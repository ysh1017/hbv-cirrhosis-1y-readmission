# Fixed screening R44A: all 46 candidates, same seed and settings in each imputation.
options(stringsAsFactors=FALSE,digits=17)
invisible(Sys.setlocale("LC_ALL", "Chinese (Simplified)_China.utf8"))
suppressPackageStartupMessages({library(data.table); library(jsonlite); library(dplyr); library(digest); library(glmnet); library(Boruta)})
stopifnot(packageVersion("glmnet")==package_version("4.1-10"),packageVersion("Boruta")==package_version("9.0.0"))
script_arg <- grep("^--file=", commandArgs(FALSE), value=TRUE)
code_dir <- dirname(normalizePath(sub("^--file=", "", script_arg[[1]]), mustWork=TRUE))
args <- commandArgs(TRUE)
if(length(args)!=2L) stop("Usage: fixed_select.R RUN IMPUTATION")
run <- args[1]
a <- as.integer(args[2])
stopifnot(a %in% 1:5)
src <- file.path(code_dir,"preprocessing_reference.R")
out <- file.path(run,"02_selection",sprintf("fixed_imputation_%d",a))
dir.create(out,recursive=TRUE,showWarnings=FALSE)
save_csv <- function(x,name) fwrite(x,file.path(out,name),bom=TRUE,na="")
s <- readRDS(file.path(run,"01_imputation",sprintf("fixed_train_imputation_%d.rds",a)))
train <- s$train
screen <- s$screening
fac <- s$categorical
stopifnot(nrow(train)==317L,length(screen)==46L,!anyNA(train[,c("Outcome",screen)]))
y <- as.integer(as.character(train$Outcome))
core <- c("INR","PLT","ALBI","FIB.4")
warnings <- list()
phase <- "LASSO"
handler <- function(w) {
  warnings[[length(warnings)+1L]] <<- list(phase=phase, message=conditionMessage(w))
  invokeRestart("muffleWarning")
}
fit_selection <- function() {
  lassodata <- train[,c("Outcome",screen),drop=FALSE]
  continuous <- setdiff(screen,fac)
  scales <- rbindlist(lapply(continuous,function(v) {
    bounds <- range(lassodata[[v]])
    lassodata[[v]] <<- if(diff(bounds)==0) rep(0,nrow(lassodata)) else
                       (lassodata[[v]]-bounds[1])/diff(bounds)
    data.frame(variable=v,min=bounds[1],max=bounds[2],constant=diff(bounds)==0)
  }))
  mm <- model.matrix(Outcome~.,data=lassodata)
  ass <- attr(mm,"assign")
  labels <- attr(terms(Outcome~.,data=lassodata),"term.labels")
  x <- mm[,ass!=0,drop=FALSE]
  mapping <- data.frame(term=colnames(x), source_variable=gsub("`","",labels[ass[ass!=0]],fixed=TRUE))
  stopifnot(setequal(mapping$source_variable,screen),all(is.finite(x)))
  set.seed(123)
  foldid <- sample(rep(seq_len(10),length.out=nrow(x)))
  lasso_path <- glmnet::glmnet(x,y,family="binomial",alpha=1,nlambda=1000,standardize=FALSE)
  lasso_cv <- glmnet::cv.glmnet(x,y,family="binomial",alpha=1,foldid=foldid,nlambda=1000,standardize=FALSE)
  extract_lasso <- function(rule) {
    co <- as.matrix(coef(lasso_cv,s=rule))
    keep <- rownames(co)!="(Intercept)" & co[,1]!=0
    data.frame(term=rownames(co)[keep],coefficient=unname(co[keep,1]),lambda_rule=rule)
  }
  lasso_terms <- rbind(extract_lasso("lambda.min"),extract_lasso("lambda.1se"))
  lasso_terms$source_variable <- mapping$source_variable[match(lasso_terms$term,mapping$term)]
  lasso <- unique(lasso_terms$source_variable[lasso_terms$lambda_rule=="lambda.1se"])
  stopifnot(!anyNA(lasso))
  save_csv(scales,"lasso_train_minmax.csv")
  save_csv(cbind(s$meta,fold=foldid,Outcome=y),"lasso_foldids.csv")
  save_csv(mapping,"lasso_model_terms.csv")
  save_csv(lasso_terms,"lasso_selected_terms.csv")
  save_csv(data.frame(lambda=lasso_cv$lambda,cvm=lasso_cv$cvm,cvsd=lasso_cv$cvsd,
                      cvup=lasso_cv$cvup,cvlo=lasso_cv$cvlo,nzero=lasso_cv$nzero),"lasso_cv.csv")
  saveRDS(list(path=lasso_path,cv=lasso_cv,mapping=mapping,foldid=foldid),file.path(out,"lasso_objects.rds"))
  message("LASSO complete; running Boruta for imputation ",a)
  phase <<- "Boruta"
  set.seed(123)
  boruta <- Boruta::Boruta(Outcome~.,data=train[,c("Outcome",screen),drop=FALSE],
      pValue=.01,mcAdj=TRUE,maxRuns=1000,doTrace=1,holdHistory=TRUE,getImp=Boruta::getImpRfZ)
  final <- Boruta::TentativeRoughFix(boruta)
  selected_boruta <- Boruta::getSelectedAttributes(final,withTentative=FALSE)
  initial_stats <- Boruta::attStats(boruta)
  final_stats <- Boruta::attStats(final)
  selection <- data.frame(imputation=a,variable=screen,in_lasso_lambda_1se=screen %in% lasso,
                          boruta_before=initial_stats[screen,"decision"],boruta_after=final_stats[screen,"decision"],
                          in_boruta=screen %in% selected_boruta,
                          in_intersection=screen %in% intersect(lasso,selected_boruta))
  stopifnot(!anyNA(selection))
  panel <- selection$variable[selection$in_intersection]
  save_csv(selection,"selection_46.csv")
  save_csv(cbind(variable=rownames(initial_stats),initial_stats),"boruta_before_roughfix.csv")
  save_csv(cbind(variable=rownames(final_stats),final_stats),"boruta_after_roughfix.csv")
  saveRDS(list(raw=boruta,roughfixed=final),file.path(out,"boruta_objects.rds"))
  save_csv(data.frame(imputation=a, feature=panel),"selected_panel.csv")
  save_csv(data.frame(imputation=a, feature_count=length(panel),core_count=sum(core %in% panel),
    all_core_preserved=all(core %in% panel),exact_core=setequal(core,panel),
    core_jaccard=length(intersect(panel,core))/length(union(panel,core)),
    panel=paste(panel,collapse=";")),"core4_comparison.csv")
  if (a==2L) {
    phase <<- "Spearman and VIF"
    for (which in c("main_panel","core4_reference")) {
      vars <- if(which=="main_panel") panel else core
      if(length(vars)>0L) {
        expanded <- model.matrix(reformulate(vars),train)
        m <- expanded[,attr(expanded,"assign")!=0L,drop=FALSE]
        rho <- cor(m,method="spearman")
        save_csv(cbind(term=rownames(rho),as.data.frame(rho)),sprintf("spearman_%s.csv",which))
        vif <- lapply(colnames(m),function(term) {
          rest <- setdiff(colnames(m),term)
          a <- if(length(rest)==0L) 0 else summary(lm(m[,term]~m[,rest,drop=FALSE]))$r.squared
          data.frame(term=term,R2=a,tolerance=1-a,VIF=1/(1-a))
        })
        save_csv(rbindlist(vif),sprintf("vif_%s.csv",which))
      }
    }
  }
  write_json(list(status="completed",imputation=a,n=317L,events=sum(y),
      selection_seed=123L,lasso_lambda_min=lasso_cv$lambda.min,lasso_lambda_1se=lasso_cv$lambda.1se,
      lasso_type_measure=lasso_cv$name,lasso_nlambda=1000L,lasso_standardize=FALSE,
      boruta_p=.01,boruta_mcAdj=TRUE,boruta_maxRuns=1000L,boruta_iterations=nrow(boruta$ImpHistory),
      boruta_getImp="getImpRfZ",boruta_roughfix=TRUE,panel=panel),
      file.path(out,"selection_summary.json"),pretty=TRUE,auto_unbox=TRUE)
  if (a==2L) {
    phase <<- "Univariable logistic"
    expr <- Filter(function(z) is.call(z) && identical(z[[1]],as.name("<-")) &&
                   identical(z[[2]],as.name("univariable_logistic")),parse(src,encoding="UTF-8"))
    stopifnot(length(expr)==1L)
    eval(expr[[1]])
    uni <- univariable_logistic(train,screen)
    save_csv(uni$summary[order(uni$summary$Overall_P_LRT),],"univariable_overall_p.csv")
    save_csv(uni$detail,"univariable_coefficients.csv")
    writeLines(c("Historical function exported in preprocessing_reference.R.",
                 "Fixed development rows only, imputation 2, all 46 candidates.",
                 "One unpenalized binomial GLM per variable, overall LRT, broom::tidy",
                 "with profile 95% CI and exponentiated coefficients. Factor reference",
                 "is the first level. Continuous OR per one unit in the analysis field.",
                 "Univariable results have no gating role in the selection."),
               file.path(out,"univariable_implementation.txt"))
  }
}
tryCatch(withCallingHandlers(fit_selection(),warning=handler),finally={
  fwrite(rbindlist(warnings,fill=TRUE),file.path(out,"warnings.csv"),bom=TRUE,na="")
  writeLines(capture.output(sessionInfo()),file.path(out,"session_info.txt"))
})
message("Fixed selection complete for imputation ",a)
