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

res <- read_rds("data/temp/naive.rds") %>%
  mutate(method = "Naive") %>%
  bind_rows(
    read_rds("data/temp/snaive.rds") %>%
      mutate(method = "SNaive"),
    read_rds("data/temp/regression.rds") %>%
      mutate(method = "Regression"),
    # read_rds("data/temp/regression_log.rds") %>%
    #   mutate(method = "Regression (Log)"),
    read_rds("data/temp/xgb.rds") %>%
      mutate(method = "XGBoost"),
    read_rds("data/temp/arima.rds") %>%
      mutate(method = "ARIMA")
  ) %>%
  filter(!is.na(res))
safe_pluck <- possibly(pluck, NA)
res <- res %>%
  mutate(rmse_train = map_dbl(res, safe_pluck, "rmse_train"),
         rmse_test = map_dbl(res, safe_pluck, "rmse_test"),
         mae_train = map_dbl(res, safe_pluck, "mae_train"),
         mae_test = map_dbl(res, safe_pluck, "mae_test"))


# Summary -----------------------------------------------------------------
res_summary <- res %>%
  group_by(method, cv) %>%
  summarise(cnt = sum(ifelse(is.na(mae_test), 0, 1)),
            mae_test = mean(mae_test, na.rm = TRUE)) %>%
  ungroup()
res_summary %>%
  ggplot(aes(cv, mae_test, color = method, group = method)) +
  geom_line() +
  theme_minimal() +
  scale_color_viridis_d()

res %>%
  group_by(method, cv) %>%
  summarise(cnt = sum(ifelse(is.na(mae_test), 0, 1)),
            mae_test = mean(mae_test, na.rm = TRUE)) %>%
  ungroup() %>%
  group_by(method) %>%
  summarise(mae_test_avg = mean(mae_test),
            mae_test_sd = sd(mae_test)) %>%
  View("res_1")

res_summary %>%
  ungroup() %>%
  group_by(method) %>%
  summarise(mae_test = mean(mae_test)) %>%
  View("res_2")



# All Observation ---------------------------------------------------------
res_unnest <- res %>%
  transmute(site_code,
            product_code,
            cv,
            method,
            y_test = map(res, pluck, "y_test"),
            y_test_pred = map(res, pluck, "y_test_pred")) %>%
  unnest()
res_summary_all <- res_unnest %>%
  mutate(se = (y_test - y_test_pred)^2,
         ae = abs(y_test - y_test_pred)) %>%
  group_by(method, cv) %>%
  summarise(n = sum(ifelse(is.na(y_test), 0, 1)),
            rmse = sqrt(mean(se, na.rm = TRUE)),
            mae = mean(ae, na.rm = TRUE)) %>%
  ungroup()
res_summary_all %>%
  ggplot(aes(cv, mae, color = method, group = method)) +
  geom_line() +
  theme_minimal() +
  scale_color_viridis_d()

res_summary_all %>%
  group_by(method) %>%
  summarise(mae_test_avg = mean(mae),
            mae_test_sd = sd(mae),
            rmse_test_avg = mean(rmse),
            rmse_test_sd = sd(rmse)) %>%
  View()
