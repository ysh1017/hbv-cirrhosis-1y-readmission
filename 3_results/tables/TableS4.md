# Supplementary Table S4  Configuration of the seven candidate models

## A Fixed final model parameters and preprocessing

| Model | Fixed final parameters | Preprocessing | Development search |
| --- | --- | --- | --- |
| Logistic regression | link = logit; use_pred_offset = true | Not explicit in learner parameter set | No parameter search |
| LASSO | alpha = 1; lambda = 0.0232294425776311; standardize = true; use_pred_offset = true | Standardize = true (glmnet) | 10-fold CV × 5 repeats; 30 MBO evaluations; optimize AUROC |
| Elastic net | alpha = 0.0842256563195503; lambda = 0.0893884745834839; standardize = true; use_pred_offset = true | Standardize = true (glmnet) | 10-fold CV × 5 repeats; 30 MBO evaluations; optimize AUROC |
| Random forest | importance = none; min.node.size = 29; mtry.ratio = 0.2; num.threads = 1; num.trees = 1000; sample.fraction = 0.652165659546858 | Not explicit in learner parameter set | 10-fold CV × 5 repeats; 30 MBO evaluations; optimize AUROC |
| XGBoost | alpha = 0; colsample_bytree = 1; eta = 0.0184324067769678; gamma = 0; lambda = 0.655478463773341; max_depth = 1; min_child_weight = 4.42216015579396; nrounds = 200; nthread = 1; subsample = 0.661144082310602; verbose = 0; verbosity = 0; use_pred_offset = true | Not explicit in learner parameter set | 10-fold CV × 5 repeats; 30 MBO evaluations; optimize AUROC |
| RBF-SVM | cost = 0.274080705074942; gamma = 0.0573174496538081; kernel = radial; scale = true; type = C-classification | Scale = true | 10-fold CV × 5 repeats; 30 MBO evaluations; optimize AUROC |
| LightGBM | num_leaves = 3; max_depth = 2; learning_rate = 0.014700166690139731; min_data_in_leaf = 50; feature_fraction = 0.75304694004165273; bagging_fraction = 0.70025569698636059; lambda_l2 = 19.999999999999996; nrounds = 169 | Identity on raw-scale Core4 values | 10-fold CV × 5 repeats (50 inner resamples); 30 MBO evaluations; optimize AUROC |

All fixed models used the original 312-patient development set with ALBI, FIB-4, INR and PLT in the saved learner order. The saved positive class for the six original models is Yes. Tuning used development data only, without validation- or external-dependent retuning. Glmnet standardization and SVM scaling are saved training transformations; unspecified preprocessing is retained as unspecified.

The fixed final parameter values describe the original development fits. Complete nested evaluation repeated selection, tuning and fitting within each outer-training split; these values were not imposed on every nested fit.

## B LightGBM search ranges

| Parameter | Search range | Fixed selected value |
| --- | --- | --- |
| num_leaves | 2 to 15 (integer) | 3 |
| max_depth | 2 to 5 (integer) | 2 |
| learning_rate | 0.01 to 0.15 (log scale) | 0.014700166690139731 |
| min_data_in_leaf | 10 to 50 (integer) | 50 |
| feature_fraction | 0.7 to 1.0 | 0.75304694004165273 |
| bagging_fraction | 0.7 to 0.95 | 0.70025569698636059 |
| lambda_l2 | 0.5 to 20 (log scale) | 19.999999999999996 |
| nrounds | 50 to 400 (integer) | 169 |

## C LightGBM implementation and random settings

| Setting | Configuration |
| --- | --- |
| Implementation | LightGBM 4.7.0; binary objective; gradient-boosted decision trees; AUROC tuning metric |
| Inner evaluation | 10-fold cross-validation repeated 5 times (50 inner resamples); 30 MBO parameter evaluations |
| Execution | CPU; num_threads = 1; deterministic = true; force_col_wise = true; force_row_wise = false |
| Other fixed settings | bagging_freq = 1; feature_pre_filter = false; lambda_l1 = 0; min_gain_to_split = 0; extra_trees = false |
| Fixed tuning and final-fit seeds | Tuning: 700123; final fit: 1400123 |
| Native random seeds | seed: 800123; data: 900123; feature fraction: 1000123; bagging: 1100123; drop: 1200123; extra: 1300123 |

Statistical analyses primarily used R 4.5.1 and Python 3.12.14. CV, cross-validation; MBO, model-based optimization. AUROC, area under the receiver operating characteristic curve; LASSO, least absolute shrinkage and selection operator; RBF-SVM, radial-basis-function support vector machine; XGBoost, Extreme Gradient Boosting; LightGBM, Light Gradient Boosting Machine; INR, international normalized ratio; PLT, platelet count; ALBI, albumin-bilirubin score; FIB-4, fibrosis-4 index. Core4 comprises INR, PLT, ALBI and FIB-4. SVM denotes RBF-SVM.
