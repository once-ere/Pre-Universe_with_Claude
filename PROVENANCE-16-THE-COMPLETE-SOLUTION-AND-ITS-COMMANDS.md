# Provenance 16 — The complete solution and its commands: the fermion fable, its canonical quantization in 4+4 dimensions, the coupled system with the primordial gravitational field, the density-functional ground and first excited states, the answers to [1] and [2], and every command that solves, tests, verifies, executes and displays the calculations

**The complete solution of the work of 2026-09-24 and 2026-09-25.** This page holds all of it in one
place: the foundation that was pushed and completed first (Effort 0, section 2); the fermion fable, a
complex 16-component Grassmann spinor canonically quantized in 4+4 dimensions, with its field
equations in the primordial gravitational field, its energy–momentum tensor operator, pressure,
density, equations of state and a complete discussion of the canonical spin connection (Effort A,
section 3); the fermion fable as the source of the Einstein equations of the primordial gravitational
field, the canonical spin connection of the interacting system, the Kohn–Sham source, the
density-functional ground and first excited states, the solution from the beginning of the present
universe to today, and the answers to the author's questions [1] and [2] (Effort B, section 4); the
adversarial design review with every finding, its verdict and the correction adopted (section 5);
and every command that was used to solve the coupled system and to test, verify, execute and display
the calculations, with what each command does, why, what it needs, how long it takes, what it prints
and how to tell success from failure (Effort C, section 6). Section 7 is the verification of the
repository, and section 8 lists what remains open.

This page is complete on its own. Everything a reader needs is restated here: sections 3 and 4
restate the full content of the work of Efforts A and B, every equation, result, number, caveat and
answer, so that nothing has to be looked up anywhere else. Code, logs, data files, notebooks, and the
TeX and PDF files are named only as the places where things are computed, recorded or produced.

**How to read the evidence.** Every mathematical or numerical statement on this page carries one of
these marks:

| mark | meaning |
|---|---|
| **[A]**, **[proved P §n]** | an assertion `cfAssert[label, test]` of the Mathematica notebook, Part P, Section n. The run log prints `PASS  label`; the label is quoted **verbatim**, in backticks, exactly as the log prints it |
| **[VII]**, **[VIII]** | proved in Part VII (Sections 26–29) or Part VIII (Sections 30–33) of the notebook; the labels are quoted verbatim from its run logs |
| **[D]**, **[displayed P §n]** | a displayed or printed output of the notebook (a table, a count, a closed form, a `Print` line of the run log), not an assertion |
| **[P]**, **[prose P §n]** | stated only in a `Text` cell (or a code comment) of the notebook; not checked by an assertion |
| **[nb05 §n]**, **[nb06 §n]**, **[nb07 §n]** | a number printed by an executed cell of the fable-cosmology notebook `05_fermion_fable_quantum_eos.ipynb`, `06_fable_primordial_gravity_8d.ipynb` or `07_fable_dft_states.ipynb`, section n, in the executed versions committed in `aca5102`; every such cell asserts the claims it prints (a failed assertion stops the notebook). A number quoted from the wall-state report and followed by **[nb07 §n]** is printed again by notebook 07 (or by a result file it writes in that section), to the digits it prints |
| **[WG n]** | a result of the wall-state solver, quoted from its report `fable-cosmology/fermion/waveguide_REPORT.txt`, section n, which names the log of the run that produced it |
| **[commit h]** | stated in the message of commit `h` of the repository (`git log --format=%B -1 h` prints it) |
| **[derived here]** | a short derivation carried out on this page from marked results, every step shown |
| **[file]** | read from a named file of the repository (code, CSV, log), which is named |

Numbers are quoted from the files and logs named next to them. Nothing is invented. `a4` is never
given a value anywhere: the notebook's last assertion of Part VIII checks that it is still undefined,
`PART VIII [control]: a4 is STILL UNDEFINED -- nothing in Part VIII gave it a value; the scale factors scA, scB, scC were only ever substituted inside assertions, and none of them entered the canonical frame`.

**Two kinds of "section".** "Section n" with a capital S and an integer n is a section of the
Mathematica notebook (Sections 1–33; Part VI is Sections 23–25, Part VII Sections 26–29, Part VIII
Sections 30–33). "section n" in lower case, and any section number with a dot in it, is a section of
this page. Formulas are written in plain text, close to the notebook's Wolfram notation: `T16[a]` are
the 16×16 Dirac matrices, `sigma16` the spinor metric, `Psi^ddag` the classical conjugate, `Psibar`
the Dirac conjugate, `d_mu` a partial derivative, `D_mu` the spin-covariant derivative, `Sqrt[g]` the
volume factor `Sqrt[|det g|]`, `G^mu_nu` the Einstein tensor with one index up and one down.

**Two records still to come.** Section 7.3 is where the results of the final fresh-clone verification of
the pushed repository are recorded, and section 7.4 is where the final commit hashes are recorded. Both
are filled by the last step of the work.

## Where things live

| what | where (relative to the repository root) |
|---|---|
| the Mathematica notebook (generated, never edited by hand) | `claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb` (545408 bytes; 384 cells, 217 of them Input cells) |
| its cell manifests; Part VI (Sections 23–25) is Effort 0, Part VII (Sections 26–29) Effort A, Part VIII (Sections 30–33) Effort B's symbolic side | `claude-fable/cells_part1.wl` … `cells_part8.wl`; `claude-fable/cells_part6.wl`, **`claude-fable/cells_part7.wl`**, **`claude-fable/cells_part8.wl`** |
| the builder, the run harness, the runner, the checker, the section map | `claude-fable/build_tools.py`, `claude-fable/runner_header.wl`, `claude-fable/run_from_nb.wls`, `claude-fable/verify_nb.wls`, `claude-fable/nb_section_map.wls` |
| the author's two helper packages, which must sit next to the notebook | `claude-fable/ConvertMapleToMathematicaV2.wl`, `claude-fable/EtoExp.wl` |
| **the final run log of the whole notebook, Parts I–VIII** (217 Input cells, 644/644 assertions, 0 cells with messages, 208.715 s, 46 non-vanishing witnesses; commit `1671155`) | **`claude-fable/run_fermion_fable_final.log`** |
| the earlier run logs: Parts I–VI (172 cells, 358/358); through Part VII (198 cells, 528/528); Parts I–VIII before the Rust CSVs existed (217 cells, 642/642) | `claude-fable/run_fable51_part6.log`; `claude-fable/run_fermion_fable_part7.log`; `claude-fable/run_fermion_fable_part8.log` |
| the checker's logs; the section map | `claude-fable/verify_nb_part6.log`, `verify_nb_part7.log`, `verify_nb_part8.log`; `claude-fable/nb_section_map.log` |
| the TeX/text export of the Part VII results | `claude-fable/export_fermion_fable_tex.wls` → `provenance-latex/generated/*.tex`, `*.txt` (14 files) |
| the solver of the classical fields of Effort 0 (Rust, pure-Rust SUNDIALS 7.8.0 CVODE) | `fable-cosmology/rust/fable_cosmo/` (7 unit tests) |
| the solver of the coupled (fermion fable, primordial gravitational field) system | `fable-cosmology/rust/fable_fermion/` (`src/constants.rs`, `numerics.rs`, `potentials.rs`, `kohn_sham.rs`, `models.rs`, `run.rs`, `cvode_driver.rs`, `main.rs`; `tests/cosmology.rs`; 34 tests) |
| the engine both solvers depend on by path (made by the setup, not committed) | `fable-cosmology/rust/vendor/rustSolveIt/sundials_rs/` (a sparse clone of the rustSolveIt repository for the platform) |
| the independent Python implementation of the coupled system; the development report | `fable-cosmology/fermion/crosscheck.py`; `fable-cosmology/fermion/report.py` (writes into the ignored `fable-cosmology/fermion/dev/`) |
| the Mathematica reference runs of the coupled system (Effort B) and of the classical fields (Effort 0) | `fable-cosmology/reference/make_reference_fermion.wls` → `mathematica_fable4d_mass30eV.csv`, `mathematica_fable4d_power.csv`; `fable-cosmology/reference/make_reference.wls` → `mathematica_scalar_exp.csv`, `mathematica_spinor_expdamp.csv` |
| the wall-state (`x0`) solver, its derivation, its input, its Mathematica check, its report | `fable-cosmology/fermion/waveguide.py`; `waveguide_derivation.wls` → `waveguide_derivation.log`, `waveguide_T16.json`; `waveguide_check.wls`; `waveguide_REPORT.txt` |
| the seven Jupyter notebooks (generated by `notebooks/_build/nbgen.py`, checked by `notebooks/_build/nbcheck.py`); 01–04 are Effort 0, 05–07 Effort B | `fable-cosmology/notebooks/01_fableScalar_quintessence.ipynb` … `04_dark_matter_dark_energy.ipynb`; `05_fermion_fable_quantum_eos.ipynb`, `06_fable_primordial_gravity_8d.ipynb`, `07_fable_dft_states.ipynb` |
| every CSV table and PNG figure the notebooks write | `fable-cosmology/results/nb01_*` … `nb04_*` (43 CSV, 16 PNG), `nb05_*` (11 CSV, 7 PNG), `nb06_*` (37 CSV, 8 PNG), `nb07_*` (18 CSV, 9 PNG) |
| setup and the complete reproduction | `fable-cosmology/setup.sh`, `setup.ps1`; `fable-cosmology/run_all.sh`, `run_all.ps1`; `fable-cosmology/requirements.txt` |
| the paper of Effort 0 | `fable-cosmology/latex/fable_cosmology.tex` → `.pdf` (24 pages), `fable-cosmology/latex/figures/` |
| the LaTeX twins of the three provenance pages of 2026-09-24, their preamble and build scripts | `provenance-latex/PROVENANCE-14-FERMION-FABLE-CANONICAL-QUANTIZATION.tex`, `…-15-FERMION-FABLE-AND-THE-PRIMORDIAL-GRAVITATIONAL-FIELD.tex`, `…-16-THE-COMPLETE-SOLUTION-AND-ITS-COMMANDS.tex` → `.pdf`; `provenance-latex/preamble.tex`; `provenance-latex/build_all.sh`, `build_all.ps1` |
| the delivered copy of the notebook, outside the repository | `C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb` (545408 bytes, byte-identical to the repository's; the two helper packages beside it) |

`<repo>` below is wherever the repository is cloned. Every shell block finds it with
`git rev-parse --show-toplevel`.

---

## 0. The task, in the author's words, and how the work was organized

### 0.1 The three instructions

On 2026-09-24 the author gave three instructions. They are quoted here in full as the author's
operative words, verbatim (the ellipses `[...]` are cuts in the quotation, not in the instruction's
meaning):

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

**This page is the third: the complete solution.** Instructions A and B each asked for their own
provenance files, and they were written (Effort A and Effort B); instruction C asked for this one,
which contains the complete solution. Following C's rule, every major effort has its own section here
(Effort 0: section 2; Effort A: section 3; Effort B: section 4; the design review: section 5; Effort C,
the commands: section 6; the verification and push: section 7), the content of Efforts A and B is
restated in full rather than referred to, and the complete set of ideas of all efforts is section 1.

**The author's choice.** Instruction A itself names the field: "a complex 16-spinor". Section 3.2
shows why that is forced by the author's own algebra: a real anticommuting 16-spinor with the
author's spinor metric has no dynamics, a Majorana 16-spinor is massless with no potential, and a
one-chirality (Weyl or Majorana–Weyl) spinor cannot propagate. When these alternatives were laid
out on 2026-09-24, the author confirmed the choice: **a complex 16-spinor**, with Dirac conjugate
`Psibar = Psi^ddag sigma16`. Every result below is for that field.

**The author's standing rules**, which bound all of the work: the notebook is generated from its cell
manifests and never edited by hand; the author's conventions (the metric signs, the `tau`/`T16`
construction, the 16-spinor split and the canonical frame) are never changed; the free function `a4`
of the canonical frame is never given a value; no number is invented; every claim is traced to a
file, a log or an assertion; no page sends the reader to another markdown file; nothing is
shortcut.

### 0.2 The efforts

| effort | what it is | where on this page | its main commits |
|---|---|---|---|
| **0** | the foundation: the work of 2026-09-16 on the classical fields `fableScalar` and `fable` (Part VI of the notebook, the solver `fable_cosmo`, notebooks 01–04, the paper), committed, pushed and completed first, with its gaps closed | 2 | `e34d454`, `028b379` (PR #1), `2f6d322`, and the `nbgen.py` corrections inside `aca5102` |
| **A** | the fermion fable: the complex 16-spinor, its Lagrangian and field equations in the primordial gravitational field, its canonical quantization in 4+4 dimensions, its energy–momentum tensor operator, density, pressure and equations of state, and the canonical spin connection (Part VII of the notebook) | 3 | `4fdfc40`, `b7ea18d`, `fee5603` |
| **B** | the interacting system: the Einstein equations of the primordial gravitational field with fable as source, the generalized frame and the 8-dimensional Bianchi-I system, the spin connection of the interacting system, the Kohn–Sham source, the density-functional ground and first excited states, the solution from before nucleosynthesis to today, the answers to [1] and [2] (Part VIII of the notebook, the solver `fable_fermion`, the wall-state solver, notebooks 05–07) | 4 | `8459c57`, `e130337`, `c5892bd`, `bc04ed1`, `18a2501`, `2bc936d`, `aca5102`, `1671155` |
| **review** | the adversarial review of the design before anything was implemented, and every correction found afterwards | 5 | (its corrections are in the commits above) |
| **C** | the commands: setting up the toolchain, building, running, testing, verifying, executing and displaying every calculation; the three provenance pages; the push and its verification | 6, 7 | `0a789e2`, `d0f2a99`, `fee5603`, and the final commits recorded in section 7 |

### 0.3 Who did the work, and how

The work was done by Claude (Claude Opus 5.5, in Claude Code) as one orchestrating session that
planned the work, wrote the design, ran the review, delegated self-contained pieces to subagents
running in parallel, checked every delivered piece itself, and made every commit. Every commit of the
work carries `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` [commit messages]. The agents
that appear in the records are these:

- **The orchestrator** (the main session): the design, the review loop, integration, the commits,
  the pushes. The wall-state report calls its instructions "the orchestrator's instructions of
  2026-09-24" [WG, header] and its §7 confirms or refutes "the orchestrator's" statements next
  to the reviewer's.
- **Four reviewer agents**, one per lens of the design review, each running its own Wolfram and
  Python probes against the notebook's own objects (section 5.1).
- **Four skeptic agents**, one per lens, each trying to refute every finding of its reviewer with an
  independent computation of its own (section 5.1).
- **Implementation agents**, each with one piece: the fermion-fable solver crate (the commit
  `e130337` calls it "the solver agent"); Part VII of the notebook; Part VIII of the notebook; the
  wall-state solver (its report records that "another agent works in `claude-fable/`" and that "the
  notebook was rebuilt by another agent during this session (172 -> 217 Input cells)" [WG 1, WG 8]);
  and the notebooks 05–07 with their generator and checker.
- **Independent re-runs.** Every notebook part and the solver were re-run by a second process before
  they were committed: "An independent re-run gave the same result" (Part VII, `4fdfc40`), "An
  independent re-run confirmed it" (Part VIII, `bc04ed1`), "21 + 8 tests pass (re-run independently)"
  (the solver, `c5892bd`), "validation 64/64 PASS, re-run independently" (the wall-state solver,
  `18a2501`) [commit messages].
- **The documentation workflow**: the three provenance pages, each written from the logs, manifests
  and git history, then fact-checked adversarially against them ("An adversarial fact-check against
  the logs, manifests and git history corrected 7 errors in both files", `fee5603`). This page was
  assembled by a script that copies the sections of Efforts A and B programmatically from the pages
  of those efforts (so that nothing is retyped), renumbers their sections and cross-references, and
  adds the parts that are new here.

Two process incidents are recorded because they bear on what could have been lost: two agents of the
design review (the reviewer of the Einstein lens and the skeptic of the DFT lens), while stopping their
own stalled runs, each ran `taskkill /F /IM python.exe`, which terminated every Python process on the
machine at that moment (three processes the first time, one the second), and each reported it so that
anything that had died could be re-run (the design review's records). No committed result depends on a process that was
killed: every committed number was produced or re-produced by a later run whose log or executed
notebook is committed.

### 0.4 The order in which it was done

All times are PDT (UTC−7), from `git log --date=iso` and, for the pull request, from GitHub.

| time | step | record |
|---|---|---|
| 2026-09-24 18:52:36 | Effort 0 committed as it stood when the session of 2026-09-16 ended, with its known gaps listed | `e34d454` |
| about 19:04 | the design of Efforts A and B (revision 1) written, with six facts F1–F6 already computed by probes and eight questions Q1–Q8 for the reviewers | the design's working file |
| 19:24:32 | the reference generator's underflow messages silenced; the branch `fermion-fable-and-primordial-gravity` pushed with it | `028b379` |
| 19:24:50 → 19:32:10 | pull request #1, "Fermion fable and the primordial gravitational field (branch opened with a reference-generator fix)", opened and merged into `main` (a fast-forward: its merge commit is `028b379` itself) | GitHub, PR #1 |
| 19:32 – 20:51 | the design review: the reports of the quantization and Einstein lenses (by 19:32), of the field-equation and DFT lenses (by 20:03); the skeptics' verdicts (20:03–20:04, the DFT skeptic's by 20:51) | the review's working files |
| 19:57:29 | the gaps of Effort 0 closed | `2f6d322` |
| 20:02:04, 20:14:25 | the author asked for everything to be pushed at once: two work-in-progress snapshots of the solver crate | `8459c57`, `e130337` |
| 20:17:18, 20:18:53 | the LaTeX build tree of the three new provenance pages | `0a789e2`, `d0f2a99` |
| 20:38:49 | the finished solver `fable_fermion`, with its scipy cross-check | `c5892bd` |
| 20:47:28 | Part VII of the notebook (Effort A), 528/528 | `4fdfc40` |
| 20:48:42 | a wording correction in an earlier provenance page, found by the fact-check of the spin-connection section | `b7ea18d` |
| 21:24:04 | Part VIII of the notebook (Effort B's symbolic side), 642/642 | `bc04ed1` |
| 22:13:42 | the wall-state solver (the density-functional states along `x0`) | `18a2501` |
| 22:31:20 | the page of Effort A (draft) with its LaTeX twin and PDF (110 pages) | `fee5603` |
| about 22:31 | the design addendum (revision 2, the adopted corrections) in its final form | the addendum's working file |
| 22:53 | notebooks 05 and 06 first executed; they exposed six solver defects | the page of Effort B, as written |
| 23:12:51 | the six solver defects fixed, 34/34 tests | `2bc936d` |
| 23:26 | the page of Effort B written (not yet committed) | its section on the push |
| 23:49 – 23:52 | notebooks 01–06 executed on the final solver (the cell timestamps of the committed notebooks start at 06:49:12 UTC) | the committed notebooks |
| 2026-09-25 00:06:38 | the wall-problem derivation re-run, writing the committed `waveguide_T16.json` (94/94) | `fable-cosmology/fermion/waveguide_derivation.log` |
| 00:11 – 00:21 | notebook 07 executed (its cells start at 07:11:24 UTC and end 557.6 s later) | the committed notebook 07 |
| 00:23:46 | notebooks 05–07, their 90 result files and the integration (nbcheck 7/7, `run_all.sh` passing) | `aca5102` |
| 00:28:54 | the final full run of the notebook: 217 Input cells, 644/644, 0 messages, 208.715 s | `1671155` |
| then | this page; the final push and the fresh-clone verification | section 7 |

### 0.5 The review loop

The work followed one loop, repeated at every level:

1. **Design before code.** The design (revision 1) stated the physics of Efforts A and B, the facts
   already computed, the implementation plan (Part VII and Part VIII of the notebook; the Rust
   solver; the Python cross-checks; the wall-state problem; notebooks 05–07; the three provenance
   pages; the verification) and eight questions the reviewers had to try to break.
2. **Adversarial review.** Four reviewers, one per lens, each followed by an independent skeptic
   (section 5). No finding was refuted as a whole; many were confirmed only in part, and then the
   skeptic's corrected fix was adopted. The adopted corrections were written into an addendum
   (revision 2) that overrides the design wherever they differ.
3. **Implementation with assertions.** Every symbolic claim became an assertion of the notebook
   (Parts VII and VIII), every numerical claim a unit test of the solver, a check of the wall-state
   solver or an assertion of a notebook cell.
4. **Independent re-runs and cross-implementations.** Parts VII and VIII of the notebook, the solver
   and the wall-state solver were re-run by a second process before they were committed;
   every cosmological run was recomputed by an independent Python implementation, and two by
   Mathematica as well (section 4.7.12); the wall levels were recomputed in Mathematica
   (section 4.6.4).
5. **Defects found by the checks were fixed and recorded**, never hidden (section 5.8).
6. **Pages from the records.** Every provenance page was written from the logs, the manifests and
   the git history, and then fact-checked adversarially against them.
7. **Push and verify.** Every commit reached `main` on GitHub (`028b379` through pull request #1, all the others directly); the final state is verified from a fresh
   clone (section 7).

The design and the review records are working documents in the session's scratch folder. They are
not part of the repository. Everything in them that survived review is restated on this page:
the findings and verdicts in section 5, the physics in sections 3 and 4.

## 1. The complete set of ideas

{{COMPLETE-SET-OF-IDEAS}}

## 2. Effort 0: the foundation of 2026-09-16, pushed and completed

Efforts A and B stand on the work of 2026-09-16: Part VI of the notebook, which put two classical
fields on the pre-universe (`fableScalar`, a real scalar, and `fable`, a real commuting 16-component
spinor), and the `fable-cosmology/` folder, which solved them numerically. When the session of
2026-09-24 began, that work was finished but not committed. Effort 0 committed it as it stood, pushed
it, closed every gap it had, and verified it from a clean clone. Its physics is restated in section
3.1.12 (the classical fable of Part VI and its reference cosmology) and section 3.1.13 (why it has to
be refined); this section records what was committed, what each commit closed, and the numbers that
verify it.

### 2.1 `e34d454` (18:52:36): the 2026-09-16 work, as it stood

The commit "Add the 2026-09-16 fable-cosmology work: Part VI, the solver, four notebooks" (by `git show --stat`: 107 files,
47374 insertions) contains [commit e34d454]:

- `claude-fable/cells_part6.wl`: Part VI of the notebook (Sections 23–25). The rebuilt notebook runs
  **172 Input cells, 358/358 assertions, 0 messages** (`claude-fable/run_fable51_part6.log`,
  `claude-fable/verify_nb_part6.log`).
- `fable-cosmology/`: the design of the numerical work (revision 2); the Rust solver `fable_cosmo`
  (`src/main.rs`, `models.rs`, `potentials.rs`, `cvode_driver.rs`, with the FMA pin in
  `.cargo/config.toml`) on the pure-Rust SUNDIALS 7.8.0 CVODE engine of the rustSolveIt repositories;
  four executed Jupyter notebooks (`01_fableScalar_quintessence`, `02_fable_spinor`,
  `03_pre-universe_dynamics`, `04_dark_matter_dark_energy`) with their generator `nbgen.py`, their
  checker `nbcheck.py` and their conventions; the results they write (43 CSV files and 16 PNG
  figures); the Mathematica reference integrations (`reference/make_reference.wls` →
  `mathematica_scalar_exp.csv`, `mathematica_spinor_expdamp.csv`); `setup.sh`, `setup.ps1`,
  `run_all.sh`, `run_all.ps1`, `requirements.txt`; and the 16 figures for the paper.
- `.gitignore` (the engine clone, the virtual environment, cargo's `target/` and the LaTeX build
  logs are ignored); the repository's front page (a Part VI row, the fable-cosmology section).

The commit message lists its known gaps "so nobody mistakes this for finished": three sections of
the provenance page of the fable-cosmology work were placeholders; the student instructions of
`fable-cosmology/` and the paper `latex/fable_cosmology.tex`, which the front page linked to, had
never been written; and the fresh-clone verification had not been run.

### 2.2 `028b379` (19:24:32) and pull request #1: the reference generator runs clean

`fable-cosmology/reference/make_reference.wls` writes the Mathematica `NDSolve` references of Model A
(`fableScalar`, `exp` potential) and Model B (the classical spinor fable, `expdamp`). Model B's `H`
column is evaluated at exact `N`, and its term `Exp[-s/s1]` (`s ≈ 1.3e9` at `N = −7`) underflows when
`N[]` takes it to machine precision. The value written is unaffected, but a run printed three
`General::munfl` messages and a `General::stop`. The formatter became
`fmt[x_] := Quiet[N[x], General::munfl];`, so a clean run prints no messages; nothing else changed
[commit 028b379]. The first run of the script on 2026-09-24 had taken 427 s and printed, verbatim
apart from the messages it no longer prints,

```
mathematica_scalar_exp.csv: 701 rows;  w(a=1) = -0.843363803931198
mathematica_spinor_expdamp.csv: 701 rows;  w(a=1) = -0.8608456403776481  min w = -1.3020988149091868
```

and a probe showed that `N[HB[-7]]` is `22740.499428716343` with or without the message. Re-run after
the fix (366 s), it printed exactly these two lines and nothing else, and both CSVs were
byte-identical to the committed ones.

The commit was pushed on a new branch, `fermion-fable-and-primordial-gravity`, and opened as **pull
request #1** of `once-ere/Pre-Universe_with_Claude`, "Fermion fable and the primordial gravitational
field (branch opened with a reference-generator fix)", at 19:24:50. Its description stated what the
branch was for (the six tasks of Efforts A and B) and the findings already established that would
shape the work: `sigma16 T16[a]` is antisymmetric for every `a`, so a real Grassmann fable with
`sigma16` has a zero mass term and a total-derivative kinetic term; the canonical anticommutator
`{Psi, Psi^dagger} ∝ −i sigma16 gamma^4` has signature (8,8), and the Krein fundamental symmetry
`J = −i T0 T1 T2 T3 T4` gives a positive Fock space in the sector where the fields do not depend on
`x5..x7`; the canonical pre-universe metric is not a vacuum solution of Einstein's equations; in a
generalized version of the canonical frame the off-diagonal (0,4) Einstein equation "forces the author's
volume-preserving `a4` structure". (The review later corrected the last point: the (0,4) equation
*singles out* that structure within a family and under stated conditions; it does not *derive* it,
section 4.3.2.) The pull request was merged into `main` at 19:32:10; the merge was a fast-forward,
so its merge commit is `028b379` itself. (`e34d454` had gone straight to `main` before the branch was
opened, as the pull request's description records.) After that the author asked for everything to go to `main`
at once, and every later commit of the work was pushed directly to `main`.

### 2.3 `2f6d322` (19:57:29): the gaps of 2026-09-16 closed

The commit that closes the gaps of 2026-09-16 (by `git show --stat`: 9 files, 3032 insertions) contains [commit 2f6d322]:

- **The student instructions** of the numerical cosmology (new, in `fable-cosmology/`): the
  prerequisites per platform, the setup, the solver's command-line contract read from `main.rs`, the
  CSV columns, the notebooks, the tests, the paper and troubleshooting. Their content, extended on
  2026-09-25 to the fermion solver and notebooks 05–07, is restated in section 6 of this page.
- **The paper** `fable-cosmology/latex/fable_cosmology.tex` and `.pdf` (new): 24 pages, 16 figures, 20
  references. `latexmk` builds it from scratch with no warnings, no undefined references and no over-
  or underfull boxes (`Output written on fable_cosmology.pdf (24 pages, 2835044 bytes)`).
- **The provenance page of the fable-cosmology work**: its three placeholder sections written out in
  full, every pointer to another markdown file removed, and its verification recorded.
- **Seven corrections to the fable-cosmology design**, each marked `[corr 2026-09-24]` there: `G0` is
  `C^2 Sin[6Hx0]^2/2`, not `C^2/2` (as Part VI asserts); the reference `expdamp` minimum is `−1.302`
  at `a = 0.543` (`z = 0.84`), not "`≈ −1.27` near `z ≈ 1`"; the Cai & Wang citation is Class. Quantum
  Grav. 25 (2008) 165014 (arXiv:0806.3890, doi 10.1088/0264-9381/25/16/165014), not "JCAP 2008"; the
  CSVs carry 16 significant digits (`{:.15e}`), not 15; an unknown model or potential name exits with
  code 1, not 2; the reference CSVs are written by `make_reference.wls` and checked, not written, by
  Part VI; and table pipes inside code spans are escaped.
- The same citation corrected in a Text cell of `claude-fable/cells_part6.wl` (text only; no Input
  cell changed); `setup.sh` now creates the virtual environment with `python3` when that runs and
  with `python` otherwise (many macOS and Linux systems have no `python`); `run_all.ps1` now stops
  when `cargo test` fails (PowerShell's `$ErrorActionPreference = "Stop"` does not apply to native
  commands, so the script checks `$LASTEXITCODE` and throws). `.gitignore`: comments only.

**The verification recorded with it** (run on 2026-09-24 in Git Bash on Windows 11, in the working
repository at `028b379`, with the engine `rustSolveIt_Win11_SUNDIALS_7_8_0 @ a8fdff4`):

| check | result |
|---|---|
| `cargo test --release` in `rust/fable_cosmo` | `test result: ok. 7 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s`; `fable_cosmo 0.1.0, sundials_rs 7.8.0 (pure Rust), CVODE BDF` |
| `bash fable-cosmology/run_all.sh` | exit code 0 after 51 s; `4/4 notebooks pass all eight requirements`; `== all done` |
| `nbcheck.py` on the committed notebooks | `4/4 notebooks pass all eight requirements`, exit code 0 |
| reproducibility | `git diff --stat -- fable-cosmology/results` printed nothing: **all 43 CSV files and 16 PNG figures byte-identical** to the committed ones; a column-by-column comparison of every CSV against `HEAD` printed `43 CSV files compared column by column against HEAD; files with any nonzero difference or row-count change: 0`; the four re-executed notebooks differed from the committed ones only in the cells' execution timestamps and in how the kernel split printed output into stream chunks (sources, execution counts, stream text, results, images and errors identical) |
| the paper, from scratch | `latexmk exit 0`, three pdflatex passes, no errors, warnings, undefined references, overfull or underfull boxes; `Output written on fable_cosmology.pdf (24 pages, 2835044 bytes)`; MiKTeX 26.5, pdfTeX 4.27, latexmk 4.88 |
| **a fresh local clone** of `028b379` (with the session's three new files copied in, not the PDF) | `bash fable-cosmology/setup.sh`: exit code 0, 80 s (a new virtual environment, a new engine clone from GitHub, `Finished release profile ... in 5.04s`); `bash fable-cosmology/run_all.sh`: exit code 0, 61 s; `git diff --stat -- fable-cosmology/results` empty; the paper built from source to 24 pages |
| Part VI, re-run | `wolframscript -file run_from_nb.wls`: `cells evaluated : 172`, `total seconds   : 152.388`, `cells w/ msgs   : 0`, `Assertions run: 358   passed: 358   failed: 0`, 27 non-vanishing witnesses; with the timings masked, identical line for line to the committed `run_fable51_part6.log` |
| the classical results table, re-checked against the committed files | every row confirmed (the table is below) |

Still open after this commit, and recorded as such: four wording items in the notebook generator
`nbgen.py`, which that session had been told not to touch (section 2.5 closes them).

### 2.4 `8459c57` (20:02:04) and `e130337` (20:14:25): the solver crate, pushed while it was being built

"The author asked for everything to be on main now." So the fermion-fable solver crate
`fable-cosmology/rust/fable_fermion` was committed twice at intermediate stages, each commit saying
plainly that it was **not finished, tested, reviewed or verified** and would be changed [commits
8459c57, e130337]. The first snapshot held `constants.rs` (`rho_c0`, `Omega_r0`, `Omega_b0` from
physical constants), `kohn_sham.rs` (the `T = 0` Fermi-sea integrals for `g = 8` states per momentum,
the mean-field potentials `W(sigma)` and the gap equation), `models.rs`/`run.rs` (`fable4d` with the
hidden sheet stabilized, and `fable8d`, the 8-dimensional Bianchi-I no-go demonstration) and
`cvode_driver.rs` (the path dependency on the engine, as `fable_cosmo` has it); `.gitignore` section 5
ignores the crate's `target/` and the scratch folder `fable-cosmology/fermion/dev/`. The second
recorded the solver agent's edits to `kohn_sham.rs`, `models.rs`, `potentials.rs` and `run.rs` as they
stood, "in the middle of adopting the design review's corrections": the per-7-volume normalization,
numerically stable Fermi integrals, the stabilized `fable4d` as the physical model, `fable8d` as the
no-go demonstration, and the observer-inferred and interacting `w` definitions. The finished crate is
`c5892bd` (section 4.7 and section 6.4).

### 2.5 The last open items of Effort 0, closed in `aca5102`

The four `nbgen.py` items were fixed on 2026-09-24 with the notebooks of the fermion-fable work, and
committed in `aca5102` [commit aca5102]. The generator now says:

- notebook 03, §3: `G0 = C^2 Sin[6Hx0]^2/2` (as Part VI asserts), independent of `x4` and so
  constant for the observer at fixed `x0`;
- notebooks 01 (§5.8) and 02 (§5.10): the reference CSV "was written by
  `fable-cosmology/reference/make_reference.wls` (a wolframscript) and is checked by Part VI of the
  Mathematica notebook, which reads it back";
- notebook 01, §5: every number is written as `{:.15e}`, "15 decimals, i.e. 16 significant
  digits";
- notebooks 01, 02 and 03, §5: exit code 1 is a solver or physics error "and also an unknown
  model or potential name"; exit code 2 is "a malformed command line (an unknown option, or a missing
  or non-numeric value)". This was checked against the binary first: `fable_cosmo nosuchmodel` and
  `fable_cosmo spinor-flrw --potential nosuch` exit 1, `fable_cosmo spinor-flrw --bogus` and
  `fable_cosmo spinor-flrw --points x` exit 2.

The four notebooks were regenerated (`nbgen.py 01 02 03 04`) and re-executed in place (7 s, 7 s, 53 s
and 6 s). None of the stale phrases occurs in them any more; `nbcheck.py` reported `4/4 notebooks pass
all eight requirements`; and **all 59 result files of notebooks 01–04 were byte-identical** to the
committed ones (`git diff --stat -- fable-cosmology/results` empty; the SHA-256 of each equal to that
of its `HEAD` blob: `checked 59 files, 0 differ`). The corrections are to markdown text only; no code
cell and no result changed. `aca5102` records this: "Their 59 result files are byte-identical to
before."

### 2.6 The numbers of Effort 0

Every one of these is asserted by a notebook, so a re-run that changed any of them would fail
[file: the committed notebooks 01–04 and their results; re-checked on 2026-09-24 against the committed
CSVs]:

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

(Models A and A′ are `fableScalar` in the standard 4-dimensional reference cosmology and on the Unite
CPL background; Model B is the classical spinor fable in the reference cosmology; Models C and D put
`fableScalar` on the 8-dimensional pre-universe itself. The re-check of 2026-09-24 also printed, from
the committed CSVs: `const: max|w+1| = 0.000e+00 Omega_phi(1) = 0.6999160000`, `mass: max|w| = 0.000e+00
q_dec(1) = 0.5000420000` (the `0.5` of pure dust, plus the radiation term), `Model A exp1 vs NDSolve:
max|dw| = 1.149e-10 max|dt| = 5.428e-10`, `Model B expdamp vs NDSolve: max|dw| = 1.861e-08 max|dt| =
5.224e-09`, and the scipy rows `9.509e−11` (`exp λ = 1`) and `2.201e−8` / `1.006e−9` (`lorentz`).)

**Why Effort 0 matters for the rest.** The classical fable of Part VI has `w = s V'/V − 1`, which
crosses `w = −1` for `expdamp` and `lorentz` (the "phantom crossing" of the table above: `min w =
−1.30210`). Effort A refines that field into a fermion, and Effort B shows that the quantized fable
**cannot** cross `w = −1` (`rho + P_obs = wF n >= 0`, section 4.5.9); what survives of the crossing is an
*apparent* phantom in the dark energy an observer infers (section 4.8.1).

## 3. Effort A: fermion fable, the complex 16-spinor, canonically quantized in 4+4 dimensions, in the primordial gravitational field

This section is the complete content of Effort A. It is copied section by section, by a script, from
the provenance record of Effort A (written on 2026-09-24 and fact-checked against the logs), with its
sections renumbered 3.1–3.9 and its cross-references renumbered to match this page; nothing in it was
retyped, and nothing was left out. Its subsections:

| here | content |
|---|---|
| 3.1 | the foundations: the pre-universe, its algebra, the canonical frame, the author's `La` and `eLa`, and the classical fable of Part VI (Effort 0's physics); these serve all of Efforts A and B |
| 3.2 | the refinement: why fable must be a complex 16-spinor |
| 3.3 | the Lagrangian and its Hermiticity |
| 3.4 | the field equations in the primordial gravitational field, written out: matrix, adjoint, 8+8 split-octonion, all sixteen component equations and their adjoints, the rescaled form, the `x4`-only family, the operator form, the currents |
| 3.5 | canonical quantization in 4+4 dimensions: the Dirac bracket, the anticommutator, `J`, the admissibility theorem, the Krein/`J` Fock space, the Dirac sea, the wall condition |
| 3.6 | the energy–momentum tensor operator |
| 3.7 | density, pressure and equations of state |
| 3.8 | the canonical spin connection: a complete discussion |
| 3.9 | how Effort A was verified: Part VII of the notebook, every assertion verbatim, the full runs, the design review's corrections to Effort A, the Fock check, the TeX export |

The commands that build, run, check and export Part VII are in section 6.3; the design review is
section 5.

---

### 3.1 Foundations: the pre-universe, its algebra, the canonical frame, the author's `La` and `eLa`, and the classical fable of Part VI

This section sets out everything that the new work on fermion fable stands on. It restates the
author's pre-universe (a curved 4+4-dimensional spacetime), the real Clifford algebra and
split-octonion spinors built on it, the author's own wave function, Lagrangian and field
equations, the canonical frame field, and the classical field fable of 2026-09-16. It ends with
the reason why that classical field has to be refined into a complex 16-component spinor. The
reader needs nothing outside this document to follow it.

#### 3.1.1 How the evidence is cited

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

Each statement below is tagged with one of five kinds of evidence:

- **[A]** an assertion. Its label is quoted exactly as the log prints it after `PASS`.
- **[D]** a displayed result: an Output the notebook prints but does not assert. Where a
  displayed result was re-read for the provenance pages of 2026-09-24 from the saved kernel state, that is said.
- **[P]** prose only: a statement that appears in a `Text` cell and is not checked by any
  assertion.
- **[VII]** proved in Part VII, the new part of the notebook written for fermion fable (Sections
  26–29). Its labels are quoted verbatim from `claude-fable/run_fermion_fable_part7.log`, which
  reports `Assertions run: 528   passed: 528   failed: 0` for Parts I–VII together.
- **[VIII]** proved in Part VIII, the notebook's coupled system (Sections 30–33). Its labels are
  quoted verbatim from `claude-fable/run_fermion_fable_part8.log`, which reports
  `Assertions run: 642   passed: 642   failed: 0` for Parts I–VIII together (sections 4.2–4.5 of this document);
  the final run `claude-fable/run_fermion_fable_final.log` prints the same labels and two more,
  `Assertions run: 644   passed: 644   failed: 0`.

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

#### 3.1.2 Coordinates, the flat 4+4 metric, and which directions are timelike

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

#### 3.1.3 SO(4): the self-dual and anti-self-dual blocks

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

#### 3.1.4 The real 8×8 Clifford generators `tau`, `taubar`, and the spinor metric `sigma`

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

#### 3.1.5 The 16×16 Dirac matrices, chirality, `sigma16`, and `so(4,4)`

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

#### 3.1.6 Cartan triality and the split octonions (Section 9): what is proved

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

#### 3.1.7 The wave function of the un-universe and the author's Lagrangian `La` (Section 11)

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

#### 3.1.8 The Euler–Lagrange equations `eLa` (Section 12)

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

These were printed for the provenance pages of 2026-09-24 by loading the notebook's own `DumpSave` file
`claude-fable/claude-fable_Einstein-Rosen-2-Planes-eLa.mx`. That file is `SameQ` to the author's
original `Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLa.mx` in the
repository root; this was re-checked for the provenance pages of 2026-09-24 with `SameQ`, which returned `True`. So
they are the author's equations, unchanged. In matrix form they read

```
eLa = (2/H) sigma16 . ( T16[0] d_x0 + T16[4] d_x4 + 2M ) Psi16,        i.e.   ( T16[0] d_x0 + T16[4] d_x4 ) Psi16 = -2M Psi16
```

This matrix form was checked for the provenance pages of 2026-09-24 (a `Simplify` difference of exactly 0); it is not
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

#### 3.1.9 The `(z,t)` chart, four blocks of four, and the closed-form solutions (Section 13)

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

#### 3.1.10 Bilinears, the solution branches, and M6 = 3 generations of Einstein–Rosen 2-planes (Section 14)

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

The displayed values on that branch [D, re-read for the provenance pages of 2026-09-24 from the saved kernel state]
are sharper than the assertion. There, `psi.sigma16.psi`, `psi1.sigma.psi1` and
`psi2.sigma.psi2` are all identically `0`, while `psi2.sigma.psi1` is not.

**The two mass branches** [D] are, both taken on the branch `C2 -> -C1, C4 -> -C3`:

- `Psi16ab`: `M -> H Mab Sqrt[C1 C3]`, which keeps a free dimensionless ratio `Mab`;
- `Psi16aa`: `M -> H Sqrt[C1 C3]`, the case `Mab = 1`.

In the `(x0,x4)` chart the advanced and retarded coordinates are `xiadv = x0 − x4` and
`xiret = x0 + x4` (the notebook's `ξadv`, `ξret`). Every component of `Psi16aa` is a constant
times one of `exp(±H(C1 xiret + C3 xiadv))` or `exp(±H(C3 xiret + C1 xiadv))` [D, re-read for the provenance pages of 2026-09-24 from the saved kernel state; the
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

#### 3.1.11 The canonical frame field (Section 15), restated

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
`coframe = Inverse[frame]`. On the canonical frame they are as follows (read for the provenance pages of 2026-09-24
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

#### 3.1.12 The classical field fable of 2026-09-16 (Part VI, Section 24)

Part VI (Sections 23–25) places two matter fields on the pre-universe. It asks of each the
cosmologist's question: what are the energy density `rho`, the pressure `P`, and `w = P/rho`?
The first field, `fableScalar`, is a real scalar with potential `V(phi)`. The second, **fable**,
is the subject of this document.

**fableScalar**, in brief. It has `Lhat_phi = −(1/2) g^{mu nu} d_mu phi d_nu phi − V(phi)` and the
Hilbert tensor `T_{mu nu} = d_mu phi d_nu phi + g_{mu nu} Lhat_phi`. Its central theorem is [A]
`FABLESCALAR [THE RESULT]: the null energy condition rho + P_1 == 2 KE holds IDENTICALLY, for every phi(x0, x4, x5) and every V`,
so it cannot cross `w = −1` with positive energy density.

##### 3.1.12.1 The field and its Lagrangian

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

##### 3.1.12.2 The field equation

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

##### 3.1.12.3 The energy–momentum tensor

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

##### 3.1.12.4 `rho`, `P`, and `w` on shell

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

##### 3.1.12.5 No dilution on the pre-universe

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

##### 3.1.12.6 Dust for the author's mass term

[A]:

- `FABLE [THE RESULT]: the author's mass term V = -(2M/H) s is DUST: on shell P_1 == 0 identically and rho == -(2M/H) s  (w == 0, exactly)`
- `FABLE [has content]: that density is not zero -- witnessed on Psi' = e1 + e5 at M = 1 (rho = (2M/H) * 2 Sin[6 H x0] there)`

The density `rho = −(2M/H) s` is positive only on the branch `M s < 0` [P, Section 24].

##### 3.1.12.7 `w = s V'/V − 1` for the six potentials, and the classical phantom crossing

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

##### 3.1.12.8 The FLRW reference model (Model B)

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

##### 3.1.12.9 What is proved on the pre-universe, and what belongs to the reference model

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

#### 3.1.13 Why the classical fable must be refined

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
  algebra; the Hilbert-space adjoint is fixed in the quantization, section 3.5.
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
phantom crossing, survive quantization is decided in sections 3.6 and 3.7. The complete
refinement, with every assertion of Section 26, is section 3.2.

### 3.2 The refinement: why fable must be a complex 16-spinor

This is Section 26 of the notebook (manifest `claude-fable/cells_part7.wl`, Input cells 173–179,
38 assertions). It turns the classical, real, commuting fable of section 3.1.12 into a fermion.

**Two conjugations, two symbols.** `Psi^ddag` is the **classical** conjugate of the field, the
conjugation of the Grassmann algebra, the one that appears in the Lagrangian; the Dirac conjugate
is `Psibar = Psi^ddag sigma16`. After quantization (section 3.5) the Hilbert-space adjoint is a
**different** operation, `Psi^dagger = Psi^ddag J`. The two are never written with the same symbol
[prose VII, introduction of Part VII].

**Two kinds of algebra, and when each is used** [prose VII]. Statements whose content *is* the
anticommutation of the field (that a mass term or a kinetic term vanishes, is Hermitian, or is a
total derivative) are proved in a genuine Grassmann (exterior) algebra, built and tested in
Section 26 (subsection 3.2.3). Statements about **bilinear** expressions (Lagrangians,
Euler–Lagrange equations, currents, energy–momentum tensors, conservation laws) are proved with
`Psi` and `Psibar` represented by two **independent** vectors of ordinary functions of the
coordinates, with `Psibar` always written to the **left** of `Psi`. That commuting proxy is exact
for such identities: in every term `Psibar` is the leftmost and `Psi` the rightmost odd factor, so
the left derivative with respect to `Psibar` and the right derivative with respect to `Psi` are the
ordinary derivatives, and no reordering of odd factors ever occurs. Where reality matters
(Hermiticity under `^ddag`), `Psi = u + i v` with real `u, v` and `Psibar = (u − i v)^T sigma16`.

#### 3.2.1 The Clifford symmetry table

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

#### 3.2.2 The Lorentz-invariant bilinears: exactly two, both symmetric

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

#### 3.2.3 A Grassmann algebra, built and tested

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

#### 3.2.4 The real options, and why each fails

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
`sigma16 T16[a]` gives a genuine kinetic term (the control of subsection 3.2.3). That is why Part VI's
classical theory is consistent, and why it cannot be quantized as a fermion: a commuting spinor
violates the spin–statistics connection [prose VII §26].

#### 3.2.5 The complex 16-spinor

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
  and invertible (it is the symplectic matrix of section 3.5.3).
- The symmetrized kinetic term `(1/2)(Psi^ddag K phi − phi^ddag K Psi)` is **Hermitian**, and it
  differs from `Psi^ddag K phi` by the total derivative `−(1/2) d(Psi^ddag K Psi)`; the unsymmetrized
  one is **not** Hermitian.

Invariance of `s` and `p` under Spin(4,4) is the statement `S^T N + N S = 0` of subsection 3.2.2 (the
Lorentz generators are real). The self-interaction is taken to depend on `s` only; section 3.5.7
shows why `p` cannot enter. **[proved VII §26]**

- `REFINEMENT (d) [definition]: Psi^ddag == (theta1 - i theta2)^T/Sqrt[2] in the algebra`
- `REFINEMENT (d) [THE RESULT]: s = Psibar Psi == i theta1^T sigma16 theta2: NON-ZERO (16 monomials) and HERMITIAN; p = Psibar T16[8] Psi is non-zero and Hermitian too`
- `REFINEMENT (d) [has content]: s is a sum of 16 commuting nilpotent even elements x_a (x_a x_b == x_b x_a, x_a^2 == 0), so s^17 == 0 and V(s) is a finite polynomial`
- `REFINEMENT (d) [definition]: the 32x32 matrix A read off the algebra reproduces Psi^ddag K phi exactly`
- `REFINEMENT (d) [THE RESULT]: its symmetric part is A_S == (i/2) Omega, Omega = [[0, K], [-K, 0]] real SYMMETRIC and invertible: a genuine kinetic term`
- `REFINEMENT (d) [has content]: the symmetrized kinetic term is HERMITIAN and equals Psi^ddag K phi - (1/2) d(Psi^ddag K Psi); the unsymmetrized one is not Hermitian`
- `REFINEMENT (d) [has content]: the same holds in every direction a = 0..7: the symmetrized Psi^ddag sigma16 T16[a] phi is Hermitian, with symmetric part (i/2)[[0, sigma16 T16[a]], [-sigma16 T16[a], 0]] != 0`

#### 3.2.6 Four four-dimensional Dirac fermions

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
`4 × 2 = 8` particle states (and 8 antiparticle states): the degeneracy `g = 8` of sections 3.5
and 3.7. **[proved VII §26]**

- `4D [THE RESULT]: the 16 ordered products of T16[1..4] are linearly independent (the observer's algebra is M4(C)), and its commutant in M16(C) is 16-dimensional`
- `4D [has content]: Omega4^2 == -ID16, the hidden gammas h_A = Omega4 T16[A] (A = 0,5,6,7) commute with T16[1..4] and obey {h_A, h_B} == -2 eta_AB`
- `4D [THE RESULT]: the 16 products of the hidden gammas span the commutant, and the two algebras meet only in the multiples of ID16 (rank of the union 16 + 16 - 1 = 31): C^16 = C^4 (x) C^4, four 4D Dirac fermions`
- `4D [has content]: the observer's Lorentz generators T16[i] T16[j] (i < j in 1..4) commute with every hidden gamma`

#### 3.2.7 The refined Lagrangian, and the fidelity chain to Part VI, `La` and `eLa`

The Lagrangian of fermion fable is the **symmetrized covariant** one (section 3.3 shows why no other
form is admissible for a complex field):

```
L  =  Sqrt[det g] Lhat,      Lhat  =  (1/(2H)) [ Psibar gamma^mu D_mu Psi - (D_mu Psibar) gamma^mu Psi ]  -  V(s),      s = Psibar Psi
D_mu Psi = d_mu Psi + Gamma^spin_mu Psi,       D_mu Psibar = d_mu Psibar - Psibar Gamma^spin_mu
```

and its energy–momentum tensor (section 3.6) is

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
   Section 11 (section 3.1.7);
3. the Euler–Lagrange expressions of the complex field, combined as
   `sigma16 . EL_Psibar + EL_Psi` (the chain rule for `Psibar = psi^T sigma16`), become Part VI's
   explicit variation `cfELFable`, and on the flat frame the author's sixteen equations `eLa` of
   Section 12 (section 3.1.8);
4. `That` becomes Part VI's covariant tensor `cfTCov` (section 3.1.12.3), all 64 components.

**[proved VII §26]**

- `FIDELITY [1] [fidelity]: Psi -> psi, Psibar -> psi^T sigma16 turns the symmetrized covariant Lhat into Part VI's cfLhatFable EXACTLY (canonical frame, generic V)`
- `FIDELITY [2] [fidelity]: on the flat frame with V = -(2M/H) s and no volume factor, the same limit on Psi16 IS the author's La[] of Section 11`
- `FIDELITY [3] [fidelity]: sigma16 . EL_Psibar + EL_Psi in the real limit == Part VI's explicit variation cfELFable, component for component`
- `FIDELITY [3] [fidelity]: and on the flat frame with V = -(2M/H) s the same combination IS the author's eLa of Section 12`
- `FIDELITY [4] [fidelity]: the energy-momentum tensor That in the real limit IS Part VI's covariant tensor cfTCov, all 64 components`

Every new result of this effort therefore contains Part VI, and through it the author's `La` and
`eLa`, as its real commuting limit.

#### 3.2.8 The conclusion, with its scope

The complex 16-spinor is the **minimal** field that

1. uses the author's `sigma16` conjugation,
2. propagates,
3. admits a potential `V(s)` with `s = Psibar Psi`, and
4. reduces to Part VI's classical fable as its real commuting shadow.

It is **not** the unique field with dynamics: the `C+` Majorana spinor propagates too, but it is
massless, has no bilinear `V(s)`, and has no commuting shadow with a kinetic term. The statement
of minimality is the conclusion of Section 26 as a whole; no single assertion states it. It rests
on the assertions of subsections 3.2.1–3.2.7 [prose VII §26, assembled from the assertions quoted].

### 3.3 The Lagrangian and its Hermiticity

This is the first cell of Section 27 (Input cell 180, 10 assertions). From here on `Psi` and
`Psibar` are two independent 16-component fields of **all eight** coordinates (the commuting proxy
of section 3.2, `Psibar` always on the left).

#### 3.3.1 The four candidates

Four candidate Lagrangians differ by where the derivative acts and whether it is covariant:

```
Lsym    =  (1/(2H)) [ Psibar gamma^mu D_mu Psi - (D_mu Psibar) gamma^mu Psi ] - V(s)     (the Lagrangian of fermion fable)
Lsym_d  =  the same with d_mu in place of D_mu
Lun     =  (1/H) Psibar gamma^mu D_mu Psi - V(s)
Lun_d   =  (1/H) Psibar gamma^mu d_mu Psi - V(s)
```

with `D_mu Psi = d_mu Psi + Gamma_mu Psi`, `D_mu Psibar = d_mu Psibar − Psibar Gamma_mu`, and
`Gamma_mu = GammaSpinCanonical[[mu+1]]`, the canonical spin connection of section 3.8. The action is
`S = Int d^8x Sqrt[det g] Lsym`, with `Sqrt[det g] = Sec[6 H x0]` on the canonical frame. There is
**no factor `i`** in front of the kinetic term, as in the author's `La`: section 3.3.2(b) shows that
none is needed.

#### 3.3.2 The facts, each asserted on the canonical frame for generic `Psi(x0..x7)`, `Psibar(x0..x7)`

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
(section 3.8.8). So `Lsym == Lsym_d` there: the connection drops out of the symmetrized Lagrangian on
every frame on which the **matrix** `{gamma^mu, Gamma_mu}` vanishes (diagonal frames), and **not**
in general. **[proved VII §27]** `LAGRANGIAN (c) [THE RESULT]: Lsym - Lsym_d == (1/(2H)) Sum_mu Psibar {gamma^mu, Gamma_mu} Psi identically, and {gamma^mu, Gamma_mu} == 0 for EACH mu on the canonical frame: Lsym == Lsym_d`

**(d) `Lun` and `Lsym` differ by a total divergence.** **[proved VII §27]**
`LAGRANGIAN (d) [has content]: Lun - Lsym == (1/(2H)) (1/Sqrt[g]) d_mu( Sqrt[g] Psibar gamma^mu Psi ), a total divergence`

**(e) But `Lun` and `Lun_d` differ by a term that is not zero for a complex field.**

```
Lun - Lun_d  ==  (1/H) Psibar gamma^mu Gamma_mu Psi  ==  -3 Cot[6 H x0]^2 Psibar T16[0] Psi
```

This vanishes only in the real commuting limit, which is the scope of the statement "`Lhat` with
`D` == `Lhat` with `d`" of Parts V and VI (section 3.1.12.1). **[proved VII §27]**

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

#### 3.3.3 Why the connection drops out, and why this is not Part VI's mechanism

For the real commuting field of Part VI the connection dropped out because
`Psi^T sigma16 T16[a] Psi = 0` for commuting components (`sigma16 T16[a]` antisymmetric; section
3.1.11). For a complex field that bilinear identity is false:
`Psibar T16[0] Psi = Psi^ddag (sigma16 T16[0]) Psi` with `sigma16 T16[0]` real antisymmetric is `i`
times the Hermitian form of `−i sigma16 T16[0]`, which is not zero in general [derived here]. The
drop-out of the connection from `Lsym` is therefore a property of the **matrix**
`{gamma^mu, Gamma_mu}` (fact (c)), not of a bilinear identity. The general identity behind it is
`Sum_mu {gamma^mu, Gamma_mu} = (1/2) omega_[cab] gamma^{cab}`: only the totally antisymmetric part of
the connection can enter the symmetrized Lagrangian (section 3.8.8).

Hermiticity rests on two facts: `sigma16 gamma^a` and `sigma16 Gamma_mu` are **real antisymmetric**.
The first is Part I's `sigma16 . T16[A] is antisymmetric for A = 0..7`; the second is fact (a).

### 3.4 The field equations in the primordial gravitational field, written out

This is Section 27 of the notebook (Input cells 181, 182 and 184) and item (2) of the pre-universe
cell of Section 29 (Input cell 197). The **primordial gravitational field** is the author's
canonical frame of section 3.1.11:

```
frameCanonical = DiagonalMatrix[{ Tan[6 H x0],  q, q, q,  1,  p, p, p }]
q = Exp[-a4[H x4]] / Sin[6 H x0]^(1/6),        p = Exp[+a4[H x4]] / Sin[6 H x0]^(1/6)       (a4 free, never given a value)
ds^2 = Tan[6 H x0]^2 dx0^2 + q^2 (dx1^2 + dx2^2 + dx3^2) - dx4^2 - p^2 (dx5^2 + dx6^2 + dx7^2),     Sqrt[|det g|] = Sec[6 H x0]
gamma^0 = Cot[6 H x0] T16[0],   gamma^i = (1/q) T16[i]  (i = 1,2,3),   gamma^4 = T16[4],   gamma^h = (1/p) T16[h]  (h = 5,6,7)
```

on `0 < 6 H x0 < Pi/2`. The spin connection enters through `gamma^mu Gamma_mu = −3 H Cot[6 H x0]^2 T16[0]`
(section 3.8.8).

#### 3.4.1 The derivation

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

#### 3.4.2 The 16×16 matrix form on the canonical frame

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

#### 3.4.3 The split-octonion 8+8 form

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

#### 3.4.4 All sixteen component equations

Each `T16[a]` is a signed permutation matrix, so component equation `r` contains exactly **one**
derivative per coordinate, of the component that `T16[a]` maps to `r`; the connection term
multiplies the same component as the `x0`-derivative; and `−H V'` multiplies `psi_r` itself. For
fields of all eight coordinates the sixteen equations form **one** coupled block. (The four blocks
of four of Section 13, section 3.1.9, belong to the reduction to fields of `(x0, x4)` only.) The term
lists `cfFieldEqTerms` and `cfAdjEqTerms` from which the equations below are rendered reproduce all
sixteen field equations and all sixteen adjoint equations exactly. **[proved VII §27]**

- `WRITTEN OUT (iii) [definition]: the term lists reproduce all sixteen field equations and all sixteen adjoint equations exactly`
- `WRITTEN OUT (iii) [has content]: every component equation has exactly one derivative per coordinate x0..x7, the connection term multiplies the component carrying the x0-derivative, and -H V' multiplies psi_r itself`
- `WRITTEN OUT (iii) [has content]: for fields of all eight coordinates the sixteen equations form ONE coupled block (the four blocks of four of Section 13 belong to the (x0, x4) reduction)`

**How to read the equations below.** They are the plain-text export written by
`claude-fable/export_fermion_fable_tex.wls` from the notebook's own asserted objects
(`provenance-latex/generated/fermion_fable_field_equations.txt`; the LaTeX twins of the provenance pages of 2026-09-24 use
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

#### 3.4.5 All sixteen adjoint equations

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
`T16[a]^T = eta_aa T16[a]` [derived here; the rule was checked for the provenance pages of 2026-09-24 on all 128 derivative
terms and 16 connection terms of the two exported files by a short script; it is not a notebook
assertion]. The adjoint equations are the Dirac conjugates of the field equations
(`FIELD EQUATION [has content]: the adjoint equation IS the Dirac conjugate of the field equation: with Psi = u + i v, Psibar = (u - i v)^T sigma16, adjoint residual == -(field residual)^* . sigma16`, section 3.4.1).

#### 3.4.6 The 8+8 form, component by component

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

#### 3.4.7 The rescaled form: the spin connection disappears

Put `Psi = Sqrt[Sin[6 H x0]] Psi'` and `Psibar = Sqrt[Sin[6 H x0]] Psi'bar`. Then `s = Sin[6 H x0] s'`
with `s' = Psi'bar Psi'`, and

```
gamma^mu D_mu Psi - H V'(s) Psi  ==  Sqrt[Sin[6Hx0]] ( Cot T16[0] d_0 Psi' + (1/q) Sum_i T16[i] d_i Psi' + T16[4] d_4 Psi'
                                                       + (1/p) Sum_h T16[h] d_h Psi' - H V'(Sin[6Hx0] s') Psi' )
```

with **no connection term at all**, and the same for the adjoint equation. This works because the
connection term is a gradient: `gamma^mu Gamma_mu = −(1/2) T_mu gamma^mu` with the Weitzenböck
torsion vector `T_mu = d_mu Log[Sin[6 H x0]]` (section 3.8.10), and multiplying by
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

#### 3.4.8 The `x4`-only family and the condition `V'' s' = 0`

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

#### 3.4.9 The operator form of the field equation, and its ordering

These are definitions, not identities [prose VII §27]. The Hamiltonian (section 3.5.11) contains
`V(:s:)`, defined by the spectral calculus of the Hermitian operator `s(x) = Psi^dagger beta Psi` of
section 3.5.5 (regularized and normal-ordered). No ordering prescription is needed there, and a
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
- In the Kohn–Sham mean field of section 3.7, `V'(s)` is replaced by `V'(<s>)` and the equation is
  linear.

#### 3.4.10 The U(1) current and the particle-number current

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

The **particle-number current** is `n^mu := −(i/H) Psibar gamma^mu Psi = −j^mu/H`. As section 3.5.15
shows, `N = Int Sqrt[g] n^4 d^7x` is the normal-ordered number of particles minus antiparticles, so
the charge of `j` carries a conventional minus sign: `Int Sqrt[g] j^4 d^7x = −H N` [prose VII §27].
So one particle (one occupied positive-frequency `J`-mode, `N = +1`) carries `j`-charge `−H`, and one
antiparticle `+H` [derived here from the two definitions; the design review, QK-10, states the same
sign as "a positive-frequency J-mode carries j-charge −1", that is, in units of `H`].

#### 3.4.11 The only internal symmetry is the vector phase

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

### 3.5 Canonical quantization in 4+4 dimensions

This is Section 28 of the notebook (Input cells 185–191, 56 assertions). "Extended to 4+4
dimensions" means: the time is one of the four timelike directions, `x4`, and the slice of constant
time is seven-dimensional and contains the other three timelike directions. Everything below
follows from the symmetrized Lagrangian of section 3.3; the result is summarized first.

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

#### 3.5.1 Time, slices, and why the slice is not a Cauchy surface

Time is `x4`, the observer's proper time. On the canonical frame `g_44 = −1` (lapse 1) and
`g_4mu = 0` for `mu != 4` (shift 0). A slice `x4 = const` is **seven**-dimensional with signature
`(4,3)`: `x0, x1, x2, x3` spacelike and `x5, x6, x7` **timelike**. It is therefore not a Cauchy
surface, and the quantization is carried out where it is well posed (the admissible sector, 6.10).
**[proved VII §28]** `QUANTIZATION [definition]: lapse 1 and shift 0 (g_44 == -1, g_4mu == 0), and the slice x4 = const has signature (4,3) -- x0..x3 spacelike, x5..x7 timelike (given a4 real and 0 < 6 H x0 < Pi/2)`

#### 3.5.2 The momenta, the kinetic form `G`, and the signature `(8,8)`

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

#### 3.5.3 The Dirac bracket and the canonical anticommutator

Write `Psi = (theta1 + i theta2)/Sqrt[2]` with real Grassmann `theta1, theta2` and
`Theta = (theta1, theta2)`. In the Grassmann algebra of section 3.2.3, for `K = c sigma16 T16[4]` with
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
brackets, by the Fock space of section 3.5.14: with this anticommutator the Heisenberg equation
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

#### 3.5.4 The admissible truncation, `V_hid`, and the rescaled field

The admissible theory (6.10) is a **truncation**: a dimensional reduction to fields
`Psi = Psi(x0, x1, x2, x3, x4)`, independent of `x5, x6, x7`. It needs a **finite** hidden coordinate
volume `V_hid = Int dx5 dx6 dx7`. That is an assumption, and it has a consequence that must be
stated: compact timelike directions contain closed timelike curves. In the truncation the delta
function becomes `delta^4(x0..x3 − y0..y3)` and the factor `H/Sqrt[g]` becomes `H/(V_hid Sqrt[g])`:

```
{Psi_a(x), Psi^ddag_b(y)}_{x4 = y4}  =  ( H / (V_hid Sqrt[|g|]) ) G_ab delta^4(x0..x3 - y0..y3),       G = -i sigma16 gamma^4
```

For the rescaled field `Psi' = Psi/Sqrt[Sin[6 H x0]]` of section 3.4.7 the factor is
`H Cos[6Hx0]/Sin[6Hx0] = H Cot[6 H x0]`. On a frame whose `Sqrt[g]` depends on `x4` one quantizes
`chi = (Sqrt[g]/H)^(1/2) Psi`, with `{chi, chi^ddag} = G delta^7`; on the canonical frame `Sqrt[g]`
does not depend on `x4` and the two coincide [prose VII §28]. **[proved VII §28]**
`ANTICOMMUTATOR [has content]: the rescaled field Psi' = Psi/Sqrt[Sin[6 H x0]] has {Psi', Psi'^ddag} == H Cot[6 H x0] J delta^7, and Sqrt[g] is x4-independent (so quantizing chi = (Sqrt[g]/H)^(1/2) Psi changes nothing on the canonical frame)`

(For the time-dependent warped frames of the interacting system, Part VIII of the notebook,
Section 32, proves that the rescaled field has an `x4`-independent anticommutator:
`RESCALING [THE RESULT]: {Psi, Psi^ddag} == (H/Sqrt[|det g|]) G on the warped frame (Section 28's cfAntiPsiPsiDd at c = Sqrt[|det g|]/H), and for chi = Psi/f, f = Sqrt[Sin] (A^3 B^3 C)^(-1/2): {chi, chi^ddag} == H Cot[6 H x0] G -- the Sqrt[det g] cancels, independent of x4 and of A, B, C` and `RESCALING [has content]: on the warped frame G = -i sigma16 gamma^4 is Section 28's cfGK (= J) -- the same matrix on every member of the family (gamma^4 == T16[4], lapse 1)`.)

#### 3.5.5 What `J` is, and the Hilbert adjoint

`J = −i T16[0]...T16[4] = −i Omega4 T16[0] = −i h_0`, with `Omega4 = T16[1].T16[2].T16[3].T16[4]` of
section 3.2.6. So `J` is one of the hidden **flavour** gammas: it lies in the commutant of the
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
a `J`-eigenvector (section 3.5.13). **[proved VII §28]**

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

#### 3.5.6 Why this is legitimate for fermions, and why it would fail for bosons

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

#### 3.5.7 Chirality, and why `V` depends on `s` only

`J` anticommutes with `T16[8]`: `J` exchanges the two split-octonion types. Each chirality subspace
is `G`-**null** (`PL G PL = PR G PR = 0`: the Krein form pairs type-1 with type-2 only), so the
`J`-vacuum is not chirality-graded; but the two chirality subspaces **are** orthogonal in the Hilbert
product (`PL PR = 0`, with `PL`, `PR` Hermitian). Neither `p = Psibar T16[8] Psi` (anti-Hermitian
under `J`) nor `i p` (anti-Hermitian under the classical conjugation `^ddag`, so it would make the
Lagrangian complex) can enter `V` consistently: **`V = V(s)`**. **[proved VII §28]**
`J [has content]: chirality -- {J, T16[8]} == 0, each chirality subspace is G-NULL (PL G PL == PR G PR == 0), and the two chiralities are orthogonal in the Hilbert product (PL, PR Hermitian, PL PR == 0)`

#### 3.5.8 The Hermiticity rule and the `J` table

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
(the `J`-vacuum and the Kohn–Sham states of section 3.7), consistent with `G_{mu h} = 0` on the
canonical frame. `That_{h h'}` (`h != h'`) vanishes identically for fields independent of `x5..x7`,
and `That_{hh} = g_hh Lhat` is Hermitian (section 3.6.5).

(The same `J` table holds on the dynamical frames of the interacting system; Part VIII, Section 32,
proves it: `J [THE RESULT]: [J, gamma^mu Gamma_mu] == 0 for EACH mu separately (h = 5,6,7 included), on the warped and on the Bianchi-I frame` and `J [THE RESULT]: [J, Gamma_mu] == 0 for mu = 0..4 and {J, Gamma_h} == 0 for h = 5, 6, 7, on the warped and on the Bianchi-I frame`.)

#### 3.5.9 The symmetry that survives, and what is lost

Of the 28 Lorentz generators `S_ab`, **13 commute** with `J`: Spin(4,1) of `x0..x4` (10 generators)
and Spin(3) of `x5..x7` (3). The other **15 anticommute**: the 12 boosts between `x0..x3` and
`x5..x7`, and the 3 **rotations** between `x4` and `x5..x7` (`x4..x7` are all timelike, so those
planes are rotations). The Krein form `G` itself is invariant (`S^T G + G S = 0`) under exactly the
21 generators with `a, b != 4`: Spin(4,3), the group of the slice. **[proved VII §28]** (The `J`
structure is defined in the diagonal gauge of the canonical frame and transforms as `J -> S^-1 J S`
under a change of frame gauge `S`; design review QK-6.)

- `J [THE RESULT]: 13 of the 28 Lorentz generators commute with J (a, b both in {0..4}: Spin(4,1), or both in {5,6,7}: Spin(3)); the other 15 anticommute -- 12 boosts x0..x3 <-> x5..x7 and 3 rotations x4 <-> x5..x7`
- `J [has content]: the Krein form G is invariant (S^T G + G S == 0) under exactly the 21 generators with a, b != 4 -- Spin(4,3), the group of the slice`

#### 3.5.10 The admissible sector: a theorem

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

#### 3.5.11 The Hamiltonian on the canonical frame, and the spin connection

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

#### 3.5.12 The `x0` direction and the boundary condition at the wall

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

#### 3.5.13 Krein modes, and why the mode basis must consist of `J`-eigenvectors

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

#### 3.5.14 A finite Fock space at one momentum (Jordan–Wigner): the Dirac sea, 8 particles and 8 antiparticles

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
  in section 3.7.

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

#### 3.5.15 The particle number

The particle-number density is

```
n^4 = -(i/H) Psibar gamma^4 Psi  ==  (1/H) Psi^ddag G Psi  ==  (1/H) Psi^dagger Psi  >= 0
```

and its mode form `Sum_u eta_u b_u^ddag b_u == Sum_u b_u^dagger b_u` is the particle number
(normal-ordered: particles minus antiparticles). **[proved VII §28]** `CHARGE [THE RESULT]: n^4 = -(i/H) Psibar gamma^4 Psi == (1/H) Psi^ddag G Psi == (1/H) Psi^dagger Psi, whose mode form Sum_u eta_u b_u^ddag b_u == Sum_u b_u^dagger b_u is the particle number (normal-ordered: particles - antiparticles)`

#### 3.5.16 The dynamical-frame field `chi`

On a frame whose volume factor depends on `x4` the field to quantize is
`chi = (Sqrt[g]/H)^(1/2) Psi`, with `{chi, chi^ddag} = G delta^7` (6.4). On the canonical frame
`Sqrt[g] = Sec[6 H x0]` does not depend on `x4`, and quantizing `chi` changes nothing
(`ANTICOMMUTATOR [has content]: the rescaled field Psi' = Psi/Sqrt[Sin[6 H x0]] has {Psi', Psi'^ddag} == H Cot[6 H x0] J delta^7, and Sqrt[g] is x4-independent (so quantizing chi = (Sqrt[g]/H)^(1/2) Psi changes nothing on the canonical frame)`). On the time-dependent warped frames of the interacting
system (Part VIII), the rescaled `chi = Psi / (Sqrt[Sin[6 H x0]] (A^3 B^3 C)^(−1/2))` has
`{chi, chi^ddag} = H Cot[6 H x0] G`, independent of `x4` and of the scale factors
(`RESCALING [THE RESULT]: {Psi, Psi^ddag} == (H/Sqrt[|det g|]) G on the warped frame (Section 28's cfAntiPsiPsiDd at c = Sqrt[|det g|]/H), and for chi = Psi/f, f = Sqrt[Sin] (A^3 B^3 C)^(-1/2): {chi, chi^ddag} == H Cot[6 H x0] G -- the Sqrt[det g] cancels, independent of x4 and of A, B, C`).

### 3.6 The energy–momentum tensor operator

This is the first half of Section 29 of the notebook (Input cells 192–194, 16 assertions).

#### 3.6.1 The definition, and where it comes from

The energy–momentum tensor of fermion fable is

```
That_{mu nu}  =  -(1/(4H)) [ Psibar gamma_mu D_nu Psi - (D_nu Psibar) gamma_mu Psi + (mu <-> nu) ]  +  g_{mu nu} Lhat,        gamma_mu = g_{mu nu} gamma^nu
```

normal-ordered with respect to the `J`-vacuum of section 3.5 when it is an operator. It is the
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

#### 3.6.2 Symmetric and Hermitian

`That` is symmetric, and it is Hermitian under the classical conjugation: real for `Psi = u + i v`,
`Psibar = (u − i v)^T sigma16`, in all 64 components. **[proved VII §29]**

- `EMT [definition]: That is symmetric`
- `EMT [THE RESULT]: That is Hermitian under the classical conjugation: real for Psi = u + i v, Psibar = (u - i v)^T sigma16, all 64 components`

#### 3.6.3 Conservation on shell, and why the commuting proxy proves it for the fermion

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
pre-universe results of section 3.7 are evaluated.

#### 3.6.4 On shell: the Lagrangian, the density, the pressures and the trace

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
`K_h` is Part VI's `cfKh` (section 3.1.12.4), and for the rescaled solutions
`Psi = Sqrt[Sin[6 H x0]] Psi'(x4)` (and the same for `Psibar`) `K_h = 0` and `rho = V(s)`: Part VI's
formulas, now for the complex field. **[proved VII §29]**

- `EMT ON SHELL [THE RESULT]: the kinetic bilinear == s V'(s) (not zero) and Lhat == s V'(s) - V(s)`
- `EMT ON SHELL [THE RESULT]: rho = That_44 == V(s) + K_h`
- `EMT ON SHELL [THE RESULT]: T^i_i == T^h_h == s V'(s) - V(s) for the three observed and the three hidden directions, and T^0_0 == s V'(s) - V(s) + K_h`
- `EMT [has content]: the trace T^mu_mu == 7 Lkin - 8 V off shell, == 7 s V'(s) - 8 V(s) on shell`
- `EMT [fidelity]: K_h in the real commuting limit IS Part VI's cfKh, and K_h == 0 on the rescaled solutions Sqrt[Sin] Psi'(x4), Sqrt[Sin] Psi'bar(x4), where rho == V(s)`

#### 3.6.5 Which components are Hermitian operators: the `J`-parity table

For fields independent of `x5, x6, x7` (the admissible sector, here `Psi(x0, ..., x4)`,
`Psibar(x0, ..., x4)`), replace `Psi -> J Psi` and `Psibar -> Psibar J` (`J^2 = 1`, `s` is unchanged).
A component that goes into itself is built from `J`-even matrices and is a **Hermitian** operator;
one that goes into minus itself is **anti-Hermitian** (section 3.5.8). The notebook computes the
parity of all 64 components (3.561 s) and asserts the table:

| component | `J`-parity | operator |
|---|---|---|
| `That_{mu nu}`, `mu, nu` in `{0..4}` | even | Hermitian |
| `That_{mu h}`, `mu` in `{0..4}`, `h` in `{5,6,7}` | odd | anti-Hermitian: purely imaginary expectation values, zero in every state invariant under the hidden rotations (`That_{mu h}` is a vector under them) |
| `That_{h h'}`, `h != h'` | zero identically | — |
| `That_{hh}` | even | Hermitian; `That_{hh} = g_hh Lhat` exactly, because `{gamma_h, Gamma_h} = 0` |

The hidden momenta `P_h = Int Sqrt[g] That^4_h` are `J`-odd operators with zero expectation in the
`J`-eigenmode Fock states of section 3.5 [prose VII §29]. The anti-Hermitian components are
consistent with `G_{mu h} = 0` on the canonical frame. **[proved VII §29]**

- `EMT HERMITICITY [THE RESULT]: J-parity table -- (mu, nu) in {0..4}: EVEN (Hermitian); (mu in 0..4, h in 5..7): ODD (anti-Hermitian); (h, h'), h != h': ZERO identically; (h, h): even`
- `EMT HERMITICITY [has content]: for x5..x7-independent fields That_{hh} == g_hh Lhat exactly, because {gamma_h, Gamma_h} == 0`

#### 3.6.6 The real commuting limit

Set `Psi -> psi` (real, commuting) and `Psibar -> psi^T sigma16`. Then `That` becomes Part VI's
covariant tensor `T_cov` of section 3.1.12.3 exactly, all 64 components: `FIDELITY [4] [fidelity]: the energy-momentum tensor That in the real limit IS Part VI's covariant tensor cfTCov, all 64 components`. The
classical tensor of 2026-09-16 is therefore the commuting shadow of the operator derived here.

### 3.7 Density, pressure and equations of state

This is the second half of Section 29 of the notebook (Input cells 195–197, 23 assertions), with the
numerically stable forms used by the solver and the vacuum-energy caveat added from the design
review.

#### 3.7.1 The operators

The observer is `u = d/dx4`. The energy-density and pressure **operators** are the normal-ordered
components of section 3.6:

```
rho_op   =  :That_44:                        (the energy density measured by the observer)
P_j,op   =  :That^j_j:     (no sum)          j = 1, 2, 3: the observed sheet;   j = 0: the hidden spacelike direction;   h = 5, 6, 7: the hidden timelike sheet
w        =  <P_obs> / <rho>                  P_obs = the pressure along the observed sheet
```

On shell, for fields of `(x0, x4)`: `rho = V(s) + K_h`, `P_i = P_h = s V'(s) − V(s)`,
`P_0 = s V'(s) − V(s) + K_h` (section 3.6.4). These are operator identities in the sense of section 3.4.9
(ordering by the Weyl rule; exact for linear `V`).

#### 3.7.2 Expectation values: the mode sums, and one particle

Use the **canonical normalization** `chi = Psi/Sqrt[H]`. Then `V(s) = V(H sigma) =: W(sigma)` with
`sigma = <chibar chi>`, and `m = W'(sigma)` is the mass in the mode equation. On a flat-frame plane
wave `chi = u Exp[i (k.x − omega x4)]`, `chibar = ubar Exp[−i (k.x − omega x4)]` (`ubar = u^ddag sigma16`),
the kinetic parts of the tensor are

```
T_44 + Lhat     ==  omega ubar (-i T16[4]) u  =  omega u^ddag G u
T^j_j - Lhat    ==  k_j  ubar (-i T16[j]) u   =  k_j u^ddag (dh/dk_j) u          (j = 0..3, flat frame)
```

By the expectation rule `<Psi^ddag N Psi> = Sum_occupied eta_u u^dagger N u` (section 3.5.14) and the
exact mode identities of section 3.5.13, each occupied positive-frequency mode contributes `omega` to
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

#### 3.7.3 The vacuum: normal ordering, the sea energy, and the cosmological-constant problem

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
at `m = M` and is even in `m`]. It is neither zero nor absorbable into `W` without changing the gap
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

#### 3.7.4 The homogeneous Fermi sea (the Kohn–Sham ground state) in closed form

Fill the positive-frequency modes with `|k| < k_F` along the observed sheet (zero modes along `x0` —
the `Sqrt[Sin]` profile — and along `x5, x6, x7`). The degeneracy is **`g = 8` = 4 flavours × 2
spins** (sections 3.2.6 and 3.5: eight positive-frequency modes per momentum). With `w_F = Sqrt[k_F^2 + m^2]`
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

#### 3.7.5 The numerically stable forms

The closed forms cancel catastrophically for `x = k_F/|m| << 1`: `eps ~ m n`, `sigma ~ n` and
`P ~ n k_F^2/(5m)` are small differences of large terms. The solver therefore uses three regimes,
all written with the integral representations
`S(x) = 2 Int_0^x t^2/Sqrt[1+t^2]`, `E(x) = 8 Int_0^x t^2 Sqrt[1+t^2]`, `Q(x) = 8 Int_0^x t^4/Sqrt[1+t^2]`,
with `sigma = g m^3 S/(4 pi^2)`, `eps = g m^4 E/(16 pi^2)`, `P = g m^4 Q/(48 pi^2)`
[file: `fable-cosmology/rust/fable_fermion/src/kohn_sham.rs`, module documentation and constants
`X_LO = 0.6`, `X_HI = 100.0`]:

| regime | form used |
|---|---|
| `x < X_LO = 0.6` | the convergent binomial series (radius 1) in `x^2`, e.g. `eps = \|m\| n [1 + (3/10) x^2 − (3/56) x^4 + ...]`, `sigma = sgn(m) n [1 − (3/10) x^2 + ...]` |
| `0.6 <= x <= X_HI = 100` | the closed forms (with `asinh x = L`), losing at most about 1.3 digits at `x = 0.6` |
| `x > 100` | the ultra-relativistic series in `y = \|m\|/k_F`, with the logarithm kept exact |
| `m = 0` exactly | `sigma = 0`, `eps = 3P = g k_F^4/(8 pi^2)` |

The series coefficients are `binom(−1/2, j)` for `S` and `Q` and `binom(1/2, j)` for `E`:
`S = Sum_j 2 binom(−1/2, j) x^(2j+3)/(2j+3)`, `E = Sum_j 8 binom(1/2, j) x^(2j+3)/(2j+3)`,
`Q = Sum_j 8 binom(−1/2, j) x^(2j+5)/(2j+5)` (the `series_nr` function of the same file). The commit
that finished the solver (`c5892bd`) records that these agree with quadrature to `1e-12` from
`x = 1e-8` to `1e6`, and that `cargo test --release` passes 21 + 8 tests, among them
`kohn_sham::tests::fermi_integrals_match_quadrature` and
`kohn_sham::tests::series_and_closed_forms_are_continuous_at_the_switch_points`. (The design review
had proposed a switch at `x = 0.25`; the implemented switch is `0.6`.)

#### 3.7.6 The mean field

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

#### 3.7.7 The classical limit is the non-relativistic limit, and the sign rule

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

#### 3.7.8 The author's mass term: `w` falls from 1/3 to 0

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

#### 3.7.9 `w >= −1` always: no phantom crossing for the quantized fable

From `rho + P_obs = w_F n` (8.6), which is exact, and `w_F n >= 0`:

```
w_f + 1  =  (rho + P_obs)/rho  =  w_F n / rho  >=  0          wherever rho > 0
```

(`w_f` is the fable's equation of state `w = <P_obs>/<rho>` of 8.1; `w_F = Sqrt[k_F^2 + m^2]` is the
Fermi energy.)

The quantized fermion fable **cannot cross the phantom divide**, for any potential `W` [derived
here from `MEAN FIELD [THE RESULT]: rho = eps + W - sigma W', P_obs = P_KS + sigma W' - W give rho + P_obs == w_F n exactly; and d rho/dn == w_F + (sigma_KS - sigma) W'' sigma'(n), i.e. == w_F at the self-consistent point sigma = sigma_KS (m = W'(sigma) throughout)`]. The classical Part VI crossing at `V'(s1) = 0`
(section 3.1.12.7) is unreachable. In the quantum theory `rho + P_obs = w_F n > 0` at every non-zero
density, whatever the value of `m`. And for the `expdamp` potential the gap equation keeps
`0 < sigma < min(n, s1)` strictly, so `m = W'(sigma)` never reaches the classical crossing point at
finite density: `sigma -> s1` and `m -> 0` only as `n -> infinity` (design review DFT-6; solver tests
`kohn_sham::tests::expdamp_pins_sigma_below_s1_and_mass_goes_to_zero_at_high_density` and
`kohn_sham::tests::no_phantom_crossing_rho_plus_p_obs_is_nonnegative`). The classical phantom
crossing of 2026-09-16 therefore does **not** survive quantization. (What an observer who fits a
cold-dark-matter-plus-dark-energy model to the coupled system can infer — an apparent crossing, when
the dust is subtracted at today's dark-matter density and the effective mass grows — is a property
of that fit, not of the fluid; it is part of the coupled system, Effort B, and is stated in section 1.)

#### 3.7.10 On the pre-universe: the quantum gas cools, the classical field does not

Four facts, each proved on the canonical frame with `a4` free.

**(1) Charge.** The U(1) current is conserved on shell for generic `Psi(x0, x4)`, `Psibar(x0, x4)`.
For the `x0`-profile `Psi = Sqrt[Sin[6 H x0]] Psi'` with `Psi'` independent of `x0`, `Sqrt[g] j^0` is
independent of `x0` (`Sec Sin Cot = 1`), so `d_4(Sqrt[g] j^4) = 0`: the charge per coordinate volume
does not depend on `x4`, and since `Sqrt[g]` does not either, neither does the proper 8-density. The
7-volume is constant because the observed sheet grows exactly as the hidden sheet shrinks
(`q^3 p^3` is `x4`-independent). **[proved VII §29]**

- `PRE-UNIVERSE (1) [THE RESULT]: the U(1) current is conserved on shell, (1/Sqrt[g]) d_mu(Sqrt[g] j^mu) == 0, for generic Psi(x0, x4), Psibar(x0, x4)`
- `PRE-UNIVERSE (1) [THE RESULT]: for Psi = Sqrt[Sin] Psi'(x4), Sqrt[g] j^0 is x0-independent (Sec Sin Cot == 1), so d_4(Sqrt[g] j^4) == 0 on shell; and Sqrt[g] and q^3 p^3 are x4-independent`

**(2) Which `x4`-only fields solve the equations:** `V'' s' = 0` (section 3.4.8).

**(3) Redshift.** A mode `Psi = Sqrt[Sin] u(x4) Exp[i k x1]` (coordinate momentum `k` along the
observed sheet) obeys `T16[4] u' + i (k/q) T16[1] u = H V' u` exactly (mass term, `V'` constant): its
**physical** momentum is `k/q`, and `d Log[k/q]/dx4 = H a4'(H x4) = −H_obs`. The observed-sheet momenta
redshift as `Exp[a4] ~ 1/a`, and the instantaneous frequency is `Sqrt[k^2/q^2 + m^2]`
(`E^2 = omega^2` at `k_phys = k/q`, section 3.5.10). **[proved VII §29]**

- `PRE-UNIVERSE (3) [THE RESULT]: for Psi = Sqrt[Sin] u(x4) Exp[i k x1] the field equation (mass term, V' = constant) is Sqrt[Sin] Exp[i k x1] (T16[4] u' + i (k/q) T16[1] u - H V' u): the physical momentum is k/q`
- `PRE-UNIVERSE (3) [THE RESULT]: d Log[k/q]/dx4 == H a4'[H x4] == -H_obs (observed momenta redshift as Exp[a4]), and E^2 == (k^2/q^2 + m^2) ID16 at the physical momentum`

**(4) Cooling.** The occupied coordinate momenta are fixed (the mode labels are conserved; the
`x4`-dependence of `q` only mixes `±omega`, a Bogoliubov effect that vanishes adiabatically). So
`x = k_F,phys/m` falls as `Exp[a4]`: `d Log[x]/dx4 = H a4'`, and since `w(x)` is increasing,
`sign(dw/dx4) = sign(a4')`. In the regime `a4' < 0` (the observed sheet expanding, the sign hypothesis
of Part VI, section 3.1.11) the quantum fable gas **cools**, `w: 1/3 -> 0`, even though its 8-density
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

### 3.8 The canonical spin connection: a complete discussion

This section covers the canonical spin connection of the 4+4 pre-universe in full: the frame it
comes from, how it is computed, every non-zero component, its 16×16 spinor form, the
gauge-covariant derivative of the 16-component spinor, how it relates to the three bridges of
Part IV and to the fable-5.1 (Weitzenböck) bridge of Part V, and what it does and does not do for
the complex fermion fable. It stands on its own. Every object is defined here and every result
is restated here, with the place where it is proved.

Throughout, "Section n" (capital S) means a section of the notebook. The numbered parts of this
discussion are called "subsections" 9.1–9.13.

---

#### 3.8.1 Sources, and how the status of each statement is marked

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
(Part VII adds 170 assertions and 11 witnesses to Parts I–VI). The full run of Parts I–VIII,
`claude-fable/run_fermion_fable_part8.log`, reports `Assertions run: 642   passed: 642   failed: 0`.

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
| **[proved P §n]** `"label"` or `label` | a `cfAssert` of Part P, Section n, that prints `PASS` in `run_fable51_part6.log` (Parts I–VI), `run_fermion_fable_part7.log` (Part VII) or `run_fermion_fable_part8.log` (Part VIII); the label is quoted verbatim |
| **[displayed P §n]** | the printed output of a cell of Part P, Section n (a table, a count or a closed form); an output, not an assertion |
| **[prose P §n]** | stated only in prose in the notebook (a Text cell, or a comment inside an Input cell), not asserted |
| **[derived here]** | a short derivation carried out in this section from results marked above, with every step shown |

The notebook grades its own assertion labels. `[definition]` means true by construction.
`[structural]` means true for any input of the right shape. `[solver regression]` is a check of
the code, not of the geometry. `[has content]` could have failed. `[THE RESULT]` marks a headline
result. `[control]` shows that the wrong alternative fails.

#### 3.8.2 Conventions

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

#### 3.8.3 The canonical frame (vielbein), the metric, and the volume factor

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

#### 3.8.4 The generalized Christoffel symbols

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

#### 3.8.5 The vielbein postulate, and how `cfSpinConnection` solves it

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

#### 3.8.6 The canonical spin connection: all its non-zero components

`omegaCanonical` has **24 non-zero components out of 512** **[displayed III §16]**. They are
listed by `cfShowConnection[omegaCanonical, "omega"]`. In subsections 3.8.6 and 3.8.7 only, write
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

#### 3.8.7 The spinor connection `Gamma_mu` and its exact normalization

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

**The explicit matrices [derived here, from the table of subsection 3.8.6 and the formula above].**
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

#### 3.8.8 The gauge-covariant derivative of the 16-component spinor

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
explicit `Gamma_mu` of subsection 3.8.7 and the curved gammas of subsection 3.8.3, using `T16[j].T16[j] = +ID16`,
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

#### 3.8.9 The three bridges of Part IV

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

##### 3.8.9.1 Bridge 1: a locally boosted frame, the same connection in a local gauge (Section 18)

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
frame (subsection 3.8.10 below).

##### 3.8.9.2 Bridge 2: the null (light-cone) frame, the same connection in a constant gauge (Section 19)

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

##### 3.8.9.3 Bridge 3: triality frame with totally antisymmetric split-octonion torsion, a different connection (Section 20)

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

#### 3.8.10 The fable-5.1 bridge of Part V: the Weitzenböck (teleparallel) connection

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

The first line checks against subsection 3.8.8 **[derived here]**:
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

#### 3.8.11 Master comparison of the five connections (Section 22)

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

#### 3.8.12 What the canonical connection does for the complex fermion fable

Everything in this section concerns the **complex** 16-component fermion fable of Part VII. Two
kinds of statement appear. Some are consequences of results already proved in Parts I–VI, and
the derivation is shown here. The others are assertions of the new Part VII, marked
**[proved VII §n]**, with the label quoted verbatim from `claude-fable/run_fermion_fable_part7.log`.

##### 3.8.12.1 The field and the symmetrized Lagrangian

Fermion fable is a complex 16-component Grassmann spinor `Psi`. It is the minimal field that uses
the author's `sigma16` conjugation, propagates, admits a potential `V(s)`, and reduces to Part VI's
real field as its real commuting shadow. It is not the unique field with dynamics. This is the
conclusion of Section 26 as a whole (section 3.2.8); no single assertion states it. It rests on
**[proved VII §26]** `REFINEMENT (d) [THE RESULT]: s = Psibar Psi == i theta1^T sigma16 theta2: NON-ZERO (16 monomials) and HERMITIAN; p = Psibar T16[8] Psi is non-zero and Hermitian too`, `REFINEMENT (b) [THE RESULT]: Majorana with C+: the kinetic term is genuine -- Euler-Lagrange expression 2 C+ T16[a] phi with C+ T16[a] invertible -- but every invariant bilinear vanishes (massless, no V(s))`,
`REFINEMENT (c) [THE RESULT]: Weyl and Majorana-Weyl: PL C T16[a] PL == PR C T16[a] PR == 0 for C = C-, C+ and every a (C chirality-diagonal, T16[a] chirality-odd) -- no kinetic term` and `FIDELITY [1] [fidelity]: Psi -> psi, Psibar -> psi^T sigma16 turns the symmetrized covariant Lhat into Part VI's cfLhatFable EXACTLY (canonical frame, generic V)`, among the others quoted in section 3.2. Its Dirac
conjugate and scalar bilinear are

```
Psibar = Psi^ddag sigma16            s = Psibar Psi = -psi1^ddag sigma psi1 + psi2^ddag sigma psi2
```

where `^ddag` is the classical conjugate transpose. The second form follows from
`sigma16 = diag(-sigma, sigma)`. In the quantized theory the Hilbert adjoint is
`Psi^dagger := Psi^ddag J` (subsection 3.8.12.6).

The only Lagrangian used is the **symmetrized covariant** one:

```
L = Sqrt[g] Lhat,     Lhat = (1/(2H)) [ Psibar gamma^mu D_mu Psi - (D_mu Psibar) gamma^mu Psi ] - V(s)
D_mu Psi = d_mu Psi + Gamma_mu Psi,          D_mu Psibar = d_mu Psibar - Psibar Gamma_mu
```

`D_mu Psibar` is the Dirac conjugate of `D_mu Psi`, and `Lhat` is real, because `sigma16 gamma^a`
and `sigma16 Gamma_mu` are **real antisymmetric** matrices. That rests on
**[proved I §5]** `"sigma16 . T16[A] is antisymmetric for A = 0..7"` and `"sigma16 . SAB is antisymmetric"`,
together with `Gamma_mu = (1/2) omega_{mu ab} SAB` with real `omega` (subsection 3.8.7).
**[proved VII §27]** `LAGRANGIAN (a) [definition]: every Gamma^spin_mu is real and sigma16 Gamma_mu is antisymmetric (Gamma_mu^T sigma16 == -sigma16 Gamma_mu): D_mu Psibar is the Dirac conjugate of D_mu Psi`.

##### 3.8.12.2 It drops out of the symmetrized Lagrangian because the matrix `{gamma^mu, Gamma_mu}` vanishes

Expanding `D` in the symmetrized Lagrangian gives **[derived here]**

```
Lhat(D) = Lhat(d) + (1/(2H)) Psibar ( Sum_mu {gamma^mu, Gamma_mu} ) Psi
```

The connection terms are `Psibar gamma^mu Gamma_mu Psi` from the first product and
`+Psibar Gamma_mu gamma^mu Psi` from `-(D_mu Psibar) gamma^mu Psi`. On the canonical frame
`{gamma^mu, Gamma_mu} = 0` **for each `mu`** (subsection 3.8.8), so `Lhat(D) = Lhat(d)` identically. That
is, "covariant == partial" holds for the symmetrized complex Lagrangian on this frame. It holds
on any frame where the totally antisymmetric part `omega_[cab]` vanishes, and fails in general.

- **[proved VII §27]** `LAGRANGIAN (c) [THE RESULT]: Lsym - Lsym_d == (1/(2H)) Sum_mu Psibar {gamma^mu, Gamma_mu} Psi identically, and {gamma^mu, Gamma_mu} == 0 for EACH mu on the canonical frame: Lsym == Lsym_d`.

This is **not** Part VI's mechanism. For the real commuting field, `Psi^T sigma16 gamma^mu Gamma_mu Psi`
vanishes because `sigma16 T16[0]` is antisymmetric (subsection 3.8.10). For a complex field,
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

##### 3.8.12.3 It enters the field equation as `-3 H Cot^2 T16[0]`, and the rescaling removes it

Varying `Psibar` and `Psi` independently in the symmetrized action gives the field equation and
its conjugate:

```
gamma^mu D_mu Psi = H V'(s) Psi                  (D_mu Psibar) gamma^mu = -H V'(s) Psibar
```

**[proved VII §27]** `FIELD EQUATION [THE RESULT]: EL_Psibar == (Sqrt[g]/H)(gamma^mu D_mu Psi - H V'(s) Psi) for generic Psi, Psibar of all eight coordinates: the field equation is gamma^mu D_mu Psi == H V'(s) Psi`, `FIELD EQUATION [THE RESULT]: EL_Psi == -(Sqrt[g]/H)((D_mu Psibar) gamma^mu + H V'(s) Psibar): the adjoint equation is (D_mu Psibar) gamma^mu == -H V'(s) Psibar`.
For the real field of Part VI the same equation is **[proved VI §24]**
`"FABLE [THE RESULT]: EL == Sqrt[g] (2/H) sigma16 . ( gamma^mu D_mu Psi - H V'(s) Psi ): the field equation of fable is EXACTLY the Levi-Civita covariant Dirac equation  gamma^mu D_mu Psi == H V'(s) Psi"`.

On the canonical frame the connection enters as follows **[derived here, from subsection 3.8.8]**. In the
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

**The frame-independent form.** Covariant constancy of `gamma^mu` (subsection 3.8.8) together with a
vanishing `Sum_mu {gamma^mu, Gamma_mu}` gives, for any frame on which that anticommutator
vanishes,

```
gamma^mu Gamma_mu = (1/2) (1/Sqrt[g]) d_mu( Sqrt[g] gamma^mu ) = -(1/2) T_mu gamma^mu,
T_mu = d_mu ln( e_mu^mu / det e )      (no sum; the Weitzenboeck torsion vector of a diagonal frame)
```

The second equality is a one-line computation for a diagonal frame, since `Sqrt[g] = det e` and
`gamma^mu = T16[mu]/e_mu^mu` **[derived here]**. This links the canonical connection directly to
the fable-5.1 bridge: the connection term of the Dirac operator is the Weitzenböck torsion vector.
On the canonical frame `T_mu = d_mu ln Sin[6Hx0]` (subsection 3.8.10), and the rescaling by
`Exp[(1/2) ln Sin] = Sqrt[Sin[6Hx0]]` removes it. **[proved VII §27]** `SPIN CONNECTION [has content]: Part V restated -- omega^W == 0 in the canonical frame, omega^LC == -contortion, T_mu == d_mu Log[Sin[6 H x0]], R == -T + B, and gamma^mu Gamma_mu == -(1/2) T_mu gamma^mu` (on the canonical frame); and on the time-dependent warped frames of the coupled system, Part VIII, Section 32: `WEITZENBOECK [THE RESULT]: the torsion vector of the warped frame is a GRADIENT, T_mu == d_mu Log[Sin[6 H x0]/(A^3 B^3 C)]; on the canonical member it is Part V's torsionVectorFable51`, `WEITZENBOECK [THE RESULT]: gamma^mu Gamma_mu == -(1/2) T_mu gamma^mu on the warped frame -- one vector term, a gradient`.

##### 3.8.12.4 It enters neither the canonical anticommutator nor the symmetrized Hamiltonian density

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
**[derived here]**. `J` is the fundamental symmetry of subsection 3.8.12.6.

The Hamiltonian density of the symmetrized Lagrangian is

```
Hdens = Sqrt[g] [ -(1/(2H)) Sum_{k != 4} ( Psibar gamma^k d_k Psi - d_k Psibar gamma^k Psi ) + V(s) ]
```

and it contains **no spin connection** **[proved VII §28]** `HAMILTONIAN [THE RESULT]: the Hamiltonian density Pi_Psi d_4 Psi + d_4 Psibar Pi_Psibar - L of the symmetrized Lagrangian is Sqrt[g][-(1/(2H)) Sum_{k != 4}(Psibar gamma^k d_k Psi - d_k Psibar gamma^k Psi) + V]: NO spin connection (fields of all eight coordinates)`.
This follows from 9.12.2: the symmetrized `Lhat` does not depend on the connection. The connection
re-emerges in the equation of motion. Integrating the symmetrized spatial derivative terms by
parts produces
`gamma^mu Gamma_mu = (1/2)(1/Sqrt[g]) d_mu( Sqrt[g] gamma^mu )` (subsection 3.8.12.3), because the
volume factor and the curved gammas depend on `x0`. **[proved VII §28]** `HAMILTONIAN [THE RESULT]: (Sqrt[g]/H) sigma16 (gamma^mu D_mu Psi - H V' Psi) == i Gtilde d_4 Psi - h Psi for admissible Psi(x0..x4): the field equation is i Gtilde d_4 Psi = h Psi`, `HAMILTONIAN [THE RESULT]: (1/2) Sum_{mu != 4} d_mu(Sqrt[g] sigma16 gamma^mu) == Sqrt[g] sigma16 Sum gamma^mu Gamma_mu, and d_4(Sqrt[g] sigma16 gamma^4) == 0: the connection term is the one that makes h Hermitian`.

The same rescaling organizes the one-particle space. `Sqrt[g] dx0 |Psi|^2 = |Psi'|^2 dz` for
`Psi' = Psi / Sqrt[Sin[6Hx0]]`, where `z = -Log[Cos[6Hx0]]/(6H)` is proper distance along `x0`. So the
one-particle space of `Psi'` is `L^2(dz)`. The `x0`-operator is regular at the wall `z = 0` and
needs a boundary condition there. The Lorentz-covariant, `J`-compatible ones are
`T16[0] Psi' = +-Psi'` at `z = 0`. It is limit-point at `z -> infinity`, where no condition is
needed. **[proved VII §28]** `BOUNDARY [has content]: the x0 direction in proper distance z = -Log[Cos[6 H x0]]/(6 H): dz/dx0 == Tan[6Hx0] == Sec Sin (so Sqrt[g] dx0 |Psi|^2 = |Psi'|^2 dz), z(0) == 0 and z -> infinity at 6 H x0 -> Pi/2, gamma^0 d_0 == T16[0] d_z, and Sin[6Hx0] == Sqrt[1 - Exp[-12 H z]] (bounded frame factors)`, `BOUNDARY [THE RESULT]: the bag condition T16[0] Psi' = +-Psi' at the wall -- T16[0]^2 == 1, {beta, T16[0]} == 0, the normal-flux form vanishes on both eigenspaces (P beta T16[0] P == 0), and [J, T16[0]] == 0`.

##### 3.8.12.5 It does not drop out of the energy–momentum tensor

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
- **[proved VII §29]** the piece coming from the variation of the spin connection is zero, `EMT [has content]: the spin-connection variation contributes NOTHING -- dropping it leaves the Hilbert tensor unchanged at (x1,x4), (x0,x5), (x5,x4)`. The Lagrangian depends on the connection only through `Sum_mu {gamma^mu, Gamma_mu} = (1/2) omega_[cab] gamma^{cab}` (subsection 3.8.8), and under a symmetric variation of the tetrad `delta omega_[cab] = 0`. So the spin-connection variation contributes **exactly nothing**. The covariant terms of `That` come from the dependence of `{gamma^mu, Gamma_mu}` on the frame. A partial-derivative Lagrangian must never be varied with respect to the frame. (Part VI's Text cell described this contribution as "a term antisymmetric in mu, nu that drops from the symmetrised tensor". The statement above is the sharper one.)
- **[proved VII §29]** Hilbert `!=` `T_par`, witnessed on the non-vacuous pair `(x1, x4)` (the pairs `(0,4)` and `(5,6)` coincide on the canonical frame, as shown above), `EMT [control]: the Hilbert tensor is NOT the partial-derivative tensor: at (x1,x4) they differ -- witnessed on constant spinors (Psibar = e1, Psi = e11: (T16[4] T16[1] T16[0])_{1,11} != 0)`.
- **[proved VII §29]** `T_cov` is conserved on shell, `EMT CONSERVATION [THE RESULT]: nabla^mu That_{mu nu} == 0 ON SHELL in all eight components, for generic Psi(x0, x4), Psibar(x0, x4) and generic V`.

The real-field analogues are already proved. **[proved VI §24]** `"FABLE [definition]: T_cov is symmetric by construction"`.
**[proved VI §24]** `"FABLE [has content]: the diagonal of T_cov equals the diagonal of the partial-derivative tensor, for the generic Psi(x0, x4): rho and every pressure are the same in both"`.
**[proved VI §24]** `"FABLE [has content]: but the two tensors DIFFER off the diagonal -- witnessed on the (x3, x4) component T[[4,5]], a momentum density along the observed sheet, for the constant spinor e1 + e13 and V = s^2"`.
**[proved VI §24]** `"FABLE [THE RESULT]: nabla^mu T_{mu nu} == 0 ON SHELL in all eight components, for a generic Psi(x0, x4) -- the covariant tensor is the conserved one"`.
That only the covariant tensor is conserved, and `T_par` is not, is **[prose VI §24]**: the
divergence of `T_par` is not computed symbolically.

##### 3.8.12.6 The connection and the fundamental symmetry `J`

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
`Gamma_mu` of subsection 3.8.7:

| object | relation to `J` | reason |
|---|---|---|
| `Gamma_0 = Gamma_4 = 0` | commute | zero |
| `Gamma_j` (`j = 1,2,3`) | **commute** | made of `T16[0].T16[j]`, `T16[4].T16[j]`, all factors in `{0..4}` |
| `Gamma_k` (`k = 5,6,7`) | **anticommute** | made of `T16[0].T16[k]`, `T16[4].T16[k]`: one factor in `{0..4}`, one in `{5,6,7}` |
| each `gamma^mu Gamma_mu` (no sum), and their sum | **commute** | each is `alpha_mu T16[0] + beta_mu T16[4]` (subsection 3.8.8) |

The hidden components `Gamma_5`, `Gamma_6` and `Gamma_7` are `J`-odd. They enter the Dirac
operator only through `gamma^k Gamma_k`, a product of two `J`-odd matrices, which is `J`-even. So
every term of the admissible-sector Hamiltonian, the connection term included, is `J`-even.
The `J`-odd objects, namely the `(0,h)`, `(i,h)` and `(4,h)` components of `T_cov` and the hidden
momenta `P_h` (`h = 5,6,7`), are nonzero operators with zero expectation in `J`-eigenmode Fock
states. **[proved VII §28]** `J TABLE [THE RESULT]: J commutes with sigma16, T16[0..4], sigma16 gamma^mu (mu = 0..4), every gamma^mu Gamma_mu and Gamma_1..Gamma_3; it ANTIcommutes with T16[5..7], sigma16 gamma^h (h = 5..7), Gamma_5..Gamma_7, T16[8] and C+`. The same `J` table holds on the dynamical
(warped and Bianchi-I) frames of the coupled system. Part VIII, Section 32, proves it:
`J [THE RESULT]: [J, gamma^mu Gamma_mu] == 0 for EACH mu separately (h = 5,6,7 included), on the warped and on the Bianchi-I frame`, `J [THE RESULT]: [J, Gamma_mu] == 0 for mu = 0..4 and {J, Gamma_h} == 0 for h = 5, 6, 7, on the warped and on the Bianchi-I frame` and
`J [has content]: the anticommuting Gamma_h are not zero (witnessed on A = 1 + x4/2, B = 1 + x4/3, C = 1 + x4^2/3), so {J, Gamma_h} == 0 is not vacuous`.

#### 3.8.13 Status ledger

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

### 3.9 How it was verified

#### 3.9.1 Part VII of the notebook: sections, cells, assertions

Part VII is the manifest `claude-fable/cells_part7.wl` (1777 lines; 170 `cfAssert` calls). Built into
the notebook by `claude-fable/build_tools.py` (section 6.3.1), it adds 26 Input cells, 173–198, to the
172 of Parts I–VI. The section-to-cell map is printed by `claude-fable/nb_section_map.wls`
(`claude-fable/nb_section_map.log`, section 6.3.3):

| notebook Section | subject | Input cells | assertions | seconds (sum of the cells' times) | this document |
|---|---|---|---|---|---|
| 26 | the refinement: why fermion fable is a complex 16-spinor | 173–179 | 38 | 1.957 | 3.2 |
| 27 | the Lagrangian, the field equations in the primordial gravitational field, and the canonical spin connection | 180–184 | 36 | 2.291 | 3.3, 3.4, 3.8 |
| 28 | canonical quantization in 4+4 dimensions: the Dirac bracket, the Krein structure `J`, and the admissible sector | 185–191 | 56 | 12.311 | 3.5 |
| 29 | the energy–momentum tensor operator: definition, conservation, and `rho`, `P` and `w` | 192–198 | 40 | 17.874 | 3.6, 3.7 |
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

#### 3.9.2 Every Part VII assertion, verbatim

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

#### 3.9.3 The same assertions in the full run of Parts I–VIII

After Part VIII (the coupled system, notebook Sections 30–33) was added, the whole notebook was run
again (`claude-fable/run_fermion_fable_part8.log`). The Part VII lines of that log are identical to
those of the Part VII log apart from the timing lines [checked for the provenance pages of 2026-09-24 with `diff` on the two
logs, the `CELL` and `[t s]` lines removed]. The Part VII cells took 29.706 s in that run. Its
summary:

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

**The final run** (commit `1671155`, `claude-fable/run_fermion_fable_final.log`) was made after the
fable-cosmology notebook 06 had written the Rust solver's CSVs `results/nb06_fable4d_mass30eV.csv` and
`nb06_fable4d_power.csv`, so that Part VIII's two conditional comparisons with them ran (in the
Part VIII log they had been skipped, not failed). Its Part VII lines are identical to those of the
Part VII log apart from the cells' timing lines [checked while writing this document, with `diff` on the two logs,
from the line that closes cell 172 to the line that closes cell 198]; the Part VII cells took
28.435 s and the Part VIII cells 22.932 s [summed from its `CELL n  t=...` lines]. Its last Part VII
tally is still `Assertions run: 528   passed: 528   failed: 0` (line 843), and it ends with
`identities accepted on numerical evidence alone : 0   (stage 3 returned True)`,
`non-vanishing witnesses                         : 46`,
`Assertions run: 644   passed: 644   failed: 0` and the summary

```
==================== RUN SUMMARY ====================
cells evaluated : 217
total seconds   : 208.715
cells w/ msgs   : 0
---- slowest cells ----
  cell 80  69.797 s
  cell 88  22.871 s
  cell 204  9.939 s
  cell 191  8.828 s
  cell 86  8.339 s
  cell 87  7.361 s
  cell 137  7.359 s
  cell 121  4.840 s
  cell 196  3.848 s
  cell 160  3.824 s
  cell 107  3.789 s
  cell 193  3.062 s
==================== ASSERTIONS ====================
assertions run  : 644
passed          : 644
FAILED          : 0
====================================================
```

It has no `RUN-DONE` line (that line of the earlier logs was appended by the wrapper that ran them).
Its 644 `PASS` labels are the 642 of the Part VIII log, identical, plus the two comparisons with the
Rust CSVs (section 4.7.12).

#### 3.9.4 The design review, and every correction it made to Effort A

The design (revision 1) was reviewed by four adversarial reviewers — quantization (findings `QK-*`);
field equations, energy–momentum tensor and spin connection (`EMT-*`); Einstein equations and
cosmology (`E-*`); density-functional theory and numerics (`DFT-*`) — each followed by an
independent skeptic who tried to refute each finding. **No finding was refuted.** Several were
confirmed only in part, and then the corrected fix was adopted. The review records are working
documents and are not part of the repository; every adopted correction that concerns Effort A is
restated here, with where it now lives. Section 5 of this document lists every finding of all four
lenses, Efforts A and B together, with its verdict and the correction adopted.

| design item | findings | what revision 1 said, or lacked | what was adopted | where in this document (notebook) |
|---|---|---|---|---|
| refinement | QK-7 | "fermion fable must be complex" without scope; F2(a) only on the flat frame | the invariant forms are exactly `span{sigma16, sigma16 T16[8]}`; Majorana has one quartic scalar and no commuting kinetic shadow; Weyl/Majorana–Weyl cannot propagate; the complex spinor is the **minimal**, not the unique, field; F2(a) holds on **every** frame | 3.2.2, 3.2.4, 3.2.8 (`REFINEMENT (a)`, `(b)`) |
| Lagrangian | QK-4 (corrected), EMT-5 | several Lagrangians used interchangeably; Part VI's drop-out mechanism assumed to carry over | only the symmetrized covariant Lagrangian; the unsymmetrized partial one is inadmissible (its two equations are not conjugate); the drop-out is a property of the matrix `{gamma^mu, Gamma_mu}`, per `mu`, on diagonal frames only | 3.3 (`LAGRANGIAN (a)–(f)`) |
| field equations | EMT-9, EMT-11 | 8+8 form sketched; operator ordering "normal-ordered or Weyl"; `x4`-only solutions assumed | the 8+8 form with the conjugate rows; the axial phase is not a symmetry; the ordering rule with its scalar and `gamma^4` contraction parts; the `x4`-only family needs `V'' s' = 0`, and `s'` is conserved | 3.4.3, 3.4.8, 3.4.9, 3.4.11 |
| quantization: truncation | QK-2 | "physical states obey `P_5 = P_6 = P_7 = 0`" (a superselection rule) and Tomonaga–Schwinger integrability | a **truncation** with finite `V_hid` (closed timelike curves stated); anticommutator with `H/(V_hid Sqrt[\|g\|])` and `delta^4`; only `[P_4, P_h] = 0` kept | 3.5.4, 3.5.10 |
| quantization: theorem | QK-1 (corrected) | admissibility asserted from one example | the theorem: positive quantization iff the momentum span is spacelike-definite, with items (1)–(7) (threshold Jordan block, `G`-neutral modes above threshold, traceless certificate, uniqueness) | 3.5.10 (`ADMISSIBILITY`) |
| quantization: `J` | QK-5 (corrected), plus the missed basis point | Krein prescription `b^dagger := eta b^ddag`, basis unspecified; reflection positivity claimed | `J = −i Omega4 T16[0]`, `sigma16 = J beta`, flavour metric `(2,2)`; the adjoint `Psi^dagger := Psi^ddag J` is mode-independent and **requires a `J`-eigenmode basis** (control: a Krein boost breaks Hermiticity of `s`); why it fails for bosons; reflection positivity **dropped** | 3.5.5, 3.5.6, 3.5.13 (`J`, `KREIN MODES [control]`) |
| quantization: other | QK-6, QK-8, QK-9, QK-10, QK-11, EMT-2 | symmetry count, dynamical frames, wall condition, current sign and `J`-connection relation incomplete or wrong | 13 kept / 15 lost generators, `G` invariant under Spin(4,3); `chi = (Sqrt[g]/H)^(1/2) Psi`; one-particle space `L^2(dz)`, regular at the wall, limit-point at infinity, bag condition `T16[0] Psi' = ±Psi'`; `n^mu = −(i/H) Psibar gamma^mu Psi`; the `J` table with `Gamma_5..7` anticommuting | 3.5.9, 3.5.12, 3.5.15, 3.5.16, 3.5.8 |
| EMT | EMT-1, EMT-3, EMT-4, EMT-8, QK-3 | EMT stated without derivation; conservation "for independent `Psi`, `Psibar`" without scope; "`<:T:> = 0` in the vacuum" | Hilbert = `T_cov` off shell; spin-connection variation exactly zero; Hilbert `!=` `T_par` (witness at a non-vacuous pair); why the commuting proxy proves conservation; the `J`-parity table; the vacuum statement only for static backgrounds; do not run the symbolic divergence of `T_par` | 3.6 (`EMT`, `EMT CONSERVATION`, `EMT HERMITICITY`), 3.7.3 |
| expectation values | DFT-5, DFT-6, DFT-12, DFT-15, DFT-4 | classical limit "`k_F -> 0` at fixed `n`" (impossible) or a coherent zero mode; unstable closed forms; phantom crossing not examined; sea energy only for constant `m` | the classical limit is the **non-relativistic** limit, with the sign rule; the numerically stable forms; `w_f >= −1` (no phantom crossing); the pair-excitation thresholds (`w_F + \|m\|` at `q = k_F`, `2 w_F` at `q = 0`; not asserted in Part VII); `DeltaE_vac` for mass-varying `W` | 3.7.5, 3.7.7, 3.7.9, 3.7.3 |
| spin connection | EMT-6, EMT-10 | "the connection enters the Hamiltonian" | it enters **neither** the anticommutator **nor** the Hamiltonian density; it re-emerges in the equation of motion as the term that makes `h` Hermitian; `gamma^mu Gamma_mu = −(1/2) T_mu gamma^mu` (the Weitzenböck torsion vector) | 3.5.11, 3.8.12.3, 3.8.12.4 |

Two of these adopted corrections are also stated in Part VII's own Text cells: the
Hamiltonian-density correction (EMT-6; "This corrects the design's 'it enters the Hamiltonian'",
Section 28), and the identification of the classical limit with the non-relativistic one (DFT-5;
Section 29). One numerical slip in the review's vacuum-energy figures is
corrected in this document (section 3.7.3).

#### 3.9.5 The Fock check

The finite Fock space of section 3.5.14 is the independent check of the quantization: it realizes
the Dirac-bracket anticommutator on a positive Hilbert space of dimension `2^16 = 65536`, with exact
integer sparse matrices, and confirms the sign of the anticommutator through the Heisenberg
equation (the opposite sign gives the time-reversed equation). It shows the unique Dirac-sea ground
state at `−40`, the 16-fold first excited level (8 particles, 8 antiparticles), the negative Krein
"norms" that the `J`-involution removes, and the expectation rule used for `rho`, `P` and `sigma`.
Twelve assertions (`FOCK`, `CHARGE`), Input cell 191, 9.858 s.

#### 3.9.6 The TeX export

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
`.txt` files are quoted verbatim in sections 3.4, 3.5 and 3.7 of this document; the `.tex` files are
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

## 4. Effort B: the interacting system — fermion fable as the source of the primordial gravitational field, the solution from the beginning of the present universe to today, and the answers to [1] and [2]

The quantized fermion fable of section 3 is put into the Einstein equations of the author's
primordial gravitational field as their source. The Einstein tensor of the author's canonical frame
is computed in full, with the free function `a4` never given a value, and what it demands of any
source is proved. The frame is generalized to a family on which fable can act back; its asymptotic
region is an 8-dimensional Bianchi-I universe. The canonical spin connection of that interacting
system is computed and discussed completely. The fable's energy–momentum tensor operator is evaluated
in its Kohn–Sham ground state, and the coupled equations are solved from before nucleosynthesis to
today, three times independently (Rust/CVODE, Python/scipy, Mathematica/`NDSolve`). Ideas of
density-functional theory give the fable's ground and first excited states: in the homogeneous gas
and in the discrete states bound along the hidden coordinate `x0`. The author's two questions — [1] a
time-varying dark-energy equation of state, [2] a time-varying dark-matter equation of state — are
answered directly and quantitatively, with every caveat (section 4.8).

**How this section was made.** It is copied section by section, by a script, from the provenance
record of Effort B (written on 2026-09-24 at 23:26 PDT and fact-checked against the logs), with its
sections renumbered 4.1–4.8 and its cross-references renumbered to match this page. Two of that
record's sections are not repeated because they are word for word the same as sections of Effort A
already on this page: its foundations are section 3.1, and the first thirteen subsections of its
spin-connection discussion (the canonical spin connection) are sections 3.8.1–3.8.13; its
cross-references to them point there. Three things were brought up to date, because they changed
after that record was written, and each change is marked where it is made: (i) notebook 07 has since
been executed and committed (`aca5102`), so every wall-state number it prints again now carries the
mark **[nb07 §n]**, and the few it does not print are named; (ii) the derivation of the wall problem
was re-run when its output `waveguide_T16.json` was committed, so its log's timing changed; (iii)
notebook 06 was re-executed on the final solver of `2bc936d` before it was committed, so its refusal
message for the repulsive quadratic is now the bisected one. Every other number is as it was quoted,
and every one of them was checked again, for this page, against the committed notebooks 05–07, their
result files, the wall-state report and the notebook's run logs.

**The work of Effort B, in the order it was done.**

1. A design (revision 1) was written for the whole of 2026-09-24's work. Four adversarial
   reviewers examined it — quantization; field equations, energy–momentum tensor and spin
   connection; Einstein equations and cosmology (findings `E-*`); density-functional theory and
   numerics (findings `DFT-*`) — each followed by an independent skeptic. No finding was refuted
   as a whole; several were confirmed only in part, and the corrected fix was adopted. Every adopted
   correction that concerns Effort B is stated where it applies below, and all of them are listed in
   section 5.
2. The solver `fable-cosmology/rust/fable_fermion` was written on the vendored pure-Rust SUNDIALS
   7.8.0 CVODE of the rustSolveIt repositories, with the independent Python check
   `fable-cosmology/fermion/crosscheck.py` (commit `c5892bd`).
3. Part VIII of the Mathematica notebook (Sections 30–33, manifest `claude-fable/cells_part8.wl`)
   proves the symbolic side: the Einstein tensor, the three theorems, the generalized frame, the
   Bianchi-I system, the spin connection of the interacting system, and the coupled equations for
   the Kohn–Sham fluid, and it solves two reference cases with `NDSolve` (commit `bc04ed1`).
4. The wall-state solver `fable-cosmology/fermion/waveguide.py`, its symbolic derivation and its
   Mathematica check compute the discrete states along `x0` and their density-functional
   treatment (commit `18a2501`).
5. Notebooks 05 and 06 ran the solver on every case and exposed six solver defects, which were
   fixed (commit `2bc936d`, section 5.8, item 4).
6. The fable-cosmology notebooks `05_fermion_fable_quantum_eos.ipynb`,
   `06_fable_primordial_gravity_8d.ipynb` and `07_fable_dft_states.ipynb` were executed on the final
   solver; they run every case, re-compute every run independently, reproduce the wall states, and
   state the answers (commit `aca5102`).
7. The whole notebook was run once more, now with the Rust solver's CSVs present, so that Part VIII's
   comparison with the Rust solver also ran: 644/644 (commit `1671155`).

**The evidence marks of this section** are those of the head of this page. The marks **[VIII]** and
**[proved VIII §n]** quote Part VIII's labels verbatim from `claude-fable/run_fermion_fable_part8.log`,
which reports `Assertions run: 642   passed: 642   failed: 0` for Parts I–VIII together; the final run
`claude-fable/run_fermion_fable_final.log` prints the same 642 labels identically and two more (the
comparison with the Rust CSVs, section 4.7.12), `Assertions run: 644   passed: 644   failed: 0`. The
Part VIII labels were spliced into the record of Effort B by a script from that log, not retyped.

---

### 4.1 The fermion fable in brief

This section restates, complete enough to be read alone, the quantized fermion fable that is the
source of the Einstein equations in the rest of section 4: the field, its Lagrangian, its field
equations in the primordial gravitational field, its canonical anticommutator, its
energy–momentum tensor operator, and its density, pressures and equation of state. Everything
here is proved in Part VII of the notebook (Sections 26–29, manifest `claude-fable/cells_part7.wl`,
Input cells 173–198, 170 assertions); the labels are quoted verbatim from
`claude-fable/run_fermion_fable_part7.log`, whose tally reads
`Assertions run: 528   passed: 528   failed: 0` for Parts I–VII together. Section 3.1.13 gave the
algebraic reasons (F1, F2) for the refinement; this section states the results.

#### 4.1.1 The field

Fermion fable is a **complex 16-component Grassmann spinor** `Psi`, two real Grassmann 16-spinors
`theta1`, `theta2` combined as `Psi = (theta1 + i theta2)/Sqrt[2]`, with the classical conjugate
`Psi^ddag = (theta1 − i theta2)^T/Sqrt[2]` and the Dirac conjugate

```
Psibar = Psi^ddag sigma16,        sigma16 = T16[0].T16[1].T16[2].T16[3] = diag(-sigma, sigma)
```

It has two Lorentz-scalar bilinears, `s = Psibar Psi` and `p = Psibar T16[8] Psi`; the
self-interaction depends on `s` only (3.4). Written as `Psi = (psi1, psi2)` (upper eight components
the type-1 split-octonion spinor of chirality −1, lower eight the type-2 spinor of chirality +1),
`s = −psi1^ddag sigma psi1 + psi2^ddag sigma psi2`.

**Why complex, and with what scope.** The Spin(4,4)-invariant bilinear forms on the 16-spinor are
exactly `span{sigma16, sigma16 T16[8]}`, both symmetric and chirality-diagonal. Therefore a real
Grassmann 16-spinor with the author's `sigma16` has no dynamics on any frame (its mass term vanishes
and its kinetic term is a total derivative), a Majorana 16-spinor built with `C+ = sigma16 T16[8]`
propagates but is massless and has no `V(s)`, and a one-chirality (Weyl or Majorana–Weyl) spinor
cannot propagate. The complex 16-spinor is the **minimal** field that uses the author's `sigma16`
conjugation, propagates, admits `V(s)`, and reduces to Part VI's classical fable as its real
commuting shadow; it is **not** the unique field with dynamics. The author chose it on
2026-09-24. **[proved VII §26]**
`REFINEMENT [THE RESULT]: the Spin(4,4)-invariant bilinear forms on the 16-spinor form a 2-dimensional space, spanned by C- = sigma16 and C+ = sigma16 T16[8]`,
`REFINEMENT (a) [THE RESULT]: real Grassmann + sigma16: both invariant mass terms vanish, and theta^T sigma16 T16[a] phi == (1/2) d(theta^T sigma16 T16[a] theta) for every a (a total derivative)`,
`REFINEMENT (b) [THE RESULT]: Majorana with C+: the kinetic term is genuine -- Euler-Lagrange expression 2 C+ T16[a] phi with C+ T16[a] invertible -- but every invariant bilinear vanishes (massless, no V(s))`,
`REFINEMENT (c) [THE RESULT]: Weyl and Majorana-Weyl: PL C T16[a] PL == PR C T16[a] PR == 0 for C = C-, C+ and every a (C chirality-diagonal, T16[a] chirality-odd) -- no kinetic term`,
`REFINEMENT (d) [THE RESULT]: s = Psibar Psi == i theta1^T sigma16 theta2: NON-ZERO (16 monomials) and HERMITIAN; p = Psibar T16[8] Psi is non-zero and Hermitian too`.

**Four four-dimensional Dirac fermions.** The observer's Clifford algebra `T16[1..4]` is
`M4(C)`; its commutant in `M16(C)` is generated by the hidden gammas
`h_A = Omega4 T16[A]` (`A = 0, 5, 6, 7`, `Omega4 = T16[1].T16[2].T16[3].T16[4]`). So
`C^16 = C^4 (observer Dirac index) (x) C^4 (hidden flavour index)`: under the observer's Spin(3,1)
of `x1, x2, x3, x4` fermion fable is four Dirac fermions, `g = 4 × 2 = 8` particle states (and 8
antiparticle states) per momentum. **[proved VII §26]**
`4D [THE RESULT]: the 16 products of the hidden gammas span the commutant, and the two algebras meet only in the multiples of ID16 (rank of the union 16 + 16 - 1 = 31): C^16 = C^4 (x) C^4, four 4D Dirac fermions`.

**Fidelity.** In the real commuting limit (`Psi -> psi`, `Psibar -> psi^T sigma16`) the Lagrangian,
the field equations and the energy–momentum tensor below become Part VI's classical fable exactly
(section 3.1.12), and through it the author's `La` and `eLa` (sections 3.1.7, 3.1.8). **[proved VII §26]**
`FIDELITY [1] [fidelity]: Psi -> psi, Psibar -> psi^T sigma16 turns the symmetrized covariant Lhat into Part VI's cfLhatFable EXACTLY (canonical frame, generic V)`, `FIDELITY [2] [fidelity]: on the flat frame with V = -(2M/H) s and no volume factor, the same limit on Psi16 IS the author's La[] of Section 11`,
`FIDELITY [4] [fidelity]: the energy-momentum tensor That in the real limit IS Part VI's covariant tensor cfTCov, all 64 components`.

#### 4.1.2 The Lagrangian

The only admissible Lagrangian is the **symmetrized covariant** one:

```
L = Sqrt[g] Lhat,       Lhat = (1/(2H)) [ Psibar gamma^mu D_mu Psi - (D_mu Psibar) gamma^mu Psi ] - V(s),       s = Psibar Psi
D_mu Psi = d_mu Psi + Gamma_mu Psi,        D_mu Psibar = d_mu Psibar - Psibar Gamma_mu
```

with `Gamma_mu` the canonical spin connection of section 4.4 (on the dynamical frames of this document,
the connection of those frames, section 4.4.1 onwards). There is no factor `i`, as in the author's
`La`: the Lagrangian is Hermitian because `sigma16 gamma^a` and `sigma16 Gamma_mu` are real
antisymmetric matrices. It contains the connection only through the matrix
`Sum_mu {gamma^mu, Gamma_mu}`, which vanishes for **each** `mu` on the canonical frame (and on the
warped and Bianchi-I frames of this document, section 4.4.4), so there it equals the partial-derivative
symmetrized Lagrangian. The unsymmetrized covariant Lagrangian differs from it by a total
divergence; the unsymmetrized *partial* Lagrangian is inadmissible (its two field equations are not
Dirac conjugates). **[proved VII §27]**
`LAGRANGIAN (b) [THE RESULT]: Lsym is HERMITIAN -- real for Psi = u + i v, Psibar = (u - i v)^T sigma16, generic u, v of all eight coordinates`,
`LAGRANGIAN (c) [THE RESULT]: Lsym - Lsym_d == (1/(2H)) Sum_mu Psibar {gamma^mu, Gamma_mu} Psi identically, and {gamma^mu, Gamma_mu} == 0 for EACH mu on the canonical frame: Lsym == Lsym_d`,
`LAGRANGIAN (f) [control]: so Lun_d is INADMISSIBLE -- its two field equations are not Dirac conjugates: they differ by 2 Psibar gamma^mu Gamma_mu = -6 H Cot^2 Psibar T16[0], non-zero (witness u = e1, v = 0, V = s^2)`.

#### 4.1.3 The field equations in the primordial gravitational field

Varying `Psibar` and `Psi` independently:

```
gamma^mu D_mu Psi  ==  H V'(s) Psi                  (D_mu Psibar) gamma^mu  ==  -H V'(s) Psibar
```

**[proved VII §27]** `FIELD EQUATION [THE RESULT]: EL_Psibar == (Sqrt[g]/H)(gamma^mu D_mu Psi - H V'(s) Psi) for generic Psi, Psibar of all eight coordinates: the field equation is gamma^mu D_mu Psi == H V'(s) Psi`,
`FIELD EQUATION [THE RESULT]: EL_Psi == -(Sqrt[g]/H)((D_mu Psibar) gamma^mu + H V'(s) Psibar): the adjoint equation is (D_mu Psibar) gamma^mu == -H V'(s) Psibar`,
`FIELD EQUATION [has content]: the adjoint equation IS the Dirac conjugate of the field equation: with Psi = u + i v, Psibar = (u - i v)^T sigma16, adjoint residual == -(field residual)^* . sigma16`.

On the author's canonical frame (section 3.1.11; `q = Exp[-a4[H x4]]/Sin[6 H x0]^(1/6)`,
`p = Exp[+a4[H x4]]/Sin[6 H x0]^(1/6)`, `a4` free; this `p` is the frame factor, not the bilinear of 3.1), with `gamma^mu Gamma_mu = −3 H Cot[6 H x0]^2 T16[0]`
(section 3.8.8), summed over `i = 1,2,3` and `h = 5,6,7`:

```
Cot[6Hx0] T16[0] d_0 Psi + (1/q) Sum_i T16[i] d_i Psi + T16[4] d_4 Psi + (1/p) Sum_h T16[h] d_h Psi - 3 H Cot[6Hx0]^2 T16[0] Psi  ==  H V'(s) Psi
```

**[proved VII §27]** `WRITTEN OUT (i) [THE RESULT]: the field equation on the canonical frame is Cot T16[0] d_0 Psi + (1/q) T16[i] d_i Psi + T16[4] d_4 Psi + (1/p) T16[h] d_h Psi - 3 H Cot^2 T16[0] Psi == H V'(s) Psi`.
In the split-octonion 8+8 form, covariantly on any frame (`Gamma_mu = diag(Gamma^(1)_mu, Gamma^(2)_mu)`,
the connection never mixes the two types):

```
e_a^mu taubar[a] (d_mu + Gamma^(2)_mu) psi2  =  H V'(s) psi1        e_a^mu tau[a] (d_mu + Gamma^(1)_mu) psi1  =  H V'(s) psi2
(d_mu psibar2 - psibar2 Gamma^(2)_mu) tau[a] e_a^mu  =  -H V'(s) psibar1        (d_mu psibar1 - psibar1 Gamma^(1)_mu) taubar[a] e_a^mu  =  -H V'(s) psibar2
psibar1 = -psi1^ddag sigma,   psibar2 = psi2^ddag sigma
```

and on the canonical frame the connection term is `−3 H Cot^2 psi2` in the upper and `−3 H Cot^2 psi1`
in the lower rows. **[proved VII §27]** `WRITTEN OUT (ii) [THE RESULT]: the covariant 8+8 form -- rows 1..8 are e_a^mu taubar[a] (d_mu + Gamma^(2)_mu) psi2 - H V' psi1, rows 9..16 are e_a^mu tau[a] (d_mu + Gamma^(1)_mu) psi1 - H V' psi2; and the conjugate rows`.

**All sixteen component equations on the canonical frame**, verbatim from the notebook's text
export `provenance-latex/generated/fermion_fable_field_equations.txt` (written by
`claude-fable/export_fermion_fable_tex.wls` from the asserted term lists; `psi_k` is component `k` of
`Psi`, `d_mu psi_k = ∂psi_k/∂x_mu`, `E^a4[H*x4]` is `e^{a4(H x4)}`, `V'[s]` is `V'(s)` at `s = Psibar Psi`):

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

The sixteen adjoint equations `Ebar_r` (`provenance-latex/generated/fermion_fable_adjoint_equations.txt`)
contain, for each `r`, the same eight (direction, component) pairs with `psibar_k` in place of `psi_k`:
the terms along the spacelike directions `x0..x3` have the same sign, those along the timelike
directions `x4..x7` the opposite sign, the connection term `−3 H Cot^2` is the same, and the `V'` term
changes sign (`T16[a]^T = eta_aa T16[a]`). **[proved VII §27]**
`WRITTEN OUT (iii) [definition]: the term lists reproduce all sixteen field equations and all sixteen adjoint equations exactly`.

**The rescaled form.** `Psi = Sqrt[Sin[6 H x0]] Psi'` removes the connection term exactly, because
`gamma^mu Gamma_mu = −(1/2) T_mu gamma^mu` with the gradient Weitzenböck torsion vector
`T_mu = d_mu Log[Sin[6 H x0]]`:
`gamma^mu D_mu Psi − H V'(s) Psi = Sqrt[Sin] (gamma^mu d_mu Psi' − H V'(Sin s') Psi')`, `s = Sin[6 H x0] s'`.
**[proved VII §27]** `WRITTEN OUT (iv) [THE RESULT]: Psi = Sqrt[Sin[6Hx0]] Psi' turns the field equation into Sqrt[Sin] (Cot T16[0] d_0 Psi' + (1/q) T16[i] d_i Psi' + T16[4] d_4 Psi' + (1/p) T16[h] d_h Psi' - H V'(Sin s') Psi'): NO connection term`.
The `x4`-only family `Psi = Sqrt[Sin] Psi'(x4)` solves the equation if and only if `V'' s' = 0`: for
linear `V` (the author's mass term) or for null data. **[proved VII §29]**
`PRE-UNIVERSE (2) [THE RESULT]: Psi = Sqrt[Sin] Psi'(x4) satisfies the field equation iff d_x0 V'(Sin[6Hx0] s') == 0, and d_x0 V'(Sin s') == 6 H Cos[6 H x0] s' V''(Sin s'): V linear OR s' == 0`.

**The operator form.** As an operator equation the right-hand side is `H :V'(s) Psi:` with the
Weyl-symmetrized product: exact for linear `V`; for nonlinear `V` it differs by Hartree and Fock
contractions with the coincident `J`-vacuum propagator (a scalar part that renormalizes `V'`, and a
`gamma^4` part, the sea charge, removed by charge-symmetric ordering). In the Kohn–Sham mean field
`V'(s) -> V'(<s>)` and the equation is linear [prose VII §27].

**The currents.** The only internal U(1) is the vector phase; its current `j^mu = i Psibar gamma^mu Psi`
is real and conserved on shell. The particle-number current is `n^mu = −(i/H) Psibar gamma^mu Psi`,
with `n^4 = Psi^dagger Psi/H >= 0` and `N = Int Sqrt[g] n^4 d^7x` the normal-ordered number of particles
minus antiparticles. **[proved VII §27, §28]** `CURRENT [THE RESULT]: OFF SHELL (1/Sqrt[g]) d_mu(Sqrt[g] j^mu) == i (Ebar Psi + Psibar E) for generic fields of all eight coordinates -- conserved on shell`,
`CHARGE [THE RESULT]: n^4 = -(i/H) Psibar gamma^4 Psi == (1/H) Psi^ddag G Psi == (1/H) Psi^dagger Psi, whose mode form Sum_u eta_u b_u^ddag b_u == Sum_u b_u^dagger b_u is the particle number (normal-ordered: particles - antiparticles)`.

#### 4.1.4 The canonical anticommutator in 4+4 dimensions

Time is `x4` (lapse 1, shift 0 on every frame of this document). The slice `x4 = const` is
seven-dimensional with signature (4,3) — `x0..x3` spacelike, `x5, x6, x7` timelike — and is not a
Cauchy surface. The Dirac bracket of the symmetrized Lagrangian gives

```
{Psi_a(x), Psi^ddag_b(y)}_{x4 = y4}  =  (H/Sqrt[g]) G_ab delta^7(x - y),        G = -i sigma16 gamma^4,        {Psi_a, Psi_b} = 0
```

On the canonical frame `gamma^4 = T16[4]` and `Sqrt[g] = Sec[6 H x0]`, so the matrix is

```
G  =  J  :=  -i T16[0].T16[1].T16[2].T16[3].T16[4],        J Hermitian,  J^2 = ID16,  eigenvalues +1 (8), -1 (8):  signature (8,8)
{Psi_a(x), Psi^ddag_b(y)}  =  H Cos[6 H x0] J_ab delta^7(x - y)
```

**[proved VII §28]** `QUANTIZATION [THE RESULT]: G = -i sigma16 gamma^4 == J = -i T16[0].T16[1].T16[2].T16[3].T16[4] on the canonical frame; J is Hermitian, J^2 == ID16, eigenvalues +1 (8) and -1 (8): signature (8,8)`,
`ANTICOMMUTATOR [THE RESULT]: on the canonical frame (c = Sqrt[g]/H) {Psi, Psi^ddag} == (H/Sqrt[g]) J == H Cos[6 H x0] J  (J^-1 == J), which IS the design's (H/Sqrt[g])(-i sigma16 gamma^4)`. The spin connection does not enter it
(`Gamma_4 = 0`; the anticommutator comes from the time-derivative term alone).

**The fundamental symmetry and the Hilbert adjoint.** `J = −i Omega4 T16[0]` is a hidden flavour
gamma, of signature (2,2) on the flavour factor; `sigma16 = J beta` with `beta = −i T16[4]` the
observer's Dirac-adjoint matrix. The Hilbert adjoint is defined by the `J`-involution,
`Psi^dagger := Psi^ddag J`; then `Psibar = Psi^dagger beta`, `s = Psi^dagger beta Psi`, and
`{Psi_a, Psi^dagger_b} = (H/Sqrt[g]) delta_ab delta^7`: **positive**. The adjoint is mode-independent,
and a mode basis must consist of `J`-eigenvectors. For Grassmann fields the `*`-structure is a free
choice and the filled Dirac sea makes the Hamiltonian bounded below; for a commuting field the same
construction fails. Under this adjoint a bilinear `Psi^ddag M Psi` (with `M` classically Hermitian) is a
Hermitian operator iff `[J, M] = 0` and anti-Hermitian iff `{J, M} = 0`: `s = Psibar Psi` is Hermitian and
`p = Psibar T16[8] Psi` anti-Hermitian, which is why the self-interaction depends on `s` only.
**[proved VII §28]**
`J [THE RESULT]: with Psi^dagger := Psi^ddag J:  Psibar = Psi^dagger beta (J sigma16 == beta),  Psi^ddag G = Psi^dagger (J G == ID16),  {Psi, Psi^dagger} == (H/Sqrt[g]) ID16 (G^-1 J == ID16): POSITIVE`,
`J [has content]: the Hermiticity rule -- for classically Hermitian M, (J M)^dagger == J M iff [J, M] == 0 and == -J M iff {J, M} == 0: so s = Psi^ddag sigma16 Psi is Hermitian and p = Psi^ddag C+ Psi is ANTI-Hermitian`,
`KREIN MODES [control]: a Krein-boosted pair u1 = (5/4)u+ + (3/4)u-, u2 = (3/4)u+ + (5/4)u- in the omega = +5 eigenspace is still G-orthonormal and still consists of modes, but not of J-eigenvectors; the induced J_U = G U U^dagger differs from J, and under it s is NOT Hermitian`.

**The admissible sector (a theorem).** A positive Fock quantization in which the local `s(x)`, the
local energy–momentum tensor and the free Hamiltonian are Hermitian exists if and only if the span
of the momenta carried by the modes is spacelike-definite. On the canonical frame: no momentum along
`x5, x6, x7`, and `J` is then unique. With a hidden momentum above threshold the frequencies are
imaginary (`omega^2 = k_s^2 − k_h^2 + m^2`; at `k = (0, 3/4, 1, 0 | k5 = 2)`, `m = 1`:
`±1.19896 i`), at threshold the evolution is nilpotent. The admissible theory is a truncation
(dimensional reduction to `Psi(x0, ..., x4)`) with a finite hidden coordinate volume
`V_hid = Int dx5 dx6 dx7` — an assumption, and compact timelike directions contain closed timelike
curves — and its anticommutator is
`{Psi_a(x), Psi^ddag_b(y)} = (H/(V_hid Sqrt[|g|])) G_ab delta^4(x0..x3 − y0..y3)`.
**[proved VII §28]** `ADMISSIBILITY (1) [THE RESULT]: E_k^2 == (k_s^2 - k_h^2 + m^2) ID16 for every k: omega^2 = k_s^2 - k_h^2 + m^2`,
`ADMISSIBILITY (5) [THE RESULT]: ABOVE threshold (k = (0, 3/4, 1, 0 | k5 = 2), m = 1) omega^2 == -23/16: every eigenvalue of E_k is +-i Sqrt[23]/4 = +-1.19896 i and every eigenvector is G-NEUTRAL (u^dagger G u == 0)`,
`ADMISSIBILITY (7) [THE RESULT]: J is UNIQUE -- the joint commutant of beta and the admissible E_k is 8-dimensional, contains J, and every element of it commutes with J (so X^2 == 1 with J X > 0 forces X == J)`.

**The Fock space.** Per spatial momentum the sixteen `J`-eigenmodes are 8 of frequency `+omega` and 8
of frequency `−omega`, `omega = Sqrt[k.k + m^2]`; every mode has energy equal to its frequency, the
negative-frequency modes are filled (the Dirac sea, the unique ground state), and the first
excitations are 8 particles and 8 antiparticles. A finite Jordan–Wigner Fock space at one momentum
(`k = 3 e1`, `m = 4`, dimension `2^16 = 65536`) checks all of it exactly, including the sign of the
anticommutator through the Heisenberg equation. **[proved VII §28]**
`FOCK (mode level) [THE RESULT]: the spectrum -- a UNIQUE ground state at -8 omega = -40, the Dirac sea (modes 9..16 filled, 1..8 empty); :Ham: = Ham + 40 >= 0`,
`FOCK (mode level) [THE RESULT]: the first excited level, omega = 5 above the sea, is 16-fold: 8 particle states (N = +1) and 8 antiparticle states (N = -1), with N = Sum b^dagger b - 8`,
`FOCK (field level) [THE RESULT]: Heisenberg -- [H_free, Psi_a] == -(G^-1 h Psi)_a for all 16 components, so i d_4 Psi = i [H, Psi] IS the field equation i G d_4 Psi = h Psi`.

**What survives.** 13 of the 28 Lorentz generators commute with `J` (Spin(4,1) of `x0..x4` and
Spin(3) of `x5..x7`); the 12 boosts between `x0..x3` and `x5..x7` and the 3 rotations between `x4`
and `x5..x7` are lost. The wall `x0 = 0` of the canonical frame is at finite proper distance
`z = −Log[Cos[6 H x0]]/(6 H)`; the one-particle space of `Psi' = Psi/Sqrt[Sin]` is `L^2(dz)`, the
`x0`-operator is regular at the wall and limit-point at infinity, and the Lorentz-covariant,
`J`-compatible wall conditions are `T16[0] Psi' = ±Psi'`. **[proved VII §28]**
`J [THE RESULT]: 13 of the 28 Lorentz generators commute with J (a, b both in {0..4}: Spin(4,1), or both in {5,6,7}: Spin(3)); the other 15 anticommute -- 12 boosts x0..x3 <-> x5..x7 and 3 rotations x4 <-> x5..x7`,
`BOUNDARY [THE RESULT]: the bag condition T16[0] Psi' = +-Psi' at the wall -- T16[0]^2 == 1, {beta, T16[0]} == 0, the normal-flux form vanishes on both eigenspaces (P beta T16[0] P == 0), and [J, T16[0]] == 0`.

The anticommutator on the time-dependent frames of the coupled system is section 4.4.6.

#### 4.1.5 The energy–momentum tensor operator

```
That_{mu nu}  =  -(1/(4H)) [ Psibar gamma_mu D_nu Psi - (D_nu Psibar) gamma_mu Psi + (mu <-> nu) ]  +  g_{mu nu} Lhat,        gamma_mu = g_{mu nu} gamma^nu
```

normal-ordered with respect to the `J`-vacuum when it is an operator. It is the **Hilbert**
(symmetric-tetrad) tensor of the symmetrized action, equal to this covariant expression off shell;
the variation of the spin connection contributes exactly nothing to it (the Lagrangian sees the
connection only through its totally antisymmetric part, which a symmetric tetrad variation does not
change); it is **not** the partial-derivative tensor. It is symmetric, Hermitian under the classical
conjugation, and conserved on shell. **[proved VII §29]**
`EMT [THE RESULT]: the Hilbert (symmetric-tetrad) tensor of the symmetrized action IS That, OFF shell -- components (x1,x1), (x4,x4), (x1,x4), (x0,x5), (x5,x4)`,
`EMT [has content]: the spin-connection variation contributes NOTHING -- dropping it leaves the Hilbert tensor unchanged at (x1,x4), (x0,x5), (x5,x4)`,
`EMT CONSERVATION [THE RESULT]: nabla^mu That_{mu nu} == 0 ON SHELL in all eight components, for generic Psi(x0, x4), Psibar(x0, x4) and generic V`.

**On shell**, for fields of `(x0, x4)` and generic `V`:

```
Lhat == s V'(s) - V(s)                   (the kinetic bilinear is s V'(s))
rho = That_44 == V(s) + K_h,             K_h = -(1/(2H)) ( Psibar gamma^0 d_0 Psi - d_0 Psibar gamma^0 Psi )
T^i_i == T^h_h == s V'(s) - V(s)         (observed i = 1,2,3 and hidden h = 5,6,7)
T^0_0 == s V'(s) - V(s) + K_h            trace == 7 s V'(s) - 8 V(s)
```

**[proved VII §29]** `EMT ON SHELL [THE RESULT]: rho = That_44 == V(s) + K_h`,
`EMT ON SHELL [THE RESULT]: T^i_i == T^h_h == s V'(s) - V(s) for the three observed and the three hidden directions, and T^0_0 == s V'(s) - V(s) + K_h`.
`That_{mu nu}` is a Hermitian operator for `mu, nu` in `{0..4}`; its components that mix `0..4` with
the hidden sheet are anti-Hermitian, with zero expectation value in every state invariant under the
hidden rotations. **[proved VII §29]** `EMT HERMITICITY [THE RESULT]: J-parity table -- (mu, nu) in {0..4}: EVEN (Hermitian); (mu in 0..4, h in 5..7): ODD (anti-Hermitian); (h, h'), h != h': ZERO identically; (h, h): even`.

#### 4.1.6 Density, pressures and the equation of state

The observer is `u = d/dx4`: `rho = <:That_44:>`, `P_j = <:That^j_j:>` (no sum), `w = P_obs/rho` with
`P_obs` the pressure along the observed sheet. With the canonical normalization `chi = Psi/Sqrt[H]`
and `W(sigma) := V(H sigma)`, `sigma = <chibar chi>`, each occupied positive-frequency mode contributes
`omega` to the energy density, `k_j^2/omega` to the pressure along `j`, and `m/omega` to `sigma`.
**[proved VII §29]** `MODE SUMS [has content]: with ubar = u^ddag sigma16 these are omega u^ddag G u and k_j u^ddag (dh/dk_j) u, so by Section 28 each occupied mode contributes omega, k_j^2/omega and (to sigma) m/omega`.

**The Kohn–Sham Fermi sea.** Fill the positive-frequency modes with `|k| < k_F` along the observed
sheet (zero modes along `x0` and `x5, x6, x7`), `g = 8`, mass `m`, `w_F = Sqrt[k_F^2 + m^2]`,
`L = Log[(k_F + w_F)/m]`:

```
n        =  g k_F^3/(6 pi^2)
sigma_KS =  (g m/(4 pi^2)) [ k_F w_F - m^2 L ]
eps_KS   =  (g/(16 pi^2)) [ k_F w_F (2 k_F^2 + m^2) - m^4 L ]
P_KS     =  (g/(48 pi^2)) [ k_F w_F (2 k_F^2 - 3 m^2) + 3 m^4 L ]
eps_KS + P_KS == w_F n,     eps_KS - 3 P_KS == m sigma_KS,     d eps_KS/dm == sigma_KS,     d eps_KS/dk_F == w_F dn/dk_F
```

**[proved VII §29]** `KOHN-SHAM [THE RESULT]: each closed form has k_F-derivative (g/(2 pi^2)) k_F^2 f(k_F) with f = 1, m/omega, omega, k^2/(3 omega), and vanishes at k_F = 0 -- so it IS the integral g Int d^3k/(2 pi)^3 f`,
`KOHN-SHAM [THE RESULT]: eps + P == w_F n (Gibbs), eps - 3 P == m sigma (trace), d eps/dm == sigma, d eps/dk_F == w_F dn/dk_F`. In the mean field `m = W'(sigma)`:

```
rho = eps_KS + W - sigma W',        P_obs = P_KS + sigma W' - W,        P_hid = P_x0 = sigma W' - W,        rho + P_obs == w_F n
```

**[proved VII §29]** `MEAN FIELD [THE RESULT]: rho = eps + W - sigma W', P_obs = P_KS + sigma W' - W give rho + P_obs == w_F n exactly; and d rho/dn == w_F + (sigma_KS - sigma) W'' sigma'(n), i.e. == w_F at the self-consistent point sigma = sigma_KS (m = W'(sigma) throughout)`. Hence `w_f + 1 = w_F n/rho >= 0` wherever
`rho > 0`: **the quantized fable cannot cross the phantom divide.** For the author's mass term
`W = m sigma` the condensate `W − sigma W'` vanishes, `rho = eps_KS > 0`, `P_obs = P_KS >= 0`, and
`w = P_KS/eps_KS` rises monotonically with `x = k_F/|m|` from 0 (dust) to 1/3 (radiation); the classical
limit is the non-relativistic limit `k_F/|m| -> 0`, which reproduces Part VI's `rho = V(s)`,
`P = s V' − V`, with the sign rule `sign(sigma) = sign(m) = sign(W')`. **[proved VII §29]**
`AUTHOR'S MASS TERM [THE RESULT]: w rises MONOTONICALLY -- dw/dx == x^2 Delta/(3 w_x I1^2) with Delta = x^2 I1 - w_x^2 I2, Delta(0) = 0 and Delta' = 2 x I3 > 0 -- from w -> 0 (x -> 0, w = x^2/5 + O(x^4): dust) to w -> 1/3 (x -> infinity: radiation)`,
`CLASSICAL LIMIT [THE RESULT]: at the self-consistent point rho == W + 3 P_KS and P_obs == (sigma W' - W) + P_KS exactly (sigma = sigma_KS, m = W'); Part VI's rho = V(s), P = s V' - V is the limit P_KS/eps_KS -> 0, i.e. k_F/m -> 0`.
On the pre-universe (the canonical frame, `a4` free) the charge per coordinate volume is conserved,
the observed-sheet momenta redshift as `Exp[a4]`, and the quantum gas **cools** (`w: 1/3 -> 0`) when
`a4' < 0`, while the classical Part VI fable's `w` is frozen. **[proved VII §29]**
`PRE-UNIVERSE (4) [THE RESULT]: x = k_F,phys/m = x_c/(q m) obeys d Log[x]/dx4 == H a4'[H x4]; since dw/dx > 0, dw/dx4 = w'(x) x H a4' < 0 exactly when a4' < 0 (the observed sheet expanding): the quantum gas COOLS`.

Section 4.5 below turns all of this into the per-7-volume source of the coupled system and proves the
properties the Einstein equations need.

### 4.2 The Einstein equations of the primordial gravitational field, with fable as their source

This is Section 30 of the notebook (manifest `claude-fable/cells_part8.wl`, Input cells 199–203,
28 assertions, 4.119 s in `claude-fable/run_fermion_fable_part8.log`). Part VIII opens with a
statement of purpose: Parts III–V built the 4+4 geometry of the pre-universe but never asked what
**sources** it; Part VI put fields on it without letting them act back; Part VII made fable a
quantized fermion with an energy–momentum tensor operator; Part VIII closes the loop [prose VIII,
introduction]. It never redefines anything of Parts I–VII, and it never gives `a4` a value.

#### 4.2.1 The semiclassical system and its conventions

The metric stays classical; fable is quantized. The coupled equations are

```
G^mu_nu  =  kappa < That^mu_nu >                                 (semiclassical gravity)
kappa = 8 pi G_8 > 0        (the eight-dimensional gravitational coupling, a plain symbol)
```

with the expectation value taken in a state of the fable Fock space of section 4.1.4 — in section 4.5
and after, the Kohn–Sham ground state. The Einstein tensor is used with one index up and one down,
`G^mu_nu`, because then the answer does not depend on how the metric signs are distributed. For a
source at rest in the observer's frame the energy density and the pressures are the diagonal of the
mixed tensor [prose VIII, introduction]:

```
rho = -T^4_4,        P_obs = T^i_i  (i = 1,2,3),        P_hid = T^h_h  (h = 5,6,7),        P_C = T^0_0
```

so `G^4_4 = −kappa rho`, `G^i_i = kappa P_obs`, `G^h_h = kappa P_hid`, `G^0_0 = kappa P_C`. The dynamical
frames of Sections 31–33 carry their own scale factors `scA`, `scB`, `scC` (functions of `x4`,
separate symbols); the canonical frame is recovered from them only by an explicit, labelled
substitution inside an assertion.

#### 4.2.2 The tool, and the three tests it must pass

One helper, `cfEinsteinData`, computes every Einstein tensor of Part VIII from the Christoffel
symbols of Section 16's solver:

```
R_{mu nu} = d_l Gamma^l_{mu nu} - d_nu Gamma^l_{mu l} + Gamma^l_{l s} Gamma^s_{mu nu} - Gamma^l_{nu s} Gamma^s_{mu l}
R = g^{mu nu} R_{mu nu},        G^mu_nu = g^{mu k} R_{k nu} - (1/2) delta^mu_nu R
```

It is not trusted until it passes three tests, each of which a wrong index or sign would fail
**[proved VIII §30]**:

1. on the separate FLRW frame of Part VI it returns the Friedmann equations with the textbook signs:
   `EINSTEIN [solver regression]: on the FLRW frame of Section 24, G^4_4 == -3 (a'/a)^2 and G^i_i == -(2 a''/a + (a'/a)^2): the Friedmann equations with the textbook signs`;
   `EINSTEIN [solver regression]: ... and G == -3 (a''/a + (a'/a)^2) along the four static directions x0, x5, x6, x7, with no off-diagonal component`;
2. on the canonical frame its Ricci scalar equals the one Section 16 obtained from the curvature
   2-form of the spin connection: `EINSTEIN [fidelity]: the Ricci scalar from the Christoffel symbols == RicciScalarCanonical of Section 16 (from the curvature 2-form of the spin connection): two routes, one answer`;
3. its output obeys the contracted Bianchi identity:
   `EINSTEIN [has content]: the contracted Bianchi identity nabla_mu G^mu_nu == 0 holds for the canonical Einstein tensor, all eight components, a4 arbitrary`.

And the canonical metric is not a vacuum solution: `EINSTEIN [control]: the canonical metric is NOT a vacuum solution -- G^0_0 is not zero (witnessed)`.

#### 4.2.3 The Einstein tensor of the canonical metric: all sixty-four components

With `Cot = Cot[6 H x0]`, `Csc = Csc[6 H x0]`, `a4' = a4'[H x4]`, `a4'' = a4''[H x4]` (derivatives with
respect to the argument of `a4`), the mixed Einstein tensor of the canonical metric
`ds^2 = Tan[6Hx0]^2 dx0^2 + q^2 dx_obs^2 − dx4^2 − p^2 dx_hid^2` is **diagonal** — all 56 off-diagonal
components vanish identically — and

```
G^0_0  =  3 H^2 ( 5 Cot^4 - a4'^2 )
G^i_i  =  (H^2/2) ( 15 (9 + Cos[12 H x0]) Cot^2 Csc^2 - 6 a4'^2 - 2 a4'' )          i = 1, 2, 3
G^4_4  =  (3 H^2/2) ( (55 + 7 Cos[12 H x0]) Cot^2 Csc^2 + 2 a4'^2 )
G^h_h  =  (H^2/2) ( 15 (9 + Cos[12 H x0]) Cot^2 Csc^2 - 6 a4'^2 + 2 a4'' )          h = 5, 6, 7
R      =  -3 H^2 ( (55 + 7 Cos[12 H x0]) Cot^2 Csc^2 - 2 a4'^2 )
```

for every `a4` [prose VIII §30], and **[proved VIII §30]**
`EINSTEIN [THE RESULT]: all 64 components of G^mu_nu of the canonical metric, a4 arbitrary: 8 diagonal ones as stated, 56 off-diagonal ones identically zero`,
`EINSTEIN [THE RESULT]: the Ricci scalar R == -3 H^2 ((55 + 7 Cos[12 H x0]) Cot^2 Csc^2 - 2 a4'^2)`.

**The split, with no cross terms.** Every component is a function of `x0` alone plus a function of
`x4` alone. The statement is made without giving `a4` a value: the `x0`-part is the Einstein tensor of
the **separate** frame `diag(Tan[6 H x0], S^(-1/6) x3, 1, S^(-1/6) x3)` (`S = Sin[6 H x0]`), which does
not contain `a4`, and the `a4`-part is the Einstein tensor of the **separate** frame
`diag(1, Exp[-a4] x3, 1, Exp[+a4] x3)`, which does not contain `x0`; the two frames multiply to the
canonical frame. **[proved VIII §30]**
`EINSTEIN [definition]: the two factor frames multiply to the canonical frame, and neither is it: the x0-only frame contains no a4, the a4-only frame contains no x0`,
`EINSTEIN [THE RESULT]: NO CROSS TERMS -- G^mu_nu(canonical) == G^mu_nu(x0-only frame) + G^mu_nu(a4-only frame), all 64 components`,
`EINSTEIN [has content]: the x0-part is the same on the observed and the hidden sheet (G^i_i == G^h_h), and the a4-part is x0-independent`.

The two parts, component by component [derived here: the `x0`-part is the canonical formula at
`a4' = a4'' = 0`, since the `a4`-part depends on `a4` only through the rates `a4'` and `a4''` (it is a
Bianchi-I tensor, section 4.3.1) and vanishes for constant `a4`, where the `a4`-only frame is constant; the
`a4`-part is the difference]:

| component | `x0`-part `G_x0` (the `x0`-only frame) | `a4`-part `G_a4` (the `a4`-only frame) |
|---|---|---|
| `G^0_0` | `15 H^2 Cot^4` | `−3 H^2 a4'^2` |
| `G^i_i` (`i = 1,2,3`) | `(15 H^2/2) (9 + Cos[12 H x0]) Cot^2 Csc^2` | `−3 H^2 a4'^2 − H^2 a4''` |
| `G^4_4` | `(3 H^2/2) (55 + 7 Cos[12 H x0]) Cot^2 Csc^2` | `+3 H^2 a4'^2` |
| `G^h_h` (`h = 5,6,7`) | `(15 H^2/2) (9 + Cos[12 H x0]) Cot^2 Csc^2` | `−3 H^2 a4'^2 + H^2 a4''` |

The `x0`-part does not distinguish the observed from the hidden sheet; only `a4''` does.

#### 4.2.4 Theorem (a): energy — the canonical metric demands negative total energy

`G^4_4 = −kappa rho_total`, and the minimum of `55 + 7 Cos[12 H x0]` is 48. Therefore, for every `a4` and
everywhere in `0 < 6 H x0 < Pi/2`,

```
rho_total  =  -G^4_4/kappa  <=  -( 72 H^2 Cot^2 Csc^2 + 3 H^2 a4'^2 )/kappa  <  0,
G^4_4 - (72 H^2 Cot^2 Csc^2 + 3 H^2 a4'^2)  ==  (21/2) H^2 (1 + Cos[12 H x0]) Cot^2 Csc^2  >=  0      exactly.
```

The total energy density that sources the canonical metric is **negative everywhere**. No source
with `rho >= 0` can be the sole source of this geometry — in particular not the Kohn–Sham fable with
the author's mass term, whose `rho = eps_KS` is positive. **[proved VIII §30]**
`ENERGY [has content]: min over x0 of 55 + 7 Cos[12 H x0] is 48 (attained where Cos[12 H x0] = -1)`,
`ENERGY [THE RESULT]: G^4_4 - (72 H^2 Cot^2 Csc^2 + 3 H^2 a4'^2) == (21/2) H^2 (1 + Cos[12 H x0]) Cot^2 Csc^2, which is >= 0`,
`ENERGY [THE RESULT]: 72 H^2 Cot^2 Csc^2 + 3 H^2 a4'^2 > 0 in 0 < 6 H x0 < Pi/2 for real a4, hence rho_total = -G^4_4/kappa < 0: the canonical metric demands NEGATIVE total energy density`,
`ENERGY [has content]: Section 29's eps_KS vanishes at kF = 0 and d eps_KS/d kF == g kF^2 wF/(2 pi^2) > 0, so the KS fable with the author's mass term (rho = eps_KS) cannot be the sole source`.

#### 4.2.5 The background-stress reading (an illustration; the splitting is a choice)

One may split the source as `T = T_bg + T_rest` with `T_bg := G_x0/kappa`, the `x0`-part held as a fixed
background. Its energy density is negative everywhere:

```
rho_bg  =  -(3 H^2/(2 kappa)) (55 + 7 Cos[12 H x0]) Cot^2 Csc^2  <  0
```

The remaining equations `G_a4 = kappa T_rest` then demand a stress that does not depend on `x0`,
because `G_a4` does not; the fable solutions of Part VI do — the rescaled solution
`Psi = Sqrt[Sin[6 H x0]] Psi'(x4)` has `rho = V(Sin[6 H x0] s')`, which depends on `x0` for the author's
mass term. So fable would have to deform the `x0`-profile. This is an illustration of the splitting,
not a theorem about the full coupled problem, and the notebook states it as such [prose VIII §30].
**[proved VIII §30]** `BACKGROUND [has content]: with the splitting T_bg := G_x0/kappa, rho_bg == -(3 H^2/(2 kappa)) (55 + 7 Cos[12 H x0]) Cot^2 Csc^2 < 0 everywhere`,
`BACKGROUND [has content]: the illustration -- G_a4 is x0-independent, while the fable density of Section 24, rho = V(Sin[6 H x0] s') on Psi = Sqrt[Sin] Psi'(x4), depends on x0 for the mass term (witnessed on Psi' = e1 + e5, M = 1)`.

#### 4.2.6 Theorem (b): anisotropy

Subtracting the hidden-sheet equation from the observed-sheet one, the `x0`-parts cancel:

```
G^i_i - G^h_h  =  -2 H^2 a4''        so        a4''  =  -kappa ( P_obs - P_hid ) / (2 H^2)        for ANY source
```

Take fable as the source, as a c-number configuration `Psi(x0, x4)`, `Psibar(x0, x4)` (independent
functions) of the symmetrized Lagrangian. Along a direction on which the fields do not depend,
`D_i Psi = Gamma_i Psi` and `D_i Psibar = −Psibar Gamma_i`, so the kinetic part of `That_ii` is
`−(1/(2H)) Psibar {gamma_i, Gamma_i} Psi`, which vanishes because `{gamma_mu, Gamma_mu} = 0` for each
`mu` separately. Hence, **off shell** and for every `V`,

```
P_obs  =  T^i_i  =  Lhat  =  T^h_h  =  P_hid
```

and such configurations force `a4'' = 0`: the anisotropy of the canonical frame cannot be sourced by
them. The Kohn–Sham Fermi gas is different: its quasiparticles move along the observed sheet only, so
`P_obs − P_hid = P_KS/v > 0` (with `v` the hidden 4-volume factor of section 4.5) and it **can** source
`a4'' < 0`. **[proved VIII §30]**
`ANISOTROPY [THE RESULT]: G^i_i - G^h_h == -2 H^2 a4''[H x4] for every observed i and hidden h, hence a4'' == -kappa (P_obs - P_hid)/(2 H^2) for any source`,
`ANISOTROPY [has content]: the premise, re-checked with the index lowered -- {gamma_mu, Gamma_mu} == 0 for EACH mu separately on the canonical frame (gamma_mu = g_{mu nu} gamma^nu; Section 27 (c))`,
`ANISOTROPY [THE RESULT]: OFF SHELL, for generic independent Psi(x0, x4), Psibar(x0, x4) and every V:  T^i_i == Lhat == T^h_h  (i = 1,2,3; h = 5,6,7), so P_obs == P_hid and such fable configurations force a4'' == 0`,
`ANISOTROPY [control]: T^0_0 is NOT Lhat off shell -- the x0-derivatives enter it (witnessed on Psi = x0 e1, Psibar = the first column of T16[0], V = s^2): the statement is special to the directions on which the fields do not depend`,
`ANISOTROPY [has content]: Section 29's P_KS vanishes at kF = 0 and dP_KS/dkF == g kF^4/(6 pi^2 wF) > 0, so P_KS > 0 for kF > 0`,
`ANISOTROPY [THE RESULT]: for the KS fluid P_obs - P_hid == P_KS/v identically, for every W: the Fermi gas CAN source a4'' < 0`.

#### 4.2.7 Theorem (c): momentum

`G^0_4 = G^4_0 = 0` on the canonical frame, so the source must carry no momentum along the hidden
coordinate, `T^0_4 = 0`. That is a real condition on fable: its `T_{04}` is not identically zero.
**[proved VIII §30]** `MOMENTUM [THE RESULT]: G^0_4 == G^4_0 == 0 on the canonical frame, so T^0_4 == 0 is required of the source`,
`MOMENTUM [has content]: T^0_4 == 0 is a genuine condition -- fable's T_{04} is not identically zero (witnessed on Psi = x4 e1, Psibar = T16[0] e1, V = s^2)`.

#### 4.2.8 The asymptotic canonical frame is sourced by a ghost stiff fluid

The `a4`-part of the Einstein tensor is the Einstein tensor of `diag(1, Exp[-a4] x3, 1, Exp[a4] x3)`,
which section 4.3.3 shows to be the asymptotic (`6 H x0 -> Pi/2`) form of the canonical frame. With
`h = H a4'[H x4]` (so that the observer's Hubble rate is `H_obs = −h`) and `h' = dh/dx4 = H^2 a4''`, the
stress it demands is

```
rho  =  P_C  =  -3 h^2/kappa,        P_obs  =  rho - h'/kappa,        P_hid  =  rho + h'/kappa
```

Its `x0`-pressure equals its energy density (stiff, `w_C = +1`), and both are negative. When `h' = 0`
all seven pressures equal `rho = −3 h^2/kappa`: exactly the energy–momentum tensor of a **ghost**
scalar `phi(x4)` (a scalar with the wrong sign of its kinetic term, `L = +(1/2) g^{mn} d_m phi d_n phi`,
`T_mn = −d_m phi d_n phi + g_mn L`) with `phi'^2 = 6 h^2/kappa`. In general the demanded stress is the
ghost tensor plus the traceless anisotropic stress `(h'/kappa) diag(0, −1, −1, −1, 0, +1, +1, +1)`.
The volume-preserving expansion of the observed sheet (`h < 0`, `H_obs > 0`) is sourced by negative
energy. **[proved VIII §30]** `GHOST [THE RESULT]: the a4-part demands rho == P_C == -3 h^2/kappa, P_obs == rho - h'/kappa, P_hid == rho + h'/kappa, with h = H a4'[H x4], h' = dh/dx4`,
`GHOST [THE RESULT]: demanded stress == ghost-scalar tensor with phi'^2 = 6 h^2/kappa  +  (h'/kappa) diag(0,-1,-1,-1,0,1,1,1): negative-energy, stiff (P_C == rho), plus a traceless anisotropic part`,
`GHOST [has content]: the ghost scalar's energy density is -phi'^2/2 < 0 and all seven of its pressures equal it`,
and `PART VIII [control]: a4 is STILL UNDEFINED after Section 30`.

#### 4.2.9 What Section 30 proves

Proved symbolically, with `a4` arbitrary: the Einstein tensor of the canonical metric (all 64
components, the `x0 + a4` split with no cross terms, the Ricci scalar two ways, the Bianchi
identity); negative total energy for every source; the anisotropy law, with `P_obs = P_hid` for every
c-number fable configuration of `(x0, x4)` and `P_obs − P_hid = P_KS/v` for the Kohn–Sham gas; zero
`x0`-momentum; and the ghost-scalar reading of the asymptotic canonical frame. The conclusion that
drives the rest of this document: **fable, whose energy is positive, cannot source the canonical frame
alone; the frame must be generalized** (section 4.3).

### 4.3 The generalized frame, the (0,4) equation, the asymptotic region, and the 8-dimensional Bianchi-I system

This is Section 31 of the notebook (Input cells 204–207, 21 assertions, 12.672 s). Section 30
showed that the canonical frame, with its single free function `a4`, cannot absorb a positive
energy density. Section 31 builds the family of frames on which fable can act back.

#### 4.3.1 The generalized warped frame and its Einstein tensor

The generalization keeps the `x0`-profile of the canonical frame and gives each block its own scale
factor, a function of the observer's time `x4`:

```
e = diag( Tan[6 H x0] C,  A S^(-1/6), A S^(-1/6), A S^(-1/6),  1,  B S^(-1/6), B S^(-1/6), B S^(-1/6) ),        S = Sin[6 H x0]
A = scA[x4]  (observed sheet),    B = scB[x4]  (hidden timelike sheet),    C = scC[x4]  (hidden x0 direction)
H_A = A'/A,   H_B = B'/B,   H_C = C'/C,   Theta = 3 H_A + 3 H_B + H_C          (' = d/dx4)
```

The canonical frame is the member `A = Exp[-a4]`, `B = Exp[+a4]`, `C = 1` — a labelled substitution,
used only inside assertions. The theorem:

```
diag G^mu_nu  =  diag G_x0 / C^2  +  diag G_BI(A, B, C)        EXACTLY
G^4_0  =  3 H Cot[6 H x0] ( 2 H_C - H_A - H_B ),        G^0_4  =  -3 H Cot[6 H x0]^3 ( 2 H_C - H_A - H_B ) / C^2        (the only off-diagonal components)
```

where `G_x0` is the `x0`-part of section 4.2.3 and `G_BI` is the Einstein tensor of the unwarped
8-dimensional Bianchi-I frame `diag(C, A, A, A, 1, B, B, B)`. The contracted Bianchi identity holds
for the whole family, and on the canonical member everything reduces to Section 30.
**[proved VIII §31]** `WARPED [definition]: the canonical frame IS the member A = Exp[-a4], B = Exp[+a4], C = 1 of the family (labelled substitution)`,
`WARPED [has content]: the contracted Bianchi identity nabla_mu G^mu_nu == 0 holds for the warped family, A, B, C arbitrary`,
`WARPED [THE RESULT]: diag G^mu_nu == diag G_x0/C^2 + diag G_BI(A, B, C) EXACTLY (the x0-part of Section 30 and the unwarped Bianchi-I tensor)`,
`WARPED [THE RESULT]: the only off-diagonal components are G^4_0 == 3 H Cot (2 H_C - H_A - H_B) and G^0_4 == -3 H Cot^3 (2 H_C - H_A - H_B)/C^2`,
`WARPED [fidelity]: on the canonical member the warped Einstein tensor IS Section 30's, all 64 components, and the Bianchi-I part IS Section 30's a4-part` (the two geometries took 9.584 s and 0.709 s, `claude-fable/run_fermion_fable_part8.log`).

**The Bianchi-I part, component by component** [derived here from the Ricci components asserted in
section 4.3.4, `R^i_i = H_i' + H_i Theta` and `R^4_4 = Sum_7 (H_i' + H_i^2)`, with
`R = R^4_4 + 3 R^A + 3 R^B + R^C` and `G^mu_mu = R^mu_mu − R/2`; `Sigma_2 = 3 H_A^2 + 3 H_B^2 + H_C^2`,
`Sdot = 3 H_A' + 3 H_B' + H_C'`]:

```
G_BI^4_4  =  -(Theta^2 - Sigma_2)/2  =  -( 3 H_A^2 + 3 H_B^2 + 9 H_A H_B + 3 H_A H_C + 3 H_B H_C )
G_BI^i_i  =  H_A' + H_A Theta - Sdot - (Sigma_2 + Theta^2)/2          (i = 1, 2, 3)
G_BI^h_h  =  H_B' + H_B Theta - Sdot - (Sigma_2 + Theta^2)/2          (h = 5, 6, 7)
G_BI^0_0  =  H_C' + H_C Theta - Sdot - (Sigma_2 + Theta^2)/2
```

Checks [derived here]: on the canonical member (`H_A = −h`, `H_B = h`, `H_C = 0`, `h = H a4'`,
`Theta = 0`) these give `G^4_4 = 3 h^2`, `G^i_i = −h' − 3 h^2`, `G^h_h = h' − 3 h^2`, `G^0_0 = −3 h^2` — the
`a4`-part of section 4.2.3 (`h' = H^2 a4''`); on the FLRW frame (`A = a`, `B = C = 1`, `H_A = a'/a`) they
give `G^4_4 = −3 H_A^2`, `G^i_i = −(2 a''/a + H_A^2)`, `G^0_0 = G^h_h = −3(a''/a + H_A^2)` — the solver
regression of section 4.2.2.

#### 4.3.2 The (0,4) equation singles out the author's volume-preserving structure; it does not derive it

The Einstein equation `G^4_0 = kappa T^4_0` with a source that carries no momentum along `x0`
(`T^4_0 = 0`: required on the canonical frame by theorem (c), and true of the Kohn–Sham fluid, whose
quasiparticles move along the observed sheet only) gives, since `Cot[6 H x0]` is not zero,

```
2 H_C  =  H_A + H_B
```

With the `x0` direction **static** (`C = 1`, a labelled substitution) this is `H_A + H_B = 0`, i.e.
`A B = const`: exactly the author's volume-preserving pairing `A = Exp[-a4]`, `B = Exp[+a4]`. So the
author's ansatz is singled out by the momentum constraint once `C = 1` is imposed; it is **not**
derived, because `C = 1` is itself an assumption. With `C` dynamical the constraint is
`H_C = (H_A + H_B)/2`, and the energy bill changes sign. The Bianchi-I part of `kappa rho = −G^4_4` is
the sum over the 21 pairs of the seven directions:

```
kappa rho  =  -G_x0^4_4/C^2  +  3 H_A^2 + 3 H_B^2 + 9 H_A H_B + 3 H_A H_C + 3 H_B H_C
pair sum  =  -3 H_A^2  < 0                                  on the volume-preserving branch (H_B = -H_A, H_C = 0): section 4.4's negative energy
pair sum  =  (9/2)(H_A^2 + H_B^2) + 12 H_A H_B              on the branch H_C = (H_A + H_B)/2
          =  +(9/2) H_A^2  > 0                              when the hidden sheet is static (H_B = 0)
```

With `C` dynamical a **positive-energy** expansion of the observed sheet is allowed (the `x0`-term
`−G_x0^4_4/C^2` is still negative; section 4.3.3 shows how fast it decays). **[proved VIII §31]**
`(0,4) [THE RESULT]: with T^4_0 = 0 the (0,4) Einstein equation is 2 H_C == H_A + H_B (Cot[6 H x0] is not zero for 0 < 6 H x0 < Pi/2)`,
`(0,4) [THE RESULT]: with C = 1 (labelled substitution) it reads H_A + H_B == 0, i.e. d(A B)/dx4 == 0: the volume-preserving pairing is SINGLED OUT, and the canonical member satisfies it`,
`(0,4) [has content]: kappa rho == -G^4_4 == -G_x0^4_4/C^2 + (sum over the 21 pairs of the seven directions of H_i H_j)`,
`(0,4) [THE RESULT]: the pair sum is -3 H_A^2 on the volume-preserving branch (negative energy) and (9/2)(H_A^2 + H_B^2) + 12 H_A H_B on the branch H_C = (H_A + H_B)/2, i.e. +(9/2) H_A^2 > 0 for a static hidden sheet`.

#### 4.3.3 The asymptotic region, and the decay rates

The proper distance along `x0` at fixed `x4` (`C = 1`) is

```
z  =  Int_0^x0 Tan[6 H y] dy  =  -Log[Cos[6 H x0]]/(6 H),        x0(z) = ArcCos[Exp[-6 H z]]/(6 H)
```

and `6 H x0 -> Pi/2` is `z -> infinity`. In the coordinate `z` the warped metric is **exactly**

```
ds^2  =  C^2 dz^2  +  A^2 (1 - Exp[-12 H z])^(-1/6) dx_obs^2  -  dx4^2  -  B^2 (1 - Exp[-12 H z])^(-1/6) dx_hid^2
```

so it tends to the unwarped Bianchi-I metric, and every `x0`-term of the Einstein tensor decays with
`Cot[6 H x0]^2 = Exp[-12 H z]/(1 − Exp[-12 H z])`. As `6 H x0 -> Pi/2`:

```
G_x0^0_0 ~ 15 H^2 Cot^4,     G_x0^i_i = G_x0^h_h ~ 60 H^2 Cot^2,     G_x0^4_4 ~ 72 H^2 Cot^2,     G^4_0 ~ Cot,     G^0_4 ~ Cot^3
```

Read as a background stress `T_bg = G_x0/(kappa C^2)`, in units of `H^2 Cot^2/(kappa C^2)`:
`rho_bg -> −72`, `P_obs = P_hid -> 60`, `P_C -> 15 Cot^2 -> 0`. If `T_bg` is **not** counted as a source,
the `x0`-terms act on the Bianchi-I evolution equations (5.4) as residual drivers
`kappa (P_i − T/6)|bg -> −12 H^2 Cot^2/C^2` for `A` and for `B`, and `−72 H^2 Cot^2/C^2` for `C`. The present
universe may be treated as the 8-dimensional Bianchi-I region when the background is negligible
against the observer's critical density:

```
kappa |rho_bg| / (3 H_A^2)  ->  24 (H/H_A)^2 Cot^2/C^2  <<  1                (the validity inequality of the models of section 9)
```

**[proved VIII §31]** `ASYMPTOTIC [definition]: z = Int_0^x0 Tan[6 H y] dy == -Log[Cos[6 H x0]]/(6 H), and x0(z) = ArcCos[Exp[-6 H z]]/(6 H) inverts it`,
`ASYMPTOTIC [THE RESULT]: in the coordinate z, g_zz == C^2 exactly and g_ii = A^2 (1 - Exp[-12 H z])^(-1/6), g_hh = -B^2 (1 - Exp[-12 H z])^(-1/6): the metric tends to the unwarped Bianchi-I metric`,
`ASYMPTOTIC [has content]: Cot[6 H x0]^2 == Exp[-12 H z]/(1 - Exp[-12 H z]): every x0-term decays like Exp[-12 H z]`,
`ASYMPTOTIC [THE RESULT]: decay rates as 6 H x0 -> Pi/2: G_x0^0_0/Cot^4 -> 15 H^2, G_x0^i_i/Cot^2 -> 60 H^2, G_x0^h_h/Cot^2 -> 60 H^2, G_x0^4_4/Cot^2 -> 72 H^2; G^4_0/Cot and G^0_4/Cot^3 are free of x0`,
`ASYMPTOTIC [THE RESULT]: in units of H^2 Cot^2/(kappa C^2): rho_bg -> -72, P_obs = P_hid -> 60, P_C/Cot^2 -> 15`,
`ASYMPTOTIC [THE RESULT]: residual drivers kappa (P_i - T/6)|bg -> -12 H^2 Cot^2/C^2 for A and B, and -72 H^2 Cot^2/C^2 for C (if T_bg is not counted as a source)`,
`ASYMPTOTIC [THE RESULT]: validity of 'present universe = Bianchi-I': kappa |rho_bg|/(3 H_A^2) divided by 24 (H/H_A)^2 Cot^2/C^2 -> 1`.

**What the asymptotic reading neglects** [derived here]. The Bianchi-I system below treats the rates
`H_A`, `H_B`, `H_C` as free; the (0,4) equation of 5.2 is then satisfied only to the extent that its
coefficient `3 H Cot[6 H x0] = 3 H Exp[-6 H z]/Sqrt[1 − Exp[-12 H z]]` is negligible. In the stabilized
model of section 4.7 (`H_B = H_C = 0`, `H_A > 0`) the bracket is `2 H_C − H_A − H_B = −H_A`, so at finite `z`
the equation would demand an `x0`-momentum `kappa T^4_0 = −3 H Cot H_A`, of order `Cot` — one power of
`Cot` less suppressed than the diagonal terms of order `Cot^2` in the validity inequality. The author's
constant `H` and the observer's position `z` along `x0` are not fixed by anything in the notebook, so
the size of these terms is a parameter of the reading, not a computed number.

#### 4.3.4 The 8-dimensional Bianchi-I system

In the asymptotic region the primordial field is

```
ds^2  =  C^2 dz^2  +  A^2 (dx1^2 + dx2^2 + dx3^2)  -  dx4^2  -  B^2 (dx5^2 + dx6^2 + dx7^2)
```

and its mixed Einstein tensor does **not** depend on whether the hidden directions are timelike or
spacelike: flipping the three hidden signs of `eta` leaves every `G^mu_nu` unchanged. With the source
`T^mu_nu = diag(P_C, P_obs x3, −rho, P_hid x3)` and `T = −rho + 3 P_obs + 3 P_hid + P_C`, the Einstein
equations are equivalent to

```
constraint:   3 H_A^2 + 3 H_B^2 + 9 H_A H_B + 3 H_A H_C + 3 H_B H_C  =  kappa rho          (-G^4_4 = (Theta^2 - Sum_i H_i^2)/2, the 21 pairs)
evolution:    H_i' + H_i Theta  =  kappa ( P_i - T/6 ),        i = A, B, C,        Theta = 3 H_A + 3 H_B + H_C
```

the evolution form being the Ricci form `R^i_i = kappa (T^i_i − T/(D − 2))` with `D − 2 = 6`, and
`R^4_4 = Sum over the seven directions of (H_i' + H_i^2)`. **[proved VIII §31]**
`BIANCHI-I [THE RESULT]: the mixed Einstein tensor does NOT depend on the signs of the hidden directions (timelike x5..x7 or spacelike: identical G^mu_nu)`,
`BIANCHI-I [THE RESULT]: -G^4_4 == 3 H_A^2 + 3 H_B^2 + 9 H_A H_B + 3 H_A H_C + 3 H_B H_C == (Theta^2 - Sum_i H_i^2)/2, the sum over the 21 pairs of the seven directions`,
`BIANCHI-I [has content]: R^i_i == H_i' + H_i Theta for i = A (x1), B (x5), C (x0), and R^4_4 == Sum over the seven directions of (H_i' + H_i^2)`,
`BIANCHI-I [THE RESULT]: G^mu_nu == kappa T^mu_nu is EQUIVALENT to the constraint sum-over-pairs == kappa rho plus the evolution equations H_i' + H_i Theta == kappa (P_i - T/6), i = A, B, C`
(the sign-flipped geometry took 0.680 s).

The same Bianchi-I Einstein tensor was re-computed numerically, from the metric, in notebook 06
(section 4.2, for test functions `A, B, C`), and every statement agreed to machine precision
**[nb06 §4]**:

```
off-diagonal G^mu_nu = 0                                                         0.00e+00
-G^4_4 - (3HA^2 + 3HB^2 + 9HAHB + 3HAHC + 3HBHC)                                 1.63e-16
R^0_0 - (dH_C/dt + H_C Theta)                                                    2.78e-17
R^1_1 - (dH_A/dt + H_A Theta)                                                    5.55e-17
R^5_5 - (dH_B/dt + H_B Theta)                                                    2.43e-17
G^mu_nu(hidden timelike) - G^mu_nu(hidden spacelike)                             0.00e+00
div T (nu = 4) + (drho/dt + 3HA(rho+P_obs) + 3HB(rho+P_hid) + HC(rho+P_x0))      2.22e-16
the Bianchi-I Einstein tensor, computed from the metric, is the one the solver integrates
```

**Constraint propagation.** With `S` the pair sum, the evolution equations and the conservation law
give `d(S − kappa rho)/dt = −2 Theta (S − kappa rho)`: the constraint decays forward in time (for
`Theta > 0`) and grows backward [file: `fable-cosmology/rust/fable_fermion/src/models.rs`, module
documentation; prose nb06 §4]. The solver therefore monitors the constraint and does not impose it,
and it integrates the unstabilized model forward only (section 4.7.11).

#### 4.3.5 The 8-dimensional conservation law for anisotropic pressures

The source must obey the `nu = 4` component of `nabla_mu T^mu_nu = 0`:

```
rho' + 3 H_A (rho + P_obs) + 3 H_B (rho + P_hid) + H_C (rho + P_C)  =  0
```

and the other seven components vanish identically for a diagonal, `x4`-dependent source.
**[proved VIII §31]** `BIANCHI-I [THE RESULT]: 8D conservation for anisotropic pressures -- nabla_mu T^mu_4 == -(rho' + 3 H_A (rho + P_obs) + 3 H_B (rho + P_hid) + H_C (rho + P_C)), and the other seven components vanish identically`.
Radiation (on the observed sheet: `P_obs = rho_r/3`, `P_hid = P_C = 0`) obeys it with
`rho_r propto A^-4 (B^3 C)^-1`, and baryons (dust in every direction) with `rho_b propto A^-3 (B^3 C)^-1`
[file: `fable-cosmology/rust/fable_fermion/src/models.rs`, module documentation]; section 4.5.5 proves it
for the Kohn–Sham fable.

### 4.4 The canonical spin connection of the interacting system: a complete discussion

The spin connection is discussed in full in two parts. The first part is the **canonical** spin
connection of the 4+4 pre-universe: the frame it comes from, how it is computed, every non-zero
component, its 16×16 spinor form, the gauge-covariant derivative of the 16-component spinor, how it
relates to the three bridges of Part IV and to the fable-5.1 (Weitzenböck) bridge of Part V, and what
it does and does not do for the complex fermion fable. It is identical for Efforts A and B and is
section 3.8 of this document (subsections 3.8.1–3.8.13), which Effort B uses as it stands. The second part,
subsections 4.4.1–4.4.9 below, is the spin connection of the **interacting system**: the connection of
the generalized warped frame and of the 8-dimensional Bianchi-I frame on which fable acts back on the
primordial field (section 4.3), with every non-zero component, its action on the Dirac operator, its
Weitzenböck form, the rescaling that removes it, the anticommutator of the rescaled field, its
relation to the fundamental symmetry `J`, and the recovery of the canonical connection. Every object is
defined here or in section 3.8, and every result is restated with the place where it is proved.

Throughout, "Section n" (capital S) means a section of the notebook.

#### 4.4.1 The interacting system: the same solver on two new frames

The spin connection of the frames on which fable acts back (section 4.3) is computed exactly as every
connection of Parts III–VI was: the vielbein postulate of subsection 3.8.5, solved by
`cfSpinConnection` with the Christoffel symbols of each frame, lowered with `eta4488` by
`cfLowerFirstFlat`, checked by the postulate residual (a regression test of the solver) and by
antisymmetry (metric compatibility, which has content), and turned into the 16×16 matrices
`Gamma_mu = (1/8) omega_{mu ab} [T16[a], T16[b]]` by Section 17's `cfSpinMatrix` [prose VIII §32]. This
is Section 32 of the notebook (Input cells 208–210, 26 assertions, 4.694 s). The two frames are the
warped frame of section 4.3.1,

```
e_warped = diag( Tan[6 H x0] C,  A S^(-1/6) x3,  1,  B S^(-1/6) x3 ),        S = Sin[6 H x0]
```

and the 8-dimensional Bianchi-I frame `e_BI = diag(C, A, A, A, 1, B, B, B)` of section 4.3.4 (the
connections took 0.709 s and 0.509 s). **[proved VIII §32]**
`SPIN CONNECTION [solver regression]: the vielbein-postulate residual is zero on the warped and on the Bianchi-I frame`,
`SPIN CONNECTION [has content]: omega_mu[a,b] == -omega_mu[b,a] on both frames (metric compatibility)`.

#### 4.4.2 Every non-zero component of the connection of the interacting system

On the **warped** frame, with `c = Cos[6 H x0]`, `S = Sin[6 H x0]` and `' = d/dx4`, the complete list is
thirteen independent components and their antisymmetric partners:

| component (both flat indices down, as the array the notebook compares) | value |
|---|---|
| `omega[0; 0,4] = −omega[0; 4,0]` | `Tan[6 H x0] C'` |
| `omega[i; 0,i] = −omega[i; i,0]`, `i = 1,2,3` | `H c^2 A / (C S^(13/6))` |
| `omega[i; i,4] = −omega[i; 4,i]`, `i = 1,2,3` | `A' / S^(1/6)` |
| `omega[h; 0,h] = −omega[h; h,0]`, `h = 5,6,7` | `−H c^2 B / (C S^(13/6))` |
| `omega[h; 4,h] = −omega[h; h,4]`, `h = 5,6,7` | `B' / S^(1/6)` |

`1 + 3 + 3 + 3 + 3 = 13` independent components, 26 non-zero entries of the 512. The first is
**new**: the canonical frame (`C = 1`) has no connection along `x0` at all. On the **Bianchi-I** frame
only seven survive:

```
omega[0; 0,4] = C',        omega[i; i,4] = A'   (i = 1,2,3),        omega[h; 4,h] = B'   (h = 5,6,7)
```

**[proved VIII §32]** `SPIN CONNECTION [THE RESULT]: the complete list of non-zero omega_mu^{ab} of the WARPED frame is the thirteen stated components (and their antisymmetric partners) -- nothing else`,
`SPIN CONNECTION [THE RESULT]: the complete list for the Bianchi-I frame is omega_0^{04} = C', omega_i^{i4} = A', omega_h^{4h} = B' -- nothing else`,
`SPIN CONNECTION [fidelity]: on the canonical member (labelled substitution) the warped connection IS omegaCanonical of Section 16, and the new component omega_0^{04} vanishes there`.

**Index position.** The notebook's Text cell and the two labels write these components as
`omega_mu^{ab}`; the assertion compares them with `cfOmegaWarp = cfLowerFirstFlat[...]`, whose two flat
indices are both **down**, and the table above is that array [file: `claude-fable/cells_part8.wl`,
the lists `cfOmegaWarpList`, `cfOmegaBIList` and the assertion that uses them]. Raising both flat indices
with `eta4488` leaves the `(0,i)` and `(4,h)` planes unchanged and flips the sign of the `(i,4)`, `(0,4)`
and `(0,h)` planes [derived here: one index of each of those planes is timelike]. **Recovery**
[derived here, and asserted by the fidelity label above]: at `A = Exp[-a4]`, `B = Exp[+a4]`, `C = 1`,
`A' = −H a4' Exp[-a4]` and `B' = +H a4' Exp[a4]`, so `omega[i; 4,i] = H a4'/(E^A s^(1/6))` and
`omega[h; 4,h] = E^A H a4'/s^(1/6)` with `A = a4[H x4]`: the 24 non-zero components of subsection 3.8.6.

#### 4.4.3 The spinor connection of the interacting system

With `Gamma_mu = (1/2) Sum_{a<b} omega_{mu ab} T16[a].T16[b]` (subsection 3.8.7), the table gives
[derived here]:

```
Gamma_0 = (1/2) Tan[6 H x0] C' T16[0].T16[4]
Gamma_i = (1/2) [ H c^2 A/(C S^(13/6)) T16[0].T16[i]  +  (A'/S^(1/6)) T16[i].T16[4] ]          i = 1,2,3
Gamma_4 = 0
Gamma_h = (1/2) [ -H c^2 B/(C S^(13/6)) T16[0].T16[h]  +  (B'/S^(1/6)) T16[4].T16[h] ]          h = 5,6,7
```

The first and last lines are asserted: `Gamma_x4 = 0`, and `Gamma_x0` is not zero as soon as the `x0`
direction is dynamical. `Gamma_mu` rotates the Dirac matrices as `omega` rotates a vector, and the
curved `gamma^mu` are covariantly constant on the warped frame. **[proved VIII §32]**
`DIRAC [THE RESULT]: Gamma_x4 == 0, and Gamma_x0 == (1/2) Tan[6 H x0] C'(x4) T16[0].T16[4], which is NOT zero when C varies (witnessed on C = 1 + x4^2/3)`,
`SPIN CONNECTION [has content]: Gamma_mu rotates the Dirac matrices as omega rotates a vector, [Gamma_mu, T16[a]] == -omega_mu^a_b T16[b], on the warped frame`,
`SPIN CONNECTION [has content]: the curved gamma^mu are covariantly constant on the warped frame, D_mu gamma^nu == 0`.

#### 4.4.4 What the connection of the interacting system does to the Dirac operator

The whole connection enters the Dirac operator as **one** matrix:

```
gamma^mu Gamma_mu  =  -(3 H Cot[6 H x0]^2 / C) T16[0]  +  (1/2) ( 3 H_A + 3 H_B + H_C ) gamma^4,        gamma^4 = T16[4]      (warped frame)
gamma^mu Gamma_mu  =  (1/2) ( 3 H_A + 3 H_B + H_C ) T16[4]                                                                      (Bianchi-I frame)
```

The first term is the canonical term of subsection 3.8.8 divided by `C`; the second is the Hubble
(dilution) term of an expanding 7-volume — with the **plus** sign; the opposite sign fails. And
`{gamma_mu, Gamma_mu} = 0` for **each** `mu` separately on both frames, so the symmetrized Lagrangian
of section 4.1.2 is the same with `D_mu` as with `d_mu` there, for fields of all eight coordinates and every
`V`. **[proved VIII §32]** `DIRAC [THE RESULT]: gamma^mu Gamma_mu == -(3 H Cot^2/C) T16[0] + (1/2)(3 H_A + 3 H_B + H_C) gamma^4 on the warped frame, and gamma^4 == T16[4]`,
`DIRAC [control]: the opposite sign of the Hubble term FAILS (witnessed on A = 1 + x4/2, B = 1 + x4/3, C = 1 + x4^2/3)`,
`DIRAC [THE RESULT]: on the Bianchi-I frame gamma^mu Gamma_mu == (1/2)(3 H_A + 3 H_B + H_C) T16[4]: the pure Hubble term of an expanding 7-volume`,
`DIRAC [THE RESULT]: {gamma_mu, Gamma_mu} == 0 for EACH mu separately, on the warped and on the Bianchi-I frame`,
`DIRAC [THE RESULT]: hence Section 26's symmetrized Lagrangian is the same with D_mu as with d_mu on the warped frame, for Psi, Psibar of all eight coordinates (cfPsiC8, cfPsiB8) and every V`.

**Direction by direction** [derived here, from subsection 4.4.3 and the coframe
`gamma^0 = Cot T16[0]/C`, `gamma^i = S^(1/6) T16[i]/A`, `gamma^4 = T16[4]`, `gamma^h = S^(1/6) T16[h]/B`, using
`T16[i]^2 = +1`, `T16[h]^2 = −1` and the anticommutation of distinct `T16`]:

| `mu` | `gamma^mu Gamma_mu` (no sum), warped frame | on the canonical member |
|---|---|---|
| `0` | `(1/2) H_C T16[4]` | `0` |
| `i = 1,2,3` | `−(1/2)(H Cot^2/C) T16[0] + (1/2) H_A T16[4]` | `−(1/2) H Cot^2 T16[0] − (1/2) H a4' T16[4]` |
| `4` | `0` | `0` |
| `h = 5,6,7` | `−(1/2)(H Cot^2/C) T16[0] + (1/2) H_B T16[4]` | `−(1/2) H Cot^2 T16[0] + (1/2) H a4' T16[4]` |

The sum over the seven directions is the asserted `−(3 H Cot^2/C) T16[0] + (1/2) Theta T16[4]`, and the
last column is subsection 3.8.8's table.

#### 4.4.5 The Weitzenböck form, and the rescaling that removes the connection

Computed as in Part V — the torsion of the connection in which the frame is parallel,
`T^a_{mu nu} = d_mu e_nu^a − d_nu e_mu^a`, pulled to curved indices and traced, `T_mu = T^nu_{nu mu}` —
the torsion vector of the warped frame is a **gradient**, and it carries the whole connection term of
the Dirac operator:

```
T_mu  =  d_mu Log[ Sin[6 H x0] / (A^3 B^3 C) ],        gamma^mu Gamma_mu  =  -(1/2) T_mu gamma^mu
```

(on the canonical member it is Part V's torsion vector `d_mu Log[Sin[6 H x0]]`). Hence the rescaling

```
Psi  =  Sqrt[Sin[6 H x0]] (A^3 B^3 C)^(-1/2) chi        gamma^mu D_mu Psi  =  Sqrt[Sin[6 H x0]] (A^3 B^3 C)^(-1/2) gamma^mu d_mu chi
```

removes the connection from the Dirac operator **exactly**, for a generic `chi(x0, ..., x7)`.
**[proved VIII §32]** `WEITZENBOECK [THE RESULT]: the torsion vector of the warped frame is a GRADIENT, T_mu == d_mu Log[Sin[6 H x0]/(A^3 B^3 C)]; on the canonical member it is Part V's torsionVectorFable51`,
`WEITZENBOECK [THE RESULT]: gamma^mu Gamma_mu == -(1/2) T_mu gamma^mu on the warped frame -- one vector term, a gradient`,
`RESCALING [THE RESULT]: gamma^mu D_mu [Sqrt[Sin[6 H x0]] (A^3 B^3 C)^(-1/2) chi] == Sqrt[Sin[6 H x0]] (A^3 B^3 C)^(-1/2) gamma^mu d_mu chi for a GENERIC chi(x0, ..., x7): the connection is removed exactly`
(the torsion took 0.078 s). The frame-independent form of subsection 3.8.12.3,
`T_mu = d_mu ln(e_mu^mu/det e)` for a diagonal frame, gives the same vector [derived here:
`det e = Tan[6 H x0] C A^3 B^3/S`; for `mu = 0`, `e_0^0/det e = S/(A^3 B^3)`, whose `x0`-derivative is
`6 H Cot[6 H x0]`; for `mu = 4`, `e_4^4 = 1` and `−d_4 ln det e = −Theta`, so `−(1/2) T_4 gamma^4 = (1/2) Theta T16[4]`].
The factor `(A^3 B^3 C)^(-1/2)` is the square root of the comoving 7-volume: the dilution of the density
of an expanding 7-volume.

#### 4.4.6 The anticommutator of the rescaled field is independent of `x4`

The anticommutator of section 4.1.4 carries over to the warped family because its derivation is local
in time and the lapse is still 1 with `gamma^4 = T16[4]`: the time-derivative part is
`Psi^ddag K d_4 Psi` with `K = (Sqrt[|det g|]/H) sigma16 T16[4]`, and Section 28's Dirac-bracket result
for `K = c sigma16 T16[4]` with `c = Sqrt[|det g|]/H` gives

```
{Psi_a(x), Psi^ddag_b(y)}  =  (H/Sqrt[|det g|]) G_ab delta^7(x - y),        G = -i sigma16 T16[4] = J      (the same matrix on every member)
Sqrt[|det g|]  =  Tan[6 H x0] C A^3 B^3 / Sin[6 H x0]
{chi_a(x), chi^ddag_b(y)}  =  H Cot[6 H x0] G_ab delta^7(x - y)                                            (independent of x4 and of A, B, C)
```

— the `Sqrt[det g]` cancels against the rescaling; on the canonical member this is Section 28's
`H Cot[6 H x0] J`. So the field to quantize on the dynamical frames is `chi`, whose canonical structure
does not change as the universe expands. **[proved VIII §32]**
`RESCALING [has content]: det g == (det e)^2 and det e == Tan[6 H x0] C A^3 B^3 / Sin[6 H x0] > 0, so Sqrt[|det g|] == Tan[6 H x0] C A^3 B^3 / Sin[6 H x0] on the warped frame`,
`RESCALING [has content]: on the warped frame G = -i sigma16 gamma^4 is Section 28's cfGK (= J) -- the same matrix on every member of the family (gamma^4 == T16[4], lapse 1)`,
`RESCALING [THE RESULT]: {Psi, Psi^ddag} == (H/Sqrt[|det g|]) G on the warped frame (Section 28's cfAntiPsiPsiDd at c = Sqrt[|det g|]/H), and for chi = Psi/f, f = Sqrt[Sin] (A^3 B^3 C)^(-1/2): {chi, chi^ddag} == H Cot[6 H x0] G -- the Sqrt[det g] cancels, independent of x4 and of A, B, C`.

(Two uses of the letter `chi` must be kept apart in this document: here `chi` is the rescaled field of the
dynamical frame; in sections 4.1.6 and 4.5 `chi = Psi/Sqrt[H]` is the canonically normalized field of the
Kohn–Sham gas.)

#### 4.4.7 The fundamental symmetry `J` and the connection of the interacting system

`J = −i T16[0].T16[1].T16[2].T16[3].T16[4]` (Hermitian, `J^2 = 1`) commutes with `T16[0..4]` and
anticommutes with `T16[5..7]`. The connection of the interacting system respects this split,
direction by direction, on the warped **and** on the Bianchi-I frame:

| object | relation to `J` | on both frames |
|---|---|---|
| `Gamma_0` (now `(1/2) Tan C' T16[0].T16[4]`, non-zero when `C` varies) | commutes | both factors in `{0..4}` |
| `Gamma_1`, `Gamma_2`, `Gamma_3` | commute | made of `T16[0].T16[i]`, `T16[i].T16[4]` |
| `Gamma_4` | commutes | zero |
| `Gamma_5`, `Gamma_6`, `Gamma_7` | **anticommute**, and they are **not zero** | made of `T16[0].T16[h]`, `T16[4].T16[h]` |
| each `gamma^mu Gamma_mu` (no sum), `h = 5, 6, 7` included | commutes | each is a combination of `T16[0]` and `T16[4]` |

So every connection term of the admissible-sector Hamiltonian is `J`-even on the frames of the
interacting system, as on the canonical one. **[proved VIII §32]**
`J [definition]: Section 28's J = -i T16[0]...T16[4] is Hermitian with J^2 == 1; it commutes with T16[0..4] and anticommutes with T16[5..7]`,
`J [THE RESULT]: [J, gamma^mu Gamma_mu] == 0 for EACH mu separately (h = 5,6,7 included), on the warped and on the Bianchi-I frame`,
`J [THE RESULT]: [J, Gamma_mu] == 0 for mu = 0..4 and {J, Gamma_h} == 0 for h = 5, 6, 7, on the warped and on the Bianchi-I frame`,
`J [has content]: the anticommuting Gamma_h are not zero (witnessed on A = 1 + x4/2, B = 1 + x4/3, C = 1 + x4^2/3), so {J, Gamma_h} == 0 is not vacuous`.

#### 4.4.8 Recovery of the canonical connection, and why Part VI had no dilution

On the canonical member (labelled substitution) `Gamma_mu` **is** Section 17's `GammaSpinCanonical` in
every direction, and `gamma^mu Gamma_mu` is `−3 H Cot^2 T16[0]`. The Hubble coefficient vanishes there:
`3 H_A + 3 H_B + H_C = −3 H a4' + 3 H a4' + 0 = 0` — the 7-volume of the canonical frame is constant in
`x4`. That is why Part VI found no dilution (`ds/dx4 = 0`) on the pre-universe: the dilution term is
present in the general frame and cancels exactly on the author's. **[proved VIII §32]**
`RECOVERY [fidelity]: on the canonical member (labelled substitution) Gamma_mu IS Section 17's GammaSpinCanonical for every mu, and gamma^mu Gamma_mu IS Section 24's -3 H Cot^2 T16[0]`,
`RECOVERY [THE RESULT]: the Hubble coefficient 3 H_A + 3 H_B + H_C vanishes on the canonical member -- the canonical 7-volume is constant in x4, which is why Part VI had no dilution`,
`PART VIII [control]: a4 is STILL UNDEFINED after Section 32, and the scale factors scA, scB, scC have no values either`.

#### 4.4.9 Status ledger of the connection of the interacting system

| statement | status | where |
|---|---|---|
| warped and Bianchi-I connections from the vielbein postulate; residual zero; antisymmetric | proved | VIII §32 (`SPIN CONNECTION [solver regression]`, `[has content]`) |
| the complete lists: 13 independent components (warped), 7 (Bianchi-I); the new `omega[0; 0,4] = Tan C'` | proved | VIII §32 (`SPIN CONNECTION [THE RESULT]`) |
| the explicit `Gamma_mu` of 6.16 | derived here; `Gamma_0`, `Gamma_4` proved | VIII §32 (the `DIRAC` assertion on `Gamma_x4` and `Gamma_x0`) |
| `gamma^mu Gamma_mu = −(3 H Cot^2/C) T16[0] + (1/2) Theta gamma^4`; the sign of the Hubble term | proved (with control) | VIII §32 (`DIRAC`) |
| per-`mu` `{gamma_mu, Gamma_mu} = 0`; symmetrized Lagrangian `D = d` | proved | VIII §32 (`DIRAC`) |
| the per-direction table of 6.17 | derived here | — |
| Weitzenböck gradient form; exact rescaling by `Sqrt[Sin] (A^3 B^3 C)^(-1/2)` | proved | VIII §32 (`WEITZENBOECK`, `RESCALING`) |
| `x4`-independent anticommutator `H Cot[6 H x0] G` of `chi` | proved | VIII §32 (`RESCALING [THE RESULT]`) |
| the `J` table on both frames | proved | VIII §32 (`J`) |
| recovery of the canonical connection; the Hubble coefficient vanishes on it | proved | VIII §32 (`RECOVERY`) |

### 4.5 The fable source in the Kohn–Sham ground state

This is Section 33 of the notebook, first half (Input cells 211–214, 25 assertions), with the
numerical checks of notebook `05_fermion_fable_quantum_eos.ipynb` and the solver's own statements
[file: `fable-cosmology/rust/fable_fermion/src/kohn_sham.rs` and `potentials.rs`, module
documentation]. The expectation value `<That^mu_nu>` of section 4.2.1 is taken in the Kohn–Sham ground
state of section 4.1.6: a homogeneous Fermi sea at zero temperature, `g = 8` states per spatial
momentum, momenta along the observed sheet only (zero modes along `x0`, `x5`, `x6`, `x7` — the
admissible sector of section 4.1.4), in the mean field `m = W'(sigma)` of the potential
`W(sigma) := V(H sigma)`, `sigma = <chibar chi>`, `chi = Psi/Sqrt[H]` [prose VIII §33]. In the
asymptotic region of section 4.3.3 the metric is 8-dimensional Bianchi-I and this source is diagonal.

#### 4.5.1 Densities per 7-volume, and the gap equation

The closed forms of section 4.1.6 are densities per unit **observed** 3-volume. Spread over the hidden
4-volume they become densities per 7-volume. With the hidden volume factor

```
v  =  B^3 C / (B^3 C)_today          (v = 1 today in every run; the solver's normalization)
```

the fluid that sources the Einstein equations is [prose VIII §33]

```
sigma7  =  sigma_KS / v                          (the solver calls it sigma8: the scalar density per 7-volume)
gap:    m  =  W'(sigma7)
rho     =  eps_KS/v + W(sigma7) - sigma7 W'(sigma7)        ( = 3 P_KS/v + W(sigma7)  on the gap )
P_obs   =  P_KS/v + sigma7 W' - W                           (along x1, x2, x3)
P_hid   =  P_C  =  sigma7 W' - W                             (along x5, x6, x7 and x0: the gas has no momentum there)
```

At `v = 1` this is Section 29's mean field; the massless limit is `sigma -> 0`, `eps = 3 P = g k_F^4/(8 pi^2)`.
The couplings of `W` run as 4-dimensional couplings, `lam_4 = lam_8/V_hid`, and
`kappa_4,0 = kappa_8/V_h,0` [file: `models.rs`, module documentation]. **[proved VIII §33]**
`KS FLUID [fidelity]: at v = 1 the fluid IS Section 29's mean field: rho = eps_KS + W - sigma W', P_obs = P_KS + sigma W' - W, P_hid = sigma W' - W`,
`KS FLUID [fidelity]: Section 29's identities, re-checked where they are used -- eps + P == wF n, eps - 3 P == m sigma, T_s = eps - m sigma == 3 P, d eps/dm == sigma, d eps/dkF == wF dn/dkF`,
`KS FLUID [THE RESULT]: ON THE GAP m = W'(sigma7), rho == 3 P_KS/v + W(sigma7) (Section 29's trace identity, per 7-volume), and P_obs - P_hid == P_KS/v, for every W`,
`KS FLUID [has content]: the massless limit m -> 0+: sigma_KS -> 0 and eps_KS = 3 P_KS -> g kF^4/(8 pi^2)`.

**Negative `m`.** `sigma_KS` is odd in `m` and `eps_KS`, `P_KS` are even. Under `m -> −m`,
`sigma -> −sigma` and `W(x) -> W~(x) := W(−x)` the fluid is unchanged and the gap `m = W'(sigma7)` goes
into `−m = W~'(−sigma7)`; so every statement proved for `m > 0` and an arbitrary `W` holds for `m < 0`
as well. **[proved VIII §33]** `KS FLUID [THE RESULT]: NEGATIVE m -- the fluid is invariant under sigma -> -sigma, W(x) -> W~(x) = W(-x), and the gap m = W'(sigma7) becomes -m = W~'(-sigma7); with sigma_KS odd and eps_KS, P_KS even in m (Section 29) the case m < 0 reduces to m > 0`.

**Why per 7-volume, and not per 3-volume.** The solver's unit test
`kohn_sham::tests::per_3_volume_mean_field_violates_8d_conservation` checks that the per-3-volume
prescription violates the 8-dimensional conservation law of section 4.3.5 [file:
`fable-cosmology/rust/fable_fermion/src/kohn_sham.rs`]; the per-7-volume one obeys it exactly (7.5).

#### 4.5.2 The Fermi-sea integrals, their stable forms, and their accuracy

The closed forms of section 4.1.6 cancel catastrophically for `x = k_F/|m| << 1` (`eps ~ m n`, `sigma ~ n`,
`P ~ n k_F^2/(5 m)` are small differences of large terms). The solver uses three regimes, written with
`S(x) = 2 Int_0^x t^2/Sqrt[1+t^2]`, `E(x) = 8 Int_0^x t^2 Sqrt[1+t^2]`, `Q(x) = 8 Int_0^x t^4/Sqrt[1+t^2]`,
`sigma = g m^3 S/(4 pi^2)`, `eps = g m^4 E/(16 pi^2)`, `P = g m^4 Q/(48 pi^2)` [file: `kohn_sham.rs`, module
documentation]:

| regime | form used |
|---|---|
| `x < X_LO = 0.6` | the convergent binomial series (radius 1) in `x^2`; e.g. `eps = \|m\| n [1 + (3/10) x^2 − (3/56) x^4 + ...]`, `sigma = sgn(m) n [1 − (3/10) x^2 + ...]` |
| `0.6 <= x <= X_HI = 100` | the closed forms (`asinh x = L`), losing at most about 1.3 digits at `x = 0.6` |
| `x > 100` | the ultra-relativistic series in `y = \|m\|/k_F`, with the logarithm kept exact |
| `m = 0` exactly | `sigma = 0`, `eps = 3 P = g k_F^4/(8 pi^2)`, `chi = d sigma/dm = g k_F^2/(4 pi^2)` |

Notebook 05 compared them with adaptive quadrature from `x = 1e-8` to `1e6` and with the Rust solver
**[nb05 §5.1]**:

```
max relative error of the stable forms against quadrature over 1e-8 <= x <= 1e6: 9.88e-14 (at x = 0.251)
  x =     1e-08:  stable rel. errors (sigma, eps, P) = 0.0e+00 0.0e+00 0.0e+00   closed forms: 1.5e+00 2.4e-01 4.1e+16
  x =     1e-06:  stable rel. errors (sigma, eps, P) = 1.1e-16 1.1e-16 4.4e-16   closed forms: 7.8e-05 1.8e-06 2.6e+08
  x =    0.0001:  stable rel. errors (sigma, eps, P) = 0.0e+00 2.2e-16 2.2e-16   closed forms: 7.8e-09 1.5e-09 1.0e+00
  x =      0.01:  stable rel. errors (sigma, eps, P) = 2.2e-16 2.2e-16 3.3e-16   closed forms: 4.4e-13 1.1e-13 5.4e-09
  x =     0.251:  stable rel. errors (sigma, eps, P) = 4.3e-15 1.8e-15 9.9e-14   closed forms: 4.3e-15 1.8e-15 9.9e-14
  x =         1:  stable rel. errors (sigma, eps, P) = 0.0e+00 0.0e+00 2.2e-16   closed forms: 0.0e+00 0.0e+00 2.2e-16
  x =       100:  stable rel. errors (sigma, eps, P) = 0.0e+00 1.1e-16 2.2e-16   closed forms: 0.0e+00 1.1e-16 2.2e-16
  x =     1e+06:  stable rel. errors (sigma, eps, P) = 1.1e-16 2.2e-16 2.2e-16   closed forms: 1.1e-16 2.2e-16 2.2e-16
```

and against the Rust solver's `gap` command at fifteen points from `x = 1e-8` to `1e6`:
`largest relative difference Rust - Python over these 15 points: 3.11e-14`.

(the closed forms are wrong by a factor `4.1e16` in `P` at `x = 1e-8`; the stable forms are exact there).
The thermodynamic identities hold to rounding **[nb05 §5.3, file: `fable-cosmology/results/nb05_identities.csv`]**:

| identity | largest residual |
|---|---|
| `eps − 3P − m sigma` (relative to `eps`) | `1.532e-15` |
| `eps + P − wF n` (relative) | `5.551e-16` |
| `d eps/dn\|_m − wF` (relative, central differences) | `7.439e-11` |
| `d eps/dm\|_kF − sigma` (relative, central differences) | `3.610e-08` |
| `chi − d sigma/dm` (relative) | `2.633e-07` |
| `max chi/chi0` | `1.000e+00` |

and `w_KS = P_KS/eps_KS` rises from `2.000000e-17` at `x = 1e-8` (`x^2/5 = 2.000000e-17`) through `0.121969`
at `x = 1` to `0.333333333332667` at `x = 1e6` (`1/3 − 2/(3 x^2)`) **[nb05 §5.2]**; figures
`fable-cosmology/results/nb05_ks_accuracy.png`, `nb05_w_ks.png`.

#### 4.5.3 The gap equation: uniqueness, branch selection, parameter domains

`f(m) = m − W'(sigma_KS(m, k_F)/v)`. Since `sigma_KS` is odd and increasing in `m` with slope
`chi = d sigma_KS/dm <= chi0 = g k_F^2/(4 pi^2)`, `f' = 1 − W'' chi/v`: the root is **unique** when `W'' <= 0`
(attractive, concave `W`) or when `W'' chi0/v < 1`; otherwise there can be several roots [prose nb05 §4;
file: `kohn_sham.rs`, module documentation]. Every potential states where its roots can lie and whether
the root is provably unique there (`Potential::gap_plan` in `potentials.rs`). The adopted parameter
domains (design review DFT-16): `expdamp` `m0 > 0`, `s1 > 0` (the gap then pins `0 < sigma < min(n, s1)`
strictly); `power` `lam > 0`, `0 < nu < 1`, `sigma` in `(0, n)` (the bare mass `m0` may come out negative:
section 4.7.8); `quadratic` `lam < 0` unique, `lam > 0` all roots enumerated.

**Branch selection.** When several roots exist, the solver takes the one of **lowest** energy density
`rho` — not the minimum of the Kohn–Sham energy `E_n[sigma]` over `sigma` in `(−n, n)`. The no-sea
functional is a minimax: its kinetic part `T_s = eps_KS(m(sigma)) − m(sigma) sigma` is **concave**
(`d^2 T_s/d sigma^2 = −1/chi < 0`), so the physical root is a **maximum** of `E_n` over `sigma`, and its
infimum is the variational collapse `E_n -> −|m0| n` as `sigma -> −n` (every particle in the negative-mass
band, i.e. in states of the Dirac sea). For attractive `W` the auxiliary-field **Walecka functional**
`Omega_n(m) = eps_KS(m) + W(sigma_m) − m sigma_m`, `W'(sigma_m) = m`, is convex and minimized at the gap
root, with `Omega_n(m*) = rho`. The numbers are in section 4.6.1.

#### 4.5.4 The energy–momentum tensor's expectation: `rho`, `P_obs`, `P_hid`, and `w`

On the gap:

```
rho    =  3 P_KS/v + W(sigma7)                 (Section 29's trace identity eps - 3P = m sigma, per 7-volume)
P_obs  =  P_KS/v + sigma7 W' - W
P_hid  =  P_C  =  sigma7 W' - W
P_obs - P_hid  =  P_KS/v  >= 0                 (for every W: the Fermi gas can source a4'' < 0, section 4.6)
w_f    =  P_obs/rho
```

The split `rho = rho_qp + rho_U` with `rho_qp := eps_KS/v` (quasiparticles, `w_qp = w_DM = P_KS/eps_KS` in
`[0, 1/3]`) and `rho_U := W − sigma7 W'` (the mean-field condensate, with `P = −rho_U` along **all seven**
spatial directions: an 8-dimensional vacuum energy that varies with `sigma`) is a **convention**
[prose nb06 §3; file: `kohn_sham.rs`]. Section 4.5.10 defines the dark-matter and dark-energy
equations of state built on it.

#### 4.5.5 Theorem: the Kohn–Sham fluid is exactly conserved in 8-dimensional Bianchi-I

The fable number in a comoving 7-volume, `(n_KS/v) A^3 v = n_KS A^3`, is conserved, so `k_F = k_F0/A`.
Take `A, B, C` and the mass `m(x4) > 0` as **arbitrary** functions and `W` arbitrary. Then, identically,

```
rho' + 3 H_A (rho + P_obs) + (3 H_B + H_C)(rho + P_hid)  =  sigma7 d/dx4 [ m - W'(sigma7) ]
```

The right-hand side is the time derivative of the gap equation; on the self-consistent solution it
vanishes at every `x4`, so the Kohn–Sham fluid obeys section 4.3.5's conservation law (with `P_C = P_hid`)
**exactly**, for every `W` — the Einstein equations with this source are consistent. The mechanism:
`rho + P_obs = w_F n_KS/v` and `rho + P_hid = eps_KS/v` hold identically, `d eps = w_F dn + sigma dm`, and the
gap cancels the `sigma dm` term against the variation of `W`. Off the gap the fluid is **not** conserved.
**[proved VIII §33]** `CONSERVATION [definition]: the fable number per comoving 7-volume, (n_KS/v) A^3 B^3 C, is constant when kF = kF0/A`,
`CONSERVATION [has content]: rho + P_obs == wF n_KS/v and rho + P_hid == eps_KS/v identically (no gap needed)`,
`CONSERVATION [THE RESULT]: rho' + 3 H_A (rho + P_obs) + (3 H_B + H_C)(rho + P_hid) == sigma7 d/dx4[m - W'(sigma7)] IDENTICALLY, for arbitrary A, B, C, m(x4) > 0 and W: the KS fluid is exactly conserved on the gap`,
`CONSERVATION [control]: without the gap the fluid is NOT conserved -- the left side is not identically zero (witnessed on A = 1 + x4/2, B = 1 + x4/3, C = 1 + x4^2/3, m = 2 + x4, W = sigma^2, kF0 = 1, g = 8)`.

The solver's form of the same law: `d rho_8 = w_F dn/v − (eps/v) d ln v`, so at fixed `v`,
`d rho_8/d n_8 = w_F` [file: `kohn_sham.rs`, module documentation]; its unit test
`kohn_sham::tests::thermodynamic_identities_at_the_self_consistent_point` and the end-to-end test
`covariant_conservation_along_real_fable8d_runs` check it [file: `kohn_sham.rs`, `tests/cosmology.rs`].

#### 4.5.6 The hidden-sheet driver

With `P_C = P_hid`, section 4.3.4's evolution equations for `B` and `C` both read

```
H_B' + H_B Theta  =  H_C' + H_C Theta  =  kappa F/6,        F  =  rho - 3 P_obs + 2 P_hid
```

`F` is the driver of the hidden sheet:

| source | `F` |
|---|---|
| radiation (`P_obs = rho/3`, `P_hid = 0`) | `0` |
| dust | `rho` |
| an 8-dimensional vacuum energy (all seven pressures `−rho`; a bare `V0`, the condensate `rho_U`) | `2 rho` |
| the Kohn–Sham fable, on the gap | `2 W − sigma7 W'` (off the gap: `sigma7 (m − W') + 2 W − sigma7 W'`) |
| the author's mass term `W = m0 sigma` | `m0 sigma7` (like dust) |
| `W = V0 + m0 sigma` | `2 V0 + m0 sigma7` |

**[proved VIII §33]** `DRIVER [THE RESULT]: with P_C = P_hid, kappa (P_hid - T/6) == kappa (P_C - T/6) == kappa F/6, F = rho - 3 P_obs + 2 P_hid: the right-hand side of the B and C equations`,
`DRIVER [has content]: F == 0 for radiation, F == rho for dust, F == 2 rho for an 8D vacuum`,
`DRIVER [THE RESULT]: for the KS fluid F == sigma7 (m - W') + 2 W - sigma7 W' identically, i.e. F == 2 W - sigma7 W' on the gap; the mass term gives F == m0 sigma7 (dust-like), W = V0 + m0 sigma gives 2 V0 + m0 sigma7`.

#### 4.5.7 Theorem: a frozen hidden sheet makes the fable radiation

Given `H_B = H_C = 0` at one time, the hidden sheet stays **frozen** for all time iff `F = 0` along the
history; for the Kohn–Sham fluid, for all `sigma7` the history sweeps, iff `sigma W' = 2 W`, i.e.
`W = c sigma^2`. The gap is then `m = 2 c sigma7`, and `m = 0` is always a root. For `c < 0` it is the only
one (`m sigma_KS > 0` for `m != 0`, so a root `m != 0` would give `m^2 = 2 c (m sigma_KS)/v < 0`). For
`c > 0` a non-trivial root exists iff `c g k_F^2/(2 pi^2 v) > 1` (`sigma_KS/m` decreases strictly, from
`g k_F^2/(4 pi^2)` at `m -> 0` to 0 at `m -> infinity`), and it has **higher** energy: on it
`rho = (eps_KS(m) − m sigma_KS(m)/2)/v`, and `Delta(m) = eps_KS(m) − m sigma_KS/2 − eps_KS(0)` vanishes at
`m = 0+` with `dDelta/dm = (g m^3/(4 pi^2)) (L − k_F/w_F) > 0`
(`L − k_F/w_F = phi(k_F/m)`, `phi(x) = Log[x + Sqrt[1 + x^2]] − x/Sqrt[1 + x^2]`, which vanishes at 0 and has
derivative `x^2/(1 + x^2)^(3/2) > 0`). So the ground state of a frozen-compatible fable is the `m = 0`
branch, on which `rho = eps_KS(k_F, 0)/v`, `P_obs = rho/3`, `P_hid = 0`: **radiation**. A Kohn–Sham fable
compatible with a frozen hidden sheet is neither dark matter nor dark energy. **[proved VIII §33]**
`FROZEN [THE RESULT]: 2 W - sigma W' == 0 for all sigma iff W == c sigma^2 (the general solution of sigma W' == 2 W)`,
`FROZEN [has content]: m sigma_KS > 0 for m > 0 (zero at kF = 0, kF-derivative g kF^2 m^2/(2 pi^2 wF) > 0; even in m, so also for m < 0); for c < 0 a root m != 0 of m = 2 c sigma_KS/v would give m^2 = 2 c (m sigma_KS)/v < 0: only m = 0`,
`FROZEN [has content]: phi(x) = Log[x + Sqrt[1 + x^2]] - x/Sqrt[1 + x^2] is 0 at x = 0 and increasing (derivative x^2/(1 + x^2)^(3/2)), hence positive for x > 0; and L - kF/wF == phi(kF/m)`,
`FROZEN [THE RESULT]: for c > 0, sigma_KS/m decreases strictly (d/dm = -(g m/(2 pi^2))(L - kF/wF)) from g kF^2/(4 pi^2) at m -> 0 to 0 at m -> infinity: a non-trivial root of 1 = 2 c (sigma_KS/m)/v exists iff c g kF^2/(2 pi^2 v) > 1`,
`FROZEN [THE RESULT]: on the non-trivial root (m = 2 c sigma7) rho == (eps_KS - m sigma_KS/2)/v, and Delta = eps_KS(m) - m sigma_KS/2 - eps_KS(0) has Delta(0+) = 0 and dDelta/dm = (g m^3/(4 pi^2))(L - kF/wF) > 0: the m = 0 branch has LOWER rho`,
`FROZEN [has content]: witness numbers -- at g = 8, v = 1, c = 15, kF = 1 the non-trivial root m* exists (gap residual < 10^-20) and rho(m = 0) < rho(m*)`,
`FROZEN [THE RESULT]: on the m = 0 branch the frozen-compatible fable is RADIATION: rho = eps_KS(kF, 0)/v, P_obs = rho/3, P_hid = 0`.
The witness the run prints [displayed VIII §33, `claude-fable/run_fermion_fable_part8.log`]:

```
  frozen-compatible witness (g = 8, v = 1, c = 15, kF = 1): non-trivial root m* = 3.97853200077825223420767254928521681893`12.;  rho(m = 0) = 0.10132118364233777144387946320972763891`12.  <  rho(m*) = 0.28374208489508058306307225309709278221`12.
```

#### 4.5.8 The classical limit, and the sign rule

The classical limit is the **non-relativistic** limit `k_F << |m|` (not a coherent zero mode: the Pauli
principle forbids that). Exactly, on the gap, with `s = H sigma7` and `V(s) := W(s/H)`:

```
rho  =  V(s) + 3 P_KS/v,        P_obs  =  s V'(s) - V(s) + P_KS/v,        P_hid  =  s V'(s) - V(s)
```

and as `k_F/m -> 0` (`m > 0`), `sigma_KS/n_KS = 1 − (3/10) k_F^2/m^2 + ...`,
`(eps_KS − n_KS m)/(n_KS k_F^2/m) -> 3/10`, `P_KS/(n_KS k_F^2/m) -> 1/5`: `P_KS/rho -> 0` and the quantized fluid
reduces to Part VI's `rho = V(s)`, `P = s V'(s) − V(s)` (its `K_h = 0` branch); `P_hid` is exactly Part VI's
on-shell pressure. With `s0 = n_KS/v`, exactly on the gap,
`rho − W(s0) = (eps − n m)/v − [W(s0) − W(sigma7) − W'(sigma7)(s0 − sigma7)]`: a second-order Taylor
remainder in `s0 − sigma7`. **The sign rule:** `m sigma_KS >= 0`, so on every self-consistent solution
`sign(sigma7) = sign(m) = sign(W'(sigma7))`; for Part VI's mass term `W = −2 M sigma` the gap is `m = −2M` and
`rho -> 2 |M| n/v > 0` — the Part VI branch `M s > 0`, of negative energy, is not a self-consistent state.
**[proved VIII §33]** `CLASSICAL LIMIT [THE RESULT]: exactly, on the gap and with s = H sigma7, V(s) = W(s/H): rho == V(s) + 3 P_KS/v, P_obs == s V'(s) - V(s) + P_KS/v, P_hid == s V'(s) - V(s)`,
`CLASSICAL LIMIT [fidelity]: Section 24's on-shell P_1 (cfP1Fable, re-checked here) is s V'(s) - V(s); evaluated at s = H sigma7 with V(s) = W(s/H) it IS the KS P_hid = sigma7 W' - W`,
`CLASSICAL LIMIT [THE RESULT]: NR series (kF/m -> 0, m > 0): sigma_KS/n_KS = 1 - (3/10) kF^2/m^2 + ..., (eps_KS - n_KS m)/(n_KS kF^2/m) -> 3/10, P_KS/(n_KS kF^2/m) -> 1/5`,
`CLASSICAL LIMIT [has content]: the design's form, exactly: on the gap (m = W'(sigma7) > 0) rho - W(s0) == (eps - n m)/v - [W(s0) - W(sigma7) - W'(sigma7)(s0 - sigma7)], s0 = n/v -- a second-order Taylor remainder in s0 - sigma7`,
`SIGN RULE [THE RESULT]: m sigma_KS >= 0 gives sign(sigma7) == sign(m) == sign(W'(sigma7)); for Section 24's mass term W = -2 M sigma the gap is m = -2 M and W(sign(m) n/v) = -2 M sign(-2 M) n/v == 2 |M| n/v > 0`.
Notebook 05 checks the series at `x = 0.001` and the sign at `m = −2` **[nb05 §5.4]**:
`(sigma/n − 1)/x^2 = −0.300000 (−3/10)`, `(eps/(|m| n) − 1)/x^2 = +0.300000 (+3/10)`,
`P/(n kF^2/|m|) = 0.200000 (1/5)`; `m = −2: sigma/n = −0.999999700: sgn(sigma) = sgn(m)`.

#### 4.5.9 `w_f >= −1`: no phantom crossing

```
rho + P_obs  =  w_F n_KS/v  >=  0         so        w_f  >=  -1   wherever  rho > 0
```

The quantized fermion fable **cannot cross the phantom divide**; the classical crossing of Part VI
(section 3.1.12.7, at `V'(s*) = 0`) does not survive quantization. **[proved VIII §33]**
`PHANTOM [THE RESULT]: rho + P_obs == wF n_KS/v >= 0, so w_f >= -1 wherever rho > 0 -- the quantized fable cannot cross the phantom divide`. Notebook 05 compared the classical `w_cl = s V'/V − 1` of five of Part VI's
potential shapes with the quantum `w = P_obs/rho` of the lowest-energy gap root, over densities
`1e-3 <= n <= 30` (in units where the classical `s` equals `n`), for `W = A V` with `A = 1e4, 1e2, 1` — a large
`A` makes the quasiparticles heavy (`m = A V'`), which is the classical limit (915 points) **[nb05 §5.4, file:
`fable-cosmology/results/nb05_classical_vs_quantum.csv`, figure `nb05_classical_vs_quantum.png`]**:

| potential (`V(s)`) | classical `min w_cl` | quantum `min w` (`A = 1e4`, `100`, `1`) |
|---|---|---|
| mass (`s`) | `+0.0000`, never crosses −1 | `+0.00000`, `+0.00000`, `+0.00741` |
| lambda-mass (`0.7 + 0.3 s`) | `−0.9996`, never crosses −1 | `−0.99957`, `−0.99957`, `−0.99949` |
| power (`s + s^0.236`) | `−0.7601`, never crosses −1 | `−0.76012`, `−0.76012`, `−0.76012` |
| expdamp (`1.566 + 0.839 s e^(−s/2.21)`) | `−1.3020`, **crosses −1** at `n = 2.2047` | `−0.99952`, `−0.99947`, `−0.99945` |
| lorentz (`1 + s/(1 + (s/1.5)^2)`) | `−1.2481`, **crosses −1** at `n = 1.4999` | `−0.99900`, `−0.99900`, `−0.99898` |

and it printed `the quantum w >= -1 at every density, every A and every potential; the classical
expdamp and lorentz cross -1`. For `expdamp` the gap keeps `0 < sigma < min(n, s1)` strictly, with
`sigma -> s1` and `m -> 0` only as `n -> infinity` (solver test
`kohn_sham::tests::expdamp_pins_sigma_below_s1_and_mass_goes_to_zero_at_high_density`).

#### 4.5.10 The equations of state an observer can define

Four definitions are used, and they must not be confused [file: `models.rs`, documentation of the
output columns; prose nb06 §5]:

1. **`w_f = P_obs_f/rho_f`** — the intrinsic equation of state of the whole fable fluid;
2. **`w_DM = w_qp = P_KS/eps_KS`** — the intrinsic equation of state of the quasiparticles, in `[0, 1/3]`;
3. **`w_DM,eff = w_DM − sigma_KS (dm/dN)/(3 eps_KS)`** — the effective equation of state of the
   quasiparticles when the mass varies, which exchange energy with the condensate at the rate
   `Q = sigma8 dm/dt` (the exact exchange; `n dm/dt` is its non-relativistic limit);
4. **`w_DE,inf`** — the dark energy an observer **infers** by fitting cold dark matter plus dark
   energy: `rho_DE,inf = H_A^2 − Omega_r0 A^-4 − Omega_b0 A^-3 − m_today n_today A^-3` (radiation, baryons, and
   cold dark matter with **today's** mass `m_eff(A = 1)` subtracted), `w_DE,inf = −1 − (1/3) d ln rho_DE,inf/d ln A`.

The adiabatic sound speed of the fable is `c_s^2 = (dP_obs_f/dN)/(d rho_f/dN)`; `c_s^2 < 0` is an adiabatic
instability. The split into dark matter and dark energy is a convention (7.4): the condensate is an
8-dimensional vacuum energy.

#### 4.5.11 The vacuum energy of mass-varying potentials

For a constant mass the Dirac-sea energy is a constant; it is absorbed into `V` and appears as a bare
cosmological constant. **The cosmological-constant problem is not solved here.** For a mass that varies
along the history the sea energy cannot be absorbed silently (design review DFT-4, adopted). The
renormalized one-loop Dirac-sea energy that the no-sea functional drops (relativistic Hartree
approximation, Chin 1977), per 3-volume, with reference mass `M` and counterterms through `m^4`, is

```
DeltaE_vac(m) = -(g/(16 pi^2)) [ m^4 ln(m/M) + M^3 (M - m) - (7/2) M^2 (M - m)^2 + (13/3) M (M - m)^3 - (25/12) (M - m)^4 ]
```

[file: `kohn_sham.rs`, function `vacuum_energy`; its test
`kohn_sham::tests::vacuum_energy_vanishes_to_fifth_order_at_the_reference_mass`]. At `m = 0` the bracket is
`M^4 (1 − 7/2 + 13/3 − 25/12) = −M^4/4`, so `DeltaE_vac(0) − DeltaE_vac(M) = g M^4/(64 pi^2)` [derived
here]. With `g = 8` and `E_c = rho_c0^(1/4) = 2.46261e-3 eV` (asserted:
`fable4d RUNS [definition]: the units computed from CODATA 2018 -- E_c = rho_c0^(1/4) == 2.46261e-3 eV, Omega_r0 == 9.2096e-5, Omega_b0 = 0.02237/h^2 == 0.049243 (to the quoted digits)`), a mass variation of order `m` changes the vacuum energy by

```
g m^4/(64 pi^2) / rho_c0  =  3.44,   3.44e4,   3.44e8,   3.44e12          at   m = 0.01, 0.1, 1, 10 eV          (it scales as m^4)
```

[derived here: `g/(64 pi^2) = 0.012665`, `(m/E_c)^4 = 271.9` at `m = 0.01 eV`]. So for `m >~ 10 meV` it
exceeds the critical density; notebook 05 prints the exact threshold **[nb05 §5.8]**:
`Delta E_vac(0; M) = g M^4/(64 pi^2): check 1.000000000000003;  g M^4/(64 pi^2) exceeds rho_c0 for M > (64 pi^2/g)^(1/4) E_c = 7.341 meV`,
and at `M = 1 eV` it gives `|Delta E_vac|/rho_c0` = `2.760e-02`, `2.802e+03`, `9.454e+06`, `3.444e+08` at
`m/M = 0.99, 0.9, 0.5, 0` (the last is the `3.44e8` above); at `M = 1000 eV`, `3.444e+20` at `m = 0`; the
fifth-order zero at `m = M` is confirmed by the ratio `31.9470` (`2^5 = 32`).

The design review's refinement (DFT-4, adopted): the sea energy **can** be absorbed formally by
reading `W` as the fully renormalized effective potential, `Omega(m) = eps_KS + DeltaE_vac + F` =
no-sea with `F~ = F + DeltaE_vac`; that reading is a **fine-tuning** of the bare potential against the
sea energy. The vacuum also adds `sigma_vac = dDeltaE_vac/dm` to `<Psibar Psi>`. The two options are
(a) to include `DeltaE_vac` in `rho` and in the gap equation, or (b) to declare `W` the renormalized
potential. **The runs use (b)**, and they print `DeltaE_vac(m(t)) − DeltaE_vac(m_today)` in units of
`rho_c0` (the solver's column `vac_over_rhoc`, `DeltaE_vac(m_eff; M = m_eff(A = 1))/v`). Along the power
run `nu = 0.236`, `m_today = 30 eV` notebook 05 found **[nb05 §5.8]**:

```
power nu = 0.236, m_today = 30 eV: m_eff/m_today runs from 0.2007 (a = 1e-12) to 1;  max |solver vac_over_rhoc - formula| / (g M^4/(64 pi^2)) = 5.4e-15
   |Delta E_vac(m(t)) - Delta E_vac(m_today)| / rho_total: max over a >= 0.3 = 1.314e+13,  at a = 0.5: 1.149e+13
```

Section 4.7.6 gives the ratio for every run.

#### 4.5.12 Exchange and correlation

The Kohn–Sham functional of section 4.6.1 has `E_xc` neglected (the Hartree mean field). For the author's
mass term (`W` linear) the action is bilinear, the theory is free, and the mean field is **exact**
(`E_xc = 0`). For a nonlinear `W` the design review (DFT-14) estimated that the Fock exchange of the
contact interaction is suppressed relative to the Hartree term by `~1/g = 1/8` only in the
non-relativistic regime `k_F << m`, and is of order one or larger for `k_F >~ m`; in the relativistic era
its neglect is controlled only by the smallness of the interaction energy relative to `3 P_KS`. That
ratio was not computed in the runs; the neglect of `E_xc` is a stated approximation of every
mass-varying result in this document.

### 4.6 Density-functional theory: the fable ground and first excited states

The author asked to "use some of the relevant ideas from Density Functional Theory to obtain the
fable ground and first excited states". Two systems are treated: the **homogeneous** fable gas of the
present universe (8.1–8.2), and the fable **along the hidden coordinate `x0`** of the primordial field,
where the wall `x0 = 0` binds discrete states (8.3–8.8). The homogeneous numbers are printed by
notebook 05 **[nb05 §5.5, §5.6]**; the wall-state numbers are quoted from
`fable-cosmology/fermion/waveguide_REPORT.txt` **[WG n]** and its logs, and notebook
`07_fable_dft_states.ipynb`, executed and committed in `aca5102`, reproduces them (a number it
prints again carries the mark **[nb07 §n]**, with the notebook's section). The development logs that the report names are files under
`fable-cosmology/fermion/dev/`, a folder the repository ignores; the report, which is tracked, quotes them.

#### 4.6.1 The functional, and the homogeneous Kohn–Sham ground state

**The functional.** For the conserved charge `n` and the scalar density `sigma` (the relativistic
Hohenberg–Kohn–Sham scheme; the Serot–Walecka mean field is its Hartree limit), the energy of the gas
at fixed `n` is

```
E_n[sigma]  =  T_s(sigma; n) + W(sigma) + E_xc,        T_s = eps_KS(m(sigma)) - m(sigma) sigma,        sigma_KS(m(sigma), k_F) = sigma
dE_n/d sigma  =  W'(sigma) - m(sigma)        (stationary exactly at the gap roots),        d^2 T_s/d sigma^2  =  -1/chi  <  0
```

with `E_xc` neglected (section 4.5.12) and the Dirac sea excluded (the no-sea functional; its energy is
section 4.5.11). The Kohn–Sham Slater determinant is the filled Dirac sea (renormalized away) plus the
Fermi sea `|k| < k_F` of the lowest positive band. **The ground state is the stationary point of this
minimax functional** — a maximum in `sigma` and a minimum in the occupations — and **never** its
minimum over `sigma` [prose nb05 §5.6; solver: design departure D1 of the development report, and the
unit tests `kohn_sham::tests::ks_functional_stationary_point_is_a_maximum_for_the_mass_term`,
`walecka_functional_is_minimized_at_the_gap_root`, `multiple_gap_roots_are_found_and_the_lowest_energy_one_is_taken`
in `kohn_sham.rs`]. For linear `W` the theory is free, `m = m0` exactly, and the Kohn–Sham state is the
exact ground state.

**The minimax, in numbers** **[nb05 §5.6, file: `fable-cosmology/results/nb05_minimax.csv`, figure `nb05_minimax.png`]**:

```
mass term W = 2 sigma, kF = 1.5: n = 0.4559453264, the gap root sigma* = 0.3961298703 (sigma*/n = 0.868810)
E_n(sigma*) = 1.052962422118 = rho = eps_KS(m0) = 1.052962422118;  max of E_n over the grid = 1.052959281278
E_n/n at sigma = -(1 - 1e-7) n: -1.999480  (the collapse value -|m0| = -2.0)

attractive W = sigma - 10 sigma^2, kF = 1: unique gap root m* = 0.2112489356, rho = 0.1211932853;  Omega_n(m*) = 0.121193285306
Omega_n on the grid: minimum 0.121193451922 at m = 0.2100;  second differences all positive (convex): True
```

The root of the mass term is the **maximum** of `E_n` (the grid maximum lies just below it), and
`E_n/n` falls to the collapse value `−|m0|` as `sigma -> −n`. For the attractive `W` the convex Walecka
functional `Omega_n(m) = eps_KS(m) + W(sigma_m) − m sigma_m` has its minimum at the gap root, equal to `rho`.

**Several roots, and a first-order transition.** For the repulsive `W = m0 sigma + (lam/2) sigma^2` with
`(m0, lam) = (0.05, 20)` at `k_F = 1`, `W'' chi0 = lam g k_F^2/(4 pi^2) = 4.0528 > 1` and there are three roots;
the Rust solver's `gap` command and the Python solver agree **[nb05 §5.5]**:

```
# potential Quadratic { v0: 0.0, m0: 0.05, lam: 20.0 }, kF = 1e0, v = 1e0, n8 = 1.3509491152311703e-1, plan = Scan { lo: -2.651898230462341, hi: 2.7518982304623405 }
m,sigma8,rho8,P_obs,P_hid,gap_residual
-2.535353916022531e0,-1.292676958011266e-1,1.909782056219713e-1,1.772147779888931e-1,1.671013717773260e-1,8.506e-17
-1.640336879334347e-2,-3.320168439667173e-3,1.012381942988485e-1,3.387489103006236e-2,1.102351846776195e-4,-1.898e-17
2.644093986040535e0,1.297046993020268e-1,2.039272771420881e-1,1.779694075325236e-1,1.682330902102918e-1,0.000e0
# selected (Lowest): m = -1.640336879334347e-2, rho8 = 1.012381942988485e-1, roots = 3
```

with `(rho + P)/(w_F n) = 1.000000000000` on every root (so `w >= −1` on every branch), and
`uniqueness criterion lam chi0 < 1 holds for kF < 0.4967; three roots first appear at kF = 0.625 on this grid; the ground state jumps from m = +0.4756 (kF = 0.600) to m = -0.0998 (kF = 0.625)`
**[nb05 §5.5, figure `nb05_gap_roots.png`]**: the ground state jumps between branches — a first-order
transition. That is why the solver refuses a repulsive quadratic run (section 4.7.11): energy conservation
across the jump would need a Maxwell construction, which it does not implement.

#### 4.6.2 The first excited states of the homogeneous gas

The design review (DFT-15, adopted) states them; they are not assertions of the notebook, and the
derivation is short [derived here]:

- **Particle–hole excitations** (a quasiparticle moved from just inside to just outside the Fermi
  surface) are **gapless**: `Delta E -> 0` as the momentum transfer goes to zero. The lowest excited state
  of the gas is degenerate with the ground state in the thermodynamic limit, and it has no effect on `w`.
- **Pair excitations** create a particle above the Fermi sea (energy `>= w_F`, momentum `|k1| >= k_F`) and
  a hole in the Dirac sea, an antiparticle (energy `Sqrt[k2^2 + m^2] >= |m|`), with total momentum
  `q = k1 + k2`. At `q = 0`, `k2 = −k1`, and the threshold is `2 w_F` (Pauli blocking pushes it from
  `2|m|` to `2 w_F`). The absolute threshold is `w_F + |m|`, at `|q| = k_F` (`|k1| = k_F`, `k2 = 0`).
- **Delta-SCF** (moving one quantum and re-solving the gap): in the homogeneous gas one quantum changes
  `sigma` by `O(1/volume)`, so the self-consistent excitation energy of one quantum equals the
  single-particle one. A finite effect needs a finite fraction of the particles, which is how the wall
  problem below defines its first excited state (design review DFT-9).

#### 4.6.3 The states along the hidden coordinate: the problem **[WG 2]**

The wall-state solver works at fixed observer's time on the canonical frame, with `a4` frozen to a
constant (the adiabatic approximation). The spectrum depends on the transverse momentum `k` and the
frozen `a4` only through `K_inf = k e^{a4}`, so every number below is a function of `K_inf`; the code
works with `K_inf` directly (internally it sets the frozen constant to zero, which only identifies `k`
with `K_inf`; nothing here or in the notebook gives `a4` a value). Units: `H = 1`, `hbar = c = 1`. Its
derivation, `fable-cosmology/fermion/waveguide_derivation.wls`, loads the notebook's own Input cells
1–117 (with `DumpSave` blocked) and uses only the notebook's objects (`T16`, `sigma16`,
`gammaCurvedCanonical`, `GammaSpinCanonical`, `cfDcov16`, `gCanonical`, `RicciScalarCanonical`, `eta4488`);
its log records `94 checks, 94 PASS, 0 FAIL` in 162.8 s (`total time 162.8 s`, with cells 1–117
evaluated in `125. s`, in the run of 2026-09-25 00:06:38 that wrote the committed `waveguide_T16.json`;
the first committed run, in `18a2501`, took 171.4 s, with 132.3 s of loading), and that the notebook's own 142 assertions of
cells 1–117 passed while loading [file: `fable-cosmology/fermion/waveguide_derivation.log`].

**The reduction.** With `Psi = e^{i k x1 − i omega x4} Sqrt[Sin[6 H x0]] Psi'(x0)` the Dirac equation
`gamma^mu D_mu Psi = m Psi` (`m = H V'(s)`; `m = −2M` for the author's mass term) becomes **exactly**

```
(gamma^mu D_mu - m) Psi  =  Sqrt[Sin] e^{...} [ Cot T0 d_0 + i k e^{A4} Sin^(1/6) T1 - i omega T4 - m ] Psi'
T0 d_z Psi' + i K(z) T1 Psi' - i omega T4 Psi'  =  m Psi',        K(z) = K_inf (1 - e^{-12 H z})^(1/12),        K_inf = k e^{a4}
```

in the proper distance `z = −Log[Cos[6 H x0]]/(6 H)` (`Cot d/dx0 = d/dz`; `z = 0` at the wall, a finite
proper distance away; `z -> infinity` as `6 H x0 -> Pi/2`). The measure is `Sqrt[|g|] |Psi|^2 dx0 = |Psi'|^2 dz`,
so the one-particle space is `L^2(dz)`. The transverse term rises from `K(0) = 0` at the wall
(`K = K_inf (12 H z)^(1/12) (1 − H z/2 + ...)`, `K'` integrable) to `K_inf`: a "pocket" of width
`~1/(12 H)` (`K^2/K_inf^2 = 0.875776, 0.942018, 0.984275` at `z = 0.05, 0.1, 0.2 /H`). The wall is a curvature
singularity at finite proper distance: `R z^2 -> −31/24` as `z -> 0`.

**Hamiltonian form and the 2×2 blocks.** `omega phi = h phi`,
`h = −i alz d_z + K(z) alx + m bet` with `alz = −T4 T0`, `alx = −T4 T1`, `bet = −i T4` (Hermitian involutions,
pairwise anticommuting); `J = −i T0 T1 T2 T3 T4` commutes with `h`. `w3 = alz alx bet` (`w3^2 = −1`) is
central; the algebra `<alz, alx, bet, J>` has dimension 16, and `C^16` splits into **8 invariant
2-dimensional blocks**: 4 with `w3 = −i` (`J = +1` twice, `J = −1` twice) and 4 with `w3 = +i`. In an
explicit block basis every block has `alz = sigma_y`, `bet = sigma_z`, `T0 = sigma_x`, and with `phi = (f, g)`:

```
irrep w3 = -i:    f' = -K(z) f + (m + omega) g,        g' = K(z) g + (m - omega) f
irrep w3 = +i:    the same with K -> -K
```

**The wall conditions.** The self-adjoint conditions of a block are exactly the real lines
`f(0) cos th + g(0) sin th = 0`, `th` in `[0, Pi)`, and all of them have zero normal current. Only
`th = ±Pi/4` give `Psibar Psi = 0` at the wall, and only they are covariant under the wall's
Spin(1,3) of `x1..x4`: the MIT (bag) conditions `T16[0] Psi = ±Psi` (MIT+: `f = g`; MIT−: `f = −g` in the basis
above). The complete covariant, `J`-preserving family is `P Psi(0) = Psi(0)` with `P = T16[0] Q`, `Q` any
Hermitian involution in the 8-dimensional commutant of the Clifford algebra of `T16[0..4]` (which
contains `J`); all of them have zero normal current and `Psibar Psi = 0`. Flavour symmetry (`Q` central:
`±1`, `±J`) together with charge conjugation (`P` real) select `Q = ±1`, the uniform MIT walls; a mixed `Q`
gives one MIT+ sector and one MIT− sector with halved multiplicities. Without `J`-preservation there are
more, e.g. `P = T0 exp(i vt T0 T5)`. A **same-sign** wall is `T16[0] Psi = sign(m) Psi` (the limit of an
outside mass of the same sign); an **opposite-sign** wall is `T16[0] Psi = −sign(m) Psi` (a domain wall);
for the author's mass term `m = −2M`, so both are physically possible.

**The structure of the spectrum.** With MIT walls the 16-component spectrum at transverse momentum `K`
is `S(K) = A(K) ∪ (−A(K))`, `A(K)` the levels of the `w3 = −i` block equation, symmetric under
`omega -> −omega`; a positive level is **4-fold** per transverse momentum vector (two blocks with `J = +1`,
two with `J = −1`, of one irrep), and 8-fold only when `omega` and `−omega` both lie in `A(K)`. The 8
states per momentum of the homogeneous gas split at the wall into two generally non-degenerate 4-fold
branches. The bulk continuum is `|omega| >= R = Sqrt[m^2 + K_inf^2]`; `z = 0` is a regular (limit-circle)
endpoint and `z -> infinity` limit point. Second-order form: `f'' = (K^2 − K' + m^2 − omega^2) f`, a
supersymmetric pair with superpotential `K`; for `K > 0` the `f`-channel has the attractive pocket `−K'`.

**Exact solutions** (used for validation): constant `K`, MIT−: `omega = −K`, `phi = e^{−m z}(1, −1)`; the true
profile with `g(0) = 0`: `omega = m` for **every** `K_inf > 0` (a flat band); constant `K`, any `th`: a level
`omega = −(m cos 2th + K sin 2th)` exists iff `kappa = m sin 2th − K cos 2th > 0`; constant `K > 0`, MIT+:
**no** level.

#### 4.6.4 Numerical method and its validation **[WG 3, WG 5]**

The block problem is solved by the Prüfer angle `(f, g) = r (cos p, sin p)`,
`p' = m cos 2p + K sin 2p − omega`, `p(0) = th + Pi/2`, matched to the exact decaying direction of the
constant-coefficient problem beyond `z_a = 3/H` (where `K(z)/K_inf − 1 < 2e-17`). The mismatch `Delta(omega)`
is strictly decreasing in `omega`, so the number of levels in the gap is exactly
`#{ j : Delta(+R) < j Pi < Delta(−R) }` — a rigorous count that catches shallow levels. Roots are found on a
logarithmic grid of the decay rate `kappa` and refined by Brent's method; two integrators (adaptive DOP853
at `1e-12`, and a 4th-order Magnus propagator) are compared. `python waveguide.py validate` runs 64 checks,
all PASS (log `dev/waveguide_run_validate.log`, quoted in `waveguide_REPORT.txt` §3),
among them: the exact solutions above (errors `<= 6e-16`); Hellmann–Feynman for the scalar density
(`d omega/dm = Int (f^2 − g^2) dz`, agreement `3e-8`); the full 16×16 system with the notebook's `T16`,
in which every level has multiplicity exactly 4; and the small-`K` slope of the edge band against its
closed form `omega/K_inf -> −(m/6H) B(m/6H, 13/12)` (`B` the Euler beta function): `−0.980822728` vs
`−0.980822733` at `m = H`.

The independent Mathematica check `fable-cosmology/fermion/waveguide_check.wls` (a different language,
`NDSolve` at 30 digits, the normalized Wronskian with `FindRoot`, `NullSpace` for the asymptotic data)
reports `11 checks, 11 PASS, 0 FAIL` and agreement with the Python levels to at most `4.68e-11`
**[WG 5]**. Its level table:

| case | `waveguide.py` | Mathematica | difference |
|---|---|---|---|
| same-sign `K = 80`, `n = 0` (irrep −i) | `70.985307229908` **[nb07 §5.5]** | `70.98530722995475448906` | `4.68e-11` |
| same-sign `K = 80`, `n = 1` (irrep +i) | `78.1442493324274` **[nb07 §5.5]** | `78.14424933243057439331` | `3.17e-12` |
| same-sign `K = 80`, `n = 2` (irrep −i) | `79.3714957790936` **[nb07 §5.5]** | `79.37149577909911904082` | `5.51e-12` |
| same-sign `K = 80`, `n = 3` (irrep +i) | `79.9873085520475` **[nb07 §5.5]** | `79.98730855204863978335` | `1.15e-12` |
| same-sign `K = 8`, shallow (irrep −i) | `8.05383822789729` **[nb07 §5.7]** | `8.053838227898042799445` | `7.53e-13` |
| same-sign `K = 40`, `n = 1` (irrep +i) | `39.9665602657784` **[nb07 §5.7]** | `39.96656026577953705636` | `1.14e-12` |
| opposite-sign `K = 3`, edge (irrep −i) | `−2.93849067695725` **[nb07 §5.3]** | `−2.938490676960405133909` | `3.16e-12` |
| opposite-sign `K = 3`, edge (irrep +i) | `2.9384906769572` **[nb07 §5.8]** | `2.938490676960405133909` | `3.21e-12` |
| `g(0) = 0`, `K = 3`, flat band (irrep −i) | `1.` **[nb07 §5.3]** | `1.000000000000000000000` | `0` |
| `th = 1.0`, `K = 3` (irrep −i) | `−2.21043470304386` | `−2.210434703050103980776` | `6.24e-12` |
| same-sign `m = 4`, `K = 20` (irrep −i) | `20.1427411133772` | `20.14274111338139405878` | `4.20e-12` |

It also confirms the 4-fold multiplicities in the full 16-component system (four singular values below
`1e-3` of the fifth, rising at `omega ± dw`) and the thresholds `K_c(1) = 6.70624065181` and
`K_c(2) = 33.9189585083` (the Prüfer mismatch crosses an integer multiple of `Pi` between `K_c (1 − 1e-6)` and
`K_c (1 + 1e-6)`). At `K = 80` `NDSolve` on the 16×8 matrix system did not finish within 30 minutes, so
there the 16×16 check uses an independently written Magnus/`MatrixExp` propagator.

#### 4.6.5 The wall levels: ground and first excited states, in tables **[WG 4]**

All at `m = H = 1` unless stated; the levels are the **positive** levels of the full 16-component
problem, each 4-fold per transverse momentum vector.

**Thresholds of the same-sign wall** (the transverse momentum `K_c(n)` at which the `n`-th positive level
appears; exact count, bisection to `1e-9`; `dev/waveguide_run_threshold.log`):

| `m/H` | `K_c(1)/H` | irrep | `K_c(1)/m` | `K_c(2)/H` | irrep | `K_c(2)/m` |
|---|---|---|---|---|---|---|
| 0.25 | `3.39259952` **[nb07 §5.6]** | −i | `13.57040` | `33.87815035` **[nb07 §5.6]** | +i | `135.51260` |
| 0.50 | `4.77916520` **[nb07 §5.6]** | −i | `9.55833` | `33.89177761` **[nb07 §5.6]** | +i | `67.78356` |
| 1.00 | `6.70624065` **[nb07 §5.6]** | −i | `6.70624` | `33.91895851` **[nb07 §5.6]** | +i | `33.91896` |
| 2.00 | `9.33759991` **[nb07 §5.6]** | −i | `4.66880` | `33.97299731` **[nb07 §5.6]** | +i | `16.98650` |
| 4.00 | `12.80358979` **[nb07 §5.6]** | −i | `3.20090` | `34.07956537` **[nb07 §5.6]** | +i | `8.51989` |
| 8.00 | `17.04604924` **[nb07 §5.6]** | −i | `2.13076` | `34.28513351` **[nb07 §5.6]** | +i | `4.28564` |

The first level always appears in irrep −i, with `K_c(1)` growing roughly like `6.7 (m/H)^(1/2) H`; the
second always in the other irrep, at `K_c(2) = 33.9–34.3 H`, almost independent of `m`. Within irrep −i
alone the second level appears only at `K = 49.540216755` **[nb07 §5.6]** (`m = H`). **For `K < K_c(1)` there is no
bound level at all** — the design's first guess ("for `k != 0` the wall region is a potential pocket: bound
states below `Sqrt[m^2 + k^2 e^{2 a4}]`") was refuted by the review (DFT-7), and the refutation is confirmed.

**Dispersion `omega_n(K)` of the same-sign wall** (`[R − omega]` = binding below the continuum
`R = Sqrt[m^2 + K^2]`; `dev/waveguide_dispersion_same_m1.csv`):

| `K` | `R` | `n = 0` (irrep −i) | `n = 1` (irrep +i) | `n = 2` (irrep −i) | `n = 3` (irrep +i) |
|---|---|---|---|---|---|
| 7 | `7.07106781` | `7.07061457` **[nb07 §5.7]** [`4.53e-4`] | | | |
| 8 | `8.06225775` | `8.05383823` **[nb07 §5.7]** [`8.42e-3`] | | | |
| 10 | `10.04987562` | `9.99920505` **[nb07 §5.7]** [`0.0507`] | | | |
| 20 | `20.02498439` | `19.39490065` **[nb07 §5.7]** [`0.630`] | | | |
| 34 | `34.01470270` | `31.96226139` **[nb07 §5.7]** [`2.05`] | `34.01469386` **[nb07 §5.7]** [`8.8e-6`] | | |
| 40 | `40.01249805` | `37.21339774` **[nb07 §5.7]** [`2.80`] | `39.96656027` **[nb07 §5.7]** [`0.0459`] | | |
| 50 | `50.00999900` | `45.83408535` **[nb07 §5.7]** [`4.18`] | `49.72238768` **[nb07 §5.7]** [`0.288`] | `50.00982259` **[nb07 §5.7]** [`1.8e-4`] | |
| 60 | `60.00833275` | `54.32136437` **[nb07 §5.7]** [`5.69`] | `59.31765921` **[nb07 §5.7]** [`0.691`] | `59.92357565` **[nb07 §5.7]** [`0.0848`] | |
| 80 | `80.00624976` | `70.98530723` **[nb07 §5.7]** [`9.02`] | `78.14424933` **[nb07 §5.7]** [`1.86`] | `79.37149578` **[nb07 §5.7]** [`0.635`] | `79.98730855` **[nb07 §5.7]** [`0.0189`] |
| 100 | `100.00499988` | `87.32733251` **[nb07 §5.7]** [`12.7`] | `96.59932036` **[nb07 §5.7]** [`3.41`] | `98.43212058` **[nb07 §5.7]** [`1.57`] | `99.66483153` **[nb07 §5.7]** [`0.340`] |

(at `K = 100` a fifth level `99.96879653` **[nb07 §5.7]** [`0.0362`], irrep −i). The band gap at fixed `K`
(`omega_1 − omega_0`) of the bare wall: `2.05243246` **[nb07 §5.14]** (`K = 34`), `2.75316253` **[nb07 §5.14]** (40),
`4.99629484` **[nb07 §5.14]** (60), `7.15894210` **[nb07 §5.14]** (80), `9.27198785` (100).

**The ground and first excited level at `K = 80`** (the case the review examined, DFT-7): in the full
16-component problem the positive levels are `70.98531` **[nb07 §5.5]** (`n = 0`, irrep −i), `78.14425` **[nb07 §5.5]**
(`n = 1`, from the **other** irrep, +i), `79.37150` **[nb07 §5.5]** (`n = 2`, irrep −i) and `79.98731` **[nb07 §5.5]**
(`n = 3`, irrep +i), each 4-fold. The review's "`n = 1` at 79.37150" labelled the second level of one irrep;
it is `n = 2` of the full problem, and the first excited level is `78.144249332` **[nb07 §5.5]**. The
`levels` command printed, for both irreps, `irrep -i: -79.987308552047, -78.144249332428, +70.985307229908, +79.371495779094;
irrep +i: -79.371495779091, -70.985307229895, +78.144249332427, +79.987308552047` **[nb07 §5.5]** — the `omega -> −omega`
symmetry between the irreps to `1e-11` **[WG 1]**.

**Wavefunctions** (normalized in `L^2(dz)`): at `K = 80`, `n = 0` has `Int (f^2 − g^2) = 0.24150473` **[nb07 §5.10]**
with `f` and `g` nodeless; `n = 1` (+i) `0.01572127` **[nb07 §5.10]**, `g` with one node; `n = 2` (−i) `0.02345024`,
`f` and `g` one node each; they live within `z < 0.4/H` (decay rates `kappa = 36.9, 17.2, 10.1`) **[WG 4.5]**.

**The opposite-sign wall: a gapless edge band.** For every `K > 0` there is one edge level per block, deep
inside the gap: `|omega|/K -> (m/6H) B(m/6H, 13/12) = 0.9808227327` **[nb07 §5.8]** as `K -> 0` (exact), `2.93849068`
**[nb07 §5.8]** at `K = 3`, and the ratio falls for larger `K` **[WG 4.3]**:

| `K` | `R` | edge `\|omega\|` | `\|omega\|/K` |
|---|---|---|---|
| 0.10 | `1.004988` | `0.09808212` **[nb07 §5.8]** | `0.980821` |
| 1.00 | `1.414214` | `0.98067175` **[nb07 §5.8]** | `0.980672` |
| 3.00 | `3.162278` | `2.93849068` **[nb07 §5.8]** | `0.979497` |
| 10.00 | `10.049876` | `9.69024420` **[nb07 §5.8]** | `0.969024` |
| 20.00 | `20.024984` | `18.99601285` **[nb07 §5.8]** | `0.949801` |
| 40.00 | `40.012498` | `36.76546650` **[nb07 §5.8]** | `0.919137` |
| 80.00 | `80.006250` | `70.51329445` **[nb07 §5.8]** | `0.881416` |
| 100.00 | `100.005000` | `86.85053394` **[nb07 §5.8]** | `0.868505` |

The edge band lies inside the bulk gap `|omega| < m` for `K < ~1.02 m`: massless fermions bound to the
wall, 4 positive states per transverse momentum, with a small **negative** scalar density
(`Int (f^2 − g^2) = −0.0498` at `K = 3`). Further positive levels of the opposite-sign wall appear
at `K = 33.80968834` **[nb07 §5.6]** (irrep −i) and `48.79382020` **[nb07 §5.6]** (+i).

**The dependence on the wall condition** (the uniform family `f(0) cos th + g(0) sin th = 0`, symmetry
breaking except `th = ±Pi/4`): at `K = 3` the levels sweep the **whole** gap `(−R, R)` as `th` varies; at
`K = 80` the lowest positive level moves from `omega = m = 1` **[nb07 §5.9]** (`th = −Pi/2`, `g(0) = 0`) to
`70.985` **[nb07 §5.9]** (MIT+) and `70.513` **[nb07 §5.9]** (MIT−). The wall condition, not the pocket, sets the low end
of the spectrum **[WG 4.4]**.

**Convergence:** the reference levels are accurate to about `1e-10` (tolerance-limited; matching point,
`rtol` from `1e-9` to `1e-13`, `z_a` from 2 to 6, the `kappa` grid and the integrator each change `omega` at
`K = 80`, `n = 0` by at most `1.0e-8`) **[WG 4.6]**.

#### 4.6.6 The Kohn–Sham (local-density) treatment of the wall **[WG 6]**

**Setting.** The functional per 8-volume is `W(sigma) = m0 sigma + (lam/2) sigma^2` with the local mean field
`m(z) = W'(sigma(z)) = m0 + lam sigma(z)`, `m0 = 1 H`; `lam < 0` is attractive. The admissible modes are zero
modes along `x5..x7`, normalized over the hidden coordinate volume, chosen as `V_hid = 1/H^3` (so `lam` also
stands for the effective 5-dimensional coupling `lam/V_hid`); `N_s` is the number per unit coordinate
observed 3-volume. Per transverse momentum each positive level of either irrep contributes 4 degenerate
states; a "band" is one level family `omega_b(k)`. The scalar density of a block orbital is the
Krein-weighted `|f|^2 − |g|^2`, the number density `|f|^2 + |g|^2`, and since the transverse proper volume is
`1/Sin(z)`:

```
sigma(z) = Sin(z) Sum_b 4 Int d^3k/(2 pi)^3 theta(occupied) (f^2 - g^2)_{b,k}(z),        n(z) likewise with (f^2 + g^2)
E/A      = Sum_occ omega + Int (W - sigma W') dz/Sin  =  Sum_occ omega + (|lam|/2) Int sigma^2/Sin dz
```

no-sea, `E_xc` neglected, a common Fermi level `mu`, Anderson mixing; the particle number is reproduced to
`1e-8` in every iteration.

**(a) The author's mass term: exact.** For `W = m0 sigma` (`lam = 0`) the action is bilinear, the theory is
**free**, the single-particle levels of 8.5 are the exact spectrum, and every many-body eigenstate is a
Slater determinant of exact modes; no self-consistency is needed. Consequences: on the **same-sign** wall
there is **no** bound positive level for `K < K_c(1) = 6.70624` **[nb07 §5.11]**; every wall level lies above `m0` by
more than `Sqrt[m0^2 + K_c^2] − m0 = 5.78 m0` **[nb07 §5.11: `5.780388`]**, while the bulk continuum starts at `m0`. The
`N_s`-fermion ground state of the free theory therefore has **no wall-localized fermions**; the wall levels
are excited states. On the **opposite-sign** wall the gapless edge band lies below `m0` for `K < ~1.02 m0`;
the free ground state of `N_s <= (4/6 pi^2)(1.02)^3 = 0.072 H^3` **[nb07 §5.8, §5.11: `0.071622`, with `K* = 1.01971543`]** fermions fills it — a genuine
wall-bound massless (3+1)-dimensional Fermi sea — and beyond that the particles spill into the bulk.

**(b) Same-sign wall, attractive `W`: the wall-band sector** (`lam = −0.01 H^-3`, `N_s = 100 H^3`, `m0 = 1`).
The self-consistency **converges** (9 iterations, `max |m_new − m| = 1.5e-10`). At the box size `Z = 30/H`:

```
E/A = 937.2277360325 H^4   (sum of occupied omega = 936.0540086871, interaction Int(W - sigma W') = 1.1737273454)
E/N = 9.37227736 H        mu = 11.6958993131 H
band n = 0 (irrep -i) holds all N_s: k in [5.45898483, 11.80021359]; band bottom omega = 5.54982120 at the self-consistent threshold k_lo = 5.45898 (bare 6.70624)
```

(every number in this block **[nb07 §5.17]**); the density profile has `sigma = n = 0` at the wall, a maximum `sigma = 23.845616`
**[nb07 §5.17]** (mass minimum `m = 0.761543845` **[nb07 §5.17]**) at `z = 0.167`, and an inverse-square tail. The truncation at
`Z` converges slowly (a self-consistent tail `m − m0 = −0.032/z^2`); extrapolated, `E/A -> 936.46–936.53`
, `mu -> 11.692`, `k_lo -> 5.439`; grid, quadrature and `k`-grid are converged to
`<= 4e-5` in `E/A` **[WG 6.5]**. **But this converged state is not the ground state.** (i) `mu − m0 = 10.696 > 0`:
bulk continuum states lie below the Fermi level, so the global Kohn–Sham ground state has no wall layer at
this coupling. (ii) Even within the wall-band sector the Walecka functional
`Omega[m] = Sum_occ omega[m] + Int (m − m0)^2/(2 |lam|) dz/Sin` is **not stationary**: along
`m = m0 + s (m_sc − m0)`, `Omega = 938.1963767831, 937.2277359473, 936.2641446367` **[nb07 §5.17]** at `s = 0.98, 1.00, 1.02`
and `d Omega/ds = −48.305804` **[nb07 §5.17]** — the threshold term `(4/2 pi^2) k_lo^2 (−dk_lo/ds)(R(k_lo) − mu) = −48.306186`
(`dk_lo/ds = −1.301519`, `R(k_lo) = 5.549821`; agreement to `8e-6` relative):
a deeper well pulls new bound states out of the continuum at the band bottom (energy `~5.55`) and they
replace Fermi-surface states (energy `mu = 11.70`). So the result is reported as the **self-consistent
wall-band configuration**, not as a variational ground state.

**The first excited state (Delta-SCF)** of that configuration: a fraction `x` of `N_s` in band `n = 1` (irrep
+i), the rest in `n = 0`, each band filled from its bottom; all converged to `1e-9`:

| `x` | `E/A` | `Delta E/A` | `Delta E` per promoted fermion |
|---|---|---|---|
| 0.01 | `957.9790646375` **[nb07 §5.17]** | `20.7513286050` | `20.75132861` **[nb07 §5.17]** |
| 0.05 | `1041.8217858764` **[nb07 §5.17]** | `104.5940498439` | `20.91880997` **[nb07 §5.17]** |
| 0.10 | `1148.4782948320` **[nb07 §5.17]** | `211.2505587995` | `21.12505588` **[nb07 §5.17]** |
| 0.20 | `1367.8210883907` **[nb07 §5.17]** | `430.5933523582` | `21.52966762` **[nb07 §5.17]** |

The lowest Delta-SCF excitation is the `x -> 0+` limit, about `20.75 H` per promoted fermion, close to the
bottom of band `n = 1` (`omega = 31.99` at `k_lo = 31.975`) minus the top of `n = 0` (`11.63`), `= 20.36`, the
remaining `0.4` being the mean-field rearrangement. Intra-band particle–hole excitations are gapless. The
self-consistent band gaps at fixed `k` (`omega_1 − omega_0`): `2.08513398` **[nb07 §5.17]** (`k = 34`), `2.78024477` **[nb07 §5.17]**
(40), `5.02368345` **[nb07 §5.17]** (60), `7.18485799` **[nb07 §5.17]** (80).

**(c) Opposite-sign wall: the edge band is a true ground state** (`m0 = 1`, `N_s = 0.05 H^3`). The edge band
starts at the Dirac point (`omega = 0`, `k = 0`); `N_s = 0.05` fills it to `k_F = 0.90459` **[nb07 §5.12]** with `mu < m0`:
every state below `mu` is a bound wall state, so this is a genuine ground state of `N_s` fermions.

| | `lam = −0.01 H^-3` | `lam = −10 H^-3` |
|---|---|---|
| iterations | 3 (`max \|dm\| < 1e-10`) | 6 (`max \|dm\| < 1e-10`) |
| `E/A` | `0.033268937058 H^4` **[nb07 §5.12]** | `0.033267529405 H^4` **[nb07 §5.12]** |
| `E/N` | `0.66537874 H` **[nb07 §5.12]** | `0.66535059 H` **[nb07 §5.12]** |
| `mu` | `0.8871343842 H` **[nb07 §5.12]** | `0.8870591549 H` **[nb07 §5.12]** |
| `sigma(z)` | in `[−7.964e-4, 0]` (negative: `f ~ −g`) | in `[−7.986e-4, 0]` |
| `m(z)` | in `[1, 1.00000796]` | in `[1, 1.00798557]` (the attraction **raises** `m` near the wall) |
| Walecka check | slope `−1.2e-14`, curvature `+5.6e-13` | slope `+2.0e-13`, curvature `+5.6e-10` |

Stationary and a **minimum**: a variationally consistent Kohn–Sham ground state. `E/N = 0.6654` is the
massless value `(3/4) v k_F` with `v = 0.9807`: the wall fermions are essentially massless. It is fully
converged (`Z = 45`, a finer grid and more quadrature points change `E/A` by at most `1.6e-12`). **Its first
excited state**: there is no bound band `n = 1` at the occupied momenta (the next positive bands of the
opposite-sign wall appear only at `K = 33.81` and `48.79`); the lowest excitations are gapless intra-band
particle–hole pairs and promotion into the bulk continuum, which costs at least `m0 − mu = 0.113 H` **[nb07 §5.12: `m0 − mu` from its `mu`]**
and unbinds the fermion. A Delta-SCF with a finite fraction in a bound band `n = 1` would require
`k >= 33.81`, at `omega − mu >= ~32.9 H`.

**(d) Strong attraction on the same-sign wall (exploratory; `lam = −100 H^-3`, `N_s = 0.03 H^3`): did not
converge.** Homogeneous bulk matter is self-bound only for `|lam|` between 60 and 80 `H^-3` or more (`min E/n −
m0 = +0.000033` for `lam = −0.01 ... −60`, `−0.038261` for `−80`, `−0.072213` for `−100`). At `lam = −100` the
iteration **failed** (not converged after 60 iterations; `max |m_new − m|` wandered between `6.6e-3` and `0.71`).
What was obtained: the layer **is** bound (`mu = 0.8796 H`, `mu − m0 = −0.1204 H`), the two irreps are occupied
almost equally (the two 4-fold branches become degenerate away from the wall: 8 states per momentum, as in
the homogeneous gas), and the layer drifts **outward** from `z_c = 2.07` to `3.4–3.8`. A rigid-shift
diagnostic shows why: the Walecka energy of the layer decreases monotonically with its distance from the
wall (`0.0318696` at `z_c = 0.6` to `0.0286926` at `6.0`): the same-sign wall **repels** the layer, which has no
stationary position at finite distance. There is no wall-bound Kohn–Sham ground state on the same-sign wall
at this coupling either.

#### 4.6.7 What the density-functional treatment establishes, and what it does not

- **Homogeneous gas.** The Kohn–Sham ground state is the gap root of lowest `rho` (a maximum of the no-sea
  `E_n[sigma]`, a minimum of the Walecka functional for attractive `W`); for the author's mass term it is the
  exact free Fermi sea. The first excitations are gapless particle–hole pairs; pair creation starts at
  `w_F + |m|` (`q = k_F`) and at `2 w_F` for `q = 0`.
- **Along `x0`.** The geometry binds states only above a transverse-momentum threshold on the same-sign
  wall (`K_c(1) = 6.70624 H` at `m = H` **[nb07 §5.6]**), so the **ground state of the free fable has no
  wall-bound fermions there**; the wall levels (ground `70.98531` **[nb07 §5.5]**, first excited `78.14425` **[nb07 §5.5]** at
  `K = 80`) are excited states of the many-body system. On the opposite-sign wall a gapless edge band of
  massless wall fermions exists at every `K`, and it carries a variationally consistent Kohn–Sham ground
  state; its first excitations are gapless.
- **What did not work** [WG 8]: on the same-sign wall the self-consistent wall-band configuration converges
  but is neither the global ground state nor a variational minimum within its sector; the strong-coupling
  layer does not converge (the wall repels it). A grand-canonical treatment with a bulk fable density and a
  position-constrained iteration were not done. Two runs of the derivation, before `DumpSave` was blocked,
  rewrote the notebook's two Part II `.mx` files; their content was verified identical to the committed
  version (the final script blocks `DumpSave`).
- **Caveats** [WG 8]: `a4` frozen (adiabatic; with `a4` varying the momentum redshifts as `K_inf = k e^{a4}`);
  zero modes along `x5..x7` and along the transverse directions other than the momentum; the wall condition
  is a choice of self-adjoint extension and the results depend strongly on it; no-sea, `E_xc` neglected,
  local functional `m(z) = W'(sigma(z))`; the Delta-SCF states are stationary configurations with constrained
  occupations, not eigenstates of an exact many-body Hamiltonian.

**Notebook 07.** `fable-cosmology/notebooks/07_fable_dft_states.ipynb` re-runs these computations with
`waveguide.py` (its same-sign Kohn–Sham runs at a reduced resolution, compared in its §5.17 with
the solver's full-resolution run, which it starts in the background), writes their tables and figures
under `fable-cosmology/results/nb07_*`, and asserts every number it prints. Executed and committed in
`aca5102`, it prints again every wall-state number above that carries the mark **[nb07 §n]**. The
numbers of this section that it does **not** print again, and which are therefore quoted from the
report alone **[WG n]**, are: the levels `−2.21043470304386` (`th = 1.0`, `K = 3`) and
`20.1427411133772` (`m = 4`, `K = 20`) of the Mathematica comparison; the bare band gap `9.27198785` at
`K = 100`; `Int (f^2 − g^2) = 0.02345024` of the level `n = 2` at `K = 80` and `−0.0498` of the
opposite-sign edge level at `K = 3`; and the extrapolation of the same-sign Kohn–Sham state to
`Z -> infinity` (`E/A -> 936.46–936.53`, `mu -> 11.692`, `k_lo -> 5.439`). For that last item notebook 07
prints instead the larger box `Z = 45`: `E/A = 937.06107832 (Z = 30: 937.22904016; difference
-0.167962, -1.79e-04 relative); mu = 11.69499658 (-9.07e-04); k_lo = 5.454492` and the tail
`sigma(20)/sigma(10) = 0.2529 (an inverse-square tail gives 0.25)` **[nb07 §5.13]**, consistent with
the slow convergence in `Z` described above.

### 4.7 Solving the coupled equations from the beginning of the present universe to today

The coupled system of sections 4.2–4.5 is solved three times independently: by the Rust solver
`fable_fermion` on the pure-Rust SUNDIALS 7.8.0 CVODE of the rustSolveIt repositories (`fable_fermion
0.1.0, sundials_rs 7.8.0 (pure Rust), CVODE BDF`, its `--version` line), by the independent Python
implementation `fable-cosmology/fermion/crosscheck.py` (adaptive quadrature, `brentq`, DOP853), and, for
two reference cases, by Mathematica (Part VIII, Section 33, and `fable-cosmology/reference/make_reference_fermion.wls`).
The runs, their tables and their figures are those of notebook 06 **[nb06]**, which writes every file named
below under `fable-cosmology/results/`.

#### 4.7.1 The two models, and the system handed to CVODE

**`fable8d` — the unstabilized 8-dimensional system.** The asymptotic region of the primordial field is
the Bianchi-I metric of section 4.3.4; the sources are radiation (on the observed sheet, `P_obs = rho_r/3`,
`P_hid = P_x0 = 0`, `rho_r = Omega_r0 A^-4/v`), baryons (dust in every direction, `rho_b = Omega_b0 A^-3/v`) and the
Kohn–Sham fable of section 4.5 (`k_F = k_F0/A`, per 7-volume, the gap solved at every step). The equations
are the constraint (monitored, not imposed) and the evolution equations of section 4.3.4 with
`kappa_8 rho -> 3 rho_hat` (densities per 7-volume in `rho_c0`), so that `kappa_8 (P_i − T/6)` becomes
`F/2 + 3 (P_i − P_hid)`:

```
dH_A/dt = -H_A Theta + F/2 + 3 (P_obs - P_hid),        dH_B/dt = -H_B Theta + F/2,        dH_C/dt = -H_C Theta + F/2
```

with the hidden driver `F` and `P_obs − P_hid` formed per source analytically — radiation `0` and `rho_r/3`,
baryons `rho_b` and `0`, the fable `2 W − sigma8 W'` and `P_KS/v` — never by subtracting large numbers. The
independent variable is `N = ln A`; since the physical rates fall like `A^-2` by many orders of magnitude
while `H_B` and `H_C` start at exactly zero, CVODE integrates the scaled variables `h_i = H_i A^2` and
`tau = t/A^2`, state `y = (ln B, ln C, h_A, h_B, h_C, tau)`:

```
d ln B/dN = H_B/H_A,        d ln C/dN = H_C/H_A,        dh_i/dN = 2 h_i + A^2 (dH_i/dt)/H_A,        dtau/dN = -2 tau + A^-2/H_A
```

Initial state: `H_B = H_C = 0`, `H_A` from the constraint, `t(a_i) = 1/(2 H_A(a_i))`. The forward run is a
**boundary-value problem** (`H_B = H_C = 0` at `a_i`; `H_A = B = C = 1` today), solved by an outer shooting
(bracket and Brent) on the fable's amplitude and an inner secant iteration on `ln v(a_i)`. It runs forward
only (9.11). [prose nb06 §4, §4.1; file: `fable-cosmology/rust/fable_fermion/src/models.rs` and `run.rs`,
module documentation.] (The module summary of `models.rs` still lists the unscaled state
`(ln B, ln C, H_A, H_B, H_C, t)`; its right-hand side and the notebook integrate the scaled one above.)

**`fable4d` — the stabilized model, the physical one.** `fable8d` plus a zero-energy stabilizing stress
`P_stab = −F_total/2` added to the hidden pressures of `B` and `C`. Then `F_total + 2 P_stab = 0`, `H_B = H_C = 0` is
preserved exactly, `v = 1`, and the observer's equations are **exactly** the Friedmann equations
`3 H_A^2 = kappa rho`, `H_A' = −(kappa/2)(rho + P_obs)`, with the hidden equations satisfied identically. The
stabilizer is a **Lagrange multiplier** that enforces the frozen hidden sheet, not a stress derived from any
field; it has zero energy density, drops out of the conservation law at `H_B = H_C = 0`, and it **violates the
null energy condition along `x0`** whenever dust is present: for the null vector `k = e_0/C + e_4` in the
`(x0, x4)` plane `T_stab(k, k) = P_stab = −F/2`, which is `−rho_dust/2 < 0` for dust alone. **[proved VIII §33]**
`fable4d [THE RESULT]: with P_stab = -F/2 on B and C, the hidden drivers vanish, F + 2 P_stab == 0, so H_B = H_C = 0 is preserved exactly`,
`fable4d [THE RESULT]: with B = C = 1 (labelled substitution) the Einstein equations are EXACTLY 3 H_A^2 == kappa rho and H_A' == -(kappa/2)(rho + P_obs); the x0 and hidden equations then hold with P_hid + P_stab`,
`fable4d [has content]: the Friedmann pair is self-consistent -- d/dx4 (3 H_A^2 - kappa rho) == 0 when H_A' = -(kappa/2)(rho + P_obs) and rho' = -3 H_A (rho + P_obs) (the conservation law at H_B = H_C = 0)`,
`fable4d [THE RESULT]: the stabilizer VIOLATES the null energy condition along x0: T_stab(k, k) == P_stab == -F/2 for the null k in the (x0, x4) plane, == -rho_dust/2 < 0 for dust alone`,
`fable4d [has content]: it is a Lagrange multiplier with zero energy -- rho_stab == 0, and at H_B = H_C = 0 it drops out of the conservation law (its term is (3 H_B + H_C) P_stab)`.
(Without the stabilizer, dust would decelerate as `dH/dt = −(5/2) H^2` instead of `−(3/2) H^2` [file:
`models.rs`, module documentation].) `fable4d` is **algebraic** in `a`: `k_F = k_F0/a`, the gap is local,
`H_A(a)^2 = Omega_r0 a^-4 + Omega_b0 a^-3 + rho_f(a)`, and only the age `t(a)` is integrated
(`dtau/dN = −2 tau + A^-2/H_A(N)`). `fable8d --freeze-hidden` integrates the `fable8d` system with the
stabilizer (`dH_A/dt = −3 H_A^2 + (3/2)(rho − P_obs)`, `H_A` evolved, not algebraic) and must reproduce
`fable4d`; it does (9.10).

**CVODE settings:** BDF, Newton iteration, a dense Jacobian, `rtol = 1e-10`, `atol = 1e-12` [prose nb06 §4.1].
**Normalization:** `fable4d` by a closure today, `rho_r + rho_b + rho_f = 1` at `A = 1`, with one shooting
parameter per potential (9.3). **The branch:** the gap root of lowest `rho` (section 4.5.3).

**Units** (`fable_fermion --constants`, printed by notebooks 05 and 06; `hbar = c = k_B = 1`):

```
h                     = 0.674
H0                    = 2.1842852411e-18 1/s = 6.8930799924e-11 1/yr = 1.4377226622e-33 eV
1/H0                  = 1.4507302992e10 yr
M_pl (reduced, from G)= 2.4353234593e27 eV = 2.4353234593e18 GeV
rho_c0 = 3 H0^2 M_pl^2= 3.6777719498e-11 eV^4
E_c = rho_c0^(1/4)    = 2.4626131773e-3 eV   (unit of m, kF; sigma, n in E_c^3; W, rho in E_c^4 = rho_c0)
1 eV                  = 4.0607270732e2 E_c
T_CMB                 = 2.7255 K = 2.3486541806e-4 eV;  T_nu0 = 1.6763891605e-4 eV
Omega_gamma0          = 5.4437728013e-5   (Omega_gamma0 h^2 = 2.4729753331e-5)
Omega_nu(1 species)0  = 1.2363206389e-5
Omega_r0 (N_eff=3.046)= 9.2096054673e-5   (Omega_r0 h^2 = 4.1837027333e-5)
Omega_b0 = 0.02237/h^2 = 4.9243191364e-2
(g_*(T) is not followed: radiation is Omega_r0 A^-4 at all times, which misstates rho_r A^4 by up to a factor ~0.39 before e+e- annihilation and the QCD transition)
g (fable states per momentum) = 8
a_BBN (T = 1 MeV)     = 1.6763891605e-10   (= T_nu0 / 1 MeV)
a_rec (z = 1090)      = 9.1659028414e-4
```

and the notebooks recompute it in Python from CODATA and agree to `1e-9`. Part VIII computes the same
constants in Mathematica and asserts them [displayed and proved VIII §33]:
`units:  1/H0 = 1.4507303e10 yr;  M_pl = 2.4353235e18 GeV;  rho_c0 = 3.6777719e-11 eV^4;  E_c = rho_c0^(1/4) = 0.0024626132 eV`,
`Omega_gamma0 = 0.000054437728,  Omega_r0 = 0.000092096055,  Omega_b0 = 0.049243191`;
`fable4d RUNS [definition]: the units computed from CODATA 2018 -- E_c = rho_c0^(1/4) == 2.46261e-3 eV, Omega_r0 == 9.2096e-5, Omega_b0 = 0.02237/h^2 == 0.049243 (to the quoted digits)`. The coupling is `kappa_4,0 = kappa_8/V_h,0` with `v = 1` today, and
`Omega_i := kappa_8 rho7_i/(3 H_A^2)`.

**Assumptions** stated with every run [prose nb06 §4]: `x0` is compactified in the asymptotic region with a
Kaluza–Klein gap far above the temperatures considered; the hidden timelike sheet is a formal comoving
volume (compactifying it gives closed timelike curves); every field is truncated to its zero modes along
the hidden directions; gravity is semiclassical (`G = kappa <That>`); the exchange–correlation energy is
neglected; the Dirac-sea energy is absorbed into a renormalized `W` (section 4.5.11); the terms of order `Cot`
and `Cot^2` of the asymptotic reading are neglected (section 4.3.3).

#### 4.7.2 The interval, and why it is the right one

**"From the beginning of the present universe."** The present universe is the asymptotic region of the
primordial field (section 4.3.3), in which the primordial field is the 8-dimensional Bianchi-I metric. Its
beginning, for this system, is the earliest time at which the model applies with ordinary matter: deep in
the radiation era, before nucleosynthesis, with the fable ultra-relativistic. The runs start at

```
a_i  <=  min(1e-10, 0.01 a_nr(m))           (default a_i = 1e-12:  T = T_CMB/a_i = 234.9 MeV;  a_BBN = 1.6763891605e-10 at T = 1 MeV)
```

and end at `A = 1`, defined by `T_CMB = 2.7255 K`. The criterion is checked for every run [prose nb06 §4,
§5.1]. Three facts justify it: (i) before `a_nr` the fable is radiation-like (`w = 1/3` to `1e-8`, asserted
for the reference case in Part VIII) and its history is fixed by its conserved number; (ii) the pre-universe
itself does **not** fix `a_i` — nothing in the notebook ties the author's constant `H` or the position along
`x0` to a time in the present universe (section 4.3.3); (iii) the results do not depend on `a_i`
**[nb06 §5.1, file: `fable-cosmology/results/nb06_ai_insensitivity.csv`]**:

| model | `a_i` | `T(a_i)`/MeV | `H_B(1)` | `rho_U(1)` | `q0` | `t0` [1/H0] | `w_f(0.5)` | `G(a_BBN)/G(1)` |
|---|---|---|---|---|---|---|---|---|
| fable4d | 1e-12 | 234.9 | `0.0000e+00` | `0.685664712581` | `−0.528451020843` | `0.951246512174` | `−0.244385837789` | `1.000000e+00` |
| fable4d | 1e-11 | 23.5 | `0.0000e+00` | `0.685664712581` | `−0.528451020843` | `0.951246510304` | `−0.244385846968` | `1.000000e+00` |
| fable4d | 1e-10 | 2.3 | `0.0000e+00` | `0.685664712581` | `−0.528451020843` | `0.951246512298` | `−0.244385836589` | `1.000000e+00` |
| fable8d | 1e-12 | 234.9 | `9.9990e-01` | `6.684880971343` | `−0.842486541055` | `0.652899266076` | `−0.164884834974` | `1.046057e+12` |
| fable8d | 1e-11 | 23.5 | `9.9990e-01` | `6.684880972924` | `−0.842486540972` | `0.652899265712` | `−0.164884977537` | `1.046057e+12` |
| fable8d | 1e-10 | 2.3 | `9.9990e-01` | `6.684880970384` | `−0.842486544662` | `0.652899266556` | `−0.164884818972` | `1.046057e+12` |

(`lambda-mass`, `m0 = 30 eV`.) The largest relative change between `a_i = 1e-12` and `1e-10` is `2.0e-09` (`t0`)
and `3.8e-08` (`w_f(0.5)`) in `fable4d`, `8.6e-07` (`w_f(0.5)`) in `fable8d`. The one approximation the
early start exposes is `g_*(T)`, which is not followed (the solver's constants line above).

#### 4.7.3 The potentials, and what each run fixes

For the potentials that supply dark energy the split is imposed today: the quasiparticles carry
`Omega_qp0 = 0.265` (the dark matter) at the mass `m_today = W'(sigma_t)`, and the amplitude closes the budget
[prose nb06 §3; file: `run.rs`, module documentation]:

| name | `W(sigma)` | given | shot (to close the budget today) |
|---|---|---|---|
| `mass` (the author's) | `m0 sigma` | `m0` | `ln k_F0`; the fable closes the budget alone, `Omega_f0 = 1 − Omega_r0 − Omega_b0` (Einstein–de Sitter-like) |
| `lambda-mass` | `V0 + m0 sigma` | `m0`, `Omega_qp0 = 0.265` | `V0` (a bare Lambda, reported as such); `k_F0` from `eps_KS(m0, k_F0) = Omega_qp0` |
| `power` | `m0 sigma + lam sigma^nu` | `m_today`, `nu`, `Omega_qp0` | the condensate energy today `U_t = (1 − nu) lam sigma_t^nu`; then `lam = U_t/((1 − nu) sigma_t^nu)`, `m0 = m_today − nu lam sigma_t^(nu−1)` (may be negative) |
| `expdamp` | `V0 + m0 sigma e^(−sigma/s1)` | `m_today`, `xt = sigma_t/s1` (Part VI's `1/2.21`), `Omega_qp0` | `V0`; `s1 = sigma_t/xt`, `m0 = m_today e^xt/(1 − xt)` |
| `quadratic` | `V0 + m0 sigma + (lam/2) sigma^2` | `m_today`, `gq = lam sigma_t/m_today`, `Omega_qp0` | `V0`; `m0 = m_today (1 − gq)` |
| `lorentz` | `V0 + m0 sigma/(1 + (sigma/s1)^2)` | `m_today`, `xt` (Part VI's `1/1.5`), `Omega_qp0` | `V0`; `m0 = m_today (1 + xt^2)^2/(1 − xt^2)` |

#### 4.7.4 Runs (a): the author's mass term alone — an Einstein–de Sitter universe with a fable that cools

`W = m0 sigma`, `fable4d`, `m0 = 1, 30, 100, 1000, 2000 eV`. There is no condensate (`U = 0`): the fable is a
free degenerate gas and, with no Lambda, it closes the budget. Its `w_f = w_DM = P_KS/eps_KS` runs from 1/3 to 0
through `a_nr`, the scale factor at which `k_F = m` **[nb06 §5.2, file: `results/nb06_runs.csv`, figure
`results/nb06_a_mass_wdm.png`]**:

| run | `k_F0` [eV] | `a_nr` | `a_i` ok | `DeltaN_eff` BBN | `DeltaN_eff` rec | `3P/rho_nu` rec | `q0` | `t0` [Gyr] | `Omega_f0` |
|---|---|---|---|---|---|---|---|---|---|
| mass 1 eV (EdS) | `6.3727e-04` | `6.3727e-04` | True | `36.75` | `79.96` | `17.67` | `0.50005` | `9.6706` | `0.95066` |
| mass 30 eV (EdS) | `2.0509e-04` | `6.8364e-06` | True | `0.3943` | `70.49` | `0.002353` | `0.50005` | `9.6707` | `0.95066` |
| mass 100 eV (EdS) | `1.3730e-04` | `1.3730e-06` | True | `0.07918` | `70.48` | `9.489e-05` | `0.50005` | `9.6707` | `0.95066` |
| mass 1000 eV (EdS) | `6.3727e-05` | `6.3727e-08` | True | `0.003675` | `70.48` | `2.044e-07` | `0.50005` | `9.6707` | `0.95066` |
| mass 2000 eV (EdS) | `5.0580e-05` | `2.5290e-08` | True | `0.001459` | `70.48` | `3.22e-08` | `0.50005` | `9.6707` | `0.95066` |

(`DeltaN_eff` is the whole fable energy in units of one massless neutrino species; at recombination it is
large because the fable is the dark matter there, and `3P/rho_nu` is its radiation-like part.) The solver's
own log of the 30 eV run (`fable_fermion fable4d --potential mass --param m0_ev=30`, printed in notebook 05):
`# NOTE: W = m0 sigma alone (no V0): the closure forces Omega_f0 = 1 - Omega_b0 - Omega_r0 = 0.950665: an
Einstein-de Sitter-like universe (q0 = 0.5000, +1/2 for pure dust)`, and `a_nr (kF = |m_eff|) = 6.837070e-6
(z_nr = 1.4626e5), a_eq = 9.2105e-5: WARM / not hot (a_nr between 1e-6 and a_eq)` **[nb05 §5.7]**. This model
has no dark energy; it is the author's mass term as the only content of the dark sector.

#### 4.7.5 Runs (b): a mass term plus a bare cosmological constant — ΛCDM with fable dark matter

`W = V0 + m0 sigma`, `fable4d`, `Omega_qp0 = 0.265`, `V0` (a bare Lambda) closing the budget **[nb06 §5.3, figure
`results/nb06_b_lambda_mass.png`]**:

| run | `a_nr` | `DeltaN_eff` BBN | `DeltaN_eff` rec | CPL `w_f` `(w0, wa)` | CPL `w_DE,inf` `(w0, wa)` | `max \|w_DE,inf + 1\|`, `a >= 0.3` | `q0` | `t0` [Gyr] | `V0 = rho_U` |
|---|---|---|---|---|---|---|---|---|---|
| lambda-mass 30 eV | `4.4658e-06` | `0.07179` | `19.65` | `(−0.7573, +1.0100)` | `(−1.0000000003, +1.33e-09)` | `1.47e-09` | `−0.52845` | `13.8000` | `0.685665` |
| lambda-mass 100 eV | `8.9687e-07` | `0.01442` | `19.65` | `(−0.7573, +1.0100)` | `(−1.0000000000, +5.34e-11)` | `5.91e-11` | `−0.52845` | `13.8000` | `0.685665` |
| lambda-mass 1000 eV | `4.1629e-08` | `0.0006692` | `19.65` | `(−0.7573, +1.0100)` | `(−1.0000000000, +1.16e-13)` | `1.31e-13` | `−0.52845` | `13.8000` | `0.685665` |
| lambda-mass 2000 eV | `1.6521e-08` | `0.0002656` | `19.65` | `(−0.7573, +1.0100)` | `(−1.0000000000, +1.72e-14)` | `2.40e-14` | `−0.52845` | `13.8000` | `0.685665` |
| lambda-mass 30 eV (reference) | `4.4658e-06` | `0.07179` | `19.65` | `(−0.7569, +1.0092)` | `(−1.0000000003, +1.31e-09)` | `1.44e-09` | `−0.52845` | `13.8000` | `0.685665` |

The mass does not vary (`w_DM,eff = w_DM`, `Q = 0`) and the condensate is the constant `V0`, so the dark
energy an observer infers **is a cosmological constant**, to the precision of the quasiparticles' kinetic
energy that the observer counts as dark energy. The intrinsic `w_f` today is `−0.72124767` [file: `nb06_runs.csv`]
— it mixes the gas and `V0` and is not a dark-energy equation of state. The fifth run (`a_i = 1e-10`, 701
rows, `results/nb06_fable4d_mass30eV.csv`) is Part VIII's reference case (9.12).

#### 4.7.6 Runs (c): potentials with which the fable supplies the dark energy itself

`power` (`nu = 0.236`, `0.5`), `expdamp` (Part VI's `xt = 1/2.21`), attractive `quadratic` (`gq = −0.5`), each
at `m_today = 30` and `100 eV`, `fable4d`, and Part VIII's mass-varying reference case (`power`, `nu = 0.5`,
`m_today = 100 eV`, `Omega_qp0 = 0.55`, 701 rows, `results/nb06_fable4d_power.csv`) **[nb06 §5.4, figures
`results/nb06_c_de_potentials.png`, `results/nb06_c_exchange_vacuum_stabilizer.png`]**:

| run | `a_nr` | min `m/m_today` (`1e-3 <= a <= 0.3`) | `w_f(1)` | min `w_f` | CPL `w_f` | poles of `w_DE,inf` | `w = −1` crossings | phantom in `0.3 <= a <= 1`? | CPL `w_DE,inf` | fit from `a` | min `c_s^2` |
|---|---|---|---|---|---|---|---|---|---|---|---|
| power nu=0.236, 30 eV | `2.22e-05` | `2.01e-01` | `−0.7212` | `−0.7212` | `(−0.783, +0.445)` | `3.43e-06, 0.533` | `4.55966e-06, 1` | True | `(−0.082, −7.986)` | `0.559` | `−0.611` |
| power nu=0.236, 100 eV | `4.47e-06` | `2.01e-01` | `−0.7212` | `−0.7212` | `(−0.783, +0.445)` | `6.89e-07, 0.533` | `9.15884e-07, 1` | True | `(−0.082, −7.986)` | `0.559` | `−0.611` |
| power nu=0.5, 30 eV | `0.669` | `7.91e-12` | `−0.7212` | `−1.0000` | `(−0.804, −0.358)` | `3.35e-06, 0.619` | `4.46748e-06, 1` | True | `(−0.249, −10.191)` | `0.650` | `−27` |
| power nu=0.5, 100 eV | `0.669` | `1.59e-12` | `−0.7212` | `−1.0000` | `(−0.804, −0.359)` | `6.73e-07, 0.619` | `8.97015e-07, 1` | True | `(−0.249, −10.191)` | `0.650` | `−27` |
| expdamp xt=1/2.21, 30 eV | `0.712` | `6.58e-12` | `−0.7212` | `−1.0000` | `(−0.829, −0.317)` | `3.35e-06, 0.625` | `4.46748e-06, 1` | True | `(−0.128, −11.778)` | `0.656` | `−21.8` |
| expdamp xt=1/2.21, 100 eV | `0.712` | `1.32e-12` | `−0.7212` | `−1.0000` | `(−0.829, −0.317)` | `6.73e-07, 0.625` | `8.97015e-07, 1` | True | `(−0.128, −11.779)` | `0.656` | `−21.8` |
| quadratic gq=−0.5, 30 eV | `0.643` | `8.93e-12` | `−0.7212` | `−1.0000` | `(−0.730, −0.483)` | `3.35e-06, 0.602` | `4.46748e-06, 1` | True | `(−0.180, −9.321)` | `0.632` | `−47.1` |
| quadratic gq=−0.5, 100 eV | `0.643` | `1.79e-12` | `−0.7212` | `−1.0000` | `(−0.730, −0.483)` | `6.73e-07, 0.602` | `8.97015e-07, 1` | True | `(−0.180, −9.321)` | `0.632` | `−47.1` |
| power nu=0.5, 100 eV, `Omega_qp0 = 0.55` | `4.21e-06` | `2.72e-01` | `−0.4215` | `−0.4215` | `(−0.448, +0.264)` | `8.96e-07, 0.63` | `1.18957e-06, 1` | True | `(−0.327, −9.682)` | `0.662` | `−0.364` |

and, for the same runs **[nb06 §5.4]**:

| run | `c_s^2 < 0` on (`a >= 1e-3`) | `w_DM,eff` range (`a >= 1e-3`) | `\|DeltaE_vac\|/rho_tot`, `a >= 0.3` | `P_stab(1)` [`rho_c0`] | `DeltaN_eff` BBN |
|---|---|---|---|---|---|
| power nu=0.236, 30 eV | `[0.00409, 1]` | `(−0.611, +9.85e-05)` | `1.314e+13` | `−0.8428` | `0.0718` |
| power nu=0.236, 100 eV | `[0.00194, 1]` | `(−0.611, +3.59e-06)` | `1.622e+15` | `−0.8428` | `0.0144` |
| power nu=0.5, 30 eV | `[0.608, 1]` | `(−27.6, +0.333)` | `2.229e+14` | `−0.8428` | `0.0718` |
| power nu=0.5, 100 eV | `[0.608, 1]` | `(−27.7, +0.333)` | `2.752e+16` | `−0.8428` | `0.0144` |
| expdamp xt=1/2.21, 30 eV | `[0.643, 1]` | `(−21.8, +0.333)` | `2.327e+14` | `−0.8428` | `0.0718` |
| expdamp xt=1/2.21, 100 eV | `[0.643, 1]` | `(−21.8, +0.333)` | `2.873e+16` | `−0.8428` | `0.0144` |
| quadratic gq=−0.5, 30 eV | `[0.592, 1]` | `(−47.1, +0.333)` | `2.031e+14` | `−0.8428` | `0.0718` |
| quadratic gq=−0.5, 100 eV | `[0.592, 1]` | `(−47.1, +0.333)` | `2.508e+16` | `−0.8428` | `0.0144` |
| power nu=0.5, 100 eV, `Omega_qp0 = 0.55` | `[0.001, 1]` | `(−0.364, −3.89e-05)` | `2.350e+14` | `−0.7003` | `0.0382` |

and `smallest w_f over all 9 runs: -0.9999987921 (never below -1);  every run has c_s^2 < 0 somewhere after
a = 1e-3: True`. Reading the tables:

- Only the two `nu = 0.236` runs and the reference run stay **massive** through the matter era. The
  `nu = 0.5`, `expdamp` and `quadratic` runs with `Omega_qp0 = 0.265` have `min m/m_today ~ 1e-12`: the gap pins
  their mass near zero and the fable is a **massless gas** (radiation, `w = 1/3`) until `a_nr = 0.64–0.71` —
  it supplies no dark matter at recombination (`DeltaN_eff` at recombination equals its BBN value, e.g.
  `0.071792425` for `power nu=0.5, 30 eV` [file: `nb06_runs.csv`]). Their CPL fits of `w_f` look like the
  supernova fits `(−0.861, −0.60)`, but they are not viable cosmologies.
- The observer's inferred dark energy `w_DE,inf` has **poles** (its `rho_DE,inf` changes sign) inside
  `0.3 <= a <= 1` in every run, and it is phantom and crosses `−1` in every run; a CPL line is not a
  faithful description (the fits above the pole are in `results/nb06_cpl_fits.csv`).
- `c_s^2 < 0` in every run: an **adiabatic instability**.
- The Dirac-sea energy that the no-sea functional drops changes along every run by `1.31e13` to `2.87e16`
  times the total density at `a >= 0.3`.

#### 4.7.7 The inferred dark energy of a massive power law, in closed form

Once the gas is non-relativistic, `sigma8 ≈ n ∝ a^-3`, the condensate is `U = U_t a^(−3 nu)` and the mass
`m(a) = m0 + nu U_t a^(3(1−nu))/((1 − nu) sigma_t)`. Subtracting cold dark matter with today's mass leaves
`rho_DE,inf = U + (m(a) − m_today) n = U_t [a^(−3 nu) − nu a^−3]/(1 − nu)` and `P_DE = −U`, hence

```
w_DE,inf(a)  =  -(1 - nu) / (1 - nu a^(-3(1 - nu)))
```

a pole at `a_pole = nu^(1/(3(1 − nu)))`, `w > 0` before it, phantom (`w < −1`) between it and today, and
`w = −1` at `a = 1` up to the quasiparticles' kinetic energy, which makes it cross `−1` just before today. It
depends on `nu` alone [prose nb06 §5.4]. The runs agree **[nb06 §5.4]**:

```
power nu=0.236, 30 eV                  w_DE,inf against -(1-nu)/(1 - nu a^(-3(1-nu))) on a >= 0.3: max deviation 1.2e-09;  pole: formula 0.532600, run 0.532723;  crossing of -1: 1.00000000
power nu=0.236, 100 eV                 w_DE,inf against -(1-nu)/(1 - nu a^(-3(1-nu))) on a >= 0.3: max deviation 4.9e-11;  pole: formula 0.532600, run 0.532723;  crossing of -1: 1.00000000
power nu=0.5, 100 eV, Omega_qp0=0.55   w_DE,inf against -(1-nu)/(1 - nu a^(-3(1-nu))) on a >= 0.3: max deviation 4.2e-11;  pole: formula 0.629961, run 0.630028;  crossing of -1: 1.00000000
```

The mechanism is that of Das, Corasaniti and Khoury, Phys. Rev. D 73, 083509 (2006): subtracting cold dark
matter with today's mass when the mass was different leaves `rho_DE + P_DE ≈ (m_eff(a) − m_today) n`, which is
negative whenever `m_eff` grows; an apparent phantom with no phantom field.

#### 4.7.8 The scans: where does a dark-energy fable stay massive through the matter era?

Notebook 06 scanned the shape parameters — `power` `nu = 0.05 … 0.65`, `quadratic` `gq = −0.95 … −0.05`,
`expdamp` `xt = 0.1 … 0.9`, and for `power` `nu = 0.3` and `0.5` the quasiparticle share
`Omega_qp0 = 0.265 … 0.8` — at `m_today = 1000 eV` and `100 eV` (`fable4d`, 401 output rows, 45 + 45 runs), and
re-computed every scan run independently as it ran **[nb06 §5.6, files `results/nb06_scan.csv`, figures
`results/nb06_scan.png`, `results/nb06_scan_cpl.png`]**. Its conclusions, verbatim:

```
scan points whose fable stays massive through 1e-3 <= a <= 0.3 (min m/m_today > 1e-3): 28 of 90: power, nu=0.05 (1000 eV), power, nu=0.1 (1000 eV), power, nu=0.15 (1000 eV), power, nu=0.2 (1000 eV), power, nu=0.25 (1000 eV), power nu=0.3, Omega_qp0=0.35 (1000 eV), power nu=0.3, Omega_qp0=0.45 (1000 eV), power nu=0.3, Omega_qp0=0.55 (1000 eV), power nu=0.3, Omega_qp0=0.65 (1000 eV), power nu=0.3, Omega_qp0=0.8 (1000 eV), power nu=0.5, Omega_qp0=0.5 (1000 eV), power nu=0.5, Omega_qp0=0.55 (1000 eV), power nu=0.5, Omega_qp0=0.65 (1000 eV), power nu=0.5, Omega_qp0=0.8 (1000 eV), power, nu=0.05 (100 eV), power, nu=0.1 (100 eV), power, nu=0.15 (100 eV), power, nu=0.2 (100 eV), power, nu=0.25 (100 eV), power nu=0.3, Omega_qp0=0.35 (100 eV), power nu=0.3, Omega_qp0=0.45 (100 eV), power nu=0.3, Omega_qp0=0.55 (100 eV), power nu=0.3, Omega_qp0=0.65 (100 eV), power nu=0.3, Omega_qp0=0.8 (100 eV), power nu=0.5, Omega_qp0=0.5 (100 eV), power nu=0.5, Omega_qp0=0.55 (100 eV), power nu=0.5, Omega_qp0=0.65 (100 eV), power nu=0.5, Omega_qp0=0.8 (100 eV)
of these, with c_s^2 >= 0 after a = 1e-3: 0;  smallest c_s^2 among them: -0.6469;  largest: -0.0565
power law: 'massive through the matter era' <=> 'bare m0 > 0' at all 52 power scan points: True
the estimate Omega_qp0/U_t > nu/(1 - nu) agrees with the sign of m0 at 52 of 52 points;  with Omega_qp0 = 0.265 it allows nu < Omega_qp0/(1 - Omega_b0 - Omega_r0) = 0.2788
```

So: **every `quadratic` and `expdamp` point is massless in the matter era; a power law stays massive exactly
when its bare mass `m0 = m_today − nu lam sigma_t^(nu−1)` is positive, i.e. when `Omega_qp0/U_t > nu/(1 − nu)`; with
the observed split `Omega_qp0 = 0.265` that requires `nu < 0.2788`** (massive up to `nu = 0.25`, massless from
`nu = 0.3` in the scan); a larger `nu` needs a larger quasiparticle share (`Omega_qp0 >= 0.35` for `nu = 0.3`,
`>= 0.5` for `nu = 0.5`). And every massive point has `c_s^2 < 0` after `a = 1e-3`. (At high density
`nu lam sigma^(nu−1) -> 0`, so if `m0 < 0` the gap can only be met with `m -> 0+`; with `sigma_t ≈ n_t` and
`eps_KS ≈ m_today n_t` today this happens exactly when `Omega_qp0/U_t < nu/(1 − nu)` [prose nb06 §5.6].) In the massless
cases the smallest `c_s^2` sits at the sharp release of the pinned gap, and its magnitude depends on how finely
the output grid samples that release; its sign does not [prose nb06 §5.6]. The largest cross-check difference
over the 90 scan runs is `4.43e-09` **[nb06 §5.10]**.

#### 4.7.9 How heavy must a fable that is all of the dark matter be?

**[nb06 §5.7, file `results/nb06_dm_mass_bounds.csv`, figure `results/nb06_dm_mass_bounds.png`]**

| bound | fable mass | detail |
|---|---|---|
| `DeltaN_eff(BBN) < 0.3` | `m > 10.2645 eV` | fit over 17 runs: `DeltaN_eff = 6.6922 (m/eV)^(-1.33333)`, max `\|ln residual\| = 7.1e-05` |
| `DeltaN_eff(BBN) < 0.2` | `m > 13.9126 eV` | same fit |
| free streaming: `v_rms0` matched to thermal WDM of 3.3 keV (Viel et al. 2013) | `m ≈ 1124.92 eV` | `v_rms0 = 8.2629e-03 km/s` |
| free streaming: `v_rms0` matched to thermal WDM of 5.3 keV (Iršič et al. 2017) | `m ≈ 1806.69 eV` | `v_rms0 = 4.3932e-03 km/s` |
| Tremaine–Gunn, `g = 8`, `sigma = 10 km/s`, `r_c = 0.3 kpc` | `m > 231.315 eV` | `m^4 > 9 h^3/(2 (2 pi)^(5/2) g G sigma r_c^2)` |
| Tremaine–Gunn, `g = 8`, `sigma = 7 km/s`, `r_c = 0.15 kpc` | `m > 357.639 eV` | same |

`DeltaN_eff ∝ m^(−4/3)` because `DeltaN_eff(BBN)` depends only on `k_F0`, which `eps_KS(m, k_F0) = Omega_qp0` fixes,
and `k_F0 ∝ m^(−1/3)` for a non-relativistic gas today; at 1, 30, 100, 1000, 2000 eV it is `6.69227`, `0.0717924`,
`0.0144181`, `0.000669238`, `0.00026561`. A degenerate gas has the velocity dispersion of a filled Fermi sphere,
`v_rms = Sqrt[3/5] k_F/m`: `4.4870e+00`, `2.6132e+00`, `2.0827e-01`, `9.6670e-03`, `3.8364e-03` km/s at 10, 15, 100,
1000, 2000 eV. The Lyman-alpha-allowed thermal-relic warm dark matter (`m_WDM >~ 3.3 keV` and `5.3 keV`) has
`v_rms0 = 8.2629e-03` and `4.3932e-03` km/s; a degenerate fable with the same `v_rms0` needs `m ≈ 1.1–1.8 keV` —
a velocity-matching estimate, not a transfer-function computation. The Tremaine–Gunn bound uses illustrative
dwarf-spheroidal values (inputs, not results). The free-streaming bound is far stronger than `DeltaN_eff`.
At such masses the change of `w_DM` from 1/3 to 0 happens around `a_nr = 4.16e-08` (1 keV) or `1.65e-08` (2 keV).

#### 4.7.10 Runs (d): without the stabilizer, the hidden sheet moves and the Newton constant varies

`fable8d` for the mass term at 1 and 100 eV and `lambda-mass` at 30 eV and 1 keV, and two controls: radiation
alone (`--no-fable --omega-b 0`), which must keep the hidden sheet exactly frozen (`F = 0`), and radiation plus
baryons (`--no-fable`), in which dust alone drives it. `G(a)/G(1) = 1/v` (the observed Newton constant is
`G_4 = G_8/V_hid ∝ 1/v`) **[nb06 §5.8, file `results/nb06_nogo_8d.csv`, figure `results/nb06_d_nogo_8d.png`]**:

| run | `B(a_i)` = `C(a_i)` | `G(a_i)/G(1)` | `G(BBN)/G(1)` | `DeltaG/G` since BBN | `\|d ln G/dt\|` today [/yr] | `H_B/H_A(1)` = `H_C/H_A(1)` | max constraint residual | `Omega_sum(1)` | `q0` | `t0` [Gyr] |
|---|---|---|---|---|---|---|---|---|---|---|
| mass 1 eV, fable8d | `2.3224e-03` | `3.4376e+10` | `3.4376e+10` | `−1.0000e+00` | `2.7571e-10` | `0.999959` | `1.16e-08` | `6.99967` | `2.5000` | `4.145` |
| mass 100 eV, fable8d | `4.8207e-05` | `1.8516e+17` | `1.8516e+17` | `−1.0000e+00` | `2.7571e-10` | `0.999963` | `2.12e-08` | `6.99971` | `2.5000` | `4.145` |
| lambda-mass 30 eV, fable8d | `9.8881e-04` | `1.0461e+12` | `1.0461e+12` | `−1.0000e+00` | `2.7570e-10` | `0.999902` | `2.47e-08` | `6.99922` | `−0.8425` | `9.472` |
| lambda-mass 1 keV, fable8d | `9.8389e-04` | `1.0671e+12` | `1.0671e+12` | `−1.0000e+00` | `2.7570e-10` | `0.999902` | `2.07e-08` | `6.99922` | `−0.8425` | `9.472` |
| radiation only, fable8d | `1.0000e+00` | `1.0000e+00` | `1.0000e+00` | `0.0000e+00` | `0.0000e+00` | `0.000000` | `9.89e-16` | `1.00000` | `1.0000` | `755.851` |
| radiation + baryons, fable8d | `6.2532e-03` | `6.5402e+08` | `6.5402e+08` | `−1.0000e+00` | `2.3096e-11` | `0.994782` | `1.04e-08` | `6.95831` | `2.4935` | `49.354` |

Radiation alone keeps `H_B = H_C = 0` exactly (`max |H_B/H_A| = 0.0e+00`: `F = 0`); dust or vacuum energy drives the
hidden sheet to the 7-dimensional isotropic attractor (`H_B/H_A -> 1`), and the observed Newton constant
changes by **`6.5e8` to `1.9e17`** between the start and today, with `|d ln G/dt|` today `2.3e-11` to `2.76e-10` /yr
against the lunar-laser-ranging bound `1e-13` /yr, and `DeltaG/G` since nucleosynthesis `−1` against the bound of
about `0.1`. The closure today then needs `Omega_sum(1) ≈ 7` (`Sum Omega_i = 1 + (3 H_B^2 + 9 H_A H_B + 3 H_A H_C + 3 H_B H_C)/(3 H_A^2)`,
which is 7 on the attractor). The two controls have nothing to shoot, so their `H_A` today is not 1 and their ages
are not those of our universe. **`fable8d` is a no-go for observers; that is why the physical model is the
stabilized `fable4d`.** The last run, `fable8d --freeze-hidden` (`lambda-mass 30 eV`), agrees with the algebraic
`fable4d`: `max |dH_A|/H_A = 4.1e-09, max |dt|/t = 9.8e-09, max |dw_f| = 0.0e+00, max |H_B| = 0.0e+00`.

#### 4.7.11 The cases the solver refuses, and why

Each exits with code 1 and one line of physical reason **[nb06 §5.9]**:

```
$ fable_fermion fable4d --potential lorentz --points 1001
  exit code 1: fable_fermion: rho_hat = H_A^2 <= 0 from N = -0.7597808064 (a = 0.4677689478) on: the Kohn-Sham ground state has negative energy there (m_eff = -3.802078e-2, sigma8 = -9.789374e-4, rho_f = -4.830421e-1 (U = -4.847891e-1) against rho_r + rho_b = 4.830421e-1); H_A^2 = rho_hat is impossible (the onset located past the last accepted CVODE step and bisected)
$ fable_fermion fable4d --potential quadratic --param gq=0.5 --points 1001
  exit code 1: fable_fermion: gap-branch jump at N = -0.0037262796 (a = 0.9962806544): a first-order transition of the Kohn-Sham ground state, the lowest-energy gap root jumps from the branch m_eff = -1.518260e0 (rho_f = 6.856759e-1) to the branch m_eff = 4.083552e2 (rho_f = 9.536521e-1); the right-hand side is discontinuous there, and energy conservation across it would need the Maxwell construction, which this solver does not implement (the transition detected inside the right-hand side and bisected in N to adjacent doubles)
$ fable_fermion fable8d --potential mass --direction backward
  exit code 1: fable_fermion: fable8d runs forward only (design review E4): backward in time the shear modes grow as A^-3 v^-1 relative to H_A ~ A^-2, the solution runs to the 8D Kasner point H_B/H_A = -0.2929 and the constraint drifts to O(1); use fable4d --direction backward
all three refused with exit code 1 and the expected reason
```

`lorentz`: the Kohn–Sham ground state moves to the negative-`sigma` branch, whose energy is negative (a well of
`W` on `sigma < 0` that the quantum gas reaches and the classical `s >= 0` field never did). Repulsive `quadratic`:
a first-order transition (section 4.6.1). `fable8d` backward: the constraint grows backward (section 4.3.4).
(These lines are the output of the committed notebook 06, executed on the final solver of `2bc936d`.
That commit detects both the negative-energy onset and the gap-branch jump inside the right-hand side, on
every internal CVODE step, and bisects them to adjacent doubles, independently of the output grid:
`lorentz` at `a = 0.4677689478` "whatever --points is", the repulsive-quadratic jump at
`a = 0.9962806544` "for any grid", with scipy agreeing to `8e-12` [commit 2bc936d]. The first execution
of the notebook, at 22:53 PDT on the solver before that commit, had bracketed the jump only between two
output rows and printed `gap-branch jump (sign of m_eff) between N = -0.027631021115929855 and N = 0:
m = -3.1667192351800344e-1 -> 4.060727073199006e2`; the `lorentz` line was the same then as now.)

#### 4.7.12 Three implementations, one answer: CVODE, scipy and Mathematica

**Part VIII's own solution.** Section 33 solves two `fable4d` cases in Mathematica, independently of the
reference script: every tenth row (71 of 701) by exact algebra from Section 29's closed forms (with
`FindRoot` for the gap), the age of `mass30eV` by `NIntegrate` between the rows, and the age of `power` by
`NDSolve` of the pair `(m(N), ln t(N))` with the **differentiated** gap equation
`dm/dN = −W''(sigma) (d sigma/d k_F) k_F / (1 − W''(sigma) d sigma/dm)` instead of solving it [prose VIII §33]. The run
printed [displayed VIII §33, `claude-fable/run_fermion_fable_part8.log`]:

```
  [0.242 s]  fable4d mass30eV: 71 rows by exact algebra, the age by NIntegrate between the rows
  [0.603 s]  fable4d power: NDSolve of (m(N), ln t(N)) with the differentiated gap equation
  [0.047 s]  fable4d power: 71 rows by exact algebra (FindRoot of the gap at every row)
  mass30eV: m0 = 30 eV = 12182.18122 E_c;  kF0 = 0.0544035545089 E_c = 0.00013397491 eV;  V0 = 0.6856647126;  a_nr = kF0/m0 = 4.46583e-6;  t0 = 0.951246513195 / H0
  power:    m_today = 100 eV;  kF0 = 0.0464558024014 E_c;  lam = 217.736704888;  m0 = 27.15187044 eV;  U_today = 0.4006647126;  w_f(1) = -0.421457436338;  t0 = 0.9218031611 / H0
  P_stab(a) [units of rho_c0] at a = 1e-10, 1e-6, 1e-3, 1:   mass30eV {-2.4626e28, -6.53147e16, -1.57121e8, -0.842786};   power {-2.46243e28, -4.87299e16, -9.93078e7, -0.700286}
```

and asserted **[proved VIII §33]**
`fable4d RUNS [THE RESULT]: mass30eV -- flat today (H_A(1) == 1), eps_KS(1) == 0.265, ultra-relativistic at the start (w_f(a_i) = 1/3 to 1e-8), non-relativistic at a_nr = kF0/m0 == 4.16e-4 (m/eV)^(-4/3) (1%), and w_f >= -1 at every row`,
`fable4d RUNS [THE RESULT]: power -- flat today, m_eff(1) == 100 eV, m0 == 27.15 eV > 0, m_eff INCREASES monotonically from m0 (early) to m_today, and w_f >= -1 at every row`,
`fable4d RUNS [has content]: the differentiated gap equation carries m(N) along the history -- NDSolve's m agrees with the per-row FindRoot to 1e-15 at all 71 rows`,
`fable4d RUNS [THE RESULT]: the stabilizer P_stab = -F_total/2 is NEGATIVE at every row of both runs -- the null-energy violation along x0 is present along the whole history`,
`fable4d RUNS [fidelity]: the reference CSVs have the expected header and 701 rows`,
`fable4d RUNS [fidelity]: at every tenth row ALL TEN columns agree with fable-cosmology/reference/mathematica_fable4d_mass30eV.csv and _power.csv to 1e-10 (relative; P_obs_f relative to rho_f; N and w_f absolute)`.
The comparison with the reference CSVs printed `max difference per column {0., 0., 0., 0., 0., 0., 0., 0., 0., 0.}`
for both files (three-digit formatting). When this log was recorded the Rust CSVs
`results/nb06_fable4d_mass30eV.csv` and `nb06_fable4d_power.csv` did not yet exist, and the conditional
comparison with them was skipped, not failed (`NOTE  Rust CSV not found; that comparison was skipped, not failed`);
notebook 06 now writes them, and the three-way comparison below includes them. The final run of the notebook (`claude-fable/run_fermion_fable_final.log`, commit `1671155`),
made after notebook 06 had written them, ran both comparisons and passed:
`Rust ...fable-cosmology\results\nb06_fable4d_mass30eV.csv: 71 rows compared; max difference per column {a, t, H_A, rho_f, P_obs_f, w_f, m_eff, sigma, kF_over_m}: {4.9e-14, 2.35e-9, 3.35e-11, 1.87e-13, 6.22e-15, 6.8e-15, 2.22e-15, 1.39e-13, 4.84e-14}`,
`PASS  fable4d RUNS [fidelity]: the Rust solver's mass30eV run agrees with this cell to 1e-6 in every column, at every one of the rows its grid covers`,
`Rust ...fable-cosmology\results\nb06_fable4d_power.csv: 71 rows compared; max difference per column {a, t, H_A, rho_f, P_obs_f, w_f, m_eff, sigma, kF_over_m}: {4.9e-14, 1.39e-9, 3.36e-11, 1.92e-13, 1.34e-14, 1.39e-14, 5.04e-14, 1.41e-13, 8.82e-14}`,
`PASS  fable4d RUNS [fidelity]: the Rust solver's power run agrees with this cell to 1e-6 in every column, at every one of the rows its grid covers`
(the absolute path before `fable-cosmology` shortened to `...`).

**The reference script** `fable-cosmology/reference/make_reference_fermion.wls` writes
`mathematica_fable4d_mass30eV.csv` and `mathematica_fable4d_power.csv`: 701 values of `N` from `ln 1e-10` to 0,
columns `N, a, t, H_A, rho_f, P_obs_f, w_f, m_eff, sigma, kF_over_m`; every row is exact algebra at 40
significant digits (the power-law gap by Brent's method at 45 digits), the age by `NDSolve` at working
precision 30 with the stable series of the Fermi-sea integrals for `k_F/|m| < 1/4` [file: its header].

**Three-way** **[nb06 §5.5, file `results/nb06_threeway.csv`]** — CVODE (Rust), scipy (the independent
implementation), and Mathematica (the reference CSVs), column by column, on both reference cases:

| case | Rust − Mathematica: `t` | `H_A` | `rho_f` | `P_obs_f` | `m_eff` | `sigma` | `kF/m` | `w_f` (abs) | scipy − Mathematica: `H_A` | `rho_f` | `P_obs_f` | `m_eff` | `t(A=1)` |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `nb06_fable4d_mass30eV` | `2.352e-09` | `3.338e-11` | `1.271e-14` | `1.603e-13` | `1.792e-15` | `9.938e-15` | `6.506e-15` | `3.608e-15` | `3.347e-11` | `1.419e-12` | `1.172e-12` | `2.986e-16` | `2.665e-14` |
| `nb06_fable4d_power` | `1.500e-09` | `3.353e-11` | `5.540e-14` | `6.990e-13` | `5.032e-14` | `5.242e-14` | `5.128e-14` | `8.160e-15` | `3.362e-11` | `1.362e-12` | `1.170e-12` | `4.586e-14` | `4.241e-14` |

`written: results/nb06_threeway.csv;  CVODE, scipy and Mathematica agree to better than 1e-6 on both reference
cases`; in the power case `m_eff` runs from `27.1519 eV (a = 1e-10) to 100.0000 eV (today)`.

**Every run re-computed independently** **[nb06 §5.10, file `results/nb06_crosscheck.csv`]**: the
independent implementation takes the normalized parameters from the `# params:` line of each CSV and
re-computes the run — every Fermi-sea integral by adaptive quadrature, every gap root by `brentq`, `fable8d` by
DOP853 at `rtol = 1e-11`, `fable4d` algebraically with `t(A = 1)` by adaptive quadrature — and checks the
Friedmann consistency of the solver's columns and the covariant conservation of the independently computed
fluid (Richardson-extrapolated central differences). The notebook fails if any difference exceeds `1e-6`. It
printed `largest difference over the 29 kept runs: 1.08e-08;  over the 90 scan runs: 4.43e-09;  largest
conservation residual of the independent fluid: 1.24e-07`.

#### 4.7.13 The consolidated table of every kept run

**[nb06 §5.11, files `results/nb06_runs.csv` (29 rows, 34 columns), `results/nb06_cpl_fits.csv`]**, verbatim:

```
run                                 m [eV]      a_nr dNeff BBN           CPL w_f      CPL w_DE,inf   min cs2 vac/rho a>=.3 G(a_i)/G(1) |Gdot/G| /yr
mass 1 eV (EdS)                          1  0.000637     36.75 (-0.000, +0.000) (+nan, +nan)  1.35e-07     0.000e+00   1.000e+00    0.000e+00
mass 30 eV (EdS)                        30  6.84e-06    0.3943 (-0.000, +0.000) (+nan, +nan)  1.56e-11     0.000e+00   1.000e+00    0.000e+00
mass 100 eV (EdS)                      100  1.37e-06   0.07918 (-0.000, +0.000) (+nan, +nan)  6.28e-13     0.000e+00   1.000e+00    0.000e+00
mass 1000 eV (EdS)                    1000  6.37e-08  0.003675 (-0.000, +0.000) (+nan, +nan)  1.35e-15     0.000e+00   1.000e+00    0.000e+00
mass 2000 eV (EdS)                    2000  2.53e-08  0.001459 (-0.000, +0.000) (+nan, +nan)  2.13e-16     0.000e+00   1.000e+00    0.000e+00
lambda-mass 30 eV                       30  4.47e-06   0.07179 (-0.757, +1.010) (-1.000, +0.000)  6.65e-12     0.000e+00   1.000e+00    0.000e+00
lambda-mass 100 eV                     100  8.97e-07   0.01442 (-0.757, +1.010) (-1.000, +0.000)  2.68e-13     0.000e+00   1.000e+00    0.000e+00
lambda-mass 1000 eV                   1000  4.16e-08 0.0006692 (-0.757, +1.010) (-1.000, +0.000)  5.78e-16     0.000e+00   1.000e+00    0.000e+00
lambda-mass 2000 eV                   2000  1.65e-08 0.0002656 (-0.757, +1.010) (-1.000, +0.000)   9.1e-17     0.000e+00   1.000e+00    0.000e+00
lambda-mass 30 eV (reference)           30  4.47e-06   0.07179 (-0.757, +1.009) (-1.000, +0.000)  6.65e-12     0.000e+00   1.000e+00    0.000e+00
power nu=0.236, 30 eV                   30  2.22e-05   0.07179 (-0.783, +0.445) (-0.082, -7.986)    -0.611     1.314e+13   1.000e+00    0.000e+00
power nu=0.236, 100 eV                 100  4.47e-06   0.01442 (-0.783, +0.445) (-0.082, -7.986)    -0.611     1.622e+15   1.000e+00    0.000e+00
power nu=0.5, 30 eV                     30     0.669   0.07179 (-0.804, -0.358) (-0.249, -10.191)       -27     2.229e+14   1.000e+00    0.000e+00
power nu=0.5, 100 eV                   100     0.669   0.01442 (-0.804, -0.359) (-0.249, -10.191)       -27     2.752e+16   1.000e+00    0.000e+00
expdamp xt=1/2.21, 30 eV                30     0.712   0.07179 (-0.829, -0.317) (-0.128, -11.778)     -21.8     2.327e+14   1.000e+00    0.000e+00
expdamp xt=1/2.21, 100 eV              100     0.712   0.01442 (-0.829, -0.317) (-0.128, -11.779)     -21.8     2.873e+16   1.000e+00    0.000e+00
quadratic gq=-0.5, 30 eV                30     0.643   0.07179 (-0.730, -0.483) (-0.180, -9.321)     -47.1     2.031e+14   1.000e+00    0.000e+00
quadratic gq=-0.5, 100 eV              100     0.643   0.01442 (-0.730, -0.483) (-0.180, -9.321)     -47.1     2.508e+16   1.000e+00    0.000e+00
power nu=0.5, 100 eV, Omega_qp0=0.55     100  4.21e-06   0.03817 (-0.448, +0.264) (-0.327, -9.682)    -0.364     2.350e+14   1.000e+00    0.000e+00
power nu=0.236, 1 eV (Delta N_eff)       1   0.00207     6.692 (-0.783, +0.445) (-0.082, -7.985)    -0.611     1.622e+07   1.000e+00    0.000e+00
power nu=0.5, 1 eV (Delta N_eff)         1      0.67     6.692 (-0.807, -0.347) (-0.251, -10.172)     -21.7     2.720e+08   1.000e+00    0.000e+00
expdamp xt=1/2.21, 1 eV (Delta N_eff)       1     0.712     6.692 (-0.832, -0.305) (-0.130, -11.753)     -21.7     2.850e+08   1.000e+00    0.000e+00
quadratic gq=-0.5, 1 eV (Delta N_eff)       1     0.643     6.692 (-0.732, -0.473) (-0.182, -9.306)     -46.4     2.490e+08   1.000e+00    0.000e+00
mass 1 eV, fable8d                       1   0.00124     521.5 (-0.000, +0.000) (+0.394, -8.104)  3.93e-07     0.000e+00   3.438e+10    2.757e-10
mass 100 eV, fable8d                   100  2.66e-06     1.124 (-0.000, +0.000) (+0.394, -8.104)  1.83e-12     0.000e+00   1.852e+17    2.757e-10
lambda-mass 30 eV, fable8d              30  4.47e-06   0.07179 (-1.103, +1.715) (-1.716, +5.459)  5.13e-12     0.000e+00   1.046e+12    2.757e-10
lambda-mass 1 keV, fable8d            1000  4.16e-08 0.0006692 (-1.103, +1.715) (-1.716, +5.459)  4.46e-16     0.000e+00   1.067e+12    2.757e-10
radiation only, fable8d                nan       nan         0 (+nan, +nan) (+nan, +nan)       nan     0.000e+00   1.000e+00    0.000e+00
radiation + baryons, fable8d           nan       nan         0 (+nan, +nan) (+0.386, -8.020)       nan     0.000e+00   6.540e+08    2.310e-11
```

(The `vac/rho` column is `0` for constant-mass runs, where the sea energy is a constant absorbed into `V0`.)

#### 4.7.14 The figures

All written by notebook 06 under `fable-cosmology/results/` (and those of notebook 05, which show the
fluid itself):

| figure | what it shows |
|---|---|
| `nb06_a_mass_wdm.png` | runs (a): the author's mass term, `w_DM = P_KS/eps_KS` (`= w_f` there) against `a`: the degenerate fable cools from 1/3 to 0 |
| `nb06_b_lambda_mass.png` | runs (b): `w_f` (solid) and `w_DM` (dotted); and `w_DE,inf + 1` on `0.3 <= a <= 1`: the inferred dark energy is a cosmological constant |
| `nb06_c_de_potentials.png` | runs (c): `w_f` (never below −1), the observer's `w_DE,inf` (clipped to `[−3, 1]`, poles and crossings marked), `m_eff/m_today`, and `c_s^2` (negative below the line) |
| `nb06_c_exchange_vacuum_stabilizer.png` | runs (c): `w_DM` and `w_DM,eff`, the exchange `Q`, the Dirac-sea energy relative to the total density, and `P_stab/rho` |
| `nb06_scan.png`, `nb06_scan_cpl.png` | the scans: per family, the smallest `m_eff/m_today` over `1e-3 <= a <= 0.3` and the smallest `c_s^2` (`a >= 1e-3`) against the scanned parameter; the CPL points `(w0, wa)` of `w_DE,inf` (fitted above its poles) and of `w_f` |
| `nb06_dm_mass_bounds.png` | the free streaming of a degenerate fable: `v_rms` today against the fable mass, with the warm-dark-matter velocities |
| `nb06_d_nogo_8d.png` | runs (d): `G_4(a)/G_4(today) = 1/v`, `H_B/H_A` and `H_C/H_A` (the approach to the 7-dimensional isotropic attractor), and the constraint residual `(S − 3 rho_hat)/(3 H_A^2)` |
| `nb05_w_ks.png`, `nb05_ks_accuracy.png`, `nb05_classical_vs_quantum.png`, `nb05_gap_roots.png`, `nb05_minimax.png`, `nb05_preuniverse_cooling.png`, `nb05_vacuum_energy.png` | the Kohn–Sham fluid: `w_KS(x)`, the accuracy of the stable forms, classical vs quantum `w`, the gap roots, the minimax and Walecka functionals, the cooling on the pre-universe, the Dirac-sea energy |

### 4.8 The answers to [1] and [2]

The author asked: **[1]** "Does this system provide a physical mechanism for a time-varying dark energy
equation of state (w)?" **[2]** "[...] time-varying dark matter equation of state (w)?" The answers below rest
on the runs of section 4.7 and the theorems of sections 4.2–4.5. Notebook 06 composes its own statement of the
answers from its tables and asserts every qualitative claim in it; its headlines read **[nb06 §7]**:
"**Formally yes, in the stabilized model, but in none of the runs is it a viable one.**" for [1], and
"**Yes, intrinsically, but for an allowed mass the variation is over long before recombination.**" for [2].

#### 4.8.1 Answer [1]: a time-varying dark-energy equation of state

**Yes, as a mechanism — in the stabilized model, and only with a mass-varying potential. None of the runs
is a viable cosmology, and the mechanism carries every one of the following caveats.**

**What the mechanism is.** In the Kohn–Sham ground state the fable's energy is `rho = rho_qp + rho_U`, and the
mean-field condensate `rho_U = W(sigma7) − sigma7 W'(sigma7)` has `P = −rho_U` along all seven spatial directions:
a vacuum energy. When `W` is not linear, `rho_U` changes as the density falls, the quasiparticle mass
`m_eff = W'(sigma7)` changes with it, and the two parts exchange energy at the rate `Q = sigma8 dm/dt`
(section 4.5.10). The dark energy that an observer infers therefore varies in time. For a massive power law
`W = m0 sigma + lam sigma^nu` it is, in closed form and confirmed by the runs to `1.2e-09`,
`w_DE,inf(a) = −(1 − nu)/(1 − nu a^(−3(1−nu)))`, with a pole at `a = nu^(1/(3(1−nu)))` (`0.5326` for `nu = 0.236`)
(section 4.7.7). The observer's CPL fits of the eight dark-energy runs of section 4.7.6 lie at distances from the
supernova fit `(w0, wa) = (−0.861, −0.60)` of `7.43` (`power nu = 0.236`: `(−0.082, −7.986)`) to `11.2`
(`expdamp`: `(−0.128, −11.778)`) [file: `fable-cosmology/results/nb06_cpl_fits.csv`], and the fits are not faithful,
because `w_DE,inf` has a pole inside `0.3 <= a <= 1` in all of them.

**What does not give it.** With the author's mass term alone there is no dark energy at all: the fable is a free
gas that closes the budget, an Einstein–de Sitter-like universe with `Omega_f0 = 0.95066` and `q0 = 0.50005`
(section 4.7.4). With a mass term plus a bare `V0` (`lambda-mass`), the observer infers **exactly a cosmological
constant**: CPL `(w0, wa) = (−1.000000, +1.3e-09)`, `(−1.000000, +5.3e-11)`, `(−1.000000, +1.2e-13)`,
`(−1.000000, +1.7e-14)` at 30, 100, 1000, 2000 eV — no time variation (section 4.7.5). `V0` is a bare cosmological
constant and is reported as such.

**The caveats, each quantified:**

1. **No true phantom — but an apparent phantom and phantom crossing in the observer's fit.** The fable's own
   equation of state never goes below `−1`: `rho + P_obs = w_F n/v >= 0` is an identity (section 4.5.9), and the
   smallest `w_f` over every run is `−0.9999987921`. The classical Part VI crossing of `−1` (at `V'(s*) = 0`,
   section 3.1.12.7) does **not** survive quantization. The **observer-inferred** dark energy, however, is phantom
   or crosses `−1` inside `0.3 <= a <= 1` in 9 of 9 runs of section 4.7.6 and in 90 of 90 scan points: subtracting
   cold dark matter with today's mass when the mass was different leaves `rho_DE + P_DE ≈ (m_eff(a) − m_today) n`,
   negative whenever `m_eff` grows (the mechanism of Das, Corasaniti and Khoury, Phys. Rev. D 73, 083509 (2006)),
   with no phantom field. For the massive power law the crossing lies in the last output interval before today
   (`a > 0.9727`), where the quasiparticles' kinetic energy, of relative size `(3/10)(k_F/m)^2`, finally exceeds
   `(m_today − m_eff(a)) n` **[nb06 §7]**.
2. **Mass-varying dark energy with massive dark matter needs a power law with `nu < 0.279`.** In the scans 28 of
   90 points keep the fable massive over `1e-3 <= a <= 0.3`, all of them power laws; every `quadratic` and
   `expdamp` point is a massless gas (radiation) until late times and supplies no dark matter at recombination.
   A power law stays massive exactly when its bare mass `m0` is positive, i.e. when `Omega_qp0/U_t > nu/(1 − nu)`;
   with the observed split `Omega_qp0 = 0.265` that is `nu < 0.2788` (section 4.7.8). The massive mass-varying
   example with a larger quasiparticle share (Part VIII's case: `power`, `nu = 0.5`, `m_today = 100 eV`,
   `Omega_qp0 = 0.55`, no bare Lambda) has `m_eff` rising from 27.15 eV to 100.00 eV, `w_f` today `−0.4215`,
   `q0 = −0.1010`, and matter today `Omega_qp0 + Omega_b0 = 0.599`, about twice the measured `Omega_m ≈ 0.315`
   (Planck 2018): it is massive because its dark matter outweighs its dark energy, which the observed universe
   does not allow **[nb06 §7]**.
3. **It is adiabatically unstable.** Every scan point that stays massive has `c_s^2 < 0` after `a = 1e-3`
   (smallest `c_s^2` between `−0.647` and `−0.056`), and so do all 9 runs of section 4.7.6 (`−0.611` for
   `nu = 0.236`, `−0.364` for Part VIII's case, down to `−47.1` for `quadratic`). This is the adiabatic instability
   of mass-varying fermions (as found by Afshordi, Zaldarriaga and Kohri for mass-varying neutrinos).
4. **The Dirac-sea vacuum energy demands a fine-tuning.** The renormalized sea energy that the no-sea functional
   drops changes, for a mass variation of order `m`, by `g m^4/(64 pi^2)`: `3.44`, `3.44e4`, `3.44e8`, `3.44e12`
   times `rho_c0` at `m = 0.01, 0.1, 1, 10 eV`, more than the critical density for `m > 7.341 meV` (section 4.5.11).
   Along every mass-varying run it changes by **`1.31e13` to `2.87e16` times the total density at `a >= 0.3`**
   (over the scans at least `3.79e9`) **[nb06 §7]**. The runs read `W` as the fully renormalized effective potential,
   which absorbs the sea energy only by fine-tuning the bare potential against it to that precision. The
   cosmological-constant problem is not solved.
5. **It needs the stabilizer, which violates the null energy condition.** All of this holds with the hidden sheet
   held by `P_stab = −F/2` (today `−0.8428 rho_c0` in the ΛCDM-like runs, `−0.7003` in Part VIII's power case), a
   Lagrange multiplier, not a stress derived from any field, with zero energy density; it violates the null
   energy condition along `x0` on 100.0 % of the output rows of every stabilized run (section 4.7.1).
6. **Without the stabilizer it is excluded (the `fable8d` no-go).** Left free, the hidden sheet is driven by dust
   and vacuum energy to the 7-dimensional isotropic attractor, and the observed Newton constant
   `G_4 = G_8/V_hid` varies: `G(a_i)/G(1)` = `3.44e10`, `1.85e17`, `1.05e12`, `1.07e12` in the four fable runs and
   `6.54e8` for radiation plus baryons alone; `DeltaG/G` since nucleosynthesis is `−1` (against about `0.1`), and
   `|d ln G/dt|` today `>= 2.31e-11 /yr` (against the lunar-laser-ranging bound `1e-13 /yr`) (section 4.7.10). The
   only frozen-compatible Kohn–Sham fable is radiation (section 4.5.7).
7. **The split into dark matter and dark energy is a convention.** The condensate `rho_U` is an 8-dimensional
   vacuum energy, with `P = −rho_U` along the hidden directions as well; calling it dark energy and the
   quasiparticles dark matter is a choice of bookkeeping (section 4.5.4).
8. **The approximations under which all of this holds:** semiclassical gravity (`G = kappa <That>`); the
   Kohn–Sham mean field with exchange–correlation neglected (section 4.5.12); zero modes along `x0` and the
   hidden timelike sheet, with `x0` compactified (a Kaluza–Klein gap above the temperatures considered) and the
   hidden timelike sheet a formal comoving volume (compactifying it gives closed timelike curves); the
   asymptotic Bianchi-I reading of the primordial field, which neglects terms of order `Cot[6 H x0]` and
   `Cot[6 H x0]^2` (section 4.3.3); `g_*(T)` not followed.

#### 4.8.2 Answer [2]: a time-varying dark-matter equation of state

**Yes, intrinsically: the quantized fable's dark-matter equation of state runs from 1/3 to 0. For an allowed
mass the variation is over long before recombination.**

1. **The mechanism.** The fable's quasiparticles are a degenerate Fermi gas (`g = 8` states per momentum), and
   their equation of state is `w_DM = P_KS/eps_KS`, a function of `x = k_F/|m|` alone that rises monotonically
   from 0 (dust) to 1/3 (radiation) (section 4.1.6). As the universe expands, `k_F = k_F0/a` falls, and `w_DM`
   falls from 1/3 to 0: **a time-varying dark-matter equation of state**, which is a property of the quantum
   gas and has no counterpart in the classical Part VI fable (whose `w` was frozen on the pre-universe and 0 for
   the mass term). Every run starts at `w_DM = 0.333333` and ends today at most `8.1e-08` **[nb06 §7]**; the
   transition is at `a_nr = k_F0/m`, `4.466e-06` for 30 eV and `4.163e-08` for 1 keV, scaling as
   `m^(−4/3)` (sections 4.7.4–4.7.5). The same cooling happens on the pre-universe itself, on the canonical frame
   with `a4` free, whenever the observed sheet expands (`a4' < 0`, section 4.1.6).
2. **How heavy it must be, and hence when the variation happens.** A fable that is all of the dark matter is
   radiation before `a_nr`: `DeltaN_eff(BBN) = 6.692 (m/eV)^(−4/3) < 0.3` requires `m > 10.3 eV` (`< 0.2`:
   `m > 13.9 eV`). Free streaming is far more restrictive: matching the rms velocity of the Lyman-alpha-allowed
   thermal warm dark matter requires `m ≈ 1125–1807 eV` (`~1.1–1.8 keV`, a velocity-matching estimate, not a
   transfer-function computation), and the Tremaine–Gunn phase-space bound for illustrative dwarf spheroidals
   gives `m > 231–358 eV` (section 4.7.9). At such masses the change of `w_DM` from 1/3 to 0 happens around
   `a_nr = 4.16e-08` (1 keV) or `1.65e-08` (2 keV): **indistinguishable from cold dark matter in the late
   universe**.
3. **With a mass-varying potential the effective equation of state varies late.** The quasiparticles then
   exchange energy with the condensate (`Q = sigma8 dm/dt`), and their effective equation of state
   `w_DM,eff = w_DM − sigma_KS (dm/dN)/(3 eps_KS)` ranges, after `a = 1e-3`, over `[−0.611, +9.85e-05]`
   (`power nu = 0.236`, 30 eV), `[−0.611, +3.59e-06]` (100 eV), `[−27.6, +0.333]` and `[−27.7, +0.333]`
   (`power nu = 0.5`), `[−21.8, +0.333]` (`expdamp`), `[−47.1, +0.333]` (`quadratic`), and `[−0.364, −3.89e-05]`
   (Part VIII's case) (section 4.7.6). This late variation is the same exchange that makes the inferred dark energy
   vary in [1], and it carries all of [1]'s caveats (adiabatic instability, the sea energy, the viability window
   `nu < 0.2788`).
4. **The author's mass term alone is dark matter without dark energy.** `W = m0 sigma` gives an Einstein–de
   Sitter-like universe (`q0 = +0.50005`, age `9.67 Gyr` with `H0 = 67.4` km/s/Mpc), not ours; with a bare
   cosmological constant (`lambda-mass`) it is ΛCDM with fable dark matter (`q0 = −0.52845`, age `13.8000 Gyr`)
   (sections 4.7.4–4.7.5).
5. **The same caveats as [1]** apply: the stabilized model with its NEC-violating stabilizer (without it the
   Newton constant varies by `6.5e8` to `1.9e17`); the split into dark matter and dark energy is a convention;
   semiclassical gravity, the Kohn–Sham mean field with `E_xc` neglected (exact for the author's mass term, which
   is free), zero modes along the hidden directions, the asymptotic reading of the primordial field.

## 5. The design review: four lenses, four skeptics, every finding, and every correction

Nothing of Efforts A and B was implemented before its design had been attacked. This section records
the attack: how it was organized, every finding with its severity and its verdict, what was adopted,
the sub-claims of the reviewers that the skeptics refuted, the points the skeptics found that the
reviewers had missed, and the corrections that were found only later, by the implementation and the
checks. Each adopted correction is named with the section of this page where its content now stands.

### 5.1 How the review was organized

**The design (revision 1)**, written on 2026-09-24 before any code, fixed the conventions of the
notebook (never to be changed), recorded six facts already computed by probes (F1 the Clifford
symmetry table; F2 the Grassmann consequences; F3 the Einstein tensor of the canonical metric, which
is not a vacuum solution; F4 the generalized warped frame and its (0,4) equation; F5 the 8-dimensional
Bianchi-I system; F6 the quantization algebra: `G = −i sigma16 gamma^4`, signature (8,8), `J`, the
plane-wave spectrum), stated the physics of Efforts A (A.1 refinement, A.2 Lagrangian, A.3 field
equations, A.4 quantization, A.5 EMT, A.6 expectation values, A.7 spin connection) and B (B.1–B.6: the
semiclassical system, the canonical ansatz, the present-universe models, the DFT states, the spin
connection of the dynamical frames, the answers), gave the implementation plan, and asked the reviewers
eight questions to try to break:

| | question |
|---|---|
| Q1 | Is the Dirac-bracket anticommutator (factor, sign, `H/Sqrt[g]`, `−i sigma16 gamma^4`) right, including for the symmetrized Lagrangian and on the curved slice? |
| Q2 | Is the Krein/`J` quantization legitimate (Hermiticity of the interacting `H` under the `J`-involution; what exactly is lost; does `J` commute with every term of the admissible-sector Hamiltonian, the spin connection included)? |
| Q3 | Is the impossibility of a Majorana mass / scalar bilinear right for every candidate bilinear, and is "fermion fable must be complex" stated with the right scope? |
| Q4 | The EMT operator: sign and normalization against Part VI; symmetrization; the spin-connection-variation argument; conservation with independent `Psi`, `Psibar`. |
| Q5 | Kohn–Sham thermodynamics: the closed forms, `g = 8`, the classical limit, the no-sea statement, the mass-term conclusions. |
| Q6 | The 8D Einstein equations: F3–F5, the frozen-hidden theorem and its corollary, the conservation law, the units (`kappa_8` against `kappa_4`), the Bianchi-I claim, the negative background energy. |
| Q7 | DFT: the functional `E_n[sigma]` on `(−n, n)`, uniqueness, the ΔSCF / wall-state construction, the MIT condition in this real-Clifford convention, whether the wall problem is well posed and bound states exist, whether `expdamp` pins `sigma <= s1`. |
| Q8 | Cosmology: are the runs meaningful (`Omega` values, time interval, shooting), the definitions of `w_DE,eff` and `w_DM`, adiabatic instability, the bounds on `G`; are answers [1] and [2] honest? |

**The four lenses.** Each reviewer ran its own probes on the notebook's own state (the Input cells
loaded headlessly, or the notebook's `T16` and `sigma16` exported to Python) and wrote findings, each
with an ID, a severity (critical, major, minor), a kind (wrong, incomplete, ill-posed, hidden
assumption, implementation risk, better formulation), the statement and a proposed fix:

| lens | covers | findings |
|---|---|---|
| quantization: canonical quantization in 4+4 signature, Grassmann and Majorana algebra, Krein spaces | F1, F2, F6; A.1, A.2, A.4; Q1–Q3 | `QK-1` … `QK-11` |
| field equations, energy–momentum tensor operator, canonical spin connection | A.2, A.3, A.5, A.7, B.5; Q4 | `EMT-1` … `EMT-11` |
| the 8D Einstein equations with fable as source, and the cosmological runs | F3, F4, F5; B.1, B.2, B.3, B.6; Q6, Q8 | `E1` … `E12` |
| density-functional theory and the numerics | A.6, B.3 sources, B.4; Q5, Q7; the Rust and Python plan | `DFT-1` … `DFT-16` |

**The four skeptics.** Each lens was followed by an independent skeptic, who received the findings
and tried to **refute** each one with computations of its own (its own Riemann-tensor and
spin-connection code, its own Python on the exported matrices, its own numerical runs), and returned
a verdict per finding — *confirmed*, *partly confirmed* or *refuted* — with a corrected fix wherever
it disagreed, and a list of what the reviewer had **missed**.

**The outcome.** 50 findings: **30 confirmed, 20 partly confirmed, 0 refuted.** Where a finding was
only partly confirmed, the skeptic's corrected fix was adopted. All adopted corrections were written
into an addendum to the design (revision 2), which overrides revision 1 wherever they differ, and
then implemented. The DFT skeptic's final verdicts came last and override the addendum where they
differ.

| lens | confirmed | partly confirmed | refuted |
|---|---|---|---|
| quantization (`QK`) | 3 (`QK-2`, `QK-7`, `QK-8`) | 8 (`QK-1`, `3`, `4`, `5`, `6`, `9`, `10`, `11`) | 0 |
| field equations / EMT / spin connection (`EMT`) | 9 (`EMT-1`, `3`–`10`) | 2 (`EMT-2`, `EMT-11`) | 0 |
| Einstein / cosmology (`E`) | 6 (`E2`, `E4`, `E6`, `E8`, `E10`, `E11`) | 6 (`E1`, `E3`, `E5`, `E7`, `E9`, `E12`) | 0 |
| DFT / numerics (`DFT`) | 12 (`DFT-1`–`3`, `5`, `9`–`16`) | 4 (`DFT-4`, `6`, `7`, `8`) | 0 |

### 5.2 The quantization lens (`QK`)

| ID | severity, kind | the finding | verdict and the skeptic's correction | adopted, and where it stands now |
|---|---|---|---|---|
| QK-1 | major, wrong | The admissibility argument had the wrong mechanism: the free theory below threshold can be quantized with a momentum-dependent `J_k`; the real obstruction is **locality** — one momentum-independent `J'` must commute with `beta = −i T16[4]` and every one-particle generator `E_k = G h_k`; no positive `J'` exists once a hidden momentum is present; at threshold `E_k` is nilpotent (Jordan blocks); above it the modes are `G`-neutral. | **Partly confirmed.** Computed with the notebook's matrices: the boosted `J' = S^-1 J S` works for one mixed momentum (`[J', E] = 1e-15`, `G J'` positive, minimum eigenvalue 0.655); the theorem is about the **span** `V` of the mode momenta: positive quantization iff `V` is spacelike-definite; `J'` unique (with `J'^2 = 1`) when `V = span(x0..x3)`. The reviewer's above-threshold frequencies `±1.705872 i` were wrong: for `k = (0, .75, 1, 0 \| k5 = 2)`, `m = 1` they are `±1.19896 i`. Below threshold the free field is quantizable mode by mode but not uniformly: `cond(G J_k) = (m + k5)/(m − k5)` = 3, 19, 199, 1999 at `k5 = .5, .9, .99, .999`. | The theorem as corrected, with its proof ingredients as assertions (`[E_k, beta] = 2 i T_k`, the `T5` anti-congruence, the traceless certificate, the positive boosted `J'`, the rank-8 Jordan block with `E^2 = 0`): section 3.5.10 (`ADMISSIBILITY`). |
| QK-2 | major, ill-posed | "Physical states obey `P5 = P6 = P7 = 0`" is not a superselection rule: pairs `(k_h, −k_h)` have `P_h = 0`, and `V(s)` contains `b^dag_{k_h} b^dag_{−k_h} b_0 b_0`; the admissible theory is a **truncation** needing a finite hidden volume. | **Confirmed** (derivation; normalization by projection gives `(H/(V_hid Sqrt[g])) G delta^4`). `V_hid` is a coordinate volume; the truncated theory is a (4,1)-dimensional theory whose Cauchy surface is `x0..x3`. | The truncation `Psi = Psi(x0..x4)` with finite `V_hid` (closed timelike curves stated); the anticommutator `(H/(V_hid Sqrt[\|g\|])) G delta^4`; the Tomonaga–Schwinger remark kept only as `[P_4, P_h] = 0`: sections 3.5.1, 3.5.4. |
| QK-3 | major, incomplete | Under the `J`-involution, `Psi^ddag M Psi` is Hermitian iff `[J, M] = 0` and anti-Hermitian iff `{J, M} = 0`; `That_{mu h}`, `That_{hh'}` and `j^h` are anti-Hermitian. | **Partly confirmed. Refuted sub-claim:** `That_{hh'}` (`h ≠ h'`) is **not** anti-Hermitian — its connection pieces commute with `J`, and for `x5..x7`-independent `Psi` it vanishes identically on all three frames. The mixed `That_{mu h}` are nonzero and anti-Hermitian; an anti-Hermitian operator has a purely imaginary expectation in every state, so `G_{mu h} = kappa <That_{mu h}>` is consistent only where the expectation is 0, which hidden-SO(3) invariance ensures. | The Hermiticity table with `That_{hh'} ≡ 0`, `That_{hh} = g_hh Lhat`, anti-Hermitian `That_{mu h}` and `j^h` with zero expectation in hidden-SO(3)-invariant states: sections 3.5.8, 3.6.5. |
| QK-4 | major, implementation risk | Part V/VI's "`Lhat` with `D` = `Lhat` with `d`" holds only for real commuting `Psi`; for Grassmann fields the unsymmetrized connection term `−3H Cot^2 Psi^ddag sigma16 T16[0] Psi` is nonzero and anti-Hermitian, and the unsymmetrized partial-derivative Lagrangian gives inconsistent equations. | **Partly confirmed. Overstated part:** "never assert covariant = partial" is too strong — for the **symmetrized** Lagrangian `Lhat_sym(D) − Lhat_sym(d) = (1/(2H)) Psibar Sum {gamma^mu, Gamma_mu} Psi`, which is identically 0 on the canonical, warped and Bianchi-I frames, so the identity holds there in symmetrized form. F2(a) (no dynamics for a real Grassmann field) holds on **every** frame. | Only the symmetrized Lagrangian; the four facts (a)–(f) as assertions: section 3.3 (`LAGRANGIAN (a)–(f)`), 3.2.3. |
| QK-5 | major, better formulation | `J` has concrete content: `sigma16 = J beta`, `J = −i Omega T16[0]`; with `Psi^dagger := Psi^ddag J` the author's conjugate is the observer's Dirac adjoint; fable is four 4D Dirac flavours with a flavour metric of signature (2,2) replaced by 1; legitimate for fermions, not for bosons. | **Partly confirmed.** Not verified: "J gives reflection positivity" — dropped. The bosonic mechanism is not "a ghost": for a commuting field `H` has 8 negative-frequency modes per `k` and is unbounded below; making it bounded below turns 4 modes into negative-norm modes. The `J` *-structure differs from the classical reality structure on `J`-odd observables, so the classical theory is the limit of the `J`-even sector only. **Missed point:** the prescription `b_u^dagger := eta_u b_u^ddag` is basis-dependent (a Krein boost inside a (4,4) eigenspace gives `\|\|J_k − J\|\| = 4.45` and a non-Hermitian `s`); the adjoint must be `Psi^ddag J`, mode-independent. | Sections 3.5.5, 3.5.6, 3.5.13 (`J`, `KREIN MODES [control]`); two symbols for the classical conjugation and the Hilbert adjoint. |
| QK-6 | minor, wrong | The symmetry count: the group commuting with `J` is Spin(4,1)×Spin(3) (13 generators); the 15 lost are 12 boosts and 3 **rotations** (the design had called them boosts); chirality `T16[8]` is lost; `p = Psibar T16[8] Psi` is anti-Hermitian; `G` is Spin(4,3)-invariant (21). | **Partly confirmed. Misleading sub-claim:** the chirality subspaces **are** orthogonal in the Hilbert product (`T16[8]` is Hermitian); what is true is that `J` is chirality-odd, so each chirality subspace is `G`-null and the `J`-vacuum is not chirality-graded. `i p` is `J`-Hermitian but classically imaginary, so `V` depends on `s` only. | Section 3.5.9, 3.5.7. |
| QK-7 | minor, incomplete | The four candidate matrices are only two (`Cplus T8 = sigma16`); the invariant forms are `span{sigma16, sigma16 T8}`, both symmetric and chirality-diagonal; Majorana has one quartic scalar and a non-dynamical commuting shadow; complex Weyl spinors do not propagate either; the complex spinor has two scalar bilinears and 6 quartic invariants. | **Confirmed** (full rank table `S\|S, A\|S, A\|A, S\|A, S\|S, A\|S, A\|A, S\|A, S\|S` for ranks 0–8; invariant forms of dimension 2; 0 singlets in `Lambda^2(16)`). | "The minimal, not the unique, field": sections 3.2.1–3.2.8 (`REFINEMENT (a)`, `(b)`). |
| QK-8 | minor, hidden assumption | When `Sqrt[g]` depends on `x4`, `Psi` is not a canonical Heisenberg field; quantize `chi = (Sqrt[\|g\|]/H)^(1/2) Psi`. | **Confirmed.** | Section 3.5.16; on the dynamical frames, section 4.4.6. |
| QK-9 | minor, hidden assumption | Hermiticity needs a `J`-compatible boundary condition in `x0`: the bag condition `T16[0] Psi = ±Psi`. | **Partly confirmed. Overstated:** "vanishes at both ends" — the wall is at finite proper distance (`z ≈ 3H x0^2`), the operator is **regular** there and needs a condition; at `z -> infinity` it is limit-point and none can be imposed. | One-particle space `L^2(dz)`; the condition at the wall only: section 3.5.12. |
| QK-10 | minor, wrong | `j^mu = i Psibar gamma^mu Psi` has the wrong sign and normalization to be the number current. | **Partly confirmed:** the calculation is right, "wrong" is overstated — `j^mu` is a legitimate conserved current that needs its normalization stated. | `n^mu := −(i/H) Psibar gamma^mu Psi`, `n^4 = Psi^dagger Psi/H >= 0`; a positive-frequency `J`-mode carries `j`-charge −1: section 3.4.10. |
| QK-11 | minor, better formulation | `V(s)` needs no Weyl ordering in the Hamiltonian (spectral calculus of one Hermitian operator); the ordering appears only in the Heisenberg equation, as an insertion average. | **Partly confirmed:** the design's Weyl-symmetrized product is already identical to the insertion average (Fock check to `1.1e-16`); the real addition is that `V(:s:)` needs no ordering. | Section 3.4.9. |

What the quantization lens confirmed as right (11 items): the full Clifford symmetry table; the
invariant forms; `G = −i sigma16 gamma^4 = J` Hermitian with `J^2 = 1` and signature (8,8); the
eightfold `±omega` modes for admissible momenta; `omega^2 = k_s^2 − k_h^2 + m^2`; the `J`
commutation relations; `Gamma_mu` real with `sigma16 Gamma_mu` antisymmetric; the real commuting
shadow equals Part VI's `cfLhatFable`; the commutant `M4(C)` (four flavours); the Hermiticity of
`H_free + lam s^2`; the rescaling `Sqrt|g| = Sec[6Hx0]`.

### 5.3 The field-equation, energy–momentum-tensor and spin-connection lens (`EMT`)

| ID | severity, kind | the finding | verdict and the skeptic's correction | adopted, and where it stands now |
|---|---|---|---|---|
| EMT-1 | major, implementation risk | The design gave the wrong reason for the covariant derivative in `T_{mu nu}`: varying a partial-derivative Lagrangian gives `T_par`, not conserved, differing from `T_cov` in 21 off-diagonal components; the spin-connection variation is **identically zero** (`delta omega_[cab] = 0` for symmetric tetrad variations). | **Confirmed** (own first-order symmetric tetrad perturbation, all 36 functions generic). Addition: on the canonical frame `T_cov = T_par` on the diagonal **and** on `(0,4)`; `(5,6)` vanishes identically; the control needs a non-vacuous pair such as `(1,4)`, `(0,1)`, `(1,5)`, `(5,4)`, `(0,5)`. Do not run the symbolic divergence of `T_par` (it ran more than 9 minutes). | Hilbert = `T_cov` off shell, the variation piece zero, Hilbert ≠ `T_par` at a non-vacuous pair: sections 3.6.1, 3.8.12.5 (`EMT`). |
| EMT-2 | major, wrong | "The connection commutes with `J`" holds only for `gamma^mu Gamma_mu` and `Gamma_0..Gamma_4`; `Gamma_5, Gamma_6, Gamma_7` **anticommute** with `J`. | **Partly confirmed. Part of the finding wrong:** in any Hamiltonian `Gamma_h` enters only as `sigma16 gamma^h Gamma_h`, and `[J, gamma^h Gamma_h] = 0` for **each** `h` separately; the `J`-odd objects are the bare `Gamma_h` in `T_cov` `(0,h)`, `(i,h)`, `(4,h)` and the hidden momenta. The expectation argument is right and needs `J`-eigenmodes. | The full `J` table, per `mu`: sections 3.5.8, 3.8.12.6, 4.4.7 (`J TABLE`). |
| EMT-3 | minor, wrong | "On shell `Lhat = sV' − V` (bilinear part vanishes)" is false: the kinetic bilinear equals `s V'(s)`. | **Confirmed.** | Section 3.6.4. |
| EMT-4 | minor, incomplete | The on-shell components were missing: trace `7 sV' − 8V`; `rho = V + K_h`; `T^i_i = T^h_h = sV' − V`; `T^0_0 = sV' − V + K_h`; `K_h` symmetrized, 0 on the rescaled `x4`-only solutions. | **Confirmed.** Caveats added: calling `T^h_h` a pressure along the hidden **timelike** directions is a naming convention; `K_h = 0` holds on the `x4`-only family, which solves the equation only if `V'' s' = 0`. | Section 3.6.4 (`EMT ON SHELL`). |
| EMT-5 | minor, hidden assumption | Part VI's drop-out mechanism does not carry over to complex fields; in the symmetrized Lagrangian the connection drops iff the **matrix** `{gamma^mu, Gamma_mu} = (1/2) omega_[cab] gamma^{cab}` vanishes. | **Confirmed.** | Sections 3.3.3, 3.8.12.2. |
| EMT-6 | minor, better formulation | With the symmetrized Lagrangian the Hamiltonian density contains **no** connection; it re-emerges in the equation of motion as `gamma^mu Gamma_mu = (1/2)(1/Sqrt[g]) d_mu(Sqrt[g] gamma^mu)`. | **Confirmed.** Addition: the unsymmetrized and symmetrized integrated Hamiltonians differ only by the surface term `(1/2H)[Csc(6Hx0) Psibar T16[0] Psi]` at the wall, which vanishes exactly when the wall condition kills the normal current. | Sections 3.5.11, 3.8.12.4. |
| EMT-7 | minor, incomplete | On the dynamical frames `Gamma_0 ≠ 0` when `C' ≠ 0`; the complete non-zero `omega` lists must be asserted. | **Confirmed** (own routine reproduces `GammaSpinCanonical`; the warped and Bianchi-I lists; `Gamma_4 = 0`). | Section 4.4.2 (the complete lists). |
| EMT-8 | minor, hidden assumption | The commuting-placeholder conservation proof holds for Grassmann fields only because the on-shell divergence is linear in `Psibar`-left bilinears with coefficients that are functions of the **even** composites `s` and `d s`. | **Confirmed** (derivation checked step by step). | Section 3.6.3. |
| EMT-9 | minor, better formulation | The exact 8+8 form with its conjugate rows; `s` is chirality-diagonal, so the axial phase leaves `V(s)` invariant but **not** the kinetic term: the only U(1) is the vector one. | **Confirmed** (the internal-symmetry Lie algebra is 1-dimensional). | Sections 3.4.3, 3.4.6, 3.4.11 (`SYMMETRY`). |
| EMT-10 | minor, better formulation | The rescaling theorem in frame-independent form: `gamma^mu Gamma_mu = −(1/2) T_mu gamma^mu`, `T_mu` the Weitzenböck torsion vector; on the warped frame `Psi = Sqrt[Sin](A^3 B^3 C)^(-1/2) chi` and `{chi, chi^dagger} = H Cot[6Hx0] G delta^7`, independent of `x4`. | **Confirmed.** Wording: the `chi` anticommutator is `x4`-independent and the dilution is carried by the prefactor; the `chi` dynamics stay time-dependent through the frame. | Sections 3.8.12.3, 4.4.5, 4.4.6. |
| EMT-11 | minor, hidden assumption | For nonlinear `V` the operator equation is `gamma D Psi = H :V'(s) Psi:`, differing from the naive product by Hartree/Fock contractions. | **Partly confirmed. Imprecise:** the contraction terms are not all c-number multiples of `Psi`; the J-vacuum sea matrix has a scalar part (divergent, renormalizes `V'`) and a `gamma^4` part (the sea charge, a constant chemical-potential shift, removed by charge-symmetric ordering or a phase, **not** by renormalizing `V`). | Section 3.4.9. |

What the skeptic of this lens found **missed**: the `x4`-only family `Psi = Sqrt[Sin] Psi'(x4)` solves
the field equation only if `V'' s' = 0` (for the complex field `s'` is conserved, so null data
`s' = 0` give `x4`-only solutions for **any** `V`, with `rho = V(0)`) — section 3.4.8; normal ordering on
an `x4`-dependent background is ambiguous, and "`<:T:> = 0` in the vacuum" holds only for static
backgrounds or adiabatically — section 3.7.3; the witness pairs for `T_cov` against `T_par` are
frame-specific; and the per-`mu` identity `{gamma^mu, Gamma_mu} = 0` (not only the sum) is what gives
the individual pressures — section 3.6.4.

### 5.4 The Einstein and cosmology lens (`E`)

| ID | severity, kind | the finding | verdict and the skeptic's correction | adopted, and where it stands now |
|---|---|---|---|---|
| E1 | major, wrong | `W = m0 sigma + (lam/2) sigma^2` is **not** frozen-hidden-compatible; the condition holds only for `W = c sigma^2`, and then the gap is nonzero only while `lam g kF^2/(4 pi^2 v) > 1`. The reviewer wrote the driver as `F = sigma W' − 2W`. | **Partly confirmed. Sign corrected:** at self-consistency `F = rho − 3P_obs + 2P_hid = 2W − sigma W'` (the reviewer's own number, `F = +m0 sigma`, agrees with this sign); with `V0`, `F = 2V0 + m0 sigma + ...`. Stronger than stated: the nontrivial root is **never** the ground state (at `kF = 1, 0.6, 0.41`: `rho = 0.2837, 0.01632, 0.0028633` against the massless `0.1013, 0.01313, 0.0028631`; roots `m = 3.9785, 1.9816, 0.7479, 0.3468` at `kF = 1, 0.8, 0.6, 0.5`, none at 0.40, `kF_c = 0.40558`). | A frozen-compatible fable is radiation: sections 4.5.6, 4.5.7 (`FROZEN`). |
| E2 | critical, implementation risk | The Kohn–Sham densities are per observed 3-volume; the 8D source must be per 7-volume (`sigma7 = sigma_KS/v`, gap `m = W'(sigma7)`), otherwise conservation fails; `d rho = wF dn` holds only at fixed `v`. | **Confirmed** (conservation residual `−2.5e-11` per 7-volume against `5.4e-3` per 3-volume). | Per-7-volume everywhere, a unit test that the per-3 version fails: sections 4.5.1, 4.5.5, 6.4.2 (`per_3_volume_mean_field_violates_8d_conservation`). |
| E3 | critical, incomplete | In `fable8d` the variation of `G` is catastrophic (12 orders of magnitude); any 8D vacuum energy and any dust drive the hidden sheet; a bare 8D `Lambda` is not a 4D cosmological constant. Make `fable4d` (with a zero-energy stabilizer) the physical model. | **Partly confirmed.** The 7D-isotropic attractor is **not universal**: with baryons plus a frozen-compatible vacuum (`P_hid = −2 rho`, which must obey `rho' = (3H_B + H_C) rho`) the sheet re-freezes, `Gdot/G ≈ 1.5e-14 /yr` (within lunar laser ranging) while `DeltaG/G` since BBN still fails. The stabilizer `P_stab = −F_total/2` violates the null energy condition along `x0` whenever dust is present (`rho + P_C = −rho_dust/2`): a Lagrange multiplier, not a derived stress. | `fable4d` as the physical model, `fable8d` as the no-go, `P_stab` printed on every run: sections 4.7.1, 4.7.10. |
| E4 | major, ill-posed | The backward `fable8d` run from today is neither anchored nor stable (runs to the 8D Kasner point, the constraint drifts). | **Confirmed** (`H_B/H_A -> −0.2929 = −(1 − 1/Sqrt[2])`; constraint residual `−3.7e5` at `a = 1e-8` with LSODA). | The solver refuses it (section 4.7.11). |
| E5 | major, better formulation | Replace the circular x0-mismatch no-go by three splitting-free theorems: (a) energy, (b) anisotropy, (c) momentum. | **Partly confirmed.** (b) as stated ("`a4'' = 0` for any fable state") holds only for c-number configurations; the Kohn–Sham gas has `P_obs − P_hid = P_KS/v > 0` and allows `a4'' < 0`. | (a), (c) as theorems; (b) as `a4'' = −kappa (P_obs − P_hid)/(2H^2)`: sections 4.2.4–4.2.7. |
| E6 | major, hidden assumption | F4 "derives" the volume-preserving `a4` structure only under `C = 1`, `T^4_0 = 0` and separability; with `C` dynamical, `H_C = (H_A + H_B)/2` and positive-energy expansion is allowed. | **Confirmed.** | "Singled out, not derived": section 4.3.2. |
| E7 | minor, incomplete | The decay rates per component; the asymptotic background values; the validity condition; the ghost stiff fluid. The reviewer gave the residual driver as `F_bg = −132 H^2 Cot^2/(kappa C^2)`. | **Partly confirmed. `F_bg = −132` is wrong** (it assumed `P_C = P_hid`); the correct drivers are `kappa (P_i − T/6)\|bg = −12 H^2 Cot^2/C^2` for `A`, `B` and `−72 H^2 Cot^2/C^2` for `C`, and only if `T_bg` is not included as a source. | Section 4.3.3, 4.2.8. |
| E8 | major, hidden assumption | `kappa_4 = kappa_8/V_h` needs a finite hidden volume: `x0` has infinite proper length and compact timelike `x5..x7` give closed timelike curves; zero modes along `x0` need a Kaluza–Klein gap; `Sum Omega ≠ 1` in `fable8d`. | **Confirmed.** | The assumptions stated: sections 4.7.1, 4.7.2. |
| E9 | major, ill-posed | The shooting was misposed (two conditions, one unknown in `fable8d`; uniqueness needs monotonicity; a branch jump breaks conservation); `W = m0 sigma` forces Einstein–de Sitter. | **Partly confirmed.** "Hot or warm below about 20 eV" had no criterion (use `a_nr < a_eq` for not hot, `a_nr < 1e-6` for cold-like). **Missed simplification:** `fable4d` is algebraic in `a`, so the shooting is one root-find and `t(a)` a quadrature — an exact cross-check. | Sections 4.7.1, 4.7.4. |
| E10 | major, better formulation | Four problems with the `w` definitions; report `w_f`, the observer-inferred `w_DE,inf` (with a stated constant subtraction) and both `w_DM` and `w_DM,eff`; the DM/DE split is a convention. | **Confirmed.** | Section 4.5.10. |
| E11 | minor, wrong | `Omega_r0 = 9.15e-5` is wrong; at `h = 0.674`, `T0 = 2.7255 K`, `N_eff = 3.046` it is `9.21e-5`. | **Confirmed** (`9.20961e-5`). | Computed in the code: section 4.7.1, 6.4.3. |
| E12 | minor, hidden assumption | The pre-universe does not define the "beginning of the present universe"; `a_i` must be chosen on physical grounds and shown irrelevant. | **Partly confirmed. Two details wrong:** the `g_*s` correction lowers `T(a_i)` (`T a = T0 (3.909/g_*s)^(1/3)`), it does not raise it to "about 0.5 GeV"; the `rho_r a^4` factor at `a_i = 1e-12` is 0.46–0.71, not 0.386 (that needs `T > 100 GeV`); "any `a_i <= 1e-8`" is too loose (that is after BBN). | `a_i <= min(1e-10, 0.01 a_nr(m))`, insensitivity shown, `g_*(T)` neglected: section 4.7.2. |

What the skeptics of this lens found **missed**: the no-sea functional has a **maximum** at the
physical root (so a global-minimum rule picks a collapsed state; `E = 0.16123, 0.17007, 0.17028,
0.17012, 0.16350, 0.14277` at `m = 0.5, 0.9, 1.0, 1.1, 2, 10` for `W = m0 sigma`, `kF = 1`) — section
4.6.1; the spin connection of the warped frame has `Gamma_x0 = +(1/2) Tan[6Hx0] C'[x4] T16[0].T16[4] ≠ 0`
and `[J, Gamma_h] ≠ 0` — section 4.4.2, 4.4.7; a frozen-compatible vacuum must carry
`rho' = (3H_B + H_C) rho`, and holding it constant violates the constraint (residual `2.6e-2`); the
stabilizer's NEC violation; and that "`Gdot/G` today" and "`DeltaG/G` since BBN" test different things
and must both be reported — section 4.7.10.

### 5.5 The density-functional and numerics lens (`DFT`)

| ID | severity, kind | the finding | verdict | adopted, and where it stands now |
|---|---|---|---|---|
| DFT-1 | critical, wrong | "Ground state = global minimum of `E_n[sigma]`" is wrong: `T_s` is concave, the mass-term root is the **maximum**, the infimum is the variational collapse `E -> −\|m0\| n`. Use the stationary (minimax) point, and for attractive `W` the convex Walecka functional (`W = sigma − 10 sigma^2`, `kF = 1`: `m* = 0.211249`, `Omega(m*) = rho = 0.121193`). | **Confirmed.** | Sections 4.6.1, 3.7.4 (`KOHN-SHAM`), 6.4.2 (`walecka_functional_is_minimized_at_the_gap_root`, `ks_functional_stationary_point_is_a_maximum_for_the_mass_term`). |
| DFT-2 | major, wrong | Uniqueness holds for `W'' g kF^2/(4 pi^2 V) < 1`, not for any monotone `W'`; the repulsive quadratic has three roots, the lowest-energy one of opposite sign. | **Confirmed.** | Section 4.5.3; `root_counts_three_for_strong_repulsion_one_for_concave_w`. |
| DFT-3 | major, wrong | The frozen-hidden condition gives `W = c sigma^2` exactly; no massive dark-matter-like fable is frozen-compatible. | **Confirmed.** | Section 4.5.7. |
| DFT-4 | critical, hidden assumption | For mass-varying `W` the one-loop Dirac-sea energy `DeltaE_vac(m)` is not absorbable and is enormous. | **Partly confirmed. Overstated:** it **can** be absorbed formally by reading `W` as the fully renormalized effective potential — which is a fine-tuning; the sea also adds `sigma_vac = dDeltaE_vac/dm`. The runs use that reading and print `DeltaE_vac(m(t)) − DeltaE_vac(m_today)`. (A figure slip in this verdict is corrected in section 5.8.) | Sections 3.7.3, 4.5.11; the column `vac_over_rhoc`. |
| DFT-5 | major, wrong | The classical limit is the **non-relativistic** limit (Pauli forbids a coherent zero mode), with the expansions and the sign rule that removes Part VI's `M s > 0` branch. | **Confirmed.** | Sections 3.7.7, 4.5.8. |
| DFT-6 | major, incomplete | The missed theorem `rho + P_obs = wF n >= 0`: the quantized fable cannot cross `w = −1`; the Part VI crossing is excluded by `0 < sigma < min(n, s1)`. | **Partly confirmed, plus missed:** `w_f >= −1` holds, but the observer's `w_DE,eff` **can** be phantom and cross −1 when `m_eff` grows (the Das–Corasaniti–Khoury mechanism): power `(0.3, 0.05)`, `nu = 1/2`, `kF0 = 0.1` gives `w_DE,eff = −3.39` at `a = 0.7`, `−1.21` at 0.9, crossing near 1. | Sections 3.7.9, 4.5.9, 4.8.1. |
| DFT-7 | major, wrong | "Bound states below `Sqrt[m^2 + k^2 e^{2a4}]` for `k ≠ 0`" is false in general: with the same-sign MIT wall there is no level at `K = 3`; the first appears near `K_inf ≈ 6.71 H`; the opposite-sign wall has an edge band `omega ≈ ∓0.98 K`. The reviewer gave `n = 0` and `n = 1` at `K = 80` as 70.98531 and 79.37150. | **Partly confirmed. Labelling corrected:** levels must be counted in the full 16-component problem, whose spectrum is `omega -> −omega` symmetric; at `K = 80` the positive levels are 70.98531 (`n = 0`), **78.14425** (`n = 1`, from the other irrep) and 79.37150 (`n = 2`). | Sections 4.6.3–4.6.5 (see also section 5.8). |
| DFT-8 | major, better formulation | In this real-Clifford convention MIT is `T16[0] Psi = eps Psi`; zero normal current alone does not single it out; only the MIT pair is Lorentz-covariant; the explicit 2×2 ODE. | **Partly confirmed, refined:** the covariant, `J`-preserving, self-adjoint walls are `P = T16[0] Q` with `Q` any Hermitian involution in the 8-dimensional commutant of `T16[0..4]`; flavour symmetry gives `Q = ±1`; without `J`-preservation there are more (`T0 exp(i theta T0 T5)`). | Section 4.6.3; the wall-state derivation selects `Q = ±1` by flavour symmetry and charge conjugation. |
| DFT-9 | major, ill-posed | The ΔSCF construction as written is ill-posed (moving one quantum changes `sigma` by `O(1/area)`); define it per transverse area with finite fractions; for the mass term the theory is free. | **Confirmed.** | Section 4.6.6. |
| DFT-10 | major, hidden assumption | The gap equation must use the 8D density; couplings run as 4D couplings (`lam_4 = lam_8/V_hid`). | **Confirmed.** | Section 4.5.1. |
| DFT-11 | major, incomplete | A degenerate dark-matter fable carries extra radiation: `DeltaN_eff = 6.7, 0.31, 0.014` at 1, 10, 100 eV (`∝ m^(-4/3)`), so `m >~ 15 eV`; `Omega_r0` must be computed. | **Confirmed.** | Section 4.7.9. |
| DFT-12 | major, implementation risk | The log closed forms cancel catastrophically for `x = kF/\|m\| << 1`; use series for `x < 0.25`, the `asinh` forms above, never `eps − m sigma` by subtraction. | **Confirmed.** | Sections 3.7.5, 4.5.2; `fermi_integrals_match_quadrature`. |
| DFT-13 | major, implementation risk | The numerical pitfalls: 22 decades of `t`; brackets per potential; the poles of `w_DE,eff`; matching points for the wall states (a fixed `z_m = 0.3` lost the level −70.985 at `K = −80`; a uniform `omega` grid missed the shallow level 8.05384 at `K = 8`). | **Confirmed.** | Sections 4.6.4, 4.7.1. |
| DFT-14 | minor, wrong | `E_x/E_H -> 1/g` only for `kF << m`; it is O(1) or larger for `kF >~ m`. | **Confirmed.** | Section 4.5.12. |
| DFT-15 | minor, incomplete | The pair continuum starts at `wF + \|m\|` (at `q = kF`), at `2 wF` for `q = 0`; particle–hole excitations are gapless. | **Confirmed.** | Section 4.6.2. |
| DFT-16 | minor, hidden assumption | The parameter domains of `power`, `expdamp`, `quadratic`. | **Confirmed.** | Section 4.5.3. |

What the DFT skeptic found **missed**: the apparent phantom of `w_DE,eff` (above); the
free-streaming bound for a degenerate dark-matter fable (`v_rms0 = Sqrt[3/5] kF0/m` = 4.5, 2.6 and
0.21 km/s at 10, 15 and 100 eV against 0.0094–0.0044 km/s for Lyman-α-allowed thermal warm dark matter
of 3–5.3 keV, requiring `m ≈ 1.0–1.8 keV`, far stronger than `DeltaN_eff`; Tremaine–Gunn to be quoted) —
section 4.7.9; the wall-condition family `P = T16[0] Q`; the 16-component labelling of the wall
levels; the gap solver failing in the non-relativistic limit (`x <~ 1e-7`: solve in `delta = 1 − sigma/n`
with the series for `n − sigma_KS`); and the `expdamp` bracket `(0, min(n, s1))`, not `(−n, n)`
(`exp(−sigma/s1)` overflowed near `sigma = −n`).

### 5.6 What the review changed in the answers to [1] and [2]

Before the review the design expected a mechanism for a time-varying dark-energy `w` from the
condensate and from the classical phantom crossing. After it, answer [1] had to separate three
things — no true phantom (`w_f >= −1`), an apparent phantom and a crossing of `−1` in the observer's
inferred dark energy, and the fine-tuning of the Dirac-sea energy — and to rest on the stabilized
model, with its null-energy-condition-violating stabilizer stated, and with `fable8d` reported as a
no-go. Answer [2] had to add the free-streaming and phase-space bounds, which move the allowed mass to
about a keV, where the change of `w_DM` from 1/3 to 0 happens long before recombination. Both answers,
as finally computed, are section 4.8.

### 5.7 Corrections to Effort A that the review produced

They are listed with their places in section 3.9.4 (the table "The design review, and every correction
it made to Effort A").

### 5.8 Corrections found after the review, by the implementation and the checks

These are the errors found later — in the review's own records, in the code, and in earlier pages —
each with how it was found and where it was fixed.

1. **The vacuum-energy slip of `1e4`.** The DFT skeptic's verdict on DFT-4 gave the variation
   `g m^4/(64 pi^2)` of the Dirac-sea energy as `3.44e-4, 3.44, 3.44e8, 3.44e12 rho_c` at
   `m = 0.01, 0.1, 1, 10 eV`. The first two are off by `10^4`: the correct values are `3.44` and
   `3.44e4` (the quantity scales as `m^4`: `g/(64 pi^2) = 0.012665`, `(m/E_c)^4 = 271.9` at
   `m = 0.01 eV`). The addendum was corrected in place ("corrected: an earlier line here had 3.44e-4 and
   3.44 for the first two"), and the correction is stated in section 3.7.3. Notebook 05 prints the
   exact threshold, `g M^4/(64 pi^2) exceeds rho_c0 for M > (64 pi^2/g)^(1/4) E_c = 7.341 meV`
   **[nb05 §5.8]**. (This is a different thing from the solver's own rounding noise in the same
   quantity, item 4 below.)
2. **The reviewer's sign of `F`.** Finding E1 wrote the hidden-sheet driver of the Kohn–Sham fluid as
   `F = sigma W' − 2W`. The skeptic's computation gives `F = rho − 3 P_obs + 2 P_hid = 2W − sigma W'`
   (`m0 sigma` for the mass term, `2.1539 = m0 sigma + 2V0` at `(m0 = 1, V0 = 0.3)`, and `5e-13`,
   `−1.7e-18` for the pure quadratic); the notebook asserts that sign (`F == 2W − sigma W'`, section
   4.5.6). Separately, E7's residual background driver `F_bg = −132 H^2 Cot^2/(kappa C^2)` was wrong
   and replaced by `−12` (for `A`, `B`) and `−72` (for `C`) in units of `H^2 Cot^2/C^2` (section 4.3.3).
3. **The labelling of the first excited wall level (X2).** The review gave `n = 1` at `K = 80` as
   `79.37150`. The wall-state solver, counting the levels exactly in the full 16-component problem,
   found `n = 1` at `78.144249332` (irrep +i) and `79.371495779` as `n = 2`, and it also refuted the
   review's "a second positive level only near `K_inf ≈ 80`": the second level appears at
   `K_c(2) = 33.91895851 H`, almost independent of `m` (33.88–34.29 for `m/H = 0.25..8`) [WG 7, items
   10, 11] — section 4.6.5. The same report confirms, refines or refutes 25 claims of the review and of
   the orchestrator: claim 10 is refuted in part (its `n = 1`) and claim 11 refuted; 6, 14, 16, 17 and
   25 are refined; 3 is confirmed with a basis caveat and 15 confirmed and generalized; 19 is confirmed
   in part (the level exists; the failure of a uniform grid was not re-tested); 20 was not re-tested
   and 21 not needed by the method; the other thirteen are confirmed [WG 7].
4. **The six solver defects of `2bc936d`**, exposed when notebooks 05 and 06 first ran the solver on
   every case (22:53 PDT) [commit 2bc936d]:
   1. *The negative-energy refusal* now is detected inside the right-hand side on every internal CVODE
      step, and its onset bisected to adjacent doubles: `lorentz` refuses with one line at
      `a = 0.4677689478` whatever `--points` is. Before, the onset moved with the grid, and
      `--points 11` died with a CVODE `mxstep` error. A minimum step, `CVodeSetMinStep(64 eps max|x|)`,
      keeps singular approaches fast; successful outputs are byte-identical with it.
   2. *The first-order transition* (repulsive quadratic) is also detected inside the right-hand side
      and bisected, at `a = 0.9962806544` for any grid; scipy agrees to `8e-12`. The message names both
      branches and the missing Maxwell construction. The gap-root scan now finds the extremum between
      merging roots, so the root count changes exactly at the fold (before, it lost the pair `1.4e-7`
      in `N` early).
   3. *The `fable8d` shooting.* Trial runs no longer use the refusal checks as objective values, and
      any `|H_A(1) − 1| > 1e-6` is refused instead of reported as converged. For `lorentz` the old code
      "converged" to `V0 = 7.5e13` with `H_A(1) = 3.3e6`.
   4. *`vac_over_rhoc`* (the renormalized Dirac-sea energy over `rho_c0`) is now evaluated stably in
      `u = (m − M)/M`: a series for `|u| <= 0.75`, which starts at order `(m − M)^5`, and the closed
      form with `log1p` otherwise. It matches 120-digit references to `1.8e-15`. The old closed form
      left rounding noise of `1.6e4–5e4 rho_c0` at 1 keV.
   5. *`gap_residual`* is now measured against the natural scale of `W'`; it is at most `3.3e-16` in
      every phase, including `m -> 0`.
   6. *One `hbar`* (item 7 below).

   The tests went from 21 + 8 to 34/34 (23 unit + 11 integration), and the scipy cross-check still
   passes (largest difference `1.1e-8`).
5. **The `T16` JSON that a fresh clone lacked** [commit aca5102]. The wall-state solver's input
   `waveguide_T16.json` (the notebook's `T16[0..8]`, `sigma16` and the block basis `U`) used to be
   written into the git-ignored `fermion/dev/`, so a fresh clone without Mathematica could not run
   `waveguide.py validate` or notebook 07. It is now written next to the solver and committed; the
   regenerated file is byte-identical, and the derivation log still reports 94 checks, 94 PASS.
   `waveguide.py validate` no longer returns early when the file is missing (it records one `FAIL`
   each for V7 and V8, naming the command that rewrites the file, and still runs its other checks) and
   exits with status 1 whenever any check fails. Its module docstring, which still cited "81/81 PASS"
   from an earlier version of the derivation, now cites the committed log's `94 checks, 94 PASS, 0 FAIL`.
6. **The wording of an earlier provenance page** [commit b7ea18d]. The earlier provenance page on the
   frame field and the canonical spin connection said that the canonical connection "rotates each
   spatial frame axis against the hidden-space direction and boosts it against time" for all six
   directions it excites. That holds for the observed directions `j = 1, 2, 3`. For the deflating
   directions `k = 5, 6, 7` the roles are exchanged, because `x5..x7` are timelike like `x4`: the
   `(0,k)` plane is a **boost** and the `(4,k)` plane a **rotation**. Only the prose was wrong; the
   component table was always right. The fact-check of the spin-connection section of the fermion-fable
   pages found it; the correct statement is in section 3.8.6.
7. **The inconsistent `hbar`** [commit 2bc936d; the constants of the solver]. The solver used to
   compute `H0` in eV with the truncated constant `hbar = 6.582119569e-16 eV s`, and the reduced Planck
   mass with `hbar = 1.054571817e-34 J s`; the two differ by `6.1e-10`. `HBAR_EV_S` is now
   `HBAR_J_S/EV_J`, one CODATA-2018 value for both (the same as the Mathematica reference script). This
   moved `E_c` from `2.46261317798907812e-3` to `2.46261317732986325e-3 eV` (`−2.7e-10`) and `Omega_r0`
   from `9.20960545742757834e-5` to `9.20960546728882807e-5` (`+1.1e-9`); the comments no longer call
   the truncated constants "exact"; `fermion/crosscheck.py` uses the same convention; notebooks 05–07
   assert that the unit system recomputed in Python agrees with the solver's to `1e-9`.
8. **The quantization reviewer's number** (QK-1): the above-threshold frequencies `±1.705872 i` were
   wrong; `±1.19896 i` (`= Sqrt[4 − 2.5625] i`) is right, and notebook 05 prints it **[nb05 §3.3]**.
9. **The direction of the `g_*s` correction** (E12): lower, not higher, temperatures in the past.
10. **The fact-check of the page of Effort A** corrected 7 errors in its markdown and LaTeX before it
    was committed [commit fee5603]; the corrected text is what section 3 reproduces.
11. **The wall-state solver's own bugs**, found by its checks and fixed before its commit: a Magnus
    grid too coarse near the wall (errors `6e-5` rad; fixed by geometric grading to `z = 0.05/H`), a
    trapezoid normalization (`1e-5`; replaced by Simpson), a wrong identification of the edge branch at
    `K >= 80`, a grid mismatch in the band-gap step, and shell escaping in two patches; the first
    Mathematica check printed `NDSolveValue::precw` (fixed by 20 and 10 extra digits of input) [WG 8].
12. **The generator of the notebooks of Effort 0** said four things wrongly; they were corrected
    (section 2.5).

## 6. Effort C: the commands that solve the coupled system, and test, verify, execute and display the calculations

This section is the working manual of the whole solution. It gives **every command**, in full, in a
fenced block; for each one what it does and why, what it needs first, how long it takes, what it
prints (quoted from the real logs and outputs, with the file named), and how to tell success from
failure. Section 6.2 gives the order in which to run them. All commands run in **Git Bash on
Windows 11**, where they were run; they are plain POSIX shell and run the same way on Linux and macOS
with `.venv/bin/python` in place of `.venv/Scripts/python.exe` and without the `.exe` suffix. Where a
PowerShell twin exists, it is given too.

### 6.1 The toolchain, and how to set it up

**What is needed, and the versions that produced every result on this page** [the tools' own
`--version` output on the development machine, 2026-09-25; the first line of the run logs]:

| tool | used for | version | check |
|---|---|---|---|
| Git (Git for Windows, with Git Bash and Perl) | the repository; the shell; Perl for `latexmk` | `git version 2.51.2.windows.1` | `git --version` |
| Wolfram Language / `wolframscript` | the notebook (Parts I–VIII), the TeX export, the Mathematica reference runs, the wall-problem derivation and its check | `Wolfram Language 15.0.1 for Microsoft Windows (64-bit) (July 2, 2026)`; `WolframScript 1.14.0 for Microsoft Windows (64-bit)` | `wolframscript -version` |
| Rust (`cargo`, `rustc`, MSVC toolchain on Windows) | the solvers `fable_cosmo` and `fable_fermion` | `cargo 1.91.1 (ea2d97820 2025-10-10)`, `rustc 1.91.1 (ed61e7d7e 2025-11-07)` | `cargo --version` |
| the engine | pure-Rust SUNDIALS 7.8.0 CVODE (`sundials_rs`), sparse-cloned from the rustSolveIt repository of the platform | `rustSolveIt_Win11_SUNDIALS_7_8_0 @ a8fdff4`; the binaries report `sundials_rs 7.8.0 (pure Rust), CVODE BDF` | `setup.sh` prints `== engine: <url> @ <commit>` |
| Python 3.10 or newer, in the virtual environment `fable-cosmology/.venv` | the notebooks, the cross-check, the wall-state solver, the notebook builder | Python 3.14.5; numpy 2.5.3, scipy 1.18.1, matplotlib 3.11.2, nbconvert 7.17.1, nbclient 0.11.0, nbformat 5.11.1, ipykernel 7.3.0 | `python --version` |
| MiKTeX (TeX Live on Linux/macOS) with `latexmk` | the paper of Effort 0; the LaTeX twins of the provenance pages | `MiKTeX-pdfTeX 4.27 (MiKTeX 26.5)`; `Latexmk, John Collins, 9 March 2026. Version 4.88`; MiKTeX installed at `C:/Program Files/MiKTeX/miktex/bin/x64` | `pdflatex --version`, `latexmk -v` |

How to install them, per platform: **Windows 11** — Git for Windows (`https://git-scm.com/download/win`);
Rust with `rustup-init.exe` from `https://rustup.rs` (it uses the MSVC toolchain, which needs the
"Desktop development with C++" workload of the Visual Studio Build Tools; rustup offers to install
it); Python from `https://www.python.org/downloads/` with "Add python.exe to PATH" ticked; MiKTeX from
`https://miktex.org/download`, allowed to install missing packages on the fly; Perl for `latexmk` is in
Git Bash (in PowerShell run `$env:Path += ";C:\Program Files\Git\usr\bin"` or install Strawberry
Perl). **macOS (Apple silicon)** — `xcode-select --install`; Rust with
`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`; Python 3.10+; MacTeX (which contains
`latexmk` and Perl). **Linux (x86-64, Debian/Ubuntu)** — `sudo apt install build-essential git`; Rust as
on macOS; `sudo apt install python3 python3-venv`; `sudo apt install latexmk lmodern
texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended`. Wolfram Mathematica (developed
with 15.0.1) is needed only for the Mathematica steps (sections 6.3, 6.6.1, 6.6.4); everything else runs
without it, because the notebook's log, the reference CSVs, the derivation's log and its export
`waveguide_T16.json` are committed. An internet connection is needed once, for the setup.

**Get the repository:**

```bash
git clone https://github.com/once-ere/Pre-Universe_with_Claude.git
cd Pre-Universe_with_Claude
```

The repository carries a `.gitattributes` with `* -text`, so git never rewrites line endings and every
file checks out with the bytes that were committed. Every command below starts from the repository
root; `cd "$(git rev-parse --show-toplevel)"` takes you there from anywhere inside it.

**Set up, once** (Git Bash, macOS, Linux; PowerShell twin below):

```bash
bash fable-cosmology/setup.sh
```

```powershell
powershell -ExecutionPolicy Bypass -File fable-cosmology\setup.ps1
```

- **What it does** [file: `fable-cosmology/setup.sh`]. (1) Creates `fable-cosmology/.venv` unless it
  exists — with `python3` when that runs, else `python` — upgrades pip, installs
  `fable-cosmology/requirements.txt` (numpy, scipy, matplotlib, jupyter, nbconvert, nbclient,
  ipykernel), imports the packages and prints `python ok: numpy <v> scipy <v> matplotlib <v>`.
  (2) Picks the engine repository for the platform (`uname -s`: `Linux*` →
  `https://github.com/once-ere/rustSolveIt_linux_SUNDIALS_7_8_0.git`, `Darwin*` →
  `…/rustSolveIt_macos-silicon_SUNDIALS_7_8_0.git`, `MINGW*|MSYS*|CYGWIN*` →
  `…/rustSolveIt_Win11_SUNDIALS_7_8_0.git`) and, unless
  `rust/vendor/rustSolveIt/sundials_rs/crates/cvode_rs` exists, makes a sparse clone
  (`git clone --depth 1 --filter=blob:none --sparse <url> rust/vendor/rustSolveIt`, then
  `git sparse-checkout set sundials_rs`), and prints `== engine: <url> @ <commit>`. (3) For each of the
  two solver crates, `rust/fable_cosmo` and `rust/fable_fermion`, runs `cargo build --release` inside
  the crate's own folder and smoke-tests the binary with `--version`. It ends with `== setup complete`.
- **Why this way.** Both crates depend on the engine by path
  (`../vendor/rustSolveIt/sundials_rs/crates/sundials_core` and `…/cvode_rs`), exactly as rustSolveIt's
  own `planet_Mercury/mercury_rs` does, and each pins `-C target-feature=+fma` in its own
  `.cargo/config.toml` on x86-64, because the engine's deterministic math library uses `f64::mul_add`
  and requires it. Cargo reads that file from the directory it is invoked in, so **each solver must be
  built from inside its own folder**, as the script does.
- **How long.** On the development machine the whole setup from nothing (pip, the engine clone over
  the network, the builds) took 80 s in a fresh clone; the first build of `fable_cosmo` took
  `Finished release profile [optimized] target(s) in 5.04s` (section 2.3).
- **What it prints** in a fresh clone (recorded for `fable_cosmo` on 2026-09-24, before the second
  crate existed; the scratch path is shortened to `…`):

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

  With both crates the script prints, after that, `== building rust/fable_fermion (release)`, cargo's
  lines, and `fable_fermion 0.1.0, sundials_rs 7.8.0 (pure Rust), CVODE BDF` before
  `== setup complete`. The three pip warnings come from pip's local download cache and are harmless.
  The setup's output in the final fresh clone is recorded in section 7.
- **Success and failure.** Success is the two `--version` lines and `== setup complete`, with exit
  code 0 (`setup.sh` runs under `set -euo pipefail` and stops at the first failing command; `setup.ps1`
  checks `$LASTEXITCODE` after each build and each `--version` and throws). Typical failures and their
  causes: `python: command not found` (neither `python3` nor `python` works: install Python or create
  the environment by hand with `python3 -m venv fable-cosmology/.venv`); `error: linker 'link.exe' not
  found` or MSVC errors (the C++ build tools are missing); path errors naming `vendor/rustSolveIt`
  (the engine clone is incomplete: delete `fable-cosmology/rust/vendor/rustSolveIt` and run the setup
  again); an error about the target feature `fma` (cargo was run from another directory).
- **Idempotent.** Re-running it changes nothing that is already in place.

The same three steps by hand (replace `linux` in the URL by `Win11` or `macos-silicon`):

```bash
cd "$(git rev-parse --show-toplevel)/fable-cosmology"
python3 -m venv .venv                                  # or: python -m venv .venv
.venv/bin/python -m pip install -r requirements.txt    # Windows Git Bash: .venv/Scripts/python.exe
mkdir -p rust/vendor
git clone --depth 1 --filter=blob:none --sparse https://github.com/once-ere/rustSolveIt_linux_SUNDIALS_7_8_0.git rust/vendor/rustSolveIt
( cd rust/vendor/rustSolveIt && git sparse-checkout set sundials_rs )
( cd rust/fable_cosmo && cargo build --release )
rust/fable_cosmo/target/release/fable_cosmo --version
( cd rust/fable_fermion && cargo build --release )
rust/fable_fermion/target/release/fable_fermion --version
```

### 6.2 The order in which to run everything

| step | command (section) | needs | time on the development machine | success looks like |
|---|---|---|---|---|
| 1 | `bash fable-cosmology/setup.sh` (6.1) | Git, Rust, Python, network | 80 s from nothing | `== setup complete` |
| 2 | `cargo test --release` in both crates (6.4.2) | step 1 | about 45 s (`fable_fermion`), under 1 s (`fable_cosmo`) | `test result: ok. 23 passed`, `11 passed`; `7 passed` |
| 3 | `fable_fermion --constants`, one `gap` solve (6.4.3, 6.4.4) | step 1 | instant | the unit block; three roots |
| 4 | `python fermion/crosscheck.py --jobs 6` (6.5) | step 1 | about 10 s | `CROSSCHECK PASSED: every difference < 1e-06` |
| 5 | `python fermion/waveguide.py validate` (6.6.2) | step 1 | 31–45 s | `VALIDATION: 64 of 64 PASS`, exit code 0 |
| 6 | execute notebooks 05, 06, 07 and check them (6.7) | steps 1 (and 5 for 07) | 7 s, 93 s, 558 s | `7/7 notebooks pass all eight requirements` |
| 7 | or steps 2 and 6 for all seven notebooks, plus the paper: `bash fable-cosmology/run_all.sh` (6.8) | step 1 | 12 min 18 s | `== all done` |
| 8 | `python build_tools.py`, then `verify_nb.wls` (6.3.1, 6.3.2) | Python; Mathematica | 0.1 s; 4 s | byte-identical notebook; `input cells that FAIL to parse: {}` |
| 9 | `wolframscript -file run_from_nb.wls` (6.3.4) | Mathematica; for the full 644, step 6 first (it writes the Rust CSVs Part VIII compares with) | 208.715 s | `Assertions run: 644   passed: 644   failed: 0`, `cells w/ msgs   : 0` |
| 10 | the TeX export, the reference runs, the wall-problem derivation and its check (6.3.6, 6.3.7, 6.6.1, 6.6.4) | Mathematica | a notebook run; not recorded; 163–171 s; 40 s | 14 files written; 701 rows each; `94 checks, 94 PASS, 0 FAIL`; `11 checks, 11 PASS, 0 FAIL` |
| 11 | `bash provenance-latex/build_all.sh` (6.9) | MiKTeX or TeX Live | — | `== all three PDFs built` |
| 12 | commit, push, `git ls-remote`, fresh clone (6.10, 7) | everything above | — | the local and remote hashes equal; every check reproduced |

The Mathematica steps (8–10) and the Python/Rust steps (1–7) are independent, with one exception:
Part VIII's comparison with the Rust solver runs only when notebook 06 has written
`results/nb06_fable4d_mass30eV.csv` and `results/nb06_fable4d_power.csv` (otherwise it is skipped, not
failed, and the run reports 642/642 instead of 644/644).

### 6.3 The Mathematica notebook: build, check, map, run, verify, export, reference runs

The notebook `claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb` holds all the symbolic
mathematics: Parts I–V (the author's pre-universe, its algebra, the canonical frame and spin
connection, the bridges), Part VI (Effort 0's classical fields), Part VII (Effort A) and Part VIII
(Effort B's symbolic side). Every claim is an assertion `cfAssert[label, test]`, which prints
`PASS  label` or `FAIL  label`.

#### 6.3.1 Build the notebook from its manifests

The notebook is never edited by hand. `build_tools.py` reads every `claude-fable/cells_part*.wl` in
order and writes both the notebook and `run_all.wls` (the same Input cells as a script).

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
python build_tools.py          # use python3 where python is absent
```

It prints (recorded on 2026-09-24, with the eight committed manifests, in a scratch copy of the
directory so that nothing in the repository was touched; it ran in 0.115 s; the last line gives the
absolute path of the directory it ran in):

```
manifest files : ['cells_part1.wl', 'cells_part2.wl', 'cells_part3.wl', 'cells_part4.wl', 'cells_part5.wl', 'cells_part6.wl', 'cells_part7.wl', 'cells_part8.wl']
cells parsed   : 384 {'Title': 8, 'Subtitle': 1, 'Subsubtitle': 1, 'Text': 123, 'Section': 34, 'Input': 217}
run_all.wls    : 217 Input cells
notebook       : 384 cells -> <repo>\claude-fable\claude-fable_Einstein-Rosen-2-Planes.nb
```

**Success:** the rebuilt `claude-fable_Einstein-Rosen-2-Planes.nb` and `run_all.wls` are
**byte-identical** to the committed ones (`cmp` reports no difference; `git status` shows nothing).
With only the seven manifests of Parts I–VII present — the state in which Part VII was run — it
prints `cells parsed   : 340 {'Title': 7, 'Subtitle': 1, 'Subsubtitle': 1, 'Text': 103, 'Section': 30, 'Input': 198}`
and `run_all.wls    : 198 Input cells`. The notebook has not changed since `bc04ed1`.

#### 6.3.2 Check the notebook without evaluating it

```bash
wolframscript -file "$(git rev-parse --show-toplevel)/claude-fable/verify_nb.wls"
```

It imports the `.nb`, counts its cells by style, extracts the Input cells, and checks that every one
of them parses. About 4 s (4.118 s when timed). It prints [file: `claude-fable/verify_nb_part8.log`,
and identically when re-run on 2026-09-24]:

```
file bytes: 545408
Head: Notebook
cells: 384
style tally: {{Title, 8}, {Subtitle, 1}, {Subsubtitle, 1}, {Text, 123}, {Section, 34}, {Input, 217}}
input cells with plain-string BoxData: 217
total input characters: 347187
input cells that FAIL to parse: {}
first cell: InputForm[(* --- provenance banner, as in the original notebook ------------------------------------]
last cell : InputForm[cfAssert["PART VIII [control]: a4 is STILL UNDEFINED -- nothing in Part VIII gave it a val]
```

**Success:** `input cells that FAIL to parse: {}`. For the Part VII notebook it printed
(`claude-fable/verify_nb_part7.log`) `file bytes: 440320`, `cells: 340`, the tally with 198 Input cells,
`total input characters: 279955`, `input cells that FAIL to parse: {}`, and the last cell
`(* --- final tally of every assertion made in this notebook, Parts I-VII ...`.

#### 6.3.3 Print the section-to-cell map

```bash
wolframscript -file "$(git rev-parse --show-toplevel)/claude-fable/nb_section_map.wls" > "$(git rev-parse --show-toplevel)/claude-fable/nb_section_map.log"
```

It reads the `.nb` without evaluating anything and prints, in document order, each Part title and each
Section with the range of its Input cells (3.340 s when timed). Its output,
`claude-fable/nb_section_map.log`, is the table of contents of the notebook and the key to every
"Section n" on this page:

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

Where each Section of Parts VII and VIII is discussed on this page:

| notebook Section | Input cells | assertions | seconds (Part VII log; Part VIII log) | this page |
|---|---|---|---|---|
| 26 | 173–179 | 38 | 1.957 | 3.2 |
| 27 | 180–184 | 36 | 2.291 | 3.3, 3.4, 3.8 |
| 28 | 185–191 | 56 | 12.311 | 3.5 |
| 29 | 192–198 | 40 | 17.874 | 3.6, 3.7 |
| 30 | 199–203 | 28 | 4.119 | 4.2 |
| 31 | 204–207 | 21 | 12.672 | 4.3 |
| 32 | 208–210 | 26 | 4.694 | 4.4 |
| 33 | 211–217 | 39 (41 in the final run) | 2.526 | 4.5, 4.7 |

#### 6.3.4 Run the notebook end to end, straight out of the `.nb`

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
wolframscript -file run_from_nb.wls > run_fermion_fable_final.log 2>&1
git checkout -- claude-fable_Einstein-Rosen-2-Planes-eLa.mx claude-fable_Einstein-Rosen-2-Planes-eLazt.mx
```

- **What it does.** `run_from_nb.wls` imports the `.nb`, takes its Input cells in order, and evaluates
  each one as a single unit (a multi-line cell becomes one `CompoundExpression`, exactly as the front end
  evaluates it), through the harness `runner_header.wl`. The harness prints `CELL n  t=... s` after
  each cell, with `MESSAGES: ...` appended if the cell raised any message, prints every `PASS` or
  `FAIL` label, and ends with the run summary and the assertion counts. The script is self-locating
  (`$InputFileName`) and finds the notebook from any directory.
- **Why from inside `claude-fable/`.** Run headless, the notebook cannot ask for its own file name, so
  Section 10 looks for the author's helper packages `ConvertMapleToMathematicaV2.wl` and `EtoExp.wl` in
  the working directory (and in `Pre-Universe_14SEP26-77/` below it, and one level up); they sit in
  `claude-fable/`. The reference CSVs of Parts VI and VIII are found as
  `claude-fable\..\fable-cosmology\reference\...` (the log prints these paths), and Part VIII's Rust
  CSVs as `claude-fable\..\fable-cosmology\results\...`.
- **The `.mx` restore.** Section 12 of the notebook writes `claude-fable_Einstein-Rosen-2-Planes-eLa.mx`
  and `...-eLazt.mx` with `DumpSave`, whose bytes are not reproducible from run to run (their content
  is: the wall-state report records that loading the committed and the rewritten files gives
  `eLa === eLa` and `eLazt === eLazt` [WG 1]). The two
  files are restored to the committed version after every run, as the second command does.
- **How long.** 208.715 s for the 217 cells of the final run (`total seconds   : 208.715`); the earlier
  runs took 232.146 s (Parts I–VII, 198 cells) and 233.289 s (Parts I–VIII, 217 cells). The slowest
  cell is Part II's cell 80, the bilinears of the author's closed-form solution (69.797 s in the final
  run).
- **What it prints.** First `evaluating 217 Input cells straight out of the .nb`, then the provenance
  banner of the original notebook (`CopyRight (C) 2022, Patrick L. Nash, under the General Public
  License.`, `Please cite this work, and this web page, if you use it.`,
  `Refactored for claude-fable_Einstein-Rosen-2-Planes.nb; Wolfram Language 15.0.1 for Microsoft Windows (64-bit) (July 2, 2026)`),
  then every cell's line, `PASS` labels and notes. The Part VII portion is quoted in full in section
  3.9.2. Part VIII's last cell prints the Mathematica solution of the two reference cases (section
  4.7.12), then the tallies. The final run ends [file: `claude-fable/run_fermion_fable_final.log`]:

```
identities accepted on numerical evidence alone : 0   (stage 3 returned True)
non-vanishing witnesses                         : 46   (cfNonZeroWitnessQ found a probe point at which every entry is a
                                                     number and one of them is non-zero: a complete proof of non-vanishing)
  PASS  no identity in this notebook was accepted on numerical evidence alone
Assertions run: 644   passed: 644   failed: 0
CELL 217  t=0.000 s
==================== RUN SUMMARY ====================
cells evaluated : 217
total seconds   : 208.715
cells w/ msgs   : 0
---- slowest cells ----
  cell 80  69.797 s
  cell 88  22.871 s
  cell 204  9.939 s
  cell 191  8.828 s
  cell 86  8.339 s
  cell 87  7.361 s
  cell 137  7.359 s
  cell 121  4.840 s
  cell 196  3.848 s
  cell 160  3.824 s
  cell 107  3.789 s
  cell 193  3.062 s
==================== ASSERTIONS ====================
assertions run  : 644
passed          : 644
FAILED          : 0
====================================================
```

- **Success and failure.** Success is `assertions run  : 644`, `passed          : 644`,
  `FAILED          : 0`, `cells w/ msgs   : 0`, and `identities accepted on numerical evidence alone : 0`.
  A failed assertion prints `FAIL  label` and is counted in `FAILED`; a cell that raises any message
  gets `MESSAGES: ...` on its `CELL` line and is counted in `cells w/ msgs`. The run also prints four
  `EXPECTED MESSAGE(S)` lines (three in Part II, one in Part V: messages that the original notebook's
  time budgets or its underdetermined `Solve` calls may raise, announced in advance) and one `NOTE` in
  Part III (that `a4` is an undefined scalar function inherited from the original notebook); none of
  them is a message raised by a cell. If the Rust CSVs are absent, Section 33 prints twice
  `NOTE  Rust CSV not found; that comparison was skipped, not failed`, and the run ends at 642/642 —
  that is how `claude-fable/run_fermion_fable_part8.log` ends (`total seconds   : 233.289`), because it
  was made before notebook 06 wrote them.

The three committed logs of the notebook of 2026-09-24/25, and what separates them:

| log | notebook | Input cells | assertions | seconds | witnesses | commit |
|---|---|---|---|---|---|---|
| `claude-fable/run_fermion_fable_part7.log` | Parts I–VII | 198 | 528/528 | 232.146 | 38 | `4fdfc40` |
| `claude-fable/run_fermion_fable_part8.log` | Parts I–VIII, Rust CSVs absent | 217 | 642/642 | 233.289 | 46 | `bc04ed1` |
| `claude-fable/run_fermion_fable_final.log` | Parts I–VIII, Rust CSVs present | 217 | 644/644 | 208.715 | 46 | `1671155` |

The first two end with a line `RUN-DONE` that the wrapper which ran them appended; the final one has
none. All three were produced by the same command with the output redirected to the named log.

#### 6.3.5 Check a log

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
grep -c '^  PASS' run_fermion_fable_final.log          # 644
grep -c '^  PASS' run_fermion_fable_part8.log          # 642
grep -c '^  PASS' run_fermion_fable_part7.log          # 528
grep -n '^  FAIL' run_fermion_fable_final.log          # no output: no assertion failed
grep -c 'MESSAGES: ' run_fermion_fable_final.log       # 0: no cell raised a message
grep -E 'identities accepted|non-vanishing witnesses' run_fermion_fable_final.log | tail -2
#   identities accepted on numerical evidence alone : 0   (stage 3 returned True)
#   non-vanishing witnesses                         : 46   (cfNonZeroWitnessQ found a probe point at which every entry is a
sed -n '/RUN SUMMARY/,$p' run_fermion_fable_final.log  # the summary quoted in 6.3.4
diff <(grep '^  PASS' run_fermion_fable_part8.log) <(grep '^  PASS' run_fermion_fable_final.log)
#   641a642,643
#   >   PASS  fable4d RUNS [fidelity]: the Rust solver's mass30eV run agrees with this cell to 1e-6 in every column, at every one of the rows its grid covers
#   >   PASS  fable4d RUNS [fidelity]: the Rust solver's power run agrees with this cell to 1e-6 in every column, at every one of the rows its grid covers
```

The counts are the results on the committed logs (checked for this page). A plain `grep FAIL` also
finds the summary line `FAILED          : 0` and two `PASS` labels whose text contains the word "FAILS"
(control assertions that show a wrong sign failing, lines 298 and 921 of both the Part VIII log and the
final log); `grep -n '^  FAIL'` finds only real failures.

#### 6.3.6 Export the field equations, the anticommutator, `J` and the equations of state to TeX and text

```bash
wolframscript -file "$(git rev-parse --show-toplevel)/claude-fable/export_fermion_fable_tex.wls"
```

It is self-locating and sets its working directory to `claude-fable/`, so it runs from anywhere. It
evaluates every Input cell of the notebook with the output suppressed (so it takes about as long as a
run; its duration was not recorded), prints the assertion count, stops with exit code 1 if the Part VII
objects are missing, and writes fourteen files (seven `.tex` and seven `.txt`) into
`provenance-latex/generated/`: the 16 component field equations, the 16 adjoint equations, the 8+8
form, the rescaled equations, the anticommutator `{Psi_a, Psi^ddag_b} = H Cos[6 H x0] J_ab delta^7` with
its matrix, `J`, `beta` and `sigma16 = J beta`, and the Kohn–Sham closed forms (section 3.9.6 lists them
with the notebook objects they come from). The script does no mathematics of its own beyond formatting.
It was run on 2026-09-24 at 20:41 PDT on the 198-cell notebook and printed:

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

(That console output was captured outside the repository; the fourteen files were committed in
`4fdfc40`.) On today's 217-cell notebook the first two lines read `evaluating 217 Input cells ...` and
`assertions: ...`; the Part VII objects it exports are the same. **Success:** `done: 14 files`, and the
`.txt` files unchanged (`git status` shows nothing for them); the `.tex` files carry the date of the run
in their header comment, so a re-run on another day changes that one line. Like every evaluation of the
notebook it rewrites the two `.mx` files, which are then restored as in 6.3.4. The `.txt` files are
quoted verbatim in sections 3.4, 3.5 and 3.7; a test document that `\input`s all seven `.tex` fragments
(with `amsmath`) compiled with pdfLaTeX to 9 pages with no errors, warnings or overfull boxes.

#### 6.3.7 The Mathematica reference runs of the coupled system

```bash
wolframscript -file "$(git rev-parse --show-toplevel)/fable-cosmology/reference/make_reference_fermion.wls"
```

- **What it does.** An independent Mathematica solution of two `fable4d` cases, written next to the
  script as `mathematica_fable4d_mass30eV.csv` and `mathematica_fable4d_power.csv`: 701 values of `N`
  from `ln 1e-10` to 0, columns `N, a, t, H_A, rho_f, P_obs_f, w_f, m_eff, sigma, kF_over_m`; every row
  is exact algebra at 40 significant digits (the power-law gap by Brent's method at 45 digits), the age
  by `NDSolve` at working precision 30, with the stable series of the Fermi-sea integrals for
  `k_F/|m| < 1/4` [file: its header]. Self-locating.
- **What it prints** [file: its `Print` statements]: the units (`E_c = rho_c0^(1/4) = ... eV;  1/H0 = ... yr`,
  the three `Omega`s), the agreement of the series with the closed forms at `kF/m = 1/5, 1/100`, the
  parameters of each case (`mass30eV: m0 = ... E_c = 30 eV;  kF0 = ... E_c = ... eV;  V0 = Omega_Lambda = ...`;
  `power: nu = 1/2, m_today = 100 eV, eps_today = 0.55;  kF0 = ... E_c;  lam = ...`), the timings and
  checks of each case (`|H_A(1) - 1|`, `w_f(a_i)`, the largest gap residual, `m_eff(a_i)`), and
  `wrote mathematica_fable4d_mass30eV.csv and mathematica_fable4d_power.csv (701 rows each)`. Its console
  output and its duration were not captured in a repository log.
- **How it is checked.** By Part VIII: `fable4d RUNS [fidelity]: the reference CSVs have the expected header and 701 rows`
  and `fable4d RUNS [fidelity]: at every tenth row ALL TEN columns agree with fable-cosmology/reference/mathematica_fable4d_mass30eV.csv and _power.csv to 1e-10 (relative; P_obs_f relative to rho_f; N and w_f absolute)`
  (the log prints `max difference per column {0., 0., 0., 0., 0., 0., 0., 0., 0., 0.}` for both), and by
  notebook 06's three-way comparison (section 4.7.12). **Success:** both CSVs byte-identical to the
  committed ones after a re-run (`git status` shows nothing).

The classical references of Effort 0 are made the same way, by
`wolframscript -file fable-cosmology/reference/make_reference.wls` (427 s on its first run of 2026-09-24,
366 s after the fix of `028b379`), which prints exactly two lines (section 2.2).

### 6.4 The Rust solver `fable_fermion`: build, test, and every run

The solver of the coupled (quantized fermion fable, 8-dimensional primordial gravitational field)
system, on the pure-Rust SUNDIALS 7.8.0 CVODE engine. Its models, equations, units and normalization are
section 4.7.1; this section is how to drive it.

#### 6.4.1 Build it

```bash
cd "$(git rev-parse --show-toplevel)/fable-cosmology/rust/fable_fermion"
cargo build --release          # -> target/release/fable_fermion(.exe)
./target/release/fable_fermion --version
```

It prints `fable_fermion 0.1.0, sundials_rs 7.8.0 (pure Rust), CVODE BDF` (the first line of notebooks
05, 06 and 07). Build it from inside its folder: the crate's `.cargo/config.toml` pins
`rustflags = ["-C", "target-feature=+fma"]` on x86-64, which its comment states is **required** by the
vendored engine (its deterministic math library uses `f64::mul_add`), and cargo reads that file only
from the directory it is invoked in. `setup.sh` does the same (section 6.1).

#### 6.4.2 Test it

```bash
cd "$(git rev-parse --show-toplevel)/fable-cosmology/rust/fable_fermion"
cargo test --release
```

It runs the 23 unit tests of `src/` and the 11 end-to-end tests of `tests/cosmology.rs`; each end-to-end
test runs the real binary, writes a CSV and reads it back. About 45 s. The history of the count: `21 + 8`
at the finished solver (`c5892bd`, "re-run independently"), **34/34 (23 unit + 11 integration)** after the
six defects were fixed (`2bc936d`). The 34 tests [listed from the source files]:

| file | tests |
|---|---|
| `src/constants.rs` | `unit_system_matches_the_standard_values` |
| `src/cvode_driver.rs` | `exponential_decay_forward_and_backward` |
| `src/numerics.rs` | `brent_finds_simple_roots`, `gauss_kronrod_is_exact_on_smooth_functions` |
| `src/potentials.rs` | `derivatives_match_finite_differences`, `signs_that_the_bracket_proofs_use` |
| `src/kohn_sham.rs` | `fermi_integrals_match_quadrature`, `series_and_closed_forms_are_continuous_at_the_switch_points`, `nonrelativistic_and_ultrarelativistic_limits`, `per_3_volume_mean_field_violates_8d_conservation`, `thermodynamic_identities_at_the_self_consistent_point`, `derivative_along_the_trajectory_matches_finite_differences`, `expdamp_pins_sigma_below_s1_and_mass_goes_to_zero_at_high_density`, `multiple_gap_roots_are_found_and_the_lowest_energy_one_is_taken`, `quadrature_at_the_review_points_and_switch_continuity`, `nonrelativistic_classical_limit_of_the_mean_field`, `no_phantom_crossing_rho_plus_p_obs_is_nonnegative`, `root_counts_three_for_strong_repulsion_one_for_concave_w`, `walecka_functional_is_minimized_at_the_gap_root`, `vacuum_energy_vanishes_to_fifth_order_at_the_reference_mass`, `vacuum_energy_matches_high_precision_references_near_and_far_from_the_reference_mass`, `gap_residual_is_at_round_off_in_massless_phases`, `ks_functional_stationary_point_is_a_maximum_for_the_mass_term` |
| `tests/cosmology.rs` | `version_string`, `covariant_conservation_along_real_fable8d_runs`, `constraint_residual_stays_small_on_forward_fable8d_runs`, `frozen_hidden_theorem`, `fable8d_with_hidden_frozen_by_hand_reproduces_fable4d`, `backward_runs`, `physics_checks_along_runs`, `negative_energy_refusal_is_found_inside_the_rhs_independently_of_the_output_grid`, `first_order_transition_is_found_inside_the_rhs_independently_of_the_output_grid`, `gap_residual_and_vacuum_energy_at_round_off_in_1_kev_runs`, `insensitivity_to_a_start` |

What they check, in words: the unit system against standard values; CVODE forward and backward on an
exponential; Brent and Gauss–Kronrod; the potentials' derivatives, `U` and `F` against finite
differences and the signs the bracket proofs use; the Fermi-sea integrals against Gauss–Kronrod
quadrature to `1e-12` for `kF/|m|` from `1e-8` to `1e6` and both signs of `m`; the continuity of the series
and closed forms at the switch points; the non- and ultra-relativistic limits; `eps − 3P = m sigma`,
`eps + P = wF n`, `d rho/d n8 = wF` at the gap; the derivatives along a trajectory; the classical limit
of the mean field; `w_f >= −1` for every potential; the root counts (three for the repulsive quadratic,
one for every concave `W`); the lowest-energy selection; the `expdamp` pinning `sigma8 < s1`; the maximum
of the no-sea functional at the mass-term root; the minimum of the Walecka functional; the fifth-order
zero of the Dirac-sea energy; the violation of 8D conservation by a per-3-volume mean field; the
Dirac-sea energy against high-precision references; the gap residual at round-off in massless phases;
and, on real runs, covariant conservation along `fable8d`, the constraint residual, the frozen-hidden
theorem (radiation keeps `H_B = 0`; dust drives it), `fable8d --freeze-hidden` = `fable4d`, backward runs
(refused for `fable8d`, equal to forward for `fable4d`), physics checks, insensitivity to `a_start`, the
two refusals located inside the right-hand side independently of the output grid, and the gap residual
and the Dirac-sea energy at round-off in 1 keV runs.

**What it prints.** For each test binary `running N tests`, one `test <name> ... ok` line per test, and a
`test result:` line. `run_all.sh` keeps only the `running`/`test result` lines; on 2026-09-25 they were
[quoted from the recorded run of `run_all.sh`]:

```
running 23 tests
test result: ok. 23 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 38.31s
running 0 tests
test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
running 11 tests
test result: ok. 11 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.93s
running 0 tests
test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

(the four test binaries are the library, the command-line binary, the end-to-end tests and the
documentation tests). **Success:** `23 passed` and `11 passed`, `0 failed`, exit code 0. A failing test
prints `test <name> ... FAILED`, a `panicked at` line with the assertion that failed, `test result:
FAILED`, and exits non-zero (and `run_all.sh`, `run_all.ps1` then stop).

The classical solver of Effort 0 is tested the same way from `fable-cosmology/rust/fable_cosmo`: 7
tests (`scalar_derivatives_match_finite_differences`, `spinor_derivatives_match_finite_differences_and_w`,
`cpl_closed_form_matches_the_integral`, `rho_plus_p_is_twice_the_kinetic_energy`,
`friedmann_closure_today`, `x0_grid_rejects_the_singular_ends`, `exponential_decay_to_tolerance`), ending
`test result: ok. 7 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s`.

#### 6.4.3 The unit system

```bash
cd "$(git rev-parse --show-toplevel)/fable-cosmology"
F=rust/fable_fermion/target/release/fable_fermion        # fable_fermion.exe on Windows
$F --constants
```

It prints the unit system the solver computes from CODATA 2018 and IAU constants (`hbar = c = k_B = 1`;
time in `1/H0`; energy densities per 7-volume in `rho_c0`; masses and momenta in `E_c = rho_c0^(1/4)`)
[nb05 §5, verbatim]:

```
# fable_fermion unit system (hbar = c = k_B = 1)
h                     = 0.674
H0                    = 2.1842852411e-18 1/s = 6.8930799924e-11 1/yr = 1.4377226622e-33 eV
1/H0                  = 1.4507302992e10 yr
M_pl (reduced, from G)= 2.4353234593e27 eV = 2.4353234593e18 GeV
rho_c0 = 3 H0^2 M_pl^2= 3.6777719498e-11 eV^4
E_c = rho_c0^(1/4)    = 2.4626131773e-3 eV   (unit of m, kF; sigma, n in E_c^3; W, rho in E_c^4 = rho_c0)
1 eV                  = 4.0607270732e2 E_c
T_CMB                 = 2.7255 K = 2.3486541806e-4 eV;  T_nu0 = 1.6763891605e-4 eV
Omega_gamma0          = 5.4437728013e-5   (Omega_gamma0 h^2 = 2.4729753331e-5)
Omega_nu(1 species)0  = 1.2363206389e-5
Omega_r0 (N_eff=3.046)= 9.2096054673e-5   (Omega_r0 h^2 = 4.1837027333e-5)
Omega_b0 = 0.02237/h^2 = 4.9243191364e-2
(g_*(T) is not followed: radiation is Omega_r0 A^-4 at all times, which misstates rho_r A^4 by up to a factor ~0.39 before e+e- annihilation and the QCD transition)
g (fable states per momentum) = 8
a_BBN (T = 1 MeV)     = 1.6763891605e-10   (= T_nu0 / 1 MeV)
a_rec (z = 1090)      = 9.1659028414e-4
```

Every notebook of Effort B recomputes this unit system in Python from CODATA and asserts agreement:
`the unit system recomputed in Python from CODATA agrees with the solver's to 1e-9 (E_c, Omega_r0, Omega_nu1, Omega_b0)`
[nb05 §5, nb06 §5, nb07 §5]. If a notebook fails there, the binary predates the `hbar` correction of
`2bc936d` (section 5.8, item 7): rebuild it.

#### 6.4.4 One gap solve

```bash
$F gap --form quadratic --param m0=0.05 --param lam=20 --kf 1
```

It solves the gap equation `m = W'(sigma_KS(m, kF)/v)` once at `kF` (and `v`, default 1) for the
potential `W = m0 sigma + (lam/2) sigma^2`, prints every root with `m, sigma8, rho8, P_obs, P_hid,
gap_residual` (16 significant digits) and the selected root. For this case (the repulsive quadratic,
which has three roots) it prints [nb05 §5.5, verbatim]:

```
# potential Quadratic { v0: 0.0, m0: 0.05, lam: 20.0 }, kF = 1e0, v = 1e0, n8 = 1.3509491152311703e-1, plan = Scan { lo: -2.651898230462341, hi: 2.7518982304623405 }
m,sigma8,rho8,P_obs,P_hid,gap_residual
-2.535353916022531e0,-1.292676958011266e-1,1.909782056219713e-1,1.772147779888931e-1,1.671013717773260e-1,8.506e-17
-1.640336879334347e-2,-3.320168439667173e-3,1.012381942988485e-1,3.387489103006236e-2,1.102351846776195e-4,-1.898e-17
2.644093986040535e0,1.297046993020268e-1,2.039272771420881e-1,1.779694075325236e-1,1.682330902102918e-1,0.000e0
# selected (Lowest): m = -1.640336879334347e-2, rho8 = 1.012381942988485e-1, roots = 3
```

**Success:** the roots agree with the independent Python solution (notebook 05 prints the three roots of
both codes; they agree to `1.3e-15` in `rho`) and the lowest-`rho` root is selected. Notebook 05 also
solves the mass term (`m0 = 1`, so `kF = x`) at the fifteen `x = kF/m` of its accuracy table, with the
arguments Python's `repr` gives:

```bash
for x in 1e-08 1e-06 0.0001 0.01 0.2 0.25 0.3 0.6 1.0 3.0 10.0 99.0 101.0 10000.0 1000000.0; do
  $F gap --form mass --param m0=1 --kf $x
done
```

(the rows `sigma8`, `rho8`, `P_obs` of the mass term are `sigma_KS`, `eps_KS`, `P_KS`; they agree with the
independent Python forms to `3.11e-14`: `largest relative difference Rust - Python over these 15 points:
3.11e-14` [nb05 §5.1]).

#### 6.4.5 The command-line contract

The usage the binary prints (to standard error, with exit code 2) on a malformed command line
[file: `fable-cosmology/rust/fable_fermion/src/main.rs`]:

```
usage: fable_fermion fable4d|fable8d --potential mass|lambda-mass|power|expdamp|lorentz|quadratic|explicit [--form NAME] [--param KEY=VALUE ...] [--direction forward|backward] [--a-start A] [--points K] [--out FILE.csv] [--rtol R] [--atol A] [--method bdf|adams] [--branch lowest|positive|negative] [--freeze-hidden] [--no-shoot] [--no-fable] [--omega-b X] [--omega-r X]
       fable_fermion gap --form NAME --param ... --kf KF [--v V]
       fable_fermion --constants | --version
```

| option | meaning | default |
|---|---|---|
| `fable4d`, `fable8d` | the model: stabilized (physical) or unstabilized (the no-go) | required |
| `gap` | solve the gap equation once at `kF` (and `v`) for the potential `--form`: every root with `m, sigma8, rho8, P_obs, P_hid, gap_residual`, then the selected root | — |
| `--potential NAME` | `mass`, `lambda-mass`, `power`, `expdamp`, `lorentz`, `quadratic`, `explicit` | `mass` |
| `--form NAME` | the form of `W` for `--potential explicit`, `--no-shoot` and `gap` | the potential's name |
| `--param KEY=VALUE` | one parameter; repeat for more; a mass may be given in eV as `KEY_ev` or in `E_c` as `KEY` | see below |
| `--direction` | `forward` (from `a_start` to 1) or `backward` (from today; `fable4d` only) | `forward` |
| `--a-start A` | the first scale factor, in `(0, 1)` | `1e-12` |
| `--points K` | output rows, equally spaced in `N = ln A`, first and last included (at least 2) | `2001` |
| `--out FILE.csv` | write the CSV there; **without it the CSV goes to standard output** | standard output |
| `--rtol R`, `--atol A` | CVODE's tolerances | `1e-10`, `1e-12` |
| `--method bdf\|adams` | CVODE's family | `bdf` |
| `--branch` | which gap root when there are several: the lowest energy density, the largest positive or the most negative mass | `lowest` |
| `--freeze-hidden` | `fable8d` with the stabilizer (`H_A` evolved by its equation) | off |
| `--no-shoot` | take the potential's parameters and `kf0` (or `kf0_ev`) as given | shoot |
| `--no-fable` | radiation and baryons only (the controls of the no-go runs) | with the fable |
| `--omega-b X`, `--omega-r X` | override `Omega_b0`, `Omega_r0` | the computed values |
| `--kf KF`, `--v V` | `gap` only: the Fermi momentum (in `E_c`) and the hidden volume factor | —, `1` |

The potentials and their parameters (`W(sigma)` in `E_c^4`; the "split" potentials impose the dark matter
today: the quasiparticles carry `Omega_qp0 = omega_dm` at the mass `m_today`, so `kF0` follows from
`eps_KS(m_today, kF0) = omega_dm`):

| `--potential` | `W(sigma)` | `--param` keys (default) | what is shot so that the budget closes today |
|---|---|---|---|
| `mass` (the author's term) | `m0 sigma` | `m0_ev` (1) | `ln kF0` (the fable is all the non-baryonic matter: Einstein–de Sitter) |
| `lambda-mass` | `V0 + m0 sigma` | `m0_ev` (1), `omega_dm` (0.265) | `V0`, a bare cosmological constant |
| `power` | `m0 sigma + lam sigma^nu` | `m_today_ev` (1), `nu` (0.236), `omega_dm` (0.265) | `U_t = (1 − nu) lam sigma_t^nu`, the condensate today; then `lam = U_t/((1 − nu) sigma_t^nu)`, `m0 = m_today − nu lam sigma_t^(nu−1)` (may be negative) |
| `expdamp` | `V0 + m0 sigma e^(−sigma/s1)` | `m_today_ev` (1), `xt` (1/2.21), `omega_dm` (0.265) | `V0`; `s1 = sigma_t/xt`, `m0 = m_today e^xt/(1 − xt)` |
| `lorentz` | `V0 + m0 sigma/(1 + (sigma/s1)^2)` | `m_today_ev` (1), `xt` (1/1.5), `omega_dm` (0.265) | `V0`; `s1 = sigma_t/xt`, `m0 = m_today (1 + xt^2)^2/(1 − xt^2)` |
| `quadratic` | `V0 + m0 sigma + (lam/2) sigma^2` | `m_today_ev` (1), `gq` (−0.5), `omega_dm` (0.265) | `V0`; `lam = gq m_today/sigma_t`, `m0 = m_today (1 − gq)` |
| `explicit` | the `--form`'s `W` | `m0` or `m0_ev`, `v0`, `lam`, `nu`, `s1` | `ln kF0`, after checking that `rho_f(A = 1; kF0)` is monotonic |

Parameter domains: `power` needs `lam > 0` and `0 < nu < 1`; `expdamp` `m0 > 0`, `s1 > 0` (`0 < xt < 1`);
`lorentz` `s1 > 0`. The gap root is provably unique for `mass`, `lambda-mass`, `power`, `expdamp`,
attractive `quadratic` (`lam <= 0`) and for `lorentz` while `n8 <= s1`; otherwise all roots are found by a
scan and the lowest-energy one is taken.

**The CSV.** A run writes `#` comment lines — the version; a machine-readable `# params:` line with every
normalized parameter (`model, direction, spec, a_start, omega_r0, omega_b0, freeze, branch, lnB_i, lnC_i,
e_c_ev, omega_nu1, rtol, atol, kf0, potential` and the potential's `m0, v0, lam, nu, s1`, as `key=value`);
`# spec:`; one line defining each group of columns — then a header and one row per output point, every
number as `{:.14e}` (15 significant digits). The 47 columns: `N, a, z, t, B, C, H_A, H_B, H_C,
constraint_residual, rho_r, rho_b, rho_f, P_obs_f, P_hid_f, n_f, sigma, m_eff, kF_over_m, w_f, rho_qp, w_qp,
rho_U, w_DE_eff, Omega_r, Omega_b, Omega_f, q_dec, G_ratio, cs2_adiabatic, N_eff_extra, P_stab, Omega_sum,
rho_DE_inf, w_DE_inf, w_DM_intrinsic, w_DM_eff, Q, rho_DE_eff, F_hidden, dm_dN, m_eff_eV, kF_eV, gap_roots,
branch, gap_residual, vac_over_rhoc`. Their meanings:

| column | meaning |
|---|---|
| `N`, `a`, `z` | `ln A`, `A`, `1/A − 1` |
| `t` | the age in `1/H0` (`t(a_start) = 1/(2 H_A(a_start))`, then integrated) |
| `B`, `C` | the hidden scale factors (1 today; 1 throughout in `fable4d`) |
| `H_A`, `H_B`, `H_C` | the expansion rates, in `H0` |
| `constraint_residual` | `(S − 3 rho_hat)/(3 H_A^2)`, `S` the pair sum of the constraint |
| `rho_r`, `rho_b`, `rho_f` | energy densities per 7-volume, in `rho_c0` |
| `P_obs_f`, `P_hid_f` | the fable's pressures along the observed and the hidden directions (`P_x0 = P_hid`) |
| `n_f`, `sigma` | the fable's number density and scalar density `sigma8` per 7-volume, in `E_c^3` |
| `m_eff`, `kF_over_m` | the gap mass in `E_c`; `kF/\|m_eff\|` (`inf` when `m_eff = 0`) |
| `w_f` | `P_obs_f/rho_f`, the fable's own equation of state |
| `rho_qp`, `w_qp` | the quasiparticles: `eps_KS/v` and `P_KS/eps_KS` |
| `rho_U` | the condensate `W − sigma8 W'` (`P_hid_f = −rho_U`: an 8-dimensional vacuum energy) |
| `w_DE_eff`, `rho_DE_eff` | `P_obs_f/rho_DE_eff`, `rho_DE_eff = rho_f − rho_dust0 A^-3 v(1)/v`, `rho_dust0 = m_eff(1) n_f(1)` |
| `Omega_r`, `Omega_b`, `Omega_f`, `Omega_sum` | `rho_X/H_A^2`; `Omega_sum = rho_hat/H_A^2` (1 in `fable4d`) |
| `q_dec` | `−1 − (dH_A/dt)/H_A^2` |
| `G_ratio` | `1/v = G_4(t)/G_4(today)` |
| `cs2_adiabatic` | `(dP_obs_f/dN)/(d rho_f/dN)` along the solution (analytic, with the differentiated gap equation) |
| `N_eff_extra` | `rho_f/rho_nu(1 species)` |
| `P_stab` | `−F/2` in `fable4d` and `--freeze-hidden`; 0 in `fable8d` |
| `rho_DE_inf`, `w_DE_inf` | the dark energy an observer infers: `H_A^2 − Omega_r0 A^-4 − Omega_b0 A^-3 − rho_dust0 A^-3` (cold dark matter subtracted with **today's** mass `m_eff(1)`), and `−1 − (1/3) d ln rho_DE_inf/d ln A` |
| `w_DM_intrinsic`, `w_DM_eff`, `Q` | `P_KS/eps_KS`; `w_DM − sigma_KS (dm/dN)/(3 eps_KS)`; `sigma8 dm/dt`, the energy the condensate hands to the quasiparticles |
| `F_hidden`, `dm_dN` | `rho − 3 P_obs + 2 P_hid` (all sources); `dm_eff/dN` |
| `m_eff_eV`, `kF_eV` | the mass and the Fermi momentum in eV |
| `gap_roots`, `branch`, `gap_residual` | the number of gap roots found; the sign of `m_eff`; `(m − W'(sigma8))/max(\|m\|, S_W'(sigma8))`, `S_W'` the round-off scale of `W'` |
| `vac_over_rhoc` | `DeltaE_vac(m_eff; M = m_eff(1))/v` in `rho_c0`: the renormalized Dirac-sea energy (relativistic Hartree) that the no-sea functional drops; reported, not in the dynamics |

Read the CSV skipping the `#` lines (numpy's `genfromtxt(..., names=True)` would take the first comment
for the header).

**Standard error** carries the run's log, one line each: `# normalization: …` (what was shot, and to what
value), `# ground-state check: …` (split potentials), `# fable today: …`, `# result: …` (`H_A`, `B`, `C`
today, `q0`, the age, the largest constraint and gap residuals), `# a_nr …` (with its class: hot, warm or
cold-like), `# the fable is ultra-relativistic at a_start …`, `# Delta N_eff …` at nucleosynthesis and
recombination, `# stabilizer: …` (`fable4d`), `# unstabilized fable8d (the no-go test): …` (`fable8d`: the `G`
ratio, `H_B/H_A` today, `d ln G/dt` against `1e-13`/yr), `# t(A=1) cross-check: …` (CVODE against
Gauss–Kronrod quadrature, `fable4d`), `# the DM/DE split … is a convention`, a `# stats:` line (CVODE
steps, right-hand-side evaluations, Newton iterations, error-test failures, Jacobian evaluations and wall
time, summed over every integration of the run, shooting included), and the version.

**Exit codes** (checked against the binary): `0` success; `1` a solver or physics error with a one-line
reason starting `fable_fermion:` (the refusals of 6.4.8, CVODE failures, an unknown `gap` form, an
unwritable output file); `2` a usage error (an unknown model, option or potential name, a non-numeric
value, `--points` below 2, `--no-shoot` without `kf0`), with the usage lines printed.

#### 6.4.6 One complete run and its log

The author's mass term at 30 eV, as notebook 05 ran it and printed its whole log [nb05 §5.7, verbatim]:

```
$ fable_fermion fable4d --potential mass --param m0_ev=30 --points 1001 --out results/nb05_fable4d_mass30.csv
  # normalization: closure today (A = B = C = 1): rho_r + rho_b + rho_f = 1; shooting variable [ln kF0 (the fable number density)] = -2.485515249891274e0; rho_f(A=1; kF0) strictly increasing on the Lowest branch over ln kF0 in [-40, 40] (1601 grid points, 0 without a gap solution); unique solution ln kF0 = -2.485515249891274e0
  # fable today (A = 1, v = 1): potential Mass { m0: 12182.181219597018 }, kF0 = 8.3282632088e-2 E_c = 2.050929e-4 eV, m_eff = 1.2182181220e4 E_c = 3.000000e1 eV, rho_qp = 9.5066471258e-1, U = 0.0000000000e0, rho_f = 9.5066471258e-1, w_f = 9.3473556871e-12, gap roots = 1
  # result: H_A(A=1) = 1.000000000000000e0, B(1) = 1.000000000000000e0, C(1) = 1.000000000000000e0, q0 = 5.000460e-1, age t0 = 6.6660643059e-1/H0, max |constraint residual| = 4.303e-16, max |gap residual| = 0.0e0, rows with several gap roots = 0
  # a_nr (kF = |m_eff|) = 6.837070e-6 (z_nr = 1.4626e5), a_eq = 9.2105e-5: WARM / not hot (a_nr between 1e-6 and a_eq)
  # the fable is ultra-relativistic at a_start: kF/|m_eff| = 6.836e6
  # Delta N_eff (fable energy density in units of one massless neutrino species): at BBN (a = 1.6764e-10, T = 1 MeV) = 3.942638e-1, at recombination (a = 9.1659e-4) = 7.048553e1
  # stabilizer: P_stab = -F_hidden/2 ranges over [-2.4622e34, -4.9995e-1] (today -4.999540e-1); it is a Lagrange multiplier with zero energy density and violates the null energy condition along x0 wherever dust is present (rho + P_C = -rho_dust/2)
  # t(A=1) cross-check: CVODE 6.666064305910978e-1 vs Gauss-Kronrod quadrature 6.666064296244345e-1 (rel. diff 1.45e-9, quadrature error estimate 2.4e-14)
  # NOTE: W = m0 sigma alone (no V0): the closure forces Omega_f0 = 1 - Omega_b0 - Omega_r0 = 0.950665: an Einstein-de Sitter-like universe (q0 = 0.5000, +1/2 for pure dust)
  # the DM/DE split (rho_qp = eps/v vs rho_U = W - sigma W') is a convention: the condensate has P = -rho_U in all seven spatial directions, i.e. it is an 8D vacuum energy
  # stats: model=fable4d direction=Forward potential=mass steps=373 rhs_evals=459 nonlin_iters=456 err_test_fails=18 jac_evals=7 wall=0.010s (summed over every CVODE integration of the run, shooting included)
  # fable_fermion 0.1.0, sundials_rs 7.8.0 (pure Rust), CVODE BDF
```

How to read it: the shooting found `ln kF0` uniquely (the energy density today is strictly increasing in
it); today `H_A = B = C = 1` exactly, the constraint holds to `4.303e-16`; the fable became
non-relativistic at `a_nr = 6.84e-6`; it adds `0.394` neutrino species at nucleosynthesis; the stabilizer
is negative throughout; CVODE's age agrees with an independent quadrature to `1.45e-9`; and the run took
373 steps and 10 ms. A `lambda-mass` run at 30 eV logs, among its lines,
`# result: H_A(A=1) = 1.000000000000000e0, B(1) = 1.000000000000000e0, C(1) = 1.000000000000000e0, q0 = -5.284510e-1, age t0 = 9.5124651250e-1/H0, max |constraint residual| = 4.291e-16, max |gap residual| = 0.0e0, rows with several gap roots = 0`
and `# t(A=1) cross-check: CVODE 9.512465124959659e-1 vs Gauss-Kronrod quadrature 9.512465131954438e-1 (rel. diff 7.35e-10, quadrature error estimate 2.4e-14)`.

#### 6.4.7 Every run behind the results of this page

Run from `fable-cosmology/`; each `$ fable_fermion` below is `$F` of 6.4.3 (the notebooks show the
command with the output path relative to `fable-cosmology/` and run it with the absolute path). They are
listed in the order the committed notebooks ran them, by notebook section, each followed by the line it
printed — the `# stats:` line, or the refusal — exactly as the committed notebooks recorded them
(`aca5102`). Every run takes 3 to 42 ms of CVODE wall time. The `fable4d` runs take 373–458 CVODE steps; the
unstabilized `fable8d` runs with a fable take 34762–40808, because they integrate the shear of the hidden
sheet from `a_i` on and shoot on two unknowns (the radiation-plus-baryons control takes 2109, the
radiation-only control, whose hidden sheet stays frozen, 7, and `--freeze-hidden` 395).

```bash
# notebook 05 §5.7: On the pre-universe: the charge is conserved per coordinate volume, the gas cools from 1/3 to 0
$ fable_fermion fable4d --potential mass --param m0_ev=30 --points 1001 --out results/nb05_fable4d_mass30.csv
#   prints: # stats: model=fable4d direction=Forward potential=mass steps=373 rhs_evals=459 nonlin_iters=456 err_test_fails=18 jac_evals=7 wall=0.010s (summed over every CVODE integration of the run, shooting included)

# notebook 05 §5.8: The Dirac-sea energy of a mass-varying fable
$ fable_fermion fable4d --potential power --param nu=0.236 --param m_today_ev=30 --points 1001 --out results/nb05_fable4d_power0.236_m30.csv
#   prints: # stats: model=fable4d direction=Forward potential=power steps=390 rhs_evals=482 nonlin_iters=479 err_test_fails=20 jac_evals=7 wall=0.010s (summed over every CVODE integration of the run, shooting included)

# notebook 06 §5.1: The interval, and why the starting point does not matter
$ fable_fermion fable4d --potential lambda-mass --param m0_ev=30 --a-start 1e-12 --points 1001
#   prints: # stats: model=fable4d direction=Forward potential=lambda-mass steps=430 rhs_evals=542 nonlin_iters=539 err_test_fails=25 jac_evals=8 wall=0.010s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential lambda-mass --param m0_ev=30 --a-start 1e-11 --points 1001
#   prints: # stats: model=fable4d direction=Forward potential=lambda-mass steps=433 rhs_evals=549 nonlin_iters=546 err_test_fails=27 jac_evals=8 wall=0.010s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential lambda-mass --param m0_ev=30 --a-start 1e-10 --points 1001
#   prints: # stats: model=fable4d direction=Forward potential=lambda-mass steps=438 rhs_evals=525 nonlin_iters=522 err_test_fails=20 jac_evals=8 wall=0.010s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable8d --potential lambda-mass --param m0_ev=30 --a-start 1e-12 --points 1001
#   prints: # stats: model=fable8d direction=Forward potential=lambda-mass steps=37544 rhs_evals=42447 nonlin_iters=42339 err_test_fails=654 jac_evals=647 wall=0.040s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable8d --potential lambda-mass --param m0_ev=30 --a-start 1e-11 --points 1001
#   prints: # stats: model=fable8d direction=Forward potential=lambda-mass steps=36759 rhs_evals=41619 nonlin_iters=41511 err_test_fails=618 jac_evals=634 wall=0.039s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable8d --potential lambda-mass --param m0_ev=30 --a-start 1e-10 --points 1001
#   prints: # stats: model=fable8d direction=Forward potential=lambda-mass steps=34762 rhs_evals=39367 nonlin_iters=39262 err_test_fails=576 jac_evals=593 wall=0.037s (summed over every CVODE integration of the run, shooting included)

# notebook 06 §5.2: (a) The author's mass term alone: an Einstein–de Sitter universe with a fable that cools
$ fable_fermion fable4d --potential mass --param m0_ev=1 --points 1001 --out results/nb06_mass_m1_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=mass steps=392 rhs_evals=480 nonlin_iters=477 err_test_fails=20 jac_evals=7 wall=0.010s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential mass --param m0_ev=30 --points 1001 --out results/nb06_mass_m30_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=mass steps=373 rhs_evals=459 nonlin_iters=456 err_test_fails=18 jac_evals=7 wall=0.010s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential mass --param m0_ev=100 --points 1001 --out results/nb06_mass_m100_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=mass steps=387 rhs_evals=467 nonlin_iters=464 err_test_fails=16 jac_evals=7 wall=0.010s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential mass --param m0_ev=1000 --points 1001 --out results/nb06_mass_m1000_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=mass steps=377 rhs_evals=463 nonlin_iters=460 err_test_fails=19 jac_evals=7 wall=0.010s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential mass --param m0_ev=2000 --points 1001 --out results/nb06_mass_m2000_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=mass steps=377 rhs_evals=467 nonlin_iters=464 err_test_fails=18 jac_evals=7 wall=0.010s (summed over every CVODE integration of the run, shooting included)

# notebook 06 §5.3: (b) A mass term plus a bare cosmological constant: ΛCDM with fable dark matter
$ fable_fermion fable4d --potential lambda-mass --param m0_ev=30 --points 1001 --out results/nb06_lm_m30_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=lambda-mass steps=430 rhs_evals=542 nonlin_iters=539 err_test_fails=25 jac_evals=8 wall=0.010s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential lambda-mass --param m0_ev=100 --points 1001 --out results/nb06_lm_m100_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=lambda-mass steps=418 rhs_evals=515 nonlin_iters=512 err_test_fails=21 jac_evals=8 wall=0.010s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential lambda-mass --param m0_ev=1000 --points 1001 --out results/nb06_lm_m1000_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=lambda-mass steps=407 rhs_evals=509 nonlin_iters=506 err_test_fails=21 jac_evals=8 wall=0.009s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential lambda-mass --param m0_ev=2000 --points 1001 --out results/nb06_lm_m2000_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=lambda-mass steps=425 rhs_evals=527 nonlin_iters=524 err_test_fails=21 jac_evals=8 wall=0.010s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential lambda-mass --param m0_ev=30 --param omega_dm=0.265 --a-start 1e-10 --points 701 --out results/nb06_fable4d_mass30eV.csv
#   prints: # stats: model=fable4d direction=Forward potential=lambda-mass steps=429 rhs_evals=548 nonlin_iters=545 err_test_fails=29 jac_evals=8 wall=0.008s (summed over every CVODE integration of the run, shooting included)

# notebook 06 §5.4: (c) Potentials with which the fable supplies the dark energy itself
$ fable_fermion fable4d --potential power --param nu=0.236 --param m_today_ev=30 --points 1001 --out results/nb06_power_0.236_m30_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=power steps=390 rhs_evals=482 nonlin_iters=479 err_test_fails=20 jac_evals=7 wall=0.011s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential power --param nu=0.236 --param m_today_ev=100 --points 1001 --out results/nb06_power_0.236_m100_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=power steps=401 rhs_evals=505 nonlin_iters=502 err_test_fails=23 jac_evals=7 wall=0.010s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential power --param nu=0.5 --param m_today_ev=30 --points 1001 --out results/nb06_power_0.5_m30_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=power steps=430 rhs_evals=551 nonlin_iters=548 err_test_fails=26 jac_evals=8 wall=0.021s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential power --param nu=0.5 --param m_today_ev=100 --points 1001 --out results/nb06_power_0.5_m100_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=power steps=433 rhs_evals=545 nonlin_iters=542 err_test_fails=24 jac_evals=8 wall=0.027s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential expdamp --param xt=0.4524886877828054 --param m_today_ev=30 --points 1001 --out results/nb06_expdamp_m30_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=expdamp steps=423 rhs_evals=527 nonlin_iters=524 err_test_fails=21 jac_evals=8 wall=0.019s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential expdamp --param xt=0.4524886877828054 --param m_today_ev=100 --points 1001 --out results/nb06_expdamp_m100_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=expdamp steps=434 rhs_evals=542 nonlin_iters=539 err_test_fails=23 jac_evals=8 wall=0.019s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential quadratic --param gq=-0.5 --param m_today_ev=30 --points 1001 --out results/nb06_quadratic_m30_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=quadratic steps=451 rhs_evals=562 nonlin_iters=559 err_test_fails=23 jac_evals=8 wall=0.012s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential quadratic --param gq=-0.5 --param m_today_ev=100 --points 1001 --out results/nb06_quadratic_m100_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=quadratic steps=451 rhs_evals=558 nonlin_iters=555 err_test_fails=22 jac_evals=8 wall=0.011s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential power --param m_today_ev=100 --param nu=0.5 --param omega_dm=0.55 --a-start 1e-10 --points 701 --out results/nb06_fable4d_power.csv
#   prints: # stats: model=fable4d direction=Forward potential=power steps=379 rhs_evals=483 nonlin_iters=480 err_test_fails=24 jac_evals=7 wall=0.008s (summed over every CVODE integration of the run, shooting included)

# notebook 06 §5.7: How heavy must a fable that is all of the dark matter be?  `ΔN_eff`, free streaming, phase space
$ fable_fermion fable4d --potential power --param nu=0.236 --param m_today_ev=1 --points 1001 --out results/nb06_power_0.236_m1_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=power steps=397 rhs_evals=487 nonlin_iters=484 err_test_fails=18 jac_evals=7 wall=0.011s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential power --param nu=0.5 --param m_today_ev=1 --points 1001 --out results/nb06_power_0.5_m1_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=power steps=429 rhs_evals=553 nonlin_iters=550 err_test_fails=28 jac_evals=8 wall=0.019s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential expdamp --param xt=0.4524886877828054 --param m_today_ev=1 --points 1001 --out results/nb06_expdamp_m1_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=expdamp steps=428 rhs_evals=560 nonlin_iters=557 err_test_fails=32 jac_evals=8 wall=0.018s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential quadratic --param gq=-0.5 --param m_today_ev=1 --points 1001 --out results/nb06_quadratic_m1_4d.csv
#   prints: # stats: model=fable4d direction=Forward potential=quadratic steps=444 rhs_evals=576 nonlin_iters=573 err_test_fails=30 jac_evals=8 wall=0.011s (summed over every CVODE integration of the run, shooting included)

# notebook 06 §5.8: (d) Without the stabilizer: the hidden sheet moves and the Newton constant varies
$ fable_fermion fable8d --potential mass --param m0_ev=1 --points 1001 --out results/nb06_mass_m1_8d.csv
#   prints: # stats: model=fable8d direction=Forward potential=mass steps=37019 rhs_evals=41186 nonlin_iters=41081 err_test_fails=499 jac_evals=634 wall=0.039s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable8d --potential mass --param m0_ev=100 --points 1001 --out results/nb06_mass_m100_8d.csv
#   prints: # stats: model=fable8d direction=Forward potential=mass steps=40808 rhs_evals=45860 nonlin_iters=45758 err_test_fails=474 jac_evals=702 wall=0.042s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable8d --potential lambda-mass --param m0_ev=30 --points 1001 --out results/nb06_lm_m30_8d.csv
#   prints: # stats: model=fable8d direction=Forward potential=lambda-mass steps=37544 rhs_evals=42447 nonlin_iters=42339 err_test_fails=654 jac_evals=647 wall=0.039s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable8d --potential lambda-mass --param m0_ev=1000 --points 1001 --out results/nb06_lm_m1000_8d.csv
#   prints: # stats: model=fable8d direction=Forward potential=lambda-mass steps=38558 rhs_evals=42762 nonlin_iters=42657 err_test_fails=595 jac_evals=669 wall=0.040s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable8d --no-fable --omega-b 0 --points 1001 --out results/nb06_radiation_only_8d.csv
#   prints: # stats: model=fable8d direction=Forward potential=none steps=7 rhs_evals=13 nonlin_iters=7 err_test_fails=0 jac_evals=2 wall=0.008s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable8d --no-fable --points 1001 --out results/nb06_radiation_baryons_8d.csv
#   prints: # stats: model=fable8d direction=Forward potential=none steps=2109 rhs_evals=2379 nonlin_iters=2370 err_test_fails=37 jac_evals=38 wall=0.010s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable8d --potential lambda-mass --param m0_ev=30 --freeze-hidden --points 1001
#   prints: # stats: model=fable8d direction=Forward potential=lambda-mass steps=395 rhs_evals=475 nonlin_iters=472 err_test_fails=15 jac_evals=7 wall=0.011s (summed over every CVODE integration of the run, shooting included)

# notebook 06 §5.9: The cases the solver refuses, and why
$ fable_fermion fable4d --potential lorentz --points 1001
#   prints: exit code 1: fable_fermion: rho_hat = H_A^2 <= 0 from N = -0.7597808064 (a = 0.4677689478) on: the Kohn-Sham ground state has negative energy there (m_eff = -3.802078e-2, sigma8 = -9.789374e-4, rho_f = -4.830421e-1 (U = -4.847891e-1) against rho_r + rho_b = 4.830421e-1); H_A^2 = rho_hat is impossible (the onset located past the last accepted CVODE step and bisected)
$ fable_fermion fable4d --potential quadratic --param gq=0.5 --points 1001
#   prints: exit code 1: fable_fermion: gap-branch jump at N = -0.0037262796 (a = 0.9962806544): a first-order transition of the Kohn-Sham ground state, the lowest-energy gap root jumps from the branch m_eff = -1.518260e0 (rho_f = 6.856759e-1) to the branch m_eff = 4.083552e2 (rho_f = 9.536521e-1); the right-hand side is discontinuous there, and energy conservation across it would need the Maxwell construction, which this solver does not implement (the transition detected inside the right-hand side and bisected in N to adjacent doubles)
$ fable_fermion fable8d --potential mass --direction backward
#   prints: exit code 1: fable_fermion: fable8d runs forward only (design review E4): backward in time the shear modes grow as A^-3 v^-1 relative to H_A ~ A^-2, the solution runs to the 8D Kasner point H_B/H_A = -0.2929 and the constraint drifts to O(1); use fable4d --direction backward

# notebook 07 §5.18: The cosmological runs follow the homogeneous Kohn–Sham ground state at every epoch
$ fable_fermion fable4d --potential power --param nu=0.236 --param m_today_ev=30 --points 201
#   prints: # stats: model=fable4d direction=Forward potential=power steps=387 rhs_evals=488 nonlin_iters=485 err_test_fails=22 jac_evals=7 wall=0.003s (summed over every CVODE integration of the run, shooting included)
$ fable_fermion fable4d --potential quadratic --param gq=-0.5 --param m_today_ev=30 --points 201
#   prints: # stats: model=fable4d direction=Forward potential=quadratic steps=458 rhs_evals=570 nonlin_iters=567 err_test_fails=26 jac_evals=8 wall=0.003s (summed over every CVODE integration of the run, shooting included)
```

#### 6.4.8 The scans, and the refusals

The 90 scan runs of section 4.7.8 (notebook 06, §5.6; the CSV goes to standard output, 401 rows;
each run is re-computed by the independent implementation as it runs; their `# stats:` lines are not
printed):

```bash
# notebook 06 §5.6: Parameter scans: where does a dark-energy fable stay massive through the matter era?
$ fable_fermion fable4d --potential power --param nu=0.05 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param nu=0.1 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param nu=0.15 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param nu=0.2 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param nu=0.25 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param nu=0.3 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param nu=0.35 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param nu=0.4 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param nu=0.45 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param nu=0.5 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param nu=0.55 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param nu=0.6 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param nu=0.65 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.95 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.85 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.75 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.65 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.55 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.45 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.35 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.25 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.15 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.05 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.1 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.2 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.3 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.4 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.5 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.6 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.7 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.8 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.9 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.265 --param nu=0.3 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.35 --param nu=0.3 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.45 --param nu=0.3 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.55 --param nu=0.3 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.65 --param nu=0.3 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.8 --param nu=0.3 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.265 --param nu=0.5 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.35 --param nu=0.5 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.45 --param nu=0.5 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.5 --param nu=0.5 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.55 --param nu=0.5 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.65 --param nu=0.5 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.8 --param nu=0.5 --param m_today_ev=1000 --points 401
$ fable_fermion fable4d --potential power --param nu=0.05 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param nu=0.1 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param nu=0.15 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param nu=0.2 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param nu=0.25 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param nu=0.3 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param nu=0.35 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param nu=0.4 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param nu=0.45 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param nu=0.5 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param nu=0.55 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param nu=0.6 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param nu=0.65 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.95 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.85 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.75 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.65 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.55 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.45 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.35 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.25 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.15 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential quadratic --param gq=-0.05 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.1 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.2 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.3 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.4 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.5 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.6 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.7 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.8 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential expdamp --param xt=0.9 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.265 --param nu=0.3 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.35 --param nu=0.3 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.45 --param nu=0.3 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.55 --param nu=0.3 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.65 --param nu=0.3 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.8 --param nu=0.3 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.265 --param nu=0.5 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.35 --param nu=0.5 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.45 --param nu=0.5 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.5 --param nu=0.5 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.55 --param nu=0.5 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.65 --param nu=0.5 --param m_today_ev=100 --points 401
$ fable_fermion fable4d --potential power --param omega_dm=0.8 --param nu=0.5 --param m_today_ev=100 --points 401
```

**The refusals.** Three runs must fail, and the notebook checks that they do, with exit code 1 and the
expected reason (`all three refused with exit code 1 and the expected reason` [nb06 §5.9]); their
messages are in the block of 6.4.7 and discussed in section 4.7.11. They are the solver saying no where
the physics or the numerics would be meaningless: `lorentz` (the Kohn–Sham ground state has negative
energy from `a = 0.4677689478` on, so `H_A^2 = rho_hat` is impossible); the repulsive quadratic (a
first-order transition at `a = 0.9962806544`, where energy conservation would need the Maxwell
construction, which the solver does not implement); and `fable8d --direction backward` (the shear
modes grow backward and the solution runs to the 8D Kasner point). The first two are located inside the
right-hand side and bisected to adjacent doubles, so the message and the onset do not depend on
`--points`.

#### 6.4.9 The classical solver `fable_cosmo` of Effort 0: its command line and every run

The notebooks 01–04 drive the solver of the classical fields, `fable-cosmology/rust/fable_cosmo`
(built and tested exactly as in 6.4.1–6.4.2, from inside its own folder; `fable_cosmo 0.1.0, sundials_rs
7.8.0 (pure Rust), CVODE BDF`). Its usage [file: `fable-cosmology/rust/fable_cosmo/src/main.rs`]:

```
usage: fable_cosmo <scalar-flrw|scalar-cpl|spinor-flrw|scalar-pre|scalar-pre-x0> [--potential NAME] [--param KEY=VALUE ...] [--n0 X0] [--n1 X1] [--points K] [--out FILE.csv] [--no-normalize] [--grid N] [--x0min A] [--x0max B] [--profile-out FILE.csv] [--rtol R] [--atol A] [--method bdf|adams]
       fable_cosmo --version
```

The models are Model A (`scalar-flrw`: `fableScalar` in the standard 4-dimensional reference cosmology),
Model A′ (`scalar-cpl`: the same as a test field on the Unite CPL background), Model B (`spinor-flrw`: the
classical spinor fable in the reference cosmology), Model C (`scalar-pre`: `fableScalar` on the
8-dimensional pre-universe itself) and Model D (`scalar-pre-x0`, with `--grid`, `--x0min`, `--x0max` and
`--profile-out` for its dependence on `x0`); `--n0`, `--n1` set the range of the independent variable,
`--no-normalize` takes the potential's scale as given. Exit code 1 is a solver or physics error (and also an
unknown model or potential name), 2 a malformed command line. Every run the committed notebooks 01–04
made, with the line it printed, run from `fable-cosmology/` [the committed notebooks 01–04, verbatim]:

```bash
# notebook 01 §5.1: The exponential potential, `V = V0 e^{−λφ}`, for λ = 0.5, 1, 1.5, 2 and 3
$ fable_cosmo scalar-flrw --potential exp --param lambda=0.5 --out results/nb01_exp_lambda0.5.csv
#   prints: # stats: model=scalar-flrw steps=384 rhs_evals=424 nonlin_iters=421 err_test_fails=5
$ fable_cosmo scalar-flrw --potential exp --param lambda=1 --out results/nb01_exp_lambda1.csv
#   prints: # stats: model=scalar-flrw steps=385 rhs_evals=434 nonlin_iters=431 err_test_fails=5
$ fable_cosmo scalar-flrw --potential exp --param lambda=1.5 --out results/nb01_exp_lambda1.5.csv
#   prints: # stats: model=scalar-flrw steps=399 rhs_evals=452 nonlin_iters=449 err_test_fails=5
$ fable_cosmo scalar-flrw --potential exp --param lambda=2 --out results/nb01_exp_lambda2.csv
#   prints: # stats: model=scalar-flrw steps=433 rhs_evals=498 nonlin_iters=495 err_test_fails=8
$ fable_cosmo scalar-flrw --potential exp --param lambda=3 --out results/nb01_exp_lambda3.csv
#   prints: exit code 1: fable_cosmo: normalisation cannot bracket Omega_phi = 0.699916: Omega(10^-6 V) = 0.0000011107972084367645, Omega(10^6 V) = 0.3375115141492524; choose the scale by hand and pass --no-normalize
$ fable_cosmo scalar-flrw --potential exp --param lambda=3 --no-normalize --param v0=1e6 --out results/nb01_exp_lambda3_scaling.csv
#   prints: # stats: model=scalar-flrw steps=662 rhs_evals=697 nonlin_iters=696 err_test_fails=4

# notebook 01 §5.2: The inverse power potential, `V = V0 φ^{−α}`, α = 1: is the tracker joined?
$ fable_cosmo scalar-flrw --potential invpower --param alpha=1 --out results/nb01_invpower_alpha1.csv
#   prints: # stats: model=scalar-flrw steps=430 rhs_evals=493 nonlin_iters=490 err_test_fails=9
$ fable_cosmo scalar-flrw --potential invpower --param alpha=1 --n0 -25 --points 2501 --out results/nb01_invpower_alpha1_n0-25.csv
#   prints: # stats: model=scalar-flrw steps=517 rhs_evals=619 nonlin_iters=616 err_test_fails=19

# notebook 01 §5.3: The pseudo-Nambu–Goldstone potential, the hilltop, and the constant (the control)
$ fable_cosmo scalar-flrw --potential pngb --param f=1 --out results/nb01_pngb_f1.csv
#   prints: # stats: model=scalar-flrw steps=312 rhs_evals=357 nonlin_iters=354 err_test_fails=5
$ fable_cosmo scalar-flrw --potential pngb --param f=0.5 --param phi_i=0.3 --out results/nb01_pngb_f0.5.csv
#   prints: # stats: model=scalar-flrw steps=313 rhs_evals=356 nonlin_iters=353 err_test_fails=3
$ fable_cosmo scalar-flrw --potential hilltop --param mu=3 --out results/nb01_hilltop_mu3.csv
#   prints: # stats: model=scalar-flrw steps=305 rhs_evals=352 nonlin_iters=349 err_test_fails=4
$ fable_cosmo scalar-flrw --potential const --out results/nb01_const.csv
#   prints: # stats: model=scalar-flrw steps=306 rhs_evals=370 nonlin_iters=367 err_test_fails=13

# notebook 01 §5.4: Model A′: the exponential potential as a test field on the Unite CPL background
$ fable_cosmo scalar-cpl --potential exp --param lambda=1 --out results/nb01_cpl_exp_lambda1.csv
#   prints: # stats: model=scalar-cpl steps=384 rhs_evals=436 nonlin_iters=433 err_test_fails=6
$ fable_cosmo scalar-cpl --potential exp --param lambda=2 --out results/nb01_cpl_exp_lambda2.csv
#   prints: exit code 1: fable_cosmo: normalisation cannot bracket rho_phi(a=1) = 2.099748 (= 3 Omega_DE): rho_phi(10^-6 V) = 0.0000009999995795872962, rho_phi(10^6 V) = 1.0248972437664063; choose the scale by hand and pass --no-normalize
$ fable_cosmo scalar-cpl --potential exp --param lambda=2 --no-normalize --param v0=10 --out results/nb01_cpl_exp_lambda2_hand.csv
#   prints: # stats: model=scalar-cpl steps=459 rhs_evals=517 nonlin_iters=514 err_test_fails=7

# notebook 01 §5.9: A finer scan in λ, to answer "which λ" precisely
$ fable_cosmo scalar-flrw --potential exp --param lambda=0.5
#   prints: # stats: model=scalar-flrw steps=384 rhs_evals=424 nonlin_iters=421 err_test_fails=5
$ fable_cosmo scalar-flrw --potential exp --param lambda=0.6
#   prints: # stats: model=scalar-flrw steps=366 rhs_evals=415 nonlin_iters=412 err_test_fails=6
$ fable_cosmo scalar-flrw --potential exp --param lambda=0.7
#   prints: # stats: model=scalar-flrw steps=365 rhs_evals=410 nonlin_iters=407 err_test_fails=4
$ fable_cosmo scalar-flrw --potential exp --param lambda=0.8
#   prints: # stats: model=scalar-flrw steps=368 rhs_evals=414 nonlin_iters=411 err_test_fails=4
$ fable_cosmo scalar-flrw --potential exp --param lambda=0.9
#   prints: # stats: model=scalar-flrw steps=372 rhs_evals=422 nonlin_iters=419 err_test_fails=5
$ fable_cosmo scalar-flrw --potential exp --param lambda=1.0
#   prints: # stats: model=scalar-flrw steps=385 rhs_evals=434 nonlin_iters=431 err_test_fails=5
$ fable_cosmo scalar-flrw --potential exp --param lambda=1.1
#   prints: # stats: model=scalar-flrw steps=388 rhs_evals=437 nonlin_iters=434 err_test_fails=5
$ fable_cosmo scalar-flrw --potential exp --param lambda=1.2
#   prints: # stats: model=scalar-flrw steps=391 rhs_evals=440 nonlin_iters=437 err_test_fails=5
$ fable_cosmo scalar-flrw --potential exp --param lambda=1.3
#   prints: # stats: model=scalar-flrw steps=411 rhs_evals=461 nonlin_iters=458 err_test_fails=6
$ fable_cosmo scalar-flrw --potential exp --param lambda=1.4
#   prints: # stats: model=scalar-flrw steps=421 rhs_evals=466 nonlin_iters=463 err_test_fails=5
$ fable_cosmo scalar-flrw --potential exp --param lambda=1.5
#   prints: # stats: model=scalar-flrw steps=399 rhs_evals=452 nonlin_iters=449 err_test_fails=5
$ fable_cosmo scalar-flrw --potential exp --param lambda=1.6
#   prints: # stats: model=scalar-flrw steps=389 rhs_evals=440 nonlin_iters=437 err_test_fails=4
$ fable_cosmo scalar-flrw --potential exp --param lambda=1.7
#   prints: # stats: model=scalar-flrw steps=435 rhs_evals=483 nonlin_iters=480 err_test_fails=5
$ fable_cosmo scalar-flrw --potential exp --param lambda=1.8
#   prints: # stats: model=scalar-flrw steps=409 rhs_evals=465 nonlin_iters=462 err_test_fails=7
$ fable_cosmo scalar-flrw --potential exp --param lambda=1.9
#   prints: # stats: model=scalar-flrw steps=436 rhs_evals=492 nonlin_iters=489 err_test_fails=7
$ fable_cosmo scalar-flrw --potential exp --param lambda=2.0
#   prints: # stats: model=scalar-flrw steps=433 rhs_evals=498 nonlin_iters=495 err_test_fails=8

# notebook 02 §5.1: The mass term: dust, exactly
$ fable_cosmo spinor-flrw --potential mass --out results/nb02_mass.csv
#   prints: # stats: model=spinor-flrw steps=811 rhs_evals=869 nonlin_iters=866 err_test_fails=3

# notebook 02 §5.2: `lambda-mass`: dust plus a bare cosmological constant
$ fable_cosmo spinor-flrw --potential lambda-mass --param v0=0.7 --param m=0.3 --out results/nb02_lambda-mass.csv
#   prints: # stats: model=spinor-flrw steps=811 rhs_evals=869 nonlin_iters=866 err_test_fails=3

# notebook 02 §5.3: Power laws: `V = m s + λ s^n`, n = 0.236, 0.5, 0.9
$ fable_cosmo spinor-flrw --potential power --param n=0.236 --out results/nb02_power_n0.236.csv
#   prints: # stats: model=spinor-flrw steps=811 rhs_evals=869 nonlin_iters=866 err_test_fails=3
$ fable_cosmo spinor-flrw --potential power --param n=0.5 --out results/nb02_power_n0.5.csv
#   prints: # stats: model=spinor-flrw steps=811 rhs_evals=869 nonlin_iters=866 err_test_fails=3
$ fable_cosmo spinor-flrw --potential power --param n=0.9 --out results/nb02_power_n0.9.csv
#   prints: # stats: model=spinor-flrw steps=811 rhs_evals=869 nonlin_iters=866 err_test_fails=3
$ fable_cosmo spinor-flrw --potential power --param n=0.236 --n1 6 --points 1301 --out results/nb02_power_n0.236_future.csv
#   prints: # stats: model=spinor-flrw steps=1257 rhs_evals=1390 nonlin_iters=1387 err_test_fails=10

# notebook 02 §5.4: The potentials that cross the phantom divide: `lorentz`, `expdamp`, `hilltop`
$ fable_cosmo spinor-flrw --potential lorentz --param v0=1 --param m=1 --param s1=1.5 --out results/nb02_lorentz.csv
#   prints: # stats: model=spinor-flrw steps=811 rhs_evals=869 nonlin_iters=866 err_test_fails=3
$ fable_cosmo spinor-flrw --potential expdamp --param v0=1.566 --param m=0.839 --param s1=2.21 --no-normalize --out results/nb02_expdamp_ref.csv
#   prints: # stats: model=spinor-flrw steps=811 rhs_evals=869 nonlin_iters=866 err_test_fails=3
$ fable_cosmo spinor-flrw --potential expdamp --param v0=1.566 --param m=0.839 --param s1=1.5 --out results/nb02_expdamp_s1.5.csv
#   prints: # stats: model=spinor-flrw steps=811 rhs_evals=869 nonlin_iters=866 err_test_fails=3
$ fable_cosmo spinor-flrw --potential expdamp --param v0=1.566 --param m=0.839 --param s1=3.0 --out results/nb02_expdamp_s3.csv
#   prints: # stats: model=spinor-flrw steps=811 rhs_evals=869 nonlin_iters=866 err_test_fails=3
$ fable_cosmo spinor-flrw --potential hilltop --param v0=1 --param mu=0.05 --param sstar=1.5 --out results/nb02_hilltop_default_start.csv
#   prints: exit code 1: fable_cosmo: V(s) = -184913370713936540 is not positive at the start (s = 1.3188e9 at N0 = -7): rho_Psi = V(s) must be positive; this potential is only valid at later times -- start at a larger --n0 (the Lorentz potential is positive everywhere)
$ fable_cosmo spinor-flrw --potential hilltop --param v0=1 --param mu=0.05 --param sstar=1.5 --n0 -0.5 --out results/nb02_hilltop.csv
#   prints: # stats: model=spinor-flrw steps=122 rhs_evals=138 nonlin_iters=135 err_test_fails=2

# notebook 03 §5.1: Model C: the quadratic potential, `V = ½ m² φ²`, m = 1, φ_i = 1, to x4 = 100
$ fable_cosmo scalar-pre --potential quadratic --param m=1 --param phi_i=1 --n1 100 --points 2001 --out results/nb03_modelC_quadratic.csv
#   prints: # stats: model=scalar-pre steps=965 rhs_evals=1163 nonlin_iters=1160 err_test_fails=40

# notebook 03 §5.2: Model C: the quartic potential, `V = ¼ λ φ⁴`, λ = 1, and the constant potential
$ fable_cosmo scalar-pre --potential quartic --param lambda=1 --n1 100 --points 2001 --out results/nb03_modelC_quartic.csv
#   prints: # stats: model=scalar-pre steps=2974 rhs_evals=3832 nonlin_iters=3829 err_test_fails=223
$ fable_cosmo scalar-pre --potential const --n1 100 --points 2001 --out results/nb03_modelC_const.csv
#   prints: # stats: model=scalar-pre steps=6 rhs_evals=9 nonlin_iters=6 err_test_fails=0

# notebook 03 §5.3: Cross-check of Model C with scipy (DOP853, rtol = 1e−11)
$ fable_cosmo scalar-pre --potential quartic --param lambda=1 --n1 100 --points 2001 --rtol 1e-12 --atol 1e-14 --out results/nb03_modelC_quartic_tight.csv
#   prints: # stats: model=scalar-pre steps=4247 rhs_evals=5187 nonlin_iters=5185 err_test_fails=242

# notebook 03 §5.4: Model D: a profile along the hidden coordinate, ε = 0.05 and ε = 0.5
$ fable_cosmo scalar-pre-x0 --potential quadratic --param m=1 --param eps=0.05 --grid 61 --n1 30 --points 301 --profile-out results/nb03_profile_eps0.05.csv --out results/nb03_modelD_eps0.05.csv
#   prints: # stats: model=scalar-pre-x0 steps=294095 rhs_evals=321641 nonlin_iters=321639 err_test_fails=2864
$ fable_cosmo scalar-pre-x0 --potential quadratic --param m=1 --param eps=0.5 --grid 61 --n1 30 --points 301 --profile-out results/nb03_profile_eps0.5.csv --out results/nb03_modelD_eps0.5.csv
#   prints: # stats: model=scalar-pre-x0 steps=329282 rhs_evals=368139 nonlin_iters=368138 err_test_fails=5712

# notebook 04 §5.1: The best cases, re-run
$ fable_cosmo scalar-flrw --potential exp --param lambda=1 --out results/nb04_exp_lambda1.csv
#   prints: # stats: model=scalar-flrw steps=385 rhs_evals=434 nonlin_iters=431 err_test_fails=5
$ fable_cosmo scalar-flrw --potential exp --param lambda=1.5 --out results/nb04_exp_lambda1.5.csv
#   prints: # stats: model=scalar-flrw steps=399 rhs_evals=452 nonlin_iters=449 err_test_fails=5
$ fable_cosmo spinor-flrw --potential expdamp --param v0=1.566 --param m=0.839 --param s1=2.21 --no-normalize --out results/nb04_expdamp_ref.csv
#   prints: # stats: model=spinor-flrw steps=811 rhs_evals=869 nonlin_iters=866 err_test_fails=3
$ fable_cosmo spinor-flrw --potential expdamp --param v0=1.566 --param m=0.839 --param s1=3.0 --out results/nb04_expdamp_s3.csv
#   prints: # stats: model=spinor-flrw steps=811 rhs_evals=869 nonlin_iters=866 err_test_fails=3
$ fable_cosmo spinor-flrw --potential lambda-mass --param v0=0.7 --param m=0.3 --out results/nb04_lambda-mass.csv
#   prints: # stats: model=spinor-flrw steps=811 rhs_evals=869 nonlin_iters=866 err_test_fails=3
$ fable_cosmo spinor-flrw --potential power --param n=0.236 --out results/nb04_power_n0.236.csv
#   prints: # stats: model=spinor-flrw steps=811 rhs_evals=869 nonlin_iters=866 err_test_fails=3
$ fable_cosmo spinor-flrw --potential mass --out results/nb04_mass.csv
#   prints: # stats: model=spinor-flrw steps=811 rhs_evals=869 nonlin_iters=866 err_test_fails=3
```

The three refusals are deliberate: an exponential potential with `lambda = 3` cannot reach the dark-energy
fraction today (the scaling solution caps it at `3/lambda^2`), nor can `lambda = 2` on the CPL background,
so each is re-run with the scale chosen by hand (`--no-normalize`); and a potential that is negative at the
start is refused with the start to be moved later.

### 6.5 The independent Python implementation, and comparing results

```bash
cd "$(git rev-parse --show-toplevel)"
fable-cosmology/.venv/Scripts/python.exe fable-cosmology/fermion/crosscheck.py --jobs 6    # .venv/bin/python on Linux/macOS
```

- **What it does** [file: its docstring]. An independent implementation of `fable4d` and `fable8d` that
  shares no code with the Rust crate: it recomputes the unit system from CODATA (one CODATA-2018 `hbar`,
  as the solver since `2bc936d`); evaluates every Fermi-sea integral by adaptive quadrature
  (`scipy.integrate.quad`, `epsrel = 1e-12`, split at `k = |m|`), not the closed forms; solves every gap
  by `brentq` on the documented brackets; integrates `fable8d` with DOP853 at `rtol = 1e-11` (and
  `fable4d` algebraically). It runs 13 cases with the solver (`mass` at 1 and 100 eV, `lambda-mass` at
  30 eV, `power` `nu = 0.236`, `expdamp`, `quadratic` `gq = −0.5`, each as `fable4d` and `fable8d`, and
  `lambda-mass` 30 eV `fable8d --freeze-hidden`), regenerating their CSVs into the ignored
  `fable-cosmology/fermion/dev/`, reads each CSV's `# params:` line, re-computes the run on the same
  grid, and compares `max |Delta w_f|`, `max |Delta H_A|/H_A`, `max |Delta B|/B`,
  `max |Delta G_ratio|/G_ratio`; it also checks, independently of the Rust shooting, that
  `H_A(A = 1) = 1` and `B(1) = C(1) = 1`. `--jobs N` is the number of worker processes (default 4).
- **What it prints.** A `units:` line (`Omega_r0` and `E_c` of Python and Rust), one row per case
  (`case, max|dw_f|, max|dH_A|/H, max|dB|/B, max|dG|/G, H_A(1)py, B(1)py, nfev, secs`), and
  `CROSSCHECK PASSED: every difference < 1e-06`.
- **How long.** About 10 s.
- **Success and failure.** Success is `CROSSCHECK PASSED` and exit code 0. Any difference above `1e-6`,
  or `H_A(1)`, `B(1)` not 1, prints `<-- FAIL` on that row and `CROSSCHECK FAILED: some difference exceeds
  1e-6 (or H_A(1), B(1) != 1)`, and exits with code 1. The largest difference on 2026-09-24 was `1.1e-8`
  (`|dG|/G` of the `lambda-mass 30 eV` `fable8d` case), recorded in `c5892bd` (below `1e-8` then) and
  `2bc936d` (`1.1e-8` after the fixes).

**Notebook 06 applies the same independent functions to every run** it makes (`independent
implementation imported from fermion/crosscheck.py`, `crosscheck.units() agrees with the solver's unit
system to 1e-9` [nb06 §5]) and prints, per run, the differences and the conservation residual of the
independently computed fluid, ending `largest difference over the 29 kept runs: 1.08e-08;  over the 90 scan
runs: 4.43e-09;  largest conservation residual of the independent fluid: 1.24e-07` [nb06 §5.10]
(section 4.7.12).

**Comparing a re-run with the committed results.** Every CSV and PNG under `fable-cosmology/results/`
is committed as evidence. After a re-run,

```bash
cd "$(git rev-parse --show-toplevel)"
git diff --stat -- fable-cosmology/results          # lists every result file whose bytes changed
git status --short -- fable-cosmology/results
```

lists what changed; on every recorded re-run it listed **nothing** (all 59 result files of notebooks
01–04 byte-identical on 2026-09-24 and 2026-09-25; the result files of notebooks 05, 06 and 07 written
byte-identically by two successive runs: 63 of 05 and 06, 27 of 07). For a CSV that did change, compare
it column by column with this script (save it as `compare_csv.py` and run it from the repository root
with the file's path, for example
`fable-cosmology/.venv/Scripts/python.exe compare_csv.py fable-cosmology/results/nb06_lm_m30_4d.csv`):

```python
import csv, io, math, subprocess, sys
path = sys.argv[1].replace('\\', '/')        # a path relative to the repository root
keep = lambda rows: [r for r in rows if r and not r[0].startswith('#')]    # fable_fermion CSVs start with '#' lines
old = keep(csv.reader(io.StringIO(subprocess.run(['git', 'show', f'HEAD:{path}'], capture_output=True, text=True, check=True).stdout)))
new = keep(csv.reader(open(path, newline='')))
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

It prints one line per column, `max |difference| = …` (text columns are `(not numeric)`).

### 6.6 The wall-state solver, its derivation and its Mathematica checks

The discrete states of the fermion fable along the hidden coordinate `x0` (section 4.6). Run from
`fable-cosmology/fermion/`, with the Python of the virtual environment:

```bash
cd "$(git rev-parse --show-toplevel)/fable-cosmology/fermion"
PY=../.venv/Scripts/python.exe        # ../.venv/bin/python on Linux/macOS
```

#### 6.6.1 The derivation (Mathematica)

```bash
wolframscript -file waveguide_derivation.wls > waveguide_derivation.log
```

- **What it does.** Loads Input cells 1–117 of the notebook (with `DumpSave` blocked, so nothing is
  written into `claude-fable/`), and derives the wall problem from the notebook's own objects (`T16`,
  `sigma16`, `gammaCurvedCanonical`, `GammaSpinCanonical`, `cfDcov16`, `gCanonical`,
  `RicciScalarCanonical`, `eta4488`): the rescaling and the proper distance, the reduction of the 16
  components to eight 2×2 blocks, the wall conditions, the symmetries and degeneracies, the endpoints and
  the exact solutions (section 4.6.3). Section 8 of the script (re)writes the committed
  `fermion/waveguide_T16.json` (the notebook's `T16[0..8]`, `sigma16` and the block basis `U`, 29 KB),
  byte-identically.
- **How long.** 162.8 s in the committed run (`total time 162.8 s`, loading `125. s`); 171.4 s in the first
  committed run (`18a2501`).
- **What it prints** [file: `fable-cosmology/fermion/waveguide_derivation.log`]: a header
  (`waveguide_derivation.wls   2026-09-25 00:06:38`, the Mathematica version, the notebook's path),
  `[load] DumpSave was blocked while loading: nothing was written into claude-fable/`,
  `[load] notebook Input cells: 217; evaluated cells 1..117 in 125. s`,
  `[load] cells that raised messages while loading (incidental to this script): {}`,
  `[load] the notebook's own assertions in cells 1..117: 142 run, 142 passed; not passed: {}`, then the
  94 `PASS` lines of its eight sections, and at the end

```
==================================================================================
 waveguide_derivation.wls: 94 checks, 94 PASS, 0 FAIL
 total time 162.8 s
==================================================================================
```

- **Success:** `94 checks, 94 PASS, 0 FAIL`, the notebook's own 142 assertions passed while loading, and
  `waveguide_T16.json` unchanged (`git status` shows nothing). Notebook 07 re-reads this log and asserts
  it (`derivation log: 94 PASS lines, 0 FAIL lines; summary line: "94 checks, 94 PASS, 0 FAIL"` [nb07 §5.3]).

#### 6.6.2 The solver's validation

```bash
$PY waveguide.py validate
```

- **What it does.** 64 checks: the analytic cases (constant `K` with MIT−: `omega = −K`; the closed form
  for any `th`; no level for constant `K` with MIT+; the flat band `omega = m` for `g(0) = 0`, absent in
  the other irrep), the Magnus propagator against DOP853, Hellmann–Feynman (`d omega/dm = Int (f^2 − g^2)`,
  `d omega/dK`), the full 16×16 system with the notebook's `T16` (every level of multiplicity exactly 4, a
  non-level of multiplicity 0, the level located independently), the edge-band slope against its closed
  form `(m/6H) B(m/6H, 13/12)`, and the block reduction by `U`. It reads `waveguide_T16.json`.
- **How long.** `[done in 31.1 s]` in notebook 07's run; 45 s in the report's development run.
- **What it prints.** `waveguide.py validate   (python 3.14.5, numpy 2.5.3)`, one `PASS`/`FAIL` line per
  check with its numbers, `VALIDATION: 64 of 64 PASS` and `[done in ... s]`; notebook 07 §5.3 prints the
  whole output. Among its lines [nb07 §5.3, verbatim]:

```
  PASS  V1 constant K=0.3, MIT- (f=-g): single level w = -K   [w = -0.299999999999999, err = 6.11e-16]
  PASS  V4 true profile K=80.0, g(0)=0: w = m is a level   [|w - m| = 4.55e-13; all levels [-80.00428754, -78.51089497, 1.0, 78.51089497, 80.00428754]]
  PASS  V5 Magnus vs DOP853 mismatch Delta(w), K=80.0, th=-0.785   [max diff 7.50e-09 rad]
  PASS  V6 level w=+70.98530723 (K=80.0, th=-0.785): norm, wall condition, Hellmann-Feynman dw/dm = Int(f^2-g^2), dw/dK = Int 2fg s6   [norm-1=-1.8e-10, bc=0.0e+00, dw/dm=0.24150470 vs 0.24150473, dw/dK=0.82441698 vs 0.82441698]
  PASS  V7 16x16 locates the level independently (K=80.0): w16 = 79.3714959054 vs 2x2 block 79.3714957791   [|diff| = 1.3e-07, multiplicity 4, sv_min 1.5e-08]
  PASS  V9 opposite-sign edge band slope at K -> 0, m = 1.0: omega/K = -(m/6H) B(m/6H, 13/12)   [omega/K at K=1e-4: -0.980822728, exact slope -0.980822733]
  PASS  V8 numeric: U^dag T0(m - iK T1 + i w T4) U = diag of the 8 block matrices (s = +1 for w3=-i, -1 for w3=+i)
VALIDATION: 64 of 64 PASS
[done in 31.1 s]
```

- **Success and failure.** `VALIDATION: 64 of 64 PASS` and exit status 0. Any failed check makes the exit
  status 1 and prints `waveguide.py: N validation check(s) FAILED` to standard error. If
  `waveguide_T16.json` is missing, V7 and V8 each record one `FAIL` naming the command that rewrites the
  file (6.6.1), the other checks still run, and the exit status is 1 (section 5.8, item 5).

#### 6.6.3 The levels, thresholds, dispersion, edge band, wall family, convergence, wavefunctions, reference table

```bash
$PY waveguide.py levels --K 80 --m 1 --wall same   # 1.4 s
$PY waveguide.py threshold                         # 13 s (9.5 s in notebook 07)
$PY waveguide.py figures                           # dispersion + edge + theta + wavefunctions, ~25 s (24.6 s in notebook 07)
$PY waveguide.py dispersion
$PY waveguide.py edge
$PY waveguide.py theta
$PY waveguide.py wavefunctions
$PY waveguide.py convergence                       # 18 s
$PY waveguide.py reference                         # 7 s: the level table read by waveguide_check.wls
$PY waveguide.py all                               # everything except the exploratory dft scenarios
$PY waveguide.py -h                                # every command and option
```

The subcommands [file: the module and its argument parser]: `levels` prints all levels of both irreps at
`--K` (the transverse momentum `K_inf = k e^{a4}`, in units of `H`; default 80), `--m` (the bulk mass `m/H`;
default 1), `--wall same|opposite` (the MIT wall sign relative to `m`), or `--theta th` (a uniform wall
angle, overriding `--wall`); `threshold` prints `K_c(1)`, `K_c(2)` against `m/H`; `dispersion` the levels
`omega_n(K)` for `K = 7..100` and the opposite-sign spectrum; `edge` the opposite-sign edge band; `theta`
the uniform self-adjoint family at `K = 3` and 80; `convergence` the dependence of a level on the matching
point, the tolerances, `z_a`, the `kappa` grid and the integrator; `wavefunctions` the orbitals at
`K = 80`; `figures` the four figure tables at once; `reference` the level table for the Mathematica check;
`--quick` limits `dft` to one ΔSCF fraction (`x = 0.05` instead of `0.01, 0.05, 0.10, 0.20`) [file: `dft_run`]. Tables go to `fermion/dev/` with the prefix `waveguide_` (a folder the repository
ignores; notebook 07 writes the final tables and figures into `results/nb07_*`).

`levels --K 80 --m 1 --wall same` prints, for both irreps, `irrep -i: -79.987308552047, -78.144249332428,
+70.985307229908, +79.371495779094; irrep +i: -79.371495779091, -70.985307229895, +78.144249332427,
+79.987308552047` — the `omega -> −omega` symmetry between the irreps to `1e-11` [WG 1]. `threshold`
prints the table of section 4.6.5 (notebook 07 prints it again, `THRESHOLDS of the same-sign MIT wall ...`,
with `K_c(1) = 6.70624065` and `K_c(2) = 33.91895851` at `m/H = 1` [nb07 §5.6]); `figures` prints the
dispersion table (`DISPERSION omega_n(K), same-sign (MIT+) wall, m/H = 1.0, H = 1: ...` [nb07 §5.7]).
**Success** for these is exit status 0 and the tables; they are checked by notebook 07, which asserts
what they print, and by the Mathematica check (6.6.4).

#### 6.6.4 The independent Mathematica check

```bash
$PY waveguide.py reference                                          # writes fermion/dev/waveguide_levels_reference.csv
cd "$(git rev-parse --show-toplevel)"
wolframscript -file fable-cosmology/fermion/waveguide_check.wls
```

- **What it does.** Recomputes the levels in a different language: `NDSolve` at 30 digits, the normalized
  Wronskian with `FindRoot`, `NullSpace` for the asymptotic data; the 16-component multiplicities with
  `NDSolve` at `K = 3, 8` and, at `K = 80` (where `NDSolve` on the 16×8 matrix system did not finish within
  30 minutes), an independently written Magnus/`MatrixExp` propagator; the thresholds by an independently
  written Prüfer `NDSolve` at 30 digits. It reads the committed `waveguide_T16.json` and the Python level
  table, which is not committed — so in a fresh clone write it first with `waveguide.py reference`.
- **How long.** 40 s [WG 1].
- **What it prints.** `Summary: 11 checks, 11 PASS, 0 FAIL, no messages`, with its level table (section
  4.6.4), agreement with the Python levels to at most `4.68e-11`, and the thresholds
  `K_c(1) = 6.70624065181` and `K_c(2) = 33.9189585083` [WG 5]. Notebook 07 quotes the four `K = 80`
  Mathematica levels and asserts `max |notebook - Mathematica| = 4.7e-11` [nb07 §5.7].
- **Success:** `11 checks, 11 PASS, 0 FAIL, no messages`.

#### 6.6.5 The density-functional runs

```bash
$PY waveguide.py dft                           # 9.3 min (522.4 s in notebook 07's background run)
$PY waveguide.py dft --scenario bulk           # about a second (0.3 s): is homogeneous matter self-bound?
$PY waveguide.py dft --scenario strong         # 10.9 min; exploratory (lam = -100), does not converge
$PY waveguide.py dft --scenario convergence    # 12.1 min
```

- **What they do.** The local-density Kohn–Sham self-consistency for `W = m0 sigma + (lam/2) sigma^2` along
  `z` (section 4.6.6): `[DFT-a]` the author's mass term, which is free and exact; `[DFT-b]` the same-sign wall,
  `lam = −0.01`, `N_s = 100`, its variational check and band gaps, and the ΔSCF first excited states at
  `x = 0.01, 0.05, 0.1, 0.2`; `[DFT-c]` the opposite-sign wall at `lam = −0.01` and `−10`, `N_s = 0.05`.
  `--scenario` selects `all` (default), `free`, `same`, `opposite`, `strong`, `bulk` or `convergence`.
- **What `dft` prints**: every iteration (`it   n  max|m_new - m| = …  E/A = …  mu = …  N(check) = …  z_c = …`),
  then per scenario the converged state, its stability statement, the Walecka variational check and the
  band structure, ending `[done in 522.4 s]`. Notebook 07 starts it in the background and prints its whole
  output in its §5.17 [nb07 §5.17]; for example the same-sign ground state converges in nine iterations,
  `it   9  max|m_new - m| = 1.537e-10  E/A = 937.2277360325  mu = 11.6958993131  N(check) = 100.00000000  z_c = 0.92318`,
  and its variational check reads `d Omega/ds = -48.305804: NOT stationary.`
- **What `--scenario bulk` prints** [nb07 §5.16, verbatim]:

```
[DFT bulk] homogeneous 4D matter (z, x1..x3), g = 8 per 4-momentum, W = m0 sigma + (lam/2) sigma^2, m0 = 1:
   n = kF^4/(4 pi^2), sigma = (m/pi^2) Int_0^kF k^3/w, eps = (1/pi^2) Int_0^kF k^3 w, gap m = m0 + lam sigma, E = eps - (lam/2) sigma^2
   lam =    -0.01: min over kF in [0.01, 10] of (E/n - m0) = +0.000033 at kF = 0.0100, m* = 1.0000, n = 2.533e-10  -> not self-bound (minimum at the lowest density)
   lam =    -1.00: min over kF in [0.01, 10] of (E/n - m0) = +0.000033 at kF = 0.0100, m* = 1.0000, n = 2.533e-10  -> not self-bound (minimum at the lowest density)
   lam =   -10.00: min over kF in [0.01, 10] of (E/n - m0) = +0.000033 at kF = 0.0100, m* = 1.0000, n = 2.533e-10  -> not self-bound (minimum at the lowest density)
   lam =   -30.00: min over kF in [0.01, 10] of (E/n - m0) = +0.000033 at kF = 0.0100, m* = 1.0000, n = 2.533e-10  -> not self-bound (minimum at the lowest density)
   lam =   -60.00: min over kF in [0.01, 10] of (E/n - m0) = +0.000033 at kF = 0.0100, m* = 1.0000, n = 2.533e-10  -> not self-bound (minimum at the lowest density)
   lam =   -80.00: min over kF in [0.01, 10] of (E/n - m0) = -0.038261 at kF = 0.8775, m* = 0.3965, n = 0.01502  -> SELF-BOUND
   lam =  -100.00: min over kF in [0.01, 10] of (E/n - m0) = -0.072213 at kF = 0.8575, m* = 0.3550, n = 0.01369  -> SELF-BOUND
   lam =  -200.00: min over kF in [0.01, 10] of (E/n - m0) = -0.175598 at kF = 0.7819, m* = 0.2568, n = 0.009468  -> SELF-BOUND
[done in 0.3 s]
```

- **Success:** the converged scenarios print `converged=True` with the particle number reproduced
  (`N(check) = 100.00000000`); `dft` ends with exit code 0 (`waveguide.py dft finished with exit code 0, 554 s
  after it was started` [nb07 §5.17]). The strong-coupling scenario is exploratory and is **expected not
  to converge** (section 4.6.6).

The development logs of all these commands (`dev/waveguide_run_*.log`) are in the ignored `fermion/dev/`;
the committed report `fable-cosmology/fermion/waveguide_REPORT.txt` quotes them, and notebook 07 re-runs
and asserts the numbers that matter.

### 6.7 The Jupyter notebooks: generate, execute, check, and how they display the results

Seven notebooks drive the solvers, display the results and check them: 01–04 for Effort 0, 05–07 for
Effort B. They are **generated**, never edited by hand, executed headlessly, and checked.

#### 6.7.1 Generate them

```bash
cd "$(git rev-parse --show-toplevel)/fable-cosmology"
.venv/Scripts/python.exe notebooks/_build/nbgen.py            # all seven, unexecuted
.venv/Scripts/python.exe notebooks/_build/nbgen.py 05 06 07   # only these
```

`nbgen.py` is the source of truth: it writes `notebooks/0N_*.ipynb` (nbformat 4, unexecuted) from its
cell manifests, and refuses (with an assertion) a code cell that is not preceded by a markdown cell of at
least 80 characters. It prints one line per notebook, `wrote <name>.ipynb: <n> cells, <m> code cells`
[file: its `build` and `build_fermion` functions]; for the committed notebooks that is 38 cells (16 code)
for 05, 45 (20) for 06 and 73 (34) for 07, and 38 (16), 35 (15), 29 (12), 25 (10) for 01–04 [counted from
the committed notebooks]. Generating overwrites the executed notebooks with unexecuted ones, so execute
them next.

#### 6.7.2 Execute them, and check them

```bash
cd "$(git rev-parse --show-toplevel)/fable-cosmology"
PY=.venv/Scripts/python.exe                     # .venv/bin/python on Linux/macOS
for nb in notebooks/05_fermion_fable_quantum_eos.ipynb notebooks/06_fable_primordial_gravity_8d.ipynb notebooks/07_fable_dft_states.ipynb; do
  "$PY" -m nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=1800 \
        --ExecutePreprocessor.kernel_name=python3 "$nb"
done
"$PY" notebooks/_build/nbcheck.py
```

- **What it does.** Each notebook is executed headlessly by the Jupyter kernel of the virtual
  environment, and its outputs (text, tables, figures) are written back **into the `.ipynb`**. The
  notebooks locate the solver binary, read the unit system from it (and assert it against CODATA), run
  every case, write their CSV tables and PNG figures under `results/`, and **assert every claim they
  print**: a failed assertion stops the execution with an `AssertionError` and `nbconvert` exits
  non-zero. Notebook 07 also runs `fermion/waveguide.py` and starts its full-resolution `dft` run in the
  background (`$ python fermion/waveguide.py dft      started in the background (pid 28636); its output
  goes to fermion/dev/nb07_waveguide_dft_full.log`), which its §5.17 waits for. The per-cell
  timeout is 1800 s.
- **How long.** From the committed notebooks' cell timestamps (the kernel's time from the first cell's
  start to the last cell's end): 05 **6.9 s**, 06 **92.8 s**, 07 **557.6 s** (and 01–04: 3.3 s, 2.5 s,
  31.4 s, 1.8 s). 07 is the one notebook allowed a cell of more than a minute (the wait for the background
  run).
- **The two interactive cells.** The last two cells of every notebook ask for a name and open a save
  dialog; headless, they detect the batch run and print
  `Headless execution: no prompt; the notebook keeps its name 05_fermion_fable_quantum_eos` and
  `Headless execution: the save dialog is skipped; the notebook stays where it is.` (likewise for 06 and
  07).
- **The checker.** `nbcheck.py` checks every notebook against eight requirements: **R1** it explains how
  to launch a notebook from a terminal (and how to rebuild its own solver: 05–07 must name the crate
  `rust/fable_fermion`, and 07 also `fermion/waveguide.py`); **R2** it never sends the reader to another
  notebook; **R3** every code cell is preceded by explanatory markdown; **R4** it asks the user to name
  the notebook; **R5** it opens a graphical save dialog, with a fallback; **R6** it describes the field,
  its Lagrangian and energy–momentum tensor, the equations of motion and the first-order system actually
  handed to SUNDIALS, with a glossary of every word of the common list (and, for 05–07, of the fermion
  list: complex 16-spinor, Grassmann numbers, Dirac conjugate, anticommutator, Krein space, fundamental
  symmetry `J`, Fock space, Dirac sea, Kohn–Sham, gap equation, Fermi momentum, degenerate gas,
  `DeltaN_eff`, stabilizing stress, null energy condition, Bianchi-I, hidden sheet, Newton constant
  variation; for 07, of the wall list: Hohenberg–Kohn theorem, Kohn–Sham reference system,
  exchange–correlation energy, local-density approximation, self-consistent field, ΔSCF, Walecka
  functional, minimax, particle–hole excitation, pair continuum, wall, proper distance, transverse
  momentum, self-adjoint extension, MIT condition, irrep, Prüfer angle, threshold, edge state, band,
  surface density, Fermi level); **R7** it is valid nbformat-4, every non-interactive code cell was
  executed, no cell raised an error, and its metadata pairs it with exactly one solver
  (`metadata.fable_fermion.model`: `["fable4d", "gap"]` for 05, `["fable4d", "fable8d"]` for 06,
  `["gap", "fable4d", "waveguide"]` for 07); **R8** it owns its results (a results section naming files
  under `results/`) and reads one back with plain Python (the `csv` module), independently of the solver.
  It prints a `FAIL <notebook>` block with the failed requirements for each failing notebook, and the
  count.
- **What it prints, and success.** With all seven executed, on 2026-09-25:
  `7/7 notebooks pass all eight requirements`, exit code 0 (commit `aca5102`: "All seven notebooks pass
  all eight requirements (nbcheck 7/7)"). Earlier states printed `4/4 …` (before the fermion notebooks) and
  `6/6 …` (at 23:04 PDT on 2026-09-24, before notebook 07 was executed; 0.11 s).
- **After a run** `git status` shows the notebooks as modified: the execution timestamps of every cell
  change on every run, and the kernel may split a cell's printed output into chunks differently; their
  sources, execution counts, printed text, embedded images and results do not change. Notebook 07 also
  prints wall-clock times and the process id of its background run, which change from run to run. In a
  clone at another path, the one line that prints the absolute `results directory` differs too.
  `git checkout -- fable-cosmology/notebooks` restores the committed notebooks.

#### 6.7.3 How the notebooks display the results

Every notebook has the same eight-part structure (1 how to open it from a terminal; 2 the words used; 3
the field, its Lagrangian and energy–momentum tensor; 4 the equations of motion and the first-order
system handed to SUNDIALS; 5 running the solver, section by section; 6 this notebook's results, read back
with plain Python; 7 the conclusions — "What the numbers say" in 05, "Answers" in 06, "What these states
mean for the cosmology" in 07; 8 name and save). Their prose states no numerical result:
every number is printed by a cell, and the closing summary is **composed from the computed values** and
displayed as Markdown output, with an assertion behind each qualitative claim. They display in four
ways:

- **Printed tables** in the cell output: the solver's command line (`$ fable_fermion …`) and its
  `# stats:` line for every run, then the table the section computes (for example notebook 06's table of
  the mass runs, `run  kF0 [eV]  a_nr  a_i ok  dNeff BBN  dNeff rec  3P/rho_nu rec  q0  t0 [Gyr]  Omega_f0`,
  or notebook 07's level table at `K = 80` with each level's irrep, `kappa`, binding and 16-component
  multiplicity).
- **Figures**, written as PNG under `results/` and embedded inline in the executed notebook (7 in 05, 8 in
  06, 9 in 07):

| figure | what it shows |
|---|---|
| `nb05_ks_accuracy.png` | "Kohn-Sham Fermi-sea integrals: closed forms versus stable forms": the relative error of each against quadrature over `1e-8 <= x = kF/\|m\| <= 1e6`, with the series/closed switch at `x = 0.25` |
| `nb05_w_ks.png` | "The degenerate fable gas: from radiation (1/3) to dust (0)": `w_KS(x) = P_KS/eps_KS` with its limits `x^2/5` and `(1/3)(1 − 2/x^2)` |
| `nb05_classical_vs_quantum.png` | quantum (Kohn–Sham, lowest-energy gap root) against classical (Part VI, `sV'/V − 1`) `w` for the five potentials against the density: no phantom crossing after quantization |
| `nb05_gap_roots.png` | the gap function `m − W'(sigma_KS(m))` of the repulsive quadratic `(0.05, 20)` and its roots; the ground-state `m` against `kF`, which jumps (a first-order transition) |
| `nb05_minimax.png` | the no-sea functional `E_n[sigma]/n` of `W = m0 sigma` (`m0 = 2`, `kF = 1.5`): the gap root is a maximum, the collapse value `−\|m0\|`; the Walecka functional of `W = sigma − 10 sigma^2` (`kF = 1`): the gap root is its minimum |
| `nb05_preuniverse_cooling.png` | "On the pre-universe the quantum fable gas cools from w = 1/3 to w = 0": `w_KS(a_nr/a)` against `a/a_nr` (`a = e^(−a4)`), the Rust run's `w_qp`, and the frozen classical `w = 0` |
| `nb05_vacuum_energy.png` | "Renormalized Dirac-sea energy of a mass-varying fable (g = 8)": `\|DeltaE_vac(m; M)\|/rho_c0` against `m/M` for `M = 1, 30, 100, 1000 eV`, with `rho_c0` marked |
| `nb06_a_mass_wdm.png` | runs (a): `w_DM = P_KS/eps_KS` against `a`: the degenerate fable cools from 1/3 to 0 |
| `nb06_b_lambda_mass.png` | runs (b): `w_f` and `w_DM`, and `w_DE,inf + 1` on `0.3 <= a <= 1`: the inferred dark energy is a cosmological constant |
| `nb06_c_de_potentials.png` | runs (c): `w_f` (never below −1), the observer's `w_DE,inf` (clipped to `[−3, 1]`, poles and crossings marked), `m_eff/m_today`, and `c_s^2` |
| `nb06_c_exchange_vacuum_stabilizer.png` | runs (c): `w_DM` and `w_DM,eff`, the exchange `Q`, the Dirac-sea energy relative to the total density, and `P_stab/rho` |
| `nb06_scan.png`, `nb06_scan_cpl.png` | the scans: the smallest `m_eff/m_today` over `1e-3 <= a <= 0.3` and the smallest `c_s^2` against the scanned parameter; the CPL points of `w_DE,inf` and of `w_f` |
| `nb06_dm_mass_bounds.png` | free streaming: `v_rms` today against the fable mass, with the warm-dark-matter velocities |
| `nb06_d_nogo_8d.png` | runs (d): `G_4(a)/G_4(today) = 1/v`, `H_B/H_A` and `H_C/H_A` (the approach to the 7-dimensional isotropic attractor), and the constraint residual |
| `nb07_homogeneous.png` | the homogeneous Kohn–Sham ground state: the no-sea functional of `W = 2 sigma` (`kF = 1.5`, a maximum), the Walecka functional of `W = sigma − 10 sigma^2` (`kF = 1`, the minimum), and the repulsive quadratic (one root, then three) |
| `nb07_excitations.png` | the particle–hole and pair excitation thresholds of the homogeneous gas (`m = 1`, `kF = 1.5`) against the total momentum `Q` |
| `nb07_thresholds.png` | "same-sign MIT wall: where the wall levels appear": `K_c(1)` (irrep −i) and `K_c(2)` (irrep +i) against `m/H` |
| `nb07_dispersion.png` | the positive levels `omega_n(K)` of the same-sign wall (`m = H`, each 4-fold) with the continuum edge `R = Sqrt[m^2 + K^2]`, and their binding `R − omega_n` |
| `nb07_edge_band.png` | the opposite-sign wall: `\|omega_edge\|/K` against the closed-form slope `(m/6H) B(m/6H, 13/12)`, and the edge level against the continuum edge and the bulk mass ("massless fermions on the wall below K*") |
| `nb07_theta.png` | "K = 3, m = H: levels of the self-adjoint wall family" against `theta/pi`, both irreps, with the continuum edges and the MIT walls marked |
| `nb07_wavefunctions.png` | the orbitals `f(z)`, `g(z)` of `n = 0` and `n = 1` at `K = 80` against the proper distance from the wall |
| `nb07_ks_profiles.png` | the Kohn–Sham profiles `sigma(z)`, `m(z)`, `n(z)` of the same-sign ground state, of the ΔSCF state with `x = 0.10`, and of the opposite-sign edge-band ground state (`lam = −10`) |
| `nb07_strong.png` | strong attraction (`lam = −100`): the residual of the non-converging iteration, the layer centre drifting away from the wall, and the Walecka functional of the shifted well against its centre ("the wall repels the layer") |

- **Result files**: every table the notebook computes is also written as CSV under `results/`
  (`nb05_*` 11 files, `nb06_*` 37, `nb07_*` 18), and §6 of each notebook reads one back with plain
  Python and prints it (for example `nb06_runs.csv: 29 rows, 34 columns` and a line per run with `a_nr`,
  `Delta N_eff(BBN)` and the CPL fit [nb06 §6]).
- **The composed summary**: notebook 05 prints ten numbered statements, notebook 06 its answers to [1] and
  [2], notebook 07 nine numbered statements, each ending with a line that every statement is asserted
  (`every statement of this notebook is backed by the numbers above`, `every claim of the answers is
  asserted above`, `every statement of the summary is asserted in the cells above`). They are restated in
  sections 4.5–4.8.

**Troubleshooting** (what a failing notebook prints, and why): `The solver binary … does not exist` (the
setup did not finish: run it again); an `AssertionError` naming `omega_r0` in §5 of 05 or 06 (the
binary predates the `hbar` correction: rebuild it); `the Mathematica reference … is missing` in 06
(restore `reference/mathematica_fable4d_*.csv` with `git checkout`, or regenerate them, 6.3.7); notebook 07
stopping in its §5.3 with `…fermion/waveguide_T16.json is missing` (restore it with
`git checkout -- fable-cosmology/fermion/waveguide_T16.json`, or rewrite it, 6.6.1); `Kernel ... not found`
or `No such kernel named python3` (run nbconvert from the `.venv`, which contains `ipykernel`); the
Windows warnings `RuntimeWarning: Proactor event loop does not implement add_reader …` and
`[IPKernelApp] WARNING | Kernel is running over TCP without encryption` are warnings of the zmq and
Jupyter libraries, not errors.

### 6.8 Reproduce everything with one command

```bash
bash "$(git rev-parse --show-toplevel)/fable-cosmology/run_all.sh"
```

```powershell
powershell -ExecutionPolicy Bypass -File fable-cosmology\run_all.ps1     # make Perl visible first (6.1)
```

- **What it does** [file: `fable-cosmology/run_all.sh`], after `setup.sh`, from any directory, under
  `set -euo pipefail` (it stops at the first failure): `== 1. solver tests` — `cargo test --release` in
  `rust/fable_cosmo` (showing its last three lines) and in `rust/fable_fermion` (showing its `running`,
  `test result`, `FAILED` and `panicked` lines); `== 2. notebooks` — every `notebooks/0*.ipynb` in order,
  01 to 07, executed in place with the `nbconvert` command of 6.7.2; `== 3. notebook requirements` —
  `nbcheck.py`; `== 4. the paper` — `latexmk -pdf -interaction=nonstopmode -halt-on-error
  fable_cosmology.tex` in `fable-cosmology/latex/` (its output into `latex/latexmk.log`), then the PDF's
  `ls -la` line; and `== all done`. `run_all.ps1` does the same, shows all of `cargo test`'s output, and
  throws on a failing `cargo test` of either solver (it checks `$LASTEXITCODE`), a failing notebook, the
  checker or the paper build.
- **How long.** 12 min 18 s on 2026-09-25 with the seven notebooks (of which notebook 07 about 9 min and
  the `fable_fermion` tests about 45 s; the committed execution of notebook 06 took 92.8 s); 3 min 35 s on 2026-09-24 before notebook 07
  existed; 51 s (61 s in a fresh clone) before the fermion-fable work.
- **What it printed** on 2026-09-25 (Windows 11, Git Bash, the seven notebooks, 12 min 18 s), verbatim:

```
== 1. solver tests
   rust/fable_cosmo

test result: ok. 7 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

   rust/fable_fermion
running 23 tests
test result: ok. 23 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 38.31s
running 0 tests
test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
running 11 tests
test result: ok. 11 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.93s
running 0 tests
test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
== 2. notebooks
   executing notebooks/01_fableScalar_quintessence.ipynb
[NbConvertApp] Converting notebook notebooks/01_fableScalar_quintessence.ipynb to notebook
C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\fable-cosmology\.venv\Lib\site-packages\zmq\_future.py:718: RuntimeWarning: Proactor event loop does not implement add_reader family of methods required for zmq. Registering an additional selector thread for add_reader support via tornado. Use `asyncio.set_event_loop_policy(WindowsSelectorEventLoopPolicy())` to avoid this warning.
  self._get_loop()
[IPKernelApp] WARNING | Kernel is running over TCP without encryption. All communication (including code and outputs) is sent in plain text and is susceptible to eavesdropping. Use IPC transport or launch with kernel manager-provisioned CurveZMQ keys to enable transport encryption.
[NbConvertApp] Writing 475134 bytes to notebooks\01_fableScalar_quintessence.ipynb
   executing notebooks/02_fable_spinor.ipynb
[NbConvertApp] Converting notebook notebooks/02_fable_spinor.ipynb to notebook
   (the same two warning lines)
[NbConvertApp] Writing 532820 bytes to notebooks\02_fable_spinor.ipynb
   executing notebooks/03_pre-universe_dynamics.ipynb
[NbConvertApp] Converting notebook notebooks/03_pre-universe_dynamics.ipynb to notebook
   (the same two warning lines)
[NbConvertApp] Writing 1090050 bytes to notebooks\03_pre-universe_dynamics.ipynb
   executing notebooks/04_dark_matter_dark_energy.ipynb
[NbConvertApp] Converting notebook notebooks/04_dark_matter_dark_energy.ipynb to notebook
   (the same two warning lines)
[NbConvertApp] Writing 318320 bytes to notebooks\04_dark_matter_dark_energy.ipynb
   executing notebooks/05_fermion_fable_quantum_eos.ipynb
[NbConvertApp] Converting notebook notebooks/05_fermion_fable_quantum_eos.ipynb to notebook
   (the same two warning lines)
[NbConvertApp] Writing 734434 bytes to notebooks\05_fermion_fable_quantum_eos.ipynb
   executing notebooks/06_fable_primordial_gravity_8d.ipynb
[NbConvertApp] Converting notebook notebooks/06_fable_primordial_gravity_8d.ipynb to notebook
   (the same two warning lines)
[NbConvertApp] Writing 1412296 bytes to notebooks\06_fable_primordial_gravity_8d.ipynb
   executing notebooks/07_fable_dft_states.ipynb
[NbConvertApp] Converting notebook notebooks/07_fable_dft_states.ipynb to notebook
   (the same two warning lines)
[NbConvertApp] Writing 905839 bytes to notebooks\07_fable_dft_states.ipynb
== 3. notebook requirements

7/7 notebooks pass all eight requirements
== 4. the paper
-rw-r--r-- 1 nsh 197121 2835044 Sep 24 19:40 fable_cosmology.pdf
== all done
```

  The only abbreviation is `(the same two warning lines)`, which stands for the zmq `RuntimeWarning`
  (two lines) and the `[IPKernelApp] WARNING`, repeated verbatim as after notebook 01; they are warnings
  of the zmq and Jupyter libraries on Windows, not of the notebooks, and they change no output. The empty
  line after `rust/fable_cosmo` is the first of the three lines that `cargo test … | tail -n 3` keeps.
  The paper step lists the PDF; latexmk's own output is in `latex/latexmk.log`, which ends with
  `Latexmk: All targets (fable_cosmology.pdf) are up-to-date` when nothing changed (after three pdflatex
  passes the first time).
- **Success:** `== all done` with exit code 0, `7/7 notebooks pass all eight requirements`, and
  `git diff --stat -- fable-cosmology/results` empty (6.5).

### 6.9 The LaTeX build

```bash
bash "$(git rev-parse --show-toplevel)/provenance-latex/build_all.sh"
```

```powershell
powershell -ExecutionPolicy Bypass -File provenance-latex\build_all.ps1
```

- **What it does** [file: `provenance-latex/build_all.sh`]. For each of the three LaTeX twins of the
  provenance pages of 2026-09-24 — `PROVENANCE-14-FERMION-FABLE-CANONICAL-QUANTIZATION`,
  `PROVENANCE-15-FERMION-FABLE-AND-THE-PRIMORDIAL-GRAVITATIONAL-FIELD` and
  `PROVENANCE-16-THE-COMPLETE-SOLUTION-AND-ITS-COMMANDS` (the twin of this page) — it runs
  `latexmk -pdf -interaction=nonstopmode -halt-on-error <doc>.tex` (as many pdflatex passes as the
  cross-references need), with the output in `provenance-latex/<doc>.latexmk.log`; it stops on the first
  failure, printing `FAILED; see provenance-latex/<doc>.latexmk.log and <doc>.log`; it warns
  (`WARNING: undefined references in <doc>.log`) if the `.log` contains "undefined" or "Rerun to get"; and
  it lists each PDF. Every document begins with `\input{preamble}` (`provenance-latex/preamble.tex`:
  pdfLaTeX, Latin Modern, A4, 2.5 cm margins, and macros for the notebook's objects, with separate symbols
  for the classical conjugation `\cconj` and the Hilbert adjoint `\hadj`); the generated fragments of
  `provenance-latex/generated/` are `\input` where the equations are quoted. `build_all.ps1` does the same
  in PowerShell and throws on a failing `latexmk`. MiKTeX's `latexmk` needs Perl on the `PATH`; Git for
  Windows ships one (`$env:PATH += ";C:\Program Files\Git\usr\bin"` in PowerShell).
- **What it prints:** `== <doc>` and an `ls -la` line per document, and finally `== all three PDFs built`.
- **Success:** exit code 0 and that last line; the `.log` of each document free of errors and undefined
  references, and no overfull box worse than 10pt (`grep -n -E "^!|undefined|Overfull" <doc>.log`). The
  twin of the page of Effort A was built this way when it was committed: 110 pages, no errors, no
  undefined references, no overfull box above 5.5pt [commit fee5603]. The output of the build of all three
  twins on the final pushed state is recorded with the fresh-clone verification (section 7).

The paper of Effort 0 is built the same way from `fable-cosmology/latex`:

```bash
cd "$(git rev-parse --show-toplevel)/fable-cosmology/latex"
latexmk -pdf -interaction=nonstopmode -halt-on-error fable_cosmology.tex
```

A clean build ends with `Output written on fable_cosmology.pdf (24 pages, …)` in `fable_cosmology.log`,
with no errors, no undefined references and no overfull boxes; `latexmk -c` removes the by-products (which
git ignores). Its 16 figures are byte-identical copies of the notebooks' PNGs in `latex/figures/`.

### 6.10 Git: commit, push, check the remote, clone afresh

**Commit and push** (every commit of the work was made this way; the notebook's two `.mx` files are
restored first, 6.3.4):

```bash
cd "$(git rev-parse --show-toplevel)"
git status --short                                   # what changed
git add <the files of the step>                      # named files, never a blanket add
git commit -m "<what the step adds or fixes>" -m "<details>" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git push origin main
```

`origin` is `https://github.com/once-ere/Pre-Universe_with_Claude.git`; the remote named `upstream` (the
author's other repository) is never pushed to. Since pull request #1 (section 2.2) every commit went
directly to `main`.

**Check that the remote has what was pushed:**

```bash
cd "$(git rev-parse --show-toplevel)"
git fetch origin
git rev-parse HEAD origin/main              # both must print the same hash
git ls-remote origin refs/heads/main        # the hash GitHub serves for main
git status --short                          # what is not yet committed
```

When this page was written (2026-09-25), `git ls-remote origin refs/heads/main` printed

```
16711556effcf920b28a606f4c365149f126dd4e	refs/heads/main
```

which is the local `main` (`git rev-parse HEAD` printed the same hash): `1671155`, "Record the final
notebook run: 217 Input cells, 644/644 assertions, 0 messages". Earlier checks printed
`bc04ed16096e134857111ae16df5220d4ff18435` (about 21:28 PDT on 2026-09-24) and
`2bc936d0dfd6f6c1243214fc6b1b9947f5bded6e` (23:26 PDT). The final commits and the `ls-remote` line of the
final push are recorded in section 7.4.

**Clone afresh and verify** (`<scratch>` is any empty directory outside the repository; section 7 records
the results):

```bash
cd <scratch>
git clone https://github.com/once-ere/Pre-Universe_with_Claude.git fresh
cd fresh
git log --oneline -1                                   # the hash of the pushed main
cd claude-fable
cp claude-fable_Einstein-Rosen-2-Planes.nb committed.nb
python build_tools.py                                  # the four lines of 6.3.1
cmp claude-fable_Einstein-Rosen-2-Planes.nb committed.nb && echo "notebook rebuilds byte for byte"
wolframscript -file verify_nb.wls                      # 6.3.2
cd ../fable-cosmology
bash setup.sh                                          # 6.1
bash run_all.sh                                        # 6.8: both crates' tests, notebooks 01-07, nbcheck, the paper
git diff --stat -- results                             # empty: every result file reproduced byte for byte
.venv/Scripts/python.exe fermion/crosscheck.py --jobs 6
(cd fermion && ../.venv/Scripts/python.exe waveguide.py validate)
cd ../claude-fable
wolframscript -file run_from_nb.wls > fresh_run.log 2>&1      # after run_all.sh, so the Rust CSVs exist
sed -n '/RUN SUMMARY/,$p' fresh_run.log                # 217 cells, 644/644, cells w/ msgs 0
diff <(grep '^  PASS' fresh_run.log) <(grep '^  PASS' run_fermion_fable_final.log) && echo "every label identical"
git checkout -- claude-fable_Einstein-Rosen-2-Planes-eLa.mx claude-fable_Einstein-Rosen-2-Planes-eLazt.mx
cd .. && bash provenance-latex/build_all.sh            # 6.9
```

**The delivered copy of the notebook** outside the repository,
`C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb`, is refreshed from `claude-fable/`
whenever the notebook changes, next to the author's two helper packages. When this page was written it was
545408 bytes and byte-identical to the repository's notebook (`cmp` reported no difference); when the page
of Effort A was written it was still the 2026-09-16 version (273270 bytes).

## 7. Verification of the repository: the push, and a fresh clone of it

### 7.1 What was pushed, and what was not yet, when this page was written

**The commits of the work** (`git log --date=iso`, PDT; every one pushed to `origin/main` of
`https://github.com/once-ere/Pre-Universe_with_Claude.git`):

| commit | time | effort | what it contains |
|---|---|---|---|
| `e34d454` | 2026-09-24 18:52:36 | 0 | the 2026-09-16 work as it stood: Part VI (172 Input cells, 358/358), `fable_cosmo`, notebooks 01–04, results, references, setup and run scripts (section 2.1) |
| `028b379` | 19:24:32 | 0 | the reference generator runs without underflow messages; pull request #1, merged 19:32:10 (section 2.2) |
| `2f6d322` | 19:57:29 | 0 | the gaps of 2026-09-16 closed: student instructions, the paper, the provenance page of that work, seven design corrections, `setup.sh`, `run_all.ps1`; a fresh local clone ran `setup.sh` and `run_all.sh` end to end (section 2.3) |
| `8459c57` | 20:02:04 | B | a work-in-progress snapshot of the solver crate `fable_fermion` |
| `e130337` | 20:14:25 | B | a second work-in-progress snapshot of that crate |
| `0a789e2` | 20:17:18 | C | the LaTeX build tree of the three provenance pages: `provenance-latex/preamble.tex`, `build_all.sh`, `build_all.ps1`; `.gitignore` names each document's `.log` and `.latexmk.log`; a minimal test document compiled with no warnings |
| `d0f2a99` | 20:18:53 | C | `build_all.sh` tracked without the executable bit (mode 100644), like the repository's other scripts |
| `c5892bd` | 20:38:49 | B | the finished solver `fable_fermion` (21 + 8 tests), the independent `crosscheck.py` (every run below `1e-8`), `report.py` |
| `4fdfc40` | 20:47:28 | A | Part VII of the notebook (198 Input cells, 528/528, 0 cells with messages), its log, the checker's log, the TeX export and its fourteen generated files |
| `b7ea18d` | 20:48:42 | A | the wording correction of an earlier provenance page (section 5.8, item 6) |
| `bc04ed1` | 21:24:04 | B | Part VIII of the notebook (217 Input cells, 642/642), its log, and the Mathematica reference runs of the coupled system |
| `18a2501` | 22:13:42 | B | the wall-state solver, its derivation (94/94), its Mathematica check (11/11), its report |
| `fee5603` | 22:31:20 | A, C | the page of Effort A (draft) and its LaTeX twin and PDF (110 pages) |
| `2bc936d` | 23:12:51 | B | six solver defects fixed, 34/34 tests (section 5.8, item 4) |
| `aca5102` | 2026-09-25 00:23:46 | B, 0 | notebooks 05–07 executed, their 90 result files, the integration (nbcheck 7/7, `run_all.sh` passing), the fermion sections of the student instructions, `waveguide_T16.json` committed, the `nbgen.py` corrections of notebooks 01–04 |
| `1671155` | 00:28:54 | B | the final full run of the notebook, `claude-fable/run_fermion_fable_final.log` (217 Input cells, 644/644, 0 messages, 208.715 s, 46 witnesses) |

When this page was written, `git ls-remote origin refs/heads/main` printed
`16711556effcf920b28a606f4c365149f126dd4e	refs/heads/main`, the local `main`. Everything that exists as
code, notebook, log, result file or generated file is in that pushed history. **Not yet committed** at
that moment: this page, the page of Effort B and the LaTeX twins and PDFs of the pages of Efforts B and
C, and an update of the repository's front page (its table of the notebook's Parts, the final counts, the
table of provenance pages). None of the numbers on this page is taken from an uncommitted file: every one
comes from the committed notebooks, result files, logs, reports and commit messages named next to it.
They are committed together at the end of the work, and that final state is what the fresh clone
verifies.

### 7.2 What the fresh-clone verification consists of

The final pushed `main` is cloned into an empty directory outside the repository, and everything is
rebuilt and re-run there from nothing — a new virtual environment, a new engine clone from GitHub, new
builds — with the commands of section 6.10, in this order, each result compared with the committed
record:

| step | command | compared with |
|---|---|---|
| 1 | `git clone https://github.com/once-ere/Pre-Universe_with_Claude.git fresh`; `git log --oneline -1` | the hash `git ls-remote` reports for `main` |
| 2 | `python build_tools.py` in `claude-fable/`; `cmp` against the committed notebook | byte-identical `.nb` and `run_all.wls` (6.3.1) |
| 3 | `wolframscript -file verify_nb.wls` | the output of 6.3.2 (`input cells that FAIL to parse: {}`) |
| 4 | `bash fable-cosmology/setup.sh` | `== setup complete`, both `--version` lines (6.1) |
| 5 | `bash fable-cosmology/run_all.sh` | `test result: ok. 7 passed`; `23 passed`, `11 passed`; the seven notebooks executed; `7/7 notebooks pass all eight requirements`; the paper built; `== all done` (6.8) |
| 6 | `git diff --stat -- fable-cosmology/results` | empty: all 149 result files (59 of notebooks 01–04, 63 of 05 and 06, 27 of 07) reproduced byte for byte; any CSV that differs compared column by column (6.5) |
| 7 | `python fermion/crosscheck.py --jobs 6`; `python fermion/waveguide.py validate` | `CROSSCHECK PASSED: every difference < 1e-06`; `VALIDATION: 64 of 64 PASS` |
| 8 | `wolframscript -file run_from_nb.wls` (after step 5, so the Rust CSVs exist) | `cells evaluated : 217`, `assertions run  : 644`, `passed          : 644`, `FAILED          : 0`, `cells w/ msgs   : 0`; every `PASS` label identical to `claude-fable/run_fermion_fable_final.log` (6.3.5) |
| 9 | `bash provenance-latex/build_all.sh` | `== all three PDFs built`, no errors, no undefined references, no overfull box worse than 10pt (6.9) |
| 10 | `git status --short` after restoring the two `.mx` files | only the re-executed notebooks (timestamps) and nothing else |

### 7.3 The results of the fresh-clone verification

{{FRESH-CLONE}}

### 7.4 The final push

{{FINAL-PUSH}}

## 8. What remains open

This is the honest list: what the work did not do, what it assumed without deriving, and where its
answers stop. Each item names the section where it is discussed.

### 8.1 Physics that was not done

1. **The Maxwell construction.** For the repulsive quadratic potential (`gq > 0`) the Kohn–Sham ground state
   jumps between gap branches at `a = 0.9962806544` — a first-order transition. Energy conservation across
   it needs the Maxwell (coexistence) construction, which the solver does not implement; it **refuses** the
   run instead (sections 4.7.11, 6.4.8). The physics of that transition — coexisting phases, latent heat,
   bubbles — is not examined.
2. **Exchange and correlation.** `E_xc` is neglected everywhere (the Hartree mean field). That is exact for the
   author's mass term, which is free, but for a nonlinear `W` the Fock exchange of the contact interaction is
   `1/g` of the Hartree term only for `k_F << m`, and of order one or larger for `k_F >~ m`, the early-universe
   regime. The ratio of the interaction energy to `3 P_KS`, which alone controls the neglect there, was
   **not computed** in the runs (section 4.5.12).
3. **The vacuum energy is fine-tuned, not solved.** For a constant mass the Dirac-sea energy is a constant,
   absorbed into `V0` as a bare cosmological constant: the cosmological-constant problem is not addressed. For
   a mass-varying potential the runs read `W` as the fully renormalized effective potential, which absorbs the
   sea energy only by fine-tuning: its variation along the runs is `1.31e13` to `2.87e16` times the total
   density at `a >= 0.3` (at least `3.79e9` over the scans). The other option — including `DeltaE_vac(m)` in
   `rho` and in the gap equation — was not run (sections 3.7.3, 4.5.11, 4.8.1).
4. **The origin of the stabilizer is unknown.** Every result of Effort B rests on the stabilized model
   `fable4d`, whose hidden sheet is held by `P_stab = −F/2`: a Lagrange multiplier with zero energy density,
   not a stress derived from any field, which **violates the null energy condition along `x0`** wherever dust
   is present (`rho + P_C = −rho_dust/2`; negative on every output row of every stabilized run). Without it
   (`fable8d`) the Newton constant varies by `6.5e8` to `1.9e17` and the model is excluded. What physical
   mechanism could stabilize the hidden sheet is not known (sections 4.7.1, 4.7.10).
5. **The strong-coupling wall state.** At `lam = −100` homogeneous matter is self-bound, but the Kohn–Sham
   iteration at the same-sign wall does **not converge** (residual `4.1e-2` after 12 iterations; the layer
   drifts from `z_c = 2.07` to `2.63`), and the wall repels the layer. A position-constrained iteration, to map
   `E(z_c)` self-consistently, was not done; only a rigid-shift upper bound was computed (section 4.6.6).
6. **The same-sign wall's self-consistent state is not a ground state.** At `lam = −0.01`, `N_s = 100` the
   iteration converges, but `mu − m0 = 10.696 > 0` (bulk states lie below the Fermi level) and the Walecka
   functional is not stationary (`d Omega/ds = −48.3`). A grand-canonical treatment with a bulk fable density
   was not done (section 4.6.6).
7. **Perturbations were not examined.** Everything is homogeneous background cosmology. Every massive
   mass-varying case has a negative adiabatic sound speed (`c_s^2` down to `−0.611` for `power nu = 0.236`,
   `−27` for `nu = 0.5`, `−21.8` for `expdamp`, `−47.1` for `quadratic`, `−0.364` in Part VIII's case), which
   signals an instability of perturbations that is stated but not followed; the free-streaming bound
   (`m ≈ 1.1–1.8 keV`) is a velocity-matching estimate, not a transfer-function computation; structure
   formation, the CMB and lensing are not computed (sections 4.7.6, 4.7.9).
8. **Renormalized `<T>` on a time-dependent background.** `<0|:T:|0> = 0` holds only for a static background or
   adiabatically; a conserved renormalized expectation on an `x4`-dependent background needs adiabatic
   subtraction or point-splitting, which was not carried out (section 3.7.3).
9. **Reflection positivity** of the `J`-quantization was claimed in the design, not verified, and dropped
   (section 5.2, QK-5).
10. **Other wall conditions.** Only the flavour-symmetric, charge-conjugation-invariant MIT walls `Q = ±1` were
    solved; the mixed walls `P = T16[0] Q` and the non-`J`-preserving covariant walls were described, not solved
    (section 4.6.3).

### 8.2 Assumptions made, not derived

1. **`a4` is free.** It is never given a value; nothing in the work determines it. The wall states are computed
   at a frozen `a4` (the adiabatic approximation, with `K_inf = k e^{a4}`), and the cosmology uses the
   asymptotic region of the generalized frame, not `a4` (sections 3.1.11, 4.3.3, 4.6.3).
2. **The present universe is the asymptotic Bianchi-I region** of the generalized warped frame, valid when
   `24 (H/H_A)^2 Cot^2/C^2 << 1`; the frozen and dust-driven solutions solve the warped equations only up to
   `O(e^{-12Hz})` terms, including an `x0`-momentum flux (sections 4.3.3, 4.3.4).
3. **The (0,4) equation singles out, but does not derive, the author's volume-preserving structure** (with
   `C = 1` and `T^4_0 = 0`; with `C` dynamical, positive-energy expansion is allowed) (section 4.3.2).
4. **The admissible theory is a truncation** to fields independent of `x5..x7` with a finite hidden coordinate
   volume `V_hid`; compactifying the timelike `x5..x7` produces closed timelike curves; `x0` is taken as
   compactified at large `z` with a Kaluza–Klein gap `1/L0 >> T_max`, so that all matter is in zero modes
   (sections 3.5.4, 4.7.1).
5. **The beginning of the present universe** is not fixed by the pre-universe: `a_i <= min(1e-10, 0.01 a_nr(m))`
   is chosen on physical grounds (before nucleosynthesis, fable ultra-relativistic) and shown not to matter;
   `g_*(T)` is not followed (a factor `0.46–0.83` on `rho_r a^4` at `a ≈ 1e-12`) (section 4.7.2).
6. **Semiclassical gravity** with the Kohn–Sham expectation value as the source; the split of the fable into
   dark matter and dark energy is a **convention** (the condensate `rho_U` is an 8-dimensional vacuum energy)
   (sections 4.2.1, 4.5.10).

### 8.3 Where the answers stop

- **[1]** A time-varying dark-energy equation of state exists formally in the stabilized model with a
  mass-varying potential, but in no run is it viable: with a bare `Lambda` the inferred dark energy is a
  cosmological constant; with a mass-varying potential the fable's own `w_f` never goes below −1, while the
  observer-inferred dark energy has a pole and is phantom or crosses −1 (apparent, from the dark-sector
  energy exchange); the fable is massless through the matter era unless it is a power law with a positive
  bare mass (`nu < 0.279` at the observed split), and every massive case is adiabatically unstable; the
  neglected Dirac-sea energy is enormous; the stabilizer violates the null energy condition; without it `G`
  varies far beyond the bounds (section 4.8.1). Whether any modification (a derived stabilizer, the sea
  energy included, perturbations) could make it viable is open.
- **[2]** A time-varying dark-matter equation of state exists intrinsically (1/3 to 0 around
  `a_nr ∝ m^(-4/3)`), but for the masses that free streaming and phase space allow (about 1 keV and above) the
  change happens around `a_nr ≈ 4e-8` to `2e-8`, long before recombination: indistinguishable from cold dark
  matter in the late universe (section 4.8.2).

### 8.4 Records that are incomplete

- The console output and the duration of the Mathematica reference script of the coupled system
  (`make_reference_fermion.wls`) and the duration of the TeX export were not captured in a repository log;
  their products are checked by Part VIII and by notebook 06 instead (sections 6.3.6, 6.3.7).
- Two claims of the review about the wall-state numerics (a fixed matching point losing a level, a uniform
  frequency grid missing a shallow level) were not re-tested, because the method used does not have those
  weaknesses (section 5.8, item 3).
- The development logs of the wall-state solver live in the ignored `fable-cosmology/fermion/dev/`; the
  committed report quotes them, and notebook 07 re-runs what matters.

### 8.5 What is still to be done when this page is written

- Section 1, the complete set of ideas of all efforts (identical on the three pages of 2026-09-24), which
  is filled when every effort's results are in.
- The LaTeX twins and PDFs of the pages of Efforts B and C, built with `build_all.sh` (section 6.9).
- The final commit and push, recorded in section 7.4, and the fresh-clone verification of the pushed
  repository, recorded in section 7.3.
