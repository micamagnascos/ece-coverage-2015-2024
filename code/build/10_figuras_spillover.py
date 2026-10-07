# -*- coding: utf-8 -*-
"""Figuras para explicar la contaminación del grupo control por jardines
abiertos en UVs vecinas (spillover).

Clasifica las UVs nunca tratadas (grupo_t1 == 2) en:
  A  Sin jardín vecino      vecina_jardin == 0
  B  Vecina con jardín 2014  vecina_jardin == 1 & vecina_abre == 0
  C  Vecina abre jardín      vecina_abre == 1

Input:  data/raw/unidades-vecinales_2024/UnidadesVecinales_2024v4.shp
        data/final/base_cobertura_cp.dta (salida de 09_merge_vecina_jardin.do)
        data/build/junji_uv.csv, data/build/integra_uv.csv
Output: output/figures/spillover_1_ejemplo_uv.png
        output/figures/spillover_2_contaminacion_anual.png
        output/figures/spillover_3_tamano_control.png
        output/figures/spillover_4_mapa_santiago.png
"""

from pathlib import Path

import geopandas as gpd
import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.lines import Line2D
from matplotlib.patches import Patch

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data" / "raw"
BUILD = ROOT / "data" / "build"
FINAL = ROOT / "data" / "final"
FIG = ROOT / "output" / "figures"

# Paleta (validada, 3 slots categóricos + neutros)
C_ABRE = "#eb6834"    # naranja: jardín nuevo 2015-2024 / grupo C
C_2014 = "#2a78d6"    # azul: jardín que ya existía en 2014 / grupo B
C_LIMPIA = "#1baf7a"  # aqua: control limpio / grupo A
C_GRIS = "#d9d8d4"
C_TXT = "#0b0b0b"
C_TXT2 = "#52514e"

plt.rcParams.update({
    "font.size": 11, "axes.edgecolor": C_TXT2, "axes.labelcolor": C_TXT2,
    "xtick.color": C_TXT2, "ytick.color": C_TXT2, "axes.spines.top": False,
    "axes.spines.right": False, "figure.dpi": 150,
})

# --- Datos ---------------------------------------------------------------
uv = gpd.read_file(RAW / "unidades-vecinales_2024" / "UnidadesVecinales_2024v4.shp")
uv = uv[["t_id_uv_ca", "t_reg_nom", "t_com_nom", "geometry"]].to_crs("EPSG:32719")
uv["t_id_uv_ca"] = uv["t_id_uv_ca"].astype(int)
uv["geometry"] = uv.geometry.make_valid()
uv["area_km2"] = uv.area / 1e6

base = pd.read_stata(FINAL / "base_cobertura_cp.dta", convert_categoricals=False)
uv14 = base[base["anio"] == 2014].set_index("t_id_uv_ca")

def clasificar(r):
    if r["grupo_t1"] == 1:
        return "Excluida"
    if r["grupo_t1"] == 3:
        return "Tratada"
    if r["vecina_abre"] == 1:
        return "C"
    if r["vecina_jardin"] == 1:
        return "B"
    return "A"

uv14["clase"] = uv14.apply(clasificar, axis=1)
uv = uv.merge(uv14[["clase", "grupo_t1", "stock_base", "g1"]], left_on="t_id_uv_ca", right_index=True)

# Primer año en que cada UV tiene más jardines que en 2014 (0 = nunca)
b = base[base["n_total"] > base["stock_base"]]
anio_abre = b.groupby("t_id_uv_ca")["anio"].min()

# Pares de vecinas (mismo criterio que 08_vecina_jardin_uv.py)
uv_buf = uv[["t_id_uv_ca", "geometry"]].copy()
uv_buf["geometry"] = uv_buf.buffer(10)
pares = gpd.sjoin(uv_buf, uv[["t_id_uv_ca", "geometry"]], predicate="intersects")
pares = pares[pares["t_id_uv_ca_left"] != pares["t_id_uv_ca_right"]]
pares = pares[["t_id_uv_ca_left", "t_id_uv_ca_right"]]
pares.columns = ["uv", "vecina"]
pares["anio_abre_vec"] = pares["vecina"].map(anio_abre)

# Jardines (puntos)
junji = pd.read_csv(BUILD / "junji_uv.csv", encoding="latin1")
integra = pd.read_csv(BUILD / "integra_uv.csv", encoding="latin1")
jard = pd.concat([
    junji[["lat", "longi", "anio_apertura", "t_id_uv_ca"]],
    integra[["lat", "longi", "anio_apertura", "t_id_uv_ca"]],
]).dropna()
jard = gpd.GeoDataFrame(
    jard, geometry=gpd.points_from_xy(jard["longi"], jard["lat"]), crs="EPSG:4326"
).to_crs(uv.crs)
jard["nuevo"] = jard["anio_apertura"] >= 2015

