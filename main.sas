libname ss "C:\Users\user\Documents\2_cvd_tyg\data\";

data out; set ss.out; run;

%let ff = 
age_g sex town_t educ_g ho_incm bmi_g marri_g
health_g stress_g drinking_g smoking_g drug_g diabetes_g
hypertension_g dyslipidemia_g stroke_g mi_g angina_g;

%let nn = age HE_wc HE_BMI HE_sbp HE_glu HE_TG HE_HDL_st2 HE_chol
tyg tyg_bmi absi tyg_absi frs;

%macro sub(y);
%local i v; %let i=1; %let v=%scan(&ff, &i);
%do %while(&v ne );
proc surveymeans data=out;
cluster psu; strata kstrata; weight wt_adj; domain year_g*&v;
var &y;
run;
%let i=%eval(&i+1); %let v=%scan(&ff, &i);
%end;
%mend;


/*Table1.*/
/*overall crude factor*/
proc freq data=out; table &ff; run;
proc freq data=out; table frs_g*(&ff); run;
proc freq data=out; table tyg_g*(&ff); run;
proc freq data=out; table tyg_bmi_g*(&ff); run;
proc freq data=out; table tyg_absi_g*(&ff); run;

/*overall weighted factor*/
proc surveyfreq data=out;
cluster psu; strata kstrata; weight wt_adj;
table &ff / cl row; run;
proc surveyfreq data=out;
cluster psu; strata kstrata; weight wt_adj;
table frs_g*(&ff) / cl row; run;
proc surveyfreq data=out;
cluster psu; strata kstrata; weight wt_adj;
table tyg_g*(&ff) / cl row; run;
proc surveyfreq data=out;
cluster psu; strata kstrata; weight wt_adj;
table tyg_bmi_g*(&ff) / cl row; run;
proc surveyfreq data=out;
cluster psu; strata kstrata; weight wt_adj;
table tyg_absi_g*(&ff) / cl row; run;

/*by crude factor*/
proc means data=out; var &nn; run;
proc means data=out; var frs_g*(&nn); run;
proc means data=out; var tyg_g*(&nn); run;
proc means data=out; var tyg_bmi_g*(&nn); run;
proc means data=out; var tyg_absi_g*(&nn); run;

/*by weighted factor*/
proc surveymeans data=out;
cluster psu; strata kstrata; weight wt_adj;
var &nn; run;
proc surveymeans data=out;
cluster psu; strata kstrata; weight wt_adj; domain frs_g;
var &nn; run;
proc surveymeans data=out;
cluster psu; strata kstrata; weight wt_adj; domain tyg_g;
var &nn; run;
proc surveymeans data=out;
cluster psu; strata kstrata; weight wt_adj; domain tyg_bmi_g;
var &nn; run;
proc surveymeans data=out;
cluster psu; strata kstrata; weight wt_adj; domain tyg_absi_g;
var &nn; run;


/*Table2.*/
proc means data=out; class year_g; var frs; run;
proc means data=out; class year_g; var tyg; run;
proc means data=out; class year_g; var tyg_bmi; run;
proc means data=out; class year_g; var tyg_absi; run;

proc surveymeans data=out;
cluster psu; strata kstrata; weight wt_adj; domain year_g;
var frs; run;
proc surveymeans data=out;
cluster psu; strata kstrata; weight wt_adj; domain year_g;
var tyg; run;
proc surveymeans data=out;
cluster psu; strata kstrata; weight wt_adj; domain year_g;
var tyg_bmi; run;
proc surveymeans data=out;
cluster psu; strata kstrata; weight wt_adj; domain year_g;
var tyg_absi; run;

proc means data=out; class year_g &ff; ways 2; var frs; run;
proc means data=out; class year_g &ff; ways 2; var tyg; run;
proc means data=out; class year_g &ff; ways 2; var tyg_bmi; run;
proc means data=out; class year_g &ff; ways 2; var tyg_absi; run;

%sub(frs);
%sub(tyg);
%sub(tyg_bmi);
%sub(tyg_absi);


/*Table3.*/
proc surveyreg data=out;
cluster psu; strata kstrata; weight wt_adj; domain year_g;
model frs = year; run;

proc surveyreg data=out;
cluster psu; strata kstrata; weight wt_adj; domain year_g;
model tyg = year; run;

proc surveyreg data=out;
cluster psu; strata kstrata; weight wt_adj; domain year_g;
model tyg_bmi = year; run;

proc surveyreg data=out;
cluster psu; strata kstrata; weight wt_adj; domain year_g;
model tyg_absi = year; run;