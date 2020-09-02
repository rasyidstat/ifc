import numpy as np

def seed_everything(seed=0):
    random.seed(seed)
    np.random.seed(seed)
    
def rmse(y, y_pred):
    return np.sqrt(np.mean(np.square(y - y_pred)))

def mae(y, y_pred):
    return np.mean(np.abs(y - y_pred))

def mase_df(pred_df, clip_lower = True, factor = 1):
    pred_df = pred_df.copy()
    pred_df = pd.merge(pred_df, df[['site_code', 'product_code', 'idx', 'mase_constant']])
    if clip_lower:
        pred_df[['preds']] = pred_df[['preds']].clip(lower = 0)
    pred_df[['preds']] = pred_df[['preds']] * factor
    pred_df['scaled_error'] = abs(pred_df['stock_distributed'] - pred_df['preds']) * pred_df['mase_constant']
    mase = pred_df.groupby(['site_code', 'product_code'])['scaled_error'].agg(lambda x: x.mean()).mean()
    return(mase)

def mae_row(pred_df, clip_lower = True, factor = 1):
    pred_df = pred_df.copy()
    if clip_lower:
        pred_df[['preds']] = pred_df[['preds']].clip(lower = 0)
    pred_df[['preds']] = pred_df[['preds']] * factor
    return(mae(pred_df.preds, pred_df.stock_distributed))