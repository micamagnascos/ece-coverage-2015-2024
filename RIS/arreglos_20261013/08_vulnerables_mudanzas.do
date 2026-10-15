*08 MUJERES: MUDANZAS, 60% MAS VULNERABLE, ESTIMACION UV E INDIVIDUAL -- 13/10/2026
* abre muestra_laboral_ingresos UNA vez. Solo usa programas del 00_setup (guardar, guardarV)
* guarda: muestra_laboral_v60_ind, muestra_laboral_v60_uv, coefs_lab_v60, coefs_lab_ind_v60, V_*
* Cambios: agrega UV fija (3b) y estimacion con EF de mujer (7b) -> coefs_lab_indm_v60. Buscar CAMBIO

clear all
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_08_20261013.txt", text replace


*1. ABRIR (solo variables necesarias) + DESCRIPTIVOS BASE COMPLETA
use rut_inn anio id_uv_2024 g1 grupo_t1 muestra_t1 rel_t1 renta_imponible_anual monto_dep_anual monto_indep_anual meses_con_renta meses_cotizados_total per_edad calc_quintil_validacion2 cambia_uv using "$muestra/muestra_laboral_ingresos.dta", clear
count
gunique rut_inn
gunique id_uv_2024


*2. MUDANZAS
* cambia_uv (ya en la base): 1 si la mujer aparece en mas de una uv_rsh en el panel RSH 2016-2024
* cambia: cambio de id_uv_2024 entre años de la muestra, desde 2017 (2014-15 tienen la UV de 2016)
bys rut_inn: gen tag_m = (_n == 1)
tab cambia_uv if tag_m, m

sort rut_inn anio
by rut_inn: gen mueve = (id_uv_2024 != id_uv_2024[_n-1]) if _n > 1 & anio >= 2017 & !missing(id_uv_2024) & !missing(id_uv_2024[_n-1])
bys rut_inn: egen cambia = max(mueve)
tab cambia if tag_m, m
tab cambia_uv cambia if tag_m, m
tab anio mueve, row
tab grupo_t1 mueve, row
drop mueve cambia tag_m


*3. VULNERABILIDAD FIJA POR MUJER (antes del keep: primer valor RSH observado desde 2016)
* 2014-2015 se ignoran (no esta puntaje FPS en esta base)
tab anio calc_quintil_validacion2, m
bys rut_inn: egen anio_v = min(cond(!missing(calc_quintil_validacion2) & anio >= 2016, anio, .))
gen v_pri = calc_quintil_validacion2 if anio == anio_v
bys rut_inn: egen vul = max(v_pri)
gen v60 = (vul <= 60) if !missing(vul)
tab anio_v v60, m
drop anio_v v_pri

bys rut_inn: gen tag_m = (_n == 1)
tab v60 if tag_m, m
drop tag_m


*3b. UV FIJA (antes del keep): la UV del primer año en que aparece la mujer. El tratamiento la sigue aunque se mude  // CAMBIO 1
bys rut_inn (anio): gen uv_fija = id_uv_2024[1]  // CAMBIO 1
by rut_inn: gen g1_f = g1[1]  // CAMBIO 1
by rut_inn: gen muestra_f = muestra_t1[1]  // CAMBIO 1
by rut_inn: gen pre_f = (g1_f == 0 | anio[1] < g1_f)  // CAMBIO 1: 1 = entro antes de la apertura (o UV nunca tratada)


*4. MUESTRA T1 Y 60% MAS VULNERABLE + DESCRIPTIVOS
keep if muestra_t1 == 1
count
gunique rut_inn
gunique id_uv_2024

keep if v60 == 1
count
gunique rut_inn
gunique id_uv_2024

*años por mujer en el panel
bys rut_inn: gen n_anios = _N
bys rut_inn: gen tag_m = (_n == 1)
tab n_anios if tag_m
drop n_anios tag_m


