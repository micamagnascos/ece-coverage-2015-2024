*21 LABORAL - TODAS LAS MUJERES v60 18-49 (pedido profes 22/10) -- 27/10/2026
*misma muestra que fertilidad (solo vulnerabilidad + edad fertil, sin exigir hijo <5) + rentas + cotizaciones
*LENTO (merges grandes): dejar de noche. SA ponderado: empleo formal e ingreso con ceros, principal

clear all
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_lab_todas_20261027.txt", text replace

*1. MUESTRA: mujeres v60 18-49 (= muestra de fertilidad), solo variables necesarias
* CAMBIO 3: la muestra de fertilidad ya no está -> se arma desde la muestra completa del 09 (sin per_edad)
use rut_inn anio id_uv_2024 g1 muestra_t1 rel_t1 v60 using "$muestra/muestra_completa_ruts_trat_v60.dta", clear
keep if muestra_t1 == 1 & v60 == 1
* CAMBIO 4: edad desde la base madre (solo per_edad) y mismo corte de edad que fertilidad
merge 1:1 anio rut_inn using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/fps_rsh_uv_panel_2014_2024.dta", keepusing(per_edad) keep(master match) nogen
keep if per_edad <= 49

rename anio year
merge 1:1 year rut_inn using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\rentas/rentas_rut_panelfinal.dta", keepusing(renta_imponible_anual) keep(master match) nogen
rename year anio

merge 1:1 anio rut_inn using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\cotizaciones/panel_cotizaciones_run_anio.dta", keepusing(monto_dep_anual monto_indep_anual) keep(master match) nogen

*OUTCOMES (igual que el 02)
egen monto_cot = rowtotal(monto_dep_anual monto_indep_anual), missing
gen ingreso_anual = renta_imponible_anual
replace ingreso_anual = monto_cot if missing(renta_imponible_anual)
* CAMBIO 1: si tiene renta, se le SUMA el ingreso independiente (antes se ignoraba; la renta no lo incluye)
replace ingreso_anual = renta_imponible_anual + monto_indep_anual if !missing(renta_imponible_anual) & !missing(monto_indep_anual)
gen empleo_formal = (ingreso_anual > 0 & !missing(ingreso_anual))
gen ingreso_total = ingreso_anual
replace ingreso_total = 0 if missing(ingreso_total)
* CAMBIO 2: anotar la media 2024 (para pasar ingreso_rel a pesos acá afuera)
sum ingreso_total if anio == 2024
bys anio: egen m_anio = mean(ingreso_total)
gen ingreso_rel = 100 * ingreso_total / m_anio
gen uno = 1

*COLAPSO A UV-AÑO
gcollapse (mean) empleo_formal ingreso_rel per_edad (sum) n_mujeres = uno (firstnm) g1 rel_t1, by(id_uv_2024 anio)
gunique id_uv_2024
save "$muestra/muestra_laboral_todas_uv.dta", replace

gen nunca_tratada = (g1 == 0)

*DUMMIES DE EVENTO
gen rel_t1_bin = rel_t1
replace rel_t1_bin = -5 if rel_t1 < -5
replace rel_t1_bin = -1 if missing(rel_t1)
* REVISAR: 15 filas, la fila 5 tiene que ser -1
tab rel_t1_bin, gen(d)

capture postclose pf
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_lab_todas.dta", replace

*A. EMPLEO FORMAL
quietly sum empleo_formal if nunca_tratada == 1 [aw = n_mujeres]
local m0w = r(mean)
eventstudyinteract empleo_formal d1-d4 d6-d15 [aw = n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w empleo_formal `m0w'
guardarV sa_w_todas_empleo_formal

*B. INGRESO CON CEROS
quietly sum ingreso_rel if nunca_tratada == 1 [aw = n_mujeres]
local m0w = r(mean)
eventstudyinteract ingreso_rel d1-d4 d6-d15 [aw = n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w ingreso_rel `m0w'
guardarV sa_w_todas_ingreso_rel

postclose pf

use "$est/coefs_lab_todas.dta", clear
list modelo outcome k b se N n_uv if k >= -1, sepby(outcome)

log close
