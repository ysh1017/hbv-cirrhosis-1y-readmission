args <- commandArgs(TRUE)
if (length(args)!=1L) stop("Usage: smoke_models.R OUTPUT_CSV")
script <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value=TRUE)[[1L]])
code <- dirname(script)
suppressPackageStartupMessages({library(mlr3); library(mlr3learners); library(paradox)})
source(file.path(code, "model_reference.R"))
source(file.path(code, "preprocessing_reference.R"))
source(file.path(code, "lightgbm_seeds.R"))
source(file.path(code, "lightgbm_learner.R"))
SEED <- 123L
RF_TREES <- 1000L
RNGkind("L'Ecuyer-CMRG","Inversion","Rejection")
set.seed(SEED)
n <- 80L
x <- data.frame(Outcome=rep(c(0L,1L),n/2L), Age=runif(n,35,82), ALT=runif(n,15,110),
                AST=runif(n,17,130), TBIL=runif(n,13,120), Albumin=runif(n,22,51),
                PLT=runif(n,32,240), INR=runif(n,0.9,2.2))
x$ALBI <- round(.66 * log10(x$TBIL) - .085 * x$Albumin, 2)
x$FIB.4 <- round(x$Age * x$AST / (x$PLT * sqrt(x$ALT)), 2)
stopifnot(all(is.finite(x$ALBI)), all(is.finite(x$FIB.4)))

# Smoke checks the same outcome-excluded PMM and validation ignore conventions.
pmm <- x[c("Outcome","ALT","AST","TBIL","Albumin")]; pmm$ALT[c(4,9,69)] <- NA
start <- mice::mice(pmm,maxit=0L,printFlag=FALSE)
choice <- start$method; pm <- start$predictorMatrix
choice["Outcome"] <- ""; pm["Outcome",] <- 0; pm[,"Outcome"] <- 0
guard <- seq_len(n) > 64L
result <- mice::mice(pmm,m=5L,maxit=20L,seed=123L,method=choice,predictorMatrix=pm,
                     ignore=guard,printFlag=FALSE)
stopifnot(identical(result$ignore,guard), all(result$predictorMatrix[,"Outcome"]==0L),
          !anyNA(mice::complete(result,2L)$ALT), identical(mice::complete(result,2L)$Outcome,pmm$Outcome))

core <- c("ALBI","FIB.4","INR","PLT")
train <- x[1:64,]; heldout <- x[65:80,core]
task <- make_task(train,core,"SyntheticTrain")
matrix_input <- as.matrix(train[core])
set.seed(SEED)
lambda_cv <- glmnet::cv.glmnet(matrix_input,train$Outcome,family="binomial",
  foldid=sample(rep(seq_len(10),length.out=nrow(train))),alpha=1,nlambda=1000,standardize=FALSE)
set.seed(SEED)
boruta <- Boruta::Boruta(Outcome~.,transform(train[c("Outcome",core)],Outcome=factor(Outcome)),
  pValue=.01,mcAdj=TRUE,maxRuns=100L,holdHistory=TRUE,getImp=Boruta::getImpRfZ)
stopifnot(is.finite(lambda_cv$lambda.1se), inherits(Boruta::TentativeRoughFix(boruta),"Boruta"))

lasso <- make_lasso(); lasso$param_set$values$lambda <- .02
elastic <- make_en(); elastic$param_set$values$lambda <- .02; elastic$param_set$values$alpha <- .5
svm <- make_svm(); svm$param_set$values$cost <- 1; svm$param_set$values$gamma <- .02
light <- LgbControlled$new(core,list(),123L)
light$param_set$values <- list(num_leaves=4L,max_depth=2L,learning_rate=.03,min_data_in_leaf=10L,
                               feature_fraction=.8,bagging_fraction=.8,lambda_l2=1,nrounds=50L)
models <- list(Logistic=make_logistic(),LASSO=lasso,ElasticNet=elastic,RandomForest=make_rf(),
               XGBoost=make_xgb(),SVM_RBF=svm,LightGBM=light)
table <- lapply(names(models),function(model) {
    learner <- models[[model]]
    learner$train(task)
    prob <- learner$predict_newdata(heldout)$prob[,"Yes"]
    stopifnot(length(prob)==nrow(heldout), all(is.finite(prob) & prob>=0 & prob<=1))
    data.frame(algorithm=model,rows=length(prob),status="synthetic_probability_interface_pass")
})
write.csv(do.call(rbind,table),args[1],row.names=FALSE)
print(sessionInfo())
