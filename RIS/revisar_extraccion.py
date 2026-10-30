# Revisa una extracción del RIS: cada matriz V tiene que calzar con algún modelo de los coefs de la MISMA carpeta
# (raíz de la diagonal de V = errores estándar). Si no calza con nada, es un archivo antiguo o de otro modelo.
# Uso: /opt/anaconda3/bin/python RIS/revisar_extraccion.py RIS/20261028
import sys, glob, os, numpy as np, pandas as pd

carpeta = sys.argv[1]
modelos = {}
for f in glob.glob(os.path.join(carpeta, 'coefs_*.csv')):
    c = pd.read_csv(f)
    if c.empty:
        print(f'VACÍO      {os.path.basename(f)} (solo encabezado)')
        continue
    for (m, o), d in c.groupby(['modelo', 'outcome']):
        modelos[(os.path.basename(f), m, o)] = d[d.se > 0].sort_values('k').se.values

for f in sorted(glob.glob(os.path.join(carpeta, '[vV]_*.csv'))):
    V = pd.read_csv(f).values
    se = np.sqrt(np.clip(np.diag(V), 0, None))
    se = se[se > 0]
    calza = [k for k, s in modelos.items() if len(s) == len(se) and np.allclose(s, se, rtol=1e-3)]
    if calza:
        print(f'OK         {os.path.basename(f)} ({V.shape[0]}x{V.shape[1]}) = ' + ' | '.join(f'{a}: {m} {o}' for a, m, o in calza))
    else:
        print(f'NO CALZA   {os.path.basename(f)} ({V.shape[0]}x{V.shape[1]}): no corresponde a ningún modelo de esta extracción')
