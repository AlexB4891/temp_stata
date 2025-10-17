cap clear all
set more off
cap log close
set varabbrev off

/***********/
/* HISTORY */
/***********/
	
//20250609: rebuilding, combining reprocessed APS with the adjusted data table, checking that the values align
	
//20250610: starting with reprocessing of APS, then MID, then F101
	//then making sample restrictions and putting back together
	
//20250715: incorporating "interior" intermediate ownership results	
	
//20250721: adding some additional ownership variables	
	
//20250722: adding in alternate interior ownership variables that map to missing if there is no interior	
	
//20250819: adding in an any alt spec,
	//editing the definitions of non-haven to include ecuador, which I think it should. This shouldn't affect the intermediate pff results, but should affect the prominent results
	
//20251002: adding in additonal variables

//20251008: adding in dividends and retained earnings imputations 
	
/*********/
/* NOTES */
/*********/

/*
net install ftools, from("F:\DTO_ESTUDIOS_E1_ext2\B_INVESTIGADORES_EXTERNOS\B202106_JAKOB_BROUNSTEIN\Ado\ado_1\install\ftools_src_v2") replace
net install gtools, from("F:\DTO_ESTUDIOS_E1_ext2\B_INVESTIGADORES_EXTERNOS\B202106_JAKOB_BROUNSTEIN\Ado\ado_1\install\gtools_build") replace
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
glob outdir "$localdir/out"

log using "$logdir/build_`today'.smcl", replace

timer clear
timer on 1 

/*********/
/*********/
/* BUILD */
/*********/
/*********/

/*
/*******/
/* APS */
/*******/

forv t = 2012/2019 {

	import delimited "F:\DTO_ESTUDIOS_E2\B_INVESTIGADORES_EXTERNOS\202201_BANCO_MUNDIAL_PBACHAS\01_DATA\1_PROPORCIONADO_SRI\APS\A_APS_`t'.csv", clear

	keep anio_fiscal identificacion_informante_anon id_sociedad_anon id_accionista_anon nivel_aps porcentaje_participacion porcentaje_efectivo paraiso_fiscal_accionista pais_accionista_unico codigo_pais_accionista pais_accionista tipo_id_accionista tipo_accionista

	destring porcentaje_efectivo porcentaje_participacion codigo_pais_accionista, force replace

	gen filing_year = `t'
	
	compress
	
	tempfile aps_`t'
	save `aps_`t'', replace
	
}	
	
clear

forv t = 2012/2019 {	
	
	append using `aps_`t''
	
}

keep if anio_fiscal == filing_year
gduplicates drop

replace tipo_id_accionista = "" if inlist(tipo_id_accionista, "C", "E", "P", "R") == 0

//forcing drop on qualitatively same observation
gduplicates drop anio_fiscal identificacion_informante_anon id_sociedad_anon id_accionista_anon pais_accionista pais_accionista_unico codigo_pais_accionista nivel_aps, force

drop filing_year

compress

///
//ADJUSTING APS
///

ren identificacion_informante_anon firm_id

//BASIC COMPLIANCE VARIABLES
gen aps = 1
bys firm_id: gegen aps_2014 = max(cond(anio_fiscal == 2014, 1, 0))
bys firm_id: gegen aps_2012_2014 = max(cond(inrange(anio_fiscal, 2012, 2014), 1, 0))

compress

save "$datadir/aps_processed.dta", replace

/**************************/
/* LIST OF EXCLUDED FIRMS */
/**************************/

//this list comes from the RUC database, it lists government entities and oil companies that are excluded from the law and regulated under different regimes

//need to make this dataset unique on the firm level
use "$datadir\crosswalk_ruc_id_update_16082021.dta", clear

keep if name == "ruc"

save "$datadir\crosswalk_ruc_id_update.dta", replace

/********/
/* F101 */
/********/

//need f101 unzipped
forv t = 2012/2019 {

	import delimited "F:\DTO_ESTUDIOS_E2\B_INVESTIGADORES_EXTERNOS\202201_BANCO_MUNDIAL_PBACHAS\01_DATA\F101\completo\F101_`t'.csv", clear
	
	cap ren id_an numero_identificacion_an
	keep numero_identificacion_an total_ingresos_1930 anio_fiscal impuesto_renta_causado_3600 impuesto_renta_pagar_3680
	
	destring total_ingresos_1930 anio_fiscal, force replace dpcomma

	gen filing_year = `t'
	
	compress
	
	tempfile f101_`t'
	save `f101_`t'', replace
	
}	
	
clear

forv t = 2012/2019 {	
	
	append using `f101_`t''
	
}

//save "$datadir\transfer\f101_temp.dta", replace 

gduplicates drop

ren numero_identificacion_an firm_id

gen f101 = 1
gen active = total_ingresos_1930 > 0 & missing(total_ingresos_1930) == 0
//gen cit = impuesto_renta_causado_3600 > 0 & missing(impuesto_renta_causado_3600) == 0

//keep criteria: firms that filed f101 with positive revenues in 2014
bys firm_id: egen active_2014 = max(cond(anio_fiscal == 2014 & active == 1, 1, 0))

drop filing_year

compress

save "$datadir/f101_active_list.dta", replace

keep firm_id

gduplicates drop

save "$datadir/f101_id_list.dta", replace

/***************************************************************/
/* BROAD APS X F101 ACTIVITY X INDUSTRY EXCLUSION & SAMPLE SET */
/***************************************************************/

use firm_id anio_fiscal aps aps_2012_2014 using "$datadir/aps_processed.dta", clear

gduplicates drop

merge 1:1 firm_id anio_fiscal using "$datadir/f101_active_list.dta", gen(merge) 

replace aps = 0 if merge == 2

replace f101 = 0 if merge == 1
replace active = 0 if merge == 1
//replace cit = 0 if merge == 1

gen aps_f101 = merge == 3
gen aps_f101_active = merge == 3 & active == 1
//gen aps_f101_cit = merge == 3 & cit == 1

//rectangularize
fillin firm_id anio_fiscal

foreach v in aps active f101 aps_f101 aps_f101_active /*cit aps_f101_cit*/ {

	replace `v' = 0 if _fillin == 1

}

bys firm_id: gegen f101_2014 = mean(cond(anio_fiscal == 2014, f101, .))
bys firm_id: ereplace active_2014 = max(cond(anio_fiscal == 2014, active, .))
bys firm_id: ereplace aps_2012_2014 = max(cond(inrange(anio_fiscal, 2012, 2014), aps, .))

drop merge _fillin

destring impuesto_renta_causado_3600 impuesto_renta_pagar_3680, dpcomma force replace

ren firm_id id_an
merge m:1 id_an using "$datadir\crosswalk_ruc_id_update.dta", keep(3) nogen keepus(exclusion_motive)
ren id_an firm_id

compress

save "$datadir/panel_aps_f101_filing.dta", replace

//list of firms that ever file either aps or f101: using this as a filter for tractability in processing the MID
preserve

	keep firm_id
	
	gduplicates drop
	
	save "$datadir/aps_f101_id_list.dta", replace

restore

//main sample requires 1) filing f101 in 2014, 2) positive revenues in 2014, and 3) at least one aps between 2012 and 2014
//this group would constitute the "core sample"
keep if aps_2012_2014 == 1 & active_2014 == 1 & exclusion_motive == ""
keep firm_id

gduplicates drop 
gunique firm_id

compress

save "$datadir/core_sample_list.dta", replace
*/

/*
/*******************************************************/
/* ATTACHING THE CORE SAMPLE TO THE APS AND PROCESSING */
/*******************************************************/

use "$datadir/core_sample_list.dta", clear

merge 1:m firm_id using "$datadir/aps_processed.dta", keep(3) nogen

gegen firm_year_tag = tag(firm_id anio_fiscal)
gegen firm_tag = tag(firm_id)

gen terminal = missing(porcentaje_efectivo) == 0

//ITALY CHECK
/*
preserve
	
	keep if anio_fiscal == 2014
	keep if pais_accionista_unico == "ITALIA"
	collapse (sum) porcentaje_efectivo, by(firm_id)
	keep if porcentaje_efectivo >= 50
	keep firm_id
	save "$datadir/italy_check.dta", replace

	use "D:\BM_EXTENSION\B202106_JAKOB_BROUNSTEIN\transfer\data_main.dta" ,clear
	merge m:1 firm_id using "D:\BM_EXTENSION\B202106_JAKOB_BROUNSTEIN/data/transparency/italy_check.dta", gen(merge) keep(1 3)
	gen group = 0 if group_assign == "C-Maj"
	replace group = 1 if group_assign=="T-Maj"
	replace group = 2 if merge == 3
	lgraph tasa_ir anio_fiscal group if cit_liability > 0, yti(Tasa) xti(Year) legend(order(1 "C-major" 2 "T-major" 3 "Italy-owned"))
	
		graph export "$outdir/italy_check.png", replace
	
restore
*/

replace paraiso_fiscal_accionista = "" if pais_accionista_unico == "ITALIA"

//country groups
gen pais_extranjero = "pff" if paraiso_fiscal_accionista == "S"
	replace pais_extranjero = "ext" if paraiso_fiscal_accionista != "S" & pais_accionista_unico != "ECUADOR" 
	replace pais_extranjero = "nac" if paraiso_fiscal_accionista != "S" & pais_accionista_unico == "ECUADOR" 
	replace pais_extranjero = "otro" if paraiso_fiscal_accionista == "" & pais_accionista_unico == ""

//GENERATE TERMINAL OWNERSHIP VARIABLES 
//percentage
bys firm_id anio_fiscal: gegen porcentaje_pff = total(cond(paraiso_fiscal_accionista == "S", porcentaje_efectivo, 0)) 
bys firm_id anio_fiscal: gegen porcentaje_ext = total(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico != "ECUADOR", porcentaje_efectivo, 0))
bys firm_id anio_fiscal: gegen porcentaje_nac = total(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico == "ECUADOR", porcentaje_efectivo, 0))
bys firm_id anio_fiscal: gegen porcentaje_vac = total(cond(paraiso_fiscal_accionista == "" & pais_accionista_unico == "", porcentaje_efectivo, 0))	
	
//total ownership, pathological ownership
bys firm_id anio_fiscal: gegen total_terminal_ownership = total(porcentaje_efectivo)
gen percent_declarado = porcentaje_pff + porcentaje_ext + porcentaje_nac //porcentaje_vac 
	gen incomplete = percent_declarado < 100
	gen complete = percent_declarado == 100
	gen inconsistent = percent_declarado > 100

//resolve pathological cases		
replace porcentaje_efectivo = porcentaje_efectivo * (100 / percent_declarado) if inconsistent == 1
	bys firm_id anio_fiscal: ereplace porcentaje_pff = total(cond(paraiso_fiscal_accionista == "S", porcentaje_efectivo, 0)) if inconsistent == 1
	bys firm_id anio_fiscal: ereplace porcentaje_ext = total(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico != "ECUADOR", porcentaje_efectivo, 0)) if inconsistent == 1
	bys firm_id anio_fiscal: ereplace porcentaje_nac = total(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico == "ECUADOR", porcentaje_efectivo, 0)) if inconsistent == 1
	bys firm_id anio_fiscal: ereplace porcentaje_vac = total(cond(paraiso_fiscal_accionista == "" & pais_accionista_unico == "", porcentaje_efectivo, 0)) if inconsistent == 1
	
//aps residuals
gen aps_residual = 100 - total_terminal_ownership 
gen aps_residual_0 = total_terminal_ownership == 100 
gen aps_residual_pais = 100 - porcentaje_pff - porcentaje_ext - porcentaje_nac 
gen aps_residual_pais_other = total_terminal_ownership - porcentaje_pff - porcentaje_ext - porcentaje_nac 	
	
//OWNERSHIP VARIABLES
//ownership chain length
bys firm_id anio_fiscal: gegen average_chain_length = mean(nivel_aps) [aweight = porcentaje_efectivo] if porcentaje_efectivo != .
bys firm_id anio_fiscal: gegen max_chain_length = max(nivel_aps)

gen b_average_chain_length = average_chain_length > 1 if missing(average_chain_length) == 0
gen b_max_chain_length = max_chain_length > 1 if missing(max_chain_length) == 0

//average terminal ownership concentration percentage
bys firm_id anio_fiscal: gegen terminal_ownership_concentration = mean(cond(missing(porcentaje_efectivo) == 0, porcentaje_efectivo, .))
bys firm_id anio_fiscal: gegen terminal_owners_10 = total(cond(porcentaje_efectivo >= 10, 1, .))
bys firm_id anio_fiscal: gegen terminal_owners = total(cond(porcentaje_efectivo > 0 & missing(porcentaje_efectivo) == 0, 1, .))

//generating plurality ownership
bys firm_id anio_fiscal: gegen max_shareholder = max(porcentaje_efectivo)	

bys firm_id anio_fiscal: gegen has_whole_terminal_owner = max(cond(porcentaje_efectivo == 100, 1, 0))
bys firm_id anio_fiscal: gegen has_majority_terminal_owner = max(cond(porcentaje_efectivo >= 50, 1, 0))

//NEED F102 RUC LIST: alex has this separately, but I generated just from the existing f102 data
/*
//ID LIST
use id_an using "D:\BM_EXTENSION\B202106_JAKOB_BROUNSTEIN\data\f102\f102_processed_all.dta", replace
gduplicates drop
compress
save "$datadir/f102_id_list.dta", replace

//ID-YEAR LIST
use id_an year using "D:\BM_EXTENSION\B202106_JAKOB_BROUNSTEIN\data\f102\f102_processed_all.dta", replace
gduplicates drop
ren year anio_fiscal
compress
save "$datadir/f102_id_year_list.dta", replace
*/

///
//GEOGRAPHY X PERSONHOOD
///

ren id_accionista_anon id_an
merge m:1 id_an using "$datadir/f102_id_list.dta", keep(1 3)
//merge m:1 id_an anio_fiscal using "$datadir/f102_id_year_list.dta", keep(1 3) //pretty sure we sholdn't use this
gen f102 = _merge == 3 
drop _merge
ren id_an id_accionista_anon

gen ecuador = pais_accionista_unico == "ECUADOR"

gen persona_pff = paraiso_fiscal_accionista == "S" & (inlist(tipo_id_accionista, "P","C"))
	replace persona_pff = 1 if paraiso_fiscal_accionista == "S" & (tipo_id_accionista == "R" & f102 == 1)

gen empresa_pff = paraiso_fiscal_accionista == "S" & (tipo_id_accionista == "E" & f102 == 1)
	replace empresa_pff = 1 if paraiso_fiscal_accionista == "S" & (tipo_id_accionista == "E")
	replace empresa_pff = 1 if paraiso_fiscal_accionista == "S" & (tipo_id_accionista == "R" & f102 == 0)
	
gen persona_nacional = ecuador == 1 & f102 == 1
	replace persona_nacional = 1 if ecuador == 1 & (f102 == 0 & inlist(tipo_id_accionista, "C", "P"))
	
gen empresa_nacional = ecuador == 1 & f102 == 0 & inlist(tipo_id_accionista, "E", "R")

gen persona_extranjera = (ecuador == 0 & paraiso_fiscal_accionista == "") & (inlist(tipo_id_accionista, "P", "C"))
	replace persona_extranjera = 1 if (ecuador == 0 & paraiso_fiscal_accionista == "") & (tipo_id_accionista == "R" & f102 == 1)

gen empresa_extranjera = (ecuador == 0 & paraiso_fiscal_accionista == "") & (tipo_id_accionista == "E" & f102 == 1)
	replace empresa_extranjera = 1 if (ecuador == 0 & paraiso_fiscal_accionista == "") & (tipo_id_accionista == "E")
	replace empresa_extranjera = 1 if (ecuador == 0 & paraiso_fiscal_accionista == "") & (tipo_id_accionista == "R" & f102 == 0)
	
foreach v in empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional {
	
	gen is_`v' = `v'
	bys firm_id anio_fiscal: ereplace `v' = total(cond(`v' == 1, porcentaje_efectivo, .))
	
}

