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

## 3. The physics, in one page

Every statement below is one of three kinds. Some are proved symbolically in Part VI of the
notebook, where each is an assertion; section 7 lists them. Some are hypotheses, and each is
called a hypothesis where it appears. The rest belong to the 4-dimensional reference models, and
each is called that.

### 3.1 The pre-universe

- **Coordinates and metric.** The coordinates are `X = {x0, …, x7}` and the flat metric is
  `η = diag(+1,+1,+1,+1,−1,−1,−1,−1)`.
- **The frame.** The canonical frame is `e = diag(Tan[6Hx0], q, q, q, 1, p, p, p)`, with
  `q = Exp[−a4[H x4]]/Sin[6Hx0]^(1/6)` and `p = Exp[+a4[H x4]]/Sin[6Hx0]^(1/6)`. It gives
  `g = e.η.eᵀ = diag(Tan², q², q², q², −1, −p², −p², −p²)` and, for `0 < 6Hx0 < π/2`,
  `Sqrt[det g] = Sec[6Hx0]`.
- **The constants.** `H` is the notebook's constant. `a4` is undetermined and is never given a
  value.
- **The 8-volume element does not depend on `x4`.** `q³p³ = 1/Sin[6Hx0]`, and
  `Sqrt[g_8] = q³ · (Tan[6Hx0] p³)` is the observed 3-volume times the hidden 4-volume density.
- **The spin connection drops out.** On this frame the spin connection contributes nothing to the
  Dirac Lagrangian of a real 16-spinor (Part V). This is a property of the frame, whose
  connection has no totally antisymmetric part, not of the spinor.
- **Observer and energy components.** The observer is `u = ∂_4`, and the time is `t ≡ x4`
  (`g44 = −1`). The energy components are `ρ ≡ T_44`, `P_i ≡ T^i_i` (no sum),
  `P ≡ (P_1 + P_2 + P_3)/3` and `w ≡ P/ρ`, defined only where `ρ > 0`. Both fields are
  homogeneous on the observed sheet, so `P_1 = P_2 = P_3`. In Wolfram indices `x4` is entry 5:
  `ρ = T[[5,5]]`.
- **Kinematic identification, a hypothesis.** `a(t) ≡ q|_{x0 fixed} ∝ Exp[−a4[H t]]`, so
  `ln a = −a4[H t] + const` and `H_obs = −H a4'[H t]`. The second sheet contracts at the opposite
  rate. The observed sheet expands (`H_obs > 0`) exactly when `a4' < 0`; this sign is assumed,
  never derived.

### 3.2 fableScalar

**Definition.** `fableScalar ≡ φ(x)` is a real scalar on the 8-manifold, minimally coupled, with
a self-interaction potential `V(φ)`:

    L_φ = Sqrt[det g] · L̂_φ,        L̂_φ = −½ g^{μν} ∂_μφ ∂_νφ − V(φ)      (so −½ g^{44} φ̇² = +½ φ̇²)
    T_{μν} = −(2/Sqrt[g]) δS/δg^{μν} = ∂_μφ ∂_νφ + g_{μν} L̂_φ
    □φ = V′(φ),   □ = (1/Sqrt[g]) ∂_μ(Sqrt[g] g^{μν} ∂_ν), which on the pre-universe reads
    −φ̈ + Cos[6Hx0] ∂_0(Sec[6Hx0] Cot[6Hx0]² ∂_0φ) + (1/q²)(∂_1²+∂_2²+∂_3²)φ − (1/p²)(∂_5²+∂_6²+∂_7²)φ = V′(φ)

**Properties of `T`.** It is symmetric. The Hilbert prescription reproduces it. The
**off-shell identity** `∇^μ T_{μν} = (□φ − V′(φ)) ∂_νφ` holds for a generic `φ(x0,…,x7)`, so
conservation on shell is exact. The trace is `T^μ_μ = −3(∂φ)² − 8V`.

**Energies, density, pressure, `wScalar`.** For a field of `x0`, `x4` and the second-sheet
coordinates:

    KE = ½ φ̇²,   PE = V(φ),   G0 = ½ Cot[6Hx0]² (∂_0φ)²,   G5 = ½ (1/p²) Σ_{i=5,6,7} (∂_iφ)²
    ρ_φ = KE + PE + G0 − G5,    P_φ = KE − PE − G0 + G5,    P_0 (along x0) = KE − PE + G0 + G5,    wScalar ≡ w_φ = P_φ/ρ_φ

The usual quintessence formulas are the case `G0 = G5 = 0`.

**Results (all proved in Part VI).**

1. **The null energy condition holds identically:** `ρ_φ + P_φ = 2 KE ≥ 0`, so
   `w_φ + 1 = 2 KE/ρ_φ`. Hence `w_φ ≥ −1` wherever `ρ_φ > 0`, which is guaranteed for `V ≥ 0`
   and a field independent of `x5, x6, x7`. The `−G5` sector (gradients along the timelike
   second sheet) can have `ρ < 0`; it is excluded from every statement about `w`. fableScalar
   cannot cross the phantom divide with positive energy.
2. **No Hubble friction in `x4`.** For `φ(x4)`, `φ̈ = −V′(φ)`, because
   `Sqrt[g] g^{44} = −Sec[6Hx0]` is `x4`-independent. Then `ρ = KE + V` is conserved on shell.
   On `φ = A Cos[m x4]` with `V = ½m²φ²`, `w = −Cos[2 m x4]` and its average over a period is 0:
   dust. In general the virial average is `⟨w⟩ = (n − 1)/(n + 1)` for `V ∝ φ^{2n}`.
3. **A static `x0` profile is `w = −1` on the observed sheet.** With `V = 0` the solution is
   `∂_0φ = C Sin[6Hx0]²/Cos[6Hx0]`. On it `G0 = C² Sin[6Hx0]²/2`, which is independent of `x4`
   and of `x1, x2, x3`. Then `ρ = G0` and `P_1 = −G0`, so `w = −1` exactly for the observer at
   fixed `x0`. Along `x0` itself `P_0 = +G0 = +ρ`, which is an anisotropic stress, not a Λ term.
   (The design and the notebooks' prose wrote `G0 = C²/2`; Part VI asserts `C² Sin[6Hx0]²/2`.
   See section 8.10.)
4. **The volume bookkeeping.** Reducing the action over the hidden coordinates gives
   `S_4 = ∫ d⁴x a³ 𝒱_hid L̂` with `𝒱_hid ∝ Tan[6Hx0] p³ ∝ Exp[3 a4] = a^{−3}`. So
   `ρ_4 = 𝒱_hid ρ_8` obeys `dρ_4/dt + 3H_obs(ρ_4 + P_4) = 3H_obs P_4`, i.e.
   `dρ_4/dt = −3H_obs ρ_4` for **every** `w`. This is a volume effect, not a dark-matter
   signature. The locally measured `T_44 = ρ_8` is exactly constant.

**The 4-dimensional reference model.** `φ̈ + 3H_obs φ̇ + V′ = 0` together with the Friedmann
equation, on a separate FLRW frame. It is what one obtains when the hidden volume is held fixed
and the field sources the expansion. It is never substituted into the canonical frame.

### 3.3 fable

**Definition.** `fable ≡ Ψ(x)` is a real 16-component spinor of `Spin(4,4)`, exactly as the
model's `Ψ16` of Section 11 of the notebook. It uses the Dirac matrices `T16[a]`
(`½{T16[a], T16[b]} = η_ab ID16`), the symmetric spinor metric `σ16` (`σ16 . T16[a]` is
antisymmetric), the curved Dirac matrices `γ^μ = coframe[[a, μ]] T16[a]`, the bilinear
`s ≡ Ψᵀ σ16 Ψ`, and a potential `V(s)`:

    L_Ψ = Sqrt[det g] · L̂_Ψ,     L̂_Ψ = (1/H) Ψᵀ σ16 γ^μ D_μΨ − V(s),     D_μ = ∂_μ + Γ^spin_μ

On the canonical frame the `Γ^spin` term vanishes identically in `L̂_Ψ`.

**Fidelity.** With `V = −(2M/H) s`, `frame → ID8` and `Sqrt[g] → 1`, `L̂_Ψ` **is** the author's
`La[]` of Section 11. Its Euler–Lagrange equations **are** his sixteen equations `eLa` of
Section 12.

**Field equation.** The explicit variation gives
`EL = Sqrt[g] [(2/H)(A^μ∂_μΨ + ½ 𝒟Ψ) − 2V′(s) σ16 Ψ]`, with `A^μ = σ16 γ^μ` antisymmetric and
`𝒟 = σ16 (1/Sqrt[g]) ∂_μ(Sqrt[g] γ^μ)`. That is,

    γ^μ ∂_μΨ + ½ (1/Sqrt[g]) ∂_μ(Sqrt[g] γ^μ) Ψ = H V′(s) Ψ.

- In general `(1/Sqrt[g]) ∂_μ(Sqrt[g] γ^μ) = [γ^μ, Γ^spin_μ]`.
- On the canonical frame the anticommutator `{γ^μ, Γ^spin_μ}` vanishes. This is the stated
  hypothesis, and Part VI asserts it. So the term is `γ^μ Γ^spin_μ Ψ = −3H Cot[6Hx0]² T16[0] Ψ`,
  and the equation is the **Levi-Civita covariant Dirac equation** `γ^μ D_μΨ = H V′(s) Ψ`.
