# English version of pe_04_control_limpio.py (same content, labels translated for slides)
# Primera etapa - paso 5: control limpio, SA con 3 definiciones de control (coefs_ctrl.csv)
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261006
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NAR, AQUA, GRIS = '#2a78d6', '#eb6834', '#1baf7a', '#52514e'
d = pd.read_csv('coefs_ctrl.csv')
d = d[(d.outcome=='tasa_matricula') & d.k.between(-5, 9)]
d['b'] = d.b * 100
d['se'] = d.se * 100

specs = [('todas', AZUL, -0.2, 'All never-treated (4,146)'),
         ('abre', NAR, 0.0, 'No neighbor that opened a preschool (2,150)'),
         ('jardin', AQUA, 0.2, 'No neighboring preschool at all (652)')]
fig, axs = plt.subplots(1, 2, figsize=(12,4.2), sharey=True)
for ax, (pref, tit) in zip(axs, [('sa', 'Sun-Abraham, unweighted'), ('sa_w', 'Sun-Abraham, weighted by no. of children')]):
    for s, col, dx, lab in specs:
        x = d[d.modelo==f'{pref}_{s}'].sort_values('k')
        ax.errorbar(x.k + dx, x.b, yerr=1.96*x.se, fmt='o', color=col, ms=4.5, elinewidth=1.3, capsize=0, label=lab)
    ax.axhline(0, color=GRIS, lw=0.8)
    ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
    ax.set_xticks(range(-5, 10)); ax.set_xlabel('Years since opening (k)')
    ax.set_title(tit, loc='left', fontsize=10)
axs[0].set_ylabel('Effect on enrollment rate (pp)')
h, l = axs[0].get_legend_handles_labels()
fig.legend(h, l, loc='lower center', ncol=3, frameon=False, fontsize=9, title='Control group (no. of control UVs)', title_fontsize=9)
fig.suptitle('First stage with different control groups (95% CI, ref. k = −1)', x=0.01, ha='left')
fig.tight_layout(rect=(0, 0.12, 1, 1)); fig.savefig('graficos/pe_04_control_limpio_en.png', dpi=200)
