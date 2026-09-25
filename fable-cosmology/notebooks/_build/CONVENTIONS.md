# Conventions for the fable-cosmology notebooks

The notebooks are **generated** by `_build/nbgen.py` (one Python function per notebook, building
`nbformat` v4 cells), then **executed in place** by `nbconvert --execute`, then checked by
`_build/nbcheck.py`. The generator is the source of truth: never hand-edit a `.ipynb`. This mirrors
how the 128 rustSolveIt notebooks are produced (`notebooks/_build/nbgen.py` there).

    .venv/Scripts/python.exe notebooks/_build/nbgen.py            # every notebook (unexecuted)
    .venv/Scripts/python.exe notebooks/_build/nbgen.py 05 06      # only these

There are two families, one per solver:

| notebooks | solver (crate) | binary | metadata key | models |
|---|---|---|---|---|
| 01–04 | `rust/fable_cosmo` (the classical fields of Part VI) | `rust/fable_cosmo/target/release/fable_cosmo[.exe]` | `metadata.fable_cosmo.model` | `scalar-flrw`, `scalar-cpl`, `spinor-flrw`, `scalar-pre`, `scalar-pre-x0` |
| 05–06 | `rust/fable_fermion` (the quantized fermion fable, Kohn–Sham fluid, 8D Bianchi-I) | `rust/fable_fermion/target/release/fable_fermion[.exe]` | `metadata.fable_fermion.model` | `fable4d`, `fable8d`, `gap` (the gap-equation command) |
| 07 | `rust/fable_fermion` (the homogeneous gap equation and `fable4d`) and the wall-state solver `fermion/waveguide.py` (a Python module and CLI: the wall levels along x0 and the Kohn–Sham runs there) | `fable_fermion[.exe]` as above; `python fermion/waveguide.py <command>` (numpy, scipy) | `metadata.fable_fermion.model` | `gap`, `fable4d`, `waveguide` |

A notebook records exactly one solver key. The model is a string or a list of the models it runs.
The model `waveguide` is a second program, not a mode of the crate: a notebook that names it must also
name `fermion/waveguide.py` (checked as part of R1).

## Kernel and metadata

- `kernelspec`: `{"display_name": "Python 3 (ipykernel)", "language": "python", "name": "python3"}`.
- `metadata.fable_cosmo.model` (notebooks 01–04) or `metadata.fable_fermion.model` (05–07), as in the
  table above.
- The last two code cells (name the notebook; save dialog) carry the cell tag `interactive`
  and detect a headless run (nbconvert, `FABLE_HEADLESS`), printing a notice instead of prompting;
  every other code cell must execute without error.

## Required sections (exact headings; `nbcheck.py` looks for them)

