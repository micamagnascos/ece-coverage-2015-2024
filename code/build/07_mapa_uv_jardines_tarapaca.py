# -*- coding: utf-8 -*-
"""Mapa de las unidades vecinales (UV) de la Región de Tarapacá coloreadas por
número de jardines (JUNJI + Integra) en la UV, con la ubicación de cada jardín
marcada como punto.

Contraparte del mapa de superficie de Coquimbo (code/build/06_mapa_uv_area_coquimbo.py):
en vez de resaltar las UV más grandes, resalta dónde hay jardines. El conteo es
simple —cantidad de jardines en la UV, sin dividir por superficie— y los puntos
muestran que en el interior los pocos jardines de una UV están dispersos entre
pueblos distantes, mientras que en la conurbación costera Iquique - Alto Hospicio
(que reúne ~70% de los jardines de la región) se apiñan en UV diminutas.

Conteo de jardines: variable n_total del panel oficial UV-año
(data/final/base_cobertura_cp.dta, salida de code/build/03_panel_uv_anio.do), año
2024. Puntos: coordenadas de data/build/junji_uv.csv y data/build/integra_uv.csv
(salidas del spatial join, code/build/02_spatial_join_uv.py), filtrando a los
jardines activos en 2024.

Corre localmente: requiere geopandas, matplotlib y contextily (ver
requirements.txt) y se ejecuta desde la raíz del repo.

Input:  data/raw/unidades-vecinales_2024/UnidadesVecinales_2024v4.shp
        data/final/base_cobertura_cp.dta
        data/build/junji_uv.csv, data/build/integra_uv.csv
Output: output/figures/mapa_uv_jardines_tarapaca.png
"""

from pathlib import Path

import contextily as cx
import geopandas as gpd
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib.colors import BoundaryNorm, ListedColormap
from matplotlib.lines import Line2D
from matplotlib.patches import Patch, Rectangle

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data" / "raw"
BUILD = ROOT / "data" / "build"
FINAL = ROOT / "data" / "final"
FIGURES = ROOT / "output" / "figures"

REGION = "TARAPACA"
REGION_PANEL = "tarapaca"
YEAR = 2024
CRS_WEB = "EPSG:3857"

# Vista principal: toda la región
BBOX_REGION_LATLON = {"lat_min": -21.65, "lat_max": -18.92, "lon_min": -70.32, "lon_max": -68.38}
# Inset: conurbación costera Iquique - Alto Hospicio
BBOX_URBANO_LATLON = {"lat_min": -20.35, "lat_max": -20.12, "lon_min": -70.20, "lon_max": -70.02}

# Clases de conteo de jardines (n_total) y su color
BINS = [0, 1, 2, 3, 4, np.inf]
LABELS = ["0", "1", "2", "3", "4 o más"]
COLORS = ["#e6e6e6", "#fed976", "#fd8d3c", "#e31a1c", "#800026"]

COLOR_JUNJI = "#1f4f8f"
COLOR_INTEGRA = "#1a9850"
BASEMAP = cx.providers.Esri.WorldGrayCanvas
ATTRIB = (
    "Basemap: Esri World Gray Canvas  ·  UV: Subsecretaría de Desarrollo Regional 2024  ·  "
    "Jardines: panel UV-año + spatial join JUNJI / Integra"
)


def latlon_bbox_to_web(bbox):
    corners = gpd.GeoSeries(
        gpd.points_from_xy(
            [bbox["lon_min"], bbox["lon_max"]],
            [bbox["lat_min"], bbox["lat_max"]],
        ),
        crs="EPSG:4326",
    ).to_crs(CRS_WEB)
    return (corners.x.min(), corners.x.max()), (corners.y.min(), corners.y.max())


# --- UV con conteo de jardines ------------------------------------------
uv = gpd.read_file(RAW / "unidades-vecinales_2024" / "UnidadesVecinales_2024v4.shp")
uv = uv[uv["t_reg_nom"] == REGION].copy()
uv["t_id_uv_ca"] = uv["t_id_uv_ca"].astype("int64")
uv = uv.to_crs(CRS_WEB)
tp_ids = set(uv["t_id_uv_ca"])

panel = pd.read_stata(FINAL / "base_cobertura_cp.dta")
panel = panel[(panel["t_reg_nom"] == REGION_PANEL) & (panel["anio"] == YEAR)].copy()
panel["t_id_uv_ca"] = panel["t_id_uv_ca"].astype("int64")
uv = uv.merge(panel[["t_id_uv_ca", "n_total"]], on="t_id_uv_ca", how="left")
uv["n_total"] = uv["n_total"].fillna(0).astype(int)

# --- Puntos de jardines (activos en 2024) -------------------------------
junji = pd.read_csv(BUILD / "junji_uv.csv")
junji["t_id_uv_ca"] = pd.to_numeric(junji["t_id_uv_ca"], errors="coerce")
junji = junji[junji["t_id_uv_ca"].isin(tp_ids) & (junji["anio_inicio"] <= YEAR)].copy()

integra = pd.read_csv(BUILD / "integra_uv.csv")
integra["t_id_uv_ca"] = pd.to_numeric(integra["t_id_uv_ca"], errors="coerce")
integra = integra[integra["t_id_uv_ca"].isin(tp_ids) & (integra["anio_termino"] >= YEAR)].copy()

