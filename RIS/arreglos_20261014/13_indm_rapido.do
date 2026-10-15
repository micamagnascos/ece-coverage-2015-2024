*EF MUJER, UV FIJA (ITT) - EMPLEO FORMAL, SOLO SA + GRAFICO
*BASE NUEVA DEL 09: v60, madres con hijo <5 en algun momento, todos los años
* 14/10

use "$muestra/muestra_laboral_ingresos_v60.dta", clear
count
gunique rut_inn

*OUTCOME
egen monto_cot = rowtotal(monto_dep_anual monto_indep_anual), missing
gen ingreso_anual = renta_imponible_anual
replace ingreso_anual = monto_cot if missing(renta_imponible_anual)
gen empleo_formal = (ingreso_anual > 0 & !missing(ingreso_anual))

*UV FIJA = primera UV observada de cada mujer (las que se mudan se quedan)
sort rut_inn anio
by rut_inn: gen uv_fija = id_uv_2024[1]
by rut_inn: gen g1_f = g1[1]
by rut_inn: gen muestra_f = muestra_t1[1]
by rut_inn: gen anio_ent = anio[1]
gen pre_f = (g1_f == 0 | anio_ent < g1_f)
count if missing(uv_fija)
tab muestra_f pre_f, m
keep if muestra_f == 1 & pre_f == 1
gunique rut_inn

*EVENTO SEGUN UV FIJA
gen nunca_f = (g1_f == 0)
gen rel_f = anio - g1_f if g1_f > 0
gen rel_t1_bin = rel_f
replace rel_t1_bin = -5 if rel_f < -5
replace rel_t1_bin = -1 if missing(rel_f)
tab rel_t1_bin, gen(d)
*revisar: d5 tiene que ser -1

eventstudyinteract empleo_formal d1-d4 d6-d15, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
* CAMBIO 2: promedio post, pretest y media control justo despues de estimar (no se pueden recuperar despues)
lincom (d6 + d7 + d8 + d9 + d10 + d11 + d12 + d13 + d14 + d15)/10
test d1 d2 d3 d4
sum empleo_formal if nunca_f == 1

*GRAFICO
matrix bt = e(b_iw)'
matrix V = e(V_iw)
matrix vt = vecdiag(V)'
preserve
clear
svmat bt, names(b)
svmat vt, names(v)
gen k = _n - 6
replace k = _n - 5 if _n >= 5
set obs 15
replace k = -1 in 15
replace b1 = 0 in 15
replace v1 = 0 in 15
gen lo = b1 - 1.96*sqrt(v1)
gen hi = b1 + 1.96*sqrt(v1)
list k b1 lo hi
twoway (rcap lo hi k) (scatter b1 k), yline(0) xline(-0.5, lpattern(dash)) xlabel(-5(1)9) legend(off) title("Empleo formal - EF mujer, UV fija (SA)")
graph export "$est/g_sa_indm_empleo.png", replace
restore
