*ESTUDIO CP
* CHEQUEO DE ROBUSTEZ: panel UV-año alternativo, sin merge contra el
* universo completo de UVs
*
* Extraído del borrador legacy/limpieza_bases_borrador.do (líneas 709-938).
* NO es el pipeline oficial (ver code/build/03_panel_uv_anio.do) y no debe
* usarse como fuente de base_cobertura_cp.dta.
*
* Diferencias metodológicas clave respecto al panel oficial:
*   - Inputs: data/raw/junji_panel_uv.xlsx y data/raw/integra_panel_uv.xlsx,
*     que ya vienen con el spatial join y la expansión año-establecimiento
*     hechos por fuera de este repo (no se genera acá ni en
*     code/build/02_spatial_join_uv.py). Se desconoce el proceso exacto que
*     los generó.
*   - NO hace merge contra el universo completo de 6.877 UVs del shapefile:
*     solo colapsa las filas que ya existen en los xlsx de entrada. Las UVs
*     que nunca tuvieron ningún centro JUNJI/Integra en 2015-2024 quedan
*     ausentes del panel (panel NO balanceado), a diferencia de
*     base_cobertura_cp.dta, que sí las incluye explícitamente con conteo 0.
*   - Nombres de variables propios: n_centros_junji/n_centros_integra/
*     n_centros_total (no n_junji/n_integra/n_total), y una definición de
*     tratamiento distinta: estado_jardin (1=transición 0->1,
*     2=tenía centro desde el primer año del panel) en vez de tratada.
*
* Si se usa este panel para un chequeo de robustez, documentar
* explícitamente que los "nunca tratados" con cobertura cero no están
* representados de la misma forma que en el panel oficial.
*
* Rutas relativas a la raíz del proyecto: correr vía run_all.do o con
* el directorio de trabajo ya posicionado en la raíz del repo.

*INTEGRA
import excel "data/raw/integra_panel_uv.xlsx", firstrow clear

drop if missing(t_id_uv_ca)

gen uno = 1

collapse (sum) n_centros_integra = uno, by(t_id_uv_ca anio objectid t_reg_ca t_prov_ca t_com t_reg_nom t_prov_nom t_com_nom uv_carto t_uv_nom st_area_sh st_length_)

destring t_id_uv_ca, replace
sort t_id_uv_ca anio

save "data/build/n_centros_uv_integra_wide.dta", replace


*JUNJI
import excel "data/raw/junji_panel_uv.xlsx", firstrow clear

drop if missing(t_id_uv_ca)
*3,376 observations deleted las que no tenían coord

* Contar establecimientos únicos por año en la base original (antes del collapse)
bysort codigo_junji anio: gen dup = _n
tab anio if dup == 1

gen uno = 1

collapse (sum) n_centros_junji = uno, by(t_id_uv_ca anio objectid t_reg_ca t_prov_ca t_com t_reg_nom t_prov_nom t_com_nom uv_carto t_uv_nom st_area_sh st_length_)

destring t_id_uv_ca, replace
sort t_id_uv_ca anio

save "data/build/n_centros_uv_junji_wide.dta", replace


merge 1:1 t_id_uv_ca anio using "data/build/n_centros_uv_integra_wide.dta"

replace n_centros_integra = 0 if n_centros_integra == .
replace n_centros_junji = 0 if n_centros_junji == .

gen n_centros_total = n_centros_integra + n_centros_junji

drop _merge

save "data/build/panel_n_junji_integra_uv.dta", replace

export excel using "data/build/panel_n_junji_integra_uv.xlsx", firstrow(variables) replace




*GRÁFICOS

use "data/build/panel_n_junji_integra_uv.dta", clear

preserve
collapse (sum) n_centros_total n_centros_junji n_centros_integra, by(anio)
list anio n_centros_total n_centros_junji n_centros_integra if inrange(anio, 2015, 2023)
restore



preserve

collapse (sum) n_centros_junji n_centros_integra n_centros_total, by(anio)
sort anio

* Crecimiento % anual solo para el total
gen crec_anual = ((n_centros_total - n_centros_total[_n-1]) / n_centros_total[_n-1]) * 100
gen crec_label = string(round(crec_anual, 0.1)) + "%" if crec_anual != .
replace crec_label = "" if crec_anual == .

