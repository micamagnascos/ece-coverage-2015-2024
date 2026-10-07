# Resumen resultados RIS 06/10/2026

## Errores a corregir en los do-files
1. `03_primera_etapa.do`: `guardar twfe_w tuvo_hijo` → debe decir `tasa_matricula` (quedó mal etiquetado en coefs_pe).
2. `04_heterogeneidad_edad.do`: no guarda pretest (`test d1 d2 d3 d4`), promedio post (`lincom`) ni V de Sun-Abraham (`guardarV`). No controla por `per_edad` (los modelos principales sí).
3. `06_horas.do`: `hogar` y `cuida_hogar` con pretest p ≈ 0 → pre-tendencias no paralelas.
4. `per_fic_trabaja`: el valor 0 (6,8%) se trata como "no trabaja" junto con el 2. Revisar etiqueta.
5. `03_primera_etapa.do` (y 01, 02, 05, 06): `guardarV` solo después de `sa`, no de `sa_w` → sin SE del promedio ponderado. Agregar `guardarV sa_w_<y>` tras el eventstudyinteract ponderado.
6. Promedio SA en el RIS: NO usar `matrix b = e(b_iw)` / `ereturn post b V` antes de `lincom` (dio promedios inconsistentes: empleo 0,0020 y ln ingreso 0,108 vs 0,0059 y 0,023 esperados). Usar `lincom` directo después de `eventstudyinteract`. Ya corregido en `arreglos_20261006/07_ingreso_total.do`.
7. `06_horas.do`: en `busca` el k = 9 sale 0 (sin SE) → no hay celdas tratadas en k = 9 con dato de búsqueda; revisar.

## Revisión general
- Contenido: 7 do-files (00–06), coefs de primera etapa, fertilidad, laboral, heterogeneidad por edad, control limpio y horas/RSH; tendencias por cohorte; balances 2014; matrices V de Sun-Abraham.
- Cruces OK: spec `todas` de 05 = estimaciones de 01–03 (300 filas idénticas); √diag(V) = se.
- 422 UVs tratadas vs ~3.900–4.000 nunca tratadas. Control limpio: `abre` ~2.150 controles, `jardin` ~650.
- Balance 2014: tratadas ~2x más grandes (pob d = 0,42); outcomes en nivel balanceados (|d| < 0,1).

## 1. Primera etapa (tasa_matricula)

### Paso 1: tendencias crudas por cohorte
Gráficos: `graficos/pe_01a_tendencias_pool.png`, `pe_01b_brecha_cohortes.png`, `pe_01c_brecha_cohortes_tardias.png`, `pe_01d_niveles_cohortes.png` (niveles: cohorte vs nunca tratadas).

Qué muestra: cada panel es un conjunto fijo de UVs (las que abrieron en el año g), seguido en todos los años 2014–2024. Cada punto = tasa de matrícula agregada de esas UVs (matriculados / niños 0–4) menos la misma tasa en las nunca tratadas. Es el insumo directo del ATT(g,t) del JEL (ec. 23): efecto = brecha en t − brecha en g−1.

Tamaño de cohortes: 2015 = 172 UVs; 2015–2019 = 378 de 422 (90%); 2020–2024 = 4 a 15 UVs cada una.

Por cohorte:
- 2015: brecha +0,5 pp (2014) → ~+2 pp (2021–2024). Efecto pequeño y gradual. Solo un año pre. Es la cohorte más grande y la única en k = 9.
- 2016: la brecha sube antes de la apertura (2,9 → 4,2 pp en k = −1), luego 6,8 pp y cae desde 2018.
- 2017: plana antes, salto ~+3 pp en la apertura, crece a ~+5.
- 2018: nivel bajo (−3,5 pp) pero plano antes; sube +1,5 pp el primer año y +2,7 pp el segundo.
- 2019: plana antes, salto +3,7 pp en la apertura.
- 2020 (7 UVs): sin efecto, brecha más negativa después (−3,6 → −5 pp).
- 2021 (15 UVs): +1 a +1,7 pp hacia 2023–2024.
- 2022 (10 UVs): tendencia pre al alza (−3,6 → +0,7 pp) y luego salto +3,4 pp.
- 2023 (8 UVs): +2,4 pp.
- 2024 (4 UVs): un solo año post, sin cambio.