*5. OUTCOMES NIVEL MUJER (igual que 02 + ingreso_rel de 07) Y GUARDAR BASE INDIVIDUAL
egen monto_cot = rowtotal(monto_dep_anual monto_indep_anual), missing
gen ingreso_anual = renta_imponible_anual
replace ingreso_anual = monto_cot if missing(renta_imponible_anual)
gen ln_ingreso = ln(ingreso_anual) if ingreso_anual > 0
gen empleo_formal = (ingreso_anual > 0 & !missing(ingreso_anual))
gen meses_trabajando = meses_con_renta
replace meses_trabajando = meses_cotizados_total if missing(meses_con_renta)

gen ingreso_total = ingreso_anual
replace ingreso_total = 0 if missing(ingreso_total)
bys anio: egen m_anio = mean(ingreso_total)
gen ingreso_rel = 100 * ingreso_total / m_anio

drop renta_imponible_anual monto_dep_anual monto_indep_anual meses_con_renta meses_cotizados_total monto_cot m_anio
compress
save "$muestra/muestra_laboral_v60_ind.dta", replace


*6. COLAPSO UV-AÑO, GUARDAR Y ESTIMAR SA (sin ponderar y ponderado, con las 2 V)
gen uno = 1
gcollapse (mean) empleo_formal ln_ingreso meses_trabajando ingreso_rel per_edad (sum) n_mujeres = uno n_con_ingreso = empleo_formal (firstnm) g1 grupo_t1 rel_t1, by(id_uv_2024 anio)
gduplicates report id_uv_2024 anio
save "$muestra/muestra_laboral_v60_uv.dta", replace

gen nunca_tratada = (g1 == 0)
gen rel_t1_bin = rel_t1
replace rel_t1_bin = -5 if rel_t1 < -5
replace rel_t1_bin = -1 if missing(rel_t1)
tab rel_t1_bin, gen(d)

capture postclose pf
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_lab_v60.dta", replace

