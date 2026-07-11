*ESTUDIO CP
* actualización -> 15/06
*===================================================================
* LIMPIEZA BASES JUNJI E INTEGRA
*
* JUNJI: importa base de transparencia, colapsa a una fila por
* establecimiento (matrícula total, programa y modalidad principal),
* filtra establecimientos abiertos hasta 2023 y descarta programas/
* modalidades que implican esfuerzo directo de las madres.
* Output: data/build/junji_limpia.{dta,csv,xlsx}
*
* INTEGRA: construye tabla de concordancia para corregir el cambio
* de códigos por la creación de la región de Ñuble (2018), arma panel
* 2015-2024 por establecimiento, corrige códigos Ñuble, filtra
* modalidades de interés y genera anio_apertura/anio_termino.
* Output: data/build/integra_limpia.{dta,csv,xlsx}
*
* Rutas relativas a la raíz del proyecto: correr vía run_all.do o con
* el directorio de trabajo ya posicionado en la raíz del repo.
*===================================================================

capture program drop estandarizar_strings
program define estandarizar_strings

    ds, has(type string)
    foreach var of varlist `r(varlist)' {

        replace `var' = trim(`var')
        replace `var' = itrim(`var')

        * mayúsculas acentuadas y especiales
        replace `var' = subinstr(`var', "Á", "a", .)
        replace `var' = subinstr(`var', "É", "e", .)
        replace `var' = subinstr(`var', "Í", "i", .)
        replace `var' = subinstr(`var', "Ó", "o", .)
        replace `var' = subinstr(`var', "Ú", "u", .)
        replace `var' = subinstr(`var', "Ñ", "n", .)
        replace `var' = subinstr(`var', "Ã", "n", .)
		replace `var' = subinstr(`var', "Ü", "u", .)

        replace `var' = lower(`var')

        * minúsculas acentuadas y especiales
        replace `var' = subinstr(`var', "á", "a", .)
        replace `var' = subinstr(`var', "é", "e", .)
        replace `var' = subinstr(`var', "í", "i", .)
        replace `var' = subinstr(`var', "ó", "o", .)
        replace `var' = subinstr(`var', "ú", "u", .)
        replace `var' = subinstr(`var', "ñ", "n", .)
        replace `var' = subinstr(`var', "ü", "u", .)
    }

end


***************************
/* Importar base bruta de JUNJI (transparencia) y revisar estructura:
   fechas de cierre, programas y modalidades disponibles */

*JUNJI
import excel "data/raw/junji.xlsx", ///
    sheet("Base") firstrow clear

describe
tab FECHA_CIERRE
tab PROGRAMA
tab MODALIDAD

tab PROGRAMA MODALIDAD

*cambio de codigo ñuble
list COD_ESTABLEC COD_ESTABLECantiguo if COD_ESTABLEC != COD_ESTABLECantiguo
* todos de la región del ñuble, si es que usamos el codigo nuevo deberíamos estar bien


*no me importa que dividia por sala ni por jornada
collapse (sum) MATRICULAPROMEDIO, ///
    by(FECHA_APERTURA FECHA_CIERRE REGION COMUNA DIRECCIÓN LATITUD LONGITUD COD_ESTABLEC COD_ESTABLECantiguo NOMBRE_JARDIN NIVEL NIVEL NUM_GRUPO PROGRAMA MODALIDAD)

sort COD_ESTABLEC

*crear dummies de programas, porque un mismo establecimiento puede tener más de uno al mismo tiempo
bysort COD_ESTABLEC: egen d_prog_convenio_alimentacion = max(PROGRAMA == "Convenio Alimentación")
bysort COD_ESTABLEC: egen d_prog_educ_familia          = max(PROGRAMA == "Educativo para la Familia")
bysort COD_ESTABLEC: egen d_prog_alternativo           = max(PROGRAMA == "Jardín Infantil Alternativo")
bysort COD_ESTABLEC: egen d_prog_clasico_terceros      = max(PROGRAMA == "Jardín Infantil Clásico Adm. por Terc..")
bysort COD_ESTABLEC: egen d_prog_clasico_directa       = max(PROGRAMA == "Jardín Infantil Clásico de Adm. Directa")
bysort COD_ESTABLEC: egen d_prog_transitorio           = max(PROGRAMA == "Transitorio")

