# Resumen de resultados: extracción 04/11/2026

Para la reunión del jueves 05/11. Se va completando sección por sección.

Promedios post y pruebas conjuntas calculados con las matrices V de la extracción (`revisar_extraccion.py`: las 22 V calzan con sus coeficientes).

---

## Errores y advertencias

| # | Dónde | Qué pasa | Qué afecta | Para mañana |
|---|---|---|---|---|
| 1 | `08a` l.112 | El bloque "ln ingreso" balanceado estima `ingreso_rel` | `sa_indm_entr_bal ln_ingreso` es una copia de `ingreso_rel` | No usar |
| 2 | `08b` l.130 y l.137 | `nac_acum` h1 y h2 corren con `if grupo_h == 0`; además l.121, 128 y 135 calculan la media con `tuvo_hijo` | `nac_acum` h1 y h2 son copias de h0; la media de los tres está mal. `tuvo_hijo` h0, h1 y h2 están bien | No usar `nac_acum` por grupo con EF de mujer |
| 3 | `03` l.73 | `if g1` deja fuera a las nunca tratadas (`g1 == 0` es falso) | `sa_w_bal` de primera etapa: N = 1.513 y 221 UV, sin controles | No usar |
| 4 | `08a` l.30, `08b` l.23 y `24` l.23 | `gen uv_fija` queda en `float` y pierde dígitos del código de UV | Se fusionan UV de códigos cercanos: quedan unos 1.600 clusters en vez de unos 4.400 | Coeficientes correctos; errores estándar provisorios |
| 5 | `sa_w_e14_bal hijos_pre2014` k = 9 | EE prácticamente cero (t absurdo) | Ese punto; los t de ese placebo balanceado no son confiables | No usar |
| 6 | `tablas.txt` | Trae 4 de los 8 elementos: faltan `sum ingreso_total` y `tab g1_f bal` del 08a, y `tab g1_f bal` y `tab grupo_h` del 08b | No hay conversión a pesos propia para EF de mujer | Usar la conversión del modelo UV-año, como aproximación |

**Detalle del error 4.** El `float` de Stata guarda enteros exactos solo hasta 16,7 millones, y los códigos de UV llegan a 163 millones. Probado con `data/final/base_cobertura_cp.dta`: las 4.493 UV de `muestra_t1` quedan en 1.629 valores distintos, cerca de los 1.597–1.600 `n_uv` de los modelos con EF de mujer. 228 de los 276 grupos con alguna tratada mezclan tratadas y control.

- No cambia los coeficientes: la cohorte sale de `g1[1]` y el efecto fijo es la mujer. `uv_fija` solo se usa para el cluster.
- Sí cambia los errores estándar. No se puede saber en qué dirección sin volver a correr.
- Arreglo: `gen double uv_fija = id_uv_2024[1]`. Es la misma línea en el `24`, que todavía se puede corregir antes de usarlo.

