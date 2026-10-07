*BASE FERTILIDAD - DESCRIPTIVOS Y RESULTADOS A NIVEL DE UV
/* Panel id_uv_2024 x anio, 2014-2024, ya colapsado desde el panel mujer.
Tratado: la UV. Outcome: tuvo_hijo = tasa de natalidad (prom. de mujeres que
tuvieron hijo ese año, entre las mujeres 18-49 de la UV).
Marco metodologico: Baker, Callaway, Cunningham, Goodman-Bacon & Sant'Anna
(JEL 2026), Seccion 5.2.3 -- G x T sin covariables, PT-GT-NEV (never-treated
como control). Cada seccion de abajo indica a que parte del paper corresponde. */

clear all
use ".../fertilidad_uv_anio.dta", clear
describe, fullnames
count
order anio id_uv_2024


******************************************************************************
* 1. DESCRIPCION GENERAL DEL PANEL

tab anio
gunique id_uv_2024
gduplicates report id_uv_2024 anio

gegen n_years_obs = count(anio), by(id_uv_2024)
tabstat n_years_obs, by(grupo_t1) stat(mean sd min max)


******************************************************************************
* 2. CHECKEO DE VARIABLES DE TRATAMIENTO

tab anio tratada, m
tab anio grupo_t1, m
tab anio post_t1 if muestra_t1 == 1
tab rel_t1_bin
* confirmar rango y que no haya huecos antes de generar los dummies (seccion 7) --
* el numero de columnas d# depende de los valores presentes en esta base

gegen tag_uv = tag(id_uv_2024)
tab grupo_t1 if tag_uv == 1
tab g1 if tag_uv == 1 & muestra_t1 == 1
drop tag_uv


******************************************************************************
* 3. TAMAÑO DE CELDA (mujeres por UV-año)

tabstat n_mujeres, stat(mean p50 p99 max)

* cuantas mujeres tratadas vs. nunca tratadas -- en UN año de referencia
* (no sumar n_mujeres a traves de todos los años, serian cortes repetidos
* y contarias a la misma mujer varias veces)
local pre 2014
capture gen ever_t1 = (g1 > 0 & g1 < .) if muestra_t1 == 1

preserve
keep if anio==`pre' & muestra_t1==1
collapse (sum) n_mujeres, by(ever_t1)
list
restore


******************************************************************************
* 4. VARIABLE DE RESULTADO: TASA DE NATALIDAD

count if missing(tuvo_hijo)
tabstat tuvo_hijo if grupo_t1 == 2, by(anio) stat(mean n)
tabstat tuvo_hijo if grupo_t1 == 3, by(anio) stat(mean n)


******************************************************************************
* 5. BALANCE PRE TRATAMIENTO A NIVEL UV (2014)

capture gen ever_t1 = (g1 > 0 & g1 < .) if muestra_t1 == 1
* (probablemente ya se creo en la Seccion 3 -- capture evita el error "already defined")

global bal_ind tuvo_hijo per_edad calc_quintil_validacion2 per_fic_tipoeducacion_id pob_total_uv densidad_ninos_uv cse_prom_uv

local pre 2014
tabstat $bal_ind if anio == `pre', by(grupo_t1) stat(mean sd n) varwidth(25)

* 5a. version simple: tratadas vs nunca tratadas
preserve
keep if anio == `pre' & muestra_t1 == 1
eststo clear
eststo: estpost ttest $bal_ind, by(ever_t1)
esttab, cells("mu_1 mu_2 b(star)") varwidth(25)
restore

* 5b. version ponderada + diferencia normalizada -- mismo formato que la
* tabla de balance de mercado laboral (muestra_laboral_descript.do)
local pre 2014
di "$bal_ind"
preserve
keep if anio == `pre' & muestra_t1 == 1 & !missing(pob_total_uv)
di _newline "BALANCE A NIVEL UV, año `pre' (tratadas vs nunca tratadas)"
di %-30s "" %39s "Sin ponderar" %45s "Ponderado por pob_total_uv"
di %-30s "Variable" %14s "No trat." %14s "Trat" %9s "Dif.norm" %17s "No trat." %14s "Trat" %9s "Dif.norm"

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
	di %-30s "`v'" %14.4f `a0' %14.4f `a1' %9.4f (`a1'-`a0')/sqrt((`s1'+`s0')/2) %17.4f `w0' %14.4f `w1' %9.4f (`w1'-`w0')/sqrt((`t1'+`t0')/2)
}

di _newline "Numero de UVs"
count if ever_t1 == 0
count if ever_t1 == 1
restore


******************************************************************************
* 6. TASA DE NATALIDAD EN EL TIEMPO -- descriptivo crudo
* analogo Figura 5 (Seccion 5.2), pero grupos agrupados (no por cohorte) --
* chequeo grueso solamente, la evidencia real viene de las secciones 8 en adelante

preserve
keep if muestra_t1 == 1
collapse (mean) tuvo_hijo, by(anio grupo_t1)
sort anio
twoway (line tuvo_hijo anio if grupo_t1==2) (line tuvo_hijo anio if grupo_t1==3), ///
    legend(label(1 "Nunca tratadas") label(2 "Tratadas")) ///
    ytitle("Tasa de natalidad") xtitle("Año") ///
    title("Tasa de natalidad promedio por año, UVs tratadas vs. nunca tratadas", size(small)) ///
    note("Descriptivo, cohortes de tratamiento agrupadas -- no aisla el efecto por cohorte, ver seccion 8 en adelante")
restore


******************************************************************************
* 7. DUMMIES DE TIEMPO-EVENTO Y VARIABLE DE CONTROL
* insumo para las secciones 8 en adelante

