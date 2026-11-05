*M LABORAL - MUESTRA V60 MADRES FIJAS, ENTRADA DESDE EL PRIMER AÑO EN EL RSH
* 02/11/2026

clear all

do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_lab_entrada_20261102.txt", text replace 

*BASE UV AÑO 
pq use rut_inn anio id_uv_2024 g1 muestra_t1 rel_t1 per_edad renta_imponible_anual monto_dep_anual monto_indep_anual meses_con_renta meses_cotizados_total n_hijos_menor5 per_fic_horastrabajo per_fic_tipoeducacion_id per_fic_trabaja pob_total_uv densidad_ninos_uv using "$muestra/muestra_laboral_ingresos_v60_entrada.parquet", clear

keep if muestra_t1 == 1

*años de cada mujer dentro de la muestra 
bys rut_inn: gen n_anios_t1 = _N
bys rut_inn: gen tag_m = (_n == 1)
tab n_anios_t1 if tag_m == 1

tab anio if n_anios == 3 
gen trat = (g1 > 0 & !missing(g1))
gen bal = (n_anios_t1 == 11)
tab trat bal if anio == 2024, row 
drop tag_m
drop bal 
drop trat

count 
tab anio
*tab grupo_t1

sum renta_imponible_anual 
sum monto_dep_anual
sum monto_indep_anual



*OUTCOMES NIVEL MUJER ANTES DEL COLLAPSE

*EDUCACION 
replace per_fic_tipoeducacion_id = . if per_fic_tipoeducacion_id == 99

*TRABAJO
tab per_fic_trabaja
replace per_fic_trabaja = . if per_fic_trabaja == 9 
replace per_fic_trabaja = 0 if per_fic_trabaja == 2

*MESES TRABAJANDO 
gen meses_trabajando = meses_con_renta
replace meses_trabajando = meses_cotizados_total if missing(meses_con_renta)

gen dif = renta_imponible_anual - monto_dep_anual if monto_dep_anual > 0 & !missing(monto_indep_anual) & !missing(renta_imponible_anual)
sum dif, d 
sum monto_indep_anual if !missing(dif), d 

*INGRESOS juntando las dos fuentes 
egen monto_cot = rowtotal(monto_dep_anual monto_indep_anual), missing 
gen ingreso_anual = renta_imponible_anual
replace ingreso_anual =monto_cot if missing(renta_imponible_anual)
*media del ingreso sin independiente 
sum ingreso_anual if ingreso_anual > 0
*si tiene renta, se le suma el ingreso independiente (antes se ignoraba)
replace ingreso_anual = renta_imponible_anual + monto_indep_anual if !missing(monto_indep_anual) & !missing(renta_imponible_anual)
*media del ingreso con independiente 
sum ingreso_anual if ingreso_anual > 0
count if monto_indep_anual > 0 & !missing(monto_indep_anual) & !missing(renta_imponible_anual)
gen empleo_formal = (ingreso_anual > 0 & !missing(ingreso_anual))
gen ln_ingreso = ln(ingreso_anual) if ingreso_anual > 0
sum ingreso_anual if ingreso_anual > 0, detail 


*INGRESO CON CEROS 
gen ingreso_total = ingreso_anual 
replace ingreso_total = 0 if missing(ingreso_total)
bys anio: egen m_anio = mean(ingreso_total)
gen ingreso_rel = 100 * ingreso_total/ m_anio 
gen uno = 1


*PROMEDIOS ANUALES EN PESOS 
tabstat ingreso_total, by(anio) stat(mean p50 n)
tabstat ingreso_total if ingreso_total > 0, by(anio) stat(mean p50 n)

