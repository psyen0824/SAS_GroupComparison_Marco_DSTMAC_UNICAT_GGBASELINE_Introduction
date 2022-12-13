/*****************************************************************************************
Purpose: Introduce different summary tables under group stratification

SAS Macros: %DSTMAC, %UNICAT, %ggBaseline

Dataset: PBC

Date- 09/24/2019

Demonstrated Version- SAS 9.4

Author- Pei-Shan Yen, Nairita Ghosal, Yi-Fan Chen
Biostatistics Core, Center for Clinical and Translational Science, University of Illinois at Chicago
*********************************************************************************************/


/*import PBC data from my drive*/ 
PROC IMPORT OUT= WORK.PBC 
            DATAFILE= "C:\Users\pyen2\Dropbox\UIC RA CCTS\201909 Side Project_Group Comparison SAS Macro\Group Comparison SAS Macro\Data\pbc.csv" 
            DBMS=csv REPLACE;
            GETNAMES=YES;
RUN;

/*format for categorical variables*/ 
PROC FORMAT;
	value status_F 0="alive" 1="liver transplant" 2="dead" .=' ';
    value trt_F 1="Dpenicillamine"  2="placebo" .=' ';
	value sex_F 0="male"  1="female" .=' ';
	value ascites_F 0="no"  1="yes"  .=' ';
		value ascites_FM 0="no"  1="yes"  .='MISSING';
	value hepato_F 0="no"  1="yes"  .=' ';
    value spiders_F 0="absent"  1="present"  .=' ';
    value edema_F   0="no edema and no diuretic therapy for edema" 
                   .5="edema present without diuretics, or edema resolved by diuretics"
                    1="edema despite diuretic therapy"  .=' ';

RUN;

DATA WORK.PBC2;
 SET WORK.PBC(OBS=312);

/*label for all variables, # of variables=20*/
label 	
id        = "case number"
time      = "number of days between registration and the earlier of death, transplantion, or study analysis time in July, 1986"
status    = "status"
status_C  = "status"
trt       = "for D-penicillmain, placebo, not randomised"
trt_C     = "for D-penicillmain, placebo, not randomised"
age       = "age in years"
sex       = "sex"
sex_C     = "sex"
ascites   = "presence of ascites"
ascites_C = "presence of ascites"
hepato    = "presence of hepatomegaly or enlarged liver"
hepato_C  = "presence of hepatomegaly or enlarged liver"
spiders   = "blood vessel malformations in the skin"
spiders_C = "blood vessel malformations in the skin"
edema     = "presence of edema 0=no edema and no diuretic therapy for edema"
edema_C   = "presence of edema 0=no edema and no diuretic therapy for edema"
bili      = "serum bilirubin in mg/dl"
chol      = "serum cholesterol in mg/dl"
albumin   = "serum albumin (g/dl)"
copper    = "urine copper in ug/day"
alk_phos  = "alkaline phosphotase (U/liter)"
ast       = "aspartate aminotransferase, once called SGOT (U/ml)"
trig      = "triglicerides in mg/dl"
platelet  = "platelets per cubic ml/1000"
protime   = "standardised blood clotting time"
stage     = "histologic stage of disease (needs biopsy)"
;

/*Make up some missing data*/
If chol=. then ascites=. ;

/*format for categorial variables*/ 
status_C  =put(status,status_F.);
trt_C     =put(trt ,trt_F.);
sex_C     =put(sex,sex_F.);
ascites_C =put(ascites,ascites_F.);
ascites_CM =put(ascites,ascites_FM.);
hepato_C  =put(hepato,hepato_F.);
spiders_C =put(spiders,spiders_F.);
edema_C   =put(edema ,edema_F.);
RUN;


DATA WORK.PBC3;
 SET WORK.PBC2(KEEP= id trt_C age bili chol sex_C ascites_C ascites_CM edema_C);
RUN;

/*print out dataset*/
PROC PRINT DATA=WORK.PBC3;
RUN;

proc freq data=WORK.PBC3;
table sex_C*ascites_C/CHISQ;
table trt_C*ascites_C/CHISQ;
run;

