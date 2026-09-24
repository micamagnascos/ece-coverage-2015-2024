**********************************************************************
* PROCESAMIENTO BASE COTIZACIONES (Super Intendencia de Pensiones)
* para incorporar informaciòn laboral de personas independientes, sector pùblico y fuerzas armadas 


clear all
set more off

global cotizaciones "Y:\BASES_COMUNES2\Super_Pensiones\COTIZACIONES"
global salida "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\cotizaciones"


*Bases semestrales desde 2015-2025
*Loop por año y por semestre 

forv anio = 2015/2025 {
	
	*primer semestre disponible es el segundo de 2015
	local semestres "06 12"
	if `anio' == 2015 local semestres "12"
	
	foreach sem of local semestres {
	
		local per = `anio' * 100 + `sem'
		local archivo "$cotizaciones/`anio'/sdp_cotizaciones_`per'_inn.parquet"
		
		capture confirm file "`archivo'"
		if _rc {
			di as error "No existe `archivo' - se salta"
			continue 
		}
		
		pq use "`archivo'", clear 
		di as text "`per': `=_N' obs crudas"
		
		rename *, lower
		cap rename run_inn rut_inn
		cap rename nuevo_run_falso rut_inn
		cap rename periodo dn_mes_devengamiento
		cap rename mes_pension dn_mes_devengamiento 
		cap rename periododev dn_mes_devengamiento
		
		if `anio' >= 2025 {
			*a partir de 2025 cambia la estructura de la base, contempla rut del emplador 
			gen indep=0
			replace indep=1 if (mcci_codigomov==11084 | mcci_codigomov==11085 | mcci_codigomov==11086)
			replace indep=1 if ((mcci_codigomov==11010 | mcci_codigomov==11001) & (rut_inn==rut_empleador_inn))
			gen dep = 1 if indep == 0
			replace dep = 0 if indep == 1
			
			gen monto_dep = cotizacion if dep == 1
			gen monto_indep = cotizacion if indep==1
			replace monto_indep = 0 if monto_indep == . 
			replace monto_dep = 0 if monto_dep == .
			
			cap drop remuneracion_imp mcci_actecoempl mcci_codigomov mcci_tipoplanilla dep indep rut_empleador_inn
			}
		
		else {
		*estandarizar nombres 
			cap rename cotizacion monto_dep
			cap gen monto_indep = . 
			cap drop ind dep deuda 
		}
		
		*filtrar por ruts del panel 
		merge m:1 rut_inn using "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\bases_muestra/ruts_panel_2016_2024.dta", keep(match) nogenerate 
		
		di as text "`per': `=_N' obs tras filtro por RUT"
		
		keep rut_inn dn_mes_devengamiento monto_dep monto_indep
		
		replace monto_indep = 0 if monto_indep == . 
		drop if monto_dep == 0 & monto_indep == 0 

		*sumar montos de personas que pueden tener dos trabajos o màs el mismo mes 
		collapse (sum) monto_dep monto_indep, by(rut_inn dn_mes_devengamiento)
		
		gen archivo_fecha = `per' //marca de que archivo viene 
		
		compress
		pq save "$salida/afp_filtrado_`per'.parquet", replace 
		
		}

}



*Apilamos todos los archivos (todos los años y semestres)

clear 
tempfile acumulado 
local n_archivos = 0 

forv anio = 2015/2025 {
	local semestres "06 12"
	if `anio' == 2015 local semestres "12"
	
	foreach sem of local semestres {
		local per = `anio' * 100 + `sem'
		
		capture confirm file "$salida/afp_filtrado_`per'.parquet"
		
		if !_rc {
			local n_archivos = `n_archivos' + 1 
			if `n_archivos' == 1 {
				pq use "$salida/afp_filtrado_`per'.parquet", clear
			}
		else {
			pq append using "$salida/afp_filtrado_`per'.parquet"
			}

		}

	}
}
di as result "Total tras apilar: `=_N' obs (rut-mes-archivo), de `n_archivos' archivos"




*Eliminamos duplicados exactos entre archivos (rt, mes y monto)  - se pueden repetir las obs entre archivos porque son fotos que incluyen datos dos años hacia atràs
gduplicates drop rut_inn dn_mes_devengamiento monto_dep monto_indep, force 

*Traslape con totales DISTINTOS entre archivos: el archivo màs reciente gana, mejor aproximaciòn disponible al total mas completo que incluya todos los montos del mes 
bysort rut_inn dn_mes_devengamiento (archivo_fecha): keep if _n == _N 
drop archivo_fecha 

isid rut_inn dn_mes_devengamiento // tiene que ser ùnico a este punto 


*Ajuste de unidad (sacado por contexto)
replace monto_dep = monto_dep * 10
replace monto_indep = monto_indep * 10 


*Colapsar por persona-año con dep/indep separados 
gen anio = floor(dn_mes_devengamiento/100)
gen cotizo_dep_mes = (monto_dep > 0)
gen cotizo_indep_mes = (monto_indep > 0)

collapse (sum) monto_dep_anual = monto_dep (sum) monto_indep_anual = monto_indep (sum) meses_cotizados_dep = cotizo_dep_mes (sum) meses_cotizados_indep = cotizo_indep_mes (count) meses_cotizados_total = dn_mes_devengamiento, by(rut_inn anio)

*solo tenemos obs de diciembre 2013, mejor eliminar por completo ese año porque no es representativo 
drop if anio == 2013

gen trabajo_dep = (meses_cotizados_dep > 0)
gen trabajo_indep = (meses_cotizados_indep > 0)
gen trabajo_binario_cotiz = (meses_cotizados_total > 0)

gen tipo_cotizante_anual = 0 
replace tipo_cotizante_anual = 1 if trabajo_dep == 1 & trabajo_indep == 0
replace tipo_cotizante_anual = 2 if trabajo_dep == 0 & trabajo_indep == 1
replace tipo_cotizante_anual = 3 if trabajo_dep == 1 & trabajo_indep == 1
label define tipo_cot 0 "ninguno" 1 "solo dependiente" 2 "solo independiente" 3 "mixto"
label values tipo_cotizante_anual tipo_cot

isid rut_inn anio 
tab anio 
tab tipo_cotizante_anual 
summ meses_cotizados_total meses_cotizados_dep meses_cotizados_indep
summ monto_dep_anual monto_indep_anual, detail 



*guardamos base final 
compress 
save "$salida/panel_cotizaciones_run_anio.dta", replace 

di as result "Panel final: `=_N' obs persona-año"



*eliminamos los archivos temp
forv anio = 2015/2025 {
	local semestres "06 12"
	if `anio' == 2015 local semestres "12"
	foreach sem of local semestres {
	local per = `anio' * 100 + `sem'
	capture erase "$salida/afp_filtrado_`per'.parquet"
	}
}


**************************************************************************************


use "$salida/panel_cotizaciones_run_anio.dta", clear

tab anio

tab anio tipo_cotizante_anual


tab meses_cotizados_total

summ monto_dep_anual if monto_dep_anual > 0, detail


summ monto_indep_anual if monto_indep_anual > 0, detail