*crear dummies de modalidad
bysort COD_ESTABLEC: egen d_mod_cash             = max(MODALIDAD == "CASH")
bysort COD_ESTABLEC: egen d_mod_ceci             = max(MODALIDAD == "CECI")
bysort COD_ESTABLEC: egen d_mod_comunicacional   = max(MODALIDAD == "Jardín Comunicacional")
bysort COD_ESTABLEC: egen d_mod_comunitario      = max(MODALIDAD == "Jardín Comunitario")
bysort COD_ESTABLEC: egen d_mod_familiar         = max(MODALIDAD == "Jardín Familiar")
bysort COD_ESTABLEC: egen d_mod_jardin_infantil  = max(MODALIDAD == "Jardín Infantil")
bysort COD_ESTABLEC: egen d_mod_estacional       = max(MODALIDAD == "Jardín Infantil Estacional")
bysort COD_ESTABLEC: egen d_mod_verano           = max(MODALIDAD == "Jardín Infantil de Verano")
bysort COD_ESTABLEC: egen d_mod_laboral          = max(MODALIDAD == "Jardín Laboral")
bysort COD_ESTABLEC: egen d_mod_etnico           = max(MODALIDAD == "Jardín Étnico")
bysort COD_ESTABLEC: egen d_mod_pmi              = max(MODALIDAD == "PMI")

bysort COD_ESTABLEC: egen matricula_total = total(MATRICULAPROMEDIO)


*Calcular matrícula total y matrícula por programa/modalidad, para definir cuál programa y modalidad es el "principal" de cada establecimiento (el de mayor matrícula)
* Matrícula acumulada por establecimiento+programa y establecimiento+modalidad
bysort COD_ESTABLEC PROGRAMA: egen mat_by_programa = total(MATRICULAPROMEDIO)
bysort COD_ESTABLEC MODALIDAD: egen mat_by_modalidad = total(MATRICULAPROMEDIO)

gen main_programa  = ""
gen main_modalidad = ""

*dejamos como programa y modalidad main a los que reporten una mayor matrícula, porque hay jardines que tienen mas de una modalidad o programa
bysort COD_ESTABLEC (mat_by_programa):  replace main_programa  = PROGRAMA[_N]
bysort COD_ESTABLEC (mat_by_modalidad): replace main_modalidad = MODALIDAD[_N]

drop mat_by_programa mat_by_modalidad

*dejamos una fila por establecimiento, ya tenemos info de modalidades
collapse (first) FECHA_APERTURA FECHA_CIERRE REGION COMUNA ///
                 DIRECCIÓN LATITUD LONGITUD NOMBRE_JARDIN ///
                 matricula_total main_programa main_modalidad ///
                 d_prog_* d_mod_*, by(COD_ESTABLEC)

count if LATITUD==0

describe FECHA_APERTURA

*nos quedamos con los que abrieron antes de 2024

*no tengo fecha de cierre!! debería pedirla por transaprencia
*drop if FECHA_APERTURA > td(31dec2024)

drop if FECHA_APERTURA > td(31dec2023)

duplicates report COD_ESTABLEC
*4286 contando todos los tipos de establecimiento

tab main_programa

/*
. tab main_programa

                  (first) main_programa |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                  Convenio Alimentación |         73        1.69        1.69
              Educativo para la Familia |        485       11.26       12.95
            Jardín Infantil Alternativo |        782       18.15       31.10
Jardín Infantil Clásico Adm. por Terc.. |      1,862       43.21       74.31
Jardín Infantil Clásico de Adm. Directa |        898       20.84       95.15
                            Transitorio |        209        4.85      100.00
----------------------------------------+-----------------------------------
                                  Total |      4,309      100.00

*/


rename DIRECCIÓN direccion
rename COD_ESTABLEC codigo_junji
rename FECHA_APERTURA fecha_apertura
rename FECHA_CIERRE fecha_cierre
rename REGION nom_region
rename COMUNA comuna
rename LONGITUD longi
rename LATITUD lat
rename NOMBRE_JARDIN nom_estab
rename matricula_total matricula
rename main_programa programa
rename main_modalidad modalidad

estandarizar_strings

