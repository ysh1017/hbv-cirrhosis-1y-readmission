# Supplementary Table S3  Predictor definitions, availability and selection

## A Predictor definitions and availability profiles

| Variable | Unit/scale | Role | Definition/coding | Profile |
| --- | --- | --- | --- | --- |
| Metabolic comorbidities | Category | Candidate | Obesity OR hypertension OR diabetes mellitus | A |
| EGVH | Category | Candidate | Stored definition | A |
| Ascites | Category | Candidate | Stored definition | A |
| SBP | Category | Candidate | Stored definition | A |
| HE | Category | Description only | Stored definition | A |
| HRS | Category | Candidate | Stored definition | A |
| Infection | Category | Candidate | Stored definition | A |
| HBeAg/anti-HBe status | Category | Candidate | Stored definition | A |
| Sex | Category | Candidate | Stored definition | A |
| Prior antiviral therapy | Category | Candidate | Stored definition | A |
| Smoking history | Category | Candidate | Stored definition | A |
| Alcohol use history | Category | Candidate | Stored definition | A |
| Serum creatinine (μmol/L) | μmol/L | Candidate | Stored definition | A |
| Total bilirubin (μmol/L) | μmol/L | Candidate | Stored definition | A |
| ALT (U/L) | U/L | Candidate | Stored definition | A |
| AST (U/L) | U/L | Candidate | Stored definition | A |
| GGT (U/L) | U/L | Candidate | Stored definition | A |
| LDH (U/L) | U/L | Candidate | Stored definition | A |
| ALP (U/L) | U/L | Candidate | Stored definition | A |
| Albumin (g/L) | g/L | Candidate | Stored definition | A |
| PTA (%) | % | Description only | Stored definition | A |
| PT (s) | s | Description only | Stored definition | A |
| Hemoglobin (g/L) | g/L | Candidate | Stored definition | A |
| NEU (10^9/L) | 10^9/L | Candidate | Stored definition | B |
| LYM (10^9/L) | 10^9/L | Candidate | Stored definition | B |
| MON (10^9/L) | 10^9/L | Candidate | Stored definition | B |
| Platelet count (10^9/L) | 10^9/L | Candidate; Core4 | Stored definition | A |
| WBC (10^9/L) | 10^9/L | Candidate | Stored definition | A |
| Potassium (mmol/L) | mmol/L | Candidate | Stored definition | A |
| Sodium (mmol/L) | mmol/L | Candidate | Stored definition | A |
| Chloride (mmol/L) | mmol/L | Candidate | Stored definition | A |
| INR | ratio | Candidate; Core4 | Stored definition | A |
| HBsAg, log10 (IU/mL) | log10 (IU/mL) | Candidate | Viral-marker coding below | A |
| HBV DNA study category (IU/mL) | IU/mL cutpoints | Candidate | 0: &lt;2,000; 1: 2,000-&lt;20,000; 2: ≥20,000 IU/mL | C |
| HBV DNA, log10 (IU/mL) | log10 (IU/mL) | Candidate | Viral-marker coding below | D |
| Age (years) | years | Candidate | Stored definition | A |
| MELD-Na | score | Description only | Formula below | A |
| ALBI | score | Candidate; Core4 | Formula below | A |
| PMR | Formula-defined index/ratio | Candidate | Formula below | B |
| PTAR | Formula-defined index/ratio | Candidate | Formula below | A |
| NAR | Formula-defined index/ratio | Candidate | Formula below | B |
| NLR | Formula-defined index/ratio | Candidate | Formula below | B |
| FIB-4 | score | Candidate; Core4 | Formula below | A |
| LMR | Formula-defined index/ratio | Candidate | Formula below | B |
| PLR | Formula-defined index/ratio | Candidate | Formula below | B |
| SIRI | Formula-defined index/ratio | Candidate | Formula below | B |
| PNI | Formula-defined index/ratio | Candidate | Formula below | B |
| APRI | Formula-defined index/ratio | Candidate | Formula below | A |
| Length of index hospital stay (days) | days | Candidate | Stored definition | A |
| Body mass index | kg/m² | Candidate | Stored definition | A |

