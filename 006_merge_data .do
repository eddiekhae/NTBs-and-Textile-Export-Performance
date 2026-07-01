** import the master data 
use "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/NTMdata.dta", clear 

** merge the data using WB groups 
merge m:m pair using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/WB_group.dta", keep(match master)
drop _merge

** merge using the tariffs 
merge m:m pair HS6 using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/tariff_data.dta", keep(match master)
drop _merge

** merge using the RTAs  
merge m:m pair using "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/rta_data.dta", keep(match master)
drop _merge

** merge with CEPII data 

** save the final data 
save "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/NTMdata.dta", replace 
