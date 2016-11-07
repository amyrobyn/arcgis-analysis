/****************************************************
 *Amykr Krystosik                  					*
 *chikv, dengue, and zika in cali, colombia       	*
 *PHD dissertation- arcgis analysis only               *
 *last updated July 29, 2016 
 * FILE NAME: neighborhood_data_july29.do* 
 ***************************************************/
cd "C:\Users\Amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models"
capture log close 
log using "arcgis_analysis_only_oct_26_2016_mes.smcl", text replace 
set scrollbufsize 100000
set more 1

foreach dataset in "pop_total_sex_barrio.csv" "ed_level_approved_barrio.csv" "education_barrio.csv" "houses_barrios.csv" "economy_barrio.csv" "type_of_work_barrio.csv" "estrato_por_geografia_barrio.csv" "hombres_parentesco_con_jefe_barrio.csv" "parentesco_con_jefe_barrio.csv" "mujeres_parentesco_con_jefe_barrio.csv" "marital_status_barrio.csv" "ethnicity_barrio.csv" "limitations_barrio.csv" "literacy_barrio.csv" "school_assistence_barrio.csv" "barrios.csv" {  
		insheet using "`dataset'", clear
		capture drop _merge		
		destring codigo_barrio, replace 
		drop if codigo_barrio == .

			capture drop freq_barrio
			bysort  codigo_barrio: gen freq_barrio = _N
			tab freq_barrio 
			drop if freq_barrio >1
			capture drop _merge
			save "`dataset'.dta",  replace

			merge 1:1 codigo_barrio using `dataset'.dta
			capture drop _merge
		save "`dataset'.dta",  replace
	}	
	
	use barrios.csv.dta, clear
			capture drop _merge
			drop if codigo_barrio ==.
			capture	drop _merge
			save barrios.csv.dta, replace
			use barrios.csv.dta, clear

		merge 1:1 codigo_barrio using school_assistence_barrio.csv.dta
		drop _merge
		save merged_barrio.dta, replace
		
		import excel "C:\Users\amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\canals\distance_m.xls", sheet("distance_m") firstrow clear
		keep barriosID_BARRIO dist_barrio_canal_m dist_water_barrio_m
		rename barriosID_BARRIO  codigo_barrio 
		destring codigo_barrio, replace
		save "C:\Users\amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\canals\dist_canal_water_barrio.dta", replace
		merge 1:1 codigo_barrio using merged_barrio.dta
		save merged_barrio.dta, replace
	
*merge barrio data**	
foreach dataset in "ed_level_approved_barrio.csv" "education_barrio.csv" "houses_barrios.csv" "economy_barrio.csv" "type_of_work_barrio.csv" "estrato_por_geografia_barrio.csv" "hombres_parentesco_con_jefe_barrio.csv" "parentesco_con_jefe_barrio.csv" "mujeres_parentesco_con_jefe_barrio.csv" "marital_status_barrio.csv" "ethnicity_barrio.csv" "limitations_barrio.csv" "literacy_barrio.csv" { 
	use merged_barrio.dta, clear
			drop if codigo_barrio ==.
			capture drop _merge
	merge 1:1 codigo_barrio using `dataset'.dta
	drop _merge
	save merged_barrio.dta, replace
}	

*merge case data**	
*i have to create counts by neighborhod csv for this analysis.
*import case data with barrios
		insheet using "Join_Output_TableToExcel.csv", clear
		keep id_barri_1 codigo
		rename id_barri_1 codigo_barrio
		destring codigo_barrio, replace
		drop if codigo_barrio ==.
		save "cases_barrio.dta",  replace

	
use "C:\Users\Amykr\OneDrive\epi analysis\temp3.dta", clear 			
	destring cod_barrio, replace
	drop if cod_barrio ==.
	rename CODIGO codigo
	capture drop _merge
	merge 1:1 codigo using "cases_barrio.dta"
	capture drop _merge
	
	gen mes=.
		replace mes = 12 if semana <=53
		replace mes = 11 if semana <=48
		replace mes = 10 if semana <=44
		replace mes = 9 if semana <=40
		replace mes = 8 if semana <=36
		replace mes = 7 if semana <=32
		replace mes = 6 if semana <=28
		replace mes = 5 if semana <=24
		replace mes = 4 if semana <=16
		replace mes = 3 if semana <=12
		replace mes = 2 if semana <=8
		replace mes = 1 if semana >=1 & semana <=4

		rename mes month
		rename anos year
		egen monthyear = concat(month year)
		
	save merged_barrio_cases.dta, replace
	
use "merged_barrio_cases.dta", clear
		keep if cod_eve == 895| cod_eve ==.
		save zika.dta, replace	
use "merged_barrio_cases.dta", clear
		keep if cod_eve == 217| cod_eve ==.
		save chik.dta, replace	
use "merged_barrio_cases.dta", clear
		keep if cod_eve == 210|  cod_eve==220|cod_eve==580| cod_eve ==.
		save dengue.dta, replace	
use "merged_barrio_cases.dta", clear
		keep if cod_eve == . 
		save nodisease.dta, replace	

foreach dataset in "zika" "chik" "dengue"{ 
		use `dataset', clear
			
		destring cod_barrio, replace
		local i = `i' + 1
		capture drop casecount
		gen casecount = 1
		replace casecount = 0 if cod_eve ==.
		rename casecount casecount`i'
		
		collapse (sum) casecount, by(codigo_barrio monthyear)
		replace casecount`i' = 0 if casecount`i' ==.
		*reshape wide casecount`i' , i(codigo_barrio) j(monthyear) s 
		save "`dataset'",  replace
	}

	
