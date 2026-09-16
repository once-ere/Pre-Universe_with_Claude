# Provenance 12 — The fable-5.1 bridge, the Weitzenböck connection of the canonical frame, compared to the canonical spin connection

**Effort.** The author's instruction, 2026-09-16: *"create a novel, highly non-trivial and even
super-human [if possible] bridge solution named 'fable-5.1 bridge' and compare it to the
canonical spin connection. Document all of your work so that an ignorant student can read,
understand and employ your superior solution."*

This is Part V of `claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb` — Section 21 (the
bridge) and Section 22 (the master comparison of all five connections) — generated from the new
manifest `claude-fable/cells_part5.wl`.

Everything needed to repeat this work is on this page. No other file needs to be consulted.

---

## 0. Where things are

| what | where |
|---|---|
| the notebook | `<repo>/claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb` |
| Part V's manifest | `<repo>/claude-fable/cells_part5.wl` |
| the run log | `<repo>/claude-fable/run_fable51_fourth.log` |
| a script that *uses* the result | `<repo>/claude-fable/student_fable51.wls` (section 7) |

## 1. What "trivial" means, and what a non-trivial bridge has to do

Part IV's review established the criterion, which is stated here in full: a frame of the
form `frameCanonical . L(x)` with `L(x)` preserving the flat metric gives the *same* connection
in a different gauge, and a "comparison" with the canonical spin connection then merely
re-derives the gauge law. A bridge is a different **connection** only if it differs from the
canonical one by a **tensor**. Bridge 3 does that by adding a contortion by hand. The fable-5.1
bridge does it without adding anything: it keeps the metric, the frame, the flat metric and the
bridge `g = e . eta . eᵀ` all untouched, and changes the one thing the other bridges never
questioned — the rule for parallel transport.

## 2. The bridge

Declare the canonical frame itself to be parallel. The affine connection that does this is the
**Weitzenböck** (teleparallel) connection of the frame,

```
GammaWeitzenboeck[[rho, mu, nu]]  ==  Sum[ coframe[[a, rho]] D[frame[[nu, a]], x[mu]], {a, 8} ] ,
```

in the notebook:

```wolfram
ClearAll[GammaWeitzenboeck, cfFable51Frame, cfFable51Coframe];
cfFable51Frame   = frameCanonical;
cfFable51Coframe = coframeCanonical;
GammaWeitzenboeck = cfTimed["fable-5.1: Weitzenboeck affine connection Gamma^W = e_a^rho d_mu e_nu^a",
  cfSimpArray @ Table[Sum[cfFable51Coframe[[a, r]] D[cfFable51Frame[[p, a]], X[[m]]], {a, 8}],
    {r, 8}, {m, 8}, {p, 8}]];
```

Then Step 2 of the author's standard procedure — the vielbein postulate
`D[e[nu,a], x[mu]] - Gamma[rho,mu,nu] e[rho,a] + omegaMixed[mu,a,b] e[nu,b] == 0` — is solved
with **the same solver** that produced every other spin connection in the notebook, with
`Gamma = GammaWeitzenboeck`:

```wolfram
omegaFable51Mixed = cfSpinConnection[cfFable51Frame, X, eta4488, GammaWeitzenboeck];
omegaFable51      = cfLowerFirstFlat[omegaFable51Mixed, eta4488];
```

and Step 3, the spinor, follows from what comes out.

## 3. What was proved

Every line below is a `cfAssert` in Section 21 that prints `PASS`. Tags: `[definition]` true by
construction; `[has content]` could have failed; `[THE RESULT]` a headline.

**The connection.**
- `[definition]` the frame is parallel, `nabla^W e == 0` for all eight frame vectors;
- `[has content]` `Gamma^W` is metric compatible, `nabla^W g == 0`;
- `[has content]` `Gamma^W` is not symmetric in its lower indices (it has torsion), and is not
  the Levi-Civita connection — both witnessed at a probe point where the difference is a number;
- `[solver regression]` the vielbein-postulate residual is zero;
- **`[THE RESULT]` the fable-5.1 spin connection in the canonical frame is identically zero.**