- The term does not vanish for an `x0`-independent spinor. **A spinor homogeneous in every
  coordinate but `x4` is not a solution.**
- The rescaling `Ψ = Sqrt[Sin[6Hx0]] Ψ′` removes the term exactly, for a generic `Ψ′(x0, x4)`.
  Since `(γ^4)² = −ID16`, `Ψ′(x4)` solves `∂_4Ψ′ = −H V′(s) γ^4 Ψ′`. This is exact only for
  constant `V′`: the mass and `lambda-mass` terms. For a nonlinear `V` the exact problem is the
  `(x0, x4)` system (witnessed with `V = s²`).

**Energy–momentum tensor.** This is the symmetrised tensor built with the **covariant**
derivative:

    T_{μν} = −(1/2H)(Ψᵀ σ16 γ_μ D_νΨ + Ψᵀ σ16 γ_ν D_μΨ) + g_{μν} L̂_Ψ,     γ_μ = g_{μν} γ^ν

It is symmetric and conserved on shell in all eight components, for a generic `Ψ(x0, x4)`. The
`∂`-built tensor has the same diagonal (the same `ρ` and `P`) but differs off the diagonal, and
it is not the conserved one.

**Energies, density, pressure, `w`.** Define `K_Ψ ≡ (1/H) Ψᵀσ16 γ^4 ∂_4Ψ`,
`K_h ≡ −(1/H) Ψᵀσ16 γ^0 ∂_0Ψ` and `U_Ψ ≡ V(s)`. For a field homogeneous on the observed sheet,
on shell:

    L̂_Ψ = sV′(s) − V(s),    ρ_Ψ = V(s) + K_h,    P_Ψ = sV′(s) − V(s),    K_Ψ = sV′(s) + K_h

`K_h = 0` for `Ψ = Sqrt[Sin[6Hx0]] Ψ′(x4)`, and then

    ρ_Ψ = V(s),      w ≡ w_Ψ = s V′(s)/V(s) − 1,      ρ_Ψ > 0 ⇔ V(s) > 0.

**Results (all proved in Part VI).**

1. **The author's mass term is dust.** `V = −(2M/H) s` gives `P = 0` identically and
   `ρ = −(2M/H) s`, which is positive on the branch `M s < 0`. So `w = 0` exactly: cold dark
   matter.
2. **`w` is not bounded below by −1.** `V ∝ s^n` gives `w = n − 1`. This is accelerating for
   `n < 2/3`, and `n = 0.236` gives Unite's `−0.764` exactly. Since `w + 1 = sV′/V`, `w` crosses
   −1 where `V′` changes sign with `V > 0`. That is the spinor-quintom mechanism (Cai and Wang,
   Class. Quantum Grav. 25 (2008) 165014), with no wrong-sign kinetic term. Perturbative
   stability is not examined.
3. **No dilution on the pre-universe (Model E).** On shell,
   `ds/dx4 = 2 Ψᵀσ16 γ^4 γ^0 ∂_0Ψ` for a generic `Ψ(x0, x4)`. This is not identically zero, but
   it vanishes for `Sqrt[Sin[6Hx0]] Ψ′(x4)`, and `ds′/dx4 = 0` from the reduced equation. So `s`,
   `V`, `ρ_Ψ` and `w_Ψ` are constant along `x4`.
4. **The 4-dimensional reference model (Model B).** It lives on the separate frame
   `diag(1, aF(t), aF(t), aF(t), 1, 1, 1, 1)`. There `γ^μ Γ^spin_μ = (3/2)(aF′/aF) γ^4`, and
   `d(aF³ s)/dt = 0` for every `V`. So `s = s_0 a^{−3}`, and `w(a)` is the algebraic function
   above evaluated on it.

### 3.4 The potentials

| fable potential | `V(s)` | `w_Ψ(s) = sV′/V − 1` | on `s = s_0 a^{−3}` |
|---|---|---|---|
| `mass` | `m s` | `0` | dust at all times (the author's model) |
| `lambda-mass` | `V0 + m s` | `−V0/(V0 + m s)` | dust early → −1 late; `V0` is a bare Λ in the action: ΛCDM with spinor dust |
| `power` | `m s + λ s^n` | `(m s + nλ s^n)/(m s + λ s^n) − 1` | for `n < 1`: dust → `n − 1` |
| `hilltop` | `V0 − μ (s − s*)²` | `−2μ s (s − s*)/V − 1` | crosses −1 at `s*`; unbounded below, valid only for `s < s* + Sqrt[V0/μ]` |
| `lorentz` | `V0 + m s/(1 + u)`, `u = (s/s1)²` | `m s (1 − u)/((1 + u)² V) − 1` | positive everywhere; phantom for `s > s1`; crosses −1 at `s1`, i.e. at `a_c = (s1/s_0)^{−1/3}` |
| `expdamp` | `V0 + m s e^{−s/s1}` | `m s e^{−s/s1}(1 − s/s1)/V − 1` | bounded below by `V0`; the same crossing at `s1` |

The fableScalar potentials are listed with the initial value `φ_i` of the FLRW runs, which start
from rest:

| potential | `V(φ)` | `φ_i` |
|---|---|---|
| `exp` | `V0 e^{−λφ}` | 0 |
| `invpower` | `V0 φ^{−α}` | 0.2 |
| `pngb` | `V0 (1 + cos(φ/f))` | `0.5 f` |
| `quadratic` | `½ m² φ²` | 1 |
| `hilltop` | `V0 (1 − φ²/μ²)` (used where `V > 0`) | `0.1 μ` |
| `const` | `V0` (the control, `w = −1`) | 0 |
| `quartic` | `¼ λ φ⁴` | 1 |

### 3.5 The numerical models

**Units and background.** `M_pl² = 1/(8πG) = 1`, `H0 = 1`, `a0 = 1`, so `ρ_crit,0 = 3`. The
parameters are `Ω_m0 = 0.3` and `Ω_r0 = 8.4e−5`, with `ρ_m = 3Ω_m0 e^{−3N}` and
`ρ_r = 3Ω_r0 e^{−4N}`, where `N = ln a`. Then
`H² = Ω_m0 e^{−3N} + Ω_r0 e^{−4N} + ρ_field/3`, so `H(N = 0) = 1` exactly when the field carries
`Ω = 0.699916`. Time is carried as `dt/dN = 1/H`, plus the analytic age `t_age(N0) = 1/(2H(N0))`.
The deceleration parameter is `q_dec = −1 − (dH/dN)/H`.

**Initial conditions.** The FLRW runs start at `N0 = −7` (`a = 9.12e−4`), from rest, at `φ_i`.
Thawing, freezing, constant or mixed is read off the sign of `dw/dN` over `0.3 ≤ a ≤ 1`, with
tolerance `1e−6`.

- **Model A** (`scalar-flrw`), fableScalar sourcing FLRW. The state is `(φ, φ̇, t)`:
  `dφ/dN = φ̇/H`, `dφ̇/dN = −3φ̇ − V′/H`, `dt/dN = 1/H`, with
  `H² = Ω_m0 e^{−3N} + Ω_r0 e^{−4N} + (½φ̇² + V)/3`. The scale of `V` is found by shooting:
  bisection on `log10 k` in `[−6, 6]`, 80 iterations or `Δ < 1e−13`, to `Ω_φ(1) = 0.699916`. The
  solver refuses if the target is not bracketed or if `ρ_φ ≤ 0`.
- **Model A′** (`scalar-cpl`), the same field as a test field on the Unite CPL background:
  `H² = Ω_m0 a^{−3} + Ω_r0 a^{−4} + Ω_DE0 a^{−3(1+w0+wa)} e^{−3wa(1−a)}` with
  `(w0, wa) = (−0.861, −0.60)`. The scale is set so that `ρ_φ(1)/3 = Ω_DE0`.
- **Model B** (`spinor-flrw`), fable in FLRW. The state is `(s, t)`: `ds/dN = −3s`,
  `dt/dN = 1/H`, with `H² = Ω_m0 e^{−3N} + Ω_r0 e^{−4N} + V(s)/3` and `s_today = 1`. The
  potential is rescaled so that `V(1) = 3 × 0.699916`, which leaves `w(s)` unchanged. The solver
  refuses if `V ≤ 0` anywhere.
- **Model C** (`scalar-pre`), fableScalar on the pre-universe, homogeneous, with `H = 1`:
  `φ̈ = −V′(φ)`. It reports `w`, the running average `w_avg`, and the drift `ρ/ρ(0) − 1`.
- **Model D** (`scalar-pre-x0`), fableScalar with an `x0` profile, by the method of lines on
  `x0 ∈ [0.05, 0.22] ⊂ (0, π/12)`:
  `φ̈_j = Cos_j (F_{j+½} − F_{j−½})/h − V′(φ_j)`, with `F_{j+½} = c_{j+½}(φ_{j+1} − φ_j)/h`,
  `c = Sec Cot²` at the half points, and zero flux at both ends. The scheme conserves exactly
  `E_h = Σ_j Sec_j h (½φ̇_j² + V(φ_j)) + Σ ½ c_{j+½} (φ_{j+1} − φ_j)²/h`. The sheet average is
  `w_sheet = ⟨P⟩/⟨ρ⟩`, `Sec`-weighted. The initial profile is `φ_i (1 + ε cos(π u))`, at rest.
- **Model E**, fable on the pre-universe: `ds/dx4 = 0` exactly, so there is nothing to integrate.

**The CPL fit.** For every run of A, A′ and B, the unweighted least-squares fit of `w(a)` to
`w0 + wa (1 − a)` over `0.3 ≤ a ≤ 1`. It is reported with `w0 + wa`, the true `w(0.3)`, `w(1)`,
`min w`, and the distance from Unite's `(−0.861, −0.60)`. This describes a model curve; it is not
a fit to supernova data.

### 3.6 The results

Every number below is from the committed `fable-cosmology/results/*.csv` and the executed
notebooks. A re-run reproduces them byte for byte (section 8.4).

- **fableScalar, reference model.** The exponential potential thaws from rest, with
  `min w = −1.000000` in every run (the null energy condition).

  | `λ` | `w(1)` | CPL fit `(w0, wa)` |
  |---|---|---|
  | 0.5 | −0.9616 | (−0.9627, −0.0532) |
  | 1 | −0.8434 | (−0.8440, −0.2172) |
  | 1.5 | −0.6322 | (−0.6176, −0.5015), distance 0.263 |
  | 2 | −0.2720 | (−0.2004, −0.8384) |

  A scan over `λ = 0.5 … 2.0` puts the closest point at `λ = 1.4`, `(−0.6740, −0.4349)`, distance
  0.2495. The fitted `wa` reaches −0.60 at `λ = 1.638`, where `w0 = −0.5274`. So a thawing scalar
  has Unite's sign pattern, and a CPL extrapolation `w0 + wa` below −1 (between −1.016 and
  −1.129), but it never matches both numbers and never has `w < −1`.