gegen is_persona = rowmax(is_persona_extranjera is_persona_nacional is_persona_pff)
drop is_persona_extranjera is_persona_nacional is_persona_pff is_empresa_extranjera is_empresa_nacional is_empresa_pff

gegen persona_foreign = rowtotal(persona_extranjera persona_pff)
gegen empresa_foreign = rowtotal(empresa_extranjera empresa_pff)

//BENEFICIAL OWNERSHIP
gegen bf_persona = rowtotal(persona_extranjera persona_nacional persona_pff)
gen bf_persona_100 = bf_persona == 100
gen bf_persona_50 = bf_persona >= 50

bys firm_id anio_fiscal: gegen bf_persona_unique_100 = max(cond(porcentaje_efectivo == 100 & is_persona == 1, 1, 0))
bys firm_id anio_fiscal: gegen bf_persona_unique_50 = max(cond(porcentaje_efectivo >= 50 & is_persona == 1, 1, 0))
drop is_persona

gen any_bf_persona = bf_persona > 0 & missing(bf_persona) == 0
gegen bf_empresa = rowtotal(empresa_extranjera empresa_nacional empresa_pff)

bys firm_id anio_fiscal: gegen bf_persona_alt = total(cond(inlist(tipo_accionista, "PERSONAS NATURALES"), porcentaje_efectivo, .))

//counts of terminal owners: make sure that this only counts terminal owners
bys firm_id anio_fiscal: gegen beneficiarios_pff = total(cond(paraiso_fiscal_accionista == "S" & porcentaje_efectivo != ., 1, 0)) 
bys firm_id anio_fiscal: gegen beneficiarios_ext = total(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico != "ECUADOR" & porcentaje_efectivo != ., 1, 0))
bys firm_id anio_fiscal: gegen beneficiarios_nac = total(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico == "ECUADOR" & porcentaje_efectivo != ., 1, 0))
bys firm_id anio_fiscal: gegen beneficiarios_vac = total(cond(paraiso_fiscal_accionista == "" & pais_accionista_unico == "" & porcentaje_efectivo != ., 1, 0))

//counts >= 10
bys firm_id anio_fiscal: gegen beneficiarios_10_pff = total(cond(paraiso_fiscal_accionista == "S" & porcentaje_efectivo >= 10, 1, 0)) 
bys firm_id anio_fiscal: gegen beneficiarios_10_ext = total(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico != "ECUADOR" & porcentaje_efectivo >= 10, 1, 0))
bys firm_id anio_fiscal: gegen beneficiarios_10_nac = total(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico == "ECUADOR" & porcentaje_efectivo >= 10, 1, 0))
bys firm_id anio_fiscal: gegen beneficiarios_10_vac = total(cond(paraiso_fiscal_accionista == "" & pais_accionista_unico == "" & porcentaje_efectivo >= 10, 1, 0))

///
//GENERATING GROUPS
///

bys firm_id: gegen max_year_2012_2014 = max(cond(inrange(anio_fiscal, 2012, 2014) == 1, anio_fiscal, .))

//generating groups
preserve

	//prepping alt groups
	bys firm_id: gegen pff_alt_2012_2014 = mean(cond(firm_year_tag == 1 & inrange(anio_fiscal, 2012, 2014), porcentaje_pff, .))
	bys firm_id: gegen ext_alt_2012_2014 = mean(cond(firm_year_tag == 1 & inrange(anio_fiscal, 2012, 2014), porcentaje_ext, .))
		
	keep if anio_fiscal == max_year_2012_2014
	
	cap drop firm_tag
	gegen firm_tag = tag(firm_id)
	keep if firm_tag == 1
	
	//data should be unique on the firm_id level

	gen t_major = (porcentaje_pff >= 50)
	gen t_minor = (porcentaje_pff > 5 & porcentaje_pff < 50)
	gen c_major = (porcentaje_ext >= 50 & porcentaje_pff < 5)
	gen c_minor = ((porcentaje_ext > 5 & porcentaje_ext < 50) & porcentaje_pff < 5)
	gen domestic = (porcentaje_ext < 0.0005 & porcentaje_pff < 0.0005)
	gen c_domestic = (porcentaje_nac > 95)
	
	cap gen total_percent = porcentaje_ext + porcentaje_pff + porcentaje_nac 
	cap gen incomplete = total_percent < 100
	
	gen other = (t_major == 0 & t_minor == 0 & c_major == 0 & c_minor == 0 & c_domestic == 0 & incomplete == 0)
	
	gen group = 0 //incomplete
		replace group = 1 if c_domestic == 1
		replace group = 2 if c_major == 1
		replace group = 3 if c_minor == 1
		replace group = 4 if t_major == 1
		replace group = 5 if t_minor == 1
		replace group = 6 if other == 1
	
	lab def groups 0 "Incomplete" 1 "Domestic" 2 "C-major" 3 "C-minor" 4 "T-major" 5 "T-minor" 6 "Other"
	lab val group groups
	
	tab group
	
	gegen check = rowtotal(c_domestic c_major c_minor t_major t_minor other)
	sum check
	//check should be uniformly 1
	drop check

	//alt treatment and control
	gen t_major_alt = (pff_alt_2012_2014 >= 50)
	gen t_minor_alt = (pff_alt_2012_2014 > 5 & pff_alt_2012_2014 < 50)
	gen c_major_alt = (ext_alt_2012_2014 >= 50 & pff_alt_2012_2014 < 5)
	gen c_minor_alt = ((ext_alt_2012_2014 > 5 & ext_alt_2012_2014 < 50) & pff_alt_2012_2014 < 5)
	
	keep firm_id t_major t_minor c_major c_minor domestic c_domestic incomplete other group porcentaje_pff porcentaje_ext t_major_alt t_minor_alt c_minor_alt c_major_alt pff_alt_2012_2014
	
	//generating prominent, inverse prominent groups
	gen prominent_group = "pff" if t_major == 1 | t_minor == 1
		replace prominent_group = "ext" if c_major == 1 | c_minor == 1
		replace prominent_group = "nac" if c_domestic == 1
		
	gen inv_prominent_group = "ext" if t_major == 1 | t_minor == 1
		replace inv_prominent_group = "pff" if c_major == 1 | c_minor == 1
		
	gen treatment_major = .
		replace treatment_major = 1 if group == 4
		replace treatment_major = 0 if group == 2

	gen treatment_minor = .
		replace treatment_minor = 1 if group == 5
		replace treatment_minor = 0 if group == 3	
	
	gen treatment_major_alt = .
		replace treatment_major_alt = 1 if t_major_alt == 1
		replace treatment_major_alt = 0 if c_major_alt == 1

	gen treatment_minor_alt = .
		replace treatment_minor_alt = 1 if t_minor_alt == 1
		replace treatment_minor_alt = 0 if c_minor_alt == 1	
		
	gen exposure = ((porcentaje_pff * .03) * (porcentaje_pff < 50)) + (3 * (porcentaje_pff >= 50))
	gen exposure_alt = ((pff_alt_2012_2014 * .03) * (pff_alt_2012_2014 < 50)) + (3 * (pff_alt_2012_2014 >= 50))
	
	gen prominent_2014 = (porcentaje_pff * inlist(group, 4, 5)) + (porcentaje_ext * inlist(group, 2, 3))
	
	gen group_assign = "T-major" if t_major == 1
		replace group_assign = "C-major" if c_major == 1
		replace group_assign = "T-minor" if t_minor == 1
		replace group_assign = "C-minor" if c_minor == 1
	
	tempfile groups
	save `groups', replace
	
restore

//only keeping firms that merge
merge m:1 firm_id using `groups', keep(3) nogen

//GENERATE PROMINENT AND INVERSE PROMINENT PARTICIPATION
gen participation_prominent = porcentaje_pff if t_major == 1 | t_minor == 1
	replace participation_prominent = porcentaje_ext if c_major == 1 | c_minor == 1
	replace participation_prominent = porcentaje_nac if c_domestic == 1
	
	gen participation_prominent_0 = participation_prominent == 0
		
gen participation_inverse_prominent = porcentaje_ext if t_major == 1 | t_minor == 1
	replace participation_inverse_prominent = porcentaje_pff if c_major == 1 | c_minor == 1	

bys firm_id: gegen prominent_2012_2014 = mean(cond(inrange(anio_fiscal, 2012, 2014), participation_prominent, .))	
	
compress

save "$datadir/core_sample_aps.dta", replace

/////
///
//HAVEN AND NONHAVEN INTERMEDIATES
///
/////

//TERMINAL OWNERSHIP COUNT BY GROUP X DOMICILE
gen terminal_owners_prom = (beneficiarios_pff * inlist(group, 4, 5)) + (beneficiarios_ext * inlist(group, 2, 3))
gen terminal_owners_inv_prom = (beneficiarios_ext * inlist(group, 4, 5)) + (beneficiarios_pff * inlist(group, 2, 3))

gen terminal_owners_10_prom = (beneficiarios_10_pff * inlist(group, 4, 5)) + (beneficiarios_10_ext * inlist(group, 2, 3))
gen terminal_owners_10_inv_prom = (beneficiarios_10_ext * inlist(group, 4, 5)) + (beneficiarios_10_pff * inlist(group, 2, 3))

///
//INTERIOR PRESENCE
///

bys firm_id anio_fiscal: gegen intermediate_pff_int = max(cond(paraiso_fiscal_accionista == "S" & missing(porcentaje_efectivo), 1, 0)) 
bys firm_id anio_fiscal: gegen intermediate_ext_int = max(cond(paraiso_fiscal_accionista != "S" & missing(porcentaje_efectivo), 1, 0))

