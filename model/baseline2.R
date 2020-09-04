## Baseline Forecasting
## NNETAR
## TBATS
## THETAF

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

# Exponential Smoothing ---------------------------------------------------
get_result <- function(df, i, model = "thetaf") {
  # Split train and test
  df_train <- df %>%
    filter(idx < cv_list$start[i])
  df_test <- df %>%
    filter(idx >= cv_list$start[i],
           idx <= cv_list$end[i])

  # Model
  df_train_ts <- ts(replace_na(df_train$y, 0))

  # Model
  if (nrow(df_train) > 0) {
    if (model == "nnetar") {
      m <- nnetar(df_train_ts)
    } else if (model == "tbats") {
      m <- tbats(df_train_ts)
    } else if (model == "thetaf") {
      m <- thetaf(df_train_ts)
    } else {
      stop()
    }
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
  mutate(res_cv1 = future_map(data, get_result, 1, "thetaf"),
         res_cv11 = future_map(data, get_result, 2, "thetaf"),
         res_cv2 = future_map(data, get_result, 3, "thetaf"),
         res_cv21 = future_map(data, get_result, 4, "thetaf"),
         res_cv3 = future_map(data, get_result, 5, "thetaf"),
         res_cv31 = future_map(data, get_result, 6, "thetaf"),
         res_cv4 = future_map(data, get_result, 7, "thetaf"),
         res_cv5 = future_map(data, get_result, 8, "thetaf"))
res <- df %>%
  select(-data) %>%
  gather(cv, res, -site_code, -product_code)
write_rds(res, "data/temp/thetaf.rds")

df <- logistic %>%
  nest()
df <- df %>%
  ungroup() %>%
  mutate(res_cv1 = future_map(data, get_result, 1, "tbats"),
         res_cv11 = future_map(data, get_result, 2, "tbats"),
         res_cv2 = future_map(data, get_result, 3, "tbats"),
         res_cv21 = future_map(data, get_result, 4, "tbats"),
         res_cv3 = future_map(data, get_result, 5, "tbats"),
         res_cv31 = future_map(data, get_result, 6, "tbats"),
         res_cv4 = future_map(data, get_result, 7, "tbats"),
         res_cv5 = future_map(data, get_result, 8, "tbats"))
res <- df %>%
  select(-data) %>%
  gather(cv, res, -site_code, -product_code)
write_rds(res, "data/temp/tbats.rds")

df <- logistic %>%
  nest()
df <- df %>%
  ungroup() %>%
  mutate(res_cv1 = future_map(data, get_result, 1, "nnetar"),
         res_cv11 = future_map(data, get_result, 2, "nnetar"),
         res_cv2 = future_map(data, get_result, 3, "nnetar"),
         res_cv21 = future_map(data, get_result, 4, "nnetar"),
         res_cv3 = future_map(data, get_result, 5, "nnetar"),
         res_cv31 = future_map(data, get_result, 6, "nnetar"),
         res_cv4 = future_map(data, get_result, 7, "nnetar"),
         res_cv5 = future_map(data, get_result, 8, "nnetar"))
res <- df %>%
  select(-data) %>%
  gather(cv, res, -site_code, -product_code)
write_rds(res, "data/temp/nnetar.rds")
