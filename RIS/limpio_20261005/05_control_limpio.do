* 05_CONTROL LIMPIO -- 06/10/2026
* mismos modelos de 01-03, cambiando el grupo control:
* todas = todas las nunca tratadas | abre = sin vecina que abrio jardin | jardin = sin ningun jardin vecino

clear all
global codigo "ESCRIBIR_CARPETA_DE_LOS_DO"
do "$codigo/00_setup.do"
global cob "$base/cobertura"
capture log close
log using "$est/log_ctrl_20261006.txt", text replace


* prepara: pega vecinas, saca controles contaminados y arma dummies
capture program drop prepara
program define prepara
	args spec
	keep if muestra_t1 == 1
	merge m:1 id_uv_2024 using "$cob/vecinas_uv.dta", keep(master match)
	tab _merge
	drop _merge
	if "`spec'" == "abre" drop if g1 == 0 & vecina_abre == 1
	if "`spec'" == "jardin" drop if g1 == 0 & vecina_jardin == 1
	gen nunca_tratada = (g1 == 0)
	gunique id_uv_2024 if nunca_tratada == 1
	gunique id_uv_2024 if nunca_tratada == 0
	gen rel_t1_bin = rel_t1
	replace rel_t1_bin = -5 if rel_t1 < -5
	replace rel_t1_bin = -1 if missing(rel_t1)
	tab rel_t1_bin, gen(d)
	count if missing(d1)
end


* est4: los 4 modelos de siempre (twfe, twfe_w, sa, sa_w)
capture program drop est4
program define est4
	args y w spec cov
	local copt
	if "`cov'" != "" local copt covariates(`cov')

	quietly sum `y' if nunca_tratada == 1
	local m0 = r(mean)
	quietly sum `y' if nunca_tratada == 1 [aw = `w']
	local m0w = r(mean)

	reghdfe `y' d1-d4 d6-d15 `cov', absorb(id_uv_2024 anio) cluster(id_uv_2024)
	guardar twfe_`spec' `y' `m0'
	test d1 d2 d3 d4
	post pf ("pretest_`spec'") ("`y'") (-99) (r(p)) (.) (.) (.) (.)
	lincom (d6 + d7 + d8 + d9 + d10 + d11 + d12 + d13 + d14 + d15)/10
	post pf ("twfe_prom_`spec'") ("`y'") (99) (r(estimate)) (r(se)) (.) (.) (`m0')

	reghdfe `y' d1-d4 d6-d15 `cov' [aw = `w'], absorb(id_uv_2024 anio) cluster(id_uv_2024)
	guardar twfe_w_`spec' `y' `m0w'

	eventstudyinteract `y' d1-d4 d6-d15, cohort(g1) control_cohort(nunca_tratada) `copt' absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
	guardar sa_`spec' `y' `m0'
	guardarV sa_`spec'_`y'

	eventstudyinteract `y' d1-d4 d6-d15 [aw = `w'], cohort(g1) control_cohort(nunca_tratada) `copt' absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
	guardar sa_w_`spec' `y' `m0w'
end


* 1. CHEQUEO DEL ARCHIVO DE VECINAS
use t_id_uv_ca vecina_jardin vecina_abre using "$cob/base_cobertura_cp.dta", clear
gduplicates drop
gduplicates report t_id_uv_ca
rename t_id_uv_ca id_uv_2024
tab vecina_jardin vecina_abre
save "$cob/vecinas_uv.dta", replace


* 2. ESTIMACIONES (bases UV-año ya armadas)
capture postclose pf
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctrl using "$est/coefs_ctrl.dta", replace

foreach s in todas abre jardin {
	use "$pe/primera_etapa_panel_uv.dta", clear
	prepara `s'
	est4 tasa_matricula n_ninos `s'

	use "$muestra/muestra_fertilidad_uvs.dta", clear
	prepara `s'
	est4 tuvo_hijo n_mujeres `s' per_edad

	use "$muestra/muestra_laboral_ingresos_v2.dta", clear
	prepara `s'
	est4 empleo_formal n_mujeres `s' per_edad
	est4 ln_ingreso n_con_ingreso `s' per_edad
	est4 meses_trabajando n_con_ingreso `s' per_edad
}
postclose pf


* 3. REVISAR
use "$est/coefs_ctrl.dta", clear
list modelo outcome b se N n_uv if k == 99 | k == -99, sepby(outcome)
list modelo outcome b se N n_uv if k == 0 & strpos(modelo, "sa_") == 1, sepby(outcome)

* 4. GRAFICOS: las 3 definiciones de control superpuestas
keep if k >= -5 & k <= 9
gen spec = word(subinstr(modelo, "_", " ", .), -1)
gen mod = substr(modelo, 1, strlen(modelo) - strlen(spec) - 1)
tab mod spec
gen lo = b - 1.96*se
gen hi = b + 1.96*se
sort k

capture program drop comparar
program define comparar
	args y m
	twoway (rcap lo hi k if spec == "todas", lcolor(navy)) ///
		(rcap lo hi k if spec == "abre", lcolor(maroon)) ///
		(rcap lo hi k if spec == "jardin", lcolor(forest_green)) ///
		(scatter b k if spec == "todas", mcolor(navy)) ///
		(scatter b k if spec == "abre", mcolor(maroon)) ///
		(scatter b k if spec == "jardin", mcolor(forest_green)) ///
		if outcome == "`y'" & mod == "`m'", ///
		yline(0) xline(-0.5, lpattern(dash)) xlabel(-5(1)9) ///
		legend(off) ///
		title("`m'") name(`m', replace)
end

comparar tasa_matricula twfe
comparar tasa_matricula twfe_w
comparar tasa_matricula sa
comparar tasa_matricula sa_w
graph combine twfe twfe_w sa sa_w, ycommon title("tasa_matricula") note("Azul = todas, rojo = abre, verde = jardin")
graph export "$est/ctrl_tasa_matricula.png", replace

comparar tuvo_hijo twfe
comparar tuvo_hijo twfe_w
comparar tuvo_hijo sa
comparar tuvo_hijo sa_w
graph combine twfe twfe_w sa sa_w, ycommon title("tuvo_hijo") note("Azul = todas, rojo = abre, verde = jardin")
graph export "$est/ctrl_tuvo_hijo.png", replace

comparar empleo_formal twfe
comparar empleo_formal twfe_w
comparar empleo_formal sa
comparar empleo_formal sa_w
graph combine twfe twfe_w sa sa_w, ycommon title("empleo_formal") note("Azul = todas, rojo = abre, verde = jardin")
graph export "$est/ctrl_empleo_formal.png", replace

comparar ln_ingreso twfe
comparar ln_ingreso twfe_w
comparar ln_ingreso sa
comparar ln_ingreso sa_w
graph combine twfe twfe_w sa sa_w, ycommon title("ln_ingreso") note("Azul = todas, rojo = abre, verde = jardin")
graph export "$est/ctrl_ln_ingreso.png", replace

comparar meses_trabajando twfe
comparar meses_trabajando twfe_w
comparar meses_trabajando sa
comparar meses_trabajando sa_w
graph combine twfe twfe_w sa sa_w, ycommon title("meses_trabajando") note("Azul = todas, rojo = abre, verde = jardin")
graph export "$est/ctrl_meses_trabajando.png", replace

log close
