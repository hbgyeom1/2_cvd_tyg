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


/* Table1. */
/* crude factor */
proc freq data=out; where subject = 1; table &ff; run;

proc freq data=out; where subject = 1;; table (&ff)*tyg_g; run;

proc freq data=out; where subject = 1;; table (&ff)*tyg_absi_g; run;

proc freq data=out; where subject = 1;; table (&ff)*aip_g; run;

proc freq data=out; where subject = 1;; table (&ff)*mets_ir_g; run;


/* crude numeric */
proc means data=out; where subject = 1;; var &nn; run;

proc sort data=out; by tyg_g; run;
proc means data=out; where subject = 1; by tyg_g; var &nn; run;

proc sort data=out; by tyg_absi_g; run;
proc means data=out; where subject = 1; by tyg_absi_g; var &nn; run;

proc sort data=out; by aip_g; run;
proc means data=out; where subject = 1; by aip_g; var &nn; run;

proc sort data=out; by mets_ir_g; run;
proc means data=out; where subject = 1; by mets_ir_g; var &nn; run;


/* weighted factor */
proc surveyfreq data=out nomcar;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
table &ff / cl row; run;

proc surveyfreq data=out nomcar;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
table tyg_g*(&ff) / cl row; run;

proc surveyfreq data=out nomcar;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
table tyg_absi_g*(&ff) / cl row; run;

proc surveyfreq data=out nomcar;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
table aip_g*(&ff) / cl row; run;

proc surveyfreq data=out nomcar;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
table mets_ir_g*(&ff) / cl row; run;


/* weighted numeric */
proc surveymeans data=out nomcar;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
var &nn; run;

proc sort data=out; by tyg_g; run;
proc surveymeans data=out nomcar;
where subject = 1; cluster psu; strata kstrata; weight wt_adj; by tyg_g;
var &nn; run;

proc sort data=out; by tyg_absi_g; run;
proc surveymeans data=out nomcar;
where subject = 1; cluster psu; strata kstrata; weight wt_adj; by tyg_absi_g;
var &nn; run;

proc sort data=out; by aip_g; run;
proc surveymeans data=out nomcar;
where subject = 1; cluster psu; strata kstrata; weight wt_adj; by aip_g;
var &nn; run;

proc sort data=out; by mets_ir_g; run;
proc surveymeans data=out nomcar;
where subject = 1; cluster psu; strata kstrata; weight wt_adj; by mets_ir_g;
var &nn; run;


/* Table2. */
proc sort data=out; by year_g; run;
proc surveymeans data=out nomcar;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
var tyg tyg_absi aip mets_ir; run;

proc surveymeans data=out nomcar;
where subject = 1; cluster psu; strata kstrata; weight wt_adj; by year_g;
var tyg tyg_absi aip mets_ir; run;

%macro tot;
%local i v; %let i=1; %let v=%scan(&ff, &i);
%do %while(%length(&v));
proc sort data=out; by &v; run;
proc surveymeans data=out nomcar;
where subject = 1; cluster psu; strata kstrata; weight wt_adj; by &v;
var tyg tyg_absi aip mets_ir; run;
%let i=%eval(&i+1); %let v=%scan(&ff, &i);
%end;
%mend;

%tot;

%macro sub;
%local i v; %let i=1; %let v=%scan(&ff, &i);
%do %while(%length(&v));
proc sort data=out; by year_g &v; run;
proc surveymeans data=out nomcar;
where subject = 1; cluster psu; strata kstrata; weight wt_adj; by year_g &v;
var tyg tyg_absi aip mets_ir; run;
%let i=%eval(&i+1); %let v=%scan(&ff, &i);
%end;
%mend;

%sub;


/* Table3. */
proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class tyg_g(ref = '1') / param=ref;
model hypertension_g(event = '1') = tyg_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class tyg_absi_g(ref = '1') / param=ref;
model hypertension_g(event = '1') = tyg_absi_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class aip_g(ref = '1') / param=ref;
model hypertension_g(event = '1') = aip_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class mets_ir_g(ref = '1') / param=ref;
model hypertension_g(event = '1') = mets_ir_g; run;

%let ff = 
age_g sex town_t educ_g ho_incm bmi_g
marri_g health_g stress_g drinking_g smoking_g;

%macro sublog(index, dis);
%local i v; %let i=1; %let v=%scan(&ff, &i);
%do %while(%length(&v));
proc sort data=out; by &v; run;
proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj; by &v;
class &index(ref = '1') / param=ref;
model &dis(event = '1') = &index; run;
%let i=%eval(&i+1); %let v=%scan(&ff, &i);
%end;
%mend;

