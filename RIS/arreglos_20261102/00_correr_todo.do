*CORRE TODO DE UNA VEZ -- 02/11/2026
*Si uno se cae, los demas siguen: al otro dia revisar cada log

clear all
* OJO: reemplazar RUTA_DOFILES por la carpeta donde estan tus do-files
global dof "RUTA_DOFILES"

capture noisily do "$dof/09_merge_muestra_v60.do"
capture noisily do "$dof/11_primera_etapa_v60.do"
capture noisily do "$dof/03_primera_etapa_v60.do"
capture noisily do "$dof/02_laboral_entrada.do"
capture noisily do "$dof/01_fertilidad_cw.do"
capture noisily do "$dof/08a_ef_mujer_empleo.do"
capture noisily do "$dof/08b_ef_mujer_fert.do"
capture noisily do "$dof/21_laboral_todas.do"
