#!/usr/bin/env python3
"""Generate the fable-cosmology notebooks (nbformat 4) from cell manifests.

    python notebooks/_build/nbgen.py            # writes notebooks/0[1-7]_*.ipynb (unexecuted)
    python notebooks/_build/nbgen.py 05 06      # only these

Notebooks 01-04 run the classical-field solver rust/fable_cosmo (metadata.fable_cosmo.model);
notebooks 05-07 run the fermion-fable solver rust/fable_fermion (metadata.fable_fermion.model);
notebook 07 also runs the wall-state solver fermion/waveguide.py (model "waveguide").

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
`--n0 -7 --n1 0 --points 701`.  It writes a CSV whose header line names every column (every
number written as `{:.15e}`: 15 decimals, i.e. 16 significant digits) and prints to stderr the
initial conditions, a `# stats:` line with the CVODE step and function-evaluation counts, the
potential *after* normalisation, and its version.  Exit code 0 is success; 1 is a solver or
physics error with a one-line reason, and also an unknown model or potential name; 2 is a
malformed command line (an unknown option, or a missing or non-numeric value).

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

`reference/mathematica_scalar_exp.csv` was written by `fable-cosmology/reference/make_reference.wls`
(a wolframscript) and is checked by Part VI of the Mathematica notebook, which reads it back:
the same equations, the same `Ω_m0, Ω_r0`, the same frozen start, the same normalised
`V0 = 2.6871520526047146` (the value the solver printed above for
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
exit code 0 is success; 1 is a solver or physics error with a one-line reason, and also an
unknown model or potential name; 2 is a malformed command line (an unknown option, or a missing
or non-numeric value).

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

`reference/mathematica_spinor_expdamp.csv` was written by `fable-cosmology/reference/make_reference.wls`
(a wolframscript) and is checked by Part VI of the Mathematica notebook, which reads it back.  It
is `expdamp (1.566, 0.839, 2.21)` without normalisation:
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
   `∂_0(Sec Cot² ∂_0φ) = 0` has the solution `∂_0φ = C Sin[6Hx0]²/Cos[6Hx0]`, so
   `G0 = C² Sin[6Hx0]²/2` (as Part VI asserts) is independent of `x4` (and of `x1, x2, x3`), i.e.
   constant for the observer at fixed `x0`, and `ρ = G0`, `P = −G0`, `w = −1` exactly on the
   sheet — while along `x0` itself
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
potential and the version; exit code 0 is success; 1 is a solver error, and also an unknown
model or potential name; 2 is a malformed command line (an unknown option, or a missing or
non-numeric value).

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
# The fermion-fable notebooks (05, 06, 07).  They run the second solver, rust/fable_fermion, and
# record it under metadata.fable_fermion.model (07 adds "waveguide": the wall-state solver fermion/waveguide.py).
# ==============================================================================================

SECTION_1_FERMION = r"""
## 1. How to open a notebook like this one, from a terminal

**What you need.** A Rust toolchain (`cargo`, from https://rustup.rs), Python 3 (3.10 or newer),
`git`, and an internet connection for the one-time setup, which makes a sparse clone of the
platform rustSolveIt engine (the vendored pure-Rust SUNDIALS 7.8.0 that both solvers of this
project are built on: `rustSolveIt_Win11_SUNDIALS_7_8_0` on Windows 11,
`rustSolveIt_macos-silicon_SUNDIALS_7_8_0` on Apple-silicon macOS,
`rustSolveIt_linux_SUNDIALS_7_8_0` on Linux).  Nothing else is downloaded.

**The three commands.**  From the directory that contains `fable-cosmology/`:

1. Run the setup once.  It creates the virtual environment `.venv`, installs numpy, scipy,
   matplotlib and jupyter into it, clones the engine sparsely into `rust/vendor/rustSolveIt`,
   builds the two solvers `rust/fable_cosmo` and `rust/fable_fermion` with `cargo build --release`
   and prints their versions:

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
again and watch for its last line, `== setup complete`.  To rebuild this notebook's solver alone,
run `cargo build --release` inside `rust/fable_fermion`; its own tests run with
`cargo test --release` in the same folder.
"""

SECTION_2_FERMION = r"""
## 2. The words used in this notebook

- **field** -- a quantity defined at every point of space-time.  `fable` is a spinor field Ψ with
  sixteen components per point that rotate into each other under Spin(4,4), the symmetry group of
  the 8-dimensional pre-universe.  In Part VI of the Mathematica notebook (the classical fable) the
  sixteen components are real commuting numbers; here they are quantized.
- **complex 16-spinor** -- the fermion fable: sixteen *complex* anticommuting components.  It is
  the minimal field that uses the author's spinor metric σ16, propagates, admits a potential
  V(s) of s = Ψbar Ψ, and reduces to Part VI's field as its real commuting shadow.
- **Grassmann numbers** -- anticommuting variables, θ1 θ2 = −θ2 θ1, so θ1² = 0; the classical
  variables of a fermion field.  A bilinear θᵀ M θ keeps only the antisymmetric part of M.
- **Dirac conjugate** -- Ψbar = Ψ^‡ σ16, with Ψ^‡ the complex-conjugate transpose and
  σ16 = T16[0] T16[1] T16[2] T16[3] the author's spinor metric; s = Ψbar Ψ is the scalar density.
- **anticommutator** -- {A, B} = AB + BA.  A fermion field is quantized by prescribing
  anticommutators, {Ψ_a(x), Ψ^‡_b(y)}, instead of commutators.
- **Krein space** -- a vector space with an *indefinite* inner product.  Here the form u^‡ G u
  with G = −i σ16 γ⁴ has eight positive and eight negative directions, so the naive quantization
  has states of negative norm.
- **fundamental symmetry J** -- an operator with J² = 1 that turns an indefinite form into a
  positive one.  Here J = −i T16[0] T16[1] T16[2] T16[3] T16[4]; the Hilbert adjoint is
  Ψ^† := Ψ^‡ J.
- **Fock space** -- the Hilbert space of states with any number of particles, built by applying
  creation operators to the vacuum.
- **Dirac sea** -- the vacuum in which every negative-frequency mode is filled.  Its holes are the
  antiparticles, and energies are measured from it (normal ordering).
- **Kohn–Sham** -- the density-functional method that replaces an interacting system by
  non-interacting quasiparticles moving in a self-consistent mean field.  Here the mean field is
  the mass m = W′(σ), with W(σ) := V(Hσ) and σ = ⟨χbar χ⟩, χ = Ψ/√H.
- **gap equation** -- the self-consistency condition m = W′(σ_KS(m, kF)/v): the mass of the
  quasiparticles fixes their scalar density, and the scalar density fixes the mass.
- **Fermi momentum kF** -- the radius of the filled momentum ball; with g = 8 states per
  momentum the number density is n = g kF³/(6π²).
- **degenerate gas** -- fermions at zero temperature, filling every state with |k| < kF.  Its
  pressure comes from the Pauli principle, not from heat.
- **ΔN_eff** -- extra radiation, counted in units of the energy density of one massless neutrino
  species: ΔN_eff = ρ_f / ρ_ν(1 species).  Nucleosynthesis (BBN) and the cosmic microwave
  background allow about 0.3.
- **stabilizing stress** -- the zero-energy pressure P_stab = −F/2 on the hidden directions that
  holds the hidden sheet fixed in the model `fable4d`.  It is a Lagrange multiplier, not a stress
  derived from any field.
- **null energy condition** -- ρ + P ≥ 0 for every direction and every component.  A component
  with zero energy density and negative pressure violates it.
- **Bianchi-I** -- a homogeneous but anisotropic metric with one scale factor per direction:
  ds² = C² dz² + A² dx_obs² − dt² − B² dx_hid².
- **hidden sheet** -- the directions x5, x6, x7 (timelike in the 4+4 signature, scale factor B),
  together with the hidden spacelike coordinate x0 (scale factor C, proper coordinate z).
- **Newton constant variation** -- the observed Newton constant is G_4 = G_8 / V_hid, with V_hid
  proportional to B³ C.  If the hidden sheet moves, G_4 changes; lunar laser ranging allows
  |d ln G/dt| < 1e−13 per year today, and nucleosynthesis allows |ΔG/G| of about 0.1 since then.
- **Lagrangian** -- the function L of a field and its derivatives whose integral (the action) is
  stationary on the physical solutions; in curved space-time it carries the factor Sqrt[|det g|].
- **energy-momentum tensor** T_{μν} -- the response of the action to a change of the metric.  Its
  components measured by an observer are the energy density and the pressures.
- **energy density ρ** -- energy per unit volume seen by the observer moving along the time
  coordinate (x4 on the pre-universe, t in the present universe).
- **pressure P** -- a diagonal spatial component of T.  P_obs acts along the observed sheet
  x1, x2, x3, P_hid along the hidden sheet x5, x6, x7, P_x0 along x0.
- **equation of state w = P/ρ** -- here w = P_obs/ρ.  A component with constant w dilutes as
  a^{−3(1+w)}: w = 1/3 is radiation, w = 0 is dust, w = −1 is a cosmological constant.
- **scale factor a** -- the size of the observed 3-space relative to today (a = 1 today, defined by
  the photon temperature T_CMB = 2.7255 K); in the solver it is called A.
- **redshift z = 1/a − 1** -- what an astronomer measures; z = 0 today.
- **N = ln a** -- the number of e-folds of expansion, the independent variable of the solver.
- **Hubble rate H = (da/dt)/a** -- measured in units of its value today, H0 = 1; the hidden
  directions have their own rates H_B and H_C.
- **Ω_i** -- the fraction ρ_i/(3H²) (in units 8πG = 1) of the critical density carried by
  component i: radiation r, baryons b, the fable f.
- **CPL (w0, wa)** -- the Chevallier–Polarski–Linder line w(a) = w0 + wa(1 − a).  The supernova
  *Unite* fits are (w0, wa) = (−0.861, −0.60) and, forcing a constant w, w = −0.764.
- **thawing / freezing** -- a dark energy whose w rises with time (dw/dN > 0) is thawing, one whose
  w falls towards −1 is freezing.
- **phantom** -- w < −1.  Crossing w = −1 is called crossing the phantom divide.
- **dust** -- pressureless matter, w = 0, ρ ∝ a^{−3}: what cold dark matter is.
- **cosmological constant** -- a constant energy density, w = −1 exactly.
- **kination** -- energy that is all kinetic, w = +1, ρ ∝ a^{−6}; the fable reaches it only on a
  non-ground-state branch of the gap equation.
- **SUNDIALS / CVODE / BDF / Adams** -- SUNDIALS is the Lawrence Livermore suite of solvers for
  differential equations; CVODE is its solver for first-order systems y′ = f(x, y); BDF (backward
  differentiation formulas, implicit, for stiff systems) and Adams (explicit-predictor
  multistep) are its two families of methods.  The solver uses the pure-Rust port of SUNDIALS 7.8.0
  of the rustSolveIt repositories, BDF with Newton iteration.
- **tolerance** -- CVODE keeps the local error of every step below rtol·|y| + atol; the runs use
  rtol = 1e−10, atol = 1e−12.  The independent scipy cross-checks integrate with DOP853 at
  rtol = 1e−11 and use adaptive quadrature for every Fermi-sea integral.
"""

# The setup cell of the fermion notebooks: the binary, the unit system (read from the binary, never
# hard-coded), the CSV reader, the runner, and an independent Python Kohn-Sham toolkit.
FERMION_SETUP_CODE = r'''
import os, sys, re, csv, io, math, time, subprocess
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import quad, solve_ivp
from scipy.optimize import brentq
from IPython.display import Markdown, display

ROOT = Path.cwd() if (Path.cwd() / 'rust').exists() else Path.cwd().parent
BIN = ROOT / 'rust' / 'fable_fermion' / 'target' / 'release' / ('fable_fermion.exe' if os.name == 'nt' else 'fable_fermion')
RESULTS = ROOT / 'results'
REFERENCE = ROOT / 'reference'
RESULTS.mkdir(exist_ok=True)
if not BIN.exists():
    print(f'The solver binary {BIN} does not exist: run  bash fable-cosmology/setup.sh  '
          f'(or  powershell -ExecutionPolicy Bypass -File fable-cosmology\\setup.ps1 ) first, then restart this notebook.')
    raise SystemExit(1)
VERSION = subprocess.run([str(BIN), '--version'], check=True, capture_output=True, text=True).stdout.strip()
CONSTANTS_TEXT = subprocess.run([str(BIN), '--constants'], check=True, capture_output=True, text=True).stdout
print(VERSION)
print(CONSTANTS_TEXT)
print('results directory:', RESULTS)


def _const(key, i=0):
    """The i-th number written as '= <mantissa>e<exponent>' on the line of `fable_fermion --constants`
    that starts with `key`."""
    line = next(l for l in CONSTANTS_TEXT.splitlines() if l.startswith(key))
    return float(re.findall(r'=\s+([-+]?\d[\d.]*e[-+]?\d+)', line)[i])


E_C_EV = _const('E_c')                  # the solver's unit of mass and momentum, rho_c0^(1/4), in eV
RHO_C0_EV4 = _const('rho_c0')           # the critical density today in eV^4
H0_PER_YR = _const('H0', 1)             # H0 in 1/yr
OMEGA_R0 = _const('Omega_r0')
OMEGA_B0 = _const('Omega_b0')
OMEGA_NU1 = _const('Omega_nu(1')        # one massless neutrino species today
T_CMB_EV = _const('T_CMB')
A_BBN = _const('a_BBN')
A_REC = _const('a_rec')
G_FABLE = float(re.search(r'g \(fable states per momentum\) = (\d+)', CONSTANTS_TEXT).group(1))
PI2 = math.pi ** 2
UNITE_W0, UNITE_WA, UNITE_WCONST = -0.861, -0.60, -0.764
LLR_BOUND_PER_YR = 1e-13                # |d ln G/dt| today, lunar laser ranging
print(f'E_c = {E_C_EV:.10e} eV, Omega_r0 = {OMEGA_R0:.10e}, Omega_b0 = {OMEGA_B0:.10e}, Omega_nu(1) = {OMEGA_NU1:.10e}, '
      f'a_BBN = {A_BBN:.6e}, a_rec = {A_REC:.6e}, g = {G_FABLE:g}')


def units_python():
    """The unit system recomputed here from the CODATA 2018 / IAU constants, independently of the solver:
    h = 0.674, T_CMB = 2.7255 K, N_eff = 3.046, omega_b = 0.02237."""
    hbar_js, c, ev, gN, kb = 1.054571817e-34, 299792458.0, 1.602176634e-19, 6.67430e-11, 8.617333262e-5
    hbar_evs = hbar_js / ev                                        # one CODATA 2018 hbar for H0 and M_pl
    mpc = 648000.0 / math.pi * 149597870700.0 * 1e6
    h = 0.674
    h0 = 100.0 * h * 1e3 / mpc * hbar_evs                          # eV
    mpl = math.sqrt(hbar_js * c ** 5 / (8 * math.pi * gN)) / ev    # reduced Planck mass, eV
    rhoc = 3 * h0 ** 2 * mpl ** 2
    og = math.pi ** 2 / 15 * (kb * 2.7255) ** 4 / rhoc
    onu = 7 / 8 * (4 / 11) ** (4 / 3) * og
    return dict(e_c=rhoc ** 0.25, omega_r0=og + 3.046 * onu, omega_nu1=onu, omega_b0=0.02237 / h ** 2)


U_PY = units_python()
for key, val in (('e_c', E_C_EV), ('omega_r0', OMEGA_R0), ('omega_nu1', OMEGA_NU1), ('omega_b0', OMEGA_B0)):
    assert abs(U_PY[key] / val - 1) < 1e-9, (key, U_PY[key], val)
print('the unit system recomputed in Python from CODATA agrees with the solver\'s to 1e-9 (E_c, Omega_r0, Omega_nu1, Omega_b0)')
assert G_FABLE == 8.0
RUNS = {}


def read_fermion_csv(text):
    """A fable_fermion CSV: '#' comment lines (the version, the machine-readable '# params:' line, the
    definitions), then the header line, then the rows.  Returns (comments, params, {column: array})."""
    comments, params, rows, hdr = [], {}, [], None
    for line in text.splitlines():
        if line.startswith('#'):
            comments.append(line[1:].strip())
            if line.startswith('# params:'):
                for tok in line[len('# params:'):].split():
                    k, _, v = tok.partition('=')
                    try:
                        params[k] = float(v)
                    except ValueError:
                        params[k] = v
        elif line.strip():
            if hdr is None:
                hdr = line.strip().split(',')
            else:
                rows.append([float(x) for x in line.split(',')])
    d = np.array(rows)
    return comments, params, {h: d[:, i] for i, h in enumerate(hdr)}


def run_fermion(name, *args, keep=True, expect_failure=False, quiet=False, label=None, show_log=True):
    """Run fable_fermion; write results/<name>.csv (unless keep=False: then the CSV is read from stdout);
    print the solver's log (stderr) and return a dict with the columns, the parameters and the log.
    With expect_failure=True the non-zero exit code and the solver's one-line reason are printed and
    the CompletedProcess is returned.  quiet=True prints only the '# stats:' line."""
    args = [str(x) for x in args]
    out = RESULTS / f'{name}.csv'
    cmd = [str(BIN), *args] + (['--out', str(out)] if keep else [])
    shown = ' '.join(['fable_fermion', *args] + (['--out', f'results/{name}.csv'] if keep else []))
    print('$', shown)
    t0 = time.time()
    r = subprocess.run(cmd, capture_output=True, text=True)
    wall = time.time() - t0
    if expect_failure:
        reason = [l for l in r.stderr.splitlines() if l.startswith('fable_fermion:')]
        print(f'  exit code {r.returncode}: {reason[-1] if reason else r.stderr.strip().splitlines()[-1]}')
        return r
    if r.returncode != 0:
        print(r.stderr)
        raise RuntimeError(f'fable_fermion failed (exit code {r.returncode}) for {name}')
    log = [l for l in r.stderr.splitlines() if l.startswith('#')]
    if show_log:
        for line in log:
            if not quiet or line.startswith('# stats'):
                print(' ', line)
    comments, params, cols = read_fermion_csv(out.read_text() if keep else r.stdout)
    RUNS[name] = dict(name=name, label=label or name, args=args, cols=cols, params=params, comments=comments,
                      log=log, wall=wall, keep=keep)
    return RUNS[name]


def log_value(run, key, pattern=r'([-+]?\d+\.?\d*(?:e[-+]?\d+)?)', i=0):
    """A number from the solver's log line that contains `key`."""
    line = next(l for l in run['log'] if key in l)
    return float(re.findall(pattern, line.split(key, 1)[1])[i])


# ---------------------------------------------------------------- the Kohn-Sham Fermi sea, in Python
# x = kF/|m|.  sigma = g m |m|^2 I1/(2 pi^2), eps = g |m|^4 I2/(2 pi^2), P = g |m|^4 I3/(6 pi^2), with
# I1 = Int_0^x t^2/sqrt(1+t^2), I2 = Int_0^x t^2 sqrt(1+t^2), I3 = Int_0^x t^4/sqrt(1+t^2).
X_SWITCH = 0.25


def ks_I_closed(x):
    """The closed forms (r = sqrt(1 + x^2), A = asinh x): they cancel catastrophically for x << 1."""
    r, A = math.sqrt(1.0 + x * x), math.asinh(x)
    return (x * r - A) / 2.0, (x * r * (2.0 * x * x + 1.0) - A) / 8.0, (x * r * (2.0 * x * x - 3.0) + 3.0 * A) / 8.0


def ks_I_series(x):
    """The convergent binomial series (radius 1): I1 = Sum binom(-1/2, j) x^(2j+3)/(2j+3), I2 with binom(1/2, j),
    I3 = Sum binom(-1/2, j) x^(2j+5)/(2j+5); the binomial coefficients by their recurrences, summed until
    every term is below 1e-17 of its sum."""
    x2, p = x * x, x ** 3
    i1 = i2 = i3 = 0.0
    c = b = 1.0                            # binom(-1/2, j), binom(1/2, j)
    j = 0
    while True:
        t1, t2, t3 = c * p / (2 * j + 3), b * p / (2 * j + 3), c * p * x2 / (2 * j + 5)
        i1, i2, i3 = i1 + t1, i2 + t2, i3 + t3
        if j >= 2 and abs(t1) <= 1e-17 * abs(i1) and abs(t2) <= 1e-17 * abs(i2) and abs(t3) <= 1e-17 * abs(i3):
            return i1, i2, i3
        c *= (-0.5 - j) / (j + 1)
        b *= (0.5 - j) / (j + 1)
        j, p = j + 1, p * x2


def ks_I_stable(x):
    """The numerically stable forms: the series below x = 0.25, the closed forms above."""
    return ks_I_series(x) if x < X_SWITCH else ks_I_closed(x)


def ks_I_quad(x):
    """The three integrals by adaptive quadrature (scipy.integrate.quad, epsrel 1e-13) on the pieces
    [0, 1e-8], [1e-8, 1e-7], ..., [10^k, x], summed with math.fsum: independent of both forms above."""
    o = dict(epsabs=0.0, epsrel=1e-13, limit=200)
    edges = sorted(set([0.0] + [10.0 ** k for k in range(-8, 7) if 10.0 ** k < x] + [x]))
    fs = (lambda t: t * t / math.sqrt(1 + t * t), lambda t: t * t * math.sqrt(1 + t * t), lambda t: t ** 4 / math.sqrt(1 + t * t))
    return tuple(math.fsum(quad(f, a, b, **o)[0] for a, b in zip(edges[:-1], edges[1:])) for f in fs)


def fermi_sea(m, kf, form='stable'):
    """The T = 0 Fermi sea of g = 8 states per momentum: n, sigma, eps, P, wF and chi = d sigma/dm at fixed kF."""
    n = G_FABLE * kf ** 3 / (6 * PI2)
    if kf <= 0.0:
        return dict(n=0.0, sigma=0.0, eps=0.0, P=0.0, wF=abs(m), chi=0.0)
    chi0 = G_FABLE * kf * kf / (4 * PI2)
    if m == 0.0:
        e = G_FABLE * kf ** 4 / (8 * PI2)
        return dict(n=n, sigma=0.0, eps=e, P=e / 3.0, wF=kf, chi=chi0)
    am, x = abs(m), kf / abs(m)
    i1, i2, i3 = {'stable': ks_I_stable, 'closed': ks_I_closed, 'quad': ks_I_quad}[form](x)
    r = math.sqrt(1.0 + x * x)
    # chi = (g/(2 pi^2)) Int_0^kF k^4/w^3 dk = (g m^2/(2 pi^2)) Int_0^x t^4/(1+t^2)^(3/2) dt, and that
    # integral is 3 I1 - x^3/r exactly (its derivative is x^4/r^3); below the switch its series is used
    j4 = (3.0 * i1 - x ** 3 / r) if x >= X_SWITCH else _chi_series(x)
    chi = G_FABLE * m * m * j4 / (2 * PI2)
    return dict(n=n, sigma=G_FABLE * m * am * am * i1 / (2 * PI2), eps=G_FABLE * am ** 4 * i2 / (2 * PI2),
                P=G_FABLE * am ** 4 * i3 / (6 * PI2), wF=math.hypot(kf, m), chi=chi)


def _chi_series(x):
    """3 I1 - x^3/sqrt(1+x^2) = Int_0^x t^4/(1+t^2)^(3/2) dt for small x, by its binomial series
    Sum binom(-3/2, j) x^(2j+5)/(2j+5) (radius 1)."""
    s, p, c, j = 0.0, x ** 5, 1.0, 0      # c = binom(-3/2, j)
    while True:
        t = c * p / (2 * j + 5)
        s += t
        if j >= 2 and abs(t) <= 1e-17 * abs(s):
            return s
        c *= (-1.5 - j) / (j + 1)
        j, p = j + 1, p * x * x


# ---------------------------------------------------------------- the potentials W(sigma) and the gap equation
class Pot:
    """W(sigma) as potentials.rs defines it: mass, lambda-mass, power, expdamp, lorentz, quadratic."""

    def __init__(self, name, **p):
        self.name, self.p = name, dict(p)

    def W(self, s):
        p = self.p
        return {'mass': lambda: p['m0'] * s, 'lambda-mass': lambda: p['v0'] + p['m0'] * s,
                'power': lambda: p['m0'] * s + p['lam'] * s ** p['nu'],
                'expdamp': lambda: p['v0'] + p['m0'] * s * math.exp(-s / p['s1']),
                'lorentz': lambda: p['v0'] + p['m0'] * s / (1.0 + (s / p['s1']) ** 2),
                'quadratic': lambda: p['v0'] + p['m0'] * s + 0.5 * p['lam'] * s * s}[self.name]()

    def dW(self, s):
        p = self.p
        if self.name in ('mass', 'lambda-mass'):
            return p['m0']
        if self.name == 'power':
            return p['m0'] + p['nu'] * p['lam'] * s ** (p['nu'] - 1.0)
        if self.name == 'expdamp':
            return p['m0'] * (1.0 - s / p['s1']) * math.exp(-s / p['s1'])
        if self.name == 'lorentz':
            u = (s / p['s1']) ** 2
            return p['m0'] * (1.0 - u) / (1.0 + u) ** 2
        return p['m0'] + p['lam'] * s

    def d2W(self, s):
        p = self.p
        if self.name in ('mass', 'lambda-mass'):
            return 0.0
        if self.name == 'power':
            return p['nu'] * (p['nu'] - 1.0) * p['lam'] * s ** (p['nu'] - 2.0)
        if self.name == 'expdamp':
            return (p['m0'] / p['s1']) * math.exp(-s / p['s1']) * (s / p['s1'] - 2.0)
        if self.name == 'lorentz':
            u = (s / p['s1']) ** 2
            return p['m0'] * (u - 3.0) / (1.0 + u) ** 3 * 2.0 * s / p['s1'] ** 2
        return p['lam']

    def U(self, s):
        """The condensate energy U = W - sigma W' (P_hid = -U)."""
        return self.W(s) - s * self.dW(s)

    def scaled(self, A):
        """The same shape with every energy scaled by A: W -> A W (m0, v0, lam multiplied by A)."""
        return Pot(self.name, **{k: (v * A if k in ('m0', 'v0', 'lam') else v) for k, v in self.p.items()})


def gap_function(pot, m, kf, v=1.0):
    return m - pot.dW(fermi_sea(m, kf)['sigma'] / v)


def gap_roots(pot, kf, v=1.0, ngrid=2001):
    """Every root of m = W'(sigma_KS(m, kF)/v): a scan of m over [-M, M] (M = 1.1 max |W'| over
    |sigma| < n/v), asinh-spaced on the scale kF (m > 0 only for the power law), every sign change
    refined by brentq.  Linear W: the root is m0."""
    if pot.name in ('mass', 'lambda-mass'):
        return [pot.p['m0']]
    n8 = G_FABLE * kf ** 3 / (6 * PI2) / v
    positive = pot.name == 'power'
    ss = np.linspace(1e-12 * n8 if positive else -n8 * (1 - 1e-12), n8 * (1 - 1e-12), 2001)
    M = 1.1 * max(abs(pot.dW(s)) for s in ss) + 1e-300
    if positive:
        ms = np.geomspace(1e-14 * kf, M, ngrid)
    else:
        t = np.linspace(-math.asinh(M / kf), math.asinh(M / kf), ngrid)
        ms = kf * np.sinh(t)
    f = lambda m: gap_function(pot, m, kf, v)
    fs = [f(m) for m in ms]
    roots = []
    for i in range(len(ms) - 1):
        if fs[i] == 0.0:
            roots.append(float(ms[i]))
        elif fs[i] * fs[i + 1] < 0.0:
            roots.append(brentq(f, ms[i], ms[i + 1], xtol=1e-300, rtol=1e-15, maxiter=500))
    return roots


def mean_field(pot, m, kf, v=1.0):
    """The Kohn-Sham fable at mass m (a gap root or not), per 7-volume v: rho = eps/v + U, P_obs = P/v - U, P_hid = -U."""
    fs = fermi_sea(m, kf)
    s8 = fs['sigma'] / v
    U = pot.U(s8)
    return dict(m=m, kf=kf, n8=fs['n'] / v, sigma8=s8, eps=fs['eps'] / v, P=fs['P'] / v, wF=fs['wF'], chi=fs['chi'],
                U=U, rho=fs['eps'] / v + U, P_obs=fs['P'] / v - U, P_hid=-U, gap=m - pot.dW(s8))


def ground_state(pot, kf, v=1.0):
    """The gap root of lowest energy density (the solver's default branch rule), with the number of roots."""
    roots = gap_roots(pot, kf, v)
    mfs = [mean_field(pot, m, kf, v) for m in roots]
    best = min(mfs, key=lambda d: d['rho'])
    best['n_roots'] = len(roots)
    return best


def delta_e_vac(m, M, closed=False):
    """The renormalized one-loop Dirac-sea energy that the no-sea functional drops (relativistic Hartree,
    Chin 1977), g = 8, reference mass M: vanishes like (m - M)^5 at m = M; even in m.
    With t = (M - m)/M the bracket is M^4 f(t), f = (1-t)^4 ln(1-t) + t - (7/2)t^2 + (13/3)t^3 - (25/12)t^4,
    whose first four orders cancel; for |t| < 0.2 the series f = Sum_{n>=5} c_n t^n,
    c_n = -Sum_{k=0..4} (-1)^k C(4,k)/(n - k), is summed instead (closed=True forces the closed form)."""
    m, M = abs(m), abs(M)
    t = (M - m) / M
    if closed or abs(t) >= 0.2:
        d = M - m
        log_term = m ** 4 * math.log(m / M) if m > 0 else 0.0
        return -(G_FABLE / (16 * PI2)) * (log_term + M ** 3 * d - 3.5 * M * M * d * d + 13.0 / 3.0 * M * d ** 3 - 25.0 / 12.0 * d ** 4)
    f, tn, n = 0.0, t ** 5, 5
    while True:
        cn = -sum((-1) ** k * math.comb(4, k) / (n - k) for k in range(5))
        term = cn * tn
        f += term
        if abs(term) <= 1e-17 * abs(f) or n > 400:
            return -(G_FABLE / (16 * PI2)) * M ** 4 * f
        n, tn = n + 1, tn * t


def cpl_fit(a, w, mask=None, amin=0.3, amax=1.0):
    """Least squares of w(a) to w0 + wa (1 - a) over amin <= a <= amax (and mask), numpy.polyfit on (1 - a)."""
    sel = (a >= amin) & (a <= amax) & np.isfinite(w)
    if mask is not None:
        sel &= mask
    if sel.sum() < 3:
        return float('nan'), float('nan')
    wa, w0 = np.polyfit(1.0 - a[sel], w[sel], 1)
    return float(w0), float(wa)


def crossing_points(a, y, level=0.0, floor=None):
    """Every a at which y - level changes sign (linear interpolation in ln a between rows).  With `floor` (an
    array), a sign change between two rows where |y - level| stays below the floor is rounding noise and is skipped."""
    f = y - level
    out = []
    for k in range(1, len(a)):
        if floor is not None and max(abs(f[k - 1]), abs(f[k])) <= max(floor[k - 1], floor[k]):
            continue
        if np.isfinite(f[k - 1]) and np.isfinite(f[k]) and f[k - 1] * f[k] < 0:
            la, lb = math.log(a[k - 1]), math.log(a[k])
            out.append(math.exp(la + (lb - la) * f[k - 1] / (f[k - 1] - f[k])))
    return out


def interp_log(a_rows, y_rows, a0):
    """y at a0, interpolating linearly in ln a (NaN outside the run)."""
    if a0 < a_rows[0] or a0 > a_rows[-1]:
        return float('nan')
    return float(np.interp(math.log(a0), np.log(a_rows), y_rows))
'''


def build_fermion(path, model, cells):
    """build() for the fermion notebooks: the solver model(s) go under metadata.fable_fermion.model."""
    for i, c in enumerate(cells):
        if c.cell_type == "code":
            assert i > 0 and cells[i - 1].cell_type == "markdown", f"{path.name}: code cell {i} has no markdown before it"
            assert len(cells[i - 1].source.strip()) >= 80, f"{path.name}: explanation before code cell {i} is too thin"
    nb = new_notebook(cells=cells)
    nb.metadata["kernelspec"] = {"display_name": "Python 3 (ipykernel)", "language": "python", "name": "python3"}
    nb.metadata["language_info"] = {"name": "python"}
    nb.metadata["fable_fermion"] = {"model": model}
    nbformat.validate(nb)
    nbformat.write(nb, str(path))
    n_code = sum(1 for c in cells if c.cell_type == "code")
    print(f"wrote {path.name}: {len(cells)} cells, {n_code} code cells")


# ==============================================================================================
# Notebook 05: the quantized fermion fable as a fluid (Kohn-Sham equation of state)
# ==============================================================================================

def notebook_05():
    name = "05_fermion_fable_quantum_eos"
    cells = []
    cells.append(md(r"""
# fermion fable: the quantized complex 16-spinor as a fluid

This notebook turns the quantized fermion fable into a fluid and checks every step with numbers.
It shows why the fermion fable is a **complex 16-spinor** (the invariant bilinear forms of
Spin(4,4) and what anticommuting variables do to them), what canonical quantization in 4+4
dimensions gives (the Krein form, the fundamental symmetry `J`, eight particle and eight
antiparticle states per momentum), and then the **Kohn–Sham Fermi sea**: its closed forms and their
numerically stable forms, verified against adaptive quadrature over `x = kF/|m|` from `1e−8` to
`1e6` and against the Rust solver `fable_fermion`; the equation of state `w_KS(x)` from 1/3 to 0;
the thermodynamic identities; the non-relativistic limit, which is Part VI's classical fable, and
the one thing that does not survive quantization, the classical crossing of the phantom divide;
the gap equation, its uniqueness criterion and a case with three roots; the minimax nature of the
no-sea functional and the convex Walecka functional; the cooling of the gas on the pre-universe;
and the Dirac-sea energy that a mass-varying fable carries.  Every number quoted is computed
below; the prose states only what the assertions of the code cells check.
"""))
    cells.append(md(SECTION_1_FERMION))
    cells.append(md(SECTION_2_FERMION))
    cells.append(md(r"""
## 3. The field, its Lagrangian and its energy-momentum tensor

**The 8-dimensional setting (Parts I–VI of the Mathematica notebook).**  The pre-universe has
coordinates `X = {x0, …, x7}`, flat metric `η = diag(+,+,+,+,−,−,−,−)` and the canonical frame
`e = diag(Tan[6Hx0], q, q, q, 1, p, p, p)` with `q = e^{−a4[Hx4]}/Sin[6Hx0]^{1/6}`,
`p = e^{+a4[Hx4]}/Sin[6Hx0]^{1/6}`, so `g = diag(Tan², q², q², q², −1, −p², −p², −p²)` and
`Sqrt[|det g|] = Sec[6Hx0]`.  The observer's time is `x4` (`g44 = −1`); `x1, x2, x3` are the observed
sheet, `x0` the hidden spacelike coordinate, `x5, x6, x7` the hidden timelike sheet.  The function
`a4` is never given a value.  The real 16×16 generators are `T16[A] = [[0, taubar[A]], [tau[A], 0]]`
(`A = 0…7`, built from the 8×8 split-octonion matrices `tau`, `taubar`), with
`{T16[a], T16[b]} = 2 η_ab`.  The author's spinor metric is `σ16 = T16[0] T16[1] T16[2] T16[3]`, and
`T16[8] = T16[0] ⋯ T16[7] = diag(−I8, +I8)` separates the two chiralities (the type-1 and type-2
split-octonion spinors).  The curved gammas on the canonical frame are `γ⁰ = Cot[6Hx0] T16[0]`,
`γ^i = T16[i]/q`, `γ⁴ = T16[4]`, `γ^h = T16[h]/p`.

**Why the fermion fable is a complex 16-spinor.**  Part VI's fable is a real *commuting* 16-component
field.  A fermion is described by anticommuting (Grassmann) variables, and a Grassmann bilinear
`θᵀ M θ` keeps only the antisymmetric part of `M` (`θ_a θ_b = −θ_b θ_a`).  Section 3.1 constructs
the algebra and shows: the only Spin(4,4)-invariant bilinear forms on `R^16` are the two
**symmetric**, chirality-diagonal matrices `σ16` and `σ16 T16[8]`.  Hence

- a *real* Grassmann 16-spinor with the author's `σ16` has no mass term (`θᵀσ16θ = 0`) and a kinetic
  term that is a total derivative (`σ16 T16[a]` is antisymmetric, so
  `θᵀ σ16 γ^μ ∂_μθ = ½ ∂_μ(θᵀ σ16 γ^μ θ)`): no dynamics, on every frame (the spin-connection term
  involves `σ16 Γ_abc`, which is symmetric);
- a *Majorana* 16-spinor with `C₊ = σ16 T16[8]` propagates (`C₊ T16[a]` is symmetric) but has no
  scalar bilinear at all: it is massless and `V(s)` is undefined;
- a *Weyl* or *Majorana–Weyl* 8-spinor (one chirality) cannot propagate: both invariant forms are
  chirality-diagonal, while `γ^μ` is chirality-odd;
- the **complex 16-spinor** `Ψ` (sixteen complex Grassmann components, equivalently two Majorana
  16-spinors) with Dirac conjugate `Ψbar = Ψ^‡ σ16` is the *minimal* field that uses the author's
  `σ16`, propagates, admits `V(s)` with `s = Ψbar Ψ`, and reduces to Part VI as its real commuting
  shadow.  It is not the unique field with dynamics.  It has two scalar bilinears, `s = Ψbar Ψ` and
  `p = Ψbar T16[8] Ψ`; `V` depends on `s` only.  Under the observer's `Spin(3,1)` of
  `x1, x2, x3, x4` it is four 4-dimensional Dirac fields: `C^16 = C^4 ⊗ C^4`.

**The Lagrangian** (the symmetrized covariant form; it is the only admissible one):

    L = Sqrt[|g|] L̂,     L̂ = (1/(2H)) [ Ψbar γ^μ D_μΨ − (D_μΨbar) γ^μ Ψ ] − V(s),     s = Ψbar Ψ,
    D_μΨ = (∂_μ + Γ_μ) Ψ,     D_μΨbar = ∂_μΨbar − Ψbar Γ_μ,

with `Γ_μ` the canonical spin connection.  As in the author's `La`, no factor `i` appears; the
action is Hermitian because `σ16 γ^a` and `σ16 Γ_μ` are real antisymmetric matrices.  On the
canonical, warped and Bianchi-I frames `{γ^μ, Γ_μ} = 0` for each `μ` separately, so there the
covariant and partial symmetrized Lagrangians coincide (not on a general frame).  The unsymmetrized
covariant form differs by the divergence `(1/(2H)) ∇_μ(Ψbar γ^μ Ψ)`; the unsymmetrized *partial*
form is inadmissible (its `Ψ` and `Ψbar` equations disagree by `−6H Cot² Ψbar T16[0]`).

**The energy–momentum tensor operator** is the Hilbert (symmetric-tetrad) tensor of this action; the
spin-connection variation contributes nothing to it:

    T̂_μν = −(1/(4H)) [ Ψbar γ_μ D_νΨ − (D_νΨbar) γ_μ Ψ + (μ ↔ ν) ] + g_μν L̂ ,

normal-ordered with respect to the J-vacuum (below).  On shell the kinetic bilinear is `sV′` and
`L̂ = sV′ − V`, the trace is `7sV′ − 8V`, `ρ = T_44 = V + K_h`, `T^i_i = T^h_h = sV′ − V` and
`T^0_0 = sV′ − V + K_h`, where `K_h = −(1/(2H))(Ψbar γ⁰ ∂_0Ψ − ∂_0Ψbar γ⁰ Ψ)` is the `x0` kinetic
bilinear; in the real commuting limit this is Part VI's `T_cov` exactly.  `T̂_μν` is Hermitian for
`μ, ν ∈ {0…4}`; its components that mix `0…4` with the hidden sheet are anti-Hermitian, with zero
expectation value in the states used here.

**Canonical quantization in 4+4 dimensions (section 3.3).**  Time is `x4`.  The admissible theory
is the dimensional reduction `Ψ = Ψ(x0, x1, x2, x3, x4)`, homogeneous along the hidden timelike
sheet, whose finite coordinate volume `V_hid` is an assumption (compact timelike directions contain
closed timelike curves).  The canonical anticommutator is

    {Ψ_a(x), Ψ^‡_b(y)} = (H / (V_hid Sqrt[|g|])) G_ab δ⁴(x − y),     G = −i σ16 γ⁴ ,

`G` Hermitian with `G² = 1` and eight eigenvalues `+1`, eight `−1`: the state space is a **Krein
space**.  The **fundamental symmetry** `J = −i T16[0] T16[1] T16[2] T16[3] T16[4]` (equal to `G` on
the canonical frame) defines the Hilbert adjoint `Ψ^† := Ψ^‡ J`; with it the Fock space is positive,
every mode's energy equals its frequency, the negative-frequency modes are filled (the **Dirac
sea**), the holes are antiparticles, and each spatial momentum carries `g = 8` particle and eight
antiparticle states.  A positive Fock quantization with Hermitian local `s`, energy–momentum tensor
and free Hamiltonian exists exactly when the momenta of the modes span a spacelike-definite
subspace (here `x0…x3`); momenta along the hidden timelike sheet above threshold give complex
frequencies (the ill-posed ultrahyperbolic Cauchy problem), which 3.3 shows.  What is lost: `J` is
covariant only under `Spin(4,1)` of `x0…x4` times `Spin(3)` of `x5, x6, x7`.

**The fluid.**  In the Kohn–Sham mean field `V′(s) → V′(⟨s⟩)` the fable is a free Fermi gas of mass
`m = W′(σ)`, `W(σ) := V(Hσ)`, `σ = ⟨χbar χ⟩`, `χ = Ψ/√H`, filling every momentum `|k| < kF` along
the observed sheet (zero modes along `x0` and `x5, x6, x7`) with `g = 8` states per momentum: its
zero-temperature ground state.  Its energy density and pressures are

    ρ = ε_KS + W(σ) − σ W′(σ),     P_obs = P_KS + σ W′ − W,     P_hid = P_x0 = σ W′ − W,     w = P_obs/ρ ,

with `n`, `σ_KS`, `ε_KS`, `P_KS` the Fermi-sea integrals of section 5.1.  **What is proved where.**
The algebra (3.1, 3.3) is re-verified numerically here.  The Lagrangian, the field equations, the
energy–momentum tensor operator, its conservation and the operator statements are asserted
symbolically in Part VII of the Mathematica notebook and are stated, not re-derived, here.  The
Fermi-sea formulas, their identities and limits, the gap-equation facts, the pre-universe cooling
and the vacuum energy are computed and checked in this notebook, against quadrature and against
the Rust solver.
"""))
    cells.append(md(r"""
### 3.1 The algebra: the invariant bilinear forms, and what anticommuting variables do to them

The next cell builds `tau`, `taubar` and `T16` exactly as Parts I and II of the Mathematica notebook
do (the self-dual and anti-self-dual 4×4 blocks, the ordered product `tau[7]`, `taubar[A] =
σ · Transpose[σ · tau[A]]`), checks the Clifford relations, and tabulates which products are
symmetric: `σ16`, `σ16 T16[a]` (8), `σ16 Γ_ab` (28), `σ16 Γ_abc` (56), `σ16 Γ_abcd` (70),
`σ16 T16[8]`, `C₊ = σ16 T16[8]` and `C₊ T16[a]`.  It then solves the linear equations
`M Σ_ab + Σ_abᵀ M = 0` for all 28 generators `Σ_ab = T16[a] T16[b]` of Spin(4,4) to find every
invariant bilinear form, checks that none is antisymmetric (so no Majorana mass term exists), that
both are chirality-diagonal (so a single chirality has no kinetic term), and that the commutant of
the observer's Clifford algebra `T16[1…4]` in the complex 16×16 matrices is 16-dimensional (so
`C^16 = C^4 ⊗ C^4`: four Dirac flavours).  The table is written to `results/nb05_clifford_table.csv`.
"""))
    cells.append(code(r'''
import itertools, csv, math
from pathlib import Path
import numpy as np

RESULTS = (Path.cwd() if (Path.cwd() / 'rust').exists() else Path.cwd().parent) / 'results'
RESULTS.mkdir(exist_ok=True)
ETA = np.diag([1, 1, 1, 1, -1, -1, -1, -1])
ID4 = np.eye(4, dtype=int)


def signature(seq):
    """Mathematica's Signature: the sign of the permutation that sorts seq, 0 if an entry repeats."""
    if len(set(seq)) < len(seq):
        return 0
    s = 1
    for i in range(len(seq)):
        for j in range(i + 1, len(seq)):
            if seq[i] > seq[j]:
                s = -s
    return s


Qa = lambda h, p, q: signature([h, p, q, 4])
Qb = lambda h, p, q: ID4[p - 1, 3] * ID4[q - 1, h - 1] - ID4[p - 1, h - 1] * ID4[q - 1, 3]
s4 = {h: np.array([[Qa(h, p, q) - Qb(h, p, q) for q in range(1, 5)] for p in range(1, 5)]) for h in (1, 2, 3)}
t4 = {h: np.array([[Qa(h, p, q) + Qb(h, p, q) for q in range(1, 5)] for p in range(1, 5)]) for h in (1, 2, 3)}
Z4, Z8 = np.zeros((4, 4), dtype=int), np.zeros((8, 8), dtype=int)
sigma8 = np.block([[Z4, ID4], [ID4, Z4]])
six = [np.block([[Z4, s4[h]], [s4[h], Z4]]) for h in (1, 2, 3)] + [np.block([[Z4, t4[h]], [-t4[h], Z4]]) for h in (3, 2, 1)]
tau = {0: np.eye(8, dtype=int), **{h: six[h - 1] for h in range(1, 7)}}
tau[7] = tau[1] @ tau[2] @ tau[3] @ tau[4] @ tau[5] @ tau[6]
taubar = {A: sigma8 @ (sigma8 @ tau[A]).T for A in range(8)}
T16 = {A: np.block([[Z8, taubar[A]], [tau[A], Z8]]) for A in range(8)}
I16 = np.eye(16, dtype=int)

assert all(np.array_equal(tau[A] @ taubar[B] + tau[B] @ taubar[A], 2 * ETA[A, B] * np.eye(8, dtype=int)) for A in range(8) for B in range(8))
assert np.array_equal(sigma8, tau[1] @ tau[2] @ tau[3])
assert all(np.array_equal(T16[a] @ T16[b] + T16[b] @ T16[a], 2 * ETA[a, b] * I16) for a in range(8) for b in range(8))
T8 = T16[0] @ T16[1] @ T16[2] @ T16[3] @ T16[4] @ T16[5] @ T16[6] @ T16[7]
S16 = T16[0] @ T16[1] @ T16[2] @ T16[3]
assert np.array_equal(T8, np.diag([-1] * 8 + [1] * 8)), 'T16[8] = diag(-I8, +I8)'
assert np.array_equal(S16, np.block([[-sigma8, Z8], [Z8, sigma8]])) and np.array_equal(S16 @ S16, I16)
print('Clifford relations {T16[a], T16[b]} = 2 eta_ab: all 64 hold;  T16[8] = diag(-I8, +I8);  sigma16 = [[-sigma, 0], [0, sigma]], sigma16^2 = 1')

sym = lambda M: bool(np.array_equal(M, M.T))
asym = lambda M: bool(np.array_equal(M, -M.T))
G2 = [T16[a] @ T16[b] for a, b in itertools.combinations(range(8), 2)]
G3 = [T16[a] @ T16[b] @ T16[c] for a, b, c in itertools.combinations(range(8), 3)]
G4 = [T16[a] @ T16[b] @ T16[c] @ T16[d] for a, b, c, d in itertools.combinations(range(8), 4)]
Cplus = S16 @ T8
consequence = {
    'sigma16': 'theta^T sigma16 theta = 0: no mass term for a real Grassmann spinor',
    'sigma16 T16[a]': 'theta^T sigma16 gamma d theta = (1/2) d(theta^T sigma16 gamma theta): a total derivative, no dynamics',
    'sigma16 Gamma_ab': 'antisymmetric: a real Grassmann tensor bilinear survives, but it is not a scalar',
    'sigma16 Gamma_abc': 'the spin-connection term theta^T sigma16 {gamma, Gamma} theta = 0 on every frame',
    'sigma16 Gamma_abcd': 'symmetric: vanishes on real Grassmann spinors',
    'sigma16 T16[8]': 'symmetric: no pseudoscalar mass term for a real Grassmann spinor either',
    'Cplus = sigma16 T16[8]': 'symmetric: a Majorana spinor with Cplus has no mass term',
    'Cplus T16[a]': 'symmetric: the Majorana kinetic term theta^T Cplus gamma d theta is dynamical',
}
table = [('sigma16', [S16]), ('sigma16 T16[a]', [S16 @ T16[a] for a in range(8)]), ('sigma16 Gamma_ab', [S16 @ M for M in G2]),
         ('sigma16 Gamma_abc', [S16 @ M for M in G3]), ('sigma16 Gamma_abcd', [S16 @ M for M in G4]), ('sigma16 T16[8]', [S16 @ T8]),
         ('Cplus = sigma16 T16[8]', [Cplus]), ('Cplus T16[a]', [Cplus @ T16[a] for a in range(8)])]
rows = []
print(f"\n{'matrix':24s} {'count':>5s}  {'all symmetric':>13s}  {'all antisym.':>12s}  what it means for a REAL Grassmann 16-spinor theta")
for label, mats in table:
    s_all, a_all = all(sym(M) for M in mats), all(asym(M) for M in mats)
    rows.append(dict(matrix=label, count=len(mats), all_symmetric=s_all, all_antisymmetric=a_all, consequence=consequence[label]))
    print(f'{label:24s} {len(mats):5d}  {str(s_all):>13s}  {str(a_all):>12s}  {consequence[label]}')
assert [r['all_symmetric'] for r in rows] == [True, False, False, True, True, True, True, True]
assert [r['all_antisymmetric'] for r in rows] == [False, True, True, False, False, False, False, False]

# every Spin(4,4)-invariant bilinear form: M Sigma + Sigma^T M = 0 for the 28 generators (row-major vec)
L = np.vstack([np.kron(np.eye(16), S.T) + np.kron(S.T, np.eye(16)) for S in G2]).astype(float)
sv = np.linalg.svd(L, compute_uv=False)
dim_inv = 256 - int(np.sum(sv > 1e-9 * sv[0]))
inv = lambda M: all(np.array_equal(M @ S + S.T @ M, np.zeros((16, 16), dtype=int)) for S in G2)
chir_diag = lambda M: np.array_equal(M[:8, 8:], Z8) and np.array_equal(M[8:, :8], Z8)
print(f'\ndimension of the space of Spin(4,4)-invariant bilinear forms on R^16: {dim_inv}')
print(f'sigma16 invariant {inv(S16)}, symmetric {sym(S16)}, chirality-diagonal {chir_diag(S16)};  '
      f'sigma16 T16[8] invariant {inv(S16 @ T8)}, symmetric {sym(S16 @ T8)}, chirality-diagonal {chir_diag(S16 @ T8)};  Cplus == sigma16 T16[8]: {np.array_equal(Cplus, S16 @ T8)}')
assert dim_inv == 2 and inv(S16) and inv(S16 @ T8) and chir_diag(S16) and chir_diag(S16 @ T8)
# a single chirality: the kinetic matrices M T16[a] restricted to one chirality vanish for both invariant forms
Pm, Pp = (I16 - T8) // 2, (I16 + T8) // 2
weyl_zero = all(np.array_equal(P @ M @ T16[a] @ P, np.zeros((16, 16), dtype=int)) for M in (S16, S16 @ T8) for P in (Pm, Pp) for a in range(8))
print(f'Weyl / Majorana-Weyl: P_chir (M T16[a]) P_chir == 0 for both invariant forms M, both chiralities, all a: {weyl_zero}')
assert weyl_zero
# the commutant of the observer's Clifford algebra T16[1..4]: dimension 16 = M4(C), i.e. four Dirac flavours
Lc = np.vstack([np.kron(np.eye(16), T16[a].T) - np.kron(T16[a], np.eye(16)) for a in (1, 2, 3, 4)]).astype(float)
svc = np.linalg.svd(Lc, compute_uv=False)
dim_comm = 256 - int(np.sum(svc > 1e-9 * svc[0]))
print(f'commutant of {{T16[1], T16[2], T16[3], T16[4]}} in the 16x16 matrices: dimension {dim_comm} (= 4 x 4): C^16 = C^4 (observer Dirac spinor) x C^4 (four flavours)')
assert dim_comm == 16
with open(RESULTS / 'nb05_clifford_table.csv', 'w', newline='') as f:
    wr = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
    wr.writeheader(); wr.writerows(rows)
print('written: results/nb05_clifford_table.csv')
'''))
    cells.append(md(r"""
### 3.2 The field equations and the number current (stated; the notebook checks their consequences)

Varying `Ψbar` and `Ψ` independently gives the Dirac equation in the primordial gravitational field
and its adjoint (written out, component by component, in section 4).  The action has one `U(1)`
symmetry, `Ψ → e^{iα}Ψ`; its current is `j^μ = i Ψbar γ^μ Ψ` (`i σ16 γ^μ` is Hermitian).  The
**number current** `n^μ := −(i/H) Ψbar γ^μ Ψ` has `n⁴ = Ψ^† Ψ/H ≥ 0`, and `N = ∫ Sqrt[|g|] n⁴` is the
normal-ordered number of particles minus antiparticles: the `n` of the Kohn–Sham gas below.  The
axial phase `e^{iα T16[8]}` leaves `V(s)` invariant but not the kinetic term (the reverse of four
dimensions), so the only `U(1)` of the action is the vector one.
"""))
    cells.append(md(r"""
### 3.3 Canonical quantization: the Krein form, `J`, and eight particles plus eight antiparticles

With `x4` as time the kinetic term is `Ψbar γ⁴ ∂_4Ψ = i Ψ^‡ G ∂_4Ψ`, `G = −i σ16 γ⁴`, so the
Hamiltonian density matrix is `K = G h`, where `∂_4Ψ = −i h Ψ` for a plane wave.  For a plane wave
`Ψ = u e^{i k·x − i ω x4}` of the Dirac equation `γ^μ ∂_μΨ = mΨ` on the flat frame,
`h = −T16[4] (Σ_j k_j T16[j] + i m)`.  The cell checks: `G` is Hermitian, `G² = 1`, eight
eigenvalues `+1` and eight `−1` (a Krein form), `G = J`, `J` commutes with `T16[0…4]` and `σ16` and
anticommutes with `T16[5], T16[6], T16[7]` and `T16[8]`, and `σ16 = J β` with `β = −i T16[4]`.  For
momenta in `span(x0…x3)`: `h² = ω²` with `ω = Sqrt[k² + m²]`, `[G, h] = 0`, and the four joint
eigenspaces of `h` (frequency `±ω`) and `J` (sign `η = ±1`) each have dimension 4 — so the Krein form
restricted to one frequency has signature (4, 4), and the naive quantization would contain
negative-norm states.  In the `J`-eigenbasis every mode has `u^‡ G u = η`, energy per quantum
`η u^‡ K u = ω` (the same sign for both `η`) and scalar density per quantum `η u^‡ σ16 u = m/ω`: after
the involution `b^† := η b^‡` all eight positive-frequency modes are particles of energy `+ω`, the
eight negative-frequency modes form the Dirac sea, and `σ = g ∫ d³k/(2π)³ m/ω` over the Fermi ball —
the Kohn–Sham scalar density of 5.1.  A momentum along the hidden timelike sheet above threshold
gives complex frequencies.
"""))
    cells.append(code(r'''
G = -1j * (S16 @ T16[4])
J = -1j * (T16[0] @ T16[1] @ T16[2] @ T16[3] @ T16[4])
beta = -1j * T16[4]
I = np.eye(16)
checks = {
    'G Hermitian': np.allclose(G, G.conj().T), 'G^2 = 1': np.allclose(G @ G, I),
    'G has eight eigenvalues +1 and eight -1': list(np.round(np.linalg.eigvalsh(G), 12)).count(1.0) == 8,
    'G == J (flat and canonical frames: gamma^4 = T16[4])': np.allclose(G, J),
    'J commutes with T16[0..4]': all(np.allclose(J @ T16[a], T16[a] @ J) for a in range(5)),
    'J anticommutes with T16[5], T16[6], T16[7]': all(np.allclose(J @ T16[a], -T16[a] @ J) for a in range(5, 8)),
    'J commutes with sigma16': np.allclose(J @ S16, S16 @ J), 'J anticommutes with T16[8]': np.allclose(J @ T8, -T8 @ J),
    'sigma16 = J beta, beta = -i T16[4]': np.allclose(S16, J @ beta),
}
for k, v in checks.items():
    print(f'{k:55s} {v}')
assert all(checks.values())


def h_matrix(k, m):
    """d_4 Psi = -i h Psi for Psi = u exp(i k.x - i w x4), gamma^mu d_mu Psi = m Psi on the flat frame (k[4] unused)."""
    kT = sum(k[j] * T16[j] for j in range(8) if j != 4)
    return -T16[4] @ (kT + 1j * m * I)


print(f"\n{'momentum k (x0..x3 | x5..x7)':34s} {'m':>5s} {'omega':>9s} {'sign':>4s} {'eta':>4s} {'dim':>3s} {'u^G u':>6s} {'eta u^K u':>10s} {'eta u^s16 u':>11s} {'m/omega':>9s}")
mode_rows = []
for k, m in [((0, 0.75, 1, 0, 0, 0, 0, 0), 1.0), ((0.3, -0.2, 0.5, 1.1, 0, 0, 0, 0), 0.7), ((0, 2.0, 0, 0, 0, 0, 0, 0), -1.3)]:
    h = h_matrix(k, m)
    K = G @ h
    w = math.sqrt(sum(k[j] ** 2 for j in range(4)) + m * m)
    assert np.allclose(K, K.conj().T) and np.allclose(G @ h, h @ G) and np.allclose(h @ h, w * w * I)
    for sgn in (+1, -1):
        for eta in (+1, -1):
            P = (I + sgn * h / w) / 2 @ (I + eta * J) / 2          # the joint spectral projector (h and J commute)
            U, S, _ = np.linalg.svd(P)
            B = U[:, : int(np.sum(S > 1e-9))]
            norms = [np.vdot(B[:, i], G @ B[:, i]).real for i in range(B.shape[1])]
            energies = [eta * np.vdot(B[:, i], K @ B[:, i]).real for i in range(B.shape[1])]
            scal = [eta * np.vdot(B[:, i], S16 @ B[:, i]).real for i in range(B.shape[1])]
            assert B.shape[1] == 4 and np.allclose(norms, eta) and np.allclose(energies, sgn * w) and np.allclose(scal, m / (sgn * w))
            mode_rows.append((k, m, sgn * w, eta, B.shape[1]))
            print(f'{str(k[:4]) + " | " + str(k[5:]):34s} {m:5.2f} {sgn * w:+9.5f} {sgn:+4d} {eta:+4d} {B.shape[1]:3d} {norms[0]:+6.2f} {energies[0]:+10.5f} {scal[0]:+11.6f} {m / (sgn * w):+9.6f}')
print('\nper spatial momentum: 8 modes of frequency +omega (particles, energy +omega each after b^dagger = eta b^ddag) and 8 of frequency -omega (the Dirac sea): g = 8')

# a momentum along the hidden timelike sheet, above threshold: complex frequencies
k_h = (0, 0.75, 1, 0, 0, 2.0, 0, 0)
ev = np.linalg.eigvals(h_matrix(k_h, 1.0))
w2 = 0.75 ** 2 + 1.0 ** 2 - 2.0 ** 2 + 1.0 ** 2
print(f'k = {k_h[:4]} | k5 = {k_h[5]}, m = 1: omega^2 = k_obs^2 - k_h^2 + m^2 = {w2:+.4f}; the 16 eigenvalues of h have |Re| <= {np.abs(ev.real).max():.1e} '
      f'and Im = +-{np.abs(ev.imag).max():.5f} (sqrt(-omega^2) = {math.sqrt(-w2):.5f}): exponential growth in x4, the ultrahyperbolic Cauchy problem')
assert np.abs(ev.real).max() < 1e-9 and abs(np.abs(ev.imag).max() - math.sqrt(-w2)) < 1e-9
'''))
    cells.append(md(r"""
## 4. The equations of motion

**The field equations in the primordial gravitational field.**  Varying the symmetrized action,

    γ^μ D_μΨ = H V′(s) Ψ ,          (D_μΨbar) γ^μ = −H V′(s) Ψbar .

On the canonical frame `γ^μ Γ_μ = −3H Cot[6Hx0]² T16[0]` (in frame-independent form
`γ^μ Γ_μ = −½ T_μ γ^μ` with `T_μ` the Weitzenböck torsion vector), and the rescaling
`Ψ = Sqrt[Sin[6Hx0]] Ψ′` removes it exactly:

    Cot[6Hx0] T16[0] ∂_0Ψ′ + (1/q) Σ_{i=1..3} T16[i] ∂_iΨ′ + T16[4] ∂_4Ψ′ + (1/p) Σ_{h=5..7} T16[h] ∂_hΨ′ = H V′(s) Ψ′ ,

with `s = Sin[6Hx0] Ψ′bar Ψ′`.  In the split-octonion 8+8 form, `Ψ = (ψ1, ψ2)`:

    e_a^μ taubar[a] (∂_μ + Γ^(2)_μ) ψ2 = H V′(s) ψ1 ,     e_a^μ tau[a] (∂_μ + Γ^(1)_μ) ψ1 = H V′(s) ψ2 ,
    s = −ψ1^‡ σ ψ1 + ψ2^‡ σ ψ2 ,

and on the canonical frame the connection term is `−3H Cot² ψ2` in the upper and `−3H Cot² ψ1` in
the lower block.  As an operator equation the right-hand side is `H :V′(s) Ψ:`; this is exact for
linear `V`, and for nonlinear `V` it differs by Hartree and Fock contractions with the coincident
propagator.  In the **Kohn–Sham mean field** `V′(s) → V′(⟨s⟩)` the equation is linear: a free Dirac
field of mass `m = H V′(⟨s⟩) = W′(σ)`.

**The gap equation.**  The mass and the scalar density must agree:

    m = W′( σ_KS(m, kF) / v ) ,       σ_KS(m, kF) = (g m / (4π²)) [ kF wF − m² asinh(kF/|m|) ] ,

(`v` the hidden volume factor, 1 in this notebook).  Since `σ_KS` is odd and increasing in `m` with
slope `χ = ∂σ_KS/∂m ≤ χ0 = g kF²/(4π²)`, the function `f(m) = m − W′(σ_KS/v)` has
`f′ = 1 − W″ χ/v`: the root is **unique** when `W″ ≤ 0` (attractive, concave `W`) or when
`W″ χ0/v < 1`; otherwise there can be several, and the one of lowest `ρ` is the ground state
(section 5.5).

**On the pre-universe.**  The `x4`-only rescaled family `Ψ = Sqrt[Sin] Ψ′(x4)` solves the equation
exactly when `V″ s′ = 0`: for linear `V` (the author's mass term) or for null data.  The Fermi gas
of the author's mass term therefore lives on the canonical frame without further conditions; its
momenta along the observed sheet redshift with `a4`, which section 5.7 turns into `w(a)`.

### 4.1 The first-order system actually handed to SUNDIALS

Two sections below run the solver's `fable4d` model (the present-universe model with the hidden
sheet held fixed): 5.7 to cross-check the cooling curve and 5.8 to cross-check the vacuum-energy
column.  Its units are `ħ = c = 1`, `H0 = 1` (time in `1/H0`), densities in `ρ_c0 = 3H0² M_pl²`,
masses and momenta in `E_c = ρ_c0^{1/4}` (printed by the setup cell).  Its independent variable is
`N = ln A`.  The Hubble rate is algebraic, `H_A² = ρ_r + ρ_b + ρ_f(N)` with `ρ_r = Ω_r0 A^{−4}`,
`ρ_b = Ω_b0 A^{−3}` and the fable at `kF = kF0/A` with the gap solved at every `N`; CVODE integrates
the single variable `τ = t/A²`:

    dτ/dN = −2τ + A^{−2} / H_A(N) ,          τ(N0) = t(N0)/A0²,   t(N0) = 1/(2 H_A(N0)) ,

with BDF, Newton iteration, a dense Jacobian, `rtol = 1e−10`, `atol = 1e−12`, from `A0 = 1e−12` to
`A = 1`.  The normalization is a closure today: for the mass term the solver shoots `ln kF0`
(bracket and Brent) until `ρ_r + ρ_b + ρ_f = 1` at `A = 1`.
"""))
    cells.append(md(r"""
## 5. Running the solver

The binary is `rust/fable_fermion/target/release/fable_fermion` (`.exe` on Windows), built by the
setup.  Its command lines are

    fable_fermion fable4d|fable8d --potential NAME [--param KEY=VALUE ...] [--direction forward|backward]
                  [--a-start A] [--points K] [--out FILE.csv] [--rtol R] [--atol A] [--method bdf|adams]
                  [--branch lowest|positive|negative] [--freeze-hidden] [--no-shoot] [--no-fable]
                  [--omega-b X] [--omega-r X]
    fable_fermion gap --form NAME --param KEY=VALUE ... --kf KF [--v V]
    fable_fermion --constants | --version

`gap` solves the gap equation once and prints every root with `m, sigma8, rho8, P_obs, P_hid,
gap_residual` (16 significant digits) and the selected root; `--constants` prints the unit system.
A `fable4d`/`fable8d` run writes a CSV that starts with `#` comment lines (the version, a
machine-readable `# params:` line with the normalized parameters, the definitions of the columns),
then a header line and one row per output point; its log (normalization, result, `a_nr`, `ΔN_eff`,
the stabilizer, the `# stats:` line with the CVODE step counts) goes to stderr.  Exit code 0 is
success; 1 is a solver or physics error with a one-line reason (including the refusals of a
first-order transition or of a negative-energy ground state); 2 is a usage error (an unknown model,
option or potential name, a non-numeric value).

The next cell locates the binary, reads the unit system from it (nothing is hard-coded), and defines
the helpers used below: the CSV reader and runner, and an independent Python Kohn–Sham toolkit — the
three integrals in closed form, as a series and by adaptive quadrature, the Fermi sea, the six
potentials, a gap solver that finds every root, the mean field, and the Dirac-sea energy.
"""))
    cells.append(code(FERMION_SETUP_CODE))
    # ---- 5.1
    cells.append(md(r"""
### 5.1 The Fermi-sea closed forms, their stable forms, and quadrature, over `x = kF/|m|` from `1e−8` to `1e6`

With `x = kF/|m|`, `r = Sqrt[1 + x²]` and `A = asinh x` the Fermi-sea integrals are

    n = g kF³/(6π²),   σ_KS = g m |m|² I1/(2π²),   ε_KS = g |m|⁴ I2/(2π²),   P_KS = g |m|⁴ I3/(6π²),
    I1 = (x r − A)/2,   I2 = (x r (2x² + 1) − A)/8,   I3 = (x r (2x² − 3) + 3A)/8 ,

which are `σ_KS = (g m/(4π²)) [kF wF − m² asinh x]`, `ε_KS = (g/(16π²)) [kF wF (2kF² + m²) − m⁴ asinh x]`,
`P_KS = (g/(48π²)) [kF wF (2kF² − 3m²) + 3m⁴ asinh x]` with `wF = Sqrt[kF² + m²]`.  For `x ≪ 1` the
closed forms are small differences of large numbers; the **stable forms** use the binomial series
`I1 = Σ binom(−½, j) x^{2j+3}/(2j+3)`, `I2 = Σ binom(½, j) x^{2j+3}/(2j+3)`,
`I3 = Σ binom(−½, j) x^{2j+5}/(2j+5)` below `x = 0.25`.  The cell evaluates both against adaptive
quadrature of the defining integrals on 281 values of `x`, plots the relative errors, asserts that
the stable forms agree with quadrature to `1e−12` everywhere, and then compares the stable forms
with the Rust solver itself (`fable_fermion gap --form mass --param m0=1 --kf x`, whose `sigma8`,
`rho8` and `P_obs` are `σ_KS`, `ε_KS` and `P_KS` for the mass term).  The Rust code switches at
`x = 0.6` and `x = 100` to its own series; the two implementations share no code.
"""))
    cells.append(code(r'''
xs = np.geomspace(1e-8, 1e6, 281)
acc = []
for x in xs:
    q, s, c = ks_I_quad(x), ks_I_stable(x), ks_I_closed(x)
    rel = lambda u, v: abs(u / v - 1.0) if v != 0 else float('inf')
    acc.append([x] + [rel(s[i], q[i]) for i in range(3)] + [rel(c[i], q[i]) for i in range(3)])
acc = np.array(acc)
worst_stable = acc[:, 1:4].max()
print(f'max relative error of the stable forms against quadrature over 1e-8 <= x <= 1e6: {worst_stable:.2e} '
      f'(at x = {acc[np.unravel_index(acc[:, 1:4].argmax(), acc[:, 1:4].shape)[0], 0]:.3g})')
for x0 in (1e-8, 1e-6, 1e-4, 1e-2, 0.25, 1.0, 1e2, 1e6):
    i = int(np.argmin(np.abs(np.log(xs / x0))))
    print(f'  x = {xs[i]:9.3g}:  stable rel. errors (sigma, eps, P) = {acc[i, 1]:.1e} {acc[i, 2]:.1e} {acc[i, 3]:.1e}   '
          f'closed forms: {acc[i, 4]:.1e} {acc[i, 5]:.1e} {acc[i, 6]:.1e}')
assert worst_stable < 1e-12, 'the stable forms must agree with quadrature to 1e-12'
with open(RESULTS / 'nb05_ks_accuracy.csv', 'w', newline='') as f:
    wr = csv.writer(f)
    wr.writerow(['x', 'rel_err_stable_sigma', 'rel_err_stable_eps', 'rel_err_stable_P', 'rel_err_closed_sigma', 'rel_err_closed_eps', 'rel_err_closed_P'])
    wr.writerows([[f'{v:.10e}' for v in row] for row in acc])

fig, ax = plt.subplots(figsize=(8.5, 4.6))
floor = 1e-17
for i, (lab, col) in enumerate([('sigma', 'tab:blue'), ('eps', 'tab:orange'), ('P', 'tab:green')]):
    ax.loglog(xs, np.clip(acc[:, 4 + i], floor, 10), '--', color=col, lw=1.0, label=f'{lab}: closed forms')
    ax.loglog(xs, np.clip(acc[:, 1 + i], floor, 10), '-', color=col, lw=1.4, label=f'{lab}: stable forms')
ax.axvline(X_SWITCH, color='0.5', lw=0.8, ls=':', label='series / closed switch, x = 0.25')
ax.set_xlabel('x = kF/|m|'); ax.set_ylabel('|relative error| against quadrature (floor 1e-17, cap 10)')
ax.set_title('Kohn-Sham Fermi-sea integrals: closed forms versus stable forms'); ax.legend(fontsize=7, ncol=2)
fig.savefig(RESULTS / 'nb05_ks_accuracy.png', dpi=130, bbox_inches='tight'); print('figure: results/nb05_ks_accuracy.png'); plt.show()

# the same numbers from the Rust solver (mass term, m = 1: sigma8 = sigma_KS, rho8 = eps_KS, P_obs = P_KS)
worst_rust = 0.0
print(f"\n{'x = kF/m':>10s} {'sigma rust':>23s} {'sigma python':>23s} {'rel':>8s} {'eps rel':>8s} {'P rel':>8s}")
for x in (1e-8, 1e-6, 1e-4, 1e-2, 0.2, 0.25, 0.3, 0.6, 1.0, 3.0, 10.0, 99.0, 101.0, 1e4, 1e6):
    r = subprocess.run([str(BIN), 'gap', '--form', 'mass', '--param', 'm0=1', '--kf', repr(x)], check=True, capture_output=True, text=True)
    vals = [l for l in r.stdout.splitlines() if not l.startswith('#') and not l.startswith('m,')][0].split(',')
    s_r, e_r, p_r = float(vals[1]), float(vals[2]), float(vals[3])
    fs = fermi_sea(1.0, x)
    rels = [abs(s_r / fs['sigma'] - 1), abs(e_r / fs['eps'] - 1), abs(p_r / fs['P'] - 1)]
    worst_rust = max(worst_rust, max(rels))
    print(f'{x:10.3g} {s_r:23.15e} {fs["sigma"]:23.15e} {rels[0]:8.1e} {rels[1]:8.1e} {rels[2]:8.1e}')
print(f'largest relative difference Rust - Python over these 15 points: {worst_rust:.2e}')
assert worst_rust < 1e-12
'''))
    # ---- 5.2
    cells.append(md(r"""
### 5.2 The equation of state of the Fermi sea, `w_KS(x) = P_KS/ε_KS`, from 1/3 to 0

`w_KS` depends on `x = kF/|m|` alone.  For `x → ∞` (ultra-relativistic) `ε_KS → 3P_KS` and
`w_KS → (1/3)(1 − 2/x²)`; for `x → 0` (non-relativistic) `ε_KS → |m| n` and `w_KS → x²/5`.  The cell
evaluates `w_KS` on the same grid, checks that it increases monotonically, and checks both
asymptotic forms; the curve is written to `results/nb05_w_ks.csv` and plotted.  This single function
is the whole equation of state of the author's mass term (`U = W − σW′ = 0`), in the pre-universe
and in the present universe alike.
"""))
    cells.append(code(r'''
wks = np.array([fermi_sea(1.0, x)['P'] / fermi_sea(1.0, x)['eps'] for x in xs])
print(f'w_KS at x = 1e-8: {wks[0]:.6e}  (x^2/5 = {xs[0] ** 2 / 5:.6e});  at x = 1: {np.interp(0.0, np.log(xs), wks):.6f};  at x = 1e6: {wks[-1]:.15f}  (1/3 - 2/(3 x^2) = {1 / 3 - 2 / (3 * xs[-1] ** 2):.15f})')
assert np.all(np.diff(wks) > 0), 'w_KS increases monotonically with x'
assert abs(wks[0] / (xs[0] ** 2 / 5) - 1) < 1e-6 and abs(wks[-1] - (1 / 3 - 2 / (3 * xs[-1] ** 2))) < 1e-14
small, large = xs < 1e-3, xs > 1e3
nr_dev = np.max(np.abs(wks[small] / (xs[small] ** 2 / 5) - 1))
ur_dev = np.max(np.abs(wks[large] - (1 - 2 / xs[large] ** 2) / 3))
print(f'max |w_KS/(x^2/5) - 1| for x < 1e-3: {nr_dev:.2e} (the next order is O(x^2));  '
      f'max |w_KS - (1/3)(1 - 2/x^2)| for x > 1e3: {ur_dev:.2e} (the next order is O(ln x / x^4))')
assert nr_dev < 1e-5 and ur_dev < 1e-10
with open(RESULTS / 'nb05_w_ks.csv', 'w', newline='') as f:
    wr = csv.writer(f); wr.writerow(['x', 'w_KS']); wr.writerows([[f'{a:.10e}', f'{b:.15e}'] for a, b in zip(xs, wks)])
fig, ax = plt.subplots(figsize=(7.5, 4.2))
ax.semilogx(xs, wks, lw=1.6, label='w_KS = P_KS/eps_KS')
ax.semilogx(xs[xs < 1], xs[xs < 1] ** 2 / 5, ':', color='tab:red', label='x^2/5 (non-relativistic)')
ax.semilogx(xs[xs > 1], (1 - 2 / xs[xs > 1] ** 2) / 3, ':', color='tab:green', label='(1/3)(1 - 2/x^2) (ultra-relativistic)')
ax.axhline(1 / 3, color='0.6', lw=0.6); ax.axhline(0, color='0.6', lw=0.6)
ax.set_ylim(-0.02, 0.36); ax.set_xlabel('x = kF/|m|'); ax.set_ylabel('w'); ax.legend(fontsize=8)
ax.set_title('The degenerate fable gas: from radiation (1/3) to dust (0)')
fig.savefig(RESULTS / 'nb05_w_ks.png', dpi=130, bbox_inches='tight'); print('figure: results/nb05_w_ks.png'); plt.show()
'''))
    # ---- 5.3
    cells.append(md(r"""
### 5.3 The thermodynamic identities

At zero temperature the chemical potential is `wF`, and the Fermi sea obeys, for every `x` and both
signs of `m`:

    ε_KS − 3 P_KS = m σ_KS            (the trace identity; T_s := ε_KS − m σ_KS = 3 P_KS)
    ε_KS + P_KS  = wF n               (Gibbs–Duhem, μ = wF)
    ∂ε_KS/∂n |_m = wF ,   ∂ε_KS/∂m |_kF = σ_KS      (the first law  dε = wF dn + σ dm)
    χ = ∂σ_KS/∂m |_kF > 0,  χ ≤ χ0 = g kF²/(4π²)

The first law is what makes the self-consistent fluid conserve energy exactly: at a gap root the
`σ dm` terms cancel, so `dρ = wF dn`, and `ρ + P_obs = wF n ≥ 0` for **every** potential — the
quantized fable cannot have `w < −1` where `ρ > 0`.  The cell checks each identity on 41 values of
`x` from `1e−4` to `1e4` for `m = ±1.3`; the derivatives by central differences (step `1e−5`
relative) on the points with `1e−2 ≤ x ≤ 1e2` (outside that range a difference of the energy
cannot resolve `σ dm`: for `x ≫ 1` the change `σ h` is below the rounding of `ε ∝ kF⁴`, for `x ≪ 1`
the change of `σ ≈ n` with `m` is below the rounding of `n`).  The largest residuals go to
`results/nb05_identities.csv`.
"""))
    cells.append(code(r'''
ident = {'eps - 3P - m sigma (rel. to eps)': 0.0, 'eps + P - wF n (rel.)': 0.0, 'd eps/dn|m - wF (rel.)': 0.0,
         'd eps/dm|kF - sigma (rel.)': 0.0, 'chi - d sigma/dm (rel.)': 0.0, 'max chi/chi0': 0.0}
for m in (1.3, -1.3):
    for x in np.geomspace(1e-4, 1e4, 41):
        kf = x * abs(m)
        s = fermi_sea(m, kf)
        ident['eps - 3P - m sigma (rel. to eps)'] = max(ident['eps - 3P - m sigma (rel. to eps)'], abs(s['eps'] - 3 * s['P'] - m * s['sigma']) / s['eps'])
        ident['eps + P - wF n (rel.)'] = max(ident['eps + P - wF n (rel.)'], abs((s['eps'] + s['P']) / (s['wF'] * s['n']) - 1))
        ident['max chi/chi0'] = max(ident['max chi/chi0'], s['chi'] / (G_FABLE * kf * kf / (4 * PI2)))
        if not 1e-2 <= x <= 1e2:
            continue                                   # central differences: only where they resolve the derivative
        h = 1e-5 * kf
        sp, sm = fermi_sea(m, kf + h), fermi_sea(m, kf - h)
        ident['d eps/dn|m - wF (rel.)'] = max(ident['d eps/dn|m - wF (rel.)'], abs((sp['eps'] - sm['eps']) / (sp['n'] - sm['n']) / s['wF'] - 1))
        hm = 1e-5 * abs(m)
        mp, mm = fermi_sea(m + hm, kf), fermi_sea(m - hm, kf)
        ident['d eps/dm|kF - sigma (rel.)'] = max(ident['d eps/dm|kF - sigma (rel.)'], abs((mp['eps'] - mm['eps']) / (2 * hm) / s['sigma'] - 1))
        ident['chi - d sigma/dm (rel.)'] = max(ident['chi - d sigma/dm (rel.)'], abs((mp['sigma'] - mm['sigma']) / (2 * hm) / s['chi'] - 1))
for k, v in ident.items():
    print(f'{k:36s} {v:.2e}')
assert ident['eps - 3P - m sigma (rel. to eps)'] < 1e-13 and ident['eps + P - wF n (rel.)'] < 1e-13
assert ident['d eps/dn|m - wF (rel.)'] < 1e-8 and ident['d eps/dm|kF - sigma (rel.)'] < 1e-7 and ident['chi - d sigma/dm (rel.)'] < 1e-6
assert ident['max chi/chi0'] <= 1.0 + 1e-12
with open(RESULTS / 'nb05_identities.csv', 'w', newline='') as f:
    wr = csv.writer(f); wr.writerow(['identity', 'largest_residual']); wr.writerows([[k, f'{v:.3e}'] for k, v in ident.items()])
print('written: results/nb05_identities.csv')
'''))
    # ---- 5.4
    cells.append(md(r"""
### 5.4 The non-relativistic limit is Part VI's classical fable — except for the phantom crossing

For `kF ≪ |m|` the Fermi sea expands as `σ_KS = sgn(m) n [1 − (3/10) x² + …]`,
`ε_KS = |m| n [1 + (3/10) x² + …]` and `P_KS = n kF²/(5|m|) [1 + …]`, so the mean-field fluid becomes

    ρ → W(sgn(m) n) + (3/10) n kF²/|m| ,     P_obs → [σW′ − W] + n kF²/(5|m|) ,     P_hid = σW′ − W ,

which is Part VI's classical `ρ = V(s)`, `P = sV′ − V`, `w = sV′/V − 1` with `s = Hσ` (its `K_h = 0`
branch).  Self-consistency forces `sgn σ = sgn m = sgn W′`, which removes Part VI's branch with
`M s > 0`; for the author's `W = −2Mσ`, `ρ → 2|M| n > 0`.  The first cell checks the three
expansion coefficients.  The second compares, for five of Part VI's potential shapes (`mass`
`V = s`; `lambda-mass` `V = 0.7 + 0.3 s`; `power` `V = s + s^0.236`; `expdamp`
`V = 1.566 + 0.839 s e^{−s/2.21}`; `lorentz` `V = 1 + s/(1 + (s/1.5)²)`), the classical
`w_cl(s = n)` with the quantum `w = P_obs/ρ` of the lowest-energy gap root at density `n`, for
`W = A V` with `A = 10⁴, 10², 1`: a large `A` makes the quasiparticles heavy (`m = A V′`), which is
the classical limit.  Below the classical crossing the quantum `w` approaches `w_cl` as `A` grows.
Where the classical `w_cl` drops below −1 (`expdamp` and `lorentz` for `s > s1`, where `V′ < 0`),
the quantum theory does **not** follow: the gap pins `σ` below `min(n, s1)`, the quasiparticles become
light and relativistic, and `w ≥ −1` at every root.
"""))
    cells.append(code(r'''
x = 1e-3
s = fermi_sea(2.0, 2.0 * x)
c_sigma = (s['sigma'] / s['n'] - 1) / x ** 2
c_eps = (s['eps'] / (2.0 * s['n']) - 1) / x ** 2
c_P = s['P'] / (s['n'] * (2.0 * x) ** 2 / 2.0)
print(f'at x = {x:g}: (sigma/n - 1)/x^2 = {c_sigma:+.6f} (-3/10),  (eps/(|m| n) - 1)/x^2 = {c_eps:+.6f} (+3/10),  P/(n kF^2/|m|) = {c_P:.6f} (1/5)')
assert abs(c_sigma + 0.3) < 1e-5 and abs(c_eps - 0.3) < 1e-5 and abs(c_P - 0.2) < 1e-5
s = fermi_sea(-2.0, 2.0 * x)
print(f'm = -2: sigma/n = {s["sigma"] / s["n"]:+.9f}: sgn(sigma) = sgn(m)')
assert s['sigma'] < 0
'''))
    cells.append(md(r"""
Now the comparison over densities `1e−3 ≤ n ≤ 30` (in units where the classical `s` equals `n`).
For every density and every `A` the cell finds all gap roots, takes the one of lowest `ρ`, and
records the quantum `w`, `σ/n`, `x = kF/|m|` and the number of roots; the classical `w_cl` is exact.
The assertions: `ρ + P_obs = wF n ≥ 0` at every root found (so `w ≥ −1` wherever `ρ > 0`); for
`expdamp`, `0 < σ < min(n, s1)` at every density; the classical `w_cl` of `expdamp` and `lorentz`
is below −1 at some density; and, below half the crossing density, the largest `|w − w_cl|` shrinks
as `A` grows.  The table goes to `results/nb05_classical_vs_quantum.csv`.
"""))
    cells.append(code(r'''
SHAPES = {'mass': Pot('mass', m0=1.0), 'lambda-mass': Pot('lambda-mass', v0=0.7, m0=0.3), 'power': Pot('power', m0=1.0, lam=1.0, nu=0.236),
          'expdamp': Pot('expdamp', v0=1.566, m0=0.839, s1=2.21), 'lorentz': Pot('lorentz', v0=1.0, m0=1.0, s1=1.5)}
AS = [1e4, 1e2, 1.0]
ns = np.geomspace(1e-3, 30.0, 61)
cq_rows, curves = [], {}
t0 = time.time()
for name, V in SHAPES.items():
    wcl = np.array([n * V.dW(n) / V.W(n) - 1.0 for n in ns])
    curves[(name, 'classical')] = wcl
    for A in AS:
        W = V.scaled(A)
        wq, son, xr = [], [], []
        for n in ns:
            kf = (6 * PI2 * n / G_FABLE) ** (1 / 3)
            roots = gap_roots(W, kf, ngrid=1201)
            mfs = [mean_field(W, m, kf) for m in roots]
            for d in mfs:                                   # rho + P_obs = wF n >= 0 on EVERY root
                assert abs((d['rho'] + d['P_obs']) / (d['wF'] * d['n8']) - 1) < 1e-9 and d['rho'] + d['P_obs'] >= 0
            b = min(mfs, key=lambda d: d['rho'])
            if name == 'expdamp':
                assert 0 < b['sigma8'] < min(n, V.p['s1']), (n, b['sigma8'])
            w = b['P_obs'] / b['rho']
            if b['rho'] > 0:
                assert w >= -1 - 1e-12
            wq.append(w); son.append(b['sigma8'] / n); xr.append(kf / abs(b['m']) if b['m'] != 0 else float('inf'))
            cq_rows.append(dict(potential=name, A=A, n=n, w_classical=float(V.dW(n) * n / V.W(n) - 1), w_quantum=w, sigma_over_n=b['sigma8'] / n,
                                x_kF_over_m=xr[-1], n_roots=len(roots), rho_over_A=b['rho'] / A))
        curves[(name, A)] = (np.array(wq), np.array(son), np.array(xr))
print(f'{len(cq_rows)} (potential, A, n) points in {time.time() - t0:.1f} s')
for name in SHAPES:
    wcl = curves[(name, 'classical')]
    cross = crossing_points(ns, wcl, -1.0)
    line = f'{name:12s} classical: min w_cl = {wcl.min():+.4f}' + (f', crosses -1 at n = {", ".join(f"{c:.4f}" for c in cross)}' if cross else ', never crosses -1')
    for A in AS:
        wq = curves[(name, A)][0]
        below = ns < 0.5 * (cross[0] if cross else ns[-1])
        line += f' | A={A:g}: min w = {wq.min():+.5f}, max|w-w_cl| (n < half crossing) = {np.max(np.abs(wq[below] - wcl[below])):.2e}'
    print(line)
for name in ('expdamp', 'lorentz'):
    assert curves[(name, 'classical')].min() < -1.0, f'the classical {name} crosses the phantom divide'
    devs = [np.max(np.abs(curves[(name, A)][0][ns < 0.5 * crossing_points(ns, curves[(name, "classical")], -1.0)[0]] -
                          curves[(name, 'classical')][ns < 0.5 * crossing_points(ns, curves[(name, "classical")], -1.0)[0]])) for A in AS]
    assert devs[0] < devs[1] < devs[2], f'{name}: the quantum w approaches the classical one as A grows'
print('the quantum w >= -1 at every density, every A and every potential; the classical expdamp and lorentz cross -1')
with open(RESULTS / 'nb05_classical_vs_quantum.csv', 'w', newline='') as f:
    wr = csv.DictWriter(f, fieldnames=list(cq_rows[0].keys())); wr.writeheader()
    wr.writerows([{k: (f'{v:.10g}' if isinstance(v, float) else v) for k, v in r.items()} for r in cq_rows])
print('written: results/nb05_classical_vs_quantum.csv')

fig, axes = plt.subplots(1, 5, figsize=(19, 4.2), sharey=False)
for ax, name in zip(axes, SHAPES):
    ax.semilogx(ns, curves[(name, 'classical')], 'k-', lw=2.0, label='classical (Part VI): sV\'/V - 1')
    for A, col in zip(AS, ('tab:blue', 'tab:orange', 'tab:green')):
        ax.semilogx(ns, curves[(name, A)][0], '--', color=col, lw=1.3, label=f'quantum, W = {A:g} V')
    ax.axhline(-1.0, color='tab:red', lw=0.8)
    if name in ('expdamp', 'lorentz'):
        ax.axvline(SHAPES[name].p['s1'], color='0.5', ls=':', lw=0.8, label='s = s1 (V\' = 0)')
    ax.set_title(name); ax.set_xlabel('density n (= s)'); ax.set_ylim(-1.35, 0.4)
axes[0].set_ylabel('w'); axes[0].legend(fontsize=7, loc='lower left'); axes[3].legend(fontsize=7, loc='upper left')
fig.suptitle('Quantum (Kohn-Sham, lowest-energy gap root) versus classical w: no phantom crossing after quantization', y=1.02)
fig.savefig(RESULTS / 'nb05_classical_vs_quantum.png', dpi=130, bbox_inches='tight'); print('figure: results/nb05_classical_vs_quantum.png'); plt.show()
'''))
    # ---- 5.5
    cells.append(md(r"""
### 5.5 The gap equation: the uniqueness criterion, three roots, and a first-order jump

For the repulsive quadratic `W = m0 σ + (λ/2) σ²` with `(m0, λ) = (0.05, 20)`, `W″ χ0 = λ g kF²/(4π²)`
passes 1 at the `kF = Sqrt[4π²/(λ g)]` that the cell prints; above it the uniqueness argument no longer applies.  At `kF = 1` the
cell plots `f(m) = m − W′(σ_KS(m))`, finds its roots with the Python gap solver, and compares the
roots and their `ρ`, `P_obs`, `P_hid` with the Rust solver's `gap` command.  It checks
`ρ + P_obs = wF n` on each root (so `w ≥ −1` on every branch) and marks the lowest-energy root, the
ground state.  It then follows the ground state as `kF` grows from 0.2 to 2: where the three roots
appear, the lowest-energy root jumps from the positive-mass branch to the negative-mass branch — a
first-order transition, which is why the solver refuses a repulsive quadratic run (energy
conservation would need a Maxwell construction).  At `kF = 0.4`, below the criterion, the root is
unique.  The data go to `results/nb05_gap_roots.csv`.
"""))
    cells.append(code(r'''
Wrep = Pot('quadratic', v0=0.0, m0=0.05, lam=20.0)
kf = 1.0
chi0 = G_FABLE * kf * kf / (4 * PI2)
roots = gap_roots(Wrep, kf)
mfs = [mean_field(Wrep, m, kf) for m in roots]
gs = min(mfs, key=lambda d: d['rho'])
print(f'kF = {kf}: W\'\' chi0 = lam g kF^2/(4 pi^2) = {20 * chi0:.4f} > 1;  {len(roots)} roots')
r = subprocess.run([str(BIN), 'gap', '--form', 'quadratic', '--param', 'm0=0.05', '--param', 'lam=20', '--kf', '1'], check=True, capture_output=True, text=True)
print(r.stdout)
rust_rows = [list(map(float, l.split(','))) for l in r.stdout.splitlines() if l and not l.startswith('#') and not l.startswith('m,')]
assert len(rust_rows) == len(roots) == 3
print(f"{'m (python)':>22s} {'m (rust)':>22s} {'rho python':>14s} {'rel. diff':>9s} {'P_obs rel':>9s} {'P_hid rel':>9s} {'(rho+P)/(wF n)':>14s}  ground state")
for d, rr in zip(mfs, rust_rows):
    dr = [abs(d['m'] / rr[0] - 1), abs(d['rho'] / rr[2] - 1), abs(d['P_obs'] / rr[3] - 1), abs(d['P_hid'] / rr[4] - 1)]
    assert max(dr) < 1e-10, dr
    print(f"{d['m']:22.15e} {rr[0]:22.15e} {d['rho']:14.10f} {dr[1]:9.1e} {dr[2]:9.1e} {dr[3]:9.1e} {(d['rho'] + d['P_obs']) / (d['wF'] * d['n8']):14.12f}  {'<-- lowest rho' if d is gs else ''}")
rust_sel = float(re.search(r'm = ([-+0-9.e]+)', [l for l in r.stdout.splitlines() if l.startswith('# selected')][0]).group(1))
assert abs(rust_sel / gs['m'] - 1) < 1e-10, 'the Rust solver selects the same (lowest-energy) root'
print(f'both codes select m = {gs["m"]:.12e} (rho = {gs["rho"]:.12f})')

scan = []
for kf_s in np.linspace(0.2, 2.0, 73):
    rs = gap_roots(Wrep, kf_s)
    b = min((mean_field(Wrep, m, kf_s) for m in rs), key=lambda d: d['rho'])
    scan.append((kf_s, 20 * G_FABLE * kf_s ** 2 / (4 * PI2), len(rs), b['m'], b['rho'], min(rs), max(rs)))
scan = np.array(scan)
k_three = scan[scan[:, 2] == 3, 0].min()
jump = np.argmax(np.sign(scan[:, 3]) < 0)
print(f'uniqueness criterion lam chi0 < 1 holds for kF < {math.sqrt(4 * PI2 / (20 * G_FABLE)):.4f}; three roots first appear at kF = {k_three:.3f} on this grid; '
      f'the ground state jumps from m = {scan[jump - 1, 3]:+.4f} (kF = {scan[jump - 1, 0]:.3f}) to m = {scan[jump, 3]:+.4f} (kF = {scan[jump, 0]:.3f})')
assert scan[scan[:, 1] < 1, 2].max() == 1, 'below the criterion the root is unique'
r04 = gap_roots(Wrep, 0.4)
print(f'kF = 0.4: lam chi0 = {20 * G_FABLE * 0.16 / (4 * PI2):.3f} < 1 and {len(r04)} root (m = {r04[0]:.10f})')
with open(RESULTS / 'nb05_gap_roots.csv', 'w', newline='') as f:
    wr = csv.writer(f); wr.writerow(['kF', 'lam_chi0', 'n_roots', 'm_ground', 'rho_ground', 'm_min_root', 'm_max_root'])
    wr.writerows([[f'{v:.10g}' for v in row] for row in scan])

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12.5, 4.3))
mgrid = np.linspace(-3.2, 3.2, 1601)
for kf_p, col in ((1.0, 'tab:blue'), (0.4, 'tab:orange')):
    ax1.plot(mgrid, [gap_function(Wrep, m, kf_p) for m in mgrid], color=col, label=f'kF = {kf_p}: lam chi0 = {20 * G_FABLE * kf_p ** 2 / (4 * PI2):.2f}')
for d in mfs:
    ax1.plot(d['m'], 0, 'o', color='k' if d is gs else '0.6', ms=6)
ax1.axhline(0, color='k', lw=0.5); ax1.set_xlabel('m'); ax1.set_ylabel("f(m) = m - W'(sigma_KS(m))"); ax1.set_ylim(-3, 3)
ax1.set_title('repulsive quadratic (m0, lam) = (0.05, 20): roots (black = ground state)'); ax1.legend(fontsize=8)
ax2.plot(scan[:, 0], scan[:, 3], 'k.-', ms=3, label='ground-state m (lowest rho)')
ax2.fill_between(scan[:, 0], scan[:, 5], scan[:, 6], where=scan[:, 2] == 3, color='tab:red', alpha=0.12, label='range of the three roots')
ax2.axvline(math.sqrt(4 * PI2 / (20 * G_FABLE)), color='0.5', ls=':', label='lam chi0 = 1')
ax2.set_xlabel('kF'); ax2.set_ylabel('m'); ax2.set_ylim(-1.5, 1.5); ax2.legend(fontsize=8); ax2.set_title('the ground state jumps: a first-order transition')
fig.savefig(RESULTS / 'nb05_gap_roots.png', dpi=130, bbox_inches='tight'); print('figure: results/nb05_gap_roots.png'); plt.show()
'''))
    # ---- 5.6
    cells.append(md(r"""
### 5.6 The no-sea functional is a minimax; the Walecka functional is convex for attractive `W`

The Kohn–Sham energy of the gas at fixed `n` as a functional of the scalar density,
`E_n[σ] = T_s(σ; n) + W(σ)` with `T_s = ε_KS(m(σ)) − m(σ) σ` and `m(σ)` defined by `σ_KS(m, kF) = σ`,
has `dE_n/dσ = W′(σ) − m(σ)` (stationary exactly at the gap roots) and `d²T_s/dσ² = −1/χ < 0`: the
kinetic part is **concave**.  For the mass term the physical root is therefore a **maximum** of
`E_n` over `σ ∈ (−n, n)`, and the infimum is the variational collapse `E_n → −|m0| n` as `σ → −n`
(every particle in the negative-mass band, i.e. in states of the Dirac sea).  The ground state is a
stationary point of this minimax functional (a maximum in `σ`, a minimum in the occupations), never
its minimum over `σ`.  For attractive (concave) `W` the auxiliary-field **Walecka functional**
`Ω_n(m) = ε_KS(m) + W(σ_m) − m σ_m`, `W′(σ_m) = m`, is convex, its minimum is the gap root, and
`Ω_n(m*) = ρ`.  The cell draws both, for `W = 2σ` at `kF = 1.5` and `W = σ − 10σ²` at `kF = 1`, and
writes the curves to `results/nb05_minimax.csv`.
"""))
    cells.append(code(r'''
def m_of_sigma(s, kf):
    """The m with sigma_KS(m, kF) = s (sigma_KS is odd, increasing and maps R onto (-n, n))."""
    f = lambda m: fermi_sea(m, kf)['sigma'] - s
    hi, lo = kf, -kf
    while f(hi) < 0:
        hi *= 2
    while f(lo) > 0:
        lo *= 2
    return brentq(f, lo, hi, xtol=1e-300, rtol=1e-15, maxiter=500)


def E_n(pot, s, kf):
    m = m_of_sigma(s, kf)
    fs = fermi_sea(m, kf)
    return fs['eps'] - m * s + pot.W(s)


Wm, kfm = Pot('mass', m0=2.0), 1.5
n_m = G_FABLE * kfm ** 3 / (6 * PI2)
s_star = fermi_sea(2.0, kfm)['sigma']
E_star = E_n(Wm, s_star, kfm)
fr = np.concatenate([-1 + np.geomspace(1e-7, 1e-2, 25), np.linspace(-0.99, 0.99, 199), 1 - np.geomspace(1e-2, 1e-7, 25)])
E_curve = np.array([E_n(Wm, f_ * n_m, kfm) for f_ in fr])
print(f'mass term W = 2 sigma, kF = {kfm}: n = {n_m:.10f}, the gap root sigma* = {s_star:.10f} (sigma*/n = {s_star / n_m:.6f})')
print(f'E_n(sigma*) = {E_star:.12f} = rho = eps_KS(m0) = {fermi_sea(2.0, kfm)["eps"]:.12f};  max of E_n over the grid = {E_curve.max():.12f}')
print(f'E_n/n at sigma = -(1 - 1e-7) n: {E_curve[0] / n_m:+.6f}  (the collapse value -|m0| = {-2.0:+.1f})')
h = 1e-4 * n_m
assert E_n(Wm, s_star + h, kfm) < E_star and E_n(Wm, s_star - h, kfm) < E_star and E_curve.max() <= E_star + 1e-12
assert abs(E_star / fermi_sea(2.0, kfm)['eps'] - 1) < 1e-12 and abs(E_curve[0] / n_m + 2.0) < 1e-2

Wa, kfa = Pot('quadratic', v0=0.0, m0=1.0, lam=-20.0), 1.0
ra = gap_roots(Wa, kfa)
assert len(ra) == 1
ga = mean_field(Wa, ra[0], kfa)
Om = lambda m: fermi_sea(m, kfa)['eps'] + Wa.W((m - 1.0) / -20.0) - m * (m - 1.0) / -20.0
mg = np.linspace(-0.6, 1.0, 321)
Om_curve = np.array([Om(m) for m in mg])
print(f'\nattractive W = sigma - 10 sigma^2, kF = 1: unique gap root m* = {ra[0]:.10f}, rho = {ga["rho"]:.10f};  Omega_n(m*) = {Om(ra[0]):.12f}')
print(f'Omega_n on the grid: minimum {Om_curve.min():.12f} at m = {mg[Om_curve.argmin()]:.4f};  second differences all positive (convex): {bool(np.all(np.diff(Om_curve, 2) > 0))}')
assert abs(Om(ra[0]) / ga['rho'] - 1) < 1e-12 and np.all(np.diff(Om_curve, 2) > 0) and Om_curve.min() >= Om(ra[0]) - 1e-14
with open(RESULTS / 'nb05_minimax.csv', 'w', newline='') as f:
    wr = csv.writer(f); wr.writerow(['curve', 'abscissa', 'value'])
    wr.writerows([['E_n(sigma)/n, W=2 sigma, kF=1.5; abscissa sigma/n', f'{a:.10g}', f'{b / n_m:.12g}'] for a, b in zip(fr, E_curve)])
    wr.writerows([['Omega_n(m), W=sigma-10 sigma^2, kF=1; abscissa m', f'{a:.10g}', f'{b:.12g}'] for a, b in zip(mg, Om_curve)])
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12.5, 4.3))
ax1.plot(fr, E_curve / n_m, lw=1.5); ax1.plot(s_star / n_m, E_star / n_m, 'ko', label='gap root (the physical state): a MAXIMUM')
ax1.axhline(-2.0, color='tab:red', ls=':', label='collapse value -|m0|'); ax1.set_xlabel('sigma/n'); ax1.set_ylabel('E_n[sigma]/n')
ax1.set_title('no-sea functional, W = m0 sigma (m0 = 2, kF = 1.5)'); ax1.legend(fontsize=8)
ax2.plot(mg, Om_curve, lw=1.5); ax2.plot(ra[0], Om(ra[0]), 'ko', label='gap root: the minimum, Omega = rho')
ax2.set_xlabel('m'); ax2.set_ylabel('Omega_n(m)'); ax2.set_title('Walecka functional, W = sigma - 10 sigma^2 (kF = 1)'); ax2.legend(fontsize=8)
fig.savefig(RESULTS / 'nb05_minimax.png', dpi=130, bbox_inches='tight'); print('figure: results/nb05_minimax.png'); plt.show()
'''))
    # ---- 5.7
    cells.append(md(r"""
### 5.7 On the pre-universe: the charge is conserved per coordinate volume, the gas cools from 1/3 to 0

On the canonical frame `Sqrt[|det g|] = Sec[6Hx0]` does not depend on `x4`, so the conserved number
`N = ∫ Sqrt[|g|] n⁴` fixes the density per *coordinate* volume for all `x4`: the 8-density does not
dilute.  A mode with coordinate momentum `k` along `x1` has the physical momentum
`k/q = k e^{a4} Sin[6Hx0]^{1/6}`, so at fixed `x0` every observed-sheet momentum — and the Fermi
momentum — scales as `e^{a4} = 1/a` with `a := e^{−a4}` (the observed sheet grows while the hidden
timelike sheet shrinks, the 7-volume staying fixed).  For the author's mass term `W = −2Mσ`
(`|m| = 2|M|`, `U = 0`) the equation of state is `w_KS(x)` at `x = kF/|m| = a_nr/a`, with `a_nr` the
value of `a` at which `kF = |m|`: the quantum gas cools from `w = 1/3` to `w = 0` as `a4` decreases,
whereas the classical fable of Part VI has `ds/dx4 = 0` and a frozen `w = sV′/V − 1` (`= 0` for the
mass term).  `a4` itself is never given a value: the curve is plotted against `a/a_nr`.  The cell
checks the frame statements numerically at random `(x0, a4)`, then compares `w_KS(a_nr/a)` with the
Rust solver's `fable4d` run of the mass term (`m0 = 30 eV`), whose quasiparticle column `w_qp` is the
same function of `kF0/(A m)`; the sign of `m` does not enter (`ε`, `P` are even in `m`).
"""))
    cells.append(code(r'''
Hc = 0.37
worst, npts = 0.0, 0
for u6, a4 in itertools.product(np.linspace(0.01, 0.99, 15), np.linspace(-3.0, 3.0, 13)):
    x0 = u6 * math.pi / (12 * Hc)                   # 6 H x0 = u6 pi/2 in (0, pi/2)
    npts += 1
    S, C = math.sin(6 * Hc * x0), math.cos(6 * Hc * x0)
    q, p = math.exp(-a4) / S ** (1 / 6), math.exp(a4) / S ** (1 / 6)
    g = np.diag([(S / C) ** 2, q * q, q * q, q * q, -1.0, -p * p, -p * p, -p * p])
    worst = max(worst, abs(math.sqrt(abs(np.linalg.det(g))) * C - 1.0), abs((1.0 / q) / (math.exp(a4) * S ** (1 / 6)) - 1.0))
print(f'{npts} grid points (x0, a4), H = {Hc}: max |Sqrt|det g| Cos[6Hx0] - 1| and max |(k/q)/(k e^a4 Sin^(1/6)) - 1| = {worst:.1e}')
assert worst < 1e-12

run = run_fermion('nb05_fable4d_mass30', 'fable4d', '--potential', 'mass', '--param', 'm0_ev=30', '--points', '1001', label='fable4d mass 30 eV')
c, p = run['cols'], run['params']
x_rows = p['kf0'] / (c['a'] * abs(p['m0']))
w_py = np.array([fermi_sea(p['m0'], p['kf0'] / A)['P'] / fermi_sea(p['m0'], p['kf0'] / A)['eps'] for A in c['a']])
dw = np.max(np.abs(w_py - c['w_qp']))
a_nr = p['kf0'] / abs(p['m0'])
print(f'\nfable4d mass 30 eV: kF0 = {p["kf0"]:.10e} E_c, m0 = {p["m0"]:.10e} E_c, a_nr = kF0/m0 = {a_nr:.6e}  '
      f'(the solver logged a_nr = {log_value(run, "a_nr (kF = |m_eff|) ="):.6e})')
print(f'max |w_qp(Rust) - w_KS(kF0/(A m0))(Python)| over {len(c["a"])} rows = {dw:.2e}')
assert dw < 1e-12 and abs(log_value(run, 'a_nr (kF = |m_eff|) =') / a_nr - 1) < 1e-3
u = np.geomspace(1e-3, 1e3, 241)                     # a / a_nr
w_pre = np.array([fermi_sea(1.0, 1.0 / v)['P'] / fermi_sea(1.0, 1.0 / v)['eps'] for v in u])
with open(RESULTS / 'nb05_preuniverse_cooling.csv', 'w', newline='') as f:
    wr = csv.writer(f); wr.writerow(['a_over_a_nr', 'w']); wr.writerows([[f'{a:.10e}', f'{b:.15e}'] for a, b in zip(u, w_pre)])
fig, ax = plt.subplots(figsize=(7.5, 4.3))
ax.semilogx(u, w_pre, lw=1.8, label='quantum fable, author\'s mass term: w_KS(a_nr/a)')
ax.semilogx(c['a'] / a_nr, c['w_qp'], '--', color='tab:orange', lw=1.0, label='fable4d (Rust), m0 = 30 eV: w_qp')
ax.axhline(0, color='k', lw=1.2, label='classical Part VI (mass term): w = 0, frozen')
ax.set_xlim(1e-3, 1e3); ax.set_xlabel('a / a_nr   (a = e^{-a4})'); ax.set_ylabel('w'); ax.legend(fontsize=8)
ax.set_title('On the pre-universe the quantum fable gas cools from w = 1/3 to w = 0')
fig.savefig(RESULTS / 'nb05_preuniverse_cooling.png', dpi=130, bbox_inches='tight'); print('figure: results/nb05_preuniverse_cooling.png'); plt.show()
'''))
    # ---- 5.8
    cells.append(md(r"""
### 5.8 The Dirac-sea energy of a mass-varying fable

The no-sea functional drops the energy of the filled Dirac sea.  For a constant mass that energy is
a constant: it is absorbed into `V0` (it appears as a bare cosmological constant, and the
cosmological-constant problem is not solved).  For a mass that varies with the state, the
renormalized one-loop sea energy of the relativistic Hartree approximation (Chin 1977), with the
reference mass `M` (today's mass) and counterterms through `m⁴`,

    ΔE_vac(m) = −(g/(16π²)) [ m⁴ ln(m/M) + M³(M − m) − (7/2) M²(M − m)² + (13/3) M (M − m)³ − (25/12)(M − m)⁴ ] ,

vanishes like `(m − M)⁵` at `m = M` and reaches `ΔE_vac(0) = g M⁴/(64π²)` at `m = 0`.  It is not a
constant, so it cannot be absorbed into a bare `Λ`.  It can be absorbed only *formally*, by reading
`W` as the fully renormalized effective potential (the reading the solver and this notebook use:
the no-sea functional with `W` renormalized); that is a fine-tuning of the bare potential against
the sea energy, and the size of the tuning is `ΔE_vac(m(t)) − ΔE_vac(m_today)` in units of `ρ_c0`.
The cell tabulates and plots it for `M` = 1 eV, 30 eV, 100 eV and 1 keV, finds the mass above which
the full variation `g M⁴/(64π²)` exceeds `ρ_c0`, checks the fifth-order zero, and compares the
formula with the solver's column `vac_over_rhoc` along a `fable4d` run of the power potential
(`ν = 0.236`, `m_today = 30 eV`), in which the mass varies.
"""))
    cells.append(code(r'''
Ms_eV = [1.0, 30.0, 100.0, 1000.0]
mm = np.linspace(0.0, 2.0, 401)
vac_rows = []
for M_eV in Ms_eV:
    M = M_eV / E_C_EV
    for f_ in mm:
        vac_rows.append((M_eV, f_, delta_e_vac(f_ * M, M)))
vac = np.array(vac_rows)
M_star = (64 * PI2 / G_FABLE) ** 0.25 * E_C_EV
print(f'Delta E_vac(0; M) = g M^4/(64 pi^2): check {delta_e_vac(0.0, 7.0) / (G_FABLE * 7.0 ** 4 / (64 * PI2)):.15f};  '
      f'g M^4/(64 pi^2) exceeds rho_c0 for M > (64 pi^2/g)^(1/4) E_c = {M_star * 1e3:.3f} meV')
for M_eV in Ms_eV:
    M = M_eV / E_C_EV
    print(f'M = {M_eV:6g} eV: |Delta E_vac|/rho_c0 at m/M = 0.99: {abs(delta_e_vac(0.99 * M, M)):.3e};  0.9: {abs(delta_e_vac(0.9 * M, M)):.3e};  '
          f'0.5: {abs(delta_e_vac(0.5 * M, M)):.3e};  0: {abs(delta_e_vac(0.0, M)):.3e}')
r5 = delta_e_vac(1.02 * 3.0, 3.0) / delta_e_vac(1.01 * 3.0, 3.0)
print(f'fifth-order zero: Delta E_vac(M(1 + 2d))/Delta E_vac(M(1 + d)) at d = 0.01: {r5:.4f} (2^5 = 32)')
assert abs(delta_e_vac(0.0, 7.0) / (G_FABLE * 7.0 ** 4 / (64 * PI2)) - 1) < 1e-14 and abs(r5 - 32) < 1.5 and delta_e_vac(3.0, 3.0) == 0.0
with open(RESULTS / 'nb05_vacuum_energy.csv', 'w', newline='') as f:
    wr = csv.writer(f); wr.writerow(['M_eV', 'm_over_M', 'DeltaE_vac_over_rhoc0']); wr.writerows([[f'{a:g}', f'{b:.6f}', f'{c_:.10e}'] for a, b, c_ in vac_rows])

pw = run_fermion('nb05_fable4d_power0.236_m30', 'fable4d', '--potential', 'power', '--param', 'nu=0.236', '--param', 'm_today_ev=30', '--points', '1001',
                 label='fable4d power nu=0.236, m_today = 30 eV', quiet=True)
cp = pw['cols']
m_today = cp['m_eff'][-1]
vac_py = np.array([delta_e_vac(m, m_today) for m in cp['m_eff']])
vac_scale = G_FABLE * m_today ** 4 / (64 * PI2)           # the full variation, Delta E_vac(0; M)
dvac = np.max(np.abs(vac_py - cp['vac_over_rhoc'])) / vac_scale
vac_closed = np.array([delta_e_vac(m, m_today, closed=True) for m in cp['m_eff']])
near = np.abs(1 - cp['m_eff'] / m_today) < 0.2
print(f'closed form versus series where |1 - m/M| < 0.2: max |difference| / (g M^4/(64 pi^2)) = {np.max(np.abs(vac_closed[near] - vac_py[near])) / vac_scale:.1e}'
      f' (the closed form loses the digits that cancel; the series keeps them)')
rho_tot = cp['rho_r'] + cp['rho_b'] + cp['rho_f']
late = cp['a'] >= 0.3
print(f'\npower nu = 0.236, m_today = 30 eV: m_eff/m_today runs from {cp["m_eff"][0] / m_today:.4f} (a = 1e-12) to 1;  '
      f'max |solver vac_over_rhoc - formula| / (g M^4/(64 pi^2)) = {dvac:.1e}')
print(f'   |Delta E_vac(m(t)) - Delta E_vac(m_today)| / rho_total: max over a >= 0.3 = {np.max(np.abs(cp["vac_over_rhoc"][late]) / rho_tot[late]):.3e},  '
      f'at a = 0.5: {interp_log(cp["a"], np.abs(cp["vac_over_rhoc"]) / rho_tot, 0.5):.3e}')
assert dvac < 1e-12 and np.max(np.abs(cp['vac_over_rhoc'][late]) / rho_tot[late]) > 1.0
fig, ax = plt.subplots(figsize=(7.8, 4.4))
for M_eV in Ms_eV:
    sel = vac[:, 0] == M_eV
    ax.semilogy(vac[sel, 1], np.maximum(np.abs(vac[sel, 2]), 1e-30), label=f'M = {M_eV:g} eV')
ax.axhline(1.0, color='k', ls=':', label='rho_c0')
ax.set_ylim(1e-10, 1e20); ax.set_xlabel('m / M'); ax.set_ylabel('|Delta E_vac(m; M)| / rho_c0')
ax.set_title('Renormalized Dirac-sea energy of a mass-varying fable (g = 8)'); ax.legend(fontsize=8)
fig.savefig(RESULTS / 'nb05_vacuum_energy.png', dpi=130, bbox_inches='tight'); print('figure: results/nb05_vacuum_energy.png'); plt.show()
'''))
    # ---- 6 results
    cells.append(md(r"""
## 6. This notebook's results

Everything this notebook writes lives under `results/`:

- `results/nb05_clifford_table.csv` — the symmetry table of 3.1 and what it means for a real
  Grassmann spinor;
- `results/nb05_ks_accuracy.csv`, `results/nb05_ks_accuracy.png` — relative errors of the closed
  and stable Fermi-sea forms against quadrature, `1e−8 ≤ x ≤ 1e6`;
- `results/nb05_w_ks.csv`, `results/nb05_w_ks.png` — `w_KS(x)`;
- `results/nb05_identities.csv` — the largest residuals of the thermodynamic identities;
- `results/nb05_classical_vs_quantum.csv`, `results/nb05_classical_vs_quantum.png` — quantum versus
  classical `w` for five potentials;
- `results/nb05_gap_roots.csv`, `results/nb05_gap_roots.png` — the repulsive quadratic: roots and the
  first-order jump;
- `results/nb05_minimax.csv`, `results/nb05_minimax.png` — `E_n[σ]` and `Ω_n(m)`;
- `results/nb05_preuniverse_cooling.csv`, `results/nb05_preuniverse_cooling.png` — `w(a/a_nr)`;
- `results/nb05_vacuum_energy.csv`, `results/nb05_vacuum_energy.png` — `ΔE_vac(m; M)/ρ_c0`;
- `results/nb05_fable4d_mass30.csv`, `results/nb05_fable4d_power0.236_m30.csv` — the two solver runs.

The files are plain text: the cell below reads two of them back with Python's `csv` module alone
(no numpy, no solver) and prints them.
"""))
    cells.append(code(r'''
import csv
with open(RESULTS / 'nb05_identities.csv', newline='') as f:
    rows = list(csv.DictReader(f))
print(f'nb05_identities.csv: {len(rows)} rows, columns {", ".join(rows[0].keys())}')
for r in rows:
    print(f"  {r['identity']:36s} {r['largest_residual']}")
with open(RESULTS / 'nb05_fable4d_mass30.csv', newline='') as f:
    lines = [l for l in f if not l.startswith('#')]
reader = csv.DictReader(lines)
data = list(reader)
print(f'nb05_fable4d_mass30.csv: {len(data)} rows, {len(reader.fieldnames)} columns; first and last row:')
for r in (data[0], data[-1]):
    print(f"  a = {float(r['a']):.4e}   w_qp = {float(r['w_qp']):.6f}   rho_f = {float(r['rho_f']):.6e}   H_A = {float(r['H_A']):.6e}")
'''))
    # ---- 7 summary
    cells.append(md(r"""
## 7. What the numbers say

The cell below collects, from the cells above, the numbers behind each statement of this notebook
and prints them as a short report.  It fails if any statement is contradicted: that the stable forms
agree with quadrature and with the Rust solver; that `w_KS` runs monotonically from 1/3 to 0; that
the identities hold; that the quantum `w` never goes below −1 while the classical `expdamp` and
`lorentz` cross it; that the repulsive quadratic has three roots and a first-order jump; that the
mass-term root is a maximum of the no-sea functional; and that the Dirac-sea energy of a
mass-varying fable exceeds the critical density.
"""))
    cells.append(code(r'''
min_wq = min(r['w_quantum'] for r in cq_rows if r['rho_over_A'] > 0)
min_wcl = {k: float(curves[(k, 'classical')].min()) for k in ('expdamp', 'lorentz')}
assert min_wq >= -1 - 1e-12 and all(v < -1 for v in min_wcl.values())
report = f"""
**Summary, computed in this notebook.**

1. The invariant bilinear forms of Spin(4,4) on `R^16` form a space of dimension {dim_inv}, both symmetric and
   chirality-diagonal; a real Grassmann 16-spinor with `σ16` has neither a mass term nor dynamics; the complex
   16-spinor is four Dirac flavours (commutant dimension {dim_comm}).
2. Quantization: `G = −iσ16γ⁴` has signature (8, 8); in the `J`-eigenbasis every one of the 8 positive-frequency modes
   per momentum has energy `+ω` and scalar density `m/ω`: `g = 8`.
3. Stable Fermi-sea forms: largest relative error against quadrature {worst_stable:.1e} over `1e−8 ≤ x ≤ 1e6`; against the
   Rust solver {worst_rust:.1e}.
4. `w_KS` rises monotonically from {wks[0]:.2e} (x = 1e−8) to {wks[-1]:.12f} (x = 1e6).
5. Identities: `ε − 3P = mσ` to {ident['eps - 3P - m sigma (rel. to eps)']:.1e}, `ε + P = wF n` to {ident['eps + P - wF n (rel.)']:.1e}.
6. Quantum versus classical: the smallest quantum `w` over all potentials, densities and scales is {min_wq:+.6f}; the classical
   `expdamp` reaches {min_wcl['expdamp']:+.4f} and `lorentz` {min_wcl['lorentz']:+.4f}.  The phantom crossing does not survive quantization.
7. Repulsive quadratic `(0.05, 20)`: {len(roots)} roots at `kF = 1` (Rust and Python agree), ground state `m = {gs['m']:+.6e}`; the ground state
   jumps from `m = {scan[jump - 1, 3]:+.4f}` to `m = {scan[jump, 3]:+.4f}` near `kF = {scan[jump, 0]:.3f}`: a first-order transition.
8. The mass-term root is a maximum of `E_n[σ]` (value {E_star:.6f} = ρ); `E_n/n → {E_curve[0] / n_m:+.4f}` as `σ → −n` (collapse to −|m0| = −2).
   The Walecka functional of `W = σ − 10σ²` is convex with its minimum {Om(ra[0]):.6f} = ρ at `m* = {ra[0]:.6f}`.
9. On the pre-universe the author's mass term gives `w` from 1/3 to 0 as `a = e^(−a4)` grows through `a_nr`; the Rust run agrees to {dw:.1e}.
10. Dirac-sea energy: its full variation `g M⁴/(64π²)` exceeds `ρ_c0` for `M > {M_star * 1e3:.2f} meV`; along the power run (30 eV) it
    reaches {np.max(np.abs(cp['vac_over_rhoc'][late]) / rho_tot[late]):.2e} times the total density at `a ≥ 0.3`.
"""
display(Markdown(report))
print('every statement of this notebook is backed by the numbers above')
'''))
    cells += closing_cells(name, 8)
    build_fermion(NOTEBOOKS / f"{name}.ipynb", ["fable4d", "gap"], cells)


# ==============================================================================================
# Notebook 06: the coupled (fable, primordial gravitational field) system, solved to today
# ==============================================================================================

# The notebook-06 helpers: the independent scipy implementation (fermion/crosscheck.py) imported,
# the summaries of a run, the dark-energy bookkeeping and the cross-check of a run.
NB06_HELPERS = r'''
sys.path.insert(0, str(ROOT / 'fermion'))
import crosscheck as xc                    # the independent scipy implementation (quadrature, brentq, DOP853)
from scipy.special import zeta
print('independent implementation imported from', Path(xc.__file__).resolve().relative_to(ROOT.resolve()).as_posix())
XU = xc.units()
for key, val in (('e_c', E_C_EV), ('omega_r0', OMEGA_R0), ('omega_b0', OMEGA_B0), ('omega_nu1', OMEGA_NU1)):
    assert abs(XU[key] / val - 1) < 1e-9
print('crosscheck.units() agrees with the solver\'s unit system to 1e-9')
POINTS = 1001                              # output rows of every kept run (N from ln a_i to 0)
C_KMS = 299792.458
OMEGA_DM = 0.265


def interp_spline(c, col, a0):
    """The column at a0 by a cubic spline in N through the 8 rows nearest to ln a0 (NaN outside the run)."""
    from scipy.interpolate import CubicSpline
    N, x = c['N'], math.log(a0)
    if x < N[0] or x > N[-1]:
        return float('nan')
    k = int(np.searchsorted(N, x))
    lo, hi = max(0, k - 4), min(len(N), k + 4)
    return float(CubicSpline(N[lo:hi], c[col][lo:hi])(x))


def a_nr_of(c):
    """The first a at which kF/|m_eff| falls through 1 (linear in ln a between rows); NaN if it never does."""
    kfm = np.where(np.isfinite(c['kF_over_m']), c['kF_over_m'], 1e300)
    x = crossing_points(c['a'], np.log(kfm), 0.0)
    return x[0] if x else float('nan')


def neg_ranges(a, y, amin=0.0):
    """The a-intervals (first row, last row) on which y < 0, for a >= amin."""
    out, k = [], 0
    neg = np.isfinite(y) & (y < 0) & (a >= amin)
    while k < len(a):
        if neg[k]:
            j = k
            while j + 1 < len(a) and neg[j + 1]:
                j += 1
            out.append((float(a[k]), float(a[j])))
            k = j + 1
        else:
            k += 1
    return out


def de_bookkeeping(a, rho_de, p_de, rho_tot):
    """The dark energy an observer infers: w = P/rho; its poles (rho changes sign), its crossings of w = -1
    (rho + P changes sign while rho does not vanish), where it is phantom (w < -1, |rho| > 1e-3 rho_tot), and the
    CPL fit over [max(0.3, 1.05 x the last pole inside [0.3, 1]), 1] excluding rows with |rho| < 1e-3 rho_tot.
    Sign changes between rows where |rho| (or |rho + P|) stays below 1e-8 rho_tot are rounding noise (a universe
    without dark energy) and are not counted."""
    w = p_de / rho_de
    ok = np.abs(rho_de) > 1e-3 * rho_tot
    noise = 1e-8 * rho_tot                         # rho_DE,inf is a difference of O(rho_tot) numbers
    poles = crossing_points(a, rho_de, floor=noise)
    cross = crossing_points(a, rho_de + p_de, floor=noise)
    late = (a >= 0.3) & (a <= 1.0)
    poles_late = [x for x in poles if 0.3 <= x <= 1.0]
    amin = max(0.3, 1.05 * max(poles_late)) if poles_late else 0.3
    w0, wa = cpl_fit(a, w, ok, amin=amin)
    ph = late & ok & (w < -1)
    return dict(w=w, poles=poles, cross=cross, cross_late=[x for x in cross if 0.3 <= x <= 1.0], poles_late=poles_late,
                amin=amin, cpl=(w0, wa), phantom_late=bool(ph.any()), w_min_late=float(np.min(w[late & ok])) if (late & ok).any() else float('nan'),
                w_today=float(w[-1]))


def summarize(run):
    """The key numbers of one run, read from its CSV columns and its parameter line."""
    c, p = run['cols'], run['params']
    a = c['a']
    rho_tot = c['rho_r'] + c['rho_b'] + c['rho_f']
    s = dict(name=run['name'], label=run['label'], model=p['model'], spec=p['spec'], a_start=p['a_start'])
    has_f = 'kf0' in p
    s['m_today_eV'] = float(c['m_eff_eV'][-1]) if has_f else float('nan')
    s['kF0_eV'] = float(c['kF_eV'][-1]) if has_f else float('nan')
    s['a_nr'] = a_nr_of(c) if has_f else float('nan')
    s['a_start_ok'] = bool(p['a_start'] <= min(1e-10, 0.01 * s['a_nr'])) if has_f and np.isfinite(s['a_nr']) else bool(p['a_start'] <= 1e-10)
    s['Neff_BBN'] = interp_log(a, c['N_eff_extra'], A_BBN) if has_f else 0.0
    s['Neff_rec'] = interp_log(a, c['N_eff_extra'], A_REC) if has_f else 0.0
    # the radiation-like part at recombination: 3 P_KS/rho_nu1, P_KS/v = P_obs_f + rho_U, rho_nu1 = Omega_nu1 a^-4 G_ratio
    rad = 3.0 * (c['P_obs_f'] + c['rho_U']) / (OMEGA_NU1 * a ** -4 * c['G_ratio'])
    s['Neff_rec_rad'] = interp_log(a, rad, A_REC) if has_f else 0.0
    s['q0'] = float(c['q_dec'][-1])
    s['t0_Gyr'] = float(c['t'][-1] / H0_PER_YR / 1e9)
    s['Omega_f0'] = float(c['Omega_f'][-1])
    s['w_f_today'] = float(c['w_f'][-1]) if has_f else float('nan')
    s['w_f_min'] = float(np.nanmin(c['w_f'])) if has_f else float('nan')
    s['cpl_wf'] = cpl_fit(a, c['w_f']) if has_f else (float('nan'), float('nan'))
    de = de_bookkeeping(a, c['rho_DE_inf'], c['rho_DE_inf'] * c['w_DE_inf'], rho_tot)
    s['de'] = de
    s['cpl_wDEinf'] = de['cpl']
    s['cs2_min'] = float(np.nanmin(c['cs2_adiabatic'])) if has_f else float('nan')
    s['cs2_neg'] = neg_ranges(a, c['cs2_adiabatic'], 1e-3) if has_f else []
    late = a >= 0.3
    s['vac_rhoc_max'] = float(np.max(np.abs(c['vac_over_rhoc']))) if has_f else 0.0
    s['vac_ratio_late'] = float(np.max(np.abs(c['vac_over_rhoc'][late]) / rho_tot[late])) if has_f else 0.0
    matter = (a >= 1e-3) & (a <= 0.3)
    s['m_ratio_min_matter'] = float(np.min(np.abs(c['m_eff'][matter])) / abs(c['m_eff'][-1])) if has_f else float('nan')
    s['wDMeff_range'] = (float(np.nanmin(c['w_DM_eff'][a >= 1e-3])), float(np.nanmax(c['w_DM_eff'][a >= 1e-3]))) if has_f else (float('nan'),) * 2
    s['P_stab_today'] = float(c['P_stab'][-1])
    s['NEC_violated_frac'] = float(np.mean(c['P_stab'] < 0))
    s['gap_residual_max'] = float(np.nanmax(np.abs(c['gap_residual']))) if has_f else 0.0
    s['constraint_max'] = float(np.nanmax(np.abs(c['constraint_residual'])))
    s['Omega_sum0'] = float(c['Omega_sum'][-1])
    g = c['G_ratio']
    s['G_ai_over_G1'] = float(g[0] / g[-1])
    s['G_BBN_over_G1'] = interp_log(a, g, A_BBN) / g[-1]
    s['dG_since_BBN'] = float(g[-1] / interp_log(a, g, A_BBN) - 1.0)
    s['Gdot_today_per_yr'] = float(abs(3 * c['H_B'][-1] + c['H_C'][-1]) * H0_PER_YR)
    s['HB_over_HA_today'] = float(c['H_B'][-1] / c['H_A'][-1])
    s['HC_over_HA_today'] = float(c['H_C'][-1] / c['H_A'][-1])
    return s


def py_composition(p, N, lnv):
    """crosscheck.composition, or radiation + baryons alone when the run has no fable."""
    if p.get('potential') == 'none':
        rr, rb = p['omega_r0'] * math.exp(-4 * N - lnv), p['omega_b0'] * math.exp(-3 * N - lnv)
        return rr, rb, None, rr + rb, rb, rr / 3
    return xc.composition(p, N, lnv)


def py_run(p, grid):
    """The independent solution on the solver's N grid: fable4d algebraic (H_A = sqrt(rho)) with t by adaptive
    quadrature of dN/H; fable8d by DOP853 (rtol 1e-11) on the same scaled variables as crosscheck.run_python,
    with t carried along.  Returns H_A, B, C, G, t, rho_f, P_obs_f, m (and lnv)."""
    four_d = p['model'] == 'fable4d' or p['freeze'] == 1
    if four_d:
        comp = [py_composition(p, N, 0.0) for N in grid]
        H = np.sqrt([cc[3] for cc in comp])
        hfun = lambda N: math.sqrt(py_composition(p, N, 0.0)[3])
        t1 = 0.5 / hfun(grid[0]) + quad(lambda N: 1.0 / hfun(N), grid[0], grid[-1], epsabs=0.0, epsrel=1e-12, limit=400,
                                         points=[x for x in (-20.0, -15.0, -10.0, -5.0, -2.0) if grid[0] < x < grid[-1]])[0]
        lnv = np.zeros(len(grid))
        out = dict(H_A=H, B=np.ones(len(grid)), C=np.ones(len(grid)), G=np.ones(len(grid)), t_today=t1, lnv=lnv)
    else:
        def rhs(N, y):
            lnB, lnC, sA, sB, sC, tau = y
            e = math.exp(-2 * N)
            HA, HB, HC = sA * e, sB * e, sC * e
            rr, rb, fb, rho, F, dp = py_composition(p, N, 3 * lnB + lnC)
            th = 3 * HA + 3 * HB + HC
            return [HB / HA, HC / HA, 2 * sA + (-HA * th + F / 2 + 3 * dp) / (HA * e), 2 * sB + (-HB * th + F / 2) / (HA * e),
                    2 * sC + (-HC * th + F / 2) / (HA * e), -2 * tau + e / HA]
        N0 = grid[0]
        rho0 = py_composition(p, N0, 3 * p['lnB_i'] + p['lnC_i'])[3]
        HA0, e2 = math.sqrt(rho0), math.exp(2 * N0)
        sol = solve_ivp(rhs, (N0, grid[-1]), [p['lnB_i'], p['lnC_i'], HA0 * e2, 0.0, 0.0, 0.5 / HA0 / e2], method='DOP853', rtol=1e-11, atol=1e-14, t_eval=grid)
        assert sol.success, sol.message
        E = np.exp(-2 * grid)
        lnv = 3 * sol.y[0] + sol.y[1]
        out = dict(H_A=sol.y[2] * E, B=np.exp(sol.y[0]), C=np.exp(sol.y[1]), G=np.exp(-lnv), t_today=sol.y[5][-1] / E[-1], lnv=lnv, nfev=sol.nfev)
    if p.get('potential') != 'none':
        fbs = [xc.fable(p, N, lv) for N, lv in zip(grid, out['lnv'])]
        out['rho_f'] = np.array([f['rho'] for f in fbs])
        out['P_obs_f'] = np.array([f['pobs'] for f in fbs])
        out['m'] = np.array([f['m'] for f in fbs])
    return out


XCHECK = {}


def xcheck(run, conservation=True, stride=10):
    """Compare a run with the independent implementation: max |dw_f|, |dH_A|/H_A, |dB|/B, |dG|/G, |drho_f|/rho_f,
    |dP_obs|/rho_f, |dm|/m_today, and |dt(A=1)|/t; the Friedmann consistency of the solver's own columns
    (|H_A^2 - rho_hat|/H_A^2 in fable4d, the constraint residual in fable8d); and, on every `stride`-th row, the
    covariant conservation of the Python fable, d rho/dN + 3(rho + P_obs) + l (rho + P_hid) = 0, l = d ln v/dN, by
    Richardson-extrapolated central differences (steps 1e-3 and 2e-3), relative to 3(rho + P_obs)."""
    c, p = run['cols'], run['params']
    grid = c['N']
    t0 = time.time()
    py = py_run(p, grid)
    r = dict(name=run['name'])
    r['dH'] = float(np.max(np.abs(py['H_A'] - c['H_A']) / c['H_A']))
    r['dB'] = float(np.max(np.abs(py['B'] - c['B']) / c['B']))
    r['dG'] = float(np.max(np.abs(py['G'] - c['G_ratio']) / c['G_ratio']))
    r['dt'] = float(abs(py['t_today'] / c['t'][-1] - 1))
    four_d = p['model'] == 'fable4d' or p['freeze'] == 1
    rho_hat = c['rho_r'] + c['rho_b'] + c['rho_f']
    r['friedmann'] = float(np.max(np.abs(c['H_A'] ** 2 - rho_hat) / c['H_A'] ** 2)) if four_d else float(np.max(np.abs(c['constraint_residual'])))
    if 'rho_f' in py:
        r['dw'] = float(np.nanmax(np.abs(py['P_obs_f'] / py['rho_f'] - c['w_f'])))
        r['drho'] = float(np.max(np.abs(py['rho_f'] - c['rho_f']) / np.abs(c['rho_f'])))
        r['dP'] = float(np.max(np.abs(py['P_obs_f'] - c['P_obs_f']) / np.abs(c['rho_f'])))
        r['dm'] = float(np.max(np.abs(py['m'] - c['m_eff'])) / abs(c['m_eff'][-1]))
        cons = 0.0
        if conservation:
            ell = (3 * c['H_B'] + c['H_C']) / c['H_A']
            h = 1e-3
            for k in range(1, len(grid) - 1, stride):
                N, lv = grid[k], py['lnv'][k]
                f0 = xc.fable(p, N, lv)
                d1, d2 = [(xc.fable(p, N + q, lv + q * ell[k])['rho'] - xc.fable(p, N - q, lv - q * ell[k])['rho']) / (2 * q) for q in (h, 2 * h)]
                drho = (4 * d1 - d2) / 3                 # Richardson: the O(h^2) truncation of both differences cancels
                res = drho + 3 * (f0['rho'] + f0['pobs']) + ell[k] * (f0['rho'] + f0['phid'])
                cons = max(cons, abs(res) / (3 * abs(f0['rho'] + f0['pobs'])))
        r['conservation'] = cons
    else:
        r.update(dw=0.0, drho=0.0, dP=0.0, dm=0.0, conservation=0.0)
    r['secs'] = time.time() - t0
    r['worst'] = max(r['dw'], r['dH'], r['dB'], r['dG'], r['drho'], r['dP'], r['dt'])
    XCHECK[run['name']] = r
    return r


def print_xcheck(r):
    print(f"  {r['name']:34s} |dw_f| {r['dw']:.1e}  |dH|/H {r['dH']:.1e}  |dB|/B {r['dB']:.1e}  |dG|/G {r['dG']:.1e}  |drho|/rho {r['drho']:.1e}  "
          f"|dP|/rho {r['dP']:.1e}  |dm|/m0 {r['dm']:.1e}  |dt0|/t0 {r['dt']:.1e}  Friedmann {r['friedmann']:.1e}  conservation {r['conservation']:.1e}  ({r['secs']:.1f} s)")


def fmt_ranges(rr, n=3):
    return 'none' if not rr else '; '.join(f'[{x:.3g}, {y:.3g}]' for x, y in rr[:n]) + (' ...' if len(rr) > n else '')
'''


def notebook_06():
    name = "06_fable_primordial_gravity_8d"
    cells = []
    cells.append(md(r"""
# fermion fable and the primordial gravitational field: the coupled system, from the beginning of the present universe to today

This notebook solves the coupled equations of the quantized fermion fable (in its Kohn–Sham ground
state) and the 8-dimensional gravitational field, from deep in the radiation era, before
nucleosynthesis, to today, with the Rust solver `fable_fermion` (pure-Rust SUNDIALS 7.8.0 CVODE), and
re-computes every run with an independent scipy implementation.  The asymptotic region of the
primordial field is an 8-dimensional Bianchi-I universe with three scale factors: `A` for the
observed sheet, `B` for the hidden timelike sheet, `C` for the hidden coordinate `x0`.  Two models
are run.  `fable4d` holds the hidden sheet fixed with a zero-energy stabilizing stress (a Lagrange
multiplier that violates the null energy condition); it is the physical model and the answers rest
on it.  `fable8d` leaves the hidden sheet free; it is the no-go demonstration, because the Newton
constant then varies by many orders of magnitude.  The runs: (a) the author's mass term alone, an
Einstein–de Sitter universe; (b) a mass term plus a bare cosmological constant, ΛCDM with fable dark
matter; (c) the potentials with which the fable supplies the dark energy itself, with parameter
scans; the mass bounds from `ΔN_eff`, free streaming and phase space; (d) the unstabilized no-go
runs.  The last section answers the two questions — is there a time-varying dark-energy `w`, and a
time-varying dark-matter `w`? — from these runs, with every caveat.  Every number is computed below.
"""))
    cells.append(md(SECTION_1_FERMION))
    cells.append(md(SECTION_2_FERMION))
    cells.append(md(r"""
## 3. The field, its Lagrangian and its energy-momentum tensor

**The field.**  The fermion fable is a complex 16-component Grassmann spinor `Ψ` on the
8-dimensional pre-universe (`η = diag(+,+,+,+,−,−,−,−)`, real generators `T16[a]`, the author's spinor
metric `σ16 = T16[0] T16[1] T16[2] T16[3]`, Dirac conjugate `Ψbar = Ψ^‡ σ16`).  Its Lagrangian is the
symmetrized covariant one,

    L = Sqrt[|g|] L̂,     L̂ = (1/(2H)) [ Ψbar γ^μ D_μΨ − (D_μΨbar) γ^μ Ψ ] − V(s),     s = Ψbar Ψ ,

with `D_μ` the covariant derivative of the canonical spin connection; its field equations are
`γ^μ D_μΨ = H V′(s) Ψ` and `(D_μΨbar) γ^μ = −H V′(s) Ψbar`.  It is quantized canonically with `x4` as
time: the anticommutator carries the indefinite form `G = −i σ16 γ⁴`, the fundamental symmetry
`J = −i T16[0]…T16[4]` makes the Fock space positive, the negative-frequency modes form the Dirac sea,
and each spatial momentum carries `g = 8` particle states.  Its energy–momentum tensor operator is
the Hilbert tensor of the symmetrized action,

    T̂_μν = −(1/(4H)) [ Ψbar γ_μ D_νΨ − (D_νΨbar) γ_μ Ψ + (μ ↔ ν) ] + g_μν L̂ ,

normal-ordered with respect to the `J`-vacuum.

**The source: the Kohn–Sham ground state, per 7-volume.**  With `W(σ) := V(Hσ)`, the fable in its
zero-temperature Kohn–Sham ground state is a Fermi gas of `g = 8` states per momentum filling the
momenta `|k| < kF` along the observed sheet (zero modes along `x0` and `x5, x6, x7`), of mass
`m = W′(σ8)`, where `σ8 = σ_KS(m, kF)/v` is the scalar density per 7-volume and `v = B³C/(B³C)_today` the
hidden volume factor.  The expectation value of `T̂_μν` is diagonal, with

    ρ     = ε_KS/v + W(σ8) − σ8 W′(σ8)          (= ρ_qp + ρ_U)
    P_obs = P_KS/v + σ8 W′ − W                   (along x1, x2, x3)
    P_hid = P_x0 = σ8 W′ − W                     (along x5, x6, x7 and x0: the gas has no momentum there)

`ε_KS, P_KS, σ_KS` are the Fermi-sea integrals at `(m, kF)`, `kF = kF0/A` (the number of fermions per
7-volume dilutes as `A^{−3} v^{−1}`).  Two exact identities make this a consistent source:
`ρ + P_obs = wF n/v ≥ 0` (so `w_f = P_obs/ρ ≥ −1` wherever `ρ > 0`: the quantized fable never crosses
the phantom divide) and `ρ + P_hid = ε_KS/v`; at a gap root `dρ = wF dn/v − (ε_KS/v) d ln v`, which is
the covariant conservation law in the Bianchi-I metric.  The **DM/DE split** `ρ_qp = ε_KS/v`
(quasiparticles, `w_DM = P_KS/ε_KS` from 1/3 to 0) versus `ρ_U = W − σ8W′` (the condensate, with
`P = −ρ_U` along all seven spatial directions: an 8-dimensional vacuum energy) is a convention.

**The potentials** (`potentials.rs`; masses in `E_c = ρ_c0^{1/4}`):

| name | `W(σ)` | what is given | what the solver shoots |
|---|---|---|---|
| `mass` (the author's) | `m0 σ` | `m0` | `ln kF0` so that today `ρ_r + ρ_b + ρ_f = 1` |
| `lambda-mass` | `V0 + m0 σ` | `m0`, `Ω_qp0 = 0.265` | `V0` (a bare Λ); `kF0` from `ε_KS(m0, kF0) = Ω_qp0` |
| `power` | `m0 σ + λ σ^ν` | `m_today`, `ν`, `Ω_qp0` | the condensate energy today `U_t = (1 − ν) λ σ_t^ν` |
| `expdamp` | `V0 + m0 σ e^{−σ/s1}` | `m_today`, `xt = σ_t/s1`, `Ω_qp0` | `V0` |
| `quadratic` | `V0 + m0 σ + (λ/2) σ²` | `m_today`, `gq = λσ_t/m_today`, `Ω_qp0` | `V0` |
| `lorentz` | `V0 + m0 σ/(1 + (σ/s1)²)` | `m_today`, `xt`, `Ω_qp0` | `V0` |

For the potentials that supply dark energy the split is imposed today: the quasiparticles carry
`Ω_qp0 = 0.265` (the dark matter) at the mass `m_today = W′(σ_t)`, and the amplitude closes the budget.
The other sources are radiation (on the observed sheet: `P_obs = ρ_r/3`, `P_hid = P_x0 = 0`) and
baryons (dust in every direction).  **What is proved where.**  The field, its quantization and its
energy–momentum tensor are asserted in Part VII of the Mathematica notebook.  The Einstein tensor of
the Bianchi-I metric and the conservation law are computed numerically in section 4 of this notebook
from the metric itself.  The Fermi-sea formulas are evaluated by the solver and, independently, by
adaptive quadrature in the scipy cross-check.
"""))
    cells.append(md(r"""
## 4. The equations of motion

**The metric of the present universe.**  Far from the wall `x0 = 0` of the primordial field
(`6Hx0 → π/2`), every `x0`-dependent term of the Einstein tensor of the warped frame decays like
`Cot[6Hx0]²`, and the primordial field becomes the 8-dimensional Bianchi-I metric

    ds² = C(t)² dz² + A(t)² (dx1² + dx2² + dx3²) − dt² − B(t)² (dx5² + dx6² + dx7²) ,

`t = x4`, `z` the proper `x0`-coordinate; the canonical frame is its special case `A = e^{−a4}`,
`B = e^{a4}`, `C = 1` (`a4` itself is never given a value).  With `H_X = d ln X/dt` and
`Θ = 3H_A + 3H_B + H_C`, the Einstein equations `G^μ_ν = κ_8 T^μ_ν`, `T^μ_ν = diag(P_x0, P_obs, P_obs,
P_obs, −ρ, P_hid, P_hid, P_hid)`, are

    constraint:   3H_A² + 3H_B² + 9 H_A H_B + 3 H_A H_C + 3 H_B H_C = κ_8 ρ          (−G^4_4: the sum over pairs of directions)
    evolution:    dH_i/dt + H_i Θ = κ_8 (P_i − T/6),     i = A, B, C,     T = −ρ + 3P_obs + 3P_hid + P_x0
    conservation: dρ/dt + 3H_A (ρ + P_obs) + 3H_B (ρ + P_hid) + H_C (ρ + P_x0) = 0          (for each source)

(`R^i_i = dH_i/dt + H_i Θ`, and `D − 2 = 6` in eight dimensions).  The mixed Einstein tensor does not
depend on whether a direction is timelike or spacelike.  The constraint propagates:
`d(S − κρ)/dt = −2Θ (S − κρ)`, `S` the pair sum.  The cell below computes the Einstein tensor
numerically from the metric (the Christoffel symbols and the Ricci tensor of a diagonal metric that
depends on `t` only, for test functions `A, B, C`) and checks all four statements, including the flip
of the hidden sheet from timelike to spacelike and the covariant divergence of a diagonal `T^μ_ν`.

**The hidden-sheet driver.**  For the hidden directions (`P_x0 = P_hid` for every source here)
`dH_B/dt + H_B Θ = κ_8 F/6` with `F = ρ − 3P_obs + 2P_hid`: radiation `F = 0`, dust `F = ρ`, an
8-dimensional vacuum energy (a bare `V0`, the condensate `ρ_U`) `F = 2ρ_V`, the Kohn–Sham fable
`F = 2W − σ8 W′`.  The hidden sheet stays frozen (`H_B = H_C = 0`) exactly when `F = 0`: for radiation,
and for a fable with `W ∝ σ²` — whose ground state is, however, the massless gas (radiation).  Any dust
or vacuum energy drives the hidden sheet, and the observed Newton constant `G_4 = G_8/V_hid ∝ 1/v`
changes: that is the unstabilized model **`fable8d`**, the no-go demonstration.

**The stabilized model `fable4d`** adds to `fable8d` a zero-energy stress `P_stab = −F_total/2` on the
`B` and `C` directions.  Then `H_B = H_C = 0`, `v = 1`, and the equations become exactly 4-dimensional
Friedmann: `3H_A² = κρ` and `dH_A/dt = −(κ/2)(ρ + P_obs)`.  `P_stab` is a Lagrange multiplier, not a
stress derived from any field; with zero energy density and `P_stab < 0` wherever `F > 0` it violates
the null energy condition along `x0` (for dust, `ρ + P_C = −ρ_dust/2` for the stabilizer).  This is
the physical model: every answer of section 7 rests on it, with this caveat.  `fable8d
--freeze-hidden` integrates the same system with `H_A` evolved (not algebraic) and must reproduce it.

**Units, normalization, interval.**  `ħ = c = 1`, `H0 = 1` (time in `1/H0`), densities per 7-volume in
`ρ_c0 = 3H0²M_pl²`, so the constraint reads `S = 3ρ̂`; masses and momenta in `E_c = ρ_c0^{1/4}`;
`κ_4,0 = κ_8/V_h,0` with `v = 1` today in every run (`B = C = 1` at `A = 1`); `Ω_r0` (photons and
`N_eff = 3.046` massless neutrinos at `T_CMB = 2.7255 K`, `h = 0.674`) and `Ω_b0 = 0.02237/h²` are
computed from constants by the solver and printed.  `A = 1` is defined by `T_CMB`.  The runs start at
`a_i ≤ min(1e−10, 0.01 a_nr(m))`: before nucleosynthesis (`a_BBN`, `T = 1 MeV`), with the fable
ultra-relativistic; the pre-universe does not fix `a_i`, and section 5.1 shows that the results do not
depend on it.  `g_*(T)` is not followed (`ρ_r = Ω_r0 A^{−4}/v` at all times).  `fable4d` is normalized
by a closure today (`ρ_r + ρ_b + ρ_f = 1` at `A = 1`); the forward `fable8d` is a boundary-value problem
(`H_B = H_C = 0` at `a_i`; `H_A = B = C = 1` today), solved by an outer shooting on the fable's
amplitude and an inner secant iteration on `ln v(a_i)`.  **Assumptions:** `x0` is compactified in the
asymptotic region with a Kaluza–Klein gap far above the temperatures considered; the hidden timelike
sheet is a formal comoving volume (compactifying it gives closed timelike curves); every field is
truncated to its zero modes along the hidden directions; gravity is semiclassical (`G = κ⟨T̂⟩`); the
exchange–correlation energy is neglected.
"""))
    cells.append(code(r'''
import math, itertools
import numpy as np


def mixed_einstein(sig, f, df, ddf, t_index=4):
    """G^mu_nu and R^mu_nu of g = diag(sig_mu exp(2 f_mu(t))) (f_t = 0, sig_t = -1), from f, f', f'' at one t:
    Christoffel symbols of a diagonal metric depending on t only, their t-derivatives, the Ricci tensor
    R_mn = d_l Gam^l_mn - d_n Gam^l_ml + Gam^l_ls Gam^s_mn - Gam^l_ns Gam^s_ml."""
    D = len(sig)
    g = np.array([s_ * math.exp(2 * x) for s_, x in zip(sig, f)])
    dg = 2 * g * np.array(df)
    ddg = 2 * g * (np.array(ddf) + 2 * np.array(df) ** 2)
    gi, dgi = 1 / g, -dg / g ** 2
    Gam, dGam = np.zeros((D, D, D)), np.zeros((D, D, D))
    for l, m_, n in itertools.product(range(D), repeat=3):
        s, ds = 0.0, 0.0
        if m_ == t_index and l == n:
            s, ds = s + dg[l], ds + ddg[l]
        if n == t_index and l == m_:
            s, ds = s + dg[l], ds + ddg[l]
        if l == t_index and m_ == n:
            s, ds = s - dg[m_], ds - ddg[m_]
        Gam[l, m_, n], dGam[l, m_, n] = 0.5 * gi[l] * s, 0.5 * (dgi[l] * s + gi[l] * ds)
    Ric = dGam[t_index].copy()
    Ric[:, t_index] -= np.einsum('lml->m', dGam)
    Ric += np.einsum('lls,smn->mn', Gam, Gam) - np.einsum('lns,sml->mn', Gam, Gam)
    Rmix = np.diag(gi) @ Ric
    Rs = np.trace(Rmix)
    return Rmix - 0.5 * Rs * np.eye(D), Rmix, Gam


# test functions: ln C = 0.1 t - 0.07 t^2, ln A = 0.3 t + 0.1 t^2, ln B = -0.2 t + 0.05 t^2, at t = 0.4
t = 0.4
lnX = {'C': (0.1, -0.07), 'A': (0.3, 0.1), 'B': (-0.2, 0.05)}
Hd = {k: (b + 2 * c * t) for k, (b, c) in lnX.items()}          # H_X = d ln X/dt
dHd = {k: 2 * c for k, (b, c) in lnX.items()}                    # dH_X/dt
val = {k: b * t + c * t * t for k, (b, c) in lnX.items()}
order = ['C', 'A', 'A', 'A', None, 'B', 'B', 'B']                 # x0, x1..x3, x4 = t, x5..x7
f = [val[k] if k else 0.0 for k in order]
df = [Hd[k] if k else 0.0 for k in order]
ddf = [dHd[k] if k else 0.0 for k in order]
Gt, Rt, Gam = mixed_einstein([1, 1, 1, 1, -1, -1, -1, -1], f, df, ddf)
Gs, _, _ = mixed_einstein([1, 1, 1, 1, -1, 1, 1, 1], f, df, ddf)            # the hidden sheet made spacelike
HA, HB, HC = Hd['A'], Hd['B'], Hd['C']
Th = 3 * HA + 3 * HB + HC
S = 3 * HA ** 2 + 3 * HB ** 2 + 9 * HA * HB + 3 * HA * HC + 3 * HB * HC
checks = {
    'off-diagonal G^mu_nu = 0': np.max(np.abs(Gt - np.diag(np.diag(Gt)))),
    '-G^4_4 - (3HA^2 + 3HB^2 + 9HAHB + 3HAHC + 3HBHC)': abs(-Gt[4, 4] - S),
    'R^0_0 - (dH_C/dt + H_C Theta)': abs(Rt[0, 0] - (dHd['C'] + HC * Th)),
    'R^1_1 - (dH_A/dt + H_A Theta)': abs(Rt[1, 1] - (dHd['A'] + HA * Th)),
    'R^5_5 - (dH_B/dt + H_B Theta)': abs(Rt[5, 5] - (dHd['B'] + HB * Th)),
    'G^mu_nu(hidden timelike) - G^mu_nu(hidden spacelike)': np.max(np.abs(Gt - Gs)),
}
# the covariant divergence of T^mu_nu = diag(P_C, P_A x3, -rho, P_B x3) with arbitrary values and a rate drho/dt
rho, PA, PB, PC, drho = 0.7, 0.2, -0.3, 0.45, -1.9
Tm = np.diag([PC, PA, PA, PA, -rho, PB, PB, PB])
dTm = np.zeros((8, 8)); dTm[4, 4] = -drho
div4 = dTm[4, 4] + np.einsum('mml,l->', Gam, Tm[:, 4]) - np.einsum('lmn,ml->n', Gam, Tm)[4]
checks['div T (nu = 4) + (drho/dt + 3HA(rho+P_obs) + 3HB(rho+P_hid) + HC(rho+P_x0))'] = abs(div4 + (drho + 3 * HA * (rho + PA) + 3 * HB * (rho + PB) + HC * (rho + PC)))
for k, v in checks.items():
    print(f'{k:80s} {v:.2e}')
assert max(checks.values()) < 1e-12
print('the Bianchi-I Einstein tensor, computed from the metric, is the one the solver integrates')
'''))
    cells.append(md(r"""
### 4.1 The first-order system actually handed to SUNDIALS

The independent variable is `N = ln A`.  From `a_i = 1e−12` on, the physical rates fall like `A^{−2}`
by many orders of magnitude while `H_B` and `H_C` start at exactly zero, so CVODE integrates the scaled variables
`h_i = H_i A²` and `τ = t/A²` (constant in the radiation era).  **`fable8d`**, state
`y = (ln B, ln C, h_A, h_B, h_C, τ)`:

    d ln B/dN = H_B/H_A,        d ln C/dN = H_C/H_A,
    dh_i/dN   = 2 h_i + A² (dH_i/dt)/H_A,        dτ/dN = −2τ + A^{−2}/H_A,
    dH_A/dt = −H_A Θ + F/2 + 3 (P_obs − P_hid),     dH_B/dt = −H_B Θ + F/2,     dH_C/dt = −H_C Θ + F/2 ,

with `κ_8 ρ → 3ρ̂` (so `κ_8 (P_i − T/6)` becomes `F/2 + 3(P_i − P_hid)`), `v = B³C`, and `F` and
`P_obs − P_hid` formed per source analytically (radiation `0` and `ρ_r/3`, baryons `ρ_b` and `0`, the
fable `2W − σ8W′` and `P_KS/v`), never by subtracting large numbers.  At every right-hand-side
evaluation the gap equation `m = W′(σ_KS(m, kF0 e^{−N})/v)` is solved (in closed form for linear `W`,
by a proven-unique bracket, or by a scan of all roots taking the lowest `ρ`).  Initial state: `H_B =
H_C = 0`, `H_A` from the constraint, `t(a_i) = 1/(2H_A(a_i))`.  **`fable4d`**: one variable,
`dτ/dN = −2τ + A^{−2}/H_A(N)` with `H_A² = ρ̂(N)` algebraic.  **`fable8d --freeze-hidden`**: the
`fable8d` system with the stabilizer, `dH_A/dt = −3H_A² + (3/2)(ρ − P_obs)`, `H_B = H_C = 0`.  CVODE:
BDF, Newton iteration, a dense Jacobian, `rtol = 1e−10`, `atol = 1e−12`.  The independent scipy
check integrates the same `fable8d` equations with DOP853 at `rtol = 1e−11`, evaluates every
Fermi-sea integral by adaptive quadrature and every gap root by `brentq`, and gets `t` in `fable4d` by
adaptive quadrature of `dN/H_A`.
"""))
    cells.append(md(r"""
## 5. Running the solver

The binary is `rust/fable_fermion/target/release/fable_fermion` (`.exe` on Windows):

    fable_fermion fable4d|fable8d --potential NAME [--param KEY=VALUE ...] [--direction forward|backward]
                  [--a-start A] [--points K] [--out FILE.csv] [--rtol R] [--atol A] [--method bdf|adams]
                  [--branch lowest|positive|negative] [--freeze-hidden] [--no-shoot] [--no-fable]
                  [--omega-b X] [--omega-r X]
    fable_fermion gap --form NAME --param KEY=VALUE ... --kf KF [--v V]
    fable_fermion --constants | --version

`--param` keys: `mass`: `m0_ev`; `lambda-mass`: `m0_ev`, `omega_dm`; `power`: `m_today_ev`, `nu`,
`omega_dm`; `expdamp`: `m_today_ev`, `xt`, `omega_dm`; `quadratic`: `m_today_ev`, `gq`, `omega_dm`;
`lorentz`: `m_today_ev`, `xt`, `omega_dm`.  Defaults: `--a-start 1e-12`, `--points 2001` (this notebook
uses 1001), `rtol 1e−10`, `atol 1e−12`, the lowest-energy gap branch.  The CSV starts with `#` comment
lines — the version; `# params:` with the normalized parameters (`kf0`, `m0`, `v0`, `lam`, `nu`, `s1`,
`lnB_i`, `lnC_i`, `a_start`, `omega_r0`, `omega_b0`, …); the definition of every column — then 47
columns: `N, a, z, t, B, C, H_A, H_B, H_C, constraint_residual, rho_r, rho_b, rho_f, P_obs_f, P_hid_f,
n_f, sigma, m_eff, kF_over_m, w_f, rho_qp, w_qp, rho_U, w_DE_eff, Omega_r, Omega_b, Omega_f, q_dec,
G_ratio, cs2_adiabatic, N_eff_extra, P_stab, Omega_sum, rho_DE_inf, w_DE_inf, w_DM_intrinsic, w_DM_eff,
Q, rho_DE_eff, F_hidden, dm_dN, m_eff_eV, kF_eV, gap_roots, branch, gap_residual, vac_over_rhoc`.  The
ones used below: `w_f = P_obs_f/rho_f`; `w_qp = w_DM_intrinsic = P_KS/ε_KS`; `w_DM_eff = w_DM −
σ_KS (dm/dN)/(3ε_KS)` and `Q = σ8 dm/dt` (the energy the condensate hands to the quasiparticles);
`rho_DE_inf = H_A² − Ω_r0 A^{−4} − Ω_b0 A^{−3} − m_today n_today A^{−3}` and `w_DE_inf = −1 − (1/3) d ln
rho_DE_inf/d ln A` (the dark energy an observer infers after subtracting radiation, baryons and cold
dark matter with **today's** mass — the solver takes `m_eff(A = 1)`, not a bare parameter);
`cs2_adiabatic = (dP_obs_f/dN)/(dρ_f/dN)`; `N_eff_extra = ρ_f/ρ_ν(1 species)`; `G_ratio = 1/v =
G_4/G_4(today)`; `P_stab = −F/2` (0 in `fable8d`); `vac_over_rhoc = ΔE_vac(m_eff; M = m_eff(A = 1))/v`
in `ρ_c0`, the renormalized Dirac-sea energy the no-sea functional drops.  The log on stderr gives the
normalization, the result today, `a_nr`, `ΔN_eff` at nucleosynthesis and recombination, the stabilizer's
range, the `t(A = 1)` quadrature check and the `# stats:` line.  Exit code 0 is success; 1 a solver or
physics error with a one-line reason (including the refusal of a first-order transition or of a
negative-energy ground state); 2 a usage error.

The next two cells locate the binary, read the unit system from it, define the runner and the Python
Kohn–Sham toolkit, import the independent implementation `fermion/crosscheck.py`, and define the
summaries and the cross-check used in every section below.
"""))
    cells.append(code(FERMION_SETUP_CODE))
    cells.append(md(r"""
The notebook-specific helpers: `summarize` reads the key numbers of a run from its columns (`a_nr`,
`ΔN_eff` at `a_BBN` and `a_rec`, `q0`, the age, the CPL fits, the dark-energy bookkeeping with its poles
and crossings, the sound speed, the Dirac-sea energy, the stabilizer, the Newton constant); `py_run`
and `xcheck` re-compute a run with the independent implementation and report the largest differences.
"""))
    cells.append(code(NB06_HELPERS))
    # ---- 5.1 interval
    cells.append(md(r"""
### 5.1 The interval, and why the starting point does not matter

The runs start at `a_i = 1e−12` (`T = T_CMB/a_i`, before nucleosynthesis at `a_BBN`), with the fable
ultra-relativistic.  The criterion `a_i ≤ min(1e−10, 0.01 a_nr(m))` is checked for every run by
`summarize`.  Here the `lambda-mass` case with `m0 = 30 eV` is run from `a_i = 1e−12, 1e−11, 1e−10` in
both models (CSV from stdout, nothing written): the state today, `w_f(0.5)` (a cubic spline in `N` through the nearest rows) and, in `fable8d`,
`G(a_BBN)/G(1)` are compared.  In `fable4d` the solution is algebraic in `a` and only the age changes (by
the radiation-era age assigned at `a_i`); in `fable8d` the hidden sheet starts at rest at `a_i`, so a
later start changes its history slightly.
"""))
    cells.append(code(r'''
ai_rows = []
for model in ('fable4d', 'fable8d'):
    for ai in ('1e-12', '1e-11', '1e-10'):
        r = run_fermion(f'ai_{model}_{ai}', model, '--potential', 'lambda-mass', '--param', 'm0_ev=30', '--a-start', ai, '--points', str(POINTS),
                        keep=False, quiet=True)
        c = r['cols']
        ai_rows.append(dict(model=model, a_start=float(ai), T_start_MeV=T_CMB_EV / float(ai) / 1e6, H_B_today=float(c['H_B'][-1]),
                            rho_U_today=float(c['rho_U'][-1]), q0=float(c['q_dec'][-1]), t0=float(c['t'][-1]),
                            w_f_05=interp_spline(c, 'w_f', 0.5), G_BBN_over_G1=interp_spline(c, 'G_ratio', A_BBN) / c['G_ratio'][-1]))
print(f"\n{'model':8s} {'a_i':>7s} {'T(a_i)/MeV':>10s} {'H_B(1)':>12s} {'rho_U(1)':>16s} {'q0':>16s} {'t0 [1/H0]':>16s} {'w_f(0.5)':>16s} {'G(a_BBN)/G(1)':>14s}")
for r in ai_rows:
    print(f"{r['model']:8s} {r['a_start']:7.0e} {r['T_start_MeV']:10.1f} {r['H_B_today']:12.4e} {r['rho_U_today']:16.12f} {r['q0']:16.12f} {r['t0']:16.12f} {r['w_f_05']:16.12f} {r['G_BBN_over_G1']:14.6e}")
for model in ('fable4d', 'fable8d'):
    rs = [r for r in ai_rows if r['model'] == model]
    spread = {k: max(abs(r[k] / rs[0][k] - 1) for r in rs) for k in ('rho_U_today', 'q0', 't0', 'w_f_05')}
    print(f'{model}: largest relative change of rho_U(1), q0, t0, w_f(0.5) between a_i = 1e-12 and 1e-10: ' + ', '.join(f'{k} {v:.1e}' for k, v in spread.items()))
    if model == 'fable4d':
        assert max(spread['rho_U_today'], spread['q0']) < 1e-12 and spread['w_f_05'] < 1e-6 and spread['t0'] < 1e-6
    else:
        assert max(spread.values()) < 1e-2
with open(RESULTS / 'nb06_ai_insensitivity.csv', 'w', newline='') as f:
    wr = csv.DictWriter(f, fieldnames=list(ai_rows[0].keys())); wr.writeheader()
    wr.writerows([{k: (f'{v:.12g}' if isinstance(v, float) else v) for k, v in r.items()} for r in ai_rows])
print('written: results/nb06_ai_insensitivity.csv')
'''))
    # ---- 5.2 (a) mass term
    cells.append(md(r"""
### 5.2 (a) The author's mass term alone: an Einstein–de Sitter universe with a fable that cools

`W = m0 σ` with `m0 = 1, 30, 100, 1000, 2000 eV`, `fable4d`.  There is no condensate (`U = 0`), so the
fable is a free degenerate gas and, with no `Λ`, it closes the budget: an Einstein–de Sitter-like
universe (`q0` near `+1/2`).  Its `w_f = w_DM = P_KS/ε_KS` runs from 1/3 (ultra-relativistic) to 0
(dust) through `a_nr`, the scale factor at which `kF = m`.  The cell runs the five masses, tabulates
`kF0`, `a_nr`, `ΔN_eff` at nucleosynthesis and at recombination (the whole fable energy, and its
radiation-like part `3P_KS/ρ_ν`), `q0`, the age and `Ω_f0`, checks `U = 0` and `w_f = w_qp`, and plots
`w_DM(a)`.
"""))
    cells.append(code(r'''
SUM = {}
MASS_RUNS = []
for m in (1, 30, 100, 1000, 2000):
    name = f'nb06_mass_m{m}_4d'
    run_fermion(name, 'fable4d', '--potential', 'mass', '--param', f'm0_ev={m}', '--points', str(POINTS), label=f'mass {m} eV (EdS)', quiet=True)
    MASS_RUNS.append(name)
    c = RUNS[name]['cols']
    assert np.max(np.abs(c['rho_U'])) == 0.0 and np.max(np.abs(c['w_f'] - c['w_qp'])) < 1e-12
    SUM[name] = summarize(RUNS[name])
print(f"\n{'run':26s} {'kF0 [eV]':>10s} {'a_nr':>10s} {'a_i ok':>6s} {'dNeff BBN':>10s} {'dNeff rec':>10s} {'3P/rho_nu rec':>13s} {'q0':>8s} {'t0 [Gyr]':>8s} {'Omega_f0':>8s}")
for n in MASS_RUNS:
    s = SUM[n]
    print(f"{s['label']:26s} {s['kF0_eV']:10.4e} {s['a_nr']:10.4e} {str(s['a_start_ok']):>6s} {s['Neff_BBN']:10.4g} {s['Neff_rec']:10.4g} {s['Neff_rec_rad']:13.4g} {s['q0']:8.5f} {s['t0_Gyr']:8.4f} {s['Omega_f0']:8.5f}")
    assert s['a_start_ok'] and abs(s['q0'] - 0.5) < 1e-3
fig, ax = plt.subplots(figsize=(8, 4.3))
for n in MASS_RUNS:
    c = RUNS[n]['cols']
    ax.semilogx(c['a'], c['w_qp'], label=RUNS[n]['label'] + f", a_nr = {SUM[n]['a_nr']:.2e}")
ax.axvline(A_BBN, color='0.6', ls=':', lw=0.8); ax.axvline(A_REC, color='0.6', ls='--', lw=0.8)
ax.text(A_BBN, 0.34, ' BBN', fontsize=8); ax.text(A_REC, 0.34, ' recombination', fontsize=8)
ax.set_xlabel('a'); ax.set_ylabel('w_DM = P_KS/eps_KS  (= w_f here)'); ax.set_ylim(-0.02, 0.37); ax.legend(fontsize=8)
ax.set_title('(a) the author\'s mass term: the degenerate fable cools from w = 1/3 to w = 0')
fig.savefig(RESULTS / 'nb06_a_mass_wdm.png', dpi=130, bbox_inches='tight'); print('figure: results/nb06_a_mass_wdm.png'); plt.show()
'''))
    # ---- 5.3 (b) lambda-mass
    cells.append(md(r"""
### 5.3 (b) A mass term plus a bare cosmological constant: ΛCDM with fable dark matter

`W = V0 + m0 σ`, `m0 = 30, 100, 1000, 2000 eV`, `fable4d`, with the quasiparticles carrying
`Ω_qp0 = 0.265` today and `V0` (a bare `Λ`, reported as such) closing the budget.  The mass does not vary,
so `w_DM,eff = w_DM` and `Q = 0`; the condensate is the constant `V0`, so the dark energy an observer
infers must be a cosmological constant: `w_DE,inf = −1` and its CPL fit `(−1, 0)`, to the precision of
the kinetic energy of the quasiparticles that the observer counts as dark energy.  The cell asserts
both, tabulates `a_nr`, `ΔN_eff`, the CPL fit of the intrinsic `w_f` (which is not a dark-energy
equation of state: it mixes the gas and `V0`), `q0` and the age, and plots `w_f`, `w_DM` and `w_DE,inf`.
A fifth run, `lambda-mass 30 eV` from `a_i = 1e−10` on 701 rows, is the reference case of Part VIII of
the Mathematica notebook; it is written to `results/nb06_fable4d_mass30eV.csv`, the name under which
Part VIII compares it with its own solution, and 5.5 compares the two here.
"""))
    cells.append(code(r'''
LM_RUNS = []
for m in (30, 100, 1000, 2000):
    name = f'nb06_lm_m{m}_4d'
    run_fermion(name, 'fable4d', '--potential', 'lambda-mass', '--param', f'm0_ev={m}', '--points', str(POINTS), label=f'lambda-mass {m} eV', quiet=True)
    LM_RUNS.append(name)
    c = RUNS[name]['cols']
    SUM[name] = s = summarize(RUNS[name])
    assert np.max(np.abs(c['w_DM_eff'] - c['w_DM_intrinsic'])) == 0.0 and np.max(np.abs(c['Q'])) == 0.0
    assert abs(s['cpl_wDEinf'][0] + 1) < 1e-6 and abs(s['cpl_wDEinf'][1]) < 1e-6, s['cpl_wDEinf']
# the reference case of Part VIII of the Mathematica notebook (compared with NDSolve in 5.5): exactly this command
run_fermion('nb06_fable4d_mass30eV', 'fable4d', '--potential', 'lambda-mass', '--param', 'm0_ev=30', '--param', 'omega_dm=0.265', '--a-start', '1e-10',
            '--points', '701', label='lambda-mass 30 eV (reference)', quiet=True)
LM_RUNS.append('nb06_fable4d_mass30eV')
SUM['nb06_fable4d_mass30eV'] = s = summarize(RUNS['nb06_fable4d_mass30eV'])
assert abs(s['cpl_wDEinf'][0] + 1) < 1e-6 and abs(s['cpl_wDEinf'][1]) < 1e-6 and s['a_start_ok']
print(f"\n{'run':34s} {'a_nr':>10s} {'dNeff BBN':>10s} {'dNeff rec':>10s} {'CPL w_f (w0, wa)':>20s} {'CPL w_DE,inf (w0, wa)':>26s} {'max|w_DE,inf+1| a>=0.3':>22s} {'q0':>8s} {'t0 [Gyr]':>8s} {'V0 = rho_U':>10s}")
for n in LM_RUNS:
    s, c = SUM[n], RUNS[n]['cols']
    late = c['a'] >= 0.3
    print(f"{s['label']:34s} {s['a_nr']:10.4e} {s['Neff_BBN']:10.4g} {s['Neff_rec']:10.4g} ({s['cpl_wf'][0]:+.4f}, {s['cpl_wf'][1]:+.4f})   "
          f"({s['cpl_wDEinf'][0]:+.10f}, {s['cpl_wDEinf'][1]:+.2e}) {np.max(np.abs(c['w_DE_inf'][late] + 1)):22.2e} {s['q0']:8.5f} {s['t0_Gyr']:8.4f} {c['rho_U'][-1]:10.6f}")
fig, ax = plt.subplots(1, 2, figsize=(13, 4.3))
for n in LM_RUNS:
    c = RUNS[n]['cols']
    l, = ax[0].semilogx(c['a'], c['w_f'], label=f"{RUNS[n]['label']}: w_f")
    ax[0].semilogx(c['a'], c['w_DM_intrinsic'], ':', color=l.get_color(), label=f"{RUNS[n]['label']}: w_DM")
    ax[1].plot(c['a'], c['w_DE_inf'] + 1, color=l.get_color(), label=RUNS[n]['label'])
ax[0].axhline(-1, color='k', lw=0.5); ax[0].set_xlabel('a'); ax[0].set_ylabel('w'); ax[0].legend(fontsize=7); ax[0].set_title('(b) lambda-mass: w_f (solid), w_DM (dotted)')
ax[1].set_xlim(0.3, 1.0); ax[1].set_xlabel('a'); ax[1].set_ylabel('w_DE,inf + 1'); ax[1].legend(fontsize=7)
ax[1].set_title('the inferred dark energy is a cosmological constant'); ax[1].ticklabel_format(axis='y', style='sci', scilimits=(0, 0))
fig.savefig(RESULTS / 'nb06_b_lambda_mass.png', dpi=130, bbox_inches='tight'); print('figure: results/nb06_b_lambda_mass.png'); plt.show()
'''))
    # ---- 5.4 (c) DE potentials
    cells.append(md(r"""
### 5.4 (c) Potentials with which the fable supplies the dark energy itself

`power` with `ν = 0.236` and `ν = 0.5`, `expdamp` (Part VI's `xt = σ_t/s1 = 1/2.21`) and the attractive
`quadratic` (`gq = −0.5`), each with `m_today = 30` and `100 eV`, `fable4d`.  Here the mass varies, the
condensate `ρ_U` varies, and the fluid exchanges energy between its two parts (`Q = σ8 dm/dt`).  The
cell runs the eight cases and prints, for each: `a_nr`; the smallest `m_eff/m_today` over the matter
era `1e−3 ≤ a ≤ 0.3` (a fable that is massless there is not dark matter); `w_f` today, its minimum over
the run and its CPL fit; the dark energy an observer infers (subtracting cold dark matter with today's
mass): the scale factors at which its density `ρ_DE,inf` changes sign (poles of `w_DE,inf`), those at
which it crosses `w = −1`, whether it is phantom in `0.3 ≤ a ≤ 1`, and its CPL fit (over
`[max(0.3, 1.05 a_pole), 1]` when a pole lies inside the supernova range); the smallest adiabatic sound
speed `c_s²` and the ranges where it is negative (an adiabatic instability); the range of `w_DM,eff`;
the Dirac-sea energy `ΔE_vac(m(t)) − ΔE_vac(m_today)` relative to the total density (largest over
`a ≥ 0.3`); and the stabilizer today.  A ninth run is the mass-varying reference case of Part VIII of
the Mathematica notebook: `power` with `ν = 0.5`, `m_today = 100 eV` and a larger quasiparticle share
`Ω_qp0 = 0.55`, from `a_i = 1e−10` on 701 rows, written to `results/nb06_fable4d_power.csv`; with that
share the bare mass `m0` is positive and the fable stays massive (5.6 explains why).

**The inferred dark energy of a massive power law, in closed form.**  Once the gas is non-relativistic,
`σ8 ≈ n ∝ a^{−3}`, the condensate is `U = U_t a^{−3ν}` and the mass `m(a) = m0 + ν U_t a^{3(1−ν)}/((1 − ν) σ_t)`.
Subtracting cold dark matter with today's mass leaves `ρ_DE,inf = U + (m(a) − m_today) n = U_t [a^{−3ν} −
ν a^{−3}]/(1 − ν)` and `P_DE = −U`, hence

    w_DE,inf(a) = −(1 − ν) / (1 − ν a^{−3(1−ν)}) :

a pole at `a_pole = ν^{1/(3(1−ν))}`, `w > 0` before it, phantom (`w < −1`) between it and today, and
`w = −1` at `a = 1` up to the quasiparticles' kinetic energy (which makes it cross −1 just before today).
It depends on `ν` alone, not on `m_today` or `Ω_qp0`.  The cell checks it against the solver's column for
the three runs that stay massive (the two `ν = 0.236` runs and the reference run).  It also checks that the solver's `w_DE_inf` equals
`P_obs_f/(ρ_f − m_today n_today A^{−3})`, as it must in `fable4d`, and computes the second convention of
the subtraction, `ε_KS(today) A^{−3}` (the full quasiparticle energy today, kinetic part included).
"""))
    cells.append(code(r'''
DE_RUNS = []
DE_SPECS = [('power', 'nu=0.236', 'power nu=0.236'), ('power', 'nu=0.5', 'power nu=0.5'), ('expdamp', 'xt=0.4524886877828054', 'expdamp xt=1/2.21'),
            ('quadratic', 'gq=-0.5', 'quadratic gq=-0.5')]
for pot, par, lab in DE_SPECS:
    for m in (30, 100):
        name = f"nb06_{pot}{'_' + par.split('=')[1] if pot == 'power' else ''}_m{m}_4d"
        run_fermion(name, 'fable4d', '--potential', pot, '--param', par, '--param', f'm_today_ev={m}', '--points', str(POINTS), label=f'{lab}, {m} eV', quiet=True)
        DE_RUNS.append(name)
        SUM[name] = summarize(RUNS[name])
# the mass-varying reference case of Part VIII (compared with NDSolve in 5.5): exactly this command
run_fermion('nb06_fable4d_power', 'fable4d', '--potential', 'power', '--param', 'm_today_ev=100', '--param', 'nu=0.5', '--param', 'omega_dm=0.55',
            '--a-start', '1e-10', '--points', '701', label='power nu=0.5, 100 eV, Omega_qp0=0.55', quiet=True)
DE_RUNS.append('nb06_fable4d_power')
SUM['nb06_fable4d_power'] = summarize(RUNS['nb06_fable4d_power'])
ALT = {}
for n in DE_RUNS:
    c, s = RUNS[n]['cols'], SUM[n]
    a = c['a']
    rho_tot = c['rho_r'] + c['rho_b'] + c['rho_f']
    dust0 = abs(c['m_eff'][-1]) * c['n_f'][-1]
    ok = np.abs(c['rho_DE_inf']) > 1e-3 * rho_tot
    w_formula = c['P_obs_f'] / (c['rho_f'] - dust0 * a ** -3)
    assert np.max(np.abs(w_formula[ok] - c['w_DE_inf'][ok]) / np.maximum(1, np.abs(c['w_DE_inf'][ok]))) < 1e-6
    ALT[n] = de_bookkeeping(a, c['rho_f'] - c['rho_qp'][-1] * a ** -3, c['P_obs_f'], rho_tot)
print(f"\n{'run':38s} {'a_nr':>9s} {'min m/m1':>9s} {'w_f(1)':>8s} {'min w_f':>8s} {'CPL w_f':>17s} {'poles of w_DE,inf':>22s} {'w=-1 crossings':>22s} {'phantom?':>8s} {'CPL w_DE,inf':>17s} {'from a':>6s} {'min cs2':>9s}")
for n in DE_RUNS:
    s = SUM[n]; d = s['de']
    print(f"{s['label']:38s} {s['a_nr']:9.3g} {s['m_ratio_min_matter']:9.2e} {s['w_f_today']:8.4f} {s['w_f_min']:8.4f} ({s['cpl_wf'][0]:+.3f}, {s['cpl_wf'][1]:+.3f}) "
          f"{', '.join(f'{x:.3g}' for x in d['poles']):>22s} {', '.join(f'{x:.6g}' for x in d['cross']):>22s} {str(d['phantom_late']):>8s} ({d['cpl'][0]:+.3f}, {d['cpl'][1]:+.3f}) {d['amin']:6.3f} {s['cs2_min']:9.3g}")
print(f"\n{'run':38s} {'cs2 < 0 on (a >= 1e-3)':>34s} {'w_DM,eff range (a >= 1e-3)':>28s} {'|dE_vac|/rho_tot, a>=0.3':>24s} {'P_stab(1)':>10s} {'dNeff BBN':>9s}   second convention (eps_KS(1) a^-3): poles; crossings; CPL")
for n in DE_RUNS:
    s, d2 = SUM[n], ALT[n]
    print(f"{s['label']:38s} {fmt_ranges(s['cs2_neg'], 2):>34s} ({s['wDMeff_range'][0]:+10.3g}, {s['wDMeff_range'][1]:+8.3g}) {s['vac_ratio_late']:24.3e} {s['P_stab_today']:10.4f} {s['Neff_BBN']:9.4f}   "
          f"{', '.join(f'{x:.3g}' for x in d2['poles'])}; {', '.join(f'{x:.3g}' for x in d2['cross'])}; ({d2['cpl'][0]:+.3f}, {d2['cpl'][1]:+.3f})")
for n in DE_RUNS:
    assert SUM[n]['w_f_min'] >= -1 - 1e-12 and SUM[n]['a_start_ok']
for n in ('nb06_power_0.236_m30_4d', 'nb06_power_0.236_m100_4d', 'nb06_fable4d_power'):
    c, s, p = RUNS[n]['cols'], SUM[n], RUNS[n]['params']
    nu_ = p['nu']
    a = c['a']
    rho_tot = c['rho_r'] + c['rho_b'] + c['rho_f']
    w_an = -(1 - nu_) / (1 - nu_ * a ** (-3 * (1 - nu_)))
    sel = (a >= 0.3) & (np.abs(c['rho_DE_inf']) > 1e-2 * rho_tot)
    dev = np.max(np.abs(w_an[sel] - c['w_DE_inf'][sel]) / np.maximum(1, np.abs(c['w_DE_inf'][sel])))
    a_pole = nu_ ** (1 / (3 * (1 - nu_)))
    print(f"{s['label']:38s} w_DE,inf against -(1-nu)/(1 - nu a^(-3(1-nu))) on a >= 0.3: max deviation {dev:.1e};  pole: formula {a_pole:.6f}, "
          f"run {', '.join(f'{x:.6f}' for x in s['de']['poles_late'])};  crossing of -1: {', '.join(f'{x:.8f}' for x in s['de']['cross_late'])}")
    assert dev < 1e-6 and len(s['de']['poles_late']) == 1 and abs(s['de']['poles_late'][0] / a_pole - 1) < 1e-3
print(f"\nsmallest w_f over all {len(DE_RUNS)} runs: {min(SUM[n]['w_f_min'] for n in DE_RUNS):+.10f} (never below -1);  every run has c_s^2 < 0 somewhere after a = 1e-3: {all(SUM[n]['cs2_neg'] for n in DE_RUNS)}")
'''))
    cells.append(md(r"""
The figures of (c).  Top left: `w_f` (never below −1).  Top right: the observer's `w_DE,inf`, clipped to
`[−3, 1]`, with its poles (dotted verticals) and its crossings of −1 (dots).  Bottom left:
`m_eff/m_today`.  Bottom right: the adiabatic sound speed `c_s²` on a symmetric-log scale, negative below
the line.  The second figure shows `w_DM` and `w_DM,eff`, the energy exchange `Q`, the Dirac-sea
energy relative to the total density, and the stabilizing stress `P_stab/ρ`.
"""))
    cells.append(code(r'''
fig, ax = plt.subplots(2, 2, figsize=(14, 9))
for n in DE_RUNS:
    c, s = RUNS[n]['cols'], SUM[n]
    a = c['a']
    l, = ax[0, 0].semilogx(a, c['w_f'], label=s['label'])
    ax[0, 1].plot(a, np.clip(c['w_DE_inf'], -3, 1), color=l.get_color(), lw=1.2, label=s['label'])
    for x in s['de']['poles']:
        if 0.1 <= x <= 1:
            ax[0, 1].axvline(x, color=l.get_color(), ls=':', lw=0.8)
    for x in s['de']['cross']:
        if 0.1 <= x <= 1:
            ax[0, 1].plot(x, -1, 'o', color=l.get_color(), ms=5)
    ax[1, 0].loglog(a, np.maximum(np.abs(c['m_eff'] / c['m_eff'][-1]), 1e-16), color=l.get_color(), label=s['label'])
    ax[1, 1].semilogx(a, c['cs2_adiabatic'], color=l.get_color(), label=s['label'])
ax[0, 0].axhline(-1, color='k', lw=0.6); ax[0, 0].set_ylabel('w_f = P_obs/rho'); ax[0, 0].set_xlabel('a'); ax[0, 0].legend(fontsize=7)
ax[0, 0].set_title('(c) the fable\'s own w: never below -1')
au = np.linspace(0.1, 1, 100)
ax[0, 1].plot(au, UNITE_W0 + UNITE_WA * (1 - au), 'k:', lw=2, label='Unite CPL (-0.861, -0.60)')
af = np.linspace(0.1, 1, 2000)
for nu_, ls in ((0.236, '--'), (0.5, '-.')):
    wf_ = -(1 - nu_) / (1 - nu_ * af ** (-3 * (1 - nu_)))
    wf_[np.abs(1 - nu_ * af ** (-3 * (1 - nu_))) < 1e-3] = np.nan
    ax[0, 1].plot(af, np.clip(wf_, -3, 1), 'k', ls=ls, lw=0.9, label=f'closed form, massive power law nu = {nu_}')
ax[0, 1].axhline(-1, color='k', lw=0.6); ax[0, 1].set_xlim(0.1, 1); ax[0, 1].set_xlabel('a'); ax[0, 1].set_ylabel('w_DE,inf (clipped to [-3, 1])')
ax[0, 1].set_title('the observer-inferred dark energy: poles (dotted), crossings of -1 (dots)'); ax[0, 1].legend(fontsize=7)
ax[1, 0].set_xlabel('a'); ax[1, 0].set_ylabel('m_eff / m_today (floor 1e-16)'); ax[1, 0].set_title('the quasiparticle mass'); ax[1, 0].axvspan(1e-3, 0.3, color='0.9')
ax[1, 1].set_yscale('symlog', linthresh=1e-2); ax[1, 1].axhline(0, color='k', lw=0.8); ax[1, 1].set_xlabel('a'); ax[1, 1].set_ylabel('c_s^2 (symlog)')
ax[1, 1].set_title('adiabatic sound speed: negative = adiabatic instability')
fig.tight_layout(); fig.savefig(RESULTS / 'nb06_c_de_potentials.png', dpi=130, bbox_inches='tight'); print('figure: results/nb06_c_de_potentials.png'); plt.show()

fig, ax = plt.subplots(1, 4, figsize=(20, 4.2))
for n in DE_RUNS:
    c, s = RUNS[n]['cols'], SUM[n]
    a = c['a']
    rho_tot = c['rho_r'] + c['rho_b'] + c['rho_f']
    l, = ax[0].semilogx(a, c['w_DM_eff'], label=s['label'])
    ax[0].semilogx(a, c['w_DM_intrinsic'], ':', color=l.get_color())
    ax[1].semilogx(a, c['Q'], color=l.get_color())
    ax[2].loglog(a, np.maximum(np.abs(c['vac_over_rhoc']) / rho_tot, 1e-30), color=l.get_color())
    ax[3].semilogx(a, c['P_stab'] / rho_tot, color=l.get_color())
ax[0].set_ylim(-3, 0.4); ax[0].set_xlabel('a'); ax[0].set_ylabel('w_DM,eff (solid), w_DM (dotted)'); ax[0].legend(fontsize=6)
ax[1].set_yscale('symlog', linthresh=1e-3); ax[1].set_xlabel('a'); ax[1].set_ylabel('Q = sigma8 dm/dt  [rho_c0 H0]'); ax[1].set_title('energy exchange')
ax[2].axhline(1, color='k', ls=':'); ax[2].set_ylim(1e-6, 1e20); ax[2].set_xlabel('a'); ax[2].set_ylabel('|Delta E_vac(m(t)) - Delta E_vac(m_today)| / rho_total')
ax[2].set_title('the Dirac-sea energy the no-sea functional drops')
ax[3].set_xlabel('a'); ax[3].set_ylabel('P_stab / rho_total'); ax[3].set_title('stabilizer: rho_stab + P_stab < 0 (NEC violated)')
fig.tight_layout(); fig.savefig(RESULTS / 'nb06_c_exchange_vacuum_stabilizer.png', dpi=130, bbox_inches='tight'); print('figure: results/nb06_c_exchange_vacuum_stabilizer.png'); plt.show()
'''))
    # ---- 5.5 three implementations on the Part VIII reference cases
    cells.append(md(r"""
### 5.5 Three implementations on two reference cases: CVODE (Rust), scipy, and Mathematica

Part VIII of the Mathematica notebook solves two `fable4d` cases independently —
`fable-cosmology/reference/make_reference_fermion.wls` evaluates the Fermi-sea closed forms and the gap at
40 significant digits and integrates the age with `NDSolve` at 30-digit working precision — and writes
`reference/mathematica_fable4d_mass30eV.csv` (`lambda-mass`, `m0 = 30 eV`, `Ω_qp0 = 0.265`) and
`reference/mathematica_fable4d_power.csv` (`power`, `ν = 0.5`, `m_today = 100 eV`, `Ω_qp0 = 0.55`), both
on 701 values of `N` from `ln 1e−10` to 0, with the same unit system as the Rust solver.  The two runs
of the same cases above wrote `results/nb06_fable4d_mass30eV.csv` and `results/nb06_fable4d_power.csv`
on the same grid.  The cell compares all three pairwise, column by column: `t`, `H_A`, `ρ_f`, `P_obs_f`,
`m_eff`, `σ`, `kF/m` relative, `w_f` absolute; the scipy side is the independent implementation of 5.10
(quadrature, `brentq`, and adaptive quadrature for the age).  It fails if any difference exceeds `1e−6`,
the tolerance Part VIII uses.
"""))
    cells.append(code(r'''
three = []
for name, fn in (('nb06_fable4d_mass30eV', 'mathematica_fable4d_mass30eV.csv'), ('nb06_fable4d_power', 'mathematica_fable4d_power.csv')):
    path = REFERENCE / fn
    assert path.exists(), f'the Mathematica reference {path} is missing'
    with open(path, newline='') as f:
        rr = list(csv.DictReader(f))
    ref = {k: np.array([float(r[k]) for r in rr]) for k in rr[0]}
    c, p = RUNS[name]['cols'], RUNS[name]['params']
    assert len(ref['N']) == len(c['N']) and np.max(np.abs(ref['N'] - c['N'])) < 1e-12, 'the reference grid must be the solver grid'
    py = py_run(p, c['N'])
    row = dict(case=name)
    for col in ('t', 'H_A', 'rho_f', 'P_obs_f', 'm_eff', 'sigma', 'kF_over_m'):
        row[f'rust-mathematica {col}'] = float(np.max(np.abs(c[col] - ref[col]) / np.abs(ref[col])))
    row['rust-mathematica w_f (abs)'] = float(np.max(np.abs(c['w_f'] - ref['w_f'])))
    row['scipy-mathematica H_A'] = float(np.max(np.abs(py['H_A'] - ref['H_A']) / ref['H_A']))
    row['scipy-mathematica rho_f'] = float(np.max(np.abs(py['rho_f'] - ref['rho_f']) / np.abs(ref['rho_f'])))
    row['scipy-mathematica P_obs_f'] = float(np.max(np.abs(py['P_obs_f'] - ref['P_obs_f']) / np.abs(ref['rho_f'])))
    row['scipy-mathematica m_eff'] = float(np.max(np.abs(py['m'] - ref['m_eff']) / np.abs(ref['m_eff'])))
    row['scipy-mathematica t(A=1)'] = float(abs(py['t_today'] / ref['t'][-1] - 1))
    three.append(row)
    print(f'{name}:  m_eff from {ref["m_eff"][0] * E_C_EV:.4f} eV (a = 1e-10) to {ref["m_eff"][-1] * E_C_EV:.4f} eV (today)')
    for k, v in row.items():
        if k != 'case':
            print(f'   max |difference| {k:32s} {v:.2e}')
    assert max(v for k, v in row.items() if k != 'case') < 1e-6
with open(RESULTS / 'nb06_threeway.csv', 'w', newline='') as f:
    wr = csv.DictWriter(f, fieldnames=list(three[0].keys())); wr.writeheader()
    wr.writerows([{k: (f'{v:.3e}' if isinstance(v, float) else v) for k, v in r.items()} for r in three])
print('written: results/nb06_threeway.csv;  CVODE, scipy and Mathematica agree to better than 1e-6 on both reference cases')
'''))
    # ---- 5.6 scans
    cells.append(md(r"""
### 5.6 Parameter scans: where does a dark-energy fable stay massive through the matter era?

The answers must not rest on one choice of shape parameter.  For each family that can supply the dark
energy the next cells scan the shape: `power` `ν = 0.05 … 0.65`, `quadratic` `gq = −0.95 … −0.05`,
`expdamp` `xt = 0.1 … 0.9`, at `m_today = 1 keV` (the mass scale that free streaming requires, 5.7) and
at `100 eV` (`fable4d`, 401 output rows, CSV from stdout); and, for `power` with `ν = 0.3` and `ν = 0.5`,
the quasiparticle share `Ω_qp0 = 0.265 … 0.8` (the condensate then carries the rest of the budget).  For every point: the smallest `m_eff/m_today`
over `1e−3 ≤ a ≤ 0.3` (below `1e−3` or so the fable is massless there and is not dark matter), `a_nr`,
the CPL fit of the observer-inferred `w_DE,inf` (with its poles), whether it is phantom or crosses −1
in `0.3 ≤ a ≤ 1`, the smallest `c_s²` after `a = 1e−3`, the smallest `w_f`, and the largest gap residual.
Every scan run is also re-computed with the independent implementation as it runs (5.10 lists the
result).  For the power law the scan also records the bare mass `m0 = m_today − ν λ σ_t^{ν−1}`: at high
density `ν λ σ^{ν−1} → 0`, so if `m0 < 0` the gap can only be met with `m → 0⁺` and the fable is a
massless gas until the density has fallen far enough; with `σ_t ≈ n_t` and `ε_KS ≈ m_today n_t` today
this happens exactly when `Ω_qp0/U_t < ν/(1 − ν)`, `U_t = 1 − Ω_qp0 − Ω_b0 − Ω_r0` the condensate today.
The cell checks that the sign of `m0` decides, at every power-law scan point, whether the fable stays
massive.  In the massless cases the smallest `c_s²` sits at the sharp release of the pinned gap, and its
magnitude depends on how finely the output grid samples that release; its sign does not.  The map is written to `results/nb06_scan.csv` and drawn in `results/nb06_scan.png` and
`results/nb06_scan_cpl.png`.
"""))
    scan_code = r'''
SCAN_FAMILIES = [('power, nu', 'power', 'nu', [round(0.05 * k, 2) for k in range(1, 14)], []),
                 ('quadratic, gq', 'quadratic', 'gq', [round(-0.95 + 0.1 * k, 2) for k in range(10)], []),
                 ('expdamp, xt', 'expdamp', 'xt', [round(0.1 * k, 1) for k in range(1, 10)], []),
                 ('power nu=0.3, Omega_qp0', 'power', 'omega_dm', [0.265, 0.35, 0.45, 0.55, 0.65, 0.8], ['nu=0.3']),
                 ('power nu=0.5, Omega_qp0', 'power', 'omega_dm', [0.265, 0.35, 0.45, 0.5, 0.55, 0.65, 0.8], ['nu=0.5'])]
try:
    SCAN
except NameError:
    SCAN = []
for fam, pot, key, vals, fixed in SCAN_FAMILIES:
    for v in vals:
        name = f"scan_{pot}_{key}{v}{'_' + '_'.join(fixed) if fixed else ''}_m{M_SCAN}"
        extra = [x for f_ in fixed for x in ('--param', f_)]
        r = run_fermion(name, 'fable4d', '--potential', pot, '--param', f'{key}={v}', *extra, '--param', f'm_today_ev={M_SCAN}', '--points', '401',
                        keep=False, quiet=True, show_log=False, label=f'{fam}={v}, {M_SCAN} eV')
        s = summarize(r)
        xr = xcheck(r, conservation=True, stride=20)
        cc, pp = r['cols'], r['params']
        SCAN.append(dict(family=fam, key=key, value=v, m_today_eV=M_SCAN, m0_over_m_today=pp['m0'] / cc['m_eff'][-1],
                         omega_qp0=float(cc['rho_qp'][-1]), U_today=float(cc['rho_U'][-1]), a_nr=s['a_nr'], m_ratio_min_matter=s['m_ratio_min_matter'],
                         w0_DE=s['cpl_wDEinf'][0], wa_DE=s['cpl_wDEinf'][1], fit_from_a=s['de']['amin'],
                         poles=' '.join(f'{x:.3g}' for x in s['de']['poles']), crossings=' '.join(f'{x:.3g}' for x in s['de']['cross']),
                         phantom_late=s['de']['phantom_late'], crosses_late=bool(s['de']['cross_late']), w0_f=s['cpl_wf'][0], wa_f=s['cpl_wf'][1],
                         w_f_min=s['w_f_min'], cs2_min=float(np.nanmin(np.where(r['cols']['a'] >= 1e-3, r['cols']['cs2_adiabatic'], np.nan))),
                         vac_ratio_late=s['vac_ratio_late'], gap_residual_max=s['gap_residual_max'], xcheck_worst=xr['worst'], conservation=xr['conservation']))
        assert xr['worst'] < 1e-6 and s['w_f_min'] >= -1 - 1e-12
rows = [r for r in SCAN if r['m_today_eV'] == M_SCAN]
print(f"m_today = {M_SCAN} eV: {len(rows)} scan runs")
print(f"{'family':24s} {'value':>6s} {'m0/m1':>9s} {'min m/m1':>9s} {'a_nr':>8s} {'CPL w_DE,inf':>18s} {'from a':>6s} {'poles':>18s} {'phantom':>7s} {'cross':>5s} {'min cs2':>9s} {'min w_f':>8s} {'max gap res':>11s} {'xcheck':>8s} {'cons.':>8s}")
for r in rows:
    print(f"{r['family']:24s} {r['value']:6.3f} {r['m0_over_m_today']:9.3g} {r['m_ratio_min_matter']:9.2e} {r['a_nr']:8.3g} ({r['w0_DE']:+7.3f}, {r['wa_DE']:+7.3f}) {r['fit_from_a']:6.3f} {r['poles']:>18s} "
          f"{str(r['phantom_late']):>7s} {str(r['crosses_late']):>5s} {r['cs2_min']:9.3g} {r['w_f_min']:8.4f} {r['gap_residual_max']:11.1e} {r['xcheck_worst']:8.1e} {r['conservation']:8.1e}")
'''
    cells.append(code("M_SCAN = 1000" + scan_code))
    cells.append(md(r"""
The same scan at `m_today = 100 eV`, then the map: for each family, the smallest `m_eff/m_today` in the
matter era and the smallest `c_s²` against the scanned parameter (both masses), the check of the
bare-mass criterion, and the CPL points of the inferred dark energy and of `w_f` in the `(w0, wa)` plane
next to Unite's.
"""))
    cells.append(code("M_SCAN = 100" + scan_code + r'''
massive = [r for r in SCAN if r['m_ratio_min_matter'] > 1e-3]
print(f"\nscan points whose fable stays massive through 1e-3 <= a <= 0.3 (min m/m_today > 1e-3): {len(massive)} of {len(SCAN)}: "
      + ', '.join(f"{r['family']}={r['value']} ({r['m_today_eV']} eV)" for r in massive))
print(f"of these, with c_s^2 >= 0 after a = 1e-3: {sum(1 for r in massive if r['cs2_min'] >= 0)};  "
      f"smallest c_s^2 among them: {min(r['cs2_min'] for r in massive):+.4f};  largest: {max(r['cs2_min'] for r in massive):+.4f}")
pw_scan = [r for r in SCAN if r['family'].startswith('power')]
agree = all((r['m0_over_m_today'] > 0) == (r['m_ratio_min_matter'] > 1e-3) for r in pw_scan)
print(f"power law: 'massive through the matter era' <=> 'bare m0 > 0' at all {len(pw_scan)} power scan points: {agree}")
assert agree
for r in SCAN:
    if r['family'].startswith('power'):
        nu_ = r['value'] if r['key'] == 'nu' else float(r['family'].split('nu=')[1].split(',')[0])
        r['criterion'] = r['omega_qp0'] / r['U_today'] - nu_ / (1 - nu_)          # > 0: massive (NR estimate today)
    else:
        r['criterion'] = float('nan')
mism = [r for r in pw_scan if (r['criterion'] > 0) != (r['m0_over_m_today'] > 0)]
nu_crit = OMEGA_DM / (1 - OMEGA_B0 - OMEGA_R0)
print(f"the estimate Omega_qp0/U_t > nu/(1 - nu) agrees with the sign of m0 at {len(pw_scan) - len(mism)} of {len(pw_scan)} points;  "
      f"with Omega_qp0 = {OMEGA_DM} it allows nu < Omega_qp0/(1 - Omega_b0 - Omega_r0) = {nu_crit:.4f}")
assert not mism
with open(RESULTS / 'nb06_scan.csv', 'w', newline='') as f:
    wr = csv.DictWriter(f, fieldnames=list(SCAN[0].keys())); wr.writeheader()
    wr.writerows([{k: (f'{v:.8g}' if isinstance(v, float) else v) for k, v in r.items()} for r in SCAN])
print('written: results/nb06_scan.csv')
fig, ax = plt.subplots(2, len(SCAN_FAMILIES), figsize=(5.2 * len(SCAN_FAMILIES), 8.5))
for j, (fam, pot, key, vals, fixed) in enumerate(SCAN_FAMILIES):
    for M_, mk in ((1000, 'o-'), (100, 's--')):
        rr = [r for r in SCAN if r['family'] == fam and r['m_today_eV'] == M_]
        ax[0, j].semilogy([r['value'] for r in rr], [max(r['m_ratio_min_matter'], 1e-16) for r in rr], mk, ms=4, label=f'm_today = {M_} eV')
        ax[1, j].plot([r['value'] for r in rr], [r['cs2_min'] for r in rr], mk, ms=4, label=f'm_today = {M_} eV')
    ax[0, j].axhline(1e-3, color='tab:red', lw=0.8, ls=':'); ax[0, j].set_title(f'{fam}\nmin m_eff/m_today over 1e-3 <= a <= 0.3', fontsize=9)
    ax[0, j].set_xlabel(key); ax[0, j].legend(fontsize=7)
    ax[1, j].set_yscale('symlog', linthresh=1e-2); ax[1, j].axhline(0, color='k', lw=0.8); ax[1, j].set_title(f'{fam}\nmin c_s^2 (a >= 1e-3)', fontsize=9); ax[1, j].set_xlabel(key)
fig.tight_layout(); fig.savefig(RESULTS / 'nb06_scan.png', dpi=130, bbox_inches='tight'); print('figure: results/nb06_scan.png'); plt.show()
fig, ax = plt.subplots(1, 2, figsize=(13, 5))
for (fam, pot, key, vals, fixed), mk in zip(SCAN_FAMILIES, ('o', 's', '^', 'v', 'D')):
    rr = [r for r in SCAN if r['family'] == fam]
    ax[0].plot([r['w0_DE'] for r in rr], [r['wa_DE'] for r in rr], mk, ms=5, alpha=0.7, label=fam)
    ax[1].plot([r['w0_f'] for r in rr], [r['wa_f'] for r in rr], mk, ms=5, alpha=0.7, label=fam)
for k in (0, 1):
    ax[k].plot(UNITE_W0, UNITE_WA, 'r*', ms=14, label='Unite (-0.861, -0.60)'); ax[k].plot(UNITE_WCONST, 0, 'ks', label='Unite constant w = -0.764')
    ax[k].set_xlabel('w0'); ax[k].set_ylabel('wa'); ax[k].legend(fontsize=7)
ax[0].set_xlim(-6, 4); ax[0].set_ylim(-10, 12); ax[0].set_title('CPL of the observer-inferred w_DE (fitted above its poles)')
ax[1].set_title('CPL of the fable\'s own w_f')
fig.tight_layout(); fig.savefig(RESULTS / 'nb06_scan_cpl.png', dpi=130, bbox_inches='tight'); print('figure: results/nb06_scan_cpl.png'); plt.show()
'''))
    # ---- 5.6 mass bounds
    cells.append(md(r"""
### 5.7 How heavy must a fable that is all of the dark matter be?  `ΔN_eff`, free streaming, phase space

**Extra radiation.**  Before `a_nr` the fable is radiation.  Its energy at nucleosynthesis in units of one
neutrino species, `ΔN_eff(BBN)`, depends only on `kF0`, which the requirement `ε_KS(m_today, kF0) = Ω_qp0`
fixes; for a non-relativistic gas today `kF0 ∝ m^{−1/3}`, so `ΔN_eff ∝ m^{−4/3}`.  The cell runs the four
dark-energy potentials at `m_today = 1 eV` (only to show that failure), collects `ΔN_eff(BBN)` from every
run with `Ω_qp0 = 0.265`, fits the power law, and solves for the mass above which `ΔN_eff < 0.3` (and `0.2`).

**Free streaming.**  A zero-temperature degenerate gas has the velocity dispersion of a uniformly filled
Fermi sphere, `v_rms = Sqrt[3/5] kF/m`.  For a fable that is all of the dark matter (`g = 8`,
`n0 = Ω_dm ρ_c0/m`, `kF0 = (6π² n0/g)^{1/3}`) the cell computes `v_rms0(m)` and compares it with the
`v_rms0` of the thermal-relic warm dark matter that the Lyman-α forest allows: `m_WDM ≳ 3.3 keV` (Viel,
Becker, Bolton & Haehnelt 2013, Phys. Rev. D 88, 043502) and `m_WDM ≳ 5.3 keV` (Iršič et al. 2017, Phys.
Rev. D 96, 023522), each a Fermi–Dirac relic with 2 states that is all of the dark matter:
`n = (3ζ(3)/(2π²)) T_x³`, `m n = Ω_dm ρ_c0`, `v_rms = Sqrt[15 ζ(5)/ζ(3)] T_x/m`.  Matching `v_rms0` gives the
fable mass whose free streaming equals that of the allowed WDM.  This is a velocity-matching estimate,
not a transfer-function computation.

**Phase space (Tremaine & Gunn 1979, Phys. Rev. Lett. 42, 407).**  The phase-space density of a
degenerate gas is `g/h³`, the largest a fermion can have, and coarse-graining can only lower it.  A dwarf
galaxy whose core is an isothermal sphere with velocity dispersion `σ` and core radius `r_c` has central
density `ρ0 = 9σ²/(4πG r_c²)` and maximal coarse-grained phase-space density `ρ0/(m⁴ (2πσ²)^{3/2})`, so
`m⁴ > 9 h³/(2 (2π)^{5/2} g G σ r_c²)`.  The cell evaluates it for `g = 8` with illustrative dwarf
spheroidal values `(σ, r_c) = (10 km/s, 0.3 kpc)` and `(7 km/s, 0.15 kpc)` (inputs, not results).
"""))
    cells.append(code(r'''
ONE_EV_RUNS = []
for pot, par, lab in DE_SPECS:
    name = f"nb06_{pot}{'_' + par.split('=')[1] if pot == 'power' else ''}_m1_4d"
    run_fermion(name, 'fable4d', '--potential', pot, '--param', par, '--param', 'm_today_ev=1', '--points', str(POINTS), label=f'{lab}, 1 eV (Delta N_eff)', quiet=True)
    ONE_EV_RUNS.append(name)
    SUM[name] = summarize(RUNS[name])
pts = [(SUM[n]['m_today_eV'], SUM[n]['Neff_BBN'], SUM[n]['label']) for n in LM_RUNS + DE_RUNS + ONE_EV_RUNS
       if abs(RUNS[n]['cols']['rho_qp'][-1] - OMEGA_DM) < 1e-9]          # the runs whose quasiparticles carry Omega_qp0 = 0.265
for mm_, ne, lab in sorted(pts):
    print(f'{lab:40s} m_today = {mm_:7.1f} eV   Delta N_eff(BBN) = {ne:.6g}')
lm_ = np.log([p[0] for p in pts]); ln_ = np.log([p[1] for p in pts])
slope, icpt = np.polyfit(lm_, ln_, 1)
resid = np.max(np.abs(ln_ - (slope * lm_ + icpt)))
coef = math.exp(icpt)
m_03, m_02 = (coef / 0.3) ** (-1 / slope), (coef / 0.2) ** (-1 / slope)
print(f'\nfit over {len(pts)} runs: Delta N_eff(BBN) = {coef:.4f} (m/eV)^({slope:.5f})   (max |ln residual| = {resid:.1e});  '
      f'Delta N_eff < 0.3 needs m > {m_03:.2f} eV, < 0.2 needs m > {m_02:.2f} eV')
assert abs(slope + 4 / 3) < 1e-3 and all(SUM[n]['Neff_BBN'] > 0.3 for n in ONE_EV_RUNS)


def v_rms_fable(m_eV, g=G_FABLE):
    """sqrt(3/5) kF0/m (in km/s) for a degenerate fable that is all of the dark matter today."""
    m = m_eV / E_C_EV
    kf0 = (6 * PI2 * (OMEGA_DM / m) / g) ** (1 / 3)
    return math.sqrt(0.6) * kf0 / m * C_KMS


def v_rms_thermal(m_eV):
    """sqrt(15 zeta(5)/zeta(3)) T_x/m (km/s) for a thermal Fermi-Dirac relic with 2 states that is all of the dark matter."""
    m = m_eV / E_C_EV
    Tx = (OMEGA_DM / m * 2 * PI2 / (3 * zeta(3))) ** (1 / 3)
    return math.sqrt(15 * zeta(5) / zeta(3)) * Tx / m * C_KMS


for n in LM_RUNS:                           # the formula against the runs (eps(m, kF0) = 0.265 exactly there)
    c, p = RUNS[n]['cols'], RUNS[n]['params']
    v_run = math.sqrt(0.6) * p['kf0'] / c['m_eff'][-1] * C_KMS
    print(f"{RUNS[n]['label']:22s} v_rms0 from the run's kF0: {v_run:.6e} km/s;  formula: {v_rms_fable(SUM[n]['m_today_eV']):.6e} km/s")
    assert abs(v_run / v_rms_fable(SUM[n]['m_today_eV']) - 1) < 1e-4
bounds = []
for mw, ref in ((3300.0, 'Viel et al. 2013: m_WDM > 3.3 keV'), (5300.0, 'Irsic et al. 2017: m_WDM > 5.3 keV')):
    vt = v_rms_thermal(mw)
    mf = math.exp(brentq(lambda lm: math.log(v_rms_fable(math.exp(lm)) / vt), math.log(1.0), math.log(1e6)))
    bounds.append(dict(bound=f'free streaming, v_rms0 matched to thermal WDM of {mw / 1e3:g} keV ({ref})', value_eV=mf, detail=f'v_rms0 = {vt:.4e} km/s'))
    print(f'thermal WDM {mw / 1e3:g} keV: v_rms0 = {vt:.4e} km/s  ->  degenerate fable (g = 8) with the same v_rms0: m = {mf:.1f} eV')
for m_ in (10.0, 15.0, 100.0, 1000.0, 2000.0):
    print(f'   fable m = {m_:6.0f} eV: v_rms0 = {v_rms_fable(m_):.4e} km/s')
hP, Gsi, kpc, eVJ = 6.62607015e-34, 6.67430e-11, 3.0856775814913673e19, 1.602176634e-19
for sig_kms, rc_kpc in ((10.0, 0.3), (7.0, 0.15)):
    m4 = 9 * hP ** 3 / (2 * (2 * math.pi) ** 2.5 * G_FABLE * Gsi * sig_kms * 1e3 * (rc_kpc * kpc) ** 2)
    m_tg = m4 ** 0.25 * 299792458.0 ** 2 / eVJ
    bounds.append(dict(bound=f'Tremaine-Gunn, g = 8, sigma = {sig_kms:g} km/s, r_c = {rc_kpc:g} kpc', value_eV=m_tg, detail='m^4 > 9 h^3/(2 (2 pi)^(5/2) g G sigma r_c^2)'))
    print(f'Tremaine-Gunn (g = 8, sigma = {sig_kms:g} km/s, r_c = {rc_kpc:g} kpc): m > {m_tg:.1f} eV')
bounds = [dict(bound='Delta N_eff(BBN) < 0.3', value_eV=m_03, detail=f'Delta N_eff = {coef:.4f} (m/eV)^({slope:.4f})'),
          dict(bound='Delta N_eff(BBN) < 0.2', value_eV=m_02, detail='same fit')] + bounds
with open(RESULTS / 'nb06_dm_mass_bounds.csv', 'w', newline='') as f:
    wr = csv.DictWriter(f, fieldnames=['bound', 'value_eV', 'detail']); wr.writeheader()
    wr.writerows([{**b, 'value_eV': f"{b['value_eV']:.6g}"} for b in bounds])
print('written: results/nb06_dm_mass_bounds.csv')
fig, ax = plt.subplots(figsize=(7.8, 4.6))
mgr = np.geomspace(1, 1e4, 200)
ax.loglog(mgr, [v_rms_fable(x) for x in mgr], label='degenerate fable (g = 8), all of the dark matter')
for mw, ls in ((3300.0, ':'), (5300.0, '--')):
    ax.axhline(v_rms_thermal(mw), color='tab:red', ls=ls, label=f'thermal WDM {mw / 1e3:g} keV (Lyman-alpha bound)')
ax.axvline(m_03, color='0.5', lw=0.8, label=f'Delta N_eff(BBN) = 0.3 at m = {m_03:.1f} eV')
ax.set_xlabel('fable mass m [eV]'); ax.set_ylabel('v_rms today [km/s]'); ax.legend(fontsize=7); ax.set_title('free streaming of a degenerate fable')
fig.savefig(RESULTS / 'nb06_dm_mass_bounds.png', dpi=130, bbox_inches='tight'); print('figure: results/nb06_dm_mass_bounds.png'); plt.show()
'''))
    # ---- 5.7 (d) no-go
    cells.append(md(r"""
### 5.8 (d) Without the stabilizer: the hidden sheet moves and the Newton constant varies

`fable8d` for representative cases of (a) and (b): the mass term at `1` and `100 eV`, `lambda-mass` at
`30 eV` and `1 keV`; and two controls, radiation alone (`--no-fable --omega-b 0`), which must keep the
hidden sheet exactly frozen (`F = 0`), and radiation plus baryons (`--no-fable`), in which dust alone
drives it.  For each: `B` and `C` at `a_i` (both are 1 today), `G(a)/G(1) = 1/v` at `a_i` and at
`a_BBN`, `ΔG/G` since nucleosynthesis, `|d ln G/dt|` today in units of 1/yr against the lunar-laser-ranging
bound `1e−13/yr`, `H_B/H_A` and `H_C/H_A` today (the approach to the 7-dimensional isotropic attractor,
where both are 1), the largest constraint residual, and `Ω_sum` today (the budget the closure needs).
The two controls have nothing to shoot, so their `H_A` today is not 1 and their ages are not those of our
universe; they only show what drives the hidden sheet.  The last run is `fable8d --freeze-hidden` for
`lambda-mass 30 eV`: `fable4d` with `H_A` evolved by its own equation, which must agree with the algebraic
`fable4d`.
"""))
    cells.append(code(r'''
NOGO_RUNS = []
for name, args, lab in [('nb06_mass_m1_8d', ['--potential', 'mass', '--param', 'm0_ev=1'], 'mass 1 eV, fable8d'),
                        ('nb06_mass_m100_8d', ['--potential', 'mass', '--param', 'm0_ev=100'], 'mass 100 eV, fable8d'),
                        ('nb06_lm_m30_8d', ['--potential', 'lambda-mass', '--param', 'm0_ev=30'], 'lambda-mass 30 eV, fable8d'),
                        ('nb06_lm_m1000_8d', ['--potential', 'lambda-mass', '--param', 'm0_ev=1000'], 'lambda-mass 1 keV, fable8d'),
                        ('nb06_radiation_only_8d', ['--no-fable', '--omega-b', '0'], 'radiation only, fable8d'),
                        ('nb06_radiation_baryons_8d', ['--no-fable'], 'radiation + baryons, fable8d')]:
    run_fermion(name, 'fable8d', *args, '--points', str(POINTS), label=lab, quiet=True)
    NOGO_RUNS.append(name)
    SUM[name] = summarize(RUNS[name])
print(f"\n{'run':28s} {'B(a_i)':>10s} {'C(a_i)':>10s} {'G(a_i)/G(1)':>12s} {'G(BBN)/G(1)':>12s} {'dG/G since BBN':>14s} {'|dlnG/dt| /yr':>13s} {'> 1e-13?':>8s} {'H_B/H_A(1)':>11s} {'H_C/H_A(1)':>11s} {'max|constr|':>11s} {'Omega_sum(1)':>12s} {'q0':>7s} {'t0 Gyr':>7s}")
for n in NOGO_RUNS:
    s, c = SUM[n], RUNS[n]['cols']
    print(f"{s['label']:28s} {c['B'][0]:10.4e} {c['C'][0]:10.4e} {s['G_ai_over_G1']:12.4e} {s['G_BBN_over_G1']:12.4e} {s['dG_since_BBN']:14.4e} {s['Gdot_today_per_yr']:13.4e} "
          f"{str(s['Gdot_today_per_yr'] > LLR_BOUND_PER_YR):>8s} {s['HB_over_HA_today']:11.6f} {s['HC_over_HA_today']:11.6f} {s['constraint_max']:11.2e} {s['Omega_sum0']:12.5f} {s['q0']:7.4f} {s['t0_Gyr']:7.3f}")
rad = RUNS['nb06_radiation_only_8d']['cols']
print(f"\nradiation only: max |H_B/H_A| = {np.max(np.abs(rad['H_B'] / rad['H_A'])):.1e}, max |H_C/H_A| = {np.max(np.abs(rad['H_C'] / rad['H_A'])):.1e} (F = 0: the hidden sheet stays frozen)")
assert np.max(np.abs(rad['H_B'] / rad['H_A'])) < 1e-12 and np.max(np.abs(rad['H_C'] / rad['H_A'])) < 1e-12
for n in NOGO_RUNS[:4] + NOGO_RUNS[5:]:
    assert SUM[n]['Gdot_today_per_yr'] > LLR_BOUND_PER_YR and SUM[n]['constraint_max'] < 1e-6
fr = run_fermion('nb06_lm_m30_8d_frozen', 'fable8d', '--potential', 'lambda-mass', '--param', 'm0_ev=30', '--freeze-hidden', '--points', str(POINTS), keep=False, quiet=True,
                 label='lambda-mass 30 eV, fable8d --freeze-hidden')
c4, c8 = RUNS['nb06_lm_m30_4d']['cols'], fr['cols']
dH, dt_, dw_ = np.max(np.abs(c8['H_A'] / c4['H_A'] - 1)), np.max(np.abs(c8['t'] / c4['t'] - 1)), np.max(np.abs(c8['w_f'] - c4['w_f']))
print(f'fable8d --freeze-hidden versus fable4d (lambda-mass 30 eV): max |dH_A|/H_A = {dH:.1e}, max |dt|/t = {dt_:.1e}, max |dw_f| = {dw_:.1e}, max |H_B| = {np.max(np.abs(c8["H_B"])):.1e}')
assert dH < 1e-7 and dt_ < 1e-7 and dw_ < 1e-9
with open(RESULTS / 'nb06_nogo_8d.csv', 'w', newline='') as f:
    keys = ['label', 'G_ai_over_G1', 'G_BBN_over_G1', 'dG_since_BBN', 'Gdot_today_per_yr', 'HB_over_HA_today', 'HC_over_HA_today', 'constraint_max', 'Omega_sum0', 'q0', 't0_Gyr']
    wr = csv.writer(f); wr.writerow(keys + ['B_ai', 'C_ai'])
    for n in NOGO_RUNS:
        wr.writerow([SUM[n][k] if isinstance(SUM[n][k], str) else f'{SUM[n][k]:.8g}' for k in keys] + [f"{RUNS[n]['cols']['B'][0]:.8g}", f"{RUNS[n]['cols']['C'][0]:.8g}"])
print('written: results/nb06_nogo_8d.csv')
fig, ax = plt.subplots(1, 3, figsize=(18, 4.4))
for n in NOGO_RUNS:
    c = RUNS[n]['cols']
    l, = ax[0].loglog(c['a'], c['G_ratio'], label=RUNS[n]['label'])
    ax[1].semilogx(c['a'], c['H_B'] / c['H_A'], color=l.get_color(), label=RUNS[n]['label'] + ': H_B/H_A')
    ax[1].semilogx(c['a'], c['H_C'] / c['H_A'], ':', color=l.get_color())
    ax[2].loglog(c['a'], np.maximum(np.abs(c['constraint_residual']), 1e-18), color=l.get_color())
ax[0].axvline(A_BBN, color='0.6', ls=':'); ax[0].set_xlabel('a'); ax[0].set_ylabel('G_4(a)/G_4(today) = 1/v'); ax[0].legend(fontsize=7); ax[0].set_title('(d) the Newton constant without the stabilizer')
ax[1].axhline(1, color='k', lw=0.5); ax[1].set_xlabel('a'); ax[1].set_ylabel('H_B/H_A (solid), H_C/H_A (dotted)'); ax[1].set_title('the approach to the 7D-isotropic attractor')
ax[2].set_xlabel('a'); ax[2].set_ylabel('|constraint residual| (floor 1e-18)'); ax[2].set_title('(S - 3 rho_hat)/(3 H_A^2)')
fig.tight_layout(); fig.savefig(RESULTS / 'nb06_d_nogo_8d.png', dpi=130, bbox_inches='tight'); print('figure: results/nb06_d_nogo_8d.png'); plt.show()
'''))
    # ---- 5.8 refused
    cells.append(md(r"""
### 5.9 The cases the solver refuses, and why

Three runs are expected to fail, each with a one-line physical reason: `lorentz` (Part VI's `xt = 1/1.5`,
`m_today = 1 eV`), whose Kohn–Sham ground state moves to the negative-`σ` branch and has negative total
energy density, so `H_A² = ρ̂` is impossible; the repulsive `quadratic` (`gq = +0.5`), whose ground state
jumps between gap branches (a first-order transition: energy conservation would need a Maxwell
construction, which the solver does not implement); and `fable8d` backward in time, which runs away to
the 8-dimensional Kasner point.  The cell checks the exit code (1) and prints each reason.
"""))
    cells.append(code(r'''
REFUSED = []
for args, why in [(['fable4d', '--potential', 'lorentz', '--points', str(POINTS)], 'negative-energy ground state'),
                  (['fable4d', '--potential', 'quadratic', '--param', 'gq=0.5', '--points', str(POINTS)], 'first-order transition'),
                  (['fable8d', '--potential', 'mass', '--direction', 'backward'], 'fable8d backward')]:
    r = run_fermion('refused', *args, keep=False, expect_failure=True)
    reason = [l for l in r.stderr.splitlines() if l.startswith('fable_fermion:')][-1]
    REFUSED.append((why, r.returncode, reason))
    assert r.returncode == 1
for key, (why, code_, reason) in zip(('negative energy', 'first-order transition', 'forward only'), REFUSED):
    assert key in reason, reason
print('all three refused with exit code 1 and the expected reason')
'''))
    # ---- 5.9 cross-check
    cells.append(md(r"""
### 5.10 Cross-check: every run re-computed with the independent scipy implementation

`xcheck` takes the solver's normalized parameters from the `# params:` line of each CSV and re-computes
the run with `fermion/crosscheck.py`: every Fermi-sea integral by adaptive quadrature, every gap root by
`brentq`, `fable8d` by DOP853 at `rtol = 1e−11`, `fable4d` algebraically with `t(A = 1)` by adaptive
quadrature.  It reports the largest differences of `w_f`, `H_A`, `B`, `G`, `ρ_f`, `P_obs`, `m_eff` and
`t(A = 1)`, the Friedmann consistency of the solver's own columns, and the covariant conservation of the
independently computed fluid on every tenth row (central differences with steps `1e−3` and `2e−3` in `N`,
Richardson-extrapolated so that their `O(h²)` truncation cancels) — which also
tests the massless phases of the dark-energy runs, where the gap is solved at the edge of double
precision.  The notebook fails if any difference exceeds `1e−6`.  The table goes to
`results/nb06_crosscheck.csv`; the scan runs of 5.5 were checked the same way as they ran.
"""))
    cells.append(code(r'''
KEPT = MASS_RUNS + LM_RUNS + DE_RUNS + ONE_EV_RUNS + NOGO_RUNS
for n in KEPT:
    print_xcheck(xcheck(RUNS[n]))
worst = max(XCHECK[n]['worst'] for n in KEPT)
worst_scan = max(r['xcheck_worst'] for r in SCAN)
cons = max(XCHECK[n]['conservation'] for n in KEPT + [k for k in XCHECK if k.startswith('scan_')])
print(f'\nlargest difference over the {len(KEPT)} kept runs: {worst:.2e};  over the {len(SCAN)} scan runs: {worst_scan:.2e};  '
      f'largest conservation residual of the independent fluid: {cons:.2e}')
assert worst < 1e-6 and worst_scan < 1e-6 and cons < 1e-6
with open(RESULTS / 'nb06_crosscheck.csv', 'w', newline='') as f:
    keys = ['name', 'dw', 'dH', 'dB', 'dG', 'drho', 'dP', 'dm', 'dt', 'friedmann', 'conservation']      # no wall times: the file is reproducible
    wr = csv.writer(f); wr.writerow(keys)
    for n in KEPT + sorted(k for k in XCHECK if k.startswith('scan_')):
        wr.writerow([XCHECK[n]['name']] + [f'{XCHECK[n][k]:.3e}' for k in keys[1:]])
print('written: results/nb06_crosscheck.csv')
'''))
    # ---- tables
    cells.append(md(r"""
### 5.11 The key tables

The per-run table (every kept run: model, potential, `m_today`, `a_nr`, `ΔN_eff` at nucleosynthesis and
recombination, `q0`, the age, `w_f` today, the CPL fits of `w_f` and of the inferred `w_DE`, the poles and
crossings of the inferred `w_DE`, the smallest `c_s²`, the largest Dirac-sea ratio at `a ≥ 0.3`, the
stabilizer today and, for `fable8d`, the Newton-constant numbers) goes to `results/nb06_runs.csv`; the CPL
fits, with Unite's two reference rows appended, to `results/nb06_cpl_fits.csv`.
"""))
    cells.append(code(r'''
RUN_COLS = ['name', 'label', 'model', 'm_today_eV', 'kF0_eV', 'a_start', 'a_nr', 'Neff_BBN', 'Neff_rec', 'Neff_rec_rad', 'q0', 't0_Gyr', 'Omega_f0', 'w_f_today', 'w_f_min',
            'w0_f', 'wa_f', 'w0_DE_inf', 'wa_DE_inf', 'DE_fit_from_a', 'DE_poles', 'DE_crossings', 'cs2_min', 'cs2_negative_ranges', 'm_ratio_min_matter',
            'vac_ratio_late', 'P_stab_today', 'G_ai_over_G1', 'dG_since_BBN', 'Gdot_today_per_yr', 'HB_over_HA_today', 'constraint_max', 'gap_residual_max', 'xcheck_worst']
table = []
for n in KEPT:
    s = SUM[n]
    table.append(dict(name=n, label=s['label'], model=s['model'], m_today_eV=s['m_today_eV'], kF0_eV=s['kF0_eV'], a_start=s['a_start'], a_nr=s['a_nr'],
                      Neff_BBN=s['Neff_BBN'], Neff_rec=s['Neff_rec'], Neff_rec_rad=s['Neff_rec_rad'], q0=s['q0'], t0_Gyr=s['t0_Gyr'], Omega_f0=s['Omega_f0'],
                      w_f_today=s['w_f_today'], w_f_min=s['w_f_min'], w0_f=s['cpl_wf'][0], wa_f=s['cpl_wf'][1], w0_DE_inf=s['cpl_wDEinf'][0], wa_DE_inf=s['cpl_wDEinf'][1],
                      DE_fit_from_a=s['de']['amin'], DE_poles=' '.join(f'{x:.4g}' for x in s['de']['poles']), DE_crossings=' '.join(f'{x:.4g}' for x in s['de']['cross']),
                      cs2_min=s['cs2_min'], cs2_negative_ranges=fmt_ranges(s['cs2_neg'], 4), m_ratio_min_matter=s['m_ratio_min_matter'], vac_ratio_late=s['vac_ratio_late'],
                      P_stab_today=s['P_stab_today'], G_ai_over_G1=s['G_ai_over_G1'], dG_since_BBN=s['dG_since_BBN'], Gdot_today_per_yr=s['Gdot_today_per_yr'],
                      HB_over_HA_today=s['HB_over_HA_today'], constraint_max=s['constraint_max'], gap_residual_max=s['gap_residual_max'], xcheck_worst=XCHECK[n]['worst']))
with open(RESULTS / 'nb06_runs.csv', 'w', newline='') as f:
    wr = csv.DictWriter(f, fieldnames=RUN_COLS); wr.writeheader()
    wr.writerows([{k: (f'{v:.8g}' if isinstance(v, float) else v) for k, v in r.items()} for r in table])
print(f"{'run':34s} {'m [eV]':>7s} {'a_nr':>9s} {'dNeff BBN':>9s} {'CPL w_f':>17s} {'CPL w_DE,inf':>17s} {'min cs2':>9s} {'vac/rho a>=.3':>13s} {'G(a_i)/G(1)':>11s} {'|Gdot/G| /yr':>12s}")
for r in table:
    print(f"{r['label']:34s} {r['m_today_eV']:7.4g} {r['a_nr']:9.3g} {r['Neff_BBN']:9.4g} ({r['w0_f']:+.3f}, {r['wa_f']:+.3f}) ({r['w0_DE_inf']:+.3f}, {r['wa_DE_inf']:+.3f}) "
          f"{r['cs2_min']:9.3g} {r['vac_ratio_late']:13.3e} {r['G_ai_over_G1']:11.3e} {r['Gdot_today_per_yr']:12.3e}")
cpl_rows = [dict(run=r['label'], quantity=q, w0=r[f'w0_{k}'], wa=r[f'wa_{k}'], dist_to_unite=math.hypot(r[f'w0_{k}'] - UNITE_W0, r[f'wa_{k}'] - UNITE_WA))
            for r in table if r['model'] == 'fable4d' for q, k in (('w_f', 'f'), ('w_DE_inf', 'DE_inf'))]
cpl_rows += [dict(run='Unite CPL', quantity='reference', w0=UNITE_W0, wa=UNITE_WA, dist_to_unite=0.0),
             dict(run='Unite constant w', quantity='reference', w0=UNITE_WCONST, wa=0.0, dist_to_unite=math.hypot(UNITE_WCONST - UNITE_W0, UNITE_WA))]
with open(RESULTS / 'nb06_cpl_fits.csv', 'w', newline='') as f:
    wr = csv.DictWriter(f, fieldnames=['run', 'quantity', 'w0', 'wa', 'dist_to_unite']); wr.writeheader()
    wr.writerows([{k: (f'{v:.8g}' if isinstance(v, float) else v) for k, v in r.items()} for r in cpl_rows])
print('written: results/nb06_runs.csv, results/nb06_cpl_fits.csv')
'''))
    # ---- 6 results
    cells.append(md(r"""
## 6. This notebook's results

Everything this notebook writes lives under `results/`:

- the solver's CSVs of every kept run: `results/nb06_mass_m{1,30,100,1000,2000}_4d.csv` (a),
  `results/nb06_lm_m{30,100,1000,2000}_4d.csv` (b), `results/nb06_power_0.236_m{1,30,100}_4d.csv`,
  `results/nb06_power_0.5_m{1,30,100}_4d.csv`, `results/nb06_expdamp_m{1,30,100}_4d.csv`,
  `results/nb06_quadratic_m{1,30,100}_4d.csv` (c and the `ΔN_eff` runs), and the two reference cases of
  Part VIII, `results/nb06_fable4d_mass30eV.csv` and `results/nb06_fable4d_power.csv`;
  `results/nb06_mass_m1_8d.csv`, `results/nb06_mass_m100_8d.csv`, `results/nb06_lm_m30_8d.csv`,
  `results/nb06_lm_m1000_8d.csv`, `results/nb06_radiation_only_8d.csv`,
  `results/nb06_radiation_baryons_8d.csv` (d);
- the tables: `results/nb06_runs.csv` (every kept run), `results/nb06_cpl_fits.csv` (with Unite's rows),
  `results/nb06_scan.csv` (the parameter scans), `results/nb06_dm_mass_bounds.csv`,
  `results/nb06_nogo_8d.csv`, `results/nb06_ai_insensitivity.csv`, `results/nb06_crosscheck.csv`,
  `results/nb06_threeway.csv` (CVODE, scipy and Mathematica on the reference cases);
- the figures: `results/nb06_a_mass_wdm.png`, `results/nb06_b_lambda_mass.png`,
  `results/nb06_c_de_potentials.png`, `results/nb06_c_exchange_vacuum_stabilizer.png`,
  `results/nb06_scan.png`, `results/nb06_scan_cpl.png`, `results/nb06_dm_mass_bounds.png`,
  `results/nb06_d_nogo_8d.png`.

The cell below reads the per-run table and one solver CSV back with Python's `csv` module alone (no
numpy, no solver).
"""))
    cells.append(code(r'''
import csv
with open(RESULTS / 'nb06_runs.csv', newline='') as f:
    rows = list(csv.DictReader(f))
print(f'nb06_runs.csv: {len(rows)} rows, {len(rows[0])} columns')
for r in rows:
    print(f"  {r['label']:34s} a_nr = {r['a_nr']:>12s}  Delta N_eff(BBN) = {r['Neff_BBN']:>12s}  CPL w_DE,inf = ({r['w0_DE_inf']}, {r['wa_DE_inf']})")
with open(RESULTS / 'nb06_lm_m1000_8d.csv', newline='') as f:
    data = list(csv.DictReader([l for l in f if not l.startswith('#')]))
print(f"nb06_lm_m1000_8d.csv: {len(data)} rows;  G_ratio at the first row = {float(data[0]['G_ratio']):.4e}, B = {float(data[0]['B']):.4e}, H_B/H_A today = {float(data[-1]['H_B']) / float(data[-1]['H_A']):.6f}")
'''))
    # ---- 7 answers
    cells.append(md(r"""
## 7. Answers

The two questions: **[1]** does this system provide a physical mechanism for a time-varying dark-energy
equation of state `w`?  **[2]** does it provide a time-varying dark-matter equation of state `w`?  The
cell below states the answers with the numbers of the runs above — it composes them from the tables,
so nothing in them is typed by hand — and asserts every qualitative claim they make: that the quantized
fable never has `w_f < −1`; that with a bare `Λ` the inferred dark energy is exactly a cosmological
constant; that every dark-energy potential that stays massive through the matter era has a negative
adiabatic sound speed; that the observer's inferred dark energy can be phantom and cross −1 while the
fable itself never is; that the neglected Dirac-sea energy of every mass-varying run exceeds the total
density; that the stabilizer violates the null energy condition; that without it the Newton constant
varies beyond the lunar-laser-ranging bound; and that the dark-matter `w` runs from 1/3 to 0.  Both
answers are about the stabilized model; the split of the fable into dark matter and dark energy is a
convention (the condensate is an 8-dimensional vacuum energy).
"""))
    cells.append(code(r'''
de4 = [n for n in DE_RUNS]
all_fable = [n for n in KEPT if 'kf0' in RUNS[n]['params']]
min_wf_all = min(SUM[n]['w_f_min'] for n in all_fable)
lm_cpl = [SUM[n]['cpl_wDEinf'] for n in LM_RUNS]
massive_scan = [r for r in SCAN if r['m_ratio_min_matter'] > 1e-3]
massless_scan = [r for r in SCAN if r['m_ratio_min_matter'] <= 1e-3]
fam_massive = sorted({r['family'] for r in massive_scan})
nu_max_massive = max((r['value'] for r in massive_scan if r['family'] == 'power, nu'), default=float('nan'))
nu_min_massless = min((r['value'] for r in massless_scan if r['family'] == 'power, nu'), default=float('nan'))
qe_massive = [r for r in massive_scan if r['family'].startswith(('quadratic', 'expdamp'))]
om_min_05 = min((r['value'] for r in massive_scan if r['family'] == 'power nu=0.5, Omega_qp0'), default=float('nan'))
om_min_03 = min((r['value'] for r in massive_scan if r['family'] == 'power nu=0.3, Omega_qp0'), default=float('nan'))
vp, vc = SUM['nb06_fable4d_power'], RUNS['nb06_fable4d_power']['cols']
viable = dict(m_first=float(vc['m_eff_eV'][0]), m_last=float(vc['m_eff_eV'][-1]), cs2=vp['cs2_min'], q0=vp['q0'], w0=vp['cpl_wDEinf'][0], wa=vp['cpl_wDEinf'][1],
              poles=vp['de']['poles_late'], cross=vp['de']['cross_late'], phantom=vp['de']['phantom_late'], om_m=float(vc['rho_qp'][-1] + vc['rho_b'][-1]),
              vac=vp['vac_ratio_late'], wf0=vp['w_f_today'])
OMEGA_M_PLANCK = 0.315                     # Planck 2018 (TT,TE,EE+lowE+lensing): the measured matter density, an input
apparent = [n for n in de4 if SUM[n]['de']['phantom_late'] or SUM[n]['de']['cross_late']]
scan_phantom = sum(1 for r in SCAN if r['phantom_late'] or r['crosses_late'])
poles_late = [n for n in de4 if SUM[n]['de']['poles_late']]
vac_min = min(SUM[n]['vac_ratio_late'] for n in de4)
vac_max = max(SUM[n]['vac_ratio_late'] for n in de4)
scan_vac_min = min(r['vac_ratio_late'] for r in SCAN)
cs2_massive = [r['cs2_min'] for r in massive_scan]
nogo = [n for n in NOGO_RUNS if 'radiation' not in n]
gdot_min = min(SUM[n]['Gdot_today_per_yr'] for n in nogo + ['nb06_radiation_baryons_8d'])
gratio = [SUM[n]['G_ai_over_G1'] for n in nogo]
dg_bbn = [SUM[n]['dG_since_BBN'] for n in nogo]
pstab_lm = SUM['nb06_lm_m30_4d']['P_stab_today']
nec_frac = min(SUM[n]['NEC_violated_frac'] for n in MASS_RUNS + LM_RUNS + DE_RUNS)
a_nr_1kev = SUM['nb06_lm_m1000_4d']['a_nr']; a_nr_30 = SUM['nb06_lm_m30_4d']['a_nr']; a_nr_2kev = SUM['nb06_lm_m2000_4d']['a_nr']
g_bbn = [SUM[n]['G_BBN_over_G1'] for n in nogo]
pole_236 = SUM['nb06_power_0.236_m30_4d']['de']['poles_late'][0]
cross_236 = SUM['nb06_power_0.236_m30_4d']['de']['cross_late']
a_last = float(RUNS['nb06_power_0.236_m30_4d']['cols']['a'][-2])
assert len(cross_236) == 1 and a_last < cross_236[0] <= 1.0
wdm_mass = {n: (float(RUNS[n]['cols']['w_qp'][0]), float(RUNS[n]['cols']['w_qp'][-1])) for n in MASS_RUNS + LM_RUNS}
wdmeff = [SUM[n]['wDMeff_range'] for n in de4]
m_fs = [b['value_eV'] for b in bounds if b['bound'].startswith('free streaming')]
m_tg = [b['value_eV'] for b in bounds if b['bound'].startswith('Tremaine')]
d_best = min((math.hypot(SUM[n]['cpl_wDEinf'][0] - UNITE_W0, SUM[n]['cpl_wDEinf'][1] - UNITE_WA), SUM[n]['label']) for n in de4)

assert min_wf_all >= -1 - 1e-12
assert all(abs(w0 + 1) < 1e-6 and abs(wa) < 1e-6 for w0, wa in lm_cpl)
assert massive_scan and all(c < 0 for c in cs2_massive) and not qe_massive and viable['cs2'] < 0
assert apparent and all(SUM[n]['w_f_min'] >= -1 - 1e-12 for n in apparent)
assert vac_min > 1.0 and scan_vac_min > 1.0
assert nec_frac > 0.99 and pstab_lm < 0
assert gdot_min > LLR_BOUND_PER_YR and min(gratio) > 1e6
assert all(abs(w1 - 1 / 3) < 1e-3 and abs(w2) < 1e-3 for w1, w2 in wdm_mass.values())

answer = f"""
### [1] A time-varying dark-energy equation of state?

**Formally yes, in the stabilized model, but in none of the runs is it a viable one.**

- *With a bare Λ* (`lambda-mass`, {len(LM_RUNS)} masses): the observer infers exactly a cosmological constant, CPL
  `(w0, wa)` = {', '.join(f'({w0:+.6f}, {wa:+.1e})' for w0, wa in lm_cpl)}. No time variation.
- *With a mass-varying potential* the condensate energy `ρ_U = W − σW′` changes with the density, so the dark energy an
  observer infers varies: the CPL fits of `w_DE,inf` in (c) lie at distances from Unite's `(−0.861, −0.60)` down to
  {d_best[0]:.3f} ({d_best[1]}); but `ρ_DE,inf` changes sign inside `0.3 ≤ a ≤ 1` in {len(poles_late)} of {len(de4)} runs, where
  `w_DE,inf` has a pole, so a CPL line is not a faithful description (the fits above the pole are in `results/nb06_cpl_fits.csv`).
  For a massive power law it is `w_DE,inf = −(1 − ν)/(1 − ν a^(−3(1−ν)))` (checked against the runs in 5.4): for `ν = 0.236` a pole at
  `a = {pole_236:.4f}`, phantom from there to today, and `w = −1` at `a = 1`.
- **No true phantom, but an apparent one.** The fable's own `w_f` never goes below −1 (the smallest over every run:
  {min_wf_all:+.10f}; `ρ + P_obs = wF n ≥ 0` is an identity). The classical Part VI crossing of −1 does not survive quantization.
  The *observer-inferred* dark energy, however, is phantom or crosses −1 inside `0.3 ≤ a ≤ 1` in {len(apparent)} of {len(de4)} runs
  of (c) and {scan_phantom} of {len(SCAN)} scan points: subtracting cold dark matter with today's mass when the mass was different
  leaves `ρ_DE + P_DE ≈ (m_eff(a) − m_today) n` (the mechanism of apparent phantom behaviour from dark-sector energy exchange of
  Das, Corasaniti & Khoury, Phys. Rev. D 73, 083509 (2006)), with no phantom field; for the massive power law the crossing of −1 lies
  in the last output interval before today (`a > {a_last:.4f}`), where the kinetic energy of the quasiparticles, of relative size
  `(3/10)(kF/m)²`, finally exceeds `(m_today − m_eff(a)) n`.
- **Massless through the matter era.** In the scans {len(massive_scan)} of {len(SCAN)} points keep the fable massive over
  `1e−3 ≤ a ≤ 0.3` (smallest `m_eff/m_today` above 1e−3), all of them power laws; every `quadratic` and `expdamp` point is a
  massless gas (radiation) until late times, i.e. supplies no dark matter at recombination. A power law stays massive exactly when
  its bare mass `m0` is positive, i.e. when `Ω_qp0/U_t > ν/(1 − ν)`: with the observed split `Ω_qp0 = 0.265` that means
  `ν < {nu_crit:.3f}` (massive up to `ν = {nu_max_massive:g}`, massless from `ν = {nu_min_massless:g}` in the scan); a larger `ν` needs a larger
  quasiparticle share (`Ω_qp0 ≥ {om_min_03:g}` for `ν = 0.3`, `≥ {om_min_05:g}` for `ν = 0.5` in the scan).
- **The massive mass-varying example** (Part VIII's case: `power`, `ν = 0.5`, `m_today = 100 eV`, `Ω_qp0 = 0.55`, no bare `Λ`):
  `m_eff` rises from {viable['m_first']:.2f} eV to {viable['m_last']:.2f} eV, `w_f` today is {viable['wf0']:+.4f}, `q0 = {viable['q0']:+.4f}`,
  the smallest `c_s²` is {viable['cs2']:+.4f} (adiabatically unstable), the Dirac-sea energy reaches {viable['vac']:.2e} times the total density,
  and its matter today, `Ω_qp0 + Ω_b0 = {viable['om_m']:.3f}`, is about twice the measured `Ω_m ≈ {OMEGA_M_PLANCK}` (Planck 2018): it is massive
  because its dark matter outweighs its dark energy, which the observed universe does not allow.
- **Adiabatic instability.** Every scan point that does stay massive has a negative adiabatic sound speed after `a = 1e−3`
  (smallest `c_s²` between {min(cs2_massive):+.3f} and {max(cs2_massive):+.3f}); so do all {len(de4)} runs of (c).
- **Vacuum energy.** The Dirac-sea energy that the no-sea functional drops changes along every mass-varying run by
  {vac_min:.2e} to {vac_max:.2e} times the total density at `a ≥ 0.3` (over the scans at least {scan_vac_min:.2e}). This notebook reads `W`
  as the fully renormalized effective potential, which absorbs the sea energy only by fine-tuning the bare potential against it to that
  precision.
- **The stabilizer.** All of this holds with the hidden sheet held by `P_stab = −F/2` (today {pstab_lm:+.4f} `ρ_c0` in the ΛCDM-like run), a
  Lagrange multiplier that violates the null energy condition along `x0` (on {100 * nec_frac:.1f} % of the output rows of every
  stabilized run at least).
- **Without it** (`fable8d`) the Newton constant varies: `G(a_i)/G(today)` = {', '.join(f'{g:.2e}' for g in gratio)}; at
  nucleosynthesis `G` was {', '.join(f'{g:.2e}' for g in g_bbn)} times today's value (`ΔG/G` since then is −1 to within
  {max(1 + d for d in dg_bbn):.1e}, against the bound of about 0.1), and `|d ln G/dt|` today ≥ {gdot_min:.2e} /yr against the bound 1e−13 /yr.

### [2] A time-varying dark-matter equation of state?

**Yes, intrinsically, but for an allowed mass the variation is over long before recombination.**

- The quasiparticles of the degenerate fable have `w_DM = P_KS/ε_KS`, running from 1/3 (every run starts at
  {min(v[0] for v in wdm_mass.values()):.6f}) to 0 (today at most {max(v[1] for v in wdm_mass.values()):.1e}); the transition is at `a_nr`,
  e.g. {a_nr_30:.3e} for 30 eV and {a_nr_1kev:.3e} for 1 keV (it scales as `m^(−4/3)`).
- The mass is bounded from below by extra radiation, `ΔN_eff(BBN) = {coef:.3f} (m/eV)^({slope:.4f})` < 0.3 for `m > {m_03:.1f} eV`,
  far more strongly by free streaming: matching the rms velocity of the Lyman-α-allowed thermal warm dark matter
  requires `m ≈ {m_fs[0]:.0f}–{m_fs[1]:.0f} eV` (a velocity-matching estimate), and the Tremaine–Gunn phase-space bound for
  illustrative dwarf spheroidals gives `m > {min(m_tg):.0f}–{max(m_tg):.0f} eV`. At such masses the change of `w_DM` from 1/3 to 0 happens
  around `a_nr` = {a_nr_1kev:.2e} (1 keV) or {a_nr_2kev:.2e} (2 keV): indistinguishable from cold dark matter in the late universe.
- With a mass-varying potential the dark matter exchanges energy with the condensate (`Q = σ8 dm/dt`) and its effective
  `w_DM,eff = w_DM − σ_KS (dm/dN)/(3ε_KS)` ranges, after `a = 1e−3`, over {'; '.join(f"[{a_:+.3g}, {b_:+.3g}] ({SUM[n]['label']})" for (a_, b_), n in zip(wdmeff, de4))}.

Both answers rest on the stabilized model `fable4d` and on semiclassical gravity with the Kohn–Sham ground state (exchange and
correlation neglected, zero modes along the hidden directions); the split of the fable into dark matter and dark energy is a
convention, since the condensate `ρ_U` is an 8-dimensional vacuum energy.
"""
display(Markdown(answer))
print('every claim of the answers is asserted above')
'''))
    cells += closing_cells(name, 8)
    build_fermion(NOTEBOOKS / f"{name}.ipynb", ["fable4d", "fable8d"], cells)


# ==============================================================================================
# Notebook 07: the ground and first excited states, with ideas from density functional theory
# ==============================================================================================

SECTION_1_07 = SECTION_1_FERMION.rstrip() + r"""

This notebook also uses the wall-state solver `fermion/waveguide.py`, a documented Python module
and command-line tool (numpy and scipy from `.venv`; nothing to build), and the committed file
`fermion/waveguide_T16.json` that its validation reads (the matrices `T16` exported from the
Mathematica notebook by `wolframscript -file fable-cosmology/fermion/waveguide_derivation.wls`, which
rewrites it).
"""

WALL_GLOSSARY = r"""
- **Hohenberg–Kohn theorem** -- the ground-state energy of an interacting system is a functional
  of its ground-state densities (here the charge density n and the scalar density σ), stationary
  at the true densities.
- **Kohn–Sham reference system** -- non-interacting fermions in an effective field (here a mass m)
  chosen so that they reproduce the densities; its kinetic energy T_s is known exactly.
- **exchange–correlation energy E_xc** -- the part of the energy beyond the reference system's
  kinetic energy and the mean-field (Hartree) interaction; neglected in this notebook.
- **local-density approximation** -- the mean field at a point depends on the densities at that
  point only: here m(z) = W′(σ(z)).
- **self-consistent field** -- orbitals computed in a mean field that is itself computed from the
  orbitals, iterated (here with Anderson mixing) until the mean field no longer changes.
- **Delta-SCF (ΔSCF)** -- an excited state obtained as a self-consistent solution with prescribed
  occupations that differ from the ground state's; its energy minus the ground-state energy
  estimates the excitation energy.
- **Walecka functional** -- the energy as a functional of the mass m instead of σ,
  Ω(m) = ε_KS(m) + W(σ_m) − m σ_m with W′(σ_m) = m; for attractive W it is convex and minimized at
  the gap root.
- **minimax** -- a stationary point that is a maximum in one variable and a minimum in another
  (Talman); the no-sea functional E_n[σ] has one at the physical state.
- **particle–hole excitation** -- a fermion moved from inside the Fermi sea to outside it; its
  energy can be arbitrarily small (gapless).
- **pair continuum** -- the energies of creating a particle–antiparticle pair out of the Dirac sea,
  the particle above the Fermi sea.
- **wall** -- the end x0 = 0 of the hidden coordinate: a curvature singularity at a finite proper
  distance from every point.
- **proper distance z** -- length along x0 measured with the metric, z = −ln Cos(6Hx0)/(6H).
- **transverse momentum K** -- the momentum along the observed sheet as it is felt near the wall,
  K(z) = K_inf (1 − e^{−12Hz})^{1/12}, K_inf = k e^{a4}.
- **self-adjoint extension** -- the boundary condition that makes an operator on a half-line
  Hermitian; at a regular endpoint one must be chosen.
- **MIT condition** -- the wall condition T16[0]Ψ = ±Ψ (named after the MIT bag model), which stops
  the current through the wall.
- **irrep w3 = ±i** -- the two inequivalent 2-dimensional representations into which the sixteen
  components split along x0.
- **Prüfer angle** -- the angle p of the solution vector, (f, g) = r (cos p, sin p); its turns count
  the levels.
- **bound state, threshold** -- a level below the continuum edge; the transverse momentum at which a
  level leaves the continuum.
- **edge state** -- a state bound to the wall by the wall condition itself, not by a potential well.
- **band** -- a family of levels ω_b(k) labelled by the transverse momentum k.
- **surface density N_s** -- the number of fermions per unit coordinate observed 3-volume in the
  wall problem.
- **Fermi level μ** -- the highest occupied single-particle energy.
"""

SECTION_2_07 = SECTION_2_FERMION.rstrip() + "\n" + WALL_GLOSSARY

# helpers of notebook 07: the wall-state solver, the background full-resolution run, tables, T16
NB07_HELPERS = r'''
import atexit, json, itertools
from scipy.integrate import simpson
from scipy.interpolate import PchipInterpolator
from scipy.special import beta as Beta

FERMION = ROOT / 'fermion'
WG = FERMION / 'waveguide.py'
DEV = FERMION / 'dev'
if not WG.exists():
    print(f'The wall-state solver {WG} is missing: this notebook needs the folder fable-cosmology/fermion of the repository.')
    raise SystemExit(1)
sys.path.insert(0, str(FERMION))
import waveguide as wg
DEV.mkdir(exist_ok=True)
WG_ENV = dict(os.environ, MPLBACKEND='Agg', PYTHONUNBUFFERED='1', PYTHONIOENCODING='utf-8')
print('wall-state solver:', WG.relative_to(ROOT).as_posix(), '--', wg.__doc__.strip().splitlines()[0])

# the full-resolution Kohn-Sham runs of the solver (waveguide.py dft), started now in the background;
# section 5.17 waits for them and compares them with the reduced-resolution runs of this notebook
FULL_LOG = DEV / 'nb07_waveguide_dft_full.log'
_full_fh = open(FULL_LOG, 'w', encoding='utf-8')
FULL_T0 = time.time()
FULL = subprocess.Popen([sys.executable, str(WG), 'dft'], cwd=str(FERMION), stdout=_full_fh, stderr=subprocess.STDOUT, env=WG_ENV)
atexit.register(lambda: FULL.kill() if FULL.poll() is None else None)
print(f'$ python fermion/waveguide.py dft      started in the background (pid {FULL.pid}); its output goes to fermion/dev/{FULL_LOG.name}')


def run_wg(*args, show=True):
    """Run fermion/waveguide.py with these arguments, print its output (unless show=False) and return it."""
    print('$ python fermion/waveguide.py ' + ' '.join(args))
    t0 = time.time()
    r = subprocess.run([sys.executable, str(WG), *args], cwd=str(FERMION), capture_output=True, text=True, env=WG_ENV)
    if show or r.returncode:
        print(r.stdout.rstrip())
    if r.returncode:
        print(r.stderr)
        raise RuntimeError(f'waveguide.py {" ".join(args)} failed with exit code {r.returncode}')
    print(f'  ({time.time() - t0:.1f} s)')
    return r.stdout


def dev_rows(name):
    """The rows of a CSV that waveguide.py has just written into fermion/dev/, numbers converted."""
    with open(DEV / name, newline='', encoding='utf-8') as f:
        rows = list(csv.DictReader(f))
    for r in rows:
        for k, v in r.items():
            try:
                r[k] = float(v)
            except ValueError:
                pass
    return rows


def write_table(name, header, rows, fmt='{:.12g}'):
    """Write results/<name> with a header line; floats with 12 significant digits."""
    with open(RESULTS / name, 'w', newline='') as f:
        wr = csv.writer(f)
        wr.writerow(header)
        wr.writerows([[fmt.format(v) if isinstance(v, float) else v for v in r] for r in rows])
    print('written: results/' + name)


def build_T16():
    """T16[0..8] and sigma16 exactly as Parts I-II of the Mathematica notebook build them (the self-dual and
    anti-self-dual 4x4 blocks, the ordered product tau[7], taubar[A] = sigma . Transpose[sigma . tau[A]])."""
    ID4 = np.eye(4, dtype=int)

    def signature(seq):
        if len(set(seq)) < len(seq):
            return 0
        s = 1
        for i in range(len(seq)):
            for j in range(i + 1, len(seq)):
                if seq[i] > seq[j]:
                    s = -s
        return s

    Qa = lambda h, p, q: signature([h, p, q, 4])
    Qb = lambda h, p, q: ID4[p - 1, 3] * ID4[q - 1, h - 1] - ID4[p - 1, h - 1] * ID4[q - 1, 3]
    s4 = {h: np.array([[Qa(h, p, q) - Qb(h, p, q) for q in range(1, 5)] for p in range(1, 5)]) for h in (1, 2, 3)}
    t4 = {h: np.array([[Qa(h, p, q) + Qb(h, p, q) for q in range(1, 5)] for p in range(1, 5)]) for h in (1, 2, 3)}
    Z4, Z8 = np.zeros((4, 4), dtype=int), np.zeros((8, 8), dtype=int)
    sig = np.block([[Z4, ID4], [ID4, Z4]])
    six = [np.block([[Z4, s4[h]], [s4[h], Z4]]) for h in (1, 2, 3)] + [np.block([[Z4, t4[h]], [-t4[h], Z4]]) for h in (3, 2, 1)]
    tau = {0: np.eye(8, dtype=int), **{h: six[h - 1] for h in range(1, 7)}}
    tau[7] = tau[1] @ tau[2] @ tau[3] @ tau[4] @ tau[5] @ tau[6]
    taubar = {A: sig @ (sig @ tau[A]).T for A in range(8)}
    T = [np.block([[Z8, taubar[A]], [tau[A], Z8]]) for A in range(8)]
    T8 = T[0]
    for A in range(1, 8):
        T8 = T8 @ T[A]
    return [t.astype(float) for t in T] + [T8.astype(float)], (T[0] @ T[1] @ T[2] @ T[3]).astype(float)


def ks_summary(r, Ns):
    """The key numbers of a waveguide.KSResult."""
    i = int(np.argmax(np.abs(r.sigma)))
    o = r.occupations[0]
    return dict(converged=r.converged, iterations=r.iterations, E_per_A=r.E_per_A, E_per_N=r.E_per_A / Ns, mu=r.mu,
                sum_omega=r.sum_omega, E_int=r.E_int, sigma_ext=float(r.sigma[i]), z_ext=float(r.z[i]),
                m_min=float(r.m.min()), m_max=float(r.m.max()), k_lo=o['k_lo'], kF=o['kF'], bottom=o['w_bottom'])


# the reduced resolution of the same-sign Kohn-Sham runs of this notebook (the solver's defaults: Z = 30/H,
# h_near = 0.003/H, 16 Gauss-Legendre nodes per occupied k-interval, 41 k-points on [0, 20] and 81 on [0, 40])
RED = dict(Z=30.0, h_near=0.006, n_gl=12)
KG_SAME = np.linspace(0.0, 20.0, 21)
KG_DSCF = np.linspace(0.0, 40.0, 41)
KG_OPP = np.linspace(0.0, 3.0, 31)
M0, LAM = 1.0, -0.01
print('reduced resolution of the same-sign runs:', RED, f'| k-grids: {len(KG_SAME)} points on [0, {KG_SAME[-1]:g}] (ground state),'
      f' {len(KG_DSCF)} on [0, {KG_DSCF[-1]:g}] (Delta-SCF)')
'''


def notebook_07():
    name = "07_fable_dft_states"
    cells = []
    cells.append(md(r"""
# fermion fable: the ground and first excited states, with ideas from density functional theory

This notebook finds the ground state and the first excited states of the quantized fermion fable,
first in a homogeneous region and then along the hidden coordinate x0 of the primordial
gravitational field, near its wall.  The tools come from density functional theory: the
Hohenberg–Kohn–Sham reduction to a reference system of free fermions in a self-consistent mass,
the local-density approximation, and the ΔSCF construction of excited states.  The homogeneous
Kohn–Sham ground state is the gap root.  The no-sea functional has a maximum there, not a minimum,
and the Walecka functional has a minimum.  The first excitations are gapless particle–hole pairs,
and the pair continuum lies above them.  Along x0 the notebook uses the wall-state solver
`fermion/waveguide.py`.  Its derivation from the Mathematica notebook is quoted from its log.  Its
validation is run here.  From it the notebook takes the wall conditions, the structure of the
spectrum, the thresholds and dispersion of the wall levels, the edge band of the opposite-sign
wall, the family of self-adjoint walls, and the wavefunctions.  Then come the Kohn–Sham ground
states along x0: the author's mass term (free, exact), a variationally consistent edge-band ground
state, the self-consistent wall-band configuration of the same-sign wall with the reason it is not a
variational minimum, the ΔSCF first excited states, the band gap, and the strong-coupling case
where the self-consistency fails.  The last section says what these states mean for the cosmology.
Every number is computed below.
"""))
    cells.append(md(SECTION_1_07))
    cells.append(md(SECTION_2_07))
    cells.append(md(r"""
## 3. The field, its Lagrangian and its energy-momentum tensor

**The field** (Part VII of the Mathematica notebook, restated).  The fermion fable is a complex
16-component Grassmann spinor `Ψ` on the pre-universe (`η = diag(+,+,+,+,−,−,−,−)`, real generators
`T16[a]`, the author's spinor metric `σ16 = T16[0] T16[1] T16[2] T16[3]`, `Ψbar = Ψ^‡ σ16`) with the
symmetrized covariant Lagrangian

    L = Sqrt[|g|] L̂,     L̂ = (1/(2H)) [ Ψbar γ^μ D_μΨ − (D_μΨbar) γ^μ Ψ ] − V(s),     s = Ψbar Ψ ,

and the field equation `γ^μ D_μΨ = H V′(s) Ψ`.  It is quantized canonically with `x4` as time: the
anticommutator carries the indefinite form `G = −i σ16 γ⁴`; the fundamental symmetry
`J = −i T16[0] T16[1] T16[2] T16[3] T16[4]` gives a positive Fock space whose negative-frequency
modes form the Dirac sea; each spatial momentum carries `g = 8` particle states.  Its energy–momentum
tensor operator is `T̂_μν = −(1/(4H)) [ Ψbar γ_μ D_νΨ − (D_νΨbar) γ_μ Ψ + (μ ↔ ν) ] + g_μν L̂`,
normal-ordered with respect to the `J`-vacuum; the energy density measured by the observer is its
`44` component.

**Density functional theory for the fable.**  Because `V` depends on `s` only, the ground state is
fixed by two densities: the conserved charge density `n` (particles minus antiparticles, conserved
by the `U(1)` symmetry) and the scalar density `σ = ⟨χbar χ⟩`, `χ = Ψ/√H`.  Hohenberg–Kohn: the
ground-state energy at given `n` is a functional `E[n, σ]`, stationary at the true `σ`.  Kohn–Sham:
the reference system is a free Fermi gas whose mass `m` is chosen so that its scalar density is `σ`;
its kinetic energy is the Legendre transform `T_s[n, σ] = ε_KS(m) − m σ`, and

    E[n, σ] = T_s[n, σ] + W(σ) + E_xc[n, σ],       W(σ) := V(Hσ) .

Because `∂T_s/∂σ = −m`, stationarity in `σ` is the **gap equation** `m = W′(σ) + ∂E_xc/∂σ`: the
Kohn–Sham mass is the mean field.  This notebook neglects `E_xc` (the Hartree, or mean-field,
approximation).  For a contact interaction the exchange energy is `1/g` of the Hartree energy only in
the non-relativistic regime `kF ≪ m`.  For `kF ≳ m` it is of the same order, and its neglect is then
controlled only by the smallness of the whole interaction energy relative to the kinetic energy;
the cells print that ratio.  The Dirac sea is excluded from `σ` (the no-sea approximation: its vacuum
polarization is absorbed into `W`).

**Along the hidden coordinate** the densities depend on the proper distance `z` from the wall, the
Kohn–Sham orbitals are the wall states of section 4, and per unit coordinate observed 3-volume (hidden
coordinate volume `V_hid = 1/H³`, `a4` frozen at 0)

    σ(z) = Sin(z) Σ_bands 4 ∫ d³k/(2π)³ θ(occupied) (f² − g²)(z),     n(z) likewise with (f² + g²),
    E/A  = Σ_occ ω + ∫ (W − σW′) dz/Sin(z),     Sin(z) = Sqrt[1 − e^{−12Hz}] ,

where `f² − g²` is the Krein-weighted scalar density and `f² + g²` the number density of a block
orbital, and `dz/Sin(z)` is the proper 7-volume per unit coordinate transverse volume.

**What is proved where.**  The field, its quantization and its energy–momentum tensor are asserted in
Part VII of the Mathematica notebook.  The reduction of the wall problem to 2×2 blocks, the wall
conditions and the structure of the spectrum are derived by `fermion/waveguide_derivation.wls`,
which loads the notebook's own Input cells; section 5.3 quotes its log.  The numerics of the wall
levels and of the Kohn–Sham runs are `fermion/waveguide.py`, validated in 5.3 and cross-checked
against Mathematica (`fermion/waveguide_check.wls`), whose numbers 5.7 reads from the solver's
report.  The homogeneous functionals, the excitations, the wall conditions, the 16-component
multiplicities and every Kohn–Sham run are computed in this notebook.
"""))
    cells.append(md(r"""
## 4. The equations of motion

**The homogeneous problem.**  A homogeneous gas of `n = g kF³/(6π²)` fermions per unit volume fills
the momenta `|k| < kF` with `g = 8` states each.  Its Kohn–Sham mass solves the gap equation

    m = W′( σ_KS(m, kF) ),     σ_KS(m, kF) = (g m/(4π²)) [ kF wF − m² asinh(kF/|m|) ],   wF = Sqrt[kF² + m²] .

With `f(m) = m − W′(σ_KS)`, `f′ = 1 − W″ χ` and `0 < χ = ∂σ_KS/∂m ≤ χ0 = g kF²/(4π²)`: the root is unique
when `W″ ≤ 0` or `W″ χ0 < 1`; otherwise there can be several, and the ground state is the root of
lowest energy density `ρ = ε_KS + W − σW′`.

**The wall problem.**  On the canonical frame at fixed `x4`, with `a4` frozen at a constant (0 in the
numerics, where also `H = 1`), a mode `Ψ = Sqrt[Sin(6Hx0)] Ψ′(z) e^{i k x1 − i ω x4}` with proper
distance `z = −ln Cos(6Hx0)/(6H)` satisfies exactly

    T16[0] dΨ′/dz + i K(z) T16[1] Ψ′ − i ω T16[4] Ψ′ = m Ψ′,     K(z) = K_inf (1 − e^{−12Hz})^{1/12},   K_inf = k e^{a4}:

the factor `Sqrt[Sin]` removes the spin-connection term `−3H Cot[6Hx0]² T16[0]` exactly.  In
Hamiltonian form `ωΨ′ = hΨ′`, `h = −i α_z d/dz + K α_x + m β` (`α_z = −T16[4]T16[0]`,
`α_x = −T16[4]T16[1]`, `β = −iT16[4]`).  The algebra of `T16[0], T16[1], T16[4]` and `J` splits the sixteen
components into eight invariant 2-dimensional blocks: four in the irrep `w3 = α_z α_x β = −i` and
four in `w3 = +i`.  In each block `φ = (f, g)` obeys

    df/dz = −s K(z) f + (m + ω) g,       dg/dz = s K(z) g + (m − ω) f,       s = +1 (w3 = −i),  −1 (w3 = +i).

The wall `z = 0` is a curvature singularity at finite proper distance, but the rescaled operator is
regular there (limit circle), so a self-adjoint condition `f(0) cos θ + g(0) sin θ = 0` must be
chosen; at `z → ∞` the operator is limit point.  The covariant, `J`-preserving walls are
`P Ψ(0) = Ψ(0)` with `P = T16[0] Q` and `Q` a Hermitian involution that commutes with `T16[0…4]`.
Flavour symmetry and charge conjugation select `Q = ±1`: the MIT walls `T16[0]Ψ = ±Ψ`, i.e. `f = ±g`
(`θ = ∓π/4`).  The same-sign wall is `T16[0]Ψ = sign(m) Ψ`, the opposite-sign wall `−sign(m)`.  The bulk
continuum is `|ω| ≥ R = Sqrt[m² + K_inf²]`.

**Kohn–Sham along x0.**  With `W(σ) = m0 σ + (λ/2) σ²` the mean field is `m(z) = m0 + λ σ(z)`
(`λ < 0` is attractive).  The positive levels of both irreps form bands `ω_b(k)`, each carrying 4 states
per transverse momentum.  In the ground state a common Fermi level `μ` fills them with
`N_s = Σ_b (4/(6π²)) (kF,b³ − k_lo,b³)` (`k_lo,b` the lower end of band b).  In a ΔSCF state each band
holds a prescribed fraction of `N_s`, filled from its bottom.

### 4.1 The first-order system actually handed to SUNDIALS

One system in this notebook is handed to SUNDIALS: the `fable4d` model of `fable_fermion`,
`dτ/dN = −2τ + A^{−2}/H_A(N)` with `τ = t/A²` and `H_A² = ρ_r + ρ_b + ρ_f(N)`, the gap solved at every
`N` (CVODE BDF, Newton iteration, dense Jacobian, `rtol = 1e−10`, `atol = 1e−12`), in section 5.18,
which shows that the cosmological runs follow the homogeneous Kohn–Sham ground state.  The wall
problem is an eigenvalue problem, not an initial-value problem, and `waveguide.py` does not use
SUNDIALS.  It integrates the Prüfer form of the block equations, `(f, g) = r (cos p, sin p)`:

    dp/dz = m cos 2p + s K(z) sin 2p − ω,          d(ln r)/dz = m sin 2p − s K(z) cos 2p,

from the wall (`p(0) = θ + π/2`) and backwards from `z_a = 3/H`, where `K(z) = K_inf` to `2e−17` and the
decaying solution is the exact eigenvector of the constant system (angle
`p_d = (α − arccos(ω/R))/2`, `α = atan2(sK_inf, m)`).  The integrators are scipy's DOP853
(`rtol = atol = 1e−12`, the reference) and a fourth-order Magnus propagator on a fixed nonuniform grid.
A level is a zero of the mismatch `Δ(ω) − jπ`.  Because `Δ` decreases strictly with `ω`, the number of
levels in the gap is counted exactly before they are searched.  The Kohn–Sham engine shoots with the
Magnus propagator on a grid that is geometric near the wall (step `h_near` there, `0.02/H` beyond
`z = 4/H`, up to `z = Z`).
"""))
    cells.append(md(r"""
## 5. Running the solver

Two solvers are used.  `rust/fable_fermion/target/release/fable_fermion` (`.exe` on Windows):

    fable_fermion gap --form NAME --param KEY=VALUE ... --kf KF [--v V]
    fable_fermion fable4d --potential NAME [--param KEY=VALUE ...] [--points K] [--out FILE.csv] ...

(`gap` prints every root of the gap equation with `m, sigma8, rho8, P_obs, P_hid, gap_residual` and the
selected root; `fable4d` is the stabilized cosmological model).  And the wall-state solver
`fermion/waveguide.py`, run from `fable-cosmology/fermion` as `python waveguide.py <command>`:

    validate      analytic cases, Hellmann-Feynman, Magnus against DOP853, 16x16 multiplicities (64 checks)
    levels        all levels of both irreps at --K --m --wall same|opposite [--theta th]
    threshold     K_c(1), K_c(2) versus m/H (same-sign MIT wall), and the further thresholds
    figures       the dispersion, the edge band, the theta family and the wavefunctions (tables)
    dft           the Kohn-Sham runs: --scenario all (free, same-sign ground state + Walecka check +
                  band gaps + Delta-SCF, opposite-sign edge band) | free | same | opposite | bulk |
                  strong (exploratory) | convergence

Its tables go to `fermion/dev/` (not part of the repository) with the prefix `waveguide_`; this
notebook reads the ones its commands have just written and writes its own results under `results/`.
The notebook also imports `waveguide.py` as a module and calls its functions directly (`find_levels`,
`wavefunction`, `full16_singular_values`, `ks_solve`, `walecka_check`, `KSGrid`), with the parameters
shown in each cell.  The full-resolution Kohn–Sham runs (`python waveguide.py dft`, about 9–10
minutes) are started in the background by the next-but-one cell and collected in section 5.17; that
cell waits for them if they are not yet finished (the one cell of this project that can take longer
than a minute).  The same-sign runs of this notebook use a reduced resolution, stated in the cell,
and 5.17 compares them with the full-resolution numbers.

The next cell locates the binary, reads the unit system from it and defines the Python Kohn–Sham
toolkit (the Fermi sea in stable forms, the potentials, a gap solver that finds every root).
"""))
    cells.append(code(FERMION_SETUP_CODE))
    cells.append(md(r"""
The notebook-specific helpers: the wall-state solver imported as a module, the background start of
its full-resolution Kohn–Sham runs, a runner for its commands, a reader for the tables it writes, the
construction of `T16` exactly as the Mathematica notebook builds it, and the reduced resolution used
below for the same-sign wall.
"""))
    cells.append(code(NB07_HELPERS))
    # ---- 5.1 homogeneous
    cells.append(md(r"""
### 5.1 The homogeneous Kohn–Sham ground state: a minimax, a convex Walecka functional, and branch selection

Three computations.  (i) The no-sea functional of the author's mass term `W = m0 σ` (`m0 = 2`,
`kF = 1.5`): `E_n[σ] = T_s + W` with `T_s = ε_KS(m(σ)) − m(σ) σ` and `m(σ)` defined by `σ_KS(m, kF) = σ`.  Its
stationary point is the gap root `m = m0`, where `E_n = ρ`; because `d²T_s/dσ² = −1/χ < 0` (checked
numerically) it is a **maximum**, and `E_n → −|m0| n` as `σ → −n` (every particle in the negative-mass
band: Dirac-sea states).  The ground state is this stationary point, never the minimum over `σ`.
(ii) For the attractive `W = σ − 10σ²` (`kF = 1`) the Walecka functional
`Ω_n(m) = ε_KS(m) + W(σ_m) − m σ_m` is convex, minimized at the unique gap root, where `Ω = ρ`.
(iii) The repulsive `W = 0.05 σ + 10 σ²`: below `kF = Sqrt[4π²/(λg)]` (`λχ0 < 1`) the root is unique; above
it there can be three, found here and by `fable_fermion gap`, and the ground state is the one of
lowest `ρ`.  The curves go to `results/nb07_homogeneous.csv` and `results/nb07_homogeneous.png`.
"""))
    cells.append(code(r'''
def m_of_sigma(s, kf):
    """The m with sigma_KS(m, kF) = s (odd, increasing, onto (-n, n))."""
    f = lambda m: fermi_sea(m, kf)['sigma'] - s
    hi, lo = kf, -kf
    while f(hi) < 0:
        hi *= 2
    while f(lo) > 0:
        lo *= 2
    return brentq(f, lo, hi, xtol=1e-300, rtol=1e-15, maxiter=500)


def E_nosea(pot, s, kf):
    m = m_of_sigma(s, kf)
    return fermi_sea(m, kf)['eps'] - m * s + pot.W(s)


# (i) the minimax of the no-sea functional, W = 2 sigma, kF = 1.5
Wm, kfm = Pot('mass', m0=2.0), 1.5
n_m = G_FABLE * kfm ** 3 / (6 * PI2)
s_star = fermi_sea(2.0, kfm)['sigma']
E_star = E_nosea(Wm, s_star, kfm)
fr = np.concatenate([-1 + np.geomspace(1e-7, 1e-2, 20), np.linspace(-0.99, 0.99, 149), 1 - np.geomspace(1e-2, 1e-7, 20)])
E_curve = np.array([E_nosea(Wm, f_ * n_m, kfm) for f_ in fr])
h = 1e-3 * n_m
d2T = (E_nosea(Wm, s_star + h, kfm) - 2 * E_star + E_nosea(Wm, s_star - h, kfm)) / h ** 2
chi_star = fermi_sea(2.0, kfm)['chi']
print(f'(i) W = 2 sigma, kF = {kfm}: gap root sigma*/n = {s_star / n_m:.6f}; E_n(sigma*) = {E_star:.12f} = rho = eps_KS(m0) = {fermi_sea(2.0, kfm)["eps"]:.12f}')
print(f'    d2E_n/dsigma2 at the root = {d2T:.6f}, -1/chi = {-1 / chi_star:.6f}: a MAXIMUM;  E_n/n at sigma = -(1 - 1e-7) n = {E_curve[0] / n_m:+.6f} (-> -|m0| = -2)')
assert abs(E_star / fermi_sea(2.0, kfm)['eps'] - 1) < 1e-12 and d2T < 0 and abs(d2T * chi_star + 1) < 1e-3 and E_curve.max() <= E_star + 1e-12

# (ii) the convex Walecka functional, W = sigma - 10 sigma^2, kF = 1
Wa, kfa = Pot('quadratic', v0=0.0, m0=1.0, lam=-20.0), 1.0
ra = gap_roots(Wa, kfa)
ga = mean_field(Wa, ra[0], kfa)
Om = lambda m: fermi_sea(m, kfa)['eps'] + Wa.W((m - 1.0) / -20.0) - m * (m - 1.0) / -20.0
mg = np.linspace(-0.6, 1.0, 161)
Om_curve = np.array([Om(m) for m in mg])
print(f'(ii) W = sigma - 10 sigma^2, kF = 1: {len(ra)} gap root m* = {ra[0]:.10f}, rho = {ga["rho"]:.10f} = Omega(m*) = {Om(ra[0]):.10f};'
      f' Omega convex on the grid: {bool(np.all(np.diff(Om_curve, 2) > 0))}, minimum {Om_curve.min():.10f} at m = {mg[Om_curve.argmin()]:.3f}')
assert len(ra) == 1 and abs(Om(ra[0]) / ga['rho'] - 1) < 1e-12 and np.all(np.diff(Om_curve, 2) > 0) and Om_curve.min() >= Om(ra[0]) - 1e-14

# (iii) uniqueness criterion and the three roots of the repulsive quadratic, with fable_fermion gap
Wr = Pot('quadratic', v0=0.0, m0=0.05, lam=20.0)
kf_c = math.sqrt(4 * PI2 / (20.0 * G_FABLE))
print(f'(iii) W = 0.05 sigma + 10 sigma^2: lam chi0 = 1 at kF = {kf_c:.6f}')
rows3 = []
for kf in (0.4, 1.0):
    roots = gap_roots(Wr, kf)
    mfs = [mean_field(Wr, m, kf) for m in roots]
    best = min(mfs, key=lambda d: d['rho'])
    r = subprocess.run([str(BIN), 'gap', '--form', 'quadratic', '--param', 'm0=0.05', '--param', 'lam=20', '--kf', repr(kf)], check=True, capture_output=True, text=True)
    rust = [list(map(float, l.split(','))) for l in r.stdout.splitlines() if l and not l.startswith('#') and not l.startswith('m,')]
    sel = float(re.search(r'm = ([-+0-9.e]+)', [l for l in r.stdout.splitlines() if l.startswith('# selected')][0]).group(1))
    assert len(rust) == len(roots) and all(abs(d['m'] - rr[0]) <= 1e-10 * max(1.0, abs(rr[0])) for d, rr in zip(mfs, rust)) and abs(sel - best['m']) <= 1e-10
    print(f'    kF = {kf}: lam chi0 = {20 * G_FABLE * kf * kf / (4 * PI2):.4f}, {len(roots)} root(s) (Python and fable_fermion gap agree):')
    for d in mfs:
        tag = '  <- lowest rho: the ground state' if d is best else ''
        print(f'        m = {d["m"]:+.10f}   rho = {d["rho"]:.10f}   (rho + P_obs)/(wF n) = {(d["rho"] + d["P_obs"]) / (d["wF"] * d["n8"]):.12f}{tag}')
        rows3.append(('repulsive quadratic roots', kf, d['m'], d['rho']))
assert len(gap_roots(Wr, 0.4)) == 1 and len(gap_roots(Wr, 1.0)) == 3

rows = [('no-sea E_n(sigma)/n, W = 2 sigma, kF = 1.5; x = sigma/n', float(a_), float(b_ / n_m)) for a_, b_ in zip(fr, E_curve)]
rows += [('Walecka Omega(m), W = sigma - 10 sigma^2, kF = 1; x = m', float(a_), float(b_)) for a_, b_ in zip(mg, Om_curve)]
rows += [(lab, float(kf), float(m), float(rho)) for lab, kf, m, rho in rows3]
write_table('nb07_homogeneous.csv', ['curve', 'x_or_kF', 'value_or_m', 'rho'], [list(r) + ([''] if len(r) == 3 else []) for r in rows])
fig, ax = plt.subplots(1, 3, figsize=(16, 4.2))
ax[0].plot(fr, E_curve / n_m); ax[0].plot(s_star / n_m, E_star / n_m, 'ko', label='gap root: a MAXIMUM'); ax[0].axhline(-2.0, color='tab:red', ls=':', label='-|m0|')
ax[0].set_xlabel('sigma/n'); ax[0].set_ylabel('E_n[sigma]/n'); ax[0].set_title('no-sea functional, W = 2 sigma, kF = 1.5'); ax[0].legend(fontsize=8)
ax[1].plot(mg, Om_curve); ax[1].plot(ra[0], Om(ra[0]), 'ko', label='gap root: the minimum'); ax[1].set_xlabel('m'); ax[1].set_ylabel('Omega_n(m)')
ax[1].set_title('Walecka functional, W = sigma - 10 sigma^2, kF = 1'); ax[1].legend(fontsize=8)
mm_ = np.linspace(-3.2, 3.2, 801)
for kf, col in ((1.0, 'tab:blue'), (0.4, 'tab:orange')):
    ax[2].plot(mm_, [gap_function(Wr, m, kf) for m in mm_], color=col, label=f'kF = {kf}')
ax[2].axhline(0, color='k', lw=0.5); ax[2].set_ylim(-3, 3); ax[2].set_xlabel('m'); ax[2].set_ylabel("m - W'(sigma_KS(m))")
ax[2].set_title('repulsive quadratic: one root, then three'); ax[2].legend(fontsize=8)
fig.tight_layout(); fig.savefig(RESULTS / 'nb07_homogeneous.png', dpi=130, bbox_inches='tight'); print('figure: results/nb07_homogeneous.png'); plt.show()
'''))
    # ---- 5.2 excitations
    cells.append(md(r"""
### 5.2 The first excited states of the homogeneous gas: gapless particle–hole pairs, and the pair continuum

In the ground state the positive-energy states `|k| < kF` are filled and the Dirac sea is full.  A
**particle–hole** excitation of total momentum `Q` moves a fermion from `k` (`|k| < kF`) to `k + Q`
(`|k + Q| > kF`) at the cost `ω(k + Q) − ω(k)`.  Its minimum over `k` vanishes for every `Q ≤ 2kF`
(Fermi surface to Fermi surface): the excitations are gapless, and in the thermodynamic limit the
lowest of them is degenerate with the ground state.  A **pair** excitation creates a particle at `p`
(`|p| ≥ kF`, Pauli) and a hole in the Dirac sea (an antiparticle of energy `ω(p′)`), total momentum
`Q = p − p′`.  Its threshold is `wF + ω(|kF − Q|)` for `Q ≤ 2kF` (the particle on the Fermi surface) and
`2ω(Q/2)` beyond: `2wF` at `Q = 0`, and its lowest point is `wF + |m|` at `Q = kF`.  The cell minimizes both energies by brute force over the
momenta (a grid of `p` in the plane of `Q`, at `m = 1`, `kF = 1.5`), compares them with these closed
forms, and writes `results/nb07_excitations.csv` and `results/nb07_excitations.png`.
"""))
    cells.append(code(r'''
m_e, kf_e = 1.0, 1.5
om = lambda k: np.sqrt(k * k + m_e * m_e)
wF_e = om(kf_e)
Qs = np.linspace(0.0, 3.5, 36)
th_ = np.linspace(0.0, np.pi, 2881)
rows, dev_ph, dev_pair = [], 0.0, 0.0
for Q in Qs:
    # particle-hole: k inside the Fermi ball, k + Q outside; minimize omega(k + Q) - omega(k) on a polar grid
    kk = np.linspace(0.0, kf_e, 301)[:, None]
    kx, ky = kk * np.cos(th_), kk * np.sin(th_)
    kq = np.hypot(kx + Q, ky)
    dE = np.where(kq >= kf_e, om(kq) - om(kk), np.inf)
    ph = float(dE.min())
    ph_exact = 0.0 if Q <= 2 * kf_e else float(om(Q - kf_e) - wF_e)
    # pair: particle at p (|p| >= kF), antiparticle from the sea at p' = p - Q; minimize omega(p) + omega(p - Q)
    pp = np.linspace(kf_e, kf_e + 4.0, 801)[:, None]
    px, py = pp * np.cos(th_), pp * np.sin(th_)
    pair = float((om(pp) + om(np.hypot(px - Q, py))).min())
    pair_exact = float(wF_e + om(abs(kf_e - Q))) if Q <= 2 * kf_e else float(2 * om(Q / 2))
    dev_ph, dev_pair = max(dev_ph, abs(ph - ph_exact)), max(dev_pair, abs(pair - pair_exact))
    rows.append([float(Q), ph, ph_exact, pair, pair_exact])
rows_a = np.array(rows)
i_min = int(np.argmin(rows_a[:, 4]))
print(f'm = {m_e}, kF = {kf_e}, wF = {wF_e:.6f}:  largest |brute force - closed form|: particle-hole {dev_ph:.2e}, pair {dev_pair:.2e} (grid-limited)')
print(f'particle-hole threshold = 0 for Q <= 2 kF = {2 * kf_e}: gapless;  pair threshold at Q = 0: {rows_a[0, 3]:.6f} (2 wF = {2 * wF_e:.6f});'
      f'  lowest pair threshold {rows_a[i_min, 4]:.6f} at Q = {rows_a[i_min, 0]:.2f} (wF + |m| = {wF_e + m_e:.6f} at Q = kF)')
assert dev_ph < 2e-2 and dev_pair < 1e-9 and abs(rows_a[0, 1]) < 1e-12 and abs(rows_a[i_min, 0] - kf_e) < 0.051
write_table('nb07_excitations.csv', ['Q', 'particle_hole_min_bruteforce', 'particle_hole_min_closed', 'pair_min_bruteforce', 'pair_min_closed'], rows)
fig, ax = plt.subplots(figsize=(7.5, 4.3))
ax.plot(rows_a[:, 0], rows_a[:, 2], 'k-', label='particle-hole: lowest energy (closed form)'); ax.plot(rows_a[:, 0], rows_a[:, 1], 'k.', ms=4, label='brute force')
ax.plot(rows_a[:, 0], rows_a[:, 4], 'r-', label='pair continuum: threshold (closed form)'); ax.plot(rows_a[:, 0], rows_a[:, 3], 'r.', ms=4, label='brute force')
ax.axvline(kf_e, color='0.6', ls=':'); ax.axvline(2 * kf_e, color='0.6', ls=':')
ax.set_xlabel('total momentum Q'); ax.set_ylabel('excitation energy'); ax.set_title(f'homogeneous Kohn-Sham gas, m = {m_e}, kF = {kf_e}'); ax.legend(fontsize=8)
fig.savefig(RESULTS / 'nb07_excitations.png', dpi=130, bbox_inches='tight'); print('figure: results/nb07_excitations.png'); plt.show()
'''))
    # ---- 5.3 derivation and validation
    cells.append(md(r"""
### 5.3 The wall problem: the derivation (quoted from its log) and the solver's validation

`fermion/waveguide_derivation.wls` loads the Input cells 1–117 of the Mathematica notebook and derives
the wall problem from the notebook's own `T16`, `gammaCurvedCanonical`, `GammaSpinCanonical` and
`cfDcov16`.  The first cell reads its committed log `fermion/waveguide_derivation.log`, prints its key
PASS lines (the rescaling, the proper distance, the 2×2 blocks, the wall conditions, the symmetries,
the endpoints and the spectrum structure) and checks that every one of its checks passed.  The second
builds `T16` here exactly as the notebook does, compares it with the matrices the derivation exported
to the committed file `fermion/waveguide_T16.json`, and runs `python waveguide.py validate`: exact solutions (constant
`K`, the flat band `ω = m` for `g(0) = 0`), the Hellmann–Feynman theorem, Magnus against DOP853, the
16-component multiplicities with the notebook's `T16`, the block basis, and the closed-form slope of
the edge band.  It asserts that all 64 checks pass.
"""))
    cells.append(code(r'''
log = (FERMION / 'waveguide_derivation.log').read_text(encoding='utf-8')
lines = log.splitlines()
n_pass = sum(1 for l in lines if l.strip().startswith('PASS'))
n_fail = sum(1 for l in lines if l.strip().startswith('FAIL'))
m_sum = re.search(r'(\d+) checks, (\d+) PASS, (\d+) FAIL', log)
print('\n'.join(l.strip() for l in lines[1:4]))
keys = ['RESCALING', 'the wall is at FINITE proper distance', 'transverse term', 'the one-particle space of Psi', 'curvature singularity at finite proper distance',
        'dim <alz, alx, bet, J> = 16', 'every joint eigenspace', 'irrep w3 = -i (4 blocks)', 'irrep w3 = +i (4 blocks)',
        'MIT T16[0] Psi = eps Psi', 'maximal isotropic', 'MIT+ (T0 Psi = +Psi, 8-dim)', 'only the two MIT conditions are covariant',
        'flavour symmetry (Q central) AND C select', 'S(K) = S(-K) = -S(K)', 'REGULAR endpoint', 'limit point', 'a flat band', 'NO bound state']
quoted = []
for k in keys:
    hit = next((l.strip() for l in lines if k in l and l.strip().startswith('PASS')), None)
    assert hit is not None, f'no PASS line containing {k!r} in the derivation log'
    quoted.append(hit)
    print('  ' + (hit if len(hit) <= 230 else hit[:227] + '...'))
i_c = next(i for i, l in enumerate(lines) if 'CONSEQUENCE (MIT walls)' in l)
print('\n'.join('  ' + l.strip() for l in lines[i_c:i_c + 4]))
print(f'derivation log: {n_pass} PASS lines, {n_fail} FAIL lines; summary line: "{m_sum.group(0)}"')
assert n_fail == 0 and int(m_sum.group(1)) == int(m_sum.group(2)) == n_pass and int(m_sum.group(3)) == 0
'''))
    cells.append(md(r"""
`T16` built here against the exported matrices, then the validation of the wall-state solver (about half
a minute).  The validation reads the committed file `fermion/waveguide_T16.json`; if it has been
removed, the cell says how to rewrite it from the Mathematica notebook and stops.
"""))
    cells.append(code(r'''
T16, S16 = build_T16()
assert all(np.array_equal(T16[a] @ T16[b] + T16[b] @ T16[a], 2 * ((1 if a < 4 else -1) if a == b else 0) * np.eye(16)) for a in range(8) for b in range(8))
jpath = FERMION / 'waveguide_T16.json'
if not jpath.exists():
    print(f'{jpath} is missing (it is part of the repository).  It is rewritten by  wolframscript -file fable-cosmology/fermion/waveguide_derivation.wls  (about 3.5 minutes; needs Mathematica).')
    raise SystemExit(1)
jd = json.loads(jpath.read_text())
same = [bool(np.array_equal(np.array(jd['T16'][a], float), T16[a])) for a in range(9)] + [bool(np.array_equal(np.array(jd['sigma16'], float), S16))]
print(f'T16[0..8] and sigma16 built here are identical to the matrices exported by the derivation: {all(same)} ({sum(same)} of {len(same)})')
assert all(same)
out = run_wg('validate')
mv = re.search(r'VALIDATION: (\d+) of (\d+) PASS', out)
N_VALID = (int(mv.group(1)), int(mv.group(2)))
print(f'validation: {N_VALID[0]} of {N_VALID[1]} PASS')
assert N_VALID == (64, 64)
'''))
    # ---- 5.4 wall conditions
    cells.append(md(r"""
### 5.4 The wall conditions `P Ψ(0) = Ψ(0)`, `P = T16[0] Q`, and why the MIT walls

With the `T16` built above the cell checks, for `Q = +1, −1, +J, −J`: `P` is a Hermitian involution,
commutes with `J`, and commutes with the six generators `T16[a]T16[b]` of the wall's `Spin(1,3)` of
`x1, x2, x3, x4` (covariance).  On its 8-dimensional `+1` eigenspace (basis `V`) the scalar density and
the normal current vanish for every complex `Ψ`: the matrices `V^† σ16 V` and `V^† σ16 T16[0] V` are zero.
Whether `P` is real decides invariance under the charge conjugation `Ψ → Ψ^*` (`T16` is real, `J^* = −J`):
only `Q = ±1` pass, the MIT walls `T16[0]Ψ = ±Ψ`.  For contrast, the non-covariant member
`β = −iT16[4]` of the uniform family `cos φ β + sin φ T16[0]` anticommutes with the boosts `T16[i]T16[4]`.
The table goes to `results/nb07_wall_conditions.csv`.
"""))
    cells.append(code(r'''
T0 = T16[0]
J = -1j * (T16[0] @ T16[1] @ T16[2] @ T16[3] @ T16[4])
bet = -1j * T16[4]
I16 = np.eye(16)
gens = [(a, b) for a, b in itertools.combinations((1, 2, 3, 4), 2)]
rows = []
print(f"{'Q':>3s} {'Hermitian':>9s} {'P^2 = 1':>7s} {'[P,J]=0':>7s} {'covariant':>9s} {'|V+ s16 V|':>10s} {'|V+ s16 T0 V|':>13s} {'P real (C)':>10s}")
for lab, Q in (('+1', I16), ('-1', -I16), ('+J', J), ('-J', -J)):
    P = T0 @ Q
    ev, V = np.linalg.eigh(P)
    Vp = V[:, ev > 0]
    herm, inv, commJ = np.allclose(P, P.conj().T), np.allclose(P @ P, I16), np.allclose(P @ J, J @ P)
    cov = all(np.allclose(P @ (T16[a] @ T16[b]), (T16[a] @ T16[b]) @ P) for a, b in gens)
    sc, cur = np.abs(Vp.conj().T @ S16 @ Vp).max(), np.abs(Vp.conj().T @ (S16 @ T0) @ Vp).max()
    real = bool(np.allclose(P.imag, 0))
    rows.append([lab, herm, inv, commJ, cov, int(Vp.shape[1]), float(sc), float(cur), real])
    print(f'{lab:>3s} {str(herm):>9s} {str(inv):>7s} {str(commJ):>7s} {str(cov):>9s} {sc:10.1e} {cur:13.1e} {str(real):>10s}')
    assert herm and inv and commJ and cov and Vp.shape[1] == 8 and sc < 1e-12 and cur < 1e-12
assert [r[-1] for r in rows] == [True, True, False, False]
anti_boost = all(np.allclose(bet @ (T16[i] @ T16[4]), -(T16[i] @ T16[4]) @ bet) for i in (1, 2, 3))
comm_rot = all(np.allclose(bet @ (T16[i] @ T16[j]), (T16[i] @ T16[j]) @ bet) for i, j in ((1, 2), (1, 3), (2, 3)))
print(f'beta = -i T16[4] anticommutes with the three boosts T16[i]T16[4]: {anti_boost}; commutes with the rotations T16[i]T16[j]: {comm_rot}'
      ' -> only cos(phi) = 0 in cos(phi) beta + sin(phi) T16[0] is covariant: the MIT walls')
assert anti_boost and comm_rot
write_table('nb07_wall_conditions.csv', ['Q', 'hermitian', 'involution', 'commutes_with_J', 'covariant_Spin13', 'dim_plus_space',
                                         'max_scalar_density_form', 'max_normal_current_form', 'real_C_invariant'], rows)
'''))
    # ---- 5.5 spectrum structure
    cells.append(md(r"""
### 5.5 The structure of the spectrum: `S(K) = A(K) ∪ (−A(K))`, every level 4-fold

With MIT walls the levels of the irrep `w3 = +i` are the negatives of those of `w3 = −i`, so the
16-component spectrum at transverse momentum `K` is `A(K) ∪ (−A(K))`, `A(K)` the levels of the `s = +1`
block equation, and every positive level is 4-fold per transverse momentum vector (two blocks with
`J = +1`, two with `J = −1`, of one irrep).  The cell computes both irreps at `K = 80` (same-sign wall,
`m = H = 1`) with `waveguide.find_levels`, checks the symmetry, and then counts the multiplicity of
levels directly in the **16-component** problem with the `T16` built in this notebook: the number of
vanishing singular values of the matched left and right solution spaces
(`waveguide.full16_singular_values`).  The positive levels go to `results/nb07_levels_K80.csv`.
"""))
    cells.append(code(r'''
K80 = 80.0
Aminus, c1 = wg.find_levels(wg.Block(Kinf=K80, m=1.0, theta=wg.theta_MIT(+1)))
Aplus, c2 = wg.find_levels(wg.Block(Kinf=-K80, m=1.0, theta=wg.theta_MIT(+1)))
print(f'K = {K80}, same-sign MIT wall, m = H = 1, continuum from R = {math.hypot(1.0, K80):.9f}')
print('  irrep -i (s = +1): ' + ', '.join(f'{L.w:+.9f}' for L in Aminus) + f'   (exact count {c1})')
print('  irrep +i (s = -1): ' + ', '.join(f'{L.w:+.9f}' for L in Aplus) + f'   (exact count {c2})')
sym = max(abs(a + b) for a, b in zip(sorted(L.w for L in Aminus), sorted((L.w for L in Aplus), reverse=True)))
print(f'max |A_(+i) + A_(-i)| (the om -> -om symmetry) = {sym:.1e}')
assert c1 == len(Aminus) and c2 == len(Aplus) and len(Aminus) == len(Aplus) and sym < 1e-9
LEV80 = sorted([(L.w, '-i', L.kappa) for L in Aminus if L.w > 0] + [(L.w, '+i', L.kappa) for L in Aplus if L.w > 0])
rows = []
for n, (w, irr, kap) in enumerate(LEV80):
    sv, zm = wg.full16_singular_values(w, K80, 1.0, +1, T16)
    mult = int(np.sum(sv < 1e-6))
    rows.append([n, w, irr, kap, math.hypot(1.0, K80) - w, mult])
    print(f'  n = {n}: omega = {w:.9f} (irrep {irr}), kappa = {kap:.4f}, binding R - omega = {math.hypot(1.0, K80) - w:.6f};'
          f' 16-component multiplicity {mult} (smallest singular values {sv[-1]:.1e}, next {sv[-mult - 1]:.2f})')
    assert mult == 4
for w in (-LEV80[0][0], 0.37 * math.hypot(1.0, K80)):
    sv, _ = wg.full16_singular_values(w, K80, 1.0, +1, T16)
    print(f'  omega = {w:+.6f}: 16-component multiplicity {int(np.sum(sv < 1e-6))}' + ('  (the mirror level: 4-fold as well)' if w < 0 else '  (not a level)'))
    assert int(np.sum(sv < 1e-6)) == (4 if w < 0 else 0)
write_table('nb07_levels_K80.csv', ['n', 'omega', 'irrep', 'kappa', 'binding_R_minus_omega', 'multiplicity_16'], rows)
'''))
    # ---- 5.6 thresholds
    cells.append(md(r"""
### 5.6 The thresholds `K_c(1)`, `K_c(2)` of the same-sign wall versus `m/H`

A same-sign wall binds nothing at small transverse momentum: a level appears only where the pocket
`K(z)` near the wall is deep enough.  `python waveguide.py threshold` finds, for `m/H = 0.25 … 8`, the
transverse momentum at which the first and the second positive level of the 16-component problem
appear (exact Prüfer count, bisection to `1e−9`), the irrep in which each appears, the second level
within irrep `−i` alone, and the thresholds of the opposite-sign wall.  The cell prints its output,
copies its table to `results/nb07_thresholds.csv` and draws `results/nb07_thresholds.png`.
"""))
    cells.append(code(r'''
out_thr = run_wg('threshold')
thr = dev_rows('waveguide_thresholds.csv')
THR = {r['m_over_H']: r for r in thr}
write_table('nb07_thresholds.csv', ['m_over_H', 'Kc1_over_H', 'irrep1', 'Kc2_over_H', 'irrep2'],
            [[r['m_over_H'], r['Kc1_over_H'], r['irrep1'], r['Kc2_over_H'], r['irrep2']] for r in thr])
assert all(r['irrep1'] == '-i' and r['irrep2'] == '+i' for r in thr)
K_WITHIN = float(re.search(r'WITHIN irrep -i .*? at K = ([\d.]+)', out_thr).group(1))
K_OPP = [float(x) for x in re.findall(r'K = ([\d.]+) \(irrep', out_thr.split('opposite-sign wall')[1])]
ms_ = np.array([r['m_over_H'] for r in thr]); k1 = np.array([r['Kc1_over_H'] for r in thr]); k2 = np.array([r['Kc2_over_H'] for r in thr])
slope1 = np.polyfit(np.log(ms_), np.log(k1), 1)[0]
print(f'K_c(1) grows like (m/H)^{slope1:.3f} over m/H = {ms_[0]:g}..{ms_[-1]:g}; K_c(2) ranges only over {k2.min():.4f}..{k2.max():.4f} H')
print(f'second level within irrep -i (m = H): K = {K_WITHIN:.9f};  opposite-sign wall, further levels at K = {", ".join(f"{k:.8f}" for k in K_OPP)}')
fig, ax = plt.subplots(figsize=(7, 4.3))
ax.loglog(ms_, k1, 'o-', label='K_c(1): first level (irrep -i)'); ax.loglog(ms_, k2, 's-', label='K_c(2): second level (irrep +i)')
ax.set_xlabel('m / H'); ax.set_ylabel('threshold K_inf / H'); ax.set_title('same-sign MIT wall: where the wall levels appear'); ax.legend(fontsize=8)
fig.savefig(RESULTS / 'nb07_thresholds.png', dpi=130, bbox_inches='tight'); print('figure: results/nb07_thresholds.png'); plt.show()
'''))
    # ---- 5.7 dispersion
    cells.append(md(r"""
### 5.7 The dispersion `ω_n(K)`, n = 0…3, of the same-sign wall, and the levels at `K = 80`

`python waveguide.py figures` computes the positive levels of the 16-component problem for
`K = 7, 8, …, 100` (same-sign and opposite-sign walls), the edge band, the `θ` family and the
wavefunctions.  The cell prints its output, draws `ω_n(K)` and the binding `R − ω_n` (the depth below the
continuum), checks its `K = 80` row against the levels of 5.5, and compares those with the independent
Mathematica values (`NDSolve` at 30 digits, `fermion/waveguide_check.wls`) that the solver's committed
report `fermion/waveguide_REPORT.txt` lists.  The table goes to `results/nb07_dispersion_same.csv`, the
figure to `results/nb07_dispersion.png`.
"""))
    cells.append(code(r'''
out_fig = run_wg('figures', show=False)
print('DISPERSION' + out_fig.split('DISPERSION')[1].split(2 * chr(10))[0])
disp = dev_rows('waveguide_dispersion_same_m1.csv')
write_table('nb07_dispersion_same.csv', ['K', 'R_continuum', 'n', 'omega', 'irrep', 'kappa', 'R_minus_omega'],
            [[r['K'], r['R_continuum'], int(r['n']), r['omega'], r['irrep'], r['kappa'], r['R_minus_omega']] for r in disp])
row80 = sorted([(r['omega'], r['irrep']) for r in disp if r['K'] == 80.0])
d_mod = max(abs(a[0] - b[0]) for a, b in zip(row80, LEV80))
print(f'K = 80 from the table: {", ".join(f"{w:.9f} ({i})" for w, i in row80)};  max |table - 5.5| = {d_mod:.1e}')
assert len(row80) == len(LEV80) == 4 and d_mod < 1e-9 and [i for _, i in row80] == [i for _, i, _ in LEV80]
rep = (FERMION / 'waveguide_REPORT.txt').read_text(encoding='utf-8')
MATH80 = {}
for mt in re.finditer(r'same-sign K=80 n=(\d) \(irrep ([-+]i)\)\s+([-+\d.]+)\s+([-+\d.]+)\s+([\d.e+-]+)', rep):
    MATH80[int(mt.group(1))] = float(mt.group(4))
dmath = max(abs(LEV80[n][0] - MATH80[n]) for n in range(4))
print('Mathematica (waveguide_check.wls, as listed in waveguide_REPORT.txt): ' + ', '.join(f'n = {n}: {MATH80[n]:.11f}' for n in range(4))
      + f';  max |notebook - Mathematica| = {dmath:.1e}')
assert len(MATH80) == 4 and dmath < 1e-9
Ks_ = sorted(set(r['K'] for r in disp))
fig, ax = plt.subplots(1, 2, figsize=(13, 4.4))
for n, col in zip(range(4), ('tab:blue', 'tab:orange', 'tab:green', 'tab:red')):
    pts = [(r['K'], r['omega'], r['R_minus_omega'], r['irrep']) for r in disp if int(r['n']) == n]
    if pts:
        P_ = np.array([(a, b, c) for a, b, c, _ in pts])
        ax[0].plot(P_[:, 0], P_[:, 1], color=col, label=f'n = {n} (irrep {pts[0][3]} at its onset)')
        ax[1].semilogy(P_[:, 0], P_[:, 2], color=col, label=f'n = {n}')
ax[0].plot(Ks_, [math.hypot(1.0, k) for k in Ks_], 'k:', label='continuum edge R = sqrt(m^2 + K^2)')
ax[0].set_xlabel('K_inf / H'); ax[0].set_ylabel('omega_n / H'); ax[0].set_title('same-sign wall, m = H: positive levels (each 4-fold)'); ax[0].legend(fontsize=8)
ax[1].set_xlabel('K_inf / H'); ax[1].set_ylabel('R - omega_n (binding)'); ax[1].set_title('depth below the continuum'); ax[1].legend(fontsize=8)
fig.tight_layout(); fig.savefig(RESULTS / 'nb07_dispersion.png', dpi=130, bbox_inches='tight'); print('figure: results/nb07_dispersion.png'); plt.show()
'''))
    # ---- 5.8 edge band
    cells.append(md(r"""
### 5.8 The opposite-sign wall: a gapless edge band and its closed-form slope

With the opposite-sign wall `T16[0]Ψ = −sign(m) Ψ` every transverse momentum carries an edge level, 4-fold,
bound by the wall condition itself.  For small `K` it is the constant-`K` edge state
`Sqrt[2m] e^{−mz}(1, −1)/√2` with `ω = −K`, and the Hellmann–Feynman theorem with the true profile `K(z)`
gives the slope

    ω/K_inf → −∫ 2m e^{−2mz} (1 − e^{−12Hz})^{1/12} dz = −(m/6H) B(m/6H, 13/12)       (B the Euler beta function).

The cell checks it at `K = 1e−4` for `m/H = 0.5, 1, 3`, reads the edge band from the `figures` run, finds
the transverse momentum `K*` at which the edge level reaches the bulk mass (below it, the edge fermions
lie inside the bulk gap: massless fermions on the wall), and the largest surface density
`(4/(6π²)) K*³` they can hold there.  Table `results/nb07_edge_band.csv`, figure `results/nb07_edge_band.png`.
"""))
    cells.append(code(r'''
rows_s = []
for mm in (0.5, 1.0, 3.0):
    lv, _ = wg.find_levels(wg.Block(Kinf=1e-4, m=mm, theta=wg.theta_MIT(-1)))
    slope = min(lv, key=lambda X: abs(X.w + 1e-4)).w / 1e-4
    exact = -(mm / 6.0) * Beta(mm / 6.0, 13.0 / 12.0)
    rows_s.append([mm, slope, exact])
    print(f'm/H = {mm}: omega/K at K = 1e-4: {slope:.9f};  -(m/6H) B(m/6H, 13/12) = {exact:.9f};  |diff| = {abs(slope - exact):.1e}')
    assert abs(slope - exact) < 1e-6
SLOPE1 = rows_s[1][2]
edge = dev_rows('waveguide_edge_m1.csv')
EK = sorted(set(r['K'] for r in edge))
ed = []
for K in EK:
    A = [r['omega'] for r in edge if r['K'] == K and r['irrep'] == '-i']
    e_ = max(w for w in A if w < 0)
    ed.append((K, abs(e_), abs(e_) / K, math.hypot(1.0, K)))
ed = np.array(ed)


def edge_level(K):
    lv, _ = wg.find_levels(wg.Block(Kinf=K, m=1.0, theta=wg.theta_MIT(-1)))
    return abs(max(L.w for L in lv if L.w < 0))


K_STAR = brentq(lambda K: edge_level(K) - 1.0, 0.9, 1.2, xtol=1e-10)
NS_MAX = 4.0 / (6 * PI2) * K_STAR ** 3
print(f'edge band |omega|/K: {ed[0, 2]:.6f} at K = {ed[0, 0]:g} ... {ed[-1, 2]:.6f} at K = {ed[-1, 0]:g}; it reaches the bulk mass m0 = 1 at K* = {K_STAR:.8f}')
print(f'below K* the edge fermions are inside the bulk gap: at most N_s = (4/(6 pi^2)) K*^3 = {NS_MAX:.6f} H^3 of them per unit coordinate 3-volume')
write_table('nb07_edge_band.csv', ['K', 'edge_abs_omega', 'abs_omega_over_K', 'R_continuum'], ed.tolist())
fig, ax = plt.subplots(1, 2, figsize=(12.5, 4.2))
ax[0].semilogx(ed[:, 0], ed[:, 2], 'o-', label='|omega_edge| / K'); ax[0].axhline(abs(SLOPE1), color='tab:red', ls=':', label='(m/6H) B(m/6H, 13/12), K -> 0')
ax[0].set_xlabel('K_inf / H'); ax[0].set_ylabel('|omega| / K'); ax[0].set_title('opposite-sign wall, m = H: edge-band slope'); ax[0].legend(fontsize=8)
sel = ed[:, 0] <= 5
ax[1].plot(ed[sel, 0], ed[sel, 1], 'o-', label='edge level |omega|'); ax[1].plot(ed[sel, 0], ed[sel, 3], 'k:', label='continuum edge R')
ax[1].axhline(1.0, color='tab:red', ls='--', label='bulk mass m0'); ax[1].axvline(K_STAR, color='0.5', ls=':')
ax[1].set_xlabel('K_inf / H'); ax[1].set_ylabel('omega / H'); ax[1].set_title('massless fermions on the wall below K*'); ax[1].legend(fontsize=8)
fig.tight_layout(); fig.savefig(RESULTS / 'nb07_edge_band.png', dpi=130, bbox_inches='tight'); print('figure: results/nb07_edge_band.png'); plt.show()
'''))
    # ---- 5.9 theta
    cells.append(md(r"""
### 5.9 The family of self-adjoint walls `f(0) cos θ + g(0) sin θ = 0`

Every `θ` gives a self-adjoint wall with zero normal current, but only `θ = ∓π/4` (MIT±) is covariant
and has `Ψbar Ψ = 0` at the wall; the others break the wall's `Spin(1,3)`.  The `figures` run computed
the 16-component levels (irrep `−i` = `A_θ(K)`, irrep `+i` = `A_θ(−K)`, each 4-fold) on a grid of `θ` in
`[−π/2, π/2)` that contains `0` and `±π/4`, at `K = 3` and `K = 80` (the cell prints how many values).  The cell draws the `K = 3` levels against `θ`, prints the `K = 80` rows at
`θ = −π/2, −π/4, 0, π/4`, and writes `results/nb07_theta.csv` and `results/nb07_theta.png`: the wall
condition, not the pocket, sets the low end of the spectrum.
"""))
    cells.append(code(r'''
th3, th80 = dev_rows('waveguide_theta_K3.csv'), dev_rows('waveguide_theta_K80.csv')
print(f'{len(set(r["theta"] for r in th3))} values of theta at K = 3, {len(set(r["theta"] for r in th80))} at K = 80')
write_table('nb07_theta.csv', ['K', 'theta', 'omega', 'irrep'], [[r['K'], r['theta'], r['omega'], r['irrep']] for r in th3 + th80])
for thv, lab in ((-math.pi / 2, 'g(0) = 0'), (-math.pi / 4, 'MIT+'), (0.0, 'f(0) = 0'), (math.pi / 4, 'MIT-')):
    a = sorted(r['omega'] for r in th80 if abs(r['theta'] - thv) < 1e-9 and r['irrep'] == '-i')
    b = sorted(r['omega'] for r in th80 if abs(r['theta'] - thv) < 1e-9 and r['irrep'] == '+i')
    low = min([w for w in a + b if w > 0], default=float('nan'))
    print(f'K = 80, theta = {thv / math.pi:+.2f} pi ({lab:8s}): -i {[round(w, 6) for w in a]} | +i {[round(w, 6) for w in b]};  lowest positive {low:.6f}')
lowest_gp = min(r['omega'] for r in th80 if abs(r['theta'] + math.pi / 2) < 1e-9 and r['omega'] > 0)
assert abs(lowest_gp - 1.0) < 1e-9          # the exact flat band omega = m of g(0) = 0
fig, ax = plt.subplots(figsize=(7.8, 4.6))
for irr, col in (('-i', 'tab:blue'), ('+i', 'tab:orange')):
    P_ = np.array([(r['theta'] / math.pi, r['omega']) for r in th3 if r['irrep'] == irr])
    ax.plot(P_[:, 0], P_[:, 1], 'o', color=col, ms=4, label=f'irrep {irr}')
R3 = math.hypot(1.0, 3.0)
ax.axhline(R3, color='k', ls=':'); ax.axhline(-R3, color='k', ls=':', label='continuum edges +-R')
ax.axvline(-0.25, color='0.5', ls='--', label='MIT+ / MIT-'); ax.axvline(0.25, color='0.5', ls='--')
ax.set_xlabel('theta / pi'); ax.set_ylabel('omega / H'); ax.set_title('K = 3, m = H: levels of the self-adjoint wall family'); ax.legend(fontsize=8)
fig.savefig(RESULTS / 'nb07_theta.png', dpi=130, bbox_inches='tight'); print('figure: results/nb07_theta.png'); plt.show()
'''))
    # ---- 5.10 wavefunctions
    cells.append(md(r"""
### 5.10 The wavefunctions of the ground level n = 0 and the first excited level n = 1 at `K = 80`

`waveguide.wavefunction` builds the normalized orbital (`∫ (f² + g²) dz = 1` in `L²(dz)`) from the left and
right Prüfer solutions with the exact exponential tail.  The cell computes n = 0 (irrep `−i`) and n = 1
(irrep `+i`) of the same-sign wall at `K = 80`, prints the norm on a long grid, the wall condition
`f(0) = g(0)`, the scalar density `∫ (f² − g²) dz` and the nodes, and writes `results/nb07_wavefunctions.csv`
and `results/nb07_wavefunctions.png`.
"""))
    cells.append(code(r'''
zs = wg.make_grid(0.0, 4.0, 0.0005)
zl = wg.make_grid(0.0, 60.0, 0.0005)
WF, rows = {}, []
for n, (Ks, pick) in ((0, (80.0, LEV80[0][0])), (1, (-80.0, LEV80[1][0]))):
    blk = wg.Block(Kinf=Ks, m=1.0, theta=wg.theta_MIT(+1))
    lv, _ = wg.find_levels(blk)
    L = min(lv, key=lambda X: abs(X.w - pick))
    f, g, info = wg.wavefunction(blk, L.w, zs)
    fl, gl, _ = wg.wavefunction(blk, L.w, zl)
    norm = simpson(fl * fl + gl * gl, x=zl)
    scal = simpson(fl * fl - gl * gl, x=zl)
    nod = lambda y: int(np.sum(np.diff(np.sign(y[np.abs(y) > 1e-12])) != 0))
    WF[n] = (L.w, f, g)
    print(f'n = {n} (irrep {"-i" if Ks > 0 else "+i"}), omega = {L.w:.10f}: norm = {norm:.12f}, wall f(0) - g(0) = {fl[0] - gl[0]:.1e},'
          f' Int(f^2 - g^2) dz = {scal:.8f}, nodes f: {nod(fl)}, g: {nod(gl)}, decay kappa = {L.kappa:.4f}')
    assert abs(norm - 1) < 1e-6 and abs(fl[0] - gl[0]) < 1e-9
    rows += [[n, L.w, float(z_), float(a_), float(b_)] for z_, a_, b_ in zip(zs[::10], f[::10], g[::10])]
write_table('nb07_wavefunctions.csv', ['n', 'omega', 'z', 'f', 'g'], rows)
fig, ax = plt.subplots(1, 2, figsize=(12.5, 4.2))
for i, n in enumerate((0, 1)):
    w_, f, g = WF[n]
    ax[i].plot(zs, f, label='f'); ax[i].plot(zs, g, label='g'); ax[i].axhline(0, color='k', lw=0.5)
    ax[i].set_xlim(0, 1.0); ax[i].set_xlabel('proper distance z from the wall (1/H)'); ax[i].set_title(f'K = 80, n = {n}: omega = {w_:.6f}'); ax[i].legend(fontsize=8)
fig.tight_layout(); fig.savefig(RESULTS / 'nb07_wavefunctions.png', dpi=130, bbox_inches='tight'); print('figure: results/nb07_wavefunctions.png'); plt.show()
'''))
    # ---- 5.11 the mass term
    cells.append(md(r"""
### 5.11 Kohn–Sham along x0: the author's mass term is free, and its wall levels are exact

For `W = m0 σ` (the author's `V = −(2M/H) s`, `m0 = −2M`) the action is bilinear: the theory is free, the
single-particle levels above are its exact spectrum, and every many-body eigenstate is a Slater
determinant of them; no self-consistency is needed.  The cell lists the positive levels of both irreps
of the same-sign wall at `K = 0, 1, 3, 6, 6.7, 7, 10` (`m0 = H = 1`): none below `K_c(1)`, while the bulk
continuum starts at `m0`.  So the ground state of `N_s` fermions of the free theory has no fermion bound
to a same-sign wall; its wall levels are excited states.  At an opposite-sign wall the edge band lies
below `m0` up to `K*` (5.8), and the free ground state of up to `(4/(6π²)) K*³` fermions per unit
coordinate 3-volume is a Fermi sea of massless fermions bound to the wall.
"""))
    cells.append(code(r'''
rows = []
for K in (0.0, 1.0, 3.0, 6.0, 6.7, 7.0, 10.0):
    Kx = max(K, 1e-9)
    pos = sorted([L.w for L in wg.find_levels(wg.Block(Kinf=Kx, m=M0, theta=wg.theta_MIT(+1)))[0] if L.w > 0]
                 + [L.w for L in wg.find_levels(wg.Block(Kinf=-Kx, m=M0, theta=wg.theta_MIT(+1)))[0] if L.w > 0])
    rows.append([K, math.hypot(M0, K), len(pos), pos[0] if pos else float('nan')])
    print(f'same-sign wall, K = {K:5.2f}: bound positive levels {[round(w, 6) for w in pos]}; continuum from {math.hypot(M0, K):.6f}')
    assert (len(pos) == 0) == (K < THR[1.0]['Kc1_over_H'])
print(f'no same-sign wall level below K_c(1) = {THR[1.0]["Kc1_over_H"]:.8f}: every wall level lies above m0 = {M0} by at least'
      f' sqrt(m0^2 + K_c(1)^2) - m0 = {math.hypot(M0, THR[1.0]["Kc1_over_H"]) - M0:.6f}')
print(f'opposite-sign wall: the edge band lies below m0 for K < K* = {K_STAR:.6f}; free ground state bound to the wall for N_s <= {NS_MAX:.6f}')
write_table('nb07_free_levels.csv', ['K', 'R_continuum', 'n_bound_positive', 'lowest_positive'], rows)
'''))
    # ---- 5.12 opposite
    cells.append(md(r"""
### 5.12 The opposite-sign wall with `W = m0 σ + (λ/2) σ²`: a variationally consistent ground state

`m0 = 1`, `N_s = 0.05` per unit coordinate 3-volume, at the solver's full resolution (`Z = 30/H`,
`h_near = 0.003/H`, 16 Gauss–Legendre nodes, 31 k-points on `[0, 3]`), for `λ = −0.01` (this cell) and
`λ = −10` (the next).  The occupied band is the edge band of irrep `+i`, which starts at `ω = 0, k = 0`
without a threshold.  If `μ < m0`, every state below the Fermi level is a bound wall state, and the
configuration is a genuine ground state of `N_s` fermions.  The Walecka check evaluates
`Ω[m] = Σ_occ ω[m] + ∫ (m − m0)²/(2|λ|) dz/Sin` along `m = m0 + s (m_sc − m0)`, `s = 0.98, 1, 1.02`:
`Ω(1) = E`; a vanishing slope and a positive curvature make the self-consistent state stationary and a
minimum.  `E/N` is compared with a massless gas, `(3/4) μ`.
"""))
    ks_opp = r'''
LAM_O = __LAM__
t0 = time.time()
r = wg.ks_solve(0.05, m0=M0, lam=LAM_O, eps=-1, kgrid=KG_OPP, tol=1e-10, verbose=False)
wc = wg.walecka_check(r, M0, LAM_O, -1, 0.05, KG_OPP)
s_ = ks_summary(r, 0.05)
slope_w = (wc[2][1] - wc[0][1]) / 0.04
curv_w = 0.5 * (wc[0][1] + wc[2][1]) - wc[1][1]
OPP[LAM_O] = dict(res=r, summary=s_, slope=slope_w, curvature=curv_w)
print(f'lam = {LAM_O}: converged = {r.converged} in {r.iterations} iterations; E/A = {r.E_per_A:.12f}; mu = {r.mu:.10f}; E/N = {s_["E_per_N"]:.8f};'
      f' band {r.occupations[0]["band"]}: k in [{s_["k_lo"]:.6f}, {s_["kF"]:.8f}]  ({time.time() - t0:.1f} s)')
print(f'   sigma in [{r.sigma.min():.4e}, {r.sigma.max():.4e}] (negative: f ~ -g for edge states); m in [{r.m.min():.8f}, {r.m.max():.8f}]'
      f' (the attraction RAISES m near the wall); interaction / kinetic energy = {r.E_int / r.sum_omega:.2e}')
print(f'   mu < m0: {r.mu < M0} (every state below mu is a bound wall state);  E/N / ((3/4) mu) = {s_["E_per_N"] / (0.75 * r.mu):.6f}')
print(f'   Walecka: Omega(0.98, 1, 1.02) = {wc[0][1]:.14f}, {wc[1][1]:.14f}, {wc[2][1]:.14f};  slope {slope_w:.2e}, curvature {curv_w:.2e}'
      f' -> stationary and a minimum;  Omega(1) - E/A = {wc[1][1] - r.E_per_A:.1e}')
assert r.converged and r.mu < M0 and abs(slope_w) < 1e-9 and curv_w > 0 and abs(wc[1][1] - r.E_per_A) < 1e-10
'''
    cells.append(code("OPP = {}" + ks_opp.replace("__LAM__", "-0.01")))
    cells.append(md(r"""
The same with `λ = −10`: a thousand times stronger attraction changes the edge-band ground state only
slightly, because the edge fermions have a small scalar density of the opposite sign.  The two profiles
go to `results/nb07_ks_opposite.csv`.
"""))
    cells.append(code(ks_opp.replace("__LAM__", "-10.0") + r'''
write_table('nb07_ks_opposite.csv', ['lam', 'z', 'sigma', 'm', 'n'],
            [[lam_, float(z_), float(s_v), float(m_v), float(n_v)] for lam_, d in OPP.items() for z_, s_v, m_v, n_v in zip(d['res'].z[::5], d['res'].sigma[::5], d['res'].m[::5], d['res'].n[::5])])
'''))
    # ---- 5.13 same-sign ground state
    cells.append(md(r"""
### 5.13 The same-sign wall, `λ = −0.01`, `N_s = 100`: a converged configuration that is not a variational minimum

`m0 = 1`, `λ = −0.01` (attractive; the cell prints the depth of the mass depression it causes), `N_s = 100`,
which fills the bare n = 0 band well above `K_c(1)`.  This notebook runs it at the reduced resolution
printed by the helper cell (`h_near = 0.006/H`, 12 Gauss–Legendre nodes, 21 k-points on `[0, 20]`, `Z = 30/H`);
5.17 compares every number with the solver's full resolution.  The first cell solves the ground state
of the wall-band sector (common Fermi level) and prints the profile; the second is the Walecka check,
and it explains the slope it finds: the band bottom `k_lo` is a continuum threshold below `μ`, so a
deeper well pulls new bound states out of the continuum at the band bottom (energy `R(k_lo)`), and
they replace Fermi-surface states at `μ`, a change `(4/(2π²)) k_lo² (−dk_lo/ds)(R(k_lo) − μ)` per unit `s`.
The same `μ > m0` also puts bulk continuum states below the Fermi level.  The third cell repeats the
ground state with `Z = 45/H` to show the truncation of the mass profile at `Z`.
"""))
    cells.append(code(r'''
t0 = time.time()
GS = wg.ks_solve(100.0, m0=M0, lam=LAM, eps=+1, kgrid=KG_SAME, tol=1e-8, verbose=False, **RED)
GSs = ks_summary(GS, 100.0)
print(f'converged = {GS.converged} in {GS.iterations} iterations ({time.time() - t0:.1f} s): E/A = {GS.E_per_A:.8f} (sum omega {GS.sum_omega:.8f} + interaction {GS.E_int:.8f});'
      f' E/N = {GSs["E_per_N"]:.8f}; mu = {GS.mu:.8f}')
for o in GS.occupations:
    print(f'   {o["band"]}: k in [{o["k_lo"]:.6f}, {o["kF"]:.6f}], N = {o["N"]:.6f}, band bottom omega = {o["w_bottom"]:.6f}')
print(f'   bare threshold K_c(1) = {THR[1.0]["Kc1_over_H"]:.6f} -> self-consistent band bottom k_lo = {GSs["k_lo"]:.6f}: the attractive field binds the band down to lower k')
print(f'   sigma_max = {GSs["sigma_ext"]:.6f} at z = {GSs["z_ext"]:.4f}; m_min = {GSs["m_min"]:.6f}; interaction / kinetic = {GS.E_int / GS.sum_omega:.2e}')
print(f'   mu - m0 = {GS.mu - M0:.4f} > 0: bulk continuum states (omega >= m0) lie below the Fermi level -- not the global ground state')
for z_ in (0.01, 0.05, 0.1, 0.167, 0.25, 0.4, 0.6, 1.0, 2.0, 5.0, 10.0, 30.0):
    i = int(np.argmin(np.abs(GS.z - z_)))
    print(f'      z = {GS.z[i]:7.3f}   sigma = {GS.sigma[i]:10.6f}   m = {GS.m[i]:.8f}   n = {GS.n[i]:10.4f}')
assert GS.converged and GS.mu > M0 and len(GS.occupations) == 1
'''))
    cells.append(md(r"""
The Walecka check of this configuration along `m = m0 + s (m_sc − m0)`, and the threshold term that
accounts for its slope (the same reduced resolution).
"""))
    cells.append(code(r'''
t0 = time.time()
WC = wg.walecka_check(GS, M0, LAM, +1, 100.0, KG_SAME, Z=RED['Z'], h_near=RED['h_near'], n_gl=RED['n_gl'])
for sc, Om_, mu_s, bl in WC:
    print(f'   s = {sc:.2f}: Omega = {Om_:.8f}, mu = {mu_s:.8f}, ' + '; '.join(f'{l}: k_lo = {kl:.6f}, omega_bottom = {wb:.6f}' for l, kl, wb in bl))
W_SLOPE = (WC[2][1] - WC[0][1]) / (WC[2][0] - WC[0][0])
b_lo = [x for x in WC[1][3] if x[0].startswith('n=0')][0]
dklo = ([x for x in WC[2][3] if x[0].startswith('n=0')][0][1] - [x for x in WC[0][3] if x[0].startswith('n=0')][0][1]) / (WC[2][0] - WC[0][0])
W_THR = 4.0 / (2 * PI2) * b_lo[1] ** 2 * (-dklo) * (b_lo[2] - GS.mu)
print(f'dOmega/ds = {W_SLOPE:.6f}: NOT stationary;  threshold term (4/2pi^2) k_lo^2 (-dk_lo/ds) (R(k_lo) - mu) = {W_THR:.6f} (dk_lo/ds = {dklo:.6f}); Omega(1) - E/A = {WC[1][1] - GS.E_per_A:.1e}  ({time.time() - t0:.1f} s)')
assert W_SLOPE < 0 and abs(W_THR / W_SLOPE - 1) < 2e-2 and abs(WC[1][1] - GS.E_per_A) < 1e-5
'''))
    cells.append(md(r"""
The truncation of the mass profile at `Z` (beyond it `m = m0`) is not negligible, because orbitals near the
band threshold decay slowly and leave an inverse-square density tail.  The same ground state with
`Z = 45/H` (same reduced resolution otherwise):
"""))
    cells.append(code(r'''
t0 = time.time()
GS45 = wg.ks_solve(100.0, m0=M0, lam=LAM, eps=+1, kgrid=KG_SAME, tol=1e-8, verbose=False, Z=45.0, h_near=RED['h_near'], n_gl=RED['n_gl'])
d_EA, d_mu = GS45.E_per_A - GS.E_per_A, GS45.mu - GS.mu
print(f'Z = 45: E/A = {GS45.E_per_A:.8f} (Z = 30: {GS.E_per_A:.8f}; difference {d_EA:+.6f}, {d_EA / GS.E_per_A:+.2e} relative); mu = {GS45.mu:.8f} ({d_mu:+.2e});'
      f' k_lo = {GS45.occupations[0]["k_lo"]:.6f}  ({time.time() - t0:.1f} s)')
i = int(np.argmin(np.abs(GS45.z - 10.0))); j = int(np.argmin(np.abs(GS45.z - 20.0)))
print(f'density tail: sigma(20)/sigma(10) = {GS45.sigma[j] / GS45.sigma[i]:.4f} (an inverse-square tail gives 0.25)')
assert GS45.converged and d_EA < 0
'''))
    # ---- 5.14 gaps
    cells.append(md(r"""
### 5.14 The band gap at fixed transverse momentum in the self-consistent potential

The first excited level at a given transverse momentum `k` is the next level of the 16-component problem
in the self-consistent mass profile of 5.13 (interpolated onto a grid with `h_near = 0.001/H`, as the solver does).  The
cell prints the positive levels and the gap `ω_1 − ω_0` at `k = 34, 40, 60, 80`, next to the bare wall's
gap from the dispersion table of 5.7.
"""))
    cells.append(code(r'''
Gsc = wg.KSGrid(Z=30.0, h_near=0.001, theta=wg.theta_MIT(+1))
Gsc.set_mass(PchipInterpolator(GS.z, GS.m)(Gsc.z), M0)
rows, GAPS = [], {}
for k in (34.0, 40.0, 60.0, 80.0):
    allp = sorted([(w, '-i') for (_, j, w, _) in Gsc.levels(np.array([k]), +1)] + [(w, '+i') for (_, j, w, _) in Gsc.levels(np.array([k]), -1)])
    bare = sorted(r['omega'] for r in disp if r['K'] == k)
    gap_sc, gap_bare = allp[1][0] - allp[0][0], bare[1] - bare[0]
    GAPS[k] = gap_sc
    rows.append([k, allp[0][0], allp[1][0], gap_sc, gap_bare])
    print(f'k = {k:5.1f}: self-consistent levels {[(round(w, 6), i) for w, i in allp]}; gap = {gap_sc:.6f} (bare wall {gap_bare:.6f})')
    assert gap_sc > 0
write_table('nb07_band_gap.csv', ['k', 'omega0_sc', 'omega1_sc', 'gap_sc', 'gap_bare'], rows)
'''))
    # ---- 5.15 Delta-SCF
    cells.append(md(r"""
### 5.15 The ΔSCF first excited state: a fraction `x` of the fermions in band n = 1

The first excited state of the same-sign wall-band sector, by ΔSCF: a fraction `x` of `N_s` occupies band
n = 1 (irrep `+i`), the rest band n = 0, each filled from its bottom (the lowest configuration with these
occupations), solved self-consistently from the ground-state profile (reduced resolution, 41 k-points on
`[0, 40]`, tolerance `1e−7`).  `ΔE/A` divided by the number of promoted fermions `x N_s` is the excitation
energy per promoted fermion; `x → 0` is the lowest ΔSCF excitation.  One value of `x` per cell (under a
minute each): 0.01, 0.05, 0.10, 0.20.
"""))
    dscf = r'''
t0 = time.time()
x_ = __X__
r = wg.ks_solve(100.0, m0=M0, lam=LAM, eps=+1, kgrid=KG_DSCF, fractions={0: 1 - x_, 1: x_}, tol=1e-7, m_init=GS.m, verbose=False, **RED)
dE = r.E_per_A - GS.E_per_A
DSCF[x_] = dict(res=r, dE=dE, per=dE / (x_ * 100.0))
print(f'x = {x_}: converged = {r.converged} in {r.iterations} iterations: E/A = {r.E_per_A:.8f}; Delta E/A = {dE:.8f}; per promoted fermion {dE / (x_ * 100.0):.8f}  ({time.time() - t0:.1f} s)')
for o in r.occupations:
    print(f'   {o["band"]}: k in [{o["k_lo"]:.6f}, {o["kF"]:.6f}], N = {o["N"]:.4f}, top omega = {o["w_top"]:.6f}')
assert r.converged and dE > 0
'''
    cells.append(code("DSCF = {}" + dscf.replace("__X__", "0.01") + r'''
top0 = GS.occupations[0]
b1 = [o for o in DSCF[0.01]['res'].occupations if o['band'].startswith('n=1')][0]
print(f'compare: bottom of band n = 1, sqrt(m0^2 + k_lo^2) = {math.hypot(M0, b1["k_lo"]):.6f}, minus the Fermi level mu = {GS.mu:.6f}:'
      f' {math.hypot(M0, b1["k_lo"]) - GS.mu:.4f}; the rest of the excitation energy is the rearrangement of the mean field')
'''))
    for xv in ("0.05", "0.10", "0.20"):
        cells.append(md(f"""
ΔSCF with `x = {xv}` of `N_s` in band n = 1 (the same resolution and starting profile).  With more
fermions promoted the well weakens and the n = 1 shell fills, so the energy per promoted fermion grows.
"""))
        cells.append(code(dscf.replace("__X__", xv)))
    cells.append(md(r"""
The ΔSCF table and the Kohn–Sham profiles: `σ(z)`, `m(z)` and `n(z)` of the same-sign ground state, of the
ΔSCF state with `x = 0.10`, and of the opposite-sign edge-band ground state (`λ = −10`).  Written to
`results/nb07_dscf.csv`, `results/nb07_ks_same.csv` and `results/nb07_ks_profiles.png`.
"""))
    cells.append(code(r'''
xs_ = sorted(DSCF)
pers = [DSCF[x]['per'] for x in xs_]
print('Delta E per promoted fermion: ' + ', '.join(f'x = {x:g}: {p:.6f}' for x, p in zip(xs_, pers)))
assert all(np.diff(pers) > 0)
write_table('nb07_dscf.csv', ['x', 'E_per_A', 'Delta_E_per_A', 'Delta_E_per_promoted'], [[x, DSCF[x]['res'].E_per_A, DSCF[x]['dE'], DSCF[x]['per']] for x in xs_])
write_table('nb07_ks_same.csv', ['state', 'z', 'sigma', 'm', 'n'],
            [[lab, float(z_), float(a_), float(b_), float(c_)] for lab, rr in (('ground state', GS), ('Delta-SCF x=0.10', DSCF[0.10]['res']))
             for z_, a_, b_, c_ in zip(rr.z[::5], rr.sigma[::5], rr.m[::5], rr.n[::5])])
fig, ax = plt.subplots(1, 3, figsize=(17, 4.3))
for lab, rr, ls in (('same-sign ground state', GS, '-'), ('same-sign Delta-SCF, x = 0.10', DSCF[0.10]['res'], '--')):
    sel = rr.z <= 3.0
    ax[0].plot(rr.z[sel], rr.sigma[sel], ls, label=lab); ax[1].plot(rr.z[sel], rr.m[sel], ls, label=lab); ax[2].plot(rr.z[sel], rr.n[sel], ls, label=lab)
ro = OPP[-10.0]['res']
sel = ro.z <= 3.0
ax0b = ax[0].twinx(); ax0b.plot(ro.z[sel], ro.sigma[sel], 'g:', label='opposite-sign edge band, lam = -10 (right axis)'); ax0b.legend(fontsize=7, loc='lower right')
ax[1].plot(ro.z[sel], ro.m[sel], 'g:', label='opposite-sign edge band, lam = -10')
for a_, t_ in zip(ax, ('scalar density sigma(z)', 'Kohn-Sham mass m(z)', 'number density n(z)')):
    a_.set_xlabel('proper distance z from the wall (1/H)'); a_.set_title(t_); a_.legend(fontsize=7)
fig.tight_layout(); fig.savefig(RESULTS / 'nb07_ks_profiles.png', dpi=130, bbox_inches='tight'); print('figure: results/nb07_ks_profiles.png'); plt.show()
'''))
    # ---- 5.16 strong coupling
    cells.append(md(r"""
### 5.16 Strong attraction at the same-sign wall: the self-consistency fails, and why

Can an attractive functional bind a genuinely stable layer (`μ < m0`) at the same-sign wall?  First,
homogeneous matter far from the wall (four spatial dimensions, 8 states per 4-momentum) is self-bound
only for strong attraction: `python waveguide.py dft --scenario bulk` scans `λ`.  Then the solver's
exploratory scenario `λ = −100`, `N_s = 0.03`, started from a well centred at `z = 1.5/H`, is run here at
reduced resolution (`Z = 40/H`, `h_near = 0.01/H`, 12 Gauss–Legendre nodes, 26 k-points on `[0, 2.5]`,
mixing 0.3) for twelve iterations, in two cells of six (the mixing history restarts between them).  The
residual stalls and rises again instead of converging, and the layer centre `z_c` wanders outward, away
from the wall, though not monotonically.  The third cell moves the
last well rigidly to other centres and evaluates the Walecka functional there (an upper bound on the
energy of a layer at that place): it decreases with the distance from the wall, so the wall repels the
layer and there is no wall-bound ground state to converge to.  The solver's full exploratory run
(`--scenario strong`, 60 iterations) is not repeated here.
"""))
    cells.append(code(r'''
out_bulk = run_wg('dft', '--scenario', 'bulk')
BULK = {float(a): (float(b), c) for a, b, c in re.findall(r'lam =\s+(-?[\d.]+): min over kF .*? = ([-+\d.]+) at kF .*?-> (SELF-BOUND|not self-bound)', out_bulk)}
LAM_BOUND = max(l for l, (e, c) in BULK.items() if c == 'SELF-BOUND')
print(f'homogeneous matter is self-bound for lam <= {LAM_BOUND:g} among the values scanned, not for lam >= {min(l for l, (e, c) in BULK.items() if c != "SELF-BOUND"):g}')
assert BULK[-0.01][1] != 'SELF-BOUND' and BULK[-100.0][1] == 'SELF-BOUND'
STRONG = dict(Ns=0.03, lam=-100.0, kgrid=np.linspace(0.0, 2.5, 26), Z=40.0, h_near=0.01, n_gl=12)
t0 = time.time()
S1 = wg.ks_solve(STRONG['Ns'], m0=M0, lam=STRONG['lam'], eps=+1, kgrid=STRONG['kgrid'], Z=STRONG['Z'], h_near=STRONG['h_near'], n_gl=STRONG['n_gl'],
                 m_init=lambda z: M0 - 0.6 * np.exp(-((z - 1.5) / 0.8) ** 2), mix=0.3, maxit=6, tol=1e-8, verbose=False)
print(f'iterations 1-6 ({time.time() - t0:.1f} s): residual max|m_new - m| = {[f"{h_["residual"]:.2e}" for h_ in S1.history]}; layer centre z_c = {[round(h_["zc"], 3) for h_ in S1.history]}; mu = {S1.mu:.6f}')
'''))
    cells.append(md(r"""
Iterations 7–12 of the same strong-coupling run, continued from the last mass profile of the previous
cell (the Anderson mixing history starts afresh):
"""))
    cells.append(code(r'''
t0 = time.time()
S2 = wg.ks_solve(STRONG['Ns'], m0=M0, lam=STRONG['lam'], eps=+1, kgrid=STRONG['kgrid'], Z=STRONG['Z'], h_near=STRONG['h_near'], n_gl=STRONG['n_gl'],
                 m_init=S1.m, mix=0.3, maxit=6, tol=1e-8, verbose=False)
hist = S1.history + S2.history
print(f'iterations 7-12 ({time.time() - t0:.1f} s): residual = {[f"{h_["residual"]:.2e}" for h_ in S2.history]}; z_c = {[round(h_["zc"], 3) for h_ in S2.history]}')
print(f'converged: {S2.converged};  after 12 iterations mu = {S2.mu:.6f} (mu - m0 = {S2.mu - M0:+.4f}: the layer is bound below the bulk continuum),'
      f' residual {hist[-1]["residual"]:.2e}; z_c moved from {hist[0]["zc"]:.3f} to {hist[-1]["zc"]:.3f}')
assert not S1.converged and not S2.converged and S2.mu < M0 and hist[-1]['zc'] > hist[0]['zc']
'''))
    cells.append(md(r"""
The rigid-shift diagnostic: the last well `m(z) − m0` moved to the centres `z_c = 0.6, 1.5, 3, 6` (in `1/H`),
with the Walecka functional and the Fermi level evaluated there (same reduced resolution).  Written, with
the iteration history, to `results/nb07_strong.csv` and drawn in `results/nb07_strong.png`.
"""))
    cells.append(code(r'''
t0 = time.time()
zc0 = hist[-1]['zc']
dm_ = PchipInterpolator(S2.z, S2.m - M0, extrapolate=False)
SHIFT = []
for zc in (0.6, 1.5, 3.0, 6.0):
    Gs = wg.KSGrid(Z=STRONG['Z'], h_near=STRONG['h_near'], theta=wg.theta_MIT(+1))
    mn = M0 + np.nan_to_num(dm_(Gs.z - (zc - zc0)), nan=0.0)
    Om_, mu_ = wg.walecka_energy(Gs, mn, M0, STRONG['lam'], STRONG['Ns'], STRONG['kgrid'], n_gl=STRONG['n_gl'])
    SHIFT.append((zc, Om_, mu_))
    print(f'   well centred at z_c = {zc:4.1f}: Omega = {Om_:.8f}, mu = {mu_:.6f}')
print(f'({time.time() - t0:.1f} s)  Omega decreases monotonically away from the wall: {all(np.diff([s[1] for s in SHIFT]) < 0)} -> the same-sign wall repels the layer')
assert all(np.diff([s[1] for s in SHIFT]) < 0)
write_table('nb07_strong.csv', ['kind', 'index_or_zc', 'residual_or_Omega', 'zc_or_mu'],
            [['iteration', i + 1, h_['residual'], h_['zc']] for i, h_ in enumerate(hist)] + [['rigid shift', zc, Om_, mu_] for zc, Om_, mu_ in SHIFT])
fig, ax = plt.subplots(1, 3, figsize=(16, 4.1))
ax[0].semilogy(range(1, len(hist) + 1), [h_['residual'] for h_ in hist], 'o-'); ax[0].set_xlabel('iteration'); ax[0].set_ylabel('max |m_new - m|'); ax[0].set_title('lam = -100: no convergence')
ax[1].plot(range(1, len(hist) + 1), [h_['zc'] for h_ in hist], 'o-'); ax[1].set_xlabel('iteration'); ax[1].set_ylabel('layer centre z_c (1/H)'); ax[1].set_title('the layer drifts away from the wall')
ax[2].plot([s[0] for s in SHIFT], [s[1] for s in SHIFT], 's-'); ax[2].set_xlabel('centre of the shifted well z_c (1/H)'); ax[2].set_ylabel('Walecka Omega'); ax[2].set_title('the wall repels the layer')
fig.tight_layout(); fig.savefig(RESULTS / 'nb07_strong.png', dpi=130, bbox_inches='tight'); print('figure: results/nb07_strong.png'); plt.show()
'''))
    # ---- 5.17 full resolution
    cells.append(md(r"""
### 5.17 The full-resolution runs of the solver, and the comparison

The background run `python waveguide.py dft` (started by the helper cell) computes the free levels, the
same-sign ground state with its Walecka check and band gaps, the four ΔSCF states, and the two
opposite-sign ground states, all at the solver's full resolution (`Z = 30/H`, `h_near = 0.003/H`, 16
Gauss–Legendre nodes, 41 k-points on `[0, 20]`, 81 on `[0, 40]` for ΔSCF, tolerance `1e−9`).  This cell waits
for it if it is still running (the one cell of the project that may take more than a minute), prints its
log, extracts its numbers into `results/nb07_dft_full.csv`, and compares them with this notebook's runs
in `results/nb07_dft_comparison.csv`.  The opposite-sign runs of 5.12 used the same resolution, so they must
agree to the digits the log prints (relative `1e−8`).  The same-sign runs used the reduced resolution, and
the table shows by how much that matters.  The cell asserts relative differences below `1e−4` for the
energies, the Fermi level, the band edges and the Walecka slope, `1e−5` for the ΔSCF energies, `1e−6` for the
band gaps, and `1e−3` for `sigma_max`, which is the largest value on the grid and so depends on the grid itself.
"""))
    cells.append(code(r'''
while FULL.poll() is None:
    time.sleep(2)
_full_fh.close()
full = FULL_LOG.read_text(encoding='utf-8')
print(full)
print(f'waveguide.py dft finished with exit code {FULL.returncode}, {time.time() - FULL_T0:.0f} s after it was started')
assert FULL.returncode == 0
num = r'([-+]?\d+\.?\d*(?:e[-+]?\d+)?)'
blk_b = full.split('[DFT-b]')[1].split('[DFT-c]')[0]
blocks_c = full.split('[DFT-c]')[1:]
F = {}
mg_ = re.search(r'ground state: converged=(\w+) in (\d+) it\.; E/A = ' + num + '; sum omega = ' + num + '; E_int = ' + num + '; mu = ' + num + '; E/N = ' + num, blk_b)
F['same: E/A'], F['same: sum omega'], F['same: E_int'], F['same: mu'], F['same: E/N'] = (float(mg_.group(i)) for i in range(3, 8))
mo_ = re.search(r'n=0 \(-i, j=0\): k in \[' + num + ', ' + num + r'\], N = ' + num + r' \(1\.0000 of N_s\), bottom ' + num, blk_b)
F['same: k_lo'], F['same: kF'], F['same: band bottom'] = float(mo_.group(1)), float(mo_.group(2)), float(mo_.group(4))
F['same: sigma_max'] = float(re.search(r'sigma_max = ' + num, blk_b).group(1))
F['same: Walecka slope'] = float(re.search(r'd Omega/ds = ' + num, blk_b).group(1))
for k_, g_ in re.findall(r'self-consistent potential, k = +' + num + r': .*?gap n=1 - n=0 = ' + num, blk_b):
    F[f'same: gap at k = {float(k_):g}'] = float(g_)
for x_, e_, d_, p_ in re.findall(r'x = ' + num + r': converged=True; E/A = ' + num + '; Delta E/A = ' + num + '; per promoted particle ' + num, blk_b):
    F[f'Delta-SCF x = {float(x_):g}: per promoted fermion'] = float(p_)
for b_ in blocks_c:
    lam_ = float(re.search(r'lam = ' + num, b_).group(1))
    mc_ = re.search(r'E/A = ' + num + '; mu = ' + num + '; E/N = ' + num, b_)
    F[f'opposite lam = {lam_:g}: E/A'], F[f'opposite lam = {lam_:g}: mu'], F[f'opposite lam = {lam_:g}: E/N'] = (float(mc_.group(i)) for i in (1, 2, 3))
write_table('nb07_dft_full.csv', ['quantity', 'value_full_resolution'], [[k, v] for k, v in F.items()])
mine = {'same: E/A': GS.E_per_A, 'same: sum omega': GS.sum_omega, 'same: E_int': GS.E_int, 'same: mu': GS.mu, 'same: E/N': GSs['E_per_N'],
        'same: k_lo': GSs['k_lo'], 'same: kF': GSs['kF'], 'same: band bottom': GSs['bottom'], 'same: sigma_max': GSs['sigma_ext'], 'same: Walecka slope': W_SLOPE}
for x in xs_:
    mine[f'Delta-SCF x = {x:g}: per promoted fermion'] = DSCF[x]['per']
for lam_, d in OPP.items():
    mine[f'opposite lam = {lam_:g}: E/A'], mine[f'opposite lam = {lam_:g}: mu'], mine[f'opposite lam = {lam_:g}: E/N'] = d['res'].E_per_A, d['res'].mu, d['summary']['E_per_N']
for k in (34.0, 40.0, 60.0, 80.0):
    mine[f'same: gap at k = {k:g}'] = GAPS[k]
cmp_rows = []
print(f"\n{'quantity':46s} {'full resolution':>18s} {'this notebook':>18s} {'resolution here':>16s} {'relative difference':>20s}")
for k, v in F.items():
    w_ = mine[k]
    res_here = 'full' if k.startswith('opposite') else 'reduced'
    rel = abs(w_ - v) / max(abs(v), 1e-300)
    cmp_rows.append([k, v, w_, res_here, rel])
    print(f'{k:46s} {v:18.10g} {w_:18.10g} {res_here:>16s} {rel:20.2e}')
write_table('nb07_dft_comparison.csv', ['quantity', 'full_resolution', 'this_notebook', 'resolution_here', 'relative_difference'], cmp_rows)
REL = {r_[0]: r_[4] for r_ in cmp_rows}
assert all(REL[k] < 1e-8 for k in REL if k.startswith('opposite'))
assert all(REL[k] < 1e-4 for k in ('same: E/A', 'same: sum omega', 'same: E_int', 'same: mu', 'same: E/N', 'same: k_lo', 'same: kF', 'same: band bottom', 'same: Walecka slope'))
assert REL['same: sigma_max'] < 1e-3           # the largest value on the grid: the coarser grid misses the peak by more
assert all(REL[k] < 1e-5 for k in REL if k.startswith('Delta-SCF'))
assert all(REL[k] < 1e-6 for k in REL if k.startswith('same: gap'))
print(f'\nlargest relative difference: opposite-sign (same resolution) {max(REL[k] for k in REL if k.startswith("opposite")):.1e};'
      f' same-sign ground state (reduced) {max(REL[k] for k in REL if k.startswith("same")):.1e}; Delta-SCF (reduced) {max(REL[k] for k in REL if k.startswith("Delta")):.1e}')
'''))
    # ---- 5.18 cosmology link
    cells.append(md(r"""
### 5.18 The cosmological runs follow the homogeneous Kohn–Sham ground state at every epoch

In a homogeneous universe the fable at each epoch is the homogeneous gas of 5.1 with `kF = kF0/A`.  The
stabilized model `fable4d` solves the gap equation at every `N` and integrates the age with CVODE (the
system of 4.1).  The cell runs it for two mass-varying potentials — `power` (`ν = 0.236`,
`m_today = 30 eV`) and the attractive `quadratic` (`gq = −0.5`, `m_today = 30 eV`, massless until late
times) — on 201 rows, and at every row finds **all** roots of the gap equation with this notebook's
independent Python solver, takes the one of lowest energy density, and compares its mass and energy
density with the solver's columns.  The table goes to `results/nb07_cosmology_link.csv`.
"""))
    cells.append(code(r'''
link = []
for name_, args_ in (('power nu=0.236, 30 eV', ['--potential', 'power', '--param', 'nu=0.236', '--param', 'm_today_ev=30']),
                     ('quadratic gq=-0.5, 30 eV', ['--potential', 'quadratic', '--param', 'gq=-0.5', '--param', 'm_today_ev=30'])):
    run = run_fermion('nb07_link', 'fable4d', *args_, '--points', '201', keep=False, quiet=True)
    c, p = run['cols'], run['params']
    pot = Pot('power', m0=p['m0'], lam=p['lam'], nu=p['nu']) if p['potential'] == 'power' else Pot('quadratic', v0=p['v0'], m0=p['m0'], lam=p['lam'])
    dm_max = drho_max = 0.0
    nroots = set()
    for i in range(len(c['a'])):
        gsx = ground_state(pot, p['kf0'] / c['a'][i])
        nroots.add(gsx['n_roots'])
        dm_max = max(dm_max, abs(gsx['m'] - c['m_eff'][i]) / abs(c['m_eff'][-1]))
        drho_max = max(drho_max, abs(gsx['rho'] - c['rho_f'][i]) / abs(c['rho_f'][i]))
    link.append([name_, len(c['a']), sorted(nroots), dm_max, drho_max])
    print(f'{name_}: {len(c["a"])} epochs from a = {c["a"][0]:.0e} to 1; gap roots per epoch {sorted(nroots)};'
          f' max |m_solver - m_ground state|/m_today = {dm_max:.1e}, max |rho_solver - rho_ground state|/rho = {drho_max:.1e}')
    assert dm_max < 1e-10 and drho_max < 1e-10
write_table('nb07_cosmology_link.csv', ['run', 'epochs', 'gap_roots_per_epoch', 'max_rel_mass_difference', 'max_rel_rho_difference'],
            [[r_[0], r_[1], ' '.join(map(str, r_[2])), r_[3], r_[4]] for r_ in link])
'''))
    # ---- 6 results
    cells.append(md(r"""
## 6. This notebook's results

Everything this notebook writes lives under `results/`:

- the homogeneous problem: `results/nb07_homogeneous.csv`, `results/nb07_homogeneous.png` (the no-sea
  minimax, the Walecka functional, the three roots); `results/nb07_excitations.csv`,
  `results/nb07_excitations.png` (particle–hole and pair thresholds);
- the wall problem: `results/nb07_wall_conditions.csv`; `results/nb07_levels_K80.csv` (with the
  16-component multiplicities); `results/nb07_thresholds.csv`, `results/nb07_thresholds.png`;
  `results/nb07_dispersion_same.csv`, `results/nb07_dispersion.png`; `results/nb07_edge_band.csv`,
  `results/nb07_edge_band.png`; `results/nb07_theta.csv`, `results/nb07_theta.png`;
  `results/nb07_wavefunctions.csv`, `results/nb07_wavefunctions.png`;
- Kohn–Sham along x0: `results/nb07_free_levels.csv`; `results/nb07_ks_opposite.csv`;
  `results/nb07_ks_same.csv`; `results/nb07_band_gap.csv`; `results/nb07_dscf.csv`;
  `results/nb07_ks_profiles.png`; `results/nb07_strong.csv`, `results/nb07_strong.png`;
  `results/nb07_dft_full.csv` and `results/nb07_dft_comparison.csv` (the solver's full-resolution
  numbers and the comparison);
- the cosmology: `results/nb07_cosmology_link.csv`.

The cell below reads two of them back with Python's `csv` module alone.
"""))
    cells.append(code(r'''
import csv
with open(RESULTS / 'nb07_levels_K80.csv', newline='') as f:
    rows = list(csv.DictReader(f))
print(f'nb07_levels_K80.csv: {len(rows)} rows, columns {", ".join(rows[0].keys())}')
for r in rows:
    print(f"  n = {r['n']}  omega = {float(r['omega']):.9f}  irrep {r['irrep']}  multiplicity {r['multiplicity_16']}")
with open(RESULTS / 'nb07_dscf.csv', newline='') as f:
    rows = list(csv.DictReader(f))
print(f'nb07_dscf.csv: {len(rows)} rows')
for r in rows:
    print(f"  x = {r['x']}: Delta E per promoted fermion = {float(r['Delta_E_per_promoted']):.6f}")
'''))
    # ---- 7 meaning
    cells.append(md(r"""
## 7. What these states mean for the cosmology

The cell below composes the summary of this notebook from the numbers computed above; every claim in it
is asserted in the cells that computed it.  In words: the homogeneous Kohn–Sham ground state — the gap
root, a maximum of the no-sea functional and a minimum of the Walecka functional — is the state that the
cosmological runs follow at every epoch (5.18).  Its first excited states are gapless particle–hole
pairs, so they do not open any gap in the thermodynamics: the equation of state used by the cosmological
runs is that of the ground state, and a small temperature changes it only at second order, while pair
creation needs at least `wF + |m|`.  The wall states are the discrete ground and first excited levels of the
fable in the primordial gravitational field near the pre-universe's wall: a same-sign wall binds nothing
below a threshold momentum and its levels are excited states of the free theory; an opposite-sign wall
carries a gapless band of massless fermions, which is a genuine, variationally consistent Kohn–Sham
ground state; and with strong attraction a bound layer forms but is pushed away from a same-sign wall.
"""))
    cells.append(code(r'''
so = OPP[-10.0]
summary = f"""
**Summary, computed in this notebook.**

1. Homogeneous gas: the no-sea functional of `W = 2σ` has a maximum at the gap root (`E_n = ρ = {E_star:.6f}`, curvature `{d2T:.4f} = −1/χ`), and
   `E_n/n → {E_curve[0] / n_m:+.4f}` as `σ → −n`; the Walecka functional of `W = σ − 10σ²` is convex with its minimum `{Om(ra[0]):.6f} = ρ` at `m* = {ra[0]:.6f}`;
   the repulsive `W = 0.05σ + 10σ²` has one root below `kF = {kf_c:.4f}` and three at `kF = 1`, where the lowest-ρ root is the ground state.
2. Excitations (`m = 1`, `kF = 1.5`): particle–hole energies reach 0 for every `Q ≤ 2kF`; the pair continuum starts at `2wF = {2 * wF_e:.6f}` for `Q = 0`
   and at its lowest, `wF + |m| = {wF_e + m_e:.6f}`, at `Q = kF`.
3. Wall problem: the derivation log reports {m_sum.group(1)} checks, {m_sum.group(2)} PASS; the solver's validation {N_VALID[0]} of {N_VALID[1]} PASS;
   `T16` built here equals the exported matrices; only `Q = ±1` (MIT±) are covariant, `J`-compatible and charge-conjugation invariant.
4. Same-sign wall, `m = H`: levels appear at `K_c(1) = {THR[1.0]['Kc1_over_H']:.6f}` (irrep −i) and `K_c(2) = {THR[1.0]['Kc2_over_H']:.6f}` (irrep +i);
   at `K = 80` the positive levels are {', '.join(f'{w:.6f}' for w, _, _ in LEV80)}, each 4-fold in the 16-component problem, and agree with
   Mathematica to {dmath:.1e}.
5. Opposite-sign wall: an edge band with slope `(m/6H) B(m/6H, 13/12) = {abs(SLOPE1):.9f}` at small `K`, below the bulk mass up to `K* = {K_STAR:.6f}`.
6. Kohn–Sham, opposite-sign wall (`λ = −10`, `N_s = 0.05`): `μ = {so['res'].mu:.6f} < m0`, `E/A = {so['res'].E_per_A:.9f}`, a stationary minimum of the Walecka
   functional (slope {so['slope']:.1e}, curvature {so['curvature']:.1e}): a variationally consistent ground state of massless wall fermions.
7. Kohn–Sham, same-sign wall (`λ = −0.01`, `N_s = 100`, reduced resolution): converged, `E/A = {GS.E_per_A:.4f}`, `μ = {GS.mu:.4f} > m0` (bulk states below the
   Fermi level), Walecka slope `{W_SLOPE:.3f}` (not stationary), accounted for by the band-threshold term `{W_THR:.3f}`; full resolution differs by
   {REL['same: E/A']:.1e} in `E/A`.  ΔSCF first excited state: `ΔE` per promoted fermion {', '.join(f'{DSCF[x]["per"]:.4f} (x = {x:g})' for x in xs_)};
   band gap at `k = 80`: {GAPS[80.0]:.6f}.
8. Strong attraction (`λ = −100`): homogeneous matter is self-bound, but at the same-sign wall the self-consistency does not converge
   (residual {hist[-1]['residual']:.1e} after {len(hist)} iterations) and the layer wanders outward (`z_c` {hist[0]['zc']:.2f} → {hist[-1]['zc']:.2f}); the Walecka
   functional of the shifted well falls from {SHIFT[0][1]:.6f} (`z_c = 0.6`) to {SHIFT[-1][1]:.6f} (`z_c = 6`): the wall repels the layer.
9. Cosmology: at every epoch of two `fable4d` runs the solver's state is the lowest-energy gap root found independently here (differences ≤ {max(r_[3] for r_ in link):.0e}).
"""
display(Markdown(summary))
print('every statement of the summary is asserted in the cells above')
'''))
    cells += closing_cells(name, 8)
    build_fermion(NOTEBOOKS / f"{name}.ipynb", ["gap", "fable4d", "waveguide"], cells)


NOTEBOOK_BUILDERS = {"01": notebook_01, "02": notebook_02, "03": notebook_03, "04": notebook_04,
                     "05": notebook_05, "06": notebook_06, "07": notebook_07}

if __name__ == "__main__":
    which = sys.argv[1:] or sorted(NOTEBOOK_BUILDERS)
    for k in which:
        NOTEBOOK_BUILDERS[k]()
