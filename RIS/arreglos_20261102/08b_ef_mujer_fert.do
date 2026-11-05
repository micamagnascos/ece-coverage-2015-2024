* 08 EFECTO FIJO MUJER, UV FIJA (ITT) FERTILIDAD


clear all
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
* CAMBIO 1: log con nombre propio
log using "$est/log_indm_fert_20261102.txt", text replace


* CAMBIO 2: se agrega nac_acum. hijos_total no: con EF de mujer da exactamente lo mismo (hijos_pre2014 es fijo y lo absorbe el EF)
pq use rut_inn anio id_uv_2024 tuvo_hijo nac_acum hijos_pre2014 per_edad g1 muestra_t1 rel_t1 using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_fertilidad_v60.parquet", clear

* CAMBIO 3: muestra de fertilidad = mujeres de 18 a 35 en 2014 (igual que el 01)
bys rut_inn (anio): gen edad14 = per_edad[1] - (anio[1] - 2014)
keep if inrange(edad14, 18, 35)
duplicates drop rut_inn anio, force
* CAMBIO 10: submuestra segun hijos antes de 2014 (0, 1, 2 = dos o mas). Fijo por mujer: no lo cambia el jardin
gen grupo_h = min(hijos_pre2014, 2)


*UV FIJA
gen sin_uv = missing(id_uv_2024, muestra_t1)
sort rut_inn sin_uv anio
by rut_inn: gen uv_fija = id_uv_2024[1]
by rut_inn: gen g1_f = g1[1]
by rut_inn: gen muestra_f = muestra_t1[1]
by rut_inn: gen anio_ent = anio[1]
gen pre_f = (g1_f ==0 | anio_ent < g1_f)
tab muestra_f pre_f, m
keep if muestra_f == 1 & pre_f == 1
gunique uv_fija
* CAMBIO 4: guardar cuenta las UV con id_uv_2024; asi el n_uv de los coefs es el de la UV fija
replace id_uv_2024 = uv_fija


*PANEL BALANCEADO
bys rut_inn: gen n_anios = _N
gen bal = (anio_ent == 2014 & n_anios == 11)
*revisar y anotar
tab g1_f bal if anio == 2014, row


*EVENTO SEGUN FIJA
gen nunca_f = (g1_f == 0)
gen rel_f = anio - g1_f if g1_f > 0
gen rel_t1_bin = rel_f
replace rel_t1_bin = -5 if rel_f < -5
replace rel_t1_bin = -1 if missing(rel_f)
tab rel_t1_bin
tab rel_t1_bin, gen(d)
count if missing(d1)





* ESTIMACIONES
capture postclose pf
* CAMBIO 5: nombres nuevos en coefs y V, para no pisar los resultados anteriores
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_indm_e14.dta", replace


quietly sum tuvo_hijo if nunca_f == 1
local m0 = r(mean)

eventstudyinteract tuvo_hijo d1-d4 d6-d15, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14 tuvo_hijo `m0'
guardarV sa_indm_e14_tuvo_hijo

* CAMBIO 6: nombres propios del balanceado (antes pisaban a los de arriba)
quietly sum tuvo_hijo if nunca_f == 1 & bal == 1
local m0 = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if bal == 1 , cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14_bal tuvo_hijo `m0'
guardarV sa_indm_e14_bal_tuvo_hijo

* CAMBIO 7: nacimientos acumulados, completa y balanceada
quietly sum nac_acum if nunca_f == 1
local m0 = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14 nac_acum `m0'
guardarV sa_indm_e14_nac_acum

quietly sum nac_acum if nunca_f == 1 & bal == 1
local m0 = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 if bal == 1 , cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14_bal nac_acum `m0'
guardarV sa_indm_e14_bal_nac_acum


postclose pf

* CAMBIO 11: SUBMUESTRAS, con su propio archivo de coefs. Si esto no alcanza a terminar, las 4 de arriba ya quedaron guardadas
tab grupo_h
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_indm_e14_hijos.dta", replace

