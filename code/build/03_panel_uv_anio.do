*ESTUDIO CP
* creación base de panel
* junio 2026

/*===================================================================
CONSTRUCCIÓN PANEL UV-AÑO (data/final/base_cobertura_cp.dta)

A partir de junji_uv.csv e integra_uv.csv (asignación espacial
establecimiento-UV hecha en python), elimina duplicados por establecimiento,
expande cada jardín a una fila por año de actividad (2015-2024)
y colapsa a conteos de centros por UV-año (n_junji, n_integra,
y desagregación por programa JUNJI).

Hace merge JUNJI + Integra, completa el panel con tsfill (todas
las UV x todos los años), reemplaza missings por cero y agrega
la base completa de UVs (base_uv_completa) para tener el universo
de 6,877 UVs balanceado 2015-2024.

Genera n_total y la variable tratada (UV que pasa de 0 a ≥1
centros). Incluye gráficos descriptivos de evolución de
establecimientos por año, modalidad y región tratada.

Rutas relativas a la raíz del proyecto: correr vía run_all.do o con
el directorio de trabajo ya posicionado en la raíz del repo.
===================================================================*/

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




*===================================================================

/* PANEL JUNJI: leer asignación espacial jardín-UV (salida de Python "junji_uv.csv"),
   revisar y resolver duplicados de codigo_junji (jardines en el
   límite entre dos UV: 4 casos), fijar anio_termino=2024 (no hay
   fecha de cierre confiable para JUNJI), expandir a una fila por año
   de actividad (2015-2024) y colapsar a conteos por UV-año, incluyendo
   desagregación por programa */

* una fila por jardín, cada uno asignado a su uv correspondiente.
import delimited "data/build/junji_uv.csv", encoding(utf-8) clear

duplicates report codigo_junji
duplicates list codigo_junji
duplicates tag codigo_junji, gen(dup)
*list codigo_junji if dup > 0

*jardines que quedaron en el limite entre dos uv
bysort codigo_junji: keep if _n == 1
drop dup

describe

tab programa
tab modalidad

estandarizar_strings

* generar anio_termino
gen anio_termino = 2024

* expandir por años de actividad
gen n_anios = anio_termino - anio_inicio + 1
tab n_anios
expand n_anios

bysort codigo_junji: gen anio = anio_inicio + _n - 1

* verificar
tab anio

/*
       anio |      Freq.     Percent        Cum.
------------+-----------------------------------
       2015 |      2,757        8.87        8.87
       2016 |      2,879        9.26       18.12
       2017 |      2,985        9.60       27.72
       2018 |      3,077        9.90       37.62
       2019 |      3,167       10.18       47.80
       2020 |      3,180       10.23       58.03
       2021 |      3,225       10.37       68.40
       2022 |      3,258       10.48       78.88
       2023 |      3,284       10.56       89.44
       2024 |      3,284       10.56      100.00
------------+-----------------------------------
      Total |     31,096      100.00
*/

collapse (count) n_junji = codigo_junji ///
         (sum) n_conv_alim = d_prog_convenio_alimentacion ///
               n_educ_fam = d_prog_educ_familia ///
               n_alternativo = d_prog_alternativo ///
               n_clas_terc = d_prog_clasico_terceros ///
               n_clas_dir = d_prog_clasico_directa ///
               n_transitorio = d_prog_transitorio ///
         (firstnm) nom_region comuna, ///
         by(t_id_uv_ca anio)

save "data/build/uv_junji.dta", replace




*===================================================================
/* PANEL INTEGRA: leer asignación espacial jardín-UV, resolver
   duplicados de codigo_integra (1 jardín asignado a dos UV),
   definir anio_inicio (tope mínimo 2015 para jardines que ya
   existían antes del período), expandir a una fila por año de
   actividad y colapsar a conteos por UV-año */

* una fila por jardin, cada uno asinado a su uv respectiva
import delimited "data/build/integra_uv.csv", encoding(utf-8) clear

describe
duplicates report codigo_integra
duplicates list codigo_integra

*un jardin asignado a dos uv distintas
bysort codigo_integra: keep if _n == 1

gen anio_inicio = anio_apertura
count if missing(anio_inicio)
replace anio_inicio = 2015 if anio_apertura < 2015

gen n_anios = anio_termino - anio_inicio + 1
expand n_anios

bysort codigo_integra: gen anio = anio_inicio + _n - 1

tab anio_inicio
tab anio_termino

*para ver si hay problemas con ñuble
tab region if anio_termino == 2018

/*
. tab region if anio_termino == 2018 -> ahora todo ok
            region |      Freq.     Percent        Cum.
-------------------+-----------------------------------
            biobio |          4      100.00      100.00
-------------------+-----------------------------------
             Total |          4      100.00

*/


collapse (count) n_integra = codigo_integra ///
         (firstnm) region comuna, ///
         by(t_id_uv_ca anio)

save "data/build/uv_integra.dta", replace






*===================================================================
* CREAR PANEL COMPLETO DE TODAS LAS UV PARA TODOS LOS AÑOS 2015-2024

