# Reuses the R44B fixed-model and later fixed LightGBM source recipes.
options(stringsAsFactors=FALSE,digits=17)
invisible(Sys.setlocale("LC_CTYPE","English_United States.utf8"))
script_arg <- grep("^--file=", commandArgs(FALSE), value=TRUE)
code_dir <- dirname(normalizePath(sub("^--file=", "", script_arg[[1]]), mustWork=TRUE))

args <- commandArgs(TRUE)
if(length(args)<2L || length(args)>3L) stop("Usage: fixed_model.R RUN MODEL [IMPUTATIONS]")
run <- args[1]
algorithm <- args[2]
indexes <- if(length(args)>=3L) as.integer(strsplit(args[3],",",fixed=TRUE)[[1]]) else c(2L,1L,3:5)
stopifnot(all(indexes %in% 1:5))
suppressPackageStartupMessages({
 library(data.table);library(digest);library(jsonlite);library(mlr3)
 library(mlr3learners);library(mlr3tuning);library(mlr3mbo);library(paradox);library(bbotk)
 if(algorithm=="LightGBM") library(lightgbm)
})
future::plan(future::sequential)
setDTthreads(1L)
lgr::get_logger("mlr3")$set_threshold("warn")
lgr::get_logger("bbotk")$set_threshold("warn")
RNGkind("L'Ecuyer-CMRG","Inversion","Rejection")
SEED <- 123L
RF_TREES <- 1000L
sha <- function(p) digest(readBin(p,"raw",n=file.info(p)$size),algo="sha256",serialize=FALSE)
load_expressions <- function(src,names) {
  expressions <- parse(src,encoding="UTF-8")
  for(n in names) {
    hit <- Filter(function(z) is.call(z) && identical(z[[1]],as.name("<-")) &&
                  identical(z[[2]],as.name(n)),expressions)
    stopifnot(length(hit)==1L)
    eval(hit[[1]],envir=.GlobalEnv)
  }
}

source(file.path(code_dir,"model_reference.R"),encoding="UTF-8")
if(algorithm=="LightGBM") {
  stopifnot(packageVersion("lightgbm")==package_version("4.7.0"))
  source(file.path(code_dir,"lightgbm_seeds.R"),encoding="UTF-8")
  source(file.path(code_dir,"lightgbm_learner.R"),encoding="UTF-8")
}
make_model <- function(m,panel,lev) switch(m,
  Logistic=make_logistic(),LASSO=make_lasso(),ElasticNet=make_en(),RandomForest=make_rf(),
  XGBoost=make_xgb(),SVM_RBF=make_svm(),LightGBM=LgbControlled$new(panel,lev,123L))
search_space <- function(m) switch(m,LASSO=space_lasso(),ElasticNet=space_en(),
  RandomForest=space_rf(),XGBoost=space_xgb(),SVM_RBF=space_svm(),LightGBM=lgb_space(),NULL)