# --- Figura 1: ejemplo de UV nunca tratada rodeada de jardines nuevos ----
nt_rm = uv[(uv["grupo_t1"] == 2) & (uv["t_reg_nom"] == "METROPOLITANA DE SANTIAGO")]
n_abren = pares[pares["anio_abre_vec"].notna()].groupby("uv")["vecina"].nunique()
cand = nt_rm.assign(n_abren=nt_rm["t_id_uv_ca"].map(n_abren).fillna(0))
cand = cand[cand["area_km2"] < 2].sort_values(["n_abren", "area_km2"], ascending=[False, True])
foco = cand.iloc[0]
print(f"UV ejemplo: {foco['t_id_uv_ca']} ({foco['t_com_nom']}), "
      f"{int(foco['n_abren'])} vecinas abren jardín")

vec_ids = pares.loc[pares["uv"] == foco["t_id_uv_ca"], "vecina"].unique()
vec = uv[uv["t_id_uv_ca"].isin(vec_ids)].copy()
vec["color"] = C_GRIS
vec.loc[vec["stock_base"] > 0, "color"] = C_2014
vec.loc[vec["t_id_uv_ca"].isin(anio_abre.index), "color"] = C_ABRE
foco_gdf = uv[uv["t_id_uv_ca"] == foco["t_id_uv_ca"]]

fig, ax = plt.subplots(figsize=(8, 8))
vec.plot(ax=ax, color=vec["color"], alpha=0.35, edgecolor="white", linewidth=1.5)
foco_gdf.plot(ax=ax, color="white", edgecolor=C_TXT, linewidth=2.5, hatch="//")
xmin, ymin, xmax, ymax = vec.total_bounds
pad = 150
ax.set_xlim(xmin - pad, xmax + pad)
ax.set_ylim(ymin - pad, ymax + pad)

j = jard[jard["t_id_uv_ca"].isin(vec_ids)]
ax.scatter(j.loc[~j["nuevo"]].geometry.x, j.loc[~j["nuevo"]].geometry.y,
           s=60, color=C_2014, edgecolor="white", linewidth=1.5, zorder=3)
jn = j[j["nuevo"]]
ax.scatter(jn.geometry.x, jn.geometry.y, s=90, marker="^", color=C_ABRE,
           edgecolor="white", linewidth=1.5, zorder=4)
for _, r in jn.iterrows():
    ax.annotate(str(int(r["anio_apertura"])), (r.geometry.x, r.geometry.y),
                xytext=(6, 6), textcoords="offset points", fontsize=9,
                color=C_TXT, weight="bold")

c = foco_gdf.geometry.iloc[0].representative_point()
ax.annotate("UV control\n(nunca tratada)", (c.x, c.y), ha="center", va="center",
            fontsize=10, weight="bold", color=C_TXT,
            bbox=dict(boxstyle="round", fc="white", ec=C_TXT, lw=0.8))

ax.legend(handles=[
    Patch(facecolor="white", edgecolor=C_TXT, hatch="//", label="UV control: 0 jardines 2014-2024"),
    Patch(facecolor=C_ABRE, alpha=0.35, label="Vecina que abrió jardín 2015-2024"),
    Patch(facecolor=C_2014, alpha=0.35, label="Vecina con jardín desde 2014"),
    Patch(facecolor=C_GRIS, alpha=0.35, label="Vecina sin jardín"),
    Line2D([], [], marker="^", ls="", color=C_ABRE, ms=9, label="Jardín nuevo (año apertura)"),
    Line2D([], [], marker="o", ls="", color=C_2014, ms=8, label="Jardín existente en 2014"),
], loc="upper left", bbox_to_anchor=(1.01, 1), frameon=False, fontsize=9)
ax.set_title(f"Una UV 'nunca tratada' en {foco['t_com_nom'].title()}\n"
             f"{int(foco['n_abren'])} de sus {len(vec_ids)} UVs vecinas abren jardín en el período",
             loc="left", color=C_TXT)
ax.set_axis_off()
fig.savefig(FIG / "spillover_1_ejemplo_uv.png", bbox_inches="tight")
plt.close(fig)

# --- Figura 2: % de nunca tratadas con vecina que ya abrió, por año ------
nt_ids = uv14.index[uv14["grupo_t1"] == 2]
p_nt = pares[pares["uv"].isin(nt_ids)]
primer = p_nt.groupby("uv")["anio_abre_vec"].min().reindex(nt_ids)
anios = range(2015, 2025)
pct = [100 * (primer <= a).mean() for a in anios]

fig, ax = plt.subplots(figsize=(8, 4.5))
ax.plot(list(anios), pct, color=C_ABRE, lw=2, marker="o", ms=8,
        markeredgecolor="white", markeredgewidth=2)
