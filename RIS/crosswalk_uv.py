# -*- coding: utf-8 -*-
"""
Created on Mon Aug 10 10:01:40 2026

@author: ris_mmagnasco_190
"""
# %%
import pandas as pd 
import os 
print(os.getcwd())
os.listdir(".")

pd.set_option("display.max_columns", None)


# %%
import geopandas 
print(geopandas.__version__)
# %%
CARPETA_SHAPES= "//10.60.214.178/Repositorio_Datos_ADM/repositorio_ris/RIS_INVESTIGACION_11/190_impacto_jardines/03_EDITABLES/01_DATOS_SALIDA/FERTILIDAD_ML/shapes_uv"
CRS_METRICO = "EPSG:5361"
UMBRAL_DIVISION=0.8

ARCHIVO_REFERENCIA="//10.60.214.178/Repositorio_Datos_ADM/repositorio_ris/RIS_INVESTIGACION_11/190_impacto_jardines/03_EDITABLES/01_DATOS_SALIDA/FERTILIDAD_ML/shapes_uv/UV_2024/UnidadesVecinales_2024v4.shp"
COLUMNA_ID_REFERENCIA = "t_id_uv_ca"
COLUMNA_COMUNA_REFERENCIA="t_com_nom"
COLUMNA_COMUNA_REF_ID= "t_com"
COLUMNA_NOMBRE_UV_REF = "t_uv_nom"

filas = []

os.chdir(os.path.join(CARPETA_SHAPES))
print(os.getcwd())


# %% 
#CALIDAD CAPA

def calidad_capa (capa, anio, columna_id):
    resultado = {}
    resultado["anio"] = anio 
    resultado["n_shapes"] = len(capa)
    resultado["pct_invalidas"] = round(100* (1 - capa.geometry.is_valid.mean()),2)
    resultado["pct_vacias"] = round(100* capa.geometry.is_empty.mean(),2)
    resultado["pct_nulas"] = round(100* capa.geometry.isna().mean(),2)
    resultado["ids_duplicado"] = int(capa[columna_id].duplicated().sum())
    capa_m = capa.to_crs(CRS_METRICO)
    areas = capa_m.geometry.area
    resultado["shapes_menor_100m2"]= int((areas < 100).sum())
    resultado["area_max_m2"] = round(areas.max(), 1)
    geom_valida=capa_m.geometry.make_valid()
    suma_individual = geom_valida.area.sum()
    area_union = geom_valida.unary_union.area
    resultado["pct_area_solapada"] = round(100 * (suma_individual - area_union)/ suma_individual, 2)
    return resultado



# %%
#FUNCIÒN PARA REVISAR CAPAS 
def revisar_capa(ruta_archivo):
    capa = geopandas.read_file(ruta_archivo)
    print("Archivo:", ruta_archivo)
    print("Filas(cantidad de UVs):", len(capa))
    print("CRS original:", capa.crs)
    print("Columnas:", list(capa.columns))
    print("Geometrìas validas:", capa.is_valid.sum(), "de", len(capa))
    print("Primeras filas:")
    print(capa.head(3))
    return capa 



