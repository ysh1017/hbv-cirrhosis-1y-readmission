args <- commandArgs(TRUE)
if (length(args) < 3L) stop(paste(
  "Usage:",
  "score_core4.R lasso input.csv output.csv",
  "or score_core4.R fitted input.csv output.csv algorithm /trusted/local/model.rds"
))
method <- args[1L]
input <- read.csv(args[2L], check.names=FALSE, stringsAsFactors=FALSE)
fields <- c("ALBI", "FIB.4", "INR", "PLT")
if (!all(c("example_id", fields) %in% names(input)) || nrow(input) < 1L ||
    anyNA(input$example_id) || any(!nzchar(input$example_id)) || anyDuplicated(input$example_id) ||
    !all(vapply(input[fields], function(x) is.numeric(x) && all(is.finite(x)), logical(1L)))) {
  stop("Supply a nonempty CSV with unique example_id and finite numeric ALBI, FIB.4, INR, and PLT.")
}
if (identical(method, "lasso") && length(args) == 3L) {
  script <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value=TRUE)[[1L]])
  coefficients <- read.csv(file.path(dirname(script), "LASSO_final_coefficients.csv"), stringsAsFactors=FALSE)
  stopifnot(!anyDuplicated(coefficients$term), setequal(coefficients$term, c("(Intercept)", fields)))
  values <- setNames(coefficients$coefficient, coefficients$term)
  out <- values[["(Intercept)"]] + drop(as.matrix(input[fields]) %*% values[fields])
  algorithm <- "LASSO"
  probability <- plogis(out)
} else if (identical(method, "fitted") && length(args) == 5L) {
  algorithm <- args[4L]
  stopifnot(algorithm %in% c("LASSO", "Logistic", "SVM_RBF"))
  packages <- c("mlr3", "mlr3learners", switch(algorithm, LASSO="glmnet", SVM_RBF="e1071", Logistic=character()))
  for (package in packages) {
    if (!requireNamespace(package, quietly=TRUE)) stop("Install ", package, " to use a fitted learner.")
  }
  # Only load the investigator's own trusted and independently verified object.
  fit <- readRDS(args[5L])
  order <- unname(fit$state$feature_names)
  stopifnot(setequal(order, fields), identical(fit$predict_type, "prob"))
  probability <- fit$predict_newdata(input[order])$prob[, "Yes"]
} else {
  stop("Use lasso with no fitted object, or fitted with the algorithm and trusted object path.")
}
stopifnot(all(is.finite(probability) & probability >= 0 & probability <= 1))
write.csv(data.frame(example_id=input$example_id, algorithm=algorithm, probability_yes=probability),
          args[3L], row.names=FALSE)
