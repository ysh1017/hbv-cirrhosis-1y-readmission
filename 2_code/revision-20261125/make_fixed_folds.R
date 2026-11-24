args <- commandArgs(TRUE)
if (length(args)!=1L) stop("Usage: make_fixed_folds.R PRIVATE_RUN")
script <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value=TRUE)[[1L]])
source(file.path(dirname(script), "model_reference.R"), encoding="UTF-8")
SEED <- 123L
CV_FOLDS <- 10L
CV_REPEATS <- 5L
RNGkind("L'Ecuyer-CMRG","Inversion","Rejection")
input <- readRDS(file.path(args[1], "01_imputation/fixed_train_imputation_2.rds"))
task <- make_task(input$train,"INR","fixed_317_stratified")
stopifnot(task$nrow==317L)
resampling <- make_repeated_cv(task)
out <- file.path(args[1], "03_models")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
saveRDS(lapply(seq_len(resampling$iters), resampling$test_set), file.path(out,"fixed_inner_fold_assignments.rds"))
