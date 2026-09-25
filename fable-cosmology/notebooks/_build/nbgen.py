#!/usr/bin/env python3
"""Generate the four fable-cosmology notebooks (nbformat 4) from cell manifests.

    python notebooks/_build/nbgen.py            # writes notebooks/0[1-4]_*.ipynb (unexecuted)

The generator is the source of truth: never hand-edit a .ipynb.  After generation the
notebooks are executed in place with nbconvert (see run_all.sh / run_all.ps1) and checked by
nbcheck.py.  Every requirement of CONVENTIONS.md is encoded here: the section headings, the
metadata, the code conventions, the result-file naming, and the two `interactive` cells at the
end that are skipped by the headless runner.
"""
import sys
from pathlib import Path

import nbformat
from nbformat.v4 import new_code_cell, new_markdown_cell, new_notebook

HERE = Path(__file__).resolve().parent
NOTEBOOKS = HERE.parent

# ----------------------------------------------------------------------------------------------
# cell helpers
# ----------------------------------------------------------------------------------------------

def md(text):
    return new_markdown_cell(text.strip("\n"))


def code(text, tags=None):
    c = new_code_cell(text.strip("\n"))
    if tags:
        c.metadata["tags"] = list(tags)
    return c


def build(path, model, cells):
    """Assemble, validate the CONVENTIONS rules that can be checked before execution, write."""
    for i, c in enumerate(cells):
        if c.cell_type == "code":
            assert i > 0 and cells[i - 1].cell_type == "markdown", f"{path.name}: code cell {i} has no markdown before it"
            assert len(cells[i - 1].source.strip()) >= 80, f"{path.name}: explanation before code cell {i} is too thin"
    nb = new_notebook(cells=cells)
    nb.metadata["kernelspec"] = {"display_name": "Python 3 (ipykernel)", "language": "python", "name": "python3"}
    nb.metadata["language_info"] = {"name": "python"}
    nb.metadata["fable_cosmo"] = {"model": model}
    nbformat.validate(nb)
    nbformat.write(nb, str(path))
    n_code = sum(1 for c in cells if c.cell_type == "code")
    print(f"wrote {path.name}: {len(cells)} cells, {n_code} code cells")


# ----------------------------------------------------------------------------------------------
# text shared by every notebook
# ----------------------------------------------------------------------------------------------

SECTION_1 = r"""
## 1. How to open a notebook like this one, from a terminal

**What you need.** A Rust toolchain (`cargo`, from https://rustup.rs), Python 3 (3.10 or newer),
`git`, and an internet connection for the one-time setup, which makes a sparse clone of the
platform rustSolveIt engine (the vendored pure-Rust SUNDIALS 7.8.0 that the solver is built on:
`rustSolveIt_Win11_SUNDIALS_7_8_0` on Windows 11, `rustSolveIt_macos-silicon_SUNDIALS_7_8_0` on
Apple-silicon macOS, `rustSolveIt_linux_SUNDIALS_7_8_0` on Linux).  Nothing else is downloaded.

**The three commands.**  From the directory that contains `fable-cosmology/`:

1. Run the setup once.  It creates the virtual environment `.venv`, installs numpy, scipy,
   matplotlib and jupyter into it, clones the engine sparsely into `rust/vendor/rustSolveIt`,
   builds the solver with `cargo build --release` and smoke-tests it:

       bash fable-cosmology/setup.sh
       powershell -ExecutionPolicy Bypass -File fable-cosmology\setup.ps1      (Windows PowerShell)

2. Change into the project:

       cd fable-cosmology

3. Start JupyterLab on the notebooks folder:

       .venv/bin/jupyter lab notebooks/
       .venv\Scripts\jupyter.exe lab notebooks\        (Windows)

A browser tab opens.  Click this notebook in the file list on the left.  When Jupyter asks for a
kernel, pick **`Python 3 (ipykernel)`** -- it is the kernel of the `.venv` you just made, so
numpy, scipy and matplotlib are all there.  Run a cell with **`Shift+Enter`**: the cursor moves
to the next cell, and the outputs (text, tables, figures) appear under the cell.  Run the cells
in order from the top; `Run > Run All Cells` does that in one go.  Every cell finishes in well
under a minute on a laptop.

If a cell says the solver binary is missing, the setup was not run (or not finished): run step 1
again and watch for its last line, `== setup complete`.  To rebuild the solver alone, run
`cargo build --release` inside `rust/fable_cosmo`.
"""

SECTION_2 = r"""
## 2. The words used in this notebook

- **field** -- a quantity defined at every point of space-time.  `fableScalar` is one real number
  per point (a scalar field, written phi); `fable` is sixteen real numbers per point that rotate
  into each other under the symmetry group Spin(4,4) of the 8-dimensional pre-universe (a real
  16-component spinor field, written Psi).
- **Lagrangian** -- the function L of a field and its derivatives whose integral (the action) is
  stationary on the physical solutions.  The field equations follow from it by the
  Euler-Lagrange rule.  In curved space-time L carries the volume factor Sqrt[det g].
- **energy-momentum tensor** T_{mu nu} -- the response of the action to a change of the metric;
  its components measured by an observer are the energy density and the pressures.
- **energy density rho** -- energy per unit volume seen by the observer moving along the time
  coordinate (here rho = T_{44}, the time being x4 on the pre-universe and t in the reference
  models).
- **pressure P** -- the spatial diagonal components of T (P_i = T^i_i, i = 1, 2, 3); the fields
  are homogeneous, so P_1 = P_2 = P_3 = P.
- **equation of state w = P / rho** -- the single number that fixes how the energy density of a
  component dilutes as the universe expands: rho is proportional to a^{-3(1+w)}.
- **scale factor a** -- the size of the observed 3-space relative to today (a = 1 today).
- **redshift z = 1/a - 1** -- what an astronomer measures; z = 0 today, z = 1 when a = 1/2.
- **N = ln a** -- the number of e-folds of expansion; the independent variable of the solver.
  N = -7 is a = 9.1e-4 (z = 1096, just after radiation-matter equality, which with the
  parameters used here is at a_eq = Omega_r0/Omega_m0 = 2.8e-4), N = 0 is today.
- **Hubble rate H = (da/dt)/a** -- the expansion rate; in this notebook it is measured in units
  of its value today, so H(a = 1) = 1.
- **Omega_i** -- the fraction of the critical density 3 H^2 carried by component i (matter m,
  radiation r, or the field).  Today Omega_m = 0.3, Omega_r = 8.4e-5 and the field carries the
  rest, 0.699916.
- **CPL (w0, wa)** -- the Chevallier-Polarski-Linder straight line w(a) = w0 + wa (1 - a): w0 is
  w today, w0 + wa is the value the line extrapolates to at a = 0.  The Supernovae *Unite*
  fits are (w0, wa) = (-0.861, -0.60) and, forcing a constant w, w = -0.764.
- **thawing / freezing** -- a field whose w rises with time (dw/dN > 0) is *thawing* (it starts
  frozen at w = -1 and wakes up); one whose w falls towards -1 is *freezing*.  We read the
  class off the sign of dw/dN over the fit range, not off the potential's name.
- **phantom** -- w < -1.  A canonical scalar field cannot get there (its rho + P = 2 KE >= 0);
  crossing w = -1 is called crossing the phantom divide.
- **dust** -- pressureless matter, w = 0, rho proportional to a^{-3}: what cold dark matter is.
- **cosmological constant** -- a constant energy density, w = -1 exactly.
- **kination** -- a scalar field whose energy is all kinetic: w = +1, rho proportional to a^{-6}.
- **SUNDIALS / CVODE / BDF / Adams** -- SUNDIALS is the Lawrence Livermore suite of solvers for
  differential equations; CVODE is its solver for first-order systems y' = f(x, y); BDF (backward
  differentiation formulas, implicit, for stiff systems) and Adams (explicit-predictor
  multistep, for smooth non-stiff oscillations) are its two families of methods.  The solver
  here uses the pure-Rust port of SUNDIALS 7.8.0 of the rustSolveIt repositories.
- **tolerance** -- CVODE keeps the local error of every step below rtol * |y| + atol; the runs
  use rtol = 1e-10, atol = 1e-12.  The cross-checks re-integrate with scipy at rtol = 1e-11.
"""

# The setup cell is the same for every notebook except the notebook-number prefix and the models.
SETUP_CODE = r'''
import os, sys, re, csv, io, subprocess
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from scipy.optimize import brentq

ROOT = Path.cwd() if (Path.cwd() / 'rust').exists() else Path.cwd().parent
BIN = ROOT / 'rust' / 'fable_cosmo' / 'target' / 'release' / ('fable_cosmo.exe' if os.name == 'nt' else 'fable_cosmo')
RESULTS = ROOT / 'results'
REFERENCE = ROOT / 'reference'
RESULTS.mkdir(exist_ok=True)
if not BIN.exists():
    print(f'The solver binary {BIN} does not exist: run  bash fable-cosmology/setup.sh  '
          f'(or  powershell -ExecutionPolicy Bypass -File fable-cosmology\\setup.ps1 ) first, then restart this notebook.')
    raise SystemExit(1)
print(subprocess.run([str(BIN), '--version'], check=True, capture_output=True, text=True).stdout.strip())
print('results directory:', RESULTS)

OM, OR = 0.3, 8.4e-5                       # Omega_m0, Omega_r0: the solver's defaults
OMEGA_FIELD_TODAY = 1.0 - OM - OR          # 0.699916, what the field must carry today
UNITE_W0, UNITE_WA, UNITE_WCONST = -0.861, -0.60, -0.764
RUNS = {}                                  # every solver run of this notebook, by result-file name


def parse_stderr(text):
    """The potential (name and parameters after normalisation) that the solver printed on stderr."""
    m = re.search(r'# potential=(\S+) \w+ \{ ([^}]*)\}', text)
    if not m:
        return None, {}
    params = {k: float(v) for k, v in re.findall(r'(\w+): ([-+0-9.eE]+)', m.group(2))}
    return m.group(1), params


def run_solver(name, model, *args, label=None, expect_failure=False, keep=True, quiet=False):
    """Run fable_cosmo; write results/<name>.csv (unless keep=False); print its stderr; return the table.

    With expect_failure=True the non-zero exit is caught and the solver's one-line reason is printed;
    the CompletedProcess is returned instead of a table.  quiet=True prints only the '# stats:' line."""
    args = [str(x) for x in args]
    out = RESULTS / f'{name}.csv'
    cmd = [str(BIN), model, *args] + (['--out', str(out)] if keep else [])
    shown = ' '.join(['fable_cosmo', model, *args] + (['--out', f'results/{name}.csv'] if keep else []))
    print('$', shown.replace(str(RESULTS) + os.sep, 'results/').replace(str(RESULTS), 'results'))
    if expect_failure:
        r = subprocess.run(cmd, capture_output=True, text=True)
        reason = r.stderr.strip().splitlines()[-1] if r.stderr.strip() else '(no message)'
        print(f'  exit code {r.returncode}: {reason}')
        return r
    r = subprocess.run(cmd, check=True, capture_output=True, text=True)
    for line in r.stderr.strip().splitlines():
        if not quiet or line.startswith('# stats'):
            print(' ', line)
    table = np.genfromtxt(out, delimiter=',', names=True) if keep else np.genfromtxt(io.StringIO(r.stdout), delimiter=',', names=True)
    pot, params = parse_stderr(r.stderr)
    RUNS[name] = dict(label=label or name, model=model, args=args, table=table, pot=pot, params=params, stderr=r.stderr)
    return table


def scalar_potential(name, p):
    """V(phi) and V'(phi) exactly as potentials.rs defines them, with the solver's (normalised) parameters."""
    if name == 'exp':
        return (lambda x: p['v0'] * np.exp(-p['lambda'] * x), lambda x: -p['lambda'] * p['v0'] * np.exp(-p['lambda'] * x))
    if name == 'invpower':
        return (lambda x: p['v0'] * x ** (-p['alpha']), lambda x: -p['alpha'] * p['v0'] * x ** (-p['alpha'] - 1.0))
    if name == 'pngb':
        return (lambda x: p['v0'] * (1.0 + np.cos(x / p['f'])), lambda x: -p['v0'] / p['f'] * np.sin(x / p['f']))
    if name == 'quadratic':
        return (lambda x: 0.5 * p['m'] ** 2 * x * x, lambda x: p['m'] ** 2 * x)
    if name == 'hilltop':
        return (lambda x: p['v0'] * (1.0 - x * x / p['mu'] ** 2), lambda x: -2.0 * p['v0'] * x / p['mu'] ** 2)
    if name == 'const':
        return (lambda x: p['v0'] + 0.0 * x, lambda x: 0.0 * x)
    if name == 'quartic':
        return (lambda x: 0.25 * p['lambda'] * x ** 4, lambda x: p['lambda'] * x ** 3)
    raise ValueError(name)


def spinor_potential(name, p):
    """V(s) and V'(s) exactly as potentials.rs defines them, with the solver's (normalised) parameters."""
    if name == 'mass':
        return (lambda s: p['m'] * s, lambda s: p['m'] + 0.0 * s)
    if name == 'lambda-mass':
        return (lambda s: p['v0'] + p['m'] * s, lambda s: p['m'] + 0.0 * s)
    if name == 'power':
        return (lambda s: p['m'] * s + p['lambda'] * s ** p['n'], lambda s: p['m'] + p['n'] * p['lambda'] * s ** (p['n'] - 1.0))
    if name == 'hilltop':
        return (lambda s: p['v0'] - p['mu'] * (s - p['sstar']) ** 2, lambda s: -2.0 * p['mu'] * (s - p['sstar']))
    if name == 'lorentz':
        return (lambda s: p['v0'] + p['m'] * s / (1.0 + (s / p['s1']) ** 2),
                lambda s: p['m'] * (1.0 - (s / p['s1']) ** 2) / (1.0 + (s / p['s1']) ** 2) ** 2)
    if name == 'expdamp':
        return (lambda s: p['v0'] + p['m'] * s * np.exp(-s / p['s1']), lambda s: p['m'] * (1.0 - s / p['s1']) * np.exp(-s / p['s1']))
    raise ValueError(name)


def cpl_h2(a, w0=UNITE_W0, wa=UNITE_WA):
    """H^2 of the CPL background (H0 = 1): the closed form of rho_DE(a)/rho_DE(1) of models.rs."""
    return OM * a ** -3 + OR * a ** -4 + OMEGA_FIELD_TODAY * a ** (-3.0 * (1.0 + w0 + wa)) * np.exp(-3.0 * wa * (1.0 - a))


def cpl_fit(a, w, amin=0.3, amax=1.0):
    """Unweighted least squares of w(a) to w0 + wa (1 - a) over amin <= a <= amax (numpy.polyfit on 1 - a)."""
    m = (a >= amin) & (a <= amax)
    wa, w0 = np.polyfit(1.0 - a[m], w[m], 1)
    return float(w0), float(wa)


def w_at(a, w, a0):
    """w interpolated at a0 (NaN if a0 lies outside the run)."""
    if a0 < a[0] or a0 > a[-1]:
        return float('nan')
    return float(np.interp(a0, a, w))


def thaw_class(N, w, a, tol=1e-6):
    """'thawing' if dw/dN > 0 over the whole fit range 0.3 <= a <= 1, 'freezing' if < 0, 'constant' if |dw/dN| < tol, else 'mixed'."""
    m = (a >= 0.3) & (a <= 1.0)
    d = np.gradient(w, N)[m]
    if np.max(np.abs(d)) < tol:
        return 'constant'
    if np.min(d) > -tol:
        return 'thawing'
    if np.max(d) < tol:
        return 'freezing'
    return 'mixed'


def crossings(N, w):
    """Every scale factor at which w + 1 changes sign, by a local degree-6 polynomial through the 8 grid
    points around the sign change and a root bracket (brentq); [] if w never crosses -1."""
    f = w + 1.0
    out = []
    for i in np.where(np.sign(f[:-1]) * np.sign(f[1:]) < 0)[0]:
        lo, hi = max(0, i - 3), min(len(N), i + 5)
        c = np.polyfit(N[lo:hi] - N[i], f[lo:hi], min(6, hi - lo - 1))
        out.append(float(np.exp(N[i] + brentq(lambda x: np.polyval(c, x), 0.0, N[i + 1] - N[i]))))
    return out


FIT_COLUMNS = ['run', 'model', 'w0_fit', 'wa_fit', 'w0_plus_wa', 'w_a03', 'w_a1', 'w_min', 'class', 'omega_today', 'dist_to_unite']


def fit_row(name, wcol):
    """One row of the CPL table for a run in RUNS."""
    r = RUNS[name]
    d = r['table']
    a, w, N = d['a'], d[wcol], d['N']
    w0, wa = cpl_fit(a, w)
    om_col = next(c for c in ('Omega_phi', 'Omega_Psi', 'Omega_phi_test') if c in d.dtype.names)
    return {'run': r['label'], 'model': r['model'], 'w0_fit': w0, 'wa_fit': wa, 'w0_plus_wa': w0 + wa,
            'w_a03': w_at(a, w, 0.3), 'w_a1': float(w[-1]), 'w_min': float(w.min()), 'class': thaw_class(N, w, a),
            'omega_today': float(d[om_col][-1]), 'dist_to_unite': float(np.hypot(w0 - UNITE_W0, wa - UNITE_WA))}


UNITE_ROWS = [
    {'run': 'Unite CPL (w0, wa)', 'model': 'reference', 'w0_fit': UNITE_W0, 'wa_fit': UNITE_WA, 'w0_plus_wa': UNITE_W0 + UNITE_WA,
     'w_a03': UNITE_W0 + UNITE_WA * 0.7, 'w_a1': UNITE_W0, 'w_min': float('nan'), 'class': 'CPL line', 'omega_today': OMEGA_FIELD_TODAY, 'dist_to_unite': 0.0},
    {'run': 'Unite constant w', 'model': 'reference', 'w0_fit': UNITE_WCONST, 'wa_fit': 0.0, 'w0_plus_wa': UNITE_WCONST,
     'w_a03': UNITE_WCONST, 'w_a1': UNITE_WCONST, 'w_min': UNITE_WCONST, 'class': 'constant', 'omega_today': OMEGA_FIELD_TODAY,
     'dist_to_unite': float(np.hypot(UNITE_WCONST - UNITE_W0, 0.0 - UNITE_WA))},
]


def fit_table(rows, path):
    """Print the CPL table next to Unite's numbers and write it (with the two Unite reference rows) to `path`."""
    hdr = f"{'run':44s} {'w0_fit':>8s} {'wa_fit':>8s} {'w0+wa':>8s} {'w(0.3)':>8s} {'w(1)':>8s} {'min w':>8s}  {'class':9s} {'Omega(1)':>8s} {'dist':>6s}"
    print(hdr)
    print('-' * len(hdr))
    for r in rows + UNITE_ROWS:
        print(f"{r['run']:44s} {r['w0_fit']:8.4f} {r['wa_fit']:8.4f} {r['w0_plus_wa']:8.4f} {r['w_a03']:8.4f} {r['w_a1']:8.4f} {r['w_min']:8.4f}  {r['class']:9s} {r['omega_today']:8.4f} {r['dist_to_unite']:6.3f}")
    with open(path, 'w', newline='') as f:
        wr = csv.DictWriter(f, fieldnames=FIT_COLUMNS)
        wr.writeheader()
        for r in rows + UNITE_ROWS:
            wr.writerow({k: (f'{v:.10g}' if isinstance(v, float) else v) for k, v in r.items()})
    print('written:', path.relative_to(ROOT).as_posix())


def plot_w_of_a(entries, fname, title, fits=True, ylim=None):
    """w(a) over the full run (left, log a) and zoomed to 0.3 <= a <= 1 (right) with each run's CPL fit
    (dashed) and Unite's CPL line (dotted).  entries = [(label, table, w-column), ...]."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12.5, 4.4))
    au = np.linspace(0.3, 1.0, 200)
    for label, d, wcol in entries:
        a, w = d['a'], d[wcol]
        line, = ax1.plot(a, w, lw=1.2, label=label)
        ax2.plot(a, w, lw=1.4, color=line.get_color(), label=label)
        if fits and a[0] <= 0.31:
            w0, wa = cpl_fit(a, w)
            ax2.plot(au, w0 + wa * (1.0 - au), '--', lw=0.9, color=line.get_color())
    afull = np.geomspace(min(d['a'][0] for _, d, _ in entries), 1.0, 300)
    ax1.plot(afull, UNITE_W0 + UNITE_WA * (1.0 - afull), 'k:', lw=1.2, label='Unite CPL line, extrapolated')
    ax2.plot(au, UNITE_W0 + UNITE_WA * (1.0 - au), 'k:', lw=2.0, label='Unite CPL (-0.861, -0.60)')
    ax2.axhline(UNITE_WCONST, color='0.4', lw=0.8, ls='-.', label='Unite constant w = -0.764')
    for ax in (ax1, ax2):
        ax.axhline(-1.0, color='k', lw=0.5)
        ax.set_xlabel('a')
        ax.set_ylabel('w')
        if ylim:
            ax.set_ylim(*ylim)
    ax1.set_xscale('log')
    ax1.set_title(f'{title}: the whole run')
    ax2.set_xlim(0.3, 1.0)
    ax2.set_title('0.3 <= a <= 1 (supernova range) with the CPL fits, dashed')
    ax1.legend(fontsize=7, loc='best')
    ax2.legend(fontsize=7, loc='best')
    fig.savefig(RESULTS / fname, dpi=130, bbox_inches='tight')
    print('figure:', f'results/{fname}')
    plt.show()


def plot_caldwell_linder(entries, fname, title):
    """The Caldwell-Linder plane w' = dw/dN versus w over a >= 0.3, with the thawing and freezing wedges
    as guides; the class printed in the legend is the sign of dw/dN over the fit range (the rule used here)."""
    fig, ax = plt.subplots(figsize=(7.0, 4.8))
    wg = np.linspace(-1.0, -0.2, 60)
    ax.fill_between(wg, 1.0 + wg, 3.0 * (1.0 + wg), color='tab:red', alpha=0.08, label="thawing wedge: 1+w < w' < 3(1+w)")
    ax.fill_between(wg, 3.0 * wg * (1.0 + wg), 0.2 * wg * (1.0 + wg), color='tab:blue', alpha=0.08, label="freezing wedge: 3w(1+w) < w' < 0.2w(1+w)")
    for label, d, wcol in entries:
        a, w, N = d['a'], d[wcol], d['N']
        m = a >= 0.3
        wp = np.gradient(w, N)
        line, = ax.plot(w[m], wp[m], lw=1.2, label=f'{label}: {thaw_class(N, w, a)}')
        ax.plot(w[-1], wp[-1], 'o', ms=4, color=line.get_color())
    ax.axhline(0.0, color='k', lw=0.5)
    ax.set_xlabel('w')
    ax.set_ylabel("w' = dw/dN")
    ax.set_title(title + ' (dot = today)')
    ax.legend(fontsize=7, loc='best')
    fig.savefig(RESULTS / fname, dpi=130, bbox_inches='tight')
    print('figure:', f'results/{fname}')
    plt.show()


def scipy_scalar(name, cpl=False):
    """Re-integrate a Model A (or, with cpl=True, Model A') run with scipy DOP853 at rtol 1e-11 from the
    same initial state and the same normalised potential; return max |w_rust - w_scipy| and max |t_rust - t_scipy|."""
    r = RUNS[name]
    d = r['table']
    V, dV = scalar_potential(r['pot'], r['params'])
    N = d['N']

    def H(n, phi, phid):
        if cpl:
            return np.sqrt(cpl_h2(np.exp(n)))
        return np.sqrt(OM * np.exp(-3.0 * n) + OR * np.exp(-4.0 * n) + (0.5 * phid * phid + V(phi)) / 3.0)

    def rhs(n, y):
        phi, phid, t = y
        h = H(n, phi, phid)
        return [phid / h, -3.0 * phid - dV(phi) / h, 1.0 / h]

    sol = solve_ivp(rhs, (N[0], N[-1]), [d['phi'][0], d['phidot'][0], 0.0], method='DOP853', rtol=1e-11, atol=1e-14, t_eval=N)
    assert sol.success, sol.message
    phi, phid = sol.y[0], sol.y[1]
    w = (0.5 * phid ** 2 - V(phi)) / (0.5 * phid ** 2 + V(phi))
    t = sol.y[2] + 0.5 / H(N[0], d['phi'][0], d['phidot'][0])      # the same analytic age offset t_age(N0) = 1/(2 H(N0))
    return float(np.abs(w - d['w_phi']).max()), float(np.abs(t - d['t']).max()), w


def scipy_spinor(name):
    """Re-integrate a Model B run with scipy DOP853 at rtol 1e-11: ds/dN = -3 s, dt/dN = 1/H; compare w and t."""
    r = RUNS[name]
    d = r['table']
    V, dV = spinor_potential(r['pot'], r['params'])
    N = d['N']

    def H(n, s):
        return np.sqrt(OM * np.exp(-3.0 * n) + OR * np.exp(-4.0 * n) + V(s) / 3.0)

    sol = solve_ivp(lambda n, y: [-3.0 * y[0], 1.0 / H(n, y[0])], (N[0], N[-1]), [d['s'][0], 0.0],
                    method='DOP853', rtol=1e-11, atol=1e-14, t_eval=N)
    assert sol.success, sol.message
    s = sol.y[0]
    w = s * dV(s) / V(s) - 1.0
    t = sol.y[1] + 0.5 / H(N[0], d['s'][0])
    return float(np.abs(w - d['w_Psi']).max()), float(np.abs(t - d['t']).max()), w
'''

