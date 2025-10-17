cap clear all
set more off
cap log close
set varabbrev off

loc extract_date = "20251017"

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

log using "$logdir/main_ownership_results_`today'.smcl", replace

loc time0 = "$S_TIME"
loc date0 = "$S_DATE"

di "started: `time0' `date0'"

timer clear
timer on 1  

/**************************/
/* MAIN OWNERSHIP RESULTS */
/**************************/

use "$datadir/main_panel.dta", clear

keep if missing(treatment_major) == 0
ren treatment_major treatment

gen post = anio_fiscal >= 2015

gen b_participation_prominent = participation_prominent > 0 if missing(participation_prominent) == 0
gen b_participation_inv_prominent = participation_inv_prominent > 0 if missing(participation_inv_prominent) == 0

gegen any_prom_presence_int = rowmax(intermediate_prom_int b_participation_prominent)
gegen any_prom_presence_alt = rowmax(intermediate_prom_alt b_participation_prominent)

gegen any_haven_presence_int = rowmax(intermediate_pff_int b_participation_prominent)
gegen any_haven_presence_alt = rowmax(intermediate_pff_alt b_participation_prominent)

gegen any_prom_presence_intalt = rowmax(intermediate_prom_alt b_participation_prominent)
	replace any_prom_presence_intalt = . if intermediate_prom_alt == .
	
gegen any_haven_presence_intalt = rowmax(intermediate_pff_alt b_participation_prominent)
	replace any_haven_presence_intalt = . if intermediate_pff_alt == .
	
gegen any_inv_prom_presence_int = rowmax(intermediate_inv_prom_int b_participation_prominent)
gegen any_inv_prom_presence_alt = rowmax(intermediate_inv_prom_alt b_participation_prominent)

gegen any_nonhaven_presence_int = rowmax(intermediate_ext_int b_participation_prominent)
gegen any_nonhaven_presence_alt = rowmax(intermediate_ext_alt b_participation_prominent)

foreach v in 10 50 100 {
	
	gegen any_prom_`v'_presence_int = rowmax(intermediate_`v'_prom_int b_participation_prominent)
	gegen any_prom_`v'_presence_alt = rowmax(intermediate_`v'_prom_alt b_participation_prominent)

	gegen any_haven_`v'_presence_int = rowmax(intermediate_`v'_pff_int b_participation_prominent)
	gegen any_haven_`v'_presence_alt = rowmax(intermediate_`v'_pff_alt b_participation_prominent)
	
	gegen any_prom_`v'_presence_intalt = rowmax(intermediate_`v'_prom_alt b_participation_prominent)	
		replace any_prom_`v'_presence_intalt = . if intermediate_`v'_prom_alt == .
		
	gegen any_haven_`v'_presence_intalt = rowmax(intermediate_`v'_pff_alt b_participation_prominent)
		replace any_haven_`v'_presence_intalt = . if intermediate_`v'_pff_alt == .
		
	gegen any_inv_prom_`v'_presence_int = rowmax(intermediate_`v'_inv_prom_int b_participation_inv_prominent)
	gegen any_inv_prom_`v'_presence_alt = rowmax(intermediate_`v'_inv_prom_alt b_participation_inv_prominent)
	
	gegen any_nonhaven_`v'_presence_int = rowmax(intermediate_`v'_ext_int b_participation_inv_prominent)
	gegen any_nonhaven_`v'_presence_alt = rowmax(intermediate_`v'_ext_alt b_participation_inv_prominent)
	
}

gegen passive_unrelated_local = rowtotal(passive_c_unrelated_local passive_l_unrelated_local)
gegen passive_unrelated_ext = rowtotal(passive_c_unrelated_ext passive_l_unrelated_ext)
gegen passive_related_local = rowtotal(passive_c_related_local passive_l_related_local)
gegen passive_related_ext = rowtotal(passive_c_related_ext passive_l_related_ext)

gegen passive_related = rowtotal(passive_related_local passive_related_ext)
gegen passive_alt = rowtotal(passive_related_local passive_related_ext passive_unrelated_local passive_unrelated_ext)

gegen active_unrelated_local = rowtotal(active_c_unrelated_local active_l_unrelated_local)
gegen active_unrelated_ext = rowtotal(active_c_unrelated_ext active_l_unrelated_ext)
gegen active_related_local = rowtotal(active_c_related_local active_l_related_local)
gegen active_related_ext = rowtotal(active_c_related_ext active_l_related_ext)

