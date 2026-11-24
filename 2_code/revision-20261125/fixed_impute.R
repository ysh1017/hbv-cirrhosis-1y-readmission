# Fixed development/validation MICE. R44A historical expressions are loaded by name.
options(stringsAsFactors=FALSE, digits=17)
invisible(Sys.setlocale("LC_ALL", "Chinese (Simplified)_China.utf8"))
suppressPackageStartupMessages({library(data.table); library(jsonlite); library(mice); library(digest)})
script_arg <- grep("^--file=", commandArgs(FALSE), value=TRUE)
code_dir <- dirname(normalizePath(sub("^--file=", "", script_arg[[1]]), mustWork=TRUE))
args <- commandArgs(TRUE)
if(length(args)!=1L) stop("Usage: fixed_impute.R RUN")
run <- args[1]
src <- file.path(code_dir,"preprocessing_reference.R")
out <- file.path(run, "01_imputation")
dir.create(out, recursive=TRUE, showWarnings=FALSE)
source_hash <- digest(file=src, algo="sha256")
stopifnot(file.exists(file.path(run, "00_protocol", "analysis_protocol.json")),
          getRversion()==package_version("4.5.1"), packageVersion("mice")==package_version("3.19.0"))
extract <- function(path, names, envir) {
  expressions <- parse(path, encoding="UTF-8")
  for (name in names) {
    match <- Filter(function(z) is.call(z) && identical(z[[1]], as.name("<-")) &&
                    identical(z[[2]], as.name(name)), expressions)
    stopifnot(length(match)==1L)
    eval(match[[1]], envir)
  }
}
save_csv <- function(x,name) fwrite(x,file.path(out,name),bom=TRUE,na="")
extract(src, c("baseline_vars_original","screening_vars_original","cat_vars_original",
               "derived_vars_original","recalculate_derived"), .GlobalEnv)
baseline <- make.names(baseline_vars_original)
screen <- make.names(screening_vars_original)
categorical <- make.names(cat_vars_original)
derived <- make.names(derived_vars_original)
raw <- fread(file.path(run,"00_protocol","analysis_input_453_raw.csv"),
             colClasses=list(character=c("id","registry_id")), na.strings=c("","NA"))
manifest <- fread(file.path(run,"00_protocol","split_manifest_updated.csv"),
                  colClasses=list(character=c("id","registry_id","patient_cluster")))
idx <- match(raw$id,manifest$id)
stopifnot(nrow(raw)==453L, nrow(manifest)==453L, !anyNA(idx), !anyDuplicated(raw$id),
          identical(raw$Y365,manifest$Y365[idx]), all(baseline %in% names(raw)),
          length(screen)==46L, length(baseline)==50L, sum(raw$Y365)==193L)
manifest <- manifest[idx]
is_train <- manifest$split=="development"
stopifnot(sum(is_train)==317L, sum(raw$Y365[is_train])==135L,
          all(manifest$split[!is_train]=="validation"))
analysis <- as.data.frame(raw[,..baseline])
analysis <- cbind(data.frame(Outcome=factor(raw$Y365, levels=c(0,1))),analysis)
analysis[categorical] <- lapply(analysis[categorical],as.factor)
analysis$HBeAg.status <- factor(as.character(analysis$HBeAg.status),
    levels=c("HBeAg-/anti-HBe+","HBeAg+/anti-HBe-","HBeAg-/anti-HBe-","HBeAg+/anti-HBe+"))
observed <- analysis
analysis$HBV.DNA.3group <- factor(as.character(analysis$HBV.DNA.3group),levels=c("0","1","2"))
original_DNA_3group <- analysis$HBV.DNA.3group
original_DNA_3group_missing <- is.na(original_DNA_3group)
for_mice <- analysis[,setdiff(names(analysis),derived),drop=FALSE]
set.seed(123)
ini <- mice(for_mice, maxit=0L, printFlag=FALSE)
methods <- ini$method
predictors <- ini$predictorMatrix
methods["Outcome"] <- ""
predictors["Outcome",] <- 0
predictors[,"Outcome"] <- 0
for(v in c("HBV.DNA.numeric","NEU","LYM","MON")) if(anyNA(for_mice[[v]])) methods[v] <- "pmm"
stopifnot(all(methods[methods!=""]=="pmm"), all(predictors[,"Outcome"]==0))
warnings <- character()
message("Starting m=5, maxit=20 fixed MICE")
set.seed(123)
imputed <- withCallingHandlers(mice(for_mice,m=5L,maxit=20L,seed=123L,method=methods,
                                      predictorMatrix=predictors,ignore=!is_train,printFlag=FALSE),
  warning=function(w) {
    warnings <<- c(warnings,conditionMessage(w))
    invokeRestart("muffleWarning")
  })
