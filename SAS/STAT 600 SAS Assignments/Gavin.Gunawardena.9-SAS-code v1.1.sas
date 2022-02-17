/* options macrogen symbolgen mprint mlogic; */

/*
 * General Instructions.
 * 
 * Choose either IML or Macro language to provide SAS solutions for the problems
 * listed in the R markdown instructions. You are not required to solve all problems,
 * but be sure to change the title to indicate which problems you want graded.
 * 
 * You may use `IML`, `DATA` operations or `PROC SQL` at your discretion.
 */




title 'Exercise 1';
/* Exercise 1 Code Here */
/* Load the ncaa2018 dataset */
proc import datafile='/home/u58783680/Week 7/ncaa2018SAS.csv' out=ncaa2018raw   dbms=csv    replace;
 getnames=yes;
run;
options nodate ps=60 ls=80;


/* Create a histogram on ELO */
proc sgplot data=ncaa2018raw;
    histogram elo / nbins=10;
    TITLE 'NCAA 2018 ELO Histogram';
run;


/* Create QQ Norm on ELO */

proc univariate data = ncaa2018raw;
    var elo;
    qqplot elo;
    TITLE 'NCAA 2018 ELO QQ Norm Chart';
run;



/* Create a box-whisker on ELO */
proc sgplot data = ncaa2018raw;
	hbox elo / name = "NCAA 2018 ELO Boxplot";
    TITLE 'NCAA 2018 ELO Box-Whisker Chart';
run;






















title 'Exercise 2';
/* Exercise 2 Code Here */

/* Part A */
title 'Exercise 2 Part A';
/* Draw 1000 Normal Distribution random samples */
data normal;
seed =9999;
call streaminit(seed);
/* do stickprov = 1 to 10000; */
do obs = 1 to 10000;
x = rand ('normal',0,1);
output;
/* end; */
end;
drop seed;
run;



/* Cauchy Distributions */
data cauchy;
seed =9999;
call streaminit(seed);
/* do stickprov = 1 to 10000; */
do obs = 1 to 10000;
x = rand ('cauchy');
output;
/* end; */
end;
drop seed;
run;

/* Weibull Distribution */
data weibull;
seed =9999;
call streaminit(seed);
/* do stickprov = 1 to 10000; */
do obs = 1 to 10000;
x = rand ('weibull', 1.5);
output;
/* end; */
end;
drop seed;
run;
/* Double Exponential */
data laplace;
seed =9999;
call streaminit(seed);
/* do stickprov = 1 to 10000; */
do obs = 1 to 10000;
x = rand ('laplace',0,1);
output;
/* end; */
end;
drop seed;
run;

/* Combine the samples datasets */
proc sql;
create table CombinedSamples as
select n.obs as observations, n.x as Normal, c.x as Cauchy, w.x as Weibull, l.x as Laplace
from normal n inner join
cauchy c on n.obs = c.obs
inner join
weibull w on w.obs = c.obs
inner join
laplace l on l.obs = c.obs
;
quit;




/* Calculate skewness and kurtosis for each sample */

proc iml;
use CombinedSamples;
read all;

kurtosis_Normal = round(kurtosis(Normal),.0001);
call symput("kurtosis_Normal",rowcat(char(kurtosis_Normal)));
  %put &kurtosis_Normal;
kurtosis_Cauchy = round(kurtosis(Cauchy),.0001);
call symput("kurtosis_Cauchy",rowcat(char(kurtosis_Cauchy)));
  %put &kurtosis_Cauchy;
kurtosis_Weibull = round(kurtosis(Weibull),.0001);
call symput("kurtosis_Weibull",rowcat(char(kurtosis_Weibull)));
  %put &kurtosis_Weibull;
kurtosis_Laplace = round(kurtosis(Laplace),.0001);
call symput("kurtosis_Laplace",rowcat(char(kurtosis_Laplace)));
  %put &kurtosis_Laplace;
skewness_Normal = round(skewness(Normal),.0001);
call symput("skewness_Normal",rowcat(char(skewness_Normal)));
  %put &skewness_Normal;
skewness_Cauchy = round(skewness(Cauchy),.0001);
call symput("skewness_Cauchy",rowcat(char(skewness_Cauchy)));
  %put &skewness_Cauchy;
