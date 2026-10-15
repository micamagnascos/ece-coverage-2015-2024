# v60 nivel UV: event study SA, muestra completa (06/10) vs v60 vs v60 sin 2015, un gráfico por outcome
# Uso: python v60_01_eventstudy.py <outcome>   (empleo_formal, ln_ingreso, meses_trabajando, ingreso_rel)
import os, sys, numpy as np, pandas as pd, matplotlib.pyplot as plt

os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))  # corre desde RIS/20261014
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e6e5e1','grid.linewidth':0.6})
AZUL, NAR, GRIS, GRISC = '#2a78d6', '#eb6834', '#52514e', '#a3a29e'

v60 = pd.read_csv('coefs_lab_v60.csv')
full = pd.read_csv('../20261006/coefs_lab.csv')

# Pretest conjunto (k=-5..-2) y promedio post (k>=0) con la V de SA
def resumen(modelo, y, archivo_v, d):
    x = d[(d.modelo==modelo) & (d.outcome==y) & (d.k!=-1)].sort_values('k')
    if not os.path.exists(archivo_v):
        return None
    V = pd.read_csv(archivo_v).values
    b = x.b.values  # orden k=-5..-2, 0..K coincide con d1-d4, d6-...
    pre, post = slice(0, 4), slice(4, len(b))
    w = np.linalg.solve(V[pre, pre], b[pre]) @ b[pre]
    a = np.zeros(len(b)); a[post] = 1 / (len(b) - 4)
    return dict(modelo=modelo, p_pre=np.exp(-w / 2) * (1 + w / 2), prom_post=a @ b, se_post=np.sqrt(a @ V @ a),
                N=int(x.N.iloc[0]), n_uv=int(x.n_uv.iloc[0]), media_ctr=x.media_ctr.iloc[0])

def evento(y, escala, ylab, titulo, archivo, ref=None):
    # ref = (base, modelo, etiqueta) para la muestra completa; por defecto SA ponderado del 06/10
    ref = ref or (full, 'sa_w', 'Muestra completa (06/10)')
    # solo ponderado (madre promedio)
    fig, ax = plt.subplots(figsize=(8, 4.6))
    w = '_w'
    if True:
        series = [(ref[0], ref[1], GRISC, -0.2, ref[2]),
                  (v60, 'sa' + w + '_v60', AZUL, 0, 'v60'),
                  (v60, 'sa' + w + '_v60s15', NAR, 0.2, 'v60 sin cohorte 2015')]
        if ref[0] is None:  # sin referencia de muestra completa
            series = series[1:]
        for d, m, col, dx, lab in series:
            x = d[(d.modelo==m) & (d.outcome==y) & d.k.between(-5, 9)].sort_values('k')
            ax.errorbar(x.k + dx, x.b * escala, yerr=1.96 * x.se * escala, fmt='o', color=col, ms=4.5, elinewidth=1.4, capsize=0, label=lab)
        ax.axhline(0, color=GRIS, lw=0.8)
        ax.axvline(-0.5, color=GRIS, ls='--', lw=0.8)
        ax.set_xticks(range(-5, 10)); ax.set_xlabel('Años desde la apertura (k)')
    ax.set_ylabel(ylab)
    h, l = ax.get_legend_handles_labels()
    fig.legend(h, l, loc='lower center', ncol=3, frameon=False)
    fig.suptitle(titulo, x=0.01, ha='left')
    fig.tight_layout(rect=(0, 0.09, 1, 1)); fig.savefig(archivo, dpi=200)

    filas = [resumen('sa_w_v60', y, f'v_sa_w_v60_{y}.csv', v60),
             resumen('sa_w_v60s15', y, f'v_sa_w_v60s15_{y}.csv', v60)]
    t = pd.DataFrame([f for f in filas if f])
    t['prom_post'] *= escala; t['se_post'] *= escala; t['media_ctr'] *= escala
    t['efecto_rel_%'] = 100 * t.prom_post / t.media_ctr
    print(t.round(4).to_string(index=False))

y = sys.argv[1]
if y == 'empleo_formal':
    evento(y, 100, 'Efecto en % con empleo formal (pp)',
           'Empleo formal de las madres, Sun-Abraham ponderado (IC 95%, ref. k = −1)', 'graficos/v60_01a_empleo.png')
if y == 'ln_ingreso':
    evento(y, 1, 'Efecto en ln ingreso (0,05 ≈ 5%)',
           'ln ingreso anual (madres con ingreso), Sun-Abraham ponderado (IC 95%, ref. k = −1)', 'graficos/v60_01b_ln_ingreso.png')
if y == 'meses_trabajando':
    evento(y, 1, 'Efecto en meses trabajando',
           'Meses trabajando (madres con ingreso), Sun-Abraham ponderado (IC 95%, ref. k = −1)', 'graficos/v60_01c_meses.png')
if y == 'ingreso_rel':
    evento(y, 1, 'Efecto en ingreso (puntos, 100 = prom. año)',
           'Ingreso con ceros (relativo al promedio anual), Sun-Abraham ponderado (IC 95%, ref. k = −1)', 'graficos/v60_01d_ingreso_rel.png',
           ref=(None, None, None))  # SA de muestra completa del 07 mal estimado (error 1)
