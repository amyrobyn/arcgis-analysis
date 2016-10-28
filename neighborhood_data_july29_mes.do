/****************************************************
 *Amy Krystosik                  					*
 *chikv, dengue, and zika in cali, colombia       	*
 *PHD dissertation- arcgis analysis only               *
 *last updated July 29, 2016 
 * FILE NAME: neighborhood_data_july29.do* 
 ***************************************************/
cd "C:\Users\Amy\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models"
capture log close 
log using "arcgis_analysis_only_oct_26_2016.smcl", text replace 
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

use "C:\Users\Amy\OneDrive\epi analysis\temp3.dta", clear 			
			destring cod_barrio, replace
			drop if cod_barrio ==.
	rename CODIGO codigo
	capture drop _merge
	merge 1:1 codigo using "cases_barrio.dta"
	capture drop _merge
	save merged_barrio_cases.dta, replace
	
use "merged_barrio_cases.dta", clear
		keep if cod_eve == 895
		save zika.dta, replace	
use "merged_barrio_cases.dta", clear
		keep if cod_eve == 217
		save chik.dta, replace	
use "merged_barrio_cases.dta", clear
		keep if cod_eve == 210|  cod_eve==220|cod_eve==580
		save dengue.dta, replace	

foreach dataset in "zika.dta" "chik.dta" "dengue.dta"{ 
		use `dataset', clear
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

		destring cod_barrio, replace
		local i = `i' + 1
		capture drop casecount
		gen casecount = 1
		rename casecount casecount`i'
		collapse (sum) casecount, by(codigo_barrio mes anos)
		replace casecount`i' = 0 if casecount`i' ==.
		save "`dataset'",  replace
	}
	
	rename anos year
	rename mes month

merge m:m month year using "C:\Users\Amy\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\temperature_data_raw\temp_anomoly_2014-2016.dta"
drop _merge
merge m:m month year using "C:\Users\Amy\Google Drive\avg_rain\rain_months.dta"
save barrios_rain_temp, replace
	
foreach dataset in "zika.dta" "chik.dta" "dengue.dta"{ 
		use merged_barrio.dta, clear
		capture drop _merge
		merge 1:1 codigo_barrio using `dataset'
		drop _merge
		merge 1:1 codigo_barrio using "pop_total_sex_barrio.csv.dta"
		save merged_barrio, replace	
}	
use merged_barrio.dta, clear

rename casecount1* countzikabarrio*
rename casecount2* countchikvbarrio*
rename casecount3* countdenguebarrio*

*drop _merge freq_barrio id_barrio cod_comunac2 perimetron3210 acuerdoc32 limitesc32 cdigo_barrio barrio__urbanizacin_o_sector asistencia_educativa_no_informa asistencia_educativa_total cdigonico barriourbanizacinosector cdigo_nico communa barrio_nombre barrio_urbanizacinosector cogigo_barrio OID Barrio_C Barrio _merge  barrio_urbanizacin_o_sector 

destring *, replace

gen asistencia_educativa_ratio = asistencia_educativa_si/asistencia_educativa_no
*drop asistencia_educativa_si asistencia_educativa_no

gen alguna_limitacin_ratio = alguna_limitacin_si/alguna_limitacin_no 
*drop alguna_limitacin_si alguna_limitacin_no alguna_limitacin_total limitacin_para_aprender limitacin_para_baarse limitacin_para_caminar limitacin_para_hablar limitacin_para_oir limitacin_para_ver limitacin_para_socializar limitacin_para_usar_brazos_o_man limitacin_para_otro sabe_leer_y_escribir_no_informa 

gen sabe_leer_y_escribir_ratio = sabe_leer_y_escribir_si/sabe_leer_y_escribir_no
*drop sabe_leer_y_escribir_si sabe_leer_y_escribir_no sabe_leer_y_escribir_total sabe_leer_y_escribir_15__24_aos_ v9 v10 

egen ed_index_sum= rowtotal(prejardin- superiorypostgrado)
*drop prejardin- superiorypostgrado
*drop preescolar bsica_primaria bsica_secundaria media_acadmica_clsica media_tcnica normalista superior__y__postgrado _ninguno no_informa 

egen services_index_sum= rowtotal(vivienda_con_acueducto vivienda_con_alcantarillado vivienda_con_energia vivienda_con_gas vivienda_con_telefono vivienda_con_)
*drop vivienda_con_acueducto vivienda_con_alcantarillado vivienda_con_energia vivienda_con_gas vivienda_con_telefono vivienda_con_ 

egen services_coverage_index_sum= rowtotal(cobertura_vivienda_con____acuedu cobertura_vivienda_con____alcant cobertura_vivienda_con____energi cobertura_vivienda_con____gas cobertura_vivienda_con____telefo)
*drop cobertura_vivienda_con____acuedu cobertura_vivienda_con____alcant cobertura_vivienda_con____energi cobertura_vivienda_con____gas cobertura_vivienda_con____telefo 

ds, has(type string) 
foreach var of varlist `r(varlist)' { 
replace `var' = "." if `var' =="NA"
destring, replace
}

