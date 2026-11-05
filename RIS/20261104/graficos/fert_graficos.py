# Fertilidad (extracción 04/11): mujeres v60, 18-35 en 2014. Hasta k = 7
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261104
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NARANJA, GRIS, GRISC = '#2a78d6', '#d9822b', '#52514e', '#a3a29e'

c = pd.read_csv('coefs_fert_entr_v60cw.csv')
e = pd.read_csv('coefs_indm_e14.csv')
h = pd.read_csv('coefs_indm_e14_hijos.csv')

def es(ax, d, col, dx, lab, esc=100, fmt='o'):
    x = d[d.k <= 7].sort_values('k')  # k = 8 y 9 solo los aportan las cohortes 2015-2016: no se muestran
    ax.errorbar(x.k + dx, esc*x.b, yerr=1.96*esc*x.se.fillna(0), fmt=fmt, color=col, ms=5, elinewidth=1.6, capsize=0, label=lab)

def ejes(ax, y):
    ax.axhline(0, color=GRIS, lw=0.8); ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
    ax.set_xticks(range(-5, 8)); ax.set_xlabel('Años desde la apertura (k)'); ax.set_ylabel(y)

YT = 'Efecto en tuvo un hijo (pp)'
YN = 'Efecto en acumulados (hijos por 100 mujeres)'

# 1. tuvo hijo, principal
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, c[(c.modelo=='sa_w_e14') & (c.outcome=='tuvo_hijo')], AZUL, 0, 'Principal')
ejes(ax, YT)
fig.suptitle('Tuvo un hijo, mujeres 18–35 en 2014: SA ponderado (IC 95%, ref. k = −1). Media control 5,9%', x=0.01, ha='left')
fig.tight_layout(); fig.savefig('graficos/fert_01_tuvo_hijo.png', dpi=200)

# 2. tuvo hijo, versiones
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, c[(c.modelo=='sa_w_e14') & (c.outcome=='tuvo_hijo')], AZUL, -0.15, 'Principal (UV donde vive)')
es(ax, c[(c.modelo=='sa_w_e14_bal') & (c.outcome=='tuvo_hijo')], GRISC, 0, 'Balanceada (11 años)', fmt='s')
es(ax, e[(e.modelo=='sa_indm_e14') & (e.outcome=='tuvo_hijo')], NARANJA, 0.15, 'EF de mujer (UV fija), EE provisorios', fmt='^')
ejes(ax, YT)
h1, l1 = ax.get_legend_handles_labels(); fig.legend(h1, l1, loc='lower center', ncol=3, frameon=False)
fig.suptitle('Tuvo un hijo: tres versiones (IC 95%, ref. k = −1)', x=0.01, ha='left')
fig.tight_layout(rect=(0, 0.09, 1, 1)); fig.savefig('graficos/fert_02_tuvo_hijo_versiones.png', dpi=200)

# 3. tuvo hijo, solo EF de mujer
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, e[(e.modelo=='sa_indm_e14') & (e.outcome=='tuvo_hijo')], NARANJA, 0, 'EF de mujer', fmt='^')
ejes(ax, YT)
fig.suptitle('Tuvo un hijo, mismas mujeres con UV fija: EF de mujer (IC 95%, ref. k = −1, EE provisorios)', x=0.01, ha='left', fontsize=10.5)
fig.tight_layout(); fig.savefig('graficos/fert_03_tuvo_hijo_ef_mujer.png', dpi=200)

# 4. nacimientos acumulados, principal
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, c[(c.modelo=='sa_w_e14') & (c.outcome=='nac_acum')], AZUL, 0, 'Principal')
ejes(ax, YN)
fig.suptitle('Nacimientos acumulados, mujeres 18–35 en 2014: SA ponderado (IC 95%, ref. k = −1). Media control 0,38', x=0.01, ha='left', fontsize=10.5)
fig.tight_layout(); fig.savefig('graficos/fert_04_nac_acum.png', dpi=200)

# 5. nacimientos acumulados, versiones
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, c[(c.modelo=='sa_w_e14') & (c.outcome=='nac_acum')], AZUL, -0.15, 'Principal (UV donde vive)')
es(ax, c[(c.modelo=='sa_w_e14_bal') & (c.outcome=='nac_acum')], GRISC, 0, 'Balanceada (11 años)', fmt='s')
es(ax, e[(e.modelo=='sa_indm_e14') & (e.outcome=='nac_acum')], NARANJA, 0.15, 'EF de mujer (UV fija), EE provisorios', fmt='^')
ejes(ax, YN)
h1, l1 = ax.get_legend_handles_labels(); fig.legend(h1, l1, loc='lower center', ncol=3, frameon=False)
fig.suptitle('Nacimientos acumulados: tres versiones (IC 95%, ref. k = −1)', x=0.01, ha='left')
fig.tight_layout(rect=(0, 0.09, 1, 1)); fig.savefig('graficos/fert_05_nac_acum_versiones.png', dpi=200)

