# Horas y variables RSH: un gráfico por outcome, TWFE vs Sun-Abraham, sin ponderar y ponderado (coefs_horas.csv)
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261006
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NAR, GRIS = '#2a78d6', '#eb6834', '#52514e'
d = pd.read_csv('coefs_horas.csv')
d = d[d.k.between(-5, 9)].copy()

def grafico(y, titulo, f, ylab, archivo):
    x = d[d.outcome==y].copy(); x['b'] = x.b*f; x['se'] = x.se*f
    fig, axs = plt.subplots(1, 2, figsize=(12,4.6), sharey=True)
    for ax, sfx, tit in [(axs[0], '', 'Sin ponderar (UV promedio)'), (axs[1], '_w', 'Ponderado (madre promedio)')]:
        for m, col, dx, lab in [(f'twfe{sfx}_rsh', NAR, -0.15, 'TWFE'), (f'sa{sfx}_rsh', AZUL, 0.15, 'Sun-Abraham')]:
            z = x[x.modelo==m].sort_values('k')
            ax.errorbar(z.k + dx, z.b, yerr=1.96*z.se, fmt='o', color=col, ms=5, elinewidth=1.5, capsize=0, label=lab)
        ax.axhline(0, color=GRIS, lw=0.8); ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
        ax.set_xticks(range(-5, 10)); ax.set_xlabel('Años desde la apertura (k)')
        ax.set_title(tit, loc='left', fontsize=10)
    axs[0].set_ylabel(ylab)
    h, l = axs[0].get_legend_handles_labels(); fig.legend(h, l, loc='lower center', ncol=2, frameon=False)
    m0 = x[x.modelo=='sa_rsh'].media_ctrl.iloc[0]*f
    fig.suptitle(f'{titulo} — media control {m0:.1f}{" h" if f==1 else "%"} (IC 95%, ref. k = −1)', x=0.01, ha='left')
    fig.tight_layout(rect=(0, 0.07, 1, 1)); fig.savefig(archivo, dpi=200)

grafico('horas', 'Horas semanales trabajadas (solo ocupadas)', 1, 'Efecto (horas)', 'graficos/rsh_01a_horas.png')
grafico('busca', 'Busca trabajo (% entre las que responden)', 100, 'Efecto (pp)', 'graficos/rsh_01b_busca.png')
grafico('cuida', 'No busca trabajo porque "no tiene con quién dejar a los niños" (% sobre todas las madres)', 100, 'Efecto (pp)', 'graficos/rsh_01c_cuida.png')
grafico('hogar', 'No busca trabajo por "quehaceres del hogar" (% sobre todas las madres)', 100, 'Efecto (pp)', 'graficos/rsh_01d_hogar.png')
grafico('cuida_hogar', 'No busca trabajo por cuidado u hogar (% sobre todas las madres)', 100, 'Efecto (pp)', 'graficos/rsh_01e_cuida_hogar.png')
