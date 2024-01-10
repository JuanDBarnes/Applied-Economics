/*******************************************************************************
		     		Problem Set 7: cluster robust inference 

                          Universidad de San Andrés
                              Economía Aplicada
/*******************************************************************************/
					Barnes, Fasan, Legaspe y Martin
/*******************************************************************************
Este archivo sigue la siguiente estructura:
* 0) Set up environment
* 1) Robust standard errors
* 2) Cluster robust standard errors
* 3) Wild-bootstrap standard errors
* 4) ARTs.
*******************************************************************************/

* 0) Set up environment
*==============================================================================*/
clear all
global main "C:\Users\Usuario\Desktop\MAESTRIA\Economia Aplicada\TPs\Applied-Economics\PS7"
global input "$main/input"
global output "$main/output"

cd "$main"

use "$input/base01.dta", clear


ssc install boottest, replace

* Separo por grupos
gen group = 1
replace group = 2 if pair == 2 | pair == 4
replace group = 3 if pair == 5 | pair == 8
replace group = 4 if pair == 7
replace group = 5 if pair == 9 | pair == 10
replace group = 6 if pair == 11
replace group = 7 if pair == 12 | pair == 13
replace group = 8 if pair == 14 | pair == 15
replace group = 9 if pair == 16 | pair == 17
replace group = 10 if pair == 18 | pair == 20
replace group = 11 if pair == 19


eststo clear
********************************************************************************
* 1) Robust standard errors
*==============================================================================*/
reg zakaibag treated semarab semrel i.group, vce(robust)

********************************************************************************
* 2) Cluster robust standard errors
*==============================================================================*/
xtreg zakaibag treated semarab semrel, fe i(group) cluster(group)

********************************************************************************
* 3) Wild-bootstrap standard errors
*==============================================================================*/
xtreg zakaibag treated semarab semrel, fe i(group) cluster(group)
eststo boo: boottest treated, boottype(wild) cluster(group) robust seed(69) nograph



********************************************************************************
* 4) ARTs.
*==============================================================================*/
do "$main/programs/art.ado"

art zakaibag treated semarab semrel, cluster(group) m(regress) report(treated)

*==============================================================================*/
* Generar apendice
*==============================================================================*/

translate "$main/programs/PS7.do" "$main/documents/Apendice.pdf", translator(txt2pdf) replace
