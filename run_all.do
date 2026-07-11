*===================================================================
* run_all.do — corre el pipeline completo de construcción del panel
* de cobertura JUNJI/Integra por UV-año (2015-2024)
*
* Requiere:
*   - Stata (probado con las rutas relativas de este repo)
*   - Python 3 con geopandas/pandas instalados (ver requirements.txt)
*     para el paso 2 (spatial join)
*
* Uso: abrir Stata con el directorio de trabajo en la raíz del repo
* y correr `do run_all.do`, o desde la línea de comandos:
*   stata -b do run_all.do
*===================================================================

* Paso 1 — Limpieza JUNJI/Integra (Stata)
do "code/build/01_limpieza_junji_integra.do"

* Paso 2 — Asignación espacial jardín -> UV (Python/GeoPandas)
shell python3 code/build/02_spatial_join_uv.py

* Paso 3 — Construcción del panel UV-año (Stata)
do "code/build/03_panel_uv_anio.do"

di as result "run_all.do: pipeline completo. Panel final en data/final/base_cobertura_cp.dta"
