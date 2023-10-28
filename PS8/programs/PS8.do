/*******************************************************************************
		     		Problem Set 8: control sintético

                          Universidad de San Andrés
                              Economía Aplicada
/*******************************************************************************/
					Barnes, Fasan, Legaspe y Martin
/*******************************************************************************
Este archivo sigue la siguiente estructura:
* 0) Set up environment
* 1) Tables Replication of Ferire
*******************************************************************************/

* 0) Set up environment
*==============================================================================*/
clear all
global main "C:\Users\Usuario\Desktop\MAESTRIA\Economia Aplicada\TPs\Applied-Economics\PS8"
global input "$main/input"
global output "$main/output"

cd "$main"

*ssc install synth

********************************************************************************
* 1) Feire (2019) Replication
*==============================================================================*/
* Uso el csv en forma de panel
import delimited "$input/df.csv", encoding(UTF-8) clear
browse
* Defino el panel
tsset code year
line homiciderates year
collapse (mean) homiciderates if code!=35, by(year)
gen code=1
save "$input/brasil.dta", replace

import delimited "$input/df.csv", encoding(UTF-8) clear

append using "$input/brasil.dta"

twoway (line homiciderates year if code==1, lcolor(grey) lpattern(dash)) (line homiciderates year if code==35, lcolor(black)), ytitle("Homicide Rates") xtitle("Year") xline(1999, lpattern(shortdash) lcolor(grey)) legend(label(1 "Sao Paulo") label(2 "Brazil (average)"))
graph export "$output/Plot 1.png", replace

* Gráfico 2

drop if code==1

synth homiciderates yearsschoolingimp stategdpcapita homiciderates proportionextremepoverty giniimp populationprojectionln stategdpgrowthpercent, trunit(35) trperiod(1999) nested fig keep(restout)

graph export "C:\Users\Usuario\Desktop\MAESTRIA\Economia Aplicada\TPs\Applied-Economics\PS8\output\ Plot 2.png", as(png) replace



* Vemos la informacion en la memoria
eret list 
* Guardamos los pesos y las medias
mat list e(W_weights)
mat list e(X_balance)

* Gráfico 3

matrix gaps=e(Y_treated) -e(Y_synthetic)
matrix Y_treated=e(Y_treated)
matrix Y_synthetic=e(Y_synthetic)
keep year 
svmat gaps
svmat Y_treated
svmat Y_synthetic

twoway (line gaps1 year, lcolor(black)), xline(1999,lpattern(shortdash) lcolor(grey)) yline(0, lpattern(dash) lcolor(black)) ytitle("Gap in Homicide Rates") xtitle("Year")

graph export "$output/Plot 3.png", replace

* Gráfico 4

import delimited "$input/df.csv", encoding(UTF-8) clear

tsset code year

synth homiciderates yearsschoolingimp stategdpcapita homiciderates proportionextremepoverty giniimp populationprojectionln stategdpgrowthpercent, trunit(35) trperiod(1995) resultsperiod(1990(1)1998) nested fig

graph export "C:\Users\Usuario\Desktop\MAESTRIA\Economia Aplicada\TPs\Applied-Economics\PS8\output\ Plot 4.png", as(png) replace


* Gráfico 5

egen id=group(code)

save "$input/df.dta", replace

use "$input/df.dta", clear

tsset id year

cd "$input/loo"

