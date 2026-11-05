*FERTILIDAD - MUJERES V60 18-49, CROSSWALK NUEVO
* 02/11/2026

clear all

do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
* CAMBIO 1: log con nombre propio (antes usaba el nombre del log laboral y lo pisaba)
log using "$est/log_fert_20261102.txt", text replace 


* CAMBIO 2: se agregan nac_acum, hijos_total e hijos_pre2014 (creadas en el 09)
pq use rut_inn anio id_uv_2024 tuvo_hijo nac_acum hijos_total hijos_pre2014 per_edad g1 muestra_t1 rel_t1 using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_fertilidad_v60.parquet", clear
count 
tab anio
*tab grupo_t1


* CAMBIO 3: edad en 2014, fija por mujer (profe 02/11). Se calcula con su primer anio, antes de filtrar por muestra_t1
bys rut_inn (anio): gen edad14 = per_edad[1] - (anio[1] - 2014)
* REVISAR: en la columna Cum., hasta que edad en 2014 se concentran los nacimientos (para confirmar el maximo de 35)
tab edad14 if tuvo_hijo == 1

keep if muestra_t1 == 1



* CAMBIO 4: base UV-anio solo con mujeres presentes los 11 anios dentro de la muestra de estimacion
preserve
duplicates drop rut_inn anio, force
bys rut_inn: gen n_anios_t1 = _N
bys rut_inn: gen tag_m = (_n == 1)
tab n_anios_t1 if tag_m == 1
drop tag_m
keep if n_anios_t1 == 11
gunique rut_inn
* REVISAR: edades en 2014. Para estar los 11 anios entre 18 y 49 tienen que tener 18 a 39 en 2014
sum per_edad if anio == 2014
gcollapse (mean) tuvo_hijo nac_acum hijos_total per_edad (firstnm) g1 rel_t1 (count) n_mujeres = rut_inn, by(id_uv_2024 anio)
gunique id_uv_2024
save "$muestra/muestra_fertilidad_v60_bal_uv.dta", replace
restore

* CAMBIO 5: bases UV-anio solo con mujeres de 18 a 35 en 2014 (se siguen aunque pasen de esa edad)
*Completa
preserve
keep if inrange(edad14, 18, 35)
duplicates drop rut_inn anio, force
gunique rut_inn
gcollapse (mean) tuvo_hijo nac_acum hijos_total hijos_pre2014 per_edad (firstnm) g1 rel_t1 (count) n_mujeres = rut_inn, by(id_uv_2024 anio)
gunique id_uv_2024
save "$muestra/muestra_fertilidad_edad14_uv.dta", replace
restore

*Balanceada: los 11 anios dentro de la muestra de estimacion
preserve
keep if inrange(edad14, 18, 35)
duplicates drop rut_inn anio, force
bys rut_inn: gen n_anios_t1 = _N
bys rut_inn: gen tag_m = (_n == 1)
tab n_anios_t1 if tag_m == 1
drop tag_m
keep if n_anios_t1 == 11
gunique rut_inn
gcollapse (mean) tuvo_hijo nac_acum hijos_total hijos_pre2014 per_edad (firstnm) g1 rel_t1 (count) n_mujeres = rut_inn, by(id_uv_2024 anio)
gunique id_uv_2024
save "$muestra/muestra_fertilidad_edad14_bal_uv.dta", replace
restore

* CAMBIO 13: base UV-anio por submuestra segun hijos antes de 2014 (0, 1, 2 = dos o mas). Fijo por mujer: no lo cambia el jardin
preserve
keep if inrange(edad14, 18, 35)
duplicates drop rut_inn anio, force
gen grupo_h = min(hijos_pre2014, 2)
tab grupo_h
gcollapse (mean) tuvo_hijo nac_acum per_edad (firstnm) g1 rel_t1 (count) n_mujeres = rut_inn, by(id_uv_2024 anio grupo_h)
save "$muestra/muestra_fertilidad_edad14_hijos_uv.dta", replace
restore