All 50 recorded characteristics are shown; 46 were screening candidates. HE, PT, PTA and MELD-Na were descriptive rather than screening candidates. Core4 consists of INR, PLT, ALBI and FIB-4. All non-viral continuous fields retain their recorded numeric scale without an added transformation. Category meanings are retained rather than re-diagnosed. Measurement-time anchors and treatment timing are not assumed uniform.

## A Pre-imputation availability by cohort

| Profile | Overall N = 445 | Development N = 312 | Internal N = 133 |
| --- | --- | --- | --- |
| A | 445 / 0 | 312 / 0 | 133 / 0 |
| B | 438 / 7 | 306 / 6 | 132 / 1 |
| C | 442 / 3 | 309 / 3 | 133 / 0 |
| D | 437 / 8 | 304 / 8 | 133 / 0 |

Each cell is available n / missing n. The profile assigned to each variable above retains every original count. Numerical encodings of left-censored values are not counted as missing; missing percentages were not calculated.

## A Pre-imputation availability by outcome group

| Profile | Development no readmission N = 182 | Development readmission N = 130 | Internal no readmission N = 78 | Internal readmission N = 55 |
| --- | --- | --- | --- | --- |
| A | 182 / 0 | 130 / 0 | 78 / 0 | 55 / 0 |
| B | 178 / 4 | 128 / 2 | 77 / 1 | 55 / 0 |
| C | 182 / 0 | 127 / 3 | 78 / 0 | 55 / 0 |
| D | 178 / 4 | 126 / 4 | 78 / 0 | 55 / 0 |

Each cell is available n / missing n. The data state is pre-imputation. Saved modeling imputations are a separate data state.

## A Metabolic-comorbidity components

| Component | Unit/scale | Definition |
| --- | --- | --- |
| Obesity | Binary (0/1) | Derived from BMI ≥28 kg/m². |
| Hypertension | Binary (0/1) | Existing historical structured diagnosis flag retained. |
| Diabetes mellitus | Binary (0/1) | Existing historical structured diagnosis flag retained. |

These components describe the composite metabolic-comorbidity candidate and were not entered separately into feature selection.

## A Derived predictor definitions

| Predictor | Formula |
| --- | --- |
| MELD-Na | Scr_mg_dl = min(4, max(1, Scr/88.4)); TBIL_mg_dl = max(1, TBIL/17.1); M = 3.78 × ln(TBIL_mg_dl) + 11.2 × ln(max(1, INR)) + 9.57 × ln(Scr_mg_dl) + 6.43; Na = min(137, max(125, Sodium)); round(M + 1.32 × (137-Na) - 0.033 × M × (137-Na), 2). |
| ALBI | round(0.66 × log10(TBIL) - 0.085 × Albumin, 2) |
| PMR | PLT/MON (MON &gt; 0); no rounding |
| PTAR | 10 × INR/Albumin (Albumin &gt; 0); no rounding |
| NAR | 10 × NEU/Albumin (Albumin &gt; 0); no rounding |
| NLR | round(NEU/LYM, 2) |
| FIB-4 | round(Age × AST / (PLT × sqrt(ALT)), 2) |
| LMR | round(LYM/MON, 2) |
| PLR | round(PLT/LYM, 2) |
| SIRI | round(NEU × MON/LYM, 2) |
| PNI | round(Albumin + 5 × LYM, 2) |
| APRI | round((AST/40) × 100/PLT, 2) |

Albumin is in g/L; bilirubin and creatinine are in μmol/L; cell counts are in 10^9/L. The project definition PTAR = 10 × INR/Albumin is retained.

## A Additional descriptions Overall

| Variable | Overall (N = 445) |
| --- | --- |
| LDH (U/L) | 388.00 (288.00, 520.00) |
| NEU (10^9/L) | 2.68 (1.75, 4.74); n=438 |
| LYM (10^9/L) | 0.69 (0.47, 1.02); n=438 |
| MON (10^9/L) | 0.31 (0.20, 0.46); n=438 |
| Potassium (mmol/L) | 3.80 (3.50, 4.20) |
| Chloride (mmol/L) | 107.00 (104.00, 109.00) |
| PMR | 221.72 (143.92, 322.14); n=438 |
| PTAR | 0.45 (0.38, 0.57) |
| NAR | 0.93 (0.57, 1.69); n=438 |
| NLR | 3.69 (2.50, 6.75); n=438 |
| LMR | 2.40 (1.67, 3.42); n=438 |
| PLR | 92.52 (63.41, 143.15); n=438 |
| SIRI | 1.08 (0.56, 2.64); n=438 |
| PNI | 34.02 (29.81, 37.85); n=438 |
| APRI | 1.73 (1.01, 3.27) |

