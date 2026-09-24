*CREACIÓN MUESTRA BASE CORTO PLAZO 2016-2024
*Micaella Magnasco
*julio 2026 

* Objetivo: unir información de RSH con información de su unidad vecinal. Tambié filtrar por -> solo mujeres mayores de 18 años y menores de ???

* 2016-2025 -> RSH

* guardamos info de uv, sexo, edad, oficio/trabajo e ingresos
* Formato: una base por semestre, vamos a usar para cada año las bases de diciembre 

clear all 
ssc install distinct
ssc install gtools, replace 
gtools, upgrade 

global MDS "Z:\BASES_COMUNES2\MDSF"
global RSH "$MDS\RSH"
global FPS "$MDS\FPS"
global salida "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra"


************************************************
*FPS (2014-2015)
*FICHA DE PROTECCIÒN SOCIAL 

*2014
pq use "$FPS/2014/midesof_fps_201412_inn.parquet", clear

describe, fullnames 

rename annio anio 
rename run_inn rut_inn
rename comuna_ine grupfami_comunaine
rename c_uv grupfami_unidadvecinal
rename c_zona grupfami_c_zona 
destring grupfami_c_zona, replace
rename fecha_nacimiento per_fechanacimiento
rename sexo per_sexo_id
codebook per_sexo_id
destring per_sexo_id, replace
rename edad per_edad
destring per_edad, replace
rename nacionalidad per_nacionalidad_id
destring per_nacionalidad_id, replace
rename c_parentesco per_fic_parentescoid 
rename pareja per_fic_numpareja
rename i3 per_fic_pueblooriginario
rename e1 per_fic_asisteestabeducacional
rename e2 per_fic_noasistemotivo
rename e3 per_fic_curso
rename e4 per_fic_tipoeducacion_id 
rename o3 per_fic_trabaja
rename o10a per_fic_ocupacionactual	
rename o10b per_fic_codigosrama
rename o10c per_fic_temppermanen
rename o10d per_fic_codigocontrato
rename o10e per_fic_relacioncontractual
rename o10f per_fic_horastrabajo
rename ingreso_anual per_fic_ingresoanual 
rename ingreso_jubilacion per_fic_ingresojubilacion
rename ingreso_otros per_fic_ingresootros
rename fecha_aplicacion grupfami_fecha_encuesta 

keep  anio folio_inn grupfami_c_zona grupfami_comunaine grupfami_unidadvecinal rut_inn per_fechanacimiento per_sexo_id per_edad per_nacionalidad_id per_fic_parentescoid per_fic_parentesco per_fic_numpareja per_fic_pueblooriginario per_fic_asisteestabeducacional per_fic_noasistemotivo per_fic_curso per_fic_tipoeducacion_id per_fic_trabaja per_fic_ocupacionactual per_fic_codigosrama per_fic_temppermanen per_fic_codigocontrato per_fic_relacioncontractual per_fic_horastrabajo per_fic_ingreso* grupfami_fecha_encuesta puntaje 

	
foreach v of varlist anio rut_inn per_edad folio_inn grupfami_c_zona per_fechanacimiento per_sexo_id per_nacionalidad_id per_fic_numpareja per_fic_pueblooriginario per_fic_asisteestabeducacional per_fic_noasistemotivo per_fic_curso per_fic_tipoeducacion_id per_fic_trabaja per_fic_ocupacionactual per_fic_codigosrama per_fic_temppermanen per_fic_codigocontrato per_fic_relacioncontractual per_fic_horastrabajo per_fic_ingresoanual per_fic_ingresojubilacion per_fic_ingresootros grupfami_fecha_encuesta {
	cap destring `v', replace 
	}

foreach v of varlist per_fic_codigocontrato per_fic_relacioncontractual per_fic_horastrabajo per_fic_ingreso* grupfami_fecha_encuesta puntaje  {
	destring `v', replace 
	}
	
describe, fullnames 

*duplicates report rut_inn 
*igual hay hartos pero chao, desde el MDs me explicanq ue la FPS puede tener varios errores
duplicates drop rut_inn, force

*no puedo hacer variables de totales por UV porque la variable de "unidad vecinal" no es confiable ni unica 

*filtros de sexo y edad

*dejamos solo a las mujeres 
codebook per_sexo_id
destring per_sexo_id, replace 
keep if per_sexo_id == 2 

*dejamos a las edades necesarias 
destring per_edad, replace 
keep if per_edad >= 18 & per_edad <= 70

count
*  4,476,584 obs 
save "$salida\fps_2014.dta", replace




*2015
pq use "$FPS/2015/midesof_fps_201512_inn.parquet", clear