*COLAPSO A UV AÑO 
* CAMBIO 6: se agregan nac_acum y hijos_total, para estimarlas tambien en la muestra completa
gcollapse (mean) tuvo_hijo nac_acum hijos_total per_edad (firstnm) g1 rel_t1 (count) n_mujeres = rut_inn, by(id_uv_2024 anio)
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
* CAMBIO 7: nombres nuevos en coefs, tendencias y V, para no pisar los resultados con el crosswalk viejo
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_fert_v60cw.dta", replace

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

* CAMBIO 8: acumulados en la muestra completa. OJO: cuentan desde que la mujer entra a la muestra, comparar con el balanceado
*Nacimientos acumulados desde que entra
quietly sum nac_acum if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w nac_acum `m0w'
guardarV sa_w_cw_nac_acum

*Total de hijos (antes de 2014 + acumulados)
quietly sum hijos_total if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract hijos_total d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w hijos_total `m0w'
guardarV sa_w_cw_hijos_total

* CAMBIO 9: MUJERES BALANCEADAS. Sin per_edad: con las mismas mujeres cada anio ya la capturan los EF de UV y anio
preserve
use "$muestra/muestra_fertilidad_v60_bal_uv.dta", clear
gen nunca_tratada = (g1 == 0)
gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 
replace rel_t1_bin = -1 if missing(rel_t1)
* REVISAR: 15 filas, de -5 a 9. La fila 5 tiene que ser -1 (d5 = referencia)
tab rel_t1_bin, gen(d)

*Tasa de natalidad
quietly sum tuvo_hijo if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_bal tuvo_hijo `m0w'
guardarV sa_w_bal_tuvo_hijo

*Nacimientos acumulados desde 2014
quietly sum nac_acum if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_bal nac_acum `m0w'
guardarV sa_w_bal_nac_acum

*Total de hijos (antes de 2014 + acumulados)
quietly sum hijos_total if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract hijos_total d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_bal hijos_total `m0w'
guardarV sa_w_bal_hijos_total

restore

* CAMBIO 10: MUJERES DE 18 A 35 EN 2014. Completa con per_edad, balanceada sin per_edad
preserve
use "$muestra/muestra_fertilidad_edad14_uv.dta", clear
gen nunca_tratada = (g1 == 0)
gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 
replace rel_t1_bin = -1 if missing(rel_t1)
* REVISAR: 15 filas, de -5 a 9. La fila 5 tiene que ser -1 (d5 = referencia)
tab rel_t1_bin, gen(d)

*Tasa de natalidad
quietly sum tuvo_hijo if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14 tuvo_hijo `m0w'
guardarV sa_w_e14_tuvo_hijo

*Nacimientos acumulados
quietly sum nac_acum if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14 nac_acum `m0w'
guardarV sa_w_e14_nac_acum

*Total de hijos
quietly sum hijos_total if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract hijos_total d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14 hijos_total `m0w'
guardarV sa_w_e14_hijos_total

* CAMBIO 12: PLACEBO. Hijos nacidos antes de 2014: el jardin no puede afectarlos, tiene que dar 0. Si no, cambia la composicion de la UV
quietly sum hijos_pre2014 if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract hijos_pre2014 d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14 hijos_pre2014 `m0w'
guardarV sa_w_e14_hijos_pre2014
restore

preserve
use "$muestra/muestra_fertilidad_edad14_bal_uv.dta", clear
gen nunca_tratada = (g1 == 0)
gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 
replace rel_t1_bin = -1 if missing(rel_t1)
* REVISAR: 15 filas, de -5 a 9. La fila 5 tiene que ser -1 (d5 = referencia)
tab rel_t1_bin, gen(d)

*Tasa de natalidad
quietly sum tuvo_hijo if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_bal tuvo_hijo `m0w'
guardarV sa_w_e14_bal_tuvo_hijo

*Nacimientos acumulados
quietly sum nac_acum if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_bal nac_acum `m0w'
guardarV sa_w_e14_bal_nac_acum

*Total de hijos
quietly sum hijos_total if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract hijos_total d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_bal hijos_total `m0w'
guardarV sa_w_e14_bal_hijos_total