skewness_Weibull = round(skewness(Weibull),.0001);
call symput("skewness_Weibull",rowcat(char(skewness_Weibull)));
  %put &skewness_Weibull;
skewness_Laplace = round(skewness(Laplace),.0001);
call symput("skewness_Laplace",rowcat(char(skewness_Laplace)));
  %put &skewness_Laplace;

/* value $vlblfmt 'results' = cat("Kurtosis=",kurtosis_Normal); */

print "Results";

print kurtosis_Normal kurtosis_Cauchy kurtosis_Weibull kurtosis_Laplace;
print skewness_Normal skewness_Cauchy skewness_Weibull skewness_Laplace;
store _all_ module=_all_;

quit;

proc iml;
use CombinedSamples;
read all;
IF (Normal <= 1) then print(Normal);

quit;


/* Part B */
title 'Exercise 2 Part B';
proc sgplot data=CombinedSamples;
    histogram normal / nbins=10 showbins transparency=0.5 fillattrs=(color=blue) ;
    histogram cauchy / nbins=10 showbins transparency=0.5 fillattrs=(color=silver);
    histogram weibull / nbins=10 showbins transparency=0.5 fillattrs=(color=red);
    histogram laplace / nbins=10 showbins transparency=0.5 fillattrs=(color=yellow);
    TITLE "Histograms for Normal, Cauchy, Weibull, and Laplace Distributions";
    xaxis min=-5 max=5 label="Distributions:(Normal: Kurtosis=&kurtosis_Normal Skewness=&skewness_Normal) (Cauchy: Kurtosis=&kurtosis_Cauchy Skewness=&skewness_Cauchy) (Weibull: Kurtosis=&kurtosis_Weibull Skewness=&skewness_Weibull) (Laplace: Kurtosis=&kurtosis_Laplace Skewness=&skewness_Laplace)";
    yaxis max=100;
run;


/* Part C */
title 'Exercise 2 Part C';
/* Set Up for Part C */
proc rank data=CombinedSamples normal=blom out=CombinedSamplesQuant;
  var Normal Cauchy Weibull Laplace;
  ranks Normal_Quant Cauchy_Quant Weibull_Quant Laplace_Quant;
run;



/* Create Combined QQPlots */
title 'Q-Q Plot for Normal, Cauchy, Weibull, and Laplace Distributions';
proc sgplot data=CombinedSamplesQuant;
  scatter x=Normal_Quant y=Normal;
  scatter x=Cauchy_Quant y=Cauchy;
  scatter x=Weibull_Quant y=Weibull;
  scatter x=Laplace_Quant y=Laplace;
  xaxis label="Distributions:(Normal: Kurtosis=&kurtosis_Normal Skewness=&skewness_Normal) (Cauchy: Kurtosis=&kurtosis_Cauchy Skewness=&skewness_Cauchy) (Weibull: Kurtosis=&kurtosis_Weibull Skewness=&skewness_Weibull) (Laplace: Kurtosis=&kurtosis_Laplace Skewness=&skewness_Laplace)";
  yaxis min=-500 max=500;
run;

