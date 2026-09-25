# fable-cosmology: the numerical cosmology of fableScalar and fable

This folder holds everything needed to set up, run, check and reproduce the numerical side of
the work on two fields on the 4+4 pre-universe of Patrick L. Nash:

- **fableScalar** is a real scalar field `φ` with a self-interaction potential `V(φ)`, inspired by
  quintessence. Its equation of state is called `wScalar`.
- **fable** is a 16-component spinor field `Ψ` with a self-interaction potential `V(s)` of its
  scalar bilinear `s`. Classically (Part VI of the Mathematica notebook) it is a real commuting
  field with `s = Ψᵀ σ16 Ψ`; its equation of state is called `w`. Quantized, it is the **fermion
  fable**: a complex 16-component anticommuting spinor with `s = Ψbar Ψ`, whose ground state is a
  degenerate Fermi gas (section 14).

The work produces two solvers, written in Rust on the pure-Rust SUNDIALS 7.8.0 CVODE of the
author's rustSolveIt repositories: `fable_cosmo` for the classical fields (sections 5–7), and
`fable_fermion` for the quantized fermion fable as the source of the 8-dimensional gravitational
field (section 14). Seven Jupyter notebooks drive the solvers, plot the results and check them:
01–04 the classical fields, 05–07 the fermion fable (sections 15 and 16; notebook 07 also runs the
wall-state solver `fermion/waveguide.py`). A paper,
`latex/fable_cosmology.pdf`, states the physics and the results of the classical fields. There
are also two scripts that set everything up and reproduce everything.

This page is complete on its own. It assumes you have never used Rust, Jupyter or LaTeX. Follow
sections 2 to 4 in order and you will have every result on your own machine. Sections 5 to 16
explain each piece in detail.

**Contents.** 1 What is here · 2 What you need · 3 Setup, once · 4 Reproduce everything with one
command · 5 The physics the solver integrates · 6 The solver `fable_cosmo` · 7 The CSV files ·
8 The notebooks · 9 The tests and checks · 10 The paper · 11 The Mathematica reference (optional)
· 12 The numbers you should get · 13 Troubleshooting · 14 The fermion-fable solver `fable_fermion`
· 15 The fermion-fable notebooks 05 and 06 · 16 The wall states and notebook 07

---

## 1. What is here

| path (inside `fable-cosmology/`) | what it is |
|---|---|
| `setup.sh`, `setup.ps1` | one-time setup: Python virtual environment, a sparse clone of the rustSolveIt engine for your platform, the release builds of both solvers, and a smoke test of each |
| `run_all.sh`, `run_all.ps1` | reproduce everything: the tests of both solvers, every notebook executed, the notebook checker, the paper |
| `requirements.txt` | the Python packages: numpy, scipy, matplotlib, jupyter, nbconvert, nbclient, ipykernel |
| `rust/fable_cosmo/` | the solver crate: `Cargo.toml`, `.cargo/config.toml` (the FMA pin), `src/main.rs` (command line, output), `src/models.rs` (the equations), `src/potentials.rs` (the potentials), `src/cvode_driver.rs` (the CVODE driver), with 7 unit tests |
| `rust/vendor/rustSolveIt/` | **made by the setup, not committed**: the sparse clone of the rustSolveIt engine (`sundials_rs` only) |
| `rust/fable_cosmo/target/` | **made by the build, not committed**: cargo's build directory; the solver binary is `target/release/fable_cosmo` (`fable_cosmo.exe` on Windows) |
| `.venv/` | **made by the setup, not committed**: the Python virtual environment |
| `notebooks/01_fableScalar_quintessence.ipynb` | Models A and A′: fableScalar in the standard 4-dimensional reference cosmology and on the Unite CPL background |
| `notebooks/02_fable_spinor.ipynb` | Model B: fable in the reference cosmology, including dust and the crossing of `w = −1` |
| `notebooks/03_pre-universe_dynamics.ipynb` | Models C and D: fableScalar on the 8-dimensional pre-universe itself (Model E stated) |
| `notebooks/04_dark_matter_dark_energy.ipynb` | the synthesis: the best cases, the figures, and the answers about dark matter and dark energy |
| `notebooks/05_fermion_fable_quantum_eos.ipynb` | the quantized fermion fable as a fluid: why it is a complex 16-spinor, its quantization, the Kohn–Sham equation of state, the classical limit, the gap equation, the pre-universe cooling, the Dirac-sea energy (section 15) |
| `notebooks/06_fable_primordial_gravity_8d.ipynb` | the coupled (fermion fable, 8-dimensional gravitational field) system from before nucleosynthesis to today, and the answers about time-varying dark-energy and dark-matter `w` (section 15) |
| `notebooks/07_fable_dft_states.ipynb` | the ground and first excited states of the fermion fable, with ideas from density functional theory: the homogeneous Kohn–Sham ground state and its excitations, then the wall states along the hidden coordinate `x0` and the Kohn–Sham states there (section 16) |
| `notebooks/_build/nbgen.py` | the generator of the seven notebooks (the notebooks are generated, never edited by hand) |
| `notebooks/_build/nbcheck.py` | the checker of the eight notebook requirements |
| `notebooks/_build/CONVENTIONS.md` | the conventions the generator encodes (their content is in sections 8 and 15 of this page) |
| `results/` | every CSV and PNG the notebooks write, committed as the evidence: `nb01_`…`nb04_` 43 CSV files and 16 PNG figures; `nb05_` 11 CSV files and 7 PNG figures; `nb06_` 37 CSV files and 8 PNG figures; `nb07_` 18 CSV files and 9 PNG figures |
| `rust/fable_fermion/` | the fermion-fable solver crate (section 14): `src/constants.rs` (unit system), `src/kohn_sham.rs` (Fermi sea, gap, mean field), `src/potentials.rs`, `src/models.rs` (the 8D equations), `src/run.rs` (normalization, output), `src/cvode_driver.rs`, `src/numerics.rs`, `src/main.rs` (command line), `tests/cosmology.rs`; 34 tests |
| `rust/fable_fermion/target/` | **made by the build, not committed**: the binary is `target/release/fable_fermion` (`fable_fermion.exe` on Windows) |
| `fermion/crosscheck.py` | the independent scipy implementation of the fermion-fable models, compared with the Rust CSVs (section 14) |
| `fermion/report.py` | the development report of the solver: every development run and its key numbers, written to `fermion/dev/` (**not committed**) |
| `fermion/waveguide.py` | the wall-state solver (section 16): a Python module and command line for the levels of the fermion fable along `x0`, their validation, and the Kohn–Sham runs there; its tables go to `fermion/dev/` (**not committed**) |
| `fermion/waveguide_derivation.wls`, `fermion/waveguide_derivation.log` | the Mathematica derivation of the wall problem from the notebook's own objects, and its log (94 checks); it also writes `fermion/waveguide_T16.json` |
| `fermion/waveguide_T16.json` | the notebook's matrices `T16[0..8]`, `σ16` and the block basis `U`, exported by `waveguide_derivation.wls` (29 KB); `waveguide.py validate`, `waveguide_check.wls` and notebook 07 read it |
| `fermion/waveguide_check.wls`, `fermion/waveguide_REPORT.txt` | the independent Mathematica cross-check of the wall levels, and the solver's report |
| `reference/make_reference.wls` | the Mathematica `NDSolve` reference integrations of the classical fields (optional, section 11) |
| `reference/mathematica_scalar_exp.csv`, `reference/mathematica_spinor_expdamp.csv` | their output, committed |
| `reference/make_reference_fermion.wls` | the Mathematica reference runs of the fermion fable in `fable4d` (Part VIII of the notebook; section 15) |
| `reference/mathematica_fable4d_mass30eV.csv`, `reference/mathematica_fable4d_power.csv` | their output |
| `latex/fable_cosmology.tex` | the paper's source |
| `latex/fable_cosmology.pdf` | the compiled paper (24 pages) |
| `latex/figures/` | the 16 PNG figures of the paper, copies of the ones in `results/` |
| `DESIGN.md` | the design specification (revision 2) the work was built to; everything a student needs from it is on this page |

The Mathematica side of the work lives outside this folder. Part VI of the notebook
`claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb` (Sections 23–25) proves the symbolic
results that the numerics of the classical fields rely on. Its manifest is
`claude-fable/cells_part6.wl`. Part VII (Sections 26–29, manifest `claude-fable/cells_part7.wl`)
does the same for the fermion fable: the complex 16-spinor, its Lagrangian and field equations,
its canonical quantization and its energy–momentum tensor operator. Part VIII treats the fermion
fable as the source of the primordial gravitational field and solves the two reference cases of
section 15.

## 2. What you need

You need an internet connection **once**, for the setup. It downloads the Python packages and
makes a sparse clone of one rustSolveIt repository from GitHub. The three repositories are
public:

| platform | the engine repository the setup clones |
|---|---|
| Windows 11 (x86-64) | `https://github.com/once-ere/rustSolveIt_Win11_SUNDIALS_7_8_0.git` |
| macOS (the setup uses the Apple-silicon edition on every Mac) | `https://github.com/once-ere/rustSolveIt_macos-silicon_SUNDIALS_7_8_0.git` |
| Linux (x86-64) | `https://github.com/once-ere/rustSolveIt_linux_SUNDIALS_7_8_0.git` |

Install the following. Check each one with the command in the last column; it must print a
version.

### Windows 11

