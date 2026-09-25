# Provenance 14 — Fermion fable: the complex 16-spinor, its canonical quantization in 4+4 dimensions, its field equations in the primordial gravitational field, and its energy–momentum tensor operator

**Effort A of 2026-09-24.** The classical 16-component spinor field *fable* of 2026-09-16 is
refined into a fermion: a complex 16-component Grassmann spinor. It is quantized canonically with
the observer's time `x4` as time, in the 4+4-dimensional pre-universe. Its field equations are
written out component by component in the primordial gravitational field (the author's canonical
frame, with the free function `a4` never given a value). Its energy–momentum tensor operator,
energy density, pressures and equations of state are derived, and the canonical spin connection
is discussed completely.

This page is complete on its own. Everything a reader needs is restated here. Code, logs, the
notebook, and the TeX and PDF files are named only as the places where things are computed,
recorded or produced.

**How to read the evidence.** Every mathematical statement on this page carries one of these
marks:

| mark | meaning |
|---|---|
| **[A]**, **[proved P §n]** | an assertion `cfAssert[label, test]` of the Mathematica notebook, Part P, Section n. The run log prints `PASS  label`; the label is quoted **verbatim**, in backticks, exactly as the log prints it |
| **[D]**, **[displayed P §n]** | a displayed output of the notebook (a table, a count, a closed form), not an assertion |
| **[P]**, **[prose P §n]** | stated only in a `Text` cell (or a code comment) of the notebook; not checked by an assertion |
| **[derived here]** | a short derivation carried out on this page from marked results, every step shown |
| **[file]** | read from a named file of the repository (code, CSV, log), which is named |

Numbers are quoted from the files and logs named next to them. Nothing is invented. `a4` is never
given a value anywhere.

**Two kinds of "section".** "Section n" with a capital S is a section of the Mathematica notebook
(Sections 1–33; Part VII is Sections 26–29). "section n" in lower case is a section of this page.
Formulas are written in plain text, close to the notebook's Wolfram notation: `T16[a]` are the 16×16
Dirac matrices, `sigma16` the spinor metric, `Psi^ddag` the classical conjugate, `Psibar` the Dirac
conjugate, `d_mu` a partial derivative, `D_mu` the spin-covariant derivative, `Sqrt[g]` the volume
factor `Sqrt[|det g|]`.

## Where things live

| what | where (relative to the repository root) |
|---|---|
| the Mathematica notebook (generated, never edited by hand) | `claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb` |
| its cell manifests; Part VII (Sections 26–29) is this effort | `claude-fable/cells_part1.wl` … `cells_part8.wl`; **`claude-fable/cells_part7.wl`** |
| the builder and the run harness | `claude-fable/build_tools.py`, `claude-fable/runner_header.wl` |
| the runner, the checker, the section map | `claude-fable/run_from_nb.wls`, `claude-fable/verify_nb.wls`, `claude-fable/nb_section_map.wls` |
| Part VII's own acceptance run, the record of Part VII: the notebook through Part VII (198 Input cells, 528/528, 0 cells with messages) | `claude-fable/run_fermion_fable_part7.log` |
| the acceptance run of Part VIII, kept as a historical record (217 Input cells, 642/642: the Rust solver's CSVs did not exist yet, so Part VIII's two Rust-vs-Mathematica comparisons were skipped, and three Section 32 labels still carry the superseded index notation; section 10.3) | `claude-fable/run_fermion_fable_part8.log` |
| the final run of the whole notebook, Parts I–VIII, in its committed state (217 Input cells, 644/644, 0 cells with messages, 198.352 s, 46 witnesses, 0 identities accepted on numerical evidence alone) | `claude-fable/run_fermion_fable_final.log` |
| the checker's logs; the section map | `claude-fable/verify_nb_part7.log`, `claude-fable/verify_nb_part8.log`; `claude-fable/nb_section_map.log` |
| the TeX/text export of the Part VII results | `claude-fable/export_fermion_fable_tex.wls` → `provenance-latex/generated/*.tex`, `*.txt` |
| the LaTeX twin of this page, its preamble and build scripts | `provenance-latex/PROVENANCE-14-FERMION-FABLE-CANONICAL-QUANTIZATION.tex` → `.pdf`; `provenance-latex/preamble.tex`; `provenance-latex/build_all.sh`, `build_all.ps1` |
| the author's two helper packages, which must sit next to the notebook | `claude-fable/ConvertMapleToMathematicaV2.wl`, `claude-fable/EtoExp.wl` |
| the numerically stable Kohn–Sham integrals and Dirac-sea energy used by the solver `fable_fermion` (final at `2bc936d`: 34/34 tests) | `fable-cosmology/rust/fable_fermion/src/kohn_sham.rs` |

`<repo>` below is wherever the repository is cloned. Every shell block finds it with
`git rev-parse --show-toplevel`.

---

## 0. The task, in the author's words

On 2026-09-24 the author gave three instructions. Their operative parts, verbatim (the ellipses
`[...]` are cuts in the quotation, not in the instruction's meaning):

> **A.** "Refine the new 16-component fermi spinor field named fable to be a complex 16-spinor,
> and quantize it using canonical quantization, extended to 4+4 dimensions. Write out the field
> equations for the fermion fable field in the presence of a primordial Gravitational Field.
> Create new provenance markdown file, latex, and pdf files, that contain the exact, correct,
> fermion fable field equations, energy-momentum tensor operator, pressure, density and equations
> of state for fermion fable field. Include a complete discussion of the canonical spin
> connection."
>
> **B.** "Include fable as a source in the Einstein Gravitational Field Equations for this
> primordial Gravitational Field, and solve the coupled field equations over a time interval from
> the beginning of the present universe until the present time. Try to use some of the relevant
> ideas from Density Functional Theory to obtain the fable ground and first excited states. Create
> another new provenance markdown file, latex, and pdf files [...] the interacting (fermion fable
> field, primordial Gravitational Field) system [...] coupled equations, canonical spin connection
> for the interacting system, energy-momentum tensor operator, pressure, density and equations of
> state [...] complete discussion of the canonical spin connections. Answer: [1] Does this system
> provide a physical mechanism for a time-varying dark energy equation of state (w)? [2] [...]
> time-varying dark matter equation of state (w)?"
>
> **C.** "Thoroughly discuss the commands that you use to solve the coupled system, and to test,
> verify, execute, and display your calculations of the coupled field equations. Create another
> new provenance markdown file, latex, and pdf files that contain your complete solution. Each of
> your major efforts should have its own section in the markdown file, latex, and pdf files. Do
> not ever refer the USER to another markdown file for any reason. The full set of 100% complete
> ideas must be given its own section in each markdown file." And: push, check and verify the
> repository. "DO NOT TAKE SHORTCUTS."

**This page is Effort A.** Efforts B and C have their own pages. The complete set of ideas of all
three efforts is section 1 below, identical on all three pages.

**The author's choice.** Instruction A itself names the field: "a complex 16-spinor". Section 3
shows why that is forced by the author's own algebra: a real anticommuting 16-spinor with the
author's spinor metric has no dynamics, a Majorana 16-spinor is massless with no potential, and a
one-chirality (Weyl or Majorana–Weyl) spinor cannot propagate. When these alternatives were laid
out on 2026-09-24, the author confirmed the choice: **a complex 16-spinor**, with Dirac conjugate
`Psibar = Psi^ddag sigma16`. Every result below is for that field.

**The work, in the order it was done.** A design (revision 1) was written and then reviewed
adversarially by four reviewers — quantization; field equations, energy–momentum tensor and spin
connection; Einstein equations and cosmology; density-functional theory and numerics — each
followed by an independent skeptic. Every finding was adopted, some only in corrected form
(section 10.4). The physics was then implemented as Part VII of the Mathematica notebook
(Sections 26–29), where every claim is an assertion. The notebook was run end to end (528/528
assertions, 0 messages). Part VIII (the coupled system of Effort B, Sections 30–33) was added
afterwards; the final run of the whole notebook, Parts I–VIII, evaluates 217 Input cells with 644/644
assertions and 0 cells with messages, and its Part VII lines are those of the Part VII run, line for
line apart from the timings (section 10.3). The exact field equations, anticommutator, fundamental symmetry and
equations of state were exported from the notebook's own objects to TeX and plain text, and those
exports are quoted verbatim on this page.

## 1. The complete set of ideas

{{COMPLETE-SET-OF-IDEAS}}

## 2. Foundations: the pre-universe, its algebra, the canonical frame, the author's `La` and `eLa`, and the classical fable of Part VI

This section sets out everything that the new work on fermion fable stands on. It restates the
author's pre-universe (a curved 4+4-dimensional spacetime), the real Clifford algebra and
split-octonion spinors built on it, the author's own wave function, Lagrangian and field
equations, the canonical frame field, and the classical field fable of 2026-09-16. It ends with
the reason why that classical field has to be refined into a complex 16-component spinor. The
reader needs nothing outside this document to follow it.

### 2.1 How the evidence is cited

All the mathematics lives in one Mathematica notebook,
`claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb`. That notebook is never edited by hand.
Its Parts I–VI, which this section restates, are generated from the cell manifests
`claude-fable/cells_part1.wl` … `cells_part6.wl`. In a manifest, `Text` cells explain and
`Input` cells compute. Every claim the notebook checks is an assertion `cfAssert[label, test]`,
which prints `PASS  label` or `FAIL  label`. The complete run of Parts I–VI is recorded in
`claude-fable/run_fable51_part6.log`. It evaluated 172 Input cells in 162.5 s with no cell
raising a message, and its final tally reads (the witness line is shortened here; in the log it
continues with a one-sentence explanation of what a witness is):

```
identities accepted on numerical evidence alone : 0   (stage 3 returned True)
non-vanishing witnesses                         : 27
  PASS  no identity in this notebook was accepted on numerical evidence alone
Assertions run: 358   passed: 358   failed: 0
```

Each statement below is tagged with one of four kinds of evidence:

- **[A]** an assertion. Its label is quoted exactly as the log prints it after `PASS`.
- **[D]** a displayed result: an Output the notebook prints but does not assert. Where a
  displayed result was re-read for this document from the saved kernel state, that is said.
- **[P]** prose only: a statement that appears in a `Text` cell and is not checked by any
  assertion.
- **[VII]** proved in Part VII, the new part of the notebook written for fermion fable (Sections
  26–29). Its labels are quoted verbatim from `claude-fable/run_fermion_fable_part7.log`, which
  reports `Assertions run: 528   passed: 528   failed: 0` for Parts I–VII together.

How an identity is certified (restated from Section 15 of the notebook). `cfZeroQ` and
`cfZeroArrayQ` try three stages in turn:

1. exact structural zero;
2. `Simplify` under the geometric assumptions, with a 5-second budget;
3. a 30-digit numerical evaluation at three rational probe points, with test functions
   substituted for the undetermined `a4` (and for the undetermined rapidity of the notebook's
   boosted-frame bridge); the result is accepted as zero only if its magnitude is below 10^-22.

An identity accepted at stage 3 counts as a *numerical certificate*, and the run reports zero of
those: every identity in Parts I–VI is closed symbolically. A claim that something is *not*
zero is made with `cfNonZeroWitnessQ`. It passes only if, at some probe point, every entry
evaluates to a number and at least one of them has magnitude above 10^-10. That is a complete
proof of non-vanishing; the run has 27 such witnesses. The probe functions are test inputs only,
never definitions.

The session policy is the original notebook's, unchanged: `Simplify` has a 1-second budget and
`FullSimplify` a 3-second budget. `DIM8 = 8`, and the model's three constants `M` (a mass), `K`
and `H` (a Hubble-like constant) are `Protect`ed, so no cell can assign them (Section 1: a
`Text` cell and the `Input` cells that set this up; no assertion) [P].

### 2.2 Coordinates, the flat 4+4 metric, and which directions are timelike

The coordinates are `X = {x0, x1, x2, x3, x4, x5, x6, x7}`. The flat tangent-space metric is

```
eta4488 = DiagonalMatrix[{+1, +1, +1, +1, -1, -1, -1, -1}]        signature (4,4)
```

| coordinate | `eta` | the original notebook's name (Section 2) | reading used in this work |
|---|---|---|---|
| `x0` | `+1` | hidden space | the hidden **spacelike** coordinate |
| `x1, x2, x3` | `+1` | ordinary 3-space | the **observed sheet** |
| `x4` | `−1` | time | the **observer's time** |
| `x5, x6, x7` | `−1` | superluminal deflating time directions | the hidden **timelike sheet** |

[A] `eta4488 . eta4488 == ID8`; `eta4488 is symmetric`; `signature of eta4488 is (4,4)`.

Index conventions (restated from Section 2). Latin indices `a, b, A, B` are flat and run 0..7.
Greek indices `mu, nu` are curved and run 0..7. Wolfram arrays are 1-based, so index `A` sits at
array position `A+1`. For example, `x4` is entry 5 of `X`, so Part VI's energy density
`rho = T_44` is the array element `T[[5,5]]`.

The notebook uses two sets of assumptions:

- `ssX = H > 0 && sX0 && 6 H x0 > 0 && 2 la[x4] > 0 && Cot[6 H x0] > 0 && Sin[6 H x0] > 0`,
  with `sX0 = x0 > 0 && x1 > 0 && ... && x7 > 0` (all eight coordinates positive), for the
  `(x0, x4)` chart;
- `constraintVars = x0 > 0 && x4 > 0 && z > 0 && t > 0`, for the chart `z = 6 H x0`, `t = H x4`.

**`la` is a free function inherited from the original notebook.** It occurs only inside `ssX`.
It is never given a value, and nothing here invents one [P, Section 2].

### 2.3 SO(4): the self-dual and anti-self-dual blocks

The six antisymmetric real 4×4 matrices split under the Hodge star into a self-dual 3-space and
an anti-self-dual 3-space, the two commuting `su(2)` factors of `so(4)`. The original notebook
builds both from two elementary tensors (Section 3):

```
Qa[h,p,q] = Signature[{h,p,q,4}]
Qb[h,p,q] = KroneckerDelta[p,4] KroneckerDelta[q,h] - KroneckerDelta[p,h] KroneckerDelta[q,4]
s4by4[h] = Qa - Qb   (self-dual),      t4by4[h] = Qa + Qb   (anti-self-dual),      h = 1, 2, 3
```

Explicitly [D], with rows separated by semicolons:

```
s4by4[1] = {{0,0,0,1};{0,0,1,0};{0,-1,0,0};{-1,0,0,0}}    t4by4[1] = {{0,0,0,-1};{0,0,1,0};{0,-1,0,0};{1,0,0,0}}
s4by4[2] = {{0,0,-1,0};{0,0,0,1};{1,0,0,0};{0,-1,0,0}}    t4by4[2] = {{0,0,-1,0};{0,0,0,-1};{1,0,0,0};{0,1,0,0}}
s4by4[3] = {{0,1,0,0};{-1,0,0,0};{0,0,0,1};{0,0,-1,0}}    t4by4[3] = {{0,1,0,0};{-1,0,0,0};{0,0,0,-1};{0,0,1,0}}
```

[A] `s4by4 is self-dual`; `t4by4 is anti-self-dual`; `s4by4 and t4by4 are antisymmetric`;
`the two su(2) factors commute`; and, for the nine mixed products `st[J,K] = s4by4[J] . t4by4[K]`,
`st[J,K] is symmetric`.

### 2.4 The real 8×8 Clifford generators `tau`, `taubar`, and the spinor metric `sigma`

The O(4,4) spinor metric is

```
sigma = ArrayFlatten[{{0, ID4}, {ID4, 0}}]
```

[A] `sigma . sigma == ID8`; `sigma is symmetric`; `Tr[sigma] == 0`. The type-1 and type-2
split-octonion spinors both carry this same `sigma`, because `sigma == Inverse[sigma]` [P].

The generators (Section 4):

```
tau[0]   = ID8
tau[h]   = ArrayFlatten[{{0, s4by4[h]}, { s4by4[h], 0}}]                  h = 1, 2, 3
tau[3+k] = ArrayFlatten[{{0, t4by4[4-k]}, {-t4by4[4-k], 0}}]              k = 1, 2, 3   (t4by4 taken in the order 3, 2, 1)
tau[7]   = tau[1].tau[2].tau[3].tau[4].tau[5].tau[6]  =  DiagonalMatrix[{-1,-1,-1,-1,+1,+1,+1,+1}]   [D]
taubar[A] = sigma . Transpose[sigma . tau[A]]                              A = 0..7   (the sigma-adjoint)
```

The order `3, 2, 1` is the original's. It is what makes `tau[7]` the product of the first six
and `sigma = tau[1].tau[2].tau[3]` [P]. The original calls the list of the six blocks
`sixAntiSymmetric8by8`, but that name fits only half of it: [A]
`blocks 1-3 (built from s4by4) are antisymmetric`; `blocks 4-6 (built from t4by4) are symmetric`.

The defining relation is the split Clifford algebra of the 4+4 quadratic form in its real 8×8
"half-spinor" form:

```
(1/2) ( tau[A] . taubar[B] + tau[B] . taubar[A] )  ==  eta4488[[A+1,B+1]] ID8
```

[A] `(1/2)(tau[A].taubar[B] + tau[B].taubar[A]) == eta4488[[A+1,B+1]] ID8`.

The ordering identities [A]:

- `sigma == tau[1].tau[2].tau[3]`
- `sigma == tau[4].tau[5].tau[6].tau[7]`
- `tau[1]...tau[7] == tau[0] == ID8`
- `sigma . taubar[A] == Transpose[sigma . tau[A]]`
- `-eta4488[[A+1,A+1]] tau[A] == Transpose[tau[A]] for A = 1..7`

The last one says that `tau[1..3]` are antisymmetric and `tau[4..7]` are symmetric. The second
invariant of the original is `Omega = sigma . tau[7]`: [A] `Omega == tau[4].tau[5].tau[6]`.

A complete basis of the 8×8 algebra (Section 7) is the 63 ordered products of 1, 2 or 3 of
`tau[1..7]`, together with `ID8`. [A] `the 8x8 basis has 64 elements`;
`the 64 elements are distinct`; `(1/8) Tr[bas64[A].bas64[B]] == eta64[[A,B]]`;
`symmetric 8x8 basis elements number 36`; `antisymmetric 8x8 basis elements number 28`.

### 2.5 The 16×16 Dirac matrices, chirality, `sigma16`, and `so(4,4)`

Following E. A. Lord's reduced Brauer–Weyl construction (Math. Proc. Camb. Phil. Soc. 64 (1968)
765–778), the 8×8 generators are doubled off-diagonally (Section 5):

```
T16[A] = ArrayFlatten[{{0, taubar[A]}, {tau[A], 0}}]        A = 0..7        (real 16x16;  gamma[a] means T16[a])
T16[8] = T16[0].T16[1]. ... .T16[7]                                        (the chirality operator)
sigma16 = T16[0].T16[1].T16[2].T16[3]                                      (the 16x16 spinor metric)
```

Assertions [A]:

- `{T16[A], T16[B]}/2 == eta4488[[A+1,B+1]] ID16`
- `sigma16 == ArrayFlatten[{{-sigma,0},{0,sigma}}]`
- `sigma16 . T16[A] is antisymmetric for A = 0..7`
- `T16[8] == sigma16 . T16[4].T16[5].T16[6].T16[7]`
- `sigma16 is symmetric and sigma16 . sigma16 == ID16`
- `sigma16 . covariantDiffMatrix is symmetric`, with `covariantDiffMatrix = T16[5].T16[6].T16[7]`

**The two chiralities are the two split-octonion spinors.** The notebook defines
`PL = (ID16 - T16[8])/2` and `PR = (ID16 + T16[8])/2`. [A] `PL + PR == ID16`;
`PL is idempotent`; `PR is idempotent`; `PL . PR == PR . PL == 0`;
`PL projects onto the upper (type-1) components, PR onto the lower (type-2) components`.

The last assertion is equivalent to

```
T16[8] = DiagonalMatrix[{-1 (x8), +1 (x8)}] = diag(-ID8, +ID8)
```

A 16-component spinor is therefore the direct sum `Psi = (psi1, psi2)`:

- the upper eight components are the **type-1** split-octonion spinor, of chirality `−1`;
- the lower eight components are the **type-2** spinor, of chirality `+1`.

Every `T16[A]` exchanges the two halves, since it is block off-diagonal [P].

**The `so(4,4)` generators** are

```
SAB[[A+1,B+1]] = S^{AB} = (1/4) Commutator[T16[A], T16[B]]
```

Assertions [A]:

- `SAB is antisymmetric in its two flat indices`
- `sigma16 . SAB is antisymmetric`
- `T16[8] commutes with every SAB: the chiral halves are each Spin(4,4)-invariant`
- `[SAB,SAB] closes on the so(4,4) algebra`, which is the relation
  `[S_AB, S_CD] == -( eta_AC S_BD - eta_AD S_BC - eta_BC S_AD + eta_BD S_AC )`
- `[SAB, T16] reproduces the vector representation`, which is
  `[S_AB, gamma_C] == -eta_CA gamma_B + eta_CB gamma_A`

The spin connection of the frame field enters as
`(1/8) omega_{mu ab} [gamma^a, gamma^b] = (1/2) omega_{mu ab} S^{ab}`.

**The 256-element basis** (Section 6) is the ordered products of `k` distinct generators,
`k = 1..8`, followed by `ID16`, taken in the original's order. [A]
`base16[[93]] is sigma16` (the word `{0,1,2,3}`); `base16[[255]] is the chirality operator T16[8]`;
`base16[[256]] is the identity`; `Tr[M.M]/16 is +1 or -1 for every basis element`;
`136 basis elements have Tr[M.M] > 0`; `120 basis elements have Tr[M.M] < 0`;
`symmetric basis elements number 16*17/2 = 136`;
`antisymmetric basis elements number 16*15/2 = 120`; `Tr[M.M] > 0 exactly when M is symmetric`;
`Tr[M.M] < 0 exactly when M is antisymmetric`.

Section 8 also builds the ordinary 4×4 Dirac algebra of the `(x1, x2, x3, x4)` block, whose
metric is `g44 = diag(1,1,1,-1)`. For example [A]:
`{gamma4[h], gamma4[k]} == 2 g44[[h,k]] ID4  for h,k = 1..4`;
`[S44,S44] closes on the so(3,1) algebra`. It plays no role below.

### 2.6 Cartan triality and the split octonions (Section 9): what is proved

The vector, the type-1 spinor and the type-2 spinor are three 8-dimensional representations of
Spin(4,4) that triality relates. The original makes the vector-to-spinor bridge concrete with
one distinguished spinor, `unit`. It is row 8 of the eigenvectors of `sigma`, rescaled by
`1/Sqrt[2]`. Assertions [A]:

- `unit is pinned to the author's spinor {1/Sqrt[2],0,0,0,1/Sqrt[2],0,0,0} -- the row order of Eigensystem is not relied on silently`
- `each uEig row is sigma-normalized to +/-1`
- `unit is sigma-normalized to +1`

The bridge and its inverse are

```
triVecToSpin[[A+1, a+1]] = ( unit . sigma . taubar[A] )[[a+1]]     (flat vector row A, type-1 spinor column a)
triSpinToVec             = Inverse[triVecToSpin]
```

Assertions [A]:

- `triVecToSpin . triSpinToVec == ID8`
- `triSpinToVec . triVecToSpin == ID8`
- `triSpinToVec == Transpose[ eta_AA tau[A].unit ]  (the original's closed form)`
- `etaTri is symmetric`; `etaTri has signature (4,4)`
- `triVecToSpin transports etaTri back to eta4488`
- `THE TRIALITY METRIC IS EXACTLY THE SPINOR METRIC:  etaTri == sigma`

The split-octonion structure constants are read off from the generators through the bridge. In
the type-1 spinor basis they are `mabc`; in the vector basis they are `mABC`, the usual
multiplication table. Assertions [A]:

- `eA[1] is a two-sided identity for the vector-basis product`
- `<eA, eB> composition is compatible with eta (basis-unit norm form)`
- `m_{ABC} restricted to imaginary directions is totally antisymmetric`

The scope of what is proved: the norm is multiplicative **on the basis units**, and the
imaginary structure constants are totally antisymmetric. The general composition law
`N(x y) = N(x) N(y)` for arbitrary elements, and alternativity, are **not** asserted.

### 2.7 The wave function of the un-universe and the author's Lagrangian `La` (Section 11)

The original notebook calls `Psi16` the wave function of the "un-universe". It is sixteen scalar
functions of the hidden coordinate `x0` and the time `x4`:

```
Psi16 = Table[f16[k][x0, x4], {k, 0, 15}]          upper 8 = type-1 spinor,  lower 8 = type-2 spinor
```

[A] `Psi16 is the direct sum of the type-1 and type-2 spinors`. Two re-parametrizations are
recorded:

- `f16[k] -> Z[k][6 H #1, H #2] &`, which is the one used downstream;
- `f16[k] -> nZ[k][6 H #1, H #2]/Sqrt[Sin[6 H #1]] &`, the author's alternative normalization.

**The author's Lagrangian, exactly as defined in Section 11:**

```
La[] := ((1/H) Transpose[Psi16] . sigma16 .
          Sum[T16[alpha1 - 1] . D[Psi16, X[[alpha1]]], {alpha1, 1, Length[X]}]
        + 2 (M/H) Transpose[Psi16] . sigma16 . Psi16
       ) // Simplify[#, constraintVars] &
```

that is,

```
La = (1/H) Psi16^T sigma16 T16[alpha] d_alpha Psi16  +  (2M/H) Psi16^T sigma16 Psi16
   = (1/H) Psi16^T sigma16 ( T16[0] d_x0 + T16[4] d_x4 ) Psi16  +  (2M/H) s,        s = Psi16^T sigma16 Psi16
```

The second line holds because `Psi16` depends only on `x0` and `x4`. It was checked for this
document against the evaluated `La[]` (a `Simplify` difference of exactly 0); it is not a
notebook assertion. The mass term is `(2M/H) s`: it is `+(2M/H)` times the scalar bilinear
`s = Psi16^T sigma16 Psi16`.

The evaluated `La[]` [D] is shown below. Write `fk = f16[k][x0,x4]`,
`d0 fk = Derivative[1,0][f16[k]][x0,x4]` and `d4 fk = Derivative[0,1][f16[k]][x0,x4]`. Then
`H La` is exactly

```
 -4 M ( f0 f4 + f1 f5 + f2 f6 + f3 f7 - f8 f12 - f9 f13 - f10 f14 - f11 f15 )
 + f12 ( d4 f5  + d0 f0 )  + f13 (-d4 f4  + d0 f1 )  + f14 (-d4 f7  + d0 f2 )  + f15 ( d4 f6  + d0 f3 )
 + f8  (-d4 f1  + d0 f4 )  + f9  ( d4 f0  + d0 f5 )  + f10 ( d4 f3  + d0 f6 )  + f11 (-d4 f2  + d0 f7 )
 + f4  ( d4 f13 - d0 f8 )  - f5  ( d4 f12 + d0 f9 )  - f6  ( d4 f15 + d0 f10)  + f7  ( d4 f14 - d0 f11)
 - f0  ( d4 f9  + d0 f12)  + f1  ( d4 f8  - d0 f13)  + f2  ( d4 f11 - d0 f14)  - f3  ( d4 f10 + d0 f15)
```

**The structural identity behind it.** `sigma16 . T16[A]` is antisymmetric (Section 5). An
antisymmetric form vanishes on the diagonal, so for commuting components
`Psi16^T sigma16 T16[alpha] Psi16 = 0` identically. The kinetic term therefore equals minus its
transpose, with no boundary term. [A]
`Psi16 . sigma16 . T16[alpha] . Psi16 == 0 identically (antisymmetric form)`;
`the kinetic term equals minus its transpose, exactly`;
`La[] == its conjugate form when the coefficients match`. The last one is
`La == -(1/H) (d_alpha Psi16)^T sigma16 T16[alpha] Psi16 + (2M/H) Psi16^T sigma16 Psi16`. The
original's scratch cell compared `La` with a form carrying mismatched factors of `H` and so
found a non-zero difference [P].

### 2.8 The Euler–Lagrange equations `eLa` (Section 12)

The original's Euler–Lagrange operator, transcribed exactly:

```
eL[Lagrangian_Symbol, detsqrt_] := Module[{L, t},
  L = Lagrangian[];
  t = Table[
    FullSimplify[
      (1/detsqrt) ( D[L, f16[k][x0, x4]]
                    - D[D[L, Derivative[1, 0][f16[k]][x0, x4]], x0]
                    - D[D[L, Derivative[0, 1][f16[k]][x0, x4]], x4] ),
      constraintVars],
    {k, 0, 15}];
  Return[t /. subsDefects]];                (* subsDefects = {} *)
eLa = eL[La, 1]
```

[A] `there are sixteen field equations`. `eLa[[k]]` is the Euler–Lagrange expression for the
component `f16[k-1]`, and the field equations are `eLa[[k]] == 0`. **The sixteen expressions,
exactly as the notebook computes them** [D]:

```
eLa[[1]]  = (-2*(2*M*f16[4][x0, x4] + Derivative[0, 1][f16[9]][x0, x4] + Derivative[1, 0][f16[12]][x0, x4]))/H
eLa[[2]]  = (-2*(2*M*f16[5][x0, x4] - Derivative[0, 1][f16[8]][x0, x4] + Derivative[1, 0][f16[13]][x0, x4]))/H
eLa[[3]]  = (-2*(2*M*f16[6][x0, x4] - Derivative[0, 1][f16[11]][x0, x4] + Derivative[1, 0][f16[14]][x0, x4]))/H
eLa[[4]]  = (-2*(2*M*f16[7][x0, x4] + Derivative[0, 1][f16[10]][x0, x4] + Derivative[1, 0][f16[15]][x0, x4]))/H
eLa[[5]]  = (-2*(2*M*f16[0][x0, x4] - Derivative[0, 1][f16[13]][x0, x4] + Derivative[1, 0][f16[8]][x0, x4]))/H
eLa[[6]]  = (-2*(2*M*f16[1][x0, x4] + Derivative[0, 1][f16[12]][x0, x4] + Derivative[1, 0][f16[9]][x0, x4]))/H
eLa[[7]]  = (-2*(2*M*f16[2][x0, x4] + Derivative[0, 1][f16[15]][x0, x4] + Derivative[1, 0][f16[10]][x0, x4]))/H
eLa[[8]]  = (-2*(2*M*f16[3][x0, x4] - Derivative[0, 1][f16[14]][x0, x4] + Derivative[1, 0][f16[11]][x0, x4]))/H
eLa[[9]]  = (2*(2*M*f16[12][x0, x4] - Derivative[0, 1][f16[1]][x0, x4] + Derivative[1, 0][f16[4]][x0, x4]))/H
eLa[[10]] = (2*(2*M*f16[13][x0, x4] + Derivative[0, 1][f16[0]][x0, x4] + Derivative[1, 0][f16[5]][x0, x4]))/H
eLa[[11]] = (2*(2*M*f16[14][x0, x4] + Derivative[0, 1][f16[3]][x0, x4] + Derivative[1, 0][f16[6]][x0, x4]))/H
eLa[[12]] = (2*(2*M*f16[15][x0, x4] - Derivative[0, 1][f16[2]][x0, x4] + Derivative[1, 0][f16[7]][x0, x4]))/H
eLa[[13]] = (2*(2*M*f16[8][x0, x4] + Derivative[0, 1][f16[5]][x0, x4] + Derivative[1, 0][f16[0]][x0, x4]))/H
eLa[[14]] = (2*(2*M*f16[9][x0, x4] - Derivative[0, 1][f16[4]][x0, x4] + Derivative[1, 0][f16[1]][x0, x4]))/H
eLa[[15]] = (2*(2*M*f16[10][x0, x4] - Derivative[0, 1][f16[7]][x0, x4] + Derivative[1, 0][f16[2]][x0, x4]))/H
eLa[[16]] = (2*(2*M*f16[11][x0, x4] + Derivative[0, 1][f16[6]][x0, x4] + Derivative[1, 0][f16[3]][x0, x4]))/H
```

These were printed for this document by loading the notebook's own `DumpSave` file
`claude-fable/claude-fable_Einstein-Rosen-2-Planes-eLa.mx`. That file is `SameQ` to the author's
original `Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLa.mx` in the
repository root; this was re-checked for this document with `SameQ`, which returned `True`. So
they are the author's equations, unchanged. In matrix form they read

```
eLa = (2/H) sigma16 . ( T16[0] d_x0 + T16[4] d_x4 + 2M ) Psi16,        i.e.   ( T16[0] d_x0 + T16[4] d_x4 ) Psi16 = -2M Psi16
```

This matrix form was checked for this document (a `Simplify` difference of exactly 0); it is not
a notebook assertion. In Part VI's language (below) it is the flat-frame Dirac equation
`gamma^mu d_mu Psi = H V'(s) Psi` with `gamma^mu = T16[mu]` and `V'(s) = -2M/H`. What Part VI
asserts is the fidelity anchor below: the Euler–Lagrange expressions of its fable Lagrangian with
`V = -(2M/H) s`, on the flat frame and with no volume factor, are exactly `eLa`.

**The coupling pattern.** Iterating `MergeSetsStep` to a fixed point merges any two sets of
component indices that share an index. The result partitions the sixteen components into [D]

```
eLaCouplings = {{0, 5, 8, 13}, {1, 4, 9, 12}, {2, 7, 10, 15}, {3, 6, 11, 14}}
```

[A] `the coupled blocks partition all sixteen components`; `there are four blocks of four`. The
notebook writes `eLa` and `eLazt` to `.mx` files beside itself, as the original does.

### 2.9 The `(z,t)` chart, four blocks of four, and the closed-form solutions (Section 13)

**The chart.** The chart is `z = 6 H x0`, `t = H x4`. Substituting `f16[k] -> Z[k][6 H x0, H x4]`
and then `x0 -> z/(6H)`, `x4 -> t/H`, with the original's normalization `1/(2H)`, gives
`eLazt = (1/(2H)) eLa` in the new chart. The first equation, for example, reads [D]

```
eLazt[[1]] = -((2*M*Z[4][z, t] + H*Derivative[0, 1][Z[9]][z, t] + 6*H*Derivative[1, 0][Z[12]][z, t])/H^2)
```

**Decoupling.** Solving `0 == eLazt` for the sixteen `t`-derivatives gives [A]
`all sixteen t-derivatives are determined`. Relabelling each coupling set as a consecutive block,
`sZtOyZ` maps `Z[k]` to `yZ[j]` as follows [D]:

- `Z0, Z5, Z8, Z13` → `yZ0..yZ3`
- `Z1, Z4, Z9, Z12` → `yZ4..yZ7`
- `Z2, Z7, Z10, Z15` → `yZ8..yZ11`
- `Z3, Z6, Z11, Z14` → `yZ12..yZ15`

Assertions [A]:

- `the relabelling is a bijection of the sixteen components`
- `the system splits into four blocks of four equations`
- `each 4x4 block is closed in its own four components`

The relabelling is a linear map. [A] `the yZ coefficient matrix is the identity`;
`ORTHOGONAL: Transpose[S] . S == ID16`; `ORTHOGONAL: S . Transpose[S] == ID16`;
`but NOT a O(8,8) transformation: it does not preserve sigma16`;
`and NOT a direct sum: it mixes type-1 with type-2`.

**Closed forms.** `DSolve`, wrapped in a 60-second `TimeConstrained`, returns every block
unevaluated. The log prints `block 1: returned unevaluated` through
`block 4: returned unevaluated`. The author obtained closed forms with Maple and pasted them into the original as
strings. The notebook reproduces them verbatim, parses them with the author's
`ConvertMapleToMathematicaV2`, and then substitutes them back into the four blocks. That
substitution, not the parser, is what certifies them. [A]
`all sixteen components have a closed form`; `there are sixteen pure-function rules`;
`THE MAPLE CLOSED FORMS SOLVE ALL SIXTEEN EQUATIONS`.

Block `j` has one constant `Cj` and four constants `cj1..cj4`. Every component of block `j`
carries the same exponential

```
E_j = exp( ( 6 (z/6 + t) H^2 Cj^2 - 6 (-z/6 + t) M^2 ) / (6 Cj H^2) )  =  exp( Cj (t + z/6) - M^2 (t - z/6)/(Cj H^2) )
```

Block 1, verbatim from the Maple string:

```
yZ0 =  E_1 (H^2 (c11 c12 - c13 c14) C1^2 - M^2 (c11 c12 + c13 c14)) / (2 H C1 M)
yZ1 = -E_1 (H^2 (c11 c12 - c13 c14) C1^2 + M^2 (c11 c12 + c13 c14)) / (2 H C1 M)
yZ2 =  c13 c14 E_1
yZ3 =  c11 c12 E_1
```

Blocks 2, 3 and 4 have the same shape with their own constants and signs (Section 13 prints all
four strings).

### 2.10 Bilinears, the solution branches, and M6 = 3 generations of Einstein–Rosen 2-planes (Section 14)

Five bilinears are formed from the solution written in the relabelled basis. `psi1sol` and
`psi2sol` are its first and second halves of eight components **in the relabelled `yZ` basis**,
that is, coupling blocks 1–2 and coupling blocks 3–4. They are not the type-1 and type-2
spinors. [A] `the yZ split at 8 is NOT the type-1/type-2 split`;
`the first relabelled block holds four type-1 and four type-2 components`.

For the full sixteen-component norm, [A]:

- `psi . sigma16 . psi == psi2.sigma.psi2 - psi1.sigma.psi1`
- `sigma16 alone is SYMMETRIC, so psi . sigma16 . psi is not forced to vanish`
- `and for this solution it does NOT vanish: it is not the zero expression`

With the light-cone coordinates `ztadv = 6t + z` and `ztret = 6t − z`, the notebook requires
the two block norms to be light-cone constants. [A]
`the light-cone-constant condition has solutions`. `Solve` returns four branches [D], among them
`{C2 -> -C1, C4 -> -C3}`, the original's branch. [A]
`on the branch C2 = -C1, C4 = -C3 the two norms are independent of ztadv and ztret`.

The displayed values on that branch [D, re-read for this document from the saved kernel state]
are sharper than the assertion. There, `psi.sigma16.psi`, `psi1.sigma.psi1` and
`psi2.sigma.psi2` are all identically `0`, while `psi2.sigma.psi1` is not.

**The two mass branches** [D] are, both taken on the branch `C2 -> -C1, C4 -> -C3`:

- `Psi16ab`: `M -> H Mab Sqrt[C1 C3]`, which keeps a free dimensionless ratio `Mab`;
- `Psi16aa`: `M -> H Sqrt[C1 C3]`, the case `Mab = 1`.

In the `(x0,x4)` chart the advanced and retarded coordinates are `xiadv = x0 − x4` and
`xiret = x0 + x4` (the notebook's `ξadv`, `ξret`). Every component of `Psi16aa` is a constant
times one of `exp(±H(C1 xiret + C3 xiadv))` or `exp(±H(C3 xiret + C1 xiadv))` [D, re-read for this document from the saved kernel state; the
notebook prints `Short` forms]. The special
case `C3 -> C1`, `Psi16x0ONLY`, depends on `x0` alone. It is exactly [D, re-read in full from the saved kernel state]

```
Psi16x0ONLY = { -c13 c14 e^(2 C1 H x0),  c23 c24 e^(-2 C1 H x0), -c33 c34 e^(2 C1 H x0),  c43 c44 e^(-2 C1 H x0),
                 c21 c22 e^(-2 C1 H x0), -c11 c12 e^(2 C1 H x0),  c41 c42 e^(-2 C1 H x0), -c31 c32 e^(2 C1 H x0),
                 c13 c14 e^(2 C1 H x0),  c23 c24 e^(-2 C1 H x0),  c33 c34 e^(2 C1 H x0),  c43 c44 e^(-2 C1 H x0),
                 c21 c22 e^(-2 C1 H x0),  c11 c12 e^(2 C1 H x0),  c41 c42 e^(-2 C1 H x0),  c31 c32 e^(2 C1 H x0) }
```

**Triality turns each spinor of the solution into a vector.** The genuine type-1 and type-2
spinors are `psi1 = Psi16ab[[1;;8]]` and `psi2 = Psi16ab[[9;;16]]`. From them:

```
vectorFormOfType2 = triVecToSpin . psi2
vectorFormOfType1 = eta4488 . ( Transpose[psi1] . sigma . triSpinToVec )
```

Assertions [A]:

- `both triality vectors have eight components`
- `vectorFormOfType2 == psi2 contracted on the SPINOR index of triVecToSpin`
- `triVecToSpin and triSpinToVec really are mutually inverse`

Each vector is normal to a 7-plane through the origin of the split-octonion algebra, the set of
position vectors `Zoct` with `<vector, Zoct> = 0`. [A]
`sevenPlane2 is annihilated by vectorFormOfType2`; `sevenPlane1 is annihilated by vectorFormOfType1`.

Two non-parallel 7-planes in an 8-space meet in a 6-plane, **M6**. [A]
`M6 is a non-empty solution set`; `M6 has six free parameters`. The intersection determines
`zoct[7]` and `zoct[8]` as linear combinations of the free `zoct[1] .. zoct[6]`, with
coefficients that depend on `x0`, `x4` and the constants `C1`, `C3`, `Mab`, `cjk` [D].

What is proved is that M6 exists and is a 6-parameter set. The reading of M6 as the home of
"the three generations of Einstein–Rosen 2-plane bridges", which gives the original notebook its
title, is the author's interpretation and is stated in prose only [P].

Finally [A]: `cfResolution[unit]: the closed-form bridge equals the matrix inverse`;
`cfResolution[unit]: the two bridges are mutually inverse`;
`cfResolution[unit] reproduces triVecToSpin`.

### 2.11 The canonical frame field (Section 15), restated

At every point of the curved 4+4 spacetime there is a local flat 4+4 Minkowski coordinate
system. The frame field installs it; in eight dimensions a vielbein is simply an 8-dimensional
vierbein. The frame is stored with the curved index `mu` as the row and the flat index `a` as the
column. The canonical frame is the one the original notebook records as the value of its symbol
`gtrye`:

```
frameCanonical = DiagonalMatrix[{ Tan[6 H x0],  q, q, q,  1,  p, p, p }]
    q = Exp[-a4[H x4]] / Sin[6 H x0]^(1/6)
    p = Exp[+a4[H x4]] / Sin[6 H x0]^(1/6)
g = frame . eta4488 . Transpose[frame]
ds^2 = Tan[6 H x0]^2 dx0^2 + q^2 (dx1^2 + dx2^2 + dx3^2) - dx4^2 - p^2 (dx5^2 + dx6^2 + dx7^2)
```

Assertions [A]:

- `CANONICAL [structural]: frame . coframe == ID8  (certifies only that the frame is invertible)`
- `CANONICAL [definition]: g == frame . eta4488 . Transpose[frame]  (bridge [d]; this IS how g was defined, so it cannot fail)`
- `CANONICAL [has content]: g == diag(Tan[6 H x0]^2, q^2, q^2, q^2, -1, -p^2, -p^2, -p^2), the stated line element`
- `CANONICAL [has content]: Diagonal[g] == Diagonal[eta4488] * Diagonal[frame]^2 exactly`
- `CANONICAL [has content]: g has signature (4,4), GIVEN a4 real and 0 < 6 H x0 < Pi/2`
- `Inverse[g] == Transpose[coframe] . eta4488 . coframe`
- `g is symmetric`
- `the metric is non-degenerate`
- `FABLE-5.1: det g == Sec[6 H x0]^2  (positive, as signature 4+4 requires)`

So `Sqrt[|det g|] = Sec[6 H x0]` on `0 < 6 H x0 < Pi/2`. This is the notebook's volume factor
`sqrtDetgTele = Sec[6 H x0]`, defined in Section 21 and used throughout Part VI (Section 15
itself displays `Abs[Sec[6 H x0]]`).

Two facts follow from the definitions of `q` and `p`. First, `q p = 1/Sin[6 H x0]^(1/3)`: the
two exponentials cancel [P, Section 15]. Hence `q^3 p^3 = 1/Sin[6 H x0]`, and the 8-volume
element factorizes. [A]:

- `FABLESCALAR [has content]: Sqrt[det g_8] == q^3 * (Tan[6 H x0] p^3): observed 3-volume density times hidden 4-volume density`
- `FABLESCALAR [has content]: the 8-volume element is independent of x4: d(q^3 p^3)/dx4 == 0`
- `FABLESCALAR [has content]: the hidden 4-volume density scales as Exp[+3 a4[H x4]] and the observed 3-volume as Exp[-3 a4[H x4]]: Vhid Exp[-3 a4] and q^3 Exp[+3 a4] are x4-independent`

(One Text cell of Section 23 writes `q^3 p^3 = 1/Sqrt[Sin[6 H x0]]`. That is a typo in the
prose: from `q p = Sin^(-1/3)` the cube is `1/Sin[6 H x0]`, which is what makes
`Sqrt[det g] = q^3 Tan p^3 = Sec[6 H x0]`. The assertions above are unaffected.)

**The curved Dirac matrices** are `gamma^mu = Sum_a coframe[[a, mu]] T16[a]`, with
`coframe = Inverse[frame]`. On the canonical frame they are as follows (read for this document
from the saved kernel state; they follow directly from the diagonal coframe):

```
gamma^0 = Cot[6 H x0] T16[0]
gamma^i = (1/q) T16[i] = E^(a4[H x4]) Sin[6 H x0]^(1/6) T16[i]       i = 1, 2, 3
gamma^4 = T16[4]
gamma^h = (1/p) T16[h] = E^(-a4[H x4]) Sin[6 H x0]^(1/6) T16[h]      h = 5, 6, 7
```

[A] `{gammaCurved[mu], gammaCurved[nu]} == 2 gInv[mu,nu] ID16`; and, from Part VI,
`FABLE [has content]: (gamma^4)^2 == -ID16, so gamma^4 d_4 Psi' == H V'(s) Psi' is solved by d_4 Psi' == -H V'(s) gamma^4 Psi'`.

**The free function `a4`.** `a4` is a free, differentiable scalar function of `H x4`. The
original notebook never defines it; it occurs only inside the recorded frame. It is carried
symbolically everywhere and is never given a value, and every result holds for arbitrary `a4`.
The notebook says so on screen: the log prints
`NOTE  a4 is an undefined scalar function inherited from the original notebook` together with
the explanation, which also names `la`. Near its end Part VI checks [A]
`PART VI [control]: a4 is STILL UNDEFINED -- nothing in Part VI gave it a value; and the FLRW scale factor aF never entered the canonical frame`.

**The physical reading.** The observer is the geodesic observer `u = d/dx4`: `g_44 = −1`, and
`x0` is constant along the worldline [P, Section 23]. The cosmological time is `t = x4`, the
proper time of that observer [P, Section 25]. The
observed sheet is `x1, x2, x3`; the hidden spacelike coordinate is `x0`; the hidden timelike
sheet is `x5, x6, x7`. Part VI makes the kinematic identification `a(t) ~ q ~ Exp[−a4[H t]]`,
`H_obs = −H a4'[H t]`. Assertions [A]:

- `KINEMATIC [definition]: ln q == -a4[H x4] + const(x0):  D[Log[q], x4] == -H a4'[H x4] == H_obs`
- `KINEMATIC [has content]: the second sheet contracts at exactly the opposite rate:  D[Log[p], x4] == +H a4'[H x4] == -H_obs`
- `KINEMATIC [has content]: H_obs > 0 exactly when a4' < 0 (and H_obs < 0 when a4' > 0) -- the sign HYPOTHESIS of this Part, stated, not derived`

So which sheet grows is set by the sign of `a4'`, which is never fixed. Section 15's prose
describes the 3-space contracting while the deflating directions expand. Part VI reads the same
frame the other way round (the observed sheet expands when `a4' < 0`) and states that sign as a
hypothesis [P].

**What the canonical spin connection contributes.** The spin connection of this frame follows
from the zero-torsion vielbein postulate. Only the facts that the classical fable uses are
restated here:

```
Gamma^spin_mu = (1/8) omega_{mu ab} [T16[a], T16[b]]            (block diagonal: never mixes type-1 with type-2)
D_mu Psi = d_mu Psi + Gamma^spin_mu Psi
```

Its 24 non-zero components [D, Section 16] are listed below, with `c = Cos[6Hx0]`,
`s = Sin[6Hx0]`, `A = a4[Hx4]`, `A' = a4'[Hx4]`, `j = 1,2,3` and `k = 5,6,7`:

| component | value |
|---|---|
| `omega[j; 0,j] = -omega[j; j,0]` | `H c^2 / (E^A s^(13/6))` |
| `omega[j; 4,j] = -omega[j; j,4]` | `H A' / (E^A s^(1/6))` |
| `omega[k; 0,k] = -omega[k; k,0]` | `-E^A H c^2 / s^(13/6)` |
| `omega[k; 4,k] = -omega[k; k,4]` | `E^A H A' / s^(1/6)` |

Assertions [A]:

- `CANONICAL [has content]: omega[mu,a,b] == -omega[mu,b,a]  (metric compatibility)`
- `INDEPENDENT CHECK: the frame-only derivation reproduces omegaCanonical exactly`
- `[has content] the spinor connection is compatible with omega: [Gamma^spin_mu, gamma^a] + omega_mu^a_b gamma^b == 0`
- `Gamma^spin[mu] is block diagonal: it never mixes type-1 with type-2`
- `[has content] and therefore the curved Dirac matrices are covariantly constant: D_mu gammaCurved^nu == 0`

From Part V (the fable-5.1 bridge), three results are used below [A]:

- `FABLE-5.1 [THE RESULT]: gamma^mu Gamma^spin[mu] == -(1/2) T[mu] gamma^mu, one vector term`,
  with the Weitzenböck torsion vector `T_mu = d_mu Log[Sin[6 H x0]]`, i.e.
  `FABLE-5.1 torsion vector has exactly one non-zero component, 6 H Cot[6 H x0] along x0`. Hence
  `gamma^mu Gamma^spin_mu = −3 H Cot[6 H x0]^2 T16[0]`.
- `FABLE-5.1 [THE RESULT]: DiracCanonical[ Sqrt[Sin[6Hx0]] Psi' ] == Sqrt[Sin[6Hx0]] DiracFable51[Psi'], for a generic Psi'`
- `FABLE-5.1 [THE RESULT]: Psi^T sigma16 gamma^mu Gamma^spin[mu] Psi == 0 for EVERY Psi -- the spin connection drops out of the Lagrangian`,
  because `FABLE-5.1: the reason is Section 11's identity, Psi^T sigma16 T16[a] Psi == 0 (sigma16 T16[a] antisymmetric)`.
  Note that this reason is a statement about **commuting** components.

The Ricci scalar of the canonical metric is [D, Section 16]
`R = -3 H^2 ((55 + 7 Cos[12 H x0]) Cot[6 H x0]^2 Csc[6 H x0]^2 - 2 a4'[H x4]^2)`.

### 2.12 The classical field fable of 2026-09-16 (Part VI, Section 24)

Part VI (Sections 23–25) places two matter fields on the pre-universe. It asks of each the
cosmologist's question: what are the energy density `rho`, the pressure `P`, and `w = P/rho`?
The first field, `fableScalar`, is a real scalar with potential `V(phi)`. The second, **fable**,
is the subject of this document.

**fableScalar**, in brief. It has `Lhat_phi = −(1/2) g^{mu nu} d_mu phi d_nu phi − V(phi)` and the
Hilbert tensor `T_{mu nu} = d_mu phi d_nu phi + g_{mu nu} Lhat_phi`. Its central theorem is [A]
`FABLESCALAR [THE RESULT]: the null energy condition rho + P_1 == 2 KE holds IDENTICALLY, for every phi(x0, x4, x5) and every V`,
so it cannot cross `w = −1` with positive energy density.

#### 2.12.1 The field and its Lagrangian

fable is a **real, commuting** 16-component spinor `Psi(x)` that transforms under Spin(4,4)
exactly as `Psi16`. It uses `T16[a]`, `sigma16`, the curved `gamma^mu`, the scalar bilinear
`s = Psi^T sigma16 Psi`, and a general potential `V(s)`:

```
L_Psi = Sqrt[det g] Lhat_Psi,        Lhat_Psi = (1/H) Psi^T sigma16 gamma^mu D_mu Psi - V(s),        D_mu = d_mu + Gamma^spin_mu
s = Psi^T sigma16 Psi
```

In Part VI's generic computations `Psi = Psi(x0, x4)` has sixteen arbitrary component functions.
Assertions [A]:

- `FABLE [definition]: s = Psi^T sigma16 Psi is a genuine scalar with content: on the constant spinor e1 + e5, s == -2`
- `FABLE [has content]: Lhat with the covariant derivative == Lhat with the partial derivative, for the generic Psi(x0, x4) (Part V's theorem, re-asserted here)`

**The fidelity anchor.** The author's Lagrangian is the special case `V(s) = −(2M/H) s`, taken on
the flat frame (`frame -> ID8`) and with no volume factor (`Sqrt[g] -> 1`). With that potential
`−V = +(2M/H) s`, which is exactly `La`'s mass term. [A]:

- `FABLE [fidelity]: with V = -(2M/H) s, frame -> ID8 and Sqrt[g] -> 1, on the model's Psi16, the Lagrangian helper IS the author's La[] of Section 11`
- `FABLE [fidelity]: and its Euler-Lagrange equations, formed with the author's own eL operator, ARE the sixteen equations eLa of Section 12`
- `FABLE [solver regression]: the new helper cfEulerLagrange reproduces eLa too`
- `FABLE-5.1: the covariant Lagrangian with frame -> ID8 and volume factor -> 1 IS the author's La of Section 11, term for term`

#### 2.12.2 The field equation

The equation is obtained by explicit variation of `Sqrt[g] Lhat_Psi`. The kinetic matrix is
`A^mu = sigma16 gamma^mu`, which is antisymmetric; the mass matrix `sigma16` is symmetric. [A]:

- `FABLE [THE RESULT]: the Euler-Lagrange equations by explicit variation == Sqrt[g] [ (2/H)(A^mu d_mu Psi + (1/2) D Psi) - 2 V'(s) sigma16 Psi ]`,
  where `D = (1/Sqrt[g]) d_mu(Sqrt[g] A^mu)`
- `FABLE [has content]: A^mu = sigma16 gamma^mu is antisymmetric and sigma16 is symmetric -- the structure that makes the variation close`
- `FABLE [has content]: in general (1/Sqrt[g]) d_mu(Sqrt[g] gamma^mu) == [gamma^mu, Gamma^spin_mu]  (covariant constancy of gamma^mu, Section 17)`
- `FABLE [has content]: the HYPOTHESIS that makes it a product -- the anticommutator {gamma^mu, Gamma^spin_mu} == 0 on the canonical frame (no totally antisymmetric part of the connection)`
- `FABLE [has content]: hence (1/2)(1/Sqrt[g]) d_mu(Sqrt[g] gamma^mu) == gamma^mu Gamma^spin_mu, and on this geometry == -3 H Cot[6 H x0]^2 T16[0]`
- `FABLE [THE RESULT]: EL == Sqrt[g] (2/H) sigma16 . ( gamma^mu D_mu Psi - H V'(s) Psi ): the field equation of fable is EXACTLY the Levi-Civita covariant Dirac equation  gamma^mu D_mu Psi == H V'(s) Psi`
- `FABLE [has content]: the connection term does not vanish on an x0-independent spinor -- witnessed on the constant spinor e1: a spinor homogeneous in everything but x4 is NOT a solution`

So the field equation of the classical fable is

```
gamma^mu D_mu Psi = H V'(s) Psi,     i.e. on the canonical frame
Cot[6Hx0] T16[0] d_0 Psi + (1/q) T16[i] d_i Psi + T16[4] d_4 Psi + (1/p) T16[h] d_h Psi - 3 H Cot[6Hx0]^2 T16[0] Psi = H V'(s) Psi
```

(summed over `i = 1,2,3` and `h = 5,6,7`; for `Psi(x0, x4)` only the `d_0` and `d_4` terms
survive).

**The rescaling.** [A]:

- `FABLE [definition]: under Psi = Sqrt[Sin[6 H x0]] Psi', s == Sin[6 H x0] Psi'^T sigma16 Psi'`
- `FABLE [THE RESULT]: (gamma^mu D_mu - H V'(s)) [Sqrt[Sin[6 H x0]] Psi'] == Sqrt[Sin[6 H x0]] (gamma^mu d_mu Psi' - H V'(s) Psi') for a GENERIC Psi'(x0, x4): the rescaling removes the connection term exactly`
- `FABLE [has content]: for Psi' = Psi'(x4) the field equation reduces to Sqrt[Sin[6 H x0]] (gamma^4 d_4 Psi' - H V'(s) Psi'), s = Sin[6 H x0] Psi'^T sigma16 Psi'`
- `FABLE [has content]: the reduced equation still depends on x0 through V'(Sin[6 H x0] s'): for a NONLINEAR V a Psi'(x4) alone is not a solution -- witnessed with V = s^2 on Psi' = e1 + e5`
- `FABLE [has content]: for the mass term V = -(2M/H) s, V' is constant and Psi'(x4) IS an exact solution`

#### 2.12.3 The energy–momentum tensor

The tensor is built with the covariant derivative and symmetrized:

```
T_cov_{mu nu} = -(1/(2H)) ( Psi^T sigma16 gamma_mu D_nu Psi + Psi^T sigma16 gamma_nu D_mu Psi ) + g_{mu nu} Lhat_Psi,      gamma_mu = g_{mu nu} gamma^nu
```

Assertions [A]:

- `FABLE [definition]: T_cov is symmetric by construction`
- `FABLE [has content]: the diagonal of T_cov equals the diagonal of the partial-derivative tensor, for the generic Psi(x0, x4): rho and every pressure are the same in both`
- `FABLE [has content]: but the two tensors DIFFER off the diagonal -- witnessed on the (x3, x4) component T[[4,5]], a momentum density along the observed sheet, for the constant spinor e1 + e13 and V = s^2`
- `FABLE [THE RESULT]: nabla^mu T_{mu nu} == 0 ON SHELL in all eight components, for a generic Psi(x0, x4) -- the covariant tensor is the conserved one`

"On shell" means the following. The field equation is solved for
`d_4 Psi = F = −gamma^4 (H V'(s) Psi − gamma^0 d_0 Psi − (1/2) divG Psi)`, where
`divG = (1/Sqrt[g]) d_mu(Sqrt[g] gamma^mu)` (on this geometry `(1/2) divG = −3 H Cot[6 H x0]^2 T16[0]`,
by the assertion quoted above), and `cfOnShell`
replaces every `x4`-derivative of the field by the corresponding derivative of `F`, repeatedly,
until none is left. [A] `FABLE [definition]: F solves the field equation for d_4 Psi: gamma^4 F + gamma^0 d_0 Psi + (1/2) divG Psi - H V'(s) Psi == 0`;
`FABLE [definition]: cfOnShell leaves no x4-derivative of the field in rho`. The partial-derivative
tensor was checked symbolically while Part VI was designed: its `x0` and `x4` components are
conserved and the other six are not. That check takes minutes and is not repeated in the
notebook [P].

#### 2.12.4 `rho`, `P`, and `w` on shell

The observer is `u = d/dx4`, so `rho = T_44` (`T[[5,5]]`) and `P_i = T^i_i` (no sum, `i = 1,2,3`).
Two kinetic bilinears organize the answer:

```
K_Psi = (1/H) Psi^T sigma16 gamma^4 d_4 Psi          along the observer's time
K_h   = -(1/H) Psi^T sigma16 gamma^0 d_0 Psi         along the hidden coordinate x0
```

Assertions [A]:

- `FABLE [THE RESULT]: on shell, Lhat == s V'(s) - V(s)`
- `FABLE [THE RESULT]: on shell, rho == V(s) + K_h,   K_h = -(1/H) Psi^T sigma16 gamma^0 d_0 Psi`
- `FABLE [THE RESULT]: on shell, P_1 == s V'(s) - V(s),  and P_2 == P_3 == P_1`
- `FABLE [has content]: on shell, K_Psi == s V'(s) + K_h -- the x4 kinetic bilinear is fixed by the potential and the hidden one`
- `FABLE [has content]: K_h == 0 for Psi = Sqrt[Sin[6 H x0]] Psi'(x4)  (d_0 Psi is proportional to Psi, and Psi^T sigma16 gamma^0 Psi == 0)`
- `FABLE [THE RESULT]: so for those solutions rho == V(s), hence w == s V'(s)/V(s) - 1, and rho > 0 requires V(s) > 0`

In summary:

```
rho = V(s) + K_h,      P = s V'(s) - V(s),      and for Psi = Sqrt[Sin[6Hx0]] Psi'(x4):   rho = V(s),   w = s V'(s)/V(s) - 1
```

#### 2.12.5 No dilution on the pre-universe

Assertions [A]:

- `FABLE [THE RESULT]: on shell, ds/dx4 == 2 Psi^T sigma16 gamma^4 gamma^0 d_0 Psi for a generic Psi(x0, x4)`
- `FABLE [has content]: the two other terms of d_4 Psi drop out because sigma16 gamma^4 and sigma16 gamma^4 gamma^0 are ANTISYMMETRIC`
- `FABLE [control]: that bilinear is NOT identically zero for an x0-dependent Psi -- witnessed on Psi = e1 + x0 e2: 'ds/dx4 == 0 for generic Psi(x0, x4)' would be FALSE`
- `FABLE [THE RESULT]: for Psi = Sqrt[Sin[6 H x0]] Psi'(x4) it vanishes: s is CONSTANT IN x4 -- no dilution on the pre-universe`
- `FABLE [THE RESULT]: the same from the reduced equation: ds'/dx4 == 0 on shell for Psi'(x4), because Psi'^T sigma16 gamma^4 Psi' == 0`

So on those solutions `s`, `V`, `rho` and `w` are all constant along `x4`. This is the spinor
analogue of the scalar's "no Hubble friction" (for the scalar, [A]
`FABLESCALAR [THE RESULT]: for phi = phi(x4) the field equation is phi'' == -V'(phi): NO HUBBLE FRICTION on the pre-universe`).
For the scalar, Section 23's prose gives the reason as geometric: the factor
`Sqrt[g] g^44 = −Sec[6 H x0]` does not depend on `x4`, because the 8-volume element is
`x4`-independent [P].

#### 2.12.6 Dust for the author's mass term

[A]:

- `FABLE [THE RESULT]: the author's mass term V = -(2M/H) s is DUST: on shell P_1 == 0 identically and rho == -(2M/H) s  (w == 0, exactly)`
- `FABLE [has content]: that density is not zero -- witnessed on Psi' = e1 + e5 at M = 1 (rho = (2M/H) * 2 Sin[6 H x0] there)`

The density `rho = −(2M/H) s` is positive only on the branch `M s < 0` [P, Section 24].

#### 2.12.7 `w = s V'/V − 1` for the six potentials, and the classical phantom crossing

| name | `V(s)` | `w_Psi(s) = s V'(s)/V(s) − 1` |
|---|---|---|
| mass | `m s` | `0` |
| lambda-mass | `V0 + m s` | `−V0/(V0 + m s)` |
| power | `m s + lam s^n` | `(m s + n lam s^n)/(m s + lam s^n) − 1` |
| hilltop | `V0 − mu (s − s*)^2` | `−2 mu s (s − s*)/(V0 − mu (s − s*)^2) − 1` |
| lorentz | `V0 + m s/(1 + (s/s1)^2)` | `m s (1 − (s/s1)^2)/((1 + (s/s1)^2)^2 (V0 + m s/(1 + (s/s1)^2))) − 1` |
| expdamp | `V0 + m s Exp[−s/s1]` | `m s Exp[−s/s1] (1 − s/s1)/(V0 + m s Exp[−s/s1]) − 1` |

Assertions [A]:

- `FABLE [has content]: the closed forms of w_Psi(s) = s V'(s)/V(s) - 1 for the six potentials of the numerical work (mass, lambda-mass, power, hilltop, lorentz, expdamp)`
- `FABLE [THE RESULT]: mass -> w == 0 (dust);  V = lam s^n alone -> w == n - 1 (accelerating for n < 2/3, phantom for n < 0);  n = 0.236 -> w == -0.764 exactly`
- `FABLE [THE RESULT]: w + 1 == s V'/V vanishes where V' does, with V > 0 there: lorentz and expdamp cross w = -1 at s = s1, hilltop at s = s* -- the phantom divide is crossed with no wrong-sign kinetic term`
- `FABLE [has content]: lorentz and expdamp are bounded below by V0 > 0 for s >= 0 (rho > 0 on the whole history), and w < -1 for s > s1 (the past), w > -1 for 0 < s < s1 (the present)`
- `FABLE [has content]: the limits -- lorentz and expdamp: w -> -1 both as s -> infinity and as s -> 0;  lambda-mass: w -> 0 (dust) as s -> infinity and -> -1 (Lambda) as s -> 0`
- `FABLE [has content]: expdamp with (V0, m, s1) = (1.566, 0.839, 2.21) at s = 1 (today) gives w == -0.8608, Unite's w0 = -0.861 to three decimals`

The assumptions for the sign statements are `V0 > 0, m > 0, s1 > 0`. This is the **classical
phantom crossing**: `w + 1 = s V'/V` changes sign where `V'` does, with `V > 0` there, and no
kinetic term has the wrong sign. It is the spinor-quintom mechanism of Cai and Wang, Class.
Quantum Grav. 25 (2008) 165014. The stability of perturbations is not examined in Part VI [P].
The `V0` terms of lambda-mass, lorentz and expdamp are a bare cosmological constant and are
reported as such [D, the summary table printed in Section 25].

#### 2.12.8 The FLRW reference model (Model B)

Because `ds/dx4 = 0` on the pre-universe, a history `w(a)` needs a different background. Part VI
builds it as a **separate** frame, `frameFLRW = diag(1, aF[x4], aF[x4], aF[x4], 1, 1, 1, 1)`, with
its own scale factor `aF`, and feeds it to the same spin-connection solver. The canonical frame
and `a4` are not touched. Assertions [A]:

- `FLRW [definition]: the reference frame does not mention a4, and the canonical frame is untouched`
- `FLRW [solver regression]: vielbein postulate residual is zero`
- `FLRW [has content]: omega is antisymmetric (metric compatible)`
- `FLRW [THE RESULT]: gamma^mu Gamma^spin_mu == (3/2) (a'/a) gamma^4 -- the Hubble term of the FLRW Dirac equation`
- `FLRW [definition]: the rule solves gamma^mu D_mu Psi == H V'(s) Psi for d_4 Psi`
- `FLRW [THE RESULT]: d(a^3 s)/dx4 == 0 on shell, for EVERY V: s = s0 a^-3, the dust dilution law, and w_Psi(a) = s V'(s)/V(s) - 1 on it`
- `FLRW [control]: without the Hubble term, d(a^3 s)/dx4 == 3 (a'/a) a^3 s instead (i.e. ds/dx4 == 0, the pre-universe law): the dilution IS the Hubble term`

**Model B, solved independently with `NDSolve`.** The units are `8 pi G = 1`, `H0 = 1` and
`rho_crit = 3`. The independent variable is `N = ln a`, and `s = Exp[−3N]` is exact, so only the
cosmic time needs integrating:

```
dt/dN = 1/H,      H^2 = Om Exp[-3N] + Or Exp[-4N] + V(s)/3,      Om = 3/10,  Or = 84/10^6
V = expdamp with (V0, m, s1) = (1566/1000, 839/1000, 221/100),   N from -7 to 0,   701 rows,   t(N0) = 1/(2 H(N0)) added
```

All inputs are exact rationals, and `WorkingPrecision -> 24`. Assertions [A]:

- `MODEL B [definition]: 701 rows from N = -7 to 0, s(0) == 1 and rho_Psi(0) == V(1) == 1.566 + 0.839 Exp[-1/2.21]`
- `MODEL B [THE RESULT]: w <= -1 at every grid point with s > s1 and w > -1 at every grid point with s < s1: the crossing is at s = s1, a = s1^(-1/3) = 0.7677`
- `MODEL B [has content]: a genuine phantom phase: min w = -1.302 (to 0.001) at a = 0.543, and w(a = 1) = -0.8608`
- `MODEL B [has content]: V(s) > 0 at every row -- rho_Psi > 0 on the whole history`
- `MODEL B [fidelity]: the reference CSV has the expected header and the same 701 values of N`
- `MODEL B [fidelity]: w agrees with fable-cosmology/reference/mathematica_spinor_expdamp.csv at EVERY row to 1e-9`
- `MODEL B [fidelity]: so do t, H and rho_Psi, to 1e-9 (s differs only by the file's 16-digit rounding of numbers of order 1e9)`

The run prints [D]:

```
Model B (expdamp):  w(a=1) = -0.86084564037764806560795392619028548152`20.   min w = -1.30209881490918676547015655743122703056`20. at N = -0.61 (a = 0.54335086907449978711266408781657974806`20.)   t(a=1) = 0.96433642136311524576147498023448633382`20.   H(a=1) = 0.99998205003431888956547950340514648567`20.
```

Model B applies no normalization: `V(1) = 1.566 + 0.839 Exp[-1/2.21] ≈ 2.0996 = 3 Omega_Psi0`
with `Omega_Psi0 = 0.6999` [P, Section 24]. That is why the printed `H(a=1)` is 0.99998 and not
exactly 1: `H(a=1)^2 = 3/10 + 84/10^6 + V(1)/3 ≈ 0.99996` (this arithmetic was added for this
document; it is not a notebook statement).

#### 2.12.9 What is proved on the pre-universe, and what belongs to the reference model

Proved on the 8-manifold, for arbitrary `a4`, with every identity closed symbolically:

- the Lagrangian and its fidelity to `La` and `eLa`;
- the covariant Dirac equation and its rescaling;
- the covariant energy–momentum tensor and its conservation;
- `rho = V + K_h` and `P = s V' − V`;
- dust for the author's mass term;
- the constancy of `s` in `x4`;
- the volume factorization.

The history `s = s0 a^-3`, the phantom crossing at `a = 0.768`, and all contact with the Unite
fits `(w0, wa) = (−0.861, −0.60)` belong to 4-dimensional physics on the separate FLRW frame
[P, Section 25].

The volume bookkeeping is proved [A]:

- `VOLUME [has content]: the reduced density rho_4 = Vhid rho_8 is NOT separately conserved:  d rho_4/dx4 + 3 H_obs (rho_4 + P_4) == 3 H_obs P_4, for every w`
- `VOLUME [has content]: equivalently d rho_4/dx4 == -3 H_obs rho_4: rho_4 falls as a^-3 for EVERY w -- a volume effect, the same for a cosmological constant as for dust`

Which of `rho_4` and `rho_8` gravitates is left undetermined in Part VI, because Part VI has no
gravitational sector: no Einstein equations, and `a4` free [P, Section 25].

### 2.13 Why the classical fable must be refined

The fable of Part VI is a field of **real, commuting** numbers. A fermion needs **anticommuting**
(Grassmann) components, and the change is not cosmetic. It rests on two algebraic facts about
the author's Clifford algebra.

**F1, the symmetry of `C Gamma`.** Write `Gamma_(r)` for an antisymmetrized product of `r` of the
`T16[a]`. With `C− = sigma16`:

- `sigma16` is symmetric;
- `sigma16 T16[a]` is **antisymmetric** (this much is already Part I's
  `sigma16 . T16[A] is antisymmetric for A = 0..7`);
- `sigma16 Gamma_ab` is antisymmetric;
- `sigma16 Gamma_abc` and `sigma16 Gamma_abcd` are symmetric;
- `sigma16 T16[8]` is symmetric;
- `sigma16 T16[a] sigma16^-1 = −T16[a]^T`.

The second conjugation is `C+ = sigma16 T16[8]`:

- it is symmetric, and `C+ T16[a]` is **symmetric**;
- `C+ Gamma_ab` and `C+ Gamma_abc` are antisymmetric;
- `C+ T16[a] C+^-1 = +T16[a]^T`.

The Spin(4,4)-invariant bilinear forms on the 16-spinor form a two-dimensional space, spanned
by `sigma16` and `sigma16 T16[8]` (`C+ T16[8] = sigma16`). Both are symmetric, and both are
chirality-diagonal. [VII] `REFINEMENT [definition]: T16[8]^2 == sigma16^2 == C+^2 == ID16, C+ is symmetric, and C+ . T16[8] == sigma16 -- the four candidate mass matrices are only two`,
`REFINEMENT [has content]: C- T16[a] C-^-1 == -T16[a]^T and C+ T16[a] C+^-1 == +T16[a]^T for a = 0..7`, `REFINEMENT [THE RESULT]: the symmetry of C Gamma depends only on the rank r of Gamma:  C-: S A A S S A A S S,  C+: S S A A S S A A S  (r = 0..8)`,
`REFINEMENT [THE RESULT]: the Spin(4,4)-invariant bilinear forms on the 16-spinor form a 2-dimensional space, spanned by C- = sigma16 and C+ = sigma16 T16[8]`, `REFINEMENT [has content]: every invariant form is SYMMETRIC and chirality-diagonal, and the two chiral pieces PL sigma16 PL and PR sigma16 PR are invariant separately`.

**F2, what anticommuting components do to a bilinear.** For Grassmann `theta`:

- `theta^T N theta` sees only the **antisymmetric** part of `N`;
- `theta^T N d theta = (1/2) d(theta^T N theta) + theta^T N_sym d theta`.

For commuting components the roles are exactly reversed: `theta^T N theta` sees only the
symmetric part, and the Euler–Lagrange expression of `theta^T N phi` is `2 N_antisym phi`. That
reversal is why Part VI's real commuting fable has both a mass term (`sigma16` symmetric) and a
kinetic term (`sigma16 T16[a]` antisymmetric). [VII]
`GRASSMANN [THE RESULT]: theta^T N theta == theta^T N_A theta and theta^T N_S theta == 0 for a general 16x16 N -- an anticommuting bilinear sees only the ANTISYMMETRIC part`, `GRASSMANN [THE RESULT]: theta^T N phi - (1/2) d(theta^T N theta) == theta^T N_S phi for a general N`,
`GRASSMANN [THE RESULT]: the Euler-Lagrange expression of L = theta^T N phi (left derivatives) is (N + N^T) phi: EMPTY field equations exactly when N is antisymmetric`, `GRASSMANN [control]: for COMMUTING components the roles are reversed -- theta^T N theta sees only N_S, and the Euler-Lagrange expression of theta^T N phi is 2 N_A phi`.

The consequences:

- **(a) A real Grassmann 16-spinor with the author's `sigma16` has no dynamics.** Its mass term
  `theta^T sigma16 theta` vanishes identically, because `sigma16` is symmetric. Its kinetic term
  `theta^T sigma16 T16[a] d theta` is a total derivative, because `sigma16 T16[a]` is
  antisymmetric. So its Euler–Lagrange expression is identically empty, even though the kinetic
  term itself is not zero. The statement holds on **every** frame. `sigma16 Gamma_abc` is
  symmetric, so the connection term `theta^T sigma16 {gamma^mu, Gamma^spin_mu} theta` vanishes
  too. [VII] `REFINEMENT (a) [THE RESULT]: real Grassmann + sigma16: both invariant mass terms vanish, and theta^T sigma16 T16[a] phi == (1/2) d(theta^T sigma16 T16[a] theta) for every a (a total derivative)`, `REFINEMENT (a) [has content]: its Euler-Lagrange expression is identically empty in every direction -- while the kinetic term itself is NOT zero`,
  `REFINEMENT (a) [THE RESULT]: FRAME-INDEPENDENT -- sigma16 {T16[a], S^bc} is SYMMETRIC for all a, b, c (so theta^T sigma16 {gamma^mu, Gamma_mu} theta == 0 on every frame), and d_mu(Sqrt[g] sigma16 gamma^mu) == Sqrt[g] sigma16 [gamma^mu, Gamma_mu] on the canonical frame`.
- **(b) A Majorana 16-spinor built with `C+` propagates but is massless.** Its kinetic term is
  genuine, but every invariant bilinear vanishes on it, so there is no `s` and `V(s)` is
  undefined. It has exactly one quartic Lorentz scalar: the quartic scalars `v.v`, `B.B` and
  `C.C` built from it are all proportional to one quartic. Its commuting shadow has no kinetic
  term at all. [VII] `REFINEMENT (b) [THE RESULT]: Majorana with C+: the kinetic term is genuine -- Euler-Lagrange expression 2 C+ T16[a] phi with C+ T16[a] invertible -- but every invariant bilinear vanishes (massless, no V(s))`,
  `REFINEMENT (b) [has content]: the scope -- the quartic Lorentz scalars v.v, B.B, C.C of the Majorana spinor are NOT zero and are all proportional to ONE quartic (same monomials, one constant ratio each)`, `REFINEMENT (b) [has content]: and the commuting shadow of the C+ Majorana spinor has NO kinetic term: for commuting components theta^T C+ T16[a] phi is the total derivative (1/2) d(theta^T C+ T16[a] theta)`.
- **(c) Weyl and Majorana–Weyl 8-spinors (one chirality) cannot propagate.** Both `C`s are
  chirality-diagonal and `gamma^mu` is chirality-odd, so `PL C T16[a] PL = PR C T16[a] PR = 0`.
  [VII] `REFINEMENT (c) [THE RESULT]: Weyl and Majorana-Weyl: PL C T16[a] PL == PR C T16[a] PR == 0 for C = C-, C+ and every a (C chirality-diagonal, T16[a] chirality-odd) -- no kinetic term`.
- **(d) Fermion fable is the complex 16-component spinor.** It is
  `Psi = (theta1 + i theta2)/Sqrt[2]`, built from two real Grassmann 16-spinors, with the
  conjugate `Psibar = Psi^ddag sigma16`. Here `^ddag` is the conjugation of the complex Grassmann
  algebra; the Hilbert-space adjoint is fixed in the quantization, section 6.
  - It has two scalar bilinears. `s = Psibar Psi = i theta1^T sigma16 theta2` is non-zero and
    Hermitian under `^ddag`, and so is `p = Psibar T16[8] Psi`. (With the Hilbert-space adjoint
    that the quantization fixes, `p` is odd under the fundamental symmetry `J` and becomes an
    anti-Hermitian operator, while `s` stays Hermitian.)
  - The symmetrized kinetic term is Hermitian and genuine.
  - It reduces **exactly** to Part VI's real commuting fable: its Lagrangian, its field equation,
    and its covariant energy–momentum tensor. Through that reduction it reduces to the author's
    `La` and `eLa`.

  [VII] `REFINEMENT (d) [THE RESULT]: s = Psibar Psi == i theta1^T sigma16 theta2: NON-ZERO (16 monomials) and HERMITIAN; p = Psibar T16[8] Psi is non-zero and Hermitian too`, `REFINEMENT (d) [THE RESULT]: its symmetric part is A_S == (i/2) Omega, Omega = [[0, K], [-K, 0]] real SYMMETRIC and invertible: a genuine kinetic term`, `REFINEMENT (d) [has content]: the symmetrized kinetic term is HERMITIAN and equals Psi^ddag K phi - (1/2) d(Psi^ddag K Psi); the unsymmetrized one is not Hermitian`,
  `FIDELITY [1] [fidelity]: Psi -> psi, Psibar -> psi^T sigma16 turns the symmetrized covariant Lhat into Part VI's cfLhatFable EXACTLY (canonical frame, generic V)`, `FIDELITY [2] [fidelity]: on the flat frame with V = -(2M/H) s and no volume factor, the same limit on Psi16 IS the author's La[] of Section 11`, `FIDELITY [3] [fidelity]: sigma16 . EL_Psibar + EL_Psi in the real limit == Part VI's explicit variation cfELFable, component for component`,
  `FIDELITY [3] [fidelity]: and on the flat frame with V = -(2M/H) s the same combination IS the author's eLa of Section 12`, `FIDELITY [4] [fidelity]: the energy-momentum tensor That in the real limit IS Part VI's covariant tensor cfTCov, all 64 components`.

The claim must be stated with its scope. The complex 16-spinor is the **minimal** field that:

1. uses the author's `sigma16` conjugation;
2. propagates;
3. admits a potential `V(s)`;
4. reduces to Part VI's classical fable as its real commuting shadow.

It is **not** the unique field with dynamics: a Majorana spinor with `C+` also propagates. The
author chose the complex 16-spinor on 2026-09-24.

One more consequence matters for everything that follows. Part VI's mechanism for the spin
connection dropping out of the Lagrangian was `Psi^T sigma16 T16[a] Psi = 0`, which is a
property of commuting components. It does not carry over to complex Grassmann fields. There,
the drop of the connection is a property of the matrix `{gamma^mu, Gamma^spin_mu}` itself, and
it has to be proved again. Whether the classical results of this section, among them `w` and the
phantom crossing, survive quantization is decided in sections 7 and 8. The complete
refinement, with every assertion of Section 26, is section 3.

## 3. The refinement: why fable must be a complex 16-spinor

This is Section 26 of the notebook (manifest `claude-fable/cells_part7.wl`, Input cells 173–179,
38 assertions). It turns the classical, real, commuting fable of section 2.12 into a fermion.

**Two conjugations, two symbols.** `Psi^ddag` is the **classical** conjugate of the field, the
conjugation of the Grassmann algebra, the one that appears in the Lagrangian; the Dirac conjugate
is `Psibar = Psi^ddag sigma16`. After quantization (section 6) the Hilbert-space adjoint is a
**different** operation, `Psi^dagger = Psi^ddag J`. The two are never written with the same symbol
[prose VII, introduction of Part VII].

**Two kinds of algebra, and when each is used** [prose VII]. Statements whose content *is* the
anticommutation of the field (that a mass term or a kinetic term vanishes, is Hermitian, or is a
total derivative) are proved in a genuine Grassmann (exterior) algebra, built and tested in
Section 26 (subsection 3.3). Statements about **bilinear** expressions (Lagrangians,
Euler–Lagrange equations, currents, energy–momentum tensors, conservation laws) are proved with
`Psi` and `Psibar` represented by two **independent** vectors of ordinary functions of the
coordinates, with `Psibar` always written to the **left** of `Psi`. That commuting proxy is exact
for such identities: in every term `Psibar` is the leftmost and `Psi` the rightmost odd factor, so
the left derivative with respect to `Psibar` and the right derivative with respect to `Psi` are the
ordinary derivatives, and no reordering of odd factors ever occurs. Where reality matters
(Hermiticity under `^ddag`), `Psi = u + i v` with real `u, v` and `Psibar = (u − i v)^T sigma16`.

### 3.1 The Clifford symmetry table

A spinor bilinear `psi^T C Gamma psi` is built from a "charge conjugation" matrix `C` and one of
the 256 ordered products `Gamma` of the Dirac matrices (Section 6's basis `base16`, grouped by the
rank `r`, the number of factors). There are two candidates for `C`:

```
C-  =  sigma16                 with  C- T16[a] C-^-1  =  -T16[a]^T      (the author's spinor metric)
C+  =  sigma16 . T16[8]        with  C+ T16[a] C+^-1  =  +T16[a]^T
```

Every product `C Gamma` is either symmetric (S) or antisymmetric (A), and the answer depends only
on the rank:

| rank `r` | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|---|
| number of products, `Binomial[8, r]` | 1 | 8 | 28 | 56 | 70 | 56 | 28 | 8 | 1 |
| `C- Gamma = sigma16 Gamma` | S | A | A | S | S | A | A | S | S |
| `C+ Gamma = sigma16 T16[8] Gamma` | S | S | A | A | S | S | A | A | S |

For each `C`, 136 products are symmetric and 120 antisymmetric, as it must be for 16×16 matrices
(`16·17/2 = 136`, `16·15/2 = 120`). The "four candidate" mass matrices `sigma16`, `C+`,
`sigma16 T16[8]`, `C+ T16[8]` are only two, because `T16[8]^2 = ID16`: `sigma16 T16[8] = C+` and
`C+ T16[8] = sigma16`. Why this table decides everything: for **commuting** components
`psi^T N psi` sees only the symmetric part of `N`; for **anticommuting** (Grassmann) components only
the antisymmetric part.

**[proved VII §26]**

- `REFINEMENT [definition]: T16[8]^2 == sigma16^2 == C+^2 == ID16, C+ is symmetric, and C+ . T16[8] == sigma16 -- the four candidate mass matrices are only two`
- `REFINEMENT [has content]: C- T16[a] C-^-1 == -T16[a]^T and C+ T16[a] C+^-1 == +T16[a]^T for a = 0..7`
- `REFINEMENT [THE RESULT]: the symmetry of C Gamma depends only on the rank r of Gamma:  C-: S A A S S A A S S,  C+: S S A A S S A A S  (r = 0..8)` (the assertion also checks that the counts per rank are `Binomial[8, r]`)
- `REFINEMENT [has content]: for each C, 136 of the 256 products are symmetric and 120 antisymmetric`

### 3.2 The Lorentz-invariant bilinears: exactly two, both symmetric

A bilinear `psi^T N psi` (real field) or `Psi^ddag N Psi` (complex field) is a Spin(4,4) scalar
exactly when `S^T N + N S = 0` for all 28 generators `S = SAB` of Section 5 (the generators are
real, so the condition is the same in both cases). Solving these 7168 linear equations
(`28 × 256`) for the 256 entries of `N` gives a **two**-dimensional space, spanned by `C-` and
`C+`, equivalently by the two chiral pieces `PL sigma16 PL` and `PR sigma16 PR`, one for each
split-octonion spinor type. Every invariant `N` is **symmetric** and chirality-**diagonal** (it
commutes with `T16[8]`). That is the complete list of candidates for a mass term; nothing is left
out [prose VII §26].

**[proved VII §26]**

- `REFINEMENT [THE RESULT]: the Spin(4,4)-invariant bilinear forms on the 16-spinor form a 2-dimensional space, spanned by C- = sigma16 and C+ = sigma16 T16[8]`
- `REFINEMENT [has content]: every invariant form is SYMMETRIC and chirality-diagonal, and the two chiral pieces PL sigma16 PL and PR sigma16 PR are invariant separately`

### 3.3 A Grassmann algebra, built and tested

To prove statements about anticommuting fields the notebook uses an honest exterior algebra, not
a sign convention applied by hand. An element is an `Association` from **monomials** to
coefficients; a monomial is the sorted list of the generator indices it contains, `{}` being the
unit. The product of two monomials is zero if they share a generator; otherwise it is the sorted
union with the sign of the permutation that sorts the concatenation (`Signature`). The operations
are [prose VII §26]:

```
grAdd, grScale, grMul          sums, scalar multiples and products
grSame[x, y]                   equality of two elements (x - y has no monomial left)
grBil[xs, N, ys]               the bilinear  Sum_ab xs_a N_ab ys_b  of two lists of elements
grD[x, dmap]                   the EVEN derivation that maps generator i to generator dmap[i]
                               (with dmap: theta_a -> phi_a it is d/dt, with phi_a = d theta_a/dt)
grDL[x, i]                     the LEFT derivative with respect to generator i
grConj[x]                      the classical conjugation ^ddag: (x y)^ddag = y^ddag x^ddag,
                               generators self-conjugate (real), coefficients complex-conjugated
grEL[L, thIdx, phIdx, dmap]    the Euler-Lagrange expression dL/dtheta_c - d(dL/dphi_c), left derivatives
```

Before any physics the algebra is tested on facts known independently (random elements drawn with
`SeedRandom[20260924]`). **[proved VII §26]**

- `GRASSMANN [solver regression]: generators anticommute and square to zero (all pairs of 1..6)`
- `GRASSMANN [solver regression]: the product is associative, (x y) z == x (y z), on elements of degree 1, 2, 3 (and the products tested are not zero)`
- `GRASSMANN [solver regression]: graded commutativity  x y == (-1)^(|x| |y|) y x  (degrees 1, 2, 3), and x^2 == 0 for x odd`
- `GRASSMANN [solver regression]: the conjugation is an involutive anti-automorphism,  (x y)^ddag == y^ddag x^ddag,  (x^ddag)^ddag == x`
- `GRASSMANN [solver regression]: grD is an even derivation, d(x y) == d(x) y + x d(y);  grDL obeys d_i(x y) == d_i(x) y + (-1)^|x| x d_i(y)`

Then the two lemmas that drive the section are proved for a completely general, symbolic 16×16
matrix `N` (`N_A`, `N_S` its antisymmetric and symmetric parts, `theta` sixteen real Grassmann
generators, `phi = d theta/dt` sixteen more):

```
theta^T N theta  ==  theta^T N_A theta                                  (and theta^T N_S theta == 0)
theta^T N phi - (1/2) d( theta^T N theta )  ==  theta^T N_S phi
Euler-Lagrange expression of  L = theta^T N phi  ==  (N + N^T) phi  =  2 N_S phi
```

So a first-order Grassmann kinetic term is a **total derivative**, with empty field equations,
precisely when its matrix is antisymmetric. For **commuting** variables the roles are exactly
reversed (the control). **[proved VII §26]**

- `GRASSMANN [THE RESULT]: theta^T N theta == theta^T N_A theta and theta^T N_S theta == 0 for a general 16x16 N -- an anticommuting bilinear sees only the ANTISYMMETRIC part`
- `GRASSMANN [THE RESULT]: theta^T N phi - (1/2) d(theta^T N theta) == theta^T N_S phi for a general N`
- `GRASSMANN [THE RESULT]: the Euler-Lagrange expression of L = theta^T N phi (left derivatives) is (N + N^T) phi: EMPTY field equations exactly when N is antisymmetric`
- `GRASSMANN [control]: for COMMUTING components the roles are reversed -- theta^T N theta sees only N_S, and the Euler-Lagrange expression of theta^T N phi is 2 N_A phi`

### 3.4 The real options, and why each fails

With the table and the lemmas the verdicts are immediate, and each is proved in the Grassmann
algebra.

**(a) A real Grassmann 16-spinor with the author's `sigma16` has no dynamics, on any frame.** Its
only invariant mass terms vanish, `theta^T sigma16 theta == theta^T C+ theta == 0` (both matrices
are symmetric). In every direction its flat kinetic term `theta^T sigma16 T16[a] d theta` is the
total derivative `(1/2) d(theta^T sigma16 T16[a] theta)` (`sigma16 T16[a]` is antisymmetric), with
an identically empty Euler–Lagrange expression; the total derivative itself is not zero. On a
curved frame the covariant kinetic term is
`Sqrt[g] theta^T sigma16 gamma^mu D_mu theta = (total derivative) + (1/2) Sqrt[g] theta^T sigma16 {gamma^mu, Gamma_mu} theta`,
because `d_mu(Sqrt[g] sigma16 gamma^mu) = Sqrt[g] sigma16 [gamma^mu, Gamma_mu]`; and the second
term vanishes on **every** frame, because `{T16[a], S^bc}` is a rank-3 product (or zero) and
`sigma16` times a rank-3 product is symmetric. **[proved VII §26]**

- `REFINEMENT (a) [THE RESULT]: real Grassmann + sigma16: both invariant mass terms vanish, and theta^T sigma16 T16[a] phi == (1/2) d(theta^T sigma16 T16[a] theta) for every a (a total derivative)`
- `REFINEMENT (a) [has content]: its Euler-Lagrange expression is identically empty in every direction -- while the kinetic term itself is NOT zero`
- `REFINEMENT (a) [THE RESULT]: FRAME-INDEPENDENT -- sigma16 {T16[a], S^bc} is SYMMETRIC for all a, b, c (so theta^T sigma16 {gamma^mu, Gamma_mu} theta == 0 on every frame), and d_mu(Sqrt[g] sigma16 gamma^mu) == Sqrt[g] sigma16 [gamma^mu, Gamma_mu] on the canonical frame`

**(b) A Majorana 16-spinor built with `C+` propagates, but is massless and has no `V(s)`.** Now
`C+ T16[a]` is symmetric, so the kinetic term is genuine: its Euler–Lagrange expression is
`2 C+ T16[a] phi`, and `C+ T16[a]` is invertible. But both invariant forms are symmetric, so there
is **no** Lorentz-scalar bilinear: no mass, no `s`, no `V(s)`. Its quartic Lorentz scalars are not
zero, and they are all **one** scalar: with the vector `v_a = theta^T sigma16 T16[a] theta`, the
2-form `B_ab = theta^T C+ T16[a] T16[b] theta` and the 3-form
`C_abc = theta^T C+ T16[a] T16[b] T16[c] theta`, the contractions `v.v`, `B.B` and `C.C` are
proportional to each other (same monomials, one constant ratio each). Its commuting shadow has no
kinetic term (`C+ T16[a]` symmetric is a total derivative for commuting components).
**[proved VII §26]**

- `REFINEMENT (b) [THE RESULT]: Majorana with C+: the kinetic term is genuine -- Euler-Lagrange expression 2 C+ T16[a] phi with C+ T16[a] invertible -- but every invariant bilinear vanishes (massless, no V(s))`
- `REFINEMENT (b) [has content]: the scope -- the quartic Lorentz scalars v.v, B.B, C.C of the Majorana spinor are NOT zero and are all proportional to ONE quartic (same monomials, one constant ratio each)`
- `REFINEMENT (b) [has content]: and the commuting shadow of the C+ Majorana spinor has NO kinetic term: for commuting components theta^T C+ T16[a] phi is the total derivative (1/2) d(theta^T C+ T16[a] theta)`

**(c) A Weyl or Majorana–Weyl 8-spinor (one chirality, `PL` or `PR`) cannot propagate.** Both
invariant forms are chirality-**diagonal** and every `T16[a]` is chirality-**off**-diagonal, so
`PL C T16[a] PL == PR C T16[a] PR == 0`: no kinetic term at all. **[proved VII §26]**

- `REFINEMENT (c) [THE RESULT]: Weyl and Majorana-Weyl: PL C T16[a] PL == PR C T16[a] PR == 0 for C = C-, C+ and every a (C chirality-diagonal, T16[a] chirality-odd) -- no kinetic term`

**(d) Why Part VI's real commuting fable escapes (a), and why it cannot be quantized as a fermion.**
For commuting components the symmetric `sigma16` gives a non-zero mass term and the antisymmetric
`sigma16 T16[a]` gives a genuine kinetic term (the control of subsection 3.3). That is why Part VI's
classical theory is consistent, and why it cannot be quantized as a fermion: a commuting spinor
violates the spin–statistics connection [prose VII §26].

### 3.5 The complex 16-spinor

Take two real Grassmann 16-spinors `theta1`, `theta2` (32 real generators) and

```
Psi = (theta1 + i theta2)/Sqrt[2],      Psi^ddag = (theta1 - i theta2)^T/Sqrt[2],      Psibar = Psi^ddag sigma16
```

Now everything the real options lacked is present:

- `s = Psibar Psi == i theta1^T sigma16 theta2` is **non-zero** (16 monomials) and **Hermitian**
  (real under `^ddag`). The second invariant `p = Psibar T16[8] Psi = Psi^ddag C+ Psi` is non-zero and
  Hermitian as well: the complex 16-spinor has **two** scalar bilinears.
- `s` is a sum of 16 **commuting nilpotent** even elements `x_a` (`x_a^2 = 0`), so every polynomial
  `V(s)` is a finite polynomial: `s^17 == 0`.
- The kinetic term is genuine: `Psi^ddag K phi = Theta^T A Phi` with `Theta = (theta1, theta2)`,
  `Phi = d Theta`, `K = sigma16 T16[a]`, and the symmetric part of the 32×32 matrix `A` is
  `A_S = (i/2) [[0, K], [-K, 0]] =: (i/2) Omega`, which is **not** zero. `Omega` is real symmetric
  and invertible (it is the symplectic matrix of section 6.3).
- The symmetrized kinetic term `(1/2)(Psi^ddag K phi − phi^ddag K Psi)` is **Hermitian**, and it
  differs from `Psi^ddag K phi` by the total derivative `−(1/2) d(Psi^ddag K Psi)`; the unsymmetrized
  one is **not** Hermitian.

Invariance of `s` and `p` under Spin(4,4) is the statement `S^T N + N S = 0` of subsection 3.2 (the
Lorentz generators are real). The self-interaction is taken to depend on `s` only; section 6.7
shows why `p` cannot enter. **[proved VII §26]**

- `REFINEMENT (d) [definition]: Psi^ddag == (theta1 - i theta2)^T/Sqrt[2] in the algebra`
- `REFINEMENT (d) [THE RESULT]: s = Psibar Psi == i theta1^T sigma16 theta2: NON-ZERO (16 monomials) and HERMITIAN; p = Psibar T16[8] Psi is non-zero and Hermitian too`
- `REFINEMENT (d) [has content]: s is a sum of 16 commuting nilpotent even elements x_a (x_a x_b == x_b x_a, x_a^2 == 0), so s^17 == 0 and V(s) is a finite polynomial`
- `REFINEMENT (d) [definition]: the 32x32 matrix A read off the algebra reproduces Psi^ddag K phi exactly`
- `REFINEMENT (d) [THE RESULT]: its symmetric part is A_S == (i/2) Omega, Omega = [[0, K], [-K, 0]] real SYMMETRIC and invertible: a genuine kinetic term`
- `REFINEMENT (d) [has content]: the symmetrized kinetic term is HERMITIAN and equals Psi^ddag K phi - (1/2) d(Psi^ddag K Psi); the unsymmetrized one is not Hermitian`
- `REFINEMENT (d) [has content]: the same holds in every direction a = 0..7: the symmetrized Psi^ddag sigma16 T16[a] phi is Hermitian, with symmetric part (i/2)[[0, sigma16 T16[a]], [-sigma16 T16[a], 0]] != 0`

### 3.6 Four four-dimensional Dirac fermions

The observer's Clifford algebra is generated by `T16[1]`, `T16[2]`, `T16[3]` (the observed space)
and `T16[4]` (the observer's time). Its 16 ordered products are linearly independent, so over the
complex numbers it is the full matrix algebra `M4(C)`, the algebra of 4×4 Dirac matrices. Its
**commutant** in `M16(C)`, computed by solving `X T16[i] == T16[i] X` (`i = 1..4`), is again
16-dimensional, generated by the four "hidden" (flavour) gammas

```
h_A  =  Omega4 . T16[A],     A = 0, 5, 6, 7,       Omega4 = T16[1].T16[2].T16[3].T16[4],   Omega4^2 = -ID16,
{h_A, h_B} = -2 eta_AB ID16
```

which commute with `T16[1..4]`: a second Clifford algebra, of the hidden directions. The two
algebras meet only in the multiples of the identity (the rank of their union is
`16 + 16 − 1 = 31`). By the double-commutant theorem

```
C^16  =  C^4 (the observer's Dirac index)  (x)  C^4 (the hidden flavour index)
```

Under the observer's Lorentz group Spin(3,1), generated by `T16[i] T16[j]` with `i, j` in
`{1, 2, 3, 4}`, fermion fable is **four 4-dimensional Dirac fermions**. Per momentum that is
`4 × 2 = 8` particle states (and 8 antiparticle states): the degeneracy `g = 8` of sections 6
and 8. **[proved VII §26]**

- `4D [THE RESULT]: the 16 ordered products of T16[1..4] are linearly independent (the observer's algebra is M4(C)), and its commutant in M16(C) is 16-dimensional`
- `4D [has content]: Omega4^2 == -ID16, the hidden gammas h_A = Omega4 T16[A] (A = 0,5,6,7) commute with T16[1..4] and obey {h_A, h_B} == -2 eta_AB`
- `4D [THE RESULT]: the 16 products of the hidden gammas span the commutant, and the two algebras meet only in the multiples of ID16 (rank of the union 16 + 16 - 1 = 31): C^16 = C^4 (x) C^4, four 4D Dirac fermions`
- `4D [has content]: the observer's Lorentz generators T16[i] T16[j] (i < j in 1..4) commute with every hidden gamma`

### 3.7 The refined Lagrangian, and the fidelity chain to Part VI, `La` and `eLa`

The Lagrangian of fermion fable is the **symmetrized covariant** one (section 4 shows why no other
form is admissible for a complex field):

```
L  =  Sqrt[det g] Lhat,      Lhat  =  (1/(2H)) [ Psibar gamma^mu D_mu Psi - (D_mu Psibar) gamma^mu Psi ]  -  V(s),      s = Psibar Psi
D_mu Psi = d_mu Psi + Gamma^spin_mu Psi,       D_mu Psibar = d_mu Psibar - Psibar Gamma^spin_mu
```

and its energy–momentum tensor (section 7) is

```
That_{mu nu}  =  -(1/(4H)) [ Psibar gamma_mu D_nu Psi - (D_nu Psibar) gamma_mu Psi + (mu <-> nu) ]  +  g_{mu nu} Lhat
```

Four helpers implement them for an arbitrary frame (curved gammas and spin connection passed in):
`cfLhatFermion`, `cfEquationFermion` (`gamma^mu D_mu Psi − H V'(s) Psi`), `cfAdjointEquationFermion`
(`(D_mu Psibar) gamma^mu + H V'(s) Psibar`) and `cfTFermion`. Before they are used for anything
new they are anchored to what the notebook already knows. Set `Psi -> psi` (a real commuting
spinor) and `Psibar -> psi^T sigma16` (the "bosonic shadow"). Then:

1. `Lhat` becomes Part VI's `cfLhatFable` **exactly**, on the canonical frame, with generic `V`;
2. on the flat frame with `V = −(2M/H) s` and no volume factor, it becomes the author's `La[]` of
   Section 11 (section 2.7);
3. the Euler–Lagrange expressions of the complex field, combined as
   `sigma16 . EL_Psibar + EL_Psi` (the chain rule for `Psibar = psi^T sigma16`), become Part VI's
   explicit variation `cfELFable`, and on the flat frame the author's sixteen equations `eLa` of
   Section 12 (section 2.8);
4. `That` becomes Part VI's covariant tensor `cfTCov` (section 2.12.3), all 64 components.

**[proved VII §26]**

- `FIDELITY [1] [fidelity]: Psi -> psi, Psibar -> psi^T sigma16 turns the symmetrized covariant Lhat into Part VI's cfLhatFable EXACTLY (canonical frame, generic V)`
- `FIDELITY [2] [fidelity]: on the flat frame with V = -(2M/H) s and no volume factor, the same limit on Psi16 IS the author's La[] of Section 11`
- `FIDELITY [3] [fidelity]: sigma16 . EL_Psibar + EL_Psi in the real limit == Part VI's explicit variation cfELFable, component for component`
- `FIDELITY [3] [fidelity]: and on the flat frame with V = -(2M/H) s the same combination IS the author's eLa of Section 12`
- `FIDELITY [4] [fidelity]: the energy-momentum tensor That in the real limit IS Part VI's covariant tensor cfTCov, all 64 components`

Every new result of this effort therefore contains Part VI, and through it the author's `La` and
`eLa`, as its real commuting limit.

### 3.8 The conclusion, with its scope

The complex 16-spinor is the **minimal** field that

1. uses the author's `sigma16` conjugation,
2. propagates,
3. admits a potential `V(s)` with `s = Psibar Psi`, and
4. reduces to Part VI's classical fable as its real commuting shadow.

It is **not** the unique field with dynamics: the `C+` Majorana spinor propagates too, but it is
massless, has no bilinear `V(s)`, and has no commuting shadow with a kinetic term. The statement
of minimality is the conclusion of Section 26 as a whole; no single assertion states it. It rests
on the assertions of subsections 3.1–3.7 [prose VII §26, assembled from the assertions quoted].

## 4. The Lagrangian and its Hermiticity

This is the first cell of Section 27 (Input cell 180, 10 assertions). From here on `Psi` and
`Psibar` are two independent 16-component fields of **all eight** coordinates (the commuting proxy
of section 3, `Psibar` always on the left).

### 4.1 The four candidates

Four candidate Lagrangians differ by where the derivative acts and whether it is covariant:

```
Lsym    =  (1/(2H)) [ Psibar gamma^mu D_mu Psi - (D_mu Psibar) gamma^mu Psi ] - V(s)     (the Lagrangian of fermion fable)
Lsym_d  =  the same with d_mu in place of D_mu
Lun     =  (1/H) Psibar gamma^mu D_mu Psi - V(s)
Lun_d   =  (1/H) Psibar gamma^mu d_mu Psi - V(s)
```

with `D_mu Psi = d_mu Psi + Gamma_mu Psi`, `D_mu Psibar = d_mu Psibar − Psibar Gamma_mu`, and
`Gamma_mu = GammaSpinCanonical[[mu+1]]`, the canonical spin connection of section 9. The action is
`S = Int d^8x Sqrt[det g] Lsym`, with `Sqrt[det g] = Sec[6 H x0]` on the canonical frame. There is
**no factor `i`** in front of the kinetic term, as in the author's `La`: section 4.2(b) shows that
none is needed.

### 4.2 The facts, each asserted on the canonical frame for generic `Psi(x0..x7)`, `Psibar(x0..x7)`

**(a) The connection is real and `sigma16 Gamma_mu` is antisymmetric**, i.e.
`Gamma_mu^T sigma16 = −sigma16 Gamma_mu`. So `D_mu Psibar = d_mu Psibar − Psibar Gamma_mu` is exactly
the Dirac conjugate of `D_mu Psi`. **[proved VII §27]** `LAGRANGIAN (a) [definition]: every Gamma^spin_mu is real and sigma16 Gamma_mu is antisymmetric (Gamma_mu^T sigma16 == -sigma16 Gamma_mu): D_mu Psibar is the Dirac conjugate of D_mu Psi`

**(b) `Lsym` is Hermitian; `Lun` is not.** With `Psi = u + i v` and `Psibar = (u − i v)^T sigma16`,
`Lsym` is real. No factor `i` is needed, because `sigma16 gamma^mu` is real and antisymmetric:
`(Psi^ddag K d Psi)^ddag = −(d Psi^ddag) K Psi` for real antisymmetric `K`, so the symmetrized
combination is real. `Lun` is not Hermitian: its imaginary part is not zero (a witness).
**[proved VII §27]**

- `LAGRANGIAN (b) [THE RESULT]: Lsym is HERMITIAN -- real for Psi = u + i v, Psibar = (u - i v)^T sigma16, generic u, v of all eight coordinates`
- `LAGRANGIAN (b) [control]: Lun is NOT Hermitian -- its imaginary part is not zero, witnessed on the constant spinors u = e1, v = e13 (with V = s^2)`

**(c) `Lsym` contains the connection only through `{gamma^mu, Gamma_mu}`, and that matrix vanishes
for each `mu`.** Expanding `D`,

```
Lsym - Lsym_d  ==  (1/(2H)) Sum_mu Psibar {gamma^mu, Gamma_mu} Psi          (identically, off shell)
```

On the canonical frame `{gamma^mu, Gamma_mu} == 0` for **each** `mu` separately: every `Gamma_mu` is
a combination of `T16[mu] T16[0]` and `T16[mu] T16[4]`, with no totally antisymmetric part
(section 9.8). So `Lsym == Lsym_d` there: the connection drops out of the symmetrized Lagrangian on
every frame on which the **matrix** `{gamma^mu, Gamma_mu}` vanishes (diagonal frames), and **not**
in general. **[proved VII §27]** `LAGRANGIAN (c) [THE RESULT]: Lsym - Lsym_d == (1/(2H)) Sum_mu Psibar {gamma^mu, Gamma_mu} Psi identically, and {gamma^mu, Gamma_mu} == 0 for EACH mu on the canonical frame: Lsym == Lsym_d`

**(d) `Lun` and `Lsym` differ by a total divergence.** **[proved VII §27]**
`LAGRANGIAN (d) [has content]: Lun - Lsym == (1/(2H)) (1/Sqrt[g]) d_mu( Sqrt[g] Psibar gamma^mu Psi ), a total divergence`

**(e) But `Lun` and `Lun_d` differ by a term that is not zero for a complex field.**

```
Lun - Lun_d  ==  (1/H) Psibar gamma^mu Gamma_mu Psi  ==  -3 Cot[6 H x0]^2 Psibar T16[0] Psi
```

This vanishes only in the real commuting limit, which is the scope of the statement "`Lhat` with
`D` == `Lhat` with `d`" of Parts V and VI (section 2.12.1). **[proved VII §27]**

- `LAGRANGIAN (e) [has content]: Lun - Lun_d == (1/H) Psibar gamma^mu Gamma_mu Psi == -3 Cot[6 H x0]^2 Psibar T16[0] Psi`
- `LAGRANGIAN (e) [control]: that term is NOT zero for a complex field (witness u = e1, v = e13), and IS zero in the real commuting limit (the scope of Parts V-VI)`

**(f) So `Lun_d` is inadmissible.** Varying `Psibar` gives `gamma^mu d_mu Psi == H V' Psi` with the
connection term **missing**. Varying `Psi` gives an adjoint equation that **contains** it,
`(d_mu Psibar) gamma^mu + Psibar [gamma^mu, Gamma_mu] == −H V' Psibar`. The two are **not** Dirac
conjugates of each other: they differ by `Psibar [gamma^mu, Gamma_mu] = 2 Psibar gamma^mu Gamma_mu = −6 H Cot[6 H x0]^2 Psibar T16[0]`
(a witness). Only a Lagrangian whose two variations are conjugate defines a consistent theory.
**[proved VII §27]**

- `LAGRANGIAN (f) [THE RESULT]: Lun_d varied with respect to Psibar gives (Sqrt[g]/H)(gamma^mu d_mu Psi - H V' Psi): the connection term is MISSING`
- `LAGRANGIAN (f) [THE RESULT]: varied with respect to Psi it gives -(Sqrt[g]/H)((d_mu Psibar) gamma^mu + Psibar [gamma^mu, Gamma_mu] + H V' Psibar), with Psibar [gamma^mu, Gamma_mu] == 2 Psibar gamma^mu Gamma_mu: the connection term is PRESENT`
- `LAGRANGIAN (f) [control]: so Lun_d is INADMISSIBLE -- its two field equations are not Dirac conjugates: they differ by 2 Psibar gamma^mu Gamma_mu = -6 H Cot^2 Psibar T16[0], non-zero (witness u = e1, v = 0, V = s^2)`

### 4.3 Why the connection drops out, and why this is not Part VI's mechanism

For the real commuting field of Part VI the connection dropped out because
`Psi^T sigma16 T16[a] Psi = 0` for commuting components (`sigma16 T16[a]` antisymmetric; section
2.11). For a complex field that bilinear identity is false:
`Psibar T16[0] Psi = Psi^ddag (sigma16 T16[0]) Psi` with `sigma16 T16[0]` real antisymmetric is `i`
times the Hermitian form of `−i sigma16 T16[0]`, which is not zero in general [derived here]. The
drop-out of the connection from `Lsym` is therefore a property of the **matrix**
`{gamma^mu, Gamma_mu}` (fact (c)), not of a bilinear identity. The general identity behind it is
`Sum_mu {gamma^mu, Gamma_mu} = (1/2) omega_[cab] gamma^{cab}`: only the totally antisymmetric part of
the connection can enter the symmetrized Lagrangian (section 9.8).

Hermiticity rests on two facts: `sigma16 gamma^a` and `sigma16 Gamma_mu` are **real antisymmetric**.
The first is Part I's `sigma16 . T16[A] is antisymmetric for A = 0..7`; the second is fact (a).

## 5. The field equations in the primordial gravitational field, written out

This is Section 27 of the notebook (Input cells 181, 182 and 184) and item (2) of the pre-universe
cell of Section 29 (Input cell 197). The **primordial gravitational field** is the author's
canonical frame of section 2.11:

```
frameCanonical = DiagonalMatrix[{ Tan[6 H x0],  q, q, q,  1,  p, p, p }]
q = Exp[-a4[H x4]] / Sin[6 H x0]^(1/6),        p = Exp[+a4[H x4]] / Sin[6 H x0]^(1/6)       (a4 free, never given a value)
ds^2 = Tan[6 H x0]^2 dx0^2 + q^2 (dx1^2 + dx2^2 + dx3^2) - dx4^2 - p^2 (dx5^2 + dx6^2 + dx7^2),     Sqrt[|det g|] = Sec[6 H x0]
gamma^0 = Cot[6 H x0] T16[0],   gamma^i = (1/q) T16[i]  (i = 1,2,3),   gamma^4 = T16[4],   gamma^h = (1/p) T16[h]  (h = 5,6,7)
```

on `0 < 6 H x0 < Pi/2`. The spin connection enters through `gamma^mu Gamma_mu = −3 H Cot[6 H x0]^2 T16[0]`
(section 9.8).

### 5.1 The derivation

Vary `Psibar` and `Psi` independently in `L = Sqrt[g] Lsym` (the left derivative with respect to
`Psibar` and the right derivative with respect to `Psi` are the ordinary derivatives of the
commuting proxy). For generic fields of all eight coordinates:

```
EL_Psibar  ==  (Sqrt[g]/H) ( gamma^mu D_mu Psi - H V'(s) Psi )
EL_Psi     ==  -(Sqrt[g]/H) ( (D_mu Psibar) gamma^mu + H V'(s) Psibar )
```

so **the field equation and the adjoint field equation of fermion fable** are

```
gamma^mu D_mu Psi  ==  H V'(s) Psi                  (D_mu Psibar) gamma^mu  ==  -H V'(s) Psibar
```

The **sign** of the adjoint equation is derived, not assumed, and it is exactly the one consistency
requires: with `Psi = u + i v` and `Psibar = (u − i v)^T sigma16`, the adjoint equation is the Dirac
conjugate of the field equation, (adjoint residual) `== −`(field residual)`^* . sigma16`, because
`T16[a]^T sigma16 = −sigma16 T16[a]`. The opposite sign fails that test (control). The derivation
uses only the covariant constancy of `gamma^mu`, in the form
`(1/Sqrt[g]) d_mu(Sqrt[g] gamma^mu) == [gamma^mu, Gamma_mu]` (Section 17); the anticommutator is
not needed for the symmetrized Lagrangian. **[proved VII §27]**

- `FIELD EQUATION [has content]: the identity the derivation uses -- (1/Sqrt[g]) d_mu(Sqrt[g] gamma^mu) == [gamma^mu, Gamma_mu] (covariant constancy, Section 17)`
- `FIELD EQUATION [THE RESULT]: EL_Psibar == (Sqrt[g]/H)(gamma^mu D_mu Psi - H V'(s) Psi) for generic Psi, Psibar of all eight coordinates: the field equation is gamma^mu D_mu Psi == H V'(s) Psi`
- `FIELD EQUATION [THE RESULT]: EL_Psi == -(Sqrt[g]/H)((D_mu Psibar) gamma^mu + H V'(s) Psibar): the adjoint equation is (D_mu Psibar) gamma^mu == -H V'(s) Psibar`
- `FIELD EQUATION [has content]: the adjoint equation IS the Dirac conjugate of the field equation: with Psi = u + i v, Psibar = (u - i v)^T sigma16, adjoint residual == -(field residual)^* . sigma16`
- `FIELD EQUATION [control]: the opposite sign, (D Psibar) gamma == +H V' Psibar, is NOT the conjugate -- witnessed on u = e1 + e5, v = 0 with V = s^2 (s = -2 there)`

### 5.2 The 16×16 matrix form on the canonical frame

For fields of all eight coordinates, with `d_mu = D[ , x_mu]`, sums over `i = 1,2,3` and
`h = 5,6,7`:

```
Cot[6Hx0] T16[0] d_0 Psi + (1/q) Sum_i T16[i] d_i Psi + T16[4] d_4 Psi + (1/p) Sum_h T16[h] d_h Psi - 3 H Cot[6Hx0]^2 T16[0] Psi  ==  H V'(s) Psi

Cot[6Hx0] d_0 Psibar T16[0] + (1/q) Sum_i d_i Psibar T16[i] + d_4 Psibar T16[4] + (1/p) Sum_h d_h Psibar T16[h]
      - 3 H Cot[6Hx0]^2 Psibar T16[0]  ==  -H V'(s) Psibar
```

In the adjoint equation the connection enters as `−Psibar Gamma_mu gamma^mu = +Psibar gamma^mu Gamma_mu`
(per-`mu` anticommutator), so it carries the **same** coefficient `−3 H Cot^2` as in the field
equation. **[proved VII §27]**

- `WRITTEN OUT (i) [THE RESULT]: the field equation on the canonical frame is Cot T16[0] d_0 Psi + (1/q) T16[i] d_i Psi + T16[4] d_4 Psi + (1/p) T16[h] d_h Psi - 3 H Cot^2 T16[0] Psi == H V'(s) Psi`
- `WRITTEN OUT (i) [THE RESULT]: the adjoint equation is Cot d_0 Psibar T16[0] + ... - 3 H Cot^2 Psibar T16[0] == -H V'(s) Psibar (the connection enters with the sign fixed by {gamma^mu, Gamma_mu} = 0)`

### 5.3 The split-octonion 8+8 form

Write `Psi = (psi1, psi2)`: `psi1` = the upper eight components (type-1 split-octonion spinor,
chirality −1), `psi2` = the lower eight (type-2, chirality +1). With
`T16[a] = [[0, taubar[a]], [tau[a], 0]]` and `Gamma^spin_mu = diag(Gamma^(1)_mu, Gamma^(2)_mu)`
(Section 17; the spin connection never mixes the two types), **covariantly, on any frame**:

```
e_a^mu taubar[a] (d_mu + Gamma^(2)_mu) psi2  =  H V'(s) psi1              (rows 1..8)
e_a^mu tau[a]    (d_mu + Gamma^(1)_mu) psi1  =  H V'(s) psi2              (rows 9..16)
s = -psi1^ddag sigma psi1 + psi2^ddag sigma psi2,        psibar1 = -psi1^ddag sigma,   psibar2 = psi2^ddag sigma
(d_mu psibar2 - psibar2 Gamma^(2)_mu) tau[a]    e_a^mu  =  -H V'(s) psibar1
(d_mu psibar1 - psibar1 Gamma^(1)_mu) taubar[a] e_a^mu  =  -H V'(s) psibar2
```

(`Psibar = (psibar1, psibar2) = Psi^ddag sigma16`, `sigma16 = diag(−sigma, sigma)`.) On the
canonical frame (`tau[0] = taubar[0] = ID8`), the connection term is `−3 H Cot^2 psi2` in the upper
rows and `−3 H Cot^2 psi1` in the lower rows:

```
Cot d_0 psi2 + (1/q) Sum_i taubar[i] d_i psi2 + taubar[4] d_4 psi2 + (1/p) Sum_h taubar[h] d_h psi2 - 3 H Cot^2 psi2  ==  H V'(s) psi1
Cot d_0 psi1 + (1/q) Sum_i tau[i]    d_i psi1 + tau[4]    d_4 psi1 + (1/p) Sum_h tau[h]    d_h psi1 - 3 H Cot^2 psi1  ==  H V'(s) psi2
```

**[proved VII §27]**

- `WRITTEN OUT (ii) [THE RESULT]: the split-octonion 8+8 form -- the type-1 rows are the taubar equations for psi2, the type-2 rows the tau equations for psi1 (tau[0] == taubar[0] == ID8)`
- `WRITTEN OUT (ii) [THE RESULT]: the covariant 8+8 form -- rows 1..8 are e_a^mu taubar[a] (d_mu + Gamma^(2)_mu) psi2 - H V' psi1, rows 9..16 are e_a^mu tau[a] (d_mu + Gamma^(1)_mu) psi1 - H V' psi2; and the conjugate rows`
- `WRITTEN OUT (ii) [has content]: with Psibar = Psi^ddag sigma16 and sigma16 = diag(-sigma, sigma): s == -psi1^ddag sigma psi1 + psi2^ddag sigma psi2 (psibar1 = -psi1^ddag sigma, psibar2 = psi2^ddag sigma)`

### 5.4 All sixteen component equations

Each `T16[a]` is a signed permutation matrix, so component equation `r` contains exactly **one**
derivative per coordinate, of the component that `T16[a]` maps to `r`; the connection term
multiplies the same component as the `x0`-derivative; and `−H V'` multiplies `psi_r` itself. For
fields of all eight coordinates the sixteen equations form **one** coupled block. (The four blocks
of four of Section 13, section 2.9, belong to the reduction to fields of `(x0, x4)` only.) The term
lists `cfFieldEqTerms` and `cfAdjEqTerms` from which the equations below are rendered reproduce all
sixteen field equations and all sixteen adjoint equations exactly. **[proved VII §27]**

- `WRITTEN OUT (iii) [definition]: the term lists reproduce all sixteen field equations and all sixteen adjoint equations exactly`
- `WRITTEN OUT (iii) [has content]: every component equation has exactly one derivative per coordinate x0..x7, the connection term multiplies the component carrying the x0-derivative, and -H V' multiplies psi_r itself`
- `WRITTEN OUT (iii) [has content]: for fields of all eight coordinates the sixteen equations form ONE coupled block (the four blocks of four of Section 13 belong to the (x0, x4) reduction)`

**How to read the equations below.** They are the plain-text export written by
`claude-fable/export_fermion_fable_tex.wls` from the notebook's own asserted objects
(`provenance-latex/generated/fermion_fable_field_equations.txt`; the LaTeX twin of this page uses
the `.tex` twin of the same file). They are quoted verbatim.

- `psi_k` (`k = 0..15`) is component `k` of `Psi`; `psibar_k` is component `k` of `Psibar`. The
  index is the notebook's 0-based component index (array position `k + 1`).
- `d_mu psi_k` is `∂psi_k/∂x_mu`, `mu = 0..7`.
- `E^a4[H*x4]` is `e^{a4(H x4)}`, with `a4` the free function. Hence
  `(E^a4[H*x4]*Sin[6*H*x0]^(1/6)) = 1/q` multiplies the observed derivatives `d_1, d_2, d_3`, and
  `(Sin[6*H*x0]^(1/6)/E^a4[H*x4]) = 1/p` multiplies the hidden derivatives `d_5, d_6, d_7`.
- `V'[s]` is `V'(s)` at `s = Psibar Psi`; `H` is the author's Protected constant.
- Equation `E_r` is row `r` of `gamma^mu D_mu Psi − H V'(s) Psi = 0`, with the `V'` term moved to the
  right.

```
fermion fable -- the 16 component field equations on the canonical frame

E_0:  (Cot[6*H*x0]) d_0 psi_8 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi_8 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi_13 - d_4 psi_13 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi_14 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi_14 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi_15 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi_15 - (3*H*Cot[6*H*x0]^2) psi_8  ==  (H*V'[s]) psi_0
E_1:  (Cot[6*H*x0]) d_0 psi_9 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi_9 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi_12 + d_4 psi_12 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi_14 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi_14 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi_15 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi_15 - (3*H*Cot[6*H*x0]^2) psi_9  ==  (H*V'[s]) psi_1
E_2:  (Cot[6*H*x0]) d_0 psi_10 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi_10 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi_12 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi_12 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi_13 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi_13 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi_15 + d_4 psi_15 - (3*H*Cot[6*H*x0]^2) psi_10  ==  (H*V'[s]) psi_2
E_3:  (Cot[6*H*x0]) d_0 psi_11 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi_11 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi_12 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi_12 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi_13 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi_13 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi_14 - d_4 psi_14 - (3*H*Cot[6*H*x0]^2) psi_11  ==  (H*V'[s]) psi_3
E_4:  -(E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi_9 + d_4 psi_9 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi_10 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi_10 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi_11 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi_11 + (Cot[6*H*x0]) d_0 psi_12 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi_12 - (3*H*Cot[6*H*x0]^2) psi_12  ==  (H*V'[s]) psi_4
E_5:  (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi_8 - d_4 psi_8 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi_10 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi_10 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi_11 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi_11 + (Cot[6*H*x0]) d_0 psi_13 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi_13 - (3*H*Cot[6*H*x0]^2) psi_13  ==  (H*V'[s]) psi_5
E_6:  -(E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi_8 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi_8 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi_9 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi_9 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi_11 - d_4 psi_11 + (Cot[6*H*x0]) d_0 psi_14 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi_14 - (3*H*Cot[6*H*x0]^2) psi_14  ==  (H*V'[s]) psi_6
E_7:  (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi_8 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi_8 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi_9 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi_9 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi_10 + d_4 psi_10 + (Cot[6*H*x0]) d_0 psi_15 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi_15 - (3*H*Cot[6*H*x0]^2) psi_15  ==  (H*V'[s]) psi_7
E_8:  (Cot[6*H*x0]) d_0 psi_0 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi_0 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi_5 + d_4 psi_5 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi_6 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi_6 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi_7 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi_7 - (3*H*Cot[6*H*x0]^2) psi_0  ==  (H*V'[s]) psi_8
E_9:  (Cot[6*H*x0]) d_0 psi_1 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi_1 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi_4 - d_4 psi_4 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi_6 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi_6 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi_7 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi_7 - (3*H*Cot[6*H*x0]^2) psi_1  ==  (H*V'[s]) psi_9
E_10:  (Cot[6*H*x0]) d_0 psi_2 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi_2 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi_4 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi_4 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi_5 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi_5 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi_7 - d_4 psi_7 - (3*H*Cot[6*H*x0]^2) psi_2  ==  (H*V'[s]) psi_10
E_11:  (Cot[6*H*x0]) d_0 psi_3 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi_3 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi_4 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi_4 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi_5 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi_5 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi_6 + d_4 psi_6 - (3*H*Cot[6*H*x0]^2) psi_3  ==  (H*V'[s]) psi_11
E_12:  (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi_1 - d_4 psi_1 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi_2 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi_2 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi_3 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi_3 + (Cot[6*H*x0]) d_0 psi_4 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi_4 - (3*H*Cot[6*H*x0]^2) psi_4  ==  (H*V'[s]) psi_12
E_13:  -(E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi_0 + d_4 psi_0 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi_2 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi_2 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi_3 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi_3 + (Cot[6*H*x0]) d_0 psi_5 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi_5 - (3*H*Cot[6*H*x0]^2) psi_5  ==  (H*V'[s]) psi_13
E_14:  (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi_0 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi_0 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi_1 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi_1 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi_3 + d_4 psi_3 + (Cot[6*H*x0]) d_0 psi_6 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi_6 - (3*H*Cot[6*H*x0]^2) psi_6  ==  (H*V'[s]) psi_14
E_15:  -(E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi_0 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi_0 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi_1 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi_1 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi_2 - d_4 psi_2 + (Cot[6*H*x0]) d_0 psi_7 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi_7 - (3*H*Cot[6*H*x0]^2) psi_7  ==  (H*V'[s]) psi_15
```

### 5.5 All sixteen adjoint equations

Equation `Ebar_r` is column `r` of `(D_mu Psibar) gamma^mu + H V'(s) Psibar = 0`, with the `V'` term
moved to the right (`provenance-latex/generated/fermion_fable_adjoint_equations.txt`, verbatim):

```
fermion fable -- the 16 component adjoint equations on the canonical frame

Ebar_0:  (Cot[6*H*x0]) d_0 psibar_8 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psibar_8 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psibar_13 + d_4 psibar_13 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psibar_14 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psibar_14 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psibar_15 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psibar_15 - (3*H*Cot[6*H*x0]^2) psibar_8  ==  -(H*V'[s]) psibar_0
Ebar_1:  (Cot[6*H*x0]) d_0 psibar_9 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psibar_9 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psibar_12 - d_4 psibar_12 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psibar_14 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psibar_14 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psibar_15 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psibar_15 - (3*H*Cot[6*H*x0]^2) psibar_9  ==  -(H*V'[s]) psibar_1
Ebar_2:  (Cot[6*H*x0]) d_0 psibar_10 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psibar_10 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psibar_12 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psibar_12 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psibar_13 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psibar_13 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psibar_15 - d_4 psibar_15 - (3*H*Cot[6*H*x0]^2) psibar_10  ==  -(H*V'[s]) psibar_2
Ebar_3:  (Cot[6*H*x0]) d_0 psibar_11 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psibar_11 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psibar_12 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psibar_12 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psibar_13 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psibar_13 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psibar_14 + d_4 psibar_14 - (3*H*Cot[6*H*x0]^2) psibar_11  ==  -(H*V'[s]) psibar_3
Ebar_4:  -(E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psibar_9 - d_4 psibar_9 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psibar_10 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psibar_10 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psibar_11 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psibar_11 + (Cot[6*H*x0]) d_0 psibar_12 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psibar_12 - (3*H*Cot[6*H*x0]^2) psibar_12  ==  -(H*V'[s]) psibar_4
Ebar_5:  (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psibar_8 + d_4 psibar_8 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psibar_10 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psibar_10 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psibar_11 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psibar_11 + (Cot[6*H*x0]) d_0 psibar_13 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psibar_13 - (3*H*Cot[6*H*x0]^2) psibar_13  ==  -(H*V'[s]) psibar_5
Ebar_6:  -(E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psibar_8 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psibar_8 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psibar_9 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psibar_9 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psibar_11 + d_4 psibar_11 + (Cot[6*H*x0]) d_0 psibar_14 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psibar_14 - (3*H*Cot[6*H*x0]^2) psibar_14  ==  -(H*V'[s]) psibar_6
Ebar_7:  (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psibar_8 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psibar_8 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psibar_9 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psibar_9 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psibar_10 - d_4 psibar_10 + (Cot[6*H*x0]) d_0 psibar_15 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psibar_15 - (3*H*Cot[6*H*x0]^2) psibar_15  ==  -(H*V'[s]) psibar_7
Ebar_8:  (Cot[6*H*x0]) d_0 psibar_0 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psibar_0 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psibar_5 - d_4 psibar_5 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psibar_6 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psibar_6 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psibar_7 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psibar_7 - (3*H*Cot[6*H*x0]^2) psibar_0  ==  -(H*V'[s]) psibar_8
Ebar_9:  (Cot[6*H*x0]) d_0 psibar_1 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psibar_1 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psibar_4 + d_4 psibar_4 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psibar_6 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psibar_6 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psibar_7 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psibar_7 - (3*H*Cot[6*H*x0]^2) psibar_1  ==  -(H*V'[s]) psibar_9
Ebar_10:  (Cot[6*H*x0]) d_0 psibar_2 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psibar_2 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psibar_4 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psibar_4 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psibar_5 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psibar_5 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psibar_7 + d_4 psibar_7 - (3*H*Cot[6*H*x0]^2) psibar_2  ==  -(H*V'[s]) psibar_10
Ebar_11:  (Cot[6*H*x0]) d_0 psibar_3 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psibar_3 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psibar_4 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psibar_4 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psibar_5 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psibar_5 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psibar_6 - d_4 psibar_6 - (3*H*Cot[6*H*x0]^2) psibar_3  ==  -(H*V'[s]) psibar_11
Ebar_12:  (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psibar_1 + d_4 psibar_1 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psibar_2 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psibar_2 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psibar_3 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psibar_3 + (Cot[6*H*x0]) d_0 psibar_4 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psibar_4 - (3*H*Cot[6*H*x0]^2) psibar_4  ==  -(H*V'[s]) psibar_12
Ebar_13:  -(E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psibar_0 - d_4 psibar_0 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psibar_2 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psibar_2 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psibar_3 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psibar_3 + (Cot[6*H*x0]) d_0 psibar_5 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psibar_5 - (3*H*Cot[6*H*x0]^2) psibar_5  ==  -(H*V'[s]) psibar_13
Ebar_14:  (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psibar_0 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psibar_0 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psibar_1 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psibar_1 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psibar_3 - d_4 psibar_3 + (Cot[6*H*x0]) d_0 psibar_6 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psibar_6 - (3*H*Cot[6*H*x0]^2) psibar_6  ==  -(H*V'[s]) psibar_14
Ebar_15:  -(E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psibar_0 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psibar_0 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psibar_1 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psibar_1 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psibar_2 + d_4 psibar_2 + (Cot[6*H*x0]) d_0 psibar_7 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psibar_7 - (3*H*Cot[6*H*x0]^2) psibar_7  ==  -(H*V'[s]) psibar_15
```

For every `r`, `E_r` and `Ebar_r` contain the same eight (derivative direction, component index)
pairs, `d_mu psi_k` against `d_mu psibar_k`, with the same coefficients. The terms with derivatives
along the spacelike directions `x0..x3` have the **same** sign in both; those along the timelike
directions `x4..x7` have the **opposite** sign; the connection term `−3 H Cot^2` multiplies the same
component with the same sign; and the `V'` term changes sign. This is what the transposition
requires: `T16[a]` is a real signed permutation matrix with `T16[a]^2 = eta_aa`, so
`T16[a]^T = eta_aa T16[a]` [derived here; the rule was checked for this page on all 128 derivative
terms and 16 connection terms of the two exported files by a short script; it is not a notebook
assertion]. The adjoint equations are the Dirac conjugates of the field equations
(`FIELD EQUATION [has content]: the adjoint equation IS the Dirac conjugate of the field equation: with Psi = u + i v, Psibar = (u - i v)^T sigma16, adjoint residual == -(field residual)^* . sigma16`, section 5.1).

### 5.6 The 8+8 form, component by component

Rows 0–7 are the `taubar` equations for `psi2`, rows 8–15 the `tau` equations for `psi1`;
`psi1_k = psi_k` and `psi2_k = psi_{k+8}` (`k = 0..7`)
(`provenance-latex/generated/fermion_fable_field_equations_8plus8.txt`, verbatim):

```
fermion fable -- the split-octonion 8+8 form

Cot[6 H x0] d_0 psi2 + (1/q) Sum_i taubar_i d_i psi2 + taubar_4 d_4 psi2 + (1/p) Sum_h taubar_h d_h psi2 - 3 H Cot[6 H x0]^2 psi2 == H V'[s] psi1
Cot[6 H x0] d_0 psi1 + (1/q) Sum_i tau_i d_i psi1 + tau_4 d_4 psi1 + (1/p) Sum_h tau_h d_h psi1 - 3 H Cot[6 H x0]^2 psi1 == H V'[s] psi2
s == -psi1^ddag sigma psi1 + psi2^ddag sigma psi2
q = 1/(E^a4[H*x4]*Sin[6*H*x0]^(1/6)),  p = E^a4[H*x4]/Sin[6*H*x0]^(1/6)

components:
E_0:  (Cot[6*H*x0]) d_0 psi2_0 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi2_0 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi2_5 - d_4 psi2_5 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi2_6 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi2_6 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi2_7 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi2_7 - (3*H*Cot[6*H*x0]^2) psi2_0  ==  (H*V'[s]) psi1_0
E_1:  (Cot[6*H*x0]) d_0 psi2_1 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi2_1 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi2_4 + d_4 psi2_4 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi2_6 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi2_6 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi2_7 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi2_7 - (3*H*Cot[6*H*x0]^2) psi2_1  ==  (H*V'[s]) psi1_1
E_2:  (Cot[6*H*x0]) d_0 psi2_2 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi2_2 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi2_4 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi2_4 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi2_5 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi2_5 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi2_7 + d_4 psi2_7 - (3*H*Cot[6*H*x0]^2) psi2_2  ==  (H*V'[s]) psi1_2
E_3:  (Cot[6*H*x0]) d_0 psi2_3 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi2_3 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi2_4 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi2_4 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi2_5 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi2_5 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi2_6 - d_4 psi2_6 - (3*H*Cot[6*H*x0]^2) psi2_3  ==  (H*V'[s]) psi1_3
E_4:  -(E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi2_1 + d_4 psi2_1 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi2_2 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi2_2 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi2_3 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi2_3 + (Cot[6*H*x0]) d_0 psi2_4 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi2_4 - (3*H*Cot[6*H*x0]^2) psi2_4  ==  (H*V'[s]) psi1_4
E_5:  (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi2_0 - d_4 psi2_0 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi2_2 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi2_2 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi2_3 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi2_3 + (Cot[6*H*x0]) d_0 psi2_5 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi2_5 - (3*H*Cot[6*H*x0]^2) psi2_5  ==  (H*V'[s]) psi1_5
E_6:  -(E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi2_0 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi2_0 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi2_1 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi2_1 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi2_3 - d_4 psi2_3 + (Cot[6*H*x0]) d_0 psi2_6 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi2_6 - (3*H*Cot[6*H*x0]^2) psi2_6  ==  (H*V'[s]) psi1_6
E_7:  (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi2_0 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi2_0 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi2_1 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi2_1 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi2_2 + d_4 psi2_2 + (Cot[6*H*x0]) d_0 psi2_7 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi2_7 - (3*H*Cot[6*H*x0]^2) psi2_7  ==  (H*V'[s]) psi1_7
E_8:  (Cot[6*H*x0]) d_0 psi1_0 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi1_0 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi1_5 + d_4 psi1_5 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi1_6 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi1_6 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi1_7 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi1_7 - (3*H*Cot[6*H*x0]^2) psi1_0  ==  (H*V'[s]) psi2_0
E_9:  (Cot[6*H*x0]) d_0 psi1_1 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi1_1 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi1_4 - d_4 psi1_4 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi1_6 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi1_6 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi1_7 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi1_7 - (3*H*Cot[6*H*x0]^2) psi1_1  ==  (H*V'[s]) psi2_1
E_10:  (Cot[6*H*x0]) d_0 psi1_2 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi1_2 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi1_4 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi1_4 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi1_5 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi1_5 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi1_7 - d_4 psi1_7 - (3*H*Cot[6*H*x0]^2) psi1_2  ==  (H*V'[s]) psi2_2
E_11:  (Cot[6*H*x0]) d_0 psi1_3 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi1_3 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi1_4 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi1_4 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi1_5 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi1_5 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi1_6 + d_4 psi1_6 - (3*H*Cot[6*H*x0]^2) psi1_3  ==  (H*V'[s]) psi2_3
E_12:  (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi1_1 - d_4 psi1_1 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi1_2 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi1_2 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi1_3 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi1_3 + (Cot[6*H*x0]) d_0 psi1_4 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi1_4 - (3*H*Cot[6*H*x0]^2) psi1_4  ==  (H*V'[s]) psi2_4
E_13:  -(E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi1_0 + d_4 psi1_0 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi1_2 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi1_2 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi1_3 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi1_3 + (Cot[6*H*x0]) d_0 psi1_5 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi1_5 - (3*H*Cot[6*H*x0]^2) psi1_5  ==  (H*V'[s]) psi2_5
E_14:  (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi1_0 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi1_0 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi1_1 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi1_1 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi1_3 + d_4 psi1_3 + (Cot[6*H*x0]) d_0 psi1_6 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi1_6 - (3*H*Cot[6*H*x0]^2) psi1_6  ==  (H*V'[s]) psi2_6
E_15:  -(E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi1_0 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi1_0 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi1_1 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi1_1 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi1_2 - d_4 psi1_2 + (Cot[6*H*x0]) d_0 psi1_7 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi1_7 - (3*H*Cot[6*H*x0]^2) psi1_7  ==  (H*V'[s]) psi2_7
```

### 5.7 The rescaled form: the spin connection disappears

Put `Psi = Sqrt[Sin[6 H x0]] Psi'` and `Psibar = Sqrt[Sin[6 H x0]] Psi'bar`. Then `s = Sin[6 H x0] s'`
with `s' = Psi'bar Psi'`, and

```
gamma^mu D_mu Psi - H V'(s) Psi  ==  Sqrt[Sin[6Hx0]] ( Cot T16[0] d_0 Psi' + (1/q) Sum_i T16[i] d_i Psi' + T16[4] d_4 Psi'
                                                       + (1/p) Sum_h T16[h] d_h Psi' - H V'(Sin[6Hx0] s') Psi' )
```

with **no connection term at all**, and the same for the adjoint equation. This works because the
connection term is a gradient: `gamma^mu Gamma_mu = −(1/2) T_mu gamma^mu` with the Weitzenböck
torsion vector `T_mu = d_mu Log[Sin[6 H x0]]` (section 9.10), and multiplying by
`Exp[(1/2) Log[Sin]] = Sqrt[Sin]` removes it. **[proved VII §27]**

- `WRITTEN OUT (iv) [THE RESULT]: Psi = Sqrt[Sin[6Hx0]] Psi' turns the field equation into Sqrt[Sin] (Cot T16[0] d_0 Psi' + (1/q) T16[i] d_i Psi' + T16[4] d_4 Psi' + (1/p) T16[h] d_h Psi' - H V'(Sin s') Psi'): NO connection term`
- `WRITTEN OUT (iv) [THE RESULT]: and the adjoint equation into Sqrt[Sin] (Cot d_0 Psi'bar T16[0] + ... + H V'(Sin s') Psi'bar), with no connection term either`
- `WRITTEN OUT (iv) [definition]: under the rescaling s == Sin[6 H x0] s',  s' = Psi'bar Psi'`

The sixteen rescaled equations (`psi'_k` = component `k` of `Psi'`; `V'` evaluated at
`s = Sin[6 H x0] Psi'bar Psi'`; `provenance-latex/generated/fermion_fable_field_equations_rescaled.txt`,
verbatim):

```
fermion fable -- the rescaled field equations, Psi = Sqrt[Sin[6 H x0]] Psi', V' evaluated at s = Sin[6 H x0] Psi'bar Psi'

E'_0:  (Cot[6*H*x0]) d_0 psi'_8 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi'_8 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi'_13 - d_4 psi'_13 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi'_14 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi'_14 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi'_15 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi'_15  ==  (H*V'[s]) psi'_0
E'_1:  (Cot[6*H*x0]) d_0 psi'_9 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi'_9 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi'_12 + d_4 psi'_12 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi'_14 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi'_14 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi'_15 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi'_15  ==  (H*V'[s]) psi'_1
E'_2:  (Cot[6*H*x0]) d_0 psi'_10 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi'_10 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi'_12 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi'_12 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi'_13 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi'_13 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi'_15 + d_4 psi'_15  ==  (H*V'[s]) psi'_2
E'_3:  (Cot[6*H*x0]) d_0 psi'_11 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi'_11 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi'_12 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi'_12 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi'_13 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi'_13 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi'_14 - d_4 psi'_14  ==  (H*V'[s]) psi'_3
E'_4:  -(E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi'_9 + d_4 psi'_9 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi'_10 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi'_10 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi'_11 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi'_11 + (Cot[6*H*x0]) d_0 psi'_12 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi'_12  ==  (H*V'[s]) psi'_4
E'_5:  (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi'_8 - d_4 psi'_8 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi'_10 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi'_10 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi'_11 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi'_11 + (Cot[6*H*x0]) d_0 psi'_13 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi'_13  ==  (H*V'[s]) psi'_5
E'_6:  -(E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi'_8 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi'_8 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi'_9 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi'_9 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi'_11 - d_4 psi'_11 + (Cot[6*H*x0]) d_0 psi'_14 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi'_14  ==  (H*V'[s]) psi'_6
E'_7:  (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi'_8 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi'_8 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi'_9 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi'_9 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi'_10 + d_4 psi'_10 + (Cot[6*H*x0]) d_0 psi'_15 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi'_15  ==  (H*V'[s]) psi'_7
E'_8:  (Cot[6*H*x0]) d_0 psi'_0 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi'_0 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi'_5 + d_4 psi'_5 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi'_6 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi'_6 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi'_7 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi'_7  ==  (H*V'[s]) psi'_8
E'_9:  (Cot[6*H*x0]) d_0 psi'_1 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi'_1 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi'_4 - d_4 psi'_4 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi'_6 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi'_6 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi'_7 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi'_7  ==  (H*V'[s]) psi'_9
E'_10:  (Cot[6*H*x0]) d_0 psi'_2 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi'_2 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi'_4 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi'_4 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi'_5 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi'_5 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi'_7 - d_4 psi'_7  ==  (H*V'[s]) psi'_10
E'_11:  (Cot[6*H*x0]) d_0 psi'_3 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi'_3 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi'_4 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi'_4 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi'_5 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi'_5 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi'_6 + d_4 psi'_6  ==  (H*V'[s]) psi'_11
E'_12:  (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi'_1 - d_4 psi'_1 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi'_2 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi'_2 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi'_3 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi'_3 + (Cot[6*H*x0]) d_0 psi'_4 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi'_4  ==  (H*V'[s]) psi'_12
E'_13:  -(E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi'_0 + d_4 psi'_0 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi'_2 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi'_2 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi'_3 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi'_3 + (Cot[6*H*x0]) d_0 psi'_5 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi'_5  ==  (H*V'[s]) psi'_13
E'_14:  (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi'_0 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi'_0 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi'_1 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi'_1 + (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi'_3 + d_4 psi'_3 + (Cot[6*H*x0]) d_0 psi'_6 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi'_6  ==  (H*V'[s]) psi'_14
E'_15:  -(E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_1 psi'_0 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_6 psi'_0 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_2 psi'_1 - (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_5 psi'_1 - (E^a4[H*x4]*Sin[6*H*x0]^(1/6)) d_3 psi'_2 - d_4 psi'_2 + (Cot[6*H*x0]) d_0 psi'_7 + (Sin[6*H*x0]^(1/6)/E^a4[H*x4]) d_7 psi'_7  ==  (H*V'[s]) psi'_15
```

### 5.8 The `x4`-only family and the condition `V'' s' = 0`

The rescaled field with no `x0`-dependence, `Psi = Sqrt[Sin[6 H x0]] Psi'(x4)`, satisfies the field
equation at every `x0` **if and only if** `d_x0 V'(Sin[6Hx0] s') == 0`, and
`d_x0 V'(Sin s') = 6 H Cos[6 H x0] s' V''(Sin s')`. So it is a solution exactly when `V'' s' = 0`:

- either `V` is **linear** (the author's mass term `V = −(2M/H) s`, `V' = −2M/H` constant), or
- the data are **null**, `s' = Psi'bar Psi' = 0`.

For the complex field `s'` is **conserved** by the `x4`-only equations
`d_4 Psi' = −H V' T16[4] Psi'`, `d_4 Psi'bar = H V' Psi'bar T16[4]`, for **any** `V`. So null data give
`x4`-only solutions for any `V`, with `rho = V(0)`. For a nonlinear `V` and `s' != 0` the family
fails (witness: `V = s^2`). **[proved VII §29]**

- `PRE-UNIVERSE (2) [THE RESULT]: Psi = Sqrt[Sin] Psi'(x4) satisfies the field equation iff d_x0 V'(Sin[6Hx0] s') == 0, and d_x0 V'(Sin s') == 6 H Cos[6 H x0] s' V''(Sin s'): V linear OR s' == 0`
- `PRE-UNIVERSE (2) [has content]: s' = Psi'bar Psi' is conserved by the x4-only equations (d_4 Psi' = -H V' T16[4] Psi', d_4 Psi'bar = H V' Psi'bar T16[4]) for ANY V; so null data s' = 0 are solutions for any V, with rho == V(0); and for V = s^2 with s' != 0 the x0-dependence is real (witness)`

### 5.9 The operator form of the field equation, and its ordering

These are definitions, not identities [prose VII §27]. The Hamiltonian (section 6.11) contains
`V(:s:)`, defined by the spectral calculus of the Hermitian operator `s(x) = Psi^dagger beta Psi` of
section 6.5 (regularized and normal-ordered). No ordering prescription is needed there, and a
non-polynomial `V` is covered. The operator field equation is

```
gamma^mu D_mu Psi  =  H :V'(s) Psi:
```

where `V'(s) Psi` is the **Weyl-symmetrized** product, the average over the positions at which `Psi`
can be inserted in `V'(s)`.

- It is **exact** for linear `V` (the author's mass term).
- For nonlinear `V` it differs from the naive product by Hartree and Fock contractions with the
  coincident `J`-vacuum propagator. That propagator is a c-number **matrix** with two parts: a
  **scalar** part, which is divergent and renormalizes `V'`; and a **`gamma^4`** part, the charge
  density of the Dirac sea, which is a constant chemical-potential shift. The `gamma^4` part is
  removed by charge-symmetric ordering or by a phase `Psi -> e^{i mu x4} Psi`, **not** by
  renormalizing `V`.
- In the Kohn–Sham mean field of section 8, `V'(s)` is replaced by `V'(<s>)` and the equation is
  linear.

### 5.10 The U(1) current and the particle-number current

`Lsym` is invariant under `Psi -> e^{i alpha} Psi`, `Psibar -> e^{−i alpha} Psibar`. The Noether
current is

```
J^mu  =  dL/d(d_mu Psi) (i Psi) + (-i Psibar) dL/d(d_mu Psibar)  ==  (Sqrt[g]/H) i Psibar gamma^mu Psi
```

so `j^mu = i Psibar gamma^mu Psi` is the U(1) current. It is real, because `i sigma16 gamma^mu` is
Hermitian. **Off shell**, for generic fields of all eight coordinates,

```
(1/Sqrt[g]) d_mu( Sqrt[g] j^mu )  ==  i ( Ebar Psi + Psibar E )          E, Ebar = the two field-equation residuals
```

so the current is conserved on shell. **[proved VII §27]**

- `CURRENT [THE RESULT]: the Noether current of the U(1) phase is (Sqrt[g]/H) i Psibar gamma^mu Psi`
- `CURRENT [has content]: i sigma16 gamma^mu is Hermitian for every mu, so j^mu is real`
- `CURRENT [THE RESULT]: OFF SHELL (1/Sqrt[g]) d_mu(Sqrt[g] j^mu) == i (Ebar Psi + Psibar E) for generic fields of all eight coordinates -- conserved on shell`

The **particle-number current** is `n^mu := −(i/H) Psibar gamma^mu Psi = −j^mu/H`. As section 6.15
shows, `N = Int Sqrt[g] n^4 d^7x` is the normal-ordered number of particles minus antiparticles, so
the charge of `j` carries a conventional minus sign: `Int Sqrt[g] j^4 d^7x = −H N` [prose VII §27].
So one particle (one occupied positive-frequency `J`-mode, `N = +1`) carries `j`-charge `−H`, and one
antiparticle `+H` [derived here from the two definitions; the design review, QK-10, states the same
sign as "a positive-frequency J-mode carries j-charge −1", that is, in units of `H`].

### 5.11 The only internal symmetry is the vector phase

The commutant of all eight `T16[a]` in `M16(C)` is one-dimensional (multiples of `ID16`), so the
only internal U(1) is the vector phase. In particular the **axial** phase
`Psi -> exp(i alpha T16[8]) Psi` leaves `s = Psibar Psi` invariant but **not** the kinetic term
(`T16[8]` anticommutes with every gamma):
`exp(−i alpha T8) T16[a] exp(i alpha T8) == T16[a] exp(2 i alpha T8)`, so
`Psibar gamma^mu d_mu Psi` changes at first order by `2 i alpha Psibar gamma^mu T16[8] d_mu Psi`,
which is not zero. This is the reverse of the four-dimensional intuition, where the axial phase
preserves the kinetic term and breaks the mass term. **[proved VII §27]**

- `SYMMETRY [THE RESULT]: the only internal U(1) is the vector phase -- the commutant of all eight T16[a] in M16(C) is one-dimensional (multiples of ID16)`
- `SYMMETRY [has content]: the axial phase exp(i alpha T16[8]) leaves s invariant but not the kinetic term: exp(-i alpha T8) T16[a] exp(i alpha T8) == T16[a] exp(2 i alpha T8), so Psibar gamma^mu d_mu Psi changes at first order by 2 i alpha Psibar gamma^mu T16[8] d_mu Psi, which is not zero (witness)`

## 6. Canonical quantization in 4+4 dimensions

This is Section 28 of the notebook (Input cells 185–191, 56 assertions). "Extended to 4+4
dimensions" means: the time is one of the four timelike directions, `x4`, and the slice of constant
time is seven-dimensional and contains the other three timelike directions. Everything below
follows from the symmetrized Lagrangian of section 4; the result is summarized first.

**The result in one paragraph.** The Dirac bracket gives the anticommutator
`{Psi_a(x), Psi^ddag_b(y)} = (H/Sqrt[|g|]) (−i sigma16 gamma^4)_ab delta^7(x − y)`. Its matrix is
`J = −i T16[0].T16[1].T16[2].T16[3].T16[4]`, which is Hermitian with square 1 and has signature
`(8,8)`: the naive Fock space would have negative-norm states. `J` acts only on a hidden flavour
index, `sigma16 = J beta` with `beta = −i T16[4]`, and the Hilbert adjoint `Psi^dagger := Psi^ddag J`
makes the anticommutator positive, `{Psi, Psi^dagger} = (H/Sqrt[|g|]) delta^7`. This works exactly
when the field carries no momentum along the three hidden timelike directions `x5, x6, x7` (the
admissibility theorem), and there `J` is unique. The admissible theory is a dimensional reduction
with a finite hidden coordinate volume `V_hid`. Its Fock space is built on `J`-eigenmodes: per
momentum, 8 positive-frequency and 8 negative-frequency modes; the ground state is the filled Dirac
sea; the first excitations are 8 particles and 8 antiparticles. A finite Jordan–Wigner Fock space
checks all of this exactly.

### 6.1 Time, slices, and why the slice is not a Cauchy surface

Time is `x4`, the observer's proper time. On the canonical frame `g_44 = −1` (lapse 1) and
`g_4mu = 0` for `mu != 4` (shift 0). A slice `x4 = const` is **seven**-dimensional with signature
`(4,3)`: `x0, x1, x2, x3` spacelike and `x5, x6, x7` **timelike**. It is therefore not a Cauchy
surface, and the quantization is carried out where it is well posed (the admissible sector, 6.10).
**[proved VII §28]** `QUANTIZATION [definition]: lapse 1 and shift 0 (g_44 == -1, g_4mu == 0), and the slice x4 = const has signature (4,3) -- x0..x3 spacelike, x5..x7 timelike (given a4 real and 0 < 6 H x0 < Pi/2)`

### 6.2 The momenta, the kinetic form `G`, and the signature `(8,8)`

From `Lsym` the canonical momenta are

```
Pi_Psi     =  dL/d(d_4 Psi)     =  (Sqrt[g]/(2H)) Psibar gamma^4
Pi_Psibar  =  dL/d(d_4 Psibar)  =  -(Sqrt[g]/(2H)) gamma^4 Psi
```

The symplectic potential `Pi_Psi dPsi + dPsibar Pi_Psibar` differs from that of the unsymmetrized
Lagrangian, `(Sqrt[g]/H) Psibar gamma^4 dPsi`, by the exact variation
`delta[(Sqrt[g]/(2H)) Psibar gamma^4 Psi]`: the two define the **same** symplectic form, hence the
same brackets. With `Psibar = Psi^ddag sigma16` the time-derivative part of the Lagrangian is

```
Psi^ddag K d_4 Psi,     K = (Sqrt[g]/H) sigma16 gamma^4 = i Gtilde,     Gtilde = (Sqrt[g]/H) G,     G = -i sigma16 gamma^4
```

On the canonical frame `gamma^4 = T16[4]`, so

```
G = -i sigma16 T16[4] = -i T16[0].T16[1].T16[2].T16[3].T16[4]  =:  J
```

`G` is Hermitian, `G^2 = ID16`, with eigenvalues `+1` (8 times) and `−1` (8 times): the kinetic form
is **indefinite**, signature `(8,8)`. The canonical frame has `Gamma_4 = 0`, so the time-derivative
part, which alone determines the anticommutator, contains no spin connection. **[proved VII §28]**

- `QUANTIZATION [THE RESULT]: the momenta of Lsym are Pi_Psi == (Sqrt[g]/(2H)) Psibar gamma^4 and Pi_Psibar == -(Sqrt[g]/(2H)) gamma^4 Psi`
- `QUANTIZATION [has content]: theta_un - theta_sym == delta[(Sqrt[g]/(2H)) Psibar gamma^4 Psi] exactly: the same symplectic form, the same brackets`
- `QUANTIZATION [THE RESULT]: G = -i sigma16 gamma^4 == J = -i T16[0].T16[1].T16[2].T16[3].T16[4] on the canonical frame; J is Hermitian, J^2 == ID16, eigenvalues +1 (8) and -1 (8): signature (8,8)`
- `QUANTIZATION [has content]: Gamma_4 == 0 -- the time-derivative part of the Lagrangian, which fixes the anticommutator, contains no spin connection`

### 6.3 The Dirac bracket and the canonical anticommutator

Write `Psi = (theta1 + i theta2)/Sqrt[2]` with real Grassmann `theta1, theta2` and
`Theta = (theta1, theta2)`. In the Grassmann algebra of section 3.3, for `K = c sigma16 T16[4]` with
any scalar `c`,

```
Psi^ddag K dPsi  ==  (i/2) Theta^T Omega_c dTheta  +  (1/4) d( theta1^T K theta1 + theta2^T K theta2 ),
Omega_c = [[0, K], [-K, 0]]          (real, symmetric, invertible;  Omega_c^-1 = [[0, -K^-1], [K^-1, 0]])
```

So up to a total time derivative the Lagrangian is the first-order system
`(i/2) Theta^T Omega Theta' − h`. Its momenta are proportional to `Theta`; the constraints
`pi − (momentum as a function of Theta)` are second class with constraint matrix proportional to
`Omega`; and the Dirac bracket of the `Theta`'s is proportional to `Omega^-1`. The constant is fixed
by the elementary case `Omega = 1`, `(i/2) xi xi'`, whose quantization is `{xi, xi} = 1`. Hence

```
{Theta_i, Theta_j}   =  (Omega^-1)_ij
{Psi_a, Psi^ddag_b}  =  (1/2) [ (Omega^-1)_11 + (Omega^-1)_22 - i (Omega^-1)_12 + i (Omega^-1)_21 ]_ab  ==  i (K^-1)_ab  ==  (Gtilde^-1)_ab
{Psi_a, Psi_b}       =  0
```

The same sign and normalization are confirmed independently, with no convention for graded Poisson
brackets, by the Fock space of section 6.14: with this anticommutator the Heisenberg equation
generated by the canonical Hamiltonian reproduces the field equation, and with the opposite sign
it gives the time-reversed one. On the canonical frame `J^-1 = J` and `Sqrt[g] = Sec[6 H x0]`, so

```
{Psi_a(x), Psi^ddag_b(y)}_{x4 = y4}  =  (H/Sqrt[g]) J_ab delta^7(x - y)  =  H Cos[6 H x0] J_ab delta^7(x - y),       {Psi_a, Psi_b} = 0
```

which is `(H/Sqrt[|g|]) (−i sigma16 gamma^4)_ab`, because `(−i sigma16 T16[4])^-1 = −i sigma16 T16[4]`.
The spin connection does not appear: the anticommutator comes from the time-derivative term alone,
and `Gamma_4 = 0`. **[proved VII §28]**

- `DIRAC BRACKET [THE RESULT]: in the Grassmann algebra Psi^ddag K phi == (i/2) Theta^T Omega_c Phi + (1/4) d(theta1^T K theta1 + theta2^T K theta2), for K = c sigma16 T16[4] with a free scalar c`
- `DIRAC BRACKET [has content]: Omega_c is real symmetric and invertible, Omega_c^-1 == [[0, -K^-1], [K^-1, 0]]`
- `DIRAC BRACKET [THE RESULT]: {Theta_i, Theta_j} = (Omega^-1)_ij gives {Psi_a, Psi^ddag_b} == i (K^-1)_ab == (Gtilde^-1)_ab and {Psi_a, Psi_b} == 0`
- `ANTICOMMUTATOR [THE RESULT]: on the canonical frame (c = Sqrt[g]/H) {Psi, Psi^ddag} == (H/Sqrt[g]) J == H Cos[6 H x0] J  (J^-1 == J), which IS the design's (H/Sqrt[g])(-i sigma16 gamma^4)`

The exported anticommutator, with its matrix
(`provenance-latex/generated/fermion_fable_anticommutator.txt`, verbatim; `I` is the imaginary unit):

```
{Psi_a(x), Psi^ddag_b(y)} = (H/Sqrt[g]) J_ab delta^7(x-y) = H*Cos[6*H*x0] J_ab delta^7(x-y);  {Psi_a, Psi_b} = 0;  {Psi_a, Psi^dagger_b} = (H/Sqrt[g]) delta_ab delta^7 with Psi^dagger = Psi^ddag J

matrix (H/Sqrt[g]) J:
0  0  0  0  0  0  0  0  0  I*H*Cos[6*H*x0]  0  0  0  0  0  0
0  0  0  0  0  0  0  0  (-I)*H*Cos[6*H*x0]  0  0  0  0  0  0  0
0  0  0  0  0  0  0  0  0  0  0  (-I)*H*Cos[6*H*x0]  0  0  0  0
0  0  0  0  0  0  0  0  0  0  I*H*Cos[6*H*x0]  0  0  0  0  0
0  0  0  0  0  0  0  0  0  0  0  0  0  (-I)*H*Cos[6*H*x0]  0  0
0  0  0  0  0  0  0  0  0  0  0  0  I*H*Cos[6*H*x0]  0  0  0
0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  I*H*Cos[6*H*x0]
0  0  0  0  0  0  0  0  0  0  0  0  0  0  (-I)*H*Cos[6*H*x0]  0
0  I*H*Cos[6*H*x0]  0  0  0  0  0  0  0  0  0  0  0  0  0  0
(-I)*H*Cos[6*H*x0]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
0  0  0  (-I)*H*Cos[6*H*x0]  0  0  0  0  0  0  0  0  0  0  0  0
0  0  I*H*Cos[6*H*x0]  0  0  0  0  0  0  0  0  0  0  0  0  0
0  0  0  0  0  (-I)*H*Cos[6*H*x0]  0  0  0  0  0  0  0  0  0  0
0  0  0  0  I*H*Cos[6*H*x0]  0  0  0  0  0  0  0  0  0  0  0
0  0  0  0  0  0  0  I*H*Cos[6*H*x0]  0  0  0  0  0  0  0  0
0  0  0  0  0  0  (-I)*H*Cos[6*H*x0]  0  0  0  0  0  0  0  0  0
```

### 6.4 The admissible truncation, `V_hid`, and the rescaled field

The admissible theory (6.10) is a **truncation**: a dimensional reduction to fields
`Psi = Psi(x0, x1, x2, x3, x4)`, independent of `x5, x6, x7`. It needs a **finite** hidden coordinate
volume `V_hid = Int dx5 dx6 dx7`. That is an assumption, and it has a consequence that must be
stated: compact timelike directions contain closed timelike curves. In the truncation the delta
function becomes `delta^4(x0..x3 − y0..y3)` and the factor `H/Sqrt[g]` becomes `H/(V_hid Sqrt[g])`:

```
{Psi_a(x), Psi^ddag_b(y)}_{x4 = y4}  =  ( H / (V_hid Sqrt[|g|]) ) G_ab delta^4(x0..x3 - y0..y3),       G = -i sigma16 gamma^4
```

For the rescaled field `Psi' = Psi/Sqrt[Sin[6 H x0]]` of section 5.7 the factor is
`H Cos[6Hx0]/Sin[6Hx0] = H Cot[6 H x0]`. On a frame whose `Sqrt[g]` depends on `x4` one quantizes
`chi = (Sqrt[g]/H)^(1/2) Psi`, with `{chi, chi^ddag} = G delta^7`; on the canonical frame `Sqrt[g]`
does not depend on `x4` and the two coincide [prose VII §28]. **[proved VII §28]**
`ANTICOMMUTATOR [has content]: the rescaled field Psi' = Psi/Sqrt[Sin[6 H x0]] has {Psi', Psi'^ddag} == H Cot[6 H x0] J delta^7, and Sqrt[g] is x4-independent (so quantizing chi = (Sqrt[g]/H)^(1/2) Psi changes nothing on the canonical frame)`

(For the time-dependent warped frames of the interacting system, Part VIII of the notebook,
Section 32, proves that the rescaled field has an `x4`-independent anticommutator:
`RESCALING [THE RESULT]: {Psi, Psi^ddag} == (H/Sqrt[|det g|]) G on the warped frame (Section 28's cfAntiPsiPsiDd at c = Sqrt[|det g|]/H), and for chi = Psi/f, f = Sqrt[Sin] (A^3 B^3 C)^(-1/2): {chi, chi^ddag} == H Cot[6 H x0] G -- the Sqrt[det g] cancels, independent of x4 and of A, B, C` and `RESCALING [has content]: on the warped frame G = -i sigma16 gamma^4 is Section 28's cfGK (= J) -- the same matrix on every member of the family (gamma^4 == T16[4], lapse 1)`.)

### 6.5 What `J` is, and the Hilbert adjoint

`J = −i T16[0]...T16[4] = −i Omega4 T16[0] = −i h_0`, with `Omega4 = T16[1].T16[2].T16[3].T16[4]` of
section 3.6. So `J` is one of the hidden **flavour** gammas: it lies in the commutant of the
observer's Clifford algebra, and on `C^16 = C^4 (observer) (x) C^4 (flavour)` it acts on the
**flavour factor only**, where it has signature `(2,2)` (verified on the image of a rank-4
primitive idempotent of the observer's algebra). With `beta := −i T16[4]` (Hermitian, `beta^2 = 1`):

```
sigma16  =  J beta,        beta T16[j] beta = -T16[j]  and  T16[j] Hermitian  (j = 0..3)
```

so `beta` is the observer's Dirac-adjoint matrix. Define the **Hilbert adjoint** by the
`J`-involution, `Psi^dagger := Psi^ddag J`. Then

```
Psibar = Psi^ddag sigma16 = Psi^dagger beta          (the standard 4D Dirac adjoint)
s = Psi^dagger beta Psi
Psi^ddag G d_4 Psi = Psi^dagger d_4 Psi              (the time-kinetic term becomes (Sqrt[g]/H) i Psi^dagger d_4 Psi)
{Psi_a, Psi^dagger_b} = (H/Sqrt[g]) delta_ab delta^7  (POSITIVE)
```

So fermion fable is four flavours times a 4D Dirac field, and `J`-quantization replaces the
classical flavour metric of signature `(2,2)` by the identity. The adjoint is **mode-independent**,
and it must be defined this way: a mode-by-mode prescription is basis-dependent unless every mode is
a `J`-eigenvector (section 6.13). **[proved VII §28]**

- `J [THE RESULT]: J == -i Omega4 T16[0] == -i h_0 is a hidden flavour gamma: it lies in the commutant of T16[1..4] (in the span of the hidden-gamma products of Section 26)`
- `J [has content]: on the flavour factor J has signature (2,2): cfIdemObs is a rank-4 projector commuting with J, and J restricted to its image has eigenvalues +1, +1, -1, -1`
- `J [THE RESULT]: sigma16 == J beta with beta = -i T16[4] Hermitian, beta^2 == 1; T16[0..3] Hermitian with beta T16[j] beta == -T16[j]: beta is the observer's Dirac adjoint`
- `J [THE RESULT]: with Psi^dagger := Psi^ddag J:  Psibar = Psi^dagger beta (J sigma16 == beta),  Psi^ddag G = Psi^dagger (J G == ID16),  {Psi, Psi^dagger} == (H/Sqrt[g]) ID16 (G^-1 J == ID16): POSITIVE`

`J` and `beta`, as exported (`provenance-latex/generated/fermion_fable_krein_J.txt`, verbatim):

```
J = -I T16[0].T16[1].T16[2].T16[3].T16[4] = -I sigma16.T16[4]:
0  0  0  0  0  0  0  0  0  I  0  0  0  0  0  0
0  0  0  0  0  0  0  0  -I  0  0  0  0  0  0  0
0  0  0  0  0  0  0  0  0  0  0  -I  0  0  0  0
0  0  0  0  0  0  0  0  0  0  I  0  0  0  0  0
0  0  0  0  0  0  0  0  0  0  0  0  0  -I  0  0
0  0  0  0  0  0  0  0  0  0  0  0  I  0  0  0
0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  I
0  0  0  0  0  0  0  0  0  0  0  0  0  0  -I  0
0  I  0  0  0  0  0  0  0  0  0  0  0  0  0  0
-I  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
0  0  0  -I  0  0  0  0  0  0  0  0  0  0  0  0
0  0  I  0  0  0  0  0  0  0  0  0  0  0  0  0
0  0  0  0  0  -I  0  0  0  0  0  0  0  0  0  0
0  0  0  0  I  0  0  0  0  0  0  0  0  0  0  0
0  0  0  0  0  0  0  I  0  0  0  0  0  0  0  0
0  0  0  0  0  0  -I  0  0  0  0  0  0  0  0  0

beta = -I T16[4]:
0  0  0  0  0  0  0  0  0  0  0  0  0  I  0  0
0  0  0  0  0  0  0  0  0  0  0  0  -I  0  0  0
0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  -I
0  0  0  0  0  0  0  0  0  0  0  0  0  0  I  0
0  0  0  0  0  0  0  0  0  -I  0  0  0  0  0  0
0  0  0  0  0  0  0  0  I  0  0  0  0  0  0  0
0  0  0  0  0  0  0  0  0  0  0  I  0  0  0  0
0  0  0  0  0  0  0  0  0  0  -I  0  0  0  0  0
0  0  0  0  0  -I  0  0  0  0  0  0  0  0  0  0
0  0  0  0  I  0  0  0  0  0  0  0  0  0  0  0
0  0  0  0  0  0  0  I  0  0  0  0  0  0  0  0
0  0  0  0  0  0  -I  0  0  0  0  0  0  0  0  0
0  I  0  0  0  0  0  0  0  0  0  0  0  0  0  0
-I  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
0  0  0  -I  0  0  0  0  0  0  0  0  0  0  0  0
0  0  I  0  0  0  0  0  0  0  0  0  0  0  0  0

sigma16 = J.beta, J^2 = beta^2 = 1, Psibar = Psi^dagger beta
```

### 6.6 Why this is legitimate for fermions, and why it would fail for bosons

For Grassmann fields the `*`-structure is a free choice: the Berezin integral treats `Psi` and
`Psibar` as independent, and the `J`-involution is that choice. The filled Dirac sea makes the
Hamiltonian bounded below. For a **commuting** 16-component field the same involution gives
`[b, b^dagger] = 1`, but the Hamiltonian `Sum_u omega_u b_u^dagger b_u` then has 8 negative-frequency
modes per momentum and no exclusion principle to fill them: it is unbounded below. The only local
involutions compatible with a Hermitian `s` and a Hermitian Hamiltonian are `+J` and `−J` (the
uniqueness theorem, 6.10), and `−J` gives every mode negative norm; making the bosonic Hamiltonian
bounded below would turn 4 modes into negative-norm modes. For fermions the
negative-frequency modes are filled and the obstruction disappears [prose VII §28; design review
QK-5].

The `J`-odd bilinears (`That_{mu h}`, `j^h`, `Psibar T16[8] Psi`) become **anti-Hermitian** operators
(6.8). So the classical real theory of Part VI is the classical limit of the `J`-**even** sector
only. (A reflection-positivity claim that appeared in the design was dropped by the review: it was
not verified.)

### 6.7 Chirality, and why `V` depends on `s` only

`J` anticommutes with `T16[8]`: `J` exchanges the two split-octonion types. Each chirality subspace
is `G`-**null** (`PL G PL = PR G PR = 0`: the Krein form pairs type-1 with type-2 only), so the
`J`-vacuum is not chirality-graded; but the two chirality subspaces **are** orthogonal in the Hilbert
product (`PL PR = 0`, with `PL`, `PR` Hermitian). Neither `p = Psibar T16[8] Psi` (anti-Hermitian
under `J`) nor `i p` (anti-Hermitian under the classical conjugation `^ddag`, so it would make the
Lagrangian complex) can enter `V` consistently: **`V = V(s)`**. **[proved VII §28]**
`J [has content]: chirality -- {J, T16[8]} == 0, each chirality subspace is G-NULL (PL G PL == PR G PR == 0), and the two chiralities are orthogonal in the Hilbert product (PL, PR Hermitian, PL PR == 0)`

### 6.8 The Hermiticity rule and the `J` table

Under the `J`-adjoint, a bilinear `Psi^ddag M Psi` with `M` classically Hermitian has
`(Psi^ddag M Psi)^dagger = Psi^ddag (J M J) Psi`: it is **Hermitian** iff `[J, M] = 0` and
**anti-Hermitian** iff `{J, M} = 0`. The table records `J` against every matrix that occurs
**[proved VII §28]**:

| matrix | relation to `J` | consequence |
|---|---|---|
| `sigma16` | commutes | `s` is Hermitian |
| `T16[0]`, …, `T16[4]` | commute | |
| `T16[5]`, `T16[6]`, `T16[7]` | anticommute | |
| `sigma16 gamma^mu`, `mu = 0..4` | commute | `j^mu`, `mu = 0..4`, Hermitian |
| `sigma16 gamma^h`, `h = 5, 6, 7` | anticommute | `j^h` anti-Hermitian |
| each `gamma^mu Gamma_mu` (no sum), `mu = 0..7` | commute | the connection term of the Dirac operator is `J`-even |
| `Gamma_0`, `Gamma_4` (both zero), `Gamma_1`, `Gamma_2`, `Gamma_3` | commute | |
| `Gamma_5`, `Gamma_6`, `Gamma_7` | anticommute | boosts mixing `x0` or `x4` with the hidden timelike sheet |
| `T16[8]` and `C+ = sigma16 T16[8]` | anticommute | `p = Psibar T16[8] Psi` is anti-Hermitian |

- `J TABLE [THE RESULT]: J commutes with sigma16, T16[0..4], sigma16 gamma^mu (mu = 0..4), every gamma^mu Gamma_mu and Gamma_1..Gamma_3; it ANTIcommutes with T16[5..7], sigma16 gamma^h (h = 5..7), Gamma_5..Gamma_7, T16[8] and C+`
- `J [has content]: the Hermiticity rule -- for classically Hermitian M, (J M)^dagger == J M iff [J, M] == 0 and == -J M iff {J, M} == 0: so s = Psi^ddag sigma16 Psi is Hermitian and p = Psi^ddag C+ Psi is ANTI-Hermitian`

Consequences: `s` is Hermitian and `p` anti-Hermitian (so `V` may depend on `s` but not on `p`);
the hidden current components `j^h` and the energy–momentum components `That_{mu h}`
(`mu = 0..4`) are built from anticommuting matrices and are anti-Hermitian: their expectation values
are purely imaginary in every state and vanish in every state invariant under the hidden rotations
(the `J`-vacuum and the Kohn–Sham states of section 8), consistent with `G_{mu h} = 0` on the
canonical frame. `That_{h h'}` (`h != h'`) vanishes identically for fields independent of `x5..x7`,
and `That_{hh} = g_hh Lhat` is Hermitian (section 7.5).

(The same `J` table holds on the dynamical frames of the interacting system; Part VIII, Section 32,
proves it: `J [THE RESULT]: [J, gamma^mu Gamma_mu] == 0 for EACH mu separately (h = 5,6,7 included), on the warped and on the Bianchi-I frame` and `J [THE RESULT]: [J, Gamma_mu] == 0 for mu = 0..4 and {J, Gamma_h} == 0 for h = 5, 6, 7, on the warped and on the Bianchi-I frame`.)

### 6.9 The symmetry that survives, and what is lost

Of the 28 Lorentz generators `S_ab`, **13 commute** with `J`: Spin(4,1) of `x0..x4` (10 generators)
and Spin(3) of `x5..x7` (3). The other **15 anticommute**: the 12 boosts between `x0..x3` and
`x5..x7`, and the 3 **rotations** between `x4` and `x5..x7` (`x4..x7` are all timelike, so those
planes are rotations). The Krein form `G` itself is invariant (`S^T G + G S = 0`) under exactly the
21 generators with `a, b != 4`: Spin(4,3), the group of the slice. **[proved VII §28]** (The `J`
structure is defined in the diagonal gauge of the canonical frame and transforms as `J -> S^-1 J S`
under a change of frame gauge `S`; design review QK-6.)

- `J [THE RESULT]: 13 of the 28 Lorentz generators commute with J (a, b both in {0..4}: Spin(4,1), or both in {5,6,7}: Spin(3)); the other 15 anticommute -- 12 boosts x0..x3 <-> x5..x7 and 3 rotations x4 <-> x5..x7`
- `J [has content]: the Krein form G is invariant (S^T G + G S == 0) under exactly the 21 generators with a, b != 4 -- Spin(4,3), the group of the slice`

### 6.10 The admissible sector: a theorem

Take a plane wave at momentum `k` (flat local analysis, the frame factors frozen). The one-particle
Hamiltonian is `h_k = sigma16 (m − i gamma.k)`, with `gamma.k = Sum_{a != 4} k_a T16[a]`, and the
evolution generator is `E_k = G^-1 h_k = G h_k`, `i d_4 Psi = E_k Psi`. Write
`k_s^2 = k0^2 + k1^2 + k2^2 + k3^2` and `k_h^2 = k5^2 + k6^2 + k7^2`.

1. For **every** `k`, `E_k^2 = (k_s^2 − k_h^2 + m^2) ID16`: the dispersion relation is
   `omega^2 = k_s^2 − k_h^2 + m^2`.
2. **Admissible** `k` (`k_h = 0`): `[J, E_k] = 0` and `J` itself gives the positive quantization
   (`G J = ID16`).
3. Hidden momentum **below** threshold (`k_h^2 < k_s^2 + m^2`): a momentum-dependent, boosted
   `J' = S^-1 J S` (`S` the spin boost in the plane of `k_s` and `k_h` that removes `k_h`) commutes
   with `E_k` and with `beta`, `J'^2 = 1`, and `G J' = S^2` is positive definite: each such momentum
   can be quantized positively on its own (checked at `k = 5 e1 + 3 e5`, `m = 3`,
   `omega^2 = 25 − 9 + 9 = 25`, boost with `tanh(theta) = 3/5`).
4. **At** threshold `E_k` is not zero but `E_k^2 = 0`: `E_k` is nilpotent and cannot be diagonalized
   (Jordan blocks of size 2, rank 8); there is no mode expansion (checked at `k = 4 e1 + 5 e5`,
   `m = 3`).
5. **Above** threshold `omega^2 < 0`: the frequencies are imaginary (growth along `x4`, the
   ill-posed ultrahyperbolic Cauchy problem) and the modes are `G`-**neutral** (`u^dagger G u = 0`),
   so they carry no norm at all. Example: `k = (0, 3/4, 1, 0 | k5 = 2)`, `m = 1`:
   `omega^2 = −23/16`, `omega = ±i Sqrt[23]/4 = ±1.19896 i`.
6. **No** single momentum-independent positive `J'` exists once a hidden momentum is present. If
   `V(s)` and the local energy–momentum tensor are to be Hermitian, `J'` must commute with `beta`
   (because `s = Psi^ddag G beta Psi`) and with `E_k` for all `k`. Certificate: for the four admissible
   unit momenta and one hidden momentum, **every** `X` commuting with `beta` and all five `E_k` has
   `Tr(G X) = 0`, so `G X` is never positive definite. Analytic proof for a purely hidden momentum:
   `[E_k, beta] = 2 i k5 T16[5]`, so `J'` commutes with `T16[5]`; `T16[5]` anticommutes with `G`, hence
   `T16[5]^dagger (G J') T16[5] = −(G J')`: a positive matrix would be congruent to a negative one.
7. `J` is **unique**: the joint commutant of `beta` and all admissible `E_k` is 8-dimensional and every
   one of its elements commutes with `J`; if `X` is in it with `X^2 = 1` and `G X = J X` definite, then
   `(J X)^2 = 1`, and a definite Hermitian matrix with square 1 is `±ID16`: `X = J` (positive metric)
   or `X = −J` (every mode of negative norm).

The general identity behind (6) is `[E_k, beta] = 2 i T_k`, `T_k = Sum_a k_a T16[a]`, for every `k`.

**THEOREM (admissibility).** Let `W` be the linear span of the momenta carried by the modes, a
subspace of the slice `R^(4,3)`. A positive (Hilbert-space) Fock quantization in which the local
`s(x)`, the local energy–momentum tensor and the free Hamiltonian are all Hermitian exists **if and
only if `W` is spacelike-definite**. Then `J' = S^-1 J S` with `S` a slice boost carrying `W` into
`span(x0..x3)`, and `J'` is unique (with `J'^2 = 1`) when `W = span(x0..x3)`. On the canonical frame
the fields depend on all of `x0..x3`, so the condition is: **no momentum along `x5, x6, x7`**, and
`J = −i T16[0].T16[1].T16[2].T16[3].T16[4]` is unique.

The admissible theory is a **truncation** (a dimensional reduction `Psi = Psi(x0, ..., x4)`), not a
superselection sector: `V(s)` contains terms like `b^dagger_{k_h} b^dagger_{−k_h} b_0 b_0` that would
connect it to hidden momenta. What survives of the multi-time (Tomonaga–Schwinger) picture is the
isometry fact: the metric, the frame and the connection do not depend on `x5, x6, x7`, so the hidden
translations commute with the `x4`-evolution, `[P_4, P_h] = 0` [prose VII §28]. **[proved VII §28]**

- `ADMISSIBILITY (1) [THE RESULT]: E_k^2 == (k_s^2 - k_h^2 + m^2) ID16 for every k: omega^2 = k_s^2 - k_h^2 + m^2`
- `ADMISSIBILITY (2) [THE RESULT]: for admissible k (k_h = 0), [J, E_k] == 0, E_k is J-Hermitian, and G J == ID16 is positive: J quantizes every admissible momentum positively`
- `ADMISSIBILITY (3) [THE RESULT]: below threshold (k = 5 e1 + 3 e5, m = 3) the boosted J' = S^-1 J S commutes with E_k and beta, J'^2 == 1, and G J' == S^2 is Hermitian positive definite`
- `ADMISSIBILITY (4) [THE RESULT]: AT threshold (k = 4 e1 + 5 e5, m = 3) E_k != 0 but E_k^2 == 0: nilpotent, not diagonalizable (rank 8: Jordan blocks of size 2)`
- `ADMISSIBILITY (5) [THE RESULT]: ABOVE threshold (k = (0, 3/4, 1, 0 | k5 = 2), m = 1) omega^2 == -23/16: every eigenvalue of E_k is +-i Sqrt[23]/4 = +-1.19896 i and every eigenvector is G-NEUTRAL (u^dagger G u == 0)`
- `ADMISSIBILITY [has content]: the general identity [E_k, beta] == 2 i T_k, T_k = Sum_a k_a T16[a], for every k (admissible and hidden components alike)`
- `ADMISSIBILITY (6) [THE RESULT]: traceless certificate -- every X commuting with beta, the four admissible E_k and one hidden-momentum E_k has Tr(G X) == 0, so no positive G J' exists; J itself is not in that commutant`
- `ADMISSIBILITY (6) [THE RESULT]: the analytic proof for a purely hidden momentum -- [E_k, beta] == 2 i k5 T16[5]; T16[5] anticommutes with G and T16[5]^dagger G T16[5] == -G (so a J' commuting with T16[5] has T5^dagger (G J') T5 == -(G J'))`
- `ADMISSIBILITY (7) [THE RESULT]: J is UNIQUE -- the joint commutant of beta and the admissible E_k is 8-dimensional, contains J, and every element of it commutes with J (so X^2 == 1 with J X > 0 forces X == J)`
- `ADMISSIBILITY [has content]: [P_4, P_h] == 0 -- the metric, the frame and the spin connection do not depend on x5, x6, x7`

The theorem statement combines items (1)–(7); the items are asserted individually, the "if and only
if" is their combination [prose VII §28].

### 6.11 The Hamiltonian on the canonical frame, and the spin connection

The Hamiltonian **density** of the symmetrized Lagrangian, `Pi_Psi d_4 Psi + d_4 Psibar Pi_Psibar − L`,
is

```
Sqrt[g] [ -(1/(2H)) Sum_{k != 4} ( Psibar gamma^k d_k Psi - d_k Psibar gamma^k Psi ) + V(s) ]
```

with **no spin connection** in it, for fields of all eight coordinates. (This corrects design
revision 1, which said that the connection "enters the Hamiltonian".) Varying it gives the
one-particle operator. In the admissible sector (`Psi = Psi(x0, ..., x4)`) the field equation is
`i Gtilde d_4 Psi = h Psi` with

```
h Psi  =  Sqrt[g] sigma16 [ V'(s) Psi - (1/H) ( Sum_{j=0..3} gamma^j d_j Psi + Sum_mu gamma^mu Gamma_mu Psi ) ]
```

(`V'(s)` is the mean-field `V'(<s>)` here). The connection appears here, through the equation of
motion, and it has a job: since
`(1/2) Sum_{mu != 4} d_mu(Sqrt[g] sigma16 gamma^mu) == Sqrt[g] sigma16 gamma^mu Gamma_mu` and
`d_4(Sqrt[g] sigma16 gamma^4) = 0`, the derivative part of `h` is `−(1/H) Sum_j (A_j d_j + (1/2) d_j A_j)`
with `A_j = Sqrt[g] sigma16 gamma^j` real **antisymmetric**, and for such an operator
`<f, h g> − <h f, g>` is a total derivative. The connection term is exactly the term that makes the
one-particle Hamiltonian Hermitian. **[proved VII §28]**

- `HAMILTONIAN [THE RESULT]: the Hamiltonian density Pi_Psi d_4 Psi + d_4 Psibar Pi_Psibar - L of the symmetrized Lagrangian is Sqrt[g][-(1/(2H)) Sum_{k != 4}(Psibar gamma^k d_k Psi - d_k Psibar gamma^k Psi) + V]: NO spin connection (fields of all eight coordinates)`
- `HAMILTONIAN [THE RESULT]: (Sqrt[g]/H) sigma16 (gamma^mu D_mu Psi - H V' Psi) == i Gtilde d_4 Psi - h Psi for admissible Psi(x0..x4): the field equation is i Gtilde d_4 Psi = h Psi`
- `HAMILTONIAN [THE RESULT]: (1/2) Sum_{mu != 4} d_mu(Sqrt[g] sigma16 gamma^mu) == Sqrt[g] sigma16 Sum gamma^mu Gamma_mu, and d_4(Sqrt[g] sigma16 gamma^4) == 0: the connection term is the one that makes h Hermitian`
- `HAMILTONIAN [has content]: A_0 = Sqrt[g] sigma16 gamma^0 is real antisymmetric, and for h_0 = -(A_0 d_0 + (1/2) A_0'):  <f, h_0 g> - <h_0 f, g> == -d_0(f^dagger A_0 g), a pure boundary term`

`J` commutes with `h`: every matrix in `h` (`sigma16`, `sigma16 gamma^j` for `j = 0..3`,
`sigma16 gamma^mu Gamma_mu`) commutes with `J`, for every `a4`, every `x0`-profile and every `V`. A
hidden derivative term would anticommute (control). The `x4`-dependence of `h` enters only through
the observed frame factor `1/q`; it mixes positive and negative frequencies (a **Bogoliubov**
transformation, particle production by the `x4`-dependence of `a4`) **within** the admissible sector,
and since it commutes with `J` that mixing is unitary on the Fock space. **[proved VII §28]**

- `HAMILTONIAN [THE RESULT]: [J, h] == 0 on the admissible sector, for every a4, every x0-profile and every V' -- including the spin-connection term`
- `HAMILTONIAN [control]: a hidden derivative term breaks it -- [J, h] != 0 once Psi depends on x5 (witnessed on Psi = x5 e1)`
- `HAMILTONIAN [has content]: the x4-dependence of h enters only through 1/q: d_4 h Psi == (H a4'[H x4]) x (the observed-direction part of h), which commutes with J`

### 6.12 The `x0` direction and the boundary condition at the wall

For the rescaled field `Psi' = Psi/Sqrt[Sin[6 H x0]]` the measure becomes flat in the proper
distance `z = −Log[Cos[6 H x0]]/(6 H)` along `x0`:

```
Sqrt[g] dx0 |Psi|^2 = |Psi'|^2 dz          (Sec Sin = Tan = dz/dx0)
```

`z` runs over `[0, infinity)` as `6 H x0` runs over `[0, Pi/2)`; the `x0` part of the rescaled Dirac
operator is exactly `T16[0] d_z`, and the frame factors are bounded,
`Sin[6 H x0] = Sqrt[1 − Exp[−12 H z]]`. So the one-particle space is `L^2(dz)`. The operator is
**regular** at the wall `z = 0`, so a boundary condition is needed there, and **limit-point** at
`z -> infinity` (by the standard theorem that a one-dimensional Dirac system with locally integrable
coefficients is always limit-point at an infinite endpoint), so no condition is needed or allowed
there. The condition at the wall, in this real-Clifford convention, is the bag-type

```
T16[0] Psi' = +Psi'    or    T16[0] Psi' = -Psi'        at z = 0       (no factor i, because T16[0]^2 = +1)
```

It kills the normal flux `Psi'^dagger beta T16[0] Psi'` (because `{beta, T16[0]} = 0`) and commutes
with `J`. It is part of the canonical quantization. **[proved VII §28]** It also gives
`Psibar Psi = 0` at the wall [derived here: `sigma16 = J beta` anticommutes with `T16[0]`, because `J`
commutes and `beta` anticommutes with it, so `P sigma16 P = 0` on either eigenspace `P` of `T16[0]`;
design review QK-9].

- `BOUNDARY [has content]: the x0 direction in proper distance z = -Log[Cos[6 H x0]]/(6 H): dz/dx0 == Tan[6Hx0] == Sec Sin (so Sqrt[g] dx0 |Psi|^2 = |Psi'|^2 dz), z(0) == 0 and z -> infinity at 6 H x0 -> Pi/2, gamma^0 d_0 == T16[0] d_z, and Sin[6Hx0] == Sqrt[1 - Exp[-12 H z]] (bounded frame factors)`
- `BOUNDARY [THE RESULT]: the bag condition T16[0] Psi' = +-Psi' at the wall -- T16[0]^2 == 1, {beta, T16[0]} == 0, the normal-flux form vanishes on both eigenspaces (P beta T16[0] P == 0), and [J, T16[0]] == 0`

(The full family of self-adjoint, Lorentz-covariant, `J`-sector-preserving wall conditions is
`P = T16[0] Q`, with `Q` any Hermitian involution in the 8-dimensional commutant of `T16[0..4]`,
which contains `J`; the uniform choices `Q = ±1` are the two above. That refinement belongs to the
treatment of the states along the hidden coordinate in the coupled system; it was adopted by the
design review, DFT-8, and is not asserted in Part VII.)

### 6.13 Krein modes, and why the mode basis must consist of `J`-eigenvectors

For an admissible momentum `k = (k0, k1, k2, k3)` and mass `m` (flat local analysis; on the canonical
frame `k` is the physical momentum, the coordinate momentum along `x1..x3` divided by `q`), put
`A = G h = E_k` and `w = Sqrt[k.k + m^2]`. Then `A^2 = w^2`, `[A, J] = 0`, `A` is Hermitian, and the
four Hermitian projectors

```
P_{s,eta}  =  (1/4) (ID16 + s A/w) (ID16 + eta J),       s, eta = +1, -1
```

have rank 4 each (trace 4), are mutually orthogonal, sum to `ID16`, and
`Sum eta P_{s,eta} = J = G^-1`: the **completeness relation** `Sum_u eta_u u u^dagger = G^-1` of any
`J`-orthonormal mode basis. So each frequency `±w` is 8-fold degenerate, and the `G`-form restricted
to each frequency eigenspace has signature `(4,4)`. For **every** mode `u` in the image of
`P_{s,eta}`, normalized by `u^dagger G u = eta`, the projector identities `P X P = c P` give, exactly
and for arbitrary `k` and `m`,

```
eta u^dagger h u          = s w = omega_u                       (energy = frequency)
eta u^dagger sigma16 u    = m/omega_u                           (scalar density)
eta u^dagger (dh/dk_j) u  = k_j/omega_u = d omega_u/d k_j       (velocity: Hellmann-Feynman),     dh/dk_j = -i sigma16 T16[j]
```

The identities are proved with `w` a symbol and `w^2` reduced to `k.k + m^2` (exact polynomial
remainder); nothing is numerical. **[proved VII §28]**

- `KREIN MODES [has content]: A = G h satisfies A^2 == w^2 ID16 and [A, J] == 0, and A is Hermitian (G and h commute) for every admissible k and m`
- `KREIN MODES [THE RESULT]: the four P_{s,eta} are projectors of trace (rank) 4, mutually orthogonal, summing to ID16, and Sum eta P_{s,eta} == J == G^-1 (completeness)`
- `KREIN MODES [THE RESULT]: for every mode, eta u^dagger h u == s w (energy = frequency), eta u^dagger sigma16 u == m/omega_u, eta u^dagger (dh/dk_j) u == k_j/omega_u: P X P == c P with c = eta s w, eta s m/w, eta s k_j/w`
- `KREIN MODES [has content]: dh/dk_j == -i sigma16 T16[j], and d omega/d k_j == k_j/omega for omega = +-w`
- `KREIN MODES [THE RESULT]: every mode of P_{s,eta} is a J-eigenvector: J P_{s,eta} == eta P_{s,eta}`

**The mode basis must consist of `J`-eigenvectors.** The Krein prescription
`b_u^dagger := eta_u b_u^ddag` depends on the basis. It reproduces the `J`-involution
`Psi^dagger = Psi^ddag J` only if every mode is a `J`-eigenvector, `J u = eta_u u`, which is what the
`P_{s,eta}` deliver (`J P_{s,eta} = eta P_{s,eta}`), and which is possible because `[J, G h_k] = 0`
for momenta along `x0..x3`. A `G`-orthonormal basis mixed by a Krein boost inside one frequency
eigenspace still diagonalizes the evolution, but it induces the involution `J_U = G U U^dagger != J`,
and under it `s` is **not** Hermitian (control, exact, at `k = 3 e1`, `m = 4`, with the boost
`cosh = 5/4`, `sinh = 3/4`). A generic generalized-eigenvector routine does not choose
`J`-eigenvectors; the Fock construction of 6.14 does. **[proved VII §28]**
`KREIN MODES [control]: a Krein-boosted pair u1 = (5/4)u+ + (3/4)u-, u2 = (3/4)u+ + (5/4)u- in the omega = +5 eigenspace is still G-orthonormal and still consists of modes, but not of J-eigenvectors; the induced J_U = G U U^dagger differs from J, and under it s is NOT Hermitian`

### 6.14 A finite Fock space at one momentum (Jordan–Wigner): the Dirac sea, 8 particles and 8 antiparticles

At the momentum `k = 3 e1` with `m = 4` (so `omega = 5` exactly) the sixteen modes of one momentum are
represented on `C^(2^16) = C^65536` by Jordan–Wigner operators `f_1..f_16` (`SparseArray`, exact
integers), which obey the positive CAR `{f_i, f_j^dagger} = delta_ij`, `{f_i, f_j} = 0`. Two
realizations are checked.

**Field level.** `Psi_a := f_a` (the factor `H/Sqrt[g]` set to 1), `Psi^dagger = f^dagger`,
`Psi^ddag := Psi^dagger J`. Then:

- `{Psi_a, Psi^ddag_b} = J_ab = (G^-1)_ab`: exactly the Dirac-bracket anticommutator, realized on a
  positive Fock space;
- the free Hamiltonian `H_free = Psi^ddag h Psi = Psi^dagger (J h) Psi` and `s = Psi^ddag sigma16 Psi = Psi^dagger beta Psi`
  are Hermitian operators, and so is the interacting `H_free + (3/7) s^2`; `p = Psi^ddag C+ Psi` is
  anti-Hermitian (control); the one-body matrix `J h` has eigenvalues `+5` and `−5`, eight times each;
- the **Heisenberg equation** holds: `[H_free, Psi_a] = −(G^-1 h Psi)_a` for all 16 components, i.e.
  `i d_4 Psi = i [H, Psi]` reproduces `i G d_4 Psi = h Psi`;
- with the **opposite** sign of the anticommutator (`Psi^ddag := −Psi^dagger J`) the same construction
  gives `H' = −H_free` and the time-**reversed** equation (control). This is the convention-free
  confirmation of the sign derived with the Dirac bracket.

**Mode level.** `b_u := f_u` for the sixteen `J`-eigenmodes of 6.13 (`u = 1..8`: `omega = +5`;
`u = 9..16`: `omega = −5`; `J u = eta_u u` with `eta = +1` for four of each and `−1` for the other four):

- the Krein conjugate `b_u^ddag := eta_u b_u^dagger` obeys `{b_u, b_v^ddag} = eta_u delta_uv`, the
  indefinite CAR that the field anticommutator demands through `Sum_u eta_u u u^dagger = G^-1`, and
  the `J`-involution `b^dagger = eta b^ddag` restores `{b, b^dagger} = 1`;
- the naive Krein "norm" `<0| b_u b_u^ddag |0> = eta_u` is **negative** for `eta = −1`: that is the
  indefinite metric the `J`-involution removes (the Fock norm `<0| b_u b_u^dagger |0> = 1`);
- `Ham = Sum_u omega_u eta_u b_u^ddag b_u = Sum_u omega_u b_u^dagger b_u`, and `[Ham, b_u] = −omega_u b_u`
  (`b_u(x4) = b_u e^(−i omega_u x4)`, the time dependence of the classical mode);
- the spectrum on the 65536 states: a **unique ground state** at `−8 omega = −40`, the **Dirac sea**
  (all eight negative-frequency modes filled); the normal-ordered `:Ham: = Ham + 40 >= 0`;
- the first excited level, `omega = 5` above the sea (energy `−35`), is **16-fold**: **8 particle
  states** (one positive-frequency mode added, `N = +1`) and **8 antiparticle states** (one
  negative-frequency mode emptied, a hole, `N = −1`), with `N = Sum_u b_u^dagger b_u − 8`;
- in every Fock basis state tested (the sea and the 16 first excited states) the expectation of
  `b_u^ddag b_v` is `eta_u n_u delta_uv`: the rule `<Psi^ddag M Psi> = Sum_occupied eta_u u^dagger M u` used
  in section 8.

**[proved VII §28]**

- `FOCK [solver regression]: the Jordan-Wigner operators obey the positive CAR {f_i, f_j^dagger} == delta_ij, {f_i, f_j} == 0 on C^65536`
- `FOCK (field level) [THE RESULT]: {Psi_a, Psi^ddag_b} == J_ab == (G^-1)_ab with Psi = f, Psi^ddag = f^dagger J -- the Dirac-bracket anticommutator, realized on a positive Fock space`
- `FOCK (field level) [THE RESULT]: J h is Hermitian with eigenvalues +5 (8) and -5 (8); H_free and s are Hermitian operators, so is H_free + (3/7) s^2; p = Psi^ddag C+ Psi is ANTI-Hermitian`
- `FOCK (field level) [THE RESULT]: Heisenberg -- [H_free, Psi_a] == -(G^-1 h Psi)_a for all 16 components, so i d_4 Psi = i [H, Psi] IS the field equation i G d_4 Psi = h Psi`
- `FOCK (field level) [control]: with the opposite sign of the anticommutator the Hamiltonian is -H_free and [H', Psi_a] == +(G^-1 h Psi)_a: the time-REVERSED equation`
- `FOCK (mode level) [THE RESULT]: {b_u, b_v^ddag} == eta_u delta_uv (the indefinite CAR demanded by Sum eta u u^dagger = G^-1), and the J-involution b^dagger = eta b^ddag restores {b, b^dagger} == 1`
- `FOCK (mode level) [has content]: the naive Krein 'norm' <0| b_u b_u^ddag |0> equals eta_u -- NEGATIVE for the four eta = -1 modes of each frequency -- while the Fock norm <0| b_u b_u^dagger |0> == 1`
- `FOCK (mode level) [THE RESULT]: Sum omega_u eta_u b_u^ddag b_u == Sum omega_u b_u^dagger b_u, and [Ham, b_u] == -omega_u b_u for every u (b_u(x4) = b_u e^(-i omega_u x4))`
- `FOCK (mode level) [THE RESULT]: the spectrum -- a UNIQUE ground state at -8 omega = -40, the Dirac sea (modes 9..16 filled, 1..8 empty); :Ham: = Ham + 40 >= 0`
- `FOCK (mode level) [THE RESULT]: the first excited level, omega = 5 above the sea, is 16-fold: 8 particle states (N = +1) and 8 antiparticle states (N = -1), with N = Sum b^dagger b - 8`
- `FOCK (mode level) [THE RESULT]: in every Fock basis state tested (the sea and the 16 first excited states) <n| b_u^ddag b_v |n> == eta_u n_u delta_uv -- the expectation rule of Section 29`

The Jordan–Wigner CAR check on the 65536-dimensional space took 0.749 s and the Heisenberg check
1.868 s; the whole Fock cell (Input cell 191) took 9.858 s
(`claude-fable/run_fermion_fable_part7.log`, lines `[0.749 s]`, `[1.868 s]`, `CELL 191  t=9.858 s`).

### 6.15 The particle number

The particle-number density is

```
n^4 = -(i/H) Psibar gamma^4 Psi  ==  (1/H) Psi^ddag G Psi  ==  (1/H) Psi^dagger Psi  >= 0
```

and its mode form `Sum_u eta_u b_u^ddag b_u == Sum_u b_u^dagger b_u` is the particle number
(normal-ordered: particles minus antiparticles). **[proved VII §28]** `CHARGE [THE RESULT]: n^4 = -(i/H) Psibar gamma^4 Psi == (1/H) Psi^ddag G Psi == (1/H) Psi^dagger Psi, whose mode form Sum_u eta_u b_u^ddag b_u == Sum_u b_u^dagger b_u is the particle number (normal-ordered: particles - antiparticles)`

### 6.16 The dynamical-frame field `chi`

On a frame whose volume factor depends on `x4` the field to quantize is
`chi = (Sqrt[g]/H)^(1/2) Psi`, with `{chi, chi^ddag} = G delta^7` (6.4). On the canonical frame
`Sqrt[g] = Sec[6 H x0]` does not depend on `x4`, and quantizing `chi` changes nothing
(`ANTICOMMUTATOR [has content]: the rescaled field Psi' = Psi/Sqrt[Sin[6 H x0]] has {Psi', Psi'^ddag} == H Cot[6 H x0] J delta^7, and Sqrt[g] is x4-independent (so quantizing chi = (Sqrt[g]/H)^(1/2) Psi changes nothing on the canonical frame)`). On the time-dependent warped frames of the interacting
system (Part VIII), the rescaled `chi = Psi / (Sqrt[Sin[6 H x0]] (A^3 B^3 C)^(−1/2))` has
`{chi, chi^ddag} = H Cot[6 H x0] G`, independent of `x4` and of the scale factors
(`RESCALING [THE RESULT]: {Psi, Psi^ddag} == (H/Sqrt[|det g|]) G on the warped frame (Section 28's cfAntiPsiPsiDd at c = Sqrt[|det g|]/H), and for chi = Psi/f, f = Sqrt[Sin] (A^3 B^3 C)^(-1/2): {chi, chi^ddag} == H Cot[6 H x0] G -- the Sqrt[det g] cancels, independent of x4 and of A, B, C`).

## 7. The energy–momentum tensor operator

This is the first half of Section 29 of the notebook (Input cells 192–194, 16 assertions).

### 7.1 The definition, and where it comes from

The energy–momentum tensor of fermion fable is

```
That_{mu nu}  =  -(1/(4H)) [ Psibar gamma_mu D_nu Psi - (D_nu Psibar) gamma_mu Psi + (mu <-> nu) ]  +  g_{mu nu} Lhat,        gamma_mu = g_{mu nu} gamma^nu
```

normal-ordered with respect to the `J`-vacuum of section 6 when it is an operator. It is the
**Hilbert** (symmetric-tetrad) tensor of the symmetrized action, `T^{mu nu} = (2/Sqrt[g]) dS/dg_{mu nu}`,
and it equals the covariant expression above **off shell**. The notebook checks this the direct way:
it perturbs the canonical frame by a symmetric first-order tetrad perturbation `h(x0, x4)` in the
`(mu, nu)` slot, recomputes to first order everything that depends on the frame (the metric, the
Christoffel symbols, the spin connection from the vielbein postulate, the curved gammas,
`Sqrt[g]`), and takes the Euler–Lagrange derivative with respect to `h`. Three facts come out:

1. The result is the tensor above, checked on the diagonal `(x1, x1)`, `(x4, x4)` and off the diagonal
   `(x1, x4)`, `(x0, x5)`, `(x5, x4)`.
2. The variation of the spin connection contributes **exactly nothing**. Its totally antisymmetric
   part does not change under a symmetric tetrad variation, and the symmetrized Lagrangian sees the
   connection only through that part, `(1/2) omega_[cab] gamma^{cab}`. The covariant-derivative terms
   of the tensor come instead from the frame dependence of `{gamma^mu, Gamma_mu}`, which vanishes on
   the background while its first variation does not.
3. The Hilbert tensor is **not** the partial-derivative tensor `T_par` (control, at `(x1, x4)`): one
   never varies a partial-derivative Lagrangian with respect to the frame.

**[proved VII §29]**

- `EMT [THE RESULT]: the Hilbert (symmetric-tetrad) tensor of the symmetrized action IS That, OFF shell -- components (x1,x1), (x4,x4), (x1,x4), (x0,x5), (x5,x4)` (the five components took 0.693 s)
- `EMT [has content]: the spin-connection variation contributes NOTHING -- dropping it leaves the Hilbert tensor unchanged at (x1,x4), (x0,x5), (x5,x4)`
- `EMT [control]: the Hilbert tensor is NOT the partial-derivative tensor: at (x1,x4) they differ -- witnessed on constant spinors (Psibar = e1, Psi = e11: (T16[4] T16[1] T16[0])_{1,11} != 0)`

### 7.2 Symmetric and Hermitian

`That` is symmetric, and it is Hermitian under the classical conjugation: real for `Psi = u + i v`,
`Psibar = (u − i v)^T sigma16`, in all 64 components. **[proved VII §29]**

- `EMT [definition]: That is symmetric`
- `EMT [THE RESULT]: That is Hermitian under the classical conjugation: real for Psi = u + i v, Psibar = (u - i v)^T sigma16, all 64 components`

### 7.3 Conservation on shell, and why the commuting proxy proves it for the fermion

Solve the two field equations for the `x4`-derivatives:

```
d_4 Psi     =  F     =  -gamma^4 ( H V'(s) Psi - gamma^0 d_0 Psi - (gamma^mu Gamma_mu) Psi )
d_4 Psibar  =  Fbar  =  ( H V'(s) Psibar + d_0 Psibar gamma^0 - Psibar (Gamma_mu gamma^mu) ) gamma^4
```

and let `cfOnShellC` replace every `x4`-derivative of either field (of any order) by the
corresponding derivative of `F` or `Fbar`, to a fixed point. Then `nabla^mu That_{mu nu} == 0` in all
eight components, for generic `Psi(x0, x4)`, `Psibar(x0, x4)` and generic `V`.

**Why a commuting computation proves the Grassmann statement.** After the substitution, every term
of the divergence is a bilinear with `Psibar` (or a derivative of it) on the left and `Psi` (or a
derivative) on the right, multiplied by functions of the **even** composites `s` and `d s` (through
`V'`, `V''` and their derivatives). No two odd factors are ever exchanged, so the same algebra holds
verbatim for anticommuting components. (The argument is not valid for arbitrary quartic identities;
it is valid here because of that structure.) A configuration that is not a solution has a non-zero
divergence (control).

**The connection does not drop out of the tensor.** `That` differs from the partial-derivative
tensor by

```
That_{mu nu} - T_par_{mu nu}  ==  -(1/(4H)) Psibar ( {gamma_mu, Gamma_nu} + {gamma_nu, Gamma_mu} ) Psi
```

which vanishes on the diagonal (so `rho` and every pressure are the same in both) but not off it,
and only `That` is conserved. (The symbolic divergence of `T_par` is not attempted: it takes minutes,
and the off-diagonal difference already shows the two tensors are different.) **[proved VII §29]**

- `EMT CONSERVATION [definition]: F and Fbar solve the field equation and the adjoint equation for the x4-derivatives`
- `EMT CONSERVATION [THE RESULT]: nabla^mu That_{mu nu} == 0 ON SHELL in all eight components, for generic Psi(x0, x4), Psibar(x0, x4) and generic V` (the divergence took 0.767 s and its on-shell reduction 2.599 s)
- `EMT CONSERVATION [control]: OFF shell the divergence is not zero -- witnessed on Psi = (x4 + x0^2) e1 + e13, Psibar = e1 + x4 e5 with V = s^2, which is not a solution`
- `EMT [THE RESULT]: That - T_par == -(1/(4H)) Psibar ({gamma_mu, Gamma_nu} + {gamma_nu, Gamma_mu}) Psi: equal on the diagonal (every {gamma_mu, Gamma_mu} vanishes), different off it (the (x1, x4) witness above)`

The statement is proved for fields of `(x0, x4)`. That is the family in which `rho`, `P` and the
pre-universe results of section 8 are evaluated.

### 7.4 On shell: the Lagrangian, the density, the pressures and the trace

With `cfOnShellC`, for generic `Psi(x0, x4)`, `Psibar(x0, x4)` and generic `V`:

```
kinetic bilinear  (1/(2H)) [ Psibar gamma^mu D_mu Psi - (D_mu Psibar) gamma^mu Psi ]  ==  s V'(s)        (NOT zero)
Lhat              ==  s V'(s) - V(s)
rho = That_44     ==  V(s) + K_h,           K_h = -(1/(2H)) ( Psibar gamma^0 d_0 Psi - d_0 Psibar gamma^0 Psi )
T^i_i == T^h_h    ==  s V'(s) - V(s)        (i = 1, 2, 3 observed;  h = 5, 6, 7 hidden;  no sum)
T^0_0             ==  s V'(s) - V(s) + K_h
T^mu_mu           ==  7 s V'(s) - 8 V(s)    (off shell:  7 Lkin - 8 V)
```

The observer is `u = d/dx4`, so `rho = T_44` (the array element `[[5,5]]`) and the pressure along a
direction `j` is `P_j = T^j_j` (no sum). `P_i = P_h` holds because `{gamma^mu, Gamma_mu} = 0` for
**each** direction separately: the kinetic parts of `T^i_i` and `T^h_h` vanish for fields of
`(x0, x4)`, and both reduce to `Lhat`. The trace is consistent with the list: `T^4_4 = −rho`, so
`−(V + K_h) + (sV' − V + K_h) + 6 (sV' − V) = 7 sV' − 8 V` [derived here]. In the real commuting limit
`K_h` is Part VI's `cfKh` (section 2.12.4), and for the rescaled solutions
`Psi = Sqrt[Sin[6 H x0]] Psi'(x4)` (and the same for `Psibar`) `K_h = 0` and `rho = V(s)`: Part VI's
formulas, now for the complex field. **[proved VII §29]**

- `EMT ON SHELL [THE RESULT]: the kinetic bilinear == s V'(s) (not zero) and Lhat == s V'(s) - V(s)`
- `EMT ON SHELL [THE RESULT]: rho = That_44 == V(s) + K_h`
- `EMT ON SHELL [THE RESULT]: T^i_i == T^h_h == s V'(s) - V(s) for the three observed and the three hidden directions, and T^0_0 == s V'(s) - V(s) + K_h`
- `EMT [has content]: the trace T^mu_mu == 7 Lkin - 8 V off shell, == 7 s V'(s) - 8 V(s) on shell`
- `EMT [fidelity]: K_h in the real commuting limit IS Part VI's cfKh, and K_h == 0 on the rescaled solutions Sqrt[Sin] Psi'(x4), Sqrt[Sin] Psi'bar(x4), where rho == V(s)`

### 7.5 Which components are Hermitian operators: the `J`-parity table

For fields independent of `x5, x6, x7` (the admissible sector, here `Psi(x0, ..., x4)`,
`Psibar(x0, ..., x4)`), replace `Psi -> J Psi` and `Psibar -> Psibar J` (`J^2 = 1`, `s` is unchanged).
A component that goes into itself is built from `J`-even matrices and is a **Hermitian** operator;
one that goes into minus itself is **anti-Hermitian** (section 6.8). The notebook computes the
parity of all 64 components (3.561 s) and asserts the table:

| component | `J`-parity | operator |
|---|---|---|
| `That_{mu nu}`, `mu, nu` in `{0..4}` | even | Hermitian |
| `That_{mu h}`, `mu` in `{0..4}`, `h` in `{5,6,7}` | odd | anti-Hermitian: purely imaginary expectation values, zero in every state invariant under the hidden rotations (`That_{mu h}` is a vector under them) |
| `That_{h h'}`, `h != h'` | zero identically | — |
| `That_{hh}` | even | Hermitian; `That_{hh} = g_hh Lhat` exactly, because `{gamma_h, Gamma_h} = 0` |

The hidden momenta `P_h = Int Sqrt[g] That^4_h` are `J`-odd operators with zero expectation in the
`J`-eigenmode Fock states of section 6 [prose VII §29]. The anti-Hermitian components are
consistent with `G_{mu h} = 0` on the canonical frame. **[proved VII §29]**

- `EMT HERMITICITY [THE RESULT]: J-parity table -- (mu, nu) in {0..4}: EVEN (Hermitian); (mu in 0..4, h in 5..7): ODD (anti-Hermitian); (h, h'), h != h': ZERO identically; (h, h): even`
- `EMT HERMITICITY [has content]: for x5..x7-independent fields That_{hh} == g_hh Lhat exactly, because {gamma_h, Gamma_h} == 0`

### 7.6 The real commuting limit

Set `Psi -> psi` (real, commuting) and `Psibar -> psi^T sigma16`. Then `That` becomes Part VI's
covariant tensor `T_cov` of section 2.12.3 exactly, all 64 components: `FIDELITY [4] [fidelity]: the energy-momentum tensor That in the real limit IS Part VI's covariant tensor cfTCov, all 64 components`. The
classical tensor of 2026-09-16 is therefore the commuting shadow of the operator derived here.

## 8. Density, pressure and equations of state

This is the second half of Section 29 of the notebook (Input cells 195–197, 23 assertions), with the
numerically stable forms used by the solver and the vacuum-energy caveat added from the design
review.

### 8.1 The operators

The observer is `u = d/dx4`. The energy-density and pressure **operators** are the normal-ordered
components of section 7:

```
rho_op   =  :That_44:                        (the energy density measured by the observer)
P_j,op   =  :That^j_j:     (no sum)          j = 1, 2, 3: the observed sheet;   j = 0: the hidden spacelike direction;   h = 5, 6, 7: the hidden timelike sheet
w        =  <P_obs> / <rho>                  P_obs = the pressure along the observed sheet
```

On shell, for fields of `(x0, x4)`: `rho = V(s) + K_h`, `P_i = P_h = s V'(s) − V(s)`,
`P_0 = s V'(s) − V(s) + K_h` (section 7.4). These are operator identities in the sense of section 5.9
(ordering by the Weyl rule; exact for linear `V`).

### 8.2 Expectation values: the mode sums, and one particle

Use the **canonical normalization** `chi = Psi/Sqrt[H]`. Then `V(s) = V(H sigma) =: W(sigma)` with
`sigma = <chibar chi>`, and `m = W'(sigma)` is the mass in the mode equation. On a flat-frame plane
wave `chi = u Exp[i (k.x − omega x4)]`, `chibar = ubar Exp[−i (k.x − omega x4)]` (`ubar = u^ddag sigma16`),
the kinetic parts of the tensor are

```
T_44 + Lhat     ==  omega ubar (-i T16[4]) u  =  omega u^ddag G u
T^j_j - Lhat    ==  k_j  ubar (-i T16[j]) u   =  k_j u^ddag (dh/dk_j) u          (j = 0..3, flat frame)
```

By the expectation rule `<Psi^ddag N Psi> = Sum_occupied eta_u u^dagger N u` (section 6.14) and the
exact mode identities of section 6.13, each occupied positive-frequency mode contributes `omega` to
the energy density, `k_j^2/omega` to the pressure along `j`, and `m/omega` to `sigma`; each hole in
the sea contributes the same with `omega -> |omega|`. So for a state of `N` modes in a coordinate
volume `Vol`:

```
rho    =  Sum omega/Vol + (W - sigma W')
P_j    =  Sum k_j^2/(omega Vol) + (sigma W' - W)
sigma  =  Sum m/(omega Vol)
```

For **one particle**, `w = (k^2/3)/omega^2` (isotropic average) on top of the background
`W − sigma W'`. **[proved VII §29]**

- `MODE SUMS [THE RESULT]: on a flat-frame plane wave (canonical normalization), T_44 + Lhat == omega ubar (-i T16[4]) u and T^j_j - Lhat == k_j ubar (-i T16[j]) u (j = 0..3): energy and pressure are the frequency and k_j dh/dk_j bilinears`
- `MODE SUMS [has content]: with ubar = u^ddag sigma16 these are omega u^ddag G u and k_j u^ddag (dh/dk_j) u, so by Section 28 each occupied mode contributes omega, k_j^2/omega and (to sigma) m/omega`

### 8.3 The vacuum: normal ordering, the sea energy, and the cosmological-constant problem

`<0| :That_{mu nu}: |0> = 0` by normal ordering with respect to the `J`-vacuum. That statement is
clean only for a **static** background (`a4 = const`) or in the adiabatic limit. On an
`x4`-dependent background normal ordering is ambiguous: with respect to the instantaneous vacuum it
breaks covariant conservation, and with respect to a fixed in-vacuum it leaves a divergence. A
conserved renormalized `<T>` needs adiabatic subtraction or point-splitting [prose VII §29].

The **unrenormalized sea energy** per unit volume, `−g Int^Lambda d^3k/(2 pi)^3 omega`, is minus the
Fermi-sea energy at `k_F = Lambda`:

```
-eps_KS(Lambda)  =  -(g/(16 pi^2)) [ 2 Lambda^4 + 2 m^2 Lambda^2 + m^4/4 - m^4 Log[2 Lambda/m] ]  +  o(1)       (Lambda -> infinity)
```

Its finite, mass-dependent part contains `−(g/(32 pi^2)) m^4 Log[m^2]`. It is absorbed into `V`
(the renormalized, "no-sea" functional). **The cosmological-constant problem is not solved here.**
**[proved VII §29]** `VACUUM [THE RESULT]: the unrenormalized sea energy -eps_KS(Lambda) == -(g/(16 pi^2))(2 Lambda^4 + 2 m^2 Lambda^2 + m^4/4 - m^4 Log[2 Lambda/m]) + o(1) as Lambda -> infinity; its m-dependent finite part contains -(g/(32 pi^2)) m^4 Log[m^2]`

**For a mass that varies (the coupled system), the sea energy cannot be absorbed silently** (design
review DFT-4, adopted). The renormalized one-loop Dirac-sea energy that the no-sea functional drops
(relativistic Hartree approximation, Chin 1977), per 3-volume, with reference mass `M` and
counterterms through `m^4`, is

```
DeltaE_vac(m) = -(g/(16 pi^2)) [ m^4 ln(m/M) + M^3 (M - m) - (7/2) M^2 (M - m)^2 + (13/3) M (M - m)^3 - (25/12) (M - m)^4 ]
```

[file: `fable-cosmology/rust/fable_fermion/src/kohn_sham.rs`, function `vacuum_energy`; its unit test
`vacuum_energy_vanishes_to_fifth_order_at_the_reference_mass` checks that it vanishes like `(m − M)^5`
at `m = M` and is even in `m`]. Since `2bc936d` the solver evaluates it as
`DeltaE_vac = −(g/(16 pi^2)) M^4 F(u)` with `u = (m − M)/M`, summing the power series
`F(u) = u^5/5 − u^6/30 + u^7/105 − ...` for `|u| <= 0.75` and the closed form (with `log1p`)
otherwise, because the closed form above cancels to rounding noise near `m = M`; the unit test
`vacuum_energy_matches_high_precision_references_near_and_far_from_the_reference_mass` compares it
with 120-digit references, and the commit records agreement to `1.8e-15` [file: the same function,
`vac_bracket` and their tests; commit `2bc936d`]. It is neither zero nor absorbable into `W` without changing the gap
equation; the solver reports it (column `vac_over_rhoc`) and does not include it in the dynamics.
Reading `W` as the fully renormalized effective potential absorbs it formally, but that is a
fine-tuning. Its size [derived here]: at `m = 0` the bracket is
`M^4 (1 − 7/2 + 13/3 − 25/12) = −M^4/4`, so `DeltaE_vac(0) − DeltaE_vac(M) = g M^4/(64 pi^2)`. With `g = 8`
and the unit `E_c = rho_c0^(1/4) = 2.46261e-3 eV` (asserted in Part VIII:
`fable4d RUNS [definition]: the units computed from CODATA 2018 -- E_c = rho_c0^(1/4) == 2.46261e-3 eV, Omega_r0 == 9.2096e-5, Omega_b0 = 0.02237/h^2 == 0.049243 (to the quoted digits)`), a mass variation of order `m` changes the vacuum energy by
`g m^4/(64 pi^2) / rho_c0 = 3.44, 3.44e4, 3.44e8, 3.44e12` for `m = 0.01, 0.1, 1, 10 eV` (it scales as
`m^4`). So for `m ≳ 10 meV` it exceeds the critical density. (The design review quoted
`3.44e-4` and `3.44` at `0.01` and `0.1 eV`; those two figures are off by `10^4` and are corrected
here.)

### 8.4 The homogeneous Fermi sea (the Kohn–Sham ground state) in closed form

Fill the positive-frequency modes with `|k| < k_F` along the observed sheet (zero modes along `x0` —
the `Sqrt[Sin]` profile — and along `x5, x6, x7`). The degeneracy is **`g = 8` = 4 flavours × 2
spins** (sections 3.6 and 6: eight positive-frequency modes per momentum). With `w_F = Sqrt[k_F^2 + m^2]`
and `L = Log[(k_F + w_F)/m]` (`m > 0`; everything depends on `m^2` except `sigma`, which has the sign
of `m`):

```
n          =  g k_F^3/(6 pi^2)                                                   = g Int d^3k/(2 pi)^3 1
sigma_KS   =  (g m/(4 pi^2)) [ k_F w_F - m^2 L ]                                  = g Int d^3k/(2 pi)^3 m/omega
eps_KS     =  (g/(16 pi^2)) [ k_F w_F (2 k_F^2 + m^2) - m^4 L ]                  = g Int d^3k/(2 pi)^3 omega
P_KS       =  (g/(48 pi^2)) [ k_F w_F (2 k_F^2 - 3 m^2) + 3 m^4 L ]              = g Int d^3k/(2 pi)^3 k^2/(3 omega)
```

Each closed form is proved equal to its integral: its `k_F`-derivative is the integrand times
`g k_F^2/(2 pi^2)` and it vanishes at `k_F = 0`; independently, Mathematica's `Integrate` returns
the same function (with `ArcTanh[k_F/w_F]`, which equals `L`); and a numerical quadrature at
`k_F = 3/2`, `m = 1`, `g = 8` agrees to `1e-12` (a cross-check; the proof is the symbolic one).
**[proved VII §29]**

- `KOHN-SHAM [definition]: the degeneracy g = 8 -- per momentum the positive-frequency eigenspace has rank 8 (Section 28's P_{+,+} + P_{+,-}), four flavours times two spins`
- `KOHN-SHAM [THE RESULT]: each closed form has k_F-derivative (g/(2 pi^2)) k_F^2 f(k_F) with f = 1, m/omega, omega, k^2/(3 omega), and vanishes at k_F = 0 -- so it IS the integral g Int d^3k/(2 pi)^3 f`
- `KOHN-SHAM [has content]: Integrate returns the same functions, with ArcTanh[k_F/w_F] in place of L -- and ArcTanh[k_F/w_F] == L (equal derivatives, both 0 at k_F = 0)`
- `KOHN-SHAM [control]: numerical quadrature agrees at k_F = 3/2, m = 1, g = 8 to 1e-12 (a cross-check; the proof is the symbolic one above)`

The exported closed forms at `g = 8` (`kF` = `k_F`, `m` = `m`; `provenance-latex/generated/fermion_fable_eos.txt`, verbatim):

```
n = (4*kF^3)/(3*Pi^2)
\sigma_{KS} = (2*m*(kF*Sqrt[kF^2 + m^2] - m^2*Log[(kF + Sqrt[kF^2 + m^2])/m]))/Pi^2
\varepsilon_{KS} = (kF*Sqrt[kF^2 + m^2]*(2*kF^2 + m^2) - m^4*Log[(kF + Sqrt[kF^2 + m^2])/m])/(2*Pi^2)
P_{KS} = (kF*(2*kF^2 - 3*m^2)*Sqrt[kF^2 + m^2] + 3*m^4*Log[(kF + Sqrt[kF^2 + m^2])/m])/(6*Pi^2)
rho = eps_KS + W - sigma W',  P_obs = P_KS + sigma W' - W,  P_hid = sigma W' - W,  rho + P_obs = wF n,  wF = Sqrt[kF^2 + m^2]
w = P_KS/eps_KS in [0, 1/3] for the mass term W = m sigma (w -> kF^2/(5 m^2) as kF/m -> 0, w -> 1/3 as kF/m -> Infinity)
```

**The identities that organize them:**

```
eps_KS + P_KS  ==  w_F n                 (the zero-temperature Gibbs relation, chemical potential mu = w_F)
eps_KS - 3 P_KS  ==  m sigma_KS          (the trace identity)
d eps_KS/dm  ==  sigma_KS,     d eps_KS/dk_F  ==  w_F dn/dk_F
```

**[proved VII §29]** `KOHN-SHAM [THE RESULT]: eps + P == w_F n (Gibbs), eps - 3 P == m sigma (trace), d eps/dm == sigma, d eps/dk_F == w_F dn/dk_F`

### 8.5 The numerically stable forms

The closed forms cancel catastrophically for `x = k_F/|m| << 1`: `eps ~ m n`, `sigma ~ n` and
`P ~ n k_F^2/(5m)` are small differences of large terms. The solver therefore uses three regimes,
all written with the integral representations
`S(x) = 2 Int_0^x t^2/Sqrt[1+t^2]`, `E(x) = 8 Int_0^x t^2 Sqrt[1+t^2]`, `Q(x) = 8 Int_0^x t^4/Sqrt[1+t^2]`,
with `sigma = g m^3 S/(4 pi^2)`, `eps = g m^4 E/(16 pi^2)`, `P = g m^4 Q/(48 pi^2)`
[file: `fable-cosmology/rust/fable_fermion/src/kohn_sham.rs`, module documentation and constants
`X_LO = 0.6`, `X_HI = 100.0`]:

| regime | form used |
|---|---|
| `x < X_LO = 0.6` | the convergent binomial series (radius 1) in `x^2`, e.g. `eps = |m| n [1 + (3/10) x^2 − (3/56) x^4 + ...]`, `sigma = sgn(m) n [1 − (3/10) x^2 + ...]` |
| `0.6 <= x <= X_HI = 100` | the closed forms (with `asinh x = L`), losing at most about 1.3 digits at `x = 0.6` |
| `x > 100` | the ultra-relativistic series in `y = |m|/k_F`, with the logarithm kept exact |
| `m = 0` exactly | `sigma = 0`, `eps = 3P = g k_F^4/(8 pi^2)` |

The series coefficients are `binom(−1/2, j)` for `S` and `Q` and `binom(1/2, j)` for `E`:
`S = Sum_j 2 binom(−1/2, j) x^(2j+3)/(2j+3)`, `E = Sum_j 8 binom(1/2, j) x^(2j+3)/(2j+3)`,
`Q = Sum_j 8 binom(−1/2, j) x^(2j+5)/(2j+5)` (the `series_nr` function of the same file). The commit
that finished the solver (`c5892bd`) records that these agree with quadrature to `1e-12` from
`x = 1e-8` to `1e6`, and that `cargo test --release` passes 21 + 8 tests, among them
`kohn_sham::tests::fermi_integrals_match_quadrature` and
`kohn_sham::tests::series_and_closed_forms_are_continuous_at_the_switch_points`. After the defect
fixes of `2bc936d` the final solver passes 34 of 34 tests (23 unit, 11 integration), these two among
them [commit `2bc936d`; the `#[test]` functions of `src/*.rs` and `tests/cosmology.rs`]. (The design review
had proposed a switch at `x = 0.25`; the implemented switch is `0.6`.)

### 8.6 The mean field

With `W(sigma) := V(H sigma)`, the gap equation `m = W'(sigma)` and self-consistency
`sigma = sigma_KS(k_F, m)`:

```
rho    =  eps_KS + W - sigma W'
P_obs  =  P_KS + sigma W' - W
P_hid  =  P_x0  =  sigma W' - W                  (along x0 and along x5, x6, x7: zero modes carry no kinetic pressure)
rho + P_obs  ==  w_F n        (exact)
d rho/dn     ==  w_F + (sigma_KS - sigma) W'' sigma'(n),   i.e.  == w_F  at the self-consistent point
```

**[proved VII §29]** `MEAN FIELD [THE RESULT]: rho = eps + W - sigma W', P_obs = P_KS + sigma W' - W give rho + P_obs == w_F n exactly; and d rho/dn == w_F + (sigma_KS - sigma) W'' sigma'(n), i.e. == w_F at the self-consistent point sigma = sigma_KS (m = W'(sigma) throughout)`

The split `rho = eps_KS + U` with `U := W − sigma W'` separates a **quasiparticle** part
(`eps_KS`, `P_KS`, with `0 <= P_KS/eps_KS <= 1/3`) from a **mean-field condensate** `U`, which has
`P = −U` in the observed and in the hidden directions alike: an 8-dimensional vacuum-like energy that
varies with `sigma` [derived here from the formulas above].

### 8.7 The classical limit is the non-relativistic limit, and the sign rule

At the self-consistent point the trace identity gives, **exactly**,

```
rho    ==  W(sigma) + 3 P_KS
P_obs  ==  ( sigma W'(sigma) - W(sigma) ) + P_KS
```

that is, Part VI's `rho = V(s)`, `P = s V' − V` (with `s = H sigma`) plus the degeneracy pressure and
three times it. Part VI is recovered exactly in the limit `P_KS/eps_KS -> 0`, which is
`k_F/|m| -> 0`: the cold, **non-relativistic** limit of the Fermi sea. (It is not "`k_F -> 0` at fixed
`n`", which is impossible, and not a coherent zero mode, which the Pauli principle forbids.)
**[proved VII §29]** `CLASSICAL LIMIT [THE RESULT]: at the self-consistent point rho == W + 3 P_KS and P_obs == (sigma W' - W) + P_KS exactly (sigma = sigma_KS, m = W'); Part VI's rho = V(s), P = s V' - V is the limit P_KS/eps_KS -> 0, i.e. k_F/m -> 0`

Expanded in `x = k_F/|m|` with the series of 8.5 and `W' = m` [derived here]:

```
sigma  =  sgn(m) n [ 1 - (3/10) x^2 + ... ]
rho    =  W( sgn(m) n ) + (3/10) n k_F^2/|m| + ...
P_obs  =  [ sigma W' - W ] + n k_F^2/(5 |m|) + ...
P_hid  =  sigma W' - W
```

(`rho = |m| n (1 + (3/10)x^2) + W(sigma) − |m| n (1 − (3/10)x^2)` with
`W(sigma) = W(sgn(m) n) − (3/10) |m| n x^2 + ...`.) **The sign rule:** self-consistency forces
`sign(sigma) = sign(m) = sign(W')`. This removes the Part VI branch `M s > 0`. For the author's mass
term `W = −2 M sigma` (`V = −(2M/H) s`, `m = −2M`), `rho -> 2 |M| n > 0` in the classical limit.

### 8.8 The author's mass term: `w` falls from 1/3 to 0

For `W = m sigma` (`V = −(2M/H) s` gives `m = −2M`), `W − sigma W' = 0`, so

```
rho = eps_KS > 0,       P_obs = P_KS >= 0,       0 <= w = P_KS/eps_KS <= 1/3
```

and `w` depends only on `x = k_F/|m|`: `w = I2/(3 I1)` with the `m = 1` integrals
`I1 = (1/8)(x w_x (2x^2 + 1) − Log[x + w_x])`, `I2 = (1/8)(x w_x (2x^2 − 3) + 3 Log[x + w_x])`,
`I3 = (1/2)(x w_x − Log[x + w_x])`, `w_x = Sqrt[x^2 + 1]`. `w` rises **monotonically**, since
`dw/dx = x^2 Delta/(3 w_x I1^2)` with `Delta = x^2 I1 − w_x^2 I2`, `Delta(0) = 0` and
`Delta' = 2 x I3 > 0`, from `w -> 0` (`x -> 0`, `w = x^2/5 + O(x^4)`: dust) to `w -> 1/3`
(`x -> infinity`: radiation). As a gas of fixed particle number cools, `w` falls from 1/3 to 0.

**The classical sign problem disappears.** Part VI needed `M s < 0` for `rho = −(2M/H) s > 0`.
Quantum mechanically `sigma_KS = g Int m/omega` is **odd** in `m`, and
`m sigma_KS = (g m^4/(2 pi^2)) I3(k_F/|m|) >= 0` for either sign of `m`. With `m = −2M`,
`M sigma_KS <= 0`: exactly the branch `M s < 0` that Part VI had to assume. **[proved VII §29]**

- `AUTHOR'S MASS TERM [THE RESULT]: W = m sigma gives W - sigma W' == 0, so rho == eps_KS, P == P_KS, and w = P_KS/eps_KS depends only on x = k_F/m: w == I2/(3 I1), I_n the m = 1 integrals`
- `AUTHOR'S MASS TERM [THE RESULT]: 0 <= w <= 1/3 -- P_KS >= 0 (I2' = x^4/w_x > 0, I2(0) = 0) and eps - 3P = m sigma = (g m^4/(2 pi^2)) I3 >= 0 (I3' = x^2/w_x > 0, I3(0) = 0)`
- `AUTHOR'S MASS TERM [THE RESULT]: w rises MONOTONICALLY -- dw/dx == x^2 Delta/(3 w_x I1^2) with Delta = x^2 I1 - w_x^2 I2, Delta(0) = 0 and Delta' = 2 x I3 > 0 -- from w -> 0 (x -> 0, w = x^2/5 + O(x^4): dust) to w -> 1/3 (x -> infinity: radiation)`
- `AUTHOR'S MASS TERM [has content]: the classical sign problem disappears -- sigma_KS = g Int m/omega is ODD in m and m sigma_KS = (g m^4/(2 pi^2)) I3(k_F/|m|) >= 0 for either sign, so with m = -2M: M sigma_KS <= 0, the branch M s < 0 that Part VI had to assume`

### 8.9 `w >= −1` always: no phantom crossing for the quantized fable

From `rho + P_obs = w_F n` (8.6), which is exact, and `w_F n >= 0`:

```
w_f + 1  =  (rho + P_obs)/rho  =  w_F n / rho  >=  0          wherever rho > 0
```

(`w_f` is the fable's equation of state `w = <P_obs>/<rho>` of 8.1; `w_F = Sqrt[k_F^2 + m^2]` is the
Fermi energy.)

The quantized fermion fable **cannot cross the phantom divide**, for any potential `W` [derived
here from `MEAN FIELD [THE RESULT]: rho = eps + W - sigma W', P_obs = P_KS + sigma W' - W give rho + P_obs == w_F n exactly; and d rho/dn == w_F + (sigma_KS - sigma) W'' sigma'(n), i.e. == w_F at the self-consistent point sigma = sigma_KS (m = W'(sigma) throughout)`]. The classical Part VI crossing at `V'(s1) = 0`
(section 2.12.7) is unreachable. In the quantum theory `rho + P_obs = w_F n > 0` at every non-zero
density, whatever the value of `m`. And for the `expdamp` potential the gap equation keeps
`0 < sigma < min(n, s1)` strictly, so `m = W'(sigma)` never reaches the classical crossing point at
finite density: `sigma -> s1` and `m -> 0` only as `n -> infinity` (design review DFT-6; solver tests
`kohn_sham::tests::expdamp_pins_sigma_below_s1_and_mass_goes_to_zero_at_high_density` and
`kohn_sham::tests::no_phantom_crossing_rho_plus_p_obs_is_nonnegative`). The classical phantom
crossing of 2026-09-16 therefore does **not** survive quantization. (What an observer who fits a
cold-dark-matter-plus-dark-energy model to the coupled system can infer — an apparent crossing, when
the dust is subtracted at today's dark-matter density and the effective mass grows — is a property
of that fit, not of the fluid; it is part of the coupled system, Effort B, and is stated in section 1.)

### 8.10 On the pre-universe: the quantum gas cools, the classical field does not

Four facts, each proved on the canonical frame with `a4` free.

**(1) Charge.** The U(1) current is conserved on shell for generic `Psi(x0, x4)`, `Psibar(x0, x4)`.
For the `x0`-profile `Psi = Sqrt[Sin[6 H x0]] Psi'` with `Psi'` independent of `x0`, `Sqrt[g] j^0` is
independent of `x0` (`Sec Sin Cot = 1`), so `d_4(Sqrt[g] j^4) = 0`: the charge per coordinate volume
does not depend on `x4`, and since `Sqrt[g]` does not either, neither does the proper 8-density. The
7-volume is constant because the observed sheet grows exactly as the hidden sheet shrinks
(`q^3 p^3` is `x4`-independent). **[proved VII §29]**

- `PRE-UNIVERSE (1) [THE RESULT]: the U(1) current is conserved on shell, (1/Sqrt[g]) d_mu(Sqrt[g] j^mu) == 0, for generic Psi(x0, x4), Psibar(x0, x4)`
- `PRE-UNIVERSE (1) [THE RESULT]: for Psi = Sqrt[Sin] Psi'(x4), Sqrt[g] j^0 is x0-independent (Sec Sin Cot == 1), so d_4(Sqrt[g] j^4) == 0 on shell; and Sqrt[g] and q^3 p^3 are x4-independent`

**(2) Which `x4`-only fields solve the equations:** `V'' s' = 0` (section 5.8).

**(3) Redshift.** A mode `Psi = Sqrt[Sin] u(x4) Exp[i k x1]` (coordinate momentum `k` along the
observed sheet) obeys `T16[4] u' + i (k/q) T16[1] u = H V' u` exactly (mass term, `V'` constant): its
**physical** momentum is `k/q`, and `d Log[k/q]/dx4 = H a4'(H x4) = −H_obs`. The observed-sheet momenta
redshift as `Exp[a4] ~ 1/a`, and the instantaneous frequency is `Sqrt[k^2/q^2 + m^2]`
(`E^2 = omega^2` at `k_phys = k/q`, section 6.10). **[proved VII §29]**

- `PRE-UNIVERSE (3) [THE RESULT]: for Psi = Sqrt[Sin] u(x4) Exp[i k x1] the field equation (mass term, V' = constant) is Sqrt[Sin] Exp[i k x1] (T16[4] u' + i (k/q) T16[1] u - H V' u): the physical momentum is k/q`
- `PRE-UNIVERSE (3) [THE RESULT]: d Log[k/q]/dx4 == H a4'[H x4] == -H_obs (observed momenta redshift as Exp[a4]), and E^2 == (k^2/q^2 + m^2) ID16 at the physical momentum`

**(4) Cooling.** The occupied coordinate momenta are fixed (the mode labels are conserved; the
`x4`-dependence of `q` only mixes `±omega`, a Bogoliubov effect that vanishes adiabatically). So
`x = k_F,phys/m` falls as `Exp[a4]`: `d Log[x]/dx4 = H a4'`, and since `w(x)` is increasing,
`sign(dw/dx4) = sign(a4')`. In the regime `a4' < 0` (the observed sheet expanding, the sign hypothesis
of Part VI, section 2.11) the quantum fable gas **cools**, `w: 1/3 -> 0`, even though its 8-density
does not dilute. The classical Part VI fable, by contrast, has `ds/dx4 = 0` on the rescaled
solutions and `w = s V'/V − 1` **frozen**. **[proved VII §29]**

- `PRE-UNIVERSE (4) [THE RESULT]: x = k_F,phys/m = x_c/(q m) obeys d Log[x]/dx4 == H a4'[H x4]; since dw/dx > 0, dw/dx4 = w'(x) x H a4' < 0 exactly when a4' < 0 (the observed sheet expanding): the quantum gas COOLS`
- `PRE-UNIVERSE (4) [control]: the classical Part VI fable does NOT cool -- ds/dx4 == 0 on its rescaled solutions (Part VI's result, re-asserted), and its w = s V'/V - 1 is a function of s alone: frozen`

| quantity | classical fable (Part VI) | fermion fable (Part VII, Kohn–Sham, mass term) |
|---|---|---|
| `rho` | `V(s)` | `eps_KS(k_F, m) > 0` |
| `P` (observed) | `s V' − V` (`= 0`: dust) | `P_KS` in `[0, rho/3]` |
| `w` | `s V'/V − 1`, frozen (`ds/dx4 = 0`) | `P_KS/eps_KS`: `1/3 -> 0` as the observed sheet expands |
| 8-density | constant | constant (charge per coordinate volume conserved) |

(This table is the notebook's displayed summary at the end of Section 29 [displayed VII §29].)

Finally, **`a4` is still undefined** after Part VII: `PART VII [control]: a4 is STILL UNDEFINED -- nothing in Part VII gave it a value`

## 9. The canonical spin connection: a complete discussion

This section covers the canonical spin connection of the 4+4 pre-universe in full: the frame it
comes from, how it is computed, every non-zero component, its 16×16 spinor form, the
gauge-covariant derivative of the 16-component spinor, how it relates to the three bridges of
Part IV and to the fable-5.1 (Weitzenböck) bridge of Part V, and what it does and does not do for
the complex fermion fable. It stands on its own. Every object is defined here and every result
is restated here, with the place where it is proved.

Throughout, "Section n" (capital S) means a section of the notebook. The numbered parts of this
discussion are called "subsections" 9.1–9.13.

---

### 9.1 Sources, and how the status of each statement is marked

**Where the proofs live.** The proofs are in the Mathematica notebook
`claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb`. That notebook is generated from cell
manifests and is never edited by hand:

| manifest | Part | Sections | subject |
|---|---|---|---|
| `claude-fable/cells_part1.wl` | I | 0–4 | session, coordinates, `eta4488`, `tau`, `sigma` |
| `claude-fable/cells_part2.wl` | I | 5–9 | `T16`, `sigma16`, `SAB`, matrix bases, Cartan triality |
| `claude-fable/cells_part3.wl` | II | 10–14 | the author's physics reproduced (`Psi16`, `La`, `eLa`) |
| `claude-fable/cells_part4.wl` | III, IV | 15–17, 18–20 | frame, Christoffel symbols, canonical spin connection, spinor covariant derivative; the three bridges |
| `claude-fable/cells_part5.wl` | V | 21–22 | the fable-5.1 (Weitzenböck) bridge; the master comparison |
| `claude-fable/cells_part6.wl` | VI | 23–25 | fableScalar and the real (classical) fable spinor |
| `claude-fable/cells_part7.wl` | VII | 26–29 | the complex fermion fable (new): refinement, Lagrangian and field equations, canonical quantization, energy–momentum tensor |
| `claude-fable/cells_part8.wl` | VIII | 30–33 | fable as a source of the Einstein equations of the primordial field (the coupled system; its spin connection is Section 32) |

The run of Parts I–VI, `claude-fable/run_fable51_part6.log`, evaluates 172 Input cells straight
out of the `.nb`. It reports `Assertions run: 358   passed: 358   failed: 0` and `cells w/ msgs   : 0`,
with `identities accepted on numerical evidence alone : 0` and `non-vanishing witnesses : 27`.
The Part VII run is recorded in `claude-fable/run_fermion_fable_part7.log`. It evaluates 198 Input cells
and reports `Assertions run: 528   passed: 528   failed: 0` and `cells w/ msgs   : 0`, with
`identities accepted on numerical evidence alone : 0` and `non-vanishing witnesses : 38`
(Part VII adds 170 assertions and 11 witnesses to Parts I–VI). The acceptance run of Part VIII,
`claude-fable/run_fermion_fable_part8.log`, reported `Assertions run: 642   passed: 642   failed: 0`;
its two comparisons of the Rust solver with the Mathematica reference runs were skipped, because the
solver's CSVs did not exist yet. The final run of the whole notebook,
`claude-fable/run_fermion_fable_final.log`, evaluates 217 Input cells and reports
`Assertions run: 644   passed: 644   failed: 0` and `cells w/ msgs   : 0`, with
`identities accepted on numerical evidence alone : 0` and `non-vanishing witnesses : 46`.

**How an identity is certified.** Each identity is certified in up to three stages:

1. exact structural equality (the entry is literally `0`);
2. `Simplify` under the geometric assumptions, with a 5-second budget;
3. a numerical check at three rational probe points to 30 significant digits.

Stage 3 has two uses, and the notebook counts them separately. The first is to accept an
identity. The notebook reports **zero** of those, and its last assertion fails if that count is
ever non-zero, so every identity quoted below is closed symbolically. The second is to witness
that something is **not** zero, through `cfNonZeroWitnessQ`. A witness succeeds only if every
entry evaluates to an actual number at some probe point and at least one of them exceeds
`10^-10` in magnitude. That is a complete proof of non-vanishing.

The probe functions used in stage 3 are test inputs only, never definitions:
`a4 -> Function[u, 3/7 + u/5 + Sin[u]/11]`, a probe for the boost rapidity of Bridge 1, and probe
values of the Bridge 3 parameter `lambdaOct`.

**Status marks used below.**

| mark | meaning |
|---|---|
| **[proved P §n]** `"label"` or `label` | a `cfAssert` of Part P, Section n, that prints `PASS` in `run_fable51_part6.log` (Parts I–VI), `run_fermion_fable_part7.log` (Part VII) or `run_fermion_fable_final.log` (Part VIII, the final run); the label is quoted verbatim |
| **[displayed P §n]** | the printed output of a cell of Part P, Section n (a table, a count or a closed form); an output, not an assertion |
| **[prose P §n]** | stated only in prose in the notebook (a Text cell, or a comment inside an Input cell), not asserted |
| **[derived here]** | a short derivation carried out in this section from results marked above, with every step shown |


The notebook grades its own assertion labels. `[definition]` means true by construction.
`[structural]` means true for any input of the right shape. `[solver regression]` is a check of
the code, not of the geometry. `[has content]` could have failed. `[THE RESULT]` marks a headline
result. `[control]` shows that the wrong alternative fails.

### 9.2 Conventions

- Coordinates `X = {x0, x1, ..., x7}`. The Wolfram array position is the coordinate index plus
  one, so `x4` is entry 5. Greek indices are curved and Latin indices are flat; both run 0..7.
  `x4` is the observer's time (`g44 = -1`), `x1, x2, x3` are the observed 3-space, `x0` is the
  hidden spacelike direction, and `x5, x6, x7` are the hidden timelike sheet. The notebook's own
  words for `x5..x7` are "the superluminal deflating directions".
- Flat metric: `eta4488 = DiagonalMatrix[{1,1,1,1,-1,-1,-1,-1}]`. **[proved I §2]**
  `"signature of eta4488 is (4,4)"`, `"eta4488 . eta4488 == ID8"`.
- The 8×8 generators have `tau[0] = ID8`. The conjugates are
  `taubar[A] = sigma . Transpose[sigma . tau[A]]`, with `sigma = ArrayFlatten[{{0,ID4},{ID4,0}}]`
  (**[proved I §4]** `"sigma . sigma == ID8"`, `"sigma is symmetric"`). It follows that
  `taubar[0] = ID8`.
- The 16×16 Dirac matrices are E. A. Lord's reduced Brauer–Weyl doubling,
  `T16[A] = ArrayFlatten[{{0, taubar[A]}, {tau[A], 0}}]` for `A = 0..7`. They are real, and
  `T16[0] = ArrayFlatten[{{0,ID8},{ID8,0}}]`. **[proved I §5]**
  `"{T16[A], T16[B]}/2 == eta4488[[A+1,B+1]] ID16"`. Throughout, `T16[a]` **is** `gamma^a`, with the flat
  index **up**. Since `eta4488` is its own inverse, `gamma_a = eta_{ab} T16[b]` differs from
  `T16[a]` by the sign `eta_aa`.
- Spinor metric: `sigma16 = T16[0].T16[1].T16[2].T16[3]`. **[proved I §5]**
  `"sigma16 == ArrayFlatten[{{-sigma,0},{0,sigma}}]"`, `"sigma16 . T16[A] is antisymmetric for A = 0..7"`,
  `"sigma16 is symmetric and sigma16 . sigma16 == ID16"`.
- Chirality: `T16[8] = T16[0].T16[1]...T16[7] = diag(-ID8, +ID8)`. **[proved I §5]**
  `"PL projects onto the upper (type-1) components, PR onto the lower (type-2) components"`.
  A 16-spinor is `Psi = (psi1, psi2)`. The upper 8 components `psi1` are a split-octonion type-1
  spinor, and the lower 8 components `psi2` are a type-2 spinor.
- so(4,4) generators: `SAB[[A+1,B+1]] = (1/4) (T16[A].T16[B] - T16[B].T16[A])`. **[proved I §5]**
  `"SAB is antisymmetric in its two flat indices"`, `"sigma16 . SAB is antisymmetric"`,
  `"T16[8] commutes with every SAB: the chiral halves are each Spin(4,4)-invariant"`,
  `"[SAB, T16] reproduces the vector representation"`.
- `H`, `K` and `M` are Protected constants of the original notebook.

### 9.3 The canonical frame (vielbein), the metric, and the volume factor

A vielbein here is simply an 8-dimensional vierbein, that is, an 8-dimensional frame field. The
canonical frame is the diagonal matrix that the original notebook records as the value of the
symbol it writes "gtrye with indices alpha and (A)" **[prose III §15]**:

```
frameCanonical = DiagonalMatrix[{Tan[6 H x0], q, q, q, 1, p, p, p}]

    q = cfQminus = Exp[-a4[H x4]] / Sin[6 H x0]^(1/6)      (observed directions x1, x2, x3)
    p = cfQplus  = Exp[+a4[H x4]] / Sin[6 H x0]^(1/6)      (hidden directions  x5, x6, x7)
```

**Rows curved, columns flat.** `frameCanonical[[mu+1, a+1]] = e_mu^a`. The coframe is the matrix
inverse, stored with the flat index on the row:
`coframeCanonical = Inverse[frameCanonical]`, `coframeCanonical[[a+1, mu+1]] = e_a^mu`.
**[proved III §15]** `"CANONICAL [structural]: frame . coframe == ID8  (certifies only that the frame is invertible)"`.

**The free function `a4`.** The original notebook never defines `a4`. It appears only inside the
recorded frame. It is carried symbolically everywhere and is **never given a value**. The
notebook prints a notice to this effect when Section 15 runs **[prose III §15]**, and Part VI ends
with **[proved VI §25]** `"PART VI [control]: a4 is STILL UNDEFINED -- nothing in Part VI gave it a value; and the FLRW scale factor aF never entered the canonical frame"`.
Every result in this section holds for an arbitrary differentiable `a4`. Below, `a4'` means
`Derivative[1][a4][H x4]`.

**Reciprocity.** `q p = 1/Sin[6 H x0]^(1/3)` does not depend on `x4`: the observed directions
contract exactly as fast as the hidden directions expand **[prose III §15]**.

**The metric.** The bridge between the curved and flat metrics is

```
[d]   g_{mu nu} = e_mu^a eta_{ab} e_nu^b        i.e.     gCanonical = frameCanonical . eta4488 . Transpose[frameCanonical]

ds^2 = Tan[6 H x0]^2 dx0^2 + q^2 (dx1^2 + dx2^2 + dx3^2) - dx4^2 - p^2 (dx5^2 + dx6^2 + dx7^2)
```

- **[proved III §15]** `"CANONICAL [definition]: g == frame . eta4488 . Transpose[frame]  (bridge [d]; this IS how g was defined, so it cannot fail)"`.
- **[proved III §15]** `"CANONICAL [has content]: g == diag(Tan[6 H x0]^2, q^2, q^2, q^2, -1, -p^2, -p^2, -p^2), the stated line element"`.
- **[proved III §15]** `"CANONICAL [has content]: Diagonal[g] == Diagonal[eta4488] * Diagonal[frame]^2 exactly"` (Sylvester's law made explicit).
- **[proved III §15]** `"CANONICAL [has content]: g has signature (4,4), GIVEN a4 real and 0 < 6 H x0 < Pi/2"`.
- **[proved III §15]** `"Inverse[g] == Transpose[coframe] . eta4488 . coframe"`, `"g is symmetric"`, `"the metric is non-degenerate"`.

**The volume factor.** Section 15 displays `Det[g] = Sec[6 H x0]^2` and
`Sqrt[Abs[Det[g]]] = Abs[Sec[6 H x0]]` **[displayed III §15]**. **[proved V §21]**
`"FABLE-5.1: det g == Sec[6 H x0]^2  (positive, as signature 4+4 requires)"`. On the domain
`0 < 6 H x0 < Pi/2` the root is `Sec[6 H x0]`. From Part V on, the notebook uses
`sqrtDetgTele = Sec[6 H x0]` rather than `Abs[Sec[...]]`, so that `Abs` is never differentiated
**[prose V §21]**. The same result follows from the frame directly **[derived here]**:
`det e = Tan[6Hx0] q^3 p^3 = Tan[6Hx0]/Sin[6Hx0] = Sec[6Hx0]`. The volume factor does not depend on
`x4`.

**The curved Dirac matrices.** `gammaCurvedCanonical[[mu+1]] = Sum_a coframe[[a,mu]] T16[a]`.
The frame is diagonal, so **[derived here]**

```
gamma^0 = Cot[6 H x0] T16[0]
gamma^j = (1/q) T16[j] = E^{a4} Sin[6 H x0]^(1/6) T16[j]         j = 1, 2, 3
gamma^4 = T16[4]
gamma^k = (1/p) T16[k] = E^{-a4} Sin[6 H x0]^(1/6) T16[k]        k = 5, 6, 7
```

- **[proved III §17]** `"{gammaCurved[mu], gammaCurved[nu]} == 2 gInv[mu,nu] ID16"`.
- **[proved VI §24]** `"FABLE [has content]: (gamma^4)^2 == -ID16, so gamma^4 d_4 Psi' == H V'(s) Psi' is solved by d_4 Psi' == -H V'(s) gamma^4 Psi'"`.

### 9.4 The generalized Christoffel symbols

These are the Levi-Civita symbols of `g`:

```
Gamma^rho_{mu nu} = (1/2) g^{rho s} ( d_mu g_{s nu} + d_nu g_{s mu} - d_s g_{mu nu} )
```

`cfChristoffel[g, ginv, coords]` computes the first derivatives `dg[[k,m,p]] = D[g[[m,p]], coords[[k]]]`
once, reuses them in the triple loop, and simplifies each entry under the notebook's assumptions.
The result is `GammaCanonical[[rho+1, mu+1, nu+1]]`. Section 16 lists its 37 non-zero entries
(out of 512) **[displayed III §16]**:

```
Gamma[0;0,0] = 12*H*Csc[12*H*x0]
Gamma[0;j,j] =  (H*Cos[6*H*x0]^3)/(E^(2*a4[H*x4])*Sin[6*H*x0]^(10/3))          j = 1,2,3
Gamma[0;k,k] = -(E^(2*a4[H*x4])*H*Cos[6*H*x0]^3)/Sin[6*H*x0]^(10/3)             k = 5,6,7
Gamma[j;0,j] = Gamma[j;j,0] = -H*Cot[6*H*x0]                                    j = 1,2,3
Gamma[j;j,4] = Gamma[j;4,j] = -H*a4'[H*x4]                                      j = 1,2,3
Gamma[4;j,j] = -(H*a4'[H*x4])/(E^(2*a4[H*x4])*Sin[6*H*x0]^(1/3))                j = 1,2,3
Gamma[4;k,k] = -(E^(2*a4[H*x4])*H*a4'[H*x4])/Sin[6*H*x0]^(1/3)                  k = 5,6,7
Gamma[k;0,k] = Gamma[k;k,0] = -H*Cot[6*H*x0]                                    k = 5,6,7
Gamma[k;4,k] = Gamma[k;k,4] =  H*a4'[H*x4]                                      k = 5,6,7
```

Here `Gamma[r;m,n]` stands for `Gamma^r_{mn}`. The count is
`1 + 3 + 3 + 6 + 6 + 3 + 3 + 6 + 6 = 37`.

- **[proved III §16]** `"Gamma is symmetric in its two lower indices (torsion-free affine connection)"`. This check is structural: swapping the two lower indices in the formula reproduces the formula whenever `g` is symmetric.
- **[proved VI §23]** `"HELPER [solver regression]: cfCovariantDivergence of the metric itself vanishes (metric compatibility of Section 16's Gamma; a wrong index slot in the helper fails this)"`.

### 9.5 The vielbein postulate, and how `cfSpinConnection` solves it

The spin connection is fixed by the zero-torsion (Levi-Civita) condition, written as the
**vielbein postulate**. The total covariant derivative of the frame vanishes when `Gamma` acts on
the curved index and `omega` acts on the flat index **[prose III §16]**:

```
D[e[nu,a], x[mu]] - Gamma[rho,mu,nu] e[rho,a] + omegaMixed[mu,a,b] e[nu,b]  ==  0 ,
```

Here `e[nu,a] = e_nu^a` and `omegaMixed[mu,a,b] = omega_mu^a_b`. Contracting with the coframe
frees `nu`:

```
omegaMixed[mu,a,c] = Sum over nu of ( Sum over rho of Gamma[rho,mu,nu] e[rho,a]  -  D[e[nu,a], x[mu]] ) * coframe[[c,nu]]
```

The notebook's solver is exactly this formula (Section 16):

```wolfram
cfSpinConnection[frame_, coords_, etaFlat_, gamma_] :=
 Module[{n = Length[coords], cofr, dE},
  cofr = cfSimp[Inverse[frame]];                                  (* cofr[[a,nu]] = e_a^nu *)
  dE = Table[D[frame[[nu, a]], coords[[mu]]], {mu, n}, {nu, n}, {a, n}];
  Table[
    cfSimp[Sum[(Sum[gamma[[r, mu, nu]] frame[[r, a]], {r, n}] - dE[[mu, nu, a]]) cofr[[c, nu]],
      {nu, n}]],
    {mu, n}, {a, n}, {c, n}]];

cfLowerFirstFlat[om_, etaFlat_] := Module[{n = Length[etaFlat]},
  Table[Sum[etaFlat[[a, c]] om[[mu, c, b]], {c, n}], {mu, n}, {a, n}, {b, n}]];

omegaCanonicalMixed = cfSpinConnection[frameCanonical, X, eta4488, GammaCanonical];   (* omega_mu^a_b  *)
omegaCanonical      = cfLowerFirstFlat[omegaCanonicalMixed, eta4488];                 (* omega_{mu a b} *)
```

The same routine produces every connection of the notebook that comes from the vielbein
postulate: the canonical one, those of Bridges 1 and 2, the Levi-Civita part `omegaTriLC` of
Bridge 3 (to which Section 20 then adds the contortion), and the fable-5.1 connection. The
Christoffel symbols are computed once and passed in. So the comparisons below compare results, not
different pieces of code **[prose III §16, IV, V §21]**.

**What each certificate is worth.** The notebook grades its certificates as follows
**[prose III §16]**:

- **[proved III §16]** `"CANONICAL [solver regression]: vielbein postulate residual is zero"`.
  This is an algebraic identity of the solver. `cfSpinConnection` contracts the postulate with
  `Inverse[frame]` and `cfVielbeinResidual` contracts it back with `frame`, and the two cancel for
  any affine connection and any invertible frame.
- **[proved III §16]** `"CANONICAL [structural]: torsion vanishes"`. Once the residual is zero,
  this reduces to the symmetry of `Gamma` in its lower indices, which is itself structural. The
  torsion 2-form used is
  `T^a_{mu nu} = d_mu e_nu^a - d_nu e_mu^a + omega_mu^a_b e_nu^b - omega_nu^a_b e_mu^b` (`cfTorsion`).
- **[proved III §16]** `"CANONICAL [has content]: omega[mu,a,b] == -omega[mu,b,a]  (metric compatibility)"`.
  This is not imposed anywhere. It holds only because the affine connection fed in is the
  Levi-Civita connection of the metric the frame builds, so a wrong Christoffel symbol would
  break it. The connection is therefore `so(4,4)`-valued.
- **[proved III §16]** `"INDEPENDENT CHECK: the frame-only derivation reproduces omegaCanonical exactly"`
  and `"INDEPENDENT CHECK: and it is antisymmetric in its two raised flat indices"`. The
  connection is re-derived from the frame alone by the anholonomy formula, which never mentions
  `Gamma` or `g`:

  ```
  omega_mu^{ab} = (1/2) e^{a nu} ( d_mu e_nu^b - d_nu e_mu^b )
                - (1/2) e^{b nu} ( d_mu e_nu^a - d_nu e_mu^a )
                - (1/2) e^{a rho} e^{b sig} ( d_rho e_sig^c - d_sig e_rho^c ) eta_{cd} e_mu^d
  ```

  (`cfSpinConnectionFromFrame`, with `e^{a nu} = (Inverse[eta] . coframe)[[a,nu]]`).
- The canonical frame is diagonal and so equals its own transpose. Section 16 therefore cannot
  detect a transposition of the frame's two slots. Section 18 closes that gap on a frame that is
  not symmetric (the canonical frame times a constant boost of rapidity `1/3`):
  **[proved IV §18]** `"the slot-test frame is genuinely not symmetric"`,
  `"INDEPENDENT CHECK on a non-symmetric frame: the two solvers agree, so the curved/flat slots are placed correctly in both"`,
  `"and the result is the canonical connection conjugated by the constant boost, as the gauge law demands"`.

### 9.6 The canonical spin connection: all its non-zero components

`omegaCanonical` has **24 non-zero components out of 512** **[displayed III §16]**. They are
listed by `cfShowConnection[omegaCanonical, "omega"]`. In subsections 9.6 and 9.7 only, write
`c = Cos[6 H x0]`, `s = Sin[6 H x0]` and `A = a4[H x4]`. For `j = 1,2,3` and `k = 5,6,7`, with all indices down,
`omega[mu; a, b] = omega_{mu a b} = omegaCanonical[[mu+1, a+1, b+1]]`:

| component (both flat indices down) | value |
|---|---|
| `omega[j; 0,j] = -omega[j; j,0]` | `H c^2 / (E^A s^(13/6))` |
| `omega[j; 4,j] = -omega[j; j,4]` | `H a4' / (E^A s^(1/6))` |
| `omega[k; 0,k] = -omega[k; k,0]` | `-E^A H c^2 / s^(13/6)` |
| `omega[k; 4,k] = -omega[k; k,4]` | `E^A H a4' / s^(1/6)` |

That gives `6 directions x 2 planes x 2 orderings = 24` components. Every other component is zero.
Part VII re-asserts the count and the pattern: **[proved VII §27]** `SPIN CONNECTION [has content]: metric compatible (omega_mu^{ab} antisymmetric) and every non-zero component is omega_mu^{mu 0} or omega_mu^{mu 4} (up to antisymmetry): omega_0 == omega_4 == 0`.
That label writes the connection with both flat indices up, `omega_mu^{ab}`. Neither the
antisymmetry nor the pattern of non-zero components depends on that position: raising both flat
indices multiplies each component by `eta_aa eta_bb = ±1` [derived here]. The **sign** of a listed
component does depend on it: raising both indices flips the components in the planes with exactly
one timelike index — `(4,j)` and `(0,k)` here — and leaves the `(0,j)` and `(4,k)` components
unchanged. That is why the table above is written with both flat indices down, as `omegaCanonical`
is, and why Part VIII, Section 32, lists the components of the connections of its dynamical frames
the same way (section 10.3).

**Structure [derived here, from the table].**

- `omega_0 = omega_4 = 0`: the connection vanishes along the hidden direction `x0` and along the
  observer's time `x4`.
- In each remaining direction `mu` (`1,2,3,5,6,7`) only the two flat planes `(0,mu)` and `(4,mu)`
  are excited.
- Whether the generator of a plane is a rotation or a boost depends on the signs of `eta4488` in
  that plane. For `j = 1,2,3`, `(0,j)` is a rotation (both directions spacelike) and `(4,j)` is a
  boost. For `k = 5,6,7`, `(0,k)` is a boost and `(4,k)` is a rotation (both directions timelike).
- The `x0`-dependent components (planes `(0,mu)`) do not involve `a4'`. The `a4`-dependent
  components (planes `(4,mu)`) are proportional to `a4'`, so they all vanish when `a4` is constant.
- No component depends on `x1, x2, x3, x5, x6, x7`. The metric, the frame and the connection are
  invariant under translations along the observed and hidden sheets.
- The **mixed** components `omega_mu^a_b = omegaCanonicalMixed` follow by raising the first flat
  index with `eta4488`. For example, `omega_j^4_j = -omega[j;4,j]` because `eta_44 = -1`.

**Curvature.** The curvature 2-form is
`R_{mu nu}^a_b = d_mu omega_nu^a_b - d_nu omega_mu^a_b + [omega_mu, omega_nu]^a_b` (`cfCurvature`).
It has **156 non-zero components** **[displayed III §16]**.
**[proved III §16]** `"CANONICAL: curvature is antisymmetric in the two spacetime indices"`.
The Ricci scalar is **[displayed III §16]**

```
RicciScalarCanonical = -3*H^2*((55 + 7*Cos[12*H*x0])*Cot[6*H*x0]^2*Csc[6*H*x0]^2 - 2*a4'[H*x4]^2)
```

This is equivalent to `-6 H^2 (24 Cot[6Hx0]^2 + 31 Cot[6Hx0]^4 - a4'[Hx4]^2)` **[derived here]**,
using `Cos[12Hx0] = 1 - 2 Sin[6Hx0]^2` and `Csc^2 = 1 + Cot^2`. It depends on `a4`
only through `a4'^2`. It is the frame-independent invariant that every bridge below is checked
against.

**Summary of the certified properties of the canonical connection.** It is metric compatible
(antisymmetric in its flat indices, a statement with content), it is torsion-free (structural),
it is reproduced exactly by an independent frame-only derivation, and it is not flat.

### 9.7 The spinor connection `Gamma_mu` and its exact normalization

The 16×16 spin-connection matrix is built by `cfSpinMatrix` in Section 17:

```wolfram
cfSpinMatrix[om_, mu_Integer] :=
  (1/8) Sum[om[[mu, a, b]] (T16[a - 1] . T16[b - 1] - T16[b - 1] . T16[a - 1]), {a, 8}, {b, 8}];
GammaSpinCanonical = Table[cfSimpArray[cfSpinMatrix[omegaCanonical, mu]], {mu, 8}];
```

It is fed `omegaCanonical`, the connection with **both flat indices down**. Since
`T16[a] = gamma^a` has its flat index **up**, the exact convention is

```
Gamma_mu = (1/8) omega_{mu ab} [gamma^a, gamma^b]
         = (1/4) omega_{mu ab} T16[a].T16[b]              (sum over all a, b = 0..7)
         = (1/2) Sum_{a<b} omega_{mu ab} T16[a].T16[b]
         = (1/2) omega_{mu ab} SAB[[a+1,b+1]]
```

The second line uses the antisymmetry of `omega_{mu ab}` and `T16[a].T16[b] = -T16[b].T16[a]`
for `a != b` **[derived here]**. The equivalent form with raised connection indices is
`(1/4) omega_mu^{ab} gamma_a gamma_b`, with `gamma_a = eta_{ab} T16[b]`.

**Index warning.** The expression `(1/4) omega_mu^{ab} T16[a].T16[b]`, with the raised connection
contracted against the unlowered `T16`, is **not** the notebook's `Gamma_mu`. It would multiply
each plane by `eta_aa eta_bb`, and so flip the sign of the `(4,j)` and `(0,k)` terms
**[derived here]**.

The coefficient and the sign are not conventions left open. They are fixed against the vielbein
postulate:

- **[proved III §17]** `"[definition] (1/8) omega [gamma^a, gamma^b] == (1/2) omega SAB  (SAB is defined as (1/4)[gamma,gamma], so this cannot fail)"`.
- **[proved III §17]** `"[has content] the spinor connection is compatible with omega: [Gamma^spin_mu, gamma^a] + omega_mu^a_b gamma^b == 0"`.
  The spinor connection rotates the Dirac matrices exactly as `omega` rotates a vector. With
  `1/4` in place of `1/8`, or with the opposite sign, this check fails.
- **[proved III §17]** `"[control] with the opposite sign the compatibility check FAILS (witnessed): the sign is fixed by the vielbein postulate, not free"`.
- **[proved VII §27]** the normalization used throughout Part VII, `SPIN CONNECTION [definition]: Gamma^spin_mu == Sum_{a<b} omega_mu,ab (1/2) T16[a] T16[b]`.

**The explicit matrices [derived here, from the table of subsection 9.6 and the formula above].**
Only the planes `(0,mu)` and `(4,mu)` contribute. For `j = 1,2,3` the ordered pair
`(j,4)` gives `omega_{j j4} T16[j].T16[4] = omega_{j4j} T16[4].T16[j]`, so

```
Gamma_0 = Gamma_4 = 0
Gamma_j = (1/2) [ H c^2/(E^A s^(13/6)) T16[0].T16[j]  +  H a4'/(E^A s^(1/6)) T16[4].T16[j] ]         j = 1,2,3
Gamma_k = (1/2) [ -E^A H c^2/s^(13/6)  T16[0].T16[k]  +  E^A H a4'/s^(1/6)  T16[4].T16[k] ]         k = 5,6,7
```

The provenance script `claude-fable/prov03_covariant_derivative.wls` (log
`claude-fable/prov03.log`) prints the non-zero directions of `Gamma^spin` as
`{1, 2, 3, 5, 6, 7}`, each with 32 non-zero entries. That matches the two terms above: each
`T16[a].T16[b]` with `a != b` is a signed permutation matrix with 16 entries, and the two terms
occupy different positions.

**The direct-sum structure.** Every `T16[a]` is off-diagonal in the type-1/type-2 split, so every
product of two of them is block-diagonal:
`T16[A].T16[B] = ArrayFlatten[{{taubar[A].tau[B], 0}, {0, tau[A].taubar[B]}}]`. The spin
connection therefore never mixes the two split-octonion spinors.

- **[proved III §17]** `"Gamma^spin[mu] is block diagonal: it never mixes type-1 with type-2"`.
- **[proved III §17]** `"the type-1 block is (1/8) omega (taubar^a tau^b - taubar^b tau^a)"`.
- **[proved III §17]** `"the type-2 block is (1/8) omega (tau^a taubar^b - tau^b taubar^a)"`.

Below, the upper (type-1) block is written `Gamma^(1)_mu` and the lower (type-2) block
`Gamma^(2)_mu`. In the notebook these are `GammaSpinType1` and `GammaSpinType2`.

### 9.8 The gauge-covariant derivative of the 16-component spinor

```
D_mu Psi  =  d_mu Psi + Gamma_mu . Psi              cfDcov16[psi, mu] = D[psi, X[[mu]]] + GammaSpinCanonical[[mu]] . psi
D_mu psi1 =  d_mu psi1 + Gamma^(1)_mu . psi1        cfDcovType1
D_mu psi2 =  d_mu psi2 + Gamma^(2)_mu . psi2        cfDcovType2
Dirac[Psi] = gamma^mu D_mu Psi                      cfDiracOperator[psi] = Sum[gammaCurvedCanonical[[mu]] . cfDcov16[psi, mu], {mu, 8}]
```

- **[proved III §17]** `"Dcov16 on the direct sum is the direct sum of Dcov1 and Dcov2"` (on a generic spinor of all eight coordinates).

**Covariant constancy of `gamma^mu`.** The Christoffel symbols act on the curved index, the spinor
connection acts by commutator, and the frame connects the two. If any of the three had the wrong
sign or index order, the curved Dirac matrices would not be covariantly constant:

```
D_mu gamma^nu = d_mu gamma^nu + Gamma^nu_{mu rho} gamma^rho + [Gamma_mu, gamma^nu] = 0
```

- **[proved III §17]** `"[has content] and therefore the curved Dirac matrices are covariantly constant: D_mu gammaCurved^nu == 0"`.

**The commutator identity.** Contract `mu = nu` and use `Gamma^mu_{mu rho} = d_rho ln Sqrt[g]`
**[derived here]**:

```
(1/Sqrt[g]) d_mu ( Sqrt[g] gamma^mu )  =  [gamma^mu, Gamma_mu]
```

- **[proved VI §24]** `"FABLE [has content]: in general (1/Sqrt[g]) d_mu(Sqrt[g] gamma^mu) == [gamma^mu, Gamma^spin_mu]  (covariant constancy of gamma^mu, Section 17)"`.

**The connection term of the Dirac operator, direction by direction [derived here].** From the
explicit `Gamma_mu` of subsection 9.7 and the curved gammas of subsection 9.3, using `T16[j].T16[j] = +ID16`,
`T16[k].T16[k] = -ID16` and the anticommutation of distinct `T16`:

```
gamma^j Gamma_j = (1/(2q)) T16[j] (w0 T16[0].T16[j] + w4 T16[4].T16[j]) = -(1/(2q)) (w0 T16[0] + w4 T16[4])
gamma^k Gamma_k = (1/(2p)) T16[k] (v0 T16[0].T16[k] + v4 T16[4].T16[k]) = +(1/(2p)) (v0 T16[0] + v4 T16[4])
```

where `w0, w4` and `v0, v4` are the coefficients in `Gamma_j` and `Gamma_k`. Since
`w0/q = H c^2/s^2 = H Cot^2`, `w4/q = H a4'`, `v0/p = -H Cot^2` and `v4/p = H a4'`:

| `mu` | `gamma^mu Gamma_mu` (no sum) | `{gamma^mu, Gamma_mu}` (no sum) |
|---|---|---|
| `0` | `0` | `0` |
| `j = 1,2,3` | `-(1/2) H Cot[6Hx0]^2 T16[0] - (1/2) H a4' T16[4]` | `0` |
| `4` | `0` | `0` |
| `k = 5,6,7` | `-(1/2) H Cot[6Hx0]^2 T16[0] + (1/2) H a4' T16[4]` | `0` |

The anticommutator column follows because `Gamma_j gamma^j` equals `+(1/(2q))(w0 T16[0] + w4 T16[4])`,
the negative of `gamma^j Gamma_j`, and similarly for `k`.

**The sum.** Summing the table **[derived here]** gives `3(-1/2) + 3(-1/2) = -3` for the `T16[0]`
terms and `3(-1/2) + 3(+1/2) = 0` for the `T16[4]` terms. The observed and hidden `a4'` terms
cancel:

```
gamma^mu Gamma_mu = -3 H Cot[6 H x0]^2 T16[0]         Sum_mu {gamma^mu, Gamma_mu} = 0
```

- **[proved VI §24]** `"FABLE [has content]: the HYPOTHESIS that makes it a product -- the anticommutator {gamma^mu, Gamma^spin_mu} == 0 on the canonical frame (no totally antisymmetric part of the connection)"` (the sum over `mu`).
- **[proved VI §24]** `"FABLE [has content]: hence (1/2)(1/Sqrt[g]) d_mu(Sqrt[g] gamma^mu) == gamma^mu Gamma^spin_mu, and on this geometry == -3 H Cot[6 H x0]^2 T16[0]"`.
- **[proved VII §27]** the per-direction form: every `gamma^mu Gamma_mu` is `alpha_mu T16[0] + beta_mu T16[4]`, with `Sum alpha_mu = -3 H Cot^2` and `Sum beta_mu = 0`, `SPIN CONNECTION [THE RESULT]: direction by direction gamma^mu Gamma_mu == alpha_mu T16[0] + beta_mu T16[4]; Sum alpha_mu == -3 H Cot[6 H x0]^2 and Sum beta_mu == 0 (the observed and hidden a4 terms cancel)`; and the anticommutator vanishes for **each** `mu` separately, `LAGRANGIAN (c) [THE RESULT]: Lsym - Lsym_d == (1/(2H)) Sum_mu Psibar {gamma^mu, Gamma_mu} Psi identically, and {gamma^mu, Gamma_mu} == 0 for EACH mu on the canonical frame: Lsym == Lsym_d`.

**Why the anticommutator vanishes [derived here].** For `a != b`,
`{gamma^c, gamma^a gamma^b} = 2 gamma^a gamma^b gamma^c + 2 eta^{ca} gamma^b - 2 eta^{cb} gamma^a`.
This is `2 gamma^{cab}` (the antisymmetrized product) when `c` differs from both `a` and `b`, and
`0` when `c = a` or `c = b`. Hence
`Sum_mu {gamma^mu, Gamma_mu} = (1/2) omega_[cab] gamma^{cab}`, where
`omega_{cab} = e_c^mu omega_{mu ab}` and only its totally antisymmetric part survives. For the
diagonal canonical frame, `c` equals the direction `mu`, and every non-zero `omega_{mu ab}` has
`mu` equal to `a` or `b` (the planes `(0,mu)`, `(4,mu)`). So the totally antisymmetric part is
zero, and it is zero direction by direction.

**Contrast with an expanding frame.** On the separate 4-dimensional FLRW reference frame of Part
VI, the same computation leaves a Hubble term: **[proved VI §24]**
`"FLRW [THE RESULT]: gamma^mu Gamma^spin_mu == (3/2) (a'/a) gamma^4 -- the Hubble term of the FLRW Dirac equation"`.
On the canonical frame the analogous `T16[4]` terms cancel between the observed sheet and the
hidden sheet (`Sum beta_mu = 0`), because `q p` does not depend on `x4` **[derived here]**: the
per-direction coefficient `-(1/2) H a4'` of the table equals `(1/2) d_4 ln q`, and `+(1/2) H a4'`
equals `(1/2) d_4 ln p`, so the sum is `(3/2) d_4 ln(q p) = 0`.

**On the model's own spinor `Psi16` of Section 11.**

- **[proved III §17]** `"[definition] Dcov[mu] Psi16 - D[Psi16, x_mu] == Gamma^spin[mu] . Psi16"`.
- **[proved III §17]** `"in the six directions on which Psi16 does not depend, Dcov Psi16 is purely the connection term"`.
- **[proved III §17]** `"the connection term does not vanish on Psi16: the connection matrices themselves are non-zero (witnessed)"`.
- **[proved VI §24]** `"FABLE [has content]: the connection term does not vanish on an x0-independent spinor -- witnessed on the constant spinor e1: a spinor homogeneous in everything but x4 is NOT a solution"`.

Section 17 constructs the operator and applies it. It does not re-derive the flat field
equations of Part II from a covariant Lagrangian **[prose III §17]**.

### 9.9 The three bridges of Part IV

**The gauge law [prose IV, verified per bridge].** Suppose a new frame is `frameNew = frameOld . L`
with `L(x)` invertible on the flat indices. Substituting into the vielbein postulate, with
`M = Transpose[L]`, gives

```
omegaNew_mu = M . omegaOld_mu . Inverse[M]  -  D[M, x_mu] . Inverse[M]          (mixed components)
```

The second term is the inhomogeneous gauge term, and it vanishes exactly when `L` is constant.
The law is not assumed anywhere. Each new connection is derived independently by
`cfSpinConnection`, and the law is then verified against the result. A frame
`frameCanonical . L` with `L` preserving the flat metric describes the **same geometry**, and its
Levi-Civita connection is the canonical one in a different gauge, **not** a new connection
**[prose IV]**.

#### 9.9.1 Bridge 1: a locally boosted frame, the same connection in a local gauge (Section 18)

A new object, not in the original notebook, is introduced here: the rapidity
`theta = cfBoostRapidity[x0, x4]`, an arbitrary function. It generates a boost in the flat `(0,4)`
plane:

```
Lambda[theta] = ID8 + (Cosh[theta] - 1)(E00 + E44) + Sinh[theta](E04 + E40) = MatrixExp[theta K],   K = E04 + E40
frameBoost    = frameCanonical . Lambda
```

- **[proved IV §18]** `"Lambda is in O(4,4): Lambda . eta . Transpose[Lambda] == eta"`, `"Lambda is NOT in O(8): it is a genuine boost, not a rotation"`, `"Lambda == MatrixExp[theta K] with K the (0,4) boost generator"`.
- **[proved IV §18]** `"BRIDGE 1 reproduces the SAME curved metric g"`, `"BRIDGE 1 frame really is different from the canonical frame"`.
- **[proved IV §18]** `"BRIDGE 1: vielbein postulate holds identically"`, `"BRIDGE 1: omega[mu,a,b] == -omega[mu,b,a]"`, `"BRIDGE 1: torsion still vanishes"`.
- **[proved IV §18]** `"COMPARISON 1: omegaBoost == M omegaCanonical Inverse[M] - D[M,x_mu] Inverse[M]"`, `"COMPARISON 1: the WHOLE difference is the inhomogeneous gauge term"`, `"COMPARISON 1: the difference equals -D[theta, x_mu] * (boost generator)"`.
- **[proved IV §18]** `"COMPARISON 1: curvature transforms covariantly, R' == M R Inverse[M]"`, `"COMPARISON 1: BRIDGE 1 has the SAME Ricci scalar as the canonical frame"`.
- **[displayed IV §18]** `omegaBoost` has 28 non-zero components. The difference `deltaBoost` has 4: `-D[theta, x_mu] K` for `mu = 0` and `mu = 4`, in the two orderings of the plane `(0,4)`.

At the spinor level, the spin lift is `S = MatrixExp[theta SAB[[1,5]]]`, with no extra factor
`1/2`, because `SAB` already carries `1/4` **[prose IV §18]**:

- **[proved IV §18]** `"BRIDGE 1 spin lift: Inverse[S] . S == ID16"`, `"BRIDGE 1 spin lift: S preserves the spinor metric, Transpose[S] . sigma16 . S == sigma16"`, `"BRIDGE 1 spin lift [has content]: Inverse[S] . gamma^a . S == Lambda^a_b gamma^b  (S is the spin lift of Lambda)"`.
- **[proved IV §18]** `"COMPARISON 1 at the spinor level [THE GAUGE LAW]: Gamma'_mu == S Gamma_mu Inverse[S] - D[S,x_mu] Inverse[S]"`, `"COMPARISON 1 at the spinor level: the inhomogeneous term is -D[theta,x_mu] SAB[[1,5]], the spin image of -D[theta,x_mu] K"`, `"COMPARISON 1 at the spinor level: and that is exactly cfSpinMatrix applied to the vector difference deltaBoost"`.
- **[proved IV §18]** `"BRIDGE 1 [has content]: D'_mu (S psi) == S D_mu psi for a generic spinor -- one covariant derivative, two gauges"`, `"BRIDGE 1: the curved Dirac matrices of the boosted frame are S gamma^mu Inverse[S]"`, `"BRIDGE 1: so the Dirac operator is one operator in two gauges, Dirac'[S psi] == S Dirac[psi]"`.

A solution of the Dirac equation in one gauge is therefore a solution in the other, after
`psi -> S psi`. Part V identifies the inhomogeneous term as the fable-5.1 connection of the boosted
frame (subsection 9.10 below).

#### 9.9.2 Bridge 2: the null (light-cone) frame, the same connection in a constant gauge (Section 19)

```
U = (1/Sqrt[2]) ArrayFlatten[{{ID4, ID4}, {ID4, -ID4}}]        U == Transpose[U],  U . U == ID8
etaNull = Transpose[U] . eta4488 . U                          frameNull = frameCanonical . U
```

The eight flat directions are paired as `(0,4)`, `(1,5)`, `(2,6)` and `(3,7)`, one spacelike and
one timelike in each pair, and each pair is replaced by its two null combinations **[prose IV §19]**.

- **[proved IV §19]** `"U is an involution: U . U == ID8"`, `"U is symmetric"`, `"THE NULL TANGENT METRIC IS EXACTLY THE SPINOR METRIC sigma"`, `"etaNull is symmetric and squares to ID8"`, `"all eight frame directions are null: etaNull has zero diagonal"`.
  The identity `etaNull == sigma` is a statement about the flat metric, not about the connection.
- **[proved IV §19]** `"BRIDGE 2 reproduces the SAME curved metric g"`, `"BRIDGE 2: vielbein postulate holds identically"`, `"BRIDGE 2: omega[mu,a,b] == -omega[mu,b,a] with indices lowered by etaNull"`, `"BRIDGE 2: torsion vanishes"`.
- **[proved IV §19]** `"COMPARISON 2: omegaNull == U . omegaCanonical . U exactly"`, `"COMPARISON 2: the inhomogeneous gauge term is ZERO because U is constant"`, `"COMPARISON 2: R_null == U . R_canonical . U"`, `"COMPARISON 2: BRIDGE 2 has the SAME Ricci scalar as the canonical frame"`.
- **[displayed IV §19]** `omegaNull` has 48 non-zero components. A constant change of basis spreads the canonical 24 over more entries, and the difference from `U omega U` is zero.

#### 9.9.3 Bridge 3: triality frame with totally antisymmetric split-octonion torsion, a different connection (Section 20)

The flat index is a **type-1 split-octonion spinor index**, reached through the constant triality
bridge `triVecToSpin` of Section 9. **[proved I §9]** `"THE TRIALITY METRIC IS EXACTLY THE SPINOR METRIC:  etaTri == sigma"`.

```
frameTri = frameCanonical . triVecToSpin                           (flat tangent metric sigma)
omegaOct[mu,a,b] = omegaTriLC[mu,a,b] + lambda * mSkew[a,b,c] frameTri[[mu,c]]
```

Here `omegaTriLC` is the Levi-Civita connection in the triality frame. `mSkew = mSkewSpin` is the
totally antisymmetrized split-octonion structure constant `mLower`, transported to the spinor
basis. `lambda = lambdaOct` is a free real torsion-strength parameter introduced in Section 20,
not in the original notebook.

- **[proved IV §20]** `"the triality bridge is Euclidean-orthogonal: Transpose[P] == Inverse[P]"`, `"but it is NOT in O(4,4): P . eta4488 . Transpose[P] != eta4488 (it carries eta4488 to sigma)"`, `"BRIDGE 3 reproduces the SAME curved metric g"`, `"the triality tangent metric is sigma"`.
- **[proved IV §20]** `"the antisymmetrized structure constants are totally antisymmetric"`, `"they agree with mLower on the seven imaginary directions"`, `"mSkewSpin is totally antisymmetric"` (48 non-zero components **[displayed IV §20]**).
- **[proved IV §20]** `"BRIDGE 3 (lambda=0): vielbein postulate holds identically"`, `"BRIDGE 3 (lambda=0): omega[mu,a,b] == -omega[mu,b,a]"`, `"BRIDGE 3 (lambda=0) is the constant triality conjugate of the canonical connection"`.
- **[proved IV §20]** `"BRIDGE 3: omegaOct[mu,a,b] == -omegaOct[mu,b,a]  (still metric compatible)"`, `"BRIDGE 3: at lambda = 0 it reduces to the Levi-Civita connection"`.
- **[proved IV §20]** `"BRIDGE 3: torsion vanishes at lambda = 0"`, `"BRIDGE 3: torsion is NOT zero for lambda != 0"`, `"BRIDGE 3: the flat torsion T[a,b,c] is TOTALLY ANTISYMMETRIC"`, `"BRIDGE 3: T[a,b,c] == -2 lambda mSkewSpin[a,b,c]"`.
- **[proved IV §20]** `"COMPARISON 3: omegaOct - (triality conjugate of omegaCanonical) == contortion"`, `"COMPARISON 3: the difference is linear in lambda and vanishes at lambda = 0"`. The difference is a **tensor** (a contortion), so this is a different connection.

**Its curvature is quadratic in `lambda`.** With `K` the contortion,
`R(omegaOct) = R(omegaTriLC) + lambda (dK + [omegaTriLC, K]) + lambda^2 [K, K]`:

- **[proved IV §20]** `"BRIDGE 3: at lambda = 0 the curvature is the triality conjugate of the canonical curvature"`, `"BRIDGE 3 [has content]: the curvature DOES depend on lambda (witnessed)"`, `"BRIDGE 3: the lambda-dependence is a polynomial of degree exactly two"`.
- **[proved IV §20]** `"BRIDGE 3: the lambda^1 term is the Levi-Civita covariant exterior derivative of the contortion, dK + [omegaTriLC, K]"`. Written out, it is `d_mu K_nu - d_nu K_mu + [omegaTriLC_mu, K_nu] - [omegaTriLC_nu, K_mu]`.
- **[proved IV §20]** `"BRIDGE 3: the lambda^2 term is [K_mu, K_nu], the contortion commuted with itself"`.

**The Ricci shift.** `-42 lambda^2 = -(1/4) T_{abc} T^{abc}`:

- **[proved IV §20]** `"BRIDGE 3: at lambda = 0 the Ricci scalar is the canonical one"`.
- **[proved IV §20]** `"BRIDGE 3 [THE RESULT]: R(omegaOct) - R(canonical) == -(1/4) T_{abc} T^{abc}, a constant shift set by the torsion alone"`.
- **[proved IV §20]** `"BRIDGE 3: equivalently -lambda^2 (mSkew . mSkew), with mSkew . mSkew == 42, so the shift is exactly -42 lambda^2"`.
  Check **[derived here]**: `T = -2 lambda mSkew` gives `T.T = 4 lambda^2 . 42 = 168 lambda^2`, and `(1/4) . 168 = 42`.

This connection resembles the Cartan–Schouten connections of a Lie group, but it differs in two
ways that must not be assumed away **[prose IV §20]**. It is not flat. And the octonion structure
constants violate the Jacobi identity, so they cannot be the anholonomy of any frame.

**Spinor level.** `cfSpinMatrix` is correct only for `eta4488` vector indices. Bridge 3's flat index
is a triality-spinor index, so the matching Dirac matrices are
`T16Tri[a] = Sum_A triSpinToVec[[a,A]] T16[A-1]`, and they are contracted by `cfSpinMatrixTri`
**[prose IV §20]**:

- **[proved IV §20]** `"THE TRIALITY DIRAC MATRICES OBEY THE sigma CLIFFORD RELATION: {T16Tri[a],T16Tri[b]} == 2 sigma[[a,b]] ID16"`, `"they are NOT the vector-frame Dirac matrices, so the distinction is real"`.
- **[proved IV §20]** `"at lambda = 0 the Bridge 3 spinor connection equals the canonical one"`, `"the extra spinor coupling vanishes at lambda = 0"`, `"the extra spinor coupling is non-zero for lambda != 0"`, `"the extra spinor coupling is still block diagonal (type-1 + type-2 preserved)"`.
- The extra coupling `(lambda/8) mSkew[a,b,c] frameTri[[mu,c]] [T16Tri[a], T16Tri[b]]` is **quadratic** in the gammas. The third index is contracted with the frame, not with a third gamma. The cubic Einstein–Cartan axial term would appear only after contracting with `gamma^mu` in the Dirac operator, and the notebook does **not** carry that contraction out **[prose IV §20]**. The extra coupling has 160 non-zero entries **[displayed IV §20]**.

### 9.10 The fable-5.1 bridge of Part V: the Weitzenböck (teleparallel) connection

The fable-5.1 bridge keeps the metric, the frame, `eta4488` and the bridge `[d]` unchanged, and
changes only the rule for parallel transport. It declares the canonical frame itself to be
parallel **[prose V §21]**:

```
GammaWeitzenboeck[[rho, mu, nu]] = Sum_a coframe[[a, rho]] D[frame[[nu, a]], x[mu]]         (Gamma^W = e_a^rho d_mu e_nu^a)
```

- **[proved V §21]** `"FABLE-5.1 [definition]: the frame is parallel  --  nabla^W e == 0 for all eight frame vectors"`, `"FABLE-5.1 [has content]: Gamma^W is metric compatible, nabla^W g == 0"`, `"FABLE-5.1 [has content]: Gamma^W is NOT symmetric in its lower indices -- it has torsion"`, `"FABLE-5.1 [has content]: Gamma^W is NOT the Levi-Civita connection"`.
- `Gamma^W` has 13 non-zero components **[displayed V §22]**.

**The spin connection is zero, and so is the curvature.** `Gamma^W` is fed to the same solver.
Because the first two terms of the vielbein postulate then cancel by construction, the solver
returns `omega = 0`:

- **[proved V §21]** `"FABLE-5.1 [solver regression]: vielbein postulate residual is zero"`, `"FABLE-5.1 [THE RESULT]: the spin connection in the canonical frame is IDENTICALLY ZERO"`, `"FABLE-5.1: trivially antisymmetric, so trivially metric compatible"`.
- **[proved V §21]** `"FABLE-5.1 [has content]: the torsion is NOT zero"`, `"FABLE-5.1: T^rho_{mu nu} == Gamma^W[rho,mu,nu] - Gamma^W[rho,nu,mu]  (torsion is the antisymmetric part of Gamma^W)"`. With `omega = 0` the torsion is `T^a_{mu nu} = d_mu e_nu^a - d_nu e_mu^a`.
- **[proved V §21]** `"FABLE-5.1 [THE RESULT]: the curvature is IDENTICALLY ZERO -- a flat connection on a curved metric"`.

**The canonical connection is minus the contortion of this torsion.** The contortion is
`K = Gamma^W - Gamma^LC`, and in terms of the torsion
`K[rho,mu,nu] = (1/2)(T[rho,mu,nu] + T[mu,rho,nu] + T[nu,rho,mu])` (all indices down, first index
then raised). Substituting `Gamma^LC = Gamma^W - K` into the vielbein postulate leaves
`omegaCanonical[mu,a,b] = -K[rho,mu,nu] e[rho,a] coframe[[b,nu]]` **[prose V §21]**.

- **[proved V §21]** `"COMPARISON F [has content]: Gamma^W - Gamma^LC == (1/2)(T_{rmn} + T_{mrn} + T_{nrm}) with the index raised, the contortion formula"`.
- **[proved V §21]** `"COMPARISON F [THE RESULT]: omegaCanonical == - contortion(fable-5.1 torsion), pulled back to flat indices, exactly"`.
- **[proved V §21]** `"COMPARISON F: so omegaCanonical - omegaFable51 is a TENSOR, not a gauge term (omegaFable51 == 0)"`.
- `contortionFable51` has 24 non-zero components, the same 24 as `omegaCanonical`. `torsionFable51Flat` has 24, and `RiemannFable51` has 0 **[displayed V §22]**.

**The kind of torsion.** A torsion tensor splits into a vector part, an axial part and a tensor
part:

- **[proved V §21]** `"FABLE-5.1 torsion vector T[mu] = T[nu,nu,mu] is a GRADIENT: T[mu] == D[Log[Sin[6 H x0]], x[mu]]"`.
- **[proved V §21]** `"FABLE-5.1 torsion vector has exactly one non-zero component, 6 H Cot[6 H x0] along x0"`.
- **[proved V §21]** `"FABLE-5.1: the AXIAL (totally antisymmetric) part of the torsion vanishes -- the complement of Bridge 3"`, `"FABLE-5.1: the torsion itself does not vanish, so the tensor part carries the rest"`.

For any diagonal frame the torsion vector is, component by component (no sum) **[derived here]**,
`T_mu = Sum_nu e_a^nu (d_nu e_mu^a - d_mu e_nu^a) = d_mu ln( e_mu^mu / det e )`. On the canonical
frame this is `d_0 ln( Tan[6Hx0]/Sec[6Hx0] ) = d_0 ln Sin[6Hx0] = 6 H Cot[6Hx0]` for `mu = 0`. It
is zero for `mu = 4`, because `e_4^4 = 1` and `det e = Sec[6Hx0]` do not depend on `x4`. It is zero
for `mu = 1,2,3,5,6,7`, because nothing depends on those coordinates. This agrees with the
assertion.

**`R = -T + B` in closed form.** With the torsion scalar
`T = (1/4) T^{rmn} T_{rmn} + (1/2) T^{rmn} T_{nmr} - T^m T_m` and the boundary term
`B = (2/Sqrt[det g]) d_mu( Sqrt[det g] T^mu )`, where `Sqrt[det g] = Sec[6 H x0]`:

```
RicciScalarCanonical  = -3*H^2*((55 + 7*Cos[12*H*x0])*Cot[6*H*x0]^2*Csc[6*H*x0]^2 - 2*a4'[H*x4]^2)
torsionScalarFable51  = -6*H^2*(5*Cot[6*H*x0]^4 + a4'[H*x4]^2)
boundaryTermFable51   = -36*H^2*(5 + Cos[12*H*x0])*Cot[6*H*x0]^2*Csc[6*H*x0]^2
```

These closed forms are **[displayed V §21]**. The following are **[proved V §21]**:
`"COMPARISON F [THE RESULT]: R == -T + B  --  the teleparallel equivalent of GR, in closed form for this geometry"`,
`"FABLE-5.1: T is not zero and B is not zero -- neither side is trivial"`. The Einstein–Hilbert and
teleparallel actions therefore differ by a boundary term on this geometry.

**The spinor: one vector term, removed by a rescaling.** In the fable-5.1 gauge the spinor
connection is zero, so the Dirac operator is `gamma^mu d_mu`. The canonical Dirac operator carries
in addition `gamma^mu Gamma_mu`, and this whole term is one vector term:

```
gamma^mu Gamma_mu = -(1/2) T_mu gamma^mu = -(1/2) d_mu( Log[Sin[6 H x0]] ) gamma^mu        ( = -3 H Cot[6Hx0]^2 T16[0] )
Dirac_LC[ Sqrt[Sin[6 H x0]] Psi' ] = Sqrt[Sin[6 H x0]] gamma^mu d_mu Psi'                  for every Psi'
```

The first line checks against subsection 9.8 **[derived here]**:
`-(1/2) (6H Cot) (Cot T16[0]) = -3H Cot^2 T16[0]`, because `gamma^0 = Cot T16[0]`. The matrix
`gamma^mu Gamma_mu` is `-3H Cot^2` times the permutation matrix `T16[0]`, so it has 16 non-zero
entries.

- **[proved V §21]** `"FABLE-5.1 [THE RESULT]: gamma^mu Gamma^spin[mu] == -(1/2) T[mu] gamma^mu, one vector term"`, `"FABLE-5.1: equivalently -(1/2) D[Log[Sin[6 H x0]], x_mu] gamma^mu"`.
- **[proved V §21]** `"FABLE-5.1 [THE RESULT]: DiracCanonical[ Sqrt[Sin[6Hx0]] Psi' ] == Sqrt[Sin[6Hx0]] DiracFable51[Psi'], for a generic Psi'"`, `"FABLE-5.1: the rescaling is NOT a no-op -- the two Dirac operators differ on the constant spinor"`.
- **[proved VI §24]** with a potential: `"FABLE [THE RESULT]: (gamma^mu D_mu - H V'(s)) [Sqrt[Sin[6 H x0]] Psi'] == Sqrt[Sin[6 H x0]] (gamma^mu d_mu Psi' - H V'(s) Psi') for a GENERIC Psi'(x0, x4): the rescaling removes the connection term exactly"`.

The rescaling works because the torsion vector is a gradient. A vector-torsion term that is a
gradient is removed by multiplying the spinor by `Exp[(1/2) Log[Sin[6Hx0]]] = Sqrt[Sin[6Hx0]]`
**[derived here]**.

**For the real spinor of Parts II–VI the connection drops out of the Lagrangian.**
`sigma16 . T16[a]` is antisymmetric, so `Psi^T sigma16 T16[a] Psi = 0` for real commuting `Psi`.
Since `gamma^mu Gamma_mu` is a multiple of `gamma^mu`, the connection contributes nothing to that
Lagrangian:

- **[proved V §21]** `"FABLE-5.1 [THE RESULT]: Psi^T sigma16 gamma^mu Gamma^spin[mu] Psi == 0 for EVERY Psi -- the spin connection drops out of the Lagrangian"`, `"FABLE-5.1: the reason is Section 11's identity, Psi^T sigma16 T16[a] Psi == 0 (sigma16 T16[a] antisymmetric)"`, `"FABLE-5.1: but the connection term does NOT drop out of the Dirac OPERATOR (it is -(1/2) T[mu] gamma^mu, non-zero)"`.
- **[proved V §21]** `"FABLE-5.1: the covariant Lagrangian with frame -> ID8 and volume factor -> 1 IS the author's La of Section 11, term for term"`, `"FABLE-5.1: and the covariant Lagrangian has NO connection term to omit -- its kinetic term is already the fable-5.1 one"`. The author's flat `La` omits only the volume factor `Sec[6Hx0]` and the coframe factors inside `gamma^mu` **[prose V §21]**.

This mechanism is specific to a **real** field. Subsection 9.12 shows that it does not carry over to
the complex fermion fable.

**Frame covariance: Bridge 1 explained.** In Bridge 1's boosted frame, the same `Gamma^W` fed to
the same solver gives a fable-5.1 spin connection that is pure gauge:

- **[proved V §21]** `"FABLE-5.1 in the boosted frame: vielbein postulate residual is zero"`, `"FABLE-5.1 in the boosted frame [THE RESULT]: omega == -D[M,x_mu] Inverse[M], pure gauge and nothing else"`, `"FABLE-5.1 in the boosted frame: the lemma's prediction itself satisfies the vielbein postulate with Gamma^W"`, `"FABLE-5.1 in the boosted frame: the curvature is STILL identically zero"`.
- **[proved V §21]** `"and Bridge 1's inhomogeneous term of Section 18 IS this object: deltaBoost == omegaFable51Boost"`, `"so omegaBoost == (canonical, conjugated) + (fable-5.1 in the boosted frame)"`.
- `omegaFable51BoostMixed` has 4 non-zero components, the same 4 as `deltaBoost` **[displayed V §21]**.

### 9.11 Master comparison of the five connections (Section 22)

Section 22 prints two tables: the summary `cfConnectionSummary`, and a grid of the comparisons
side by side **[displayed V §22]**. The table below is `cfConnectionSummary`, with three entries of
the side-by-side grid added to the column "difference from canonical": Bridge 1's spinor-level law,
and Bridge 3's curvature and Ricci shift. Part VII restates the bridge results it relies on, so
that it can be read alone: **[proved VII §27]** `SPIN CONNECTION [has content]: Parts IV-V restated -- Bridge 1's difference is the pure gauge term, Bridge 2 is a constant conjugate, Bridge 3 has totally antisymmetric torsion that is not zero` and
`SPIN CONNECTION [has content]: Part V restated -- omega^W == 0 in the canonical frame, omega^LC == -contortion, T_mu == d_mu Log[Sin[6 H x0]], R == -T + B, and gamma^mu Gamma_mu == -(1/2) T_mu gamma^mu`.

| connection | frame field | flat metric | same `g`? | metric compatible? | torsion zero? | curvature zero? | difference from canonical | verdict |
|---|---|---|---|---|---|---|---|---|
| `omegaCanonical` | `frameCanonical` (diagonal) | `eta4488` | yes (reference) | yes | yes | no | — (reference) | Levi-Civita |
| `omegaBoost` (Bridge 1) | `frameCanonical . Lambda(x)` | `eta4488` | yes | yes | yes | no | gauge term `-D[theta,x_mu] K`, which is the fable-5.1 connection of the boosted frame; at spinor level `Gamma' = S Gamma S^-1 - dS S^-1` | SAME connection, local gauge |
| `omegaNull` (Bridge 2) | `frameCanonical . U` | `etaNull == sigma` | yes | yes | yes | no | constant similarity `U omega U` | SAME connection, constant gauge |
| `omegaOct` (Bridge 3) | `frameCanonical . triVecToSpin` | `etaTri == sigma` | yes | yes | **no**: axial torsion `-2 lambda mSkew` | no | contortion `lambda mSkew[a,b,c] frameTri[[mu,c]]`, a tensor; curvature quadratic in `lambda`; Ricci shift `-42 lambda^2` | **DIFFERENT connection** |
| `omegaFable51` (fable-5.1) | `frameCanonical` (parallel) | `eta4488` | yes | yes | **no**: vector + tensor torsion, axial part zero | **yes**: flat | `omegaCanonical == -contortion(T_fable51)`, a tensor; `omegaFable51 == 0` | **DIFFERENT connection** |

Non-zero component counts (Section 22 fingerprint table and the counts printed in Sections 16–21,
**[displayed]**):

| object | non-zero components |
|---|---|
| `GammaCanonical` (Christoffel) | 37 |
| `GammaWeitzenboeck` | 13 |
| `omegaCanonical` | 24 |
| `omegaBoost` / its difference `deltaBoost` | 28 / 4 |
| `omegaNull` / its difference | 48 / 0 |
| `omegaTriLC` (Bridge 3, `lambda = 0`) | 84 |
| `contortionOct` (Bridge 3) | 78 |
| `torsionOctFlat` (Bridge 3) | 48 |
| `omegaFable51` (canonical frame) | 0 |
| `contortionFable51` / `torsionFable51Flat` | 24 / 24 |
| `RiemannCanonical` | 156 |
| `RiemannFable51` | 0 |

### 9.12 What the canonical connection does for the complex fermion fable

Everything in this section concerns the **complex** 16-component fermion fable of Part VII. Two
kinds of statement appear. Some are consequences of results already proved in Parts I–VI, and
the derivation is shown here. The others are assertions of the new Part VII, marked
**[proved VII §n]**, with the label quoted verbatim from `claude-fable/run_fermion_fable_part7.log`.

#### 9.12.1 The field and the symmetrized Lagrangian

Fermion fable is a complex 16-component Grassmann spinor `Psi`. It is the minimal field that uses
the author's `sigma16` conjugation, propagates, admits a potential `V(s)`, and reduces to Part VI's
real field as its real commuting shadow. It is not the unique field with dynamics. This is the
conclusion of Section 26 as a whole (section 3.8); no single assertion states it. It rests on
**[proved VII §26]** `REFINEMENT (d) [THE RESULT]: s = Psibar Psi == i theta1^T sigma16 theta2: NON-ZERO (16 monomials) and HERMITIAN; p = Psibar T16[8] Psi is non-zero and Hermitian too`, `REFINEMENT (b) [THE RESULT]: Majorana with C+: the kinetic term is genuine -- Euler-Lagrange expression 2 C+ T16[a] phi with C+ T16[a] invertible -- but every invariant bilinear vanishes (massless, no V(s))`,
`REFINEMENT (c) [THE RESULT]: Weyl and Majorana-Weyl: PL C T16[a] PL == PR C T16[a] PR == 0 for C = C-, C+ and every a (C chirality-diagonal, T16[a] chirality-odd) -- no kinetic term` and `FIDELITY [1] [fidelity]: Psi -> psi, Psibar -> psi^T sigma16 turns the symmetrized covariant Lhat into Part VI's cfLhatFable EXACTLY (canonical frame, generic V)`, among the others quoted in section 3. Its Dirac
conjugate and scalar bilinear are

```
Psibar = Psi^ddag sigma16            s = Psibar Psi = -psi1^ddag sigma psi1 + psi2^ddag sigma psi2
```

where `^ddag` is the classical conjugate transpose. The second form follows from
`sigma16 = diag(-sigma, sigma)`. In the quantized theory the Hilbert adjoint is
`Psi^dagger := Psi^ddag J` (subsection 9.12.6).

The only Lagrangian used is the **symmetrized covariant** one:

```
L = Sqrt[g] Lhat,     Lhat = (1/(2H)) [ Psibar gamma^mu D_mu Psi - (D_mu Psibar) gamma^mu Psi ] - V(s)
D_mu Psi = d_mu Psi + Gamma_mu Psi,          D_mu Psibar = d_mu Psibar - Psibar Gamma_mu
```

`D_mu Psibar` is the Dirac conjugate of `D_mu Psi`, and `Lhat` is real, because `sigma16 gamma^a`
and `sigma16 Gamma_mu` are **real antisymmetric** matrices. That rests on
**[proved I §5]** `"sigma16 . T16[A] is antisymmetric for A = 0..7"` and `"sigma16 . SAB is antisymmetric"`,
together with `Gamma_mu = (1/2) omega_{mu ab} SAB` with real `omega` (subsection 9.7).
**[proved VII §27]** `LAGRANGIAN (a) [definition]: every Gamma^spin_mu is real and sigma16 Gamma_mu is antisymmetric (Gamma_mu^T sigma16 == -sigma16 Gamma_mu): D_mu Psibar is the Dirac conjugate of D_mu Psi`.

#### 9.12.2 It drops out of the symmetrized Lagrangian because the matrix `{gamma^mu, Gamma_mu}` vanishes

Expanding `D` in the symmetrized Lagrangian gives **[derived here]**

```
Lhat(D) = Lhat(d) + (1/(2H)) Psibar ( Sum_mu {gamma^mu, Gamma_mu} ) Psi
```

The connection terms are `Psibar gamma^mu Gamma_mu Psi` from the first product and
`+Psibar Gamma_mu gamma^mu Psi` from `-(D_mu Psibar) gamma^mu Psi`. On the canonical frame
`{gamma^mu, Gamma_mu} = 0` **for each `mu`** (subsection 9.8), so `Lhat(D) = Lhat(d)` identically. That
is, "covariant == partial" holds for the symmetrized complex Lagrangian on this frame. It holds
on any frame where the totally antisymmetric part `omega_[cab]` vanishes, and fails in general.

- **[proved VII §27]** `LAGRANGIAN (c) [THE RESULT]: Lsym - Lsym_d == (1/(2H)) Sum_mu Psibar {gamma^mu, Gamma_mu} Psi identically, and {gamma^mu, Gamma_mu} == 0 for EACH mu on the canonical frame: Lsym == Lsym_d`.

This is **not** Part VI's mechanism. For the real commuting field, `Psi^T sigma16 gamma^mu Gamma_mu Psi`
vanishes because `sigma16 T16[0]` is antisymmetric (subsection 9.10). For a complex field,
`Psibar T16[0] Psi = Psi^ddag (sigma16 T16[0]) Psi` with `sigma16 T16[0]` real antisymmetric is
`i` times the Hermitian form of `-i sigma16 T16[0]`, which is not zero in general. So the drop-out
for the complex field is a property of the **matrix** `{gamma^mu, Gamma_mu}`, not of a bilinear
identity **[derived here]**. The other Lagrangians behave differently:

- The **unsymmetrized covariant** Lagrangian `(1/H) Psibar gamma^mu D_mu Psi - V` equals the
  symmetrized one plus `(1/(2H)) (1/Sqrt[g]) d_mu( Sqrt[g] Psibar gamma^mu Psi )`, a total
  divergence. Its connection term is `(1/H) Psibar gamma^mu Gamma_mu Psi = -3 Cot[6Hx0]^2 Psibar T16[0] Psi`,
  which is not zero. **[proved VII §27]** `LAGRANGIAN (d) [has content]: Lun - Lsym == (1/(2H)) (1/Sqrt[g]) d_mu( Sqrt[g] Psibar gamma^mu Psi ), a total divergence`, `LAGRANGIAN (e) [has content]: Lun - Lun_d == (1/H) Psibar gamma^mu Gamma_mu Psi == -3 Cot[6 H x0]^2 Psibar T16[0] Psi`, `LAGRANGIAN (e) [control]: that term is NOT zero for a complex field (witness u = e1, v = e13), and IS zero in the real commuting limit (the scope of Parts V-VI)`.
- The **unsymmetrized partial** Lagrangian `(1/H) Psibar gamma^mu d_mu Psi - V` is **inadmissible**.
  Its `Psi` and `Psibar` equations are not Dirac conjugates of each other: they differ by
  `Psibar Sum_mu [gamma^mu, Gamma_mu] = 2 Psibar gamma^mu Gamma_mu = -6 H Cot[6Hx0]^2 Psibar T16[0]`.
  **[proved VII §27]** `LAGRANGIAN (f) [THE RESULT]: Lun_d varied with respect to Psibar gives (Sqrt[g]/H)(gamma^mu d_mu Psi - H V' Psi): the connection term is MISSING`, `LAGRANGIAN (f) [THE RESULT]: varied with respect to Psi it gives -(Sqrt[g]/H)((d_mu Psibar) gamma^mu + Psibar [gamma^mu, Gamma_mu] + H V' Psibar), with Psibar [gamma^mu, Gamma_mu] == 2 Psibar gamma^mu Gamma_mu: the connection term is PRESENT`, `LAGRANGIAN (f) [control]: so Lun_d is INADMISSIBLE -- its two field equations are not Dirac conjugates: they differ by 2 Psibar gamma^mu Gamma_mu = -6 H Cot^2 Psibar T16[0], non-zero (witness u = e1, v = 0, V = s^2)`.

#### 9.12.3 It enters the field equation as `-3 H Cot^2 T16[0]`, and the rescaling removes it

Varying `Psibar` and `Psi` independently in the symmetrized action gives the field equation and
its conjugate:

```
gamma^mu D_mu Psi = H V'(s) Psi                  (D_mu Psibar) gamma^mu = -H V'(s) Psibar
```

**[proved VII §27]** `FIELD EQUATION [THE RESULT]: EL_Psibar == (Sqrt[g]/H)(gamma^mu D_mu Psi - H V'(s) Psi) for generic Psi, Psibar of all eight coordinates: the field equation is gamma^mu D_mu Psi == H V'(s) Psi`, `FIELD EQUATION [THE RESULT]: EL_Psi == -(Sqrt[g]/H)((D_mu Psibar) gamma^mu + H V'(s) Psibar): the adjoint equation is (D_mu Psibar) gamma^mu == -H V'(s) Psibar`.
For the real field of Part VI the same equation is **[proved VI §24]**
`"FABLE [THE RESULT]: EL == Sqrt[g] (2/H) sigma16 . ( gamma^mu D_mu Psi - H V'(s) Psi ): the field equation of fable is EXACTLY the Levi-Civita covariant Dirac equation  gamma^mu D_mu Psi == H V'(s) Psi"`.

On the canonical frame the connection enters as follows **[derived here, from subsection 9.8]**. In the
equation it is `gamma^mu Gamma_mu Psi = -3 H Cot[6Hx0]^2 T16[0] Psi`. In the conjugate it is
`-Psibar Gamma_mu gamma^mu = +Psibar gamma^mu Gamma_mu = -3 H Cot[6Hx0]^2 Psibar T16[0]`, using the
per-`mu` anticommutator. Because `T16[0] = ArrayFlatten[{{0,ID8},{ID8,0}}]`, in the 8+8
split-octonion form `Psi = (psi1, psi2)`:

```
e_a^mu taubar[a] (d_mu + Gamma^(2)_mu) psi2 = H V'(s) psi1        (upper 8 rows; connection term -3 H Cot^2 psi2)
e_a^mu tau[a]    (d_mu + Gamma^(1)_mu) psi1 = H V'(s) psi2        (lower 8 rows; connection term -3 H Cot^2 psi1)
```

Here `s = -psi1^ddag sigma psi1 + psi2^ddag sigma psi2`, `psibar1 = -psi1^ddag sigma` and
`psibar2 = psi2^ddag sigma`. The conjugate equations are
`(d psibar2 - psibar2 Gamma^(2)) tau[a] e_a^mu = -H V' psibar1` and
`(d psibar1 - psibar1 Gamma^(1)) taubar[a] e_a^mu = -H V' psibar2`.
**[proved VII §27]** `WRITTEN OUT (ii) [THE RESULT]: the split-octonion 8+8 form -- the type-1 rows are the taubar equations for psi2, the type-2 rows the tau equations for psi1 (tau[0] == taubar[0] == ID8)`, `WRITTEN OUT (ii) [THE RESULT]: the covariant 8+8 form -- rows 1..8 are e_a^mu taubar[a] (d_mu + Gamma^(2)_mu) psi2 - H V' psi1, rows 9..16 are e_a^mu tau[a] (d_mu + Gamma^(1)_mu) psi1 - H V' psi2; and the conjugate rows`, `WRITTEN OUT (ii) [has content]: with Psibar = Psi^ddag sigma16 and sigma16 = diag(-sigma, sigma): s == -psi1^ddag sigma psi1 + psi2^ddag sigma psi2 (psibar1 = -psi1^ddag sigma, psibar2 = psi2^ddag sigma)`.

**The rescaling.** The rescaling of Part V applies unchanged, because it is a statement about the
operator. `Psi = Sqrt[Sin[6Hx0]] Psi'` turns the equation into
`Sqrt[Sin[6Hx0]] (gamma^mu d_mu Psi' - H V'(s) Psi') = 0` with `s = Sin[6Hx0] Psi'bar Psi'`. The
connection term is gone. **[proved VII §27]** `WRITTEN OUT (iv) [THE RESULT]: Psi = Sqrt[Sin[6Hx0]] Psi' turns the field equation into Sqrt[Sin] (Cot T16[0] d_0 Psi' + (1/q) T16[i] d_i Psi' + T16[4] d_4 Psi' + (1/p) T16[h] d_h Psi' - H V'(Sin s') Psi'): NO connection term`, `WRITTEN OUT (iv) [THE RESULT]: and the adjoint equation into Sqrt[Sin] (Cot d_0 Psi'bar T16[0] + ... + H V'(Sin s') Psi'bar), with no connection term either`.
The `x4`-only family `Psi = Sqrt[Sin[6Hx0]] Psi'(x4)` solves the equation if and only if
`V'' s' = 0`. That holds for linear `V` (the author's mass term), or for null data `s' = 0`. For
the complex field `s'` is conserved on the `x4`-only equation, so null data give `x4`-only
solutions for any `V`. **[proved VII §29]** `PRE-UNIVERSE (2) [THE RESULT]: Psi = Sqrt[Sin] Psi'(x4) satisfies the field equation iff d_x0 V'(Sin[6Hx0] s') == 0, and d_x0 V'(Sin s') == 6 H Cos[6 H x0] s' V''(Sin s'): V linear OR s' == 0`, `PRE-UNIVERSE (2) [has content]: s' = Psi'bar Psi' is conserved by the x4-only equations (d_4 Psi' = -H V' T16[4] Psi', d_4 Psi'bar = H V' Psi'bar T16[4]) for ANY V; so null data s' = 0 are solutions for any V, with rho == V(0); and for V = s^2 with s' != 0 the x0-dependence is real (witness)`.
The real-field version is **[proved VI §24]**
`"FABLE [has content]: for the mass term V = -(2M/H) s, V' is constant and Psi'(x4) IS an exact solution"`.

**The frame-independent form.** Covariant constancy of `gamma^mu` (subsection 9.8) together with a
vanishing `Sum_mu {gamma^mu, Gamma_mu}` gives, for any frame on which that anticommutator
vanishes,

```
gamma^mu Gamma_mu = (1/2) (1/Sqrt[g]) d_mu( Sqrt[g] gamma^mu ) = -(1/2) T_mu gamma^mu,
T_mu = d_mu ln( e_mu^mu / det e )      (no sum; the Weitzenboeck torsion vector of a diagonal frame)
```

The second equality is a one-line computation for a diagonal frame, since `Sqrt[g] = det e` and
`gamma^mu = T16[mu]/e_mu^mu` **[derived here]**. This links the canonical connection directly to
the fable-5.1 bridge: the connection term of the Dirac operator is the Weitzenböck torsion vector.
On the canonical frame `T_mu = d_mu ln Sin[6Hx0]` (subsection 9.10), and the rescaling by
`Exp[(1/2) ln Sin] = Sqrt[Sin[6Hx0]]` removes it. **[proved VII §27]** `SPIN CONNECTION [has content]: Part V restated -- omega^W == 0 in the canonical frame, omega^LC == -contortion, T_mu == d_mu Log[Sin[6 H x0]], R == -T + B, and gamma^mu Gamma_mu == -(1/2) T_mu gamma^mu` (on the canonical frame); and on the time-dependent warped frames of the coupled system, Part VIII, Section 32: `WEITZENBOECK [THE RESULT]: the torsion vector of the warped frame is a GRADIENT, T_mu == d_mu Log[Sin[6 H x0]/(A^3 B^3 C)]; on the canonical member it is Part V's torsionVectorFable51`, `WEITZENBOECK [THE RESULT]: gamma^mu Gamma_mu == -(1/2) T_mu gamma^mu on the warped frame -- one vector term, a gradient`.

#### 9.12.4 It enters neither the canonical anticommutator nor the symmetrized Hamiltonian density

The admissible theory is a dimensional reduction `Psi = Psi(x0, x1, x2, x3, x4)`. It uses a
finite hidden coordinate volume `V_hid = Int dx5 dx6 dx7`, which is an assumption: compact timelike
directions contain closed timelike curves. Time is `x4`. The canonical anticommutator on a slice
`x4 = y4` is

```
{Psi_a(x), Psi^ddag_b(y)} = ( H / (V_hid Sqrt[|g|]) ) G_ab delta^4(x0..x3 - y0..y3),       G = -i sigma16 gamma^4
```

**[proved VII §28]** `DIRAC BRACKET [THE RESULT]: {Theta_i, Theta_j} = (Omega^-1)_ij gives {Psi_a, Psi^ddag_b} == i (K^-1)_ab == (Gtilde^-1)_ab and {Psi_a, Psi_b} == 0`, `ANTICOMMUTATOR [THE RESULT]: on the canonical frame (c = Sqrt[g]/H) {Psi, Psi^ddag} == (H/Sqrt[g]) J == H Cos[6 H x0] J  (J^-1 == J), which IS the design's (H/Sqrt[g])(-i sigma16 gamma^4)`. No spin connection appears in
it. It is fixed by the coefficient of `d_4 Psi` in the Lagrangian, and `Gamma_4 = 0` in any case.
On the canonical frame `gamma^4 = T16[4]`, so `G = -i T16[0].T16[1].T16[2].T16[3].T16[4] = J`
**[derived here]**. `J` is the fundamental symmetry of subsection 9.12.6.

The Hamiltonian density of the symmetrized Lagrangian is

```
Hdens = Sqrt[g] [ -(1/(2H)) Sum_{k != 4} ( Psibar gamma^k d_k Psi - d_k Psibar gamma^k Psi ) + V(s) ]
```

and it contains **no spin connection** **[proved VII §28]** `HAMILTONIAN [THE RESULT]: the Hamiltonian density Pi_Psi d_4 Psi + d_4 Psibar Pi_Psibar - L of the symmetrized Lagrangian is Sqrt[g][-(1/(2H)) Sum_{k != 4}(Psibar gamma^k d_k Psi - d_k Psibar gamma^k Psi) + V]: NO spin connection (fields of all eight coordinates)`.
This follows from 9.12.2: the symmetrized `Lhat` does not depend on the connection. The connection
re-emerges in the equation of motion. Integrating the symmetrized spatial derivative terms by
parts produces
`gamma^mu Gamma_mu = (1/2)(1/Sqrt[g]) d_mu( Sqrt[g] gamma^mu )` (subsection 9.12.3), because the
volume factor and the curved gammas depend on `x0`. **[proved VII §28]** `HAMILTONIAN [THE RESULT]: (Sqrt[g]/H) sigma16 (gamma^mu D_mu Psi - H V' Psi) == i Gtilde d_4 Psi - h Psi for admissible Psi(x0..x4): the field equation is i Gtilde d_4 Psi = h Psi`, `HAMILTONIAN [THE RESULT]: (1/2) Sum_{mu != 4} d_mu(Sqrt[g] sigma16 gamma^mu) == Sqrt[g] sigma16 Sum gamma^mu Gamma_mu, and d_4(Sqrt[g] sigma16 gamma^4) == 0: the connection term is the one that makes h Hermitian`.

The same rescaling organizes the one-particle space. `Sqrt[g] dx0 |Psi|^2 = |Psi'|^2 dz` for
`Psi' = Psi / Sqrt[Sin[6Hx0]]`, where `z = -Log[Cos[6Hx0]]/(6H)` is proper distance along `x0`. So the
one-particle space of `Psi'` is `L^2(dz)`. The `x0`-operator is regular at the wall `z = 0` and
needs a boundary condition there. The Lorentz-covariant, `J`-compatible ones are
`T16[0] Psi' = +-Psi'` at `z = 0`. It is limit-point at `z -> infinity`, where no condition is
needed. **[proved VII §28]** `BOUNDARY [has content]: the x0 direction in proper distance z = -Log[Cos[6 H x0]]/(6 H): dz/dx0 == Tan[6Hx0] == Sec Sin (so Sqrt[g] dx0 |Psi|^2 = |Psi'|^2 dz), z(0) == 0 and z -> infinity at 6 H x0 -> Pi/2, gamma^0 d_0 == T16[0] d_z, and Sin[6Hx0] == Sqrt[1 - Exp[-12 H z]] (bounded frame factors)`, `BOUNDARY [THE RESULT]: the bag condition T16[0] Psi' = +-Psi' at the wall -- T16[0]^2 == 1, {beta, T16[0]} == 0, the normal-flux form vanishes on both eigenspaces (P beta T16[0] P == 0), and [J, T16[0]] == 0`.

#### 9.12.5 It does not drop out of the energy–momentum tensor

The energy–momentum tensor operator is

```
That_{mu nu} = -(1/(4H)) [ Psibar gamma_mu D_nu Psi - (D_nu Psibar) gamma_mu Psi + (mu <-> nu) ] + g_{mu nu} Lhat,     gamma_mu = g_{mu nu} gamma^nu
```

This is the Hilbert (symmetric-tetrad) tensor of the symmetrized action, and it equals the
covariant tensor `T_cov` off shell. It is **built with `D`, not `d`**. The difference from the
tensor `T_par` built with partial derivatives is **[derived here]**

```
T_cov_{mu nu} - T_par_{mu nu} = -(1/(4H)) Psibar ( {gamma_mu, Gamma_nu} + {gamma_nu, Gamma_mu} ) Psi
```

The `g_{mu nu} Lhat` terms agree by 9.12.2. For `mu = nu` the difference is
`-(1/(2H)) Psibar {gamma_mu, Gamma_mu} Psi = 0` by the per-`mu` anticommutator, because
`gamma_mu = g_{mu mu} gamma^mu` on the diagonal frame. So the energy density and all the pressures
are the same with `D` or `d`. Not every off-diagonal component differs. The `(0,4)` component
coincides, because `Gamma_0 = Gamma_4 = 0`. The `(5,6)` component coincides too, because there the
two anticommutators cancel **[derived here]**: `gamma_5 = -p T16[5]`, `gamma_6 = -p T16[6]`, the
coefficients of `Gamma_5` and `Gamma_6` are equal, and `T16[5].T16[a].T16[6] = -T16[6].T16[a].T16[5]`
for `a = 0, 4`. The pair at which the notebook shows the two tensors to differ is given in the third
item below.

- **[proved VII §29]** Hilbert `==` `T_cov`, via a first-order symmetric perturbation of the frame, `EMT [THE RESULT]: the Hilbert (symmetric-tetrad) tensor of the symmetrized action IS That, OFF shell -- components (x1,x1), (x4,x4), (x1,x4), (x0,x5), (x5,x4)`.
- **[proved VII §29]** the piece coming from the variation of the spin connection is zero, `EMT [has content]: the spin-connection variation contributes NOTHING -- dropping it leaves the Hilbert tensor unchanged at (x1,x4), (x0,x5), (x5,x4)`. The Lagrangian depends on the connection only through `Sum_mu {gamma^mu, Gamma_mu} = (1/2) omega_[cab] gamma^{cab}` (subsection 9.8), and under a symmetric variation of the tetrad `delta omega_[cab] = 0`. So the spin-connection variation contributes **exactly nothing**. The covariant terms of `That` come from the dependence of `{gamma^mu, Gamma_mu}` on the frame. A partial-derivative Lagrangian must never be varied with respect to the frame. (Part VI's Text cell described this contribution as "a term antisymmetric in mu, nu that drops from the symmetrised tensor". The statement above is the sharper one.)
- **[proved VII §29]** Hilbert `!=` `T_par`, witnessed on the non-vacuous pair `(x1, x4)` (the pairs `(0,4)` and `(5,6)` coincide on the canonical frame, as shown above), `EMT [control]: the Hilbert tensor is NOT the partial-derivative tensor: at (x1,x4) they differ -- witnessed on constant spinors (Psibar = e1, Psi = e11: (T16[4] T16[1] T16[0])_{1,11} != 0)`.
- **[proved VII §29]** `T_cov` is conserved on shell, `EMT CONSERVATION [THE RESULT]: nabla^mu That_{mu nu} == 0 ON SHELL in all eight components, for generic Psi(x0, x4), Psibar(x0, x4) and generic V`.

The real-field analogues are already proved. **[proved VI §24]** `"FABLE [definition]: T_cov is symmetric by construction"`.
**[proved VI §24]** `"FABLE [has content]: the diagonal of T_cov equals the diagonal of the partial-derivative tensor, for the generic Psi(x0, x4): rho and every pressure are the same in both"`.
**[proved VI §24]** `"FABLE [has content]: but the two tensors DIFFER off the diagonal -- witnessed on the (x3, x4) component T[[4,5]], a momentum density along the observed sheet, for the constant spinor e1 + e13 and V = s^2"`.
**[proved VI §24]** `"FABLE [THE RESULT]: nabla^mu T_{mu nu} == 0 ON SHELL in all eight components, for a generic Psi(x0, x4) -- the covariant tensor is the conserved one"`.
That only the covariant tensor is conserved, and `T_par` is not, is **[prose VI §24]**: the
divergence of `T_par` is not computed symbolically.

#### 9.12.6 The connection and the fundamental symmetry `J`

```
J = -i T16[0].T16[1].T16[2].T16[3].T16[4]        J^2 = ID16
```

`J` is the fundamental symmetry that gives the positive quantization of the admissible sector.
With `beta = -i T16[4]`, `sigma16 = J beta` holds, and the Hilbert adjoint is `Psi^dagger = Psi^ddag J`.
**[proved VII §28]** `J [THE RESULT]: sigma16 == J beta with beta = -i T16[4] Hermitian, beta^2 == 1; T16[0..3] Hermitian with beta T16[j] beta == -T16[j]: beta is the observer's Dirac adjoint`, `J [THE RESULT]: with Psi^dagger := Psi^ddag J:  Psibar = Psi^dagger beta (J sigma16 == beta),  Psi^ddag G = Psi^dagger (J G == ID16),  {Psi, Psi^dagger} == (H/Sqrt[g]) ID16 (G^-1 J == ID16): POSITIVE`.

`J^2 = ID16` follows directly **[derived here]**. The product `P = T16[0]...T16[4]` of five
mutually anticommuting matrices satisfies
`P^2 = (-1)^(5.4/2) T16[0]^2 ... T16[4]^2 = (+1)(1)(1)(1)(1)(-1) = -ID16`, so `(-iP)^2 = +ID16`.

The commutation rules also follow by counting sign changes **[derived here]**. A single `T16[a]`
anticommutes with the four factors of `P` other than itself and commutes with itself, if `a` is
in `{0..4}`. It anticommutes with all five if `a` is in `{5,6,7}`. Hence `J` **commutes** with
`T16[0..4]` and **anticommutes** with `T16[5], T16[6], T16[7]`. Applying this to the explicit
`Gamma_mu` of subsection 9.7:

| object | relation to `J` | reason |
|---|---|---|
| `Gamma_0 = Gamma_4 = 0` | commute | zero |
| `Gamma_j` (`j = 1,2,3`) | **commute** | made of `T16[0].T16[j]`, `T16[4].T16[j]`, all factors in `{0..4}` |
| `Gamma_k` (`k = 5,6,7`) | **anticommute** | made of `T16[0].T16[k]`, `T16[4].T16[k]`: one factor in `{0..4}`, one in `{5,6,7}` |
| each `gamma^mu Gamma_mu` (no sum), and their sum | **commute** | each is `alpha_mu T16[0] + beta_mu T16[4]` (subsection 9.8) |

The hidden components `Gamma_5`, `Gamma_6` and `Gamma_7` are `J`-odd. They enter the Dirac
operator only through `gamma^k Gamma_k`, a product of two `J`-odd matrices, which is `J`-even. So
every term of the admissible-sector Hamiltonian, the connection term included, is `J`-even.
The `J`-odd objects, namely the `(0,h)`, `(i,h)` and `(4,h)` components of `T_cov` and the hidden
momenta `P_h` (`h = 5,6,7`), are nonzero operators with zero expectation in `J`-eigenmode Fock
states. **[proved VII §28]** `J TABLE [THE RESULT]: J commutes with sigma16, T16[0..4], sigma16 gamma^mu (mu = 0..4), every gamma^mu Gamma_mu and Gamma_1..Gamma_3; it ANTIcommutes with T16[5..7], sigma16 gamma^h (h = 5..7), Gamma_5..Gamma_7, T16[8] and C+`. The same `J` table holds on the dynamical
(warped and Bianchi-I) frames of the coupled system. Part VIII, Section 32, proves it:
`J [THE RESULT]: [J, gamma^mu Gamma_mu] == 0 for EACH mu separately (h = 5,6,7 included), on the warped and on the Bianchi-I frame`, `J [THE RESULT]: [J, Gamma_mu] == 0 for mu = 0..4 and {J, Gamma_h} == 0 for h = 5, 6, 7, on the warped and on the Bianchi-I frame` and
`J [has content]: the anticommuting Gamma_h are not zero (witnessed on A = 1 + x4/2, B = 1 + x4/3, C = 1 + x4^2/3), so {J, Gamma_h} == 0 is not vacuous`.

### 9.13 Status ledger

| statement | status | where (notebook Part and Section; assertion tag) |
|---|---|---|
| frame `e`, `g = e . eta . e^T`, stated line element, signature (4,4) | proved | III §15 |
| `a4` is free and never given a value | proved | VI §25, VII §29 and VIII (controls); notice printed in III §15 |
| `det g = Sec[6Hx0]^2`; `Sqrt[Abs[det g]] = Sec[6Hx0]` on `0 < 6Hx0 < Pi/2` | displayed; proved | displayed III §15; proved V §21 |
| 37 Christoffel symbols; symmetric in the lower indices; metric compatible | displayed; proved | III §16; VI §23 |
| the vielbein postulate is solved by `cfSpinConnection` (residual zero) | proved (solver regression) | III §16 |
| the 24 non-zero components of `omegaCanonical` | displayed; independent frame-only derivation proved; count 24 proved | III §16; VII §27 (`SPIN CONNECTION [has content]`) |
| antisymmetry in the flat indices (metric compatibility) | proved (has content) | III §16; VII §27 |
| torsion-free | proved (structural) | III §16 |
| curvature: 156 components; Ricci scalar | displayed | III §16 |
| `Gamma_mu = (1/8) omega_{mu ab} [T16[a], T16[b]]`; sign and coefficient fixed by compatibility | proved (with control) | III §17; VII §27 (`SPIN CONNECTION [definition]`) |
| block-diagonal; type-1 and type-2 blocks; `Dcov16` = direct sum | proved | III §17 |
| covariant constancy of `gamma^mu` | proved | III §17 |
| `(1/Sqrt[g]) d_mu(Sqrt[g] gamma^mu) = [gamma^mu, Gamma_mu]` | proved | VI §24; VII §27 (`FIELD EQUATION [has content]`) |
| `Sum_mu {gamma^mu, Gamma_mu} = 0`; `gamma^mu Gamma_mu = -3 H Cot^2 T16[0]` | proved | VI §24; VII §27 |
| per-direction `gamma^mu Gamma_mu = alpha_mu T16[0] + beta_mu T16[4]`, `Sum alpha = -3 H Cot^2`, `Sum beta = 0`; anticommutator zero for each `mu` | derived here; proved | VII §27 (`SPIN CONNECTION [THE RESULT]`, `LAGRANGIAN (c) [THE RESULT]`) |
| Bridges 1 and 2: the same connection in a local / constant gauge, at vector and spinor level | proved | IV §18, IV §19; restated VII §27 |
| Bridge 3: a different connection; torsion `-2 lambda mSkew`; curvature of degree 2 in `lambda`; Ricci shift `-42 lambda^2 = -(1/4) T.T` | proved | IV §20; restated VII §27 |
| fable-5.1: `omega = 0`, zero curvature, `omega^LC = -contortion(T)`, `T_mu = d_mu Log[Sin[6Hx0]]`, axial part zero, `R = -T + B` | proved | V §21; restated VII §27 |
| `gamma^mu Gamma_mu = -(1/2) T_mu gamma^mu`; the rescaling `Psi = Sqrt[Sin[6Hx0]] Psi'` | proved | V §21; VI §24; VII §27 (`SPIN CONNECTION [has content]`, `WRITTEN OUT (iv)`); VIII §32 on the warped frames (`WEITZENBOECK`, `RESCALING`) |
| Bridge 1's gauge term is the fable-5.1 connection of the boosted frame | proved | V §21 |
| master table of the five connections | displayed | V §22 |
| complex fable: the connection drops out of the symmetrized `L` because the matrix `{gamma^mu, Gamma_mu}` vanishes | proved | VII §27 (`LAGRANGIAN (c) [THE RESULT]`) |
| unsymmetrized covariant `L` = symmetrized + divergence; unsymmetrized partial `L` inadmissible | proved | VII §27 (`LAGRANGIAN (d)`, `(e)`, `(f)`) |
| field equations; connection term `-3 H Cot^2 T16[0]`; 8+8 form; rescaling; frame-independent form | proved | VII §27 (`FIELD EQUATION`, `WRITTEN OUT (i)–(iv)`, `SPIN CONNECTION`); VIII §32 |
| no connection in the canonical anticommutator or in the symmetrized Hamiltonian density; the connection makes `h` Hermitian | proved | VII §28 (`QUANTIZATION [has content]: Gamma_4 == 0`, `ANTICOMMUTATOR`, `HAMILTONIAN`) |
| EMT: Hilbert `= T_cov`; spin-connection variation zero; Hilbert `!= T_par`; `T_cov` conserved | proved | VII §29 (`EMT`, `EMT CONSERVATION`) |
| `J` commutes with each `gamma^mu Gamma_mu` and with `Gamma_0..Gamma_4`, and anticommutes with `Gamma_5..Gamma_7` | derived here; proved | VII §28 (`J TABLE [THE RESULT]`); VIII §32 on the warped and Bianchi-I frames (`J [THE RESULT]`) |

## 10. How it was verified

### 10.1 Part VII of the notebook: sections, cells, assertions

Part VII is the manifest `claude-fable/cells_part7.wl` (1777 lines; 170 `cfAssert` calls). Built into
the notebook by `claude-fable/build_tools.py` (section 11.1), it adds 26 Input cells, 173–198, to the
172 of Parts I–VI. The section-to-cell map is printed by `claude-fable/nb_section_map.wls`
(`claude-fable/nb_section_map.log`, section 11.4):

| notebook Section | subject | Input cells | assertions | seconds (sum of the cells' times) | this page |
|---|---|---|---|---|---|
| 26 | the refinement: why fermion fable is a complex 16-spinor | 173–179 | 38 | 1.957 | 3 |
| 27 | the Lagrangian, the field equations in the primordial gravitational field, and the canonical spin connection | 180–184 | 36 | 2.291 | 4, 5, 9 |
| 28 | canonical quantization in 4+4 dimensions: the Dirac bracket, the Krein structure `J`, and the admissible sector | 185–191 | 56 | 12.311 | 6 |
| 29 | the energy–momentum tensor operator: definition, conservation, and `rho`, `P` and `w` | 192–198 | 40 | 17.874 | 7, 8 |
| **Part VII** | | **26 cells** | **170** | **34.433** | |

The counts and times per cell, read from `claude-fable/run_fermion_fable_part7.log` (each cell's
`PASS` lines are printed before its `CELL n  t=...` line):

| cell | 173 | 174 | 175 | 176 | 177 | 178 | 179 | 180 | 181 | 182 | 183 | 184 | 185 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| assertions | 4 | 2 | 9 | 7 | 7 | 4 | 5 | 10 | 5 | 3 | 5 | 13 | 5 |
| seconds | 0.016 | 0.541 | 0.117 | 0.592 | 0.053 | 0.064 | 0.574 | 1.005 | 0.403 | 0.395 | 0.209 | 0.279 | 0.062 |

| cell | 186 | 187 | 188 | 189 | 190 | 191 | 192 | 193 | 194 | 195 | 196 | 197 | 198 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| assertions | 5 | 9 | 10 | 9 | 6 | 12 | 5 | 4 | 7 | 3 | 11 | 9 | 1 |
| seconds | 0.017 | 0.344 | 0.129 | 0.221 | 1.680 | 9.858 | 2.248 | 4.431 | 4.080 | 2.098 | 4.945 | 0.072 | 0.000 |

The 170 assertions by tag (the text of a label before its first `[`), counted from the log:

| tag | count | | tag | count |
|---|---|---|---|---|
| `REFINEMENT` | 6 | | `ADMISSIBILITY` (all items) | 10 |
| `GRASSMANN` | 9 | | `HAMILTONIAN` | 7 |
| `REFINEMENT (a)`, `(b)`, `(c)`, `(d)` | 3, 3, 1, 7 | | `BOUNDARY` | 2 |
| `4D` | 4 | | `KREIN MODES` | 6 |
| `FIDELITY` | 5 | | `FOCK`, `FOCK (field level)`, `FOCK (mode level)` | 1, 4, 6 |
| `LAGRANGIAN (a)`–`(f)` | 1, 2, 1, 1, 2, 3 | | `CHARGE` | 1 |
| `FIELD EQUATION` | 5 | | `EMT` | 8 |
| `CURRENT` | 3 | | `EMT CONSERVATION`, `EMT ON SHELL`, `EMT HERMITICITY` | 3, 3, 2 |
| `SPIN CONNECTION` | 5 | | `MODE SUMS`, `VACUUM` | 2, 1 |
| `WRITTEN OUT (i)`–`(iv)` | 2, 3, 3, 3 | | `KOHN-SHAM`, `MEAN FIELD` | 5, 1 |
| `SYMMETRY` | 2 | | `AUTHOR'S MASS TERM`, `CLASSICAL LIMIT` | 4, 1 |
| `QUANTIZATION` | 5 | | `PRE-UNIVERSE (1)`–`(4)` | 2, 2, 2, 2 |
| `DIRAC BRACKET`, `ANTICOMMUTATOR` | 3, 2 | | `PART VII` | 1 |
| `J`, `J TABLE` | 8, 1 | | "no identity in this notebook was accepted on numerical evidence alone" | 1 |

By grade: the labels carry `[THE RESULT]` (a headline result), `[has content]` (a statement that
could have failed), `[definition]`, `[structural]`, `[solver regression]` (a check of the code),
`[control]` (the wrong alternative is shown to fail) and `[fidelity]` (agreement with the author's
or an earlier Part's objects).

**The final tally and the run summary**, verbatim from the end of
`claude-fable/run_fermion_fable_part7.log`:

```
identities accepted on numerical evidence alone : 0   (stage 3 returned True)
non-vanishing witnesses                         : 38   (cfNonZeroWitnessQ found a probe point at which every entry is a
                                                     number and one of them is non-zero: a complete proof of non-vanishing)
  PASS  no identity in this notebook was accepted on numerical evidence alone
Assertions run: 528   passed: 528   failed: 0
CELL 198  t=0.000 s
==================== RUN SUMMARY ====================
cells evaluated : 198
total seconds   : 232.146
cells w/ msgs   : 0
---- slowest cells ----
  cell 80  89.913 s
  cell 88  27.790 s
  cell 86  11.167 s
  cell 87  10.303 s
  cell 191  9.858 s
  cell 137  8.740 s
  cell 160  6.445 s
  cell 121  5.401 s
  cell 196  4.945 s
  cell 193  4.431 s
  cell 107  4.158 s
  cell 194  4.080 s
==================== ASSERTIONS ====================
assertions run  : 528
passed          : 528
FAILED          : 0
====================================================
RUN-DONE

```

So through Part VII: 198 Input cells, **528 assertions, 528 passed, 0 failed**, **0 cells with
messages**, **0 identities accepted on numerical evidence alone** (every identity is closed
symbolically; the notebook's last assertion is `no identity in this notebook was accepted on numerical evidence alone`), and **38 non-vanishing witnesses** (19 from Parts I–V, 8 more from Part VI, 11 more
from Part VII: the Part V and Part VI tallies in the same log print 19 and 27). Parts I–VI account
for 358 of the assertions; Part VII adds 170. The whole run took 232.146 s; the slowest cells are
Part II's (cell 80, the bilinears of the author's closed-form solution, 89.913 s). The last line,
`RUN-DONE`, is not printed by `run_from_nb.wls`: it was appended by the shell wrapper that ran it.

### 10.2 Every Part VII assertion, verbatim

This is the complete output of Input cells 173–198 in `claude-fable/run_fermion_fable_part7.log`
(lines 634–844), from the line that closes cell 172 to the line that closes cell 198. Every label is
printed after `PASS`; a bracketed `[t s]` line is a timing printed by `cfTimed`.

```
CELL 172  t=0.000 s
  PASS  REFINEMENT [definition]: T16[8]^2 == sigma16^2 == C+^2 == ID16, C+ is symmetric, and C+ . T16[8] == sigma16 -- the four candidate mass matrices are only two
  PASS  REFINEMENT [has content]: C- T16[a] C-^-1 == -T16[a]^T and C+ T16[a] C+^-1 == +T16[a]^T for a = 0..7
  PASS  REFINEMENT [THE RESULT]: the symmetry of C Gamma depends only on the rank r of Gamma:  C-: S A A S S A A S S,  C+: S S A A S S A A S  (r = 0..8)
  PASS  REFINEMENT [has content]: for each C, 136 of the 256 products are symmetric and 120 antisymmetric
CELL 173  t=0.016 s
  PASS  REFINEMENT [THE RESULT]: the Spin(4,4)-invariant bilinear forms on the 16-spinor form a 2-dimensional space, spanned by C- = sigma16 and C+ = sigma16 T16[8]
  PASS  REFINEMENT [has content]: every invariant form is SYMMETRIC and chirality-diagonal, and the two chiral pieces PL sigma16 PL and PR sigma16 PR are invariant separately
CELL 174  t=0.541 s
  PASS  GRASSMANN [solver regression]: generators anticommute and square to zero (all pairs of 1..6)
  PASS  GRASSMANN [solver regression]: the product is associative, (x y) z == x (y z), on elements of degree 1, 2, 3 (and the products tested are not zero)
  PASS  GRASSMANN [solver regression]: graded commutativity  x y == (-1)^(|x| |y|) y x  (degrees 1, 2, 3), and x^2 == 0 for x odd
  PASS  GRASSMANN [solver regression]: the conjugation is an involutive anti-automorphism,  (x y)^ddag == y^ddag x^ddag,  (x^ddag)^ddag == x
  PASS  GRASSMANN [solver regression]: grD is an even derivation, d(x y) == d(x) y + x d(y);  grDL obeys d_i(x y) == d_i(x) y + (-1)^|x| x d_i(y)
  PASS  GRASSMANN [THE RESULT]: theta^T N theta == theta^T N_A theta and theta^T N_S theta == 0 for a general 16x16 N -- an anticommuting bilinear sees only the ANTISYMMETRIC part
  PASS  GRASSMANN [THE RESULT]: theta^T N phi - (1/2) d(theta^T N theta) == theta^T N_S phi for a general N
  PASS  GRASSMANN [THE RESULT]: the Euler-Lagrange expression of L = theta^T N phi (left derivatives) is (N + N^T) phi: EMPTY field equations exactly when N is antisymmetric
  PASS  GRASSMANN [control]: for COMMUTING components the roles are reversed -- theta^T N theta sees only N_S, and the Euler-Lagrange expression of theta^T N phi is 2 N_A phi
CELL 175  t=0.117 s
  PASS  REFINEMENT (a) [THE RESULT]: real Grassmann + sigma16: both invariant mass terms vanish, and theta^T sigma16 T16[a] phi == (1/2) d(theta^T sigma16 T16[a] theta) for every a (a total derivative)
  PASS  REFINEMENT (a) [has content]: its Euler-Lagrange expression is identically empty in every direction -- while the kinetic term itself is NOT zero
  PASS  REFINEMENT (a) [THE RESULT]: FRAME-INDEPENDENT -- sigma16 {T16[a], S^bc} is SYMMETRIC for all a, b, c (so theta^T sigma16 {gamma^mu, Gamma_mu} theta == 0 on every frame), and d_mu(Sqrt[g] sigma16 gamma^mu) == Sqrt[g] sigma16 [gamma^mu, Gamma_mu] on the canonical frame
  PASS  REFINEMENT (b) [THE RESULT]: Majorana with C+: the kinetic term is genuine -- Euler-Lagrange expression 2 C+ T16[a] phi with C+ T16[a] invertible -- but every invariant bilinear vanishes (massless, no V(s))
  PASS  REFINEMENT (b) [has content]: the scope -- the quartic Lorentz scalars v.v, B.B, C.C of the Majorana spinor are NOT zero and are all proportional to ONE quartic (same monomials, one constant ratio each)
  PASS  REFINEMENT (b) [has content]: and the commuting shadow of the C+ Majorana spinor has NO kinetic term: for commuting components theta^T C+ T16[a] phi is the total derivative (1/2) d(theta^T C+ T16[a] theta)
  PASS  REFINEMENT (c) [THE RESULT]: Weyl and Majorana-Weyl: PL C T16[a] PL == PR C T16[a] PR == 0 for C = C-, C+ and every a (C chirality-diagonal, T16[a] chirality-odd) -- no kinetic term
CELL 176  t=0.592 s
  PASS  REFINEMENT (d) [definition]: Psi^ddag == (theta1 - i theta2)^T/Sqrt[2] in the algebra
  PASS  REFINEMENT (d) [THE RESULT]: s = Psibar Psi == i theta1^T sigma16 theta2: NON-ZERO (16 monomials) and HERMITIAN; p = Psibar T16[8] Psi is non-zero and Hermitian too
  PASS  REFINEMENT (d) [has content]: s is a sum of 16 commuting nilpotent even elements x_a (x_a x_b == x_b x_a, x_a^2 == 0), so s^17 == 0 and V(s) is a finite polynomial
  PASS  REFINEMENT (d) [definition]: the 32x32 matrix A read off the algebra reproduces Psi^ddag K phi exactly
  PASS  REFINEMENT (d) [THE RESULT]: its symmetric part is A_S == (i/2) Omega, Omega = [[0, K], [-K, 0]] real SYMMETRIC and invertible: a genuine kinetic term
  PASS  REFINEMENT (d) [has content]: the symmetrized kinetic term is HERMITIAN and equals Psi^ddag K phi - (1/2) d(Psi^ddag K Psi); the unsymmetrized one is not Hermitian
  PASS  REFINEMENT (d) [has content]: the same holds in every direction a = 0..7: the symmetrized Psi^ddag sigma16 T16[a] phi is Hermitian, with symmetric part (i/2)[[0, sigma16 T16[a]], [-sigma16 T16[a], 0]] != 0
CELL 177  t=0.053 s
  PASS  4D [THE RESULT]: the 16 ordered products of T16[1..4] are linearly independent (the observer's algebra is M4(C)), and its commutant in M16(C) is 16-dimensional
  PASS  4D [has content]: Omega4^2 == -ID16, the hidden gammas h_A = Omega4 T16[A] (A = 0,5,6,7) commute with T16[1..4] and obey {h_A, h_B} == -2 eta_AB
  PASS  4D [THE RESULT]: the 16 products of the hidden gammas span the commutant, and the two algebras meet only in the multiples of ID16 (rank of the union 16 + 16 - 1 = 31): C^16 = C^4 (x) C^4, four 4D Dirac fermions
  PASS  4D [has content]: the observer's Lorentz generators T16[i] T16[j] (i < j in 1..4) commute with every hidden gamma
CELL 178  t=0.064 s
  [0.024 s]  Euler-Lagrange expressions of the complex fable with respect to Psibar, generic (x0, x4)
  [0.023 s]  Euler-Lagrange expressions of the complex fable with respect to Psi, generic (x0, x4)
  PASS  FIDELITY [1] [fidelity]: Psi -> psi, Psibar -> psi^T sigma16 turns the symmetrized covariant Lhat into Part VI's cfLhatFable EXACTLY (canonical frame, generic V)
  PASS  FIDELITY [2] [fidelity]: on the flat frame with V = -(2M/H) s and no volume factor, the same limit on Psi16 IS the author's La[] of Section 11
  PASS  FIDELITY [3] [fidelity]: sigma16 . EL_Psibar + EL_Psi in the real limit == Part VI's explicit variation cfELFable, component for component
  PASS  FIDELITY [3] [fidelity]: and on the flat frame with V = -(2M/H) s the same combination IS the author's eLa of Section 12
  PASS  FIDELITY [4] [fidelity]: the energy-momentum tensor That in the real limit IS Part VI's covariant tensor cfTCov, all 64 components
CELL 179  t=0.574 s
  PASS  LAGRANGIAN (a) [definition]: every Gamma^spin_mu is real and sigma16 Gamma_mu is antisymmetric (Gamma_mu^T sigma16 == -sigma16 Gamma_mu): D_mu Psibar is the Dirac conjugate of D_mu Psi
  PASS  LAGRANGIAN (b) [THE RESULT]: Lsym is HERMITIAN -- real for Psi = u + i v, Psibar = (u - i v)^T sigma16, generic u, v of all eight coordinates
  PASS  LAGRANGIAN (b) [control]: Lun is NOT Hermitian -- its imaginary part is not zero, witnessed on the constant spinors u = e1, v = e13 (with V = s^2)
  PASS  LAGRANGIAN (c) [THE RESULT]: Lsym - Lsym_d == (1/(2H)) Sum_mu Psibar {gamma^mu, Gamma_mu} Psi identically, and {gamma^mu, Gamma_mu} == 0 for EACH mu on the canonical frame: Lsym == Lsym_d
  PASS  LAGRANGIAN (d) [has content]: Lun - Lsym == (1/(2H)) (1/Sqrt[g]) d_mu( Sqrt[g] Psibar gamma^mu Psi ), a total divergence
  PASS  LAGRANGIAN (e) [has content]: Lun - Lun_d == (1/H) Psibar gamma^mu Gamma_mu Psi == -3 Cot[6 H x0]^2 Psibar T16[0] Psi
  PASS  LAGRANGIAN (e) [control]: that term is NOT zero for a complex field (witness u = e1, v = e13), and IS zero in the real commuting limit (the scope of Parts V-VI)
  PASS  LAGRANGIAN (f) [THE RESULT]: Lun_d varied with respect to Psibar gives (Sqrt[g]/H)(gamma^mu d_mu Psi - H V' Psi): the connection term is MISSING
  PASS  LAGRANGIAN (f) [THE RESULT]: varied with respect to Psi it gives -(Sqrt[g]/H)((d_mu Psibar) gamma^mu + Psibar [gamma^mu, Gamma_mu] + H V' Psibar), with Psibar [gamma^mu, Gamma_mu] == 2 Psibar gamma^mu Gamma_mu: the connection term is PRESENT
  PASS  LAGRANGIAN (f) [control]: so Lun_d is INADMISSIBLE -- its two field equations are not Dirac conjugates: they differ by 2 Psibar gamma^mu Gamma_mu = -6 H Cot^2 Psibar T16[0], non-zero (witness u = e1, v = 0, V = s^2)
CELL 180  t=1.005 s
  [0.134 s]  Euler-Lagrange expressions with respect to Psibar, generic fields of all eight coordinates
  [0.118 s]  Euler-Lagrange expressions with respect to Psi, generic fields of all eight coordinates
  PASS  FIELD EQUATION [has content]: the identity the derivation uses -- (1/Sqrt[g]) d_mu(Sqrt[g] gamma^mu) == [gamma^mu, Gamma_mu] (covariant constancy, Section 17)
  PASS  FIELD EQUATION [THE RESULT]: EL_Psibar == (Sqrt[g]/H)(gamma^mu D_mu Psi - H V'(s) Psi) for generic Psi, Psibar of all eight coordinates: the field equation is gamma^mu D_mu Psi == H V'(s) Psi
  PASS  FIELD EQUATION [THE RESULT]: EL_Psi == -(Sqrt[g]/H)((D_mu Psibar) gamma^mu + H V'(s) Psibar): the adjoint equation is (D_mu Psibar) gamma^mu == -H V'(s) Psibar
  PASS  FIELD EQUATION [has content]: the adjoint equation IS the Dirac conjugate of the field equation: with Psi = u + i v, Psibar = (u - i v)^T sigma16, adjoint residual == -(field residual)^* . sigma16
  PASS  FIELD EQUATION [control]: the opposite sign, (D Psibar) gamma == +H V' Psibar, is NOT the conjugate -- witnessed on u = e1 + e5, v = 0 with V = s^2 (s = -2 there)
CELL 181  t=0.403 s
  PASS  CURRENT [THE RESULT]: the Noether current of the U(1) phase is (Sqrt[g]/H) i Psibar gamma^mu Psi
  PASS  CURRENT [has content]: i sigma16 gamma^mu is Hermitian for every mu, so j^mu is real
  PASS  CURRENT [THE RESULT]: OFF SHELL (1/Sqrt[g]) d_mu(Sqrt[g] j^mu) == i (Ebar Psi + Psibar E) for generic fields of all eight coordinates -- conserved on shell
CELL 182  t=0.395 s
  PASS  SPIN CONNECTION [has content]: metric compatible (omega_mu^{ab} antisymmetric) and every non-zero component is omega_mu^{mu 0} or omega_mu^{mu 4} (up to antisymmetry): omega_0 == omega_4 == 0
  PASS  SPIN CONNECTION [definition]: Gamma^spin_mu == Sum_{a<b} omega_mu,ab (1/2) T16[a] T16[b]
  PASS  SPIN CONNECTION [THE RESULT]: direction by direction gamma^mu Gamma_mu == alpha_mu T16[0] + beta_mu T16[4]; Sum alpha_mu == -3 H Cot[6 H x0]^2 and Sum beta_mu == 0 (the observed and hidden a4 terms cancel)
  PASS  SPIN CONNECTION [has content]: Parts IV-V restated -- Bridge 1's difference is the pure gauge term, Bridge 2 is a constant conjugate, Bridge 3 has totally antisymmetric torsion that is not zero
  PASS  SPIN CONNECTION [has content]: Part V restated -- omega^W == 0 in the canonical frame, omega^LC == -contortion, T_mu == d_mu Log[Sin[6 H x0]], R == -T + B, and gamma^mu Gamma_mu == -(1/2) T_mu gamma^mu
CELL 183  t=0.209 s
  PASS  WRITTEN OUT (i) [THE RESULT]: the field equation on the canonical frame is Cot T16[0] d_0 Psi + (1/q) T16[i] d_i Psi + T16[4] d_4 Psi + (1/p) T16[h] d_h Psi - 3 H Cot^2 T16[0] Psi == H V'(s) Psi
  PASS  WRITTEN OUT (i) [THE RESULT]: the adjoint equation is Cot d_0 Psibar T16[0] + ... - 3 H Cot^2 Psibar T16[0] == -H V'(s) Psibar (the connection enters with the sign fixed by {gamma^mu, Gamma_mu} = 0)
  PASS  WRITTEN OUT (ii) [THE RESULT]: the split-octonion 8+8 form -- the type-1 rows are the taubar equations for psi2, the type-2 rows the tau equations for psi1 (tau[0] == taubar[0] == ID8)
  PASS  WRITTEN OUT (ii) [THE RESULT]: the covariant 8+8 form -- rows 1..8 are e_a^mu taubar[a] (d_mu + Gamma^(2)_mu) psi2 - H V' psi1, rows 9..16 are e_a^mu tau[a] (d_mu + Gamma^(1)_mu) psi1 - H V' psi2; and the conjugate rows
  PASS  WRITTEN OUT (ii) [has content]: with Psibar = Psi^ddag sigma16 and sigma16 = diag(-sigma, sigma): s == -psi1^ddag sigma psi1 + psi2^ddag sigma psi2 (psibar1 = -psi1^ddag sigma, psibar2 = psi2^ddag sigma)
  PASS  WRITTEN OUT (iii) [definition]: the term lists reproduce all sixteen field equations and all sixteen adjoint equations exactly
  PASS  WRITTEN OUT (iii) [has content]: every component equation has exactly one derivative per coordinate x0..x7, the connection term multiplies the component carrying the x0-derivative, and -H V' multiplies psi_r itself
  PASS  SYMMETRY [THE RESULT]: the only internal U(1) is the vector phase -- the commutant of all eight T16[a] in M16(C) is one-dimensional (multiples of ID16)
  PASS  SYMMETRY [has content]: the axial phase exp(i alpha T16[8]) leaves s invariant but not the kinetic term: exp(-i alpha T8) T16[a] exp(i alpha T8) == T16[a] exp(2 i alpha T8), so Psibar gamma^mu d_mu Psi changes at first order by 2 i alpha Psibar gamma^mu T16[8] d_mu Psi, which is not zero (witness)
  PASS  WRITTEN OUT (iii) [has content]: for fields of all eight coordinates the sixteen equations form ONE coupled block (the four blocks of four of Section 13 belong to the (x0, x4) reduction)
  PASS  WRITTEN OUT (iv) [THE RESULT]: Psi = Sqrt[Sin[6Hx0]] Psi' turns the field equation into Sqrt[Sin] (Cot T16[0] d_0 Psi' + (1/q) T16[i] d_i Psi' + T16[4] d_4 Psi' + (1/p) T16[h] d_h Psi' - H V'(Sin s') Psi'): NO connection term
  PASS  WRITTEN OUT (iv) [THE RESULT]: and the adjoint equation into Sqrt[Sin] (Cot d_0 Psi'bar T16[0] + ... + H V'(Sin s') Psi'bar), with no connection term either
  PASS  WRITTEN OUT (iv) [definition]: under the rescaling s == Sin[6 H x0] s',  s' = Psi'bar Psi'
CELL 184  t=0.279 s
  PASS  QUANTIZATION [definition]: lapse 1 and shift 0 (g_44 == -1, g_4mu == 0), and the slice x4 = const has signature (4,3) -- x0..x3 spacelike, x5..x7 timelike (given a4 real and 0 < 6 H x0 < Pi/2)
  PASS  QUANTIZATION [THE RESULT]: the momenta of Lsym are Pi_Psi == (Sqrt[g]/(2H)) Psibar gamma^4 and Pi_Psibar == -(Sqrt[g]/(2H)) gamma^4 Psi
  PASS  QUANTIZATION [has content]: theta_un - theta_sym == delta[(Sqrt[g]/(2H)) Psibar gamma^4 Psi] exactly: the same symplectic form, the same brackets
  PASS  QUANTIZATION [THE RESULT]: G = -i sigma16 gamma^4 == J = -i T16[0].T16[1].T16[2].T16[3].T16[4] on the canonical frame; J is Hermitian, J^2 == ID16, eigenvalues +1 (8) and -1 (8): signature (8,8)
  PASS  QUANTIZATION [has content]: Gamma_4 == 0 -- the time-derivative part of the Lagrangian, which fixes the anticommutator, contains no spin connection
CELL 185  t=0.062 s
  PASS  DIRAC BRACKET [THE RESULT]: in the Grassmann algebra Psi^ddag K phi == (i/2) Theta^T Omega_c Phi + (1/4) d(theta1^T K theta1 + theta2^T K theta2), for K = c sigma16 T16[4] with a free scalar c
  PASS  DIRAC BRACKET [has content]: Omega_c is real symmetric and invertible, Omega_c^-1 == [[0, -K^-1], [K^-1, 0]]
  PASS  DIRAC BRACKET [THE RESULT]: {Theta_i, Theta_j} = (Omega^-1)_ij gives {Psi_a, Psi^ddag_b} == i (K^-1)_ab == (Gtilde^-1)_ab and {Psi_a, Psi_b} == 0
  PASS  ANTICOMMUTATOR [THE RESULT]: on the canonical frame (c = Sqrt[g]/H) {Psi, Psi^ddag} == (H/Sqrt[g]) J == H Cos[6 H x0] J  (J^-1 == J), which IS the design's (H/Sqrt[g])(-i sigma16 gamma^4)
  PASS  ANTICOMMUTATOR [has content]: the rescaled field Psi' = Psi/Sqrt[Sin[6 H x0]] has {Psi', Psi'^ddag} == H Cot[6 H x0] J delta^7, and Sqrt[g] is x4-independent (so quantizing chi = (Sqrt[g]/H)^(1/2) Psi changes nothing on the canonical frame)
CELL 186  t=0.017 s
  PASS  J [THE RESULT]: J == -i Omega4 T16[0] == -i h_0 is a hidden flavour gamma: it lies in the commutant of T16[1..4] (in the span of the hidden-gamma products of Section 26)
  PASS  J [has content]: on the flavour factor J has signature (2,2): cfIdemObs is a rank-4 projector commuting with J, and J restricted to its image has eigenvalues +1, +1, -1, -1
  PASS  J [THE RESULT]: sigma16 == J beta with beta = -i T16[4] Hermitian, beta^2 == 1; T16[0..3] Hermitian with beta T16[j] beta == -T16[j]: beta is the observer's Dirac adjoint
  PASS  J [THE RESULT]: with Psi^dagger := Psi^ddag J:  Psibar = Psi^dagger beta (J sigma16 == beta),  Psi^ddag G = Psi^dagger (J G == ID16),  {Psi, Psi^dagger} == (H/Sqrt[g]) ID16 (G^-1 J == ID16): POSITIVE
  PASS  J TABLE [THE RESULT]: J commutes with sigma16, T16[0..4], sigma16 gamma^mu (mu = 0..4), every gamma^mu Gamma_mu and Gamma_1..Gamma_3; it ANTIcommutes with T16[5..7], sigma16 gamma^h (h = 5..7), Gamma_5..Gamma_7, T16[8] and C+
  PASS  J [has content]: the Hermiticity rule -- for classically Hermitian M, (J M)^dagger == J M iff [J, M] == 0 and == -J M iff {J, M} == 0: so s = Psi^ddag sigma16 Psi is Hermitian and p = Psi^ddag C+ Psi is ANTI-Hermitian
  PASS  J [THE RESULT]: 13 of the 28 Lorentz generators commute with J (a, b both in {0..4}: Spin(4,1), or both in {5,6,7}: Spin(3)); the other 15 anticommute -- 12 boosts x0..x3 <-> x5..x7 and 3 rotations x4 <-> x5..x7
  PASS  J [has content]: the Krein form G is invariant (S^T G + G S == 0) under exactly the 21 generators with a, b != 4 -- Spin(4,3), the group of the slice
  PASS  J [has content]: chirality -- {J, T16[8]} == 0, each chirality subspace is G-NULL (PL G PL == PR G PR == 0), and the two chiralities are orthogonal in the Hilbert product (PL, PR Hermitian, PL PR == 0)
CELL 187  t=0.344 s
  PASS  ADMISSIBILITY (1) [THE RESULT]: E_k^2 == (k_s^2 - k_h^2 + m^2) ID16 for every k: omega^2 = k_s^2 - k_h^2 + m^2
  PASS  ADMISSIBILITY (2) [THE RESULT]: for admissible k (k_h = 0), [J, E_k] == 0, E_k is J-Hermitian, and G J == ID16 is positive: J quantizes every admissible momentum positively
  PASS  ADMISSIBILITY (3) [THE RESULT]: below threshold (k = 5 e1 + 3 e5, m = 3) the boosted J' = S^-1 J S commutes with E_k and beta, J'^2 == 1, and G J' == S^2 is Hermitian positive definite
  PASS  ADMISSIBILITY (4) [THE RESULT]: AT threshold (k = 4 e1 + 5 e5, m = 3) E_k != 0 but E_k^2 == 0: nilpotent, not diagonalizable (rank 8: Jordan blocks of size 2)
  PASS  ADMISSIBILITY (5) [THE RESULT]: ABOVE threshold (k = (0, 3/4, 1, 0 | k5 = 2), m = 1) omega^2 == -23/16: every eigenvalue of E_k is +-i Sqrt[23]/4 = +-1.19896 i and every eigenvector is G-NEUTRAL (u^dagger G u == 0)
  PASS  ADMISSIBILITY [has content]: the general identity [E_k, beta] == 2 i T_k, T_k = Sum_a k_a T16[a], for every k (admissible and hidden components alike)
  PASS  ADMISSIBILITY (6) [THE RESULT]: traceless certificate -- every X commuting with beta, the four admissible E_k and one hidden-momentum E_k has Tr(G X) == 0, so no positive G J' exists; J itself is not in that commutant
  PASS  ADMISSIBILITY (6) [THE RESULT]: the analytic proof for a purely hidden momentum -- [E_k, beta] == 2 i k5 T16[5]; T16[5] anticommutes with G and T16[5]^dagger G T16[5] == -G (so a J' commuting with T16[5] has T5^dagger (G J') T5 == -(G J'))
  PASS  ADMISSIBILITY (7) [THE RESULT]: J is UNIQUE -- the joint commutant of beta and the admissible E_k is 8-dimensional, contains J, and every element of it commutes with J (so X^2 == 1 with J X > 0 forces X == J)
  PASS  ADMISSIBILITY [has content]: [P_4, P_h] == 0 -- the metric, the frame and the spin connection do not depend on x5, x6, x7
CELL 188  t=0.129 s
  PASS  HAMILTONIAN [THE RESULT]: the Hamiltonian density Pi_Psi d_4 Psi + d_4 Psibar Pi_Psibar - L of the symmetrized Lagrangian is Sqrt[g][-(1/(2H)) Sum_{k != 4}(Psibar gamma^k d_k Psi - d_k Psibar gamma^k Psi) + V]: NO spin connection (fields of all eight coordinates)
  PASS  HAMILTONIAN [THE RESULT]: (Sqrt[g]/H) sigma16 (gamma^mu D_mu Psi - H V' Psi) == i Gtilde d_4 Psi - h Psi for admissible Psi(x0..x4): the field equation is i Gtilde d_4 Psi = h Psi
  PASS  HAMILTONIAN [THE RESULT]: (1/2) Sum_{mu != 4} d_mu(Sqrt[g] sigma16 gamma^mu) == Sqrt[g] sigma16 Sum gamma^mu Gamma_mu, and d_4(Sqrt[g] sigma16 gamma^4) == 0: the connection term is the one that makes h Hermitian
  PASS  HAMILTONIAN [has content]: A_0 = Sqrt[g] sigma16 gamma^0 is real antisymmetric, and for h_0 = -(A_0 d_0 + (1/2) A_0'):  <f, h_0 g> - <h_0 f, g> == -d_0(f^dagger A_0 g), a pure boundary term
  PASS  BOUNDARY [has content]: the x0 direction in proper distance z = -Log[Cos[6 H x0]]/(6 H): dz/dx0 == Tan[6Hx0] == Sec Sin (so Sqrt[g] dx0 |Psi|^2 = |Psi'|^2 dz), z(0) == 0 and z -> infinity at 6 H x0 -> Pi/2, gamma^0 d_0 == T16[0] d_z, and Sin[6Hx0] == Sqrt[1 - Exp[-12 H z]] (bounded frame factors)
  PASS  BOUNDARY [THE RESULT]: the bag condition T16[0] Psi' = +-Psi' at the wall -- T16[0]^2 == 1, {beta, T16[0]} == 0, the normal-flux form vanishes on both eigenspaces (P beta T16[0] P == 0), and [J, T16[0]] == 0
  PASS  HAMILTONIAN [THE RESULT]: [J, h] == 0 on the admissible sector, for every a4, every x0-profile and every V' -- including the spin-connection term
  PASS  HAMILTONIAN [control]: a hidden derivative term breaks it -- [J, h] != 0 once Psi depends on x5 (witnessed on Psi = x5 e1)
  PASS  HAMILTONIAN [has content]: the x4-dependence of h enters only through 1/q: d_4 h Psi == (H a4'[H x4]) x (the observed-direction part of h), which commutes with J
CELL 189  t=0.221 s
  PASS  KREIN MODES [has content]: A = G h satisfies A^2 == w^2 ID16 and [A, J] == 0, and A is Hermitian (G and h commute) for every admissible k and m
  PASS  KREIN MODES [THE RESULT]: the four P_{s,eta} are projectors of trace (rank) 4, mutually orthogonal, summing to ID16, and Sum eta P_{s,eta} == J == G^-1 (completeness)
  PASS  KREIN MODES [THE RESULT]: for every mode, eta u^dagger h u == s w (energy = frequency), eta u^dagger sigma16 u == m/omega_u, eta u^dagger (dh/dk_j) u == k_j/omega_u: P X P == c P with c = eta s w, eta s m/w, eta s k_j/w
  PASS  KREIN MODES [has content]: dh/dk_j == -i sigma16 T16[j], and d omega/d k_j == k_j/omega for omega = +-w
  PASS  KREIN MODES [THE RESULT]: every mode of P_{s,eta} is a J-eigenvector: J P_{s,eta} == eta P_{s,eta}
  PASS  KREIN MODES [control]: a Krein-boosted pair u1 = (5/4)u+ + (3/4)u-, u2 = (3/4)u+ + (5/4)u- in the omega = +5 eigenspace is still G-orthonormal and still consists of modes, but not of J-eigenvectors; the induced J_U = G U U^dagger differs from J, and under it s is NOT Hermitian
CELL 190  t=1.680 s
  [0.749 s]  the CAR of 16 Jordan-Wigner operators
  PASS  FOCK [solver regression]: the Jordan-Wigner operators obey the positive CAR {f_i, f_j^dagger} == delta_ij, {f_i, f_j} == 0 on C^65536
  PASS  FOCK (field level) [THE RESULT]: {Psi_a, Psi^ddag_b} == J_ab == (G^-1)_ab with Psi = f, Psi^ddag = f^dagger J -- the Dirac-bracket anticommutator, realized on a positive Fock space
  PASS  FOCK (field level) [THE RESULT]: J h is Hermitian with eigenvalues +5 (8) and -5 (8); H_free and s are Hermitian operators, so is H_free + (3/7) s^2; p = Psi^ddag C+ Psi is ANTI-Hermitian
  [1.868 s]  the Heisenberg equation on the Fock space
  PASS  FOCK (field level) [THE RESULT]: Heisenberg -- [H_free, Psi_a] == -(G^-1 h Psi)_a for all 16 components, so i d_4 Psi = i [H, Psi] IS the field equation i G d_4 Psi = h Psi
  PASS  FOCK (field level) [control]: with the opposite sign of the anticommutator the Hamiltonian is -H_free and [H', Psi_a] == +(G^-1 h Psi)_a: the time-REVERSED equation
  PASS  FOCK (mode level) [THE RESULT]: {b_u, b_v^ddag} == eta_u delta_uv (the indefinite CAR demanded by Sum eta u u^dagger = G^-1), and the J-involution b^dagger = eta b^ddag restores {b, b^dagger} == 1
  PASS  FOCK (mode level) [has content]: the naive Krein 'norm' <0| b_u b_u^ddag |0> equals eta_u -- NEGATIVE for the four eta = -1 modes of each frequency -- while the Fock norm <0| b_u b_u^dagger |0> == 1
  PASS  FOCK (mode level) [THE RESULT]: Sum omega_u eta_u b_u^ddag b_u == Sum omega_u b_u^dagger b_u, and [Ham, b_u] == -omega_u b_u for every u (b_u(x4) = b_u e^(-i omega_u x4))
  PASS  FOCK (mode level) [THE RESULT]: the spectrum -- a UNIQUE ground state at -8 omega = -40, the Dirac sea (modes 9..16 filled, 1..8 empty); :Ham: = Ham + 40 >= 0
  PASS  FOCK (mode level) [THE RESULT]: the first excited level, omega = 5 above the sea, is 16-fold: 8 particle states (N = +1) and 8 antiparticle states (N = -1), with N = Sum b^dagger b - 8
  PASS  FOCK (mode level) [THE RESULT]: in every Fock basis state tested (the sea and the 16 first excited states) <n| b_u^ddag b_v |n> == eta_u n_u delta_uv -- the expectation rule of Section 29
  PASS  CHARGE [THE RESULT]: n^4 = -(i/H) Psibar gamma^4 Psi == (1/H) Psi^ddag G Psi == (1/H) Psi^dagger Psi, whose mode form Sum_u eta_u b_u^ddag b_u == Sum_u b_u^dagger b_u is the particle number (normal-ordered: particles - antiparticles)
CELL 191  t=9.858 s
  [0.693 s]  Hilbert tensor from first-order symmetric tetrad perturbations, five components
  PASS  EMT [THE RESULT]: the Hilbert (symmetric-tetrad) tensor of the symmetrized action IS That, OFF shell -- components (x1,x1), (x4,x4), (x1,x4), (x0,x5), (x5,x4)
  PASS  EMT [has content]: the spin-connection variation contributes NOTHING -- dropping it leaves the Hilbert tensor unchanged at (x1,x4), (x0,x5), (x5,x4)
  PASS  EMT [control]: the Hilbert tensor is NOT the partial-derivative tensor: at (x1,x4) they differ -- witnessed on constant spinors (Psibar = e1, Psi = e11: (T16[4] T16[1] T16[0])_{1,11} != 0)
  PASS  EMT [definition]: That is symmetric
  PASS  EMT [THE RESULT]: That is Hermitian under the classical conjugation: real for Psi = u + i v, Psibar = (u - i v)^T sigma16, all 64 components
CELL 192  t=2.248 s
  PASS  EMT CONSERVATION [definition]: F and Fbar solve the field equation and the adjoint equation for the x4-derivatives
  [0.767 s]  nabla^mu That_{mu nu}, generic Psi(x0, x4), Psibar(x0, x4)
  [2.599 s]  the on-shell divergence, eight components
  PASS  EMT CONSERVATION [THE RESULT]: nabla^mu That_{mu nu} == 0 ON SHELL in all eight components, for generic Psi(x0, x4), Psibar(x0, x4) and generic V
  PASS  EMT CONSERVATION [control]: OFF shell the divergence is not zero -- witnessed on Psi = (x4 + x0^2) e1 + e13, Psibar = e1 + x4 e5 with V = s^2, which is not a solution
  PASS  EMT [THE RESULT]: That - T_par == -(1/(4H)) Psibar ({gamma_mu, Gamma_nu} + {gamma_nu, Gamma_mu}) Psi: equal on the diagonal (every {gamma_mu, Gamma_mu} vanishes), different off it (the (x1, x4) witness above)
CELL 193  t=4.431 s
  PASS  EMT ON SHELL [THE RESULT]: the kinetic bilinear == s V'(s) (not zero) and Lhat == s V'(s) - V(s)
  PASS  EMT ON SHELL [THE RESULT]: rho = That_44 == V(s) + K_h
  PASS  EMT ON SHELL [THE RESULT]: T^i_i == T^h_h == s V'(s) - V(s) for the three observed and the three hidden directions, and T^0_0 == s V'(s) - V(s) + K_h
  PASS  EMT [has content]: the trace T^mu_mu == 7 Lkin - 8 V off shell, == 7 s V'(s) - 8 V(s) on shell
  PASS  EMT [fidelity]: K_h in the real commuting limit IS Part VI's cfKh, and K_h == 0 on the rescaled solutions Sqrt[Sin] Psi'(x4), Sqrt[Sin] Psi'bar(x4), where rho == V(s)
  [3.561 s]  the J-parity of all 64 components of That, admissible fields
  PASS  EMT HERMITICITY [THE RESULT]: J-parity table -- (mu, nu) in {0..4}: EVEN (Hermitian); (mu in 0..4, h in 5..7): ODD (anti-Hermitian); (h, h'), h != h': ZERO identically; (h, h): even
  PASS  EMT HERMITICITY [has content]: for x5..x7-independent fields That_{hh} == g_hh Lhat exactly, because {gamma_h, Gamma_h} == 0
CELL 194  t=4.080 s
  PASS  MODE SUMS [THE RESULT]: on a flat-frame plane wave (canonical normalization), T_44 + Lhat == omega ubar (-i T16[4]) u and T^j_j - Lhat == k_j ubar (-i T16[j]) u (j = 0..3): energy and pressure are the frequency and k_j dh/dk_j bilinears
  PASS  MODE SUMS [has content]: with ubar = u^ddag sigma16 these are omega u^ddag G u and k_j u^ddag (dh/dk_j) u, so by Section 28 each occupied mode contributes omega, k_j^2/omega and (to sigma) m/omega
  PASS  VACUUM [THE RESULT]: the unrenormalized sea energy -eps_KS(Lambda) == -(g/(16 pi^2))(2 Lambda^4 + 2 m^2 Lambda^2 + m^4/4 - m^4 Log[2 Lambda/m]) + o(1) as Lambda -> infinity; its m-dependent finite part contains -(g/(32 pi^2)) m^4 Log[m^2]
CELL 195  t=2.098 s
  PASS  KOHN-SHAM [definition]: the degeneracy g = 8 -- per momentum the positive-frequency eigenspace has rank 8 (Section 28's P_{+,+} + P_{+,-}), four flavours times two spins
  PASS  KOHN-SHAM [THE RESULT]: each closed form has k_F-derivative (g/(2 pi^2)) k_F^2 f(k_F) with f = 1, m/omega, omega, k^2/(3 omega), and vanishes at k_F = 0 -- so it IS the integral g Int d^3k/(2 pi)^3 f
  PASS  KOHN-SHAM [has content]: Integrate returns the same functions, with ArcTanh[k_F/w_F] in place of L -- and ArcTanh[k_F/w_F] == L (equal derivatives, both 0 at k_F = 0)
  PASS  KOHN-SHAM [control]: numerical quadrature agrees at k_F = 3/2, m = 1, g = 8 to 1e-12 (a cross-check; the proof is the symbolic one above)
  PASS  KOHN-SHAM [THE RESULT]: eps + P == w_F n (Gibbs), eps - 3 P == m sigma (trace), d eps/dm == sigma, d eps/dk_F == w_F dn/dk_F
  PASS  MEAN FIELD [THE RESULT]: rho = eps + W - sigma W', P_obs = P_KS + sigma W' - W give rho + P_obs == w_F n exactly; and d rho/dn == w_F + (sigma_KS - sigma) W'' sigma'(n), i.e. == w_F at the self-consistent point sigma = sigma_KS (m = W'(sigma) throughout)
  PASS  AUTHOR'S MASS TERM [THE RESULT]: W = m sigma gives W - sigma W' == 0, so rho == eps_KS, P == P_KS, and w = P_KS/eps_KS depends only on x = k_F/m: w == I2/(3 I1), I_n the m = 1 integrals
  PASS  AUTHOR'S MASS TERM [THE RESULT]: 0 <= w <= 1/3 -- P_KS >= 0 (I2' = x^4/w_x > 0, I2(0) = 0) and eps - 3P = m sigma = (g m^4/(2 pi^2)) I3 >= 0 (I3' = x^2/w_x > 0, I3(0) = 0)
  PASS  AUTHOR'S MASS TERM [THE RESULT]: w rises MONOTONICALLY -- dw/dx == x^2 Delta/(3 w_x I1^2) with Delta = x^2 I1 - w_x^2 I2, Delta(0) = 0 and Delta' = 2 x I3 > 0 -- from w -> 0 (x -> 0, w = x^2/5 + O(x^4): dust) to w -> 1/3 (x -> infinity: radiation)
  PASS  AUTHOR'S MASS TERM [has content]: the classical sign problem disappears -- sigma_KS = g Int m/omega is ODD in m and m sigma_KS = (g m^4/(2 pi^2)) I3(k_F/|m|) >= 0 for either sign, so with m = -2M: M sigma_KS <= 0, the branch M s < 0 that Part VI had to assume
  PASS  CLASSICAL LIMIT [THE RESULT]: at the self-consistent point rho == W + 3 P_KS and P_obs == (sigma W' - W) + P_KS exactly (sigma = sigma_KS, m = W'); Part VI's rho = V(s), P = s V' - V is the limit P_KS/eps_KS -> 0, i.e. k_F/m -> 0
CELL 196  t=4.945 s
  PASS  PRE-UNIVERSE (1) [THE RESULT]: the U(1) current is conserved on shell, (1/Sqrt[g]) d_mu(Sqrt[g] j^mu) == 0, for generic Psi(x0, x4), Psibar(x0, x4)
  PASS  PRE-UNIVERSE (1) [THE RESULT]: for Psi = Sqrt[Sin] Psi'(x4), Sqrt[g] j^0 is x0-independent (Sec Sin Cot == 1), so d_4(Sqrt[g] j^4) == 0 on shell; and Sqrt[g] and q^3 p^3 are x4-independent
  PASS  PRE-UNIVERSE (2) [THE RESULT]: Psi = Sqrt[Sin] Psi'(x4) satisfies the field equation iff d_x0 V'(Sin[6Hx0] s') == 0, and d_x0 V'(Sin s') == 6 H Cos[6 H x0] s' V''(Sin s'): V linear OR s' == 0
  PASS  PRE-UNIVERSE (2) [has content]: s' = Psi'bar Psi' is conserved by the x4-only equations (d_4 Psi' = -H V' T16[4] Psi', d_4 Psi'bar = H V' Psi'bar T16[4]) for ANY V; so null data s' = 0 are solutions for any V, with rho == V(0); and for V = s^2 with s' != 0 the x0-dependence is real (witness)
  PASS  PRE-UNIVERSE (3) [THE RESULT]: for Psi = Sqrt[Sin] u(x4) Exp[i k x1] the field equation (mass term, V' = constant) is Sqrt[Sin] Exp[i k x1] (T16[4] u' + i (k/q) T16[1] u - H V' u): the physical momentum is k/q
  PASS  PRE-UNIVERSE (3) [THE RESULT]: d Log[k/q]/dx4 == H a4'[H x4] == -H_obs (observed momenta redshift as Exp[a4]), and E^2 == (k^2/q^2 + m^2) ID16 at the physical momentum
  PASS  PRE-UNIVERSE (4) [THE RESULT]: x = k_F,phys/m = x_c/(q m) obeys d Log[x]/dx4 == H a4'[H x4]; since dw/dx > 0, dw/dx4 = w'(x) x H a4' < 0 exactly when a4' < 0 (the observed sheet expanding): the quantum gas COOLS
  PASS  PRE-UNIVERSE (4) [control]: the classical Part VI fable does NOT cool -- ds/dx4 == 0 on its rescaled solutions (Part VI's result, re-asserted), and its w = s V'/V - 1 is a function of s alone: frozen
  PASS  PART VII [control]: a4 is STILL UNDEFINED -- nothing in Part VII gave it a value
CELL 197  t=0.072 s
identities accepted on numerical evidence alone : 0   (stage 3 returned True)
non-vanishing witnesses                         : 38   (cfNonZeroWitnessQ found a probe point at which every entry is a
                                                     number and one of them is non-zero: a complete proof of non-vanishing)
  PASS  no identity in this notebook was accepted on numerical evidence alone
Assertions run: 528   passed: 528   failed: 0
CELL 198  t=0.000 s
```

### 10.3 The same assertions in the runs of Parts I–VIII

After Part VIII (the coupled system, notebook Sections 30–33) was added, the whole notebook was run
twice more. **Part VII's record is its own run** (10.1, 10.2); the two later runs show that adding
Part VIII changed nothing in it. With the `CELL` and `[t s]` timing lines removed, the lines printed
by cells 173–198 are identical in all three logs — the Part VII run, the acceptance run of Part VIII
and the final run — 174 lines each, 170 of them `PASS` lines [checked for this page with `diff`].

**The acceptance run of Part VIII** (`claude-fable/run_fermion_fable_part8.log`, committed in
`bc04ed1`; a historical record). The Part VII cells took 29.706 s in that run. Its summary:

```
==================== RUN SUMMARY ====================
cells evaluated : 217
total seconds   : 233.289
cells w/ msgs   : 0
---- slowest cells ----
  cell 80  80.343 s
  cell 88  23.494 s
  cell 204  10.364 s
  cell 86  9.821 s
  cell 137  9.306 s
  cell 191  9.225 s
  cell 87  8.387 s
  cell 121  6.069 s
  cell 160  4.250 s
  cell 196  4.185 s
  cell 107  3.836 s
  cell 193  3.140 s
==================== ASSERTIONS ====================
assertions run  : 642
passed          : 642
FAILED          : 0
====================================================
RUN-DONE
```

The last Part VII line of that log is still `Assertions run: 528   passed: 528   failed: 0` (line 843),
and the run ends with `Assertions run: 642   passed: 642   failed: 0` and 46 non-vanishing witnesses.
Two of Part VIII's assertions did not run in it: its comparisons of the Rust solver with the
Mathematica reference runs are made only if the solver's CSVs exist, and they did not exist yet (two
`NOTE` lines say `Rust CSV not found; that comparison was skipped, not failed`). And three of its
labels, in Section 32, write the listed spin-connection components with both flat indices up — the
notation that `3a5020d` corrected:

- `SPIN CONNECTION [THE RESULT]: the complete list of non-zero omega_mu^{ab} of the WARPED frame is the thirteen stated components (and their antisymmetric partners) -- nothing else`
- `SPIN CONNECTION [THE RESULT]: the complete list for the Bianchi-I frame is omega_0^{04} = C', omega_i^{i4} = A', omega_h^{4h} = B' -- nothing else`
- `SPIN CONNECTION [fidelity]: on the canonical member (labelled substitution) the warped connection IS omegaCanonical of Section 16, and the new component omega_0^{04} vanishes there`

The arrays these assertions compare (`cfOmegaWarp`, `cfOmegaBI`) carry both flat indices **down**, so
the tests themselves were right and are unchanged. Raising both flat indices multiplies a component by
`eta_aa eta_bb`, which is `−1` exactly in the planes with one timelike index and one spacelike index
(`(0,4)`, `(i,4)`, `(0,h)`) and `+1` in the `(0,i)` and `(4,h)` planes [derived here]. So, read with
the indices up as written, the second label states the wrong sign for `omega_0^{04}` and
`omega_i^{i4}`, while `omega_h^{4h} = B'` holds in either position; and the list of values in the old
Section 32 Text cell had the wrong sign for its `(0,4)`, `(i,4)` and `(0,h)` components. (The corrected
Text cell of `3a5020d` says that raising both indices "would flip the sign of every plane that
contains x4 or a hidden timelike direction"; exactly, it flips the planes with one timelike and one
spacelike index, and leaves the `(4,h)` planes, whose two indices are both timelike, unchanged.)

**The final run** (`claude-fable/run_fermion_fable_final.log`, first recorded in `1671155` and
re-recorded after the label correction in `3a5020d`; the notebook in its committed state). The
Part VII cells took 26.118 s and the Part VIII cells 20.994 s in that run. Its summary:

```
==================== RUN SUMMARY ====================
cells evaluated : 217
total seconds   : 198.352
cells w/ msgs   : 0
---- slowest cells ----
  cell 80  68.159 s
  cell 88  22.525 s
  cell 204  9.360 s
  cell 86  8.072 s
  cell 191  7.887 s
  cell 87  7.193 s
  cell 137  6.985 s
  cell 121  4.579 s
  cell 160  3.822 s
  cell 107  3.505 s
  cell 196  3.334 s
  cell 193  2.970 s
==================== ASSERTIONS ====================
assertions run  : 644
passed          : 644
FAILED          : 0
====================================================
```

The last Part VII line of that log is again `Assertions run: 528   passed: 528   failed: 0` (line
843), and the run ends with `Assertions run: 644   passed: 644   failed: 0` (line 1005),
`identities accepted on numerical evidence alone : 0` and 46 non-vanishing witnesses; no `RUN-DONE`
line was appended to this log. Its `PASS` lines differ from those of the acceptance run in exactly
five places [checked for this page with `diff`]. The two comparisons with the Rust solver now run and
pass, each after a line `Rust <path>: 71 rows compared; max difference per column ...`:

- `fable4d RUNS [fidelity]: the Rust solver's mass30eV run agrees with this cell to 1e-6 in every column, at every one of the rows its grid covers`
- `fable4d RUNS [fidelity]: the Rust solver's power run agrees with this cell to 1e-6 in every column, at every one of the rows its grid covers`

and the three Section 32 labels write the components with both flat indices down, `omega_{mu ab}`,
as the arrays they compare have them (the tests are unchanged):

- `SPIN CONNECTION [THE RESULT]: the complete list of non-zero omega_{mu ab} (both flat indices down) of the WARPED frame is the thirteen stated components (and their antisymmetric partners) -- nothing else`
- `SPIN CONNECTION [THE RESULT]: the complete list for the Bianchi-I frame is omega_{0 04} = C', omega_{i i4} = A', omega_{h 4h} = B' (both flat indices down) -- nothing else`
- `SPIN CONNECTION [fidelity]: on the canonical member (labelled substitution) the warped connection IS omegaCanonical of Section 16, and the new component omega_{0 04} vanishes there`

### 10.4 The design review, and every correction it made to Effort A

The design (revision 1) was reviewed by four adversarial reviewers — quantization (findings `QK-*`);
field equations, energy–momentum tensor and spin connection (`EMT-*`); Einstein equations and
cosmology (`E-*`); density-functional theory and numerics (`DFT-*`) — each followed by an
independent skeptic who tried to refute each finding. **No finding was refuted.** Several were
confirmed only in part, and then the corrected fix was adopted. The review records are working
documents and are not part of the repository; every adopted correction that concerns Effort A is
restated here, with where it now lives.

| design item | findings | what revision 1 said, or lacked | what was adopted | where on this page (notebook) |
|---|---|---|---|---|
| refinement | QK-7 | "fermion fable must be complex" without scope; F2(a) only on the flat frame | the invariant forms are exactly `span{sigma16, sigma16 T16[8]}`; Majorana has one quartic scalar and no commuting kinetic shadow; Weyl/Majorana–Weyl cannot propagate; the complex spinor is the **minimal**, not the unique, field; F2(a) holds on **every** frame | 3.2, 3.4, 3.8 (`REFINEMENT (a)`, `(b)`) |
| Lagrangian | QK-4 (corrected), EMT-5 | several Lagrangians used interchangeably; Part VI's drop-out mechanism assumed to carry over | only the symmetrized covariant Lagrangian; the unsymmetrized partial one is inadmissible (its two equations are not conjugate); the drop-out is a property of the matrix `{gamma^mu, Gamma_mu}`, per `mu`, on diagonal frames only | 4 (`LAGRANGIAN (a)–(f)`) |
| field equations | EMT-9, EMT-11 | 8+8 form sketched; operator ordering "normal-ordered or Weyl"; `x4`-only solutions assumed | the 8+8 form with the conjugate rows; the axial phase is not a symmetry; the ordering rule with its scalar and `gamma^4` contraction parts; the `x4`-only family needs `V'' s' = 0`, and `s'` is conserved | 5.3, 5.8, 5.9, 5.11 |
| quantization: truncation | QK-2 | "physical states obey `P_5 = P_6 = P_7 = 0`" (a superselection rule) and Tomonaga–Schwinger integrability | a **truncation** with finite `V_hid` (closed timelike curves stated); anticommutator with `H/(V_hid Sqrt[|g|])` and `delta^4`; only `[P_4, P_h] = 0` kept | 6.4, 6.10 |
| quantization: theorem | QK-1 (corrected) | admissibility asserted from one example | the theorem: positive quantization iff the momentum span is spacelike-definite, with items (1)–(7) (threshold Jordan block, `G`-neutral modes above threshold, traceless certificate, uniqueness) | 6.10 (`ADMISSIBILITY`) |
| quantization: `J` | QK-5 (corrected), plus the missed basis point | Krein prescription `b^dagger := eta b^ddag`, basis unspecified; reflection positivity claimed | `J = −i Omega4 T16[0]`, `sigma16 = J beta`, flavour metric `(2,2)`; the adjoint `Psi^dagger := Psi^ddag J` is mode-independent and **requires a `J`-eigenmode basis** (control: a Krein boost breaks Hermiticity of `s`); why it fails for bosons; reflection positivity **dropped** | 6.5, 6.6, 6.13 (`J`, `KREIN MODES [control]`) |
| quantization: other | QK-6, QK-8, QK-9, QK-10, QK-11, EMT-2 | symmetry count, dynamical frames, wall condition, current sign and `J`-connection relation incomplete or wrong | 13 kept / 15 lost generators, `G` invariant under Spin(4,3); `chi = (Sqrt[g]/H)^(1/2) Psi`; one-particle space `L^2(dz)`, regular at the wall, limit-point at infinity, bag condition `T16[0] Psi' = ±Psi'`; `n^mu = −(i/H) Psibar gamma^mu Psi`; the `J` table with `Gamma_5..7` anticommuting | 6.9, 6.12, 6.15, 6.16, 6.8 |
| EMT | EMT-1, EMT-3, EMT-4, EMT-8, QK-3 | EMT stated without derivation; conservation "for independent `Psi`, `Psibar`" without scope; "`<:T:> = 0` in the vacuum" | Hilbert = `T_cov` off shell; spin-connection variation exactly zero; Hilbert `!=` `T_par` (witness at a non-vacuous pair); why the commuting proxy proves conservation; the `J`-parity table; the vacuum statement only for static backgrounds; do not run the symbolic divergence of `T_par` | 7 (`EMT`, `EMT CONSERVATION`, `EMT HERMITICITY`), 8.3 |
| expectation values | DFT-5, DFT-6, DFT-12, DFT-15, DFT-4 | classical limit "`k_F -> 0` at fixed `n`" (impossible) or a coherent zero mode; unstable closed forms; phantom crossing not examined; sea energy only for constant `m` | the classical limit is the **non-relativistic** limit, with the sign rule; the numerically stable forms; `w_f >= −1` (no phantom crossing); the pair-excitation thresholds (`w_F + |m|` at `q = k_F`, `2 w_F` at `q = 0`; not asserted in Part VII); `DeltaE_vac` for mass-varying `W` | 8.5, 8.7, 8.9, 8.3 |
| spin connection | EMT-6, EMT-10 | "the connection enters the Hamiltonian" | it enters **neither** the anticommutator **nor** the Hamiltonian density; it re-emerges in the equation of motion as the term that makes `h` Hermitian; `gamma^mu Gamma_mu = −(1/2) T_mu gamma^mu` (the Weitzenböck torsion vector) | 6.11, 9.12.3, 9.12.4 |

Two of these adopted corrections are also stated in Part VII's own Text cells: the
Hamiltonian-density correction (EMT-6; "This corrects the design's 'it enters the Hamiltonian'",
Section 28), and the identification of the classical limit with the non-relativistic one (DFT-5;
Section 29). One numerical slip in the review's vacuum-energy figures is
corrected on this page (section 8.3).

### 10.5 The Fock check

The finite Fock space of section 6.14 is the independent check of the quantization: it realizes
the Dirac-bracket anticommutator on a positive Hilbert space of dimension `2^16 = 65536`, with exact
integer sparse matrices, and confirms the sign of the anticommutator through the Heisenberg
equation (the opposite sign gives the time-reversed equation). It shows the unique Dirac-sea ground
state at `−40`, the 16-fold first excited level (8 particles, 8 antiparticles), the negative Krein
"norms" that the `J`-involution removes, and the expectation rule used for `rho`, `P` and `sigma`.
Twelve assertions (`FOCK`, `CHARGE`), Input cell 191, 9.858 s.

### 10.6 The TeX export

`claude-fable/export_fermion_fable_tex.wls` evaluates the notebook's Input cells (output
suppressed), checks that the Part VII objects exist, and writes fourteen files into
`provenance-latex/generated/`:

| file (`.tex` and `.txt`) | content | taken from the notebook object |
|---|---|---|
| `fermion_fable_field_equations` | the 16 component field equations on the canonical frame | `cfFieldEqTerms` |
| `fermion_fable_adjoint_equations` | the 16 component adjoint equations | `cfAdjEqTerms` |
| `fermion_fable_field_equations_8plus8` | the split-octonion 8+8 form, compact and by component | `cfFieldOp16`, `cfUpper8`, `cfLower8`, `cfFieldEqTerms` |
| `fermion_fable_field_equations_rescaled` | the 16 equations for `Psi' = Psi/Sqrt[Sin[6 H x0]]` | the rescaled operator of Section 27 (iv), asserted equal to `cfE8` under the rescaling |
| `fermion_fable_anticommutator` | `{Psi_a, Psi^ddag_b} = H Cos[6 H x0] J_ab delta^7`, with the matrix | `cfAntiPsiPsiDd` at `c = Sqrt[g]/H` |
| `fermion_fable_krein_J` | `J`, `beta`, `sigma16 = J beta` | `cfJK`, `cfBeta` |
| `fermion_fable_eos` | the Kohn–Sham closed forms `n`, `sigma`, `eps`, `P`, `w` at `g = 8` | `cfNKS`, `cfSigKS`, `cfEpsKS`, `cfPKS` |

Every expression comes from an object that Part VII asserts; the script does no mathematics of its
own beyond formatting (its header says so, and its code only renders term lists and matrices). The
`.txt` files are quoted verbatim in sections 5, 6 and 8 of this page; the `.tex` files are
`\input` by the LaTeX twin. The export was run on 2026-09-24 at 20:41 (PDT) on the 198-cell notebook,
and it printed:

```
evaluating 198 Input cells of C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\claude-fable\claude-fable_Einstein-Rosen-2-Planes.nb (output suppressed)
assertions: 528   failed: 0   cells with messages: 0
  wrote C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\provenance-latex\generated\fermion_fable_field_equations.tex / .txt
  wrote C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\provenance-latex\generated\fermion_fable_adjoint_equations.tex / .txt
  wrote C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\provenance-latex\generated\fermion_fable_field_equations_8plus8.tex / .txt
  wrote C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\provenance-latex\generated\fermion_fable_field_equations_rescaled.tex / .txt
  wrote C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\provenance-latex\generated\fermion_fable_anticommutator.tex / .txt
  wrote C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\provenance-latex\generated\fermion_fable_krein_J.tex / .txt
  wrote C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\provenance-latex\generated\fermion_fable_eos.tex / .txt
done: 14 files in C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\provenance-latex\generated
```

(That console output was captured outside the repository; the fourteen files it wrote were
committed in `4fdfc40`.) A test document that `\input`s all seven `.tex` fragments (with `amsmath`)
compiled with pdfLaTeX (MiKTeX) to 9 pages with no errors, warnings or overfull boxes (a scratch
test on 2026-09-24, outside the repository).

## 11. Every command, in full

The commands run in Git Bash on Windows 11 (they are plain POSIX shell and run the same way on Linux
and macOS). The toolchain recorded in the logs: Wolfram Language 15.0.1 for Microsoft Windows
(64-bit) (July 2, 2026), called as `wolframscript` (the fourth line of each of the three run logs); Python 3 for the
builder (Python 3.14.5 when section 11.1's output was recorded); and MiKTeX (pdfTeX
3.141592653-2.6-1.40.29, MiKTeX 26.5; Latexmk 4.88) for the LaTeX twin, installed on this machine
at `C:/Program Files/MiKTeX/miktex/bin/x64`.

### 11.1 Build the notebook from its manifests

The notebook is never edited by hand. `build_tools.py` reads every `claude-fable/cells_part*.wl` in
order and writes both the notebook and `run_all.wls` (the same Input cells as a script).

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
python build_tools.py          # use python3 where python is absent
```

It prints (recorded on 2026-09-24 for this page, with the eight committed manifests, in a scratch
copy of the directory so that nothing in the repository was touched; it ran in 0.115 s):

```
manifest files : ['cells_part1.wl', 'cells_part2.wl', 'cells_part3.wl', 'cells_part4.wl', 'cells_part5.wl', 'cells_part6.wl', 'cells_part7.wl', 'cells_part8.wl']
cells parsed   : 384 {'Title': 8, 'Subtitle': 1, 'Subsubtitle': 1, 'Text': 123, 'Section': 34, 'Input': 217}
run_all.wls    : 217 Input cells
notebook       : 384 cells -> <repo>\claude-fable\claude-fable_Einstein-Rosen-2-Planes.nb
```

(the last line prints the absolute path of the directory it ran in). The rebuilt
`claude-fable_Einstein-Rosen-2-Planes.nb` and `run_all.wls` were **byte-identical** to the committed
ones (`cmp` reported no difference). The check was repeated on 2026-09-25 on the manifests of
`3a5020d`, whose `cells_part8.wl` carries the corrected Section 32 labels: the same four lines, and the
rebuilt notebook and `run_all.wls` again byte-identical to the committed ones. With only the seven manifests of Parts I–VII present — the
state in which Part VII was run — it prints
`cells parsed   : 340 {'Title': 7, 'Subtitle': 1, 'Subsubtitle': 1, 'Text': 103, 'Section': 30, 'Input': 198}`
and `run_all.wls    : 198 Input cells`, which is the style tally that the checker reported for the
Part VII notebook (section 11.3).

### 11.2 Run the notebook end to end, straight out of the `.nb`

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
wolframscript -file run_from_nb.wls > run_fermion_fable_final.log 2>&1
git checkout -- claude-fable_Einstein-Rosen-2-Planes-eLa.mx claude-fable_Einstein-Rosen-2-Planes-eLazt.mx
```

- **What it does.** `run_from_nb.wls` imports the `.nb`, takes its Input cells in order, and
  evaluates each one as a single unit (a multi-line cell becomes one `CompoundExpression`, exactly as
  the front end evaluates it), through the harness `runner_header.wl`. The harness prints
  `CELL n  t=... s` after each cell, with `MESSAGES: ...` appended if the cell raised any message, and
  ends with the run summary and the assertion counts.
- **Why from inside `claude-fable/`.** Run headless, the notebook cannot ask for its own file name, so
  Section 10 looks for the author's helper packages `ConvertMapleToMathematicaV2.wl` and `EtoExp.wl`
  in the working directory (and in `Pre-Universe_14SEP26-77/` below it, and one level up). They sit
  in `claude-fable/`. The reference CSVs of Parts VI and VIII are found as
  `claude-fable\..\fable-cosmology\reference\...` (the log prints these paths). The script itself is
  self-locating (`$InputFileName`) and finds the notebook from any directory.
- **The `.mx` restore.** Section 12 of the notebook writes `claude-fable_Einstein-Rosen-2-Planes-eLa.mx`
  and `...-eLazt.mx` with `DumpSave`, whose bytes are not reproducible from run to run. The two files
  are restored to the committed version after every run (commits `4fdfc40` and `bc04ed1` record that
  this was done).
- **How long.** 198.352 s for the 217 cells of the final run; 232.146 s for the 198 cells of the
  Part VII run and 233.289 s for the 217 cells of the acceptance run of Part VIII (the
  `total seconds` lines of the three logs).
- **What it prints.** The first line is `evaluating 217 Input cells straight out of the .nb`
  (`evaluating 198 ...` for the Part VII state). Then the provenance banner of the original notebook
  and every cell's line, `PASS` labels and notes. The Part VII portion is quoted in full in section
  10.2. The end of the run is quoted in sections 10.1 and 10.3.

The final log was produced by this command on the committed notebook of `3a5020d`. The Part VII log
was produced by the same command with the output redirected to `run_fermion_fable_part7.log`, when the
notebook had Parts I–VII, and the acceptance log of Part VIII with the output redirected to
`run_fermion_fable_part8.log`, before the Rust solver's CSVs existed. The last line of those two,
`RUN-DONE`, was appended by the wrapper that ran the command; the final log has no such line.

**Checking a log** (the numbers are the results on the three committed logs):

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
grep -c '^  PASS' run_fermion_fable_part7.log         # 528
grep -c '^  PASS' run_fermion_fable_part8.log         # 642
grep -c '^  PASS' run_fermion_fable_final.log         # 644
grep -n '^  FAIL' run_fermion_fable_final.log         # no output: no assertion failed
grep -c 'MESSAGES: ' run_fermion_fable_final.log      # 0: no cell raised a message
grep -E 'identities accepted|non-vanishing witnesses' run_fermion_fable_final.log | tail -2
#   identities accepted on numerical evidence alone : 0   (stage 3 returned True)
#   non-vanishing witnesses                         : 46   (cfNonZeroWitnessQ found a probe point at which every entry is a
sed -n '/RUN SUMMARY/,$p' run_fermion_fable_final.log  # the summary quoted in section 10.3
diff <(grep '^  PASS' run_fermion_fable_part8.log) <(grep '^  PASS' run_fermion_fable_final.log)
#   five differences: the three Section 32 labels, and the two Rust comparisons added (section 10.3)
```

A plain `grep FAIL` also finds the summary line `FAILED          : 0` and the two `PASS` labels whose
text contains the word "FAILS" (control assertions that show a wrong sign failing, lines 298 and
921 of the final log, and of the Part VIII log). The run prints four `EXPECTED MESSAGE(S)` lines (three
in Part II, one in Part V: messages that the original notebook's time budgets or its underdetermined
`Solve` calls may raise, announced in advance) and one `NOTE` line in Part III (that `a4` is
undefined); in Part VIII it prints the two lines `Rust <path>: 71 rows compared; ...` of the
comparisons with the Rust solver's CSVs `fable-cosmology/results/nb06_fable4d_mass30eV.csv` and
`nb06_fable4d_power.csv` (committed in `aca5102`). In the acceptance run of Part VIII those CSVs were
not yet present, and two `NOTE` lines said so instead (`Rust CSV not found; that comparison was
skipped, not failed`). None of these lines is a message raised by a cell.

### 11.3 Check the generated notebook without evaluating it

```bash
wolframscript -file "$(git rev-parse --show-toplevel)/claude-fable/verify_nb.wls"
```

It imports the `.nb`, counts its cells by style, extracts the Input cells, and checks that every
one of them parses. It takes about 4 s (4.118 s when timed for the draft of this page). For the
committed notebook it prints (`claude-fable/verify_nb_part8.log`, re-recorded in `3a5020d` after the
Section 32 labels were corrected; before that correction it printed `file bytes: 545408` and
`total input characters: 347187`, the rest unchanged):

```
file bytes: 545713
Head: Notebook
cells: 384
style tally: {{Title, 8}, {Subtitle, 1}, {Subsubtitle, 1}, {Text, 123}, {Section, 34}, {Input, 217}}
input cells with plain-string BoxData: 217
total input characters: 347237
input cells that FAIL to parse: {}
first cell: InputForm[(* --- provenance banner, as in the original notebook ------------------------------------]
last cell : InputForm[cfAssert["PART VIII [control]: a4 is STILL UNDEFINED -- nothing in Part VIII gave it a val]
```

For the Part VII notebook it printed (`claude-fable/verify_nb_part7.log`):

```
file bytes: 440320
Head: Notebook
cells: 340
style tally: {{Title, 7}, {Subtitle, 1}, {Subsubtitle, 1}, {Text, 103}, {Section, 30}, {Input, 198}}
input cells with plain-string BoxData: 198
total input characters: 279955
input cells that FAIL to parse: {}
first cell: InputForm[(* --- provenance banner, as in the original notebook ------------------------------------]
last cell : InputForm[(* --- final tally of every assertion made in this notebook, Parts I-VII -----------------]
```

### 11.4 Print the section-to-cell map

```bash
wolframscript -file "$(git rev-parse --show-toplevel)/claude-fable/nb_section_map.wls" > "$(git rev-parse --show-toplevel)/claude-fable/nb_section_map.log"
```

It reads the `.nb` without evaluating anything and prints, in document order, each Part title and
each Section with the range of its Input cells (3.340 s when timed for this page). Its output,
`claude-fable/nb_section_map.log`:

```
== claude-fable_Einstein-Rosen-2-Planes
0.  What this notebook does, and how it is organized  |  Input cells none
1.  Session setup  |  Input cells 1-6
2.  Coordinates and the flat 4+4 Minkowski metric eta  |  Input cells 7-12
3.  SO(4): self-dual and anti-self-dual antisymmetric 4x4 matrices  |  Input cells 13-15
4.  The real 8x8 Clifford generators tau, their conjugates, and the spinor metric sigma  |  Input cells 16-21
5.  The 16x16 Dirac matrices T16, the chirality operator, sigma16 and the so(4,4) generators  |  Input cells 22-29
6.  A complete basis of the 16x16 matrix algebra  |  Input cells 30-35
7.  A complete basis of the 8x8 matrix algebra, and the induced flat metric  |  Input cells 36-38
8.  The 4x4 Dirac matrices, and a complete basis of the 4x4 matrix algebra  |  Input cells 39-44
9.  Cartan triality: the constant bridge between the vector and spinor realizations,
    and the split-octonion structure constants  |  Input cells 45-52
== PART II  --  The wave function of the un-universe, its field equations, and the 3 generations
10.  Housekeeping: where this notebook lives, and the two helper packages  |  Input cells 53-55
11.  The wave function of the un-universe, and its Lagrangian  |  Input cells 56-60
12.  The Euler-Lagrange equations, the coupling pattern, and the (z,t) chart  |  Input cells 61-66
13.  Decoupling into four blocks of four, and the closed-form solutions  |  Input cells 67-78
14.  Bilinears, the two solution branches, and M6 = 3 generations of Einstein-Rosen 2-planes  |  Input cells 79-90
== PART III  --  The curved 4+4 spacetime, its frame field, and the canonical spin connection
15.  The local flat 4+4 Minkowski coordinate system at every spacetime point  |  Input cells 91-99
16.  The generalized Christoffel symbols, and the canonical spin connection  |  Input cells 100-110
17.  The gauge-covariant derivative of the 16-component spinor  |  Input cells 111-117
== PART IV  --  Three bridges between curved and flat indices: two gauge transformations, and one new connection
18.  Bridge 1 -- a locally boosted frame: the same connection in a local gauge  |  Input cells 118-125
19.  Bridge 2 -- the null (light-cone) frame: the same connection in a constant gauge, and the spinor metric sigma  |  Input cells 126-130
20.  Bridge 3 -- the triality frame with totally antisymmetric split-octonion torsion  |  Input cells 131-139
== PART V  --  The fable-5.1 bridge: the connection in which the frame itself is parallel
21.  The fable-5.1 bridge -- the Weitzenboeck (teleparallel) connection of the canonical frame  |  Input cells 140-148
22.  Master comparison of the five spin connections  |  Input cells 149-152
== PART VI  --  fableScalar and fable: two fields on the pre-universe, and the equation of state of dark energy
23.  fableScalar -- a scalar field on the pre-universe, its energy-momentum tensor, and wScalar  |  Input cells 153-160
24.  fable -- the 16-component spinor field, its energy-momentum tensor, and w  |  Input cells 161-169
25.  Reading the two mechanisms side by side  |  Input cells 170-172
== PART VII  --  fermion fable: the complex 16-spinor, its canonical quantization in 4+4 dimensions, its field equations in the primordial gravitational field, and its energy-momentum tensor operator
26.  The refinement: why fermion fable is a complex 16-spinor  |  Input cells 173-179
27.  The Lagrangian, the field equations in the primordial gravitational field, and the canonical spin connection  |  Input cells 180-184
28.  Canonical quantization in 4+4 dimensions: the Dirac bracket, the Krein structure J, and the admissible sector  |  Input cells 185-191
29.  The energy-momentum tensor operator of fermion fable: definition, conservation, and rho, P and w  |  Input cells 192-198
== PART VIII  --  fable as a source of the Einstein equations of the primordial gravitational field
30.  The Einstein tensor of the canonical metric, and what it demands of its source  |  Input cells 199-203
31.  The generalized warped frame, its asymptotic region, and the 8-dimensional Bianchi-I limit  |  Input cells 204-207
32.  The canonical spin connection of the interacting system  |  Input cells 208-210
33.  The coupled equations of fable and the primordial field, and their solution from the radiation era to today  |  Input cells 211-217
total Input cells: 217
```

### 11.5 Export the field equations, the anticommutator, `J` and the equations of state to TeX and text

```bash
wolframscript -file "$(git rev-parse --show-toplevel)/claude-fable/export_fermion_fable_tex.wls"
```

It is self-locating and sets its own working directory to `claude-fable/`, so it runs from anywhere.
It evaluates every Input cell of the notebook with the output suppressed (so it takes about as long
as a run; its duration was not recorded), prints the assertion count, stops with exit code 1 if the
Part VII objects are missing, and writes the fourteen files listed in section 10.6. Its recorded
output is quoted there. On today's 217-cell notebook the first two lines would read
`evaluating 217 Input cells ...` and `assertions: 644 ...` (644 because the Rust solver's CSVs are
committed, so Part VIII's two comparisons run, as in the final run of section 10.3); the Part VII
objects it exports are the same. The `.tex` files carry the date of the run in their header comment, so a re-run on another
day changes that one line; the `.txt` files carry no date. Like every evaluation of the notebook, it
rewrites the two `.mx` files of Section 12, which are then restored as in 11.2.

### 11.6 Build the LaTeX twin and its PDF

```bash
bash "$(git rev-parse --show-toplevel)/provenance-latex/build_all.sh"
```

or, in PowerShell,

```powershell
powershell -ExecutionPolicy Bypass -File provenance-latex\build_all.ps1
```

For each of the three documents
(`PROVENANCE-14-FERMION-FABLE-CANONICAL-QUANTIZATION`, `...-15-...`, `...-16-...`) the script runs
`latexmk -pdf -interaction=nonstopmode -halt-on-error <doc>.tex`, with the output in
`provenance-latex/<doc>.latexmk.log`; it stops on the first failure, printing
`FAILED; see provenance-latex/<doc>.latexmk.log and <doc>.log`; it warns if the `.log` contains
"undefined" or "Rerun to get"; and it lists each PDF. So it prints `== <doc>` and an `ls -la` line
per document, and finally `== all three PDFs built`. Every document begins with `\input{preamble}`
(`provenance-latex/preamble.tex`: pdfLaTeX, Latin Modern, A4, 2.5 cm margins, and macros for the
notebook's objects, with separate symbols for the classical conjugation `\cconj` and the Hilbert
adjoint `\hadj`). MiKTeX's `latexmk` needs Perl on the `PATH`; Git for Windows ships one
(`$env:PATH += ";C:\Program Files\Git\usr\bin"` in PowerShell, as `build_all.ps1` notes).

The preamble was test-compiled when it was added: commit `0a789e2` records that a minimal test
document compiles with `latexmk` with no warnings. The LaTeX twin of this page, in its final state, was
compiled on its own on 2026-09-25, inside `provenance-latex/`, with the command of its header,
`latexmk -pdf -interaction=nonstopmode -halt-on-error PROVENANCE-14-FERMION-FABLE-CANONICAL-QUANTIZATION.tex`:
it ran with no errors, no warnings and no undefined references, and wrote a PDF of 114 pages
whose only two overfull lines are 5.5 pt and 0.6 pt too wide. The run of `build_all.sh` over the three pages belongs to the fresh-clone
verification of section 12.

## 12. Push and repository verification

**The repository.** `origin` is `https://github.com/once-ere/Pre-Universe_with_Claude.git`, and the
work is pushed to its `main` branch. (The remote named `upstream`, the author's other repository,
is never pushed to.) The repository carries a `.gitattributes` with `* -text`, so that git never
rewrites line endings and every file checks out with the bytes that were committed.

**The commits of the work, 2026-09-24 and 2026-09-25** (`git log --oneline -18`, times from
`git log --date=iso`, PDT; the work ran past midnight, so the last four commits are dated 2026-09-25):

| commit | time | what it contains |
|---|---|---|
| `e34d454` | 18:52:36 | the 2026-09-16 work, as it stood: Part VI of the notebook (Sections 23–25; 172 Input cells, 358/358), the `fable-cosmology/` solver, notebooks, results and references; with its known gaps listed in the commit message |
| `028b379` | 19:24:32 | the reference generator `make_reference.wls` no longer prints harmless underflow messages (the values it writes are unchanged) |
| `2f6d322` | 19:57:29 | the 2026-09-16 gaps closed: the student instructions and the paper of the fable-cosmology work, its provenance page completed, seven corrections to its design; a fresh local clone ran its `setup.sh` and `run_all.sh` end to end |
| `8459c57` | 20:02:04 | a work-in-progress snapshot of the fermion-fable solver crate `fable-cosmology/rust/fable_fermion` |
| `e130337` | 20:14:25 | a second work-in-progress snapshot of that crate |
| `0a789e2` | 20:17:18 | the LaTeX build tree of the three new provenance pages: `provenance-latex/preamble.tex`, `build_all.sh`, `build_all.ps1` |
| `d0f2a99` | 20:18:53 | `build_all.sh` tracked without the executable bit, like the repository's other scripts |
| `c5892bd` | 20:38:49 | the finished fermion-fable solver: the Kohn–Sham fermion gas (stable integrals, per-7-volume mean field, gap equation), the stabilized and 8D models, `cargo test` 21 + 8 passing, and the independent scipy cross-check |
| **`4fdfc40`** | **20:47:28** | **Part VII (this effort):** `claude-fable/cells_part7.wl`, the rebuilt notebook (198 Input cells, 528/528, 0 cells with messages), `run_fermion_fable_part7.log`, `verify_nb_part7.log`, `export_fermion_fable_tex.wls` and the fourteen generated TeX/text files |
| `b7ea18d` | 20:48:42 | a wording correction, in an earlier provenance page, about the canonical connection's planes: for `k = 5, 6, 7` the `(0,k)` plane is a **boost** and the `(4,k)` plane a **rotation** (the fact is stated in section 9.6 of this page) |
| `bc04ed1` | 21:24:04 | Part VIII (the coupled system, Sections 30–33; 217 Input cells, 642/642, with its two comparisons of the Rust solver skipped because the solver's CSVs did not exist yet), its acceptance run log `run_fermion_fable_part8.log`, and the Mathematica fermion references |
| `18a2501` | 22:13:42 | the wall-state solver of the coupled system (`fable-cosmology/fermion/waveguide*`): its derivation from the notebook's own `T16` (94/94 checks pass), its Python solver (validation 64/64), its independent Mathematica cross-check, and its report |
| `fee5603` | 22:31:20 | the draft of this page, its LaTeX twin and its PDF (110 pages), with section 1 still a placeholder |
| `2bc936d` | 23:12:51 | six defects of the solver `fable_fermion` fixed, among them the stable evaluation of the Dirac-sea energy `vac_over_rhoc` (section 8.3); `cargo test` 34/34 (23 unit + 11 integration, previously 21 + 8) |
| `aca5102` | 2026-09-25 00:23:46 | notebooks 05–07 of the fermion fable executed and committed with their results (all seven notebooks pass the checker, `nbcheck` 7/7; `fable-cosmology/run_all.sh` passes end to end); the wall-state solver's input `fable-cosmology/fermion/waveguide_T16.json` committed (its derivation log still reports `94 checks, 94 PASS, 0 FAIL`); `waveguide.py validate` exits 1 whenever a check fails |
| `1671155` | 00:28:54 | the final full run of the notebook recorded, `claude-fable/run_fermion_fable_final.log` (217 Input cells, 644/644, 0 cells with messages, 208.715 s, 46 witnesses): with the solver's CSVs now committed, Part VIII's two comparisons of the Rust solver with the Mathematica reference runs run and pass (642 + 2 = 644) |
| `38701ef` | 05:40:19 | the drafts of the pages of Efforts B and C (markdown, LaTeX, PDF), the notebook figures their PDFs use (`provenance-latex/figures/`), and the repository's front page updated for Parts VII–VIII and the three pages |
| `3a5020d` | 05:54:25 | Part VIII, Section 32: its Text cell and three assertion labels now write the listed spin-connection components with **both flat indices down** — `omega_{mu ab}`, `omega_{0 04}`, `omega_{i i4}`, `omega_{h 4h}` — as the arrays they compare have them (raising both indices flips the sign of every component in a plane with one timelike and one spacelike index; section 10.3); no computation changed. The final run re-recorded in `run_fermion_fable_final.log` (217 Input cells, 644/644, 0 cells with messages, 198.352 s, 46 witnesses, 0 identities accepted on numerical evidence alone, both Rust-vs-Mathematica comparisons passing); `verify_nb_part8.log` re-recorded (section 11.3); a comment in the solver's `models.rs` |

**Checking that the remote has what was pushed:**

```bash
cd "$(git rev-parse --show-toplevel)"
git fetch origin
git rev-parse HEAD origin/main              # both must print the same hash
git ls-remote origin refs/heads/main        # the hash GitHub serves for main
git status --short                          # what is not yet committed
```

When the draft of this page was written (2026-09-24, about 21:28 PDT), `git ls-remote origin
refs/heads/main` printed

```
bc04ed16096e134857111ae16df5220d4ff18435	refs/heads/main
```

which was the local `main` (`bc04ed1`, "Add Part VIII: fable as a source of the Einstein equations of
the primordial field"). Everything of this effort that exists as code, log or generated file —
`cells_part7.wl`, the rebuilt notebook, the Part VII run log, the checker's logs, the export script
and the generated TeX/text files — was in that pushed commit.

**What was not yet committed when the draft was written, and where it went.** The draft of this
page, its LaTeX twin and its PDF were committed in `fee5603`. The working-tree changes of the other
efforts that were pending at that moment are all committed since: the changes to the solver's
`constants.rs` and to `fable-cosmology/fermion/crosscheck.py` in `2bc936d`, and the new notebook
`05_fermion_fable_quantum_eos.ipynb`, the edits to the other notebooks and their results in `aca5102`.
None of the numbers on this page is taken from a file that is not committed. The two `.mx` files of
Section 12 were also showing as modified in the working tree then, rewritten by a notebook evaluation
running at the time; they are restored as in section 11.2 before any commit. This final version of
the page, its LaTeX twin and its PDF are committed together with the final versions of the pages of
Efforts B and C.

**The final push and the fresh-clone verification.** The final state is verified from a fresh clone
of the pushed `main`, with these commands (`<scratch>` is any empty directory outside the
repository):

```bash
cd <scratch>
git clone https://github.com/once-ere/Pre-Universe_with_Claude.git fresh
cd fresh
git log --oneline -1                                   # the hash of the pushed main
cd claude-fable
cp claude-fable_Einstein-Rosen-2-Planes.nb committed.nb
python build_tools.py                                  # prints the four lines of section 11.1
cmp claude-fable_Einstein-Rosen-2-Planes.nb committed.nb && echo "notebook rebuilds byte for byte"
wolframscript -file verify_nb.wls                      # section 11.3
wolframscript -file run_from_nb.wls > fresh_run.log 2>&1
sed -n '/RUN SUMMARY/,$p' fresh_run.log                # 217 cells, 644/644, cells w/ msgs 0
diff <(grep '^  PASS' fresh_run.log) <(grep '^  PASS' run_fermion_fable_final.log) && echo "every label identical"
cd .. && bash provenance-latex/build_all.sh            # section 11.6
```

The Rust solver's two CSVs that Part VIII compares with its Mathematica reference runs,
`fable-cosmology/results/nb06_fable4d_mass30eV.csv` and `nb06_fable4d_power.csv`, are committed (since
`aca5102`), so a fresh clone runs both comparisons and its summary is compared with the final run,
644/644. Before the final one, the most recent completed fresh-clone verification in the
repository's history is the one recorded in `2f6d322` (for the fable-cosmology work). The delivered
copy of the notebook outside the repository,
`C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb`, is byte-identical to the
committed notebook of `3a5020d` (545713 bytes, the `file bytes` of section 11.3; compared with `cmp`
when this page was brought to its final state on 2026-09-25).

The final commit hashes, the `git ls-remote` line of the final push, and the results of the
fresh-clone verification of that pushed state (the rebuild, the run summary, the comparison of every
label, the LaTeX build) are recorded here: {{FINAL-PUSH}}
