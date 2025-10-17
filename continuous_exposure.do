cap clear all
set more off
cap log close
set varabbrev off

loc extract_date = "20251017"

/***********/
/* HISTORY */
/***********/
	
//20250606: continous exposure skeleton

//20250610: developing build
	
//20250618: added on t-minor versus c-major 
	
//20250723: adding on a discrete minors spec	
	
//20250729: adding on two base 2014 specs	
	
//20250731: adding in alternate continuous exposure measure	

//20250810: adding on a binary X consistent spec	
	
/*********/
/* NOTES */
/*********/

//spec 1: continuous exposure reghdfe prominent c.exposure##b2014.i.year if inlist(group, 2, 3, 4, 5), cluster(firm_id) absorb(firm_id anio_fiscal)
	//c.exposure is the predicted tax exposure

//spec 2: continuous exposure among tmaj and tmin reghdfe prominent c.exposure##b2014.i.year if inlist(group, 4, 5), cluster(firm_id) absorb(firm_id anio_fiscal)
	//c.exposure is the predicted tax exposure

//spec 3: continuous exposure among tmin and cmin reghdfe prominent c.exposure##b2014.i.year if inlist(group, 3, 5), cluster(firm_id) absorb(firm_id anio_fiscal)
	//c.exposure is the predicted tax exposure

//spec 4: continous exposure among tmin reghdfe prominent c.exposure##b2014.i.year if inlist(group, 5), cluster(firm_id) absorb(firm_id anio_fiscal)
	
//spec 5: triple difference: c.prominent_2014##b2.i.group##b2014.i.year, cluster(firm_id) absorb(firm_id anio_fiscal)
	//NOT DOING THIS SPEC
	
//spec 6: continuous exposure: c-maj versus t-min
	//c.exposure##b2014.i.year if inlist(group, 3, 5), cluster(firm_id) absorb(firm_id anio_fiscal)

//spec 7: binary exposure: c-maj versus t-min
	//b2.i.group##b2014.i.year if inlist(group, 2, 5), cluster(firm_id) absorb(firm_id anio_fiscal)
	
//the proper comparisons are (3) and (1)	
	
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

//log using "$logdir/continuous_exposure_results_`today'.smcl", replace

loc time0 = "$S_TIME"
loc date0 = "$S_DATE"

di "started: `time0' `date0'"

timer clear
timer on 1 

//sca local_environment = 1
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

log using "$logdir/continuous_exposure_`today'.smcl", replace

loc time0 = "$S_TIME"
loc date0 = "$S_DATE"

di "started: `time0' `date0'"

timer clear
timer on 1  

/*******************************************/
/* CONTINUOUS + MINORITY OWNERSHIP RESULTS */
/*******************************************/

use "$datadir/main_panel.dta", replace

keep firm_id anio_fiscal group exposure prominent_2014 aps f101 active aps_f101 aps_f101_active porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais aps_residual_pais_other average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_conc terminal_owners_10 terminal_owners participation_prominent participation_prominent_0 participation_inv_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_100_pff intermediate_pff_max intermediate_50_prominent intermediate_100_ext intermediate_100_prominent intermediate_inv_prominent intermediate_10_inv_prominent intermediate_50_inv_prominent intermediate_100_inv_prominent empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt bf_persona_r persona_prominent bf_persona_100_r any_bf_persona_r bf_empresa_r complete_r inconsistent_r aps_residual_0_r percent_declarado_r persona_prominent_r incomplete_r aps_residual_r cit_liability gross_profit taxable_profits cit_liability uti_reinvertir_cpz_3580_w taxable_profits_w gross_profit_w cit_liability_w tasa_ir tasa_ir_w porcion_comp_soc_si_inf_3578

bys firm_id: gegen b_cit_liability_2014 = max(cond(anio_fiscal == 2014 & missing(cit_liability) == 0, (cit_liability > 0), .))

bys firm_id: gegen consistent_count_2015_2017 = total(cond(inrange(anio_fiscal, 2015, 2017) & round(porcentaje_pff - porcion_comp_soc_si_inf_3578, 1) == 0, 1, 0))
gen consistent_2015_2017 = consistent_count_2015_2017 == 3

gen exposure_cit = exposure * b_cit_liability_2014
gen exposure_consistent = exposure * consistent_2015_2017
gen exposure_cit_consistent = exposure * b_cit_liability_2014 * consistent_2015_2017
gen exposure_consistent_missing = exposure if consistent_2015_2017 == 1
gen exposure_cit_consistent_missing = exposure * b_cit_liability_2014 if consistent_2015_2017 == 1

cap drop treatment
gen treatment = 1 if inlist(group, 4, 5)
	replace treatment = 0 if inlist(group, 2, 3)
	
gen treatment_cit = treatment * b_cit_liability_2014
gen treatment_consistent = treatment * consistent_2015_2017
gen treatment_cit_consistent = treatment * b_cit_liability_2014 * consistent_2015_2017
gen treatment_consistent_missing = treatment if consistent_2015_2017 == 1
gen treatment_cit_consistent_missing = treatment * b_cit_liability_2014 if consistent_2015_2017 == 1

gen post = anio_fiscal >= 2015

compress

/*
/////
///
//VERSION 0: BINARY X CONSISTENT
///
/////

cap postclose binary_exposure_consistent
postfile binary_exposure_consistent str32(var) double(coef stderr N r2) using "$outdir/binary_exposure_consistent.dta", replace

forv x = 1/3 {
	
	preserve
	
		if `x' == 1 {
			
			loc samplespec = "majors"
			keep if inlist(group, 2, 4)
			
		}
		
		else if `x' == 2 {
			
			loc samplespec = "minors"
			keep if inlist(group, 3, 5)
			
		}
		
		else if `x' == 3 {
			
			loc samplespec = "all"
			keep if inlist(group, 2, 3, 4, 5)
			
		}
	
		foreach v in treatment treatment_cit treatment_consistent treatment_cit_consistent treatment_consistent_missing treatment_cit_consistent_missing {
				
			foreach y in participation_prominent porcentaje_pff gross_profit_w cit_liability_w bf_persona {
				
			//levels
			cap n reghdfe `y' `v'##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
				if !_rc regsave using "$outdir/binary_exposure_consistent.dta", append autoid addlabel(indepvar, `v', depvar, `y', spec, "levels", design, "event_study", samplespec, "`samplespec'") detail(scalars)
				
			cap n reghdfe `y' `v'##b0.i.post, cluster(firm_id) absorb(firm_id)
			
				if !_rc regsave using "$outdir/binary_exposure_consistent.dta", append autoid addlabel(indepvar, `v', depvar, `y', spec, "levels", design, "dd", samplespec, "`samplespec'") detail(scalars)	
			
			//skipping if the variable is a binary variable
			qui sum `y'
			if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue
			
			cap gen l_`y' = log(`y')
			cap gen b_`y' = `y' > 0 if missing(`y') == 0
			
			//log
			cap n reghdfe l_`y' `v'##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
				if !_rc regsave using "$outdir/binary_exposure_consistent.dta", append autoid addlabel(indepvar, `v', depvar, `y', spec, "log", design, "event_study", samplespec, "`samplespec'") detail(scalars)
				
			cap n reghdfe l_`y' `v'##b0.i.post, cluster(firm_id) absorb(firm_id)
			
				if !_rc regsave using "$outdir/binary_exposure_consistent.dta", append autoid addlabel(indepvar, `v', depvar, `y', spec, "log", design, "dd", samplespec, "`samplespec'") detail(scalars)	
				
			//poisson
			cap n ppmlhdfe `y' `v'##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
				
				if !_rc regsave using "$outdir/binary_exposure_consistent.dta", append autoid addlabel(indepvar, `v', depvar, `y', spec, "poisson", design, "event_study", samplespec, "`samplespec'") detail(scalars)
				
			cap n ppmlhdfe `y' `v'##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id)
			
				if !_rc regsave using "$outdir/binary_exposure_consistent.dta", append autoid addlabel(indepvar, `v', depvar, `y', spec, "poisson", design, "dd", samplespec, "`samplespec'") detail(scalars)	
				
			//binary
			cap n reghdfe b_`y' `v'##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
				
				if !_rc regsave using "$outdir/binary_exposure_consistent.dta", append autoid addlabel(indepvar, `v', depvar, `y', spec, "binary", design, "event_study", samplespec, "`samplespec'") detail(scalars)
				
			cap n reghdfe b_`y' `v'##b0.i.post, cluster(firm_id) absorb(firm_id)
			
				if !_rc regsave using "$outdir/binary_exposure_consistent.dta", append autoid addlabel(indepvar, `v', depvar, `y', spec, "binary", design, "dd", samplespec, "`samplespec'") detail(scalars)	
			
			
			//closing dependent variable loop
			}
			
		//closing independent variable loops	
		}
		
	restore
	
}

cap postclose binary_exposure_consistent
*/

