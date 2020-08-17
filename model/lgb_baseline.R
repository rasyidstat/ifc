## Baseline LGB in R
## Best MAE so far is 10.14

library(tidyverse)
library(tsibble)
library(lubridate)
library(furrr)
library(lightgbm)
library(feather)
plan(multiprocess)

source("script/util.R")

train <- read_feather("data/clean/ifc_clean.feather")
train <- train %>%
  mutate(stock_distributed = replace_na(stock_distributed, 0))

# Lag features
train <- train %>%
  group_by(site_code, product_code) %>%
  mutate(stock_distributed_lag_1 = lag(stock_distributed, 1),
         stock_distributed_lag_2 = lag(stock_distributed, 2),
         stock_distributed_lag_3 = lag(stock_distributed, 3),
         stock_distributed_lag_4 = lag(stock_distributed, 4)) %>%
  ungroup()
train <- train %>%
  filter_at(vars(contains("stock_distributed")), all_vars(!is.na(.)))

# LGB dataset
block <- 43
dtrain <- train %>%
  filter(idx < block) %>%
  select(site_code, product_code, region, district, product_type,
         contains("stock_distributed"))
dtest <- train %>%
  filter(idx >= block, idx < block + 3) %>%
  select(site_code, product_code, region, district, product_type,
         contains("stock_distributed"))

train_lgb <- lgb.Dataset(data = lgb.convert_with_rules(select(dtrain, -stock_distributed)),
                         label = pull(select(dtrain, stock_distributed)))
test_lgb <- lgb.Dataset(data = lgb.convert_with_rules(select(dtest, -stock_distributed)),
                        label = pull(select(dtest, stock_distributed)))
lgb.grid <-  list(objective = "mean_absolute_error",
                  metric = "mae")
lgb.train(data = train_lgb, objective = "regression")


# Error I don't know why... Let's use Python then -------------------------