*INGRESO EN PESOS DE 2024 POR MES 
sum ingreso_total if anio == 2024
local m24 = r(mean)
gen ingreso_mes24 = ingreso_total * `m24' / m_anio / 12 


*BASE BALANCEADA 
preserve 
keep if n_anios_t1 == 11
gunique rut_inn
gcollapse (mean) empleo_formal ln_ingreso ingreso_rel ingreso_mes24 ingreso_anual meses_trabajando per_edad n_hijos_menor5 per_fic_horastrabajo per_fic_trabaja per_fic_tipoeducacion_id (sum) n_mujeres = uno n_con_ingreso = empleo_formal (firstnm) pob_total_uv densidad_ninos_uv g1 rel_t1, by(id_uv_2024 anio)
gunique id_uv_2024 
save "$muestra/muestra_laboral_entrada_bal_uv.dta", replace 
restore



*COLAPSO A UV AÑO 
gcollapse (mean) empleo_formal ln_ingreso ingreso_rel ingreso_mes24 ingreso_anual meses_trabajando per_edad n_hijos_menor5 per_fic_horastrabajo per_fic_trabaja per_fic_tipoeducacion_id (sum) n_mujeres = uno n_con_ingreso = empleo_formal (firstnm) pob_total_uv densidad_ninos_uv g1 rel_t1, by(id_uv_2024 anio)
count 
gunique id_uv_2024 
save "$muestra/muestra_laboral_entrada_uv.dta", replace 



*TENDENCIAS POR AÑO Y CHORTE
preserve 
gen emp = empleo_formal * n_mujeres 
gcollapse (sum) emp n_mujeres (count) n_uv = n_mujeres, by(anio g1)
save "$est/tend_lab_entrada.dta", replace 
restore 


gen nunca_tratada = (g1==0)


*BALANCE 2014
gen ever_t1 = (g1>0)
global bal_ind empleo_formal ln_ingreso ingreso_anual ingreso_rel ingreso_mes24 meses_trabajando per_edad n_hijos_menor5 per_fic_horastrabajo per_fic_trabaja per_fic_tipoeducacion_id n_mujeres pob_total_uv densidad_ninos_uv
preserve 
keep if anio == 2014 & !missing(pob_total_uv)
cap postclose pb
postfile pb str32 var m0 m1 dn m0w m1w dnw using "$est/balance_lab_entrada.dta", replace 
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
tab rel_t1_bin
tab rel_t1_bin, gen(d)
count if missing(d1)



* ESTIMACIONES 
capture postclose pf 
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_lab_entrada.dta", replace

quietly sum empleo_formal if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)

*Principal
eventstudyinteract empleo_formal d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w empleo_formal `m0w'
guardarV sa_w_entr_empleo_formal

*Sin 2015 
eventstudyinteract empleo_formal d1-d4 d6-d14 if g1 != 2015 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_s15 empleo_formal `m0w'
guardarV sa_w_s15_entr_empleo_formal

*Ingreso con ceros 
quietly sum ingreso_rel if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract ingreso_rel d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w ingreso_rel `m0w'
guardarV sa_w_entr_ingreso_rel

*Ingreso con ceros sin 2015
quietly sum ingreso_rel if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract ingreso_rel d1-d4 d6-d14 if g1 != 2015 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_s15 ingreso_rel `m0w'
guardarV sa_w_s15_entr_ingreso_rel

*Ln ingreso  
quietly sum ln_ingreso if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract ln_ingreso d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w ln_ingreso `m0w'
guardarV sa_w_entr_ln_ingreso

*Ingreso con ceros en pesos 2024 por mes 
quietly sum ingreso_mes24 if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract ingreso_mes24 d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w ingreso_mes24 `m0w'
guardarV sa_w_entr_ingreso_mes24

*composiciòn 
quietly sum n_hijos_menor5 if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract n_hijos_menor5 d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w n_hijos_menor5 `m0w'
guardarV sa_w_entr_n_hijos_menor5



*PANEL BALANCEADO 
preserve 
use "$muestra/muestra_laboral_entrada_bal_uv.dta", clear
gen nunca_tratada = (g1 == 0)
gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 
replace rel_t1_bin = -1 if missing(rel_t1)
tab rel_t1_bin, gen(d)

quietly sum empleo_formal if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract empleo_formal d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_bal empleo_formal `m0w'
guardarV sa_w_bal_empleo_formal


*Ingreso con ceros 
quietly sum ingreso_rel if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract ingreso_rel d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada)  absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_bal ingreso_rel `m0w'
guardarV sa_w_bal_ingreso_rel

*Ln ingreso  
quietly sum ln_ingreso if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract ln_ingreso d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada)  absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_bal ln_ingreso `m0w'
guardarV sa_w_bal_ln_ingreso

*Ingreso con ceros en pesos 2024 por mes 
quietly sum ingreso_mes24 if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract ingreso_mes24 d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_bal ingreso_mes24 `m0w'
guardarV sa_w_bal_ingreso_mes24

restore

postclose pf 





use "$est/coefs_lab_entrada.dta", clear 

grafico coefs_lab_entrada empleo_formal sa_w
grafico coefs_lab_entrada ingreso_rel sa_w
grafico coefs_lab_entrada ln_ingreso sa_w
grafico coefs_lab_entrada ingreso_mes24 sa_w

grafico coefs_lab_entrada n_hijos_menor5 sa_w


grafico coefs_lab_entrada empleo_formal sa_w_bal
grafico coefs_lab_entrada ingreso_rel sa_w_bal
grafico coefs_lab_entrada ln_ingreso sa_w_bal
grafico coefs_lab_entrada ingreso_mes24 sa_w_bal




log close








