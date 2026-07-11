README — Construcción del panel UV-año (cobertura jardines JUNJI/Integra)

## Estrategia general

El objetivo es construir un panel balanceado a nivel de unidad vecinal (UV) x año (6.877 UVs x 10 años, 2015-2024), donde cada fila indica cuántos centros de educación parvularia JUNJI e Integra existían en esa UV ese año.

El proceso tiene tres etapas, cada una en su propio archivo dentro de `code/build/`:

1. Limpieza de bases administrativas (Stata): limpiar y estandarizar los registros de JUNJI e Integra, dejando una fila por establecimiento con su año de apertura, año de "término" y coordenadas.
2. Asignación espacial jardín → UV (Python, GeoPandas): usando las coordenadas de cada jardín y el shapefile de UVs, asignar a cada establecimiento la UV donde está ubicado.
3. Construcción del panel UV-año (Stata): expandir cada jardín a una fila por año de actividad, colapsar a conteos por UV-año, completar el panel con todas las UVs y años (incluyendo ceros), y generar la variable de tratamiento.

Correr todo el pipeline: `do run_all.do` desde la raíz del repo (requiere Stata + Python 3 con geopandas, ver `requirements.txt`).

## Estructura del repo

```
data/raw/     bases crudas (junji.xlsx, integra.xlsx, shapefile de UVs)
data/build/   intermedios de cada etapa
data/final/   base_cobertura_cp.dta — panel final
code/build/   los 3 scripts del pipeline oficial (01, 02, 03)
code/analysis/ chequeos de robustez / análisis (placeholder para el análisis econométrico)
output/       figuras y tablas
docs/         este README, docs/base_de_cobertura.docx, codebook, nota de disponibilidad de datos
legacy/       borradores y archivos huérfanos anteriores, preservados sin usar en el pipeline activo
```

---

## 1. Do-file de limpieza JUNJI/Integra
`code/build/01_limpieza_junji_integra.do`

- **JUNJI**: importa la base de transparencia, colapsa a una fila por establecimiento (sumando matrícula, sin distinguir sala/jornada), define el programa y modalidad "principal" de cada establecimiento (el de mayor matrícula), filtra establecimientos abiertos hasta 2023, descarta los programas/modalidades que implican esfuerzo directo de las madres (`educativo para la familia`, `jardín familiar`), y genera `anio_apertura` y `anio_inicio` (este último con tope mínimo 2015, igual que Integra). Resultado: `data/build/junji_limpia.{dta,csv,xlsx}`.

- **Integra**: primero construye una tabla de concordancia de códigos para corregir el cambio de identificadores causado por la creación de la región de Ñuble en 2018 (57 de 61 establecimientos afectados se logran mapear). Luego, para cada año 2015-2024, importa, limpia y colapsa a una fila por establecimiento. Junta todos los años en un panel largo, corrige los códigos de Ñuble, filtra modalidades de interés (`convenio`, `jardín infantil`, `jardín sobre islas`), y genera `anio_apertura` y `anio_termino` (este último es solo el último año en que el establecimiento aparece en los datos — no es un indicador de cierre confiable). Resultado: `data/build/integra_limpia.{dta,csv,xlsx}`.

- Incluye gráficos exploratorios de aperturas por año, programa y modalidad.

**Outputs reales:** `data/build/junji_limpia.{dta,csv,xlsx}`, `data/build/integra_limpia.{dta,csv,xlsx}`, además de intermedios (`data/build/base_junji_transparencia.dta`, `data/build/cambio_cod_nuble.dta`, `data/build/integra_2015.csv`…`integra_2024.csv`).

---

## 2. Script de Python (GeoPandas)
`code/build/02_spatial_join_uv.py`

**Qué hace:**

- Carga el shapefile de unidades vecinales (`data/raw/unidades-vecinales_2023/mdsf_Unidades_Vecinales_Julio2023.shp`, 6.877 UVs) y los CSV limpios de JUNJI e Integra (`data/build/junji_limpia.csv`, `data/build/integra_limpia.csv`).
- Elimina jardines sin coordenadas válidas (lat/longi en 0 o missing): **353 JUNJI** y **11 Integra** descartados.
- Convierte los jardines restantes a puntos geográficos y reproyecta al CRS del shapefile.
- Hace un **spatial join** (`sjoin`, `predicate='within'`): asigna a cada jardín la UV (`t_id_uv_ca`) dentro de la cual cae su coordenada.
- Verifica que **0 jardines** (de los que sí tenían coordenadas) quedaron sin UV asignada — el join fue exitoso al 100%.
- Exporta los resultados.

