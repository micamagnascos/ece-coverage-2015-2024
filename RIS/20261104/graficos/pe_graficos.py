# Primera etapa v60 (extracción 04/11): event study, comparación con 28/10 y niveles
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261104
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NARANJA, GRIS, GRISC = '#2a78d6', '#d9822b', '#52514e', '#a3a29e'

c = pd.read_csv('coefs_pe_v60.csv')
ant = pd.read_csv('../20261028/coefs_pe_v60.csv')

def es(ax, d, col, dx, lab):
    x = d[d.k <= 7].sort_values('k')  # k = 8 y 9 solo los aportan las cohortes 2015-2016: no se muestran
    ax.errorbar(x.k + dx, 100*x.b, yerr=196*x.se.fillna(0), fmt='o', color=col, ms=5, elinewidth=1.6, capsize=0, label=lab)

def ejes(ax):
    ax.axhline(0, color=GRIS, lw=0.8); ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
    ax.set_xticks(range(-5, 8)); ax.set_xlabel('Años desde la apertura (k)'); ax.set_ylabel('Efecto en tasa de matrícula (pp)')

# 1. principal
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, c[c.modelo=='sa_w'], AZUL, 0, 'Principal')
ejes(ax)
fig.suptitle('Primera etapa: SA ponderado por niños (IC 95%, ref. k = −1). Media control 34,0%', x=0.01, ha='left')
fig.tight_layout(); fig.savefig('graficos/pe_01_principal.png', dpi=200)

# 2. comparación con la extracción del 28/10
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, ant[ant.modelo=='sa_w'], GRISC, -0.12, '28/10: crosswalk anterior')
es(ax, c[c.modelo=='sa_w'], AZUL, 0.12, '04/11: crosswalk corregido')
ejes(ax)
h, l = ax.get_legend_handles_labels(); fig.legend(h, l, loc='lower center', ncol=2, frameon=False)
fig.suptitle('Primera etapa: extracción anterior vs actual (SA ponderado, IC 95%, ref. k = −1)', x=0.01, ha='left')
fig.tight_layout(rect=(0, 0.09, 1, 1)); fig.savefig('graficos/pe_02_comparacion.png', dpi=200)

# 3. niveles: tasa bruta por año y brecha bruta por k
t = pd.read_csv('tend_pe_v60.csv')
t['tasa'] = t.matr / t.n_ninos
ctr = t[t.g1==0].set_index('anio').tasa
tr = t[t.g1>0].copy()
tr['k'] = tr.anio - tr.g1
tr['brecha'] = tr.tasa - tr.anio.map(ctr)
fig, (a1, a2) = plt.subplots(1, 2, figsize=(11, 4.4))
a1.plot(ctr.index, 100*ctr.values, color=GRIS, lw=2, label='Nunca tratadas')
g = tr.groupby('anio')[['matr','n_ninos']].sum()
a1.plot(g.index, 100*g.matr/g.n_ninos, color=AZUL, lw=2, label='Tratadas (todas las cohortes)')
a1.set_xlabel('Año'); a1.set_ylabel('Tasa de matrícula (%)'); a1.legend(frameon=False); a1.set_title('Tasa bruta por año', loc='left')
x = tr[tr.k.between(-5, 7)]
b = (x.brecha*x.n_ninos).groupby(x.k).sum() / x.groupby('k').n_ninos.sum()
a2.plot(b.index, 100*b.values, 'o-', color=AZUL, ms=5, lw=2)
a2.axhline(0, color=GRIS, lw=0.8); a2.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
a2.set_xticks(range(-5, 8)); a2.set_xlabel('Años desde la apertura (k)'); a2.set_ylabel('Tratadas − control (pp)')
a2.set_title('Brecha bruta tratadas − control, mismo año (pond. niños)', loc='left')
fig.tight_layout(); fig.savefig('graficos/pe_03_niveles.png', dpi=200)
print(b.round(4))
