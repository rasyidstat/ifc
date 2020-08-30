# Utility function for Python

# Categorical features
categorical_features = ['site_code',
                        'product_code',
                        'region',
                        'district',
                        'site_type',
                        'product_type']
# Remove features
remove_features = ['stock_initial', 'stock_received', 'stock_adjustment', 'stock_distributed',
                   'stock_end', 'average_monthly_consumption', 'stock_stockout_days',
                   'stock_ordered', 'ds', 'isna', 'idx', 'product_name']
# Parameter
TARGET = 'stock_distributed'
SEED = 2020

# Function
def seed_everything(seed=0):
    random.seed(seed)
    np.random.seed(seed)
def rmse(y, y_pred):
    return np.sqrt(np.mean(np.square(y - y_pred)))
def mae(y, y_pred):
    return np.mean(np.abs(y - y_pred))

# Quick function
def process(df, 
			test_block=43, 
			verbose=20, 
		   	use_date=False,
		   	use_log=False,
		   	use_weight=False,
		   	print=False
		   	):

    df = df.copy()
    
    local_params = lgb_params.copy()           
    
    if use_log:
        df[TARGET] = np.log1p(df[TARGET])

    # Categorical feature
    for col in categorical_features:
        try:
            df[col] = df[col].astype('category')
        except:
            pass
    
    # Our features
    all_features = [col for col in list(df) if col not in remove_features]
    print(all_features)
    
    train_mask = df['idx']<test_block
    valid_mask = (df['idx'].isin(range(test_block,test_block+3))) & (df['isna'] == False)
    
    train_data = lgb.Dataset(df[train_mask][all_features], label=df[train_mask][TARGET])
    valid_data = lgb.Dataset(df[valid_mask][all_features], label=df[valid_mask][TARGET])
    
    print('Train time block', df[train_mask]['idx'].min(), df[train_mask]['idx'].max())
    print('Valid time block', df[valid_mask]['idx'].min(), df[valid_mask]['idx'].max())

    temp_df = df[valid_mask]
    del df
    seed_everything(SEED)
    estimator = lgb.train(local_params,
                          train_data,
                          valid_sets = [valid_data],
                          verbose_eval = verbose) 
        
    
    temp_df['preds'] = estimator.predict(temp_df[all_features])
    if use_log:
        temp_df['preds'] = np.expm1(temp_df['preds'])
        temp_df[TARGET] = np.expm1(temp_df[TARGET])
    temp_df = temp_df[['site_code','product_code','idx',TARGET,'preds']]
    return estimator, temp_df