gen intermediate_prom_int = (intermediate_pff_int * inlist(group, 4, 5)) + (intermediate_ext_int * inlist(group, 2, 3))
gen intermediate_inv_prom_int = (intermediate_ext_int * inlist(group, 4, 5)) + (intermediate_pff_int * inlist(group, 2, 3))

//any interior intermediate presence in group >= 10%
bys firm_id anio_fiscal: gegen intermediate_10_pff_int = max(cond(paraiso_fiscal_accionista == "S" & porcentaje_participacion >= 10 & missing(porcentaje_participacion) == 0 & missing(porcentaje_efectivo), 1, 0)) 
bys firm_id anio_fiscal: gegen intermediate_10_ext_int = max(cond(paraiso_fiscal_accionista != "S" & porcentaje_participacion >= 10 & missing(porcentaje_participacion) == 0 & missing(porcentaje_efectivo), 1, 0))

gen intermediate_10_prom_int = (intermediate_10_pff_int * inlist(group, 4, 5)) + (intermediate_10_ext_int * inlist(group, 2, 3))
gen intermediate_10_inv_prom_int = (intermediate_10_ext_int * inlist(group, 4, 5)) + (intermediate_10_pff_int * inlist(group, 2, 3))

//any interior intermediate presence in group >= 50%
bys firm_id anio_fiscal: gegen intermediate_50_pff_int = max(cond(paraiso_fiscal_accionista == "S" & porcentaje_participacion >= 50 & missing(porcentaje_participacion) == 0 & missing(porcentaje_efectivo), 1, 0)) 
bys firm_id anio_fiscal: gegen intermediate_50_ext_int = max(cond(paraiso_fiscal_accionista != "S" & porcentaje_participacion >= 50 & missing(porcentaje_participacion) == 0 & missing(porcentaje_efectivo), 1, 0))

gen intermediate_50_prom_int = (intermediate_50_pff_int * inlist(group, 4, 5)) + (intermediate_50_ext_int * inlist(group, 2, 3))
gen intermediate_50_inv_prom_int = (intermediate_50_ext_int * inlist(group, 4, 5)) + (intermediate_50_pff_int * inlist(group, 2, 3))

//any interior intermediate presence in group == 100%
bys firm_id anio_fiscal: gegen intermediate_100_pff_int = max(cond(paraiso_fiscal_accionista == "S" & porcentaje_participacion == 100 & missing(porcentaje_participacion) == 0 & missing(porcentaje_efectivo), 1, 0)) 
bys firm_id anio_fiscal: gegen intermediate_100_ext_int = max(cond(paraiso_fiscal_accionista != "S" & porcentaje_participacion == 100 & missing(porcentaje_participacion) == 0 & missing(porcentaje_efectivo), 1, 0))

gen intermediate_100_prom_int = (intermediate_100_pff_int * inlist(group, 4, 5)) + (intermediate_100_ext_int * inlist(group, 2, 3))
gen intermediate_100_inv_prom_int = (intermediate_100_ext_int * inlist(group, 4, 5)) + (intermediate_100_pff_int * inlist(group, 2, 3))

///
//ANY ALT
///

bys firm_id anio_fiscal: has_interior = max(missing(porcentaje_efectivo))

bys firm_id anio_fiscal: gegen any_haven = max(cond(paraiso_fiscal_accionista == "S", 1, 0))
bys firm_id anio_fiscal: gegen any_nonhaven = max(cond(paraiso_fiscal_accionista != "S", 1, 0))

bys firm_id anio_fiscal: gegen any_haven_alt = max(cond(paraiso_fiscal_accionista == "S", 1, 0))
bys firm_id anio_fiscal: gegen any_nonhaven_alt = max(cond(paraiso_fiscal_accionista != "S", 1, 0))

	replace any_haven_alt = . if has_interior == 0
	replace any_nonhaven_alt = . if has_interior == 0

gen any_prom = (any_haven * inlist(group, 4, 5)) + (any_nonhaven * inlist(group, 2, 3))
gen any_prom_alt = (any_haven_alt * inlist(group, 4, 5)) + (any_nonhaven_alt * inlist(group, 2, 3))

gen any_inv_prom = (any_nonhaven * inlist(group, 4, 5)) + (any_haven * inlist(group, 2, 3))
gen any_inv_prom_alt = (any_nonhaven_alt * inlist(group, 4, 5)) + (any_haven_alt * inlist(group, 2, 3))

drop has_interior 

///
//INTERIOR PRESENCE ALT: MISSING IF NO INTERIOR
///
bys firm_id anio_fiscal: gegen intermediate_pff_alt = max(cond(missing(porcentaje_efectivo), paraiso_fiscal_accionista == "S", .)) 
bys firm_id anio_fiscal: gegen intermediate_ext_alt = max(cond(missing(porcentaje_efectivo), paraiso_fiscal_accionista != "S", .))

gen intermediate_prom_alt = (intermediate_pff_alt * inlist(group, 4, 5)) + (intermediate_ext_alt * inlist(group, 2, 3))
gen intermediate_inv_prom_alt = (intermediate_ext_alt * inlist(group, 4, 5)) + (intermediate_pff_alt * inlist(group, 2, 3))

//any interior intermediate presence in group >= 10%
bys firm_id anio_fiscal: gegen intermediate_10_pff_alt = max(cond(missing(porcentaje_efectivo), paraiso_fiscal_accionista == "S" & porcentaje_participacion >= 10 & missing(porcentaje_participacion) == 0, .)) 
bys firm_id anio_fiscal: gegen intermediate_10_ext_alt = max(cond(missing(porcentaje_efectivo), paraiso_fiscal_accionista != "S" & porcentaje_participacion >= 10 & missing(porcentaje_participacion) == 0, .))

gen intermediate_10_prom_alt = (intermediate_10_pff_alt * inlist(group, 4, 5)) + (intermediate_10_ext_alt * inlist(group, 2, 3))
gen intermediate_10_inv_prom_alt = (intermediate_10_ext_alt * inlist(group, 4, 5)) + (intermediate_10_pff_alt * inlist(group, 2, 3))

//any interior intermediate presence in group >= 50%
bys firm_id anio_fiscal: gegen intermediate_50_pff_alt = max(cond(missing(porcentaje_efectivo), paraiso_fiscal_accionista == "S" & porcentaje_participacion >= 50 & missing(porcentaje_participacion) == 0 , .)) 
bys firm_id anio_fiscal: gegen intermediate_50_ext_alt = max(cond(missing(porcentaje_efectivo), paraiso_fiscal_accionista != "S" & porcentaje_participacion >= 50 & missing(porcentaje_participacion) == 0 , .))

gen intermediate_50_prom_alt = (intermediate_50_pff_alt * inlist(group, 4, 5)) + (intermediate_50_ext_alt * inlist(group, 2, 3))
gen intermediate_50_inv_prom_alt = (intermediate_50_ext_alt * inlist(group, 4, 5)) + (intermediate_50_pff_alt * inlist(group, 2, 3))

//any interior intermediate presence in group == 100%
bys firm_id anio_fiscal: gegen intermediate_100_pff_alt = max(cond(missing(porcentaje_efectivo), paraiso_fiscal_accionista == "S" & porcentaje_participacion == 100 & missing(porcentaje_participacion) == 0 , .)) 
bys firm_id anio_fiscal: gegen intermediate_100_ext_alt = max(cond(missing(porcentaje_efectivo), paraiso_fiscal_accionista != "S" & porcentaje_participacion == 100 & missing(porcentaje_participacion) == 0, .))

gen intermediate_100_prom_alt = (intermediate_100_pff_alt * inlist(group, 4, 5)) + (intermediate_100_ext_alt * inlist(group, 2, 3))
gen intermediate_100_inv_prom_alt = (intermediate_100_ext_alt * inlist(group, 4, 5)) + (intermediate_100_pff_alt * inlist(group, 2, 3))

///
//ANY INTERMEDIATE PRESENCE
///
//any intermediate presence in group
bys firm_id anio_fiscal: gegen intermediate_pff = max(cond(paraiso_fiscal_accionista == "S", 1, 0)) 
bys firm_id anio_fiscal: gegen intermediate_ext = max(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico != "ECUADOR", 1, 0))
bys firm_id anio_fiscal: gegen intermediate_nac = max(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico == "ECUADOR", 1, 0))
bys firm_id anio_fiscal: gegen intermediate_vac = max(cond(paraiso_fiscal_accionista == "" & pais_accionista_unico == "", 1, 0))

gen intermediate_prominent = (intermediate_pff * inlist(group, 4, 5)) + (intermediate_ext * inlist(group, 2, 3))

//any intermediate presence in group >= 10%
bys firm_id anio_fiscal: gegen intermediate_10_pff = max(cond(paraiso_fiscal_accionista == "S" & porcentaje_participacion >= 10, 1, 0)) 
bys firm_id anio_fiscal: gegen intermediate_10_ext = max(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico != "ECUADOR" & porcentaje_participacion >= 10, 1, 0))
bys firm_id anio_fiscal: gegen intermediate_10_nac = max(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico == "ECUADOR" & porcentaje_participacion >= 10, 1, 0))
bys firm_id anio_fiscal: gegen intermediate_10_vac = max(cond(paraiso_fiscal_accionista == "" & pais_accionista_unico == "" & porcentaje_participacion >= 10, 1, 0))

gen intermediate_10_prominent = (intermediate_10_pff * inlist(group, 4, 5)) + (intermediate_10_ext * inlist(group, 2, 3))

//any intermediate presence in group >= 50%
bys firm_id anio_fiscal: gegen intermediate_50_pff = max(cond(paraiso_fiscal_accionista == "S" & porcentaje_participacion >= 50, 1, 0)) 
bys firm_id anio_fiscal: gegen intermediate_50_ext = max(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico != "ECUADOR" & porcentaje_participacion >= 50, 1, 0))
bys firm_id anio_fiscal: gegen intermediate_50_nac = max(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico == "ECUADOR" & porcentaje_participacion >= 50, 1, 0))
bys firm_id anio_fiscal: gegen intermediate_50_vac = max(cond(paraiso_fiscal_accionista == "" & pais_accionista_unico == "" & porcentaje_participacion >= 50, 1, 0))

gen intermediate_50_prominent = (intermediate_50_pff * inlist(group, 4, 5)) + (intermediate_50_ext * inlist(group, 2, 3))

//any intermediate presence in group == 100%
bys firm_id anio_fiscal: gegen intermediate_100_pff = max(cond(paraiso_fiscal_accionista == "S" & porcentaje_participacion == 100, 1, 0)) 
bys firm_id anio_fiscal: gegen intermediate_100_ext = max(cond(paraiso_fiscal_accionista != "S" & pais_accionista_unico != "ECUADOR" & porcentaje_participacion == 100, 1, 0))

bys firm_id anio_fiscal: gegen intermediate_pff_max = max(cond(paraiso_fiscal_accionista == "S", porcentaje_participacion, 0))

gen intermediate_100_prominent = (intermediate_100_pff * inlist(group, 4, 5)) + (intermediate_100_ext * inlist(group, 2, 3))

