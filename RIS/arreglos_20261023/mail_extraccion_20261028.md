# Solicitud de extracción RIS — 28/10/2026

**Nombre del estudio:** "Los impactos de la educación parvularia en Chile a través de tres décadas"

**Carpeta exacta desde donde se requiere extraer datos:**
`\\10.60.214.178\Repositorio_Datos_ADM\repositorio_ris\RIS_INVESTIGACION_11\190_impacto_jardines\03_EDITABLES\02_RESULTADOS\Extracción\20261028`

**Archivos exactos que se requiere extraer (36 archivos: 34 de estimaciones y códigos + 4 tablas dentro de 2 registros = 38 elementos):**

> Antes de mandar: (0) en los logs, borrar todo menos las tablas indicadas (cada tabla = 1 elemento, máximo 50); (1) completar la columna Dimensión con `describe, short` (o abrir el csv); (2) borrar las filas de lo que no se corrió; (3) no pegar tablas dentro de los do-files (motivo del rechazo del 21/10).

### A. Primera etapa (matrícula parvularia), hijos de madres del 60% más vulnerable

| # | Archivo | Dimensión | Contenido |
|---|---|---|---|
| 1 | `coefs_pe_v60.dta` | 36 x 8 | Coeficientes de estudio de eventos (coeficiente, error estándar, N, n° de unidades vecinales, media del grupo control) por año relativo a la apertura. Modelos: principal, sin cohorte 2015, panel balanceado |
| 2 | `V_sa_w_tasa_matricula_v60.dta` | 14 x 14 | Matriz de varianzas-covarianzas de los coeficientes, modelo principal |
| 3 | `V_sa_w_bal_tasa_matricula_v60.dta` | 6 x 6 | Matriz de varianzas-covarianzas, panel balanceado |
| 4 | `tend_pe_v60.dta` | 121 x 5 | Matrícula agregada por año y cohorte de apertura (descriptivo agregado) |
| 5 | `coefs_expo_pe_v60.dta` | 3 x 8 | Coeficientes de años matriculado entre 0 y 4 años según la edad del niño cuando abrió el jardín (3 grupos) |

### B. Resultados laborales, madres del 60% más vulnerable (muestra fija)

| # | Archivo | Dimensión | Contenido |
|---|---|---|---|
| 6 | `coefs_lab_v60fija.dta` | 88 x 8 | Coeficientes de estudio de eventos: empleo formal, ingreso total relativo (incluye ceros), logaritmo del ingreso e ingreso total en pesos de 2024 por mes. Modelos: principal y sin cohorte 2015 |
| 7 | `V_sa_w_fija_empleo_formal.dta` | 14 x 14 | Matriz de varianzas-covarianzas, empleo formal |
| 8 | `V_sa_w_fija_ingreso_rel.dta` | 14 x 14 | Matriz de varianzas-covarianzas, ingreso total relativo |
| 9 | `V_sa_w_fija_ln_ingreso.dta` | 14 x 14 | Matriz de varianzas-covarianzas, logaritmo del ingreso |
| 10 | `V_sa_w_fija_ingreso_mes24.dta` | 14 x 14 | Matriz de varianzas-covarianzas, ingreso total en pesos de 2024 por mes |
| 11 | `tend_lab_v60fija.dta` | 121 x 5 | Empleo formal agregado por año y cohorte de apertura (descriptivo agregado) |
| 12 | `balance_lab_v60fija.dta` | 15 x 7 | Tabla de balance 2014: promedios de unidades vecinales tratadas y control (sin ponderar y ponderado) |
| 13 | `log_lab_v60fija_20261019.txt` | 2 tablas | Registro de la estimación: SOLO las 2 tablas de promedios anuales de ingreso (todas las madres / solo con ingreso) |

### C. Fertilidad, mujeres del 60% más vulnerable de 18 a 49 años

| # | Archivo | Dimensión | Contenido |
|---|---|---|---|
| 14 | `coefs_fert_v60.dta` | 29 x 8 | Coeficientes de estudio de eventos de la tasa de natalidad. Modelos: principal y sin cohorte 2015 |
| 15 | `V_sa_w_fija_tuvo_hijo.dta` | 14 x 14 | Matriz de varianzas-covarianzas, modelo principal |
| 16 | `tend_fert_v60.dta` | 121 x 5 | Nacimientos y mujeres agregados por año y cohorte de apertura (descriptivo agregado) |

### D. Estimaciones con efecto fijo de mujer (incluye panel balanceado de mujeres)

| # | Archivo | Dimensión | Contenido |
|---|---|---|---|
| 17 | `coefs_indm_empleo.csv` | 75 x 8 | Coeficientes de estudio de eventos con efecto fijo individual: empleo formal, ingreso total relativo y logaritmo del ingreso; muestra completa y panel balanceado |
| 18 | `V_sa_indm_empleo_formal.csv` | 14 x 14 | Matriz de varianzas-covarianzas, empleo formal |
| 19 | `V_sa_indm_ingreso_rel.csv` | 14 x 14 | Matriz de varianzas-covarianzas, ingreso total relativo |
| 20 | `V_sa_indm_ln_ingreso.csv` | 14 x 14 | Matriz de varianzas-covarianzas, logaritmo del ingreso |
| 21 | `V_sa_indm_bal_empleo_formal.csv` | 14 x 14 | Matriz de varianzas-covarianzas, empleo formal, panel balanceado |
| 22 | `V_sa_indm_bal_ingreso_rel.csv` | 14 x 14 | Matriz de varianzas-covarianzas, ingreso total relativo, panel balanceado |
| 24 | `coefs_indm_fert.csv` | 30 x 8 | Coeficientes de estudio de eventos con efecto fijo individual, tasa de natalidad; muestra completa y panel balanceado |
| 25 | `V_sa_indm_tuvo_hijo.csv` | 14 x 14 | Matriz de varianzas-covarianzas, tasa de natalidad |
| 26 | `V_sa_indm_bal_tuvo_hijo.csv` | 14 x 14 | Matriz de varianzas-covarianzas, tasa de natalidad, panel balanceado |

### E. Códigos

| # | Archivo | Contenido |
|---|---|---|
| 27 | `crosswalk_cobertura_uvs.do` | Correspondencia de códigos de unidad vecinal entre años (corrección 2016–2021) |
| 28 | `09_merge_muestra_v60.do` | Construcción de las muestras laboral y de fertilidad del 60% más vulnerable |
| 29 | `11_primera_etapa_v60.do` | Construcción del panel de matrícula de hijos de madres del 60% más vulnerable |
| 30 | `03_primera_etapa_v60.do` | Estimación de la primera etapa (matrícula) |
| 31 | `14_exposicion_pe.do` | Estimación de la primera etapa por exposición |
| 32 | `02_laboral_v60.do` | Estimación de resultados laborales |
| 33 | `01_fertilidad_v60.do` | Estimación de fertilidad |
| 34 | `08a_ef_mujer_empleo.do` | Estimación con efecto fijo individual, resultados laborales |
| 35 | `08b_ef_mujer_fert.do` | Estimación con efecto fijo individual, fertilidad |
| 36 | `18_mudanzas_2122.do` | Revisión de cambios de unidad vecinal |
