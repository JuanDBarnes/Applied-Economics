/*******************************************************************************
		     		Problem Set 11: Matching

                          Universidad de San Andrés
                              Economía Aplicada
/*******************************************************************************/
					Barnes, Fasan, Legaspe y Martin
/*******************************************************************************


* 0) Set up environment

* 1) Eliminamos missings y realizamos test de medias.

* 2) Calculamos el Propensity Score

* 3) Graficamos la distribucion del Propensity Score de Tratados y No Tratados

* 4) Generamos la variable binria para las observacion dentro del common suport.

* 5) Generamos el Matching dentro del common support

* 6) Graficamos las distribución después del matching

* 7) Realizamos el test de medias para tratados y no tratados con el matching.


*==============================================================================*/ 

*******************************************************************************/
*0)
clear all
global main "C:/Users/Diego/Desktop/UDESA/Aplicada/PS11"
global input "$main/input"
global output "$main/output"

cd "$main"

set matsize 4000
set more off

* Get data 
cd "$main"

use "input/base_censo.dta", clear

browse
order treated, first
*-------------------------------------------------------------------------
*1)
*Sacamos los missing values para después poder matchear todo con las caracteristicas observables
foreach var of varlist _all {
drop if missing(`var')
}
*Test de medias por variable
ttest pobl_1999, by(treated)
ttest via1, by(treated)
ttest ranking_pobr, by(treated)
*En principio contamos con muchas más observaciones para el grupo de tratados
*Las medias de las variables son distintas entre grupos, lo cual podría ser esperable si son caracteristicas que influyen en la posibilidad de ser tratado.

*--------------------------------------------------------------------------
*2
*Calculamos Propensity Score
probit treated ind_abs_pobr ldens_pob prov_cap pob_1 pob_2 pob_3 pob_4 km_cap_prov via3 via5 via7 via9 region_2 region_3 laltitud tdesnutr deficit_post deficit_aulas
predict P_score

*search pscore

*----------------------------------------------------------------------------
*3)
*Graficamos la distribucion del Propensity Score de Tratados y No Tratados
twoway (kdensity P_score if treated == 1, title("Distribución para Tratados") ytitle(Density) xtitle(Scoring) legend(label(1 "Tratados") pos(5)))(kdensity P_score if treated == 0, title("Distribución Propensity Score") ytitle(Density) xtitle(Scoring) legend(label(2 "No Tratados") pos(5)))
graph export "output/Distribuciones.png", replace
*Como es de esperar, la distribución de los tratados esta corrida hacia la derecha. Es decir, que las observaciones tratadas tienen más probabilidad de ser tratadas, lo cual es lógico.
*----------------------------------------------------------------------------
*4)
*Armamos la variable "common_sup" que toma valor 1 en los valores de P_score que hay observaciones de tratados y no tratados
egen x = min(P_score) if treated==1
egen psmin = min(x)
egen y = max(P_score) if treated==0
egen psmax = max(y)
drop x y
gen common_sup=1 if (P_score>=psmin & P_score<=psmax) & P_score!=.
replace common_sup=0 if common_sup==.
browse

*----------------------------------------------------------------------------
*5)
*Matcheamos distritos tratados y no tratados
psmatch2 treated if common_sup==1, p(P_score) noreplacement
gen matches=_weight
replace matches=0 if matches==.
*----------------------------------------------------------------------------
*6)
*Comparamos las distribuciones despues del matcheo y el common support
twoway (kdensity P_score if treated == 1 & matches == 1, title("Distribución para Tratados") ytitle(Density) xtitle(Scoring) legend(label(1 "Tratados") pos(5)))(kdensity P_score if treated == 0 & matches == 1, title("Distribución Propensity Score") ytitle(Density) xtitle(Scoring) legend(label(2 "No Tratados") pos(5)))
graph export "output/Distribuciones con Matching.png", replace
*----------------------------------------------------------------------------
 *7)
 *Test de medias por variable
ttest pobl_1999 if matches == 1, by(treated)
ttest via1 if matches == 1, by(treated)
ttest ranking_pobr if matches == 1, by(treated)
*En principio ahora tenemos la misma cantidad de observaciones. 