twoway ///
    (line n_centros_total    anio, lcolor(navy)         lwidth(medthick)) ///
    (line n_centros_junji    anio, lcolor(cranberry)    lwidth(medium) lpattern(dash)) ///
    (line n_centros_integra  anio, lcolor(forest_green) lwidth(medium) lpattern(dash)) ///
    (scatter n_centros_total anio, ///
        mcolor(navy) msize(small) ///
        mlabel(crec_label) mlabposition(12) mlabsize(vsmall) mlabcolor(gs6)), ///
    title("Número de Centros Parvularios por Año, excluyendo jardines familiares", size(small)) ///
    subtitle("Etiquetas indican crecimiento % del total respecto al año anterior", size(vsmall) color(gs6)) ///
    xtitle("Año", size(vsmall)) ///
    ytitle("Número de Centros", size(vsmall)) ///
    yscale(range(800 .)) ///
    ylabel(800(500)4500, angle(0) labsize(small)) ///
    xlabel(2015(1)2024, angle(25) labsize(small)) ///
    legend(order(1 "Total" 2 "JUNJI" 3 "Integra") ///
           position(6) rows(1) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    xsize(6) ysize(5)

restore


preserve
collapse (sum) n_centros_junji n_centros_integra, by(anio)

twoway ///
    (line n_centros_junji anio, lcolor(navy) lwidth(medium)) ///
    (line n_centros_integra anio, lcolor(cranberry) lwidth(medium)) ///
    (scatter n_centros_junji anio, mcolor(navy) mlabel(n_centros_junji) mlabsize(vsmall) mlabposition(12)) ///
    (scatter n_centros_integra anio, mcolor(cranberry) mlabel(n_centros_integra) mlabsize(vsmall) mlabposition(6)), ///
    title("Evolución de centros de educación parvularia pública", size(medium)) ///
    subtitle("Chile, 2015-2024", size(medium)) ///
    ytitle("Número de centros", size(medium)) ///
    xtitle("Año") ///
    xlabel(2015(1)2024, labsize(small)) ///
    ylabel(0(500)4000, labsize(small)) ///
    legend(order(1 "JUNJI" 2 "Integra") position(6) rows(1)) ///
    scheme(s2color)

restore


preserve

collapse (sum) n_centros_junji n_centros_integra, by(anio)
drop if anio == 2024

gen junji_base = n_centros_junji - n_centros_junji[1]
gen integra_base = n_centros_integra - n_centros_integra[1]

twoway ///
    (area junji_base anio, fcolor(navy%30) lcolor(navy) lwidth(medium)) ///
    (area integra_base anio, fcolor(cranberry%30) lcolor(cranberry) lwidth(medium)) ///
    (scatter junji_base anio, mcolor(navy) mlabel(junji_base) mlabsize(vsmall) mlabposition(12)) ///
    (scatter integra_base anio, mcolor(cranberry) mlabel(integra_base) mlabsize(vsmall) mlabposition(6)), ///
    title("Crecimiento acumulado de centros parvularios públicos", size(medium)) ///
    subtitle("Nuevos centros respecto a 2015, Chile") ///
    ytitle("Nuevos centros desde 2015") ///
    xtitle("") ///
    xlabel(2015(1)2023, labsize(small)) ///
    ylabel(0(100)600, labsize(small)) ///
    legend(order(1 "JUNJI" 2 "Integra") position(6) rows(1)) ///
    scheme(s2color)

restore



* Requiere paquetes de usuario (instalar una vez, requiere conexión a internet)
capture which heatplot
if _rc ssc install heatplot
capture which palettes
if _rc ssc install palettes
capture which colrspace
if _rc ssc install colrspace

preserve

collapse (sum) n_centros_total, by(t_reg_nom anio)
drop if anio == 2024

bysort t_reg_nom (anio): gen crecimiento = n_centros_total - n_centros_total[1]

* abreviar nombres de región
replace t_reg_nom = "Arica" if t_reg_nom == "ARICA Y PARINACOTA"
replace t_reg_nom = "Tarapacá" if t_reg_nom == "TARAPACA"
replace t_reg_nom = "Antofagasta" if t_reg_nom == "ANTOFAGASTA"
replace t_reg_nom = "Atacama" if t_reg_nom == "ATACAMA"
replace t_reg_nom = "Coquimbo" if t_reg_nom == "COQUIMBO"
replace t_reg_nom = "Valparaíso" if t_reg_nom == "VALPARAISO"
replace t_reg_nom = "RM" if t_reg_nom == "METROPOLITANA DE SANTIAGO"
replace t_reg_nom = "O'Higgins" if t_reg_nom == "LIBERTADOR GENERAL BERNARDO OHK"
replace t_reg_nom = "Maule" if t_reg_nom == "MAULE"
replace t_reg_nom = "Ñuble" if t_reg_nom == "ÑUBLE"
replace t_reg_nom = "Biobío" if t_reg_nom == "BIOBIO"
replace t_reg_nom = "Araucanía" if t_reg_nom == "LA ARAUCANIA"
replace t_reg_nom = "Los Ríos" if t_reg_nom == "LOS RIOS"
replace t_reg_nom = "Los Lagos" if t_reg_nom == "LOS LAGOS"
replace t_reg_nom = "Aysén" if t_reg_nom == "AYSEN DEL GENERAL CARLOS IBANEZ DEL"
replace t_reg_nom = "Magallanes" if t_reg_nom == "MAGALLANES Y DE LA ANTARTICA CHI"

heatplot crecimiento anio t_reg_nom, ///
    color(Blues) ///
    title("Crecimiento acumulado de centros por región", size(medium)) ///
    subtitle("Nuevos centros respecto a 2015") ///
    xtitle("") ytitle("") ///
    legend(title("Nuevos centros", size(small))) ///
    scheme(s2color)

restore



*DEFINICIONES DE TRATAMIENTO (estado_jardin, distinta de "tratada" del panel oficial)
use "data/build/panel_n_junji_integra_uv.dta", clear

* Cuántas UV tienen n_centros_total == 0 en algún año?
count if n_centros_total == 0

* Ver distribución de n_centros_total
tab n_centros_total

* Ver si hay variación dentro de una UV (que cambie de 0 a algo)
bysort objectid: egen min_centros = min(n_centros_total)
bysort objectid: egen max_centros = max(n_centros_total)

tab min_centros
tab max_centros

* Ver UVs que sí cambian (tenían 0 y luego tienen algo)
count if min_centros == 0 & max_centros >= 1




* Ordenar el panel
sort objectid anio

* Crear variable:
* 1 = primer jardín en este año (transición de 0 a 1)
* 2 = ya tenía jardín desde el inicio del panel
* 0 = el resto

bysort objectid: gen estado_jardin = .

* Caso 1: transición de 0 a 1
bysort objectid: replace estado_jardin = 1 if (n_centros_total >= 1 & n_centros_total[_n-1] == 0)

* Caso 2: ya tenía desde el primer año del panel
bysort objectid: replace estado_jardin = 2 if (n_centros_total >= 1 & _n == 1)

* Tabla resumen: cuántas UV recibieron su primer jardín por año
tab anio if estado_jardin == 1

* Y cuántas ya estaban tratadas desde el inicio
count if estado_jardin == 2
