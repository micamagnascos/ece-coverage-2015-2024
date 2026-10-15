*MODIFICACIONES MUESTRA MUJERES 
* 13/10

clear all 
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_08_20261013.txt", text replace

use "$muestra/muestra_laboral_ingresos.dta", clear

describe, fullnames 

tab calc_quintil_validacion2
tab calc_quintil_validacion2 anio, m


*CAMBIA UV 

bys rut_inn: gen tag_m = (_n == 1)
tab cambia_uv if tag_m, m

sort rut_inn anio
by rut_inn: gen mueve = (id_uv_2024 != id_uv_2024[_n-1]) if _n > 1 & anio >= 2017 & !missing(id_uv_2024) & !missing(id_uv_2024[_n-1])
bys rut_inn: egen cambia = max(mueve)
tab cambia if tag_m, m 
tab cambia_uv cambia if tag_m, m 
tab grupo_t1 mueve, row 
tab anio mueve, row 


*QUINTIL VALIDACION 
*vulnerabilidad fija por mijer, ates del keep, primer valor observado desde el 2016
tab anio calc_quintil_validacion2, m 

bys rut_inn: egen anio_v = min(cond(!missing(calc_quintil_validacion2) & anio >= 2016, anio, .))
gen v_pri = calc_quintil_validacion2 if anio == anio_v
bys rut_inn: egen vul = max(v_pri)
gen v60 = (vul <= 60) if !missing(vul)
tab anio_v v60, m 
drop anio_v v_pri 

*60% MAS VULNERABLE
bys rut_inn: gen tag_m = (_n == 1)
tab v60 if tag_m, m 
tab anio if missing(v60)
drop tag_m 


*UV FIJA 
sort rut_inn anio 
by rut_inn: gen uv_fija = id_uv_2024[1]
by rut_inn: gen g1_f = g1[1]
by rut_inn: gen muestra_f = muestra_t1[1]
by rut_inn: gen anio_ent = anio[1]
gen pre_f = (g1_f ==0 | anio[1] < g1_f) 


* MUESTRA T1
keep if muestra_t1 == 1 

*DEJAMOS A LAS MAS VULNERABLES 
keep if v60 == 1 

*OUTCOMES MUJER
egen monto_cot = rowtotal(monto_dep_anual monto_indep_anual), missing 
gen ingreso_anual = renta_imponible_anual
replace ingreso_anual =monto_cot if missing(renta_imponible_anual)
gen fuente_ing = 1 if !missing(renta_imponible_anual)
replace fuente_ing = 2 if missing(renta_imponible_anual) & !missing(monto_cot)
tab anio fuente_ing, row
gen ln_ingreso = ln(ingreso_anual) if ingreso_anual > 0
gen empleo_formal = (ingreso_anual > 0 & !missing(ingreso_anual))
gen meses_trabajando = meses_con_renta 
replace meses_trabajando = meses_cotizados_total if missing(meses_con_renta) 

gen ingreso_total = ingreso_anual 
replace ingreso_total = 0 if missing(ingreso_total)
bys anio: egen m_anio = mean(ingreso_total)
gen ingreso_rel = 100 * ingreso_total/ m_anio 

drop renta_imponible_anual monto_dep_anual monto_indep_anual meses_con_renta meses_cotizados_total monto_cot m_anio
compress 
save "$muestra/muestra_laboral_v60_ind.dta", replace 





use "$muestra/muestra_laboral_v60_ind.dta", clear

*COLAPSO A UV AÑO 
gen uno = 1
collapse (mean) ln_ingreso empleo_formal meses_trabajando ingreso_rel per_edad (sum) n_mujeres = uno n_con_ingreso = empleo_formal (firstnm) g1 grupo_t1 rel_t1, by(id_uv_2024 anio)
duplicates report id_uv_2024 anio 
count 
save "$muestra/muestra_laboral_v60_uv.dta", replace 



use "$muestra/muestra_laboral_v60_uv.dta", clear

gen nunca_tratada = (g1==0)

*DUMMIES DE EVENTO
gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 
replace rel_t1_bin = -1 if missing(rel_t1)
tab rel_t1_bin, gen(d)



