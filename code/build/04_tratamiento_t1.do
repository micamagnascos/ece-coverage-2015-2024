/*===================================================================
04_tratamiento_t1.do

Crea las variables del tratamiento 1 (UV pasa de 0 a >=1 jardin)
sobre base_cobertura_cp.dta. Correr despues del 03.
===================================================================*/

use "data/final/base_cobertura_cp.dta", clear

* 1. Numero de jardines de la UV en 2014, primer año del panel
*    (mismo valor todos los años)
gen aux = n_total if anio == 2014
bysort t_id_uv_ca: egen stock_base = max(aux)
drop aux

* 2. Muestra: solo UVs con 0 jardines en 2014
gen muestra_t1 = (stock_base == 0)

* 3. Año de la primera apertura (0 = nunca tratada, . = excluida)
gen aux = anio if n_total >= 1 & muestra_t1 == 1
bysort t_id_uv_ca: egen g1 = min(aux)
drop aux
replace g1 = 0 if muestra_t1 == 1 & g1 == .

* 4. Grupo de cada UV
gen grupo_t1 = 1 if muestra_t1 == 0
replace grupo_t1 = 2 if muestra_t1 == 1 & g1 == 0
replace grupo_t1 = 3 if muestra_t1 == 1 & g1 > 0
label define lgrupo 1 "Excluida" 2 "Nunca tratada" 3 "Tratada"
label values grupo_t1 lgrupo

* 5. tratada: 1 solo en el año en que aparece el jardin
drop tratada
gen tratada = (anio == g1 & g1 > 0)

* 6. post_t1: 1 desde el año de apertura en adelante
gen post_t1 = (g1 > 0 & anio >= g1)

* 7. Tiempo al evento (años desde la apertura)
gen rel_t1 = anio - g1 if g1 > 0

* Chequeos
tab grupo_t1 if anio == 2014      // 2265 / 4175 / 447
tab g1 if anio == 2014 & muestra_t1 == 1   // 2015 = 179
tab tratada                       // 447
tab rel_t1                        // de -10 a 9
assert rel_t1 == 0 if tratada == 1

sort t_id_uv_ca anio
save "data/final/base_cobertura_cp.dta", replace
export excel using "data/final/base_cobertura_cp.xlsx", firstrow(variables) replace

* Grafico: UVs tratadas por region
preserve
keep if tratada == 1
contract t_reg_nom, freq(n_tratadas)
gsort -n_tratadas

graph hbar n_tratadas, over(t_reg_nom, sort(n_tratadas) descending) ///
    title("UVs tratadas por región") ///
    ytitle("Número de UVs") ///
    blabel(bar)

graph export "output/figures/03_uv_tratadas_por_region.png", replace width(1600)
restore
