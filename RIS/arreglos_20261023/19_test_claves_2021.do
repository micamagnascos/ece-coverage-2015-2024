*19 - TEST: ¿la clave 2021 del crosswalk (merge directo shapes-carto) coincide con seguir a las personas hasta 2022?
*2022 es confiable. Si en 2021 el merge directo esta mal, la votacion desde 2022 da OTRA uv -> acierto bajo
*rapido: lee solo 2 variables de carto 2021 y 2022

clear all
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
global shapes "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\shapes_uv"
global carto "Z:\BASES_COMUNES2\MDSF\RSH\Cartografia\UV_RSH"
capture log close
log using "$est/log_test_claves_2021.txt", text replace

*1. claves 2021 que usa el crosswalk (para comparar al final)
use codigo_uv id_uv_2024 using "$shapes/claves_2021.dta", clear
cap tostring codigo_uv, replace
rename id_uv_2024 uv_crosswalk
tempfile c21
save `c21'

*2. diccionario 2022 (confiable)
use codigo_uv id_uv_2024 using "$shapes/claves_2022.dta", clear
cap tostring codigo_uv, replace
tempfile dic
save `dic'

*3. uv 2024 de cada persona en 2022
use r*_inn uv_rsh using "$carto/2022/midesof_rsh_uv_202212.dta", clear
drop if missing(uv_rsh)
capture rename run_inn rut_inn
rename uv_rsh codigo_uv
cap tostring codigo_uv, replace
merge m:1 codigo_uv using `dic', keep(match) nogen
keep rut_inn id_uv_2024
tempfile ancla
save `ancla'

*4. personas 2021: a que uv 2024 cae la mayoria de cada codigo 2021
use r*_inn uv_rsh using "$carto/2021/midesof_rsh_uv_202112.dta", clear
drop if missing(uv_rsh)
capture rename run_inn rut_inn
rename uv_rsh codigo_uv
cap tostring codigo_uv, replace
merge 1:1 rut_inn using `ancla', keep(match) nogen
contract codigo_uv id_uv_2024
bys codigo_uv: egen double nvot = total(_freq)
gen double share = _freq / nvot
gsort codigo_uv -_freq
by codigo_uv: keep if _n == 1
rename id_uv_2024 uv_voto

*5. comparar
merge 1:1 codigo_uv using `c21'
tab _merge
keep if _merge == 3
gen acierto = (uv_voto == uv_crosswalk)

* REVISAR (anotar las 3 Mean): % de codigos 2021 donde coinciden, ponderado por personas, y share de la mayoria
sum acierto
sum acierto [fw = nvot]
sum share, d

log close
