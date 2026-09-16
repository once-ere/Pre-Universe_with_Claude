# Student guide — the fable-5.1 bridge, and how to use it

This page is written for a reader who has never met a frame field, a spin connection or a
Weitzenböck connection, and who wants to (1) understand what the fable-5.1 bridge is, (2) see
exactly what was proved about it, and (3) use it — for example to solve the curved Dirac
equation of this model. Everything needed is on this page: every command is complete and
relocatable, and nothing here depends on any other page.

The work lives in Part V (Sections 21–22) of the notebook
`claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb`, which is generated from the manifest
`claude-fable/cells_part5.wl`. The notebook checks itself as it runs; every statement below that
is labelled *proved* is a `cfAssert[...]` in that notebook that prints `PASS` when it is evaluated.

---

## 0. Getting the notebook and running it

You need Wolfram Mathematica (the work was done on 15.0.1 with `wolframscript` 1.14), Python 3
(only to regenerate the notebook from its manifests) and git.

```bash
git clone https://github.com/once-ere/Pre-Universe_with_Claude.git
cd Pre-Universe_with_Claude/claude-fable
wolframscript -file run_from_nb.wls 2>&1 | tee run_from_nb.log
```

That imports the delivered `.nb`, evaluates every `Input` cell in order in one kernel, prints one
line per cell, every assertion with `PASS` or `FAIL`, and a final tally. It takes two to four
minutes on an ordinary machine (145 s on the one it was developed on); Part V is the last ten
seconds of that. To see only the Part V lines afterwards:

```bash
grep -n "FABLE-5.1\|COMPARISON F\|BRIDGE 3: \|identities accepted\|non-vanishing witnesses\|assertions" run_from_nb.log
```

To open it interactively instead, open `claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb` in
Mathematica and choose *Evaluation ▸ Evaluate Notebook*. If you edit a manifest, regenerate the
notebook before running it — the notebook is never edited by hand:

```bash
cd claude-fable
python build_tools.py
```

---

## 1. The objects, in plain words

The model of Parts I–II is a real 16-component spinor field `Psi16` on an 8-dimensional
spacetime with four space-like and four time-like directions, coordinates `x0 … x7`. Part III
adds the geometry. There are five objects, and the notebook keeps their index conventions fixed
throughout:

| object | symbol in the notebook | what it is |
|---|---|---|
| curved metric | `gCanonical[[mu, nu]]` | the metric `g_{μν}` of the spacetime; `detgCanonical == Sec[6 H x0]^2` |
| flat metric | `eta4488` | `diag(+1,+1,+1,+1,−1,−1,−1,−1)`, the Minkowski metric of the tangent space at each point |
| frame field (vielbein) | `frameCanonical[[mu, a]]` | `e_μ^a`: row = curved index `μ`, column = flat index `a`; it is diagonal, `diag(Tan[6 H x0], q, q, q, 1, p, p, p)` with `q = Exp[−a4[H x4]] / Sin[6 H x0]^(1/6)`, `p = Exp[+a4[H x4]] / Sin[6 H x0]^(1/6)` |
| coframe | `coframeCanonical == Inverse[frameCanonical]` | `e_a^μ`, the inverse |
| the bridge | `g == e . eta . Transpose[e]` | proved in Section 15 |

`a4` is an undetermined function of the original notebook and is **never** given a value; every
identity below holds for any differentiable `a4`.

A *connection* is a rule saying which vectors at neighbouring points count as "the same". Given a
connection you can differentiate vector fields covariantly, and two things measure how the rule
behaves:

- **torsion** — whether the rule closes infinitesimal parallelograms (`T = 0`) or not;
- **curvature** — whether carrying a vector round a small closed loop brings it back unchanged
  (`R = 0`) or rotated.

For a frame field there are two equivalent ways to write the same connection: on curved indices,
`Gamma[rho, mu, nu]` (an *affine* connection), and on flat indices, `omega[mu, a, b]` (a *spin*
connection). They are tied together by the **vielbein postulate** — the statement that the
frame is covariantly constant when *both* its indices are differentiated:

