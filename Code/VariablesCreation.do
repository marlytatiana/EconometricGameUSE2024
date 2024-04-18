// Variables creation
use "${dataClean}\pisaOECD.dta", clear
merge m:1 cnt using "${dataClean}\CountriesNames.dta"
drop if _merge==2



egen mean_math_score=rmean(pv1math - pv10math)
egen mean_read_score=rmean(pv1read - pv10read)

// Mean by country, wave and school
bys cnt : egen mean_math_cnt=mean(mean_math_score)
bys cnt : egen mean_read_cnt=mean(mean_read_score)

//
gen high_educ=(paredint>12)
gen low_educ=(paredint<=12)
gen repeat1=(repeat=="Repeated at lease once")

gen schoolstart = .
	replace schoolstart = 3 if st126q01ta=="3 or younger"
	replace schoolstart = 4 if st126q01ta=="4"
	replace schoolstart = 5 if st126q01ta=="5"
	replace schoolstart = 6 if st126q01ta=="6"
	replace schoolstart = 7 if st126q01ta=="7"
	replace schoolstart = 8 if st126q01ta=="8"
	replace schoolstart = 9 if st126q01ta=="9 or older"

gen yearschool = .
replace yearschool = age - schoolstart

bys cnt wave: egen mean_math_wav=mean(mean_math_score)
bys cnt wave: egen mean_read_wav=mean(mean_read_score)

encode st001d01t, gen(gradegroup)
gen female=(st004d01t=="Female")

bys cnt wave : egen mean_school_age=mean(schoolstart)
bys cnt wave : egen mean_math_cntWave=mean(mean_math_score)
bys cnt wave : egen mean_read_cntWave=mean(mean_read_score)

bysort wave cntschid st001d01t: egen school_grade_mean = mean(age)

gen relative_age = age - school_grade_mean


// Mean per country, per school for 2015
bys country cntschid: gen numberObsSchool=_N
*bys cntschid: sum mean_math_score 
*tabstat mean_math_score if wave==2015, by(cntschid)
*gen zscore_cst = (mean_math_score - mean_math_cs2015)/(sd__math_cs2015)
