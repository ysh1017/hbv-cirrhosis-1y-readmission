# Full outer-training workflow. It never fits a predictive model.
script_arg <- grep("^--file=", commandArgs(FALSE), value=TRUE)
code_dir <- dirname(normalizePath(sub("^--file=", "", script_arg[[1]]), mustWork=TRUE))
source(file.path(code_dir,"nested_common.R"),encoding="UTF-8")
suppressPackageStartupMessages({library(mice);library(glmnet);library(Boruta)})
check_gate();seed<-as.integer(commandArgs(TRUE)[1]);stopifnot(seed%in%1001:1100)
out<-file.path(NESTED,paste0('seed_',seed));dir.create(out,recursive=TRUE,showWarnings=FALSE)
done<-file.path(out,'SELECTION_COMPLETE.json')
if(file.exists(done)){z<-fromJSON(done);stopifnot(z$status%in%c('PASS','FAILED_FEATURE_SELECTION'));quit(status=0)}
warnings<-list();phase<-'READ_INPUT';start<-stamp()
recordwarn<-function(w){warnings[[length(warnings)+1L]]<<-list(phase=phase,message=conditionMessage(w));invokeRestart('muffleWarning')}
main<-function(){
 ref<-readRDS(file.path(NESTED,'nested_raw_input.rds'));raw<-ref$data;ids<-ref$ids;pool<-ref$pool;fac<-ref$fac;y<-as.integer(as.character(raw$Outcome))
 splits<-fread(file.path(NESTED,'all_outer_splits.csv'),colClasses=c(patient_id='character'));outer_seed<-seed;sp<-splits[splits$seed==outer_seed];setorder(sp,raw_row)
 stopifnot(nrow(raw)==453,nrow(sp)==453,identical(ids,sp$patient_id),identical(y,as.integer(sp$outcome)),length(pool)==46)
 train<-sp$role=='outer_train';dt<-raw[train,,drop=FALSE];test<-!train;stopifnot(sum(train)==318,sum(y[train])==136,sum(test)==135,sum(y[test])==57)
 wc(data.table(variable=names(raw),training_missing=colSums(is.na(dt)),test_missing=colSums(is.na(raw[test,,drop=FALSE]))),file.path(out,'MISSINGNESS.csv'))
 impfile<-file.path(out,'MICE_M5_ACTION2.rds');mseed<-100000L+seed
 if(file.exists(impfile)){imp<-readRDS(impfile);stopifnot(identical(imp$data,raw),identical(imp$ignore,test),imp$seed==mseed)}else{
  phase<<-'TRAIN_ONLY_MICE_SETUP';RNGkind("L'Ecuyer-CMRG",'Inversion','Rejection');set.seed(mseed)
  meth0<-mice::make.method(dt);pm0<-mice::make.predictorMatrix(dt);meth0['Outcome']<-'';pm0['Outcome',]<-0;pm0[,'Outcome']<-0
  for(v in c('HBV.DNA.numeric','NEU','LYM','MON'))if(anyNA(raw[[v]])){
   stopifnot(sum(!is.na(dt[[v]]))>=2,length(unique(na.omit(dt[[v]])))>=2);meth0[v]<-'pmm'
  }
  ini<-mice::mice(dt,maxit=0,method=meth0,predictorMatrix=pm0,printFlag=FALSE)
  meth<-ini$method;pm<-ini$predictorMatrix;meth['Outcome']<-'';pm['Outcome',]<-0;pm[,'Outcome']<-0
  for(v in c('HBV.DNA.numeric','NEU','LYM','MON'))if(anyNA(raw[[v]]))meth[v]<-'pmm'
  phase<<-'NEW_MICE';set.seed(mseed);before<-.Random.seed
  imp<-mice::mice(raw,m=5,maxit=20,seed=mseed,method=meth,predictorMatrix=pm,ignore=test,remove.constant=FALSE,remove.collinear=FALSE,printFlag=FALSE)
  atomic_rds(imp,impfile)
  js(list(start=start,end=stamp(),m=5,maxit=20,action=2,MICE_seed=mseed,RNG_before=unname(before),RNG_after=unname(.Random.seed),train_n=318,test_n=135,structure_estimation='OUTER_TRAIN_ONLY',initial_donors='OBSERVED_AND_NOT_IGNORE',parameter_estimation='MICE_SAMPLER_RY_EXCLUDES_TEST',Outcome_predictor=FALSE),file.path(out,'MICE_EXECUTION.json'))
 }
 stopifnot(imp$m==5,imp$iteration==20,all(imp$predictorMatrix['Outcome',]==0),all(imp$predictorMatrix[,'Outcome']==0),imp$method['Outcome']=='')
 wc(data.table(variable=names(imp$method),method=unname(imp$method)),file.path(out,'MICE_METHODS.csv'))
 wc(data.table(variable=rownames(imp$predictorMatrix),imp$predictorMatrix),file.path(out,'MICE_PREDICTOR_MATRIX.csv'))
 wc(data.table(patient_id=ids,ignore=test),file.path(out,'MICE_IGNORE.csv'))
 wc(if(is.null(imp$loggedEvents))data.table(it=integer(),im=integer(),dep=character(),meth=character(),out=character())else imp$loggedEvents,file.path(out,'MICE_LOGGED_EVENTS.csv'))
 base<-mice::complete(imp,2)
 for(v in names(raw)){ok<-!is.na(raw[[v]]);stopifnot(identical(as.character(base[[v]][ok]),as.character(raw[[v]][ok])))}
 stopifnot(identical(as.character(base$Outcome),as.character(raw$Outcome)))
 phase<<-'DERIVE_AFTER_IMPUTATION'
 original_aux<-data.frame(HBV.DNA.3group=ref$original_DNA_3group)
 assign('original_DNA_3group',factor(original_aux$HBV.DNA.3group,levels=c('0','1','2')),.GlobalEnv)
 assign('original_DNA_3group_missing',is.na(get('original_DNA_3group',.GlobalEnv)),.GlobalEnv)
 ff<-Filter(function(z)is.call(z)&&identical(z[[1]],as.name('<-'))&&identical(z[[2]],as.name('recalculate_derived')),parse(cfg$derivation_source_path,encoding='UTF-8'))
 stopifnot(length(ff)==1);eval(ff[[1]],.GlobalEnv);completed<-recalculate_derived(base)
 # Preserve originally observed groups as authorized; the archived source fills only missing groups.
 dna_observed <- !is.na(original_aux$HBV.DNA.3group)
 stopifnot(all(as.character(completed$HBV.DNA.3group[dna_observed])==as.character(original_aux$HBV.DNA.3group[dna_observed])))
 stopifnot(all(pool%in%names(completed)),!anyNA(completed[,pool]),identical(completed$ALBI,round(.66*log10(base$TBIL)-.085*base$Albumin,2)),identical(completed$FIB.4,round(base$Age*base$AST/(base$PLT*sqrt(base$ALT)),2)))
 atomic_rds(list(data=completed,ids=ids,is_train=train,pool=pool,factor_vars=fac,seed=seed),file.path(out,'COMPLETED_DATA.rds'))
 # Only these 318 rows are retained in the separate selection workspace.
 tr<-completed[train,c('Outcome',pool),drop=FALSE];ti<-ids[train]
 atomic_rds(list(train_data=tr,train_ids=ti,pool=pool,seed=seed,test_present=FALSE),file.path(out,'TRAIN_ONLY_SELECTION_INPUT.rds'))
 rm(raw,base,completed,ref,original_aux,imp,dt);invisible(gc())
 ld<-tr;continuous<-setdiff(pool,fac)
 scaling<-rbindlist(lapply(continuous,function(v)data.table(variable=v,minimum=min(ld[[v]]),maximum=max(ld[[v]]))))
 for(v in continuous){a<-min(ld[[v]]);b<-max(ld[[v]]);ld[[v]]<-if(a==b)rep(0,nrow(ld))else(ld[[v]]-a)/(b-a)}
 ld[fac]<-lapply(ld[fac],as.factor)
 mm<-model.matrix(Outcome~.,data=ld);asn<-attr(mm,'assign');labels<-attr(terms(Outcome~.,data=ld),'term.labels');ix<-which(asn!=0);x<-mm[,ix,drop=FALSE];yy<-as.numeric(as.character(tr$Outcome))
 mapping<-data.frame(term=colnames(x),source_variable=labels[asn[ix]]);stopifnot(setequal(mapping$source_variable,pool))
 wc(mapping,file.path(out,'LASSO_TERM_SOURCE_MAP.csv'));wc(scaling,file.path(out,'LASSO_TRAIN_ONLY_SCALING.csv'))
 RNGkind('Mersenne-Twister','Inversion','Rejection');set.seed(300000L+seed);fold<-sample(rep(1:10,length.out=nrow(x)))
 wc(data.table(patient_id=ti,fold=fold),file.path(out,'LASSO_TRAIN_FOLDS.csv'))
 phase<<-'LASSO';cv<-glmnet::cv.glmnet(x,yy,family='binomial',alpha=1,foldid=fold,nlambda=1000,standardize=FALSE)
 co<-as.matrix(coef(cv,s='lambda.1se'));ix<-rownames(co)!='(Intercept)'&co[,1]!=0;term<-rownames(co)[ix];ls<-unique(mapping$source_variable[match(term,mapping$term)]);stopifnot(!anyNA(ls))
 wc(data.table(term=term,source_variable=mapping$source_variable[match(term,mapping$term)],coefficient=co[ix,1]),file.path(out,'LASSO_SELECTED_TERMS.csv'))
 phase<<-'BORUTA';bd<-tr;bd$Outcome<-factor(bd$Outcome,levels=c('0','1'));bd[fac]<-lapply(bd[fac],as.factor);set.seed(400000L+seed)
 bm<-Boruta::Boruta(Outcome~.,data=bd,pValue=.01,mcAdj=TRUE,maxRuns=1000,holdHistory=TRUE,doTrace=0,getImp=Boruta::getImpRfZ)
 bf<-if(any(bm$finalDecision=='Tentative'))Boruta::TentativeRoughFix(bm)else bm;bs<-Boruta::getSelectedAttributes(bf,withTentative=FALSE);inter<-pool[pool%in%ls&pool%in%bs]
 wc(data.table(replicate=seed-1000L,seed=seed,variable=pool,LASSO=pool%in%ls,Boruta=pool%in%bs,intersection=pool%in%inter,Boruta_original=as.character(bm$finalDecision[pool]),Boruta_after_RoughFix=as.character(bf$finalDecision[pool])),file.path(out,'FEATURE_SELECTION.csv'))
 atomic_rds(list(lasso=cv,boruta_before=bm,boruta_after=bf,intersection=inter,pool=pool,term_mapping=mapping,train_ids=ti,foldid=fold),file.path(out,'SELECTION_OBJECTS.rds'))
 js(list(status=if(length(inter))'PASS'else'FAILED_FEATURE_SELECTION',reason=if(length(inter))NULL else'EMPTY_INTERSECTION_NO_FALLBACK',seed=seed,replicate=seed-1000L,LASSO=ls,Boruta=bs,intersection=inter,LASSO_n=length(ls),Boruta_n=length(bs),intersection_n=length(inter),primary_eligible=!any(inter%in%fac),selected_categorical=inter[inter%in%fac],lambda_min=cv$lambda.min,lambda_1se=cv$lambda.1se,LASSO_seed=300000L+seed,Boruta_seed=400000L+seed,MICE_seed=mseed,train_n=318,test_n=135,selection_test_rows=0,warnings=warnings,start=start,end=stamp()),done)
 cat('SELECTION_COMPLETE',seed,'LASSO',length(ls),'BORUTA',length(bs),'INTERSECTION',paste(inter,collapse=','),'\n')
}
tryCatch(withCallingHandlers(main(),warning=recordwarn),error=function(e){js(list(status='FAILED_PREPARATION_OR_SELECTION',seed=seed,phase=phase,error=conditionMessage(e),warnings=warnings,start=start,end=stamp()),file.path(out,'PREPARE_SELECTION_FAILURE.json'));stop(e)})
