* ===================================================
* Plantilla G x T (Baker, Callaway, Cunningham, Goodman-Bacon
* & Sant'Anna, JEL 2026, Seccion 5.2.3 - sin covariables)
* Correr una vez por cada Y: tasa_empleo, meses_trabajando,
* ingreso_anual (o log), tasa_fertilidad
* Panel id_uv_2024 x anio, muestra_t1==1, control = nunca_tratada
* Ventana k = -5 a 9 (cola izq binneada en -5, cola derecha sin binnear,
* celdas sanas 179-424 seg. tab rel_t1_bin del 2026-09-29) -- confirmar
* con "tab rel_t1_bin" en cada base nueva antes de correr, el numero de
* columnas d# generadas depende de los valores presentes en esa base
* ===================================================

* reemplazar Y por el outcome de esta corrida antes de ejecutar


* --- Paso 0: dummies de tiempo-evento para este panel ---
tab rel_t1_bin, gen(d)


* --- Paso 1: descriptivo crudo, analogo Figura 5 (Seccion 5.2) ---
* tendencias por grupo, ANTES de cualquier regresion
* ojo: hay muchas UVs por año -- hay que promediar por grupo-año antes de
* graficar, si no la linea salta entre UVs distintas del mismo año
preserve
collapse (mean) Y, by(anio grupo_t1)
sort anio
twoway (line Y anio if grupo_t1==2) (line Y anio if grupo_t1==3), ///
    legend(label(1 "Nunca tratadas") label(2 "Tratadas")) ///
    ytitle("Y") xtitle("Año") ///
    title("Y promedio por año, UVs tratadas vs. nunca tratadas") ///
    note("Descriptivo, cohortes de tratamiento agrupadas -- no aisla el efecto por cohorte, ver Paso 2 en adelante")
restore


* --- Paso 2: TWFE de referencia ---
* forma de la ecuacion (21), Seccion 5.1, aplicada en contexto G x T
* ver limitaciones / por que es solo referencia en Seccion 5.3
* rango k=-5..9 confirmado sano con "tab rel_t1_bin" (celdas 179-424, sin huecos)
reghdfe Y d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15, ///
    absorb(id_uv_2024 anio) cluster(id_uv_2024)


* --- Paso 2b: version ponderada por tamaño de celda (opcional, comparar con 2) ---
* aweight de celda -- NO es el mismo peso que la agregacion de cohortes del paso 6
reghdfe Y d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 [aweight=n_elegibles], ///
    absorb(id_uv_2024 anio) cluster(id_uv_2024)


* --- Paso 3: estimador robusto G x T bajo PT-GT-NEV ---
* ecuacion (28)-(29), Seccion 5.2.3 (Sun-Abraham, never-treated como control)
* misma estructura de opciones que ya se uso para matricula, solo cambia Y
eventstudyinteract Y d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15, ///
    cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)


* --- Paso 4: chequeo de pre-tendencia ---
* Seccion 5.1.2: individual y conjunta -- "no significativo" no es lo mismo
* que "tendencias paralelas confirmadas" (potencia baja, ver texto)
test d1 d2 d3 d4


* --- Paso 5: grafico agregado, Figura 8 (Seccion 5.2.4, ecuacion 31) ---
* correr inmediatamente despues del reghdfe del Paso 2 (usa su e(b)/e(V))
matrix b = e(b)'
matrix V = e(V)

preserve
clear
svmat b, names(coef)
gen k = .
gen se = .

replace k = -5 in 1
replace k = -4 in 2
replace k = -3 in 3
replace k = -2 in 4
replace k = 0  in 5
replace k = 1  in 6
replace k = 2  in 7
replace k = 3  in 8
replace k = 4  in 9
replace k = 5  in 10
replace k = 6  in 11
replace k = 7  in 12
replace k = 8  in 13
replace k = 9  in 14

forvalues i = 1/14 {
    matrix vi = V[`i',`i']
    replace se = sqrt(vi[1,1]) in `i'
}

* punto omitido k=-1 (referencia, coef=0) -- parte de la Figura 8 tal cual
set obs 15
replace k = -1 in 15
replace coef1 = 0 in 15
replace se = 0 in 15

gen ci_lo = coef1 - 1.96*se
gen ci_hi = coef1 + 1.96*se
sort k

twoway (rcap ci_lo ci_hi k) (scatter coef1 k), ///
    yline(0) xline(-0.5, lpattern(dash)) ///
    ytitle("Efecto sobre Y") xtitle("Tiempo relativo (k)") legend(off)
restore


* --- Paso 6: efecto resumen post-tratamiento ---
* aproximacion simple de la ecuacion (31), Seccion 5.2.4
* OJO: esto promedia parejo, NO pondera por tamaño de cohorte como pide el paper
* -- si se suma csdid, "estat simple" da la version correcta ponderada
lincom (d6 + d7 + d8 + d9 + d10 + d11 + d12 + d13 + d14 + d15)/10


* ===================================================
* Pendiente antes de correr en mercado laboral:
* corregir muestra_laboral_descript.do -- el reghdfe actual solo
* absorbe id_uv_2024, falta agregar anio (absorb(id_uv_2024 anio))
* ===================================================
