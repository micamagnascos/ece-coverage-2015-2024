# Primera etapa: SA ponderado, todas las cohortes (06/10) vs sin cohorte 2015 (14/10)
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261014
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, GRIS, GRISC = '#2a78d6', '#52514e', '#a3a29e'

full = pd.read_csv('../20261006/coefs_pe.csv')
s15 = pd.read_csv('coefs_pe_sin2015.csv')

fig, ax = plt.subplots(figsize=(8, 4.6))
for d, col, dx, lab in [(full, GRISC, -0.12, 'Todas las cohortes (06/10)'), (s15, AZUL, 0.12, 'Sin cohorte 2015')]:
    x = d[(d.modelo=='sa_w') & d.k.between(-5, 9)].sort_values('k')
    ax.errorbar(x.k + dx, 100*x.b, yerr=196*x.se, fmt='o', color=col, ms=4.5, elinewidth=1.4, capsize=0, label=lab)
    post = x[x.k >= 0]
    print(lab, 'promedio post k0-%d: %.2f pp' % (post.k.max(), 100*post.b.mean()), '| k0-7: %.2f pp' % (100*post[post.k <= 7].b.mean()))
ax.axhline(0, color=GRIS, lw=0.8)
ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
ax.set_xticks(range(-5, 10)); ax.set_xlabel('Años desde la apertura (k)')
ax.set_ylabel('Efecto en tasa de matrícula (pp)')
h, l = ax.get_legend_handles_labels()
fig.legend(h, l, loc='lower center', ncol=2, frameon=False)
fig.suptitle('Primera etapa: matrícula, Sun-Abraham ponderado por niños (IC 95%, ref. k = −1)', x=0.01, ha='left')
fig.tight_layout(rect=(0, 0.09, 1, 1)); fig.savefig('graficos/pe_01_sin2015.png', dpi=200)
