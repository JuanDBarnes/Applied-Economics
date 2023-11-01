* 0) Set up environment
*==============================================================================*
clear all

global main "C:\Users\Usuario\Desktop\MAESTRIA\Economia Aplicada\TPs\Applied-Economics\PS9"
global output "$main/output"
global input "$main/input"
global temp "$main/temp"

* 1) Generamos una muestra simulada con datos de pagos de impuestos de empresas
*==============================================================================*
clear all
set seed 123 // seteamos semilla para poder replicar los resultados
set obs 15000
gen ganancias_estimadas = rnormal(10000,2000)
drop if ganancias_estimadas<0

gen impuestos_pagados = 0.2*ganancias_estimadas + rnormal(0,500)
drop if impuestos_pagados<0

save "$input/base_simulada.dta", replace
browse
*==============================================================================*

* 2) Creo "base" que distribuye las tareas entre los distintos procesadores
*==============================================================================*
*net install parallel, from(https://raw.github.com/gvegayon/parallel/stable/) replace
*mata mata mlib index

parallel numprocessors
global processors=`r(numprocessors)'-2
local processors=`r(numprocessors)'-2

clear all
local efectos=5
local sizes=10
local obs=`efectos'*`sizes'
set obs `obs'
gen size=1000 if _n<=`efectos'
forv i=2/10{
	replace size=1000*`i' if _n<=`efectos'*`i' & size==.
}
bysort size: gen efecto=0.01 if _n==1
bysort size: replace efecto=0.025 if _n==2
bysort size: replace efecto=0.05 if _n==3
bysort size: replace efecto=0.075 if _n==4
bysort size: replace efecto=0.1 if _n==5

g n=_n
gen t0=n if _n==1
replace t0=t0[_n-1]+1 if t0==. & _n<`processors'+1
replace t0=t0[_n-`processors'] if t0==.
drop n

save "$temp/processors.dta", replace


cap program drop myprogram
parallel setclusters $processors
program def myprogram
forv i=1/$processors{
	if ($pll_instance == `i'){
		use "$temp/processors.dta", clear
		keep if t0==`i'
		forv j=1/`=_N'{
			mat resultados = J(1,3,.)
			summ size if _n==`j'
			local size=`r(mean)'
			summ efecto if _n==`j'
			local efecto=`r(mean)'
			mat R = J(500,2,.) 
			forvalues x=1(1)500 {
				preserve
				use "${input}/base_simulada.dta", clear
				sample `size' , count
				gen temp = runiform()
				gen T=0
				replace T = 1 if temp<0.5	
				replace impuestos_pagados = impuestos_pagados * (1+`efecto') if T==1
				reg impuestos_pagados T, robust
				mat R[`x',1]=_b[T]/_se[T]
				restore
			}
			preserve
			clear
			svmat R
			gen reject = 0
			replace reject = 1 if (R1>1.65)
			drop if reject==.
			sum reject
			scalar media = r(mean)
			
			mat resultados[1,3] = `efecto'
			mat resultados[1,2] = media
			mat resultados[1,1] = `size'
			restore
			
			preserve
			clear 
			svmat resultados
			rename resultados1 sample_size
			rename resultados2 st_power
			rename resultados3 efecto
			save "$temp/results_efecto`efecto'_size`size'.dta", replace
			restore
		}
	} 
}
end
parallel, nodata prog(myprogram): myprogram

* Append all datasets
cd "$temp" 
clear
append using `: dir . files "results_*.dta"'
duplicates drop
save "$output/power.dta", replace 


*==============================================================================*

* Gráfico
*==============================================================================*
use "$output/power.dta", clear
sort efecto sample_size

replace st_power=round(st_power,.01)
separate st_power, by(efecto)



set scheme s1color
twoway (connected st_power1 sample_size) (connected st_power2 sample_size) ///
(connected st_power3 sample_size) (connected st_power4 sample_size) ///
(connected st_power5 sample_size), ytitle("Power") ///
xtitle("Number of observations") ///
legend(label(1 "1%") label(2 "2.5%") label(3 "5%") label(4 "7.5%") label(5 "10%")) ///
legend(rows(1) title("Effect")) xscale(titlegap(3)) yscale(titlegap(3)) 
graph export "outpt/Graph 1 Penalization.png", replace
*==============================================================================*
