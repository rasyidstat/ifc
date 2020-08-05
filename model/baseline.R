## Baseline Forecasting
## Naive
## Seasonal Naive
## ETS
## ARIMA
## Linear Regression
## XGBoost

library(forecast)
library(tidyverse)
library(tsibble)
library(lubridate)
library(furrr)
library(xgboost)
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
  y_test_pred <- replace_na(df_test$y_pred, 0)

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
  y_test_pred <- replace_na(df_test$y_pred, 0)

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


# Linear Regression -------------------------------------------------------
get_result_regression <- function(df, i) {
  # Predict
  df <- df %>%
    mutate(y_lag_3 = lag(y, 3))
  df <- df %>%
    filter(idx > 3)
  df <- df %>%
    mutate(y_lag_3 = replace_na(y_lag_3, 0))

  # Split train and test
  df_train <- df %>%
    filter(idx < cv_list$start[i]) %>%
    filter(!is.na(y))
  df_test <- df %>%
    filter(idx >= cv_list$start[i],
           idx <= cv_list$end[i])

  # Model
  if (nrow(df_train) > 0) {
    m <- lm(y ~ y_lag_3, data = df_train)
    y_train <-df_train$y
    y_train_pred <- predict(m)
    y_test_pred <- replace_na(predict(m, df_test), 0)
  } else {
    y_train <- NA_real_
    y_train_pred <- NA_real_
    y_test_pred <- rep(0, nrow(df_test))
  }

  y_test <- df_test$y

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

get_result_regression_safe <- possibly(get_result_regression, NA)
get_result_regression(df$data[[1]], 3)

df <- logistic %>%
  nest()
df <- df %>%
  ungroup() %>%
  mutate(res_cv1 = future_map(data, get_result_regression_safe, 1),
         res_cv11 = future_map(data, get_result_regression_safe, 2),
         res_cv2 = future_map(data, get_result_regression_safe, 3),
         res_cv21 = future_map(data, get_result_regression_safe, 4),
         res_cv3 = future_map(data, get_result_regression_safe, 5),
         res_cv31 = future_map(data, get_result_regression_safe, 6),
         res_cv4 = future_map(data, get_result_regression_safe, 7),
         res_cv5 = future_map(data, get_result_regression_safe, 8))
res <- df %>%
  select(-data) %>%
  gather(cv, res, -site_code, -product_code)
write_rds(res, "data/temp/regression.rds")


# Exponential Smoothing ---------------------------------------------------
get_result_ets <- function(df, i) {
  # Split train and test
  df_train <- df %>%
    filter(idx < cv_list$start[i])
  df_test <- df %>%
    filter(idx >= cv_list$start[i],
           idx <= cv_list$end[i])

  # Model
  df_train_ts <- ts(replace_na(df$y, 0))

  # Model
  if (nrow(df_train) > 0) {
    m <- ets(df_train_ts)
    y_train <- df_train$y
    y_train_pred <- ifelse(m$fitted < 0, 0, m$fitted)
    y_test <- df_test$y
    y_test_pred <- forecast(m, 3)$mean
    y_test_pred <- ifelse(y_test_pred < 0, 0, y_test_pred)
  } else {
    y_train <- NA_real_
    y_train_pred <- NA_real_
    y_test_pred <- rep(0, nrow(df_test))
  }

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
  mutate(res_cv1 = future_map(data, get_result_ets, 1),
         res_cv11 = future_map(data, get_result_ets, 2),
         res_cv2 = future_map(data, get_result_ets, 3),
         res_cv21 = future_map(data, get_result_ets, 4),
         res_cv3 = future_map(data, get_result_ets, 5),
         res_cv31 = future_map(data, get_result_ets, 6),
         res_cv4 = future_map(data, get_result_ets, 7),
         res_cv5 = future_map(data, get_result_ets, 8))
res <- df %>%
  select(-data) %>%
  gather(cv, res, -site_code, -product_code)
write_rds(res, "data/temp/ets.rds")


# Linear Regression (Log) -------------------------------------------------
get_result_regression <- function(df, i) {
  # Convert to log
  df <- df %>%
    mutate(y = log(y+1))
  # Predict
  df <- df %>%
    mutate(y_lag_3 = lag(y, 3))
  df <- df %>%
    filter(idx > 3)
  df <- df %>%
    mutate(y_lag_3 = replace_na(y_lag_3, 0))

  # Split train and test
  df_train <- df %>%
    filter(idx < cv_list$start[i]) %>%
    filter(!is.na(y))
  df_test <- df %>%
    filter(idx >= cv_list$start[i],
           idx <= cv_list$end[i])

  # Model
  if (nrow(df_train) > 0) {
    m <- lm(y ~ y_lag_3, data = df_train)
    y_train <- exp(df_train$y) - 1
    y_train_pred <- exp(predict(m)) - 1
    y_test_pred <- replace_na(exp(predict(m, df_test)), 0)
  } else {
    y_train <- NA_real_
    y_train_pred <- NA_real_
    y_test_pred <- rep(0, nrow(df_test))
  }

  y_test <- exp(df_test$y) - 1

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

get_result_regression_safe <- possibly(get_result_regression, NA)

df <- logistic %>%
  nest()
df <- df %>%
  ungroup() %>%
  mutate(res_cv1 = future_map(data, get_result_regression_safe, 1),
         res_cv11 = future_map(data, get_result_regression_safe, 2),
         res_cv2 = future_map(data, get_result_regression_safe, 3),
         res_cv21 = future_map(data, get_result_regression_safe, 4),
         res_cv3 = future_map(data, get_result_regression_safe, 5),
         res_cv31 = future_map(data, get_result_regression_safe, 6),
         res_cv4 = future_map(data, get_result_regression_safe, 7),
         res_cv5 = future_map(data, get_result_regression_safe, 8))
res <- df %>%
  select(-data) %>%
  gather(cv, res, -site_code, -product_code)
write_rds(res, "data/temp/regression_log.rds")

# y = log(x) --> x = exp(y)
# y = log(x + 1) --> x + 1 = exp(y) --> x = exp(y) - 1


# XGBoost -----------------------------------------------------------------
get_result_xgb <- function(df, i) {
  # Predict
  df <- df %>%
    mutate(y_lag_3 = lag(y, 3))
  df <- df %>%
    filter(idx > 3)
  df <- df %>%
    mutate(y_lag_3 = replace_na(y_lag_3, 0))

  # Split train and test
  df_train <- df %>%
    filter(idx < cv_list$start[i]) %>%
    filter(!is.na(y))
  df_test <- df %>%
    filter(idx >= cv_list$start[i],
           idx <= cv_list$end[i])

  # Model
  if (nrow(df_train) > 0) {
    m <- xgboost(data = as.matrix(select(ungroup(df_train), y_lag_3)),
                 label = df_train$y,
                 nrounds = 100,
                 params = list(booster = "gblinear",
                               eta = 0.05))
    y_train <- df_train$y
    y_train_pred <- predict(m, as.matrix(select(ungroup(df_train), y_lag_3)))
    y_test_pred <- replace_na(predict(m, as.matrix(select(ungroup(df_test), y_lag_3))), 0)
  } else {
    y_train <- NA_real_
    y_train_pred <- NA_real_
    y_test_pred <- rep(0, nrow(df_test))
  }

  y_train_pred <- ifelse(y_train_pred < 0, 0, y_train_pred)
  y_test_pred <- ifelse(y_test_pred < 0, 0, y_test_pred)
  y_test <- df_test$y

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

get_result_xgb_safe <- possibly(get_result_xgb, NA)
get_result_xgb_safe(df$data[[1]], 3)

df <- logistic %>%
  nest()
df <- df %>%
  ungroup() %>%
  mutate(res_cv1 = future_map(data, get_result_xgb_safe, 1),
         res_cv11 = future_map(data, get_result_xgb_safe, 2),
         res_cv2 = future_map(data, get_result_xgb_safe, 3),
         res_cv21 = future_map(data, get_result_xgb_safe, 4),
         res_cv3 = future_map(data, get_result_xgb_safe, 5),
         res_cv31 = future_map(data, get_result_xgb_safe, 6),
         res_cv4 = future_map(data, get_result_xgb_safe, 7),
         res_cv5 = future_map(data, get_result_xgb_safe, 8))
res <- df %>%
  select(-data) %>%
  gather(cv, res, -site_code, -product_code)
write_rds(res, "data/temp/xgb.rds")