/**************************************************************************************** 
Data Analysis
1. We will use data PBC3 as an example throughout the demonstration
2. Consider first 312 samples and only focus on 6 variable (3 continuous+3 categorical)
3. Variable "trt" and "sex" will be used as the stratification variable.
4. In Summary statistics, Means ± standard deviations are calculated for continuous variables, n (%) are produced for categorical variables
****************************************************************************************/

/**************************************************************************************** 
SAS MACRO FOR DESCRIPTIVE STATISTICS TABLE: %DSTMAC
by Matthew C. Fenchel, M.S.,Cincinnati Children’s Hospital Medical Center, Cincinnati, OH et al.,2011
URL link: https://www.mwsug.org/proceedings/2011/stats/MWSUG-2011-SA19.pdf
*****************************************************************************************
Note: 
1. Creates .rtf file   
2. Parametric Test: T-Test/ANOVA for continuous variables
3. Parametric Test: Likelihood Ratio Chi-Square Test for categorical variables
4. Non-parametric Test: Kruskal-Wallis Test for continuous variables 
5. Non-parametric Test: Fisher's exact Test for categorical variables
*****************************************************************************************/

%INCLUDE "C:\Users\pyen2\Dropbox\UIC RA CCTS\201909 Small Project_Group Comparison SAS Macro\Group Comparison SAS Macro\Macro\DSTMAC\MWSUG 2011 Descriptive Stat V2.sas" ;

/*Summary Stataistics*/
%DSTMAC (dsname = PBC3(drop=ascites_C), 
/*Name of data set.*/
/*drop up the variable which has missing data and without missing label because we would like to show count of missing*/

ID=id,     
/*Name of the subject or ID variable in the data set.*/ 

Byvar = NONE,  
/*The "By" variable*/ 
/*Separate DST’s will be produced for each level of the “By” variable*/
         
group = NONE,  
/*The "Group" variable*/
         
test = TST,    
/*For most cases, enter "TST" (all caps)*/ 
/*If you have a "Group" variable with exactly three (3) levels, 
and you want overall (ANOVA) results instead of all two-way comparisons, 
then enter the word "OVERALL" (all caps).*/ 

outpath = C:\Users\pyen2\Dropbox\UIC RA CCTS\201909 Small Project_Group Comparison SAS Macro\Group Comparison SAS Macro\Output\, 
/* Output file location*/
         
outname = Descriptive Statistics using Macro DSTMAC,     
/*output file name*/ 
         
title = Descriptive Statistics using Macro DSTMAC);  
/*Title*/


/* Summary statistics stratified by Sex*/ 
%DSTMAC (dsname = PBC3(drop=ascites_CM), 
/*drop up the variable which has missing data and with missing label because we would like to perform test (exclude missing)*/
         ID=id, 
         byvar = NONE,   
         group = SEX_C,   
         test = TST,    
         outpath = C:\Users\pyen2\Dropbox\UIC RA CCTS\201909 Small Project_Group Comparison SAS Macro\Group Comparison SAS Macro\Output\, 
         outname = Descriptive Statistics stratified by Sex using Macro DSTMAC,
         title = Descriptive Statistics stratified by Sex using Macro DSTMAC);


/* Summary statistics stratified by Sex and Treatment*/ 
%DSTMAC (dsname=PBC3(drop=ascites_CM), 
/*drop up the variable which has missing data and with missing label because we would like to perform test (exclude missing)*/
         ID=id, 
         byvar=SEX_C, 
         group=TRT_C, 
         test=TST, 
         outpath=C:\Users\pyen2\Dropbox\UIC RA CCTS\201909 Small Project_Group Comparison SAS Macro\Group Comparison SAS Macro\Output\, 
         outname=Descriptive Statistics stratified by Sex and Treatment using Macro DSTMAC,
         title=Descriptive Statistics stratified by Sex and Treatment using Macro DSTMAC);





/**************************************************************************************** 
SAS MACRO FOR DESCRIPTIVE STATISTICS TABLE: %UNICAT

by Dana Nickleach, Yuan Liu, Adam Shrewsberry, Kenneth Ogan, Sungjin Kim, and Zhibo
             Wang, Emory University, Atlanta, GA, 2013
URL link: https://github.com/Emory-Yuan/BBISR-SAS-Macros
*****************************************************************************************
Note: 
1. Creates Microsoft Words documents
2. %UNICAT for stratification and statistical tests
3. Parametric Test: T-Test/ANOVA for numerical variables
4. Parametric Test: Chi-Square Test for categorical variables
5. Non-parametric Test: Kruskal-Wallis Test for numerical variables
6. Non-parametric Test: Fisher's exact Test for categorical variables
****************************************************************************************/