///
//ABBREVIATED COLLAPSE FOR THE CORE SAMPLE
///
preserve

	collapse (firstnm) group_assign porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais aps_residual_pais_other beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_concentration terminal_owners_10 terminal_owners group exposure prominent_2014 participation_prominent participation_prominent_0 participation_inverse_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_pff_max intermediate_50_prominent average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign treatment_major treatment_minor bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt intermediate_100_pff intermediate_100_ext intermediate_100_prominent t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt prominent_2012_2014 bf_persona_unique_50 bf_persona_unique_100 bf_persona_50 has_majority_terminal_owner has_whole_terminal_owner terminal_owners_prom terminal_owners_10_prom intermediate_pff_int intermediate_ext_int intermediate_prom_int intermediate_10_pff_int intermediate_10_ext_int intermediate_10_prom_int intermediate_50_pff_int intermediate_50_ext_int intermediate_50_prom_int intermediate_100_pff_int intermediate_100_ext_int intermediate_100_prom_int intermediate_100_prom_alt intermediate_50_prom_alt intermediate_10_prom_alt intermediate_prom_alt intermediate_pff_alt intermediate_ext_alt intermediate_10_pff_alt intermediate_10_ext_alt intermediate_50_pff_alt intermediate_50_ext_alt intermediate_100_pff_alt intermediate_100_ext_alt any_haven any_nonhaven any_nonhaven_alt any_haven_alt any_prom any_prom_alt any_inv_prom any_inv_prom_alt, by(firm_id anio_fiscal)
	
	gen persona_prominent = persona_pff if inlist(group, 4, 5)
		replace persona_prominent = persona_extranjera if inlist(group, 2, 3)

	///
	//END PROCESSING
	///

	compress

	fillin firm_id anio_fiscal
	
	///
	//FILLIN, STARTING WITH COMPLIANCE AND DEFINITION-ORIENTED VARIABLES
	///
	gen aps = 1 - _fillin

	gsort firm_id + _fillin
	foreach v in group_assign group treatment_major treatment_minor exposure prominent_2014 bf_persona_alt t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt {

		replace `v' = `v'[_n-1] if missing(`v') & firm_id == firm_id[_n-1]
		
	}

	drop _fillin

	gsort firm_id + anio_fiscal

	///
	//generating alt rectangularization variables
	///

	foreach v in bf_persona bf_persona_100 any_bf_persona bf_empresa complete inconsistent aps_residual_0 percent_declarado persona_prominent {

		gen `v'_r = (`v' * aps)
			replace `v'_r = 0 if aps == 0 & missing(`v'_r)
		
	}

	gen incomplete_r = (incomplete * aps)
		replace incomplete_r = 1 if aps == 0 & missing(incomplete_r)
		
	gen aps_residual_r = (aps_residual * aps)
		replace aps_residual_r = 100 if aps == 0 & missing(aps_residual_r)
		
	///
	//CARRY FORWARD 2012, 2013 OBSERVARTIONS TO MISSING 2013 or 2014
	///

	hashsort firm_id + anio_fiscal
	
	foreach v in porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_concentration terminal_owners_10 terminal_owners participation_prominent participation_prominent_0 participation_inverse_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_pff_max intermediate_50_prominent average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt intermediate_100_pff intermediate_100_ext intermediate_100_prominent persona_prominent bf_persona_unique_50 bf_persona_unique_100 bf_persona_50 has_majority_terminal_owner has_whole_terminal_owner terminal_owners_prom terminal_owners_10_prom intermediate_pff_int intermediate_ext_int intermediate_prom_int intermediate_10_pff_int intermediate_10_ext_int intermediate_10_prom_int intermediate_50_pff_int intermediate_50_ext_int intermediate_50_prom_int intermediate_100_pff_int intermediate_100_ext_int intermediate_100_prom_int intermediate_100_prom_alt intermediate_50_prom_alt intermediate_10_prom_alt intermediate_prom_alt intermediate_pff_alt intermediate_ext_alt intermediate_10_pff_alt intermediate_10_ext_alt intermediate_50_pff_alt intermediate_50_ext_alt intermediate_100_pff_alt intermediate_100_ext_alt any_haven any_nonhaven any_nonhaven_alt any_haven_alt any_prom any_prom_alt any_inv_prom any_inv_prom_alt {
		
		replace `v' = `v'[_n-1] if inrange(anio_fiscal, 2013, 2014) & firm_id == firm_id[_n-1] & missing(`v') & missing(`v'[_n-1]) == 0 
		
	}	
		
	compress

	order firm_id anio_fiscal aps group_assign group treatment_major treatment_minor exposure prominent_2014 /// meta variables and exposure
		porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac /// participation by domicile
		percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais aps_residual_pais_other average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder /// compliance, meta aps
		beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac /// counts of owners
		terminal_ownership_concentration terminal_owners_10 terminal_owners /// ownership concentration
		participation_prominent participation_prominent_0 participation_inverse_prominent /// main ownership outcomes
		intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_100_pff intermediate_pff_max intermediate_50_prominent intermediate_100_pff intermediate_100_ext intermediate_100_prominent ///intermediate ownership 
		empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign /// disaggregated by domicile and type
		bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt /// beneficial ownership
		aps bf_persona_r bf_persona
		
	save "$datadir/core_sample_aps_processed.dta", replace

restore
	
keep if inlist(group, 2, 3, 4, 5)
	
///	
//GENERATE INTERMEDIATE OWNERSHIP VARIABLES 
///

gen intermediate_inv_prominent = (intermediate_ext * inlist(group, 4, 5)) + (intermediate_pff * inlist(group, 2, 3))
gen intermediate_10_inv_prominent = (intermediate_10_ext * inlist(group, 4, 5)) + (intermediate_10_pff * inlist(group, 2, 3))
gen intermediate_50_inv_prominent = (intermediate_50_ext * inlist(group, 4, 5)) + (intermediate_50_pff * inlist(group, 2, 3))
gen intermediate_100_inv_prominent = (intermediate_100_ext * inlist(group, 4, 5)) + (intermediate_100_pff * inlist(group, 2, 3))

//generating 2014 main group shareholder list and variable for whether one of these shareholders is present by year
gen maingroup_shareholder_2014 = (anio_fiscal == max_year_2012_2014) & (pais_extranjero == prominent_group) //indicator for is 2014 (or max year)
bys firm_id maingroup_shareholder_2014: gen list_maingroup_shareholder_2014 = id_accionista_anon[1] if maingroup_shareholder_2014 == 1
by firm_id maingroup_shareholder_2014: replace list_maingroup_shareholder_2014 = list_maingroup_shareholder_2014[_n-1] + "," + id_accionista_anon if _n > 1 & maingroup_shareholder_2014 == 1
by firm_id maingroup_shareholder_2014: replace list_maingroup_shareholder_2014 = list_maingroup_shareholder_2014[_N] if maingroup_shareholder_2014 == 1
gsort firm_id - list_maingroup_shareholder_2014
bys firm_id: replace list_maingroup_shareholder_2014 = list_maingroup_shareholder_2014[_n-1] if missing(list_maingroup_shareholder_2014)
//this yields a list of the main group shareholders in 2014

//generating the dummy variable for whether in a firm-year a shareholder appears as one of the 2014 maingroup plurality shareholders
bys firm_id anio_fiscal: gegen has_maingroup_shareholder_2014 = max(cond(strpos(list_maingroup_shareholder_2014, id_accionista_anon) != 0, 1, 0))

//generating 2014 main group plurality shareholder list
//same idea as before, but isolating the plurality 2014 main group shareholder

//id of plurality main group terminal shareholders in 2014
bys firm_id: gegen max_maingroup_share_2014 = max(cond((anio_fiscal == max_year_2012_2014) & (pais_extranjero == prominent_group), porcentaje_efectivo, .))

	//there is a floating point problem, so rounding here
gen is_max_prom_sh_2014 = (anio_fiscal == max_year_2012_2014) & (pais_extranjero == prominent_group) & ((round(porcentaje_efectivo, .001) == round(max_maingroup_share_2014, .001)) | (round(porcentaje_efectivo, .01) == round(max_maingroup_share_2014, .01)))

bys firm_id is_max_prom_sh_2014: gen list_maingroup_plurality_sh_2014 = id_accionista_anon[1] if is_max_prom_sh_2014 == 1
by firm_id is_max_prom_sh_2014: replace list_maingroup_plurality_sh_2014 = list_maingroup_plurality_sh_2014[_n-1] + "," + id_accionista_anon if _n > 1 & is_max_prom_sh_2014 == 1
by firm_id is_max_prom_sh_2014: replace list_maingroup_plurality_sh_2014 = list_maingroup_plurality_sh_2014[_N] if is_max_prom_sh_2014 == 1
gsort firm_id - list_maingroup_plurality_sh_2014
bys firm_id: replace list_maingroup_plurality_sh_2014 = list_maingroup_plurality_sh_2014[_n-1] if missing(list_maingroup_plurality_sh_2014)

//generating the dummy variable for whether in a firm-year a shareholder appears as one of the 2014 maingroup plurality shareholders
bys firm_id anio_fiscal: gegen has_maingroup_plurality_sh_2014 = max(cond(strpos(list_maingroup_plurality_sh_2014, id_accionista_anon) != 0, 1, 0))

///
//collapse to firm-year level
///
collapse (firstnm) group_assign porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais aps_residual_pais_other beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_concentration terminal_owners_10 terminal_owners group exposure prominent_2014 participation_prominent participation_prominent_0 participation_inverse_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_inv_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_10_inv_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_pff_max intermediate_50_prominent intermediate_50_inv_prominent average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder has_maingroup_shareholder_2014 has_maingroup_plurality_sh_2014 empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign treatment_major treatment_minor bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt intermediate_100_pff intermediate_100_ext intermediate_100_prominent intermediate_100_inv_prominent terminal_owners_prom terminal_owners_inv_prom terminal_owners_10_prom terminal_owners_10_inv_prom intermediate_pff_int intermediate_ext_int intermediate_prom_int intermediate_inv_prom_int intermediate_10_pff_int intermediate_10_ext_int intermediate_10_prom_int intermediate_10_inv_prom_int intermediate_50_pff_int intermediate_50_ext_int intermediate_50_prom_int intermediate_50_inv_prom_int intermediate_100_pff_int intermediate_100_ext_int intermediate_100_prom_int intermediate_100_inv_prom_int t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt prominent_2012_2014 bf_persona_unique_50 bf_persona_unique_100 bf_persona_50 has_majority_terminal_owner has_whole_terminal_owner intermediate_100_inv_prom_alt intermediate_100_prom_alt intermediate_50_inv_prom_alt intermediate_50_prom_alt intermediate_10_inv_prom_alt intermediate_10_prom_alt intermediate_inv_prom_alt intermediate_prom_alt intermediate_pff_alt intermediate_ext_alt intermediate_10_pff_alt intermediate_10_ext_alt intermediate_50_pff_alt intermediate_50_ext_alt intermediate_100_pff_alt intermediate_100_ext_alt any_haven any_nonhaven any_nonhaven_alt any_haven_alt any_prom any_prom_alt any_inv_prom any_inv_prom_alt , by(firm_id anio_fiscal)

gen persona_prominent = persona_pff if inlist(group, 4, 5)
	replace persona_prominent = persona_extranjera if inlist(group, 2, 3)

gen persona_inverse_prominent = persona_extranjera if inlist(group, 4, 5)
	replace persona_inverse_prominent = persona_pff if inlist(group, 2, 3)

///
//END PROCESSING
///

compress

fillin firm_id anio_fiscal

///
//FILLIN, STARTING WITH COMPLIANCE AND DEFINITION-ORIENTED VARIABLES
///
gen aps = 1 - _fillin

gsort firm_id + _fillin
foreach v in group_assign group treatment_major treatment_minor exposure prominent_2014 bf_persona_alt t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt {

	replace `v' = `v'[_n-1] if missing(`v') & firm_id == firm_id[_n-1]
	
}

drop _fillin

gsort firm_id + anio_fiscal

///
//generating alt rectangularization variables
///

foreach v in bf_persona bf_persona_100 any_bf_persona bf_empresa complete inconsistent aps_residual_0 percent_declarado persona_prominent persona_inverse_prominent {

	gen `v'_r = (`v' * aps)
		replace `v'_r = 0 if aps == 0 & missing(`v'_r)
	
}

gen incomplete_r = (incomplete * aps)
	replace incomplete_r = 1 if aps == 0 & missing(incomplete_r)
	
gen aps_residual_r = (aps_residual * aps)
	replace aps_residual_r = 100 if aps == 0 & missing(aps_residual_r)
	
///
//CARRY FORWARD 2012, 2013 OBSERVARTIONS TO MISSING 2013 or 2014
///

hashsort firm_id + anio_fiscal

