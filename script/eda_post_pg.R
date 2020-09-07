
res_lgb_final %>%
  count(block, idx)

log_txt <- readLines("data/temp/log.txt") %>%
  as_tibble()
log_txt <- log_txt %>%
  filter(grepl("CV details is ", value)) %>%
  mutate(metrics = ifelse(grepl("MASE", value), "mae", "mase"),
         value = gsub(".*\\[|]", "", value)) %>%
  separate(value, c("cv1","cv2","cv3","cv4"), sep = ", ") %>%
  mutate_at(vars(cv1:cv4), as.numeric) %>%
  group_by(metrics) %>%
  mutate(iter = row_number()) %>%
  ungroup()
log_txt_mean <- log_txt %>%
  gather(key, val, -metrics, -iter) %>%
  group_by(metrics, iter) %>%
  summarise(val_mean = mean(val),
            val_sd = sd(val)) %>%
  ungroup()

visualize_agg_prediction(res_lgb_final)
visualize_specific_prediction_top_bottom(res_lgb_final)



# Not found ---------------------------------------------------------------
df_missing <- read_csv("data/sub_not_found.csv") %>%
  select(-X1)
train <- read_feather("data/clean/ifc_clean.feather")
train %>%
  inner_join(df_missing) %>%
  group_by(site_code, product_code) %>%
  summarise(pred = median(stock_distributed, na.rm = TRUE))
df_missing %>%
  anti_join(train)

train %>%
  arrange(site_code, product_code, ds) %>%
  View()
