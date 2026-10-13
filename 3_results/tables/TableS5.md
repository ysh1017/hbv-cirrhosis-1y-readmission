# Supplementary Table S5  Supplementary model performance and clinical benchmarking

## A. Repeated nested internal performance

| Model | Valid n | AUROC | AP | Brier |
| --- | --- | --- | --- | --- |
| Logistic regression | 98 | 0.776 (0.757, 0.797) | 0.693 (0.666, 0.723) | 0.192 (0.183, 0.201) |
| LASSO | 95 | 0.776 (0.759, 0.799) | 0.692 (0.668, 0.722) | 0.192 (0.184, 0.200) |
| Elastic net | 95 | 0.776 (0.756, 0.799) | 0.692 (0.662, 0.723) | 0.195 (0.188, 0.205) |
| Random forest | 98 | 0.764 (0.737, 0.781) | 0.645 (0.617, 0.682) | 0.196 (0.188, 0.209) |
| XGBoost | 98 | 0.766 (0.742, 0.780) | 0.661 (0.633, 0.692) | 0.195 (0.189, 0.205) |
| RBF-SVM | 98 | 0.777 (0.756, 0.798) | 0.688 (0.656, 0.719) | 0.193 (0.184, 0.201) |
| LightGBM | 98 | 0.762 (0.738, 0.779) | 0.653 (0.626, 0.688) | 0.199 (0.191, 0.209) |

Performance values are median (Q1, Q3), describing variation across overlapping partitions; they are not confidence intervals.

## A. Calibration in the same nested evaluations

| Model | Valid n | CITL | Calibration slope |
| --- | --- | --- | --- |
| Logistic regression | 98 | -0.009 (-0.114, 0.064) | 0.881 (0.718, 1.098) |
| LASSO | 95 | -0.007 (-0.108, 0.054) | 0.993 (0.802, 1.323) |
| Elastic net | 95 | -0.012 (-0.077, 0.046) | 1.196 (0.914, 1.869) |
| Random forest | 98 | -0.015 (-0.100, 0.077) | 0.861 (0.697, 1.023) |
| XGBoost | 98 | -0.025 (-0.087, 0.059) | 1.039 (0.850, 1.209) |
| RBF-SVM | 98 | -0.101 (-0.196, 0.005) | 0.932 (0.775, 1.107) |
| LightGBM | 98 | -0.020 (-0.076, 0.043) | 1.159 (0.879, 1.595) |

## A. Execution denominators

| Model | Planned | Primary eligible | Successful (primary set) | Failed (primary set) |
| --- | --- | --- | --- | --- |
| Logistic regression | 100 | 98 | 98 | 0 |
| LASSO | 100 | 98 | 95 | 3 |
| Elastic net | 100 | 98 | 95 | 3 |
| Random forest | 100 | 98 | 98 | 0 |
| XGBoost | 100 | 98 | 98 | 0 |
| RBF-SVM | 100 | 98 | 98 | 0 |
| LightGBM | 100 | 98 | 98 | 0 |

Selection completed in all 100 planned partitions. Two partitions with unsupported categorical-predictor selection were excluded from the comparable set for every model. Three further single-predictor partitions failed for LASSO and elastic net because their fitting interface required at least two columns.

Overall successful/failed fits among all 100 partitions: logistic regression 100/0; LASSO 95/5; elastic net 95/5; random forest 100/0; XGBoost 98/2; RBF-SVM 98/2; LightGBM 100/0. Completed but excluded fits are distinct from failures. Failed fits were not imputed, replaced or retried.

## B. Fixed model performance and calibration: internal validation

| Metric | RBF-SVM | Core4 logistic | MELD-Na benchmark |
| --- | --- | --- | --- |
| AUROC | 0.751 | 0.762 | 0.691 |
| AP | 0.672 | 0.716 | 0.620 |
| Brier | 0.199 | 0.193 | 0.218 |
| CITL (95% CI) | 0.020 (-0.419 to 0.430) | -0.063 (-0.493 to 0.355) | -0.103 (-0.493 to 0.267) |
| Calibration slope (95% CI) | 0.822 (0.484 to 1.252) | 0.796 (0.480 to 1.268) | 0.863 (0.442 to 1.413) |
| O/E (95% CI) | 1.009 (0.827 to 1.199) | 0.973 (0.801 to 1.148) | 0.950 (0.770 to 1.133) |
| Mean predicted probability (95% CI) | 0.410 (0.369 to 0.452) | 0.425 (0.381 to 0.468) | 0.435 (0.405 to 0.466) |
| Observed event proportion (95% CI) | 0.414 (0.331 to 0.496) | 0.414 (0.331 to 0.496) | 0.414 (0.331 to 0.496) |

