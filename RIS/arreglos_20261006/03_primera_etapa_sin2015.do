*PRIMERA ETAPA PARTE 2 - SIN COHORTE 2015
*Cambios respecto a 20261006/03_primera_etapa.do: buscar "CAMBIO" (no hace falta copiar los comentarios)


clear all

do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_pe_sin2015_20261007.txt", text replace // CAMBIO 1: nombre log

*BASE UV AÑO 
use "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\primera etapa/primera_etapa_panel_uv.dta", clear
count 
gduplicates report id_uv_2024 anio


keep if muestra_t1 == 1 
drop if g1 == 2015 // CAMBIO 2: linea nueva
gen nunca_tratada = (g1==0)
count 
gunique id_uv_2024


*TENDENCIAS POR AÑO Y COHORTE 
preserve 
gen matr = tasa_matricula * n_ninos
gcollapse (mean) tasa_matricula (sum) matr n_ninos (count) n_uv = n_ninos, by(anio g1)
save "$est/tend_pe_sin2015.dta", replace // CAMBIO 3: nombre archivo
restore 


*DUMMIES DE EVENTO
gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 
replace rel_t1_bin = -1 if missing(rel_t1)
tab rel_t1_bin // REVISAR: debe ir de -5 a 8 (ya no hay k = 9)
tab rel_t1_bin, gen(d)
count if missing(d1)



* ESTIMACIONES 
capture postclose pf 
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_pe_sin2015.dta", replace // CAMBIO 4: nombre archivo
	
sum tasa_matricula if nunca_tratada == 1 
local m0= r(mean)
quietly sum tasa_matricula if nunca_tratada == 1 [aw= n_ninos]
local m0w = r(mean)
	
reghdfe tasa_matricula d1-d4 d6-d14, absorb(id_uv_2024 anio) cluster(id_uv_2024) // CAMBIO 5: d15 -> d14
guardar twfe tasa_matricula `m0'
test d1 d2 d3 d4
post pf ("pretest_p") ("tasa_matricula") (-99) (r(p)) (.) (.) (.) (.)
lincom (d6 + d7 + d8 + d9 + d10 + d11 + d12 + d13 + d14)/9 // CAMBIO 6: sin d15, dividir por 9
post pf ("twfe_prom") ("tasa_matricula") (99) (r(estimate)) (r(se)) (.) (.) (`m0')

reghdfe tasa_matricula d1-d4 d6-d14 [aw= n_ninos], absorb(id_uv_2024 anio) cluster(id_uv_2024) // CAMBIO 7: d15 -> d14
guardar twfe_w tasa_matricula `m0w' // CAMBIO 8: tuvo_hijo -> tasa_matricula (error del original)

eventstudyinteract tasa_matricula d1-d4 d6-d14, cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024) // CAMBIO 9: d15 -> d14
guardar sa tasa_matricula `m0'
guardarV tasa_matricula_sin2015 // CAMBIO 10: nombre archivo V

eventstudyinteract tasa_matricula d1-d4 d6-d14 [aw= n_ninos], cohort(g1) control_cohort(nunca_tratada)  absorb(id_uv_2024 anio) vce(cluster id_uv_2024) // CAMBIO 11: d15 -> d14
guardar sa_w tasa_matricula `m0w'

postclose pf 


use "$est/coefs_pe_sin2015.dta", clear // CAMBIO 12: nombre archivo
list modelo k b se N n_uv media_ctr if k == 0 | k == 99 | k == -99
list modelo k b se if modelo == "twfe"
grafico coefs_pe_sin2015 tasa_matricula twfe // CAMBIO 13: coefs_pe -> coefs_pe_sin2015 (estas 3 lineas)
grafico coefs_pe_sin2015 tasa_matricula sa
grafico coefs_pe_sin2015 tasa_matricula sa_w

log close 
