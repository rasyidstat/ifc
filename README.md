ifc
================

USAID’s Intelligent Forecasting: Model Future Contraceptive Use

## Status

  - Forecasting prize: MASE (got 2nd rank, MASE: 0.9980,
    [source](https://competitions4dev.org/forecastingprize/winners))
  - Co-creation phase: RMSSE (ongoing, deadline: 16 Dec 2020)

## Data

Source:
[Kaggle](https://www.kaggle.com/darisdzakwanhoesien2/usaids-model-future-contraceptive-use)

  - 156 sites
  - 11 products
  - 7 type of products
  - 1716 sites x products (train: 1357, test: 1052)
  - 45 observations from Jan 2016 to Sep 2019
  - Predict 3 observations from Oct 2019 to Dec 2019
  - 38,842 train data
  - 3,115 test data

Additional information:

  - Deadline: 8 Sept 2020
  - Metrics: MASE
  - 2 winners only (it will be very hard\!)

## Insights

  - Trend is going up (2015 is up, 2016 is stagnant, 2017 is up, 2018 is
    up)
  - There are products with trend and no trend
  - In average, there is only 25 non-zero data
  - Distributed evenly for first non-zero date

## CV Strategy

4 times CV (quarterly basis)

  - Jan - Mar 2019 (36 data)
  - April - Jun 2019 (39 data)
  - Jul - Sep 2019 (42 data)
  - Oct - Dec 2018 (33 data)

## Tasks

Notion:
[link](https://www.notion.so/rasyidridha/Tasks-e9c9299a80bf46e9aa6f448998ff40fc?p=86a7c89a14bb48708f968a1c8f854b2b)

  - [x] EDA: MVP
  - [x] EDA: Check data completeness
  - [x] EDA: Deep EDA
  - [x] EDA: Post EDA prediction result and evaluationn
  - [x] Modeling: MVP (baseline)
  - [x] Modeling: single model (10.39, tree models, [LightGBM
    baseline](https://www.kaggle.com/rasyidstat/ifc-lightgbm-baseline))
  - [x] Modeling: separate model for each lag (10.18, better so far)
  - [x] Modeling: recursive model (10.77)
  - [x] Modeling: all variables included (10.83)
  - [x] Clustering + re-EDA
  - [x] Features engineering: scale to 0 to 1 for each series
  - [x] Features engineering: remove first NA value (not working)
  - [x] Features engineering: normalize based on number of days in month
  - [x] Features engineering: time series features extraction
  - [x] Postprocessing: factor multiplication (between 1.05-1.20, tree
    models cannot get the trend)
  - [x] Post-EDA: MVP (explore LightGBM and ensemble technique)

Not yet tried:

  - [ ] Features engineering: neighborhood features
  - [ ] External Data
  - [ ] Function: create universal function (recursive, individual vs
    all)
  - [ ] Modeling: ETS + LightGBM (R for ETS, Python for LightGBM)
  - [ ] Modeling: predict zero values (classification)

## Result

Please check `submission` directory or `eda_post.html` for CV scores
detail (MASE). The temporary CV predictions are not found because the
they are being ignored on `.gitignore`, it is hard to reproduce all
experiments.

  - Model 1: CV (1.0267), Final LB (0.998)
  - Model 2: CV (1.0186), Final LB (1.034), overfitted (yet zero
    clipping postprocessing can improve, the result might be different
    if we applied it to Model 1)
  - Model 3: CV (1.0905), Final LB (1.051)

<!-- So far, the best baseline model is single LightGBM with lag 3, 4 months.  -->

Previously, we also calculated RMSE to compare result with [Zindi
leaderboard](https://zindi.africa/competitions/usaids-intelligent-forecasting-challenge-model-future-contraceptive-use/leaderboard)

  - LGB Single + Lag 3,4 + Categorical + 1.2 factor –\> **RMSE: 38.33**
  - LGB Single + Lag 3,4 + Categorical –\> **RMSE: 38.72**
  - XGB Multiple + Lag 3 –\> **RMSE: 40.52**