/* Cargar shapefile completo de UVs (6,877 UVs, salida de Python),
   estandarizar strings y guardar como .dta. Este será el universo
   completo de UVs con el que se hace merge más adelante */

import delimited "data/build/base_uv_completa.csv", encoding(utf-8) clear
estandarizar_strings
save "data/build/base_uv_completa.dta", replace




/* MERGE JUNJI + INTEGRA a nivel UV-año. Reemplazar missings por 0
   (UV-año sin centros de ese tipo). Si nom_region falta (UV solo
   presente en Integra, que usa la variable region), completarla
   con region de Integra */
use "data/build/uv_junji.dta", clear

merge 1:1 t_id_uv_ca anio using "data/build/uv_integra.dta", nogen

* reemplazar missings por cero
replace n_junji = 0 if n_junji == .
replace n_integra = 0 if n_integra == .

replace nom_region = region if missing(nom_region)
count if missing(nom_region)
drop region



/* PANEL BALANCEADO: tsfill, full crea todas las combinaciones
   UV x año (2015-2024) para las UVs que ya tenían al menos un
   registro en JUNJI/Integra. Las celdas nuevas quedan con missing
   en n_junji/n_integra -> se reemplazan por 0 */
xtset t_id_uv_ca anio
tsfill, full

replace n_junji = 0 if n_junji == .
replace n_integra = 0 if n_integra == .

*Todas las UV-año donde JUNJI o Integra reportó al menos un centro en algún año
save "data/build/uv_junji_integra.dta", replace





/* MERGE CON UNIVERSO COMPLETO DE UVs: expandir base_uv_completa
   (6,877 UVs) a 10 filas por UV, una por año 2015-2024, y hacer
   merge con uv_junji_integra (UVs que tuvieron al menos un centro
   en algún año, ya balanceadas con tsfill).

   - UVs que estaban en uv_junji_integra: se completan con sus
     conteos reales.
   - UVs que nunca tuvieron ningún centro JUNJI/Integra (no estaban
     en uv_junji_integra): entran con missing en todos los conteos,
     reemplazado por 0 a continuación.

   Resultado: panel balanceado 6,877 UVs x 10 años = 68,770 obs */

use "data/build/base_uv_completa.dta", clear
* expandir para tener 10 filas por UV
expand 10
bysort t_id_uv_ca: gen anio = 2014 + _n

merge 1:1 t_id_uv_ca anio using "data/build/uv_junji_integra.dta", nogen

replace n_junji = 0 if n_junji == .
replace n_integra = 0 if n_integra == .
replace n_conv_alim = 0 if n_conv_alim == .
replace n_educ_fam = 0 if n_educ_fam == .
replace n_alternativo = 0 if n_alternativo == .
replace n_clas_terc = 0 if n_clas_terc == .
replace n_clas_dir = 0 if n_clas_dir == .
replace n_transitorio = 0 if n_transitorio == .

tab anio

drop nom_region comuna



* DEFINICION DE TRATAMIENTO
gen n_total = n_junji + n_integra

bysort t_id_uv_ca (anio): gen tratada = (n_total >= 1 & n_total[_n-1] == 0)

tab anio if tratada == 1
/*
Verificado con una corrida completa del pipeline (10/07/2026), tras el fix
de anio_inicio para JUNJI en 01_limpieza_junji_integra.do:

       anio |      Freq.     Percent        Cum.
------------+-----------------------------------
       2016 |         63       23.95       23.95
       2017 |         78       29.66       53.61
       2018 |         45       17.11       70.72
       2019 |         37       14.07       84.79
       2020 |          7        2.66       87.45
       2021 |         15        5.70       93.16
       2022 |         10        3.80       96.96
       2023 |          8        3.04      100.00
------------+-----------------------------------
      Total |        263      100.00

*/

tab t_reg_nom if tratada == 1
order anio t_* n_*

save "data/final/base_cobertura_cp.dta", replace






*===================================================================
*GRAFICOS

use "data/final/base_cobertura_cp.dta", clear


*GRAFICO DE UV TRATADAS POR AÑO POR REGION
preserve
keep if tratada == 1
contract t_reg_nom, freq(n_tratadas)
gsort -n_tratadas

graph hbar n_tratadas, over(t_reg_nom, sort(n_tratadas) descending) ///
    title("UVs tratadas por región") ///
    ytitle("Número de UVs") ///
    blabel(bar)

graph export "output/figures/03_uv_tratadas_por_region.png", replace width(1600)

restore


describe

preserve
collapse (sum) n_*, by(anio)
list anio n_*
restore
/*
     +-------------------------------------+
     | anio   n_junji   n_inte~a   n_total |
     |-------------------------------------|
  1. | 2015      2757        972      3729 |
  2. | 2016      2879       1010      3889 |
  3. | 2017      2985       1116      4101 |
  4. | 2018      3077       1145      4222 |
  5. | 2019      3167       1149      4316 |
     |-------------------------------------|
  6. | 2020      3180       1147      4327 |
  7. | 2021      3225       1147      4372 |
  8. | 2022      3258       1146      4404 |
  9. | 2023      3284       1143      4427 |
 10. | 2024      3284       1144      4428 |
     +-------------------------------------+
*/