- **The refusals.** `λ = 3` cannot be normalised; its scaling attractor carries only
  `Ω_φ = 0.3375` (`3/λ² = 0.3333`). The inverse power (`α = 1`) does not reach its tracker from
  rest: the starts at `N0 = −7` and `N0 = −25` agree to `3.0e−8`, with `w(1) = −0.7532`.
- **Model A′.** `λ = 1` fits `(−0.8371, −0.2257)`. `λ = 2` saturates at `Ω = 0.4984`.
- **fable, reference model.** The `mass` term gives `w = 0` at all 701 points. `lambda-mass`
  splits into `Ω_Λ = 0.489941` (a bare constant) plus spinor dust `0.209975`, with
  `w(1) = −0.700000`. The power law `n = 0.236` reaches `w(N = 6) = −0.76399919`. The reference
  `expdamp (1.566, 0.839, 2.21)` has `w(1) = −0.86085`, crosses −1 at `a_c = 0.7677195`
  (analytic to `1.3e−8`), reaches `min w = −1.30210` at `a = 0.5434` (`z = 0.840`) and fits
  `(−0.9782, −0.2445)`. `expdamp` with `s1 = 3.0` fits `(−0.8513, −0.5692)`, `w0 + wa = −1.4205`,
  at distance **0.0323** from Unite: the closest of all runs. It has a genuine phantom phase
  (`min w = −1.3878`) and `V ≥ V0 > 0` throughout.
- **fableScalar on the pre-universe.** Model C conserves `ρ` to `3.27e−9` (quadratic) and
  `1.58e−8` (quartic) over `x4 ≤ 100`, with `w_avg(100) = +0.004363` and `0.334909` (virial 0 and
  1/3). In Model D, `E_h` is conserved to `4.48e−9` (`ε = 0.05`) and `9.05e−9` (`ε = 0.5`). The
  `x0`-gradient store holds 28.5 % and 97.8 % of the energy at the start and sloshes into the
  `x4` motion and back (`G0` fraction down to 2.88 % and 9.88 %). `w_sheet` swings over
  `[−1, +0.9412]` and `[−1, +0.8022]`, and averages to `+0.0038` and `+0.0007`.
- **Dark matter.** Yes. The author's spinor mass term is dust, exactly. A quadratic scalar
  oscillating without friction averages to `w = 0`. The `power` spinor is dust early.
- **Dark energy.** Yes, by two mechanisms. The first is thawing fableScalar quintessence (Unite's
  sign pattern, no phantom phase). The second is the fable spinor with a sign-changing `V′`,
  which gives a genuine phantom past with `ρ > 0` and comes within 0.032 of Unite's point.
  `lambda-mass` is ΛCDM in disguise. On the pre-universe itself a time-varying `w` comes from
  oscillation and sloshing, not rolling.
- **Not established.** The framework has no gravitational sector: `a4` is free, and which
  density gravitates is undetermined. Perturbations are not examined. The volume bookkeeping is
  a volume effect. The kinematic identification is a hypothesis.

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
cargo test --release     # 7 unit tests: derivatives vs finite differences, the CPL closed form, rho + P = 2 KE, w formulas and crossings, H(a=1) = 1, the x0 grid refusing its singular ends, Adams vs BDF
./target/release/fable_cosmo.exe --version
#   fable_cosmo 0.1.0, sundials_rs 7.8.0 (pure Rust), CVODE BDF
```

(Corrected 2026-09-24: the list of tests omitted `x0_grid_rejects_the_singular_ends`. The seven
tests are named in section 8.1.)

**The command-line contract.** This was read from `rust/fable_cosmo/src/main.rs` and checked
against the binary on 2026-09-24.

    fable_cosmo <model> [--potential NAME] [--param KEY=VALUE ...] [--n0 X0] [--n1 X1] [--points K]
                [--out FILE.csv] [--no-normalize] [--grid N] [--x0min A] [--x0max B]
                [--profile-out FILE.csv] [--rtol R] [--atol A] [--method bdf|adams]
    fable_cosmo --version

- **Models.** `scalar-flrw` (A), `scalar-cpl` (A′), `spinor-flrw` (B), `scalar-pre` (C),
  `scalar-pre-x0` (D).
- **Defaults.**
  - Potential: `exp` for the scalar models, `mass` for `spinor-flrw`.
  - Range: `--n0 -7 --n1 0` for A, A′ and B (in `N = ln a`); `0` to `50` for C and D (in `x4`).
  - `--points 701`, `--grid 101`, `--x0min 0.05`, `--x0max 0.22`, `--rtol 1e-10`,
    `--atol 1e-12`.
  - Method: `bdf` for A, A′ and B; `adams` for C and D.
  - Background: `om=0.3`, `or=8.4e-5`, `w0=-0.861`, `wa=-0.60`.
  - Initial state: `phi_i` and `phidot_i` as in section 3.4 (`phi_i = 1` for C and D); Model B
    `s_today=1`; Model D `eps=0.5`, `mode=1`.
  - Potential parameters default to 1, except `n=0.5`, `sstar=1.5` and `s1=1.5`.
- **Output.** A CSV whose header line names every column. Numbers use Rust's `{:.15e}` (16
  significant digits). Without `--out` the CSV goes to standard output. The columns are:
  - A: `a, z, N, t, phi, phidot, H, KE, PE, rho_phi, P_phi, w_phi, Omega_phi, Omega_m, Omega_r, q_dec`.
  - A′: the first twelve of those, then `w_cpl, Omega_phi_test, Omega_DE_cpl`.
  - B: `a, z, N, t, s, H, K_Psi, U_Psi, rho_Psi, P_Psi, w_Psi, Omega_Psi, Omega_m, Omega_r, q_dec`.
  - C: `x4, phi, phidot, KE, PE, rho, P, w, w_avg, rho_drift`.
  - D: `x4, phi_mid, KE_mid, PE_mid, G0_mid, rho_mid, P_mid, w_mid, E_sheet, P_sheet, w_sheet,
    KE_frac, PE_frac, G0_frac, E_drift`. With `--profile-out`, a second file: header `x4,phi,…`,
    first data row `NaN` followed by the `x0` grid, then `x4` and `φ(x0_j, x4)` on each row.
- **Standard error.** `# initial conditions: …` (A, A′, B only), `# stats: model=… steps=…
  rhs_evals=… nonlin_iters=… err_test_fails=…`, `# potential=…` (after normalisation), and the
  version line.
- **Exit codes.**
  - `0`: success.
  - `1`: a solver or physics error, with a one-line reason starting `fable_cosmo:`. This covers
    `V ≤ 0`, `ρ ≤ 0`, a normalisation that is not bracketed, an `x0` grid outside `(0, π/12)`,
    a CVODE failure, an unwritable file, and also an unknown model or potential name.
  - `2`: a malformed command line: no arguments, an unknown option, a missing or non-numeric
    value, `--param` without `=`, `--points < 2`, or an unknown `--method`.

The design text said "15 significant digits" and "2 usage" for an unknown model. Both are
corrected above; see section 8.10.

