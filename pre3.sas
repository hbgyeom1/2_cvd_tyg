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
if tyg < 8.1214804 then tyg_g = 1;
else if 8.1214804 <= tyg < 8.5469461 then tyg_g = 2;
else if 8.5469461 <= tyg < 9.0069994 then tyg_g = 3;
else if tyg >= 9.0069994 then tyg_g = 4;

if absi < 0.0746053 then absi_g = 1;
else if 0.0746053 <= absi < 0.0776736 then absi_g = 2;
else if 0.0776736 <= absi < 0.0808435 then absi_g = 3;
else if absi >= 0.0808435 then absi_g = 4;

if tyg_absi < 0.6157329 then tyg_absi_g = 1;
else if 0.6157329 <= tyg_absi < 0.6667297 then tyg_absi_g = 2;
else if 0.6667297 <= tyg_absi < 0.7187844 then tyg_absi_g = 3;
else if tyg_absi >= 0.7187844 then tyg_absi_g = 4;

if aip < 0.6157329 then aip_g = 1;
else if 0.6157329 <= aip < 0.6667297 then aip_g = 2;
else if 0.6667297 <= aip < 0.7187844 then aip_g = 3;
else if aip >= 0.7187844 then aip_g = 4;

if mets_ir < 30.2411040 then mets_ir_g = 1;
else if 30.2411040 <= mets_ir < 34.8993476 then mets_ir_g = 2;
else if 34.8993476 <= mets_ir < 40.0299336 then mets_ir_g = 3;
else if mets_ir >= 40.0299336 then mets_ir_g = 4;
run;

data ss.out; set dd; run;
