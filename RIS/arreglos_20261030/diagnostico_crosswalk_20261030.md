# Diagnóstico y arreglo del crosswalk de UV (30/10/2026)

Do-files: `22_diagnostico_uv.do` (diagnóstico) y `crosswalk_cobertura_uvs.do` (arreglo), ambos en `RIS/arreglos_20261030/`.
Respaldo del crosswalk anterior: `cobertura/cobertura_crosswalk_final_antiguo.dta`.

## Resumen en una línea
La votación hacia atrás sacaba del diccionario del año siguiente los códigos ambiguo y division (línea 68). Por eso un mismo código RSH recibía UV 2024 distintas en años distintos, y las mujeres "se mudaban" sin moverse (~15 pp de mudanzas falsas al año en 2016–2021). Arreglado: ahora todos los códigos entran al diccionario.

## Síntomas de antes (semana del 26/10)
- En las bases de estimación, las UV con datos saltaban de ~3.300 a ~4.150 entre 2020 y 2021; las tratadas, de 249 a 305. Las personas crecían solo ~2%.
- Solo 241 de las 319 tratadas tenían datos en 2014.
- La primera etapa en k = −2 pasó de −0,2 pp (06/10) a +0,9 pp (28/10).
- 18_mudanzas: se mudaba un 24% entre 2020 y 2021, y un 20% entre 2021 y 2022 (era 23,6% con el crosswalk previo al del 26/10).

## Paso 1: mudanzas y UV por año (base de fertilidad v60, 18–49)
**1a. `tab anio mueve24, row`**, % que cambia de UV 2024 respecto a su observación anterior:

| 2017 | 2018 | 2019 | 2020 | 2021 | 2022 | 2023 | 2024 |
|---|---|---|---|---|---|---|---|
| 26% | 19% | 19% | 21% | 26% | 23% | **5%** | **5%** |

Es alto en todos los años en que interviene un código votado (≤ 2021) y baja a 5% cuando los dos años son de cruce directo (2022–2024). `mueve24` parte en 2017 porque 2014–2015 toman la UV de 2016.

**1b. UV con al menos una mujer por año:** ~5.250 entre 2014 y 2020, y ~5.550 en 2021 (+6%). Las mujeres crecen parejo: ~2,9 millones en 2021 y ~3,0 millones desde 2022, cada año ~9% del total. ⇒ En 2021 la misma gente se reparte en más UV.

## Paso 2: ¿las mudanzas son reales?
**2a. Muestra de estimación (`muestra_t1 == 1`):** mismo patrón que la base completa, en mudanzas y en número de UV (mueve24 ~20% en 2021).

**2b. `tab anio mismo_cod if mueve24 == 1, row`**, entre las que "se mudan", % con **el mismo código RSH** que su observación anterior:

| 2017–2021 | 2022 | 2023 | 2024 |
|---|---|---|---|
| 50–75% | 4% | 0,2% | 1% |

En 2017–2021, la mitad o más de las "mudanzas" son mujeres que siguen con el mismo código RSH: el crosswalk les cambió la UV 2024 sin que se movieran. (En 2023–2024 sale ≈ 0 por construcción: con cruce directo, mismo código ⇒ misma UV 2024.)

**2c. `tab anio mismo_cod, row`** (todas las mujeres): 2015–2016 = 100% (por construcción); **2017–2024 > 90%**, salvo **2022 = 70%** (cambio parcial de cartografía entre 2021 y 2022). ⇒ Los códigos RSH de las personas son estables entre años. Lo que no conversa son los códigos RSH ≤ 2021 con los shapes (encabezado del crosswalk, línea 4), y por eso se vota.

Ejemplo de una mujer (`list`): el mismo código RSH entre 2014 y 2017 (termina en …235) y desde 2018 otro (termina en …222). Un solo cambio, que puede ser mudanza o recodificación.

## Paso 3: el crosswalk mismo (`crosswalk_uv_final_2_puntocero.dta`, ANTES del arreglo)
En los division se deja la UV ganadora; una fila por código y año.

**`tab anio tipo`** (códigos):

| Año | limpio | ambiguo | division |
|---|---|---|---|
| 2016–2020 | 5.400–5.500 | 1.100–1.400 | ~100 (más en 2018) |
| 2021 | 5.500 | 900 | 540 |
| 2022–2024 | todos "verdad" | | |

