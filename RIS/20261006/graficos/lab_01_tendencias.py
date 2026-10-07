# Laboral - paso 1: tendencias crudas por cohorte (tend_lab.csv; promedios a nivel mujer por anio x g1)
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261006
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NAR, GRIS = '#2a78d6', '#eb6834', '#52514e'
d = pd.read_csv('tend_lab.csv')
d['tr'] = d.g1 > 0
d['empleo_formal'] = d.empleo_formal * 100   # en %
ctrl = d[d.g1==0].set_index('anio')

# (a) tratadas vs nunca tratadas, 3 outcomes (promedio ponderado por n° mujeres)
outs = [('empleo_formal', '% con empleo formal'), ('ln_ingreso', 'ln ingreso anual (con ingreso)'), ('meses_trabajando', 'Meses trabajando (con ingreso)')]
fig, axs = plt.subplots(1, 3, figsize=(14,3.8))
for ax, (v, lab) in zip(axs, outs):
    x = d.assign(z=d[v]*d.n_mujeres).groupby(['anio','tr'])[['z','n_mujeres']].sum()
    x = (x.z / x.n_mujeres).unstack()
    ax.plot(x.index, x[False], color=NAR, lw=2, marker='o', ms=4, label='Nunca tratadas')
    ax.plot(x.index, x[True], color=AZUL, lw=2, marker='o', ms=4, label='Tratadas (todas las cohortes)')
    ax.set_title(lab, loc='left', fontsize=10); ax.set_xticks([2014,2016,2018,2020,2022,2024])
axs[0].legend(frameon=False, fontsize=8.5)
fig.suptitle('Mercado laboral de las madres por año: UVs tratadas (azul) vs nunca tratadas (naranjo)', x=0.01, ha='left')
fig.tight_layout(); fig.savefig('graficos/lab_01a_tendencias_pool.png', dpi=200)

# (b) brechas por cohorte, un gráfico por outcome
def brechas(v, cohortes, unidad, titulo, archivo):
    fig, axs = plt.subplots(1, 5, figsize=(14,3.8), sharey=True)
    for ax, g in zip(axs, cohortes):
        c = d[d.g1==g].set_index('anio')
        gap = c[v] - ctrl[v]
        ax.axhline(0, color=GRIS, lw=0.8)
        ax.axvline(g-0.5, color=GRIS, ls='--', lw=0.8)
        ax.plot(gap.index, gap.values, color=AZUL, lw=2, marker='o', ms=4)
        ax.set_title(f'Cohorte {g} ({int(c.n_mujeres.iloc[0]):,} mujeres)'.replace(',', '.'), loc='left', fontsize=10)
        ax.set_xticks([2014,2016,2018,2020,2022,2024]); ax.tick_params(axis='x', labelsize=8)
    axs[0].set_ylabel(f'Brecha ({unidad})')
    fig.suptitle(titulo + '\nBrecha 0 = igual que los controles. Efecto = cuánto cambia la brecha después de la apertura (línea punteada) respecto de antes.',
                 x=0.01, ha='left', fontsize=10.5)
    fig.tight_layout(); fig.savefig(archivo, dpi=200)

brechas('empleo_formal', [2015,2016,2017,2018,2019], 'pp',
        'Brecha de empleo formal = (% madres con empleo formal en la cohorte) − (% en nunca tratadas), cada año, en pp.',
        'graficos/lab_01b_brecha_empleo.png')
brechas('empleo_formal', [2020,2021,2022,2023,2024], 'pp',
        'Brecha de empleo formal, cohortes 2020-2024 = (% con empleo formal en la cohorte) − (% en nunca tratadas), en pp.',
        'graficos/lab_01c_brecha_empleo_tardias.png')
brechas('ln_ingreso', [2015,2016,2017,2018,2019], 'log',
        'Brecha de ln ingreso = (ln ingreso promedio en la cohorte) − (en nunca tratadas), cada año. 0,05 ≈ 5% más ingreso.',
        'graficos/lab_01d_brecha_ingreso.png')
brechas('meses_trabajando', [2015,2016,2017,2018,2019], 'meses',
        'Brecha de meses trabajando = (meses promedio en la cohorte) − (en nunca tratadas), cada año.',
        'graficos/lab_01e_brecha_meses.png')
