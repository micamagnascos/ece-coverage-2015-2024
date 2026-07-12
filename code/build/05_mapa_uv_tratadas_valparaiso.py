# -*- coding: utf-8 -*-
"""Mapa de UVs tratadas (0 -> >=1 jardín) en la Región de Valparaíso.

Mismo diseño que code/build/04_mapa_uv_tratadas_panel.py (RM), aplicado a la
Región de Valparaíso. "Tratada" es la misma definición del panel oficial
(code/build/03_panel_uv_anio.do, data/final/base_cobertura_cp.dta): UV que
pasa de n_total == 0 a n_total >= 1 en algún año del período 2015-2024 (el
primer año, 2015, nunca cuenta como tratamiento porque no hay año anterior
dentro del panel para comparar).

No se filtra ninguna UV de la región: se cargan las 1,060 UVs completas
(incluidas Isla de Pascua y Juan Fernández) y se recorta la vista (xlim/ylim)
al extent continental, para que el mapa sea legible.

Corre localmente: requiere geopandas, matplotlib y contextily (ver
requirements.txt) y se ejecuta desde la raíz del repo (o vía run_all.do, que ya
se posiciona ahí).

Input:  data/raw/unidades-vecinales_2023/mdsf_Unidades_Vecinales_Julio2023.shp
        data/final/base_cobertura_cp.dta (salida de code/build/03_panel_uv_anio.do)
Output: output/figures/mapa_uv_tratadas_valparaiso.png
"""

from pathlib import Path

import contextily as cx
import geopandas as gpd
import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.patches import Patch

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data" / "raw"
FINAL = ROOT / "data" / "final"
FIGURES = ROOT / "output" / "figures"

REGION_VP = "VALPARAISO"
REGION_VP_PANEL = "valparaiso"  # t_reg_nom ya estandarizado (minúsculas, sin tildes)
CRS_WEB = "EPSG:3857"  # CRS de los tiles del basemap

# Extent fijo, en EPSG:4326: Valparaíso continental (excluye Isla de Pascua y
# Juan Fernández, que están a miles de km y harían ilegible el mapa)
BBOX_ZOOM_LATLON = {"lat_min": -34.00, "lat_max": -31.97, "lon_min": -71.90, "lon_max": -69.90}

COLOR_TRATADA = "#4a90d9"
COLOR_TRATADA_BORDE = "#1f5fa8"

# Cargar shapefile de unidades vecinales, quedarse con TODAS las UV de
# Valparaíso (sin filtrar) y reproyectar
uv = gpd.read_file(RAW / "unidades-vecinales_2023" / "mdsf_Unidades_Vecinales_Julio2023.shp")
uv_vp = uv[uv["t_reg_nom"] == REGION_VP].copy()
uv_vp["t_id_uv_ca"] = uv_vp["t_id_uv_ca"].astype(int)
uv_vp = uv_vp.to_crs(CRS_WEB)

print("Unidades vecinales Valparaíso (todas):", uv_vp.shape)

# Cargar panel UV-año y marcar las UVs de Valparaíso que en algún año del
# período pasaron de 0 a >=1 jardines (tratada == 1 en algún año)
panel = pd.read_stata(FINAL / "base_cobertura_cp.dta")
panel_vp = panel[panel["t_reg_nom"] == REGION_VP_PANEL]
uv_tratadas = set(panel_vp.loc[panel_vp["tratada"] == 1, "t_id_uv_ca"].unique())

uv_vp["tratada"] = uv_vp["t_id_uv_ca"].isin(uv_tratadas)

print("UVs tratadas en Valparaíso (2015-2024):", uv_vp["tratada"].sum(), "de", len(uv_vp))

# Extent de la vista: bounding box fijo en lat/lon, reproyectado a EPSG:3857
bbox_corners = gpd.GeoSeries(
    gpd.points_from_xy(
        [BBOX_ZOOM_LATLON["lon_min"], BBOX_ZOOM_LATLON["lon_max"]],
        [BBOX_ZOOM_LATLON["lat_min"], BBOX_ZOOM_LATLON["lat_max"]],
    ),
    crs="EPSG:4326",
).to_crs(CRS_WEB)
xlim = (bbox_corners.x.min(), bbox_corners.x.max())
ylim = (bbox_corners.y.min(), bbox_corners.y.max())

# Graficar: todas las UV de Valparaíso + UVs tratadas resaltadas, recortado al extent
fig, ax = plt.subplots(figsize=(12.5, 9.4))

uv_vp.plot(ax=ax, facecolor="none", edgecolor="lightgray", linewidth=0.3)
uv_vp[uv_vp["tratada"]].plot(
    ax=ax, facecolor=COLOR_TRATADA, edgecolor=COLOR_TRATADA_BORDE, alpha=0.45, linewidth=0.6
)
ax.set_axis_off()

ax.set_xlim(xlim)
ax.set_ylim(ylim)

cx.add_basemap(ax, crs=CRS_WEB, source=cx.providers.CartoDB.Positron)

ax.set_title("UVs tratadas (0 → ≥1 jardín), Región de Valparaíso, 2015-2024", fontsize=15)

legend_handles = [
    Patch(facecolor=COLOR_TRATADA, edgecolor=COLOR_TRATADA_BORDE, alpha=0.45, label="UV tratada"),
    Patch(facecolor="none", edgecolor="lightgray", label="UV no tratada"),
]
ax.legend(handles=legend_handles, loc="upper right", fontsize=12, frameon=True)

fig.tight_layout()

FIGURES.mkdir(parents=True, exist_ok=True)
fig.savefig(FIGURES / "mapa_uv_tratadas_valparaiso.png", dpi=300, bbox_inches="tight")
print("Exportado:", FIGURES / "mapa_uv_tratadas_valparaiso.png")
