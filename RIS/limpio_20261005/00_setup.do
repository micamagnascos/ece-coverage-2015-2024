* 00_SETUP -- rutas y programas. Se llama al inicio de cada do-file.

* (solo si no estan instalados)
* ssc install gtools
* ssc install ftools
* ssc install reghdfe
* ssc install eventstudyinteract
* ssc install avar

global base "\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\01_DATOS_SALIDA\FERTILIDAD_ML"
global muestra "$base/bases_muestra"
global pe "$base/primera etapa"
global est "$base/estimaciones"
set linesize 200


* guardar: una fila por k (coef, ee, N, n UVs, media control) en el postfile pf
capture program drop guardar
program define guardar
	args modelo y m0
	matrix T = r(table)
	quietly count if e(sample)
	local n = r(N)
	quietly gunique id_uv_2024 if e(sample)
	local nuv = r(J)
	post pf ("`modelo'") ("`y'") (-1) (0) (0) (`n') (`nuv') (`m0')
	forvalues t = -5/9 {
		if `t' != -1 {
			local dnum = `t' + 6
			local j = colnumb(T, "d`dnum'")
			if `j' < . {
				post pf ("`modelo'") ("`y'") (`t') (T[1,`j']) (T[2,`j']) (`n') (`nuv') (`m0')
			}
		}
	}
end


* guardarV: matriz de varianzas del Sun-Abraham (para el efecto promedio con su EE)
capture program drop guardarV
program define guardarV
	args nombre
	matrix V = e(V_iw)
	preserve
	clear
	svmat V, names(col)
	save "$est/V_`nombre'.dta", replace
	restore
end


* balance: una fila por variable en el postfile pb (sin ponderar y ponderado por pob_total_uv)
capture program drop balance
program define balance
	args v
	quietly summ `v' if ever_t1 == 0
	local a0 = r(mean)
	local s0 = r(Var)
	quietly summ `v' if ever_t1 == 1
	local a1 = r(mean)
	local s1 = r(Var)
	quietly summ `v' [aw = pob_total_uv] if ever_t1 == 0
	local w0 = r(mean)
	local t0 = r(Var)
	quietly summ `v' [aw = pob_total_uv] if ever_t1 == 1
	local w1 = r(mean)
	local t1 = r(Var)
	post pb ("`v'") (`a0') (`a1') ((`a1'-`a0')/sqrt((`s1'+`s0')/2)) (`w0') (`w1') ((`w1'-`w0')/sqrt((`t1'+`t0')/2))
end


* grafico: event study desde el dta de coeficientes (para mirar en el RIS)
capture program drop grafico
program define grafico
	args archivo y modelo
	preserve
	use "$est/`archivo'.dta", clear
	keep if outcome == "`y'" & modelo == "`modelo'" & k >= -5 & k <= 9
	gen lo = b - 1.96*se
	gen hi = b + 1.96*se
	sort k
	twoway (rcap lo hi k) (scatter b k), yline(0) xline(-0.5, lpattern(dash)) legend(off) xlabel(-5(1)9) xtitle("k") title("`y' - `modelo'") name(g_`y'_`modelo', replace)
	restore
end
