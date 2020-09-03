# Stage 2 modeling

# LGB-ia
# LGB-iar
# Naive
# SNaive

# Aggregate data
summary_tsfeatures <- read_rds("data/clean/summary_tsfeatures.rds")
summary_basic <- read_rds("data/clean/summary_basic.rds") %>%
  select(-first_date_no_na, -first_date_no_zero)

summary_res <- read_rds("data/clean/summary_res.rds") %>%
  filter(block == 43)
summary_res_spread <- summary_res %>%
  mutate(method = tolower(method),
         method = gsub("-", "_", method)) %>%
  select(-mae, -mase_constant, -mase_constant_fix, -mase_2) %>%
  spread(method, mase)
summary_res

