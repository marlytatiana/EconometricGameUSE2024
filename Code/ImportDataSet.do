import delimit "${dataRaw}\Pisa201520182022_GameDataset.csv",clear

// Drop if no OECD country
drop if oecd=="2" | oecd=="No"

// Drop if country does not have the three waves
tab cnt wave 
drop if cnt=="COL"
drop if cnt=="CRI"
drop if cnt=="LTU"
drop if cnt=="LUX"

// verify final sample
tab cnt wave 

save "${dataClean}\pisaOECD.dta", replace



frame create countriesname
frame change countriesname
import excel "${dataRaw}\CountriesNames.xlsx",clear
rename A cnt
rename B countryname
save "${dataClean}\CountriesNames.dta", replace
frame change default
