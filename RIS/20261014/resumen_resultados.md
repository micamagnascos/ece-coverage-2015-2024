# Resumen extracción RIS 14/10/2026

## Cambios incorporados en esta extracción

### Muestra laboral 60% más vulnerable (v60) — `08_vulnerables_mudanzas.do`
- **Base:** `muestra_laboral_ingresos.dta` (la misma del 06/10).
- **Madres:** se mantiene la definición antigua: mujer-año con hijo < 5 **ese año** (`tiene_hijo_menor5 == 1`). **Aún no es la muestra fija** (madres con hijo < 5 en algún momento, en `09_merge_muestra_v60.do`, no usada todavía).
- **Vulnerabilidad:** `v60 = 1` si el primer `calc_quintil_validacion2` observado desde 2016 es ≤ 60. Fija por mujer. Mujeres solo en 2014–2015 → v60 missing → fuera.
- **Tratamiento:** igual que antes (`muestra_t1`, cohorte `g1`, UV actual `id_uv_2024`).

| Línea | Madres | Vulnerabilidad | Cohortes |
|---|---|---|---|
| Muestra completa (06/10) | hijo < 5 ese año | todas | todas |
| **v60 (principal)** | hijo < 5 ese año | v60 | todas |
| v60 sin 2015 (robustez) | hijo < 5 ese año | v60 | sin 2015 |

- Estimador: Sun-Abraham, ponderado por n° de madres, EF UV y año, control por edad, cluster UV.

### Muestra nueva (09 corregido, `arreglos_20261014/09_merge_muestra_v60.do`, corriendo 14/10)
- **v60 en ambas muestras** (laboral y fertilidad): FPS `puntaje` ≤ 13.500 en 2014–15, RSH tramo ≤ 60 desde 2016. Fija por mujer en su **primer año con dato** (la mayoría: FPS 2014).
- **Laboral = muestra fija de madres:** entra el **primer año con hijo < 5** y se queda **hasta 2024** (no sale cuando el hijo cumple 5). Ojo: sale si cumple 50 sin hijo < 5 (línea 33).
- Variables de mudanzas con mapa 2024 (`mueve24`, `cambia_uv24`, `cambia_uv24_s22`).
- **Ningún resultado de esta extracción usa esta muestra todavía.**
- N v60: 47.993 UV-año, 4.558 UVs (vs 48.348 / 4.568 muestra completa).

## Empleo formal — v60, ponderado

Gráfico: `graficos/v60_01a_empleo.png`

- **Sin pre-tendencias:** p = 0,79 (k = −5 a −2).
- **Efecto promedio post (k 0–9): +0,76 pp** (EE 0,38), significativo al 5%. Media control 46,3% → **≈ +1,6%**.
- Efecto gradual: 0 en k = 0, ~+1 pp desde k = 4.
- Igual a la muestra completa (v60 = 2/3 de la muestra).
- Sin 2015: +1,0 pp (EE 0,45). La subida en k lejanos es composición (k = 8 = solo cohorte 2016), no crecimiento del efecto. No mostrar; respaldo si preguntan.

## ln ingreso — v60, ponderado (madres con ingreso)

Gráfico: `graficos/v60_01b_ln_ingreso.png`

- **Sin pre-tendencias:** p = 0,81.
- **Sin efecto:** promedio post **+0,3%** (EE 1,4%). Sin 2015: +2,3% (EE 1,9%), tampoco significativo.
- Muestra completa: puntos algo mayores (~+3% en k 3–6), tampoco significativos.
- k = 8 negativo (−4%) = composición (solo cohortes 2015–2016), no una caída.
- **Junto con empleo:** más madres trabajan, pero las que trabajan no ganan más → el efecto en ingreso, si existe, va por el **margen extensivo**.
- Ojo, selección: las que entran a trabajar por el jardín probablemente lo hacen con sueldos más bajos → empuja ln ingreso hacia abajo. Por eso el outcome que junta ambos márgenes es `ingreso_rel` (con ceros).
- Margen intensivo: no había efecto en ninguna de las dos muestras; la lógica de dilución aplica sobre todo a empleo.

