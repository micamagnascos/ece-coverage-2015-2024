*DIAGNOSTICO UVS

clear all 
capture log close
log using "log_diagnostico_uv.txt", text replace 

pq use rut_inn anio g1 id_uv_2024 mueve24 muestra_t1 codigo_uv_rsh using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_fertilidad_v60.parquet", clear 

*keep if muestra_t1 == 1 & anio == 2022
*gen trat = (g1 > 0 & !missing(g1))
*tab trat mueve24, row

tab anio mueve24, row 

bys anio id_uv_2024: gen tag_uv = (_n == 1) if !missing(id_uv_2024)
tab anio if tag_uv == 1
tab anio 


*viendo solo para nuestra muestra 
tab anio mueve24 if muestra_t1 == 1, row 
tab anio if tag_uv == 1 & muestra_t1 == 1 

sort rut_inn anio
by rut_inn: gen mismo_cod = (codigo_uv_rsh == codigo_uv_rsh[_n-1]) if _n > 1
tab anio mismo_cod if mueve24 == 1, row 

tab anio mismo_cod, row 
list anio codigo_uv_rsh id_uv_2024 if rut_inn == rut_inn[1]


*ver que paso en crosswalk 
use "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\shapes_uv/crosswalk_uv_final_2_puntocero.dta", clear 
cap tostring codigo_uv, replace 
gsort anio codigo_uv -share 
by anio codigo_uv: keep if _n == 1
keep anio codigo_uv id_uv_2024 tipo
tab anio tipo

preserve 
replace anio = anio - 1
rename id_uv_2024 uv_sig 
rename tipo tipo_sig 
tempfile sig 
save `sig'
restore 
merge 1:1 anio codigo_uv using `sig', keep(match) nogen 
gen cambia = (id_uv_2024 != uv_sig)

tab anio cambia, row 
tab tipo cambia if anio <= 2021, row 
tab tipo_sig cambia if anio <= 2021, row 



log close 