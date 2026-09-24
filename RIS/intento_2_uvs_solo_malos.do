* IDEA 2 CROSSWALK UNIDADES VECINALES 
/*
Objetivo final: hacer un crosswalk que permita asignar a cada persona su uv de cada año, la uv que le corresponderìa en 2024 y con ello la cobertura de educ parv -> tratamiento 
Problema: puente entre shapes y carto rsh no es el mismo, no se pueden unir esas informaciones 
Idea: con la informaciòn de carto rsh, ir "descubriendo" los còdigos de las uv usando las claves correctas (desde 2021 en adelante). La idea general es que, paritiendo de un par cod uv año bueno x cod 2024, vemos donde vive la mayoria de las personas de esa uv en el "año malo", y asignamos ese cod_uv_2024 a esa uv de "año malo".

Inputs: carto rsh, shapes que indica la uv de 2024 correspondiente a cada uv de cada año, y la base de cobertura de educ parvularia asignada a 2024.

Output: crosswalk completo -> "$shapes/cobertura_crosswalk_final.dta"
*/

clear all
set more off
*ssc install gtools

global shapes "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\shapes_uv"
global carto "Z:\BASES_COMUNES2\MDSF\RSH\Cartografia\UV_RSH"

*UNIÒN MERGE NORMAL -> generamos las claves de 2022 en adelante 
use "$shapes/uvs_madre.dta", clear
rename id_uv_origen codigo_uv 
duplicates report anio codigo_uv
merge 1:1 codigo_uv anio using "$shapes/carto_uvs.dta"

tab anio _merge 
*ojo, siempre carto tiene mas que shapes 


keep if _merge == 3
keep if inlist(anio, 2017, 2020, 2021, 2022, 2023, 2024)
drop _merge 
tab anio 

describe, fullnames 

keep anio codigo_uv id_uv_2024 comuna_id flag_division
gen double share = 1 
gen tipo = "verdad"
duplicates drop anio codigo_uv, force 
save "$shapes/crosswalk_verdad.dta", replace


foreach y in 2017 2020 2021 2022 2023 2024 {
	preserve 
	keep if anio == `y'
	save "$shapes/claves_`y'.dta", replace
	restore
}

global VERDAD "$shapes/crosswalk_verdad.dta"
global VCOD "codigo_uv"
global VUV "id_uv_2024"

*global NMIN 20
global SALTO 0.70
global SDIV 0.20
global SALTO_DIVISON 0.85



*decodificamos 
foreach t of numlist 2019 2018 2016 {
	local ay = `t' + 1 
	local mt = cond(`t' == 2017, "06", "12")
	
	*claves 
	use "$shapes/claves_`ay'.dta", clear 
	keep if inlist(tipo,"verdad","limpio")
	count if tipo == "verdad"
	keep codigo_uv id_uv_2024
	duplicates drop codigo_uv, force 
	cap tostring codigo_uv, replace
	count
	tempfile dic 
	save "`dic'"
	
	*ancla nivel persona
	use r*_inn uv_rsh using "$carto/`ay'/midesof_rsh_uv_`ay'12.dta", clear
	drop if missing(uv_rsh)
	capture rename run_inn rut_inn
	rename uv_rsh codigo_uv
	*duplicates drop rut_inn, force 
	cap tostring codigo_uv, replace
	merge m:1 codigo_uv using "`dic'", keep(match) nogen 
	keep rut_inn id_uv_2024
	tempfile ancla
	save "`ancla'"
	
	*personas del año t
	use r*_inn uv_rsh using "$carto/`t'/midesof_rsh_uv_`t'`mt'.dta", clear
	drop if missing(uv_rsh)
	capture rename run_inn rut_inn
	rename uv_rsh Z
	cap tostring Z, replace
	*duplicates drop rut_inn, force 
	merge 1:1 rut_inn using "`ancla'", keep(match) nogen 
	drop rut_inn 
	
	*votacion
	contract Z id_uv_2024
	bysort Z: egen double nvot = total(_freq)
	gen double share = _freq / nvot 
	
	gsort Z -_freq
	by Z: keep if _n <=2
	by Z: gen double s1 = share[1]
	by Z: gen str40 u1 = id_uv_2024[1]
	by Z: gen double s2 = share[2]
	by Z: gen str40 u2 = id_uv_2024[2]
	by Z: keep if _n == 1
	replace s2 = 0 if missing(s2)
	
	gen tipo = "ambiguo"
	*replace tipo = "insuf" if nvot < $NMIN
	replace tipo = "limpio" if tipo == "ambiguo" & s1 >= $SALTO
	replace tipo = "division" if tipo == "ambiguo" & s1+s2 >= $SALTO & s2 >= $SDIV
	
	tab tipo 
	count if s1 >= 0.70
	count if s1 >= 0.75
	count if s1 >= 0.80
	count if s1 >= 0.85
	
	*armar claves (2 filas si division)
	drop id_uv_2024 share
	expand 2 if tipo == "division", gen(seg)
	gen str40 id_uv_2024 = u1 
	gen double share = s1
	replace id_uv_2024 = u2 if seg == 1
	replace share = s2 if seg == 1 
	
	gen int anio = `t'
	rename Z codigo_uv
	rename nvot n_votantes 
	keep anio codigo_uv id_uv_2024 share n_votantes tipo 
	save "$shapes/claves_`t'.dta", replace
	
	di as res "anio `t':"
	tab tipo

	}
	
	
	
*CROSSWALK FINAL
	
use "$shapes/claves_2016.dta", clear 
foreach y in 2017 2018 2019 2020 2021 2022 2023 2024 {
	append using "$shapes/claves_`y'.dta", force
}
	
gen byte usable = inlist(tipo, "verdad", "limpio", "division")
sort anio codigo_uv 
save "$shapes/crosswalk_uv_final_2_puntocero.dta", replace 
	
tab anio tipo
tab anio usable

duplicates report anio codigo_uv
duplicates tag anio codigo_uv, gen(_dup)
*browse if _dup > 0

*eliminamos los de division que pierden 
gsort anio codigo_uv -share 
by anio codigo_uv: drop if tipo == "division" & _n == 2 

drop usable _dup tipo

tab anio

destring id_uv_2024, replace
format %15.0f id_uv_2024
	
save "$shapes/CROSSWALK_RSH_UVACTUAL.dta", replace 
/*


*/

merge m:1 id_uv_2024 anio using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\cobertura/base_cobertura_cp"

drop if anio == 2015

tab _merge
tab anio _merge
*solo el 2% no hacen merge, concentrado entre 2017 y 2020

tab tratada _merge
*pierdo 16 uv tratadas :(



tab anio tratada 




keep if _merge == 3 

rename codigo_uv codigo_uv_rsh

keep codigo_uv_rsh id_uv_2024 anio t_* n_* tratada
drop n_votantes
order anio codigo_uv_rsh id_uv_2024

duplicates report anio id_uv_2024
duplicates report anio codigo_uv_rsh

save "$shapes/cobertura_crosswalk_final.dta", replace 

	