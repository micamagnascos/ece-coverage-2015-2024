# Plan RIS semana 19–20/10/2026

Extracción: **martes 20/10 al terminar la jornada** → resultados miércoles en la tarde → reunión jueves 22/10.
Lista para el mail: [extraccion_20261020.md](extraccion_20261020.md).

Prioridades: (1) todo con la muestra nueva, primero primera etapa; (2) EF de mujer (empleo y fertilidad); (3) exposición; (4) panel balanceado. Robustez si alcanza: 40% no vulnerable y mudanzas 2022.

## Lunes 19/10, primeros 15 min: chequeos (en la ventana de comandos)

Primero `do ".../estimaciones/00_setup.do"` (para tener `$pe` y `$muestra`).

1. **¿Terminaron las muestras del fin de semana?** Abrir los logs del 09, el 10 y el 11 y mirar el final (que no termine en error).
2. **¿Existen las bases nuevas?** Fijarse en "Last saved" (fecha del fin de semana) y en el n° de observaciones:
   ```stata
   describe using "$muestra/muestra_laboral_ingresos_v60.dta", short
   describe using "$muestra/muestra_fertilidad_v60_uvs.dta", short
   describe using "$pe/primera_etapa_panel_v60_uv.dta", short
   ```
3. **¿Sobrevivió el panel de niños COMPLETO?** (error 3 de la semana pasada)
   ```stata
   describe v60 using "$pe/primera_etapa_panel.dta"
   ```
   - Si da **error "variable v60 not found"** → está bien, es el original. El 03b se puede correr.
   - Si **muestra v60** → se sobrescribió. **No correr el 03b** (el 40% queda para otra semana).

**Si una base no existe (plan B):** se relanza en el Stata 2 en la tarde (el 09 primero si falló, porque el 10 y el 11 dependen de él). Lo que dependía de esa base se corre el martes.

## ⚠️ ACTUALIZACIÓN lunes 19/10: plan nuevo (reemplaza la tabla de abajo)

El fin de semana falló por las rutas (`cd`). El lunes se usó entero para re-correr `rsh_uv_panel_2014_2024.do` (arreglo de `puntaje`). `merge_muestra_final.do` **no** se corre esta semana: `puntaje` solo cambia v60, y la muestra completa queda igual.

Los do-files de estimación **se piden por incorporación** el lunes (no se tipean): 01, 02, 03, 03b, 08a, 08b, 14, mudanzas_2022 y los dos maestros del martes. Con Stata corriendo, el computador queda demasiado lento para tipear.

| Cuándo | Stata 1 | Stata 2 |
|---|---|---|
| Lun, antes de irse | `00_maestro_noche.do`: 09 → 11 | — |
| Mar mañana | `00_maestro_martes_stata1.do`: 08a → 08b | `00_maestro_martes_stata2.do`: 03 → 14 → 01 → 02 → 03b → mudanzas |
| Mar tarde | Lo que haya terminado del 08 | **Pedir la extracción** |

**Martes noche (cambio 20/10):** `00_maestro_martes_stata1.do` = 08a (empleo, ingreso con ceros, ln ingreso) → 08b (fertilidad) corre de noche. **Extracción miércoles 21/10 temprano.** Si al llegar algo se cayó a la mitad: escribir `postclose pf` en la ventana de comandos antes de extraer (cierra el archivo de coeficientes con lo que alcanzó a guardar).

## Orden de trabajo (plan original)