# %% 
#CONSTRUIR CROSSWALK DE CADA AÑO CONTRA REFERENCIA (2024)
def crear_crosswalk(uv_origen, uv_referencia, columna_id_origen, columna_id_referencia, columna_comuna_origen, columna_comuna_referencia, columna_comuna_origen_id, columna_comuna_ref_id, columna_nombre_origen, columna_nombre_referencia, anio):
    
    print(f"año {anio}")
    print("columna_comuna_origen_id recibido:", columna_comuna_origen_id)
    print("existe en uv origen?", columna_comuna_origen_id in uv_origen.columns)
    print("columnas de uv origen:", uv_origen.columns.tolist())
    
    
    uv_origen=uv_origen.copy()
    uv_origen= uv_origen.to_crs(CRS_METRICO)
    uv_origen["geometry"]=uv_origen["geometry"].make_valid()
    uv_origen = uv_origen.rename(columns={columna_id_origen: "id_uv_origen", columna_comuna_origen_id: "id_comuna_origen", columna_nombre_origen: "nombre_uv_origen"})
    uv_origen = uv_origen.reset_index(drop=True)
    uv_origen["fila_origen"]= uv_origen.index 
    
    if columna_comuna_origen: 
        uv_origen=uv_origen.rename(columns={columna_comuna_origen:"comuna_origen"})
    else:
        uv_origen["comuna_origen"] = None 
        
    
    uv_referencia= uv_referencia.copy()
    uv_referencia= uv_referencia.rename(columns={columna_id_referencia:"id_uv_2024", columna_comuna_ref_id:"id_comuna_2024", columna_nombre_referencia:"nombre_uv_2024"})
    
    if columna_comuna_referencia:
        uv_referencia=uv_referencia.rename(columns={columna_comuna_referencia:"comuna_2024"})
    else:
        uv_referencia["comuna_2024"] = None 
    
    interseccion = geopandas.overlay(uv_origen, uv_referencia, how="intersection")
    print("COLUMNAS interseccion:", list(interseccion.columns))
    interseccion["area_solape"]=interseccion.geometry.area

    
    #mejor destino por fila 
    mejor_por_fila=interseccion.loc[interseccion.groupby("fila_origen")["area_solape"].idxmax()].copy()
    uv_origen["area_total"]= uv_origen.geometry.area
    mejor_por_fila = mejor_por_fila.merge(uv_origen[["fila_origen","area_total"]], on="fila_origen")
    mejor_por_fila["pct_area"]= mejor_por_fila["area_solape"]/mejor_por_fila["area_total"]
    
    total_origen=len(uv_origen)
    total_con_match= mejor_por_fila["fila_origen"].nunique()
    if total_con_match < total_origen:
        print("ATENCION año",anio,".",
        total_origen-total_con_match,
        "UVs de origen quedaron sin ningun match en 2024. Revisar aparte",)
        
    print(mejor_por_fila.loc[mejor_por_fila["id_uv_origen"].isin([0,"0"]), "comuna_2024"].isna().mean())
        
    #separar codigos 0 
    es_sin_codigo = (mejor_por_fila["id_uv_origen"].isin([0,"0"]) | mejor_por_fila["id_uv_origen"].isna())
    sin_codigo= mejor_por_fila.loc[es_sin_codigo].copy()
    con_codigo= mejor_por_fila.loc[es_sin_codigo==False].copy()
    
    #colapsar a nivel id_uv_origen
    
    agregado= (con_codigo.groupby(["id_uv_origen", "id_uv_2024"], as_index =False).agg(area_solape=("area_solape", "sum"), area_total=("area_total", "sum"), comuna_origen=("comuna_origen","first"), comuna_2024=("comuna_2024", "first"), id_comuna_origen=("id_comuna_origen", "first"), id_comuna_2024=("id_comuna_2024", "first"), nombre_uv_origen=("nombre_uv_origen", "first"), nombre_uv_2024=("nombre_uv_2024", "first"),))
    
    n_destinos = agregado.groupby("id_uv_origen")["id_uv_2024"].nunique()
    ids_ambiguos=set(n_destinos[n_destinos>1].index)
    if ids_ambiguos:
        print(f"AVISO año {anio}: {len(ids_ambiguos)} id_uv_origen quedaron asignados a mas de una id_uv_2024 ")
        
        
    con_codigo_final = agregado.loc[agregado.groupby("id_uv_origen")["area_solape"].idxmax()].copy()
    con_codigo_final["pct_area"]=con_codigo_final["area_solape"]/con_codigo_final["area_total"]
    con_codigo_final["flag_multidestino"]= con_codigo_final["id_uv_origen"].isin(ids_ambiguos)
    con_codigo_final["sin_codigo_origen"] = False
    
    if len(sin_codigo)>0:
        print(f"AVISO año {anio}: {len(sin_codigo)} filas con id_uv_origen =0 No se pueden mergear con codigo, usar fila_origen para esas")
        sin_codigo["flag_multidestino"]= False
        sin_codigo["sin_codigo_origen"]= True
        
    crosswalk = con_codigo_final.copy()
    crosswalk["flag_division"]=crosswalk["pct_area"]< UMBRAL_DIVISION
    crosswalk["anio"]=anio
    
    columnas_finales= ["anio", "fila_origen", "id_uv_origen", "id_uv_2024", "nombre_uv_origen", "nombre_uv_2024", "comuna_origen", "comuna_2024", "id_comuna_origen", "id_comuna_2024", "pct_area", "flag_division", "flag_multidestino", "sin_codigo_origen"]
    if "fila_origen" not in crosswalk.columns:
        crosswalk["fila_origen"]=pd.NA
    crosswalk = crosswalk[columnas_finales]
    
    antes = len(crosswalk)
    crosswalk = crosswalk.drop_duplicates()
    if len(crosswalk) < antes:
        print(f"AVISO {anio}: se eliminaron {antes - len(crosswalk)} filas duplicadas exactas")
        
    return crosswalk
        
    