# The two interactive cells (tagged 'interactive'; skipped by the headless runner in the sense that
# they detect the absence of a person and print a notice instead of prompting).
NAME_CODE = r'''
import os, sys

def headless_now():
    """True when nobody can answer a prompt: nbconvert / nbclient execution (the kernel's stdin is
    disabled), a FABLE_HEADLESS environment variable, or a plain Python run without a terminal."""
    if os.environ.get('FABLE_HEADLESS'):
        return True
    try:
        return not get_ipython().kernel._allow_stdin
    except Exception:
        return not sys.stdin.isatty()

HEADLESS = headless_now()
if HEADLESS:
    NOTEBOOK_NAME = '__NBNAME__'
    print('Headless execution: no prompt; the notebook keeps its name', NOTEBOOK_NAME)
else:
    NOTEBOOK_NAME = input('Name for this notebook: ').strip() or '__NBNAME__'
    print('This notebook is called', NOTEBOOK_NAME)
'''

SAVE_CODE = r'''
import shutil
from pathlib import Path

if globals().get('HEADLESS', True):
    print('Headless execution: the save dialog is skipped; the notebook stays where it is.')
else:
    target = ''
    try:
        import tkinter
        from tkinter import filedialog
        root = tkinter.Tk()
        root.withdraw()
        root.attributes('-topmost', True)
        target = filedialog.asksaveasfilename(title='Save a copy of this notebook as',
                                              initialfile=NOTEBOOK_NAME + '.ipynb', defaultextension='.ipynb',
                                              filetypes=[('Jupyter notebook', '*.ipynb'), ('All files', '*.*')])
        root.destroy()
    except Exception as exc:
        print(f'No graphical dialog is available ({exc}). Falling back to a typed folder path.')
        folder = input('Folder to save a copy of this notebook into (empty = do not save): ').strip()
        if folder:
            target = str(Path(folder) / (NOTEBOOK_NAME + '.ipynb'))
    if target:
        shutil.copyfile(Path.cwd() / '__NBNAME__.ipynb', target)
        print('A copy of this notebook was saved as', target)
    else:
        print('Nothing saved.')
'''


def closing_cells(nbname, number):
    return [
        md(f"""
## {number}. Name this notebook and save it

The last two cells are the interactive ones.  The first asks you for a name for this notebook
(press Enter to keep the current one); the second opens the usual graphical *Save as* dialog so
you can put a copy of the notebook -- with all the outputs you have just produced -- wherever you
like.  When the notebook is executed headlessly (by `run_all.sh`, `run_all.ps1` or `nbconvert`)
there is nobody to answer, so both cells detect that and print a one-line notice instead.
"""),
        code(NAME_CODE.replace("__NBNAME__", nbname), tags=["interactive"]),
        md("""
If the graphical dialog cannot be opened (no display, or Tk missing from your Python), the cell
falls back to asking for a folder path in plain text and copies the notebook there.
"""),
        code(SAVE_CODE.replace("__NBNAME__", nbname), tags=["interactive"]),
    ]


# ==============================================================================================
# Notebook 01: fableScalar, Models A and A'
# ==============================================================================================

