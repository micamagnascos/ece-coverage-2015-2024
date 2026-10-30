# Guion reunión 29/10

Números de diapo = PDF actual (30 diapos + anexo). ● = diapo nueva.
Cada diapo trae: **Decir** (lo que cuesta explicar o no está escrito) y **Si preguntan** (respuestas guardadas).

---

## Partir aquí → 7 y 8: el arreglo de 2015 (lo primero que hay que explicar)
Frase de entrada: "Esta semana re-estimamos todo con los datos corregidos. Lo primero que arreglamos fue el año de apertura de los jardines, que cambia quién está tratado."

## 7 ● Cohortes de tratamiento
- **Decir:** "En gris está cómo eran las cohortes antes y en azul cómo quedan ahora. El cambio está casi todo en 2015, que pasa de 179 a 51 UV. En 127 UV la 'apertura' de 2015 era en realidad un jardín que ya funcionaba en 2014. Las otras cohortes casi no cambian. En total, las tratadas pasan de 447 a 319."
- "Ahora las aperturas están repartidas entre 2015 y 2019, y la cohorte más grande es 2017. Casi 60% abre entre 2015 y 2017."
- **Si preguntan por qué importa:** "Una UV que figuraba como tratada sin haber abierto nada nuevo tiene efecto cero y baja el promedio. Además, la cohorte 2015 tiene un solo año previo (2014), así que pesaba mucho en los post y casi nada en los pre."

## 8 ● Cómo lo resolvimos
- **Decir:** "El problema era la fecha de apertura de JUNJI. Sus registros parten en marzo de 2015, así que todo jardín sin registro anterior quedaba con fecha 1 de marzo de 2015. Eso era el 84% de las aperturas de 2015."
- "Para comprobarlo usamos los paneles de jardines por año de las solicitudes de transparencia. De los jardines con fecha 01-03-2015, el 96% ya existía antes. Ahora el año de apertura es el primer año en que el jardín aparece en los paneles."
- "Todo lo que viene está re-estimado con este tratamiento corregido."
- **Si preguntan adónde se fueron las 128 UV:** "Ya tenían un jardín en 2014, así que quedan en el grupo excluido (UV con jardín al inicio), igual que cualquier UV que ya tenía jardín."
- **Si preguntan por Integra:** "También tiene panel por año, 2001–2024, y se aplica la misma regla."

## 9–11: pasar rápido (especificación, datos, mapa de UV 2024)

---

## 12 ● Muestras
- **Decir:** "Dos cambios en la muestra laboral. Primero, las madres ahora se quedan en la muestra hasta 2024, aunque su hijo ya tenga más de 5. Antes salían justo cuando llevaban más tiempo expuestas. Segundo, el ingreso ahora incluye el ingreso independiente."
- **Si preguntan cuánto sube la media con el independiente:** "No lo tengo todavía; viene en la próxima extracción." (CAMBIO 7)

## 13 ● Crosswalk
- **Decir (siguiendo el esquema):**
  - **Fila de arriba:** "Para saber en qué UV de 2024 vive cada mujer necesito dos bases. El RSH me dice el código de su UV en ese año, y los mapas me dicen a qué UV de 2024 corresponde cada código. Desde 2022 las dos usan los mismos códigos; antes no."
  - **Fila de abajo:** "Para los años anteriores sigo a los hogares hacia atrás. Parto en 2022, donde los códigos ya calzan, y voy año a año."
  - **Ejemplo:** "Si el código A de 2021 tiene 10 hogares y 8 de ellos viven en la UV 105 en 2022, entonces A es la UV 105. Después hago lo mismo con 2020 contra 2021, y así hasta 2016."
  - **Texto de abajo:** "Antes usaba este método en algunos años y similitud de códigos en otros, y eso dejaba un quiebre. Ahora uso este método en todos los años."
- **Si preguntan qué años iban con cada método:** no entrar en detalle. "Unos años tenían códigos parecidos y se emparejaron por similitud; ahora todos usan el mismo método."
- **No mencionar:** el 122 → 7, el 20% de mudanzas ni el salto de UV en 2021.

## 14 ● Arreglos de datos
- **Decir:** "Los arreglos 1 y 2 corrigen quién está tratado. Si una UV figura como tratada pero no abrió nada nuevo, su efecto es cero y baja el promedio. Por eso, al corregirlo, los efectos suben."
- **Si preguntan cuánto:** "Como idea gruesa, con 128 de 447 tratadas falsas el promedio salía en ~70% del efecto real (319/447). En la práctica subió más, porque el crosswalk también ayudó."

