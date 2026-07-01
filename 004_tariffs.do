** import the data 
use "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/tariffs.dta", clear 

** generate pair 
gen pair = exporter + "_" + importer 
gen pair1 = importer + "_" + export
gen HS4 = (hs6_2007/100)
rename hs6_2007 HS6

duplicates report importer exporter HS6 adv

** generate the average tariffs 
bysort importer exporter HS2: egen tariff_mean_2 = mean(adv)
bysort importer exporter HS4: egen tariff_mean_4 = mean(adv)
bysort importer exporter HS6: egen tariff_mean_6 = mean(adv)

gen str6 HS6_str = string(HS6, "%06.0f")
drop HS6 HS2 HS4
rename HS6_str HS6

save "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/tariff_data.dta", replace
