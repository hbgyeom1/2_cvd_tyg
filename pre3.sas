libname ss "C:\Users\user\Documents\data\2_cvd_tyg";

proc import
datafile="C:\Users\user\Documents\data\2_cvd_tyg\dd.csv"
out=work.dd
dbms=csv
replace;
guessingrows=max;
run;

data dd; set dd;
if frs < 10 then frs_g = 1;
else if 10 <= frs < 20 then frs_g = 2;
else if frs >= 20 then frs_g = 3;
run;

data ss.out; set dd (drop=frs); run;