**`tab anio cambia, row`**, % de códigos que reciben **otra** UV 2024 el año siguiente (la fila t compara t con t+1):

| 2016 | … | 2020 | 2021 (vs 2022 verdad) | 2022 | 2023 | Total |
|---|---|---|---|---|---|---|
| 10% | sube | 19% | 4% | 0% | 0,06% | 10% |

**`tab tipo cambia if anio <= 2021, row`** (tipo del código ese año):

| limpio | division | ambiguo |
|---|---|---|
| 1% | 54% | 70% |

**`tab tipo_sig cambia if anio <= 2021, row`** (tipo del mismo código el año siguiente):

| limpio | verdad | ambiguo | division |
|---|---|---|---|
| 0,2% | 4,5% | 75% | **88%** |

**Diagnóstico:** si el año siguiente el código fue ambiguo o division, salta en 75–88% de los casos. Un division tiene una UV ganadora clara; si su gente hubiera podido votar, el código habría quedado estable. Salta porque la línea 68 (`keep if inlist(tipo,"verdad","limpio")`) los sacaba del diccionario: su gente no votaba y el código lo decidían las pocas mujeres que habían cambiado de código. Además, los ambiguos sí se usaban en el crosswalk final, con la UV más votada aunque fuera por minoría.

## Arreglo (`crosswalk_cobertura_uvs.do`)
- **CAMBIO 1 (líneas 68–69):** se comenta `keep if inlist(tipo,"verdad","limpio")`. Todos los códigos del año siguiente entran al diccionario.
- **CAMBIO 2 (líneas 71–73):** `gsort codigo_uv -share` + `by codigo_uv: keep if _n == 1`. En los division (2 filas) queda la UV ganadora, con la misma regla que el crosswalk final.

Efecto: un código estable hereda la traducción del año siguiente, y así hasta la votación de 2021 contra 2022 (la confiable, solo 4% de cambios).

## Resultados del crosswalk arreglado (log del crosswalk, 30/10)
**`tab anio tipo`** (filas; cada division tiene 2):

| Año | limpio | ambiguo | division |
|---|---|---|---|
| 2016–2019 | ~6.800 | 10–40 entre ambos | |
| 2020 | 6.700 | 196 | 16 |
| 2021 | 5.500 | 900 | 1.000 filas (~500 códigos) |

- 2016–2019: los ambiguos y division bajan de ~1.200–1.500 a 10–40.
- 2021 queda igual que antes (es lo esperado: vota contra 2022, que ya era todo "verdad").
- Usables: ~6.800 por año (~6.700 en 2020 y 2021). Filas por año en el crosswalk final: ~6.800 (~6.900 en 2020 y 2021).

**Tratadas** (`gunique id_uv_2024 if tratada == 1`):
- Todo el crosswalk: 336.
- Con `muestra_t1 == 1`: **nuevo 268 / viejo 259**. El máximo es 268 = 319 − 51 de la cohorte 2015, porque el crosswalk parte en 2016 y `tratada == 1` está solo en la fila del año de apertura. ⇒ El crosswalk nuevo llega a todas las tratadas; el viejo perdía 9.

## Limitación que queda: 2021
~20% de los códigos de 2021 (~900 ambiguos + ~500 division) cubren un área que en 2024 son dos o más UV. Esto es división real entre 2021 y 2022, y ningún crosswalk por código lo resuelve. A toda la gente del código se le asigna la UV más votada; las mujeres de la parte "perdedora" quedan en la UV vecina entre 2016 y 2021, y su tratamiento puede estar mal asignado esos años. Que desde 2022 queden bien depende del puente carto–shapes, que aún no está comprobado (ver sección final).
- Para la tesis: documentarlo y hacer una robustez sin las mujeres de esos códigos de 2021.
- Después de la tesis: asignar con información de cada mujer (su UV en 2022) en vez de por código.

## Pendientes
- [x] Correr de nuevo el paso 3 del 22 con el crosswalk nuevo (hecho 02/11, ver abajo).
- [x] Después del 09: correr de nuevo el paso 1 del 22 (hecho 02/11, ver abajo).
- [x] Volver a estimar todo con el crosswalk nuevo (extracción 04/11, ver "Revisión con la extracción 04/11").
- [ ] Robustez sin las mujeres de códigos 2021 ambiguo/division.

