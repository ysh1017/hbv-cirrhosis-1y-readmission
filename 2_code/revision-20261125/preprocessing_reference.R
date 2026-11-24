baseline_vars_original <- c("Metabolic comorbidities", "EGVH", "Ascites", "SBP", "HE", "HRS", "Infection", "HBeAg.status",
    "Sex", "Prior.antiviral.therapy", "Smoking.history", "Alcohol.use.history", "Scr", "TBIL", "ALT", "AST", "GGT", "LDH",
    "ALP", "Albumin", "PTA", "PT", "Hb", "NEU", "LYM", "MON", "PLT", "WBC", "Potassium", "Sodium", "Chloride", "INR", "HBsAg",
    "HBV.DNA.3group", "HBV.DNA.numeric", "Age", "MELD.Na", "ALBI", "PMR", "PTAR", "NAR", "NLR", "FIB.4", "LMR", "PLR", "SIRI",
    "PNI", "APRI", "Length.of.stay", "BMI")

screening_vars_original <- setdiff(baseline_vars_original, c("HE", "PTA", "PT", "MELD.Na"))

cat_vars_original <- c("Metabolic comorbidities", "EGVH", "Ascites", "SBP", "HE", "HRS", "Infection", "HBeAg.status", "Sex",
    "Prior.antiviral.therapy", "Smoking.history", "Alcohol.use.history", "HBV.DNA.3group")

derived_vars_original <- c("HBV.DNA.3group", "MELD.Na", "ALBI", "PMR", "PTAR", "NAR", "NLR", "FIB.4", "LMR", "PLR", "SIRI",
    "PNI", "APRI")

recalculate_derived <- function(df) {
    Scr_mg_dl <- pmin(4, pmax(1, df$Scr/88.4))
    TBIL_mg_dl <- pmax(1, df$TBIL/17.1)
    INR_use <- pmax(1, df$INR)
    MELD_base <- 3.78 * log(TBIL_mg_dl) + 11.2 * log(INR_use) + 9.57 * log(Scr_mg_dl) + 6.43
    Na_use <- pmin(137, pmax(125, df$Sodium))
    df$MELD.Na <- round(MELD_base + 1.32 * (137 - Na_use) - 0.033 * MELD_base * (137 - Na_use), 2)
    df$ALBI <- ifelse(df$TBIL > 0, round(0.66 * log10(df$TBIL) - 0.085 * df$Albumin, 2), NA)
    df$NLR <- ifelse(df$LYM > 0, round(df$NEU/df$LYM, 2), NA)
    df$FIB.4 <- ifelse(df$PLT > 0 & df$ALT > 0, round(df$Age * df$AST/(df$PLT * sqrt(df$ALT)), 2), NA)
    df$LMR <- ifelse(df$MON > 0, round(df$LYM/df$MON, 2), NA)
    df$PLR <- ifelse(df$LYM > 0, round(df$PLT/df$LYM, 2), NA)
    df$SIRI <- ifelse(df$LYM > 0, round(df$NEU * df$MON/df$LYM, 2), NA)
    df$PNI <- round(df$Albumin + 5 * df$LYM, 2)
    df$APRI <- ifelse(df$PLT > 0, round((df$AST/40) * 100/df$PLT, 2), NA)
    df$PMR <- ifelse(df$MON > 0, df$PLT/df$MON, NA)
    df$PTAR <- ifelse(df$Albumin > 0, 10 * df$INR/df$Albumin, NA)
    df$NAR <- ifelse(df$Albumin > 0, 10 * df$NEU/df$Albumin, NA)
    dna3_chr <- as.character(original_DNA_3group)
    miss3 <- original_DNA_3group_missing
    if (any(miss3)) {
        dna3_chr[miss3] <- ifelse(df$HBV.DNA.numeric[miss3] < log10(2000), "0", ifelse(df$HBV.DNA.numeric[miss3] < log10(20000),
            "1", "2"))
    }
    df$HBV.DNA.3group <- factor(dna3_chr, levels = c("0", "1", "2"))
    df
}

univariable_logistic <- function(df, predictors) {
    detail_list <- list()
    summary_list <- list()
    for (v in predictors) {
        if (length(unique(df[[v]])) < 2L)
            next
        f <- reformulate(v, response = "Outcome")
        fit <- tryCatch(glm(f, data = df, family = binomial), error = function(e) NULL)
        if (is.null(fit))
            next
        p_overall <- tryCatch({
            a <- anova(fit, test = "LRT")
            as.numeric(a$`Pr(>Chi)`[2])
        }, error = function(e) NA)
        td <- tryCatch(broom::tidy(fit, conf.int = TRUE, exponentiate = TRUE), error = function(e) broom::tidy(fit, exponentiate = TRUE))
        td$Variable <- v
        td$Overall_P_LRT <- p_overall
        detail_list[[v]] <- td
        summary_list[[v]] <- data.frame(Variable = v, Overall_P_LRT = p_overall, stringsAsFactors = FALSE)
    }
    list(detail = bind_rows(detail_list), summary = bind_rows(summary_list))
}
