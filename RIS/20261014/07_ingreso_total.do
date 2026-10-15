*M LABORAL
*INGRESO TOTAL -> INCLUYE CEROS  

clear all

do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_ingtotal_20261005.txt", text replace 

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

gen ingreso_total = ingreso_anual 
replace ingreso_total = 0 if missing(ingreso_total)
bys anio: egen m_anio = mean(ingreso_total)
gen ingreso_rel = 100 * ingreso_total/ m_anio 
sum ingreso_total ingreso_rel, detail 
tab anio, sum(ingreso_rel)



*COLAPSO A UV AÑO 
gen uno = 1
gcollapse (mean) ingreso_rel per_edad (sum) n_mujeres = uno (firstnm) g1 rel_t1, by(id_uv_2024 anio)
gduplicates report id_uv_2024 anio 


gen nunca_tratada = (g1==0)


*DUMMIES DE EVENTO
gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 
replace rel_t1_bin = -1 if missing(rel_t1)
tab rel_t1_bin
tab rel_t1_bin, gen(d)
count if missing(d1)



* ESTIMACIONES 
capture postclose pf 
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_ingtotal.dta", replace

sum ingreso_rel if nunca_tratada == 1 
local m0= r(mean)
quietly sum ingreso_rel if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
		
reghdfe ingreso_rel d1-d4 d6-d15 per_edad, absorb(id_uv_2024 anio) cluster(id_uv_2024)
guardar twfe ingreso_rel `m0'
test d1 d2 d3 d4
post pf ("pretest_p") ("ingreso_rel") (-99) (r(p)) (.) (.) (.) (.)
	
reghdfe ingreso_rel d1-d4 d6-d15 per_edad [aw= n_mujeres], absorb(id_uv_2024 anio) cluster(id_uv_2024)
guardar twfe_w n_mujeres' `m0w'

eventstudyinteract n_mujeres d1-d4 d6-d15, cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa n_mujeres `m0'
guardarV sa_n_mujeres

eventstudyinteract n_mujeres d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w n_mujeres `m0w'
guardarV sa_w_n_mujeres

postclose pf 


use "$est/coefs_ingtotal.dta", clear 
list modelo k b se N n_uv media_ctr if k == 0 | k == 99 | k == -99, sepby(outcome)
grafico coefs_lab empleo_formal sa
grafico coefs_lab ln_ingreso sa
grafico coefs_lab meses_trabajando sa