gegen active_related = rowtotal(active_related_local active_related_ext)
gegen active_alt = rowtotal(active_related_local active_related_ext active_unrelated_local active_unrelated_ext)

//year-to-year increase variables
gsort firm_id + anio_fiscal

foreach v in investments mid_div_salidas_pff mid_div_salidas_pff_rr mid_all_salidas_pff mid_all_salidas_prom mid_all_salidas_pff_rr mid_all_salidas_prom_rr debt_ratio total_assets total_passive labor_cost labor_ratio foreign_related_w local_related_w passive_related_ext passive_related_local {

	gen b_`v'_inc = `v' > `v'[_n-1] if firm_id == firm_id[_n-1] & missing(`v') == 0 & missing(`v'[_n-1]) == 0
	gen b_`v'_dec = `v' < `v'[_n-1] if firm_id == firm_id[_n-1] & missing(`v') == 0 & missing(`v'[_n-1]) == 0
	
}

///
//UNWEIGHTED
///

cap postclose main_ownership_results
postfile main_ownership_results str32(var) double(coef stderr N r2) using "$outdir/main_ownership_results.dta", replace

ds post firm_id anio_fiscal group_assign group treatment treatment_minor exposure prominent_2014 t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt prominent_2012_2014 porcion_comp_soc_no_inf_3576 porcion_comp_soc_si_inf_3578, not

foreach y in `r(varlist)' {	
	
// foreach y in participation_prominent any_prom_presence_int any_prom_presence_alt any_inv_prom_presence_int any_inv_prom_presence_alt any_inv_prom_10_presence_alt any_inv_prom_10_presence_int any_prom_10_presence_alt any_prom_10_presence_int any_inv_prom_50_presence_alt any_inv_prom_50_presence_int any_prom_50_presence_alt any_prom_50_presence_int any_inv_prom_100_presence_alt any_inv_prom_100_presence_int any_prom_100_presence_alt any_prom_100_presence_int any_haven_presence_int any_haven_presence_alt any_nonhaven_presence_int any_nonhaven_presence_alt any_nonhaven_10_presence_alt any_nonhaven_10_presence_int any_haven_10_presence_alt any_haven_10_presence_int any_nonhaven_50_presence_alt any_nonhaven_50_presence_int any_haven_50_presence_alt any_haven_50_presence_int any_nonhaven_100_presence_alt any_nonhaven_100_presence_int any_haven_100_presence_alt any_haven_100_presence_int any_prom_presence_intalt any_haven_presence_intalt any_prom_10_presence_intalt any_haven_10_presence_intalt any_prom_50_presence_intalt any_haven_50_presence_intalt any_prom_100_presence_intalt any_haven_100_presence_intalt intermediate_10_pff_int intermediate_10_ext_int intermediate_50_pff_int intermediate_50_ext_int intermediate_100_pff_int intermediate_100_ext_int intermediate_pff_int intermediate_ext_int intermediate_prom_int intermediate_inv_prom_int intermediate_10_prom_int intermediate_10_inv_prom_int intermediate_50_prom_int intermediate_50_inv_prom_int intermediate_100_prom_int intermediate_100_inv_prom_int intermediate_pff_alt intermediate_ext_alt intermediate_10_pff_alt intermediate_10_ext_alt intermediate_50_pff_alt intermediate_50_ext_alt intermediate_100_pff_alt intermediate_100_ext_alt intermediate_prom_alt intermediate_inv_prom_alt intermediate_10_prom_alt intermediate_10_inv_prom_alt intermediate_50_prom_alt intermediate_50_inv_prom_alt intermediate_100_prom_alt intermediate_100_inv_prom_alt any_haven any_nonhaven any_nonhaven_alt any_haven_alt any_prom any_prom_alt any_inv_prom any_inv_prom_alt passive_alt passive_related active_related active_alt b_investments_inc b_investments_dec b_mid_all_salidas_pff_inc b_mid_all_salidas_pff_dec b_mid_all_salidas_prom_inc b_mid_all_salidas_prom_dec b_mid_all_salidas_pff_rr_inc b_mid_all_salidas_pff_rr_dec b_mid_all_salidas_prom_rr_inc  b_debt_ratio_inc b_debt_ratio_dec b_total_assets_inc b_total_assets_dec b_total_passive_inc b_total_passive_dec b_labor_cost_inc b_labor_cost_dec b_labor_ratio_inc b_labor_ratio_dec b_foreign_related_w_inc b_foreign_related_w_dec b_local_related_w_inc b_local_related_w_dec b_passive_related_ext_inc b_passive_related_ext_dec b_passive_related_local_inc b_passive_related_local_dec {
	
	//levels
	cap n reghdfe `y' b0.i.treatment##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/main_ownership_results.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels", design, "event_study") detail(scalars)
		
	cap n reghdfe `y' b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id)
	
		if !_rc regsave using "$outdir/main_ownership_results.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels", design, "dd") detail(scalars)	

	//skipping if the variable is a binary variable
	qui sum `y'
	if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue

	cap gen l_`y' = log(`y')
	cap gen b_`y' = `y' > 0 if missing(`y') == 0
	
	//log
	cap n reghdfe l_`y' b0.i.treatment##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/main_ownership_results.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log", design, "event_study") detail(scalars)
		
	cap n reghdfe l_`y' b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id)
	
		if !_rc regsave using "$outdir/main_ownership_results.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log", design, "dd") detail(scalars)	
		
	//poisson
	cap n ppmlhdfe `y' b0.i.treatment##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
		
		if !_rc regsave using "$outdir/main_ownership_results.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
		
	cap n ppmlhdfe `y' b0.i.treatment##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id)
	
		if !_rc regsave using "$outdir/main_ownership_results.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson", design, "dd") detail(scalars)	
	
	if strpos("`y'", "_rr") != 0 continue 
	
	//binary
	cap n reghdfe b_`y' b0.i.treatment##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
		if !_rc regsave using "$outdir/main_ownership_results.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary", design, "event_study") detail(scalars)
		
	cap n reghdfe b_`y' b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id)
	
		if !_rc regsave using "$outdir/main_ownership_results.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary", design, "dd") detail(scalars)	
	
}

