# Conventions for the fable-cosmology notebooks

The four notebooks are **generated** by `_build/nbgen.py` (one Python function per notebook,
building `nbformat` v4 cells), then **executed in place** by `nbconvert --execute`, then checked by
`_build/nbcheck.py`. The generator is the source of truth: never hand-edit a `.ipynb`. This mirrors
how the 128 rustSolveIt notebooks are produced (`notebooks/_build/nbgen.py` there).

## Kernel and metadata

- `kernelspec`: `{"display_name": "Python 3 (ipykernel)", "language": "python", "name": "python3"}`.
- `metadata.fable_cosmo.model`: the solver model(s) the notebook runs (a string or a list from
  `scalar-flrw | scalar-cpl | spinor-flrw | scalar-pre | scalar-pre-x0`).
- The last two code cells (name the notebook; save dialog) carry the cell tag `interactive`
  and are skipped by the headless runner; every other code cell must execute.

## Required sections (exact headings; `nbcheck.py` looks for them)

1. `## 1. How to open a notebook like this one, from a terminal` — repeated in full in every
   notebook. Must contain the strings `setup.sh`, `setup.ps1`, `cargo build --release`,
   `jupyter lab`, `Python 3 (ipykernel)`, `Shift+Enter`. Content: what you need (Rust, Python 3,
   git, the platform rustSolveIt engine which `setup.*` clones sparsely); the three commands
   (`bash fable-cosmology/setup.sh` or `powershell -ExecutionPolicy Bypass -File fable-cosmology\setup.ps1`;
   `cd fable-cosmology`; `.venv/bin/jupyter lab notebooks/` or `.venv\Scripts\jupyter.exe lab notebooks\`);
   pick `Python 3 (ipykernel)`; run cells with `Shift+Enter`.
2. `## 2. The words used in this notebook` — glossary, repeated in full: field, Lagrangian,
   energy-momentum tensor, energy density ρ, pressure P, equation of state w = P/ρ, scale factor a,
   redshift z = 1/a − 1, N = ln a, Hubble rate H, Ω_i, CPL (w0, wa), thawing/freezing, phantom,
   dust, cosmological constant, kination, SUNDIALS/CVODE/BDF/Adams, tolerance.
3. `## 3. The field, its Lagrangian and its energy-momentum tensor` — the definitions of
   DESIGN.md §2 (scalar) or §3 (spinor), with the 8-dimensional statement first and then the
   4-dimensional reference model, stated honestly (what is proved in the notebook's Part VI versus
   what is the reference model).
4. `## 4. The equations of motion` with `### 4.1 The first-order system actually handed to SUNDIALS`
   — the ODE system exactly as `models.rs` integrates it, variable by variable, with the units
   (`8πG = 1`, `H0 = 1`, `a0 = 1`, `ρ_crit = 3`), the initial conditions, and the normalisation.
5. `## 5. Running the solver` — locating the binary, the exact command line, the CSV columns.
6. `## 6. This notebook's results` — names every file it writes under `results/` (CSV and PNG),
   and contains a plain-Python read-back cell using `import csv` and no other library.
7. Further sections are free (`## 7. …`), but every code cell has ≥ 80 characters of explanatory
   markdown immediately before it.
8. The final two cells: `## N. Name this notebook and save it` with a code cell containing the
   string `Name for this notebook` (an `input()` prompt), and a code cell that opens
   `tkinter.filedialog.asksaveasfilename` with the text `Falling back to a typed folder path` in
   its fallback branch. Both tagged `interactive`.

## Code conventions

- Locate the solver binary relative to the notebook:
  `ROOT = Path.cwd()` if `(Path.cwd()/'rust').exists()` else `Path.cwd().parent`;
  `BIN = ROOT/'rust'/'fable_cosmo'/'target'/'release'/('fable_cosmo.exe' if os.name == 'nt' else 'fable_cosmo')`;
  if it does not exist, print the one-line instruction to run `setup.sh`/`setup.ps1` and stop.
- Run it with `subprocess.run([str(BIN), model, '--potential', ..., '--out', str(csv_path)], check=True, capture_output=True, text=True)`
  and print its stderr (the `# stats:` line) so the reader sees the step counts.
- Read CSVs with `numpy.genfromtxt(path, delimiter=',', names=True)`.
- Plot with matplotlib; `fig.savefig(RESULTS/'<name>.png', dpi=130, bbox_inches='tight')`; show inline.
- Cross-check every model with `scipy.integrate.solve_ivp(..., method='DOP853', rtol=1e-11, atol=1e-14, t_eval=N_from_csv)`
  and print `max |w_rust − w_scipy|`; assert it is below `1e-6` (the notebook must FAIL loudly if not).
- CPL fit: least squares of `w(a)` to `w0 + wa (1 − a)` over `0.3 ≤ a ≤ 1` (`numpy.polyfit` on `(1 − a)`),
  reported next to Unite's `(−0.861, −0.60)` and `−0.764`. Write the fit table to
  `results/<notebook>_cpl_fits.csv`.
- Random numbers: none. Every number in the notebook is reproducible.
- Result file names: `results/nb01_<potential>.csv`, `results/nb01_w_of_a.png`, … (prefix by notebook number).
- No cell may take more than 60 s on the development machine.