# %% CARGAMOS CADA CAPA Y VEMOS SU CALIDAD 
# tiene t_uv_id, se ve que es unico por uv, habrìa que tratar de unificarlo con el resto
capa_2014=revisar_capa("UV_2014/UV_H19.shp")
filas.append(calidad_capa(capa_2014, 2014, "T_UV_ID"))


#no tiene correlativo, concatenated
capa_2015=revisar_capa("UV_2015/UV_GEO.shp")
filas.append(calidad_capa(capa_2015, 2015, "concatenad"))


#no tiene correlativo, tiene id_uv y CARTO, no son iguales
capa_2017=revisar_capa("UV_2017/unidades_vecinales_2017.shp")
filas.append(calidad_capa(capa_2017, 2017, "ID_UV"))


#no tiene correlativo, concatenated
capa_2018=revisar_capa("UV_2018/2018/UV_UTM.shp")
filas.append(calidad_capa(capa_2018, 2018, "concatenad"))


#no tiene correlativo, tiene uv_carto que contiene R y U al final
capa_2019=revisar_capa("UV_2019/2019/UV_mds_2019_ADIS_utm.shp")
filas.append(calidad_capa(capa_2019, 2019, "uv_carto")) 


############### el problema es de 2019 hacia atràs 

#tiene t_id_uv_ca
capa_2020=revisar_capa("UV_2020/2020/UVS_UTM_2020.shp")
filas.append(calidad_capa(capa_2020, 2020, "T_ID_UV_CA")) 


#tiene id_uv que al parecer es simil a t_id_uv_ca
capa_2021=revisar_capa("UV_2021/unidades_vecinales_2021.shp")
filas.append(calidad_capa(capa_2021, 2021, "ID_UV"))


#tiene id_uv que al parecer es simil a t_id_uv_ca
capa_2022=revisar_capa("UV_2022/unidades_vecinales_2022.shp")
filas.append(calidad_capa(capa_2022, 2022, "ID_UV"))


capa_2023=revisar_capa("UV_2023/mdsf_Unidades_Vecinales_Julio2023.shp")
filas.append(calidad_capa(capa_2023, 2023, "t_id_uv_ca")) 


capa_2024=revisar_capa("UV_2024/UnidadesVecinales_2024v4.shp")
filas.append(calidad_capa(capa_2024, 2024, "t_id_uv_ca"))



    # %% 

capa_2024= capa_2024.to_crs(CRS_METRICO)
capa_2024["geometry"]=capa_2024["geometry"].make_valid() 

    # %% 
crosswalk_2014=crear_crosswalk(capa_2014, capa_2024, "T_UV_ID","t_id_uv_ca",None ,COLUMNA_COMUNA_REFERENCIA, "T_COM", COLUMNA_COMUNA_REF_ID, "T_UV_NOM", COLUMNA_NOMBRE_UV_REF, 2014)

crosswalk_2015=crear_crosswalk(capa_2015, capa_2024, "concatenad","t_id_uv_ca","T_COM_NOM",COLUMNA_COMUNA_REFERENCIA, "comuna",COLUMNA_COMUNA_REF_ID, "T_UV_NOM" ,COLUMNA_NOMBRE_UV_REF, 2015)

crosswalk_2017=crear_crosswalk(capa_2017, capa_2024, "ID_UV","t_id_uv_ca","T_COM_NOM",COLUMNA_COMUNA_REFERENCIA, "COMUNA",COLUMNA_COMUNA_REF_ID,"T_UV_NOM" ,COLUMNA_NOMBRE_UV_REF, 2017)

crosswalk_2018=crear_crosswalk(capa_2018, capa_2024, "concatenad","t_id_uv_ca","T_COM_NOM",COLUMNA_COMUNA_REFERENCIA, "comuna",COLUMNA_COMUNA_REF_ID, "T_UV_NOM" ,COLUMNA_NOMBRE_UV_REF, 2018)

