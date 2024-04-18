// Regressions - heterogeneous effects


reghdfe mean_math_score mean_read_score age repeat1 high_educ i.schoolstart [aw=w_fstuwt], absorb(wave cnt cntschid)

reghdfe mean_math_score mean_read_score age repeat1 high_educ yearschool, absorb(wave cnt cntschid) coeflegend

reghdfe mean_math_score mean_read_score age repeat1 high_educ yearschool i.schoolstart hisei bfmj2 bmmj1, absorb(wave cnt cntschid) 

lincom _b[yearschool] + _b[6.schoolstart]

***

reghdfe mean_read_score mean_math_score age repeat1 high_educ yearschool i.schoolstart, absorb(wave cnt cntschid) 
lincom _b[yearschool] + _b[6.schoolstart]

reghdfe mean_read_score high_educ, absorb(wave cnt cntschid)


// 

tab st001d01t

reg mean_math_score mean_school_age age repeat1 grade female relative_age

collapse (mean) mean_math_score mean_read_score schoolstart age repeat1 grade female relative_age [aw= w_fstuwt] , by( cnt wave) 


scatter mean_math_score  schoolstart
scatter mean_read_score  schoolstart
scatter mean_read_score  mean_math_score  schoolstart

// Maths score per country and wave - correlation with schoolstart
reg mean_math_score schoolstart 
eststo maths1
reg mean_math_score schoolstart age repeat1 grade female relative_age 
eststo maths2
outreg2 [maths1 maths2] using "${tables}\corrStartingMaths", tex replace

// Reading score per country and wave -correlation with schoolstart
reg mean_read_score  schoolstart 
eststo read1
reg mean_read_score  schoolstart age repeat1 grade female relative_age 
eststo read2
outreg2 [read1 read2] using "${tables}\corrStartingRead", tex replace

outreg2 [maths1 maths2 read1 read2] using "${tables}\corrStartingMathsRead", tex replace frag