## Meses trabajando — v60, ponderado (madres con ingreso)

Gráfico: `graficos/v60_01c_meses.png`

- **Sin pre-tendencias:** p = 0,66.
- **Cero preciso:** promedio post **−0,02 meses** (EE 0,04), media control 8,3 meses → IC ±1%. Sin 2015: +0,01 (EE 0,05).
- Misma advertencia de selección que ln ingreso.

## Ingreso con ceros (ingreso_rel) — v60, ponderado

Gráfico: `graficos/v60_01d_ingreso_rel.png` (sin muestra completa: el SA del 07 está mal estimado, error 1; el TWFE no es comparable).

- **Definición:** ingreso anual de cada madre, 0 si no tiene ingreso, ÷ promedio del año sobre **todas** las madres v60 (incluidas las con 0) × 100. 100 = madre v60 promedio del año. Junta ambos márgenes (más madres trabajando + más ingreso de las que trabajan).
- **Pre-tendencias:** p = 0,49, pero los pre suben levemente (−2,0 → −0,9 → 0 de k −3 a −1). Mismo patrón que ingreso 06/10. Tener presente.
- **Efecto promedio post: +2,2 puntos (≈ +2%)** (EE 1,2), significativo solo al 10%. Máximo en k = 3–4 (+4,0 y +3,3, significativos); desde k = 5 los IC cruzan 0 (menos UVs + cohortes tempranas, incluida 2015).
- **Sin 2015: +5,3 puntos (EE 1,7), significativo al 1%.** Aquí 2015 sí pesa: su ingreso caía desde antes (tendencia propia, sin pre para verificar).
- Pendiente: winsorizar el 1% superior de `ingreso_rel` (puede mejorar la precisión).

**Ejemplo (montos ilustrativos):** UV con 100 madres v60.
- Antes: 46 trabajan y ganan $4.350.000/año; 54 ganan 0 → promedio por madre $2.000.000 = 100 puntos.
- Después (+2,2 puntos): promedio por madre $2.044.000 → **+$44.000/año por madre**.
- Por empleo: +0,76 pp = 0,76 madres más trabajando por cada 100 × $4.350.000 ≈ $3.300.000 en la UV → +$33.000 por madre ≈ **+1,65 puntos**.
- → **~75% del aumento de ingreso se explica porque más madres trabajan.** El resto (~0,5 puntos) es chico y consistente con ln ingreso ≈ 0.

## Primera etapa sin cohorte 2015 — muestra completa, ponderado por niños

Gráfico: `graficos/pe_01_sin2015.png`. Muestra completa (no v60); solo cambia sacar 2015.

- **Pre idénticos** con y sin 2015 (2015 no aporta a ningún pre) y planos.
- **Sin 2015: +2,7 pp** promedio k 0–7 (vs +1,8 pp con todas) → **~50% mayor**. Media control 33,2% → ≈ +8%. Salta en k = 0 y se mantiene ~+3 pp en k 1–5; todos los k 0–7 significativos.
- Sin EE del promedio ponderado (falta V de `sa_w`, error 16).
- En niños: UV tratada promedio ≈ 148 niños 0–4 (hijos de madres de la muestra) → **~4 niños más matriculados por UV** (vs ~3 con todas). **Sigue siendo chico** frente a los cupos de un jardín nuevo (decenas).
- Dos lecturas: (1) aperturas 2015 = error de registro → efecto real ≈ 2,7 pp, sacar 2015 en todo; (2) aperturas reales → efecto distinto por cohorte, el principal es con todas.
- Chequeo para distinguirlas: ¿los jardines "nuevos" 2015 tenían matrícula en 2014 (`mat_parv`)? **No es barato:** requiere revisar matrícula por establecimiento, aún no explorada en el RIS.

## v60 como población elegible: ¿por qué el efecto no sube más?

