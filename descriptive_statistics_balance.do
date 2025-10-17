cap clear all
set more off
cap log close
set varabbrev off

loc extract_date = "20251017"

/***********/
/* HISTORY */
/***********/
	
//20250615: four parts: 
	//1. descriptive statistics, variables collapsed by group X year
	//2. balance tests on observable characteristics among sample cuts
	//3. meta-extensive margin counts by year
	//4. balance tests of tmaj v. cmaj, tmin v. cmin, dominant v. domestic, minority v. domsestic
	
//20250617: adding on histograms of haven exits by group X year
	//adding on tabulation of most common sectors by group

//20250620: adding histograms of prominent group by group X year
	
//20250721: fixing industries and adding on a complete/incomplete balance test	
	
//20250728: adding on a 2012-2014 mid table
	
//20251017: adding on a set of results for meta-extensive margin entry and exit
	
/*********/
/* NOTES */
/*********/

/*
net install ftools, from("F:\DTO_ESTUDIOS_E1_ext2\B_INVESTIGADORES_EXTERNOS\B202106_JAKOB_BROUNSTEIN\Ado\ado_1\install\ftools_src_v2") replace
net install gtools, from("F:\DTO_ESTUDIOS_E1_ext2\B_INVESTIGADORES_EXTERNOS\B202106_JAKOB_BROUNSTEIN\Ado\ado_1\install\gtools_build") replace
*/

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

//log using "$outdir/descriptive_statistics_balance_`today'.smcl", replace

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
sysdir set PLUS c:\ado\plus\
sysdir set PERSONAL C:\Users\usuarioexterno\ado\personal\

//alt
/*
glob localdir "F:\DTO_ESTUDIOS_E1_ext2\B_INVESTIGADORES_EXTERNOS\B202106_JAKOB_BROUNSTEIN"
sysdir set PLUS F:\DTO_ESTUDIOS_E1_ext2\B_INVESTIGADORES_EXTERNOS\B202106_JAKOB_BROUNSTEIN\Ado\ado_1\plus
sysdir set PERSONAL F:\DTO_ESTUDIOS_E1_ext2\B_INVESTIGADORES_EXTERNOS\B202106_JAKOB_BROUNSTEIN\Ado\ado\plus
*/

glob logdir "$localdir\logs"
glob dumpdir "$localdir\dump"
glob datadir "$localdir/data/transparency"
glob graphdir "$localdir/out"
glob texdir "$localdir/out"

//export directory
cap n mkdir "$localdir/resultados/`extract_date'"
cap n mkdir "$localdir/resultados/`extract_date'/reportes"
glob outdir "$localdir/resultados/`extract_date'/reportes"

log using "$outdir/descriptive_statistics_balance_`today'.smcl", replace

timer clear
timer on 1  

/******************************************/
/******************************************/
/* DESCRIPTIVE STATISTICS AND TIME SERIES */
/******************************************/
/******************************************/

use "$datadir/core_panel.dta", replace

merge 1:1 firm_id anio_fiscal using "$datadir/main_panel.dta", nogen keep(1 3 4 5) keepus(intermediate_inv_prominent intermediate_10_inv_prominent intermediate_50_inv_prominent intermediate_100_inv_prominent has_maingroup_shareholder_2014 has_maingroup_plur_sh_2014 persona_inverse_prominent persona_inverse_prominent_r terminal_owners_inv_prom terminal_owners_10_inv_prom intermediate_inv_prom_int intermediate_10_inv_prom_int intermediate_50_inv_prom_int intermediate_100_inv_prom_int) update replace

merge 1:1 firm_id anio_fiscal using "$datadir/main_panel.dta", nogen keep(1 3 4) keepus(intermediate_100_inv_prom_int intermediate_100_prom_int intermediate_50_inv_prom_int intermediate_50_prom_int intermediate_10_inv_prom_int intermediate_10_prom_int intermediate_inv_prom_int intermediate_prom_int intermediate_prom_alt intermediate_inv_prom_alt intermediate_10_prom_alt intermediate_10_inv_prom_alt intermediate_50_prom_alt intermediate_50_inv_prom_alt intermediate_100_prom_alt intermediate_100_inv_prom_alt intermediate_100_ext_alt intermediate_100_pff_alt intermediate_50_ext_alt intermediate_50_pff_alt intermediate_10_ext_alt intermediate_10_pff_alt intermediate_ext_alt intermediate_pff_alt intermediate_100_ext_int intermediate_100_pff_int intermediate_50_ext_int intermediate_50_pff_int intermediate_10_ext_int intermediate_10_pff_int intermediate_ext_int intermediate_pff_int) update

//need to pare down a lot

//not doing mid prominent or inverse groups, as these are implied by the groups
drop participation_inv_prominent ///
mid_div_salidas_prom mid_div_salidas_inv mid_div_entradas_prom mid_div_entradas_inv mid_fin_salidas_prom mid_fin_salidas_inv mid_fin_entradas_prom mid_fin_entradas_inv mid_all_salidas_prom mid_all_salidas_inv mid_all_entradas_prom mid_all_entradas_inv mid_div_salidas_prom_rr mid_div_salidas_prom_rr_w mid_div_salidas_inv_rr mid_div_salidas_inv_rr_w mid_div_entradas_prom_rr mid_div_entradas_prom_rr_w mid_div_entradas_inv_rr mid_div_entradas_inv_rr_w mid_fin_salidas_prom_rr mid_fin_salidas_prom_rr_w mid_fin_salidas_inv_rr mid_fin_salidas_inv_rr_w mid_fin_entradas_prom_rr mid_fin_entradas_prom_rr_w mid_fin_entradas_inv_rr mid_fin_entradas_inv_rr_w mid_all_salidas_prom_rr mid_all_salidas_prom_rr_w mid_all_salidas_inv_rr mid_all_salidas_inv_rr_w mid_all_entradas_prom_rr mid_all_entradas_prom_rr_w mid_all_entradas_inv_rr mid_all_entradas_inv_rr_w mid_all_salidas_prom_w mid_all_salidas_inv_w mid_all_entradas_prom_w mid_all_entradas_inv_w mid_div_salidas_prom_w mid_div_salidas_inv_w mid_div_entradas_prom_w mid_div_entradas_inv_w mid_fin_salidas_prom_w mid_fin_salidas_inv_w mid_fin_entradas_prom_w mid_fin_entradas_inv_w 

//other drops
drop tasa_vigente treatment_major treatment_minor exposure prominent_2014 t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt prominent_2012_2014 porcion_comp_soc_no_inf_3576 porcion_comp_soc_si_inf_3578 aps_residual_pais_other porcentaje_vac beneficiarios_vac beneficiarios_10_vac intermediate_vac intermediate_10_vac intermediate_50_vac dummy_utilidad dummy_cero firm_id group_assign

//dropping some winsorized variables, as just trying to describe raw variables
drop current_investment_w activos_c_w total_activos_fijos_690_w activos_intangibles_alt_w total_activos_lp_1070_w passive_c_w total_pasivos_int_1600_w total_passive_w total_capital_w dividendos_percibidos_w perdida_ejercicio_3430_w participacion_tbj_15_3440_w perdida_3570_w uti_reinvertir_cpz_3580_w impuesto_renta_pagar_3680_w agregated_debt_int_w local_related_w local_unrelated_w foreign_related_w foreign_unrelated_w passive_c_related_local_w passive_c_unrelated_local_w passive_c_related_ext_w passive_c_unrelated_ext_w passive_l_related_local_w passive_l_unrelated_local_w passive_l_related_ext_w passive_l_unrelated_ext_w activos_intangibles_w investments_w inversiones_no_corrientes_w inversiones_lp_rel_w active_c_related_local_w active_c_unrelated_local_w active_c_related_ext_w active_c_unrelated_ext_w active_l_related_local_w active_l_unrelated_local_w active_l_related_ext_w active_l_unrelated_ext_w total_activos_netos_w tot_currentassets_net_w net_active_c_related_local_w net_active_c_unrel_local_w net_active_c_related_ext_w net_active_c_unrelated_ext_w net_active_l_related_local_w net_active_l_unrel_local_w net_active_l_related_ext_w net_active_l_unrelated_ext_w pagos_locales_w pagos_extranjeros_w gastos_lab_w costos_lab_w local_sales_w total_sales_w mid_div_salidas_pff_w mid_div_salidas_ext_w mid_div_entradas_pff_w mid_div_entradas_ext_w mid_fin_salidas_pff_w mid_fin_salidas_ext_w mid_fin_entradas_pff_w mid_fin_entradas_ext_w mid_fin_salidas_total_w mid_fin_entradas_total_w mid_div_salidas_total_w mid_div_entradas_total_w

