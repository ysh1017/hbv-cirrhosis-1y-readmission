# Minimal adapter to the existing mlr3 MBO optimizer. No extra learner packages.
native_seeds<-function(s){z<-seed_values(s);z[c('seed','data_random_seed','feature_fraction_seed','bagging_seed','drop_seed','extra_seed')]}
fixed_lgb_params<-function(s)c(list(objective='binary',boosting='gbdt',metric='auc',device_type='cpu',num_threads=1L,deterministic=TRUE,force_col_wise=TRUE,force_row_wise=FALSE,feature_pre_filter=FALSE,verbosity=-1L,bagging_freq=1L,lambda_l1=0,min_gain_to_split=0,extra_trees=FALSE),native_seeds(s))
lgb_space<-function()ps(num_leaves=p_int(2L,15L),max_depth=p_int(2L,5L),learning_rate=p_dbl(log(.01),log(.15),trafo=exp),min_data_in_leaf=p_int(10L,50L),feature_fraction=p_dbl(.70,1),bagging_fraction=p_dbl(.70,.95),lambda_l2=p_dbl(log(.5),log(20),trafo=exp),nrounds=p_int(50L,400L))
LgbControlled<-R6::R6Class('LgbControlled',inherit=mlr3::LearnerClassif,public=list(
 feature_order=NULL,category_levels=NULL,outer_seed=NULL,
 initialize=function(vars,levels_map,seed){
  self$feature_order<-vars;self$category_levels<-levels_map;self$outer_seed<-seed
  super$initialize(id='classif.lightgbm_controlled',param_set=ps(num_leaves=p_int(2L,15L,tags='train'),max_depth=p_int(2L,5L,tags='train'),learning_rate=p_dbl(.01,.15,tags='train'),min_data_in_leaf=p_int(10L,50L,tags='train'),feature_fraction=p_dbl(.70,1,tags='train'),bagging_fraction=p_dbl(.70,.95,tags='train'),lambda_l2=p_dbl(.5,20,tags='train'),nrounds=p_int(50L,400L,tags='train')),predict_types='prob',feature_types=c('integer','numeric','factor'),properties=c('twoclass'),packages='lightgbm',label='CPU deterministic LightGBM controlled extension')
  self$predict_type<-'prob'
 }
),private=list(
 matrix_data=function(task){
  d<-as.data.frame(task$data(cols=self$feature_order));stopifnot(identical(names(d),self$feature_order))
  for(n in names(self$category_levels)){
   code<-match(as.character(d[[n]]),self$category_levels[[n]])-1L
   if(anyNA(code))stop('Unseen categorical level; no test-informed recoding allowed')
   d[[n]]<-code
  }
  x<-as.matrix(d);storage.mode(x)<-'double';stopifnot(!anyNA(x),ncol(x)==length(self$feature_order));x
 },
 .train=function(task){
  had<-exists('.Random.seed',envir=.GlobalEnv,inherits=FALSE);if(had)rng<-get('.Random.seed',.GlobalEnv)
  on.exit(if(had)assign('.Random.seed',rng,.GlobalEnv),add=TRUE)
  x<-private$matrix_data(task);y<-as.integer(task$truth()==task$positive);p<-self$param_set$get_values(tags='train');nr<-p$nrounds;p$nrounds<-NULL
  params<-c(fixed_lgb_params(self$outer_seed),p)
  ds<-lightgbm::lgb.Dataset(x,label=y,categorical_feature=names(self$category_levels),params=params)
  lightgbm::lgb.train(params=params,data=ds,nrounds=nr,verbose=-1L)
 },
 .predict=function(task){
  pr<-as.numeric(predict(self$model,private$matrix_data(task)));prob<-cbind(1-pr,pr);colnames(prob)<-c('No','Yes');list(prob=prob)
 }
))
