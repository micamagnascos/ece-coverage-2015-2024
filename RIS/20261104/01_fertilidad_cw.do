*FERTILIDAD - MUESTRA CROSSWALK NUEVO 
* 02/11/2026

clear all

do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_fert_20261102.txt", text replace 


pq use rut_inn anio id_uv_2024 tuvo_hijo per_edad g1 muestra_t1 rel_t1 nac_acum hijos_total hijos_pre2014 using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_fertilidad_v60.parquet", clear
count 
tab anio
*tab grupo_t1

*edad en 2014
bys rut_inn (anio): gen edad14 = per_edad[1] - (anio[1]- 2014)
tab edad14 if tuvo_hijo == 1 


keep if muestra_t1 == 1

*MUESTRA BALANCEADA 
preserve 
duplicates drop rut_inn anio, force
bys rut_inn: gen n_anios_t1 = _N
bys rut_inn: gen tag_m = (_n == 1)
tab n_anios_t1 if tag_m == 1 
drop tag_m 
keep if n_anios_t1 == 11 
gunique rut_inn 
*revisar edades en 2014 
sum per_edad if anio == 2014 
gcollapse (mean) tuvo_hijo nac_acum hijos_total hijos_pre2014 per_edad (firstnm) g1 rel_t1 (count) n_mujeres = rut_inn, by(id_uv_2024 anio)
count 
gunique id_uv_2024 
save "$muestra/muestra_fertilidad_v60_bal_uvs.dta", replace 
restore


*base solo con mujeres de 18 a 35 en 2014 
preserve 
keep if inrange(edad14, 18, 35)
duplicates drop rut_inn anio, force 
gunique rut_inn 
gcollapse (mean)  edad14 tuvo_hijo nac_acum hijos_total hijos_pre2014 per_edad (firstnm) g1 rel_t1 (count) n_mujeres = rut_inn, by(id_uv_2024 anio)
count 
gunique id_uv_2024 
save "$muestra/muestra_fertilidad_edad14_uvs.dta", replace 
restore


*base solo con mujeres de 18 a 35 en 2014 BALANCEADA 
preserve 
keep if inrange(edad14, 18, 35)
duplicates drop rut_inn anio, force 
duplicates drop rut_inn anio, force
bys rut_inn: gen n_anios_t1 = _N
bys rut_inn: gen tag_m = (_n == 1)
tab n_anios_t1 if tag_m == 1 
drop tag_m 
keep if n_anios_t1 == 11 
gunique rut_inn 
gcollapse (mean)  edad14 tuvo_hijo nac_acum hijos_total hijos_pre2014 per_edad (firstnm) g1 rel_t1 (count) n_mujeres = rut_inn, by(id_uv_2024 anio)
count 
gunique id_uv_2024 
save "$muestra/muestra_fertilidad_edad14_bal_uvs.dta", replace 
restore


*Base por submuestras segun hijos antes 
preserve 
keep if inrange(edad14, 18, 35)
duplicates drop rut_inn anio, force 
gen grupo_h = min(hijos_pre2014, 2)
tab grupo_h
gcollapse (mean)  edad14 tuvo_hijo nac_acum hijos_total hijos_pre2014 per_edad (firstnm) g1 rel_t1 (count) n_mujeres = rut_inn, by(id_uv_2024 anio grupo_h)
count 
save "$muestra/muestra_fertilidad_edad14_hijos_uv.dta", replace 
restore

*COLAPSO A UV AÑO 
gcollapse (mean) tuvo_hijo edad14 nac_acum hijos_total hijos_pre2014 per_edad (firstnm) g1 rel_t1 (count) n_mujeres = rut_inn, by(id_uv_2024 anio)
count 
gunique id_uv_2024 
save "$muestra/muestra_fertilidad_v60_uvs.dta", replace 

gen nunca_tratada = (g1 == 0)
gunique id_uv_2024


*TENDENCIAS POR AÑO Y CHORTE
preserve 
gen nac = tuvo_hijo * n_mujeres 
gcollapse (sum) nac n_mujeres (count) n_uv = n_mujeres, by(anio g1)
save "$est/tend_fert_v60cw.dta", replace 
restore 



*DUMMIES DE EVENTO
gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 
replace rel_t1_bin = -1 if missing(rel_t1)
tab rel_t1_bin
tab rel_t1_bin, gen(d)
count if missing(d1)



* ESTIMACIONES 
capture postclose pf 
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_fert_entr_v60cw.dta", replace

quietly sum tuvo_hijo if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)

*Principal
eventstudyinteract tuvo_hijo d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w tuvo_hijo `m0w'
guardarV sa_w_cw_tuvo_hijo

*Sin 2015 
eventstudyinteract tuvo_hijo d1-d4 d6-d14 if g1 != 2015 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_s15 tuvo_hijo `m0w'
guardarV sa_w_s15_cw_tuvo_hijo


*acumulados 
quietly sum nac_acum if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w nac_acum `m0w'
guardarV sa_w_cw_nac_acum


*total hijos  
quietly sum hijos_total if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract hijos_total d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w hijos_total `m0w'
guardarV sa_w_cw_hijos_total


*BALANCEADA
preserve
use "$muestra/muestra_fertilidad_v60_bal_uvs.dta", clear
gen nunca_tratada = (g1 == 0)
gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 
replace rel_t1_bin = -1 if missing(rel_t1)
tab rel_t1_bin, gen(d)

