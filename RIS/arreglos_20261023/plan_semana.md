# Plan semana 26–29/10/2026

RIS lunes 26 y martes 27 (quizás miércoles 28). Extracción martes en la tarde. Reunión jueves 29.
Todo se corre de nuevo con la **base de cobertura nueva (319 tratadas)**.

## Lunes 26 (de día: cosas cortas, antes de que el PC quede tomado)

1. **Extracción 21/10**: borrar la tabla pegada dentro del do-file y volver a pedirla (esos resultados son con la base antigua, pero sirven para comparar antigua vs nueva).
2. **Renombrar bases** en `cobertura/`:
   - `base_cobertura_cp` → `base_cobertura_cp_antigua`
   - `base_cobertura_cp_nueva` → `base_cobertura_cp`
   - Chequeo: `use g1 tratada using ".../cobertura/base_cobertura_cp", clear` → `tab g1 if tratada == 1` → en 2015 tiene que dar **51** (la antigua da 179).
3. **Correr el 17** a mano (minutos). El `gunique` final da **~259** (esperado: `tratada`=1 solo en el año de apertura y se bota 2015). ✅ Hecho: 259. Después **copiar** el archivo de `shapes_uv/` a `cobertura/` (el 09 lo lee desde ahí).
4. **Correr el 18 (mudanzas)** dos veces, ANTES del maestro:
   - `a=2021 b=2022` y después `a=2020 b=2021` (comparación).
   - Anotar a mano: `sum mueve`, la tabla `pct_cat`, y la mediana de `top_max`.
   - Si en 2021→2022 hay muchas UVs con pct 0.9–1 y mediana de top_max ≈ 1 → es error del crosswalk (claves shapes vs carto), no mudanzas reales.
5. **Chequeos baratos pendientes** (para las diapos):
   - `use rut_inn v60 using "$muestra/muestra_completa_ruts_trat_v60", clear` → `gduplicates drop rut_inn, force` → `tab v60, m`
   - `use rut_inn using "$muestra/muestra_laboral_ingresos_v60", clear` → `gunique rut_inn`
6. **Fin del día: lanzar `00_maestro_finde.do`** (reemplazar `RUTA` por la carpeta de los do-files). Orden: 09 → 11 → 03 → 14 → 02 → 01 → 08a → 08b.

## Martes 27

1. Revisar el log del maestro: qué terminó y qué no. Los 08a/08b (EF mujer) son lo más lento: puede que sigan corriendo.
2. Si el PC está libre: correr `15_sin_bin.do` (pre sin agrupar, k −10..−1) con la base nueva.
3. Si alcanza: `16_balance_mediana.do`.
4. **Fin del día: pedir extracción** (lista en `extraccion_20261027.md`). Si los 08 no terminaron → extracción miércoles en la mañana (como la semana pasada).

## Miércoles 28 / Jueves 29

- Llegan resultados → revisar acá: primera etapa con la base nueva primero, después el resto; comparar con la base antigua.
- HonestDiD acá (fuera del RIS) con los b y V extraídos.

## Queda para después (no esta semana salvo que sobre tiempo)

- `03b` primera etapa 40% no vulnerable (necesita rehacer `merge_muestra_final` → noche entera).
- Tendencias paralelas condicionales (covariables UV 2014 × año) — falta escribir el do-file.
- Vecinos (adyacencia de UVs, se arma fuera del RIS → pedir incorporación).
- Si el 18 confirma error del crosswalk: arreglo con `descubrir_claves_uv.do` (votación hacia atrás desde 2022) → otra noche de muestras.

## Estado fin lunes 26/10
- Hecho: base nueva confirmada (g1 2015 = 51), crosswalk rehecho (match directo solo 2022–2024, votación 2021→2016), maestro lanzado (copy → 09 → 11 → 03 → 14 → 02 → 01 → 08a → 08b).
- Crosswalk: 2016–2020 ~79% limpio / 17% ambiguo / 3% división; 2021 74% / 12% / 13% (cambio de mapa en 2022; pedazo chico de las divisiones queda mal asignado solo en 2021 → limitación).
- **Martes, primero:** (1) log: 09 y 11 terminaron sin error / fecha de las muestras; (2) 18 de nuevo 2021→2022 (mueve debería bajar de 23,6%); (3) chequeos baratos (tab v60, gunique rut_inn); (4) si los 08 siguen corriendo → extracción miércoles AM.

## Estado martes 27/10 (tarde)
- 18 con crosswalk nuevo: 2021→2022 mueve 20% (antes 23,6%), UVs con 90–100% que se mueve: 7 (antes 122) → error de UVs completas arreglado. Pero 2020→2021 da 24% (top_max p50 0,18): todos los años ~20–24%, demasiado → probable ruido del crosswalk por votación. PENDIENTE: revisar si los que se mueven van a UV vecina/misma comuna.
- Noche: Stata 1: 08a (CAMBIOS 1–4) → 08b (CAMBIOS 1–2). Stata 2: 02 (CAMBIOS 1–7) → 21. Extracción miércoles 8 am.

## Miércoles 28/10 – 8 am
1. Revisar que 08a y 08b terminaron: los 10 csv en la carpeta de extracción con fecha de anoche (si falta alguno, exportarlo a mano).
2. Recortar log_indm_empleo (2 tablas) y log_lab_v60fija (2 tablas).
3. Pasar los 16 .dta a csv; verificar dimensiones con describe, short.
4. Mandar extracción (texto final en el chat 27/10; listado en mail_extraccion_20261028.md) + 5 tablas del compañero → 43 elementos.
5. Si hay tiempo en el RIS: correr 21 (laboral todas) y 20 (fert vecinos) → próxima extracción.
- 28/10: log_indm_empleo fuera de la extracción (CAMBIO 6 no se tipeó, el log queda solo en $est). Total 40 elementos con las tablas del compañero.

## Miércoles 28/10 – RIS
- Extracción 20261028 enviada, esperando respuesta.
- Lanzado: 21 (laboral todas, CAMBIO 2 = `sum ingreso_total if anio == 2024` → m24 para pasar ingreso_rel a pesos: coef × m24/1200). 20 y 15 NO se corrieron.

## Panel desde 2011 (pedido Andrés 22/10) — revisado 28/10, para semana 2/11
- Disponibilidad: nacimientos sin límite; FPS desde 2007 (UV mala → asignar UV 2016, igual que 2014–15); matrícula parvularia desde 2011; rentas históricas 2002–2015 + semestrales (años nuevos); cotizaciones desde 2015 (2014 por rezago); cobertura no se necesita antes de 2014 (tratamiento = 0 jardines en 2014).
- Propuesta: todo parte en 2011. Laboral 2011–2013 solo con rentas (sin independientes ni cotizaciones) → robustez: outcome solo-rentas en todos los años.
- Costo: rehacer panel base (FPS 2011–13 → hijos desde 2006 → 09) = varias noches.
