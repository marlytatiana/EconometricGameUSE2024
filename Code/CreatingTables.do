use "${dataClean}\pisaOECD.dta", clear
merge m:1 cnt using "${dataClean}\CountriesNames.dta"
drop if _merge==2

tostring cntschid, gen(cntschidString) 
tostring cntstuid, gen(cntstuidString)
egen cntschstuid = concat(cntschidString cntstuidString)
destring cntschstuid,replace
format cntschstuid %25.0f


foreach i of numlist 1/10 {
	sum pv`i'math
	sum pv`i'read
}

egen mean_math_score=rmean(pv1math - pv10math)
egen mean_read_score=rmean(pv1read - pv10read)

estpost tabstat mean_math_score, by(countryname) s(mean sd min max)
mat mean_countries_math= (e(mean)' , e(sd)')

estpost tabstat mean_read_score, by(countryname) s(mean sd min max)
mat mean_countries_read= (e(mean)' , e(sd)')

estpost tabstat mean_math_score if wave==2015, by(countryname) s(mean sd min max)
mat mean_countries_math_2015= (e(mean)' , e(sd)')

estpost tabstat mean_read_score if wave==2015, by(countryname) s(mean sd min max)
mat mean_countries_read_2015= (e(mean)' , e(sd)')

estpost tabstat mean_math_score if wave==2018, by(countryname) s(mean sd min max)
mat mean_countries_math_2018= (e(mean)' , e(sd)')

estpost tabstat mean_read_score if wave==2018, by(countryname) s(mean sd min max)
mat mean_countries_read_2018= (e(mean)' , e(sd)')

estpost tabstat mean_math_score if wave==2022, by(countryname) s(mean sd min max)
mat mean_countries_math_2022= (e(mean)' , e(sd)')

estpost tabstat mean_read_score if wave==2022, by(countryname) s(mean sd min max)
mat mean_countries_read_2022= (e(mean)' , e(sd)')

mat mean_countries =( mean_countries_math, mean_countries_read, mean_countries_math_2015,  mean_countries_read_2015, mean_countries_math_2018, mean_countries_read_2018, mean_countries_math_2022, mean_countries_read_2022 )

mat list mean_countries 

********************
preserve
collapse (mean) mean_math_score mean_read_score (sd) sdmean_math_score =mean_math_score sdmean_read_score=mean_read_score (min) minmean_math_score =mean_math_score minmean_read_score=mean_read_score (max)  maxmean_math_score =mean_math_score maxmean_read_score=mean_read_score  , by( cnt wave)
save "${dataClean}\table_countries",replace
restore
*
frame create table_countries
frame change table_countries
use "${dataClean}\table_countries",clear
frame change default
********************

// Descriptive table for all OECD selected countries
frmttable using "${tables}/countries_scores.tex", statmat(mean_countries ) substat(1) sdec(1,1) ctitle("", "All Waves", "", "2015" , "", "2018", "", "2022", "" \ "", "Maths", "Read", "Maths", "Read", "Maths", "Read", "Maths", "Read") tex frag replace 


// Mean by country, wave and school
bys cnt : egen mean_math_cnt=mean(mean_math_score)
bys cnt : egen mean_read_cnt=mean(mean_read_score)

histogram mean_math_cnt
histogram mean_read_cnt


bys cnt wave: egen mean_math_wav=mean(mean_math_score)
bys cnt wave: egen mean_read_wav=mean(mean_read_score)

histogram mean_math_wav
histogram mean_read_wav


bys cnt wave cntschid: egen mean_math_ind=mean(mean_math_score)
bys cnt wave cntschid: egen mean_read_ind=mean(mean_read_score)

histogram mean_math_ind
histogram mean_read_ind



// Mean per country, per school for 2015
bys country cntschid: gen numberObsSchool=_N
bys cntschid: sum mean_math_score 
tabstat mean_math_score if wave==2015, by(cntschid)

gen zscore_cst = (mean_math_score - mean_math_cs2015)/(sd__math_cs2015)

// sum mean_math_score if wave==2015 & cntschid==3600048
//  r(mean) =  524.4783243815104
//                 r(Var) =  4775.865294666624
//                  r(sd) =  69.10763557427373


export delimit using "${dataClean}\pisaOECD_clean.txt",replace

//
gen high_educ=(paredint>12)
gen low_educ=(paredint<=12)
gen repeat1=(repeat=="Repeated at lease once")
encode st126q01ta, gen(schoolstart)
ttest mean_math_score, by(high_educ)
ttest mean_read_score, by(high_educ)

gen yearschool = .
replace yearschool = age - 3 if schoolstart==1
replace yearschool = age - 4 if schoolstart==2
replace yearschool = age - 5 if schoolstart==3
replace yearschool = age - 6 if schoolstart==4
replace yearschool = age - 7 if schoolstart==5
replace yearschool = age - 8 if schoolstart==6
replace yearschool = age - 9 if schoolstart==7

reghdfe mean_math_score mean_read_score age repeat1 high_educ i.schoolstart, absorb(wave cnt cntschid)

reghdfe mean_math_score mean_read_score age repeat1 high_educ yearschool, absorb(wave cnt cntschid) coeflegend

reghdfe mean_math_score mean_read_score age repeat1 high_educ yearschool i.schoolstart hisei bfmj2 bmmj1, absorb(wave cnt cntschid) 

lincom _b[yearschool] + _b[6.schoolstart]

***

reghdfe mean_read_score mean_math_score age repeat1 high_educ yearschool i.schoolstart, absorb(wave cnt cntschid) 
lincom _b[yearschool] + _b[6.schoolstart]

reghdfe mean_read_score high_educ, absorb(wave cnt cntschid)