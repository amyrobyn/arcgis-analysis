cd "C:\Users\amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\output"
insheet using "nov6_nomissing_zvd_listwise.csv", comma clear
save nov6_nomissing_zvd_listwise, replace

insheet using "nov6_nomissing_denv_listwise.csv", comma clear
save nov6_nomissing_denv_listwise, replace

insheet using "nov6_nomissing_zvd_listwise.csv", comma clear
save nov6_nomissing_chikv_listwise, replace

foreach dataset in nov6_nomissing_chikv_listwise nov6_nomissing_denv_listwise nov6_nomissing_zvd_listwise{
use `dataset', clear
drop t_* 

		foreach var in est_intercept est_rainlag1 est_avg_rain est_serv_cov_index est_services_index est_assist_educ_p est_alguna_limit_p est_literate_p est_ed_index_sum est_assist_esc_ind est_home_empty_p est_estrato_mon3210 est_male_p est_negro__a___mulato__afrop est_unem_p est_home_p est_single_p est_cobertura_alcant est_cobertura_energi est_arean3210 est_temp_anom_median_c est_templag1{


				local new = substr("`var'", 5, 15)
					rename `var' `new'

				gen exp_`new' = exp(`new') 
				gen exp_SE_`new' = exp(`new')*se_`new'		
		}
keep exp_*  area_key
		save `dataset', replace
}
