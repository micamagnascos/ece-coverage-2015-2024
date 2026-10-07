*ESTIMACIONES FERTILIDAD - SIN COHORTE 2015
*Cambios respecto a 20261006/01_fertilidad.do: buscar "CAMBIO" (no hace falta copiar los comentarios)

clear all

do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_fert_sin2015_20261007.txt", text replace // CAMBIO 1: nombre log


*BASE UV AÑO 
use "$muestra/muestra_fertilidad_uvs.dta", clear
count 
gduplicates report id_uv_2024 anio 
tab grupo_t1

keep if muestra_t1 == 1
drop if g1 == 2015 // CAMBIO 2: linea nueva
gen ever_t1 = (g1 > 0)
gen nunca_tratada = (g1==0)
count if missing(g1)
tab grupo_t1 ever_t1
count
gunique id_uv_2024


*TENDENCIAS POR AÑO Y COHORTE 
preserve 
gen nac = tuvo_hijo * n_mujeres
gcollapse (mean) tuvo_hijo per_edad (sum) nac n_mujeres (count) n_uv = n_mujeres, by(anio g1)
save "$est/tend_fert_sin2015.dta", replace // CAMBIO 3: nombre archivo
restore 

*BALANCE 2014
global bal_ind tuvo_hijo per_edad n_hijos_menor5 n_mujeres pob_total_uv densidad_ninos_uv
preserve 
keep if anio == 2014 & !missing(pob_total_uv)
cap postclose pb
postfile pb str32 var m0 m1 dn m0w m1w dnw using "$est/balance_fert_sin2015.dta", replace // CAMBIO 4: nombre archivo
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
tab rel_t1_bin // REVISAR: debe ir de -5 a 8 (ya no hay k = 9)
tab rel_t1_bin, gen(d)
count if missing(d1)



* ESTIMACIONES 
capture postclose pf 
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_fert_sin2015.dta", replace // CAMBIO 5: nombre archivo

	
sum tuvo_hijo if nunca_tratada == 1 
local m0= r(mean)
quietly sum tuvo_hijo if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
	
reghdfe tuvo_hijo d1-d4 d6-d14 per_edad, absorb(id_uv_2024 anio) cluster(id_uv_2024) // CAMBIO 6: d15 -> d14
guardar twfe tuvo_hijo `m0'
test d1 d2 d3 d4
post pf ("pretest_p") ("tuvo_hijo") (-99) (r(p)) (.) (.) (.) (.)
lincom (d6 + d7 + d8 + d9 + d10 + d11 + d12 + d13 + d14)/9 // CAMBIO 7: sin d15, dividir por 9
post pf ("twfe_prom") ("tuvo_hijo") (99) (r(estimate)) (r(se)) (.) (.) (`m0')

reghdfe tuvo_hijo d1-d4 d6-d14 per_edad [aw= n_mujeres], absorb(id_uv_2024 anio) cluster(id_uv_2024) // CAMBIO 8: d15 -> d14
guardar twfe_w tuvo_hijo `m0w'

eventstudyinteract tuvo_hijo d1-d4 d6-d14, cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024) // CAMBIO 9: d15 -> d14
guardar sa tuvo_hijo `m0'
guardarV sa_tuvo_hijo_sin2015 // CAMBIO 10: nombre archivo V

eventstudyinteract tuvo_hijo d1-d4 d6-d14 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024) // CAMBIO 11: d15 -> d14
guardar sa_w tuvo_hijo `m0w'

postclose pf 



use "$est/coefs_fert_sin2015.dta", clear // CAMBIO 12: nombre archivo
list modelo k b se N n_uv media_ctr if k == 0 | k == 99 | k == -99
grafico coefs_fert_sin2015 tuvo_hijo twfe // CAMBIO 13: coefs_fert -> coefs_fert_sin2015 (estas 4 lineas)
grafico coefs_fert_sin2015 tuvo_hijo twfe_w 
grafico coefs_fert_sin2015 tuvo_hijo sa 
grafico coefs_fert_sin2015 tuvo_hijo sa_w 


use "$est/tend_fert_sin2015.dta", clear // CAMBIO 14: nombre archivo
gen trat = (g1 > 0)
collapse (sum) nac n_mujeres, by(anio trat)
gen tasa = nac/ n_mujeres 
twoway (line tasa anio if trat == 0) (line tasa anio if trat == 1), legend(order(1 "Nunca tratadas" 2 "Tratadas"))

log close 
