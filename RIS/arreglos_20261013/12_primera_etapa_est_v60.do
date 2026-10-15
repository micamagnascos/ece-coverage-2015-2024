*PRIMERA ETAPA PARTE 2 - HIJOS DE MADRES DEL 60% MAS VULNERABLE (v60)
*Copia de 20261006/03_primera_etapa.do. Cambios: buscar "CAMBIO" (solo nombres de bases, log y archivos de salida)
*Correr DESPUES de 09 y 11 (usa primera_etapa_panel_v60_uv.dta)


clear all

do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
* CAMBIO 1: nombre log
log using "$est/log_pe_v60_20261014.txt", text replace 

*BASE UV AÑO
* CAMBIO 2: base v60
use "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\primera etapa/primera_etapa_panel_v60_uv.dta", clear 
count
gduplicates report id_uv_2024 anio


keep if muestra_t1 == 1
gen nunca_tratada = (g1==0)
count
gunique id_uv_2024
* CAMBIO 3: linea nueva, revisar que no haya UV-año con muy pocos niños
sum n_ninos, detail 


*TENDENCIAS POR AÑO Y COHORTE
preserve
gen matr = tasa_matricula * n_ninos
gcollapse (mean) tasa_matricula (sum) matr n_ninos (count) n_uv = n_ninos, by(anio g1)
* CAMBIO 4: nombre archivo
save "$est/tend_pe_v60.dta", replace 
restore


*DUMMIES DE EVENTO
gen rel_t1_bin = rel_t1
replace rel_t1_bin = -5 if rel_t1 < -5
replace rel_t1_bin = -1 if missing(rel_t1)
* REVISAR: debe ir de -5 a 9 (15 dummies, d5 = k=-1) igual que la muestra completa
tab rel_t1_bin
tab rel_t1_bin, gen(d)
count if missing(d1)



* ESTIMACIONES
capture postclose pf
* CAMBIO 5: nombre archivo
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_pe_v60.dta", replace 

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
guardar twfe_w tasa_matricula `m0w'

eventstudyinteract tasa_matricula d1-d4 d6-d15, cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa tasa_matricula `m0'
* CAMBIO 6: nombre archivo V
guardarV tasa_matricula_v60 

eventstudyinteract tasa_matricula d1-d4 d6-d15 [aw= n_ninos], cohort(g1) control_cohort(nunca_tratada)  absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w tasa_matricula `m0w'
* CAMBIO 7: nombre archivo V
guardarV sa_w_tasa_matricula_v60 

postclose pf


* CAMBIO 8: nombre archivo
use "$est/coefs_pe_v60.dta", clear 
list modelo k b se N n_uv media_ctr if k == 0 | k == 99 | k == -99
list modelo k b se if modelo == "twfe"
* CAMBIO 9: coefs_pe -> coefs_pe_v60 (estas 3 lineas)
grafico coefs_pe_v60 tasa_matricula twfe 
grafico coefs_pe_v60 tasa_matricula sa
grafico coefs_pe_v60 tasa_matricula sa_w

log close
