*10 FERTILIDAD: COLAPSO A UV-AÑO DE LA MUESTRA v60 -- 13/10/2026
* igual que la primera parte de 20260930/muestra_fert_descript.do. Cambios marcados con CAMBIO N
clear all


* CAMBIO 1: muestra_fertilidad -> muestra_fertilidad_v60
use "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_fertilidad_v60.dta", clear 

count
order anio rut_inn codigo_uv_rsh id_uv_2024

*AGRUPAMOS POR UV
* CAMBIO 2: agregar cambia_uv24
keep id_uv_2024 anio rut_inn tuvo_hijo tiene_hijo_menor5 n_hijos_menor5 per_edad calc_quintil_validacion2 calc_ingreso_laboral pob_total_uv cse_prom_uv densidad_ninos_uv n_hogares_uv n_ninos_0_5_uv cambia_uv cambia_uv24 tratada grupo_t1 g1 muestra_t1 post_t1 rel_t1 stock_base n_* 

* CAMBIO 3: agregar cambia_uv24 en (mean) = % de mujeres de la celda que se mudan
gcollapse (mean) tuvo_hijo tiene_hijo_menor5 n_hijos_menor5 per_edad calc_quintil_validacion2 calc_ingreso_laboral cambia_uv24 (first) pob_total_uv cse_prom_uv densidad_ninos_uv n_hogares_uv n_ninos_0_5_uv cambia_uv tratada grupo_t1 muestra_t1 post_t1 rel_t1 stock_base n_junji n_conv_alim n_educ_fam n_alternativo n_clas_terc n_clas_dir n_transitorio n_integra n_total g1 (count) n_mujeres = rut_inn, by(id_uv_2024 anio) 

gunique id_uv_2024
gduplicates report id_uv_2024 anio

* CAMBIO 4: nombre nuevo (antes muestra_fertilidad_uvs)
save "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_fertilidad_v60_uvs.dta", replace 