pts_junji = gpd.GeoDataFrame(
    junji, geometry=gpd.points_from_xy(junji["longi"], junji["lat"]), crs="EPSG:4326"
).to_crs(CRS_WEB)
pts_integra = gpd.GeoDataFrame(
    integra, geometry=gpd.points_from_xy(integra["longi"], integra["lat"]), crs="EPSG:4326"
).to_crs(CRS_WEB)

print(f"UVs en la Región de {REGION.title()}: {len(uv)}  ·  con >=1 jardín: {(uv['n_total'] > 0).sum()}")
print(f"Jardines {YEAR}: JUNJI {len(pts_junji)}  +  Integra {len(pts_integra)}  =  {len(pts_junji) + len(pts_integra)}")
print("\nUV por número de jardines:")
print(uv["n_total"].value_counts().sort_index().to_string())

conurb = ["IQUIQUE", "ALTO HOSPICIO"]
jard_conurb = int(uv.loc[uv["t_com_nom"].isin(conurb), "n_total"].sum())
jard_total = int(uv["n_total"].sum())

norm = BoundaryNorm(BINS, len(COLORS))
cmap = ListedColormap(COLORS)

xlim, ylim = latlon_bbox_to_web(BBOX_REGION_LATLON)
xlim_u, ylim_u = latlon_bbox_to_web(BBOX_URBANO_LATLON)


def draw(target, lw, ms):
    uv.plot(ax=target, column="n_total", cmap=cmap, norm=norm,
            edgecolor="#3d3d3d", linewidth=lw, alpha=0.9)
    pts_junji.plot(ax=target, color=COLOR_JUNJI, markersize=ms, edgecolor="white",
                   linewidth=0.7, zorder=8)
    pts_integra.plot(ax=target, color=COLOR_INTEGRA, marker="^", markersize=ms * 1.25,
                     edgecolor="white", linewidth=0.7, zorder=8)


# --- Figura --------------------------------------------------------------
fig = plt.figure(figsize=(12.8, 12.6))
ax = fig.add_axes([0.02, 0.035, 0.63, 0.90])
axins = fig.add_axes([0.66, 0.05, 0.32, 0.42])

draw(ax, 0.6, 30)
ax.set_xlim(xlim)
ax.set_ylim(ylim)
ax.set_axis_off()
cx.add_basemap(ax, crs=CRS_WEB, source=BASEMAP, attribution=False)

ax.add_patch(Rectangle(
    (xlim_u[0], ylim_u[0]), xlim_u[1] - xlim_u[0], ylim_u[1] - ylim_u[0],
    fill=False, edgecolor="#1a1a1a", linewidth=1.4, linestyle="--", zorder=7,
))
ax.annotate("Iquique – Alto Hospicio", xy=((xlim_u[0] + xlim_u[1]) / 2, ylim_u[1]),
            xytext=(0, 12), textcoords="offset points", fontsize=9.5, ha="center",
            va="bottom", color="#1a1a1a")

draw(axins, 0.9, 70)
axins.set_xlim(xlim_u)
axins.set_ylim(ylim_u)
axins.set_xticks([])
axins.set_yticks([])
for spine in axins.spines.values():
    spine.set_edgecolor("#1a1a1a")
    spine.set_linewidth(1.4)
cx.add_basemap(axins, crs=CRS_WEB, source=BASEMAP, attribution=False)
axins.set_title(
    f"Detalle: conurbación Iquique – Alto Hospicio\n"
    f"{jard_conurb} de {jard_total} jardines de la región",
    fontsize=9.5,
)

# Leyenda: clases de conteo + tipo de jardín, en un solo recuadro opaco
handles = (
    [Patch(facecolor=c, edgecolor="white", label=lbl) for c, lbl in zip(COLORS, LABELS)]
    + [
        Line2D([], [], color="none", label=""),
        Line2D([], [], color=COLOR_JUNJI, marker="o", linestyle="", markeredgecolor="white",
               markersize=9, label=f"Jardín JUNJI ({len(pts_junji)})"),
        Line2D([], [], color=COLOR_INTEGRA, marker="^", linestyle="", markeredgecolor="white",
               markersize=9, label=f"Jardín Integra ({len(pts_integra)})"),
    ]
)
ax.legend(handles=handles, title="Jardines en la UV (2024)", loc="upper right",
          fontsize=10, title_fontsize=10.5, frameon=True, framealpha=1).set_zorder(10)

fig.text(0.5, 0.016, ATTRIB, ha="center", va="bottom", fontsize=8, color="gray")

fig.suptitle(
    "Unidades vecinales de la Región de Tarapacá según número de jardines\n"
    f"{jard_conurb} de {jard_total} jardines ({100 * jard_conurb / jard_total:.0f}%) están en la "
    f"conurbación Iquique – Alto Hospicio; el resto se dispersa por el interior",
    fontsize=13.5, y=0.985,
)

FIGURES.mkdir(parents=True, exist_ok=True)
out = FIGURES / "mapa_uv_jardines_tarapaca.png"
fig.savefig(out, dpi=300, bbox_inches="tight")
print("\nExportado:", out)
