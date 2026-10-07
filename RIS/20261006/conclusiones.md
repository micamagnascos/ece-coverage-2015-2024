# Conclusiones RIS 06/10/2026

## Primera etapa

**Efecto de +3 pp significativo.** Ponderado por niños, +2 pp.

- La matrícula sube desde el mismo año de apertura y se mantiene estable.
- No hay pre-tendencias con Sun-Abraham. El k = −2 negativo de semanas anteriores era del estimador TWFE.
- Es un efecto chico: unos 3–4 niños más matriculados por UV, poco frente a los cupos de un jardín.

### Por qué el efecto es chico
1. La cohorte 2015 tiene un efecto casi nulo y es casi la mitad de las tratadas. Posible error de registro: jardines que ya existían en 2014.
2. Ponderar por niños diluye: los mismos cupos en UVs más grandes mueven menos la tasa.
3. El denominador incluye niños de 4 años, que ya están mayoritariamente matriculados.
4. Sustitución: el jardín nuevo se puede llenar con niños que ya iban a otro.
5. Spillovers hacia los controles: descartado con el control limpio.

### Cohorte 2015
- Efecto pequeño y gradual, menor que el de las otras cohortes. Revisar en detalle.
  - *Es la única cohorte en los últimos años del event study y no aporta a los años previos.
- **Sin 2015: efecto de +4,7 pp significativo**, un 50% mayor y estable en todo el período.
  - Disclaimer: números leídos en pantalla, falta confirmar con V. Si las aperturas 2015 son errores de registro, el efecto real es 4,7 pp; si son reales, el efecto difiere por cohorte y vale el de 3 pp.

### Por edad del niño
**Efecto significativo en los tres grupos.**
- Sala cuna: chico en pp, pero el mayor en términos relativos, y crece con los años.
- Nivel medio: el mayor efecto, inmediato y estable.
- Transición: efecto inesperado.
  - *Revisar cuándo corta realmente la edad: hoy se usa la edad a diciembre, no al corte de matrícula.

### Control limpio
**Mismo efecto con los tres grupos de control.**
- Qué es: si los niños de UVs de control vecinas se matriculan en el jardín nuevo, la matrícula del control también sube y el efecto se subestima. Para evitarlo, se sacan del control las UVs que podrían estar "contaminadas":
  - todas las nunca tratadas (principal);
  - sin vecina que abrió un jardín entre 2015 y 2024;
  - sin ningún jardín vecino en ningún año.
- La idea era encontrar una primera etapa mayor con controles "más limpios". No funcionó.
- Los spillovers no explican que el efecto sea chico.

## Fertilidad

**Efecto no significativo.**
- Tratadas y controles caen igual en el tiempo, sin cambio en la apertura.
- Es un cero razonablemente preciso: se descartan efectos grandes.

## Mercado laboral

### Tendencias crudas
- Cohorte 2016: sube a la vez en empleo, ingreso y meses, con un par de años de rezago. Es también la cohorte con mayor primera etapa.
- Cohorte 2015: el ingreso cae desde el inicio. No se puede saber si es efecto o tendencia propia, y puede tirar el promedio hacia abajo.
- Cohortes 2020–2024: tendencias previas muy fuertes. Son las que forman los años pre del event study.

### Empleo formal
**Efecto de ~+1 pp significativo desde el cuarto año, con cautela.**
- No pasa nada al abrir el jardín; el empleo sube gradualmente.
- Las pre-tendencias no son significativas, pero vienen subiendo. No se puede descartar que el efecto sea la continuación de una tendencia previa.
  - Disclaimer: los años pre y post vienen de cohortes distintas, así que no son las mismas UVs.
  - *Pendiente: event study con panel balanceado.

### Ingreso
**Efecto de +2–4% no significativo, pero sugerente.**
- Misma forma gradual que el empleo y sin pre-tendencias.
- En pesos, aproximadamente $10–20 mil más al mes.
- Se mide solo entre las madres que trabajan, así que probablemente subestima el efecto.
  - *Falta la V del ponderado para confirmar la significancia.

### Meses trabajando
**Efecto no significativo.**
- Sería como un día más trabajado al año, sin sentido económico.
- El jardín cambia si las madres trabajan, no cuánto.

### Por edad del hijo menor
**Efecto de +1 a +2 pp no significativo, pero sugerente.**
- Hay efecto positivo en las madres con hijo menor de 0 a 3 años y ninguno con hijo de 4.
- Calza con el mecanismo: de 0 a 3 años la madre tiene que cuidarlo y aún no puede ir a pre-kínder.
- Lo informativo es el patrón entre grupos, no cada coeficiente.

## Horas y variables RSH

Variables (Ficha RSH, autoreportadas por la madre):
- Horas: horas semanales trabajadas, solo entre las que trabajan.
- Busca: % que buscó trabajo, entre las que responden la pregunta (en la práctica, las que no trabajan).
- Cuida: % que no busca trabajo porque "no tiene con quién dejar a los niños". Es la más ligada al jardín.
- Hogar: % que no busca trabajo por "quehaceres del hogar".
- Cuida u hogar: la suma de las dos anteriores.

Cuidados al leerlas:
- La razón de no buscar trabajo solo la responden las madres que no trabajan ni buscan. A todas las demás se les asigna 0, así que cuida y hogar son un % sobre todas las madres. Si más madres empiezan a trabajar, estos % bajan, y eso también es parte del efecto.
- La ficha no se actualiza todos los años: la misma respuesta se puede repetir varios años, así que los cambios son lentos y ruidosos.
- Hay UVs con muy pocas respuestas (algunas con ~4 mujeres). Son estimaciones exploratorias, para observar.

### Horas
**Efecto no significativo.**
- Las que ya trabajan no cambian su jornada.
- Junto con meses trabajados: el jardín cambia si las madres trabajan, no cuánto.

### Busca trabajo
**Efecto no significativo.**
- Leve indicio de que aumenta la búsqueda en los primeros años.

### "No tiene con quién dejar a los niños"
**Efecto de −0,7 pp significativo, pero frágil.**
- Qué compara: cuida = 1 si la madre no trabaja, no busca, y la razón es no tener con quién dejar a los niños. Cuida = 0 para todo el resto: las que trabajan, las que buscan, las inactivas por otra razón y las sin dato.
- Baja después de la apertura y sin pre-tendencias, pero se debilita al ponderar. Sin ponderar es el modelo más expuesto a las UVs con pocas respuestas.
- No sabemos adónde se fueron esas madres: pueden haber empezado a trabajar, a buscar trabajo, o seguir inactivas pero dando otra razón.
- Es evidencia de apoyo al mecanismo, no un resultado principal.

### "Quehaceres del hogar" y cuida u hogar
**No interpretables.**
- Hogar es plano en todo el período salvo una caída justo antes y en el año de apertura. Como todo se compara contra el año anterior a la apertura, lo demás parece "alto". Es un problema del año de referencia, no un efecto.
- La suma de ambos hereda el mismo problema.
- Hogar no sube después de la apertura, así que no hay evidencia de que las madres cambiaran "cuidado" por "hogar" como razón.

## Por hacer
- **Estimar todo sin la cohorte 2015.**
- **Mercado laboral: estimar el ingreso de todas las madres, incluyendo a las que no trabajan.**