Agrupado: shocks comunes (COVID 2020–21) afectan a ambos grupos igual; brecha crece de −0,35 pp (2014) a +2,1 pp (2024).

Implicancias:
- Event time desbalanceado: k post lejanos (7–9) = casi solo cohorte 2015; k pre lejanos (−5 a −3) = cohortes ≥2017. La cohorte 2015 no aporta al test de pre-tendencias.
- Dinámicas distintas por cohorte → el event study TWFE puede estar contaminado (JEL §5.3); referencia = Sun-Abraham.

Pendientes:
- Cohorte 2015: por qué el efecto es menor (¿aperturas que ya funcionaban y se registraron tarde?).
- Cohorte 2016: revisar fechas de apertura (salto en k = −1).

Nota k: k = anio − g1. Cohorte 2015 es la única en k = 9 (178 celdas), 2015+2016 en k = 8 (239), 2015–2017 en k = 7 (314). Cohorte 2015 no aporta a k = −5…−2.

### Paso 2: event study, 4 modelos (coefs_pe.csv)
TWFE vs SA = estimador (TWFE usa ya-tratadas como control, JEL §5.3). Sin ponderar vs ponderado (n_ninos) = parámetro: UV promedio vs niño promedio.

| k | TWFE | SA | TWFE_w | SA_w |
|---|---|---|---|---|
| −5 | +0,7 | +0,6 | −0,8 | −0,1 |
| −4 | +0,2 | +0,5 | −0,3 | +0,3 |
| −3 | −0,1 | +0,7 | −0,9* | −0,2 |
| −2 | −1,2 (t −1,9) | +0,2 | −0,9* | −0,2 |
| 0 | 3,2* | 3,1* | 1,7* | 1,6* |
| 1 | 3,5* | 3,5* | 2,3* | 2,3* |
| 2 | 2,8* | 2,8* | 2,2* | 2,1* |
| 3 | 3,1* | 3,1* | 1,8* | 1,7* |
| 4 | 2,9* | 3,0* | 1,9* | 1,9* |
| 5 | 3,2* | 3,4* | 2,0* | 2,0* |
| 6 | 2,8* | 2,8* | 2,0* | 1,7* |
| 7 | 1,7 | 1,6 | 1,7* | 1,2* |
| 8 | 0,7 | 0,0 | 1,2 | 0,4 |
| 9 | 1,0 | −1,0 | 1,5* | 0,3 |

pp; * p<0,05; media control 32,4% (sin ponderar), 33,2% (ponderado).

- SA: efecto inmediato ~+3 pp (k = 0–6), ~+10% relativo. Pre todos < 0,7 pp, no significativos.
- SA_w: ~+2 pp; pre muy precisos (SE 0,3–0,4 pp).
- TWFE: k = −2 = −1,2 pp; TWFE_w: k = −3 y −2 significativos. En SA desaparecen → el k = −2 de semanas anteriores era del estimador.
- Ponderado < sin ponderar: UVs grandes, efecto menor en la tasa (cupos fijos / más niños).
- Caída k = 7–9 en SA = composición (solo cohorte 2015), no desvanecimiento.
- Promedios simples (sin SE): SA k0–9 = 2,2 pp, k0–6 = 3,1 pp; SA_w k0–9 = 1,5 pp, k0–6 = 1,9 pp. Pretest p = 0,11 es de TWFE.

### Magnitud de la primera etapa
- pp = diferencia absoluta de tasas (32,4% → 35,4%); % = relativo (3/32,4 ≈ +9%). Ponderado: +2 pp / 33,2% ≈ +6%.
- En niños: UV tratada ≈ 143 niños 0–4 en muestra → +3 pp ≈ 4 niños, +2 pp ≈ 3 niños netos por UV. Muy por debajo de los cupos de un jardín.
- Sin ponderar = UV promedio; ponderado por n_ninos = niño promedio. Dilución al ponderar: mismos cupos / más niños = menos pp. Tratadas 2x más grandes. Para escalar laboral (Wald) usar la misma ponderación en ambos.