/* Working Test Code for QQ plot */
/*  */
/* proc rank data=CombinedSamples normal=blom out=NormalSamplesQuant; */
/*   var Normal; */
/*   ranks Normal_Quant; */
/* run; */
/* proc rank data=CombinedSamples normal=blom out=CauchySamplesQuant; */
/*   var Cauchy; */
/*   ranks Cauchy_Quant; */
/* run; */
/* proc rank data=CombinedSamples normal=blom out=WeibullSamplesQuant; */
/*   var Weibull; */
/*   ranks Weibull_Quant; */
/* run; */
/* proc rank data=CombinedSamples normal=blom out=LaplaceSamplesQuant; */
/*   var Laplace; */
/*   ranks Laplace_Quant; */
/* run; */
/*  */
/*  */
/* title 'Q-Q Plot for Normal, Cauchy, Weibull, and Laplace Distributions'; */
/* proc sgplot data=NormalSamplesQuant; */
/*   scatter x=Normal_Quant y=Normal; */
/*   xaxis label="Distributions:(Normal: Kurtosis=&kurtosis_Normal Skewness=&skewness_Normal) (Cauchy: Kurtosis=&kurtosis_Cauchy Skewness=&skewness_Cauchy) (Weibull: Kurtosis=&kurtosis_Weibull Skewness=&skewness_Weibull) (Laplace: Kurtosis=&kurtosis_Laplace Skewness=&skewness_Laplace)"; */
/*   yaxis min=-500 max=500; */
/* run; */
/*  */
/* title 'Q-Q Plot for Normal, Cauchy, Weibull, and Laplace Distributions'; */
/* proc sgplot data=CauchySamplesQuant; */
/*   scatter x=Cauchy_Quant y=Cauchy; */
/*   xaxis label="Distributions:(Normal: Kurtosis=&kurtosis_Normal Skewness=&skewness_Normal) (Cauchy: Kurtosis=&kurtosis_Cauchy Skewness=&skewness_Cauchy) (Weibull: Kurtosis=&kurtosis_Weibull Skewness=&skewness_Weibull) (Laplace: Kurtosis=&kurtosis_Laplace Skewness=&skewness_Laplace)"; */
/*   yaxis min=-500 max=500; */
/* run; */
/*  */
/* title 'Q-Q Plot for Normal, Cauchy, Weibull, and Laplace Distributions'; */
/* proc sgplot data=WeibullSamplesQuant; */
/*   scatter x=Weibull_Quant y=Weibull; */
/*   xaxis label="Distributions:(Normal: Kurtosis=&kurtosis_Normal Skewness=&skewness_Normal) (Cauchy: Kurtosis=&kurtosis_Cauchy Skewness=&skewness_Cauchy) (Weibull: Kurtosis=&kurtosis_Weibull Skewness=&skewness_Weibull) (Laplace: Kurtosis=&kurtosis_Laplace Skewness=&skewness_Laplace)"; */
/*   yaxis min=-500 max=500; */
/* run; */
/*  */
/* title 'Q-Q Plot for Normal, Cauchy, Weibull, and Laplace Distributions'; */
/* proc sgplot data=LaplaceSamplesQuant; */
/*   scatter x=Laplace_Quant y=Laplace; */
/*   xaxis label="Distributions:(Normal: Kurtosis=&kurtosis_Normal Skewness=&skewness_Normal) (Cauchy: Kurtosis=&kurtosis_Cauchy Skewness=&skewness_Cauchy) (Weibull: Kurtosis=&kurtosis_Weibull Skewness=&skewness_Weibull) (Laplace: Kurtosis=&kurtosis_Laplace Skewness=&skewness_Laplace)"; */
/*   yaxis min=-500 max=500; */
/* run; */



/* Part D */
title 'Exercise 2 Part D';
/* Create Combined Box and Whisker Plots */
TITLE 'Box-Whisker Plots for Normal, Cauchy, Weibull, and Laplace Distributions';
ods graphics / width=8cm height=8cm;
ods layout gridded columns=2;
ods region;
proc sgplot data = CombinedSamples;
TITLE "Normal Distribution - Kurtosis=&kurtosis_Normal Skewness=&skewness_Normal";
	vbox normal / legendlabel= "Normal Distribution Boxplot";

run;
ods region;
proc sgplot data = CombinedSamples;
TITLE "Cauchy Distribution - Kurtosis=&kurtosis_Cauchy Skewness=&skewness_Cauchy";
	vbox cauchy / legendlabel = "Cauchy Distribution Boxplot";

run;
ods region;
proc sgplot data = CombinedSamples;
TITLE "Weibull Distribution - Kurtosis=&kurtosis_Weibull Skewness=&skewness_Weibull";
	vbox weibull / legendlabel = "Weibull Distribution Boxplot";
run;
ods region;
proc sgplot data = CombinedSamples;
TITLE "Laplace Distribution - Kurtosis=&kurtosis_Laplace Skewness=&skewness_Laplace";
	vbox laplace / legendlabel = "Laplace Distribution Boxplot";
run;
ods layout end;
ods graphics off;
ods graphics on;
ODS GRAPHICS / reset=All;



















title 'Exercise 3';
/* Exercise 3 Code Here */
/* Part A */
title 'Exercise 3 Part A';
/* Create 6000 samples of the Poisson distribution
doubling lambda from 2 to 64 for each 1000.
Display lambda and skewness for each histogram and
box-whisker plot*/

/* Lambda */
data lambda;
seed =1976;
call streaminit(seed);
do lambda = 2 to 64 by 1;

do obs = 1 to 1000;
poisson = rand ('poisson',lambda);
output;
end;