*tiene la region de ñuble
tab nom_region
replace nom_region = "antofagasta"        if strpos(nom_region, "antofagasta") > 0
replace nom_region = "arica y parinacota" if strpos(nom_region, "arica") > 0
replace nom_region = "atacama"            if strpos(nom_region, "atacama") > 0
replace nom_region = "aysen"              if strpos(nom_region, "aysen") > 0
replace nom_region = "coquimbo"           if strpos(nom_region, "coquimbo") > 0
replace nom_region = "araucania"          if strpos(nom_region, "araucania") > 0
replace nom_region = "los lagos"          if strpos(nom_region, "los lagos") > 0
replace nom_region = "los rios"           if strpos(nom_region, "los rios") > 0
replace nom_region = "magallanes"         if strpos(nom_region, "magallanes") > 0
replace nom_region = "nuble"              if strpos(nom_region, "nuble") > 0
replace nom_region = "tarapaca"           if strpos(nom_region, "tarapaca") > 0
replace nom_region = "valparaiso"         if strpos(nom_region, "valparaiso") > 0
replace nom_region = "biobio"             if strpos(nom_region, "biobio") > 0
replace nom_region = "o'higgins"          if strpos(nom_region, "o'higgins") > 0
replace nom_region = "maule"              if strpos(nom_region, "maule") > 0
replace nom_region = "metropolitana"      if strpos(nom_region, "metropolitana") > 0

describe

gen dependencia = "junji"

duplicates report codigo_junji

save "data/build/base_junji_transparencia.dta", replace



use "data/build/base_junji_transparencia.dta", clear

*OJO: borramos modalidades y programas que impliquen un esfuerzo directo de las madres o padres en general, segun las descripciones que entrega JUNJI
tab programa modalidad
drop if programa == "educativo para la familia"
drop if modalidad == "jardin familiar"

tab programa modalidad

count if lat == 0
*353
count if missing(direccion)
*pero tienen dirección, podría encontrar su coordenadas a partir de eso? es dificil, porque muchas direcciones tienen muy poca información

*año de apertura para hacer panel
gen anio_apertura = year(fecha_apertura)

* año de inicio para el panel UV-año: tope mínimo 2015 (igual que Integra),
* para que jardines abiertos antes del período de estudio entren desde el
* primer año del panel en vez de con anio_inicio faltante
gen anio_inicio = anio_apertura
replace anio_inicio = 2015 if anio_apertura < 2015

*borramos las dummies para que calce con panel
drop d_mod*

save "data/build/junji_limpia.dta", replace
export delimited using "data/build/junji_limpia.csv", replace
export excel using "data/build/junji_limpia.xlsx", firstrow(variables) replace

describe

/*
codigo_junji    long    %10.0g                COD_ESTABLEC
fecha_apertura  int     %td                   (first) FECHA_APERTURA
fecha_cierre    str12   %12s                  (first) FECHA_CIERRE
nom_region      str42   %42s                  (first) REGION
comuna          str20   %20s                  (first) COMUNA
direccion       str73   %73s                  (first) DIRECCIÓN
lat             double  %10.0g                (first) LATITUD
longi           double  %10.0g                (first) LONGITUD
nom_estab       str49   %49s                  (first) NOMBRE_JARDIN
matricula       float   %9.0g                 (first) matricula_total
programa        str49   %49s                  (first) main_programa
modalidad       str27   %27s                  (first) main_modalidad
d_prog_conven~n float   %9.0g                 (first) d_prog_convenio_alimentacion
d_prog_educ_f~a float   %9.0g                 (first) d_prog_educ_familia
d_prog_altern~o float   %9.0g                 (first) d_prog_alternativo
d_prog_clasic~s float   %9.0g                 (first) d_prog_clasico_terceros
d_prog_clasic~a float   %9.0g                 (first) d_prog_clasico_directa
d_prog_transi~o float   %9.0g                 (first) d_prog_transitorio
dependencia     str5    %9s
anio_apertura   float   %9.0g
anio_inicio     float   %9.0g

*/


codebook programa
tab anio_apertura programa

*1970-1994 se abrieron super pocos como 20
*en 1995 hay un boom, debe ser el año en donde empezaron a guardar datos. la mayoria de los años entre 20 y 50. Hay booms extraños, como por ejemplo 154 en 2007, o 362 en 2008

*GRAFICO APERTURAS JUNJI
preserve

keep if anio_apertura >= 2005 & anio_apertura <= 2023
collapse (count) n_aperturas = codigo_junji, by(anio_apertura programa)