* GRAFICO JARDINES JUNJI POR AÑO
preserve
collapse (sum) n_junji n_integra, by(anio)

twoway (line n_junji anio, lcolor(navy) lwidth(medium)), ///
       xlabel(2015(1)2024) ///
       ylabel(, angle(0)) ///
       title("Jardines JUNJI por año") ///
       xtitle("Año") ytitle("Número de establecimientos")

graph export "output/figures/04_jardines_junji_por_anio.png", replace width(1600)

restore

* GRAFICO JARDINES INTEGRA POR AÑO
preserve
collapse (sum) n_junji n_integra, by(anio)
twoway (line n_integra anio, lcolor(cranberry) lwidth(medium)), ///
       xlabel(2015(1)2024) ///
       ylabel(, angle(0)) ///
       title("Jardines Integra por año") ///
       xtitle("Año") ytitle("Número de establecimientos")

graph export "output/figures/05_jardines_integra_por_anio.png", replace width(1600)

restore



* GRAFICO JARDINES JUNJI e INTEGRA POR AÑO
preserve
collapse (sum) n_junji n_integra, by(anio)

twoway (line n_junji anio, lcolor(navy) lwidth(medium)) ///
       (line n_integra anio, lcolor(cranberry) lwidth(medium)), ///
       xlabel(2015(1)2024) ///
       ylabel(0(500)3500, angle(0)) ///
       title("Jardines JUNJI e Integra por año") ///
       xtitle("Año") ytitle("Número de establecimientos") ///
       legend(order(1 "JUNJI" 2 "Integra") position(6) rows(1)) ///
       xsize(7) ysize(6)

graph export "output/figures/06_jardines_junji_integra_por_anio.png", replace width(1600)

restore



preserve
collapse (sum) n_conv_alim n_educ_fam n_alternativo n_clas_terc n_clas_dir n_transitorio, by(anio)
list, clean
restore

/*
       anio   n_conv~m   n_educ~m   n_alte~o   n_clas~c   n_clas~r   n_tran~o
  1.   2015         57          1        447          0        490        141
  2.   2016         58          2        486          0        535        149
  3.   2017         58          2        501          0        617        168
  4.   2018         58          2        520          0        689        182
  5.   2019         62          2        528          0        766        201
  6.   2020         63          2        528          0        776        204
  7.   2021         63          2        528          0        821        219
  8.   2022         63          2        528          0        854        225
  9.   2023         63          2        528          0        876        227
 10.   2024         63          2        528          0        876        227
*/

*GRAFICO MODALIDADES POR AÑO
preserve
collapse (sum) n_conv_alim n_educ_fam n_alternativo n_clas_terc n_clas_dir n_transitorio, by(anio)

twoway ///
    (connected n_conv_alim anio, lcolor(blue) mcolor(blue)) ///
    (connected n_educ_fam anio, lcolor(red) mcolor(red)) ///
    (connected n_alternativo anio, lcolor(green) mcolor(green)) ///
    (connected n_clas_dir anio, lcolor(orange) mcolor(orange)) ///
    (connected n_transitorio anio, lcolor(purple) mcolor(purple)), ///
    title("Jardines JUNJI por modalidad, 2015–2024") ///
    xtitle("Año") ytitle("N° jardines") ///
    legend(order(1 "Conv. alimentación" 2 "Educ. familia" ///
                 3 "Alternativo" 4 "Clásico directo" 5 "Transitorio")) ///
    xlabel(2015(1)2024, angle(45))

graph export "output/figures/07_modalidades_junji_por_anio.png", replace width(1600)

restore



preserve
keep if anio == 2024
histogram n_total, discrete frequency title("Distribución de n_total por UV, 2024")

graph export "output/figures/08_histograma_n_total_2024.png", replace width(1600)

restore


preserve
collapse (sum) n_conv_alim n_educ_fam n_alternativo n_clas_terc n_clas_dir n_transitorio, by(anio)
* NOTA: se usa graph bar con stack (en vez de twoway area) porque twoway area
* sin apilar dibuja cada serie superpuesta desde 0, no acumulada -> las series
* chicas (conv_alim, educ_fam, alternativo, clas_terc) quedaban tapadas por
* las más grandes dibujadas después (clas_dir, transitorio).
graph bar n_conv_alim n_educ_fam n_alternativo n_clas_terc n_clas_dir n_transitorio, ///
    over(anio) stack ///
    title("Composición de jardines JUNJI por modalidad, 2015-2024") ///
    ytitle("N° jardines") ///
    legend(order(1 "Conv. alim." 2 "Educ. familia" 3 "Alternativo" ///
                  4 "Clásico terc." 5 "Clásico directo" 6 "Transitorio") ///
           position(6) rows(2) size(small))

graph export "output/figures/09_composicion_modalidades_junji.png", replace width(1600)

restore
