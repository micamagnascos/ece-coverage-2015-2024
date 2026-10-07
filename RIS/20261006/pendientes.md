# Pendientes tras RIS 06/10/2026

## A. Correcciones en los do-files
1. ⭐ Guardar la V de los modelos ponderados (`guardarV sa_w_…`) en 01, 02, 03 y 05.
2. ⭐ Guardar la V en 04 (heterogeneidad), parte primera etapa y parte laboral.
3. 03: corregir la etiqueta `guardar twfe_w tuvo_hijo` → `tasa_matricula`.
4. 07_ingreso_total: revisar el `lincom` después de `eventstudyinteract` (puede fallar; no hace falta si se guarda V).

## B. Estimaciones nuevas para ganar precisión
1. ⭐ Estimar todo sin la cohorte 2015 (primera etapa con V, fertilidad, laboral, heterogeneidad).
2. ⭐ Ingreso de todas las madres, con $0 para las que no trabajan (`07_ingreso_total.do`).
3. Heterogeneidad laboral ponderada y con control por edad de la madre, guardando V.
4. Event study de empleo con panel balanceado (mismas cohortes en toda la ventana).

## C. Revisar en los datos
1. ⭐ Edad de los niños al corte de matrícula (hoy edad a diciembre). Confirmar corte real y redefinir grupos.
2. ⭐ Cohorte 2015: ¿los jardines que "abren" en 2015 ya tenían matrícula en 2014?
3. Cohorte 2016: la matrícula sube un año antes de la apertura. Revisar fechas de apertura en la base de cobertura.
4. Sustitución entre jardines: matrícula en el jardín nuevo vs aumento neto de matrícula en la UV.
5. `per_fic_trabaja`: confirmar el significado de cada valor (0, 1, 2, 9).

## D. Análisis acá (sin RIS)
1. Escalar el efecto laboral por la primera etapa (misma ponderación).
2. Decidir especificaciones principales: ponderado o no; ventanas k 0–6 / k 4–7.
3. Sensibilidad de la pre-tendencia de empleo (Rambachan y Roth), con la V ponderada.
4. Verificar la cita de Bauernschuster, Hener y Rainer (2016).

## E. Próxima extracción
Traer `coefs_*` y todas las `V_*` (incluidas las ponderadas), más los logs de los do-files nuevos.