## Verificación en personas con el crosswalk nuevo (02/11, después del 09)
| Tab | Crosswalk viejo | Crosswalk nuevo |
|---|---|---|
| `tab anio mueve24, row` | 19–26% en 2017–2022; 5% en 2023–24 | **4–9% todos los años, salvo 2022 = 23%** |
| `tab anio if tag_uv == 1` | ~5.250 en 2014–2020, ~5.550 en 2021 | **~6.450 a ~6.810, sube de a poco, sin salto** (cada año 8,9–9,4% de 72.457 UV-año) |
| `tab anio mismo_cod if mueve24 == 1, row` | 50–75% en 2017–2021 | **0–1%; 2022 = 4%** |
| `tab anio cambia, row` | 10–19% en 2016–2020 | **≈ 0; 2021 = 4%** |

⇒ Se fueron las mudanzas falsas de cada año y el salto de UV de 2021. Queda un salto de una sola vez en 2022 (23% vs ~5–9%): sería el cambio de cartografía entre 2021 y 2022, en que a toda la gente de un código 2021 se le asigna una sola UV y en 2022 pasa a su UV por cruce directo. Sugiere que ~15–18% de las mujeres podría tener en 2016–2021 una UV distinta de la que le corresponde. Esa cifra es una estimación a partir del tab, no una medición directa.

Muestra laboral nueva (log del 09): 1,6 millones de mujeres (todas las UV), 57% presente los 11 años. Muestra del 21: 23% de 11 millones de mujeres-año con hijo menor de 5.

## Pendiente para retomar: el salto de 2022 (conversado 02/11, NO resuelto)

### Cómo se llega de la mujer a la UV 2024
```
2022–2024:  Mujer → [1. carto] → código del año → [2. shapes: polígono con mayor área] → UV 2024
2016–2021:  Mujer → [1. carto] → código del año → [votación: dónde vive su gente el año siguiente] → UV 2024
```
- Eslabón 1 (carto): `midesof_rsh_uv_AAAAMM.dta`, persona → `uv_rsh`.
- Eslabón 2 (shapes): `crosswalk_uv.py` → `uvs_madre.dta`; cada polígono del año va a la UV 2024 con mayor área de solape. Une con el carto por `codigo_uv`, y eso solo se usa en 2022–2024.
- Antes de 2022, los códigos de carto y shapes no coinciden, y la votación reemplaza al eslabón 2.
- ⇒ La "mudanza" de 2022 compara dos métodos: UV 2021 por votación contra UV 2022 por shapes.

### Magnitud (aproximada, con ~3 millones de mujeres al año)
| | % | Mujeres |
|---|---|---|
| Año normal (`mueve24`) | 4–9% (~6–7%) | ~200 mil |
| 2022 | 23% | ~690 mil |
| Exceso en 2022 | ~16–17 puntos | ~500 mil |

Falta anotar el % exacto de cada año para calcular el promedio. Que el exceso sea mala asignación es una inferencia, no una medición.

### Qué sabemos de cada parte
| Parte | Evidencia | Veredicto |
|---|---|---|
| Carto (mujer → código) | 30% de las mujeres cambia de código en 2022, contra <10% otros años (paso 2c), sin usar shapes. Códigos en el carto: 6.996 en 2021 → 6.872 en 2022 | Hay un quiebre |
| Votación 2021 → 2022 | Cada código 2021 va a una sola UV; ~20% de los códigos 2021 son ambiguo/division; de las que "se mudan" en 2022, solo 4% mantiene el código | Convierte el quiebre en mudanzas |
| Shapes (código → UV 2024) | El 5% de 2023–24 NO la valida: mismo código ⇒ misma UV por construcción, aunque esté mal. El carto siempre tiene más códigos que las shapes (nota en `intento_2_uvs_solo_malos.do`) | Sin comprobar |

Un cambio de nombre por sí solo no crea mudanzas (si todo A pasa a llamarse B, la votación lo traduce completo). Para que aparezcan, la gente de un código 2021 tiene que repartirse en varios códigos 2022.