Razones de efecto chico:
1. Cohorte 2015: 41% de tratadas en k = 0, ~50% en k = 6; efecto crudo k0–6 ≈ 0,7 pp. Aprox. resto de cohortes ≈ 2,9 pp ponderado (vs 1,9 total). Hipótesis: error de registro en borde del panel (jardines existentes que aparecen como apertura 2015). Verificar: ¿establecimientos "nuevos" 2015 tienen matrícula en 2014 en mat_parv? Re-estimar con `drop if g1 == 2015`.
2. Ponderación por niños (arriba).
3. Denominador 0–4: tasa control 8% (0–1), 35% (2–3), 68% (4). Ver heterogeneidad.
4. Sustitución: outcome = matriculado en cualquier jardín; si el nuevo se llena con niños ya matriculados, la tasa neta no cambia. Verificar: matrícula en el jardín nuevo vs aumento neto en la UV.
5. Spillovers a controles: TWFE promedio casi igual con 3 controles (2,47 / 2,55 / 2,43 pp) → parecen menores.

### Paso 3: promedio post SA con V (JEL §5.1.3, §5.2.4)
Promedio simple de los ATT_es(k) post; SE = √(a′Va) porque los coeficientes están correlacionados (mismo k = −1 y mismo control). No es el TWFE estático (ec. 22).

| Promedio SA | Efecto | SE | IC 95% |
|---|---|---|---|
| k 0–9 | 2,23 pp | 0,63 | [0,99 ; 3,47] |
| k 0–6 | 3,11 pp | 0,58 | [1,97 ; 4,24] |
| k 0–5 | 3,16 pp | 0,57 | [2,04 ; 4,28] |
| pre k −5…−2 | 0,49 pp | 0,59 | [−0,68 ; 1,65] |

- Pretest conjunto SA: χ²(4) = 1,07, p = 0,90 (TWFE: p = 0,11).
- Diferencia k0–9 vs k0–6 = k 7–9 (cohorte 2015). Propuesta: principal k0–5/k0–6 (balanceado), k0–9 robustez.
- Pre: IC del promedio ≤ 1,65 pp → descarta pre-tendencia del tamaño del efecto (3 pp). No prueba PT (bajo poder, JEL §5.1.2).
- SE ingenuo (sin covarianzas) k0–9 = 0,27 vs correcto 0,63.
- SA_w sin SE (no se guardó V).

### Paso 4: heterogeneidad por edad del niño (coefs_het_pe.csv)
Gráfico: `graficos/pe_03_het_edad.png`. Para qué: validar mecanismo (efecto en edades de jardín) y anticipar laboral.

| Grupo | Media control | SA prom k0–6 | Relativo |
|---|---|---|---|
| Sala cuna (0–1) | 8% | +1,3 pp | +15% |
| Medio (2–3) | 35% | +4,2 pp | +12% |
| Transición (4) | 68% | +3,6 pp | +5% |

(sin SE: 04 no guarda V)
- Medio: mayor efecto, inmediato y estable.
- Sala cuna: chico en pp, mayor relativo; crece con k (~0,7 → ~2 pp en k 4–5).
- Transición: +3,6 pp, inesperado. Posibles causas: edad = anio − anio_nac (edad a dic., no a marzo) → "4" incluye niños de medio mayor y "0–1" incluye recién nacidos post-marzo (diluye sala cuna); jardines con NT1.
- Medio: pre-tendencia SA k = −5 = +4,0 pp (t ≈ 3,5), luego 1,7 / 1,4 / 0,4 → brecha cerrándose antes, salto después. k = −5 = bin y cohortes tardías. Dirección contraria al efecto.
- TWFE ≈ SA post en los 3 grupos.
- Por hacer: redefinir edad con corte de matrícula (31/03 o `edad_30_06`); guardar V en 04.

