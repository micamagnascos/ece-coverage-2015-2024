# Laboral - paso 2: event study, 4 modelos, un gráfico por outcome (coefs_lab.csv)
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261006
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NAR, GRIS = '#2a78d6', '#eb6834', '#52514e'
d = pd.read_csv('coefs_lab.csv')
d = d[d.k.between(-5, 9)]

def evento(y, escala, ylab, titulo, archivo):
    x0 = d[d.outcome==y].copy()
    x0['b'] = x0.b * escala
    x0['se'] = x0.se * escala
    fig, axs = plt.subplots(1, 2, figsize=(12,4.4), sharey=True)
    paneles = [('twfe', 'sa', 'Sin ponderar (UV promedio)'), ('twfe_w', 'sa_w', 'Ponderado (madre promedio)')]
    for ax, (mt, ms, tit) in zip(axs, paneles):
        for m, col, dx, lab in [(mt, NAR, -0.15, 'TWFE'), (ms, AZUL, 0.15, 'Sun-Abraham')]:
            x = x0[x0.modelo==m].sort_values('k')
            ax.errorbar(x.k + dx, x.b, yerr=1.96*x.se, fmt='o', color=col, ms=5, elinewidth=1.5, capsize=0, label=lab)
        ax.axhline(0, color=GRIS, lw=0.8)
        ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
        ax.set_xticks(range(-5, 10)); ax.set_xlabel('Años desde la apertura (k)')
        ax.set_title(tit, loc='left', fontsize=10)
    axs[0].set_ylabel(ylab)
    h, l = axs[0].get_legend_handles_labels()
    fig.legend(h, l, loc='lower center', ncol=2, frameon=False)
    fig.suptitle(titulo, x=0.01, ha='left')
    fig.tight_layout(rect=(0, 0.07, 1, 1)); fig.savefig(archivo, dpi=200)

evento('empleo_formal', 100, 'Efecto en % con empleo formal (pp)',
       'Empleo formal de las madres: event study (IC 95%, ref. k = −1). Media control = 48,9%', 'graficos/lab_02a_eventstudy_empleo.png')
evento('ln_ingreso', 1, 'Efecto en ln ingreso (0,05 ≈ 5%)',
       'ln ingreso anual (madres con ingreso): event study (IC 95%, ref. k = −1)', 'graficos/lab_02b_eventstudy_ingreso.png')
evento('meses_trabajando', 1, 'Efecto en meses trabajando',
       'Meses trabajando (madres con ingreso): event study (IC 95%, ref. k = −1). Media control = 8,7 meses', 'graficos/lab_02c_eventstudy_meses.png')