gen count = 1

foreach v in gross_profit_margin_w_alt gross_profit_margin gross_profit_margin_w return_on_assets_w_alt return_on_assets return_on_assets_w roa_2014 roa_2014_w_alt roa_2014_w porcentaje_pff porcentaje_nac porcentaje_ext current_investment activos_c total_activos_fijos_690 activos_intangibles_alt total_activos_lp_1070 total_assets total_assets_w passive_c total_pasivos_int_1600 total_passive total_capital dividendos_percibidos revenue revenue_w total_cost_expenses total_cost_expenses_w gross_profit gross_profit_w perdida_ejercicio_3430 participacion_tbj_15_3440 taxable_profits perdida_3570 uti_reinvertir_cpz_3580 cit_liability cit_liability_w tasa_ir impuesto_renta_pagar_3680 agregated_debt_int local_related local_unrelated foreign_related foreign_unrelated passive_c_related_local passive_c_unrelated_local passive_c_related_ext passive_c_unrelated_ext passive_l_related_local passive_l_unrelated_local passive_l_related_ext passive_l_unrelated_ext activos_intangibles investments inversiones_no_corrientes inversiones_lp_rel active_c_related_local active_c_unrelated_local active_c_related_ext active_c_unrelated_ext active_l_related_local active_l_unrelated_local active_l_related_ext active_l_unrelated_ext total_activos_netos tot_currentassets_net net_active_c_related_local net_active_c_unrel_local net_active_c_related_ext net_active_c_unrelated_ext net_active_l_related_local net_active_l_unrel_local net_active_l_related_ext net_active_l_unrelated_ext pagos_locales pagos_extranjeros labor_cost labor_cost_w gastos_lab costos_lab exports exports_w local_sales total_sales taxable_profit_margin mid_div_salidas_pff mid_div_salidas_ext mid_div_entradas_pff mid_div_entradas_ext mid_fin_salidas_pff mid_fin_salidas_ext mid_fin_entradas_pff mid_fin_entradas_ext mid_all_salidas_pff mid_all_salidas_ext mid_all_entradas_pff mid_all_entradas_ext mid_fin_salidas_total mid_fin_entradas_total mid_div_salidas_total mid_div_entradas_total mid_all_salidas_total mid_all_entradas_total dividends_w domestic_dividends_w retained_earnings_w profits_accumulated_w dividends domestic_dividends retained_earnings profits_accumulated {
	
	qui sum `v'
	if r(sd) == 0 continue
	
	cap n gen l_`v' = log(`v')
	
}

//smaller set for binaries
foreach v in mid_div_salidas_pff mid_div_salidas_ext mid_div_entradas_pff mid_div_entradas_ext mid_fin_salidas_pff mid_fin_salidas_ext mid_fin_entradas_pff mid_fin_entradas_ext mid_all_salidas_pff mid_all_salidas_ext mid_all_entradas_pff mid_all_entradas_ext mid_fin_salidas_total mid_fin_entradas_total mid_div_salidas_total mid_div_entradas_total mid_all_salidas_total mid_all_entradas_total gross_profit taxable_profits cit_liability dividends domestic_dividends {

	qui sum `v'
	if r(sd) == 0 continue
	
	cap n gen b_`v' = (`v') > 0 if missing(`v') == 0
	
}

drop *net_active*
drop *div_entradas*
drop *fin_entradas*

ds count group anio_fiscal, not

foreach v in `r(varlist)' {
		
	loc l = length("`v'")
	if `l' >= 31 continue
	
	local meanlist = "`meanlist'"+ " m_`v' = `v'"
	local countlist = "`countlist'"+ " c_`v' = `v'"
	
	//not producing percentiles or sd for binaries
	if substr("`v'", 1, 2) == "b_"  continue
	
	qui sum `v'
	if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue
	
	local sdlist = "`sdlist'" + " s_`v' = `v'"
	local p10list = "`p10list'" + " `v'10 = `v'"
	local p50list = "`p50list'" + " `v'50 = `v'"
	local p90list = "`p90list'" + " `v'90 = `v'"
	local p99list = "`p99list'"+ " `v'99 = `v'"
	local maxlist = "`maxlist'"+ " u_`v' = `v'"
	local minlist = "`minlist'"+ " b_`v' = `v'"
	
}

//BY GROUP X YEAR
preserve

	gcollapse (sum) count (mean) `meanlist' (sd) `sdlist' (p10) `p10list' (p50) `p50list' (p90) `p90list', by(group anio_fiscal)

	save "$outdir/core_time_series.dta", replace

restore	

preserve

	gcollapse (sum) count (count) `countlist' (min) `minlist' (max) `maxlist' (p99) `p99list', by(group anio_fiscal) 

	save "$outdir/core_time_series_meta.dta", replace
	
restore	

//BY YEAR
preserve

	gcollapse (sum) count (mean) `meanlist' (sd) `sdlist' (p10) `p10list' (p50) `p50list' (p90) `p90list', by(anio_fiscal)

	save "$outdir/core_time_series_all.dta", replace

restore	

preserve

	gcollapse (sum) count (count) `countlist' (min) `minlist' (max) `maxlist' (p99) `p99list', by(anio_fiscal) 

	save "$outdir/core_time_series_meta_all.dta", replace
	
restore	
	
local meanlist = ""
local countlist = ""
local sdlist = ""
local p10list = ""
local p50list = ""
local p90list = ""
local minlist = ""
local maxlist = ""
local p99list = ""

/*
/*******************************/
/*******************************/
/* BALANCE BY SAMPLE CUTS 2014 */
/*******************************/
/*******************************/

///
//F101 NON-APS V. CORE SAMPLE
///

use "$datadir/f101_processed.dta", clear

gen f101_check = 1

merge 1:1 firm_id anio_fiscal using "$datadir/panel_aps_f101_filing.dta", gen(panel_aps_merge) keep(1 2 3) //firms can come from either f101 or the aps panel
merge 1:1 firm_id anio_fiscal using "$datadir/mid_processed.dta", nogen keep(1 3) //excluding firms in the MID that do not appear in the APS or the F101
merge 1:1 firm_id anio_fiscal using "$datadir/all_aps_sample_processed.dta", nogen keep(1 3) //the firms that don't match onto the f101 should match onto the file panel_aps_f101_filing

gen panel_aps_check = panel_aps_merge == 2

//PURELY CROSS SECTIONAL
keep if anio_fiscal == 2014

cap drop porcion_comp_soc_no_inf_3576 porcion_comp_soc_si_inf_3578 anio_fiscal

//three groups compared to core sample

//1. excluded from consideration due to industry
//2. excluded from core sample due to lack of APS
//3. excluded from core sample due to inactive f101 in 2014
//4. auxiliary: incomplete versus non-incomplete

drop group_assign

foreach v in current_investment activos_c total_activos_fijos_690 activos_intangibles_alt total_activos_lp_1070 total_assets passive_c total_pasivos_int_1600 total_passive total_capital dividendos_percibidos revenue total_cost_expenses gross_profit perdida_ejercicio_3430 participacion_tbj_15_3440 taxable_profits perdida_3570 uti_reinvertir_cpz_3580 cit_liability impuesto_renta_pagar_3680 agregated_debt_int local_related local_unrelated foreign_related foreign_unrelated passive_c_related_local passive_c_unrelated_local passive_c_related_ext passive_c_unrelated_ext passive_l_related_local passive_l_unrelated_local passive_l_related_ext passive_l_unrelated_ext activos_intangibles investments inversiones_no_corrientes inversiones_lp_rel active_c_related_local active_c_unrelated_local active_c_related_ext active_c_unrelated_ext active_l_related_local active_l_unrelated_local active_l_related_ext active_l_unrelated_ext total_activos_netos debt_ratio tot_currentassets_net net_active_c_related_local net_active_c_unrel_local net_active_c_related_ext net_active_c_unrelated_ext net_active_l_related_local net_active_l_unrel_local net_active_l_related_ext net_active_l_unrelated_ext pagos_locales pagos_extranjeros labor_cost gastos_lab costos_lab exports local_sales total_sales labor_ratio taxable_profit_margin gross_profit_margin return_on_assets tasa_vigente tasa_ir mid_div_salidas_pff mid_div_salidas_ext mid_div_entradas_pff mid_div_entradas_ext mid_fin_salidas_pff mid_fin_salidas_ext mid_fin_entradas_pff mid_fin_entradas_ext mid_all_salidas_pff mid_all_salidas_ext mid_all_entradas_pff mid_all_entradas_ext mid_fin_salidas_total mid_fin_entradas_total mid_div_salidas_total mid_div_entradas_total mid_all_salidas_total mid_all_entradas_total {

	cap n gen l_`v' = log(`v')
	
}

