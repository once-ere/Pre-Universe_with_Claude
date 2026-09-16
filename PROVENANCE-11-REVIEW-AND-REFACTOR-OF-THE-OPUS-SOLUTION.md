# Provenance 11 — Checking, verifying, refining and refactoring the Opus-5 solution

**Effort.** The author's instruction, 2026-09-16, verbatim in its operative part: *"opus-5 had
great difficulty with its solution (i.e., this solution), which has critical issues/errors (e.g.,
its 'boost' solution [New bridge 1, a locally boosted frame, compared to the canonical spin
connection], which is trivial and must be replaced with a novel, highly non-trivial and even
super-human [if possible] solution). YOU MUST check, verify, refine and refactor opus's solution,
in its entirety; no exceptions."* The replacement bridge itself — the fable-5.1 bridge — is Part V
of the notebook (Sections 21–22, manifest `claude-fable/cells_part5.wl`); this page records
the review of everything that was already there, what was found, and what was changed.

Everything needed to repeat this work is on this page. No other file needs to be consulted.

The hard rules the author set for this work, and how each was honoured, are in section 9.

---

## 0. Where things are

| what | where |
|---|---|
| the notebook | `<repo>/claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb` (generated; never hand-edited) |
| its manifests | `<repo>/claude-fable/cells_part1.wl` … `cells_part5.wl` (Part V is new) |
| the generator | `<repo>/claude-fable/build_tools.py` (unchanged; it globs `cells_part*.wl`) |
| the headless runner | `<repo>/claude-fable/run_from_nb.wls` (unchanged) |
| the run log of this revision | `<repo>/claude-fable/run_fable51_fourth.log` |
| the logs of the two runs that exposed the defects of sections 6 and 6b | `<repo>/claude-fable/run_fable51_second.log`, `run_fable51_third.log` |
| the parse check and the front-end render probe of this revision | `<repo>/claude-fable/verify_nb_fable51.log`, section 7a |
| the section-to-cell map, printed from the notebook | `<repo>/claude-fable/nb_section_map.log` (script `nb_section_map.wls`) |
| the backups taken before any file was touched | `<repo>/backups/fable51-20260916/` (ignored by git, kept on disk) |

`<repo>` is wherever the repository is cloned; every shell block below finds it with
`git rev-parse --show-toplevel`.

## 1. Backups first

Hard rule 1. Before any manifest, page or notebook was modified, every file that would be
modified was copied:

```bash
cd "$(git rev-parse --show-toplevel)"
mkdir -p backups/fable51-20260916
cp -p claude-fable/cells_part1.wl claude-fable/cells_part2.wl claude-fable/cells_part3.wl \
      claude-fable/cells_part4.wl claude-fable/build_tools.py claude-fable/runner_header.wl \
      claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb README.md PROVENANCE-*.md \
      backups/fable51-20260916/
ls backups/fable51-20260916/ | wc -l        # 19
```

`backups/` is in `.gitignore`, so these copies stay on the author's disk and out of the
repository.

## 2. How the review was done

The whole of the Opus-5 solution — Parts I–IV of the notebook, all four manifests, and the ten
provenance pages — was audited along five lines: (i) is the canonical construction of Part III
correct (frame, vielbein postulate, spin connection, Dirac coupling, index placement, signs);
(ii) is each of the three Part IV bridges a genuinely different connection or a gauge transform
of the canonical one; (iii) is Bridge 3's octonionic torsion right; (iv) are Parts I–II faithful
to the original (control flow, constants, tolerances); (v) does every claim in the prose have a
computation behind it. Each candidate finding was then independently checked against the code
and, where a computation was needed, against the running kernel, and only the findings that
survived were acted on: **37 raised, 24 confirmed, 13 refuted.** The refuted ones are not listed
here because nothing was changed for them; the confirmed ones are listed in full in section 4.

