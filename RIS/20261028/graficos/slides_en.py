# Gráficos en inglés para la presentación short term (solo ponderados, hasta k = 7)
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261028
plt.rcParams.update({'font.size':11,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NARANJA, GRIS, GRISC = '#2a78d6', '#d9822b', '#52514e', '#a3a29e'

pe = pd.read_csv('coefs_pe_v60.csv')
pe_ant = pd.read_csv('../20261006/coefs_pe.csv')
lab = pd.read_csv('coefs_lab_v60fija.csv')
lab_ant = pd.read_csv('../20261014/coefs_lab_v60.csv')
fe = pd.read_csv('coefs_fert_v60fija.csv')
fe_ant = pd.read_csv('../20261006/coefs_fert.csv')
fe_indm = pd.read_csv('coefs_indm_fert.csv')

def evento(series, escala, ylab, archivo, loc='upper left'):
    fig, ax = plt.subplots(figsize=(7.5, 4.2))
    for d, m, y, col, dx, lab_ in series:
        x = d[(d.modelo==m) & (d.outcome==y) & d.k.between(-5, 7)].sort_values('k')
        ax.errorbar(x.k + dx, x.b * escala, yerr=1.96 * x.se * escala, fmt='o', color=col, ms=5, elinewidth=1.5, capsize=0, label=lab_)
    ax.axhline(0, color=GRIS, lw=0.8)
    ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
    ax.set_xticks(range(-5, 8)); ax.set_xlabel('Years since opening (k)')
    ax.set_ylabel(ylab)
    if len(series) > 1:
        ax.legend(loc=loc, frameon=False, fontsize=9.5)
    fig.tight_layout(); fig.savefig(archivo, dpi=200)

# primera etapa: antes vs ahora
evento([(pe_ant, 'sa_w', 'tasa_matricula', GRISC, -0.12, 'Previous (Oct 6): original data'),
        (pe, 'sa_w', 'tasa_matricula', AZUL, 0.12, 'Now: corrected opening years and UV crosswalk')],
       100, 'Effect on enrollment rate (pp)', 'graficos/en_pe_comparacion.png')

# primera etapa: niveles y brecha bruta
t = pd.read_csv('tend_pe_v60.csv'); t['tasa'] = t.matr / t.n_ninos
ctr = t[t.g1==0].set_index('anio').tasa
tr = t[t.g1>0].copy(); tr['k'] = tr.anio - tr.g1; tr['brecha'] = tr.tasa - tr.anio.map(ctr)
g = tr.groupby('anio').apply(lambda d: d.matr.sum() / d.n_ninos.sum())
b = tr[tr.k.between(-5, 7)].groupby('k').apply(lambda d: (d.brecha * d.n_ninos).sum() / d.n_ninos.sum())
fig, (a1, a2) = plt.subplots(1, 2, figsize=(11, 4.2))
a1.plot(ctr.index, 100*ctr.values, color=GRIS, lw=2, label='Never treated')
a1.plot(g.index, 100*g.values, color=AZUL, lw=2, label='Treated (all cohorts)')
a1.set_xlabel('Year'); a1.set_ylabel('Enrollment rate (%)'); a1.legend(frameon=False); a1.set_title('Raw enrollment rate', loc='left')
a2.plot(b.index, 100*b.values, 'o-', color=AZUL, ms=4.5)
a2.axhline(0, color=GRIS, lw=0.8); a2.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
a2.set_xticks(range(-5, 8)); a2.set_xlabel('Years since opening (k)'); a2.set_ylabel('Treated − control (pp)')
a2.set_title('Raw gap, treated − control, same year', loc='left')
fig.tight_layout(); fig.savefig('graficos/en_pe_niveles.png', dpi=200)

# empleo: antes vs ahora
evento([(lab_ant, 'sa_w_v60', 'empleo_formal', GRISC, -0.12, 'Previous (Oct 14)'),
        (lab, 'sa_w', 'empleo_formal', AZUL, 0.12, 'Now: fixed mother sample, corrected data')],
       100, 'Effect on formal employment (pp)', 'graficos/en_lab_empleo.png')

# ingreso en pesos
evento([(lab, 'sa_w', 'ingreso_mes24', AZUL, 0, '')],
       1/1000, 'Effect on monthly earnings incl. zeros\n(thousand CLP of 2024)', 'graficos/en_lab_ingreso_pesos.png')

# ingreso relativo (media del año = 100), para el anexo
evento([(lab, 'sa_w', 'ingreso_rel', AZUL, 0, '')],
       1, 'Effect on earnings incl. zeros\n(points, year mean = 100)', 'graficos/en_lab_ingreso_rel.png')

# ln ingreso: antes vs ahora
evento([(lab_ant, 'sa_w_v60', 'ln_ingreso', GRISC, -0.12, 'Previous (Oct 14)'),
        (lab, 'sa_w', 'ln_ingreso', AZUL, 0.12, 'Now: fixed mother sample, corrected data')],
       100, 'Effect on earnings of working mothers (%)', 'graficos/en_lab_ln_ingreso.png')

# fertilidad: niveles
tf = pd.read_csv('tend_fert_v60fija.csv')
c0 = tf[tf.g1==0].set_index('anio')
c1 = tf[tf.g1>0].groupby('anio')[['nac', 'n_mujeres']].sum()
fig, ax = plt.subplots(figsize=(7.5, 4.2))
ax.plot(c0.index, 100*c0.nac/c0.n_mujeres, color=GRIS, lw=2, label='Never treated')
ax.plot(c1.index, 100*c1.nac/c1.n_mujeres, color=AZUL, lw=2, ls='--', label='Treated (all cohorts)')
ax.set_xlabel('Year'); ax.set_ylabel('% of women who had a child'); ax.legend(frameon=False)
fig.tight_layout(); fig.savefig('graficos/en_fert_niveles.png', dpi=200)

# fertilidad: UV vs efecto fijo de mujer
evento([(fe, 'sa_w', 'tuvo_hijo', AZUL, -0.12, 'UV-year (main)'),
        (fe_indm, 'sa_indm', 'tuvo_hijo', NARANJA, 0.12, 'Woman fixed effects, fixed UV')],
       100, 'Effect on birth rate (pp)', 'graficos/en_fert_ef_mujer.png', loc='lower left')
