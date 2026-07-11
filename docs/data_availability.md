# Disponibilidad de datos

## Fuentes

- **JUNJI** (`data/raw/junji.xlsx`): bases estadísticas mensuales de la Junta Nacional de
  Jardines Infantiles, procesadas por la oficina de Análisis y Reportabilidad de Datos y
  Estadísticas del Departamento de Planificación de JUNJI. Obtenidas por solicitud de
  acceso a información pública (Ley N°20.285). Período: años parvularios 2015-2024.
- **Integra** (`data/raw/integra.xlsx`): listado de establecimientos en funcionamiento
  2015-2024 (corte a noviembre de cada año), obtenido por solicitud de acceso a
  información pública a Fundación Integra.
- **Unidades vecinales** (`data/raw/unidades-vecinales_2023/`): shapefile de unidades
  vecinales, Ministerio de Desarrollo Social y Familia, julio 2023.

**Pendiente de completar por el equipo del proyecto:**
- Número(s) y fecha(s) de las solicitudes de transparencia que originaron `junji.xlsx`
  e `integra.xlsx` (hay un archivo lock `~$SAIP_6396.tmp` encontrado en la carpeta
  original, que sugiere una solicitud SAIP N°6396 — verificar si corresponde a alguna
  de las dos bases y completar la referencia exacta aquí).
- Fecha de obtención de cada base.

## Redistribución

Las respuestas a solicitudes de transparencia son en general información pública una
vez entregadas, pero **antes de subir `junji.xlsx`/`integra.xlsx` crudos a un
repositorio (privado o público)** se recomienda:

1. Confirmar en la carta/oficio de respuesta de cada solicitud si existe alguna
   restricción explícita de redistribución.
2. Evaluar si `data/raw/` se sube tal cual, o si el repo solo documenta el proceso de
   obtención (este archivo + los oficios de respuesta) y cada usuario debe volver a
   solicitar los datos por su cuenta.

## Nivel de agregación y datos sensibles

- `data/build/junji_limpia.*` e `integra_limpia.*` son a **nivel de establecimiento**
  (nombre, dirección, coordenadas) — información ya pública por ser parte de la
  respuesta de transparencia, pero es administrativa/institucional (jardines
  infantiles), no contiene datos personales de individuos.
- `data/final/base_cobertura_cp.dta` (el panel final) está agregado a **nivel de
  unidad vecinal x año** (conteos de establecimientos) — no permite identificar
  establecimientos ni personas individuales. Este archivo es el candidato más seguro
  para compartir públicamente si se decide no redistribuir los raw.