A first battery of runs (every model, every potential) and the independent checks made before
the notebooks existed:

| check | result |
|---|---|
| `const` potential, Model A | `w = −1`, `Ω_φ(a=1) = 0.6999`, `H(a=1) = 1` |
| `mass` potential, Model B | `w = 0` at every point, `q_dec(a=1) = 0.5` |
| Model A `exp λ=1` vs `scipy.solve_ivp` DOP853 `rtol 1e-11` | `max\|Δw\| = 9.5e-11` |
| Model B `lorentz` vs scipy | `max\|Δt\| = 1.0e-9`, `max\|Δw\| = 2.2e-8` |
| Model A `exp λ=1` vs Mathematica `NDSolve` (`reference/make_reference.wls`) | `max\|Δw\| = 1.1e-10`, `max\|Δt\| = 5.4e-10` |
| Model B `expdamp (1.566, 0.839, 2.21)` vs `NDSolve` | `max\|Δw\| = 1.9e-8`, `max\|Δt\| = 5.2e-9` |
| Model C `quadratic`, `x4 ∈ [0,100]` | `ρ` drift `3e-9`, running `⟨w⟩ → 0.004` |
| Model C `quartic`, `x4 ∈ [0,200]` | running `⟨w⟩ → 0.3348` (virial value 1/3), `ρ` drift `3.5e-8` |
| Model D `quadratic`, grid 61, `eps = 0.05` | exactly conserved discrete energy `E_h` drift `4.5e-9` |

Every row of this table was re-checked on 2026-09-24 against the committed CSVs and the executed
notebooks (section 8.9). The quartic row came from a development run whose command the page did
not record. It is reproduced exactly by
`fable_cosmo scalar-pre --potential quartic --param lambda=1 --n1 200 --points 4001`, which
gives `w_avg(200) = 0.334843` and `max |ρ drift| = 3.488e−8`. The notebooks run the quartic case
to `x4 = 100` instead.

The Mathematica reference integrations:

```bash
cd "$(git rev-parse --show-toplevel)"
wolframscript -file fable-cosmology/reference/make_reference.wls
#   mathematica_scalar_exp.csv: 701 rows;  w(a=1) = -0.843363803931198
#   mathematica_spinor_expdamp.csv: 701 rows;  w(a=1) = -0.8608456403776481  min w = -1.3020988149091868
```

(Corrected 2026-09-24. The quote above used to read `w(a=1) = -0.860845640377648  min w =
-1.30209881490919`, which was one digit short of what the script prints, and it omitted three
`General::munfl` underflow messages and a `General::stop` that the script printed between the two
lines. Those messages were harmless; their cause and the one-line fix are in section 8.7.)

## 7. The notebooks, Part VI, the paper

### 7.1 How the notebooks are generated

The four notebooks are **generated** by `fable-cosmology/notebooks/_build/nbgen.py`, never
edited by hand. It follows the rustSolveIt practice of generating notebooks so that the
boilerplate is identical. It has one function per notebook, each building `nbformat` v4 cells,
and a shared toolbox:

- the launch instructions (section 1 of every notebook) and the glossary (section 2);
- one setup cell, which:
  - locates `rust/fable_cosmo/target/release/fable_cosmo[.exe]` relative to the notebook;
  - defines `run_solver` (runs one case, prints its stderr, reads the CSV);
  - provides Python copies of every potential, taking the solver's normalised parameters from
    its `# potential=` line;
  - defines the CPL fit (`numpy.polyfit` on `1 − a` over `0.3 ≤ a ≤ 1`), the thawing/freezing
    classifier (the sign of `dw/dN`), the crossing finder (a local degree-6 polynomial plus
    `brentq`), the fit-table writer, the two plotting functions, and the scipy DOP853
    re-integrations of Models A, A′ and B;
