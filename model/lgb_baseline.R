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
