cap clear all
set more off
cap log close
set varabbrev off

loc extract_date = "20251017"

/***********/
/* HISTORY */
/***********/
	
//20250625: ex-post strict
	
//20250729: adding in lincom on difference to haven remainers	
	
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

log using "$logdir/expost_strict_results_`today'.smcl", replace

loc time0 = "$S_TIME"
loc date0 = "$S_DATE"

di "started: `time0' `date0'"

timer clear
timer on 1  
*/

/*******************/
/* SRI ENVIRONMENT */
/*******************/

local today: di %tdCYND daily("$S_DATE", "DMY")
local month = substr("`today'", 1, 6)

glob localdir "D:\BM_EXTENSION\B202106_JAKOB_BROUNSTEIN"

/*
//alt
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

log using "$logdir/expost_results_`today'.smcl", replace

loc time0 = "$S_TIME"
loc date0 = "$S_DATE"

di "started: `time0' `date0'"

timer clear
timer on 1  

/*************************/
/* EXPOST STRICT RESULTS */
/*************************/

use "$datadir/main_panel.dta", clear

keep if missing(treatment_major) == 0
ren treatment_major treatment

foreach v in porcentaje_pff porcentaje_ext porcentaje_nac  {
	
	gen `v'_50 = `v' >= 50 if missing(`v') == 0
	
}

gen porcentaje_pff_0 = porcentaje_pff == 0 

bys firm_id: gegen majority_pff_post = mean(cond(inrange(anio_fiscal, 2015, 2019), porcentaje_pff_50, .))
bys firm_id: gegen majority_ext_post = mean(cond(inrange(anio_fiscal, 2015, 2019), porcentaje_ext_50, .))
bys firm_id: gegen majority_nac_post = mean(cond(inrange(anio_fiscal, 2015, 2019), porcentaje_nac_50, .))

bys firm_id: gegen pff_0_post = mean(cond(inrange(anio_fiscal, 2015, 2019), porcentaje_pff_0, .))

//mapping to perfect compliance with condition
foreach v in majority_pff_post majority_ext_post majority_nac_post pff_0_post {
	
	replace `v' = (`v' == 1)
	
}

gen treatment_expost = 0 if treatment == 0
	replace treatment_expost = 1 if treatment == 1 & majority_pff_post == 1
	replace treatment_expost = 2 if treatment == 1 & majority_ext_post == 1
	replace treatment_expost = 3 if treatment == 1 & majority_nac_post == 1
	replace treatment_expost = 4 if treatment == 1 & majority_pff_post == 0 & majority_ext_post == 0 & majority_nac_post == 0
	
gen treatment_expost_alt = 0 if treatment == 0
	replace treatment_expost_alt = 1 if treatment == 1 & majority_pff_post == 1
	replace treatment_expost_alt = 2 if treatment == 1 & pff_0_post == 1
	replace treatment_expost_alt = 3 if treatment == 1 & pff_0_post == 0 & majority_pff_post == 0

gen treatment_expost_remain = 0 if treatment == 0
	replace treatment_expost_remain = 1 if treatment == 1 & majority_pff_post == 1
	replace treatment_expost_remain = 2 if treatment == 1 & majority_pff_post == 0
	
gen post = anio_fiscal >= 2015

gegen passive_unrelated_local = rowtotal(passive_c_unrelated_local passive_l_unrelated_local)
gegen passive_unrelated_ext = rowtotal(passive_c_unrelated_ext passive_l_unrelated_ext)
gegen passive_related_local = rowtotal(passive_c_related_local passive_l_related_local)
gegen passive_related_ext = rowtotal(passive_c_related_ext passive_l_related_ext)

gegen passive_related = rowtotal(passive_related_local passive_related_ext)
gegen passive_alt = rowtotal(passive_related_local passive_related_ext passive_unrelated_local passive_unrelated_ext)

