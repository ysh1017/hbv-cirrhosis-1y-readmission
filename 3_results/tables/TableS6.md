# Supplementary Table S6  Predictor representation and Core4 ablation analyses

## A. Internal validation: Logistic regression

| Representation | AUROC | AP | Brier | CITL | Slope |
| --- | --- | --- | --- | --- | --- |
| Original Core4 | 0.762 | 0.716 | 0.193 | -0.063 | 0.796 |
| Raw-only intersection | 0.755 | 0.715 | 0.197 | -0.118 | 0.762 |
| Composite representation | 0.744 | 0.676 | 0.202 | 0.064 | 0.926 |

## A. Internal validation: RBF-SVM

| Representation | AUROC | AP | Brier | CITL | Slope |
| --- | --- | --- | --- | --- | --- |
| Original Core4 | 0.751 | 0.672 | 0.199 | 0.020 | 0.822 |
| Raw-only intersection | 0.763 | 0.724 | 0.191 | -0.064 | 0.873 |
| Composite representation | 0.739 | 0.667 | 0.204 | 0.044 | 0.970 |

## A. External evaluation: Logistic regression

| Representation | AUROC | AP | Brier | CITL | Slope |
| --- | --- | --- | --- | --- | --- |
| Original Core4 | 0.712 | 0.785 | 0.225 | 0.781 | 0.223 |
| Raw-only intersection | 0.665 | 0.744 | 0.249 | 0.825 | 0.124 |
| Composite representation | 0.719 | 0.797 | 0.214 | 0.601 | 0.420 |

## A. External evaluation: RBF-SVM

| Representation | AUROC | AP | Brier | CITL | Slope |
| --- | --- | --- | --- | --- | --- |
| Original Core4 | 0.770 | 0.853 | 0.199 | 0.725 | 0.853 |
| Raw-only intersection | 0.675 | 0.765 | 0.243 | 0.684 | 0.240 |
| Composite representation | 0.733 | 0.834 | 0.209 | 0.582 | 0.755 |

## B. Core4 ablations: internal validation / Logistic regression

| Ablation | Delta AUROC (95% CI) | Delta AP (95% CI) | Brier improvement (95% CI) |
| --- | --- | --- | --- |
| E1: remove INR | 0.030 (-0.007 to 0.067) | 0.063 (0.004 to 0.117) | 0.015 (0.001 to 0.029) |
| E2: remove PLT | -0.006 (-0.043 to 0.029) | -0.002 (-0.037 to 0.034) | 0.001 (-0.012 to 0.013) |
| E3: remove ALBI | 0.011 (-0.015 to 0.037) | -0.001 (-0.035 to 0.034) | 0.005 (-0.004 to 0.014) |
| E4: remove FIB-4 | -0.011 (-0.025 to 0.002) | -0.016 (-0.046 to 0.009) | -0.002 (-0.008 to 0.003) |
| E5: INR + ALBI only | -0.024 (-0.078 to 0.025) | -0.029 (-0.080 to 0.019) | -0.008 (-0.027 to 0.010) |
| E6: PLT + FIB-4 only | 0.095 (0.037 to 0.158) | 0.149 (0.058 to 0.224) | 0.034 (0.013 to 0.054) |

## B. Core4 ablations: internal validation / RBF-SVM

| Ablation | Delta AUROC (95% CI) | Delta AP (95% CI) | Brier improvement (95% CI) |
| --- | --- | --- | --- |
| E1: remove INR | 0.037 (-0.004 to 0.078) | 0.056 (-0.011 to 0.118) | 0.016 (-0.002 to 0.033) |
| E2: remove PLT | -0.003 (-0.025 to 0.017) | -0.023 (-0.075 to 0.028) | -0.002 (-0.010 to 0.007) |
| E3: remove ALBI | 0.010 (-0.022 to 0.043) | -0.026 (-0.079 to 0.028) | 0.004 (-0.008 to 0.017) |
| E4: remove FIB-4 | -0.024 (-0.053 to 0.005) | -0.043 (-0.110 to 0.020) | -0.010 (-0.024 to 0.003) |
| E5: INR + ALBI only | -0.036 (-0.082 to 0.008) | -0.072 (-0.139 to -0.005) | -0.012 (-0.031 to 0.006) |
| E6: PLT + FIB-4 only | 0.090 (0.026 to 0.155) | 0.114 (0.022 to 0.196) | 0.032 (0.008 to 0.056) |

