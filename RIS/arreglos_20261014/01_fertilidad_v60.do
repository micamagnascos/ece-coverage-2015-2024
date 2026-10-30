*01 FERTILIDAD - MUJERES v60 18-49 -- 19/10/2026
*mujeres v60 18-49 (base del 09), se colapsa aca a UV-año (igual que el 02 laboral)
*SA ponderado: A. principal   B. sin cohorte 2015

clear all
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_fert_v60_20261019.txt", text replace

*solo las variables necesarias (la base es muy pesada)
use id_uv_2024 anio rut_inn tuvo_hijo per_edad g1 muestra_t1 rel_t1 using "$muestra/muestra_fertilidad_v60.dta", clear
keep if muestra_t1 == 1

*COLAPSO A UV-AÑO
gcollapse (mean) tuvo_hijo per_edad (firstnm) g1 rel_t1 (count) n_mujeres = rut_inn, by(id_uv_2024 anio)
* se guarda para no volver a colapsar si hay que re-estimar
save "$muestra/muestra_fertilidad_v60_uvs.dta", replace

gen nunca_tratada = (g1 == 0)
gunique id_uv_2024

*TENDENCIAS
preserve
gen nac = tuvo_hijo * n_mujeres
gcollapse (sum) nac n_mujeres (count) n_uv = n_mujeres, by(anio g1)
save "$est/tend_fert_v60.dta", replace
restore

*DUMMIES DE EVENTO
gen rel_t1_bin = rel_t1
replace rel_t1_bin = -5 if rel_t1 < -5
replace rel_t1_bin = -1 if missing(rel_t1)
* REVISAR: 15 filas, la fila 5 tiene que ser -1
tab rel_t1_bin, gen(d)

capture postclose pf
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_fert_v60.dta", replace

quietly sum tuvo_hijo if nunca_tratada == 1 [aw = n_mujeres]
local m0w = r(mean)

*A. PRINCIPAL
eventstudyinteract tuvo_hijo d1-d4 d6-d15 [aw = n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w tuvo_hijo `m0w'
guardarV sa_w_v60_tuvo_hijo

*B. SIN COHORTE 2015
* OJO: termina en d14 (no d15)
eventstudyinteract tuvo_hijo d1-d4 d6-d14 if g1 != 2015 [aw = n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_s15 tuvo_hijo `m0w'
guardarV sa_w_s15_v60_tuvo_hijo

postclose pf

use "$est/coefs_fert_v60.dta", clear
list modelo k b se N n_uv if k >= -1, sepby(modelo)

*GRAFICOS (solo para mirar)
grafico coefs_fert_v60 tuvo_hijo sa_w
grafico coefs_fert_v60 tuvo_hijo sa_w_s15

log close
