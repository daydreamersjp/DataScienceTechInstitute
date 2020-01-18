/************************************************************************/
/*  Subject: SAS Code For DSTI S19 Time-series Analysis Final Project   */
/*  Submitted by: Motoharu DEI                                          */
/*  Submission Date: January 18th, 2020                                 */
/************************************************************************/


/**********************************
************* PART 1 *************
**********************************/

libname p1 'C:\Users\VM\Desktop\DSTI_SAS_MATERIALS\finalProject\SAS ETS Evaluation - Data-20180912';

/***********
1. You receive the SAS data set E1 from a colleague. Represent with a graph the timeseries and
identify and estimate an appropriate model to fit the data. Justify your choice. (2 points)
***********/

* Graph of the time series data;
ods excel file="p1-1.xlsx";
ods graphics on;

proc sgplot data=p1.e1;
	series x=date y=y;
run;

* ADF tests;
proc arima data=p1.e1;
	identify var=y stationarity=(adf=(0 1 2 3));
	estimate method=ml;
quit;
/*
Apparently, the data is not zero mean. Otherwise, most p-values are small, meaning non-stationarity hypothesis (H0) was rejected.

Here, the p-values for Ljung-Box test is very low, meaning there exists auto correlation.
PACF's trend is not evident but IACF has clearly exponential decreasing trend.
ACF is zero after t=2. Therefore, this is assumed to be AR(2) model. 
*/

* MA(2) model;
proc arima data=p1.e1;
	identify var=y;
	estimate q=2 method=ml;
quit;

ods graphics off;
ods excel close;
/*
Here, with MA(2) model, p-value for Ljung-Box test is high and ACF and PACF are zero-outed.
*/


/***********
2. Identify and estimate a relevant model for the variable Y in the SAS data set E2. You will use
the Maximum Likelihood estimation method to obtain your model. Explain how you have
decided which model to select. (2 points)
***********/

ods excel file="p1-2.xlsx";
ods graphics on;

* Graph of the time series data;
proc sgplot data=p1.e2;
	series x=date y=y;
run;

* ADF tests;
proc arima data=p1.e2;
	identify var=y stationarity=(adf=(0 1 2 3));
	estimate method=ml;
quit;
/*
Appearently, the data is not zero mean. Otherwise, most p-values are small, meaning non-stationarity hypothesit (H0) was rejected.
*/

* Parameter estimateionby ESACF, SCAN, MINIC;
proc arima data=p1.e2;
	identify var=y esacf p=(0:12) q=(0:12);
	estimate method=ml;
quit;
/*
ARMA(p+d,q)
Tentative
Order Selection
Tests 
ESACF 
p+d q 
0 4 
8 4 
9 3 
6 6 
4 7 
5 7 
11 3 
12 2 
*/

proc arima data=p1.e2;
	identify var=y scan p=(0:12) q=(0:12);
	estimate method=ml;
quit;
/*
ARMA(p+d,q)
Tentative
Order Selection
Tests 
SCAN 
p+d q 
2 1 
3 0 
0 3 
*/

proc arima data=p1.e2;
	identify var=y minic p=(0:12) q=(0:12);
	estimate method=ml;
quit;
/*
Minimum Table Value: BIC(3,0) = -4.85277
*/

/*
Through three estimations, I will check following four options:
0 4
2 1 
3 0 
0 3 
*/ 
proc arima data=p1.e2;
	identify var=y;
	estimate p=0 q=4 method=ml;
quit;
*AIC=-368.205. Ljung-Box test's p-values are high. Correlation graphs look good.;
proc arima data=p1.e2;
	identify var=y;
	estimate p=2 q=1 method=ml;
quit;
*AIC=-372.378. Ljung-Box test's p-values are high. Correlation graphs look good.;
proc arima data=p1.e2;
	identify var=y;
	estimate p=3 q=0 method=ml;
quit;
*AIC=-366.918. Ljung-Box test's p-values are high. Correlation graphs look good, but white noise prob may be low.;
proc arima data=p1.e2;
	identify var=y;
	estimate p=0 q=3 method=ml;
quit;
*AIC=-365.058. Ljung-Box test's p-values are high but some are close to 5%. Correlation graphs look good, but white noise prob may be low.;

/*
Then, I would choose ARMA(2,1) for lowest AIC and other good looking plots.
*/

ods graphics off;
ods excel close;