- v60 = población elegible para jardín público → sacar a las no elegibles debería **limpiar la dilución** y subir el efecto.
- Empleo: completa ~+0,73 pp vs v60 +0,76 pp. Si el 1/3 no-v60 tuviera efecto 0, se esperaría ≈ 0,73 / 0,66 ≈ **1,1 pp**.
- Posibles razones (no excluyentes):
  1. Las que salen no son ricas: la muestra ya es RSH; las no-v60 son tramos 70–100 (clase media). v60 = 66% de la muestra.
  2. Elegibilidad no estricta en la práctica (cupos sobrantes → entran otras familias).
  3. Error de medición en v60 (primer tramo desde 2016, no el tramo al matricular).
  4. Precisión: IC de v60 ≈ 0 a 1,5 pp, incluye 1,1.
- **Chequeo:** estimar el 40% no vulnerable por separado. Si da 0 → v60 es el efecto relevante; si da parecido → las no-v60 también responden.

## Patrón laboral v60

| Outcome | Margen | Efecto v60 |
|---|---|---|
| Empleo formal | extensivo | +0,76 pp, significativo |
| ln ingreso | intensivo | 0 |
| Meses trabajando | intensivo | 0 (preciso) |
| Ingreso con ceros | ambos | +2,2 puntos (≈ +2%), sig. 10%; sin 2015: +5,3, sig. 1% |

→ El jardín cambia **si** las madres trabajan, no cuánto trabajan las que ya lo hacían. El aumento de ingreso viene casi todo de ese margen.

## Nivel individual — v60

- **EF de UV + año (`coefs_lab_ind_v60`, twfe_ind / sa_ind):** replica el nivel UV ponderado casi al decimal (empleo k = 5: 1,06 vs 1,06). Esperable: el tratamiento varía a nivel UV-año, así que con EF de UV la regresión individual = regresión de promedios UV ponderada por n° de madres. **No es resultado nuevo; confirma que el colapso está bien.** Respaldo para los profesores.
- **EF de mujer + año (`coefs_lab_indm_v60`):** **no válido** (errores 2 y 2b: evento con `rel_t1` y `pre_f` sin `by`). Se rehace con `arreglos_20261014/13_indm_rapido.do`: UV fija (primera UV observada; las que se mudan se quedan con el tratamiento de su UV inicial), evento con `rel_f`, sobre la muestra fija v60 del 09.

### EF de mujer, UV fija, muestra fija v60 — empleo formal (corrido 14/10, preliminar, leído en pantalla)
- SA, EF mujer + año, cluster UV fija. ~5 millones de obs, **1.634 clusters**. Corrió ~20 min.
- **Ojo, versión anterior de la muestra fija:** incluía todos los años 2014–2024 de la madre, también **antes** del nacimiento (el 09 que corrió el 13/10). La definición se corrigió (desde el primer año con hijo < 5) → hay que re-correr el 13 con la base nueva.
- **Pre (d1–d4) no significativos** (k = −5: +1,0 pp, ruido).
- **Post: gradual.** No significativo en k 0–2; **significativo desde k = 4 (d10)**; llega a **+1,6 pp en k = 9**.
- → **Misma historia que nivel UV comparando a la misma madre** (y con las que se mudan en su UV inicial). Se sostiene.
- Falta: promedio post con EE y pretest conjunto (no se guardó la V; `lincom` no corrió después del do-file).
- **Revisar:** 1.634 clusters vs ~4.560 UVs a nivel UV → se pierden 2/3 de las UVs. Probable: `muestra_f` = 0/missing porque `muestra_t1` del primer año (2014) no hizo match. Chequeo: `tab muestra_f, m` antes del `keep`; si hay muchos missing, usar el `muestra_t1` del primer año no missing.
- Para la próxima corrida: agregar `guardar`/`guardarV` y `lincom` + `test` dentro del mismo do-file, justo después del `eventstudyinteract`.

## Pasos a seguir