AUROC, AP and Brier are saved point estimates; marginal confidence intervals are not supplied for these three metrics. Existing calibration and prediction-level confidence intervals are retained.

## B. Fixed model performance and calibration: external evaluation

| Metric | RBF-SVM | Core4 logistic | MELD-Na benchmark |
| --- | --- | --- | --- |
| AUROC | 0.770 | 0.712 | 0.669 |
| AP | 0.853 | 0.785 | 0.732 |
| Brier | 0.199 | 0.225 | 0.214 |
| CITL (95% CI) | 0.725 (0.159 to 1.272) | 0.781 (0.085 to 1.458) | 0.055 (-0.730 to 0.682) |
| Calibration slope (95% CI) | 0.853 (0.415 to 1.491) | 0.223 (-0.038 to 0.774) | 0.412 (0.022 to 0.931) |
| O/E (95% CI) | 1.251 (1.058 to 1.447) | 1.231 (1.027 to 1.467) | 1.015 (0.811 to 1.178) |
| Mean predicted probability (95% CI) | 0.525 (0.432 to 0.606) | 0.533 (0.427 to 0.623) | 0.647 (0.575 to 0.717) |
| Observed event proportion (95% CI) | 0.657 (0.517 to 0.767) | 0.657 (0.517 to 0.767) | 0.657 (0.517 to 0.767) |

AUROC, AP and Brier are saved point estimates; marginal confidence intervals are not supplied for these three metrics. Existing calibration and prediction-level confidence intervals are retained.

## C. RBF-SVM versus MELD-Na: paired differences

| Cohort | AUROC difference (95% CI) | AP difference (95% CI) | Brier improvement (95% CI) |
| --- | --- | --- | --- |
| Internal validation | 0.060 (-0.021 to 0.141) | 0.052 (-0.050 to 0.159) | 0.019 (-0.011 to 0.048) |
| External evaluation | 0.100 (-0.029 to 0.233) | 0.122 (0.001 to 0.230) | 0.015 (-0.036 to 0.072) |

AUROC and AP differences are RBF-SVM minus MELD-Na; Brier improvement is MELD-Na minus RBF-SVM. Positive values favor RBF-SVM.

## C. Other paired comparisons: internal validation

| Comparison (left minus right) | AUROC difference (95% CI) | AP difference (95% CI) | Brier difference (95% CI) |
| --- | --- | --- | --- |
| Core4 logistic minus MELD-Na benchmark | 0.071 (-0.013 to 0.156) | 0.096 (0.001 to 0.195) | -0.025 (-0.054 to 0.005) |
| RBF-SVM minus Core4 logistic | -0.012 (-0.038 to 0.014) | -0.044 (-0.094 to 0.004) | 0.006 (-0.004 to 0.016) |

All three differences retain the left-minus-right direction. A negative Brier difference favors the left model.

## C. Other paired comparisons: external evaluation

| Comparison (left minus right) | AUROC difference (95% CI) | AP difference (95% CI) | Brier difference (95% CI) |
| --- | --- | --- | --- |
| Core4 logistic minus MELD-Na benchmark | 0.042 (-0.082 to 0.158) | 0.054 (-0.043 to 0.140) | 0.011 (-0.041 to 0.065) |
| RBF-SVM minus Core4 logistic | 0.058 (-0.010 to 0.143) | 0.068 (-0.018 to 0.169) | -0.026 (-0.060 to -0.000) |

All three differences retain the left-minus-right direction. A negative Brier difference favors the left model.

## D. Nested patient-level aggregate: coverage

| Patients | Events | Paired partitions | Total paired predictions |
| --- | --- | --- | --- |
| 445 | 185 | 98 | 13034 |