Median (Q1, Q3), with available n where different from the group total. Outcome-group P values are exploratory, unadjusted and were not used for feature selection.

## A Additional descriptions Development

| Variable | No readmission (N = 182) | Readmission (N = 130) | P value |
| --- | --- | --- | --- |
| LDH (U/L) | 381.00 (292.00, 519.75) | 401.50 (296.00, 545.25) | 0.460 |
| NEU (10^9/L) | 3.08 (1.84, 5.39); n=178 | 2.32 (1.50, 3.61); n=128 | 0.001 |
| LYM (10^9/L) | 0.76 (0.50, 1.15); n=178 | 0.65 (0.47, 0.95); n=128 | 0.026 |
| MON (10^9/L) | 0.32 (0.21, 0.48); n=178 | 0.27 (0.19, 0.44); n=128 | 0.071 |
| Potassium (mmol/L) | 3.90 (3.52, 4.20) | 3.80 (3.50, 4.10) | 0.222 |
| Chloride (mmol/L) | 106.00 (104.00, 109.00) | 108.00 (104.00, 110.75) | 0.015 |
| PMR | 254.06 (169.15, 393.45); n=178 | 180.70 (131.34, 278.33); n=128 | &lt;0.001 |
| PTAR | 0.42 (0.36, 0.49) | 0.52 (0.44, 0.62) | &lt;0.001 |
| NAR | 1.01 (0.60, 1.84); n=178 | 0.83 (0.53, 1.39); n=128 | 0.040 |
| NLR | 3.54 (2.50, 6.67); n=178 | 3.56 (2.38, 6.18); n=128 | 0.551 |
| LMR | 2.44 (1.77, 3.50); n=178 | 2.38 (1.73, 3.44); n=128 | 0.696 |
| PLR | 102.17 (65.17, 156.44); n=178 | 75.50 (54.46, 115.70); n=128 | &lt;0.001 |
| SIRI | 1.19 (0.57, 2.76); n=178 | 0.94 (0.49, 2.00); n=128 | 0.075 |
| PNI | 35.35 (31.52, 39.62); n=178 | 31.88 (28.84, 35.76); n=128 | &lt;0.001 |
| APRI | 1.39 (0.78, 2.27) | 2.69 (1.56, 4.74) | &lt;0.001 |

Median (Q1, Q3), with available n where different from the group total. Outcome-group P values are exploratory, unadjusted and were not used for feature selection.

## A Additional descriptions Internal validation

| Variable | No readmission (N = 78) | Readmission (N = 55) | P value |
| --- | --- | --- | --- |
| LDH (U/L) | 391.50 (282.00, 550.50) | 384.00 (267.00, 499.00) | 0.502 |
| NEU (10^9/L) | 2.53 (1.79, 4.72); n=77 | 3.03 (1.93, 4.58) | 0.663 |
| LYM (10^9/L) | 0.71 (0.46, 1.00); n=77 | 0.57 (0.46, 0.93) | 0.227 |
| MON (10^9/L) | 0.33 (0.22, 0.47); n=77 | 0.31 (0.17, 0.44) | 0.569 |
| Potassium (mmol/L) | 3.90 (3.52, 4.30) | 3.80 (3.60, 4.20) | 0.460 |
| Chloride (mmol/L) | 105.00 (103.00, 108.00) | 107.00 (105.00, 109.50) | 0.045 |
| PMR | 233.33 (168.42, 308.33); n=77 | 178.12 (114.95, 287.14) | 0.032 |
| PTAR | 0.42 (0.37, 0.48) | 0.55 (0.44, 0.69) | &lt;0.001 |
| NAR | 0.90 (0.56, 1.39); n=77 | 1.08 (0.70, 1.85) | 0.129 |
| NLR | 3.71 (2.52, 7.11); n=77 | 4.70 (2.83, 7.74) | 0.295 |
| LMR | 2.33 (1.67, 3.33); n=77 | 2.25 (1.25, 3.40) | 0.600 |
| PLR | 107.04 (71.05, 153.13); n=77 | 78.43 (61.36, 119.92) | 0.021 |
| SIRI | 1.03 (0.65, 2.36); n=77 | 1.08 (0.67, 2.94) | 0.631 |
| PNI | 34.95 (30.90, 39.65); n=77 | 31.75 (28.30, 35.55) | 0.003 |
| APRI | 1.38 (0.86, 2.66) | 2.21 (1.42, 3.60) | 0.006 |

