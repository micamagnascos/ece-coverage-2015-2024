* 08 EFECTO FIJO MUJER, UV FIJA (ITT) FERTILIDAD 


clear all 
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_indm_fert_20261102.txt", text replace 


pq use rut_inn anio id_uv_2024 tuvo_hijo nac_acum hijos_pre2014 per_edad g1 muestra_t1 rel_t1 using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_fertilidad_v60.parquet", clear


*dejamos la muestra buena 
bys rut_inn (anio): gen edad14 = per_edad[1] - (anio[1]-2014)
keep if inrange(edad14, 18, 35)
duplicates drop rut_inn anio, force 
*submuestra segun hijos antes de 2014
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
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_indm_e14.dta", replace


*tasa de natalidad 
quietly sum tuvo_hijo if nunca_f == 1 
local m0 = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14 tuvo_hijo `m0'
guardarV sa_indm_e14_tuvo_hijo

*tasa de natalidad balanceado 
quietly sum tuvo_hijo if nunca_f == 1 & bal == 1 
local m0 = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if bal == 1 , cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14 bal_tuvo_hijo `m0'
guardarV sa_indm_e14_bal_tuvo_hijo

*nacimientos acumulados 
quietly sum nac_acum if nunca_f == 1
local m0 = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14 nac_acum `m0'
guardarV sa_indm_e14_nac_acum

*nacimientos acumulados balanceado
quietly sum nac_acum if nunca_f == 1 & bal == 1 
local m0 = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 if bal == 1 , cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14 bal_nac_acum `m0'
guardarV sa_indm_e14_bal_nac_acum


postclose pf 



*SUBMUESTRAS 
tab grupo_h 
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_indm_e14_hijos.dta", replace

*tasa de natalidad 
quietly sum tuvo_hijo if nunca_f == 1 & grupo_h == 0 
local m0 = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if grupo_h == 0, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14_h0 tuvo_hijo `m0'
guardarV sa_indm_e14_h0_tuvo_hijo

*tasa de natalidad 
quietly sum tuvo_hijo if nunca_f == 1 & grupo_h == 1 
local m0 = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if grupo_h == 1, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14_h1 tuvo_hijo `m0'
guardarV sa_indm_e14_h1_tuvo_hijo

*tasa de natalidad 
quietly sum tuvo_hijo if nunca_f == 1 & grupo_h == 2
local m0 = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if grupo_h == 2, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14_h2 tuvo_hijo `m0'
guardarV sa_indm_e14_h2_tuvo_hijo



*nacimientos acum  
quietly sum tuvo_hijo if nunca_f == 1 & grupo_h == 0
local m0 = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 if grupo_h == 0, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14_h0 nac_acum `m0'
guardarV sa_indm_e14_h0_nac_acum

*nacimientos acum  
quietly sum tuvo_hijo if nunca_f == 1 & grupo_h == 1
local m0 = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 if grupo_h == 0, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14_h1 nac_acum `m0'
guardarV sa_indm_e14_h1_nac_acum

*nacimientos acum  
quietly sum tuvo_hijo if nunca_f == 1 & grupo_h == 2
local m0 = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 if grupo_h == 0, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_e14_h2 nac_acum `m0'
guardarV sa_indm_e14_h2_nac_acum


postclose pf 


log close 