## D. Paired held-out predictions per patient

| Minimum | Q1 | Median | Mean | Q3 | Maximum |
| --- | --- | --- | --- | --- | --- |
| 15 | 26 | 29 | 29.2899 | 32 | 45 |

## D. Nested patient-level aggregate: absolute and paired performance

| Metric | RBF-SVM (95% CI) | MELD-Na benchmark (95% CI) | Paired difference (95% CI) |
| --- | --- | --- | --- |
| AUROC | 0.783 (0.739 to 0.824) | 0.722 (0.675 to 0.769) | 0.061 (0.025 to 0.097) |
| AP | 0.679 (0.606 to 0.760) | 0.618 (0.546 to 0.691) | 0.061 (0.012 to 0.116) |
| Brier | 0.189 (0.172 to 0.206) | 0.212 (0.196 to 0.228) | 0.024 (0.010 to 0.036) |

AUROC/AP: RBF-SVM minus MELD-Na. Brier improvement: MELD-Na minus RBF-SVM. Positive paired values favor RBF-SVM.

Each patient contributes the mean of paired predictions made only while that patient was held out. The saved intervals from 5,000 paired patient-bootstrap draws condition on those predictions and do not repeat model development. This aggregate describes the domestic cohort; it is not a third independent cohort or a single newly fitted model.

Internal validation: 133 patients and 55 events. External evaluation: 102 hospitalization episodes from 50 patients, with 67 event episodes. AUROC/AP/Brier in B are point estimates; calibration and prediction summaries retain their existing intervals.

Fixed paired comparisons use patient resampling internally and patient-cluster resampling externally. Diagnostic calibration does not replace the original predictions. See Notes M2 and M4.

Abbreviations: AUROC, area under the receiver operating characteristic curve; AP, average precision; CITL, calibration-in-the-large; CI, confidence interval; O/E, observed-to-expected ratio; Q1/Q3, first/third quartiles; LASSO, least absolute shrinkage and selection operator; RBF-SVM, radial-basis-function support vector machine; XGBoost, Extreme Gradient Boosting; LightGBM, Light Gradient Boosting Machine; MELD-Na, Model for End-Stage Liver Disease-sodium. Core4 comprises international normalized ratio, platelet count, albumin-bilirubin score and fibrosis-4 index.

## E. External model-ranking stability under patient-cluster bootstrap resampling

AUROC

| Model | Mean rank | First-place share (%) | Top-three share (%) |
| --- | --- | --- | --- |
| Logistic regression | 4.38 | 1.13 | 28.19 |
| LASSO | 5.41 | 0.11 | 13.72 |
| Elastic net | 3.59 | 6.40 | 48.75 |
| Random forest | 4.11 | 0.31 | 49.78 |
| XGBoost | 3.31 | 4.43 | 62.11 |
| RBF-SVM | 1.24 | 87.62 | 95.61 |
| LightGBM | 5.96 | 0.00 | 1.84 |

AP

| Model | Mean rank | First-place share (%) | Top-three share (%) |
| --- | --- | --- | --- |
| Logistic regression | 4.86 | 1.00 | 14.76 |
| LASSO | 6.16 | 0.02 | 5.40 |
| Elastic net | 4.34 | 6.36 | 25.00 |
| Random forest | 3.36 | 1.78 | 73.60 |
| XGBoost | 2.24 | 28.74 | 86.92 |
| RBF-SVM | 1.73 | 62.10 | 91.80 |
| LightGBM | 5.31 | 0.00 | 2.52 |

Brier score

| Model | Mean rank | First-place share (%) | Top-three share (%) |
| --- | --- | --- | --- |
| Logistic regression | 5.16 | 0.80 | 12.36 |
| LASSO | 5.42 | 0.14 | 14.06 |
| Elastic net | 4.11 | 4.60 | 32.60 |
| Random forest | 3.55 | 0.92 | 61.00 |
| XGBoost | 3.35 | 2.80 | 65.62 |
| RBF-SVM | 1.20 | 89.54 | 97.36 |
| LightGBM | 5.21 | 1.20 | 17.00 |

