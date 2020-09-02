import feather
import pandas as pd

def read_data(features = [TARGET]):
    df = pd.read_feather('../input/ifc-dataset/ifc_clean.feather')
    df[features] = df[features].fillna(0)
    print('Read data, data frame size: {}'.format(df.shape))
    return df

def generate_lag_features(df, lag = [3,4], features = [TARGET]):
    df = df.assign(**{
            '{}_lag_{}'.format(col, l): df.groupby(['site_code', 'product_code'])[col].transform(lambda x: x.shift(l))
            for l in lag
            for col in features
         })
    lag_features = [col for col in df.columns if 'lag' in col]
    df = df.dropna(subset = lag_features)
    print('Generate lag features {}, data frame size: {}'.format(lag, df.shape))
    return df 

def generate_id(df):
    df['id'] = df['site_code'] + '-' + df['product_code']
    df['id'] = df['id'].astype('category')
    print('Generate ID features')
    return df

def generate_date_features(df, use_month = True, use_quarter = False, use_year = False, use_category = True):
    '''
    Generate date features as category or integer, consists of:
    month, quarter and year
    '''
    if use_month:
        df['month'] = pd.to_datetime(df['ds']).dt.month
    if use_quarter:
        df['quarter'] = pd.to_datetime(df['ds']).dt.quarter
    if use_year:
        df['year'] = pd.to_datetime(df['ds']).dt.year
    date_features = df.filter(regex = '^(month|quarter|year)$').columns.tolist()
    if use_category:
        df[date_features] = df[date_features].astype('category')
    print('Generate date features {}'.format(date_features))
    return df

def generate_diff_features(df):
    lag_features = [col for col in df.columns if 'lag' in col]
    for i,j in combinations(lag_features, 2):
        df['{}_minus_{}'.format(i, j)] = df[i] - df[j]
    print('Generate diff features')
    return(df)
    
def generate_ratio_features(df):
    lag_features = [col for col in df.columns if 'lag' in col]
    for i,j in combinations(lag_features, 2):
        df['{}_div_{}'.format(i, j)] = (df[i] / df[j]).fillna(0)
    print('Generate ratio features')
    return(df)

def get_day_in_month(df):
    df['day_in_month'] = pd.to_datetime(df['ds']).dt.daysinmonth
    print('Get days in month')
    return(df)

def get_cumulative_nonzero(df):
    '''
    This function needs to be used before any data removal 
    because of lagging or rolling features.
    Exclude first NA or zero data by df.loc[df['isna_int'] > 0] or df.loc[df['iszero_int'] > 0].shape
    '''
    df['isna_int'] = [0 if x == True else 1 for x in df['isna']]
    df['iszero_int'] = [0 if x == 0 else 1 for x in df['stock_distributed']]
    df[['isna_int', 'iszero_int']] = df.groupby(['site_code', 'product_code'])[['isna_int', 'iszero_int']].transform(lambda x: x.cumsum())
    print('Get cumulative nonzero flag')
    return(df)

def get_mase_constant(df, test_block = 46, remove_first_na = True, remove_first_zero = False):
    '''
    This function needs to be used by applying `get_cumulative_nonzero` 
    to exclude first NA or zero data.
    It also needs to be used before any data removal
    The default test_block is 46 ( data) which will be used as the  (43 for latest CV)
    constant of the mase denominator for each series.
    In default, remove first NA data from the training set
    '''
    df['diff_abs'] = df.loc[(df['isna_int'] > 0) & (df['idx'] < test_block)].groupby(['site_code', 'product_code'])['stock_distributed'].transform(lambda x: abs(x-x.shift(1)))
    df['mase_constant'] = df.groupby(['site_code', 'product_code'])['diff_abs'].transform(lambda x: x.mean())
    df['mase_constant'] = 1 / df['mase_constant']
    df['mase_constant'] = df['mase_constant'].replace(np.inf, 0).replace(np.nan, 0)
    print('Get MASE constant')
    return(df)

def remove_unnecessary_columns(df, column_list = []):
    column_list_all = ['isna_int','iszero_int','diff_abs'] + column_list
    column_list_selected = list(set(column_list_all) & set(df.columns.tolist()))
    df = df.drop(column_list_selected, axis = 1)
    print('Remove unnecessary columns')
    return(df)