//smaller set for binaries
foreach v in mid_div_salidas_pff mid_div_salidas_ext mid_div_entradas_pff mid_div_entradas_ext mid_fin_salidas_pff mid_fin_salidas_ext mid_fin_entradas_pff mid_fin_entradas_ext mid_all_salidas_pff mid_all_salidas_ext mid_all_entradas_pff mid_all_entradas_ext mid_fin_salidas_total mid_fin_entradas_total mid_div_salidas_total mid_div_entradas_total mid_all_salidas_total mid_all_entradas_total gross_profit taxable_profits cit_liability {
	
		cap n gen b_`v' = (`v') > 0 if missing(`v') == 0
	
}

foreach v in mid_div_salidas_pff mid_div_salidas_ext mid_div_entradas_pff mid_div_entradas_ext mid_fin_salidas_pff mid_fin_salidas_ext mid_fin_entradas_pff mid_fin_entradas_ext mid_all_salidas_pff mid_all_salidas_ext mid_all_entradas_pff mid_all_entradas_ext mid_fin_salidas_total mid_fin_entradas_total mid_div_salidas_total mid_div_entradas_total mid_all_salidas_total mid_all_entradas_total {
	
	replace `v' = 0 if missing(`v')
	
	gen `v'_rr = `v' / revenue
	
	gen `v'_rr_w = `v'_rr
		replace `v'_rr_w = 1 if `v'_rr_w > 1 & missing(`v'_rr_w) == 0
		replace `v'_rr_w = . if `v'_rr_w < 0 & missing(`v'_rr_w) == 0
}

///
//1a. excluded from consideration due to industry, disaggregated
///

cap drop group

gegen group = group(exclusion_motive)
labmask group, values(exclusion_motive)

//this gives the core sample: 62350 firms
replace group = 0 if aps_2012_2014 & active & exclusion_motive == ""

sum group
replace group = r(max) + 1 if missing(group) & panel_aps_check == 0
replace group = r(max) + 2 if missing(group)

ds firm_id exclusion_motive group, not

cap postclose bal_core_v_excl_industry_disagg
postfile bal_core_v_excl_industry_disagg str32(var) double(coef stderr N r2) using "$outdir/bal_core_v_excl_industry_disagg.dta", replace

