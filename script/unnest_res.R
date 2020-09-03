# Extract nested model result ro tibble
res <- bind_rows(
  read_rds("data/temp/naive.rds") %>%
    mutate(method = "Naive"),
  read_rds("data/temp/snaive.rds") %>%
    mutate(method = "SNaive"),
  read_rds("data/temp/regression.rds") %>%
    mutate(method = "Regression"),
  read_rds("data/temp/xgb.rds") %>%
    mutate(method = "XGBoost"),
  read_rds("data/temp/arima.rds") %>%
    mutate(method = "ARIMA"),
  read_rds("data/temp/ets.rds") %>%
    mutate(method = "ETS")
) %>%
  mutate(stock_distributed = map(res, function(x) pluck(x, "y_test")),
         preds = map(res, function(x) pluck(x, "y_test_pred"))) %>%
  select(-res) %>%
  unnest() %>%
  mutate(block = case_when(cv == "res_cv1" ~ 43,
                           cv == "res_cv11" ~ 42,
                           cv == "res_cv2" ~ 41,
                           cv == "res_cv21" ~ 40,
                           cv == "res_cv3" ~ 39,
                           cv == "res_cv31" ~ 38,
                           cv == "res_cv4" ~ 37,
                           cv == "res_cv5" ~ 34)) %>%
  select(-cv)

res <- res %>%
  group_by(method, site_code, product_code, block) %>%
  mutate(idx = block + row_number() - 1) %>%
  ungroup() %>%
  filter(!is.na(stock_distributed)) %>%
  select(method, site_code, product_code,
         idx, stock_distributed, preds, block)

write.csv(res, "data/temp/res_all.csv", row.names = FALSE)
