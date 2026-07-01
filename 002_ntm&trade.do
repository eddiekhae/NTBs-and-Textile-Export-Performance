cls

/*
** import the data 
use "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/NTM_Source_data", clear

** the imposing country is the importer and this is the reporter
** the data has EUN as a block and WLD as a block also 

* --- Keep 2016 and PSI measures

keep if Year == 2016
keep if substr(NTMCode,1,1) == "C"
drop Year

** non of the partner country is the EU: no country has imposed NTM on the EU
br Reporter Partner if Partner == "EUN"
br Reporter Partner if Reporter == "EUN"

** non of the reporting country is the WLD 
br Reporter Partner if Reporter == "WLD"
br Reporter Partner if Partner == "WLD"

** some of the data was not necessarily collected in 2016
tab latest_year_flag
*/

* -- Dealing with the EUN problem 

clear
input str3 member
"AUT"
"BEL"
"BGR"
"HRV"
"CYP"
"CZE"
"DNK"
"EST"
"FIN"
"FRA"
"DEU"
"GRC"
"IRL"
"ITA"
"LVA"
"LTU"
"LUX"
"HUN"
"MLT"
"NLD"
"POL"
"PRT"
"ROU"
"SVK"
"SVN"
"ESP"
"SWE"
"GBR"
end
tempfile eu28
save `eu28'

** import the data 
use "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/NTM_Source_data", clear

* --- Keep 2016 and PSI measures

keep if Year == 2016
keep if substr(NTMCode,1,1) == "C" /*this is for the PSI*/
drop Year

** duplicate the EUN to reflect specific countries
preserve
keep if Reporter== "EUN"
tempfile eurows_reporter
save `eurows_reporter'

use `eurows_reporter', clear
cross using `eu28'
replace Reporter = member
drop member
tempfile eu_reporter_expanded
save `eu_reporter_expanded'

restore
drop if Reporter== "EUN"
append using `eu_reporter_expanded'


* Build a universe of country codes from your current data (exclude blocks)
preserve
keep Reporter Partner
tempfile rep par world

keep Reporter
rename Reporter code
save `rep'

restore, preserve
keep Partner
rename Partner code
save `par'

use `rep', clear
append using `par'
drop if missing(code) | inlist(code,"EUN","WLD")
duplicates drop code, force
save `world'
restore

* -- Expand rows where Partner == "WLD" to all countries in `world'
preserve
keep if Partner=="WLD"
tempfile wldrows
save `wldrows'

use `wldrows', clear
cross using `world'          // Cartesian product
replace Partner = code
drop code
drop if Partner==Reporter    // optional: drop self-pairs
tempfile wld_expanded
save `wld_expanded'
restore

* -- Remove original WLD rows and append the expanded rows
drop if Partner=="WLD"
append using `wld_expanded'


* -- Rename some variables 
rename Reporter importer
rename Partner exporter

gen pair = exporter + "_" + importer
gen pair1 = importer + "_" + exporter

* --- Create HS codes
gen HS2 = substr(HSCode,1,2)
gen HS4 = substr(HSCode,1,4)

* --- Restrict to textiles (HS 50–63)
destring HS2, gen(code)
keep if code >= 50 & code <= 63
drop code 

rename HSCode HS6

merge m:m pair HS6 using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/trade_flows.dta"
drop if _merge == 2
drop _merge 

save "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/NTMdata.dta", replace
