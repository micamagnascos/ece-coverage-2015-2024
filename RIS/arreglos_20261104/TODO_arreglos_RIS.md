# TODO próxima sesión RIS: arreglos de la extracción 04/11

Do-files corregidos en esta carpeta (`RIS/arreglos_20261104/`). Cada cambio tiene arriba `* ERROR ARREGLAR:`.
Las líneas son las del do-file **original**, el que está en el RIS.

## 1. Tipear

### `03_primera_etapa_v60.do`
- [ ] **l.73:** borrar `if g1`

```stata
eventstudyinteract tasa_matricula d4 d6-d10 [aw= n_ninos], cohort(g1) control_cohort(nunca_tratada)  absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
```

### `08a_ef_mujer_empleo.do`
- [ ] **l.30:** agregar `double`

```stata
by rut_inn: gen double uv_fija = id_uv_2024[1]
```

- [ ] **l.112:** cambiar el outcome a `ln_ingreso`

```stata
eventstudyinteract ln_ingreso d1-d4 d6-d15 if bal == 1, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
```

### `08b_ef_mujer_fert.do`
- [ ] **l.23:** agregar `double`

```stata
by rut_inn: gen double uv_fija = id_uv_2024[1]
```

- [ ] **l.121:** `quietly sum nac_acum if nunca_f == 1 & grupo_h == 0`
- [ ] **l.128:** `quietly sum nac_acum if nunca_f == 1 & grupo_h == 1`
- [ ] **l.130:** cambiar a `if grupo_h == 1`

```stata
eventstudyinteract nac_acum d1-d4 d6-d15 if grupo_h == 1, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
```

- [ ] **l.135:** `quietly sum nac_acum if nunca_f == 1 & grupo_h == 2`
- [ ] **l.137:** cambiar a `if grupo_h == 2`

```stata
eventstudyinteract nac_acum d1-d4 d6-d15 if grupo_h == 2, cohort(g1_f) control_cohort(nunca_f) absorb(rut_inn anio) vce(cluster uv_fija)
```

### `24_ef_mujer_uv2022.do`
- [ ] **Línea de `gen uv_fija`** (l.23 en mi versión; revisar si en el RIS es otra): agregar `double`

```stata
by rut_inn: gen double uv_fija = id_uv_2024[1]
```

## 2. Correr

- [ ] `03` (el más liviano)
- [ ] `08a` (horas)
- [ ] `08b` (horas)
- [ ] `24`

Guardan con los mismos nombres en `$est` y sobrescriben también los logs. La versión anterior queda en `RIS/20261104`.

## 3. Revisar que quedó bien

- [ ] **`03`, `sa_w_bal`:** N mucho mayor que 1.513 y más de 221 UV (tiene que incluir a las nunca tratadas). k = 4 con coeficiente distinto de 0.
- [ ] **`08a` y `08b`:** `gunique uv_fija` y `n_uv` cerca de 4.400, no 1.600.
- [ ] **`08a`:** los coeficientes de `sa_indm_entr` y `sa_indm_entr_bal` en empleo e ingreso quedan **iguales** a los de la extracción 04/11; solo cambian los EE. Si cambian los coeficientes, avisar.
- [ ] **`08a`:** `sa_indm_entr_bal ln_ingreso` distinto de `ingreso_rel` y con N menor (solo mujeres con ingreso).
- [ ] **`08b`:** `nac_acum` h0, h1 y h2 con distinto N, y media cercana a 0,3–0,5, no 0,06.

## 4. Anotar de los logs nuevos (faltaron en `tablas.txt`)

- [ ] `08a`: `sum ingreso_total if anio == 2024` (la media, para pasar a pesos)
- [ ] `08a`: `tab g1_f bal if anio == 2014, row`
- [ ] `08a`: `tab g1_f rel_f` (línea nueva, tipearla después de `tab rel_t1_bin`): mujeres por cohorte y k en el EF
- [ ] `08b`: `tab g1_f bal if anio == 2014, row`
- [ ] `08b`: `tab grupo_h`
- [ ] `08b`: `tab g1_f rel_f` (línea nueva, tipearla después de `tab rel_t1_bin`): mujeres por cohorte y k en el EF de fertilidad

## 5. Extraer

- [ ] `coefs_pe_v60.csv`, `V_sa_w_bal_tasa_matricula_v60.csv`, `03_primera_etapa_v60.do`
- [ ] `coefs_indm_empleo_entr.csv` y sus 6 V: `V_sa_indm_entr_empleo_formal`, `_ingreso_rel`, `_ln_ingreso`, `V_sa_indm_entr_bal_empleo_formal`, `_ingreso_rel`, `_ln_ingreso`; `08a_ef_mujer_empleo.do`
- [ ] `coefs_indm_e14.csv` y sus 4 V: `V_sa_indm_e14_tuvo_hijo`, `_nac_acum`, `_bal_tuvo_hijo`, `_bal_nac_acum`; `coefs_indm_e14_hijos.csv`; `08b_ef_mujer_fert.do`
- [ ] `coefs_indm_uv22.csv`, `V_sa_indm_uv22_empleo_formal`, `V_sa_indm_uv22_ingreso_rel`, `24_ef_mujer_uv2022.do`
- [ ] `v_sa_w_e14_hijos_total` y `v_sa_w_e14_bal_hijos_total` (ya los guarda el `01`; no llegaron el 04/11; sin ellos `hijos_total` no tiene EE del promedio ni prueba de pre-tendencias)
- [ ] Tablas de la sección 4
- [ ] Sin resultados pegados dentro de los do-files
- [ ] Al llegar: `python RIS/revisar_extraccion.py RIS/AAAAMMDD`

## 6. Otros

- [ ] Local, no RIS: decidir si se borra la copia duplicada `RIS/20261006/20261104/`.
- [ ] Agregar `ingreso_anual` e `ingreso_total` a `tend_lab_entrada` en el `02`, para tener el ingreso en pesos de cada año por cohorte y dar el nivel del año antes de abrir (hoy solo hay 2014). `ingreso_mes24` no sirve para esto: lleva cada año al promedio de 2024.
- [ ] Anotar del log del `02` las dos `tabstat ingreso_total ... by(anio) stat(mean p50 n)`, para tener promedio y mediana de esta muestra.
- [ ] **Estandarizar las variables de ingreso.** Hoy conviven `ingreso_rel` (% del promedio del año), `ingreso_mes24` (lleva cada año al promedio de 2024, sin IPC) y `ln_ingreso` (nominal, con efecto de año), y es confuso. Idea: deflactar todo por IPC a pesos de 2024 en el `02` y en el `08a`, y dejar un solo conjunto de Y para empleo, ingreso con ceros y ln. Decidir cuáles quedan. Con esto, los CLP 12 mil dejan de ser una cuenta aproximada.
- [ ] Sigue pendiente de antes: 21 (todas las mujeres), 14 (exposición), 23 (Callaway-Sant'Anna y UV con stock como control).