twoway ///
    (connected n_aperturas anio_apertura if programa == "jardin infantil clasico adm. por terceros (vtf)", lcolor(navy) mcolor(navy)) ///
    (connected n_aperturas anio_apertura if programa == "jardin infantil clasico de adm. directa", lcolor(maroon) mcolor(maroon)) ///
    (connected n_aperturas anio_apertura if programa == "jardin infantil alternativo", lcolor(forest_green) mcolor(forest_green)) ///
    (connected n_aperturas anio_apertura if programa == "educativo para la familia", lcolor(dkorange) mcolor(dkorange)) ///
    (connected n_aperturas anio_apertura if programa == "convenio alimentacion", lcolor(purple) mcolor(purple)) ///
    (connected n_aperturas anio_apertura if programa == "transitorio", lcolor(teal) mcolor(teal)), ///
    legend(order(1 "VTF" 2 "Adm. directa" 3 "Alternativo" 4 "Educ. familia" 5 "Conv. alimentación" 6 "Transitorio") size(small)) ///
    xtitle("Año") ytitle("Jardines abiertos") ///
    xlabel(2005(1)2023, angle(45)) ///
    title("Aperturas de jardines JUNJI por programa y año")

graph export "output/figures/01_aperturas_junji_por_programa.png", replace width(1600)

restore


***************************
*INTEGRA

********
* primero crear tabla de concordancia gegión de ñuble -> codigo antiguo vs nuevo, dejar todo con el nuevo

/* PROBLEMA ÑUBLE: en 2018 se creó la región de Ñuble a partir de Biobío,
   lo que cambió los códigos de establecimiento de Integra. Para mantener
   la continuidad del panel, construimos una tabla de concordancia entre
   códigos antiguos (Biobío) y nuevos (Ñuble), usando 2019 (códigos nuevos)
   y 2017 (códigos antiguos) */

*2019
* base que tiene los codigos nuevos de los estableicmientos, la usaremos como referencia para hacer tabla de conversión
import excel "data/raw/integra.xlsx", ///
        sheet("2019") firstrow clear

describe

rename MATRICULANOVIEMBRE2019 region
rename B nom_region
rename C comuna
rename D codigo_integra
rename E nombre_estab
rename F modalidad
rename G cod_nivel
rename H nombre_nivel
rename I cod_grupo
rename J lat
rename K longi
rename L direccion
rename M anio_inicio
rename N matricula
rename O observaciones