cap postclose main_ownership_results

///
//WEIGHTED
///

use "$datadir/main_panel.dta", clear

bys firm_id: gegen assets_2014 = total(cond(anio_fiscal == 2014, round(total_assets), .))
replace assets_2014 = round(assets_2014)

keep if missing(treatment_major) == 0
ren treatment_major treatment

gen post = anio_fiscal >= 2015

gen b_participation_prominent = participation_prominent > 0 if missing(participation_prominent) == 0
gen b_participation_inv_prominent = participation_inv_prominent > 0 if missing(participation_inv_prominent) == 0

gegen any_prom_presence_int = rowmax(intermediate_prom_int b_participation_prominent)
gegen any_prom_presence_alt = rowmax(intermediate_prom_alt b_participation_prominent)

gegen any_haven_presence_int = rowmax(intermediate_pff_int b_participation_prominent)
gegen any_haven_presence_alt = rowmax(intermediate_pff_alt b_participation_prominent)

gegen any_prom_presence_intalt = rowmax(intermediate_prom_alt b_participation_prominent)
	replace any_prom_presence_intalt = . if intermediate_prom_alt == .
	
gegen any_haven_presence_intalt = rowmax(intermediate_pff_alt b_participation_prominent)
	replace any_haven_presence_intalt = . if intermediate_pff_alt == .
	
gegen any_inv_prom_presence_int = rowmax(intermediate_inv_prom_int b_participation_prominent)
gegen any_inv_prom_presence_alt = rowmax(intermediate_inv_prom_alt b_participation_prominent)

gegen any_nonhaven_presence_int = rowmax(intermediate_ext_int b_participation_prominent)
gegen any_nonhaven_presence_alt = rowmax(intermediate_ext_alt b_participation_prominent)

foreach v in 10 50 100 {
	
	gegen any_prom_`v'_presence_int = rowmax(intermediate_`v'_prom_int b_participation_prominent)
	gegen any_prom_`v'_presence_alt = rowmax(intermediate_`v'_prom_alt b_participation_prominent)

	gegen any_haven_`v'_presence_int = rowmax(intermediate_`v'_pff_int b_participation_prominent)
	gegen any_haven_`v'_presence_alt = rowmax(intermediate_`v'_pff_alt b_participation_prominent)
	
	gegen any_prom_`v'_presence_intalt = rowmax(intermediate_`v'_prom_alt b_participation_prominent)	
		replace any_prom_`v'_presence_intalt = . if intermediate_`v'_prom_alt == .
		
	gegen any_haven_`v'_presence_intalt = rowmax(intermediate_`v'_pff_alt b_participation_prominent)
		replace any_haven_`v'_presence_intalt = . if intermediate_`v'_pff_alt == .
		
	gegen any_inv_prom_`v'_presence_int = rowmax(intermediate_`v'_inv_prom_int b_participation_inv_prominent)
	gegen any_inv_prom_`v'_presence_alt = rowmax(intermediate_`v'_inv_prom_alt b_participation_inv_prominent)
	
	gegen any_nonhaven_`v'_presence_int = rowmax(intermediate_`v'_ext_int b_participation_inv_prominent)
	gegen any_nonhaven_`v'_presence_alt = rowmax(intermediate_`v'_ext_alt b_participation_inv_prominent)
	
}