foreach v in investments mid_all_salidas_pff mid_all_salidas_prom mid_all_salidas_pff_rr mid_all_salidas_prom_rr mid_div_salidas_pff mid_div_salidas_prom mid_div_salidas_pff_rr mid_div_salidas_prom_rr mid_fin_salidas_pff mid_fin_salidas_prom mid_fin_salidas_pff_rr mid_fin_salidas_prom_rr debt_ratio total_assets total_passive labor_cost labor_ratio foreign_related_w local_related_w passive_related_ext passive_related_local {

	gen b_`v'_inc = `v' > `v'[_n-1] if firm_id == firm_id[_n-1] & missing(`v') == 0 & missing(`v'[_n-1]) == 0
	gen b_`v'_dec = `v' < `v'[_n-1] if firm_id == firm_id[_n-1] & missing(`v') == 0 & missing(`v'[_n-1]) == 0
	
}

///	
//treatment_expost
///
	
cap postclose expost_strict
postfile expost_strict str32(var) double(coef stderr N r2) using "$outdir/expost_strict_results.dta", replace

cap postclose expost_strict_descriptive
postfile expost_strict_descriptive str32(var) double(coef stderr N r2) using "$outdir/expost_strict_descriptive.dta", replace

ds post firm_id anio_fiscal group_assign group treatment treatment_minor exposure prominent_2014 t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt prominent_2012_2014 porcion_comp_soc_no_inf_3576 porcion_comp_soc_si_inf_3578 majority_pff_post majority_ext_post majority_nac_post pff_0_post treatment_expost treatment_expost_alt, not
	
foreach y in `r(varlist)' {
	
	//levels
	cap n reghdfe `y' b0.i.treatment_expost##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/expost_strict_results.dta", append autoid addlabel(depvar, `y', spec, "levels", design, "event_study") detail(scalars)
		
	cap n reghdfe `y' b0.i.treatment_expost##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc {
	
			forv x = 2/4 {
				
				cap n lincom _b[`x'.treatment_expost#1.post] - _b[1.treatment_expost#1.post]
				loc dif`x' = r(estimate)
				loc dif`x'_se = r(se)
				
			}
			
			if !_rc regsave using "$outdir/expost_strict_results.dta", append autoid addlabel(depvar, `y', spec, "levels", design, "dd", dif2, `dif2', dif2_se, `dif2_se', dif3, `dif3', dif3_se, `dif3_se', dif4, `dif4', dif4_se, `dif4_se') detail(scalars)	
		
		}
		
	cap n reg `y' b1.i.treatment_expost if anio_fiscal == 2014, r
		
		if !_rc regsave using "$outdir/expost_strict_descriptive.dta", append autoid addlabel(depvar, `y', spec, "levels", design, "descriptive") detail(scalars)
		
	//skipping if the variable is a binary variable
	qui sum `y'
	if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue

	cap gen l_`y' = log(`y')
	cap gen b_`y' = `y' > 0 if missing(`y') == 0
	
	//log
	cap n reghdfe l_`y' b0.i.treatment_expost##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/expost_strict_results.dta", append autoid addlabel(depvar, `y', spec, "log", design, "event_study") detail(scalars)
		
	cap n reghdfe l_`y' b0.i.treatment_expost##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc {
	
			forv x = 2/4 {
				
				cap n lincom _b[`x'.treatment_expost#1.post] - _b[1.treatment_expost#1.post]
				loc dif`x' = r(estimate)
				loc dif`x'_se = r(se)
				
			}
			
			if !_rc regsave using "$outdir/expost_strict_results.dta", append autoid addlabel(depvar, `y', spec, "log", design, "dd", dif2, `dif2', dif2_se, `dif2_se', dif3, `dif3', dif3_se, `dif3_se', dif4, `dif4', dif4_se, `dif4_se') detail(scalars)	
		
		}
		
	cap n reg l_`y' b1.i.treatment_expost if anio_fiscal == 2014, r
		
		if !_rc regsave using "$outdir/expost_strict_descriptive.dta", append autoid addlabel(depvar, `y', spec, "log", design, "descriptive") detail(scalars)
		
	//poisson
	cap n ppmlhdfe `y' b0.i.treatment_expost##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
		
		if !_rc regsave using "$outdir/expost_strict_results.dta", append autoid addlabel(depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
		
	cap n ppmlhdfe `y' b0.i.treatment_expost##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc {
	
			forv x = 2/4 {
				
				cap n lincom _b[`x'.treatment_expost#1.post] - _b[1.treatment_expost#1.post]
				loc dif`x' = r(estimate)
				loc dif`x'_se = r(se)
				
			}
			
			if !_rc regsave using "$outdir/expost_strict_results.dta", append autoid addlabel(depvar, `y', spec, "poisson", design, "dd", dif2, `dif2', dif2_se, `dif2_se', dif3, `dif3', dif3_se, `dif3_se', dif4, `dif4', dif4_se, `dif4_se') detail(scalars)	
		
		}
		
	cap n ppmlhdfe `y' b1.i.treatment_expost if anio_fiscal == 2014, vce(robust)
		
		if !_rc regsave using "$outdir/expost_strict_descriptive.dta", append autoid addlabel(depvar, `y', spec, "poisson", design, "descriptive") detail(scalars)
		
	if strpos("`y'", "_rr") != 0 continue 
	
	//binary
	cap n reghdfe b_`y' b0.i.treatment_expost##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
		if !_rc regsave using "$outdir/expost_strict_results.dta", append autoid addlabel(depvar, `y', spec, "binary", design, "event_study") detail(scalars)
		
	cap n reghdfe b_`y' b0.i.treatment_expost##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
		if !_rc {
	
			forv x = 2/4 {
				
				cap n lincom _b[`x'.treatment_expost#1.post] - _b[1.treatment_expost#1.post]
				loc dif`x' = r(estimate)
				loc dif`x'_se = r(se)
				
			}
			
			if !_rc regsave using "$outdir/expost_strict_results.dta", append autoid addlabel(depvar, `y', spec, "binary", design, "dd", dif2, `dif2', dif2_se, `dif2_se', dif3, `dif3', dif3_se, `dif3_se', dif4, `dif4', dif4_se, `dif4_se') detail(scalars)	
		
		}
		
	cap n reg b_`y' b1.i.treatment_expost if anio_fiscal == 2014, r
		
		if !_rc regsave using "$outdir/expost_strict_descriptive.dta", append autoid addlabel(depvar, `y', spec, "binary", design, "descriptive") detail(scalars)	
	
}

cap postclose expost_strict_results
cap postclose expost_strict_descriptive
*/

///
//treatment_expost_alt
///

use "$datadir/main_panel.dta", clear

keep if missing(treatment_major) == 0
ren treatment_major treatment

foreach v in porcentaje_pff porcentaje_ext porcentaje_nac  {
	
	gen `v'_50 = `v' >= 50 if missing(`v') == 0
	
}

gen porcentaje_pff_0 = porcentaje_pff == 0 

bys firm_id: gegen majority_pff_post = mean(cond(inrange(anio_fiscal, 2015, 2019), porcentaje_pff_50, .))
bys firm_id: gegen majority_ext_post = mean(cond(inrange(anio_fiscal, 2015, 2019), porcentaje_ext_50, .))
bys firm_id: gegen majority_nac_post = mean(cond(inrange(anio_fiscal, 2015, 2019), porcentaje_nac_50, .))

bys firm_id: gegen pff_0_post = mean(cond(inrange(anio_fiscal, 2015, 2019), porcentaje_pff_0, .))

//mapping to perfect compliance with condition
foreach v in majority_pff_post majority_ext_post majority_nac_post pff_0_post {
	
	replace `v' = (`v' == 1)
	
}

gen treatment_expost = 0 if treatment == 0
	replace treatment_expost = 1 if treatment == 1 & majority_pff_post == 1
	replace treatment_expost = 2 if treatment == 1 & majority_ext_post == 1
	replace treatment_expost = 3 if treatment == 1 & majority_nac_post == 1
	replace treatment_expost = 4 if treatment == 1 & majority_pff_post == 0 & majority_ext_post == 0 & majority_nac_post == 0
	
gen treatment_expost_alt = 0 if treatment == 0
	replace treatment_expost_alt = 1 if treatment == 1 & majority_pff_post == 1
	replace treatment_expost_alt = 2 if treatment == 1 & pff_0_post == 1
	replace treatment_expost_alt = 3 if treatment == 1 & pff_0_post == 0 & majority_pff_post == 0
	
gen treatment_expost_remain = 0 if treatment == 0
	replace treatment_expost_remain = 1 if treatment == 1 & majority_pff_post == 1
	replace treatment_expost_remain = 2 if treatment == 1 & majority_pff_post == 0
	
foreach v in investments mid_all_salidas_pff mid_all_salidas_prom mid_all_salidas_pff_rr mid_all_salidas_prom_rr mid_div_salidas_pff mid_div_salidas_prom mid_div_salidas_pff_rr mid_div_salidas_prom_rr mid_fin_salidas_pff mid_fin_salidas_prom mid_fin_salidas_pff_rr mid_fin_salidas_prom_rr debt_ratio total_assets total_passive labor_cost labor_ratio foreign_related_w local_related_w passive_related_ext passive_related_local {

	gen b_`v'_inc = `v' > `v'[_n-1] if firm_id == firm_id[_n-1] & missing(`v') == 0 & missing(`v'[_n-1]) == 0
	gen b_`v'_dec = `v' < `v'[_n-1] if firm_id == firm_id[_n-1] & missing(`v') == 0 & missing(`v'[_n-1]) == 0
	
}

gegen passive_unrelated_local = rowtotal(passive_c_unrelated_local passive_l_unrelated_local)
gegen passive_unrelated_ext = rowtotal(passive_c_unrelated_ext passive_l_unrelated_ext)
gegen passive_related_local = rowtotal(passive_c_related_local passive_l_related_local)
gegen passive_related_ext = rowtotal(passive_c_related_ext passive_l_related_ext)

gegen passive_related = rowtotal(passive_related_local passive_related_ext)
gegen passive_alt = rowtotal(passive_related_local passive_related_ext passive_unrelated_local passive_unrelated_ext)
	
gen post = anio_fiscal >= 2015

cap postclose expost_strict_alt_results
postfile expost_strict_alt_results str32(var) double(coef stderr N r2) using "$outdir/expost_strict_alt_results.dta", replace

cap postclose expost_strict_alt_descriptive
postfile expost_strict_alt_descriptive str32(var) double(coef stderr N r2) using "$outdir/expost_strict_alt_descriptive.dta", replace

ds post firm_id anio_fiscal group_assign group treatment treatment_minor exposure prominent_2014 t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt prominent_2012_2014 porcion_comp_soc_no_inf_3576 porcion_comp_soc_si_inf_3578 majority_pff_post majority_ext_post majority_nac_post pff_0_post treatment_expost treatment_expost_alt, not
	
foreach y in `r(varlist)' {
	
	//levels
	cap n reghdfe `y' b0.i.treatment_expost_alt##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/expost_strict_alt_results.dta", append autoid addlabel(depvar, `y', spec, "levels", design, "event_study") detail(scalars)
		
	cap n reghdfe `y' b0.i.treatment_expost_alt##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
		if !_rc {
		
			forv x = 2/3 {
				
				cap n lincom _b[`x'.treatment_expost_alt#1.post] - _b[1.treatment_expost_alt#1.post]
				loc dif`x' = r(estimate)
				loc dif`x'_se = r(se)
				
			}
		
			if !_rc regsave using "$outdir/expost_strict_alt_results.dta", append autoid addlabel(depvar, `y', spec, "levels", design, "dd", dif2, `dif2', dif2_se, `dif2_se', dif3, `dif3', dif3_se, `dif3_se') detail(scalars)	

		}
		
	cap n reg `y' b1.i.treatment_expost_alt if anio_fiscal == 2014, r
		
		if !_rc regsave using "$outdir/expost_strict_alt_descriptive.dta", append autoid addlabel(depvar, `y', spec, "levels", design, "descriptive") detail(scalars)	
		
	//skipping if the variable is a binary variable
	qui sum `y'
	if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue

	cap gen l_`y' = log(`y')
	cap gen b_`y' = `y' > 0 if missing(`y') == 0
	
	//log
	cap n reghdfe l_`y' b0.i.treatment_expost_alt##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/expost_strict_alt_results.dta", append autoid addlabel(depvar, `y', spec, "log", design, "event_study") detail(scalars)
		
	cap n reghdfe l_`y' b0.i.treatment_expost_alt##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc {
		
			forv x = 2/3 {
				
				cap n lincom _b[`x'.treatment_expost_alt#1.post] - _b[1.treatment_expost_alt#1.post]
				loc dif`x' = r(estimate)
				loc dif`x'_se = r(se)
				
			}
		
			if !_rc regsave using "$outdir/expost_strict_alt_results.dta", append autoid addlabel(depvar, `y', spec, "log", design, "dd", dif2, `dif2', dif2_se, `dif2_se', dif3, `dif3', dif3_se, `dif3_se') detail(scalars)	

		}
		
	cap n reg l_`y' b1.i.treatment_expost_alt if anio_fiscal == 2014, r
		
		if !_rc regsave using "$outdir/expost_strict_alt_descriptive.dta", append autoid addlabel(depvar, `y', spec, "log", design, "descriptive") detail(scalars)		
		
	//poisson
	cap n ppmlhdfe `y' b0.i.treatment_expost_alt##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
		
		if !_rc regsave using "$outdir/expost_strict_alt_results.dta", append autoid addlabel(depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
		
	cap n ppmlhdfe `y' b0.i.treatment_expost_alt##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc {
		
			forv x = 2/3 {
				
				cap n lincom _b[`x'.treatment_expost_alt#1.post] - _b[1.treatment_expost_alt#1.post]
				loc dif`x' = r(estimate)
				loc dif`x'_se = r(se)
				
			}
		
			if !_rc regsave using "$outdir/expost_strict_alt_results.dta", append autoid addlabel(depvar, `y', spec, "poisson", design, "dd", dif2, `dif2', dif2_se, `dif2_se', dif3, `dif3', dif3_se, `dif3_se') detail(scalars)	

		}
		
	cap n ppmlhdfe `y' b1.i.treatment_expost_alt if anio_fiscal == 2014, vce(robust)
		
		if !_rc regsave using "$outdir/expost_strict_alt_descriptive.dta", append autoid addlabel(depvar, `y', spec, "poisson", design, "descriptive") detail(scalars)		
		
	if strpos("`y'", "_rr") != 0 continue 
	
	//binary
	cap n reghdfe b_`y' b0.i.treatment_expost_alt##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
		if !_rc regsave using "$outdir/expost_strict_alt_results.dta", append autoid addlabel(depvar, `y', spec, "binary", design, "event_study") detail(scalars)
		
	cap n reghdfe b_`y' b0.i.treatment_expost_alt##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc {
		
			forv x = 2/3 {
				
				cap n lincom _b[`x'.treatment_expost_alt#1.post] - _b[1.treatment_expost_alt#1.post]
				loc dif`x' = r(estimate)
				loc dif`x'_se = r(se)
				
			}
		
			if !_rc regsave using "$outdir/expost_strict_alt_results.dta", append autoid addlabel(depvar, `y', spec, "binary", design, "dd", dif2, `dif2', dif2_se, `dif2_se', dif3, `dif3', dif3_se, `dif3_se') detail(scalars)	

		}
	
	cap n reg b_`y' b1.i.treatment_expost_alt if anio_fiscal == 2014, vce(robust)
		
		if !_rc regsave using "$outdir/expost_strict_alt_descriptive.dta", append autoid addlabel(depvar, `y', spec, "binary", design, "descriptive") detail(scalars)		
		
}