/*
3. Perform the Ljung-Box White Noise Probability test on the variable PercentUnemployed in
the SAS data set E3. You should give the null and alternative hypothesis. What can you
conclude from this test? (2 points)
*/

ods excel file="p1-3.xlsx";
ods graphics on;

* Graph of the time series data;
proc sgplot data=p1.e3;
	series x=date y=PercentUnemployed;
run;

* Diagnosis including Ljung-Box test;
proc arima data=p1.e3;
	identify var=PercentUnemployed;
	estimate method=ml;
quit;
/*
p-value is small and there exists autocorrelation.
*/

ods graphics off;
ods excel close;

/*
4. Using the PROC ESM in SAS, generate a forecast for the next 12 periods for the variable
Biscuits in the SAS data set E4 with the model of your choice. Justify your choice. (2 points)
*/

ods excel file="p1-4.xlsx";
ods graphics on;

* Graph of the time series data;
proc sgplot data=p1.e4;
	series x=date y=Biscuits;
run;

/*proc timeseries data=p1.e4 plot=(series corr acf pacf iacf wn decomp tc sc)  seasonality=12; */
/*	id date interval=week; */
/*	var Biscuits; */
/*	decomp; */
/*run;*/
/*
The data has no trend nor yearly seasonality. Funnel effect was not observed. No outstanding outlier observed.
But the data has strong cyclic movement where cycle length=3 or 4.
*/

/*
Start from double ESM, additive Holf-Winter with cycle=3or4, and multicative Holf-Winter with cycle=3or4.
*/
proc esm data=p1.e4 lead=12 plot=forecasts;
	id date interval=week;
	forecast Biscuits / model=double; 
run;
proc esm data=p1.e4 lead=12 plot=forecasts seasonality=3;
	id date interval=week;
	forecast Biscuits / model=addwinters; 
run;
proc esm data=p1.e4 lead=12 plot=forecasts seasonality=4;
	id date interval=week;
	forecast Biscuits / model=addwinters; 
run;
proc esm data=p1.e4 lead=12 plot=forecasts seasonality=3;
	id date interval=week;
	forecast Biscuits / model=winters; 
run;
proc esm data=p1.e4 lead=12 plot=forecasts seasonality=4;
	id date interval=week;
	forecast Biscuits / model=winters; 
run;


/*
Hold-out validation.
Fold1 - training: January to June, test: July to December
Fold2 - training: January to July, test: August to December 
Fold3 - training: January to August, test: September to December
Fold4 - training: January to September, test: October to December
Fold5 - training: January to October, test: November to December
Fold6 - training: January to November, test: December
*/
data tr1 te1; set p1.e4;
	if month(date)<=6 then output tr1;
	else output te1;
run;
data tr2 te2; set p1.e4;
	if month(date)<=7 then output tr2;
	else output te2;
run;
data tr3 te3; set p1.e4;
	if month(date)<=8 then output tr3;
	else output te3;
run;
data tr4 te4; set p1.e4;
	if month(date)<=9 then output tr4;
	else output te4;
run;
data tr5 te5; set p1.e4;
	if month(date)<=10 then output tr5;
	else output te5;
run;
data tr6 te6; set p1.e4;
	if month(date)<=11 then output tr6;
	else output te6;
run;

%MACRO calMse(num,model,seasonality,out); 
	proc esm data=tr&num. lead=30 plot=forecasts outfor=pred seasonality=&seasonality.;
		id date interval=week;
		forecast Biscuits / model=&model.; 
	run;
	data temp1; 
		merge te&num.(IN=t1 keep=date biscuits) pred(IN=t2 keep=date predict); 
		by date; 
		if t1 and t2; 
		MSE_&model.&seasonality. = (biscuits - predict) ** 2;
		MAE_&model.&seasonality. = abs(biscuits - predict);
	run;
	proc means data=temp1 noprint;
		var mae_&model.&seasonality. ; /* Despite the macro name, note I chose MAE, not MSE in the end. */
		output out=&out. mean=; 
	run;
%MEND calMse;