egen tasa_assistenciaesc_index_sum= rowtotal(tasa_de_asistencia_escolar_5 tasa_de_asistencia_escolar_6__10 tasa_de_asistencia_escolar_11__1 v27 tasa_de_asistencia_escolar_15__1 tasa_de_asistencia_escolar_5__16 tasa_de_asistencia_escolar_17__2 ed_index_sum)
*drop  tasa_de_asistencia_escolar_5 tasa_de_asistencia_escolar_6__10 tasa_de_asistencia_escolar_11__1 v27 tasa_de_asistencia_escolar_15__1 tasa_de_asistencia_escolar_5__16 tasa_de_asistencia_escolar_17__2 ed_index_sum
*drop asistencia_educativa_0__4_aos_no - total asistencia_educativa_0__4_aos_si  
*drop estrata_1 - estrata_6 estrata_moda 


egen home_occupied = rowtotal(occupation_condition_ocupada_con v5)
gen home_occupied_perc = home_occupied/occupation_condition_total 
egen home_empty = rowtotal(occupation_condition_desocupadas occupation_condition_desocupada_)
gen home_empty_perc = home_empty/occupation_condition_total 
gen empty_ratio = home_empty_perc/home_occupied_perc 
replace estrato_mon3210=. if estrato_mon3210==10 
*drop occupation_condition_ocupada_con v5 occupation_condition_total occupation_condition_desocupadas occupation_condition_desocupada_ home_occupied_perc home_occupied home_empty_perc home_empty
/*

regress countdenguebarrio arean3210 

regress countdenguebarrio estrato_mon3210 

regress countdenguebarrio  indigena rom raizal palenquero negro__a___mulato__afrocolombian ninguno_de_los_anteriores 

regress countdenguebarrio tipo_de_vivienda_casa tipo_de_vivienda_apartamento tipo_de_vivienda_tipo_cuarto tipo_de_vivienda_otro_tipo 


regress countdenguebarrio industria comercio servicios otras_actividades 

regress countdenguebarrio unidades_auxiliares_tipo_gerenci unidades_auxiliares_diferentes_d 

regress countdenguebarrio desocupada trabaj no_trabaj_pero_tena_trabajo busc_trabajo_pero_haba_trabajado busc_trabajo_por_primera_vez estudi_y_no_trabaj_ni_busc_traba realiz_oficios_del_hogar_y_no_tr incapacitado_permanentemente_par vivi_de_jubilacin_o_renta_y_no_t estuvo_en_otra_situacin 

regress countdenguebarrio  jefe_o_jefa_del_hogar conyuge__pareja_ hijo_a___hijastro_a_ yerno__nuera nieto_a_ padre__madre_o_suegro_a_ hermano_a___hermanastro_a_ otro_pariente empleado__a__domestico otro_no_pariente hijo_a__hijastro_a_ yerno_nuera padre_madre_o_suegro_a_ hermano_a__hermanastro_a_ v2 

regress countdenguebarrio nocasadoylleva2oaosviviendoparej nocasadoyllevade2aosviviendopare separado_a__divorciado_a_ viudo_a_ soltero_a_ casado_a_ 
*/
*drop chikttlpop
gen maletofemale = male_pop/female_pop
*drop Male_pop Female_pop