ds firm_id exclusion_motive group, not
foreach v in `r(varlist)' {
	
	cap n reg `v' b0.i.group, r
	if !_rc regsave using "$outdir/bal_core_v_excl_industry_disagg.dta", append autoid addlabel(depvar, `v') detail(scalars)	
	
}

cap postclose bal_core_v_excl_industry_disag

local meanlist = ""
local sdlist = ""
	
preserve

	gen count = 1
		
	ds firm_id exclusion_motive group, not
	foreach v in `r(varlist)' {
		
		loc l = length("`v'")
		if `l' >= 31 continue
		
		local meanlist = "`meanlist'"+ " m_`v' = `v'"
		local sdlist = "`sdlist'" + " s_`v' = `v'"
		
	}
	
	gcollapse (sum) count (mean) `meanlist' (sd) `sdlist', by(group)

	save "$outdir/bal_core_v_excl_industry_disagg_collapsed.dta", replace
	
restore	

///
//1b. excluded from consideration due to industry, aggregated
///

cap drop group

//this gives the core sample: 62350 firms
gen group = 0 if aps_2012_2014 & active & exclusion_motive == "" & panel_aps_check == 0
	replace group = 1 if missing(exclusion_motive) == 0 & panel_aps_check == 0
	replace group = 2 if missing(group) & panel_aps_check == 0
	replace group = 3 if missing(group)
	
sum group
replace group = r(max) + 1 if missing(group)

ds firm_id exclusion_motive group, not

cap postclose bal_core_v_excl_industry_agg
postfile bal_core_v_excl_industry_agg str32(var) double(coef stderr N r2) using "$outdir/bal_core_v_excl_industry_agg.dta", replace

foreach v in `r(varlist)' {
	
	cap n reg `v' b0.i.group, r
	if !_rc regsave using "$outdir/bal_core_v_excl_industry_agg.dta", append autoid addlabel(depvar, `v') detail(scalars)	
	
}

cap postclose bal_core_v_excl_industry_agg
	
local meanlist = ""
local sdlist = ""

preserve

	gen count = 1
			
	ds firm_id exclusion_motive group, not
	foreach v in `r(varlist)' {
		
		loc l = length("`v'")
		if `l' >= 31 continue
		
		local meanlist = "`meanlist'"+ " m_`v' = `v'"
		local sdlist = "`sdlist'" + " s_`v' = `v'"
		
	}
	
	gcollapse (sum) count (mean) `meanlist' (sd) `sdlist', by(group)

	save "$outdir/bal_core_v_excl_industry_agg_collapsed.dta", replace
	
restore	

///
//2. excluded from consideration due to no aps
///

drop group

//this gives the core sample: 62350 firms
gen group = 0 if aps_2012_2014 & active & exclusion_motive == ""
	replace group = 1 if aps_2012_2014 == 0 & panel_aps_check == 0
	replace group = 2 if missing(group)	& panel_aps_check == 0
	replace group = 3 if missing(group)
	
ds firm_id exclusion_motive group, not

cap postclose balance_core_v_excluded_noaps
postfile balance_core_v_excluded_noaps str32(var) double(coef stderr N r2) using "$outdir/balance_core_v_excluded_noaps.dta", replace

foreach v in `r(varlist)' {
	
	cap n reg `v' b0.i.group, r
	if !_rc regsave using "$outdir/balance_core_v_excluded_noaps.dta", append autoid addlabel(depvar, `v') detail(scalars)	
	
}

cap postclose balance_core_v_excluded_noaps
	
local meanlist = ""
local sdlist = ""

preserve

	gen count = 1
	
	ds firm_id exclusion_motive group, not
	foreach v in `r(varlist)' {	
		
		loc l = length("`v'")
		if `l' >= 31 continue
		
		local meanlist = "`meanlist'"+ " m_`v' = `v'"
		local sdlist = "`sdlist'" + " s_`v' = `v'"
		
	}
	
	gcollapse (sum) count (mean) `meanlist' (sd) `sdlist', by(group)

	lab def groups 0 "Core sample" 1 "No APS from 2012-2014" 2 "Other"
	lab val group groups
	
	save "$outdir/balance_core_v_excluded_noaps_collapsed.dta", replace
	
restore	

///
//3. excluded from core sample due to inactive f101 in 2014
///

drop group

//this gives the core sample: 62350 firms
gen group = 0 if aps_2012_2014 & active & exclusion_motive == "" & panel_aps_check == 0
	replace group = 1 if active_2014 == 0 & panel_aps_check == 0
	replace group = 2 if missing(group) & panel_aps_check == 0	
	replace group = 3 if missing(group)
	
ds firm_id exclusion_motive group, not

cap postclose balance_core_v_excluded_inactive
postfile balance_core_v_excluded_inactive str32(var) double(coef stderr N r2) using "$outdir/balance_core_v_excluded_inactive.dta", replace

foreach v in `r(varlist)' {
	
	cap n reg `v' b0.i.group, r
	if !_rc regsave using "$outdir/balance_core_v_excluded_inactive.dta", append autoid addlabel(depvar, `v') detail(scalars)	
	
}

cap postclose balance_core_v_excluded_inactive
	
local meanlist = ""
local sdlist = ""

preserve

	gen count = 1
			
	ds firm_id exclusion_motive group, not
	foreach v in `r(varlist)' {
		
		loc l = length("`v'")
		if `l' >= 31 continue
		
		local meanlist = "`meanlist'"+ " m_`v' = `v'"
		local sdlist = "`sdlist'" + " s_`v' = `v'"
		
	}
	
	gcollapse (sum) count (mean) `meanlist' (sd) `sdlist', by(group)

	lab def groups 0 "Core sample" 1 "Inactive firm" 2 "Other"
	lab val group groups
	
	save "$outdir/balance_core_v_excluded_inactive_collapsed.dta", replace
	
restore	

/******************************************************/
/* BALANCE ON OBSERVABLES WITHIN CORE BY COMPLETE APS */
/******************************************************/

foreach d in incomplete group_incomplete { 
	
	local meanlist = ""
	local sdlist = ""

	use if anio_fiscal == 2014 using "$datadir/core_panel.dta", clear
	
	foreach v in porcentaje_pff porcentaje_ext porcentaje_nac bf_persona max_shareholder terminal_ownership_conc {
	
		gen `v'_ds = `v' / percent_declarado * 100
	
	}
	
	gen group_incomplete = group == 0

	cap postclose balance_`d'
	postfile balance_`d' str32(var) double(coef stderr N r2) using "$outdir/balance_`d'.dta", replace

	ds firm_id anio_fiscal group_incomplete incomplete group_assign group treatment_minor exposure prominent_2014 t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt prominent_2012_2014 porcion_comp_soc_no_inf_3576 porcion_comp_soc_si_inf_3578, not

	foreach y in `r(varlist)' { 
		
		//levels
		cap n reg `y' b0.i.`d', r
		
			if !_rc regsave using "$outdir/balance_`d'.dta", append autoid addlabel(depvar, `y', spec, "levels", indepvar, `d') detail(scalars)	

		//skipping if the variable is a binary variable
		qui sum `y'
		if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue

		cap gen l_`y' = log(`y')
		cap gen b_`y' = `y' > 0 if missing(`y') == 0
		
		//log
		cap n reg l_`y' b0.i.`d', r
		
			if !_rc regsave using "$outdir/balance_`d'.dta", append autoid addlabel(depvar, `y', spec, "log", indepvar, `d') detail(scalars)	
			
		//binary
		cap n reg b_`y' b0.i.`d', r
		
			if !_rc regsave using "$outdir/balance_`d'.dta", append autoid addlabel(depvar, `y', spec, "binary", indepvar, `d') detail(scalars)	
		
	}

	cap postclose balance_`d'
	
	cap drop count
	gen count = 1

	cap drop b_*_w
	cap drop b_*_rr
	cap drop *_rr
		
	ds firm_id anio_fiscal group_incomplete incomplete group_assign group treatment_minor exposure prominent_2014 t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt prominent_2012_2014 porcion_comp_soc_no_inf_3576 porcion_comp_soc_si_inf_3578, not
	
	foreach v in `r(varlist)' {	
				
		loc l = length("`v'")
		if `l' >= 31 continue
		
		local meanlist = "`meanlist'"+ " m_`v' = `v'"
		local sdlist = "`sdlist'" + " s_`v' = `v'"
		
	}
	
	gcollapse (sum) count (mean) `meanlist' (sd) `sdlist', by(`d')

	lab def groups 0 "Complete" 1 "Incomplete"
	lab val `d' groups
	
	save "$outdir/balance_`d'_collapsed.dta", replace

}

/******************/ 
/* MID VALIDATION */
/******************/

use if anio_fiscal <= 2014 using "$datadir/core_panel.dta", replace

//smaller set for binaries
foreach v in mid_all_salidas_pff mid_all_salidas_ext mid_all_entradas_pff mid_all_entradas_ext {
	
	cap n gen b_`v' = (`v') > 0 if missing(`v') == 0
	
}

keep firm_id group anio_fiscal b_mid_all_salidas_pff mid_all_salidas_pff_rr_w b_mid_all_entradas_pff mid_all_entradas_pff_rr_w b_mid_all_salidas_ext mid_all_salidas_ext_rr_w b_mid_all_entradas_ext mid_all_entradas_ext_rr_w

foreach v in b_mid_all_salidas_pff mid_all_salidas_pff_rr_w b_mid_all_entradas_pff mid_all_entradas_pff_rr_w b_mid_all_salidas_ext mid_all_salidas_ext_rr_w b_mid_all_entradas_ext mid_all_entradas_ext_rr_w {
	
	bys firm_id: gegen `v'_avg = mean(cond(inrange(anio_fiscal, 2012, 2014), `v', .))

	if substr("`v'", 1, 2) == "b_" bys firm_id: gegen `v'_any = max(cond(inrange(anio_fiscal, 2012, 2014), `v', .))
	
}

gduplicates drop firm_id, force

keep group b_mid_all_salidas_pff_avg b_mid_all_salidas_pff_any mid_all_salidas_pff_rr_w_avg b_mid_all_entradas_pff_avg b_mid_all_entradas_pff_any mid_all_entradas_pff_rr_w_avg b_mid_all_salidas_ext_avg b_mid_all_salidas_ext_any mid_all_salidas_ext_rr_w_avg b_mid_all_entradas_ext_avg b_mid_all_entradas_ext_any mid_all_entradas_ext_rr_w_avg

local meanlist = ""
local sdlist = ""
	
preserve

	gen count = 1
		
	ds group, not
	foreach v in `r(varlist)' {
		
		loc l = length("`v'")
		if `l' >= 31 continue
		
		local meanlist = "`meanlist'"+ " m_`v' = `v'"
		local sdlist = "`sdlist'" + " s_`v' = `v'"
		
	}  
	
	gcollapse (sum) count (mean) `meanlist' (sd) `sdlist', by(group)

	save "$outdir/mid_validation_allgroups.dta", replace
	
restore	

gen group_broad = 0 if inlist(group, 2, 3)
	replace group_broad = 1 if inlist(group, 4, 5)
	replace group_broad = 2 if missing(group_broad)
	
local meanlist = ""
local sdlist = ""
	
preserve

	gen count = 1
		
	ds group_broad group, not
	foreach v in `r(varlist)' {
		
		loc l = length("`v'")
		if `l' >= 31 continue
		
		local meanlist = "`meanlist'"+ " m_`v' = `v'"
		local sdlist = "`sdlist'" + " s_`v' = `v'"
		
	}
	
	gcollapse (sum) count (mean) `meanlist' (sd) `sdlist', by(group_broad)

	save "$outdir/mid_validation_group_broad.dta", replace
	
restore	
*/

/****************/
/* META BALANCE */
/****************/

//three version of meta balance
//1. number of firms by group only using the aps
//2. number of firms by group using aps merged to f101
//3. number of firms by group using aps and f101 within included industries, include revenues and 

//with two permutations:
//a. using raw aps
//b. using the aps forwarded

//in all of these, need to carry forward the domicile values if an APS is missing

use "$datadir/aps_processed.dta", clear

replace paraiso_fiscal_accionista = "" if pais_accionista_unico == "ITALIA"

merge m:1 firm_id anio_fiscal using "$datadir/f101_processed.dta", gen(f101_merge) keepus(total_assets)

//GENERATE TERMINAL OWNERSHIP VARIABLES 
//percentage
bys firm_id anio_fiscal: gegen porcentaje_pff = total(cond(paraiso_fiscal_accionista == "S", porcentaje_efectivo, .)) 
bys firm_id anio_fiscal: gegen porcentaje_ext = total(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico != "ECUADOR", porcentaje_efectivo, .))
bys firm_id anio_fiscal: gegen porcentaje_nac = total(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico == "ECUADOR", porcentaje_efectivo, .))
bys firm_id anio_fiscal: gegen porcentaje_vac = total(cond(paraiso_fiscal_accionista == "" & pais_accionista_unico == "", porcentaje_efectivo, .))	
	
//total ownership, pathological ownership
bys firm_id anio_fiscal: gegen total_terminal_ownership = total(porcentaje_efectivo)
gen percent_declarado = porcentaje_pff + porcentaje_ext + porcentaje_nac //porcentaje_vac 
	gen incomplete = percent_declarado < 100
	gen complete = percent_declarado == 100
	gen inconsistent = percent_declarado > 100

//resolve pathological cases		
replace porcentaje_efectivo = porcentaje_efectivo * (100 / percent_declarado) if inconsistent == 1
	bys firm_id anio_fiscal: ereplace porcentaje_pff = total(cond(paraiso_fiscal_accionista == "S", porcentaje_efectivo, .)) if inconsistent == 1
	bys firm_id anio_fiscal: ereplace porcentaje_ext = total(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico != "ECUADOR", porcentaje_efectivo, .)) if inconsistent == 1
	bys firm_id anio_fiscal: ereplace porcentaje_nac = total(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico == "ECUADOR", porcentaje_efectivo, .)) if inconsistent == 1
	bys firm_id anio_fiscal: ereplace porcentaje_vac = total(cond(paraiso_fiscal_accionista == "" & pais_accionista_unico == "", porcentaje_efectivo, .)) if inconsistent == 1

