# Resultados extracción 30/09/2026

## ⚠️ Para el lunes en el RIS: errores a corregir
1. **Falta una línea en fertilidad y laboral:** las nunca tratadas quedan con `rel_t1_bin` missing → Stata las bota → las regresiones corren solo con tratadas (sin grupo de control). Todos los event studies de fertilidad, ingreso y meses de esta semana son inválidos. Antes de `tab rel_t1_bin, gen(d)`:
   ```stata
   keep if muestra_t1 == 1
   replace rel_t1_bin = -1 if missing(rel_t1)
   ```
   Chequeo: `count if missing(d1)` = 0; N ≈ 48 mil UV-años, ≈ 4.400 clusters.
2. **Fertilidad:** a `eventstudyinteract` le falta `vce(cluster id_uv_2024)`.
3. **Laboral:** ingreso en pesos nominales → usar log o deflactar (ver sección 3).
4. **Laboral, balance:** typo `foreach v of global bad_ind` → debe ser `bal_ind` (hoy el loop no imprime nada).
5. **Balance (ambos do-files):** los decimales se cortan y la densidad de niños sale 0.06 vs 0.06. Antes del loop de balance:
   ```stata
   replace densidad_ninos_uv = densidad_ninos_uv * 100   // niños 0-5 por cada 100 habitantes → 5.90 vs 6.31
   ```
   y cambiar `%12.2f` → `%12.3f` en la columna ponderada "No trat." (la natalidad sale 0.06).

## 1. Primera etapa (matrícula)
Fuentes: `eventstudy_primera_etapa.png` (S-A ponderado) + `../primera_etapa.txt` (TWFE y S-A sin ponderar).

**Conclusiones**
- Abrir un jardín sube la matrícula de niños 0–4 en la UV: **≈ +2 pp sin ponderar / ≈ +1 pp ponderado**, sobre una base de ≈33% (≈ +6% / +3% relativo). Aparece en k=0 y persiste hasta k=5.
- El efecto es menor ponderado → el jardín mueve más a las UVs chicas.
- TWFE y S-A dan resultados parecidos: el sesgo por timing escalonado no cambia la conclusión.
- **Alerta:** k=−2 es negativo y significativo en las 4 versiones (≈ −1 a −2 pp) → la matrícula empieza a subir antes de la apertura registrada.
- El tamaño es chico pero esperable (denominador amplio, niños de 4 ya en pre-kínder, sustitución). Implicancia: los efectos en fertilidad y empleo a nivel UV van a ser pequeños.

**Chequeos para el RIS**
- [ ] `tab rel_t1_bin` → confirmar que k llega solo hasta +5 (si no, faltan dummies).
- [ ] Guardar la tabla del S-A ponderado (hoy solo está la figura).
- [ ] Revisar cómo se construye `g1` desde `fec_inc_estab` (¿apertura registrada con 1 año de rezago?).
- [ ] k=−2 desagregado por cohorte `g1`.
- [ ] Efecto por edad del niño (0–1, 2–3, 4).
- [ ] `sum n_ninos, detail` en UVs tratadas (+ cupos por jardín si existen) → dimensionar el techo del efecto.
- [ ] `duplicates report run_alu_inn anio` después del merge con matrícula.

## 2. Fertilidad
Fuentes: `muestra_fert_descript.do`, `muestra_fert_desc.txt`, `0_natalidad_descript.png`, `1_eventstudy_natalidad(_TWFE).png`.

**Conclusiones**
- Descriptivo: la natalidad cae de ≈5,7% a ≈3,1% entre 2014 y 2024, y tratadas y nunca tratadas van prácticamente juntas (tendencias paralelas en crudo ✔).
- Balance 2014: las mujeres se parecen; las UVs tratadas son ≈2× más grandes (dif. normalizada ≈0,4 en población y n_mujeres). Lo absorben los EF de UV.
- **Las regresiones no son válidas todavía:** usan solo las 444 UVs tratadas (N = 4.753). Las nunca tratadas se caen porque `rel_t1_bin` queda missing (falta el `replace ... = -1 if missing(rel_t1)` que sí está en primera etapa). Sin grupo de control:
  - TWFE: la pendiente lineal de +0,005 a −0,014 es un artefacto (una tendencia en k no se identifica sin control).
  - S-A: `d15` omitido y SE sin cluster.
