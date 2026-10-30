# Solicitud de extracción RIS — 21/10/2026

**Nombre del estudio:** "Los impactos de la educación parvularia en Chile a través de tres décadas"

**Carpeta exacta desde donde se requiere extraer datos:**
`\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\02_RESULTADOS\Extracción\20261021`

**Archivos exactos que se requiere extraer (32 elementos):**

### A. Primera etapa (matrícula parvularia), hijos de madres del 60% más vulnerable

| # | Archivo | Dimensión | Contenido |
|---|---|---|---|
| 1 | `coefs_pe_v60.dta` | 36 x 8 | Coeficientes de estudio de eventos (coeficiente, error estándar, N, n° de unidades vecinales, media del grupo control) por año relativo a la apertura. Modelos: principal, sin cohorte 2015, panel balanceado |
| 2 | `V_sa_w_tasa_matricula_v60.dta` | 14 x 14 | Matriz de varianzas-covarianzas de los coeficientes, modelo principal |
| 3 | `V_sa_w_s15_tasa_matricula_v60.dta` | 13 x 13 | Matriz de varianzas-covarianzas, modelo sin cohorte 2015 |
| 4 | `V_sa_w_bal_tasa_matricula_v60.dta` | 6 x 6 | Matriz de varianzas-covarianzas, panel balanceado |
| 5 | `tend_pe_v60.dta` | 121 x 5 | Matrícula agregada por año y cohorte de apertura (descriptivo agregado) |
| 6 | `coefs_expo_pe_v60.dta` | 3 x 8 | Coeficientes de años matriculado entre 0 y 4 años según la edad del niño cuando abrió el jardín (3 grupos) |

### B. Resultados laborales, madres del 60% más vulnerable (muestra fija)

| # | Archivo | Dimensión | Contenido |
|---|---|---|---|
| 7 | `coefs_lab_v60fija.dta` | 73 x 8 | Coeficientes de estudio de eventos: empleo formal, ingreso total relativo (incluye ceros) y logaritmo del ingreso. Modelos: principal y sin cohorte 2015 |
| 8 | `V_sa_w_fija_empleo_formal.dta` | 14 x 14 | Matriz de varianzas-covarianzas, empleo formal |
| 9 | `V_sa_w_s15_fija_empleo_formal.dta` | 13 x 13 | Matriz de varianzas-covarianzas, empleo formal sin cohorte 2015 |
| 10 | `V_sa_w_fija_ingreso_rel.dta` | 14 x 14 | Matriz de varianzas-covarianzas, ingreso total relativo |
| 11 | `V_sa_w_s15_fija_ingreso_rel.dta` | 13 x 13 | Matriz de varianzas-covarianzas, ingreso total relativo sin cohorte 2015 |
| 12 | `V_sa_w_fija_ln_ingreso.dta` | 14 x 14 | Matriz de varianzas-covarianzas, logaritmo del ingreso |
| 13 | `tend_lab_v60fija.dta` | 121 x 5 | Empleo formal agregado por año y cohorte de apertura (descriptivo agregado) |

### C. Fertilidad, mujeres del 60% más vulnerable de 18 a 49 años

| # | Archivo | Dimensión | Contenido |
|---|---|---|---|
| 14 | `coefs_fert_v60.dta` | 29 x 8 | Coeficientes de estudio de eventos de la tasa de natalidad. Modelos: principal y sin cohorte 2015 |
| 15 | `V_sa_w_v60_tuvo_hijo.dta` | 14 x 14 | Matriz de varianzas-covarianzas, modelo principal |
| 16 | `V_sa_w_s15_v60_tuvo_hijo.dta` | 13 x 13 | Matriz de varianzas-covarianzas, sin cohorte 2015 |
| 17 | `tend_fert_v60.dta` | 121 x 5 | Nacimientos y mujeres agregados por año y cohorte de apertura (descriptivo agregado) |

### D. Estimaciones con efecto fijo de mujer

| # | Archivo | Dimensión | Contenido |
|---|---|---|---|
| 18 | `coefs_indm_empleo.dta` | 45 x 8 | Coeficientes de estudio de eventos con efecto fijo individual: empleo formal, ingreso total relativo y logaritmo del ingreso |
| 19 | `V_sa_indm_empleo_formal.dta` | 14 x 14 | Matriz de varianzas-covarianzas, empleo formal |
| 20 | `V_sa_indm_ingreso_rel.dta` | 14 x 14 | Matriz de varianzas-covarianzas, ingreso total relativo |
| 21 | `V_sa_indm_ln_ingreso.dta` | 14 x 14 | Matriz de varianzas-covarianzas, logaritmo del ingreso |
| 22 | `coefs_indm_fert.dta` | 15 x 8 | Coeficientes de estudio de eventos con efecto fijo individual, tasa de natalidad |
| 23 | `V_sa_indm_tuvo_hijo.dta` | 14 x 14 | Matriz de varianzas-covarianzas, tasa de natalidad |

### E. Códigos de estimación

| # | Archivo | Contenido |
|---|---|---|
| 24 | `03_primera_etapa_v60.do` | Estimación de la primera etapa (matrícula) |
| 25 | `14_exposicion_pe.do` | Estimación de la primera etapa por exposición (edad del niño a la apertura) |
| 26 | `02_laboral_v60.do` | Estimación de resultados laborales |
| 27 | `01_fertilidad_v60.do` | Estimación de fertilidad |
| 28 | `08a_ef_mujer_empleo.do` | Estimación con efecto fijo individual, resultados laborales |
| 29 | `08b_ef_mujer_fert.do` | Estimación con efecto fijo individual, fertilidad |

### F. Códigos de construcción de muestras

| # | Archivo | Contenido |
|---|---|---|
| 30 | `rsh_uv_panel_2014_2024.do` | Construcción del panel RSH/FPS 2014–2024 (corrección de la variable de puntaje FPS) |
| 31 | `09_merge_muestra_v60.do` | Construcción de las muestras laboral y de fertilidad del 60% más vulnerable |
| 32 | `11_primera_etapa_v60.do` | Construcción del panel de matrícula de hijos de madres del 60% más vulnerable |

**Explicar brevemente por qué los datos extraídos son necesarios y suficientes para la realización del estudio:**

Los archivos `.dta` contienen solo resultados agregados de estimaciones: coeficientes, errores estándar y matrices de varianzas-covarianzas de modelos de estudio de eventos estimados a nivel de unidad vecinal, más tablas descriptivas agregadas por año y cohorte de apertura de jardines. No contienen datos individuales ni identificadores. Se necesitan para:
- construir los gráficos de los efectos de la apertura de jardines públicos sobre la matrícula parvularia, el empleo, los ingresos y la fertilidad de las madres;
- calcular efectos promedio y pruebas conjuntas (que requieren las matrices de varianzas);
- realizar análisis de sensibilidad de los supuestos de identificación fuera del servidor.

Los códigos (`.do`) documentan la construcción de las muestras y las estimaciones, para verificar y replicar los resultados.
