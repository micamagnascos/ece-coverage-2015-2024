*=============================================================
* DESCUBRIR CLAVES UV HACIA ATRAS  (2021 -> 2017)
*
* Desde 2022 el codigo_uv de carto ya tiene id_uv_2024 confiable.
* Para los anios viejos seguimos a las personas (rut_inn) hasta
* el anio confiable de al lado y decodificamos cada codigo viejo
* por VOTACION: de la gente con codigo Z en el anio t, miramos a
* que id_uv_2024 cayo en el anio t+1.  Mayoria clara -> Z = esa uv.
*
* Solo se guardan las claves por anio: claves_YYYY.dta
* Las bases de personas se leen con 2 variables y no se guardan.
*=============================================================

clear all
set more off

global shapes "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\shapes_uv"
global carto  "Z:\BASES_COMUNES2\MDSF\RSH\Cartografia\UV_RSH"

* base con la verdad 2022-2024 (AJUSTAR nombre y variables)
global VERDAD   "$shapes/carto_shape_uv2024.dta"
global VCOD     "codigo_uv_carto"
global VUV      "id_uv_2024"

global NMIN            30
global SALTO_LIMPIO    0.70
global SALTO_DIVISION  0.85
global SDIV            0.20


*=============================================================
* PASO A: claves confiables 2022 / 2023 / 2024
*=============================================================
use "$VERDAD", clear
keep if inrange(anio,2022,2024)
keep anio $VCOD $VUV
rename $VCOD codigo_uv
rename $VUV  id_uv_2024
capture confirm string variable codigo_uv
if _rc tostring codigo_uv, replace force
capture confirm string variable id_uv_2024
if _rc tostring id_uv_2024, replace force
gen double share = 1
gen str12  tipo  = "verdad"
gduplicates drop anio codigo_uv, force

foreach y in 2022 2023 2024 {
    preserve
    keep if anio == `y'
    save "$shapes/claves_`y'.dta", replace
    restore
}


*=============================================================
* PASO B: decodificar 2021 -> 2017, un anio a la vez
*=============================================================
foreach t of numlist 2021 2020 2019 2018 2017 {
    local ay = `t' + 1

    * (1) diccionario confiable del anio ancla: 1 fila por codigo
    use "$shapes/claves_`ay'.dta", clear
    keep if inlist(tipo,"verdad","limpio")
    keep codigo_uv id_uv_2024
    gduplicates drop codigo_uv, force
    tempfile dic
    save "`dic'"

    * (2) ancla nivel persona: rut_inn -> id_uv_2024   (anio `ay')
    * ojo: en algunos carto la var se llama run_inn -> comodin r*_inn y normalizo
    use uv_rsh r*_inn using "$carto/`ay'/midesof_rsh_uv_`ay'12.dta", clear
    capture rename run_inn rut_inn
    capture confirm string variable rut_inn
    if !_rc destring rut_inn, replace
    capture confirm string variable uv_rsh
    if _rc tostring uv_rsh, replace force
    rename uv_rsh codigo_uv
    gduplicates drop rut_inn, force
    merge m:1 codigo_uv using "`dic'", keep(match) nogen
    keep rut_inn id_uv_2024
    tempfile ancla
    save "`ancla'"

    * (3) personas del anio `t'
    use uv_rsh r*_inn using "$carto/`t'/midesof_rsh_uv_`t'12.dta", clear
    capture rename run_inn rut_inn
    capture confirm string variable rut_inn
    if !_rc destring rut_inn, replace
    capture confirm string variable uv_rsh
    if _rc tostring uv_rsh, replace force
    rename uv_rsh Z
    gduplicates drop rut_inn, force
    merge 1:1 rut_inn using "`ancla'", keep(match) nogen
    drop rut_inn

    * (4) votacion: celdas Z x id_uv_2024
    gcontract Z id_uv_2024
    bysort Z: egen double nvot = total(_freq)
    gen double share = _freq / nvot

    gsort Z -_freq
    by Z: keep if _n <= 2
    by Z: gen double s1 = share[1]
    by Z: gen str40  u1 = id_uv_2024[1]
    by Z: gen double s2 = share[2]
    by Z: gen str40  u2 = id_uv_2024[2]
    by Z: keep if _n == 1
    replace s2 = 0  if missing(s2)
    replace u2 = "" if missing(u2)

    * (5) clasificar
    gen str12 tipo = "ambiguo"
    replace tipo = "insuf"    if nvot < $NMIN
    replace tipo = "limpio"   if tipo=="ambiguo" & s1 >= $SALTO_LIMPIO
    replace tipo = "division" if tipo=="ambiguo" & s1+s2 >= $SALTO_DIVISION & s2 >= $SDIV

    * (6) armar claves (2 filas si division)
    drop id_uv_2024 share
    expand 2 if tipo=="division", gen(seg)
    gen str40  id_uv_2024 = u1
    gen double share      = s1
    replace id_uv_2024 = u2 if seg==1
    replace share      = s2 if seg==1

    gen int anio = `t'
    rename Z codigo_uv
    rename nvot n_votantes
    keep  anio codigo_uv id_uv_2024 share n_votantes tipo
    save "$shapes/claves_`t'.dta", replace

    di as res "anio `t':"
    tab tipo
}


*=============================================================
* PASO C: validacion - reconstruir 2023 con 2024 y comparar
*=============================================================
use "$shapes/claves_2024.dta", clear
keep codigo_uv id_uv_2024
gduplicates drop codigo_uv, force
tempfile dic24
save "`dic24'"

use uv_rsh r*_inn using "$carto/2024/midesof_rsh_uv_202412.dta", clear
capture rename run_inn rut_inn
rename uv_rsh codigo_uv
gduplicates drop rut_inn, force
merge m:1 codigo_uv using "`dic24'", keep(match) nogen
keep rut_inn id_uv_2024
tempfile ancla24
save "`ancla24'"

use uv_rsh r*_inn using "$carto/2023/midesof_rsh_uv_202312.dta", clear
capture rename run_inn rut_inn
rename uv_rsh Z
gduplicates drop rut_inn, force
merge 1:1 rut_inn using "`ancla24'", keep(match) nogen
drop rut_inn

gcontract Z id_uv_2024
bysort Z: egen double nvot = total(_freq)
gen double share = _freq / nvot
gsort Z -_freq
by Z: keep if _n == 1
rename id_uv_2024 uv_estim
rename Z codigo_uv
merge 1:1 codigo_uv using "$shapes/claves_2023.dta", keep(match) nogen keepusing(id_uv_2024)
gen byte acierto = uv_estim == id_uv_2024

summarize acierto
summarize acierto if nvot >= $NMIN
summarize acierto [aw=nvot]


*=============================================================
* PASO D: crosswalk maestro
*=============================================================
use "$shapes/claves_2017.dta", clear
foreach y in 2018 2019 2020 2021 2022 2023 2024 {
    append using "$shapes/claves_`y'.dta"
}
gen byte usable = inlist(tipo,"verdad","limpio","division")
sort anio codigo_uv
save "$shapes/crosswalk_uv_final.dta", replace
tab anio tipo