- No leer efectos de fertilidad hasta re-correr.

**Corrección para el RIS** (antes de `tab rel_t1_bin, gen(d)`)
```stata
keep if muestra_t1 == 1
replace rel_t1_bin = -1 if missing(rel_t1)
count if missing(d1)    // debe ser 0 después de generar las d
```
- [ ] Agregar `vce(cluster id_uv_2024)` a `eventstudyinteract`.
- [ ] Verificar que N ≈ 48 mil UV-años y clusters ≈ 4.400.
- [ ] Mismo bug en `muestra_laboral_descript.do` (443 clusters) → corregir igual.

## 3. Mercado laboral (revisión rápida, solo ingresos)
Fuentes: `muestra_laboral_descript.do`, `muestra_laboral_desc_2.txt`, `ingreso_anual_tendencia.png`, `d_ingreso_anual_*.png`, `1_eventstudy_ingresos(_TWFE).png`.

**Conclusiones**
- **Event studies (TWFE y S-A): no válidos**, mismo bug que fertilidad (443 UVs, solo tratadas). Ignorar el "efecto" positivo de k=4 a 6 en S-A.
- **Válido pero solo referencial:** `reghdfe ... post_t1` (1,84 M obs, 4.542 UVs, sí incluye nunca tratadas):
  - Ingreso: +87 mil CLP/año, no significativo (p=0,29), sobre una base de ≈6,9 M (≈ +1%).
  - Meses trabajados: +0,06 meses (p=0,03), sobre una base de ≈9,1 (≈ +0,7%).
  - Es TWFE estático con timing escalonado → puede tener sesgo; sirve solo como orden de magnitud.
- Descriptivos: tratadas y nunca tratadas van paralelas en ingreso (general y por cohorte) ✔.
- **Ojo con la muestra:** ambas variables solo existen para mujeres con registro formal (≈ mitad de las obs con ingreso missing). Hoy se mide el margen intensivo; no captura la entrada al empleo, que es el efecto esperable del jardín.
- El ingreso casi se triplica en 2014–2024 → parece nominal y/o con cambio de composición o fuente (`renta_imponible` vs `monto_dep+indep`).

**Chequeos para el RIS**
- [ ] Misma corrección de `rel_t1_bin` + `keep if muestra_t1 == 1` → re-correr los event studies.
- [ ] `tabstat tiene_ingreso, by(anio)` por grupo (ya está en el do-file, falta extraer el output).

**Missing de ingreso: ¿informal o no trabaja?**
Propuesta: el resultado principal es **empleo formal** (`= 1` si tiene renta/cotización, `= 0` si no). Es exactamente lo que miden los registros administrativos y no requiere adivinar. El RSH (`per_fic_trabaja`) se usa para validar:
```stata
gen empleo_formal = !missing(ingreso_anual) & ingreso_anual > 0
tab per_fic_trabaja empleo_formal, row    // % de las que dicen trabajar sin registro formal ≈ informalidad
tab anio empleo_formal, row               // debe ser estable; un salto en un año = problema de cobertura de la base, no empleo
```

**Ingreso nominal → dos opciones**
- **Log (recomendado, lo más simple):** los EF de año absorben la inflación, porque es un factor común a todas; el coeficiente se lee como ≈ % de cambio. Solo usa a las mujeres con ingreso > 0 (margen intensivo).
  ```stata
  gen ln_ingreso = ln(ingreso_anual) if ingreso_anual > 0
  ```
  Ojo: crearla a nivel mujer y colapsar después (media del log, no log de la media).
- **Deflactar** (para reportar montos en pesos de 2024): IPC promedio anual de INE/Banco Central.
  ```stata
  gen ipc = .
  replace ipc = ___ if anio == 2014   // ... hasta 2024
  gen ingreso_real = ingreso_anual * (ipc_2024 / ipc)
  ```
