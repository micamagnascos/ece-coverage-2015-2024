# -*- coding: utf-8 -*-
"""Mapa de UVs tratadas (0 -> >=1 jardín) en el Gran Santiago (Tiltil - San
Francisco de Mostazal).

"Tratada" es la misma definición del panel oficial (code/build/03_panel_uv_anio.do,
data/final/base_cobertura_cp.dta): UV que pasa de n_total == 0 a n_total >= 1 en
algún año del período 2015-2024 (el primer año, 2015, nunca cuenta como
tratamiento porque no hay año anterior dentro del panel para comparar).

No se filtra ni excluye ninguna UV de la RM: se cargan las 1,370 UVs completas
y se recorta la vista (xlim/ylim) a un bounding box fijo que va, de norte a
sur, desde Tiltil hasta San Francisco de Mostazal.

Corre localmente: requiere geopandas, matplotlib y contextily (ver
requirements.txt) y se ejecuta desde la raíz del repo (o vía run_all.do, que ya
se posiciona ahí).

Input:  data/raw/unidades-vecinales_2024/UnidadesVecinales_2024v4.shp
        data/final/base_cobertura_cp.dta (salida de code/build/03_panel_uv_anio.do)
Output: output/figures/mapa_uv_tratadas_panel.png
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

REGION_RM = "METROPOLITANA DE SANTIAGO"
REGION_RM_PANEL = "metropolitana de santiago"  # t_reg_nom ya estandarizado (minúsculas, sin tildes)
CRS_WEB = "EPSG:3857"  # CRS de los tiles del basemap

# Extent fijo, en EPSG:4326: de Tiltil (norte) a San Francisco de Mostazal (sur)
BBOX_ZOOM_LATLON = {"lat_min": -34.10, "lat_max": -33.03, "lon_min": -71.40, "lon_max": -70.30}

COLOR_TRATADA = "#4a90d9"
COLOR_TRATADA_BORDE = "#1f5fa8"

# Cargar shapefile de unidades vecinales, quedarse con TODAS las UV de la RM
# (sin filtrar) y reproyectar
uv = gpd.read_file(RAW / "unidades-vecinales_2024" / "UnidadesVecinales_2024v4.shp")
uv_rm = uv[uv["t_reg_nom"] == REGION_RM].copy()
uv_rm["t_id_uv_ca"] = uv_rm["t_id_uv_ca"].astype(int)
uv_rm = uv_rm.to_crs(CRS_WEB)

print("Unidades vecinales RM (todas):", uv_rm.shape)

# Cargar panel UV-año y marcar las UVs de la RM que en algún año del período
# pasaron de 0 a >=1 jardines (tratada == 1 en algún año)
panel = pd.read_stata(FINAL / "base_cobertura_cp.dta")
panel_rm = panel[panel["t_reg_nom"] == REGION_RM_PANEL]
uv_tratadas = set(panel_rm.loc[panel_rm["tratada"] == 1, "t_id_uv_ca"].unique())

uv_rm["tratada"] = uv_rm["t_id_uv_ca"].isin(uv_tratadas)

print("UVs tratadas en la RM (2015-2024):", uv_rm["tratada"].sum(), "de", len(uv_rm))

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

# Graficar: todas las UV de la RM + UVs tratadas resaltadas, recortado al extent
fig, ax = plt.subplots(figsize=(9.4, 12.5))

uv_rm.plot(ax=ax, facecolor="none", edgecolor="lightgray", linewidth=0.3)
uv_rm[uv_rm["tratada"]].plot(
    ax=ax, facecolor=COLOR_TRATADA, edgecolor=COLOR_TRATADA_BORDE, alpha=0.45, linewidth=0.6
)
ax.set_axis_off()

ax.set_xlim(xlim)
ax.set_ylim(ylim)

cx.add_basemap(ax, crs=CRS_WEB, source=cx.providers.CartoDB.Positron)

ax.set_title(
    "UVs tratadas (0 → ≥1 jardín), Gran Santiago\n(Tiltil – San Francisco de Mostazal), 2015-2024",
    fontsize=15,
)

legend_handles = [
    Patch(facecolor=COLOR_TRATADA, edgecolor=COLOR_TRATADA_BORDE, alpha=0.45, label="UV tratada"),
    Patch(facecolor="none", edgecolor="lightgray", label="UV no tratada"),
]
ax.legend(handles=legend_handles, loc="upper right", fontsize=12, frameon=True)

fig.tight_layout()

FIGURES.mkdir(parents=True, exist_ok=True)
fig.savefig(FIGURES / "mapa_uv_tratadas_panel.png", dpi=300, bbox_inches="tight")
print("Exportado:", FIGURES / "mapa_uv_tratadas_panel.png")
