# Prepare
df_clean <- read_feather("data/clean/ifc_clean.feather")
df_clean_filtered <- df_clean %>%
  mutate(idx_flag = isna == FALSE,
         idx_flag = as.integer(idx_flag)) %>%
  group_by(site_code, product_code) %>%
  mutate(idx_flag_cumsum = cumsum(idx_flag)) %>%
  filter(idx_flag_cumsum > 1) %>%
  mutate(stock_distributed = replace_na(stock_distributed, 0),
         val_diff = abs(stock_distributed - lag(stock_distributed)))
sub_final <- read_csv("data/raw/submission_format.csv")
summary_sub <- sub_final %>%
  count(site_code, product_code)

# Calculate MASE denominator (only take first value only)
summary_diff <- df_clean_filtered %>%
  summarise(cnt = n(),
            val_diff = mean(val_diff, na.rm = TRUE),
            val_diff_cv_43 = mean(ifelse(idx < 43, val_diff, NA_real_), na.rm = TRUE),
            val_diff_cv_42 = mean(ifelse(idx < 42, val_diff, NA_real_), na.rm = TRUE),
            val_diff_cv_41 = mean(ifelse(idx < 41, val_diff, NA_real_), na.rm = TRUE),
            val_diff_cv_40 = mean(ifelse(idx < 40, val_diff, NA_real_), na.rm = TRUE),
            val_diff_cv_39 = mean(ifelse(idx < 39, val_diff, NA_real_), na.rm = TRUE),
            val_diff_cv_38 = mean(ifelse(idx < 38, val_diff, NA_real_), na.rm = TRUE),
            val_diff_cv_37 = mean(ifelse(idx < 37, val_diff, NA_real_), na.rm = TRUE),
            val_diff_cv_34 = mean(ifelse(idx < 34, val_diff, NA_real_), na.rm = TRUE)) %>%
  ungroup() %>%
  left_join(summary_sub) %>%
  mutate(is_eligible = case_when(n > 0 ~ 1,
                                 TRUE ~ 0)) %>%
  select(-n)
summary_diff %>%
  write_feather("data/clean/denom_v1.feather")

## Only 970 which have good MASE
## From 1052 sub, 1036 exists, 16 are missing
summary_diff %>%
  mutate(cat = case_when(val_diff > 0 ~ "(A) Good",
                         val_diff == 0 ~ "(B) Zero",
                         is.na(val_diff) ~ "(C) Empty")) %>%
  count(cat, is_eligible)
summary_diff %>%
  mutate(cat = case_when(val_diff_cv_43 > 0 ~ "(A) Good",
                         val_diff_cv_43 == 0 ~ "(B) Zero",
                         is.na(val_diff_cv_43) ~ "(C) Empty")) %>%
  count(cat)

# Check missing in sub (6 are missing, unknown)
summary_sub %>%
  anti_join(summary_diff)
summary_sub %>%
  anti_join(summary_diff) %>%
  inner_join(df_clean) %>%
  filter(isna == FALSE)

## Six site-product are not exist anywhere
summary_sub %>%
  anti_join(summary_diff) %>%
  anti_join(df_clean)
df_clean %>%
  filter(site_code == "C1080",
         product_code == "AS21126")

# Check only 3-6 data in the last
df_clean_filtered %>%
  filter(n() <= 3) %>%
  # filter(n() >= 3, n() <= 6) %>%
  View()