def notebook_01():
    name = "01_fableScalar_quintessence"
    cells = []
    cells.append(md(r"""
# fableScalar: a quintessence field and its equation of state

This notebook integrates **Model A** (the scalar field `fableScalar` rolling in a potential and
sourcing the expansion of a flat universe, the standard quintessence reference model) and
**Model A′** (the same field as a test field on the *Unite* CPL background) with the Rust solver
`fable_cosmo` (pure-Rust SUNDIALS 7.8.0 CVODE), for six potentials and several parameter values.
For every run it plots `w(a)`, fits the CPL line `w0 + wa (1 − a)` over the supernova range,
classifies the run as thawing or freezing in the Caldwell–Linder plane, re-integrates it with
scipy's DOP853 as a cross-check, and, for the reference case, compares three integrators (CVODE,
scipy, Mathematica `NDSolve`).  The last sections answer, from the numbers, which exponential
potential comes closest to Unite's `(w0, wa) = (−0.861, −0.60)` and whether `|wa| = 0.6` is
reachable by a field that never crosses `w = −1`.
"""))
    cells.append(md(SECTION_1))
    cells.append(md(SECTION_2))
    cells.append(md(r"""
## 3. The field, its Lagrangian and its energy-momentum tensor

**On the 8-dimensional pre-universe (what Part VI of the Mathematica notebook proves).**  The
pre-universe has coordinates `X = {x0, …, x7}`, flat metric `eta = diag(+,+,+,+,−,−,−,−)`, the
canonical frame `e = diag(Tan[6Hx0], q, q, q, 1, p, p, p)` with `q = e^{−a4[Hx4]}/Sin[6Hx0]^{1/6}`,
`p = e^{+a4[Hx4]}/Sin[6Hx0]^{1/6}`, hence `g = diag(Tan², q², q², q², −1, −p², −p², −p²)` and
`Sqrt[det g] = Sec[6Hx0]`.  `H` is the notebook's constant; the undetermined function `a4` is
never given a value anywhere in this work.  The observer's time is `t ≡ x4` (`g44 = −1`) and
the observed 3-space is `(x1, x2, x3)`, whose frame entry at fixed `x0` is the scale factor:
`a(t) ∝ e^{−a4[Ht]}` (a kinematic identification only; the sheet expands where `a4′ < 0`).

`fableScalar ≡ φ(x)` is a real scalar field on the 8-manifold, minimally coupled, with a
self-interaction potential `V(φ)`:

    L_φ = Sqrt[det g] · L̂_φ,        L̂_φ = −½ g^{μν} ∂_μφ ∂_νφ − V(φ)

(the sign makes the x4-kinetic term positive: `−½ g^{44} φ̇² = +½ φ̇²`).  Its energy–momentum
tensor, `T_{μν} = −(2/Sqrt[g]) δS/δg^{μν}`, is

    T_{μν} = ∂_μφ ∂_νφ + g_{μν} L̂_φ .

Part VI asserts that it is symmetric, that `∇^μ T_{μν} = (□φ − V′(φ)) ∂_νφ` holds *off shell* for
a generic `φ(x0, …, x7)` (so conservation on shell is exact), and that the trace is
`T^μ_μ = −3(∂φ)² − 8V`.  For a field depending on `x0`, `x4` and the second-sheet coordinates,
the observer `u = ∂_4` measures

    KE = ½ φ̇²                       (x4 kinetic energy)
    PE = V(φ)                       (potential energy)
    G0 = ½ Cot[6Hx0]² (∂_0 φ)²      (gradient energy along the hidden coordinate x0)
    G5 = ½ (1/p²) Σ_{i=5,6,7} (∂_i φ)²   (gradient energy along the second, timelike sheet)

    ρ_φ = KE + PE + G0 − G5,       P_φ = KE − PE − G0 + G5,       wScalar ≡ w_φ = P_φ / ρ_φ .

Two consequences proved there and used here: **the null energy condition holds identically**,
`ρ_φ + P_φ = 2 KE ≥ 0`, so `w_φ ≥ −1` wherever `ρ_φ > 0` (guaranteed for `V ≥ 0` and any field
independent of `x5, x6, x7`): fableScalar cannot cross the phantom divide; and **there is no
Hubble friction in x4** on the pre-universe, because `Sqrt[g] g^{44} = −Sec[6Hx0]` does not
depend on `x4` (the observed sheet's expansion is compensated by the second sheet's contraction).

**The 4-dimensional reference model (what this notebook integrates).**  Integrating the
8-dimensional action over the hidden coordinates gives a hidden 4-volume density
`𝒱_hid ∝ a^{−3}`, so the reduced density `ρ_4 ∝ a^{−3} ρ_8` is not separately conserved and the
framework, having no gravitational sector (no Einstein equations, `a4` free), does not say which
density gravitates.  The **standard quintessence model** — `φ̈ + 3Hφ̇ + V′(φ) = 0` with the
Friedmann equation on a separate FLRW frame `diag(1, a, a, a, 1, 1, 1, 1)` — is what one obtains
when the hidden volume is held fixed and the field sources the expansion.  It is the reference
model of the CPL fits, and it is what Model A integrates; it is never a substitution into the
canonical frame and never gives `a4` a value.  With `G0 = G5 = 0` the energies reduce to the
usual `ρ = ½φ̇² + V`, `P = ½φ̇² − V`, `w = P/ρ`.
"""))
    cells.append(md(r"""
## 4. The equations of motion

Units: `M_pl² = 1/(8πG) = 1`, `H0 = 1` (time in `1/H0`), `a0 = 1`, so the critical density today
is `ρ_crit,0 = 3 H0² M_pl² = 3` and `ρ_m = 3 Ω_m0 e^{−3N}`, `ρ_r = 3 Ω_r0 e^{−4N}` with
`Ω_m0 = 0.3`, `Ω_r0 = 8.4e−5`.  The independent variable is `N = ln a`.  The scalar field obeys
the Klein–Gordon equation with Hubble friction, `φ̈ + 3Hφ̇ + V′(φ) = 0`, and the Friedmann
equation closes the system:

    H² = (ρ_m + ρ_r + ρ_φ)/3 = Ω_m0 e^{−3N} + Ω_r0 e^{−4N} + (½φ̇² + V(φ))/3,    so H(N = 0) = 1 exactly.

**Model A′** uses instead the fixed CPL background of the *Unite* fit,
`H² = Ω_m0 e^{−3N} + Ω_r0 e^{−4N} + Ω_DE0 f(a)` with
`f(a) = ρ_DE(a)/ρ_DE0 = a^{−3(1+w0+wa)} e^{−3wa(1−a)}` (the closed form of
`exp(3∫_a^1 (1 + w(a′)) da′/a′)`, unit-tested against the integral; `f(1) = 1`); the field
does not source `H` there.

### 4.1 The first-order system actually handed to SUNDIALS

The state vector is `y = (φ, φ̇, t)` and the independent variable is `N`; `models.rs` integrates

    dφ/dN  = φ̇ / H
    dφ̇/dN = −3 φ̇ − V′(φ) / H
    dt/dN  = 1 / H                     (cosmic time, carried as a state variable)

with `H = H(N, φ, φ̇)` from the Friedmann equation above (Model A, `rhs_scalar_flrw`) or from the
CPL background (Model A′, `rhs_scalar_cpl`).  CVODE runs BDF with Newton iteration and a dense
finite-difference Jacobian, `rtol = 1e−10`, `atol = 1e−12`, `CVodeSetStopTime`, and returns the
state at 701 equally spaced values of `N` (`CV_NORMAL`).

*Initial conditions.*  Every FLRW run starts at `N0 = −7` (`a ≈ 9.1e−4`, `z ≈ 1100`; with
`Ω_r0 = 8.4e−5` radiation–matter equality is at `a_eq = Ω_r0/Ω_m0 = 2.8e−4`, so the start is
just after it, with radiation still 24 % of the density) from rest, `φ̇(N0) = 0` (the frozen
start), at a value `φ_i` that the solver prints and that `--param phi_i=… --param phidot_i=…`
overrides: `exp`: 0, `invpower`: 0.2, `pngb`: `0.5 f`, `hilltop`: `0.1 μ`, `const`: 0.  The age
of the universe at `N0` is added analytically, `t_age(N0) = 1/(2 H(N0))` (the exact age of a
radiation-dominated universe with that Hubble rate; since matter already dominates at `N0` the
true age lies between this and `2/(3H(N0))`, an uncertainty of a third of `2.2e−5/H0`,
negligible against `t ≈ 1/H0` today, but stated and printed).

*Normalisation.*  Rescaling `V → kV` is not a symmetry of the equations, so the overall scale of
`V` is found by shooting: bisection on `log10 k` in the bracket `[10^{−6}, 10^{6}]`, 80
iterations or `Δlog10 k < 1e−13`, until `Ω_φ(a = 1) = 1 − Ω_m0 − Ω_r0 = 0.699916` (Model A) or
`ρ_φ(a = 1)/3 = Ω_DE0` (Model A′).  The solver exits with code 1 and a one-line reason if the
target is not bracketed (a field that has joined the scaling solution of the exponential
potential with `λ² > 3` can never carry 70 % of the density: we meet this below) or if
`ρ_φ ≤ 0` anywhere on the run.  `--no-normalize` keeps the parameters as given.

*Potentials* (`potentials.rs`): `exp` `V0 e^{−λφ}`, `invpower` `V0 φ^{−α}`, `pngb`
`V0 (1 + cos(φ/f))`, `quadratic` `½m²φ²`, `hilltop` `V0 (1 − φ²/μ²)` (used where `V > 0`),
`const` `V0` (the control, `w = −1`).

*Outputs per point*: `a, z, N, t, phi, phidot, H, KE, PE, rho_phi, P_phi, w_phi, Omega_phi,
Omega_m, Omega_r, q_dec` with `q_dec = −1 − (dH/dN)/H`; Model A′ replaces the last four by
`w_cpl, Omega_phi_test, Omega_DE_cpl`.
"""))
    cells.append(md(r"""
## 5. Running the solver

The binary is `rust/fable_cosmo/target/release/fable_cosmo` (`.exe` on Windows), built by the
setup.  Its command line is

    fable_cosmo <model> [--potential NAME] [--param KEY=VALUE ...] [--n0 X0] [--n1 X1] [--points K]
                [--out FILE.csv] [--no-normalize] [--rtol R] [--atol A] [--method bdf|adams]

with `model` one of `scalar-flrw` (Model A) and `scalar-cpl` (Model A′) here; defaults
`--n0 -7 --n1 0 --points 701`.  It writes a CSV whose header line names every column (15
significant digits) and prints to stderr the initial conditions, a `# stats:` line with the
CVODE step and function-evaluation counts, the potential *after* normalisation, and its version.
Exit code 0 is success, 1 a solver or physics error with a one-line reason, 2 a usage error.

The next cell locates the binary relative to this notebook, checks that it runs, and defines the
helpers used throughout: `run_solver` (runs one case, prints the solver's stderr and returns the
CSV as a numpy record array), the Python copies of the potentials, the CPL fit, the
thawing/freezing classifier, the plotting functions, and the scipy re-integration.  Nothing
here is random; every number is reproducible.
"""))
    cells.append(code(SETUP_CODE))

    # ---- 5.1 exponential
    cells.append(md(r"""
### 5.1 The exponential potential, `V = V0 e^{−λφ}`, for λ = 0.5, 1, 1.5, 2 and 3

The reference case is `λ = 1` (its Mathematica `NDSolve` twin is compared in 5.8).  Each run
starts frozen at `φ_i = 0`; the solver normalises `V0` so that the field carries 69.99 % of the
density today.  Watch the `# potential=` line: it is the `V0` after normalisation, and it is the
value the scipy cross-check and the Mathematica reference use.  Nothing is fitted yet: the
table of 5.6 does that for all runs at once.
"""))
    cells.append(code(r'''
for lam in [0.5, 1, 1.5, 2]:
    d = run_solver(f'nb01_exp_lambda{lam}', 'scalar-flrw', '--potential', 'exp', '--param', f'lambda={lam}', label=f'exp lambda={lam}')
    print(f'  -> w(a=1) = {d["w_phi"][-1]:+.5f}   Omega_phi(a=1) = {d["Omega_phi"][-1]:.6f}   min w = {d["w_phi"].min():+.6f}\n')
'''))
    cells.append(md(r"""
`λ = 3` is different: for `λ² > 3` the late-time attractor of the exponential potential is the
*scaling* solution, on which the field tracks the dominant component (`w_φ = w_m = 0` in the
matter era) with a fixed share `Ω_φ = 3/λ²`; whatever `V0` is, `Ω_φ(a = 1)` never reaches
0.70, so the normalisation cannot bracket its target and the solver refuses with a one-line
reason (we catch the exit code and print it).  To show what the field does instead, the same
potential is then run with the scale fixed by hand (`--no-normalize --param v0=1e6`, deep on
the attractor): it is not a dark-energy model, and its row in the fit table is marked.
"""))
    cells.append(code(r'''
r = run_solver('nb01_exp_lambda3', 'scalar-flrw', '--potential', 'exp', '--param', 'lambda=3', expect_failure=True)
assert r.returncode == 1, 'the normalisation of lambda = 3 was expected to fail'
print()
d = run_solver('nb01_exp_lambda3_scaling', 'scalar-flrw', '--potential', 'exp', '--param', 'lambda=3', '--no-normalize', '--param', 'v0=1e6',
               label='exp lambda=3 (scaling; --no-normalize v0=1e6)')
print(f'  -> Omega_phi(a=1) = {d["Omega_phi"][-1]:.4f} (the scaling value 3/lambda^2 = {3/9:.4f}),  w(a=1) = {d["w_phi"][-1]:+.4f},  q_dec(a=1) = {d["q_dec"][-1]:+.4f}')
'''))

    # ---- 5.2 inverse power
    cells.append(md(r"""
### 5.2 The inverse power potential, `V = V0 φ^{−α}`, α = 1: is the tracker joined?

The Ratra–Peebles potential has a *tracker* solution (`w_φ = −2/(α + 2) = −2/3` in the matter
era for `α = 1`) that attracts a wide range of initial conditions; a field on the tracker is
*freezing* (its `w` falls towards −1 as it comes to dominate).  With the solver's frozen start
(`φ_i = 0.2`, `φ̇_i = 0` at `N0 = −7`) the field may or may not have reached the tracker by
today.  We run the default start and then start much earlier (`--n0 -25`, `a = 1.4e−11`) to see
whether the extra e-folds let the field join the tracker; both are reported.
"""))
    cells.append(code(r'''
d1 = run_solver('nb01_invpower_alpha1', 'scalar-flrw', '--potential', 'invpower', '--param', 'alpha=1', label='invpower alpha=1 (N0=-7)')
print()
d2 = run_solver('nb01_invpower_alpha1_n0-25', 'scalar-flrw', '--potential', 'invpower', '--param', 'alpha=1', '--n0', '-25', '--points', '2501',
                label='invpower alpha=1 (N0=-25)')
print()
for lab, d in [('N0 = -7 ', d1), ('N0 = -25', d2)]:
    w_of = lambda n: float(np.interp(n, d['N'], d['w_phi']))
    print(f'{lab}: w(N=-6) = {w_of(-6):+.5f}  w(N=-4) = {w_of(-4):+.5f}  w(N=-2) = {w_of(-2):+.5f}  w(a=0.3) = {w_at(d["a"], d["w_phi"], 0.3):+.5f}  w(a=1) = {d["w_phi"][-1]:+.5f}  phi(a=1) = {d["phi"][-1]:.5f}')
i7 = int(np.argmin(np.abs(d2['N'] + 7.0)))
print(f'the N0=-25 run at N = {d2["N"][i7]:.2f}: w = {d2["w_phi"][i7]:+.6f}, phi = {d2["phi"][i7]:.6f}, phidot = {d2["phidot"][i7]:.3e}   (tracker value in the matter era: w = -2/(alpha+2) = {-2/3:+.4f})')
w2_on_1 = np.interp(d1['N'], d2['N'], d2['w_phi'])
print(f'max |w(N0=-25) - w(N0=-7)| on the common range N >= -7: {np.abs(w2_on_1 - d1["w_phi"]).max():.2e}')
'''))
    cells.append(md(r"""
The two starts give the same history to a few parts in 10⁵: the field is still frozen at
`w = −1` when `N = −7` arrives, whatever happened before (Hubble friction in the radiation era
is enormous, `3H ≫ V″^{1/2}`), so starting earlier adds nothing.  The field thaws late, its `w`
rises from −1, overshoots and turns down slightly before today: with a frozen start the inverse
power potential does **not** join its tracker by `a = 1`, and its class is read off `dw/dN`
below, not off the potential's reputation.
"""))

    # ---- 5.3 pngb, hilltop, const
    cells.append(md(r"""
### 5.3 The pseudo-Nambu–Goldstone potential, the hilltop, and the constant (the control)

`pngb`: `V = V0 (1 + cos(φ/f))` with `f = 1` (start `φ_i = 0.5`), and `f = 0.5` started at
`φ_i = 0.3` (steeper, so the field thaws more).  `hilltop`: `V = V0 (1 − φ²/μ²)` with `μ = 3`
(start `φ_i = 0.3`, well inside `V > 0`).  `const`: `V = V0`, a cosmological constant; it must
give `w = −1` at every point, and the assertion below makes the notebook fail if it does not.
"""))
    cells.append(code(r'''
run_solver('nb01_pngb_f1', 'scalar-flrw', '--potential', 'pngb', '--param', 'f=1', label='pngb f=1')
print()
run_solver('nb01_pngb_f0.5', 'scalar-flrw', '--potential', 'pngb', '--param', 'f=0.5', '--param', 'phi_i=0.3', label='pngb f=0.5 phi_i=0.3')
print()
run_solver('nb01_hilltop_mu3', 'scalar-flrw', '--potential', 'hilltop', '--param', 'mu=3', label='hilltop mu=3')
print()
dc = run_solver('nb01_const', 'scalar-flrw', '--potential', 'const', label='const (control)')
dev = np.abs(dc['w_phi'] + 1.0).max()
print(f'\ncontrol: max |w + 1| over the run = {dev:.1e}')
assert dev < 1e-9, 'the constant potential must give w = -1 everywhere'
'''))

    # ---- 5.4 Model A'
    cells.append(md(r"""
### 5.4 Model A′: the exponential potential as a test field on the Unite CPL background

Same equations, but `H(a)` is the CPL background with `(w0, wa) = (−0.861, −0.60)` and
`Ω_DE0 = 0.699916`; the field does not source `H`, and its scale is fixed so that it would carry
`Ω_DE0` today.  `λ = 1` works as before.  For `λ = 2` (`λ² > 3`) the test field joins the
scaling regime of the background and its density today saturates at about half of the target
whatever `V0` is; the solver reports that the target is not bracketed (we catch and print the
reason), and we then run the case with the scale chosen by hand (`--no-normalize --param v0=10`,
the value that maximises `ρ_φ(a = 1)`), so that its `w(a)` can still be looked at — its row in
the table says that it carries only `Ω ≈ 0.50` today.
"""))
    cells.append(code(r'''
d = run_solver('nb01_cpl_exp_lambda1', 'scalar-cpl', '--potential', 'exp', '--param', 'lambda=1', label="A' cpl exp lambda=1")
print(f'  -> w(a=1) = {d["w_phi"][-1]:+.5f}   Omega_phi_test(a=1) = {d["Omega_phi_test"][-1]:.6f}   w_cpl(a=1) = {d["w_cpl"][-1]:+.4f}\n')
r = run_solver('nb01_cpl_exp_lambda2', 'scalar-cpl', '--potential', 'exp', '--param', 'lambda=2', expect_failure=True)
assert r.returncode == 1, "the normalisation of lambda = 2 on the CPL background was expected to fail"
print()
d = run_solver('nb01_cpl_exp_lambda2_hand', 'scalar-cpl', '--potential', 'exp', '--param', 'lambda=2', '--no-normalize', '--param', 'v0=10',
               label="A' cpl exp lambda=2 (hand v0=10, Omega 0.50)")
print(f'  -> w(a=1) = {d["w_phi"][-1]:+.5f}   Omega_phi_test(a=1) = {d["Omega_phi_test"][-1]:.4f}  (target was {OMEGA_FIELD_TODAY:.4f})')
'''))

    # ---- 5.5 plots
    cells.append(md(r"""
### 5.5 `w(a)` for every run, and the Caldwell–Linder plane

Left panels: the whole run on a logarithmic `a` axis, with Unite's CPL line extrapolated to
`a → 0` (where it reaches −1.46).  Right panels: the supernova range `0.3 ≤ a ≤ 1`, each run's
own CPL least-squares line dashed in its colour, Unite's line dotted, the constant-w fit
dash-dotted.  The exponential family first, then the other potentials and the control, then
Model A′.  The Caldwell–Linder plane plots `w′ = dw/dN` against `w` over the same range: a run
above the axis is thawing, below it freezing; the wedges are the usual guides, the class in the
legend is the sign of `dw/dN` over the fit range.
"""))
    cells.append(code(r'''
EXP_RUNS = ['nb01_exp_lambda0.5', 'nb01_exp_lambda1', 'nb01_exp_lambda1.5', 'nb01_exp_lambda2', 'nb01_exp_lambda3_scaling']
OTHER_RUNS = ['nb01_invpower_alpha1', 'nb01_invpower_alpha1_n0-25', 'nb01_pngb_f1', 'nb01_pngb_f0.5', 'nb01_hilltop_mu3', 'nb01_const']
CPL_RUNS = ['nb01_cpl_exp_lambda1', 'nb01_cpl_exp_lambda2_hand']
entries = lambda names: [(RUNS[n]['label'], RUNS[n]['table'], 'w_phi') for n in names]
plot_w_of_a(entries(EXP_RUNS), 'nb01_w_of_a_exp.png', 'Model A, exponential potential', ylim=(-1.05, 0.2))
plot_w_of_a(entries(OTHER_RUNS), 'nb01_w_of_a_other.png', 'Model A, other potentials and the control', ylim=(-1.05, -0.6))
plot_w_of_a(entries(CPL_RUNS), 'nb01_w_of_a_cpl.png', "Model A', test field on the CPL background", ylim=(-1.05, 0.0))
'''))
    cells.append(md(r"""
The Caldwell–Linder plane for the same runs.  The dot marks today; a trajectory that stays above
`w′ = 0` over `0.3 ≤ a ≤ 1` is thawing, one that stays below is freezing, one that crosses the
axis is mixed (the inverse-power runs, whose `w` overshoots and turns back; the `λ = 3` scaling
run, which oscillates about the background's `w`).
"""))
    cells.append(code(r'''
plot_caldwell_linder(entries(EXP_RUNS[:4] + OTHER_RUNS[:5]), 'nb01_caldwell_linder.png', "Caldwell-Linder plane, w' versus w over 0.3 <= a <= 1")
'''))

    # ---- 5.6 table
    cells.append(md(r"""
### 5.6 The CPL fit table

For every run: the unweighted least-squares fit of `w(a)` to `w0 + wa (1 − a)` over
`0.3 ≤ a ≤ 1` (numpy.polyfit on `1 − a`), the extrapolation `w0 + wa` of the fitted line to
`a = 0`, the *true* `w(a = 0.3)`, `w(1)` and `min w` over the whole run, the class, the field's
`Ω` today and the Euclidean distance of `(w0, wa)` from Unite's point, printed next to Unite's
`(−0.861, −0.60, w0 + wa = −1.461)` and the constant-w fit `−0.764`, and written to
`results/nb01_cpl_fits.csv` (with the two Unite rows appended for reference).
"""))
    cells.append(code(r'''
FIT_RUNS = EXP_RUNS + OTHER_RUNS + CPL_RUNS
fits01 = [fit_row(n, 'w_phi') for n in FIT_RUNS]
fit_table(fits01, RESULTS / 'nb01_cpl_fits.csv')
'''))

    # ---- 5.7 scipy cross-check
    cells.append(md(r"""
### 5.7 Cross-check: every run re-integrated with scipy (DOP853, rtol = 1e−11)

`scipy_scalar` takes the run's own initial state and the potential *as normalised by the
solver* (parsed from its `# potential=` line), integrates the same three equations with a
completely different method (the explicit Dormand–Prince 8(5,3) pair at `rtol = 1e−11`,
`atol = 1e−14`) on the same 701 values of `N`, and reports `max |w_rust − w_scipy|` and
`max |t_rust − t_scipy|`.  The notebook fails if any difference in `w` exceeds `1e−6`; the
values are in fact at the level of the solver's own tolerance, a few parts in 10⁹ at worst.
"""))
    cells.append(code(r'''
xcheck01 = {}
for n in FIT_RUNS:
    dw, dt, _ = scipy_scalar(n, cpl=RUNS[n]['model'] == 'scalar-cpl')
    xcheck01[n] = dw
    print(f'{RUNS[n]["label"]:46s} max|w_rust - w_scipy| = {dw:.3e}   max|t_rust - t_scipy| = {dt:.3e}')
    assert dw < 1e-6, f'{n}: the scipy cross-check differs by {dw}'
print(f'\nlargest difference in w over all {len(FIT_RUNS)} runs: {max(xcheck01.values()):.3e}')
'''))

    # ---- 5.8 three-way
    cells.append(md(r"""
### 5.8 Three integrators on the reference case: CVODE (Rust), DOP853 (scipy), NDSolve (Mathematica)

`reference/mathematica_scalar_exp.csv` was written by Part VI of the Mathematica notebook
(`reference/make_reference.wls`): the same equations, the same `Ω_m0, Ω_r0`, the same frozen
start, the same normalised `V0 = 2.6871520526047146` (the value the solver printed above for
`λ = 1`), integrated by `NDSolve` at 24-digit working precision and exported on the same 701
values of `N`.  The cell compares all three pairwise on `w`, and Rust against Mathematica on
`φ`, `φ̇`, `H` and `t`.
"""))
    cells.append(code(r'''
ref = np.genfromtxt(REFERENCE / 'mathematica_scalar_exp.csv', delimiter=',', names=True)
d = RUNS['nb01_exp_lambda1']['table']
assert ref.shape == d.shape and np.abs(ref['N'] - d['N']).max() < 1e-12, 'the reference grid must be the solver grid'
_, _, w_scipy = scipy_scalar('nb01_exp_lambda1')
threeway01 = {'rust-mathematica': float(np.abs(ref['w_phi'] - d['w_phi']).max()),
              'scipy-mathematica': float(np.abs(ref['w_phi'] - w_scipy).max()),
              'rust-scipy': float(np.abs(d['w_phi'] - w_scipy).max())}
for k, v in threeway01.items():
    print(f'max |w difference| {k:18s} = {v:.3e}')
for c in ['phi', 'phidot', 'H', 't']:
    print(f'max |{c} rust - mathematica| = {np.abs(ref[c] - d[c]).max():.3e}   (max relative {(np.abs(ref[c] - d[c]) / np.maximum(np.abs(ref[c]), 1e-300)).max():.3e})')
print(f'w(a=1): rust {d["w_phi"][-1]:.12f}  scipy {w_scipy[-1]:.12f}  mathematica {ref["w_phi"][-1]:.12f}')
assert threeway01['rust-mathematica'] < 1e-8 and threeway01['rust-scipy'] < 1e-8
'''))

    # ---- 5.9 lambda scan
    cells.append(md(r"""
### 5.9 A finer scan in λ, to answer "which λ" precisely

The five values above bracket the answer; this scan runs `λ = 0.5, 0.6, …, 2.0` (16 quick runs,
CSV taken from the solver's stdout, nothing written), fits each, and plots the path of
`(w0, wa)` with Unite's point.  It also interpolates the `λ` at which the fitted `wa` equals
`−0.60` and reports the true `w(a = 0.3)` and `min w` there.  The scan table is written to
`results/nb01_lambda_scan.csv`.
"""))
    cells.append(code(r'''
scan = []
for lam in np.round(np.arange(0.5, 2.001, 0.1), 2):
    d = run_solver(f'scan_lambda{lam}', 'scalar-flrw', '--potential', 'exp', '--param', f'lambda={lam}', keep=False, quiet=True)
    w0, wa = cpl_fit(d['a'], d['w_phi'])
    scan.append((lam, w0, wa, np.hypot(w0 - UNITE_W0, wa - UNITE_WA), d['w_phi'][-1], w_at(d['a'], d['w_phi'], 0.3), d['w_phi'].min()))
scan = np.array(scan)
print(f"\n{'lambda':>6s} {'w0':>8s} {'wa':>8s} {'dist':>7s} {'w(1)':>8s} {'w(0.3)':>8s} {'min w':>8s}")
for row in scan:
    print(f'{row[0]:6.2f} {row[1]:8.4f} {row[2]:8.4f} {row[3]:7.4f} {row[4]:8.4f} {row[5]:8.4f} {row[6]:8.4f}')
with open(RESULTS / 'nb01_lambda_scan.csv', 'w', newline='') as f:
    wr = csv.writer(f); wr.writerow(['lambda', 'w0_fit', 'wa_fit', 'dist_to_unite', 'w_a1', 'w_a03', 'w_min']); wr.writerows(scan.tolist())
i = scan[:, 3].argmin()
lam_wa06 = float(np.interp(-0.60, scan[::-1, 2], scan[::-1, 0]))
print(f'\nclosest to Unite in the (w0, wa) plane: lambda = {scan[i, 0]:.1f} with (w0, wa) = ({scan[i, 1]:+.4f}, {scan[i, 2]:+.4f}), distance {scan[i, 3]:.4f}')
print(f'wa = -0.60 is reached at lambda = {lam_wa06:.3f}, where w(a=0.3) = {np.interp(lam_wa06, scan[:, 0], scan[:, 5]):+.4f} and w0 = {np.interp(lam_wa06, scan[:, 0], scan[:, 1]):+.4f}; min w over every scan run = {scan[:, 6].min():+.6f}')
fig, ax = plt.subplots(figsize=(6.2, 4.6))
ax.plot(scan[:, 1], scan[:, 2], 'o-', ms=4, label='exp potential, lambda = 0.5 ... 2.0')
for row in scan[::5]:
    ax.annotate(f'lambda={row[0]:.1f}', (row[1], row[2]), textcoords='offset points', xytext=(5, 5), fontsize=8)
ax.plot(UNITE_W0, UNITE_WA, 'r*', ms=12, label='Unite (-0.861, -0.60)')
ax.plot(UNITE_WCONST, 0.0, 'ks', ms=6, label='Unite constant w = -0.764')
ax.set_xlabel('w0 (fit)'); ax.set_ylabel('wa (fit)'); ax.legend(fontsize=8); ax.set_title('Where the exponential potential lands in the CPL plane')
fig.savefig(RESULTS / 'nb01_lambda_scan.png', dpi=130, bbox_inches='tight'); print('figure: results/nb01_lambda_scan.png'); plt.show()
'''))

    # ---- 6 results
    cells.append(md(r"""
## 6. This notebook's results

Everything this notebook writes lives under `results/` and is committed as the evidence:

- `results/nb01_exp_lambda0.5.csv`, `results/nb01_exp_lambda1.csv`, `results/nb01_exp_lambda1.5.csv`,
  `results/nb01_exp_lambda2.csv`, `results/nb01_exp_lambda3_scaling.csv` — Model A, exponential potential;
- `results/nb01_invpower_alpha1.csv`, `results/nb01_invpower_alpha1_n0-25.csv` — inverse power, two starts;
- `results/nb01_pngb_f1.csv`, `results/nb01_pngb_f0.5.csv`, `results/nb01_hilltop_mu3.csv`, `results/nb01_const.csv`;
- `results/nb01_cpl_exp_lambda1.csv`, `results/nb01_cpl_exp_lambda2_hand.csv` — Model A′;
- `results/nb01_cpl_fits.csv` — the CPL fit table of 5.6; `results/nb01_lambda_scan.csv` — the scan of 5.9;
- `results/nb01_w_of_a_exp.png`, `results/nb01_w_of_a_other.png`, `results/nb01_w_of_a_cpl.png`,
  `results/nb01_caldwell_linder.png`, `results/nb01_lambda_scan.png` — the figures.

The solver's CSVs are plain text: the cell below reads the fit table back with Python's `csv`
module alone (no numpy, no solver), as anyone can, and prints it.
"""))
    cells.append(code(r'''
import csv
with open(RESULTS / 'nb01_cpl_fits.csv', newline='') as f:
    rows = list(csv.DictReader(f))
print(f'{len(rows)} rows, columns: {", ".join(rows[0].keys())}')
for r in rows:
    print(f"{r['run']:46s} w0 = {float(r['w0_fit']):+.4f}  wa = {float(r['wa_fit']):+.4f}  w0+wa = {float(r['w0_plus_wa']):+.4f}  class = {r['class']}")
'''))

    # ---- 7 answers
    cells.append(md(r"""
## 7. The questions, answered from the numbers

**Which λ of the exponential potential comes closest to Unite's `(w0, wa) = (−0.861, −0.60)`?**
Of the five values run, `λ = 1.5`: its fit is `(w0, wa) = (−0.618, −0.502)`, at a distance of
0.263 from Unite's point in the `(w0, wa)` plane; `λ = 1` is next (`(−0.844, −0.217)`, distance
0.383).  No single `λ` matches both numbers: `λ = 1` reproduces `w0` (−0.844 against −0.861) but
only a third of the slope, `λ = 1.5` reproduces most of the slope but has `w0 = −0.62`.  The
finer scan of 5.9 puts the minimum of the distance at `λ = 1.4` (`(−0.674, −0.435)`, distance
0.249), and the fitted `wa` reaches exactly −0.60 at `λ ≈ 1.64`, where `w0 ≈ −0.53`.  A thawing
exponential field with the frozen start therefore gives Unite's *sign pattern* (`w0 > −1`,
`wa < 0`) and can give either Unite number, but not the pair.

**Is `|wa| = 0.6` reachable while `w` never drops below −1?**  Yes.  Every Model A run has
`min w = −1.000000` (the frozen start) and never less — the null energy condition
`ρ + P = 2 KE ≥ 0` forbids it — yet `λ = 1.5` fits `wa = −0.50`, `λ ≈ 1.64` fits `wa = −0.60`
and `λ = 2` fits `wa = −0.84`.  The fitted line extrapolates to `w0 + wa = −1.12` (`λ = 1.5`) and
`−1.04` (`λ = 2`) at `a = 0`, below the phantom divide, while the true `w(a = 0.3)` there is
`−0.963` (`λ = 1.5`), `≈ −0.95` (`λ ≈ 1.64`) and `−0.836` (`λ = 2`): the "phantom past" of the CPL
fit is the straight line leaving the curved `w(a)`, which is concave over the supernova range
(it rises slowly from −1 and then faster), not a measurement of `w < −1`.  A thawing canonical
field with `w0 + wa < −1` in the CPL extrapolation is what these numbers show.

**The other potentials.**  The inverse power (α = 1) does not join its tracker from a frozen
start even from `N0 = −25`; it thaws to `w(1) = −0.753` with `wa ≈ +0.06` (mixed), nowhere near
Unite's slope.  The PNGB potentials thaw mildly (`f = 1`: `(−0.989, −0.017)`; `f = 0.5` from
`φ_i = 0.3`: `(−0.884, −0.182)`), the hilltop with `μ = 3` is still almost frozen
(`(−0.999, −0.001)`), the control is `w = −1` to machine precision.  `λ = 3` is not a
dark-energy model at all: on its scaling attractor it carries `Ω_φ = 0.34 ≈ 3/λ²` with
`w ≈ 0` today and no acceleration.  On the Unite CPL background (Model A′) `λ = 1` gives
`(−0.837, −0.226)`, essentially the self-consistent result, and `λ = 2` cannot carry
`Ω_DE = 0.70` (it saturates at 0.50) — a test field with `λ² > 3` scales with the background.

The cell below re-derives every number quoted in this section from the tables above and
fails if the text has gone stale.
"""))
    cells.append(code(r'''
F = {r['run']: r for r in fits01}
closest = min((r for r in fits01 if r['run'].startswith('exp lambda=') and 'scaling' not in r['run']), key=lambda r: r['dist_to_unite'])
print('closest of the five exponential runs:', closest['run'], f"(w0, wa) = ({closest['w0_fit']:+.4f}, {closest['wa_fit']:+.4f}), distance {closest['dist_to_unite']:.4f}")
assert closest['run'] == 'exp lambda=1.5' and abs(closest['w0_fit'] + 0.618) < 2e-3 and abs(closest['wa_fit'] + 0.502) < 2e-3 and abs(closest['dist_to_unite'] - 0.263) < 2e-3
assert abs(F['exp lambda=1']['w0_fit'] + 0.844) < 2e-3 and abs(F['exp lambda=1']['wa_fit'] + 0.217) < 2e-3 and abs(F['exp lambda=1']['dist_to_unite'] - 0.383) < 2e-3
assert scan[scan[:, 3].argmin(), 0] == 1.4 and abs(lam_wa06 - 1.64) < 0.01
assert all(abs(r['w_min'] + 1.0) < 1e-6 for r in fits01 if r['model'] == 'scalar-flrw'), 'no Model A run may go below w = -1'
assert abs(F['exp lambda=1.5']['w0_plus_wa'] + 1.12) < 5e-3 and abs(F['exp lambda=2']['w0_plus_wa'] + 1.04) < 5e-3
assert abs(F['exp lambda=1.5']['w_a03'] + 0.963) < 2e-3 and abs(F['exp lambda=2']['w_a03'] + 0.836) < 2e-3 and abs(F['exp lambda=2']['wa_fit'] + 0.84) < 5e-3
assert abs(F['invpower alpha=1 (N0=-7)']['w_a1'] + 0.753) < 2e-3 and F['invpower alpha=1 (N0=-7)']['class'] == 'mixed'
assert abs(F['exp lambda=3 (scaling; --no-normalize v0=1e6)']['omega_today'] - 0.34) < 5e-3
assert abs(F["A' cpl exp lambda=1"]['w0_fit'] + 0.837) < 2e-3 and abs(F["A' cpl exp lambda=2 (hand v0=10, Omega 0.50)"]['omega_today'] - 0.50) < 5e-3
assert F['const (control)']['class'] == 'constant'
print('every number quoted in section 7 agrees with the tables')
'''))
    cells += closing_cells(name, 8)
    build(NOTEBOOKS / f"{name}.ipynb", ["scalar-flrw", "scalar-cpl"], cells)


