*08a EF MUJER, UV FIJA (ITT) - LABORAL, MUESTRA FIJA v60 -- 20/10/2026
*empleo formal, ingreso con ceros y ln ingreso. Cada SA demora ~20-30 min: dejar corriendo de noche
*reemplaza al 13. UV fija = primera UV valida de cada mujer (las que se mudan se quedan con esa)

clear all
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_indm_empleo_20261019.txt", text replace

use rut_inn anio id_uv_2024 g1 muestra_t1 renta_imponible_anual monto_dep_anual monto_indep_anual using "$muestra/muestra_laboral_ingresos_v60.dta", clear

*OUTCOME
egen monto_cot = rowtotal(monto_dep_anual monto_indep_anual), missing
gen ingreso_anual = renta_imponible_anual
replace ingreso_anual = monto_cot if missing(renta_imponible_anual)
* CAMBIO 1: si tiene renta, se le SUMA el ingreso independiente (antes se ignoraba; la renta no lo incluye)
replace ingreso_anual = renta_imponible_anual + monto_indep_anual if !missing(renta_imponible_anual) & !missing(monto_indep_anual)
gen empleo_formal = (ingreso_anual > 0 & !missing(ingreso_anual))
gen ln_ingreso = ln(ingreso_anual) if ingreso_anual > 0
gen ingreso_total = ingreso_anual
replace ingreso_total = 0 if missing(ingreso_total)

*UV FIJA: primer año con UV y muestra_t1 no missing (arregla los 1.634 clusters del 13)
gen sin_uv = missing(id_uv_2024, muestra_t1)
sort rut_inn sin_uv anio
by rut_inn: gen uv_fija = id_uv_2024[1]
by rut_inn: gen g1_f = g1[1]
by rut_inn: gen muestra_f = muestra_t1[1]
by rut_inn: gen anio_ent = anio[1]
gen pre_f = (g1_f == 0 | anio_ent < g1_f)
* REVISAR: muestra_f casi sin missing
tab muestra_f pre_f, m
keep if muestra_f == 1 & pre_f == 1

* CAMBIO 2: PANEL BALANCEADO = madres que entran en 2014 y estan los 11 años (2014-2024)
bys rut_inn: gen n_anios = _N
gen bal = (anio_ent == 2014 & n_anios == 11)
* REVISAR (anotar): % de balanceadas en control (g1_f == 0) y en tratadas, tiene que ser parecido
tab g1_f bal if anio == 2014, row
* REVISAR: deberian ser ~4.500 UVs (no 1.634 como en el 13)
gunique uv_fija

*INGRESO CON CEROS: % del promedio del año de las madres de la muestra (igual que el 02)
bys anio: egen m_anio = mean(ingreso_total)
gen ingreso_rel = 100 * ingreso_total / m_anio
* CAMBIO 3: promedio 2024 de ESTA muestra, para pasar ingreso_rel a pesos de 2024 al mes afuera (coef x m24 / 1200). Anotar el Mean
sum ingreso_total if anio == 2024

*EVENTO SEGUN UV FIJA
gen nunca_f = (g1_f == 0)
gen rel_f = anio - g1_f if g1_f > 0
gen rel_t1_bin = rel_f
replace rel_t1_bin = -5 if rel_f < -5
replace rel_t1_bin = -1 if missing(rel_f)
* REVISAR: 15 filas, la fila 5 tiene que ser -1
tab rel_t1_bin, gen(d)

capture postclose pf
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_indm_empleo.dta", replace

* OJO: guardar y guardarV justo despues de cada estimacion, si no se pierde todo

*A. EMPLEO FORMAL
quietly sum empleo_formal if nunca_f == 1
local m0 = r(mean)
eventstudyinteract empleo_formal d1-d4 d6-d15, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm empleo_formal `m0'
guardarV sa_indm_empleo_formal

*B. INGRESO CON CEROS
quietly sum ingreso_rel if nunca_f == 1
local m0 = r(mean)
eventstudyinteract ingreso_rel d1-d4 d6-d15, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm ingreso_rel `m0'
guardarV sa_indm_ingreso_rel

*C. LN INGRESO (solo madres con ingreso)
quietly sum ln_ingreso if nunca_f == 1
local m0 = r(mean)
eventstudyinteract ln_ingreso d1-d4 d6-d15, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm ln_ingreso `m0'
guardarV sa_indm_ln_ingreso

* CAMBIO 4: bloque nuevo. D. PANEL BALANCEADO (mismas regresiones que A y B, solo bal == 1)
quietly sum empleo_formal if nunca_f == 1 & bal == 1
local m0 = r(mean)
eventstudyinteract empleo_formal d1-d4 d6-d15 if bal == 1, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_bal empleo_formal `m0'
guardarV sa_indm_bal_empleo_formal

quietly sum ingreso_rel if nunca_f == 1 & bal == 1
local m0 = r(mean)
eventstudyinteract ingreso_rel d1-d4 d6-d15 if bal == 1, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_bal ingreso_rel `m0'
guardarV sa_indm_bal_ingreso_rel

postclose pf

* CAMBIO 5: exportar a csv a la carpeta de extraccion. OJO: reemplazar RUTA_EXTRACCION por tu carpeta
global extr "RUTA_EXTRACCION"
use "$est/coefs_indm_empleo.dta", clear
export delimited using "$extr/coefs_indm_empleo.csv", replace
use "$est/V_sa_indm_empleo_formal.dta", clear
export delimited using "$extr/V_sa_indm_empleo_formal.csv", replace
use "$est/V_sa_indm_ingreso_rel.dta", clear
export delimited using "$extr/V_sa_indm_ingreso_rel.csv", replace
use "$est/V_sa_indm_ln_ingreso.dta", clear
export delimited using "$extr/V_sa_indm_ln_ingreso.csv", replace
use "$est/V_sa_indm_bal_empleo_formal.dta", clear
export delimited using "$extr/V_sa_indm_bal_empleo_formal.csv", replace
use "$est/V_sa_indm_bal_ingreso_rel.dta", clear
export delimited using "$extr/V_sa_indm_bal_ingreso_rel.csv", replace

*GRAFICOS (solo para mirar)
grafico coefs_indm_empleo empleo_formal sa_indm
grafico coefs_indm_empleo ingreso_rel sa_indm
grafico coefs_indm_empleo ln_ingreso sa_indm

log close
* CAMBIO 6: copia el log a la carpeta de extraccion
copy "$est/log_indm_empleo_20261019.txt" "$extr/log_indm_empleo_20261019.txt", replace
