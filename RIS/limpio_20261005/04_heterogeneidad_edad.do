* 04_HETEROGENEIDAD POR EDAD -- 06/10/2026
* grupos: 1 = 0-1 años (sala cuna), 2 = 2-3 años (medio), 3 = 4 años (transicion)

clear all
global codigo "ESCRIBIR_CARPETA_DE_LOS_DO"
do "$codigo/00_setup.do"
capture log close
log using "$est/log_het_20261006.txt", text replace


* A. PRIMERA ETAPA POR EDAD DEL NIÑO

use "$pe/primera_etapa_panel.dta", clear
describe anio_nac_hijo muestra_t1 g1 rel_t1
keep if muestra_t1 == 1
gduplicates report run_alu_inn anio
gduplicates drop run_alu_inn anio, force
gen edad = anio - anio_nac_hijo
tab edad
gen g_edad = 1 if edad <= 1
replace g_edad = 2 if edad == 2 | edad == 3
replace g_edad = 3 if edad == 4

gcollapse (mean) tasa_matricula = matriculado (count) n_ninos = matriculado (firstnm) g1 rel_t1, by(id_uv_2024 anio g_edad)
gduplicates report id_uv_2024 anio g_edad

gen nunca_tratada = (g1 == 0)
gen rel_t1_bin = rel_t1
replace rel_t1_bin = -5 if rel_t1 < -5
replace rel_t1_bin = -1 if missing(rel_t1)
tab rel_t1_bin, gen(d)
count if missing(d1)

capture postclose pf
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctrl using "$est/coefs_het_pe.dta", replace

forvalues e = 1/3 {
	sum tasa_matricula if nunca_tratada == 1 & g_edad == `e'
	local m0 = r(mean)

	reghdfe tasa_matricula d1-d4 d6-d15 if g_edad == `e', absorb(id_uv_2024 anio) cluster(id_uv_2024)
	guardar twfe_e`e' tasa_matricula `m0'

	eventstudyinteract tasa_matricula d1-d4 d6-d15 if g_edad == `e', cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
	guardar sa_e`e' tasa_matricula `m0'
}
postclose pf


* B. EDAD DEL HIJO MENOR (madre-año)

use "$pe/primera_etapa_panel.dta", clear
gcollapse (max) nac_menor = anio_nac_hijo, by(rut_inn anio)
gen edad_menor = anio - nac_menor
tab edad_menor
save "$muestra/edad_hijo_menor.dta", replace


* C. LABORAL POR EDAD DEL HIJO MENOR

use "$muestra/muestra_laboral_ingresos.dta", clear
keep if muestra_t1 == 1
keep rut_inn anio id_uv_2024 g1 rel_t1 renta_imponible_anual monto_dep_anual monto_indep_anual

merge 1:1 rut_inn anio using "$muestra/edad_hijo_menor.dta"
tab _merge
keep if _merge == 3
drop _merge

egen monto_cot = rowtotal(monto_dep_anual monto_indep_anual), missing
gen ingreso_anual = renta_imponible_anual
replace ingreso_anual = monto_cot if missing(renta_imponible_anual)
gen ln_ingreso = ln(ingreso_anual) if ingreso_anual > 0
gen empleo_formal = (ingreso_anual > 0 & !missing(ingreso_anual))

gen g_edad = 1 if edad_menor <= 1
replace g_edad = 2 if edad_menor == 2 | edad_menor == 3
replace g_edad = 3 if edad_menor == 4
tab g_edad

gen uno = 1
gcollapse (mean) empleo_formal ln_ingreso (sum) n_mujeres = uno (firstnm) g1 rel_t1, by(id_uv_2024 anio g_edad)
gduplicates report id_uv_2024 anio g_edad

gen nunca_tratada = (g1 == 0)
gen rel_t1_bin = rel_t1
replace rel_t1_bin = -5 if rel_t1 < -5
replace rel_t1_bin = -1 if missing(rel_t1)
tab rel_t1_bin, gen(d)
count if missing(d1)

capture postclose pf
postfile pf str20 modelo str20 outcome k b se N n_uv media_ctrl using "$est/coefs_het_lab.dta", replace

foreach y in empleo_formal ln_ingreso {
	forvalues e = 1/3 {
		sum `y' if nunca_tratada == 1 & g_edad == `e'
		local m0 = r(mean)

		reghdfe `y' d1-d4 d6-d15 if g_edad == `e', absorb(id_uv_2024 anio) cluster(id_uv_2024)
		guardar twfe_e`e' `y' `m0'

		eventstudyinteract `y' d1-d4 d6-d15 if g_edad == `e', cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
		guardar sa_e`e' `y' `m0'
	}
}
postclose pf


* D. REVISAR
use "$est/coefs_het_pe.dta", clear
list modelo k b se N n_uv if k == 0 | k == 2
grafico coefs_het_pe tasa_matricula sa_e1
grafico coefs_het_pe tasa_matricula sa_e2
grafico coefs_het_pe tasa_matricula sa_e3

use "$est/coefs_het_lab.dta", clear
list modelo outcome k b se N n_uv if k == 0 | k == 2, sepby(outcome)
grafico coefs_het_lab empleo_formal sa_e1
grafico coefs_het_lab empleo_formal sa_e2

log close