*tasa de natalidad 
quietly sum tuvo_hijo if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada)  absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_bal tuvo_hijo `m0w'
guardarV sa_w_bal_tuvo_hijo

*nacimientos acumulados  
quietly sum nac_acum if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada)  absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_bal nac_acum `m0w'
guardarV sa_w_bal_nac_acum

*total de hijos  
quietly sum hijos_total if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract hijos_total d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada)  absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_bal hijos_total `m0w'
guardarV sa_w_bal_hijos_total

restore



*MUJERES RESTRICCION EDAD 
preserve
use "$muestra/muestra_fertilidad_edad14_uvs.dta", clear
gen nunca_tratada = (g1 == 0)
gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 
replace rel_t1_bin = -1 if missing(rel_t1)
tab rel_t1_bin, gen(d)

*tasa de natalidad 
quietly sum tuvo_hijo if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14 tuvo_hijo `m0w'
guardarV sa_w_e14_tuvo_hijo

*nacimientos acumulados  
quietly sum nac_acum if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14 nac_acum `m0w'
guardarV sa_w_e14_nac_acum

*total de hijos  
quietly sum hijos_total if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract hijos_total d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14 hijos_total `m0w'
guardarV sa_w_e14_hijos_total

*hijos pre   
quietly sum hijos_pre2014 if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract hijos_pre2014 d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14 hijos_pre2014 `m0w'
guardarV sa_w_e14_hijos_pre2014


restore


*BALANCEADA
preserve
use "$muestra/muestra_fertilidad_edad14_bal_uvs.dta", clear
gen nunca_tratada = (g1 == 0)
gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 
replace rel_t1_bin = -1 if missing(rel_t1)
tab rel_t1_bin, gen(d)

*tasa de natalidad 
quietly sum tuvo_hijo if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada)  absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_bal tuvo_hijo `m0w'
guardarV sa_w_e14_bal_tuvo_hijo

*nacimientos acumulados  
quietly sum nac_acum if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada)  absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_bal nac_acum `m0w'
guardarV sa_w_e14_bal_nac_acum

*total de hijos  
quietly sum hijos_total if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract hijos_total d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada)  absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_bal hijos_total `m0w'
guardarV sa_w_e14_bal_hijos_total

*hijos pre   
quietly sum hijos_pre2014 if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract hijos_pre2014 d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_bal hijos_pre2014 `m0w'
guardarV sa_w_e14_bal_hijos_pre2014

restore


*SUBMUESTRAS 
preserve 
use "$muestra/muestra_fertilidad_edad14_hijos_uv.dta", clear
gen nunca_tratada = (g1 == 0)
gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 
replace rel_t1_bin = -1 if missing(rel_t1)
tab rel_t1_bin, gen(d)


*tasa de natalidad 
quietly sum tuvo_hijo if nunca_tratada == 1 & grupo_h == 0 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if grupo_h == 0 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_h0 tuvo_hijo `m0w'
guardarV sa_w_e14_h0_tuvo_hijo

*tasa de natalidad 
quietly sum tuvo_hijo if nunca_tratada == 1 & grupo_h == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if grupo_h == 1 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_h1 tuvo_hijo `m0w'
guardarV sa_w_e14_h1_tuvo_hijo

*tasa de natalidad 
quietly sum tuvo_hijo if nunca_tratada == 1 & grupo_h == 2 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if grupo_h == 2 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_h2 tuvo_hijo `m0w'
guardarV sa_w_e14_h2_tuvo_hijo


*nacimientos acum
quietly sum nac_acum if nunca_tratada == 1 & grupo_h == 0 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 if grupo_h == 0 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_h0 nac_acum `m0w'
guardarV sa_w_e14_h0_nac_acum

*nacimientos acum
quietly sum nac_acum if nunca_tratada == 1 & grupo_h == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 if grupo_h == 1 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_h1 nac_acum `m0w'
guardarV sa_w_e14_h1_nac_acum

*nacimientos acum
quietly sum nac_acum if nunca_tratada == 1 & grupo_h == 2 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 if grupo_h == 2 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_h2 nac_acum `m0w'
guardarV sa_w_e14_h2_nac_acum

restore 

postclose pf 





use "$est/coefs_fert_entr_v60cw.dta", clear 

grafico coefs_fert_entr_v60cw tuvo_hijo sa_w
grafico coefs_fert_entr_v60cw nac_acum sa_w
grafico coefs_fert_entr_v60cw hijos_total sa_w


grafico coefs_fert_entr_v60cw tuvo_hijo sa_w_bal
grafico coefs_fert_entr_v60cw nac_acum sa_w_bal
grafico coefs_fert_entr_v60cw hijos_total sa_w_bal

grafico coefs_fert_entr_v60cw tuvo_hijo sa_w_e14
grafico coefs_fert_entr_v60cw nac_acum sa_w_e14
grafico coefs_fert_entr_v60cw hijos_total sa_w_e14

grafico coefs_fert_entr_v60cw tuvo_hijo sa_w_e14_bal
grafico coefs_fert_entr_v60cw nac_acum sa_w_e14_bal
grafico coefs_fert_entr_v60cw hijos_total sa_w_e14_bal

grafico coefs_fert_entr_v60cw tuvo_hijo sa_w_e14_h0
grafico coefs_fert_entr_v60cw tuvo_hijo sa_w_e14_h1
grafico coefs_fert_entr_v60cw tuvo_hijo sa_w_e14_h2
grafico coefs_fert_entr_v60cw nac_acum sa_w_e14_h0
grafico coefs_fert_entr_v60cw nac_acum sa_w_e14_h1
grafico coefs_fert_entr_v60cw nac_acum sa_w_e14_h2