tab rel_t1_bin, gen(d)
* confirmar con el tab de la seccion 2 que d1=-5, d2=-4, d3=-3, d4=-2,
* d5=-1(omitida), d6=0, d7=1, d8=2, d9=3, d10=4, d11=5, d12=6, d13=7, d14=8,
* d15=9 -- ajustar los numeros de columna si el rango en esta base difiere

gen nunca_tratada = (g1 == 0)
* dummy de control para la Seccion 9 (control_cohort en eventstudyinteract) --
* PT-GT-NEV usa solo estas UVs como comparacion


******************************************************************************
* 8. TWFE DE REFERENCIA
* forma de la ecuacion (21), Seccion 5.1, aplicada en contexto G x T --
* ver limitaciones en Seccion 5.3, este es solo el estimador de referencia

reghdfe tuvo_hijo d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15, ///
    absorb(id_uv_2024 anio) cluster(id_uv_2024)

* chequeo de pre-tendencia -- INMEDIATAMENTE despues de este reghdfe, no
* despues del eventstudyinteract de la Seccion 9 (ver Seccion 10 para el
* porque: eventstudyinteract no guarda coeficientes llamados "d1","d2"...)
test d1 d2 d3 d4

* efecto resumen post-tratamiento del TWFE (aproximacion simple ecuacion 31,
* Seccion 5.2.4) -- mismo motivo que el test, tiene que ir aca, no al final
lincom (d6 + d7 + d8 + d9 + d10 + d11 + d12 + d13 + d14 + d15)/10

* version ponderada por tamaño de celda (comparar con la anterior)
reghdfe tuvo_hijo d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 [aweight=n_mujeres], ///
    absorb(id_uv_2024 anio) cluster(id_uv_2024)


******************************************************************************
* 9. ESTIMADOR ROBUSTO G x T BAJO PT-GT-NEV
* ecuacion (28)-(29), Seccion 5.2.3 (Sun-Abraham, never-treated como control)
* -- este es el estimador en el que confiamos para el resultado final

eventstudyinteract tuvo_hijo d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15, ///
    cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)

* version ponderada por tamaño de celda -- el paper pondera por poblacion en
* TODAS sus figuras (ver pie de Figuras 6-9), consistente con la Seccion 8
eventstudyinteract tuvo_hijo d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 [aweight=n_mujeres], ///
    cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)


******************************************************************************
* 10. CHEQUEO DE PRE-TENDENCIA
* Seccion 5.1.2 -- "no significativo" no es lo mismo que "tendencias
* paralelas confirmadas" (los tests suelen tener poca potencia, ver texto)
* el test en si se movio a la Seccion 8 (tiene que correr justo despues del
* reghdfe, no despues del eventstudyinteract de la Seccion 9)


******************************************************************************
* 11a. GRAFICO DEL TWFE DE REFERENCIA -- vuelve a correr el reghdfe de la
* seccion 8 (sin ponderar) INMEDIATAMENTE antes de este bloque, para que
* r(table) tenga esa regresion y no otra que hayas corrido despues

matrix T = r(table)

preserve
clear
set obs 15
gen k = _n - 6
* fila 1..15 -> k = -5,-4,-3,-2,-1,0,1,2,...,9 (la regla es d# = k + 6)
gen coef = 0 if k==-1
gen se = 0 if k==-1

forvalues t = -5/9 {
    if `t' != -1 {
        local dnum = `t' + 6
        replace coef = T[1,colnumb(T,"d`dnum'")] if k==`t'
        replace se   = T[2,colnumb(T,"d`dnum'")] if k==`t'
    }
}

gen ci_lo = coef - 1.96*se
gen ci_hi = coef + 1.96*se
sort k

twoway (rcap ci_lo ci_hi k) (scatter coef k), ///
    yline(0) xline(-0.5, lpattern(dash)) ///
    ytitle("Efecto sobre tasa de natalidad") xtitle("Tiempo relativo (k)") legend(off) ///
    title("Event study TWFE (referencia) -- tasa de natalidad", size(small))
restore


******************************************************************************
* 11b. GRAFICO DEL ESTIMADOR ROBUSTO -- analogo Figura 8 (Seccion 5.2.4,
* ecuacion 31). Vuelve a correr el eventstudyinteract SIN ponderar de la
* seccion 9 inmediatamente antes de este bloque (mismo motivo que en 11a):
* r(table) refleja siempre la ultima estimacion corrida, no "la de la
* seccion 9" a menos que la hayas corrido justo antes

matrix T = r(table)

preserve
clear
set obs 15
gen k = _n - 6
gen coef = 0 if k==-1
gen se = 0 if k==-1

forvalues t = -5/9 {
    if `t' != -1 {
        local dnum = `t' + 6
        replace coef = T[1,colnumb(T,"d`dnum'")] if k==`t'
        replace se   = T[2,colnumb(T,"d`dnum'")] if k==`t'
    }
}

gen ci_lo = coef - 1.96*se
gen ci_hi = coef + 1.96*se
sort k

twoway (rcap ci_lo ci_hi k) (scatter coef k), ///
    yline(0) xline(-0.5, lpattern(dash)) ///
    ytitle("Efecto sobre tasa de natalidad") xtitle("Tiempo relativo (k)") legend(off) ///
    title("Event study robusto (Sun-Abraham) -- tasa de natalidad", size(small))
restore


******************************************************************************
* 12. EFECTO RESUMEN POST-TRATAMIENTO
* el lincom del TWFE se movio a la Seccion 8 (mismo motivo que el test: tiene
* que correr justo despues de ese reghdfe). Pendiente: la version ponderada
* por cohorte de la ecuacion (31) real (no esta aproximacion simple) requiere
* csdid/estat simple, no un lincom sobre el eventstudyinteract actual
