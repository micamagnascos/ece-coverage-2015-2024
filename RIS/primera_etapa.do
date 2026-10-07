*PRIMERA ETAPA - MATRICULA 
*SEGUIR CON ESTA BASE, OJO CON LAS VAR DE TRAT QUE YA VAN A VENIR DE ANTES 

clear all 
ssc install eventstudyinteract 
ssc install avar 

global matricula "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\matricula"
global hijos "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\hijos"
global muestra "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra"


*abrimos base hijos 
use "$hijos/hijos_filtrado_2014_2024.dta", clear
describe, fullnames
gduplicates report rut_inn //madres. si hay duplicados porque pueden tener varios hijos 
gduplicates report run_hijo_inn

*tenemos que pasarla a panel año primero porque el listado de madres tratadas esta en panel 
gen anio_ini = anio_nac_hijo 
gen anio_fin = anio_nac_hijo + 4 

replace anio_fin = anio_def_hijo if !missing(anio_def_hijo) & anio_def_hijo < anio_fin

gen n_anios = anio_fin - anio_ini + 1 

count if n_anios <= 0 
*assert n_anios > 0 
drop if n_anios <= 0

expand n_anios  
bysort run_hijo_inn: gen anio = anio_nac_hijo + _n - 1 

drop anio_fin n_anios 

duplicates report run_hijo_inn anio 
count 

*hacemos merge con los rut de sus madres para saber que "hijos" son tratados 
merge m:1 rut_inn anio using "$muestra/muestra_completa_ruts_trat.dta"

*los que no hicieron merge no los necesitamos, los que si hicieron merge son los hijos de las madres de mi muestra 
keep if _merge == 3 
drop _merge 

describe, fullnames 

tab anio_ini

tab tratada 


gduplicates report run_hijo_inn anio
*no hay duplicados 

*MERGE CON LA BASE DE MATRICULA 
describe using "$matricula/mat_parv_2014_2025.dta"

rename run_hijo_inn run_alu_inn 

merge 1:m run_alu_inn anio using "$matricula/mat_parv_2014_2025.dta"

*merge 2: estan en matricula pero no son hijos de las madres de mi muestra 
*merge 1: no estan matriculados ese año, no botar 

count if _merge == 2 

gen matriculado = (_merge==3)

describe, fullnames 
drop latitud longitud 
drop marca_rc nom_pro_estab let_cur_m nom_deprov_estab cod_deprov_estab dias_trab_grupo_j nom_jor_j desc_mod_i desc_nivel_i cod_grupo_i formal corr_gru_j let_gru_j
drop fec_nac_alu_inn fec_ret_estab_m_inn cod_tip_cur_m cod_mac_estab cod_jor_i cod_provincia

drop if _merge == 2 
describe, fullnames 
drop anio_nac
drop _merge 

tab matriculado
tab anio matriculado

gsort run_alu_inn anio 

*cuàntos niños aparecen en el panel en algun año?
egen tag_nino = tag(run_alu_inn)
count if tag_nino == 1 
*2,684,829

* cuàntos niños son tratados?
bysort run_alu_inn: egen tratado_nino = max(!missing(rel_t1))
count if tag_nino == 1 & tratado_nino == 1 
*  221,199

compress
save "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\primera etapa/primera_etapa_panel.dta", replace 

describe, fullnames
 
*** 
* VERSION COLAPSADA A NIVEL UV 
preserve 
gcollapse (mean) tasa_matricula=matriculado (count) n_ninos = run_alu_inn (mean) g1 post_t1 rel_t1 grupo_t1 muestra_t1 stock_base, by(id_uv_2024 anio)
save "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\primera etapa/primera_etapa_panel_uv.dta", replace 
restore 


*****************************************************************************
*ANALISIS PRIMERA ETAPA 

*A NIVEL UV 
use "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\primera etapa/primera_etapa_panel_uv.dta", clear 

duplicates report id_uv_2024 anio 
assert post_t1 == round(post_t1)
assert g1== round(g1)


*dejamos solo a los not yet treated y never treated en 2014, dejamos fuera a las excluidas (las uv que ya tenian jardin)
keep if muestra_t1 == 1
tab grupo_t1
sum n_ninos, detail 
*deberiamos ponderar por n_ninos porque las colas superiores son muy altas 