cap postclose expost_strict_alt_results

///
//TREATMENT EX-POST REMAIN
///

///
//treatment_expost_alt
///

use "$datadir/main_panel.dta", clear

keep if missing(treatment_major) == 0
ren treatment_major treatment

foreach v in porcentaje_pff porcentaje_ext porcentaje_nac  {
	
	gen `v'_50 = `v' >= 50 if missing(`v') == 0
	
}

gen porcentaje_pff_0 = porcentaje_pff == 0 

bys firm_id: gegen majority_pff_post = mean(cond(inrange(anio_fiscal, 2015, 2019), porcentaje_pff_50, .))
bys firm_id: gegen majority_ext_post = mean(cond(inrange(anio_fiscal, 2015, 2019), porcentaje_ext_50, .))
bys firm_id: gegen majority_nac_post = mean(cond(inrange(anio_fiscal, 2015, 2019), porcentaje_nac_50, .))

bys firm_id: gegen pff_0_post = mean(cond(inrange(anio_fiscal, 2015, 2019), porcentaje_pff_0, .))

//mapping to perfect compliance with condition
foreach v in majority_pff_post majority_ext_post majority_nac_post pff_0_post {
	
	replace `v' = (`v' == 1)
	
}

gen treatment_expost = 0 if treatment == 0
	replace treatment_expost = 1 if treatment == 1 & majority_pff_post == 1
	replace treatment_expost = 2 if treatment == 1 & majority_ext_post == 1
	replace treatment_expost = 3 if treatment == 1 & majority_nac_post == 1
	replace treatment_expost = 4 if treatment == 1 & majority_pff_post == 0 & majority_ext_post == 0 & majority_nac_post == 0
	
