# Gráficos en inglés para la presentación short term (solo ponderados)
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261014
plt.rcParams.update({'font.size':11,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, GRIS, GRISC = '#2a78d6', '#52514e', '#a3a29e'

v60 = pd.read_csv('coefs_lab_v60.csv')
full = pd.read_csv('../20261006/coefs_lab.csv')
pe_full = pd.read_csv('../20261006/coefs_pe.csv')
pe_s15 = pd.read_csv('coefs_pe_sin2015.csv')

def evento(series, escala, ylab, archivo, loc='lower right'):
    fig, ax = plt.subplots(figsize=(7.5, 4.2))
    for d, m, y, col, dx, lab in series:
        x = d[(d.modelo==m) & (d.outcome==y) & d.k.between(-5, 9)].sort_values('k')
        ax.errorbar(x.k + dx, x.b * escala, yerr=1.96 * x.se * escala, fmt='o', color=col, ms=5, elinewidth=1.5, capsize=0, label=lab)
    ax.axhline(0, color=GRIS, lw=0.8)
    ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
    ax.set_xticks(range(-5, 10)); ax.set_xlabel('Years since opening (k)')
    ax.set_ylabel(ylab)
    if len(series) > 1:
        ax.legend(loc=loc, frameon=False)
    fig.tight_layout(); fig.savefig(archivo, dpi=200)

evento([(full, 'sa_w', 'empleo_formal', GRISC, -0.12, 'All mothers (previous)'),
        (v60, 'sa_w_v60', 'empleo_formal', AZUL, 0.12, '60% most vulnerable')],
       100, 'Effect on formal employment (pp)', 'graficos/en_v60_empleo.png')

evento([(v60, 'sa_w_v60', 'ingreso_rel', AZUL, 0, '60% most vulnerable')],
       1, 'Effect on earnings incl. zeros (≈ % of mean)', 'graficos/en_v60_ingreso_rel.png')

evento([(pe_full, 'sa_w', 'tasa_matricula', GRISC, -0.12, 'All cohorts (previous)'),
        (pe_s15, 'sa_w', 'tasa_matricula', AZUL, 0.12, 'Without 2015 cohort')],
       100, 'Effect on enrollment rate (pp)', 'graficos/en_pe_sin2015.png', loc='lower left')

evento([(full, 'sa_w', 'ln_ingreso', GRISC, -0.12, 'All mothers (previous)'),
        (v60, 'sa_w_v60', 'ln_ingreso', AZUL, 0.12, '60% most vulnerable')],
       100, 'Effect on earnings of working mothers (%)', 'graficos/en_v60_ln_ingreso.png', loc='upper right')
