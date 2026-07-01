/*with clustered error*/
clear all 

cls 

** the model 
** load the data 
use "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/project.dta", clear 

capture log off 

log using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/models.log", replace

** generate some variables 
egen exp_imp = group(exporter importer)
egen imp_pro = group(importer HS2)
egen exp_pro = group(exporter HS2)
encode importer, gen(imp_o)
encode exporter, gen(exp_d)
gen lngdp_o = log(gdp_o)
gen lngdp_d = log(gdp_d)
gen lndist = log(dist)
gen Freq_Tariff_6 = Freq_HS6*tariff_mean_6
gen Freq_Tariff_4 = Freq_HS4*tariff_mean_4
gen Freq_Tariff_2 = Freq_HS2*tariff_mean_2

** keep relevant variables
keep Freq_HS6 Freq_HS4 Freq_HS2 rta gni_importer gni agg_trade D_i DiMi sum_DiMi sum_Mi latest_year_flag pair adv importer exporter exp_imp tariff_mean_6 tariff_mean_4 tariff_mean_2 imp_pro exp_pro imp_o exp_d lngdp_o lngdp_d lndist comlang_ethno contig col_dep_ever Freq_Tariff_6 Freq_Tariff_4 Freq_Tariff_2

** relabel variables 
lab var Freq_HS6 "HS6 Frequency Index"
lab var Freq_HS4 "HS4 Frequency Index"
lab var Freq_HS2 "HS2 Frequency Index"
lab var rta "RTA"
lab var tariff_mean_2 "HS2 Average tariff"
lab var tariff_mean_4 "HS4 Average tariff"
lab var tariff_mean_6 "HS6 Average tariff"
lab var lngdp_o "log of Exporter GDP"
lab var lngdp_d "log of Importer GDP"
lab var lndist "log of distance"
lab var comlang_ethno "Common language"
lab var contig "Contiguity"
lab var col_dep_ever "Colony"
lab var Freq_Tariff_6 "HS6 Interaction"
lab var Freq_Tariff_4 "HS4 Interaction"
lab var Freq_Tariff_2 "HS2 Interaction"

* ----------------------------------------------------------------------------
/*Baseline*/
** run the ppml model  
eststo clear 
eststo: ppmlhdfe agg_trade Freq_HS6 tariff_mean_6 rta, absorb(imp_o exp_d) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS4 tariff_mean_4 rta, absorb(imp_o exp_d) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS2 tariff_mean_2 rta, absorb(imp_o exp_d) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

* -----------------------------------------------------------------------------------
** run the ols model  

gen lnagg_trade = log(agg_trade)

eststo: reghdfe lnagg_trade Freq_HS6 tariff_mean_6 rta, absorb(imp_o exp_d) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: reghdfe lnagg_trade Freq_HS4 tariff_mean_4 rta, absorb(imp_o exp_d) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: reghdfe lnagg_trade Freq_HS2 tariff_mean_2 rta, absorb(imp_o exp_d) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

** nice table
esttab, compress title(Baseline) s(imp_fe exp_fe pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta) varwidth(30)

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/baseline.log", ///
 compress title(Baseline) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta) varwidth(30) replace 

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/baseline.tex", ///
 compress title(Baseline) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("HS6" ///
	"HS4" "HS2" "HS6" "HS4" "HS2") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta) varwidth(30) replace 

* ---------------------------------------------------------------------	
/*heterogenous effects*/

** generate new variables
gen low = gni_importer<=1145 /*low income country*/
lab var low "Low income"

gen lmi = (gni_importer>=1146 & gni_importer<=4515)
lab var lmi "Lower middle income"

gen upm = (gni_importer>=4516 & gni_importer<=14005)
lab var upm "Upper middle income"

gen high = gni_importer>14005
lab var high "High income"

replace high = . if gni_importer == . & gni == .

** the model
/*
** run the ppml model  
/*low income countries*/
eststo clear
eststo: ppmlhdfe agg_trade Freq_HS6 tariff_mean_6 rta if low == 1, absorb(importer exporter) cluster(importer exporter) 
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS4 tariff_mean_4 rta if low == 1, absorb(importer exporter) cluster(importer exporter)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS2 tariff_mean_2 rta if low == 1, absorb(importer exporter) cluster(importer exporter)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

** nice table
esttab, compress title(Low Income) s(imp_fe exp_fe pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta) varwidth(30)

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/low_group.log", ///
 compress title(Low Income) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta) varwidth(30) replace 

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/low_group.tex", ///
 compress title(Low Income) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta) varwidth(30) replace
*/

** run the ppml model  
/*lower-middle income*/
eststo clear
eststo: ppmlhdfe agg_trade Freq_HS6 tariff_mean_6 rta if lmi == 1, absorb(importer exporter) cluster(importer exporter) 
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS4 tariff_mean_4 rta if lmi == 1, absorb(importer exporter) cluster(importer exporter)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS2 tariff_mean_2 rta if lmi == 1, absorb(importer exporter) cluster(importer exporter)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

** nice table
esttab, compress title(Lower-Middle Income) s(imp_fe exp_fe pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta) varwidth(30)

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/lmi_group.log", ///
 compress title(Lower-Middle Income) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta) varwidth(30) replace 

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/lmi_group.tex", ///
 compress title(Lower-Middle Income) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta) varwidth(30) replace
	
** run the ppml model  
/*upper-middle income*/
eststo clear
eststo: ppmlhdfe agg_trade Freq_HS6 tariff_mean_6 rta if upm == 1, absorb(importer exporter) cluster(importer exporter)  
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS4 tariff_mean_4 rta if upm == 1, absorb(importer exporter) cluster(importer exporter) 
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS2 tariff_mean_2 rta if upm == 1, absorb(importer exporter) cluster(importer exporter) 
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