rename annio anio 
recast int anio, force
rename run_inn rut_inn
rename comuna_ine grupfami_comunaine
rename c_uv grupfami_unidadvecinal
rename c_zona grupfami_c_zona 
rename fecha_nacimiento per_fechanacimiento
rename sexo per_sexo_id
rename edad per_edad
rename nacionalidad per_nacionalidad_id
rename c_parentesco per_fic_parentescoid 
rename pareja per_fic_numpareja
rename i3 per_fic_pueblooriginario
rename e1 per_fic_asisteestabeducacional
rename e2 per_fic_noasistemotivo
rename e3 per_fic_curso
rename e4 per_fic_tipoeducacion_id 
rename o3 per_fic_trabaja
rename o10a per_fic_ocupacionactual	
rename o10b per_fic_codigosrama
rename o10c per_fic_temppermanen
rename o10d per_fic_codigocontrato
rename o10e per_fic_relacioncontractual
rename o10f per_fic_horastrabajo
rename ingreso_anual per_fic_ingresoanual 
rename ingreso_jubilacion per_fic_ingresojubilacion
rename ingreso_otros per_fic_ingresootros
rename fecha_aplicacion grupfami_fecha_encuesta 

keep  anio folio_inn grupfami_c_zona grupfami_comunaine grupfami_unidadvecinal rut_inn per_fechanacimiento per_sexo_id per_edad per_nacionalidad_id per_fic_parentescoid per_fic_parentesco per_fic_numpareja per_fic_pueblooriginario per_fic_asisteestabeducacional per_fic_noasistemotivo per_fic_curso per_fic_tipoeducacion_id per_fic_trabaja per_fic_ocupacionactual per_fic_codigosrama per_fic_temppermanen per_fic_codigocontrato per_fic_relacioncontractual per_fic_horastrabajo per_fic_ingreso* grupfami_fecha_encuesta puntaje 

foreach v of varlist anio rut_inn per_edad folio_inn grupfami_c_zona per_fechanacimiento per_sexo_id per_nacionalidad_id per_fic_numpareja per_fic_pueblooriginario per_fic_asisteestabeducacional per_fic_noasistemotivo per_fic_curso per_fic_tipoeducacion_id per_fic_trabaja per_fic_ocupacionactual per_fic_codigosrama per_fic_temppermanen per_fic_codigocontrato per_fic_relacioncontractual per_fic_horastrabajo per_fic_ingresoanual per_fic_ingresojubilacion per_fic_ingresootros grupfami_fecha_encuesta {
	cap destring `v', replace 
	}

foreach v of varlist per_fic_codigocontrato per_fic_relacioncontractual per_fic_horastrabajo per_fic_ingreso* grupfami_fecha_encuesta puntaje  {
	destring `v', replace 
	}

*duplicates report rut_inn 
*igual hay hartos pero chao, desde el MDs me explicanq ue la FPS puede tener varios errores
duplicates drop rut_inn, force

*no puedo hacer variables de totales por UV porque la variable de "unidad vecinal" no es confiable ni unica 

*filtros de sexo y edad

*dejamos solo a las mujeres 
codebook per_sexo_id
destring per_sexo_id, replace 
keep if per_sexo_id == 2 

*dejamos a las edades necesarias 
destring per_edad, replace 
keep if per_edad >= 18 & per_edad <= 70

count
*  4,476,584 obs 
save "$salida\fps_2015.dta", replace


************************************************
*RSH (2016-2023)
*REGISTRO SOCIAL DE HOGARES 

forvalues y = 2016/2023 {
	pq use "$RSH/`y'/midesof_rsh_`y'12_inn.parquet", clear

	*nos quedamos solo con var de interés
keep anio folio_inn grupfami_c_zona grupfami_comunaine grupfami_unidadvecinal rut_inn per_fechanacimiento per_sexo_id sexo per_edad per_nacionalidad_id per_fic_parentescoid per_fic_parentesco per_fic_numpareja per_fic_pueblooriginario per_fic_asisteestabeducacional per_fic_noasistemotivo per_fic_curso per_fic_tipoeducacion_id per_fic_trabaja per_fic_ocupacionactual per_fic_codigosrama per_fic_temppermanen per_fic_codigocontrato per_fic_relacioncontractual per_fic_horastrabajo per_fic_buscotrabajo per_fic_nobuscotrabajomotivo per_fic_ingreso* grupfami_fecha_encuesta calc_* fecha_calificacion ingreso_transformado

	*eliminamos duplicados -> casi nunca hay 
	duplicates drop rut_inn, force
	
	if `y' <=  2021 {
		merge 1:1 rut_inn using "$RSH/Cartografia/UV_RSH/`y'/midesof_rsh_uv_`y'12.dta" 
		tab _merge
		keep if _merge == 3
		drop _merge 
		}
		
	else {
		rename rut_inn run_inn 
		merge 1:1 run_inn using "$RSH/Cartografia/UV_RSH/`y'/midesof_rsh_uv_`y'12.dta" 
		tab _merge
		keep if _merge == 3
		drop _merge 
		rename run_inn rut_inn 
		}
		
	format uv_rsh  %15.0f
	drop if missing(uv_rsh)
		
	*VARIABLES RELEVANTES A NIVEL UV COMPLETA 
	
    *poblaciòn total
	egen pob_total_uv = count(rut_inn), by(uv_rsh)
	label variable pob_total_uv "Poblacion total de la UV"
	
	*cantidad de hogares 
	bysort uv_rsh folio_inn: gen _tag= (_n==1)
	egen n_hogares_uv = sum(_tag), by(uv_rsh)
	label variable n_hogares_uv "Numero de hogares en la UV"
	drop _tag

	*densidad de niños 0-5
	gen es_nino_0_5 = (per_edad <= 5)
	egen n_ninos_0_5_uv = sum(es_nino_0_5), by(uv_rsh)
	gen densidad_ninos_uv = n_ninos_0_5_uv / pob_total_uv
	label variable densidad_ninos_uv "Densidad niños 0-5/ pob total UV"
	drop es_nino_0_5 
	
	*CSE promedio UV 
	egen cse_prom_uv = mean(calc_quintil_validacion2), by(uv_rsh)
	label variable cse_prom_uv "CSE promedio de la UV"
	
	*filtros de sexo y edad
	keep if per_sexo_id == 2 
	keep if per_edad >= 18 & per_edad <= 70
	
	*generamos var anio 
	gen anio = `y'
	order anio rut_inn
	
	*guardar año individual 
	save "$salida\rsh_uv_`y'.dta", replace
	
	di "Año `y' listo: `c(N) obs'"
	
	}


	
