# Primera etapa: solo ponderado por niños, TWFE vs SA (versión slides en inglés)
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261006
plt.rcParams.update({'font.size':11,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NAR, GRIS = '#2a78d6', '#eb6834', '#52514e'
d = pd.read_csv('coefs_pe.csv')
d = d[d.k.between(-5, 9)]

fig, ax = plt.subplots(figsize=(7.5, 4.2))
for m, col, dx, lab in [('twfe_w', NAR, -0.12, 'TWFE'), ('sa_w', AZUL, 0.12, 'Sun-Abraham')]:
    x = d[d.modelo==m].sort_values('k')
    ax.errorbar(x.k + dx, 100*x.b, yerr=196*x.se, fmt='o', color=col, ms=5, elinewidth=1.5, capsize=0, label=lab)
ax.axhline(0, color=GRIS, lw=0.8)
ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
ax.set_xticks(range(-5, 10)); ax.set_xlabel('Years since opening (k)')
ax.set_ylabel('Effect on enrollment rate (pp)')
ax.legend(frameon=False, loc='upper left')
fig.tight_layout(); fig.savefig('graficos/pe_02_w_en.png', dpi=200)