/////
///
//VERSION 1: DD ON EXPOSURE, ALL FIRMS
///
/////

cap postclose continuous_exposure
postfile continuous_exposure str32(var) double(coef stderr N r2) using "$outdir/continuous_exposure.dta", replace

forv x = 1/2 {
	
	preserve
	
		if `x' == 1 {
			
			loc samplespec = "minors"
			keep if inlist(group, 3, 5)
			
		}
		
		else if `x' == 2 {
			
			loc samplespec = "all"
			keep if inlist(group, 2, 3, 4, 5)
			
		}
		
		// foreach y in aps f101 active aps_f101 aps_f101_active porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais aps_residual_pais_other average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_conc terminal_owners_10 terminal_owners participation_prominent participation_prominent_0 participation_inv_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_100_pff intermediate_pff_max intermediate_50_prominent intermediate_100_ext intermediate_100_prominent intermediate_inv_prominent intermediate_10_inv_prominent intermediate_50_inv_prominent intermediate_100_inv_prominent empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt bf_persona_r persona_prominent bf_persona_100_r any_bf_persona_r bf_empresa_r complete_r inconsistent_r aps_residual_0_r percent_declarado_r persona_prominent_r incomplete_r aps_residual_r cit_liability gross_profit taxable_profits cit_liability uti_reinvertir_cpz_3580_w taxable_profits_w gross_profit_w cit_liability_w tasa_ir tasa_ir_w {
			
		foreach v in "c.exposure_consistent" "c.exposure" /*"c.exposure##b0.i.b_cit_liability_2014" "c.exposure##b0.i.consistent_2015_2017" "c.exposure##b0.i.b_cit_liability_2014##b0.i.consistent_2015_2017"*/ {
			
			if "`v'" == "c.exposure" loc d = "c.exposure"
			else if "`v'" == "c.exposure_consistent" loc d = "c.exposure_consistent"
			else if "`v'" == "c.exposure##b0.i.b_cit_liability_2014" loc d = "c.exposure#1.b_cit_liability_2014"
			else if "`v'" == "c.exposure##b0.i.consistent_2015_2017" loc d = "c.exposure#1.consistent_2015_2017"
			else if "`v'" == "c.exposure##b0.i.b_cit_liability_2014##b0.i.consistent_2015_2017" loc d = "c.exposure#1.b_cit_liability_2014#1.consistent_2015_2017"
			
			foreach y in participation_prominent gross_profit_w cit_liability_w bf_persona return_on_assets_w return_on_assets_w_alt {
				
			//levels
			cap n reghdfe `y' `v'##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
				if !_rc regsave using "$outdir/continuous_exposure.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "levels", design, "event_study", samplespec, "`samplespec'") detail(scalars)
				
			cap n reghdfe `y' `v'##b0.i.post, cluster(firm_id) absorb(firm_id)
			
				if !_rc {
				
					lincom 3*`d'#1.post
					loc majority_effect = r(estimate)
					loc majority_effect_se = r(se)
					
					qui sum exposure if group == 5 & anio_fiscal == 2014
					loc coef = (r(mean))
					lincom `coef'*`d'#1.post
					loc minority_effect = r(estimate)
					loc minority_effect_se = r(se)
					
					regsave using "$outdir/continuous_exposure.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "levels", design, "dd", majority_effect, `majority_effect', majority_effect_se, `majority_effect_se', minority_effect, `minority_effect', minority_effect_se, `minority_effect_se', samplespec, "`samplespec'") detail(scalars)	
			
				}
				
			//skipping if the variable is a binary variable
			qui sum `y'
			if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue
			
			cap gen l_`y' = log(`y')
			cap gen b_`y' = `y' > 0 if missing(`y') == 0
			
			//log
			cap n reghdfe l_`y' `v'##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
				if !_rc regsave using "$outdir/continuous_exposure.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "log", design, "event_study", samplespec, "`samplespec'") detail(scalars)
				
			cap n reghdfe l_`y' `v'##b0.i.post, cluster(firm_id) absorb(firm_id)
			
				if !_rc {
				
					lincom 3*`d'#1.post
					loc majority_effect = r(estimate)
					loc majority_effect_se = r(se)
					
					qui sum exposure if group == 5 & anio_fiscal == 2014
					loc coef = (r(mean))
					lincom `coef'*`d'#1.post
					loc minority_effect = r(estimate)
					loc minority_effect_se = r(se)
					
					regsave using "$outdir/continuous_exposure.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "log", design, "dd", majority_effect, `majority_effect', majority_effect_se, `majority_effect_se', minority_effect, `minority_effect', minority_effect_se, `minority_effect_se', samplespec, "`samplespec'") detail(scalars)	
				
				}
				
			//poisson
			cap n ppmlhdfe `y' `v'##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
				
				if !_rc regsave using "$outdir/continuous_exposure.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "poisson", design, "event_study", samplespec, "`samplespec'") detail(scalars)
				
			cap n ppmlhdfe `y' `v'##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id)
			
				if !_rc {
				
					lincom 3*`d'#1.post
					loc majority_effect = r(estimate)
					loc majority_effect_se = r(se)
					
					qui sum exposure if group == 5 & anio_fiscal == 2014
					loc coef = (r(mean))
					lincom `coef'*`d'#1.post
					loc minority_effect = r(estimate)
					loc minority_effect_se = r(se)
					
					regsave using "$outdir/continuous_exposure.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "poisson", design, "dd", majority_effect, `majority_effect', majority_effect_se, `majority_effect_se', minority_effect, `minority_effect', minority_effect_se, `minority_effect_se', samplespec, "`samplespec'") detail(scalars)	
				
				}
				
			//binary
			cap n reghdfe b_`y' `v'##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
				
				if !_rc regsave using "$outdir/continuous_exposure.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "binary", design, "event_study", samplespec, "`samplespec'") detail(scalars)
				
			cap n reghdfe b_`y' `v'##b0.i.post, cluster(firm_id) absorb(firm_id)
			
				if !_rc {
				
					lincom 3*`d'#1.post
					loc majority_effect = r(estimate)
					loc majority_effect_se = r(se)
					
					qui sum exposure if group == 5 & anio_fiscal == 2014
					loc coef = (r(mean))
					lincom `coef'*`d'#1.post
					loc minority_effect = r(estimate)
					loc minority_effect_se = r(se)
					
					regsave using "$outdir/continuous_exposure.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "binary", design, "dd", majority_effect, `majority_effect', majority_effect_se, `majority_effect_se', minority_effect, `minority_effect', minority_effect_se, `minority_effect_se', samplespec, "`samplespec'") detail(scalars)	
				
				}
			
			//closing dependent variable loop
			}
			
		//closing independent variable loops	
		}

	restore

}

cap postclose continuous_exposure

/////
///
//VERSION 1B: DD ON CONTINUOUS EXPOSURE + CONSTANT, ALL FIRMS
///
/////

cap postclose continuous_exposure_alt
postfile continuous_exposure_alt str32(var) double(coef stderr N r2) using "$outdir/continuous_exposure_alt.dta", replace

// foreach y in aps f101 active aps_f101 aps_f101_active porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais aps_residual_pais_other average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_conc terminal_owners_10 terminal_owners participation_prominent participation_prominent_0 participation_inv_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_100_pff intermediate_pff_max intermediate_50_prominent intermediate_100_ext intermediate_100_prominent intermediate_inv_prominent intermediate_10_inv_prominent intermediate_50_inv_prominent intermediate_100_inv_prominent empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt bf_persona_r persona_prominent bf_persona_100_r any_bf_persona_r bf_empresa_r complete_r inconsistent_r aps_residual_0_r percent_declarado_r persona_prominent_r incomplete_r aps_residual_r cit_liability gross_profit taxable_profits cit_liability uti_reinvertir_cpz_3580_w taxable_profits_w gross_profit_w cit_liability_w tasa_ir tasa_ir_w {
	
forv x = 1/2 {
	
	preserve
	
		if `x' == 1 {
			
			loc samplespec = "minors"
			keep if inlist(group, 3, 5)
			
		}
		
		else if `x' == 2 {
			
			loc samplespec = "all"
			keep if inlist(group, 2, 3, 4, 5)
			
		}
				
		foreach v in "c.exposure_consistent" "c.exposure" /*"c.exposure##b0.i.b_cit_liability_2014" "c.exposure##b0.i.consistent_2015_2017" "c.exposure##b0.i.b_cit_liability_2014##b0.i.consistent_2015_2017"*/ {
			
			if "`v'" == "c.exposure" loc d = "c.exposure"
			else if "`v'" == "c.exposure_consistent" loc d = "c.exposure_consistent"
			else if "`v'" == "c.exposure##b0.i.b_cit_liability_2014" loc d = "c.exposure#1.b_cit_liability_2014"
			else if "`v'" == "c.exposure##b0.i.consistent_2015_2017" loc d = "c.exposure#1.consistent_2015_2017"
			else if "`v'" == "c.exposure##b0.i.b_cit_liability_2014##b0.i.consistent_2015_2017" loc d = "c.exposure#1.b_cit_liability_2014#1.consistent_2015_2017"
				
			foreach y in bf_persona participation_prominent gross_profit_w cit_liability_w return_on_assets_w return_on_assets_w_alt {
				
			//levels
			cap n reghdfe `y' `v'##b2014.i.anio_fiscal b0.i.treatment##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
				if !_rc regsave using "$outdir/continuous_exposure_alt.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "levels", design, "event_study", samplespec, "`samplespec'") detail(scalars)
				
			cap n reghdfe `y' `v'##b0.i.post b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id)
			
				if !_rc {
				
					lincom 3*`d'#1.post + 1.treatment#1.post
					loc majority_effect = r(estimate)
					loc majority_effect_se = r(se)
					
					qui sum exposure if group == 5 & anio_fiscal == 2014
					loc coef = (r(mean))
					lincom `coef'*`d'#1.post + 1.treatment#1.post
					loc minority_effect = r(estimate)
					loc minority_effect_se = r(se)
					
					regsave using "$outdir/continuous_exposure_alt.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "levels", design, "dd", majority_effect, `majority_effect', majority_effect_se, `majority_effect_se', minority_effect, `minority_effect', minority_effect_se, `minority_effect_se', samplespec, "`samplespec'") detail(scalars)	
			
				}
				
			//skipping if the variable is a binary variable
			qui sum `y'
			if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue
			
			cap gen l_`y' = log(`y')
			cap gen b_`y' = `y' > 0 if missing(`y') == 0
			
			//log
			cap n reghdfe l_`y' `v'##b2014.i.anio_fiscal b0.i.treatment##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
				if !_rc regsave using "$outdir/continuous_exposure_alt.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "log", design, "event_study", samplespec, "`samplespec'") detail(scalars)
				
			cap n reghdfe l_`y' `v'##b0.i.post b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id)
			
				if !_rc {
				
					lincom 3*`d'#1.post + 1.treatment#1.post
					loc majority_effect = r(estimate)
					loc majority_effect_se = r(se)
					
					qui sum exposure if group == 5 & anio_fiscal == 2014
					loc coef = (r(mean))
					lincom `coef'*`d'#1.post + 1.treatment#1.post
					loc minority_effect = r(estimate)
					loc minority_effect_se = r(se)
					
					regsave using "$outdir/continuous_exposure_alt.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "log", design, "dd", majority_effect, `majority_effect', majority_effect_se, `majority_effect_se', minority_effect, `minority_effect', minority_effect_se, `minority_effect_se', samplespec, "`samplespec'") detail(scalars)	
				
				}
				
			//poisson
			cap n ppmlhdfe `y' `v'##b2014.i.anio_fiscal b0.i.treatment##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
				
				if !_rc regsave using "$outdir/continuous_exposure_alt.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "poisson", design, "event_study", samplespec, "`samplespec'") detail(scalars)
				
			cap n ppmlhdfe `y' `v'##b0.i.post b0.i.treatment##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id)
			
				if !_rc {
				
					lincom 3*`d'#1.post + 1.treatment#1.post
					loc majority_effect = r(estimate)
					loc majority_effect_se = r(se)
					
					qui sum exposure if group == 5 & anio_fiscal == 2014
					loc coef = (r(mean))
					lincom `coef'*`d'#1.post + 1.treatment#1.post
					loc minority_effect = r(estimate)
					loc minority_effect_se = r(se)
					
					regsave using "$outdir/continuous_exposure_alt.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "poisson", design, "dd", majority_effect, `majority_effect', majority_effect_se, `majority_effect_se', minority_effect, `minority_effect', minority_effect_se, `minority_effect_se', samplespec, "`samplespec'") detail(scalars)	
				
				}
				
			//binary
			cap n reghdfe b_`y' `v'##b2014.i.anio_fiscal b0.i.treatment##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
				
				if !_rc regsave using "$outdir/continuous_exposure_alt.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "binary", design, "event_study", samplespec, "`samplespec'") detail(scalars)
				
			cap n reghdfe b_`y' `v'##b0.i.post b0.i.treatment##b0.i.post, cluster(firm_id) absorb(firm_id)
			
				if !_rc {
				
					lincom 3*`d'#1.post + 1.treatment#1.post
					loc majority_effect = r(estimate)
					loc majority_effect_se = r(se)
					
					qui sum exposure if group == 5 & anio_fiscal == 2014
					loc coef = (r(mean))
					lincom `coef'*`d'#1.post + 1.treatment#1.post
					loc minority_effect = r(estimate)
					loc minority_effect_se = r(se)
					
					regsave using "$outdir/continuous_exposure_alt.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "binary", design, "dd", majority_effect, `majority_effect', majority_effect_se, `majority_effect_se', minority_effect, `minority_effect', minority_effect_se, `minority_effect_se', samplespec, "`samplespec'") detail(scalars)	
			
				}
				
			//closing dependent variable loop
			}
			
		//closing independent variable loops	
		}

	restore		
	
}	
	
cap postclose continuous_exposure_alt
*/

/////
///
//VERSION 2: CONTINUOUS DD WTIHIN MINORITY AND MAJORITY EXPOSURE
///
/////

cap postclose continuous_exposure_treatment
postfile continuous_exposure_treatment str32(var) double(coef stderr N r2) using "$outdir/continuous_exposure_treatment.dta", replace

forv x = 1/3 {
	
	preserve

		if `x' == 1 {
			
			loc indvar = "exposure"
			keep if inlist(group, 4, 5)
			
		}

		else if `x' == 2 {
			
			loc indvar = "exposure_consistent"
			keep if consistent_2015_2017 == 1
			keep if inlist(group, 4, 5)
			
		}
		
		else if `x' == 3 {
			
			loc indvar = "exposure_consistent_minors"
			keep if consistent_2015_2017 == 1
			keep if inlist(group, 5)
			
		}
		
		cap gegen porcentaje_alt = rowtotal(porcentaje_ext porcentaje_nac)
			
		//foreach y in aps f101 active aps_f101 aps_f101_active porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais aps_residual_pais_other average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_conc terminal_owners_10 terminal_owners participation_prominent participation_prominent_0 participation_inv_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_100_pff intermediate_pff_max intermediate_50_prominent intermediate_100_ext intermediate_100_prominent intermediate_inv_prominent intermediate_10_inv_prominent intermediate_50_inv_prominent intermediate_100_inv_prominent empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt bf_persona_r persona_prominent bf_persona_100_r any_bf_persona_r bf_empresa_r complete_r inconsistent_r aps_residual_0_r percent_declarado_r persona_prominent_r incomplete_r aps_residual_r cit_liability gross_profit taxable_profits cit_liability uti_reinvertir_cpz_3580_w taxable_profits_w gross_profit_w cit_liability_w tasa_ir tasa_ir_w {
			
		foreach y in porcentaje_pff porcentaje_ext porcentaje_nac participation_prominent porcentaje_alt cit_liability_w gross_profit_w return_on_assets_w return_on_assets_w_alt {		 
			
			//levels
			cap n reghdfe `y' c.exposure##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
				if !_rc regsave using "$outdir/continuous_exposure_treatment.dta", append autoid addlabel(indepvar, "`indvar'", depvar, `y', spec, "levels", design, "event_study") detail(scalars)
				
			cap n reghdfe `y' c.exposure##b0.i.post, cluster(firm_id) absorb(firm_id)
			
				if !_rc regsave using "$outdir/continuous_exposure_treatment.dta", append autoid addlabel(indepvar, "`indvar'", depvar, `y', spec, "levels", design, "dd") detail(scalars)
				
			//skipping if the variable is a binary variable
			qui sum `y'
			if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue
			
			cap gen l_`y' = log(`y')
			cap gen b_`y' = `y' > 0 if missing(`y') == 0
	
			//log
			cap n reghdfe l_`y' c.exposure##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
				if !_rc regsave using "$outdir/continuous_exposure_treatment.dta", append autoid addlabel(indepvar, "`indvar'", depvar, `y', spec, "log", design, "event_study") detail(scalars)
				
			cap n reghdfe l_`y' c.exposure##b0.i.post, cluster(firm_id) absorb(firm_id)
			
				if !_rc regsave using "$outdir/continuous_exposure_treatment.dta", append autoid addlabel(indepvar, "`indvar'", depvar, `y', spec, "log", design, "dd") detail(scalars)	
				
			//poisson
			cap n ppmlhdfe `y' c.exposure##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
				
				if !_rc regsave using "$outdir/continuous_exposure_treatment.dta", append autoid addlabel(indepvar, "`indvar'", depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
				
			cap n ppmlhdfe `y' c.exposure##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id)
			
				if !_rc regsave using "$outdir/continuous_exposure_treatment.dta", append autoid addlabel(indepvar, "`indvar'", depvar, `y', spec, "poisson", design, "dd") detail(scalars)	
				
			//binary
			cap n reghdfe b_`y' c.exposure##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
				
				if !_rc regsave using "$outdir/continuous_exposure_treatment.dta", append autoid addlabel(indepvar, "`indvar'", depvar, `y', spec, "binary", design, "event_study") detail(scalars)
				
			cap n reghdfe b_`y' c.exposure##b0.i.post, cluster(firm_id) absorb(firm_id)
			
				if !_rc regsave using "$outdir/continuous_exposure_treatment.dta", append autoid addlabel(indepvar, "`indvar'", depvar, `y', spec, "binary", design, "dd") detail(scalars)	
			
		}

	restore

}