Median (Q1, Q3), with available n where different from the group total. Outcome-group P values are exploratory, unadjusted and were not used for feature selection.

## A HBV DNA measurement status

| Status | Overall n | Retained handling |
| --- | --- | --- |
| Quantified result | 205 | Stored continuous value and category retained |
| Left-censored with a recorded bound | 232 | Existing half-bound coding before log10 transformation retained |
| Not detected; numerical bound unavailable | 5 | Continuous value missing; original lowest-category assignment retained |
| No HBV DNA result | 3 | Continuous and categorical fields unavailable |

The 445 records describe measurement/encoding states rather than mutually comparable measured concentrations. Recorded bounds were 20, 50, 100 and 1,000 IU/mL.

## A Viral-marker coding and limitations

| Field | Scale/definition | Interpretation limit |
| --- | --- | --- |
| HBV DNA | log10 (IU/mL); categories &lt;2,000, 2,000-&lt;20,000 and ≥20,000 IU/mL | Continuous and categorical availability differ. Medians and rank-based tests do not remove uncertainty from censoring or substitution. |
| HBsAg | Stored log10 (IU/mL); available 445/445 | The historical 0.05-IU/mL convention and zero-to-0.025 coding are not verified assay-wide detection limits; no new substitution was applied. |

Pre-imputation HBV DNA descriptions retain the stored raw categories; completed modeling groups use completed log10 HBV DNA.

## B Fixed-development selection status

| Predictor | LASSO λmin | LASSO λ1se | Original Boruta | After RoughFix | Core4 |
| --- | --- | --- | --- | --- | --- |
| Metabolic comorbidities | False | False | Rejected | False | False |
| EGVH | False | False | Rejected | False | False |
| Ascites | True | False | Rejected | False | False |
| SBP | True | False | Rejected | False | False |
| HRS | False | False | Rejected | False | False |
| Infection | True | False | Rejected | False | False |
| HBeAg status | True | False | Rejected | False | False |
| Sex | False | False | Rejected | False | False |
| Prior antiviral therapy | False | False | Rejected | False | False |
| Smoking history | True | False | Rejected | False | False |
| Alcohol use history | True | False | Rejected | False | False |
| Scr | False | False | Rejected | False | False |
| TBIL | False | False | Confirmed | True | False |
| ALT | False | False | Rejected | False | False |
| AST | False | False | Rejected | False | False |
| GGT | False | False | Rejected | False | False |
| LDH | False | False | Rejected | False | False |
| ALP | False | False | Rejected | False | False |
| Albumin | False | False | Tentative | True | False |
| Hb | False | False | Rejected | False | False |
| NEU | False | False | Rejected | False | False |
| LYM | False | False | Rejected | False | False |
| MON | False | False | Rejected | False | False |
| PLT | True | True | Confirmed | True | True |
| WBC | False | False | Rejected | False | False |
| Potassium | False | False | Rejected | False | False |
| Sodium | False | False | Rejected | False | False |
| Chloride | False | False | Confirmed | True | False |
| INR | True | True | Confirmed | True | True |
| HBsAg | False | False | Rejected | False | False |
| HBV DNA (3 groups) | True | True | Rejected | False | False |
| HBV DNA (numeric) | False | False | Rejected | False | False |
| Age | True | False | Rejected | False | False |
| ALBI | True | True | Confirmed | True | True |
| PMR | False | False | Confirmed | True | False |
| PTAR | False | False | Confirmed | True | False |
| NAR | False | False | Rejected | False | False |
| NLR | False | False | Rejected | False | False |
| FIB-4 | True | True | Confirmed | True | True |
| LMR | False | False | Rejected | False | False |
| PLR | False | False | Rejected | False | False |
| SIRI | False | False | Rejected | False | False |
| PNI | False | False | Rejected | False | False |
| APRI | False | False | Confirmed | True | False |
| Length of stay | False | False | Rejected | False | False |
| BMI | False | False | Rejected | False | False |