foreach dataset in "zika.dta" "chik.dta" "dengue.dta"{ 
		use merged_barrio.dta, clear
		capture drop _merge
		merge 1:m codigo_barrio using `dataset'
		drop _merge
		merge m:1 codigo_barrio using "pop_total_sex_barrio.csv.dta"
		save merged_barrio`dataset', replace	
	
rename casecount* count`dataset'barrio

destring *, replace

gen asistencia_educativa_ratio = asistencia_educativa_si/asistencia_educativa_no
gen assist_educ_P = asistencia_educativa_si/total_pop
gen logassist_educ_P = log(assist_educ_P)

gen alguna_limitacin_ratio = alguna_limitacin_si/alguna_limitacin_no
gen alguna_limit_p =alguna_limitacin_si/total_pop
gen logalguna_limit_p =log(alguna_limit_p)

gen sabe_leer_y_escribir_ratio = sabe_leer_y_escribir_si/sabe_leer_y_escribir_no
gen literate_p = sabe_leer_y_escribir_si/total_pop


egen ed_index_sum= rowtotal(prejardin - superiorypostgrado)

egen services_index= rowtotal(vivienda_con_acueducto vivienda_con_alcantarillado vivienda_con_energia vivienda_con_gas vivienda_con_telefono vivienda_con_)


egen serv_cov_index= rowtotal(cobertura_vivienda_con____acuedu cobertura_vivienda_con____alcant cobertura_vivienda_con____energi cobertura_vivienda_con____gas cobertura_vivienda_con____telefo)


ds, has(type string) 
foreach var of varlist `r(varlist)' { 
replace `var' = "." if `var' =="NA"
destring `var', replace
}

egen assist_esc_ind= rowtotal(tasa_de_asistencia_escolar_5 tasa_de_asistencia_escolar_6__10 tasa_de_asistencia_escolar_11__1 v27 tasa_de_asistencia_escolar_15__1 tasa_de_asistencia_escolar_5__16 tasa_de_asistencia_escolar_17__2 ed_index_sum)

destring hogares, gen(hogares2) ignore(",")
egen home_occupied = rowtotal(occupation_condition_ocupada_con v5)
gen home_occupied_p = home_occupied /hogares2

gen home_occupied_perc = home_occupied/occupation_condition_total 

egen home_empty = rowtotal(occupation_condition_desocupadas occupation_condition_desocupada_)
gen home_empty_p = home_empty/occupation_condition_total 

replace estrato_mon3210=. if estrato_mon3210==10 

gen maletofemale = male_pop/female_pop
gen female_p= female_pop/total_p
gen male_p= male_pop/total_p

drop _merge
tostring monthyear, replace
merge m:1 monthyear using "C:\Users\Amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\temperature_data_raw\temp_anomoly_2014-2016.dta"
drop _merge

egen barrio_month = concat(codigo_barrio month year)
merge m:1 barrio_month using "C:\Users\amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\data\avg_rain\rain_months.dta"
*reshape long
save temp.dta, replace

replace year = 2014 if year ==14
replace year = 2015 if year ==15
replace year = 2016 if year ==16

rename negro__a___mulato__afrocolombian negro__a___mulato__afro

export excel using "neighborhood_GWR_indices`dataset'", firstrow(variables) replace

capture drop _merge
save merged_barrio_july72016`dataset'.dta, replace	

drop if codigo_barrio  ==.

rename asistencia_educativa_0__4_aos_si asist_educ_0__4_aos_si
rename occupation_condition_ocupada_con occupation_ocupada_con
rename occupation_condition_desocupadas occupation_desocupadas
rename cobertura_vivienda_con____acuedu_avg cobertura_acuedu
rename cobertura_vivienda_con____alcant  cobertura_alcant 
rename cobertura_vivienda_con____energi cobertura_energi
rename cobertura_vivienda_con____gas cobertura_gas
rename cobertura_vivienda_con____telefo cobertura_telefo
rename unidades_auxiliares_tipo_gerenci unidades_aux_tipo_gerenci
rename unidades_auxiliares_diferentes_d unidades_aux_diferentes_d
rename busc_trabajo_pero_haba_trabajado busc_trabajo_trabajado
rename busc_trabajo_por_primera_vez  busc_trabajo_primera_vez 
rename estudi_y_no_trabaj_ni_busc_traba estudi_no_trabaj_ni_busc
rename realiz_oficios_del_hogar_y_no_tr oficios_hogar
rename incapacitado_permanentemente_par incap_perm 
rename vivi_de_jubilacin_o_renta_y_no_t  vivi_de_jubilacin
rename nocasadoylleva2oaosviviendoparej nocasado_2oaosin_parej
rename limitacin_para_usar_brazos_o_man limit_usar_brazos_o_man
rename sabe_leer_y_escribir_no_informa sabe_leer_y_escribir
rename sabe_leer_y_escribir_15__24_aos_ sabe_leer_escribir_15__24
drop if codigo_barrio ==.

gen  negro__a___mulato__afrop =  negro__a___mulato__afro/total_pop


sum occupation_desocupadas occupation_condition_desocupada_ occupation_ocupada_con occupation_condition_total desocupada
gen unem_p = desocupada/total_pop
*gen unem_p= occupation_condition_desocupada_ /occupation_condition_total
gen home_p= oficios_hogar/total_pop
gen single_p = soltero_a_/total_pop


foreach var in serv_cov_index assist_educ_P  alguna_limit_p literate_p ed_index_sum services_index  assist_esc_ind home_empty_p  estrato_mon3210 male_p negro__a___mulato__afrop unem_p home_p single_p cobertura_alcant cobertura_energi  arean3210 Avg_rain {
						capture destring `var', replace
						egen `var'b = mean(`var')
						replace `var' = `var'b if `var'==.
						drop `var'b
						
						replace `var' = . if `var'==0

			}
			
	recast int month, force
	recast int year, force
	recast int estrato_mon3210, force