```
D[e[nu,a], x[mu]] - Gamma[rho,mu,nu] e[rho,a] + omegaMixed[mu,a,b] e[nu,b] == 0 .
```

Given `Gamma`, this is a linear equation for `omega`, and the notebook's function

```
cfSpinConnection[frame, coords, etaFlat, Gamma]
```

solves it. Every spin connection in the notebook — canonical, Bridges 1–3, fable-5.1 — comes out
of this one solver, so all of them are comparable on the same footing. The spinor then couples
to `omega` through the 16×16 matrices

```
Gamma^spin[mu] == (1/8) omega[mu,a,b] (gamma^a gamma^b - gamma^b gamma^a),    gamma^a = T16[a] ,
```

and the covariant derivative of the spinor is `D[psi, x[mu]] + Gamma^spin[mu] . psi`. Section 17
proves that this is the right matrix — that `[Gamma^spin_mu, gamma^a] + omega_mu^a_b gamma^b == 0`,
which fixes both the `1/8` and its sign, and shows on the spot that the opposite sign fails.

## 2. The canonical bridge in five lines

The **Levi-Civita** connection is the unique connection with zero torsion that preserves the
metric. Its affine form is the Christoffel symbol `GammaCanonical`, its spin form is
`omegaCanonical` (24 non-zero components), its curvature `RiemannCanonical` has 156 non-zero
components, and its Ricci scalar is

```
RicciScalarCanonical  ==  6 H^2 a4'[H x4]^2 - (3/4) H^2 (117 + 124 Cos[12 H x0] + 7 Cos[24 H x0]) Csc[6 H x0]^4
```

(the notebook prints it in a slightly different but equivalent arrangement). This is the
reference everything else is compared against.

## 3. What Part IV's three bridges are, honestly

Any frame of the form `frameNew = frameCanonical . L` with `L` preserving the flat metric
describes the *same* geometry seen through a rotated local Minkowski system, and its Levi-Civita
spin connection is the canonical one transformed by the gauge law

```
omegaNew_mu == M omegaCanonical_mu Inverse[M] - D[M, x_mu] Inverse[M],     M = Transpose[L] .
```

- **Bridge 1** (`L = Lambda(x)`, a local boost) and **Bridge 2** (`L = U`, constant) are
  exactly of that kind: the same connection in a different gauge. The notebook says so now, in
  its Part IV introduction and at the head of Sections 18 and 19. Bridge 1 is kept because the
  gauge law is worth seeing in closed form — including, new in this revision, at the spinor
  level with the explicit spin lift `S = MatrixExp[theta SAB[[1,5]]]` — and because Part V shows
  what its "inhomogeneous term" really is.
- **Bridge 3** is a genuinely different connection: Levi-Civita plus a contortion built from
  the split-octonion structure constants, with totally antisymmetric torsion `-2 lambda mSkew`.
  New in this revision, its curvature is computed: a polynomial of degree two in `lambda`, whose
  Ricci scalar is the canonical one shifted by the constant `-42 lambda^2`.

## 4. The fable-5.1 bridge

### 4.1 The definition

Keep everything — the metric, the frame, the flat metric, the bridge `g = e . eta . eᵀ` — and
change only the transport rule. Declare **the eight frame vectors themselves to be parallel**.
The affine connection that does this is

```
GammaWeitzenboeck[[rho, mu, nu]]  ==  Sum[ coframe[[a, rho]] D[frame[[nu, a]], x[mu]], {a, 8} ]
```

— the **Weitzenböck** (teleparallel) connection of the canonical frame. In the notebook:

```wolfram
GammaWeitzenboeck = cfSimpArray @ Table[
  Sum[cfFable51Coframe[[a, r]] D[cfFable51Frame[[p, a]], X[[m]]], {a, 8}], {r, 8}, {m, 8}, {p, 8}];
```

*Proved:* `nabla^W e == 0` for all eight frame vectors (the definition); `nabla^W g == 0` (it is
metric compatible — lengths are preserved); it is **not** symmetric in its lower indices and is
**not** the Levi-Civita connection (both witnessed numerically, i.e. a probe point at which the
difference is an actual non-zero number is exhibited).

