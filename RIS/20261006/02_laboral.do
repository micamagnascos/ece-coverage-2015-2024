*M LABORAL 

clear all

do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_lab_20261005.txt", text replace 

*BASE UV AÑO 
use "$muestra/muestra_laboral_ingresos.dta", clear
count 
tab grupo_t1


keep if muestra_t1 == 1
keep rut_inn anio id_uv_2024 g1 grupo_t1 muestra_t1 rel_t1 renta_imponible_anual monto_dep_anual monto_indep_anual meses_con_renta meses_cotizados_total per_edad n_hijos_menor5 per_fic_horastrabajo  per_fic_trabaja per_fic_tipoeducacion_id pob_total_uv densidad_ninos_uv
count 
gduplicates report rut_inn anio 


*OUTCOMES NIVEL MUJER ANTES DEL COLLAPSE
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

sum ingreso_anual ln_ingreso empleo_formal meses_trabajando 
sum ingreso_anual if ingreso_anual > 0, detail 


*LIMPIEZA CONTROLES 
*educaciòn 
tab per_fic_tipoeducacion_id
*es mejor usar per fic tipo de educacion 
replace per_fic_tipoeducacion_id = . if per_fic_tipoeducacion_id == 99
*trabajo 
tab per_fic_trabaja
replace per_fic_trabaja = . if per_fic_trabaja == 9 
replace per_fic_trabaja = 0 if per_fic_trabaja == 2
tab per_fic_trabaja empleo_formal, row 
tab anio empleo_formal, row 


*TENDENCIAS POR AÑO Y CHORTE
gen uno = 1  
preserve 
gcollapse (mean) ingreso_anual ln_ingreso empleo_formal meses_trabajando per_fic_trabaja (sum) n_mujeres = uno, by(anio g1)
save "$est/tend_lab.dta", replace 
restore 

*COLAPSO A UV AÑO 
gcollapse (mean) ingreso_anual ln_ingreso empleo_formal meses_trabajando per_edad n_hijos_menor5 per_fic_horastrabajo per_fic_trabaja per_fic_tipoeducacion_id (sum) n_mujeres = uno n_con_ingreso = empleo_formal (firstnm) pob_total_uv densidad_ninos_uv g1 grupo_t1 muestra_t1 rel_t1, by(id_uv_2024 anio)
gduplicates report id_uv_2024 anio 
count 
gunique id_uv_2024 
save "$muestra/muestra_laboral_ingresos_v2.dta", replace 

gen ever_t1 = (g1 > 0)
gen nunca_tratada = (g1==0)
count if missing(g1)


*BALANCE 2014
global bal_ind empleo_formal ln_ingreso ingreso_anual meses_trabajando per_edad n_hijos_menor5 per_fic_horastrabajo per_fic_trabaja per_fic_tipoeducacion_id n_mujeres pob_total_uv densidad_ninos_uv
preserve 
keep if anio == 2014 & !missing(pob_total_uv)
cap postclose pb
postfile pb str32 var m0 m1 dn m0w m1w dnw using "$est/balance_lab.dta", replace 
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
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_lab.dta", replace

foreach y in empleo_formal ln_ingreso meses_trabajando {

	local w n_con_ingreso
	if "`y'" == "empleo_formal" local w n_mujeres 
	
	quietly sum `y' if nunca_tratada == 1 
	local m0= r(mean)
	quietly sum `y' if nunca_tratada == 1 [aw= `w']
	local m0w = r(mean)
		
	reghdfe `y' d1-d4 d6-d15 per_edad, absorb(id_uv_2024 anio) cluster(id_uv_2024)
	guardar twfe `y' `m0'
	test d1 d2 d3 d4
	post pf ("pretest_p") ("`y'") (-99) (r(p)) (.) (.) (.) (.)
	lincom (d6 + d7 + d8 + d9 + d10 + d11 + d12 + d13 + d14 + d15)/10
	post pf ("twfe_prom") ("`y'") (99) (r(estimate)) (r(se)) (.) (.) (`m0')

	reghdfe `y' d1-d4 d6-d15 per_edad [aw= `w'], absorb(id_uv_2024 anio) cluster(id_uv_2024)
	guardar twfe_w `y' `m0w'

	eventstudyinteract `y' d1-d4 d6-d15, cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
	guardar sa `y' `m0'
	guardarV sa_`y'

	eventstudyinteract `y' d1-d4 d6-d15 [aw= `w'], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
	guardar sa_w `y' `m0w'

}
postclose pf 


use "$est/coefs_lab.dta", clear 
list modelo k b se N n_uv media_ctr if k == 0 | k == 99 | k == -99, sepby(outcome)
grafico coefs_lab empleo_formal sa
grafico coefs_lab ln_ingreso sa
grafico coefs_lab meses_trabajando sa









