# -*- coding: utf-8 -*-
"""Primer año en que cada jardín aparece en los paneles anuales de transparencia.

La FECHA_APERTURA de data/raw/junji.xlsx viene de bases que parten en 2015:
jardines sin fecha anterior en los registros quedan con 01-03-2015 aunque
existían antes. Los paneles anuales (jardín x año) de solicitudes de
transparencia más antiguas permiten corregirlo. Lo usa
code/build/01_limpieza_junji_integra.do. Se ejecuta desde la raíz del repo.

Input:  data/raw/raw_junji/ (SAIP_5446 Jornada Normal 1996-2023,
        SAIP_5325 2009-2023, SAIP_5215 2010-2023)
        data/raw/raw_integra /  (OJO: la carpeta termina en un espacio;
        FU001T0001292 2001-2008, FU001T0001284 2009-2023,
        FU001T0001258 2010-2024; una hoja por año, foto de noviembre)
        data/raw/junji.xlsx (hoja Conversion_Ñuble)
Output: data/build/primer_anio_panel_junji.csv   (codigo_junji, primer_anio_panel)
        data/build/primer_anio_panel_integra.csv (codigo_integra, primer_anio_panel;
        códigos de Ñuble sin convertir, lo hace el 01)
"""

import re
from pathlib import Path

import openpyxl
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data" / "raw"
BUILD = ROOT / "data" / "build"
RAW_JUNJI = RAW / "raw_junji"
RAW_INTEGRA = RAW / "raw_integra "


# ------------------------------------------------------------------
# JUNJI: unir los tres paneles y quedarse con el primer año por código
# ------------------------------------------------------------------
jn = pd.read_excel(RAW_JUNJI / "SAIP_5446_Jornada Normal (1996-).xlsx", sheet_name=0)
s5325 = pd.read_excel(RAW_JUNJI / "SAIP_5325 (2009-).xlsx", sheet_name="base")
s5215 = pd.read_excel(RAW_JUNJI / "SAIP_5215 (2010-).xlsx", sheet_name="SAIP_5215")

panel_junji = pd.concat([
    jn[["CODIGO_ESTABLECIMIENTO", "AÑO"]].set_axis(["cod", "anio"], axis=1),
    s5325[["COD_ESTABLEC", "AÑO"]].set_axis(["cod", "anio"], axis=1),
    s5215[["COD_ESTABLEC", "AÑO"]].set_axis(["cod", "anio"], axis=1),
]).astype("int64")

# Ñuble: llevar todo a código antiguo para que un jardín sea un solo código
nuble = pd.read_excel(RAW / "junji.xlsx", sheet_name="Conversion_Ñuble")
nuevo_a_antiguo = dict(zip(nuble["CODIGO NUEVO"], nuble["CODIGO ANTIGUO"]))
panel_junji["cod"] = panel_junji["cod"].map(lambda c: nuevo_a_antiguo.get(c, c))

primer_junji = panel_junji.groupby("cod")["anio"].min().rename("primer_anio_panel")

# junji_limpia mezcla códigos antiguos y nuevos de Ñuble -> exportar ambos
antiguo_a_nuevo = {v: k for k, v in nuevo_a_antiguo.items()}
out_junji = primer_junji.reset_index().rename(columns={"cod": "codigo_junji"})
extra = out_junji[out_junji["codigo_junji"].isin(antiguo_a_nuevo)].copy()
extra["codigo_junji"] = extra["codigo_junji"].map(antiguo_a_nuevo)
out_junji = pd.concat([out_junji, extra]).sort_values("codigo_junji")

print("JUNJI: jardines por año en los paneles")
print(panel_junji.drop_duplicates().groupby("anio").size().to_string())


# ------------------------------------------------------------------
# Integra: una hoja por año; buscar la fila de encabezado con el código
# ------------------------------------------------------------------
archivos_integra = [
    "FU001T0001292 capacidad matricula 2001-2008 (Andrea Sobarzo).xlsx",
    "FU001T0001284 capacidad matricula 2009-2023 (Andrea Sobarzo)2.xlsx",
    "FU001T0001258_capacidad_matricula_y_extension_horaria_2010_.xlsx",
]

filas = []
for archivo in archivos_integra:
    wb = openpyxl.load_workbook(RAW_INTEGRA / archivo, read_only=True, data_only=True)
    for ws in wb.worksheets:
        anio = re.search(r"(19|20)\d\d", ws.title)
        if anio is None:
            continue
        col = None
        for row in ws.iter_rows(values_only=True):
            if col is None:
                for k, v in enumerate(row):
                    if isinstance(v, str) and "digo" in v and "stablec" in v:
                        col = k
                continue
            try:
                filas.append((int(anio.group()), int(float(row[col]))))
            except (TypeError, ValueError, IndexError):
                pass

panel_integra = pd.DataFrame(filas, columns=["anio", "cod"])

# Ñuble: los códigos quedan como vienen (antiguos hasta 2018, nuevos después);
# el 01 los convierte con cambio_cod_nuble.dta y vuelve a tomar el mínimo
out_integra = (panel_integra.groupby("cod")["anio"].min()
               .rename("primer_anio_panel").reset_index()
               .rename(columns={"cod": "codigo_integra"}))

print("Integra: jardines por año en los paneles")
print(panel_integra.drop_duplicates().groupby("anio").size().to_string())

out_junji.to_csv(BUILD / "primer_anio_panel_junji.csv", index=False)
out_integra.to_csv(BUILD / "primer_anio_panel_integra.csv", index=False)
print("Exportadas: primer_anio_panel_junji.csv, primer_anio_panel_integra.csv")