heldout <- readRDS(file.path(run,"03_models","fixed_inner_fold_assignments.rds"))
training_fold <- lapply(heldout,function(ids) setdiff(seq_len(317L),ids))
pred_dir <- file.path(run,"04_predictions","fixed")
dir.create(pred_dir,recursive=TRUE,showWarnings=FALSE)
write_json_atomic <- function(value,p) {
  tmp <- paste0(p,".",Sys.getpid(),".partial")
  write_json(value,tmp,pretty=TRUE,auto_unbox=TRUE,digits=17,na="null",null="null")
  stopifnot(file.rename(tmp,p))
}
save_csv <- function(v,p) fwrite(v,p,bom=TRUE,na="")
cache <- new.env(parent=emptyenv())
for(a in indexes) {
  out <- file.path(run,"03_models",sprintf("fixed_imputation_%d",a),algorithm)
  dir.create(out,showWarnings=FALSE,recursive=TRUE)
  started <- format(Sys.time(),"%Y-%m-%d %H:%M:%S %z")
  stage <- "INPUTS"
  warnings <- character()
  pp <- file.path(pred_dir,sprintf("imputation_%d_%s.csv",a,algorithm))
  completed_status <- file.path(out,"completion.json")
  success <- function() {
    q <- fromJSON(completed_status)
    identical(q$status,"complete") && file.exists(pp) &&
      identical(q$predictions_sha256,sha(pp)) && file.exists(q$model_path) &&
      identical(q$model_sha256,sha(q$model_path))
  }
  if(file.exists(completed_status) && success()) {
    q <- fromJSON(completed_status)
    assign(q$training_signature,q$source_imputation,cache)
    message("Reuse completed ",algorithm," imputation ",a)
    next
  }
  train_path <- file.path(run,"01_imputation",sprintf("fixed_train_imputation_%d.rds",a))
  selection_path <- file.path(run,"02_selection",sprintf("fixed_imputation_%d",a),"selection_46.csv")
  task_status <- tryCatch(withCallingHandlers({
    tr <- readRDS(train_path)
    if(algorithm=="MELD-Na") {
      panel <- "MELD.Na"
    } else {
      limit <- Sys.time() + 1800
      while (!file.exists(selection_path) && Sys.time()<limit) Sys.sleep(3)
      if(!file.exists(selection_path)) stop("Fixed screening is still pending for imputation ",a)
      ss <- fread(selection_path)
      stopifnot(nrow(ss)==46L)
      panel <- ss$variable[ss$in_intersection]
    }
    if(!length(panel)) stop("Zero original LASSO-Boruta intersection; no substitute predictors")
    lev <- lapply(tr$train[,panel,drop=FALSE],levels)
    lev <- lev[!vapply(lev,is.null,logical(1))]
    task <- make_task(tr$train,panel,paste0("fixed_453_",algorithm))
    panel <- task$feature_names
    ordered <- tr$train[,c(panel,"Outcome"),drop=FALSE]
    sig <- digest(list(algorithm=algorithm,ordered=ordered,study_id=tr$meta$study_id,heldout=heldout,
                       seed=SEED,source=sha(src)),algo="sha256")
    use <- if(exists(sig,cache,inherits=FALSE)) get(sig,cache,inherits=FALSE) else a
    ref <- file.path(run,"03_models",sprintf("fixed_imputation_%d",use),algorithm)
    path <- file.path(ref,"model.rds")
    statefile <- file.path(ref,"fitted_model_manifest.json")
    if(file.exists(path) && file.exists(statefile)) {
      state <- fromJSON(statefile)
      stopifnot(identical(state$training_signature,sig), identical(state$model_sha256,sha(path)))
      fit <- readRDS(path)
    } else {
      stage <- "TUNING"
      cv <- rsmp("custom")
      cv$instantiate(task,train_sets=training_fold,test_sets=heldout)
      stopifnot(cv$iters==50L, task$nrow==317L)
      fit <- if(algorithm=="MELD-Na") make_logistic() else make_model(algorithm,panel,lev)
      model_space <- search_space(algorithm)
      tuning_out <- file.path(out,"tuning_selection.rds")
      saveRDS(model_space,file.path(out,"exact_search_space.rds"))
      if(file.exists(tuning_out)) {
        tuning <- readRDS(tuning_out)
        stopifnot(identical(tuning$training_signature,sig))
      } else if(!is.null(model_space)) {
        seed_tune <- if(algorithm=="LightGBM") seed_values(123L)$tuning_seed else SEED
        set.seed(seed_tune)
        before <- .Random.seed
        tuner <- make_mbo_tuner()
        if(algorithm=="LightGBM") tuner$args <- list(init_design_size=16L)
        message("Tuning ",algorithm," imputation ",a," on ",paste(panel,collapse=","),
                "; 30 evaluations * 50 resamples")
        instance <- mlr3tuning::tune(tuner=tuner,task=task,learner=fit$clone(deep=TRUE),
                    resampling=cv$clone(deep=TRUE),measures=msr("classif.auc"),
                    search_space=model_space,term_evals=30L,
                    store_benchmark_result=TRUE,store_models=FALSE)
        ar <- as.data.table(instance$archive)
        stopifnot(nrow(ar)==30L,all(is.finite(ar[["classif.auc"]])),
                  all(vapply(ar$resample_result,function(z) z$iters==50L,logical(1))))
        if(algorithm=="LightGBM") {
          index <- which.max(ar[["classif.auc"]])
          parameters <- ar$x_domain[[index]]
          objective <- ar[["classif.auc"]][index]
        } else {
          parameters <- instance$result_learner_param_vals
          objective <- as.numeric(unlist(instance$result_y))[1]
        }
        tuning <- list(parameters=parameters,objective=objective,evaluations=nrow(ar),
                       seed=seed_tune,rng_before=before,rng_after=.Random.seed,training_signature=sig)
        scores <- rbindlist(lapply(seq_len(nrow(ar)),function(i) {
          sc <- ar$resample_result[[i]]$score(msr("classif.auc"))
          data.frame(evaluation=i,iteration=sc$iteration,AUROC=sc[["classif.auc"]])
        }))
        save_csv(scores,file.path(out,"tuning_all_fold_scores.csv"))
        scalar <- which(!vapply(ar,is.list,logical(1)))
        save_csv(ar[,..scalar],file.path(out,"tuning_archive.csv"))
        saveRDS(tuning,tuning_out)
      } else tuning <- list(parameters=list(),evaluations=0L,objective=NA_real_)
      fit$param_set$set_values(.values=tuning$parameters,.insert=TRUE)
      if(!algorithm %in% c("LightGBM","MELD-Na")) {
        stage <- "POST_TUNING_DEVELOPMENT_OOF"
        oof_path <- file.path(out,"development_oof.csv")
        if(!file.exists(oof_path)) {
          set.seed(SEED)
          result <- resample(task=task,learner=fit$clone(deep=TRUE),
                             resampling=cv$clone(deep=TRUE),store_models=FALSE,store_backends=TRUE)
          oof <- rbindlist(lapply(seq_len(result$iters),function(i) {
            p <- result$predictions()[[i]]
            data.frame(iteration=i,repeat_index=(i-1L)%/%10L+1L,fold=(i-1L)%%10L+1L,
                       row_id=p$row_ids,study_id=tr$meta$study_id[p$row_ids],
                       Y365=as.integer(p$truth=="Yes"),probability=as.numeric(p$prob[,"Yes"]))
          }))
          stopifnot(nrow(oof)==317L*5L,all(is.finite(oof$probability)))
          save_csv(oof,oof_path)
        }
      }
      stage <- "FINAL_FIT"
      seed_fit <- if(algorithm=="LightGBM") seed_values(123L)$final_fit_seed else SEED
      set.seed(seed_fit)
      train_rng_before <- .Random.seed
      fit$train(task)
      train_rng_after <- .Random.seed
      if(algorithm=="LightGBM") fit$model$save_model(file.path(out,"lightgbm_model.txt"))
      if(algorithm=="XGBoost") xgboost::xgb.save(fit$model,file.path(out,"xgboost_model.ubj"))
      saveRDS(fit,path)
      saveRDS(list(before=train_rng_before,after=train_rng_after),file.path(out,"fit_RNG.rds"))
      state <- list(status="fitted_before_validation_read",algorithm=algorithm,features=panel,
                    train_n=317L,train_events=sum(tr$train$Outcome=="1"),
                    training_signature=sig,training_sha256=sha(train_path),
                    model_sha256=sha(path),tuning_evaluations=tuning$evaluations,
                    inner_fold_iterations=50L,tuning_auroc=tuning$objective,tuning_seed=tuning$seed,
                    final_fit_seed=seed_fit,final_parameters=fit$param_set$values,
                    factor_levels=lev,mlr3_task_positive="Yes",
                    fixed_model_reference=algorithm,source_imputation=a,
                    original_modeling_source_sha256=sha(src),
                    lightgbm_original_modeling_source=if(algorithm=="LightGBM") historical_lightgbm else NULL)
      if(algorithm=="SVM_RBF") {
        state$SVM_center <- fit$model$x.scale[["scaled:center"]]
        state$SVM_scale <- fit$model$x.scale[["scaled:scale"]]
        state$SVM_probability_A <- fit$model$probA
        state$SVM_probability_B <- fit$model$probB
      }
      write_json_atomic(state,statefile)
      message("Model fit serialized ",algorithm," imputation ",a)
    }
    stage <- "PREDICTION"
    val <- readRDS(file.path(run,"01_imputation",sprintf("fixed_validation_imputation_%d.rds",a)))
    stopifnot(nrow(val$validation)==136L, !any(tr$meta$study_id %in% val$meta$study_id))
    p <- function(d) {
      prob <- as.numeric(fit$predict_newdata(d[,panel,drop=FALSE])$prob[,"Yes"])
      stopifnot(all(is.finite(prob)),all(prob>=0&prob<=1),length(prob)==nrow(d))
      prob
    }
    pack <- function(z,m) data.frame(m,algorithm=algorithm,imputation=a,Y365=as.integer(as.character(z$Outcome)),
                                    probability=p(z))
    predictions <- rbind(pack(tr$train,tr$meta),pack(val$validation,val$meta))
    save_csv(predictions,pp)
    write_json_atomic(list(status="complete",algorithm=algorithm,imputation=a,source_imputation=use,
      refit_reused_after_identical_training_input=use!=a,training_signature=sig,
      model_path=path,model_sha256=sha(path),predictions_path=pp,predictions_sha256=sha(pp),
      started=started,finished=format(Sys.time(),"%Y-%m-%d %H:%M:%S %z"),
      warnings=warnings,model_fit=state),
      completed_status)
    assign(sig,use,cache)
    message("Fixed complete ",algorithm," imputation ",a,"; fitted source imputation ",use)
    TRUE
  },warning=function(w) {
    warnings <<- c(warnings,paste0(stage,": ",conditionMessage(w)))
    invokeRestart("muffleWarning")
  }),error=function(e) {
    fail <- file.path(out,paste0("failure_",format(Sys.time(),"%Y%m%dT%H%M%S"),".json"))
    write_json_atomic(list(status="failed",algorithm=algorithm,imputation=a,phase=stage,
                           started=started,error=conditionMessage(e),warnings=warnings),fail)
    message("Fixed failed ",algorithm," imputation ",a,": ",conditionMessage(e))
    FALSE
  })
  writeLines(capture.output(sessionInfo()),file.path(out,"session_info.txt"))
}
