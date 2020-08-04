## Create Submission on Zindi

sub_example <- read_csv("data/sub_zindi/SampleSubmission.csv")

## My submission
res <- read_rds("data/temp/xgb.rds")
res <- res %>%
  filter(cv == "res_cv1") %>%
  transmute(site_code,
            product_code,
            cv,
            y_test = map(res, pluck, "y_test"),
            y_test_pred = map(res, pluck, "y_test_pred")) %>%
  unnest() %>%
  group_by(site_code, product_code) %>%
  mutate(r = row_number() + 6) %>%
  ungroup() %>%
  mutate(ID = paste(2019, r, site_code, product_code, sep = " X "))

sub_xgb <- sub_example %>%
  select(-prediction) %>%
  left_join(
    res %>%
      transmute(ID,
                prediction = y_test_pred)
  )

write.csv(sub_xgb, "data/sub_zindi/xgb_benchmark.csv", row.names = FALSE)

# Below Threshold to zero :)
sub_xgb %>%
  mutate(prediction = ifelse(prediction < 1, 0, prediction)) %>%
  write.csv("data/sub_zindi/xgb_benchmark_01_tres.csv", row.names = FALSE)

sub_xgb %>%
  mutate(prediction = ifelse(prediction < 0.5, 0, prediction)) %>%
  write.csv("data/sub_zindi/xgb_benchmark_0.5_tres.csv", row.names = FALSE)
