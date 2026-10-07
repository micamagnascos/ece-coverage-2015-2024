*06 HORAS TRABAJADAS 

clear all 
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
global cob "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\cobertura"
capture log close
log using "$est/log_horas_20261006.txt", text replace



*CHECKEO A NIVEL MUJER 
describe using "$muestra/muestra_laboral_ingresos.dta"

use "$muestra/muestra_laboral_ingresos.dta", clear

tab per_fic_tipoeducacion_id           
tab per_fic_trabaja, m   

tab per_fic_ocupacionactual, m 

tab per_fic_codigosrama              
           
tab per_fic_codigocontrato, m    
*si: con contrato ()
*no: sin contrato         

tab per_fic_horastrabajo, m          
tab per_fic_buscotrabajo, m
tab per_fic_nobuscotrabajomotivo, m



*LIMPIEZA NIVEL MUJER Y PROMEDIO POR UV AÑO 
keep id_uv_2024 anio muestra_t1 per_fic_horastrabajo rut_inn per_fic_buscotrabajo per_fic_nobuscotrabajomotivo 

keep if muestra_t1 == 1
replace per_fic_horastrabajo = . if per_fic_horastrabajo > 80
sum per_fic_horastrabajo, detail 

replace per_fic_nobuscotrabajomotivo = . if per_fic_nobuscotrabajomotivo > 10
sum per_fic_nobuscotrabajomotivo

gen hogar = (per_fic_nobuscotrabajomotivo == 1)
gen cuida = (per_fic_nobuscotrabajomotivo == 2)
gen cuida_hogar = (cuida == 1 | hogar == 1)
tab cuida hogar 

replace per_fic_buscotrabajo = . if per_fic_buscotrabajo == 9 
replace per_fic_buscotrabajo= 0 if per_fic_buscotrabajo== 2


gcollapse (mean) horas = per_fic_horastrabajo busca = per_fic_buscotrabajo cuida hogar cuida_hogar (count) n_horas = per_fic_horastrabajo n_busca = per_fic_buscotrabajo, by(id_uv_2024 anio)
sum horas busca cuida hogar cuida_hogar n_horas n_busca 

save "$muestra/horas_uv.dta", replace



* BASE UV AÑO
use "$muestra/muestra_laboral_ingresos_v2.dta", clear
merge 1:1 id_uv_2024 anio using "$muestra/horas_uv.dta"
drop _merge 
gen nunca_tratada = (g1 == 0)
gen rel_t1_bin = rel_t1
replace rel_t1_bin = -5 if rel_t1 < -5
replace rel_t1_bin = -1 if missing(rel_t1)
tab rel_t1_bin, gen(d)
count if missing(d1)


*ESTIMACIONES 
* est4: los 4 modelos de siempre (twfe, twfe_w, sa, sa_w)
capture program drop est4
program define est4
	args y w spec cov
	local copt
	if "`cov'" != "" local copt covariates(`cov')

	quietly sum `y' if nunca_tratada == 1
	local m0 = r(mean)
	quietly sum `y' if nunca_tratada == 1 [aw = `w']
	local m0w = r(mean)

	reghdfe `y' d1-d4 d6-d15 `cov', absorb(id_uv_2024 anio) cluster(id_uv_2024)
	guardar twfe_`spec' `y' `m0'
	test d1 d2 d3 d4
	post pf ("pretest_`spec'") ("`y'") (-99) (r(p)) (.) (.) (.) (.)
	lincom (d6 + d7 + d8 + d9 + d10 + d11 + d12 + d13 + d14 + d15)/10
	post pf ("twfe_prom_`spec'") ("`y'") (99) (r(estimate)) (r(se)) (.) (.) (`m0')

	reghdfe `y' d1-d4 d6-d15 `cov' [aw = `w'], absorb(id_uv_2024 anio) cluster(id_uv_2024)
	guardar twfe_w_`spec' `y' `m0w'

	eventstudyinteract `y' d1-d4 d6-d15, cohort(g1) control_cohort(nunca_tratada) `copt' absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
	guardar sa_`spec' `y' `m0'
	guardarV sa_`spec'_`y'

	eventstudyinteract `y' d1-d4 d6-d15 [aw = `w'], cohort(g1) control_cohort(nunca_tratada) `copt' absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
	guardar sa_w_`spec' `y' `m0w'
end



cap postclose pf 
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctrl using "$est/coefs_horas.dta", replace 
est4 horas n_horas rsh per_edad 
est4 busca n_busca rsh per_edad
est4 cuida n_mujeres rsh per_edad 
est4 hogar n_mujeres rsh per_edad  
est4 cuida_hogar n_mujeres rsh per_edad 
postclose pf 



* REVISAR
use "$est/coefs_horas.dta", clear
list modelo outcome b se N n_uv if k == 99 | k == -99, sepby(outcome)

grafico coefs_horas horas sa_rsh
grafico coefs_horas horas sa_w_rsh

grafico coefs_horas busca sa_rsh
grafico coefs_horas busca sa_w_rsh

grafico coefs_horas cuida sa_rsh
grafico coefs_horas cuida sa_w_rsh





