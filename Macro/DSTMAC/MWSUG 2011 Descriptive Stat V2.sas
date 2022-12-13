
   /********************************************************************************************************************************************

	PROJECT: 					DESCRIPTIVE STATISTICS PROGRAM (MACRO) WITH TESTS -- %DSTMAC
	REVISION DATE: 				08-25-2011
	STATISTICIAN:				M. Fenchel


	PURPOSE OF PROGRAM: To output descriptive statistics (for continuous and categorical variables) in a way that is almost 
						"presentation ready".  This includes p-values from t-tests and Wilcoxon rank-sum tests (for continuous variables) and
						p-values from likelihood chi-square and Fisher's exact tests for categorical variables.

	"BY" VARIABLES: 	The "By" variable refers to that variable for which separate statistics TABLES are desired. Example: if the "By" variable 
						is Visit and Visit has levels A, B, and C, then descriptive stats will be separately produced for Visits A, B and C.  
						There is no limit to the number of levels in the "By" variable. If there is	no "By" variable, there is an option for that. 
						(In theory, each subject is represented in each level of the "By" variable.)

	"GROUP" VARIABLES: 	The "Group" variable is that variable that defines groups to be compared. If there is no "Group" variable, there is an 
						option for that. (In that case, obviously only descriptive statistics will be produced.) If there are two levels of 
						"Group", then those two groups will be compared. If there are three levels in the "Group" variable, then all two-way 
						comparisons will be performed. (If overall tests are desired instead, there is an option for that.) For more than three 
						levels of "Group", only overall tests are possible. (Each subject is represented in only ONE "Group.")

	REQUIREMENTS:

		a)  Data set being used must be "stacked" -- i.e. one row per observation.  Each variable is in one column only.
		b)  Program assumes each row is an independent observation -- and treats each row as an independent observation. 
			(There is no adjustment for repeated measures. However, having repeated measures will not "crash" the macro.)
		c)  The columns in the data set must be correctly formatted -- text for categorical variables, numeric for continuous variables.
		d)  The data set should only contain those variables that will be used.  Otherwise, the output will contain summary information that
			may not be needed or desired.
		e)  If the user wants the output to have a certain order of the variables, those variables should be in that order already. The 
			program or output can then be adjusted to accommodate that.  Default output for the variables is alphabetical within variable
			type -- all continuous variables are listed first, then categorical variables.


	OUTPUT:

		a)  For continuous variables, means ± STD (n) will be produced.
		b)  For categorical variables, frequencies (n) will be produced.
		c)  A final Word (*.rtf) document will be produced in the path/folder that you specify (as described below), using a name that 
			you will also specify. This Word document will be using the landscape orientation.  
		d)  Final data sets will also be placed in the path/folder  -- one file for each level of the "By" variable. The name of each data set 
			will be "ALL FINAL byv.sas7bdat" where "byv" will be replaced by the respective level of the "By" variable.  If there is no "By" 
			variable, then the final data set will be named "ALL FINAL NONE.sas7bdat".


	USER MUST DO THE FOLLOWING (see below):

		1)  Place the following code within the SAS program that you are running, replacing the word "PATH" with the actual location of 
			this SAS program:

			%let saspgm='PATH\MWSUG 2011 Descriptive Stat V2.sas'; 
			%include &saspgm;
			%dstmac (DSNAME, ID, BYVAR, GROUP, TEST, OUTPATH, OUTNAME, TITLE);

		2)  Replace KEY-WORDS above with those that are applicable for your analysis.

			DSNAME = Name of data set.  If this is not in the work directory (recommended), you need to specify the full path.

			ID = Name of the subject or ID variable in the data set.  No statistics will be generated for this variable.

			BYVAR = The "By" variable (as discussed above). If there is no "By" variable, then enter the word "NONE" (all caps).

			GROUP = The "Group" variable (as discussed above). If there is no "Group" variable, then enter the word "NONE" (all caps).

			TEST = 	You have two choices to enter. For most cases, enter "TST" (all caps). If you have a "Group" variable with exactly 
					three (3) levels, and you want overall (ANOVA) results instead of all two-way comparisons, then enter the word "OVERALL" (all caps);
			
			OUTPATH = Specify the path/folder where the final Word (*.rtf) document and data set(s) will be sent to.

			OUTNAME = Specify the name that you want for the final Word (*.rtf) document.

			TITLE = Specify the first line of the title that will appear in the Word (*rtf) output. This title will appear in blue.


	THIS PROGRAM WILL CRASH IF THE FOLLOWING ARE DONE:

		a)  Using unusual characters -- _, -, %, etc. -- in the "By" or "Group" variables will crash the program.


   *******************************************************************************************************************************************/


	/*********************************************************************************************************************************  

									NOTHING MORE FOR USER TO DO.  PROGRAM STARTS FROM HERE.  

	**********************************************************************************************************************************/


	/******************************************************************************************************************************** 
										A.  ASSIGNMENT OF MACRO VARIABLES AND DETERMINING VARIABLE FORMATS
	 ********************************************************************************************************************************/


	%macro DSTMAC (dsname, ID, byvar, group, test, outpath, outname, title);

	libname descrip "&outpath";						/* Library created for final data set which contains the results. */
	options nodate nonumber validvarname = v7;

	%let subject = macroid;							/* Creating a dummy ID variable, for ease of programming. */
	

	/*  Sets-up dummy "by" and/or "group" variables -- with only one level -- if "NONE" is chosen for either.  **********************/

	data all1; set &dsname; 
		%if &byvar = NONE %then %do; ByVarX = "None"; %let byvar = ByVarX; %end;
		%if &group = NONE %then %do; GroupX = "None"; %let group = GroupX; %end;
		macroid = _n_;
		drop &ID;
		run;
			
	/*  Assigns levels of "by" variable to distinct macro variables. ****************************************************************/

	proc sort data=all1 nodupkey out=temp1; by &byvar; where &byvar ne ""; run;

	data temp2; set temp1;
		by &byvar;
		cnt = left(put(_n_,2.));	x = resolve(&byvar);
		call symputx("byv"||cnt, x);
		if Last.&byvar = 1 then do; call symput("bycount",_n_); end;
		%put _user_;
		run;


	/*  Assigns values of "group variable" to distinct macro variables. ************************************************************/

	proc sort data=all1 nodupkey out=temp3; by &group; where &group ne ""; run;

	data temp4; set temp3;
		by &group;
		cnt = left(put(_n_,2.));	y = resolve(&group);
		call symputx("grp"||cnt, y);
		if Last.&group = 1 then do; call symput("grpcount",_n_); end;
		%put _user_;
		run;


	/* Sets up transposed data set -- with variable types and variable-numbers -- to calculate continuous statistics. **************/ 

	proc transpose data=all1 out=trans(drop = _LABEL_); 
		by &subject &group notsorted;
		id &byvar;
		run;				

	proc contents data=all1 out=info (keep = Name Type VarNum Label) noprint; run;

	data trans; set trans; length Variable $20; Variable = _NAME_; drop _NAME_; run;
	data info; set info; length Variable $20; Variable = Name; drop Name; run;

	proc sql;
		create table all2 as
		select *
		from trans, info
		where trans.variable = info.variable
		order by VarNum, &subject;
		quit; 


	
	/******************************************************************************************************************************** 
										B.  STATISTICS AND TESTS FOR CONTINUOUS VARIABLES 
	 ********************************************************************************************************************************/

	/*******  Descriptive statistics for continuous variables. **********************************************************************/

	%macro cont;

		%do i = 1 %to &bycount;  							/*  Macro loops through once for each level of the "by" variable. */

	proc sql;
		create table means1_&&byv&i as
		select Variable, VarNum, &group as Group, avg(&&byv&i) as Mean_&&byv&i, std(&&byv&i) as STD_&&byv&i, n(&&byv&i) as N_&&byv&i,
				cats("(",put(n(&&byv&i),4.),")") as N2_&&byv&i
		from all2
		group by Variable, VarNum, &group;

		create table means2_&&byv&i as
		select Variable, VarNum, Group,
			catx(' ',put(Mean_&&byv&i, 6.2), '±', put(STD_&&byv&i, 6.2), N2_&&byv&i) as Final
		from means1_&&byv&i;
		quit;	

	proc transpose data=means2_&&byv&i out=means3_&&byv&i(drop = _NAME_); 
		by Variable VarNum; 
		id Group; 
		var Final; 
		run;

	data means4_&&byv&i; retain &ByVar VarNum Variable; 
		set means3_&&byv&i; 
		&ByVar = "&&byv&i"; 
		label &ByVar = "&byvar"; label Variable = "Variable"; 
		run;


	/*  The programming below is used when there are no groups to be compared.  In that case, only descriptive statistics are produced,  
		and sent to the final descriptive data set.  Otherwise, if there are groups to be compared, the test statistics macro will be run. */

	%if &group = GroupX %then %do;
		data Final_&&byv&i; 
			set means4_&&byv&i; 
			run;
		%end;

	%end;

	%mend cont;	
	%cont;
	

	/*******  Test statistics for continuous variables. ******************************************************************************/

	%macro conttest;

		%if &group ne GroupX %then %do;

	/* The counts below -- which represent how many times this "test statistics" macro will be implemented -- are based on whether
	   overall statistics will be produced (n = 1) or all two-way comparisons (for n = 3 only). */  

		%do i = 1 %to &bycount;
			%if &grpcount = 3 %then %let n = 3;
			%if &grpcount ne 3 %then %let n = 1;
			%if &test = OVERALL %then %let n = 1;
			%do j = 1 %to &n;
								
	/*  Obtain test statistics for parametric and non-parametric comparisons. */
	
	proc npar1way anova wilcoxon data=all2; 
		by Variable notsorted;
		var &&byv&i;
		class &group;
		%if &n = 3 %then %do; where &group ne "&&grp&j"; %end;
		output out=test(keep = Variable _VAR_ P_F P_KW) anova wilcoxon;
		run;

	proc sql;
		create table Not_&&grp&j as
		select Variable, _VAR_ as &byvar, P_F as P_F&j "P-F&j" format 6.4, P_KW as P_KW&j "P-KW&j" format 6.4
		from test;
		quit;

	data Not_&&grp&j; retain Variable &byvar Compare&j;
		set Not_&&grp&j;
		%if &j = 1 %then %do; 
			%if &n = 3 %then %do; Compare1 = cats("&grp2","-","&grp3"); %end;
			%if &n ne 3 %then %do; Compare1 = cats("&grp1","-","&grp2"); %end;
			%if &test = OVERALL %then %do; Compare1 = "OVERALL"; run; %end;
			%end;
		%if &j = 2 %then %do; Compare2 = cats("&grp1","-","&grp3"); run; %end;
		%if &j = 3 %then %do; Compare3 = cats("&grp1","-","&grp2"); run; %end;
		
	
	/*  Merging means & SD's with test statistics for continuous variables. */

	proc sql;
		%if &j = 1 %then %do;
		create table Final_&&byv&i 
		as select *
		from Means4_&&byv&i m, Not_&&grp&j t
		where m.Variable = t.Variable;
		%end;

		%if &j ne 1 %then %do;
		create table Final_&&byv&i 
		as select *
		from Final_&&byv&i m, Not_&&grp&j t
		where m.Variable = t.Variable;
		%end;

		quit;

	%end;	%end;	%end;
	%mend conttest;
	%conttest;



	/******************************************************************************************************************************** 
										C.  STATISTICS AND TESTS FOR CATEGORICAL VARIABLES 
	 ********************************************************************************************************************************/

	/*  Isolate categorical variables from main data set.  **************************************************************************/	
	
	proc sort data=info nodupkey out=temp5; by Variable; where TYPE = 2; run;

	/*  Determining the number of categorical variables. */

	data temp6; set temp5;
		by Variable;
		cnt = left(put(_n_,2.)); 
		call symput("catvar"||cnt, Variable); 
		if Last.Variable = 1 then do; call symput("catcount",_n_); end;	
		run;

	data temp7; set temp6;
		if variable = "&byvar" or variable = "&group" then delete;
		keep Variable VarNum;
		run;

	%macro catset;
	data catdata; set all1;
		%do k = 1 %to &catcount;
		keep &&catvar&k;
		%end;
		keep &subject;
		run;

	%mend catset;
	%catset;


	/*  Descriptive statistics for categorical variables. ***************************************************************************/

	%macro catfreq1;

	/*  The code below is only used if there is a "group" variable.  (There will be code later on if there is no "group" variable. 
	    Frequencies are calculated within a level of the group.  */

	%if &group ne GroupX %then %do;
	%do i = 1 %to &bycount; 

	proc freq data=catdata;
		where &byvar = "&&byv&i";
		tables &group;
		ods output OneWayFreqs=F_&group;
		run;

	data temp8; set F_&group;
		by &group;
		count = put(_n_, 1.);
		Frequency2 = strip(left(put(Frequency, 4.0)));	
		call symputx("ngroup"||count, Frequency2);
		%put _user_;
		run;


		%do j = 1 %to &catcount;
			%if &&catvar&j ne &group %then %do;

	proc freq data=catdata;
		where &byvar = "&&byv&i";
		tables &group*&&catvar&j / chisq crosslist;
		ods output CrossList=F_&&catvar&j;
		run;

	data F2_&&catvar&j; set F_&&catvar&j;
		where &&catvar&j ne "" and &group ne "";
		FinalC = cat(trim(put(Frequency, 4.0)), ' (', trim(left(put(RowPercent, 6.2))), '%)');
		keep &group &&catvar&j FinalC;
		run;

	%do k = 1 %to &grpcount;
	proc transpose data=F2_&&catvar&j out=trans;
		where &group = "&&grp&k";
		by &&catvar&j notsorted;
		id &group;
		var FinalC;
		run;

			%if &k = 1 %then %do;
			data F3_&&catvar&j; set trans; run; %end;

			%if &k > 1 %then %do;
			data F3_&&catvar&j; merge F3_&&catvar&j trans; 
			by &&catvar&j;  
			drop _NAME_;
			run;
			%end;
	%end;

	data F4_&&catvar&j; retain &byvar Variable Sub_Cat;
		length Sub_Cat $25;
		set F3_&&catvar&j;
		Variable = "&&catvar&j"; 
		&byvar = "&&byv&i";
		Sub_Cat = &&catvar&j; 
		drop &&catvar&j;
		run;
		
	%if &j = 1 %then %do;
		data FinalC_&&byv&i; set F4_&&catvar&j; run;
		%end;

	%if &j ne 1 %then %do;
		proc append base= FinalC_&&byv&i data= F4_&&catvar&j force; run;
		%end;

	%end; %end; 

	proc sort data=FinalC_&&byv&i; by Variable; run;
	data FinalC_&&byv&i; merge temp7 FinalC_&&byv&i; by Variable; 
		%do m = 1 %to &grpcount;
			label &&grp&m = "&&grp&m (n = &&ngroup&m.)"; 
			%end;
		run;

	title1 "TEST"; proc print label; run;

	%end; %end;	
	%mend catfreq1;	
	%catfreq1;


	/*  The code below is only used if there is not a "group" variable.  Frequencies are calculated within a level of the group.  */

	%macro catfreq2;

	%if &group = GroupX %then %do;
	%do i = 1 %to &bycount; 
		%do j = 1 %to &catcount;
			%if &&catvar&j ne &group %then %do;

	data temp9; set catdata; where &byvar = "&&byv&i"; call symputx("totaln", _n_); run;

	proc freq data=catdata;
		where &byvar = "&&byv&i";
		tables &&catvar&j / chisq;
		ods output OneWayFreqs=F_&&catvar&j;
		run;

	data F2_&&catvar&j; retain &byvar Variable Sub_Cat;
		length Sub_Cat $25;
		set F_&&catvar&j;
		FinalC = cat(trim(put(Frequency, 4.0)), ' (', trim(left(put(Percent, 6.2))), '%)');
		Variable = "&&catvar&j"; 
		&byvar = "&&byv&i";
		Sub_Cat = &&catvar&j; 
		None = FinalC; label None = "Statistics (n = &totaln)";
		keep &byvar Variable Sub_Cat None;
		run;

	%if &j = 1 %then %do;
		data FinalC_&&byv&i; set F2_&&catvar&j; run;
		%end;

	%if &j ne 1 %then %do;
		proc append base= FinalC_&&byv&i data= F2_&&catvar&j force; run;
		%end;

	%end; %end; 

	proc sort data=FinalC_&&byv&i; by Variable; run;
	data FinalC_&&byv&i; merge temp7 FinalC_&&byv&i; by Variable; run;

	%end; %end; 
	%mend catfreq2;	
	%catfreq2;


	/*  Test statistics for categorical variables. ***********************************************************************************/

	%macro cattest;

		%do i = 1 %to &bycount;
			proc datasets; delete FinalCT_&&byv&i;
			%end;


	/*  Test statistics are only produced if there is a "group" variable.  No one-way frequency tests are done in this program. */

		%if &group ne GroupX %then %do;


	/* The counts below -- which represent how many times this "test statistics" macro will be implemented -- are based on whether
	   overall statistics will be produced (n = 1) or all two-way comparisons (for n = 3 only). */ 

		%do i = 1 %to &bycount;
			%if &grpcount = 3 %then %let n = 3;
			%if &grpcount ne 3 %then %let n = 1;
			%if &test = OVERALL %then %let n = 1;


	/*  The code will run tests for all categorical variables -- EXCEPT the "by" variable and the "group" variable. */

			%do k = 1 %to &catcount;	
				%if &&catvar&k ne &group %then %do;	 
					%if &&catvar&k ne &byvar %then %do;
						%do j = 1 %to &n;

	proc freq data=catdata; 
		where &byvar = "&&byv&i";
		%if &n = 3 %then %do; where &byvar = "&&byv&i" and &group ne "&&grp&j"; %end;
		tables &group*&&catvar&k / chisq fisher;
		ods output ChiSq=astest&&catvar&k(where = (Statistic = "Likelihood Ratio Chi-Square"))
				   FishersExact = fisher&&catvar&k(where = (Name1 = "XP2_FISH"));
		run;

	data both&&catvar&k; merge astest&&catvar&k fisher&&catvar&k; run;

	/*  The code continues only if an output data set from the frequency tests is created.  It may not be created if one of the groups
		being compared does not have any observations for a particular categorical variables. */

	%if %sysfunc(exist(astest&&catvar&k)) %then %goto cont1; %else %goto exit1;

	%cont1:
	
	data Not_&&grp&j; retain &byvar Variable Compare1 Compare2 Compare3 P_LR&j P_Fish&j;
		format Variable $20.; informat Variable $20.; length Variable $20; 
		set both&&catvar&k;
		format &&catvar&k $20.; informat &&catvar&k $20.; length &&catvar&k $20; 
		Variable = "&&catvar&k"; 
		&byvar = "&&byv&i";
		P_LR&j = round(Prob, .0001); label P_LR&j = "P-LR&j";
		P_Fish&j = round(NValue1, .0001); label P_Fish&j = "P-Fish&j";
		%if &j = 1 %then %do; 
			%if &n = 3 %then %do; Compare1 = cats("&grp2","-","&grp3"); %end;
			%if &n ne 3 %then %do; Compare1 = cats("&grp1","-","&grp2"); %end;
			%if &test = OVERALL %then %do; Compare1 = "OVERALL"; %end;
			keep &byvar Variable P_LR&j P_Fish&j Compare1 Compare2 Compare3; run;
			%end;
		%if &j = 2 %then %do; Compare2 = cats("&grp1","-","&grp3"); keep &byvar Variable P_LR&j P_Fish&j Compare1 Compare2 Compare3; run; %end;
		%if &j = 3 %then %do; Compare3 = cats("&grp1","-","&grp2"); keep &byvar Variable P_LR&j P_Fish&j Compare1 Compare2 Compare3; run; %end;
		run;

	%if &j = 1 %then %do;
		data FinalCT_&&catvar&k; set Not_&&grp&j; format Variable $20.; run;
		%end;

	%if &j ne 1 %then %do;
		data FinalCT_&&catvar&k; merge FinalCT_&&catvar&k Not_&&grp&j; by Variable; format Variable $20.; run;
		%end;

	%end;


	/* Combining frequencies with test statistics for frequencies. */

	%if %sysfunc(exist(FinalCT_&&byv&i)) %then %goto cont2; %else %goto cont3;
		%cont2:
		data FinalCT_&&byv&i; merge FinalCT_&&byv&i FinalCT_&&catvar&k; by Variable; run;
		%goto cont4;

		%cont3:
		data FinalCT_&&byv&i; set FinalCT_&&catvar&k; run;
		
	%cont4:
	data FINALCAT_&&byv&i;
		merge FinalC_&&byv&i FinalCT_&&byv&i;
		by Variable;
		if Variable = "&byvar" then delete;
		run;

	%end; %end;	

	%exit1: %end; %end; %end;

	%mend cattest;
	%cattest;

		
	/************************************************************************************************************************************
									D.  FINAL MERGING OF DATA SETS AND WORD OUTPUT
	************************************************************************************************************************************/

	%macro combine;

	/* Combining data sets and creating output, when a "group" variable existed. */

		proc format;
			value testtemp 999 = '***    ';
			run;


		%if &group ne GroupX %then %do;

		options orientation = landscape;
		ods rtf file = "&outpath.&outname..doc" bodytitle style=sansPrinter;

			%do i = 1 %to &bycount;

		data descrip.ALL_FINAL_&&byv&i; 
			%if &grpcount = 3 %then %do; retain &byvar Variable Sub_Cat &grp1 &grp2 &grp3 Compare1 P_F1 P_KW1 P_LR1 P_Fish1 
					Compare2 P_F2 P_KW2 P_LR2 P_Fish2 Compare3 P_F3 P_KW3 P_LR3 P_Fish3; %end;
			%if &grpcount = 4 %then %do; retain &byvar Variable Sub_Cat &grp1 &grp2 &grp3 &grp4 Compare1 P_F1 P_KW1 P_LR1 P_Fish1; %end;
			%if &grpcount = 2 %then %do; retain &byvar Variable Sub_Cat &grp1 &grp2 Compare1 P_F1 P_KW1 P_LR1 P_Fish1; %end;
			
			set Final_&&byv&i FINALCAT_&&byv&i;

			*format P_LR1 7.5;		*format P_Fish1 7.5;

			if Sub_Cat ne "" then do;
					LV = lag(Variable); 
					if Variable = LV then do;
						format P_LR1 testtemp.;		format P_Fish1 testtemp.;
						P_LR1 = 999;
						P_Fish1 = 999;
						end;
					end;

			VarNumber = VarNum;
			label Sub_Cat = "Sub-Cat";

			drop VarNum ByVarX LV;
			run;

		title1 color=blue "&title";
		title2 "Mean ± SD (n) or Counts (%)";
		title3 "By Variable Level = &&byv&i";
		title4 "Statistics & Comparisons by &group";
		footnote1 "*** See p-value above";
		proc print noobs label; run;
		%end; 

		ods rtf close;	footnote1;

		%end;


	/* Combining data sets and creating output, when a "group" variable did not exist. */

		%if &group = GroupX %then %do;

		options orientation = landscape;
		ods rtf file = "&outpath.&outname..doc" bodytitle style=sansPrinter;

			%do i = 1 %to &bycount;

		data descrip.ALL_FINAL_&&byv&i (rename = (None = Stats)); retain &byvar Variable Sub_Cat;
			set Means4_&&byv&i FINALC_&&byv&i;
			VarNumber = VarNum;
			if Variable = "ByVarX" then delete;
			label Sub_Cat = "Sub-Cat";
			&byvar = "&&byv&i";
			drop ByVarX VarNum;
			drop VarNum;
			run;

		title1 color=blue "&title";
		title2 "Mean ± SD (n) or Counts (%)";
		title3 "By Variable Level = &&byv&i";
		title4 "Statistics Only"; 
		title5 "No Tests (No Group Variable Defined)";
		proc print noobs label; run;
		%end; 

		ods rtf close;

		%end;

	%mend combine;
	%combine;

	options orientation = portrait;

	%mend DSTMAC;