gen treatment_expost_alt = 0 if treatment == 0
	replace treatment_expost_alt = 1 if treatment == 1 & majority_pff_post == 1
	replace treatment_expost_alt = 2 if treatment == 1 & pff_0_post == 1
	replace treatment_expost_alt = 3 if treatment == 1 & pff_0_post == 0 & majority_pff_post == 0

gen treatment_expost_remain = 0 if treatment == 0
	replace treatment_expost_remain = 1 if treatment == 1 & majority_pff_post == 1
	replace treatment_expost_remain = 2 if treatment == 1 & majority_pff_post == 0
	
gen post = anio_fiscal >= 2015

gegen passive_unrelated_local = rowtotal(passive_c_unrelated_local passive_l_unrelated_local)
gegen passive_unrelated_ext = rowtotal(passive_c_unrelated_ext passive_l_unrelated_ext)
gegen passive_related_local = rowtotal(passive_c_related_local passive_l_related_local)
gegen passive_related_ext = rowtotal(passive_c_related_ext passive_l_related_ext)

gegen passive_related = rowtotal(passive_related_local passive_related_ext)
gegen passive_alt = rowtotal(passive_related_local passive_related_ext passive_unrelated_local passive_unrelated_ext)

foreach v in investments mid_all_salidas_pff mid_all_salidas_prom mid_all_salidas_pff_rr mid_all_salidas_prom_rr mid_div_salidas_pff mid_div_salidas_prom mid_div_salidas_pff_rr mid_div_salidas_prom_rr mid_fin_salidas_pff mid_fin_salidas_prom mid_fin_salidas_pff_rr mid_fin_salidas_prom_rr debt_ratio total_assets total_passive labor_cost labor_ratio foreign_related_w local_related_w passive_related_ext passive_related_local {

	gen b_`v'_inc = `v' > `v'[_n-1] if firm_id == firm_id[_n-1] & missing(`v') == 0 & missing(`v'[_n-1]) == 0
	gen b_`v'_dec = `v' < `v'[_n-1] if firm_id == firm_id[_n-1] & missing(`v') == 0 & missing(`v'[_n-1]) == 0
	
}

cap postclose expost_strict_remain_results
postfile expost_strict_remain_results str32(var) double(coef stderr N r2) using "$outdir/expost_strict_remain_results.dta", replace

cap postclose expost_strict_remain_descriptive
postfile expost_strict_remain_descriptive str32(var) double(coef stderr N r2) using "$outdir/expost_strict_remain_descriptive.dta", replace

ds post firm_id anio_fiscal group_assign group treatment treatment_minor exposure prominent_2014 t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt prominent_2012_2014 porcion_comp_soc_no_inf_3576 porcion_comp_soc_si_inf_3578 majority_pff_post majority_ext_post majority_nac_post pff_0_post treatment_expost treatment_expost_alt, not
	
foreach y in `r(varlist)' {
	
	//levels
	cap n reghdfe `y' b0.i.treatment_expost_remain##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/expost_strict_remain_results.dta", append autoid addlabel(depvar, `y', spec, "levels", design, "event_study") detail(scalars)
		
	cap n reghdfe `y' b0.i.treatment_expost_remain##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
		if !_rc {
		
			forv x = 2/2 {
				
				cap n lincom _b[`x'.treatment_expost_remain#1.post] - _b[1.treatment_expost_remain#1.post]
				loc dif`x' = r(estimate)
				loc dif`x'_se = r(se)
				
			}
		
			if !_rc regsave using "$outdir/expost_strict_remain_results.dta", append autoid addlabel(depvar, `y', spec, "levels", design, "dd", dif2, `dif2', dif2_se, `dif2_se') detail(scalars)	

		}
		
	cap n reg `y' b1.i.treatment_expost_remain if anio_fiscal == 2014, r
		
		if !_rc regsave using "$outdir/expost_strict_remain_descriptive.dta", append autoid addlabel(depvar, `y', spec, "levels", design, "descriptive") detail(scalars)	
		
	//skipping if the variable is a binary variable
	qui sum `y'
	if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue

	cap gen l_`y' = log(`y')
	cap gen b_`y' = `y' > 0 if missing(`y') == 0
	
	//log
	cap n reghdfe l_`y' b0.i.treatment_expost_remain##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/expost_strict_remain_results.dta", append autoid addlabel(depvar, `y', spec, "log", design, "event_study") detail(scalars)
		
	cap n reghdfe l_`y' b0.i.treatment_expost_remain##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc {
		
			forv x = 2/2 {
				
				cap n lincom _b[`x'.treatment_expost_remain#1.post] - _b[1.treatment_expost_remain#1.post]
				loc dif`x' = r(estimate)
				loc dif`x'_se = r(se)
				
			}
		
			if !_rc regsave using "$outdir/expost_strict_remain_results.dta", append autoid addlabel(depvar, `y', spec, "log", design, "dd", dif2, `dif2', dif2_se, `dif2_se') detail(scalars)	

		}
		
	cap n reg l_`y' b1.i.treatment_expost_remain if anio_fiscal == 2014, r
		
		if !_rc regsave using "$outdir/expost_strict_remain_descriptive.dta", append autoid addlabel(depvar, `y', spec, "log", design, "descriptive") detail(scalars)		
		
	//poisson
	cap n ppmlhdfe `y' b0.i.treatment_expost_remain##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
		
		if !_rc regsave using "$outdir/expost_strict_remain_results.dta", append autoid addlabel(depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
		
	cap n ppmlhdfe `y' b0.i.treatment_expost_remain##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc {
		
			forv x = 2/2 {
				
				cap n lincom _b[`x'.treatment_expost_remain#1.post] - _b[1.treatment_expost_remain#1.post]
				loc dif`x' = r(estimate)
				loc dif`x'_se = r(se)
				
			}
		
			if !_rc regsave using "$outdir/expost_strict_remain_results.dta", append autoid addlabel(depvar, `y', spec, "poisson", design, "dd", dif2, `dif2', dif2_se, `dif2_se') detail(scalars)	

		}
		
	cap n ppmlhdfe `y' b1.i.treatment_expost_remain if anio_fiscal == 2014, vce(robust)
		
		if !_rc regsave using "$outdir/expost_strict_remain_descriptive.dta", append autoid addlabel(depvar, `y', spec, "poisson", design, "descriptive") detail(scalars)		
		
	if strpos("`y'", "_rr") != 0 continue 
	
	//binary
	cap n reghdfe b_`y' b0.i.treatment_expost_remain##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
		if !_rc regsave using "$outdir/expost_strict_remain_results.dta", append autoid addlabel(depvar, `y', spec, "binary", design, "event_study") detail(scalars)
		
	cap n reghdfe b_`y' b0.i.treatment_expost_remain##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc {
		
			forv x = 2/2 {
				
				cap n lincom _b[`x'.treatment_expost_remain#1.post] - _b[1.treatment_expost_remain#1.post]
				loc dif`x' = r(estimate)
				loc dif`x'_se = r(se)
				
			}
		
			if !_rc regsave using "$outdir/expost_strict_remain_results.dta", append autoid addlabel(depvar, `y', spec, "binary", design, "dd", dif2, `dif2', dif2_se, `dif2_se') detail(scalars)	

		}
	
	cap n reg b_`y' b1.i.treatment_expost_remain if anio_fiscal == 2014, vce(robust)
		
		if !_rc regsave using "$outdir/expost_strict_remain_descriptive.dta", append autoid addlabel(depvar, `y', spec, "binary", design, "descriptive") detail(scalars)		
		
}

