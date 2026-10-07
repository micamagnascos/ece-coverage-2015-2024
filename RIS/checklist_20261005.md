# Plan RIS — lunes 05/10/2026

Código limpio para pasar en limpio, en este orden: `RIS/limpio_20261005/`
`00_setup.do` → `01_fertilidad.do` → `02_laboral.do` → `03_primera_etapa.do`

**Reglas para tipear rápido**
- No tipees comentarios largos: la explicación está en esta hoja.
- Los gráficos ya **no** se hacen en el RIS. Todo sale como `.dta` y los gráficos los hacemos acá.
- Corre cada do-file **por secciones** (seleccionar + Ctrl+D). Haz el chequeo de cada sección
  antes de pasar a la siguiente. Si un chequeo falla, **para ahí**.
- Mientras corre algo pesado (laboral), tipea el do-file siguiente en otra pestaña del Do-file Editor.

---

## 0. Al llegar (≈ 5 min)

- [ ] Abrir Stata y el Do-file Editor. Crear 4 do-files nuevos con los nombres de arriba, en tu carpeta de códigos.
- [ ] Copiar la **ruta de esa carpeta**: va en `global codigo "..."` (línea 4 de los do-files 01, 02 y 03).
- [ ] Revisar que exista la carpeta `...\FERTILIDAD_ML\estimaciones` (ahí se guarda todo).

---

## 1. `00_setup.do` (≈ 15 min de tipeo)

Qué hace: define las rutas (`$muestra`, `$pe`, `$est`) y 3 programas:
- `guardar`: después de cada regresión anota una fila por k (coef, EE, N, n° UVs, media del control) en `coefs_*.dta`.
- `guardarV`: guarda la matriz de varianzas del Sun-Abraham. Con eso calculo acá el efecto promedio y su EE.
- `balance`: una fila por variable de la tabla de balance (reemplaza el `di` con formatos, así que se acaba el problema de los decimales).

- [ ] Tipear y correr **solo** este do-file (`do 00_setup.do`).
- [ ] ✔ Chequeo: no da error y `di "$est"` muestra la ruta correcta.
- Si alguna vez da "command reghdfe/eventstudyinteract not found": descomentar los `ssc install` (`avar` lo necesita `eventstudyinteract`).

---

## 2. `01_fertilidad.do` (≈ 15 min tipeo + corre rápido)

Base: `muestra_fertilidad_uvs.dta` (UV-año, la colapsaste el 30/09, no hay que rehacerla).

| Sección | Qué hace | ✔ Chequeo / anotar |
|---|---|---|
| 1 | Abre la base | `gduplicates` = 0 duplicados |
| 2 | `keep if muestra_t1==1`, crea `ever_t1` y `nunca_tratada` | `count if missing(g1)` = **0**. Anotar `count` (≈ 45–49 mil) y n° de UVs (≈ 4.400–4.600) |
| 3 | Tendencias año × cohorte (`g1`) → `tend_fert.dta` | — |
| 4 | Balance 2014 → `balance_fert.dta` | Sin errores |
| 5 | `rel_t1_bin` **con el arreglo** (nunca tratadas → −1) y dummies d1–d15 | `count if missing(d1)` = **0**. En `tab rel_t1_bin`, el −1 tiene que ser enorme (≈ 43 mil) y el resto ≈ 200–450 c/u, de −5 a 9 |
| 6 | 4 modelos → `coefs_fert.dta` | **Mirar el primer `reghdfe`:** N ≈ 48 mil y clusters ≈ 4.500. Si sale 4.753 obs / 444 clusters → **Ctrl+Break**, el arreglo no quedó |
| 7 | Lista lo guardado | Tiene que haber filas `twfe`, `twfe_w`, `sa`, `sa_w` con N > 0 |

**Los 4 modelos** (iguales en los 3 do-files):

| `modelo` | Estimador | Pondera | Notas |
|---|---|---|---|
| `twfe` | `reghdfe` (referencia) | no | + `test` de pre-tendencia (`pretest_p`, k=−99) + `lincom` promedio post (`twfe_prom`, k=99) |
| `twfe_w` | `reghdfe` | sí | |
| `sa` | `eventstudyinteract` (Sun-Abraham, **principal**) | no | + guarda `V_sa_tuvo_hijo.dta` |
| `sa_w` | `eventstudyinteract` | sí | |

Todos con EF de UV y año, cluster por UV y control `per_edad` (nuevo en fertilidad, lo pide `Fertility.pdf`).
Control = nunca tratadas. Ventana: k = −5 a +9, con k = −1 de referencia.

---

## 3. `02_laboral.do` (≈ 25 min tipeo, la carga es lenta)

Base: `muestra_laboral_ingresos.dta` (mujer-año, 8,5 M). **Truco de velocidad:** en la sección 1 se botan
las UVs excluidas y las variables que no se usan. Todo lo que sigue corre sobre una base mucho más chica.

| Sección | Qué hace | ✔ Chequeo / anotar |
|---|---|---|
| 1 | Abre, `keep if muestra_t1==1`, `keep` de variables | Anotar el `count` antes y después. 0 duplicados `rut_inn anio` |
| 2 | **Arreglo del ingreso** (ver abajo) | Anotar de `tab anio fuente_ing, row`: % de la fuente 2 en 2014 y en 2024. Del `sum ... detail`: p1 y p99 |
| 3 | Limpia `per_fic_*` y valida `empleo_formal` contra RSH | Anotar: % de `per_fic_trabaja==1` con `empleo_formal==0` (≈ informalidad) |
| 4 | Tendencias año × cohorte (nivel mujer) → `tend_lab.dta` | — |
| 5 | Colapsa a UV-año, guarda `muestra_laboral_uvs_v2.dta` | `count` ≈ 48 mil. `count if missing(g1)` = 0 |
| 6 | Balance 2014 → `balance_lab.dta` | — |
| 7 | `rel_t1_bin` con el arreglo + dummies | Igual que en fertilidad |
| 8 | 4 modelos × 3 outcomes → `coefs_lab.dta` | Primer `reghdfe` (empleo_formal): N ≈ 48 mil, clusters ≈ 4.500 |
| 9 | Lista lo guardado | Filas para los 3 outcomes |