sum arean3210 estrato_mon3210 tipo_de_vivienda_casa tipo_de_vivienda_apartamento tipo_de_vivienda_tipo_cuarto tipo_de_vivienda_otro_tipo industria comercio servicios otras_actividades unidades_auxiliares_tipo_gerenci unidades_auxiliares_diferentes_d desocupada trabaj no_trabaj_pero_tena_trabajo busc_trabajo_pero_haba_trabajado busc_trabajo_por_primera_vez estudi_y_no_trabaj_ni_busc_traba realiz_oficios_del_hogar_y_no_tr incapacitado_permanentemente_par vivi_de_jubilacin_o_renta_y_no_t estuvo_en_otra_situacin jefe_o_jefa_del_hogar conyuge__pareja_ hijo_a___hijastro_a_ yerno__nuera nieto_a_ padre__madre_o_suegro_a_ hermano_a___hermanastro_a_ otro_pariente empleado__a__domestico otro_no_pariente hijo_a__hijastro_a_ yerno_nuera padre_madre_o_suegro_a_ hermano_a__hermanastro_a_ v2 nocasadoylleva2oaosviviendoparej nocasadoyllevade2aosviviendopare separado_a__divorciado_a_ viudo_a_ soltero_a_ casado_a_  indigena rom raizal palenquero negro__a___mulato__afrocolombian ninguno_de_los_anteriores countzikabarrio countchikvbarrio countdenguebarrio total_pop viviendas hogares asistencia_educativa_ratio alguna_limitacin_ratio sabe_leer_y_escribir_ratio services_index_sum services_coverage_index_sum tasa_assistenciaesc_index_sum empty_ratio maletofemale

