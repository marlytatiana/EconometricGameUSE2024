

sysuse auto.dta,clear


gen cutoff=19
gen score=mpg - cutoff 

mat rdrobust_stats=J(3,7,.)
mat rdrobust_coeff=J(3,2,.)

rdrobust price score , all kernel(uniform)
matrix b_se = get(_b)', vecdiag(cholesky(diag(vecdiag(get(VCE)))))'
mat rdrobust_coeff[1,1] = b_se[3,1]
mat rdrobust_coeff[1,2] = b_se[3,2]

mat rdrobust_stats[1,1] = b_se[3,1]
mat rdrobust_stats[1,2] = b_se[3,2]
mat rdrobust_stats[1,3] = e(N)
mat rdrobust_stats[1,4] = e(N_l) 
mat rdrobust_stats[1,5] = e(N_r)
mat rdrobust_stats[1,6] = e(h_l)
mat rdrobust_stats[1,7] = e(h_r)

rdrobust price score if foreign==0, all kernel(uniform)
matrix b_se = get(_b)', vecdiag(cholesky(diag(vecdiag(get(VCE)))))'
mat rdrobust_coeff[2,1] = b_se[3,1]
mat rdrobust_coeff[2,2] = b_se[3,2]

mat rdrobust_stats[2,1] = b_se[3,1]
mat rdrobust_stats[2,2] = b_se[3,2]
mat rdrobust_stats[2,3] = e(N)
mat rdrobust_stats[2,4] = e(N_l) 
mat rdrobust_stats[2,5] = e(N_r)
mat rdrobust_stats[2,6] = e(h_l)
mat rdrobust_stats[2,7] = e(h_r)

rdrobust price score if foreign==1, all kernel(triangular) 
matrix b_se = get(_b)', vecdiag(cholesky(diag(vecdiag(get(VCE)))))'
mat rdrobust_coeff[3,1] = b_se[3,1]
mat rdrobust_coeff[3,2] = b_se[3,2]

mat rdrobust_stats[3,1] = b_se[3,1]
mat rdrobust_stats[3,2] = b_se[3,2]
mat rdrobust_stats[3,3] = e(N)
mat rdrobust_stats[3,4] = e(N_l) 
mat rdrobust_stats[3,5] = e(N_r)
mat rdrobust_stats[3,6] = e(h_l)
mat rdrobust_stats[3,7] = e(h_r)

mat list rdrobust_stats
mat list rdrobust_coeff

local deg_f_m= degrees
local bc = rowsof(rdrobust_coeff)
        matrix stars16 = J(`bc',2,0)
        forvalues k = 1/`bc' {
        matrix stars16[`k',2] = (abs(rdrobust_coeff[`k',1]/rdrobust_coeff[`k',2]) > invttail(`deg_f_m',0.05/2)) + (abs(rdrobust_coeff[`k',1]/rdrobust_coeff[`k',2]) > invttail(`deg_f_m',0.01/2))
        }
matrix list stars16


frmttable  using  "${tables}/autoRDD.tex"  , statmat(rdrobust_stats) sdec(2,2,0,0,0,2,2) rtitle("All" \ "Domestic" \ "Foreign") ctitle("" , "b", "se" , "N" , "N left", "N right" , "Bandwidth L", "Bandwidth R") tex frag replace

frmttable using "${tables}/autoRDDstats.tex", statmat(rdrobust_coeff) substat(1) annotate(stars) asymbol(*,**)  rtitle("All" \ "" \ "Domestic" \ "" \ "Foreign" \ "" )  ctitle("", "tau") tex frag replace 
