*PRIMERA ETAPA PARTE 2 


clear all

do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_pe_20261005.txt", text replace 

*BASE UV AÑO 
use "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\primera etapa/primera_etapa_panel_uv.dta", clear
count 
gduplicates report id_uv_2024 anio


keep if muestra_t1 == 1 
gen nunca_tratada = (g1==0)
count 
gunique id_uv_2024


*TENDENCIAS POR AÑO Y COHORTE 
preserve 
gen matr = tasa_matricula * n_ninos
gcollapse (mean) tasa_matricula (sum) matr n_ninos (count) n_uv = n_ninos, by(anio g1)
save "$est/tend_pe.dta", replace 
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
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_pe.dta", replace
	
sum tasa_matricula if nunca_tratada == 1 
local m0= r(mean)
quietly sum tasa_matricula if nunca_tratada == 1 [aw= n_ninos]
local m0w = r(mean)
	
reghdfe tasa_matricula d1-d4 d6-d15, absorb(id_uv_2024 anio) cluster(id_uv_2024)
guardar twfe tasa_matricula `m0'
test d1 d2 d3 d4
post pf ("pretest_p") ("tasa_matricula") (-99) (r(p)) (.) (.) (.) (.)
lincom (d6 + d7 + d8 + d9 + d10 + d11 + d12 + d13 + d14 + d15)/10
post pf ("twfe_prom") ("tasa_matricula") (99) (r(estimate)) (r(se)) (.) (.) (`m0')

reghdfe tasa_matricula d1-d4 d6-d15 [aw= n_ninos], absorb(id_uv_2024 anio) cluster(id_uv_2024)
guardar twfe_w tasa_matricula `m0w' // CAMBIO 3: cambiar tuvo_hijo por tasa_matricula (etiqueta mal puesta)

eventstudyinteract tasa_matricula d1-d4 d6-d15, cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa tasa_matricula `m0'
guardarV tasa_matricula

eventstudyinteract tasa_matricula d1-d4 d6-d15 [aw= n_ninos], cohort(g1) control_cohort(nunca_tratada)  absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w tasa_matricula `m0w'
guardarV sa_w_tasa_matricula // CAMBIO 1: linea nueva, guarda la V del SA ponderado

postclose pf 


use "$est/coefs_pe.dta", clear 
list modelo k b se N n_uv media_ctr if k == 0 | k == 99 | k == -99
list modelo k b se if modelo == "twfe"
grafico coefs_pe tasa_matricula twfe
grafico coefs_pe tasa_matricula sa
grafico coefs_pe tasa_matricula sa_w

log close 






