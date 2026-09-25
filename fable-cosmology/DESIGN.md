# fable-cosmology — design specification, revision 2 (2026-09-16, after the physics review)

This is the specification every part of the work is built to: the physics, the conventions, the
numerical models, the file layout, the command-line contract of the solver, and the verification
plan. Revision 1 was reviewed adversarially (two independent reviewers, 30 findings, all checked
by hand and against the notebook); every accepted correction is in this revision and marked
**[rev]** where it changed a claim. Where a later result contradicts something here, the result
wins and this file is corrected.

## 0. The task, verbatim in its operative parts

> Define a new scalar field named fableScalar, inspired by Quintessence, that fills space and
> evolves over time, and that provides a physical mechanism for a time-varying dark energy
> equation of state (wScalar). Define a new 16-component spinor field named fable, also inspired
> by a generalization of Quintessence, that fills space and evolves over time, and that provides
> a second physical mechanism for a time-varying dark energy equation of state (w). Define, verify
> and test the correct Lagrangian and energy-momentum tensor for fableScalar. Then define its
> kinetic energy, potential energy, pressure and energy density and wScalar. [Same for fable.]
> In detail, investigate and determine and discuss (use numerical solutions and graphs) whether
> the physical behavior and changing nature of w and/or wScalar in this framework. Answer the
> questions: is there any connection to dark matter and/or dark energy? Create precise scientific
> documentation that provides detailed instructions to an ignorant student for setting up and
> solving your numerical solutions, in entirety. If possible, employ Jupyter notebooks from
> [the three rustSolveIt repositories] in your solution. In addition to Jupyter notebooks, create
> complete documentation using markdown files, and also latex files that are compiled to pdf.
> Then verify the pushed repo runs from a fresh clone.

The author's reference on the observational side is his Gmail printout of 2026-09-15 (kept
unpublished on his disk): the Chevallier–Polarski–Linder (CPL) parameterisation
`w(a) = w0 + wa (1 − a)`; the Supernovae *Unite* fits `w = −0.764` (constant-w, supernovae
alone, 2σ from −1) and `(w0, wa) = (−0.861, −0.60)` (time-varying: the CPL line extrapolates to
`w = −1.46` at `a → 0`, rises through −1 at `a = 0.768` and reaches −0.861 today — **[rev]** the
"phantom past" is the extrapolation of a straight line beyond the supernova range `a ≳ 0.3`,
not a measurement of `w < −1`); canonical quintessence `L = ½∂φ∂φ − V`, `ρ = ½φ̇² + V`,
`P = ½φ̇² − V`, `w = P/ρ`, `φ̈ + 3Hφ̇ + V' = 0`; thawing vs freezing; and the fact that a
canonical field cannot cross the phantom divide.

**Symbols.** `H` is the notebook's constant (it multiplies `6 H x0` in the frame and appears as
`1/H` and `2M/H` in the author's Lagrangian). `H_obs ≡ ȧ/a` is the Hubble rate of the observed
sheet. `H(a)` in the numerical models is `H_obs` in units `H0 = 1`. Nothing in this document, in
Part VI, or in the solver gives the notebook's undetermined function `a4` a value.

## 1. The framework this is built in

Everything lives on the 4+4 pre-universe of `claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb`
(Parts III–V): coordinates `X = {x0,…,x7}`, flat metric `eta4488 = diag(+1,+1,+1,+1,−1,−1,−1,−1)`,
canonical frame `e = diag(Tan[6 H x0], q, q, q, 1, p, p, p)`,

    q = Exp[−a4[H x4]] / Sin[6 H x0]^(1/6),    p = Exp[+a4[H x4]] / Sin[6 H x0]^(1/6),

curved metric `g = e . eta . eᵀ = diag(Tan², q², q², q², −1, −p², −p², −p²)`, and
`Sqrt[det g] = Sec[6 H x0]` (`0 < 6 H x0 < π/2`). Two facts of the geometry drive everything
below and are proved in the notebook already:

- **The 8-volume element is independent of x4**: the observed 3-space `(x1,x2,x3)` scales as `q`
  while the second sheet `(x5,x6,x7)` scales as `p ∝ 1/q` (up to the common `Sin` factor), so
  `q³ p³ = 1/Sqrt[Sin[6Hx0]]` does not change. It factorises as
  `Sqrt[g_8] = q³ · (Tan[6Hx0] p³)`: observed 3-volume times hidden 4-volume density **[rev]**.
- **On the canonical frame the spin connection contributes nothing to the Dirac Lagrangian of the
  real 16-spinor** (Part V, `Ψᵀ sigma16 gamma^μ Gamma^spin_μ Ψ == 0`). **[rev]** This is a
  property of the frame, not of the spinor: it holds because `gamma^μ Gamma^spin_μ = −½ T_μ gamma^μ`
  is a single-gamma term there (`sigma16 . T16[a]` is antisymmetric), and would fail on a frame
  whose spin connection has a totally antisymmetric part (`sigma16 . T16[a] . T16[b] . T16[c]` is
  symmetric). It licenses the *Lagrangian* identities below; it does not license dropping the
  connection from the energy–momentum tensor (§3).