*order count* POINT_X POINT_Y Avg_rain temp_anom_median_c estrato_mon3210 services_coverage_index_sum empty_ratio total_pop educ_ratio arean3210 sabe_leer_y_escribir_ratio maletofemale
outsheet using "C:\Users\amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\gwr4\disease_counts_mes`dataset'.csv", comma nolabel replace
preserve
collapse (sum) count*, by(codigo_barrio)
save count`dataset', replace
restore
preserve
collapse (mean) POINT_X POINT_Y serv_cov_index assist_educ_P  alguna_limit_p literate_p ed_index_sum services_index assist_esc_ind home_empty_p  estrato_mon3210 male_p negro__a___mulato__afrop unem_p home_p single_p cobertura_alcant cobertura_energi  arean3210 Avg_rain , by(codigo_barrio)

merge 1:1 codigo_barrio using count`dataset'
drop _merge POINT_X POINT_Y 
merge 1:1 codigo_barrio using "C:\Users\amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\data\avg_rain\rxy.dta"
outsheet using "C:\Users\amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\gwr4\disease_counts`dataset'.csv", comma nolabel replace
restore

drop barrio_month 
egen barrio_month = concat(codigo_barrio month year)
sort barrio_month
drop barrio
duplicates drop barrio_month, force
save merge102816`dataset', replace
}
capture drop _merge
merge 1:1 barrio_month using "C:\Users\Amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\merge102816zika" 
capture drop _merge
merge 1:1 barrio_month using  "C:\Users\Amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\merge102816chik"
save merged_barrios_rain_temp_diseases, replace
outsheet using "merged_102816", comma replace

use merged_barrios_rain_temp_diseases


destring monthyear, replace
gen monthtime = ym(year, month)  
format %tm  monthtime 
tab monthtime 

xtset codigo_barrio monthtime , monthly

foreach var in serv_cov_index assist_educ_P  alguna_limit_p literate_p ed_index_sum services_index  assist_esc_ind home_empty_p  estrato_mon3210 male_p negro__a___mulato__afrop unem_p home_p single_p cobertura_alcant cobertura_energi  arean3210 Avg_rain {
summarize `var', meanonly
gen anm_`var' = `var' - r(mean)
gen l1anm_`var' = L.anm_`var'
gen l2anm_`var' = L.l1anm_`var'

