# Gráficos en inglés para la presentación short term, extracción 04/11 (hasta k = 7)
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261104
plt.rcParams.update({'font.size':11,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NARANJA, GRIS, GRISC = '#2a78d6', '#d9822b', '#52514e', '#a3a29e'

pe = pd.read_csv('coefs_pe_v60.csv')
lab = pd.read_csv('coefs_lab_entrada.csv')
fi = pd.read_csv('coefs_indm_empleo_entr.csv')
fe = pd.read_csv('coefs_fert_entr_v60cw.csv')
fm = pd.read_csv('coefs_indm_e14.csv')
fh = pd.read_csv('coefs_indm_e14_hijos.csv')

def puntos(ax, d, m, y, esc, col, dx, nom, fmt='o'):
    x = d[(d.modelo==m) & (d.outcome==y) & d.k.between(-5, 7)].sort_values('k')
    ax.errorbar(x.k + dx, esc*x.b, yerr=1.96*esc*x.se.fillna(0), fmt=fmt, color=col, ms=5, elinewidth=1.6, capsize=0, label=nom)

def ejes(ax, ylab):
    ax.axhline(0, color=GRIS, lw=0.8); ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
    ax.set_xticks(range(-5, 8)); ax.set_xlabel('Years since opening (k)'); ax.set_ylabel(ylab)

def evento(series, esc, ylab, nombre):
    fig, ax = plt.subplots(figsize=(7.5, 4.2))
    for d, m, y, col, dx, nom, fmt in series:
        puntos(ax, d, m, y, esc, col, dx, nom, fmt)
    ejes(ax, ylab)
    if len(series) > 1:
        h, l = ax.get_legend_handles_labels(); fig.legend(h, l, loc='lower center', ncol=2, frameon=False, fontsize=10)
        fig.tight_layout(rect=(0, 0.07, 1, 1))
    else:
        fig.tight_layout()
    fig.savefig('graficos/'+nombre, dpi=200); plt.close(fig)

def ef_bal(d, m, y, ybal, esc, ylab, nombre):
    evento([(d, m, y, NARANJA, -0.08, 'Woman FE', '^'), (d, m + ('_bal' if y == ybal else ''), ybal, GRISC, 0.08, 'Woman FE, balanced', 's')], esc, ylab, nombre)

def completa_bal(d, y, esc, ylab, nombre):
    evento([(d, 'sa_w', y, AZUL, -0.08, 'Full sample', 'o'), (d, 'sa_w_bal', y, GRISC, 0.08, 'Balanced', 's')], esc, ylab, nombre)

YE, YI, YL = 'Effect on formal employment (pp)', 'Effect on earnings incl. zeros (% of mean)', 'Effect on ln earnings (≈ %)'
YT, YN = 'Effect on births (pp)', 'Cumulative births (per 100 women)'

evento([(pe, 'sa_w', 'tasa_matricula', AZUL, 0, 'Full sample', 'o')], 100, 'Effect on enrollment (pp)', 'en_pe.png')
completa_bal(lab, 'empleo_formal', 100, YE, 'en_empleo.png')
ef_bal(fi, 'sa_indm_entr', 'empleo_formal', 'empleo_formal', 100, YE, 'en_empleo_ef.png')
completa_bal(lab, 'ingreso_rel', 1, YI, 'en_ingreso.png')
ef_bal(fi, 'sa_indm_entr', 'ingreso_rel', 'ingreso_rel', 1, YI, 'en_ingreso_ef.png')
completa_bal(lab, 'ln_ingreso', 100, YL, 'en_ln.png')
evento([(fi, 'sa_indm_entr', 'ln_ingreso', NARANJA, 0, 'Woman FE', '^')], 100, YL, 'en_ln_ef.png')
evento([(fe, 'sa_w_e14', 'tuvo_hijo', AZUL, -0.08, 'Full sample', 'o'), (fe, 'sa_w_e14_bal', 'tuvo_hijo', GRISC, 0.08, 'Balanced', 's')], 100, YT, 'en_fert.png')
ef_bal(fm, 'sa_indm_e14', 'tuvo_hijo', 'bal_tuvo_hijo', 100, YT, 'en_fert_ef.png')
evento([(fe, 'sa_w_e14', 'nac_acum', AZUL, -0.08, 'Full sample', 'o'), (fe, 'sa_w_e14_bal', 'nac_acum', GRISC, 0.08, 'Balanced', 's')], 100, YN, 'en_nac.png')
evento([(fe, 'sa_w_e14', 'hijos_total', AZUL, -0.08, 'Full sample', 'o'), (fe, 'sa_w_e14_bal', 'hijos_total', GRISC, 0.08, 'Balanced', 's')], 100, 'Effect on total children (per 100 women)', 'en_hijos_total.png')

# anexo: según hijos antes de 2014
fig, axs = plt.subplots(1, 3, figsize=(11, 4.0), sharey=True)
for ax, g, tit in zip(axs, ['h0', 'h1', 'h2'], ['No children before 2014', 'One child', 'Two or more']):
    puntos(ax, fh, 'sa_indm_e14_'+g, 'tuvo_hijo', 100, NARANJA, 0, tit, '^')
    ejes(ax, YT if g=='h0' else ''); ax.set_title(tit, fontsize=11); ax.set_xticks(range(-5, 8, 2))
fig.tight_layout(); fig.savefig('graficos/en_fert_hijos.png', dpi=200); plt.close(fig)

# anexo: tasa bruta por año
t = pd.read_csv('tend_fert_v60cw.csv')
y = t.assign(tr=t.g1>0).groupby(['anio', 'tr'])[['nac', 'n_mujeres']].sum()
y = (100*y.nac/y.n_mujeres).unstack()
fig, ax = plt.subplots(figsize=(7.5, 4.2))
ax.plot(y.index, y[False], color=GRISC, lw=5, label='Never treated')
ax.plot(y.index, y[True], color=AZUL, lw=1.8, ls='--', label='Treated (all cohorts)')
ax.set_xlabel('Year'); ax.set_ylabel('Births per 100 women'); ax.set_ylim(2, 7); ax.legend(frameon=False)
fig.tight_layout(); fig.savefig('graficos/en_fert_tasa.png', dpi=200); plt.close(fig)

# lámina 2022: empleo crudo por año, tratadas y control
l = pd.read_csv('tend_lab_entrada.csv')
y = l.assign(tr=l.g1>0).groupby(['anio', 'tr'])[['emp', 'n_mujeres']].sum()
y = (100*y.emp/y.n_mujeres).unstack()
fig, ax = plt.subplots(figsize=(7.0, 4.4))
ax.plot(y.index, y[False], color=GRIS, lw=2, label='Never treated')
ax.plot(y.index, y[True], color=AZUL, lw=2, ls='--', label='Treated (all cohorts)')
ax.axvline(2022, color=NARANJA, ls=':', lw=1.5)
ax.set_xticks(range(2014, 2025, 2)); ax.set_xlabel('Year'); ax.set_ylabel('Mothers with formal earnings (%)'); ax.set_ylim(30, 70); ax.legend(frameon=False, loc="lower left")
fig.tight_layout(); fig.savefig('graficos/en_empleo_2022.png', dpi=200); plt.close(fig)
