* LIMPIEZA BASE HIJOS 2025 - 2
* Autora: Micaella Magnasco 
* julio 2026 


* base històrica que contiene todos los hijos que ha tenido cada persona hasta diciembre 2025
* run_padre_falso, run_hijo_falso, fecha_nac_hijo Formato AAAAMM; fecha_def_hijo Formato AAAAMM, sexo_hijo;String;1;F/M;"M=Masculino; F=Femenino; I=Indefinido", nac_hijo;Nacionalidad hijo/a;String;"C=Chileno; E=Extranjero; N=Nacionalizado; A=Apatriado; "" "" no es conocida", est_civil_hijo
*Es una fila por nacimiento!!!


*** 
/*
Objetivo: limpiar la base hijos y generar las bases necesarias para la var de resultado fertilidad 
Outputs:
- base hijos_filtrado_2016_2024: listado de hijos de las madres de la base panel rsh_uv -> necesaria para verificar matricula 
- base hijos_panel: nacimientos 2013-2024 por año para las mujeres de la muestra, junto con var de stock de hijos menores a 5 cada año -> para matchear a base panel como var de resultado 

*/ 

clear all 
ssc install gtools, replace
global hijos_2025 "Z:\BASES_COMUNES2\SRCeI\Hijos\2025"
global salida "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\hijos"


* EDITAR ESTO: quiero que solamente sea si es que tuvo o no hijos en el periodo nomas 

describe using "$hijos_2025\srcei_hijos_202512_inn"

use run_padre_inn run_hijo_inn fecha_nac_hijo fecha_def_hijo nacionalidad_hijo using "$hijos_2025\srcei_hijos_202512_inn", clear
describe 

*dejamos solo el año de nacimiento 
gen anio_nac_hijo = floor(fecha_nac_hijo/100)
*tab anio_nac_hijo if anio_nac_hijo >2015

*dejamos solo el año de defunciòn 
gen anio_def_hijo = floor(fecha_def_hijo/100)

rename run_padre_inn rut_inn
drop fecha_nac_hijo fecha_def_hijo

*mergeamos con la lista de ruts del panel 2016_2024
merge m:1 rut_inn using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra\ruts_panel_2016_2024.dta", keep(match) nogenerate

*guardamos el listado de hijos para mujeres de la muestra 2016-2024 para usarlo despuès para la primera etapa -> ver cambios en matrìcula de esos hijos 
compress
save "$salida\hijos_filtrado_2016_2024.dta", replace 




*GENERAMOS VARIABLES DE INTERÈS
***************************

*FLUJO -> tuvo hijo 
use "$salida\hijos_filtrado_2016_2024.dta", clear 
gcollapse (count) n_nacim=run_hijo_inn, by(rut_inn anio_nac_hijo)
format rut_inn %20.0f
gen tuvo_hijo = 1
rename anio_nac_hijo anio 
*esto es si alguna mujer tuvo màs de un hijo en el parto, pero no es relevante 
tab n_nacim
drop n_nacim
*dejamos solo los nacimientos que nos interesan (a partir de 2013 para pre trends)
keep if inrange(anio, 2013,2025)
hashsort rut_inn anio

compress 
save "$salida\tuvo_hijo.dta", replace 



*STOCK -> hijos menores a 5 
use "$salida\hijos_filtrado_2016_2024.dta", clear 

*n de hijos menores a 5 (stock)
gen exp_ini= anio_nac_hijo
gen exp_fin = anio_nac_hijo + 4 // final de la ventana de exposiciòn, ultimo año en el que ese hijo cuenta como menor a 5 

*si es que el niño fallecio antes de cumplir 5, se corta la ventana en el año de la muerte 
replace exp_fin = anio_def_hijo if !missing(anio_def_hijo) & anio_def_hijo < exp_fin 

*lo màs antiguo que me interesa observar son nacimientos hasta 2008, porque ahi tendrìan 6 en 2013, que me sirve para los años de pre trends. Nacimientos previos a 2008 no me interesan 
*modificar si es que sse decide un pre periodo distinto a 2012 (3 años de pre trends)
drop if exp_fin < 2013
replace exp_fin = min(exp_fin,2024)

*n de años que dira la ventana de exposiciòn de ese hijo 
gen n_years = exp_fin - exp_ini + 1
count if n_years < 1
* 33 obs con fecha de muerte anterior al nacimiento ??
drop if n_years < 1 


keep rut_inn run_hijo_inn exp_ini n_years
*hacemos el expand para hacer el panel 
expand n_years 
bysort rut_inn run_hijo_inn: gen anio = exp_ini + _n - 1

*se colapsa por mujer-año y cuenta cuantos hijos distintos caen en el grupo menor a 5 
gcollapse (count) n_hijos_menor5 = run_hijo_inn, by(rut_inn anio)

gduplicates report rut_inn anio

save "$salida\stock_hijos_menor_5.dta", replace 




*MERGE FINAL
use "$salida\tuvo_hijo.dta"
merge 1:1 rut_inn anio using "$salida\stock_hijos_menor_5.dta"

keep if _merge == 3 
drop _merge 

sort rut_inn anio
gduplicates report rut_inn anio
gduplicates report rut_inn

label variable tuvo_hijo "Tuvo hijo ese año (1=si, 0=no)"
label variable n_hijos_menor5 "Stock de hijos vivos menores a 5 años en el año"

compress 
save "$salida\hijos_panel.dta", replace







