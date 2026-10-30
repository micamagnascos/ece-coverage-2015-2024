*MAESTRO LUNES 26/10 - crosswalk nuevo (votacion 2021->2016) + base de cobertura NUEVA (319 tratadas), en un solo Stata
* OJO: reemplazar "RUTA" por la carpeta donde estan los do-files

*0. el crosswalk se corrio a mano antes (revisar tab anio tipo). OJO: el 09 lo lee desde cobertura/, no desde shapes_uv/
copy "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\shapes_uv/cobertura_crosswalk_final.dta" "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\cobertura/cobertura_crosswalk_final.dta", replace

*1. muestras (lo largo)
capture noisily do "RUTA/09_merge_muestra_v60.do"
capture noisily do "RUTA/11_primera_etapa_v60.do"

*2. estimaciones nivel UV (primera etapa primero)
capture noisily do "RUTA/03_primera_etapa_v60.do"
capture noisily do "RUTA/14_exposicion_pe.do"
capture noisily do "RUTA/02_laboral_v60.do"
capture noisily do "RUTA/01_fertilidad_v60.do"

*3. efecto fijo de mujer (lo mas lento, al final)
capture noisily do "RUTA/08a_ef_mujer_empleo.do"
capture noisily do "RUTA/08b_ef_mujer_fert.do"