/* Summary statistics stratified by Treatment*/ 
%INCLUDE "C:\Users\pyen2\Dropbox\UIC RA CCTS\201909 Small Project_Group Comparison SAS Macro\Group Comparison SAS Macro\Macro\UNICAT\UNI_CAT V29.sas" ;
/*SAS Macro location*/

TITLE 'Descriptive Statistics stratified by Treatment using Macro UNICAT'; 
/*Table name*/

%UNI_CAT(DATASET=PBC3(drop=ascites_CM),   
/*Dataset name*/
/*drop up the variable which has missing data and with missing label because we would like to perform test (exclude missing)*/

OUTCOME=Trt_C,                   
/*Stratification variable name*/ 

CLIST=sex_C ascites_C edema_C,   
/*Categorical Variable*/

NLIST=age bili albumin chol,     
/*Continuous Variable*/

NONPAR=T, 
/*Specify a value of F, T, or A to indicate whether to conduct non-parametric tests.
If the value is T then both parametric and non-parametric tests will be conducted. 
If the value is F then only parametric tests will be conducted. 
A value of A means that for categorical variables, the appropriate test statistic,
non-parametric or parametric, will be automatically chosen based on whether the chi-square test is invalid, 
but for numerical variables only the parametric test will be calculated. 
Option A is only available for SAS V9.3 or later. 
The default value is F.*/

SPREAD=T, 
/*Set to T to also report standard deviation, min, and max for numerical variables. The default value is F.*/

OUTPATH=C:\Users\pyen2\Dropbox\UIC RA CCTS\201909 Small Project_Group Comparison SAS Macro\Group Comparison SAS Macro\Output\, 
/*Output file location*/

FNAME=Descriptive Statistics stratified by Treatment using Macro UNICAT, 
/*Output file name*/

ROWPERCENT=T);
TITLE;




/* Summary statistics stratified by Treatment_Sex*/ 
TITLE 'Descriptive Statistics stratified by Sex/Treatment using Macro UNICAT'; 
%UNI_CAT(DATASET=PBC3(drop=ascites_CM),  
OUTCOME=sex_C trt_C,   
CLIST=ascites_C edema_C,   
NLIST=age bili albumin chol,     

NONPAR=T, 
/*Specify a value of F, T, or A to indicate whether to conduct non-parametric tests.
If the value is T then both parametric and non-parametric tests will be conducted. 
If the value is F then only parametric tests will be conducted. 
A value of A means that for categorical variables, the appropriate test statistic,
non-parametric or parametric, will be automatically chosen based on whether the chi-square test is invalid, 
but for numerical variables only the parametric test will be calculated. 
Option A is only available for SAS V9.3 or later. 
The default value is F.*/

SPREAD=T, 
OUTPATH=C:\Users\pyen2\Dropbox\UIC RA CCTS\201909 Small Project_Group Comparison SAS Macro\Group Comparison SAS Macro\Output\, 
FNAME=Descriptive Statistics stratified by Sex and Treatment using Macro UNICAT, 
ROWPERCENT=T);
TITLE;



/**************************************************************************************** 
SAS MACRO FOR DESCRIPTIVE STATISTICS TABLE:  %ggBaseline
by Hong-Qiu Gu1,2, Dao-Ji Li3, Chelsea Liu4, Zhen-Zhen Rao , 2018
URL link: http://atm.amegroups.com/article/download/21039/pdf
*****************************************************************************************
Notes: 
1. Creates rtf or PDF report
2. Deletes the Dataset used for the analysis after perform ggbaseline!!
3. Does not have the option to produce summary statistics without stratification
4. Parametric Test: T-Test/ANOVA for numerical variables
5. Parametric Test: Chi-Square test for categorical variables
6. Non-parametric Test: Wilcoxon Rank Sum, Kruskal-Wallis test for numerical variables
7. Non-parametric Test: Fisher's exact test for categorical variables
****************************************************************************************/

