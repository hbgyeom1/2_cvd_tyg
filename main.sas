libname ss "C:\Users\user\Documents\2_cvd_tyg\data\";

data out; set ss.out; run;

proc sort data=out; by subject; run;


%let ff = 
age_g sex town_t educ_g ho_incm bmi_g
marri_g health_g stress_g drinking_g smoking_g
hypertension_g dyslipidemia_g stroke_g mi_g angina_g;

%let nn = age HE_BMI HE_wc absi HE_sbp  
HE_glu HE_chol HE_HDL_st2 HE_TG
HE_ast HE_alt HE_HB HE_BUN HE_crea HE_Uph
tyg tyg_absi aip mets_ir;


/* Table1. */
/* crude factor */
proc freq data=out; by subject; table &ff; run;

proc freq data=out; by subject; table (&ff)*tyg_g; run;

proc freq data=out; by subject; table (&ff)*tyg_absi_g; run;

proc freq data=out; by subject; table (&ff)*aip_g; run;

proc freq data=out; by subject; table (&ff)*mets_ir_g; run;


/* crude numeric */
proc means data=out; by subject; var &nn; run;

proc sort data=out; by subject tyg_g; run;
proc means data=out; by subject tyg_g; var &nn; run;

proc sort data=out; by subject tyg_absi_g; run;
proc means data=out; by subject tyg_absi_g; var &nn; run;

proc sort data=out; by subject aip_g; run;
proc means data=out; by subject aip_g; var &nn; run;

proc sort data=out; by subject mets_ir_g; run;
proc means data=out; by subject mets_ir_g; var &nn; run;


/* weighted factor */
proc surveyfreq data=out nomcar;
cluster psu; strata kstrata; weight wt_adj; by subject;
table &ff / cl row; run;

proc surveyfreq data=out nomcar;
cluster psu; strata kstrata; weight wt_adj; by subject;
table tyg_g*(&ff) / cl row; run;

proc surveyfreq data=out nomcar;
cluster psu; strata kstrata; weight wt_adj; by subject;
table tyg_absi_g*(&ff) / cl row; run;

proc surveyfreq data=out nomcar;
cluster psu; strata kstrata; weight wt_adj; by subject;
table aip_g*(&ff) / cl row; run;

proc surveyfreq data=out nomcar;
cluster psu; strata kstrata; weight wt_adj; by subject;
table mets_ir_g*(&ff) / cl row; run;


/* weighted numeric */
proc surveymeans data=out nomcar;
cluster psu; strata kstrata; weight wt_adj; by subject;
var &nn; run;

proc surveymeans data=out nomcar;
cluster psu; strata kstrata; weight wt_adj; by subject; domain tyg_g;
var &nn; run;

proc surveymeans data=out nomcar;
cluster psu; strata kstrata; weight wt_adj; by subject; domain tyg_absi_g;
var &nn; run;

proc surveymeans data=out nomcar;
cluster psu; strata kstrata; weight wt_adj; by subject; domain aip_g;
var &nn; run;

proc surveymeans data=out nomcar;
cluster psu; strata kstrata; weight wt_adj; by subject; domain mets_ir_g;
var &nn; run;


/* Table2. */
proc surveymeans data=out nomcar;
cluster psu; strata kstrata; weight wt_adj; by subject; domain year_g;
var tyg; run;

proc surveymeans data=out nomcar;
cluster psu; strata kstrata; weight wt_adj; by subject; domain year_g;
var tyg_absi; run;

proc surveymeans data=out nomcar;
cluster psu; strata kstrata; weight wt_adj; by subject; domain year_g;
var aip; run;

proc surveymeans data=out nomcar;
cluster psu; strata kstrata; weight wt_adj; by subject; domain year_g;
var mets_ir; run;

%macro tot(y);
%local i v; %let i=1; %let v=%scan(&ff, &i);
%do %while(&v ne );
proc surveymeans data=out nomcar;
cluster psu; strata kstrata; weight wt_adj; by subject; domain &v;
var &y; run;
%let i=%eval(&i+1); %let v=%scan(&ff, &i);
%end;
%mend;

%tot(tyg);
%tot(tyg_absi);
%tot(aip);
%tot(mets_ir);

%macro sub(y);
%local i v; %let i=1; %let v=%scan(&ff, &i);
%do %while(&v ne );
proc surveymeans data=out nomcar;
cluster psu; strata kstrata; weight wt_adj; by subject; domain year_g*&v;
var &y; run;
%let i=%eval(&i+1); %let v=%scan(&ff, &i);
%end;
%mend;

%sub(tyg);
%sub(tyg_absi);
%sub(aip);
%sub(mets_ir);


/* Table3. */
proc surveyreg data=out;
cluster psu; strata kstrata; weight wt_adj; domain year_g;
model tyg = year; run;

proc surveyreg data=out;
cluster psu; strata kstrata; weight wt_adj; domain year_g;
model tyg_absi = year; run;

proc surveyreg data=out;
cluster psu; strata kstrata; weight wt_adj; domain year_g;
model aip = year; run;

proc surveyreg data=out;
cluster psu; strata kstrata; weight wt_adj; domain year_g;
model tyg_absi = year; run;