** nice table
esttab, compress title(Upper-Middle Income) s(imp_fe exp_fe pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2  rta) varwidth(30)

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/upm_group.log", ///
 compress title(Upper-Middle Income) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta) varwidth(30) replace 

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/upm_group.tex", ///
 compress title(Upper-Middle Income) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta) varwidth(30) replace 

/*high income income*/
eststo clear
eststo: ppmlhdfe agg_trade Freq_HS6 tariff_mean_6 rta if high == 1 , absorb(importer exporter) cluster(importer exporter) 
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS4 tariff_mean_4 rta if high == 1, absorb(importer exporter) cluster(importer exporter) 
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS2 tariff_mean_2 rta if high == 1, absorb(importer exporter) cluster(importer exporter) 
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

** nice table
esttab, compress title(High Income) s(imp_fe exp_fe pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta) varwidth(30)

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/high_group.log", ///
 compress title(High Income) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta) varwidth(30) replace

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/high_group.tex", ///
 compress title(High Income) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta) varwidth(30) replace

* --------------------------------------------------------------------------
/*importer-product and exporter-product FE*/
** run the ppml model  
eststo clear 
eststo: ppmlhdfe agg_trade Freq_HS6 tariff_mean_6 rta, absorb(imp_pro exp_pro) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS4 tariff_mean_4 rta, absorb(imp_pro exp_pro) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS2 tariff_mean_2 rta, absorb(imp_pro exp_pro) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

** nice table
esttab, compress title(Importer & Exporter-Product FE) s(imp_fe exp_fe pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta) varwidth(30)

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/imp_exp_fe.log", ///
 compress title(Baseline) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta) varwidth(30) replace 

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/imp_exp_fe.tex", ///
 compress title(Baseline) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta) varwidth(30) replace 

* -----------------------------------------------------------------------------------
/*without RTA*/
** run the ppml model  
eststo clear 
eststo: ppmlhdfe agg_trade Freq_HS6 tariff_mean_6, absorb(imp_o exp_d) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS4 tariff_mean_4, absorb(imp_o exp_d) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS2 tariff_mean_2, absorb(imp_o exp_d) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

** nice table
esttab, compress title(No RTA) s(imp_fe exp_fe pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2) varwidth(30)

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/no_rta.log", ///
 compress title(Baseline) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2) varwidth(30) replace 

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/no_rta.tex", ///
 compress title(Baseline) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2) varwidth(30) replace 

* --------------------------------------------------------------------------------
/*other gravity covariates*/

** run the ppml model  
eststo clear 
eststo: ppmlhdfe agg_trade Freq_HS6 tariff_mean_6 rta lngdp_o lngdp_d lndist comlang_ethno contig col_dep_ever, absorb(imp_o exp_d) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS4 tariff_mean_4 rta lngdp_o lngdp_d lndist comlang_ethno contig col_dep_ever, absorb(imp_o exp_d) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS2 tariff_mean_2 rta lngdp_o lngdp_d lndist comlang_ethno contig col_dep_ever, absorb(imp_o exp_d) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

** nice table
esttab, compress title(Baseline) s(imp_fe exp_fe pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta lngdp_o lngdp_d lndist comlang_ethno contig col_dep_ever) varwidth(30)

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/gravity.log", ///
 compress title(Gravity Covariates) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta lngdp_o lngdp_d lndist comlang_ethno contig col_dep_ever) varwidth(30) replace 

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/gravity.tex", ///
 compress title(Baseline) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 rta lngdp_o lngdp_d lndist comlang_ethno contig col_dep_ever) varwidth(30) replace
	
** ----------------------------------------------------------------
/*Baseline with interaction*/
** run the ppml model  
eststo clear 
eststo: ppmlhdfe agg_trade Freq_HS6 tariff_mean_6 Freq_Tariff_6 rta, absorb(imp_o exp_d) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS4 tariff_mean_4 Freq_Tariff_4 rta, absorb(imp_o exp_d) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

eststo: ppmlhdfe agg_trade Freq_HS2 tariff_mean_2 Freq_Tariff_2 rta, absorb(imp_o exp_d) cluster(exp_imp)
estadd local imp_fe "Yes", replace
estadd local exp_fe "Yes", replace
estadd local pair "No", replace

** nice table
esttab, compress title(Interaction Model) s(imp_fe exp_fe pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 Freq_Tariff_6 Freq_Tariff_4 Freq_Tariff_2 rta) varwidth(30)

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/interaction.log", ///
 compress title(Baseline) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("PPML 1" ///
	"PPML 2" "PPML 3" "OLS 1" "OLS 2" "OLS 3") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 Freq_Tariff_6 Freq_Tariff_4 Freq_Tariff_2 rta) varwidth(30) replace 

esttab using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/interaction.tex", ///
 compress title(Baseline) s(exp_pro imp_pro pair r2 N, ///
	label("Exporter-FE" "Importer-FE" "Country-Pair" "R2" "N")) ///
	label nonumbers star(* .10 ** .05 *** .01) b(%10.3f) mlabel("HS6" ///
	"HS4" "HS2" "HS6" "HS4" "HS2") order(Freq_HS6 Freq_HS4 Freq_HS2 tariff_mean_6 tariff_mean_4 tariff_mean_2 Freq_Tariff_6 Freq_Tariff_4 Freq_Tariff_2 rta) varwidth(30) replace

log close 