### Próxima sesión RIS (en orden)
1. **Revisar si el 11 sobrescribió** `primera_etapa_panel.dta` / `primera_etapa_panel_uv.dta` (error 3). Si sí, re-correr el original antes de cualquier cosa de primera etapa.
2. **El 09 corregido quedó corriendo el 14/10** (FPS 2014–15 + madres desde el primer hijo hasta 2024 + error 6 arreglado). Revisar el log: `tab anio` después del CAMBIO 5 y `tab anio_v v60`.
3. **Re-correr el 13 con la base nueva:** EF de mujer, UV fija, muestra fija v60, empleo formal (pedidos 2a y 3 de los profesores). Revisar `d5 = −1` antes del eventstudy.
4. **Arreglar el 07 y re-correr** SA y SA_w sobre `ingreso_rel` en muestra completa (con `guardarV`).
5. **Winsorizar** el 1% superior de `ingreso_rel`.
6. **Correr el 10** (fertilidad v60).
7. **Heterogeneidad por edad del hijo menor ponderada** (`04_heterogeneidad_edad.do`): hoy solo existe sin ponderar (`coefs_het_lab`: sa_e1–e3). Agregar `eventstudyinteract ... [aw = n_mujeres]` por grupo de edad + `guardarV`; idealmente con la muestra v60. Se sacó de la presentación del 15/10 por no estar ponderada.
8. **Primera etapa por edad del niño ponderada** (`04_heterogeneidad_edad.do`, `coefs_het_pe`): hoy solo sin ponderar (sa_e1–e3). Agregar `[aw = n_ninos]` + `guardarV`. Se mostró igual el 15/10 (diapo 17), sin ponderar → **hacerlo bien la próxima semana**.

### Después
7. Estimaciones laborales a nivel UV con la **muestra fija v60** (adaptar 02 a la base del 09).
8. **40% no vulnerable por separado** → ¿el efecto en empleo está concentrado en v60?
8b. **¿Quién llena el jardín nuevo?** (a) DiD sobre matrícula en JUNJI/Integra (cualquier UV) vs. otros jardines (`dependencia` en `mat_parv`); (b) descriptivo: niños de la UV matriculados en el jardín nuevo (uso bruto). Bruto − neto = sustitución. Solo (a) es DiD: (b) es 0 por construcción en controles y antes de la apertura.
9. **Cohorte 2015:** ¿jardines "nuevos" 2015 con matrícula en 2014? (requiere explorar `mat_parv` por establecimiento).
10. Pedidos de los profesores aún sin empezar: tratamiento por stock inicial de jardines (no solo stock 2014 = 0) y muestra por probabilidad predicha de embarazo.

### Próxima extracción
- V faltantes (error 16), tendencias y balances (error 15), logs (error 18), coefs del 13 con `guardar`/`guardarV`.

## Errores a corregir

### Graves (cambian resultados)
1. **07_ingreso_total.do, líneas 72 y 76 — SA estima el outcome equivocado.** `eventstudyinteract n_mujeres ...` debe ser `eventstudyinteract ingreso_rel ...`. Hoy `sa` y `sa_w` de `coefs_ingtotal` son el efecto sobre el **n° de mujeres en la UV**, no sobre el ingreso. Arreglar también `guardar sa`/`guardar sa_w` (outcome `ingreso_rel`) y `guardarV sa_ingreso_rel` / `guardarV sa_w_ingreso_rel` (líneas 73–78).
   - El resultado sobre n_mujeres no se usa: es un error. Hay que re-correr SA y SA_w sobre `ingreso_rel` (muestra completa) para tener la comparación con v60.
2. **08_vulnerables_mudanzas.do, líneas 179–182 — EF de mujer usa el evento de la UV actual.** Los dummies se arman con `rel_t1` y debe ser `rel_f` (creado en la línea 177 y no usado). Cohorte (`g1_f`) y evento quedan de UVs distintas → `sa_indm` inconsistente, **descartar**. Corrección:
   ```stata
   gen rel_t1_bin = rel_f
   replace rel_t1_bin = -5 if rel_f < -5
   replace rel_t1_bin = -1 if missing(rel_f)
   ```
   `twfe_indm` actual es coherente pero es otra especificación (tratamiento según UV actual, no ITT con UV fija).