%calMse(1,double,1,mse1_1);
%calMse(2,double,1,mse1_2);
%calMse(3,double,1,mse1_3);
%calMse(4,double,1,mse1_4);
%calMse(5,double,1,mse1_5);
%calMse(6,double,1,mse1_6);
data mse1; set mse1_1 mse1_2 mse1_3 mse1_4 mse1_5 mse1_6; run; 
%calMse(1,addwinters,3,mse2_1);
%calMse(2,addwinters,3,mse2_2);
%calMse(3,addwinters,3,mse2_3);
%calMse(4,addwinters,3,mse2_4);
%calMse(5,addwinters,3,mse2_5);
%calMse(6,addwinters,3,mse2_6);
data mse2; set mse2_1 mse2_2 mse2_3 mse2_4 mse2_5 mse2_6; run; 
%calMse(1,addwinters,4,mse3_1);
%calMse(2,addwinters,4,mse3_2);
%calMse(3,addwinters,4,mse3_3);
%calMse(4,addwinters,4,mse3_4);
%calMse(5,addwinters,4,mse3_5);
%calMse(6,addwinters,4,mse3_6);
data mse3; set mse3_1 mse3_2 mse3_3 mse3_4 mse3_5 mse3_6; run; 
%calMse(1,winters,3,mse4_1);
%calMse(2,winters,3,mse4_2);
%calMse(3,winters,3,mse4_3);
%calMse(4,winters,3,mse4_4);
%calMse(5,winters,3,mse4_5);
%calMse(6,winters,3,mse4_6);
data mse4; set mse4_1 mse4_2 mse4_3 mse4_4 mse4_5 mse4_6; run; 
%calMse(1,winters,4,mse5_1);
%calMse(2,winters,4,mse5_2);
%calMse(3,winters,4,mse5_3);
%calMse(4,winters,4,mse5_4);
%calMse(5,winters,4,mse5_5);
%calMse(6,winters,4,mse5_6);
data mse5; set mse5_1 mse5_2 mse5_3 mse5_4 mse5_5 mse5_6; run;
data mse; merge mse1 mse2 mse3 mse4 mse5; run;
proc means data=mse(drop=_type_ _freq_); run;
/*
Double ESM gave the least average MAE. Therefore I will choose simple method.
*/

* Final prediction;
proc esm data=p1.e4 lead=12 plot=forecasts;
	id date interval=week;
	forecast Biscuits / model=double; 
run;

ods graphics off;
ods excel close;



/**********************************
************* PART 2 *************
**********************************/

/*
The Sales department asked you to provide a statistical forecast for 3 key products for the next 16
months (last forecast in December 2019). You managed to extract the relevant data in the file
DSTI_SAS_ETS_Evaluation_Part2.csv.
Using all what you have learned in Times Series in SAS, generate a forecast for the 3 different
products. You will explain all the steps you have followed to choose the models and you will write a
quick report for the Sales department to understand the sales evolution of these products.
*/

* data import and preprocessing;
data WORK.P2_0    ;
	%let _EFIERR_ = 0; /* set the ERROR detection macro variable */
	infile 'C:\Users\VM\Desktop\DSTI_SAS_MATERIALS\finalProject\SAS ETS Evaluation_cours - Data-20181025_part2\DSTI_SAS_ETS_Evaluation_Part2.csv' delimiter = ';' MISSOVER DSD lrecl=32767 firstobs=2 ;
	informat 
		Product_Reference $16.
		Date $16.
		Sales_Quantity 16. ;
	format 
		Product_Reference $16.
		Date $16.
		Sales_Quantity 16. ;
	input
		Product_Reference $
		Date $
		Sales_Quantity ;
run;

proc format; value $monconv
	'JAN' = 1
	'FEB' = 2
	'MAR' = 3
	'APR' = 4
	'MAY' = 5
	'JUN' = 6
	'JUL' = 7
	'AUG' = 8
	'SEP' = 9
	'OCT' = 10
	'NOV' = 11
	'DEC' = 12
	;
run;

data p2; set p2_0;
	length date1 8. date2 8.;
	format date3 date9.;
	date1 = put(substr(date,1,3), $monconv.);
	date2 = substr(date,5,8);
	date3 = mdy(date1,1,date2);
	drop date date1 date2;
	rename date3 = Date; 
run;

libname p2 'C:\Users\VM\Desktop\DSTI_SAS_MATERIALS\finalProject\SAS ETS Evaluation_cours - Data-20181025_part2';
data p2.p2; retain product_reference date Sales_Quantity; set p2; run;

* Plot data;
data p2; set p2.p2; log_sales_quantity = log(sales_quantity); proc sort; by product_reference date; run;

ods excel file="p2-1.xlsx";
ods graphics on;
proc sgplot data=p2;
	series x=date y=Sales_Quantity;
	by product_reference;
