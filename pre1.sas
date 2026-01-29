libname kn "C:\Users\user\Documents\data\knhanes";
libname ss "C:\Users\user\Documents\2_cvd_tyg\data";

%macro mm(y1, y2);
data dd;
set
%do yy = &y1 %to &y2;
kn.hn%sysfunc(putn(&yy, Z2.))_all (keep=&vv)
%end;
;
run;
%mend;

%let vv =
year psu kstrata wt_itvex
/* demographic */
age sex town_t educ ho_incm marri_1 D_1_1 BP1 BD1_11 BS1_1 BS3_1
/* body */
HE_sbp2 HE_sbp3 HE_sbp HE_ht HE_wt HE_wc HE_BMI
/* lab */
HE_glu HE_chol HE_HDL_st2 HE_TG
HE_ast HE_alt HE_HB HE_BUN HE_crea HE_Uph
/* diagnostic */
DI1_dg DI2_dg DI3_dg DI5_dg DI6_dg
/* additional */
HE_prg;

%mm(07, 21)

data dd; set dd kn.hn24_all (keep=&vv); run;

data dd; set dd;
if year in (2007 2008 2009) then year_g = 1;
else if year in (2010 2011 2012) then year_g = 2;
else if year in (2013 2014 2015) then year_g = 3;
else if year in (2016 2017 2018) then year_g = 4;
else if year in (2019 2020 2021) then year_g = 5;
else if year = 2024 then year_g = 8;

if year = 2007 then wt_adj = wt_itvex * (100 / 2996);
else if year in (2008 2009) then wt_adj = wt_itvex * (200 / 2996);
else wt_adj = wt_itvex * (192 / 2996);

if 19 <= age < 40 then age_g = 1;
else if 40 <= age <65 then age_g = 2;
else if age >= 65 then age_g = 3;

if educ in (1 2 3) then educ_g = 1;
else if educ = 4 then educ_g = 2;
else if educ = 5 then educ_g = 3;
else if educ in (6 7 8) then educ_g = 4;

if HE_BMI = . then HE_BMI = (HE_wt / (HE_ht * HE_ht)) * 10000;
if HE_BMI < 18.5 then bmi_g = 1;
else if 18.5 <= HE_BMI < 23 then bmi_g = 2;
else if 23 <= HE_BMI < 25 then bmi_g = 3;
else if HE_BMI >= 25 then bmi_g = 4;

if marri_1 = 1 then marri_g = 1;
if marri_1 = 2 then marri_g = 2;

if D_1_1 in (1 2) then health_g = 1;
else if D_1_1 = 3 then health_g = 2;
else if D_1_1 in (4 5) then health_g = 3;

if BP1 in (1 2) then stress_g = 1;
else if BP1 = 3 then stress_g = 2;
else if BP1 = 4 then stress_g = 3;

if BD1_11 in (1 2) then drinking_g = 1;
else if BD1_11 in (3 4) then drinking_g = 2;
else if BD1_11 in (5 6) then drinking_g = 3;

if (BS1_1 in (1 2) & BS3_1 in (1 2 3)) or BS1_1 = 3
then smoking_g = (BS1_1 = 2 & BS3_1 in (1 2));
run;

data dd; set dd;
if HE_sbp = . then HE_sbp = (HE_sbp2 + HE_sbp3) / 2;

tyg = log(HE_TG * HE_glu / 2);
absi = (HE_wc / 100) / (HE_BMI**(2/3) * (HE_ht / 100)**(1/2));
tyg_absi = tyg * absi;
aip = log10(HE_TG / HE_HDL_st2);
mets_ir = (log((2 * HE_glu) + HE_TG) * HE_BMI) / log(HE_HDL_st2);

if sex = 1 then prg_g = 0;
else if  HE_prg in (0 8) then prg_g = 0;
else if HE_prg = 1 then prg_g = 1;
run;

data dd; set dd;
if DI1_dg in (0 8) then hypertension_g = 0;
else if DI1_dg = 1 then hypertension_g = 1;

if DI2_dg in (0 8) then dyslipidemia_g = 0;
else if DI2_dg = 1 then dyslipidemia_g = 1;

if DI3_dg in (0 8) then stroke_g = 0;
else if DI3_dg = 1 then stroke_g = 1;

if DI5_dg in (0 8) then mi_g = 0;
else if DI5_dg = 1 then mi_g = 1;

if DI6_dg in (0 8) then angina_g = 0;
else if DI6_dg = 1 then angina_g = 1;
run;

%let vv =
year year_g psu kstrata wt_adj
/* demographic */
age age_g sex town_t educ_g ho_incm bmi_g
marri_g health_g stress_g drinking_g smoking_g
/* body */
HE_sbp HE_wc HE_BMI
/* lab */
HE_glu HE_chol HE_HDL_st2 HE_TG
HE_ast HE_alt HE_HB HE_BUN HE_crea HE_Uph
/* diagnostic */
hypertension_g dyslipidemia_g stroke_g mi_g angina_g
/* index */
tyg absi tyg_absi aip mets_ir
/* additional */
prg_g;

data ss.dd; set dd (keep=&vv); run;
