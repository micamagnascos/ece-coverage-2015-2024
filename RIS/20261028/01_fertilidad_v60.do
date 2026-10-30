*FERTILIDAD - MUESTRA V60 MADRES FIJAS 
* 19/10/2026

clear all

do "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/00_setup.do"
capture log close
log using "$est/log_lab_v60fija_20261019.txt", text replace 


pq use rut_inn anio id_uv_2024 tuvo_hijo per_edad g1 muestra_t1 rel_t1 using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_fertilidad_v60.parquet", clear
count 
tab anio
*tab grupo_t1


keep if muestra_t1 == 1



*COLAPSO A UV AÑO 
gcollapse (mean) tuvo_hijo per_edad (firstnm) g1 rel_t1 (count) n_mujeres = rut_inn, by(id_uv_2024 anio)
count 
gunique id_uv_2024 
save "$muestra/muestra_fertilidad_v60_uvs.dta", replace 

gen nunca_tratada = (g1 == 0)
gunique id_uv_2024


*TENDENCIAS POR AÑO Y CHORTE
preserve 
gen nac = tuvo_hijo * n_mujeres 
gcollapse (sum) nac n_mujeres (count) n_uv = n_mujeres, by(anio g1)
save "$est/tend_fert_v60fija.dta", replace 
restore 



*DUMMIES DE EVENTO
gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 
replace rel_t1_bin = -1 if missing(rel_t1)
tab rel_t1_bin
tab rel_t1_bin, gen(d)
count if missing(d1)



* ESTIMACIONES 
capture postclose pf 
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctr using "$est/coefs_fert_v60fija.dta", replace

quietly sum tuvo_hijo if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)

*Principal
eventstudyinteract tuvo_hijo d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w tuvo_hijo `m0w'
guardarV sa_w_fija_tuvo_hijo

*Sin 2015 
eventstudyinteract tuvo_hijo d1-d4 d6-d14 if g1 != 2015 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w_s15 tuvo_hijo `m0w'
guardarV sa_w_s15_fija_tuvo_hijo

postclose pf 





use "$est/coefs_fert_v60fija.dta", clear 

grafico coefs_fert_v60fija tuvo_hijo sa_w











