cap clear all
set more off
cap log close
set varabbrev off

loc extract_date = "20251128"

/***********/
/* HISTORY */
/***********/
	
//20250606: main ownership results mock up

//20250609: generating basic ownership results
	
//20250618: added on a weightspec for 2014 levels assets

//20250623: correcting weightspec

//20250731: adding on a compound variable for any presence in domicile	

//20250815: adding on a compound variable for any presence in domicile, prominent group + year-to-year change
	
/*********/
/* NOTES */
/*********/

/***************************/
/* JAKOB LOCAL ENVIRONMENT */
/***************************/

/*
local today: di %tdCYND daily("$S_DATE", "DMY")
local month = substr("`today'", 1, 6)

glob localdir "/Users/jakob_brounstein/Dropbox/ecuador_transparency"
glob mydatadir "$localdir/data/local_simulation"
glob datadir "$localdir/data/local_simulation"
glob dodir "$localdir/do"
glob logdir "$localdir/logs"

glob graphdir "$localdir/local_simulation"
glob texdir "$localdir/local_simulation"

cap n mkdir "$localdir/local_simulation/resultados"

//export directory
cap n mkdir "$localdir/local_simulation/resultados/`today'"
cap n mkdir "$localdir/local_simulation/resultados/`today'/reportes"
glob outdir "$localdir/local_simulation/resultados/`today'/reportes"

log using "$logdir/main_ownership_results_`today'.smcl", replace

loc time0 = "$S_TIME"
loc date0 = "$S_DATE"

di "started: `time0' `date0'"

sca local_environment = 1

timer clear
timer on 1  
*/

/*******************/
/* SRI ENVIRONMENT */
/*******************/

local today: di %tdCYND daily("$S_DATE", "DMY")
local month = substr("`today'", 1, 6)

glob localdir "D:\BM_EXTENSION\B202106_JAKOB_BROUNSTEIN"

//alt
/*
glob localdir "F:\DTO_ESTUDIOS_E1_ext2\B_INVESTIGADORES_EXTERNOS\B202106_JAKOB_BROUNSTEIN"
sysdir set PLUS F:\DTO_ESTUDIOS_E1_ext2\B_INVESTIGADORES_EXTERNOS\B202106_JAKOB_BROUNSTEIN\Ado\ado_1\plus
sysdir set PERSONAL F:\DTO_ESTUDIOS_E1_ext2\B_INVESTIGADORES_EXTERNOS\B202106_JAKOB_BROUNSTEIN\Ado\ado\plus
*/

cap n mkdir "$localdir/resultados"

glob logdir "$localdir\logs"
glob dumpdir "$localdir\dump"
glob datadir "$localdir/data/transparency"
glob graphdir "$localdir/out"
glob texdir "$localdir/out"

//export directory
cap n mkdir "$localdir/resultados/`extract_date'"
cap n mkdir "$localdir/resultados/`extract_date'/reportes"
glob outdir "$localdir/resultados/`extract_date'/reportes"

log using "$logdir/main_ownership_results_vat_`today'.smcl", replace

loc time0 = "$S_TIME"
loc date0 = "$S_DATE"

di "started: `time0' `date0'"

timer clear
timer on 1  

/******************/
/* VAT PROCESSING */
/******************/

//attaching iva and adjusting for inflation
import delimited "$localdir\data\f104\vat_firms.csv", clear

cap ren id_an firm_id

keep firm_id anio_fiscal iva_causado iva_pagado

ren anio_fiscal year
merge m:1 year using "$datadir/cpi_year.dta", nogen keep(3) keepus(cpi2014)
ren year anio_fiscal

foreach v in iva_causado iva_pagado {
	
	replace `v' = `v' * 100 / cpi2014

}	

save "$datadir/f104.dta", replace

/**************************/
/* MAIN OWNERSHIP RESULTS */
/**************************/

use "$datadir/main_panel.dta", clear

keep if missing(treatment_major) == 0
ren treatment_major treatment

///
//UNWEIGHTED
///

//attaching iva and adjusting for inflation
merge 1:1 firm_id anio_fiscal using "$datadir/f104.dta", keep(1 3) nogen

foreach v in iva_pagado iva_causado {
	
	gen `v'_alt = `v'
	replace `v'_alt = 0 if missing(`v'_alt)
	
}

cap postclose main_ownership_results_vat
postfile main_ownership_results_vat str32(var) double(coef stderr N r2) using "$outdir/main_ownership_results_vat.dta", replace

