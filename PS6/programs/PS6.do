/*******************************************************************************
                   Semana 6: Datos de Panel 

                          Universidad de San Andrés
                              Economía Aplicada
/*******************************************************************************/
					Barnes, Fasan, Legaspe y Martin
/*******************************************************************************
Este archivo sigue la siguiente estructura:



*******************************************************************************/

* 0) Set up environment
*==============================================================================*/
clear all
global main "C:\Users\Usuario\Desktop\MAESTRIA\Economia Aplicada\TPs\PS6"
global input "$main/input"
global output "$main/output"

cd "$main"

* Open data

use "$input/microcredit.dta", clear 
replace year = 1991 if year ==0
replace year = 1998 if year ==1
xtset nh year //Set panel 
*******************************************************************************/

* 1) Baseline Estimation 
*==============================================================================*/
browse 
summarize

gen l_exptot = log(exptot)
label var l_exptot "Log Expenditure"
label var dfmfd "Female participation"
reg l_exptot dfmfd, robust 
outreg2 using "output/base1_spec.rtf",dec(3)label addtext(Village fixed effects, No, Household fixed effects, No, Year fixed effects, No, Controls, No) replace
*******************************************************************************/

* 2)Introducing fixed effects. 
*==============================================================================*/
ssc install reghdfe
ssc install ftools
reg l_exptot dfmfd, robust 
outreg2 using "output/base_spec.rtf",dec(3)label addtext(Village fixed effects, No, Household fixed effects, No, Year fixed effects, No, Controls, No) replace 
areg exptot dfmfd, absorb(nh) robust
outreg2 using "output/base_spec.rtf",dec(3)label addtext(Village fixed effects, No, Household fixed effects, Yes, Year fixed effects, No, Controls, No) append
areg exptot dfmfd, absorb(year) robust
outreg2 using "output/base_spec.rtf",dec(3)label addtext(Village fixed effects, No, Household fixed effects, No, Year fixed effects, Yes, Controls, No) append 
areg exptot dfmfd, absorb(village) robust
outreg2 using "output/base_spec.rtf",dec(3)label addtext(Village fixed effects, Yes, Household fixed effects, No, Year fixed effects, No, Controls, No) append 
reghdfe exptot dfmfd, absorb(village nh) vce(robust)
outreg2 using "output/base_spec.rtf",dec(3)label addtext(Village fixed effects, Yes, Household fixed effects, Yes, Year fixed effects, No, Controls, No) append 
reghdfe exptot dfmfd, absorb(year nh) vce(robust)
outreg2 using "output/base_spec.rtf",dec(3)label addtext(Village fixed effects, No, Household fixed effects, Yes, Year fixed effects, Yes, Controls, No) append 
reghdfe exptot dfmfd, absorb(year village) vce(robust)
outreg2 using "output/base_spec.rtf",dec(3)label addtext(Village fixed effects, Yes, Household fixed effects, No, Year fixed effects, Yes, Controls, No) append 
*******************************************************************************/

* 3)More fixed effects 
*==============================================================================*/
gen village_year = village*year
gen household_year = nh*year


reghdfe exptot dfmfd, absorb(village_year) vce(robust)
outreg2 using "output/base_spec.rtf",dec(3)label addtext(Village fixed effects, Yes, Household fixed effects, No, Year fixed effects, Yes, Controls, No) append 
reghdfe exptot dfmfd, absorb(household_year) vce(robust)
outreg2 using "output/base_spec.rtf",dec(3)label addtext(Village fixed effects, No, Household fixed effects, Yes, Year fixed effects, Yes, Controls, No) append
//Insufficient observation for the last one.


reghdfe exptot dfmfd, absorb(village_year  nh) vce(robust)
outreg2 using "output/base_spec.rtf",dec(3)label addtext(Village fixed effects, Yes, Household fixed effects, No, Year fixed effects, Yes, Controls, No) append

