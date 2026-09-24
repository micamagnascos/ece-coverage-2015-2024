# -*- coding: utf-8 -*-
"""Mapa de las unidades vecinales (UV) de la Región de Coquimbo, coloreadas por
superficie.

Objetivo: evidenciar que en zonas rurales / poco pobladas del norte las UV son
mucho más grandes que en las zonas urbanas. En Coquimbo la mediana de superficie
de una UV va desde ~0,4 km2 en las comunas urbanas (Coquimbo, Andacollo) hasta
>140 km2 en las comunas rurales del interior y del secano costero (La Higuera,
Los Vilos, Punitaqui, Combarbalá), y la UV más grande supera los 3.000 km2
(Monte Patria). El mismo shapefile 2024 usado en el resto del pipeline.

Corre localmente: requiere geopandas, matplotlib y contextily (ver
requirements.txt) y se ejecuta desde la raíz del repo (o vía run_all.do, que ya
se posiciona ahí).

Input:  data/raw/unidades-vecinales_2024/UnidadesVecinales_2024v4.shp
Output: output/figures/mapa_uv_area_coquimbo.png
"""

from pathlib import Path

import contextily as cx
import geopandas as gpd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import LogNorm
from matplotlib.patches import Rectangle

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data" / "raw"
FIGURES = ROOT / "output" / "figures"

REGION = "COQUIMBO"
CRS_WEB = "EPSG:3857"      # CRS de los tiles del basemap
CRS_AREA = "EPSG:32719"    # UTM 19S: cálculo de superficie en metros para Coquimbo

# Vista principal: Coquimbo continental
BBOX_REGION_LATLON = {"lat_min": -32.30, "lat_max": -29.00, "lon_min": -71.85, "lon_max": -69.85}
# Inset: conurbación La Serena - Coquimbo (zona urbana, UV pequeñas)
BBOX_URBANO_LATLON = {"lat_min": -30.10, "lat_max": -29.86, "lon_min": -71.37, "lon_max": -71.19}

CMAP = "inferno_r"
BASEMAP = cx.providers.Esri.WorldGrayCanvas
ATTRIB = "Basemap: Esri World Gray Canvas  ·  UV: Subsecretaría de Desarrollo Regional 2024"


def latlon_bbox_to_web(bbox):
    corners = gpd.GeoSeries(
        gpd.points_from_xy(
            [bbox["lon_min"], bbox["lon_max"]],
            [bbox["lat_min"], bbox["lat_max"]],
        ),
        crs="EPSG:4326",
    ).to_crs(CRS_WEB)
    return (corners.x.min(), corners.x.max()), (corners.y.min(), corners.y.max())


# --- Datos -----------------------------------------------------------------
uv = gpd.read_file(RAW / "unidades-vecinales_2024" / "UnidadesVecinales_2024v4.shp")
uv = uv[uv["t_reg_nom"] == REGION].copy()

# Superficie en km2 (proyección métrica), luego se pasa todo a Web Mercator
uv["area_km2"] = uv.to_crs(CRS_AREA).geometry.area / 1e6
uv = uv.to_crs(CRS_WEB)

print(f"UVs en la Región de {REGION.title()}: {len(uv)}")
print(uv["area_km2"].describe().round(2).to_string())

resumen = (
    uv.groupby("t_com_nom")["area_km2"]
    .median()
    .sort_values()
)
print("\nMediana de superficie por comuna (km2):")
print(resumen.round(1).to_string())

vmin = max(uv["area_km2"].min(), 0.05)
vmax = uv["area_km2"].max()
norm = LogNorm(vmin=vmin, vmax=vmax)

xlim, ylim = latlon_bbox_to_web(BBOX_REGION_LATLON)
xlim_u, ylim_u = latlon_bbox_to_web(BBOX_URBANO_LATLON)

# --- Figura --------------------------------------------------------------
# Mapa principal a la izquierda; colorbar e inset en la franja derecha.
fig = plt.figure(figsize=(12.5, 13.4))
ax = fig.add_axes([0.02, 0.035, 0.64, 0.90])
cax = fig.add_axes([0.70, 0.52, 0.022, 0.40])
axins = fig.add_axes([0.685, 0.055, 0.30, 0.34])

uv.plot(
    ax=ax,
    column="area_km2",
    cmap=CMAP,
    norm=norm,
    edgecolor="white",
    linewidth=0.25,
    alpha=0.85,
)
ax.set_xlim(xlim)
ax.set_ylim(ylim)
ax.set_axis_off()

cx.add_basemap(ax, crs=CRS_WEB, source=BASEMAP, attribution=False)

# Recuadro que marca el área del inset urbano
ax.add_patch(
    Rectangle(
        (xlim_u[0], ylim_u[0]),
        xlim_u[1] - xlim_u[0],
        ylim_u[1] - ylim_u[0],
        fill=False,
        edgecolor="#1a1a1a",
        linewidth=1.4,
        linestyle="--",
        zorder=5,
    )
)
ax.annotate(
    "La Serena – Coquimbo",
    xy=((xlim_u[0] + xlim_u[1]) / 2, ylim_u[0]),
    xytext=(0, -18),
    textcoords="offset points",
    fontsize=9.5,
    ha="center",
    va="top",
    color="#1a1a1a",
)

# Inset: conurbación urbana La Serena - Coquimbo (UV pequeñas)
uv.plot(
    ax=axins,
    column="area_km2",
    cmap=CMAP,
    norm=norm,
    edgecolor="white",
    linewidth=0.35,
    alpha=0.95,
)
axins.set_xlim(xlim_u)
axins.set_ylim(ylim_u)
axins.set_xticks([])
axins.set_yticks([])
for spine in axins.spines.values():
    spine.set_edgecolor("#1a1a1a")
    spine.set_linewidth(1.4)
cx.add_basemap(axins, crs=CRS_WEB, source=BASEMAP, attribution=False)
axins.set_title(
    "Detalle: conurbación La Serena – Coquimbo\n(UV urbanas de < 1 km²)", fontsize=9.5
)

# Colorbar en escala logarítmica con etiquetas en km2
sm = plt.cm.ScalarMappable(cmap=CMAP, norm=norm)
sm.set_array([])
cbar = fig.colorbar(sm, cax=cax)
ticks = [0.1, 1, 10, 100, 1000]
cbar.set_ticks(ticks)
cbar.set_ticklabels([f"{t:g}" for t in ticks])
cbar.set_label("Superficie de la UV (km², escala log)", fontsize=11)

fig.text(0.5, 0.018, ATTRIB, ha="center", va="bottom", fontsize=8, color="gray")

med_urb = resumen.iloc[0]
med_rur = resumen.iloc[-1]
fig.suptitle(
    "Unidades vecinales de la Región de Coquimbo, por superficie\n"
    f"Mediana comunal: {med_urb:.1f} km² ({resumen.index[0].title()}, urbana) "
    f"vs. {med_rur:.0f} km² ({resumen.index[-1].title()}, rural)  ·  "
    f"UV más grande: {vmax:,.0f} km²",
    fontsize=14, y=0.98,
)

FIGURES.mkdir(parents=True, exist_ok=True)
out = FIGURES / "mapa_uv_area_coquimbo.png"
fig.savefig(out, dpi=300, bbox_inches="tight")
print("\nExportado:", out)
