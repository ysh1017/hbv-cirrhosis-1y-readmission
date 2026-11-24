seed_values <- function(s) list(fixed_split_identifier = s, tuning_seed = 700000L + s, seed = 800000L + s, data_random_seed = 900000L +
    s, feature_fraction_seed = 1000000L + s, bagging_seed = 1100000L + s, drop_seed = 1200000L + s, extra_seed = 1300000L +
    s, final_fit_seed = 1400000L + s)
