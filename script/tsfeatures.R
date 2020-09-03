library(tsfeatures)
library(furrr)
library(lubridate)
library(tidyverse)

train <- read_feather("data/clean/ifc_clean.feather") %>%
  arrange(idx) %>%
  mutate(stock_distributed = replace_na(stock_distributed, 0)) %>%
  select(site_code, product_code, stock_distributed) %>%
  group_by(site_code, product_code) %>%
  nest()

extract_ts_feature <- function(df) {
  df %>%
    pull(stock_distributed) %>%
    ts(start = c(2016, 1),
       end = c(2019, 9),
       frequency = 12) %>%
    tsfeatures(features = c(
      "acf_features",
      "arch_stat",
      "crossing_points",
      "entropy",
      "flat_spots",
      "heterogeneity_tsfeat_workaround",
      "holt_parameters",
      "hurst",
      "lumpiness",
      "nonlinearity",
      "pacf_features",
      "stl_features",
      "stability",
      "hw_parameters_tsfeat_workaround",
      "unitroot_kpss",
      "unitroot_pp"
    ))
}

# train_sample <- train$data[[500]]
# train_sample %>%
#   extract_ts_feature()

safe_extract_ts_feature <- possibly(extract_ts_feature, 0)

train_nonzero <- train %>%
  mutate(total = map_dbl(data, function(x) sum(x$stock_distributed))) %>%
  filter(total > 0) %>%
  mutate(features = map(data, safe_extract_ts_feature))
features_train <- train_nonzero %>%
  select(-data) %>%
  unnest(features)
features_train <- features_train %>%
  ungroup() %>%
  select(-features) %>%
  mutate_if(is.numeric, ~replace_na(., 0))
features_train <- features_train %>%
  select(-total)

write_rds(features_train, "data/clean/summary_tsfeatures.rds")
