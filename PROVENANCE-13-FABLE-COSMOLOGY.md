# Provenance 13 — fableScalar and fable: two quintessence-like fields on the pre-universe, their equations of state, and the numerical solutions

**Effort.** The author's instruction, 2026-09-16, in its operative parts: *"Define a new scalar
field named fableScalar, inspired by Quintessence, … that provides a physical mechanism for a
time-varying dark energy equation of state (wScalar). Define a new 16-component spinor field named
fable, also inspired by a generalization of Quintessence, … a second physical mechanism …
Define, verify and test the correct Lagrangian and energy-momentum tensor for [each]. Then define
its kinetic energy, potential energy, pressure and energy density and w. In detail, investigate
and determine and discuss (use numerical solutions and graphs) … Answer the questions: is there
any connection to dark matter and/or dark energy? Create precise scientific documentation that
provides detailed instructions to an ignorant student for setting up and solving your numerical
solutions, in entirety. If possible, employ Jupyter notebooks from [the three rustSolveIt
repositories] … create complete documentation using markdown files, and also latex files that are
compiled to pdf. Then verify the pushed repo runs from a fresh clone."* The author's observational
reference is his Gmail printout of 2026-09-15 on the CPL parameterisation and the Supernovae
Unite fits (`w = −0.764`; `(w0, wa) = (−0.861, −0.60)`); it stays on his disk, unpublished, and its
content is restated where it is used.

Everything needed to repeat this work is on this page. No other file needs to be consulted.

---

## 0. Where things are

| what | where |
|---|---|
| the design specification (revision 2, after the review) | `<repo>/fable-cosmology/DESIGN.md` |
| the solver (pure-Rust SUNDIALS 7.8.0 CVODE, from the rustSolveIt repositories) | `<repo>/fable-cosmology/rust/fable_cosmo/` |
| the four Jupyter notebooks, their generator and checker | `<repo>/fable-cosmology/notebooks/`, `notebooks/_build/` |
| the results the notebooks write (CSV, PNG) | `<repo>/fable-cosmology/results/` |
| the Mathematica reference integrations | `<repo>/fable-cosmology/reference/` |
| the paper | `<repo>/fable-cosmology/latex/fable_cosmology.tex` → `fable_cosmology.pdf` |
| the student documentation | `<repo>/fable-cosmology/README.md` |
| Part VI of the Mathematica notebook (Sections 23–25) | `<repo>/claude-fable/cells_part6.wl` → the rebuilt `claude-fable_Einstein-Rosen-2-Planes.nb` |
| setup and reproduction scripts | `<repo>/fable-cosmology/setup.sh`, `setup.ps1`, `run_all.sh`, `run_all.ps1` |
| the backups taken before any file was touched | `<repo>/backups/fable51-part6-20260916/` (ignored by git, on disk) |

`<repo>` is wherever the repository is cloned; every shell block below finds it with
`git rev-parse --show-toplevel`.

## 1. Backups first

```bash
cd "$(git rev-parse --show-toplevel)"
mkdir -p backups/fable51-part6-20260916
cp -p claude-fable/cells_part1.wl claude-fable/cells_part2.wl claude-fable/cells_part3.wl claude-fable/cells_part4.wl \
      claude-fable/cells_part5.wl claude-fable/build_tools.py claude-fable/runner_header.wl claude-fable/run_from_nb.wls \
      claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb README.md .gitignore PROVENANCE-*.md STUDENT-GUIDE-*.md \
      backups/fable51-part6-20260916/
ls backups/fable51-part6-20260916/ | wc -l        # 24
```

## 2. What was employed from the rustSolveIt repositories, and what was not

The three repositories (`rustSolveIt_Win11_SUNDIALS_7_8_0`, `rustSolveIt_macos-silicon_SUNDIALS_7_8_0`,
`rustSolveIt_linux_SUNDIALS_7_8_0`) are a rigid-body / planetary / quantum simulator whose
notebooks drive that simulator's own command language. They cannot integrate a cosmological
field equation, so their notebooks were not used as they stand. What was employed:

1. **Their numerical engine**, the pure-Rust translation of SUNDIALS 7.8.0 vendored at
   `sundials_rs/crates/{sundials_core, cvode_rs}`, used exactly as their own
   `planet_Mercury/mercury_rs` uses it: a separate crate with path dependencies on the two crates
   and the `-C target-feature=+fma` pin in its own `.cargo/config.toml`. CVODE (BDF + Newton + dense,
   or Adams) with their default tolerances `rtol = 1e-10`, `atol = 1e-12` integrates every model
   here. The engine is fetched as a sparse clone (only `sundials_rs`, 2.6 s) of the repository for
   the student's platform, by `setup.sh` / `setup.ps1`.
2. **Their notebook discipline**: the eight requirements every one of their 128 notebooks meets
   (`notebooks/_build/nbcheck.py` there), adapted as `fable-cosmology/notebooks/_build/nbcheck.py`
   (R8, their SQLite dataset, became "owns its result files and reads one back with plain Python");
   their practice of *generating* notebooks from a script so the boilerplate is identical
   (`_build/nbgen.py`); their launch-instructions, glossary, name-and-save cells.
3. **Their conventions** for self-locating scripts and complete commands per page.

Their JupyterLab wrapper kernel (`jupyter/posim_kernel`) speaks the simulator's protocol and was
not applicable.

## 3. The physics, in one page (the full statement is DESIGN.md and the paper)

*(the definitions, the energy–momentum tensors, the field equations and the results of the
symbolic verification are summarised here after the run; see sections 6 and 8 of this page)*

## 4. The design review

The design was written first (`fable-cosmology/DESIGN.md`, revision 1) and reviewed adversarially
before implementation: three independent reviewers with different lenses (field-theory and
general-relativity conventions; cosmology and the quintessence / fermionic-dark-energy literature;
consistency with the pre-universe notebook itself), each asked to refute every statement, followed
by a verification pass on each finding. The session's usage limit interrupted the run after two
reviewers had returned (12 and 18 findings; the verification pass and the third reviewer did not
run), so every finding was checked by hand instead, against the notebook and by prototype
computations (section 5). The corrections adopted, all marked **[rev]** in `DESIGN.md`:

- the Friedmann constraint as written divided the `Ω` terms by 3 (a documentation error only;
  the solver had it right; a unit test `H(a=1) = 1` now guards it);
- the spinor energy–momentum tensor must be built with the *covariant* derivative
  `D_ν = ∂_ν + Γ^spin_ν`: the `∂`-only tensor has the same diagonal (so the same `ρ`, `P`) but
  differs in 42 off-diagonal components and is not the conserved one (both facts are now asserted);
- the "hilltop" spinor potential is unbounded below and cannot produce the Unite-like trajectory
  while `ρ > 0`; two bounded-below potentials with a sign-changing slope (`lorentz`, `expdamp`)
  replace it as the phantom-crossing examples, the hilltop is kept only inside its window of
  validity, and the solver refuses any run on which `V(s) ≤ 0`;
- a thawing canonical scalar *does* reproduce Unite's sign pattern (`w0 > −1`, `wa < 0`, CPL
  extrapolation below −1) without ever having `w < −1`: the "phantom past" of the CPL fit is an
  extrapolation beyond the supernova range, and the design's claim to the contrary was wrong;
- initial conditions are stated per potential and printed by the solver; thawing versus freezing
  is read off `dw/dN` over the fit range, not assumed from the potential's name;
- `w ≥ −1` for the scalar needs `ρ > 0`: the sector with gradients along the timelike second
  sheet has negative energy and is excluded from every statement about `w`;
- the "no dilution" statement is for the rescaled field `Ψ' = Ψ/√Sin[6Hx0]`; a spinor
  homogeneous in `x0` is not a solution; for a nonlinear `V` the exact problem is the `(x0, x4)`
  system, and `ρ = V(s) + K_h` carries a hidden-direction kinetic bilinear that vanishes only when
  `Ψ'` is `x0`-independent;
- the hidden-volume bookkeeping (`ρ_4 ∝ a^{−3}`) is a volume effect, not a dark-matter
  signature; the reduced tensor is not separately conserved; the framework has no gravitational
  sector, so which density gravitates is undetermined;
