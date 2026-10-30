*MAESTRO NOCHE LUNES 19/10 -- correr en Stata 1 apenas termine el panel RSH
*construye las muestras nuevas en cadena. capture noisily = si uno falla, sigue con el siguiente
*ANTES DE CORRER: en el 11 poner * delante de las 2 lineas "ssc install" (sin internet fallan y se cae todo el 11)
* OJO: reemplazar "RUTA" por la carpeta donde tienes guardados los do-files

capture noisily do "RUTA/09_merge_muestra_v60.do"
capture noisily do "RUTA/11_primera_etapa_v60.do"