1. `## 1. How to open a notebook like this one, from a terminal` — repeated in full in every
   notebook. Must contain the strings `setup.sh`, `setup.ps1`, `cargo build --release`,
   `jupyter lab`, `Python 3 (ipykernel)`, `Shift+Enter`, and the notebook's own crate
   (`rust/fable_cosmo` or `rust/fable_fermion`). Content: what you need (Rust, Python 3,
   git, the platform rustSolveIt engine which `setup.*` clones sparsely); the three commands
   (`bash fable-cosmology/setup.sh` or `powershell -ExecutionPolicy Bypass -File fable-cosmology\setup.ps1`;
   `cd fable-cosmology`; `.venv/bin/jupyter lab notebooks/` or `.venv\Scripts\jupyter.exe lab notebooks\`);
   pick `Python 3 (ipykernel)`; run cells with `Shift+Enter`; how to rebuild the solver alone.
   The fermion notebooks use `SECTION_1_FERMION` (both solvers are built by the setup).
2. `## 2. The words used in this notebook` — glossary, repeated in full. Every notebook explains:
   field, Lagrangian, energy-momentum tensor, energy density ρ, pressure P, equation of state
   w = P/ρ, scale factor a, redshift z = 1/a − 1, N = ln a, Hubble rate H, Ω_i, CPL (w0, wa),
   thawing/freezing, phantom, dust, cosmological constant, kination, SUNDIALS/CVODE/BDF/Adams,
   tolerance. The fermion notebooks (`SECTION_2_FERMION`) also explain: complex 16-spinor,
   Grassmann numbers, Dirac conjugate, anticommutator, Krein space, fundamental symmetry J, Fock
   space, Dirac sea, Kohn–Sham, gap equation, Fermi momentum, degenerate gas, ΔN_eff, stabilizing
   stress, null energy condition, Bianchi-I, hidden sheet, Newton constant variation. Notebook 07
   (model `waveguide`) also explains: Hohenberg–Kohn theorem, Kohn–Sham reference system,
   exchange–correlation energy, local-density approximation, self-consistent field, ΔSCF, Walecka
   functional, minimax, particle–hole excitation, pair continuum, wall, proper distance, transverse
   momentum, self-adjoint extension, MIT condition, irrep, Prüfer angle, threshold, edge state, band,
   surface density, Fermi level. `nbcheck.py` checks these lists (any listed spelling,
   case-insensitive) in the section-2 cell.
3. `## 3. The field, its Lagrangian and its energy-momentum tensor` — for 01–04 the definitions of
   DESIGN.md §2 (scalar) or §3 (spinor); for 05–07 the complex 16-spinor, its symmetrized
   Lagrangian, its canonical quantization and its energy–momentum tensor operator, and the
   Kohn–Sham fluid (07: density functional theory with the densities `n` and `σ`, and its form along
   the hidden coordinate); always with the 8-dimensional statement first and a statement of what is proved
   in the Mathematica notebook (Parts VI–VIII) versus what the notebook computes.
4. `## 4. The equations of motion` with `### 4.1 The first-order system actually handed to SUNDIALS`
   — the ODE system exactly as the solver's `models.rs` integrates it, variable by variable, with the
   units, the initial conditions, and the normalisation. For 05–06: the field equations, the gap
   equation, the 8D Bianchi-I Einstein equations (constraint, evolution, conservation, the
   hidden-sheet driver F), the stabilized model `fable4d` and the unstabilized `fable8d`, and the
   scaled variables `h_i = H_i A²`, `τ = t/A²` that CVODE integrates. For 07: the homogeneous gap
   equation, the wall problem (the 2×2 block equations, the wall conditions) and the Kohn–Sham
   equations along x0; §4.1 states that only `fable4d`'s `dτ/dN` is handed to SUNDIALS there and gives
   the Prüfer system and the integrators (DOP853, Magnus) that `waveguide.py` uses instead.
5. `## 5. Running the solver` — locating the binary, the exact command line, the CSV columns, the
   stderr lines, the exit codes.
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
  `BIN = ROOT/'rust'/'fable_cosmo'/'target'/'release'/('fable_cosmo.exe' if os.name == 'nt' else 'fable_cosmo')`
  (or `…/'fable_fermion'/…/'fable_fermion[.exe]'`);
  if it does not exist, print the one-line instruction to run `setup.sh`/`setup.ps1` and stop.
- Run it with `subprocess.run([str(BIN), model, ..., '--out', str(csv_path)], capture_output=True, text=True)`
  and print its stderr (the `# stats:` line; for `fable_fermion` the whole log, or only the stats line
  with `quiet=True`) so the reader sees the step counts. Runs that are expected to fail are run with
  `expect_failure=True`: the exit code and the one-line reason are printed and asserted.
- Read `fable_cosmo` CSVs with `numpy.genfromtxt(path, delimiter=',', names=True)`. A `fable_fermion`
  CSV starts with `#` comment lines (the version, the machine-readable `# params:` line, the column
  definitions), so it is read with `read_fermion_csv` (in `FERMION_SETUP_CODE`), which returns the
  comments, the parameters and the columns; `genfromtxt(..., names=True)` would take the first comment
  line for the header.
- The unit system of `fable_fermion` is read from `fable_fermion --constants`, never hard-coded, and
  recomputed independently in Python from the CODATA constants (they must agree to 1e−9).
- Plot with matplotlib; `fig.savefig(RESULTS/'<name>.png', dpi=130, bbox_inches='tight')`; show inline.
- Cross-check every model with an independent implementation and assert the largest difference is
  below `1e−6` (the notebook must FAIL loudly if not):
  - 01–04: `scipy.integrate.solve_ivp(..., method='DOP853', rtol=1e-11, atol=1e-14, t_eval=N_from_csv)`
    and `max |w_rust − w_scipy|`;
  - 05: the Fermi-sea closed forms and stable forms against adaptive quadrature and against the
    solver's `gap` command; the Python gap solver against the solver's roots;
  - 06: `fermion/crosscheck.py` imported (quadrature for every Fermi-sea integral, `brentq` for every
    gap root, DOP853 for `fable8d`), comparing `w_f`, `H_A`, `B`, `G`, `ρ_f`, `P_obs`, `m_eff`, `t(A=1)`,
    the Friedmann/constraint consistency and the covariant conservation of the fluid; and, where the
    Mathematica reference exists (`reference/mathematica_fable4d_*.csv`), a three-way comparison;
  - 07: the homogeneous roots against `fable_fermion gap`; the wall levels against the solver's own
    validation (`waveguide.py validate`, 64 checks), against the Mathematica values listed in
    `fermion/waveguide_REPORT.txt` and against the 16-component problem built with the notebook's own
    `T16`; the `fable4d` rows against the Python gap solver.  Its reduced-resolution Kohn–Sham runs are
    also compared with the solver's full-resolution run; that is a resolution comparison, and the
    notebook states and asserts its own tolerances for it.
- CPL fit: least squares of `w(a)` to `w0 + wa (1 − a)` over `0.3 ≤ a ≤ 1` (`numpy.polyfit` on `(1 − a)`),
  reported next to Unite's `(−0.861, −0.60)` and `−0.764`. Write the fit table to
  `results/<notebook>_cpl_fits.csv`. For an observer-inferred dark energy whose density changes sign
  inside the range (a pole of `w`), the fit is restricted to `[max(0.3, 1.05 a_pole), 1]` and the pole
  is reported.
- Every number stated in a notebook's markdown is computed in that notebook: prose states only what the
  code asserts, and the results (the "Answers" of 06, the summaries of 05 and 07) are composed from the computed
  values and displayed as Markdown output.
- Random numbers: none. Every number in the notebook is reproducible.
- Result file names: `results/nb01_<potential>.csv`, `results/nb01_w_of_a.png`, … (prefix by notebook
  number: `nb01_` … `nb07_`). The wall-state solver's own tables go to `fermion/dev/` (not in the
  repository); notebook 07 copies what it uses into `results/nb07_*`. Its one input file, the
  notebook's matrices `fermion/waveguide_T16.json` (written by `fermion/waveguide_derivation.wls`),
  is committed, so notebook 07 needs no Mathematica.
- No cell may take more than 60 s on the development machine, with one exception: notebook 07 starts
  the solver's full-resolution Kohn–Sham runs (`python fermion/waveguide.py dft`, about 9–10 minutes)
  in the background in its helper cell, and the cell of its section 5.17 waits for them to finish.
  That wait is the only cell allowed to exceed 60 s; the notebook as a whole stays under 20 minutes.