**Torsion and curvature.**
- `[has content]` the torsion `T^a_{mu nu} = d_mu e_nu^a − d_nu e_mu^a` is not zero (witnessed);
  it equals the antisymmetric part of `Gamma^W`;
- **`[THE RESULT]` the curvature 2-form is identically zero** — a flat connection on a curved
  metric.

**The comparison with the canonical connection (`COMPARISON F`).**
- `[has content]` `Gamma^W − Gamma^LC == (1/2)(T_{rmn} + T_{mrn} + T_{nrm})` with the first
  index raised — the contortion formula;
- **`[THE RESULT]` `omegaCanonical == − contortion(fable-5.1 torsion)` pulled back to flat
  indices, exactly** — all 24 non-zero components of the canonical Levi-Civita spin connection of
  Section 16 are minus the contortion of the fable-5.1 torsion;
- so `omegaCanonical − omegaFable51` is a tensor, not a gauge term.

**The kind of torsion.**
- the torsion vector `T[mu] = T[nu,nu,mu]` is a gradient, `D[Log[Sin[6 H x0]], x[mu]]`, with the
  single non-zero component `6 H Cot[6 H x0]`;
- the axial (totally antisymmetric) part vanishes identically — the exact complement of Bridge 3;
- the torsion itself does not vanish (witnessed), so the tensor part carries the rest.

**The scalar identity.**
- `det g == Sec[6 H x0]^2`, positive, as signature 4+4 requires;
- **`[THE RESULT]` `R == −T + B`** with `T = (1/4) T^{rmn} T_{rmn} + (1/2) T^{rmn} T_{nmr} − T^m T_m`
  and `B = (2/Sqrt[det g]) D[Sqrt[det g] T^mu, x[mu]]`, in closed form — the teleparallel
  equivalent of general relativity for this geometry; `T` and `B` are both non-zero (witnessed).

**The 16-component spinor.**
- **`[THE RESULT]` `gamma^mu Gamma^spin[mu] == −(1/2) T[mu] gamma^mu`**, one vector term;
  equivalently `−(1/2) D[Log[Sin[6 H x0]], x_mu] gamma^mu`;
- **`[THE RESULT]` `DiracCanonical[Sqrt[Sin[6 H x0]] Psi'] == Sqrt[Sin[6 H x0]] DiracFable51[Psi']`**
  for a generic 16-component `Psi'`, where `DiracFable51` has the curved `gamma^mu` and no
  connection at all;
- the rescaling is not a no-op: the two operators differ on the constant spinor (witnessed).

**The Lagrangian.**
- **`[THE RESULT]` `Psi^T sigma16 gamma^mu Gamma^spin[mu] Psi == 0` for every `Psi`** — the spin
  connection drops out of the Dirac Lagrangian of this real spinor, because `sigma16 T16[a]` is
  antisymmetric (Section 11) and the connection term is a multiple of `gamma^mu`;
- the connection term does not drop out of the Dirac *operator* (witnessed);
- the covariant Lagrangian `cfLagrangianCovariant[psi, frame, sqrtg]` with `frame -> ID8` and
  `sqrtg -> 1` is the author's `La` of Section 11 term for term, and the helper applied to
  `Psi16` **is** `La[]`; with the real frame and volume factor it is not (witnessed at `M = 1`
  on the constant spinor `e1 + e5`); and its kinetic term is already the fable-5.1 one — there is
  no connection term to omit.

**Frame covariance, and Bridge 1 explained.**
- in Bridge 1's boosted frame the same `GammaWeitzenboeck`, fed to the same solver, gives
  `omega == −D[M, x_mu] . Inverse[M]`, `M = Transpose[Lambda]` — pure gauge and nothing else
  (`[THE RESULT]`); the lemma's prediction itself satisfies the vielbein postulate; the curvature
  is still identically zero;
- Bridge 1's inhomogeneous term of Section 18 **is** this object, `deltaBoost == omegaFable51Boost`,
  so `omegaBoost == (canonical, conjugated) + (fable-5.1 in the boosted frame)`.

