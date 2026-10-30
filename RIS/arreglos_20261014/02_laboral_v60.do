*02 LABORAL - MUESTRA FIJA v60 -- 19/10/2026
*madres v60 desde el primer año con hijo <5 hasta 2024 (base del 09 corregido)
*SA ponderado. Empleo formal: principal y sin 2015. Ingreso con ceros: principal y sin 2015. ln ingreso: principal

clear all
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_lab_v60fija_20261019.txt", text replace

*solo las variables necesarias (la base es muy pesada)
* (YA ESTA EN EL RIS) se cargan tambien las variables del balance
use rut_inn anio id_uv_2024 g1 muestra_t1 rel_t1 per_edad renta_imponible_anual monto_dep_anual monto_indep_anual meses_con_renta meses_cotizados_total n_hijos_menor5 per_fic_horastrabajo per_fic_trabaja per_fic_tipoeducacion_id pob_total_uv densidad_ninos_uv using "$muestra/muestra_laboral_ingresos_v60.dta", clear
keep if muestra_t1 == 1
* REVISAR: con la muestra fija las madres se acumulan, deberia crecer año a año
tab anio

egen monto_cot = rowtotal(monto_dep_anual monto_indep_anual), missing
gen ingreso_anual = renta_imponible_anual
replace ingreso_anual = monto_cot if missing(renta_imponible_anual)
* CAMBIO 1: si tiene renta, se le SUMA el ingreso independiente (antes se ignoraba; la renta no lo incluye)
replace ingreso_anual = renta_imponible_anual + monto_indep_anual if !missing(renta_imponible_anual) & !missing(monto_indep_anual)
gen empleo_formal = (ingreso_anual > 0 & !missing(ingreso_anual))
gen ln_ingreso = ln(ingreso_anual) if ingreso_anual > 0

* (YA ESTA EN EL RIS) meses trabajados y limpieza de controles para el balance
gen meses_trabajando = meses_con_renta
replace meses_trabajando = meses_cotizados_total if missing(meses_con_renta)
replace per_fic_tipoeducacion_id = . if per_fic_tipoeducacion_id == 99
replace per_fic_trabaja = . if per_fic_trabaja == 9
replace per_fic_trabaja = 0 if per_fic_trabaja == 2

*INGRESO CON CEROS: % del promedio del año de TODAS las madres (igual que el 07)
gen ingreso_total = ingreso_anual
replace ingreso_total = 0 if missing(ingreso_total)
bys anio: egen m_anio = mean(ingreso_total)
gen ingreso_rel = 100 * ingreso_total / m_anio
gen uno = 1

* CAMBIO 2: promedios anuales en pesos (anotar o extraer del log: todas las madres y solo con ingreso)
tabstat ingreso_total, by(anio) stat(mean p50 n)
tabstat ingreso_total if ingreso_total > 0, by(anio) stat(mean p50 n)

