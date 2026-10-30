*MUDANZAS 2022 (pedido profes): ¿son mudanzas reales o cambio de cartografia? -- 19/10/2026
*idea: si en 2022 la mujer "se muda" de UV 2024 pero su codigo_uv_rsh NO cambia -> no se movio, es el mapa
*OPCIONAL, solo si sobra tiempo el martes

clear all
do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_mudanzas22_20261019.txt", text replace

use rut_inn anio codigo_uv_rsh mueve24 using "$muestra/muestra_fertilidad_v60.dta", clear
sort rut_inn anio
by rut_inn: gen cambia_cod = (codigo_uv_rsh != codigo_uv_rsh[_n-1]) if _n > 1 & !missing(mueve24)

* REVISAR: % que se muda cada año (2022 ~26%?)
tab anio mueve24, row
* REVISAR: entre las que "se mudan", % que tambien cambia codigo RSH. Si en 2022 es mucho mas bajo -> es el mapa
tab anio cambia_cod if mueve24 == 1, row
* REVISAR: % que cambia codigo RSH cada año (si 2022 tambien salta -> el RSH recodifico ese año)
tab anio cambia_cod, row

log close