crosswalk_2019=crear_crosswalk(capa_2019, capa_2024, "uv_carto","t_id_uv_ca","COMUNA",COLUMNA_COMUNA_REFERENCIA, "COD_COM",COLUMNA_COMUNA_REF_ID, "T_UV_NOM" ,COLUMNA_NOMBRE_UV_REF, 2019)

crosswalk_2020=crear_crosswalk(capa_2020, capa_2024, "T_ID_UV_CA","t_id_uv_ca","T_COM_NOM",COLUMNA_COMUNA_REFERENCIA, "T_COM",COLUMNA_COMUNA_REF_ID, "T_UV_NOM" ,COLUMNA_NOMBRE_UV_REF, 2020)
    
crosswalk_2021=crear_crosswalk(capa_2021, capa_2024, "ID_UV","t_id_uv_ca","T_COM_NOM",COLUMNA_COMUNA_REFERENCIA, "T_COM",COLUMNA_COMUNA_REF_ID, "T_UV_NOM" ,COLUMNA_NOMBRE_UV_REF, 2021)

crosswalk_2022=crear_crosswalk(capa_2022, capa_2024, "ID_UV","t_id_uv_ca","T_COM_NOM",COLUMNA_COMUNA_REFERENCIA, "T_COM",COLUMNA_COMUNA_REF_ID,  "T_UV_NOM" ,COLUMNA_NOMBRE_UV_REF, 2022)

crosswalk_2023=crear_crosswalk(capa_2023, capa_2024, "t_id_uv_ca","t_id_uv_ca","t_com_nom",COLUMNA_COMUNA_REFERENCIA, "t_com",COLUMNA_COMUNA_REF_ID, "t_uv_nom" ,COLUMNA_NOMBRE_UV_REF, 2023)

crosswalk_2024=crear_crosswalk(capa_2024, capa_2024, "t_id_uv_ca","t_id_uv_ca","t_com_nom",COLUMNA_COMUNA_REFERENCIA, "t_com",COLUMNA_COMUNA_REF_ID, "t_uv_nom" ,COLUMNA_NOMBRE_UV_REF, 2024)


    
# %% 
# CREAR BASE MAESTRA 
anios= range(2014,2025)
tablas= [globals()[f"crosswalk_{a}"] for a in anios if f"crosswalk_{a}" in globals()]
uvs_madre = pd.concat(tablas, ignore_index=True)

print("Total base maestra:", len(uvs_madre))


    
# %% 
# EXPORTAR A STATA 

uvs_madre["id_uv_origen"]=uvs_madre["id_uv_origen"].astype(str)
uvs_madre["id_uv_2024"]=uvs_madre["id_uv_2024"].astype(str)
uvs_madre["flag_division"]=uvs_madre["flag_division"].astype(int)
uvs_madre["flag_multidestino"]=uvs_madre["flag_multidestino"].astype(int)
uvs_madre["sin_codigo_origen"]=uvs_madre["sin_codigo_origen"].astype(int)
uvs_madre["id_comuna_origen"]=uvs_madre["id_comuna_origen"].astype(str)
uvs_madre["id_comuna_2024"]=uvs_madre["id_comuna_2024"].astype(str)


uvs_madre.to_stata("uvs_madre.dta", version=118, write_index=False)
print("Guardado: uvs_madre.dta")


# %%
# PANEL DE UVS 2024: una fila por id_uv_2024 x anio

# esqueleto: todas las uv de 2024 x todos los anios del crosswalk
ids_2024 = capa_2024["t_id_uv_ca"].astype(str).unique()
anios_panel = sorted(uvs_madre["anio"].unique())
esqueleto = pd.DataFrame({"id_uv_2024": ids_2024}).merge(
    pd.DataFrame({"anio": anios_panel}), how="cross")

# cuantas uv de origen aterrizan en cada uv de 2024 por anio
colapso = uvs_madre.groupby(["anio", "id_uv_2024"], as_index=False).agg(
    n_uv_origen=("id_uv_origen", "nunique"),
    codigos_origen=("id_uv_origen", lambda s: ",".join(sorted(s.astype(str).unique()))))

