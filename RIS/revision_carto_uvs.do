*ANALISIS DE LOS CODIGOS DE LAS UV 

*Intentar que el maestro del rsh y los shapes coincidan de alguna forma 

clear all
ssc install reclink, replace

global shapes "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML\shapes_uv"
global carto "Z:\BASES_COMUNES2\MDSF\RSH\Cartografia\UV_RSH"


**************************************************************
*UVS DE BASES CARTO RSH
*guardar todos los listados de codigos de los carto (los que unenn cada perosna con su uv)

describe using "$carto/2017/midesof_rsh_uv_201706.dta"
use uv_rsh uv_nom grupfami_unidadvecinal grupfami_comunaine using "$carto/2017/midesof_rsh_uv_201706.dta", clear
gduplicates drop
gduplicates drop uv_rsh, force
format %15.0f uv_rsh
sort uv_rsh
gen anio = 2017
save "$shapes/carto_2017.dta", replace

describe using "$carto/2018/midesof_rsh_uv_201812.dta"
use uv_rsh uv_nom grupfami_unidadvecinal grupfami_comunaine using "$carto/2018/midesof_rsh_uv_201812.dta", clear
gduplicates drop uv_rsh, force
format %15.0f uv_rsh
sort uv_rsh
gen anio = 2018
save "$shapes/carto_2018.dta", replace
*6853



describe using "$carto/2019/midesof_rsh_uv_201912.dta"
use uv_rsh uv_nom grupfami_unidadvecinal grupfami_comunaine using "$carto/2019/midesof_rsh_uv_201912.dta", clear
gduplicates drop uv_rsh, force
format %15.0f uv_rsh
sort uv_rsh
gen anio = 2019
save "$shapes/carto_2019.dta", replace
*6894

describe using "$carto/2020/midesof_rsh_uv_202012.dta"
use uv_rsh uv_nom grupfami_unidadvecinal grupfami_comunaine using "$carto/2020/midesof_rsh_uv_202012.dta", clear
gduplicates drop uv_rsh, force
format %15.0f uv_rsh
sort uv_rsh
gen anio = 2020
save "$shapes/carto_2020.dta", replace
*6937 ???

describe using "$carto/2021/midesof_rsh_uv_202112.dta"
use uv_rsh uv_nom grupfami_unidadvecinal grupfami_comunaine using "$carto/2021/midesof_rsh_uv_202112.dta", clear
gduplicates drop uv_rsh, force
format %15.0f uv_rsh
sort uv_rsh
gen anio = 2021
save "$shapes/carto_2021.dta", replace
*6996 ???

describe using "$carto/2022/midesof_rsh_uv_202212.dta"
use uv_rsh uv_nom grupfami_unidadvecinal grupfami_comunaine using "$carto/2022/midesof_rsh_uv_202212.dta", clear
gduplicates drop uv_rsh, force
format %15.0f uv_rsh
sort uv_rsh
gen anio = 2022
save "$shapes/carto_2022.dta", replace
*6872

describe using "$carto/2023/midesof_rsh_uv_202312.dta"
use uv_rsh uv_nom grupfami_unidadvecinal grupfami_comunaine using "$carto/2023/midesof_rsh_uv_202312.dta", clear
gduplicates drop uv_rsh, force
format %15.0f uv_rsh
sort uv_rsh
gen anio = 2023
save "$shapes/carto_2023.dta", replace
*6872

describe using "$carto/2024/midesof_rsh_uv_202412.dta"
use uv_rsh uv_nom grupfami_unidadvecinal grupfami_comunaine using "$carto/2024/midesof_rsh_uv_202412.dta", clear
gduplicates drop uv_rsh, force
format %15.0f uv_rsh
sort uv_rsh
gen anio = 2024
save "$shapes/carto_2024.dta", replace
*6884


*UVS DE CARTOGRAFIA RSH

use "$shapes/carto_2017.dta", clear
append using "$shapes/carto_2018.dta"
append using "$shapes/carto_2019.dta"
append using "$shapes/carto_2020.dta"
append using "$shapes/carto_2021.dta"
append using "$shapes/carto_2022.dta"
append using "$shapes/carto_2023.dta"
append using "$shapes/carto_2024.dta"
order anio uv_rsh

save "$shapes/carto_completo_uvs.dta", replace

use "$shapes/carto_completo_uvs.dta", clear

*renombramos y pasamos a string 
rename uv_rsh codigo_uv
tostring codigo_uv, replace 
rename grupfami_comunaine comuna_id
tostring comuna_id, replace 
rename uv_nom nombre_uv

gen long id_carto = _n

duplicates report anio codigo_uv

keep id_carto anio codigo_uv nombre_uv comuna_id 

save "$shapes/carto_uvs.dta", replace


**************************************************************
*UVS MADRE DE SHAPES 
describe using "$shapes/uvs_madre.dta"
use "$shapes/uvs_madre.dta", clear
tab anio
*2014-2024

