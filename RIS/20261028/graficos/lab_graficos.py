# Resultados laborales v60, muestra fija (extracción 28/10) vs extracción 14/10 (v60 no fija). Hasta k = 7
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261028
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, GRIS, GRISC = '#2a78d6', '#52514e', '#a3a29e'

c = pd.read_csv('coefs_lab_v60fija.csv')
ant = pd.read_csv('../20261014/coefs_lab_v60.csv')

def es(ax, d, col, dx, lab, esc):
    x = d[d.k <= 7].sort_values('k')
    ax.errorbar(x.k + dx, esc*x.b, yerr=1.96*esc*x.se, fmt='o', color=col, ms=4.5, elinewidth=1.4, capsize=0, label=lab)

def figura(outcome, esc, ylab, titulo, archivo):
    fig, ax = plt.subplots(figsize=(8, 4.6))
    es(ax, ant[(ant.modelo=='sa_w_v60') & (ant.outcome==outcome)], GRISC, -0.12, '14/10: madres con hijo < 5 ese año, base original', esc)
    es(ax, c[(c.modelo=='sa_w') & (c.outcome==outcome)], AZUL, 0.12, '28/10: muestra fija de madres, base corregida', esc)
    ax.axhline(0, color=GRIS, lw=0.8); ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
    ax.set_xticks(range(-5, 8)); ax.set_xlabel('Años desde la apertura (k)'); ax.set_ylabel(ylab)
    h, l = ax.get_legend_handles_labels(); fig.legend(h, l, loc='lower center', ncol=2, frameon=False, fontsize=9)
    fig.suptitle(titulo, x=0.01, ha='left')
    fig.tight_layout(rect=(0, 0.09, 1, 1)); fig.savefig('graficos/' + archivo, dpi=200)

figura('empleo_formal', 100, 'Efecto en empleo formal (pp)', 'Empleo formal, madres v60: SA ponderado (IC 95%, ref. k = −1)', 'lab_01_empleo.png')
figura('ingreso_rel', 1, 'Efecto en ingreso relativo (puntos, media = 100)', 'Ingreso total con ceros, madres v60 (IC 95%, ref. k = −1)', 'lab_02_ingreso_rel.png')
figura('ln_ingreso', 100, 'Efecto en ingreso de las que trabajan (%)', 'Ln ingreso (solo madres con ingreso), v60 (IC 95%, ref. k = −1)', 'lab_03_ln_ingreso.png')

# ingreso en pesos de 2024 por mes, solo extracción actual
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, c[(c.modelo=='sa_w') & (c.outcome=='ingreso_mes24')], AZUL, 0, '', 1/1000)
ax.axhline(0, color=GRIS, lw=0.8); ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
ax.set_xticks(range(-5, 8)); ax.set_xlabel('Años desde la apertura (k)'); ax.set_ylabel('Miles de pesos de 2024 al mes')
fig.suptitle('Ingreso total con ceros en pesos de 2024 por mes (IC 95%). Media control $427 mil', x=0.01, ha='left')
fig.tight_layout(); fig.savefig('graficos/lab_04_ingreso_pesos.png', dpi=200)
