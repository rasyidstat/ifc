# Stage 2 modeling

# LGB-ia
# LGB-iar
# Naive
# SNaive

library(corrr)

# Aggregate data
summary_tsfeatures <- read_rds("data/clean/summary_tsfeatures.rds")
summary_basic <- read_rds("data/clean/summary_basic.rds") %>%
  select(-first_date_no_na, -first_date_no_zero) %>%
  mutate(val_sd_mean = val_mean / val_sd)

summary_res <- read_rds("data/clean/summary_res.rds") %>%
  filter(block == 43)

summary_res_spread <- summary_res %>%
  mutate(method = tolower(method),
         method = gsub("-", "_", method)) %>%
  select(-mae, -mase_constant, -mase_constant_fix, -mase_2) %>%
  spread(method, mase) %>%
  left_join(summary_basic) %>%
  left_join(summary_tsfeatures) %>%
  mutate_at(vars(x_acf1:unitroot_pp), ~replace_na(., 0))

# Correlation exploration
correl_summary <- summary_res_spread %>%
  select(arima:xgboost, na_cnt:unitroot_pp) %>%
  select_if(is.numeric) %>%
  correlate() %>%
  focus(arima, ets, lgb, lgb_i, lgb_ia, lgb_iar, naive, regression, snaive, xgboost) %>%
  arrange(desc(abs(lgb_ia)))
correl_summary %>%
  select(rowname, lgb_ia, lgb_iar, naive)
  View()