### Chequeos propuestos (sin escribir ni correr)
- **A. Solo carto:** para cada código 2021, % de su gente en su código 2022 más común; lo mismo para 2020 → 2021 como comparación. Reparto alto solo en 2022 ⇒ el carto cambió ese año (rediseño o reasignación), limitación de los datos. Reparto bajo ⇒ el problema está en otra parte.
- **B. Puente carto–shapes 2022–2024:** para cada código que une ambas bases, ¿coinciden comuna y nombre? ¿Cuánta gente queda en códigos sin shape? Si no coinciden, 2022–2024 tampoco está limpio. Los nombres no están estandarizados: mirar sobre todo la comuna. Partir por este, porque es el que más puede cambiar lo que creemos.

### ¿Puede perjudicar las estimaciones? Sí; falta saber cuánto
- **Atenuación:** mujeres de UV no tratadas contadas en tratadas, y al revés. Empuja el efecto hacia cero.
- **El error puede no ser aleatorio:** las tratadas son ~2 veces más grandes y pueden haberse dividido más. Si el salto de 2022 es distinto en tratadas y control, los efectos fijos de año no lo absorben. Además, 2022 cae en un k distinto según la cohorte (k = 5 en la cohorte 2017, k = 2 en la 2020), así que puede deformar la dinámica o los pre-trends. La dirección de este sesgo no se conoce.
- **UV fija (08a/08b):** usa la primera UV observada, que suele ser anterior a 2022. No hay salto, pero una mujer mal asignada queda mal todos los años.

### Chequeo prioritario antes de confiar en las estimaciones
Comparar `mueve24` en 2022 entre tratadas y control (`muestra_t1 == 1`). Parecido ⇒ el salto se parece en ambos grupos y los efectos fijos de año absorben buena parte. Distinto ⇒ puede sesgar. Robusteces posibles: excluir a las mujeres de códigos 2021 ambiguo/division; comparar UV fija pre-2022 contra anclada en 2022 (ojo: esta asigna mal a quienes de verdad se mudaron antes).

## Tratadas con datos desde 2014 (03, 02/11)
`tab primer_anio if anio == primer_anio & g1 > 0 & !missing(g1)`: **288 de 319 parten en 2014** (antes 241 con datos en 2014); 2022: 12; 2024: 1; 2018–2021: ~1 por año (conteo aproximado, anotado a mano). Total 319.

## Efecto en las estimaciones (02/11, visto en gráficos del RIS; coeficientes por extraer)
- Primera etapa (03): el k = −2 ya no es significativo (antes +0,9 pp). Su muestra no cambió, así que el cambio viene del crosswalk.
- Empleo (02, muestra nueva): sube desde k = 1; k = −2 no significativo; pre-tendencias se ven mejor. Aquí cambiaron crosswalk y muestra a la vez.
- ln ingreso (02): deja de ser significativo, aunque el punto sube.
- `n_hijos_menor5`: cerca de 0 y no significativo; baja desde k = 5, sin significancia.

## Revisión con la extracción 04/11
- **El arreglo está en la copia del RIS:** `crosswalk_cobertura_uvs.do` tiene comentada la línea `keep if inlist(tipo,...)` y deja la UV ganadora (`gsort`). Respaldo con `copy` al inicio.
- **Tratadas con datos desde 2014 (03):** 299 de 319 en la tabla extraída. El 288 anterior era un conteo a mano, antes de correr de nuevo el 09.
- **Salto en UV de la muestra en 2022:** control +203 UV (de 3.904 a 4.107) y tratadas +12 (306 a 318), contra 0 a 30 en otros años. Madres control +6,0% y tratadas +4,3% ese año. La tabla "sin salto" de arriba es de todas las UV; en la muestra de diseño sí hay salto.
- **Brecha cruda de empleo por año, tratadas − control (pp):** 2019 0,34; 2020 0,87; 2021 1,16; 2022 1,44; 2023 1,62; 2024 1,56. Sube desde 2020, no solo en 2022. El cambio 2021–22 por cohorte no es parejo (de −2,0 a +3,3); en las grandes: 2015 +0,1; 2016 +0,5; 2017 +1,0; 2018 +0,9.
- **Con UV fija, que no tiene el salto de 2022,** el empleo también crece con k (`lab_10`, `lab_11`). Sigue pendiente el `24` (UV fija desde 2022) y la robustez sin códigos 2021 ambiguo/division.
