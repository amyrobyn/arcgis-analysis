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

foreach dataset in "pop_total_sex_barrio.csv" "ed_level_approved_barrio.csv" "education_barrio.csv" "houses_barrios.csv" "economy_barrio.csv" "type_of_work_barrio.csv" "estrato_por_geografia_barrio.csv" "hombres_parentesco_con_jefe_barrio.csv" "parentesco_con_jefe_barrio.csv" "mujeres_parentesco_con_jefe_barrio.csv" "marital_status_barrio.csv" "ethnicity_barrio.csv" "limitations_barrio.csv" "literacy_barrio.csv" "school_assistence_barrio.csv" "barrios.csv" {  
		insheet using "`dataset'", clear
		capture drop _merge		
		destring codigo_barrio, replace force
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
		destring cod_barrio, replace
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
		merge 1:1 codigo_barrio using `dataset'
		drop _merge
		save merged_barrio.dta, replace	
		}	


use merged_barrio.dta, clear
merge 1:1 codigo_barrio using "pop_total_sex_barrio.dta"

rename casecount1 countzikabarrio
rename casecount2 countchikvbarrio
rename casecount3 countdenguebarrio

*drop _merge freq_barrio id_barrio cod_comunac2 perimetron3210 acuerdoc32 limitesc32 cdigo_barrio barrio__urbanizacin_o_sector asistencia_educativa_no_informa asistencia_educativa_total cdigonico barriourbanizacinosector cdigo_nico communa barrio_nombre barrio_urbanizacinosector cogigo_barrio OID Barrio_C Barrio _merge  barrio_urbanizacin_o_sector 

destring *, replace force

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


egen tasa_assistenciaesc_index_sum= rowtotal(tasa_de_asistencia_escolar_5 tasa_de_asistencia_escolar_6__10 tasa_de_asistencia_escolar_11__1 v27 tasa_de_asistencia_escolar_15__1 tasa_de_asistencia_escolar_5__16 tasa_de_asistencia_escolar_17__2 ed_index_sum)
*drop  tasa_de_asistencia_escolar_5 tasa_de_asistencia_escolar_6__10 tasa_de_asistencia_escolar_11__1 v27 tasa_de_asistencia_escolar_15__1 tasa_de_asistencia_escolar_5__16 tasa_de_asistencia_escolar_17__2 ed_index_sum
*drop asistencia_educativa_0__4_aos_no - total asistencia_educativa_0__4_aos_si  
*drop estrata_1 - estrata_6 estrata_moda 


egen home_occupied = rowtotal(occupation_condition_ocupada_con v5)
gen home_occupied_perc = home_occupied/occupation_condition_total 
egen home_empty = rowtotal(occupation_condition_desocupadas occupation_condition_desocupada_)
gen home_empty_perc = home_empty/occupation_condition_total 
gen empty_ratio = home_empty_perc/home_occupied_perc 
*drop occupation_condition_ocupada_con v5 occupation_condition_total occupation_condition_desocupadas occupation_condition_desocupada_ home_occupied_perc home_occupied home_empty_perc home_empty


regress countdenguebarrio arean3210 

regress countdenguebarrio estrato_mon3210 

regress countdenguebarrio indgena rom raizal palenquero negro__a___mulato__afrocolombian ninguno_de_los_anteriores 

regress countdenguebarrio tipo_de_vivienda_casa tipo_de_vivienda_apartamento tipo_de_vivienda_tipo_cuarto tipo_de_vivienda_otro_tipo 


regress countdenguebarrio industria comercio servicios otras_actividades 

regress countdenguebarrio unidades_auxiliares_tipo_gerenci unidades_auxiliares_diferentes_d 

regress countdenguebarrio desocupada trabaj no_trabaj_pero_tena_trabajo busc_trabajo_pero_haba_trabajado busc_trabajo_por_primera_vez estudi_y_no_trabaj_ni_busc_traba realiz_oficios_del_hogar_y_no_tr incapacitado_permanentemente_par vivi_de_jubilacin_o_renta_y_no_t estuvo_en_otra_situacin 

regress countdenguebarrio  jefe_o_jefa_del_hogar conyuge__pareja_ hijo_a___hijastro_a_ yerno__nuera nieto_a_ padre__madre_o_suegro_a_ hermano_a___hermanastro_a_ otro_pariente empleado__a__domestico otro_no_pariente hijo_a__hijastro_a_ yerno_nuera padre_madre_o_suegro_a_ hermano_a__hermanastro_a_ v2 

regress countdenguebarrio nocasadoylleva2oaosviviendoparej nocasadoyllevade2aosviviendopare separado_a__divorciado_a_ viudo_a_ soltero_a_ casado_a_ 

*drop chikttlpop
gen maletofemale = Male_pop/Female_pop
*drop Male_pop Female_pop


sum arean3210 estrato_mon3210 tipo_de_vivienda_casa tipo_de_vivienda_apartamento tipo_de_vivienda_tipo_cuarto tipo_de_vivienda_otro_tipo industria comercio servicios otras_actividades unidades_auxiliares_tipo_gerenci unidades_auxiliares_diferentes_d desocupada trabaj no_trabaj_pero_tena_trabajo busc_trabajo_pero_haba_trabajado busc_trabajo_por_primera_vez estudi_y_no_trabaj_ni_busc_traba realiz_oficios_del_hogar_y_no_tr incapacitado_permanentemente_par vivi_de_jubilacin_o_renta_y_no_t estuvo_en_otra_situacin jefe_o_jefa_del_hogar conyuge__pareja_ hijo_a___hijastro_a_ yerno__nuera nieto_a_ padre__madre_o_suegro_a_ hermano_a___hermanastro_a_ otro_pariente empleado__a__domestico otro_no_pariente hijo_a__hijastro_a_ yerno_nuera padre_madre_o_suegro_a_ hermano_a__hermanastro_a_ v2 nocasadoylleva2oaosviviendoparej nocasadoyllevade2aosviviendopare separado_a__divorciado_a_ viudo_a_ soltero_a_ casado_a_ indgena rom raizal palenquero negro__a___mulato__afrocolombian ninguno_de_los_anteriores countzikabarrio countchikvbarrio countdenguebarrio Total_pop Viviendas Hogares asistencia_educativa_ratio alguna_limitacin_ratio sabe_leer_y_escribir_ratio services_index_sum services_coverage_index_sum tasa_assistenciaesc_index_sum empty_ratio maletofemale

*stepwise regression models		
foreach var in countdenguebarrio countchikvbarrio countzikabarrio{
	local indepenent  "Total_pop arean3210 estrato_mon3210 asistencia_educativa_0__4_aos_si preescolar bsica_primaria bsica_secundaria media_acadmica_clsica media_tcnica superior__y__postgrado _ninguno no_informa occupation_condition_ocupada_con v5 occupation_condition_desocupadas  occupation_condition_total tipo_de_vivienda_casa tipo_de_vivienda_apartamento  tipo_de_vivienda_otro_tipo vivienda_con_acueducto vivienda_con_alcantarillado vivienda_con_energia vivienda_con_gas vivienda_con_telefono cobertura_vivienda_con____acuedu cobertura_vivienda_con____alcant cobertura_vivienda_con____energi cobertura_vivienda_con____gas cobertura_vivienda_con____telefo industria comercio servicios otras_actividades unidades_auxiliares_tipo_gerenci unidades_auxiliares_diferentes_d desocupada trabaj no_trabaj_pero_tena_trabajo busc_trabajo_pero_haba_trabajado busc_trabajo_por_primera_vez estudi_y_no_trabaj_ni_busc_traba realiz_oficios_del_hogar_y_no_tr incapacitado_permanentemente_par vivi_de_jubilacin_o_renta_y_no_t estuvo_en_otra_situacin jefe_o_jefa_del_hogar conyuge__pareja_ hijo_a___hijastro_a_ yerno__nuera nieto_a_ padre__madre_o_suegro_a_ hermano_a___hermanastro_a_ otro_pariente empleado__a__domestico otro_no_pariente hijo_a__hijastro_a_ yerno_nuera padre_madre_o_suegro_a_ hermano_a__hermanastro_a_ nocasadoylleva2oaosviviendoparej nocasadoyllevade2aosviviendopare separado_a__divorciado_a_ viudo_a_ soltero_a_ casado_a_ indgena rom raizal palenquero negro__a___mulato__afrocolombian ninguno_de_los_anteriores cogigo_barrio alguna_limitacin_si  alguna_limitacin_total limitacin_para_aprender limitacin_para_baarse limitacin_para_caminar limitacin_para_hablar limitacin_para_oir limitacin_para_ver limitacin_para_socializar limitacin_para_usar_brazos_o_man limitacin_para_otro sabe_leer_y_escribir_no_informa sabe_leer_y_escribir_total sabe_leer_y_escribir_15__24_aos_ v10 asistencia_educativa_ratio sabe_leer_y_escribir_ratio tasa_assistenciaesc_index_sum"
	stepwise, pr(.5) pe(.2): regress `var' `indepenent'
	outreg2 using regtableseform.doc, append  e(all)
}
*stepwise models poisson		
foreach var in countdenguebarrio countchikvbarrio countzikabarrio{
	local indepenent  "Total_pop arean3210 estrato_mon3210 asistencia_educativa_0__4_aos_si preescolar bsica_primaria bsica_secundaria media_acadmica_clsica media_tcnica superior__y__postgrado _ninguno no_informa occupation_condition_ocupada_con v5 occupation_condition_desocupadas  occupation_condition_total tipo_de_vivienda_casa tipo_de_vivienda_apartamento  tipo_de_vivienda_otro_tipo vivienda_con_acueducto vivienda_con_alcantarillado vivienda_con_energia vivienda_con_gas vivienda_con_telefono cobertura_vivienda_con____acuedu cobertura_vivienda_con____alcant cobertura_vivienda_con____energi cobertura_vivienda_con____gas cobertura_vivienda_con____telefo industria comercio servicios otras_actividades unidades_auxiliares_tipo_gerenci unidades_auxiliares_diferentes_d desocupada trabaj no_trabaj_pero_tena_trabajo busc_trabajo_pero_haba_trabajado busc_trabajo_por_primera_vez estudi_y_no_trabaj_ni_busc_traba realiz_oficios_del_hogar_y_no_tr incapacitado_permanentemente_par vivi_de_jubilacin_o_renta_y_no_t estuvo_en_otra_situacin jefe_o_jefa_del_hogar conyuge__pareja_ hijo_a___hijastro_a_ yerno__nuera nieto_a_ padre__madre_o_suegro_a_ hermano_a___hermanastro_a_ otro_pariente empleado__a__domestico otro_no_pariente hijo_a__hijastro_a_ yerno_nuera padre_madre_o_suegro_a_ hermano_a__hermanastro_a_ nocasadoylleva2oaosviviendoparej nocasadoyllevade2aosviviendopare separado_a__divorciado_a_ viudo_a_ soltero_a_ casado_a_ indgena rom raizal palenquero negro__a___mulato__afrocolombian ninguno_de_los_anteriores cogigo_barrio alguna_limitacin_si  alguna_limitacin_total limitacin_para_aprender limitacin_para_baarse limitacin_para_caminar limitacin_para_hablar limitacin_para_oir limitacin_para_ver limitacin_para_socializar limitacin_para_usar_brazos_o_man limitacin_para_otro sabe_leer_y_escribir_no_informa sabe_leer_y_escribir_total sabe_leer_y_escribir_15__24_aos_ v10 asistencia_educativa_ratio sabe_leer_y_escribir_ratio tasa_assistenciaesc_index_sum"
	stepwise, pr(.5) pe(.2): poisson `var' `indepenent'
	outreg2 using poissontableseform.doc, append e(r2_p) eform 
}