- the kinematic identification `ln a = −a4` never gives `a4` a value; the FLRW reference frame in
  Part VI is a separate frame; `a4' < 0` is the expansion hypothesis and is stated as such;
- smaller corrections: the hidden 4-volume density is `Tan[6Hx0] p³`, not `Sec p³`; the CPL
  integral's limits; `lambda-mass` is ΛCDM with the dust supplied by the spinor (`V0` is a bare
  constant); the `power` ordering needs `n < 1`; the anticommutator hypothesis behind
  `½(1/√g)∂_μ(√g γ^μ) = γ^μΓ_μ`; "without ghosts" replaced by the qualified spinor-quintom statement.

Twenty-one statements were also confirmed correct by the reviewers (the frame, metric and
volume element; the scalar sector in full; the Euler–Lagrange equation with its divergence term;
the fidelity anchor; the on-shell `ρ = V`, `P = sV' − V`; the FLRW law `s ∝ a^{−3}`; the Model A
system; the CPL closed form).

## 5. The prototypes (every symbolic claim was run against the notebook's own state first)

Four scripts, kept outside the repository at the author's `fable51/` scratch folder, evaluated
the delivered notebook's `Input` cells 1–117 (through Section 17) in a fresh kernel and then
checked the claims of the design. Their pattern is the probe of Provenance 11:

```wolfram
cfHere = DirectoryName[ExpandFileName[$InputFileName]];        (* or the absolute path of <repo>/claude-fable/ *)
Get[cfHere <> "runner_header.wl"];
nb = Import[cfHere <> "claude-fable_Einstein-Rosen-2-Planes.nb", "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
Block[{$Output = {}}, Do[cfRunCell[i, asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, 1, 117}]];
(* ... the checks ... *)
```

What they established (all `True`; the same checks are now assertions of Part VI):

- scalar: `T_{μν} = ∂φ∂φ + g L̂` symmetric; the **off-shell identity** `∇^μT_{μν} = (□φ − V')∂_νφ`
  for a generic `φ(x0,…,x7)`; the trace `−3(∂φ)² − 8V`; `ρ = KE + PE + G0 − G5`,
  `P_1 = KE − PE − G0 + G5`, `P_0 = KE − PE + G0 + G5`, `ρ + P_1 = 2 KE` for `φ(x0, x4, x5)`;
  `□φ = −φ̈` for `φ(x4)`; `□φ = Cos ∂_0(Sec Cot² ∂_0 φ)` for `φ(x0)`;
- spinor: the Euler–Lagrange equation of `√g[(1/H)Ψᵀσ16γ^μ∂_μΨ − V(s)]` equals
  `√g[(2/H)(A^μ∂_μΨ + ½DΨ) − 2V'σ16Ψ]`; `½(1/√g)∂_μ(√gγ^μ) = γ^μΓ^spin_μ = −3H Cot[6Hx0]² T16[0]`,
  with `{γ^μ, Γ_μ} = 0` on this frame; the Lagrangian with and without the connection term is the
  same functional; **fidelity**: with `V = −(2M/H)s` the flat Lagrangian is `La[]` and its
  Euler–Lagrange equations are `eLa`; the covariant tensor is symmetric, its diagonal equals the
  `∂`-tensor's, 42 off-diagonal components differ, and it is **conserved on shell in all eight
  components** for a generic `Ψ(x0, x4)` (the field equation substituted repeatedly for every
  `x4`-derivative); on shell `L̂ = sV' − V`, `ρ = V + K_h`, `P_1 = sV' − V`; `K_h = 0` for
  `√Sin Ψ'(x4)`; `ds/dx4 ≠ 0` for a generic `Ψ(x0,x4)` (it equals `2Ψᵀσ16γ^4γ^0∂_0Ψ`), and
  `ds'/dx4 = 0` for the rescaled `x0`-independent field; on the separate FLRW frame
  `γ^μΓ_μ = (3/2)(a'/a)γ^4` and `d(a³s)/dx4 = 0`; `a4` undefined throughout.

