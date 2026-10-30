*08b EF MUJER, UV FIJA (ITT) - FERTILIDAD, MUJERES v60 18-49 -- 19/10/2026
*misma logica que el 08a, cambia la base y el outcome (tuvo_hijo)

clear all
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_indm_fert_20261019.txt", text replace

use rut_inn anio id_uv_2024 g1 muestra_t1 tuvo_hijo using "$muestra/muestra_fertilidad_v60.dta", clear

*UV FIJA: primer año con UV y muestra_t1 no missing
gen sin_uv = missing(id_uv_2024, muestra_t1)
sort rut_inn sin_uv anio
by rut_inn: gen uv_fija = id_uv_2024[1]
by rut_inn: gen g1_f = g1[1]
by rut_inn: gen muestra_f = muestra_t1[1]
by rut_inn: gen anio_ent = anio[1]
gen pre_f = (g1_f == 0 | anio_ent < g1_f)
tab muestra_f pre_f, m
keep if muestra_f == 1 & pre_f == 1
gunique uv_fija

* CAMBIO 1: PANEL BALANCEADO = mujeres que entran en 2014 y estan los 11 años (2014-2024), o sea 18-38 en 2014
bys rut_inn: gen n_anios = _N
gen bal = (anio_ent == 2014 & n_anios == 11)
* REVISAR (anotar): % de balanceadas en control (g1_f == 0) y en tratadas, tiene que ser parecido
tab g1_f bal if anio == 2014, row

*EVENTO SEGUN UV FIJA
gen nunca_f = (g1_f == 0)
gen rel_f = anio - g1_f if g1_f > 0
gen rel_t1_bin = rel_f
replace rel_t1_bin = -5 if rel_f < -5
replace rel_t1_bin = -1 if missing(rel_f)
* REVISAR: 15 filas, la fila 5 tiene que ser -1
tab rel_t1_bin, gen(d)

capture postclose pf
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_indm_fert.dta", replace

quietly sum tuvo_hijo if nunca_f == 1
local m0 = r(mean)

eventstudyinteract tuvo_hijo d1-d4 d6-d15, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
* OJO: guardar y guardarV justo despues, si no se pierde todo
guardar sa_indm tuvo_hijo `m0'
guardarV sa_indm_tuvo_hijo

* CAMBIO 2: bloque nuevo. PANEL BALANCEADO (misma regresion, solo bal == 1)
quietly sum tuvo_hijo if nunca_f == 1 & bal == 1
local m0 = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if bal == 1, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_bal tuvo_hijo `m0'
guardarV sa_indm_bal_tuvo_hijo

postclose pf

* CAMBIO 3: exportar a csv a la carpeta de extraccion. OJO: reemplazar RUTA_EXTRACCION por tu carpeta
global extr "RUTA_EXTRACCION"
use "$est/coefs_indm_fert.dta", clear
export delimited using "$extr/coefs_indm_fert.csv", replace
use "$est/V_sa_indm_tuvo_hijo.dta", clear
export delimited using "$extr/V_sa_indm_tuvo_hijo.csv", replace
use "$est/V_sa_indm_bal_tuvo_hijo.dta", clear
export delimited using "$extr/V_sa_indm_bal_tuvo_hijo.csv", replace

*GRAFICOS (solo para mirar)
grafico coefs_indm_fert tuvo_hijo sa_indm

log close
* CAMBIO 4: copia el log a la carpeta de extraccion
copy "$est/log_indm_fert_20261019.txt" "$extr/log_indm_fert_20261019.txt", replace
