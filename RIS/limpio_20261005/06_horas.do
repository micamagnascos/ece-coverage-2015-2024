* 06_HORAS, BUSQUEDA Y CUIDADO -- 06/10/2026
* outcomes RSH (autorreportados): horas (limpia, > 100 = missing), busca (busco trabajo), cuida / hogar / cuida_hogar (no busca por cuidado de ninos = 2, quehaceres = 1)
* mismos 4 modelos que 02

clear all
global codigo "ESCRIBIR_CARPETA_DE_LOS_DO"
do "$codigo/00_setup.do"
capture log close
log using "$est/log_horas_20261006.txt", text replace


* 1. LIMPIEZA A NIVEL MUJER Y PROMEDIO POR UV-AÑO
use id_uv_2024 anio muestra_t1 per_fic_horastrabajo per_fic_buscotrabajo per_fic_nobuscotrabajomotivo using "$muestra/muestra_laboral_ingresos.dta", clear
keep if muestra_t1 == 1
replace per_fic_horastrabajo = . if per_fic_horastrabajo > 100
sum per_fic_horastrabajo, detail
tab per_fic_buscotrabajo, missing
tab per_fic_nobuscotrabajomotivo, missing
gen cuida = (per_fic_nobuscotrabajomotivo == 2)
gen hogar = (per_fic_nobuscotrabajomotivo == 1)
gen cuida_hogar = (cuida == 1 | hogar == 1)
tab cuida hogar
gcollapse (mean) horas = per_fic_horastrabajo busca = per_fic_buscotrabajo cuida hogar cuida_hogar (count) n_horas = per_fic_horastrabajo n_busca = per_fic_buscotrabajo, by(id_uv_2024 anio)
sum horas busca cuida hogar cuida_hogar n_horas n_busca
save "$muestra/horas_uv.dta", replace


* 2. BASE UV-AÑO
use "$muestra/muestra_laboral_ingresos_v2.dta", clear
merge 1:1 id_uv_2024 anio using "$muestra/horas_uv.dta"
tab _merge
drop _merge
gen nunca_tratada = (g1 == 0)
gen rel_t1_bin = rel_t1
replace rel_t1_bin = -5 if rel_t1 < -5
replace rel_t1_bin = -1 if missing(rel_t1)
tab rel_t1_bin, gen(d)
count if missing(d1)


* 3. ESTIMACIONES
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

capture postclose pf
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctrl using "$est/coefs_horas.dta", replace
est4 horas n_horas rsh per_edad
est4 busca n_busca rsh per_edad
est4 cuida n_mujeres rsh per_edad
est4 hogar n_mujeres rsh per_edad
est4 cuida_hogar n_mujeres rsh per_edad
postclose pf


* 4. REVISAR
use "$est/coefs_horas.dta", clear
list modelo outcome k b se N n_uv media_ctrl if k == 0 | k == 99 | k == -99, sepby(outcome)

grafico coefs_horas horas sa_rsh
graph export "$est/horas_sa.png", replace
grafico coefs_horas horas sa_w_rsh
graph export "$est/horas_sa_w.png", replace

grafico coefs_horas busca sa_rsh
graph export "$est/busca_sa.png", replace
grafico coefs_horas busca sa_w_rsh
graph export "$est/busca_sa_w.png", replace

grafico coefs_horas cuida sa_rsh
graph export "$est/cuida_sa.png", replace
grafico coefs_horas cuida sa_w_rsh
graph export "$est/cuida_sa_w.png", replace

grafico coefs_horas hogar sa_rsh
graph export "$est/hogar_sa.png", replace
grafico coefs_horas hogar sa_w_rsh
graph export "$est/hogar_sa_w.png", replace

grafico coefs_horas cuida_hogar sa_rsh
graph export "$est/cuida_hogar_sa.png", replace
grafico coefs_horas cuida_hogar sa_w_rsh
graph export "$est/cuida_hogar_sa_w.png", replace

log close