cap postclose continuous_exposure_treatment
	
/////
///
//VERSION 2B: BINARY DD WTIHIN MINORITY AND MAJORITY EXPOSURE
///
/////

cap postclose binary_exposure_treatment
postfile binary_exposure_treatment str32(var) double(coef stderr N r2) using "$outdir/binary_exposure_treatment.dta", replace

forv x = 1/2 {
	
	preserve

		if `x' == 1 {
			
			loc indvar = "binary_exposure"
			
		}

		else if `x' == 2 {
			
			loc indvar = "binary_exposure_consistent"
			keep if consistent_2015_2017 == 1
			
		}	
		
		cap gegen porcentaje_alt = rowtotal(porcentaje_ext porcentaje_nac)
		
		keep if inlist(group, 4, 5)

		//foreach y in aps f101 active aps_f101 aps_f101_active porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais aps_residual_pais_other average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_conc terminal_owners_10 terminal_owners participation_prominent participation_prominent_0 participation_inv_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_100_pff intermediate_pff_max intermediate_50_prominent intermediate_100_ext intermediate_100_prominent intermediate_inv_prominent intermediate_10_inv_prominent intermediate_50_inv_prominent intermediate_100_inv_prominent empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt bf_persona_r persona_prominent bf_persona_100_r any_bf_persona_r bf_empresa_r complete_r inconsistent_r aps_residual_0_r percent_declarado_r persona_prominent_r incomplete_r aps_residual_r cit_liability gross_profit taxable_profits cit_liability uti_reinvertir_cpz_3580_w taxable_profits_w gross_profit_w cit_liability_w tasa_ir tasa_ir_w {
			
		foreach y in porcentaje_pff porcentaje_ext porcentaje_nac participation_prominent porcentaje_alt cit_liability_w gross_profit_w return_on_assets_w return_on_assets_w_alt {
			
			//levels
			cap n reghdfe `y' b5.i.group##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
				if !_rc regsave using "$outdir/binary_exposure_treatment.dta", append autoid addlabel(indepvar, "`indvar'", depvar, `y', spec, "levels", design, "event_study") detail(scalars)
				
			cap n reghdfe `y' b5.i.group##b0.i.post b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id)
				
				if !_rc regsave using "$outdir/binary_exposure_treatment.dta", append autoid addlabel(indepvar, "`indvar'", depvar, `y', spec, "levels", design, "dd") detail(scalars)
				
			//skipping if the variable is a binary variable
			qui sum `y'
			if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue
			
			cap gen l_`y' = log(`y')
			cap gen b_`y' = `y' > 0 if missing(`y') == 0
			
			//log
			cap n reghdfe l_`y' b5.i.group##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
				if !_rc regsave using "$outdir/binary_exposure_treatment.dta", append autoid addlabel(indepvar, "`indvar'", depvar, `y', spec, "log", design, "event_study") detail(scalars)
				
			cap n reghdfe l_`y' b5.i.group##b0.i.post b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id)
			
				if !_rc regsave using "$outdir/binary_exposure_treatment.dta", append autoid addlabel(indepvar, "`indvar'", depvar, `y', spec, "log", design, "dd") detail(scalars)	
				
			//poisson
			cap n ppmlhdfe `y' b5.i.group##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
				
				if !_rc regsave using "$outdir/binary_exposure_treatment.dta", append autoid addlabel(indepvar, "`indvar'", depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
				
			cap n ppmlhdfe `y' b5.i.group##b0.i.post b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id)
			
				if !_rc regsave using "$outdir/binary_exposure_treatment.dta", append autoid addlabel(indepvar, "`indvar'", depvar, `y', spec, "poisson", design, "dd") detail(scalars)	
				
			//binary
			cap n reghdfe b_`y' b5.i.group##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
				
				if !_rc regsave using "$outdir/binary_exposure_treatment.dta", append autoid addlabel(indepvar, "`indvar'", depvar, `y', spec, "binary", design, "event_study") detail(scalars)
				
			cap n reghdfe b_`y' b5.i.group##b0.i.post b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id)
			
				if !_rc regsave using "$outdir/binary_exposure_treatment.dta", append autoid addlabel(indepvar, "`indvar'", depvar, `y', spec, "binary", design, "dd") detail(scalars)	
			
		}

	restore
	
}	