* CAMBIO 3: ingreso en PESOS DE 2024 POR MES (= ingreso_rel llevado a la escala del promedio 2024)
sum ingreso_total if anio == 2024
local m24 = r(mean)
gen ingreso_mes24 = ingreso_total * `m24' / m_anio / 12

*COLAPSO A UV-AÑO
* OJO: n_con_ingreso = n° de madres con ingreso (peso para ln_ingreso)
* CAMBIO 4: se agrega ingreso_mes24 al (mean)
gcollapse (mean) empleo_formal ln_ingreso ingreso_rel ingreso_mes24 ingreso_anual meses_trabajando per_edad n_hijos_menor5 per_fic_horastrabajo per_fic_trabaja per_fic_tipoeducacion_id (sum) n_mujeres = uno n_con_ingreso = empleo_formal (firstnm) pob_total_uv densidad_ninos_uv g1 rel_t1, by(id_uv_2024 anio)
gunique id_uv_2024
* se guarda para no volver a colapsar si hay que re-estimar
save "$muestra/muestra_laboral_v60fija_uv.dta", replace

*TENDENCIAS
preserve
gen emp = empleo_formal * n_mujeres
gcollapse (sum) emp n_mujeres (count) n_uv = n_mujeres, by(anio g1)
save "$est/tend_lab_v60fija.dta", replace
restore

gen nunca_tratada = (g1 == 0)

*BALANCE 2014 (YA ESTA EN EL RIS)
gen ever_t1 = (g1 > 0)
* CAMBIO 5: se agregan ingreso_rel e ingreso_mes24 a la lista del balance
global bal_ind empleo_formal ln_ingreso ingreso_anual ingreso_rel ingreso_mes24 meses_trabajando per_edad n_hijos_menor5 per_fic_horastrabajo per_fic_trabaja per_fic_tipoeducacion_id n_mujeres pob_total_uv densidad_ninos_uv
preserve
keep if anio == 2014 & !missing(pob_total_uv)
cap postclose pb
postfile pb str32 var m0 m1 dn m0w m1w dnw using "$est/balance_lab_v60fija.dta", replace
foreach v of global bal_ind {
	balance `v'
}
count if ever_t1 == 0
local n0 = r(N)
count if ever_t1 == 1
post pb ("N_uv") (`n0') (r(N)) (.) (.) (.) (.)
postclose pb
restore

*DUMMIES DE EVENTO
gen rel_t1_bin = rel_t1
replace rel_t1_bin = -5 if rel_t1 < -5
replace rel_t1_bin = -1 if missing(rel_t1)
* REVISAR: 15 filas, la fila 5 tiene que ser -1
tab rel_t1_bin, gen(d)

capture postclose pf
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_lab_v60fija.dta", replace

quietly sum empleo_formal if nunca_tratada == 1 [aw = n_mujeres]
local m0w = r(mean)

*A. PRINCIPAL
eventstudyinteract empleo_formal d1-d4 d6-d15 [aw = n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w empleo_formal `m0w'
guardarV sa_w_fija_empleo_formal

*B. SIN COHORTE 2015
* OJO: termina en d14 (no d15)
eventstudyinteract empleo_formal d1-d4 d6-d14 if g1 != 2015 [aw = n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_s15 empleo_formal `m0w'
guardarV sa_w_s15_fija_empleo_formal

*C. INGRESO CON CEROS (peso = todas las madres)
quietly sum ingreso_rel if nunca_tratada == 1 [aw = n_mujeres]
local m0w = r(mean)
eventstudyinteract ingreso_rel d1-d4 d6-d15 [aw = n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w ingreso_rel `m0w'
guardarV sa_w_fija_ingreso_rel

* OJO: termina en d14 (no d15)
eventstudyinteract ingreso_rel d1-d4 d6-d14 if g1 != 2015 [aw = n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_s15 ingreso_rel `m0w'
guardarV sa_w_s15_fija_ingreso_rel

*D. LN INGRESO (solo madres con ingreso: peso = n_con_ingreso)
quietly sum ln_ingreso if nunca_tratada == 1 [aw = n_con_ingreso]
local m0w = r(mean)
eventstudyinteract ln_ingreso d1-d4 d6-d15 [aw = n_con_ingreso], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w ln_ingreso `m0w'
guardarV sa_w_fija_ln_ingreso

* CAMBIO 6: bloque nuevo. E. INGRESO CON CEROS EN PESOS 2024 POR MES (el coeficiente se lee en pesos)
quietly sum ingreso_mes24 if nunca_tratada == 1 [aw = n_mujeres]
local m0w = r(mean)
eventstudyinteract ingreso_mes24 d1-d4 d6-d15 [aw = n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w ingreso_mes24 `m0w'
guardarV sa_w_fija_ingreso_mes24

postclose pf

use "$est/coefs_lab_v60fija.dta", clear
list modelo outcome k b se N n_uv if k >= -1, sepby(outcome modelo)

*GRAFICOS (solo para mirar)
grafico coefs_lab_v60fija empleo_formal sa_w
grafico coefs_lab_v60fija empleo_formal sa_w_s15
grafico coefs_lab_v60fija ingreso_rel sa_w
grafico coefs_lab_v60fija ingreso_rel sa_w_s15
grafico coefs_lab_v60fija ln_ingreso sa_w
* CAMBIO 7: grafico del ingreso en pesos 2024 por mes
grafico coefs_lab_v60fija ingreso_mes24 sa_w

log close
