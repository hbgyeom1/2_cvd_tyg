libname ss "C:\Users\user\Documents\2_cvd_tyg\data\";

proc import
datafile="C:\Users\user\Documents\2_cvd_tyg\data\dd.csv"
out=work.dd
dbms=csv
replace;
guessingrows=max;
run;

proc means data=dd p25 p50 p75;
var tyg tyg_bmi tyg_absi;
run;

data dd; set dd;
if tyg < 8.2474820 then tyg_g = 1;
else if 8.2474820 <= tyg < 8.6569551 then tyg_g = 2;
else if 8.4998436 <= tyg < 9.0994088 then tyg_g = 3;
else if tyg >= 9.0994088 then tyg_g = 4;

if tyg_bmi < 184.9496035 then tyg_bmi_g = 1;
else if 184.9496035 <= tyg_bmi < 208.1456404 then tyg_bmi_g = 2;
else if 208.1456404 <= tyg_bmi < 232.9991500 then tyg_bmi_g = 3;
else if tyg_bmi >= 232.9991500 then tyg_bmi_g = 4;

if tyg_absi < 0.6368466 then tyg_absi_g = 1;
else if 0.6368466 <= tyg_absi < 0.6836926 then tyg_absi_g = 2;
else if 0.6836926 <= tyg_absi < 0.7318431 then tyg_absi_g = 3;
else if tyg_absi >= 0.7318431 then tyg_absi_g = 4;
run;

data dd; set dd;
if frs < 0.05 then frs_g = 1;
else if 0.05 <= frs < 0.075 then frs_g = 2;
else if 0.075 <= frs < 0.2 then frs_g = 3;
else if frs >= 0.2 then frs_g = 4;
run;

data ss.out; set dd; run;
