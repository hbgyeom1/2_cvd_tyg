libname ss "C:\Users\user\Documents\2_cvd_tyg\data\";

data out; set ss.out; run;


%let vv = 
age_g sex town_t educ_g ho_incm bmi_g marri_g
health_g stress_g drinking_g smoking_g
hypertension_g dyslipidemia_g stroke_g mi_g angina_g;


proc surveyfreq data=out; table &vv; run;
proc surveyfreq data=out; table frs_g*(&vv); run;
proc surveyfreq data=out; table tyg_g*(&vv); run;
proc surveyfreq data=out; table tyg_bmi_g*(&vv); run;
proc surveyfreq data=out; table tyg_absi_g*(&vv); run;

proc surveyfreq data=out;
cluster psu; strata kstrata; weight wt_adj;
table &vv / cl row; run;
proc surveyfreq data=out;
cluster psu; strata kstrata; weight wt_adj;
table frs_g*(&vv) / cl row; run;
proc surveyfreq data=out;
cluster psu; strata kstrata; weight wt_adj;
table tyg_g*(&vv) / cl row; run;
proc surveyfreq data=out;
cluster psu; strata kstrata; weight wt_adj;
table tyg_bmi_g*(&vv) / cl row; run;
proc surveyfreq data=out;
cluster psu; strata kstrata; weight wt_adj;
table tyg_absi_g*(&vv) / cl row; run;