# ==============================================================================================
# Notebook 02: fable, Model B
# ==============================================================================================

def notebook_02():
    name = "02_fable_spinor"
    cells = []
    cells.append(md(r"""
# fable: a 16-component spinor field as dark matter and dark energy

This notebook integrates **Model B**: the real 16-component spinor field `fable`, homogeneous on
the observed sheet, in the standard 4-dimensional reference model, where its scalar bilinear
`s = Ψᵀ σ16 Ψ` dilutes exactly as `s ∝ a^{−3}` and its equation of state is the algebraic
function `w = s V′(s)/V(s) − 1` of the self-interaction potential `V(s)`.  Six potentials are
run with the Rust solver `fable_cosmo` (pure-Rust SUNDIALS 7.8.0 CVODE): the author's mass term
(dust, exactly), a mass term plus a bare cosmological constant, power laws, and three potentials
whose slope changes sign, which take `w` across the phantom divide without any wrong-sign
kinetic term.  For each run: `w(a)`, the crossing of `w = −1` compared with its analytic
location, the CPL fit over the supernova range, the Caldwell–Linder class, a scipy DOP853
cross-check, and for the reference case the three-integrator comparison against Mathematica.
The last section answers, from the numbers, which potential gives a genuine phantom phase in
the past with `w(1) ≈ −0.86`, and what its fitted `(w0, wa)` are.
"""))
    cells.append(md(SECTION_1))
    cells.append(md(SECTION_2))
    cells.append(md(r"""
## 3. The field, its Lagrangian and its energy-momentum tensor

**On the 8-dimensional pre-universe (what Part VI of the Mathematica notebook proves).**  The
setting is the 4+4 pre-universe with coordinates `X = {x0, …, x7}`, flat metric
`eta = diag(+,+,+,+,−,−,−,−)`, the canonical frame `e = diag(Tan[6Hx0], q, q, q, 1, p, p, p)`
(`q = e^{−a4[Hx4]}/Sin[6Hx0]^{1/6}`, `p = e^{+a4[Hx4]}/Sin[6Hx0]^{1/6}`), `Sqrt[det g] = Sec[6Hx0]`,
observer time `t ≡ x4`, observed 3-space `(x1, x2, x3)`; `a4` is never given a value.

`fable ≡ Ψ(x)` is a real 16-component spinor on the 8-manifold, transforming under `Spin(4,4)`
exactly as the model's `Ψ16` of Section 11 of the Mathematica notebook, with its Dirac matrices
`T16[a]`, the symmetric spinor metric `σ16` (`σ16 . T16[a]` antisymmetric), curved Dirac
matrices `gamma^μ = coframe[[a, μ]] T16[a]`, the scalar bilinear `s ≡ Ψᵀ σ16 Ψ`, and a
self-interaction potential `V(s)`:

    L_Ψ = Sqrt[det g] · L̂_Ψ,     L̂_Ψ = (1/H) Ψᵀ σ16 gamma^μ D_μ Ψ − V(s),     D_μ = ∂_μ + Gamma^spin_μ.

On the canonical frame the spin-connection term vanishes identically in `L̂_Ψ` (Part V of the
notebook: a property of that frame, whose connection has no totally antisymmetric part), so
there `L̂_Ψ = (1/H) Ψᵀ σ16 gamma^μ ∂_μ Ψ − V(s)`.  The author's own `La` of Section 11 is the
case `V(s) = −(2M/H) s` on the flat frame: a fidelity anchor that Part VI checks, together with
its Euler–Lagrange equations `eLa`.

*Field equation.*  Varying `Ψ` (kinetic matrix `σ16 . gamma^μ` antisymmetric, mass matrix
`σ16` symmetric):

    gamma^μ ∂_μ Ψ + ½ (1/Sqrt[g]) ∂_μ(Sqrt[g] gamma^μ) Ψ = H V′(s) Ψ ,

and since `(1/Sqrt[g]) ∂_μ(Sqrt[g] gamma^μ) = [gamma^μ, Gamma^spin_μ]`, on the canonical frame
this is exactly the Levi-Civita covariant Dirac equation `gamma^μ D_μ Ψ = H V′(s) Ψ`.  The
divergence term is `−3H Cot[6Hx0]² T16[0] Ψ` on this geometry (and `(3/2) H_obs gamma^4 Ψ` in
FLRW), so a spinor homogeneous in every coordinate but `x4` is **not** a solution; the rescaling
`Ψ = Sqrt[Sin[6Hx0]] Ψ′` removes the term exactly, and `Ψ′ = Ψ′(x4)` is then an exact solution
when `V′` is constant (the mass term and the `lambda-mass` term).

*Energy–momentum tensor.*  Frame variation of the covariant action (the variation of the spin
connection gives an antisymmetric term that drops from the symmetrised tensor):

    T_{μν} = −(1/2H) ( Ψᵀ σ16 gamma_μ D_ν Ψ + Ψᵀ σ16 gamma_ν D_μ Ψ ) + g_{μν} L̂_Ψ,     gamma_μ = g_{μν} gamma^ν .

Part VI asserts it is symmetric and conserved on shell for a generic `Ψ(x0, x4)`, that the
tensor built with `∂_ν` instead of `D_ν` has the same diagonal (so the same `ρ` and `P`) but
differs off the diagonal, and, for a field homogeneous on the observed sheet, on shell:

    K_Ψ ≡ (1/H) Ψᵀ σ16 gamma^4 ∂_4 Ψ      (kinetic bilinear along the observer's time)
    K_h ≡ −(1/H) Ψᵀ σ16 gamma^0 ∂_0 Ψ     (kinetic bilinear along the hidden coordinate)
    U_Ψ ≡ V(s)                            (potential energy)

    L̂_Ψ = s V′(s) − V(s),      ρ_Ψ = V(s) + K_h,      P_Ψ = s V′(s) − V(s),      w ≡ w_Ψ = P_Ψ / ρ_Ψ .

`K_h = 0` for `Ψ = Sqrt[Sin[6Hx0]] Ψ′(x4)` (the identity `Ψ′ᵀ σ16 T16[0] Ψ′ = 0`), and then
`ρ_Ψ = V(s)` and `w_Ψ = s V′(s)/V(s) − 1`; `ρ_Ψ > 0` requires `V(s) > 0`.  Three results follow:
**the author's mass term is dust** (`V = −(2M/H) s`: `w = 0` identically, the spinor of the
original model promoted to a cosmological field is pressureless cold dark matter); **`w_Ψ` is
not bounded below by −1** (`w = n − 1` for `V ∝ s^n`, and a potential whose slope changes sign
at `s*` with `V(s*) > 0` lets `w` cross the phantom divide with no wrong-sign kinetic term, the
classical mechanism of the spinor quintom; the stability of perturbations is not examined
here); and **no dilution on the pre-universe**, `ds/dx4 = 0` exactly (Model E).

**The 4-dimensional reference model (what this notebook integrates).**  On a separate FLRW frame
`diag(1, a(t), a(t), a(t), 1, 1, 1, 1)` — never a substitution into the canonical frame — the
Dirac equation carries `(3/2) H_obs gamma^4` and gives `d(a³ s)/dt = 0`, i.e. `s = s0 a^{−3}`;
then `w_Ψ(a) = s V′(s)/V(s) − 1` on `s = s0 a^{−3}` and the whole history is fixed by `V`.
That is Model B.  The framework has no gravitational sector, so the Friedmann equation used to
give `H` is the reference model's, not a result of the 8-manifold.
"""))
    cells.append(md(r"""
## 4. The equations of motion

Units as in every FLRW model here: `M_pl² = 1/(8πG) = 1`, `H0 = 1`, `a0 = 1`, `ρ_crit,0 = 3`,
`ρ_m = 3 Ω_m0 e^{−3N}`, `ρ_r = 3 Ω_r0 e^{−4N}` with `Ω_m0 = 0.3`, `Ω_r0 = 8.4e−5`, `N = ln a`.
The spinor's bilinear obeys `d(a³ s)/dt = 0`, and the Friedmann equation closes the system with
`ρ_Ψ = V(s)`:

    H² = Ω_m0 e^{−3N} + Ω_r0 e^{−4N} + V(s)/3 .

### 4.1 The first-order system actually handed to SUNDIALS

The state vector is `y = (s, t)`, the independent variable `N`; `models.rs` integrates
(`rhs_spinor_flrw`)

    ds/dN = −3 s                     (exact: d(a³ s)/dt = 0)
    dt/dN = 1 / H(N, s)

with CVODE BDF, Newton, dense finite-difference Jacobian, `rtol = 1e−10`, `atol = 1e−12`,
`CVodeSetStopTime`, 701 equally spaced outputs (`CV_NORMAL`).  The first equation has the
closed solution `s = s_today e^{−3N}`; integrating it numerically is deliberate — it is the
integrator that is being tested, and its error on `s` (a few parts in 10⁸ by `N = 0`) is what
the cross-checks below see.

*Initial conditions.*  `s_today = 1` at `a = 1` (`--param s_today=…` overrides), so
`s_i = e^{−3 N0}` at `N0 = −7` (`s_i = 1.3e9`); `t` starts at 0 and the age
`t_age(N0) = 1/(2 H(N0))` is added analytically.

*Normalisation.*  `V → kV` with `V(s_today) = 3 Ω_Ψ0 = 3 (1 − Ω_m0 − Ω_r0) = 2.099748`; this
rescaling leaves `w(s) = s V′/V − 1` unchanged exactly.  `--no-normalize` keeps the parameters
as given (the reference case below is run that way, with `V(1) = 2.0996` by choice of its
parameters).  The solver exits with code 1 and a one-line reason if `V(s) ≤ 0` at the start or
at any output point: `ρ_Ψ = V(s)` must be positive on the whole run.

*Potentials* (`potentials.rs`, all parameters positive):

| name | `V(s)` | `w_Ψ(s)` | with `s = s0 a^{−3}` |
|---|---|---|---|
| `mass` | `m s` | `0` | dust at all times (the author's model) |
| `lambda-mass` | `V0 + m s` | `−V0/(V0 + m s)` | dust early → −1 late; `V0` is a bare cosmological constant in the action, `Ω_Λ = V(0)/3` is reported separately |
| `power` | `m s + λ s^n` | `(m s + nλ s^n)/(m s + λ s^n) − 1` | for `n < 1`: dust → `n − 1` (accelerating for `n < 2/3`) |
| `hilltop` | `V0 − μ (s − s*)²` | `−2μ s (s − s*)/V − 1` | crosses −1 at `s = s*`; unbounded below: valid only on `s < s* + Sqrt[V0/μ]`, i.e. late times |
| `lorentz` | `V0 + m s/(1 + (s/s1)²)` | `m s(1 − u)/((1+u)² V) − 1`, `u = (s/s1)²` | positive everywhere; phantom for `s > s1`, crosses −1 at `s = s1` |
| `expdamp` | `V0 + m s e^{−s/s1}` | `m s e^{−s/s1}(1 − s/s1)/V − 1` | bounded below by `V0`; the same crossing at `s = s1` |

Since `s = s0 a^{−3}`, a crossing at `s = s1` happens at the scale factor `a_c = (s1/s0)^{−1/3}`:
that is the analytic value the numerical crossing is checked against.

*Outputs per point*: `a, z, N, t, s, H, K_Psi (= sV′), U_Psi (= V), rho_Psi, P_Psi, w_Psi,
Omega_Psi, Omega_m, Omega_r, q_dec`.
"""))
    cells.append(md(r"""
## 5. Running the solver

The binary is `rust/fable_cosmo/target/release/fable_cosmo` (`.exe` on Windows).  For Model B
the command line is

    fable_cosmo spinor-flrw --potential NAME [--param KEY=VALUE ...] [--n0 X0] [--n1 X1] [--points K]
                [--out FILE.csv] [--no-normalize] [--rtol R] [--atol A]

with defaults `--n0 -7 --n1 0 --points 701`; the CSV header names every column; stderr carries
the initial conditions, the `# stats:` line, the potential after normalisation and the version;
exit code 0 is success, 1 a solver or physics error with a one-line reason, 2 a usage error.

The next cell locates the binary, checks that it runs, and defines the helpers: `run_solver`,
the Python copies of the potentials (used by the cross-checks with the parameters the solver
printed after normalisation), the CPL fit, the class, the crossing finder, the plots and the
scipy re-integration.  Nothing is random; every number is reproducible.
"""))
    cells.append(code(SETUP_CODE))

    cells.append(md(r"""
### 5.1 The mass term: dust, exactly

`V = m s` is the author's mass term promoted to a potential.  `w = s V′/V − 1 = 0` identically,
so the run must give `w = 0` at every one of the 701 points to `1e−14` (the assertion makes the
notebook fail otherwise), and `ρ_Ψ = V ∝ a^{−3}`: cold dark matter.
"""))
    cells.append(code(r'''
d = run_solver('nb02_mass', 'spinor-flrw', '--potential', 'mass', label='mass (dust)')
print(f'\nmax |w| over the run = {np.abs(d["w_Psi"]).max():.1e};  Omega_Psi(a=1) = {d["Omega_Psi"][-1]:.6f};  rho_Psi a^3 / rho_Psi(1): min {(d["rho_Psi"] * d["a"]**3 / d["rho_Psi"][-1]).min():.10f}, max {(d["rho_Psi"] * d["a"]**3 / d["rho_Psi"][-1]).max():.10f}')
assert np.abs(d['w_Psi']).max() <= 1e-14, 'the mass term must be dust, w = 0 exactly'
'''))
    cells.append(md(r"""
### 5.2 `lambda-mass`: dust plus a bare cosmological constant

`V = V0 + m s` with `V0 = 0.7`, `m = 0.3` before normalisation (the ratio is what matters).  The
field is dust early and `w → −1` late, but the `V0` is a **bare cosmological constant in the
action**, present with or without the spinor: this is ΛCDM with the dust supplied by the
spinor, not field-driven dark energy.  The cell therefore reports `Ω_Λ ≡ V(0)/3` separately
from the dust part `m s0/3`; their sum is the field's `Ω_Ψ(a = 1) = 0.699916`.
"""))
    cells.append(code(r'''
d = run_solver('nb02_lambda-mass', 'spinor-flrw', '--potential', 'lambda-mass', '--param', 'v0=0.7', '--param', 'm=0.3', label='lambda-mass v0=0.7 m=0.3')
p = RUNS['nb02_lambda-mass']['params']
omega_lambda = p['v0'] / 3.0
omega_dust = p['m'] * 1.0 / 3.0
print(f'\nafter normalisation: V0 = {p["v0"]:.6f}, m = {p["m"]:.6f}')
print(f'Omega_Lambda = V(0)/3 = {omega_lambda:.6f}   (a bare cosmological constant in the action)')
print(f'Omega_dust   = m s0/3 = {omega_dust:.6f}   (the spinor, s0 = 1)')
print(f'sum = {omega_lambda + omega_dust:.6f} = Omega_Psi(a=1) = {d["Omega_Psi"][-1]:.6f};   w(a=1) = {d["w_Psi"][-1]:+.6f} = -V0/(V0 + m s0) = {-p["v0"] / (p["v0"] + p["m"]):+.6f}')
assert abs(omega_lambda + omega_dust - d['Omega_Psi'][-1]) < 1e-6   # Omega_Psi(1) carries CVODE's ~5e-8 error on s(N=0)
'''))
    cells.append(md(r"""
### 5.3 Power laws: `V = m s + λ s^n`, n = 0.236, 0.5, 0.9

With `m = λ` (the solver's defaults, rescaled together) the field is dust while `m s ≫ λ s^n`
and tends to `w = n − 1` as `s → 0`.  `n = 0.236` gives Unite's constant-w value
`n − 1 = −0.764` **at late times**; at `a = 1` the mass term still carries half the potential
(`w(1) = (1 + n)/2 − 1 = −0.382`).  To check the asymptote the `n = 0.236` case is also run
into the future, to `N = +6` (`a = e⁶ ≈ 400`), where `m s/(λ s^n) ≈ 1e−6` and `w` must equal
`−0.764` to better than `1e−5` — asserted.
"""))
    cells.append(code(r'''
for n in [0.236, 0.5, 0.9]:
    d = run_solver(f'nb02_power_n{n}', 'spinor-flrw', '--potential', 'power', '--param', f'n={n}', label=f'power n={n}')
    print(f'  -> w(a=1) = {d["w_Psi"][-1]:+.5f}  (n - 1 = {n - 1:+.3f});  w(a=0.1) = {w_at(d["a"], d["w_Psi"], 0.1):+.5f}\n')
d = run_solver('nb02_power_n0.236_future', 'spinor-flrw', '--potential', 'power', '--param', 'n=0.236', '--n1', '6', '--points', '1301',
               label='power n=0.236 to a=e^6')
print(f'  -> w(N=+6) = {d["w_Psi"][-1]:+.8f};  w + 0.764 = {d["w_Psi"][-1] + 0.764:+.2e};  s(N=6) = {d["s"][-1]:.3e}')
assert abs(d['w_Psi'][-1] + 0.764) < 1e-5, 'the n = 0.236 power law must approach w = -0.764 at late times'
'''))
    cells.append(md(r"""
### 5.4 The potentials that cross the phantom divide: `lorentz`, `expdamp`, `hilltop`

`lorentz` (`V0 = 1`, `m = 1`, `s1 = 1.5`, normalised) is positive everywhere.  `expdamp` with
`(V0, m, s1) = (1.566, 0.839, 2.21)` and `--no-normalize` is **the reference case** (its
Mathematica twin is compared in 5.9); it is also run with `s1 = 1.5` and `s1 = 3.0`, normalised.
All of them cross `w = −1` at `s = s1`, i.e. at `a_c = s1^{−1/3}` since `s0 = 1`.

`hilltop` (`V0 = 1`, `μ = 0.05`, `s* = 1.5`) is unbounded below: `V < 0` for
`s > s* + Sqrt[V0/μ]`, so from the default start at `N0 = −7` (`s = 1.3e9`) the solver must
refuse, with exit code 1 and a one-line reason — we catch the non-zero exit and print the
reason, then run it inside its window, from `--n0 -0.5` (`a = 0.61`, `s = 4.5`).
"""))
    cells.append(code(r'''
run_solver('nb02_lorentz', 'spinor-flrw', '--potential', 'lorentz', '--param', 'v0=1', '--param', 'm=1', '--param', 's1=1.5', label='lorentz v0=1 m=1 s1=1.5')
print()
d = run_solver('nb02_expdamp_ref', 'spinor-flrw', '--potential', 'expdamp', '--param', 'v0=1.566', '--param', 'm=0.839', '--param', 's1=2.21', '--no-normalize',
               label='expdamp (1.566, 0.839, 2.21) reference')
i = int(d['w_Psi'].argmin())
print(f'  -> w(a=1) = {d["w_Psi"][-1]:+.5f};  min w = {d["w_Psi"][i]:+.5f} at a = {d["a"][i]:.4f} (z = {d["z"][i]:.3f});  V(1) = {d["U_Psi"][-1]:.6f};  Omega_Psi(1) = {d["Omega_Psi"][-1]:.6f};  min V = {d["U_Psi"].min():.4f}\n')
run_solver('nb02_expdamp_s1.5', 'spinor-flrw', '--potential', 'expdamp', '--param', 'v0=1.566', '--param', 'm=0.839', '--param', 's1=1.5', label='expdamp s1=1.5')
print()
run_solver('nb02_expdamp_s3', 'spinor-flrw', '--potential', 'expdamp', '--param', 'v0=1.566', '--param', 'm=0.839', '--param', 's1=3.0', label='expdamp s1=3.0')
print()
r = run_solver('nb02_hilltop_default_start', 'spinor-flrw', '--potential', 'hilltop', '--param', 'v0=1', '--param', 'mu=0.05', '--param', 'sstar=1.5', expect_failure=True)
assert r.returncode == 1, 'the hilltop must fail from the default start'
print()
d = run_solver('nb02_hilltop', 'spinor-flrw', '--potential', 'hilltop', '--param', 'v0=1', '--param', 'mu=0.05', '--param', 'sstar=1.5', '--n0', '-0.5',
               label='hilltop v0=1 mu=0.05 s*=1.5 (from N0=-0.5)')
p = RUNS['nb02_hilltop']['params']
print(f'  -> window of validity s < s* + sqrt(V0/mu) = {p["sstar"] + np.sqrt(p["v0"] / p["mu"]):.4f}, i.e. a > {(p["sstar"] + np.sqrt(p["v0"] / p["mu"])) ** (-1/3):.4f};  the run starts at a = {d["a"][0]:.4f}, s = {d["s"][0]:.4f};  w(a=1) = {d["w_Psi"][-1]:+.5f}')
'''))
    cells.append(md(r"""
### 5.5 The shapes of `V(s)` and `w(s)`

Before the histories, the potentials themselves with the parameters the solver used (after
normalisation): `V(s)` on the left, `w(s) = s V′/V − 1` on the right, both against `s` on a
logarithmic axis with today (`s = 1`) marked.  Where `V′` changes sign `w` crosses −1; where
`V′ < 0` the field is phantom.
"""))
    cells.append(code(r'''
SP_RUNS = ['nb02_mass', 'nb02_lambda-mass', 'nb02_power_n0.236', 'nb02_power_n0.5', 'nb02_power_n0.9', 'nb02_lorentz', 'nb02_expdamp_ref', 'nb02_expdamp_s1.5', 'nb02_expdamp_s3', 'nb02_hilltop']
s_grid = np.geomspace(1e-2, 1e2, 600)
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12.5, 4.4))
for n in SP_RUNS:
    V, dV = spinor_potential(RUNS[n]['pot'], RUNS[n]['params'])
    v = V(s_grid); ok = v > 0
    ax1.plot(s_grid[ok], v[ok], lw=1.2, label=RUNS[n]['label'])
    ax2.plot(s_grid[ok], (s_grid * dV(s_grid) / v - 1.0)[ok], lw=1.2, label=RUNS[n]['label'])
for ax in (ax1, ax2):
    ax.set_xscale('log'); ax.axvline(1.0, color='k', lw=0.5, ls=':'); ax.set_xlabel('s = s0 a^-3   (s = 1 today, s = 8 at z = 1)')
ax1.set_yscale('log'); ax1.set_ylabel('V(s)'); ax1.set_title('the potentials after normalisation (V > 0 shown)')
ax2.axhline(-1.0, color='k', lw=0.5); ax2.set_ylim(-2.0, 0.2); ax2.set_ylabel('w(s) = s V\'(s)/V(s) - 1'); ax2.set_title('the equation of state as a function of s')
ax1.legend(fontsize=7); fig.savefig(RESULTS / 'nb02_potentials.png', dpi=130, bbox_inches='tight'); print('figure: results/nb02_potentials.png'); plt.show()
'''))
    cells.append(md(r"""
### 5.6 `w(a)` for every run, and the Caldwell–Linder plane

As for the scalar field: the whole run on a logarithmic `a` axis with Unite's CPL line
extrapolated, then the supernova range with each run's own CPL fit dashed, Unite's line
dotted and the constant-w fit dash-dotted.  The dust-like family first, then the family that
crosses the phantom divide.  In the Caldwell–Linder plane the phantom runs sit at `w < −1`
in the past and rise through the divide towards today: their `dw/dN` changes sign over the fit
range, so they are `mixed` by the sign rule.
"""))
    cells.append(code(r'''
entries = lambda names: [(RUNS[n]['label'], RUNS[n]['table'], 'w_Psi') for n in names]
DUST_RUNS = SP_RUNS[:5]
PHANTOM_RUNS = SP_RUNS[5:]
plot_w_of_a(entries(DUST_RUNS), 'nb02_w_of_a_dust.png', 'Model B, dust-like potentials', ylim=(-1.05, 0.1))
plot_w_of_a(entries(PHANTOM_RUNS), 'nb02_w_of_a_phantom.png', 'Model B, potentials that cross w = -1', ylim=(-1.6, -0.6))
plot_caldwell_linder(entries(SP_RUNS[1:9]), 'nb02_caldwell_linder.png', "Caldwell-Linder plane, w' versus w over 0.3 <= a <= 1")
'''))
    cells.append(md(r"""
### 5.7 The crossing of `w = −1`, numerical versus analytic

`crossings` finds every sign change of `w + 1` on the 701-point grid and locates the root with
a local degree-6 polynomial through the eight surrounding points; the analytic value is
`a_c = (s1/s_today)^{−1/3}` (`(s*/s_today)^{−1/3}` for the hilltop).  The difference must be
below `1e−6` for `lorentz` and `expdamp` — asserted; it is in fact about `1e−8`, the size of
CVODE's error on `s` at `rtol = 1e−10`.  `V > 0` on the whole run is checked at the same time.
The table is written to `results/nb02_crossings.csv`.
"""))
    cells.append(code(r'''
cross_rows = []
for n in SP_RUNS:
    d = RUNS[n]['table']; p = RUNS[n]['params']
    s_c = p.get('s1', p.get('sstar'))
    a_num = crossings(d['N'], d['w_Psi'])
    a_ana = float(s_c ** (-1.0 / 3.0)) if s_c is not None else float('nan')
    err = abs(a_num[0] - a_ana) if a_num and s_c is not None else float('nan')
    cross_rows.append({'run': RUNS[n]['label'], 'a_cross_numeric': a_num[0] if a_num else float('nan'), 'a_cross_analytic': a_ana, 'abs_error': err,
                       'n_crossings': len(a_num), 'min_V': float(d['U_Psi'].min())})
    print(f"{RUNS[n]['label']:44s} crossings: {len(a_num):d}  a_c numeric = {cross_rows[-1]['a_cross_numeric']:.9f}  analytic = {a_ana:.9f}  |diff| = {err:.2e}   min V = {d['U_Psi'].min():.4f}")
    assert d['U_Psi'].min() > 0.0
    if RUNS[n]['pot'] in ('lorentz', 'expdamp'):
        assert len(a_num) == 1 and err < 1e-6, f'{n}: the crossing must agree with (s1/s0)^(-1/3) to 1e-6'
with open(RESULTS / 'nb02_crossings.csv', 'w', newline='') as f:
    wr = csv.DictWriter(f, fieldnames=list(cross_rows[0].keys())); wr.writeheader(); wr.writerows(cross_rows)
print('written: results/nb02_crossings.csv')
'''))
    cells.append(md(r"""
### 5.8 The CPL fit table

For every run: the unweighted least-squares fit of `w(a)` to `w0 + wa (1 − a)` over
`0.3 ≤ a ≤ 1`, the extrapolation `w0 + wa`, the true `w(a = 0.3)`, `w(1)` and `min w`, the
class, `Ω_Ψ` today and the distance from Unite's point, next to Unite's `(−0.861, −0.60,
−1.461)` and the constant-w fit `−0.764`, written to `results/nb02_cpl_fits.csv`.  The
hilltop run starts at `a = 0.61`, so its fit covers `0.61 ≤ a ≤ 1` only and its `w(0.3)` is
undefined (NaN).  A straight line is a poor description of a `w(a)` that dips to −1.3 and
comes back, which is why the phantom runs' `w0 + wa` differ so much from their `min w`.
"""))
    cells.append(code(r'''
fits02 = [fit_row(n, 'w_Psi') for n in SP_RUNS]
fit_table(fits02, RESULTS / 'nb02_cpl_fits.csv')
'''))
    cells.append(md(r"""
### 5.9 Cross-check: every run re-integrated with scipy (DOP853, rtol = 1e−11)

For Model B the scipy system is `ds/dN = −3 s`, `dt/dN = 1/H(N, s)` with the potential as
normalised by the solver; `w` is then the algebraic `s V′(s)/V(s) − 1` of scipy's `s`.  The
cell prints `max |w_rust − w_scipy|` and `max |t_rust − t_scipy|` for every run and fails if a
difference in `w` exceeds `1e−6`.  The differences of a few parts in 10⁸ are CVODE's error on
`s` at `rtol = 1e−10` amplified by the slope `dw/ds` near the phantom dip.
"""))
    cells.append(code(r'''
xcheck02 = {}
for n in SP_RUNS + ['nb02_power_n0.236_future']:
    dw, dt, _ = scipy_spinor(n)
    xcheck02[n] = dw
    print(f'{RUNS[n]["label"]:44s} max|w_rust - w_scipy| = {dw:.3e}   max|t_rust - t_scipy| = {dt:.3e}')
    assert dw < 1e-6, f'{n}: the scipy cross-check differs by {dw}'
print(f'\nlargest difference in w over all {len(xcheck02)} runs: {max(xcheck02.values()):.3e}')
'''))
    cells.append(md(r"""
### 5.10 Three integrators on the reference case: CVODE (Rust), DOP853 (scipy), NDSolve (Mathematica)

`reference/mathematica_spinor_expdamp.csv` was written by Part VI of the Mathematica notebook
(`reference/make_reference.wls`) for `expdamp (1.566, 0.839, 2.21)` without normalisation:
`s = e^{−3N}` in closed form, `t` by `NDSolve` at 24-digit working precision, on the same 701
values of `N`.  The cell compares the three on `w`, and Rust against Mathematica on `s`, `H`,
`ρ_Ψ` and `t`.
"""))
    cells.append(code(r'''
ref = np.genfromtxt(REFERENCE / 'mathematica_spinor_expdamp.csv', delimiter=',', names=True)
d = RUNS['nb02_expdamp_ref']['table']
assert ref.shape == d.shape and np.abs(ref['N'] - d['N']).max() < 1e-12, 'the reference grid must be the solver grid'
_, _, w_scipy = scipy_spinor('nb02_expdamp_ref')
threeway02 = {'rust-mathematica': float(np.abs(ref['w_Psi'] - d['w_Psi']).max()),
              'scipy-mathematica': float(np.abs(ref['w_Psi'] - w_scipy).max()),
              'rust-scipy': float(np.abs(d['w_Psi'] - w_scipy).max())}
for k, v in threeway02.items():
    print(f'max |w difference| {k:18s} = {v:.3e}')
for c in ['s', 'H', 'rho_Psi', 't']:
    print(f'max relative |{c} rust - mathematica| = {(np.abs(ref[c] - d[c]) / np.abs(ref[c])).max():.3e}')
print(f'w(a=1): rust {d["w_Psi"][-1]:.12f}  scipy {w_scipy[-1]:.12f}  mathematica {ref["w_Psi"][-1]:.12f}')
assert threeway02['rust-mathematica'] < 1e-6 and threeway02['rust-scipy'] < 1e-6
'''))
    cells.append(md(r"""
## 6. This notebook's results

Everything this notebook writes lives under `results/`:

- `results/nb02_mass.csv`, `results/nb02_lambda-mass.csv`, `results/nb02_power_n0.236.csv`,
  `results/nb02_power_n0.5.csv`, `results/nb02_power_n0.9.csv`, `results/nb02_power_n0.236_future.csv`;
- `results/nb02_lorentz.csv`, `results/nb02_expdamp_ref.csv`, `results/nb02_expdamp_s1.5.csv`,
  `results/nb02_expdamp_s3.csv`, `results/nb02_hilltop.csv` (the refused default-start hilltop writes nothing);
- `results/nb02_crossings.csv` — the crossing table of 5.7; `results/nb02_cpl_fits.csv` — the CPL table of 5.8;
- `results/nb02_potentials.png`, `results/nb02_w_of_a_dust.png`, `results/nb02_w_of_a_phantom.png`,
  `results/nb02_caldwell_linder.png` — the figures.

The cell below reads the crossing table back with Python's `csv` module alone (no numpy, no
solver) and prints it.
"""))
    cells.append(code(r'''
import csv
with open(RESULTS / 'nb02_crossings.csv', newline='') as f:
    rows = list(csv.DictReader(f))
print(f'{len(rows)} rows, columns: {", ".join(rows[0].keys())}')
for r in rows:
    print(f"{r['run']:44s} crossings = {r['n_crossings']}  a_c numeric = {float(r['a_cross_numeric']):.6f}  analytic = {float(r['a_cross_analytic']):.6f}  min V = {float(r['min_V']):.4f}")
'''))
    cells.append(md(r"""
## 7. The questions, answered from the numbers

**Which potential gives a genuine phantom phase in the past with `w(1) ≈ −0.86`, and what are
its fitted `(w0, wa)`?**  The reference `expdamp` potential, `V = V0 + m s e^{−s/s1}` with
`(V0, m, s1) = (1.566, 0.839, 2.21)`: `w(1) = −0.861`, `w` crosses −1 at `a_c = 0.7677`
(`z = 0.30`, the analytic `2.21^{−1/3}`), reaches its minimum `w = −1.302` at `a = 0.543`
(`z = 0.84`) and tends to −1 from below as `a → 0` — a *genuine* `w < −1` with `ρ_Ψ = V > 0`
everywhere (`min V = 1.566`), produced by the sign change of `V′` at `s = s1` and no wrong-sign
kinetic term.  Its unweighted CPL fit over `0.3 ≤ a ≤ 1` is `(w0, wa) = (−0.978, −0.245)`,
`w0 + wa = −1.22`; the straight line misses both the dip and today's value because `w(a)` is
strongly curved there.  The `lorentz` potential does the same with `w(1) = −0.843`, minimum
`−1.249`, crossing at `a_c = 0.8736 = 1.5^{−1/3}`, fit `(−1.052, −0.183)`.  Of every run in
this notebook the one closest to Unite's *fitted* numbers is `expdamp` with `s1 = 3.0`:
`(w0, wa) = (−0.851, −0.569)`, `w0 + wa = −1.42` (Unite: `−0.861, −0.60, −1.46`), with
`w(1) = −0.815`, a crossing at `a_c = 0.693` (`z = 0.44`) and a minimum of `−1.388` — a spinor
with a phantom past, not a straight line, reproduces the Unite CPL numbers to a few hundredths.

**Dust and Λ.**  The mass term is `w = 0` to machine precision at all 701 points (the author's
spinor is cold dark matter, exactly).  `lambda-mass` is ΛCDM in disguise: `Ω_Λ = V(0)/3 = 0.490`
is a bare constant in the action and the spinor supplies dust with `Ω = 0.210`; `w(1) = −0.700`.
The power law `n = 0.236` is dust early (`w(a = 0.1) = −0.004`), has `w(1) = −0.382` with
`m = λ`, and reaches Unite's constant-w value `−0.764` only asymptotically (`w(a = e⁶) + 0.764
= 8e−7`): field-driven dark energy, in the sense that no constant is added to the action, but
with the wrong timing unless `m ≪ λ`.  The hilltop crosses at `a_c = 0.8736` too but is valid
only for `a > 0.55`; the solver refuses it from the default start, as it must.

The cell below re-derives every number quoted in this section from the tables and fails if the
text has gone stale.
"""))
    cells.append(code(r'''
F = {r['run']: r for r in fits02}
C = {r['run']: r for r in cross_rows}
E = F['expdamp (1.566, 0.839, 2.21) reference']
d = RUNS['nb02_expdamp_ref']['table']
assert abs(E['w_a1'] + 0.861) < 1e-3 and abs(E['w_min'] + 1.302) < 1e-3 and abs(d['a'][d['w_Psi'].argmin()] - 0.543) < 2e-3
assert abs(C[E['run']]['a_cross_numeric'] - 0.7677) < 1e-4 and abs(E['w0_fit'] + 0.978) < 1e-3 and abs(E['wa_fit'] + 0.245) < 1e-3 and abs(E['w0_plus_wa'] + 1.22) < 5e-3
L = F['lorentz v0=1 m=1 s1=1.5']
assert abs(L['w_a1'] + 0.843) < 1e-3 and abs(L['w_min'] + 1.249) < 1e-3 and abs(C[L['run']]['a_cross_numeric'] - 0.8736) < 1e-4 and abs(L['w0_fit'] + 1.052) < 1e-3 and abs(L['wa_fit'] + 0.183) < 1e-3
S3 = F['expdamp s1=3.0']
closest = min(fits02, key=lambda r: r['dist_to_unite'])
assert closest['run'] == S3['run'] and abs(S3['w0_fit'] + 0.851) < 1e-3 and abs(S3['wa_fit'] + 0.569) < 1e-3 and abs(S3['w0_plus_wa'] + 1.42) < 5e-3
assert abs(S3['w_a1'] + 0.815) < 1e-3 and abs(C[S3['run']]['a_cross_numeric'] - 0.693) < 1e-3 and abs(S3['w_min'] + 1.388) < 1e-3
assert abs(omega_lambda - 0.490) < 1e-3 and abs(omega_dust - 0.210) < 1e-3 and abs(F['lambda-mass v0=0.7 m=0.3']['w_a1'] + 0.700) < 1e-3
P = RUNS['nb02_power_n0.236']['table']
assert abs(P['w_Psi'][-1] + 0.382) < 1e-3 and abs(w_at(P['a'], P['w_Psi'], 0.1) + 0.004) < 1e-3
assert abs(RUNS['nb02_power_n0.236_future']['table']['w_Psi'][-1] + 0.764) < 2e-6
assert abs(C['hilltop v0=1 mu=0.05 s*=1.5 (from N0=-0.5)']['a_cross_numeric'] - 0.8736) < 1e-4
print('closest run to Unite in the (w0, wa) plane:', closest['run'], f"({closest['w0_fit']:+.4f}, {closest['wa_fit']:+.4f}), distance {closest['dist_to_unite']:.4f}")
print('every number quoted in section 7 agrees with the tables')
'''))
    cells += closing_cells(name, 8)
    build(NOTEBOOKS / f"{name}.ipynb", "spinor-flrw", cells)


