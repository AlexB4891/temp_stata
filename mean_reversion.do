cap clear all
set more off
cap log close
set varabbrev off

loc extract_date = "20251017"

/***********/
/* HISTORY */
/***********/
	
//20250704: exploring mean reversion issues

//20250722: adding in no constant specs and paring dependent variables

//20250728: adding in combined group, adding in geo_alt

//20250731: changed to 2013-2014

//20250807: adding on additional mean reversion models

//20251013: adding in a mean reversion demonstration for subsequent years

/*********/
/* NOTES */
/*********/

/*
/***************************/
/* JAKOB LOCAL ENVIRONMENT */
/***************************/

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

//log using "$outdir/mean_reversion_`today'.smcl", replace

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

//alt environment
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

log using "$outdir/mean_reversion_`today'.smcl", replace

loc time0 = "$S_TIME"
loc date0 = "$S_DATE"

di "started: `time0' `date0'"

timer clear
timer on 1  


/*
/******************************/
/* MEAN REVERSION EXPLORATION */
/******************************/

use if inrange(anio_fiscal, 2012, 2014) using "$datadir/core_panel.dta", clear

keep firm_id anio_fiscal group aps f101 active aps_f101 aps_f101_active porcentaje_pff porcentaje_ext porcentaje_nac percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac terminal_ownership_conc terminal_owners_10 terminal_owners participation_prominent participation_prominent_0 intermediate_pff intermediate_ext intermediate_nac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_100_pff intermediate_pff_max intermediate_50_prominent intermediate_100_ext intermediate_100_prominent empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt persona_prominent

gen majority_pff = porcentaje_pff >= 50 if missing(porcentaje_pff) == 0
gen majority_ext = porcentaje_ext >= 50 if missing(porcentaje_ext) == 0
gen majority_nac = porcentaje_nac >= 50 if missing(porcentaje_nac) == 0

bys firm_id: gegen majority_pff_2012 = max(cond(anio_fiscal == 2012 & porcentaje_pff >= 50, 1, 0))
bys firm_id: gegen majority_ext_2012 = max(cond(anio_fiscal == 2012 & porcentaje_ext >= 50, 1, 0))
bys firm_id: gegen majority_nac_2012 = max(cond(anio_fiscal == 2012 & porcentaje_nac >= 50, 1, 0))

bys firm_id: gegen aps_count = count(cond(aps == 1, anio_fiscal, .))

gen group_2012 = 0 if majority_ext_2012 == 1 
	replace group_2012 = 1 if majority_pff_2012 == 1
	replace group_2012 = 2 if majority_nac_2012 == 1
	replace group_2012 = 3 if missing(group_2012)

keep if aps_count == 3
drop aps_count

keep if inlist(group_2012, 0, 1)

gegen id = group(firm_id)
xtset id anio_fiscal

cap postclose mean_reversion_2012_2014
postfile mean_reversion_2012_2014 str32(var) double(coef stderr N r2) using "$outdir/mean_reversion_2012_2014.dta", replace

gen l_porcentaje_pff = log(porcentaje_pff) 
gen l_porcentaje_ext = log(porcentaje_ext)
gen l_participation_prominent = log(participation_prominent)

