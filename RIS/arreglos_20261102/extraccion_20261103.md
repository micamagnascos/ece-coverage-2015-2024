# Extracción de esta semana: lista en curso

## LISTA FINAL (49 de 50 elementos). Esta manda sobre las secciones de abajo

**Estimaciones (10):** `coefs_pe_v60.csv`, `coefs_lab_entrada.csv`, `coefs_fert_v60cw.csv`, `coefs_indm_empleo_entr.csv`, `coefs_indm_e14.csv`, `coefs_indm_e14_hijos.csv`, `tend_pe_v60.csv`, `tend_lab_entrada.csv`, `tend_fert_v60cw.csv`, `balance_lab_entrada.csv`

**Do-files (9):** `crosswalk_cobertura_uvs.do`, `22_diagnostico_uv.do` (sin líneas `*RESULTADO`), `09_merge_muestra_v60.do`, `11_primera_etapa_v60.do`, `03_primera_etapa_v60.do`, `02_laboral_entrada.do`, `01_fertilidad_cw.do`, `08a_ef_mujer_empleo.do`, `08b_ef_mujer_fert.do`

**V, todas 14 x 14 (22):** `V_sa_w_tasa_matricula_v60`; `V_sa_w_entr_empleo_formal`, `V_sa_w_entr_ingreso_rel`, `V_sa_w_entr_ln_ingreso`; `V_sa_w_bal_empleo_formal`, `V_sa_w_bal_ingreso_rel`, `V_sa_w_bal_ln_ingreso`; `V_sa_w_e14_tuvo_hijo`, `V_sa_w_e14_nac_acum`, `V_sa_w_e14_hijos_pre2014`; `V_sa_w_e14_bal_tuvo_hijo`, `V_sa_w_e14_bal_nac_acum`; `V_sa_indm_entr_empleo_formal`, `V_sa_indm_entr_ingreso_rel`, `V_sa_indm_entr_ln_ingreso`; `V_sa_indm_entr_bal_empleo_formal`, `V_sa_indm_entr_bal_ingreso_rel`, `V_sa_indm_entr_bal_ln_ingreso`; `V_sa_indm_e14_tuvo_hijo`, `V_sa_indm_e14_nac_acum`; `V_sa_indm_e14_bal_tuvo_hijo`, `V_sa_indm_e14_bal_nac_acum`

**`tablas_20261104.txt` (8 elementos):** 08a `sum ingreso_total if anio == 2024` y `tab g1_f bal if anio == 2014, row`; 08b `tab g1_f bal if anio == 2014, row` y `tab grupo_h`; 02 `tab n_anios_t1`; 01 `tab n_anios_t1` (18-35); 09 `tab n_anios`; 03 `tab primer_anio`.

No van: 21, 14, 23, V de sin-2015 y de submuestras (sus coefs sí vienen).

---


**Se extrae el miércoles 04/11 temprano.** Solo archivos generados DESPUÉS de que el 09 corra bien el 03/11: lo del 02/11 usó las bases sin el arreglo de edad.

Se pega a mano en la carpeta de extracción. Lista viva: se agrega cada do-file cuando corre.

## Antes de mandar
- **Anotar a mano el `Mean` de `sum ingreso_total if anio == 2024` del log del 08a** (convierte `ingreso_rel` a pesos: coef × media / 1200).
- Copiar solo archivos de esta lista, revisando que tengan fecha de esta semana. En `$est` hay archivos de otras semanas con nombres casi iguales.
- Abrir cada V y comparar su dimensión con la columna "Dim." de esta lista.
- Sin tablas ni resultados pegados dentro de los do-files (la extracción del 21/10 se rechazó por eso). Si tipeaste las líneas `*RESULTADO 30/10...` del 22, bórralas antes de extraerlo.
- Al llegar: `python RIS/revisar_extraccion.py RIS/AAAAMMDD`.

## Ya corrido
### 03 primera etapa (crosswalk nuevo)
| Archivo | Dim. | Estado |
|---|---|---|
| `coefs_pe_v60.csv` | | Por extraer |
| `V_sa_w_tasa_matricula_v60.csv` | 14 x 14 | Por extraer |
| `V_sa_w_s15_tasa_matricula_v60.csv` | 13 x 13 | Por extraer |
| `V_sa_w_bal_tasa_matricula_v60.csv` | 6 x 6 | Por extraer (si el bloque C corrió) |
| `tend_pe_v60.csv` | | Por extraer |
| `log_pe_v60_20261102.txt` | | Por extraer |
| `03_primera_etapa_v60.do` | | Por extraer |

### Muestra y crosswalk (solo código y logs)
| Archivo | Estado |
|---|---|
| `crosswalk_cobertura_uvs.do` | Por extraer |
| `09_merge_muestra_v60.do` + `log_09_entrada.txt` | Por extraer |
| `22_diagnostico_uv.do` + `log_diagnostico_uv.txt` | Por extraer |

## Por correr (se agregan sus archivos cuando corran)
- 02 laboral con la muestra nueva: completa y mujeres balanceadas.
- 01 fertilidad: tasa, `nac_acum`, `hijos_total`.
- 21 laboral todas: de nuevo, porque el 30/10 corrió con el crosswalk viejo.
- 14 exposición: de nuevo, su panel de niños cambió con el crosswalk.
- 08a / 08b efecto fijo de mujer: de nuevo (noche).

## Si hay espacio
- `20_fert_vecinos`, `15_sin_bin`, `03b_primera_etapa_nov60`.

## Ya no hace falta extraer (crosswalk viejo)
La lista anterior (`arreglos_20261028/extraccion_proxima.md`) queda reemplazada en estos puntos:
- `V_sa_w_fija_empleo_formal`, `V_sa_w_fija_ln_ingreso`: las reemplaza el 02 nuevo.
- Rescate de 08a/08b desde los logs: se vuelven a correr.
- Coefs y V del 21 anterior: se vuelve a correr.

