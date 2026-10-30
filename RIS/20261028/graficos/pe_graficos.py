# Primera etapa v60 (extracción 28/10): event study, balanceado, descriptivo (tend) y exposición
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261028
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NARANJA, GRIS, GRISC = '#2a78d6', '#d9822b', '#52514e', '#a3a29e'

c = pd.read_csv('coefs_pe_v60.csv')

def es(ax, d, col, dx, lab):
    x = d[d.k <= 7].sort_values('k')  # k = 8 y 9 solo los aportan las cohortes 2015-2016: no se muestran
    ax.errorbar(x.k + dx, 100*x.b, yerr=196*x.se.fillna(0), fmt='o', color=col, ms=4.5, elinewidth=1.4, capsize=0, label=lab)

def ejes(ax):
    ax.axhline(0, color=GRIS, lw=0.8); ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
    ax.set_xticks(range(-5, 8)); ax.set_xlabel('Años desde la apertura (k)'); ax.set_ylabel('Efecto en tasa de matrícula (pp)')

# 1. principal
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, c[c.modelo=='sa_w'], AZUL, 0, 'Principal')
ejes(ax)
fig.suptitle('Primera etapa v60: SA ponderado por niños (IC 95%, ref. k = −1). Media control 34,0%', x=0.01, ha='left')
fig.tight_layout(); fig.savefig('graficos/pe_01_principal.png', dpi=200)

# 1b. comparación con la extracción del 06/10 (todas las madres, base original)
ant = pd.read_csv('../20261006/coefs_pe.csv')
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, ant[ant.modelo=='sa_w'], GRISC, -0.12, '06/10: todas las madres, base original')
es(ax, c[c.modelo=='sa_w'], AZUL, 0.12, '28/10: madres v60, año de apertura corregido')
ejes(ax)
h, l = ax.get_legend_handles_labels(); fig.legend(h, l, loc='lower center', ncol=2, frameon=False)
fig.suptitle('Primera etapa: extracción anterior vs actual (SA ponderado, IC 95%, ref. k = −1)', x=0.01, ha='left')
fig.tight_layout(rect=(0, 0.09, 1, 1)); fig.savefig('graficos/pe_00_comparacion.png', dpi=200)

# 2. principal vs balanceado
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, c[c.modelo=='sa_w'], AZUL, -0.12, 'Principal (4.415 UV)')
es(ax, c[(c.modelo=='sa_w_bal') & (c.se > 0)], NARANJA, 0.12, 'Balanceado (199 UV, N = 1.273)')
ejes(ax)
h, l = ax.get_legend_handles_labels(); fig.legend(h, l, loc='lower center', ncol=2, frameon=False)
fig.suptitle('Primera etapa v60: principal vs panel balanceado (k = −5 y 4 omitidos en el balanceado)', x=0.01, ha='left')
fig.tight_layout(rect=(0, 0.09, 1, 1)); fig.savefig('graficos/pe_02_balanceado.png', dpi=200)

# 3. descriptivo: tasa bruta por año calendario y brecha bruta tratadas - control por k
t = pd.read_csv('tend_pe_v60.csv')
t['tasa'] = t.matr / t.n_ninos
ctr = t[t.g1==0].set_index('anio').tasa
tr = t[t.g1>0].copy()
tr['k'] = tr.anio - tr.g1
tr['brecha'] = tr.tasa - tr.anio.map(ctr)
fig, (a1, a2) = plt.subplots(1, 2, figsize=(11, 4.4))
a1.plot(ctr.index, 100*ctr.values, color=GRIS, lw=2, label='Nunca tratadas')
g = tr.groupby('anio').apply(lambda d: d.matr.sum()/d.n_ninos.sum())
a1.plot(g.index, 100*g.values, color=AZUL, lw=2, label='Tratadas (todas las cohortes)')
a1.set_xlabel('Año'); a1.set_ylabel('Tasa de matrícula (%)'); a1.legend(frameon=False); a1.set_title('Tasa bruta por año', loc='left')
b = tr[tr.k.between(-5, 7)].groupby('k').apply(lambda d: (d.brecha*d.n_ninos).sum()/d.n_ninos.sum())
a2.plot(b.index, 100*b.values, 'o-', color=AZUL, ms=4.5)
a2.axhline(0, color=GRIS, lw=0.8); a2.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
a2.set_xticks(range(-5, 8)); a2.set_xlabel('Años desde la apertura (k)'); a2.set_ylabel('Tratadas − control (pp)')
a2.set_title('Brecha bruta tratadas − control mismo año (pond. niños)', loc='left')
fig.tight_layout(); fig.savefig('graficos/pe_03_descriptivo.png', dpi=200)
print(b.round(4))
print(t.groupby('anio').n_uv.sum())

# 4. exposición por edad del niño al abrir
e = pd.read_csv('coefs_expo_pe_v60.csv').sort_values('k')
fig, ax = plt.subplots(figsize=(6.5, 4.2))
ax.bar(['Nació el año de\napertura o después', 'Tenía 1–2', 'Tenía 3–4'], e.b, color=AZUL, width=0.55)
ax.errorbar(range(3), e.b, yerr=1.96*e.se, fmt='none', color=GRIS, elinewidth=1.4)
ax.axhline(0, color=GRIS, lw=0.8)
ax.set_ylabel('Años matriculado entre 0 y 4 (efecto)')
fig.suptitle('Exposición: años de matrícula adicionales según edad al abrir (IC 95%). Media control 1,36 años', x=0.01, ha='left', fontsize=9.5)
fig.tight_layout(); fig.savefig('graficos/pe_04_exposicion.png', dpi=200)
