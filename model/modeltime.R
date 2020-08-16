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
library(modeltime)
library(feather)
library(timetk)
library(tidymodels)
plan(multiprocess)

source("script/util.R")


# Practice ----------------------------------------------------------------
m750 <- m4_monthly %>% filter(id == "M750")
splits <- initial_time_split(m750, prop = 0.9)
model_fit_arima_no_boost <- arima_reg() %>%
  set_engine(engine = "auto_arima") %>%
  fit(value ~ date, data = training(splits))


# Implement ---------------------------------------------------------------
df_clean <- read_feather("data/clean/ifc_clean.feather")
df_clean <- df_clean %>%
  transmute(id = as.factor(paste(site_code, product_code, sep = "-")),
            idx, ds, val = stock_distributed) %>%
  filter(id == "C1077-AS27000")
df_train <- df_clean %>%
  filter(idx < 43) %>%
  select(-idx) %>%
  mutate(val = replace_na(val, 0))
df_test <- df_clean %>%
  filter(idx >= 43) %>%
  select(-idx)

# Modeltime!
model_arima <- arima_reg() %>%
  set_engine(engine = "auto_arima") %>%
  fit(val ~ ds, data = df_train)
model_arima_boost <- arima_boost(
  min_n = 2,
  learn_rate = 0.05
) %>%
  set_engine(engine = "auto_arima_xgboost") %>%
  fit(val ~ ds + as.numeric(ds) + factor(month(ds, label = TRUE), ordered = F),
      data = df_train)
model_ets <- exp_smoothing() %>%
  set_engine(engine = "ets") %>%
  fit(val ~ ds, data = df_train)
model_lm <- linear_reg() %>%
  set_engine("lm") %>%
  fit(val ~ as.numeric(ds) + factor(month(ds, label = TRUE), ordered = FALSE),
      data = df_train)

models_tbl <- modeltime_table(
  model_arima,
  model_arima_boost,
  model_ets,
  model_lm
)
calibration_tbl <- models_tbl %>%
  modeltime_calibrate(new_data = df_test)
calibration_tbl %>%
  modeltime_forecast(
    new_data    = df_test,
    actual_data = df_clean %>%
      select(-idx)
  ) %>%
  plot_modeltime_forecast(
    .legend_max_width = 25, # For mobile screens
    .interactive      = TRUE
  )
calibration_tbl %>%
  modeltime_accuracy() %>%
  table_modeltime_accuracy(resizable = TRUE, bordered = TRUE)

mape_vec(c(0,0,0), c(1,1,1))
mape_vec(c(0,0,0), c(0,0,0))
smape_vec(c(0,0,0), c(1,1,1))
smape_vec(c(0,0,0), c(0,0,0))
mase_vec(c(3,2,1), c(1,1,1), mae_train = 0)