tempname resmat
        local i 20
        qui synth homiciderates yearsschoolingimp stategdpcapita homiciderates proportionextremepoverty giniimp populationprojectionln stategdpgrowthpercent, trunit(`i') trperiod(1999) keep(loo-resout`i', replace)	
		
		forvalues j=1/28 {
		if `j'==20 { 
		continue
		}
		use "$input/df.dta", clear
		tsset id year 
		drop if id==`j'
        qui synth homiciderates yearsschoolingimp stategdpcapita homiciderates proportionextremepoverty giniimp populationprojectionln stategdpgrowthpercent, trunit(20) trperiod(1999) keep(loo-resout`j', replace)	
        }

forvalues i = 1/28 {
use "$input/loo/loo-resout`i'.dta", clear
ren _Y_synthetic _Y_synthetic_`i'
ren _Y_treated _Y_treated_`i'
gen _Y_gap_`i'=_Y_treated_`i'-_Y_synthetic_`i'
save "$input/loo/loo-resout`i'.dta", replace
}

use "$input/loo/loo-resout1.dta", clear
forvalues i = 2/28 {
merge 1:1 _Co_Number _time using "$input/loo/loo-resout`i'.dta", nogen
}

twoway (line _Y_synthetic_1 _time, lcolor(gray)) (line _Y_synthetic_2 _time, lcolor(gray)) (line _Y_synthetic_3 _time, lcolor(gray)) (line _Y_synthetic_4 _time, lcolor(gray)) (line _Y_synthetic_5 _time, lcolor(gray)) (line _Y_synthetic_6 _time, lcolor(gray)) (line _Y_synthetic_7 _time, lcolor(gray)) (line _Y_synthetic_8 _time, lcolor(gray)) (line _Y_synthetic_9 _time, lcolor(gray)) (line _Y_synthetic_10 _time, lcolor(gray)) (line _Y_synthetic_11 _time, lcolor(gray)) (line _Y_synthetic_12 _time, lcolor(gray)) (line _Y_synthetic_13 _time, lcolor(gray)) (line _Y_synthetic_14 _time, lcolor(gray)) (line _Y_synthetic_15 _time, lcolor(gray)) (line _Y_synthetic_16 _time, lcolor(gray)) (line _Y_synthetic_17 _time, lcolor(gray)) (line _Y_synthetic_18 _time, lcolor(gray)) (line _Y_synthetic_19 _time, lcolor(gray)) (line _Y_synthetic_21 _time, lcolor(gray)) (line _Y_synthetic_22 _time, lcolor(gray)) (line _Y_synthetic_23 _time, lcolor(gray)) (line _Y_synthetic_24 _time, lcolor(gray)) (line _Y_synthetic_25 _time, lcolor(gray)) (line _Y_synthetic_26 _time, lcolor(gray)) (line _Y_synthetic_27 _time, lcolor(gray)) (line _Y_treated_20 _time, lcolor(black) lwidth(thick)) (line _Y_synthetic_28 _time, lcolor(black) lpattern(dash)), xline(1999, lpattern(shortdash) lcolor(grey)) legend(order(27 "Sao Paulo" 28 "Synthetic Sao Paulo" 3 "Synthetic Sao Paulo (leave-one-out)")) xtitle("Year") ytitle("Homicide Rates")
graph export "C:\Users\Usuario\Desktop\MAESTRIA\Economia Aplicada\TPs\Applied-Economics\PS8\output\ Plot 5.png", as(png) replace



* Gráfico 6

use "$input/df.dta", clear
tsset id year 

cd "$input/f6"

tempname resmat
        local i 20
        qui synth homiciderates yearsschoolingimp stategdpcapita homiciderates proportionextremepoverty giniimp populationprojectionln stategdpgrowthpercent, trunit(`i') trperiod(1999) keep(resout`i', replace)	
        matrix `resmat' = nullmat(`resmat') \ e(RMSPE)
        local names `"`names' `"`i'"'"'
        mat colnames `resmat' = "RMSPE"
        mat rownames `resmat' = `names'
        matlist `resmat' , row("Treated Unit")
		
		drop if id==20
		
        forvalues i = 1/27 {
		if `i'==20 { 
		continue
		}
        qui synth homiciderates yearsschoolingimp stategdpcapita homiciderates proportionextremepoverty giniimp populationprojectionln stategdpgrowthpercent, trunit(`i') trperiod(1999) keep(resout`i', replace)	
        matrix `resmat' = nullmat(`resmat') \ e(RMSPE)
        local names `"`names' `"`i'"'"'
        }
		
        mat colnames `resmat' = "RMSPE"
        mat rownames `resmat' = `names'
        matlist `resmat' , row("Treated Unit")

forvalues i = 1/27 {
use "$input/f6/resout`i'.dta", clear
ren _Y_synthetic _Y_synthetic_`i'
ren _Y_treated _Y_treated_`i'
gen _Y_gap_`i'=_Y_treated_`i'-_Y_synthetic_`i'
save "$input/f6/resout`i'.dta", replace
}

use "$input/f6/resout1.dta", clear
forvalues i = 2/27 {
merge 1:1 _Co_Number _time using "$input/f6/resout`i'.dta", nogen
}

save "$input/pt.dta", replace

use "$input/df.dta", clear

tsset id year 

synth homiciderates yearsschoolingimp stategdpcapita homiciderates proportionextremepoverty giniimp populationprojectionln stategdpgrowthpercent, trunit(20) trperiod(1999) nested

matrix gaps=e(Y_treated) -e(Y_synthetic)
matrix Y_treated=e(Y_treated)
matrix Y_synthetic=e(Y_synthetic)
keep year
svmat gaps
svmat Y_treated
svmat Y_synthetic
gen _Co_Number=_n
gen _time=year
save "$input/f6/resout28", replace

use "$input/f6/resout1.dta", clear
forvalues i = 2/28 {
merge 1:1 _Co_Number _time using "$input/f6/resout`i'.dta", nogen
}


twoway (line _Y_gap_1 _time, lcolor(gray)) (line _Y_gap_2 _time, lcolor(gray)) (line _Y_gap_3 _time, lcolor(gray)) (line _Y_gap_4 _time, lcolor(gray)) (line _Y_gap_5 _time, lcolor(gray)) (line _Y_gap_6 _time, lcolor(gray)) (line _Y_gap_7 _time, lcolor(gray)) (line _Y_gap_8 _time, lcolor(gray)) (line _Y_gap_9 _time, lcolor(gray)) (line _Y_gap_10 _time, lcolor(gray)) (line _Y_gap_11 _time, lcolor(gray)) (line _Y_gap_12 _time, lcolor(gray)) (line _Y_gap_13 _time, lcolor(gray)) (line _Y_gap_14 _time, lcolor(gray)) (line _Y_gap_15 _time, lcolor(gray)) (line _Y_gap_16 _time, lcolor(gray)) (line _Y_gap_17 _time, lcolor(gray)) (line _Y_gap_18 _time, lcolor(gray)) (line _Y_gap_19 _time, lcolor(gray)) (line _Y_gap_21 _time, lcolor(gray)) (line _Y_gap_22 _time, lcolor(gray)) (line _Y_gap_23 _time, lcolor(gray)) (line _Y_gap_24 _time, lcolor(gray)) (line _Y_gap_25 _time, lcolor(gray)) (line _Y_gap_26 _time, lcolor(gray)) (line _Y_gap_27 _time, lcolor(gray)) (line gaps1 _time, lcolor(black) lwidth(thick)), xline(1999, lpattern(shortdash) lcolor(grey)) legend(order(27 "Sao Paulo" 2 "Control States")) xtitle("Year") ytitle("Gap in Homicide Rates") yline(0, lcolor(black))

graph export "$output/ Plot 6.png", replace

* Gráfico 7

use "$input/df.dta", clear
tsset id year 

keep if code==13 | code==15 |code==17|code==21|code==23|code==24|code==25|code==31|code==41|code==42|code==43|code==53|code==35

cd "$input/f7"

egen id2=group(code)

tsset id2 year

tempname resmat
        local i 9
        qui synth homiciderates yearsschoolingimp stategdpcapita homiciderates proportionextremepoverty giniimp populationprojectionln stategdpgrowthpercent, trunit(`i') trperiod(1999) keep(resout`i', replace)	
        matrix `resmat' = nullmat(`resmat') \ e(RMSPE)
        local names `"`names' `"`i'"'"'
        mat colnames `resmat' = "RMSPE"
        mat rownames `resmat' = `names'
        matlist `resmat' , row("Treated Unit")
		
		drop if id2==9
		
        forvalues i = 1/13 {
		if `i'==9 { 
		continue
		}
        qui synth homiciderates yearsschoolingimp stategdpcapita homiciderates proportionextremepoverty giniimp populationprojectionln stategdpgrowthpercent, trunit(`i') trperiod(1999) keep(resout`i', replace)	
        matrix `resmat' = nullmat(`resmat') \ e(RMSPE)
        local names `"`names' `"`i'"'"'
        }
		
        mat colnames `resmat' = "RMSPE"
        mat rownames `resmat' = `names'
        matlist `resmat' , row("Treated Unit")

forvalues i = 1/13 {
use "$input/f7/resout`i'.dta", clear
ren _Y_synthetic _Y_synthetic_`i'
ren _Y_treated _Y_treated_`i'
gen _Y_gap_`i'=_Y_treated_`i'-_Y_synthetic_`i'
save "$input/f7/resout`i'.dta", replace
}

