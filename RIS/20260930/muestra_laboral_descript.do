*BASE M LABORAL 
/* Que es esta muestra: panel no balanceado de mujeres 18-70 del RSH/FPS que tienen al menos un hijo menor de 5 años ese año, panel 2014-2025, con rentas y cotizaciones

Tratado: la UV, no la mujer. Una UV es tratada cuando pasa de 0 a 1 jardin. Cada mujer-año hereda el tratamiento de la UV(1d_uv_2024) que vive ese año.

*/

ssc install gtools
ssc install estout, replace
ssc install ftools, replace 
ssc install reghdfe, replace 
clear all 
***************************************************************************************

use "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_laboral_ingresos.dta", clear 

describe, fullnames
count 
*8,481,471

order anio rut_inn codigo_uv_rsh id_uv_2024 



******************************************************************************
/* DESCRIPCIOON GENERAL DE LA MUESTRA 
Obj: saber cant de obs, mujeres y UVs tenemos. Ver que el panel este bien armado
*/

*2014-2024
tab anio

*tienen que haber 0 duplicados de rut_inn anio 
gunique rut_inn
gunique id_uv_2024
gduplicates report rut_inn anio

*que tan balanceado esta el panel. No es balanceado, lo importante es que las mujeres de las UV tratadas no se observen sistemàticamente menos que las de las no tartadas.
gegen n_years_obs = count(anio), by(rut_inn)
tab n_years_obs
tabstat n_years_obs, by(grupo_t1) stat(mean sd min max)



******************************************************************************
/* CHECKEO DE LAS VARIABLES DE TRATAMIENTO DE LA MUESTRA 
Obj: confirmar que las var de tratamiento llegaron bien a todas las filas 
*/

tab anio tratada, m
tab anio grupo_t1, m
*solo mira tratadas y nunca tratadas. Mide fracciòn de la muestra expuesta al tratamiento en cada año 
tab anio post_t1 if muestra_t1 == 1 
*solo para uvs tratadas. rango esperado (-10 a 9), ver si es que los extremos son delgados 
tab rel_t1 

*DUMMIES TIEMPO Y EVENTO Y VAR DE CONTROL 
gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 

tab rel_t1_bin
tab rel_t1_bin, gen(d)

*generamos la variable de tratada dentro de la muestra (sin excluidas)
gen nunca_tratada = (g1== 0)


*cuantas UVs y cuàntas mujeres quedan en cada grupo y en cada cohorte 
gegen tag_uv = tag(id_uv_2024)
*uvs con al menos una mujer en la muestra, ver si es que las tratadas caen mucho por errores del crosswalk
tab grupo_t1 if tag_uv == 1 
*UVs por cohorte dentro de la muestra 
tab g1 if tag_uv == 1 & muestra_t1 == 1 
drop tag_uv

*mujeres por grupo 
gegen tag_mujer_grupo = tag(rut_inn grupo_t1)
*ver si es que el total es muy distinto a gunique, eso nos diria cuantas mujeres se cambian de UV
tab grupo_t1 if tag_mujer_grupo == 1 
drop tag_mujer_grupo


gunique rut_inn
*989714 -> mujeres tratadas 



******************************************************************************
/* VARIABLES DE RESULTADO: INGRESO Y MESES TRABAJANDO 
Obj: armar una sola variable de ingreso y meses trabajanado combinando datos de cotizaciones y rentas 
OJO: un missing de ingreso no es ingreso 0
*/

*hacemos variable completa de rentas 
gen ingreso_anual = renta_imponible_anual 
replace ingreso_anual = monto_dep_anual + monto_indep_anual if missing(renta_imponible_anual)

*hacemos variable completa de meses trabajando
gen meses_trabajando = meses_con_renta 
replace meses_trabajando = meses_cotizados_total if missing(meses_con_renta)
count if missing(meses_trabajando)

*ver para cuanto tengo vacio esa var -> estas son obs, no mujeres 
count if missing(ingreso_anual)
*  4,039,522 -> para casi la mitad de las obs 
gunique rut_inn if !missing(ingreso_anual)
*N = 4,441,949; 1,378,153 unbalanced groups of sizes 1 to 11
gunique rut_inn if missing(ingreso_anual)

count if !missing(per_fic_ingresoanual)
* 5,741,113 -> obs para los cuales lo tengo 
count if missing(ingreso_anual) & !missing(per_fic_ingresoanual)
* 2,414,064
gunique rut_inn if missing(ingreso_anual) & !missing(per_fic_ingresoanual)
*N = 2,414,064; 833,078 unbalanced groups of sizes 1 to 11
gunique rut_inn if missing(ingreso_anual)
*N = 4,039,522; 1,219,289 unbalanced groups of sizes 1 to 11


*proporcion con ingreso por año, separando grupos
gen tiene_ingreso = !missing(ingreso_anual)
tabstat tiene_ingreso if grupo_t1 == 2, by(anio) stat(mean n)
tabstat tiene_ingreso if grupo_t1 == 3, by(anio) stat(mean n)



