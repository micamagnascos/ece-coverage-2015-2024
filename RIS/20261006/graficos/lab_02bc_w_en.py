# ln income and months worked event studies, weighted panel only (slides; same estimates as right panel of lab_02b/lab_02c *_en.png)
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261006
plt.rcParams.update({'font.size':11,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NAR, GRIS = '#2a78d6', '#eb6834', '#52514e'
d = pd.read_csv('coefs_lab.csv')
d = d[d.k.between(-5, 9)]

def evento_w(y, ylab, titulo, archivo):
    x0 = d[d.outcome==y]
    fig, ax = plt.subplots(figsize=(9,4.2))
    for m, col, dx, lab in [('twfe_w', NAR, -0.15, 'TWFE'), ('sa_w', AZUL, 0.15, 'Sun-Abraham')]:
        x = x0[x0.modelo==m].sort_values('k')
        ax.errorbar(x.k + dx, x.b, yerr=1.96*x.se, fmt='o', color=col, ms=6, elinewidth=1.8, capsize=0, label=lab)
    ax.axhline(0, color=GRIS, lw=0.8)
    ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
    ax.set_xticks(range(-5, 10)); ax.set_xlabel('Years since opening (k)')
    ax.set_ylabel(ylab)
    ax.legend(frameon=False, loc='upper left')
    ax.set_title(titulo, loc='left', fontsize=10.5)
    fig.tight_layout(); fig.savefig(archivo, dpi=200)

evento_w('ln_ingreso', 'Effect on ln income (0.05 ≈ 5%)',
         'ln annual income (mothers with income), weighted (95% CI, ref. k = −1)', 'graficos/lab_02b_ingreso_w_en.png')
evento_w('meses_trabajando', 'Effect on months worked',
         'Months worked (mothers with income), weighted (95% CI, ref. k = −1). Control mean = 8.7 months', 'graficos/lab_02c_meses_w_en.png')
