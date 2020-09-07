## Baseline Forecasting
## Median
## Average

library(tidyverse)
library(lubridate)
library(furrr)
library(feather)
plan(multiprocess)

source("script/util.R")

train <- read_feather("data/clean/ifc_clean.feather")
train <- train %>%
  group_by(site_code, product_code) %>%
  mutate(isna_cumsum = cumsum(ifelse(isna, 0, 1))) %>%
  filter(isna_cumsum > 0) %>%
  rename(y = stock_distributed)

cv_list <- get_cv_block() %>%
  filter(start %in% c(43,40,37,34)) %>%
  add_row(cat = "CV0", start = 46, end = 48)

## Test
df <- train %>%
  filter(product_code == "AS21126",
         site_code == "C3015") %>%
  ungroup()

get_result_mean <- function(df, i) {
  # Split train and test
  df_train <- df %>%
    filter(idx < cv_list$start[i])
  df_test <- df %>%
    filter(idx >= cv_list$start[i],
           idx <= cv_list$end[i])

  # Predict
  y_train <- df_train$y
  y_train_pred <- rep(mean(df_train$y, na.rm = TRUE), length(y_train))
  y_test <- df_test$y
  y_test_pred <- rep(mean(df_train$y, na.rm = TRUE), length(y_test))

  # Output
  output <- list(
    start_date = cv_list$start[i],
    end_date = cv_list$end[i],
    y_train = y_train,
    y_train_pred = y_train_pred,
    y_test = y_test,
    y_test_pred = y_test_pred,
    mae_train = mae(y_train, y_train_pred),
    mae_test = mae(y_test, y_test_pred),
    rmse_train = rmse(y_train, y_train_pred),
    rmse_test = rmse(y_test, y_test_pred),
    smape_train = smape(y_train, y_train_pred),
    smape_test = smape(y_test, y_test_pred)
  )
}
df <- train %>%
  nest()
df <- df %>%
  ungroup() %>%
  mutate(`43` = future_map(data, get_result_mean, 1),
         `40` = future_map(data, get_result_mean, 2),
         `37` = future_map(data, get_result_mean, 3),
         `34` = future_map(data, get_result_mean, 4))
res <- df %>%
  select(-data) %>%
  gather(cv, res, -site_code, -product_code)

write_rds(res, "data/temp/mean.rds")

summary_diff <- read_feather("data/clean/denom_v1.feather")
summary_diff_spread <- summary_diff %>%
  select(-cnt, -is_eligible) %>%
  gather(block, mase_constant, -site_code, -product_code) %>%
  mutate(block = gsub("val_diff_|val_diff_cv_", "", block),
         block = ifelse(block == "test", "46", block),
         block = as.integer(block),
         mase_constant = ifelse(is.na(mase_constant), 0, mase_constant))
res <- read_rds("data/temp/mean.rds")
res <- res %>%
  mutate(stock_distributed = map(res, function(x) pluck(x, "y_test")),
         preds = map(res, function(x) pluck(x, "y_test_pred")[1:3])) %>%
  select(-res)
res <- res %>%
  mutate(n1 = map_dbl(stock_distributed, length),
         n2 = map_dbl(preds, length)) %>%
  filter(n1 == n2) %>%
  select(-n1, -n2) %>%
  unnest() %>%
  filter(!is.na(stock_distributed))
res <- res %>%
  mutate(preds = replace_na(preds, 0)) %>%
  rename(block = cv) %>%
  mutate(ae = abs(preds - stock_distributed)) %>%
  group_by(site_code, product_code, block) %>%
  summarise(mae = mean(ae)) %>%
  ungroup() %>%
  mutate(block = as.integer(block)) %>%
  left_join(summary_diff_spread) %>%
  mutate(mase = mae / mase_constant,
         mase = ifelse(mase_constant == 0, 0, mase))
res %>%
  group_by(block) %>%
  summarise(mae = mean(mae),
            mase = mean(mase))

# block   mae  mase
# <int> <dbl> <dbl>
# 1    34  12.0  1.24
# 2    37  12.8  1.32
# 3    40  11.5  1.37
# 4    43  11.9  1.20
