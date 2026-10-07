*FERTILIDAD

ssc install gtools
ssc install estout, replace 
clear all 


***********************************************************
*GENERAR LA BASE A NIVEL UV 
use "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_fertilidad.dta", clear

count
order anio rut_inn codigo_uv_rsh id_uv_2024
describe, fullnames  

*AGRUPAMOS POR UV para hacer el anàlisis de fertilidad, panel UV desde el inicio
keep id_uv_2024 anio rut_inn tuvo_hijo tiene_hijo_menor5 n_hijos_menor5 per_edad calc_quintil_validacion2 calc_ingreso_laboral pob_total_uv cse_prom_uv densidad_ninos_uv n_hogares_uv n_ninos_0_5_uv cambia_uv tratada grupo_t1 g1 muestra_t1 post_t1 rel_t1 stock_base n_*

gcollapse (mean) tuvo_hijo tiene_hijo_menor5 n_hijos_menor5 per_edad calc_quintil_validacion2 calc_ingreso_laboral (first) pob_total_uv cse_prom_uv densidad_ninos_uv n_hogares_uv n_ninos_0_5_uv cambia_uv tratada grupo_t1 muestra_t1 post_t1 rel_t1 stock_base n_junji n_conv_alim n_educ_fam n_alternativo n_clas_terc n_clas_dir n_transitorio n_integra n_total g1 (count) n_mujeres = rut_inn, by(id_uv_2024 anio)

*tienen que haber 0 duplicados de rut_inn anio 
gunique id_uv_2024
gduplicates report id_uv_2024 anio

save "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_fertilidad_uvs.dta", replace

***********************************************************
*DESCRIPCION GENERAL DE LA MUESTRA 
clear 
use "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_fertilidad_uvs.dta", clear
describe, fullnames 

/*
g1: = año en que tuvo primer jardin (cohorte), =0 para las nunca tratadas
stock_base: jardines en la UV en 2014
muestra_t1: = 1 si es que la UV entra en el diseño. = 1 si es que tenia 0 jaridnes en 2014
grupo_t1: 
	1 = excluida 
	2 = nunca tratada (g1 == 0)
	3 = tratada (g1 > 0 algun año)
rel_t1: tiepo relativo (anio - g1)
rel_tel_b: con cola izquierda bineada 
*/

tab anio

gegen n_years_obs = count(anio), by(id_uv_2024)
tabstat n_years_obs, by(grupo_t1) stat(mean sd min max)


***********************************************************
/* CHECKEO DE LAS VARIABLES DE TRATAMIENTO DE LA MUESTRA 
Obj: confirmar que las var de tratamiento llegaron bien a todas las filas 
*/

tab anio tratada, m
tab anio grupo_t1, m
*solo mira tratadas y nunca tratadas. Mide fracciòn de la muestra expuesta al tratamiento en cada año 
tab anio post_t1 if muestra_t1 == 1 
*solo para uvs tratadas. rango esperado (-10 a 9), ver si es que los extremos son delgados 
tab rel_t1 

*cuantas UVs y cuàntas mujeres quedan en cada grupo y en cada cohorte 
gegen tag_uv = tag(id_uv_2024)
*uvs con al menos una mujer en la muestra, ver si es que las tratadas caen mucho por errores del crosswalk
tab grupo_t1 if tag_uv == 1 
*UVs por cohorte dentro de la muestra 
tab g1 if tag_uv == 1 & muestra_t1 == 1 
drop tag_uv


***********************************************************
*MUJERES POR UV AÑO 
tabstat n_mujeres, stat(mean p50 p99 max)


***********************************************************
*VARIABLE DE RESULTADO: TASA DE NATALIDAD -> TENDENCIA CRUDA 
count if missing(tuvo_hijo)
tabstat tuvo_hijo if grupo_t1 == 2, by(anio) stat(mean n)
tabstat tuvo_hijo if grupo_t1 == 3, by(anio) stat(mean n)


***********************************************************
*BALANCE PRE TRATAMIENTO NIVEL UV 
*generamos la variable de tratada dentro de la muestra (sin excluidas)
gen ever_t1 = (g1 > 0 & g1 < .) if muestra_t1 == 1

local pre 2014 
global bal_ind tuvo_hijo per_edad n_hijos_menor5 pob_total_uv densidad_ninos_uv n_mujeres 

*incluyendo los tres grupos 
set linesize 200
tabstat $bal_ind if anio == `pre', by(grupo_t1) stat(mean sd n) varwidth(25)

*tratadas vs nunca tratadas 
preserve 
keep if anio ==  `pre' & muestra_t1 == 1 
eststo clear 
eststo: estpost ttest $bal_ind, by(ever_t1)
esttab, cells("mu_1 mu_2 b(star)") varwidth(25)
restore 

