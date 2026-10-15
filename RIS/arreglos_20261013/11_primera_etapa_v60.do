*PRIMERA ETAPA - MATRICULA -- VERSION 13/10/2026: hijos de madres del 60% mas vulnerable. Solo construccion de la muestra (lineas 1-105 de primera_etapa.do). Cambios marcados con CAMBIO N
*SEGUIR CON ESTA BASE, OJO CON LAS VAR DE TRAT QUE YA VAN A VENIR DE ANTES 

clear all 
ssc install eventstudyinteract 
ssc install avar 

global matricula "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\matricula"
global hijos "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\hijos"
global muestra "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra"


*abrimos base hijos 
use "$hijos/hijos_filtrado_2014_2024.dta", clear
describe, fullnames
gduplicates report rut_inn //madres. si hay duplicados porque pueden tener varios hijos 
gduplicates report run_hijo_inn

*tenemos que pasarla a panel año primero porque el listado de madres tratadas esta en panel 
gen anio_ini = anio_nac_hijo 
gen anio_fin = anio_nac_hijo + 4 

replace anio_fin = anio_def_hijo if !missing(anio_def_hijo) & anio_def_hijo < anio_fin

gen n_anios = anio_fin - anio_ini + 1 

count if n_anios <= 0 
*assert n_anios > 0 
drop if n_anios <= 0

expand n_anios  
bysort run_hijo_inn: gen anio = anio_nac_hijo + _n - 1 

drop anio_fin n_anios 

duplicates report run_hijo_inn anio 
count 

*hacemos merge con los rut de sus madres para saber que "hijos" son tratados 
* CAMBIO 1: _v60 (trae v60 y mudanzas)
merge m:1 rut_inn anio using "$muestra/muestra_completa_ruts_trat_v60.dta" 

*los que no hicieron merge no los necesitamos, los que si hicieron merge son los hijos de las madres de mi muestra 
keep if _merge == 3 
drop _merge
* CAMBIO 2: linea nueva, hijos de madres del 60% mas vulnerable
keep if v60 == 1 
* CAMBIO 2: linea nueva
count 

describe, fullnames 

tab anio_ini

tab tratada 


gduplicates report run_hijo_inn anio
*no hay duplicados 

*MERGE CON LA BASE DE MATRICULA 
describe using "$matricula/mat_parv_2014_2025.dta"

rename run_hijo_inn run_alu_inn 

merge 1:m run_alu_inn anio using "$matricula/mat_parv_2014_2025.dta"

*merge 2: estan en matricula pero no son hijos de las madres de mi muestra 
*merge 1: no estan matriculados ese año, no botar 

count if _merge == 2 

gen matriculado = (_merge==3)

describe, fullnames 
drop latitud longitud 
drop marca_rc nom_pro_estab let_cur_m nom_deprov_estab cod_deprov_estab dias_trab_grupo_j nom_jor_j desc_mod_i desc_nivel_i cod_grupo_i formal corr_gru_j let_gru_j
drop fec_nac_alu_inn fec_ret_estab_m_inn cod_tip_cur_m cod_mac_estab cod_jor_i cod_provincia

drop if _merge == 2 
describe, fullnames 
drop anio_nac
drop _merge 

tab matriculado
tab anio matriculado

gsort run_alu_inn anio 

*cuàntos niños aparecen en el panel en algun año?
egen tag_nino = tag(run_alu_inn)
count if tag_nino == 1 
*2,684,829

* cuàntos niños son tratados?
bysort run_alu_inn: egen tratado_nino = max(!missing(rel_t1))
count if tag_nino == 1 & tratado_nino == 1 
*  221,199

compress
* CAMBIO 3: nombre nuevo (antes primera_etapa_panel)
save "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\primera etapa/primera_etapa_panel_v60.dta", replace 

describe, fullnames
 
*** 
* VERSION COLAPSADA A NIVEL UV 
preserve 
* CAMBIO 4: agregar cambia_uv24 en el primer (mean)
gcollapse (mean) tasa_matricula=matriculado cambia_uv24 (count) n_ninos = run_alu_inn (mean) g1 post_t1 rel_t1 grupo_t1 muestra_t1 stock_base, by(id_uv_2024 anio) 
* CAMBIO 5: nombre nuevo (antes primera_etapa_panel_uv)
save "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\primera etapa/primera_etapa_panel_v60_uv.dta", replace 
restore 