*el probelma esta en la cola izquierda 
tab rel_t1
*las nunca tratadas tienen el time to event missing, las voy a meter todas en el periodo de ref
* Se agrupa la cola izquierda (rel_t1 < -5) porque hay muy pocas UVs en esos periodos lejanos, separarlos en dummies individuales daría coeficientes muy ruidosos (poca data cada uno), agruparlos en una sola categoría da una estimación más estable.
gen rel_t1_bin = rel_t1 
replace rel_t1_bin = -5 if rel_t1 < -5 & !missing(rel_t1)
replace rel_t1_bin = -1 if missing(rel_t1)


*GRAFICOS TIME TO EVENT 
*Gráficos solo para las tratadas 
*Agrupando primeros años 
preserve 
keep if grupo_t1 == 3 
collapse (mean) tasa_matricula (count) n_uv = id_uv_2024, by(rel_t1_bin)
twoway line tasa_matricula rel_t1_bin, sort xline(0, lcolor(red)) title("Matricula promedio de UV tartadas por tiempo relativo a la apertura", size(medsmall))
restore

*No agrupando primeros años 
preserve 
keep if grupo_t1 == 3 
collapse (mean) tasa_matricula (count) n_uv = id_uv_2024, by(rel_t1)
twoway line tasa_matricula rel_t1, sort xline(0, lcolor(red)) title("Matricula promedio de UV tartadas por tiempo relativo a la apertura", size(medsmall))
restore


*REGRESIONES

tab rel_t1_bin, gen(d)

reghdfe tasa_matricula d1 d2 d3 d4 d6 d7 d8 d9 d10 d11, absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
estimates store sinpond

* chequeo de pre-tendencia -- tiene que ir INMEDIATAMENTE despues de este
* reghdfe (no despues del eventstudyinteract, sus coeficientes no se llaman
* "d1","d2",... -- ver la misma correccion en fertilidad/laboral)
test d1 d2 d3 d4

* efecto resumen post-tratamiento del TWFE (aprox. simple ecuacion 31, Sec. 5.2.4)
lincom (d6 + d7 + d8 + d9 + d10 + d11)/6

reghdfe tasa_matricula d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 [aweight=n_ninos], absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
estimates store ponderado

gen nunca_tratada = (g1==0)
*solo dentro de las tratadas
eventstudyinteract tasa_matricula d1 d2 d3 d4 d6 d7 d8 d9 d10 d11, cohort(g1) control_cohort(nunca_tratada)  absorb(id_uv_2024 anio) vce(cluster id_uv_2024)

matrix list e(b_iw)

* version ponderada por n_ninos -- pendiente que faltaba, el paper pondera
* por poblacion en TODAS sus figuras (Figuras 6-9), consistente con el TWFE
eventstudyinteract tasa_matricula d1 d2 d3 d4 d6 d7 d8 d9 d10 d11 [aweight=n_ninos], cohort(g1) control_cohort(nunca_tratada) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)


******************************************************************************
* GRAFICO PARA LA REUNION: event study de la primera etapa, analogo Figura 8
* (Seccion 5.2.4). Esto es lo que pidieron mostrar en formato grafico.