run;
ods excel close;

** Log transformed for ESA154;
ods excel file="p2-1-log.xlsx";
proc sgplot data=p2;
	series x=date y=log_Sales_Quantity;
	by product_reference;
run;
ods excel close;

* FR01: seasonality + spikes;
* ESA154: log-transform + spike + seasonablity ;
* WW01AA: seasonality + spikes + temporary change for 12 months OR shift change;

* Data slice;
data p2_1; set p2; where product_reference='FR001'; run;
data p2_2; set p2; where product_reference='ESA154'; run;
data p2_3; set p2; where product_reference='WW01AA'; run;
* p2_3 has missing value;
data temp1;
	date="01SEP2015"d;
	do while (date<="01AUG2018"d);
	    output;
		date=intnx('month', date, 1, 's');
	end;
	format date date9.;
run;
data p2_3; merge p2_3 temp1; by date; proc sort; by date; run;
data p2_3; set p2_3;
	if date='01JAN2016'd then sales_Quantity=(10+7)/2;
	if date='01JUL2016'd then sales_Quantity=(2+200)/2;
	if date='01SEP2016'd then sales_Quantity=(200+712)/2;
	log_sales_Quantity=log(sales_Quantity);
run;

data p2.p2_1; set p2_1; run;
data p2.p2_2; set p2_2; run;
data p2.p2_3; set p2_3; run;
/*data p2_1; set p2.p2_1; run;*/
/*data p2_2; set p2.p2_2; run;*/
/*data p2_3; set p2.p2_3; run;*/

ods excel file="p2-3.xlsx";
proc sgplot data=p2_3;
	series x=date y=Sales_Quantity;
run;
ods excel off;


/************** FR001 **************/
* Detect outliers; 
** FR001;
proc arima data=p2_1 plots=all;
	by product_reference;
	identify var=sales_quantity;
	estimate;
	outlier type=(ao ls) maxnum=7 id=date; 
	* Number of outliers (=7) was found by checking maxnum=5 first and added two from examining the results;
quit;
/*Outlier Details */
/*Obs Time ID Type Estimate Chi-Square Approx Prob>ChiSq */
/*2 01-OCT-2015 Additive 76611.0 7.85 0.0051 */
/*1 01-SEP-2015 Additive 71259.0 7.47 0.0063 */
/*28 01-DEC-2017 Shift -19465.4 5.74 0.0166 */
/*26 01-OCT-2017 Additive 47134.0 6.56 0.0104 */
/*13 01-SEP-2016 Additive 44487.0 10.31 0.0013 */
/*14 01-OCT-2016 Additive 41251.0 11.08 0.0009 */
/*6 01-FEB-2016 Additive -40327.0 10.72 0.0011 */

*** Adjust outliers and pattern identification;
data p2_1_adj; set p2_1;
	sales_quantity_adj=sales_quantity;
	v1=0; if date='01OCT2015'd then do; sales_quantity_adj=sales_quantity_adj-76611.0; v1=1; end;
	v2=0; if date='01SEP2015'd then do; sales_quantity_adj=sales_quantity_adj-71259.0; v2=1; end;
	v3=0; if date='01OCT2017'd then do; sales_quantity_adj=sales_quantity_adj-47134.0; v3=1; end;
	v4=0; if date='01SEP2016'd then do; sales_quantity_adj=sales_quantity_adj-44487.0; v4=1; end;
	v5=0; if date='01OCT2016'd then do; sales_quantity_adj=sales_quantity_adj-41251.0; v5=1; end;
	v6=0; if date='01FEB2016'd then do; sales_quantity_adj=sales_quantity_adj+40327.0; v6=1; end;
	v7=0; if date<'01DEC2017'd then do; sales_quantity_adj=sales_quantity_adj-19465.4; v7=1; end;
run;
proc sgplot data=p2_1_adj;
	series x=date y=Sales_Quantity_adj;
run;
proc timeseries data=p2_1_adj plot=(series corr acf pacf iacf wn decomp tc sc) seasonality=12; 
	id date interval=month; 
	var sales_quantity_adj; 
	decomp / mode=add; 
run;
/*There was a strong seasonality and a weak trend.*/

data p2_1_adj; set p2_1_adj;
	by product_reference;
	seq+1;
