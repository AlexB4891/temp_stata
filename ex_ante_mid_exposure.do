cap clear all
set more off
cap log close
set varabbrev off

loc extract_date = "20251017"

/***********/
/* HISTORY */
/***********/
	
//20250617: heterogeneity cut + descriptives for the treatment group based on pre-reform mid activity

//20250731: including the post coefficient in the dd regressions

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

log using "$logdir/ex_ante_mid_exposure_`today'.smcl", replace

loc time0 = "$S_TIME"
loc date0 = "$S_DATE"

di "started: `time0' `date0'"

timer clear
timer on 1  

/************************/
/* EX ANTE MID EXPOSURE */
/************************/

use "$datadir/main_panel.dta", replace

//keeping c_majors
keep if inlist(group, 2, 4)

gegen firm_tag = tag(firm_id)

foreach v in salidas entradas {

	bys firm_id: gegen mid_all_`v'_pff_2014 = mean(cond(anio_fiscal == 2014, mid_all_`v'_pff, .))
	bys firm_id: gegen mid_all_`v'_pff_rr_2014 = mean(cond(anio_fiscal == 2014, mid_all_`v'_pff_rr, .))

	fasterxtile mid_all_`v'_pff_rr_2014_m = mid_all_`v'_pff_rr_2014 if firm_tag == 1 & mid_all_`v'_pff_rr_2014 != 0, nq(2)
	replace mid_all_`v'_pff_rr_2014_m = 0 if mid_all_`v'_pff_rr_2014 == 0 & firm_tag == 1

	bys firm_id: ereplace mid_all_`v'_pff_rr_2014_m = mean(mid_all_`v'_pff_rr_2014_m)

}

gen b_mid_all_salidas_pff_2014 = mid_all_salidas_pff_2014 > 0 if missing(mid_all_salidas_pff_2014) == 0
gen b_mid_all_entradas_pff_2014 = mid_all_entradas_pff_2014 > 0 if missing(mid_all_entradas_pff_2014) == 0

gen group_mid_salidas_pff_2014_m = 0 if group == 2 
	replace group_mid_salidas_pff_2014_m = 1 if group == 4 & mid_all_salidas_pff_rr_2014_m == 0
	replace group_mid_salidas_pff_2014_m = 2 if group == 4 & mid_all_salidas_pff_rr_2014_m == 1
	replace group_mid_salidas_pff_2014_m = 3 if group == 4 & mid_all_salidas_pff_rr_2014_m == 2

gen group_b_mid_salidas_pff_2014 = 0 if group == 2 
	replace group_b_mid_salidas_pff_2014 = 1 if group == 4 & b_mid_all_salidas_pff_2014 == 0
	replace group_b_mid_salidas_pff_2014 = 2 if group == 4 & b_mid_all_salidas_pff_2014 == 1

gen group_mid_entradas_pff_2014_m = 0 if group == 2 
	replace group_mid_entradas_pff_2014_m = 1 if group == 4 & mid_all_entradas_pff_rr_2014_m == 0
	replace group_mid_entradas_pff_2014_m = 2 if group == 4 & mid_all_entradas_pff_rr_2014_m == 1
	replace group_mid_entradas_pff_2014_m = 3 if group == 4 & mid_all_entradas_pff_rr_2014_m == 2

gen group_b_mid_entradas_pff_2014 = 0 if group == 2 
	replace group_b_mid_entradas_pff_2014 = 1 if group == 4 & b_mid_all_entradas_pff_2014 == 0
	replace group_b_mid_entradas_pff_2014 = 2 if group == 4 & b_mid_all_entradas_pff_2014 == 1

drop firm_tag mid_all_salidas_pff_rr_2014 mid_all_salidas_pff_rr_2014_m mid_all_entradas_pff_rr_2014 mid_all_entradas_pff_rr_2014_m b_mid_all_salidas_pff_2014 b_mid_all_entradas_pff_2014
	
gen post = anio_fiscal >= 2015

cap postclose ex_ante_mid_exposure
postfile ex_ante_mid_exposure str32(var) double(coef stderr N r2) using "$outdir/ex_ante_mid_exposure.dta", replace

