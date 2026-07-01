** cleaning the income groups data 

** import the data 
import excel "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/income_group.xlsx", sheet("Data") firstrow clear

** rename 
rename CountryCode exporter

* Save a base copy
tempfile base left
save `base'

* LEFT side (exporter)
use `base', clear
gen one = 1
save `left', replace

* RIGHT side (importer)
use `base', clear
gen one = 1
rename (exporter gni) (importer gni_importer)

* Cartesian product
joinby one using `left'
drop one

list exporter importer in 1/10, abbrev(20)

gen pair = exporter + "_" + importer
gen pair1 = importer + "_" + exporter

save "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/WB_group.dta", replace 
