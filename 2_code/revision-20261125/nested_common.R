options(stringsAsFactors=FALSE,digits=17)
invisible(Sys.setlocale('LC_CTYPE','English_United States.utf8'))
script_arg <- grep("^--file=", commandArgs(FALSE), value=TRUE)
code_dir <- dirname(normalizePath(sub("^--file=", "", script_arg[[1]]), mustWork=TRUE))

RUN <- Sys.getenv("HBV_RUN", unset="")
if(!nzchar(RUN)) stop("Set HBV_RUN to the authorized private run directory")
NESTED <- file.path(RUN,'11_nested_stability')
CODE <- code_dir
HIST <- code_dir
cfg <- list(derivation_source_path=file.path(CODE,'preprocessing_reference.R'),
            model_source_path=file.path(CODE,'model_reference.R'))
respect_reserved_worker_pool <- function() {
    args <- commandArgs(TRUE)
    if(!length(args))return(invisible(NULL))
    seed <- suppressWarnings(as.integer(args[1]))
    if(is.na(seed) || !seed%in%1001:1100)return(invisible(NULL))
    current_pool <- Sys.getenv('HBV_NESTED_WORKER_POOL',unset='primary')
    script <- grep('^--file=',commandArgs(FALSE),value=TRUE)
    model <- if(length(args)>1L)args[2] else if(any(endsWith(script,'fit_nested_lightgbm.R')))'LightGBM' else NULL
    p <- file.path(NESTED,paste0('seed_',seed))
    markers <- if(is.null(model))file.path(p,c('SELECTION_COMPLETE.json','PREPARE_SELECTION_FAILURE.json')) else
        file.path(p,model,c('MODEL_COMPLETE.json','MODEL_FAILURE.json'))
    for(pool in setdiff(c('high','assist'),current_pool)){
        lease <- file.path(NESTED,paste0('SCHEDULER_ACTIVE_',pool,'.json'))
        while(file.exists(lease)) {
            lock <- tryCatch(fromJSON(lease),error=function(e)NULL)
            if(!is.null(lock) && !is.null(lock$seed_min) && !is.null(lock$seed_max)){
                if(seed<lock$seed_min || seed>lock$seed_max)break
                if(any(file.exists(markers)))quit(status=0)
            }
            # The reserved worker pool owns the matched seed until its lease ends.
            Sys.sleep(10)
        }
    }
}
check_gate <- function() {
    gate <- fromJSON(file.path(NESTED,'SPLIT_STAGE.json'))
    stopifnot(gate$status=='PASS',gate$rows==453L,gate$training_n==318L,gate$holdout_n==135L)
    respect_reserved_worker_pool()
}
suppressPackageStartupMessages({library(data.table);library(jsonlite);library(digest)})
data.table::setDTthreads(1L)
Sys.setenv(OMP_NUM_THREADS='1',OPENBLAS_NUM_THREADS='1',MKL_NUM_THREADS='1')
stamp<-function()format(Sys.time(),'%Y-%m-%dT%H:%M:%OS6%z')
js<-function(z,p)write_json(z,p,auto_unbox=TRUE,pretty=TRUE,digits=17,na='null',null='null')
wc<-function(z,p){z<-as.data.table(copy(z));for(j in names(z))if(is.double(z[[j]]))z[[j]]<-ifelse(is.na(z[[j]]),'',sprintf('%.17g',z[[j]]));fwrite(z,p,bom=TRUE,na='',buffMB=1L,nThread=1L)}
atomic_rds<-function(z,p){tmp<-paste0(p,'.partial');saveRDS(z,tmp,version=3);stopifnot(file.rename(tmp,p))}
ALGS<-c('Logistic','LASSO','ElasticNet','RandomForest','XGBoost','SVM_RBF')
sha<-function(p)digest(readBin(p,'raw',n=file.info(p)$size),serialize=FALSE,algo='sha256')
load_model_functions<-function(){
 suppressPackageStartupMessages({library(mlr3);library(mlr3learners);library(mlr3tuning);library(mlr3mbo);library(paradox);library(bbotk)})
 lgr::get_logger('mlr3')$set_threshold('warn');lgr::get_logger('bbotk')$set_threshold('warn');future::plan(future::sequential)
 assign('CV_FOLDS',10L,.GlobalEnv);assign('CV_REPEATS',5L,.GlobalEnv);assign('MBO_EVALS',30L,.GlobalEnv);assign('RF_TREES',1000L,.GlobalEnv)
 allow<-c('make_task','make_repeated_cv','make_mbo_tuner','make_logistic','make_lasso','space_lasso','make_en','space_en','make_rf','space_rf','make_xgb','space_xgb','make_svm','space_svm')
 for(e in parse(cfg$model_source_path,encoding='UTF-8'))if(is.call(e)&&identical(as.character(e[[1]]),'<-')&&is.symbol(e[[2]])&&as.character(e[[2]])%in%allow)eval(e,envir=.GlobalEnv)
 stopifnot(all(vapply(allow,exists,logical(1),envir=.GlobalEnv,inherits=FALSE)))
}
learner_for<-function(m)switch(m,Logistic=make_logistic(),LASSO=make_lasso(),ElasticNet=make_en(),RandomForest=make_rf(),XGBoost=make_xgb(),SVM_RBF=make_svm())
space_for<-function(m)switch(m,LASSO=space_lasso(),ElasticNet=space_en(),RandomForest=space_rf(),XGBoost=space_xgb(),SVM_RBF=space_svm(),NULL)