******************************************************************************
* LIMPIEZA VARIABLES DE CONTROL

*educaciòn 
tab per_fic_tipoeducacion_id
tab per_fic_curso
*es mejor usar per fic tipo de educacion 
replace per_fic_tipoeducacion_id = . if per_fic_tipoeducacion_id == 99

*trabajo 
tab per_fic_trabaja
replace per_fic_trabaja = . if per_fic_trabaja == 9 
replace per_fic_trabaja = 0 if per_fic_trabaja == 2





******************************************************************************
/* BALANCE PRE TRATAMIENTO NIVEL MUJER 
Obj: ver si las mujeres de UVs que se tratan en algun momento, ANTES de la apertura, se parecen a las UVs nunca tratadas. Se hace en un año previo a todas las aperturas (2014), con la muestra del tratamiento 1 dejando fuera las que ya tenian un jardin en 2014. 
*/

*generamos la variable de tratada dentro de la muestra (sin excluidas)
gen ever_t1 = (g1 > 0 & g1 < .) if muestra_t1 == 1
*cuantas filas mujer año hay en cada grupo  
tab ever_t1 if !missing(ever_t1)

local pre 2014 
global bal_ind ingreso_anual meses_trabajando per_edad n_hijos_menor5 per_fic_horastrabajo per_fic_trabaja per_fic_tipoeducacion_id pob_total_uv densidad_ninos_uv

*incluyendo los tres grupos 
set linesize 200
tabstat $bal_ind if anio == `pre', by(grupo_t1) stat(mean sd n) varwidth(25)

*tratadas vs nunca tratadas 
preserve 
keep if anio ==  `pre' & muestra_t1 == 1 
eststo clear 
eststo: estpost ttest $bal_ind, by(ever_t1)
esttab, cells("mu_1 mu_2 b(star)") varwidth(25)

