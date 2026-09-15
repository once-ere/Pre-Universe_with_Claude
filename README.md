# Pre-Universe

Quantum description of Pre-gravity, Pre-Big-Bang, with 3-Generations of Einstein-Rosen 2-Plane-Bridges

Original mathematics and physics: **Patrick L. Nash, Ph.D.**, © 2022, under the GNU General
Public License. Professor, UTSA Physics and Astronomy, Retired. Patrick299Nash at gmail.
Please cite that work, and this page, if you use it.

---

## What is in here

The author's scratch notebook, `Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb`,
has been refactored into a commented, verified, self-checking notebook, and then extended with
new material on frame fields and spin connections.

**The deliverable is [`claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb`](claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb).**

It evaluates in about two minutes and checks itself as it goes: **182 assertions, 182 passing,
zero cells raising messages.** Every identity is closed symbolically — the run reports
`identities accepted on numerical evidence alone : 0`.

| part | sections | what it does |
|---|---|---|
| I | 1–9 | the algebraic engine: the flat 4+4 Minkowski metric, the real 8×8 Clifford generators `tau`, the 16×16 Dirac matrices `T16`, the `so(4,4)` generators, the 256-element basis of the 16×16 matrix algebra, and the split-octonion structure constants via Cartan triality |
| II | 10–14 | the original physics, reproduced: the 16-component wave function of the "un-universe", its Lagrangian, the Euler–Lagrange equations, the change to light-cone `(z,t)` coordinates, the decoupling into four blocks of four, the Maple closed forms, the bilinear invariants, and M6 = 3 generations of Einstein–Rosen 2-planes |
| III | 15–17 | **new** — the frame field (vielbein) `e`, the bridge `g = e · η · eᵀ`, the canonical spin connection from the zero-torsion vielbein postulate, and the gauge-covariant derivative of the 16-component spinor |
| IV | 18–21 | **new** — three further ways of bridging curved indices to flat tangent indices, a spin connection derived for each, and a component-by-component comparison of all four |

A vielbein here is simply an 8-dimensional vierbein.

### The four spin connections

| connection | frame field | flat metric | same `g`? | metric compatible? | torsion zero? | difference from canonical |
|---|---|---|---|---|---|---|
| `omegaCanonical` | `frameCanonical` (diagonal) | `eta4488` | reference | yes | yes | — |
| `omegaBoost` | `frameCanonical · Λ(x)` | `eta4488` | yes | yes | yes | an inhomogeneous gauge term, `−∂_μθ · K` — one scalar gradient times one fixed generator, 4 non-zero components |
| `omegaNull` | `frameCanonical · U` | `etaNull == sigma` | yes | yes | yes | a constant similarity only, `U ω U`, with no inhomogeneous term |
| `omegaOct` | `frameCanonical · triVecToSpin` | `etaTri == sigma` | yes | yes | **no** | totally antisymmetric torsion `−2λ·mSkew`, plus a contortion term |

Two results worth pointing at: the triality tangent metric turns out to be **exactly** the spinor
metric `sigma`, and so does the null-frame tangent metric.

## Running it

Needs Wolfram Mathematica (developed against 15.0.1). From a fresh clone:

```bash
cd claude-fable
wolframscript -file run_from_nb.wls 2>&1 | tee run_from_nb.log
```

That imports the delivered `.nb`, evaluates its 139 `Input` cells in order in one kernel, and
prints a per-cell timing log, every message raised, and the assertion tally. To open it instead,
just open `claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb` in the Mathematica front end and
evaluate the notebook.

The notebook is **generated**, never hand-edited. It is built from the four cell manifests
`claude-fable/cells_part1.wl` … `cells_part4.wl` by:

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

The only absolute paths left are the author's own delivery folder, where a second copy of the
notebook is placed for convenience, and they are marked as optional where they appear.

| page | what it records |
|---|---|
| [PROVENANCE-00](PROVENANCE-00-READING-THE-ORIGINAL-NOTEBOOK.md) | reading the 24 MB original without evaluating it |
| [PROVENANCE-01](PROVENANCE-01-BUILDING-AND-RUNNING-THE-REFACTORED-NOTEBOOK.md) | building the notebook from the manifests, and running it |
| [PROVENANCE-02](PROVENANCE-02-FRAME-FIELD-AND-CANONICAL-SPIN-CONNECTION.md) | the frame field and the canonical spin connection |
| [PROVENANCE-03](PROVENANCE-03-SPINOR-COVARIANT-DERIVATIVE.md) | the spinor covariant derivative |
| [PROVENANCE-04](PROVENANCE-04-BRIDGE-1-BOOSTED-FRAME-COMPARED.md) | bridge 1, the locally boosted frame |
| [PROVENANCE-05](PROVENANCE-05-BRIDGE-2-NULL-FRAME-COMPARED.md) | bridge 2, the null frame |
| [PROVENANCE-06](PROVENANCE-06-BRIDGE-3-OCTONIONIC-TORSION-COMPARED.md) | bridge 3, octonionic torsion |
| [PROVENANCE-07](PROVENANCE-07-PHYSICS-REPRODUCTION-AND-MX-FIDELITY.md) | reproducing the original physics, and `.mx` fidelity |
| [PROVENANCE-08](PROVENANCE-08-REPOSITORY-PUSH-AND-VERIFICATION.md) | the repository push and its verification |
| [PROVENANCE-09](PROVENANCE-09-EVALUATING-THE-NOTEBOOK-AND-CHECKING-THE-OUTPUT.md) | evaluating the notebook and auditing what it prints |
| [PROVENANCE-10](PROVENANCE-10-RENDER-CHECK.md) | opening it in Mathematica and checking it renders |

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
  cells_part1.wl .. cells_part4.wl           <- the manifests it is generated from
  build_tools.py                             <- the generator
  run_from_nb.wls                            <- evaluates the .nb straight out of the file
  prov0*.wls, *.log                          <- the scripts and logs behind the provenance pages
  render-check/                              <- evidence that it renders in the front end
  extract/                                   <- plain-text extract of the original notebook
PROVENANCE-*.md               one page per stage, each complete on its own
Pre-gravityPre-Big_Bang_*.nb  the author's original notebook
```

## Licence

GNU General Public License v3 — see [LICENSE](LICENSE).

The original mathematics and physics are Patrick L. Nash's. The refactoring, the frame-field and
spin-connection chapters of Part III, the three new bridges of Part IV, and the provenance pages
were prepared with Claude (Anthropic) at the author's direction, 2026-09-14.
