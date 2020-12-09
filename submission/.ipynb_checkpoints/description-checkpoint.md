# Model 1

## Provide a brief, high level summary of the submitted model.

Average ensemble of six LightGBM models to predict `stock_distributed` with separated models for t+1, t+2, and t+3


## Provide the three most important blocks of code from the model. Paste each block below and explain what it does and why it is important to the model. 

ensemble = pd.concat([sub1, sub2, sub3, sub4, sub5, sub6])
ensemble = ensemble.groupby(['site_code','product_code','idx','block']). \
                    agg({'stock_distributed': 'mean', 'preds': 'mean'}).reset_index()

This averaging ensemble is very simple but can potentially improve forecast result 


## How was the model trained (e.g. hyperparameters, training protocols, specialized hardware, etc.)?

- Optimize MSE, not RMSE since the evaluation metric is MASE (MAE divided by a constant)
- Full training using 1000 rounds
- The learning rate is 0.025


## Is there anything that was tried but did not make it into the final submission? If so, please explain briefly. (Optional)

Adding additional categorical variables (month category) or transforming the target value did not improve the result


## Is there anything USAID should know regarding model performance, potential issues or quirks, and/or biases (including, but not limited to gender bias) inherent to the proposed model?

Since the model optimized MAE, the overall aggregated forecast might be lower than the real result. If the decision needs to be made at a higher level (region level) rather than a lower-level (site level), it is better to build a separate model for the aggregated one.
Consider other metrics such as RMSE, or maybe weighted RMSE


## Describe any strengths or limitations to implementing this model in the field.

Strength: quick and have great accuracy, outperforms other traditional statistical forecasting model. The next step is to scale the model and implement it on the field.

Limitation: produce poorer forecast result at a higher level (region, country level)

## If this model is implemented in the field, are there additional recommendations for data, resources, or techniques to try?

- LightGBM model is very quick and have great accuracy. It outperforms other traditional statistical forecasting model. The next step is to scale the model and implement it on the field.
- To build a better prediction, it is recommended to invest more in data quality. If possible, try to get more granular data (in daily level rather than monthly level) so the action plan based on the forecasting result will be faster. 

To build a better prediction, it is recommended to invest more in data quality. If possible, try to get more granular data (in daily level rather than monthly level) so the action plan based on the forecasting result will be faster. 



# Model 2

## Provide a brief, high level summary of the submitted model.

Average ensemble of six LightGBM models to predict `stock_distributed` with separated models for t+1, t+2, and t+3 with additional postprocessing (clip prediction below 0.75 to 0, multiplication factor 1.05, 1.1 and 1.15 for t+1, t+2, and t+3)


## Provide the three most important blocks of code from the model. Paste each block below and explain what it does and why it is important to the model. 

ensemble.assign(preds = factor*np.where(ensemble['preds'] < 0.75, 0, ensemble['preds']))

Clipping prediction to 0 improve forecast result for each cV


## How was the model trained (e.g. hyperparameters, training protocols, specialized hardware, etc.)?

- Optimize MSE, not RMSE since the evaluation metric is MASE (MAE divided by a constant)
- Full training using 1000 rounds
- The learning rate is 0.025


## Is there anything that was tried but did not make it into the final submission? If so, please explain briefly. (Optional)

Adding additional categorical variables (month category) or transforming the target value did not improve the result


## Is there anything USAID should know regarding model performance, potential issues or quirks, and/or biases (including, but not limited to gender bias) inherent to the proposed model?

Since the model optimized MAE, the overall aggregated forecast might be lower than the real result. If the decision needs to be made at a higher level (region level) rather than a lower-level (site level), it is better to build a separate model for the aggregated one.
Consider other metrics such as RMSE, or maybe weighted RMSE


## Describe any strengths or limitations to implementing this model in the field.

Strength: quick and have great accuracy, outperforms other traditional statistical forecasting model. The next step is to scale the model and implement it on the field.

Limitation: produce poorer forecast result at a higher level (region, country level), need to do manual postprocessing

## If this model is implemented in the field, are there additional recommendations for data, resources, or techniques to try?

- LightGBM model is very quick and have great accuracy. It outperforms other traditional statistical forecasting model. The next step is to scale the model and implement it on the field.
- To build a better prediction, it is recommended to invest more in data quality. If possible, try to get more granular data (in daily level rather than monthly level) so the action plan based on the forecasting result will be faster. 

To build a better prediction, it is recommended to invest more in data quality. If possible, try to get more granular data (in daily level rather than monthly level) so the action plan based on the forecasting result will be faster. 



# Model 3

## Provide a brief, high level summary of the submitted model.

Average ensemble of three LightGBM models to predict `stock_distributed`


## Provide the three most important blocks of code from the model. Paste each block below and explain what it does and why it is important to the model. 

ensemble.assign(preds = factor*np.where(ensemble['preds'] < 0.75, 0, ensemble['preds']))

Clipping prediction to 0 improve forecast result for each cV


## How was the model trained (e.g. hyperparameters, training protocols, specialized hardware, etc.)?

- Optimize MSE, not RMSE since the evaluation metric is MASE (MAE divided by a constant)
- Full training using 1000 rounds
- The learning rate is 0.025


## Is there anything that was tried but did not make it into the final submission? If so, please explain briefly. (Optional)

Adding additional categorical variables (month category) or transforming the target value did not improve the result


## Is there anything USAID should know regarding model performance, potential issues or quirks, and/or biases (including, but not limited to gender bias) inherent to the proposed model?

Since the model optimized MAE, the overall aggregated forecast might be lower than the real result. If the decision needs to be made at a higher level (region level) rather than a lower-level (site level), it is better to build a separate model for the aggregated one.
Consider other metrics such as RMSE, or maybe weighted RMSE


## Describe any strengths or limitations to implementing this model in the field.

Strength: very quick and have great accuracy, outperforms other traditional statistical forecasting model. The next step is to scale the model and implement it on the field.

Limitation: produce poorer forecast result at a higher level (region, country level), need to do manual postprocessing

## If this model is implemented in the field, are there additional recommendations for data, resources, or techniques to try?

- LightGBM model is very quick and have great accuracy. It outperforms other traditional statistical forecasting model. The next step is to scale the model and implement it on the field.
- To build a better prediction, it is recommended to invest more in data quality. If possible, try to get more granular data (in daily level rather than monthly level) so the action plan based on the forecasting result will be faster. 

To build a better prediction, it is recommended to invest more in data quality. If possible, try to get more granular data (in daily level rather than monthly level) so the action plan based on the forecasting result will be faster. 