# ==============================================================================================
# Notebook 03: fableScalar on the pre-universe, Models C and D (E stated)
# ==============================================================================================

def notebook_03():
    name = "03_pre-universe_dynamics"
    cells = []
    cells.append(md(r"""
# fableScalar on the pre-universe: no friction, virial averages, and the sloshing of energy into the hidden direction

This notebook leaves the 4-dimensional reference model and integrates `fableScalar` **on the
8-dimensional pre-universe itself**, where the equations are exact consequences of the frame
of the Mathematica notebook: **Model C** (a field homogeneous in every coordinate but the
observer's time `x4`: `φ̈ = −V′(φ)`, no Hubble friction, conserved energy, undamped oscillation
with virial-average equations of state) and **Model D** (a field with a profile along the
hidden coordinate `x0`, integrated by the method of lines: energy sloshes between the `x4`
motion and the `x0`-gradient store, which on the observed sheet behaves as `w = −1`).  Both use
the Rust solver `fable_cosmo` (pure-Rust SUNDIALS 7.8.0 CVODE, Adams method for these undamped
oscillations), every run is cross-checked with scipy's DOP853, and the conserved quantities
(`ρ` for Model C, the discrete energy `E_h` for Model D) are checked to drift by less than
`1e−6` — they drift by less than `1e−8`.  **Model E**, the spinor on the pre-universe, needs no
integration at all: `ds/dx4 = 0` exactly; it is stated at the end.
"""))
    cells.append(md(SECTION_1))
    cells.append(md(SECTION_2))
    cells.append(md(r"""
## 3. The field, its Lagrangian and its energy-momentum tensor

**The 8-dimensional statement (all of it proved in Part VI of the Mathematica notebook, and
all of it exact).**  Coordinates `X = {x0, …, x7}`, flat metric `eta = diag(+,+,+,+,−,−,−,−)`,
canonical frame `e = diag(Tan[6Hx0], q, q, q, 1, p, p, p)` with `q = e^{−a4[Hx4]}/Sin[6Hx0]^{1/6}`,
`p = e^{+a4[Hx4]}/Sin[6Hx0]^{1/6}`, so that `g = diag(Tan², q², q², q², −1, −p², −p², −p²)` and

    Sqrt[det g] = Sec[6Hx0],        0 < 6Hx0 < π/2 .

The 8-volume element does not depend on `x4`: the observed 3-space `(x1, x2, x3)` scales as
`q` while the second sheet `(x5, x6, x7)` scales as `p ∝ 1/q`, and `q³p³ = 1/Sqrt[Sin[6Hx0]]`.
The observer is `u = ∂_4` (`g44 = −1`), `t ≡ x4`; the observed scale factor is `a ∝ e^{−a4[Hx4]}`
(a kinematic identification; `a4` is never given a value, here or anywhere).

`fableScalar ≡ φ(x)`, minimally coupled with potential `V(φ)`:

    L_φ = Sqrt[det g] · ( −½ g^{μν} ∂_μφ ∂_νφ − V(φ) ),        T_{μν} = ∂_μφ ∂_νφ + g_{μν} L̂_φ .

Field equation `□φ = V′(φ)`, which on the pre-universe reads

    −φ̈ + Cos[6Hx0] ∂_0( Sec[6Hx0] Cot[6Hx0]² ∂_0 φ ) + (1/q²)(∂_1²+∂_2²+∂_3²)φ − (1/p²)(∂_5²+∂_6²+∂_7²)φ = V′(φ) .

For a field of `x0` and `x4` (homogeneous on both sheets) the energies seen by the observer are

    KE = ½ φ̇²,      PE = V(φ),      G0 = ½ Cot[6Hx0]² (∂_0 φ)²,
    ρ = KE + PE + G0,      P (on the observed sheet, P_1 = P_2 = P_3) = KE − PE − G0,      w = P/ρ,

and along the hidden direction itself `P_0 = KE − PE + G0`.  Part VI asserts: `T` symmetric,
the off-shell identity `∇^μ T_{μν} = (□φ − V′) ∂_νφ`, the null energy condition `ρ + P = 2 KE ≥ 0`
(so `w ≥ −1` wherever `ρ > 0`), and the three facts this notebook is built on:

1. **No Hubble friction in x4.**  For `φ = φ(x4)` the field equation is `φ̈ = −V′(φ)`, because
   `Sqrt[g] g^{44} = −Sec[6Hx0]` is independent of `x4`.  `ρ = KE + PE` is then conserved in `x4`
   and the field oscillates undamped: `w(x4)` swings between −1 and +1, and its running average
   tends to the virial value `⟨w⟩ = (n − 1)/(n + 1)` for `V ∝ φ^{2n}`: `0` for the mass term
   (exactly, from `φ = A Cos[m x4]`, `w = −Cos[2 m x4]`), `1/3` for the quartic.  Model C.
2. **A static x0 profile is a cosmological constant on the observed sheet.**  With `V = 0`,
   `∂_0(Sec Cot² ∂_0φ) = 0` has the solution `∂_0φ = C Sin[6Hx0]²/Cos[6Hx0]`, so `G0 = C²/2` is
   constant and `ρ = G0`, `P = −G0`, `w = −1` exactly on the sheet — while along `x0` itself
   `P_0 = +G0 = +ρ`: in eight dimensions this is an anisotropic stress, not a Λ term.  The
   `x0`-gradient energy is a `w = −1` store, and Model D lets it exchange energy with the `x4`
   motion.
3. **The volume bookkeeping.**  Integrating over the hidden coordinates gives a hidden
   4-volume density `𝒱_hid ∝ a^{−3}`, so the reduced 4-density `ρ_4 ∝ a^{−3} ρ_8` is not separately
   conserved — a volume effect that holds for every `w` and is *not* a dark-matter signature;
   the locally measured `T_{44} = ρ_8` is exactly constant.  Which of the two gravitates is
   undetermined: the framework has no gravitational sector.

None of this uses a Friedmann equation.  Nothing here is a reference model: it is the field on
the frame of the notebook, with `H = 1` in the solver's units (so `0 < x0 < π/12`).
"""))
    cells.append(md(r"""
## 4. The equations of motion

**Model C** (`φ = φ(x4)`): `φ̈ = −V′(φ)`, energy `ρ = ½φ̇² + V(φ)` conserved.  Units: the notebook's
constant `H = 1`, the field dimensionless, `x4` in units of `1/m` for the mass term.

**Model D** (`φ = φ(x0, x4)`): `φ̈ = Cos[6x0] ∂_0( Sec[6x0] Cot[6x0]² ∂_0 φ ) − V′(φ)`, on a grid
`x0_j ∈ [x0_min, x0_max] ⊂ (0, π/12)` (default `[0.05, 0.22]`, i.e. `6x0 ∈ [0.3, 1.32]`) with
spacing `h`, in **flux form** with zero flux at both ends (Neumann):

    φ̈_j = Cos_j (F_{j+½} − F_{j−½})/h − V′(φ_j),        F_{j+½} = c_{j+½} (φ_{j+1} − φ_j)/h,        c = Sec Cot² at the half points.

The quantity this semi-discrete scheme conserves **exactly** (by summation by parts of the flux
form) is the discrete energy

    E_h = Σ_j Sec_j h ( ½φ̇_j² + V(φ_j) ) + Σ_{j+½} ½ c_{j+½} (φ_{j+1} − φ_j)²/h ,

and the solver reports it (`E_sheet`) and its drift (`E_drift = E_h/E_h(0) − 1`).  The
`Sec[6Hx0]` in the first sum is the volume element `Sqrt[det g]`: every sheet average is
weighted by it, and `w_sheet ≡ ⟨P⟩/⟨ρ⟩ = P_sheet/E_sheet` (never `⟨P/ρ⟩`) with
`P_sheet = KE_h − PE_h − G0_h`; the solver also reports the local `w_mid` at the middle grid
point, and the energy fractions `KE_frac, PE_frac, G0_frac` of `E_h`.

### 4.1 The first-order system actually handed to SUNDIALS

Model C (`rhs_scalar_pre`): state `y = (φ, φ̇)`, independent variable `x4`,

    dφ/dx4 = φ̇,        dφ̇/dx4 = −V′(φ) .

Model D (`rhs_scalar_pre_x0`): state `y = (φ_0, …, φ_{n−1}, φ̇_0, …, φ̇_{n−1})`, `2n` equations,

    dφ_j/dx4 = φ̇_j,        dφ̇_j/dx4 = Cos_j (F_{j+½} − F_{j−½})/h − V′(φ_j),        F_{−½} = F_{n−½} = 0 .

Both run CVODE **Adams** (the non-stiff multistep family, right for smooth undamped
oscillations; `--method bdf` overrides), Newton iteration with a dense finite-difference
Jacobian, `rtol = 1e−10`, `atol = 1e−12`, outputs at equally spaced `x4`.  Initial conditions:
Model C `φ(0) = φ_i` (default 1), `φ̇(0) = 0`; Model D the profile
`φ(x0, 0) = φ_i (1 + ε cos(mode · π (x0 − x0_min)/(x0_max − x0_min)))` at rest (`φ_i = 1`,
`mode = 1`, `ε` from `--param eps=…`).  There is no normalisation: nothing is fitted to today.
Outputs: Model C `x4, phi, phidot, KE, PE, rho, P, w, w_avg, rho_drift` (`w_avg` the running
trapezoidal average of `w` from `x4 = 0`, `rho_drift = ρ/ρ(0) − 1`); Model D `x4, phi_mid,
KE_mid, PE_mid, G0_mid, rho_mid, P_mid, w_mid, E_sheet, P_sheet, w_sheet, KE_frac, PE_frac,
G0_frac, E_drift`, plus, with `--profile-out`, a file whose first data row is the `x0` grid and
whose following rows are `x4` and `φ(x0_j, x4)`.

**Model E** (`fable` on the pre-universe): no equation to integrate — see section 7.
"""))
    cells.append(md(r"""
## 5. Running the solver

The binary is `rust/fable_cosmo/target/release/fable_cosmo` (`.exe` on Windows).  For the
pre-universe models the command line is

    fable_cosmo scalar-pre    --potential NAME [--param KEY=VALUE ...] [--n0 X0] [--n1 X1] [--points K] [--out FILE.csv]
    fable_cosmo scalar-pre-x0 --potential NAME [--param KEY=VALUE ...] [--n0 X0] [--n1 X1] [--points K] [--out FILE.csv]
                              [--grid N] [--x0min A] [--x0max B] [--profile-out FILE.csv]

where `--n0/--n1` are the `x4` range (defaults `0` and `50`), `--grid` the number of `x0` points
(default 101).  The CSV header names every column; stderr carries the `# stats:` line, the
potential and the version; exit code 0 is success, 1 a solver error, 2 a usage error.

The next cell locates the binary, checks that it runs, and defines the helpers (the same
toolbox as for the FLRW models; only `run_solver`, the potentials and scipy are used here).
"""))
    cells.append(code(SETUP_CODE))

    cells.append(md(r"""
### 5.1 Model C: the quadratic potential, `V = ½ m² φ²`, m = 1, φ_i = 1, to x4 = 100

The exact solution is `φ = Cos[x4]`, `w = −Cos[2x4]`, `ρ = ½` constant, `⟨w⟩ = 0`.  The run must
show `|ρ/ρ(0) − 1| < 1e−6` at every point and `|w_avg(100)| < 0.02` (both asserted; the run does
far better), and it is compared with the exact solution directly.
"""))
    cells.append(code(r'''
d = run_solver('nb03_modelC_quadratic', 'scalar-pre', '--potential', 'quadratic', '--param', 'm=1', '--param', 'phi_i=1', '--n1', '100', '--points', '2001',
               label='Model C quadratic m=1')
x = d['x4']
print(f'\nw_avg(x4=100) = {d["w_avg"][-1]:+.6f};  max |rho drift| = {np.abs(d["rho_drift"]).max():.2e};  w in [{d["w"].min():+.6f}, {d["w"].max():+.6f}]')
print(f'against the exact solution: max |phi - cos x4| = {np.abs(d["phi"] - np.cos(x)).max():.2e},  max |w + cos 2x4| = {np.abs(d["w"] + np.cos(2 * x)).max():.2e}')
assert np.abs(d['rho_drift']).max() < 1e-6 and abs(d['w_avg'][-1]) < 0.02
'''))
    cells.append(md(r"""
The figure: `φ(x4)` over the first thirty time units, the kinetic and potential energies
exchanging while their sum stays flat, `w(x4)` swinging between −1 (turning points, all
potential) and +1 (zero crossings, all kinetic), and the running average `w_avg` settling on 0.
"""))
    cells.append(code(r'''
def plot_model_c(d, fname, title, w_virial):
    x = d['x4']
    fig, axes = plt.subplots(2, 2, figsize=(12.5, 7.0))
    m = x <= 30
    axes[0, 0].plot(x[m], d['phi'][m], lw=1.2); axes[0, 0].set_ylabel('phi'); axes[0, 0].set_title(f'{title}: the field, x4 <= 30')
    axes[0, 1].plot(x[m], d['KE'][m], lw=1.0, label='KE = phidot^2/2'); axes[0, 1].plot(x[m], d['PE'][m], lw=1.0, label='PE = V(phi)')
    axes[0, 1].plot(x[m], d['rho'][m], 'k', lw=1.4, label='rho = KE + PE (conserved)'); axes[0, 1].legend(fontsize=8); axes[0, 1].set_title('energies')
    axes[1, 0].plot(x[m], d['w'][m], lw=1.0); axes[1, 0].axhline(-1, color='k', lw=0.5); axes[1, 0].axhline(1, color='k', lw=0.5)
    axes[1, 0].set_ylabel('w = P/rho'); axes[1, 0].set_title('w(x4), between -1 and +1')
    axes[1, 1].plot(x, d['w_avg'], lw=1.2, label='running average of w'); axes[1, 1].axhline(w_virial, color='r', lw=0.8, ls='--', label=f'virial value {w_virial:.4f}')
    axes[1, 1].set_ylim(w_virial - 0.3, w_virial + 0.3); axes[1, 1].legend(fontsize=8); axes[1, 1].set_title('the running average over the whole run')
    for ax in axes.flat:
        ax.set_xlabel('x4')
    fig.tight_layout(); fig.savefig(RESULTS / fname, dpi=130, bbox_inches='tight'); print('figure:', f'results/{fname}'); plt.show()

plot_model_c(RUNS['nb03_modelC_quadratic']['table'], 'nb03_modelC_quadratic.png', 'Model C, quadratic', 0.0)
'''))
    cells.append(md(r"""
### 5.2 Model C: the quartic potential, `V = ¼ λ φ⁴`, λ = 1, and the constant potential

For `V ∝ φ⁴` (`n = 2`) the virial average is `⟨w⟩ = (n − 1)/(n + 1) = 1/3`: the oscillating
field averages to radiation.  Asserted: `|w_avg(100) − 1/3| < 0.02` and `|ρ drift| < 1e−6`.
The constant potential (`V = V0`, `φ̇ = 0`) is the control: `w = −1` at every point, `ρ` exactly
constant.
"""))
    cells.append(code(r'''
d = run_solver('nb03_modelC_quartic', 'scalar-pre', '--potential', 'quartic', '--param', 'lambda=1', '--n1', '100', '--points', '2001', label='Model C quartic lambda=1')
print(f'\nw_avg(x4=100) = {d["w_avg"][-1]:+.6f}  (virial value 1/3 = {1/3:.6f}, difference {d["w_avg"][-1] - 1/3:+.2e});  max |rho drift| = {np.abs(d["rho_drift"]).max():.2e}')
assert np.abs(d['rho_drift']).max() < 1e-6 and abs(d['w_avg'][-1] - 1.0 / 3.0) < 0.02
print()
dc = run_solver('nb03_modelC_const', 'scalar-pre', '--potential', 'const', '--n1', '100', '--points', '2001', label='Model C const')
print(f'\nconst: max |w + 1| = {np.abs(dc["w"] + 1.0).max():.1e};  max |rho drift| = {np.abs(dc["rho_drift"]).max():.1e}')
assert np.abs(dc['w'] + 1.0).max() < 1e-12
plot_model_c(RUNS['nb03_modelC_quartic']['table'], 'nb03_modelC_quartic.png', 'Model C, quartic', 1.0 / 3.0)
'''))
    cells.append(md(r"""
### 5.3 Cross-check of Model C with scipy (DOP853, rtol = 1e−11)

`φ̈ = −V′(φ)` re-integrated from the same initial state on the same 2001 output points, comparing
`w` and `φ`.  The quadratic and constant cases agree to `1e−9` or better.  The quartic case
agrees to `4e−7`: still below the `1e−6` bound the notebook enforces, but larger, so its origin
is investigated rather than accepted — the same run repeated with `--rtol 1e-12 --atol 1e-14`
is compared with the same scipy solution, and the difference drops by two orders of magnitude,
which identifies it as CVODE's accumulated phase error over the ~13 nonlinear periods at the
default tolerance (scipy's own error is checked to be far smaller by rerunning it at
`rtol = 1e−13`).
"""))
    cells.append(code(r'''
def scipy_model_c(d, pot, params, rtol=1e-11):
    V, dV = scalar_potential(pot, params)
    x = d['x4']
    sol = solve_ivp(lambda t, y: [y[1], -dV(y[0])], (x[0], x[-1]), [d['phi'][0], d['phidot'][0]], method='DOP853', rtol=rtol, atol=1e-15, t_eval=x)
    assert sol.success, sol.message
    ke, pe = 0.5 * sol.y[1] ** 2, V(sol.y[0])
    w = (ke - pe) / (ke + pe)
    return float(np.abs(w - d['w']).max()), float(np.abs(sol.y[0] - d['phi']).max())

xcheck03 = {}
for n in ['nb03_modelC_quadratic', 'nb03_modelC_quartic', 'nb03_modelC_const']:
    r = RUNS[n]
    dw, dphi = scipy_model_c(r['table'], r['pot'], r['params'])
    xcheck03[n] = dw
    print(f'{r["label"]:28s} max|w_rust - w_scipy| = {dw:.3e}   max|phi_rust - phi_scipy| = {dphi:.3e}')
    assert dw < 1e-6, f'{n}: the scipy cross-check differs by {dw}'
print('\nthe quartic case, investigated:')
dq = run_solver('nb03_modelC_quartic_tight', 'scalar-pre', '--potential', 'quartic', '--param', 'lambda=1', '--n1', '100', '--points', '2001', '--rtol', '1e-12', '--atol', '1e-14',
                label='Model C quartic, rtol 1e-12', quiet=True)
for rt in (1e-11, 1e-13):
    print(f'  scipy at rtol {rt:.0e}: default-tolerance CVODE run differs by {scipy_model_c(RUNS["nb03_modelC_quartic"]["table"], "quartic", {"lambda": 1.0}, rt)[0]:.3e},  the rtol=1e-12 CVODE run by {scipy_model_c(dq, "quartic", {"lambda": 1.0}, rt)[0]:.3e}')
print(f'  w_avg(100): default {RUNS["nb03_modelC_quartic"]["table"]["w_avg"][-1]:.9f}, tight {dq["w_avg"][-1]:.9f};  rho drift: default {np.abs(RUNS["nb03_modelC_quartic"]["table"]["rho_drift"]).max():.1e}, tight {np.abs(dq["rho_drift"]).max():.1e}')
'''))
    cells.append(md(r"""
### 5.4 Model D: a profile along the hidden coordinate, ε = 0.05 and ε = 0.5

Quadratic potential `m = 1`, the default grid `x0 ∈ [0.05, 0.22]` with 61 points, `x4` from 0
to 30 with 301 outputs, the profile written to `results/nb03_profile_eps0.05.csv` and
`results/nb03_profile_eps0.5.csv`.  The initial profile is `1 + ε cos(π u)` at rest: for
`ε = 0.05` it is a 5 % ripple, for `ε = 0.5` half the field is in the ripple.  Because the flux
coefficient `Sec Cot²` is large near `x0 = 0.05` (`Cot²(0.3) = 10.4`), even the 5 % ripple
stores a quarter of the energy in `G0` at the start.  Asserted for both: `|E_drift| < 1e−6`.
"""))
    cells.append(code(r'''
for eps in ['0.05', '0.5']:
    d = run_solver(f'nb03_modelD_eps{eps}', 'scalar-pre-x0', '--potential', 'quadratic', '--param', 'm=1', '--param', f'eps={eps}', '--grid', '61', '--n1', '30', '--points', '301',
                   '--profile-out', str(RESULTS / f'nb03_profile_eps{eps}.csv'), label=f'Model D eps={eps}')
    x = d['x4']
    avg = np.concatenate([[d['w_sheet'][0]], np.cumsum(0.5 * (d['w_sheet'][1:] + d['w_sheet'][:-1]) * np.diff(x)) / x[1:]])
    RUNS[f'nb03_modelD_eps{eps}']['w_sheet_avg'] = avg
    print(f'  -> E_h(0) = {d["E_sheet"][0]:.6f};  max |E_drift| = {np.abs(d["E_drift"]).max():.2e};  w_sheet in [{d["w_sheet"].min():+.4f}, {d["w_sheet"].max():+.4f}];  w_mid in [{d["w_mid"].min():+.4f}, {d["w_mid"].max():+.4f}]')
    print(f'     energy fractions at x4 = 0: KE {d["KE_frac"][0]:.4f}  PE {d["PE_frac"][0]:.4f}  G0 {d["G0_frac"][0]:.4f};  G0_frac ranges over [{d["G0_frac"].min():.4f}, {d["G0_frac"].max():.4f}]')
    print(f'     time averages over x4 in [0, 30]: KE {d["KE_frac"].mean():.4f}  PE {d["PE_frac"].mean():.4f}  G0 {d["G0_frac"].mean():.4f};  running average of w_sheet at x4 = 30: {avg[-1]:+.4f}\n')
    assert np.abs(d['E_drift']).max() < 1e-6, 'the discrete energy E_h must be conserved'
'''))
    cells.append(md(r"""
For each `ε` one figure with four panels: `w_mid` (local, at the middle grid point) and
`w_sheet` (the `Sec`-weighted sheet average `⟨P⟩/⟨ρ⟩`) against `x4` over the first six time
units (the profile's higher modes oscillate fast, and the output spacing of 0.1 samples them
coarsely — the dots are the actual outputs; the sums and `E_h` are exact at each of them); the
running average of `w_sheet` over the whole run; the energy fractions `KE_frac`, `PE_frac`,
`G0_frac` stacked (they sum to 1 because `E_h` is conserved); and the profile `φ(x0)` at four
snapshot times read from the profile file (its first data row is the `x0` grid).
"""))
    cells.append(code(r'''
def plot_model_d(eps, fname):
    d = RUNS[f'nb03_modelD_eps{eps}']['table']
    x = d['x4']
    prof = np.loadtxt(RESULTS / f'nb03_profile_eps{eps}.csv', delimiter=',', skiprows=1)
    x0 = prof[0, 1:]
    fig, axes = plt.subplots(2, 2, figsize=(13, 8))
    m = x <= 6.0
    axes[0, 0].plot(x[m], d['w_mid'][m], 'o-', ms=2.5, lw=0.8, alpha=0.7, label='w_mid (local, middle of the grid)')
    axes[0, 0].plot(x[m], d['w_sheet'][m], 'o-', ms=2.5, lw=1.2, label='w_sheet = <P>/<rho>, Sec-weighted')
    axes[0, 0].axhline(-1, color='k', lw=0.5); axes[0, 0].axhline(0, color='k', lw=0.5, ls=':'); axes[0, 0].set_ylim(-1.1, 1.1)
    axes[0, 0].set_xlabel('x4'); axes[0, 0].set_title(f'Model D, eps = {eps}: equations of state, x4 <= 6 (output spacing 0.1)'); axes[0, 0].legend(fontsize=7, loc='lower right')
    axes[0, 1].plot(x, d['w_sheet'], lw=0.5, alpha=0.4, label='w_sheet, whole run')
    axes[0, 1].plot(x, RUNS[f'nb03_modelD_eps{eps}']['w_sheet_avg'], 'k', lw=1.6, label='running average of w_sheet')
    axes[0, 1].axhline(0, color='r', lw=0.8, ls='--', label='virial value 0'); axes[0, 1].set_ylim(-1.1, 1.1)
    axes[0, 1].set_xlabel('x4'); axes[0, 1].set_title('the running average settles on the virial value'); axes[0, 1].legend(fontsize=7, loc='lower right')
    axes[1, 0].stackplot(x, d['KE_frac'], d['PE_frac'], d['G0_frac'], labels=['KE_frac', 'PE_frac', 'G0_frac (x0 gradient)'], alpha=0.8)
    axes[1, 0].set_ylim(0, 1); axes[1, 0].set_xlabel('x4'); axes[1, 0].set_title('energy fractions of the conserved E_h'); axes[1, 0].legend(fontsize=7, loc='upper right')
    for t_snap in [0.0, 10.0, 20.0, 30.0]:
        k = int(np.argmin(np.abs(prof[1:, 0] - t_snap))) + 1
        axes[1, 1].plot(x0, prof[k, 1:], lw=1.2, label=f'x4 = {prof[k, 0]:.0f}')
    axes[1, 1].set_xlabel('x0 (hidden coordinate)'); axes[1, 1].set_ylabel('phi(x0, x4)'); axes[1, 1].set_title('the profile at four times'); axes[1, 1].legend(fontsize=8)
    fig.tight_layout(); fig.savefig(RESULTS / fname, dpi=130, bbox_inches='tight'); print('figure:', f'results/{fname}'); plt.show()

plot_model_d('0.05', 'nb03_modelD_eps0.05.png')
plot_model_d('0.5', 'nb03_modelD_eps0.5.png')
'''))
    cells.append(md(r"""
### 5.5 Cross-check of Model D with scipy (DOP853, rtol = 1e−11)

The same 122-equation semi-discrete system (flux form, `Sec Cot²` at the half points, zero flux
at both ends) is written again in numpy, integrated by DOP853 from the same profile, and its
`w_sheet` — computed with the same `Sec`-weighted sums and the same discrete gradient energy —
is compared with the solver's on the 301 output points; the middle-point field is compared too.
Each run takes about ten seconds in Python (1.5 million right-hand-side evaluations).
"""))
    cells.append(code(r'''
def scipy_model_d(eps, x0min=0.05, x0max=0.22, n=61):
    d = RUNS[f'nb03_modelD_eps{eps}']['table']
    V, dV = scalar_potential('quadratic', {'m': 1.0})
    h = (x0max - x0min) / (n - 1)
    x0 = x0min + h * np.arange(n)
    xh = x0min + h * (np.arange(n - 1) + 0.5)
    coef = (1.0 / np.cos(6 * xh)) * (np.cos(6 * xh) / np.sin(6 * xh)) ** 2
    cosj, secj = np.cos(6 * x0), 1.0 / np.cos(6 * x0)
    prof = np.loadtxt(RESULTS / f'nb03_profile_eps{eps}.csv', delimiter=',', skiprows=1)
    assert np.abs(prof[0, 1:] - x0).max() < 1e-12

    def rhs(t, y):
        phi, phid = y[:n], y[n:]
        F = np.zeros(n + 1)
        F[1:n] = coef * np.diff(phi) / h
        return np.concatenate([phid, cosj * (F[1:] - F[:-1]) / h - dV(phi)])

    sol = solve_ivp(rhs, (d['x4'][0], d['x4'][-1]), np.concatenate([prof[1, 1:], np.zeros(n)]), method='DOP853', rtol=1e-11, atol=1e-14, t_eval=d['x4'])
    assert sol.success, sol.message
    phi, phid = sol.y[:n], sol.y[n:]
    ke = (secj[:, None] * h * 0.5 * phid ** 2).sum(0)
    pe = (secj[:, None] * h * V(phi)).sum(0)
    g0 = (0.5 * coef[:, None] * (np.diff(phi, axis=0) / h) ** 2 * h).sum(0)
    E, P = ke + pe + g0, ke - pe - g0
    return float(np.abs(P / E - d['w_sheet']).max()), float(np.abs(phi[n // 2] - d['phi_mid']).max()), float(np.abs(E / E[0] - 1.0).max()), sol.nfev

for eps in ['0.05', '0.5']:
    dw, dphi, drift, nfev = scipy_model_d(eps)
    xcheck03[f'nb03_modelD_eps{eps}'] = dw
    print(f'Model D eps={eps}: max|w_sheet_rust - w_sheet_scipy| = {dw:.3e}   max|phi_mid diff| = {dphi:.3e}   E_h drift of the scipy run = {drift:.1e}   ({nfev} rhs evaluations)')
    assert dw < 1e-6, f'eps={eps}: the scipy cross-check differs by {dw}'
'''))
    cells.append(md(r"""
## 6. This notebook's results

Everything this notebook writes lives under `results/`:

- `results/nb03_modelC_quadratic.csv`, `results/nb03_modelC_quartic.csv`, `results/nb03_modelC_const.csv`,
  `results/nb03_modelC_quartic_tight.csv` (the `rtol = 1e−12` repeat) — Model C;
- `results/nb03_modelD_eps0.05.csv`, `results/nb03_modelD_eps0.5.csv` — Model D summaries;
  `results/nb03_profile_eps0.05.csv`, `results/nb03_profile_eps0.5.csv` — the profiles `φ(x0, x4)`;
- `results/nb03_modelC_quadratic.png`, `results/nb03_modelC_quartic.png`, `results/nb03_modelD_eps0.05.png`,
  `results/nb03_modelD_eps0.5.png` — the figures.

The cell below reads the `ε = 0.5` summary back with Python's `csv` module alone (no numpy,
no solver) and prints the conserved energy at a few times, as anyone can.
"""))
    cells.append(code(r'''
import csv
with open(RESULTS / 'nb03_modelD_eps0.5.csv', newline='') as f:
    rows = list(csv.DictReader(f))
print(f'{len(rows)} rows, columns: {", ".join(rows[0].keys())}')
for r in rows[::50]:
    print(f"x4 = {float(r['x4']):5.1f}   E_h = {float(r['E_sheet']):.12f}   E_drift = {float(r['E_drift']):+.2e}   w_sheet = {float(r['w_sheet']):+.5f}   G0_frac = {float(r['G0_frac']):.4f}")
'''))
    cells.append(md(r"""
## 7. What the pre-universe does to the field, in words and numbers

**No Hubble friction.**  The field equation of `φ(x4)` on the pre-universe is `φ̈ = −V′(φ)`, with
no `3Hφ̇` term, because the friction term of the wave operator is
`(1/Sqrt[g]) ∂_4(Sqrt[g] g^{44} ∂_4 φ)` and `Sqrt[g] g^{44} = −Sec[6Hx0]` does not depend on
`x4`: the observed sheet expands as `q ∝ e^{−a4}` but the second sheet contracts as `p ∝ e^{+a4}`,
and the 8-volume element `q³ p³ Tan = Sec[6Hx0]` is constant in time.  Model C shows it:
`ρ = KE + PE` is conserved to `3e−9` (quadratic) and `2e−8` (quartic) over 100 time units, and
the quadratic run reproduces `φ = Cos[x4]` to `2e−9`.

**Virial averages.**  With `w` swinging between −1 and +1 every half period, the physically
meaningful number is the average: for `V ∝ φ^{2n}` the virial theorem gives
`⟨KE⟩ = n ⟨PE⟩` and `⟨w⟩ = (n − 1)/(n + 1)`.  Measured: `w_avg(100) = +0.0044` for the mass
term (`⟨w⟩ = 0`: the oscillating field is **dust**, and in the reference model it dilutes as
`a^{−3}`), `+0.3349` for the quartic (`⟨w⟩ = 1/3`: radiation).  The residuals are the last
incomplete period divided by 100.

**The x0-gradient energy is a `w = −1` store.**  A static profile along the hidden coordinate
has `ρ = G0`, `P = −G0`, `w = −1` on the observed sheet, exactly (the `V = 0` solution
`∂_0φ ∝ Sin²/Cos`).  With a potential the store is not static: the profile's modes have
different frequencies, so its shape changes and `G0` exchanges energy with the `x4` motion —
**the sloshing mechanism**.  In the `ε = 0.5` run 97.8 % of `E_h` starts in `G0`, the fraction
falls to 9.9 % and comes back, and `w_sheet` swings between −1 and +0.80; in the `ε = 0.05` run
`G0` holds between 2.9 % and 28.5 % and `w_sheet` reaches +0.94.  The profile panels show the
ripple being carried across the grid and reflected by the Neumann ends.  For the quadratic
potential the problem is linear, so the virial theorem holds for the whole sheet,
`⟨KE⟩ = ⟨PE⟩ + ⟨G0⟩`, and the running average of `w_sheet` tends to 0 as well (`+0.004` and
`+0.001` at `x4 = 30`; the time-averaged `KE` fraction is 0.50 in both runs): the gradient store
does not change the *average* equation of state of a massive field, it changes its history.
Only a massless profile (`V = 0`) is `w = −1` forever.

**The conserved discrete energy.**  The flux-form scheme conserves
`E_h = Σ_j Sec_j h (½φ̇_j² + V(φ_j)) + Σ_{j+½} ½ c_{j+½} (φ_{j+1} − φ_j)²/h` exactly (summation by
parts), so its drift measures the time integrator alone: `4.5e−9` and `9.1e−9` at the default
tolerance.  The `Sec[6Hx0]` weight in the first sum is `Sqrt[det g]`, the volume element of the
frame: every sheet average is taken with it, and `w_sheet = ⟨P⟩/⟨ρ⟩` — the ratio of averages,
never the average of ratios (`w_mid`, the local value at the middle of the grid, is plotted
next to it to show how different a local `w` can be).

**Model E — `fable` on the pre-universe.**  For the spinor the corresponding statement is
stronger and needs no integration: with `Ψ = Sqrt[Sin[6Hx0]] Ψ′(x4)` the field equation is
`∂_4Ψ′ = −H V′(s) gamma⁴ Ψ′`, and since `(gamma⁴)² = −1` and `Ψ′ᵀ σ16 gamma⁴ Ψ′` is a bilinear
with an antisymmetric matrix, `ds′/dx4 = −2HV′ Ψ′ᵀ σ16 gamma⁴ Ψ′ = 0`; Part VI of the Mathematica
notebook proves `ds/dx4 = 0` on shell for a generic `Ψ(x0, x4)` as well.  The bilinear `s`, and
with it `V(s)`, `ρ_Ψ` and `w_Ψ`, are **constant along the observer's time on the pre-universe**:
no dilution, no oscillation, a fixed equation of state `w = s V′(s)/V(s) − 1` set once and for
all by where `s` sits on the potential.  The `a^{−3}` dilution of Model B is the reference
model's Hubble friction, which the pre-universe does not have.

The cell below re-derives every number quoted in this section and fails if the text has gone
stale.
"""))
    cells.append(code(r'''
q = RUNS['nb03_modelC_quadratic']['table']; q4 = RUNS['nb03_modelC_quartic']['table']
assert np.abs(q['rho_drift']).max() < 5e-9 and np.abs(q4['rho_drift']).max() < 5e-8 and np.abs(q['phi'] - np.cos(q['x4'])).max() < 5e-9
assert abs(q['w_avg'][-1] - 0.0044) < 2e-4 and abs(q4['w_avg'][-1] - 0.3349) < 2e-4
d5, d05 = RUNS['nb03_modelD_eps0.5']['table'], RUNS['nb03_modelD_eps0.05']['table']
assert abs(d5['G0_frac'][0] - 0.978) < 1e-3 and abs(d5['G0_frac'].min() - 0.099) < 1e-3 and abs(d5['w_sheet'].max() - 0.80) < 5e-3 and d5['w_sheet'].min() >= -1.0 - 1e-12
assert abs(d05['G0_frac'].min() - 0.029) < 1e-3 and abs(d05['G0_frac'].max() - 0.285) < 1e-3 and abs(d05['w_sheet'].max() - 0.94) < 5e-3
assert abs(RUNS['nb03_modelD_eps0.05']['w_sheet_avg'][-1] - 0.004) < 1e-3 and abs(RUNS['nb03_modelD_eps0.5']['w_sheet_avg'][-1] - 0.001) < 1e-3
assert abs(d05['KE_frac'].mean() - 0.50) < 5e-3 and abs(d5['KE_frac'].mean() - 0.50) < 5e-3
assert abs(np.abs(d05['E_drift']).max() - 4.5e-9) < 5e-10 and abs(np.abs(d5['E_drift']).max() - 9.1e-9) < 5e-10
print('every number quoted in section 7 agrees with the runs')
'''))
    cells += closing_cells(name, 8)
    build(NOTEBOOKS / f"{name}.ipynb", ["scalar-pre", "scalar-pre-x0"], cells)