foreach y in empleo_formal ln_ingreso meses_trabajando ingreso_rel {
	local w n_mujeres
	if "`y'" == "ln_ingreso" | "`y'" == "meses_trabajando" local w n_con_ingreso
	quietly sum `y' if nunca_tratada == 1
	local m0 = r(mean)
	quietly sum `y' if nunca_tratada == 1 [aw = `w']
	local m0w = r(mean)

	eventstudyinteract `y' d1-d4 d6-d15, cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
	guardar sa_v60 `y' `m0'
	guardarV sa_v60_`y'

	eventstudyinteract `y' d1-d4 d6-d15 [aw = `w'], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
	guardar sa_w_v60 `y' `m0w'
	guardarV sa_w_v60_`y'
}

*sin cohorte 2015 (k llega hasta 8 -> d14). Mismo loop: cambia d15 -> d14 y v60 -> v60s15
drop if g1 == 2015
drop d1-d15
tab rel_t1_bin, gen(d)

foreach y in empleo_formal ln_ingreso meses_trabajando ingreso_rel {
	local w n_mujeres
	if "`y'" == "ln_ingreso" | "`y'" == "meses_trabajando" local w n_con_ingreso
	quietly sum `y' if nunca_tratada == 1
	local m0 = r(mean)
	quietly sum `y' if nunca_tratada == 1 [aw = `w']
	local m0w = r(mean)

	eventstudyinteract `y' d1-d4 d6-d14, cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
	guardar sa_v60s15 `y' `m0'
	guardarV sa_v60s15_`y'

	eventstudyinteract `y' d1-d4 d6-d14 [aw = `w'], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
	guardar sa_w_v60s15 `y' `m0w'
	guardarV sa_w_v60s15_`y'
}

postclose pf


*7. ESTIMACION INDIVIDUAL (TWFE mujer-año, EF de UV y año, cluster UV)
use "$muestra/muestra_laboral_v60_ind.dta", clear
gen nunca_tratada = (g1 == 0)
gen rel_t1_bin = rel_t1
replace rel_t1_bin = -5 if rel_t1 < -5
replace rel_t1_bin = -1 if missing(rel_t1)
tab rel_t1_bin, gen(d)

capture postclose pf
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_lab_ind_v60.dta", replace

foreach y in empleo_formal ln_ingreso ingreso_rel {
	quietly sum `y' if nunca_tratada == 1
	local m0 = r(mean)
	reghdfe `y' d1-d4 d6-d15 per_edad, absorb(id_uv_2024 anio) cluster(id_uv_2024)
	guardar twfe_ind `y' `m0'
	test d1 d2 d3 d4
	post pf ("pretest_ind") ("`y'") (-99) (r(p)) (.) (.) (.) (.)

	eventstudyinteract `y' d1-d4 d6-d15, cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
	guardar sa_ind `y' `m0'
	guardarV sa_ind_`y'
}
postclose pf


*7b. ESTIMACION INDIVIDUAL CON EF DE MUJER Y UV FIJA (ITT), cluster UV fija  // CAMBIO 2
* sin per_edad: con EF mujer + EF año la edad es colineal  // CAMBIO 2
use "$muestra/muestra_laboral_v60_ind.dta", clear  // CAMBIO 2
keep if muestra_f == 1 & pre_f == 1  // CAMBIO 2
count  // CAMBIO 2
gunique rut_inn  // CAMBIO 2
gunique uv_fija  // CAMBIO 2
gen nunca_f = (g1_f == 0)  // CAMBIO 2
gen rel_f = anio - g1_f if g1_f > 0  // CAMBIO 2
gen rel_t1_bin = rel_f  // CAMBIO 2: mismo nombre para que guardar lea d1-d15
replace rel_t1_bin = -5 if rel_f < -5  // CAMBIO 2
replace rel_t1_bin = -1 if missing(rel_f)  // CAMBIO 2
tab rel_t1_bin, gen(d)  // CAMBIO 2  REVISAR: d5 tiene que ser -1

capture postclose pf  // CAMBIO 2
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_lab_indm_v60.dta", replace  // CAMBIO 2

foreach y in empleo_formal ln_ingreso ingreso_rel {  // CAMBIO 2
	quietly sum `y' if nunca_f == 1  // CAMBIO 2
	local m0 = r(mean)  // CAMBIO 2
	reghdfe `y' d1-d4 d6-d15, absorb(rut_inn anio) cluster(uv_fija)  // CAMBIO 2
	guardar twfe_indm `y' `m0'  // CAMBIO 2
	test d1 d2 d3 d4  // CAMBIO 2
	post pf ("pretest_indm") ("`y'") (-99) (r(p)) (.) (.) (.) (.)  // CAMBIO 2

	eventstudyinteract `y' d1-d4 d6-d15, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)  // CAMBIO 2
	guardar sa_indm `y' `m0'  // CAMBIO 2
	guardarV sa_indm_`y'  // CAMBIO 2
}  // CAMBIO 2
postclose pf  // CAMBIO 2



*8. REVISAR
use "$est/coefs_lab_v60.dta", clear
list modelo outcome k b se N n_uv if k == 0 | k == 4, sepby(outcome)
use "$est/coefs_lab_ind_v60.dta", clear
list modelo outcome k b se N if k == 0 | k == 4 | k == -99, sepby(outcome)
use "$est/coefs_lab_indm_v60.dta", clear  // CAMBIO 3
list modelo outcome k b se N if k == 0 | k == 4 | k == -99, sepby(outcome)  // CAMBIO 3


*9. GRAFICOS PRINCIPALES (solo para mirar, no se exportan)
grafico coefs_lab_v60 empleo_formal sa_w_v60
grafico coefs_lab_v60 ingreso_rel sa_w_v60
grafico coefs_lab_v60 ln_ingreso sa_w_v60

grafico coefs_lab_v60 empleo_formal sa_w_v60s15
grafico coefs_lab_v60 ingreso_rel sa_w_v60s15

grafico coefs_lab_ind_v60 empleo_formal twfe_ind
grafico coefs_lab_ind_v60 ln_ingreso twfe_ind
grafico coefs_lab_ind_v60 ingreso_rel twfe_ind

grafico coefs_lab_ind_v60 empleo_formal sa_ind
grafico coefs_lab_ind_v60 ln_ingreso sa_ind
grafico coefs_lab_ind_v60 ingreso_rel sa_ind

grafico coefs_lab_indm_v60 empleo_formal sa_indm  // CAMBIO 4
grafico coefs_lab_indm_v60 ln_ingreso sa_indm  // CAMBIO 4
grafico coefs_lab_indm_v60 ingreso_rel sa_indm  // CAMBIO 4

log close
