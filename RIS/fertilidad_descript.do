*BASE FERTILIDAD - DESCRIPTIVOS A NIVEL DE UV
/* Panel id_uv_2024 x anio, 2014-2024, ya colapsado desde el panel mujer.
Tratado: la UV. Outcome: tuvo_hijo = tasa de natalidad (prom. de mujeres que tuvieron hijo ese año, entre las mujeres 18-49 de la UV). */

clear all
use ".../fertilidad_uv_anio.dta", clear
describe, fullnames
count
order anio id_uv_2024


******************************************************************************
/* DESCRIPCION GENERAL DEL PANEL */

tab anio
gunique id_uv_2024
gduplicates report id_uv_2024 anio

gegen n_years_obs = count(anio), by(id_uv_2024)
tabstat n_years_obs, by(grupo_t1) stat(mean sd min max)


******************************************************************************
/* CHECKEO DE VARIABLES DE TRATAMIENTO */

tab anio tratada, m
tab anio grupo_t1, m
tab anio post_t1 if muestra_t1 == 1
tab rel_t1

gegen tag_uv = tag(id_uv_2024)
tab grupo_t1 if tag_uv == 1
tab g1 if tag_uv == 1 & muestra_t1 == 1
drop tag_uv


******************************************************************************
/* TAMAÑO DE CELDA (mujeres por UV-año) */

tabstat n_mujeres, stat(mean p50 p99 max)


******************************************************************************
/* VARIABLE DE RESULTADO: TASA DE NATALIDAD */

count if missing(tuvo_hijo)
tabstat tuvo_hijo if grupo_t1 == 2, by(anio) stat(mean n)
tabstat tuvo_hijo if grupo_t1 == 3, by(anio) stat(mean n)


******************************************************************************
/* BALANCE PRE TRATAMIENTO A NIVEL UV (2014) */

gen ever_t1 = (g1 > 0 & g1 < .) if muestra_t1 == 1

global bal_ind tuvo_hijo per_edad calc_quintil_validacion2 per_fic_tipoeducacion_id pob_total_uv densidad_ninos_uv cse_prom_uv

local pre 2014
tabstat $bal_ind if anio == `pre', by(grupo_t1) stat(mean sd n) varwidth(25)

preserve
keep if anio == `pre' & muestra_t1 == 1
eststo clear
eststo: estpost ttest $bal_ind, by(ever_t1)
esttab, cells("mu_1 mu_2 b(star)") varwidth(25)
restore


******************************************************************************
/* TASA DE NATALIDAD EN EL TIEMPO */

preserve
keep if muestra_t1 == 1
gcollapse (mean) tuvo_hijo, by(anio ever_t1)
list, sepby(ever_t1)
twoway (line tuvo_hijo anio if ever_t1 == 1) (line tuvo_hijo anio if ever_t1 == 0), ///
    legend(order(1 "UVs tratadas" 2 "UVs nunca tratadas")) ///
    xtitle("Año") ytitle("Tasa de natalidad")
restore


******************************************************************************
/* REGRESION REFERENCIAL */

reghdfe tuvo_hijo post_t1 if muestra_t1 == 1, absorb(id_uv_2024 anio) cluster(id_uv_2024)
reghdfe tuvo_hijo post_t1 [aw = n_mujeres] if muestra_t1 == 1, absorb(id_uv_2024 anio) cluster(id_uv_2024)