*diferencia normalizada 
di _newline "Diferencia normalizada, año `pre' (tratadas - nunca tratadas)"
foreach v of global bal_ind {
	quietly summ `v' if ever_t1 == 1 
	local m1 = r(mean)
	local v1 = r(Var)
	quietly summ `v' if ever_t1 == 0 
	local m0 = r(mean)
	local v0 = r(Var)
	di %-30s "`v'" %9.3f (`m1'- `m0')/sqrt((`v1'+`v0')/2)
}
restore 



******************************************************************************
/*RESULTADOS EN EL TIEMPO
Obj: primera vision de como evolucionan ingreso y meses trabajando en UVs tratadas versus nunca tratadas y tener una primera magnitud referencial 
*/

*Medias por año y por grupo
preserve 
keep if muestra_t1 == 1 
gcollapse (mean) ingreso_anual meses_trabajando, by(anio ever_t1)
list, sepby(ever_t1)
foreach y in ingreso_anual meses_trabajando {
	twoway (line `y' anio if ever_t1 == 1) (line `y' anio if ever_t1 == 0), legend(order(1 "UVs tratadas" 2 "UVs nunca tratadas")) xtitle("Año") ytitle("`y'") title("`y' promedio por año, Uvs tratadas vs nunca tratadas", size(small)) name(g_`y', replace)
	graph export "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/`y'_tendencia.png", replace
}
restore


*grupos de cohorte (0= nunca tratadas, 2018= 2018 y 2019, 2020= cohortes 2020 a 2024)
gen cohorte_g = . 
replace cohorte_g = 0 if g1==0
replace cohorte_g = g1 if inlist(g1, 2015, 2016, 2017)
replace cohorte_g = 2018 if inlist(g1, 2018, 2019)
replace cohorte_g = 2020 if g1 >= 2020 & g1 < .

preserve 
keep if muestra_t1 == 1 
gcollapse (mean) ingreso_anual meses_trabajando, by(anio cohorte_g)
sort cohorte_g anio

*cambio respecto a 2014 dentro de cada grupo 
foreach y in ingreso_anual meses_trabajando {
	gen aux = `y' if anio == 2014 
	bysort cohorte_g: egen base_`y' = max(aux)
	gen d_`y' = `y' - base_`y'
	drop aux 
}

foreach y in ingreso_anual meses_trabajando {
	foreach c in 2015 2016 2017 2018 2020 { 
	twoway (line d_`y' anio if cohorte_g == `c') (line d_`y' anio if cohorte_g == 0), xline(`c') xlabel(2014(1)2024, angle(45)) legend(order(1 "Cohorte `c'" 2 "Nunca tratadas")) xtitle("Año") ytitle("Cambio en `y' respecto a 2014") title("Cambio en `y' respecto a 2014, cohorte `c' vs nunca tratadas", size(small)) name(g_`y'_`c', replace)
		graph export "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\estimaciones/d_`y'_`c'.png", replace
	}
}
restore


*Regresion referencial
reghdfe ingreso_anual post_t1 if muestra_t1 == 1, absorb(id_uv_2024 anio) cluster(id_uv_2024)
reghdfe meses_trabajando post_t1 if muestra_t1 == 1, absorb(id_uv_2024 anio) cluster(id_uv_2024)



******************************************************************************
/*DIFERENCIAS A NIVEL DE UV

*/

keep rut_inn anio id_uv_2024 g1 grupo_t1 muestra_t1 ever_t1 rel_t1 rel_t1_bin $bal_ind

gcollapse (mean) ingreso_anual meses_trabajando per_edad n_hijos_menor5 per_fic_horastrabajo per_fic_trabaja per_fic_tipoeducacion_id (count) n_mujeres=rut_inn (firstnm) pob_total_uv densidad_ninos_uv g1 grupo_t1 muestra_t1 ever_t1 rel_t1 rel_t1_bin, by(id_uv_2024 anio)

format ingreso_anual %12.0f

save "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/muestra_laboral_uvs.dta", replace


local pre 2014
tab grupo_t1 if anio == `pre'

preserve 
keep if anio == `pre' & muestra_t1 == 1
collapse (sum) n_mujeres, by(ever_t1)
list
restore 


*BALANCE 
local pre 2014
preserve
keep if anio == `pre' & muestra_t1 == 1 & !missing(pob_total_uv)

di _newline "BALANCE A NIVEL UV, año `pre' (tratadas vs nunca tratadas)"
di %-30s "" %27s "Sin ponderar" %33s "Ponderado por pob_total_uv"
di %-30s "Variable" %9s "No trat." %9s "Dif.norm" %12s "No trat." %9s "Trat" %9s "Dif.norm"

foreach v of global bad_ind {
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
*DUMMIES TIEMPO Y EVENTO Y VAR DE CONTROL 

tab rel_t1_bin
tab rel_t1_bin, gen(d)

*generamos la variable de tratada dentro de la muestra (sin excluidas)
cap gen nunca_tratada = (g1== 0)


***********************************************************
*RESULTADO


*INGRESOS 

*1 TWFE de referencia 
*sin ponderar 
reghdfe ingreso_anual d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 per_edad, absorb(id_uv_2024 anio) cluster(id_uv_2024)
*con ponderar 
reghdfe ingreso_anual d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 per_edad [aweight=n_mujeres], absorb(id_uv_2024 anio) cluster(id_uv_2024)

test d1 d2 d3 d4
lincom (d6 + d7 + d8 + d9 + d10 + d11 + d12 + d13 + d14 + d15)/10

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
	
	twoway (rcap ci_lo ci_hi k) (scatter coef k), yline(0) xline(-0.5, lpattern(dash)) ytitle("Efecto sobre ingresos") xtitle("Tiempo relativo (k)") legend(off) title("TWFE ingresos, ponderado por n_mujeres", size(medsmall))
restore 



*estimador robusto

eventstudyinteract ingreso_anual d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 [aweight=n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)


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
	
	twoway (rcap ci_lo ci_hi k) (scatter coef k), yline(0) xline(-0.5, lpattern(dash)) ytitle("Efecto sobre ingresos") xtitle("Tiempo relativo (k)") legend(off) title("Event study robusto (Sun-Abraham) ingresos, ponderado por n_mujeres", size(medsmall))
restore 



*estimador robusto

eventstudyinteract ingreso_anual d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15, cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)








*MESES TRABAJANDO 

reghdfe meses_trabajando d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 per_edad, absorb(id_uv_2024 anio) cluster(id_uv_2024)
*con ponderar 
reghdfe meses_trabajando d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 per_edad [aweight=n_mujeres], absorb(id_uv_2024 anio) cluster(id_uv_2024)

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
	
	twoway (rcap ci_lo ci_hi k) (scatter coef k), yline(0) xline(-0.5, lpattern(dash)) ytitle("Efecto sobre meses trabajando") xtitle("Tiempo relativo (k)") legend(off) title("TWFE meses trabajando, ponderado por n_mujeres", size(medsmall))
restore 




*estimador robusto 

eventstudyinteract meses_trabajando d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 [aweight=n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)


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
	
	twoway (rcap ci_lo ci_hi k) (scatter coef k), yline(0) xline(-0.5, lpattern(dash)) ytitle("Efecto sobre meses trabajando") xtitle("Tiempo relativo (k)") legend(off) title("Event study robusto (Sun-Abraham) meses trabajando, ponderado por n_mujeres", size(medsmall))
restore 



*sin edad 

eventstudyinteract meses_trabajando d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 [aweight=n_mujeres], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)


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
	
	twoway (rcap ci_lo ci_hi k) (scatter coef k), yline(0) xline(-0.5, lpattern(dash)) ytitle("Efecto sobre meses trabajando") xtitle("Tiempo relativo (k)") legend(off) title("Event study robusto (Sun-Abraham) meses trabajando, ponderado por n_mujeres, sin controlar edad", size(medsmall))
restore 


















