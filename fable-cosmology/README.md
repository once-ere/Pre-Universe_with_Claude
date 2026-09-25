# fable-cosmology: the numerical cosmology of fableScalar and fable

This folder holds everything needed to set up, run, check and reproduce the numerical side of
the work on two fields on the 4+4 pre-universe of Patrick L. Nash:

- **fableScalar** is a real scalar field `φ` with a self-interaction potential `V(φ)`, inspired by
  quintessence. Its equation of state is called `wScalar`.
- **fable** is a real 16-component spinor field `Ψ` with a self-interaction potential `V(s)` of
  its scalar bilinear `s = Ψᵀ σ16 Ψ`. Its equation of state is called `w`.

The work produces a solver, `fable_cosmo`, written in Rust on the pure-Rust SUNDIALS 7.8.0 CVODE
of the author's rustSolveIt repositories. Four Jupyter notebooks drive the solver, plot the
results and check them. A paper, `latex/fable_cosmology.pdf`, states the physics and the results.
There are also two scripts that set everything up and reproduce everything.

This page is complete on its own. It assumes you have never used Rust, Jupyter or LaTeX. Follow
sections 2 to 4 in order and you will have every result on your own machine. Sections 5 to 12
explain each piece in detail.

**Contents.** 1 What is here · 2 What you need · 3 Setup, once · 4 Reproduce everything with one
command · 5 The physics the solver integrates · 6 The solver `fable_cosmo` · 7 The CSV files ·
8 The notebooks · 9 The tests and checks · 10 The paper · 11 The Mathematica reference (optional)
· 12 The numbers you should get · 13 Troubleshooting

---

## 1. What is here

| path (inside `fable-cosmology/`) | what it is |
|---|---|
| `setup.sh`, `setup.ps1` | one-time setup: Python virtual environment, a sparse clone of the rustSolveIt engine for your platform, the release build of the solver, and a smoke test |
| `run_all.sh`, `run_all.ps1` | reproduce everything: solver tests, every notebook executed, the notebook checker, the paper |
| `requirements.txt` | the Python packages: numpy, scipy, matplotlib, jupyter, nbconvert, nbclient, ipykernel |
| `rust/fable_cosmo/` | the solver crate: `Cargo.toml`, `.cargo/config.toml` (the FMA pin), `src/main.rs` (command line, output), `src/models.rs` (the equations), `src/potentials.rs` (the potentials), `src/cvode_driver.rs` (the CVODE driver), with 7 unit tests |
| `rust/vendor/rustSolveIt/` | **made by the setup, not committed**: the sparse clone of the rustSolveIt engine (`sundials_rs` only) |
| `rust/fable_cosmo/target/` | **made by the build, not committed**: cargo's build directory; the solver binary is `target/release/fable_cosmo` (`fable_cosmo.exe` on Windows) |
| `.venv/` | **made by the setup, not committed**: the Python virtual environment |
| `notebooks/01_fableScalar_quintessence.ipynb` | Models A and A′: fableScalar in the standard 4-dimensional reference cosmology and on the Unite CPL background |
| `notebooks/02_fable_spinor.ipynb` | Model B: fable in the reference cosmology, including dust and the crossing of `w = −1` |
| `notebooks/03_pre-universe_dynamics.ipynb` | Models C and D: fableScalar on the 8-dimensional pre-universe itself (Model E stated) |
| `notebooks/04_dark_matter_dark_energy.ipynb` | the synthesis: the best cases, the figures, and the answers about dark matter and dark energy |
| `notebooks/_build/nbgen.py` | the generator of the four notebooks (the notebooks are generated, never edited by hand) |
| `notebooks/_build/nbcheck.py` | the checker of the eight notebook requirements |
| `notebooks/_build/CONVENTIONS.md` | the conventions the generator encodes (their content is in section 8 of this page) |
| `results/` | every CSV and PNG the notebooks write: 43 CSV files and 16 PNG figures, committed as the evidence |
| `reference/make_reference.wls` | the Mathematica `NDSolve` reference integrations (optional, section 11) |
| `reference/mathematica_scalar_exp.csv`, `reference/mathematica_spinor_expdamp.csv` | their output, committed |
| `latex/fable_cosmology.tex` | the paper's source |
| `latex/fable_cosmology.pdf` | the compiled paper (24 pages) |
| `latex/figures/` | the 16 PNG figures of the paper, copies of the ones in `results/` |
| `DESIGN.md` | the design specification (revision 2) the work was built to; everything a student needs from it is on this page |