- two closing cells tagged `interactive`: a name prompt and a *Save as* dialog with a typed-folder
  fallback. Both detect headless execution (the kernel's stdin disabled, or `FABLE_HEADLESS`)
  and print a notice instead of prompting.

Before writing, `build()` asserts that every code cell is preceded by at least 80 characters of
markdown. It sets the kernelspec `Python 3 (ipykernel)` and `metadata.fable_cosmo.model`, and
validates the notebook with `nbformat.validate`.

```bash
cd "$(git rev-parse --show-toplevel)/fable-cosmology"
.venv/Scripts/python.exe notebooks/_build/nbgen.py        # Windows Git Bash; .venv/bin/python elsewhere; writes all four, unexecuted
.venv/Scripts/python.exe notebooks/_build/nbgen.py 03     # or one of them
```

| notebook | cells | code cells | `metadata.fable_cosmo.model` |
|---|---|---|---|
| `01_fableScalar_quintessence.ipynb` | 38 | 16 | `scalar-flrw`, `scalar-cpl` |
| `02_fable_spinor.ipynb` | 35 | 15 | `spinor-flrw` |
| `03_pre-universe_dynamics.ipynb` | 29 | 12 | `scalar-pre`, `scalar-pre-x0` |
| `04_dark_matter_dark_energy.ipynb` | 25 | 10 | `scalar-flrw`, `spinor-flrw` |

### 7.2 How they are executed

Headlessly and in place, in the order 01, 02, 03, 04. Notebook 04 reads the fit tables that 01
and 02 write. From `fable-cosmology/`:

```bash
for nb in notebooks/0*.ipynb; do
  .venv/Scripts/python.exe -m nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=1800 \
        --ExecutePreprocessor.kernel_name=python3 "$nb"
done
```

That is step 2 of `run_all.sh` / `run_all.ps1`. Every CSV and PNG under `results/` is rewritten.
Every notebook asserts every number its prose quotes, and it fails if any scipy cross-check
differs from the solver by more than `1e−6` in `w`.

### 7.3 How they are checked

`fable-cosmology/notebooks/_build/nbcheck.py` checks eight requirements. They are the
requirements every one of the rustSolveIt notebooks meets, adapted.

- **R1** the launch instructions: `jupyter lab`, `Python 3 (ipykernel)`, `cargo build --release`,
  `Shift+Enter`, `setup.sh`, `setup.ps1`.
- **R2** never sends the reader to another notebook.
- **R3** at least 80 characters of markdown before every code cell.
- **R4** asks for a name.
- **R5** a `tkinter` `asksaveasfilename` dialog with the fallback `Falling back to a typed folder path`.
- **R6** the sections 1–6 by their exact headings, including
  `### 4.1 The first-order system actually handed to SUNDIALS`.
- **R7** valid nbformat 4, every non-interactive code cell executed, and a known solver model in
  the metadata.
- **R8** `import csv` read-back and `results/` named in the markdown.

The verdict is in section 8.3: `4/4 notebooks pass all eight requirements`.

### 7.4 What each notebook shows

All the numbers below are from the executed notebooks and the committed `results/` files.

**01_fableScalar_quintessence (Models A, A′).**

- The exponential potential with `λ = 0.5, 1, 1.5, 2`, normalised to `V0 = 2.2222, 2.6872, 4.0697,
  12.885`, gives `w(1) = −0.96162, −0.84336, −0.63217, −0.27196`. Every run has
  `Ω_φ(1) = 0.699916` and `min w = −1.000000`.
- `λ = 3` is refused (exit code 1): `Omega(10^6 V) = 0.3375115141492524`. On its scaling solution
  (`v0 = 1e6`) it gives `Ω_φ(1) = 0.3375` (`3/λ² = 0.3333`), `w(1) = −0.0039` and
  `q_dec(1) = +0.4981`.
- The inverse power `α = 1` from `N0 = −7` and from `N0 = −25` agrees to `3.01e−8`:
  `w(N = −4) = −0.99975`, `w(N = −2) = −0.92110`, `w(1) = −0.75324`, fit `(−0.7365, +0.0625)`,
  mixed. It does not reach its tracker.
- PNGB `f = 1` fits `(−0.9888, −0.0165)`. PNGB `f = 0.5` from `φ_i = 0.3` fits
  `(−0.8841, −0.1817)`. The hilltop `μ = 3` fits `(−0.9993, −0.0010)`. The `const` control has
  `max |w + 1| = 0`.
- Model A′: `λ = 1` gives `w(1) = −0.83905` and fit `(−0.8371, −0.2257)`. `λ = 2` is refused
  (`rho_phi(10^6 V) = 1.0249 < 2.0997`). By hand with `v0 = 10` it carries `Ω = 0.4984`.
- The CPL table is `results/nb01_cpl_fits.csv`, 15 rows including the two Unite rows.
  `λ = 1.5` is the closest of the five, `(−0.6176, −0.5015)`, distance 0.2626.
- The scipy cross-check over 13 runs gives at most `4.095e−9` in `w`.
- Three integrators on `exp λ = 1`: CVODE–NDSolve `1.149e−10`, scipy–NDSolve `1.313e−10`,
  CVODE–scipy `9.509e−11`. `w(a=1)` is `−0.843363804027` (Rust), `−0.843363803932` (scipy) and
  `−0.843363803931` (Mathematica).
- The scan `λ = 0.5 … 2.0` puts the closest point at `λ = 1.4`, `(−0.6740, −0.4349)`, distance
  0.2495. `wa = −0.60` is reached at `λ = 1.638`, where `w0 = −0.5274` and `w(0.3) = −0.9477`.
- Figures: `nb01_w_of_a_exp.png`, `nb01_w_of_a_other.png`, `nb01_w_of_a_cpl.png`,
  `nb01_caldwell_linder.png`, `nb01_lambda_scan.png`.

**02_fable_spinor (Model B).**

- `mass`: `max |w| = 0` and `ρa³/ρ(1)` in `[0.9999999470, 1.0000000000]`.
- `lambda-mass` (`v0 = 0.7`, `m = 0.3`, normalised to `1.469824`, `0.629924`): `Ω_Λ = 0.489941`,
  `Ω_dust = 0.209975`, `w(1) = −0.700000`.
- `power`, with `m = λ`: `w(1) = −0.38200`, `−0.25000`, `−0.05000` for `n = 0.236, 0.5, 0.9`.
  Run to `N = +6`, `w = −0.76399919`.
- `lorentz` (normalised `v0 = m = 1.24076`): crossing at `0.873580480` (analytic `0.873580465`),
  `min w = −1.2492`, `w(1) = −0.8427`.
- `expdamp (1.566, 0.839, 2.21)`, not normalised: `w(1) = −0.86085`, `min w = −1.30210` at
  `a = 0.5434` (`z = 0.840`), `V(1) = 2.099640`, `Ω_Ψ(1) = 0.699905`, `min V = 1.5660`.
- `expdamp s1 = 1.5` and `s1 = 3.0`, normalised. `s1 = 3.0` fits `(−0.8513, −0.5692)`, distance
  `0.0323`: the closest run of either field.
- `hilltop` is refused from the default start (`V(s) = −184913370713936540` at `s = 1.3188e9`).
  It is run from `N0 = −0.5` inside its window `a > 0.5512`, crossing at `0.873580465`
  (`|Δ| = 4.0e−11`).
- All five crossings agree with `(s1/s0)^{−1/3}` to at most `1.50e−8`
  (`results/nb02_crossings.csv`).
- The scipy cross-check over 11 runs gives at most `2.387e−8`.
- Three integrators on the reference `expdamp`: CVODE–NDSolve `1.861e−8`, scipy–NDSolve
  `1.008e−11`, CVODE–scipy `1.861e−8`. Relative differences are `5.2e−8` in `s`, `2.5e−9` in `H`
  and `1.4e−8` in `ρ`.
- Figures: `nb02_potentials.png`, `nb02_w_of_a_dust.png`, `nb02_w_of_a_phantom.png`,
  `nb02_caldwell_linder.png`.

**03_pre-universe_dynamics (Models C, D; E stated).**

- Model C quadratic (`x4 ≤ 100`, 2001 points, 965 CVODE steps): `w_avg(100) = +0.004363`,
  `max |ρ drift| = 3.27e−9`, `max |φ − cos x4| = 1.67e−9`, `max |w + cos 2x4| = 2.05e−9`.
- Model C quartic: `w_avg(100) = 0.334909` (`+1.58e−3` from 1/3), `max |ρ drift| = 1.58e−8`.
  Its scipy difference of `4.013e−7` falls to `2.538e−9` when CVODE runs at `rtol 1e−12`, which
  makes it CVODE's phase error.
- Model C `const`: `w = −1` exactly, drift 0.
- Model D, 61 grid points, `x4 ≤ 30`:

  | `ε` | `E_h(0)` | `max |E_drift|` | `G0` fraction | `w_sheet` range | time-averaged `KE` | running `⟨w_sheet⟩` at 30 |
  |---|---|---|---|---|---|---|
  | 0.05 | 0.205526 | `4.48e−9` | `[0.0288, 0.2847]` | `[−1, +0.9412]` | 0.5017 | `+0.0038` |
  | 0.5 | 5.983444 | `9.05e−9` | `[0.0988, 0.9780]` | `[−1, +0.8022]` | 0.4997 | `+0.0007` |

- The numpy/scipy re-implementation of Model D agrees in `w_sheet` to `6.494e−9` and `1.073e−8`.
- Figures: `nb03_modelC_quadratic.png`, `nb03_modelC_quartic.png`, `nb03_modelD_eps0.05.png`,
  `nb03_modelD_eps0.5.png`.

**04_dark_matter_dark_energy (the synthesis).**

- It re-runs seven best cases. Their fits equal the tables' to at most `4.4e−11`.
- It prints the merged CPL table, sorted by distance from Unite: `expdamp s1 = 3.0` at 0.032,
  then `exp λ = 1.5` at 0.263.
- `q_dec(1)`:

  | run | `q_dec(1)` |
  |---|---|
  | `exp λ = 1` | −0.3854 |
  | `exp λ = 1.5` | −0.1637 |
  | reference `expdamp` | −0.4037 |
  | `expdamp s1 = 3.0` | −0.3557 |
  | `lambda-mass` | −0.2349 |
  | `power n = 0.236` | +0.0990 |
  | `mass` | +0.5000 |

- The field overtakes matter at `a = 0.7376` (`expdamp`) and `a = 0.7239` (`exp λ = 1`).
- Acceleration begins at `a = 0.5475` (`z = 0.827`), `0.5840` (`z = 0.712`) and `0.8045`
  (`z = 0.243`, `lambda-mass`). The `mass` case never accelerates.
- Section 7 answers the questions, as summarised in section 3.6 of this page.
- Figures: `nb04_w_of_a_all.png`, `nb04_omega_history.png`, `nb04_deceleration.png`.

### 7.5 Part VI of the Mathematica notebook (Sections 23–25)

The manifest is `claude-fable/cells_part6.wl`. The rebuilt notebook
`claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb` has 282 cells, 172 of them Input cells.
Sections 23–25 are Input cells 153–172. The run log is `claude-fable/run_fable51_part6.log`. It
reports: `evaluating 172 Input cells straight out of the .nb`, `Assertions run: 358   passed: 358
failed: 0`, `cells w/ msgs   : 0`, `identities accepted on numerical evidence alone : 0` and
`non-vanishing witnesses : 27`, with 162.534 s in total.

Parts I–V account for 250 of those assertions and 19 witnesses. Part VI adds 108 assertions and
8 witnesses:

| tag | assertions |
|---|---|
| HELPER | 2 |
| FABLESCALAR | 34 |
| MODEL A | 7 |
| FABLE | 43 |
| FLRW | 7 |
| MODEL B | 7 |
| KINEMATIC | 3 |
| VOLUME | 3 |
| PART VI | 1 |
| the final "no identity accepted on numerical evidence" | 1 |

What Part VI proves, by section:

- **Helpers.** `cfEulerLagrange` on an oscillator gives `−f″ − f`. `cfCovariantDivergence` of
  the metric vanishes.
- **23. fableScalar.**
  - The definitions: the kinetic sign, the symmetry of `T`, the Hilbert prescription, the
    Euler–Lagrange equation `□φ = V′`, and `□` on the pre-universe.
  - The off-shell identity `∇^μT_{μν} = (□φ − V′)∂_νφ` for a generic `φ` of all eight
    coordinates. Conservation on shell in all eight components. An off-shell control. The trace.
  - `ρ`, `P_1`, `P_0`, and the null energy condition `ρ + P_1 = 2 KE` identically. The `−G5`
    sector with `ρ < 0`.
  - No Hubble friction, with a control that has friction. `φ = A Cos[m x4]` gives
    `w = −Cos[2 m x4]`, with average 0.
  - The static `x0` profile: `G0 = C² Sin[6Hx0]²/2`, `w = −1` on the sheet, `P_0 = +ρ`.
  - `Sqrt[g_8] = q³ · Tan p³`, and the volume is independent of `x4`.
  - Model A by `NDSolve`: 701 rows, `Ω_φ(1)` to `1e−8`, `w ≥ −1`, `dw/dN > 0`. It agrees with
    `fable-cosmology/reference/mathematica_scalar_exp.csv` at every row to `1e−9`, and prints
    `w(a=1) = -0.84336380393119807…`.
- **24. fable.**
  - `s` is a genuine scalar. `L̂` is the same with `D` and with `∂`.
  - **Fidelity:** the helper is `La[]`, and its Euler–Lagrange equations are `eLa`.
  - The Euler–Lagrange equation by explicit variation. `(1/Sqrt[g])∂(Sqrt[g]γ) = [γ, Γ]`. The
    anticommutator hypothesis. `−3H Cot² T16[0]`. The covariant Dirac equation. A homogeneous
    spinor is not a solution.
  - The rescaling. The nonlinear-`V` caveat. The mass term's `Ψ′(x4)` is exact.
  - `T_cov` is symmetric, has the same diagonal as the `∂`-tensor, and differs off the diagonal.
  - On shell: `L̂ = sV′ − V`, `ρ = V + K_h`, `P = sV′ − V`, `K_Ψ = sV′ + K_h`. `K_h = 0` for the
    rescaled solutions. `ds/dx4 = 2Ψᵀσ16γ⁴γ⁰∂_0Ψ`, not zero in general, zero for the rescaled
    solutions.
  - `∇^μT_{μν} = 0` on shell in all eight components, for a generic `Ψ(x0, x4)`.
  - The mass term is dust.
  - The closed forms of `w` for the six potentials. The crossings at `s1`/`s*`. The bounds and
    limits of `lorentz` and `expdamp`. `expdamp` gives `w(1) = −0.8608`.
  - The FLRW frame: `γ^μΓ_μ = (3/2)(a′/a)γ⁴` and `d(a³s)/dx4 = 0`, with a control.
  - Model B by `NDSolve`: the crossing at `a = 0.7677`, `min w = −1.302` at `a = 0.543`,
    `V > 0`. It agrees with `fable-cosmology/reference/mathematica_spinor_expdamp.csv` at every
    row to `1e−9`.
- **25. Side by side.**
  - The kinematic identification `ln q = −a4 + const`, with the sign hypothesis stated.
  - The volume bookkeeping: `dρ_4/dx4 = −3H_obs ρ_4` for every `w`, while `ρ_8` is constant.
  - **`a4` is still undefined, and the FLRW `aF` never entered the canonical frame.**

Part VI was re-run on 2026-09-24 (section 8.8). The log is identical to the committed one apart
from timings.

### 7.6 The paper

`fable-cosmology/latex/fable_cosmology.tex` compiles to `fable_cosmology.pdf`: 24 pages, article
class. Its title is "fableScalar and fable: a quintessence-like scalar and a 16-component spinor
on the 4+4 pre-universe, their equations of state, and the Supernovae *Unite* CPL fits". It has
twelve sections and an appendix:

1. the introduction (the task, and the Unite reference restated);
2. the pre-universe;
3. fableScalar (Lagrangian, tensor, field equation, energies, the results S1–S4, the reference
   model);
4. fable (definition, fidelity, field equation, tensor, energies, the results F1–F4, the
   potentials);
5. the numerical models A–E and the CPL fit;
6. the numerical method: the rustSolveIt engine, CVODE settings and costs, the solver's
   contract, the 7 unit tests, the notebooks;
7. the verification: Part VI 358/358, the three-integrator table, the scipy re-integrations, the
   physics controls;
8. the results, with all 16 figures from `latex/figures/`, which are copies of `results/*.png`,
   and the CPL fit and crossing tables;
9. the comparison with Unite;
10. dark matter and dark energy;
11. twelve limitations, which are the [rev] items of the design and the numerical caveats;
12. reproduction;
13. Appendix A: the CSV columns.

There are 20 references. Every number in it comes from the files named above. Build it with

```bash
cd "$(git rev-parse --show-toplevel)/fable-cosmology/latex"
latexmk -pdf -interaction=nonstopmode -halt-on-error fable_cosmology.tex
```

The build log is in section 8.5. latexmk's by-products (`.aux`, `.fls`, `.fdb_latexmk`, `.out`,
`.toc`, `fable_cosmology.log`, `latexmk.log`, `.synctex.gz`) are all ignored by `.gitignore`. The
`.tex` and the `.pdf` are not ignored:

```bash
cd "$(git rev-parse --show-toplevel)"
for f in fable_cosmology.tex fable_cosmology.pdf fable_cosmology.aux fable_cosmology.fls fable_cosmology.fdb_latexmk \
         fable_cosmology.out fable_cosmology.toc fable_cosmology.log latexmk.log fable_cosmology.synctex.gz; do
  r=$(git check-ignore -v "fable-cosmology/latex/$f"); echo "$f -> ${r:-NOT IGNORED}"; done
#   fable_cosmology.tex -> NOT IGNORED
#   fable_cosmology.pdf -> NOT IGNORED
#   fable_cosmology.aux -> .gitignore:132:*.aux	fable-cosmology/latex/fable_cosmology.aux
#   fable_cosmology.fls -> .gitignore:138:*.fls	fable-cosmology/latex/fable_cosmology.fls
#   fable_cosmology.fdb_latexmk -> .gitignore:139:*.fdb_latexmk	fable-cosmology/latex/fable_cosmology.fdb_latexmk
#   fable_cosmology.out -> .gitignore:134:*.out	fable-cosmology/latex/fable_cosmology.out
#   fable_cosmology.toc -> .gitignore:133:*.toc	fable-cosmology/latex/fable_cosmology.toc
#   fable_cosmology.log -> .gitignore:242:fable-cosmology/latex/fable_cosmology.log	fable-cosmology/latex/fable_cosmology.log
#   latexmk.log -> .gitignore:243:fable-cosmology/latex/latexmk.log	fable-cosmology/latex/latexmk.log
#   fable_cosmology.synctex.gz -> .gitignore:244:fable-cosmology/latex/fable_cosmology.synctex.gz	fable-cosmology/latex/fable_cosmology.synctex.gz
```

(These line numbers include the two comment corrections of section 8.10. Before them, each
number was one or two lower. The rules themselves are unchanged.)

## 8. What the run prints

Everything in this section was run on 2026-09-24, on Windows 11 in Git Bash, in the working
repository at commit `028b379`. Section 8.6 repeats the run in a fresh clone. The engine clone
is `https://github.com/once-ere/rustSolveIt_Win11_SUNDIALS_7_8_0.git @ a8fdff4`.

### 8.1 The solver's tests

```bash
cd "$(git rev-parse --show-toplevel)/fable-cosmology/rust/fable_cosmo"
cargo test --release
#       Finished `release` profile [optimized] target(s) in 0.01s
#        Running unittests src\main.rs (target\release\deps\fable_cosmo-b62d8d18cd3a087e.exe)
#
#   running 7 tests
#   test models::tests::x0_grid_rejects_the_singular_ends ... ok
#   test potentials::tests::spinor_derivatives_match_finite_differences_and_w ... ok
#   test models::tests::rho_plus_p_is_twice_the_kinetic_energy ... ok
#   test potentials::tests::scalar_derivatives_match_finite_differences ... ok
#   test models::tests::friedmann_closure_today ... ok
#   test models::tests::cpl_closed_form_matches_the_integral ... ok
#   test cvode_driver::tests::exponential_decay_to_tolerance ... ok
#
#   test result: ok. 7 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
./target/release/fable_cosmo.exe --version
#   fable_cosmo 0.1.0, sundials_rs 7.8.0 (pure Rust), CVODE BDF
```

The tests run in parallel, so their order changes from run to run.

### 8.2 The reproduction script

```bash
cd "$(git rev-parse --show-toplevel)"
bash fable-cosmology/run_all.sh
```

It printed the following, verbatim. It exited with code 0 after 51 s.

```
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
   (the same two warning lines)
[NbConvertApp] Writing 532514 bytes to notebooks\02_fable_spinor.ipynb
   executing notebooks/03_pre-universe_dynamics.ipynb
[NbConvertApp] Converting notebook notebooks/03_pre-universe_dynamics.ipynb to notebook
   (the same two warning lines)
[NbConvertApp] Writing 1089779 bytes to notebooks\03_pre-universe_dynamics.ipynb
   executing notebooks/04_dark_matter_dark_energy.ipynb
[NbConvertApp] Converting notebook notebooks/04_dark_matter_dark_energy.ipynb to notebook
   (the same two warning lines)
[NbConvertApp] Writing 318310 bytes to notebooks\04_dark_matter_dark_energy.ipynb
== 3. notebook requirements

4/4 notebooks pass all eight requirements
== 4. the paper
-rw-r--r-- 1 nsh 197121 2835881 Sep 24 19:31 fable_cosmology.pdf
== all done
```

The only abbreviation is `(the same two warning lines)`, which stands for the zmq
`RuntimeWarning` and the `[IPKernelApp] WARNING`, repeated verbatim as after notebook 01. These
come from the zmq and Jupyter libraries on Windows (the Proactor event loop and the kernel's TCP
transport), not from the notebooks. They change no output.

Two more details of this output:

- The empty line after `== 1. solver tests` is the first of the three lines that
  `cargo test … | tail -n 3` keeps.
- Step 4 found the PDF up to date, since the paper had just been built; the listed PDF was the
  build of 19:31. The PDF was later rebuilt from scratch with the final `.tex` (2,835,044 bytes;
  section 8.5).

### 8.3 The notebook checker, on the committed notebooks

```bash
cd "$(git rev-parse --show-toplevel)/fable-cosmology"
.venv/Scripts/python.exe notebooks/_build/nbcheck.py; echo "exit code $?"
#   4/4 notebooks pass all eight requirements
#   exit code 0
```

### 8.4 Reproducibility: the re-run against the commit

```bash
cd "$(git rev-parse --show-toplevel)"
git diff --stat -- fable-cosmology/results          # prints nothing
git status --short -- fable-cosmology/results       # prints nothing
```

**All 43 CSV files and 16 PNG figures under `fable-cosmology/results/` were byte-identical to
the committed ones.** No per-column comparison was needed, since no CSV differed. A column-by-column
comparison was run on every CSV all the same. The script, which is also the one given to
students, reads the committed file with `git show HEAD:<path>` and reports the maximum absolute
difference of every numeric column. It printed
`43 CSV files compared column by column against HEAD; files with any nonzero difference or
row-count change: 0`.

