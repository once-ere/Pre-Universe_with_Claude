# Pre-Universe

Frame fields, spin connections and the 16-component split-octonion spinor on a curved 4+4
spacetime — the "un-universe" of Patrick L. Nash's *Pre-gravity / Pre-Big-Bang* notebook —
refactored into a self-checking Mathematica notebook, extended with a canonical spin connection
and four further bridges between curved and flat indices, and documented so that each stage can
be repeated from the commands on its own page.

Original mathematics and physics: Patrick L. Nash, Ph.D., © 2022, GNU General Public License.
Refactoring and Parts III–IV: prepared with Claude (Anthropic, Opus) at the author's direction,
2026-09-14. Review of all of that, and Part V: prepared with Claude (Anthropic, Fable 5.1) at the
author's direction, 2026-09-16.

## What is in here

The author's scratch notebook, `Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb`,
has been refactored into a commented, verified, self-checking notebook, and then extended with
new material on frame fields and spin connections.

**The deliverable is [`claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb`](claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb).**

It evaluates in two to four minutes and checks itself as it goes: **250 assertions, 250 passing,
zero cells raising messages.** Every identity is closed symbolically — the run reports
`identities accepted on numerical evidence alone : 0`, and the last assertion of the notebook
fails if that number is ever not zero. Every "this is not zero" claim is certified by a numerical
witness that must evaluate to an actual number (19 of them).

| part | sections | what it does |
|---|---|---|
| I | 1–9 | the algebraic engine: the flat 4+4 Minkowski metric, the real 8×8 Clifford generators `tau`, the 16×16 Dirac matrices `T16`, the `so(4,4)` generators, the 256-element basis of the 16×16 matrix algebra, and the split-octonion structure constants via Cartan triality |
| II | 10–14 | the original physics, reproduced: the 16-component wave function of the "un-universe", its Lagrangian, the Euler–Lagrange equations, the change to light-cone `(z,t)` coordinates, the decoupling into four blocks of four, the Maple closed forms, the bilinear invariants, and M6 = 3 generations of Einstein–Rosen 2-planes |
| III | 15–17 | **new** — the frame field (vielbein) `e`, the bridge `g = e · η · eᵀ`, the canonical spin connection from the zero-torsion vielbein postulate, and the gauge-covariant derivative of the 16-component spinor, applied to the model's own `Ψ16` |
| IV | 18–20 | **new** — three further ways of bridging curved indices to flat tangent indices, a spin connection derived for each, and a component-by-component comparison with the canonical one. Two of the three are the canonical connection in a different gauge and are labelled as such; the third is a different connection with octonionic torsion |
| V | 21–22 | **new** — the **fable-5.1 bridge**: the Weitzenböck (teleparallel) connection in which the canonical frame itself is parallel. Zero spin connection and zero curvature in that frame; the canonical spin connection is proved to be minus the contortion of its torsion; `R == −T + B` in closed form; the curved Dirac equation of the model is proved equivalent to a connection-free one by an exact rescaling of the spinor. Then a master comparison of all five connections |

A vielbein here is simply an 8-dimensional vierbein.

### The five spin connections

| connection | frame field | flat metric | same `g`? | metric compatible? | torsion zero? | curvature zero? | difference from canonical | verdict |
|---|---|---|---|---|---|---|---|---|
| `omegaCanonical` | `frameCanonical` (diagonal) | `eta4488` | reference | yes | yes | no | — | Levi-Civita |
| `omegaBoost` (Bridge 1) | `frameCanonical · Λ(x)` | `eta4488` | yes | yes | yes | no | the gauge term `−∂_μθ · K`, which Part V identifies as the fable-5.1 connection of the boosted frame; at the spinor level `Γ' = S Γ S⁻¹ − dS S⁻¹` with the explicit spin lift `S` | same connection, local gauge |
| `omegaNull` (Bridge 2) | `frameCanonical · U` | `etaNull == sigma` | yes | yes | yes | no | a constant similarity `U ω U` | same connection, constant gauge |
| `omegaOct` (Bridge 3) | `frameCanonical · triVecToSpin` | `etaTri == sigma` | yes | yes | **no**: axial torsion `−2λ·mSkew` | no | a contortion tensor; the curvature is quadratic in `λ` and the Ricci scalar is shifted by the constant `−42 λ²` | **different connection** |
| `omegaFable51` (fable-5.1) | `frameCanonical` (parallel) | `eta4488` | yes | yes | **no**: vector + tensor torsion, axial part zero | **yes** | `omegaCanonical == −contortion(T_fable51)`, a tensor; `omegaFable51 == 0` | **different, flat connection** |

Three results worth pointing at: the triality tangent metric and the null-frame tangent metric
are both **exactly** the spinor metric `sigma`; the Levi-Civita spin connection of this geometry
is **exactly** minus the contortion of the Weitzenböck torsion; and because that torsion's vector
part is a gradient, the curved Dirac equation of the model is the connection-free one for
`Ψ / Sqrt[Sin[6 H x0]]`.

## Running it

Needs Wolfram Mathematica (developed against 15.0.1). From a fresh clone:

```bash
cd claude-fable
wolframscript -file run_from_nb.wls 2>&1 | tee run_from_nb.log
```

That imports the delivered `.nb`, evaluates its 152 `Input` cells in order in one kernel, and
prints a per-cell timing log, every message raised, and the assertion tally. To open it instead,
just open `claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb` in the Mathematica front end and
evaluate the notebook.

To *use* the Part V result — solve the connection-free Dirac equation and convert — there is a
worked script:

```bash
cd claude-fable
wolframscript -file student_fable51.wls
```

