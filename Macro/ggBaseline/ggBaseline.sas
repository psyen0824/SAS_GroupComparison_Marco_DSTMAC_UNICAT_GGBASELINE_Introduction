*=======================================================
 %ggBaseline: generate Demographic Tables with one group or multiple groups 
 Maintainer: Hong-Qiu Gu <guhongqiu@yeah.net> 
 Date: V20180105

 
%ggBaseline(
data=, 
var=var1|test|label1\
    var2|test|label2, or 
    var1|CTN|label1\
    var2|CTG|label2, 
grp=grpvar,
grplabel=grplabel1|grplabel2,  
stdiff=N,
totcol=N, 
pctype=COL|ROW, 
exmissing=Y|N,
filetype=RTF|PDF, 
file=&ProjPath\05-Out\01-Table\, 
title=,
footnote=, 
fnspace=20,
page=PORTRAIT|LANDSCAPE,
deids=Y|N
)

/****************************/
/* ARGUMENTS AND PARAMETERS */
/****************************/

There are four required parameters data, var, file, and title for one group 
and six required parameters data, var, grp, grplabel, file, and title for  
multiple groups. The other eight optional parameters can be specified by 
users or left blank. 

/* REQUIRED ARGUMENTS:
   data = the input dataset
   var  = the variables we want to list in the table. For each variable, the form should be 
          "variable_name|test_name|variable_label\", "|" is used to separate the variable name, 
          statistical test, and variable label, and "\" is used to separate variables.  
          The slash (\)  is  not required for the last variable. If there is only one group, 
          test_name is replaced by variable type and can be CTN for continuous variables 
          and CTG for categorical variables. If there are two groups, test_name can be TTEST 
          or WILCX for continuous variables and CHISQ, CMH, TREND or FISHER for categorical 
          variables. If there are more than two groups, test_name can be ANOVA or KRSWLS for 
          continuous variables and CHISQ, CMH, TREND or FISHER for categorical variables. 
          Here 
              TTEST:  Indepent t test
              WILCX:  Wilcoxon rank-sum test
              CHISQ:  Chi-square test
              CMH:    Cochran-Mantel-Haenszel Test
              TREND:  Cocharan-Armitage trend test
              FISHER: Fisher's exact test
              ANOVA:  Analysis of variance
              KRSWLS: Kruskal-Wallis test 
   grp  = Group variable.  
   grplabel = Label for each group. For example, if there are two groups treatment and control, 
              we can set grplabel as "Treatment|Control", where "|" is used to separate group 
              labels. 
   file = the file location. 
   title= the table title.


   OPTIONAL PARAMETERS:
   stdiff   = Use Y or N to indicate whether standardized difference is used. 
              This parameter is valid only when there are two groups. The default value is N. 
   totcol   = Use Y or N to indicate whether to include a total column. The default value is N.
   pctype   = Use COL or ROW to report a column percentage or row percentage for each category 
              of categorical variable. The default value is COL.
   filetype = Use RTF or PDF to save the generated demographic table in an RTF file or a PDF 
              file. The default value is RTF. 
   footnote = Specify the footnote for the demographic table. 
   fnspace  = Specify the space before the footnote.
   page     = Use PORTRAIT or LANDSCAPE to set the page orientation. The default value is PORTRAIT.
   exmissing=  Use Y or N to indicate whether to exclude observations with missing value of categorical variables. The default value is N.
   deids    = Use Y or N to indicate whether to delete intermediate datasets. The default value is Y.
*/



====================================================;

%macro ggBaseline(
data=, 
var=, 
grp=,
grplabel=,  
stdiff=N,
totcol=N, 
pctype=col, 
exmissing=Y,
showP=Y,
filetype=rtf, 
file=, 
title=,
footnote=, 
fnspace=,
page=portrait,
deids=Y
);




%if &grp EQ %str() %then  

%ggBaseline1(
data=&data, 
var=&var, 
exmissing=&exmissing,
filetype=&filetype, 
file=&file, 
title=&title, 
footnote=&footnote,
fnspace=&fnspace,
page=&page,
deids=&deids
);


%else 

%ggBaseline2(
data=&data, 
var=&var, 
grp=&grp,
grplabel=&grplabel,  
stdiff=&stdiff,
totcol=&totcol, 
pctype=&pctype,
exmissing=&exmissing, 
showP=&showP,
filetype=&filetype, 
file=&file, 
title=&title,
footnote=&footnote, 
fnspace=&fnspace,
page=&page,
deids=&deids
);

%mend ggBaseline;