foreach y in iva_pagado iva_causado iva_causado_alt iva_causado_alt {
	
	//levels
	cap n reghdfe `y' b0.i.treatment##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/main_ownership_results_vat.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels", design, "event_study") detail(scalars)
		
	cap n reghdfe `y' b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id)
	
		if !_rc regsave using "$outdir/main_ownership_results_vat.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels", design, "dd") detail(scalars)	

	//skipping if the variable is a binary variable
	qui sum `y'
	if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue

	cap gen l_`y' = log(`y')
	cap gen b_`y' = `y' > 0 if missing(`y') == 0
	
	//log
	cap n reghdfe l_`y' b0.i.treatment##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/main_ownership_results_vat.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log", design, "event_study") detail(scalars)
		
	cap n reghdfe l_`y' b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id)
	
		if !_rc regsave using "$outdir/main_ownership_results_vat.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log", design, "dd") detail(scalars)	
		
	//poisson
	cap n ppmlhdfe `y' b0.i.treatment##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
		
		if !_rc regsave using "$outdir/main_ownership_results_vat.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
		
	cap n ppmlhdfe `y' b0.i.treatment##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id)
	
		if !_rc regsave using "$outdir/main_ownership_results_vat.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson", design, "dd") detail(scalars)	
	
	if strpos("`y'", "_rr") != 0 continue 
	
	//binary
	cap n reghdfe b_`y' b0.i.treatment##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
		if !_rc regsave using "$outdir/main_ownership_results_vat.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary", design, "event_study") detail(scalars)
		
	cap n reghdfe b_`y' b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id)
	
		if !_rc regsave using "$outdir/main_ownership_results_vat.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary", design, "dd") detail(scalars)	
	
}

cap postclose main_ownership_results_vat

///
//WEIGHTED
///

use "$datadir/main_panel.dta", clear

bys firm_id: gegen assets_2014 = total(cond(anio_fiscal == 2014, round(total_assets), .))
replace assets_2014 = round(assets_2014)

//attaching iva and adjusting for inflation
merge 1:1 firm_id anio_fiscal using "$datadir/f104.dta", keep(1 3) nogen

foreach v in iva_pagado iva_causado {
	
	gen `v'_alt = `v'
	replace `v'_alt = 0 if missing(`v'_alt)
	
}

cap postclose main_ownership_results_w_vat
postfile main_ownership_results_w_vat str32(var) double(coef stderr N r2) using "$outdir/main_ownership_results_w_vat.dta", replace

foreach y in iva_pagado iva_causado iva_causado_alt iva_causado_alt {
		
	//only running on winsorized variables when applicable	
	cap confirm variable `y'_w
	if !_rc continue
			
	//levels
	cap n reghdfe `y' b0.i.treatment##b2014.i.anio_fiscal [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/main_ownership_results_w_vat.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels", design, "event_study") detail(scalars)
		
	cap n reghdfe `y' b0.i.treatment##b0.i.post i.anio_fiscal [aweight = assets_2014], cluster(firm_id) absorb(firm_id)
	
		if !_rc regsave using "$outdir/main_ownership_results_w_vat.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels", design, "dd") detail(scalars)	
	
	//skipping if the variable is a binary variable
	qui sum `y'
	if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue

	cap gen l_`y' = log(`y')
	cap gen b_`y' = `y' > 0 if missing(`y') == 0
			
	//log
	cap n reghdfe l_`y' b0.i.treatment##b2014.i.anio_fiscal [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/main_ownership_results_w_vat.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log", design, "event_study") detail(scalars)
		
	cap n reghdfe l_`y' b0.i.treatment##b0.i.post i.anio_fiscal [aweight = assets_2014], cluster(firm_id) absorb(firm_id)
	
		if !_rc regsave using "$outdir/main_ownership_results_w_vat.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log", design, "dd") detail(scalars)	
	
	//poisson
	cap n ppmlhdfe `y' b0.i.treatment##b2014.i.anio_fiscal if `y' >= 0 [fweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal) maxiter(300)
		
		if !_rc regsave using "$outdir/main_ownership_results_w_vat.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
		
	cap n ppmlhdfe `y' b0.i.treatment##b0.i.post i.anio_fiscal if `y' >= 0 [fweight = assets_2014], cluster(firm_id) absorb(firm_id) maxiter(300)
	
		if !_rc regsave using "$outdir/main_ownership_results_w_vat.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson", design, "dd") detail(scalars)	
	
	if strpos("`y'", "_rr") != 0 continue 
	
	//binary
	cap n reghdfe b_`y' b0.i.treatment##b2014.i.anio_fiscal [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
		
		if !_rc regsave using "$outdir/main_ownership_results_w_vat.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary", design, "event_study") detail(scalars)
		
	cap n reghdfe b_`y' b0.i.treatment##b0.i.post i.anio_fiscal [aweight = assets_2014], cluster(firm_id) absorb(firm_id)
	
		if !_rc regsave using "$outdir/main_ownership_results_w_vat.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary", design, "dd") detail(scalars)	
	
}

cap postclose main_ownership_results_w_vat

/*******/
/* END */
/*******/

timer off 1 

loc time1 = "$S_TIME"
loc date1 = "$S_DATE"

di "started: `time0' `date0'"
di "ended: `time1' `date1'"

timer list 
di "elapsed time: `r(t1)' seconds"

di "file main_ownership_results_vat has terminated successfully"

cap log close
clear