# ==============================================================================================
# Notebook 04: the synthesis
# ==============================================================================================

def notebook_04():
    name = "04_dark_matter_dark_energy"
    cells = []
    cells.append(md(r"""
# Dark matter and dark energy from fableScalar and fable: the two mechanisms side by side

This is the synthesis.  It re-runs the best cases of the two fields with the Rust solver
`fable_cosmo` (pure-Rust SUNDIALS 7.8.0 CVODE) — the exponential quintessence `λ = 1` and the
exponential closest to Unite's `(w0, wa)`, the reference `expdamp` spinor, the `lambda-mass`
and `power n = 0.236` spinors and the pure mass term — reads the CPL fit tables that the FLRW
runs of both fields left under `results/` with plain Python, makes the three figures of the paper
(`w(a)` of all runs against Unite's line; the `Ω` histories; the deceleration parameter), and
then answers the questions of the task from the numbers: is there a connection to dark matter,
to dark energy, what is the framework's own mechanism, and what is *not* established.
"""))
    cells.append(md(SECTION_1))
    cells.append(md(SECTION_2))
    cells.append(md(r"""
## 3. The field, its Lagrangian and its energy-momentum tensor

Both fields live on the 4+4 pre-universe of the Mathematica notebook: coordinates
`X = {x0, …, x7}`, flat metric `eta = diag(+,+,+,+,−,−,−,−)`, canonical frame
`e = diag(Tan[6Hx0], q, q, q, 1, p, p, p)` with `q = e^{−a4[Hx4]}/Sin[6Hx0]^{1/6}`,
`p = e^{+a4[Hx4]}/Sin[6Hx0]^{1/6}`, `Sqrt[det g] = Sec[6Hx0]`, observer time `t ≡ x4`, observed
scale factor `a ∝ e^{−a4[Hx4]}` (a kinematic identification; `a4` is never given a value).  The
observer measures `ρ = T_{44}`, `P = T^i_i` (`i = 1, 2, 3`, equal by homogeneity), `w = P/ρ`.

**fableScalar** `φ(x)`: `L_φ = Sqrt[det g] (−½ g^{μν}∂_μφ∂_νφ − V(φ))`,
`T_{μν} = ∂_μφ ∂_νφ + g_{μν} L̂_φ` (symmetric, conserved on shell by an off-shell identity, trace
`−3(∂φ)² − 8V`), energies `KE = ½φ̇²`, `PE = V`, `G0 = ½Cot[6Hx0]²(∂_0φ)²`,
`G5 = ½ p^{−2} Σ(∂_{5,6,7}φ)²`, `ρ = KE + PE + G0 − G5`, `P = KE − PE − G0 + G5`.  The null energy
condition `ρ + P = 2KE ≥ 0` holds identically: **`w_φ ≥ −1` wherever `ρ_φ > 0`**; on the
pre-universe there is no Hubble friction (`Sqrt[g] g^{44}` is `x4`-independent), so a homogeneous
field oscillates undamped with virial `⟨w⟩ = (n−1)/(n+1)` for `V ∝ φ^{2n}`, and a static `x0`
profile is `w = −1` on the observed sheet.

**fable** `Ψ(x)`, a real 16-spinor of `Spin(4,4)` with bilinear `s = Ψᵀσ16Ψ`:
`L_Ψ = Sqrt[det g] ((1/H) Ψᵀσ16 gamma^μ D_μΨ − V(s))` (the spin connection drops out of `L̂` on
the canonical frame), covariant Dirac equation `gamma^μ D_μ Ψ = H V′(s) Ψ`, symmetrised
covariant `T_{μν}`; on shell `L̂_Ψ = sV′ − V`, `ρ_Ψ = V(s) + K_h`, `P_Ψ = sV′ − V`, and for the
rescaled homogeneous solutions `K_h = 0`, so **`w_Ψ = s V′(s)/V(s) − 1`**, which is not bounded
below by −1.  The author's mass term `V = −(2M/H)s` has `w = 0` identically: dust.  On the
pre-universe `ds/dx4 = 0` exactly.

**The reference models.**  Everything with a Friedmann equation in this notebook is the
*4-dimensional reference model* on a separate FLRW frame `diag(1, a, a, a, 1, 1, 1, 1)`: the
standard quintessence system for the scalar (Model A) and `d(a³s)/dt = 0`, `s = s0 a^{−3}` for
the spinor (Model B).  The framework has no gravitational sector; the reference models are what
one obtains when the hidden volume is held fixed and the field sources the expansion.  They are
never substituted into the canonical frame.
"""))
    cells.append(md(r"""
## 4. The equations of motion

Units: `M_pl² = 1/(8πG) = 1`, `H0 = 1`, `a0 = 1`, `ρ_crit,0 = 3`; `ρ_m = 3Ω_m0 e^{−3N}`,
`ρ_r = 3Ω_r0 e^{−4N}`, `Ω_m0 = 0.3`, `Ω_r0 = 8.4e−5`; `N = ln a`.

Model A: `φ̈ + 3Hφ̇ + V′(φ) = 0`, `H² = Ω_m0 e^{−3N} + Ω_r0 e^{−4N} + (½φ̇² + V)/3`.
Model B: `d(a³s)/dt = 0`, `H² = Ω_m0 e^{−3N} + Ω_r0 e^{−4N} + V(s)/3`, `w_Ψ = sV′/V − 1`.

### 4.1 The first-order system actually handed to SUNDIALS

Model A (`rhs_scalar_flrw`), state `y = (φ, φ̇, t)`:

    dφ/dN = φ̇/H,        dφ̇/dN = −3φ̇ − V′(φ)/H,        dt/dN = 1/H .

Model B (`rhs_spinor_flrw`), state `y = (s, t)`:

    ds/dN = −3s,        dt/dN = 1/H .

CVODE BDF, Newton, dense finite-difference Jacobian, `rtol = 1e−10`, `atol = 1e−12`, 701 outputs
from `N0 = −7` to `0`.  Initial conditions: Model A frozen (`φ̇ = 0`) at the potential's `φ_i`
(`exp`: 0); Model B `s = e^{−3N0}` with `s_today = 1`.  The age `t_age(N0) = 1/(2H(N0))` is
added analytically.  Normalisation: Model A shoots on the scale of `V` (bisection on `log10 k`)
until `Ω_φ(1) = 0.699916`; Model B rescales `V` so that `V(1) = 3 × 0.699916` (`w(s)`
unchanged); `--no-normalize` keeps the parameters as given (the reference `expdamp` case).
Outputs as for the FLRW models, including `Omega_field, Omega_m, Omega_r` and
`q_dec = −1 − (dH/dN)/H`, which this notebook plots.
"""))
    cells.append(md(r"""
## 5. Running the solver

The binary is `rust/fable_cosmo/target/release/fable_cosmo` (`.exe` on Windows); the models
used here are `scalar-flrw` and `spinor-flrw`, with the command line

    fable_cosmo <model> --potential NAME [--param KEY=VALUE ...] [--no-normalize] [--out FILE.csv]

The CSV header names every column; stderr carries the `# stats:` line and the potential after
normalisation.  The next cell locates the binary and defines the helpers; the following ones
re-run the six best cases (a few tenths of a second each), read the fit tables the FLRW runs
left under `results/`, and make the figures.
"""))
    cells.append(code(SETUP_CODE))
    cells.append(md(r"""
### 5.1 The best cases, re-run

Six runs, written to `results/nb04_*.csv`: the exponential quintessence `λ = 1` (the reference
case of Model A), the exponential closest to Unite's `(w0, wa)` among the values run for the
scalar field (`λ = 1.5`), the reference `expdamp` spinor `(1.566, 0.839, 2.21)` without
normalisation, the `lambda-mass` spinor (`V0 = 0.7`, `m = 0.3`), the `power n = 0.236` spinor and
the pure mass term.  A seventh, `expdamp` with `s1 = 3.0`, is added because it is the run of
either field whose fitted `(w0, wa)` lands closest to Unite's.
"""))
    cells.append(code(r'''
BEST = [
    ('nb04_exp_lambda1', 'scalar-flrw', ['--potential', 'exp', '--param', 'lambda=1'], 'fableScalar exp lambda=1', 'w_phi', 'Omega_phi'),
    ('nb04_exp_lambda1.5', 'scalar-flrw', ['--potential', 'exp', '--param', 'lambda=1.5'], 'fableScalar exp lambda=1.5 (closest of the five)', 'w_phi', 'Omega_phi'),
    ('nb04_expdamp_ref', 'spinor-flrw', ['--potential', 'expdamp', '--param', 'v0=1.566', '--param', 'm=0.839', '--param', 's1=2.21', '--no-normalize'], 'fable expdamp (1.566, 0.839, 2.21)', 'w_Psi', 'Omega_Psi'),
    ('nb04_expdamp_s3', 'spinor-flrw', ['--potential', 'expdamp', '--param', 'v0=1.566', '--param', 'm=0.839', '--param', 's1=3.0'], 'fable expdamp s1=3.0 (closest to Unite)', 'w_Psi', 'Omega_Psi'),
    ('nb04_lambda-mass', 'spinor-flrw', ['--potential', 'lambda-mass', '--param', 'v0=0.7', '--param', 'm=0.3'], 'fable lambda-mass (Lambda + dust)', 'w_Psi', 'Omega_Psi'),
    ('nb04_power_n0.236', 'spinor-flrw', ['--potential', 'power', '--param', 'n=0.236'], 'fable power n=0.236', 'w_Psi', 'Omega_Psi'),
    ('nb04_mass', 'spinor-flrw', ['--potential', 'mass'], 'fable mass (dust)', 'w_Psi', 'Omega_Psi'),
]
for key, model, args, label, wcol, ocol in BEST:
    d = run_solver(key, model, *args, label=label, quiet=True)
    RUNS[key]['wcol'], RUNS[key]['ocol'] = wcol, ocol
    print(f'  -> w(a=1) = {d[wcol][-1]:+.5f}   min w = {d[wcol].min():+.5f}   Omega_field(a=1) = {d[ocol][-1]:.6f}   q_dec(a=1) = {d["q_dec"][-1]:+.4f}')
'''))
    cells.append(md(r"""
### 5.2 The CPL tables of the two FLRW models, read with plain Python

`results/nb01_cpl_fits.csv` (fableScalar) and `results/nb02_cpl_fits.csv` (fable) are read
with the `csv` module — no numpy, no solver — merged, and printed sorted by the distance of the
fitted `(w0, wa)` from Unite's point.  They must exist: the FLRW runs of the two fields write them.  As a
consistency check the fits of the re-runs above are recomputed here and compared with the
tables' values for the same cases.
"""))
    cells.append(code(r'''
import csv
tables = {}
for f in ['nb01_cpl_fits.csv', 'nb02_cpl_fits.csv']:
    path = RESULTS / f
    if not path.exists():
        raise FileNotFoundError(f'{path} is missing: run the fableScalar and fable FLRW cases first (they write results/{f})')
    with open(path, newline='') as fh:
        tables[f] = list(csv.DictReader(fh))
merged = [dict(r, source=f) for f, rows in tables.items() for r in rows if r['model'] != 'reference']
merged.sort(key=lambda r: float(r['dist_to_unite']))
print(f"{'run':46s} {'model':12s} {'w0':>8s} {'wa':>8s} {'w0+wa':>8s} {'w(1)':>8s} {'min w':>8s}  {'class':9s} {'dist':>6s}")
for r in merged:
    print(f"{r['run']:46s} {r['model']:12s} {float(r['w0_fit']):8.4f} {float(r['wa_fit']):8.4f} {float(r['w0_plus_wa']):8.4f} {float(r['w_a1']):8.4f} {float(r['w_min']):8.4f}  {r['class']:9s} {float(r['dist_to_unite']):6.3f}")
print(f"{'Unite CPL':46s} {'':12s} {UNITE_W0:8.4f} {UNITE_WA:8.4f} {UNITE_W0 + UNITE_WA:8.4f} {UNITE_W0:8.4f}")
print(f"{'Unite constant w':46s} {'':12s} {UNITE_WCONST:8.4f} {0.0:8.4f} {UNITE_WCONST:8.4f} {UNITE_WCONST:8.4f}")
T = {r['run']: r for r in merged}
same = {'nb04_exp_lambda1': 'exp lambda=1', 'nb04_exp_lambda1.5': 'exp lambda=1.5', 'nb04_expdamp_ref': 'expdamp (1.566, 0.839, 2.21) reference',
        'nb04_expdamp_s3': 'expdamp s1=3.0', 'nb04_lambda-mass': 'lambda-mass v0=0.7 m=0.3', 'nb04_power_n0.236': 'power n=0.236', 'nb04_mass': 'mass (dust)'}
print('\nconsistency of the re-runs with the tables:')
for key, run in same.items():
    d = RUNS[key]['table']; w0, wa = cpl_fit(d['a'], d[RUNS[key]['wcol']])
    diff = max(abs(w0 - float(T[run]['w0_fit'])), abs(wa - float(T[run]['wa_fit'])))
    print(f'  {run:44s} re-run fit ({w0:+.6f}, {wa:+.6f}) versus table ({float(T[run]["w0_fit"]):+.6f}, {float(T[run]["wa_fit"]):+.6f})   max diff {diff:.1e}')
    assert diff < 1e-9
'''))
    cells.append(md(r"""
### 5.3 Figure (i): `w(a)` of all the best cases against Unite's line

Left: `0.3 ≤ a ≤ 1`, the supernova range, with Unite's CPL line and the shaded band
`|w − w_Unite(a)| < 0.1`; right: the whole run on a logarithmic `a` axis, the CPL line
extrapolated.  `results/nb04_w_of_a_all.png`.
"""))
    cells.append(code(r'''
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.5, 4.8))
au = np.linspace(0.3, 1.0, 200)
ax1.fill_between(au, UNITE_W0 + UNITE_WA * (1 - au) - 0.1, UNITE_W0 + UNITE_WA * (1 - au) + 0.1, color='0.85', label='|w - w_Unite(a)| < 0.1')
ax1.plot(au, UNITE_W0 + UNITE_WA * (1 - au), 'k:', lw=2, label='Unite CPL (-0.861, -0.60)')
afull = np.geomspace(9e-4, 1.0, 300)
ax2.plot(afull, UNITE_W0 + UNITE_WA * (1 - afull), 'k:', lw=1.5, label='Unite CPL line, extrapolated')
for key, model, args, label, wcol, ocol in BEST:
    d = RUNS[key]['table']
    line, = ax1.plot(d['a'], d[wcol], lw=1.4, label=label)
    ax2.plot(d['a'], d[wcol], lw=1.2, color=line.get_color(), label=label)
ax1.axhline(UNITE_WCONST, color='0.4', lw=0.8, ls='-.', label='Unite constant w = -0.764')
for ax in (ax1, ax2):
    ax.axhline(-1, color='k', lw=0.5); ax.set_xlabel('a'); ax.set_ylabel('w')
ax1.set_xlim(0.3, 1); ax1.set_ylim(-1.45, 0.05); ax1.set_title('the supernova range'); ax1.legend(fontsize=7, loc='upper left')
ax2.set_xscale('log'); ax2.set_ylim(-1.5, 0.2); ax2.set_title('the whole run'); ax2.legend(fontsize=7, loc='upper left')
fig.savefig(RESULTS / 'nb04_w_of_a_all.png', dpi=130, bbox_inches='tight'); print('figure: results/nb04_w_of_a_all.png'); plt.show()
'''))
    cells.append(md(r"""
### 5.4 Figure (ii): the density fractions `Ω_field(a)`, `Ω_m(a)`, `Ω_r(a)`

For the reference `expdamp` spinor and the `λ = 1` exponential scalar: matter (radiation is
already the minor component at the start, `N0 = −7`, since with `Ω_r0 = 8.4e−5` equality was at
`a_eq = Ω_r0/Ω_m0 = 2.8e−4`), then the field, which reaches `Ω = 0.6999` today by construction.
The moment the field overtakes matter is marked and printed.  `results/nb04_omega_history.png`.
"""))
    cells.append(code(r'''
fig, axes = plt.subplots(1, 2, figsize=(13.5, 4.5), sharey=True)
print(f'radiation-matter equality, analytic: a_eq = Omega_r0/Omega_m0 = {OR / OM:.2e} (z = {OM / OR - 1:.0f}), before the runs start (a = {np.exp(-7.0):.2e})')
for ax, key in zip(axes, ['nb04_expdamp_ref', 'nb04_exp_lambda1']):
    d = RUNS[key]['table']; oc = RUNS[key]['ocol']
    ax.plot(d['a'], d[oc], lw=1.6, label=f'Omega_field ({RUNS[key]["label"]})')
    ax.plot(d['a'], d['Omega_m'], lw=1.2, label='Omega_m'); ax.plot(d['a'], d['Omega_r'], lw=1.2, label='Omega_r')
    ax.set_xscale('log'); ax.set_xlabel('a'); ax.set_title(RUNS[key]['label']); ax.legend(fontsize=8, loc='center left'); ax.set_ylim(0, 1.02)
    i_dom = int(np.where(d[oc] > d['Omega_m'])[0][0])
    a_dom = float(np.exp(np.interp(0.0, (d[oc] - d['Omega_m'])[i_dom - 5:i_dom + 5], d['N'][i_dom - 5:i_dom + 5])))
    ax.axvline(a_dom, color='k', lw=0.6, ls=':'); ax.annotate('field = m', (a_dom, 0.9), fontsize=8, ha='center')
    print(f'{RUNS[key]["label"]:38s} Omega_r(N0) = {d["Omega_r"][0]:.4f};  the field overtakes matter at a = {a_dom:.4f} (z = {1 / a_dom - 1:.3f});  Omega_field(1) = {d[oc][-1]:.6f}')
axes[0].set_ylabel('Omega_i(a)')
fig.savefig(RESULTS / 'nb04_omega_history.png', dpi=130, bbox_inches='tight'); print('figure: results/nb04_omega_history.png'); plt.show()
'''))
    cells.append(md(r"""
### 5.5 Figure (iii): the deceleration parameter `q_dec(a) = −1 − (dH/dN)/H`

`q_dec = +1` in the radiation era, `+½` in the matter era, negative once the field accelerates
the expansion; the scale factor of the onset of acceleration (`q_dec = 0`) is printed for both
cases.  The phantom dip of `expdamp` shows as a deeper minimum of `q_dec`.
`results/nb04_deceleration.png`.
"""))
    cells.append(code(r'''
fig, ax = plt.subplots(figsize=(7.5, 4.6))
for key in ['nb04_expdamp_ref', 'nb04_exp_lambda1', 'nb04_lambda-mass', 'nb04_mass']:
    d = RUNS[key]['table']
    ax.plot(d['a'], d['q_dec'], lw=1.3, label=RUNS[key]['label'])
    m = d['a'] >= 0.2
    if (d['q_dec'][m] < 0).any():
        a_acc = float(np.exp(np.interp(0.0, -d['q_dec'][m], d['N'][m])))
        print(f'{RUNS[key]["label"]:38s} acceleration begins (q_dec = 0) at a = {a_acc:.4f} (z = {1 / a_acc - 1:.3f});  q_dec(1) = {d["q_dec"][-1]:+.4f}')
    else:
        print(f'{RUNS[key]["label"]:38s} never accelerates;  q_dec(1) = {d["q_dec"][-1]:+.4f}')
ax.axhline(0, color='k', lw=0.5); ax.axhline(0.5, color='k', lw=0.5, ls=':'); ax.axhline(1.0, color='k', lw=0.5, ls=':')
ax.set_xscale('log'); ax.set_xlabel('a'); ax.set_ylabel('q_dec'); ax.set_ylim(-1.2, 1.1); ax.legend(fontsize=8); ax.set_title('the deceleration parameter')
fig.savefig(RESULTS / 'nb04_deceleration.png', dpi=130, bbox_inches='tight'); print('figure: results/nb04_deceleration.png'); plt.show()
'''))
    cells.append(md(r"""
## 6. This notebook's results

Everything this notebook writes lives under `results/`:

- `results/nb04_exp_lambda1.csv`, `results/nb04_exp_lambda1.5.csv`, `results/nb04_expdamp_ref.csv`,
  `results/nb04_expdamp_s3.csv`, `results/nb04_lambda-mass.csv`, `results/nb04_power_n0.236.csv`, `results/nb04_mass.csv`
  — the re-runs of 5.1;
- `results/nb04_w_of_a_all.png`, `results/nb04_omega_history.png`, `results/nb04_deceleration.png` — the three figures of the paper.

It reads `results/nb01_cpl_fits.csv` and `results/nb02_cpl_fits.csv`, written by the two FLRW
notebooks.  The cell below reads one of its own CSVs back with Python's `csv` module alone
(no numpy, no solver) and prints today's row, as anyone can.
"""))
    cells.append(code(r'''
import csv
with open(RESULTS / 'nb04_expdamp_ref.csv', newline='') as f:
    rows = list(csv.DictReader(f))
print(f'{len(rows)} rows, columns: {", ".join(rows[0].keys())}')
for r in [rows[0], rows[len(rows) // 2], rows[-1]]:
    print(f"a = {float(r['a']):.6f}  z = {float(r['z']):10.3f}  t = {float(r['t']):.6f}  s = {float(r['s']):.4e}  w_Psi = {float(r['w_Psi']):+.6f}  Omega_Psi = {float(r['Omega_Psi']):.6f}  q_dec = {float(r['q_dec']):+.4f}")
'''))
    cells.append(md(r"""
## 7. The questions, answered

**Is there a connection to dark matter?  Yes, three of them, one of them exact.**
(1) The spinor's mass term — the author's own `V = −(2M/H) s`, the Lagrangian of the original
model promoted to a cosmological field — is **dust, exactly**: `w_Ψ = s V′/V − 1 = 0`
identically, and the `mass` run gives `w = 0` at all 701 points to `1e−14`, with
`ρ_Ψ = V(s) ∝ a^{−3}` (the `s = s0 a^{−3}` dilution law of the reference model).  A 16-component
spinor of `Spin(4,4)` with a mass term is cold dark matter.  (2) The scalar oscillating in a
quadratic potential on the pre-universe, with no Hubble friction, has the virial average
`⟨w⟩ = 0`: measured `w_avg(x4 = 100) = +0.0044` (Model C), and in the reference model an
oscillating `quadratic` field dilutes as dust once it oscillates.  (3) The `power` spinor with
`n = 0.236` is dust early (`w(a = 0.1) = −0.004`) and only later turns into dark energy.

**Is there a connection to dark energy?  Yes, by two different mechanisms, with these numbers.**
*fableScalar* rolling under Hubble friction (Model A) is standard thawing quintessence:
`exp λ = 1` gives `w(1) = −0.843`, CPL fit `(w0, wa) = (−0.844, −0.217)`; `λ = 1.5` gives
`(−0.618, −0.502)`, the closest of the values run to Unite's `(−0.861, −0.60)` (distance 0.263);
`λ ≈ 1.64` reaches `wa = −0.60` with `w0 ≈ −0.53`.  It has Unite's sign pattern (`w0 > −1`,
`wa < 0`) and a CPL extrapolation `w0 + wa` below −1 (−1.06 for `λ = 1`, −1.12 for `λ = 1.5`)
while its true `w` never drops below −1 (`min w = −1.000000`, the null energy condition): it
cannot give a genuine phantom past.  *fable* with a potential whose slope changes sign
(Model B) does: the reference `expdamp` `(1.566, 0.839, 2.21)` has `w(1) = −0.861`, crosses
`w = −1` at `a = 0.768` (`z = 0.30`), reaches `w = −1.302` at `z = 0.84` and fits
`(−0.978, −0.245)`; `expdamp` with `s1 = 3.0` fits `(−0.851, −0.569)`, `w0 + wa = −1.42`, the
closest of every run in both notebooks to Unite's `(−0.861, −0.60, −1.46)`, with a genuine
`w < −1` in the past and `ρ_Ψ = V > 0` throughout — the classical spinor-quintom mechanism,
with no wrong-sign kinetic term.  Two more spinor cases are dark energy of a different kind:
`lambda-mass` reaches `w(1) = −0.700`, but its `Ω_Λ = V(0)/3 = 0.490` is a bare cosmological
constant in the action (ΛCDM with spinor dust, `Ω = 0.210`, not field-driven dark energy), and
`power n = 0.236` is field-driven (`w → n − 1 = −0.764`, Unite's constant-w value, exactly at
late times: `w(a = e⁶) + 0.764 = 8e−7`) but has `w(1) = −0.382` with `m = λ`.

**What is the framework's own mechanism?**  On the pre-universe itself — not in the reference
models — the frame does two things.  There is **no Hubble friction** along the observer's time
(`Sqrt[g] g^{44} = −Sec[6Hx0]` is `x4`-independent, because the observed sheet's expansion is
compensated by the second sheet's contraction), so fableScalar oscillates undamped with
`ρ` conserved (drift `3e−9`) and virial-averaged `w` (0 for the mass term, 1/3 for the quartic),
and fable's bilinear does not dilute at all, `ds/dx4 = 0` exactly (Model E): its `w = sV′/V − 1`
is fixed once and for all.  And a field with a profile along the hidden coordinate `x0` stores
energy in the `x0` gradient, which on the observed sheet is a `w = −1` component (`ρ = G0`,
`P = −G0`) while along `x0` itself it is an anisotropic stress (`P_0 = +G0`); with a potential the
store sloshes into the `x4` motion and back (Model D: up to 97.8 % of the energy in the gradient,
`w_sheet` swinging between −1 and +0.80, the discrete energy conserved to `1e−8`).  A
time-varying `w` on the pre-universe therefore comes from oscillation and sloshing, not from
rolling; the average of a massive field is dust, and only a massless profile stays at `w = −1`.

**What is NOT established.**  (1) The framework has **no gravitational sector**: no Einstein
equations, `a4` undetermined, so nothing here says which density gravitates or what `a(t)` is;
every `H(a)`, every `Ω`, every CPL fit above belongs to the 4-dimensional reference models,
obtained by holding the hidden volume fixed and letting the field source a Friedmann equation
on a separate FLRW frame.  (2) **Perturbations are not examined**: the spinor's crossing of the
phantom divide is a statement about the homogeneous background; the stability of perturbations
in that phase — the known weak point of quintom models — has not been studied.  (3) **The
volume bookkeeping caveat**: integrating the 8-dimensional action over the hidden coordinates
multiplies every density by the hidden 4-volume density `𝒱_hid ∝ a^{−3}`, so the reduced
`ρ_4 ∝ a^{−3} ρ_8` is not separately conserved and dilutes like dust for *every* `w` — a
cosmological constant would pass the same test; it is a volume effect, not a dark-matter
signature, and the locally measured `T_{44} = ρ_8` is exactly constant.  Whether `ρ_4` or `ρ_8`
is the gravitating density is undetermined without a gravitational sector.  (4) The kinematic
identification `ln a = −a4[Ht]` with `a4′ < 0` is a hypothesis about the sign, not a result.

The cell below re-derives every number quoted in this section from the tables and the re-runs
and fails if the text has gone stale.
"""))
    cells.append(code(r'''
g = lambda run, col: float(T[run][col])
assert np.abs(RUNS['nb04_mass']['table']['w_Psi']).max() <= 1e-14
assert abs(g('exp lambda=1', 'w_a1') + 0.843) < 1e-3 and abs(g('exp lambda=1', 'w0_fit') + 0.844) < 1e-3 and abs(g('exp lambda=1', 'wa_fit') + 0.217) < 1e-3
assert abs(g('exp lambda=1.5', 'w0_fit') + 0.618) < 1e-3 and abs(g('exp lambda=1.5', 'wa_fit') + 0.502) < 1e-3 and abs(g('exp lambda=1.5', 'dist_to_unite') - 0.263) < 1e-3
assert abs(g('exp lambda=1', 'w0_plus_wa') + 1.06) < 5e-3 and abs(g('exp lambda=1.5', 'w0_plus_wa') + 1.12) < 5e-3
assert all(abs(g(r['run'], 'w_min') + 1.0) < 1e-6 for r in merged if r['model'] == 'scalar-flrw')
E = 'expdamp (1.566, 0.839, 2.21) reference'
d = RUNS['nb04_expdamp_ref']['table']
assert abs(g(E, 'w_a1') + 0.861) < 1e-3 and abs(g(E, 'w_min') + 1.302) < 1e-3 and abs(g(E, 'w0_fit') + 0.978) < 1e-3 and abs(g(E, 'wa_fit') + 0.245) < 1e-3
assert abs(crossings(d['N'], d['w_Psi'])[0] - 0.768) < 1e-3 and abs(d['z'][d['w_Psi'].argmin()] - 0.84) < 5e-3
assert merged[0]['run'] == 'expdamp s1=3.0' and abs(g('expdamp s1=3.0', 'w0_fit') + 0.851) < 1e-3 and abs(g('expdamp s1=3.0', 'wa_fit') + 0.569) < 1e-3 and abs(g('expdamp s1=3.0', 'w0_plus_wa') + 1.42) < 5e-3
assert abs(g('lambda-mass v0=0.7 m=0.3', 'w_a1') + 0.700) < 1e-3 and abs(RUNS['nb04_lambda-mass']['params']['v0'] / 3 - 0.490) < 1e-3 and abs(RUNS['nb04_lambda-mass']['params']['m'] / 3 - 0.210) < 1e-3
P = RUNS['nb04_power_n0.236']['table']
assert abs(P['w_Psi'][-1] + 0.382) < 1e-3 and abs(w_at(P['a'], P['w_Psi'], 0.1) + 0.004) < 1e-3
scan = np.genfromtxt(RESULTS / 'nb01_lambda_scan.csv', delimiter=',', names=True)
assert abs(np.interp(-0.60, scan['wa_fit'][::-1], scan['lambda'][::-1]) - 1.64) < 0.01
print('every number quoted in section 7 agrees with the tables and the runs')
'''))
    cells += closing_cells(name, 8)
    build(NOTEBOOKS / f"{name}.ipynb", ["scalar-flrw", "spinor-flrw"], cells)


# ==============================================================================================
NOTEBOOK_BUILDERS = {"01": notebook_01, "02": notebook_02, "03": notebook_03, "04": notebook_04}

if __name__ == "__main__":
    which = sys.argv[1:] or sorted(NOTEBOOK_BUILDERS)
    for k in which:
        NOTEBOOK_BUILDERS[k]()
