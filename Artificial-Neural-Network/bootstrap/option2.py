import csv
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import pickle

import time

import sklearn
from sklearn.model_selection import train_test_split, GridSearchCV, KFold, cross_validate
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import MinMaxScaler
from sklearn.preprocessing import PolynomialFeatures

# from sklearn.linear_model import Lasso
from lightgbm import LGBMRegressor
from sklearn.neural_network import MLPRegressor
# from sklearn.svm import SVR

import multiprocessing



if __name__=='__main__':
	main_opt2(df,i)


def main_opt2(df,bootstrapnum:int):

	ncore = multiprocessing.cpu_count()

	#X and y
	y = df['Value']
	X = df.drop(['Value'],axis=1)

	#Train/test split
	X_train, X_test, y_train, y_test = train_test_split(X,y,test_size=0.2, random_state=1111)

	#Data pipelining
	preprocessor = Pipeline(steps=[
		('scaler',MinMaxScaler()),
		('polynom',PolynomialFeatures(2,include_bias=False)) ###########################################33
	])

	regs = [
	     # Lasso(),
	     LGBMRegressor(random_state=1000),
	     MLPRegressor(random_state=2000), #############################################
	     # SVR(),
	]

	pipe_ls = [ Pipeline(steps=[
		('preprocess',preprocessor),
		('reg',regs[i])
		]) for i in range(len(regs))
	]

	gridParams = [
        # {'reg__alpha': [0.0001, 0.01]}, #Lasso
        {'reg__min_data_in_leaf': [100,200], 'reg__num_leaves': [40,80]}, #lightGBM
        {'reg__early_stopping': [True,False], 'reg__hidden_layer_sizes': [(100,),(50,50,)]}, #MLPRegressor ##################################
        # {'reg__C': [1.0,2.0], 'reg__epsilon':[0.1,0.2]} #SVR
	]

	outer_cv = KFold(n_splits=5, shuffle=True, random_state=3333) #Same conditions as Option 1
	inner_cv = KFold(n_splits=5, shuffle=True, random_state=3335)

	grid_ls = [
    	GridSearchCV(pipe_ls[i], gridParams[i], cv=inner_cv, scoring='r2', n_jobs=ncore-1, verbose=10,refit=True) 
    	for i in range(len(regs))
	]

	cv_val_list = []
	cv_score_list = []
	time_list = []
	for i in range(len(regs)):
	    time0 = time.time()
	    cv_val = cross_validate(grid_ls[i],X_train,y_train,scoring='r2',cv=outer_cv,n_jobs=ncore-1,verbose=10, return_estimator=True)
	    cv_val_list += [cv_val]
	    cv_score_list += [cv_val['test_score']]
	    time_list += [time.time()-time0]


	# Store final results
	with open('./bootstrap/output/bootstrap_opt2_'+str(bootstrapnum)+'_cvres.pkl', 'wb') as f:
	    pickle.dump([
	    	cv_val_list,
	    	cv_score_list,
	    	time_list], f)


	# Rerun the best model over the whole training data and get scores.
	meanscore_ls = [l.mean() for l in cv_score_list]
	opt2_best_pipe = Pipeline(steps=[
	                       ('preprocess',preprocessor),
	                       ('reg',regs[meanscore_ls.index(max(meanscore_ls))])
	                       ])
	opt2_best_gridParam = gridParams[meanscore_ls.index(max(meanscore_ls))]
	opt2_best = GridSearchCV(opt2_best_pipe, opt2_best_gridParam, cv=outer_cv, scoring='r2', n_jobs=ncore-1, verbose=10,refit=True)
	opt2_best.fit(X_train,y_train)

	train_score_best = opt2_best.score(X_train,y_train)
	test_score_best = opt2_best.score(X_test,y_test)

	with open('./bootstrap/output/bootstrap_opt2_'+str(bootstrapnum)+'_bestres.pkl', 'wb') as f:
	    pickle.dump([
	    	opt2_best,
	    	train_score_best,
	    	test_score_best], f)

	print('Bootstrapped dataset#',bootstrapnum,'completed.')