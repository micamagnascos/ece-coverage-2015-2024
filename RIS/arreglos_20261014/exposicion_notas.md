# Exposición por edad del niño al abrir el jardín: decisiones de diseño

Notas del 20/10/2026 sobre el `14_exposicion_pe.do`. Pedido de los profes (15/10): si el niño tenía 0 años cuando abrió el jardín, tuvo todo el efecto; si tenía 3, poco.

## Qué estima el 14

- **Base:** una fila por niño (hijos de madres v60), con su UV y la cohorte de apertura `g1` del primer año observado.
- **Outcome:** `anios_mat` = años matriculado entre los 0 y los 4 años.
- **Grupos (`expo`)** según `edad_ap = g1 − anio_nac_hijo`:
  - 1 = nació el año de la apertura o después (exposición completa)
  - 2 = tenía 1–2 años
  - 3 = tenía 3–4 años
  - 0 = referencia: UVs nunca tratadas y niños que ya tenían 5 o más
- **Regresión:** `reghdfe anios_mat i.expo, absorb(id_uv_2024 anio_nac_hijo) cluster(id_uv_2024)`.
- **Diseño:** diferencia en diferencias entre cohortes de nacimiento (Duflo, 2001: escuelas en Indonesia). Compara niños de la misma UV y nacidos el mismo año con distinta exposición.
- **Esperado:** coeficientes que bajan de 1 a 3 (más exposición, más años matriculado).

## Por qué NO un event study por grupo de exposición

1. **Las UVs nunca tratadas no tienen "edad al abrir el jardín".** Esos niños no caen en ningún grupo, así que no hay controles naturales para cada grupo.
2. **Dentro de cada grupo, la edad avanza con k.** La matrícula depende mucho de la edad, así que el gráfico mostraría a los niños creciendo, no el efecto del jardín. Ejemplo, grupo 3: en k = −3 tienen 0–1 años, en k = 0 tienen 3–4, y en k = +2 ya salieron de la base.
3. **Cada grupo existe solo en algunos k.** El grupo 1 no tiene ningún k negativo (no había nacido).

**Lo que sí funciona como event study por submuestras** es la **edad del niño ese año** (0–1, 2–3, 4). Esa edad existe para tratados y controles. Es el `04_heterogeneidad_edad.do`, pendiente de ponderar. Responde otra pregunta: en qué nivel sube la matrícula.

## Por qué NO efecto fijo de niño

- **El EF de niño solo usa la variación dentro de cada niño** (sus años antes y después de la apertura).
- **Los niños nacidos después de la apertura no aportan nada:** siempre estuvieron tratados. Son justo el grupo de exposición completa.
- **El "antes" de los que sí aportan son sus años más chicos**, cuando casi no van al jardín. Con EF de niño y de año, la edad queda casi colineal.
- **Es muy lento en el RIS:** millones de niños-año.

## Qué niños entran

- **Nacidos 2010–2013: sí.** Se ven desde 2014. Les faltan años, pero anteriores a 2014, cuando no había abierto ningún jardín (la primera cohorte es 2015). Son años no tratados, iguales para tratados y controles del mismo año de nacimiento, así que el EF de año de nacimiento los absorbe. Aportan a los grupos 2 y 3.
- **Nacidos 2014–2020: sí.** Se ven completos de 0 a 4.
- **Nacidos 2021 o después: no.** No alcanzan a cumplir 4 en 2024, y lo que falta son años **posteriores** a la apertura (tratados), así que se subestimaría el efecto.
- **Años esperados:** `esperado = min(5, anio_nac_hijo − 2009)`, porque un niño cumple 4 en `anio_nac_hijo + 4` y se ve desde 2014: (anio_nac + 4) − 2014 + 1. Se dejan solo los niños con `n_anios == esperado`.

## Pendiente de revisar con la extracción

- **Niños con 1 año visto y 5 esperados** (vistos en pantalla el 20/10, varios). Razones posibles:
  - la madre aparece un solo año en el RSH;
  - la madre se mudó a una UV fuera de la muestra;
  - el niño falleció.

  Chequear que la pérdida no sea distinta entre tratadas y controles: `tab n_anios tratada if esperado == 5, col`.
- **Es un TWFE con aperturas escalonadas:** tiene los riesgos de comparaciones "prohibidas" (Baker et al.). Presentarlo como **dosis-respuesta**, no como efecto principal (que sigue siendo el event study del 03).
- **La UV del niño es la de su primer año observado** (ITT). Para los nacidos antes de 2014, es la de 2014, no la del nacimiento.
