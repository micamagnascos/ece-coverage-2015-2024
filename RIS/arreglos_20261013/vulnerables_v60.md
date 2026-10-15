# 60% más vulnerable — resumen preliminar (13/10/2026)

Comentario de los profesores: restringir la muestra al 60% más vulnerable, que es la población que puede acceder a jardines públicos (JUNJI/Integra).

Fuente: `08_vulnerables_mudanzas.do`, pasos 3–6. Números leídos en pantalla; se completan con la extracción.

## Cómo se definió

- Variable: `calc_quintil_validacion2` (tramo de calificación socioeconómica del RSH, `TRAMO_CSE`): 40, 50, 60 = mayor vulnerabilidad; 70–100 = menor.
- `v60 = 1` si el tramo es ≤ 60 (tramos 40, 50 y 60). Verificado con el diccionario.
- **Fija por mujer:** primer valor del RSH observado desde 2016, calculado antes de restringir a `muestra_t1`.
- 2014–2015 se ignoran: en esos años la medida es `puntaje` (FPS), que no está en esta base.

## Clasificación (base laboral completa, una fila por mujer)

- 66% en el 60% más vulnerable (~73% entre las clasificadas).
- 10% sin clasificar: **son exactamente las mujeres que solo aparecen en 2014–2015** (su hijo menor cumplió 5 antes de 2016). Quedan fuera de la muestra v60 → menos observaciones en los primeros años previos.

## Primer resultado: empleo formal (SA ponderado)

| k | Muestra completa | 60% más vulnerable |
|---|---|---|
| 4 | +0,97 pp (se 0,44), t = 2,2 | +1,25 pp (se 0,87), t = 1,4 |
| 5 | +1,16 pp (se 0,47), t = 2,5 | +0,54 pp (se 0,78), t = 0,7 |
| Media control | 53% | 43% |

- **Coeficientes del mismo orden** (~+0,9 pp vs ~+1,1 pp); en términos relativos, **~+2% en ambas muestras**.
- **El error estándar casi se duplica** → menos significativo. Es un problema de precisión, no evidencia de un efecto menor.
- Las más vulnerables tienen bastante menos empleo formal de base (43% vs 53%).

## Ingreso (visto en pantalla, falta confirmar modelo y k)

- **`ingreso_rel` (todas las madres, 0 si no trabaja): significativo.**
- **`ln_ingreso` (solo las que trabajan): no significativo.**
- Lectura: el ingreso total sube porque más madres pasan a trabajar formalmente, no porque las que ya trabajaban ganen más. Calza con empleo ↑ y meses/horas sin cambio. `ln_ingreso` además tiene sesgo de composición (las que entran ganan menos).
- Frase para el jueves: "El jardín aumenta el ingreso total de las madres, principalmente porque más madres pasan a trabajar formalmente; no vemos cambios en el ingreso, meses u horas de las que ya trabajaban."

## Posibles razones de la pérdida de precisión

1. Celdas UV-año con menos mujeres → promedios más ruidosos.
2. **Se podrían estar eliminando UVs completas** sin mujeres del 60% (sobre todo UVs más acomodadas), y cambia la ponderación.
3. Se pierde el 10% de mujeres de 2014–2015, que aporta a los años previos.

## Posibles razones si el efecto realmente fuera menor

- **Empleo informal:** las más vulnerables tienen más probabilidad de trabajar en empleos informales, que no aparecen en cotizaciones ni en renta imponible.
- **Primera etapa distinta:** podrían haber tenido ya acceso a jardines públicos o a otras redes de cuidado. No sabemos la primera etapa para hijos de madres del 60%.

## Qué decir el jueves

"Restringiendo al 60% más vulnerable, el efecto en empleo formal es de magnitud similar en términos relativos, pero se pierde precisión y no es significativo. Con estos datos no podemos decir si el efecto es mayor en las más vulnerables."

## Ideas para seguir

- **Ser más flexible con el tramo.** El 60% tiene prioridad en JUNJI/Integra, pero no exclusividad: con cupos, entran mujeres de tramos más altos.
  - (a) Cortes alternativos ≤ 70 y ≤ 80 (robustez, más precisión).
  - (b) **Comparar 60% más vulnerable vs 40% menos vulnerable** (`v60 == 1` vs `v60 == 0`): responde directo si el efecto difiere según vulnerabilidad. Preferida.
- **En el 09** (muestra "alguna vez con hijo menor de 5"): guardar el tramo `vul` en la base, **sin filtrar**, para que cualquier corte después sea un `keep`; e incluir `puntaje` para clasificar a las mujeres de 2014–2015 (con el corte oficial del 60% de la FPS, verificar).

## Pendiente para completar con la extracción

- [ ] `coefs_lab_v60` y las V `V_sa_v60_*`, `V_sa_w_v60_*`, `V_sa_v60s15_*`, `V_sa_w_v60s15_*` → promedio k 4–7 con SE, comparación formal con la muestra completa.
- [ ] Ingreso con ceros (`ingreso_rel`) y ln ingreso en el 60%.
- [ ] Versión sin cohorte 2015 (`sa_w_v60s15`).
- [ ] N de UVs después de `keep if muestra_t1 == 1` vs después de `keep if v60 == 1` (¿se pierden UVs completas? ¿cuántas tratadas sobreviven de las 422?).
- [ ] Verificar que el `tab` de `calc_quintil_validacion2` solo tiene 40–100 (si hay 0 u otros códigos, agregar `& vul >= 40`).
- [ ] Estimación individual (`coefs_lab_ind_v60`).
