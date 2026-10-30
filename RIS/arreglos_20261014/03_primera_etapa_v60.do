*03 PRIMERA ETAPA - HIJOS DE MADRES v60 -- 19/10/2026
*base del 11 (primera_etapa_panel_v60_uv.dta). Solo SA ponderado:
*A. principal   B. sin cohorte 2015   C. panel balanceado

clear all
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_pe_v60_20261019.txt", text replace

use "$pe/primera_etapa_panel_v60_uv.dta", clear
keep if muestra_t1 == 1
gen nunca_tratada = (g1 == 0)
* REVISAR: ~4.500 UVs
gunique id_uv_2024
* REVISAR: que no haya muchas UV-año con 1 o 2 niños
sum n_ninos, detail

*TENDENCIAS
preserve
gen matr = tasa_matricula * n_ninos
gcollapse (sum) matr n_ninos (count) n_uv = n_ninos, by(anio g1)
save "$est/tend_pe_v60.dta", replace
restore

*DUMMIES DE EVENTO
gen rel_t1_bin = rel_t1
replace rel_t1_bin = -5 if rel_t1 < -5
replace rel_t1_bin = -1 if missing(rel_t1)
* REVISAR: 15 filas, de -5 a 9. La fila 5 tiene que ser -1 (d5 = referencia)
tab rel_t1_bin, gen(d)

capture postclose pf
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_pe_v60.dta", replace

quietly sum tasa_matricula if nunca_tratada == 1 [aw = n_ninos]
local m0w = r(mean)

*A. PRINCIPAL
eventstudyinteract tasa_matricula d1-d4 d6-d15 [aw = n_ninos], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w tasa_matricula `m0w'
guardarV sa_w_tasa_matricula_v60

*B. SIN COHORTE 2015
* OJO: termina en d14 (no d15). k = 9 solo existe para la cohorte 2015
eventstudyinteract tasa_matricula d1-d4 d6-d14 if g1 != 2015 [aw = n_ninos], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_s15 tasa_matricula `m0w'
guardarV sa_w_s15_tasa_matricula_v60

*C. PANEL BALANCEADO: cohortes 2016-2020, k de -2 a 4 (todas las cohortes se ven en todos los k)
preserve
keep if g1 == 0 | (inrange(g1, 2016, 2020) & inrange(rel_t1, -2, 4))
* REVISAR: cada cohorte (fila) tiene que tener UVs en TODAS las columnas de -2 a 4, sin ceros
tab g1 rel_t1_bin if g1 > 0
* OJO: solo d4 (k = -2) y d6-d10 (k = 0 a 4)
eventstudyinteract tasa_matricula d4 d6-d10 [aw = n_ninos], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_bal tasa_matricula `m0w'
guardarV sa_w_bal_tasa_matricula_v60
restore

postclose pf

use "$est/coefs_pe_v60.dta", clear
list modelo k b se N n_uv if k >= -1, sepby(modelo)

*GRAFICOS (solo para mirar)
grafico coefs_pe_v60 tasa_matricula sa_w
grafico coefs_pe_v60 tasa_matricula sa_w_s15
grafico coefs_pe_v60 tasa_matricula sa_w_bal

log close