cap postclose binary_exposure_treatment

/*	
/////
///
//VERSION 2C: DD ON EXPOSURE WITHIN MAJORS
///
/////

cap postclose continuous_exposure_majors
postfile continuous_exposure_majors str32(var) double(coef stderr N r2) using "$outdir/continuous_exposure_majors.dta", replace

preserve

	keep if inlist(group, 2, 4)

	foreach y in aps f101 active aps_f101 aps_f101_active porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais aps_residual_pais_other average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_conc terminal_owners_10 terminal_owners participation_prominent participation_prominent_0 participation_inv_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_100_pff intermediate_pff_max intermediate_50_prominent intermediate_100_ext intermediate_100_prominent intermediate_inv_prominent intermediate_10_inv_prominent intermediate_50_inv_prominent intermediate_100_inv_prominent empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt bf_persona_r persona_prominent bf_persona_100_r any_bf_persona_r bf_empresa_r complete_r inconsistent_r aps_residual_0_r percent_declarado_r persona_prominent_r incomplete_r aps_residual_r cit_liability gross_profit taxable_profits cit_liability uti_reinvertir_cpz_3580_w taxable_profits_w gross_profit_w cit_liability_w tasa_ir tasa_ir_w {
		
		//levels
		cap n reghdfe `y' c.prominent_2014##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_majors.dta", append autoid addlabel(indepvar, "prominent_2014", depvar, `y', spec, "levels", design, "event_study") detail(scalars)
			
		cap n reghdfe `y' c.prominent_2014##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_majors.dta", append autoid addlabel(indepvar, "prominent_2014", depvar, `y', spec, "levels", design, "dd") detail(scalars)	
		
		//skipping if the variable is a binary variable
		qui sum `y'
		if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue
		
		cap gen l_`y' = log(`y')
		cap gen b_`y' = `y' > 0 if missing(`y') == 0
		
		//log
		cap n reghdfe l_`y' c.prominent_2014##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_majors.dta", append autoid addlabel(indepvar, "prominent_2014", depvar, `y', spec, "log", design, "event_study") detail(scalars)
			
		cap n reghdfe l_`y' c.prominent_2014##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_majors.dta", append autoid addlabel(indepvar, "prominent_2014", depvar, `y', spec, "log", design, "dd") detail(scalars)	
			
		//poisson
		cap n ppmlhdfe `y' c.prominent_2014##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
			
			if !_rc regsave using "$outdir/continuous_exposure_majors.dta", append autoid addlabel(indepvar, "prominent_2014", depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
			
		cap n ppmlhdfe `y' c.prominent_2014##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_majors.dta", append autoid addlabel(indepvar, "prominent_2014", depvar, `y', spec, "poisson", design, "dd") detail(scalars)	
			
		//binary
		cap n reghdfe b_`y' c.prominent_2014##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
			if !_rc regsave using "$outdir/continuous_exposure_majors.dta", append autoid addlabel(indepvar, "prominent_2014", depvar, `y', spec, "binary", design, "event_study") detail(scalars)
			
		cap n reghdfe b_`y' c.prominent_2014##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_majors.dta", append autoid addlabel(indepvar, "prominent_2014", depvar, `y', spec, "binary", design, "dd") detail(scalars)	
		
	}

	cap postclose continuous_exposure_majors

restore	

/////
///
//VERSION 2D: DD ON EXPOSURE WITHIN T-MAJORS
///
/////

cap postclose continuous_exposure_t_majors
postfile continuous_exposure_t_majors str32(var) double(coef stderr N r2) using "$outdir/continuous_exposure_t_majors.dta", replace

preserve

	keep if inlist(group, 4)

	foreach y in aps f101 active aps_f101 aps_f101_active porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais aps_residual_pais_other average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_conc terminal_owners_10 terminal_owners participation_prominent participation_prominent_0 participation_inv_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_100_pff intermediate_pff_max intermediate_50_prominent intermediate_100_ext intermediate_100_prominent intermediate_inv_prominent intermediate_10_inv_prominent intermediate_50_inv_prominent intermediate_100_inv_prominent empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt bf_persona_r persona_prominent bf_persona_100_r any_bf_persona_r bf_empresa_r complete_r inconsistent_r aps_residual_0_r percent_declarado_r persona_prominent_r incomplete_r aps_residual_r cit_liability gross_profit taxable_profits cit_liability uti_reinvertir_cpz_3580_w taxable_profits_w gross_profit_w cit_liability_w tasa_ir tasa_ir_w {
		
		//levels
		cap n reghdfe `y' c.prominent_2014##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_t_majors.dta", append autoid addlabel(indepvar, "prominent_2014", depvar, `y', spec, "levels", design, "event_study") detail(scalars)
			
		cap n reghdfe `y' c.prominent_2014##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_t_majors.dta", append autoid addlabel(indepvar, "prominent_2014", depvar, `y', spec, "levels", design, "dd") detail(scalars)	
		
		//skipping if the variable is a binary variable
		qui sum `y'
		if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue
		
		cap gen l_`y' = log(`y')
		cap gen b_`y' = `y' > 0 if missing(`y') == 0
		
		//log
		cap n reghdfe l_`y' c.prominent_2014##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_t_majors.dta", append autoid addlabel(indepvar, "prominent_2014", depvar, `y', spec, "log", design, "event_study") detail(scalars)
			
		cap n reghdfe l_`y' c.prominent_2014##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_t_majors.dta", append autoid addlabel(indepvar, "prominent_2014", depvar, `y', spec, "log", design, "dd") detail(scalars)	
			
		//poisson
		cap n ppmlhdfe `y' c.prominent_2014##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
			
			if !_rc regsave using "$outdir/continuous_exposure_t_majors.dta", append autoid addlabel(indepvar, "prominent_2014", depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
			
		cap n ppmlhdfe `y' c.prominent_2014##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_t_majors.dta", append autoid addlabel(indepvar, "prominent_2014", depvar, `y', spec, "poisson", design, "dd") detail(scalars)	
			
		//binary
		cap n reghdfe b_`y' c.prominent_2014##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
			if !_rc regsave using "$outdir/continuous_exposure_t_majors.dta", append autoid addlabel(indepvar, "prominent_2014", depvar, `y', spec, "binary", design, "event_study") detail(scalars)
			
		cap n reghdfe b_`y' c.prominent_2014##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_t_majors.dta", append autoid addlabel(indepvar, "prominent_2014", depvar, `y', spec, "binary", design, "dd") detail(scalars)	
		
	}

	cap postclose continuous_exposure_majors

restore	
*/