# 6. tuvo hijo por hijos antes de 2014, EF de mujer
fig, axs = plt.subplots(1, 3, figsize=(11, 4.2), sharey=True)
for ax, g, tit in zip(axs, ['h0', 'h1', 'h2'], ['Sin hijos antes de 2014', 'Un hijo', 'Dos o más']):
    es(ax, h[(h.modelo=='sa_indm_e14_'+g) & (h.outcome=='tuvo_hijo')], NARANJA, 0, tit, fmt='^')
    ejes(ax, YT if g=='h0' else ''); ax.set_title(tit, fontsize=10); ax.set_xticks(range(-5, 8, 2))
fig.suptitle('Tuvo un hijo según hijos antes de 2014: EF de mujer (IC 95%, ref. k = −1, EE provisorios)', x=0.01, ha='left')
fig.tight_layout(); fig.savefig('graficos/fert_06_tuvo_hijo_por_hijos.png', dpi=200)

# 7. tasa bruta por año (todas las mujeres de la muestra de fertilidad)
t = pd.read_csv('tend_fert_v60cw.csv')
y = t.assign(tr=t.g1>0).groupby(['anio', 'tr'])[['nac', 'n_mujeres']].sum()
y = (100*y.nac/y.n_mujeres).unstack()
fig, ax = plt.subplots(figsize=(8, 4.6))
ax.plot(y.index, y[False], color=GRIS, lw=2, label='Nunca tratadas')
ax.plot(y.index, y[True], color=AZUL, lw=2, ls='--', label='Tratadas (todas las cohortes)')
ax.set_xlabel('Año'); ax.set_ylabel('% de mujeres que tuvo un hijo'); ax.set_ylim(0, None); ax.legend(frameon=False)
fig.suptitle('Tasa bruta de natalidad, mujeres v60 de 18 a 49 años', x=0.01, ha='left')
fig.tight_layout(); fig.savefig('graficos/fert_07_tasa_bruta.png', dpi=200)

# 8. brecha cruda tratadas - control, por grupo de cohortes
t['r'] = 100*t.nac/t.n_mujeres
z = t[t.g1>=2015].copy()
z['k'] = z.anio - z.g1
z['gap'] = z.r - z.anio.map(t[t.g1==0].set_index('anio').r)
def brecha(d): return d[d.k.between(-3, 5)].groupby('k')[['gap', 'n_mujeres']].apply(lambda x: (x.gap*x.n_mujeres).sum()/x.n_mujeres.sum())
fig, ax = plt.subplots(figsize=(8, 4.6))
b = brecha(z[z.g1<=2016]); ax.plot(b.index, b.values, color=NARANJA, lw=2, marker='^', ms=5, label='Cohortes 2015–2016')
b = brecha(z[z.g1.between(2017, 2019)]); ax.plot(b.index, b.values, color=AZUL, lw=2, marker='o', ms=5, label='Cohortes 2017–2019')
ax.axhline(0, color=GRIS, lw=0.8); ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
ax.set_xticks(range(-3, 6)); ax.set_xlabel('Años desde la apertura (k)'); ax.set_ylabel('Tratadas − control (nacimientos por 100 mujeres)'); ax.legend(frameon=False)
fig.suptitle('Brecha cruda en la tasa de natalidad, mujeres de 18 a 49', x=0.01, ha='left')
fig.tight_layout(); fig.savefig('graficos/fert_08_brecha_cruda.png', dpi=200)

# 9. tuvo hijo, solo EF de mujer balanceada
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, e[(e.modelo=='sa_indm_e14') & (e.outcome=='bal_tuvo_hijo')], NARANJA, 0, 'EF de mujer balanceada', fmt='^')
ejes(ax, YT)
fig.suptitle('Tuvo un hijo, mujeres de los 11 años con UV fija: EF de mujer (IC 95%, ref. k = −1, EE provisorios)', x=0.01, ha='left', fontsize=10.5)
fig.tight_layout(); fig.savefig('graficos/fert_09_tuvo_hijo_ef_mujer_bal.png', dpi=200)

# 10. nacimientos acumulados, solo EF de mujer balanceada
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, e[(e.modelo=='sa_indm_e14') & (e.outcome=='bal_nac_acum')], NARANJA, 0, 'EF de mujer balanceada', fmt='^')
ejes(ax, YN)
fig.suptitle('Nac. acumulados, mujeres de los 11 años con UV fija: EF de mujer (IC 95%, ref. k = −1, EE provisorios)', x=0.01, ha='left', fontsize=10.5)
fig.tight_layout(); fig.savefig('graficos/fert_10_nac_acum_ef_mujer_bal.png', dpi=200)
