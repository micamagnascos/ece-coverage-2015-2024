*03b PRIMERA ETAPA - HIJOS DE MADRES NO VULNERABLES (40%) -- 19/10/2026
*ROBUSTEZ (pedido profes): deberia dar ~0
*SOLO CORRER SI primera_etapa_panel.dta NO fue sobrescrito (chequeo del lunes)

clear all
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_pe_nov60_20261019.txt", text replace

*v60 de cada mujer (una fila por mujer)
use rut_inn v60 using "$muestra/muestra_completa_ruts_trat_v60.dta", clear
gduplicates drop rut_inn, force
save "$muestra/v60_por_mujer.dta", replace

*panel de niños COMPLETO (niño-año) + v60 de la madre
use rut_inn run_alu_inn anio matriculado g1 rel_t1 muestra_t1 id_uv_2024 using "$pe/primera_etapa_panel.dta", clear
merge m:1 rut_inn using "$muestra/v60_por_mujer.dta", keep(master match)
* REVISAR: v60 = 0 deberia ser ~1/3 de los niños
tab v60, m
keep if v60 == 0 & muestra_t1 == 1

*COLAPSO A UV-AÑO (igual que el 11)
gcollapse (mean) tasa_matricula = matriculado (count) n_ninos = matriculado (firstnm) g1 rel_t1, by(id_uv_2024 anio)
gen nunca_tratada = (g1 == 0)
gunique id_uv_2024
sum n_ninos, detail

*DUMMIES DE EVENTO
gen rel_t1_bin = rel_t1
replace rel_t1_bin = -5 if rel_t1 < -5
replace rel_t1_bin = -1 if missing(rel_t1)
* REVISAR: 15 filas, la fila 5 tiene que ser -1
tab rel_t1_bin, gen(d)

capture postclose pf
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_pe_nov60.dta", replace

quietly sum tasa_matricula if nunca_tratada == 1 [aw = n_ninos]
local m0w = r(mean)

eventstudyinteract tasa_matricula d1-d4 d6-d15 [aw = n_ninos], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_nov60 tasa_matricula `m0w'
guardarV sa_w_tasa_matricula_nov60

postclose pf

log close
