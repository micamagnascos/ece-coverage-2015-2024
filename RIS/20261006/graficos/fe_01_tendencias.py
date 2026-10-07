# Fertilidad - paso 1: tendencias crudas de tuvo_hijo por cohorte (tend_fert.csv)
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261006
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NAR, GRIS = '#2a78d6', '#eb6834', '#52514e'
d = pd.read_csv('tend_fert.csv')
d['tr'] = d.g1 > 0

# (a) tratadas vs nunca tratadas, tasa ponderada por mujeres (nacimientos / mujeres), en %
p = d.groupby(['anio','tr'])[['nac','n_mujeres']].sum()
p = (p.nac / p.n_mujeres).unstack() * 100
fig, ax = plt.subplots(figsize=(7,4))
ax.plot(p.index, p[False], color=NAR, lw=2, marker='o', ms=5, label='Nunca tratadas (3.973 UVs)')
ax.plot(p.index, p[True],  color=AZUL, lw=2, marker='o', ms=5, label='Tratadas, todas las cohortes (422 UVs)')
ax.set_xticks(range(2014,2025)); ax.set_ylabel('% de mujeres que tuvo un hijo en el año')
ax.set_title('Fertilidad por año: tratadas vs nunca tratadas', loc='left')
ax.legend(frameon=False, loc='upper right')
fig.tight_layout(); fig.savefig('graficos/fe_01a_tendencias_pool.png', dpi=200)

# (b, c) brecha cohorte - nunca tratadas, en pp
ctrl = d[d.g1==0].set_index('anio').eval('nac/n_mujeres')
def brechas(cohortes, titulo, archivo):
    fig, axs = plt.subplots(1, 5, figsize=(14,3.8), sharey=True)
    for ax, g in zip(axs, cohortes):
        c = d[d.g1==g].set_index('anio')
        gap = (c.nac/c.n_mujeres - ctrl) * 100
        ax.axhline(0, color=GRIS, lw=0.8)
        ax.axvline(g-0.5, color=GRIS, ls='--', lw=0.8)
        ax.plot(gap.index, gap.values, color=AZUL, lw=2, marker='o', ms=4)
        ax.set_title(f'Cohorte {g} ({int(c.n_uv.iloc[0])} UVs)', loc='left', fontsize=10)
        ax.set_xticks([2014,2016,2018,2020,2022,2024]); ax.tick_params(axis='x', labelsize=8)
    axs[0].set_ylabel('Brecha (pp)')
    fig.suptitle(titulo, x=0.01, ha='left', fontsize=10.5)
    fig.tight_layout(); fig.savefig(archivo, dpi=200)

brechas([2015,2016,2017,2018,2019], 'Brecha de fertilidad = (% mujeres que tuvo un hijo en las UVs de la cohorte) − (% en las UVs nunca tratadas), cada año, en pp.\n'
       'Brecha 0 = misma tasa que los controles. Efecto = cuánto cambia la brecha después de la apertura (línea punteada) respecto de antes.', 'graficos/fe_01b_brecha_cohortes.png')
brechas([2020,2021,2022,2023,2024], 'Brecha de fertilidad, cohortes 2020-2024 = (% mujeres con hijo en la cohorte) − (% en nunca tratadas), cada año, en pp.\n'
       'Brecha 0 = misma tasa que los controles. Efecto = cuánto cambia la brecha después de la apertura (línea punteada) respecto de antes.', 'graficos/fe_01c_brecha_cohortes_tardias.png')

# (d) niveles: fertilidad de cada cohorte sola + nunca tratadas como referencia
fig, axs = plt.subplots(1, 5, figsize=(14,4.0), sharey=True)
for ax, g in zip(axs, [2015,2016,2017,2018,2019]):
    c = d[d.g1==g].set_index('anio')
    ax.plot(ctrl.index, ctrl.values*100, color=NAR, lw=2, label='Nunca tratadas')
    ax.plot(c.index, c.nac/c.n_mujeres*100, color=AZUL, lw=2, marker='o', ms=4, label='Cohorte')
    ax.axvline(g-0.5, color=GRIS, ls='--', lw=0.8)
    ax.set_title(f'Cohorte {g} ({int(c.n_uv.iloc[0])} UVs)', loc='left', fontsize=10)
    ax.set_xticks([2014,2016,2018,2020,2022,2024]); ax.tick_params(axis='x', labelsize=8)
axs[0].set_ylabel('% mujeres que tuvo un hijo')
axs[0].legend(frameon=False, loc='lower left', fontsize=8.5)
fig.suptitle('Fertilidad de las UVs de cada cohorte (azul) vs UVs nunca tratadas (naranjo). Línea punteada = apertura del primer jardín.\n'
             'Ambas líneas caen por la tendencia común; el efecto es cuánto se separa la azul de la naranja después de la apertura, comparado con antes.',
             x=0.01, ha='left', fontsize=10.5)
fig.tight_layout(); fig.savefig('graficos/fe_01d_niveles_cohortes.png', dpi=200)
