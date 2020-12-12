# USAID’s Intelligent Forecasting Submission

### Model Summary

Separate three **LightGBM models** to predict data for t+1, t+2, and t+3

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

* `submission1.csv` average ensemble of all LightGBM model from different seed
* `submission2.csv` same like submission1 but do some postprocessing (overfit)
* `submission3.csv` simpler model, only use lag t-3 and t-4 (underfit)

For co-creation, we reevaluate the performance of the model using RMSSE:

* `submission4-rmsse.csv` use L2 loss, RMSE is better but RMSSE is not better compared to existing model, `submission1.csv`

**Comparison with Traditional Models**

Comparison with traditional statistical forecasting model such as: ARIMA, exponential smoothing, Naive, Linear Regression, etc. LightGBM model outperform traditional models on all CV metrics result.

### Co-Creation Concept Note

Model summary and notes:

* Submission number: 3124523221
* Features engineering is minimalistic: lag (t-1, t-2, t-3, t-4), site, product, district, location (longitude and latitude)
* Training times: 3 minutes (5x training consists of 4x training for CV, 1x for overall), less than a minute for single training. It is very fast, trained on a single machine MBP 13" 2017.
* No change on the final model. We tried to add external variables (district population) however there is no improvement. The model might already learns the pattern from the district categorical feature, so adding district population will be redundant and it does not improve the score at all.
* Robustness of the model
  * Cross-validation, last four quarter metrics (mean; stdev): RMSE (31.26; 5.24), RMSSE (0.68; 0.04), MASE (1.03; 0.06), details: https://docs.google.com/spreadsheets/d/1vSEl9nkIeK331oMe2yxVnscxdBB_gHMS/edit#gid=270085702
  * We can try simulation (as Dejan recommended)
  * We can try input random outliers to the model and evaluate how the forecast behave

Recommendation:

* Develop interval prediction (reference: https://www.kaggle.com/c/m5-forecasting-uncertainty)
* Evaluate forecast evaluation metrics and inventory metrics (weighted evaluation metrics might be considered, e.g. if each site has different importance whether overstock is better than understock or vice versa)
* Need to retrain the model with newest data, it will be more challenging if the pattern of the series changes significantly due to COVID-19. In fact, many patterns of time series data in the world changes significantly due to COVID-19, some demands are getting lower and some demands are getting higher. If we use the existing model that we trained from previous data, the forecast for COVID-19 might be inaccurate. Forecasting is very hard, especially when there is unexpected factors in the future that are unpredictable. 
* Retraining frequency: twice a year / each semester (as Dejan recommended) or four times a year / each quarter

Additional notes:

There are some doubt in machine learning models where in the first until fourth edition of Makrikdakis forecasting competition, most of top models are statistical and combined models. In the fifth edition of Makridakis (M5 competition), most of top models are machine learning models. LightGBM outperforms top statistical method, exponential smoothing, by more than 20% (paper: https://www.researchgate.net/publication/344487258_The_M5_Accuracy_competition_Results_findings_and_conclusions, https://arxiv.org/pdf/2009.07701.pdf). 

Why LightGBM is very superior compared to exponential smoothing and other statistical methods? In the first until fourth edition of Makrikdakis forecasting competition, most of participants were coming from academic background where statistical method is used extensively. The development of machine learning models was still limited, some machine learning models used were SVM, decision tree and Random Forecast. LightGBM is still new (initial release is 2016). It is the first to go and state-of-the-art model for tabular data. It also can be applied to forecasting by doing manual features engineering. One of the reason why LightGBM outperformed exponential smoothing and other statistical methods is because it can learn more features/inputs (e.g. cross-learning and sharing context between different series which are correlated due to same hierarchical structure: product, location, site, etc.). Most of statistical models are trained independently between each series and also have less flexibility in adding more features/inputs to the model compared with LightGBM. In addition, the boosting algorithm itself is superior. 

Deep learning might be good as well for this case. It might be be better if we have more data (deep learning is data hungry). However, due to the complexity and training duration, it is not preferred compared with LightGBM which is faster and easier to be implemented.

### Recommendation

- LightGBM model is very quick and have great accuracy. It outperforms other traditional statistical forecasting model. The next step is to scale the model and implement it on the field.
- To build a better prediction, it is recommended to invest more in data quality. If possible, try to get more granular data (in daily level rather than monthly level) so the action plan based on the forecasting result will be faster. 

### Sharing the Model

The model is free to be shared and published on the other channel.

## Appendix

### How to run

1. Create data/ dir in this project folder, place raw data on data/
2. Create empty data/temp dir to store temporary files generated from the script
3. Cross-validate and generate submissions using `model{}.ipynb`

### Checklists

- [x] The code being submitted was developed in a programming language supported by Jupyter Notebook
- [x] Any critical comments/markups to the code being submitted are included using markdowns cells
- [x] The Jupyter Notebook model package is uploaded (file extension: .ipynb) in the "Prediction and Model Submission" section of the entry form under "Please upload your model from Jupyter Notebook."

### License

Shield: [![CC BY 4.0][cc-by-shield]][cc-by]

This work is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].

[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg

### Contacts

For further details, please can contact me at rasyidstat@gmail.com