### Paso 5: control limpio (coefs_ctrl.csv)
Gráfico: `graficos/pe_04_control_limpio.png`. Para qué: si niños de controles vecinos se matriculan en el jardín nuevo, el control sube y el efecto se subestima. Sacar controles contaminados y ver si cambia.

| Control | UVs ctrl | Media | SA k0–6 | SA k0–9 | Pretest p | SA_w k0–6 |
|---|---|---|---|---|---|---|
| todas | 4.146 | 32,4% | 3,11 (0,58) | 2,23 (0,63) | 0,90 | 1,92 |
| abre | 2.150 | 31,2% | 3,21 (0,60) | 2,32 (0,65) | 0,95 | 2,14 |
| jardin | 652 | 27,2% | 2,82 (0,69) | 2,00 (0,78) | 0,72 | 2,13 |

- Efecto igual con los 3 controles (diferencias << 1 SE). Spillovers no explican efecto chico → se descarta razón 5.
- Pre-tendencias limpias en los 3. Costo = precisión (SE 0,58 → 0,69).
- Controles `jardin` con menor matrícula (más aislados) y mismo efecto.
- `abre` es el conceptualmente correcto (jardín vecino fijo lo absorben los EF).

### Cierre primera etapa
~+3 pp por UV / ~+2 pp por niño, inmediata, estable, sin pre-tendencias (SA), robusta al control. Chica; candidatos: cohorte 2015, edad/denominador, sustitución.

### Corrida sin cohorte 2015 (07/10, números leídos en pantalla, sin V)
`arreglos_20261006/03_primera_etapa_sin2015.do`. d6–d14 = k 0–8 (sin k = 9).
- SA k 0–8: 4,7 / 5,2 / 5,1 / 4,8 / 4,4 / 4,5 / 4,3 / 4,5 / 4,9 pp. Prom k 0–6 = 4,7 pp (vs 3,1).
- SA_w ≈ 3 pp en todos los k (vs 1,9).
- TWFE prom = 4,66 pp (SE 0,80) (vs 2,47). Pretest TWFE p = 0,024: pre k −5…−2 todos ≈ +0,5 pp, no significativos uno a uno (mismo signo) → chicos frente a 4,7 pp. n_uv = 4.391.
- +50%: coincide con cálculo aproximado (2,9 pp ponderado). Caída k 7–9 era composición.
- Pendiente: extraer `coefs_pe_sin2015` + V (sa y sa_w) → SE del promedio SA y pretest SA.
- Interpretación: cambia la población (cohortes 2016–2024). Válido como "efecto real" solo si aperturas 2015 son error de registro (JEL §5.2.2).

## 2. Fertilidad (tuvo_hijo)

### Paso 1: tendencias crudas por cohorte
Gráficos: `graficos/fe_01a_tendencias_pool.png`, `fe_01b_brecha_cohortes.png`, `fe_01c_brecha_cohortes_tardias.png`, `fe_01d_niveles_cohortes.png` (niveles).
- Brecha = cohorte − nunca tratadas cada año (1ª diferencia: saca la tendencia común). Efecto = brecha después − brecha antes (2ª diferencia). En niveles la cohorte cae después de abrir, pero los controles caen igual.
- Caída común 6,0% (2014) → 2,9% (2024): natalidad Chile + envejecimiento de la muestra (edad 31,9 → 33,7). Tratadas y controles se superponen; brecha agrupada entre −0,10 y +0,05 pp.
- Edad balanceada (diferencia ≤ 0,2 años).
- Sin salto en la apertura en ninguna cohorte grande. 2015 plana (~+0,1); 2016 baja de +0,4 a ~−0,1 (desde pre alto, 57 UVs); 2017 ±0,15; 2018 ruidosa; 2019 sube ~+0,3 post pero oscilaba antes. 2020–2024: ruido (hasta ±1,8 pp).
- Ruido intra-cohorte ±0,2–0,4 pp ≈ tamaño de cualquier efecto plausible (0,2 pp = +5% sobre base 4%).
- Esperado: event study plano; clave = cero preciso vs cero ruidoso (IC).