gegen passive_unrelated_local = rowtotal(passive_c_unrelated_local passive_l_unrelated_local)
gegen passive_unrelated_ext = rowtotal(passive_c_unrelated_ext passive_l_unrelated_ext)
gegen passive_related_local = rowtotal(passive_c_related_local passive_l_related_local)
gegen passive_related_ext = rowtotal(passive_c_related_ext passive_l_related_ext)

gegen passive_related = rowtotal(passive_related_local passive_related_ext)
gegen passive_alt = rowtotal(passive_related_local passive_related_ext passive_unrelated_local passive_unrelated_ext)

gegen active_unrelated_local = rowtotal(active_c_unrelated_local active_l_unrelated_local)
gegen active_unrelated_ext = rowtotal(active_c_unrelated_ext active_l_unrelated_ext)
gegen active_related_local = rowtotal(active_c_related_local active_l_related_local)
gegen active_related_ext = rowtotal(active_c_related_ext active_l_related_ext)

gegen active_related = rowtotal(active_related_local active_related_ext)
gegen active_alt = rowtotal(active_related_local active_related_ext active_unrelated_local active_unrelated_ext)

//year-to-year increase variables
gsort firm_id + anio_fiscal

foreach v in investments mid_all_salidas_pff mid_all_salidas_prom mid_all_salidas_pff_rr mid_all_salidas_prom_rr mid_div_salidas_pff mid_div_salidas_prom mid_div_salidas_pff_rr mid_div_salidas_prom_rr mid_fin_salidas_pff mid_fin_salidas_prom mid_fin_salidas_pff_rr mid_fin_salidas_prom_rr debt_ratio total_assets total_passive labor_cost labor_ratio foreign_related_w local_related_w passive_related_ext passive_related_local {

	gen b_`v'_inc = `v' > `v'[_n-1] if firm_id == firm_id[_n-1] & missing(`v') == 0 & missing(`v'[_n-1]) == 0
	gen b_`v'_dec = `v' < `v'[_n-1] if firm_id == firm_id[_n-1] & missing(`v') == 0 & missing(`v'[_n-1]) == 0
	
}

cap postclose main_ownership_results_weighted
postfile main_ownership_results_weighted str32(var) double(coef stderr N r2) using "$outdir/main_ownership_results_weighted.dta", replace

ds post firm_id anio_fiscal group_assign group treatment treatment_minor exposure prominent_2014 t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt prominent_2012_2014 porcion_comp_soc_no_inf_3576 porcion_comp_soc_si_inf_3578 assets_2014, not

foreach y in `r(varlist)' {	
	
// foreach y in participation_prominent any_prom_presence_int any_prom_presence_alt any_inv_prom_presence_int any_inv_prom_presence_alt any_inv_prom_10_presence_alt any_inv_prom_10_presence_int any_prom_10_presence_alt any_prom_10_presence_int any_inv_prom_50_presence_alt any_inv_prom_50_presence_int any_prom_50_presence_alt any_prom_50_presence_int any_inv_prom_100_presence_alt any_inv_prom_100_presence_int any_prom_100_presence_alt any_prom_100_presence_int any_haven_presence_int any_haven_presence_alt any_nonhaven_presence_int any_nonhaven_presence_alt any_nonhaven_10_presence_alt any_nonhaven_10_presence_int any_haven_10_presence_alt any_haven_10_presence_int any_nonhaven_50_presence_alt any_nonhaven_50_presence_int any_haven_50_presence_alt any_haven_50_presence_int any_nonhaven_100_presence_alt any_nonhaven_100_presence_int any_haven_100_presence_alt any_haven_100_presence_int any_prom_presence_intalt any_haven_presence_intalt any_prom_10_presence_intalt any_haven_10_presence_intalt any_prom_50_presence_intalt any_haven_50_presence_intalt any_prom_100_presence_intalt any_haven_100_presence_intalt intermediate_10_pff_int intermediate_10_ext_int intermediate_50_pff_int intermediate_50_ext_int intermediate_100_pff_int intermediate_100_ext_int intermediate_pff_int intermediate_ext_int intermediate_prom_int intermediate_inv_prom_int intermediate_10_prom_int intermediate_10_inv_prom_int intermediate_50_prom_int intermediate_50_inv_prom_int intermediate_100_prom_int intermediate_100_inv_prom_int intermediate_pff_alt intermediate_ext_alt intermediate_10_pff_alt intermediate_10_ext_alt intermediate_50_pff_alt intermediate_50_ext_alt intermediate_100_pff_alt intermediate_100_ext_alt intermediate_prom_alt intermediate_inv_prom_alt intermediate_10_prom_alt intermediate_10_inv_prom_alt intermediate_50_prom_alt intermediate_50_inv_prom_alt intermediate_100_prom_alt intermediate_100_inv_prom_alt any_haven any_nonhaven any_nonhaven_alt any_haven_alt any_prom any_prom_alt any_inv_prom any_inv_prom_alt passive_alt passive_related active_related active_alt b_investments_inc b_investments_dec b_mid_all_salidas_pff_inc b_mid_all_salidas_pff_dec b_mid_all_salidas_prom_inc b_mid_all_salidas_prom_dec b_mid_all_salidas_pff_rr_inc b_mid_all_salidas_pff_rr_dec b_mid_all_salidas_prom_rr_inc b_debt_ratio_inc b_debt_ratio_dec b_total_assets_inc b_total_assets_dec b_total_passive_inc b_total_passive_dec b_labor_cost_inc b_labor_cost_dec b_labor_ratio_inc b_labor_ratio_dec b_foreign_related_w_inc b_foreign_related_w_dec b_local_related_w_inc b_local_related_w_dec b_passive_related_ext_inc b_passive_related_ext_dec b_passive_related_local_inc b_passive_related_local_dec {
		
	//only running on winsorized variables when applicable	
	cap confirm variable `y'_w
	if !_rc continue
			
	//levels
	cap n reghdfe `y' b0.i.treatment##b2014.i.anio_fiscal [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/main_ownership_results_weighted.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels", design, "event_study") detail(scalars)
		
	cap n reghdfe `y' b0.i.treatment##b0.i.post i.anio_fiscal [aweight = assets_2014], cluster(firm_id) absorb(firm_id)
	
		if !_rc regsave using "$outdir/main_ownership_results_weighted.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels", design, "dd") detail(scalars)	
	
	//skipping if the variable is a binary variable
	qui sum `y'
	if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue

	cap gen l_`y' = log(`y')
	cap gen b_`y' = `y' > 0 if missing(`y') == 0
			
	//log
	cap n reghdfe l_`y' b0.i.treatment##b2014.i.anio_fiscal [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/main_ownership_results_weighted.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log", design, "event_study") detail(scalars)
		
	cap n reghdfe l_`y' b0.i.treatment##b0.i.post i.anio_fiscal [aweight = assets_2014], cluster(firm_id) absorb(firm_id)
	
		if !_rc regsave using "$outdir/main_ownership_results_weighted.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log", design, "dd") detail(scalars)	
	
	//poisson
	cap n ppmlhdfe `y' b0.i.treatment##b2014.i.anio_fiscal if `y' >= 0 [fweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal) maxiter(300)
		
		if !_rc regsave using "$outdir/main_ownership_results_weighted.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
		
	cap n ppmlhdfe `y' b0.i.treatment##b0.i.post i.anio_fiscal if `y' >= 0 [fweight = assets_2014], cluster(firm_id) absorb(firm_id) maxiter(300)
	
		if !_rc regsave using "$outdir/main_ownership_results_weighted.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson", design, "dd") detail(scalars)	
	
	if strpos("`y'", "_rr") != 0 continue 
	
	//binary
	cap n reghdfe b_`y' b0.i.treatment##b2014.i.anio_fiscal [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
		
		if !_rc regsave using "$outdir/main_ownership_results_weighted.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary", design, "event_study") detail(scalars)
		
	cap n reghdfe b_`y' b0.i.treatment##b0.i.post i.anio_fiscal [aweight = assets_2014], cluster(firm_id) absorb(firm_id)
	
		if !_rc regsave using "$outdir/main_ownership_results_weighted.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary", design, "dd") detail(scalars)	
	
}

cap postclose main_ownership_results_weighted

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

di "file main_ownership_results has terminated successfully"

cap log close
clear
