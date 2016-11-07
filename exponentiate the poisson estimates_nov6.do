cd "C:\Users\amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\output"
insheet using "nov6_nomissing_zvd_listwise.csv", comma clear
save zvd, replace

insheet using "nov6_nomissing_denv_listwise.csv", comma clear
save denv, replace

insheet using "nov6_nomissing_zvd_listwise.csv", comma clear
save chikv, replace

foreach dataset in denv zvd chikv{
use `dataset', clear
drop t_* ginfluence

		foreach var in est_intercept est_rainlag1 est_avg_rain est_serv_cov_index est_services_index est_assist_educ_p est_alguna_limit_p est_literate_p est_ed_index_sum est_assist_esc_ind est_home_empty_p est_estrato_mon3210 est_male_p est_negro__a___mulato__afrop est_unem_p est_home_p est_single_p est_cobertura_alcant est_cobertura_energi est_arean3210 est_temp_anom_median_c est_templag1{


				local new = substr("`var'", 5, 15)
					rename `var' `new'

				gen exp_`dataset'_`new' = exp(`new') 
				gen exp_SE_`dataset'_`new' = exp(`new')*se_`new'		
				
				gen log_`dataset'_`new' = `new'
				gen log_SE_`dataset'_`new' = se_`new'		
		
		drop `new' se_`new'
		}

		save `dataset', replace
}
merge 1:1 area_key using denv
drop _merge
merge 1:1 area_key using zvd
drop _merge

save merged, replace

keep area_key exp_SE_*  y yhat localpdev  
outsheet using exp_se.csv, comma replace
save exp_se, replace

use merged, clear
drop exp_SE_* log_* 
outsheet using exp_est.csv, comma replace
save exp_est, replace


use merged, clear
keep area_key log_SE_* y yhat localpdev  
outsheet using logse.csv, comma replace
save se, replace

use merged, clear
drop exp* log_SE_* 
outsheet using logest.csv, comma replace
save est, replace