foreach v in porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac terminal_ownership_concentration terminal_owners_10 terminal_owners exposure prominent_2014 participation_prominent participation_prominent_0 participation_inverse_prominent intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_inv_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_10_inv_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_pff_max intermediate_50_prominent intermediate_50_inv_prominent average_chain_length max_chain_length max_shareholder has_maingroup_shareholder_2014 has_maingroup_plurality_sh_2014 empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign bf_persona bf_persona_100 any_bf_persona bf_empresa treatment_major treatment_minor bf_persona_alt intermediate_100_pff intermediate_100_ext intermediate_100_prominent intermediate_100_inv_prominent b_average_chain_length b_max_chain_length t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt persona_prominent persona_inverse_prominent terminal_owners_prom terminal_owners_inv_prom terminal_owners_10_prom terminal_owners_10_inv_prom intermediate_pff_int intermediate_ext_int intermediate_prom_int intermediate_inv_prom_int intermediate_10_pff_int intermediate_10_ext_int intermediate_10_prom_int intermediate_10_inv_prom_int intermediate_50_pff_int intermediate_50_ext_int intermediate_50_prom_int intermediate_50_inv_prom_int intermediate_100_pff_int intermediate_100_ext_int intermediate_100_prom_int intermediate_100_inv_prom_int bf_persona_unique_50 bf_persona_unique_100 bf_persona_50 has_majority_terminal_owner has_whole_terminal_owner intermediate_100_inv_prom_alt intermediate_100_prom_alt intermediate_50_inv_prom_alt intermediate_50_prom_alt intermediate_10_inv_prom_alt intermediate_10_prom_alt intermediate_inv_prom_alt intermediate_prom_alt intermediate_pff_alt intermediate_ext_alt intermediate_10_pff_alt intermediate_10_ext_alt intermediate_50_pff_alt intermediate_50_ext_alt intermediate_100_pff_alt intermediate_100_ext_alt any_haven any_nonhaven any_nonhaven_alt any_haven_alt any_prom any_prom_alt any_inv_prom any_inv_prom_alt {
	
	replace `v' = `v'[_n-1] if inrange(anio_fiscal, 2013, 2014) & firm_id == firm_id[_n-1] & missing(`v') & missing(`v'[_n-1]) == 0 
	
}

compress

order firm_id anio_fiscal aps group_assign group treatment_major treatment_minor exposure prominent_2014 /// meta variables and exposure
	porcentaje_pff porcentaje_ext porcentaje_nac porcentaje_vac /// participation by domicile
	percent_declarado incomplete complete inconsistent aps_residual aps_residual_0 aps_residual_pais aps_residual_pais_other average_chain_length max_chain_length b_average_chain_length b_max_chain_length max_shareholder /// compliance, meta aps
	beneficiarios_pff beneficiarios_ext beneficiarios_nac beneficiarios_vac beneficiarios_10_pff beneficiarios_10_ext beneficiarios_10_nac beneficiarios_10_vac /// counts of owners
	terminal_ownership_concentration terminal_owners_10 terminal_owners /// ownership concentration
	participation_prominent participation_prominent_0 participation_inverse_prominent /// main ownership outcomes
	intermediate_pff intermediate_ext intermediate_nac intermediate_vac intermediate_prominent intermediate_inv_prominent intermediate_10_pff intermediate_10_ext intermediate_10_nac intermediate_10_vac intermediate_10_prominent intermediate_10_inv_prominent intermediate_50_pff intermediate_50_ext intermediate_50_nac intermediate_50_vac intermediate_100_pff intermediate_pff_max intermediate_50_prominent intermediate_50_inv_prominent intermediate_100_pff intermediate_100_ext intermediate_100_prominent intermediate_100_inv_prominent ///intermediate ownership
	has_maingroup_shareholder_2014 has_maingroup_plurality_sh_2014 /// owners from the 2014 main group 
	empresa_extranjera persona_extranjera persona_nacional empresa_pff persona_pff empresa_nacional persona_foreign empresa_foreign  /// disaggregated by domicile and type
	bf_persona bf_persona_100 any_bf_persona bf_empresa bf_persona_alt /// beneficial ownership
	aps bf_persona_r bf_persona
	
save "$datadir/main_sample_aps_processed.dta", replace
*/


/****************************/
/* F101 VARIABLE PROCESSING	*/
/****************************/	
	
forv t = 2012/2019 {

	import delimited "F:\DTO_ESTUDIOS_E2\B_INVESTIGADORES_EXTERNOS\202201_BANCO_MUNDIAL_PBACHAS\01_DATA\F101\completo\F101_`t'.csv", clear
	
	cap ren numero_identificacion_an firm_id
	cap ren id_an firm_id
	
	cap ren totas_costos_gastos_3380 total_costos_gastos_3380
	
	keep firm_id anio_fiscal total_ingresos_1930 exportaciones_netas_1820 expor_netas_servi_1822 total_costos_gastos_3380 participacion_tbj_15_3440 utilidad_gravable_3560 perdida_3570 inversiones_corrientes_180 utilidad_ejercicio_3420 perdida_ejercicio_3430 uti_reinvertir_cpz_3580 impuesto_renta_causado_3600 impuesto_renta_pagar_3680 total_activo_1080 total_activos_fijos_690 total_activos_diferidos_780 total_activo_corriente_470 total_activos_largo_plazo_1070 tot_activo_no_corriente_1077 total_pasivos_diferidos_1600 total_pasivos_1620 total_patrimonio_neto_1780 porcion_comp_soc_no_inf_3576 porcion_comp_soc_si_inf_3578 gto_comisiones_locales_2880 gasto_ame_local_2820 gto_inp_ter_rel_local_2970 gto_comisiones_exterior_2900 gasto_ame_exterior_2840 gto_iba_exterior_2950 gto_inp_ter_rel_exterios_2990 gin_ade_ppa_gasto_3150 div_percibidos_locales_1870 cdp_pve_crr_rel_locales_1110 ocp_crr_rel_locales_1240 cdp_pve_crr_locales_1160 obl_ifi_crr_locales_1180 cdp_pve_crr_rel_exterior_1120 cdp_pve_crr_nre_locales_1130 cdp_pve_crr_nre_exterior_1140 ocp_crr_rel_exterior_1250 ocp_crr_nre_locales_1260 ocp_crr_nre_exterior_1270 obl_ifi_crr_exterior_1190 obl_ifi_crr_ext_no_rel_1195 obl_ifi_crr_loc_no_rel_1185 ocp_lpl_rel_locales_1480 ocp_lpl_rel_exterior_1490 ocp_lpl_nre_locales_1500 cdp_pve_lpl_rel_locales_1350 cdp_pve_lpl_rel_exterior_1360 cdp_pve_lpl_nre_locales_1370 obl_ifi_no_rel_ext_1435 obl_ifi_rel_loc_1405 obl_ifi_no_rel_loc_1425 ocp_lpl_nre_exterior_1510 cdp_pve_lpl_nre_exterior_1380 obl_ifi_rel_ext_1415 plusvalias_695 derechos_llave_mps_700 ade_mej_bi_arr_por_arr_ope_715 derechos_concesion_725 otros_activos_diferidos_760 amo_acd_act_diferidos_770 prv_por_deterioro_vai_772 inv_no_cte_sub_cto_782 inv_no_cte_sub_ajt_acu_vpp_783 inv_no_cte_sub_aso_cto_787 inv_no_ct_sb_as_ajt_ac_vpp_788 inc_neg_con_cto_791 inc_neg_cn_cto_ajt_acu_vpp_792 det_acu_val_inv_no_cte_789 otr_inversiones_lpl_800 cdb_cli_rel_locales_200 cdb_cli_rel_exterior_210 cdb_cli_nre_locales_220 cdb_cli_nre_exterior_230 ocd_cli_rel_locales_240 ocd_cli_rel_exterior_250 ocd_cli_nre_locales_260 ocd_cli_nre_exterior_270 cdb_lpl_cli_rel_locales_810 cdb_lpl_cli_rel_exterior_820 cdb_lpl_cli_nre_locales_830 cdb_lpl_cli_nre_exterior_840 ocd_lpl_cli_rel_locales_860 ocd_lpl_cli_rel_exterior_870 ocd_lpl_cli_nre_locales_880 ocd_lpl_cli_nre_exterior_890 costo_ssa_qcm_2280 gasto_ssa_qcm_2290 costo_bsi_qnc_2300 gasto_bsi_qnc_2310 costo_ies_2360 gasto_ies_2370 cto_hon_pro_dietas_2380 gto_hon_pro_dietas_2390 cto_hon_pro_soc_2400 gto_hon_pro_soc_2410 cto_provisiones_jpa_2730 gto_provisiones_jpa_2740   tot_pasivos_corrientes_1340 cto_provisiones_desahucio_2750 gto_provisiones_desahucio_2760 cto_otr_gto_ben_emp_2752 gto_otr_gto_ben_emp_2754 vnd_ssa_qcm_2295 vnd_bsi_qnc_2315 vnd_ies_2375 vnd_hon_pro_dietas_2395 vnd_hon_pro_soc_2415 vpn_provisiones_jpa_2745 vnd_provisiones_desahucio_2765 vnd_gto_otr_gto_ben_emp_2756 vln_eaf_tdc_1800 vln_eaf_tce_1810 venta_neta_activos_fijos_1940 div_por_pagar_975 tcm_corriente_exterior_1300 credito_mutuo_corriente_1310 obl_ifi_lpl_locales_1420 obl_ifi_lpl_exterior_1430 tot_obl_ifi_largo_plazo_1440 pac_lpl_locales_1450 pac_lpl_exterior_1460 total_pac_cma_lpl_1470 pas_cont_arr_fin_nc_1525 tcm_lpl_exterior_1530 gto_int_bancarios_local_2930 gto_inp_ter_nre_local_3010 gto_inp_ter_nre_exterior_3030 inc_sub_aso_785 inc_neg_con_795 utilidad_ndi_eje_ant_1740
	
	destring anio_fiscal total_ingresos_1930 exportaciones_netas_1820 expor_netas_servi_1822 total_costos_gastos_3380 participacion_tbj_15_3440 utilidad_gravable_3560 perdida_3570 inversiones_corrientes_180 utilidad_ejercicio_3420 perdida_ejercicio_3430 uti_reinvertir_cpz_3580 impuesto_renta_causado_3600 impuesto_renta_pagar_3680 total_activo_1080 total_activos_fijos_690 total_activos_diferidos_780 total_activo_corriente_470 total_activos_largo_plazo_1070 tot_activo_no_corriente_1077 total_pasivos_diferidos_1600 total_pasivos_1620 total_patrimonio_neto_1780 porcion_comp_soc_no_inf_3576 porcion_comp_soc_si_inf_3578 gto_comisiones_locales_2880 gasto_ame_local_2820 gto_inp_ter_rel_local_2970 gto_comisiones_exterior_2900 gasto_ame_exterior_2840 gto_iba_exterior_2950 gto_inp_ter_rel_exterios_2990 gin_ade_ppa_gasto_3150 div_percibidos_locales_1870 cdp_pve_crr_rel_locales_1110 ocp_crr_rel_locales_1240 cdp_pve_crr_locales_1160 obl_ifi_crr_locales_1180 cdp_pve_crr_rel_exterior_1120 cdp_pve_crr_nre_locales_1130 cdp_pve_crr_nre_exterior_1140 ocp_crr_rel_exterior_1250 ocp_crr_nre_locales_1260 ocp_crr_nre_exterior_1270 obl_ifi_crr_exterior_1190 obl_ifi_crr_ext_no_rel_1195 obl_ifi_crr_loc_no_rel_1185 ocp_lpl_rel_locales_1480 ocp_lpl_rel_exterior_1490 ocp_lpl_nre_locales_1500 cdp_pve_lpl_rel_locales_1350 cdp_pve_lpl_rel_exterior_1360 cdp_pve_lpl_nre_locales_1370 obl_ifi_no_rel_ext_1435 obl_ifi_rel_loc_1405 obl_ifi_no_rel_loc_1425 ocp_lpl_nre_exterior_1510 cdp_pve_lpl_nre_exterior_1380 obl_ifi_rel_ext_1415 plusvalias_695 derechos_llave_mps_700 ade_mej_bi_arr_por_arr_ope_715 derechos_concesion_725 otros_activos_diferidos_760 amo_acd_act_diferidos_770 prv_por_deterioro_vai_772 inv_no_cte_sub_cto_782 inv_no_cte_sub_ajt_acu_vpp_783 inv_no_cte_sub_aso_cto_787 inv_no_ct_sb_as_ajt_ac_vpp_788 inc_neg_con_cto_791 inc_neg_cn_cto_ajt_acu_vpp_792 det_acu_val_inv_no_cte_789 otr_inversiones_lpl_800 cdb_cli_rel_locales_200 cdb_cli_rel_exterior_210 cdb_cli_nre_locales_220 cdb_cli_nre_exterior_230 ocd_cli_rel_locales_240 ocd_cli_rel_exterior_250 ocd_cli_nre_locales_260 ocd_cli_nre_exterior_270 cdb_lpl_cli_rel_locales_810 cdb_lpl_cli_rel_exterior_820 cdb_lpl_cli_nre_locales_830 cdb_lpl_cli_nre_exterior_840 ocd_lpl_cli_rel_locales_860 ocd_lpl_cli_rel_exterior_870 ocd_lpl_cli_nre_locales_880 ocd_lpl_cli_nre_exterior_890 costo_ssa_qcm_2280 gasto_ssa_qcm_2290 costo_bsi_qnc_2300 gasto_bsi_qnc_2310 costo_ies_2360 gasto_ies_2370 cto_hon_pro_dietas_2380 gto_hon_pro_dietas_2390 cto_hon_pro_soc_2400 gto_hon_pro_soc_2410 cto_provisiones_jpa_2730 gto_provisiones_jpa_2740   tot_pasivos_corrientes_1340 cto_provisiones_desahucio_2750 gto_provisiones_desahucio_2760 cto_otr_gto_ben_emp_2752 gto_otr_gto_ben_emp_2754 vnd_ssa_qcm_2295 vnd_bsi_qnc_2315 vnd_ies_2375 vnd_hon_pro_dietas_2395 vnd_hon_pro_soc_2415 vpn_provisiones_jpa_2745 vnd_provisiones_desahucio_2765 vnd_gto_otr_gto_ben_emp_2756 vln_eaf_tdc_1800 vln_eaf_tce_1810 venta_neta_activos_fijos_1940 div_por_pagar_975 tcm_corriente_exterior_1300 credito_mutuo_corriente_1310 obl_ifi_lpl_locales_1420 obl_ifi_lpl_exterior_1430 tot_obl_ifi_largo_plazo_1440 pac_lpl_locales_1450 pac_lpl_exterior_1460 total_pac_cma_lpl_1470 pas_cont_arr_fin_nc_1525 tcm_lpl_exterior_1530 gto_int_bancarios_local_2930 gto_inp_ter_nre_local_3010 gto_inp_ter_nre_exterior_3030 inc_sub_aso_785 inc_neg_con_795 utilidad_ndi_eje_ant_1740, force replace dpcomma
	
	compress
	
	tempfile f101_`t'
	save `f101_`t'', replace
	
}	
	
clear

forv t = 2012/2019 {	
	
	append using `f101_`t''
	
}	

save "$datadir/f101_long.dta", replace

///
//PROCESS THE LONG F101 FILE
///
gegen agregated_debt_int = rowtotal(div_por_pagar_975 cdp_pve_crr_rel_locales_1110 cdp_pve_crr_rel_exterior_1120 cdp_pve_crr_nre_locales_1130 cdp_pve_crr_nre_exterior_1140 obl_ifi_crr_locales_1180 obl_ifi_crr_exterior_1190 obl_ifi_crr_ext_no_rel_1195 obl_ifi_crr_loc_no_rel_1185 cdp_pve_crr_rel_exterior_1120 cdp_pve_crr_nre_locales_1130 cdp_pve_crr_nre_exterior_1140 ocp_crr_rel_exterior_1250 ocp_crr_rel_locales_1240 cdp_pve_crr_rel_locales_1110 ocp_crr_nre_locales_1260 ocp_crr_nre_exterior_1270 tcm_corriente_exterior_1300 credito_mutuo_corriente_1310 cdp_pve_lpl_rel_locales_1350 cdp_pve_lpl_rel_exterior_1360 cdp_pve_lpl_nre_locales_1370 cdp_pve_lpl_nre_exterior_1380 obl_ifi_lpl_locales_1420 obl_ifi_lpl_exterior_1430 tot_obl_ifi_largo_plazo_1440 pac_lpl_locales_1450 pac_lpl_exterior_1460 total_pac_cma_lpl_1470 ocp_lpl_rel_locales_1480 ocp_lpl_rel_exterior_1490 ocp_lpl_nre_locales_1500 cdp_pve_lpl_rel_exterior_1360 pas_cont_arr_fin_nc_1525 tcm_lpl_exterior_1530 gasto_ame_local_2820 gasto_ame_exterior_2840 gto_comisiones_locales_2880 gto_comisiones_exterior_2900 gto_iba_exterior_2950 gto_inp_ter_rel_exterios_2990 gto_inp_ter_rel_local_2970 gin_ade_ppa_gasto_3150 gto_inp_ter_nre_local_3010 gto_inp_ter_nre_exterior_3030)	
	
gegen local_related = rowtotal(cdp_pve_crr_rel_locales_1110 ocp_crr_rel_locales_1240 cdp_pve_lpl_rel_locales_1350 ocp_lpl_rel_locales_1480 gto_inp_ter_rel_local_2970)
gegen local_unrelated = rowtotal(cdp_pve_crr_nre_locales_1130 ocp_crr_nre_locales_1260 cdp_pve_lpl_nre_locales_1370 ocp_lpl_nre_locales_1500 gto_inp_ter_nre_local_3010)	
gegen foreign_related = rowtotal(cdp_pve_crr_rel_exterior_1120 ocp_crr_rel_exterior_1250 cdp_pve_lpl_rel_exterior_1360 ocp_lpl_rel_exterior_1490 gto_inp_ter_rel_exterios_2990)
gegen foreign_unrelated = rowtotal(cdp_pve_crr_nre_exterior_1140 ocp_crr_nre_exterior_1270 cdp_pve_lpl_nre_exterior_1380 ocp_lpl_nre_exterior_1510 gto_inp_ter_nre_exterior_3030)
	
drop div_por_pagar_975 tcm_corriente_exterior_1300 credito_mutuo_corriente_1310 obl_ifi_lpl_locales_1420 obl_ifi_lpl_exterior_1430 tot_obl_ifi_largo_plazo_1440 pac_lpl_locales_1450 pac_lpl_exterior_1460 total_pac_cma_lpl_1470 pas_cont_arr_fin_nc_1525 tcm_lpl_exterior_1530 gto_int_bancarios_local_2930 gto_inp_ter_nre_local_3010 gto_inp_ter_nre_exterior_3030
	
ren total_activos_largo_plazo_1070 total_activos_lp_1070
ren div_percibidos_locales_1870 dividendos_percibidos
ren tot_pasivos_corrientes_1340 passive_c 
ren total_pasivos_1620 total_passive
ren total_activo_corriente_470 activos_c
ren total_activo_1080 total_assets
ren total_patrimonio_neto_1780 total_capital

//liabilities by geography and relation
gegen passive_c_related_local = rowtotal(cdp_pve_crr_rel_locales_1110 ocp_crr_rel_locales_1240 obl_ifi_crr_locales_1180)
drop cdp_pve_crr_rel_locales_1110 ocp_crr_rel_locales_1240 obl_ifi_crr_locales_1180
	
gegen passive_c_unrelated_local = rowtotal(cdp_pve_crr_nre_locales_1130 cdp_pve_crr_locales_1160 obl_ifi_crr_loc_no_rel_1185)
drop cdp_pve_crr_nre_locales_1130 cdp_pve_crr_locales_1160 obl_ifi_crr_loc_no_rel_1185

gegen passive_c_related_extranjero = rowtotal(cdp_pve_crr_rel_exterior_1120 ocp_crr_rel_exterior_1250 obl_ifi_crr_exterior_1190)
drop cdp_pve_crr_rel_exterior_1120 ocp_crr_rel_exterior_1250 obl_ifi_crr_exterior_1190

gegen passive_c_unrelated_extranjero = rowtotal(cdp_pve_crr_nre_exterior_1140 cdp_pve_crr_nre_exterior_1140 obl_ifi_crr_ext_no_rel_1195)	
drop cdp_pve_crr_nre_exterior_1140 cdp_pve_crr_nre_exterior_1140 obl_ifi_crr_ext_no_rel_1195

gegen passive_l_related_local = rowtotal(passive_c_related_local cdp_pve_lpl_rel_locales_1350 obl_ifi_rel_loc_1405)
drop cdp_pve_lpl_rel_locales_1350 obl_ifi_rel_loc_1405

gegen passive_l_unrelated_local = rowtotal(passive_c_unrelated_local ocp_lpl_nre_locales_1500 cdp_pve_lpl_nre_locales_1370 obl_ifi_no_rel_loc_1425)
drop ocp_lpl_nre_locales_1500 cdp_pve_lpl_nre_locales_1370 obl_ifi_no_rel_loc_1425

gegen passive_l_related_extranjero = rowtotal(passive_c_related_extranjero cdp_pve_lpl_rel_exterior_1360 ocp_lpl_rel_exterior_1490 obl_ifi_rel_ext_1415)
drop cdp_pve_lpl_rel_exterior_1360 ocp_lpl_rel_exterior_1490 obl_ifi_rel_ext_1415

gegen passive_l_unrelated_extranjero = rowtotal(passive_c_unrelated_extranjero ocp_lpl_nre_exterior_1510 cdp_pve_lpl_nre_exterior_1380 obl_ifi_no_rel_ext_1435)
drop ocp_lpl_nre_exterior_1510 cdp_pve_lpl_nre_exterior_1380 obl_ifi_no_rel_ext_1435

//more assets
gegen activos_intangibles = rowtotal(plusvalias_695 derechos_llave_mps_700 ade_mej_bi_arr_por_arr_ope_715 derechos_concesion_725 otros_activos_diferidos_760 amo_acd_act_diferidos_770 prv_por_deterioro_vai_772)
drop plusvalias_695 derechos_llave_mps_700 ade_mej_bi_arr_por_arr_ope_715 derechos_concesion_725 otros_activos_diferidos_760 amo_acd_act_diferidos_770 prv_por_deterioro_vai_772 

ren total_activos_diferidos_780 activos_intangibles_alt

//inversiones

gegen investments = rowtotal(inversiones_corrientes_180 inc_sub_aso_785 inc_neg_con_795 otr_inversiones_lpl_800)

gegen inversiones_no_corrientes = rowtotal(inv_no_cte_sub_cto_782 inv_no_cte_sub_ajt_acu_vpp_783 inv_no_cte_sub_aso_cto_787 inv_no_ct_sb_as_ajt_ac_vpp_788 inc_neg_con_cto_791 inc_neg_cn_cto_ajt_acu_vpp_792 det_acu_val_inv_no_cte_789 otr_inversiones_lpl_800)
gegen inversiones_lp_rel = rowtotal(inv_no_cte_sub_cto_782 inv_no_cte_sub_ajt_acu_vpp_783 inv_no_cte_sub_aso_cto_787 inv_no_ct_sb_as_ajt_ac_vpp_788 inc_neg_con_cto_791 inc_neg_cn_cto_ajt_acu_vpp_792)
drop inv_no_cte_sub_cto_782 inv_no_cte_sub_ajt_acu_vpp_783 inv_no_cte_sub_aso_cto_787 inv_no_ct_sb_as_ajt_ac_vpp_788 inc_neg_con_cto_791 inc_neg_cn_cto_ajt_acu_vpp_792 det_acu_val_inv_no_cte_789 inc_sub_aso_785 inc_neg_con_795 otr_inversiones_lpl_800

 //assets by geography and relation
gegen active_c_related_local = rowtotal(cdb_cli_rel_locales_200 ocd_cli_rel_locales_240)
drop cdb_cli_rel_locales_200 ocd_cli_rel_locales_240

gegen active_c_unrelated_local = rowtotal(cdb_cli_nre_locales_220 ocd_cli_nre_locales_260)
drop cdb_cli_nre_locales_220 ocd_cli_nre_locales_260

gegen active_c_related_extranjero = rowtotal(cdb_cli_rel_exterior_210 ocd_cli_rel_exterior_250)
drop cdb_cli_rel_exterior_210 ocd_cli_rel_exterior_250

gegen active_c_unrelated_extranjero = rowtotal(cdb_cli_nre_exterior_230 ocd_cli_nre_exterior_270)
drop cdb_cli_nre_exterior_230 ocd_cli_nre_exterior_270

gegen active_l_related_local = rowtotal(active_c_related_local cdb_lpl_cli_rel_locales_810 ocd_lpl_cli_rel_locales_860)
drop cdb_lpl_cli_rel_locales_810 ocd_lpl_cli_rel_locales_860

gegen active_l_unrelated_local = rowtotal(active_c_unrelated_local cdb_lpl_cli_nre_locales_830 ocd_lpl_cli_nre_locales_880)
drop cdb_lpl_cli_nre_locales_830 ocd_lpl_cli_nre_locales_880

gegen active_l_related_extranjero = rowtotal(active_c_related_extranjero cdb_lpl_cli_rel_exterior_820 ocd_lpl_cli_rel_exterior_870)
drop cdb_lpl_cli_rel_exterior_820 ocd_lpl_cli_rel_exterior_870

gegen active_l_unrelated_extranjero = rowtotal(active_c_unrelated_extranjero cdb_lpl_cli_nre_exterior_840 ocd_lpl_cli_nre_exterior_890)
drop cdb_lpl_cli_nre_exterior_840 ocd_lpl_cli_nre_exterior_890

gen total_activos_netos = total_assets - total_passive
gen debt_ratio = total_passive / total_assets
gen total_activos_corrientes_netos = activos_c - passive_c

gen net_active_c_related_local = active_c_related_local - passive_c_related_local
gen net_active_c_unrelated_local = active_c_unrelated_local - passive_c_unrelated_local
gen net_active_c_related_ext = active_c_related_extranjero - passive_c_related_extranjero
gen net_active_c_unrelated_ext = active_c_unrelated_extranjero - passive_c_unrelated_extranjero
gen net_active_l_related_local = active_l_related_local - passive_l_related_local
gen net_active_l_unrelated_local = active_l_unrelated_local - passive_l_unrelated_local
gen net_active_l_related_ext = active_l_related_extranjero - passive_l_related_extranjero
gen net_active_l_unrelated_ext = active_l_unrelated_extranjero - passive_l_unrelated_extranjero

gegen pagos_locales = rowtotal(gto_comisiones_locales_2880 gasto_ame_local_2820 gto_inp_ter_rel_local_2970)
drop gto_comisiones_locales_2880 gasto_ame_local_2820 gto_inp_ter_rel_local_2970 

gegen pagos_extranjeros = rowtotal(gto_comisiones_exterior_2900 gasto_ame_exterior_2840 gto_iba_exterior_2950 gto_inp_ter_rel_exterios_2990 gin_ade_ppa_gasto_3150) 
drop gto_comisiones_exterior_2900 gasto_ame_exterior_2840 gto_iba_exterior_2950 gto_inp_ter_rel_exterios_2990 gin_ade_ppa_gasto_3150

//labor payments	
gegen labor_cost = rowtotal(gasto_ssa_qcm_2290 gasto_bsi_qnc_2310 gasto_ies_2370 gto_hon_pro_dietas_2390 gto_hon_pro_soc_2410 gto_provisiones_jpa_2740 gto_provisiones_desahucio_2760 gto_otr_gto_ben_emp_2754 costo_ssa_qcm_2280 costo_bsi_qnc_2300 costo_ies_2360 cto_hon_pro_dietas_2380 cto_hon_pro_soc_2400 cto_provisiones_jpa_2730 cto_provisiones_desahucio_2750 cto_otr_gto_ben_emp_2752 vnd_ssa_qcm_2295 vnd_bsi_qnc_2315 vnd_ies_2375 vnd_hon_pro_dietas_2395 vnd_hon_pro_soc_2415 vpn_provisiones_jpa_2745 vnd_provisiones_desahucio_2765 vnd_gto_otr_gto_ben_emp_2756)

gegen gastos_lab = rowtotal(gasto_ssa_qcm_2290 gasto_bsi_qnc_2310 gasto_ies_2370 gto_hon_pro_dietas_2390 gto_hon_pro_soc_2410 gto_provisiones_jpa_2740 gto_provisiones_desahucio_2760 gto_otr_gto_ben_emp_2754)	

gegen costos_lab = rowtotal(costo_ssa_qcm_2280 costo_bsi_qnc_2300 costo_ies_2360 cto_hon_pro_dietas_2380 cto_hon_pro_soc_2400 cto_provisiones_jpa_2730 cto_provisiones_desahucio_2750 cto_otr_gto_ben_emp_2752)
	
	drop gasto_ssa_qcm_2290 gasto_bsi_qnc_2310 gasto_ies_2370 gto_hon_pro_dietas_2390 gto_hon_pro_soc_2410 gto_provisiones_jpa_2740 gto_provisiones_desahucio_2760 gto_otr_gto_ben_emp_2754 costo_ssa_qcm_2280 costo_bsi_qnc_2300 costo_ies_2360 cto_hon_pro_dietas_2380 cto_hon_pro_soc_2400 cto_provisiones_jpa_2730 cto_provisiones_desahucio_2750 cto_otr_gto_ben_emp_2752 vnd_ssa_qcm_2295 vnd_bsi_qnc_2315 vnd_ies_2375 vnd_hon_pro_dietas_2395 vnd_hon_pro_soc_2415 vpn_provisiones_jpa_2745 vnd_provisiones_desahucio_2765 vnd_gto_otr_gto_ben_emp_2756
	
gegen exports = rowtotal(exportaciones_netas_1820 expor_netas_servi_1822)
gegen local_sales = rowtotal(vln_eaf_tdc_1800 vln_eaf_tce_1810 venta_neta_activos_fijos_1940)
gegen total_sales = rowtotal(exports local_sales)
drop vln_eaf_tdc_1800 vln_eaf_tce_1810 venta_neta_activos_fijos_1940 exportaciones_netas_1820 expor_netas_servi_1822	 

ren utilidad_gravable_3560 taxable_profits
ren utilidad_ejercicio_3420 gross_profit
ren total_ingresos_1930 revenue
ren total_costos_gastos_3380 total_cost_expenses
ren impuesto_renta_causado_3600 cit_liability
ren inversiones_corrientes_180 current_investment

ren utilidad_ndi_eje_ant_1740 profits_accumulated

gsort + firm_id anio_fiscal
gen profits_accumulated_f1 = profits_accumulated[_n+1] if firm_id == firm_id[_n+1]
gen dividends = gross_profit - cit_liability - uti_reinvertir_cpz_3580 - (profits_accumulated_f1 - profits_accumulated)
	replace dividends = 0 if dividends < 0 & missing(dividends) == 0

gen retained_earnings = (profits_accumulated_f1 - profits_accumulated)

drop profits_accumulated_f1

replace total_cost_expenses = . if total_cost_expenses < 0 & missing(total_cost_expenses) == 0

gen labor_ratio = labor_cost / total_cost_expenses
gen taxable_profit_margin = taxable_profits / revenue
gen gross_profit_margin = gross_profit / revenue
gen return_on_assets = gross_profit / total_assets

gen labor_ratio_w = labor_ratio
	replace labor_ratio_w = 1 if labor_ratio_w > 1 & missing(labor_ratio_w) == 0

gen exports_rr = exports / revenue

gen exports_rr_w = exports_rr
	replace exports_rr_w = 1 if exports_rr_w > 1 & missing(exports_rr_w) == 0

gen exports_ar = exports / total_assets

gen exports_ar_w = exports_ar
	replace exports_ar_w = 1 if exports_ar_w > 1 & missing(exports_ar_w) == 0
	
gen gross_profit_margin_w_alt = gross_profit_margin
	replace gross_profit_margin_w_alt = 1 if gross_profit_margin_w_alt > 1 & missing(gross_profit_margin_w_alt) == 0
	replace gross_profit_margin_w_alt = -1 if gross_profit_margin_w_alt < -1 & missing(gross_profit_margin_w_alt) == 0
	
gen return_on_assets_w_alt = return_on_assets
	replace return_on_assets_w_alt = 1 if return_on_assets_w_alt > 1 & missing(return_on_assets_w_alt) == 0
	replace return_on_assets_w_alt = -1 if return_on_assets_w_alt < -1 & missing(return_on_assets_w_alt) == 0

//generate statutory tax
gen tasa_vigente = 0.23 if inrange(anio_fiscal, 2012, 2012)
	replace tasa_vigente = 0.22 if inrange(anio_fiscal, 2013, 2018)
	replace tasa_vigente = 0.24 if inrange(anio_fiscal, 2019, 2019)

replace cit_liability = 0 if missing(cit_liability)	
	
gen saldo_utilidad = taxable_profits - uti_reinvertir_cpz_3580
gen numerador = cit_liability + (0.1 * uti_reinvertir_cpz_3580)
gen denominador = saldo_utilidad + uti_reinvertir_cpz_3580
gen dummy_perdida = perdida_3570 > 0 if missing(perdida_3570) == 0
gen dummy_utilidad = taxable_profits > 0 if missing(taxable_profits) == 0
gen dummy_cero = taxable_profits == 0
	replace dummy_cero = 0 if dummy_perdida == 1 

gen tasa_ir	= 0 if dummy_cero == 1 | dummy_perdida == 1
	replace tasa_ir = tasa_vigente if numerador > denominador 
	replace tasa_ir = numerador / denominador if numerador <= denominador & missing(numerador) == 0 & missing(denominador) == 0 
	
drop numerador denominador 

drop ocp_crr_nre_locales_1260 ocp_crr_nre_exterior_1270 ocp_lpl_rel_locales_1480 tot_activo_no_corriente_1077 saldo_utilidad 	
	
//gen tasa_check = cit_liability / taxable_profits

//deflate to real USD 2014
ren anio_fiscal year
merge m:1 year using "$datadir/cpi_year.dta", nogen keep(3) keepus(cpi2014)
ren year anio_fiscal

replace porcion_comp_soc_no_inf_3576 = . if porcion_comp_soc_no_inf_3576 < 0 & missing(porcion_comp_soc_no_inf_3576) == 0

foreach v in current_investment activos_c total_activos_fijos_690 activos_intangibles_alt total_activos_lp_1070 total_assets passive_c total_pasivos_diferidos_1600 total_passive total_capital dividendos_percibidos revenue total_cost_expenses gross_profit perdida_ejercicio_3430 participacion_tbj_15_3440 taxable_profits perdida_3570 uti_reinvertir_cpz_3580 cit_liability impuesto_renta_pagar_3680 agregated_debt_int local_related local_unrelated foreign_related foreign_unrelated passive_c_related_local passive_c_unrelated_local passive_c_related_extranjero passive_c_unrelated_extranjero passive_l_related_local passive_l_unrelated_local passive_l_related_extranjero passive_l_unrelated_extranjero activos_intangibles investments inversiones_no_corrientes inversiones_lp_rel active_c_related_local active_c_unrelated_local active_c_related_extranjero active_c_unrelated_extranjero active_l_related_local active_l_unrelated_local active_l_related_extranjero active_l_unrelated_extranjero total_activos_netos debt_ratio total_activos_corrientes_netos net_active_c_related_local net_active_c_unrelated_local net_active_c_related_ext net_active_c_unrelated_ext net_active_l_related_local net_active_l_unrelated_local net_active_l_related_ext net_active_l_unrelated_ext pagos_locales pagos_extranjeros labor_cost gastos_lab costos_lab exports local_sales total_sales retained_earnings dividends profits_accumulated {
	
	replace `v' = `v' * 100 / cpi2014

}	