The notebook is **generated**, never hand-edited. It is built from the five cell manifests
`claude-fable/cells_part1.wl` … `cells_part5.wl` by:

```bash
cd claude-fable
python build_tools.py
```

## Provenance

Every stage of the work has a page of its own, each carrying the complete commands for that
stage, so no page depends on another.

**The commands are relocatable.** Clone this repository wherever you like. Shell blocks find the
root with `git rev-parse --show-toplevel`, and every Wolfram script locates itself from
`$InputFileName`, so nothing is tied to the path it happened to be written on:

```wolfram
cfHere = DirectoryName[ExpandFileName[$InputFileName]];   (* <repo>/claude-fable *)
cfRepo = ParentDirectory[cfHere];                        (* the repository root  *)
cfNB   = FileNameJoin[{cfHere, "claude-fable_Einstein-Rosen-2-Planes.nb"}];
```

The scripts under `claude-fable/render-check/` are run in place and write their output to the
directory named by the `CF_OUT` environment variable, defaulting to a folder in the system temp
directory, so running them never writes into the repository.

No committed Wolfram script contains an absolute path at all. The only absolute paths left in
the provenance pages are the author's own delivery folder, where a second copy of the notebook
is placed for convenience and which is marked optional where it appears; a temp directory one
page creates for itself; and prose recording where the working repository sat when a page was
written.

| page | what it records |
|---|---|
| [PROVENANCE-00](PROVENANCE-00-READING-THE-ORIGINAL-NOTEBOOK.md) | reading the 24 MB original without evaluating it |
| [PROVENANCE-01](PROVENANCE-01-BUILDING-AND-RUNNING-THE-REFACTORED-NOTEBOOK.md) | building the notebook from the manifests, and running it |
| [PROVENANCE-02](PROVENANCE-02-FRAME-FIELD-AND-CANONICAL-SPIN-CONNECTION.md) | the frame field and the canonical spin connection |
| [PROVENANCE-03](PROVENANCE-03-SPINOR-COVARIANT-DERIVATIVE.md) | the spinor covariant derivative |
| [PROVENANCE-04](PROVENANCE-04-BRIDGE-1-BOOSTED-FRAME-COMPARED.md) | bridge 1, the locally boosted frame (a gauge transformation; see its status section) |
| [PROVENANCE-05](PROVENANCE-05-BRIDGE-2-NULL-FRAME-COMPARED.md) | bridge 2, the null frame (a constant gauge; see its status section) |
| [PROVENANCE-06](PROVENANCE-06-BRIDGE-3-OCTONIONIC-TORSION-COMPARED.md) | bridge 3, octonionic torsion |
| [PROVENANCE-07](PROVENANCE-07-PHYSICS-REPRODUCTION-AND-MX-FIDELITY.md) | reproducing the original physics, and `.mx` fidelity |
| [PROVENANCE-08](PROVENANCE-08-REPOSITORY-PUSH-AND-VERIFICATION.md) | the first repository push and its verification |
| [PROVENANCE-09](PROVENANCE-09-EVALUATING-THE-NOTEBOOK-AND-CHECKING-THE-OUTPUT.md) | evaluating the notebook and auditing what it prints |
| [PROVENANCE-10](PROVENANCE-10-RENDER-CHECK.md) | opening it in Mathematica and checking it renders |
| [PROVENANCE-11](PROVENANCE-11-REVIEW-AND-REFACTOR-OF-THE-OPUS-SOLUTION.md) | the review of everything above: 24 confirmed findings, what was changed, the rebuild, run, render check and push |
| [PROVENANCE-12](PROVENANCE-12-FABLE-5.1-BRIDGE-COMPARED.md) | the fable-5.1 bridge, compared to the canonical spin connection |
| [STUDENT-GUIDE](STUDENT-GUIDE-FABLE-5.1-BRIDGE.md) | the fable-5.1 bridge explained from the ground up, and how to use it |

## Fidelity to the original

The refactor reproduces the author's Euler–Lagrange equations **exactly**: the `eLa` and `eLazt`
the notebook writes are `SameQ` to the author's own `DumpSave` files, with residual `{0}`. The
session policy is the original's and unchanged (`Simplify` at a 1-second budget, `FullSimplify`
at 3 seconds). Where the original leaves a symbol undefined — the scalar function `a4`, and `la`
— it is carried through symbolically and **never** invented; the notebook says so on screen.

## Layout

```
claude-fable/                 the deliverable, its manifests, build tool, runners and logs
  claude-fable_Einstein-Rosen-2-Planes.nb    <- the notebook
  cells_part1.wl .. cells_part5.wl           <- the manifests it is generated from
  build_tools.py                             <- the generator; reproduced in full in PROVENANCE-01
  run_from_nb.wls                            <- evaluates the .nb straight out of the file
  student_fable51.wls                        <- uses the Part V result on a generic spinor
  nb_section_map.wls                         <- prints the section-to-Input-cell map without evaluating
  prov0*.wls, run_fable51_*.log, *.log       <- the scripts and logs behind the provenance pages
  probe*.wls, check_deltas.wls, cmp_mx.wls   <- development scratch, inventoried in PROVENANCE-01 5a
  render-check/                              <- evidence that it renders in the front end
  extract/                                   <- the extractor for the original notebook (its output is regenerated, not committed)
PROVENANCE-*.md               one page per stage, each complete on its own
STUDENT-GUIDE-*.md            the fable-5.1 bridge for a reader starting from nothing
Pre-gravityPre-Big_Bang_*.nb  the author's original notebook
```

## Licence

The original work is © 2022 Patrick L. Nash under the GNU General Public License; this
repository carries that licence forward. Please cite the original work, and this repository, if
you use it.