use "$input/f7/resout1.dta", clear
forvalues i = 2/13 {
merge 1:1 _Co_Number _time using "$input/f7/resout`i'.dta", nogen
}

save "$input/pt2.dta", replace

use "$input/df.dta", clear

tsset id year 

synth homiciderates yearsschoolingimp stategdpcapita homiciderates proportionextremepoverty giniimp populationprojectionln stategdpgrowthpercent, trunit(20) trperiod(1999) nested

matrix gaps=e(Y_treated) -e(Y_synthetic)
matrix Y_treated=e(Y_treated)
matrix Y_synthetic=e(Y_synthetic)
keep year
svmat gaps
svmat Y_treated
svmat Y_synthetic
gen _Co_Number=_n
gen _time=year
save "$input/f7/resout14", replace

use "$input/f7/resout1.dta", clear
forvalues i = 2/14 {
merge 1:1 _Co_Number _time using "$input/f7/resout`i'.dta", nogen
}


twoway (line _Y_gap_1 _time, lcolor(gray)) (line _Y_gap_2 _time, lcolor(gray)) (line _Y_gap_3 _time, lcolor(gray)) (line _Y_gap_4 _time, lcolor(gray)) (line _Y_gap_5 _time, lcolor(gray)) (line _Y_gap_6 _time, lcolor(gray)) (line _Y_gap_7 _time, lcolor(gray)) (line _Y_gap_8 _time, lcolor(gray)) (line _Y_gap_10 _time, lcolor(gray)) (line _Y_gap_11 _time, lcolor(gray)) (line _Y_gap_12 _time, lcolor(gray)) (line gaps1 _time, lcolor(black) lwidth(thick)), xline(1999, lpattern(shortdash) lcolor(grey)) legend(order(12 "Sao Paulo" 2 "Control States (MSPE)")) xtitle("Year") ytitle("Gap in Homicide Rates") yline(0, lcolor(black))
graph export "C:\Users\Usuario\Desktop\MAESTRIA\Economia Aplicada\TPs\Applied-Economics\PS8\output\ Plot 7.png", as(png) replace

********************************************************************************

********************************************************************************
*Exportar a pdf

translate "$main/programs/PS8.do" "$output/Apendice.pdf", translator(txt2pdf) replace
