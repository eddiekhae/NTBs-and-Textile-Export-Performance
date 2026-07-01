* import the data 
use "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/NTMdata.dta", clear 

* --- Indicator for PSI (non-horizontal, full coverage)
* it is important not to include horizontals for the calculation 
gen D_i = (ntm_FullCov_nonH > 0) & !missing(ntm_FullCov_nonH) /*why was full coverage used?*/ /*this is the practice of UNCTAD*/ /*maybe partial coverage and full + partial for the robustness?*/

* -- Aggregate the trade value at the dyad level 
bysort exporter importer: egen agg_trade = total(trade_value)

save "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/NTM_Source_data_clean", replace

* --- Frequency index at the HS6 level

/*Di*/
bysort importer exporter HS6: egen D_line = max(D_i)
*duplicates report importer exporter HS6
bysort importer exporter HS6: keep if _n == 1 /*drops the duplicates in the data*/
*duplicates report importer exporter HS6

/*Mi*/
bysort importer exporter HS6: gen Mi = trade_value>0 & !missing(trade_value)

/*DiMi*/
gen DiMi = D_line * Mi

/*sum(DiMi)/sum(Mi)*/

bysort importer exporter: egen sum_DiMi = total(DiMi)
bysort importer exporter: egen sum_Mi = total(Mi)
gen Freq_HS6 = 100 * (sum_DiMi / sum_Mi)
tab Freq_HS6

tempfile hs6
save `hs6', replace

use "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/NTM_Source_data_clean", clear

* --- Frequency index at the HS4 level

/*Di*/
bysort importer exporter HS4: egen D_line = max(D_i)
*duplicates report importer exporter HS4
bysort importer exporter HS4: keep if _n == 1 /*drops the duplicates in the data*/
*duplicates report importer exporter HS4

/*Mi*/
bysort importer exporter HS4: gen Mi = trade_value>0 & !missing(trade_value)

/*DiMi*/
gen DiMi = D_line * Mi

/*sum(DiMi)/sum(Mi)*/
bysort importer exporter: egen sum_DiMi = total(DiMi)
bysort importer exporter: egen sum_Mi = total(Mi)
gen Freq_HS4 = 100 * (sum_DiMi / sum_Mi)
tab Freq_HS4

tempfile hs4
save `hs4', replace

use "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/NTM_Source_data_clean", clear

* --- Frequency index at the HS2 level

/*Di*/
bysort importer exporter HS2: egen D_line = max(D_i)
*duplicates report importer exporter HS2
bysort importer exporter HS2: keep if _n == 1 /*drops the duplicates in the data*/
*duplicates report importer exporter HS2

/*Mi*/
bysort importer exporter HS2: gen Mi = trade_value>0 & !missing(trade_value)

/*DiMi*/
gen DiMi = D_line * Mi

/*sum(DiMi)/sum(Mi)*/
bysort importer exporter: egen sum_DiMi = total(DiMi)
bysort importer exporter: egen sum_Mi = total(Mi)
gen Freq_HS2 = 100 * (sum_DiMi / sum_Mi)
tab Freq_HS2

tempfile hs2
save `hs2', replace

use `hs6', clear

* Merge HS4-level frequency ratios
merge m:m importer exporter HS4 using `hs4', nogen

* Merge HS2-level frequency ratios
merge m:m importer exporter HS2 using `hs2', nogen

save "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/project.dta", replace 
