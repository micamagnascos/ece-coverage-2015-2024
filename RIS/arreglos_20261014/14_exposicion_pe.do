*14 EXPOSICION - PRIMERA ETAPA POR EDAD DEL NIÑO CUANDO ABRIO EL JARDIN -- 19/10/2026
*base del 11 a nivel niño (primera_etapa_panel_v60.dta, niño-año)
*una fila por niño: años matriculado entre 0 y 4, segun la edad que tenia cuando abrio el jardin
*grupos: 1 = nacio el año de la apertura o despues (todo el efecto), 2 = tenia 1-2, 3 = tenia 3-4
*referencia (0) = nunca tratadas + niños que ya tenian 5 o mas
*compara cohortes de nacimiento dentro de la misma UV (EF UV + año de nacimiento)

clear all
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_expo_pe_20261019.txt", text replace

use run_alu_inn anio anio_nac_hijo matriculado g1 muestra_t1 id_uv_2024 using "$pe/primera_etapa_panel_v60.dta", clear
keep if muestra_t1 == 1
*hay niños con 2 matriculas el mismo año
gduplicates drop run_alu_inn anio, force
* REVISAR: que haya nacidos 2010-2013 en la base
tab anio_nac_hijo
*nacidos 2010-2013 se ven desde 2014: les faltan años, pero son anteriores a cualquier apertura
*nacidos despues de 2020 no se ven hasta los 4 años -> fuera
keep if inrange(anio_nac_hijo, 2010, 2020)

*UNA FILA POR NIÑO (UV y g1 del primer año observado)
sort run_alu_inn anio
gcollapse (sum) anios_mat = matriculado (count) n_anios = matriculado (firstnm) g1 id_uv_2024 anio_nac_hijo, by(run_alu_inn)
*años que deberiamos ver: 5, o menos si nacio antes de 2014 (ej: nacido 2012 -> 3 años)
gen esperado = min(5, anio_nac_hijo - 2009)
* REVISAR: la mayoria deberia estar en la diagonal (n_anios = esperado)
tab n_anios esperado
keep if n_anios == esperado

*GRUPOS DE EXPOSICION
gen edad_ap = g1 - anio_nac_hijo if g1 > 0
* REVISAR: negativo = nacio despues de la apertura
tab edad_ap
gen expo = 0
replace expo = 1 if edad_ap <= 0
replace expo = 2 if inlist(edad_ap, 1, 2)
replace expo = 3 if inlist(edad_ap, 3, 4)
tab expo

quietly sum anios_mat if g1 == 0
local m0 = r(mean)

reghdfe anios_mat i.expo, absorb(id_uv_2024 anio_nac_hijo) cluster(id_uv_2024)

capture postclose pf
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_expo_pe_v60.dta", replace
* OJO: k = grupo de exposicion (1, 2, 3), no año de evento
post pf ("expo") ("anios_mat") (1) (_b[1.expo]) (_se[1.expo]) (e(N)) (e(N_clust)) (`m0')
post pf ("expo") ("anios_mat") (2) (_b[2.expo]) (_se[2.expo]) (e(N)) (e(N_clust)) (`m0')
post pf ("expo") ("anios_mat") (3) (_b[3.expo]) (_se[3.expo]) (e(N)) (e(N_clust)) (`m0')
postclose pf

*RESULTADO (no es event study: 3 coeficientes, uno por grupo)
use "$est/coefs_expo_pe_v60.dta", clear
list k b se N media_ctr

log close