drop if codigo_integra == ""
drop in 1
drop in 1

	foreach var of varlist _all {
    capture confirm string variable `var'
    if !_rc {
        quietly count if `var' != ""
        if r(N) == 0 drop `var'
    }
    else {
        quietly count if !missing(`var')
        if r(N) == 0 drop `var'
    }
    }

* Limpiar codigo_integra
drop if codigo_integra == "(en blanco)"

destring region codigo_integra cod_nivel cod_grupo anio_inicio matricula, replace
estandarizar_strings
duplicates report codigo_integra

tab nom_region
list nom_region if nom_region == "xvi del nuble"
*171802 -> prefijo nuevo (17)

* Collapse por establecimiento
collapse (sum) matricula ///
(firstnm) nom_region comuna nombre_estab modalidad direccion ///
              lat longi anio_inicio region observaciones, ///
              by(codigo_integra)

* Limpiar no aplica
replace lat   = "" if lat   == "no aplica"
replace longi = "" if longi == "no aplica"

* Forzar string
tostring lat longi, replace force

    * Estandarizar nom_region
    replace nom_region = "libertador gral. bdo. o'higgins" if strpos(nom_region, "vi del libertador") > 0
    replace nom_region = "aysen del gral. carlos ibanez del campo" if strpos(nom_region, "xi aysen") > 0
	replace nom_region = "nuble" if strpos(nom_region, "xvi del nuble") > 0
    replace nom_region = "tarapaca"           if strpos(nom_region, "tarapaca") > 0
    replace nom_region = "antofagasta"        if strpos(nom_region, "antofagasta") > 0
    replace nom_region = "atacama"            if strpos(nom_region, "atacama") > 0
    replace nom_region = "coquimbo"           if strpos(nom_region, "coquimbo") > 0
    replace nom_region = "araucania"          if strpos(nom_region, "araucania") > 0
    replace nom_region = "valparaiso"         if strpos(nom_region, "valparaiso") > 0
    replace nom_region = "o'higgins"          if strpos(nom_region, "o'higgins") > 0
    replace nom_region = "maule"              if strpos(nom_region, "maule") > 0
    replace nom_region = "biobio"             if strpos(nom_region, "bio-bio") > 0
    replace nom_region = "los lagos"          if strpos(nom_region, "los lagos") > 0
    replace nom_region = "aysen"              if strpos(nom_region, "aysen") > 0
    replace nom_region = "magallanes"         if strpos(nom_region, "magallanes") > 0
    replace nom_region = "metropolitana"      if strpos(nom_region, "metropolitana") > 0
    replace nom_region = "los rios"           if strpos(nom_region, "los rios") > 0
    replace nom_region = "arica y parinacota" if strpos(nom_region, "arica") > 0

keep if nom_region == "nuble"

rename codigo_integra codigo_integra2019
keep codigo_integra2019 nombre_estab comuna

save "data/build/integra_2019_temp.dta", replace




/* 2017: misma limpieza, pero la región de Ñuble todavía no existe ->
   estos establecimientos aparecen bajo Biobío con códigos antiguos */

import excel "data/raw/integra.xlsx", ///
        sheet("2017") firstrow clear

rename MATRICULANOVIEMBRE2017 region
rename B nom_region
rename C comuna
rename D codigo_integra
rename E nombre_estab
rename F modalidad
rename G cod_nivel
rename H nombre_nivel
rename I cod_grupo
rename J lat
rename K longi
rename L direccion
rename M anio_inicio
rename N matricula
rename O observaciones

drop if codigo_integra == ""
drop in 1
drop in 1

	foreach var of varlist _all {
    capture confirm string variable `var'
    if !_rc {
        quietly count if `var' != ""
        if r(N) == 0 drop `var'
    }
    else {
        quietly count if !missing(`var')
        if r(N) == 0 drop `var'
    }
    }

* Limpiar codigo_integra
drop if codigo_integra == "(en blanco)"

destring region codigo_integra cod_nivel cod_grupo anio_inicio matricula, replace
estandarizar_strings
duplicates report codigo_integra

tab nom_region
list nom_region if nom_region == "xvi del nuble"
*no se ha creado aun la región del ñuble

* Collapse por establecimiento
collapse (sum) matricula ///
(firstnm) nom_region comuna nombre_estab modalidad direccion ///
              lat longi anio_inicio region observaciones, ///
              by(codigo_integra)

* Limpiar no aplica
replace lat   = "" if lat   == "no aplica"
replace longi = "" if longi == "no aplica"

* Forzar string
tostring lat longi, replace force

* Estandarizar nom_region
replace nom_region = "libertador gral. bdo. o'higgins" if strpos(nom_region, "vi del libertador") > 0
    replace nom_region = "aysen del gral. carlos ibanez del campo" if strpos(nom_region, "xi aysen") > 0
	replace nom_region = "nuble" if strpos(nom_region, "xvi del nuble") > 0
    replace nom_region = "tarapaca"           if strpos(nom_region, "tarapaca") > 0
    replace nom_region = "antofagasta"        if strpos(nom_region, "antofagasta") > 0
    replace nom_region = "atacama"            if strpos(nom_region, "atacama") > 0
    replace nom_region = "coquimbo"           if strpos(nom_region, "coquimbo") > 0
    replace nom_region = "araucania"          if strpos(nom_region, "araucania") > 0
    replace nom_region = "valparaiso"         if strpos(nom_region, "valparaiso") > 0
    replace nom_region = "o'higgins"          if strpos(nom_region, "o'higgins") > 0
    replace nom_region = "maule"              if strpos(nom_region, "maule") > 0
    replace nom_region = "biobio"             if strpos(nom_region, "bio-bio") > 0
    replace nom_region = "los lagos"          if strpos(nom_region, "los lagos") > 0
    replace nom_region = "aysen"              if strpos(nom_region, "aysen") > 0
    replace nom_region = "magallanes"         if strpos(nom_region, "magallanes") > 0
    replace nom_region = "metropolitana"      if strpos(nom_region, "metropolitana") > 0
    replace nom_region = "los rios"           if strpos(nom_region, "los rios") > 0
    replace nom_region = "arica y parinacota" if strpos(nom_region, "arica") > 0

*toda la region del ñuble se crea a partir del bio bio
keep if nom_region == "biobio"

rename codigo_integra codigo_integra2017
keep codigo_integra2017 nombre_estab comuna

save "data/build/integra_2017_temp.dta", replace



/* Merge 2019 (códigos nuevos) con 2017 (códigos antiguos) por nombre de
   establecimiento + comuna. Solo nos quedamos con los que matchean
   (_merge==3): 57 de 61 establecimientos afectados por el cambio */

use "data/build/integra_2019_temp.dta", clear

merge 1:1 nombre_estab comuna using "data/build/integra_2017_temp.dta"

rename codigo_integra2017 codigo_integra
rename codigo_integra2019 codigo_nuevo

keep if _merge == 3
keep codigo_integra codigo_nuevo

save "data/build/cambio_cod_nuble.dta", replace



/* Para cada año (2015-2024): importar hoja correspondiente, limpiar,
   destringear, estandarizar strings, colapsar a una fila por
   establecimiento, estandarizar región, agregar variable anio y
   guardar CSV + dta temporal para el append */

local years 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024

foreach y of local years {

    import excel "data/raw/integra.xlsx", ///
        sheet("`y'") firstrow clear

    rename MATRICULANOVIEMBRE`y' region
    rename B nom_region
    rename C comuna
    rename D codigo_integra
    rename E nombre_estab
    rename F modalidad
    rename G cod_nivel
    rename H nombre_nivel
    rename I cod_grupo
    rename J lat
    rename K longi
    rename L direccion
    rename M anio_inicio
    rename N matricula
    rename O observaciones

    drop if codigo_integra == ""
    drop in 1
    drop in 1

	foreach var of varlist _all {
    capture confirm string variable `var'
    if !_rc {
        quietly count if `var' != ""
        if r(N) == 0 drop `var'
    }
    else {
        quietly count if !missing(`var')
        if r(N) == 0 drop `var'
    }
    }

	* Limpiar codigo_integra
    drop if codigo_integra == "(en blanco)"

    destring region codigo_integra cod_nivel cod_grupo anio_inicio matricula, replace

    estandarizar_strings

    * Collapse por establecimiento, dejamos una fila por establecimiento
    collapse (sum) matricula ///
             (firstnm) nom_region comuna nombre_estab modalidad direccion ///
                       lat longi anio_inicio region observaciones, ///
             by(codigo_integra)

   * Limpiar no aplica
	replace lat   = "" if lat   == "no aplica"
	replace longi = "" if longi == "no aplica"

	* Forzar string
	tostring lat longi, replace force

    * Estandarizar nom_region
    replace nom_region = "libertador gral. bdo. o'higgins" if strpos(nom_region, "vi del libertador") > 0
    replace nom_region = "aysen del gral. carlos ibanez del campo" if strpos(nom_region, "xi aysen") > 0
	replace nom_region = "nuble" if strpos(nom_region, "xvi del nuble") > 0
    replace nom_region = "tarapaca"           if strpos(nom_region, "tarapaca") > 0
    replace nom_region = "antofagasta"        if strpos(nom_region, "antofagasta") > 0
    replace nom_region = "atacama"            if strpos(nom_region, "atacama") > 0
    replace nom_region = "coquimbo"           if strpos(nom_region, "coquimbo") > 0
    replace nom_region = "araucania"          if strpos(nom_region, "araucania") > 0
    replace nom_region = "valparaiso"         if strpos(nom_region, "valparaiso") > 0
    replace nom_region = "o'higgins"          if strpos(nom_region, "o'higgins") > 0
    replace nom_region = "maule"              if strpos(nom_region, "maule") > 0
    replace nom_region = "biobio"             if strpos(nom_region, "bio-bio") > 0
    replace nom_region = "los lagos"          if strpos(nom_region, "los lagos") > 0
    replace nom_region = "aysen"              if strpos(nom_region, "aysen") > 0
    replace nom_region = "magallanes"         if strpos(nom_region, "magallanes") > 0
    replace nom_region = "metropolitana"      if strpos(nom_region, "metropolitana") > 0
    replace nom_region = "los rios"           if strpos(nom_region, "los rios") > 0
    replace nom_region = "arica y parinacota" if strpos(nom_region, "arica") > 0

    * Generar variable año
    gen anio = `y'

    * Guardar CSV del año
    export delimited using "data/build/integra_`y'.csv", replace

    * Guardar dta temporal para el append
    save "data/build/integra_`y'_temp.dta", replace
}


* Append de todos los años, quedamos con una fila por jardin por año
use "data/build/integra_2015_temp.dta", clear
local years 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024
foreach y of local years {
    if `y' != 2015 {
        append using "data/build/integra_`y'_temp.dta"
    }
}

