# Primera etapa - paso 1: tendencias crudas de matrícula por cohorte (tend_pe.csv)
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261006
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NAR, GRIS = '#2a78d6', '#eb6834', '#52514e'
d = pd.read_csv('tend_pe.csv')
d['tr'] = d.g1 > 0

# (a) tratadas (todas las cohortes) vs nunca tratadas, tasa ponderada por niños
p = d.groupby(['anio','tr'])[['matr','n_ninos']].sum()
p = (p.matr / p.n_ninos).unstack()
fig, ax = plt.subplots(figsize=(7,4))
ax.plot(p.index, p[False], color=NAR, lw=2, marker='o', ms=5, label='Nunca tratadas (3.909 UVs)')
ax.plot(p.index, p[True],  color=AZUL, lw=2, marker='o', ms=5, label='Tratadas, todas las cohortes (422 UVs)')
ax.set_xticks(range(2014,2025)); ax.set_ylabel('Tasa de matrícula (niños 0-4)')
ax.set_title('Matrícula por año: tratadas vs nunca tratadas', loc='left')
ax.legend(frameon=False, loc='lower right')
fig.tight_layout(); fig.savefig('graficos/pe_01a_tendencias_pool.png', dpi=200)

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
        ax.set_title(f'Cohorte {g} ({int(c.n_uv.iloc[0])} UVs)', loc='left', fontsize=10)
        ax.set_xticks([2014,2016,2018,2020,2022,2024]); ax.tick_params(axis='x', labelsize=8)
    axs[0].set_ylabel('Brecha (pp)')
    fig.suptitle(titulo, x=0.01, ha='left', fontsize=10.5)
    fig.tight_layout(); fig.savefig(archivo, dpi=200)

brechas([2015,2016,2017,2018,2019], 'Brecha de matrícula = (% niños 0-4 matriculados en las UVs de la cohorte) − (% en las UVs nunca tratadas), cada año, en pp.\n'
       'Brecha 0 = misma tasa que los controles. Efecto = cuánto cambia la brecha después de la apertura (línea punteada) respecto de antes.', 'graficos/pe_01b_brecha_cohortes.png')
# (c) cohortes chicas 2020-2024 (44 UVs en total): ruido, pero se muestran
brechas([2020,2021,2022,2023,2024], 'Brecha de matrícula, cohortes 2020-2024 = (% matriculados en la cohorte) − (% en nunca tratadas), cada año, en pp.\n'
       'Brecha 0 = misma tasa que los controles. Efecto = cuánto cambia la brecha después de la apertura (línea punteada) respecto de antes.', 'graficos/pe_01c_brecha_cohortes_tardias.png')

# (d) niveles: matrícula de cada cohorte sola + nunca tratadas como referencia
fig, axs = plt.subplots(1, 5, figsize=(14,4.0), sharey=True)
for ax, g in zip(axs, [2015,2016,2017,2018,2019]):
    c = d[d.g1==g].set_index('anio')
    ax.plot(ctrl.index, ctrl.values*100, color=NAR, lw=2, label='Nunca tratadas')
    ax.plot(c.index, c.matr/c.n_ninos*100, color=AZUL, lw=2, marker='o', ms=4, label='UVs de la cohorte')
    ax.axvline(g-0.5, color=GRIS, ls='--', lw=0.8)
    ax.set_title(f'Cohorte {g} ({int(c.n_uv.iloc[0])} UVs)', loc='left', fontsize=10)
    ax.set_xticks([2014,2016,2018,2020,2022,2024]); ax.tick_params(axis='x', labelsize=8)
axs[0].set_ylabel('% niños 0-4 matriculados')
axs[0].legend(frameon=False, loc='upper left', fontsize=8.5)
fig.suptitle('Tasa de matrícula de las UVs de cada cohorte (azul) vs UVs nunca tratadas (naranjo). Línea punteada = apertura del primer jardín.\n'
             'Ambas líneas siguen la tendencia común; el efecto es cuánto se separa la azul de la naranja después de la apertura, comparado con antes.',
             x=0.01, ha='left', fontsize=10.5)
fig.tight_layout(); fig.savefig('graficos/pe_01d_niveles_cohortes.png', dpi=200)