gcollapse (firstnm)	porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac, by(firm_id anio_fiscal)

bys firm_id: gegen year_earliest = min(anio_fiscal)
bys firm_id: gegen year_latest = max(anio_fiscal)

fillin firm_id anio_fiscal

///
//generating groups
///

gen t_major = (porcentaje_pff >= 50) if missing(porcentaje_pff) == 0
gen t_minor = (porcentaje_pff > 5 & porcentaje_pff < 50) if missing(porcentaje_pff) == 0
gen c_major = (porcentaje_ext >= 50 & porcentaje_pff < 5) if (missing(porcentaje_pff) == 0 & missing(porcentaje_ext) == 0)
gen c_minor = ((porcentaje_ext > 5 & porcentaje_ext < 50) & porcentaje_pff < 5) if (missing(porcentaje_pff) == 0 & missing(porcentaje_ext) == 0)
gen domestic = (porcentaje_ext < 0.0005 & porcentaje_pff < 0.0005) if (missing(porcentaje_pff) == 0 & missing(porcentaje_ext) == 0)
gen c_domestic = (porcentaje_nac > 95) if missing(porcentaje_nac) == 0

cap gen total_percent = porcentaje_ext + porcentaje_pff + porcentaje_nac 
cap gen incomplete = total_percent < 100

gen other = (t_major == 0 & t_minor == 0 & c_major == 0 & c_minor == 0 & c_domestic == 0 & incomplete == 0)

gen group = 0 //incomplete: incomplete = 0 or is missing and having filed in at least one year between 2012 and 2019
	replace group = 1 if c_domestic == 1
	replace group = 2 if c_major == 1
	replace group = 3 if c_minor == 1
	replace group = 4 if t_major == 1
	replace group = 5 if t_minor == 1
	replace group = 6 if other == 1
		
//carryforward
gen aps = 1 - _fillin

hashsort firm_id anio_fiscal

