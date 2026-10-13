# Table 2. Predictive performance of the seven candidate models in internal and external evaluation.

## A. Internal validation (133 patients; 55 events)

| Model | AUROC(95% CI) | Average precision(95% CI) | Brier score(95% CI) | CITL(95% CI) | Calibration slope(95% CI) |
| --- | --- | --- | --- | --- | --- |
| Logistic regression | 0.762(0.672–0.842) | 0.716(0.589–0.823) | 0.193(0.160–0.231) | -0.063(-0.493–0.355) | 0.796(0.480–1.268) |
| LASSO | 0.766(0.676–0.843) | 0.721(0.597–0.825) | 0.192(0.164–0.224) | -0.047(-0.443–0.329) | 1.054(0.652–1.642) |
| Elastic net | 0.763(0.674–0.841) | 0.716(0.593–0.819) | 0.193(0.167–0.223) | -0.027(-0.411–0.334) | 1.226(0.770–1.877) |
| Random forest | 0.762(0.672–0.842) | 0.671(0.540–0.802) | 0.192(0.159–0.230) | -0.092(-0.520–0.313) | 0.867(0.517–1.349) |
| XGBoost | 0.747(0.656–0.829) | 0.685(0.553–0.805) | 0.199(0.165–0.236) | -0.049(-0.470–0.356) | 0.859(0.509–1.307) |
| RBF-SVM | 0.751(0.660–0.832) | 0.672(0.539–0.792) | 0.199(0.164–0.238) | 0.020(-0.419–0.430) | 0.822(0.484–1.252) |
| LightGBM | 0.747(0.655–0.830) | 0.665(0.527–0.796) | 0.201(0.177–0.227) | -0.050(-0.422–0.290) | 1.425(0.856–2.134) |

Higher AUROC and AP and lower Brier scores indicate better predictive performance. Ideal values are 0 for CITL and 1 for the calibration slope. Values are point estimates with 95% CIs. Internal validation includes 133 patients; external evaluation includes 102 hospitalization episodes from 50 patients. External confidence intervals accounted for repeated episodes within patients. AUROC, area under the receiver operating characteristic curve; AP, average precision; CITL, calibration-in-the-large. CI, confidence interval; LASSO, least absolute shrinkage and selection operator; RBF-SVM, radial-basis-function support vector machine; XGBoost, Extreme Gradient Boosting; LightGBM, Light Gradient Boosting Machine.

# Table 2. Predictive performance of the seven candidate models in internal and external evaluation.

## B. External evaluation (102 admission-oriented episodes from 50 patients; 67 events)

| Model | AUROC(95% CI) | Average precision(95% CI) | Brier score(95% CI) | CITL(95% CI) | Calibration slope(95% CI) |
| --- | --- | --- | --- | --- | --- |
| Logistic regression | 0.712 (0.571–0.823) | 0.785 (0.602–0.915) | 0.225 (0.164–0.300) | 0.781 (0.085–1.458) | 0.223 (-0.038–0.774) |
| LASSO | 0.705 (0.566–0.817) | 0.776 (0.594–0.908) | 0.225 (0.170–0.294) | 0.717 (0.079–1.299) | 0.255 (-0.064–0.962) |
| Elastic net | 0.717 (0.577–0.828) | 0.788 (0.607–0.916) | 0.221 (0.170–0.285) | 0.702 (0.101–1.239) | 0.367 (-0.059–1.222) |
| Random forest | 0.719 (0.567–0.838) | 0.834 (0.639–0.934) | 0.215 (0.160–0.282) | 0.682 (0.101–1.266) | 0.614 (0.198–1.142) |
| XGBoost | 0.728 (0.569–0.846) | 0.849 (0.646–0.941) | 0.215 (0.162–0.278) | 0.650 (0.085–1.215) | 0.655 (0.208–1.210) |
| RBF-SVM | 0.770 (0.640–0.871) | 0.853 (0.707–0.945) | 0.199 (0.147–0.259) | 0.725 (0.159–1.272) | 0.853 (0.415–1.491) |
| LightGBM | 0.694 (0.537–0.820) | 0.799 (0.592–0.920) | 0.225 (0.191–0.267) | 0.681 (0.146–1.169) | 0.966 (0.227–1.825) |

Higher AUROC and AP and lower Brier scores indicate better predictive performance. Ideal values are 0 for CITL and 1 for the calibration slope. Values are point estimates with 95% CIs. Internal validation includes 133 patients; external evaluation includes 102 hospitalization episodes from 50 patients. External confidence intervals accounted for repeated episodes within patients. AUROC, area under the receiver operating characteristic curve; AP, average precision; CITL, calibration-in-the-large. CI, confidence interval; LASSO, least absolute shrinkage and selection operator; RBF-SVM, radial-basis-function support vector machine; XGBoost, Extreme Gradient Boosting; LightGBM, Light Gradient Boosting Machine.