# uv de origen DOMINANTE de cada uv de 2024 (la que aporta mas area);
# sus atributos sirven para el fuzzy match contra carto en revision_carto_uvs
dominante = (uvs_madre.sort_values("pct_area", ascending=False)
             .drop_duplicates(subset=["anio", "id_uv_2024"], keep="first"))
dominante = dominante[["anio", "id_uv_2024", "id_uv_origen",
                       "nombre_uv_origen", "id_comuna_origen", "pct_area"]]
dominante = dominante.rename(columns={
    "id_uv_origen": "codigo_uv_dom",
    "nombre_uv_origen": "nombre_uv_dom",
    "id_comuna_origen": "comuna_id_dom",
    "pct_area": "pct_area_dom"})

# pegar sobre el esqueleto (deja fila para toda uv de 2024, aunque no reciba a nadie)
panel_uv_2024 = esqueleto.merge(colapso, on=["id_uv_2024", "anio"], how="left")
panel_uv_2024 = panel_uv_2024.merge(dominante, on=["id_uv_2024", "anio"], how="left")
panel_uv_2024["n_uv_origen"] = panel_uv_2024["n_uv_origen"].fillna(0).astype(int)
panel_uv_2024["sin_origen"] = (panel_uv_2024["n_uv_origen"] == 0).astype(int)
panel_uv_2024["codigos_origen"] = panel_uv_2024["codigos_origen"].fillna("")
for c in ["codigo_uv_dom", "nombre_uv_dom", "comuna_id_dom"]:
    panel_uv_2024[c] = panel_uv_2024[c].fillna("")

# diagnostico: uv de 2024 sin ningun origen, por anio
print(panel_uv_2024.groupby("anio")["sin_origen"].sum())
print("panel_uv_2024:", len(panel_uv_2024), "filas")

panel_uv_2024.to_stata("panel_uv_2024.dta", version=118, write_index=False)
print("Guardado: panel_uv_2024.dta")


def exportar_stata(capa,ruta):
    capa= capa.drop(columns="geometry")
    for col in capa.select_dtypes(include="object").columns:
        capa[col] = capa[col].astype(str)
    capa.to_stata(ruta,write_index=False, version=118)

for a in anios:
    nombre = f"capa_{a}"
    if nombre in globals():
        exportar_stata(globals()[nombre], f"{nombre}.dta")
    else:
        print(nombre, "no existe")
        

#revisar duplicados 
dups = uvs_madre[uvs_madre.duplicated(subset=["anio", "id_uv_origen"], keep = False)]
print(dups.sort_values(["anio", "id_uv_origen"]))
print(uvs_madre["id_uv_origen"].apply(type).value_counts())
        
        

# EXPORTAR LAS FLAGGED 2017
flagged_2017 = crosswalk_2017[crosswalk_2017["flag_division"]]
ids_flagged = flagged_2017["id_uv_origen"]

capa_2017_flagged= capa_2017[capa_2017["ID_UV"].isin(ids_flagged)]
capa_2017_flagged.to_file("flagged_2017.shp")




# %% 
# CODEBOOK

def codebook_capa(capa,nombre):
    print(nombre,"-", len(capa), "filas")
    for col in capa.columns:
        if col == "geometry":
            continue
        ejemplos = list(capa[col].dropna().unique()[:3])
        print(col, capa[col].dtype, ejemplos)
    print()
    
    
capas=[
       (capa_2014, "Uv 2014"),
       (capa_2015, "Uv 2015"),
       (capa_2017, "Uv 2017"),
       (capa_2018, "Uv 2018"),
       (capa_2019, "Uv 2019"),
       (capa_2020, "Uv 2020"),
       (capa_2021, "Uv 2021"),
       (capa_2022, "Uv 2022"),
       (capa_2023, "Uv 2023"),
       (capa_2024, "Uv 2024"),
       ]
for capa, nombre in capas:
    codebook_capa(capa,nombre)
    



# %% 
#  EXPORTAR 

reporte_calidad = pd.DataFrame(filas)

import matplotlib.pyplot as plt 

fig, ax = plt.subplots(figsize=(10,4))   
ax.axis("off")

ax.table(cellText=reporte_calidad.values, colLabels=reporte_calidad.columns, loc = "center") 
plt.savefig("reporte_calidad_uv.pdf", bbox_inches="tight")

    
    