foreach v in porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac {

	gen `v'_alt = `v'
	replace `v'_alt = `v'_alt[_n-1] if missing(`v'_alt) & missing(`v'_alt[_n-1]) == 0 & firm_id == firm_id[_n-1] 

}

gen t_major_alt = (porcentaje_pff_alt >= 50) if missing(porcentaje_pff_alt) == 0
gen t_minor_alt = (porcentaje_pff_alt > 5 & porcentaje_pff_alt < 50) if missing(porcentaje_pff_alt) == 0
gen c_major_alt = (porcentaje_ext_alt >= 50 & porcentaje_pff_alt < 5) if (missing(porcentaje_pff_alt) == 0 & missing(porcentaje_ext_alt) == 0)
gen c_minor_alt = ((porcentaje_ext_alt > 5 & porcentaje_ext_alt < 50) & porcentaje_pff_alt < 5) if (missing(porcentaje_pff_alt) == 0 &  missing(porcentaje_ext_alt) == 0)
gen domestic_alt = (porcentaje_ext_alt < 0.0005 & porcentaje_pff_alt < 0.0005) if (missing(porcentaje_pff_alt) == 0 & missing(porcentaje_ext_alt) == 0)
gen c_domestic_alt = (porcentaje_nac_alt > 95) if missing(porcentaje_nac_alt) == 0

cap gen total_percent_alt = porcentaje_ext_alt + porcentaje_pff_alt + porcentaje_nac_alt
cap gen incomplete_alt = total_percent_alt < 100

gen other_alt = (t_major_alt == 0 & t_minor_alt == 0 & c_major_alt == 0 & c_minor_alt == 0 & c_domestic_alt == 0 & incomplete_alt == 0)

gen group_alt = 0 //incomplete
	replace group_alt = 1 if c_domestic_alt == 1
	replace group_alt = 2 if c_major_alt == 1
	replace group_alt = 3 if c_minor_alt == 1
	replace group_alt = 4 if t_major_alt == 1
	replace group_alt = 5 if t_minor_alt == 1
	replace group_alt = 6 if other_alt == 1

lab def groups 0 "Incomplete" 1 "Domestic" 2 "C-major" 3 "C-minor" 4 "T-major" 5 "T-minor" 6 "Other"
lab val group groups
lab val group_alt groups
	
merge 1:1 firm_id anio_fiscal using "$datadir/panel_aps_f101_filing.dta", nogen keep(1 3) keepus(exclusion_motive f101)

gen count = 1
	
///
//VERSION 1a: APS CRUDO
///
preserve

	gcollapse (sum) count, by(group anio_fiscal)

	save "$outdir/extensivemargin_counts_aps.dta", replace

restore

///
//VERSION 1b: APS CARRIED FORWARD
///
preserve

	gcollapse (sum) count, by(group_alt anio_fiscal)

	save "$outdir/extensivemargin_counts_aps_forwarded.dta", replace

restore

merge 1:1 firm_id anio_fiscal using "$datadir/f101_processed.dta", nogen keep(1 3) keepus(revenue total_assets gross_profit)

///
//VERSION 2a: APS CRUDO X F101
///
preserve

	keep if f101 == 1

	gcollapse (sum) count revenue total_assets gross_profit, by(group anio_fiscal)

	save "$outdir/extensivemargin_counts_aps_f101.dta", replace

restore

///
//VERSION 2b: APS CARRIED FORWARD X F101
///
preserve

	keep if f101 == 1

	gcollapse (sum) count revenue total_assets gross_profit, by(group_alt anio_fiscal)

	save "$outdir/extensivemargin_counts_aps_forwarded_f101.dta", replace

restore

///
//VERSION 3a: APS CRUDO FORWARD X F101 X NON EXCLUDED FIRMS
///
preserve

	keep if f101 == 1 & exclusion_motive == ""
	
	gcollapse (sum) count revenue total_assets gross_profit, by(group anio_fiscal)

	save "$outdir/extensivemargin_counts_aps_f101_industry.dta", replace

restore

///
//VERSION 3b: APS CARRIED FORWARD X F101 X NON EXCLUDED FIRMS
///
preserve

	keep if f101 == 1 & exclusion_motive == ""

	gcollapse (sum) count revenue total_assets gross_profit, by(group_alt anio_fiscal)

	save "$outdir/extensivemargin_counts_aps_forwarded_f101_industry.dta", replace

restore

///
//VERSION 4a: ENTRY
///

preserve

	keep if anio_fiscal == year_earliest
	
	cap drop count
	gen count = 1
	
	gcollapse (sum) count, by(group year_earliest)

	fillin group year_earliest
	replace count = 0 if _fillin == 1
	drop _fillin
	
	save "$outdir/extensivemargin_entry.dta", replace
	
restore

///
//VERSION 4b: ENTRY + f011
///

preserve

	keep if anio_fiscal == year_earliest & f101 == 1
	
	cap drop count
	gen count = 1
	
	gcollapse (sum) count, by(group year_earliest)

	fillin group year_earliest
	replace count = 0 if _fillin == 1
	drop _fillin
	
	save "$outdir/extensivemargin_f101_entry.dta", replace
	
restore

///
//VERSION 5a: EXIT
///

preserve

	keep if anio_fiscal == year_latest
	
	cap drop count
	gen count = 1
	
	gcollapse (sum) count, by(group year_latest)
	
	fillin group year_latest
	replace count = 0 if _fillin == 1
	drop _fillin
	
	save "$outdir/extensivemargin_exit.dta", replace
	
restore

///
//VERSION 5b: EXIT + f101
///

preserve

	keep if anio_fiscal == year_latest & f101 == 1
	
	cap drop count
	gen count = 1
	
	gcollapse (sum) count, by(group year_latest)

	fillin group year_latest
	replace count = 0 if _fillin == 1
	drop _fillin
	
	save "$outdir/extensivemargin_f101_exit.dta", replace

restore

/*
/***********************************************/
/***********************************************/
/* BALANCE ON OBSERVABLES BY TREATMENT/CONTROL */
/***********************************************/
/***********************************************/

use if anio_fiscal == 2014 using "$datadir/core_panel.dta", replace

gen majority_v_domestic = 0 if group == 1
	replace majority_v_domestic = 1 if inlist(group, 2, 4)

gen minority_v_domestic = 0 if group == 1
	replace minority_v_domestic = 1 if inlist(group, 3, 5)
	
gen majority = 0 if inlist(group, 3, 5)
	replace majority = 1 if inlist(group, 2, 4)

gen majority_t = 0 if inlist(group, 5)
	replace majority_t = 1 if inlist(group,4)
	
gen majority_c = 0 if inlist(group, 3)
	replace majority_c = 1 if inlist(group, 2)	
	
merge 1:1 firm_id anio_fiscal using "$datadir/main_panel.dta", nogen keep(1 3) keepus(intermediate_inv_prominent intermediate_10_inv_prominent intermediate_50_inv_prominent intermediate_100_inv_prominent has_maingroup_shareholder_2014 has_maingroup_plur_sh_2014 persona_inverse_prominent persona_inverse_prominent_r)

gen b_participation_prominent = participation_prominent > 0 if missing(participation_prominent) == 0
gen b_participation_inv_prominent = participation_inv_prominent > 0 if missing(participation_inv_prominent) == 0

gegen any_haven_presence_int = rowmax(intermediate_pff_int b_participation_prominent)
gegen any_haven_presence_alt = rowmax(intermediate_pff_alt b_participation_prominent)

gegen any_nonhaven_presence_int = rowmax(intermediate_ext_int b_participation_prominent)
gegen any_nonhaven_presence_alt = rowmax(intermediate_ext_alt b_participation_prominent)

foreach v in 10 50 100 {
	
	gegen any_haven_`v'_presence_int = rowmax(intermediate_`v'_pff_int b_participation_prominent)
	gegen any_haven_`v'_presence_alt = rowmax(intermediate_`v'_pff_alt b_participation_prominent)

	gegen any_nonhaven_`v'_presence_int = rowmax(intermediate_`v'_ext_int b_participation_inv_prominent)
	gegen any_nonhaven_`v'_presence_alt = rowmax(intermediate_`v'_ext_alt b_participation_inv_prominent)
	
}

gegen any_haven_presence = rowmax(intermediate_pff_int b_participation_prominent)