cap postclose expost_strict_remain_results

/*
/************************/
/* EX-POST DESCRIPTIVES */
/************************/

use "$datadir/main_panel.dta", clear

keep if missing(treatment_major) == 0
ren treatment_major treatment

foreach v in porcentaje_pff porcentaje_ext porcentaje_nac  {
	
	gen `v'_50 = `v' >= 50 if missing(`v') == 0
	
}

gen porcentaje_pff_0 = porcentaje_pff == 0 
gen porcentaje_pff_0_50 = porcentaje_pff > 0 & porcentaje_pff < 50 & missing(porcentaje_pff) == 0 

bys firm_id: gegen majority_pff_post = mean(cond(inrange(anio_fiscal, 2015, 2019), porcentaje_pff_50, .))
bys firm_id: gegen majority_ext_post = mean(cond(inrange(anio_fiscal, 2015, 2019), porcentaje_ext_50, .))
bys firm_id: gegen majority_nac_post = mean(cond(inrange(anio_fiscal, 2015, 2019), porcentaje_nac_50, .))

bys firm_id: gegen pff_0_post = mean(cond(inrange(anio_fiscal, 2015, 2019), porcentaje_pff_0, .))

//mapping to perfect compliance with condition
foreach v in majority_pff_post majority_ext_post majority_nac_post pff_0_post {
	
	replace `v' = (`v' == 1)
	
}

