# English version of pe_01_tendencias.py, panel (b) only (same content, labels translated for slides)
# Primera etapa - paso 1: tendencias crudas de matrícula por cohorte (tend_pe.csv)
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261006
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NAR, GRIS = '#2a78d6', '#eb6834', '#52514e'
d = pd.read_csv('tend_pe.csv')
d['tr'] = d.g1 > 0

# (b) brecha cohorte - nunca tratadas, cohortes grandes (2015-2019 = 378 de 422 UVs)
ctrl = d[d.g1==0].set_index('anio').eval('matr/n_ninos')
def brechas(cohortes, titulo, archivo):
    fig, axs = plt.subplots(1, 5, figsize=(14,3.8), sharey=True)
    for ax, g in zip(axs, cohortes):
        c = d[d.g1==g].set_index('anio')
        gap = (c.matr/c.n_ninos - ctrl) * 100
        ax.axhline(0, color=GRIS, lw=0.8)
        ax.axvline(g-0.5, color=GRIS, ls='--', lw=0.8)
        ax.plot(gap.index, gap.values, color=AZUL, lw=2, marker='o', ms=4)
        ax.set_title(f'Cohort {g} ({int(c.n_uv.iloc[0])} UVs)', loc='left', fontsize=10)
        ax.set_xticks([2014,2016,2018,2020,2022,2024]); ax.tick_params(axis='x', labelsize=8)
    axs[0].set_ylabel('Gap (pp)')
    fig.suptitle(titulo, x=0.01, ha='left', fontsize=10.5)
    fig.tight_layout(); fig.savefig(archivo, dpi=200)

brechas([2015,2016,2017,2018,2019], 'Enrollment gap = (% of children 0-4 enrolled in the cohort UVs) − (% in never-treated UVs), each year, in pp.\n'
       'Gap 0 = same rate as controls. Effect = how much the gap changes after the opening (dashed line) relative to before.', 'graficos/pe_01b_brecha_cohortes_en.png')
