## Baseline Forecasting
## Naive
## Seasonal Naive
## ETS
## ARIMA
## Linear Regression

library(forecast)
library(tidyverse)
library(tsibble)
library(lubridate)
library(furrr)
plan(multiprocess)

source("script/util.R")

logistic <- read_csv("data/raw/contraceptive_logistics_data.csv") %>%
  select(year, month, site_code, product_code, stock_distributed)
logistic <- logistic %>%
  group_by(site_code, product_code) %>%
  complete(year = 2016:2019, month = 1:12) %>%
  mutate(ds = dmy(paste(1, month, year, sep = "-"))) %>%
  select(-year, -month)
logistic <- logistic %>%
  rename(y = stock_distributed) %>%
  mutate(isna = is.na(y))
logistic <- logistic %>%
  filter(ds < ymd(20191001))
logistic <- logistic %>%
  mutate(idx = row_number())

## Setup
cv_list <- get_cv_block()

## Test
df <- logistic %>%
  filter(product_code == "AS27000",
         site_code == "C1024")


# Naive -------------------------------------------------------------------
get_result_naive <- function(df, i) {
  # Predict
  df <- df %>%
    mutate(y_pred = lag(y, 1),
           y_pred = ifelse(idx %% 3 == 1, y_pred, NA_real_)) %>%
    fill(y_pred, .direction = "down")

  # Split train and test
  df_train <- df %>%
    filter(idx < cv_list$start[i])
  df_test <- df %>%
    filter(idx >= cv_list$start[i],
           idx <= cv_list$end[i])

  # Predict
  y_train <- df_train$y
  y_train_pred <- df_train$y_pred
  y_test <- df_test$y
  y_test_pred <- df_test$y_pred

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

df <- logistic %>%
  nest()
df <- df %>%
  ungroup() %>%
  mutate(res_cv1 = future_map(data, get_result_naive, 1),
         res_cv11 = future_map(data, get_result_naive, 2),
         res_cv2 = future_map(data, get_result_naive, 3),
         res_cv21 = future_map(data, get_result_naive, 4),
         res_cv3 = future_map(data, get_result_naive, 5),
         res_cv31 = future_map(data, get_result_naive, 6),
         res_cv4 = future_map(data, get_result_naive, 7),
         res_cv5 = future_map(data, get_result_naive, 8))
res <- df %>%
  select(-data) %>%
  gather(cv, res, -site_code, -product_code)
write_rds(res, "data/temp/naive.rds")

# Seasonal Naive ----------------------------------------------------------
get_result_snaive <- function(df, i) {
  # Predict
  df <- df %>%
    mutate(y_pred = lag(y, 3))

  # Split train and test
  df_train <- df %>%
    filter(idx < cv_list$start[i])
  df_test <- df %>%
    filter(idx >= cv_list$start[i],
           idx <= cv_list$end[i])

  # Predict
  y_train <- df_train$y
  y_train_pred <- df_train$y_pred
  y_test <- df_test$y
  y_test_pred <- df_test$y_pred

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

df <- logistic %>%
  nest()
df <- df %>%
  ungroup() %>%
  mutate(res_cv1 = future_map(data, get_result_snaive, 1),
         res_cv11 = future_map(data, get_result_snaive, 2),
         res_cv2 = future_map(data, get_result_snaive, 3),
         res_cv21 = future_map(data, get_result_snaive, 4),
         res_cv3 = future_map(data, get_result_snaive, 5),
         res_cv31 = future_map(data, get_result_snaive, 6),
         res_cv4 = future_map(data, get_result_snaive, 7),
         res_cv5 = future_map(data, get_result_snaive, 8))
res <- df %>%
  select(-data) %>%
  gather(cv, res, -site_code, -product_code)
write_rds(res, "data/temp/snaive.rds")