*Tasa de natalidad
quietly sum tuvo_hijo if nunca_f == 1 & grupo_h == 0
local m0 = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if grupo_h == 0, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14_h0 tuvo_hijo `m0'
guardarV sa_indm_e14_h0_tuvo_hijo

quietly sum tuvo_hijo if nunca_f == 1 & grupo_h == 1
local m0 = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if grupo_h == 1, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14_h1 tuvo_hijo `m0'
guardarV sa_indm_e14_h1_tuvo_hijo

quietly sum tuvo_hijo if nunca_f == 1 & grupo_h == 2
local m0 = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if grupo_h == 2, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14_h2 tuvo_hijo `m0'
guardarV sa_indm_e14_h2_tuvo_hijo

*Nacimientos acumulados
quietly sum nac_acum if nunca_f == 1 & grupo_h == 0
local m0 = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 if grupo_h == 0, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14_h0 nac_acum `m0'
guardarV sa_indm_e14_h0_nac_acum

quietly sum nac_acum if nunca_f == 1 & grupo_h == 1
local m0 = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 if grupo_h == 1, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14_h1 nac_acum `m0'
guardarV sa_indm_e14_h1_nac_acum

quietly sum nac_acum if nunca_f == 1 & grupo_h == 2
local m0 = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 if grupo_h == 2, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14_h2 nac_acum `m0'
guardarV sa_indm_e14_h2_nac_acum

postclose pf

* CAMBIO 8: export con los nombres nuevos, se borra el global extr (no se usaba)
use "$est/coefs_indm_e14.dta", clear
export delimited using "$est/coefs_indm_e14.csv", replace
use "$est/V_sa_indm_e14_tuvo_hijo.dta", clear
export delimited using "$est/V_sa_indm_e14_tuvo_hijo.csv", replace
use "$est/V_sa_indm_e14_bal_tuvo_hijo.dta", clear
export delimited using "$est/V_sa_indm_e14_bal_tuvo_hijo.csv", replace
use "$est/V_sa_indm_e14_nac_acum.dta", clear
export delimited using "$est/V_sa_indm_e14_nac_acum.csv", replace
use "$est/V_sa_indm_e14_bal_nac_acum.dta", clear
export delimited using "$est/V_sa_indm_e14_bal_nac_acum.csv", replace
* CAMBIO 12: export de las submuestras
use "$est/coefs_indm_e14_hijos.dta", clear
export delimited using "$est/coefs_indm_e14_hijos.csv", replace
use "$est/V_sa_indm_e14_h0_tuvo_hijo.dta", clear
export delimited using "$est/V_sa_indm_e14_h0_tuvo_hijo.csv", replace
use "$est/V_sa_indm_e14_h1_tuvo_hijo.dta", clear
export delimited using "$est/V_sa_indm_e14_h1_tuvo_hijo.csv", replace
use "$est/V_sa_indm_e14_h2_tuvo_hijo.dta", clear
export delimited using "$est/V_sa_indm_e14_h2_tuvo_hijo.csv", replace
use "$est/V_sa_indm_e14_h0_nac_acum.dta", clear
export delimited using "$est/V_sa_indm_e14_h0_nac_acum.csv", replace
use "$est/V_sa_indm_e14_h1_nac_acum.dta", clear
export delimited using "$est/V_sa_indm_e14_h1_nac_acum.csv", replace
use "$est/V_sa_indm_e14_h2_nac_acum.dta", clear
export delimited using "$est/V_sa_indm_e14_h2_nac_acum.csv", replace

* CAMBIO 9: graficos para mirar en la manana
grafico coefs_indm_e14 tuvo_hijo sa_indm_e14
grafico coefs_indm_e14 tuvo_hijo sa_indm_e14_bal
grafico coefs_indm_e14 nac_acum sa_indm_e14
grafico coefs_indm_e14 nac_acum sa_indm_e14_bal
* CAMBIO 13: graficos de las submuestras
grafico coefs_indm_e14_hijos tuvo_hijo sa_indm_e14_h0
grafico coefs_indm_e14_hijos tuvo_hijo sa_indm_e14_h1
grafico coefs_indm_e14_hijos tuvo_hijo sa_indm_e14_h2
grafico coefs_indm_e14_hijos nac_acum sa_indm_e14_h0
grafico coefs_indm_e14_hijos nac_acum sa_indm_e14_h1
grafico coefs_indm_e14_hijos nac_acum sa_indm_e14_h2

log close