| tool | how to get it | check |
|---|---|---|
| Git for Windows (includes **Git Bash**) | https://git-scm.com/download/win | `git --version` |
| Rust (with its C++ build tools) | run `rustup-init.exe` from https://rustup.rs. It uses the MSVC toolchain, which needs the "Desktop development with C++" workload of the Visual Studio Build Tools; rustup offers to install it | `cargo --version` |
| Python 3.10 or newer | https://www.python.org/downloads/ ; tick **"Add python.exe to PATH"** in the installer | `python --version` |
| MiKTeX (for the paper only) | https://miktex.org/download ; allow it to install missing packages on the fly | `pdflatex --version` and `latexmk -v` |
| Perl (for `latexmk` only) | Git Bash already contains Perl. In PowerShell, either install Strawberry Perl (https://strawberryperl.com) or, for the session, run `$env:Path += ";C:\Program Files\Git\usr\bin"` | `perl -v` |

On Windows you can use either shell. In **Git Bash** you run the `.sh` scripts. In
**PowerShell** you run the `.ps1` scripts. Every command below is given for both.

### macOS (Apple silicon)

| tool | how to get it | check |
|---|---|---|
| Xcode Command Line Tools (compiler, git) | `xcode-select --install` | `git --version` |
| Rust | `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \| sh`, then open a new terminal | `cargo --version` |
| Python 3.10 or newer | https://www.python.org/downloads/ or `brew install python` | `python3 --version` |
| a TeX distribution with `latexmk` (for the paper only) | MacTeX from https://tug.org/mactex/ (it includes `latexmk` and Perl) | `latexmk -v` |

### Linux (x86-64)

| tool | how to get it (Debian / Ubuntu shown) | check |
|---|---|---|
| compiler and git | `sudo apt install build-essential git` | `git --version` |
| Rust | `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \| sh`, then open a new terminal | `cargo --version` |
| Python 3.10 or newer, with venv | `sudo apt install python3 python3-venv` | `python3 --version` |
| TeX Live with `latexmk` (for the paper only) | `sudo apt install latexmk lmodern texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended` | `latexmk -v` |

**On macOS and Linux.** `setup.sh` creates the virtual environment with `python3` when that
command works, and with `python` otherwise. If neither works for you, create the environment
yourself first. The setup then finds it and skips that step:

```bash
cd "$(git rev-parse --show-toplevel)"
python3 -m venv fable-cosmology/.venv
```

**Optional.** Wolfram Mathematica (developed with 15.0.1) and its `wolframscript`. You only need
it to regenerate the reference CSVs, to re-run Parts VI–VIII of the notebook (sections 11 and
15), or to re-run the wall-problem derivation and its cross-check (section 16.1; the derivation's
log and its export `fermion/waveguide_T16.json` are committed). You do not need it for anything else.

**The versions of the re-run of 2026-09-24**, which reproduced the committed results byte for
byte (Windows 11):
cargo and rustc 1.91.1; Python 3.14.5; numpy 2.5.3, scipy 1.18.1, matplotlib 3.11.2, nbconvert
7.17.1, nbclient 0.11.0, nbformat 5.11.1, ipykernel 7.3.0, jupyterlab 4.6.3; MiKTeX 26.5 with
pdfTeX 4.27 and latexmk 4.88; Wolfram Language 15.0.1; the engine at commit `a8fdff4` of
`rustSolveIt_Win11_SUNDIALS_7_8_0`.

## 3. Setup, once

Get the repository, if you do not have it yet:

```bash
git clone <the URL of this repository>
cd <the folder it made>
```

Every command on this page starts from the repository root. If you are somewhere inside the
repository, `cd "$(git rev-parse --show-toplevel)"` takes you there.

Then run the setup. **Git Bash, macOS or Linux:**

```bash
bash fable-cosmology/setup.sh
```

**Windows PowerShell:**

```powershell
powershell -ExecutionPolicy Bypass -File fable-cosmology\setup.ps1
```

The script works from any directory and is idempotent: running it again changes nothing that
is already in place. It does three things (the third for each of the two solvers).

1. **Python.** It creates `fable-cosmology/.venv` (unless it exists) and installs
   `requirements.txt` into it with pip. Then it imports the packages and prints
   `python ok: numpy … scipy … matplotlib …`.
2. **The engine.** It picks the rustSolveIt repository for your platform (table in section 2)
   and makes a sparse clone of it into `fable-cosmology/rust/vendor/rustSolveIt`. The clone uses
   `git clone --depth 1 --filter=blob:none --sparse`, then
   `git sparse-checkout set sundials_rs`. Only the vendored pure-Rust SUNDIALS 7.8.0 is fetched,
   in a few seconds. The script prints `== engine: <url> @ <commit>`.
3. **The solvers.** It runs `cargo build --release` in `fable-cosmology/rust/fable_cosmo` and
   then in `fable-cosmology/rust/fable_fermion`. The first build compiles the engine's two crates
   and the solver; on the development machine that took 5 s for `fable_cosmo`, and the whole
   setup, including pip and the clone, took 80 s. After each build it runs the binary with
   `--version`, which must print

       fable_cosmo 0.1.0, sundials_rs 7.8.0 (pure Rust), CVODE BDF
       fable_fermion 0.1.0, sundials_rs 7.8.0 (pure Rust), CVODE BDF

   and finally `== setup complete`. `setup.ps1` stops with an error if either build fails.

Both solver crates use the engine the same way rustSolveIt's own `planet_Mercury/mercury_rs`
does. Each has path dependencies on `../vendor/rustSolveIt/sundials_rs/crates/sundials_core` and
`…/cvode_rs`. Each also pins `-C target-feature=+fma` in its own `.cargo/config.toml` for x86-64,
because the engine's deterministic math library requires it. Cargo reads that file from the
directory it is invoked in, so **build each solver from inside its own folder**
(`rust/fable_cosmo`, `rust/fable_fermion`), as the scripts do.

If you prefer to do the three steps by hand (Git Bash, macOS, Linux):

```bash
cd "$(git rev-parse --show-toplevel)/fable-cosmology"
python3 -m venv .venv                                  # or: python -m venv .venv
.venv/bin/python -m pip install -r requirements.txt    # Windows Git Bash: .venv/Scripts/python.exe
mkdir -p rust/vendor
git clone --depth 1 --filter=blob:none --sparse https://github.com/once-ere/rustSolveIt_linux_SUNDIALS_7_8_0.git rust/vendor/rustSolveIt
( cd rust/vendor/rustSolveIt && git sparse-checkout set sundials_rs )
( cd rust/fable_cosmo && cargo build --release )
rust/fable_cosmo/target/release/fable_cosmo --version
( cd rust/fable_fermion && cargo build --release )
rust/fable_fermion/target/release/fable_fermion --version
```

Replace `linux` in the URL with `Win11` or `macos-silicon` for your platform.

## 4. Reproduce everything with one command

After the setup, **Git Bash, macOS or Linux:**

```bash
bash fable-cosmology/run_all.sh
```

**Windows PowerShell** (make Perl visible first; see section 2):

```powershell
powershell -ExecutionPolicy Bypass -File fable-cosmology\run_all.ps1
```

The script works from any directory. It does four things, in this order.

1. `cargo test --release` in `rust/fable_cosmo` (the 7 unit tests of section 9) and then in
   `rust/fable_fermion` (its 23 unit tests and 11 end-to-end tests, section 14). `run_all.sh` shows
   only the last three lines of the first and the `running …`/`test result:` lines of the second;
   `run_all.ps1` shows all of the output.
2. It executes every notebook, in the order 01, 02, 03, 04, 05, 06, 07, headlessly and **in place**:
   `python -m nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=1800
   --ExecutePreprocessor.kernel_name=python3 notebooks/0N_….ipynb`. Every CSV and PNG under
   `results/` is rewritten, and the outputs are written back into the `.ipynb` files.
3. `python notebooks/_build/nbcheck.py`: the eight-requirement check of the seven notebooks.
4. `latexmk -pdf -interaction=nonstopmode -halt-on-error fable_cosmology.tex` in `latex/`,
   with all of latexmk's output going to `latex/latexmk.log`. Then it lists
   `latex/fable_cosmology.pdf`.

It ends with `== all done`. `run_all.sh` stops at the first failure, because it runs under
`set -euo pipefail`. `run_all.ps1` throws on a failing `cargo test` of either solver (it checks
`$LASTEXITCODE` after each), on a failing notebook, on the checker and on the paper build. On the
development machine, before the fermion-fable work, the whole run took 51 s in the working
repository and 61 s in a fresh clone, and the setup before it took 80 s in the fresh clone,
including pip and the engine clone over the network. With the fermion-fable work the run took
3 min 35 s on 2026-09-24 (of which the tests of `fable_fermion` take about 45 s, notebook 05 about
11 s and notebook 06 about 2 min). With notebook 07 it took 12 min 18 s on 2026-09-25, of which
notebook 07 takes about 9 minutes (section 16). What it prints is in section 12.

Because step 2 re-executes the notebooks in place, `git status` shows them as modified
afterwards. The execution timestamp of every cell changes on every run, and the kernel may split
a cell's printed output into chunks differently. Their content (printed text, figures, results)
does not change. `git status` also shows any result file whose bytes changed. How to compare the
numbers is in section 12.

## 5. The physics the solver integrates

This section is a summary for the classical fields and the solver `fable_cosmo`; the paper
(`latex/fable_cosmology.pdf`) gives the derivations. The quantized fermion fable and the solver
`fable_fermion` are described in section 14.

**The pre-universe.** It has coordinates `x0 … x7`, the flat metric
`η = diag(+1,+1,+1,+1,−1,−1,−1,−1)`, and the canonical frame
`e = diag(Tan[6Hx0], q, q, q, 1, p, p, p)` with `q = e^{−a4(Hx4)}/Sin[6Hx0]^{1/6}`,
`p = e^{+a4(Hx4)}/Sin[6Hx0]^{1/6}`. The volume element is `Sqrt[det g] = Sec[6Hx0]`, independent
of `x4`. `H` is a constant of the model. The function `a4` is undetermined and is never given a
value. The observer's time is `t = x4`. The observer measures the energy density `ρ = T_44`, the
pressure `P = T^1_1 = T^2_2 = T^3_3`, and the equation of state `w = P/ρ`.

**fableScalar.** The Lagrangian is `L = Sqrt[g] (−½ g^{μν} ∂_μφ ∂_νφ − V(φ))`. The
energy–momentum tensor is `T_μν = ∂_μφ ∂_νφ + g_μν L̂`. The field equation is `□φ = V′(φ)`. The
energies are `KE = ½φ̇²`, `PE = V`, `G0 = ½Cot²(6Hx0)(∂_0φ)²` (the gradient along the hidden
coordinate) and `G5` (the gradient along the second sheet). Then `ρ = KE + PE + G0 − G5` and
`P = KE − PE − G0 + G5`, so `ρ + P = 2 KE ≥ 0`. That means `w ≥ −1` wherever `ρ > 0`. On the
pre-universe there is no Hubble friction: `φ̈ = −V′(φ)`.

**fable.** The Lagrangian is `L = Sqrt[g] ((1/H) Ψᵀσ16 γ^μ D_μΨ − V(s))`, and the field equation
is the covariant Dirac equation `γ^μ D_μΨ = H V′(s) Ψ`. The author's own Lagrangian is the case
`V = −(2M/H) s`. On the homogeneous solutions `ρ = V(s)`, `P = sV′(s) − V(s)`, and
`w = sV′(s)/V(s) − 1`. So the author's mass term is dust, `w = 0`. And `w` crosses −1 wherever
`V′` changes sign with `V > 0`. On the pre-universe `ds/dx4 = 0`: `s` does not dilute.

**The numerical models.** Units are `8πG = 1`, `H0 = 1`, `a0 = 1`, so the critical density
today is 3. The parameters are `Ω_m0 = 0.3` and `Ω_r0 = 8.4e−5`. For the FLRW models the
independent variable is `N = ln a`, and `ρ_m = 3Ω_m0 e^{−3N}`, `ρ_r = 3Ω_r0 e^{−4N}`.

| model | solver name | what | the system handed to CVODE |
|---|---|---|---|
| A | `scalar-flrw` | fableScalar sourcing a flat FLRW universe (standard quintessence) | `dφ/dN = φ̇/H`, `dφ̇/dN = −3φ̇ − V′(φ)/H`, `dt/dN = 1/H`, with `H² = Ω_m0 e^{−3N} + Ω_r0 e^{−4N} + (½φ̇² + V)/3` |
| A′ | `scalar-cpl` | the same field as a test field on the Unite CPL background | the same, with `H² = Ω_m0 a^{−3} + Ω_r0 a^{−4} + Ω_DE0 a^{−3(1+w0+wa)} e^{−3wa(1−a)}` |
| B | `spinor-flrw` | fable in a flat FLRW universe | `ds/dN = −3s`, `dt/dN = 1/H`, with `H² = Ω_m0 e^{−3N} + Ω_r0 e^{−4N} + V(s)/3`; `w = sV′/V − 1` |
| C | `scalar-pre` | fableScalar on the pre-universe, homogeneous (`H = 1`) | `dφ/dx4 = φ̇`, `dφ̇/dx4 = −V′(φ)` |
| D | `scalar-pre-x0` | fableScalar on the pre-universe with a profile along `x0` (method of lines) | `φ̈_j = Cos_j (F_{j+½} − F_{j−½})/h − V′(φ_j)`, `F_{j+½} = c_{j+½}(φ_{j+1} − φ_j)/h`, `c = Sec Cot²`, zero flux at both ends |
| E | — | fable on the pre-universe | nothing to integrate: `ds/dx4 = 0` exactly |

The **Friedmann equation, `H(a)`, every `Ω` and every CPL fit belong to the 4-dimensional
reference models (A, A′, B).** The pre-universe itself has no gravitational sector. The reference
models live on a separate FLRW frame and never give `a4` a value.

The **CPL fit** of a run is the unweighted least-squares straight line `w0 + wa (1 − a)` through
the run's `w(a)` over `0.3 ≤ a ≤ 1`. It is compared with the Supernovae Unite fits
`(w0, wa) = (−0.861, −0.60)` and `w = −0.764` (constant `w`).

## 6. The solver `fable_cosmo`

**Where it is.** `fable-cosmology/rust/fable_cosmo/target/release/fable_cosmo`, or
`fable_cosmo.exe` on Windows, once the setup has built it. The examples below are run from
`fable-cosmology/` and write to `/tmp`. On Windows, write to a folder you own instead, because
the Windows binary does not see Git Bash's `/tmp`.

**The command line.**

    fable_cosmo <model> [--potential NAME] [--param KEY=VALUE ...] [--n0 X0] [--n1 X1] [--points K]
                [--out FILE.csv] [--no-normalize] [--grid N] [--x0min A] [--x0max B]
                [--profile-out FILE.csv] [--rtol R] [--atol A] [--method bdf|adams]
    fable_cosmo --version

| option | meaning | default |
|---|---|---|
| `<model>` | `scalar-flrw` (A), `scalar-cpl` (A′), `spinor-flrw` (B), `scalar-pre` (C), `scalar-pre-x0` (D) | required |
| `--potential NAME` | the potential (tables below) | `exp` for the scalar models, `mass` for `spinor-flrw` |
| `--param KEY=VALUE` | set one parameter; repeat for more | see the tables below |
| `--n0`, `--n1` | the range of the independent variable: `N = ln a` for A, A′, B; `x4` for C, D | A, A′, B: `−7` to `0`; C, D: `0` to `50` |
| `--points K` | number of equally spaced output points, first and last included (at least 2) | `701` |
| `--out FILE.csv` | write the CSV there; **without it the CSV goes to standard output** | standard output |
| `--no-normalize` | keep the potential's scale as given (no shooting, no rescaling) | normalise |
| `--grid N` | Model D: number of `x0` grid points (at least 3) | `101` |
| `--x0min A`, `--x0max B` | Model D: the `x0` interval, which must lie inside `(0, π/12)` (with `H = 1`) | `0.05`, `0.22` |
| `--profile-out FILE.csv` | Model D: also write the whole profile `φ(x0_j, x4)` | not written |
| `--rtol R`, `--atol A` | CVODE's relative and absolute tolerances | `1e-10`, `1e-12` |
| `--method bdf\|adams` | CVODE's linear multistep family | `bdf` for A, A′, B; `adams` for C, D |

**Scalar potentials** (models `scalar-flrw`, `scalar-cpl`, `scalar-pre`, `scalar-pre-x0`):

| `--potential` | `V(φ)` | parameters (default) | default `phi_i` in A, A′ |
|---|---|---|---|
| `exp` | `v0 exp(−lambda φ)` | `v0` (1), `lambda` (1) | 0 |
| `invpower` | `v0 φ^(−alpha)` | `v0` (1), `alpha` (1) | 0.2 |
| `pngb` | `v0 (1 + cos(φ/f))` | `v0` (1), `f` (1) | `0.5 f` |
| `quadratic` | `½ m² φ²` | `m` (1) | 1 |
| `hilltop` | `v0 (1 − φ²/mu²)` | `v0` (1), `mu` (1) | `0.1 mu` |
| `const` | `v0` | `v0` (1) | 0 |
| `quartic` | `¼ lambda φ⁴` | `lambda` (1) | 1 |

**Spinor potentials** (model `spinor-flrw`), with their equation of state `w(s) = sV′/V − 1`:

| `--potential` | `V(s)` | parameters (default) | `w(s)` |
|---|---|---|---|
| `mass` | `m s` | `m` (1) | `0` (dust) |
| `lambda-mass` | `v0 + m s` | `v0` (1), `m` (1) | `−v0/(v0 + m s)` |
| `power` | `m s + lambda s^n` | `m` (1), `lambda` (1), `n` (0.5) | `(m s + n lambda s^n)/(m s + lambda s^n) − 1` |
| `hilltop` | `v0 − mu (s − sstar)²` | `v0` (1), `mu` (1), `sstar` (1.5) | `−2 mu s (s − sstar)/V − 1`; valid only while `V > 0` |
| `lorentz` | `v0 + m s/(1 + (s/s1)²)` | `v0` (1), `m` (1), `s1` (1.5) | `m s (1 − u)/((1 + u)² V) − 1`, `u = (s/s1)²` |
| `expdamp` | `v0 + m s exp(−s/s1)` | `v0` (1), `m` (1), `s1` (1.5) | `m s e^{−s/s1} (1 − s/s1)/V − 1` |

**Other parameters.**

- Cosmology (A, A′, B): `om` (0.3), `or` (8.4e−5), and the CPL background of A′, `w0` (−0.861)
  and `wa` (−0.60).
- Initial state of A and A′: `phi_i` (see the table above) and `phidot_i` (0).
- Model B: `s_today` (1), the value of `s` at `a = 1`, so `s = s_today e^{−3N}`.
- Model C: `phi_i` (1), `phidot_i` (0).
- Model D: `phi_i` (1), `eps` (0.5) and `mode` (1). The initial profile is
  `φ(x0, 0) = phi_i (1 + eps cos(mode π (x0 − x0min)/(x0max − x0min)))`, at rest.

**Normalisation** (on unless `--no-normalize` is given).

- Model A shoots on the overall scale `k` of `V` until the field carries
  `Ω_φ(a=1) = 1 − om − or = 0.699916`. The shooting bisects on `log10 k` in `[−6, 6]`, for 80
  iterations or until the bracket is narrower than `1e−13`.
- Model A′ does the same until `ρ_φ(a=1)/3 = 1 − om − or`.
- Model B rescales `V` so that `V(s_today) = 3 (1 − om − or)`. This leaves `w(s)` unchanged.
- Models C and D are never normalised.

The potential after normalisation is printed on standard error. Use those values if you want to
reproduce a run elsewhere.

**Standard error.** A normal run prints, in this order:

    # initial conditions: N0=-7 phi_i=0 phidot_i=0 t_age(N0)=2.198720e-5        (A, A′, B only)
    # stats: model=scalar-flrw steps=385 rhs_evals=434 nonlin_iters=431 err_test_fails=5
    # potential=exp Exp { v0: 2.6871520526047146, lambda: 1.0 }
    # fable_cosmo 0.1.0, sundials_rs 7.8.0 (pure Rust), CVODE BDF

`t_age(N0) = 1/(2H(N0))` is the age of the universe at the start. It is added analytically to
the integrated time. The version line always says `CVODE BDF`, even for an Adams run. The
`# stats` line gives the CVODE statistics of the final integration: steps, right-hand-side
evaluations, nonlinear iterations and error-test failures.

**Exit codes** (verified against the binary):

- `0`: success.
- `1`: the model or potential name is unknown, or the physics or solver failed. The reason is
  printed on one line starting with `fable_cosmo:`. Examples: the normalisation cannot bracket its
  target; `ρ_φ ≤ 0`; `V(s) ≤ 0` at the start or at an output point; an `x0` grid outside
  `(0, π/12)`; CVODE failed; the output file cannot be written.
- `2`: the command line is malformed: no arguments, an unknown option, a missing value, a value
  that is not a number, `--param` without `=`, `--points` below 2, or an unknown `--method`. The
  usage line is printed.

**Examples** (run from `fable-cosmology/`; `B=rust/fable_cosmo/target/release/fable_cosmo`, with
`.exe` on Windows):

```bash
$B --version
$B scalar-flrw --potential exp --param lambda=1 --out /tmp/exp1.csv       # Model A, the reference case
$B scalar-cpl --potential exp --param lambda=1 --out /tmp/cpl1.csv        # Model A′
$B spinor-flrw --potential expdamp --param v0=1.566 --param m=0.839 --param s1=2.21 --no-normalize --out /tmp/expdamp.csv
$B scalar-pre --potential quadratic --param m=1 --n1 100 --points 2001 --out /tmp/c.csv
$B scalar-pre-x0 --potential quadratic --param m=1 --param eps=0.05 --grid 61 --n1 30 --points 301 --profile-out /tmp/prof.csv --out /tmp/d.csv
$B spinor-flrw --potential mass --points 3                                # three rows to the screen
```

The first Model A command prints the four standard-error lines shown above. Its last CSV row has
`w_phi = -8.433638040266683e-1`. The last command prints the header and three rows to the screen,
between its standard-error lines. The last row (`a = 1`) has `w_Psi = 0.000000000000000e0`,
`Omega_Psi = 6.999160109843290e-1` and `q_dec = 5.000419999984629e-1`.

Refusals look like this. The exponential potential with `lambda = 3` cannot carry 70 % of the
density today, because it joins its scaling solution:

    $ fable_cosmo scalar-flrw --potential exp --param lambda=3
    fable_cosmo: normalisation cannot bracket Omega_phi = 0.699916: Omega(10^-6 V) = 0.0000011107972084367645, Omega(10^6 V) = 0.3375115141492524; choose the scale by hand and pass --no-normalize

## 7. The CSV files

This section describes the CSVs of `fable_cosmo`; those of `fable_fermion` are described in section 14.4.

Every CSV has a header line that names each column, then one line per output point. The numbers
are written in Rust's `{:.15e}` format: one digit, a point, fifteen decimals and an exponent,
for example `9.118819655545162e-4`. That is 16 significant digits. Python's `float()`,
numpy's `genfromtxt` (which the notebooks use) and Mathematica's `Import` all read it.

**Units.** In models A, A′ and B, time is in units of `1/H0`, `H` is in units of `H0`, and
densities and pressures are in units where `ρ_crit,0 = 3`. In models C and D, `H = 1` and the
field is dimensionless.

**`scalar-flrw` (Model A):**
`a, z, N, t, phi, phidot, H, KE, PE, rho_phi, P_phi, w_phi, Omega_phi, Omega_m, Omega_r, q_dec`.

- `z = 1/a − 1` and `N = ln a`.
- `t` is the age, including `t_age(N0)`.
- `phidot = dφ/dt`.
- `KE = ½φ̇²`, `PE = V(φ)`, `rho_phi = KE + PE`, `P_phi = KE − PE` and `w_phi = P_phi/rho_phi`.
- `Omega_i = ρ_i/(3H²)`.
- `q_dec = −1 − (dH/dN)/H` is the deceleration parameter.

**`scalar-cpl` (Model A′):** the same first twelve columns, then `w_cpl, Omega_phi_test,
Omega_DE_cpl`.

- `w_cpl = w0 + wa (1 − a)` is the background's equation of state.
- `Omega_phi_test = ρ_φ/(3H²)` is the share the test field would have.
- `Omega_DE_cpl` is the background's dark-energy fraction.

**`spinor-flrw` (Model B):**
`a, z, N, t, s, H, K_Psi, U_Psi, rho_Psi, P_Psi, w_Psi, Omega_Psi, Omega_m, Omega_r, q_dec`.

- `K_Psi = s V′(s)` is the kinetic bilinear on shell.
- `U_Psi = rho_Psi = V(s)`, `P_Psi = sV′ − V` and `w_Psi = sV′/V − 1`.

**`scalar-pre` (Model C):** `x4, phi, phidot, KE, PE, rho, P, w, w_avg, rho_drift`.

- `w_avg` is the running trapezoidal average of `w` from the start.
- `rho_drift = ρ/ρ(0) − 1`. It must be at solver precision.

**`scalar-pre-x0` (Model D):**
`x4, phi_mid, KE_mid, PE_mid, G0_mid, rho_mid, P_mid, w_mid, E_sheet, P_sheet, w_sheet, KE_frac, PE_frac, G0_frac, E_drift`.

- The `_mid` columns are local values at the middle grid point.
- `E_sheet` is the exactly conserved discrete energy `E_h`. It is the `Sec[6x0]`-weighted sum of
  the kinetic and potential energies plus the discrete gradient energy.
- `P_sheet` is the matching pressure, and `w_sheet = P_sheet/E_sheet`. This is the ratio of the
  averages, never the average of the ratios.
- `KE_frac`, `PE_frac` and `G0_frac` are the energy fractions of `E_h`. They sum to 1.
- `E_drift = E_h/E_h(0) − 1`.

**The profile file of `--profile-out`.** Its header is `x4` followed by one `phi` for each grid
point. Its first data row is `NaN` followed by the `x0` grid values. Every following row is `x4`
followed by `φ(x0_j, x4)`.

**The files the notebooks write** under `results/`:

- The solver's CSVs, named `nb0N_<case>.csv`.
- The fit tables `nb01_cpl_fits.csv` and `nb02_cpl_fits.csv`, with columns
  `run, model, w0_fit, wa_fit, w0_plus_wa, w_a03, w_a1, w_min, class, omega_today, dist_to_unite`.
  The last two rows of each are the Unite reference rows.
- The scan `nb01_lambda_scan.csv`, with columns
  `lambda, w0_fit, wa_fit, dist_to_unite, w_a1, w_a03, w_min`.
- The crossing table `nb02_crossings.csv`, with columns
  `run, a_cross_numeric, a_cross_analytic, abs_error, n_crossings, min_V`.
- 16 PNG figures.

## 8. The notebooks

This section describes notebooks 01–04 and what all seven have in common; notebooks 05 and 06 are
described in full in section 15, notebook 07 in section 16.

**What each one does.**

- **01_fableScalar_quintessence** runs Models A and A′. It covers the exponential potential for
  `λ = 0.5, 1, 1.5, 2` and the refused `λ = 3`, which is then run on its scaling solution. It
  also runs the inverse power from two starts, the PNGB potential, the hilltop and the constant
  control, plus A′ for `λ = 1` and `λ = 2`. It plots `w(a)` and the Caldwell–Linder plane, and
  writes the CPL fit table. It re-integrates every run with scipy, compares three integrators on
  the reference case, and scans `λ = 0.5 … 2.0`. Section 7 of the notebook answers "which `λ`"
  and "is `|wa| = 0.6` reachable without `w < −1`".
- **02_fable_spinor** runs Model B. It covers dust (`mass`), `lambda-mass` (with `Ω_Λ` reported
  separately), the power laws (including a run into the future to `a = e⁶`), and the potentials
  that cross `w = −1`: `lorentz`, `expdamp` (reference, `s1 = 1.5`, `s1 = 3.0`) and `hilltop`,
  which is refused from the default start and run inside its window. It plots `V(s)` and `w(s)`
  and compares the crossings with their analytic positions. It writes the CPL table, re-integrates
  every run with scipy, and compares three integrators on the reference case.
- **03_pre-universe_dynamics** runs Model C (quadratic, quartic and constant potentials, each
  compared with scipy, and a tighter-tolerance repeat of the quartic case) and Model D
  (`ε = 0.05` and `ε = 0.5`, with the profile files and an independent numpy/scipy
  re-implementation). It states Model E.
- **04_dark_matter_dark_energy** re-runs the seven best cases and reads the two CPL tables with
  plain Python. It makes the three synthesis figures and answers the questions: is there a
  connection to dark matter, and to dark energy? What is the framework's own mechanism? What is
  not established?

Notebook 04 reads `results/nb01_cpl_fits.csv` and `results/nb02_cpl_fits.csv`. **Run 01 and 02
before 04.** `run_all` does.

**Open them interactively.** From the repository root:

```bash
cd fable-cosmology
.venv/bin/jupyter lab notebooks/            # macOS, Linux
.venv/Scripts/jupyter.exe lab notebooks/    # Windows, Git Bash
```

```powershell
cd fable-cosmology
.venv\Scripts\jupyter.exe lab notebooks\    # Windows, PowerShell
```

A browser tab opens. Click a notebook. If Jupyter asks for a kernel, choose
**Python 3 (ipykernel)**. Run a cell with **Shift+Enter**, or everything with
`Run > Run All Cells`.

Every notebook starts with the same launch instructions and glossary. Then it states the field,
its Lagrangian and energy–momentum tensor, and the equations of motion, including the
first-order system handed to SUNDIALS. After that it runs the solver and ends with its results.
The last two cells ask you for a name for the notebook and open a *Save as* dialog. If no
graphical dialog is available, the second one falls back to asking for a folder in plain text.
Run headlessly, both cells detect that nobody can answer and print a one-line notice instead.

Every notebook **asserts** the numbers its text quotes. If a re-run changed any of them, the
cell fails loudly, and so does the whole headless execution.

**Re-execute one notebook headlessly** (from `fable-cosmology/`):

```bash
.venv/bin/python -m nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=1800 --ExecutePreprocessor.kernel_name=python3 notebooks/01_fableScalar_quintessence.ipynb
```

On Windows use `.venv/Scripts/python.exe` in Git Bash, or `.venv\Scripts\python.exe` in
PowerShell. Every CSV and PNG that notebook owns under `results/` is rewritten.

**Regenerate the notebooks from the generator** (only if you changed `notebooks/_build/nbgen.py`):

```bash
.venv/bin/python notebooks/_build/nbgen.py          # writes all seven, unexecuted
.venv/bin/python notebooks/_build/nbgen.py 02       # or just one (or several: 05 06)
```

A generated notebook has no outputs. Execute it as above before running the checker, because
the checker requires every non-interactive cell to have been executed. Never edit a `.ipynb` by
hand: the generator is the source of truth.

**The notebook conventions** (encoded in `nbgen.py`, checked by `nbcheck.py`):

- Every code cell is preceded by at least 80 characters of explanation.
- The sections `1. How to open a notebook like this one, from a terminal`,
  `2. The words used in this notebook`,
  `3. The field, its Lagrangian and its energy-momentum tensor`, `4. The equations of motion`
  (with `4.1 The first-order system actually handed to SUNDIALS`), `5. Running the solver` and
  `6. This notebook's results` are present.
- The solver is located relative to the notebook.
- Every run is cross-checked with an independent implementation and must agree to `1e−6`: for
  01–04 scipy DOP853 at `rtol = 1e−11` in `w`; for 05–07 see sections 15 and 16.
- The CPL fit is `numpy.polyfit` on `1 − a` over `0.3 ≤ a ≤ 1`.
- There are no random numbers.
- Result files are named by notebook number.
- The two interactive cells are tagged `interactive`.
- `metadata.fable_cosmo.model` (01–04) or `metadata.fable_fermion.model` (05–07) records the
  solver models the notebook runs; a notebook names exactly one solver (07 adds the model
  `waveguide`, the wall-state solver).
- The glossary of section 2 explains a fixed list of words (the checker verifies it); the fermion
  notebooks' glossary adds the words of the quantized theory (section 15), and notebook 07's adds
  those of density functional theory and of the wall problem (section 16).
- Every number a notebook's text quotes is asserted by a cell (01–04) or computed and printed by
  the notebook itself (05–07, whose prose states no results).

## 9. The tests and checks

**The solver's unit tests.** From `fable-cosmology/rust/fable_cosmo`:

```bash
cargo test --release
```

There are 7 tests:

- `scalar_derivatives_match_finite_differences`: every scalar potential's `V′` against a
  central difference.
- `spinor_derivatives_match_finite_differences_and_w`: the same for the spinor potentials, plus
  `w = 0` for the mass term, `w = n − 1` for a power law, the crossings at `s1` and `sstar`, the
  positivity of `lorentz` and `expdamp`, and `w` unchanged by `V → kV`.
- `cpl_closed_form_matches_the_integral`, which also checks `H²_CPL(1) = 1`.
- `rho_plus_p_is_twice_the_kinetic_energy`.
- `friedmann_closure_today`: `H(N=0) = 1` and `Ω_m(1) = Ω_m0`.
- `x0_grid_rejects_the_singular_ends`: Model D refuses `x0 = 0` and `6x0 ≥ π/2`.
- `exponential_decay_to_tolerance`: CVODE BDF and Adams against `2e^{−1.5x}`.

The expected ending is:

    running 7 tests
    …
    test result: ok. 7 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

**The notebook checker.** From `fable-cosmology/`:

```bash
.venv/bin/python notebooks/_build/nbcheck.py      # Windows Git Bash: .venv/Scripts/python.exe
```

It checks eight requirements for every notebook:

- **R1** launch instructions.
- **R2** never sends the reader to another notebook.
- **R3** explanation before every code cell.
- **R4** asks for a name.
- **R5** save dialog with a fallback.
- **R6** the physics sections.
- **R7** valid nbformat 4, every non-interactive cell executed, and the solver model recorded.
- **R8** owns its result files and reads one back with plain Python.

The expected last line is `7/7 notebooks pass all eight requirements`, with exit code 0. For the
fermion notebooks R1 also requires the crate `rust/fable_fermion` to be named, R6 also checks the
glossary words of the quantized theory, and R7 checks `metadata.fable_fermion.model` against
`fable4d`, `fable8d`, `gap` and `waveguide` and fails on any cell that raised an error. A notebook
whose model list contains `waveguide` (notebook 07) must also name `fermion/waveguide.py` (R1) and
explain the words of density functional theory and of the wall problem (R6).

**The cross-checks inside the notebooks.**

- Every run is re-integrated with scipy.
- The reference cases are compared three ways: CVODE, scipy and Mathematica `NDSolve`.
- Controls: the constant potential must give `w = −1`, the mass term `w = 0`, and the crossings
  must agree with `a_c = (s1/s_today)^{−1/3}` to `1e−6`.
- Conserved quantities must drift by less than `1e−6`.
- The text's numbers are asserted.

## 10. The paper

`latex/fable_cosmology.tex` compiles to `latex/fable_cosmology.pdf` (24 pages). You need
`pdflatex` and `latexmk` from MiKTeX or TeX Live. On Windows in PowerShell you also need Perl
(section 2). From `fable-cosmology/latex`:

```bash
latexmk -pdf -interaction=nonstopmode -halt-on-error fable_cosmology.tex
```

The paper uses these packages, all in MiKTeX's and TeX Live's standard sets: `lmodern`,
`geometry`, `microtype`, `amsmath`, `amssymb`, `graphicx`, `booktabs`, `tabularx`, `caption`,
`subcaption`, `placeins`, `enumitem`, `fancyvrb`, `upquote` and `hyperref`. Its figures are the
16 PNGs in `latex/figures/`, which are byte-identical copies of the ones in `results/`. If you
re-run the notebooks and want the paper to show your figures, copy them over first:
`cp results/nb0[1-4]_*.png latex/figures/` (the paper uses only the figures of notebooks 01–04).

A clean build ends with `Output written on fable_cosmology.pdf (24 pages, …)` in
`fable_cosmology.log`. The log contains no errors, no undefined references and no overfull
boxes. latexmk's intermediate files (`.aux`, `.fls`, `.fdb_latexmk`, `.out`, `.toc`, the two
`.log` files) are ignored by git. To remove them, run `latexmk -c`.

