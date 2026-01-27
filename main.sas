libname ss "C:\Users\user\Documents\2_cvd_tyg\data\";

data out; set ss.out; run;


%let vv = 
age_g sex town_t educ_g ho_incm bmi_g marri_g
health_g stress_g drinking_g smoking_g
frs_g tyg_g tyg_bmi_g tyg_absi_g
hypertension_g dyslipidemia_g stroke_g mi_g angina_g;


proc freq data=out;
table &vv;
run;
