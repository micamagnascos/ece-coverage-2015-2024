# -*- coding: utf-8 -*-
"""Asignación espacial jardín -> unidad vecinal (UV).

Portado desde Colab (fuente original:
https://colab.research.google.com/drive/1s-6Kq4yACpyCtWODVw9NlB7uqU93pqIX).
Corre localmente: requiere geopandas (ver requirements.txt) y se ejecuta
desde la raíz del repo (o vía run_all.do, que ya se posiciona ahí).

Input:  data/raw/unidades-vecinales_2024/UnidadesVecinales_2024v4.shp
        data/build/junji_limpia.csv, data/build/integra_limpia.csv
        (salida de code/build/01_limpieza_junji_integra.do)
Output: data/build/junji_uv.csv, data/build/integra_uv.csv,
        data/build/base_uv_completa.csv
"""

from pathlib import Path

import geopandas as gpd
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data" / "raw"
BUILD = ROOT / "data" / "build"

# Cargar shapefile de unidades vecinales
uv = gpd.read_file(RAW / "unidades-vecinales_2024" / "UnidadesVecinales_2024v4.shp")

# Cargar CSVs limpios (salida de 01_limpieza_junji_integra.do)
junji = pd.read_csv(BUILD / "junji_limpia.csv", encoding="latin1")
integra = pd.read_csv(BUILD / "integra_limpia.csv", encoding="latin1")

# Verificar que cargaron bien
print("Unidades vecinales:", uv.shape)
print("JUNJI:", junji.shape)
print("Integra:", integra.shape)
print("\nColumnas JUNJI:", junji.columns.tolist())
print("\nColumnas Integra:", integra.columns.tolist())
print("\nCRS shapefile:", uv.crs)

# Dropear sin coordenadas (incluyendo ceros)
junji_limpia = junji[(junji["lat"] != 0) & (junji["longi"] != 0)].dropna(subset=["lat", "longi"])
integra_limpia = integra.dropna(subset=["lat", "longi"])

print("JUNJI sin coordenadas:", len(junji) - len(junji_limpia))
print("Integra sin coordenadas:", len(integra) - len(integra_limpia))

# Convertir a GeoDataFrame
junji_geo = gpd.GeoDataFrame(
    junji_limpia,
    geometry=gpd.points_from_xy(junji_limpia["longi"], junji_limpia["lat"]),
    crs="EPSG:4326",
).to_crs(uv.crs)

integra_geo = gpd.GeoDataFrame(
    integra_limpia,
    geometry=gpd.points_from_xy(integra_limpia["longi"], integra_limpia["lat"]),
    crs="EPSG:4326",
).to_crs(uv.crs)

# Sjoin
junji_uv = gpd.sjoin(junji_geo, uv[["t_id_uv_ca", "geometry"]], how="left", predicate="within")
integra_uv = gpd.sjoin(integra_geo, uv[["t_id_uv_ca", "geometry"]], how="left", predicate="within")

print("\nJUNJI sin UV asignada:", junji_uv["t_id_uv_ca"].isna().sum())
print("Integra sin UV asignada:", integra_uv["t_id_uv_ca"].isna().sum())

print("=== JUNJI ===")
print(junji_uv.dtypes)
print("\n")
print(junji_uv.head())

print("\n=== INTEGRA ===")
print(integra_uv.dtypes)
print("\n")
print(integra_uv.head())

junji_uv.drop(columns=["geometry", "index_right"]).to_csv(BUILD / "junji_uv.csv", index=False)
integra_uv.drop(columns=["geometry", "index_right"]).to_csv(BUILD / "integra_uv.csv", index=False)

print("Exportadas!")

uv.drop(columns="geometry").to_csv(BUILD / "base_uv_completa.csv", index=False)
print("Exportada!")

print(uv.columns.tolist())
print(uv.shape)

print(junji_uv.columns.tolist())