## 4. Complete commands

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
python build_tools.py                                   # regenerates the .nb from cells_part1..5.wl
wolframscript -file run_from_nb.wls 2>&1 | tee run_fable51_fourth.log
grep -n "FABLE-5.1\|COMPARISON F\|Master comparison\|identities accepted\|non-vanishing witnesses\|assertions" run_fable51_fourth.log
```

To evaluate only Part V interactively, open the notebook in Mathematica, evaluate Parts I–IV
first (Part V uses `frameCanonical`, `GammaCanonical`, `omegaCanonicalMixed`, `RiemannCanonical`,
`RicciScalarCanonical`, `GammaSpinCanonical`, `gammaCurvedCanonical`, `cfDiracOperator`, `La[]`,
`Psi16`, and Bridge 1's `frameBoost`, `cfM`, `cfMinv`, `deltaBoost`, `omegaBoostMixed`), then
evaluate Sections 21 and 22.

## 5. The result

The lines the run prints for Part V, from `run_fable51_fourth.log` (the `CELL` lines are the
per-cell timings; Part V evaluates in about three seconds):

```
  PASS  FABLE-5.1 [definition]: the frame is parallel  --  nabla^W e == 0 for all eight frame vectors
  PASS  FABLE-5.1 [has content]: Gamma^W is metric compatible, nabla^W g == 0
  PASS  FABLE-5.1 [has content]: Gamma^W is NOT symmetric in its lower indices -- it has torsion
  PASS  FABLE-5.1 [has content]: Gamma^W is NOT the Levi-Civita connection
CELL 140  t=0.026 s
  PASS  FABLE-5.1 [solver regression]: vielbein postulate residual is zero
  PASS  FABLE-5.1 [THE RESULT]: the spin connection in the canonical frame is IDENTICALLY ZERO
  PASS  FABLE-5.1: trivially antisymmetric, so trivially metric compatible
CELL 141  t=0.334 s
  PASS  FABLE-5.1 [has content]: the torsion is NOT zero
  PASS  FABLE-5.1: T^rho_{mu nu} == Gamma^W[rho,mu,nu] - Gamma^W[rho,nu,mu]  (torsion is the antisymmetric part of Gamma^W)
  PASS  FABLE-5.1 [THE RESULT]: the curvature is IDENTICALLY ZERO -- a flat connection on a curved metric
CELL 142  t=0.201 s
  PASS  COMPARISON F [has content]: Gamma^W - Gamma^LC == (1/2)(T_{rmn} + T_{mrn} + T_{nrm}) with the index raised, the contortion formula
  PASS  COMPARISON F [THE RESULT]: omegaCanonical == - contortion(fable-5.1 torsion), pulled back to flat indices, exactly
  PASS  COMPARISON F: so omegaCanonical - omegaFable51 is a TENSOR, not a gauge term (omegaFable51 == 0)
CELL 143  t=0.412 s
  PASS  FABLE-5.1 torsion vector T[mu] = T[nu,nu,mu] is a GRADIENT: T[mu] == D[Log[Sin[6 H x0]], x[mu]]
  PASS  FABLE-5.1 torsion vector has exactly one non-zero component, 6 H Cot[6 H x0] along x0
  PASS  FABLE-5.1: the AXIAL (totally antisymmetric) part of the torsion vanishes -- the complement of Bridge 3
  PASS  FABLE-5.1: the torsion itself does not vanish, so the tensor part carries the rest
CELL 144  t=0.254 s
  PASS  FABLE-5.1: det g == Sec[6 H x0]^2  (positive, as signature 4+4 requires)
  PASS  COMPARISON F [THE RESULT]: R == -T + B  --  the teleparallel equivalent of GR, in closed form for this geometry
  PASS  FABLE-5.1: T is not zero and B is not zero -- neither side is trivial
CELL 145  t=1.144 s
  PASS  FABLE-5.1 [THE RESULT]: gamma^mu Gamma^spin[mu] == -(1/2) T[mu] gamma^mu, one vector term
  PASS  FABLE-5.1: equivalently -(1/2) D[Log[Sin[6 H x0]], x_mu] gamma^mu
  PASS  FABLE-5.1 [THE RESULT]: DiracCanonical[ Sqrt[Sin[6Hx0]] Psi' ] == Sqrt[Sin[6Hx0]] DiracFable51[Psi'], for a generic Psi'
  PASS  FABLE-5.1: the rescaling is NOT a no-op -- the two Dirac operators differ on the constant spinor