foreach v in exports_rr_w exports_rr gross_profit_margin_w_alt gross_profit_margin gross_profit_margin_w return_on_assets_w_alt return_on_assets return_on_assets_w roa_2014 roa_2014_w_alt roa_2014_w porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac percent_declarado aps_residual aps_residual_pais aps_residual_pais_other average_chain_length max_chain_length max_shareholder beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_conc terminal_owners_10 terminal_owners participation_prominent participation_prominent_0 participation_inv_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_100_pff intermediate_pff_max intermediate_50_prominent intermediate_100_ext intermediate_100_prominent empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt bf_persona_r persona_prominent bf_persona_100_r any_bf_persona_r bf_empresa_r complete_r inconsistent_r aps_residual_0_r percent_declarado_r persona_prominent_r incomplete_r aps_residual_r current_investment activos_c total_activos_fijos_690 activos_intangibles_alt total_activos_lp_1070 total_assets passive_c total_pasivos_int_1600 total_passive total_capital dividendos_percibidos revenue total_cost_expenses gross_profit perdida_ejercicio_3430 participacion_tbj_15_3440 taxable_profits perdida_3570 uti_reinvertir_cpz_3580 cit_liability impuesto_renta_pagar_3680 agregated_debt_int local_related local_unrelated foreign_related foreign_unrelated passive_c_related_local passive_c_unrelated_local passive_c_related_ext passive_c_unrelated_ext passive_l_related_local passive_l_unrelated_local passive_l_related_ext passive_l_unrelated_ext activos_intangibles investments inversiones_no_corrientes inversiones_lp_rel active_c_related_local active_c_unrelated_local active_c_related_ext active_c_unrelated_ext active_l_related_local active_l_unrelated_local active_l_related_ext active_l_unrelated_ext total_activos_netos debt_ratio tot_currentassets_net net_active_c_related_local net_active_c_unrel_local net_active_c_related_ext net_active_c_unrelated_ext net_active_l_related_local net_active_l_unrel_local net_active_l_related_ext net_active_l_unrelated_ext pagos_locales pagos_extranjeros labor_cost labor_cost_w gastos_lab costos_lab exports local_sales total_sales labor_ratio taxable_profit_margin tasa_vigente tasa_ir mid_div_salidas_pff mid_div_salidas_ext mid_div_entradas_pff mid_div_entradas_ext mid_fin_salidas_pff mid_fin_salidas_ext mid_fin_entradas_pff mid_fin_entradas_ext mid_all_salidas_pff mid_all_salidas_ext mid_all_entradas_pff mid_all_entradas_ext mid_fin_salidas_total mid_fin_entradas_total mid_div_salidas_total mid_div_entradas_total mid_all_salidas_total mid_all_entradas_total current_investment_w activos_c_w total_activos_fijos_690_w activos_intangibles_alt_w total_activos_lp_1070_w total_assets_w passive_c_w total_pasivos_int_1600_w total_passive_w total_capital_w dividendos_percibidos_w revenue_w total_cost_expenses_w gross_profit_w perdida_ejercicio_3430_w participacion_tbj_15_3440_w taxable_profits_w perdida_3570_w uti_reinvertir_cpz_3580_w cit_liability_w impuesto_renta_pagar_3680_w agregated_debt_int_w local_related_w local_unrelated_w foreign_related_w foreign_unrelated_w passive_c_related_local_w passive_c_unrelated_local_w passive_c_related_ext_w passive_c_unrelated_ext_w passive_l_related_local_w passive_l_unrelated_local_w passive_l_related_ext_w passive_l_unrelated_ext_w activos_intangibles_w investments_w inversiones_no_corrientes_w inversiones_lp_rel_w active_c_related_local_w active_c_unrelated_local_w active_c_related_ext_w active_c_unrelated_ext_w active_l_related_local_w active_l_unrelated_local_w active_l_related_ext_w active_l_unrelated_ext_w total_activos_netos_w debt_ratio_w tot_currentassets_net_w net_active_c_related_local_w net_active_c_unrel_local_w net_active_c_related_ext_w net_active_c_unrelated_ext_w net_active_l_related_local_w net_active_l_unrel_local_w net_active_l_related_ext_w net_active_l_unrelated_ext_w pagos_locales_w pagos_extranjeros_w labor_cost_w gastos_lab_w costos_lab_w exports_w local_sales_w total_sales_w labor_ratio_w taxable_profit_margin_w tasa_ir_w mid_div_salidas_pff_w mid_div_salidas_ext_w mid_div_entradas_pff_w mid_div_entradas_ext_w mid_fin_salidas_pff_w mid_fin_salidas_ext_w mid_fin_entradas_pff_w mid_fin_entradas_ext_w mid_all_salidas_pff_w mid_all_salidas_ext_w mid_all_entradas_pff_w mid_all_entradas_ext_w mid_fin_salidas_total_w mid_fin_entradas_total_w mid_div_salidas_total_w mid_div_entradas_total_w mid_all_salidas_total_w mid_all_entradas_total_w mid_div_salidas_prom mid_div_salidas_inv mid_div_entradas_prom mid_div_entradas_inv mid_fin_salidas_prom mid_fin_salidas_inv mid_fin_entradas_prom mid_fin_entradas_inv mid_all_salidas_prom mid_all_salidas_inv mid_all_entradas_prom mid_all_entradas_inv mid_all_salidas_prom_w mid_all_salidas_inv_w mid_all_entradas_prom_w mid_all_entradas_inv_w mid_div_salidas_prom_w mid_div_salidas_inv_w mid_div_entradas_prom_w mid_div_entradas_inv_w mid_fin_salidas_prom_w mid_fin_salidas_inv_w mid_fin_entradas_prom_w mid_fin_entradas_inv_w intermediate_inv_prominent intermediate_10_inv_prominent intermediate_50_inv_prominent intermediate_100_inv_prominent has_maingroup_shareholder_2014 has_maingroup_plur_sh_2014 persona_inverse_prominent persona_inverse_prominent_r terminal_owners_prom terminal_owners_inv_prom terminal_owners_10_prom terminal_owners_10_inv_prom intermediate_pff_int intermediate_ext_int intermediate_prom_int intermediate_inv_prom_int intermediate_10_pff_int intermediate_10_ext_int intermediate_10_prom_int intermediate_10_inv_prom_int intermediate_50_pff_int intermediate_50_ext_int intermediate_50_prom_int intermediate_50_inv_prom_int intermediate_100_pff_int intermediate_100_ext_int intermediate_100_prom_int intermediate_100_inv_prom_int intermediate_50_pff_int intermediate_50_ext_int intermediate_50_prom_int intermediate_50_inv_prom_int intermediate_100_pff_int intermediate_100_ext_int intermediate_100_prom_int intermediate_100_inv_prom_int intermediate_pff_alt intermediate_ext_alt intermediate_prom_alt intermediate_inv_prom_alt intermediate_10_pff_alt intermediate_10_ext_alt intermediate_10_prom_alt intermediate_10_inv_prom_alt intermediate_50_pff_alt intermediate_50_ext_alt intermediate_50_prom_alt intermediate_50_inv_prom_alt intermediate_100_pff_alt intermediate_100_ext_alt intermediate_100_prom_alt intermediate_100_inv_prom_alt intermediate_50_pff_alt intermediate_50_ext_alt intermediate_50_prom_alt intermediate_50_inv_prom_alt intermediate_100_pff_alt intermediate_100_ext_alt intermediate_100_prom_alt intermediate_100_inv_prom_alt bf_persona_unique_50 bf_persona_unique_100 bf_persona_50 has_majority_terminal_owner has_whole_terminal_owner any_haven_presence_int any_haven_presence_alt any_nonhaven_presence_int any_nonhaven_presence_alt any_nonhaven_10_presence_alt any_nonhaven_10_presence_int any_haven_10_presence_alt any_haven_10_presence_int any_nonhaven_50_presence_alt any_nonhaven_50_presence_int any_haven_50_presence_alt any_haven_50_presence_int any_nonhaven_100_presence_alt any_nonhaven_100_presence_int any_haven_100_presence_alt any_haven_100_presence_int any_haven any_nonhaven any_nonhaven_alt any_haven_alt any_prom any_prom_alt any_inv_prom any_inv_prom_alt {
	
	//skipping if the variable is a binary variable
	cap n qui sum `v'
	if round(((r(mean) * (1 - r(mean))) - (r(sd)^2)), .001) == 0 continue

	cap n gen l_`v' = log(`v')
	cap n gen b_`v' = (`v') > 0 if missing(`v') == 0
	
}

cap postclose balance_coresample
postfile balance_coresample str32(var) double(coef stderr N r2) using "$outdir/balance_coresample.dta", replace

ds firm_id anio_fiscal minority_v_domestic majority_v_domestic majority majority_t majority_c  group_assign group treatment_major treatment_minor exposure prominent_2014 t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt prominent_2012_2014 porcion_comp_soc_no_inf_3576 porcion_comp_soc_si_inf_3578, not

