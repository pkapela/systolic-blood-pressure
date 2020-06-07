/*
    Script: sbp.SAS
    Date: April, 16th, 2020
    Author: Piotr Kapela
*/

PROC FORMAT;
	value Order
	1='T1-T2-T3'
	2='T3-T1-T2'
	3='T2-T3-T1';

PROC FORMAT;
	value Drug_Type
	1='50mg'
	2='100mg'
	3='SR';

DATA drug_data;
	input Sequence Subject Drug Period SBP;
	format Sequence Order. Drug Drug_Type.;
	datalines;
1 1 1 1 1.5
1 1 2 2 2.2
1 1 3 3 3.4
1 2 1 1 2.0
1 2 2 2 2.6
1 2 3 3 3.1
1 3 1 1 1.6
1 3 2 2 2.7
1 3 3 3 3.2
1 4 1 1 1.1
1 4 2 2 2.3
1 4 3 3 2.9
2 5 3 1 2.5
2 5 1 2 3.5
2 5 2 3 1.9
2 6 3 1 2.8
2 6 1 2 3.1
2 6 2 3 1.5
2 7 3 1 2.7
2 7 1 2 2.9
2 7 2 3 2.4
2 8 3 1 2.4
2 8 1 2 2.6
2 8 2 3 2.3
3 9 2 1 3.3
3 9 3 2 1.9
3 9 1 3 2.7
3 10 2 1 3.1
3 10 3 2 1.6
3 10 1 3 2.5
3 11 2 1 3.6
3 11 3 2 2.3
3 11 1 3 2.2
3 12 2 1 3.0
3 12 3 2 2.5
3 12 1 3 2.0
;

/* Exploratory Analysis */
PROC PRINT data=drug_data;
	title "Corss-Over Design; Systolic Blood Pressure";
RUN;

PROC SORT data=drug_data;
	by Drug Period;
RUN;

PROC PRINT data=drug_data;
	title "Corss-Over Design; Systolic Blood Pressure (Sorted)";
RUN;

PROC MEANS data=drug_data mean noprint;
	var SBP;
	by Drug Period;
	output out=Score mean=Mnscore;
RUN;

PROC PRINT data=Score;
	title "Mean Scores by Drug and Period";
RUN;

PROC PLOT data=Score;
	plot Mnscore*Drug;
	plot Mnscore*Period;
RUN;

PROC SGPLOT data=drug_data;
	title "Boxplots of Systolic Blood Pressure by Period grouped by Drug";
	vbox SBP / category=period group=drug;
RUN;

PROC MEANS data=drug_data;
	title "Descriptive Statistics for Systolic Blood Pressure";
	class Drug Period;
	var SBP;
RUN;

PROC UNIVARIATE data=drug_data;
	title "Histogram for Systolic Blood Pressure by Period";
	class Period;
  	var SBP;
  	histogram SBP / nrows=3 ncol=1;
  	ods select histogram;
RUN;

/* Main Analysis */
PROC GLM data=drug_data plots=meanplot(cl);
	title "Cross-Over Design; Systolic Blood Pressure";
	class Sequence Subject Period Drug;
	model SBP = Sequence Subject(Sequence) Drug Period Drug*Period;
	test h=Sequence e=Subject(Sequence) / Htype=1 Etype=1;
	lsmeans Drug Period / pdiff cl;
RUN;
 
/* Variance Test for Singular Factor */
PROC ANOVA data=drug_data;
	title "Variance Test for Sequence";
	class Sequence;
	model SBP = Sequence;
	means Sequence / hovtest=bf;
	ods select "Brown and Forsythe's HoV Test";
RUN;

PROC ANOVA data=drug_data;
	title "Variance Test for Period";
	class Period;
	model SBP = Period;
	means Period / hovtest=bf;
	ods select "Brown and Forsythe's HoV Test";
RUN;

PROC ANOVA data=drug_data;
	title "Variance Test for Drug";
	class Drug;
	model SBP = Drug;
	means Drug / hovtest=bf;
	ods select "Brown and Forsythe's HoV Test";
RUN;

PROC ANOVA data=drug_data;
	title "Variance Test for Subject";
	class Subject;
	model SBP = Subject;
	means Subject / hovtest=bf;
	ods select "Brown and Forsythe's HoV Test";
RUN;