**Time and the scale factor.** The cosmological time is `t ≡ x4` (`g44 = −1`, proper time of the
geodesic observer `u = ∂_4`, along whose worldline `x0` is constant). The x1–x3 frame entry at
fixed `x0` is the observed scale factor:

    a(t) ≡ q|_{x0 fixed} ∝ Exp[−a4[H t]],     ln a = −a4[H t] + const,     H_obs = −H a4'[H t].

**[rev]** This is a *kinematic identification only*: `a4` stays undetermined, the observed sheet
expands (`H_obs > 0`) in the regime `a4' < 0`, which is the regime assumed throughout (Section 15
of the notebook reads the same frame the other way round; the sign is a hypothesis, not a
result), and the 4-dimensional reference models of §4 do **not** live on the pre-universe: their
`a(t)` comes from a Friedmann equation with Hubble friction, which the pre-universe does not
have, and it is never substituted for `a4`.

**Energy components.** For the observer `u = ∂_4`, with the Hilbert (metric-variation) tensor:

    ρ ≡ T_{44},     P_i ≡ T^i_i (no sum, i = 1,2,3),     P ≡ (P_1 + P_2 + P_3)/3,     w ≡ P/ρ   (defined where ρ > 0).

Both fields are homogeneous on the observed sheet, so `P_1 = P_2 = P_3`. In the notebook's
Wolfram indices `x4` is entry 5: `ρ = T[[5,5]]`, `P_1 = gInvCanonical[[2,2]] T[[2,2]]`.

## 2. fableScalar — the scalar field

**Definition.** A real scalar `fableScalar ≡ φ(x)` on the 8-manifold, minimally coupled, with a
self-interaction potential `V(φ)`:

    L_φ = Sqrt[det g] · L̂_φ,        L̂_φ = −½ g^{μν} ∂_μφ ∂_νφ − V(φ).

The sign makes the x4-kinetic term positive: `−½ g^{44} φ̇² = +½ φ̇²`.

**Field equation.** `□φ = V'(φ)`, `□ = (1/Sqrt[g]) ∂_μ (Sqrt[g] g^{μν} ∂_ν)`; on the pre-universe

    −φ̈ + Cos[6Hx0] ∂_0( Sec[6Hx0] Cot[6Hx0]² ∂_0 φ ) + (1/q²)(∂_1²+∂_2²+∂_3²)φ − (1/p²)(∂_5²+∂_6²+∂_7²)φ = V'(φ).

**Energy–momentum tensor** (`T_{μν} = −(2/Sqrt[g]) δS/δg^{μν}`):

    T_{μν} = ∂_μφ ∂_νφ + g_{μν} L̂_φ.

Verified in Part VI (and already in the prototype): symmetric; the **off-shell identity**
`∇^μ T_{μν} = (□φ − V'(φ)) ∂_νφ` for a generic `φ(x0,…,x7)` (so conservation on shell is exact
and needs no assumption); trace `T^μ_μ = −3 (∂φ)² − 8V`.

**Kinetic, potential, gradient energies, density, pressure, w.** For a field depending on
`x0, x4` and the second-sheet coordinates:

    KE  = ½ φ̇²                              (x4 kinetic energy)
    PE  = V(φ)                              (potential energy)
    G0  = ½ Cot[6Hx0]² (∂_0 φ)²             (gradient energy along the hidden coordinate x0)
    G5  = ½ (1/p²) Σ_{i=5,6,7} (∂_i φ)²      (gradient energy along the second, TIMELIKE sheet)

    ρ_φ  = KE + PE + G0 − G5
    P_φ  = KE − PE − G0 + G5                 (and, along x0 itself, P_0 = KE − PE + G0 + G5)
    wScalar ≡ w_φ = P_φ / ρ_φ.

Consequences, each an assertion in Part VI:

1. **The usual quintessence formulas** are the `G0 = G5 = 0` case. **The null energy condition
   holds identically**: `ρ_φ + P_φ = 2 KE ≥ 0`. **[rev]** Hence `w_φ ≥ −1` *wherever `ρ_φ > 0`*,
   which is guaranteed for `V ≥ 0` and any field independent of `x5, x6, x7`. Gradients along the
   timelike second sheet enter `ρ_φ` negatively (`−G5`): that sector can have `ρ_φ < 0`, and it is
   excluded from every statement about `w` in this work. fableScalar never has `w_φ < −1` with
   `ρ_φ > 0`: it cannot cross the phantom divide.
2. **No Hubble friction in x4.** For `φ = φ(x4)`: `φ̈ = −V'(φ)`, because `Sqrt[g] g^{44} = −Sec[6Hx0]`
   is x4-independent. `ρ_φ` is then conserved in `x4`; the field oscillates undamped and `w_φ(t)`
   oscillates between −1 and +1 with the virial average `⟨w⟩ = (n − 1)/(n + 1)` for `V ∝ φ^{2n}`
   (`⟨w⟩ = 0` for the mass term, exactly, from `φ = A Cos[m x4]`, `w = −Cos[2 m x4]`).