Rank summaries used 5,000 common patient-cluster bootstrap samples of the fixed external predictions (102 hospitalization episodes from 50 patients; 67 event episodes). In each sample, 50 patients were drawn with replacement, retaining all eligible episodes and their sampling multiplicities; performance remained episode-weighted. Models were ranked separately by higher AUROC, higher AP and lower Brier score, with rank 1 denoting the best value. Tied positions were equally apportioned using a numerical tolerance of 10⁻¹². Mean rank was averaged across samples; first-place and top-three shares sum the corresponding apportioned rank frequencies. All 5,000 samples were valid for each metric. Shares are descriptive resampling summaries, not probabilities that a model is truly optimal.

Abbreviations: AUROC, area under the receiver operating characteristic curve; AP, average precision; LASSO, least absolute shrinkage and selection operator; RBF-SVM, radial-basis-function support vector machine; XGBoost, Extreme Gradient Boosting; LightGBM, Light Gradient Boosting Machine.

## F. Paired external performance differences between RBF-SVM and the other candidate models

ΔAUROC (RBF-SVM minus comparator)

| Comparator | Point difference (95% bootstrap CI) | SVM-leading frequency (%) |
| --- | --- | --- |
| Logistic regression | +0.0580 (-0.0104 to 0.1435) | 94.68 |
| LASSO | +0.0648 (-0.0068 to 0.1551) | 95.94 |
| Elastic net | +0.0525 (-0.0167 to 0.1381) | 91.94 |
| Random forest | +0.0503 (0.0042 to 0.1173) | 98.66 |
| XGBoost | +0.0420 (-0.0083 to 0.1112) | 94.32 |
| LightGBM | +0.0753 (0.0221 to 0.1458) | 99.80 |

ΔAP (RBF-SVM minus comparator)

| Comparator | Point difference (95% bootstrap CI) | SVM-leading frequency (%) |
| --- | --- | --- |
| Logistic regression | +0.0678 (-0.0182 to 0.1691) | 91.94 |
| LASSO | +0.0774 (-0.0149 to 0.1793) | 93.80 |
| Elastic net | +0.0656 (-0.0231 to 0.1680) | 90.08 |
| Random forest | +0.0193 (-0.0176 to 0.0948) | 85.08 |
| XGBoost | +0.0044 (-0.0326 to 0.0884) | 67.32 |
| LightGBM | +0.0544 (0.0056 to 0.1429) | 99.00 |

Brier improvement (comparator minus RBF-SVM)

| Comparator | Point difference (95% bootstrap CI) | SVM-leading frequency (%) |
| --- | --- | --- |
| Logistic regression | +0.0256 (0.0000243 to 0.0600) | 97.52 |
| LASSO | +0.0262 (-0.0015 to 0.0608) | 96.66 |
| Elastic net | +0.0224 (-0.0057 to 0.0555) | 94.20 |
| Random forest | +0.0161 (0.0003 to 0.0336) | 97.64 |
| XGBoost | +0.0156 (-0.0021 to 0.0349) | 95.94 |
| LightGBM | +0.0264 (0.0019 to 0.0483) | 98.16 |

Point differences were calculated in the complete external cohort. Paired 95% percentile bootstrap CIs are the 2.5th and 97.5th percentiles of within-sample differences from the same 5,000 patient-cluster samples used in panel E. Differences are RBF-SVM minus comparator for AUROC and AP, and comparator minus RBF-SVM for Brier; positive values favor RBF-SVM. SVM-leading frequency is the proportion of valid samples with a difference greater than 10⁻¹², with ties retained in the denominator; it is not a P value. All 5,000 samples were valid for each comparison. The CIs are comparison-specific and unadjusted for multiplicity. Additional digits are retained for near-zero interval limits. Panels E and F summarize fixed predictions in the same external cohort: models were not refitted, and this exploratory analysis does not provide independent validation or adjust for model selection.

Abbreviations: CI, confidence interval; AUROC, area under the receiver operating characteristic curve; AP, average precision; LASSO, least absolute shrinkage and selection operator; RBF-SVM, radial-basis-function support vector machine; XGBoost, Extreme Gradient Boosting; LightGBM, Light Gradient Boosting Machine.
