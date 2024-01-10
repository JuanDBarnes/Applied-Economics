/*******************************************************************************
		     		Problem Set 10: Regression discontinuity

                          Universidad de San Andrés
                              Economía Aplicada
/*******************************************************************************/
					Barnes, Fasan, Legaspe y Martin
/*******************************************************************************


* 0) Set up environment

* 1) Generate cut-off

* 2) RD Graphs - polinomial order 1 and 2

* 3) Falsification tests

* 4) No controls vs with controls

* 5) Effects of differents bandwidth

* 6) Changing cutoff

* 7) Local randomization with triangular kernel


*==============================================================================*/ 

*******************************************************************************/
clear all
global main "C:\Users\Usuario\Desktop\MAESTRIA\Economia Aplicada\TPs\Applied-Economics\PS10"
global input "$main/input"
global output "$main/output"

cd "$main"

set matsize 4000
set more off

* INSTALL PACKAGES
** RDROBUST: net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace
** RDDENSITY: net install rdlocrand, from(https://raw.githubusercontent.com/rdpackages/rdlocrand/master/stata) replace
** RDLOCRAND: net install rddensity, from(https://raw.githubusercontent.com/rdpackages/rddensity/master/stata) replace

* Get data 
cd "$main"

use "$input/data_elections.dta", clear

*******************************************************************************/
* 1) Generate cut-off
*******************************************************************************/

gen demwon=0
replace demwon=1 if vote_share_democrats>0.5


*******************************************************************************/
* 2) RD Graphs - polinomial order 1 and 2
*******************************************************************************/


global covs "unemplyd union urban veterans"

rdplot lne vote_share_democrats, c(0.5) p(1) graph_options(graphregion(color(white)) ///
							xtitle(Democrats vote share) ///
							ytitle(Log FED expenditure) name(glne, replace))

graph export "$output/pol_g1.png", replace

rdplot lne vote_share_democrats, c(0.5) p(2) graph_options(graphregion(color(white)) ///
							xtitle(Democrats vote share) ///
							ytitle(Log FED expenditure) name(glne, replace))

graph export "$output/pol_g2.png", replace



*******************************************************************************/
* 3) Falsification tests
*******************************************************************************/

* Density discontinuity test

rddensity vote_share_democrats, plot c(0.5)
graph export "$output/falsif_test1.png", replace

* Placebo tests on pre-determined covariates

foreach var of global covs {
	rdrobust `var' vote_share_democrats, c(0.5)
	qui rdplot `var' vote_share_democrats, c(0.5) p(1) graph_options(graphregion(color(white)) ///
													  xlabel(0.2(0.1)1) ///
													  ytitle(`var') name(g`var', replace))
	graph export "$output/falsif_test_`var'.png", replace
}

local num: list sizeof global(covs)
mat def pvals = J(`num',1,.)
local row = 1

foreach var of global covs {
    qui rdrobust `var' vote_share_democrats, c(0.5)
    mat pvals[`row',1] =  e(pv_rb)
    local row = `row'+1
	}
frmttable using "$output/pvals_falsif", statmat(pvals) replace tex

*******************************************************************************/
* 4) No controls vs with controls
*******************************************************************************/
est clear
* No controls
eststo rd1: rdrobust lne vote_share_democrats, masspoints(off) stdvars(on) c(0.5) p(1)
* With controls
eststo rd2: rdrobust lne vote_share_democrats, covs("unemplyd union urban veterans") masspoints(off) stdvars(on) c(0.5) p(1)

esttab rd1 rd2 using "$output/Reg_no_controls_p4.tex", replace label ///
cells(b(fmt(3) star) se(par fmt(2)))

*******************************************************************************/
* 5) Effects of differents bandwidth
*******************************************************************************/
* bandwidth = 0,025
eststo rd3: rdrobust lne vote_share_democrats, covs("unemplyd union urban veterans") masspoints(off) stdvars(on) c(0.5) p(1) h(0.025)
* bandwidth = 0,15
eststo rd4: rdrobust lne vote_share_democrats, covs("unemplyd union urban veterans") masspoints(off) stdvars(on) c(0.5) p(1) h(0.15)
* bandwidth  = 0,25
eststo rd5: rdrobust lne vote_share_democrats, covs("unemplyd union urban veterans") masspoints(off) stdvars(on) c(0.5) p(1) h(0.25)

esttab rd3 rd4 rd5 using "$output/Reg_h_p5.tex", replace label ///
cells(b(fmt(3) star) se(par fmt(2)))

*******************************************************************************/
* 6) Changing cutoff
*******************************************************************************/
* Cut-off 40%
eststo rd6: rdrobust lne vote_share_democrats, covs("unemplyd union urban veterans") masspoints(off) stdvars(on) c(0.4) p(1)

rdplot lne vote_share_democrats, c(0.4) p(1) graph_options(graphregion(color(white)) ///
							xtitle(Democrats vote share) ///
							ytitle(Log FED expenditure) name(glne, replace))
* Cut-off 60%
eststo rd7: rdrobust lne vote_share_democrats, covs("unemplyd union urban veterans") masspoints(off) stdvars(on) c(0.6) p(1)

rdplot lne vote_share_democrats, c(0.6) p(1) graph_options(graphregion(color(white)) ///
							xtitle(Democrats vote share) ///
							ytitle(Log FED expenditure) name(glne, replace))

esttab rd6 rd7 using "$output/Diferent_cutoff_p6.tex", replace label ///
cells(b(fmt(3) star) se(par fmt(2)))


*******************************************************************************/
* 7) Local randomization with triangular kernel
*******************************************************************************/
* 20 iterations with seed 444
rdwinselect vote_share_democrats unemplyd union urban veterans, wmin(0.05) wstep(0.01) nwindows(20) seed(444) plot graph_options(xtitle(Half window length) ytitle(Minimum p-value across all covariates) graphregion(color(white))) c(0.5) kernel(triangular)

rdrandinf lne vote_share_democrats, wl(0.32) wr(0.68) reps(1000) seed(444) c(0.5) kernel(triangular) p(1)

*******************************************************************************/
*Export to PDF
*******************************************************************************/
translate "$main/programs/PS10.do" "$documents/Apendice.pdf", translator(txt2pdf) replace