## 11. The Mathematica reference (optional)

The two committed files `reference/mathematica_scalar_exp.csv` (Model A, `exp`, `λ = 1`,
`V0 = 2.6871520526047146`) and `reference/mathematica_spinor_expdamp.csv` (Model B, `expdamp`
`(1.566, 0.839, 2.21)`, not normalised) come from `NDSolve` at 24-digit working precision. They
use the same equations, parameters, start and 701 output points as the solver. To regenerate
them, run from the repository root:

```bash
wolframscript -file fable-cosmology/reference/make_reference.wls
```

It prints (and took 366 s on the development machine):

    mathematica_scalar_exp.csv: 701 rows;  w(a=1) = -0.843363803931198
    mathematica_spinor_expdamp.csv: 701 rows;  w(a=1) = -0.8608456403776481  min w = -1.3020988149091868

The regenerated files are byte-identical to the committed ones.

Part VI of the Mathematica notebook repeats both integrations and asserts agreement with these
files at every row to `1e−9`. To evaluate the whole notebook (172 Input cells, about 2.5
minutes), run from the repository root:

```bash
cd claude-fable
wolframscript -file run_from_nb.wls
```

It must end with `Assertions run: 358   passed: 358   failed: 0` and `cells w/ msgs   : 0`.
Evaluating the notebook rewrites the two files `claude-fable/claude-fable_Einstein-Rosen-2-Planes-eLa.mx`
and `…-eLazt.mx` (Mathematica's `DumpSave`, whose output differs byte-wise from run to run).
Restore them with `git checkout -- claude-fable/*.mx` if you do not intend to commit them.

## 12. The numbers you should get

A re-run reproduces the committed CSVs. The table below lists the numbers that matter. Each one is
asserted by a notebook, so a re-run that changed any of them would fail.

| case | quantity | value |
|---|---|---|
| Model A, `exp λ = 1` | `w(a=1)`; CPL fit `(w0, wa)` | −0.843364; (−0.8440, −0.2172) |
| Model A, `exp λ = 1.5` | CPL fit; distance from Unite | (−0.6176, −0.5015); 0.263 |
| Model A, scan | closest `λ`; `λ` with `wa = −0.60` | 1.4, fit (−0.6740, −0.4349), distance 0.2495; 1.638, with `w0 = −0.5274` |
| Model A, every run | `min w` | −1.000000 (never below −1) |
| Model A, `exp λ = 3` | refused; by hand with `v0 = 1e6` | `Ω_φ(1) = 0.3375` (`3/λ² = 0.3333`) |
| Model A′, `exp λ = 1` | CPL fit | (−0.8371, −0.2257) |
| Model B, `mass` | `max \|w\|` | 0 (dust, exactly) |
| Model B, `lambda-mass` | `Ω_Λ`, `Ω_dust`, `w(1)` | 0.489941, 0.209975, −0.700000 |
| Model B, `power n = 0.236` | `w(1)`; `w(N = 6)` | −0.38200; −0.76399919 |
| Model B, `expdamp (1.566, 0.839, 2.21)` | `w(1)`; crossing `a_c`; `min w` at `a`; fit | −0.86085; 0.7677195 (analytic 0.7677195); −1.30210 at 0.5434; (−0.9782, −0.2445) |
| Model B, `expdamp s1 = 3.0` | fit; distance from Unite | (−0.8513, −0.5692); 0.0323 (the closest of all runs) |
| Model C, quadratic, `x4 ≤ 100` | `w_avg(100)`; `max \|ρ drift\|` | +0.004363; 3.27e−9 |
| Model C, quartic, `x4 ≤ 100` | `w_avg(100)` | 0.334909 (virial value 1/3) |
| Model D, `ε = 0.05`, `ε = 0.5` | `max \|E_drift\|`; `G0` fraction at `x4 = 0` | 4.48e−9, 9.05e−9; 0.2847, 0.9780 |
| three integrators, Model A | `max \|Δw\|` CVODE–NDSolve, scipy–NDSolve, CVODE–scipy | 1.149e−10, 1.313e−10, 9.509e−11 |
| three integrators, Model B | the same | 1.861e−8, 1.008e−11, 1.861e−8 |

**What `run_all.sh` printed** on the development machine (Windows 11, Git Bash, 2026-09-25, with the
seven notebooks; 12 min 18 s):

    == 1. solver tests
       rust/fable_cosmo

    test result: ok. 7 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

       rust/fable_fermion
    running 23 tests
    test result: ok. 23 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 38.31s
    running 0 tests
    test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
    running 11 tests
    test result: ok. 11 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.93s
    running 0 tests
    test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
    == 2. notebooks
       executing notebooks/01_fableScalar_quintessence.ipynb
    [NbConvertApp] Converting notebook notebooks/01_fableScalar_quintessence.ipynb to notebook
    C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\fable-cosmology\.venv\Lib\site-packages\zmq\_future.py:718: RuntimeWarning: Proactor event loop does not implement add_reader family of methods required for zmq. Registering an additional selector thread for add_reader support via tornado. Use `asyncio.set_event_loop_policy(WindowsSelectorEventLoopPolicy())` to avoid this warning.
      self._get_loop()
    [IPKernelApp] WARNING | Kernel is running over TCP without encryption. All communication (including code and outputs) is sent in plain text and is susceptible to eavesdropping. Use IPC transport or launch with kernel manager-provisioned CurveZMQ keys to enable transport encryption.
    [NbConvertApp] Writing 475134 bytes to notebooks\01_fableScalar_quintessence.ipynb
       executing notebooks/02_fable_spinor.ipynb
    [NbConvertApp] Converting notebook notebooks/02_fable_spinor.ipynb to notebook
    C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\fable-cosmology\.venv\Lib\site-packages\zmq\_future.py:718: RuntimeWarning: Proactor event loop does not implement add_reader family of methods required for zmq. Registering an additional selector thread for add_reader support via tornado. Use `asyncio.set_event_loop_policy(WindowsSelectorEventLoopPolicy())` to avoid this warning.
      self._get_loop()
    [IPKernelApp] WARNING | Kernel is running over TCP without encryption. All communication (including code and outputs) is sent in plain text and is susceptible to eavesdropping. Use IPC transport or launch with kernel manager-provisioned CurveZMQ keys to enable transport encryption.
    [NbConvertApp] Writing 532820 bytes to notebooks\02_fable_spinor.ipynb
       executing notebooks/03_pre-universe_dynamics.ipynb
    [NbConvertApp] Converting notebook notebooks/03_pre-universe_dynamics.ipynb to notebook
    C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\fable-cosmology\.venv\Lib\site-packages\zmq\_future.py:718: RuntimeWarning: Proactor event loop does not implement add_reader family of methods required for zmq. Registering an additional selector thread for add_reader support via tornado. Use `asyncio.set_event_loop_policy(WindowsSelectorEventLoopPolicy())` to avoid this warning.
      self._get_loop()
    [IPKernelApp] WARNING | Kernel is running over TCP without encryption. All communication (including code and outputs) is sent in plain text and is susceptible to eavesdropping. Use IPC transport or launch with kernel manager-provisioned CurveZMQ keys to enable transport encryption.
    [NbConvertApp] Writing 1090050 bytes to notebooks\03_pre-universe_dynamics.ipynb
       executing notebooks/04_dark_matter_dark_energy.ipynb
    [NbConvertApp] Converting notebook notebooks/04_dark_matter_dark_energy.ipynb to notebook
    C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\fable-cosmology\.venv\Lib\site-packages\zmq\_future.py:718: RuntimeWarning: Proactor event loop does not implement add_reader family of methods required for zmq. Registering an additional selector thread for add_reader support via tornado. Use `asyncio.set_event_loop_policy(WindowsSelectorEventLoopPolicy())` to avoid this warning.
      self._get_loop()
    [IPKernelApp] WARNING | Kernel is running over TCP without encryption. All communication (including code and outputs) is sent in plain text and is susceptible to eavesdropping. Use IPC transport or launch with kernel manager-provisioned CurveZMQ keys to enable transport encryption.
    [NbConvertApp] Writing 318320 bytes to notebooks\04_dark_matter_dark_energy.ipynb
       executing notebooks/05_fermion_fable_quantum_eos.ipynb
    [NbConvertApp] Converting notebook notebooks/05_fermion_fable_quantum_eos.ipynb to notebook
    C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\fable-cosmology\.venv\Lib\site-packages\zmq\_future.py:718: RuntimeWarning: Proactor event loop does not implement add_reader family of methods required for zmq. Registering an additional selector thread for add_reader support via tornado. Use `asyncio.set_event_loop_policy(WindowsSelectorEventLoopPolicy())` to avoid this warning.
      self._get_loop()
    [IPKernelApp] WARNING | Kernel is running over TCP without encryption. All communication (including code and outputs) is sent in plain text and is susceptible to eavesdropping. Use IPC transport or launch with kernel manager-provisioned CurveZMQ keys to enable transport encryption.
    [NbConvertApp] Writing 734434 bytes to notebooks\05_fermion_fable_quantum_eos.ipynb
       executing notebooks/06_fable_primordial_gravity_8d.ipynb
    [NbConvertApp] Converting notebook notebooks/06_fable_primordial_gravity_8d.ipynb to notebook
    C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\fable-cosmology\.venv\Lib\site-packages\zmq\_future.py:718: RuntimeWarning: Proactor event loop does not implement add_reader family of methods required for zmq. Registering an additional selector thread for add_reader support via tornado. Use `asyncio.set_event_loop_policy(WindowsSelectorEventLoopPolicy())` to avoid this warning.
      self._get_loop()
    [IPKernelApp] WARNING | Kernel is running over TCP without encryption. All communication (including code and outputs) is sent in plain text and is susceptible to eavesdropping. Use IPC transport or launch with kernel manager-provisioned CurveZMQ keys to enable transport encryption.
    [NbConvertApp] Writing 1412296 bytes to notebooks\06_fable_primordial_gravity_8d.ipynb
       executing notebooks/07_fable_dft_states.ipynb
    [NbConvertApp] Converting notebook notebooks/07_fable_dft_states.ipynb to notebook
    C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\fable-cosmology\.venv\Lib\site-packages\zmq\_future.py:718: RuntimeWarning: Proactor event loop does not implement add_reader family of methods required for zmq. Registering an additional selector thread for add_reader support via tornado. Use `asyncio.set_event_loop_policy(WindowsSelectorEventLoopPolicy())` to avoid this warning.
      self._get_loop()
    [IPKernelApp] WARNING | Kernel is running over TCP without encryption. All communication (including code and outputs) is sent in plain text and is susceptible to eavesdropping. Use IPC transport or launch with kernel manager-provisioned CurveZMQ keys to enable transport encryption.
    [NbConvertApp] Writing 905839 bytes to notebooks\07_fable_dft_states.ipynb
    == 3. notebook requirements

    7/7 notebooks pass all eight requirements
    == 4. the paper
    -rw-r--r-- 1 nsh 197121 2835044 Sep 24 19:40 fable_cosmology.pdf
    == all done

The two lines that follow each `Converting notebook` line are warnings of the zmq and Jupyter
libraries on Windows. They are not errors, and they do not come from the notebooks. `run_all.sh`
shows only the last three lines of `cargo test` for `fable_cosmo`, so the first of them is empty, and
the `running …` and `test result:` lines for `fable_fermion` (its library, its command-line binary, its
end-to-end tests and its documentation tests). The paper step lists the PDF; latexmk's own output is in
`latex/latexmk.log`. A clean build ends there with `Latexmk: All targets (fable_cosmology.pdf) are
up-to-date`, after three pdflatex passes the first time.

**Comparing a re-run with the committed results.** `git diff --stat -- fable-cosmology/results`
lists every result file whose bytes changed. After the runs recorded here it listed **nothing**,
in the working repository and in a fresh clone: all 43 CSV files and all 16 PNG figures of notebooks
01–04 were byte-identical to the committed ones (again on 2026-09-24 and 2026-09-25, after the fermion-fable
work and with notebook 07: the SHA-256 of all 59 equals that of its `HEAD` blob). The result files of
notebooks 05, 06 and 07 are reproducible too: two successive runs wrote byte-identical files (63 of
05 and 06, 27 of 07). Notebook 07 also prints wall-clock times and the process id of its background run,
which change from run to run. Otherwise the notebooks differed only in the execution
timestamps of their cells and in how the kernel's printed output was split into chunks. Their
sources, execution counts, printed text, embedded images and results were identical. In a clone
at another path, the one line that prints the absolute `results directory` also differs. For a
CSV that did change, compare the numbers column by column. Save this as `compare_csv.py` and run
it from the repository root with the file's path, for example
`fable-cosmology/.venv/bin/python compare_csv.py fable-cosmology/results/nb01_exp_lambda1.csv`
(`.venv/Scripts/python.exe` on Windows):

```python
import csv, io, math, subprocess, sys
path = sys.argv[1].replace('\\', '/')        # a path relative to the repository root
keep = lambda rows: [r for r in rows if r and not r[0].startswith('#')]    # fable_fermion CSVs start with '#' lines
old = keep(csv.reader(io.StringIO(subprocess.run(['git', 'show', f'HEAD:{path}'], capture_output=True, text=True, check=True).stdout)))
new = keep(csv.reader(open(path, newline='')))
if len(old) != len(new):
    print(f'row counts differ: committed {len(old)}, now {len(new)}')

def num(x):
    try:
        v = float(x)
    except ValueError:
        return None
    return None if math.isnan(v) else v

for j, name in enumerate(new[0]):
    pairs = [(num(a[j]), num(b[j])) for a, b in zip(old[1:], new[1:])]
    d = [abs(x - y) for x, y in pairs if x is not None and y is not None]
    print(f'{name:16s} ' + (f'max |difference| = {max(d):.3e}' if d else '(not numeric)'))
```

Text columns such as `run`, `model` and `class` of the fit tables are reported as
`(not numeric)`.

## 13. Troubleshooting

| symptom | cause and fix |
|---|---|
| `python: command not found` during `setup.sh` (macOS, Linux) | Neither `python3` nor `python` works in that shell. Install Python 3.10 or newer, or create the environment by hand (`python3 -m venv fable-cosmology/.venv`) and run `setup.sh` again (section 2). |
| `error: linker 'link.exe' not found`, or MSVC errors during `cargo build` (Windows) | The Visual Studio C++ build tools are missing. Install the "Desktop development with C++" workload and open a new terminal. |
| `could not find Cargo.toml` or path errors naming `vendor/rustSolveIt` | The engine clone is missing or incomplete. Delete `fable-cosmology/rust/vendor/rustSolveIt` and run the setup again. |
| a build error about the target feature `fma`, or a mismatch in the engine's math library | cargo was run from another directory, so `.cargo/config.toml` was not read. Build from inside `fable-cosmology/rust/fable_cosmo` or `fable-cosmology/rust/fable_fermion`. |
| `The solver binary … does not exist` in a notebook | The setup did not finish. Run it again and wait for `== setup complete`. |
| a notebook cell fails with `AssertionError` | A number the notebook quotes has changed. Read the assertion message. Check that you did not edit `nbgen.py` or the solver, and that the solver was rebuilt (`cargo build --release` in `rust/fable_cosmo`). |
| notebook 04 fails with `results/nb01_cpl_fits.csv is missing` | Run notebooks 01 and 02 first. |
| `Kernel ... not found` or `No such kernel named python3` | Run nbconvert and Jupyter from the `.venv` (`.venv/bin/python -m nbconvert …`), which contains `ipykernel`. |
| nbconvert on Windows prints `RuntimeWarning: Proactor event loop does not implement add_reader …` and `[IPKernelApp] WARNING \| Kernel is running over TCP without encryption` | These are warnings of the zmq and Jupyter libraries on Windows. They do not affect the notebooks, and the run succeeds. |
| `latexmk` in PowerShell says `MiKTeX could not find the script engine 'perl'` | Install Strawberry Perl, or run `$env:Path += ";C:\Program Files\Git\usr\bin"` in that PowerShell window, or use Git Bash. |
| `run_all` stops at the paper with `latexmk failed` | Read `fable-cosmology/latex/latexmk.log` and `fable_cosmology.log`. The usual cause is a missing LaTeX package: let MiKTeX install it, or install `texlive-latex-extra` on Linux. |
| an example writing to `/tmp/...` fails on Windows | The Windows binary does not see Git Bash's `/tmp`. Write to a folder you own, for example `--out results_mine.csv`. |
| `git status` shows the notebooks modified after a run | Expected: the execution timestamps and outputs are rewritten. Compare the result CSVs (section 12). `git checkout -- fable-cosmology/notebooks` restores the committed notebooks. |
| the solver refuses a run with exit code 1 | Read the one-line reason. The refusals are deliberate. `fable_cosmo`: a potential that goes negative, a normalisation target the potential cannot reach (`--no-normalize` with a hand-chosen scale), or an `x0` grid outside `(0, π/12)`. `fable_fermion`: a first-order transition of the Kohn–Sham ground state (repulsive `quadratic`), a non-positive total energy density (`lorentz`), `fable8d --direction backward` (section 14.3). |
| notebook 06 fails with `the Mathematica reference … is missing` | `reference/mathematica_fable4d_mass30eV.csv` or `…_power.csv` is absent. Regenerate them with `wolframscript -file fable-cosmology/reference/make_reference_fermion.wls` (section 15), or restore them with `git checkout`. |
| notebook 07 stops in section 5.3 with `…fermion/waveguide_T16.json is missing` | That file is part of the repository (section 16.1). Restore it with `git checkout -- fable-cosmology/fermion/waveguide_T16.json`, or rebuild it from the Mathematica notebook with `wolframscript -file fable-cosmology/fermion/waveguide_derivation.wls > fable-cosmology/fermion/waveguide_derivation.log` (about 3.5 minutes). |
| notebook 05 or 06 fails in its setup cell (section 5) with an `AssertionError` naming `omega_r0` | The unit system the notebook recomputes from CODATA disagrees with the binary's by more than `1e−9`: the `fable_fermion` binary predates the constants correction of 2026-09-24 (section 14.2). Rebuild it with `cargo build --release` in `rust/fable_fermion`. |

## 14. The fermion-fable solver `fable_fermion`

### 14.1 What it solves

**The field.** The fermion fable is a complex 16-component spinor `Ψ` of anticommuting (Grassmann)
components on the pre-universe, with Dirac conjugate `Ψbar = Ψ^‡ σ16` (`Ψ^‡` the complex-conjugate
transpose, `σ16 = T16[0] T16[1] T16[2] T16[3]` the author's spinor metric). It is the minimal field
that uses `σ16`, propagates, admits a potential `V(s)` of `s = Ψbar Ψ`, and reduces to the classical
real fable of Part VI as its real commuting shadow. Its Lagrangian is the symmetrized one,
`L = Sqrt[|g|] L̂`, `L̂ = (1/(2H)) [Ψbar γ^μ D_μΨ − (D_μΨbar) γ^μ Ψ] − V(s)`, and its field equations are
`γ^μ D_μΨ = H V′(s) Ψ` and `(D_μΨbar) γ^μ = −H V′(s) Ψbar`. It is quantized canonically with `x4` as
time: the anticommutator carries the indefinite form `G = −i σ16 γ⁴` (eight positive, eight negative
directions); the fundamental symmetry `J = −i T16[0] T16[1] T16[2] T16[3] T16[4]` makes the Fock
space positive; the negative-frequency modes form the Dirac sea; each spatial momentum carries
`g = 8` particle states.

**The source.** In the Kohn–Sham mean field the fable is a free Fermi gas of mass `m = W′(σ8)`
(`W(σ) := V(Hσ)`), filling every momentum `|k| < kF` along the observed sheet at zero temperature.
Per 7-volume, with `v = B³C` the hidden volume factor (1 today), `σ8 = σ_KS/v` and

    n = g kF³/(6π²),   σ_KS = (g m/(4π²)) [kF wF − m² asinh(kF/|m|)],
    ε_KS = (g/(16π²)) [kF wF (2kF² + m²) − m⁴ asinh(kF/|m|)],
    P_KS = (g/(48π²)) [kF wF (2kF² − 3m²) + 3m⁴ asinh(kF/|m|)],     wF = Sqrt[kF² + m²],

the fable's energy density and pressures are `ρ_f = ε_KS/v + W − σ8 W′`, `P_obs = P_KS/v + σ8 W′ − W`
(along `x1, x2, x3`) and `P_hid = P_x0 = σ8 W′ − W` (along `x5, x6, x7` and `x0`). The gap equation
`m = W′(σ_KS(m, kF)/v)` is solved at every step. Two identities hold exactly: `ρ_f + P_obs = wF n/v ≥ 0`
(so `w_f = P_obs/ρ_f ≥ −1` wherever `ρ_f > 0`) and `ρ_f + P_hid = ε_KS/v`. The number of fermions per
7-volume dilutes as `A^{−3} v^{−1}`, so `kF = kF0/A`. The solver evaluates the Fermi-sea integrals with
three numerically stable forms (a binomial series for `kF/|m| < 0.6`, the closed forms up to 100, an
ultra-relativistic series above), verified against quadrature to `1e−12`.

**The gravitational field.** Far from the wall `x0 = 0`, the primordial field becomes the
8-dimensional Bianchi-I metric `ds² = C² dz² + A² dx_obs² − dt² − B² dx_hid²` (`t = x4`; the canonical
frame is `A = e^{−a4}`, `B = e^{a4}`, `C = 1`). With `H_X = d ln X/dt`, `Θ = 3H_A + 3H_B + H_C`:

    constraint:   3H_A² + 3H_B² + 9 H_A H_B + 3 H_A H_C + 3 H_B H_C = κ_8 ρ
    evolution:    dH_i/dt + H_i Θ = κ_8 (P_i − T/6),   i = A, B, C,   T = −ρ + 3P_obs + 3P_hid + P_x0
    conservation: dρ/dt + 3H_A (ρ + P_obs) + 3H_B (ρ + P_hid) + H_C (ρ + P_x0) = 0   (each source)

The hidden directions obey `dH_B/dt + H_B Θ = κ_8 F/6` with the driver `F = ρ − 3P_obs + 2P_hid`:
radiation `F = 0`, dust `F = ρ`, any 8-dimensional vacuum energy `F = 2ρ_V`, the fable `F = 2W − σ8W′`.
The sources are radiation (`Ω_r0 A^{−4}/v`, pressure `ρ_r/3` along the observed sheet only), baryons
(`Ω_b0 A^{−3}/v`, dust) and the fable.

**The two models.**

- `fable8d`: the equations above as they stand. Any dust or vacuum energy drives the hidden sheet,
  and the observed Newton constant `G_4 = G_8/V_hid ∝ 1/v` changes by many orders of magnitude: this
  is the **no-go** demonstration. Forward in time only (backward it runs away to the 8-dimensional
  Kasner point; the solver refuses).
- `fable4d`: `fable8d` plus a zero-energy stabilizing stress `P_stab = −F/2` on the `B` and `C`
  directions. Then `H_B = H_C = 0`, `v = 1`, and the observer's equations are exactly the Friedmann
  equations `3H_A² = κρ`, `dH_A/dt = −(κ/2)(ρ + P_obs)`. `P_stab` is a Lagrange multiplier, not a stress
  derived from a field, and it violates the null energy condition along `x0` whenever `F > 0` (for
  dust `ρ + P_C = −ρ_dust/2` for the stabilizer). This is the **physical** model. `fable4d` is
  algebraic in `A`; only the age is integrated. `fable8d --freeze-hidden` integrates the same
  stabilized system with `H_A` evolved and reproduces it (a test).

**What CVODE integrates.** The independent variable is `N = ln A`. `fable8d`: the state
`(ln B, ln C, h_A, h_B, h_C, τ)` with `h_i = H_i A²` and `τ = t/A²` (constant in the radiation era, which
keeps the problem O(1) from `A = 1e−12`); `d ln B/dN = H_B/H_A`, `d ln C/dN = H_C/H_A`,
`dh_i/dN = 2h_i + A² (dH_i/dt)/H_A`, `dτ/dN = −2τ + A^{−2}/H_A`, with `F` and `P_obs − P_hid` formed per
source analytically. `fable4d`: `dτ/dN = −2τ + A^{−2}/H_A(N)`, `H_A² = ρ̂(N)`. CVODE BDF, Newton iteration,
a dense Jacobian, `rtol = 1e−10`, `atol = 1e−12`.

**Normalization.** Every run has `v = 1` today (`B = C = 1` at `A = 1`). `fable4d` closes the budget
today, `ρ_r + ρ_b + ρ_f = 1` at `A = 1`, with one shooting parameter (table below). The forward
`fable8d` is a boundary-value problem (`H_B = H_C = 0` at `a_start`; `H_A = B = C = 1` today): an outer
bracket-and-Brent shooting on the fable's amplitude and, for every trial, an inner secant iteration on
`ln v(a_start)`.

**The interval.** From `a_start` (default `1e−12`, `T = T_CMB/a_start ≈ 235 MeV`) to `A = 1`, defined by
`T_CMB = 2.7255 K`. It should satisfy `a_start ≤ min(1e−10, 0.01 a_nr(m))` — before nucleosynthesis
(`a_BBN`, `T = 1 MeV`), with the fable ultra-relativistic; the solver warns otherwise. The number of
relativistic species `g_*(T)` is not followed.

### 14.2 Units

`ħ = c = k_B = 1`. Time in `1/H0` (`H0 = 1`, `h = 0.674`). Energy densities per 7-volume in
`ρ_c0 = 3H0²M_pl²` (`M_pl` the reduced Planck mass), so the Friedmann constraint reads `H_A² = ρ̂` in
`fable4d`. Masses and momenta in `E_c = ρ_c0^{1/4}`; `σ` and `n` in `E_c³`; `W` in `E_c⁴`. The columns
`m_eff_eV` and `kF_eV` are in eV. `κ_4,0 = κ_8/V_h,0`. Everything is computed in the code from CODATA 2018
and IAU constants; `fable_fermion --constants` prints it:

    h                     = 0.674
    H0                    = 2.1842852411e-18 1/s = 6.8930799924e-11 1/yr = 1.4377226622e-33 eV
    1/H0                  = 1.4507302992e10 yr
    M_pl (reduced, from G)= 2.4353234593e27 eV = 2.4353234593e18 GeV
    rho_c0 = 3 H0^2 M_pl^2= 3.6777719498e-11 eV^4
    E_c = rho_c0^(1/4)    = 2.4626131773e-3 eV   (unit of m, kF; sigma, n in E_c^3; W, rho in E_c^4 = rho_c0)
    1 eV                  = 4.0607270732e2 E_c
    T_CMB                 = 2.7255 K = 2.3486541806e-4 eV;  T_nu0 = 1.6763891605e-4 eV
    Omega_gamma0          = 5.4437728013e-5   (Omega_gamma0 h^2 = 2.4729753331e-5)
    Omega_nu(1 species)0  = 1.2363206389e-5
    Omega_r0 (N_eff=3.046)= 9.2096054673e-5   (Omega_r0 h^2 = 4.1837027333e-5)
    Omega_b0 = 0.02237/h^2 = 4.9243191364e-2
    g (fable states per momentum) = 8
    a_BBN (T = 1 MeV)     = 1.6763891605e-10   (= T_nu0 / 1 MeV)
    a_rec (z = 1090)      = 9.1659028414e-4

(the full output also has the header line and a note on `g_*`). **A correction of 2026-09-24:** the
solver used to compute `H0` in eV with the truncated constant `ħ = 6.582119569e-16 eV s`, and the
reduced Planck mass with `ħ = 1.054571817e-34 J s`; the two differ by 6.1e−10. `HBAR_EV_S` is now
`HBAR_J_S/EV_J`, one CODATA 2018 value for both (the same as the Mathematica reference script). This
moved `E_c` from `2.46261317798907812e-3` to `2.46261317732986325e-3 eV` (−2.7e−10) and `Ω_r0` from
`9.20960545742757834e-5` to `9.20960546728882807e-5` (+1.1e−9). `fermion/crosscheck.py` recomputes the
unit system with the same convention.

### 14.3 The command line

The binary is `fable-cosmology/rust/fable_fermion/target/release/fable_fermion` (`.exe` on Windows).

    fable_fermion fable4d|fable8d --potential NAME [--form NAME] [--param KEY=VALUE ...]
                  [--direction forward|backward] [--a-start A] [--points K] [--out FILE.csv]
                  [--rtol R] [--atol A] [--method bdf|adams] [--branch lowest|positive|negative]
                  [--freeze-hidden] [--no-shoot] [--no-fable] [--omega-b X] [--omega-r X]
    fable_fermion gap --form NAME --param KEY=VALUE ... --kf KF [--v V]
    fable_fermion --constants
    fable_fermion --version

| option | meaning | default |
|---|---|---|
| `fable4d`, `fable8d` | the model: stabilized (physical) or unstabilized (no-go) | required |
| `gap` | solve the gap equation once at `kF` (and `v`) for the potential `--form`: print every root with `m, sigma8, rho8, P_obs, P_hid, gap_residual` (16 significant digits), then the selected root | — |
| `--potential NAME` | `mass`, `lambda-mass`, `power`, `expdamp`, `lorentz`, `quadratic`, `explicit` (table below) | `mass` |
| `--form NAME` | the form of `W` for `--potential explicit`, `--no-shoot` and `gap` | the potential's name |
| `--param KEY=VALUE` | one parameter; repeat for more. A mass may be given in eV as `KEY_ev` or in `E_c` as `KEY` | see below |
| `--direction` | `forward` (from `a_start` to 1) or `backward` (from today; `fable4d` only) | `forward` |
| `--a-start A` | the first scale factor, in `(0, 1)` | `1e-12` |
| `--points K` | output rows, equally spaced in `N`, first and last included (at least 2) | `2001` |
| `--out FILE.csv` | write the CSV there; **without it the CSV goes to standard output** | standard output |
| `--rtol R`, `--atol A` | CVODE's tolerances | `1e-10`, `1e-12` |
| `--method bdf\|adams` | CVODE's family | `bdf` |
| `--branch` | which gap root when there are several: the lowest energy density, the largest positive or the most negative mass | `lowest` |
| `--freeze-hidden` | `fable8d` with the stabilizer (`H_A` evolved by its equation) | off |
| `--no-shoot` | take the potential's parameters and `kf0` (or `kf0_ev`) as given | shoot |
| `--no-fable` | radiation and baryons only (the controls of the no-go runs) | with the fable |
| `--omega-b X`, `--omega-r X` | override `Ω_b0`, `Ω_r0` | the computed values |
| `--kf KF`, `--v V` | `gap` only: the Fermi momentum (in `E_c`) and the hidden volume factor | —, `1` |

**The potentials and their parameters** (`W(σ)` in `E_c⁴`; the "split" potentials impose the dark
matter today: the quasiparticles carry `Ω_qp0 = omega_dm` at the mass `m_today`, so
`kF0` follows from `ε_KS(m_today, kF0) = omega_dm`):

| `--potential` | `W(σ)` | `--param` keys (default) | what is shot so that the budget closes today |
|---|---|---|---|
| `mass` (the author's term) | `m0 σ` | `m0_ev` (1) | `ln kF0` (the fable is all the non-baryonic matter: Einstein–de Sitter) |
| `lambda-mass` | `V0 + m0 σ` | `m0_ev` (1), `omega_dm` (0.265) | `V0`, a bare cosmological constant |
| `power` | `m0 σ + λ σ^ν` | `m_today_ev` (1), `nu` (0.236), `omega_dm` (0.265) | `U_t = (1 − ν) λ σ_t^ν`, the condensate today; then `λ = U_t/((1 − ν)σ_t^ν)`, `m0 = m_today − ν λ σ_t^{ν−1}` (may be negative) |
| `expdamp` | `V0 + m0 σ e^{−σ/s1}` | `m_today_ev` (1), `xt` (1/2.21), `omega_dm` (0.265) | `V0`; `s1 = σ_t/xt`, `m0 = m_today e^{xt}/(1 − xt)` |
| `lorentz` | `V0 + m0 σ/(1 + (σ/s1)²)` | `m_today_ev` (1), `xt` (1/1.5), `omega_dm` (0.265) | `V0`; `s1 = σ_t/xt`, `m0 = m_today (1 + xt²)²/(1 − xt²)` |
| `quadratic` | `V0 + m0 σ + (λ/2) σ²` | `m_today_ev` (1), `gq` (−0.5), `omega_dm` (0.265) | `V0`; `λ = gq m_today/σ_t`, `m0 = m_today (1 − gq)` |
| `explicit` | the `--form`'s `W` | `m0` or `m0_ev`, `v0`, `lam`, `nu`, `s1` | `ln kF0`, after checking that `ρ_f(A = 1; kF0)` is monotonic |

With `--no-shoot` the `W` parameters and `kf0` (or `kf0_ev`) are used as given. Parameter domains: `power`
needs `λ > 0` and `0 < ν < 1`; `expdamp` `m0 > 0`, `s1 > 0` (`0 < xt < 1`); `lorentz` `s1 > 0`. The gap
root is provably unique for `mass`, `lambda-mass`, `power`, `expdamp`, attractive `quadratic` (`λ ≤ 0`) and
for `lorentz` while `n8 ≤ s1`; otherwise all roots are found by a scan and the lowest-energy one is taken.
The solver **refuses** (exit code 1, one-line reason) a run whose ground state jumps between gap branches
(a first-order transition: the repulsive `quadratic`, `gq > 0`), a run whose total energy density becomes
non-positive (`lorentz` with Part VI's `xt`), and `fable8d --direction backward`. The negative-energy and
no-gap-root checks run inside the right-hand side at every internal CVODE step (not on the output rows),
and the onset is bisected in `N` from the last accepted step, so the reason and the onset (`lorentz`:
`N = −0.7597808064`, `a = 0.4677689478`) do not depend on `--points`.

**Standard error.** A run prints its log, one line each: `# normalization: …` (what was shot and to
what value), `# ground-state check: …` (split potentials), `# fable today: …` (the potential after
normalization, `kF0`, `m_eff`, `ρ_qp`, `U`, `ρ_f`, `w_f`), `# result: …` (`H_A`, `B`, `C` today, `q0`, the
age, the largest constraint and gap residuals), `# a_nr …` (where `kF = |m_eff|`, with its class: hot,
warm or cold-like), `# the fable is ultra-relativistic at a_start …`, `# Delta N_eff …` at
nucleosynthesis and recombination, `# stabilizer: …` (`fable4d`), `# unstabilized fable8d (the no-go
test): …` (`fable8d`: `G` ratio, `H_B/H_A` today, `d ln G/dt` against `1e−13`/yr), `# t(A=1) cross-check:
…` (CVODE against Gauss–Kronrod quadrature, `fable4d`), `# the DM/DE split … is a convention`, `# stats:
…` (CVODE steps, right-hand-side evaluations, Newton iterations, error-test failures, Jacobians, wall
time, summed over every integration of the run including the shooting), and the version.

**Exit codes** (checked against the binary): `0` success; `1` a solver or physics error with a one-line
reason starting `fable_fermion:` (the refusals above, CVODE failures, an unknown `gap` form, an
unwritable output file); `2` a usage error: an unknown model, option or potential name, a non-numeric
value, `--points` below 2, `--no-shoot` without `kf0`. The usage lines are printed.

**Examples** (from `fable-cosmology/`; `B=rust/fable_fermion/target/release/fable_fermion`, `.exe` on
Windows; write to a folder you own):

```bash
$B --version
$B --constants
$B fable4d --potential lambda-mass --param m0_ev=30 --out lm30.csv                  # ΛCDM with 30 eV fable dark matter
$B fable4d --potential power --param nu=0.236 --param m_today_ev=100 --out pw.csv    # the fable supplies the dark energy
$B fable8d --potential mass --param m0_ev=100 --out nogo.csv                         # the unstabilized no-go run
$B gap --form quadratic --param m0=0.05 --param lam=20 --kf 1                        # three gap roots
```

The `lambda-mass` run logs, among its lines,

    # result: H_A(A=1) = 1.000000000000000e0, B(1) = 1.000000000000000e0, C(1) = 1.000000000000000e0, q0 = -5.284510e-1, age t0 = 9.5124651250e-1/H0, max |constraint residual| = 4.291e-16, max |gap residual| = 0.0e0, rows with several gap roots = 0
    # a_nr (kF = |m_eff|) = 4.465923e-6 (z_nr = 2.2392e5), a_eq = 2.9307e-4: WARM / not hot (a_nr between 1e-6 and a_eq)
    # Delta N_eff (fable energy density in units of one massless neutrino species): at BBN (a = 1.6764e-10, T = 1 MeV) = 7.179236e-2, at recombination (a = 9.1659e-4) = 1.964725e1
    # t(A=1) cross-check: CVODE 9.512465124959659e-1 vs Gauss-Kronrod quadrature 9.512465131954438e-1 (rel. diff 7.35e-10, quadrature error estimate 2.4e-14)

and the `gap` example prints the roots `m = −2.535353916022531, −0.01640336879334347, 2.644093986040535` and
selects `m = −0.01640336879334347` (the lowest `ρ8 = 0.1012381942988485`).

### 14.4 The CSV files of `fable_fermion`

A CSV starts with `#` comment lines: the version; `# params:` with every normalized parameter on one line
(`model, direction, spec, a_start, omega_r0, omega_b0, freeze, branch, lnB_i, lnC_i, e_c_ev, omega_nu1,
rtol, atol, kf0, potential` and the potential's `m0, v0, lam, nu, s1`), which is machine-readable
(`key=value` separated by spaces); `# spec:`; and one line defining each group of columns. Then a header
line and one row per output point, every number written as `{:.14e}` (15 significant digits). Skip the
`#` lines when reading (numpy's `genfromtxt(..., names=True)` would take the first comment for the
header). The 47 columns:

| column | meaning |
|---|---|
| `N`, `a`, `z` | `ln A`, `A`, `1/A − 1` |
| `t` | the age in `1/H0` (`t(a_start) = 1/(2H_A(a_start))`, then integrated) |
| `B`, `C` | the hidden scale factors (1 today; 1 throughout in `fable4d`) |
| `H_A`, `H_B`, `H_C` | the expansion rates, in `H0` |
| `constraint_residual` | `(S − 3ρ̂)/(3H_A²)`, `S` the pair sum of the constraint |
| `rho_r`, `rho_b`, `rho_f` | energy densities per 7-volume, in `ρ_c0` |
| `P_obs_f`, `P_hid_f` | the fable's pressures along the observed and the hidden directions (`P_x0 = P_hid`) |
| `n_f`, `sigma` | the fable's number density and scalar density `σ8` per 7-volume, in `E_c³` |
| `m_eff`, `kF_over_m` | the gap mass in `E_c`; `kF/\|m_eff\|` (`inf` when `m_eff = 0`) |
| `w_f` | `P_obs_f/rho_f`, the fable's own equation of state |
| `rho_qp`, `w_qp` | the quasiparticles: `ε_KS/v` and `P_KS/ε_KS` |
| `rho_U` | the condensate `W − σ8W′` (`P_hid_f = −rho_U`: an 8-dimensional vacuum energy) |
| `w_DE_eff`, `rho_DE_eff` | `P_obs_f/rho_DE_eff`, `rho_DE_eff = ρ_f − ρ_dust0 A^{−3} v(1)/v`, `ρ_dust0 = m_eff(1) n_f(1)` |
| `Omega_r`, `Omega_b`, `Omega_f`, `Omega_sum` | `ρ_X/H_A²`; `Omega_sum = ρ̂/H_A²` (1 in `fable4d`) |
| `q_dec` | `−1 − (dH_A/dt)/H_A²` |
| `G_ratio` | `1/v = G_4(t)/G_4(today)` |
| `cs2_adiabatic` | `(dP_obs_f/dN)/(dρ_f/dN)` along the solution (analytic, with the differentiated gap equation) |
| `N_eff_extra` | `ρ_f/ρ_ν(1 species)` |
| `P_stab` | `−F/2` in `fable4d` and `--freeze-hidden`; 0 in `fable8d` |
| `rho_DE_inf`, `w_DE_inf` | the dark energy an observer infers: `H_A² − Ω_r0 A^{−4} − Ω_b0 A^{−3} − ρ_dust0 A^{−3}` (cold dark matter subtracted with **today's** mass `m_eff(1)`), and `−1 − (1/3) d ln rho_DE_inf/d ln A` |
| `w_DM_intrinsic`, `w_DM_eff`, `Q` | `P_KS/ε_KS`; `w_DM − σ_KS (dm/dN)/(3ε_KS)`; `σ8 dm/dt`, the energy the condensate hands to the quasiparticles |
| `F_hidden`, `dm_dN` | `ρ − 3P_obs + 2P_hid` (all sources); `dm_eff/dN` |
| `m_eff_eV`, `kF_eV` | the mass and the Fermi momentum in eV |
| `gap_roots`, `branch`, `gap_residual` | the number of gap roots found; the sign of `m_eff`; `(m − W′(σ8))/max(\|m\|, S_W′(σ8))`, `S_W′` = the sum of the magnitudes of the terms of `W′` plus `\|σ8 W″\|` (the round-off scale of `W′`; the residual is at round-off in every phase) |
| `vac_over_rhoc` | `ΔE_vac(m_eff; M = m_eff(1))/v` in `ρ_c0`: the renormalized Dirac-sea energy (relativistic Hartree) that the no-sea functional drops; reported, not in the dynamics |

### 14.5 The tests

From `fable-cosmology/rust/fable_fermion`, `cargo test --release` runs 34 tests in about 45 s:

- 23 unit tests: the unit system against standard values; CVODE forward and backward on an
  exponential; Brent and Gauss–Kronrod; the potentials' derivatives, `U` and `F` against finite
  differences, and the signs the bracket proofs use; the Fermi-sea integrals against Gauss–Kronrod
  quadrature to `1e−12` for `kF/|m|` from `1e−8` to `1e6` and both signs of `m`; the continuity of the
  series and closed forms at the switch points; the non- and ultra-relativistic limits; `ε − 3P = mσ`,
  `ε + P = wF n`, `dρ/dn8 = wF` at the gap; the derivatives along a trajectory; the classical limit of the
  mean field; `w_f ≥ −1` for every potential; the root counts (three for the repulsive quadratic, one for
  every concave `W`); the lowest-energy selection; the `expdamp` pinning `σ8 < s1`; the maximum of the
  no-sea functional at the mass-term root; the minimum of the Walecka functional; the fifth-order zero of
  the Dirac-sea energy; the violation of 8D conservation by a per-3-volume mean field; the Dirac-sea energy
  against high-precision references near and far from the reference mass; the gap residual at round-off in
  massless phases.
- 11 end-to-end tests on real runs written to CSV and read back (`tests/cosmology.rs`): the version
  string; covariant conservation along `fable8d` runs; the constraint residual; the frozen-hidden theorem
  (radiation keeps `H_B = 0`; dust drives it); `fable8d --freeze-hidden` reproduces `fable4d`; backward
  runs (refused for `fable8d`, equal to forward for `fable4d`); physics checks along runs; insensitivity to
  `a_start`; the negative-energy refusal and the first-order transition, both located inside the right-hand
  side independently of the output grid; the gap residual and the Dirac-sea energy at round-off in 1 keV runs.

The expected output ends with `test result: ok. 23 passed` (library), `test result: ok. 11 passed`
(`tests/cosmology.rs`) and two empty test binaries.

### 14.6 The independent cross-check

`fermion/crosscheck.py` re-implements both models in Python without sharing code with the crate: the
unit system from CODATA, every Fermi-sea integral by `scipy.integrate.quad` (not the closed forms), every
gap root by `brentq`, the `fable8d` equations by DOP853 at `rtol = 1e−11`. It runs 13 cases with the
solver, reads each CSV's `# params:` line, re-computes the run on the same grid and compares `w_f`,
`H_A`, `B` and `G`; it also recomputes `H_A = B = C = 1` today independently of the Rust shooting. It
fails (exit code 1) if any difference exceeds `1e−6`. From the repository root (about 10 s):

```bash
fable-cosmology/.venv/Scripts/python.exe fable-cosmology/fermion/crosscheck.py --jobs 6    # .venv/bin/python on macOS, Linux
```

It ends with `CROSSCHECK PASSED: every difference < 1e-06`; the largest difference on 2026-09-24 was
`1.1e−8` (`|ΔG|/G` of the `lambda-mass 30 eV` `fable8d` case). Notebook 06 imports the same functions and
applies them to every one of its runs (section 15). `fermion/report.py` reruns the development parameter
sets and writes `fermion/dev/REPORT_runs.txt` with plots; `fermion/dev/` is not committed.

## 15. The fermion-fable notebooks 05 and 06

Both follow the conventions of section 8. Their launch section also names `rust/fable_fermion`, and
their glossary adds the words of the quantized theory (complex 16-spinor, Grassmann numbers, Dirac
conjugate, anticommutator, Krein space, fundamental symmetry J, Fock space, Dirac sea, Kohn–Sham, gap
equation, Fermi momentum, degenerate gas, `ΔN_eff`, stabilizing stress, null energy condition, Bianchi-I,
hidden sheet, Newton constant variation). They record `metadata.fable_fermion.model`
(`["fable4d", "gap"]` and `["fable4d", "fable8d"]`). Their prose states no numerical result: every
number is printed by a cell, and the summary of 05 and the answers of 06 are composed from the computed
values and displayed as Markdown output, with an assertion behind each qualitative claim.

**05_fermion_fable_quantum_eos** (about 11 s) turns the quantized fermion fable into a fluid:

- 3.1 builds `tau`, `taubar` and `T16` exactly as the Mathematica notebook does and shows that the
  Spin(4,4)-invariant bilinear forms on `R^16` are two symmetric, chirality-diagonal matrices — so a real
  Grassmann 16-spinor with `σ16` has no mass term and no dynamics, a Majorana spinor has no scalar
  bilinear, a Weyl spinor cannot propagate — and that the complex 16-spinor is four Dirac flavours;
- 3.3 checks the quantization: `G` has signature (8, 8); in the `J`-eigenbasis every one of the eight
  positive-frequency modes per momentum has energy `+ω` and scalar density `m/ω`; a hidden-sheet momentum
  above threshold gives complex frequencies;
- 5.1 compares the closed and the stable Fermi-sea forms with adaptive quadrature over
  `1e−8 ≤ kF/|m| ≤ 1e6` (and with the solver's `gap` command); 5.2 `w_KS` from 1/3 to 0; 5.3 the
  thermodynamic identities; 5.4 the non-relativistic limit against Part VI's classical formulas for five
  potentials, showing that the classical `expdamp` and `lorentz` cross `w = −1` while the quantum fable
  never does (the gap pins `σ < min(n, s1)`); 5.5 the uniqueness criterion of the gap equation and the
  three-root, first-order case of the repulsive quadratic; 5.6 the minimax no-sea functional and the
  convex Walecka functional; 5.7 the pre-universe: the gas cools from `w = 1/3` to 0 as `a = e^{−a4}` grows;
  5.8 the Dirac-sea energy of a mass-varying fable, which only a fine-tuned reading of `W` can absorb.

It writes `results/nb05_clifford_table.csv`, `nb05_ks_accuracy.csv/.png`, `nb05_w_ks.csv/.png`,
`nb05_identities.csv`, `nb05_classical_vs_quantum.csv/.png`, `nb05_gap_roots.csv/.png`,
`nb05_minimax.csv/.png`, `nb05_preuniverse_cooling.csv/.png`, `nb05_vacuum_energy.csv/.png`, and two solver
runs, `nb05_fable4d_mass30.csv` and `nb05_fable4d_power0.236_m30.csv`.

**06_fable_primordial_gravity_8d** (about 2 min) solves the coupled system from `a_i = 1e−12` to today:

- section 4 computes the Einstein tensor of the 8D Bianchi-I metric numerically from the metric and
  checks the constraint, the evolution equations, their independence of the hidden sheet's signature and
  the conservation law;
- 5.1 the interval and its insensitivity to `a_i` (`1e−12, 1e−11, 1e−10`);
- 5.2 (a) the author's mass term alone, `m0 = 1, 30, 100, 1000, 2000 eV` (Einstein–de Sitter): `w_DM(a)`
  from 1/3 to 0, `a_nr`, `ΔN_eff` at nucleosynthesis and recombination, `q0`;
- 5.3 (b) `lambda-mass`, `m0 = 30, 100, 1000, 2000 eV`, and the Part VIII reference case
  (`nb06_fable4d_mass30eV.csv`: `--param m0_ev=30 --param omega_dm=0.265 --a-start 1e-10 --points 701`):
  the inferred dark energy is exactly a cosmological constant, CPL `(−1, 0)`;
- 5.4 (c) the potentials with which the fable supplies the dark energy — `power` `ν = 0.236, 0.5`,
  `expdamp`, attractive `quadratic`, each at `m_today = 30, 100 eV`, and the Part VIII mass-varying case
  (`nb06_fable4d_power.csv`: `power`, `ν = 0.5`, `m_today = 100 eV`, `Ω_qp0 = 0.55`, `--a-start 1e-10
  --points 701`): `w_f`, the inferred `w_DE,inf` with its poles and crossings of −1, `m_eff(a)`, `c_s²`,
  `w_DM,eff`, `Q`, the Dirac-sea energy, the stabilizer; and the closed form of the inferred dark energy
  of a massive power law, `w_DE,inf = −(1 − ν)/(1 − ν a^{−3(1−ν)})`, checked against the runs;
- 5.5 three implementations on the two Part VIII cases: CVODE, scipy and Mathematica
  (`reference/mathematica_fable4d_*.csv`);
- 5.6 parameter scans at `m_today = 1 keV` and `100 eV` (`power` `ν = 0.05 … 0.65`, `quadratic`
  `gq = −0.95 … −0.05`, `expdamp` `xt = 0.1 … 0.9`, and `power` `ν = 0.3, 0.5` with `Ω_qp0 = 0.265 … 0.8`),
  90 runs, each cross-checked: where does the fable stay massive through the matter era?;
- 5.7 the mass bounds for a fable that is all of the dark matter: `ΔN_eff`, free streaming (the rms
  velocity matched to the Lyman-α bounds on thermal warm dark matter, Viel et al. 2013 and Iršič et al.
  2017) and the Tremaine–Gunn phase-space bound;
- 5.8 (d) the unstabilized `fable8d` for representative (a) and (b) cases and two controls: `B`, `C`,
  `G(a)/G(1)`, `|d ln G/dt|` today, `ΔG/G` since nucleosynthesis, the approach to the 7-dimensional
  isotropic attractor, the constraint residual; `--freeze-hidden` reproduces `fable4d`;
- 5.9 the refused cases; 5.10 the cross-check of every run with `fermion/crosscheck.py`'s functions
  (quadrature, `brentq`, DOP853), including the covariant conservation of the independently computed fluid;
  5.11 the key tables; section 7 the answers.

It writes the solver's CSV of every kept run (`results/nb06_mass_m{1,30,100,1000,2000}_4d.csv`,
`nb06_lm_m{30,100,1000,2000}_4d.csv`, `nb06_fable4d_mass30eV.csv`, `nb06_power_0.236_m{1,30,100}_4d.csv`,
`nb06_power_0.5_m{1,30,100}_4d.csv`, `nb06_expdamp_m{1,30,100}_4d.csv`, `nb06_quadratic_m{1,30,100}_4d.csv`,
`nb06_fable4d_power.csv`, `nb06_mass_m1_8d.csv`, `nb06_mass_m100_8d.csv`, `nb06_lm_m30_8d.csv`,
`nb06_lm_m1000_8d.csv`, `nb06_radiation_only_8d.csv`, `nb06_radiation_baryons_8d.csv`, 1001 rows each except
the two reference cases, 701), the tables `nb06_runs.csv`, `nb06_cpl_fits.csv` (with Unite's rows),
`nb06_scan.csv`, `nb06_dm_mass_bounds.csv`, `nb06_nogo_8d.csv`, `nb06_ai_insensitivity.csv`,
`nb06_crosscheck.csv`, `nb06_threeway.csv`, and the figures `nb06_a_mass_wdm.png`, `nb06_b_lambda_mass.png`,
`nb06_c_de_potentials.png`, `nb06_c_exchange_vacuum_stabilizer.png`, `nb06_scan.png`, `nb06_scan_cpl.png`,
`nb06_dm_mass_bounds.png`, `nb06_d_nogo_8d.png`. The solver CSVs of notebook 06 take about 27 MB.

**The Mathematica reference of the fermion fable** (optional). From the repository root:

```bash
wolframscript -file fable-cosmology/reference/make_reference_fermion.wls
```

writes `reference/mathematica_fable4d_mass30eV.csv` and `reference/mathematica_fable4d_power.csv` (the Fermi-sea
closed forms and the gap at 40 digits, the age by `NDSolve` at 30 digits; columns `N, a, t, H_A, rho_f,
P_obs_f, w_f, m_eff, sigma, kF_over_m`). Part VIII of the notebook compares them with
`results/nb06_fable4d_mass30eV.csv` and `results/nb06_fable4d_power.csv` when those exist; notebook 06
compares all three implementations.

**The numbers of 2026-09-24** (each printed by the notebooks; the qualitative claims are asserted):

| case | quantity | value |
|---|---|---|
| Fermi sea (05) | stable forms against quadrature, `1e−8 ≤ x ≤ 1e6`; against the solver | `9.9e−14`; `3.1e−14` |
| quantum vs classical (05) | smallest quantum `w`; classical `expdamp`, `lorentz` minima | `−0.99957`; `−1.3020`, `−1.2481` |
| repulsive quadratic `(0.05, 20)`, `kF = 1` (05) | gap roots; ground state | `−2.53535, −0.0164034, 2.64409`; `m = −0.0164034` |
| Dirac sea (05) | `g M⁴/(64π²) > ρ_c0` above; power 0.236, 30 eV, `a ≥ 0.3` | `M = 7.34 meV`; `1.31e13 ρ_total` |
| mass term, 1 / 30 / 100 / 1000 / 2000 eV (06) | `a_nr`; `ΔN_eff(BBN)`; `q0` | `6.37e−4 / 6.84e−6 / 1.37e−6 / 6.37e−8 / 2.53e−8`; `36.75 / 0.394 / 0.0792 / 0.00368 / 0.00146`; `0.50005` (Einstein–de Sitter) |
| `lambda-mass` 30 / 100 / 1000 / 2000 eV (06) | `a_nr`; `ΔN_eff(BBN)`; CPL of `w_DE,inf` | `4.47e−6 / 8.97e−7 / 4.16e−8 / 1.65e−8`; `0.0718 / 0.0144 / 6.69e−4 / 2.66e−4`; `(−1.000000, 0.000000)` |
| `ΔN_eff` fit (06) | `ΔN_eff(BBN)`; bound `< 0.3` (`< 0.2`) | `6.692 (m/eV)^{−4/3}`; `m > 10.26 eV` (`13.91 eV`) |
| free streaming, Tremaine–Gunn (06) | fable mass matching thermal WDM of 3.3 / 5.3 keV; TG for two illustrative dwarfs | `1125 / 1807 eV`; `231 / 358 eV` |
| `power` `ν = 0.236`, 30 eV (06) | `a_nr`; CPL of `w_f`; pole of `w_DE,inf` (formula `ν^{1/(3(1−ν))}`); min `c_s²`; Dirac sea at `a ≥ 0.3` | `2.22e−5`; `(−0.783, +0.445)`; `0.5327` (`0.5326`); `−0.611`; `1.31e13 ρ_total` |
| `power ν = 0.5`, `expdamp`, `quadratic`, 30 and 100 eV (06) | `a_nr` (massless until then); min `c_s²` | `0.669`, `0.712`, `0.643`; `−27`, `−21.8`, `−47.1` |
| Part VIII power case (06) | `m_eff` from `a = 1e−10` to today; `w_f(1)`; `q0`; min `c_s²` | `27.15 → 100 eV`; `−0.4215`; `−0.1010`; `−0.364` |
| scans (06) | points massive through `1e−3 ≤ a ≤ 0.3`; all of them | `28 of 90`; power laws with bare `m0 > 0`, all with `c_s² < 0` |
| three implementations (06) | largest CVODE–Mathematica difference (`t`); scipy–Mathematica (`H_A`) | `2.4e−9`; `3.4e−11` |
| cross-check (06) | largest difference over 29 kept and 90 scan runs; conservation residual | `1.1e−8`; `1.2e−7` |
| `fable8d` no-go (06) | `G(a_i)/G(1)` for mass 1 eV, mass 100 eV, `lambda-mass` 30 eV, 1 keV; `\|d ln G/dt\|` today | `3.44e10, 1.85e17, 1.05e12, 1.07e12`; `2.76e−10 /yr` (bound `1e−13`) |

**The answers of notebook 06, in brief.** [1] A time-varying dark-energy `w`: formally yes, in the
stabilized model with a mass-varying potential, but in no run a viable one: with a bare `Λ` the inferred
dark energy is a cosmological constant; with a mass-varying potential the fable's own `w_f` never goes below
−1, while the observer-inferred dark energy has a pole and is phantom and crosses −1 (apparent, from the
dark-sector energy exchange); the fable is massless through the matter era unless it is a power law with
a positive bare mass, and every massive case has a negative adiabatic sound speed; the neglected Dirac-sea
energy exceeds the total density by 1e13 or more; the stabilizer violates the null energy condition; and
without it the Newton constant varies far beyond the bounds. [2] A time-varying dark-matter `w`: yes,
intrinsically, from 1/3 to 0 around `a_nr ∝ m^{−4/3}`, but for the masses that free streaming and phase
space allow (about 1 keV and above) the change happens around `a_nr ≈ 4e−8` (1 keV) to `2e−8` (2 keV), long before recombination. The
dark-matter/dark-energy split of the fable is a convention (its condensate is an 8-dimensional vacuum
energy).

## 16. The wall states and notebook 07

Notebooks 05 and 06 treat the fermion fable as a homogeneous gas. Notebook 07 asks what its
**ground state and first excited states** are, first in a homogeneous region and then along the
hidden coordinate `x0` of the primordial gravitational field, near the end `x0 = 0` of that
coordinate (the **wall**). It uses the ideas of density functional theory (DFT). It runs two programs:
`fable_fermion` (sections 14 and 15) and the wall-state solver `fermion/waveguide.py`.

### 16.1 The wall-state solver `fermion/waveguide.py`

`waveguide.py` is a documented Python module and command-line tool. It needs only numpy and scipy from
`.venv`, so there is nothing to build. It solves the Dirac equation of the fermion fable along `x0` on
the canonical frame of the Mathematica notebook, with `x4` fixed and `a4` frozen (0 in the numerics,
`H = 1`). With the proper distance `z = −ln Cos(6Hx0)/(6H)` and `Ψ = Sqrt[Sin(6Hx0)] Ψ′(z) e^{i k x1 − i ω x4}`,
the sixteen components split exactly into eight 2×2 blocks. In each block `(f, g)` obeys

    f′ = −s K(z) f + (m + ω) g,     g′ = s K(z) g + (m − ω) f,     K(z) = K_inf (1 − e^{−12Hz})^{1/12},

with `s = +1` in the irrep `w3 = −i` and `s = −1` in `w3 = +i`. The wall `z = 0` is a curvature
singularity at finite proper distance, but the rescaled operator is regular there, so a boundary
condition has to be chosen. The two covariant choices are the MIT walls `T16[0]Ψ = ±Ψ` (`f = ±g`). The
**same-sign** wall is `T16[0]Ψ = sign(m)Ψ`; the **opposite-sign** wall is the other one. The solver
counts the levels exactly with the Prüfer angle. It finds them with DOP853 (the reference) and with a
fourth-order Magnus propagator (for scans). On top of that it runs a local-density Kohn–Sham
self-consistency for `W(σ) = m0 σ + (λ/2) σ²` along `z`.

Its companion files are committed next to it:

- `fermion/waveguide_derivation.wls` loads Input cells 1–117 of the Mathematica notebook and derives the
  wall problem from the notebook's own `T16`, curved gammas and spinor covariant derivative. Its output,
  `fermion/waveguide_derivation.log`, ends with `94 checks, 94 PASS, 0 FAIL`. The same run exports the
  matrices `T16`, `σ16` and the block basis `U` to `fermion/waveguide_T16.json`.
- `fermion/waveguide_T16.json` is that export, the one input file of the solver's validation.
- `fermion/waveguide_check.wls` is an independent Mathematica cross-check (`NDSolve` at 30 digits).
  It compares with the Python levels in `fermion/dev/waveguide_levels_reference.csv`, which is not
  committed. In a fresh clone, write that table first with `$PY waveguide.py reference`, then run
  `wolframscript -file fable-cosmology/fermion/waveguide_check.wls` from the repository root. It ends
  with `11 checks, 11 PASS, 0 FAIL`.
- `fermion/waveguide_REPORT.txt` is the solver's report: the derivation, the method, the tables, the
  Mathematica comparison and the Kohn–Sham runs.

**Commands.** Run them from `fable-cosmology/fermion` (Git Bash on Windows: `PY=../.venv/Scripts/python.exe`;
macOS and Linux: `PY=../.venv/bin/python`):

```bash
$PY waveguide.py validate                      # 64 checks; reads waveguide_T16.json (see below)
$PY waveguide.py levels --K 80 --m 1 --wall same
$PY waveguide.py threshold                     # K_c(1), K_c(2) versus m/H
$PY waveguide.py figures                       # dispersion, edge band, theta family, wavefunctions
$PY waveguide.py dft                           # the Kohn-Sham runs at full resolution (about 9 minutes)
$PY waveguide.py dft --scenario bulk           # is homogeneous matter self-bound? (about a second)
$PY waveguide.py -h                            # every command and option
```

The commands that write tables write them to `fermion/dev/`, with the prefix `waveguide_`. That folder is
**not committed**. Notebook 07 copies what it uses into `results/nb07_*`.

**The file `fermion/waveguide_T16.json` is committed.** It holds the notebook's matrices `T16[0..8]`,
`σ16` and the block basis `U`. `validate` needs it for its 16-component checks (V7) and its block-basis
check (V8). Notebook 07 and `waveguide_check.wls` read it too. So in a fresh clone, `validate` and
notebook 07 run without Mathematica. To rebuild the file from the Mathematica notebook, run the
derivation from the repository root (about 3.5 minutes). It writes the same bytes again:

```bash
wolframscript -file fable-cosmology/fermion/waveguide_derivation.wls > fable-cosmology/fermion/waveguide_derivation.log
```

If the file is missing, notebook 07 stops in section 5.3 with a message that names this command.
`validate` records one `FAIL` for V7 and one for V8 (`file missing`, with this command), still runs its
other checks, and exits with status 1. It exits with status 1 whenever any check fails, and 0 only
when all 64 pass.

### 16.2 Notebook 07: `07_fable_dft_states`

It follows the conventions of section 8. It records `metadata.fable_fermion.model = ["gap", "fable4d",
"waveguide"]`. Its launch section also names `fermion/waveguide.py`. Its glossary adds the words of DFT
and of the wall problem: Hohenberg–Kohn theorem, Kohn–Sham reference system, exchange–correlation energy,
local-density approximation, self-consistent field, ΔSCF, Walecka functional, minimax, particle–hole
excitation, pair continuum, wall, proper distance, transverse momentum, self-adjoint extension, MIT
condition, irrep, Prüfer angle, threshold, edge state, band, surface density and Fermi level. The checker
verifies them. As in 05 and 06, the prose states no numerical result. Every number is printed by a cell,
and the closing summary is composed from the computed values.

**Running time.** It took about 9 minutes on the development machine. Its helper cell starts
`python fermion/waveguide.py dft` (the full-resolution Kohn–Sham runs, about 9 minutes) in the background, with
its output going to `fermion/dev/nb07_waveguide_dft_full.log`. The other cells run meanwhile. The cell of
section 5.17 waits for that background run to finish. It is the one cell of the project allowed to take
more than a minute (`CONVENTIONS.md`).

**What it does.**

- 3–4 density functional theory for the fable. The densities are `n` and `σ`, and the Kohn–Sham reference
  is a free Fermi gas of mass `m`. The exchange–correlation energy is neglected; for a contact interaction
  it is `1/g` of the Hartree energy only when `kF ≪ m`. Then the wall problem and the Kohn–Sham equations
  along `x0`. §4.1 says what is handed to SUNDIALS (only `fable4d`'s `dτ/dN`) and what `waveguide.py`
  integrates instead.
- 5.1 the homogeneous ground state. The no-sea functional of `W = 2σ` has a **maximum** at the gap root,
  with curvature `−1/χ`. The Walecka functional of `W = σ − 10σ²` is convex, with its minimum at the gap
  root. The repulsive `W = 0.05σ + 10σ²` has one root below the uniqueness bound and three at `kF = 1`,
  where the lowest `ρ` selects the ground state. `fable_fermion gap` finds the same roots.
- 5.2 the homogeneous excitations. Particle–hole pairs are gapless. The pair continuum starts at `2wF`
  for `Q = 0` and is lowest, at `wF + |m|`, for `Q = kF`. Brute force is compared with the closed forms.
- 5.3 the derivation's key PASS lines, quoted from its log. `T16` is built in the notebook and compared
  with the exported matrices, and `waveguide.py validate` must report 64 of 64.
- 5.4 the wall conditions `P = T16[0]Q`: only `Q = ±1` (MIT±) are covariant, `J`-compatible and
  charge-conjugation invariant.
- 5.5 `S(K) = A(K) ∪ (−A(K))`, and every level is 4-fold, counted in the 16-component problem with the
  notebook's own `T16`.
- 5.6 the thresholds `K_c(1)`, `K_c(2)` versus `m/H`.
- 5.7 the dispersion `ω_n(K)`, `n = 0…3`, with the `K = 80` levels compared with Mathematica.
- 5.8 the gapless edge band of the opposite-sign wall and its slope `(m/6H) B(m/6H, 13/12)`.
- 5.9 the family of self-adjoint walls `θ`.
- 5.10 the wavefunctions `n = 0, 1` at `K = 80`.
- 5.11 the free theory: the author's mass term.
- 5.12 the opposite-sign wall with `λ = −0.01` and `−10`: a variationally consistent ground state.
- 5.13 the same-sign wall with `λ = −0.01`, `N_s = 100`: a converged configuration that is not a
  variational minimum, and why (the band-threshold term).
- 5.14 the band gap at fixed `k`.
- 5.15 ΔSCF first excited states.
- 5.16 strong attraction (`λ = −100`): the self-consistency fails, and the wall repels the layer.
- 5.17 the comparison with the full-resolution run.
- 5.18 the cosmological `fable4d` runs follow the homogeneous Kohn–Sham ground state at every epoch.
- Section 7: what these states mean for the cosmology.

**Resolution.** The same-sign Kohn–Sham runs of the notebook use a reduced resolution: `h_near = 0.006/H`,
12 Gauss–Legendre nodes, and 21 k-points on `[0, 20]` (41 on `[0, 40]` for ΔSCF), where the solver uses
`0.003/H`, 16 nodes and 41 (81) points. The opposite-sign runs use the solver's full resolution. Section
5.17 prints both sets of numbers and writes them to `results/nb07_dft_comparison.csv`.

It writes `results/nb07_homogeneous.csv/.png`, `nb07_excitations.csv/.png`, `nb07_wall_conditions.csv`,
`nb07_levels_K80.csv`, `nb07_thresholds.csv/.png`, `nb07_dispersion_same.csv`, `nb07_dispersion.png`,
`nb07_edge_band.csv/.png`, `nb07_theta.csv/.png`, `nb07_wavefunctions.csv/.png`, `nb07_free_levels.csv`,
`nb07_ks_opposite.csv`, `nb07_ks_same.csv`, `nb07_band_gap.csv`, `nb07_dscf.csv`, `nb07_ks_profiles.png`,
`nb07_strong.csv/.png`, `nb07_dft_full.csv`, `nb07_dft_comparison.csv` and `nb07_cosmology_link.csv`
(18 CSV files and 9 PNG figures).

**The numbers of 2026-09-24** (each one printed by the notebook; the qualitative claims are asserted):

| case | quantity | value |
|---|---|---|
| no-sea functional, `W = 2σ`, `kF = 1.5` (5.1) | `E_n` at the gap root `= ρ`; `d²E_n/dσ²` there, `−1/χ`; `E_n/n` as `σ → −n` | `1.052962`; `−21.2496`, `−21.2493` (a maximum); `−1.99948` |
| Walecka functional, `W = σ − 10σ²`, `kF = 1` (5.1) | the one gap root `m*`; `Ω(m*) = ρ` | `0.2112489356`; `0.1211932853` (the minimum) |
| repulsive `W = 0.05σ + 10σ²` (5.1) | uniqueness bound on `kF`; roots at `kF = 1`; ground state | `0.496729`; `−2.53535, −0.0164034, 2.64409`; `m = −0.0164034` |
| excitations, `m = 1`, `kF = 1.5` (5.2) | pair threshold at `Q = 0` (`2wF`); lowest pair threshold (`wF + \|m\|`, at `Q = kF`); particle–hole threshold for `Q ≤ 2kF` | `3.605551`; `2.802776`; `0` |
| wall problem (5.3) | derivation checks; `waveguide.py validate` | `94 of 94 PASS`; `64 of 64 PASS` |
| same-sign wall thresholds, `m = H` (5.6) | `K_c(1)` (irrep −i); `K_c(2)` (irrep +i); growth of `K_c(1)` over `m/H = 0.25 … 8` | `6.70624065`; `33.91895851`; `∝ (m/H)^0.468` |
| same-sign wall, `K = 80`, `m = H` (5.5, 5.7) | positive levels, each 4-fold; largest difference from Mathematica | `70.985307230, 78.144249332, 79.371495779, 79.987308552`; `4.7e−11` |
| opposite-sign wall, `m = H` (5.8) | edge-band slope `(m/6H) B(m/6H, 13/12)` (solver at `K = 1e−4`); `K*` where the edge level reaches `m0`; largest `N_s` below `m0` | `0.980822733` (`0.980822728`); `1.01971543`; `0.071622` |
| wavefunctions, `K = 80` (5.10) | `∫(f² − g²) dz` of `n = 0`, `n = 1` | `0.24150473`, `0.01572127` |
| free theory (5.11) | lowest same-sign wall level above `m0` | at least `5.780388` above `m0 = 1` |
| opposite-sign Kohn–Sham, `N_s = 0.05`, `λ = −0.01` / `−10` (5.12) | `μ`; `E/A`; `(E/N)/((3/4)μ)`; Walecka curvature | `0.8871343842` / `0.8870591549`; `0.033268937058` / `0.033267529405`; `1.000042` / `1.000085`; `5.6e−13` / `5.6e−10` |
| same-sign Kohn–Sham, `λ = −0.01`, `N_s = 100` (5.13, reduced resolution; 5.17 full resolution) | `E/A`; `μ`; band bottom `k_lo`; Walecka slope; threshold term | `937.22904` (`937.22774`); `11.695904` (`11.695899`); `5.459020` (`5.458985`); `−48.3041` (`−48.3058`); `−48.3045` (`−48.3062`) |
| the same with `Z = 45/H` (5.13) | `E/A`; `σ(20)/σ(10)` | `937.06108`; `0.2529` (an inverse-square tail) |
| band gap in the self-consistent potential (5.14) | `ω1 − ω0` at `k = 34, 40, 60, 80` (bare wall) | `2.085134, 2.780245, 5.023683, 7.184858` (`2.052432, 2.753163, 4.996295, 7.158942`) |
| ΔSCF (5.15; 5.17 full resolution) | `ΔE` per promoted fermion, `x = 0.01, 0.05, 0.1, 0.2` | `20.7514, 20.9188, 21.1250, 21.5296` (`20.7513, 20.9188, 21.1251, 21.5297`) |
| strong attraction, `λ = −100`, `N_s = 0.03` (5.16) | homogeneous matter self-bound; after 12 iterations `μ`, residual; `Ω` of the shifted well at `z_c = 0.6` and `6` | for `λ ≤ −80` of the values scanned; `0.877390`, `4.1e−2` (not converged); `0.032105` → `0.028720` |
| cosmology (5.18) | largest `\|m_solver − m_ground state\|/m_today` for `power ν = 0.236` and `quadratic gq = −0.5` (30 eV, 201 epochs); `\|Δρ\|/ρ` | `1.5e−15`, `1.9e−15`; `1.5e−14` |