* version ponderada y diferencias normalizadas 
preserve 
keep if anio == `pre' & muestra_t1 == 1 & !missing(pob_total_uv)

di _newline "BALANCE A NIVEL UV, año `pre' (tratadas vs nunca tratadas)"
di %-30s "" %27s "Sin ponderar" %33s "Ponderado por pob_total_uv"
di %-30s "Variable" %9s "No trat." %9s "Dif.norm" %12s "No trat." %9s "Trat" %9s "Dif.norm"

foreach v of global bal_ind {
	quietly summ `v' if ever_t1 == 0 
	local a0 = r(mean)
	local s0 = r(Var)
	quietly summ `v' if ever_t1 == 1 
	local a1 = r(mean)
	local s1 = r(Var)
	quietly summ `v' [aw = pob_total_uv] if ever_t1 == 0
	local w0 = r(mean)
	local t0 = r(Var)
	quietly summ `v' [aw = pob_total_uv] if ever_t1 == 1
	local w1 = r(mean)
	local t1 = r(Var)
	di %-30s "`v'" %9.2f `a0' %9.2f `a1' %9.3f (`a1'-`a0') / sqrt((`s1' + `s0')/2) %12.2f `w0' %9.3f `w1' %9.3f (`w1'-`w0')/sqrt((`t1' + `t0')/2) 
}

di _newline "Numero de UVs"
count if ever_t1 == 0
count if ever_t1 == 1
restore 


***********************************************************
*0: Descriptivo tasa de natalidad en el tiempo crudo: tendencias por grupo
preserve 
collapse (mean) tuvo_hijo, by(anio grupo_t1)
sort anio 
twoway (line tuvo_hijo anio if grupo_t1 == 2) (line tuvo_hijo anio if grupo_t1 == 3), legend(label(1 "Nunca tratadas") label(2 "Tratadas")) ytitle("Natalidad") xtitle("Año") title("Promedio natalidad por UV por año, tratadas vs nunca tratadas", size(medsmall)) note("Descriptivo, cohortes de tratamiento agrupadas, no aisla efecto por cohorte")
restore 


***********************************************************
*DUMMIES TIEMPO Y EVENTO Y VAR DE CONTROL 
gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 

tab rel_t1_bin
tab rel_t1_bin, gen(d)

*generamos la variable de tratada dentro de la muestra (sin excluidas)
gen nunca_tratada = (g1== 0)



***********************************************************
*ESTIMACIONES DE EFECTOS A NIVEL UV 

*1 TWFE de referencia 
*sin ponderar 
reghdfe tuvo_hijo d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15, absorb(id_uv_2024 anio) cluster(id_uv_2024)
*con ponderar 
reghdfe tuvo_hijo d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 [aweight=n_mujeres], absorb(id_uv_2024 anio) cluster(id_uv_2024)

*GRAFICO TWFE
matrix T = r(table)

preserve 
clear 
set obs 15 
gen k = _n - 6 
gen coef = 0 if k==-1
gen se = 0 if k == -1 

forvalues t = -5/9 {
	if `t' != -1 {
		local dnum = `t' + 6
		replace coef = T[1, colnumb(T, "d`dnum'")] if k == `t'
		replace se = T[2, colnumb(T, "d`dnum'")] if k == `t'
		}
	}

	gen ci_lo = coef - 1.96*se
	gen ci_hi = coef + 1.96*se 
	sort k 
	
	twoway (rcap ci_lo ci_hi k) (scatter coef k), yline(0) xline(-0.5, lpattern(dash)) ytitle("Efecto sobre tasa de natalidad") xtitle("Tiempo relativo (k)") legend(off) title("TWFE tasa de natalidad, ponderado por poblaciòn", size(medsmall))
restore 


*ESTIMADOR ROBUSTO 
eventstudyinteract tuvo_hijo d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 [aweight=n_mujeres], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)


*GRAFICO ESTIMADOR ROBUSTO 
matrix T = r(table)

preserve 
clear 
set obs 15 
gen k = _n - 6 
gen coef = 0 if k==-1
gen se = 0 if k == -1 

forvalues t = -5/9 {
	if `t' != -1 {
		local dnum = `t' + 6
		replace coef = T[1, colnumb(T, "d`dnum'")] if k == `t'
		replace se = T[2, colnumb(T, "d`dnum'")] if k == `t'
		}
	}

	gen ci_lo = coef - 1.96*se
	gen ci_hi = coef + 1.96*se 
	sort k 
	
	twoway (rcap ci_lo ci_hi k) (scatter coef k), yline(0) xline(-0.5, lpattern(dash)) ytitle("Efecto sobre tasa de natalidad") xtitle("Tiempo relativo (k)") legend(off) title("Event study robusto (Sun-Abraham) tasa de natalidad, ponderado por poblaciòn", size(medsmall))
restore 