foreach disaease in countdenguedtabarrio countzikadtabarrio countzikadtabarrio{ 
xtserial  `disaease' `var' 
xtserial  `disaease' anm_`var' 
xtserial  `disaease' l1anm_`var'
xtserial  `disaease'  l2anm_`var' 
}
}

gen rainlag1= L.Avg_rain
gen templag1= L.temp_anom_median_c

rename hogares2 hogar
drop v2 acuerdoc32  _merge limitesc32 vivienda_c~_   hogares
drop if estrata_moda =="NR"
destring *, replace

cd "C:\Users\amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\output"
keep  POINT_X POINT_Y  codigo_barrio nombre countdenguedtabarrio  countchikdtabarrio countzikadtabarrio monthtime  year month rainlag1 Avg_rain anm_serv_cov_index anm_services_index anm_assist_educ_P anm_alguna_limit_p anm_literate_p anm_ed_index_sum anm_assist_esc_ind anm_home_empty_p anm_estrato_mon3210 anm_male_p anm_negro__a___mulato__afrop anm_unem_p anm_home_p anm_single_p anm_cobertura_alcant anm_cobertura_energi anm_arean3210 serv_cov_index services_index assist_educ_P alguna_limit_p literate_p ed_index_sum assist_esc_ind home_empty_p estrato_mon3210 male_p negro__a___mulato__afrop unem_p home_p single_p cobertura_alcant cobertura_energi arean3210 anm_Avg_rain l1anm_Avg_rain  temp_anom_median_c templag1


	misstable sum
	foreach var in rainlag1 Avg_rain anm_serv_cov_index anm_services_index anm_assist_educ_P anm_alguna_limit_p anm_literate_p anm_ed_index_sum anm_assist_esc_ind anm_home_empty_p anm_estrato_mon3210 anm_male_p anm_negro__a___mulato__afrop anm_unem_p anm_home_p anm_single_p anm_cobertura_alcant anm_cobertura_energi anm_arean3210 serv_cov_index services_index assist_educ_P alguna_limit_p literate_p ed_index_sum assist_esc_ind home_empty_p estrato_mon3210 male_p negro__a___mulato__afrop unem_p home_p single_p cobertura_alcant cobertura_energi arean3210 anm_Avg_rain l1anm_Avg_rain  temp_anom_median_c templag1{
			egen miss`var' = mean(`var'), by(codigo_barrio)
			replace `var' = miss`var' if `var' ==. 
			drop miss`var'
			
			egen miss`var' = mean(`var')
			replace `var' = miss`var' if `var' ==. 
			drop miss`var'
			}
			
			misstable sum

			save poisson, replace
preserve
	
use poisson, clear
	bysort  codigo_barrio: gen sumcountdenguedtabarrio = sum(countdenguedtabarrio)
	egen dengue= max(sumcountdenguedtabarrio), by(codigo_barrio) 

	bysort  codigo_barrio: gen sumcountzikadtabarrio = sum(countzikadtabarrio)
	egen zika= max(sumcountzikadtabarrio), by(codigo_barrio) 

	bysort  codigo_barrio: gen sumcountchikvdtabarrio = sum(countchikdtabarrio)
	egen chikv = max(sumcountchikvdtabarrio), by(codigo_barrio) 
	
	collapse (mean) POINT_X POINT_Y  chikv zika dengue rainlag1 Avg_rain anm_serv_cov_index anm_services_index anm_assist_educ_P anm_alguna_limit_p anm_literate_p anm_ed_index_sum anm_assist_esc_ind anm_home_empty_p anm_estrato_mon3210 anm_male_p anm_negro__a___mulato__afrop anm_unem_p anm_home_p anm_single_p anm_cobertura_alcant anm_cobertura_energi anm_arean3210 serv_cov_index services_index assist_educ_P alguna_limit_p literate_p ed_index_sum assist_esc_ind home_empty_p estrato_mon3210 male_p negro__a___mulato__afrop unem_p home_p single_p cobertura_alcant cobertura_energi arean3210 anm_Avg_rain l1anm_Avg_rain  temp_anom_median_c templag1, by(codigo_barrio)

		*rename POINT_X POINT_X1
		*rename POINT_Y POINT_Y1 
		*merge m:1 codigo_barrio using "C:\Users\amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\data\avg_rain\rxy.dta"
	
	order  chikv zika dengue  POINT_Y* POINT_X*
	
	drop anm_serv_cov_index anm_assist_educ_P anm_alguna_limit_p anm_literate_p anm_ed_index_sum anm_services_index anm_assist_esc_ind anm_home_empty_p anm_estrato_mon3210 anm_male_p anm_negro__a___mulato__afrop anm_unem_p anm_home_p anm_single_p anm_cobertura_alcant anm_cobertura_energi anm_arean3210 anm_Avg_rain  
	*year month monthtime 

	misstable sum

	outsheet using disease_counts.csv, comma nolabel replace
	
restore



	global fixed "rainlag1 Avg_rain temp_anom_median_c templag1 serv_cov_index services_index assist_educ_P alguna_limit_p literate_p ed_index_sum assist_esc_ind home_empty_p estrato_mon3210 male_p negro__a___mulato__afrop unem_p home_p single_p cobertura_alcant cobertura_energi arean3210"
	global fixedanom "anm_Avg_rain l1anm_Avg_rain temp_anom_median_c templag1 anm_serv_cov_index anm_services_index anm_assist_educ_P anm_alguna_limit_p anm_literate_p anm_ed_index_sum anm_assist_esc_ind anm_home_empty_p anm_estrato_mon3210 anm_male_p anm_negro__a___mulato__afrop anm_unem_p anm_home_p anm_single_p anm_cobertura_alcant anm_cobertura_energi anm_arean3210"

foreach var in `fixed' `fixedanom'{
					histogram `var' 
					graph export `var'.tif, replace
				}