| Cuándo | Stata 1 (rápido, nivel UV) | Stata 2 (pesado) |
|---|---|---|
| Lun mañana | `03_primera_etapa_v60.do` | `08a_ef_mujer_empleo.do` con `pct = 0.05` (prueba) |
| Lun mañana | `14_exposicion_pe.do` | `08b_ef_mujer_fert.do` con `pct = 0.05` (prueba) |
| Lun tarde | `02_laboral_v60.do` | (plan B: relanzar la muestra que falló) |
| Lun tarde | `01_fertilidad_v60.do` | |
| **Lun noche** | — | `08a` con `pct = 1` y después `08b` con `pct = 1` |
| Mar mañana | `03b_primera_etapa_nov60.do` (si el chequeo 3 lo permite) | Revisar logs del 08a y 08b |
| Mar | `mudanzas_2022.do` (opcional) | Si un 08 falló: relanzar solo ese |
| Mar tarde | **Copiar los do-files tipeados y pedir la extracción** | |

**Sobre la prueba del 5%:** sirve para ver que corre sin errores y cuánto se demora (`timer list 1`, en segundos). La corrida completa toma más o menos 20 veces eso. Si el 08b completo da más de ~12 horas, dejarlo con `pct = 0.25` y lo anotamos.

## Qué mirar en pantalla en cada do-file

- **Todos:** la tabla de `tab rel_t1_bin, gen(d)` → 15 filas y la fila 5 = −1. Si no, **parar**: los dummies quedan corridos.
- **`lincom` no funciona después de `eventstudyinteract`** (confirmado 20/10): se sacó de todos los do-files. El promedio post y su EE se calculan acá con la V guardada (`guardarV`).
- **03:** el panel balanceado (C) solo puede tener k de −2 a 4.
- **14 exposición:** `tab n_anios` (la mayoría en 5) y `tab expo` (que los 3 grupos tengan niños). Se espera que el coeficiente baje de 1 a 3: más efecto si el niño era más chico.
- **02:** `tab anio` debería crecer año a año (las madres se acumulan en la muestra fija).
- **08a / 08b:** `gunique uv_fija` con `pct = 1` ~4.500 (la semana pasada salieron 1.634). Si sigue dando muy poco, anotar el `tab muestra_f pre_f, m`.

## Qué cambia respecto de la semana pasada

- **Muestra:** v60 fija por mujer (FPS 2014–15 y RSH desde 2016). Laboral = la madre entra el primer año con hijo < 5 y se queda hasta 2024.
- **Solo SA ponderado.** TWFE y SA sin ponderar no se usan en la presentación.
- **Los gráficos se hacen acá** desde los `.dta`, así que en el RIS no hay que tipear código de gráficos.
- **EF de mujer:** la UV fija es la primera UV *válida*, para arreglar los clusters que se perdían.
- **Quedan reemplazados:** 08 (EF de mujer antiguo), 12, 13 y 03_sin2015 (el "sin 2015" ahora va dentro de cada do-file).
- **Queda para después:** el 07 (ingreso con ceros, muestra completa), la heterogeneidad por edad ponderada, el tratamiento por stock inicial y la probabilidad de embarazo.

## Pendiente para después de la extracción: tendencias pre

Preocupación (20/10): los pre no son significativos, pero pueden tener tendencia (ej: ingreso con ceros 14/10 subía −2,0 → −0,9 → 0). Un pretest no significativo no prueba que no haya tendencia (Roth 2022, poco poder).

1. **Revisar el 15 (sin agrupar los años pre)**: ¿hay tendencia sistemática hacia k = −1? Es un diagnóstico, no la solución. Los k lejanos son ruidosos (k = −10 = solo la cohorte 2024).
2. **HonestDiD (Rambachan y Roth 2023), acá fuera del RIS** con los `b`/`coefs` y las `V` extraídas: intervalos robustos si la tendencia pre continúa. Hacerlo para empleo, ingreso con ceros, primera etapa y fertilidad.
3. **Panel balanceado**: ya está en primera etapa (03, bloque C). Ver si conviene agregarlo en laboral.
4. **Tendencias paralelas condicionales** (próxima semana, en el RIS): covariables de la UV en 2014 (población, n° de mujeres, densidad de niños) × año. Las tratadas son más grandes (tabla de balance).
5. **No usar tendencias lineales por cohorte**: pueden absorber el efecto (Baker et al.).