The Mathematica side of the work lives outside this folder. Part VI of the notebook
`claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb` (Sections 23–25) proves the symbolic
results that the numerics rely on. Its manifest is `claude-fable/cells_part6.wl`.

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

**On macOS and Linux, read this before the setup.** `setup.sh` creates the virtual environment
with the command `python`. Many macOS and Linux systems only have `python3`. If `python --version`
fails for you, create the environment yourself first. The setup then finds it and skips that
step:

```bash
cd "$(git rev-parse --show-toplevel)"
python3 -m venv fable-cosmology/.venv
```

**Optional.** Wolfram Mathematica (developed with 15.0.1) and its `wolframscript`. You only need
it to regenerate the two reference CSVs or to re-run Part VI of the notebook (section 11). You do
not need it for anything else.

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
is already in place. It does three things.

1. **Python.** It creates `fable-cosmology/.venv` (unless it exists) and installs
   `requirements.txt` into it with pip. Then it imports the packages and prints
   `python ok: numpy … scipy … matplotlib …`.
2. **The engine.** It picks the rustSolveIt repository for your platform (table in section 2)
   and makes a sparse clone of it into `fable-cosmology/rust/vendor/rustSolveIt`. The clone uses
   `git clone --depth 1 --filter=blob:none --sparse`, then
   `git sparse-checkout set sundials_rs`. Only the vendored pure-Rust SUNDIALS 7.8.0 is fetched,
   in a few seconds. The script prints `== engine: <url> @ <commit>`.
3. **The solver.** It runs `cargo build --release` in `fable-cosmology/rust/fable_cosmo`. The
   first build compiles the engine's two crates and the solver; on the development machine that
   took 5 s, and the whole setup, including pip and the clone, took 80 s. Then it runs the
   binary with `--version`, which must print

       fable_cosmo 0.1.0, sundials_rs 7.8.0 (pure Rust), CVODE BDF

   and finally `== setup complete`.

The solver crate uses the engine the same way rustSolveIt's own `planet_Mercury/mercury_rs`
does. It has path dependencies on `../vendor/rustSolveIt/sundials_rs/crates/sundials_core` and
`…/cvode_rs`. It also pins `-C target-feature=+fma` in its own `.cargo/config.toml` for x86-64,
because the engine's deterministic math library requires it. Cargo reads that file from the
directory it is invoked in, so **build the solver from inside `rust/fable_cosmo`**, as the
scripts do.

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

1. `cargo test --release` in `rust/fable_cosmo`: the 7 unit tests of the solver (section 9).
   `run_all.sh` shows only the last three lines of the test output; `run_all.ps1` shows all of it.
2. It executes every notebook, in the order 01, 02, 03, 04, headlessly and **in place**:
   `python -m nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=1800
   --ExecutePreprocessor.kernel_name=python3 notebooks/0N_….ipynb`. Every CSV and PNG under
   `results/` is rewritten, and the outputs are written back into the `.ipynb` files.
3. `python notebooks/_build/nbcheck.py`: the eight-requirement check of the four notebooks.
4. `latexmk -pdf -interaction=nonstopmode -halt-on-error fable_cosmology.tex` in `latex/`,
   with all of latexmk's output going to `latex/latexmk.log`. Then it lists
   `latex/fable_cosmology.pdf`.

It ends with `== all done`. `run_all.sh` stops at the first failure, because it runs under
`set -euo pipefail`. `run_all.ps1` throws on a failing notebook, checker or paper build, but not
on a failing `cargo test`, so read step 1's output there. On the development machine the whole
run took 51 s in the working repository and 61 s in a fresh clone. In the fresh clone the setup
before it took 80 s, including pip and the engine clone over the network. What it prints is in section 12.

Because step 2 re-executes the notebooks in place, `git status` shows them as modified
afterwards. The execution timestamp of every cell changes on every run, and the kernel may split
a cell's printed output into chunks differently. Their content (printed text, figures, results)
does not change. `git status` also shows any result file whose bytes changed. How to compare the
numbers is in section 12.

## 5. The physics the solver integrates

