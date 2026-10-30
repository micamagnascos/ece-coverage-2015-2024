*15 EVENT STUDY SIN AGRUPAR LOS AÑOS PRE -- 20/10/2026
*hoy k < -5 se junta en una dummy. Aca cada k pre va por separado (de -10 a -1) para ver tendencias largas
*usa las bases UV ya colapsadas por el 03, 02 y 01 (corre rapido). Solo SA ponderado, modelo principal
*OJO: guardar no sirve aca (esta hecho para k de -5 a 9). Se guarda b y V a mano y los graficos se hacen afuera

clear all
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_sinbin_20261020.txt", text replace

*A. PRIMERA ETAPA
use "$pe/primera_etapa_panel_v60_uv.dta", clear
keep if muestra_t1 == 1
gen nunca_tratada = (g1 == 0)
gen rel = rel_t1
replace rel = -1 if missing(rel_t1)
* REVISAR: deberia ir de -10 a 9 (20 filas) y -1 en la fila 10. Si no, avisar antes de seguir
tab rel, gen(e)
* OJO: se omite e10 (k = -1)
eventstudyinteract tasa_matricula e1-e9 e11-e20 [aw = n_ninos], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
matrix list e(b_iw)
matrix b = e(b_iw)
guardarV sinbin_tasa_matricula
preserve
clear
svmat b, names(col)
save "$est/b_sinbin_tasa_matricula.dta", replace
restore

*B. EMPLEO FORMAL E INGRESO CON CEROS (base colapsada por el 02)
use "$muestra/muestra_laboral_v60fija_uv.dta", clear
gen nunca_tratada = (g1 == 0)
gen rel = rel_t1
replace rel = -1 if missing(rel_t1)
* REVISAR: 20 filas y -1 en la fila 10
tab rel, gen(e)
eventstudyinteract empleo_formal e1-e9 e11-e20 [aw = n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
matrix list e(b_iw)
matrix b = e(b_iw)
guardarV sinbin_empleo_formal
preserve
clear
svmat b, names(col)
save "$est/b_sinbin_empleo_formal.dta", replace
restore

eventstudyinteract ingreso_rel e1-e9 e11-e20 [aw = n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
matrix list e(b_iw)
matrix b = e(b_iw)
guardarV sinbin_ingreso_rel
preserve
clear
svmat b, names(col)
save "$est/b_sinbin_ingreso_rel.dta", replace
restore

*C. FERTILIDAD (base colapsada por el 01; si el 01 no ha corrido, esta parte falla)
use "$muestra/muestra_fertilidad_v60_uvs.dta", clear
gen nunca_tratada = (g1 == 0)
gen rel = rel_t1
replace rel = -1 if missing(rel_t1)
* REVISAR: 20 filas y -1 en la fila 10
tab rel, gen(e)
eventstudyinteract tuvo_hijo e1-e9 e11-e20 [aw = n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
matrix list e(b_iw)
matrix b = e(b_iw)
guardarV sinbin_tuvo_hijo
preserve
clear
svmat b, names(col)
save "$est/b_sinbin_tuvo_hijo.dta", replace
restore

log close
