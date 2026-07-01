** trade flows at the HS6 level 

* Import the data 
import delimited "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/trade flows/BACI_HS02_Y2016_V202501.csv", stringcols(4) clear 

* rename 
rename t year 
rename i exporter 
rename j importer 
rename k HSCode 
rename v trade_value 
rename q trade_quantity 
rename HSCode HS6 

* create HS2 and HS4 
gen HS2 = substr(HS6,1,2)
gen HS4 = substr(HS6,1,4)

drop year
 
* textiles and textile articles but not exclusive to the PSI
destring HS2, gen(code)
keep if code >= 50 & code <= 63
drop code

gen pair = string(importer, "%03.0f") + "_" + string(exporter, "%03.0f")
gen pair1 = string(exporter, "%03.0f") + "_" + string(importer, "%03.0f")

* save 
save "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/trade_flows.dta", replace 

* import another data 
import delimited "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/trade flows/country_codes_V202501.csv", clear 

* Start from your countries file
keep country_code country_iso3
duplicates drop country_code country_iso3, force   // ensure unique mapping

* Save a base copy
tempfile base left
save `base'

* LEFT side (exporter)
use `base', clear
gen one = 1
rename (country_code country_iso3) (exporter exp_iso3)
save `left', replace

* RIGHT side (importer)
use `base', clear
gen one = 1
rename (country_code country_iso3) (importer imp_iso3)

* Cartesian product
joinby one using `left'
drop one

list exporter exp_iso3 importer imp_iso3 in 1/10, abbrev(20)

gen pair = string(exporter, "%03.0f") + "_" + string(importer, "%03.0f")
gen pair1 = string(importer, "%03.0f") + "_" + string(exporter, "%03.0f")

save "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/country_code.dta", replace

** import the master data
use "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/trade_flows.dta", clear

** merge the datasets 
merge m:m pair pair1 using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/country_code.dta"

** clean the data 
drop pair
drop pair1 
drop if _merge ~= 3
drop _merge 
drop importer 
drop exporter

rename imp_iso3 importer 
rename exp_iso3 exporter 

gen pair = exporter + "_" + importer 
gen pair1 = importer + "_" + exporter

** save final as trade flows 
save "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/trade_flows.dta", replace 
