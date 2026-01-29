libname ss "C:\Users\user\Documents\2_cvd_tyg\data\";

data out; set ss.out; run;

%let ff = 
age_g sex town_t educ_g ho_incm bmi_g
marri_g health_g stress_g drinking_g smoking_g
hypertension_g dyslipidemia_g stroke_g mi_g angina_g;

%let nn = age HE_BMI HE_wc absi HE_sbp  
HE_glu HE_chol HE_HDL_st2 HE_TG
HE_ast HE_alt HE_HB HE_BUN HE_crea HE_Uph
tyg tyg_absi aip mets_ir;

/*Table1.*/
/*crude factor*/
proc freq data=out; table &ff; run;
proc freq data=out; table (&ff)*tyg_g; run;
proc freq data=out; table (&ff)*absi_g; run;
proc freq data=out; table (&ff)*tyg_absi_g; run;
proc freq data=out; table (&ff)*aip_g; run;
proc freq data=out; table (&ff)*mets_ir_g; run;

/*crude numeric*/
proc means data=out; var &nn; run;
proc means data=out; class tyg_g; var &nn; run;
proc means data=out; class tyg_absi_g; var &nn; run;
proc means data=out; class aip_g; var &nn; run;
proc means data=out; class mets_ir_g; var &nn; run;


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





/*weighted factor*/
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

/*weighted numeric*/
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