clear all

do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "log_mudanzas2122.txt", text append

local a 2021
local b 2022

pq use rut_inn anio id_uv_2024 using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_fertilidad_v60.parquet", clear
keep if inlist(anio, `a', `b')
rename id_uv_2024 uv 
reshape wide uv, i(rut_inn) j(anio)
rename uv`a' uv_a
rename uv`b' uv_b 
drop if missing(uv_a) | missing(uv_b)
gen mueve = (uv_a !=uv_b)
sum mueve 


*se muda por UV de origen 
bys uv_a: egen pct =mean(mueve)
bys uv_a: gen tag =(_n==1)
gen pct_cat = floor(pct*10)/10
tab pct_cat if tag

*de las que se mudan, que % va al destino mas comun 
keep if mueve == 1 
bys uv_a uv_b: gen n_dest = _N
bys uv_a: gen n_orig = _N
gen top = n_dest / n_orig
bys uv_a: egen top_max = max(top)
bys uv_a: gen tag2 = (_n == 1)
sum top_max if tag2 & n_orig >=10,d 

log close 
