import lightgbm as lgb

def model_lightgbm(df, test_block = 43, verbose = 20, use_log=False, use_weight=False):
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
    
    # Features
    remove_additional_features = ['mase_constant']
    remove_additional_features_selected = list(set(remove_additional_features) & set(df.columns.tolist()))
    all_features = [col for col in list(df) if col not in remove_features + remove_additional_features_selected]
    print(all_features)
    
    train_mask = df['idx']<test_block
    valid_mask = (df['idx'].isin(range(test_block,test_block+3))) & (df['isna'] == False)
    
    if use_weight:
        train_data = lgb.Dataset(df[train_mask][all_features], label=df[train_mask][TARGET], weight=df[train_mask]['mase_constant'])
        valid_data = lgb.Dataset(df[valid_mask][all_features], label=df[valid_mask][TARGET], weight=df[valid_mask]['mase_constant'])
        
    else:
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