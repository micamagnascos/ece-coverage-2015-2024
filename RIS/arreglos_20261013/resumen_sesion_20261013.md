# Resumen sesión RIS 13/10/2026

Trabajo del día sobre los comentarios de los profesores (reunión de octubre). Actualización con ellos: **jueves 15/10**.
Números leídos en pantalla; se confirman con la extracción del 14/10.

## 1. Comentarios de los profesores y qué hicimos

| Comentario | Estado |
|---|---|
| ¿Cuántas mujeres se cambian de UV? | Hecho (08). Ver `mudanzas_uv.md` |
| Restringir al 60% más vulnerable | Hecho en la muestra actual (08) y en las muestras nuevas (09–11) |
| Muestra laboral: madres que tuvieron hijo menor de 5 en algún momento, todos los años | En el 09 (corriendo) |
| Estimación a nivel individual | Primera versión hecha (08); pregunta enviada a los profes sobre la especificación |
| Tratamiento según el stock inicial de jardines | Pendiente, requiere diseño |
| Muestra por probabilidad de embarazo | Pendiente |

## 2. Mudanzas (detalle en `mudanzas_uv.md`)

- `cambia_uv` (código RSH, todo el panel 2016–2024): **49%** de las mujeres.
- `cambia` (UV 2024, años en la muestra, desde 2017): **~32%** de las mujeres comparables, **~9% por año**.
- Tasa anual de 7–12%, **salvo 2022 con 26%**: probablemente artefacto de cartografía (primer año "bueno" de las cartografías).
- La movilidad diluye el efecto a nivel UV → argumento para la estimación individual.

## 3. 60% más vulnerable (detalle en `vulnerables_v60.md`)

- Variable: `calc_quintil_validacion2` (tramo CSE: 40/50/60 = más vulnerable). `v60 = tramo ≤ 60`, fijo por mujer en su primer año RSH desde 2016.
- 66% de las mujeres en v60; 10% sin clasificar = las que solo aparecen en 2014–2015 (se recuperan en el 09 con `puntaje`).
- **Empleo formal a nivel UV (SA ponderado):** coeficientes parecidos a la muestra completa (~+2% relativo), pero el SE casi se duplica → menos significativo. Es precisión, no un efecto menor.

## 4. Ingreso

- **`ingreso_rel` (todas las madres, 0 si no trabaja, como % del promedio del año): significativo.**
- **`ln_ingreso` (solo las que trabajan): no significativo.**
- Lectura: el ingreso total sube porque **más madres pasan a trabajar formalmente**, no porque las que ya trabajaban ganen más. Calza con empleo ↑ y meses/horas sin cambio. `ln_ingreso` además tiene sesgo de composición (las que entran ganan menos).

## 5. Estimación individual

- **Empleo formal se vuelve más significativo a nivel individual** y con los cambios de muestra. A confirmar con la extracción (modelo, k, magnitud).
- Teoría:
  - Con efectos fijos de **UV** y año, la estimación individual da casi lo mismo que la estimación UV ponderada por número de mujeres (el tratamiento varía solo por UV-año). Las diferencias vienen del control por edad individual y de la muestra.
  - Lo que sí cambia el análisis: **efecto fijo de mujer** (misma mujer antes y después; elimina composición por entradas, salidas y mudanzas), tratamiento según la **UV inicial**, o **controles individuales**.
  - Con efecto fijo de mujer las estimaciones **se demoran mucho** en el RIS.
- `ingreso_rel` a nivel individual sí tiene sentido (regresión lineal en niveles, los 0 no son problema). Cuidado con valores extremos: considerar acotar el 1% superior en el do-file de muestra.
- WhatsApp enviado a los profes: ¿efecto fijo de mujer, UV inicial o efecto fijo de UV con controles?

## 6. Muestras nuevas (definición en los do-files de muestra)

Regla: **todo lo que define la muestra va en los do-files de muestra**, no en los de estimaciones.

| Do-file | Qué hace | Guarda | Estado |
|---|---|---|---|
| `09_merge_muestra_v60.do` | Mudanzas con UV 2024 (`mueve24`, `cambia_uv24`, `cambia_uv24_s22`); v60 fijo por mujer (solo tramo RSH ≤ 60 desde 2016; sin puntaje, las que solo están en 2014–15 quedan fuera); laboral = alguna vez hijo menor de 5, todos los años | `muestra_laboral_v60`, `muestra_fertilidad_v60`, `muestra_completa_ruts_trat_v60` (sin filtrar) | Corriendo (maestro) |
| `10_fertilidad_uvs_v60.do` | Colapso de fertilidad a UV-año | `muestra_fertilidad_v60_uvs` | **Correr el 14/10** |
| `11_primera_etapa_v60.do` | Panel de niños, hijos de madres v60 | `primera_etapa_panel_v60`, `primera_etapa_panel_v60_uv` | Corriendo (maestro) |

Log único del maestro: `log_muestras_v60_20261013.txt`.

## 7. Plan para el 14/10

1. **Temprano: pedir extracción** de `coefs_lab_v60`, `coefs_lab_ind_v60`, las V (`V_sa_v60_*`, `V_sa_w_v60_*`, `V_sa_v60s15_*`, `V_sa_w_v60s15_*`, `V_sa_ind_*`), `log_08_20261013.txt` y el log del maestro.
2. Revisar en el log del maestro que las muestras nuevas quedaron bien (tabs del 60%, mudanzas, counts).
3. Correr el **10** (fertilidad).
4. Adaptar las estimaciones 01, 02 y 03 a las bases v60 (carpeta nueva de resultados para no pisar nada) y poner la **estimación individual dentro del 02** (y del 01), antes del colapso.
5. Revisar en detalle empleo formal a nivel individual (con y sin efecto fijo de mujer).
6. Completar `mudanzas_uv.md` y `vulnerables_v60.md` con los números exactos y preparar el jueves.

## 8. Recordatorios

- ⚠️ `coefs_lab.dta` en el RIS quedó **pisado** con los resultados v60 → volver a correr el **02 de la muestra completa** (con el guardarV ponderado).
- Lección del día: en los do-files del RIS, **solo programas del 00_setup** (`guardar`, `guardarV`, `grafico`), **sin `graph export`** y sin tocar el setup.
