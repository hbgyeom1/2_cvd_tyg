libname ss "C:\Users\user\Documents\2_cvd_tyg\data\";

proc import
datafile="C:\Users\user\Documents\2_cvd_tyg\data\dd.csv"
out=work.dd
dbms=csv
replace;
guessingrows=max;
run;

proc means data=dd p25 p50 p75;
var tyg absi tyg_absi aip mets_ir;
run;

data dd; set dd;
if tyg < 8.1196963 then tyg_g = 1;
else if 8.1196963 <= tyg < 8.5440298 then tyg_g = 2;
else if 8.5440298 <= tyg < 9.0010997 then tyg_g = 3;
else if tyg >= 9.0010997 then tyg_g = 4;

if absi < 0.0745932 then absi_g = 1;
else if 0.0745932 <= absi < 0.0776539 then absi_g = 2;
else if 0.0776539 <= absi < 0.0808217 then absi_g = 3;
else if absi >= 0.0808217 then absi_g = 4;

if tyg_absi < 0.6153902 then tyg_absi_g = 1;
else if 0.6153902 <= tyg_absi < 0.6661442 then tyg_absi_g = 2;
else if 0.6661442 <= tyg_absi < 0.7181204 then tyg_absi_g = 3;
else if tyg_absi >= 0.7181204 then tyg_absi_g = 4;

if aip < 0.1144038 then aip_g = 1;
else if 0.1144038 <= aip < 0.3274493 then aip_g = 2;
else if 0.3274493 <= aip < 0.5541600 then aip_g = 3;
else if aip >= 0.5541600 then aip_g = 4;

if mets_ir < 30.2138336 then mets_ir_g = 1;
else if 30.2138336 <= mets_ir < 34.8679351 then mets_ir_g = 2;
else if 34.8679351 <= mets_ir < 39.9937125 then mets_ir_g = 3;
else if mets_ir >= 39.9937125 then mets_ir_g = 4;
run;

data ss.out; set dd; run;