* --- 11a: grafico del TWFE de referencia ---
* vuelve a correr el reghdfe SIN ponderar (linea de arriba, antes del test)
* inmediatamente antes de este bloque si corriste algo mas en el medio
matrix T = r(table)
preserve
clear
set obs 11
gen k = _n - 6
* k = -5,-4,-3,-2,-1,0,1,2,3,4,5 (ventana de este spec, no llega a +9)
gen coef = 0 if k==-1
gen se = 0 if k==-1
forvalues t = -5/5 {
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
    ytitle("Efecto sobre tasa de matricula") xtitle("Tiempo relativo (k)") legend(off) ///
    title("Event study TWFE (referencia) -- primera etapa", size(small))
graph export "primera_etapa_eventstudy_twfe.png", replace width(1200)
restore

* --- 11b: grafico del estimador robusto (Sun-Abraham) -- EL QUE PIDIERON ---
* vuelve a correr el eventstudyinteract SIN ponderar (el de mas arriba, antes
* de la version [aweight=n_ninos]) inmediatamente antes de este bloque
matrix T = r(table)
preserve
clear
set obs 11
gen k = _n - 6
gen coef = 0 if k==-1
gen se = 0 if k==-1
forvalues t = -5/5 {
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
    ytitle("Efecto sobre tasa de matricula") xtitle("Tiempo relativo (k)") legend(off) ///
    title("Event study robusto (Sun-Abraham) -- primera etapa", size(small))
graph export "primera_etapa_eventstudy_robusto.png", replace width(1200)
restore

* --- 11c: version ponderada del grafico robusto (opcional, para comparar) ---
* vuelve a correr el eventstudyinteract [aweight=n_ninos] inmediatamente antes
matrix T = r(table)
preserve
clear
set obs 11
gen k = _n - 6
gen coef = 0 if k==-1
gen se = 0 if k==-1
forvalues t = -5/5 {
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
    ytitle("Efecto sobre tasa de matricula") xtitle("Tiempo relativo (k)") legend(off) ///
    title("Event study robusto ponderado (Sun-Abraham) -- primera etapa", size(small))
graph export "primera_etapa_eventstudy_robusto_ponderado.png", replace width(1200)
restore












*****************************************************************************************************

*sube la matricula de los que son tratados?
preserve 
collapse (mean) matriculado, by(time_to_event)
list
twoway connected matriculado time_to_event, xline(0) title("Matricula en jardin, hijos de madres tratadas") xtitle("años relativos a la apertura del jardin (k=0)") ytitle("Tasa de matricula") xlabel(-10(2)10)
restore


*sube la matrìcula despuès de que se abre el jardìn, una vez que controlamos por diferencias de UVs y las tendencias generales de cada año?
gen post= (time_to_event >= 0) if !missing(time_to_event)
reghdfe matriculado post, absorb(id_uv_2024 anio) cluster(id_uv_2024)


* como afecta para cada time to event 
gen k_reg = time_to_event
replace k_reg = 99 if missing(time_to_event)

which reghdfe
describe k_reg

tab k_reg, gen(kd)
tab k_reg kd


reghdfe matriculado kd1-kd9 kd11-kd20, absorb(id_uv_2024 anio) cluster(id_uv_2024)


*comparacion matricula de los tratados con los no tratados 
preserve 
keep if tratado == 0 
collapse (mean) matriculado_ctrl = matriculado, by(anio)
tempfile control_anio 
save `control_anio'
restore 

merge m:1 anio using `control_anio'
drop _merge 

preserve
collapse (mean) matriculado matriculado_ctrl, by(time_to_event)
twoway (connected matriculado time_to_event) (connected matriculado_ctrl time_to_event), xline(0) title("matricula: tratados vs no tratados") legend(order(1 "Tratados" 2 "No tratados"))
restore

describe, fullnames 
drop cod_pro_estab

keep rut_inn run_alu_inn nacionalidad_hijo anio_nac_hijo anio_def_hijo anio codigo_uv_rsh id_uv_2024 tratada gen_alu edad_30_06 cod_reg_estab cod_com_estab dependencia nivel1 nivel2 cod_prog_j fec_inc_estab* edad matriculado anio* time_to_event post

tab dependencia 
*ojo, igual hay algunos en privado o subv

compress
save "$matricula/panel_mat_hijos.dta", replace




*PRIMERA ETAPA A NIVEL UV 

gcollapse (mean) matriculado, by(id_uv_2024 anio time_to_event post)

gen k_reg = time_to_event
replace k_reg = 99 if missing(time_to_event)

reghdfe matriculado post, absorb(id_uv_2024 anio) cluster(id_uv_2024)

preserve 
collapse (mean) matriculado, by(time_to_event)
twoway connected matriculado time_to_event, xline(0) title("Matricula en jardin infantil a nivel UV") xtitle("años relativos a la apertura del jardin (k=0)") ytitle("Tasa de matricula promedio UV")
restore 

preserve
keep if k_reg == 99
collapse (mean) matriculado_ctrl = matriculado, by(anio)
tempfile control_anio_uv
save `control_anio_uv'
restore

merge m:1 anio using `control_anio_uv'
drop _merge 

preserve
collapse (mean) matriculado matriculado_ctrl, by(time_to_event)
twoway (connected matriculado time_to_event) (connected matriculado_ctrl time_to_event), xline(0) title("matricula: tratados vs no tratados NIVEL UV") legend(order(1 "Tratados" 2 "No tratados"))
restore

tab k_reg, gen(kd)
tab k_reg
drop kd10
reghdfe matriculado kd*, absorb(id_uv_2024 anio) cluster(id_uv_2024)









