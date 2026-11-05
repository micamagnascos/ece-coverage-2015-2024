*PRIMERA ETAPA - HIJOS DE MADRES V60
* 19/10/2026


clear all

do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_pe_20261102.txt", text replace 

*BASE UV AÑO 
use "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\primera etapa/primera_etapa_panel_uv_v60.dta", clear
count 
gduplicates report id_uv_2024 anio


keep if muestra_t1 == 1 
gen nunca_tratada = (g1==0)
count 
gunique id_uv_2024
sum n_ninos, detail 

*revisar cuando aparecen las uv 
bys id_uv_2024: egen primer_anio = min(anio)
tab primer_anio if anio == primer_anio & g1 > 0 & !missing(g1)


*TENDENCIAS POR AÑO Y COHORTE 
preserve 
gen matr = tasa_matricula * n_ninos
gcollapse (sum) matr n_ninos (count) n_uv = n_ninos, by(anio g1)
save "$est/tend_pe_v60.dta", replace 
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
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_pe_v60.dta", replace
	
quietly sum tasa_matricula if nunca_tratada == 1 
local m0= r(mean)
quietly sum tasa_matricula if nunca_tratada == 1 [aw= n_ninos]
local m0w = r(mean)

*Prinicipal
eventstudyinteract tasa_matricula d1-d4 d6-d15 [aw= n_ninos], cohort(g1) control_cohort(nunca_tratada)  absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w tasa_matricula `m0w'
guardarV sa_w_tasa_matricula_v60
*capture noisily lincom (d6 + d7 + d8 + d9 + d10 + d11 + d12 + d13 + d14 + d15)/10

*Sin 2015 
eventstudyinteract tasa_matricula d1-d4 d6-d14 if g1 !=2015 [aw= n_ninos], cohort(g1) control_cohort(nunca_tratada)  absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_s15 tasa_matricula `m0w'
guardarV sa_w_s15_tasa_matricula_v60
*capture noisily lincom (d6 + d7 + d8 + d9 + d10 + d11 + d12 + d13 + d14 + d15)/10
	
	
*PANEL BALANCEADO 
preserve
keep if g1 == 0 | (inrange(g1, 2016, 2020) & inrange(rel_t1, -2, 4))
tab g1 rel_t1_bin if g1 > 0 

eventstudyinteract tasa_matricula d4 d6-d10 if g1 [aw= n_ninos], cohort(g1) control_cohort(nunca_tratada)  absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_bal tasa_matricula `m0w'
guardarV sa_w_bal_tasa_matricula_v60
*capture noisily lincom (d6 + d7 + d8 + d9 + d10)/5
restore 

postclose pf 


use "$est/coefs_pe_v60.dta", clear 
list modelo k b se N n_uv media_ctr 


grafico coefs_pe_v60 tasa_matricula sa_w
grafico coefs_pe_v60 tasa_matricula sa_w_s15
grafico coefs_pe_v60 tasa_matricula sa_w_bal


log close 