Every computation used for the review ran against the delivered notebook's own state, by
importing the `.nb` and evaluating its `Input` cells in order in a fresh kernel, exactly as the
notebook's headless runner does. The pattern, which any reader can use to probe the notebook at
any point, is:

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
cat > probe.wls <<'WLSEOF'
cfHere = DirectoryName[ExpandFileName[$InputFileName]];
Get[FileNameJoin[{cfHere, "runner_header.wl"}]];
nb = Import[FileNameJoin[{cfHere, "claude-fable_Einstein-Rosen-2-Planes.nb"}], "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
(* evaluate Input cells 1..N silently, then ask anything of the resulting state *)
N0 = 135;
Block[{$Output = {}}, Do[cfRunCell[i, asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, 1, N0}]];
Print["state through cell ", N0];
(* ---- your question goes here; for example: ---- *)
Print["frameCanonical is symmetric (so a slot transposition is invisible on it): ",
  frameCanonical === Transpose[frameCanonical]];
WLSEOF
wolframscript -file probe.wls
```

## 3. The verdict on the three Part IV bridges

The author's suspicion was correct, and it goes further than Bridge 1.

| bridge | frame | what the "comparison" proves | verdict |
|---|---|---|---|
| 1, boosted | `frameCanonical . Lambda(x)`, `Lambda(x)` in `O(4,4)` | `omegaBoost == M omegaCanonical M^-1 - dM M^-1` — the gauge transformation law of the spin connection | **the same connection in a local gauge; trivial** |
| 2, null | `frameCanonical . U`, `U` constant | `omegaNull == U omegaCanonical U` — a constant similarity, no inhomogeneous term | **the same connection in a constant gauge; trivial, and weaker than Bridge 1** |
| 3, triality + octonionic torsion | `frameCanonical . triVecToSpin` plus contortion `lambda mSkew . frameTri` | the difference is a tensor; torsion `-2 lambda mSkew` | **a different connection; not trivial** |

The reason, stated once so that a student can apply it to any future "new bridge": *any* frame of
the form `frameCanonical . L(x)` with `L(x)` preserving the flat metric describes the same
geometry through a rotated local Minkowski system, and its Levi-Civita spin connection is the
canonical one transformed by the gauge law. Comparing it with the canonical connection re-derives
that law and nothing more. A bridge is a new *connection* only if it differs from the canonical
one by a **tensor**. Bridge 3 does; the fable-5.1 bridge of Part V does; Bridges 1 and 2 do not.

Bridges 1 and 2 were **not deleted**. They are correct, each teaches something real about the
gauge structure of the frame bundle, Bridge 1 is the object through which Part V explains what
an "inhomogeneous gauge term" actually is, and — new in this revision — Bridge 1 now carries the
spinor-level gauge law with an explicit spin lift, which is the one thing the original Section 18
had left out. What changed is the labelling: the Part IV title, its introduction, and the heads of
Sections 18 and 19 now say what each bridge is and is not, and the master comparison of Section 22
classifies all five connections in a `verdict` column.

## 4. The twenty-four confirmed findings, and what was done about each

Numbering is by theme, not by severity. "Where" gives the manifest and section; the assertion
labels are the strings the notebook prints with `PASS`.

**A. Mislabelled triviality (findings 1–5, all high severity).**
Bridge 1 and Bridge 2 were headlined as "genuinely different" bridges and "new spin
connections"; their comparisons verify identities, not comparisons.
*Fixed in the text*, `cells_part4.wl`: Part IV title → *"Three bridges between curved and flat
indices: two gauge transformations, and one new connection"*; new introduction with the paragraph
*"A word of honesty about what counts as NEW"*; Section 18 heading → *"Bridge 1 — a locally
boosted frame: the same connection in a local gauge"* with a *"WHAT THIS BRIDGE IS, AND IS NOT"*
paragraph; likewise Section 19 → *"…the same connection in a constant gauge, and the spinor metric
sigma"*. The overview cell of Section 0 (`cells_part1.wl`) and the README say the same. The
provenance pages 04, 05 and 06 each received a *"Status after the fable-5.1 review"* section at
the top.

**B. A curvature claim with no computation behind it (findings 6, 7, 10, 13).**
The master summary said "bridge 3 adds a torsion-dependent piece" to the curvature; `cfCurvature`
had never been applied to `omegaOct`.
*Fixed by computing it*, `cells_part4.wl` Section 20, new cell after `COMPARISON 3`:
`RiemannOct = cfCurvature[omegaOctMixed, X]` (1256 non-zero components, about 5 s), with the
assertions *"at lambda = 0 the curvature is the triality conjugate of the canonical curvature"*,
*"[has content]: the curvature DOES depend on lambda (witnessed)"*, *"the lambda-dependence is a
polynomial of degree exactly two"*, *"the lambda^1 term is the Levi-Civita covariant exterior
derivative of the contortion, dK + [omegaTriLC, K]"*, *"the lambda^2 term is [K_mu, K_nu]"*; and
its Ricci scalar `RicciScalarOct` with *"[THE RESULT]: R(omegaOct) − R(canonical) == −(1/4)
T_{abc} T^{abc}"*, which for this torsion is the constant `−42 lambda^2` (`mSkew . mSkew == 42`).
The fingerprint table of Section 22 gained the row `RiemannOct`, and the curvature and Ricci rows
of the comparison table now state what was proved.

**C. The covariant derivative was never applied to the model's own spinor (findings 8, 24).**
Section 17 promised the covariant derivative "of the 16-component spinor" and exercised it only
on a generic 16-tuple; `cfDiracOperator` was defined and never called.
*Fixed*, `cells_part4.wl` Section 17: a paragraph *"What this section does and does not do,
stated plainly"*, and a new cell applying `cfDcov16` and `cfDiracOperator` to `Psi16` of
Section 11 (`DcovPsi16`, `DiracPsi16`) with three assertions, including that in the six
directions on which `Psi16` does not depend the covariant derivative is purely the connection
term. Part V then takes `Psi16` through the fable-5.1 rescaling and proves the author-form
Lagrangian applied to `Psi16` **is** Section 11's `La[]`.

**D. The Cartan–Schouten analogy was overstated (finding 9).**
The Cartan–Schouten connections on a Lie group are flat and their torsion is the anholonomy of a
frame; `omegaOct` is not flat for any `lambda`, and the octonion structure constants violate the
Jacobi identity, so they are not the anholonomy of any frame.
*Fixed in the text*, Section 20 introduction, which now says exactly that.

**E. The distinguished spinor `unit` was never pinned (finding 11).**
Everything downstream of Section 9 — the triality bridge, the structure constants, the type-1 /
type-2 split — is built on `unit = uEig[[8]]`, a row of an `Eigensystem` result whose order
Mathematica does not promise.
*Fixed*, `cells_part2.wl` Section 9: `cfAssert["unit is pinned to the author's spinor
{1/Sqrt[2],0,0,0,1/Sqrt[2],0,0,0} …", unit === {1/Sqrt[2], 0, 0, 0, 1/Sqrt[2], 0, 0, 0}]`. If a
future kernel reorders the rows, this line fails loudly instead of every table changing silently.

**F. "NOT zero" was being proved by a test that passes vacuously (findings 12, 23).**
Five assertions of the form `! TrueQ[cfZeroArrayQ[expr]]` were the notebook's way of saying
"this is not identically zero". But `cfZeroArrayQ` returns `False` for any expression its
numerical probe cannot reduce to a number — an undefined function the probe rules do not reach,
say — so the pattern passes on an *inconclusive* evaluation, and the counter
`$cfNonVanishingWitnesses` was incremented before the outcome was known.
*Fixed*, `cells_part4.wl` Section 15: a new predicate

```wolfram
cfNonZeroWitnessQ[expr_] := Block[{$MaxExtraPrecision = 200}, Module[{vals, ok},
  vals = Quiet[N[Flatten[{expr}] /. cfProbeRules /. #, 30], {N::meprec, General::stop}] & /@ cfProbePoints;
  ok = AnyTrue[vals, Function[v, AllTrue[v, NumericQ] && Max[Abs[Chop[v, 10^-22]]] > 10^-10]];
  If[ok, $cfNonVanishingWitnesses++];
  ok]];
```

which succeeds only if at some probe point **every** entry is an actual number and one of them
is non-zero — a non-numeric leftover makes it fail, not pass. Every non-vanishing claim in the
notebook (the five in Part IV, all of those in Part V) now uses it; `cfZeroQ` no longer counts a
`False` as a witness; the self-test cell demonstrates the difference on an undefined `f[x0]` and
then resets both tallies; and Section 22 ends with a new assertion, *"no identity in this notebook
was accepted on numerical evidence alone"*, `$cfNumericCertificates === 0`, so that a slower
machine hitting a `Simplify` budget would produce a visible `FAIL` instead of a silently weaker
proof.

**G. The "independent check" of Section 16 was blind to the error it claimed to catch (findings
17, 22).** `cfSpinConnectionFromFrame` was compared with `cfSpinConnection` only on the canonical
frame, which is diagonal, hence equal to its own transpose, so a transposition of the frame's
curved and flat slots in either solver would have passed.
*Fixed*: the Section 16 text now says what the check can and cannot see; and Section 18 runs
both solvers on `frameSlotTest = frameCanonical . cfLambdaOf[1/3]`, a frame that is witnessed to
be non-symmetric, and asserts that they agree and that the result is the canonical connection
conjugated by the constant boost.

**H. The only test of the spinor connection term was a tautology (finding 18).**
`(1/8) omega [gamma^a,gamma^b] == (1/2) omega SAB` restates the definition of `SAB` and cannot
fail for any coefficient or sign.
*Fixed*, Section 17: the assertion is kept and labelled `[definition]`; the discriminating checks
are added — *"[has content] the spinor connection is compatible with omega: [Gamma^spin_mu,
gamma^a] + omega_mu^a_b gamma^b == 0"*, *"[control] with the opposite sign the compatibility check
FAILS (witnessed)"*, and *"[has content] and therefore the curved Dirac matrices are covariantly
constant: D_mu gammaCurved^nu == 0"*.

**I. Chirality was never tied to the type-1 / type-2 split (finding 19).**
*Fixed*, `cells_part2.wl` Section 5: `PL` is asserted to be the projector onto the upper eight
components and `PR` onto the lower eight, and `T16[8]` is asserted to commute with every `SAB`
(so each chiral half is `Spin(4,4)`-invariant); Section 17's block-diagonality paragraph now cites
it.

**J. No spinor connection for Bridges 1 and 2 (findings 16, 20).**
The user's Step 3 comparison existed only for Bridge 3.
*Fixed for Bridge 1*, Section 18, new cell: the spin lift `cfSpinLiftBoost = MatrixExp[theta
SAB[[1,5]]]` with `Inverse[S] . gamma^a . S == Lambda^a_b gamma^b` and `Transpose[S] . sigma16 .
S == sigma16`; `GammaSpinBoost = cfSpinMatrix[omegaBoost, mu]` (224 non-zero entries); and the
assertions *"[THE GAUGE LAW]: Gamma'_mu == S Gamma_mu Inverse[S] − D[S,x_mu] Inverse[S]"*, *"the
inhomogeneous term is −D[theta,x_mu] SAB[[1,5]], the spin image of −D[theta,x_mu] K"*, *"and that
is exactly cfSpinMatrix applied to the vector difference deltaBoost"*, *"[has content]: D'_mu
(S psi) == S D_mu psi"*, *"the curved Dirac matrices of the boosted frame are S gamma^mu
Inverse[S]"*, *"Dirac'[S psi] == S Dirac[psi]"*. Which of the two candidate laws holds was
determined by computation, not assumed: with `S = MatrixExp[+theta SAB[[1,5]]]` the law with `S
… Inverse[S]` holds and the one with `Inverse[S] … S` fails. Bridge 2 is a constant change of
basis, for which the spinor statement is the constant conjugation already implied by Section 19;
its verdict row records that nothing further is claimed for it.

**K. The triality matrix was called a "rotation of the flat space" and "a constant O(4,4)
rotation" (finding 15).** It is Euclidean-orthogonal (`Transpose[P] == Inverse[P]`) and is *not*
in `O(4,4)` — it carries `eta4488` to `sigma`, which is its purpose.
*Fixed*: text corrected in Section 20, and an assertion added, *"but it is NOT in O(4,4): P .
eta4488 . Transpose[P] != eta4488"*, witnessed.

**L. A group was misnamed (finding 21).** `sigma16` is preserved by `O(8,8)`, not `Spin(8,8)`.
*Fixed*, `cells_part3.wl` Section 11: both occurrences renamed.

**M. Bridge 2's "remarkable fact" (finding 14).** `etaNull == sigma` is true by the definition of
`sigma`; the page and the notebook now present it as an identity about the flat metric, not as
evidence about the connection.

## 5. The one thing added to Part IV that is not a fix: nothing

No mathematics of Parts I–IV was changed. Every assertion that passed before still passes, with
the same label, except the five non-vanishing assertions of finding F, whose *test* was replaced
and whose *claim* is unchanged. Fidelity to the original (hard rule 2) was re-checked by the
notebook's own `.mx` comparison at the end of the run: the Euler–Lagrange equations it writes are
still `SameQ` to the author's `DumpSave` files.

## 6. A defect found in this revision's own first version of Part V, and its diagnosis

The second full run of the rebuilt notebook gave 217 of 218 assertions passing. The failure was

```
FAIL  FABLE-5.1: the covariant Lagrangian with frame -> ID8 and volume factor -> 1 IS the author's La of Section 11, term for term
```

Two probes narrowed it. The first evaluated the difference of the two Lagrangians and found it
to be exactly the mass term, `(2 M/H) Psi^T sigma16 Psi`, with the "author-form" helper having
`Head` `Times` (a single product) where a sum of a kinetic and a mass term was expected. The
second rebuilt the helper by hand in the same kernel state and found it correct — so the defect
was in the *text* of the definition, not in the mathematics. The definition read

```wolfram
cfLagrangianAuthorForm[psi_List] := (1/H) Transpose[psi] . sigma16 . Sum[T16[a - 1] . D[psi, X[[a]]], {a, 8}]
  + 2 (M/H) Transpose[psi] . sigma16 . psi;
```

and in Wolfram Language a top-level line that begins with `+`, after a line that is already a
complete expression, is a **new expression**: the first line defined the helper without its mass
term, and the second line was evaluated on its own. The author's own `La[]` of Section 11 wraps
its right-hand side in parentheses for exactly this reason. The fix is the same pair of
parentheses, with a comment saying why they are load-bearing, and a new assertion that the
helper applied to `Psi16` **is** `La[]`. The log of the failing run is kept as
`claude-fable/run_fable51_second.log`.

Two smaller things the same diagnosis turned up and fixed: a constant all-ones spinor cannot
witness a mass term because `Transpose[psi] . sigma16 . psi == 0` for it (`sigma16` has zero
diagonal) — the witness now uses `e1 + e5`, for which the bilinear is `−2`; and the mass `M` is a
free constant with no probe value, so that one witness sets `M -> 1` inside the test and nowhere
else.

## 6b. Two defects in the review's own additions, found by the third run

The third full run (`run_fable51_third.log`) gave 248 of 250 assertions passing. Both failures
were in cells the review had just added, and both were defects of the test, not of the
mathematics.

- *"PL projects onto the upper (type-1) components, PR onto the lower (type-2) components"*
  compared `PL` with `ArrayFlatten[{{ID8, 0}, {0, 0}}]`. That expression is a **9×9** matrix:
  `ArrayFlatten` gives a scalar `0` the size of the other entries in its row and column, and the
  second row and column contain no matrix, so they get size 1. `PL` is `diag(ID8, 0)` exactly as
  claimed (`T16[8] == diag(−ID8, +ID8)` was confirmed directly), and the assertion now spells the
  projectors out with `DiagonalMatrix`.
- *"the curved Dirac matrices are covariantly constant, D_mu gammaCurved^nu == 0"* was placed in
  the cell that defines `GammaSpinCanonical`, two cells before `gammaCurvedCanonical` is defined,
  so it evaluated on an undefined symbol (`Part::partd`, the one cell with a message in that run,
  and 85 s spent simplifying garbage). It now sits in the cell that defines
  `gammaCurvedCanonical` and `cfDiracOperator`, where it passes in well under a second.

Both had passed in the prototype, which ran against the *complete* notebook state; the lesson,
recorded here so it is not relearned, is that an assertion must be prototyped at the cell where it
will live, not at the end.

## 7. Rebuild and run

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
python build_tools.py
#   manifest files : ['cells_part1.wl', 'cells_part2.wl', 'cells_part3.wl', 'cells_part4.wl', 'cells_part5.wl']
#   cells parsed   : 238 {'Title': 5, 'Subtitle': 1, 'Subsubtitle': 1, 'Text': 56, 'Section': 23, 'Input': 152}
#   run_all.wls    : 152 Input cells
#   notebook       : 238 cells -> .../claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb
cp -p claude-fable_Einstein-Rosen-2-Planes.nb "$(dirname "$(git rev-parse --show-toplevel)")/"   # delivery copy; optional
wolframscript -file nb_section_map.wls 2>&1 | tee nb_section_map.log     # the section-to-cell map
wolframscript -file run_from_nb.wls 2>&1 | tee run_fable51_fourth.log
```

The section-to-cell map the second command prints:

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
total Input cells: 152
```

The run's tally, and every line the review added, are reproduced in section 8 from
`run_fable51_fourth.log`. After a run, the two regenerated `.mx` files have identical content but
different bytes; restore the committed ones:

```bash
cd "$(git rev-parse --show-toplevel)"
git checkout -- claude-fable/claude-fable_Einstein-Rosen-2-Planes-eLa.mx \
                claude-fable/claude-fable_Einstein-Rosen-2-Planes-eLazt.mx
```

## 7a. Parse check and render check

The same two checks that certified the 2026-09-14 revision, on the rebuilt file. The parse check
(`verify_nb.wls`, which imports the `.nb` and asks `ToExpression` to parse every `Input` cell):

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
wolframscript -file verify_nb.wls 2>&1 | tee verify_nb_fable51.log
```

```
file bytes: 196239
Head: Notebook
cells: 238
style tally: {{Title, 5}, {Subtitle, 1}, {Subsubtitle, 1}, {Text, 56}, {Section, 23}, {Input, 152}}
input cells with plain-string BoxData: 152
total input characters: 126789
input cells that FAIL to parse: {}
first cell: InputForm[(* --- provenance banner, as in the original notebook ------------------------------------]
last cell : InputForm[(* --- final tally of every assertion made in this notebook ------------------------------]
```

The render probe (`render-check/probe.wls`, which opens the file in a Mathematica front end,
invisibly and read-only, and counts what the front end could not parse):

```bash
export CF_OUT="${CF_OUT:-$(dirname "$(git rev-parse --show-toplevel)")/render4}"
mkdir -p "$CF_OUT"
cd "$(git rev-parse --show-toplevel)/claude-fable/render-check"
wolframscript -file probe.wls 2>&1 | tee "$CF_OUT/probe.log"
```

```
file      : 196239 bytes  sha256 3de54f2e3dea8e457faec8449d5e938fa84cc5dc4ff21e8628506f6a1be7867f
cells     : 238
by style  : {{Input, 152}, {Text, 56}, {Section, 23}, {Title, 5}, {Subsubtitle, 1}, {Subtitle, 1}}
ErrorBox  : 0
Input cells left as an unparsed string : 0
box heads : {RowBox}
private-use chars remaining: 0
source unchanged: 3de54f2e3dea8e457faec8449d5e938fa84cc5dc4ff21e8628506f6a1be7867f
```

Every one of the 152 `Input` cells parses in the kernel and in the front end; nothing became an
error box; the file was not modified by being opened.

## 8. What the run prints

The tally at the end of `run_fable51_fourth.log`:

```
identities accepted on numerical evidence alone : 0   (stage 3 returned True)
non-vanishing witnesses                         : 19   (cfNonZeroWitnessQ found a probe point at which every entry is a
                                                     number and one of them is non-zero: a complete proof of non-vanishing)
  PASS  no identity in this notebook was accepted on numerical evidence alone
Assertions run: 250   passed: 250   failed: 0
==================== RUN SUMMARY ====================
cells evaluated : 152
total seconds   : 144.995
cells w/ msgs   : 0
==================== ASSERTIONS ====================
assertions run  : 250
passed          : 250
FAILED          : 0
```

The 2026-09-14 revision had 182 assertions. The 68 added by this review and by Part V all pass;
every assertion of the earlier revision still passes under its original label, except the five
non-vanishing claims whose test was replaced (section 4, F). The lines the review added to Parts
I–IV, as the run prints them (the `PASS` lines of `run_fable51_fourth.log`, in order):

```
  PASS  PL projects onto the upper (type-1) components, PR onto the lower (type-2) components
  PASS  T16[8] commutes with every SAB: the chiral halves are each Spin(4,4)-invariant
  PASS  unit is pinned to the author's spinor {1/Sqrt[2],0,0,0,1/Sqrt[2],0,0,0} -- the row order of Eigensystem is not relied on silently
  PASS  but NOT a O(8,8) transformation: it does not preserve sigma16
  PASS  [has content] the spinor connection is compatible with omega: [Gamma^spin_mu, gamma^a] + omega_mu^a_b gamma^b == 0
  PASS  [control] with the opposite sign the compatibility check FAILS (witnessed): the sign is fixed by the vielbein postulate, not free
  PASS  [has content] and therefore the curved Dirac matrices are covariantly constant: D_mu gammaCurved^nu == 0
  PASS  [definition] Dcov[mu] Psi16 - D[Psi16, x_mu] == Gamma^spin[mu] . Psi16
  PASS  in the six directions on which Psi16 does not depend, Dcov Psi16 is purely the connection term
  PASS  the connection term does not vanish on Psi16: the connection matrices themselves are non-zero (witnessed)
  PASS  the slot-test frame is genuinely not symmetric
  PASS  INDEPENDENT CHECK on a non-symmetric frame: the two solvers agree, so the curved/flat slots are placed correctly in both
  PASS  and the result is the canonical connection conjugated by the constant boost, as the gauge law demands
  PASS  BRIDGE 1 spin lift: Inverse[S] . S == ID16
  PASS  BRIDGE 1 spin lift: S preserves the spinor metric, Transpose[S] . sigma16 . S == sigma16
  PASS  BRIDGE 1 spin lift [has content]: Inverse[S] . gamma^a . S == Lambda^a_b gamma^b  (S is the spin lift of Lambda)
  PASS  COMPARISON 1 at the spinor level [THE GAUGE LAW]: Gamma'_mu == S Gamma_mu Inverse[S] - D[S,x_mu] Inverse[S]
  PASS  COMPARISON 1 at the spinor level: the inhomogeneous term is -D[theta,x_mu] SAB[[1,5]], the spin image of -D[theta,x_mu] K
  PASS  COMPARISON 1 at the spinor level: and that is exactly cfSpinMatrix applied to the vector difference deltaBoost
  PASS  BRIDGE 1 [has content]: D'_mu (S psi) == S D_mu psi for a generic spinor -- one covariant derivative, two gauges
  PASS  BRIDGE 1: the curved Dirac matrices of the boosted frame are S gamma^mu Inverse[S]
  PASS  BRIDGE 1: so the Dirac operator is one operator in two gauges, Dirac'[S psi] == S Dirac[psi]
  PASS  but it is NOT in O(4,4): P . eta4488 . Transpose[P] != eta4488 (it carries eta4488 to sigma)
  PASS  BRIDGE 3: at lambda = 0 the curvature is the triality conjugate of the canonical curvature
  PASS  BRIDGE 3 [has content]: the curvature DOES depend on lambda (witnessed)
  PASS  BRIDGE 3: the lambda-dependence is a polynomial of degree exactly two
  PASS  BRIDGE 3: the lambda^1 term is the Levi-Civita covariant exterior derivative of the contortion, dK + [omegaTriLC, K]
  PASS  BRIDGE 3: the lambda^2 term is [K_mu, K_nu], the contortion commuted with itself
  PASS  BRIDGE 3: at lambda = 0 the Ricci scalar is the canonical one
  PASS  BRIDGE 3 [THE RESULT]: R(omegaOct) - R(canonical) == -(1/4) T_{abc} T^{abc}, a constant shift set by the torsion alone
  PASS  BRIDGE 3: equivalently -lambda^2 (mSkew . mSkew), with mSkew . mSkew == 42, so the shift is exactly -42 lambda^2
```

The closed forms behind the last two lines, printed from the completed state:

```
RicciScalarCanonical = -3*H^2*((55 + 7*Cos[12*H*x0])*Cot[6*H*x0]^2*Csc[6*H*x0]^2 - 2*Derivative[1][a4][H*x4]^2)
RicciScalarOct       = (-3*(3*(39*H^2 + 7*lambda^2) + 4*(31*H^2 - 7*lambda^2)*Cos[12*H*x0]
                         + 7*(H^2 + lambda^2)*Cos[24*H*x0])*Csc[6*H*x0]^4)/4 + 6*H^2*Derivative[1][a4][H*x4]^2
RicciScalarOct - RicciScalarCanonical = -42*lambda^2
```

Non-zero component counts of the objects this review added: `GammaSpinCanonical` 192,
`GammaSpinBoost` 224, `RiemannOct` 1256; of the Part V objects: `GammaWeitzenboeck` 13,
`omegaFable51` 0, `contortionFable51` 24, `torsionFable51` 24, `RiemannFable51` 0,
`omegaFable51BoostMixed` 4; and, for reference, unchanged from the earlier revision: `GammaCanonical` 37, `omegaCanonical` 24,
`omegaBoost` 28, `omegaNull` 48, `omegaTriLC` 84, `contortionOct` 78, `RiemannCanonical` 156,
`RiemannBoost` 156, `RiemannNull` 396, `torsionOctFlat` 48, `deltaBoost` 4, `deltaOct` 78,
`GammaSpinOctExtra` 160.

## 8a. Commit and push, and verification from a fresh clone

Recorded in section 10 at the end of this page, after the hard-rules section.

## 9. The hard rules, and how each was honoured

1. **Backups first** — section 1; taken before the first edit, kept outside the repository.
2. **Fidelity first** — no control flow, constant, tolerance or heuristic of Parts I–II was
   changed; the `Simplify` budget of 1 s and `FullSimplify` of 3 s are the original's; the `.mx`
   comparison at the end of the run still returns residual `{0}`.
3. **Missing symbols are reported, not invented** — `a4` and `la` remain undefined and are
   announced on screen by Section 15; nothing in Part V or in the fixes gives them a value. The
   one place a constant had to be a number — the mass `M` inside a single numerical witness — is
   set to `1` inside that one test only, and the assertion label says so.
4. **Nothing was taken less than seriously** — every instruction in the task was carried out;
   where an instruction could not be met in the form given, the page says so in the open. One such
   case: "three new spin connections" of the original task were found to be one; the two that are
   gauge transforms were kept and relabelled rather than deleted, because deleting correct,
   verified work is the author's decision and not this reviewer's. Should the author want them
   removed, the command that forces it is: *"Delete Sections 18 and 19 and renumber."*
5. **All errors and warnings fixed** — the run reports every assertion passing and zero cells
   raising messages; the one message that fires by design (`Simplify::time` on the boosted-frame
   fable-5.1 solver, whose budget is the original's) is announced before it can fire and quieted
   for that computation only, exactly as Section 14 of the original handles its own.

## 10. Commit, push, and verification from a fresh clone

Everything of this revision was staged by name — the modified tracked files with `git add -u`
and the new deliverables explicitly — so that nothing else on the author's disk could be swept
in. `git check-ignore` confirmed that no deliverable is ignored, and `git ls-files` that no
`.txt` is tracked.

```bash
cd "$(git rev-parse --show-toplevel)"
git add -u
git add PROVENANCE-11-REVIEW-AND-REFACTOR-OF-THE-OPUS-SOLUTION.md PROVENANCE-12-FABLE-5.1-BRIDGE-COMPARED.md \
        STUDENT-GUIDE-FABLE-5.1-BRIDGE.md claude-fable/cells_part5.wl \
        claude-fable/nb_section_map.wls claude-fable/nb_section_map.log \
        claude-fable/run_fable51_second.log claude-fable/run_fable51_third.log claude-fable/run_fable51_fourth.log \
        claude-fable/student_fable51.wls claude-fable/student_fable51.log claude-fable/verify_nb_fable51.log
git ls-files | grep -ci '\.txt$'        # 0
git commit -F - <<'MSG'
Review and refactor the Opus-5 solution; add Part V, the fable-5.1 bridge
[... the message is in the history: git log -1 d2042f8 ...]
MSG
git push origin main
```

The commit is `d2042f8`, *"Review and refactor the Opus-5 solution; add Part V, the fable-5.1
bridge"*, on `main` of `https://github.com/once-ere/Pre-Universe_with_Claude.git`.

**Verification 1 — a fresh clone holds exactly the pushed tree.**

```bash
V="$(mktemp -d)/verify-clone"
git clone -q https://github.com/once-ere/Pre-Universe_with_Claude.git "$V"
cd "$V"
git log --oneline -1                    # d2042f8 Review and refactor the Opus-5 solution; add Part V, the fable-5.1 bridge
git ls-files | wc -l                    # 130
git ls-files | grep -ci '\.txt$'        # 0
sha256sum claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb claude-fable/cells_part5.wl \
          PROVENANCE-11*.md PROVENANCE-12*.md STUDENT-GUIDE*.md README.md
```

The six hashes from the clone, and the same six from the working tree the commit was made in,
are identical:

```
3de54f2e3dea8e457faec8449d5e938fa84cc5dc4ff21e8628506f6a1be7867f  claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb
69e8a501e2dd716e0134f9f342389c1c099e812fe62a149cf7eff01828bdf809  claude-fable/cells_part5.wl
1b556f97a86fe1321207716970fb8ce73a66e85713ee1c4971b3d8f75664e966  PROVENANCE-11-REVIEW-AND-REFACTOR-OF-THE-OPUS-SOLUTION.md
e48932ccbc4f90e8bd2ac33d47e679999616b2e107cc4a0f2c6e65c837faf5ea  PROVENANCE-12-FABLE-5.1-BRIDGE-COMPARED.md
567ffc2a46ab062bdf68a149316b6411ac5205d5634265105563703397f3baaa  STUDENT-GUIDE-FABLE-5.1-BRIDGE.md
d2b64d0cb0cc50970343b5d897b2b309197ff16221086ca46451935a184c67ea  README.md
```

The notebook's hash is also the one the render probe of section 7a reported before and after
opening the file, so the file that renders, the file that was evaluated, and the file in the
repository are one and the same.

**Verification 2 — the notebook evaluates straight out of the clone.**

```bash
cd "$V/claude-fable"
wolframscript -file run_from_nb.wls 2>&1 | tee run_from_clone.log
tail -n 20 run_from_clone.log
```

The tail of `run_from_clone.log`, evaluated out of the clone at `d2042f8`:

```
==================== ASSERTIONS ====================
assertions run  : 250
passed          : 250
FAILED          : 0
====================================================
```

The same 250 assertions pass out of the clone as out of the working tree; the clone needed no
file that is not in the repository.

**A small repair made while recording this.** The `.gitignore` carried a rule for the author's
own Gmail printout on dark energy, `Gmail - w = equation of state parameter … .pdf`, written
with surrounding double quotes. Quotes are literal characters in `.gitignore`, so the rule
matched nothing and the file showed as untracked. The quotes were removed; the file is now
ignored as intended and stays on the author's disk, unpublished, like `Pre.txt`.