lambda = lambda * 2-1;

end;
drop seed;
keep lambda poisson;
run;

/* Separate the dataset by lambda values */
proc sql;
create table Lambda_2 as
select lambda, poisson
from lambda
where lambda = 2;
create table Lambda_4 as
select lambda, poisson
from lambda
where lambda = 4;
create table Lambda_8 as
select lambda, poisson
from lambda
where lambda = 8;
create table Lambda_16 as
select lambda, poisson
from lambda
where lambda = 16;
create table Lambda_32 as
select lambda, poisson
from lambda
where lambda = 32;
create table Lambda_64 as
select lambda, poisson
from lambda
where lambda = 64;
quit;

/* Obtain Calculations for skewness */
/* Lambda 2 */
proc iml;
use Lambda_2;
read all;
Lambda_2_Skewness = round(skewness(poisson),.0001);
Lambda_2_Lambda = lambda[1];
call symput("Lambda_2_Skewness",rowcat(char(Lambda_2_Skewness)));
  %put &Lambda_2_Skewness;
call symput("Lambda_2_Lambda",rowcat(char(Lambda_2_Lambda)));
  %put &Lambda_2_Lambda;
    call execute(cats('proc sgplot data=Lambda_2; histogram poisson / nbins=10;  run;'));
quit;
/* Lambda 4 */
proc iml;
use Lambda_4;
read all;
Lambda_4_Skewness = round(skewness(poisson),.0001);
Lambda_4_Lambda = lambda[1];
call symput("Lambda_4_Skewness",rowcat(char(Lambda_4_Skewness)));
  %put &Lambda_4_Skewness;
call symput("Lambda_4_Lambda",rowcat(char(Lambda_4_Lambda)));
  %put &Lambda_4_Lambda;
quit;
/* Lambda 8 */
proc iml;
use Lambda_8;
read all;
Lambda_8_Skewness = round(skewness(poisson),.0001);
Lambda_8_Lambda = lambda[1];
call symput("Lambda_8_Skewness",rowcat(char(Lambda_8_Skewness)));
  %put &Lambda_8_Skewness;
call symput("Lambda_8_Lambda",rowcat(char(Lambda_8_Lambda)));
  %put &Lambda_8_Lambda;
quit;
/* Lambda 16 */
proc iml;
use Lambda_16;
read all;
Lambda_16_Skewness = round(skewness(poisson),.0001);
Lambda_16_Lambda = lambda[1];
call symput("Lambda_16_Skewness",rowcat(char(Lambda_16_Skewness)));
  %put &Lambda_16_Skewness;
call symput("Lambda_16_Lambda",rowcat(char(Lambda_16_Lambda)));
  %put &Lambda_16_Lambda;
quit;
/* Lambda 32 */
proc iml;
use Lambda_32;
read all;
Lambda_32_Skewness = round(skewness(poisson),.0001);
Lambda_32_Lambda = lambda[1];
call symput("Lambda_32_Skewness",rowcat(char(Lambda_32_Skewness)));
  %put &Lambda_32_Skewness;
call symput("Lambda_32_Lambda",rowcat(char(Lambda_32_Lambda)));
  %put &Lambda_32_Lambda;
quit;
/* Lambda 64 */
proc iml;
use Lambda_64;
read all;
Lambda_64_Skewness = round(skewness(poisson),.0001);
Lambda_64_Lambda = lambda[1];
call symput("Lambda_64_Skewness",rowcat(char(Lambda_64_Skewness)));
  %put &Lambda_64_Skewness;
call symput("Lambda_64_Lambda",rowcat(char(Lambda_64_Lambda)));
  %put &Lambda_64_Lambda;
quit;


/* Show Charts */
data _null_;

 call execute(cats('ods graphics / width=4cm height=4cm; ','ods layout gridded columns=3; ','ODS GRAPHICS / reset=All;'));
  do i=2 to 64 by 1;
/* Histograms */
    call execute(cat('ods region; title "',cat("Poisson Distribution Histogram Lambda: ","&Lambda_",i,"_Lambda"),'";'));
    call execute(cat('proc sgplot data=lambda (where=(lambda=',i,')); histogram poisson / nbins=10 showbins transparency=0.5 fillattrs=(color=silver) ; run;'));
