# Codebook — `data/final/base_cobertura_cp.dta`

Panel balanceado UV x año, 2015-2024 (6.877 unidades vecinales x 10 años = 68.770
observaciones). Generado por `code/build/03_panel_uv_anio.do`.

## Identificadores de unidad vecinal (heredados del shapefile MDS, `unidades-vecinales_2023`)

| Variable | Descripción |
|---|---|
| `objectid` | ID interno del shapefile de unidades vecinales (MDS, julio 2023). |
| `t_id_uv_ca` | Identificador único de la unidad vecinal (código cartográfico). Llave del panel junto con `anio`. |
| `uv_carto` | Código cartográfico de la unidad vecinal. |
| `t_uv_nom` | Nombre de la unidad vecinal. |
| `t_reg_ca` | Código de región. |
| `t_reg_nom` | Nombre de la región. |
| `t_prov_ca` | Código de provincia. |
| `t_prov_nom` | Nombre de la provincia. |
| `t_com` | Código de comuna. |
| `t_com_nom` | Nombre de la comuna. |
| `st_area_sh` | Área de la unidad vecinal (según atributo del shapefile). |
| `st_length_` | Perímetro/longitud de la unidad vecinal (según atributo del shapefile). |

*Nota: estas columnas provienen tal cual del shapefile del Ministerio de Desarrollo
Social y Familia; no se revisó un diccionario de datos oficial del MDS para
confirmar unidades exactas de `st_area_sh`/`st_length_` — verificar contra la
documentación del shapefile si se van a usar como variable de control (ej. densidad).*

## Variable de tiempo

| Variable | Descripción |
|---|---|
| `anio` | Año del panel, 2015-2024. |

## Conteos de cobertura (variable dependiente / de interés)

| Variable | Descripción |
|---|---|
| `n_junji` | Número de establecimientos JUNJI activos en la UV ese año (tras excluir programa "Educativo para la Familia" y modalidad "Jardín Familiar" — ver Nota de exclusión abajo). |
| `n_integra` | Número de establecimientos Integra activos en la UV ese año (modalidades `convenio`, `jardin infantil`, `jardin sobre islas`). |
| `n_total` | `n_junji + n_integra`. |
| `n_conv_alim` | N° establecimientos JUNJI cuyo programa principal es Convenio Alimentación. |
| `n_educ_fam` | N° establecimientos JUNJI cuyo programa principal es Educativo para la Familia (subconjunto residual — la mayoría de este programa ya se excluyó de `n_junji`, ver nota). |
| `n_alternativo` | N° establecimientos JUNJI cuyo programa principal es Jardín Infantil Alternativo. |
| `n_clas_terc` | N° establecimientos JUNJI cuyo programa principal es Jardín Infantil Clásico Adm. por Terceros (VTF). |
| `n_clas_dir` | N° establecimientos JUNJI cuyo programa principal es Jardín Infantil Clásico de Adm. Directa. |
| `n_transitorio` | N° establecimientos JUNJI cuyo programa principal es Transitorio. |

**Nota de exclusión (JUNJI):** se excluyen los establecimientos cuyo programa
principal es "Educativo para la Familia" o cuya modalidad principal es "Jardín
Familiar", porque implican esfuerzo directo de las madres/padres en la atención
(CASH, Jardín Comunicacional) en vez de una oferta que libere tiempo de cuidado
(ver `docs/base_de_cobertura.docx`, sección "Programas"/"Modalidades"). Por esto
`n_conv_alim + n_alternativo + n_clas_terc + n_clas_dir + n_transitorio` no suma
exactamente `n_junji` en todos los casos si un establecimiento no cae en ninguna de
estas categorías principales — revisar consistencia al usar las desagregaciones.

## Variable de tratamiento

| Variable | Descripción |
|---|---|
| `tratada` | =1 si la UV pasa de `n_total`=0 a `n_total`>=1 entre el año `anio-1` y `anio`, dentro de la ventana 2015-2024; 0 en caso contrario. **Limitación:** las UVs que ya tenían al menos un centro en 2015 nunca pueden marcarse como `tratada`, porque no hay datos de años anteriores a 2015 para comparar. 263 UVs quedan marcadas como `tratada=1` en algún año del panel (verificado con una corrida completa del pipeline, 10/07/2026): 2016=63, 2017=78, 2018=45, 2019=37, 2020=7, 2021=15, 2022=10, 2023=8. Metropolitana (52) y Valparaíso (44) concentran la mayor cantidad. |

## Limitaciones conocidas (ver también README.md)

- 353 establecimientos JUNJI y 11 Integra quedaron fuera del panel por falta de
  coordenadas válidas (no se les pudo asignar `t_id_uv_ca`).
- `anio_termino` de Integra (usado para construir el panel, no queda en la base
  final) no es un indicador confiable de cierre — solo refleja el último año en que
  el establecimiento aparece en los datos.
- La mayor parte de la expansión observada ocurre en el margen intensivo (UVs que ya
  tenían cobertura y suman más centros), no en el margen extensivo (UVs nuevas
  marcadas `tratada`).
