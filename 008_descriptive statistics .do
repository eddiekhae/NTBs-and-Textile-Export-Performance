** load the data 
cls
use "/Users/edwardagyapong/UTartu/Trade Policy Analysis/project/data/project.dta", clear

** summary statistics
foreach x of varlist Freq_HS2 Freq_HS4 Freq_HS6 agg_trade tariff_mean_2 tariff_mean_4 tariff_mean_6 rta {
	sum `x', detail 
} 


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

** get the importers for each income group 
levelsof importer if low == 1 
levelsof importer if lmi == 1
levelsof importer if upm == 1
levelsof importer if high == 1

** correlation between PSI and tariffs
corr tariff_mean_2 Freq_HS2
corr tariff_mean_4 Freq_HS4
corr tariff_mean_6 Freq_HS6