bys firm_id: gegen assets_2014 = total(cond(anio_fiscal == 2014, total_assets, .))
gen roa_2014 = gross_profit / assets_2014
drop assets_2014

gen roa_2014_w_alt = gross_profit_margin
	replace roa_2014_w_alt = 1 if roa_2014_w_alt > 1 & missing(roa_2014_w_alt) == 0
	replace roa_2014_w_alt = -1 if roa_2014_w_alt < -1 & missing(roa_2014_w_alt) == 0

drop cpi2014

gduplicates drop
	
drop if firm_id == "NA"

compress

save "$datadir/f101_processed.dta", replace
*/

/*
/*******/
/* MID */
/*******/

//need the MID files unzipped

forv t = 2019/2019 {

	import delimited "F:\DTO_ESTUDIOS_E2\B_INVESTIGADORES_EXTERNOS\202201_BANCO_MUNDIAL_PBACHAS\01_DATA\1_PROPORCIONADO_SRI\MID\A_MID_`t'.csv", clear varnames(1)

	cap ren id_an_anon firm_id
	cap ren id_an firm_id
	cap ren codigo_motivo_super_bancos motivo_eco_super_bancos

	keep monto_transferido pais_super_bancos motivo_eco_super_bancos firm_id tipo_transaccion codigo_pais codigo_motivo_economico
	
	if `t' != 2019 destring monto_transferido motivo_eco_super_bancos, force replace
	else if `t' == 2019 destring monto_transferido motivo_eco_super_bancos, force replace dpcomma
	
	collapse (sum) monto_transferido, by(firm_id tipo_transaccion pais_super_bancos motivo_eco_super_bancos)
	
	//we can substantially speed up the MID processing and improve tractability by sieving with APS f101 firms
	//any id that does not merge is not a firm, or at the least we would be able to use it
	merge m:1 firm_id using "$datadir/aps_f101_id_list.dta", keep(3) nogen
	
	compress
	
	/*
	tempfile mid_`t'
	save `mid_`t'', replace
	*/
	
	save "$datadir/mid_`t'.dta", replace
	
}	
	
