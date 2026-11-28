# Study cohorts, code and aggregate results

This repository accompanies a study on prediction of one-year unplanned readmission for decompensation in HBV-related decompensated cirrhosis. It provides reproducibility code, synthetic examples and selected aggregate results. See the [repository rights and use notice](../../0_admin/RIGHTS_AND_USE.md). Public access does not grant an open-source license. The code and models are research material and are not clinically validated for deployment.

## Study cohorts and models

- Chinese cohort: 453 patients, including 317 in development and 136 in fixed internal validation, with 193 target events overall.
- Exploratory MIMIC-IV evaluation: 102 eligible index hospitalizations from 50 patients, with a target event following 67 index hospitalizations. External outcomes are limited to events observed in the database's covered system. External results informed model selection and are exploratory.
- The sensitivity analysis used the first eligible index hospitalization for each of the 50 patients, selected independently of the outcome. There were 25 target events.
- [Cohort counts](cohort_summary.csv) and [Core4 discrimination](core4_auroc.csv) report selected aggregate results. The RBF-SVM is the main reported model. Core4 LASSO and ordinary logistic regression are comparators. MELD-Na is the clinical benchmark.

## Available code and limits

The [code directory](../../2_code/revision-20261125) contains the original study formulas, predictor definitions, fixed PMM, LASSO/Boruta selection, seven model specifications and fit drivers, selected nested workers, locked Core4 scoring, paired evaluation with cluster resampling, and overview flow figure-generation functions. The drivers provide the analysis logic for investigator-supplied lawful data. Cohort construction and clinical adjudication remain governed by the source institutions. There is no patient dataset, fitted model, private fold assignment or original resampling index archive in this release. No MIMIC-IV data are redistributed. MIMIC-IV access requires [PhysioNet credentialed access and adherence to the applicable data use agreement](https://physionet.org/content/mimiciv/3.1/).

The public LASSO coefficients use original input scale. The raw score is a logit; the reported risk is its inverse-logit. The SVM and ordinary logistic scoring adapter requires an investigator-held, trusted, compatible fitted object. An RBF-SVM can contain patient-derived support vectors, so that object is not distributed; this is not a standalone SVM risk calculator. SHAP is a prediction attribution, distinct from a coefficient, logit, or predicted probability.

## Test the public interfaces

From the repository root, with R 4.5.1, or Python 3.12 and the pinned [Python requirements](../../2_code/revision-20261125/requirements.txt):

```sh
Rscript --vanilla 2_code/revision-20261125/score_core4.R lasso 2_code/revision-20261125/synthetic_Core4_input.csv local_lasso.csv
python 2_code/revision-20261125/evaluate_core4.py 2_code/revision-20261125/synthetic_evaluation.csv local_pairing.csv --models model_a model_b --seed 123 --draws 30
python 2_code/revision-20261125/evaluate_core4.py 2_code/revision-20261125/synthetic_evaluation.csv local_first.csv --models model_a model_b --seed 123 --draws 30 --first-index
Rscript --vanilla 2_code/revision-20261125/smoke_models.R local_model_smoke.csv
```

The LASSO example returns two rows with probabilities near 0.076534 and 0.603924. The paired example emits absolute and paired left-minus-right metrics in 15 rows. The synthetic first-index example reduces 14 fixture rows to 10 rows, one per fixture cluster. The R model smoke reports seven rows on a synthetic training fixture. Smoke tests cover the formula, preprocessing and PMM interface, reduced-size LASSO/Boruta screening, learner prediction, these paired metrics, and first eligible membership handling. They are not a rerun of the clinical study, real-data authentication, or a test of all 100 nested partitions. The checked software versions are in [environment notes](../../2_code/revision-20261125/ENVIRONMENT.md).

## Private input contracts for authorized investigators

- The models expect numeric Core4 values. Stored input order is ALBI, FIB.4, INR, PLT; INR is a ratio, PLT is measured in 10⁹/L and both indices are dimensionless. ALBI and FIB-4 use the stated component units, admission hierarchy and two-decimal rounding. See [derived predictors](../../2_code/revision-20261125/derived_predictor_definitions.csv).
- Keep paths and output locations in a private directory outside this repository. To reuse the fixed drivers, provide `00_protocol/analysis_input_453_raw.csv` (one unique clinical study record per row, valid `id`, `registry_id`, `Y365`, and the baseline fields named by `preprocessing_reference.R`), `00_protocol/split_manifest_updated.csv` (matching `id`, `registry_id`, `Y365`, `patient_cluster`, and `split`), and the investigator's `00_protocol/analysis_protocol.json`. The preprocessing driver applies five PMM completions with the validation partition excluded from parameter estimation and outcome excluded from MICE. Reference completion is 2.
- Execute `fixed_impute.R PRIVATE_RUN`, `fixed_select.R PRIVATE_RUN COMPLETION`, `make_fixed_folds.R PRIVATE_RUN`, and `fixed_model.R PRIVATE_RUN ALGORITHM COMPLETIONS` via `Rscript --vanilla`. The scripts write local completed data, imputation and screening diagnostics, fixed folds, fitted objects and predictions to the supplied private run directory. Study input checks enforce the reference cohort and known fixed partitions. A compatible built LightGBM 4.7.0 R package is required for LightGBM. MELD-Na is an additional benchmark. The supplied training smoke exercises the learner libraries and interfaces without tuning.
- Nested workers take `HBV_RUN` and the authorized local `11_nested_stability/SPLIT_STAGE.json`, `all_outer_splits.csv`, and `nested_raw_input.rds`. This RDS stores the private `data`, `ids`, `pool`, and categorical specification `fac`. The nested design used 100 planned seeds (1001–1100); its fitting and selection artifacts must remain in authorized storage. Neither raw cohort assembly, split orchestration/history, nor separate controlled launchers and recovery orchestration are publicly distributed.
- Paired evaluation takes a private CSV with one row per eligible admission or study record, unique `record`, clustering label `cluster`, `outcome` (0/1), and probability columns named via `--models`. `--first-index` uses a supplied, verified `first_eligible` flag, one independently adjudicated earliest eligible episode per cluster. Never construct that flag using the outcome. The public utility generates draws with the supplied seed; the clinical report used 5,000 aligned cluster draws and is conditional on the supplied fixed predictions. Exact historical draws are not distributed.
- The flow figure module is a rendering library. Call `render_vectors(output, layout, nodes, reasons, font_dir)` with lawful aggregate counts/labels and locally installed Arial. Public layout geometry has no counts or patient information. The release does not distribute the clinical figure's individual data, SHAP details, training examples, or the paper.