The four notebooks showed as modified. They were compared with their committed versions cell by
cell by a scratch script. For every code cell it compared the source, the execution count, the
stream text concatenated per stream, the `text/plain` results, the embedded PNGs and the errors.
It printed:

```
01_fableScalar_quintessence.ipynb: 38 cells; code cells whose metadata (execution timestamps) changed: 16; code cells whose outputs were split into a different number of stream chunks: 3; top-level keys changed: ['cells']
   sources, execution counts, concatenated stream text, results, images and errors: IDENTICAL
02_fable_spinor.ipynb: 35 cells; code cells whose metadata (execution timestamps) changed: 15; code cells whose outputs were split into a different number of stream chunks: 1; top-level keys changed: ['cells']
   sources, execution counts, concatenated stream text, results, images and errors: IDENTICAL
03_pre-universe_dynamics.ipynb: 29 cells; code cells whose metadata (execution timestamps) changed: 12; code cells whose outputs were split into a different number of stream chunks: 0; top-level keys changed: ['cells']
   sources, execution counts, concatenated stream text, results, images and errors: IDENTICAL
04_dark_matter_dark_energy.ipynb: 25 cells; code cells whose metadata (execution timestamps) changed: 10; code cells whose outputs were split into a different number of stream chunks: 1; top-level keys changed: ['cells']
   sources, execution counts, concatenated stream text, results, images and errors: IDENTICAL
```

So the notebooks differed only in two ways: each cell's `metadata.execution` timestamps, and
where the kernel happened to split a cell's printed output into stream chunks. In notebook 01's
λ-scan cell, for example, a leading space and a `# stats` line landed in separate chunks at
`λ = 0.9` instead of `λ = 1.6`. Since their content was identical, the committed notebooks were
restored, so that the commit stays clean:

```bash
git checkout -- fable-cosmology/notebooks/01_fableScalar_quintessence.ipynb fable-cosmology/notebooks/02_fable_spinor.ipynb \
                fable-cosmology/notebooks/03_pre-universe_dynamics.ipynb fable-cosmology/notebooks/04_dark_matter_dark_energy.ipynb
```

(The orchestrating session reported that another process on the machine had at some point killed
every `python.exe`. This run was not affected. `nbconvert` exited 0 for all four notebooks, the
checker passed, and the outputs above are complete and identical to the committed ones.)

### 8.5 The paper

```bash
cd "$(git rev-parse --show-toplevel)/fable-cosmology/latex"
latexmk -C                                                                    # remove every by-product and the PDF
latexmk -pdf -interaction=nonstopmode -halt-on-error fable_cosmology.tex > latexmk.log 2>&1; echo "latexmk exit $?"
#   latexmk exit 0
grep -c "Run number" latexmk.log                                              # 3   (three pdflatex passes)
grep -n -E "^!|LaTeX Warning|Package .* Warning|Overfull|Underfull|undefined" fable_cosmology.log   # prints nothing
grep "Output written" fable_cosmology.log
#   Output written on fable_cosmology.pdf (24 pages, 2835044 bytes).
tail -1 latexmk.log
#   Latexmk: All targets (fable_cosmology.pdf) are up-to-date
```

The build has no errors, no warnings, no undefined references or citations, and no overfull or
underfull boxes. The MiKTeX used was 26.5, with pdfTeX 4.27 and latexmk 4.88.

On Windows, `latexmk` from PowerShell fails with
`MiKTeX could not find the script engine 'perl' which is required to execute 'latexmk'`. Git
Bash supplies Perl, so `run_all.sh` works. For `run_all.ps1`, run
`$env:Path += ";C:\Program Files\Git\usr\bin"` first, which was checked to work, or install
Strawberry Perl. The student README says so.

### 8.6 A fresh clone

The repository at `028b379` was cloned locally into a scratch directory. Three files of this
session, as they stood then, were copied in: `fable-cosmology/README.md`,
`fable-cosmology/latex/fable_cosmology.tex` and `.gitignore`. The PDF was **not** copied. Then everything ran from nothing: a new venv, a new
engine clone from GitHub, a new build.

```bash
git clone -q <repo> fc && cd fc          # + the files named above
bash fable-cosmology/setup.sh            # exit code 0, 80 s
bash fable-cosmology/run_all.sh          # exit code 0, 61 s
```

`setup.sh` printed the following, verbatim apart from the scratch path, shortened to `…`:

```
== creating .venv
== installing Python requirements into .venv
WARNING: Cache entry deserialization failed, entry ignored
WARNING: Cache entry deserialization failed, entry ignored
WARNING: Cache entry deserialization failed, entry ignored
python ok: numpy 2.5.3 scipy 1.18.1 matplotlib 3.11.2
== cloning the engine (sparse: sundials_rs only) from https://github.com/once-ere/rustSolveIt_Win11_SUNDIALS_7_8_0.git
Cloning into 'rust/vendor/rustSolveIt'...
== engine: https://github.com/once-ere/rustSolveIt_Win11_SUNDIALS_7_8_0.git @ a8fdff4
== building rust/fable_cosmo (release)
   Compiling sundials_core v7.8.0 (…\fc\fable-cosmology\rust\vendor\rustSolveIt\sundials_rs\crates\sundials_core)
   Compiling cvode_rs v7.8.0 (…\fc\fable-cosmology\rust\vendor\rustSolveIt\sundials_rs\crates\cvode_rs)
   Compiling fable_cosmo v0.1.0 (…\fc\fable-cosmology\rust\fable_cosmo)
    Finished `release` profile [optimized] target(s) in 5.04s
fable_cosmo 0.1.0, sundials_rs 7.8.0 (pure Rust), CVODE BDF
== setup complete
```

The three `WARNING: Cache entry deserialization failed` lines come from pip's local download
cache. They are harmless. `run_all.sh` then printed the same lines as in section 8.2, with only
the byte counts of the rewritten notebooks and the time on the PDF line different:
`Writing 475211`, `532619`, `1089874`, `318492 bytes`,
`-rw-r--r-- 1 nsh 197121 2835881 Sep 24 19:38 fable_cosmology.pdf`, `4/4 notebooks pass all
eight requirements`, `== all done`. In the fresh clone the paper was built from source: three
pdflatex passes, `Output written on fable_cosmology.pdf (24 pages, 2835881 bytes)`, and no
overfull boxes. It had one underfull box in the bibliography, since fixed (section 8.5).

In the fresh clone, `git diff --stat -- fable-cosmology/results` printed nothing: all results
were byte-identical to the commit. The notebook comparison of section 8.4 gave the same verdict
with one addition. In each notebook, cell 6 prints the absolute `results directory:`, which is
the clone's own path.

### 8.7 The Mathematica reference integrations

The first run on 2026-09-24 (427 s) printed:

```
mathematica_scalar_exp.csv: 701 rows;  w(a=1) = -0.843363803931198

                               8
General::munfl: Exp[-5.96749 10 ] is too small to represent as a normalized machine number; precision may be lost.
   (two more General::munfl, for Exp[-5.79113 10^8] and Exp[-5.61997 10^8])
General::stop: Further output of General::munfl will be suppressed during this calculation.
mathematica_spinor_expdamp.csv: 701 rows;  w(a=1) = -0.8608456403776481  min w = -1.3020988149091868
```

The CSVs it wrote were byte-identical to the committed ones. **The cause of the messages.** In
Model B, the `H` column is `HB[n]` evaluated at an exact `n`, so it is an exact expression that
contains `Exp[-E^21/(221/100)]`. The CSV formatter `fmt[x_] := N[x]` sits outside the `Quiet` of
the table. Taking that expression to machine precision underflows the damped term, harmlessly:
`N[HB[-7]]` is `22740.499428716343` with or without the message, as a probe showed. **The fix**
is one line in `fable-cosmology/reference/make_reference.wls`:
`fmt[x_] := Quiet[N[x], General::munfl];`. The orchestrating session committed it as `028b379`.
Re-run (366 s), the script prints exactly the two lines quoted in section 6 and nothing else. The
two CSVs are again byte-identical to the committed ones.

### 8.8 Part VI, re-run

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
wolframscript -file run_from_nb.wls > <scratch>/part6_rerun.log 2>&1     # 152.4 s
```

The run ended:

```
identities accepted on numerical evidence alone : 0   (stage 3 returned True)
non-vanishing witnesses                         : 27   (…)
  PASS  no identity in this notebook was accepted on numerical evidence alone