run;
data p2_1_adj_modeling; set p2_1_adj;
	sales_quantity_model = sales_quantity;
	sales_quantity_adj_model = sales_quantity_adj;
	if date>='01JAN2018'd then do; sales_quantity_model = .; sales_quantity_adj_model = .; end;
run;
/*data p2_1_adj_train p2_1_adj_test; set p2_1_adj;*/
/*	if date<'01JAN2018'd then output p2_1_adj_train;*/
/*	else output p2_1_adj_test;*/
/*run;*/
proc arima data=p2_1_adj_modeling plot=all;
	identify var=sales_quantity_model(12) crosscorr=(v3 v4 v5 v7) stationarity=(adf=(0 1 2 3)); 
	estimate input=(v3 v4 v5 v7) method=ml;
	forecast lead=8 id=date interval=month out=resout1;
run;quit;
/*ADF test looks good.*/
/*White noise looks fine.*/

* Outliers + deterministic trend + seasonality;
/*proc arima data=p2_1_adj_modeling plot=all;*/
/*	identify var=sales_quantity_model(12) crosscorr=(v3 v4 v5 v7 seq) stationarity=(adf=(0 1 2 3)); */
/*	estimate input=(v3 v4 v5 v7 seq) method=ml;*/
/*	forecast lead=8 id=date interval=month out=resout2;*/
/*run;quit;*/
/*ADF test looks good.*/
/*White noise looks fine.*/
proc arima data=p2_1_adj_modeling plot=all;
	identify var=sales_quantity_model(12) crosscorr=(seq) stationarity=(adf=(0 1 2 3)); 
	estimate input=(seq) method=ml;
	forecast lead=8 id=date interval=month out=resout3;
run;quit;
/*ADF test looks good.*/
/*White noise looks fine.*/

* Stochastic trend + seasonality;
proc arima data=p2_1_adj_modeling plot=all;
	identify var=sales_quantity_model(1 12) stationarity=(adf=(0 1 2 3)); 
	estimate method=ml;
	forecast lead=8 id=date interval=month out=resout4;
run;quit;
/*ADF test looks good.*/
/*White noise looks fine.*/

* Exponential Smoothing;
proc esm data=P2_1_ADJ_MODELING lead=0 plot=forecasts out=resout5;
	id date interval=month;
	forecast sales_quantity_adj_model / model=ADDWINTERS; 
run;
data resout5; merge
	resout5(keep=date sales_quantity_adj_model rename=(sales_quantity_adj_model=forecast))
	P2_1_ADJ_MODELING(keep=date sales_quantity)
	;
	by date;
run;

* Validation score by MAE;
%MACRO MAE(num);
	data temp1; merge 
		p2_1_adj(keep=date sales_quantity where=(date>='01JAN2018'd)) 
		resout&num.(keep=date forecast where=(date>='01JAN2018'd))
		;
		by date;
		dummy = 1;
		AE = abs(sales_quantity-forecast);
	run;
	proc means data=temp1; var AE; run;
%MEND MAE;
%MAE(1);
/*%MAE(2);*/
%MAE(3);
%MAE(4);
%MAE(5);
* Exponential Smoothing was the best one;

* Final forecast;
proc esm data=P2_1_ADJ_MODELING lead=16 plot=forecasts out=forecast_final1;
	id date interval=month;
	forecast sales_quantity_adj / model=ADDWINTERS; 
run;
data forecast_final1; set 
	p2_1(keep=date sales_quantity) 
	forecast_final1(keep=date sales_quantity_adj where=(date>='01SEP2018'd) rename=(sales_quantity_adj=sales_quantity)); 
run;
proc sgplot data=forecast_final1;
	series x=date y=Sales_Quantity;
run;


/************** ESA154 **************/
** ESA154 (Log transformed sales);
proc arima data=p2_2 plots=all;
	by product_reference;
	identify var=log_sales_quantity;
	estimate;
	outlier type=(ao ls) maxnum=5 id=date; 
	* Number of outliers (=7) was found by checking maxnum=5 first and added two from examining the results;
quit;
/*Outlier Details */
/*Obs Time ID Type Estimate Chi-Square Approx Prob>ChiSq */
/*4 01-DEC-2015 Additive 0.57532 5.31 0.0212 */
/*27 01-NOV-2017 Additive 0.55924 5.11 0.0238 */
data p2_2_adj; set p2_2;
	log_sales_quantity_adj=log_sales_quantity;
	v1=0; if date='01DEC2015'd then do; log_sales_quantity_adj=log_sales_quantity_adj-0.57532; v1=1; end;
	v2=0; if date='01NOV2017'd then do; log_sales_quantity_adj=log_sales_quantity_adj-0.55924; v2=1; end;