## 02 laboral, muestra nueva (`02_laboral_entrada.do`, agregar a "Ya corrido" cuando corra)
| Archivo | Dim. |
|---|---|
| `coefs_lab_entrada.csv`, `tend_lab_entrada.csv`, `balance_lab_entrada.csv` | |
| `V_sa_w_entr_empleo_formal`, `_ingreso_rel`, `_ln_ingreso`, `_ingreso_mes24`, `_n_hijos_menor5` (.csv) | 14 x 14 |
| `V_sa_w_s15_entr_empleo_formal`, `V_sa_w_s15_entr_ingreso_rel` (.csv) | 13 x 13 |
| `V_sa_w_bal_empleo_formal`, `_ingreso_rel`, `_ln_ingreso`, `_ingreso_mes24` (.csv) | 14 x 14 |
| `log_lab_entrada_20261102.txt`, `02_laboral_entrada.do` | |

## 08a y 08b efecto fijo de mujer (`arreglos_20261102`, corren la noche del 02/11)
Los archivos antiguos de `$est` sin `entr` ni `e14` en el nombre son del crosswalk viejo: no extraerlos.
| Archivo | Dim. |
|---|---|
| `coefs_indm_empleo_entr.csv`, `coefs_indm_e14.csv` | |
| `V_sa_indm_entr_empleo_formal`, `_ingreso_rel`, `_ln_ingreso` (.csv) | 14 x 14 |
| `V_sa_indm_entr_bal_empleo_formal`, `_ingreso_rel`, `_ln_ingreso` (.csv) | 14 x 14 |
| `V_sa_indm_e14_tuvo_hijo`, `_nac_acum` (.csv) | 14 x 14 |
| `V_sa_indm_e14_bal_tuvo_hijo`, `_nac_acum` (.csv) | 14 x 14 |
| `coefs_indm_e14_hijos.csv` | |
| `V_sa_indm_e14_h0_tuvo_hijo`, `_h1_tuvo_hijo`, `_h2_tuvo_hijo`, `_h0_nac_acum`, `_h1_nac_acum`, `_h2_nac_acum` (.csv) | 14 x 14 |
| `log_indm_empleo_20261102.txt`, `log_indm_fert_20261102.txt`, `08a_ef_mujer_empleo.do`, `08b_ef_mujer_fert.do` | |

## 01 fertilidad, crosswalk nuevo (`01_fertilidad_cw.do`, agregar a "Ya corrido" cuando corra)
| Archivo | Dim. |
|---|---|
| `coefs_fert_v60cw.csv`, `tend_fert_v60cw.csv` | |
| `V_sa_w_cw_tuvo_hijo`, `V_sa_w_cw_nac_acum`, `V_sa_w_cw_hijos_total` (.csv) | 14 x 14 |
| `V_sa_w_s15_cw_tuvo_hijo.csv` | 13 x 13 |
| `V_sa_w_bal_tuvo_hijo`, `V_sa_w_bal_nac_acum`, `V_sa_w_bal_hijos_total` (.csv) | 14 x 14 |
| `V_sa_w_e14_tuvo_hijo`, `V_sa_w_e14_nac_acum`, `V_sa_w_e14_hijos_total`, `V_sa_w_e14_hijos_pre2014` (.csv) | 14 x 14 |
| `V_sa_w_e14_bal_tuvo_hijo`, `V_sa_w_e14_bal_nac_acum`, `V_sa_w_e14_bal_hijos_total`, `V_sa_w_e14_bal_hijos_pre2014` (.csv) | 14 x 14 |
| `V_sa_w_e14_h0_tuvo_hijo`, `V_sa_w_e14_h1_tuvo_hijo`, `V_sa_w_e14_h2_tuvo_hijo` (.csv) | 14 x 14 |
| `V_sa_w_e14_h0_nac_acum`, `V_sa_w_e14_h1_nac_acum`, `V_sa_w_e14_h2_nac_acum` (.csv) | 14 x 14 |
| `log_fert_20261102.txt`, `01_fertilidad_cw.do` | |

## Muestra laboral sin salida por edad (02/11)
`09_merge_laboral_edades.do` corre entero y rehace las 3 bases (la laboral como `muestra_laboral_ingresos_v60_entrada.parquet`). Se repiten 11, 03, 02, 01, 08a y 08b: los resultados previos a esta corrida ya no sirven, extraer solo archivos con fecha 02/11 tarde o 03/11. Agregar `09_merge_laboral_edades.do` y `log_09_entrada.txt`.

## Pendiente para viernes 06/11 o lunes 09/11 (no entra en esta extracción)
24 efecto fijo de mujer con UV desde 2022 (`coefs_indm_uv22.csv`, `V_sa_indm_uv22_empleo_formal`, `V_sa_indm_uv22_ingreso_rel`, `log_indm_uv22_20261104.txt`, `24_ef_mujer_uv2022.do`), corre el 04/11. 21 laboral todas, 14 exposición y 23 (Callaway-Sant'Anna y UV con jardín en 2014 como control).

## 23 robustez (`23_robustez_cs_controles.do`, próxima extracción)
| Archivo | Dim. |
|---|---|
| `coefs_ctrl_stock.csv` | |
| `V_sa_w_stock_empleo_formal`, `V_sa_w_stock_ingreso_rel` (.csv) | 14 x 14 |
| `log_robustez_cs_20261103.txt`, `23_robustez_cs_controles.do` | |
| `cs_empleo_formal.png`, `cs_ingreso_rel.png`, `cs_tasa_matricula.png`, `cs_tuvo_hijo.png` | |
