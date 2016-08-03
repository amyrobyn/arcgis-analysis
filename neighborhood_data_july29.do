/****************************************************
 *Amy Krystosik                  					*
 *chikv, dengue, and zika in cali, colombia       	*
 *PHD dissertation- arcgis analysis only               *
 *last updated July 29, 2016 
 * FILE NAME: neighborhood_data_july29.do* 
 ***************************************************/
cd "C:\Users\Amy\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models"
capture log close 
log using "arcgis_analysis_only_July_29_2016.smcl", text replace 
set scrollbufsize 100000
set more 1

foreach dataset in "ed_level_approved_barrio.csv" "education_barrio.csv" "houses_barrios.csv" "economy_barrio.csv" "type_of_work_barrio.csv" "estrato_por_geografia_barrio.csv" "hombres_parentesco_con_jefe_barrio.csv" "parentesco_con_jefe_barrio.csv" "mujeres_parentesco_con_jefe_barrio.csv" "marital_status_barrio.csv" "ethnicity_barrio.csv" "limitations_barrio.csv" "literacy_barrio.csv" "school_assistence_barrio.csv" "barrios.csv" {  
		insheet using "`dataset'", clear
		capture drop _merge		
		save "`dataset'.dta",  replace
		use "`dataset'.dta",  clear
		tostring codigo_barrio, replace
		drop if codigo_barrio ==""
		drop if codigo_barrio =="."
		drop if codigo_barrio ==" ."
		drop if codigo_barrio ==". "

		gen codigo_barriostring = string(real(codigo_barrio),"%04.0f")
			drop codigo_barrio
			rename codigo_barriostring codigo_barrio

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
			drop if codigo_barrio ==""
			gen codigo_barriostring = string(real(codigo_barrio),"%04.0f")
			drop codigo_barrio
			rename codigo_barriostring codigo_barrio
			capture	drop _merge
			save barrios.csv.dta, replace
			use barrios.csv.dta, clear

		merge 1:1 codigo_barrio using school_assistence_barrio.csv.dta
		save merged_barrio.dta, replace
	
*merge barrio data**	
foreach dataset in "ed_level_approved_barrio.csv" "education_barrio.csv" "houses_barrios.csv" "economy_barrio.csv" "type_of_work_barrio.csv" "estrato_por_geografia_barrio.csv" "hombres_parentesco_con_jefe_barrio.csv" "parentesco_con_jefe_barrio.csv" "mujeres_parentesco_con_jefe_barrio.csv" "marital_status_barrio.csv" "ethnicity_barrio.csv" "limitations_barrio.csv" "literacy_barrio.csv" { 
	use merged_barrio.dta, clear
			drop if codigo_barrio ==""
			drop if codigo_barrio =="."
			gen codigo_barriostring = string(real(codigo_barrio),"%04.0f")
			drop codigo_barrio
			rename codigo_barriostring codigo_barrio
			capture drop freq_barrio
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
		tostring codigo_barrio, replace
		drop if codigo_barrio ==""
		drop if codigo_barrio ==""
		gen codigo_barriostring = string(real(codigo_barrio),"%04.0f")
		drop codigo_barrio
		rename codigo_barriostring codigo_barrio
		save "cases_barrio.dta",  replace

use "C:\Users\Amy\OneDrive\epi analysis\temp3.dta", clear 			
			tostring cod_barrio, replace
			drop if cod_barrio ==""
			gen codigo_barriostring = string(real(cod_barrio),"%04.0f")
			*drop codigo_barrio
			rename codigo_barriostring codigo_barrio
	rename CODIGO codigo
	capture drop _merge
	merge 1:1 codigo using "cases_barrio.dta"
	capture drop _merge
	format codigo_barrio %04s
	save merged_barrio_cases.dta, replace
	
use "merged_barrio_cases.dta", clear
		keep if cod_eve == 895
		save zika.dta, replace	
use "merged_barrio_cases.dta", clear
		keep if cod_eve == 217
		save chik.dta, replace	
use "merged_barrio_cases.dta", clear
		keep if cod_eve == 210|220|580
		save dengue.dta, replace	

foreach dataset in "zika.dta" "chik.dta" "dengue.dta"{ 
		use "`dataset'", clear
		tostring codigo_barrio, replace
		local i = `i' + 1
		capture drop casecount
		gen casecount = 1
		rename casecount casecount`i'
		collapse (sum) casecount, by(codigo_barrio)
		save "`dataset'",  replace
	}
foreach dataset in "zika.dta" "chik.dta" "dengue.dta"{ 
		use merged_barrio.dta, clear
		capture drop _merge
		merge 1:1 codigo_barrio using `dataset'.dta
		drop _merge
		save merged_barrio.dta, replace	
		}	

rename casecount_1 countzikabarrio
rename casecount_2 countchikvbarrio
rename casecount_3 countdenguebarrio

drop id_barrio cod_comunac2 perimetron3210 acuerdoc32 limitesc32 cdigo_barrio barrio__urbanizacin_o_sector asistencia_educativa_no_informa asistencia_educativa_total cdigonico barriourbanizacinosector cdigo_nico communa barrio_nombre v2 barrio_urbanizacinosector

destring *, replace force

gen asistencia_educativa_ratio = asistencia_educativa_si/asistencia_educativa_no
drop asistencia_educativa_si asistencia_educativa_no

gen sabe_leer_y_escribir_ratio = sabe_leer_y_escribir_si/sabe_leer_y_escribir_no
drop sabe_leer_y_escribir_si sabe_leer_y_escribir_no

egen ed_index_sum= rowtotal(prejardin- superiorypostgrado)
drop prejardin- superiorypostgrado

egen tasa_assistenciaesc_index_sum= rowtotal(tasa_de_asistencia_escolar_5 tasa_de_asistencia_escolar_6__10 tasa_de_asistencia_escolar_11__1 v27 tasa_de_asistencia_escolar_15__1 tasa_de_asistencia_escolar_5__16 tasa_de_asistencia_escolar_17__2 ed_index_sum)
drop  tasa_de_asistencia_escolar_5 tasa_de_asistencia_escolar_6__10 tasa_de_asistencia_escolar_11__1 v27 tasa_de_asistencia_escolar_15__1 tasa_de_asistencia_escolar_5__16 tasa_de_asistencia_escolar_17__2 ed_index_sum
drop asistencia_educativa_0__4_aos_no - total 
drop estrata_1 - estrata_6 estrata_moda

sum asistencia_educativa_ratio sabe_leer_y_escribir_ratio tasa_assistenciaesc_index_sum estrato_mon3210 occupation_condition_ocupada_con v5 occupation_condition_desocupadas occupation_condition_desocupada_  tipo_de_vivienda_casa tipo_de_vivienda_apartamento tipo_de_vivienda_tipo_cuarto cobertura_vivienda_con____acuedu cobertura_vivienda_con____alcant cobertura_vivienda_con____energi cobertura_vivienda_con____gas cobertura_vivienda_con____telefo  industria comercio servicios trabaj no_trabaj_pero_tena_trabajo busc_trabajo_pero_haba_trabajado busc_trabajo_por_primera_vez estudi_y_no_trabaj_ni_busc_traba realiz_oficios_del_hogar_y_no_tr incapacitado_permanentemente_par vivi_de_jubilacin_o_renta_y_no_t estuvo_en_otra_situacin jefe_o_jefa_del_hogar conyuge__pareja_ hijo_a___hijastro_a_ yerno__nuera nieto_a_ padre__madre_o_suegro_a_ hermano_a___hermanastro_a_ otro_pariente empleado__a__domestico otro_no_pariente hijo_a__hijastro_a_ yerno_nuera padre_madre_o_suegro_a_ hermano_a__hermanastro_a_ nocasadoylleva2oaosviviendoparej nocasadoyllevade2aosviviendopare separado_a__divorciado_a_ viudo_a_ soltero_a_ casado_a_ indgena rom raizal palenquero negro__a___mulato__afrocolombian ninguno_de_los_anteriores alguna_limitacin_si 

		
foreach var in countdenguebarrio countchikvbarrio countzikabarrio{
		regress  `var' asistencia_educativa_ratio  sabe_leer_y_escribir_ratio  tasa_assistenciaesc_index_sum estrato_mon3210   occupation_condition_ocupada_con v5 occupation_condition_desocupadas occupation_condition_desocupada_  tipo_de_vivienda_casa tipo_de_vivienda_apartamento tipo_de_vivienda_tipo_cuarto cobertura_vivienda_con____acuedu cobertura_vivienda_con____alcant cobertura_vivienda_con____energi cobertura_vivienda_con____gas cobertura_vivienda_con____telefo  industria comercio servicios trabaj no_trabaj_pero_tena_trabajo busc_trabajo_pero_haba_trabajado busc_trabajo_por_primera_vez estudi_y_no_trabaj_ni_busc_traba realiz_oficios_del_hogar_y_no_tr incapacitado_permanentemente_par vivi_de_jubilacin_o_renta_y_no_t estuvo_en_otra_situacin jefe_o_jefa_del_hogar conyuge__pareja_ hijo_a___hijastro_a_ yerno__nuera nieto_a_ padre__madre_o_suegro_a_ hermano_a___hermanastro_a_ otro_pariente empleado__a__domestico otro_no_pariente hijo_a__hijastro_a_ yerno_nuera padre_madre_o_suegro_a_ hermano_a__hermanastro_a_ nocasadoylleva2oaosviviendoparej nocasadoyllevade2aosviviendopare separado_a__divorciado_a_ viudo_a_ soltero_a_ casado_a_ indgena rom raizal palenquero negro__a___mulato__afrocolombian ninguno_de_los_anteriores alguna_limitacin_si
		}

export excel using "neighborhood_GWR", firstrow(variables) replace
