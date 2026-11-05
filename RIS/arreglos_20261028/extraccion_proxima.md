# Próxima extracción: lista en curso

## Reglas para no confundir archivos

1. **Carpeta nueva cada semana** (`Extracción\AAAAMMDD`), vacía al empezar. Cambiar la fecha en `00_setup.do` (CAMBIO 1).
2. **No convertir dta → csv a mano.** `guardarV` exporta la V sola a la carpeta de la semana (CAMBIO 2), y al final de cada do-file va `exportar coefs_...` (CAMBIO 3). Si un archivo está en la carpeta, salió de una estimación de esa semana.
3. **No copiar nada de `$est` a la carpeta de extracción.** Ahí están los archivos de todas las semanas con nombres casi iguales: el 28/10 se fue la V de empleo del 14/10.
4. **Antes de mandar:** abrir cada V y comparar la dimensión con la columna del correo (todas las V del modelo principal son 14 x 14; 13 x 13 = sin 2015).
5. **Al llegar:** `python RIS/revisar_extraccion.py RIS/AAAAMMDD` revisa que cada V calce con un modelo de los coefs de la misma carpeta.

## Archivos pendientes de la extracción del 28/10 (ya existen en el RIS, no hay que re-estimar)

| Archivo | Por qué |
|---|---|
| `V_sa_w_fija_empleo_formal` (14 x 14) | Se extrajo la V antigua del 14/10 (v60 sin 2015, base original) en vez de esta. Necesaria para el test de pre-tendencias de empleo |
| `V_sa_w_fija_ln_ingreso` (14 x 14) | No llegó |
| `03_primera_etapa_v60.do` | No llegó; necesario para entender el panel balanceado |

## Rescatar EF de mujer (08a / 08b) desde los logs

Aunque el `.dta` de coefs del 08a quedó vacío, **cada `eventstudyinteract` imprime su tabla de coeficientes en el log**. Abrir en el RIS:
- `$est/log_indm_empleo_20261019.txt` → deberían estar las tablas de empleo, ingreso_rel y ln_ingreso (muestra completa) y empleo balanceado (las 4 que corrieron antes del error).
- `$est/log_indm_fert_20261019.txt` → tabla de tuvo_hijo balanceado (la completa ya llegó).

Si están: extraerlas como tablas del log (cada tabla = 1 elemento). Ojo: si después se corrió otra versión con `log ... replace`, el log tiene solo la última corrida.

Ya en `$est` (guardadas antes del error): `V_sa_indm_ingreso_rel.dta` y `V_sa_indm_ln_ingreso.dta` (muestra completa). `V_sa_indm_empleo_formal.dta` quedó sobrescrita con la del balanceado.

## Estimaciones nuevas propuestas

### 02: chequeo de composición (ciclo de vida) — antes del `postclose pf`
¿Cambia la mezcla de madres con hijos chicos vs grandes con la apertura? Si sale ≈ 0, el ciclo de vida se cancela entre tratadas y control.

```stata
* CAMBIO 6: composicion. Outcome = n° de hijos menores de 5 por madre (ya esta en el collapse)
quietly sum n_hijos_menor5 if nunca_tratada == 1 [aw= n_mujeres]
local m0w = r(mean)
eventstudyinteract n_hijos_menor5 d1-d4 d6-d15 [aw= n_mujeres], cohort(g1) control_cohort(nunca_tratada) covariates(per_edad) absorb(id_uv_2024 anio) vce(cluster id_uv_2024)
guardar sa_w n_hijos_menor5 `m0w'
guardarV sa_w_fija_n_hijos_menor5
```

## Chequeo: cuánto suma el ingreso independiente (para la diapo de arreglos)
No quedó en el log del 28/10, porque el 01 lo sobreescribió. En `02_laboral_v60.do`, agregar dos `sum` alrededor de la línea que suma el independiente (solo miran, no cambian nada):
```stata
replace ingreso_anual =monto_cot if missing(renta_imponible_anual)
* CAMBIO 7: media del ingreso SIN independiente
sum ingreso_anual if ingreso_anual > 0
replace ingreso_anual = renta_imponible_anual + monto_indep_anual if !missing(monto_indep_anual) & !missing(renta_imponible_anual)
* CAMBIO 7: media del ingreso CON independiente y % de madres con independiente
sum ingreso_anual if ingreso_anual > 0
count if monto_indep_anual > 0 & !missing(monto_indep_anual) & !missing(renta_imponible_anual)
```
Anotar las dos medias y el conteo. Ojo: el log del 02 tiene que tener nombre propio, distinto del 01.

## 21_laboral_todas (corrió; visto en el RIS 30/10)
Misma forma que madres, magnitudes más chicas, menos pre-tendencia en empleo formal. Extraer coefs + V (empleo, ingreso_rel, ln_ingreso) y el do-file.
Anotar a mano: % de mujeres con `tiene_hijo_menor5 == 1` en la muestra del 21 (para ver si la diferencia con madres es solo dilución).
