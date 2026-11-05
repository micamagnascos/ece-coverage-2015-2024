# Ingresos (extracción 04/11): con ceros en pesos, ln ingreso y versiones
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261104
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NARANJA, GRIS, GRISC = '#2a78d6', '#d9822b', '#52514e', '#a3a29e'

c = pd.read_csv('coefs_lab_entrada.csv')
f = pd.read_csv('coefs_indm_empleo_entr.csv')

def es(ax, d, col, dx, lab, esc=1, fmt='o'):
    x = d[d.k <= 7].sort_values('k')  # k = 8 y 9 solo los aportan las cohortes 2015-2016: no se muestran
    ax.errorbar(x.k + dx, esc*x.b, yerr=1.96*esc*x.se.fillna(0), fmt=fmt, color=col, ms=5, elinewidth=1.6, capsize=0, label=lab)

def ejes(ax, y):
    ax.axhline(0, color=GRIS, lw=0.8); ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
    ax.set_xticks(range(-5, 8)); ax.set_xlabel('Años desde la apertura (k)'); ax.set_ylabel(y)

# 1. ingreso con ceros en pesos
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, c[(c.modelo=='sa_w') & (c.outcome=='ingreso_mes24')], AZUL, 0, 'Principal', 1/1000)
ejes(ax, 'Efecto en ingreso con ceros (miles de $ al mes)')
fig.suptitle('Ingreso con ceros: SA ponderado (IC 95%, ref. k = −1). Media a ingresos de 2024: $422 mil', x=0.01, ha='left')
fig.tight_layout(); fig.savefig('graficos/lab_04_ingreso_pesos.png', dpi=200)

# 2. ingreso con ceros, versiones
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, c[(c.modelo=='sa_w') & (c.outcome=='ingreso_rel')], AZUL, -0.15, 'Principal (UV donde vive)')
es(ax, c[(c.modelo=='sa_w_bal') & (c.outcome=='ingreso_rel')], GRISC, 0, 'Balanceada (11 años)', fmt='s')
es(ax, f[(f.modelo=='sa_indm_entr') & (f.outcome=='ingreso_rel')], NARANJA, 0.15, 'EF de mujer (UV fija), EE provisorios', fmt='^')
ejes(ax, 'Efecto en ingreso con ceros (% del promedio)')
h, l = ax.get_legend_handles_labels(); fig.legend(h, l, loc='lower center', ncol=3, frameon=False)
fig.suptitle('Ingreso con ceros: tres versiones (IC 95%, ref. k = −1)', x=0.01, ha='left')
fig.tight_layout(rect=(0, 0.09, 1, 1)); fig.savefig('graficos/lab_05_ingreso_versiones.png', dpi=200)

# 3. ln ingreso, versiones
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, c[(c.modelo=='sa_w') & (c.outcome=='ln_ingreso')], AZUL, -0.15, 'Principal (UV donde vive)', 100)
es(ax, c[(c.modelo=='sa_w_bal') & (c.outcome=='ln_ingreso')], GRISC, 0, 'Balanceada (11 años)', 100, 's')
es(ax, f[(f.modelo=='sa_indm_entr') & (f.outcome=='ln_ingreso')], NARANJA, 0.15, 'EF de mujer (UV fija), EE provisorios', 100, '^')
ejes(ax, 'Efecto en ln ingreso (≈ %)')
h, l = ax.get_legend_handles_labels(); fig.legend(h, l, loc='lower center', ncol=3, frameon=False)
fig.suptitle('Ln ingreso, solo madres con ingreso: tres versiones (IC 95%, ref. k = −1)', x=0.01, ha='left')
fig.tight_layout(rect=(0, 0.09, 1, 1)); fig.savefig('graficos/lab_06_ln_ingreso_versiones.png', dpi=200)

# 4. ln ingreso, solo principal
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, c[(c.modelo=='sa_w') & (c.outcome=='ln_ingreso')], AZUL, 0, 'Principal', 100)
ejes(ax, 'Efecto en ln ingreso (≈ %)')
fig.suptitle('Ln ingreso, solo madres con ingreso: SA ponderado (IC 95%, ref. k = −1)', x=0.01, ha='left')
fig.tight_layout(); fig.savefig('graficos/lab_07_ln_ingreso.png', dpi=200)

# 5. ingreso con ceros, solo EF de mujer
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, f[(f.modelo=='sa_indm_entr') & (f.outcome=='ingreso_rel')], NARANJA, 0, 'EF de mujer', fmt='^')
ejes(ax, 'Efecto en ingreso con ceros (% del promedio)')
fig.suptitle('Ingreso con ceros, mismas mujeres con UV fija: EF de mujer (IC 95%, ref. k = −1, EE provisorios)', x=0.01, ha='left', fontsize=10.5)
fig.tight_layout(); fig.savefig('graficos/lab_08_ingreso_ef_mujer.png', dpi=200)

# 6. ln ingreso, solo EF de mujer
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, f[(f.modelo=='sa_indm_entr') & (f.outcome=='ln_ingreso')], NARANJA, 0, 'EF de mujer', 100, '^')
ejes(ax, 'Efecto en ln ingreso (≈ %)')
fig.suptitle('Ln ingreso, mismas mujeres con ingreso y UV fija: EF de mujer (IC 95%, ref. k = −1, EE provisorios)', x=0.01, ha='left', fontsize=10.5)
fig.tight_layout(); fig.savefig('graficos/lab_09_ln_ingreso_ef_mujer.png', dpi=200)

# 7. ingreso con ceros, solo EF de mujer balanceada
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, f[(f.modelo=='sa_indm_entr_bal') & (f.outcome=='ingreso_rel')], NARANJA, 0, 'EF de mujer balanceada', fmt='^')
ejes(ax, 'Efecto en ingreso con ceros (% del promedio)')
fig.suptitle('Ingreso con ceros, mujeres de los 11 años con UV fija: EF de mujer (IC 95%, ref. k = −1, EE provisorios)', x=0.01, ha='left', fontsize=10.5)
fig.tight_layout(); fig.savefig('graficos/lab_12_ingreso_ef_mujer_bal.png', dpi=200)
