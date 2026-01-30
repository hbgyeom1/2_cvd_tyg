libname ss "C:\Users\user\Documents\2_cvd_tyg\data\";

proc import
datafile="C:\Users\user\Documents\2_cvd_tyg\data\dd.csv"
out=work.dd
dbms=csv
replace;
guessingrows=max;
run;

proc means data=dd p25 p50 p75;
var tyg tyg_absi aip mets_ir;
run;

data dd; set dd;
if tyg < 8.0955987 then tyg_g = 1;
else if 8.0955987 <= tyg < 8.5139881 then tyg_g = 2;
else if 8.5139881 <= tyg < 8.9714485 then tyg_g = 3;
else if tyg >= 8.9714485 then tyg_g = 4;

if tyg_absi < 0.6098380 then tyg_absi_g = 1;
else if 0.6098380 <= tyg_absi < 0.6624194 then tyg_absi_g = 2;
else if 0.6624194 <= tyg_absi < 0.7164418 then tyg_absi_g = 3;
else if tyg_absi >= 0.7164418 then tyg_absi_g = 4;

if aip < 0.1071959 then aip_g = 1;
else if 0.1071959 <= aip < 0.3169530 then aip_g = 2;
else if 0.3169530 <= aip < 0.5406075 then aip_g = 3;
else if aip >= 0.5406075 then aip_g = 4;

if mets_ir < 29.7143656 then mets_ir_g = 1;
else if 29.7143656 <= mets_ir < 34.4682982 then mets_ir_g = 2;
else if 34.4682982 <= mets_ir < 39.6802362 then mets_ir_g = 3;
else if mets_ir >= 39.6802362 then mets_ir_g = 4;
run;

data ss.out; set dd; run;