table1, vars(countdenguedtabarrio conts\  countchikdtabarrio conts\ countzikadtabarrio conts\  rainlag1 conts\ Avg_rain conts\ temp_anom_median_c conts\ templag1 conts\ serv_cov_index conts\ services_index conts\ assist_educ_P contn\ alguna_limit_p contn\ literate_p conts\ ed_index_sum conts\ assist_esc_ind conts\ home_empty_p conts\ estrato_mon3210 cat\ male_p conts\ negro__a___mulato__afrop conts\ unem_p conts\ home_p conts\ single_p conts\ cobertura_alcant conts\ cobertura_energi conts\ arean3210 conts\) saving("C:\Users\Amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\table1.xls", replace) missing test

*touch "poissontables_indiceseform_nov5.xls", replace	
rename countdenguedtabarrio dengue
rename countchikdtabarrio chikv
rename countzikadtabarrio zika












foreach var in dengue zika chikv {
xtset, clear

*temp_anom_median_c templag1 
	local fixed "literate_p  rainlag1 Avg_rain serv_cov_index anm_ed_index_sum anm_assist_esc_ind alguna_limit_p male_p negro__a___mulato__afrop home_p single_p anm_cobertura_alcant anm_cobertura_energi arean3210"

	stepwise, pr(.1) pe(.05) : poisson  `var' `fixed', vce(robust) 
	est sto mstepwise`var'
	estat gof
	
xtset codigo_barrio monthtime , monthly

*temp_anom_median_c templag1 
qic `var' `fixed' , robust  family(poisson) link(log) eform    corr(ind)  
	est sto mqic`var'
	
xtset codigo_barrio monthtime , monthly
	stepwise, pr(.1) pe(.05) : poisson  `var' `fixed', vce(robust) 
	est sto mxtstepwise`var'

	 *home_empty_p  unem_p i.estrato_mon3210 

	*local fixed "rainlag1 Avg_rain serv_cov_index anm_ed_index_sum anm_assist_esc_ind alguna_limit_p literate_p home_empty_p i.estrato_mon3210 male_p negro__a___mulato__afrop unem_p home_p single_p anm_cobertura_alcant anm_cobertura_energi arean3210"
	*local fixedanom "anm_Avg_rain l1anm_Avg_rain anm_serv_cov_index anm_services_index anm_assist_educ_P anm_alguna_limit_p anm_literate_p anm_home_empty_p i.anm_estrato_mon3210 anm_male_p anm_negro__a___mulato__afrop anm_unem_p anm_home_p anm_single_p anm_cobertura_alcant anm_cobertura_energi anm_arean3210"

			xtgee `var' `fixed' , vce(robust) family(poisson) link(log) corr(ind) eform
			est sto mxtgee`var'
			
		*ereturn post
		margins
		estat vce
		estat wcorrelation
		estat summarize
		capture drop `var'p
		predict `var'p if e(sample) 
		corr `var' `var'p if e(sample) 
		di "********************"r(rho)^2 "********************"

		predict yhat`var', xb
		gen residual`var' = `var'- yhat`var' 

		twoway scatter residual`var' `var'  
		graph export "residual`var'_`var'.tif", replace

		gen l1residual`var' = L.residual`var' 

		twoway scatter l1residual`var' `var'  
		graph export "l1residual`var'_`var'.tif", replace 

		twoway scatter l1residual`var' residual`var'
		graph export "l1residual`var'_residual`var'.tif", replace

		twoway scatter residual`var' yhat`var' 
		graph export "residual`var'_yhat`var'.tif", replace
		

*mixed models so we can let rain and temp vary with time but keep everything else constant since we just measured them once
		touch C:\Users\Amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\output\poissontables_indiceseform_nov5.xls, replace
		local fixedanom "anm_serv_cov_index anm_services_index anm_assist_educ_P anm_alguna_limit_p anm_literate_p anm_ed_index_sum anm_assist_esc_ind anm_home_empty_p anm_estrato_mon3210 anm_male_p anm_negro__a___mulato__afrop anm_unem_p anm_home_p anm_single_p anm_cobertura_alcant anm_cobertura_energi anm_arean3210"
		local fixed "serv_cov_index services_index assist_educ_P alguna_limit_p literate_p ed_index_sum assist_esc_ind home_empty_p estrato_mon3210 male_p negro__a___mulato__afrop unem_p home_p single_p cobertura_alcant cobertura_energi arean3210"
		local varyanom "anm_Avg_rain l1anm_Avg_rain temp_anom_median_c templag1"
		*xtmepoisson  `var' `fixedanom', || _all: `varyanom', covariance(independent) irr 
		*outreg2 using "C:\Users\Amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\output\poisson_mixed_nov5.xls", append e(r2_p) eform 
}

foreach var in dengue zika chikv{
esttab mxtgee`var' mxtstepwise`var' mstepwise`var' mqic`var' using poisson.rtf, append eform z
}

graph bar (mean) Avg_rain temp_anom_median_c, over(month, label(angle(45) labsize(small))) over(year) legend( label(1 "Mean Precipitation") label(2 "Median Temperature anomaly") ) ytitle("Degrees Celsius / mm precipation") title("Median temperatures anomaly and Average precipation") note("Source: Rain data Hydro-Estimator, NOAA and Temp anomalies The HadCRUT4 dataset")  
