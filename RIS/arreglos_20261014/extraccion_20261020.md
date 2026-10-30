# Extracción RIS — miércoles 21/10/2026 temprano (estimaciones del 20/10 + EF de mujer corrido de noche)

Lista viva: se agrega cada archivo nuevo a medida que lo generamos. El martes en la tarde se copia al mail.
Todos en la carpeta de estimaciones (`$est`) salvo que se indique. Estimaciones en `.dta`.

## Primera etapa (matrícula), hijos de madres v60 — `03_primera_etapa_v60.do`
| Archivo | Descripción |
|---|---|
| `coefs_pe_v60.dta` | Coeficientes event study (b, EE, N, n° UVs, media control) de la tasa de matrícula. Modelos: principal, sin cohorte 2015, panel balanceado |
| `V_sa_w_tasa_matricula_v60.dta` | Matriz de varianzas del modelo principal |
| `V_sa_w_s15_tasa_matricula_v60.dta` | Matriz de varianzas sin cohorte 2015 |
| `V_sa_w_bal_tasa_matricula_v60.dta` | Matriz de varianzas del panel balanceado |
| `tend_pe_v60.dta` | Matrícula promedio por año y cohorte de apertura (descriptivo) |
| `log_pe_v60_20261019.txt` | Log |

## Primera etapa por exposición — `14_exposicion_pe.do`
| Archivo | Descripción |
|---|---|
| `coefs_expo_pe_v60.dta` | Efecto en años matriculado entre 0 y 4 según la edad del niño cuando abrió el jardín (3 grupos), hijos de madres v60 |
| `log_expo_pe_20261019.txt` | Log |

## Primera etapa, hijos de madres no vulnerables (40%) — `03b_primera_etapa_nov60.do` (si se corre)
| Archivo | Descripción |
|---|---|
| `coefs_pe_nov60.dta` | Coeficientes event study de la tasa de matrícula, hijos de madres no vulnerables |
| `V_sa_w_tasa_matricula_nov60.dta` | Matriz de varianzas |
| `log_pe_nov60_20261019.txt` | Log |

## Laboral (empleo e ingreso), muestra fija v60 — `02_laboral_v60.do`
| Archivo | Descripción |
|---|---|
| `coefs_lab_v60fija.dta` | Coeficientes event study de empleo formal, ingreso con ceros (principal y sin cohorte 2015) y ln ingreso (principal) |
| `V_sa_w_fija_empleo_formal.dta` | Matriz de varianzas del modelo principal |
| `V_sa_w_s15_fija_empleo_formal.dta` | Matriz de varianzas sin cohorte 2015 |
| `V_sa_w_fija_ingreso_rel.dta` | Matriz de varianzas, ingreso con ceros |
| `V_sa_w_s15_fija_ingreso_rel.dta` | Matriz de varianzas, ingreso con ceros sin cohorte 2015 |
| `V_sa_w_fija_ln_ingreso.dta` | Matriz de varianzas, ln ingreso |
| `tend_lab_v60fija.dta` | Empleo formal promedio por año y cohorte (descriptivo) |
| `log_lab_v60fija_20261019.txt` | Log |

## Fertilidad, mujeres v60 — `01_fertilidad_v60.do`
| Archivo | Descripción |
|---|---|
| `coefs_fert_v60.dta` | Coeficientes event study de la tasa de natalidad. Modelos: principal y sin cohorte 2015 |
| `V_sa_w_v60_tuvo_hijo.dta` | Matriz de varianzas del modelo principal |
| `V_sa_w_s15_v60_tuvo_hijo.dta` | Matriz de varianzas sin cohorte 2015 |
| `tend_fert_v60.dta` | Nacimientos y mujeres por año y cohorte (descriptivo) |
| `log_fert_v60_20261019.txt` | Log |

## Event study sin agrupar los años pre (k de -10 a 9) — `15_sin_bin.do`
| Archivo | Descripción |
|---|---|
| `b_sinbin_tasa_matricula.dta` | Coeficientes (una columna por k) de la tasa de matrícula, sin agrupar los años pre |
| `V_sinbin_tasa_matricula.dta` | Matriz de varianzas |
| `b_sinbin_empleo_formal.dta` | Coeficientes de empleo formal, sin agrupar los años pre |
| `V_sinbin_empleo_formal.dta` | Matriz de varianzas |
| `b_sinbin_ingreso_rel.dta` | Coeficientes de ingreso con ceros, sin agrupar los años pre |
| `V_sinbin_ingreso_rel.dta` | Matriz de varianzas |
| `b_sinbin_tuvo_hijo.dta` | Coeficientes de natalidad, sin agrupar los años pre |
| `V_sinbin_tuvo_hijo.dta` | Matriz de varianzas |
| `log_sinbin_20261020.txt` | Log |

## Efecto fijo de mujer — `08a_ef_mujer_empleo.do`, `08b_ef_mujer_fert.do`
| Archivo | Descripción |
|---|---|
| `coefs_indm_empleo.dta` | Coeficientes event study con efecto fijo de mujer (UV fija): empleo formal, ingreso con ceros y ln ingreso |
| `V_sa_indm_empleo_formal.dta` | Matriz de varianzas, empleo formal |
| `V_sa_indm_ingreso_rel.dta` | Matriz de varianzas, ingreso con ceros |
| `V_sa_indm_ln_ingreso.dta` | Matriz de varianzas, ln ingreso |
| `log_indm_empleo_20261019.txt` | Log |
| `coefs_indm_fert.dta` | Coeficientes event study de natalidad con efecto fijo de mujer (UV fija) |
| `V_sa_indm_tuvo_hijo.dta` | Matriz de varianzas |
| `log_indm_fert_20261019.txt` | Log |

## Mudanzas 2022 — `mudanzas_2022.do` (si se corre)
| Archivo | Descripción |
|---|---|
| `log_mudanzas22_20261019.txt` | Tablas de cambios de UV por año (descriptivo) |

## Construcción de muestras (corrido el fin de semana)
| Archivo | Descripción |
|---|---|
| Logs del 09, 10 y 11 | Logs de construcción de las muestras v60 (con los nombres que tengan) |

## Do-files
Todos los do-files corridos esta semana, tal cual se tipearon: 09, 10, 11 (fin de semana), 03, 03b, 14_exposicion, 02, 01, 15_sin_bin, 08a, 08b, mudanzas_2022.