## 15 ● Primera etapa
- **Decir:** "Antes de abrir, las tratadas tienen 31% de matrícula y el control 33%: los jardines abren donde hay menos matrícula. Cuando abre un jardín, la matrícula sube 3,6 puntos, un 10% sobre la media control de 34%. Salta el mismo año y se mantiene. Son unos 5 niños más por UV, el doble de lo que teníamos."
- **Si preguntan por qué se compara con 34% y no con 31%:** "Porque el control representa lo que habría pasado sin jardín; es la convención."
- **Si preguntan por la cohorte 2015:** "Ahora sacarla no cambia nada: 3,58 con y sin ella."
- **Si preguntan por qué casi no cambia con la muestra v60:** "Casi todo el cambio viene del arreglo de los datos, no de la muestra."
- **Si preguntan por el k = −2:** ir al **anexo A13 (diapo 44)**:
  - "k = −1 es la referencia, siempre vale 0. k = −2 queda casi un punto arriba, pero k = −3 y −5 están al mismo nivel que −1: es un punto suelto, no una tendencia."
  - "Viene de las cohortes 2018–2023 y no es COVID. En el peor caso el efecto sería 2,7 en vez de 3,6. Lo vamos a revisar con HonestDiD."
- **Si preguntan por los niveles en gráfico:** anexo **A12 (diapo 43)**. "Es un event study hecho a mano: el salto en k = 0 se ve en los datos crudos."

## 16 ● Por qué la primera etapa sigue chica
- **Decir:** "Todo lo que ya revisamos está marcado con ✓. Lo importante es que medimos un cambio neto: si los niños de la UV están en cualquier jardín. Un jardín nuevo se puede llenar con niños que ya iban a otro jardín y se cambian al más cercano. Eso no mueve nuestra matrícula, pero sí le ahorra tiempo a la madre. Esto vuelve en ingresos."

## 17 ● Empleo
- **Decir:** "Tratadas y control parten iguales, en 52%. El año de apertura no cambia nada; desde el segundo año sube. En los primeros cinco años, que es cuando el hijo puede usar el jardín, sube casi un punto: unas 2 madres más trabajando por UV. Cuenta a todas las madres de la UV, usen o no el jardín."
- **Si preguntan por qué hay más madres que niños:** "La matrícula es una foto de cada año, porque los niños salen a los 5. El empleo se acumula: la madre que volvió a trabajar sigue trabajando y sigue en la muestra."
- **Si preguntan si k = 0–4 es lo mismo que "hijo menor de 5":** "No exactamente. k son años desde la apertura, y en k = 0 hay madres con hijos de distintas edades. Es la ventana para un hijo nacido cerca de la apertura."
- **Si preguntan por el error estándar del promedio:** "Falta la matriz de varianzas correcta; viene la próxima semana. k = 2, 3 y 4 son significativos por separado."

## 18 ● Pre-tendencias en empleo
- **Decir:** "Los pre son levemente negativos. Eso quiere decir que, antes de abrir, el empleo de las tratadas venía subiendo un poco más rápido que el del control. Pero los pre y los post vienen de cohortes distintas: los pre lejanos solo los aportan las aperturas de 2019 en adelante. Si miro cada cohorte grande por separado, 2016 y 2017, no venían subiendo antes de abrir: la subida empieza después."
- **Si preguntan por el test formal:** "Falta la matriz de varianzas de empleo, que se extrajo mal. Viene la próxima semana, junto con HonestDiD."

## 19 ● Niveles de ingreso
- **Decir:** "La mitad de las madres vulnerables no tiene ingreso formal en un año dado. Las que trabajan ganan unos 770 mil al mes en 2024. Los montos están en pesos de 2024."
- **Si preguntan por qué el ingreso sube tanto en el tiempo:** "En parte es la muestra fija: las madres envejecen y entran madres nuevas. Lo que sea nacional le pasa igual a tratadas y control, y los efectos fijos de año lo eliminan del efecto."
- **Ojo:** el deflactor es aproximado. Si preguntan, decir que se verifica con la serie oficial.

## 20 ● Ingreso de las que trabajan
- **Decir:** "Las que trabajan ganan lo mismo al partir. Después de la apertura, las que trabajan ganan en promedio 1,7% más en los primeros cinco años, unos 14 mil pesos. Se ve más claro desde el tercer año."
- **Ojo:** es el resultado más débil, porque en k = 0–4 solo k = 3 es significativo. No venderlo fuerte.
- **Si preguntan por qué antes no había efecto:** "Ahora el ingreso incluye el independiente y seguimos a las madres más años."

