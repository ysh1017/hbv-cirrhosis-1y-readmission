# Same-split MELD-Na logistic benchmark, adapted from R46_FIT_MELD_BENCHMARK100.R.
script_arg <- grep("^--file=", commandArgs(FALSE), value=TRUE)
code_dir <- dirname(normalizePath(sub("^--file=", "", script_arg[[1]]), mustWork=TRUE))
source(file.path(code_dir,"nested_common.R"),encoding="UTF-8")
check_gate()
d<-file.path(NESTED,'meld_benchmark')
if(!dir.exists(d))stopifnot(dir.create(d))
files<-c('meld_benchmark_predictions.csv','meld_benchmark_parameters.csv','meld_benchmark_models.rds','MELD_QC.json')
if(any(file.exists(file.path(d,files))))stop('Existing benchmark files')
protocol<-fread(file.path(RUN,'00_protocol','analysis_input_453_raw.csv'),colClasses=c(id='character'),na.strings=c('','NA'))
sp<-fread(file.path(NESTED,'all_outer_splits.csv'),colClasses=c(patient_id='character'))
old_path<-'3_results/03_domestic_development/r46_repeated_holdout_svm_meldna_benchmark/run_20260915_210344/R46_DOMESTIC445_MELD_OUTCOME_SOURCE.csv'
old_benchmark<-fread(old_path,colClasses=c(Patient_ID='character'))
ref<-readRDS(file.path(NESTED,'nested_raw_input.rds'))
stopifnot(!anyNA(ref$data[,c('Scr','Sodium','INR','TBIL')]),identical(protocol$id,ref$ids))
original_DNA_3group<-factor(ref$original_DNA_3group,levels=c('0','1','2'))
original_DNA_3group_missing<-is.na(original_DNA_3group)
ff<-Filter(function(z)is.call(z)&&identical(z[[1]],as.name('<-'))&&identical(z[[2]],as.name('recalculate_derived')),parse(cfg$derivation_source_path,encoding='UTF-8'))
stopifnot(length(ff)==1)
eval(ff[[1]],.GlobalEnv)
new_meld<-recalculate_derived(ref$data)$MELD.Na
old_idx<-match(as.character(old_benchmark$Patient_ID),protocol$id)
stopifnot(all(old_idx%in%1:445),sum(protocol$Y365)==193,
          identical(as.numeric(new_meld[old_idx]),as.numeric(old_benchmark$MELD.Na)),
          identical(as.integer(protocol$Y365[old_idx]),as.integer(old_benchmark$Outcome)))
recorded<-protocol[['MELD.Na']]
recorded_equal<-sum(!is.na(recorded)&recorded==new_meld)
recorded_mismatch<-sum(!is.na(recorded)&recorded!=new_meld)
dom<-data.frame(patient_id=ref$ids,Outcome=protocol$Y365,MELD.Na=new_meld)
rows<-list(); parameters<-list(); models<-list()
for(s in 1001:1100){
    z<-sp[seed==s]
    tr<-match(z[role=='outer_train',patient_id],dom$patient_id)
    te<-match(z[role=='outer_test',patient_id],dom$patient_id)
    stopifnot(!anyNA(c(tr,te)),length(tr)==318L,length(te)==135L,!length(intersect(tr,te)))
    train<-dom[tr,,drop=FALSE]
    fit<-glm(Outcome~MELD.Na,family=binomial(link='logit'),data=train)
    val<-dom[te,,drop=FALSE]
    probability<-as.numeric(predict(fit,newdata=val,type='response'))
    manual<-plogis(unname(coef(fit)[1])+unname(coef(fit)[2])*val$MELD.Na)
    maxerr<-max(abs(probability-manual))
    stopifnot(fit$converged,!anyNA(probability),maxerr<1e-12)
    models[[as.character(s)]]<-list(model=fit,train_ids=train$patient_id,holdout_ids=val$patient_id)
    rows[[as.character(s)]]<-data.table(replicate=s-1000L,seed=s,patient_id=val$patient_id,outcome=val$Outcome,
                                       model='MELDNA_BENCHMARK',selected_predictors='MELD.Na',
                                       predicted_probability=probability,MELD.Na=val$MELD.Na)
    parameters[[as.character(s)]]<-data.table(seed=s,training_n=nrow(train),training_events=sum(train$Outcome),holdout_n=nrow(val),
                                             heldout_events=sum(val$Outcome),intercept=unname(coef(fit)[1]),
                                             slope=unname(coef(fit)[2]),manual_probability_max_abs_difference=maxerr)
}
wc(rbindlist(rows),file.path(d,files[1]))
wc(rbindlist(parameters),file.path(d,files[2]))
atomic_rds(models,file.path(d,files[3]))
js(list(status='PASS',number_of_fits=length(models),legacy_MELD_N_exact=length(old_idx),
        updated_MELD_N_available=sum(is.finite(new_meld)),recorded_453_agree=recorded_equal,
        recorded_453_disagree=recorded_mismatch,recorded_453_missing=sum(is.na(recorded)),
        source_of_MELD_Na='Original deterministic computation from baseline inputs, verified exact against archived R46.',
        model_formula='Outcome ~ MELD.Na',fitted_on_holdout_rows=0,external_data_used=FALSE),file.path(d,files[4]))
cat('100 MELD-Na-only allowed fits; 13,500 holdout probabilities written.\n')
