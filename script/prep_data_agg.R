# Aggregate data

df_clean <- read_feather("data/clean/ifc_clean.feather")
df_summary <- df_clean %>%
  group_by(site_code, product_code) %>%
  summarise(cnt = n(),
            na_cnt = sum(isna),
            zero_cnt = sum(ifelse(stock_distributed == 0, 1, 0), na.rm = TRUE),
            zero_na_cnt = na_cnt + zero_cnt,
            first_date_no_na = ds[which.min(ifelse(!is.na(stock_distributed), stock_distributed, NA))],
            first_date_no_zero =  ds[which.min(ifelse(stock_distributed != 0, stock_distributed, NA))],
            cnt_v2_no_na = interval(first_date_no_na, ymd(20191001)) %/% months(1),
            cnt_v3_no_zero = interval(first_date_no_zero, ymd(20191001)) %/% months(1),
            val_sum = sum(stock_distributed, na.rm = TRUE),
            val_mean = mean(stock_distributed, na.rm = TRUE),
            val_median = median(stock_distributed, na.rm = TRUE),
            val_min = min(stock_distributed, na.rm = TRUE),
            val_max = max(stock_distributed, na.rm = TRUE),
            val_sd = sd(stock_distributed, na.rm = TRUE),
            val_m1 = mean(ifelse(month(ds) == 1, stock_distributed, NA_real_), na.rm = TRUE) / val_mean,
            val_m2 = mean(ifelse(month(ds) == 2, stock_distributed, NA_real_), na.rm = TRUE) / val_mean,
            val_m3 = mean(ifelse(month(ds) == 3, stock_distributed, NA_real_), na.rm = TRUE) / val_mean,
            val_m4 = mean(ifelse(month(ds) == 4, stock_distributed, NA_real_), na.rm = TRUE) / val_mean,
            val_m5 = mean(ifelse(month(ds) == 5, stock_distributed, NA_real_), na.rm = TRUE) / val_mean,
            val_m6 = mean(ifelse(month(ds) == 6, stock_distributed, NA_real_), na.rm = TRUE) / val_mean,
            val_m7 = mean(ifelse(month(ds) == 7, stock_distributed, NA_real_), na.rm = TRUE) / val_mean,
            val_m8 = mean(ifelse(month(ds) == 8, stock_distributed, NA_real_), na.rm = TRUE) / val_mean,
            val_m9 = mean(ifelse(month(ds) == 9, stock_distributed, NA_real_), na.rm = TRUE) / val_mean,
            val_m10 = mean(ifelse(month(ds) == 10, stock_distributed, NA_real_), na.rm = TRUE) / val_mean,
            val_m11 = mean(ifelse(month(ds) == 11, stock_distributed, NA_real_), na.rm = TRUE) / val_mean,
            val_m12 = mean(ifelse(month(ds) == 12, stock_distributed, NA_real_), na.rm = TRUE) / val_mean,
            upper_outlier_cnt = sum(ifelse(stock_distributed >= val_mean + 2.5 * val_sd, 1, 0), na.rm = TRUE),
            lower_outlier_cnt = sum(ifelse(stock_distributed <= val_mean - 2.5 * val_sd, 1, 0), na.rm = TRUE),
            upper_outlier_cnt_2 = sum(ifelse(stock_distributed >= val_mean + 2 * val_sd, 1, 0), na.rm = TRUE),
            lower_outlier_cnt_2 = sum(ifelse(stock_distributed <= val_mean - 2 * val_sd, 1, 0), na.rm = TRUE)) %>%
  ungroup()

write_rds(df_summary, "data/clean/summary_basic.rds")
