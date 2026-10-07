# English version of pe_02_eventstudy.py (same content, labels translated for slides)
# Primera etapa - paso 2: event study, 4 modelos (coefs_pe.csv)
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261006
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NAR, GRIS = '#2a78d6', '#eb6834', '#52514e'
d = pd.read_csv('coefs_pe.csv')
d = d[d.k.between(-5, 9)]
d['b'] = d.b * 100
d['se'] = d.se * 100

# un panel por ponderación; en cada uno TWFE (naranjo) vs SA (azul), desplazados 0,15
fig, axs = plt.subplots(1, 2, figsize=(12,4.2), sharey=True)
paneles = [('twfe', 'sa', 'Unweighted (average UV)'), ('twfe_w', 'sa_w', 'Weighted by no. of children (average child)')]
for ax, (mt, ms, tit) in zip(axs, paneles):
    for m, col, dx, lab in [(mt, NAR, -0.15, 'TWFE'), (ms, AZUL, 0.15, 'Sun-Abraham')]:
        x = d[d.modelo==m].sort_values('k')
        ax.errorbar(x.k + dx, x.b, yerr=1.96*x.se, fmt='o', color=col, ms=5, elinewidth=1.5, capsize=0, label=lab)
    ax.axhline(0, color=GRIS, lw=0.8)
    ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
    ax.set_xticks(range(-5, 10)); ax.set_xlabel('Years since opening (k)')
    ax.set_title(tit, loc='left', fontsize=10)
axs[0].set_ylabel('Effect on enrollment rate (pp)')
axs[0].legend(frameon=False, loc='upper left')
fig.suptitle('First stage: enrollment event study (95% CI, ref. k = −1)', x=0.01, ha='left')
fig.tight_layout(); fig.savefig('graficos/pe_02_eventstudy_en.png', dpi=200)
