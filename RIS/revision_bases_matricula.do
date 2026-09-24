*REVISIÒN DE BASES DE MATRÌCULA EN EDUCACION PARVULARIA 

clear all 
global matricula "Y:\BASES_COMUNES2\MINEDUC\matricula_parvularia"
global salida "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\matricula"

	
*abrimos todos los años y creamos una base que apile todos los datos de todos los años 
forvalues y = 2014/2025 {
	tempfile temp`y'
	pq use "$matricula/`y'/mineduc_matricula_parvularia_`y'_inn.parquet", clear 
	gduplicates report run_alu_inn 
	count 
	compress 
	save `temp`y'', replace 
	}
	
use `temp2014', clear
forvalues y = 2015/2025 {
append using `temp`y''
}

order agno run_alu_inn

*eliminamos variables que no nos sirvan o que no esten en todos los años 
describe
drop ipe_alu
*siempre el mes es agosto
tab mes
drop mes
tab agno
	
*generamos variable de año de nacimiento 
codebook fec_nac_alu
gen anio_nac = floor(fec_nac_alu/100)
replace anio_nac = . if fec_nac_alu == 190001

order agno run_alu_inn

tab marca_rc

*Limpieza de base de matricula -> niños que estan fuera de la muestra 
rename agno anio
tab edad_30_06 anio

*eliminamos a los mayores de 4 
drop if edad_30_06 > 4

*eliminamos los programas alternativos 

* Para JUNJI excluimos el programa "educativo para la familia" y la modalidad "jardin familiar "
tab cod_prog_j
tab cod_prog_j cod_modal_j
drop if cod_prog_j == 3
drop if cod_modal_j == 2 

* Para INTEGRA 
* solo estan disponibles las variables para 2024 y 2025, no las voh a eliminar
tab cod_modal_i
tab cod_modal_i anio

tab cod_prog_i
tab cod_prog_i anio

/*
Modalidades 
14: ?? no esta en el codebook
15: Hogar
16: Hospital
17: Jardín Infantil
19: Jardín Sobre Ruedas (800 cada año, es poco)
20: S.C. Centro Penitenciario
21: Mi Primera Acogida

Programas
1: Jardín Infantil Clásico De Adm.
Directa
2: Jardín Infantil Alternativo o No
Convencionales
*/

tab nivel1 anio 

*Eliminamos a los niños que aparecen dos veces en la base (duplicados) segùn el estàndar de Mineduc 
tab trasladado anio
drop if trasladado == 1 

*Hacemos labels 
label define depe_label 1 "Municipal" 2 "Part Subvencionado" 3 "Part Pagado" 4 "JUNJI" 5 "INTEGRA" 6 "SLEP" 
label values dependencia depe_label

tab nivel2
label define nivel_label 1 "Sala cuna" 2 "Medio" 3 "Transicion"
label values nivel2 nivel_label

label define modalidad_junji_label 1 "Jardín Infantil" 2 "Jardín Familiar" 6 "Jardín Comunic" 7 "Jardín Étnico" 8 "Jardín Laboral" 10 "Jardín Comunitario" 12 "Jardín Comunic 1" 13 "Jardín Comunic 2" 91 "Jardín Comunic 3" 92 "Conozca a su hijo (CASH)" 93 "PMI" 94 "CECI" 95 "Transitorio"
label values cod_modal_j modalidad_junji_label

label define rural_label 0 "Urbano" 1 "Rural"
label values rural_estab rural_label

save "$salida/mat_parv_2014_2025.dta", replace 

	
	
*INFORMACIÒN DE MATRICULA A TRAVES DE LOS AÑOS 

use "$salida/mat_parv_2014_2025.dta", clear


*****************
*TOTAL
*N de matriculados por año. Se ve que disminuye despuès de la pandemia 
preserve 
gcollapse (count) n_matriculados = run_alu_inn, by(anio)
twoway line n_matriculados anio, ylabel(400000(100000)600000) ///
title("Matricula total educ parv 2014-2025 (niños 0-4 modalidades trad)", size(medium)) ///
xlabel(2014(1)2025)
list
restore

*****************
*DEPENDENCIA 
* n de matriculados por dependencia 
tab dependencia anio 

preserve 
gcollapse (count) n = run_alu_inn, by(anio dependencia)
gen n_miles = n/1000
twoway line n_miles anio, by(dependencia, title("Matriculados por dependencia 2014-2025 (0-4  trad)", size(medium))) ///
ytitle("Matriculados (miles)")
restore
	
*****************
*NIVEL
*por nivel 
*nivel1 es Clasificación de los alumnos en 6 niveles (menor y mayor en cada nivel)

preserve 
gcollapse (count) n = run_alu_inn, by(anio nivel2)
gen n_miles = n/1000
twoway line n_miles anio, by(nivel2)
restore
*predomina para todos los años la cantidad de nivel de transiciòn 


*****************
* EDAD
*INFO DE EDAD 
tab edad_30_06 anio

preserve 
gcollapse (count) n = run_alu_inn, by(anio edad)
bysort anio: egen total_anio = total(n)
gen pct_edad = 100*n/total_anio
twoway line pct_edad anio, by(edad, title("Pct por edad 2014-2025 (0-4  trad)", size(medium)))
restore 



	
*****************
*REGION
preserve 
gcollapse (count) n = run_alu_inn, by(anio cod_reg_estab)
gen n_miles = n/1000
sort cod_reg_estab anio 
separate n_miles, by(cod_reg_estab) generate(reg)
twoway line reg* anio
restore 

tab nom_reg_estab nio
*no estan unificados los strings 
tab cod_reg_estab anio
*2 de 5mm son de la RM 


	
*****************
*URBANO VS RURAL 


preserve 
gcollapse (count) n = run_alu_inn, by(anio rural_estab)
gen n_miles = n/1000
twoway line n_miles anio, by(rural_estab)
restore

	
*****************
*ASISTENCIA PROMEDIO JUNJI -> no nos dice nada esta variable 

codebook asis_real_j
preserve 
keep if dependencia == 4 
gcollapse (mean) asis_real_prom = asis_real_j (count) n = run_alu_inn, by(anio)
twoway line asis_real_prom anio
restore

	
	
	
	
	
	
	
	