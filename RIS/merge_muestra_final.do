*base completa muestra 

clear all 

*abrimos muestra total de mujeres rsh - fps
use "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/fps_rsh_uv_panel_2014_2024.dta", clear

rename uv_rsh codigo_uv_rsh
tostring codigo_uv_rsh, replace 

describe, fullnames 


*UNIMOS INFO DE HIJOS 
merge 1:1 anio rut_inn using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\hijos/hijos_panel.dta"

*merge == 1 : no cumplen con alguna de las caract o tiene info missing -> tuvo hijo o tiene hijo menor a 5 
* no se si es por missing o es porque no tiene info, aunque la base hijos debiese documentar a todo chile 
*merge == 2 : esta en la base hijos pero no en el RSH (debe estar sesgada esa parte a altos ingresos)
drop if _merge == 2 
replace tuvo_hijo = 0 if _merge == 1
replace n_hijos_menor5 = 0 if _merge == 1
drop _merge 

gen tiene_hijo_menor5 = 1 if n_hijos_menor5 > 0
replace tiene_hijo_menor5 = 0 if missing(tiene_hijo_menor5)



*ELIMINAMOS LAS OBS QUE NO NOS SIRVEN PARA NINGUNA DE LAS DOS MUESTRAS -> año en que mujer es mayor a 49 y no tiene hijo menor a 5 (para disminuir obs y peso base solamente)
drop if per_edad > 49 & n_hijos_menor5 == 0 
count



*UNIMOS INFO DE COBERTURA y UVS
merge m:1 anio codigo_uv_rsh using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\cobertura/cobertura_crosswalk_final.dta"

tab anio tratada, m

*!!!!!
*botar las personas que no tengan uv de 2024 y con ello tratamiento, menos las de 2014 y 2015 
drop if missing(id_uv_2024) & !inlist(anio,2014,2015)
tab anio tratada, m

describe, fullnames 


*pegamos info de uv contemporànea de 2016 para 2014 y 2015 
preserve 
keep if anio == 2016 
keep rut_inn id_uv_2024 codigo_uv_rsh uv_nom grupfami_c_zona grupfami_comunaine pob_total_uv densidad_ninos_uv n_hogares_uv n_ninos_0_5_uv  

rename id_uv_2024 id_uv_2024_16
rename codigo_uv_rsh codigo_uv_rsh_16
rename uv_nom uv_nom16
rename grupfami_c_zona grupfami_c_zona16
rename grupfami_comunaine grupfami_comunaine16
rename pob_total_uv pob_total_uv16 
rename densidad_ninos_uv densidad_ninos_uv16
rename n_hogares_uv n_hogares_uv16
rename n_ninos_0_5_uv n_ninos_0_5_uv16

duplicates drop rut_inn, force 
tempfile ancla2016
save `ancla2016'
restore 

merge m:1 rut_inn using `ancla2016', keep(master match) nogen 

foreach v in uv_nom grupfami_c_zona grupfami_comunaine pob_total_uv densidad_ninos_uv n_hogares_uv n_ninos_0_5_uv {
	replace `v' = `v'16 if inlist(anio, 2014, 2015) & missing(`v')
}

replace id_uv_2024 = id_uv_2024_16 if inlist(anio, 2014, 2015) & missing(id_uv_2024)
replace codigo_uv_rsh = codigo_uv_rsh_16 if inlist(anio, 2014, 2015) & codigo_uv_rsh == "."

drop id_uv_2024_16 codigo_uv_rsh_16 uv_nom16 grupfami_c_zona16 grupfami_comunaine16 pob_total_uv16 densidad_ninos_uv16 n_hogares_uv16 n_ninos_0_5_uv16

sort anio

*cobertura propia de 2014 y 2015 
drop _merge 

rename id_uv_2024 t_id_uv_ca

merge m:1 anio t_id_uv_ca using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\cobertura/base_cobertura_cp.dta", keepusing(t_* n_* tratada stock_base muestra_t1 g1 grupo_t1 post_t1 rel_t1) update keep(master match match_update match_conflict)

rename t_id_uv_ca id_uv_2024 

tab anio _merge

tab anio if missing(codigo_uv_rsh) 
tab anio if codigo_uv_rsh == "."
drop if missing(codigo_uv_rsh)
*solamente son de 2014 y 2015 -> son las personas que no estaban en 2016, los eliminamos 

count
tab anio
tab anio tratada

tab per_edad
tab anio tiene_hijo_menor5


drop _merge 





**************************************************************
*SEPARAMOS AMBAS MUESTRAS 

****************************************************************************
*MUESTRA PARA M LABORAL 
*solo mujeres que tengan hijos menores a 5 años ese año especìfico
preserve 

keep if tiene_hijo_menor5 == 1


*PEGAMOS INFO DE RENTAS 
rename anio year
merge 1:1 year rut_inn using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\rentas/rentas_rut_panelfinal.dta"
rename year anio 
*borramos a las personas que estan solo en rentas 
drop if _merge == 2 
drop _merge


*PEGAMOS INFO DE COTIZACIONES
merge 1:1 anio rut_inn using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\cotizaciones/panel_cotizaciones_run_anio.dta"
*borramos a las personas que estan solo en cotizaciones 
drop if _merge == 2 
drop _merge

compress
save "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_laboral_ingresos.dta", replace 
restore




****************************************************************************

*MUESTRA PARA FERTILIDAD -> 18 A 49 AÑOS 
*ya esta restringido para mujeres mayores de 18, hay que eliminar a las mayores de 49, para cualquier año, borra las obs de las mujeres en ese año si es que ese año tienen màs de 49
describe, fullnames 
preserve
drop if per_edad > 49 
*nos quedamos solo con las de fertilidad 
drop per_sexo_id per_fic_asisteestabeducacional per_fic_noasistemotivo per_fic_ocupacionactual per_fic_codigosrama per_fic_temppermanen per_fic_codigocontrato per_fic_relacioncontractual per_fic_horastrabajo grupfami_fecha_encuesta
count
save "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_fertilidad.dta", replace 
restore


*MUESTRA TOTAL
keep anio rut_inn codigo_uv_rsh id_uv_2024 tratada stock_base muestra_t1 g1 grupo_t1 post_t1 rel_t1
gduplicates report rut_inn anio 
*OJO ACA
duplicates drop rut_inn anio, force
compress
save "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_completa_ruts_trat.dta", replace 






