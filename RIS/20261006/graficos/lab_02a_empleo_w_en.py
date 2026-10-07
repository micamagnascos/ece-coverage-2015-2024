# Formal employment event study, weighted panel only (slides; same estimates as lab_02a_eventstudy_empleo_en.png, right panel)
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261006
plt.rcParams.update({'font.size':11,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NAR, GRIS = '#2a78d6', '#eb6834', '#52514e'
d = pd.read_csv('coefs_lab.csv')
d = d[(d.outcome=='empleo_formal') & d.k.between(-5, 9)].copy()
d['b'] = d.b * 100
d['se'] = d.se * 100

fig, ax = plt.subplots(figsize=(9,4.2))
for m, col, dx, lab in [('twfe_w', NAR, -0.15, 'TWFE'), ('sa_w', AZUL, 0.15, 'Sun-Abraham')]:
    x = d[d.modelo==m].sort_values('k')
    ax.errorbar(x.k + dx, x.b, yerr=1.96*x.se, fmt='o', color=col, ms=6, elinewidth=1.8, capsize=0, label=lab)
ax.axhline(0, color=GRIS, lw=0.8)
ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
ax.set_xticks(range(-5, 10)); ax.set_xlabel('Years since opening (k)')
ax.set_ylabel('Effect on % formally employed (pp)')
ax.legend(frameon=False, loc='upper left')
ax.set_title('Formal employment of mothers, weighted (95% CI, ref. k = −1). Control mean = 48.9%', loc='left', fontsize=10.5)
fig.tight_layout(); fig.savefig('graficos/lab_02a_empleo_w_en.png', dpi=200)