2b. **08_vulnerables_mudanzas.do, línea 54 — `pre_f` sin `by rut_inn:`.** `anio[1]` toma el primer año de toda la base (≈ 2014), no el de cada mujer → `pre_f ≈ 1` para todas y el filtro no saca a las que entran después de la apertura. Corrección: `gen pre_f = (g1_f == 0 | anio_ent < g1_f)`. Afecta también `twfe_indm`. Como `pre_f` quedó guardado en `muestra_laboral_v60_ind.dta`, rehacerlo antes del `keep`.
3. **11_primera_etapa_v60.do, líneas 99 y 107 — sobrescribe las bases de la muestra completa.** Guarda en `primera_etapa_panel.dta` y `primera_etapa_panel_uv.dta`. Cambiar a `primera_etapa_panel_v60.dta` y `primera_etapa_panel_uv_v60.dta`. **Revisar en el RIS si ya se sobrescribieron** (si sí, re-correr el 11 original).
4. **11_primera_etapa_v60.do, línea 40 — merge con la base sin v60.** Usa `muestra_completa_ruts_trat.dta`; debe ser `muestra_completa_ruts_trat_v60.dta` (la que guarda el 09). Si no, `keep if v60 == 1` (línea 46) falla.
5. **03_primera_etapa_sin2015.do, línea 55 — promedio post mal dividido.** Suma 9 dummies (d6–d14) y divide por 10 → subestima 10%. Debe ser `/9`. (Por ahora se corrige a mano: × 10/9.)

### Pueden detener el do-file
6. **09_merge_muestra_v60.do, línea 133 — `drop tag_m` antes de crearla** → error r(111). **Arreglado** en `arreglos_20261014/09` (`capture drop tag_m`).
7. **08_vulnerables_mudanzas.do, línea 43 — `tag_m` creada dos veces** (ya existe desde la línea 19) → error r(110). Se arregló a mano en la sesión; dejarlo corregido en el do-file (agregar `drop tag_m` antes de la línea 43).
8. **11_primera_etapa_v60.do, desde la línea ~110 — código antiguo al final** (gráficos, `time_to_event`, `panel_mat_hijos`). Variables que ya no existen → error, y puede volver a guardar `panel_mat_hijos.dta`. Borrar todo lo que viene después de guardar las bases.

### Etiquetas y nombres (no cambian resultados)
9. **07, línea 70:** `guardar twfe_w n_mujeres'` → `guardar twfe_w ingreso_rel` (apóstrofe de más y outcome mal etiquetado; el coef sí es de ingreso_rel).
10. **03, línea 59:** `guardar twfe_w tasa_matricula_sin2015` → `tasa_matricula` (se trunca a 20 caracteres en el postfile).
11. **03, líneas 63 y 67:** `guardarV tasa_matricula_sin2015` → `sa_tasa_matricula_sin2015` (falta el prefijo del modelo).
12. **07, líneas 85–87 y 08, líneas 225–226:** `grafico` apunta a la base o modelo equivocado (`coefs_lab` en 07; `coefs_lab_v60 ... sa_ind` en 08). Sin efecto si los gráficos se hacen afuera; borrar.
13. **08, línea 191:** `per_edad` en `twfe_indm` es colineal con EF de mujer + año (Stata la omite). Sacarla.

### Faltó extraer / confirmar
14. **`v_sa_ingreso_rel.csv` es copia idéntica de `v_sa_v60s15_ingreso_rel.csv`** (lo mismo con `_w`). Descartar; extraer la V correcta de 07 después de arreglar el punto 1.
15. **Balances y tendencias:** no vienen. Extraer `tend_pe_sin2015.dta` (lo guarda el 03) y los `balance_*`/`tend_*` que correspondan.
16. **V que faltan:** `v_sa_w_tasa_matricula_sin2015`, `v_sa_indm_*`, `v_sa_ind_*` y las V ponderadas de la muestra completa del 06/10 (`v_sa_w_empleo_formal`, etc.) para comparar con v60.
17. **Código de `coefs_lab_ind_v60` (twfe_ind / sa_ind):** no está en el 08 extraído. Confirmar que es EF de UV + año, cluster UV, con `per_edad` (sección 7 del borrador `arreglos_20261013/08`).
18. **Logs:** falta `log_muestras_v60_20261013.txt` (09 + 11) para saber si terminaron. El log del 08 se corta después del error de `tag_m` (no muestra estimaciones). El 10 (fertilidad v60) no se ha corrido.
