* 08 EFECTO FIJO MUJER, UV FIJA (ITT) M LABORAL 


clear all 
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_indm_empleo_20261019.txt", text replace 


use rut_inn anio id_uv_2024 g1 muestra_t1 rel_t1 per_edad renta_imponible_anual monto_dep_anual monto_indep_anual using "$muestra/muestra_laboral_ingresos_v60.dta", clear

*OUTCOMES NIVEL MUJER ANTES DEL COLLAPSE

*INGRESOS juntando las dos fuentes 
egen monto_cot = rowtotal(monto_dep_anual monto_indep_anual), missing 
gen ingreso_anual = renta_imponible_anual
replace ingreso_anual =monto_cot if missing(renta_imponible_anual)
*si tiene renta, se le suma el ingreso independiente (antes se ignoraba)
replace ingreso_anual = renta_imponible_anual + monto_indep_anual if !missing(monto_indep_anual) & !missing(renta_imponible_anual)
gen empleo_formal = (ingreso_anual > 0 & !missing(ingreso_anual))
gen ln_ingreso = ln(ingreso_anual) if ingreso_anual > 0
gen ingreso_total = ingreso_anual 
replace ingreso_total = 0 if missing(ingreso_total)
sum ingreso_anual if ingreso_anual > 0, detail 


*UV FIJA 
gen sin_uv = missing(id_uv_2024, muestra_t1)
sort rut_inn sin_uv anio 
by rut_inn: gen uv_fija = id_uv_2024[1]
by rut_inn: gen g1_f = g1[1]
by rut_inn: gen muestra_f = muestra_t1[1]
by rut_inn: gen anio_ent = anio[1]
gen pre_f = (g1_f ==0 | anio_ent < g1_f) 
*revisar 
tab muestra_f pre_f, m 
keep if muestra_f == 1 & pre_f == 1
gunique uv_fija 


*PANEL BALANCEADO 
bys rut_inn: gen n_anios = _N
gen bal = (anio_ent == 2014 & n_anios == 11)
*revisar y anotar
tab g1_f bal if anio == 2014, row 
gunique uv_fija 


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
tab rel_t1_bin
tab rel_t1_bin, gen(d)
count if missing(d1)




* ESTIMACIONES 
capture postclose pf 
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_indm_empleo.dta", replace

*empleo formal 
quietly sum empleo_formal if nunca_f == 1 
local m0 = r(mean)
eventstudyinteract empleo_formal d1-d4 d6-d15, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm empleo_formal `m0'
guardarV sa_indm_empleo_formal

*ingreso con ceros 
quietly sum ingreso_rel if nunca_f == 1 
local m0 = r(mean)
eventstudyinteract ingreso_rel d1-d4 d6-d15, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm ingreso_rel `m0'
guardarV sa_indm_ingreso_rel

*ln ingreso 
quietly sum ln_ingreso if nunca_f == 1 
local m0 = r(mean)
eventstudyinteract ln_ingreso d1-d4 d6-d15, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm ln_ingreso `m0'
guardarV sa_indm_ln_ingreso

*PANEL BALANCEADO 
*empleo formal 
quietly sum empleo_formal if nunca_f == 1 & bal == 1 
local m0 = r(mean)
eventstudyinteract empleo_formal d1-d4 d6-d15 if bal == 1 , cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm empleo_formal `m0'
guardarV sa_indm_empleo_formal

*ingreso con ceros 
quietly sum ingreso_rel if nunca_f == 1 bal == 1 
local m0 = r(mean)
eventstudyinteract ingreso_rel d1-d4 d6-d15 if bal == 1, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
guardar sa_indm ingreso_rel `m0'
guardarV sa_indm_ingreso_rel

postclose pf 


global extr "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\02_RESULTADOS\Extracción\20261028"
use "$est/coefs_indm_empleo.dta", clear
export delimited using "$est/coefs_indm_empleo.csv", replace 
use "$est/V_sa_indm_empleo_formal.dta", clear 
export delimited using "$est/V_sa_indm_empleo_formal.csv", replace 
use "$est/V_sa_indm_ingreso_rel.dta", clear 
export delimited using "$est/V_sa_indm_ingreso_rel.csv", replace 
use "$est/V_sa_indm_ln_ingreso.dta", clear 
export delimited using "$est/V_sa_indm_ln_ingreso.csv", replace 
use "$est/V_sa_indm_bal_empleo_formal.dta", clear 
export delimited using "$est/V_sa_indm_bal_empleo_formal.csv", replace 
use "$est/V_sa_indm_bal_ingreso_rel.dta", clear 
export delimited using "$est/V_sa_indm_bal_ingreso_rel.csv", replace 






