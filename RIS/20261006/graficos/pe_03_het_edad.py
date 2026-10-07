# Primera etapa - paso 4: event study por edad del niño (coefs_het_pe.csv)
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261006
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NAR, GRIS = '#2a78d6', '#eb6834', '#52514e'
d = pd.read_csv('coefs_het_pe.csv')
d = d[d.k.between(-5, 9)]
d['b'] = d.b * 100
d['se'] = d.se * 100

fig, axs = plt.subplots(1, 3, figsize=(15,4.2), sharey=True)
grupos = [('e1', 'Sala cuna (0–1 años)'), ('e2', 'Nivel medio (2–3 años)'), ('e3', 'Transición (4 años)')]
for ax, (e, tit) in zip(axs, grupos):
    for m, col, dx, lab in [(f'twfe_{e}', NAR, -0.15, 'TWFE'), (f'sa_{e}', AZUL, 0.15, 'Sun-Abraham')]:
        x = d[d.modelo==m].sort_values('k')
        ax.errorbar(x.k + dx, x.b, yerr=1.96*x.se, fmt='o', color=col, ms=5, elinewidth=1.5, capsize=0, label=lab)
    m0 = d[d.modelo==f'sa_{e}'].media_ctrl.iloc[0] * 100
    ax.axhline(0, color=GRIS, lw=0.8)
    ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
    ax.set_xticks(range(-5, 10)); ax.set_xlabel('Años desde la apertura (k)')
    ax.set_title(f'{tit} — media control {m0:.0f}%', loc='left', fontsize=10)
axs[0].set_ylabel('Efecto en tasa de matrícula (pp)')
axs[0].legend(frameon=False, loc='upper left')
fig.suptitle('Primera etapa por edad del niño (IC 95%, ref. k = −1)', x=0.01, ha='left')
fig.tight_layout(); fig.savefig('graficos/pe_03_het_edad.png', dpi=200)