foreach v in /*group_mid_salidas_pff_2014_m*/ group_b_mid_salidas_pff_2014 /*group_mid_entradas_pff_2014_m group_b_mid_entradas_pff_2014*/ {

	sum `v'
	loc x_max = r(max)

	foreach y in aps f101 active aps_f101 aps_f101_active porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais aps_residual_pais_other average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_conc terminal_owners_10 terminal_owners participation_prominent participation_prominent_0 participation_inv_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_100_pff intermediate_pff_max intermediate_50_prominent intermediate_100_ext intermediate_100_prominent intermediate_inv_prominent intermediate_10_inv_prominent intermediate_50_inv_prominent intermediate_100_inv_prominent empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt bf_persona_r persona_prominent bf_persona_100_r any_bf_persona_r bf_empresa_r complete_r inconsistent_r aps_residual_0_r percent_declarado_r persona_prominent_r incomplete_r aps_residual_r  mid_all_salidas_prom_rr mid_all_salidas_prom_rr_w mid_all_salidas_inv_rr mid_all_salidas_inv_rr_w mid_all_entradas_prom_rr mid_all_entradas_prom_rr_w mid_all_entradas_inv_rr mid_all_entradas_inv_rr_w mid_all_salidas_prom mid_all_salidas_inv mid_all_entradas_prom mid_all_entradas_inv mid_all_salidas_prom_w mid_all_salidas_inv_w mid_all_entradas_prom_w mid_all_entradas_inv_w {
		
		//levels
		cap n reghdfe `y' b0.i.`v'##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/ex_ante_mid_exposure.dta", append autoid addlabel(indepvar, `v', depvar, `y', spec, "levels", design, "event_study") detail(scalars)
			
		cap n reghdfe `y' b0.i.`v'##b0.i.post, cluster(firm_id) absorb(firm_id)
		
			if !_rc {
		
				forv x = 2/`x_max' {
					
					cap n lincom _b[`x'.`v'#1.post] - _b[1.`v'#1.post]
					loc dif`x' = r(estimate)
					loc dif`x'_se = r(se)
					
				}
				
				if !_rc regsave using "$outdir/ex_ante_mid_exposure.dta", append autoid addlabel(indepvar, `v', depvar, `y', spec, "levels", design, "dd", dif2, `dif2', dif2_se, `dif2_se') detail(scalars)	
			
			}
			
		//skipping if the variable is a binary variable
		qui sum `y'
		if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue
		
		cap gen l_`y' = log(`y')
		cap gen b_`y' = `y' > 0 if missing(`y') == 0 
		
		//log
		cap n reghdfe l_`y' b0.i.`v'##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
		
			if !_rc regsave using "$outdir/ex_ante_mid_exposure.dta", append autoid addlabel(indepvar, `v', depvar, `y', spec, "log", design, "event_study") detail(scalars)
			
		cap n reghdfe l_`y' b0.i.`v'##b0.i.post, cluster(firm_id) absorb(firm_id)
		
			if !_rc {
		
				forv x = 2/`x_max' {
					
					cap n lincom _b[`x'.`v'#1.post] - _b[1.`v'#1.post]
					loc dif`x' = r(estimate)
					loc dif`x'_se = r(se)
					
				}
					
				if !_rc regsave using "$outdir/ex_ante_mid_exposure.dta", append autoid addlabel(indepvar, `v', depvar, `y', spec, "log", design, "dd",  dif2, `dif2', dif2_se, `dif2_se') detail(scalars)		
				
			}	
			
		//poisson
		cap n ppmlhdfe `y' b0.i.`v'##b2014.i.anio_fiscal if `y' >= 0, cluster(firm_id) absorb(firm_id anio_fiscal)
			
			if !_rc regsave using "$outdir/ex_ante_mid_exposure.dta", append autoid addlabel(indepvar, `v', depvar, `y', spec, "poisson", design, "event_study") detail(scalars)
			
		cap n ppmlhdfe `y' b0.i.`v'##b0.i.post if `y' >= 0, cluster(firm_id) absorb(firm_id)
		
			if !_rc {
		
				forv x = 2/`x_max' {
					
					cap n lincom _b[`x'.`v'#1.post] - _b[1.`v'#1.post]
					loc dif`x' = r(estimate)
					loc dif`x'_se = r(se)
					
				}
					
				if !_rc regsave using "$outdir/ex_ante_mid_exposure.dta", append autoid addlabel(indepvar, `v', depvar, `y', spec, "poisson", design, "dd", dif2, `dif2', dif2_se, `dif2_se') detail(scalars)		
				
			}
			
		if strpos("`y'", "_rr") != 0 continue 
		
		//binary
		cap n reghdfe b_`y' b0.i.`v'##b2014.i.anio_fiscal, cluster(firm_id) absorb(firm_id anio_fiscal)
			
			if !_rc regsave using "$outdir/ex_ante_mid_exposure.dta", append autoid addlabel(indepvar, `v', depvar, `y', spec, "binary", design, "event_study") detail(scalars)
			
		cap n reghdfe b_`y' b0.i.`v'##b0.i.post, cluster(firm_id) absorb(firm_id)
		
			if !_rc {
		
				forv x = 2/`x_max' {
					
					cap n lincom _b[`x'.`v'#1.post] - _b[1.`v'#1.post]
					loc dif`x' = r(estimate)
					loc dif`x'_se = r(se)
					
				}
					
			if !_rc regsave using "$outdir/ex_ante_mid_exposure.dta", append autoid addlabel(indepvar, `v', depvar, `y', spec, "binary", design, "dd", dif2, `dif2', dif2_se, `dif2_se') detail(scalars)	
		
		}
		
	}

}	
	
cap postclose ex_ante_mid_exposure

/*
/****************/
/* DESCRIPTIVES */
/****************/

use "$datadir/main_panel.dta", replace

//keeping c_majors
keep if inlist(group, 2, 4)

gegen firm_tag = tag(firm_id)

foreach v in salidas entradas {

	bys firm_id: gegen mid_all_`v'_pff_2014 = mean(cond(anio_fiscal == 2014, mid_all_`v'_pff, .))
	bys firm_id: gegen mid_all_`v'_pff_rr_2014 = mean(cond(anio_fiscal == 2014, mid_all_`v'_pff_rr, .))

	fasterxtile mid_all_`v'_pff_rr_2014_m = mid_all_`v'_pff_rr_2014 if firm_tag == 1 & mid_all_`v'_pff_rr_2014 != 0, nq(2)
	replace mid_all_`v'_pff_rr_2014_m = 0 if mid_all_`v'_pff_rr_2014 == 0 & firm_tag == 1

	bys firm_id: ereplace mid_all_`v'_pff_rr_2014_m = mean(mid_all_`v'_pff_rr_2014_m)

}

gen b_mid_all_salidas_pff_2014 = mid_all_salidas_pff_2014 > 0 if missing(mid_all_salidas_pff_2014) == 0
gen b_mid_all_entradas_pff_2014 = mid_all_entradas_pff_2014 > 0 if missing(mid_all_entradas_pff_2014) == 0

gen group_mid_salidas_pff_2014_m = 0 if group == 2 
	replace group_mid_salidas_pff_2014_m = 1 if group == 4 & mid_all_salidas_pff_rr_2014_m == 0
	replace group_mid_salidas_pff_2014_m = 2 if group == 4 & mid_all_salidas_pff_rr_2014_m == 1
	replace group_mid_salidas_pff_2014_m = 3 if group == 4 & mid_all_salidas_pff_rr_2014_m == 2

gen group_b_mid_salidas_pff_2014 = 0 if group == 2 
	replace group_b_mid_salidas_pff_2014 = 1 if group == 4 & b_mid_all_salidas_pff_2014 == 0
	replace group_b_mid_salidas_pff_2014 = 2 if group == 4 & b_mid_all_salidas_pff_2014 == 1

gen group_mid_entradas_pff_2014_m = 0 if group == 2 
	replace group_mid_entradas_pff_2014_m = 1 if group == 4 & mid_all_entradas_pff_rr_2014_m == 0
	replace group_mid_entradas_pff_2014_m = 2 if group == 4 & mid_all_entradas_pff_rr_2014_m == 1
	replace group_mid_entradas_pff_2014_m = 3 if group == 4 & mid_all_entradas_pff_rr_2014_m == 2

gen group_b_mid_entradas_pff_2014 = 0 if group == 2 
	replace group_b_mid_entradas_pff_2014 = 1 if group == 4 & b_mid_all_entradas_pff_2014 == 0
	replace group_b_mid_entradas_pff_2014 = 2 if group == 4 & b_mid_all_entradas_pff_2014 == 1

drop firm_tag mid_all_salidas_pff_rr_2014 mid_all_salidas_pff_rr_2014_m mid_all_entradas_pff_rr_2014 mid_all_entradas_pff_rr_2014_m b_mid_all_salidas_pff_2014 b_mid_all_entradas_pff_2014
	
gen post = anio_fiscal >= 2015

compress

//need to pare down a lot

//not doing mid prominent or inverse groups, as these are implied by the groups
drop participation_inv_prominent ///
mid_div_salidas_prom mid_div_salidas_inv mid_div_entradas_prom mid_div_entradas_inv mid_fin_salidas_prom mid_fin_salidas_inv mid_fin_entradas_prom mid_fin_entradas_inv mid_all_salidas_prom mid_all_salidas_inv mid_all_entradas_prom mid_all_entradas_inv mid_div_salidas_prom_rr mid_div_salidas_prom_rr_w mid_div_salidas_inv_rr mid_div_salidas_inv_rr_w mid_div_entradas_prom_rr mid_div_entradas_prom_rr_w mid_div_entradas_inv_rr mid_div_entradas_inv_rr_w mid_fin_salidas_prom_rr mid_fin_salidas_prom_rr_w mid_fin_salidas_inv_rr mid_fin_salidas_inv_rr_w mid_fin_entradas_prom_rr mid_fin_entradas_prom_rr_w mid_fin_entradas_inv_rr mid_fin_entradas_inv_rr_w mid_all_salidas_prom_rr mid_all_salidas_prom_rr_w mid_all_salidas_inv_rr mid_all_salidas_inv_rr_w mid_all_entradas_prom_rr mid_all_entradas_prom_rr_w mid_all_entradas_inv_rr mid_all_entradas_inv_rr_w mid_all_salidas_prom_w mid_all_salidas_inv_w mid_all_entradas_prom_w mid_all_entradas_inv_w mid_div_salidas_prom_w mid_div_salidas_inv_w mid_div_entradas_prom_w mid_div_entradas_inv_w mid_fin_salidas_prom_w mid_fin_salidas_inv_w mid_fin_entradas_prom_w mid_fin_entradas_inv_w 

//other drops
drop group_assign group treatment_major treatment_minor exposure prominent_2014 tasa_vigente t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt prominent_2012_2014 porcion_comp_soc_no_inf_3576 porcion_comp_soc_si_inf_3578 aps_residual_pais_other porcentaje_vac beneficiarios_vac beneficiarios_10_vac intermediate_vac intermediate_10_vac intermediate_50_vac dummy_utilidad dummy_cero firm_id

cap drop exclusion_motive

//dropping winsorized variables, as just trying to describe raw variables
drop current_investment_w activos_c_w total_activos_fijos_690_w activos_intangibles_alt_w total_activos_lp_1070_w total_assets_w passive_c_w total_pasivos_int_1600_w total_passive_w total_capital_w dividendos_percibidos_w revenue_w total_cost_expenses_w gross_profit_w perdida_ejercicio_3430_w participacion_tbj_15_3440_w taxable_profits_w perdida_3570_w uti_reinvertir_cpz_3580_w cit_liability_w impuesto_renta_pagar_3680_w agregated_debt_int_w local_related_w local_unrelated_w foreign_related_w foreign_unrelated_w passive_c_related_local_w passive_c_unrelated_local_w passive_c_related_ext_w passive_c_unrelated_ext_w passive_l_related_local_w passive_l_unrelated_local_w passive_l_related_ext_w passive_l_unrelated_ext_w activos_intangibles_w investments_w inversiones_no_corrientes_w inversiones_lp_rel_w active_c_related_local_w active_c_unrelated_local_w active_c_related_ext_w active_c_unrelated_ext_w active_l_related_local_w active_l_unrelated_local_w active_l_related_ext_w active_l_unrelated_ext_w total_activos_netos_w debt_ratio_w tot_currentassets_net_w net_active_c_related_local_w net_active_c_unrel_local_w net_active_c_related_ext_w net_active_c_unrelated_ext_w net_active_l_related_local_w net_active_l_unrel_local_w net_active_l_related_ext_w net_active_l_unrelated_ext_w pagos_locales_w pagos_extranjeros_w labor_cost_w gastos_lab_w costos_lab_w exports_w local_sales_w total_sales_w labor_ratio_w taxable_profit_margin_w gross_profit_margin_w return_on_assets_w tasa_ir_w mid_div_salidas_pff_w mid_div_salidas_ext_w mid_div_entradas_pff_w mid_div_entradas_ext_w mid_fin_salidas_pff_w mid_fin_salidas_ext_w mid_fin_entradas_pff_w mid_fin_entradas_ext_w mid_all_salidas_pff_w mid_all_salidas_ext_w mid_all_entradas_pff_w mid_all_entradas_ext_w mid_fin_salidas_total_w mid_fin_entradas_total_w mid_div_salidas_total_w mid_div_entradas_total_w mid_all_salidas_total_w mid_all_entradas_total_w

gen count = 1

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

foreach d in group_mid_salidas_pff_2014_m group_b_mid_salidas_pff_2014 group_mid_entradas_pff_2014_m group_b_mid_entradas_pff_2014 {
	
	//reset variable collectors
	local meanlist = ""
	local sdlist = ""
	local p10list = ""
	local p50list = ""
	local p90list = ""
	
	preserve 
		
		ds count group_mid_salidas_pff_2014_m group_b_mid_salidas_pff_2014 group_mid_entradas_pff_2014_m group_b_mid_entradas_pff_2014 anio_fiscal, not

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

		gcollapse (sum) count (mean) `meanlist' (sd) `sdlist' (p10) `p10list' (p50) `p50list' (p90) `p90list', by(`d' anio_fiscal)

		save "$outdir/ex_ante_mid_exposure_collapsed_`d'.dta", replace

	restore
	
}
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

di "file ex_ante_mid_exposure has terminated successfully"

cap log close
clear