One bug found and fixed on the way, recorded so it is not relearned: replacement rules built
inside `Table[…, {k, 0, 15}]` whose right-hand side is a held `Function` body must inject the
iterator with `With[{kk = k}, …]`; without it every rule carries a symbolic `k` and three checks
came out `False` for no physical reason.

## 6. The solver, built and tested

```bash
cd "$(git rev-parse --show-toplevel)/fable-cosmology"
bash setup.sh            # venv + pip; sparse clone of the platform engine into rust/vendor/rustSolveIt; cargo build --release; --version
cd rust/fable_cosmo
cargo test --release     # 7 unit tests: derivatives vs finite differences, the CPL closed form, rho + P = 2 KE, w formulas and crossings, H(a=1) = 1, Adams vs BDF
./target/release/fable_cosmo.exe --version
#   fable_cosmo 0.1.0, sundials_rs 7.8.0 (pure Rust), CVODE BDF
```

The command-line contract, the models and the CSV columns are in `DESIGN.md` §4–5 and in
`fable-cosmology/README.md`. A first battery of runs (every model, every potential) and the
independent checks made before the notebooks existed:

| check | result |
|---|---|
| `const` potential, Model A | `w = −1`, `Ω_φ(a=1) = 0.6999`, `H(a=1) = 1` |
| `mass` potential, Model B | `w = 0` at every point, `q_dec(a=1) = 0.5` |
| Model A `exp λ=1` vs `scipy.solve_ivp` DOP853 `rtol 1e-11` | `max|Δw| = 9.5e-11` |
| Model B `lorentz` vs scipy | `max|Δt| = 1.0e-9`, `max|Δw| = 2.2e-8` |
| Model A `exp λ=1` vs Mathematica `NDSolve` (`reference/make_reference.wls`) | `max|Δw| = 1.1e-10`, `max|Δt| = 5.4e-10` |
| Model B `expdamp (1.566, 0.839, 2.21)` vs `NDSolve` | `max|Δw| = 1.9e-8`, `max|Δt| = 5.2e-9` |
| Model C `quadratic`, `x4 ∈ [0,100]` | `ρ` drift `3e-9`, running `⟨w⟩ → 0.004` |
| Model C `quartic`, `x4 ∈ [0,200]` | running `⟨w⟩ → 0.3348` (virial value 1/3), `ρ` drift `3.5e-8` |
| Model D `quadratic`, grid 61, `eps = 0.05` | exactly conserved discrete energy `E_h` drift `4.5e-9` |

The Mathematica reference integrations:

```bash
cd "$(git rev-parse --show-toplevel)"
wolframscript -file fable-cosmology/reference/make_reference.wls
#   mathematica_scalar_exp.csv: 701 rows;  w(a=1) = -0.843363803931198
#   mathematica_spinor_expdamp.csv: 701 rows;  w(a=1) = -0.860845640377648  min w = -1.30209881490919
```

## 7. The notebooks, Part VI, the paper

*(filled in from the build: the generator, the executed notebooks, the checker's verdict, the
Part VI run, the paper's compilation — see section 8)*

## 8. What the run prints

*(filled in after the fresh-clone verification)*

## 9. The hard rules, and how each was honoured

1. **Backups first** — section 1.
2. **Fidelity first** — Parts I–V of the notebook are untouched (their 250 assertions still pass
   under their labels); the fable Lagrangian with `V = −(2M/H)s` reproduces the author's `La` and
   `eLa` exactly, which Part VI asserts.
3. **Missing symbols are reported, not invented** — `a4` and `la` remain undefined; Part VI ends
   by asserting it; the 4-dimensional models are reference models on a separate frame and their
   `a(t)` is never substituted for `a4`.
4. **Nothing was taken less than seriously** — the rustSolveIt notebooks could not be used as they
   stand (they drive a rigid-body simulator); this page says so and says what was used instead,
   and the paper repeats it. Should the author want the notebooks written in the simulator's own
   command language regardless, the command that forces it is: *"Write the notebooks for the posim
   kernel."*
5. **All errors and warnings fixed** — the Part VI run reports every assertion passing and no cell
   raising a message; the notebooks pass all eight requirements; `cargo test` and `latexmk` are
   clean; the numbers in section 8.