* CAMBIO 12: PLACEBO. Hijos nacidos antes de 2014: el jardin no puede afectarlos, tiene que dar 0. Si no, cambia la composicion de la UV
quietly sum hijos_pre2014 if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract hijos_pre2014 d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_bal hijos_pre2014 `m0w'
guardarV sa_w_e14_bal_hijos_pre2014
restore

* CAMBIO 14: SUBMUESTRAS segun hijos antes de 2014. Misma regresion, solo cambia la submuestra
preserve
use "$muestra/muestra_fertilidad_edad14_hijos_uv.dta", clear
gen nunca_tratada = (g1 == 0)
gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 
replace rel_t1_bin = -1 if missing(rel_t1)
* REVISAR: 15 filas, de -5 a 9. La fila 5 tiene que ser -1 (d5 = referencia)
tab rel_t1_bin, gen(d)

*Tasa de natalidad
quietly sum tuvo_hijo if nunca_tratada == 1 & grupo_h == 0 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if grupo_h == 0 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_h0 tuvo_hijo `m0w'
guardarV sa_w_e14_h0_tuvo_hijo

quietly sum tuvo_hijo if nunca_tratada == 1 & grupo_h == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if grupo_h == 1 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_h1 tuvo_hijo `m0w'
guardarV sa_w_e14_h1_tuvo_hijo

quietly sum tuvo_hijo if nunca_tratada == 1 & grupo_h == 2 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if grupo_h == 2 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_h2 tuvo_hijo `m0w'
guardarV sa_w_e14_h2_tuvo_hijo

*Nacimientos acumulados
quietly sum nac_acum if nunca_tratada == 1 & grupo_h == 0 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 if grupo_h == 0 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_h0 nac_acum `m0w'
guardarV sa_w_e14_h0_nac_acum

quietly sum nac_acum if nunca_tratada == 1 & grupo_h == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 if grupo_h == 1 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_h1 nac_acum `m0w'
guardarV sa_w_e14_h1_nac_acum

quietly sum nac_acum if nunca_tratada == 1 & grupo_h == 2 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract nac_acum d1-d4 d6-d15 if grupo_h == 2 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_e14_h2 nac_acum `m0w'
guardarV sa_w_e14_h2_nac_acum
restore

postclose pf 





use "$est/coefs_fert_v60cw.dta", clear 

grafico coefs_fert_v60cw tuvo_hijo sa_w
grafico coefs_fert_v60cw nac_acum sa_w
grafico coefs_fert_v60cw hijos_total sa_w
grafico coefs_fert_v60cw tuvo_hijo sa_w_bal
grafico coefs_fert_v60cw nac_acum sa_w_bal
grafico coefs_fert_v60cw hijos_total sa_w_bal
grafico coefs_fert_v60cw tuvo_hijo sa_w_e14
grafico coefs_fert_v60cw nac_acum sa_w_e14
grafico coefs_fert_v60cw hijos_total sa_w_e14
grafico coefs_fert_v60cw tuvo_hijo sa_w_e14_bal
grafico coefs_fert_v60cw nac_acum sa_w_e14_bal
grafico coefs_fert_v60cw hijos_total sa_w_e14_bal
grafico coefs_fert_v60cw hijos_pre2014 sa_w_e14
grafico coefs_fert_v60cw hijos_pre2014 sa_w_e14_bal
* CAMBIO 15: graficos de las submuestras
grafico coefs_fert_v60cw tuvo_hijo sa_w_e14_h0
grafico coefs_fert_v60cw tuvo_hijo sa_w_e14_h1
grafico coefs_fert_v60cw tuvo_hijo sa_w_e14_h2
grafico coefs_fert_v60cw nac_acum sa_w_e14_h0
grafico coefs_fert_v60cw nac_acum sa_w_e14_h1
grafico coefs_fert_v60cw nac_acum sa_w_e14_h2

* CAMBIO 11: cierra el log (antes no se cerraba)
log close