Both methods received all 46 candidate source variables from the 312-patient development cohort; univariable P values did not filter inputs. Statuses refer to source variables, not separate design-matrix terms. Original Boruta: 9 confirmed, 1 tentative and 36 rejected. Albumin was tentative and retained after RoughFix. LASSO λ1se retained 5 variables; Boruta retained 10; their intersection was Core4.

## B Full nested-selection frequencies

| Predictor | Original Core4 | Nested LASSO n (%) | Nested Boruta n (%) | Nested intersection n (%) |
| --- | --- | --- | --- | --- |
| Metabolic comorbidities | No | 6 (6%) | 0 (0%) | 0 (0%) |
| EGVH | No | 9 (9%) | 0 (0%) | 0 (0%) |
| Ascites | No | 20 (20%) | 0 (0%) | 0 (0%) |
| SBP | No | 13 (13%) | 0 (0%) | 0 (0%) |
| HRS | No | 0 (0%) | 0 (0%) | 0 (0%) |
| Infection | No | 10 (10%) | 0 (0%) | 0 (0%) |
| HBeAg status | No | 10 (10%) | 0 (0%) | 0 (0%) |
| Sex | No | 11 (11%) | 0 (0%) | 0 (0%) |
| Prior antiviral therapy | No | 4 (4%) | 0 (0%) | 0 (0%) |
| Smoking history | No | 8 (8%) | 0 (0%) | 0 (0%) |
| Alcohol use history | No | 26 (26%) | 0 (0%) | 0 (0%) |
| Scr | No | 0 (0%) | 16 (16%) | 0 (0%) |
| TBIL | No | 0 (0%) | 99 (99%) | 0 (0%) |
| ALT | No | 0 (0%) | 6 (6%) | 0 (0%) |
| AST | No | 0 (0%) | 0 (0%) | 0 (0%) |
| GGT | No | 0 (0%) | 19 (19%) | 0 (0%) |
| LDH | No | 1 (1%) | 3 (3%) | 0 (0%) |
| ALP | No | 0 (0%) | 10 (10%) | 0 (0%) |
| Albumin | No | 0 (0%) | 50 (50%) | 0 (0%) |
| Hb | No | 0 (0%) | 0 (0%) | 0 (0%) |
| NEU | No | 0 (0%) | 2 (2%) | 0 (0%) |
| LYM | No | 0 (0%) | 10 (10%) | 0 (0%) |
| MON | No | 0 (0%) | 6 (6%) | 0 (0%) |
| PLT | Yes | 67 (67%) | 100 (100%) | 67 (67%) |
| WBC | No | 0 (0%) | 0 (0%) | 0 (0%) |
| Potassium | No | 0 (0%) | 1 (1%) | 0 (0%) |
| Sodium | No | 0 (0%) | 7 (7%) | 0 (0%) |
| Chloride | No | 1 (1%) | 56 (56%) | 1 (1%) |
| INR | Yes | 100 (100%) | 100 (100%) | 100 (100%) |
| HBsAg | No | 0 (0%) | 3 (3%) | 0 (0%) |
| HBV DNA (categorical) | No | 98 (98%) | 2 (2%) | 2 (2%) |
| log10 HBV DNA | No | 0 (0%) | 8 (8%) | 0 (0%) |
| Age | No | 0 (0%) | 1 (1%) | 0 (0%) |
| ALBI | Yes | 85 (85%) | 97 (97%) | 85 (85%) |
| PMR | No | 0 (0%) | 70 (70%) | 0 (0%) |
| PTAR | No | 5 (5%) | 100 (100%) | 5 (5%) |
| NAR | No | 0 (0%) | 0 (0%) | 0 (0%) |
| NLR | No | 0 (0%) | 0 (0%) | 0 (0%) |
| FIB-4 | Yes | 46 (46%) | 100 (100%) | 46 (46%) |
| LMR | No | 0 (0%) | 0 (0%) | 0 (0%) |
| PLR | No | 0 (0%) | 63 (63%) | 0 (0%) |
| SIRI | No | 0 (0%) | 2 (2%) | 0 (0%) |
| PNI | No | 0 (0%) | 42 (42%) | 0 (0%) |
| APRI | No | 1 (1%) | 100 (100%) | 1 (1%) |
| Length of stay | No | 1 (1%) | 0 (0%) | 0 (0%) |
| BMI | No | 0 (0%) | 0 (0%) | 0 (0%) |