foreach v in `r(varlist)' {

	//1. majors
	qui sum `v' if treatment_major == 1
	loc t_mean = r(mean)
	loc t_sd = r(sd) 
	
	qui sum `v' if treatment_major == 0
	loc c_mean = r(mean)
	loc c_sd = r(sd) 
	
	cap reg `v' b0.i.treatment_major, r
	if !_rc regsave using "$outdir/balance_coresample.dta", append autoid addlabel(spec, majors, depvar, `v', t_mean, `t_mean', t_sd, `t_sd', c_mean, `c_mean', c_sd, `c_sd') detail(scalars)	
 
	//2. minors
	qui sum `v' if treatment_minor == 1
	loc t_mean = r(mean)
	loc t_sd = r(sd) 
	
	qui sum `v' if treatment_minor == 0
	loc c_mean = r(mean)
	loc c_sd = r(sd) 
	
	cap reg `v' b0.i.treatment_minor, r
	if !_rc regsave using "$outdir/balance_coresample.dta", append autoid addlabel(spec, minors, depvar, `v', t_mean, `t_mean', t_sd, `t_sd', c_mean, `c_mean', c_sd, `c_sd') detail(scalars)	
	
	//3. majors v. domestic
	qui sum `v' if majority_v_domestic == 1
	loc t_mean = r(mean)
	loc t_sd = r(sd) 
	
	qui sum `v' if majority_v_domestic == 0
	loc c_mean = r(mean)
	loc c_sd = r(sd) 
	
	cap reg `v' b0.i.majority_v_domestic, r
	if !_rc regsave using "$outdir/balance_coresample.dta", append autoid addlabel(spec, majority_v_domestic, depvar, `v', t_mean, `t_mean', t_sd, `t_sd', c_mean, `c_mean', c_sd, `c_sd') detail(scalars)	
	
	//4. minors v. domestic
	qui sum `v' if minority_v_domestic == 1
	loc t_mean = r(mean)
	loc t_sd = r(sd) 
	
	qui sum `v' if minority_v_domestic == 0
	loc c_mean = r(mean)
	loc c_sd = r(sd) 
	
	cap reg `v' b0.i.minority_v_domestic, r
	if !_rc regsave using "$outdir/balance_coresample.dta", append autoid addlabel(spec, minority_v_domestic, depvar, `v', t_mean, `t_mean', t_sd, `t_sd', c_mean, `c_mean', c_sd, `c_sd') detail(scalars)	
	
	//5. t majority v. t minority 
	qui sum `v' if majority_t == 1
	loc t_mean = r(mean)
	loc t_sd = r(sd) 
	
	qui sum `v' if majority_t == 0
	loc c_mean = r(mean)
	loc c_sd = r(sd) 
	
	cap reg `v' b0.i.majority_t, r
	if !_rc regsave using "$outdir/balance_coresample.dta", append autoid addlabel(spec, t_majors_t_minors, depvar, `v', t_mean, `t_mean', t_sd, `t_sd', c_mean, `c_mean', c_sd, `c_sd') detail(scalars)	
 
	//6. minors
	qui sum `v' if majority_c == 1
	loc t_mean = r(mean)
	loc t_sd = r(sd) 
	
	qui sum `v' if majority_c == 0
	loc c_mean = r(mean)
	loc c_sd = r(sd) 
	
	cap reg `v' b0.i.majority_c, r
	if !_rc regsave using "$outdir/balance_coresample.dta", append autoid addlabel(spec, c_majors_c_minors, depvar, `v', t_mean, `t_mean', t_sd, `t_sd', c_mean, `c_mean', c_sd, `c_sd') detail(scalars)	
	
	//7. majors v minors
	qui sum `v' if majority == 1
	loc t_mean = r(mean)
	loc t_sd = r(sd) 
	
	qui sum `v' if majority == 0
	loc c_mean = r(mean)
	loc c_sd = r(sd) 
	
	cap reg `v' b0.i.majority, r
	if !_rc regsave using "$outdir/balance_coresample.dta", append autoid addlabel(spec, majority_v_minority, depvar, `v', t_mean, `t_mean', t_sd, `t_sd', c_mean, `c_mean', c_sd, `c_sd') detail(scalars)	
	
}

cap postclose balance_coresample

/*
/******************************************************/
/******************************************************/
/* HISTOGRAMS OF HAVEN OUTFLOWS AS A SHARE OF REVENUE */
/******************************************************/
/******************************************************/

use group anio_fiscal mid_all_salidas_pff_rr mid_all_salidas_pff_rr_w using "$datadir/core_panel.dta", clear

glevelsof group anio_fiscal, local(group_year)
foreach gt of local group_year {
	
	loc g = real(substr("`gt'", 1, 1))
	loc t = real(substr("`gt'", -4, 4))
	
	//graph twoway (histogram mid_all_salidas_pff_rr if group == `g' & anio_fiscal == `t', color(black)), xti(Ratio of haven exits to revenue) yti(Density) graphregion(fcolor(white))
		
		//gr_edit .plotregion1.plot1._set_type line
		
		//graph export "$outdir/histogram_mid_all_salidas_pff_rr_group`g'_year`t'.png", replace
		twoway__histogram_gen mid_all_salidas_pff_rr if group == `g' & anio_fiscal == `t', gen(h_rr_`g'_`t' x_rr_`g'_`t', replace)
		
	//graph twoway (histogram mid_all_salidas_pff_rr_w if group == `g' & anio_fiscal == `t', color(black)), xti(Ratio of haven exits to revenue) yti(Density) graphregion(fcolor(white))
		
		//gr_edit .plotregion1.plot1._set_type line
		
		//graph export "$outdir/histogram_mid_all_salidas_pff_rr_group`g'_year`t'_nozeros.png", replace
		twoway__histogram_gen mid_all_salidas_pff_rr_w if group == `g' & anio_fiscal == `t', gen(h_rr_w_`g'_`t' x_rr_w_`g'_`t', replace)
		
	//graph twoway (histogram mid_all_salidas_pff_rr if group == `g' & anio_fiscal == `t' & mid_all_salidas_pff_rr != 0, color(black)), xti(Ratio of haven exits to revenue) yti(Density) graphregion(fcolor(white))
		
		//gr_edit .plotregion1.plot1._set_type line
		
		//graph export "$outdir/histogram_mid_all_salidas_pff_rr_group`g'_year`t'.png", replace
		twoway__histogram_gen mid_all_salidas_pff_rr if group == `g' & anio_fiscal == `t' & mid_all_salidas_pff_rr != 0, gen(h_rr_nozeros_`g'_`t' x_rr_nozeros_`g'_`t', replace)
		
	//graph twoway (histogram mid_all_salidas_pff_rr_w if group == `g' & anio_fiscal == `t' & mid_all_salidas_pff_rr_w != 0, color(black)), xti(Ratio of haven exits to revenue) yti(Density) graphregion(fcolor(white))
		
		//gr_edit .plotregion1.plot1._set_type line
		
		//graph export "$outdir/histogram_mid_all_salidas_pff_rr_w_group`g'_year`t'_nozeros.png", replace
		twoway__histogram_gen mid_all_salidas_pff_rr_w if group == `g' & anio_fiscal == `t' & mid_all_salidas_pff_rr_w != 0, gen(h_rr_w_nozeros_`g'_`t' x_rr_w_nozeros_`g'_`t', replace)
}

keep x_* h_*

gegen missings = rowmiss(*)
desc 
drop if missings == r(k) - 1
drop missings

save "$outdir/histograms_salidas_pff_rr_bygroup_by_year.dta", replace

/**************/
/**************/
/* INDUSTRIES */
/**************/
/**************/

/*
import delimited "$datadir/RUC_anonimizado.csv", clear

gen industry1 = substr(codigo_opera_actividad_eco, 1, 1)
keep firm_id industry1
compress
save "$datadir/industries.dta", replace
*/

use if anio_fiscal == 2014 using "$datadir/core_panel.dta", clear

merge 1:1 firm_id using "$datadir/industries.dta", keep(1 3) gen(industry_merge)

glevelsof group, local(groups)
foreach g of local groups {
	
	fre industry1 using "$outdir/industries_group`g'.csv" if group == `g', missing asc replace
	
}

/*****************************************/
/* HISTOGRAMS OF PROMINENT PARTICIPATION */
/*****************************************/

use group anio_fiscal participation_prominent using "$datadir/core_panel.dta", clear

gen group_alt = 0 if inlist(group, 2, 3)
	replace group_alt = 1 if inlist(group, 4, 5)

drop if missing(group_alt)
	
glevelsof group_alt anio_fiscal, local(group_year)
foreach gt of local group_year {
	
	loc g = real(substr("`gt'", 1, 1))
	loc t = real(substr("`gt'", -4, 4))
	
	//graph twoway (histogram participation_prominent if group_alt == `g' & anio_fiscal == `t', color(black)), xti(Prominent group participation) yti(Density) graphregion(fcolor(white))
		
		//gr_edit .plotregion1.plot1._set_type line
		
		//graph export "$outdir/histogram_participation_prominent_group`g'_year`t'.png", replace
		twoway__histogram_gen participation_prominent if group_alt == `g' & anio_fiscal == `t', gen(h_participation_prominent_`g'_`t' x_participation_prominent_`g'_`t', replace)
	
}
	
keep x_* h_*

gegen missings = rowmiss(*)
desc 
drop if missings == r(k) - 1
drop missings

save "$outdir/histograms_participation_prominent_bygroup_by_year.dta", replace
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

di "file descriptive_statistics_balance has terminated successfully"

cap log close
clear