**Otros puntos**
- `RIS/20261006/20261104/` es una copia idéntica de esta carpeta, probablemente pegada ahí por error.
- `coefs_fert_entr_v60cw.csv` se llama distinto en el correo de extracción (`coefs_fert_v60cw.csv`). El contenido es el correcto (314 x 8).
- No vienen en esta extracción: 21 (todas las mujeres), 14 (exposición), 23 (Callaway-Sant'Anna y UV con stock como control), 24 (UV desde 2022), vecinas, HonestDiD.

---

## 1. Panorama

### Diseño

- **Tratamiento:** la UV recibe su primer jardín público (JUNJI o Integra) en el año `g1`.
- **Muestra de UV:** solo UV sin jardín en 2014 (`muestra_t1`).
- **Control:** UV que nunca reciben jardín (`g1 == 0`).
- **Estimador:** Sun-Abraham, con cluster por UV. Marco: Baker et al. (JEL), sección 5.2, supuesto PT-GT-NEV.
- **k:** años desde la apertura. La referencia es k = −1.

| Cohorte | 2015 | 2016 | 2017 | 2018 | 2019 | 2020 | 2021 | 2022 | 2023 | 2024 | Total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| UV tratadas | 51 | 61 | 75 | 48 | 39 | 7 | 15 | 11 | 8 | 4 | 319 |

Quién identifica los extremos:
- **k = 9:** solo la cohorte 2015 (51 UV).
- **k = 8:** cohortes 2015 y 2016.
- **k ≤ −5:** solo cohortes 2019 en adelante (84 UV), y sus años más antiguos son 2014–2015, donde la UV viene anclada a 2016.

### Tres versiones de cada resultado

| Versión | Unidad | UV de la mujer | Mujeres | Qué responde |
|---|---|---|---|---|
| **Principal** (`sa_w`) | UV-año, ponderado | La UV donde vive ese año | Entran el primer año que aparecen | ¿Qué cambia en la UV? Incluye a quienes llegan o se van |
| **Balanceada** (`sa_w_bal`) | UV-año, ponderado | La UV donde vive ese año | Solo observadas los 11 años en UV de la muestra | Saca la entrada al RSH, pero no las mudanzas |
| **EF de mujer** (`sa_indm`) | Mujer-año | Fija: la primera UV válida, antes de la apertura | Cada mujer contra sí misma | Efecto en las mismas mujeres (ITT). Saca la composición; mudanzas y errores de UV atenúan |

### Qué mide cada variable

| Variable | Definición | Cómo se lee el coeficiente |
|---|---|---|
| `tasa_matricula` | Proporción de niños de 0 a 4 años, hijos de madres v60, con matrícula parvularia ese año | 0,029 = +2,9 puntos porcentuales |
| `empleo_formal` | 1 si la madre tiene ingreso formal mayor que 0 en el año (renta imponible; si falta, cotizaciones). Basta con algún ingreso en el año | 0,011 = +1,1 pp de madres con empleo formal |
| `ingreso_rel` | 100 × ingreso anual (con ceros) / promedio de la muestra ese año | 3,6 ≈ ingreso 3,6% del promedio más alto. 1 punto ≈ $4.235 al mes |
| `ingreso_mes24` | Mismo ingreso con ceros, en pesos mensuales a nivel 2024. **Se ajusta por el promedio de ingresos de la muestra, no por IPC** | Pesos al mes |
| `ln_ingreso` | Log del ingreso anual, solo con ingreso mayor que 0 | 0,024 ≈ +2,4%, entre quienes tienen ingreso. Margen intensivo; la muestra puede cambiar con el tratamiento |
| `tuvo_hijo` | 1 si la mujer tuvo un hijo ese año (v60, 18–35 años en 2014) | −0,002 = −0,2 pp, sobre 5,9 nacimientos por 100 mujeres al año |
| `nac_acum` | Nacimientos acumulados desde el primer año observado | Hijos por mujer |

### Muestras

| Base | Mujeres | Observadas los 11 años |
|---|---|---|
| Madres v60, todas las UV (`09`) | 1.659.254 | 60,9% |
| Madres v60, UV de la muestra (`02`) | 816.836 | 30,2% (246.961) |
| Mujeres v60, 18–35 en 2014, UV de la muestra (`01`) | 1.022.069 | 29,5% (301.834) |

299 de las 319 UV tratadas tienen datos desde 2014; 12 aparecen recién en 2022.

### Resultados en una tabla

Efecto promedio k = 0 a 9 (promedio simple de los coeficientes, EE con la V). "pre" es el p-valor de la prueba conjunta: todos los k < −1 / sin el bin k ≤ −5.

| Variable | Versión | Media control | Efecto | EE | % de la media | p pre (todos / sin k ≤ −5) |
|---|---|---|---|---|---|---|
| Matrícula | Principal | 34,0% | **+2,9 pp** | 0,42 | +8,5% | 0,81 / 0,68 |
| Empleo formal | Principal | 54,6% | **+1,1 pp** | 0,30 | +2,0% | 0,15 / 0,58 |
| | Balanceada | 53,4% | **+1,5 pp** | 0,35 | +2,7% | 0,18 / 0,87 |
| | EF mujer* | 54,7% | +0,7 pp | 0,32 | +1,2% | 0,06 / 0,97 |
| | EF mujer balanceada* | 54,2% | +0,9 pp | 0,33 | +1,6% | 0,10 / 0,93 |
| Ingreso con ceros | Principal | 99,6 | **+3,6** (≈ $15.400/mes) | 0,85 | +3,7% | 0,13 / 0,93 |
| | Balanceada | 101,6 | +3,0 (≈ $12.600/mes) | 1,03 | +2,9% | 0,04 / 0,65 |
| | EF mujer* | 99,4 | −0,1 | 0,91 | −0,1% | 0,02 / 0,64 |
| | EF mujer balanceada* | 101,0 | +0,7 | 1,07 | +0,7% | 0,002 / 0,14 |
| Ln ingreso | Principal | 14,92 | +2,4% | 1,0 | | 0,20 / 0,15 |
| | Balanceada | 14,96 | +0,9% | 1,5 | | 0,20 / 0,18 |
| | EF mujer* | 14,94 | −1,4% | 1,1 | | 0,000 / 0,004 |
| Tuvo hijo (18–35) | Principal | 5,9% | −0,23 pp | 0,13 | −3,9% | 0,25 / 0,20 |
| | Balanceada | 5,8% | −0,16 pp | 0,15 | −2,7% | 0,27 / 0,22 |
| | EF mujer* | 5,9% | −0,15 pp | 0,13 | −2,6% | 0,01 / 0,006 |
| | EF mujer balanceada* | 6,1% | −0,26 pp | 0,14 | −4,3% | 0,01 / 0,006 |
| Nac. acumulados (18–35) | Principal | 0,376 | +0,009 | 0,006 | +2,4% | 0,12 / 0,25 |
| | EF mujer* | 0,374 | +0,006 | 0,004 | +1,7% | 0,000 / 0,01 |

\* EE provisorios (error 4). Los pesos de la balanceada salen de `ingreso_mes24`.

### Cambios respecto a la extracción del 28/10

| | 28/10 | 04/11 |
|---|---|---|
| Matrícula, promedio post | +3,5 pp | +2,9 pp |
| Matrícula, k = −2 | +0,9 pp | +0,3 pp (t = 1,0) |
| Empleo, promedio post | +1,6 pp | +1,1 pp |
| Ingreso con ceros, promedio post | +4,6 ($19.800/mes) | +3,6 ($15.400/mes) |

Las muestras cambiaron: crosswalk corregido y madres que entran desde su primer año en el RSH.

### Patrones a revisar en detalle

1. **Primera etapa sólida:** salta en k = 0 y se mantiene en torno a +3 pp. Sin pre-tendencias.
2. **Empleo:** sube gradualmente en las tres versiones. Con EF de mujer es cerca de 40% menor que en la versión principal.
3. **Ingreso:** el efecto cae cerca de 70% con EF de mujer (k = 0–7: +3,6 a +1,0, no significativo). Es el resultado más sensible a la especificación.
4. **Bin k ≤ −5:** explica casi todos los rechazos de la prueba de pre-tendencias en empleo e ingreso.
5. **Fertilidad:** sin efecto robusto. `tuvo_hijo` es levemente negativo y `nac_acum` levemente positivo.
6. **`nac_acum` y `tuvo_hijo`:** ver abajo.

### Por qué `tuvo_hijo` baja y `nac_acum` sube

Con las mismas mujeres, el cambio en los acumulados entre k = −1 y k es la suma de los nacimientos de esos años. Entonces (derivación propia, no viene de la extracción):

> coef `nac_acum`(k) ≈ suma de coef `tuvo_hijo`(0 a k) + (k + 1) × γ

donde γ es la diferencia en la **tasa** anual de nacimientos entre tratadas y control en k = −1. `tuvo_hijo` descuenta esa diferencia, porque se normaliza a k = −1; `nac_acum` no la descuenta y la va sumando cada año.

Con EF de mujer, el γ implícito es muy estable en los primeros años: 0,27, 0,26, 0,26, 0,26 y 0,24 pp (k = 0 a 4). Después varía, en parte porque cambian las cohortes.

⇒ No sirve como prueba. Ver "Por qué `tuvo_hijo` es negativo y `nac_acum` positivo" en la sección 5.

---

## 2. Primera etapa

**Pregunta:** cuando abre el primer jardín en una UV, ¿aumenta la matrícula de los niños que viven ahí?

**Y (`tasa_matricula`):** por UV y año, proporción de los niños de 0 a 4 años, hijos de madres v60, con matrícula parvularia ese año en cualquier jardín.
- Mide matrícula **neta**: un niño que se cambia de otro jardín al nuevo no la mueve.
- Se asigna por la UV donde vive la madre, no por dónde está el jardín.
- Incluye a todos los niños de 0 a 4, aunque nunca usen el jardín nuevo (es un efecto sobre la UV, no sobre los que asisten).

**Método (Sun-Abraham, Baker et al. 5.2).** Para cada cohorte `g` y cada k:

> (tasa de la cohorte en g+k − tasa en g−1) − (lo mismo en las nunca tratadas, en esos años)

Luego promedia entre cohortes, según su peso en cada k. Solo compara con nunca tratadas, así que evita usar UV ya tratadas como control, el problema de TWFE. Pondera por número de niños: es el efecto para el niño promedio, no para la UV promedio.

**Resultado principal** (4.422 UV, 45.788 UV-años, media control 34,0%):

| k | −5 | −4 | −3 | −2 | −1 | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| pp | 0,42 | 0,47 | 0,08 | 0,31 | ref. | 2,72 | 3,26 | 3,29 | 3,02 | 3,00 | 3,05 | 3,10 | 2,88 | 2,28 | 2,43 |
| EE | 1,12 | 0,61 | 0,41 | 0,31 | | 0,40 | 0,42 | 0,44 | 0,47 | 0,49 | 0,53 | 0,59 | 0,59 | 0,81 | 1,30 |

| Promedio | Efecto | EE | IC 95% |
|---|---|---|---|
| k = 0 a 7 | **+3,0 pp** | 0,38 | 2,3 a 3,8 |
| k = 0 a 9 | +2,9 pp | 0,42 | 2,1 a 3,7 |

Uso k = 0 a 7 como cifra central: es lo que usaba el ppt, y k = 8 y 9 dependen de una o dos cohortes.

### Cómo decirlo en palabras

**Versión corta:**

> "Cuando abre el primer jardín en una unidad vecinal, la matrícula de los niños de 0 a 4 años sube 3 puntos porcentuales, de 34% a 37%. Sube el mismo año de la apertura y se mantiene."

**Versión completa, para explicar el coeficiente:**

> "Comparadas con las UV que nunca reciben un jardín, y respecto del año anterior a la apertura, en las UV que reciben su primer jardín la proporción de hijos de 0 a 4 años de madres vulnerables con matrícula parvularia aumenta 3 puntos porcentuales. Sobre una base de 34%, es un aumento de cerca de 9%, unos 3,6 niños más matriculados por UV. El año antes de abrir, las tratadas parten en 31,7% y las control en 33,0%."

**De dónde sale 3,6 niños:** 3,0 pp × 117 niños por UV tratada. Solo cuenta hijos de madres v60.

**Validez**
- **Pre-tendencias:** ningún coeficiente previo es significativo; prueba conjunta p = 0,81.
- **Sin la cohorte 2015:** +3,0 pp (k = 0 a 7). No depende de esa cohorte.
- **Datos crudos:** brecha tratadas − control de −1,3 pp en k = −1 a +1,4 pp en k = 0: un salto de 2,7 pp, igual al coeficiente. En promedio post la brecha es +1,9 pp (k = 0 a 7). No hace falta el modelo para ver el efecto.
- **Niveles:** las tratadas parten más abajo (31,7% vs 33,0%) y terminan más arriba. El DiD no exige niveles iguales, solo tendencias paralelas.
- **Balanceada:** no se usa (error 3).

**Cambio respecto al 28/10:** bajó de +3,6 a +3,0 pp (k = 0 a 7), y k = −2 bajó de +0,9 a +0,3 pp. Las dos caídas son casi iguales (0,54 y 0,57 pp). Lectura posible, sin comprobar: todo se mide contra k = −1; si ese año estaba algo bajo por el crosswalk, inflaba todos los coeficientes post y k = −2 a la vez.

⇒ La primera etapa es clara, inmediata y estable. Es modesta en número de niños, lo que no descarta niños que se cambian de jardín, que esta variable no captura.

Gráficos: `graficos/pe_01_principal.png`, `pe_02_comparacion.png`, `pe_03_niveles.png`.

## 3. Empleo

### Cómo decirlo en palabras

**Versión corta:**
> "Cuando abre el primer jardín en una unidad vecinal, el empleo formal de las madres vulnerables sube 1 punto porcentual, de 54,6% a 55,6%. El efecto parte en cero y crece gradualmente, hasta 2,2 puntos en el séptimo año."

**Versión completa, para explicar el coeficiente:**
> "Comparadas con las UV que nunca reciben un jardín, y respecto del año anterior a la apertura, en las UV que reciben su primer jardín la proporción de madres vulnerables con ingreso formal en el año aumenta en promedio 1 punto porcentual durante los primeros ocho años. Sobre una base de 54,6%, es un aumento de cerca de 2%, unas 2,5 madres más con empleo formal por UV. El año antes de abrir, tratadas y control parten igual, en 54,8%."

### Cómo se mide Y
`empleo_formal` vale 1 si la madre tiene **algún ingreso formal en el año** (renta imponible o, si falta, cotizaciones), y 0 si no.

- **No mide intensidad:** con un mes de ingreso ya vale 1, así que no dice cuántos meses ni qué jornada trabaja.
- **No ve lo informal:** una madre que trabaja informalmente vale 0.
- **Incluye a todas las madres de la UV:** también a las que no usan el jardín y años en que no tienen hijos pequeños. Por eso el efecto en quienes sí lo usan tiene que ser mayor que 1 punto.

### Cómo leer el gráfico
`graficos/lab_01_empleo.png`: se lee igual que la primera etapa, pero la forma es otra. La matrícula salta de inmediato; **el empleo no salta, crece**.

| k | −5 a −2 | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|---|
| Efecto (pp) | sin diferencias significativas | 0,09 | 0,52 | 0,61 | 0,83 | 1,04 | 1,24 | 1,44 | 2,20 |

### Por qué es creíble
1. **Sin pre-tendencias:** la prueba conjunta da p = 0,15, y sin el bin k ≤ −5, p = 0,58.
2. **Se ve dentro de cada cohorte:** las cohortes grandes están planas antes de abrir y suben después, tanto las que parten bajo el control como las que parten sobre él. Por eso no parece simple convergencia.

| Brecha cruda (pp) | k = −2 | −1 | 0 | 2 | 4 | 6 |
|---|---|---|---|---|---|---|
| 2016 (61 UV) | −1,5 | −2,1 | −1,7 | −1,4 | −1,0 | −0,3 |
| 2017 (75 UV) | −1,7 | −1,9 | −2,0 | −1,6 | −0,6 | +0,7 |
| 2018 (48 UV) | +2,2 | +2,2 | +2,2 | +2,9 | +4,2 | +3,6 |

3. **El número de hijos pequeños por madre no cambia:** `n_hijos_menor5` da −0,002 en promedio sobre 0,52, y ningún k es significativo (`coefs_lab_entrada.csv`, sin V para prueba conjunta). Ayuda con la duda de ciclo de vida del 28/10, pero solo mira esa variable: no muestra que no haya cambiado quiénes viven en la UV.
4. **No depende de la cohorte 2015:** sin ella da +0,96 pp.

**Buena noticia respecto del ppt:** antes los coeficientes previos eran negativos y parecía una línea que venía subiendo desde antes. Ahora están en torno a cero, aunque el efecto bajó de +1,5 a +1,0 pp.

### Las tres versiones
`graficos/lab_02_empleo_versiones.png`:

| Promedio k = 0 a 7 | Efecto | EE |
|---|---|---|
| Principal (UV donde vive) | **+1,00 pp** | 0,28 |
| Balanceada (11 años) | +1,21 pp | 0,33 |
| EF de mujer (UV fija) | +0,55 pp | 0,29* |
| EF de mujer balanceada | +0,69 pp | 0,29* |

\* Provisorios, por el error del `float`.

Las cuatro son positivas y graduales. Con EF de mujer el efecto es cerca de 45% menor, y hay dos explicaciones que todavía no podemos separar:

- **Composición (el principal está inflado):** el principal incluye a madres que llegan a la UV después de la apertura, y quizás llegan las que trabajan más.
- **Atenuación (el EF está achicado):** con UV fija, una madre que se mudó o tiene mal asignada la UV cuenta como tratada sin serlo.

El `24` (UV fija desde 2022) es la prueba para distinguirlas, y por eso importa que quedó en el TODO.

### Lo que te pueden preguntar
- **"¿Por qué el empleo es gradual si la matrícula salta?"** Encontrar trabajo formal toma tiempo, y las madres con recién nacidos usan el jardín más tarde. Son hipótesis, no resultados. Además, los k altos solo vienen de cohortes antiguas (k = 7 es 2015–2017), así que el salto de k = 6 a 7 puede ser en parte cambio de cohortes.
- **"¿2,5 madres más con empleo por 3,6 niños más matriculados no es demasiado?"** Sí, son 0,7 madres por niño, y creo que es la pregunta más difícil de esta sección. Una explicación es que la matrícula neta no ve a los niños que se cambian a un jardín más cercano, aunque eso igual ayuda a la madre. No está comprobado, y es una cuenta aproximada, no una estimación de variables instrumentales.
- **"¿Es significativo con efecto fijo de mujer?"** Está en el límite (t ≈ 1,9, y 2,4 en la balanceada), con errores estándar que se están reestimando. Yo diría "se mantiene positivo, algo más chico", sin afirmar significancia.
- **"¿Qué pasa con el k = −5, que está por sobre cero?"**
  - **Qué es:** no es un año, es un bin que junta todos los años desde 5 antes de abrir hacia atrás. Solo lo identifican las cohortes 2019 en adelante (84 de 319 UV), con sus años más antiguos, incluidos 2014–2015, donde la UV viene anclada a 2016.
  - **Cuánto da:** +0,90 pp en la principal (t = 1,6), no significativo. Sí lo es en la balanceada (+1,78, t = 2,4) y con EF de mujer (+1,44, t = 2,8; EE provisorio), y en esa versión tiene el resto de los coeficientes previos planos (k = −4 a −2: 0,06 a 0,10).
  - **Qué significa el signo:** positivo quiere decir que en esos años las tratadas estaban más arriba, en relación al control, que en k = −1: venían **perdiendo** terreno antes de abrir. Es lo contrario de "ya venían subiendo". Si esa caída siguiera, el efecto estaría subestimado; si fue una baja transitoria que después se revierte, parte del alza post podría ser esa recuperación, y el efecto estaría sobreestimado. Con estos datos no se puede distinguir.
  - **De dónde viene:** de pocas UV. En la brecha cruda, de k = −5 a k = −1, la cohorte 2019 está plana (+2,5 a +2,6). Las que caen son 2022 (+3,3 a +1,6; 11 UV) y 2023 (+5,3 a +0,8; 8 UV), mientras 2020 y 2024 suben. Sus k = −1 caen en 2021 y 2022, justo alrededor del salto del crosswalk, pero no sabemos si esa es la causa. Esta cuenta usa solo el año exacto k = −5, no todo el bin.
  - **Por qué no cambia la conclusión:** sin este bin la prueba conjunta pasa de p = 0,15 a p = 0,58 (y con EF de mujer, de 0,06 a 0,97). Además, en la cuenta cruda dentro de cada cohorte, usando solo 2016–2019 el efecto post es casi igual al de todas las cohortes (k = 1 a 3: 0,53, 0,65 y 0,84 contra 0,46, 0,61 y 0,86).
  - **Cómo decirlo:** "El bin k ≤ −5 viene de pocas UV y de los años con datos más débiles. Lo mostramos, no lo escondemos: va en dirección contraria a una tendencia previa al alza, y el resto de los coeficientes previos está plano. Falta acotarlo con HonestDiD."

### Un cuidado con el gráfico de niveles
En `graficos/lab_03_empleo_niveles.png` usa **solo el panel izquierdo**. El derecho muestra una brecha que cae de +2,9 a 0 antes de abrir, pero es un artefacto: cada k mezcla cohortes distintas. La lectura correcta es la tabla por cohorte de arriba.

### Detalle técnico

**Muestra:** madres v60 (algún año con hijo menor de 5), desde su primer año en el RSH. 4.448 UV, 46.427 UV-años, media control 54,6%, ponderado por madres, controla edad. 0,52 hijos menores de 5 por madre en promedio. 245 madres por UV tratada (k = 0–7).

| k | −5 | −4 | −3 | −2 | −1 | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| pp | 0,90 | −0,32 | −0,10 | 0,12 | ref. | 0,09 | 0,52 | 0,61 | 0,83 | 1,04 | 1,24 | 1,44 | 2,20 | 1,75 | 1,47 |
| t | 1,6 | −0,7 | −0,4 | 0,6 | | 0,5 | 1,9 | 2,0 | 2,3 | 2,8 | 3,2 | 3,3 | 3,9 | 3,1 | 1,8 |

| Promedio (pp, EE) | k = 0–2 | k = 5–7 | k = 0–7 |
|---|---|---|---|
| Principal | 0,41 (0,23) | 1,63 (0,43) | 1,00 (0,28) |
| Balanceada | 0,62 (0,24) | 1,74 (0,49) | 1,21 (0,33) |
| EF de mujer* | 0,25 (0,21) | 0,96 (0,44) | 0,55 (0,29) |
| EF de mujer balanceada* | 0,15 (0,21) | 1,25 (0,45) | 0,69 (0,29) |

Otras cohortes (brecha cruda, pp):

| Cohorte (UV) | k = −3 | −2 | −1 | 0 | 2 | 4 | 6 |
|---|---|---|---|---|---|---|---|
| 2015 (51) | | | −3,7 | −3,9 | −2,2 | −2,3 | −0,9 |
| 2019 (39) | 2,1 | 2,7 | 2,6 | 3,0 | 3,9 | 2,9 | |

Las cohortes 2020–2024 son muy chicas y ruidosas (2020 tiene 7 UV y ya venía subiendo).

**Niveles:** 54,8% tratadas y 54,8% control en k = −1. Balance 2014 ponderado: dif. estandarizada 0,03.

**Sobre la atenuación:** el salto de 2021–22 podría afectar a 15–18% de las mujeres (inferido, no medido), y además hay mudanzas de 4–9% al año que se acumulan. No está cuantificada.

**Cambio respecto al 28/10:** k = −2 pasó de −0,64 a +0,12.

## 4. Ingresos

**Corrección a la sección 1:** "el efecto desaparece con EF de mujer" salía del promedio k = 0–9 (−0,1), que arrastran k = 8 y 9 (−1,9 y −6,8, una o dos cohortes). Con k = 0–7 es +1,0, no significativo. El efecto cae cerca de 70%, pero no es exactamente cero.

**Corrección de niveles:** los "$440 mil" y "$790 mil de 2014" que se usaron antes estaban mal. `ingreso_mes24` lleva cada año al promedio de 2024, así que no sirve para decir con cuánto se partía. Los niveles correctos están en "Niveles de ingreso", más abajo.

### Cómo decirlo, gráfico por gráfico

**1. Ingreso con ceros, en pesos** (`graficos/lab_04_ingreso_pesos.png`)
> "Este gráfico mide el ingreso formal de todas las madres vulnerables de la UV, contando con cero a las que no tienen ingreso. Tratadas y control parten casi iguales: en 2014, unos 165 mil pesos al mes de ese año, porque casi la mitad no tiene ingreso formal. Cuando abre el primer jardín, el ingreso sube gradualmente. En promedio, en los primeros ocho años es 3,6% más alto. A ingresos de 2024, con un promedio de cerca de 420 mil pesos, son unos 15 mil pesos al mes, y llega a unos 32 mil siete años después de abrir. Antes de la apertura no hay diferencias significativas."

⇒ El ingreso promedio de las madres de la UV sube gradualmente: 3,6%, unos 15 mil pesos al mes a ingresos de 2024.

**2. Ln ingreso** (`graficos/lab_07_ln_ingreso.png`)
> "Este gráfico mira solo a las madres que tienen ingreso formal ese año. Tratadas y control parten iguales: en 2014, cerca de 300 mil pesos al mes de ese año, no muy lejos del salario mínimo de entonces. Su ingreso anual sube en promedio 2,65% en los primeros ocho años, unos 20 mil pesos al mes a ingresos de 2024, y el efecto se vuelve significativo desde el cuarto año. Hay que leerlo con cuidado: no es salario, porque también sube si trabajan más meses, y el grupo de madres con ingreso puede cambiar."

⇒ Entre las madres con ingreso, el ingreso anual sube cerca de 2,65%, sin poder separar salario de meses trabajados.

**3. Ingreso con ceros, tres versiones** (`graficos/lab_05_ingreso_versiones.png`)
> "Este gráfico compara el mismo resultado en tres versiones. En azul, la UV donde vive la madre cada año: +3,6%. En gris, solo madres observadas los once años, también en la UV donde viven: +3,0%. En naranjo, las mismas mujeres, siempre asignadas a la primera UV con la que aparecen en los datos: cerca de +1%, no significativo. Las tres van relativamente cerca hasta el cuarto año. Después, azul y gris siguen subiendo y naranjo deja de subir."

⇒ El efecto se reduce cerca de 70% al seguir a las mismas mujeres en su UV inicial: es menos robusto que el de empleo.

**4. Ln ingreso, tres versiones** (`graficos/lab_06_ln_ingreso_versiones.png`)
> "Aquí hacemos la misma comparación para las madres con ingreso, que en 2014 ganaban cerca de 300 mil pesos al mes de ese año. En la UV donde viven hay un aumento significativo de 2,65%. Baja a 1,5% en la versión balanceada y a 0,2% con las mismas mujeres, y estos dos últimos no son significativos. La estimación con efecto fijo además tiene pre-tendencias, y las madres que empiezan a trabajar pueden bajar el promedio, así que no podemos descartar una ganancia entre las que ya trabajaban."

⇒ Hay un aumento en la UV, pero no sabemos si es que las madres ganan más o que cambió quiénes viven ahí.

**5. Ingreso con ceros, solo efecto fijo de mujer** (`graficos/lab_08_ingreso_ef_mujer.png`)
> "Aquí seguimos a las mismas mujeres y comparamos a cada una consigo misma en el tiempo. Cada mujer queda asignada a la primera UV con la que aparece en los datos, aunque después se mude, y solo entra si la vemos antes de que abra el jardín. El ingreso sube en los primeros años, hasta cerca de 1,7% tres años después de abrir, y después deja de subir: queda entre 0,3 y 1,4%, sin ser significativo. En promedio, en los primeros ocho años es cerca de 1%, unos 4 mil pesos al mes a ingresos de 2024, y no es significativo."

⇒ En las mismas mujeres, el ingreso sube poco y no sigue creciendo: no replica el aumento de la UV.

- **Los puntos k = 2 y 3 son significativos por poco** (t = 2,0 y 2,1) y los EE son provisorios (error 4), así que no conviene afirmar que esos años son significativos.
- **Antes de abrir:** k = −4 a −2 están cerca de 0. k = −5 da +5,0 (t = 3,1), y con él la prueba conjunta rechaza (p = 0,015); sin él no (p = 0,64). Es el bin de k ≤ −5, con pocas UV y los años de datos más débiles.

**6. Ln ingreso, solo efecto fijo de mujer** (`graficos/lab_09_ln_ingreso_ef_mujer.png`)
> "Este gráfico sigue a las mismas mujeres, pero solo en los años en que tienen ingreso formal, y compara a cada una consigo misma. Partían, en 2014, de cerca de 300 mil pesos al mes de ese año. Después de que abre el jardín no se ve un aumento: los primeros cuatro años dan cerca de 0,8% y los siguientes cerca de cero, y ningún año es significativo. En promedio, en los primeros ocho años es 0,2%, es decir, nada. Eso sí, antes de abrir hay dos años con ingresos más altos, así que esta estimación es la menos confiable de todas."

⇒ Entre las mismas mujeres que ya trabajaban, no vemos que el ingreso suba.

- **Es el contraste más fuerte con el azul:** en la UV, el ingreso de las madres con ingreso sube 2,65% y crece con los años (hasta +5,0% en k = 7). Aquí se queda en cero todo el período.
- **Pero es la estimación menos confiable:** k = −5 da +5,3 y k = −4 da +2,5, los dos significativos. La prueba conjunta de pre-tendencias rechaza con el bin (p = 0,000) y también sin él (p = 0,004). Solo deja de rechazar si además se saca k = −4 (p = 0,78). Los EE son provisorios (error 4).
- **La muestra cambia con el tratamiento:** solo entran los años en que la mujer tiene ingreso. Si el jardín hace que entren a trabajar madres de menores ingresos, el promedio baja por composición, aunque ninguna gane menos. Por eso un cero aquí no prueba que nadie ganó más.
- **Conviene mostrarlo junto al de ingreso con ceros** (`lab_08`): ahí el efecto es positivo los primeros años, y la diferencia entre ambos es justamente el margen de entrada al empleo.

**7. Empleo formal, solo efecto fijo de mujer** (`graficos/lab_10_empleo_ef_mujer.png`)
> "Este gráfico sigue a las mismas mujeres, cada una asignada a la primera UV con la que aparece en los datos. Cerca de 55% tiene ingreso formal en el año. Después de que abre el jardín, el empleo sube de a poco: en promedio 0,55 puntos en los primeros ocho años, y llega a 1,4 puntos siete años después de abrir. Los puntos anteriores a la apertura están cerca de cero, salvo el primero, que agrupa los años más lejanos."

⇒ Con las mismas mujeres, el empleo también sube de a poco, aunque el efecto es cerca de la mitad.

- **Significancia:** el promedio no alcanza por poco el 5% (IC −0,02 a 1,11). Solo k = 7 es significativo por sí solo, y los EE son provisorios (error 4).
- **Pre-tendencias:** con k ≤ −5, p = 0,056; sin él, p = 0,97.

### Por qué a nivel UV sale significativo y a nivel mujer no

**No es falta de precisión.** Los EE son casi iguales (0,87 y 0,94): lo que cambia es el punto estimado, de +2,65 a +0,22.

**Son dos preguntas distintas.**
- **Nivel UV:** "¿suben los ingresos de las madres que viven en este barrio?" Incluye el cambio en quiénes viven ahí.
- **Nivel mujer:** "¿sube el ingreso de esta madre?" No deja entrar a nadie después de la apertura.

**Tres cosas cambian a la vez al pasar de una a otra**, y cada una puede mover el resultado:
1. **Quiénes entran:** a nivel UV entran mujeres nuevas cada año, por mudanza o por inscribirse por primera vez en el RSH. A nivel mujer, no.
2. **La UV es fija:** si una mujer se muda, a nivel UV cambia de grupo; a nivel mujer sigue contando como tratada aunque ya no viva ahí.
3. **La comparación:** a nivel UV se compara el promedio de la UV con su propio pasado; a nivel mujer, cada mujer consigo misma.

**Chequeo nuevo (`tend_lab_entrada`): las UV tratadas sí ganan mujeres.** Mujeres por UV respecto de k = −1, dividido por lo mismo en las UV control (1 = crecen igual):

| k | −3 | −2 | −1 | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Tratadas / control | 0,99 | 1,00 | 1,00 | 1,01 | 1,02 | 1,02 | **1,04** | **1,05** | **1,04** | **1,05** | **1,04** |

De k = −3 a −1 van iguales; después las tratadas suman cerca de 4–5% más mujeres, desde k = 3. Ojo: k = −5 y −4 (no están en la tabla) dan 0,95 y 0,98, y k = −5 es solo la cohorte 2019, así que no se puede afirmar que el crecimiento empieza recién con la apertura. Es una cuenta descriptiva con cohortes distintas en cada k. Cohortes 2015–2019, ponderado por UV. (El control crece 28% entre 2014 y 2024 por sí solo.)

**Pero no alcanza para explicar los 2,65%.** Si esas mujeres nuevas son 4,5% de las que tienen ingreso, tendrían que ganar 80% más que las que ya estaban. Si tienen el doble de empleo que las demás, serían 8,6% y tendrían que ganar 36% más. Son brechas muy grandes.

**La dilución tampoco alcanza sola.** Si la cuarta parte de las mujeres del EF ya no vive en su UV inicial y no recibe ningún efecto, un efecto real de 2,65 bajaría a cerca de 2,0, no a 0,2. Con 4–9% de mudanzas al año, de k = −1 a k = 5 habría entre 22% y 43% de mudadas (acumulado simple, sin contar regresos); incluso con 43% bajaría a cerca de 1,5.

**Entonces:** ninguna de las dos explicaciones por sí sola llega, así que lo más probable es que sea una mezcla, más el ruido de la UV anclada en 2016 para la mitad de la muestra. No podemos cerrar la pregunta con lo que tenemos.

**Dos cosas que relativizan todo lo anterior:**
- **La diferencia no está testeada:** que una estimación sea significativa y la otra no, no implica que sean distintas entre sí (Gelman y Stern, 2006). Los IC 95% son 0,9 a 4,4 (UV) y −1,6 a 2,1 (mujer), y se traslapan: un efecto de 1,5% es compatible con ambos. Para testear la diferencia (2,43) hace falta la covarianza entre las dos estimaciones, y cada regresión solo reporta su propia varianza. Si fueran independientes, EE 1,28, t ≈ 1,9. Comparten datos, así que probablemente el t es algo mayor, pero no lo podemos calcular. Esto vale para toda comparación entre versiones, incluidas las caídas en porcentaje ("cae 73%").
  - **No decir:** "el efecto cae significativamente" ni "desaparece".
  - **Decir:** "la estimación cae de 2,65% a 0,2%, pero los intervalos se traslapan: no podemos descartar que sea el mismo efecto".
- **La balanceada queda en medio** (+1,47, EE 1,18) y no es distinguible de ninguna de las dos. La descomposición es ruidosa.

**Cómo decirlo:**
> "Son dos preguntas distintas. A nivel de barrio preguntamos si suben los ingresos de las madres que viven ahí, y eso incluye que cambie quién vive ahí. A nivel de mujer preguntamos si le sube el ingreso a una madre determinada, y ahí no entra nadie nuevo. Vimos que las UV tratadas ganan cerca de 4% más mujeres que las control después de abrir, así que parte de la diferencia puede ser composición. Pero para explicar todo el efecto, esas mujeres nuevas tendrían que ganar muchísimo más que las que ya estaban, así que probablemente también hay dilución: en la estimación con efecto fijo seguimos contando como tratadas a mujeres que ya se mudaron. Todavía no podemos separar las dos."

**Qué lo separaría:** el `24` con UV fija desde 2022 (menos años, menos mudanzas) y contar las mudanzas directamente. Ambos pendientes.


### Qué hay dentro de cada k en el efecto fijo de mujer

**UV asignada:** la primera UV válida con la que la mujer aparece en los datos (`08a` l.28–33).
- **Si aparece en 2014 o 2015:** esos años no tienen UV confiable, así que su primera UV es la de **2016**. Es cerca de la mitad de las mujeres (aprox.: 425 mil de 817 mil aparecen en 2014, muestra principal). Las que no están en 2016 salen de la muestra.
- **Sale de la estimación** si su primera UV ya tenía jardín en 2014, aunque después se mude a una UV sin jardín.
- **Sale de la estimación** si la primera vez que la vemos el jardín de esa UV ya abrió.
- **Se queda con esa UV** todos los años: si se muda, sigue contando como tratada o control según la UV inicial.
- **Cuidado con las cohortes 2015 y 2016:** su UV "previa" se mide en 2016, cuando el jardín ya abrió o está abriendo. Para ellas no está garantizado que vivieran ahí antes de la apertura, y son parte importante de k = 7.

**Qué se compara en un k.** Ejemplo, k = 3 de la cohorte 2018: ingreso de 2021 menos ingreso de 2017 de cada mujer, comparado con ese mismo cambio en las mujeres de UV que nunca reciben jardín. El coeficiente de k = 3 promedia ese resultado entre las cohortes que llegan a k = 3, según su número de mujeres. Con panel desbalanceado, la regresión hace una versión aproximada de esta resta.

**Quién llega a cada k.** k = año − año de apertura, y solo hay datos de 2014 a 2024. Mujeres contadas en la muestra principal, como aproximación: la tabla exacta del EF no se extrajo (ver TODO).

| k | Cohortes | Mujeres aprox. |
|---|---|---|
| ≤ −5 | 2019–2024 | hasta 19 mil por k |
| −4 | 2018–2024 | 31 mil |
| −3 | 2017–2024 | 46 mil |
| −2 | 2016–2024 | 57 mil |
| −1 | todas (2015–2024) | 69 mil |
| 0 | todas (2015–2024) | 71 mil |
| 1 | 2015–2023 | 73 mil |
| 2 | 2015–2022 | 72 mil |
| 3 | 2015–2021 | 70 mil |
| 4 | 2015–2020 | 68 mil |
| 5 | 2015–2019 | 68 mil |
| 6 | 2015–2018 | 60 mil |
| 7 | 2015–2017 | 43 mil |

- **Cada k no tiene a las mismas mujeres:** para estar en k = −3, la mujer debe aparecer al menos tres años antes de la apertura. Para estar en k = 7, su UV debe abrir en 2015–2017.
- **Los cambios entre k mezclan efecto y cohortes:** de k = 6 a k = 7 sale la cohorte 2018, que pesa cerca de 30% de k = 6. No todo cambio entre dos k es que el efecto creció o cayó.
- **Azul vs. naranjo:** en azul las celdas crecen con el tiempo porque entran mujeres nuevas (cohorte 2015: 8.500 en k = −1, 12.100 en k = 7). En naranjo no puede entrar nadie después de la apertura. Las UV control también crecen (39% entre 2014 y 2024), así que esto no prueba por sí solo una diferencia entre tratadas y control.
- **"Madres" incluye futuras madres:** basta tener un hijo menor de 5 en algún año 2014–2024, y puede aparecer antes de tenerlo.

### Cómo se miden las variables

| Variable | Qué es | Quiénes entran | Coeficiente |
|---|---|---|---|
| `ingreso_rel` | 100 × ingreso anual / promedio de la muestra ese año | Todas; sin ingreso = 0 | ≈ % del ingreso promedio |
| `ingreso_mes24` | El mismo ingreso, en pesos mensuales a nivel 2024 | Todas; sin ingreso = 0 | Pesos al mes |
| `ln_ingreso` | Log del ingreso anual | Solo con ingreso mayor que 0 | ≈ % |

- **Pesos "a ingresos de 2024" no son pesos reales:** `ingreso_mes24` es (ingreso / promedio de ese año) × promedio de 2024. Cada año queda con promedio cercano a $424 mil, también 2014. Sirve para el efecto, no para el nivel: los $15 mil significan "3,6% del ingreso promedio, valorado a ingresos de 2024".
- **`ln_ingreso` no es salario:** el ingreso es anual, así que sube si gana más por mes o si trabaja más meses.
- **`ln_ingreso` puede cambiar la muestra:** si entran a trabajar madres con menores ingresos, baja el promedio aunque nadie gane menos.

**Con ceros suma los dos márgenes:** % ingreso con ceros ≈ % empleo + % ingreso de quienes trabajan.

### Niveles de ingreso

Ingreso anual / 12, en pesos de cada año.

| | Con ceros | Madres con ingreso, promedio | Madres con ingreso, mediana | Salario mínimo* |
|---|---|---|---|---|
| 2014 | ≈ $165 mil | ≈ $300 mil | ≈ $230 mil | $225 mil |
| 2024 | ≈ $424 mil | ≈ $770 mil | ≈ $630 mil | $460–500 mil |

\* De memoria, verificar. Fuentes: 2014 con ceros y promedio, `balance_lab_entrada.csv` (ponderado, control $296 mil, tratadas $298 mil; con ceros = promedio × empleo). 2024 con ceros, conversión de esta extracción. Medianas y promedio 2024, log del 28/10: muestra anterior, sin ponderar. Esta extracción no trae la tabla (ver TODO).

- **¿Es alto?** En 2014 no: la mediana está casi en el mínimo. En 2024 el promedio es cerca de 1,5 veces el mínimo y la mediana cerca de 1,3 veces. Es más alto de lo que uno esperaría, pero razonable: solo cuenta a quienes tienen ingreso formal, v60 no es solo la población más pobre y el promedio lo tiran hacia arriba los ingresos altos.
- **Comparar con el mínimo del año correcto:** el ingreso de 2024 se compara con el mínimo de 2024, no con el de hoy.

### Los números
| Promedio | Principal | Balanceada | EF de mujer* | EF balanceada* |
|---|---|---|---|---|
| **Ingreso con ceros, k = 0–7** | **+3,56** (0,75) | +2,97 (0,90) | +0,97 (0,71) | +1,23 (0,82) |
| En pesos al mes | **$15.060** | $12.600 | ≈ $4.100 | ≈ $5.200 |
| Ingreso con ceros, k = 0–4 | +2,09 (0,66) | +2,03 (0,78) | +1,16 (0,56) | +0,77 (0,64) |
| Ingreso con ceros, k = 5–7 | +6,00 (1,23) | +4,55 (1,33) | +0,66 (1,15) | +2,00 (1,28) |
| **Ln ingreso, k = 0–7** | **+2,65%** (0,87) | +1,47% (1,18) | +0,22% (0,94) | error 1 |

\* EE provisorios (error 4). Pesos de EF con la conversión del modelo UV-año (1 punto ≈ $4.235), aproximados.

**De dónde salen los $15.060:** es el promedio simple de los ocho coeficientes de `ingreso_mes24` (`sa_w`, k = 0 a 7, `coefs_lab_entrada.csv`): 833, 4.983, 7.802, 12.872, 17.791, 20.071, 24.235 y 31.892.
- **Es lo mismo que el 3,56%, en otra unidad:** `ingreso_mes24` es `ingreso_rel` × $4.236, y $4.236 es 1% del ingreso promedio con ceros de 2024 ($423.600). Por eso 3,556 × $4.236 = $15.060. La balanceada sale igual: 2,975 × $4.236 = $12.600.
- **Intervalo:** no se extrajo la V de `ingreso_mes24`, pero se puede convertir la de `ingreso_rel`: EE 0,75 × $4.236 ≈ $3.200, IC 95% de cerca de $8.800 a $21.300.
- **Cada k pesa lo mismo** en este promedio, sin importar cuántas cohortes tenga.
- **No son pesos ganados en cada año:** es el efecto en porcentaje valorado a ingresos de 2024. Por ejemplo, para una cohorte que abrió en 2017, el aumento en pesos de ese año fue menor.

### De dónde viene el aumento (k = 0–7)

| | Empleo | Ingreso de quienes trabajan | Suma | Ingreso con ceros estimado |
|---|---|---|---|---|
| Principal | +1,8% | +2,65% | 4,5% | +3,6% |
| EF de mujer | +1,0% | +0,2% | 1,2% | +1,0% |

Lo que cae al seguir a las mismas mujeres es sobre todo la segunda columna. La suma es aproximada.

**La misma cuenta en pesos, a ingresos de 2024.** Cuánto sube el ingreso promedio solo porque más madres trabajan. De cada 100 madres, 1 más con ingreso de $770 mil sube el promedio de las 100 en $7.700. Depende de cuánto ganen las nuevas:

| k = 0–7 | Aumento total | Más empleo | Si ganan el promedio ($770 mil) | Si ganan el mínimo ($500 mil) |
|---|---|---|---|---|
| Principal | $15.060 | 1,00 pp | $7.700 (cerca de 50%) | $5.000 (cerca de 33%) |
| Balanceada | $12.600 | 1,21 pp | $9.300 (cerca de 75%) | $6.050 (cerca de 50%) |
| EF de mujer | ≈ $4.100 | 0,55 pp | $4.200 (casi todo) | $2.750 (cerca de 67%) |

- **Es una cuenta aproximada, no una estimación:** usa los coeficientes y dos supuestos de cuánto ganan las madres nuevas.
- **Respuesta a "¿sube porque más madres empiezan a trabajar?":** en la UV, entre un tercio y la mitad; en las mismas mujeres, entre dos tercios y casi todo. El resto es ingreso de las que ya tenían o cambio en quiénes viven en la UV. Son aproximaciones: las nuevas podrían ganar menos que el mínimo si trabajan parte del año, y las cifras de EF son imprecisas.
- **El azul de ln ingreso sí es evidencia** (+2,65%, t = 3,1). Lo que no se sabe es si refleja que las madres ganan más o que cambió quiénes viven en la UV.
- **Ln con EF cerca de 0 no prueba que nadie gane más:** si entran madres con menores ingresos, baja el promedio. La ganancia de las que ya trabajaban podría estar escondida.

### Ingreso en pesos de 2024, ajustado por IPC (cuenta aproximada)

`ingreso_rel` y `ingreso_mes24` no usan IPC: llevan cada año al promedio de ingresos de la muestra, así que también sacan el crecimiento real. Los $15.060 son el efecto **a ingresos de 2024**. Para pesos reales de cada año:

- **Factor IPC 2014 → 2024:** ≈ 1,57 (diciembre a diciembre). 2014, 2017, 2018 y 2021–2024 salen de prensa; 2015, 2016, 2019 y 2020 son de memoria. **Verificar con INE o Banco Central.**
- **Niveles en pesos de 2024:** con ceros, ≈ $260 mil en 2014 y ≈ $424 mil en 2024. Madres con ingreso, ≈ $470 mil y ≈ $770 mil.
- **Promedio de los años post (2016–2024), con el log del 28/10 (muestra anterior, sin ponderar):** con ceros ≈ $335 mil; madres con ingreso ≈ $630 mil.
- **Efecto en pesos de 2024:** 3,56% × $335 mil ≈ **$12 mil** (antes $15 mil). Balanceada ≈ $10 mil; EF ≈ $3,2 mil; EF balanceada ≈ $4,1 mil.

No es una estimación: para eso hay que deflactar en el `02` (ver TODO).

### Estimaciones en niveles (como van en las láminas)

Base: media del control de cada modelo más el promedio k = 0–7. Ingresos: promedio real 2016–2024 (≈ $335 mil con ceros, ≈ $630 mil con ingreso), cuenta aproximada.

| k = 0–7 | Completa o EF | Balanceada |
|---|---|---|
| Matrícula | 34% a 37% | |
| Empleo | 54,6% a 55,6% | 53,4% a 54,6% |
| Empleo EF | 54,7% a 55,3% | 54,2% a 54,9% |
| Ingreso con ceros | $335 mil a $347 mil | $335 mil a $345 mil |
| Ingreso con ceros EF | $335 mil a $338 mil | $335 mil a $339 mil |
| Madres con ingreso | $630 mil a $647 mil | $630 mil a $639 mil |
| Madres con ingreso EF | $630 mil a $631 mil | |
| Nacimientos por 100 mujeres | 5,87 a 5,74 | 5,76 a 5,62 |
| Nacimientos por 100 mujeres EF | 5,88 a 5,75 | 6,13 a 5,92 |
| Acumulados por mujer | 0,376 a 0,381 | 0,405 a 0,408 |
| Total de hijos por mujer | 1,248 a 1,251 | 1,477 a 1,477 |

### Aumento de ingreso por madre adicional que trabaja (cuenta aproximada)

Aumento de ingreso ÷ aumento de empleo: lo que tendría que ganar cada nueva trabajadora si ella explicara todo el aumento.

| k = 0–7, pesos de 2024 | Aumento de ingreso | Más empleo | Por madre adicional | Respecto del promedio ($630 mil) |
|---|---|---|---|---|
| Principal | $12 mil | +1,00 pp | $1,2 millones | ≈ 2 veces |
| Balanceada | $10 mil | +1,21 pp | $830 mil | ≈ 1,3 veces |
| EF de mujer | $3,2 mil | +0,55 pp | $590 mil | ≈ 1 vez |
| EF balanceada | $4,1 mil | +0,69 pp | $600 mil | ≈ 1 vez |

- **A nivel UV es demasiado para las nuevas trabajadoras solas:** parte tiene que venir de madres que ya trabajaban (más meses o sueldo) o de quién está en la UV. Calza con que el efecto caiga al seguir a las mismas mujeres.
- **Muy impreciso:** sin covarianza entre ambos resultados no hay IC de la razón. Combinando los extremos de cada IC, la principal va de cerca de $450 mil a $3,8 millones.
- **Ajustar por IPC no cambia la lectura:** a ingresos de 2024 son $1,5 millones contra $770 mil, también cerca de 2 veces.

### Cuánto del aumento de ingreso viene de que más madres trabajen (lámina 16)

La misma cuenta, hacia adelante. Si solo hubiera más madres trabajando y cada nueva ganara el promedio ($630 mil), +1 pp de empleo sube el ingreso promedio en $6.300.

| k = 0–7, pesos de 2024 | Más empleo | Subiría solo por empleo | Sube | Parte explicada |
|---|---|---|---|---|
| Principal | +1,0 pp | $6.300 | $12.000 | ≈ la mitad |
| Balanceada | +1,2 pp | $7.600 | $10.000 | ≈ tres cuartos |
| EF de mujer | +0,55 pp | $3.500 | $3.200 | ≈ todo |
| EF balanceada | +0,7 pp | $4.300 | $4.100 | ≈ todo |

Si las nuevas trabajadoras ganan menos que el promedio, la parte explicada es menor. Con EF, los aumentos de ingreso no son significativos, así que "≈ todo" es una cuenta de tamaños, no una prueba.

### Conclusiones de empleo e ingresos (borrador)

Promedio k = 0–7. En EF, EE provisorios.

| | Principal | Balanceada | EF de mujer | EF balanceada |
|---|---|---|---|---|
| **Empleo formal (pp)** | +1,00, sig. | +1,21, sig. | +0,55, IC −0,02 a 1,11 | +0,69, sig. |
| **Ingreso con ceros (%)** | +3,56, sig. | +2,97, sig. | +0,97, no sig. | +1,23, no sig. |
| **Ln ingreso (%)** | +2,65, sig. | +1,47, no sig. | +0,22, no sig.; pre-tendencias | error 1 |

1. **Empleo es el resultado más robusto:** positivo y gradual en las cuatro versiones, sin pre-tendencias al sacar el bin. Con EF de mujer no alcanza por poco el 5%; con EF balanceada sí.
2. **Ingreso con ceros sube en la UV,** 3,6%, unos 15 mil pesos al mes a ingresos de 2024. Con las mismas mujeres es cerca de 1% y no es significativo.
3. **Ln ingreso solo es significativo en la principal.** No podemos afirmar ni descartar que las madres con ingreso ganen más.
4. **Parte del aumento de ingreso viene de que más madres tienen ingreso:** según una cuenta aproximada, entre un tercio y la mitad en la principal, si las nuevas ganan entre el mínimo y el promedio.

**Una frase para la reunión:**
> "Cuando abre el primer jardín, más madres entran al empleo formal, de a poco, y esto se ve en todas las versiones. El ingreso promedio de las madres de la UV también sube, pero ese aumento no es significativo al seguir a las mismas mujeres, así que todavía no podemos decir si las madres ganan más."

### Por qué cuesta más creerlo que empleo
1. **Es sensible a la versión:** de principal a balanceada casi no cambia; cae al fijar la UV (2,97 a 1,23). Lo que importa es la mudanza o la asignación de UV, no la entrada al RSH.
2. **Cae más que el empleo:** de principal a EF cae 73% (empleo: 45%). Si fuera solo atenuación, debería caer parecido. Sugiere que además hay composición, pero las diferencias son imprecisas.
3. **La brecha se abre con el tiempo:** en k = 0–4 con EF es +1,16 (t = 2,1), más de la mitad del principal; en k = 5–7 se separan (0,66 vs 6,00). Las dos explicaciones crecen con k: se acumulan tanto las llegadas como las mudanzas desde la UV fija.
4. **Pre-tendencias:** en ingreso con ceros, sin el bin k ≤ −5 pasan en todas (p = 0,93, 0,65, 0,64 y 0,14). En ln ingreso con EF de mujer no pasan (p = 0,004), porque también pesa k = −4: esa estimación es la menos confiable.

### Lo que te pueden preguntar

- **"¿Entonces el jardín aumenta el ingreso o no?"**
  - Cómo decirlo: "En la UV, sí: el ingreso promedio sube 3,6%. En las mismas mujeres, el efecto es cerca de 1% y no es significativo. Lo que se sostiene en todas las versiones es que más madres tienen ingreso. También hay un aumento entre las madres con ingreso, pero no se mantiene en las mismas mujeres, así que no sabemos si es que ganan más o que cambió quiénes viven en la UV."
- **"¿Por qué cae tanto con efecto fijo de mujer?"**
  - Cómo decirlo: "Hay dos explicaciones que no podemos separar todavía: pueden estar llegando madres de mayores ingresos a las UV tratadas, lo que inflaría el efecto principal; o el efecto fijo está atenuado, porque cuenta como tratadas a madres que se mudaron o tienen mal asignada la UV. La caída es mayor que en empleo, lo que sugiere algo de composición. La estimación con UV fija desde 2022 ayudará a separarlas."
- **"¿Las madres ganan más por mes?"**
  - Cómo decirlo: "No lo podemos afirmar: el ingreso es anual, así que mezcla salario y meses trabajados. Además, ese resultado no se sostiene con las mismas mujeres."
- **"¿Qué pasa con el k = −5, que da +4,5?"**
  - Cómo decirlo: "Es el mismo bin que en empleo: pocas UV y los años con datos más débiles. Va en dirección contraria a una tendencia previa al alza y, sin él, la prueba conjunta no rechaza (p = 0,93). Falta acotarlo con HonestDiD."
- **"¿Y k = 8 y 9, que con EF son muy negativos?"**
  - Cómo decirlo: "k = 9 es solo la cohorte 2015 en 2024, y k = 8 agrega solo la 2016. Por eso nuestra cifra central es k = 0 a 7. No los leería como una caída del efecto."
- **"¿Por qué bajó respecto de la reunión pasada?"**
  - Cómo decirlo: "Corregimos el crosswalk y cambió la muestra: ahora las madres entran desde su primer año en el RSH. El efecto en k = 0–7 pasó de 19 a 15 mil pesos, y los coeficientes previos ya no son negativos." (Sin 2015 da +4,28, cerca de 18 mil pesos.)

### Qué cambiar respecto del ppt del 29/10
- **"Working mothers now also earn more":** matizarla. Hay aumento en la UV, pero no se mantiene en las mismas mujeres.
- **"Half more mothers working, half higher earnings, consistent with switching":** esa mitad es la que cae al seguir a las mismas mujeres. No la usaría como evidencia del cambio a un jardín más cercano.

⇒ El ingreso sube en la UV, pero es menos robusto que el empleo. Lo más firme es el margen de empleo. Entre las madres con ingreso hay un aumento en la UV (+2,65%), que puede ser ganancia real, composición o ambas.

## 5. Fertilidad

**Muestra:** mujeres v60 de 18 a 35 años en 2014, tengan o no hijos, en la UV donde viven cada año. Decisión del 02/11, por confirmar con el profesor. Promedios k = 0–7; los de la tabla del Panorama son k = 0–9.

### Cómo se miden las variables

| Variable | Qué es | Base | Coeficiente |
|---|---|---|---|
| `tuvo_hijo` | 1 si la mujer tuvo un hijo ese año | 5,9 nacimientos por 100 mujeres al año (control) | Puntos porcentuales: −0,13 = 1,3 nacimientos menos por 1.000 mujeres al año |
| `nac_acum` | Nacimientos acumulados desde el primer año en que aparece | 0,38 hijos por mujer | Hijos por mujer: +0,005 = 0,5 hijos más por 100 mujeres |

- **`tuvo_hijo` compara tasas:** contra la del año antes de abrir, respecto del mismo cambio en el control.
- **`nac_acum` compara cantidades:** como parte de cero al aparecer, a nivel UV también cambia según quién llega o se va.
- **k = 0 casi no puede responder:** la mayoría de los nacimientos de ese año se concibieron antes de abrir el jardín.

### Cómo decirlo, gráfico por gráfico

**1. Tasa bruta por año** (`graficos/fert_07_tasa_bruta.png`)
> "Este gráfico muestra la tasa de natalidad cruda de las mujeres vulnerables de 18 a 49 años. Cae a la mitad en el período: de cerca de 6 nacimientos por 100 mujeres en 2014 a cerca de 3 en 2024. Las UV tratadas y control van prácticamente juntas todos los años."

⇒ La natalidad de estas mujeres cae a la mitad en el período, y tratadas y control caen igual.

**2. Tuvo un hijo, principal** (`graficos/fert_01_tuvo_hijo.png`)
> "Este gráfico mide cuántas mujeres vulnerables, de 18 a 35 años en 2014, tienen un hijo cada año. La base es de cerca de 6 nacimientos por cada 100 mujeres al año, en promedio entre 2014 y 2024. Antes de la apertura no hay diferencias significativas. Después, los coeficientes son levemente negativos: en promedio −0,13 puntos en los primeros ocho años, y no es significativo. Con este intervalo podemos descartar una baja mayor a 0,36 puntos, cerca de 6%, o un alza mayor a 0,10 puntos, cerca de 2%."

⇒ No vemos un efecto significativo en la natalidad, y podemos descartar bajas mayores a cerca de 6%.

**3. Tuvo un hijo, tres versiones** (`graficos/fert_02_tuvo_hijo_versiones.png`)
> "Este gráfico compara las tres versiones, sobre una base de cerca de 6 nacimientos por 100 mujeres al año. En azul, la UV donde vive la mujer: −0,13 puntos. En gris, solo mujeres observadas los once años: −0,14. En naranjo, las mismas mujeres, asignadas a la primera UV con la que aparecen: −0,13. Ninguna es significativa. A diferencia del ingreso, aquí la estimación casi no cambia al seguir a las mismas mujeres, aunque la versión naranja tiene pre-tendencias."

⇒ Las tres versiones dan casi lo mismo: un efecto pequeño y no significativo.

**4. Tuvo un hijo, solo efecto fijo de mujer** (`graficos/fert_03_tuvo_hijo_ef_mujer.png`)
> "Aquí seguimos a las mismas mujeres, sobre una base de cerca de 6 nacimientos por 100 mujeres al año. En promedio, en los primeros ocho años la tasa es 0,13 puntos menor y no es significativo. En los primeros cuatro años es cerca de 0,2 puntos menor y después vuelve cerca de cero. Hay que leerlo con cuidado: ya es negativo el mismo año de apertura, cuando casi no debería poder responder, y cuatro años antes de abrir el coeficiente ya es significativo."

⇒ Con las mismas mujeres tampoco hay un efecto significativo en el promedio, y esta versión tiene pre-tendencias.

- **k = 0–3:** −0,22 (EE 0,11, t = −2,0, EE provisorios). Sin k = 0, k = 1–3 da −0,22 (t = −1,9). No presentarlo como efecto.
- **Pre-tendencias:** vienen de k = −4 (+0,38, t = 2,3). Con solo k = −3 y −2 no rechaza (p = 0,55). El coeficiente baja desde k = −4 hasta k = −2, en la misma dirección que el efecto.

**5. Nacimientos acumulados, principal** (`graficos/fert_04_nac_acum.png`)
> "Este gráfico mide cuántos hijos ha tenido cada mujer desde que aparece en los datos, con una base de cerca de 0,38 hijos por mujer. Después de la apertura el coeficiente es positivo, pero pequeño e impreciso: en promedio, 0,5 hijos más por cada 100 mujeres en los primeros ocho años, cerca de 1,4%, y no es significativo. Ningún año por sí solo es significativo, y el coeficiente ya venía subiendo un poco antes de abrir."

⇒ No vemos un cambio significativo en el número de hijos acumulados.

- **IC 95%:** −0,27 a +1,33 hijos por 100 mujeres. Pre-tendencias: p = 0,12 con bin, 0,25 sin bin.
- **Cuenta desde que la mujer aparece, no desde su nacimiento:** no es el total de hijos. A nivel UV, además, cambia según quién llega o se va, porque cada mujer llega con sus acumulados.
- **Por qué sube si `tuvo_hijo` baja:** ver "Por qué `tuvo_hijo` es negativo y `nac_acum` positivo".

**6. Nacimientos acumulados, tres versiones** (`graficos/fert_05_nac_acum_versiones.png`)
> "Este gráfico compara las tres versiones, sobre una base de cerca de 0,4 hijos por mujer. En azul, la UV donde vive la mujer: 0,5 hijos más por 100 mujeres. En gris, solo mujeres observadas los once años: 0,3. En naranjo, las mismas mujeres en su primera UV: 0,3. Ninguna es significativa. La versión gris es la que tiene los coeficientes previos más limpios, y la naranja tiene pre-tendencias claras."

⇒ El resultado es pequeño y no significativo en todas las versiones.

**7. Según hijos antes de 2014, efecto fijo de mujer** (`graficos/fert_06_tuvo_hijo_por_hijos.png`)
> "Este gráfico separa a las mujeres según cuántos hijos tenían antes de 2014. Entre las que no tenían hijos, la tasa es cerca de 0,5 puntos menor en los primeros cuatro años, sobre una base de 6,1, y después vuelve a cero. En las otras no hay un patrón claro. Es exploratorio: a nivel UV este patrón no se repite y el efecto ya aparece el mismo año de apertura, cuando casi no debería poder responder."

⇒ Hay una señal entre las mujeres sin hijos previos, pero no es suficientemente firme para sostenerla como resultado.

### Los números

| Promedio k = 0–7 | Principal | Balanceada | EF de mujer* | EF balanceada* |
|---|---|---|---|---|
| **Tuvo un hijo (pp)** | −0,13 (0,12) | −0,14 (0,14) | −0,13 (0,12) | −0,21 (0,13) |
| Base | 5,9 | 5,8 | 5,9 | 6,1 |
| k = 0–3 | −0,07 (0,11) | −0,09 (0,14) | −0,22 (0,11) | −0,13 (0,13) |
| k = 4–7 | −0,19 (0,14) | −0,19 (0,16) | −0,05 (0,14) | −0,28 (0,15) |
| Pre-tendencias (con bin / sin bin) | 0,25 / 0,20 | 0,27 / 0,22 | **0,013 / 0,006** | **0,009 / 0,006** |
| **Nac. acumulados (hijos por 100 mujeres)** | +0,53 (0,41) | +0,26 (0,33) | +0,25 (0,25) | +0,16 (0,29) |
| Base (hijos por mujer) | 0,38 | 0,41 | 0,37 | 0,43 |
| Pre-tendencias (con bin / sin bin) | 0,12 / 0,25 | 0,94 / 0,87 | **0,000 / 0,012** | **0,000 / 0,029** |

\* EE provisorios (error 4).

- **IC 95% de la principal en `tuvo_hijo`:** −0,36 a +0,10 pp.
- **Años sueltos:** en la principal solo k = 6 es significativo (−0,35, t = −2,1), de ocho coeficientes.
- **k = 8 y 9:** en la principal dan −0,69 (t = −2,9) y −0,56, solo con las cohortes 2015 y 2016. Con k = 0–9 el promedio es −0,23 (EE 0,13, t = −1,8). Por eso la ventana importa: con ella, el coeficiente queda más negativo, sin ser significativo al 5%.

**Control con hijos previos:** `hijos_pre2014` no puede responder a la apertura, porque son hijos nacidos antes. Da −0,0025 (EE 0,0048) sobre 0,87, con pre-tendencias p = 0,80 / 0,85. No cambia el número de hijos previos de las mujeres de la UV. Solo mira esa variable.

**Total de hijos (`hijos_total`):** hijos nacidos antes de 2014 + nacimientos desde que aparece; no suma los nacimientos entre 2014 y su primer año. Media 1,25 hijos por mujer (1,48 balanceada). Promedio k = 0–7: +0,28 hijos por 100 mujeres (balanceada +0,03). Sale de `nac_acum` + `hijos_pre2014`: +0,53 − 0,25 y +0,26 − 0,23. Ningún k es significativo. No llegaron las V, así que no hay EE del promedio ni prueba conjunta (ver TODO). Ojo: en la balanceada, la caída viene de `hijos_pre2014`, con k = 3–6 significativos (−0,21 a −0,74). Hijos ya nacidos no pueden responder al jardín, y ese placebo balanceado no es confiable (error 5), así que el +0,03 no debe leerse como un efecto más chico.

### Según hijos antes de 2014

| `tuvo_hijo`, pp | k = 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| Sin hijos, EF | **−0,52** | **−0,54** | −0,42 | **−0,51** | −0,02 | +0,08 | +0,37 | +0,25 |
| Sin hijos, UV | −0,03 | −0,24 | −0,07 | −0,23 | +0,12 | 0,00 | −0,21 | −0,17 |
| Un hijo, EF | +0,19 | **+0,50** | −0,15 | +0,10 | −0,31 | −0,03 | −0,16 | −0,12 |
| Dos o más, EF | −0,20 | −0,32 | −0,37 | −0,13 | −0,01 | −0,13 | −0,17 | −0,43 |

En negrita, |t| > 2 (EE provisorios). Sin V para estos grupos, así que no hay promedio con EE ni prueba conjunta. `nac_acum` por grupo con EF no sirve (error 2).

**Contra qué se compara:** cada panel es una regresión separada (`08b` l.100, 107 y 114): tratadas contra control, ambas con el mismo número de hijos antes de 2014. El grupo queda fijo: una mujer sin hijos antes de 2014 sigue en ese grupo después de tener su primer hijo, así que el panel no mide solo el primer hijo. Dentro de cada grupo no se iguala la edad, y los paneles no se comparan entre sí con un test.

Promedios simples, EF: sin hijos, k = 0–3 −0,50 y k = 4–7 +0,17 (base 6,1); un hijo, k = 0–7 0,00 (base 6,8); dos o más, k = 0–7 −0,22 (base 4,3). Son 24 coeficientes posteriores en tres grupos, así que algunos pueden salir significativos por azar.

### Por qué `tuvo_hijo` es negativo y `nac_acum` positivo

**No está resuelto.** Ninguno de los dos es significativo. La explicación por una brecha previa solo aparece en dos cohortes.

Brecha cruda tratadas − control, nacimientos por 100 mujeres, muestra de 18 a 49 (`graficos/fert_08_brecha_cruda.png`):

| Cohorte | k = −1 | Promedio después de abrir |
|---|---|---|
| 2015 | **+0,61** | +0,13 |
| 2016 | **+0,55** | +0,11 |
| 2017 | −0,02 | +0,09 |
| 2018 | −0,15 | −0,06 |
| 2019 | +0,25 | +0,35 |

- **En 2015 y 2016 la brecha cae fuerte después de k = −1.** Eso empuja `tuvo_hijo` a negativo.
- **En 2017–2019 no cae:** sube cerca de 0,1. No hay una brecha previa general.
- **El k = −1 de 2015 y 2016 son los años 2014 y 2015, con la UV de 2016.** Si madres con hijos recién nacidos se mudaron a esas UV antes de 2016, se verían "más nacimientos" antes de abrir. Es una hipótesis, no está verificada.
- **Límites:** es de 18 a 49, porque la extracción no trae 18–35 por año. Son brechas crudas, sin EE: con este tamaño, cada cohorte tiene un error de cerca de 0,17 pp.
- **La derivación de la sección 1 no sirve como prueba:** su coincidencia con +0,29 viene de las cohortes 2015–2017, y k = −2 usa otras cohortes.

⇒ No podemos atribuir el alza de `nac_acum` al jardín, ni tampoco a una brecha previa general. Para cerrarlo hay que estimar por cohorte.

### Quién entra en fertilidad con EF de mujer, y qué nacimientos cuenta

**"Antes de abrir" no es antes de 2014:** los datos parten en 2014, así que todos los k caen entre 2014 y 2024. Los hijos anteriores a 2014 solo están en `hijos_pre2014` (`09` l.194–200).

**Una mujer que aparece después de 2014 no sale por eso** (`08b` l.14–15 y l.27–29). La edad de 18 a 35 en 2014 se calcula hacia atrás desde su primer año.

| Situación | ¿Queda? |
|---|---|
| Aparece en 2019, con UV control | Sí |
| Aparece en 2017, con UV que abre en 2019 | Sí, desde k = −2 |
| Aparece en 2019 o después, con UV que abre en 2019 | No |
| Su primera UV ya tenía jardín en 2014 | No |
| Aparece después de 2014, en la versión balanceada | No: exige aparecer en 2014 y tener 11 años (`08b` l.36) |

- **La balanceada son 431 mil mujeres y 68% de las observaciones del EF.** El resto no tiene los 11 años o apareció después de 2014.
- **La regla no es igual para tratadas y control:** una control puede aparecer en cualquier año, y una tratada solo antes de la apertura de su UV. No está medido cuánto pesa.
- **`nac_acum` solo cuenta nacimientos de años en que la mujer está en la base** (`09` l.17–22 y l.218). Un hijo nacido antes de su primer año, o en un año en que no aparece, no se suma. Por lo mismo, `hijos_total` no incluye los nacimientos entre 2014 y su primer año.

### Por qué `nac_acum` con EF de mujer tiene pre-tendencias

**Lo principal: una variable acumulada casi no puede cumplir tendencias paralelas si hay diferencia de nivel en la tasa.** Para una misma mujer, el cambio anual de `nac_acum` es `tuvo_hijo`. Entonces, tendencias paralelas en `nac_acum` exige que tratadas y control tengan **la misma tasa anual en nivel**, no solo que cambie igual. Una brecha constante en la tasa se vuelve una línea con pendiente.

| | k ≤ −5 | −4 | −3 | −2 |
|---|---|---|---|---|
| `nac_acum` EF (hijos por 100 mujeres) | +1,65 | +0,75 | +0,34 | +0,02 |
| EE* | 0,36 | 0,27 | 0,16 | 0,11 |
| Brecha anual en k = −1 implícita (pp) | | −0,20 | −0,10 | −0,02 |

\* Provisorios (error 4). Brecha implícita: despejada de los coeficientes de `nac_acum` y `tuvo_hijo`; es aproximada, porque cada k tiene cohortes distintas.

- **Son brechas chicas:** cerca de 0,1 a 0,2 nacimientos por 100 mujeres al año, sobre una base de 5,9.
- **Calza con los datos crudos de las cohortes tardías:** 2018–2024 están bajo el control todos los años previos (−0,06, −0,06, −0,20, −0,24 y −0,14). Esto es de 18 a 49 y con la UV donde viven, no la muestra del EF.
- **Por eso rechaza con tanta fuerza:** el EF es más preciso y una brecha pequeña acumulada se detecta fácil. `tuvo_hijo`, en cambio, no rechaza con k = −3 y −2 (p = 0,55).

**Ejemplo sin ningún efecto del jardín.** Control con 6,0 nacimientos por 100 mujeres al año y tratadas con 5,8, todos los años:

| k | −4 | −3 | −2 | −1 | 0 | 1 | 2 |
|---|---|---|---|---|---|---|---|
| Brecha en la tasa | −0,2 | −0,2 | −0,2 | −0,2 | −0,2 | −0,2 | −0,2 |
| **Coeficiente en la tasa** (contra k = −1) | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| Brecha en el acumulado | −0,2 | −0,4 | −0,6 | −0,8 | −1,0 | −1,2 | −1,4 |
| **Coeficiente en el acumulado** (contra k = −1) | +0,6 | +0,4 | +0,2 | 0 | −0,2 | −0,4 | −0,6 |

La tasa da una línea plana: ni pre-tendencia ni efecto, y es correcto, porque el jardín no hizo nada. El acumulado, con los mismos nacimientos, da una línea con pendiente que parece pre-tendencia y efecto.

**La idea:** diferencias en diferencias necesita que la brecha entre los grupos se mantenga constante si no hay efecto.
- **En la tasa,** basta con que la diferencia sea estable, aunque un grupo tenga más nacimientos que el otro.
- **En el acumulado,** la brecha solo se mantiene constante si ambos grupos tienen exactamente la misma tasa. Con cualquier diferencia, por chica que sea, crece cada año.

**Por qué importa:** también puede pasar hacia arriba. Si las tratadas tuvieran 6,2, el coeficiente en el acumulado daría −0,6, −0,4, −0,2, 0, +0,2, +0,4 y +0,6: una línea que sube después de abrir sin ningún efecto. Una línea acumulada que sube no basta para decir que el jardín aumenta los nacimientos, aunque fuera significativa.

**En el gráfico naranjo:** la parte de antes de abrir (+1,65, +0,75, +0,34, +0,02) se parece al ejemplo: positiva y bajando hacia cero. Después de abrir no sigue el mismo patrón, en parte porque vienen de otras cohortes, así que el ejemplo no explica todo el gráfico.

**Qué mujeres hay antes de abrir:** cada k previo solo tiene cohortes tardías, y solo mujeres que ya aparecían ese año.

| k | Cohortes | Años |
|---|---|---|
| ≤ −5 | 2019–2024 | 2014 a 2019 |
| −4 | 2018–2024 | 2014 a 2020 |
| −3 | 2017–2024 | 2014 a 2021 |
| −2 | 2016–2024 | 2014 a 2022 |

- **Pocos años previos influye, pero no lo explica solo:** menos datos dan intervalos más anchos, no coeficientes significativos. Lo que sí implica es que la prueba de pre-tendencias mira a cohortes tardías, y el efecto en los k altos viene de cohortes tempranas.
- **Sin explicar:** azul y gris no muestran este patrón. La diferencia con el naranjo es la UV fija, pero no sabemos por qué pasa. La tabla exacta por cohorte y k del EF no se extrajo (ver TODO).

**Cómo decirlo:**
> "Es casi mecánico. Como la variable es acumulada, tendencias paralelas exige que tratadas y control tengan la misma tasa de natalidad en nivel, no solo que cambie igual. Las cohortes tardías tienen una tasa levemente menor que el control, cerca de 0,1 a 0,2 nacimientos por 100 mujeres, y esa pequeña diferencia se va sumando. Por eso prefiero leer fertilidad con la tasa anual."

### Conclusiones de fertilidad (borrador)

1. **No vemos un efecto significativo en la natalidad** en ninguna de las cuatro versiones. La estimación es parecida en todas, cerca de −0,13 a −0,21 pp.
2. **Se pueden descartar bajas mayores a cerca de 6%** de la tasa base.
3. **Los nacimientos acumulados tampoco cambian de forma significativa.**
4. **Las versiones con efecto fijo tienen pre-tendencias,** en las dos variables.

**Una frase para la reunión:**
> "No vemos un efecto significativo de la apertura en la fertilidad: en promedio, la tasa baja 0,13 puntos sobre una base de cerca de 6 nacimientos por 100 mujeres al año, y podemos descartar bajas mayores a cerca de 6%."

### Lo que te pueden preguntar

- **"¿Entonces las UV tratadas acumulan más niños?"**
  - Cómo decirlo: "El coeficiente es positivo en todas las versiones, pero pequeño y no significativo en ninguna, así que no podemos decir que las UV tratadas acumulen más. Tampoco lo vemos en la tasa anual, que da levemente negativa. Para entender esa diferencia de signo tendríamos que estimar por cohorte."
- **"¿Tiene sentido 6 por 100 con la fecundidad actual de Chile?"**
  - Cómo decirlo: "No es comparable directamente con la tasa de fecundidad, que suma todas las edades. En 2024, nuestra muestra completa tiene cerca de 3 nacimientos por 100 mujeres al año, lo que equivale a cerca de un hijo por mujer, igual que el dato nacional."
  - Por qué da 5,9: es un promedio de 2014 a 2024 y son mujeres más jóvenes (18 a 35 en 2014). Cuenta aproximada: 3,1 × 32 años de edad fértil ≈ 1,0, contra 1,03 nacional en 2024 (Ex-Ante, cifra INE; verificar en el boletín). La extracción no trae esta muestra por año.
- **"¿No hay efecto, o no alcanzan a detectarlo?"**
  - Cómo decirlo: "No detectamos efecto, y el intervalo descarta bajas mayores a cerca de 6% y alzas mayores a cerca de 2%. Un efecto más pequeño que eso no lo podemos descartar."
- **"¿Por qué mujeres de 18 a 35 en 2014?"**
  - Cómo decirlo: "Porque son las que están en edad de tener hijos durante buena parte del período. Si tomamos a todas las de 18 a 49 en cada año, entran y salen mujeres por edad." (Falta confirmarlo con el profesor.)
- **"¿Y si uso los últimos años, k = 8 y 9?"**
  - Cómo decirlo: "Son solo las cohortes 2015 y 2016, y ahí el coeficiente es más negativo. Con k = 0 a 9 el promedio es −0,23 y sigue sin ser significativo al 5%."
- **"¿Hay efecto en las mujeres sin hijos?"**
  - Cómo decirlo: "Aparece una baja con efecto fijo en los primeros cuatro años, pero no a nivel UV, y parte el mismo año de apertura. Por eso la tratamos como exploratoria."

## 6. Balance y validez del diseño

### Balance en 2014

Muestra laboral, antes de cualquier apertura (`balance_lab_entrada.csv`). Ponderado por población de la UV; 299 UV tratadas y 3.811 control. Las regresiones ponderan por número de madres, no por población. Diferencia estandarizada = diferencia / desviación estándar conjunta; la regla usual considera problemático sobre 0,25.

| Variable | Control | Tratadas | Dif. estandarizada |
|---|---|---|---|
| Empleo formal | 55,5% | 55,8% | 0,03 |
| Ingreso, madres con ingreso (al mes, pesos de 2014) | $296 mil | $298 mil | 0,02 |
| Meses con ingreso | 8,2 | 8,1 | −0,03 |
| Edad | 27,9 | 28,1 | 0,13 |
| Hijos menores de 5 | 0,68 | 0,69 | 0,16 |
| Densidad de niños en la UV | 0,061 | 0,064 | 0,20 |
| **Madres por UV** | 286 | 520 | **0,50** |
| **Población de la UV** | 3.198 | 5.332 | **0,44** |

**Cómo decirlo:**
> "En 2014, antes de cualquier apertura, las madres de UV tratadas y control son muy parecidas: 55,5 y 55,8% de empleo formal, unos 300 mil pesos al mes entre las que tienen ingreso, y cerca de 28 años. La diferencia importante es el tamaño: las UV que reciben un jardín son más grandes, con cerca de 5.300 habitantes contra 3.200."

⇒ Las madres son parecidas en 2014; lo que difiere es el tamaño de la UV.

- **Sin ponderar, las brechas son mayores:** empleo 51,2 contra 53,4% (0,15). El tamaño también: 96 contra 198 madres por UV, y 1.075 contra 2.063 habitantes.
- **Diferencias en diferencias no exige igualdad de niveles:** exige que hubieran seguido tendencias paralelas. El balance no prueba eso.
- **Por qué importa el tamaño:** UV más grandes podrían tener otras tendencias. Las pruebas de pre-tendencias ayudan, pero no lo descartan. Ninguna estimación de esta extracción condiciona por tamaño.
- **Límites:** la UV de 2014 es la de 2016. Esta tabla es solo de la muestra laboral; no hay una equivalente para fertilidad.

### Gráficos de EF de mujer balanceada

Mujeres que aparecen en 2014 y están los 11 años, con UV fija. EE provisorios (error 4). No hay gráfico de ln ingreso: esa estimación está mal (error 1).

**Empleo formal** (`graficos/lab_11_empleo_ef_mujer_bal.png`)
> "Aquí seguimos a las mismas mujeres, todas observadas los once años, con una base de cerca de 54% de empleo formal. Antes de abrir, los coeficientes están cerca de cero, salvo el primero, que agrupa los años más lejanos. Después, el empleo sube de a poco: en promedio 0,7 puntos en los primeros ocho años, y es significativo. El aumento se concentra desde el cuarto año, cuando es cerca de 1,2 puntos."

⇒ Con exactamente las mismas mujeres, el empleo sube y es significativo.

- k = 0–3: +0,21 (0,23). k = 4–7: +1,17 (0,42). Pre-tendencias: p = 0,10 con bin, 0,93 sin bin.

**Ingreso con ceros** (`graficos/lab_12_ingreso_ef_mujer_bal.png`)
> "Con las mismas mujeres, el ingreso promedio es cerca de 1,2% más alto en los primeros ocho años, unos 5 mil pesos al mes a ingresos de 2024, y no es significativo. Los puntos anteriores a la apertura no son significativos, salvo el primero, que agrupa los años más lejanos y da +6,5."

⇒ Con las mismas mujeres, el aumento de ingreso es cerca de 1% y no es significativo.

- k = 0–3: +0,64 (0,59). k = 4–7: +1,82 (1,18). k = 7 da +3,6 (t = 2,2), solo con las cohortes 2015–2017. Pre-tendencias: p = 0,002 con bin, 0,14 sin bin.

**Tuvo un hijo** (`graficos/fert_09_tuvo_hijo_ef_mujer_bal.png`)
> "Con las mismas mujeres, sobre una base de cerca de 6 nacimientos por 100 mujeres al año, la tasa es 0,21 puntos menor en los primeros ocho años, y no es significativo. Esta versión tiene pre-tendencias: cuatro años antes de abrir, el coeficiente ya es significativo."

⇒ Tampoco hay un efecto significativo en natalidad, y esta versión tiene pre-tendencias.

- k = 0–3: −0,13 (0,13). k = 4–7: −0,28 (0,15). Pre-tendencias: p = 0,009 con bin, 0,006 sin bin.

**Nacimientos acumulados** (`graficos/fert_10_nac_acum_ef_mujer_bal.png`)
> "Con las mismas mujeres, el coeficiente es positivo y pequeño: 0,16 hijos más por 100 mujeres en los primeros ocho años, y no es significativo. Antes de abrir hay pre-tendencias claras, que son esperables en una variable acumulada si las tasas difieren en nivel."

⇒ No hay un cambio significativo en hijos acumulados, y esta versión tiene pre-tendencias.

- k = 0–3: +0,06 (0,19). k = 4–7: +0,27 (0,42). Pre-tendencias: p = 0,000 con bin, 0,029 sin bin.

### Crosswalk: el arreglo y lo que queda

Detalle completo en `RIS/arreglos_20261030/diagnostico_crosswalk_20261030.md`.

**El error:** para traducir cada código RSH de 2016–2021 a su UV 2024, se vota según dónde está su gente el año siguiente. La línea 68 sacaba del diccionario los códigos ambiguo y division, así que su gente no votaba. Un mismo código recibía UV distintas según el año, y las mujeres "se mudaban" sin moverse.

**El arreglo:** todos los códigos entran al diccionario, y en los division queda la UV ganadora. Está aplicado en la copia del RIS.

| | Antes | Después |
|---|---|---|
| Mujeres que cambian de UV al año | 19–26% en 2017–2022 | **4–9%, salvo 2022 = 23%** |
| De las que cambian, con el mismo código RSH | 50–75% | **0–1%; 2022 = 4%** |
| UV tratadas con datos desde 2014 | 241 de 319 | **299 de 319** |

**Efecto en primera etapa** (es la comparación más limpia, porque su muestra no cambió de definición):

| | 28/10 | 04/11 |
|---|---|---|
| Promedio k = 0–7 | +3,58 pp | **+3,04 pp** |
| k = −2 | +0,88 | **+0,31** |
| UV-año | 39.964 | **45.788** |

En empleo e ingreso cambiaron a la vez el crosswalk y la muestra, así que no se puede separar.

**Lo que queda: el salto de 2022.** Sigue sin resolver.
- **Qué es:** en 2022 cambia la cartografía y el método (2021 por votación; 2022 por shapes). 23% de las mujeres cambia de UV, contra 4–9% en otros años. El exceso sugiere que 15–18% podría tener mal la UV en 2016–2021; es una inferencia, no una medición.
- **Es parecido entre grupos:** 25,9% tratadas y 26,3% control (muestra de diseño), así que los efectos fijos de año deberían absorber buena parte.
- **También aparece en el número de UV de la muestra:** en 2022 se suman 203 UV control y 12 tratadas, contra 0 a 30 en otros años.
- **La brecha de empleo no salta solo ese año:** tratadas − control es 0,34 en 2019, 0,87 en 2020, 1,16 en 2021, 1,44 en 2022, 1,62 en 2023 y 1,56 en 2024. En 2022 sube cerca de 1 punto en las cohortes 2017 y 2018, pero no es parejo entre cohortes.
- **Con UV fija, que no tiene este salto, el empleo también crece con k.** Pero una mujer mal asignada queda mal todos los años, lo que puede achicar el efecto.

**Pendiente:** el `24` (UV fija desde 2022) y la robustez sin los códigos 2021 ambiguo o division.

**Cómo decirlo:**
> "Encontramos y corregimos un error en el crosswalk de UV, que creaba mudanzas falsas: pasamos de cerca de 20% de mujeres que cambiaban de UV cada año a 4–9%. Con el arreglo, la primera etapa baja de 3,6 a 3,0 puntos, y el coeficiente previo de k = −2 deja de ser significativo. Queda un salto de una sola vez en 2022, por un cambio de cartografía. Afecta de forma parecida a tratadas y control, pero todavía lo estamos revisando."

⇒ El arreglo eliminó las mudanzas falsas y mejoró las pre-tendencias; queda por resolver el salto de 2022.

### Regla de entrada con EF de mujer

**La regla no es igual para tratadas y control** (`08a` l.34–37, `08b` l.27–29): una tratada solo entra si aparece antes de que abra el jardín de su UV; una control puede aparecer en cualquier año. Lo primero lo exige el diseño, porque hay que ver a la mujer antes de abrir.

**Por qué podría importar:** después de la apertura, las control incluyen mujeres recién aparecidas y las tratadas no. Si en sus primeros años en el RSH esas mujeres cambian distinto que las demás (por ejemplo, entran a trabajar más), el cambio del control no representa lo que les habría pasado a las tratadas. La dirección y el tamaño no están medidos.

**El chequeo disponible es la versión EF balanceada:** exige aparecer en 2014 y tener los 11 años, tanto a tratadas como a control, así que no tiene esta diferencia.

| k = 0–7 | EF de mujer | EF balanceada |
|---|---|---|
| Empleo formal (pp) | +0,55 (0,29) | +0,69 (0,29) |
| Ingreso con ceros (%) | +0,97 (0,71) | +1,23 (0,82) |
| Tuvo un hijo (pp) | −0,13 (0,12) | −0,21 (0,13) |
| Nac. acumulados (por 100 mujeres) | +0,25 (0,25) | +0,16 (0,29) |

EE provisorios (error 4). Las diferencias son pequeñas comparadas con los EE, así que esta regla no parece mover mucho los resultados. No es una prueba: la balanceada también cambia de mujeres, porque saca a las que no están todos los años.

**Cómo decirlo:**
> "Con efecto fijo de mujer, una tratada solo entra si la vemos antes de la apertura, mientras que una control puede aparecer en cualquier año. Para ver si eso importa, usamos la versión balanceada, donde todas aparecen desde 2014, y los resultados son parecidos."

⇒ La regla de entrada no parece cambiar mucho los resultados, aunque no está medida directamente.
