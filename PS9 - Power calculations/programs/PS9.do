/*******************************************************************************
		     		Problem Set 9: power calculations 

                          Universidad de San Andrés
                              Economía Aplicada
/*******************************************************************************/
					Barnes, Fasan, Legaspe y Martin
/*******************************************************************************
Este archivo sigue la siguiente estructura:
* 0) Set up environment
* 1) Replica grafico tutorial
* 2) Replica con varianza de u en 5000
* 3) Replica con varianza de u en 5000 y 20% Tratado
* 4) Replica con varianza de u en 5000 y 80% Tratado
* 5) Replica con varianza de u en 500 y con ganancias_estimadas_2019 como control

*******************************************************************************/

* 0) Set up environment
*==============================================================================*/
clear all
global main "C:\Users\Usuario\Desktop\MAESTRIA\Economia Aplicada\TPs\Applied-Economics\PS9"
global input "$main/input"
global output "$main/output"

cd "$main"

set matsize 4000
set more off
*==============================================================================*
********************************************************************************
* 1) Replica grafico tutorial
*==============================================================================*/
* Generamos una muestra simulada con datos de pagos de impuestos de empresas

clear all
set seed 123 // seteamos semilla para poder replicar los resultados
set obs 15000
gen ganancias_estimadas = rnormal(10000,2000)
drop if ganancias_estimadas<0

gen impuestos_pagados = 0.2*ganancias_estimadas + rnormal(0,500)
drop if impuestos_pagados<0

gen obs=_n
pctile escuela = obs, nq(10)


* Repito la simulación pero para distintos tamaños de muestra y para distintos efectos
local i=1
mat resultados = J(50,4,.)

