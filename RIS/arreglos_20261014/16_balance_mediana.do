*16 BALANCE 2014 CON MEDIANA -- 21/10/2026
*misma muestra que la tabla de balance (06/10). Se lee del log

clear all
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_balance_mediana_20261021.txt", text replace

*LABORAL
use "$muestra/muestra_laboral_ingresos_v2.dta", clear
keep if anio == 2014 & !missing(pob_total_uv)
gen ever_t1 = (g1 > 0)
* REVISAR: 3909 / 422
tab ever_t1
tabstat empleo_formal ingreso_anual meses_trabajando per_edad n_hijos_menor5 per_fic_horastrabajo per_fic_trabaja per_fic_tipoeducacion_id n_mujeres pob_total_uv densidad_ninos_uv, by(ever_t1) stat(p50 mean) varwidth(25)
tabstat empleo_formal ingreso_anual meses_trabajando per_edad n_hijos_menor5 per_fic_horastrabajo per_fic_trabaja per_fic_tipoeducacion_id n_mujeres pob_total_uv densidad_ninos_uv [aw = pob_total_uv], by(ever_t1) stat(p50 mean) varwidth(25)
ranksum pob_total_uv, by(ever_t1)

*FERTILIDAD
use "$muestra/muestra_fertilidad_uvs.dta", clear
keep if muestra_t1 == 1 & anio == 2014 & !missing(pob_total_uv)
gen ever_t1 = (g1 > 0)
* REVISAR: 3973 / 422
tab ever_t1
tabstat tuvo_hijo per_edad n_hijos_menor5 n_mujeres pob_total_uv densidad_ninos_uv, by(ever_t1) stat(p50 mean) varwidth(25)
tabstat tuvo_hijo per_edad n_hijos_menor5 n_mujeres pob_total_uv densidad_ninos_uv [aw = pob_total_uv], by(ever_t1) stat(p50 mean) varwidth(25)

log close
