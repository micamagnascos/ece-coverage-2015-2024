*DIAGNOSTICO UV: entender que pasa con los cambios de UV antes de decidir nada
*Se arma paso a paso: se corre un paso, se mira el resultado y recien ahi se escribe el siguiente

clear all
capture log close
log using "log_diagnostico_uv.txt", text replace

* CAMBIO 1: se agregan codigo_uv_rsh y muestra_t1 para el paso 2
pq use rut_inn anio id_uv_2024 mueve24 codigo_uv_rsh muestra_t1 using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_fertilidad_v60.parquet", clear

*PASO 1a: % de mujeres que cambia de UV 2024 respecto a su anio anterior (mueve24 parte en 2017; 2014-15 tienen la UV de 2016)
tab anio mueve24, row

*PASO 1b: cuantas UV 2024 tienen al menos una mujer cada anio, y cuantas mujeres
bys anio id_uv_2024: gen tag_uv = (_n == 1) if !missing(id_uv_2024)
tab anio if tag_uv == 1
tab anio
*RESULTADO 30/10: mueve24 19-26% en 2017-2022 (anios votados), 5% en 2023-2024 (directos). UV ~5.250 en 2014-2020 -> ~5.550 en 2021; mujeres crecen parejo

* CAMBIO 2: PASO 2a: lo mismo en la muestra de estimacion (UV sin jardin en 2014)
tab anio mueve24 if muestra_t1 == 1, row
tab anio if tag_uv == 1 & muestra_t1 == 1
*RESULTADO 30/10: igual que en la base completa

* CAMBIO 3: PASO 2b: entre las que "se mudan", cuantas tienen el MISMO codigo RSH que su obs anterior (mismo codigo + otra UV 2024 = artefacto del crosswalk)
sort rut_inn anio
by rut_inn: gen mismo_cod = (codigo_uv_rsh == codigo_uv_rsh[_n-1]) if _n > 1
tab anio mismo_cod if mueve24 == 1, row
*RESULTADO 30/10: mismo_cod = 50-75% en 2017-2021, 4% en 2022, 0.2% en 2023, 1% en 2024 -> la votacion traduce el mismo codigo a UV 2024 distintas en anios distintos

* CAMBIO 4: PASO 2c: todas las mujeres, % con el mismo codigo que su obs anterior + ver una mujer
tab anio mismo_cod, row
list anio codigo_uv_rsh id_uv_2024 if rut_inn == rut_inn[1]
*RESULTADO 30/10: >90% en 2017-2024 salvo 2022 (70%) -> los codigos RSH son estables entre anios

* CAMBIO 5: PASO 3: en el crosswalk, un mismo codigo que existe en t y t+1 ¿recibe la misma UV 2024? ¿los cambios vienen de los "division"/"ambiguo"?
use "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\shapes_uv/crosswalk_uv_final_2_puntocero.dta", clear
cap tostring codigo_uv, replace
*en los division se queda la UV que gana (igual que la linea 165 del crosswalk)
gsort anio codigo_uv -share
by anio codigo_uv: keep if _n == 1
keep anio codigo_uv id_uv_2024 tipo
tab anio tipo
*base del anio siguiente: se le resta 1 al anio para pegarla al anio t
preserve
replace anio = anio - 1
rename id_uv_2024 uv_sig
rename tipo tipo_sig
tempfile sig
save `sig'
restore
merge 1:1 anio codigo_uv using `sig', keep(match) nogen
gen cambia = (id_uv_2024 != uv_sig)
tab anio cambia, row
tab tipo cambia if anio <= 2021, row
tab tipo_sig cambia if anio <= 2021, row

log close
