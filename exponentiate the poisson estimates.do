insheet using "C:\Users\amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\gwr4\chikv10_31_16B_listwise.csv", clear
drop t_* 

foreach var in est_intercept est_avg_rain est_temp_anom_median_c est_estrato_mon3210 est_services_coverage_index_sum est_empty_ratio est_total_pop est_educ_ratio est_arean3210 est_sabe_leer_y_escribir_ratio est_maletofemale est_alguna_limitacin_ratio est_tasa_assist_index_sum est_services_index_sum est_indigena est_rom est_raizal est_negro__a___mulato__afro est_ninguno_de_los_anteriores{

	local new = substr("`var'", 5, 15)
 	rename `var' `new'

gen `new'_IRR = exp(`new') 
gen SE_`new'_IRR = exp(`new')*se_`new'

}

outsheet using "C:\Users\amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\gwr4\chikv10_31_16B_listwise_exp.csv", comma replace

insheet using "C:\Users\amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\gwr4\zvdv10_31_16B_listwise_exp.csv", clear
drop t_* 

foreach var in est_intercept est_avg_rain est_temp_anom_median_c est_estrato_mon3210 est_services_coverage_index_sum est_empty_ratio est_total_pop est_educ_ratio est_arean3210 est_sabe_leer_y_escribir_ratio est_maletofemale est_alguna_limitacin_ratio est_tasa_assist_index_sum est_services_index_sum est_indigena est_rom est_raizal est_negro__a___mulato__afro est_ninguno_de_los_anteriores{

	local new = substr("`var'", 5, 15)
 	rename `var' `new'

gen `new'_IRR = exp(`new') 
gen SE_`new'_IRR = exp(`new')*se_`new'

}

outsheet using "C:\Users\amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\gwr4\zvdv10_31_16B_listwise_exp.csv", comma replace

insheet using "C:\Users\amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\gwr4\denv10_31_16B_listwise_exp.csv", clear
drop t_* 

foreach var in est_intercept est_avg_rain est_temp_anom_median_c est_estrato_mon3210 est_services_coverage_index_sum est_empty_ratio est_total_pop est_educ_ratio est_arean3210 est_sabe_leer_y_escribir_ratio est_maletofemale est_alguna_limitacin_ratio est_tasa_assist_index_sum est_services_index_sum est_indigena est_rom est_raizal est_negro__a___mulato__afro est_ninguno_de_los_anteriores{

	local new = substr("`var'", 5, 15)
 	rename `var' `new'

gen `new'_IRR = exp(`new') 
gen SE_`new'_IRR = exp(`new')*se_`new'

}
outsheet using "C:\Users\amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\gwr4\denv10_31_16B_listwise_exp.csv", comma replace