* ESTIMACIONES 
capture postclose pf 
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_lab_v60.dta", replace

foreach y in empleo_formal ln_ingreso meses_trabajando ingreso_rel {

	local w n_mujeres
	if "`y'" == "ln_ingreso" | "`y'" == "meses_trabajando" local w n_con_ingreso 
	
	quietly sum `y' if nunca_tratada == 1 
	local m0= r(mean)
	quietly sum `y' if nunca_tratada == 1 [aw= `w']
	local m0w = r(mean)

	eventstudyinteract `y' d1-d4 d6-d15, cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
	guardar sa_v60 `y' `m0'
	guardarV sa_v60_`y'

	eventstudyinteract `y' d1-d4 d6-d15 [aw= `w'], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
	guardar sa_w_v60 `y' `m0w'
	guardarV sa_w_v60_`y'

}



*sin cohorte 2015 
drop if g1 == 2015 
drop d1-d15 
tab rel_t1_bin, gen(d)


foreach y in empleo_formal ln_ingreso meses_trabajando ingreso_rel {

	local w n_mujeres
	if "`y'" == "ln_ingreso" | "`y'" == "meses_trabajando" local w n_con_ingreso 
	
	quietly sum `y' if nunca_tratada == 1 
	local m0= r(mean)
	quietly sum `y' if nunca_tratada == 1 [aw= `w']
	local m0w = r(mean)

	eventstudyinteract `y' d1-d4 d6-d14, cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
	guardar sa_v60s15 `y' `m0'
	guardarV sa_v60s15_`y'

	eventstudyinteract `y' d1-d4 d6-d14 [aw= `w'], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
	guardar sa_w_v60s15 `y' `m0w'
	guardarV sa_w_v60s15_`y'

}
postclose pf 





*ESTIMACION A NIVEL INDIVIDUAL 
use "$muestra/muestra_laboral_v60_ind.dta", clear 
keep if muestra_f == 1 & pre_f == 1 
count 

gunique rut_inn
gunique uv_fija 
gen nunca_f = (g1_f == 0)
gen rel_f = anio - g1_f if g1_f > 0 

gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 
replace rel_t1_bin = -1 if missing(rel_t1)
tab rel_t1_bin, gen(d)

capture postclose pf 
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_lab_indm_v60.dta", replace

foreach y in empleo_formal ln_ingreso ingreso_rel {
	quietly sum `y' if nunca_f == 1 
	local m0= r(mean)
	
	reghdfe `y' d1-d4 d6-d15 per_edad, absorb(rut_inn anio) cluster(uv_fija)
	guardar twfe_indm `y' `m0'
	test d1 d2 d3 d4
	post pf ("pretest_indm") ("`y'") (-99) (r(p)) (.) (.) (.) (.)
	
	eventstudyinteract `y' d1-d4 d6-d15, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
	guardar sa_indm `y' `m0'
	guardarV sa_indm_`y'
}

postclose pf



*REVISAR, NIVEL UV 
use "$est/coefs_lab_v60.dta", clear
tab modelo outcome 
list modelo outcome k b se N n_uv, sepby(outcome)


*GRAFICOS PRINCIPALES 
grafico coefs_lab_v60 empleo_formal sa_w_v60
grafico coefs_lab_v60 ingreso_rel sa_w_v60
grafico coefs_lab_v60 ln_ingreso sa_w_v60


*REVISAR NIVEL IND 
use "$est/coefs_lab_ind_v60.dta", clear

grafico coefs_lab_ind_v60 empleo_formal twfe_ind
grafico coefs_lab_ind_v60 ingreso_rel twfe_ind
grafico coefs_lab_ind_v60 ln_ingreso twfe_ind

grafico coefs_lab_indm_v60 empleo_formal sa_indm
grafico coefs_lab_v60 ingreso_rel sa_ind
grafico coefs_lab_v60 ln_ingreso sa_ind


grafico coefs_lab_indm_v60 empleo_formal sa_indm
grafico coefs_lab_indm_v60 ingreso_rel sa_indm
grafico coefs_lab_indm_v60 ln_ingreso sa_indm

