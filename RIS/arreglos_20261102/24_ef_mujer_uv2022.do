* 24 EFECTO FIJO MUJER, UV FIJA DESDE 2022 (codigo directo, sin votacion) M LABORAL
* Prueba si el error del crosswalk explica la caida respecto del efecto fijo UV. Solo empleo e ingreso con ceros

clear all
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_indm_uv22_20261104.txt", text replace

pq use rut_inn anio id_uv_2024 g1 muestra_t1 renta_imponible_anual monto_dep_anual monto_indep_anual using "$muestra/muestra_laboral_ingresos_v60_entrada.parquet", clear

*INGRESOS juntando las dos fuentes
egen monto_cot = rowtotal(monto_dep_anual monto_indep_anual), missing
gen ingreso_anual = renta_imponible_anual
replace ingreso_anual = monto_cot if missing(renta_imponible_anual)
replace ingreso_anual = renta_imponible_anual + monto_indep_anual if !missing(monto_indep_anual) & !missing(renta_imponible_anual)
gen empleo_formal = (ingreso_anual > 0 & !missing(ingreso_anual))
gen ingreso_total = ingreso_anual
replace ingreso_total = 0 if missing(ingreso_total)

*UV FIJA: primer anio valido DESDE 2022. OJO: anio_ent es su primer anio en los datos, no el de la UV
gen sin_uv = missing(id_uv_2024, muestra_t1) | anio < 2022
sort rut_inn sin_uv anio
by rut_inn: gen uv_fija = id_uv_2024[1]
by rut_inn: gen g1_f = g1[1]
* OJO: si no tiene ningun anio valido desde 2022, queda missing y sale de la muestra
by rut_inn: gen muestra_f = muestra_t1[1] if sin_uv[1] == 0
bys rut_inn: egen anio_ent = min(anio)
gen pre_f = (g1_f == 0 | anio_ent < g1_f)
*revisar
tab muestra_f pre_f, m
keep if muestra_f == 1 & pre_f == 1
gunique uv_fija
gunique rut_inn
replace id_uv_2024 = uv_fija

*INGRESO CON CEROS
bys anio: egen m_anio = mean(ingreso_total)
gen ingreso_rel = 100 * ingreso_total / m_anio
sum ingreso_total if anio == 2024

*EVENTO SEGUN FIJA
gen nunca_f = (g1_f == 0)
gen rel_f = anio - g1_f if g1_f > 0
gen rel_t1_bin = rel_f
replace rel_t1_bin = -5 if rel_f < -5
replace rel_t1_bin = -1 if missing(rel_f)
* REVISAR: 15 filas, la fila 5 tiene que ser -1
tab rel_t1_bin, gen(d)

capture postclose pf
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_indm_uv22.dta", replace

*empleo formal
quietly sum empleo_formal if nunca_f == 1
local m0 = r(mean)
eventstudyinteract empleo_formal d1-d4 d6-d15, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_uv22 empleo_formal `m0'
guardarV sa_indm_uv22_empleo_formal

*ingreso con ceros
quietly sum ingreso_rel if nunca_f == 1
local m0 = r(mean)
eventstudyinteract ingreso_rel d1-d4 d6-d15, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm_uv22 ingreso_rel `m0'
guardarV sa_indm_uv22_ingreso_rel

postclose pf

use "$est/coefs_indm_uv22.dta", clear
export delimited using "$est/coefs_indm_uv22.csv", replace

grafico coefs_indm_uv22 empleo_formal sa_indm_uv22
grafico coefs_indm_uv22 ingreso_rel sa_indm_uv22

log close