%sublog(tyg_g, hypertension_g);
%sublog(tyg_absi_g, hypertension_g);
%sublog(aip_g, hypertension_g);

%let ff = 
age_g sex town_t educ_g ho_incm
marri_g health_g stress_g drinking_g smoking_g;

%sublog(mets_ir_g, hypertension_g);


proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class tyg_g(ref = '1') / param=ref;
model dyslipidemia_g(event = '1') = tyg_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class tyg_absi_g(ref = '1') / param=ref;
model dyslipidemia_g(event = '1') = tyg_absi_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class aip_g(ref = '1') / param=ref;
model dyslipidemia_g(event = '1') = aip_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class mets_ir_g(ref = '1') / param=ref;
model dyslipidemia_g(event = '1') = mets_ir_g; run;

%let ff = 
age_g sex town_t educ_g ho_incm bmi_g
marri_g health_g stress_g drinking_g smoking_g;

%sublog(tyg_g, dyslipidemia_g);
%sublog(tyg_absi_g, dyslipidemia_g);
%sublog(aip_g, dyslipidemia_g);

%let ff = 
age_g sex town_t educ_g ho_incm
marri_g health_g stress_g drinking_g smoking_g;

%sublog(mets_ir_g, dyslipidemia_g);


proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class tyg_g(ref = '1') / param=ref;
model stroke_g(event = '1') = tyg_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class tyg_absi_g(ref = '1') / param=ref;
model stroke_g(event = '1') = tyg_absi_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class aip_g(ref = '1') / param=ref;
model stroke_g(event = '1') = aip_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class mets_ir_g(ref = '1') / param=ref;
model stroke_g(event = '1') = mets_ir_g; run;

%let ff = 
age_g sex town_t educ_g ho_incm bmi_g
marri_g health_g stress_g drinking_g smoking_g;

%sublog(tyg_g, stroke_g);
%sublog(tyg_absi_g, stroke_g);
%sublog(aip_g, stroke_g);

%let ff = 
age_g sex town_t educ_g ho_incm
marri_g health_g stress_g drinking_g smoking_g;

%sublog(mets_ir_g, stroke_g);


proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class tyg_g(ref = '1') / param=ref;
model mi_g(event = '1') = tyg_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class tyg_absi_g(ref = '1') / param=ref;
model mi_g(event = '1') = tyg_absi_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class aip_g(ref = '1') / param=ref;
model mi_g(event = '1') = aip_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class mets_ir_g(ref = '1') / param=ref;
model mi_g(event = '1') = mets_ir_g; run;

%let ff = 
age_g sex town_t educ_g ho_incm bmi_g
marri_g health_g stress_g drinking_g smoking_g;

%sublog(tyg_g, mi_g);
%sublog(tyg_absi_g, mi_g);
%sublog(aip_g, mi_g);

%let ff = 
age_g sex town_t educ_g ho_incm
marri_g health_g stress_g drinking_g smoking_g;

%sublog(mets_ir_g, mi_g);


proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class tyg_g(ref = '1') / param=ref;
model angina_g(event = '1') = tyg_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class tyg_absi_g(ref = '1') / param=ref;
model angina_g(event = '1') = tyg_absi_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class aip_g(ref = '1') / param=ref;
model angina_g(event = '1') = aip_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class mets_ir_g(ref = '1') / param=ref;
model angina_g(event = '1') = mets_ir_g; run;

%let ff = 
age_g sex town_t educ_g ho_incm bmi_g
marri_g health_g stress_g drinking_g smoking_g;

%sublog(tyg_g, angina_g);
%sublog(tyg_absi_g, angina_g);
%sublog(aip_g, angina_g);

%let ff = 
age_g sex town_t educ_g ho_incm
marri_g health_g stress_g drinking_g smoking_g;

%sublog(mets_ir_g, angina_g);


proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class tyg_g(ref = '1') / param=ref;
model hypertension_g(event = '1') = tyg_g age_g sex town_t educ_g ho_incm marri_g
health_g stress_g drinking_g smoking_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class tyg_absi_g(ref = '1') / param=ref;
model hypertension_g(event = '1') = tyg_absi_g age_g sex town_t educ_g ho_incm marri_g
health_g stress_g drinking_g smoking_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class aip_g(ref = '1') / param=ref;
model hypertension_g(event = '1') = aip_g age_g sex town_t educ_g ho_incm marri_g
health_g stress_g drinking_g smoking_g; run;

proc surveylogistic data=out;
where subject = 1; cluster psu; strata kstrata; weight wt_adj;
class mets_ir_g(ref = '1') / param=ref;
model hypertension_g(event = '1') = mets_ir_g age_g sex town_t educ_g ho_incm marri_g
health_g stress_g drinking_g smoking_g; run;