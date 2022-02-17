/* Gavin Gunawardena */
/* 7/16/21 */
/* STAT 600 */
/* Dr Claussen */
/* Assignment 7 */
/* Ver. 1.2 */
/* Reverted back to 1.0 and just changed the 3B NPar1Way Function Inputs */
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

%macro ReuseIML;
 /* 
  * Define IML functions here you might use in multiple exercises,
  * then invoke the macro name in IML blocks for different exercises.
  */
%mend;

title 'Exercise 1';
/* Exercise 1 Code Here */
/* Part A */
/* Import the data */
proc import datafile='/home/u58783680/Week 7/coloniesSAS.csv' out=colonies_wide   dbms=csv    replace;
/* delimiter='09'x; */
 getnames=yes;
run;
options nodate ps=60 ls=80;
/* Query for Central Plains States */
proc sql;
  create table central_plains_wide as select * from colonies_wide 
    where(State in ('NEBRASKA','KANSAS','SOUTH DAKO','MINNESOTA','IOWA','MISSOURI','OKLAHOMA'));
quit;
/* Part B */
/* Sort in order to Transpose */
proc sort data=central_plains_wide out=central_plains_wide_sorted;
  by State;
run;
/* Transpose the data from wide to long format */
proc transpose data=central_plains_wide_sorted out=central_plains_long(
    rename=(col1=Value))
  name=year;
  by State;
run;

/* proc print data=central_plains_long; */
/* run; */


/* Part C */
/* Create Temp Table for plotting a box chart of bee colonies by year */

/* Create a box plot with the Central Plains Bee Colony Data */
proc iml;
print("Part 1C Plot:");
quit;
PROC SGPLOT DATA = central_plains_long;
VBOX Value / CATEGORY = Year;
TITLE 'Number of Bees Per Year in Central Plains States';
RUN;






title 'Exercise 2.';
/* Exercise 2 Code Here */
/* Part A */
/* Import the data */
proc import datafile='/home/u58783680/Week 7/productionSAS.csv' out=production_long   dbms=csv    replace;
/* delimiter='09'x; */
 getnames=yes;
run;
options nodate ps=60 ls=80;

/* Query for Central Plains States */
proc sql;
  create table central_plains_production_long as select * from production_long 
    where(State in ('NEBRASKA','KANSAS','SOUTH DAKO','MINNESOTA','IOWA','MISSOURI','OKLAHOMA'));
quit;

/* Part B */
/* Sort in order to Transpose */
proc sort data=central_plains_production_long out=central_plains_prod_long_sorted;
  by State;
run;
/* Reshape the data table to wide format */
proc transpose data=central_plains_prod_long_sorted out=central_plains_prod_wide
  prefix=Data
  name=Data;
  BY State;
  ID Year;
  Var Value;
run;

/* Part B */
/* Plot the data into a cluster plot */
/*
  Template for cluster plot. 
  You may need to change data or var to match your wide data.
*/


/* Replace missing values with zeroes to get a 7 leaf cluster chart */
proc stdize data=central_plains_prod_wide out=central_plains_prod_wide2 reponly missing=0;
run;

/* Cluster Chart */
proc cluster data=central_plains_prod_wide2 method=ward ccc pseudo out=tree
  plots=den(height=rsq);
  var Data1995-Data2014;
  id State;
run;








title 'Exercise 3.';
/* Exercise 3 Code Here */
/* Part A */
/* Import the data */
proc import datafile='/home/u58783680/Week 7/Khan.csv' out=Khan_long   dbms=csv    replace;
/* delimiter='09'x; */
 getnames=yes;
run;
options nodate ps=60 ls=80;
/* Note from assignment 5:  CarbonLoss = Mean05-Mean55 */
/* Add a carbonloss column */
data Khan_long_CLoss;
  set Khan_long;
  Carbonloss = Mean05 - Mean55;
run;


/* Compute mean mi, standard deviation si and count ni for CarbonLoss in each combination of Fertilizer and Rotation .*/

proc summary data=Khan_long_CLoss;
    class Rotation Fertilizer;
    var Carbonloss;
    output out=Khan_long_CLoss_Agg mean=Mean_CarbonLoss std=SD_CarbonLoss n(Carbonloss)=Count_CarbonLoss;
    TYPES Rotation * Fertilizer;
run;
proc print data = Khan_long_CLoss_Agg; run;



/* Part B */
/* Rank the data */
proc rank data=Khan_long_CLoss out=Khan_long_CLoss_Rank;
  
  var CarbonLoss;
  ranks CarbonLossRank;
run;

/* Pull variables for calculations */
proc sql;
create table CalculationValues1 as
select count(klcr.rotation) as N_Value
from Khan_long_CLoss_Rank klcr;

create table CalculationValues2 as
select distinct count(*) as C_Value
from Khan_long_CLoss_Rank klcr
group by klcr.fertilizer;

create table CalculationValues3 as
select klcr.rotation, klcr.fertilizer, sum(klcr.CarbonLossRank) as RankSumsPerSample
from Khan_long_CLoss_Rank klcr
group by klcr.rotation, klcr.fertilizer;

create table CalculationValues4 as
select distinct count(*) as  N_I_Value
from Khan_long_CLoss_Rank klcr
group by klcr.rotation, klcr.fertilizer;

create table CalculationValues5 as
select CalculationValues1.n_value,
CalculationValues2.c_value,
CalculationValues4.N_I_value
from CalculationValues1, CalculationValues2, CalculationValues4;