/* QQ Norm */
	call execute(cat('proc rank data=',cat('Lambda_',i),' normal=blom out=',cat('Lambda_',i,'_Quant'),';',' var poisson; ranks Poisson_Quant;', 'run;'));
    call execute(cat('ods region; title "',cat("Poisson Distribution QQ Plot Lambda: ","&Lambda_",i,"_Lambda"),'";'));
    call execute(cat('proc sgplot data=',cat('Lambda_',i,'_Quant'),'; scatter x=Poisson_Quant y=Poisson ; run;'));
/* Box-Whisker */
    call execute(cat('ods region; title "',cat("Poisson Distribution Box Chart Lambda: ","&Lambda_",i,"_Lambda"," Skewness: ","&Lambda_",i,"_Skewness"),'";'));
    call execute(cat('proc sgplot data=lambda (where=(lambda=',i,')); vbox poisson /  legendlabel= "Poisson Distribution Boxplot"; run;'));
    i = i * 2-1;
  end;
 call execute(cats('ods layout end; ','ods graphics on; ','ODS GRAPHICS / reset=All;'));


run;






/* Part B */
title 'Exercise 3 Part B';
proc iml;
print('Tried combining the tables but started getting max memory errors in SAS. The below method of running the datasets individually seems to work though.');
quit;
title2 'lambda 2';
proc univariate data=lambda_2 plot; var poisson; run;
title2 'lambda 4';
proc univariate data=lambda_4 plot; var poisson; run;
title2 'lambda 8';
proc univariate data=lambda_8 plot; var poisson; run;
title2 'lambda 16';
proc univariate data=lambda_16 plot; var poisson; run;
title2 'lambda 32';
proc univariate data=lambda_32 plot; var poisson; run;
title2 'lambda 64';
proc univariate data=lambda_64 plot; var poisson; run;

proc iml;
print('Question: At what size mean is Poisson data no longer skewed, relative to normally distributed data?');
print('Answer: It seems to be no longer skewed at a mean of 64, as this is where the skewness is closest to 0.');
print('Question: At what µ is skewness of the Poisson distribution small enough to be considered normal?');
print('Answer: Going by my results from exercise 2 and from running it a few times with different seed values, 
it seems like a normal distribution usually has a skewness between -.06 and .06. Skewness of the poisson 
distribution seems to get into this range at a µ of 64, and can thus be considered a normal distribution at 
this point.');
quit;



















title 'Exercise 4';
/* Exercise 4 Code Here */
/* Part A */
title 'Exercise 4 Part A';
/* Macro Setup */
options macrogen symbolgen mprint mlogic;
/* Read in data file */
proc import datafile='/home/u58783680/Week 9/hidalgo.dat' out=hidalgo (rename=Var1=y)  dbms=csv    replace;
/* delimiter='09'x; */
 getnames=no;
run;
options nodate ps=60 ls=80;



/* Write function to plot histograms */
%macro plot_histograms(table_name, column_name, number_of_bins, main="Main", xlabel="X Label");

/* Check amount of items in number_of_bins */
%let number_of_bins_size=%sysfunc(countw(&number_of_bins));

/* Loop from 1 to number of bins */
%do i=1 %to &number_of_bins_size;
/* 	%let number_of_bins_size= %scan(&number_of_bins,&i) */
/* Skip over null values in number_of_bins */
	%if(%scan(&number_of_bins,&i) ^= .) %then %do;

	  
	        proc sgplot data=work.&table_name;
	       
	            histogram &column_name / nbins=%scan(&number_of_bins,&i);
	            xaxis label = &xlabel;
	            yaxis label = "Frequency,   Number of Bins: %scan(&number_of_bins,&i)";
	            title "&main";
	        run;
	%end;
%end;

%mend;

/* Part B */
title 'Exercise 4 Part B';
/* Test function */

%plot_histograms(hidalgo, y, 12 36 60, main="1872 Hidalgo issue", xlabel="Thickness (mm)");

proc iml;
print('Question: Some analysis suggest there are three different mixtures of paper used to produce the 1872 Hidalgo issue;
other analysis suggest seven. Why do you think there might be disagreement about the number of mixtures?');
print('Answer: It makes sense that people would be suspicious of this data after seeing a visualization of it as it is not normally distributed.
When visualized on a histogram, the data seems to be heavily skewed and distributed around multiple points including .07 mm, .08 mm, .1 mm, and .11 mm.');

quit;
