** load the data 
use "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/gravity.dta", clear 
 
** clean data
keep if year == 2016
keep iso3_d iso3_o gdp* wto* pop* col* com* dist* contig*
drop pop_source* gdp_source*

** rename 
rename iso3_o exporter
rename iso3_d importer 

gen pair = exporter + "_" + importer
gen pair1 = importer + "_" + exporter 

** save the data 
save "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/gravity_cepii.dta", replace  
