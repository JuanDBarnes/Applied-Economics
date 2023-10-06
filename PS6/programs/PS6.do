/*******************************************************************************
                   Problem Set 6: diff-in-diffs 

                          Universidad de San Andrés
                              Economía Aplicada
/*******************************************************************************/
					Barnes, Fasan, Legaspe y Martin
/*******************************************************************************
Este archivo sigue la siguiente estructura:
* 0) Set up environment
* 1) Replica de la Tabla 4 (Cheng y Hoekstra, 2013)
* 2) Replica Panel C.1 with Callaway y Sant’Anna’s Estimator
* 3) Descomposición de Bacon para log(Burglary Rate)

*******************************************************************************/

* 0) Set up environment
*==============================================================================*/
clear all
global main "C:\Users\Usuario\Desktop\MAESTRIA\Economia Aplicada\TPs\Applied-Economics\PS6"
global input "$main/input"
global output "$main/output"

cd "$main"

* Open data

use "$input/castle.dta", clear 
browse 

net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
set scheme cleanplots

* define global macros (like Cunningham)
global crime1 jhcitizen_c jhpolice_c murder homicide robbery assault burglary larceny motor robbery_gun_r 
global demo blackm_15_24 whitem_15_24 blackm_25_44 whitem_25_44 //demographics
global lintrend trend_1-trend_51 //state linear trend
global region r20001-r20104  //region-quarter fixed effects
global exocrime l_larceny l_motor // exogenous crime rates
global spending l_exp_subsidy l_exp_pubwelfare
global xvar l_police unemployrt poverty l_income l_prisoner l_lagprisoner $demo $spending

* define variable labels like paper's table
label var post "Castle Doctrine Law"
label var l_burglary "Log(Burglary Rate)"
label var l_assault "Log(Aggravated Assault Rate)"
label var l_robbery "Log(Robbery Rate)"
label var pre2_cdl "0 to 2 years before adoption of castle doctrine law"
*******************************************************************************/
* 1) Replica de la Tabla 4 (Cheng y Hoekstra, 2013)
*==============================================================================*/
* Especificaciones:}
* 1.
* 2.
* 3.
* 4.
* 5. 
* 6.
* 7.
* 8.
* 9.
* 10.
* 11.
* 12.
*******************************************************************************/
* PANEL A
eststo clear
* 1
eststo: xtreg l_burglary post i.year [aweight=popwt], fe vce(cluster sid)

* 2
eststo: xtreg l_burglary post i.year $region [aweight=popwt], fe vce(cluster sid)

* 3
eststo: xtreg l_burglary post i.year $region $xvar [aweight=popwt], fe vce(cluster sid)

* 4 
eststo: xtreg l_burglary post pre2_cdl i.year $region $xvar [aweight=popwt], fe vce(cluster sid)

* 5 
eststo: xtreg l_burglary post i.year $exocrime $region $xvar [aweight=popwt], fe vce(cluster sid)

* 6 
eststo: xtreg l_burglary post i.year $lintrend $region $xvar [aweight=popwt], fe vce(cluster sid)

* 7 
eststo: xtreg l_burglary post i.year, fe vce(cluster sid)

* 8 
eststo: xtreg l_burglary post i.year $region, fe vce(cluster sid)

* 9 
eststo: xtreg l_burglary post i.year $region $xvar, fe vce(cluster sid)

* 10 
eststo: xtreg l_burglary post pre2_cdl i.year $region $xvar, fe vce(cluster sid)

* 11 
eststo: xtreg l_burglary post i.year $exocrime $region $xvar, fe vce(cluster sid)

* 12 
eststo: xtreg l_burglary post i.year $lintrend $region $xvar, fe vce(cluster sid)

esttab using "$output/Table4_A.tex", se replace label noobs noabbrev ///
keep(post pre2_cdl, relax) cells(b(fmt(4) star) se(par fmt(4)))
********************************************************************************
* PANEL B

eststo clear
* 1
eststo: xtreg l_robbery post i.year [aweight=popwt], fe vce(cluster sid)

* 2
eststo: xtreg l_robbery post i.year $region [aweight=popwt], fe vce(cluster sid)

* 3
eststo: xtreg l_robbery post i.year $region $xvar [aweight=popwt], fe vce(cluster sid)

* 4 
eststo: xtreg l_robbery post pre2_cdl i.year $region $xvar [aweight=popwt], fe vce(cluster sid)

* 5 
eststo: xtreg l_robbery post i.year $exocrime $region $xvar [aweight=popwt], fe vce(cluster sid)