### Paso 2: event study, 4 modelos (coefs_fert.csv)
Gráfico: `graficos/fe_02_eventstudy.png`. Media control 4,3%. Covariable: per_edad.
- Sin efecto: post oscilan en torno a 0, sin salto. 1 de 40 coef. post significativo (SA_w k = 8: −0,22 pp, t −2,2) ≈ azar; k = 8 = solo cohortes 2015–2016.
- Pre limpias; pretest TWFE p = 0,56.
- TWFE ≈ SA (sin heterogeneidad que contaminar si efecto = 0 en todas).
- Ponderado mucho más preciso (IC ±0,15 vs ±0,3 pp): UVs chicas con pocas mujeres = tasas ruidosas. Ponderado = modelo más informativo para fertilidad.

### Paso 3: promedio post y precisión (cero preciso vs ruidoso)
| Modelo | Promedio | IC 95% | IC relativo (base 4,3%) |
|---|---|---|---|
| SA k0–6 | 0,00 pp (SE 0,11) | [−0,21 ; +0,22] | ±5% |
| SA k0–9 | −0,05 pp (SE 0,12) | [−0,28 ; +0,19] | [−6,5% ; +4,4%] |
| SA_w k0–6 | −0,03 pp | [−0,18 ; +0,12]* | [−4,3% ; +2,7%] |

*SA_w sin V: cota conservadora (promedio de SE). Pretest SA p = 0,67.
- Se descartan efectos mayores a ~±5% en fertilidad de la UV.
- Referencia (verificar): Bauernschuster, Hener & Rainer (2016), +10 pp cobertura → ~+3% nacimientos. Escalado a +3 pp → ~+1% (~0,04 pp): dentro del IC → no distinguible de 0.
- Cero relativamente preciso para la UV, pero no para el efecto esperado dada la primera etapa chica (dilución UV). Más poder: madres con hijos pequeños / análisis a nivel mujer.
- Conclusión: no hay efecto en fertilidad.

## 3. Mercado laboral (empleo_formal, ln_ingreso, meses_trabajando)

### Paso 1: tendencias crudas por cohorte
Gráficos: `graficos/lab_01a_tendencias_pool.png`, `lab_01b_brecha_empleo.png`, `lab_01c_brecha_empleo_tardias.png`, `lab_01d_brecha_ingreso.png`, `lab_01e_brecha_meses.png`.
- ln ingreso y meses = solo madres con ingreso → efecto composición si entran nuevas trabajadoras.
- Magnitud esperable: 0,03 (primera etapa) × ~15 pp (efecto por madre) ≈ 0,5 pp a nivel UV.
- Tendencias comunes paralelas (empleo 51% → 57%, salto 2021–22 común; ingreso nominal). Niveles: tratadas −0,03 log ingreso y −0,07 meses, paralelo (EF).
- Brecha agrupada empleo: −0,4 pp (2014) → +0,7 pp (2024).
- Por cohorte (empleo / ln ingreso): 2015 plana ~−2 pp, baja ~−0,7 desde 2021 / cae continuo −0,05 → −0,15 desde 2014 (tendencia propia). 2016 sube ~+4 pp desde 2018 / sube ~+0,15. 2017 plana. 2018 leve alza pre, sube ~+3 pp desde 2020. 2019 joroba transitoria 2020–21 / sube ~+0,1.
- 2016 y 2018: +3–4 pp en empleo con ~2 años de rezago (gradual, plausible). 2016 = mayor primera etapa (pero problema de fechas; 57 UVs).
- Alerta: cohorte 2015 con tendencia divergente en ingreso, sin pre para verificar → otra razón para estimar sin 2015.
- Dinámicas heterogéneas → SA referencia. Esperado: efectos chicos y graduales (k 2–4), promedio diluido por 2015.

### Paso 2: event study (coefs_lab.csv)
Gráficos: `graficos/lab_02a_eventstudy_empleo.png`, `lab_02b_eventstudy_ingreso.png`, `lab_02c_eventstudy_meses.png`. Ponderado (por madres) = más preciso.