CELL 146  t=0.096 s
  PASS  FABLE-5.1 [THE RESULT]: Psi^T sigma16 gamma^mu Gamma^spin[mu] Psi == 0 for EVERY Psi -- the spin connection drops out of the Lagrangian
  PASS  FABLE-5.1: the reason is Section 11's identity, Psi^T sigma16 T16[a] Psi == 0 (sigma16 T16[a] antisymmetric)
  PASS  FABLE-5.1: but the connection term does NOT drop out of the Dirac OPERATOR (it is -(1/2) T[mu] gamma^mu, non-zero)
  PASS  FABLE-5.1: the author-form helper applied to Psi16 IS Section 11's La[] (the two are the same expression)
  PASS  FABLE-5.1: the covariant Lagrangian with frame -> ID8 and volume factor -> 1 IS the author's La of Section 11, term for term
  PASS  FABLE-5.1: with the real frame and volume factor it is NOT the author's La -- witnessed on the constant spinor e1 + e5 (at M = 1)
  PASS  FABLE-5.1: and the covariant Lagrangian has NO connection term to omit -- its kinetic term is already the fable-5.1 one
CELL 147  t=0.036 s
  PASS  FABLE-5.1 in the boosted frame: vielbein postulate residual is zero
  PASS  FABLE-5.1 in the boosted frame [THE RESULT]: omega == -D[M,x_mu] Inverse[M], pure gauge and nothing else
  PASS  FABLE-5.1 in the boosted frame: the lemma's prediction itself satisfies the vielbein postulate with Gamma^W
  PASS  FABLE-5.1 in the boosted frame: the curvature is STILL identically zero
  PASS  and Bridge 1's inhomogeneous term of Section 18 IS this object: deltaBoost == omegaFable51Boost
  PASS  so omegaBoost == (canonical, conjugated) + (fable-5.1 in the boosted frame)
CELL 148  t=0.410 s
CELL 149  t=0.000 s
CELL 150  t=0.001 s
CELL 151  t=0.000 s
identities accepted on numerical evidence alone : 0   (stage 3 returned True)
non-vanishing witnesses                         : 19   (cfNonZeroWitnessQ found a probe point at which every entry is a
                                                     number and one of them is non-zero: a complete proof of non-vanishing)
  PASS  no identity in this notebook was accepted on numerical evidence alone
Assertions run: 250   passed: 250   failed: 0
```

The closed forms, printed from the completed state (`lambda` is Bridge 3's `lambdaOct`; `a4'`
is the undetermined function's derivative, carried symbolically):

```
RicciScalarCanonical  = -3*H^2*((55 + 7*Cos[12*H*x0])*Cot[6*H*x0]^2*Csc[6*H*x0]^2 - 2*a4'[H*x4]^2)
torsionScalarFable51  = -6*H^2*(5*Cot[6*H*x0]^4 + a4'[H*x4]^2)
boundaryTermFable51   = -36*H^2*(5 + Cos[12*H*x0])*Cot[6*H*x0]^2*Csc[6*H*x0]^2
```

and `RicciScalarCanonical + torsionScalarFable51 - boundaryTermFable51` simplifies to `0`, which
is the assertion `R == -T + B`.

Non-zero component counts of the Part V objects, from the fingerprint table of Section 22:

| object | non-zero components |
|---|---|
| `GammaWeitzenboeck` (`Gamma^W`) | 13 |
| `omegaFable51` (canonical frame) | 0 |
| `contortionFable51` (`== Gamma^W − Gamma^LC`) | 24 — the same 24 as `omegaCanonical` |
| `torsionFable51` / `torsionFable51Flat` | 24 / 24 |
| `RiemannFable51` | 0 |
| `omegaFable51BoostMixed` (boosted frame) | 4 — the same 4 as `deltaBoost` |
| `cfDiracConnectionTerm` (`gamma^mu Gamma^spin[mu]`) | 16 |

The output of `student_fable51.wls` (section 7), from `student_fable51.log`:

```
notebook state loaded through Input cell 117
Dirac_LC[Sqrt[Sin] Psi'] - Sqrt[Sin] gamma^mu d_mu Psi'  ==  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
the two equations differ by: {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
given Psi' solving  gamma^mu d_mu Psi' + m Psi' == 0,  the Levi-Civita solution is  Psi = Sqrt[Sin[6*H*x0]] Psi'
given Psi solving the Levi-Civita equation, the connection-free solution is  Psi' = Psi / Sqrt[Sin[6*H*x0]]
```

## 6. Reading the comparison

**Why this is a different connection and not a gauge.** The difference `omegaCanonical −
omegaFable51` is `omegaCanonical` itself, and it is proved equal to minus the contortion of the
fable-5.1 torsion, a tensor built from `d e^a`. No frame rotation produces it: a rotation adds
`−dM M^-1`, whose curvature contribution cancels, whereas here the two curvatures are `156`
non-zero components against identically zero. Two connections with different curvature are not
the same connection in different gauges.

**Why the whole geometry sits in the torsion.** With the frame parallel, `Gamma^W` has no
freedom left: it is determined by the frame's own derivatives. Its torsion is the exterior
derivative of the frame, and the contortion formula reconstructs the Levi-Civita connection —
Christoffel symbols and spin connection alike — from that torsion. The 37 non-zero Christoffel
symbols and the 24 non-zero canonical spin-connection components are all functions of the torsion.

**Why `R == −T + B` is the deep statement.** The Einstein–Hilbert Lagrangian `R Sqrt[g]` and the
teleparallel Lagrangian `−T Sqrt[g]` differ by a total divergence, so they give the same field
equations: gravity can be written as a theory of torsion on a flat connection instead of a theory
of curvature on a torsion-free one. Here the identity is not quoted from a textbook; it is
computed for this metric, with `T` and `B` in closed form, and closed symbolically.

**Why the spinor result is exact and useful.** The torsion vector is a gradient. A vector-torsion
term in the Dirac operator that is a gradient is removed by rescaling the spinor by the
exponential of half the potential — here `Exp[(1/2) Log[Sin[6 H x0]]] = Sqrt[Sin[6 H x0]]`. That
is why the Levi-Civita Dirac equation and the connection-free one are the same equation, and why
a student may solve the simpler one and multiply. Had the torsion vector not been a gradient,
no rescaling would do it.

**What it says about the original notebook's Lagrangian.** The author's `La` is flat: no volume
factor, no coframe, no connection. Part V shows that the connection was never missing — it
contributes exactly zero to the Lagrangian of a real spinor with this `sigma16` — and that what
`La` omits is precisely `Sec[6 H x0]` and the coframe factors inside `gamma^mu`.

## 7. Employing it

`claude-fable/student_fable51.wls` loads the notebook's own definitions through Section 17 and
demonstrates the conversion between the two Dirac equations on a generic spinor with a generic
mass:

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
wolframscript -file student_fable51.wls
```

```wolfram
(* student_fable51.wls -- use the fable-5.1 result: solve the connection-free Dirac equation,   *)
(* multiply by Sqrt[Sin[6 H x0]], and you have solved the Levi-Civita one.                     *)
(* Run from anywhere:  wolframscript -file student_fable51.wls                                 *)
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

Its output is in section 5.

## 8. What this proves

- A bridge exists that keeps the metric, the frame, the flat metric and `g = e . eta . eᵀ`
  exactly as in Part III and is nevertheless a **different connection**, with a comparison to
  the canonical spin connection that is a tensor identity rather than a gauge law.
- In the canonical frame its spin connection is zero and its curvature is zero; its torsion is
  `d e^a`; and the canonical Levi-Civita spin connection is **minus the contortion of that
  torsion**, component for component.
- The Levi-Civita scalar curvature of the pre-universe equals minus the fable-5.1 torsion scalar
  plus a boundary term, `R == −T + B`, in closed form.
- The torsion vector is a gradient, so the curved Dirac equation of the model is **exactly**
  the connection-free one after the rescaling `Psi = Sqrt[Sin[6 H x0]] Psi'`; and the spin
  connection contributes **nothing** to the Dirac Lagrangian of this real spinor.
- Bridge 1's inhomogeneous term is this connection in the boosted frame; Part IV and Part V are
  one picture.
