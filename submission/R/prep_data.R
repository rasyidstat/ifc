# Script to prepare data
library(tidyverse)
library(lubridate)

annual <- read_csv("../data/contraceptive_case_data_annual.csv")
monthly <- read_csv("../data/contraceptive_case_data_monthly.csv")
logistic <- read_csv("../data/contraceptive_logistics_data.csv")
location <- read_csv("../data/service_delivery_site_data.csv")
product <- read_csv("../data/product.csv")
subm <- read_csv("../data/submission_format.csv")

logistic <- logistic %>%
  group_by(site_code, product_code, region, district) %>%
  complete(year = 2016:2019, month = 1:12) %>%
  mutate(ds = dmy(paste(1, month, year, sep = "-"))) %>%
  select(-year, -month)
logistic <- logistic %>%
  mutate(isna = is.na(stock_distributed))
logistic <- logistic %>%
  filter(ds < ymd(20191001))
logistic <- logistic %>%
  mutate(idx = row_number()) %>%
  ungroup()

# Join with other
# Join logistic and location
logistic <- logistic %>%
  left_join(
    location %>%
      select(-site_region, -site_district)
  )

# Join logistic and product
logistic <- logistic %>%
  left_join(product)

# Write csv
write_csv(logistic, "../data/ifc_clean.csv")
