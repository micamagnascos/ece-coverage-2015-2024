# Empleo formal (extracción 04/11): principal, tres versiones y niveles
import os, pandas as pd, matplotlib.pyplot as plt
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261104
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NARANJA, GRIS, GRISC = '#2a78d6', '#d9822b', '#52514e', '#a3a29e'

c = pd.read_csv('coefs_lab_entrada.csv'); c = c[c.outcome=='empleo_formal']
f = pd.read_csv('coefs_indm_empleo_entr.csv'); f = f[f.outcome=='empleo_formal']

def es(ax, d, col, dx, lab, fmt='o'):
    x = d[d.k <= 7].sort_values('k')  # k = 8 y 9 solo los aportan las cohortes 2015-2016: no se muestran
    ax.errorbar(x.k + dx, 100*x.b, yerr=196*x.se.fillna(0), fmt=fmt, color=col, ms=5, elinewidth=1.6, capsize=0, label=lab)

def ejes(ax):
    ax.axhline(0, color=GRIS, lw=0.8); ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
    ax.set_xticks(range(-5, 8)); ax.set_xlabel('Años desde la apertura (k)'); ax.set_ylabel('Efecto en empleo formal (pp)')

# 1. principal
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, c[c.modelo=='sa_w'], AZUL, 0, 'Principal')
ejes(ax)
fig.suptitle('Empleo formal de las madres: SA ponderado (IC 95%, ref. k = −1). Media control 54,6%', x=0.01, ha='left')
fig.tight_layout(); fig.savefig('graficos/lab_01_empleo.png', dpi=200)

# 2. tres versiones
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, c[c.modelo=='sa_w'], AZUL, -0.15, 'Principal (UV donde vive)')
es(ax, c[c.modelo=='sa_w_bal'], GRISC, 0, 'Balanceada (11 años)', 's')
es(ax, f[f.modelo=='sa_indm_entr'], NARANJA, 0.15, 'EF de mujer (UV fija), EE provisorios', '^')
ejes(ax)
h, l = ax.get_legend_handles_labels(); fig.legend(h, l, loc='lower center', ncol=3, frameon=False)
fig.suptitle('Empleo formal: tres versiones (IC 95%, ref. k = −1)', x=0.01, ha='left')
fig.tight_layout(rect=(0, 0.09, 1, 1)); fig.savefig('graficos/lab_02_empleo_versiones.png', dpi=200)

# 3. niveles
t = pd.read_csv('tend_lab_entrada.csv'); t['tasa'] = t.emp / t.n_mujeres
ctr = t[t.g1==0].set_index('anio').tasa
tr = t[t.g1>0].copy(); tr['k'] = tr.anio - tr.g1; tr['brecha'] = tr.tasa - tr.anio.map(ctr)
fig, (a1, a2) = plt.subplots(1, 2, figsize=(11, 4.4))
a1.plot(ctr.index, 100*ctr.values, color=GRIS, lw=2, label='Nunca tratadas')
g = tr.groupby('anio')[['emp','n_mujeres']].sum()
a1.plot(g.index, 100*g.emp/g.n_mujeres, color=AZUL, lw=2, label='Tratadas (todas las cohortes)')
a1.set_xlabel('Año'); a1.set_ylabel('Empleo formal (%)'); a1.legend(frameon=False); a1.set_title('Tasa bruta por año', loc='left')
x = tr[tr.k.between(-5, 7)]
b = (x.brecha*x.n_mujeres).groupby(x.k).sum() / x.groupby('k').n_mujeres.sum()
a2.plot(b.index, 100*b.values, 'o-', color=AZUL, ms=5, lw=2)
a2.axhline(0, color=GRIS, lw=0.8); a2.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
a2.set_xticks(range(-5, 8)); a2.set_xlabel('Años desde la apertura (k)'); a2.set_ylabel('Tratadas − control (pp)')
a2.set_title('Brecha bruta tratadas − control, mismo año (pond. madres)', loc='left')
fig.tight_layout(); fig.savefig('graficos/lab_03_empleo_niveles.png', dpi=200)
print('brecha cruda',(100*b).round(2).to_dict())
print('anio tasa', pd.DataFrame({'c':100*ctr,'t':100*g.emp/g.n_mujeres}).round(1).T.to_string())
for lab,q in [('pre',tr.k<0),('k-1',tr.k==-1),('post0-7',tr.k.between(0,7))]:
    d=tr[q]; rt=d.emp.sum()/d.n_mujeres.sum(); rc=(d.anio.map(ctr)*d.n_mujeres).sum()/d.n_mujeres.sum()
    print(lab,round(100*rt,1),round(100*rc,1),round(100*(rt-rc),2),'madres/UV',round(d.n_mujeres.sum()/d.n_uv.sum(),1))

# 4. empleo, solo EF de mujer
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, f[(f.modelo=='sa_indm_entr') & (f.outcome=='empleo_formal')], NARANJA, 0, 'EF de mujer', '^')
ejes(ax)
fig.suptitle('Empleo formal, mismas mujeres con UV fija: EF de mujer (IC 95%, ref. k = −1, EE provisorios)', x=0.01, ha='left', fontsize=10.5)
fig.tight_layout(); fig.savefig('graficos/lab_10_empleo_ef_mujer.png', dpi=200)

# 5. empleo, solo EF de mujer balanceada
fig, ax = plt.subplots(figsize=(8, 4.6))
es(ax, f[(f.modelo=='sa_indm_entr_bal') & (f.outcome=='empleo_formal')], NARANJA, 0, 'EF de mujer balanceada', '^')
ejes(ax)
fig.suptitle('Empleo formal, mujeres de los 11 años con UV fija: EF de mujer (IC 95%, ref. k = −1, EE provisorios)', x=0.01, ha='left', fontsize=10.5)
fig.tight_layout(); fig.savefig('graficos/lab_11_empleo_ef_mujer_bal.png', dpi=200)
