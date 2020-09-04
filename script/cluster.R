# Aggregate data
summary_tsfeatures <- read_rds("data/clean/summary_tsfeatures.rds")
summary_basic <- read_rds("data/clean/summary_basic.rds") %>%
  select(-first_date_no_na, -first_date_no_zero)
summary_all <- summary_basic %>%
  left_join(summary_tsfeatures) %>%
  mutate_at(vars(x_acf1:unitroot_pp), ~replace_na(., 0)) %>%
  select(-cnt) %>%
  mutate_at(vars(contains("cnt"), val_sp), ~./45) %>%
  mutate(val_max_mean = val_max / val_mean,
         val_sd_mean = val_sd / val_mean) %>%
  mutate_if(is.numeric, ~ifelse(is.na(.) | is.infinite(.), 0, .))



# Cluster using all features ----------------------------------------------
summary_norm <- summary_all %>%
  select_if(is.numeric) %>%
  mutate_all(scale)

library(factoextra)
fviz_nbclust(summary_norm, kmeans, method = "wss", k.max = 20) +
  geom_vline(xintercept = 10, linetype = 2) +
  labs(subtitle = "Elbow method")

# Get 10 clusters
set.seed(2020)
km <- kmeans(summary_norm, 10)

# Cluster summary
summary_all %>%
  mutate(cluster = km$cluster) %>%
  count(cluster) %>%
  left_join(
    summary_all %>%
      mutate(cluster = km$cluster) %>%
      group_by(cluster) %>%
      summarise_if(is.numeric, mean)
  )
summary_all %>%
  mutate(cluster = km$cluster) %>%
  write_rds("data/clean/cluster_v1.rds")

