*17 - REHACE cobertura_crosswalk_final.dta con la base de cobertura NUEVA (319 tratadas)
*es solo el final de crosswalk_cobertura_uvs.do: parte desde el crosswalk ya guardado (rapido, minutos)
*HAY QUE CORRERLO ANTES DEL 09: el 09 saca "tratada" de este archivo y el merge con update NO la reemplaza

global shapes "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\shapes_uv"

use "$shapes/CROSSWALK_RSH_UVACTUAL.dta", clear

merge m:1 id_uv_2024 anio using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\cobertura/base_cobertura_cp"

drop if anio == 2015

tab anio _merge
tab tratada _merge

keep if _merge == 3

* REVISAR: ~259 (tratada=1 solo en la fila del año de apertura; sin 2015 quedan 268, menos las que no hacen merge). NO distingue base nueva de antigua: eso se revisa con tab g1 if tratada==1 en la base (2015: 51 nueva, 179 antigua)
gunique id_uv_2024 if tratada == 1

rename codigo_uv codigo_uv_rsh

keep codigo_uv_rsh id_uv_2024 anio t_* n_* tratada
drop n_votantes
order anio codigo_uv_rsh id_uv_2024

duplicates report anio id_uv_2024
duplicates report anio codigo_uv_rsh

save "$shapes/cobertura_crosswalk_final.dta", replace

* OJO: el 09 lee este archivo desde cobertura/, no desde shapes_uv/ -> copiarlo
copy "$shapes/cobertura_crosswalk_final.dta" "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\cobertura/cobertura_crosswalk_final.dta", replace