order anio region nom_region comuna codigo_integra nombre_estab modalidad direccion lat longi anio_inicio
sort anio codigo_integra

describe

tab nom_region anio


*Corregir códigos Ñuble: para los establecimientos que cambiaron de código tras 2018, reemplazar código antiguo por nuevo y reasignar región = ñuble
merge m:1 codigo_integra using "data/build/cambio_cod_nuble.dta"
*list if _merge== 3 -> todos region del bio bio
replace codigo_integra = codigo_nuevo if _merge == 3
replace nom_region = "nuble" if _merge == 3
replace region = 17 if _merge == 3
drop codigo_nuevo _merge

drop region
rename nombre_estab nom_estab
rename anio_inicio anio_apertura
drop observaciones
rename nom_region region

*nos quedamos solo con las modalidades que nos interesan, borramos jardin sobre ruedas, educ para la familia, entre otros. Nos quedamos con los que no signifiquen mas trabajo para la madre
tab modalidad
keep if inlist(modalidad, "convenio", "jardin infantil", "jardin sobre islas")
tab modalidad anio

*anio_termino = último año en que el establecimiento aparece en los datos (proxy de actividad, no de cierre real -> limitación conocida por cambios de identificador entre años)
bysort codigo_integra: egen anio_termino = max(anio)

