*23 ROBUSTEZ: A. CALLAWAY-SANT'ANNA, MISMA MUESTRA   B. UV CON JARDIN EN 2014 COMO CONTROL  -- 03/11/2026
*Correr despues del 02, 01 y 03 (usa sus bases UV-anio). Solo para comparar con la principal

clear all
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_robustez_cs_20261103.txt", text replace


*A. CALLAWAY-SANT'ANNA. Control: nunca tratadas (g1 == 0). Peso fijo por UV. long2: los pre se miden contra k = -1, como en SA
*Empleo e ingreso con ceros
use "$muestra/muestra_laboral_entrada_uv.dta", clear
bys id_uv_2024: egen w_uv = mean(n_mujeres)

csdid empleo_formal [iw= w_uv], ivar(id_uv_2024) time(anio) gvar(g1) long2
estat simple
estat event, window(-5 9)
csdid_plot
graph export "$est/cs_empleo_formal.png", replace

csdid ingreso_rel [iw= w_uv], ivar(id_uv_2024) time(anio) gvar(g1) long2
estat simple
estat event, window(-5 9)
csdid_plot
graph export "$est/cs_ingreso_rel.png", replace

*Primera etapa
use "$pe/primera_etapa_panel_uv_v60.dta", clear
keep if muestra_t1 == 1
bys id_uv_2024: egen w_uv = mean(n_ninos)

csdid tasa_matricula [iw= w_uv], ivar(id_uv_2024) time(anio) gvar(g1) long2
estat simple
estat event, window(-5 9)
csdid_plot
graph export "$est/cs_tasa_matricula.png", replace

*Fertilidad, 18 a 35 en 2014
use "$muestra/muestra_fertilidad_edad14_uv.dta", clear
bys id_uv_2024: egen w_uv = mean(n_mujeres)

csdid tuvo_hijo [iw= w_uv], ivar(id_uv_2024) time(anio) gvar(g1) long2
estat simple
estat event, window(-5 9)
csdid_plot
graph export "$est/cs_tuvo_hijo.png", replace


*B. UV CON JARDIN EN 2014 COMO CONTROL (muestra_t1 == 0). Misma estimacion principal del 02, Sun-Abraham
pq use rut_inn anio id_uv_2024 g1 muestra_t1 rel_t1 per_edad renta_imponible_anual monto_dep_anual monto_indep_anual using "$muestra/muestra_laboral_ingresos_v60_entrada.parquet", clear
keep if !missing(muestra_t1)
replace g1 = 0 if muestra_t1 == 0
replace rel_t1 = . if muestra_t1 == 0

egen monto_cot = rowtotal(monto_dep_anual monto_indep_anual), missing 
gen ingreso_anual = renta_imponible_anual
replace ingreso_anual = monto_cot if missing(renta_imponible_anual)
replace ingreso_anual = renta_imponible_anual + monto_indep_anual if !missing(monto_indep_anual) & !missing(renta_imponible_anual)
gen empleo_formal = (ingreso_anual > 0 & !missing(ingreso_anual))
gen ingreso_total = ingreso_anual 
replace ingreso_total = 0 if missing(ingreso_total)
bys anio: egen m_anio = mean(ingreso_total)
gen ingreso_rel = 100 * ingreso_total / m_anio 
gen uno = 1

gcollapse (mean) empleo_formal ingreso_rel per_edad (sum) n_mujeres = uno (firstnm) g1 rel_t1, by(id_uv_2024 anio)
gen nunca_tratada = (g1 == 0)
* REVISAR: controles y tratadas. Los controles deberian subir en ~2.400 UV respecto del 02
gunique id_uv_2024 if nunca_tratada == 1
gunique id_uv_2024 if nunca_tratada == 0

gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 
replace rel_t1_bin = -1 if missing(rel_t1)
* REVISAR: 15 filas, de -5 a 9. La fila 5 tiene que ser -1 (d5 = referencia)
tab rel_t1_bin, gen(d)

capture postclose pf 
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_ctrl_stock.dta", replace

*Empleo
quietly sum empleo_formal if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract empleo_formal d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_stock empleo_formal `m0w'
guardarV sa_w_stock_empleo_formal

*Ingreso con ceros
quietly sum ingreso_rel if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract ingreso_rel d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_stock ingreso_rel `m0w'
guardarV sa_w_stock_ingreso_rel

postclose pf 

use "$est/coefs_ctrl_stock.dta", clear
export delimited using "$est/coefs_ctrl_stock.csv", replace

grafico coefs_ctrl_stock empleo_formal sa_w_stock
grafico coefs_ctrl_stock ingreso_rel sa_w_stock

log close
