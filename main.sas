libname ss "C:\Users\user\Documents\2_cvd_tyg\data\";

data out; set ss.out; run;

/*Table1.*/
%let ff = 
age_g sex town_t educ_g ho_incm bmi_g marri_g
health_g stress_g drinking_g smoking_g
hypertension_g dyslipidemia_g stroke_g mi_g angina_g;

proc freq data=out; table &ff; run;
proc freq data=out; table frs_g*(&ff); run;
proc freq data=out; table tyg_g*(&ff); run;
proc freq data=out; table tyg_bmi_g*(&ff); run;
proc freq data=out; table tyg_absi_g*(&ff); run;

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

%let nn = age HE_wc HE_BMI HE_sbp HE_glu HE_TG HE_HDL_st2 HE_chol
tyg tyg_bmi absi tyg_absi frs;

proc means data=out; var &nn; run;
proc means data=out; var frs_g*(&nn); run;
proc means data=out; var tyg_g*(&nn); run;
proc means data=out; var tyg_bmi_g*(&nn); run;
proc means data=out; var tyg_absi_g*(&nn); run;

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

proc surveymeans data=out;
cluster psu; strata kstrata; weight wt_adj; domain year_g*age_g;
var frs; run;