/*
/////
///
//VERSION 3 DD ON EXPOSURE, MINORS
///
/////

cap postclose continuous_exposure_minors
postfile continuous_exposure_minors str32(var) double(coef stderr N r2) using "$outdir/continuous_exposure_minors.dta", replace

preserve

	keep if inlist(group, 3, 5)

// 	foreach y in aps f101 active aps_f101 aps_f101_active porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais aps_residual_pais_other average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_conc terminal_owners_10 terminal_owners participation_prominent participation_prominent_0 participation_inv_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_100_pff intermediate_pff_max intermediate_50_prominent intermediate_100_ext intermediate_100_prominent intermediate_inv_prominent intermediate_10_inv_prominent intermediate_50_inv_prominent intermediate_100_inv_prominent empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt bf_persona_r persona_prominent bf_persona_100_r any_bf_persona_r bf_empresa_r complete_r inconsistent_r aps_residual_0_r percent_declarado_r persona_prominent_r incomplete_r aps_residual_r cit_liability gross_profit taxable_profits cit_liability uti_reinvertir_cpz_3580_w taxable_profits_w gross_profit_w cit_liability_w tasa_ir tasa_ir_w {
		
	foreach v in "" "_cit_consistent_missing" "_consistent_missing" "_cit_consistent" "_consistent" "_cit" {
		
		foreach y in participation_prominent porcentaje_pff gross_profit_w cit_liability_w bf_persona {	
		
			//levels
			cap n reghdfe `y' c.exposure`v'##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
				if !_rc regsave using "$outdir/continuous_exposure_minors.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "levels", design, "event_study") detail(scalars)
				
			cap n reghdfe `y' c.exposure`v'##b0.i.post, cluster(firm_id) absorb(firm_id)
			
				if !_rc {
				
					lincom 3*c.exposure`v'#1.post
					loc majority_effect = r(estimate)
					loc majority_effect_se = r(se)
					
					qui sum exposure if group == 5 & anio_fiscal == 2014
					loc coef = (r(mean))
					lincom `coef'*c.exposure`v'#1.post
					loc minority_effect = r(estimate)
					loc minority_effect_se = r(se)
					
					regsave using "$outdir/continuous_exposure_minors.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "levels", design, "dd", majority_effect, `majority_effect', majority_effect_se, `majority_effect_se', minority_effect, `minority_effect', minority_effect_se, `minority_effect_se') detail(scalars)	
			
				}
				
			//skipping if the variable is a binary variable
			qui sum `y'
			if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue
			
			cap gen l_`y' = log(`y')
			cap gen b_`y' = `y' > 0 if missing(`y') == 0
			
			//log
			cap n reghdfe l_`y' c.exposure`v'##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
				if !_rc regsave using "$outdir/continuous_exposure_minors.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "log", design, "event_study") detail(scalars)
				
			cap n reghdfe l_`y' c.exposure`v'##b0.i.post, cluster(firm_id) absorb(firm_id)
			
				if !_rc {
				
					lincom 3*c.exposure`v'#1.post
					loc majority_effect = r(estimate)
					loc majority_effect_se = r(se)
					
					qui sum exposure if group == 5 & anio_fiscal == 2014
					loc coef = (r(mean))
					lincom `coef'*c.exposure`v'#1.post
					loc minority_effect = r(estimate)
					loc minority_effect_se = r(se)
					
					regsave using "$outdir/continuous_exposure_minors.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "log", design, "dd", majority_effect, `majority_effect', majority_effect_se, `majority_effect_se', minority_effect, `minority_effect', minority_effect_se, `minority_effect_se') detail(scalars)	
				
				}
				
			//poisson
			cap n ppmlhdfe `y' c.exposure`v'##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
				
				if !_rc regsave using "$outdir/continuous_exposure_minors.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
				
			cap n ppmlhdfe `y' c.exposure`v'##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id)
			
				if !_rc {
				
					lincom 3*c.exposure`v'#1.post
					loc majority_effect = r(estimate)
					loc majority_effect_se = r(se)
					
					qui sum exposure if group == 5 & anio_fiscal == 2014
					loc coef = (r(mean))
					lincom `coef'*c.exposure`v'#1.post
					loc minority_effect = r(estimate)
					loc minority_effect_se = r(se)
					
					regsave using "$outdir/continuous_exposure_minors.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "poisson", design, "dd", majority_effect, `majority_effect', majority_effect_se, `majority_effect_se', minority_effect, `minority_effect', minority_effect_se, `minority_effect_se') detail(scalars)	
				
				}
				
			//binary
			cap n reghdfe b_`y' c.exposure`v'##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
				
				if !_rc regsave using "$outdir/continuous_exposure_minors.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "binary", design, "event_study") detail(scalars)
				
			cap n reghdfe b_`y' c.exposure`v'##b0.i.post, cluster(firm_id) absorb(firm_id)
			
				if !_rc {
				
					lincom 3*c.exposure`v'#1.post
					loc majority_effect = r(estimate)
					loc majority_effect_se = r(se)
					
					qui sum exposure if group == 5 & anio_fiscal == 2014
					loc coef = (r(mean))
					lincom `coef'*c.exposure`v'#1.post
					loc minority_effect = r(estimate)
					loc minority_effect_se = r(se)
					
					regsave using "$outdir/continuous_exposure_minors.dta", append autoid addlabel(indepvar, "`v'", depvar, `y', spec, "binary", design, "dd", majority_effect, `majority_effect', majority_effect_se, `majority_effect_se', minority_effect, `minority_effect', minority_effect_se, `minority_effect_se') detail(scalars)	
			
				}
			
		//closing dependent variable loop		
		}

	//closing independent variable loop	
	}	
		
	cap postclose continuous_exposure_minors

restore

/////
///
//VERSION 4: DD ON EXPOSURE, TREATMENT MINORS
///
/////

cap postclose continuous_exposure_treat_min
postfile continuous_exposure_treat_min str32(var) double(coef stderr N r2) using "$outdir/continuous_exposure_treat_min.dta", replace

preserve

	keep if inlist(group, 5)

	foreach y in aps f101 active aps_f101 aps_f101_active porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais aps_residual_pais_other average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_conc terminal_owners_10 terminal_owners participation_prominent participation_prominent_0 participation_inv_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_100_pff intermediate_pff_max intermediate_50_prominent intermediate_100_ext intermediate_100_prominent intermediate_inv_prominent intermediate_10_inv_prominent intermediate_50_inv_prominent intermediate_100_inv_prominent empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt bf_persona_r persona_prominent bf_persona_100_r any_bf_persona_r bf_empresa_r complete_r inconsistent_r aps_residual_0_r percent_declarado_r persona_prominent_r incomplete_r aps_residual_r cit_liability gross_profit taxable_profits cit_liability uti_reinvertir_cpz_3580_w taxable_profits_w gross_profit_w cit_liability_w tasa_ir tasa_ir_w {
		
		//levels
		cap n reghdfe `y' c.exposure##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_treat_min.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "levels", design, "event_study") detail(scalars)
			
		cap n reghdfe `y' c.exposure##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_treat_min.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "levels", design, "dd") detail(scalars)	
		
		
		//skipping if the variable is a binary variable
		sum `y'
		if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue
		
		cap gen l_`y' = log(`y')
		cap gen b_`y' = `y' > 0 if missing(`y') == 0
		
		//log
		cap n reghdfe l_`y' c.exposure##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_treat_min.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "log", design, "event_study") detail(scalars)
			
		cap n reghdfe l_`y' c.exposure##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_treat_min.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "log", design, "dd") detail(scalars)	
			
		//poisson
		cap n ppmlhdfe `y' c.exposure##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
			
			if !_rc regsave using "$outdir/continuous_exposure_treat_min.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
			
		cap n ppmlhdfe `y' c.exposure##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_treat_min.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "poisson", design, "dd") detail(scalars)	
			
		//binary
		cap n reghdfe b_`y' c.exposure##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
			if !_rc regsave using "$outdir/continuous_exposure_treat_min.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "binary", design, "event_study") detail(scalars)
			
		cap n reghdfe b_`y' c.exposure##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_treat_min.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "binary", design, "dd") detail(scalars)	
		
	}

	cap postclose continuous_exposure_treat_min

restore
	
/////
///
//VERSION 5: DDD, SKIPPING, NOT A GOOD IDEA
///
/////

/////
///
//VERSION 6: DD ON CONTINUOUS EXPOSURE, TREATMENT MINORS V. C-MAJORS
///
/////

cap postclose continuous_exposure_tmin_cmaj
postfile continuous_exposure_tmin_cmaj str32(var) double(coef stderr N r2) using "$outdir/continuous_exposure_tmin_cmaj.dta", replace

preserve

	keep if inlist(group, 2, 5)

	foreach y in aps f101 active aps_f101 aps_f101_active porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais aps_residual_pais_other average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_conc terminal_owners_10 terminal_owners participation_prominent participation_prominent_0 participation_inv_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_100_pff intermediate_pff_max intermediate_50_prominent intermediate_100_ext intermediate_100_prominent intermediate_inv_prominent intermediate_10_inv_prominent intermediate_50_inv_prominent intermediate_100_inv_prominent empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt bf_persona_r persona_prominent bf_persona_100_r any_bf_persona_r bf_empresa_r complete_r inconsistent_r aps_residual_0_r percent_declarado_r persona_prominent_r incomplete_r aps_residual_r cit_liability gross_profit taxable_profits cit_liability uti_reinvertir_cpz_3580_w taxable_profits_w gross_profit_w cit_liability_w tasa_ir tasa_ir_w {
		
		//levels
		cap n reghdfe `y' c.exposure##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_tmin_cmaj.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "levels", design, "event_study") detail(scalars)
			
		cap n reghdfe `y' c.exposure##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_tmin_cmaj.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "levels", design, "dd") detail(scalars)	
		
		
		//skipping if the variable is a binary variable
		sum `y'
		if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue
		
		cap gen l_`y' = log(`y')
		cap gen b_`y' = `y' > 0 if missing(`y') == 0
		
		//log
		cap n reghdfe l_`y' c.exposure##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_tmin_cmaj.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "log", design, "event_study") detail(scalars)
			
		cap n reghdfe l_`y' c.exposure##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_tmin_cmaj.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "log", design, "dd") detail(scalars)	
			
		//poisson
		cap n ppmlhdfe `y' c.exposure##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
			
			if !_rc regsave using "$outdir/continuous_exposure_tmin_cmaj.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
			
		cap n ppmlhdfe `y' c.exposure##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_tmin_cmaj.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "poisson", design, "dd") detail(scalars)	
			
		//binary
		cap n reghdfe b_`y' c.exposure##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
			if !_rc regsave using "$outdir/continuous_exposure_tmin_cmaj.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "binary", design, "event_study") detail(scalars)
			
		cap n reghdfe b_`y' c.exposure##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_tmin_cmaj.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "binary", design, "dd") detail(scalars)	
		
	}

	cap postclose continuous_exposure_tmin_cmaj

restore
	
/////
///
//VERSION 7: DD ON BINARY EXPOSURE, TREATMENT MINORS V. C-MAJORS
///
/////

cap postclose binary_exposure_tmin_cmaj
postfile binary_exposure_tmin_cmaj str32(var) double(coef stderr N r2) using "$outdir/binary_exposure_tmin_cmaj.dta", replace

preserve

	keep if inlist(group, 2, 5)

	foreach y in aps f101 active aps_f101 aps_f101_active porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais aps_residual_pais_other average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_conc terminal_owners_10 terminal_owners participation_prominent participation_prominent_0 participation_inv_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_100_pff intermediate_pff_max intermediate_50_prominent intermediate_100_ext intermediate_100_prominent intermediate_inv_prominent intermediate_10_inv_prominent intermediate_50_inv_prominent intermediate_100_inv_prominent empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt bf_persona_r persona_prominent bf_persona_100_r any_bf_persona_r bf_empresa_r complete_r inconsistent_r aps_residual_0_r percent_declarado_r persona_prominent_r incomplete_r aps_residual_r cit_liability gross_profit taxable_profits cit_liability uti_reinvertir_cpz_3580_w taxable_profits_w gross_profit_w cit_liability_w tasa_ir tasa_ir_w {
		
		//levels
		cap n reghdfe `y' b2.i.group##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/binary_exposure_tmin_cmaj.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "levels", design, "event_study") detail(scalars)
			
		cap n reghdfe `y' b2.i.group##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/binary_exposure_tmin_cmaj.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "levels", design, "dd") detail(scalars)	
		
		
		//skipping if the variable is a binary variable
		sum `y'
		if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue
		
		cap gen l_`y' = log(`y')
		cap gen b_`y' = `y' > 0 if missing(`y') == 0
		
		//log
		cap n reghdfe l_`y' b2.i.group##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/binary_exposure_tmin_cmaj.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "log", design, "event_study") detail(scalars)
			
		cap n reghdfe l_`y' b2.i.group##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/binary_exposure_tmin_cmaj.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "log", design, "dd") detail(scalars)	
			
		//poisson
		cap n ppmlhdfe `y' b2.i.group##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
			
			if !_rc regsave using "$outdir/binary_exposure_tmin_cmaj.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
			
		cap n ppmlhdfe `y' b2.i.group##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/binary_exposure_tmin_cmaj.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "poisson", design, "dd") detail(scalars)	
			
		//binary
		cap n reghdfe b_`y' b2.i.group##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
			if !_rc regsave using "$outdir/binary_exposure_tmin_cmaj.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "binary", design, "event_study") detail(scalars)
			
		cap n reghdfe b_`y' b2.i.group##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/binary_exposure_tmin_cmaj.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "binary", design, "dd") detail(scalars)	
		
	}

	cap postclose binary_exposure_tmin_cmaj

restore

/////
///
//VERSION 8: DD ON BINARY EXPOSURE, T-MINOR V. C-MINOR MINORS
///
/////

cap postclose binary_exposure_tmin_cmin
postfile binary_exposure_tmin_cmin str32(var) double(coef stderr N r2) using "$outdir/binary_exposure_tmin_cmin.dta", replace

preserve

	keep if inlist(group, 3, 5)

// 	foreach y in aps f101 active aps_f101 aps_f101_active porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais aps_residual_pais_other average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_conc terminal_owners_10 terminal_owners participation_prominent participation_prominent_0 participation_inv_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_100_pff intermediate_pff_max intermediate_50_prominent intermediate_100_ext intermediate_100_prominent intermediate_inv_prominent intermediate_10_inv_prominent intermediate_50_inv_prominent intermediate_100_inv_prominent empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt bf_persona_r persona_prominent bf_persona_100_r any_bf_persona_r bf_empresa_r complete_r inconsistent_r aps_residual_0_r percent_declarado_r persona_prominent_r incomplete_r aps_residual_r cit_liability gross_profit taxable_profits cit_liability uti_reinvertir_cpz_3580_w taxable_profits_w gross_profit_w cit_liability_w tasa_ir tasa_ir_w {
	
	foreach y in participation_prominent porcentaje_pff gross_profit_w cit_liability_w {
		
		//levels
		cap n reghdfe `y' b3.i.group##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/binary_exposure_tmin_cmin.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "levels", design, "event_study") detail(scalars)
			
		cap n reghdfe `y' b3.i.group##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/binary_exposure_tmin_cmin.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "levels", design, "dd") detail(scalars)	
		
		
		//skipping if the variable is a binary variable
		sum `y'
		if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue
		
		cap gen l_`y' = log(`y')
		cap gen b_`y' = `y' > 0 if missing(`y') == 0
		
		//log
		cap n reghdfe l_`y' b3.i.group##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/binary_exposure_tmin_cmin.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "log", design, "event_study") detail(scalars)
			
		cap n reghdfe l_`y' b3.i.group##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/binary_exposure_tmin_cmin.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "log", design, "dd") detail(scalars)	
			
		//poisson
		cap n ppmlhdfe `y' b3.i.group##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
			
			if !_rc regsave using "$outdir/binary_exposure_tmin_cmin.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
			
		cap n ppmlhdfe `y' b3.i.group##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/binary_exposure_tmin_cmin.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "poisson", design, "dd") detail(scalars)	
			
		//binary
		cap n reghdfe b_`y' b3.i.group##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
			if !_rc regsave using "$outdir/binary_exposure_tmin_cmin.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "binary", design, "event_study") detail(scalars)
			
		cap n reghdfe b_`y' b3.i.group##b0.i.post, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/binary_exposure_tmin_cmin.dta", append autoid addlabel(indepvar, "exposure", depvar, `y', spec, "binary", design, "dd") detail(scalars)	
		
	}

	cap postclose binary_exposure_tmin_cmin

restore
		
/////
///
//MINORS, ALL BASE 2014 FOR POST
///
/////		
			
cap postclose continuous_exposure_base_2014
postfile continuous_exposure_base_2014 str32(var) double(coef stderr N r2) using "$outdir/continuous_exposure_base_2014.dta", replace
	
cap gen post_alt = 0 if anio_fiscal == 2014
	replace post_alt = 1 if anio_fiscal >= 2015
	replace post_alt = 2 if anio_fiscal <= 2013
	
///
//MINORS
///

preserve

	keep if inlist(group, 3, 5)

	foreach y in participation_prominent {
		
		//levels
		cap n reghdfe `y' c.exposure##b0.i.post_alt, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_base_2014.dta", append autoid addlabel(indepvar, "exposure_minors", depvar, `y', spec, "levels", design, "dd") detail(scalars)	
		
		//skipping if the variable is a binary variable
		qui sum `y'
		if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue
		
		cap gen l_`y' = log(`y')
		cap gen b_`y' = `y' > 0 if missing(`y') == 0
		
		//log
		cap n reghdfe l_`y' c.exposure##b0.i.post_alt, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_base_2014.dta", append autoid addlabel(indepvar, "exposure_minors", depvar, `y', spec, "log", design, "dd") detail(scalars)	
			
		//poisson	
		cap n ppmlhdfe `y' c.exposure##b0.i.post_alt if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_base_2014.dta", append autoid addlabel(indepvar, "exposure_minors", depvar, `y', spec, "poisson", design, "dd") detail(scalars)	
			
		//binary
		cap n reghdfe b_`y' c.exposure##b0.i.post_alt, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/continuous_exposure_base_2014.dta", append autoid addlabel(indepvar, "exposure_minors", depvar, `y', spec, "binary", design, "dd") detail(scalars)	
		
	}

restore

///
//ALL FIRMS
///

foreach y in participation_prominent {
	
	//levels
	cap n reghdfe `y' c.exposure##b0.i.post_alt, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/continuous_exposure_base_2014.dta", append autoid addlabel(indepvar, "exposure_all", depvar, `y', spec, "levels", design, "dd") detail(scalars)	
	
	//skipping if the variable is a binary variable
	qui sum `y'
	if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue
	
	cap gen l_`y' = log(`y')
	cap gen b_`y' = `y' > 0 if missing(`y') == 0
	
	//log
	cap n reghdfe l_`y' c.exposure##b0.i.post_alt, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/continuous_exposure_base_2014.dta", append autoid addlabel(indepvar, "exposure_all", depvar, `y', spec, "log", design, "dd") detail(scalars)	
		
	//poisson
	cap n ppmlhdfe `y' c.exposure##b0.i.post_alt if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/continuous_exposure_base_2014.dta", append autoid addlabel(indepvar, "exposure_all", depvar, `y', spec, "poisson", design, "dd") detail(scalars)	
		
	//binary
	cap n reghdfe b_`y' c.exposure##b0.i.post_alt, cluster(firm_id) absorb(firm_id anio_fiscal)
	
		if !_rc regsave using "$outdir/continuous_exposure_base_2014.dta", append autoid addlabel(indepvar, "exposure_all", depvar, `y', spec, "binary", design, "dd") detail(scalars)	
	
}

cap postclose continuous_exposure_base_2014
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

di "file continuous_exposure_results has terminated successfully"

cap log close
clear
