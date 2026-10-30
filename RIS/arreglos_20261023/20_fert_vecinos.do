*20 FERTILIDAD CON RESTRICCION DE VECINOS (pedido profes 22/10) -- 27/10/2026
*control limpio: A. saca nunca tratadas con vecina que abrio jardin   B. saca nunca tratadas con algun jardin vecino
*usa la base UV ya colapsada por el 01 de anoche (rapido). SA ponderado, igual que el 01

clear all
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
global cob "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\cobertura"
capture log close
log using "$est/log_fert_vecinos_20261027.txt", text replace

*1. vecinas desde la base de cobertura NUEVA (una fila por UV)
use t_id_uv_ca vecina_jardin vecina_abre using "$cob/base_cobertura_cp.dta", clear
gduplicates drop
* REVISAR: no tiene que haber duplicados
gduplicates report t_id_uv_ca
rename t_id_uv_ca id_uv_2024
save "$cob/vecinas_uv.dta", replace

*2. base UV-año del 01 + vecinas
use "$muestra/muestra_fertilidad_v60_uvs.dta", clear
merge m:1 id_uv_2024 using "$cob/vecinas_uv.dta", keep(master match)
tab _merge
drop _merge
gen nunca_tratada = (g1 == 0)
* REVISAR: cuantas nunca tratadas se pierden en cada definicion (anotar)
tab vecina_abre if nunca_tratada == 1 & anio == 2016
tab vecina_jardin if nunca_tratada == 1 & anio == 2016

*DUMMIES DE EVENTO
gen rel_t1_bin = rel_t1
replace rel_t1_bin = -5 if rel_t1 < -5
replace rel_t1_bin = -1 if missing(rel_t1)
* REVISAR: 15 filas, la fila 5 tiene que ser -1
tab rel_t1_bin, gen(d)

capture postclose pf
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_fert_vecinos.dta", replace

*A. CONTROL SIN VECINA QUE ABRIO JARDIN
quietly sum tuvo_hijo if nunca_tratada == 1 & vecina_abre == 0 [aw = n_mujeres]
local m0w = r(mean)
* OJO: el if saca SOLO a las nunca tratadas con vecina_abre == 1 (las tratadas se quedan todas)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if !(nunca_tratada == 1 & vecina_abre == 1) [aw = n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_abre tuvo_hijo `m0w'
guardarV sa_w_abre_v60_tuvo_hijo

*B. CONTROL SIN NINGUN JARDIN VECINO
quietly sum tuvo_hijo if nunca_tratada == 1 & vecina_jardin == 0 [aw = n_mujeres]
local m0w = r(mean)
eventstudyinteract tuvo_hijo d1-d4 d6-d15 if !(nunca_tratada == 1 & vecina_jardin == 1) [aw = n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_jardin tuvo_hijo `m0w'
guardarV sa_w_jardin_v60_tuvo_hijo

postclose pf

use "$est/coefs_fert_vecinos.dta", clear
list modelo k b se N n_uv if k >= -1, sepby(modelo)

log close
