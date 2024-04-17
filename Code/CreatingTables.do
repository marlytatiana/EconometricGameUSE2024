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
collapse (mean) mean_math_score mean_read_score (sd) sdmean_math_score =mean_math_score sdmean_read_score=mean_read_score (min) minmean_math_score =mean_math_score minmean_read_score=mean_read_score (max)  maxmean_math_score =mean_math_score maxmean_read_score=mean_read_score  , by( countryname wave)
save "${dataClean}\table_countries",replace
restore
*
frame create table_countries
frame change table_countries
use "${dataClean}\table_countries",clear
frame change default
********************


frmttable using "${tables}/countries_scores", statmat(mean_countries ) substat(1) sdec(1,1) ctitle("", "All Waves", "", "2015" , "", "2018", "", "2022", "" \ "", "Maths", "Read", "Maths", "Read", "Maths", "Read", "Maths", "Read") replace tex frag




