# Conclusiones extracción 28/10 (solo puntos marcados)

## Primera etapa

**Niveles de partida (pregunta de los profes).** Tasa de matrícula 0–4, hijos de madres v60:

| | Tratadas | Control | Brecha |
|---|---|---|---|
| 2014 | 29,5% | 31,1% | −1,6 pp |
| Promedio años pre (k < 0) | 31,7% | 32,6% | −0,9 pp |
| Año antes de abrir (k = −1) | 31,3% | 33,1% | −1,8 pp |
| Promedio años post (k ≥ 0) | 36,6% | 34,8% | +1,8 pp |

⇒ Las tratadas parten algo por debajo (los jardines abren donde hay menos matrícula) y terminan por encima. El DiD no exige niveles iguales, solo tendencias paralelas; el efecto SA es +3,5 pp (≈ +10% sobre 34%).

## Exposición por edad del niño al abrir (guardado, NO presentar el 29/10)

Pregunta: ¿los niños que pueden aprovechar más el jardín (expuestos desde más chicos) tienen un efecto mayor?

| Grupo | Efecto (años matriculado entre 0 y 4) | EE |
|---|---|---|
| 1. Nació el año de apertura o después | +0,146 | 0,028 |
| 2. Tenía 1–2 años | +0,142 | 0,026 |
| 3. Tenía 3–4 años | +0,053 | 0,016 |

Gráfico: `graficos/pe_04_exposicion.png`. Media control 1,36 años.

- Código del 14 revisado: sin errores, hace lo acordado el 20/10.
- Respuesta parcial: sí, más exposición ⇒ más efecto entre grupos 1–2 y grupo 3 (~3 veces más). Pero nacer después de la apertura no da más que tener 1–2 años.
- Una posible razón de 1 ≈ 2 (por entender mejor antes de mostrar): si a los 0–1 años casi nadie va al jardín, ambos grupos tienen los mismos años "aprovechables".
- Pendientes RIS: pérdida de niños por tratamiento (`tab n_anios tratada if esperado == 5, col`), media control solo nacidos 2014–2020, revisar por qué hay 3.260 UV y no 4.415.

## Para el viernes: revisar UV y votaciones del crosswalk

No es para decirlo en la reunión, es para revisar yo.

- Que una UV 2024 aparezca un año depende de que alguna persona del RSH de ese año quede asignada a ella por el crosswalk.
- El número de UV salta de golpe 2020 → 2021 en las 3 bases (primera etapa, laboral y fertilidad): control ~3.100 → ~3.900, tratadas 249 → 305. Las personas crecen solo ~2%. Solo 241 de las 319 tratadas tienen datos en 2014.
- Sospecha: la votación hacia atrás asigna cada código antiguo a UNA sola UV 2024. Cuando una UV se dividió, el otro pedazo queda vacío antes de 2021 y su gente queda contada en la UV "hermana".
- Coincide con que las UV tratadas tengan ~198 niños por UV antes de la apertura y ~121 después: antes de 2021 hay menos UV pero más grandes.
- El k = −2 de primera etapa era plano el 06/10 (−0,2 pp) y ahora es +0,9 pp: apareció con los cambios de esta semana, uno de ellos el crosswalk nuevo.
- Puede estar relacionado con las mudanzas de ~20–24% todos los años (también muy alto).
- ⇒ Revisar bien el crosswalk y las votaciones; puede que no esté funcionando bien.
- Chequeo en el RIS: `bys id_uv_2024: egen primer_anio = min(anio)` + `tab primer_anio`, y ver si las que parten en 2021 son las "division". Robustez posible: estimar solo con UV observadas desde 2014.

## Empleo: duda de ciclo de vida (solo para mí)

- El DiD resta el ciclo de vida (dejar de trabajar al tener hijo, volver después) solo si cada año tratadas y control tienen la misma mezcla de madres con guaguas vs hijos grandes.
- Riesgo: si a las UV tratadas entran relativamente menos madres nuevas, su muestra queda "más avanzada" y el empleo sube solo por eso → parecería un efecto gradual.
- Pista: madres de la muestra fija 2014→2024 crecen ×2,4 en control y ×2,1 en tratadas (puede ser en parte el salto de UV de 2021).
- Chequeo: CAMBIO 6 del 02 (event study con `n_hijos_menor5` como outcome; ≈ 0 = OK) en `arreglos_20261028/extraccion_proxima.md`. Además, 08a con mujeres balanceadas.

## Balance 2014 (guardado, no presentar por ahora)

UV tratadas con datos en 2014 (241) vs control (2.982). Dif. est. = diferencia / desv. estándar (< 0,25 balanceado; < 0,1 muy parecido). Ponderada por población de la UV.

| Variable | Control | Tratadas | Dif. est. | Dif. est. ponderada |
|---|---|---|---|---|
| Empleo formal | 44,5% | 47,3% | 0,16 | 0,03 |
| Ln ingreso | 14,29 | 14,30 | 0,02 | −0,01 |
| Ingreso relativo | 83,4 | 89,6 | 0,10 | 0,05 |
| Edad de la madre | 29,2 | 29,1 | −0,06 | 0,05 |
| Hijos menores de 5 | 1,11 | 1,11 | 0,07 | 0,04 |
| Horas trabajadas (FIC) | 37,1 | 38,1 | 0,15 | 0,12 |
| Trabaja (FIC) | 42,3% | 43,6% | 0,07 | 0,03 |
| Educación (código) | 4,69 | 4,85 | 0,13 | 0,06 |
| **Madres por UV** | 69 | 159 | **0,34** | **0,46** |
| **Población de la UV** | 1.072 | 1.923 | **0,42** | **0,33** |
| Densidad de niños | 0,059 | 0,064 | 0,23 | 0,16 |

- Madres muy parecidas; las UV tratadas son ~2 veces más grandes (los jardines abren donde hay más demanda).
- No invalida el DiD (EF de UV), pero si las UV grandes tienen otra tendencia, podría colarse (conectado con la duda de empleo).
- Chequeo posible: tendencias por tercil de población × año, o control restringido a UV de tamaño parecido.