/* Specialized version of Khan_long_Closs table for the later used NPar1Way Function */
create table CalculationValuesNPar1Way as
select CAT(klc.rotation, klc.fertilizer) as Rotation_Fertilizer, klc.Carbonloss
from Khan_long_CLoss klc;

quit;
/* proc print data = CalculationValues1; run; */
/* proc print data = CalculationValues2; run; */
/* proc print data = CalculationValues3; run; */
/* proc print data = CalculationValues4; run; */
/* proc print data = CalculationValues5; run; */

data CalculationValues6;
   set CalculationValues5 CalculationValues3;
run;
/* Do the calculation for H */

/* First pull and shape variables and arrays from data table */
proc iml;
use CalculationValues6;
read all;
N_Val = shape(N_Value[1],1,1);
C_Val = shape(C_Value[1],1,1);
N_I_Val = shape(N_I_Value[1],1,1);
rot_var = shape(rotation[2:10],9,1);
fert_var = shape(fertilizer[2:10],9,1);
RankSums_var = shape(ranksumspersample[2:10],9,1);
/* print rot_var fert_var RankSums_var; */


/* Do Calculations each section at a time */
H_val_pt1 = 12/(N_Val * (N_Val + 1));


/* Did the summing in 2 different ways to familiarize myself with do loops and vector operations.
Both ways got the same result.*/
/*   Do Loop */
  sum_x = 0;
  k = 0;
H_val_pt2calc2 = 0;
  do i = 1 to nrow(RankSums_var);
    if(RankSums_var[i] ^= .) then do;
      sum_x = sum_x + (RankSums_var[i]**2/N_I_Val);
      k = k+1;
    end;
    
  end;
 H_val_pt2calc2 = sum_x;

/* Matrix calculation */
H_val_pt2 = sum((RankSums_var##2)/N_I_Val);


H_val_pt3 = 3 * (N_Val + 1);
/* print H_val_pt1 H_val_pt2 H_val_pt2calc2 H_val_pt3 ; */


/* Combine the calculations */
H_Val = H_val_pt1 * H_val_pt2 -H_val_pt3;


/* Print Result */

print "H Statistic:";
print H_Val;
      ChiSquared_PDF = pdf('CHISQUARE', H_Val, C_Val-1);



/* Print Result */

/* Part C */
/* Chi Square Function */

print "P value:";
print ChiSquared_PDF;

print("Is the combination of fertilizer and crop rotation predictive of carbon loss?");
print("Answer: No, as a chi square test shows the H statistic for this study to have a P value of .09 which is too high to be statistically significant (threshold being .05).");
/* use Khan_long_CLoss; */




/* Kruskal Test Function */
Print "Kruskal Test Function Results:";
quit;
/* Note: Going by other students' answers mentioned on the forum, 
I believe these results are slightly off since this function requires 
groups, causing the degrees of freedom to be different compared to 
what I calculated above. */
PROC NPAR1WAY DATA=CalculationValuesNPar1Way  correct=no WILCOXON;
CLASS Rotation_Fertilizer;
VAR Carbonloss;
RUN;










title 'Exercise 4';
/* Exercise 4 Code Here */
/* Part A */
/* Import the 2 datasets */
/* NCAA 2018 */
proc import datafile='/home/u58783680/Week 7/ncaa2018SAS.csv' out=ncaa2018raw   dbms=csv    replace;
 getnames=yes;
run;
options nodate ps=60 ls=80;
/* NCAA 2019 */
proc import datafile='/home/u58783680/Week 7/ncaa2019SAS.csv' out=ncaa2019raw   dbms=csv    replace;
 getnames=yes;
run;
options nodate ps=60 ls=80;

/* Part B */
proc sql;
create table ncaaMerged as
select ncaa18.first, ncaa18.last, ncaa18.weight as Weight_18, ncaa19.weight as Weight_19, 
ncaa18.conference, ncaa18.finish as Finish_18, ncaa19.finish as Finish_19, ncaa18.elo
from ncaa2018raw ncaa18
inner join ncaa2019raw ncaa19
on ncaa18.first = ncaa19.first and ncaa18.last = ncaa19.last
where ncaa19.finish <> 'NQ' and ncaa18.finish <> 'NQ';
quit;
/* proc print data = ncaaMerged; run; */

/* Check row count */
data CalculationValues7;
   set ncaaMerged;
run;
proc iml;
use CalculationValues7;
read all;
Finish_19_val = Finish_19;
Finish_19_val_Rows = nrow(Finish_19_val);
Weight19_Val = Weight_19;
Weight19_Val_Rows = nrow(Weight19_Val);

print("Number of rows:");
print Finish_19_val_Rows;
print("No null Finish values detected by this frequency function:");
quit;
proc freq data = ncaaMerged;
  tables Finish_18 Finish_19 ;
run;

/* Part C */
proc iml;
print("Contingency Table:");
quit;
PROC FREQ DATA = ncaaMerged;
TABLES Weight_18 * Weight_19;
TABLES Weight_18 * Weight_19 / MISSING
NOPERCENT NOCOL NOROW;
TITLE 'Weight for 2018 vs Weight for 2019';
RUN;
proc iml;
print("How many wrestlers changed weight classes?");
print("Answer: According to my results, 127 of the 156 wrestlers who qualified for both tournaments stayed in the same weight class while 29 changed weight classes.");
quit;
/*
Use this code to check your results.

proc npar1way data=Lacanne wilcoxon;
  class Composite;
  var POM;
run;
*/
/* Result Check */
proc npar1way data=ncaaMerged wilcoxon;
  class Weight_18;
  var  Weight_19;
run;


/*