Assertions run: 358   passed: 358   failed: 0
…
cells evaluated : 172
total seconds   : 152.388
cells w/ msgs   : 0
```

With the timings masked, the log is identical line for line to the committed
`run_fable51_part6.log`, apart from its last line (`RUN-DONE`, written by the original wrapper).
The notebook's `DumpSave` in Section 12 rewrites
`claude-fable/claude-fable_Einstein-Rosen-2-Planes-eLa.mx` and `…-eLazt.mx` on every evaluation
(the log says `wrote …-eLa.mx`). The output of `DumpSave` is not byte-reproducible. Against the
committed files, 2225 of the 2698 bytes of the `eLa` file differed, and the `eLazt` file grew
from 3144 to 3148 bytes. Whether the rewritten expressions are `SameQ` to the committed ones was
not checked, since that would need loading both. They were restored with
`git checkout -- claude-fable/claude-fable_Einstein-Rosen-2-Planes-eLa.mx claude-fable/claude-fable_Einstein-Rosen-2-Planes-eLazt.mx`.

### 8.9 The section-6 table, re-checked against the committed files

A scratch script read the committed CSVs and ran the one missing development run. It printed:

```
const: max|w+1| = 0.000e+00  Omega_phi(1) = 0.6999160000  H(1) = 1.000000000000011  t(1) = 0.963722
mass: max|w| = 0.000e+00  q_dec(1) = 0.5000420000  H(1) = 1.000000018302  t(1) = 0.666608
Model C quadratic: w_avg(100) = 0.004363  max|rho drift| = 3.269e-09
Model C quartic (x4<=100): w_avg(100) = 0.334909  max|rho drift| = 1.582e-08
Model D eps0.05: max|E_drift| = 4.482e-09
mathematica_scalar_exp.csv: 701 rows, w(a=1) = np.float64(-0.843363803931198)
mathematica_spinor_expdamp.csv: 701 rows, w(a=1) = np.float64(-0.8608456403776481), min w = np.float64(-1.3020988149091868) at a = 0.543351
Model A exp1 vs NDSolve: max|dw| = 1.149e-10  max|dt| = 5.428e-10
Model B expdamp vs NDSolve: max|dw| = 1.861e-08  max|dt| = 5.224e-09
quartic x4 in [0,200], 701 points: w_avg(200) = 0.334785  max|rho drift| = 1.152e-08   # stats: model=scalar-pre steps=5886 rhs_evals=7375 nonlin_iters=7372 err_test_fails=376
quartic x4 in [0,200], 2001 points: w_avg(200) = 0.334837  max|rho drift| = 8.767e-09   # stats: model=scalar-pre steps=5718 rhs_evals=7182 nonlin_iters=7179 err_test_fails=363
quartic x4 in [0,200], 4001 points: w_avg(200) = 0.334843  max|rho drift| = 3.488e-08   # stats: model=scalar-pre steps=6008 rhs_evals=7727 nonlin_iters=7724 err_test_fails=451
```

Together with the notebook outputs of section 7.4, this confirms every row of the section-6 table.
The scipy rows are `9.509e−11` (`exp λ = 1`) and `2.201e−8` / `1.006e−9` (`lorentz`). The
`mass` row's `q_dec(a=1) = 0.5` is `0.500042`: the radiation term.

### 8.10 Corrections made on 2026-09-24, and discrepancies left for the owners of other files

**Corrected on this page.**

- Section 3 and the heading of section 3 used to send the reader to `DESIGN.md` and the paper.
  Section 6 used to send the reader to `DESIGN.md` §4–5 and `fable-cosmology/README.md` for the
  command-line contract. Both pointers are removed, and the content is now on this page.
- The list of unit tests omitted `x0_grid_rejects_the_singular_ends`.
- The quoted output of `make_reference.wls` was one digit short and omitted the underflow
  messages.
- The command behind the quartic row of section 6 was not recorded; it is now.
- The section-6 table wrote `max|Δw|` inside table cells. GitHub splits a table row at every
  unescaped `|`, even inside a code span, so those rows rendered with the wrong number of cells.
  The pipes are now escaped (`max\|Δw\|`). The same fix was made to one row of the table in
  `DESIGN.md` §7 (`\|wa\|`).

**Corrected in `fable-cosmology/DESIGN.md`**, marked `[corr 2026-09-24]` there:

- `G0 = C²/2` → `G0 = C² Sin[6Hx0]²/2`, as Part VI asserts.
- The reference `expdamp`'s "min `w ≈ −1.27` near `z ≈ 1`" → `−1.302` at `a = 0.543`
  (`z = 0.84`).
- "Cai & Wang, JCAP 2008" → Class. Quantum Grav. 25 (2008) 165014, arXiv:0806.3890. This was
  verified at the publisher: IOP, doi 10.1088/0264-9381/25/16/165014.
- The CSV number format "15 significant digits" → `{:.15e}`, 16 significant digits.
- The exit code of an unknown model or potential is 1, not 2.
- The reference CSVs are written by `make_reference.wls` and checked, not written, by Part VI.

**Corrected in `fable-cosmology/reference/make_reference.wls`** (committed as `028b379`): the
underflow messages (section 8.7).

**Corrected in `.gitignore`** (comments only; no rule changed):

- Section 3 said "There are no .tex sources in this repository". It now names the one there is,
  and says that its by-products are scoped by name in section 4.
- The header's count "42 of its 118 tracked files are .log" is dated. On 2026-09-24 the count was
  51 of 232.

No new ignore rule was needed.

**Left for the owners of files this session was told not to touch.** These are reported, not
changed.

- `fable-cosmology/notebooks/_build/nbgen.py` (and so the executed notebooks):
  - Notebook 03's section 3 states `G0 = C²/2` (it should be `C² Sin[6Hx0]²/2`).
  - Notebooks 01 and 02 say the reference CSVs "were written by Part VI of the Mathematica
    notebook (`reference/make_reference.wls`)". They are written by `make_reference.wls` and
    checked by Part VI.
  - Notebook 01's section 5 says the CSV has "15 significant digits" (it has 16).
  - The three notebooks' section-5 text says exit code 2 for "a usage error". That is right for a
    malformed command line, but an unknown model or potential exits 1.
**Fixed afterwards on 2026-09-24, in the commit that records this page.** These were three of
the reported items:

- `claude-fable/cells_part6.wl`, in a Text cell of Section 24: "(Cai & Wang, JCAP 2008)" now
  reads "(Cai & Wang, Class. Quantum Grav. 25 (2008) 165014)". The change is to text only; no
  Input cell is affected. The notebook `.nb` is generated from the manifests, and Part VII was
  being built in the same directory at the time. The rebuilt notebook therefore carries the
  corrected text from the commit that adds Part VII.
- `fable-cosmology/setup.sh` used to create the venv with `python`, which does not exist on many
  macOS and Linux systems. It now uses `python3` when that runs, and `python` otherwise.
- `fable-cosmology/run_all.ps1` did not stop when `cargo test` failed. PowerShell's
  `$ErrorActionPreference = "Stop"` does not apply to native commands. The script now checks
  `$LASTEXITCODE` after `cargo test` and throws, as it already did for the other steps.

**The four `nbgen.py` items above were fixed on 2026-09-24, with the notebooks of the
fermion-fable work.** The generator `fable-cosmology/notebooks/_build/nbgen.py` now says:

- notebook 03, section 3: `G0 = C² Sin[6Hx0]²/2` (as Part VI asserts), independent of `x4` and
  therefore constant for the observer at fixed `x0`;
- notebooks 01 (section 5.8) and 02 (section 5.10): the reference CSV "was written by
  `fable-cosmology/reference/make_reference.wls` (a wolframscript) and is checked by Part VI of
  the Mathematica notebook, which reads it back";
- notebook 01, section 5: every number is written as `{:.15e}`, "15 decimals, i.e. 16
  significant digits";
- notebooks 01, 02 and 03, section 5: exit code 1 is a solver or physics error "and also an
  unknown model or potential name"; exit code 2 is "a malformed command line (an unknown option,
  or a missing or non-numeric value)". This was checked against the binary before the text was
  written: `fable_cosmo nosuchmodel` and `fable_cosmo spinor-flrw --potential nosuch` exit 1,
  `fable_cosmo spinor-flrw --bogus` and `fable_cosmo spinor-flrw --points x` exit 2.

How this was verified. The four notebooks were regenerated with
`.venv/Scripts/python.exe notebooks/_build/nbgen.py 01 02 03 04` and re-executed in place with
`nbconvert --execute --inplace` (7 s, 7 s, 53 s and 6 s). None of the stale phrases occurs in the
executed notebooks any more (`grep -c` finds 0 in each). `nbcheck.py` reports `4/4 notebooks pass
all eight requirements`. The re-execution rewrote every CSV and PNG under
`fable-cosmology/results/` that the four notebooks own, and all 59 are byte-identical to the
committed files: `git diff --stat -- fable-cosmology/results` is empty, and the SHA-256 of each
file equals that of its `HEAD` blob (`checked 59 files, 0 differ`). The corrections are to
markdown text only; no code cell and no result changed.

**Not done in this session.** The author's instruction "verify the pushed repo runs from a fresh
clone" needs the files of this session to be committed and pushed first. Section 8.6 is a local
fresh clone of `028b379`, with this session's files copied in. It exercises the same path
(setup from nothing, engine clone from GitHub, build, every notebook, checker, paper). The clone
of the pushed repository is left to the push.

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
   clean (no warnings, no overfull or underfull boxes); the numbers in section 8. On 2026-09-24
   one more warning was found and fixed: the `General::munfl` messages of `make_reference.wls`
   (section 8.7). The warnings that remain in a run are those of third-party libraries on
   Windows: pip's cache warning, and zmq's and ipykernel's warnings under `nbconvert` (sections
   8.2 and 8.6). They come from neither the code nor the notebooks of this work.
