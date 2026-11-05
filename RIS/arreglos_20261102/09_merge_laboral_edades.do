*base completa muestra 

clear all 
*ssc install gtools, replace 


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
* CAMBIO 9: ninguna madre sale por edad. Solo salen los anios con mas de 49 de mujeres que NUNCA tuvieron hijo menor de 5 (no estan en la muestra laboral)
bys rut_inn: egen alguna_hijo5 = max(tiene_hijo_menor5)
drop if per_edad > 49 & alguna_hijo5 == 0
drop alguna_hijo5
count



*UNIMOS INFO DE COBERTURA y UVS
merge m:1 anio codigo_uv_rsh using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\cobertura/cobertura_crosswalk_final.dta"

*tab anio tratada, m

*!!!!!
*botar las personas que no tengan uv de 2024 y con ello tratamiento, menos las de 2014 y 2015 
drop if missing(id_uv_2024) & !inlist(anio,2014,2015)
*tab anio tratada, m

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

*tab anio _merge

*tab anio if missing(codigo_uv_rsh) 
*tab anio if codigo_uv_rsh == "."
drop if missing(codigo_uv_rsh)
*solamente son de 2014 y 2015 -> son las personas que no estaban en 2016, los eliminamos 

count
*tab anio
*tab anio tratada

*tab per_edad
*tab anio tiene_hijo_menor5


drop _merge 



* MUDANZAS CON LIMITES DE 2024
sort rut_inn anio
by rut_inn: gen mueve24 = (id_uv_2024 != id_uv_2024[_n-1]) if _n > 1 & anio > anio[_n-1] & anio >= 2017 & !missing(id_uv_2024) & !missing(id_uv_2024[_n-1])
bys rut_inn: egen cambia_uv24 = max(mueve24)
bys rut_inn: egen cambia_uv24_s22 = max(cond(anio != 2022, mueve24, .)) 
*tab anio mueve, row 


*VULNERABILIDAD
*tab anio calc_quintil_validacion2, m 
*sum puntaje if inlist(anio, 2014,2015), detail 

*tab puntaje 
gen vul60_anio = (puntaje <=13500) if inlist(anio, 2014, 2015) & !missing(puntaje)
replace vul60_anio = (calc_quintil_validacion2 <= 60) if anio >=2016 & !missing(calc_quintil_validacion2)
bys rut_inn: egen anio_v = min(cond(!missing(vul60_anio), anio, .))
gen v_pri = vul60_anio if anio == anio_v
bys rut_inn: egen v60 = max(v_pri)
*tab anio_v v60, m 
drop anio_v v_pri vul60_anio

cap drop tag_m
bys rut_inn: gen tag_m = (_n == 1)
*tab v60 if tag_m, m 
*tab cambia_uv24 if tag_m, m
drop tag_m 
count

**************************************************************
*SEPARAMOS AMBAS MUESTRAS 

****************************************************************************
*MUESTRA PARA M LABORAL 
*solo mujeres que tengan hijos menores a 5 años ese año especìfico
* CAMBIO 1: log para guardar los tab de la noche (el 09 no tenia log)
capture log close
log using "log_09_entrada.txt", text replace
preserve

bys rut_inn: egen alguna_hijo5 = max(tiene_hijo_menor5)
keep if alguna_hijo5 == 1
*CAMBIO
bys rut_inn: egen anio_hijo = min(cond(tiene_hijo_menor5 == 1, anio, .))
* CAMBIO 2: entran desde el primer anio que aparecen en el RSH, no desde el primer anio con hijo menor de 5 (profes 29/10). Se deja anio_hijo para usarlo despues
*keep if anio >= anio_hijo
tab anio

keep if v60 == 1
count 
gunique rut_inn
duplicates drop rut_inn anio, force
* CAMBIO 3: cuantos anios esta cada mujer (para decidir el panel balanceado el lunes)
bys rut_inn: gen n_anios = _N
bys rut_inn: gen tag_m = (_n == 1)
tab n_anios if tag_m == 1
drop tag_m


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
* CAMBIO 4: nombre nuevo para no pisar la muestra laboral actual, en parquet para ahorrar espacio
pq save using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_laboral_ingresos_v60_entrada.parquet", replace
restore

* CAMBIO 5: hijos nacidos ANTES de 2014 por mujer (desde la lista de todos los hijos), para tener hijos totales cada anio
preserve
use rut_inn anio_nac_hijo using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\hijos/hijos_filtrado_2014_2024.dta", clear
keep if anio_nac_hijo < 2014
gcollapse (count) hijos_pre2014 = anio_nac_hijo, by(rut_inn)
tempfile pre14
save `pre14'
restore
merge m:1 rut_inn using `pre14', keep(master match) nogen
replace hijos_pre2014 = 0 if missing(hijos_pre2014)




****************************************************************************

*MUESTRA PARA FERTILIDAD -> 18 A 49 AÑOS 
*ya esta restringido para mujeres mayores de 18, hay que eliminar a las mayores de 49, para cualquier año, borra las obs de las mujeres en ese año si es que ese año tienen màs de 49
describe, fullnames 
preserve
drop if per_edad > 49 
*dejamos a las mas vulnerables 
keep if v60 == 1
* CAMBIO 6: % con hijo menor de 5 en la muestra del 21 (v60, 18-49, muestra_t1 == 1) -> chequeo de dilucion
tab tiene_hijo_menor5 if muestra_t1 == 1
log close
* CAMBIO 7: nacimientos acumulados desde 2014 y total de hijos (antes de 2014 + acumulados) cada anio
bys rut_inn (anio): gen nac_acum = sum(tuvo_hijo)
gen hijos_total = hijos_pre2014 + nac_acum
*nos quedamos solo con las de fertilidad
* CAMBIO 8: se agregan hijos_pre2014 nac_acum hijos_total al keep
keep id_uv_2024 codigo_uv_rsh anio rut_inn per_nacionalidad_id per_fic_numpareja per_fic_curso tuvo_hijo tiene_hijo_menor5 n_hijos_menor5 hijos_pre2014 nac_acum hijos_total per_edad calc_quintil_validacion2 calc_ingreso_laboral pob_total_uv cse_prom_uv densidad_ninos_uv n_hogares_uv n_ninos_0_5_uv cambia_uv tratada grupo_t1 g1 muestra_t1 post_t1 rel_t1 stock_base n_*  v60 mueve24 cambia_uv24 cambia_uv24_s22
pq save using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_fertilidad_v60.parquet", replace 
restore


*MUESTRA TOTAL
keep anio rut_inn codigo_uv_rsh id_uv_2024 tratada stock_base muestra_t1 g1 grupo_t1 post_t1 rel_t1 n_vecinas v60 mueve24 cambia_uv24 cambia_uv24_s22
gduplicates report rut_inn anio 
*OJO ACA
duplicates drop rut_inn anio, force
compress
save "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_completa_ruts_trat_v60.dta", replace 