* 6 
eststo: xtreg l_robbery post i.year $lintrend $region $xvar [aweight=popwt], fe vce(cluster sid)

* 7 
eststo: xtreg l_robbery post i.year, fe vce(cluster sid)

* 8 
eststo: xtreg l_robbery post i.year $region, fe vce(cluster sid)

* 9 
eststo: xtreg l_robbery post i.year $region $xvar, fe vce(cluster sid)

* 10 
eststo: xtreg l_robbery post pre2_cdl i.year $region $xvar, fe vce(cluster sid)

* 11 
eststo: xtreg l_robbery post i.year $exocrime $region $xvar, fe vce(cluster sid)

* 12 
eststo: xtreg l_robbery post i.year $lintrend $region $xvar, fe vce(cluster sid)

esttab using "$output/Table4_B.tex", se replace label noobs noabbrev ///
keep(post pre2_cdl, relax) cells(b(fmt(4) star) se(par fmt(4)))

********************************************************************************
* PANEL C 

eststo clear
* 1
eststo: xtreg l_assault post i.year [aweight=popwt], fe vce(cluster sid)

* 2
eststo: xtreg l_assault post i.year $region [aweight=popwt], fe vce(cluster sid)

* 3
eststo: xtreg l_assault post i.year $region $xvar [aweight=popwt], fe vce(cluster sid)

* 4 
eststo: xtreg l_assault post pre2_cdl i.year $region $xvar [aweight=popwt], fe vce(cluster sid)

* 5 
eststo: xtreg l_assault post i.year $exocrime $region $xvar [aweight=popwt], fe vce(cluster sid)

* 6 
eststo: xtreg l_assault post i.year $lintrend $region $xvar [aweight=popwt], fe vce(cluster sid)

* 7 
eststo: xtreg l_assault post i.year, fe vce(cluster sid)

* 8 
eststo: xtreg l_assault post i.year $region, fe vce(cluster sid)

* 9 
eststo: xtreg l_assault post i.year $region $xvar, fe vce(cluster sid)

* 10 
eststo: xtreg l_assault post pre2_cdl i.year $region $xvar, fe vce(cluster sid)

* 11 
eststo: xtreg l_assault post i.year $exocrime $region $xvar, fe vce(cluster sid)

* 12 
eststo: xtreg l_assault post i.year $lintrend $region $xvar, fe vce(cluster sid)

esttab using "$output/Table4_C.tex", se replace label noobs noabbrev ///
keep(post pre2_cdl, relax) cells(b(fmt(4) star) se(par fmt(4))) ///
indicate("State and Year Fixed Effects = *.year" "Region-by-Year Fixed Effects = *r20001" "Time-Varying Controls = *l_police" "Contemporaneous Crime Rates = *l_larceny" "State-Specific Linear Time Trends = *trend_1") ///
stats(N, fmt(0) labels("Observations"))

********************************************************************************
* Export Table 4

include "https://raw.githubusercontent.com/steveofconnell/PanelCombine/master/PanelCombine.do"

cd "$output"

panelcombine, use(Table4_A.tex Table4_B.tex Table4_C.tex)  columncount(12) paneltitles("Burglary" "Robbery" "Aggravated Assault") save(Table4.tex)

cd "$main"

*******************************************************************************/
* 2) Replica Panel C. 1 with Callaway y Sant’Anna’s Estimator
*==============================================================================*/

ssc install csdid
ssc install drdid
ssc install bacondecomp

bys state: gen treat = year if cdl>0 & cdl<1
bys state: egen treated = max(treat)
replace treated = 0 if treated == .

csdid l_assault post i.year i.sid [weight=popwt], ivar(sid) time(year) gvar(treated) method(reg) notyet

* Pretrends test

estat pretrend

* Average ATT

estat simple

estat event
csdid_plot

graph export "$output\EventStudy.png", as(png) name("Graph") replace

csdid_plot, group(2006) name(m1,replace) title("Group 2006")
csdid_plot, group(2007) name(m2,replace) title("Group 2007")
csdid_plot, group(2008) name(m3,replace) title("Group 2008")
csdid_plot, group(2009) name(m4,replace) title("Group 2009")
graph combine m1 m2 m3 m4, xcommon scale(0.8)

graph export "$output\4Years_ES.png", as(png) name("Graph") replace


*******************************************************************************/
* 3) Descomposición de Bacon para log(Burglary Rate)
*==============================================================================*/
ssc install bacondecomp

bacondecomp l_burglary post , stub(Bacon_) ddetail

graph export "$output\Bacon.png", as(png) name("Graph") replace

********************************************************************************
