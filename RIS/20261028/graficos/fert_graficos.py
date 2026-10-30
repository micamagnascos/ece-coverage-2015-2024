# Fertilidad v60 18-49 (extracción 28/10) vs extracción 06/10 (todas las mujeres, base original). Hasta k = 7
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261028
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, GRIS, GRISC = '#2a78d6', '#52514e', '#a3a29e'

c = pd.read_csv('coefs_fert_v60fija.csv')
ant = pd.read_csv('../20261006/coefs_fert.csv')

def es(ax, d, col, dx, lab):
    x = d[d.k <= 7].sort_values('k')
    ax.errorbar(x.k + dx, 100*x.b, yerr=196*x.se, fmt='o', color=col, ms=4.5, elinewidth=1.4, capsize=0, label=lab)

fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, ant[ant.modelo=='sa_w'], GRISC, -0.12, '06/10: todas las mujeres, base original')
es(ax, c[c.modelo=='sa_w'], AZUL, 0.12, '28/10: mujeres v60, base corregida')
ax.axhline(0, color=GRIS, lw=0.8); ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
ax.set_xticks(range(-5, 8)); ax.set_xlabel('Años desde la apertura (k)'); ax.set_ylabel('Efecto en tasa de natalidad (pp)')
h, l = ax.get_legend_handles_labels(); fig.legend(h, l, loc='lower center', ncol=2, frameon=False, fontsize=9)
fig.suptitle('Fertilidad, mujeres 18–49: SA ponderado (IC 95%, ref. k = −1). Media control 4,4%', x=0.01, ha='left')
fig.tight_layout(rect=(0, 0.09, 1, 1)); fig.savefig('graficos/fert_01_eventstudy.png', dpi=200)

# tasa bruta por año: tratadas vs control
t = pd.read_csv('tend_fert_v60fija.csv')
ctr = t[t.g1==0].set_index('anio')
tr = t[t.g1>0].groupby('anio')[['nac', 'n_mujeres']].sum()
fig, ax = plt.subplots(figsize=(7, 4.2))
ax.plot(ctr.index, 100*ctr.nac/ctr.n_mujeres, color=GRIS, lw=2, label='Nunca tratadas')
ax.plot(tr.index, 100*tr.nac/tr.n_mujeres, color=AZUL, lw=2, ls='--', label='Tratadas (todas las cohortes)')
ax.set_xlabel('Año'); ax.set_ylabel('% de mujeres que tuvo un hijo'); ax.legend(frameon=False)
fig.suptitle('Tasa de natalidad bruta, mujeres v60 18–49', x=0.01, ha='left')
fig.tight_layout(); fig.savefig('graficos/fert_02_descriptivo.png', dpi=200)

# UV-año vs efecto fijo de mujer (08b, muestra completa)
m = pd.read_csv('coefs_indm_fert.csv')
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, c[c.modelo=='sa_w'], AZUL, -0.12, 'Por UV-año (principal)')
es(ax, m[m.modelo=='sa_indm'], '#d9822b', 0.12, 'Efecto fijo de mujer, UV fija')
ax.axhline(0, color=GRIS, lw=0.8); ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
ax.set_xticks(range(-5, 8)); ax.set_xlabel('Años desde la apertura (k)'); ax.set_ylabel('Efecto en tasa de natalidad (pp)')
h, l = ax.get_legend_handles_labels(); fig.legend(h, l, loc='lower center', ncol=2, frameon=False, fontsize=9)
fig.suptitle('Fertilidad, mujeres v60 18–49: dos especificaciones (IC 95%, ref. k = −1)', x=0.01, ha='left')
fig.tight_layout(rect=(0, 0.09, 1, 1)); fig.savefig('graficos/fert_03_ef_mujer.png', dpi=200)