gen treatment_expost = 0 if treatment == 0
	replace treatment_expost = 1 if treatment == 1 & majority_pff_post == 1
	replace treatment_expost = 2 if treatment == 1 & majority_ext_post == 1
	replace treatment_expost = 3 if treatment == 1 & majority_nac_post == 1
	replace treatment_expost = 4 if treatment == 1 & majority_pff_post == 0 & majority_ext_post == 0 & majority_nac_post == 0
	
gen treatment_expost_alt = 0 if treatment == 0
	replace treatment_expost_alt = 1 if treatment == 1 & majority_pff_post == 1 // >= 50 every year post
	replace treatment_expost_alt = 2 if treatment == 1 & pff_0_post == 1 // 0 post
	replace treatment_expost_alt = 3 if treatment == 1 & pff_0_post == 0 & majority_pff_post == 0 // other
	
gen count = 1

keep if anio_fiscal == 2014

//need to pare down a lot

//not doing mid prominent or inverse groups, as these are implied by the groups
drop participation_inv_prominent ///
mid_div_salidas_prom mid_div_salidas_inv mid_div_entradas_prom mid_div_entradas_inv mid_fin_salidas_prom mid_fin_salidas_inv mid_fin_entradas_prom mid_fin_entradas_inv mid_all_salidas_prom mid_all_salidas_inv mid_all_entradas_prom mid_all_entradas_inv mid_div_salidas_prom_rr mid_div_salidas_prom_rr_w mid_div_salidas_inv_rr mid_div_salidas_inv_rr_w mid_div_entradas_prom_rr mid_div_entradas_prom_rr_w mid_div_entradas_inv_rr mid_div_entradas_inv_rr_w mid_fin_salidas_prom_rr mid_fin_salidas_prom_rr_w mid_fin_salidas_inv_rr mid_fin_salidas_inv_rr_w mid_fin_entradas_prom_rr mid_fin_entradas_prom_rr_w mid_fin_entradas_inv_rr mid_fin_entradas_inv_rr_w mid_all_salidas_prom_rr mid_all_salidas_prom_rr_w mid_all_salidas_inv_rr mid_all_salidas_inv_rr_w mid_all_entradas_prom_rr mid_all_entradas_prom_rr_w mid_all_entradas_inv_rr mid_all_entradas_inv_rr_w mid_all_salidas_prom_w mid_all_salidas_inv_w mid_all_entradas_prom_w mid_all_entradas_inv_w mid_div_salidas_prom_w mid_div_salidas_inv_w mid_div_entradas_prom_w mid_div_entradas_inv_w mid_fin_salidas_prom_w mid_fin_salidas_inv_w mid_fin_entradas_prom_w mid_fin_entradas_inv_w 