All 100 outer-training selections completed. Frequencies use all 100 selections, irrespective of downstream fitting failures. Each outcome-stratified 70:30 partition used 312 outer-training and 133 outer-test patients from the 445-patient domestic cohort. Selection used LASSO λ1se and Boruta after TentativeRoughFix. Original Core4 membership was a reference label and did not constrain nested selection.

## C Post-selection Spearman correlations (development n = 312)

| Predictor | INR | PLT | ALBI | FIB-4 |
| --- | --- | --- | --- | --- |
| INR | 1.000 | -0.351 | 0.518 | 0.434 |
| PLT | -0.351 | 1.000 | -0.143 | -0.744 |
| ALBI | 0.518 | -0.143 | 1.000 | 0.343 |
| FIB-4 | 0.434 | -0.744 | 0.343 | 1.000 |

## C Post-selection linear-redundancy diagnostics (development n = 312)

| Predictor | VIF | Tolerance |
| --- | --- | --- |
| INR | 1.490 | 0.671 |
| Platelet count | 1.295 | 0.772 |
| ALBI | 1.407 | 0.711 |
| FIB-4 | 1.343 | 0.744 |

VIF = 1/(1-R²), with each Core4 predictor regressed on the other three; tolerance = 1/VIF. These post-selection assessments did not determine predictor selection. They describe correlation and residual linear redundancy, not biological independence.

## C Joint Core4 retention and similarity

| Summary | Value | Definition |
| --- | --- | --- |
| All four Core4 predictors retained | 35/100 (35%) | All four retained, allowing other predictors |
| Exact Core4 recovery | 33/100 (33%) | Selected intersection exactly Core4 |
| Jaccard similarity to original Core4 | 0.75 (0.50, 1.00) | Median (Q1, Q3); intersection size divided by union size |

Frequencies and quartiles describe repeated-partition behavior; they are not independent-sample confidence intervals or causal-importance estimates.

Abbreviations: EGVH, esophagogastric variceal hemorrhage; SBP, spontaneous bacterial peritonitis; HE, hepatic encephalopathy; HRS, hepatorenal syndrome; INR, international normalized ratio; PLT, platelet count; TBIL, total bilirubin; ALT, alanine aminotransferase; AST, aspartate aminotransferase; ALP, alkaline phosphatase; GGT, gamma-glutamyl transferase; LDH, lactate dehydrogenase; PT, prothrombin time; PTA, prothrombin activity; WBC, white blood cell count; Hb, hemoglobin; Scr, serum creatinine; NEU, neutrophil count; LYM, lymphocyte count; MON, monocyte count; ALBI, albumin-bilirubin score; FIB-4, fibrosis-4 index; MELD-Na, Model for End-Stage Liver Disease-sodium; PMR, platelet-to-monocyte ratio; PTAR, study-defined 10 × INR/albumin; NAR, neutrophil-to-albumin ratio, calculated as 10 × NEU/albumin; NLR, neutrophil-to-lymphocyte ratio; LMR, lymphocyte-to-monocyte ratio; PLR, platelet-to-lymphocyte ratio; SIRI, systemic inflammation response index; PNI, prognostic nutritional index; APRI, aspartate aminotransferase-to-platelet ratio index; LASSO, least absolute shrinkage and selection operator; VIF, variance inflation factor. HBV, hepatitis B virus; DNA, deoxyribonucleic acid; HBeAg, hepatitis B e antigen; anti-HBe, antibody to hepatitis B e antigen; HBsAg, hepatitis B surface antigen; Q1/Q3, first/third quartiles.