## 21 ● Ingreso con ceros
- **Decir:** "Este junta las dos cosas: cuenta como cero a las que no trabajan. Tratadas y control parten parecidos. En los primeros cinco años, el ingreso promedio de las madres de la UV sube 11 mil pesos al mes, un 2,5%. Es significativo desde el segundo año y no hay pre-tendencias."
- **Si preguntan por qué antes eran 19 mil:** "Ese era el promedio de los 8 años post; en los primeros cinco es menor porque el efecto crece en el tiempo."
- **Si preguntan por el ingreso relativo:** anexo **A14 (diapo 45)**. "Es la misma estimación en otra escala."

## 22 ● De dónde viene el aumento
- **Decir:** "El ingreso promedio es el porcentaje que trabaja por lo que ganan las que trabajan. Si descompongo los 11 mil, la mitad viene de que más madres trabajan y la otra mitad de que las que ya trabajaban ganan más."
- "Lo segundo calza con la idea de la diapo 16: madres que cambian a su hijo a un jardín más cercano. No cambia la matrícula, pero ahorran tiempo y pueden trabajar más horas o en mejores trabajos. Lo podemos verificar con los registros de matrícula: si los niños del jardín nuevo estaban en otro jardín el año anterior."
- **Si preguntan por qué la suma (15k) no da el directo (11k):** "Es una aproximación. Las madres nuevas que entran a trabajar probablemente ganan menos que el promedio, así que el primer canal está sobreestimado."

## 23 ● Fertilidad: dos estimaciones
- **Decir:** "Estimamos fertilidad de dos formas: a nivel UV-año, en azul, igual que los resultados laborales, y con efecto fijo de mujer, en naranjo, donde cada mujer se compara consigo misma y queda en su primera UV aunque se mude. Las dos dan cero. Con efecto fijo de mujer desaparecen además los pre algo positivos."

## 24 ● Niveles de fertilidad
- **Decir:** "Parten en 6% las dos y caen exactamente igual hasta 3%: es la caída de la fecundidad en Chile."
- **Si preguntan por k = −5 y −4 positivos:** "Solo los aportan las cohortes de 2018 en adelante, y el test conjunto no rechaza (p ≈ 0,11)."

## 25 ● Efecto fijo de mujer
- **Decir:** "El panel balanceado retiene un 79% de las madres de 2014, y es parecido en tratadas y control, así que la salida de la muestra no está relacionada con el tratamiento. Los resultados laborales están estimados, pero la extracción falló; llegan la próxima semana."

---

## 27–29: discusión → aquí hay que preguntarles

## 27 ● Panel balanceado
- **Decir:** "Me confunde qué esperan con 'panel balanceado', porque hay tres versiones y responden preocupaciones distintas."
  - "**En tiempo de evento:** las mismas UV en toda la ventana. Responde a que la composición de cohortes cambia entre k."
  - "**En mujeres:** las mismas mujeres todos los años. Responde a que la muestra cambia."
  - "**En UV:** todas las UV todos los años."
- **Preguntar:** "¿Cuál tienen en mente?"

## 28 ● Más años previos
- **Decir:** "Hay datos desde 2011 para todos los outcomes. Propongo partir en 2011, lo que suma 3 años previos por cohorte. El problema es que antes de 2016 no hay UV confiable, así que habría que usar la UV de 2016 de cada mujer. Se pierden las que se fueron antes y no se ven las mudanzas previas."
- **Preguntar:** "¿Les parece aceptable usar la UV de 2016 hacia atrás?"

## 29 ● Seguimiento de pedidos
- **Decir:** recorrer rápido lo verde y detenerse en lo rojo. "Lo que falta partir es redefinir el tratamiento por stock inicial y la muestra por probabilidad de embarazo."
- **Exposición por edad del niño:** decir solo "está estimado, lo estoy revisando". No mostrar resultados.

## 30 ● Próximos pasos
- **Decir:** "La próxima semana: laboral para todas las mujeres vulnerables de 18 a 49 y no solo madres, laboral con efecto fijo de mujer y la matriz de varianzas de empleo para el test de pre-tendencias y HonestDiD."

---

## No decir (notas privadas)
- El salto en el número de UV entre 2020 y 2021, y que los niños por UV bajan de 198 a 121.
- La duda del ciclo de vida en la muestra fija.
- Los resultados de exposición por edad del niño.
- El 122 → 7 del crosswalk y el ~20% de mudanzas anuales.
