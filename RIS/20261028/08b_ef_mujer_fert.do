* 08 EFECTO FIJO MUJER, UV FIJA (ITT) FERTILIDAD 


clear all 
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_indm_fert_20261019.txt", text replace 


pq use rut_inn anio id_uv_2024 tuvo_hijo per_edad g1 muestra_t1 rel_t1 using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_fertilidad_v60.parquet", clear


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
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_indm_fert.dta", replace


quietly sum tuvo_hijo if nunca_f == 1 
local m0 = r(mean)

eventstudyinteract tuvo_hijo d1-d4 d6-d15, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm tuvo_hijo `m0'
guardarV sa_indm_tuvo_hijo

quietly sum tuvo_hijo if nunca_f == 1 & bal == 1 
local m0 = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if bal == 1 , cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm tuvo_hijo `m0'
guardarV sa_indm_tuvo_hijo


postclose pf 

global extr "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\02_RESULTADOS\Extracción\20261028"
use "$est/coefs_indm_fert.dta", clear
export delimited using "$est/coefs_indm_fert.csv", replace 
use "$est/V_sa_indm_tuvo_hijo.dta", clear 
export delimited using "$est/V_sa_indm_tuvo_hijo.csv", replace 
use "$est/V_sa_indm_bal_tuvo_hijo.dta", clear 
export delimited using "$est/V_sa_indm_bal_tuvo_hijo.csv", replace 

log close 






