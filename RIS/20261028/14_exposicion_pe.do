* 14 EXPOSICION  - PRIMERA ETAPA POR EDAD DEL NIÑO CUANDO ABRIO EL JARDIN 
*grupos:
* 1: nacio el año de la apertura 
* 2: tenia 1-2 cuando abrio el jardin 
* 3: tenia 3-4 cuando abrio el jardin 

*PRIMERA ETAPA - HIJOS DE MADRES V60
* 19/10/2026


clear all

do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_expo_pe_20261019.txt", text replace 

*BASE PANEL NIÑOS MATRICULA  
use run_alu_inn anio anio_nac_hijo matriculado g1 muestra_t1 id_uv_2024 using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\primera etapa/primera_etapa_panel_v60.dta", clear
count 


keep if muestra_t1 == 1 
gduplicates drop run_alu_inn anio, force 

tab anio_nac_hijo 
*eliminamos a los que nacen despues de 2020, porque no le alcanzamos a ver todos los años 
keep if inrange(anio_nac_hijo, 2010, 2020)

*Una fila por niño 
gsort run_alu_inn anio 
gcollapse (sum) anios_mat = matriculado (count) n_anios = matriculado (firstnm) g1 id_uv_2024 anio_nac_hijo, by(run_alu_inn)
gen esperado = min(5, anio_nac_hijo - 2009)
tab n_anios esperado 
keep if n_anios == esperado 

*Grupos de exposicion 
gen edad_ap = g1 - anio_nac_hijo if g1 > 0 
tab edad_ap 
gen expo = 0 
replace expo = 1 if edad_ap <= 0 
replace expo = 2 if inlist(edad_ap, 1, 2)
replace expo = 3 if inlist(edad_ap, 3, 4)

quietly sum anios_mat if g1 == 0 
local m0 = r(mean)

reghdfe anios_mat i.expo, absorb(id_uv_2024 anio_nac_hijo) cluster(id_uv_2024)

capture postclose pf 
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_expo_pe_v60.dta", replace
post pf ("expo") ("anios_mat") (1) (_b[1.expo]) (_se[1.expo]) (e(N)) (e(N_clust)) (`m0')
post pf ("expo") ("anios_mat") (2) (_b[2.expo]) (_se[2.expo]) (e(N)) (e(N_clust)) (`m0')
post pf ("expo") ("anios_mat") (3) (_b[3.expo]) (_se[3.expo]) (e(N)) (e(N_clust)) (`m0')

postclose pf 


use "$est/coefs_expo_pe_v60.dta", clear 
list modelo k b se N n_uv media_ctr 


log close 