### 4.2 The spin connection is zero, the curvature is zero, the torsion carries the geometry

Feed `GammaWeitzenboeck` to the *same* solver that produced every other connection:

```wolfram
omegaFable51Mixed = cfSpinConnection[cfFable51Frame, X, eta4488, GammaWeitzenboeck];
```

*Proved:* the result is **identically zero** — in the frame that defines the bridge, the
fable-5.1 spin connection vanishes. Consequently the torsion 2-form is the exterior derivative
of the frame, `T^a_{μν} = ∂_μ e_ν^a − ∂_ν e_μ^a` (non-zero, witnessed), it equals the
antisymmetric part of `Gamma^W` (proved), and the curvature 2-form is **identically zero**
(proved): a flat connection on a curved metric.

### 4.3 The comparison with the canonical connection is a tensor identity

Two connections on the same manifold differ by a tensor. Here it is the **contortion**
`K = Gamma^W − Gamma^LC`, and the standard formula gives it from the torsion alone:

```
K[rho,mu,nu] == (1/2) ( T[rho,mu,nu] + T[mu,rho,nu] + T[nu,rho,mu] ),    all indices down.
```

*Proved* (`COMPARISON F`): that formula holds; and, substituting `Gamma^LC = Gamma^W − K` into
the vielbein postulate,

```
omegaCanonical[mu,a,b]  ==  - K[rho,mu,nu] e[rho,a] coframe[[b,nu]]      exactly.
```

**The whole canonical Levi-Civita spin connection of Section 16 is minus the contortion of the
fable-5.1 torsion.** All 24 of its non-zero components are accounted for. This is the sense in
which the fable-5.1 bridge is a *different* connection with a *contentful* comparison: the
difference is a tensor, not a gauge term.

### 4.4 What kind of torsion it is

A torsion tensor splits into a vector part (its trace), an axial part (totally antisymmetric)
and a tensor part. *Proved:*

- the vector part `T[mu] = T[nu,nu,mu]` is a **gradient**, `T[mu] == D[Log[Sin[6 H x0]], x[mu]]`,
  with the single non-zero component `6 H Cot[6 H x0]` along `x0`;
- the axial part **vanishes identically** — the exact complement of Bridge 3, whose torsion is
  purely axial and inserted by hand;
- the tensor part carries the rest, including everything that depends on `a4`.

### 4.5 The scalar identity R == −T + B

Define the torsion scalar and the boundary term

```
T  =  (1/4) T^{rmn} T_{rmn} + (1/2) T^{rmn} T_{nmr} - T^m T_m ,
B  =  (2 / Sqrt[det g]) D[ Sqrt[det g] T^mu, x[mu] ],        Sqrt[det g] == Sec[6 H x0] .
```

*Proved:* `RicciScalarCanonical == -T + B`, in closed form, with `T` and `B` both non-zero. This
is the *teleparallel equivalent of general relativity* for the 4+4 pre-universe: the
Einstein–Hilbert action and the teleparallel action are the same action up to a boundary term.
Two details a student should not skip: `det g` is positive because signature 4+4 has an even
number of minus signs; and the square root is `Sec[6 H x0]`, not `Abs[Sec[6 H x0]]`, because
Section 15 assumed `0 < 6 H x0 < π/2` — writing the `Abs` would make Mathematica differentiate
`Abs` and the identity would look false for a purely notational reason.

### 4.6 The spinor: the connection term is one vector term, and a rescaling removes it

In the fable-5.1 gauge the spin connection is zero, so the covariant derivative of the spinor is
the plain partial derivative and the Dirac operator is `gamma^mu D[Psi, x_mu]` with the curved
`gamma^mu = coframe[[a,mu]] T16[a]`. The canonical Dirac operator carries in addition the term
`gamma^mu Gamma^spin[mu]`. *Proved:*

```
gamma^mu Gamma^spin[mu]  ==  -(1/2) T[mu] gamma^mu  ==  -(1/2) D[Log[Sin[6 H x0]], x_mu] gamma^mu ,
```

