# Mudanzas de UV — resumen preliminar (13/10/2026)

Pregunta de los profesores: ¿las mujeres se cambian de UV? ¿Cuántas?

Fuente: `08_vulnerables_mudanzas.do`, paso 2, sobre `muestra_laboral_ingresos` completa (todas las UVs, ~2 millones de mujeres). Números leídos en pantalla; se completan el miércoles con las salidas exactas.

## Dos medidas

| | `cambia_uv` (ya en la base) | `cambia` (nueva, paso 2) |
|---|---|---|
| Código de UV | `uv_rsh`: código del RSH de cada año (puede cambiar por re-cartografía) | `id_uv_2024`: mapa fijo de 2024, el mismo que define el tratamiento |
| Años que mira | Todo el panel RSH 2016–2024 de la mujer, aunque no tenga hijos pequeños | Solo los años en que la mujer está en la muestra (hijo menor de 5) |
| Desde cuándo | 2016 | 2017 (la UV de 2014–2015 es la de 2016, así que 2015→2016 no se puede comparar) |

## Resultados

- **`cambia_uv`: 49% de las mujeres cambia de UV**, sin faltantes.
- **`cambia`: 25% cambia, 53% no cambia y 20% faltante.**
  - El faltante no es falta de datos: son mujeres sin dos años comparables (observadas un solo año, o solo en 2014–2016).
  - Sobre las mujeres comparables: **~32% cambia de UV al menos una vez** durante su permanencia en la muestra.
  - Las mujeres están ~5 años en la muestra (~4 transiciones comparables), así que equivale a **~9% por año**.
- **Mudanzas por año (`tab anio mueve`):** entre 7% y 12% todos los años, **salvo 2022 con 26%**.

## Interpretación

- Una tasa anual de 7–12% es plausible: las UVs son chicas (cambiarse a pocas cuadras ya cuenta) y es una población muy móvil (madres jóvenes, de ingresos bajos, muchas arrendatarias o allegadas).
- **2022 es probablemente un artefacto de cartografía**, no mudanzas reales. 2022 es el primer año "bueno" de las cartografías de UV, así que el cambio de código ese año y su paso al mapa 2024 pueden asignar a mujeres a otra UV sin que se hayan mudado. Es difícil de corregir.
- La diferencia entre 49% y 32% viene de re-cartografía en `uv_rsh` y de mudanzas fuera de los años de la muestra.
- Reportar `cambia` como la medida principal y `cambia_uv` como cota superior.

## Por qué importa para el estudio

- Con ~9% de mudanzas al año, una parte de las madres de UVs tratadas llega después de la apertura y otra se va. Eso **diluye el efecto estimado a nivel UV** y es un argumento a favor de la estimación individual.
- Si las mujeres se mudan **más hacia UVs tratadas** después de la apertura, cambia la composición de las tratadas (revisar `tab grupo_t1 mueve, row`).
- Si 2022 es re-cartografía, algunas mujeres quedan asignadas a otra UV desde 2022 sin haberse mudado, y su tratamiento puede estar mal asignado en los años finales.

## Pendiente para el miércoles (salidas exactas)

- [ ] `tab cambia_uv if tag_m, m`
- [ ] `tab cambia if tag_m, m`
- [ ] `tab cambia_uv cambia if tag_m, m` (cuántas son cambio de código sin mudanza)
- [ ] `tab anio mueve, row` (con 2020 y 2021, para descartar el rezago por pandemia)
- [ ] `tab grupo_t1 mueve, row` (¿más mudanzas en UVs tratadas?)
- [ ] Opcional: `cambia` sin las transiciones de 2022 (`cambia_s22`), para una cifra sin el artefacto
- [ ] Opcional: `tab cambia if tag_m, m` dentro de `muestra_t1` (la muestra de estimación)
