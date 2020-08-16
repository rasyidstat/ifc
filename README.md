ifc
================

USAID’s Intelligent Forecasting: Model Future Contraceptive Use

## Data

Source:
[Kaggle](https://www.kaggle.com/darisdzakwanhoesien2/usaids-model-future-contraceptive-use)

  - 156 sites
  - 11 products
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

8 times CV (moving monthly)

  - Jan - Mar 2019 (CV 4) OK
  - Feb - Apr 2019 (CV 3.1)
  - March - May 2019 (CV 3)
  - April - Jun 2019 (CV 2.1) OK
  - May - Jul 2019 (CV 2)
  - Jun - Aug 2019 (CV 1.1)
  - Jul - Sep 2019 (CV 1) OK
  - Oct - Dec 2018 (CV 5) OK

## Tasks

  - \[x\] EDA: MVP
  - \[x\] EDA: Check data completeness
  - \[x\] EDA: Deep EDA
  - \[x\] EDA: Post EDA prediction result and evaluationn
  - \[x\] Modeling: MVP (baseline)
  - \[x\] Modeling: single model (tree models, [LightGBM
    baseline](https://www.kaggle.com/rasyidstat/ifc-lightgbm-baseline))
  - \[ \] Clustering + re-EDA
  - \[ \] Modeling: separate model for each lag
  - \[ \] Features engineering: neighborhood features
  - \[x\] Postprocessing: factor multiplication (between 1.05-1.20, tree
    models cannot get the trend)
  - \[ \] External Data

## Baseline Result

So far, the best baseline model is single LightGBM with lag 3, 4 months.

| Method     | MAE CV-1 | MAE (4-CV)    | MAE (8-CV)    |
| :--------- | :------- | :------------ | :------------ |
| LightGBM   | 10.14    | 10.59 (±0.38) | 10.62 (±0.40) |
| ETS        | 10.88    | 11.39 (±0.98) | 11.17 (±0.72) |
| ARIMA      | 11.00    | 11.17 (±0.67) | 11.33 (±0.54) |
| XGBoost    | 11.51    | 11.46 (±0.70) | 11.41 (±0.54) |
| Regression | 11.71    | 11.78 (±0.64) | 11.67 (±0.51) |
| Naive      | 11.88    | 12.30 (±0.96) | 12.07 (±0.73) |
| SNaive     | 12.00    | 12.36 (±0.61) | 12.27 (±0.44) |

Also, we calculate RMSE to compare result with [Zindi
leaderboard](https://zindi.africa/competitions/usaids-intelligent-forecasting-challenge-model-future-contraceptive-use/leaderboard)

  - LGB Single + Lag 3,4 + Categorical + 1.2 factor –\> **RMSE: 38.33**
  - LGB Single + Lag 3,4 + Categorical –\> **RMSE: 38.72**
  - XGB Multiple + Lag 3 –\> **RMSE: 40.52**