run;
proc sgplot data=p2_2_adj;
	series x=date y=log_Sales_Quantity_adj;
run;
proc timeseries data=p2_2_adj plot=(series corr acf pacf iacf wn decomp tc sc) seasonality=12; 
	id date interval=month; 
	var log_sales_quantity_adj; 
	decomp / mode=add; 
run;
/*There were week seasonality and trend.*/

data p2_2_adj_modeling; set p2_2_adj;
	log_sales_quantity_model = log_sales_quantity;
	log_sales_quantity_adj_model = log_sales_quantity_adj;
	if date>='01JAN2018'd then log_sales_quantity_model = .;
	if date>='01JAN2018'd then log_sales_quantity_adj_model = .;
run;
/*proc arima data=p2_2_adj_modeling plot=all;*/
/*	identify var=log_sales_quantity_model(12) crosscorr=(v1 v2) stationarity=(adf=(0 1 2 3)); */
/*	estimate input=(v1 v2) method=ml;*/
/*	forecast lead=8 id=date interval=month out=resout1;*/
/*run;quit;*/
proc arima data=p2_2_adj_modeling plot=all;
	identify var=log_sales_quantity_model(12) stationarity=(adf=(0 1 2 3)); 
	estimate method=ml;
	forecast lead=8 id=date interval=month out=resout2;
run;quit;
proc arima data=p2_2_adj_modeling plot=all;
	identify var=log_sales_quantity_model(2 12) stationarity=(adf=(0 1 2 3)); 
	estimate method=ml;
	forecast lead=8 id=date interval=month out=resout3;
run;quit;
proc esm data=P2_2_ADJ_MODELING lead=0 plot=forecasts out=resout4;
	id date interval=month;
	forecast log_sales_quantity_adj_model / model=SEASONAL; 
run;
data resout4; merge
	resout4(keep=date log_sales_quantity_adj_model rename=(log_sales_quantity_adj_model=forecast))
	P2_2_ADJ_MODELING(keep=date log_sales_quantity)
	;
	by date;
run;
* Validation score by MAE;
%MACRO MAE(num);
	data temp1; merge 
		p2_2_adj(keep=date log_sales_quantity where=(date>='01JAN2018'd)) 
		resout&num.(keep=date forecast where=(date>='01JAN2018'd))
		;
		by date;
		dummy = 1;
		AE = abs(log_sales_quantity-forecast);
	run;
	proc means data=temp1; var AE; run;
%MEND MAE;
/*%MAE(1);*/
%MAE(2);
%MAE(3);
%MAE(4);
* Differencing (12) was the best one;

* Final forecast;
data temp1;
	date="01SEP2015"d;
	do while (date<="01DEC2019"d);
	    output;
		date=intnx('month', date, 1, 's');
	end;
	format date date9.;
run;
data p2_2_final; merge temp1 p2_2_adj_modeling; by date; run;
proc arima data=p2_2_final plot=all;
	identify var=log_sales_quantity(12); 
	estimate method=ml;
	forecast lead=16 id=date interval=month out=forecast_final2;
run;quit;
data forecast_final2; set forecast_final2;
	if log_sales_quantity ne . then sales_quantity = exp(log_sales_quantity);
	else sales_quantity = exp(forecast);
run;
proc sgplot data=forecast_final2;
	series x=date y=Sales_Quantity;
run;


/************** WW01AA **************/
proc arima data=p2_3 plots=all;
	identify var=sales_quantity;
	estimate;
	outlier type=(ao ls tc(12)) maxnum=5 id=date; 
	* Number of outliers (=7) was found by checking maxnum=5 first and added two from examining the results;
quit;
/*Outlier Details */
/*Obs Time ID Type Estimate Chi-Square Approx Prob>ChiSq */
/*2 01-OCT-2015 Additive 4912.4 17.57 <.0001 */
/*3 01-NOV-2015 Temp(12) -921.77778 7.80 0.0052 */
/*27 01-NOV-2017 Additive 2400.4 15.42 <.0001 */
/*15 01-NOV-2016 Temp(12) 526.76389 12.00 0.0005 */
/*1 01-SEP-2015 Additive -1210.6 6.34 0.0118 */

