cd "C:\Users\amykr\Google Drive\Kent\james\dissertation\chkv and dengue\arcgis analysis\gwr models\output"


foreach dataset in "109chikbsq1" "109zikabsq" "109denbsq"{
	insheet using "`dataset'.csv", comma clear 
	save "`dataset'.dta", replace
}

foreach dataset in "109chikbsq1" "109zikabsq" "109denbsq"{
use `dataset'.dta, clear
drop t_* ginfluence

		foreach var in    est_intercept est_rainlag1 est_serv_cov_index est_anm_ed_index_sum est_anm_assist_esc_ind est_male_p est_negro__a___mulato__afrop est_single_p est_anm_cobertura_energi est_temp_anom_median_c est_templag1 est_estrato_mon3210{
*		est_intercept est_rainlag1 est_serv_cov_index est_single_p est_anm_cobertura_energi est_templag1{


				local new = substr("`var'", 5, 10)
					rename `var' `new'

				gen exp_`dataset'_`new' = exp(`new') 
				gen exp_SE_`dataset'_`new' = exp(`new')*se_`new'		
				
				gen log_`dataset'_`new' = `new'
				gen log_SE_`dataset'_`new' = se_`new'		
		
		drop `new' se_`new'

}

rename yhat predicted
rename y dependent

gen residual = dependent-predicted

foreach var in predicted dependent localpdev residual{
rename `var' `var'`dataset'	
		}
	
twoway scatter residual predicted
graph export predictedresidual`dataset'.tif, replace width(4000)
		save `dataset'.dta, replace
}

merge 1:1 area_key using 109chikbsq1.dta
drop _merge
merge 1:1 area_key using 109zikabsq.dta
drop _merge

save merged, replace

keep area_key exp_SE_*  predicted* dependent* residual* localpdev*  
outsheet using exp_se.csv, comma replace
save exp_se, replace

use merged, clear
drop exp_SE_* log_* 
outsheet using exp_est.csv, comma replace
save exp_est, replace


use merged, clear
keep area_key log_SE_* predicted* dependent* residual* localpdev*
outsheet using logse.csv, comma replace
save se, replace

use merged, clear
drop exp* log_SE_* 
outsheet using logest.csv, comma replace
save est, replace