//other drops
drop tasa_vigente treatment treatment_minor exposure prominent_2014 t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt prominent_2012_2014 porcion_comp_soc_no_inf_3576 porcion_comp_soc_si_inf_3578 aps_residual_pais_other porcentaje_vac beneficiarios_vac beneficiarios_10_vac intermediate_vac intermediate_10_vac intermediate_50_vac dummy_utilidad dummy_cero firm_id group_assign group majority_pff_post majority_ext_post majority_nac_post pff_0_post anio_fiscal

cap drop exclusion_motive

//dropping winsorized variables, as just trying to describe raw variables
drop current_investment_w activos_c_w total_activos_fijos_690_w activos_intangibles_alt_w total_activos_lp_1070_w total_assets_w passive_c_w total_pasivos_int_1600_w total_passive_w total_capital_w dividendos_percibidos_w revenue_w total_cost_expenses_w gross_profit_w perdida_ejercicio_3430_w participacion_tbj_15_3440_w taxable_profits_w perdida_3570_w uti_reinvertir_cpz_3580_w cit_liability_w impuesto_renta_pagar_3680_w agregated_debt_int_w local_related_w local_unrelated_w foreign_related_w foreign_unrelated_w passive_c_related_local_w passive_c_unrelated_local_w passive_c_related_ext_w passive_c_unrelated_ext_w passive_l_related_local_w passive_l_unrelated_local_w passive_l_related_ext_w passive_l_unrelated_ext_w activos_intangibles_w investments_w inversiones_no_corrientes_w inversiones_lp_rel_w active_c_related_local_w active_c_unrelated_local_w active_c_related_ext_w active_c_unrelated_ext_w active_l_related_local_w active_l_unrelated_local_w active_l_related_ext_w active_l_unrelated_ext_w total_activos_netos_w debt_ratio_w tot_currentassets_net_w net_active_c_related_local_w net_active_c_unrel_local_w net_active_c_related_ext_w net_active_c_unrelated_ext_w net_active_l_related_local_w net_active_l_unrel_local_w net_active_l_related_ext_w net_active_l_unrelated_ext_w pagos_locales_w pagos_extranjeros_w labor_cost_w gastos_lab_w costos_lab_w exports_w local_sales_w total_sales_w labor_ratio_w taxable_profit_margin_w gross_profit_margin_w return_on_assets_w tasa_ir_w mid_div_salidas_pff_w mid_div_salidas_ext_w mid_div_entradas_pff_w mid_div_entradas_ext_w mid_fin_salidas_pff_w mid_fin_salidas_ext_w mid_fin_entradas_pff_w mid_fin_entradas_ext_w mid_all_salidas_pff_w mid_all_salidas_ext_w mid_all_entradas_pff_w mid_all_entradas_ext_w mid_fin_salidas_total_w mid_fin_entradas_total_w mid_div_salidas_total_w mid_div_entradas_total_w mid_all_salidas_total_w mid_all_entradas_total_w