collapse (firstnm) region comuna nom_estab modalidad ///
         direccion lat longi anio_apertura ///
         (max) anio_termino, ///
         by(codigo_integra)

tab anio_termino

/*
anio_termin |
          o |      Freq.     Percent        Cum.
------------+-----------------------------------
       2015 |          7        0.60        0.60
       2016 |          4        0.34        0.94
       2017 |          3        0.26        1.20
       2018 |          1        0.09        1.29
       2019 |          2        0.17        1.46
       2020 |          1        0.09        1.54
       2021 |          1        0.09        1.63
       2022 |          3        0.26        1.89
       2023 |          1        0.09        1.97
       2024 |      1,144       98.03      100.00
------------+-----------------------------------
      Total |      1,167      100.00


*/

destring lat longi, replace

sort codigo_integra

* cuántos tienen anio_apertura missing o raro -> todo bien
tab anio_apertura if region == "nuble"
tab anio_apertura if region == "nuble" & anio_apertura > 2017
count if region == "nuble"

* Guardar panel final
save "data/build/integra_limpia.dta", replace
export delimited using "data/build/integra_limpia.csv", replace
export excel using "data/build/integra_limpia.xlsx", firstrow(variables) replace


tab anio_apertura
tab region if anio_apertura == 2017
tab modalidad if anio_apertura == 2017
*todos fueron jardines infantiles clasicos


*GRAFICO APERTURAS INTEGRA por año
preserve
keep if anio_apertura >= 2005 & anio_apertura <= 2024
collapse (count) n_aperturas = codigo_integra, by(anio_apertura modalidad)
twoway ///
    (connected n_aperturas anio_apertura if modalidad == "jardin infantil", lcolor(navy) mcolor(navy)) ///
    (connected n_aperturas anio_apertura if modalidad == "convenio", lcolor(maroon) mcolor(maroon)) ///
    (connected n_aperturas anio_apertura if modalidad == "jardin sobre islas", lcolor(forest_green) mcolor(forest_green)), ///
    legend(order(1 "Jardín infantil" 2 "Convenio" 3 "Jardín sobre islas") size(small)) ///
    xtitle("Año") ytitle("Jardines abiertos") ///
    xlabel(2005(1)2024, angle(45)) ///
    title("Aperturas de jardines Integra por modalidad y año")

graph export "output/figures/02_aperturas_integra_por_modalidad.png", replace width(1600)

restore


* Borrar archivos temporales
foreach y of local years {
    erase "data/build/integra_`y'_temp.dta"
}