3. **A static x0 profile is a cosmological constant *on the observed sheet*.** With `V = 0`,
   `∂_0(Sec Cot² ∂_0φ) = 0` has the solution `∂_0φ = C Sin[6Hx0]²/Cos[6Hx0]`, so `G0 = C²/2` is
   constant, and `ρ = G0`, `P_1 = −G0`, `w = −1` exactly. **[rev]** Along the hidden direction
   itself `P_0 = +G0 = +ρ`, so in eight dimensions this is an anisotropic stress, not a Λ term;
   the Λ-like behaviour is a statement about the observed sheet.
4. **The 4-dimensional reference model and the volume bookkeeping. [rev]** Integrating the
   8-dimensional action over the hidden coordinates gives `S_4 = ∫ d⁴x a³ 𝒱_hid(t) L̂` with the
   hidden 4-volume density `𝒱_hid ∝ Tan[6Hx0] p³ ∝ e^{3 a4} = a^{−3}` (defined up to the formal
   integral over the three non-compact timelike directions). The reduced tensor
   `T^{(4)}_{μν} = 𝒱_hid T^{(8)}_{μν}` has `ρ_4 ∝ a^{−3} ρ_8` and `P_4 = w_φ ρ_4`, and is **not**
   separately conserved (`ρ̇_4 + 3H_obs(ρ_4 + P_4) = 3H_obs P_4`: energy flows into the contracting
   sheet). The `a^{−3}` is a volume effect that holds for every `w_φ`; it is *not* a dark-matter
   signature (a cosmological constant would pass the same test). The locally measured density of
   the observer, `T_{44} = ρ_8`, is exactly constant. Which of the two gravitates is undetermined:
   the framework has no gravitational sector (no Einstein equations, `a4` free). The **standard
   quintessence model** — `φ̈ + 3Hφ̇ + V' = 0` with the Friedmann equation — is what one obtains
   when the hidden volume is held fixed and the field sources the expansion; it is the reference
   model of the PDF and of the CPL fits, and it is what Model A integrates.

## 3. fable — the 16-component spinor field

**Definition.** `fable ≡ Ψ(x)`, a real 16-component spinor on the 8-manifold, transforming under
`Spin(4,4)` exactly as the model's `Ψ16` of Section 11, with the notebook's Dirac matrices `T16[a]`,
the spinor metric `\[Sigma]16` (symmetric; `\[Sigma]16 . T16[a]` antisymmetric), curved Dirac
matrices `gamma^μ = coframe[[a,μ]] T16[a]`, the scalar bilinear `s ≡ Ψᵀ . \[Sigma]16 . Ψ`, and a
self-interaction potential `V(s)`:

    L_Ψ = Sqrt[det g] · L̂_Ψ,        L̂_Ψ = (1/H) Ψᵀ . \[Sigma]16 . gamma^μ . D_μΨ − V(s),     D_μ = ∂_μ + Gamma^spin_μ.

On the canonical frame the `Gamma^spin` term is identically zero in `L̂_Ψ` (Part V), so
`L̂_Ψ = (1/H) Ψᵀ \[Sigma]16 gamma^μ ∂_μΨ − V(s)` there. The author's `La` of Section 11 is the case
`V(s) = −(2M/H) s`, flat frame, no volume factor — a **fidelity anchor**: with `V = −(2M/H)s`,
`frame → ID8`, `Sqrt[g] → 1`, `L̂_Ψ` is `La[]` and its Euler–Lagrange equations are the author's
`eLa` of Section 12 (both verified in the prototype).

**Field equation.** Varying `Ψ` (kinetic matrix `A^μ ≡ \[Sigma]16 . gamma^μ` antisymmetric, mass
matrix `\[Sigma]16` symmetric, transposed term integrated by parts against `Sqrt[g] A^μ`):

    gamma^μ ∂_μ Ψ + ½ (1/Sqrt[g]) ∂_μ( Sqrt[g] gamma^μ ) Ψ = H V'(s) Ψ.

**[rev]** In general `(1/Sqrt[g]) ∂_μ(Sqrt[g] gamma^μ) = [gamma^μ, Gamma^spin_μ]`, so the second
term is `gamma^μ Gamma^spin_μ Ψ − ½{gamma^μ, Gamma^spin_μ}Ψ`; on the canonical frame the
anticommutator vanishes (no totally antisymmetric part of the connection) and the equation is
exactly the **Levi-Civita covariant Dirac equation** `gamma^μ D_μ Ψ = H V'(s) Ψ`. On this geometry
the term is `−3H Cot[6Hx0]² T16[0] Ψ`; in FLRW the same term is the familiar `(3/2) H_obs gamma^4 Ψ`.
It does not vanish for a spinor independent of `x0`, so **a spinor homogeneous in every coordinate
but x4 is not a solution.** Part V's rescaling `Ψ = Sqrt[Sin[6Hx0]] Ψ'` removes the term exactly:
`gamma^μ ∂_μ Ψ' = H V'(s) Ψ'` with `s = Sin[6Hx0] · Ψ'ᵀ \[Sigma]16 Ψ'`. **[rev]** `Ψ' = Ψ'(x4)` is
then an exact solution only when `V'` is constant (the mass term and the `lambda-mass` term);
for a nonlinear `V` the potential varies with `x0` through `Sin[6Hx0]` and the exact problem is the
`(x0, x4)` system for `Ψ'(x0, x4)`.