stopifnot(identical(imputed$ignore,!is_train), all(imputed$predictorMatrix[,"Outcome"]==0))
saveRDS(imputed,file.path(out,"fixed_mice_m5.rds"))
save_csv(data.frame(variable=names(imputed$method),method=unname(imputed$method)),"fixed_mice_methods.csv")
save_csv(data.frame(variable=rownames(imputed$predictorMatrix),imputed$predictorMatrix,check.names=FALSE),
         "fixed_mice_predictor_matrix.csv")
save_csv(data.frame(study_id=raw$id,ignore_for_estimation=!is_train),"fixed_mice_ignore_map.csv")
save_csv(data.frame(warning=warnings),"fixed_mice_warnings.csv")
if (!is.null(imputed$loggedEvents)) save_csv(imputed$loggedEvents,"fixed_mice_logged_events.csv")
writeLines(capture.output(sessionInfo()),file.path(out,"fixed_mice_session_info.txt"))
means <- as.data.frame.table(imputed$chainMean,responseName="chain_mean",stringsAsFactors=FALSE)
means$chain_variance <- as.vector(imputed$chainVar)
save_csv(means,"fixed_mice_chain_summary.csv")
diagnostics <- tryCatch(mice::convergence(imputed),error=function(e) data.frame(error=conditionMessage(e)))
save_csv(diagnostics,"fixed_mice_convergence.csv")
audit <- list()
for (a in 1:5) {
  completed <- analysis
  completed[,names(for_mice)] <- mice::complete(imputed,action=a)
  rebuilt <- recalculate_derived(completed)
  # The total instruction fixes original observations. Historic formulas populate
  # unobserved cells; available values and DNA categories stay as 453 raw.
  for (v in derived) {
    known <- !is.na(analysis[[v]])
    if (is.factor(analysis[[v]])) {
      difference <- as.character(rebuilt[[v]][known]) != as.character(analysis[[v]][known])
    } else difference <- is.na(rebuilt[[v]][known]) | rebuilt[[v]][known]!=analysis[[v]][known]
    audit[[length(audit)+1L]] <- data.frame(imputation=a,variable=v,
        observed_preserved=sum(known),raw_missing=sum(!known),
        recomputation_differences_in_observed=sum(difference,na.rm=TRUE))
    rebuilt[[v]][known] <- analysis[[v]][known]
  }
  for(v in names(analysis)) {
    known <- !is.na(analysis[[v]])
    stopifnot(isTRUE(all.equal(rebuilt[[v]][known], analysis[[v]][known],tolerance=0,check.attributes=FALSE)))
  }
  stopifnot(!anyNA(rebuilt[,c("Outcome",screen,"MELD.Na")]))
  meta <- data.frame(study_id=raw$id, patient_group=manifest$patient_cluster,
                     cohort=manifest$split)
  save_csv(cbind(meta, rebuilt), sprintf("fixed_completed_imputation_%d.csv",a))
  saveRDS(list(train=rebuilt[is_train,,drop=FALSE],meta=meta[is_train,,drop=FALSE],
               screening=screen,categorical=intersect(categorical,screen),imputation=a),
          file.path(out,sprintf("fixed_train_imputation_%d.rds",a)))
  saveRDS(list(validation=rebuilt[!is_train,,drop=FALSE],meta=meta[!is_train,,drop=FALSE]),
          file.path(out,sprintf("fixed_validation_imputation_%d.rds",a)))
}
save_csv(rbindlist(audit),"fixed_derived_cell_audit.csv")
write_json(list(R=as.character(getRversion()),mice=as.character(packageVersion("mice")),
                m=5L,maxit=20L,seed=123L,primary_action=2L,train_n=317L,validation_n=136L,
                validation_ignored_for_estimation=TRUE,outcome_used_as_predictor=FALSE,
                observed_derived_preserved=TRUE,original_formula_source=src,
                original_formula_sha256=source_hash),
           file.path(out,"fixed_mice_configuration.json"),pretty=TRUE,auto_unbox=TRUE)
message("Fixed MICE complete")
