# -*- coding: utf-8 -*-
"""Mapa interactivo (HTML) de la expansión de jardines JUNJI e Integra en la RM,
2014-2024, con perilla de año y botón de play. Texto del mapa en inglés.

Capa 1: puntos de jardines. Activo en el año t si anio_apertura <= t <= anio_termino
        (misma regla que 03_panel_uv_anio.do). Stock pre-2015 en tono tenue.
Capa 2: UV coloreadas según grupo_t1/g1 de base_cobertura_cp.dta (las tratadas se
        "encienden" en su año g1).

Corre localmente: requiere geopandas (ver requirements.txt) y se ejecuta desde la
raíz del repo. El HTML necesita internet solo para el mapa de fondo (tiles).

Input:  data/build/junji_uv.csv, data/build/integra_uv.csv
        data/final/base_cobertura_cp.dta
        data/raw/unidades-vecinales_2024/UnidadesVecinales_2024v4.shp
Output: output/figures/mapa_animado_rm.html
"""

import json
from pathlib import Path

import geopandas as gpd
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data" / "raw"
BUILD = ROOT / "data" / "build"
FINAL = ROOT / "data" / "final"
FIGURES = ROOT / "output" / "figures"

REGION_RM = "METROPOLITANA DE SANTIAGO"
SIMPLIFICAR = 0.0002  # tolerancia (grados, ~20 m) para simplificar polígonos de UV

# Jardines de la RM: una fila por jardín con año de apertura y término
junji = pd.read_csv(BUILD / "junji_uv.csv", encoding="latin1")
junji = junji[junji["nom_region"] == "metropolitana"]
junji = junji.assign(tipo="J", anio_termino=2024)

integra = pd.read_csv(BUILD / "integra_uv.csv", encoding="latin1")
integra = integra[integra["region"] == "metropolitana"]
integra = integra.assign(tipo="I")

cols = ["tipo", "nom_estab", "comuna", "lat", "longi", "anio_apertura", "anio_termino"]
jardines = pd.concat([junji[cols], integra[cols]], ignore_index=True)

print("Jardines RM:", jardines["tipo"].value_counts().to_dict())

puntos = [
    [round(r.lat, 5), round(r.longi, 5), r.tipo, int(r.anio_apertura),
     int(r.anio_termino), r.nom_estab.title(), r.comuna.title()]
    for r in jardines.itertuples()
]

# Panel UV x año: grupo y cohorte (g1) por UV, n_total por año
panel = pd.read_stata(FINAL / "base_cobertura_cp.dta")
panel = panel[panel["t_reg_ca"] == 13]
panel["t_id_uv_ca"] = panel["t_id_uv_ca"].astype(int)

uv_info = panel.drop_duplicates("t_id_uv_ca")[["t_id_uv_ca", "grupo_t1", "g1"]]
n_total = panel.pivot(index="t_id_uv_ca", columns="anio", values="n_total").fillna(0)

# Chequeo: n_total del panel vs puntos activos por año (deberían ser casi iguales)
for t in [2014, 2019, 2024]:
    activos = ((jardines["anio_apertura"] <= t) & (jardines["anio_termino"] >= t)).sum()
    print(t, "puntos activos:", activos, "| n_total panel:", int(n_total[float(t)].sum()))

# Polígonos de UV de la RM, simplificados y en lat/lon
uv = gpd.read_file(RAW / "unidades-vecinales_2024" / "UnidadesVecinales_2024v4.shp")
uv = uv[uv["t_reg_nom"] == REGION_RM].to_crs("EPSG:4326")
uv["t_id_uv_ca"] = uv["t_id_uv_ca"].astype(int)
uv["geometry"] = uv.geometry.simplify(SIMPLIFICAR, preserve_topology=True)
uv = uv.merge(uv_info, on="t_id_uv_ca", how="left")

grupo_cod = {"Excluida": "x", "Nunca tratada": "n", "Tratada": "t"}
uv["grupo"] = uv["grupo_t1"].astype(str).map(grupo_cod)
uv["g1"] = uv["g1"].fillna(0).astype(int)
uv["comuna"] = uv["t_com_nom"].astype(str).str.title()
# el shapefile viene sin tildes: corregir las comunas de la RM que las llevan
TILDES = {"Nunoa": "Ñuñoa", "Maipu": "Maipú", "Estacion Central": "Estación Central",
          "Conchali": "Conchalí", "Penalolen": "Peñalolén", "San Joaquin": "San Joaquín",
          "San Ramon": "San Ramón", "Curacavi": "Curacaví", "Alhue": "Alhué",
          "Maria Pinto": "María Pinto", "San Jose De Maipo": "San José de Maipo",
          "Penaflor": "Peñaflor", "Calera De Tango": "Calera de Tango",
          "Isla De Maipo": "Isla de Maipo", "Pedro Aguirre Cerda": "Pedro Aguirre Cerda"}
uv["comuna"] = uv["comuna"].replace(TILDES)
uv["nom"] = uv["t_uv_nom"].astype(str).str.strip()

# Etiquetas de comunas: punto representativo de la comuna (unión de sus UV)
com = uv.dissolve(by="comuna").representative_point()
comunas = [[round(pt.y, 4), round(pt.x, 4), c] for c, pt in com.items()]
uv["n"] = [",".join(str(int(v)) for v in n_total.loc[i]) for i in uv["t_id_uv_ca"]]

print("UV RM por grupo:", uv["grupo"].value_counts().to_dict())

geo = json.loads(
    uv[["grupo", "g1", "comuna", "nom", "n", "geometry"]].to_json(drop_id=True)
)

# Redondear coordenadas a 5 decimales (~1 m) para achicar el archivo
def redondear(c):
    if isinstance(c[0], (int, float)):
        return [round(c[0], 5), round(c[1], 5)]
    return [redondear(x) for x in c]

for f in geo["features"]:
    f["geometry"]["coordinates"] = redondear(f["geometry"]["coordinates"])

# Armar HTML: insertar los datos en la plantilla
plantilla = (ROOT / "code" / "build" / "plantilla_mapa_animado.html").read_text(encoding="utf-8")
html = plantilla.replace("__PUNTOS__", json.dumps(puntos, ensure_ascii=False))
html = html.replace("__COMUNAS__", json.dumps(comunas, ensure_ascii=False))
html = html.replace("__UV__", json.dumps(geo, ensure_ascii=False, separators=(",", ":")))

FIGURES.mkdir(parents=True, exist_ok=True)
salida = FIGURES / "mapa_animado_rm.html"
salida.write_text(html, encoding="utf-8")
print("Exportado:", salida, f"({salida.stat().st_size / 1e6:.1f} MB)")
