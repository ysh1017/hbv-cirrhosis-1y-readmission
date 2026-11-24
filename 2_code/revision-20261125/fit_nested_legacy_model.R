# The fitting process opens outer-test inputs only after storing the final fit.
script_arg <- grep("^--file=", commandArgs(FALSE), value=TRUE)
code_dir <- dirname(normalizePath(sub("^--file=", "", script_arg[[1]]), mustWork=TRUE))
source(file.path(code_dir,"nested_common.R"),encoding="UTF-8")
check_gate();load_model_functions();args<-commandArgs(TRUE);seed<-as.integer(args[1]);m<-args[2];stopifnot(seed%in%1001:1100,m%in%ALGS)
out<-file.path(NESTED,paste0('seed_',seed));md<-file.path(out,m);dir.create(md,showWarnings=FALSE)
done<-file.path(md,'MODEL_COMPLETE.json');failure<-file.path(md,'MODEL_FAILURE.json')
if(file.exists(done)){z<-fromJSON(done);stopifnot(z$status=='PASS',sha(file.path(md,'MODEL.rds'))==z$model_sha256);quit(status=0)}
if(file.exists(failure))stop('FAILED_JOB_RETAINED_NO_AUTOMATIC_RETRY')
sel<-fromJSON(file.path(out,'SELECTION_COMPLETE.json'));if(sel$status!='PASS')stop('FAILED_FEATURE_SELECTION_NO_MODEL_FALLBACK')
vars<-sel$intersection;vars<-as.character(vars);stopifnot(length(vars)>0)
tr<-readRDS(file.path(out,'TRAIN_ONLY_SELECTION_INPUT.rds'));stopifnot(isFALSE(tr$test_present));task<-make_task(tr$train_data,vars,paste0('NESTED_TRAIN_',seed))
SEED<-200000L+seed;RNGkind("L'Ecuyer-CMRG",'Inversion','Rejection');set.seed(SEED)
cv<-make_repeated_cv(task);stopifnot(cv$iters==50)
wc(rbindlist(lapply(seq_len(50),function(i)data.table(iteration=i,patient_id=tr$train_ids[cv$test_set(i)],row_id=cv$test_set(i)))),file.path(md,'INNER_CV_HELD_OUT_IDS.csv'))
warnings<-list();phase<-'TUNING';start<-stamp()
warn<-function(w){warnings[[length(warnings)+1L]]<<-list(phase=phase,message=conditionMessage(w));invokeRestart('muffleWarning')}
make_cb<-function()mlr3tuning::callback_batch_tuning('nested_train_rng',on_resample_before_train=function(callback,context){
 context$data_extra<-list(iteration=context$iteration,train_rows=context$resampling$train_set(context$iteration),test_rows=context$resampling$test_set(context$iteration),RNG_before=.Random.seed,train_start=stamp())
},on_resample_end=function(callback,context){z<-context$data_extra;z$end<-stamp();z$RNG_after<-.Random.seed;z$completed<-TRUE;context$data_extra<-z})
main<-function(){
 learner<-learner_for(m)
 unsupported<-setdiff(task$feature_types$type,learner$feature_types)
 if(length(unsupported))stop('ORIGINAL_LEARNER_UNSUPPORTED_SELECTED_TYPES: ',paste(unsupported,collapse=','),'; no new encoding fallback authorized')
 tunfile<-file.path(md,'TUNING.rds')
 if(file.exists(tunfile))tu<-readRDS(tunfile)else{
  set.seed(SEED);rb<-.Random.seed
  if(m=='Logistic')tu<-list(parameters=list(),evaluations=0L,archive=NULL)else{
   ins<-mlr3tuning::tune(tuner=make_mbo_tuner(),task=task,learner=learner$clone(deep=TRUE),resampling=cv,measures=msr('classif.auc'),search_space=space_for(m),term_evals=30L,store_benchmark_result=TRUE,store_models=FALSE,callbacks=list(make_cb()))
   ar<-as.data.table(ins$archive);stopifnot(nrow(ar)==30)
   detail<-rbindlist(lapply(seq_len(30),function(k){rr<-ar$resample_result[[k]];sc<-rr$score(msr('classif.auc'));extra<-rr$data_extra$data_extra;stopifnot(nrow(sc)==50,length(extra)==50,all(vapply(extra,function(z)isTRUE(z$completed),logical(1))))
    data.table(evaluation=k,iteration=sc$iteration,AUROC=sc[['classif.auc']],RNG_start_sha256=vapply(extra,function(z)digest(z$RNG_before,algo='sha256'),character(1)),RNG_end_sha256=vapply(extra,function(z)digest(z$RNG_after,algo='sha256'),character(1))) }))
   wc(detail,file.path(md,'TUNING_ALL_FOLD_SCORES.csv'));wc(ar[,which(!vapply(ar,is.list,logical(1))),with=FALSE],file.path(md,'TUNING_ARCHIVE.csv'))
   tu<-list(parameters=ins$result_learner_param_vals,evaluations=30L,archive=ar,objective=ins$result_y)
  }
  tu$rng_before<-rb;tu$rng_after<-.Random.seed;tu$train_ids<-tr$train_ids;tu$features<-vars;atomic_rds(tu,tunfile)
 }
 phase<<-'FINAL_FIT';learner$param_set$set_values(.values=tu$parameters,.insert=TRUE)
 mp<-file.path(md,'MODEL.rds')
 if(file.exists(mp))fit<-readRDS(mp)else{
  set.seed(SEED);rb<-.Random.seed;fit<-learner$clone(deep=TRUE);fit$train(task);atomic_rds(fit,mp)
  atomic_rds(list(train_ids=tr$train_ids,features=vars,seed=SEED,rng_before=rb,rng_after=.Random.seed,parameters=fit$param_set$values,training_input_sha256=sha(file.path(out,'TRAIN_ONLY_SELECTION_INPUT.rds'))),file.path(md,'TRAINING_STATE.rds'))
 }
 phase<<-'OUTER_TEST_PREDICTION'
 # Nothing from this file is used above: tuners operate only on the train-only task.
 complete<-readRDS(file.path(out,'COMPLETED_DATA.rds'));te<-!complete$is_train;vid<-complete$ids[te];stopifnot(!length(intersect(vid,tr$train_ids)))
 prob<-as.numeric(fit$predict_newdata(complete$data[te,vars,drop=FALSE])$prob[,'Yes']);yy<-as.integer(as.character(complete$data$Outcome[te]))
 stopifnot(length(prob)==135,sum(yy)==57,all(is.finite(prob)),all(prob>=0&prob<=1))
 wc(data.table(replicate=seed-1000L,seed=seed,patient_id=vid,outcome=yy,model=m,selected_predictors=paste(vars,collapse=';'),predicted_probability=prob),file.path(md,'OUTER_TEST_PREDICTIONS.csv'))
 js(list(model=m,seed=seed,features=vars,parameters=fit$param_set$values,SVM_actual_center_scale=if(m=='SVM_RBF')fit$model$x.scale else NULL,positive='Yes'),file.path(md,'FINAL_PARAMETERS.json'))
 writeLines(capture.output(sessionInfo()),file.path(md,'sessionInfo.txt'))
 js(list(status='PASS',model=m,seed=seed,start=start,end=stamp(),train_n=318,test_n=135,feature_set=vars,model_sha256=sha(mp),tuning_evaluations=tu$evaluations,inner_resamples=50L,classification_fit_calls=tu$evaluations*50L+1L,outer_test_tuning_rows=0L,outer_test_fit_rows=0L,external_data_used=FALSE,warnings=warnings),done)
 cat('MODEL_PASS',seed,m,'\n')
}
tryCatch(withCallingHandlers(main(),warning=warn),error=function(e){js(list(status='FAILED_MODEL',seed=seed,model=m,phase=phase,error=conditionMessage(e),warnings=warnings,start=start,end=stamp(),automatic_fallback=FALSE),failure);stop(e)})