**Output:** `data/build/junji_uv.csv`, `data/build/integra_uv.csv` (cada jardín con su `t_id_uv_ca`), `data/build/base_uv_completa.csv` (las 6.877 UVs del shapefile, sin geometría)

Requiere Python 3 con `geopandas`/`pandas` instalados localmente (ver `requirements.txt`).

---

## 3. Do-file de construcción del panel (ESTUDIO CP)
`code/build/03_panel_uv_anio.do`

**Qué hace:**

- **Panel JUNJI**: lee `data/build/junji_uv.csv`, resuelve los 4 casos de jardines en el límite entre dos UVs (se queda con la primera asignación), fija `anio_termino = 2024` para todos (no hay fecha de cierre confiable), expande cada jardín a una fila por año de actividad (2015-2024), y colapsa a conteos por UV-año (`n_junji` + desagregación por programa: `n_conv_alim`, `n_educ_fam`, `n_alternativo`, `n_clas_terc`, `n_clas_dir`, `n_transitorio`). Guarda `data/build/uv_junji.dta`.

- **Panel Integra**: lee `data/build/integra_uv.csv`, resuelve el caso de un jardín asignado a dos UVs, define `anio_inicio` (con tope mínimo 2015 para jardines que ya existían antes del período), expande por años de actividad, y colapsa a conteos por UV-año (`n_integra`). Verifica que la corrección de Ñuble quedó bien aplicada. Guarda `data/build/uv_integra.dta`.

- **Universo completo de UVs**: carga `data/build/base_uv_completa.csv` (6.877 UVs) y lo guarda como `.dta`.

- **Merge JUNJI + Integra**: une ambos paneles por `t_id_uv_ca` + `anio`, reemplaza missings por cero, y usa `tsfill, full` para completar los años 2015-2024 en las UVs que ya tenían al menos un centro en algún año.

- **Merge con universo completo**: expande `base_uv_completa` a 10 filas por UV (2015-2024) y hace merge con el panel anterior. Las UVs que nunca tuvieron ningún centro entran con missing en todos los conteos, que se reemplazan por cero. Resultado: panel balanceado de **68.770 observaciones** (6.877 UVs x 10 años).

- **Variable de tratamiento**: genera `n_total = n_junji + n_integra` y `tratada` (UV que pasa de 0 a 1+ centros entre un año y el siguiente, dentro de la ventana 2015-2024) → **263 UVs tratadas** (verificado con una corrida completa del pipeline; ver `docs/codebook_panel_final.md`).

- **Gráficos descriptivos**: evolución de centros JUNJI e Integra por año, composición por modalidad JUNJI, y UVs tratadas por región.

**Output:** `data/final/base_cobertura_cp.dta` — la base final del panel de cobertura, con `n_junji`, `n_integra`, `n_total`, `tratada`, desagregación por programa JUNJI, y variables de identificación territorial (`t_id_uv_ca`, `t_reg_nom`, etc.). Ver `docs/codebook_panel_final.md` para el diccionario completo de variables.

---

## Chequeo de robustez (`code/analysis/robustness_panel_no_uv_universe.do`)

Panel UV-año alternativo, construido a partir de insumos ya pre-unidos espacialmente
(`data/raw/junji_panel_uv.xlsx`, `data/raw/integra_panel_uv.xlsx`) con un proceso
distinto al de `code/build/02_spatial_join_uv.py`. A diferencia del panel oficial,
**no está balanceado contra el universo completo de 6.877 UVs** — las UVs sin ningún
centro en todo el período no aparecen en este panel. No usar como reemplazo de
`base_cobertura_cp.dta`; ver el encabezado del script para el detalle de las
diferencias metodológicas.

---

## Notas y limitaciones conocidas

- **`anio_termino` de Integra** no es un indicador confiable de cierre — solo refleja el último año en que el establecimiento aparece en los datos, lo cual puede deberse a cambios de identificador (ej. Ñuble) más que a cierres reales.
- **353 jardines JUNJI y 11 Integra** quedaron fuera del panel por falta de coordenadas válidas.
- **`tratada`** solo captura transiciones de 0→1 *dentro* de la ventana 2015-2024. Las ~2.430 UVs que ya tenían al menos un centro en 2015 nunca pueden marcarse como `tratada`, porque no hay datos de años anteriores para comparar.
- La mayor parte de la expansión observada (en términos de número de centros) ocurre en el **margen intensivo** (UVs que ya tenían cobertura y suman más centros), no en el margen extensivo (UVs nuevas).

## Datos

Ver `docs/data_availability.md` para el origen de las bases (solicitudes de
transparencia JUNJI/Integra) y las condiciones de redistribución.