save temp.dta, replace
/*
*stepwise regression models		
 touch regtableseform.xls, replace
foreach var in countdenguebarrio countchikvbarrio countzikabarrio{
	replace `var' = 0 if `var'==.
	local indepenent  "arean3210 estrato_mon3210 asistencia_educativa_0__4_aos_si preescolar bsica_primaria bsica_secundaria media_acadmica_clsica media_tcnica superior__y__postgrado _ninguno no_informa occupation_condition_ocupada_con v5 occupation_condition_desocupadas  occupation_condition_total tipo_de_vivienda_casa tipo_de_vivienda_apartamento  tipo_de_vivienda_otro_tipo vivienda_con_acueducto vivienda_con_alcantarillado vivienda_con_energia vivienda_con_gas vivienda_con_telefono cobertura_vivienda_con____acuedu cobertura_vivienda_con____alcant cobertura_vivienda_con____energi cobertura_vivienda_con____gas cobertura_vivienda_con____telefo industria comercio servicios otras_actividades unidades_auxiliares_tipo_gerenci unidades_auxiliares_diferentes_d desocupada trabaj no_trabaj_pero_tena_trabajo busc_trabajo_pero_haba_trabajado busc_trabajo_por_primera_vez estudi_y_no_trabaj_ni_busc_traba realiz_oficios_del_hogar_y_no_tr incapacitado_permanentemente_par vivi_de_jubilacin_o_renta_y_no_t estuvo_en_otra_situacin jefe_o_jefa_del_hogar conyuge__pareja_ hijo_a___hijastro_a_ yerno__nuera nieto_a_ padre__madre_o_suegro_a_ hermano_a___hermanastro_a_ otro_pariente empleado__a__domestico otro_no_pariente hijo_a__hijastro_a_ yerno_nuera padre_madre_o_suegro_a_ hermano_a__hermanastro_a_ nocasadoylleva2oaosviviendoparej nocasadoyllevade2aosviviendopare separado_a__divorciado_a_ viudo_a_ soltero_a_ casado_a_  indigena rom raizal palenquero negro__a___mulato__afrocolombian ninguno_de_los_anteriores cogigo_barrio alguna_limitacin_si  alguna_limitacin_total limitacin_para_aprender limitacin_para_baarse limitacin_para_caminar limitacin_para_hablar limitacin_para_oir limitacin_para_ver limitacin_para_socializar limitacin_para_usar_brazos_o_man limitacin_para_otro sabe_leer_y_escribir_no_informa sabe_leer_y_escribir_total sabe_leer_y_escribir_15__24_aos_ v10 asistencia_educativa_ratio sabe_leer_y_escribir_ratio tasa_assistenciaesc_index_sum"
	stepwise, pr(.5) pe(.2): regress `var' `indepenent'
	outreg2 using regtableseform.xls, append  e(all)
}
*/
*stepwise models poisson		
touch poissontableseform.xls, replace
foreach var in countdenguebarrio countchikvbarrio countzikabarrio{
	local indepenent  "arean3210 estrato_mon3210 asistencia_educativa_0__4_aos_si preescolar bsica_primaria bsica_secundaria media_acadmica_clsica media_tcnica superior__y__postgrado _ninguno no_informa occupation_condition_ocupada_con v5 occupation_condition_desocupadas  occupation_condition_total tipo_de_vivienda_casa tipo_de_vivienda_apartamento  tipo_de_vivienda_otro_tipo vivienda_con_acueducto vivienda_con_alcantarillado vivienda_con_energia vivienda_con_gas vivienda_con_telefono cobertura_vivienda_con____acuedu cobertura_vivienda_con____alcant cobertura_vivienda_con____energi cobertura_vivienda_con____gas cobertura_vivienda_con____telefo industria comercio servicios otras_actividades unidades_auxiliares_tipo_gerenci unidades_auxiliares_diferentes_d desocupada trabaj no_trabaj_pero_tena_trabajo busc_trabajo_pero_haba_trabajado busc_trabajo_por_primera_vez estudi_y_no_trabaj_ni_busc_traba realiz_oficios_del_hogar_y_no_tr incapacitado_permanentemente_par vivi_de_jubilacin_o_renta_y_no_t estuvo_en_otra_situacin jefe_o_jefa_del_hogar conyuge__pareja_ hijo_a___hijastro_a_ yerno__nuera nieto_a_ padre__madre_o_suegro_a_ hermano_a___hermanastro_a_ otro_pariente empleado__a__domestico otro_no_pariente hijo_a__hijastro_a_ yerno_nuera padre_madre_o_suegro_a_ hermano_a__hermanastro_a_ nocasadoylleva2oaosviviendoparej nocasadoyllevade2aosviviendopare separado_a__divorciado_a_ viudo_a_ soltero_a_ casado_a_  indigena rom raizal palenquero negro__a___mulato__afrocolombian ninguno_de_los_anteriores cogigo_barrio alguna_limitacin_si  alguna_limitacin_total limitacin_para_aprender limitacin_para_baarse limitacin_para_caminar limitacin_para_hablar limitacin_para_oir limitacin_para_ver limitacin_para_socializar limitacin_para_usar_brazos_o_man limitacin_para_otro sabe_leer_y_escribir_no_informa sabe_leer_y_escribir_total sabe_leer_y_escribir_15__24_aos_ v10 asistencia_educativa_ratio sabe_leer_y_escribir_ratio tasa_assistenciaesc_index_sum"
	stepwise, pr(.5) pe(.2): poisson `var' `indepenent'
	outreg2 using poissontableseform.xls, append e(r2_p) eform 
}
/*
*stepwise models regression indices		
touch regtables_indiceseform.xls, replace
foreach var in countdenguebarrio countchikvbarrio countzikabarrio{
local indepenent  "total_pop  arean3210 estrato_mon3210  indigena rom raizal negro__a___mulato__afrocolombian ninguno_de_los_anteriores asistencia_educativa_ratio alguna_limitacin_ratio sabe_leer_y_escribir_ratio services_index_sum services_coverage_index_sum tasa_assistenciaesc_index_sum empty_ratio maletofemale"
	stepwise, pr(.5) pe(.2): regress `var' `indepenent'
	outreg2 using regtables_indiceseform.xls, append  e(all)
}
*/
foreach var of varlist countzikabarrio countchikvbarrio countdenguebarrio  total_pop arean3210 estrato_mon3210 indigena rom raizal negro__a___mulato__afrocolombian ninguno_de_los_anteriores asistencia_educativa_ratio alguna_limitacin_ratio sabe_leer_y_escribir_ratio services_index_sum services_coverage_index_sum tasa_assistenciaesc_index_sum empty_ratio maletofemale{
histogram `var'
graph export "C:\Users\Amy\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\histograms barrios\`var'.tif", width(4000) replace 
}
table1, vars(countzikabarrio contn\ countchikvbarrio contn\countdenguebarrio contn\ total_pop contn\ arean3210 contn\ estrato_mon3210 cat\indigena conts\rom conts\raizal conts\negro__a___mulato__afrocolombian conts\ninguno_de_los_anteriores conts\asistencia_educativa_ratio contn\alguna_limitacin_ratio contn\sabe_leer_y_escribir_ratio contn\services_index_sum conts\services_coverage_index_sum conts\tasa_assistenciaesc_index_sum conts\empty_ratio conts\maletofemale contn\) saving("C:\Users\Amy\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\neighborhood'.xls", replace) missing test

*stepwise models poisson indices		
touch poissontables_indiceseform.xls, replace
foreach var in countdenguebarrio countchikvbarrio countzikabarrio{
local indepenent  "total_pop arean3210 estrato_mon3210 indigena rom raizal negro__a___mulato__afrocolombian ninguno_de_los_anteriores asistencia_educativa_ratio alguna_limitacin_ratio sabe_leer_y_escribir_ratio services_index_sum services_coverage_index_sum tasa_assistenciaesc_index_sum empty_ratio maletofemale"
	stepwise, pr(.49) pe(.1): poisson `var' `indepenent'
	outreg2 using poissontables_indiceseform.xls, append e(r2_p) eform 
}