%INCLUDE "C:\Users\pyen2\Dropbox\UIC RA CCTS\201909 Side Project_Group Comparison SAS Macro\Group Comparison SAS Macro\Macro\ggBaseline\ggBaseline1.sas";
%INCLUDE "C:\Users\pyen2\Dropbox\UIC RA CCTS\201909 Side Project_Group Comparison SAS Macro\Group Comparison SAS Macro\Macro\ggBaseline\ggBaseline2.sas";
%INCLUDE "C:\Users\pyen2\Dropbox\UIC RA CCTS\201909 Side Project_Group Comparison SAS Macro\Group Comparison SAS Macro\Macro\ggBaseline\ggBaseline.sas";

/*Summary statistics*/ 
%ggBaseline(data=PBC3, 
/*Dataset*/ 
var = age|CTN|'age in years'\ 
bili|CTN|'serum bilirubin in mg/dl'\ 
chol|CTN|'serum cholesterol in mg/dl'\
sex_C|CTG|'sex'\
edema_C|CTG|'presence of edema'\
ascites_C|CTG|'presence of ascites'\,
/*Variables|CTN/CTG|variable_label*/
/*If there is only one group,
test_name is replaced by variable type and can be CTN for continuous variables and CTG for categorical variables*/ 

totcol=Y, 
/*Use Y or N to indicate whether we need a total column ahead of group columns*/

filetype=RTF, 
/*Use RTF or PDF*/

file=C:\Users\pyen2\Dropbox\UIC RA CCTS\201909 Side Project_Group Comparison SAS Macro\Group Comparison SAS Macro\Output\Descriptive Statistics using Macro ggBaseline, 
/*Specify the Output file location and name*/

title=%str(Descriptive Statistics using Macro ggBaseline));
/*Specify the table title*/ 


/* Summary statistics stratified by Treatment*/ 
%ggBaseline(data=PBC3(drop=ascites_CM),   
/*drop up the variable which has missing data and with missing label because we would like to perform test (exclude missing)*/
var = age|TTEST|'age in years'\ 
bili|TTEST|'serum bilirubin in mg/dl'\ 
chol|TTEST|'serum cholesterol in mg/dl'\
sex_C|CHISQ|'sex'\
edema_C|CHISQ|'presence of edema'\
ascites_C|CHISQ|'presence of ascites'\,
/*Variables|Test Name|variable_label*/
/*Test Name; TTEST/WILCX/ANOVA/KRSWLS for continuous variables; CHISQ/CMH/TREND/FISHER for categorical variables*/
grp=Trt_C,
grplabel= D-penicillamine| Placebo, 
totcol=Y, 
filetype=PDF, 
file=C:\Users\pyen2\Dropbox\UIC RA CCTS\201909 Side Project_Group Comparison SAS Macro\Group Comparison SAS Macro\Output\Descriptive Statistics stratified by Treatment using Macro ggBaseline, 
title=%str(Descriptive Statistics stratified by Treatment using Macro ggBaseline));

/* Summary statistics stratified by Gender*/ 
%ggBaseline(data=PBC3(drop=ascites_CM),   
/*drop up the variable which has missing data and with missing label because we would like to perform test (exclude missing)*/
var = age|TTEST|'age in years'\ 
bili|TTEST|'serum bilirubin in mg/dl'\ 
chol|TTEST|'serum cholesterol in mg/dl'\
Trt_C|CHISQ|'Treatment'\
edema_C|CHISQ|'presence of edema'\
ascites_C|CHISQ|'presence of ascites'\,
/*Variables|Test Name|variable_label*/
/*Test Name; TTEST/WILCX/ANOVA/KRSWLS for continuous variables; CHISQ/CMH/TREND/FISHER for categorical variables*/
grp=Sex_C,
grplabel= Male| Female, 
totcol=Y, 
filetype=PDF, 
file=C:\Users\pyen2\Dropbox\UIC RA CCTS\201909 Side Project_Group Comparison SAS Macro\Group Comparison SAS Macro\Output\Descriptive Statistics stratified by Sex using Macro ggBaseline, 
title=%str(Descriptive Statistics stratified by Treatment using Macro ggBaseline));