one vector term, and therefore, for a *generic* 16-component spinor `Psi'`,

```
DiracCanonical[ Sqrt[Sin[6 H x0]] Psi' ]  ==  Sqrt[Sin[6 H x0]] * gamma^mu D[Psi', x_mu] .
```

**The Levi-Civita Dirac equation for `Psi` and the connection-free fable-5.1 Dirac equation for
`Psi' = Psi / Sqrt[Sin[6 H x0]]` are the same equation.** Nothing about this is approximate.
The notebook also witnesses that the rescaling is not a no-op (the two operators differ on an
unrescaled spinor).

### 4.7 The Lagrangian: the spin connection drops out entirely

Section 11 proved that `sigma16 . T16[a]` is antisymmetric, so `Transpose[Psi] . sigma16 . T16[a] . Psi == 0`
for every real `Psi`. Since the connection term of the Dirac operator is a multiple of
`gamma^mu`, *proved:*

```
Transpose[Psi] . sigma16 . gamma^mu Gamma^spin[mu] . Psi  ==  0     for EVERY Psi .
```

The curved Dirac Lagrangian of this real spinor is therefore, exactly,

```
L  ==  Sqrt[det g] ( Transpose[Psi] . sigma16 . gamma^mu . D[Psi, x_mu] )  +  mass term ,
```

with no connection at all — it is manifestly the teleparallel Lagrangian. *Proved* also: with
`frame -> ID8` and `Sqrt[det g] -> 1` this is term-for-term the author's flat Lagrangian `La` of
Section 11 (and the helper applied to `Psi16` **is** `La[]`), while with the real frame it is
not: the author's `La` leaves out precisely the volume factor `Sec[6 H x0]` and the coframe
factors inside `gamma^mu`, and nothing else.

### 4.8 The bridge is frame-covariant, and it explains Bridge 1

Rotate the canonical frame by Bridge 1's local boost `Lambda(x)` and feed the *same*
`GammaWeitzenboeck` to the *same* solver. *Proved:* the fable-5.1 spin connection of the boosted
frame is `-D[M, x_mu] . Inverse[M]` with `M = Transpose[Lambda]` — pure gauge and nothing else —
its curvature is still identically zero, and it **is** Bridge 1's "inhomogeneous gauge term".
So Part IV's first bridge was the canonical connection plus the fable-5.1 connection of the
boosted frame; everything in Part IV sits in one picture.

## 5. How to use it

### 5.1 Solving the curved Dirac equation of this model

Section 4.6 says: if `Psi'` solves the connection-free equation

```
gamma^mu D[Psi', x_mu] + m Psi' == 0          (curved gamma^mu, NO connection)
```

then `Psi = Sqrt[Sin[6 H x0]] Psi'` solves the full Levi-Civita equation

```
gamma^mu ( D[Psi, x_mu] + Gamma^spin[mu] . Psi ) + m Psi == 0 ,
```

