# Supplementary Table S7  Discrimination by readmission timing

## A. Event-time groups and shared non-event controls

| Cohort / period | Cases | Common controls | Analyzed records | Patients / units | Unclassified positive times |
| --- | --- | --- | --- | --- | --- |
| Internal / Early | 22 | 78 | 100 | 100 | 0 |
| Internal / Late | 33 | 78 | 111 | 111 | 0 |
| External / Early | 48 | 35 | 83 | 48 | 2 |
| External / Late | 17 | 35 | 52 | 37 | 2 |

Internal units are patients; external records are hospitalization episodes. External patients may contribute multiple episodes. The early and late comparisons share the same one-year non-event controls; their displayed sizes must not be added to reconstruct the primary cohort.

Two external event episodes with unclassifiable timing remain in the one-year analysis and are excluded from both time groups. The repeated count in the two external rows denotes the same two episodes.

## B. Fixed internal model scores: time-stratified discrimination

| Model | Early AUROC (95% CI) | Late AUROC (95% CI) | Late minus early (95% CI) |
| --- | --- | --- | --- |
| Logistic regression | 0.846 (0.745 to 0.930) | 0.707 (0.591 to 0.814) | -0.139 (-0.270 to -0.012) |
| LASSO | 0.848 (0.749 to 0.932) | 0.711 (0.596 to 0.817) | -0.137 (-0.267 to -0.011) |
| Elastic net | 0.843 (0.744 to 0.929) | 0.709 (0.594 to 0.814) | -0.134 (-0.261 to -0.009) |
| Random forest | 0.837 (0.736 to 0.924) | 0.711 (0.601 to 0.815) | -0.126 (-0.253 to -0.004) |
| XGBoost | 0.838 (0.736 to 0.926) | 0.686 (0.572 to 0.793) | -0.152 (-0.285 to -0.026) |
| RBF-SVM | 0.818 (0.712 to 0.911) | 0.706 (0.593 to 0.811) | -0.112 (-0.235 to 0.012) |

## C. Fixed external model scores: time-stratified discrimination

| Model | Early AUROC (95% CI) | Late AUROC (95% CI) | Late minus early (95% CI) |
| --- | --- | --- | --- |
| Logistic regression | 0.725 (0.583 to 0.835) | 0.645 (0.438 to 0.803) | -0.080 (-0.243 to 0.048) |
| LASSO | 0.718 (0.577 to 0.829) | 0.640 (0.436 to 0.798) | -0.078 (-0.241 to 0.051) |
| Elastic net | 0.732 (0.592 to 0.842) | 0.649 (0.444 to 0.807) | -0.083 (-0.255 to 0.047) |
| Random forest | 0.728 (0.574 to 0.847) | 0.684 (0.447 to 0.853) | -0.044 (-0.232 to 0.112) |
| XGBoost | 0.732 (0.569 to 0.853) | 0.691 (0.456 to 0.857) | -0.042 (-0.227 to 0.109) |
| RBF-SVM | 0.786 (0.655 to 0.887) | 0.723 (0.494 to 0.878) | -0.064 (-0.266 to 0.077) |

Early = 0–90 days; late = &gt;90–365 days after discharge. Both event groups are compared with the same one-year non-event controls. The other event group is not used as controls. These six fixed-model score analyses are not newly fitted early/late models, cumulative 90-day ROC analyses or window-specific calibrated risks.

Original 95% intervals and late-minus-early contrasts use the saved 5,000 patient draws internally and patient-cluster draws externally. Contrasts are paired; an interval spanning zero does not demonstrate equivalence. See Note M3.

Abbreviations: AUROC, area under the receiver operating characteristic (ROC) curve; CI, confidence interval; LASSO, least absolute shrinkage and selection operator; RBF-SVM, radial-basis-function support vector machine; XGBoost, Extreme Gradient Boosting.
