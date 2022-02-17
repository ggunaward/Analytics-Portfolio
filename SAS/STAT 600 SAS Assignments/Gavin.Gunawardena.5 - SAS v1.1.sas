/*
Gavin Gunawardena
Stat 600
6/18/21
Dr Claussen
Version:1.0
*/
/* options macrogen symbolgen mprint mlogic; */
/*
 * General Instructions.
 *
 * Choose either IML or Macro language to provide SAS solutions for the problems
 * listed in the R markdown instructions.
 *
 * You must upload your SAS log to D2L to get credit for Macro code. If you use IML,
 * be sure to print your results, and to add comments to the output.
 */
title 'Exercise 1';

/* Exercise 1 Code Here */
options macrogen symbolgen mprint mlogic;

/*Function*/
%macro percent_increase(v_1, v_2);
	round((&v_2-&v_1)/&v_1, .0001);
%mend;

/* use of the function  */
data Exercise1;
/* Solve for percentage increase between 1936 and 2006
Mean total calories per recipe */
	MeanTotalCalPerRec=%percent_increase(2123.8, 3051.9);
/* Solve for percentage increase between 1936 and 2006
Mean average calories per serving */
	MeanAvgCalPerServ=%percent_increase(268.1, 384.4);
/* Solve for percentage increase between 1936 and 2006
Mean number of servings per recipe */
	MeanNumServPerRec=%percent_increase(12.9, 12.7);
run;

proc print data=Exercise1;
run;











title 'Exercise 2';

/* Exercise 2 Code Here */


/*Functions*/
proc iml;
	/*Functions*/
	start ConfidenceInterval(mean, sd, n, alpha=0.05, title='answer', 
		lower_bound=0, upper_bound=0);
	seHat=sd/sqrt(n);
	intervalA=quantile('NORMAL', 1-alpha/2)*seHat;
	lower_bound=mean-intervalA;
	upper_bound=mean+intervalA;
	print("Normal Dist - " + title);
	print lower_bound upper_bound;
	finish;
	
	
	start ConfidenceBoundT(mean, sd, n, alpha=0.05, title='answer', lower_bound=0, 
		upper_bound=0);
	df=n-1;
	seHat=sd/sqrt(n);
	intervalA=quantile('T', 1-alpha/2, df)*seHat;
	lower_bound=mean-intervalA;
	upper_bound=mean+intervalA;
	print("T Dist - " + title);
	print lower_bound upper_bound;
	finish;

	/*variables to test pass by reference*/
	lower=100;
	upper=100;

	/*Function use 2a*/
	/*95% CI, 1638.7 to 2608.9 calories] mean = 2123.8*/
	title_C='Confidence Bounds for Mean Total Calores Per Recipe 1936';
	call ConfidenceInterval(2123.8, 1050, 18, 0.05, title_C, lower, upper);
	print('Pass By Reference Test');
	print lower upper;

	/*[CI, 2360.7 to 3743.1 calories] mean = 3051.9*/
	title_C='Confidence Bounds for Mean Total Calores Per Recipe 2006';
	call ConfidenceInterval(3051.9, 1496.2, 18, , title_C, lower, upper);
	print('Pass By Reference Test');
	print lower upper;

	/*[CI, 210.4 to 325.8 calories] mean = 268.1*/
	title_C='Confidence Bounds for Mean Average Calories Per Serving 1936';
	call ConfidenceInterval(268.1, 124.8, 18, , title_C, lower, upper);
	print('Pass By Reference Test');
	print lower upper;

	/*[CI, 359.1 to 514.7 calories] mean = 436.9
	Note: 436.9 was their calculated P Value. The actual mean was 384.4*/
	title_C='Confidence Bounds for Mean Average Calories Per Serving 2006';
	call ConfidenceInterval(436.9, 168.3, 18, , title_C, lower, upper);
	print('Pass By Reference Test');
	print lower upper;

	/*Function use 2b
	/*95% CI, 1638.7 to 2608.9 calories] mean = 2123.8*/
	title_C='Confidence Bounds for Mean Total Calores Per Recipe 1936';
	call ConfidenceBoundT(2123.8, 1050, 18, , title_C);
	print('Pass By Reference Test');
	print lower upper;

	/*[CI, 2360.7 to 3743.1 calories] mean = 3051.9*/
	title_C='Confidence Bounds for Mean Total Calores Per Recipe 2006';
	call ConfidenceBoundT(3051.9, 1496.2, 18, , title_C);
	print('Pass By Reference Test');
	print lower upper;

	/*[CI, 210.4 to 325.8 calories] mean = 268.1*/
	title_C='Confidence Bounds for Mean Average Calories Per Serving 1936';
	call ConfidenceBoundT(268.1, 124.8, 18, , title_C);
	print('Pass By Reference Test');
	print lower upper;

	/*[CI, 359.1 to 514.7 calories] mean = 436.9
	Note: 436.9 was their calculated P Value. The actual mean was 384.4*/
	title_C='Confidence Bounds for Mean Average Calories Per Serving 2006';
	call ConfidenceBoundT(436.9, 168.3, 18, , title_C);
	print('Pass By Reference Test');
	print lower upper;
	quit;
	
	
	
	
	
	
	
	
	
	
	
	
title 'Exercise 3';
/* Exercise 3 Code Here */
	

	/*Function*/
	options macrogen symbolgen mprint mlogic;
	%macro norm_pdf(x, mu=0, sigma=1);
		%let pi2  = %sysfunc(constant(PI))*2;
		%let var_1 = &sigma**2;
		%let part1 =(1/((&sigma)*(%sysfunc(sqrt(&pi2)))));
		%let part2 = (%sysfunc(constant(E))**((-1*(&x-&mu)**2/(2*&var_1))));
		round(&part1*&part2, .0001);
	%mend;


/* use of the function  */
data Exercise3;
	Answer1=%norm_pdf(-0.1);
	Answer2=%norm_pdf(0);
	Answer3=%norm_pdf(0.1);
run;

proc print data=Exercise3;
run;











title 'Exercise 4';

	/* Exercise 4 Code Here */
	
	
proc iml;
	start pois_pmf(x, lambda);

	/* Creation of probability mass function */
	var_fac=fact(x);
	print((constant("e")**(-1*lambda)*lambda**x)/var_fac);
	finish;

	/* use of the function  */
	print('x=4 lambda = 12');
	call pois_pmf(4, 12);
	print('x=12 lambda = 12');
	call pois_pmf(12, 12);
	print('x=20 lambda = 12');
	call pois_pmf(20, 12);
	quit;