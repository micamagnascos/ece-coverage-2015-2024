# -*- coding: utf-8 -*-
"""Mapa estático de jardines JUNJI e Integra en la Región Metropolitana.

Corre localmente: requiere geopandas y matplotlib (ver requirements.txt) y se
ejecuta desde la raíz del repo (o vía run_all.do, que ya se posiciona ahí).

Input:  data/raw/unidades-vecinales_2023/mdsf_Unidades_Vecinales_Julio2023.shp
        data/build/junji_uv.csv, data/build/integra_uv.csv
        (salida de code/build/02_spatial_join_uv.py)
Output: output/figures/mapa_jardines_rm.png
"""

from pathlib import Path

import contextily as cx
import geopandas as gpd
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data" / "raw"
BUILD = ROOT / "data" / "build"
FIGURES = ROOT / "output" / "figures"

REGION_RM = "METROPOLITANA DE SANTIAGO"
CRS_WEB = "EPSG:3857"  # CRS de los tiles del basemap
PCT_ZOOM = (5, 95)  # percentiles de x/y para acotar al núcleo denso (Gran Santiago)
MARGEN_ZOOM = 0.05  # margen sobre el rango de percentiles

# Cargar shapefile de unidades vecinales, filtrar a la RM y reproyectar
uv = gpd.read_file(RAW / "unidades-vecinales_2023" / "mdsf_Unidades_Vecinales_Julio2023.shp")
uv_rm = uv[uv["t_reg_nom"] == REGION_RM].to_crs(CRS_WEB)

print("Unidades vecinales RM:", uv_rm.shape)

# Cargar CSVs con UV asignada (salida de 02_spatial_join_uv.py)
junji = pd.read_csv(BUILD / "junji_uv.csv", encoding="latin1")
integra = pd.read_csv(BUILD / "integra_uv.csv", encoding="latin1")

# Reconstruir geometría a partir de lat/longi, quedarse con la RM y reproyectar
junji_geo = gpd.GeoDataFrame(
    junji,
    geometry=gpd.points_from_xy(junji["longi"], junji["lat"]),
    crs="EPSG:4326",
).to_crs(CRS_WEB)
junji_geo = junji_geo[junji_geo["nom_region"] == "metropolitana"]

integra_geo = gpd.GeoDataFrame(
    integra,
    geometry=gpd.points_from_xy(integra["longi"], integra["lat"]),
    crs="EPSG:4326",
).to_crs(CRS_WEB)
integra_geo = integra_geo[integra_geo["region"] == "metropolitana"]

print("JUNJI en RM:", junji_geo.shape)
print("Integra en RM:", integra_geo.shape)

# Extent por percentiles de las coordenadas de los jardines: acota al núcleo
# denso del Gran Santiago y descarta outliers periféricos (Til Til, Curacaví,
# Melipilla, Talagante, Paine, María Pinto, etc.)
puntos = pd.concat([junji_geo.geometry, integra_geo.geometry])
x, y = puntos.x.to_numpy(), puntos.y.to_numpy()
xmin, xmax = np.percentile(x, PCT_ZOOM)
ymin, ymax = np.percentile(y, PCT_ZOOM)
dx = (xmax - xmin) * MARGEN_ZOOM
dy = (ymax - ymin) * MARGEN_ZOOM
xlim = (xmin - dx, xmax + dx)
ylim = (ymin - dy, ymax + dy)

# Graficar: límites de UV (referencia administrativa) + basemap + jardines
fig, ax = plt.subplots(figsize=(13.33, 7.5))

uv_rm.plot(ax=ax, facecolor="none", edgecolor="lightgray", linewidth=0.3)

junji_geo.plot(ax=ax, color="#1f77b4", markersize=4, alpha=0.65, label="JUNJI")
integra_geo.plot(ax=ax, color="#d62728", markersize=4, alpha=0.65, label="Integra")

ax.set_xlim(xlim)
ax.set_ylim(ylim)

cx.add_basemap(ax, crs=CRS_WEB, source=cx.providers.CartoDB.Positron)

ax.set_title("Jardines infantiles JUNJI e Integra, Región Metropolitana", fontsize=16)
ax.set_axis_off()
ax.legend(loc="upper right", fontsize=12, markerscale=2, frameon=True)

fig.tight_layout()

FIGURES.mkdir(parents=True, exist_ok=True)
fig.savefig(FIGURES / "mapa_jardines_rm.png", dpi=300, bbox_inches="tight")
print("Exportado:", FIGURES / "mapa_jardines_rm.png")