This section is a summary. The paper (`latex/fable_cosmology.pdf`) gives the derivations.

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
.venv/bin/python notebooks/_build/nbgen.py          # writes all four, unexecuted
.venv/bin/python notebooks/_build/nbgen.py 02       # or just one
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
- Every run is cross-checked with scipy DOP853 at `rtol = 1e−11` and must agree in `w` to `1e−6`.
- The CPL fit is `numpy.polyfit` on `1 − a` over `0.3 ≤ a ≤ 1`.
- There are no random numbers.
- Result files are named by notebook number.
- The two interactive cells are tagged `interactive`.
- `metadata.fable_cosmo.model` records the solver models the notebook runs.

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

The expected last line is `4/4 notebooks pass all eight requirements`, with exit code 0.

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
`cp results/*.png latex/figures/`.

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

**What `run_all.sh` printed** on the development machine (Windows 11, Git Bash, 2026-09-24):

    == 1. solver tests

    test result: ok. 7 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

    == 2. notebooks
       executing notebooks/01_fableScalar_quintessence.ipynb
    [NbConvertApp] Converting notebook notebooks/01_fableScalar_quintessence.ipynb to notebook
    C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\fable-cosmology\.venv\Lib\site-packages\zmq\_future.py:718: RuntimeWarning: Proactor event loop does not implement add_reader family of methods required for zmq. Registering an additional selector thread for add_reader support via tornado. Use `asyncio.set_event_loop_policy(WindowsSelectorEventLoopPolicy())` to avoid this warning.
      self._get_loop()
    [IPKernelApp] WARNING | Kernel is running over TCP without encryption. All communication (including code and outputs) is sent in plain text and is susceptible to eavesdropping. Use IPC transport or launch with kernel manager-provisioned CurveZMQ keys to enable transport encryption.
    [NbConvertApp] Writing 475039 bytes to notebooks\01_fableScalar_quintessence.ipynb
       executing notebooks/02_fable_spinor.ipynb
    [NbConvertApp] Converting notebook notebooks/02_fable_spinor.ipynb to notebook
    C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\fable-cosmology\.venv\Lib\site-packages\zmq\_future.py:718: RuntimeWarning: Proactor event loop does not implement add_reader family of methods required for zmq. Registering an additional selector thread for add_reader support via tornado. Use `asyncio.set_event_loop_policy(WindowsSelectorEventLoopPolicy())` to avoid this warning.
      self._get_loop()
    [IPKernelApp] WARNING | Kernel is running over TCP without encryption. All communication (including code and outputs) is sent in plain text and is susceptible to eavesdropping. Use IPC transport or launch with kernel manager-provisioned CurveZMQ keys to enable transport encryption.
    [NbConvertApp] Writing 532514 bytes to notebooks\02_fable_spinor.ipynb
       executing notebooks/03_pre-universe_dynamics.ipynb
    [NbConvertApp] Converting notebook notebooks/03_pre-universe_dynamics.ipynb to notebook
    C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\fable-cosmology\.venv\Lib\site-packages\zmq\_future.py:718: RuntimeWarning: Proactor event loop does not implement add_reader family of methods required for zmq. Registering an additional selector thread for add_reader support via tornado. Use `asyncio.set_event_loop_policy(WindowsSelectorEventLoopPolicy())` to avoid this warning.
      self._get_loop()
    [IPKernelApp] WARNING | Kernel is running over TCP without encryption. All communication (including code and outputs) is sent in plain text and is susceptible to eavesdropping. Use IPC transport or launch with kernel manager-provisioned CurveZMQ keys to enable transport encryption.
    [NbConvertApp] Writing 1089779 bytes to notebooks\03_pre-universe_dynamics.ipynb
       executing notebooks/04_dark_matter_dark_energy.ipynb
    [NbConvertApp] Converting notebook notebooks/04_dark_matter_dark_energy.ipynb to notebook
    C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\fable-cosmology\.venv\Lib\site-packages\zmq\_future.py:718: RuntimeWarning: Proactor event loop does not implement add_reader family of methods required for zmq. Registering an additional selector thread for add_reader support via tornado. Use `asyncio.set_event_loop_policy(WindowsSelectorEventLoopPolicy())` to avoid this warning.
      self._get_loop()
    [IPKernelApp] WARNING | Kernel is running over TCP without encryption. All communication (including code and outputs) is sent in plain text and is susceptible to eavesdropping. Use IPC transport or launch with kernel manager-provisioned CurveZMQ keys to enable transport encryption.
    [NbConvertApp] Writing 318310 bytes to notebooks\04_dark_matter_dark_energy.ipynb
    == 3. notebook requirements

    4/4 notebooks pass all eight requirements
    == 4. the paper
    -rw-r--r-- 1 nsh 197121 2835881 Sep 24 19:31 fable_cosmology.pdf
    == all done