/**selected models
foreach var in countdenguebarrio countchikvbarrio countzikabarrio{
		*select based on knowledge.....
		local indepenent  "total_pop arean3210 estrato_mon3210 asistencia_educativa_0__4_aos_si preescolar bsica_primaria bsica_secundaria media_acadmica_clsica media_tcnica superior__y__postgrado _ninguno no_informa occupation_condition_ocupada_con v5 occupation_condition_desocupadas  occupation_condition_total tipo_de_vivienda_casa tipo_de_vivienda_apartamento  tipo_de_vivienda_otro_tipo vivienda_con_acueducto vivienda_con_alcantarillado vivienda_con_energia vivienda_con_gas vivienda_con_telefono cobertura_vivienda_con____acuedu cobertura_vivienda_con____alcant cobertura_vivienda_con____energi cobertura_vivienda_con____gas cobertura_vivienda_con____telefo industria comercio servicios otras_actividades unidades_auxiliares_tipo_gerenci unidades_auxiliares_diferentes_d desocupada trabaj no_trabaj_pero_tena_trabajo busc_trabajo_pero_haba_trabajado busc_trabajo_por_primera_vez estudi_y_no_trabaj_ni_busc_traba realiz_oficios_del_hogar_y_no_tr incapacitado_permanentemente_par vivi_de_jubilacin_o_renta_y_no_t estuvo_en_otra_situacin jefe_o_jefa_del_hogar conyuge__pareja_ hijo_a___hijastro_a_ yerno__nuera nieto_a_ padre__madre_o_suegro_a_ hermano_a___hermanastro_a_ otro_pariente empleado__a__domestico otro_no_pariente hijo_a__hijastro_a_ yerno_nuera padre_madre_o_suegro_a_ hermano_a__hermanastro_a_ nocasadoylleva2oaosviviendoparej nocasadoyllevade2aosviviendopare separado_a__divorciado_a_ viudo_a_ soltero_a_ casado_a_  indigena rom raizal palenquero negro__a___mulato__afrocolombian ninguno_de_los_anteriores cogigo_barrio alguna_limitacin_si  alguna_limitacin_total limitacin_para_aprender limitacin_para_baarse limitacin_para_caminar limitacin_para_hablar limitacin_para_oir limitacin_para_ver limitacin_para_socializar limitacin_para_usar_brazos_o_man limitacin_para_otro sabe_leer_y_escribir_no_informa sabe_leer_y_escribir_total sabe_leer_y_escribir_15__24_aos_ v10 asistencia_educativa_ratio sabe_leer_y_escribir_ratio tasa_assistenciaesc_index_sum"
		regress  `var' `indepenent'
		}
*/
*/
*export
use temp, clear
order codigo_barrio countzikabarrio countchikvbarrio countdenguebarrio
sort countzikabarrio countchikvbarrio countdenguebarrio
export excel using "neighborhood_GWR_indices", firstrow(variables) replace
capture drop _merge
save merged_barrio_july72016.dta, replace	
import excel "C:\Users\Amy\Desktop\gwr4\points2.xls", sheet("points2") firstrow clear
keep dengue_ID_BARRIO POINT_X POINT_Y
rename dengue_ID_BARRIO  codigo_barrio
rename POINT_X x
rename POINT_Y y
destring codigo_barrio, replace
merge m:m codigo_barrio using merged_barrio_july72016
keep codigo_barrio  x y countdenguebarrio countchikvbarrio countzikabarrio arean3210 estrato_mon3210  indigena rom raizal palenquero negro__a___mulato__afrocolombian ninguno_de_los_anteriores total_pop asistencia_educativa_ratio alguna_limitacin_ratio sabe_leer_y_escribir_ratio services_index_sum services_coverage_index_sum tasa_assistenciaesc_index_sum empty_ratio maletofemale total_pop arean3210 estrato_mon3210 asistencia_educativa_0__4_aos_si preescolar bsica_primaria bsica_secundaria media_acadmica_clsica media_tcnica superior__y__postgrado _ninguno no_informa occupation_condition_ocupada_con v5 occupation_condition_desocupadas  occupation_condition_total tipo_de_vivienda_casa tipo_de_vivienda_apartamento  tipo_de_vivienda_otro_tipo vivienda_con_acueducto vivienda_con_alcantarillado vivienda_con_energia vivienda_con_gas vivienda_con_telefono cobertura_vivienda_con____acuedu cobertura_vivienda_con____alcant cobertura_vivienda_con____energi cobertura_vivienda_con____gas cobertura_vivienda_con____telefo industria comercio servicios otras_actividades unidades_auxiliares_tipo_gerenci unidades_auxiliares_diferentes_d desocupada trabaj no_trabaj_pero_tena_trabajo busc_trabajo_pero_haba_trabajado busc_trabajo_por_primera_vez estudi_y_no_trabaj_ni_busc_traba realiz_oficios_del_hogar_y_no_tr incapacitado_permanentemente_par vivi_de_jubilacin_o_renta_y_no_t estuvo_en_otra_situacin jefe_o_jefa_del_hogar conyuge__pareja_ hijo_a___hijastro_a_ yerno__nuera nieto_a_ padre__madre_o_suegro_a_ hermano_a___hermanastro_a_ otro_pariente empleado__a__domestico otro_no_pariente hijo_a__hijastro_a_ yerno_nuera padre_madre_o_suegro_a_ hermano_a__hermanastro_a_ nocasadoylleva2oaosviviendoparej nocasadoyllevade2aosviviendopare separado_a__divorciado_a_ viudo_a_ soltero_a_ casado_a_  indigena rom raizal palenquero negro__a___mulato__afrocolombian ninguno_de_los_anteriores cogigo_barrio alguna_limitacin_si  alguna_limitacin_total limitacin_para_aprender limitacin_para_baarse limitacin_para_caminar limitacin_para_hablar limitacin_para_oir limitacin_para_ver limitacin_para_socializar limitacin_para_usar_brazos_o_man limitacin_para_otro sabe_leer_y_escribir_no_informa sabe_leer_y_escribir_total sabe_leer_y_escribir_15__24_aos_ v10 asistencia_educativa_ratio sabe_leer_y_escribir_ratio tasa_assistenciaesc_index_sum
drop if codigo_barrio  ==.
rename negro__a___mulato__afrocolombian negro__a___mulato__afro
rename tasa_assistenciaesc_index_sum tasa_assist_index_sum
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
foreach var in arean3210 estrato_mon3210 indigena rom raizal palenquero negro__a___mulato__afro ninguno_de_los_anteriores total_pop asistencia_educativa_ratio alguna_limitacin_ratio sabe_leer_y_escribir_ratio services_index_sum services_coverage_index_sum tasa_assist_index_sum empty_ratio maletofemale asist_educ_0__4_aos_si preescolar bsica_primaria bsica_secundaria media_acadmica_clsica media_tcnica superior__y__postgrado _ninguno no_informa occupation_ocupada_con v5 occupation_desocupadas  occupation_condition_total tipo_de_vivienda_casa tipo_de_vivienda_apartamento  tipo_de_vivienda_otro_tipo vivienda_con_acueducto vivienda_con_alcantarillado vivienda_con_energia vivienda_con_gas vivienda_con_telefono cobertura_acuedu cobertura_alcant cobertura_energi cobertura_gas cobertura_telefo industria comercio servicios otras_actividades unidades_aux_tipo_gerenci unidades_aux_diferentes_d desocupada trabaj no_trabaj_pero_tena_trabajo busc_trabajo_trabajado busc_trabajo_primera_vez estudi_no_trabaj_ni_busc oficios_hogar incap_perm vivi_de_jubilacin estuvo_en_otra_situacin jefe_o_jefa_del_hogar conyuge__pareja_ hijo_a___hijastro_a_ yerno__nuera nieto_a_ padre__madre_o_suegro_a_ hermano_a___hermanastro_a_ otro_pariente empleado__a__domestico otro_no_pariente hijo_a__hijastro_a_ yerno_nuera padre_madre_o_suegro_a_ hermano_a__hermanastro_a_ separado_a__divorciado_a_ viudo_a_ soltero_a_ casado_a_   alguna_limitacin_total limitacin_para_aprender limitacin_para_baarse limitacin_para_caminar limitacin_para_hablar limitacin_para_oir limitacin_para_ver limitacin_para_socializar limit_usar_brazos_o_man limitacin_para_otro sabe_leer_y_escribir sabe_leer_y_escribir_total sabe_leer_escribir_15__24 v10 alguna_limitacin_si{ 
capture destring `var', replace
egen `var'_avg = mean(`var')
replace `var' = `var'_avg if `var'==.
drop `var'_avg
}
foreach disease in countzikabarrio	countchikvbarrio	countdenguebarrio{
replace `disease'=0 if `disease'==.
}
drop nocasado_2oaosin_parej	nocasadoyllevade2aosviviendopare cogigo_barrio
outsheet using "C:\Users\Amy\Desktop\gwr4\disease_counts.csv", comma nolabel replace
/*
summarize x y 
display sqrt(( 97315.61 - 115493.7)^2 + (105547.3 - 118912.8)^2)

foreach disease in countzikabarrio	countchikvbarrio	countdenguebarrio{
spatwmat, name(`disease') xcoord(x) ycoord(y) band(0 22562.791)
spatgsa `disease', weights(`disease') moran
}

variog av8top, list
summarize lat lon
dis sqrt((33.6275 - 34.69012)^2 + (-118.5347 - -116.2339)^2)
variog2 av8top lat lon, width(.1) lags(12) list

variog2  av8top lat lon, width(.15) lags(10) list