for a, v in zip(anios, pct):
    if a in (2015, 2024):
        ax.annotate(f"{v:.0f}%", (a, v), xytext=(0, 10), textcoords="offset points",
                    ha="center", color=C_TXT, weight="bold")
ax.set_ylim(0, 100)
ax.set_xticks(list(anios))
ax.yaxis.grid(True, color="#ecebe8")
ax.set_ylabel("% de UVs nunca tratadas")
ax.set_title("UVs control que ya tienen un jardín nuevo en una UV vecina\n"
             "(acumulado, N = " + f"{len(nt_ids):,}".replace(",", ".") + " UVs nunca tratadas)",
             loc="left", color=C_TXT)
fig.savefig(FIG / "spillover_2_contaminacion_anual.png", bbox_inches="tight")
plt.close(fig)

# --- Figura 3: tamaño del control según definición + área mediana -------
n = uv14["clase"].value_counts()
area_med = uv.groupby("clase")["area_km2"].median()
filas = [
    ("Todas las nunca tratadas\n(actual)", n["A"] + n["B"] + n["C"], C_TXT2),
    ("Sin vecina que abrió\n(vecina_abre == 0)", n["A"] + n["B"], C_2014),
    ("Sin ningún jardín vecino\n(vecina_jardin == 0)", n["A"], C_LIMPIA),
]

fig, axs = plt.subplots(1, 2, figsize=(11, 4), gridspec_kw={"width_ratios": [3, 2]})
ax = axs[0]
for i, (lab, v, col) in enumerate(filas):
    ax.barh(i, v, color=col, height=0.6)
    ax.text(v + 60, i, f"{v:,}".replace(",", "."), va="center", color=C_TXT, weight="bold")
ax.set_yticks(range(3), [f[0] for f in filas])
ax.invert_yaxis()
ax.set_xlim(0, n[["A", "B", "C"]].sum() * 1.15)
ax.set_xlabel("N° de UVs en el grupo control")
ax.set_title(f"Tamaño del control (vs. {n['Tratada']} tratadas)", loc="left", color=C_TXT)

ax = axs[1]
grupos = [("Tratadas", "Tratada", C_TXT2), ("Control A\nsin jardín vecino", "A", C_LIMPIA),
          ("Control B\nvecina 2014", "B", C_2014), ("Control C\nvecina abre", "C", C_ABRE)]
for i, (lab, k, col) in enumerate(grupos):
    ax.barh(i, area_med[k], color=col, height=0.6)
    ax.text(area_med[k] * 1.03, i, f"{area_med[k]:.1f}", va="center", color=C_TXT, weight="bold")
ax.set_yticks(range(4), [g[0] for g in grupos])
ax.invert_yaxis()
ax.set_xlabel("Área mediana de la UV (km²)")
ax.set_title("¿Son comparables?", loc="left", color=C_TXT)
fig.tight_layout()
fig.savefig(FIG / "spillover_3_tamano_control.png", bbox_inches="tight")
plt.close(fig)

# --- Figura 4: mapa Gran Santiago con la clasificación del control ------
rm = uv[uv["t_reg_nom"] == "METROPOLITANA DE SANTIAGO"].to_crs("EPSG:4326")
col = {"A": C_LIMPIA, "B": C_2014, "C": C_ABRE, "Tratada": "#8f8e89", "Excluida": "#f1f0ec"}
fig, ax = plt.subplots(figsize=(9, 9))
rm.plot(ax=ax, color=rm["clase"].map(col), edgecolor="white", linewidth=0.3)
ax.set_xlim(-70.85, -70.45)
ax.set_ylim(-33.65, -33.30)
ax.legend(handles=[
    Patch(facecolor=C_LIMPIA, label="Control A: sin jardín vecino"),
    Patch(facecolor=C_2014, label="Control B: vecina con jardín desde 2014"),
    Patch(facecolor=C_ABRE, label="Control C: vecina abre jardín 2015-2024"),
    Patch(facecolor="#8f8e89", label="Tratada"),
    Patch(facecolor="#f1f0ec", edgecolor="#c3c2b7", label="Excluida (jardín en 2014)"),
], loc="upper left", bbox_to_anchor=(1.01, 1), frameon=False, fontsize=9)
ax.set_title("Gran Santiago: UVs nunca tratadas según exposición a jardines vecinos",
             loc="left", color=C_TXT)
ax.set_axis_off()
fig.savefig(FIG / "spillover_4_mapa_santiago.png", bbox_inches="tight")
plt.close(fig)

print("\nN por clase (2014):")
print(n)
print("\nÁrea mediana (km²):")
print(area_med.round(2))
print("\n% nunca tratadas con vecina que ya abrió:", dict(zip(anios, [round(p) for p in pct])))
