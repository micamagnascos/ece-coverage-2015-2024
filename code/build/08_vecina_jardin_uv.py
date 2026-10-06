# -*- coding: utf-8 -*-
"""Marca UVs con alguna UV vecina (pegada) con jardín o que abrió jardines.

Vecina = comparte borde o vértice (contigüidad queen), con límites 2024.
Se usa un buffer de 10 m porque el shapefile tiene pequeñas separaciones
entre polígonos que en la realidad se tocan.

vecina_jardin: alguna vecina tuvo n_total >= 1 en algún año 2014-2024
               (incluye jardines que ya existían en 2014).
vecina_abre:   alguna vecina aumentó su n° de jardines respecto a 2014
               (abrió al menos uno en 2015-2024).

Input:  data/raw/unidades-vecinales_2024/UnidadesVecinales_2024v4.shp
        data/final/base_cobertura_cp.dta (salida de 04_tratamiento_t1.do)
Output: data/build/vecina_jardin_uv.dta (una fila por UV)
        -> se pega a la base con 09_merge_vecina_jardin.do
"""

from pathlib import Path

import geopandas as gpd
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data" / "raw"
BUILD = ROOT / "data" / "build"
FINAL = ROOT / "data" / "final"

BUFFER_M = 10

# Shapefile en metros (UTM 19S) para que el buffer sea en metros
uv = gpd.read_file(RAW / "unidades-vecinales_2024" / "UnidadesVecinales_2024v4.shp")
uv = uv[["t_id_uv_ca", "geometry"]].to_crs("EPSG:32719")
uv["t_id_uv_ca"] = uv["t_id_uv_ca"].astype(int)
uv["geometry"] = uv.geometry.make_valid()

# UV tuvo jardín en algún año / abrió jardines respecto a 2014
base = pd.read_stata(FINAL / "base_cobertura_cp.dta", convert_categoricals=False)
g = base.groupby("t_id_uv_ca")
jardin = (g["n_total"].max() >= 1).astype(int)
abre = (g["n_total"].max() > g["stock_base"].first()).astype(int)

# Pares UV - vecina (paso intermedio, no se guarda)
uv_buf = uv.copy()
uv_buf["geometry"] = uv_buf.geometry.buffer(BUFFER_M)
pares = gpd.sjoin(uv_buf, uv, how="inner", predicate="intersects")
pares = pares[pares["t_id_uv_ca_left"] != pares["t_id_uv_ca_right"]]
pares = pares[["t_id_uv_ca_left", "t_id_uv_ca_right"]]
pares.columns = ["t_id_uv_ca", "vecina"]
pares["jardin_vec"] = pares["vecina"].map(jardin).fillna(0)
pares["abre_vec"] = pares["vecina"].map(abre).fillna(0)

# Colapsar a una fila por UV
out = pares.groupby("t_id_uv_ca").agg(
    n_vecinas=("vecina", "nunique"),
    vecina_jardin=("jardin_vec", "max"),
    vecina_abre=("abre_vec", "max"),
)
out = out.reindex(uv["t_id_uv_ca"].unique(), fill_value=0).reset_index()
out = out.rename(columns={"index": "t_id_uv_ca"}).astype("int32")

# Chequeos
print("UVs:", len(out))
print("UVs sin vecinas (islas):", (out["n_vecinas"] == 0).sum())
print(out["n_vecinas"].describe())

chk = base[base["anio"] == 2014][["t_id_uv_ca", "grupo_t1"]].merge(out, on="t_id_uv_ca", how="left")
print("\nUVs de la base sin match en shapefile:", chk["vecina_jardin"].isna().sum())
print("\nvecina_jardin por grupo_t1 (1 excluida, 2 nunca tratada, 3 tratada):")
print(pd.crosstab(chk["grupo_t1"], chk["vecina_jardin"], margins=True))
print("\nvecina_abre por grupo_t1:")
print(pd.crosstab(chk["grupo_t1"], chk["vecina_abre"], margins=True))

out.to_stata(
    BUILD / "vecina_jardin_uv.dta",
    write_index=False,
    variable_labels={
        "n_vecinas": "N de UVs pegadas (queen, buffer 10m, limites 2024)",
        "vecina_jardin": "1 si alguna UV pegada tuvo jardin en 2014-2024",
        "vecina_abre": "1 si alguna UV pegada abrio jardines en 2015-2024",
    },
)
print("\nExportada: data/build/vecina_jardin_uv.dta")