Empleo formal (SA_w, pp): k −5…−2 = +0,4 / −0,9 / −0,6 / −0,3; k 0…9 = −0,1 / +0,1 / +0,3 / +0,6 / +1,0* / +1,2* / +1,0* / +1,5* / +1,0 / +0,7. Sin ponderar: misma forma, más ruido. Pretest TWFE p = 0,20.
- Primer resultado laboral con forma de efecto: nada en k 0–1, sube gradual a +1/+1,5 pp desde k = 4 (~+2% relativo sobre 53%). Consistente con rezago y con cohortes 2016/2018.
- Cuidado: pre ya suben (−0,9 → 0 de k −4 a −1, ~+0,3 pp/año). Si continúa, explicaría ~+1,5 pp en k = 5. Matiz: pre = cohortes tardías (ruidosas), post lejanos = cohortes 2015–2018 → no son las mismas UVs.
ln ingreso: sin ponderar +3–5% k 0–5 (no sig.); ponderado +1–3%, sig. en k 5–6 (~+3%). Pre limpios (p = 0,57). Entre ocupadas → posible subestimación por composición.
Meses: sin ponderar +0,13/+0,16 en k 0–1 (t ≈ 2), luego se diluye; ponderado ~+0,04 (no sig.). Sin efecto relevante. Pre limpios (p = 0,70).
- TWFE ≈ SA en los 3. Patrón gradual, sin salto en la apertura.
- Paso 3: promedios con IC + evaluar tendencia previa de empleo (Rambachan-Roth / Bilinski-Hatfield, JEL §5.1.2).

### Paso 3: promedios post y pre-tendencias (en curso)
Empleo formal:
| Modelo | Promedio | SE | p |
|---|---|---|---|
| SA k0–6 | 0,62 pp | 0,51 | 0,23 |
| SA k0–9 | 0,63 pp | 0,56 | 0,26 |
| SA k4–7 | 1,13 pp | 0,65 | 0,08 |
| SA_w k0–6 (prom. CSV) | 0,59 pp | 0,28 (lincom RIS) | ≈ 0,04 si el promedio es 0,59 |

- Pre-tendencias: no significativas (|t| ≤ 1,6; conjunto SA p = 0,26; SA_w p = 0,82 en RIS), pero crecientes y de tamaño comparable al efecto → no se descarta que sea continuación de tendencia previa.
- Pre (k −4…−2) = solo cohortes tardías (k = −4: cohortes 2018–2024, 120 UVs; pesan 2018 y 2019). Post lejanos (k 4–7) = sobre todo 2015–2017. Cohorte 2015 no aporta a ningún pre.
- k4–7 elegido después de ver el gráfico → reportar solo como complemento, con justificación del rezago (niño debe llegar a edad de jardín).
- Pendiente: confirmar promedio SA_w en RIS con `lincom` directo (debe coincidir con promedio de d6–d12 de la tabla) → define si empleo es significativo.
- Pendiente: event study balanceado (mismas cohortes en toda la ventana, ej. k −3…+5 = cohortes 2017–2019, ~150 UVs; JEL §5.2.4 ec. 32).

ln ingreso:
| Modelo | Promedio k0–6 | % | Significancia |
|---|---|---|---|
| SA | 0,039 (SE 0,025) | +4,0% | p = 0,12, IC [−1% ; +9%] |
| SA k0–9 | 0,029 (SE 0,029) | +3,0% | p = 0,32 |
| SA_w | 0,023 | +2,3% | t entre 1,5 y 4,0 (sin V) |

- Solo madres con ingreso > 0 (`ln_ingreso` missing si no hay ingreso; peso `n_con_ingreso`).
- En pesos (aprox.): ingreso promedio control ~$6,3 MM/año (2019) → +2–4% ≈ $130–250 mil/año (~$10–20 mil/mes).
- Composición (inferencia, no observado): si empleo sube ~1 pp, ~2% de las madres con ingreso post son entrantes. Si ganan ~la mitad, bajan el promedio ~1,4% → el efecto en las que ya trabajaban puede ser mayor (~+3–5%).
- Verificación directa posible: estimar ln ingreso solo en madres que ya trabajaban antes (panel nivel mujer).
- Efecto total sin composición: `arreglos_20261006/07_ingreso_total.do` → ingreso con 0 para las sin ingreso, como % del promedio del año (`ingreso_rel`); evita logs con ceros (Chen y Roth 2024).