foreach efecto in 0.01 0.025 0.05 0.075 0.1{
forvalues size = 1000(1000)10000 {
mat R = J(500,2,.) 

forvalues x=1(1)500 {

preserve

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


mat resultados[`i',3] = `efecto'
mat resultados[`i',2] = media
mat resultados[`i',1] = `size'
restore

local i=`i'+1
}
}

clear 
svmat resultados

rename resultados1 sample_size
rename resultados2 st_power
rename resultados3 efecto

replace st_power=round(st_power,.01)
separate st_power, by(efecto)

* Gráfico
set scheme s1color
twoway (connected st_power1 sample_size) (connected st_power2 sample_size) ///
(connected st_power3 sample_size) (connected st_power4 sample_size) ///
(connected st_power5 sample_size), ytitle("Power") ///
xtitle("Number of observations") ///
legend(label(1 "1%") label(2 "2.5%") label(3 "5%") label(4 "7.5%") label(5 "10%")) ///
legend(rows(1) title("Effect")) xscale(titlegap(3)) yscale(titlegap(3)) 
graph export "output/Graph 1.png", replace
*==============================================================================*

********************************************************************************
* 2) Replica con varianza de u en 5000
*==============================================================================*/
* Generamos una muestra simulada con datos de pagos de impuestos de empresas

clear all
set seed 123 // seteamos semilla para poder replicar los resultados
set obs 15000
gen ganancias_estimadas = rnormal(10000,2000)
drop if ganancias_estimadas<0


gen impuestos_pagados = 0.2*ganancias_estimadas + rnormal(0,sqrt(5000))
drop if impuestos_pagados<0

gen obs=_n
pctile escuela = obs, nq(10)

* Repito la simulación pero para distintos tamaños de muestra y para distintos efectos
local i=1
mat resultados = J(50,4,.)

foreach efecto in 0.01 0.025 0.05 0.075 0.1{
forvalues size = 1000(1000)10000 {
mat R = J(500,2,.) 

forvalues x=1(1)500 {

preserve

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


mat resultados[`i',3] = `efecto'
mat resultados[`i',2] = media
mat resultados[`i',1] = `size'
restore

local i=`i'+1
}
}

clear 
svmat resultados

rename resultados1 sample_size
rename resultados2 st_power
rename resultados3 efecto

replace st_power=round(st_power,.01)
separate st_power, by(efecto)

* Gráfico
set scheme s1color
twoway (connected st_power1 sample_size) (connected st_power2 sample_size) ///
(connected st_power3 sample_size) (connected st_power4 sample_size) ///
(connected st_power5 sample_size), ytitle("Power") ///
xtitle("Number of observations") ///
legend(label(1 "1%") label(2 "2.5%") label(3 "5%") label(4 "7.5%") label(5 "10%")) ///
legend(rows(1) title("Effect")) xscale(titlegap(3)) yscale(titlegap(3)) 
graph export "output/Graph 2 (var_u 5000).png", replace
*==============================================================================*


********************************************************************************
* 3) Replica con varianza de u en 5000 (20% Tratado)
*==============================================================================*/
* Generamos una muestra simulada con datos de pagos de impuestos de empresas

clear all
set seed 123 // seteamos semilla para poder replicar los resultados
set obs 15000
gen ganancias_estimadas = rnormal(10000,2000)
drop if ganancias_estimadas<0

gen impuestos_pagados = 0.2*ganancias_estimadas + rnormal(0,sqrt(5000))
drop if impuestos_pagados<0

gen obs=_n
pctile escuela = obs, nq(10)


* Repito la simulación pero para distintos tamaños de muestra y para distintos efectos
local i=1
mat resultados = J(50,4,.)

foreach efecto in 0.01 0.025 0.05 0.075 0.1{
forvalues size = 1000(1000)10000 {
mat R = J(500,2,.) 

forvalues x=1(1)500 {

preserve

sample `size' , count

gen temp = runiform()
gen T=0
replace T = 1 if temp<0.2


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


mat resultados[`i',3] = `efecto'
mat resultados[`i',2] = media
mat resultados[`i',1] = `size'
restore

local i=`i'+1
}
}

clear 
svmat resultados

rename resultados1 sample_size
rename resultados2 st_power
rename resultados3 efecto

replace st_power=round(st_power,.01)
separate st_power, by(efecto)

* Gráfico
set scheme s1color
twoway (connected st_power1 sample_size) (connected st_power2 sample_size) ///
(connected st_power3 sample_size) (connected st_power4 sample_size) ///
(connected st_power5 sample_size), ytitle("Power") ///
xtitle("Number of observations") ///
legend(label(1 "1%") label(2 "2.5%") label(3 "5%") label(4 "7.5%") label(5 "10%")) ///
legend(rows(1) title("Effect")) xscale(titlegap(3)) yscale(titlegap(3)) 
graph export "output/Graph 3 (20 Tratado).png", replace
*==============================================================================*


********************************************************************************
* 4) Replica con varianza de u en 5000 (80% Tratado)
*==============================================================================*/
* Generamos una muestra simulada con datos de pagos de impuestos de empresas

clear all
set seed 123 // seteamos semilla para poder replicar los resultados
set obs 15000
gen ganancias_estimadas = rnormal(10000,2000)
drop if ganancias_estimadas<0
browse
gen impuestos_pagados = 0.2*ganancias_estimadas + rnormal(0,sqrt(5000))
drop if impuestos_pagados<0

gen obs=_n
pctile escuela = obs, nq(10)


* Repito la simulación pero para distintos tamaños de muestra y para distintos efectos
local i=1
mat resultados = J(50,4,.)

foreach efecto in 0.01 0.025 0.05 0.075 0.1{
forvalues size = 1000(1000)10000 {
mat R = J(500,2,.) 

forvalues x=1(1)500 {

preserve

sample `size' , count

gen temp = runiform()
gen T=0
replace T = 1 if temp<0.8


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


mat resultados[`i',3] = `efecto'
mat resultados[`i',2] = media
mat resultados[`i',1] = `size'
restore

local i=`i'+1
}
}

clear 
svmat resultados

rename resultados1 sample_size
rename resultados2 st_power
rename resultados3 efecto

replace st_power=round(st_power,.01)
separate st_power, by(efecto)

* Gráfico
set scheme s1color
twoway (connected st_power1 sample_size) (connected st_power2 sample_size) ///
(connected st_power3 sample_size) (connected st_power4 sample_size) ///
(connected st_power5 sample_size), ytitle("Power") ///
xtitle("Number of observations") ///
legend(label(1 "1%") label(2 "2.5%") label(3 "5%") label(4 "7.5%") label(5 "10%")) ///
legend(rows(1) title("Effect")) xscale(titlegap(3)) yscale(titlegap(3)) 
graph export "output/Graph 4 (80 tratado).png", replace
*==============================================================================*

********************************************************************************
* 5) Replica con varianza de u en 500 y con ganancias_estimadas_2019 como control
*==============================================================================*/
* Generamos una muestra simulada con datos de pagos de impuestos de empresas

clear all
set seed 123 // seteamos semilla para poder replicar los resultados
set obs 15000
gen ganancias_estimadas = rnormal(10000,2000)
drop if ganancias_estimadas<0

gen impuestos_pagados = 0.2*ganancias_estimadas + rnormal(0,500)
drop if impuestos_pagados<0

gen obs=_n
pctile escuela = obs, nq(10)


* Repito la simulación pero para distintos tamaños de muestra y para distintos efectos
local i=1
mat resultados = J(50,4,.)

foreach efecto in 0.01 0.025 0.05 0.075 0.1{
forvalues size = 1000(1000)10000 {
mat R = J(500,2,.) 

forvalues x=1(1)500 {

preserve

sample `size' , count

gen temp = runiform()
gen T=0
replace T = 1 if temp<0.5


replace impuestos_pagados = impuestos_pagados * (1+`efecto') if T==1

reg impuestos_pagados T ganancias_estimadas, robust

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


mat resultados[`i',3] = `efecto'
mat resultados[`i',2] = media
mat resultados[`i',1] = `size'
restore

local i=`i'+1
}
}

clear 
svmat resultados

rename resultados1 sample_size
rename resultados2 st_power
rename resultados3 efecto

replace st_power=round(st_power,.01)
separate st_power, by(efecto)

* Gráfico
set scheme s1color
twoway (connected st_power1 sample_size) (connected st_power2 sample_size) ///
(connected st_power3 sample_size) (connected st_power4 sample_size) ///
(connected st_power5 sample_size), ytitle("Power") ///
xtitle("Number of observations") ///
legend(label(1 "1%") label(2 "2.5%") label(3 "5%") label(4 "7.5%") label(5 "10%")) ///
legend(rows(1) title("Effect")) xscale(titlegap(3)) yscale(titlegap(3)) 
graph export "output/Graph 5 (con control).png", replace
*==============================================================================*

********************************************************************************
*Exportar a pdf

translate "$main/programs/PS9.do" "$documents/Apendice.pdf", translator(txt2pdf) replace
