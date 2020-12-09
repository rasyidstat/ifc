library(tidyverse)
library(lubridate)

pred_df <- read.csv("submission/pred.csv") %>%
  select(-X) %>%
  mutate(preds = ifelse(preds < 0, 0, preds))

pred_df %>%
  mutate(date = ymd(20191201),
         date = date + months(idx - 48),
         date = format(date, "%Y %b")) %>%
  select(date, site_code, product_code, preds) %>%
  write.csv("data/rmse_37_oct2018_dec2019.csv", row.names = FALSE)

pred_df %>%
  mutate(date = ymd(20191201),
         date = date + months(idx - 48),
         date = format(date, "%Y %b")) %>%
  filter(idx <= 45) %>%
  select(date, site_code, product_code, preds) %>%
  write.csv("data/rmse_37_oct2018_sep2019.csv", row.names = FALSE)

