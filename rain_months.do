import excel "C:\Users\Amy\Google Drive\avg_rain\rain_months.xls", sheet("rain_months") firstrow clear
save "C:\Users\Amy\Google Drive\avg_rain\rain_months.dta", replace
keep ID_BARRIO BARRIO COMUNA ESTRA_MODA Avg_rain*  POINT_X POINT_Y
sum
save "C:\Users\Amy\Google Drive\avg_rain\rain_months.dta", replace
reshape long Avg_rain, i(ID_BARRIO) j(rain_month)
drop Avg_rain915_1

tostring rain_month, replace

gen year = "."
replace year = substr(rain_month,-2,.)
destring year, replace
replace year = 2000+year

destring rain_month, replace
gen month =.
replace month = 1 if rain_month == 115 |rain_month == 116
replace month = 2 if rain_month == 215 |rain_month == 216
replace month = 3 if rain_month == 315 |rain_month == 316
replace month = 4  if rain_month == 415 |rain_month == 416
replace month = 5 if rain_month == 515 |rain_month == 516
replace month = 6 if rain_month == 615 |rain_month == 616
replace month = 7 if rain_month == 715
replace month = 8 if rain_month == 815 
replace month = 9 if rain_month == 914 |rain_month == 915
replace month = 10 if rain_month == 1014 |rain_month == 1015
replace month = 11 if rain_month == 1114 |rain_month == 1115
replace month = 12 if rain_month == 1214 |rain_month == 1215
 
tab year month
destring *, replace

egen barrio_month = concat(ID_BARRIO month year)
duplicates drop barrio_month, force

save "C:\Users\Amy\Google Drive\avg_rain\rain_months.dta", replace