*stepwise models regression indices		
foreach var in countdenguebarrio countchikvbarrio countzikabarrio{
local indepenent  "arean3210 estrato_mon3210 indgena rom raizal palenquero negro__a___mulato__afrocolombian ninguno_de_los_anteriores Total_pop asistencia_educativa_ratio alguna_limitacin_ratio sabe_leer_y_escribir_ratio services_index_sum services_coverage_index_sum tasa_assistenciaesc_index_sum empty_ratio maletofemale"
	stepwise, pr(.5) pe(.2): regress `var' `indepenent'
	outreg2 using regtables_indiceseform.doc, append  e(all)
}
*stepwise models poisson indices		
foreach var in countdenguebarrio countchikvbarrio countzikabarrio{
local indepenent  "arean3210 estrato_mon3210 indgena rom raizal palenquero negro__a___mulato__afrocolombian ninguno_de_los_anteriores Total_pop asistencia_educativa_ratio alguna_limitacin_ratio sabe_leer_y_escribir_ratio services_index_sum services_coverage_index_sum tasa_assistenciaesc_index_sum empty_ratio maletofemale"
	stepwise, pr(.5) pe(.2): poisson `var' `indepenent'
	outreg2 using poissontables_indiceseform.doc, append e(r2_p) eform 
}
/**selected models
foreach var in countdenguebarrio countchikvbarrio countzikabarrio{
		*select based on knowledge.....
		local indepenent  "Total_pop arean3210 estrato_mon3210 asistencia_educativa_0__4_aos_si preescolar bsica_primaria bsica_secundaria media_acadmica_clsica media_tcnica superior__y__postgrado _ninguno no_informa occupation_condition_ocupada_con v5 occupation_condition_desocupadas  occupation_condition_total tipo_de_vivienda_casa tipo_de_vivienda_apartamento  tipo_de_vivienda_otro_tipo vivienda_con_acueducto vivienda_con_alcantarillado vivienda_con_energia vivienda_con_gas vivienda_con_telefono cobertura_vivienda_con____acuedu cobertura_vivienda_con____alcant cobertura_vivienda_con____energi cobertura_vivienda_con____gas cobertura_vivienda_con____telefo industria comercio servicios otras_actividades unidades_auxiliares_tipo_gerenci unidades_auxiliares_diferentes_d desocupada trabaj no_trabaj_pero_tena_trabajo busc_trabajo_pero_haba_trabajado busc_trabajo_por_primera_vez estudi_y_no_trabaj_ni_busc_traba realiz_oficios_del_hogar_y_no_tr incapacitado_permanentemente_par vivi_de_jubilacin_o_renta_y_no_t estuvo_en_otra_situacin jefe_o_jefa_del_hogar conyuge__pareja_ hijo_a___hijastro_a_ yerno__nuera nieto_a_ padre__madre_o_suegro_a_ hermano_a___hermanastro_a_ otro_pariente empleado__a__domestico otro_no_pariente hijo_a__hijastro_a_ yerno_nuera padre_madre_o_suegro_a_ hermano_a__hermanastro_a_ nocasadoylleva2oaosviviendoparej nocasadoyllevade2aosviviendopare separado_a__divorciado_a_ viudo_a_ soltero_a_ casado_a_ indgena rom raizal palenquero negro__a___mulato__afrocolombian ninguno_de_los_anteriores cogigo_barrio alguna_limitacin_si  alguna_limitacin_total limitacin_para_aprender limitacin_para_baarse limitacin_para_caminar limitacin_para_hablar limitacin_para_oir limitacin_para_ver limitacin_para_socializar limitacin_para_usar_brazos_o_man limitacin_para_otro sabe_leer_y_escribir_no_informa sabe_leer_y_escribir_total sabe_leer_y_escribir_15__24_aos_ v10 asistencia_educativa_ratio sabe_leer_y_escribir_ratio tasa_assistenciaesc_index_sum"
		regress  `var' `indepenent'
		}
*/

*export
order codigo_barrio countzikabarrio countchikvbarrio countdenguebarrio
sort countzikabarrio countchikvbarrio countdenguebarrio
export excel using "neighborhood_GWR_indices", firstrow(variables) replace
save merged_barrio_july72016.dta, replace	