order anio id_uv_origen fila_origen id_uv_2024 id_comuna_origen

duplicates report anio id_uv_origen
duplicates tag anio id_uv_origen, gen(dup_num)
bysort anio id_uv_origen: gen n_variantes = _N
tab anio if n_variantes > 1
*browse if dup_num > 0
tab id_uv_origen if dup_num > 0

*elimino las uv que no tengan còdigo de origen, tienen codigo 0 
duplicates drop anio id_uv_origen, force
rename id_uv_origen codigo_uv
rename id_comuna_origen comuna_id
rename nombre_uv_origen nombre_uv

*borramos estos años porque no tienen carto 
drop if anio == 2014
drop if anio == 2015

gen long id_shapes = _n
duplicates report anio codigo_uv

keep id_shapes anio codigo_uv nombre_uv comuna_id id_uv_2024

save "$shapes/shapes_uvs.dta", replace







***********************************************
*ENCONTRAR MATCHS ENTRE CODIGOS UV CARTO Y SHAPES 

use "$shapes/carto_uvs.dta", clear 
tab anio
levelsof anio, clean local(anios)

foreach a of local anios {
	preserve 
	keep if anio ==  `a'
	replace nombre_uv = upper(nombre_uv)
	replace comuna_id = upper(comuna_id)
	save "$shapes/carto_`a'_anual.dta", replace 
	restore 
	}

	

clear 
input str5 comuna_id str5 comuna_nueva 
"8401" "16101"
"8402" "16102"
"8403" "16202"
"8404" "16203"
"8405" "16302"
"8406" "16103"
"8407" "16104"
"8408" "16204"
"8409" "16303"
"8410" "16105"
"8411" "16106"
"8412" "16205"
"8413" "16107"
"8414" "16201"
"8415" "16206"
"8416" "16301"
"8417" "16304"
"8418" "16108"
"8419" "16305"
"8420" "16207"
"8421" "16109"
end
save "$shapes/crosswalk_comunas_nuble.dta", replace 


use "$shapes/shapes_uvs.dta", clear 
tab anio
levelsof anio, clean local(anios)

foreach a of local anios {
	preserve 
	keep if anio ==  `a'
	
	*creacion de region de ñuble
	if `a' == 2018 {
	merge m:1 comuna_id using "$shapes/crosswalk_comunas_nuble.dta"
	replace codigo_uv = comuna_nueva + substr(codigo_uv, 5, .) if _merge == 3 
	replace comuna_id = comuna_nueva if _merge == 3
	drop _merge comuna_nueva
	}
	
	if `a' == 2020 {
	replace codigo_uv = substr(codigo_uv, 1, length(codigo_uv)-2) if substr(codigo_uv, -2,2) == ".0"
	}
	
	
	replace nombre_uv = upper(nombre_uv)
	replace comuna_id = upper(comuna_id)
	save "$shapes/shapes_`a'_anual.dta", replace
	restore 
	}


foreach y of numlist 2017/2024 {

	use "$shapes/shapes_`y'_anual.dta", clear

	reclink codigo_uv nombre_uv comuna_id using "$shapes/carto_`y'_anual.dta", ///
	idmaster(id_shapes) idusing(id_carto) ///
	gen(sim_score) wmatch(60 30 30)
	tab _merge

	gen byte comuna_igual = (comuna_id == Ucomuna_id)

	gsort id_shapes -sim_score -comuna_igual
	by id_shapes: gen byte primera = (_n==1)
	keep if primera == 1
	drop primera

	gsort id_carto -sim_score -comuna_igual
	by id_carto: gen byte gana = (_n==1)

	*shapes a los que no se le asigno ningun carto
	preserve
		keep if gana == 0
		keep id_shapes codigo_uv nombre_uv comuna_id
		save "$shapes/perdedores_`y'.dta", replace
	restore

	preserve
		keep if gana == 1
		keep id_carto
		save "$shapes/usados_`y'.dta", replace
	restore

	*cartos que quedaron libres -> no fueron asignados a ningun shape
	preserve
		use "$shapes/carto_`y'_anual.dta", clear
		merge 1:1 id_carto using "$shapes/usados_`y'.dta"
		keep if _merge==1
		drop _merge
		save "$shapes/libres_`y'.dta", replace
	restore

	*si perdio, la asignacion no es valida (id_uv_2024 no se toca: es del master shape)
	replace id_carto =. if gana == 0
	replace Ucodigo_uv = "" if gana == 0
	replace Unombre_uv = "" if gana == 0
	replace Ucomuna_id = "" if gana == 0

	rename codigo_uv codigo_uv_shapes
	rename nombre_uv nombre_shapes
	rename comuna_id comuna_id_shapes
	rename Ucodigo_uv codigo_uv_carto
	rename Unombre_uv nombre_carto
	rename Ucomuna_id comuna_id_carto

	save "$shapes/base_final_`y'.dta", replace

}


