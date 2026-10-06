/*===================================================================
09_merge_vecina_jardin.do

Pega vecina_jardin, vecina_abre y n_vecinas (salida de 08_vecina_jardin_uv.py)
a base_cobertura_cp.dta. Correr despues del 08.
===================================================================*/

use "data/final/base_cobertura_cp.dta", clear

capture drop vecina_jardin vecina_abre n_vecinas
merge m:1 t_id_uv_ca using "data/build/vecina_jardin_uv.dta", keep(master match)
assert _merge == 3
drop _merge

* Chequeo: nunca tratadas que quedan limpias en cada definicion
tab grupo_t1 vecina_jardin if anio == 2014   // 647 nunca tratadas con 0
tab grupo_t1 vecina_abre if anio == 2014     // 2163 nunca tratadas con 0

sort t_id_uv_ca anio
save "data/final/base_cobertura_cp.dta", replace
export excel using "data/final/base_cobertura_cp.xlsx", firstrow(variables) replace
