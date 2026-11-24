script_arg <- grep("^--file=", commandArgs(FALSE), value=TRUE)
code_dir <- dirname(normalizePath(sub("^--file=", "", script_arg[[1]]), mustWork=TRUE))
source(file.path(code_dir,"nested_common.R"),encoding="UTF-8")
load_model_functions()
suppressPackageStartupMessages(library(lightgbm))
stopifnot(as.character(getNamespaceVersion('lightgbm'))=='4.7.0')
seed_values<-function(s)list(outer_seed=s,inner_cv_original_generation_seed=200000L+s,inner_folds_reused=TRUE,tuning_seed=700000L+s,seed=800000L+s,data_random_seed=900000L+s,feature_fraction_seed=1000000L+s,bagging_seed=1100000L+s,drop_seed=1200000L+s,extra_seed=1300000L+s,final_fit_seed=1400000L+s)
source(file.path(HIST,'original_lightgbm_learner.R'),encoding='UTF-8')
s <- as.integer(commandArgs(TRUE)[1])
stopifnot(s%in%1001:1100)
mode <- 'A'
check_gate()
d <- file.path(NESTED,paste0('seed_',s))
md <- file.path(d,'LightGBM')
dir.create(md,showWarnings=FALSE)
done<-file.path(md,'MODEL_COMPLETE.json');fail<-file.path(md,'MODEL_FAILURE.json')
if(file.exists(done)){q<-fromJSON(done);stopifnot(sha(file.path(md,'MODEL.rds'))==q$model_sha256);quit(status=0)}
if(file.exists(fail))stop('EXISTING_FAILURE_RETAINED_NO_AUTOMATIC_RETRY')
start<-stamp();phase<-'INPUTS';warnings<-list()
main<-function(){
 sel<-fromJSON(file.path(d,'SELECTION_COMPLETE.json'));v<-as.character(sel$intersection)
 tr<-readRDS(file.path(d,'TRAIN_ONLY_SELECTION_INPUT.rds'));stopifnot(!tr$test_present)
 lev<-lapply(tr$train_data[,v,drop=FALSE],levels);lev<-lev[!vapply(lev,is.null,logical(1))]
 task<-make_task(tr$train_data,v,paste0('LGB_TRAIN_',s))
 fd<-fread(file.path(d,'Logistic/INNER_CV_HELD_OUT_IDS.csv'))
 tes<-lapply(1:50,function(i)as.integer(fd[iteration==i,row_id]));trs<-lapply(tes,function(j)setdiff(seq_along(tr$train_ids),j));cv<-rsmp('custom');cv$instantiate(task,train_sets=trs,test_sets=tes)
 stopifnot(cv$iters==50,all(vapply(1:50,function(i)identical(cv$test_set(i),tes[[i]]),logical(1))))
 wc(fd,file.path(md,'INNER_CV_HELD_OUT_IDS.csv'));wc(data.table(position=seq_along(v),feature=v),file.path(md,'FEATURE_ORDER.csv'));wc(data.table(row_id=seq_along(tr$train_ids),patient_id=tr$train_ids),file.path(md,'TRAIN_IDS.csv'))
 js(lev,file.path(md,'NATIVE_CATEGORY_LEVELS.json'))
 seeddef<-seed_values(s);RNGkind("L'Ecuyer-CMRG",'Inversion','Rejection');l<-LgbControlled$new(v,lev,s)
 phase<<-'TUNING';tp<-file.path(md,'TUNING.rds')
 if(file.exists(tp))tu<-readRDS(tp)else{
  set.seed(seeddef$tuning_seed);rb<-.Random.seed
  tuner<-make_mbo_tuner();tuner$args<-list(init_design_size=16L)
  ins<-mlr3tuning::tune(tuner=tuner,task=task,learner=l$clone(deep=TRUE),resampling=cv,measures=msr('classif.auc'),search_space=lgb_space(),term_evals=30L,store_benchmark_result=TRUE,store_models=FALSE)
  ar<-as.data.table(ins$archive);js(list(actual_evaluations=nrow(ar),requested_budget=30,initial_design_size=16),file.path(md,'TUNING_BUDGET_CHECK.json'));stopifnot(nrow(ar)==30,all(is.finite(ar[['classif.auc']])));best<-which.max(ar[['classif.auc']])
  detail<-rbindlist(lapply(1:30,function(k){sc<-ar$resample_result[[k]]$score(msr('classif.auc'));stopifnot(nrow(sc)==50);data.table(evaluation=k,iteration=sc$iteration,AUROC=sc[['classif.auc']])}))
  wc(detail,file.path(md,'TUNING_ALL_FOLD_SCORES.csv'));wc(ar[,which(!vapply(ar,is.list,logical(1))),with=FALSE],file.path(md,'TUNING_ARCHIVE.csv'))
  cand<-rbindlist(lapply(1:30,function(k)c(list(evaluation=k,mean_inner_AUROC=ar[['classif.auc']][k]),ar$x_domain[[k]])));wc(cand,file.path(md,'TUNING_CANDIDATE_SEQUENCE.csv'))
  tu<-list(parameters=ar$x_domain[[best]],evaluations=30L,chosen_evaluation=best,objective=ar[['classif.auc']][best],rng_before=rb,rng_after=.Random.seed,features=v,train_ids=tr$train_ids)
  atomic_rds(tu,tp);cat('TUNING_COMPLETE',s,mode,'\n');flush.console()
 }
 phase<<-'FINAL_FIT';l$param_set$set_values(.values=tu$parameters,.insert=TRUE);mp<-file.path(md,'MODEL.rds')
 if(file.exists(mp))fit<-readRDS(mp)else{
  set.seed(seeddef$final_fit_seed);rb<-.Random.seed;fit<-l$clone(deep=TRUE);fit$train(task)
  fit$model$save_model(file.path(md,'LIGHTGBM_MODEL.txt'));atomic_rds(fit,mp)
  atomic_rds(list(features=v,train_ids=tr$train_ids,parameters=fit$param_set$values,native_params=fit$model$params,rng_before=rb,rng_after=.Random.seed,seed_manifest=seeddef),file.path(md,'TRAINING_STATE.rds'))
 }
 js(list(model='LightGBM',outer_seed=s,features=v,parameters=fit$param_set$values,fixed_native_parameters=fixed_lgb_params(s),seed_manifest=seeddef,chosen_evaluation=tu$chosen_evaluation),file.path(md,'FINAL_PARAMETERS.json'))
 phase<<-'OUTER_TEST_PREDICTION'
 # First read of outer-test data/outcome occurs only after final model serialization.
 complete<-readRDS(file.path(d,'COMPLETED_DATA.rds'));test<-!complete$is_train;vid<-complete$ids[test];stopifnot(!length(intersect(vid,tr$train_ids)))
 p<-as.numeric(fit$predict_newdata(complete$data[test,v,drop=FALSE])$prob[,'Yes']);y<-as.integer(as.character(complete$data$Outcome[test]));stopifnot(length(p)==135,sum(y)==57,all(is.finite(p)),all(p>=0&p<=1))
 atomic_rds(p,file.path(md,'PROBABILITIES_FULL_PRECISION.rds'))
 wc(data.table(replicate=s-1000L,seed=s,patient_id=vid,outcome=y,model='LightGBM',selected_predictors=paste(v,collapse=';'),predicted_probability=p,primary_eligible=!length(lev)),file.path(md,'OUTER_TEST_PREDICTIONS.csv'))
 wc(data.table(row_id=which(test),patient_id=vid),file.path(md,'TEST_IDS.csv'))
 writeLines(capture.output(sessionInfo()),file.path(md,'sessionInfo.txt'))
 js(list(status='PASS',mode=mode,seed=s,start=start,end=stamp(),train_n=318,test_n=135,features=v,primary_eligible=!length(lev),model_sha256=sha(mp),model_text_sha256=sha(file.path(md,'LIGHTGBM_MODEL.txt')),probabilities_rds_sha256=sha(file.path(md,'PROBABILITIES_FULL_PRECISION.rds')),tuning_evaluations=30,inner_resamples=50,classification_fit_calls=1501,outer_test_tuning_rows=0,outer_test_fit_rows=0,external_data_used=FALSE,warnings=warnings),done)
 cat('MODEL_PASS',s,mode,'\n')
}
tryCatch(withCallingHandlers(main(),warning=function(w){warnings[[length(warnings)+1]]<<-list(phase=phase,message=conditionMessage(w));invokeRestart('muffleWarning')}),error=function(e){js(list(status='FAILED_MODEL',seed=s,mode=mode,phase=phase,start=start,end=stamp(),error=conditionMessage(e),warnings=warnings,automatic_fallback=FALSE),fail);stop(e)})