**Qué cambió en el ingreso y por qué**
1. `monto_dep + monto_indep` → `rowtotal(..., missing)`. Antes, si una mujer tenía solo uno de los dos, la suma daba missing y se perdía.
2. `fuente_ing`: muestra si el ingreso viene de renta imponible (1) o de cotizaciones (2). Si la mezcla cambia mucho entre años, parte del "aumento" del ingreso es cambio de fuente.
3. **`ln_ingreso`** reemplaza al ingreso en pesos nominales. Los EF de año absorben la inflación y el coeficiente se lee ≈ como % de cambio. Es el margen intensivo.
4. **`empleo_formal`** (nuevo, outcome principal): 1 si tiene ingreso > 0. Es el margen extensivo, entrar al empleo formal, que es lo esperable del jardín.
5. Peso: `empleo_formal` se pondera por `n_mujeres`; `ln_ingreso` y `meses_trabajando` por `n_con_ingreso` (solo las que tienen ingreso aportan a esa media).

**Outcomes, en orden de prioridad:** `empleo_formal` > `ln_ingreso` > `meses_trabajando`.
Si te falta tiempo, deja solo los dos primeros en el `foreach`.

**Lo que se sacó a propósito:** el balance a nivel mujer y el `reghdfe ... post_t1` estático. Ya están
en el log del 23/09, y el TWFE estático queda superado por los event studies.

---

## 4. `03_primera_etapa.do` (≈ 10 min tipeo, corre rápido)

Base: `primera_etapa_panel_uv.dta` (no reconstruye el panel de niños).

- **Cambio importante:** antes la regresión usaba solo d1–d11 (k hasta +5). Si `rel_t1` llega hasta +9, los años
  k = 6 a 9 quedaban **mezclados con la referencia**. Ahora usa d1–d15 igual que fertilidad y laboral.
- [ ] ✔ En `tab rel_t1_bin`: ¿llega a 9? Si llega **solo hasta 5**, cambia `d6-d15` → `d6-d11` y el `lincom` a `(d6+...+d11)/6`.
- [ ] Resto de los chequeos igual que fertilidad. Con el arreglo, N ≈ 48.348 y 4.568 clusters, como antes.
- `tend_pe.dta` (año × cohorte) sirve para ver acá **el k=−2 por cohorte** sin correr nada más.

---

## 5. Si algo falla

| Error | Solución |
|---|---|
| `variable rel_t1_bin already defined` | Cambiar ese `gen` por `capture drop rel_t1_bin` + `gen ...` |
| `eventstudyinteract` no acepta `d1-d4 d6-d15` | Escribirlas una por una: `d1 d2 d3 d4 d6 ... d15` |
| `post: ... not found` / `pf already in use` | Correr `postclose pf` y volver a correr desde `postfile` |
| En `coefs_*.dta` las filas `sa`/`sa_w` tienen N = 0 | `eventstudyinteract` no guardó `e(sample)`. Los coef y EE igual sirven; anota el N de la pantalla |
| `guardarV`: matrix `e(V_iw)` not found | Borra esa línea, no es crítica |
| El RIS no deja sacar `.dta` | `use archivo.dta, clear` + `export delimited using "archivo.csv", replace` |
| Celdas chicas (cohortes 2020–2024 tienen 4–15 UVs) en `tend_*` | Si el RIS lo objeta, agrupar `g1 >= 2020` antes del collapse |

---

## 6. Extraer → carpeta `RIS/20261005/`

- [ ] `coefs_fert.dta`, `coefs_lab.dta`, `coefs_pe.dta`
- [ ] `V_sa_tuvo_hijo.dta`, `V_sa_empleo_formal.dta`, `V_sa_ln_ingreso.dta`, `V_sa_meses_trabajando.dta`, `V_sa_tasa_matricula.dta`
- [ ] `tend_fert.dta`, `tend_lab.dta`, `tend_pe.dta`
- [ ] `balance_fert.dta`, `balance_lab.dta`
- [ ] `log_fert_20261005.txt`, `log_lab_20261005.txt`, `log_pe_20261005.txt` (logs completos: esto resuelve lo que faltó extraer la vez pasada)
- [ ] Los 4 do-files tal como quedaron corridos

## 7. Hoja de anotaciones (a mano)

| Dato | Valor |
|---|---|
| Fert: N y n° UVs del 1er `reghdfe` | |
| Lab: `count` antes / después del `keep` (sección 1) | |
| Lab: % fuente 2 (cotizaciones) en 2014 / 2024 | |
| Lab: p1 y p99 del ingreso > 0 | |
| Lab: % que dice trabajar en RSH pero `empleo_formal = 0` | |
| PE: ¿`rel_t1_bin` llega a 9? | |
| Cualquier error raro y en qué línea | |

**¿Qué era lo que faltó extraer la vez pasada?** Confirmar si era algo distinto de (a) los descriptivos de laboral
(quedan en el log completo) o (b) la tabla del S-A ponderado de primera etapa (queda en `coefs_pe.dta`).