*RSH (2024)
pq use "$RSH/2024/midesof_rsh_202412_inn.parquet", clear

*nos quedamos solo con var de interés
keep folio_inn grupfami_c_zona grupfami_comunaine grupfami_unidadvecinal run_inn per_fechanacimiento per_sexo_id sexo per_edad per_nacionalidad_id per_fic_parentescoid per_fic_parentesco per_fic_numpareja per_fic_pueblooriginario per_fic_asisteestabeducacional per_fic_noasistemotivo per_fic_curso per_fic_tipoeducacion_id per_fic_trabaja per_fic_ocupacionactual per_fic_codigosrama per_fic_temppermanen per_fic_codigocontrato per_fic_relacioncontractual per_fic_horastrabajo per_fic_buscotrabajo per_fic_nobuscotrabajomotivo per_fic_ingreso* grupfami_fecha_encuesta calc_* fecha_calificacion ingreso_transformado

*eliminamos duplicados -> casi nunca hay 
duplicates drop run_inn, force
	
merge 1:1 run_inn using "$RSH/Cartografia/UV_RSH/2024/midesof_rsh_uv_202412.dta" 
tab _merge
keep if _merge == 3
drop _merge 
rename run_inn rut_inn 
		
format uv_rsh  %15.0f
drop if missing(uv_rsh)
		
*VARIABLES RELEVANTES A NIVEL UV COMPLETA 
	
*poblaciòn total
egen pob_total_uv = count(rut_inn), by(uv_rsh)
label variable pob_total_uv "Poblacion total de la UV"
	
*cantidad de hogares 
bysort uv_rsh folio_inn: gen _tag= (_n==1)
egen n_hogares_uv = sum(_tag), by(uv_rsh)
label variable n_hogares_uv "Numero de hogares en la UV"
drop _tag

*densidad de niños 0-5
gen es_nino_0_5 = (per_edad <= 5)
egen n_ninos_0_5_uv = sum(es_nino_0_5), by(uv_rsh)
gen densidad_ninos_uv = n_ninos_0_5_uv / pob_total_uv
label variable densidad_ninos_uv "Densidad niños 0-5/ pob total UV"
drop es_nino_0_5 
	
*CSE promedio UV 
egen cse_prom_uv = mean(calc_quintil_validacion2), by(uv_rsh)
label variable cse_prom_uv "CSE promedio de la UV"
	
*filtros de sexo y edad
keep if per_sexo_id == 2 
keep if per_edad >= 18 & per_edad <= 70
	
*generamos var anio 
gen anio = 2024
order anio rut_inn
	
*guardar año individual 
save "$salida\rsh_uv_2024.dta", replace
	

	

*hacemos el append 
clear all 
forvalues i = 2016/2024 {
	append using "$salida\rsh_uv_`i'.dta", force
	}
	
sort rut_inn anio 
order anio rut_inn uv_rsh uv_nom per_edad
format rut_inn %15.0f
describe, fullnames
drop sexo per_fic_parentesco fecha_calificacion


*generamos var cambia_uv -> 1 si la mujer aparece en mas de una uv distinta a lo largo del panel, 0 si se mantiene fija en todos los años 
gegen min_uv = min(uv_rsh), by(rut_inn)
gegen max_uv = max(uv_rsh), by(rut_inn)

gen cambia_uv = (min_uv != max_uv)
drop min_uv max_uv

gegen tag_mujer = tag(rut_inn)
tab cambia_uv if tag_mujer==1


compress
save "$salida\rsh_uv_panel_2016_2024.dta", replace


*UNIMOS INFO DE RSH 
use "$salida\rsh_uv_panel_2016_2024.dta", clear

append using "$salida\fps_2014.dta", force 
append using "$salida\fps_2015.dta", force 

*sort rut_inn anio 
order anio rut_inn uv_rsh uv_nom per_edad
format rut_inn %15.0f
describe, fullnames
drop per_fic_parentesco 

tab anio 

compress
save "$salida\fps_rsh_uv_panel_2014_2024.dta", replace


keep rut_inn
duplicates drop 
count
compress 
save "$salida\ruts_panel_2014_2024.dta", replace















	