data p2_3_adj; set p2_3;
	sales_quantity_adj=sales_quantity;
	v1=0; if date='01OCT2015'd then do; sales_quantity_adj=sales_quantity_adj-4912.4; v1=1; end;
	v2=0; if date=>'01NOV2015'd and date<'01NOV2016'd then do; sales_quantity_adj=sales_quantity_adj+921.77778; v2=1; end;
	v3=0; if date='01NOV2017'd then do; sales_quantity_adj=sales_quantity_adj-2400.4; v3=1; end;
	v4=0; if date=>'01NOV2016'd and date<'01NOV2017'd then do; sales_quantity_adj=sales_quantity_adj-526.76389; v4=1; end;
	v5=0; if date='01SEP2015'd then do; sales_quantity_adj=sales_quantity_adj+1210.6; v5=1; end;
run;
proc sgplot data=p2_3_adj;
	series x=date y=Sales_Quantity_adj;
run;
proc timeseries data=p2_3_adj plot=(series corr acf pacf iacf wn decomp tc sc) seasonality=12; 
	id date interval=month; 
	var sales_quantity_adj; 
	decomp / mode=add; 
run;
/*There was some seasonality and very weak trend.*/

data p2_3_adj_modeling; set p2_3_adj;
	sales_quantity_adj_model = sales_quantity_adj;
	if date>='01JAN2018'd then sales_quantity_adj_model = .;
run;

proc arima data=p2_3_adj_modeling plot=all;
	identify var=sales_quantity_adj_model(12) stationarity=(adf=(0 1 2 3)); 
	estimate p=2 q=2 method=ml;
	forecast lead=8 id=date interval=month out=resout1;
run;quit;
proc arima data=p2_3_adj_modeling plot=all;
	identify var=sales_quantity_adj_model(1 12) stationarity=(adf=(0 1 2 3)); 
	estimate p=2 method=ml;
	forecast lead=8 id=date interval=month out=resout2;
run;quit;
/*proc arima data=p2_3_adj_modeling plot=all;*/
/*	identify var=sales_quantity_adj_model(1) stationarity=(adf=(0 1 2 3)); */
/*	estimate method=ml;*/
/*	forecast lead=8 id=date interval=month out=resout2;*/
/*run;quit;*/
/*proc arima data=p2_3_adj_modeling;*/
/*	identify var=sales_quantity_adj_model minic p=(0:12) q=(0:12);*/
/*	estimate method=ml;*/
/*run;quit;*/
proc arima data=p2_3_adj_modeling plot=all;
	identify var=sales_quantity_adj_model;
	estimate p=2 q=2 method=ml;
	forecast lead=8 id=date interval=month out=resout3;
run;quit;
proc esm data=P2_3_ADJ_MODELING lead=0 plot=forecasts out=resout4;
	id date interval=month;
	forecast sales_quantity_adj_model / model=SEASONAL; 
run;
data resout4; merge
	resout4(keep=date sales_quantity_adj_model rename=(sales_quantity_adj_model=forecast))
	P2_3_ADJ_MODELING(keep=date sales_quantity)
	;
	by date;
run;

* Validation score by MAE;
%MACRO MAE(num);
	data temp1; merge 
		p2_3_adj(keep=date sales_quantity where=(date>='01JAN2018'd)) 
		resout&num.(keep=date forecast where=(date>='01JAN2018'd))
		;
		by date;
		dummy = 1;
		AE = abs(sales_quantity-forecast);
	run;
	proc means data=temp1; var AE; run;
%MEND MAE;
%MAE(1);
%MAE(2);
%MAE(3);
%MAE(4);
* Exponential Smoothing was the best one;

* Final forecast;
proc esm data=P2_3_ADJ_MODELING lead=16 plot=forecasts out=forecast_final3;
	id date interval=month;
	forecast sales_quantity_adj / model=ADDWINTERS; 
run;
data forecast_final3; merge p2_3(IN=t1 keep=date sales_quality) forecast_final3(IN=t2);
	by date;
	if t1=1 and  then sales_q = sales_quality;

data forecast_final3; set 
	p2_3(keep=date sales_quantity) 
	forecast_final3(keep=date sales_quantity_adj where=(date>='01SEP2018'd) rename=(sales_quantity_adj=sales_quantity)); 
run;
proc sgplot data=forecast_final3;
	series x=date y=Sales_Quantity;
run;

/******** END ********/
