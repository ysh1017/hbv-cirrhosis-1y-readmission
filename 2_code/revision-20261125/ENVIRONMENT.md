# Verified software environment

The portable demonstrations were executed in an isolated copy using R 4.5.1 (Windows UCRT x86_64) and Python 3.12.14. Observed test dependencies were as follows.

| R package | Installed version |
|--|--|
| Boruta | 9.0.0 |
| data.table | 1.17.6 |
| dplyr | 1.1.4 |
| e1071 | 1.7-16 |
| glmnet | 4.1-10 |
| lightgbm | 4.7.0 |
| mice | 3.19.0 |
| mlr3 | 1.7.1 |
| mlr3learners | 0.15.1 |
| paradox | 1.0.1 |
| ranger | 0.18.0 |
| xgboost | 3.2.1.1 |

The fixed model and tuning code was sourced from the project environment that also included bbotk 1.12.0, broom 1.0.8, digest 0.6.37, future 1.68.0, jsonlite 2.0.0, mlr3mbo 1.2.1, mlr3tuning 1.6.1, and R6 2.6.1. Install packages from the relevant R archive or version-compatible study environment. LightGBM needs a compatible native R build. Keep private data and temporary output outside Git. The exact portable demo commands and limits are in the [version README](../../6_release/revision-20261125/README.md); the [Python requirements](requirements.txt) cover the portable Python modules.