**Energy–momentum tensor** (frame variation of the covariant action; **[rev]** the variation of
the spin connection gives a term antisymmetric in `μν` that drops from the symmetrised tensor, so
the tensor is the symmetrised kinetic bilinear built with the *covariant* derivative):

    T_{μν} = −(1/2H) ( Ψᵀ \[Sigma]16 gamma_μ D_νΨ + Ψᵀ \[Sigma]16 gamma_ν D_μΨ ) + g_{μν} L̂_Ψ,     gamma_μ = g_{μν} gamma^ν.

The tensor built with `∂_ν` instead of `D_ν` has the same diagonal (so the same `ρ` and `P`) but
differs in off-diagonal components and is not the conserved one; Part VI asserts both facts
(symmetry, on-shell conservation of the `D_ν` tensor for a generic `Ψ(x0, x4)` by explicit
substitution of the field equation, and a witnessed difference on an off-diagonal component).

**Kinetic energy, potential energy, density, pressure, w.** Define

    K_Ψ ≡ (1/H) Ψᵀ \[Sigma]16 gamma^4 ∂_4Ψ         (the kinetic bilinear along the observer's time)
    K_h ≡ −(1/H) Ψᵀ \[Sigma]16 gamma^0 ∂_0Ψ        (the kinetic bilinear along the hidden coordinate)  [rev]
    U_Ψ ≡ V(s)                                     (potential energy)

For a field homogeneous on the observed sheet (`∂_iΨ = 0`, `i = 1,2,3,5,6,7`), on shell:

    L̂_Ψ = s V'(s) − V(s),      ρ_Ψ = V(s) + K_h,      P_Ψ = s V'(s) − V(s),      w ≡ w_Ψ = P_Ψ/ρ_Ψ.

**[rev]** `K_h` vanishes for `Ψ = Sqrt[Sin[6Hx0]] Ψ'(x4)` (the identity `Ψ'ᵀ \[Sigma]16 T16[0] Ψ' = 0`),
i.e. exactly for the solutions with constant `V'`, and then `ρ_Ψ = V(s)`,
`w_Ψ = s V'(s)/V(s) − 1`; `ρ_Ψ > 0` requires `V(s) > 0`. Consequences (assertions in Part VI):

1. **The author's mass term is dust.** `V = −(2M/H) s`: `w_Ψ = 0` identically, `ρ = −(2M/H)s`
   (positive on the branch `M s < 0`). The spinor of the original model, promoted to a
   cosmological field, is **pressureless: cold dark matter**. Exact.
2. **`w_Ψ` is not bounded below by −1.** `w = s V'/V − 1` is `n − 1` for `V ∝ s^n`: `n = 1` dust,
   `0 < n < 2/3` accelerating (`n = 0.236` gives Unite's constant-w value −0.764 exactly), `n < 0`
   phantom. A potential whose slope changes sign at `s*` with `V(s*) > 0` lets `w_Ψ` **cross the
   phantom divide** with no wrong-sign kinetic term — the classical mechanism of the spinor
   quintom (Cai & Wang, JCAP 2008). **[rev]** The stability of perturbations is not examined here.
3. **No dilution in the pre-universe.** For `Ψ' = Ψ'(x4)`: `∂_4Ψ' = −H V'(s) gamma^4 Ψ'`
   (`(gamma^4)² = −ID16`), so `ds'/dx4 = −2HV' Ψ'ᵀ\[Sigma]16 gamma^4 Ψ' = 0` and `s = Sin[6Hx0] s'`
   is constant in `x4`; Part VI also proves `ds/dx4 = 0` on shell for a generic `Ψ(x0, x4)`.
4. **The 4-dimensional reference model.** On a separate FLRW frame `diag(1, a(t), a(t), a(t), 1, 1, 1, 1)`
   (never a substitution into the canonical frame) the Dirac equation carries `(3/2) H_obs gamma^4`
   and `d(a³ s)/dt = 0`, i.e. `s = s_0 a^{−3}`; then `w_Ψ(a)` is the **algebraic** function
   `s V'(s)/V(s) − 1` on `s = s_0 a^{−3}`, and the whole history is fixed by `V`. Model B.

**Potentials for fable used in the numerics** (`m, λ, V0 > 0`):

| name | `V(s)` | `w_Ψ(s)` | behaviour with `s = s_0 a^{−3}` |
|---|---|---|---|
| `mass` | `m s` | `0` | dust at all times (the author's model) |
| `lambda-mass` | `V0 + m s` | `−V0/(V0 + m s)` | dust early → −1 late. **[rev]** `V0` is a bare cosmological constant in the action, present with or without the spinor: this is ΛCDM with the dust supplied by the spinor, not field-driven dark energy; `Ω_Λ ≡ V(0)/3` is reported separately |
| `power` | `m s + λ s^n` | `(m s + nλ s^n)/(m s + λ s^n) − 1` | for `n < 1`: dust → `n − 1` (accelerating for `n < 2/3`; the field-driven dark energy of this class); reversed order for `n > 1` |
| `hilltop` | `V0 − μ (s − s*)²` | `−2μ s (s − s*)/V − 1` | crosses −1 at `s = s*`; **[rev]** unbounded below: valid only on `s < s* + Sqrt[V0/μ]`, i.e. late times; a local textbook form, run only inside its window |
| `lorentz` | `V0 + m s/(1 + (s/s1)²)` | `m s(1 − u)/((1+u)² V) − 1`, `u = (s/s1)²` | **positive everywhere**; `w → −1⁻` as `s → ∞`, minimum below −1, crosses −1 at `s = s1`, `w → −1⁺` as `s → 0` |
| `expdamp` | `V0 + m s e^{−s/s1}` | `m s e^{−s/s1}(1 − s/s1)/V − 1` | **bounded below by V0**; the same crossing pattern at `s = s1`; with `(V0, m, s1) = (1.566, 0.839, 2.21)` the run gives `w(1) = −0.861`, min `w ≈ −1.27` near `z ≈ 1`, crossing at `a = 0.768` |

## 4. The numerical models (what the solver integrates)

Units: `M_pl² = 1/(8πG) = 1`, `H0 = 1` (time in `1/H0`), `a0 = 1`, so `ρ_crit,0 = 3 H0² M_pl² = 3`;
`Ω_i` are fractions of it, densities are in those units: `ρ_m = 3 Ω_m0 e^{−3N}`,
`ρ_r = 3 Ω_r0 e^{−4N}`. Independent variable `N = ln a`. **[rev]**

    H² = ( ρ_m + ρ_r + ρ_field ) / 3  =  Ω_m0 e^{−3N} + Ω_r0 e^{−4N} + ρ_field/3,      so H(N = 0) = 1 exactly.

Cosmic time is carried as a state variable, `dt/dN = 1/H`, from `N0`; **[rev]** the age at `N0` is
added analytically as `t_age(N0) = 1/(2 H(N0))` (the exact age of a radiation-dominated universe
with that Hubble rate; `≈ 2.2e-5/H0` at `N0 = −7`, negligible, but stated and printed).

**Initial conditions [rev].** Every FLRW run starts at `N0 = −7` (`a ≈ 9.1e-4`, deep radiation
era) from rest, `φ̇(N0) = 0` (the frozen start; the standard thawing initial condition), at a
value `φ_i` that is printed by the solver and can be overridden with `--param phi_i=… --param phidot_i=…`:
`exp`: 0, `invpower`: 0.2, `pngb`: `0.5 f`, `quadratic`: 1, `hilltop`: `0.1 μ`, `const`: 0. Whether
a run thaws or freezes is **read off the sign of `dw/dN` over the fit range** (Caldwell–Linder
`w′–w` plane), not assumed from the potential's name: with a frozen start the exponential potential
thaws; the inverse power freezes only if it joins its tracker, which the notebook tests by starting
earlier (`--n0 -25`) or on the tracker.

**Model A — fableScalar, standard 4-dimensional reference (self-consistent).**
State `y = (φ, φ̇, t)`: `dφ/dN = φ̇/H`, `dφ̇/dN = −3φ̇ − V'(φ)/H`, `dt/dN = 1/H`. Outputs per point:
`a, z, N, t, φ, φ̇, H, KE, PE, ρ_φ, P_φ, w_φ, Ω_φ, Ω_m, Ω_r, q_dec` with `q_dec = −1 − (dH/dN)/H`.
Potentials `exp` (`V0 e^{−λφ}`), `invpower` (`V0 φ^{−α}`), `pngb` (`V0 (1 + cos(φ/f))`),
`quadratic` (`½m²φ²`), `hilltop` (`V0 (1 − φ²/μ²)`, used where `V > 0`), `const` (`V0`, the
control: `w = −1`). **Normalisation [rev]**: the overall scale of `V` is found by *shooting* —
bisection on `log10 k`, `V → k V`, 80 iterations or `Δlog10 k < 1e-13`, bracket `[10^{−6}, 10^{6}]`,
error exit if `Ω_φ(a=1) = 1 − Ω_m0 − Ω_r0` is not bracketed (the oscillating `quadratic` case is
not monotone: it is run with `--no-normalize` and hand-chosen parameters). Rescaling is not a
symmetry of the equations, which is why shooting is needed. The solver exits non-zero if `ρ_φ ≤ 0`
anywhere on the run.

**Model A′ — fableScalar as a test field on the Unite CPL background.** Same equations, `H` from
`H² = Ω_m0 e^{−3N} + Ω_r0 e^{−4N} + Ω_DE0 f(a)`, `f(a) = ρ_DE(a)/ρ_DE0 = exp(3∫_a^1 (1 + w(a′)) da′/a′) = a^{−3(1+w0+wa)} e^{−3 wa (1−a)}`
(unit-tested against the integral; `f(1) = 1`). The field does not source `H`; its scale is fixed
so that `ρ_φ(a=1)/3 = Ω_DE0`, for comparability with Model A. Output adds `w_cpl(a)`.

**Model B — fable, standard 4-dimensional reference.** State `y = (s, t)`, `ds/dN = −3 s`
(exact), `dt/dN = 1/H`, `H² = Ω_m0 e^{−3N} + Ω_r0 e^{−4N} + V(s)/3`. Normalisation: `V → k V` with
`V(s_0) = 3 Ω_Ψ0` at `a = 1` (`s_0 = 1`; this rescaling leaves `w(s)` unchanged, exactly). The
solver exits non-zero if `V(s) ≤ 0` at any output point (or at the start). Outputs `a, z, N, t, s,
H, K_Ψ (= sV'), U_Ψ (= V), ρ_Ψ, P_Ψ, w_Ψ, Ω_Ψ, Ω_m, Ω_r, q_dec`.

**Model C — fableScalar on the pre-universe, homogeneous in x4.** `φ̈ = −V'(φ)`, state `(φ, φ̇)`
in `x4`, CVODE Adams; outputs `KE, PE, ρ, P, w(x4)`, the running average of `w`, and the drift of
`ρ` (must be at solver precision). The virial average of the quadratic potential must approach 0.

**Model D — fableScalar on the pre-universe with an x0 profile (method of lines). [rev]**
`φ(x0, x4)` on a grid `x0_j ∈ [x0_min, x0_max] ⊂ (0, π/12)` (`H = 1`; default `[0.05, 0.22]`,
i.e. `6Hx0 ∈ [0.3, 1.32]`), flux form `φ̈_j = Cos_j (F_{j+½} − F_{j−½})/h − V'(φ_j)` with
`F_{j+½} = c_{j+½}(φ_{j+1} − φ_j)/h`, `c = Sec Cot²` at the half points, zero flux at both ends
(Neumann), CVODE Adams. The quantity conserved exactly by this semi-discrete scheme is
`E_h = Σ_j Sec_j h (KE_j + PE_j) + Σ_{j+½} ½ c_{j+½}(φ_{j+1} − φ_j)²/h` (summation by parts), and the
solver reports it and its drift (`< 1e-8` in the runs). Sheet averages are weighted by the volume
element `Sec[6Hx0]`: `w_sheet ≡ ⟨P⟩/⟨ρ⟩`, never `⟨P/ρ⟩`; the mid-grid local `w` is also reported.

**Model E — fable on the pre-universe.** `ds/dx4 = 0` is exact; no integration. Proved in Part VI.

**CPL fit.** For every run of Models A, A′, B: unweighted least squares of `w(a)` to
`w0 + wa (1 − a)` over `a ∈ [0.3, 1]` (`z ≤ 2.33`, the supernova range), reported with the true
`min w`, `w(a = 0.3)`, `w(1)`, and the CPL extrapolation `w0 + wa`, next to Unite's `(−0.861, −0.60)`,
`w0 + wa = −1.46`, and the constant-w value `−0.764`. The notebooks plot the true `w(a)` and the
fitted line on the same axes.

## 5. The solver: `fable-cosmology/rust/fable_cosmo` (pure-Rust SUNDIALS 7.8.0 CVODE)

A Rust crate that depends on the vendored engine of the rustSolveIt repositories exactly as their
own `planet_Mercury/mercury_rs` does — path dependencies on `sundials_core` and `cvode_rs` — and
pins `-C target-feature=+fma` in its own `.cargo/config.toml` as the engine requires. The engine is
a sparse clone (`sundials_rs` only, 2.6 s) of the rustSolveIt repository **for the student's
platform**, at `fable-cosmology/rust/vendor/rustSolveIt` (git-ignored; `setup.sh` / `setup.ps1`
make it):

| platform | repository |
|---|---|
| Windows 11 x86-64 | `https://github.com/once-ere/rustSolveIt_Win11_SUNDIALS_7_8_0.git` |
| macOS Apple Silicon | `https://github.com/once-ere/rustSolveIt_macos-silicon_SUNDIALS_7_8_0.git` |
| Linux x86-64 | `https://github.com/once-ere/rustSolveIt_linux_SUNDIALS_7_8_0.git` |

Integrator: CVODE, BDF + Newton + dense for the FLRW models, Adams for the undamped pre-universe
models (`--method` overrides), `rtol = 1e-10`, `atol = 1e-12` (rustSolveIt's defaults),
finite-difference Jacobian, `CVodeSetStopTime`, outputs at prescribed abscissae via `CV_NORMAL`.

**Command-line contract** (every notebook uses exactly this):

    fable_cosmo <model> [--potential NAME] [--param KEY=VALUE ...] [--n0 X0] [--n1 X1] [--points K] [--out FILE.csv]
                [--no-normalize] [--grid N] [--x0min A] [--x0max B] [--profile-out FILE.csv] [--rtol R] [--atol A] [--method bdf|adams]
      model      : scalar-flrw | scalar-cpl | spinor-flrw | scalar-pre | scalar-pre-x0
      defaults   : FLRW models --n0 -7 --n1 0 --points 701; pre-universe models --n0 0 --n1 50 (x4 range);
                   cosmological params om=0.3 or=8.4e-5 w0=-0.861 wa=-0.60; potential params as in §3/§4 (v0, lambda, alpha, f, m, mu, sstar, s1, n)
      output     : CSV, header line naming every column, one line per output point, 15 significant digits
      stderr     : "# initial conditions: …", "# stats: model=… steps=… rhs_evals=… nonlin_iters=… err_test_fails=…",
                   "# potential=…" (the potential after normalisation), the version line
      exit code  : 0 success; 1 solver or physics error (V ≤ 0, ρ ≤ 0, normalisation not bracketed) with a one-line reason; 2 usage
    fable_cosmo --version   prints "fable_cosmo 0.1.0, sundials_rs 7.8.0 (pure Rust), CVODE BDF"

Cross-checks: `scipy.integrate.solve_ivp` (DOP853, `rtol = 1e-11`) of every model in the notebooks
(Models A and B agree to `1e-10` and `2e-8` in `w` in the development runs); a Mathematica
`NDSolve` reference for one case of Model A and one of Model B exported by Part VI
(`fable-cosmology/reference/mathematica_*.csv`) as a third integrator.

## 6. The Mathematica side: Part VI of the notebook (`claude-fable/cells_part6.wl`)

Sections 23–25, in the style of Parts III–V (every claim a `cfAssert`, tags `[definition]`,
`[has content]`, `[THE RESULT]`, `[fidelity]`, `[control]`; non-vanishing via `cfNonZeroWitnessQ`
on concrete substitutions, since the probe rules know nothing about generic functions; identities
closed symbolically). **New helpers Part VI defines** (none exist yet): `cfEulerLagrange[L, fields, coords]`
(Euler–Lagrange operator for fields of any subset of the coordinates), `cfCovariantDivergence[T, gInv, Gamma, coords]`,
`cfLagrangianFable[psi, frame, sqrtg, Vfun]` (generic `V` as a pure function of `s`),
`cfDiracOperatorFor[psi, gammaUp, gammaSpin]`, `cfOnShell` (the recipe: solve the field equation for
the highest x4-derivative and substitute it, repeatedly, until no x4-derivative of the field is
left). Conventions restated at the top: `\[Sigma]16` is the symbol; `T16[a]` is 0-based; entry 5
of `X`, `gCanonical`, `gammaCurvedCanonical` is `x4`; `H`, `K`, `M` are Protected, so energies are
`cfKE, cfPE, cfG0, cfG5, cfKPsi, cfKh`; `sqrtDetgTele = Sec[6 H x0]` is the volume factor to use.
**Part VI never substitutes for `a4`**; its FLRW reference frame is the separate
`frameFLRW = DiagonalMatrix[{1, aF[x4], aF[x4], aF[x4], 1, 1, 1, 1}]`, and the last assertion of
Part VI is that `a4` is still undefined.

- **23. fableScalar** — definition; `T_{μν}`; symmetric; the off-shell divergence identity (for a
  generic `φ` of all eight coordinates); the trace; the decomposition `ρ, P_1, P_0` for a field of
  `x0, x4, x5`; `ρ + P_1 = 2 KE` [THE RESULT: the null energy condition]; the `ρ > 0` hypothesis
  stated and the `−G5` sector shown; `φ̈ = −V'` for `φ(x4)` [THE RESULT: no friction]; the static
  x0 profile with `w = −1` on the sheet and `P_0 = +ρ`; the virial average on the exact quadratic
  solution; the reduced 4-volume factorisation `Sqrt[g_8] = q³ Tan p³`; the 4-dimensional
  reference equations `NDSolve`d for `exp` → `reference/mathematica_scalar_exp.csv`.
- **24. fable** — definition with `s` and a generic `V`; the Euler–Lagrange equation by explicit
  variation and its equality with `Sqrt[g][(2/H)(A^μ∂_μΨ + ½DΨ) − 2V'\[Sigma]16Ψ]`; the divergence
  term equals `gamma^μ Gamma^spin_μ` and `−3H Cot² T16[0]` on this frame, with the anticommutator
  hypothesis asserted; the rescaling; **[fidelity]** `La` and `eLa`; the covariant `T_{μν}`:
  symmetric, **on-shell conservation for generic `Ψ(x0,x4)`** by `cfOnShell`, the diagonal
  agreement with the `∂`-tensor and a witnessed off-diagonal difference; `L̂ = sV' − V`,
  `ρ = V + K_h`, `P = sV' − V` on shell; `K_h = 0` and `ρ = V` for `Sqrt[Sin] Ψ'(x4)`; `ds/dx4 = 0`;
  dust for the mass term [THE RESULT]; `w_Ψ` closed forms for the potentials of §3 with the
  crossing points; the FLRW frame: `gamma^μ Gamma_μ = (3/2)(a'/a) gamma^4`, `d(a³ s)/dt = 0`;
  `NDSolve` reference `reference/mathematica_spinor_expdamp.csv`.
- **25. Reading the two mechanisms side by side** — the table of §7, the kinematic identification
  `ln a = −a4` with its sign hypothesis, the volume bookkeeping and its caveats, the honest
  statement of what is proved on the 8-manifold versus what is the reference model, and the
  assertion that `a4` is still undefined.

## 7. What the investigation is expected to find (confirmed or corrected by the numerics)

| question | fableScalar | fable |
|---|---|---|
| time-varying `w`? | yes: rolling in `V` under Hubble friction (Model A/A′); on the pre-universe, undamped oscillation (C) and sloshing between `x0`-gradient energy and `x4` motion (D) | yes: `w(a) = sV'/V − 1` on `s ∝ a^{−3}`: dust → constant `n − 1` (`power`), or phantom → −1 → quintessence-like (`lorentz`, `expdamp`) |
| phantom divide? | never with `ρ_φ > 0` (NEC: `ρ + P = 2KE ≥ 0`) | crossed at `V'(s*) = 0` by `lorentz`/`expdamp`, classical spinor-quintom mechanism; perturbative stability not examined |
| dark matter? | coherent oscillations (`⟨w⟩ = 0`, quadratic `V`, Model C; and Model A `quadratic` dilutes as dust once oscillating) | the author's mass term **is** dust, exactly; `s ∝ a^{−3}` is the dust dilution law |
| dark energy? | slow roll / flat `V` (`w → −1`); the static `x0` gradient (`w = −1` on the sheet) | `power` with `0 < n < 2/3` (field-driven; `n = 0.236` ↔ `−0.764`); `V0` terms are a bare Λ and are reported as such |
| Unite `(−0.861, −0.60)`? **[rev]** | a thawing fableScalar gives `w0 > −1` and `wa < 0` (the same sign pattern) with `w0 + wa` below −1 in the CPL *extrapolation*, while never having `w < −1`; whether `|wa| ≈ 0.6` is reachable is what Model A measures | `expdamp`/`lorentz` give a genuine phantom phase in the past, `w(1) ≈ −0.86`, `wa < 0`; the fits are reported |
| the volume bookkeeping | any constant 8-density has `ρ_4 ∝ a^{−3}` in the reduction — a volume effect, not dust; undetermined without a gravitational sector | same |

## 8. File layout of the deliverable

    fable-cosmology/
      DESIGN.md                      this file
      README.md                      what is here, how to run everything (complete, self-contained)
      requirements.txt               numpy scipy matplotlib jupyter nbconvert nbclient ipykernel
      setup.sh / setup.ps1           venv + pip + sparse clone of the platform rustSolveIt engine + cargo build + smoke test
      run_all.sh / run_all.ps1       cargo test; execute every notebook in place; nbcheck; latexmk
      rust/fable_cosmo/              the solver crate (Cargo.toml, .cargo/config.toml, src/{main,models,potentials,cvode_driver}.rs, unit tests)
      rust/vendor/                   git-ignored: the platform rustSolveIt clone (sundials_rs only)
      notebooks/
        01_fableScalar_quintessence.ipynb     Models A and A′, the potentials, thawing/freezing read off w′–w, CPL fits, cross-checks
        02_fable_spinor.ipynb                 Model B, the potentials, dust, the crossing, CPL fits, Ω_Λ separated, cross-checks
        03_pre-universe_dynamics.ipynb        Models C, D (E stated): no friction, the virial average, the sloshing mechanism, energy conservation
        04_dark_matter_dark_energy.ipynb      the comparison, the questions answered, the figures for the paper
        _build/nbgen.py, nbcheck.py, CONVENTIONS.md
      results/                       CSVs and PNGs written by the notebooks (committed: they are the evidence)
      reference/                     mathematica_*.csv from Part VI
      latex/fable_cosmology.tex, fable_cosmology.pdf, figures/   the paper, compiled with latexmk (MiKTeX / TeX Live)
    claude-fable/cells_part6.wl      Part VI of the notebook
    PROVENANCE-13-FABLE-COSMOLOGY.md the provenance page: every command, every result

Each notebook follows the rustSolveIt notebook rules, adapted (`notebooks/_build/CONVENTIONS.md`):
launch instructions in full; never sends the reader to another notebook; explanatory markdown before
every code cell; asks the user to name the notebook and offers a save dialog with a typed fallback;
describes the field, Lagrangian, energy–momentum tensor, equations of motion and the first-order
system handed to SUNDIALS; valid nbformat 4 with every non-interactive cell executed and its outputs
committed; owns its result files under `results/` and reads one back with plain Python.

## 9. Verification plan

1. Part VI: all assertions `PASS`, 0 messages, `$cfNumericCertificates == 0`.
2. `cargo test`: potentials' derivatives vs finite differences; the CPL closed form vs the integral
   and `f(1) = 1`; `ρ + P = 2KE`; `w_Ψ` formulas, crossings at `s1`/`s*`, positivity of `lorentz`/`expdamp`;
   **[rev]** `H(N=0) = 1` and `Ω_m(a=1) = Ω_m0` after normalisation; CVODE Adams and BDF agree on a decay.
3. Three-way agreement on the reference cases: CVODE (Rust) vs `solve_ivp` (Python) vs `NDSolve`
   (Mathematica), maximum relative difference reported in the notebooks and the paper.
4. Physics sanity: `const` gives `w = −1` to 1e-10; `mass` gives `w = 0` exactly; the crossing of
   `lorentz`/`expdamp` at `N_c = −⅓ ln(s1/s_0)` to `1e-8` by interpolation of `w + 1`, with `V > 0`
   on the whole run; Model C `ρ` drift and Model D `E_h` drift below `1e-8`; Model C `⟨w⟩ → 0`.
5. `nbcheck.py` passes on all four notebooks; `nbconvert --execute` re-runs them from a fresh clone
   with identical numbers (CSV compare).
6. `latexmk -pdf` builds the PDF from a fresh clone.
7. Fresh-clone run of everything, recorded on the provenance page.
