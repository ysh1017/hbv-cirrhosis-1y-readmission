make_task <- function(df, vars, id) {
    dd <- as.data.frame(df[, vars, drop = FALSE])
    dd$target <- factor(df$Outcome, levels = c(0, 1), labels = c("No", "Yes"))
    task <- mlr3::TaskClassif$new(id = id, backend = dd, target = "target", positive = "Yes")
    task$set_col_roles("target", add_to = "stratum")
    task
}

make_repeated_cv <- function(task) {
    set.seed(SEED)
    r <- mlr3::rsmp("repeated_cv", folds = CV_FOLDS, repeats = CV_REPEATS)
    r$instantiate(task)
    r
}

make_mbo_tuner <- function() {
    surrogate <- mlr3mbo::SurrogateLearner$new(mlr3mbo::default_rf())
    mlr3tuning::tnr("mbo", surrogate = surrogate)
}

make_logistic <- function() {
    mlr3::lrn("classif.log_reg", predict_type = "prob")
}

make_lasso <- function() {
    mlr3::lrn("classif.glmnet", predict_type = "prob", alpha = 1, standardize = TRUE)
}

space_lasso <- function() {
    paradox::ps(lambda = paradox::p_dbl(lower = log(1e-05), upper = log(1), trafo = exp))
}

make_en <- function() {
    mlr3::lrn("classif.glmnet", predict_type = "prob", standardize = TRUE)
}

space_en <- function() {
    paradox::ps(alpha = paradox::p_dbl(lower = 0.05, upper = 0.95), lambda = paradox::p_dbl(lower = log(1e-05), upper = log(1),
        trafo = exp))
}

make_rf <- function() {
    mlr3::lrn("classif.ranger", predict_type = "prob", num.trees = RF_TREES, importance = "none", num.threads = 1L)
}

space_rf <- function() {
    paradox::ps(mtry.ratio = paradox::p_dbl(lower = 0.2, upper = 1), min.node.size = paradox::p_int(lower = 2L, upper = 30L),
        sample.fraction = paradox::p_dbl(lower = 0.6, upper = 0.95))
}

make_xgb <- function() {
    mlr3::lrn("classif.xgboost", predict_type = "prob", nrounds = 200L, colsample_bytree = 1, gamma = 0, alpha = 0, nthread = 1L,
        verbose = 0, verbosity = 0)
}

space_xgb <- function() {
    paradox::ps(max_depth = paradox::p_int(lower = 1L, upper = 4L), min_child_weight = paradox::p_dbl(lower = 1, upper = 12),
        eta = paradox::p_dbl(lower = log(0.01), upper = log(0.15), trafo = exp), subsample = paradox::p_dbl(lower = 0.6,
            upper = 0.95), lambda = paradox::p_dbl(lower = log(0.5), upper = log(20), trafo = exp))
}

make_svm <- function() {
    mlr3::lrn("classif.svm", predict_type = "prob", type = "C-classification", kernel = "radial", scale = TRUE)
}

space_svm <- function() {
    paradox::ps(cost = paradox::p_dbl(lower = log(2^-4), upper = log(2^8), trafo = exp), gamma = paradox::p_dbl(lower = log(2^-10),
        upper = log(2^1), trafo = exp))
}
