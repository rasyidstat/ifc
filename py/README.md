# USAID’s Intelligent Forecasting Submission

## Model Summary

* Model: separate three LightGBM models to predict stock distributed for t+1, t+2, and t+3
* Cross-validation: 4x time series CV
  * Block 43: Jul-Sep 2019
  * Block 40: Apr-Jun 2019
  * Block 37: Jan-Mar 2019
  * Block 34: Oct-Dec 2018
* Features engineering
  * Lag t-1, t-2, t-3, t-4
  * Longitude, latitude
  * Categorical features: product, region, type
* Modeling
  * Optimize MSE directly, not RMSE since the evaluationn metrics is MASE (MAE divided by a constant)
  * Full training using 1000 rounds
  * Learning rate is 0.025

There are three submissions generated:

* Submission-1: best LightGBM model based on CV mean and standard deviation
* Submission-2: average ensemble of all LightGBM model from different seed
* Submission-3: LightGBM model combination with traditional models

## Comparison with Traditional Models

Comparison with traditional statistical forecasting model such as: ARIMA, exponential smoothing, Naive and Linear Regression. LightGBM model outperform traditional models on all CV metrics result.

## Recommendation

To build a better model, we also need better data quality.

- Reduce missing values on the dataset
- Have more granular data, in daily level rather than monthly level

## Checklists

- [x] The code being submitted was developed in a programming language supported by Jupyter Notebook
- [x] Any critical comments/markups to the code being submitted are included using markdowns cells
- [x] The Jupyter Notebook model package is uploaded (file extension: .ipynb) in the "P​rediction and Model Submission" ​section of the entry form under "​Please upload your model from Jupyter Notebook."

## License

Shield: [![CC BY 4.0][cc-by-shield]][cc-by]

This work is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].

[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg

## Contacts

For further details, please can contact me at rasyidstat@gmail.com