## B. Core4 ablations: external evaluation / Logistic regression

| Ablation | Delta AUROC (95% CI) | Delta AP (95% CI) | Brier improvement (95% CI) |
| --- | --- | --- | --- |
| E1: remove INR | -0.049 (-0.133 to 0.030) | -0.084 (-0.172 to 0.008) | 0.002 (-0.041 to 0.040) |
| E2: remove PLT | 0.005 (-0.042 to 0.055) | 0.013 (-0.026 to 0.058) | -0.007 (-0.028 to 0.014) |
| E3: remove ALBI | 0.032 (0.006 to 0.065) | 0.033 (0.004 to 0.070) | 0.012 (-0.001 to 0.028) |
| E4: remove FIB-4 | 0.008 (-0.010 to 0.029) | 0.010 (-0.011 to 0.035) | 0.009 (-0.001 to 0.017) |
| E5: INR + ALBI only | 0.056 (-0.021 to 0.138) | 0.058 (-0.012 to 0.126) | 0.018 (-0.018 to 0.053) |
| E6: PLT + FIB-4 only | -0.001 (-0.105 to 0.100) | -0.053 (-0.145 to 0.055) | 0.013 (-0.034 to 0.055) |

## B. Core4 ablations: external evaluation / RBF-SVM

| Ablation | Delta AUROC (95% CI) | Delta AP (95% CI) | Brier improvement (95% CI) |
| --- | --- | --- | --- |
| E1: remove INR | -0.004 (-0.059 to 0.055) | -0.022 (-0.054 to 0.032) | -0.003 (-0.028 to 0.022) |
| E2: remove PLT | 0.025 (-0.035 to 0.099) | 0.016 (-0.045 to 0.123) | 0.003 (-0.019 to 0.031) |
| E3: remove ALBI | 0.072 (-0.007 to 0.166) | 0.083 (-0.018 to 0.189) | 0.016 (-0.017 to 0.061) |
| E4: remove FIB-4 | 0.016 (-0.028 to 0.061) | 0.006 (-0.034 to 0.055) | 0.010 (-0.009 to 0.027) |
| E5: INR + ALBI only | 0.107 (0.009 to 0.221) | 0.105 (-0.010 to 0.218) | 0.038 (-0.001 to 0.079) |
| E6: PLT + FIB-4 only | 0.034 (-0.039 to 0.125) | -0.003 (-0.041 to 0.082) | 0.009 (-0.022 to 0.044) |

Panel A shows point estimates; no new intervals are introduced. Internal validation contains 133 patients; external evaluation contains 102 episodes from 50 patients. Core4 = INR/PLT/ALBI/FIB-4; raw-only intersection = INR/PLT; composite intersection = PTAR/FIB-4. Candidate-pool rules are in Note M3.

Panel B retains all six ablations. ΔAUROC and ΔAP = FULL minus ablation; Brier improvement = ablation minus FULL. Positive values favor FULL. Original paired 95% percentile intervals use 5,000 patient draws internally and patient-cluster draws externally. Intervals spanning zero do not establish equivalence or absence of contribution. See Note M3.

Abbreviations: AUROC, area under the receiver operating characteristic curve; AP, average precision; CITL, calibration-in-the-large; CI, confidence interval; RBF-SVM, radial-basis-function support vector machine; PTAR, study-defined 10 × INR/albumin (albumin in g/L); INR, international normalized ratio; PLT, platelet count; ALBI, albumin-bilirubin score; FIB-4, fibrosis-4 index.