*SEGUNDA VUELTA
foreach y of numlist 2017/2024 {
	use "$shapes/perdedores_`y'.dta", clear
	count
	if r(N) > 0 {
		reclink codigo_uv nombre_uv comuna_id using "$shapes/libres_`y'.dta", ///
		idmaster(id_shapes) idusing(id_carto) ///
		gen(sim_score) wmatch(60 30 30)
		tab _merge

		gen byte comuna_igual = (comuna_id == Ucomuna_id)

		gsort id_shapes -sim_score -comuna_igual
		by id_shapes: gen byte primera = (_n==1)
		keep if primera == 1
		drop primera

		gsort id_carto -sim_score -comuna_igual
		by id_carto: gen byte gana2 = (_n==1)

		keep if gana2 == 1

		rename id_carto id_carto_v2
		rename Ucodigo_uv codigo_uv_carto_v2
		rename Unombre_uv nombre_carto_v2
		rename Ucomuna_id comuna_id_carto_v2
		rename sim_score sim_score_v2

		keep id_shapes id_carto_v2 codigo_uv_carto_v2 nombre_carto_v2 comuna_id_carto_v2 sim_score_v2
		save "$shapes/rescatados_`y'.dta", replace

		use "$shapes/base_final_`y'.dta", clear
		merge 1:1 id_shapes using "$shapes/rescatados_`y'.dta", nogen

		gen byte segunda_vuelta = !missing(codigo_uv_carto_v2)
		replace id_carto = id_carto_v2 if segunda_vuelta
		replace codigo_uv_carto = codigo_uv_carto_v2 if segunda_vuelta
		replace nombre_carto = nombre_carto_v2 if segunda_vuelta
		replace comuna_id_carto = comuna_id_carto_v2 if segunda_vuelta
		replace sim_score = sim_score_v2 if segunda_vuelta

		drop id_carto_v2 codigo_uv_carto_v2 nombre_carto_v2 comuna_id_carto_v2 sim_score_v2
		save "$shapes/base_final_`y'.dta", replace
	}
}

use "$shapes/base_final_2017.dta", clear
capture confirm variable segunda_vuelta
if _rc gen byte segunda_vuelta = 0
drop _merge comuna_igual
replace segunda_vuelta = 0 if missing(segunda_vuelta)
foreach y of numlist 2018/2024 {
	append using "$shapes/base_final_`y'.dta"
	capture confirm variable segunda_vuelta
	if _rc gen byte segunda_vuelta = 0
	drop _merge comuna_igual
	drop if codigo_uv_carto == "."
	replace segunda_vuelta = 0 if missing(segunda_vuelta)
	}

* forzar una sola fila por shape x anio: el mejor carto de cada shape
gsort anio id_shapes -sim_score
by anio id_shapes: keep if _n == 1
isid anio id_shapes

gen byte asignado = !missing(id_carto)
tab anio asignado, row
* con shapes de master: los no asignados son shapes que no encontraron carto


*GUARDAMOS BASE CROSSWALK (intermedio: incluye shapes no asignados) !!
save "$shapes/crosswalk_final.dta", replace

tab anio
tabstat sim_score, by(asignado)

isid anio id_shapes
count
count if missing(id_carto)

list anio codigo_uv_shapes nombre_shapes comuna_id_shapes if anio == 2018 & asignado == 0

* entre asignados: cada shape con un carto, cada carto una sola vez
duplicates report anio codigo_uv_shapes if asignado == 1
duplicates report anio codigo_uv_carto  if asignado == 1


*=====================================================================
* BASE FINAL: una fila por shape que cumple los DOS requisitos
*   req 1: shape <-> id_uv_2024        (del master, en todas las filas)
*   req 2: shape <-> codigo_uv_carto   (del reclink)
*=====================================================================

use "$shapes/crosswalk_final.dta", clear
assert !missing(id_uv_2024)

* --- perdida de personas: codigos de carto que quedaron sin pareja de shape ---
preserve
	contract anio if asignado == 1
	rename _freq n_carto_usados
	tempfile usados
	save `usados'

	use "$shapes/carto_uvs.dta", clear
	contract anio
	rename _freq n_carto_total
	merge 1:1 anio using `usados', nogen
	gen n_carto_sin_shape = n_carto_total - n_carto_usados
	list anio n_carto_total n_carto_usados n_carto_sin_shape
restore

* --- solo las filas que cumplen los dos requisitos ---
keep if asignado == 1
keep anio id_uv_2024 codigo_uv_shapes codigo_uv_carto sim_score segunda_vuelta

isid anio codigo_uv_shapes
duplicates report anio codigo_uv_carto

order anio id_uv_2024 codigo_uv_shapes codigo_uv_carto sim_score segunda_vuelta
sort anio id_uv_2024 codigo_uv_shapes

save "$shapes/carto_shape_uv2024.dta", replace
tab anio

