foreach y in porcentaje_pff porcentaje_ext participation_prominent majority_pff majority_ext l_porcentaje_pff l_porcentaje_ext l_participation_prominent  {
	
	cap n reg `y' l1.`y', cluster(id)
	
		if !_rc regsave using "$outdir/mean_reversion_2012_2014.dta", append autoid addlabel(depvar, `y', group, group_all, spec, "unconditional", regspec, "constant") detail(scalars)
		
	cap n reg `y' l1.`y', cluster(id) noconstant
	
		if !_rc regsave using "$outdir/mean_reversion_2012_2014.dta", append autoid addlabel(depvar, `y', group, group_all, spec, "unconditional", regspec, "noconstant") detail(scalars)	
		
	cap n reg `y' c.l1.`y'##b0.i.group_2012, cluster(id)
	
		if !_rc regsave using "$outdir/mean_reversion_2012_2014.dta", append autoid addlabel(depvar, `y', group, group_all, spec, "unconditional_group_interact", regspec, "constant") detail(scalars)
		
	cap n reg `y' c.l1.`y'##b0.i.group_2012, cluster(id) noconstant
	
		if !_rc regsave using "$outdir/mean_reversion_2012_2014.dta", append autoid addlabel(depvar, `y', group, group_all, spec, "unconditional_group_interact", regspec, "noconstant") detail(scalars)		
	
	foreach v in majority_pff_2012 majority_ext_2012 {
		
		cap n reg `y' l1.`y' if `v' == 1, cluster(id)
	
			if !_rc regsave using "$outdir/mean_reversion_2012_2014.dta", append autoid addlabel(depvar, `y', group, group_all,  spec, "`v'", regspec, "constant") detail(scalars)			
			
		cap n reg `y' l1.`y' if `v' == 1, cluster(id) noconstant
	
			if !_rc regsave using "$outdir/mean_reversion_2012_2014.dta", append autoid addlabel(depvar, `y', group, group_all,  spec, "`v'", regspec, "noconstant") detail(scalars)				
		
	}
	
}

cap postclose mean_reversion_2012_2014

gcollapse (mean) participation_prominent porcentaje_pff porcentaje_ext porcentaje_nac, by(group_2012 anio_fiscal)

save "$outdir/mean_reversion_group_2012.dta", replace

/****************************************/
/* MEAN REVERSION EXPLORATION - GEO ALT */
/****************************************/

forv x = 1/3 { 
		
	use if inrange(anio_fiscal, 2012, 2014) using "$datadir/geo_alt_`x'_panel.dta", clear
		
	keep firm_id anio_fiscal group porcentaje_pff porcentaje_ext porcentaje_nac average_chain_length max_chain_length participation_prominent participation_inv_prominent aps

	gen majority_pff = porcentaje_pff >= 50 if missing(porcentaje_pff) == 0
	gen majority_ext = porcentaje_ext >= 50 if missing(porcentaje_ext) == 0
	gen majority_nac = porcentaje_nac >= 50 if missing(porcentaje_nac) == 0

	bys firm_id: gegen majority_pff_2012 = max(cond(anio_fiscal == 2012 & porcentaje_pff >= 50, 1, 0))
	bys firm_id: gegen majority_ext_2012 = max(cond(anio_fiscal == 2012 & porcentaje_ext >= 50, 1, 0))
	bys firm_id: gegen majority_nac_2012 = max(cond(anio_fiscal == 2012 & porcentaje_nac >= 50, 1, 0))

	gen group_2012 = 0 if majority_ext_2012 == 1 
		replace group_2012 = 1 if majority_pff_2012 == 1
		replace group_2012 = 2 if majority_nac_2012 == 1
		replace group_2012 = 3 if missing(group_2012)
		
	bys firm_id: gegen aps_count = count(cond(aps == 1, anio_fiscal, .))

	keep if aps_count == 3
	drop aps_count
	
	keep if inlist(group_2012, 0, 1)

	gegen id = group(firm_id)
	xtset id anio_fiscal

	cap postclose mean_reversion_geo_alt_`x'
	postfile mean_reversion_geo_alt_`x' str32(var) double(coef stderr N r2) using "$outdir/mean_reversion_geo_alt_`x'.dta", replace

	foreach y in porcentaje_pff porcentaje_ext participation_prominent participation_inv_prominent majority_pff majority_ext {
		
		cap n reg `y' l1.`y', cluster(id)
		
			if !_rc regsave using "$outdir/mean_reversion_geo_alt_`x'.dta", append autoid addlabel(depvar, `y', group, group_all, spec, "unconditional", regspec, "constant") detail(scalars)
			
		cap n reg `y' l1.`y', cluster(id) noconstant
		
			if !_rc regsave using "$outdir/mean_reversion_geo_alt_`x'.dta", append autoid addlabel(depvar, `y', group, group_all, spec, "unconditional", regspec, "noconstant") detail(scalars)	
		
		cap n reg `y' c.l1.`y'##b0.i.group_2012, cluster(id)
	
			if !_rc regsave using "$outdir/mean_reversion_geo_alt_`x'.dta", append autoid addlabel(depvar, `y', group, group_all, spec, "unconditional_group_interact", regspec, "constant") detail(scalars)
			
		cap n reg `y' c.l1.`y'##b0.i.group_2012, cluster(id) noconstant
		
			if !_rc regsave using "$outdir/mean_reversion_geo_alt_`x'.dta", append autoid addlabel(depvar, `y', group, group_all, spec, "unconditional_group_interact", regspec, "noconstant") detail(scalars)		
		
		foreach v in majority_pff_2012 majority_ext_2012 {
			
			cap n reg `y' l1.`y' if `v' == 1, cluster(id)
		
				if !_rc regsave using "$outdir/mean_reversion_geo_alt_`x'.dta", append autoid addlabel(depvar, `y', group, group_all,  spec, "`v'", regspec, "constant") detail(scalars)			
				
			cap n reg `y' l1.`y' if `v' == 1, cluster(id) noconstant
		
				if !_rc regsave using "$outdir/mean_reversion_geo_alt_`x'.dta", append autoid addlabel(depvar, `y', group, group_all,  spec, "`v'", regspec, "noconstant") detail(scalars)				
			
		}
		
	}

	cap postclose mean_reversion_geo_alt_`x'

	cap drop group_2012
	gen group_2012 = 0
	replace group_2012 = 1 if majority_nac_2012 == 1
	replace group_2012 = 2 if majority_ext_2012 == 1
	replace group_2012 = 3 if majority_pff_2012 == 1

	gcollapse (mean) participation_prominent porcentaje_pff porcentaje_ext porcentaje_nac, by(group_2012 anio_fiscal)

	save "$outdir/mean_reversion_group_2012_geo_alt_`x'.dta", replace	
		
}

/************************************/
/* MEAN REVERSION ECONOMETRIC MODEL */
/************************************/

use "$datadir/main_panel.dta", clear

gen post = anio_fiscal >= 2015

gen years_elapsed = anio_fiscal - 2014

gen l_participation_prominent = log(participation_prominent)
gen b_participation_prominent = participation_prominent > 0 if missing(participation_prominent) == 0

bys firm_id: gegen assets_2014 = total(cond(anio_fiscal == 2014, round(total_assets), .))
replace assets_2014 = round(assets_2014)

keep if missing(treatment_major) == 0
ren treatment_major treatment

cap postclose main_ownership_mean_reversion
postfile main_ownership_mean_reversion str32(var) double(coef stderr N r2) using "$outdir/main_ownership_mean_reversion.dta", replace

forv w = 1/2 {
	
	if `w' == 1 {
		
		loc weightspec = "u"
		loc weight = ""
		loc poisson_weight = ""
		
	}
	
	else if `w' == 2 {
		
		loc weightspec = "w"
		loc weight = "[aweight = assets_2014]"
		loc poisson_weight = "[fweight = assets_2014]"
		
	}
		
	//levels
	cap n reghdfe participation_prominent b0.i.treatment##b2014.i.anio_fiscal c.years_elapsed#post##b0.i.treatment `weight', cluster(firm_id) absorb(firm_id anio_fiscal)

		if !_rc regsave using "$outdir/main_ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, participation_prominent, spec, "levels", design, "event_study", weight, `weightspec') detail(scalars)
		
	cap n reghdfe participation_prominent b0.i.treatment##b0.i.post c.years_elapsed#post##b0.i.treatment `weight', cluster(firm_id) absorb(firm_id anio_fiscal)

		if !_rc regsave using "$outdir/main_ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, participation_prominent, spec, "levels", design, "dd", weight, `weightspec') detail(scalars)	

	//log
	cap n reghdfe l_participation_prominent b0.i.treatment##b2014.i.anio_fiscal c.years_elapsed#post##b0.i.treatment `weight', cluster(firm_id) absorb(firm_id anio_fiscal)

		if !_rc regsave using "$outdir/main_ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, participation_prominent, spec, "log", design, "event_study", weight, `weightspec') detail(scalars)
		
	cap n reghdfe l_participation_prominent b0.i.treatment##b0.i.post c.years_elapsed#post##b0.i.treatment `weight', cluster(firm_id) absorb(firm_id anio_fiscal)

		if !_rc regsave using "$outdir/main_ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, participation_prominent, spec, "log", design, "dd", weight, `weightspec') detail(scalars)	

	//poisson
	cap n ppmlhdfe participation_prominent b0.i.treatment##b2014.i.anio_fiscal c.years_elapsed#post##b0.i.treatment if participation_prominent >= 0 `poisson_weight', cluster(firm_id) absorb(firm_id anio_fiscal) maxiter(300)
		
		if !_rc regsave using "$outdir/main_ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, participation_prominent, spec, "poisson", design, "event_study", weight, `weightspec') detail(scalars)
		
	cap n ppmlhdfe participation_prominent b0.i.treatment##b0.i.post c.years_elapsed#post##b0.i.treatment if participation_prominent >= 0 `poisson_weight', cluster(firm_id) absorb(firm_id anio_fiscal) maxiter(300)

		if !_rc regsave using "$outdir/main_ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, participation_prominent, spec, "poisson", design, "dd", weight, `weightspec') detail(scalars)	

	//binary
	cap n reghdfe b_participation_prominent b0.i.treatment##b2014.i.anio_fiscal c.years_elapsed#post##b0.i.treatment `weight', cluster(firm_id) absorb(firm_id anio_fiscal)
		
		if !_rc regsave using "$outdir/main_ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, participation_prominent, spec, "binary", design, "event_study", weight, `weightspec') detail(scalars)
		
	cap n reghdfe b_participation_prominent b0.i.treatment##b0.i.post c.years_elapsed#post##b0.i.treatment `weight', cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/main_ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, participation_prominent, spec, "binary", design, "dd", weight, `weightspec') detail(scalars)		
		
}

cap postclose main_ownership_mean_reversion

/*****************************************/
/* MAIN OWNERSHIP RESULTS MEAN REVERSION */
/*****************************************/

use "$datadir/main_panel.dta", clear

keep if missing(treatment_major) == 0
ren treatment_major treatment

gen post = anio_fiscal >= 2015

gegen id = group(firm_id)
xtset id anio_fiscal

drop if anio_fiscal == 2012

///
//UNWEIGHTED
///

cap postclose ownership_mean_reversion
postfile ownership_mean_reversion str32(var) double(coef stderr N r2) using "$outdir/ownership_mean_reversion.dta", replace

// ds post firm_id anio_fiscal group_assign group treatment treatment_minor exposure prominent_2014 t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt prominent_2012_2014 porcion_comp_soc_no_inf_3576 porcion_comp_soc_si_inf_3578, not
// foreach y in `r(varlist)' {	
	
foreach y in participation_prominent {
	
	///
	//levels - event study
	///
	cap n reghdfe `y' b0.i.treatment##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels", design, "event_study") detail(scalars)
	
	cap n reghdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y', cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag", design, "event_study") detail(scalars)
	
	cap n reghdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y'##treatment, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag_dd", design, "event_study") detail(scalars)
	
	cap n reghdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y'#treatment, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag_d", design, "event_study") detail(scalars)
	
	cap n reghdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y'#b0.i.treatment#b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag_d_post", design, "event_study") detail(scalars)
		
	cap n reghdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y'##b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag_dd_post", design, "event_study") detail(scalars)
	
	///
	//levels - dd
	///
	cap n reghdfe `y' b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels", design, "dd") detail(scalars)	
		
	cap n reghdfe `y' b0.i.treatment##b0.i.post c.l1.`y', cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag", design, "dd") detail(scalars)	
	
	cap n reghdfe `y' b0.i.treatment##b0.i.post c.l1.`y'##b0.i.treatment, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag_dd", design, "dd") detail(scalars)	
	
	cap n reghdfe `y' b0.i.treatment##b0.i.post c.l1.`y'#b0.i.treatment, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag_d", design, "dd") detail(scalars)	
	
	cap n reghdfe `y' b0.i.treatment##b0.i.post c.l1.`y'#b0.i.treatment#b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag_d_post", design, "dd") detail(scalars)
		
	cap n reghdfe `y' b0.i.treatment##b0.i.post c.l1.`y'##b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag_dd_post", design, "dd") detail(scalars)

	//skipping if the variable is a binary variable
	qui sum `y'
	if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue

	cap gen l_`y' = log(`y')
	cap gen b_`y' = `y' > 0 if missing(`y') == 0
	
	///
	//log - event study
	///
	cap n reghdfe l_`y' b0.i.treatment##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log", design, "event_study") detail(scalars)
	
	cap n reghdfe l_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.l_`y', cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag", design, "event_study") detail(scalars)
	
	cap n reghdfe l_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.l_`y'##treatment, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag_dd", design, "event_study") detail(scalars)
	
	cap n reghdfe l_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.l_`y'#treatment, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag_d", design, "event_study") detail(scalars)
	
	cap n reghdfe l_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.l_`y'#b0.i.treatment#b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag_d_post", design, "event_study") detail(scalars)
		
	cap n reghdfe l_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.l_`y'##b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag_dd_post", design, "event_study") detail(scalars)
	
	///
	//log - dd
	///
	cap n reghdfe l_`y' b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log", design, "dd") detail(scalars)	
		
	cap n reghdfe l_`y' b0.i.treatment##b0.i.post c.l1.l_`y', cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag", design, "dd") detail(scalars)	
	
	cap n reghdfe l_`y' b0.i.treatment##b0.i.post c.l1.l_`y'##b0.i.treatment, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag_dd", design, "dd") detail(scalars)	
	
	cap n reghdfe l_`y' b0.i.treatment##b0.i.post c.l1.l_`y'#b0.i.treatment, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag_d", design, "dd") detail(scalars)	
	
	cap n reghdfe l_`y' b0.i.treatment##b0.i.post c.l1.l_`y'#b0.i.treatment#b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag_d_post", design, "dd") detail(scalars)	
		
	cap n reghdfe l_`y' b0.i.treatment##b0.i.post c.l1.l_`y'##b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag_dd_post", design, "dd") detail(scalars)	
		
	///
	//poisson - event study
	///
	cap n ppmlhdfe `y' b0.i.treatment##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
	
	cap n ppmlhdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y' if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag", design, "event_study") detail(scalars)
	
	cap n ppmlhdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y'##treatment if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag_dd", design, "event_study") detail(scalars)
	
	cap n ppmlhdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y'#treatment if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag_d", design, "event_study") detail(scalars)
	
	cap n ppmlhdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y'#b0.i.treatment#b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag_d_post", design, "event_study") detail(scalars)
	
	cap n ppmlhdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y'##b0.i.treatment##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag_dd_post", design, "event_study") detail(scalars)
	
	///
	//poisson - dd
	///
	cap n ppmlhdfe `y' b0.i.treatment##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson", design, "dd") detail(scalars)	
		
	cap n ppmlhdfe `y' b0.i.treatment##b0.i.post c.l1.`y' if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag", design, "dd") detail(scalars)	
	
	cap n ppmlhdfe `y' b0.i.treatment##b0.i.post c.l1.`y'##b0.i.treatment if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag_dd", design, "dd") detail(scalars)	
	
	cap n ppmlhdfe `y' b0.i.treatment##b0.i.post c.l1.`y'#b0.i.treatment if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag_d", design, "dd") detail(scalars)	
	
	cap n ppmlhdfe `y' b0.i.treatment##b0.i.post c.l1.`y'#b0.i.treatment#b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag_d_post", design, "dd") detail(scalars)		
	
	cap n ppmlhdfe `y' b0.i.treatment##b0.i.post c.l1.`y'##b0.i.treatment##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag_dd_post", design, "dd") detail(scalars)		
	
	if strpos("`y'", "_rr") != 0 continue 
	
	///
	//binary - event study
	///
	cap n reghdfe b_`y' b0.i.treatment##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary", design, "event_study") detail(scalars)
	
	cap n reghdfe b_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.b_`y', cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag", design, "event_study") detail(scalars)
	
	cap n reghdfe b_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.b_`y'##treatment, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag_dd", design, "event_study") detail(scalars)
	
	cap n reghdfe b_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.b_`y'#treatment, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag_d", design, "event_study") detail(scalars)
	
	cap n reghdfe b_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.b_`y'#b0.i.treatment#b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag_d_post", design, "event_study") detail(scalars)
		
	cap n reghdfe b_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.b_`y'##b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag_dd_post", design, "event_study") detail(scalars)
	
	///
	//binary - dd
	///
	cap n reghdfe b_`y' b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary", design, "dd") detail(scalars)	
		
	cap n reghdfe b_`y' b0.i.treatment##b0.i.post c.l1.b_`y', cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag", design, "dd") detail(scalars)	
	
	cap n reghdfe b_`y' b0.i.treatment##b0.i.post c.l1.b_`y'##b0.i.treatment, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag_dd", design, "dd") detail(scalars)	
	
	cap n reghdfe b_`y' b0.i.treatment##b0.i.post c.l1.b_`y'#b0.i.treatment, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag_d", design, "dd") detail(scalars)	
	
	cap n reghdfe b_`y' b0.i.treatment##b0.i.post c.l1.b_`y'#b0.i.treatment#b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag_d_post", design, "dd") detail(scalars)
		
	cap n reghdfe b_`y' b0.i.treatment##b0.i.post c.l1.b_`y'##b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag_dd_post", design, "dd") detail(scalars)
	
}

cap postclose ownership_mean_reversion

///
//WEIGHTED
///

use "$datadir/main_panel.dta", clear

bys firm_id: gegen assets_2014 = total(cond(anio_fiscal == 2014, round(total_assets), .))
replace assets_2014 = round(assets_2014)

keep if missing(treatment_major) == 0
ren treatment_major treatment

gen post = anio_fiscal >= 2015

gegen id = group(firm_id)
xtset id anio_fiscal

drop if anio_fiscal == 2012

cap postclose ownership_mean_reversion_w
postfile ownership_mean_reversion_w str32(var) double(coef stderr N r2) using "$outdir/ownership_mean_reversion_w.dta", replace

// ds post firm_id anio_fiscal group_assign group treatment treatment_minor exposure prominent_2014 t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt prominent_2012_2014 porcion_comp_soc_no_inf_3576 porcion_comp_soc_si_inf_3578 assets_2014, not
// foreach y in `r(varlist)' { 
		
	//only running on winsorized variables when applicable	
	//cap confirm variable `y'_w
	//if !_rc continue

foreach y in participation_prominent {
	
	///
	//levels - event study
	///
	cap n reghdfe `y' b0.i.treatment##b2014.i.anio_fiscal [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels", design, "event_study") detail(scalars)
	
	cap n reghdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y' [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag", design, "event_study") detail(scalars)
	
	cap n reghdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y'##treatment [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag_dd", design, "event_study") detail(scalars)
	
	cap n reghdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y'#treatment [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag_d", design, "event_study") detail(scalars)
		
	cap n reghdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y'#b0.i.treatment#b0.i.post [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag_d_post", design, "event_study") detail(scalars)
		
	cap n reghdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y'##b0.i.treatment##b0.i.post [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag_dd_post", design, "event_study") detail(scalars)
	
	///
	//levels - dd
	///
	cap n reghdfe `y' b0.i.treatment##b0.i.post [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels", design, "dd") detail(scalars)	
		
	cap n reghdfe `y' b0.i.treatment##b0.i.post c.l1.`y' [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag", design, "dd") detail(scalars)	
	
	cap n reghdfe `y' b0.i.treatment##b0.i.post c.l1.`y'##b0.i.treatment [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag_dd", design, "dd") detail(scalars)	
	
	cap n reghdfe `y' b0.i.treatment##b0.i.post c.l1.`y'#b0.i.treatment [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag_d", design, "dd") detail(scalars)	
		
	cap n reghdfe `y' b0.i.treatment##b0.i.post c.l1.`y'#b0.i.treatment#b0.i.post [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag_d_post", design, "dd") detail(scalars)
		
	cap n reghdfe `y' b0.i.treatment##b0.i.post c.l1.`y'##b0.i.treatment##b0.i.post [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "levels_lag_dd_post", design, "dd") detail(scalars)

	//skipping if the variable is a binary variable
	qui sum `y'
	if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue

	cap gen l_`y' = log(`y')
	cap gen b_`y' = `y' > 0 if missing(`y') == 0
	
	///
	//log - event study
	///
	cap n reghdfe l_`y' b0.i.treatment##b2014.i.anio_fiscal [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log", design, "event_study") detail(scalars)
	
	cap n reghdfe l_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.l_`y' [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag", design, "event_study") detail(scalars)
	
	cap n reghdfe l_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.l_`y'##treatment [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag_dd", design, "event_study") detail(scalars)
	
	cap n reghdfe l_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.l_`y'#treatment [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag_d", design, "event_study") detail(scalars)
		
	cap n reghdfe l_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.l_`y'#b0.i.treatment#b0.i.post [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag_d_post", design, "event_study") detail(scalars)
		
	cap n reghdfe l_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.l_`y'##b0.i.treatment##b0.i.post [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag_dd_post", design, "event_study") detail(scalars)
	
	///
	//log - dd
	///
	cap n reghdfe l_`y' b0.i.treatment##b0.i.post [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log", design, "dd") detail(scalars)	
		
	cap n reghdfe l_`y' b0.i.treatment##b0.i.post c.l1.l_`y' [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag", design, "dd") detail(scalars)	
	
	cap n reghdfe l_`y' b0.i.treatment##b0.i.post c.l1.l_`y'##b0.i.treatment [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag_dd", design, "dd") detail(scalars)	
	
	cap n reghdfe l_`y' b0.i.treatment##b0.i.post c.l1.l_`y'#b0.i.treatment [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag_d", design, "dd") detail(scalars)	
		
	cap n reghdfe l_`y' b0.i.treatment##b0.i.post c.l1.l_`y'#b0.i.treatment#b0.i.post [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag_d_post", design, "dd") detail(scalars)
		
	cap n reghdfe l_`y' b0.i.treatment##b0.i.post c.l1.l_`y'##b0.i.treatment##b0.i.post [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "log_lag_dd_post", design, "dd") detail(scalars)	
		
	///
	//poisson - event study
	///
	cap n ppmlhdfe `y' b0.i.treatment##b2014.i.anio_fiscal if `y' >= 0 [fweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
	
	cap n ppmlhdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y' if `y' >= 0 [fweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag", design, "event_study") detail(scalars)
	
	cap n ppmlhdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y'##treatment if `y' >= 0 [fweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag_dd", design, "event_study") detail(scalars)
		
	cap n ppmlhdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y'#treatment if `y' >= 0 [fweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag_d", design, "event_study") detail(scalars)
		
	cap n ppmlhdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y'#b0.i.treatment#b0.i.post if `y' >= 0 [fweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag_d_post", design, "event_study") detail(scalars)
		
	cap n ppmlhdfe `y' b0.i.treatment##b2014.i.anio_fiscal c.l1.`y'##b0.i.treatment##b0.i.post if `y' >= 0 [fweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag_dd_post", design, "event_study") detail(scalars)
	
	///
	//poisson - dd
	///
	cap n ppmlhdfe `y' b0.i.treatment##b0.i.post if `y' >= 0 [fweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson", design, "dd") detail(scalars)	
		
	cap n ppmlhdfe `y' b0.i.treatment##b0.i.post c.l1.`y' if `y' >= 0 [fweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag", design, "dd") detail(scalars)	
	
	cap n ppmlhdfe `y' b0.i.treatment##b0.i.post c.l1.`y'##b0.i.treatment if `y' >= 0 [fweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag_dd", design, "dd") detail(scalars)	
	
	cap n ppmlhdfe `y' b0.i.treatment##b0.i.post c.l1.`y'#b0.i.treatment if `y' >= 0 [fweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag_d", design, "dd") detail(scalars)	
		
	cap n ppmlhdfe `y' b0.i.treatment##b0.i.post c.l1.`y'#b0.i.treatment#b0.i.post if `y' >= 0 [fweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag_d_post", design, "dd") detail(scalars)
		
	cap n ppmlhdfe `y' b0.i.treatment##b0.i.post c.l1.`y'##b0.i.treatment##b0.i.post if `y' >= 0 [fweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "poisson_lag_dd_post", design, "dd") detail(scalars)		
	
	if strpos("`y'", "_rr") != 0 continue 
	
	///
	//binary - event study
	///
	cap n reghdfe b_`y' b0.i.treatment##b2014.i.anio_fiscal [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary", design, "event_study") detail(scalars)
	
	cap n reghdfe b_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.b_`y' [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag", design, "event_study") detail(scalars)
	
	cap n reghdfe b_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.b_`y'##treatment [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag_dd", design, "event_study") detail(scalars)
		
	cap n reghdfe b_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.b_`y'#treatment [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag_d", design, "event_study") detail(scalars)
		
	cap n reghdfe b_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.b_`y'#b0.i.treatment#b0.i.post [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag_d_post", design, "event_study") detail(scalars)
		
	cap n reghdfe b_`y' b0.i.treatment##b2014.i.anio_fiscal c.l1.b_`y'##b0.i.treatment##b0.i.post [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag_dd_post", design, "event_study") detail(scalars)
	
	///
	//binary - dd
	///
	cap n reghdfe b_`y' b0.i.treatment##b0.i.post [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary", design, "dd") detail(scalars)	
		
	cap n reghdfe b_`y' b0.i.treatment##b0.i.post c.l1.b_`y' [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag", design, "dd") detail(scalars)	
	
	cap n reghdfe b_`y' b0.i.treatment##b0.i.post c.l1.b_`y'##b0.i.treatment [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag_dd", design, "dd") detail(scalars)	
	
	cap n reghdfe b_`y' b0.i.treatment##b0.i.post c.l1.b_`y'#b0.i.treatment [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag_d", design, "dd") detail(scalars)	
		
	cap n reghdfe b_`y' b0.i.treatment##b0.i.post c.l1.b_`y'#b0.i.treatment#b0.i.post [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag_d_post", design, "dd") detail(scalars)
		
	cap n reghdfe b_`y' b0.i.treatment##b0.i.post c.l1.b_`y'##b0.i.treatment##b0.i.post [aweight = assets_2014], cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/ownership_mean_reversion_w.dta", append autoid addlabel(indepvar, "treatment_major", depvar, `y', spec, "binary_lag_dd_post", design, "dd") detail(scalars)
	
}

cap postclose ownership_mean_reversion_w

/**************/
/* ALT DESIGN */
/**************/

forv x = 2012/2013 {

	loc x1 = `x' + 1

	//2012-2013
	use if inrange(anio_fiscal, `x', `x1') using "$datadir/core_panel.dta", clear

	bys firm_id: gegen pff_pre = mean(cond(anio_fiscal == `x', porcentaje_pff, .))
	bys firm_id: gegen ext_pre = mean(cond(anio_fiscal == `x', porcentaje_ext, .))

	cap drop treatment
	gen treatment = 1 if pff_pre >= 50 & missing(pff_pre) == 0
		replace treatment = 0 if ext_pre >= 50 & pff_pre < 5 & missing(pff_pre) == 0 & missing(ext_pre) == 0
	
	keep if missing(treatment) == 0
	
	gen t = anio_fiscal - `x' + 1
	
	gen cohort = `x'
	
	keep firm_id anio_fiscal participation_prominent cohort t treatment
	
	gegen id = group(firm_id)
	
	tempfile t`x'
	save `t`x'', replace
	
}

clear 

forv x = 2012/2013 {
	
	append using `t`x''	
	
}	
	
sum id if cohort == 2012
replace id = r(max) + id if cohort == 2013

cap gen l_participation_prominent = log(participation_prominent)
cap gen b_participation_prominent = participation_prominent > 0 if missing(participation_prominent) == 0

xtset id t

//regressions
cap postclose mean_reversion_test
postfile mean_reversion_test str32(var) double(coef stderr N r2) using "$outdir/mean_reversion_test.dta", replace

forv c = 1/2 {
	
	if `c' == 1 {
		
		loc constant_spec = "constant"
		loc constant = ""
		
	}
	
	else if `c' == 2 {
		
		loc constant_spec = "noconstant"
		loc constant = "noconstant"
		
	}

	///
	//LEVELS
	///
	cap n reghdfe participation_prominent c.l1.participation_prominent##treatment, `constant' cluster(id) 

		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "levels", cluster_spec, "id", absorb_spec, "noabsorb", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe participation_prominent c.l1.participation_prominent##treatment, `constant' cluster(firm_id)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "levels", cluster_spec, "firm_id", absorb_spec, "noabsorb", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe participation_prominent c.l1.participation_prominent##treatment, `constant' cluster(firm_id) absorb(firm_id)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "levels", cluster_spec, "firm_id", absorb_spec, "firm_id", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe participation_prominent c.l1.participation_prominent##treatment, `constant' cluster(id) absorb(anio_fiscal)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "levels", cluster_spec, "id", absorb_spec, "anio_fiscal", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe participation_prominent c.l1.participation_prominent##treatment, `constant' cluster(firm_id) absorb(anio_fiscal)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "levels", cluster_spec, "firm_id", absorb_spec, "anio_fiscal", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe participation_prominent c.l1.participation_prominent##treatment, `constant' cluster(id) absorb(firm_id anio_fiscal)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "levels", cluster_spec, "id", absorb_spec, "twfe", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe participation_prominent c.l1.participation_prominent##treatment, `constant' cluster(firm_id) absorb(firm_id anio_fiscal)

		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "levels", cluster_spec, "firm_id", absorb_spec, "twfe", constant_spec, "`constant_spec'") detail(scalars)
		
	///
	//LOG
	///
	cap n reghdfe l_participation_prominent c.l1.l_participation_prominent##treatment, `constant' cluster(id)

		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "log", cluster_spec, "id", absorb_spec, "noabsorb", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe l_participation_prominent c.l1.l_participation_prominent##treatment, `constant' cluster(firm_id)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "log", cluster_spec, "firm_id", absorb_spec, "noabsorb", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe l_participation_prominent c.l1.l_participation_prominent##treatment, `constant' cluster(firm_id) absorb(firm_id)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "log", cluster_spec, "firm_id", absorb_spec, "firm_id", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe l_participation_prominent c.l1.l_participation_prominent##treatment, `constant' cluster(id) absorb(anio_fiscal)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "log", cluster_spec, "id", absorb_spec, "anio_fiscal", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe l_participation_prominent c.l1.l_participation_prominent##treatment, `constant' cluster(firm_id) absorb(anio_fiscal)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "log", cluster_spec, "firm_id", absorb_spec, "anio_fiscal", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe l_participation_prominent c.l1.l_participation_prominent##treatment, `constant' cluster(id) absorb(firm_id anio_fiscal)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "log", cluster_spec, "id", absorb_spec, "twfe", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe l_participation_prominent c.l1.l_participation_prominent##treatment, `constant' cluster(firm_id) absorb(firm_id anio_fiscal)

		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "log", cluster_spec, "firm_id", absorb_spec, "twfe", constant_spec, "`constant_spec'") detail(scalars)
		
	///
	//POISSON
	///
	cap n ppmlhdfe participation_prominent c.l1.participation_prominent##treatment, `constant' cluster(id)

		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "poisson", cluster_spec, "id", absorb_spec, "noabsorb", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n ppmlhdfe participation_prominent c.l1.participation_prominent##treatment, `constant' cluster(firm_id)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "poisson", cluster_spec, "firm_id", absorb_spec, "noabsorb", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n ppmlhdfe participation_prominent c.l1.participation_prominent##treatment, `constant' cluster(firm_id) absorb(firm_id)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "poisson", cluster_spec, "firm_id", absorb_spec, "firm_id", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n ppmlhdfe participation_prominent c.l1.participation_prominent##treatment, `constant' cluster(id) absorb(anio_fiscal)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "poisson", cluster_spec, "id", absorb_spec, "anio_fiscal", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n ppmlhdfe participation_prominent c.l1.participation_prominent##treatment, `constant' cluster(firm_id) absorb(anio_fiscal)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "poisson", cluster_spec, "firm_id", absorb_spec, "anio_fiscal", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n ppmlhdfe participation_prominent c.l1.participation_prominent##treatment, `constant' cluster(id) absorb(firm_id anio_fiscal)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "poisson", cluster_spec, "id", absorb_spec, "twfe", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n ppmlhdfe participation_prominent c.l1.participation_prominent##treatment, `constant' cluster(firm_id) absorb(firm_id anio_fiscal)

		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "poisson", cluster_spec, "firm_id", absorb_spec, "twfe", constant_spec, "`constant_spec'") detail(scalars)
		
	///
	//BINARY
	///
	cap n reghdfe b_participation_prominent c.l1.b_participation_prominent##treatment, `constant' cluster(id)

		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "binary", cluster_spec, "id", absorb_spec, "noabsorb", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe b_participation_prominent c.l1.b_participation_prominent##treatment, `constant' cluster(firm_id)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "binary", cluster_spec, "firm_id", absorb_spec, "noabsorb", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe b_participation_prominent c.l1.b_participation_prominent##treatment, `constant' cluster(firm_id) absorb(firm_id)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "binary", cluster_spec, "firm_id", absorb_spec, "firm_id", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe b_participation_prominent c.l1.b_participation_prominent##treatment, `constant' cluster(id) absorb(anio_fiscal)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "binary", cluster_spec, "id", absorb_spec, "anio_fiscal", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe b_participation_prominent c.l1.b_participation_prominent##treatment, `constant' cluster(firm_id) absorb(anio_fiscal)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "binary", cluster_spec, "firm_id", absorb_spec, "anio_fiscal", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe b_participation_prominent c.l1.b_participation_prominent##treatment, `constant' cluster(id) absorb(firm_id anio_fiscal)
		
		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "binary", cluster_spec, "id", absorb_spec, "twfe", constant_spec, "`constant_spec'") detail(scalars)
		
	cap n reghdfe b_participation_prominent c.l1.b_participation_prominent##treatment, `constant' cluster(firm_id) absorb(firm_id anio_fiscal)

		if !_rc regsave using "$outdir/mean_reversion_test.dta", append autoid addlabel(depvar, participation_prominent, depvar_spec, "binary", cluster_spec, "firm_id", absorb_spec, "twfe", constant_spec, "`constant_spec'") detail(scalars)	

	cap postclose mean_reversion_test

}
*/

/******************************/
/* MEAN REVERSION FOR CONTROL */
/******************************/

use "$datadir/core_panel.dta", clear

forv x = 2012/2019 {
	
	cap drop ext_`x' 
	cap drop pff_`x' 
	cap drop assets_`x'
	
	bys firm_id: gegen ext_`x' = mean(cond(anio_fiscal == `x', porcentaje_ext, .))
	bys firm_id: gegen pff_`x' = mean(cond(anio_fiscal == `x', porcentaje_pff, .))
	
	bys firm_id: gegen assets_`x' = mean(cond(anio_fiscal == `x', total_assets, .))
		
}

forv x = 2012/2019 {
	
	preserve
	
		keep if ext_`x' >= 50 & pff_`x' < 5
			
		gcollapse (mean) porcentaje_pff porcentaje_ext porcentaje_nac, by(anio_fiscal) 
		
			gen group = "`x'_unweighted"
		
			tempfile ext_`x'_unweighted
			save `ext_`x'_unweighted', replace
			
	restore
	
	preserve
	
		keep if ext_`x' >= 50 & pff_`x' < 5
			
		gcollapse (mean) porcentaje_pff porcentaje_ext porcentaje_nac [aweight = assets_`x'], by(anio_fiscal) 
		
			gen group = "`x'_weighted"
			
			tempfile ext_`x'_weighted
			save `ext_`x'_weighted', replace

	restore
	
}

clear

forv x = 2012/2019 {

	append using `ext_`x'_unweighted'
	append using `ext_`x'_weighted'
	
}	

save "$outdir/mean_reversion_control.dta", replace

/*************************************************/
/* MAINTAINING TERMINAL AND BENEFICIAL OWNERSHIP */
/*************************************************/

use "$datadir/main_panel.dta", clear

bys firm_id: gegen bo_2014_100 = max(cond(anio_fiscal == 2014 & (bf_persona == 100 | bf_persona_100 == 1), 1, 0))

///
//1. tabulate plurality owner over groups and years if bo_2014 == 100
///

preserve

	cap drop count
	gen count = 1
	
	gcollapse (sum) count (mean) has_maingroup_shareholder_2014 has_maingroup_plur_sh_2014, by(group anio_fiscal bo_2014_100)

	save "$outdir/ownership_changes_bo_2014_100.dta", replace
	
restore

///
//2a. among firms with good BO in 2014, condition on changing (no 2014 plurality owner), do they do worse reporting or is a new person the BO?
///

preserve

	cap drop count
	gen count = 1
	
	gcollapse (sum) count (mean) bf_persona bf_persona_100 any_bf_persona, by(group anio_fiscal bo_2014_100 has_maingroup_plur_sh_2014)

	save "$outdir/bo_changes_by_ownership_changes_bo_2014_100_a.dta", replace
	
restore

///
//2b. among firms with good BO in 2014, condition on changing (no 2014 plurality owner), do they do worse reporting or is a new person the BO?
///

preserve

	cap drop count
	gen count = 1
	
	gcollapse (sum) count (mean) bf_persona bf_persona_100 any_bf_persona, by(group anio_fiscal bo_2014_100 has_maingroup_shareholder_2014)

	save "$outdir/bo_changes_by_ownership_changes_bo_2014_100_b.dta", replace
	
restore

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

di "file mean_reversion has terminated successfully"

cap log close
clear
