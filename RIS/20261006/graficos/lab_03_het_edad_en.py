# English version of lab_03_het_edad.py (same content, labels translated for slides)
# Mercado laboral - heterogeneidad: event study por edad del hijo menor (coefs_het_lab.csv)
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261006
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NAR, GRIS = '#2a78d6', '#eb6834', '#52514e'
d = pd.read_csv('coefs_het_lab.csv')
d = d[d.k.between(-5, 9)].copy()
grupos = [('e1', 'Youngest child aged 0–1'), ('e2', 'Youngest child aged 2–3'), ('e3', 'Youngest child aged 4')]

# (a) empleo formal, en pp
x = d[d.outcome=='empleo_formal'].copy(); x['b'] = x.b*100; x['se'] = x.se*100
fig, axs = plt.subplots(1, 3, figsize=(15,4.6), sharey=True)
for ax, (e, tit) in zip(axs, grupos):
    for m, col, dx, lab in [(f'twfe_{e}', NAR, -0.15, 'TWFE'), (f'sa_{e}', AZUL, 0.15, 'Sun-Abraham')]:
        z = x[x.modelo==m].sort_values('k')
        ax.errorbar(z.k + dx, z.b, yerr=1.96*z.se, fmt='o', color=col, ms=5, elinewidth=1.5, capsize=0, label=lab)
    m0 = x[x.modelo==f'sa_{e}'].media_ctrl.iloc[0]*100
    ax.axhline(0, color=GRIS, lw=0.8); ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
    ax.set_xticks(range(-5, 10)); ax.set_xlabel('Years since opening (k)')
    ax.set_title(f'{tit} — control mean {m0:.0f}%', loc='left', fontsize=10)
axs[0].set_ylabel('Effect on % formally employed (pp)')
h, l = axs[0].get_legend_handles_labels(); fig.legend(h, l, loc='lower center', ncol=2, frameon=False)
fig.suptitle('Formal employment of mothers by age of youngest child (unweighted, 95% CI, ref. k = −1)', x=0.01, ha='left')
fig.tight_layout(rect=(0, 0.07, 1, 1)); fig.savefig('graficos/lab_03a_het_empleo_en.png', dpi=200)

# (b) ln ingreso (madres con ingreso)
x = d[d.outcome=='ln_ingreso']
fig, axs = plt.subplots(1, 3, figsize=(15,4.6), sharey=True)
for ax, (e, tit) in zip(axs, grupos):
    for m, col, dx, lab in [(f'twfe_{e}', NAR, -0.15, 'TWFE'), (f'sa_{e}', AZUL, 0.15, 'Sun-Abraham')]:
        z = x[x.modelo==m].sort_values('k')
        ax.errorbar(z.k + dx, z.b, yerr=1.96*z.se, fmt='o', color=col, ms=5, elinewidth=1.5, capsize=0, label=lab)
    ax.axhline(0, color=GRIS, lw=0.8); ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
    ax.set_xticks(range(-5, 10)); ax.set_xlabel('Years since opening (k)')
    ax.set_title(tit, loc='left', fontsize=10)
axs[0].set_ylabel('Effect on ln income (0.05 ≈ 5%)')
h, l = axs[0].get_legend_handles_labels(); fig.legend(h, l, loc='lower center', ncol=2, frameon=False)
fig.suptitle('ln income of mothers with income, by age of youngest child (unweighted, 95% CI, ref. k = −1)', x=0.01, ha='left')
fig.tight_layout(rect=(0, 0.07, 1, 1)); fig.savefig('graficos/lab_03b_het_ingreso_en.png', dpi=200)