and conversely. The script below loads the notebook's own definitions (it evaluates the
notebook's cells up to and including Section 17, about two minutes), verifies the equivalence on
a generic spinor with a generic mass term, and shows the conversion. Save it as
`claude-fable/student_fable51.wls` — it is also committed there — and run it from anywhere:

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
wolframscript -file student_fable51.wls
```

```wolfram
(* student_fable51.wls -- use the fable-5.1 result: solve the connection-free Dirac equation,   *)
(* multiply by Sqrt[Sin[6 H x0]], and you have solved the Levi-Civita one.                     *)
cfHere = DirectoryName[ExpandFileName[$InputFileName]];
Get[FileNameJoin[{cfHere, "runner_header.wl"}]];
nb = Import[FileNameJoin[{cfHere, "claude-fable_Einstein-Rosen-2-Planes.nb"}], "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
(* evaluate the notebook's cells until Section 17's Dirac operator exists *)
i = 0;
Block[{$Output = {}},
  While[! (ValueQ[GammaSpinCanonical] && DownValues[cfDiracOperator] =!= {}) && i < Length[inputs],
    i++; cfRunCell[i, asOne[ToExpression[inputs[[i]], InputForm, Hold]]]]];
Print["notebook state loaded through Input cell ", i];

(* the connection-free (fable-5.1) Dirac operator: curved gammas, no connection *)
cfDiracFable51[psi_List] := Sum[gammaCurvedCanonical[[mu]] . D[psi, X[[mu]]], {mu, 8}];
(* a generic real 16-component spinor and a generic mass *)
psiP = Table[psiPrime[k] @@ X, {k, 0, 15}];
weight = Sqrt[Sin[6 H x0]];

(* THE IDENTITY, on a generic spinor: DiracCanonical[weight psi'] == weight DiracFable51[psi'] *)
identity = Simplify[cfDiracOperator[weight psiP] - weight cfDiracFable51[psiP], cfGeomAssume];
Print["Dirac_LC[Sqrt[Sin] Psi'] - Sqrt[Sin] gamma^mu d_mu Psi'  ==  ", identity];

(* so the two Dirac EQUATIONS are equivalent, mass term included: *)
eqLC     = cfDiracOperator[weight psiP] + m weight psiP;        (* Levi-Civita, on Psi = weight Psi' *)
eqFable  = weight (cfDiracFable51[psiP] + m psiP);              (* connection-free, on Psi'          *)
Print["the two equations differ by: ", Simplify[eqLC - eqFable, cfGeomAssume]];

(* how to convert a solution: *)
Print["given Psi' solving  gamma^mu d_mu Psi' + m Psi' == 0,  the Levi-Civita solution is  Psi = ",
  weight, " Psi'"];
Print["given Psi solving the Levi-Civita equation, the connection-free solution is  Psi' = Psi / ", weight];
```

What it prints is a `0` (the identity, closed symbolically by `Simplify` under the notebook's
geometric assumptions), a list of sixteen `0`s (the two equations differ by nothing), and the
two conversion rules.

### 5.2 Writing the curved Lagrangian of the model

Take the author's flat Lagrangian of Section 11 and make two replacements, and only two:

1. multiply by the volume factor `Sqrt[det g] == Sec[6 H x0]`;
2. replace the flat `T16[a] . D[Psi, x_a]` by `Sum[coframe[[a,mu]] T16[a], {a,8}] . D[Psi, x_mu]`.

There is no spin-connection term to add — Section 4.7 proves it would contribute zero. The
notebook's `cfLagrangianCovariant[psi, frame, sqrtg]` is exactly this, with the author's `1/H`
normalisation kept, and `cfLagrangianCovariant[psi, ID8, 1]` reproduces the author's `La`.

### 5.3 Computing the fable-5.1 connection of a frame of your own

For any invertible frame `frameNew` (a `8×8` matrix of functions of `X`) over the same metric:

```wolfram
GammaW = Table[Sum[Inverse[frameNew][[a, r]] D[frameNew[[p, a]], X[[m]]], {a, 8}], {r, 8}, {m, 8}, {p, 8}];
omegaW = cfSpinConnection[frameNew, X, eta4488, GammaW];       (* zero iff frameNew is parallel *)
```

If `frameNew = frameCanonical . L(x)`, Section 4.8 tells you the answer before you compute it:
`omegaW_mu == -D[Transpose[L], x_mu] . Inverse[Transpose[L]]`, pure gauge, with zero curvature.

## 6. Reading the assertion labels

Every `cfAssert` in the notebook prints `PASS <label>` or `FAIL <label>`. The labels carry tags:

| tag | meaning |
|---|---|
| `[definition]` | true by construction; kept so a reader can see the definition holds, not as evidence |
| `[solver regression]` | an identity the solver guarantees; guards against a broken helper, not a claim about geometry |
| `[has content]` | could have failed; a genuine fact about this geometry |
| `[THE RESULT]` | one of the headline results of the bridge |
| `[control]` | a deliberately wrong variant, shown to fail, so you can see the test discriminates |

Two counters are printed at the end. `identities accepted on numerical evidence alone` must be
`0` — every identity in the notebook is closed symbolically, and the final assertion of Section 22
fails if it is not. `non-vanishing witnesses` counts the "this is NOT zero" claims; each one is
certified by `cfNonZeroWitnessQ`, which succeeds only if at some probe point *every* entry
evaluates to an actual number and one of them is non-zero. A probe that does not reduce to
numbers is a *failed* witness, not a passed one.

## 7. Pitfalls met on the way, so you do not meet them again

- **A line beginning with `+` at top level is a new expression.** In a cell or a `.wls` file,
  `f[x_] := a` followed by a line `+ b` defines `f` as `a` and then evaluates `+ b` on its own.
  The first version of Part V lost the mass term of a Lagrangian helper this way, and an assertion
  comparing it with the covariant Lagrangian failed by exactly `(2 M/H) Psi^T sigma16 Psi`. The
  cure is a pair of parentheses around the whole right-hand side, which the author's own `La[]`
  has for the same reason.
- **`Sqrt[Det[g]]` is not `Abs[Sec[6 H x0]]` here.** Use the assumption `0 < 6 H x0 < π/2` and
  write `Sec[6 H x0]`; otherwise `D` differentiates `Abs` and `R == -T + B` looks false.
- **`a4` has no value and must not be given one.** Every result is an identity in `a4`.
- **A non-vanishing claim needs a number.** `! TrueQ[cfZeroArrayQ[expr]]` passes vacuously
  when `expr` merely fails to simplify; use `cfNonZeroWitnessQ[expr]`.
- **The all-ones spinor cannot witness a mass term**: `Transpose[psi] . sigma16 . psi == 0` for
  it, because `sigma16` has zero diagonal. `e1 + e5` gives `-2`.

## 8. What the run prints for Part V

From `claude-fable/run_fable51_fourth.log`, the record of the final evaluation (152 cells,
145 s, 250 of 250 assertions passing, no cell raising a message). Read each line against the
sections above; the tags are explained in section 6.

```
  PASS  FABLE-5.1 [definition]: the frame is parallel  --  nabla^W e == 0 for all eight frame vectors
  PASS  FABLE-5.1 [has content]: Gamma^W is metric compatible, nabla^W g == 0
  PASS  FABLE-5.1 [has content]: Gamma^W is NOT symmetric in its lower indices -- it has torsion
  PASS  FABLE-5.1 [has content]: Gamma^W is NOT the Levi-Civita connection
  PASS  FABLE-5.1 [solver regression]: vielbein postulate residual is zero
  PASS  FABLE-5.1 [THE RESULT]: the spin connection in the canonical frame is IDENTICALLY ZERO
  PASS  FABLE-5.1: trivially antisymmetric, so trivially metric compatible
  PASS  FABLE-5.1 [has content]: the torsion is NOT zero
  PASS  FABLE-5.1: T^rho_{mu nu} == Gamma^W[rho,mu,nu] - Gamma^W[rho,nu,mu]  (torsion is the antisymmetric part of Gamma^W)
  PASS  FABLE-5.1 [THE RESULT]: the curvature is IDENTICALLY ZERO -- a flat connection on a curved metric
  PASS  COMPARISON F [has content]: Gamma^W - Gamma^LC == (1/2)(T_{rmn} + T_{mrn} + T_{nrm}) with the index raised, the contortion formula
  PASS  COMPARISON F [THE RESULT]: omegaCanonical == - contortion(fable-5.1 torsion), pulled back to flat indices, exactly
  PASS  COMPARISON F: so omegaCanonical - omegaFable51 is a TENSOR, not a gauge term (omegaFable51 == 0)
  PASS  FABLE-5.1 torsion vector T[mu] = T[nu,nu,mu] is a GRADIENT: T[mu] == D[Log[Sin[6 H x0]], x[mu]]
  PASS  FABLE-5.1 torsion vector has exactly one non-zero component, 6 H Cot[6 H x0] along x0
  PASS  FABLE-5.1: the AXIAL (totally antisymmetric) part of the torsion vanishes -- the complement of Bridge 3
  PASS  FABLE-5.1: the torsion itself does not vanish, so the tensor part carries the rest
  PASS  FABLE-5.1: det g == Sec[6 H x0]^2  (positive, as signature 4+4 requires)
  PASS  COMPARISON F [THE RESULT]: R == -T + B  --  the teleparallel equivalent of GR, in closed form for this geometry
  PASS  FABLE-5.1: T is not zero and B is not zero -- neither side is trivial
  PASS  FABLE-5.1 [THE RESULT]: gamma^mu Gamma^spin[mu] == -(1/2) T[mu] gamma^mu, one vector term
  PASS  FABLE-5.1: equivalently -(1/2) D[Log[Sin[6 H x0]], x_mu] gamma^mu
  PASS  FABLE-5.1 [THE RESULT]: DiracCanonical[ Sqrt[Sin[6Hx0]] Psi' ] == Sqrt[Sin[6Hx0]] DiracFable51[Psi'], for a generic Psi'
  PASS  FABLE-5.1: the rescaling is NOT a no-op -- the two Dirac operators differ on the constant spinor
  PASS  FABLE-5.1 [THE RESULT]: Psi^T sigma16 gamma^mu Gamma^spin[mu] Psi == 0 for EVERY Psi -- the spin connection drops out of the Lagrangian
  PASS  FABLE-5.1: the reason is Section 11's identity, Psi^T sigma16 T16[a] Psi == 0 (sigma16 T16[a] antisymmetric)
  PASS  FABLE-5.1: but the connection term does NOT drop out of the Dirac OPERATOR (it is -(1/2) T[mu] gamma^mu, non-zero)
  PASS  FABLE-5.1: the author-form helper applied to Psi16 IS Section 11's La[] (the two are the same expression)
  PASS  FABLE-5.1: the covariant Lagrangian with frame -> ID8 and volume factor -> 1 IS the author's La of Section 11, term for term
  PASS  FABLE-5.1: with the real frame and volume factor it is NOT the author's La -- witnessed on the constant spinor e1 + e5 (at M = 1)
  PASS  FABLE-5.1: and the covariant Lagrangian has NO connection term to omit -- its kinetic term is already the fable-5.1 one
  PASS  FABLE-5.1 in the boosted frame: vielbein postulate residual is zero
  PASS  FABLE-5.1 in the boosted frame [THE RESULT]: omega == -D[M,x_mu] Inverse[M], pure gauge and nothing else
  PASS  FABLE-5.1 in the boosted frame: the lemma's prediction itself satisfies the vielbein postulate with Gamma^W
  PASS  FABLE-5.1 in the boosted frame: the curvature is STILL identically zero
  PASS  and Bridge 1's inhomogeneous term of Section 18 IS this object: deltaBoost == omegaFable51Boost
  PASS  so omegaBoost == (canonical, conjugated) + (fable-5.1 in the boosted frame)
identities accepted on numerical evidence alone : 0   (stage 3 returned True)
non-vanishing witnesses                         : 19
  PASS  no identity in this notebook was accepted on numerical evidence alone
Assertions run: 250   passed: 250   failed: 0
```

The closed forms, for the reader who wants to see them:

```
R  (Levi-Civita)   = -3*H^2*((55 + 7*Cos[12*H*x0])*Cot[6*H*x0]^2*Csc[6*H*x0]^2 - 2*a4'[H*x4]^2)
T  (torsion scalar)= -6*H^2*(5*Cot[6*H*x0]^4 + a4'[H*x4]^2)
B  (boundary term) = -36*H^2*(5 + Cos[12*H*x0])*Cot[6*H*x0]^2*Csc[6*H*x0]^2
R + T - B          =  0
```

And what `student_fable51.wls` prints (section 5.1):

```
notebook state loaded through Input cell 117
Dirac_LC[Sqrt[Sin] Psi'] - Sqrt[Sin] gamma^mu d_mu Psi'  ==  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
the two equations differ by: {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
given Psi' solving  gamma^mu d_mu Psi' + m Psi' == 0,  the Levi-Civita solution is  Psi = Sqrt[Sin[6*H*x0]] Psi'
given Psi solving the Levi-Civita equation, the connection-free solution is  Psi' = Psi / Sqrt[Sin[6*H*x0]]
```