## 4. Variables RSH (coefs_horas.csv, 06_horas.do)
Outcomes de la ficha RSH a nivel UV-año (madres):
- `horas`: horas trabajadas declaradas (solo quienes reportan; > 80 a missing). Media control 36,5.
- `busca`: % que busca trabajo. Media 18,6%.
- `cuida`: % que no busca trabajo porque "no tiene con quién dejar a los niños" (motivo 2; sobre todas las madres). Media 11,8%.
- `hogar`: % que no busca por "quehaceres del hogar" (motivo 1). Media 12,0%.
- `cuida_hogar`: cuida o hogar. Media 23,7%.

| Outcome | SA prom k0–6 | SE | p | Pretest SA p | SA_w prom k0–6 (sin SE) |
|---|---|---|---|---|---|
| horas | −0,29 h | 0,22 | 0,18 | 0,18 | +0,08 h |
| busca | +0,79 pp | 0,56 | 0,16 | 0,54 | +0,58 pp |
| **cuida** | **−0,67 pp** | **0,31** | **0,03** | **0,87** | −0,42 pp |
| hogar | +2,03 pp | 0,54 | 0,00 | **0,00** | +1,11 pp |
| cuida_hogar | +1,36 pp | 0,54 | 0,01 | **0,00** | +0,68 pp |

- **cuida = resultado más interesante**: baja ~0,7 pp el % de madres que no busca trabajo por no tener con quién dejar a los niños (−6% relativo sobre 11,8%). Significativo (p = 0,03), pre-tendencias limpias (p = 0,87), aparece desde k = 1 (k 1–3 ≈ −0,8 a −1,0 pp, t ≈ −2 a −2,6). Es la medida más directa del mecanismo (restricción de cuidado). Ponderado: misma dirección (−0,4 pp), más débil.
- busca: +0,8 pp (no sig.), signo consistente con más vinculación laboral.
- horas: sin efecto (−0,3 h sin ponderar, +0,1 h ponderado).
- hogar y cuida_hogar: **no interpretables**. Pre k −5…−2 ≈ +3 / +2,6 / +2,7 / +1,1 pp (significativos) y post ≈ +2 a +2,5 → forma de V con mínimo en k = −1/0. El "efecto" viene de un año base anómalo, no de un cambio post. Respecto de k −5…−2, el post no cambia.
- Hipótesis para la V (por verificar): la ficha RSH no se actualiza todos los años; las familias la actualizan al postular a beneficios (p. ej. al jardín) → el momento de la medición depende del tratamiento. Afecta a todas las variables RSH, incluida cuida.
- TWFE ≈ SA (pretest TWFE: horas 0,40; busca 0,72; cuida 0,76; hogar 0,00; cuida_hogar 0,00).

## Pendiente de revisar en esta extracción
- Control limpio para fertilidad y laboral (`coefs_ctrl.csv` también trae tuvo_hijo, empleo_formal, ln_ingreso, meses).
- Heterogeneidad laboral por edad del hijo menor (`coefs_het_lab.csv`).

## Próximos pasos (consolidado)
1. Confirmar promedios SA_w con `lincom` directo en el RIS (empleo y ln ingreso).
2. Correr `07_ingreso_total.do` (efecto total en ingreso, sin composición).
3. Cohorte 2015: verificar si los jardines "nuevos" 2015 tienen matrícula en 2014; extraer corrida sin 2015 con V. Do-files listos para fertilidad y laboral (`01_fertilidad_sin2015.do`, `02_laboral_sin2015.do`).
4. Event study balanceado (empleo).
5. Redefinir edad con corte de matrícula (31/03 o `edad_30_06`).
6. Corregir errores 1–7 de arriba (guardar V ponderadas).
7. Verificar timing de actualización de la ficha RSH respecto de la apertura.