clear

use "$datadir/mid_2012.dta", clear
gen anio_fiscal = 2012

forv t = 2013/2019 {	
	
	append using "$datadir/mid_`t'.dta"
	replace anio_fiscal = `t' if missing(anio_fiscal)
	
}

/*
use `mid_2012', clear
gen anio_fiscal = 2012

forv t = 2013/2019 {	
	
	append using `mid_`t''
	replace anio_fiscal = `t' if missing(anio_fiscal)
	
}
*/
	
///
//PROCESSING
///	
	
ren pais_super_bancos pais
merge m:1 pais anio_fiscal using "D:\BM_EXTENSION\B202106_JAKOB_BROUNSTEIN\transfer\paises_mid_aps.dta", nogen keep(1 3) keepus(paraiso_fiscal_accionista)

replace paraiso_fiscal_accionista = "" if pais == "ITALIA"

gcollapse (sum) monto_transferido, by(firm_id anio_fiscal tipo_transaccion paraiso_fiscal_accionista motivo_eco_super_bancos)	
	
//deflate to real USD 2014
ren anio_fiscal year
merge m:1 year using "$datadir/cpi_year.dta", nogen keep(3) keepus(cpi2014)
ren year anio_fiscal

foreach v in monto_transferido {

	replace `v' = `v' * 100 / cpi2014

}	

drop cpi2014

//want to reformat the MID into a wide panel on the firm-year level
//gen motivo_factor = real(substr(string(motivo_eco_super_bancos), 1, 1))
//gen mid_commerce = inrange(motivo_factor, 1, 3)
//gen mid_finance = inrange(motivo_factor, 4, 7)
//gen mid_dividend = real(motivo_eco_super_bancos) == 405
//gen mid_all = 1

ren monto_transferido monto

bys firm_id anio_fiscal: gegen mid_div_salidas_pff = total(cond(motivo_eco_super_bancos == 405 & tipo_transaccion == "S" & paraiso_fiscal_accionista == "S", monto, 0))
bys firm_id anio_fiscal: gegen mid_div_salidas_ext = total(cond(motivo_eco_super_bancos == 405 & tipo_transaccion == "S" & paraiso_fiscal_accionista == "", monto, 0))
bys firm_id anio_fiscal: gegen mid_div_entradas_pff = total(cond(motivo_eco_super_bancos == 405 & tipo_transaccion == "E" & paraiso_fiscal_accionista == "S", monto, 0))
bys firm_id anio_fiscal: gegen mid_div_entradas_ext = total(cond(motivo_eco_super_bancos == 405 & tipo_transaccion == "E" & paraiso_fiscal_accionista == "", monto, 0))

bys firm_id anio_fiscal: gegen mid_fin_salidas_pff = total(cond(inrange(motivo_eco_super_bancos, 200, 999) & tipo_transaccion == "S" & paraiso_fiscal_accionista == "S", monto, 0))
bys firm_id anio_fiscal: gegen mid_fin_salidas_ext = total(cond(inrange(motivo_eco_super_bancos, 200, 999) & tipo_transaccion == "S" & paraiso_fiscal_accionista == "", monto, 0))
bys firm_id anio_fiscal: gegen mid_fin_entradas_pff = total(cond(inrange(motivo_eco_super_bancos, 200, 999) & tipo_transaccion == "E" & paraiso_fiscal_accionista == "S", monto, 0))
bys firm_id anio_fiscal: gegen mid_fin_entradas_ext = total(cond(inrange(motivo_eco_super_bancos, 200, 999) & tipo_transaccion == "E" & paraiso_fiscal_accionista == "", monto, 0))

bys firm_id anio_fiscal: gegen mid_all_salidas_pff = total(cond(tipo_transaccion == "S" & paraiso_fiscal_accionista == "S", monto, 0))
bys firm_id anio_fiscal: gegen mid_all_salidas_ext = total(cond(tipo_transaccion == "S" & paraiso_fiscal_accionista == "", monto, 0))
bys firm_id anio_fiscal: gegen mid_all_entradas_pff = total(cond(tipo_transaccion == "E" & paraiso_fiscal_accionista == "S", monto, 0))
bys firm_id anio_fiscal: gegen mid_all_entradas_ext = total(cond(tipo_transaccion == "E" & paraiso_fiscal_accionista == "", monto, 0))

bys firm_id anio_fiscal: gegen mid_fin_salidas_total = total(cond(inrange(motivo_eco_super_bancos, 200, 999) & tipo_transaccion == "S", monto, 0))
bys firm_id anio_fiscal: gegen mid_fin_entradas_total = total(cond(inrange(motivo_eco_super_bancos, 200, 999) & tipo_transaccion == "E", monto, 0))
bys firm_id anio_fiscal: gegen mid_div_salidas_total = total(cond(motivo_eco_super_bancos == 405 & tipo_transaccion == "S", monto, 0))
bys firm_id anio_fiscal: gegen mid_div_entradas_total = total(cond(motivo_eco_super_bancos == 405 & tipo_transaccion == "E", monto, 0))
bys firm_id anio_fiscal: gegen mid_all_salidas_total = total(cond(tipo_transaccion == "S", monto, 0))
bys firm_id anio_fiscal: gegen mid_all_entradas_total = total(cond(tipo_transaccion == "E", monto, 0))

keep firm_id anio_fiscal mid_div_salidas_pff mid_div_salidas_ext mid_div_entradas_pff mid_div_entradas_ext mid_all_salidas_pff mid_all_salidas_ext mid_all_entradas_pff mid_all_entradas_ext mid_div_salidas_total mid_div_entradas_total mid_all_salidas_total mid_all_entradas_total mid_fin_salidas_pff mid_fin_salidas_ext mid_fin_entradas_pff mid_fin_entradas_ext mid_fin_salidas_total mid_fin_entradas_total

//this *should* make the data unique on the firm-year level
gduplicates drop

//if this drops anything, investigate
gduplicates drop firm_id anio_fiscal,  force

save "$datadir/mid_processed.dta", replace	
*/
	
/****************************************/
/* COMBINE ALL OF THE FILES AND PROCESS */
/****************************************/	

//going to go about winsorize by group X anio_fiscal
	
foreach f in main core { 
		
	use "$datadir/`f'_sample_aps_processed.dta", clear

	merge 1:1 firm_id anio_fiscal using "$datadir/f101_processed.dta", gen(merge) keep(1 3)
	
	//f101 declaration variables
		
	gen f101 = merge == 3
	gen active = merge == 3 & revenue > 0 & revenue != .
	gen aps_f101 = merge == 3 & aps == 1
	gen aps_f101_active = merge == 3 & aps == 1 & active == 1
	
	drop merge 
	
	merge 1:1 firm_id anio_fiscal using "$datadir/mid_processed.dta", nogen keep(1 3)
	
	//generating combined f101-MID variables
	gen domestic_dividends = dividends - mid_div_salidas_total
		replace domestic_dividends = 0 if domestic_dividends < 0 & missing(domestic_dividends) == 0
		
	foreach v in domestic_dividends dividends mid_div_salidas_total retained_earnings investments {
		
		gen `v'_ps = `v' / gross_profit
		
		gen `v'_ps_w = `v' / gross_profit
			replace `v'_ps_w = 1 if `v'_ps_w > 1 & missing(`v'_ps_w) == 0
		
	}
	
	foreach v in domestic_dividends dividends mid_div_salidas_total investments retained_earnings investments mid_div_salidas_pff mid_fin_salidas_pff mid_all_salidas_pff mid_div_salidas_prom mid_fin_salidas_prom mid_all_salidas_prom {
		
		gen `v'_ar = `v' / total_assets
		
		gen `v'_ar_w = `v' / total_assets
			replace `v'_ar_w = 1 if `v'_ar_w > 1 & missing(`v'_ar_w) == 0
		
	}
	
	//generating prominent and inverse prominent mid variables
	foreach v in mid_div_salidas mid_div_entradas mid_fin_salidas mid_fin_entradas mid_all_salidas mid_all_entradas {
		
		gen `v'_prom = `v'_pff if inlist(group, 4, 5)
			replace `v'_prom = `v'_ext if inlist(group, 2, 3)
		
		gen `v'_inv = `v'_ext if inlist(group, 4, 5)
			replace `v'_inv = `v'_pff if inlist(group, 2, 3)
			
	}
	
	//rectangulatizing MID variables and generating ratios as a share of revenues, winsorizing the ratios
	foreach v in mid_div_salidas_pff mid_div_salidas_ext mid_div_entradas_pff mid_div_entradas_ext mid_fin_salidas_pff mid_fin_salidas_ext mid_fin_entradas_pff mid_fin_entradas_ext mid_all_salidas_pff mid_all_salidas_ext mid_all_entradas_pff mid_all_entradas_ext mid_fin_salidas_total mid_fin_entradas_total mid_div_salidas_total mid_div_entradas_total mid_all_salidas_total mid_all_entradas_total mid_div_salidas_prom mid_div_salidas_inv mid_div_entradas_prom mid_div_entradas_inv mid_fin_salidas_prom mid_fin_salidas_inv mid_fin_entradas_prom mid_fin_entradas_inv mid_all_salidas_prom mid_all_salidas_inv mid_all_entradas_prom mid_all_entradas_inv domestic_dividends dividends investments retained_earnings {
		
		replace `v' = 0 if missing(`v')
		
		gen `v'_rr = `v' / revenue
		
		//winsorized ratio variables
		gen `v'_rr_w = `v'_rr
			replace `v'_rr_w = 1 if `v'_rr_w > 1 & missing(`v'_rr_w) == 0
		
	}
		
	gstats winsor current_investment activos_c total_activos_fijos_690 activos_intangibles_alt total_activos_lp_1070 total_assets passive_c total_pasivos_diferidos_1600 total_passive total_capital dividendos_percibidos revenue total_cost_expenses gross_profit perdida_ejercicio_3430 participacion_tbj_15_3440 taxable_profits perdida_3570 uti_reinvertir_cpz_3580 cit_liability impuesto_renta_pagar_3680 agregated_debt_int local_related local_unrelated foreign_related foreign_unrelated passive_c_related_local passive_c_unrelated_local passive_c_related_extranjero passive_c_unrelated_extranjero passive_l_related_local passive_l_unrelated_local passive_l_related_extranjero passive_l_unrelated_extranjero activos_intangibles investments inversiones_no_corrientes inversiones_lp_rel active_c_related_local active_c_unrelated_local active_c_related_extranjero active_c_unrelated_extranjero active_l_related_local active_l_unrelated_local active_l_related_extranjero active_l_unrelated_extranjero total_activos_netos debt_ratio total_activos_corrientes_netos net_active_c_related_local net_active_c_unrelated_local net_active_c_related_ext net_active_c_unrelated_ext net_active_l_related_local net_active_l_unrelated_local net_active_l_related_ext net_active_l_unrelated_ext pagos_locales pagos_extranjeros labor_cost gastos_lab costos_lab exports local_sales total_sales taxable_profit_margin gross_profit_margin return_on_assets roa_2014 tasa_ir mid_div_salidas_pff mid_div_salidas_ext mid_div_entradas_pff mid_div_entradas_ext mid_fin_salidas_pff mid_fin_salidas_ext mid_fin_entradas_pff mid_fin_entradas_ext mid_all_salidas_pff mid_all_salidas_ext mid_all_entradas_pff mid_all_entradas_ext mid_fin_salidas_total mid_fin_entradas_total mid_div_salidas_total mid_div_entradas_total mid_all_salidas_total mid_all_entradas_total mid_all_salidas_prom mid_all_salidas_inv mid_all_entradas_prom mid_all_entradas_inv mid_div_salidas_prom mid_div_salidas_inv mid_div_entradas_prom mid_div_entradas_inv mid_fin_salidas_prom mid_fin_salidas_inv mid_fin_entradas_prom mid_fin_entradas_inv domestic_dividends dividends profits_accumulated retained_earnings, by(anio_fiscal group) cuts(0 99) suffix("_w")

	order firm_id anio_fiscal group_assign group treatment_major treatment_minor exposure prominent_2014 t_major_alt t_minor_alt c_major_alt c_minor_alt treatment_major_alt treatment_minor_alt exposure_alt prominent_2012_2014 ///
		porcion_comp_soc_no_inf_3576 porcion_comp_soc_si_inf_3578 ///
		aps f101 active aps_f101 aps_f101_active
	
	compress
	
	///
	//PROCESSING NAMES FOR LENGTH
	///
	
	//want variable names of max length 28 characters
	
	ren total_activos_corrientes_netos_w tot_currentassets_net_w
	ren total_activos_corrientes_netos tot_currentassets_net

	ren active_l_unrelated_extranjero_w active_l_unrelated_ext_w
	ren active_l_unrelated_extranjero active_l_unrelated_ext

	ren active_c_unrelated_extranjero_w active_c_unrelated_ext_w 
	ren active_c_unrelated_extranjero active_c_unrelated_ext 

	ren passive_c_unrelated_extranjero_w passive_c_unrelated_ext_w
	ren passive_c_unrelated_extranjero passive_c_unrelated_ext

	ren passive_l_unrelated_extranjero_w passive_l_unrelated_ext_w
	ren passive_l_unrelated_extranjero passive_l_unrelated_ext

	ren terminal_ownership_concentration terminal_ownership_conc
	ren participation_inverse_prominent participation_inv_prominent
 
	ren total_pasivos_diferidos_1600 total_pasivos_int_1600
	ren total_pasivos_diferidos_1600_w total_pasivos_int_1600_w

	ren passive_c_related_extranjero passive_c_related_ext
	ren passive_c_related_extranjero_w passive_c_related_ext_w
	
	ren passive_l_related_extranjero passive_l_related_ext
	ren passive_l_related_extranjero_w passive_l_related_ext_w
	
	ren active_c_related_extranjero active_c_related_ext
	ren active_c_related_extranjero_w active_c_related_ext_w
	
	ren active_l_related_extranjero active_l_related_ext
	ren active_l_related_extranjero_w active_l_related_ext_w
	
	ren net_active_c_unrelated_local net_active_c_unrel_local
	ren net_active_c_unrelated_local_w net_active_c_unrel_local_w
	
	ren net_active_l_unrelated_local net_active_l_unrel_local
	ren net_active_l_unrelated_local_w net_active_l_unrel_local_w
	
	cap ren has_maingroup_plurality_sh_2014 has_maingroup_plur_sh_2014
	
	save "$datadir/`f'_panel.dta", replace
	
}

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

di "file build has terminated successfully"

cap log close
clear