The two lines that follow each `Converting notebook` line are warnings of the zmq and Jupyter
libraries on Windows. They are not errors, and they do not come from the notebooks. `run_all.sh`
shows only the last three lines of `cargo test`, so the first of them is empty. The paper step
lists the PDF; latexmk's own output is in `latex/latexmk.log`. A clean build ends there with
`Latexmk: All targets (fable_cosmology.pdf) are up-to-date`, after three pdflatex passes.

**Comparing a re-run with the committed results.** `git diff --stat -- fable-cosmology/results`
lists every result file whose bytes changed. After the runs recorded here it listed **nothing**,
in the working repository and in a fresh clone: all 43 CSV files and all 16 PNG figures were
byte-identical to the committed ones. The four notebooks differed only in the execution
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
old = list(csv.reader(io.StringIO(subprocess.run(['git', 'show', f'HEAD:{path}'], capture_output=True, text=True, check=True).stdout)))
new = list(csv.reader(open(path, newline='')))
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
| `python: command not found` during `setup.sh` (macOS, Linux) | Only `python3` exists. Run `python3 -m venv fable-cosmology/.venv`, then `setup.sh` again (section 2). |
| `error: linker 'link.exe' not found`, or MSVC errors during `cargo build` (Windows) | The Visual Studio C++ build tools are missing. Install the "Desktop development with C++" workload and open a new terminal. |
| `could not find Cargo.toml` or path errors naming `vendor/rustSolveIt` | The engine clone is missing or incomplete. Delete `fable-cosmology/rust/vendor/rustSolveIt` and run the setup again. |
| a build error about the target feature `fma`, or a mismatch in the engine's math library | cargo was run from another directory, so `.cargo/config.toml` was not read. Build from inside `fable-cosmology/rust/fable_cosmo`. |
| `The solver binary … does not exist` in a notebook | The setup did not finish. Run it again and wait for `== setup complete`. |
| a notebook cell fails with `AssertionError` | A number the notebook quotes has changed. Read the assertion message. Check that you did not edit `nbgen.py` or the solver, and that the solver was rebuilt (`cargo build --release` in `rust/fable_cosmo`). |
| notebook 04 fails with `results/nb01_cpl_fits.csv is missing` | Run notebooks 01 and 02 first. |
| `Kernel ... not found` or `No such kernel named python3` | Run nbconvert and Jupyter from the `.venv` (`.venv/bin/python -m nbconvert …`), which contains `ipykernel`. |
| nbconvert on Windows prints `RuntimeWarning: Proactor event loop does not implement add_reader …` and `[IPKernelApp] WARNING \| Kernel is running over TCP without encryption` | These are warnings of the zmq and Jupyter libraries on Windows. They do not affect the notebooks, and the run succeeds. |
| `latexmk` in PowerShell says `MiKTeX could not find the script engine 'perl'` | Install Strawberry Perl, or run `$env:Path += ";C:\Program Files\Git\usr\bin"` in that PowerShell window, or use Git Bash. |
| `run_all` stops at the paper with `latexmk failed` | Read `fable-cosmology/latex/latexmk.log` and `fable_cosmology.log`. The usual cause is a missing LaTeX package: let MiKTeX install it, or install `texlive-latex-extra` on Linux. |
| an example writing to `/tmp/...` fails on Windows | The Windows binary does not see Git Bash's `/tmp`. Write to a folder you own, for example `--out results_mine.csv`. |
| `git status` shows the notebooks modified after a run | Expected: the execution timestamps and outputs are rewritten. Compare the result CSVs (section 12). `git checkout -- fable-cosmology/notebooks` restores the committed notebooks. |
| the solver refuses a run with exit code 1 | Read the one-line reason. The refusals are deliberate: a potential that goes negative, a normalisation target the potential cannot reach (`--no-normalize` with a hand-chosen scale), or an `x0` grid outside `(0, π/12)`. |