foreach v in current_investment activos_c total_activos_fijos_690 activos_intangibles_alt total_activos_lp_1070 total_assets passive_c total_pasivos_int_1600 total_passive total_capital dividendos_percibidos revenue total_cost_expenses gross_profit perdida_ejercicio_3430 participacion_tbj_15_3440 taxable_profits perdida_3570 uti_reinvertir_cpz_3580 cit_liability tasa_ir impuesto_renta_pagar_3680 agregated_debt_int local_related local_unrelated foreign_related foreign_unrelated passive_c_related_local passive_c_unrelated_local passive_c_related_ext passive_c_unrelated_ext passive_l_related_local passive_l_unrelated_local passive_l_related_ext passive_l_unrelated_ext activos_intangibles investments inversiones_no_corrientes inversiones_lp_rel active_c_related_local active_c_unrelated_local active_c_related_ext active_c_unrelated_ext active_l_related_local active_l_unrelated_local active_l_related_ext active_l_unrelated_ext total_activos_netos tot_currentassets_net net_active_c_related_local net_active_c_unrel_local net_active_c_related_ext net_active_c_unrelated_ext net_active_l_related_local net_active_l_unrel_local net_active_l_related_ext net_active_l_unrelated_ext pagos_locales pagos_extranjeros labor_cost gastos_lab costos_lab exports local_sales total_sales taxable_profit_margin gross_profit_margin return_on_assets mid_div_salidas_pff mid_div_salidas_ext mid_div_entradas_pff mid_div_entradas_ext mid_fin_salidas_pff mid_fin_salidas_ext mid_fin_entradas_pff mid_fin_entradas_ext mid_all_salidas_pff mid_all_salidas_ext mid_all_entradas_pff mid_all_entradas_ext mid_fin_salidas_total mid_fin_entradas_total mid_div_salidas_total mid_div_entradas_total mid_all_salidas_total mid_all_entradas_total {
	
	qui sum `v'
	if r(sd) == 0 continue
	
	cap n gen l_`v' = log(`v')
	
}

//smaller set for binaries
foreach v in mid_div_salidas_pff mid_div_salidas_ext mid_div_entradas_pff mid_div_entradas_ext mid_fin_salidas_pff mid_fin_salidas_ext mid_fin_entradas_pff mid_fin_entradas_ext mid_all_salidas_pff mid_all_salidas_ext mid_all_entradas_pff mid_all_entradas_ext mid_fin_salidas_total mid_fin_entradas_total mid_div_salidas_total mid_div_entradas_total mid_all_salidas_total mid_all_entradas_total gross_profit taxable_profits cit_liability {

	qui sum `v'
	if r(sd) == 0 continue
	cap n gen b_`v' = (`v') > 0 if missing(`v') == 0
	
}

ds treatment_expost_alt treatment_expost, not

foreach v in `r(varlist)' {
		
	loc l = length("s_`v'")
	if `l' >= 33 di "s_`v' is `l'"
	
	local meanlist = "`meanlist'"+ " m_`v' = `v'"
	
	//not producing percentiles or sd for binaries
	if substr("`v'", 1, 2) == "b_"  continue
	
	qui sum `v'
	if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue
	
	local sdlist = "`sdlist'" + " s_`v' = `v'"
	local p10list = "`p10list'" + " `v'10 = `v'"
	local p50list = "`p50list'" + " `v'50 = `v'"
	local p90list = "`p90list'" + " `v'90 = `v'"

}

preserve

	gcollapse (sum) count (mean) `meanlist' (sd) `sdlist' (p10) `p10list' (p50) `p50list' (p90) `p90list', by(treatment_expost)

	save "$outdir/treatment_expost_strict_descriptives.dta", replace

restore

preserve

	gcollapse (sum) count (mean) `meanlist' (sd) `sdlist' (p10) `p10list' (p50) `p50list' (p90) `p90list', by(treatment_expost_alt)

	save "$outdir/treatment_expost_strict_alt_descriptives.dta", replace

restore
*/

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

di "file expost_strict_results has terminated successfully"

cap log close
clear
