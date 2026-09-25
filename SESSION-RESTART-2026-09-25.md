# Session restart — the fermion-fable task of 2026-09-24, paused 2026-09-25

This file lets a new Claude session (or a person) pick up the unfinished task exactly where it
stopped. It is not a provenance page; it is the hand-off. Delete it once the task is finished.

## 1. How to restart

**Option A: resume this same session.** This is the best option, because it keeps the whole
context. In the Claude desktop app, open the Code tab and click this session in the sidebar.
From a terminal, run `claude --resume` in `C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77`
and pick the session. Then type:

> resume today's task from SESSION-RESTART-2026-09-25.md and run it to completion

**Option B: start a new session** in the repository folder
`C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77`, and paste this prompt:

> Resume the unfinished fermion-fable task of 2026-09-24 in this repository. Read
> `SESSION-RESTART-2026-09-25.md` in the repository root in full, then carry out its section 4,
> "Remaining steps", in order, with no shortcuts. The scratch materials are in
> `C:\Users\nsh\Documents\8-dim\session-handoff-2026-09-25\`. Push each verified step to `main` on
> `origin` (https://github.com/once-ere/Pre-Universe_with_Claude.git), and never push to the
> `upstream` remote. Finish with a fresh-clone verification of the pushed `main`, and report.

The project memory contains a pointer to this file, so a new session in this folder also finds
it on its own.

## 2. The task (the author's request of 2026-09-24, in its operative parts)

- **Effort A.** Refine the 16-component fermi spinor field fable to be a complex 16-spinor.
  Quantize it by canonical quantization, extended to 4+4 dimensions. Write out its field equations
  in the presence of the primordial gravitational field. Create new provenance markdown, LaTeX
  and PDF files containing:
  - the exact field equations;
  - the energy–momentum tensor operator, pressure, density and equations of state;
  - a complete discussion of the canonical spin connection.
- **Effort B.** Include fable as a source in the Einstein equations of the primordial
  gravitational field. Solve the coupled equations from the beginning of the present universe to
  the present time. Use ideas from density functional theory to obtain the fable ground and first
  excited states. Create another provenance markdown + LaTeX + PDF covering:
  - the coupled equations;
  - the canonical spin connections of the interacting system;
  - the energy–momentum tensor operator, pressure, density and equations of state.

  It must answer:
  - [1] Does this system provide a physical mechanism for a time-varying dark-energy `w`?
  - [2] Does it provide one for a time-varying dark-matter `w`?
- **Effort C.** Thoroughly discuss the commands used to solve, test, verify, execute and
  display the calculations. Create another provenance markdown + LaTeX + PDF with the complete
  solution. Rules for all three pages:
  - Each major effort has its own section.
  - Never refer the reader to another markdown file for any reason.
  - "The full set of 100% complete ideas" gets its own section in each markdown file.
- Push to https://github.com/once-ere/Pre-Universe_with_Claude.git and check and verify the
  repository. "DO NOT TAKE SHORTCUTS."

## 3. State at the pause (`main` = `f2ce96f`, pushed and matching `git ls-remote`)

**Done, verified and pushed:**

| what | where | verification |
|---|---|---|
| the 2026-09-16 foundation, completed | `e34d454`, `028b379`, `2f6d322` | fresh local clone; run_all.sh; results byte-identical |
| design, and an adversarial review with 4 reviewers and 4 skeptics | scratch `design/` (see §5) | 50 findings: 30 confirmed, 20 partly confirmed, 0 refuted; all adopted |
| notebook Part VII (fermion fable) | `claude-fable/cells_part7.wl`, `4fdfc40` | independent re-run: 528/528 |
| notebook Part VIII (Einstein–fable), notation fix | `cells_part8.wl`, `bc04ed1`, `3a5020d` | the final run: **217 Input cells, 644/644, 0 messages**, `claude-fable/run_fermion_fable_final.log` |
| the fermion solver crate `fable_fermion` | `c5892bd`, `2bc936d`, `3a5020d` | `cargo test --release`: 23 + 11 pass; `fermion/crosscheck.py` PASSED (1.1e-8) |
| wall-state solver `fermion/waveguide.py` and its Mathematica derivation and check | `18a2501`, `aca5102` | validate 64/64 (exits 1 on failure); derivation 94/94; Mathematica check 11/11 |
| notebooks 05, 06, 07; nbgen fixes for 01–04; setup/run_all for both crates; student README §14–16 | `aca5102` | nbcheck 7/7; run_all.sh passes; 01–04 results byte-identical |
| the delivered notebook copy | `C:\Users\nsh\Documents\8-dim\claude-fable_Einstein-Rosen-2-Planes.nb` | SHA-256 equals the committed `.nb` (after `3a5020d`) |
| root README (Parts VII–VIII, counts, pages 14–16) | `38701ef` | links 14–16 |
| PROVENANCE-14 (md, tex, pdf) | `fee5603`, then updated in `f2ce96f` | fact-checked once (7 corrections); final counts in |
| PROVENANCE-15 (md, tex, pdf) | `38701ef`, then updated in `f2ce96f` | NB07 marks resolved; final counts in; **not yet adversarially fact-checked** |
| PROVENANCE-16 (md, tex, pdf) | `38701ef` | written from the pre-update 14/15; **not yet regenerated or fact-checked** |

**Fresh-clone verification of `3a5020d` (interrupted by the pause).** The record is in
`session-handoff-2026-09-25/freshclone-record/VERIFY.txt`. Steps 1–4 passed:

1. The clone from GitHub was at `3a5020d`.
2. `setup.sh` passed, building both crates.
3. `run_all.sh` passed: fable_cosmo 7 tests, fable_fermion 23 + 11, **nbcheck 7/7**, and the paper.
4. **All 171 committed result/reference/figure files regenerated byte-identical.** Notebook output
   text differs only in timings and in how stdout was split into chunks. That was being confirmed
   when the pause came.

Steps 5–9 did not run: the Mathematica notebook run in the clone, the waveguide checks,
crosscheck and reference regeneration, build_all.sh, and the summary.

**Not yet done:** see §4.

**Leave alone:** `Pair_Creation_of_Universes_WaveFunctionOfUniverse-4+4-Einstein-Lovelock-Nash.nb`
in the repository root. It appeared there during the session, is not part of this work, and is the
author's file. Do not commit it unless the author asks.

## 4. Remaining steps, in order

1. **Regenerate PROVENANCE-16** from the updated PROVENANCE-14/15. Use the generators in
   `session-handoff-2026-09-25/scratchpad/p16/` (`mksubst.py`, then `build16.py`; `check16.py`
   checks the result) and `.../p16tex/` (`build16tex.py`). Then update PROVENANCE-16's own parts
   (`p16/parts/*.md` and the tex parts) for the final facts:
   - the final run: 644/644, 198.352 s, 46 witnesses, the Rust-vs-Mathematica checks passing;
   - the Part VIII omega index-notation correction (`3a5020d`), in the design-review "later
     corrections" list and in Effort B's spin-connection text;
   - the models.rs comment fix;
   - the commit table through the final commit.

   **The generators contain the absolute scratch path of the original session**, in the form
   `C:/Users/nsh/AppData/Local/Temp/claude/C--Users-nsh-Documents-8-dim-Pre-Universe-14SEP26-77/a4cc01b9-bc82-49b5-8384-6abeb2e19ce5/scratchpad`.
   That folder may still exist. If it does not, rewrite the prefix in the copies to
   `C:/Users/nsh/Documents/8-dim/session-handoff-2026-09-25/scratchpad`, for example with
   `grep -rl ...scratchpad . | xargs sed -i 's#<old>#<new>#g'` run inside the handoff folder.
2. **Update the complete set of ideas and insert it.**
   - Its source is `scratchpad/docs-shared/_ideas_src/ideas_src.txt` (about 490 numbered items in
     26 groups, fact-checked once). The generator is `gen_ideas.py`, which writes
     `docs-shared/complete-set-of-ideas.md` and `.tex` from the one source, so they stay identical.
   - Add the `3a5020d` notation fix, the models.rs comment fix, the final run figures and the
     fresh-clone result.
   - Replace the placeholder `{{COMPLETE-SET-OF-IDEAS}}` in section 1 of all three `.md` files with
     the generated markdown.
   - In the three `.tex` files, replace `\texttt{\{\{COMPLETE-SET-OF-IDEAS\}\}}` with
     `\input{ideas/complete-set-of-ideas}`, after copying the fragment to
     `provenance-latex/ideas/complete-set-of-ideas.tex`.
   - Confirm by script that the inserted list is byte-identical in the three `.md` files.
3. **Adversarially fact-check** PROVENANCE-14, -15 and -16, markdown and LaTeX, against the
   committed sources:
   - `claude-fable/run_fermion_fable_final.log` and `run_fermion_fable_part7.log`;
   - the manifests `cells_part7.wl` and `cells_part8.wl`;
   - the executed notebooks 05–07 and `fable-cosmology/results/nb05_*`, `nb06_*`, `nb07_*`;
   - `fable-cosmology/fermion/waveguide_REPORT.txt`;
   - `git log`.

   Enforce the author's rules: grep each page for `.md`, `see PROVENANCE`, `README` and `DESIGN`.
   The workflow script `workflow-scripts/finalize-provenance-documents-wf_23ff07f9-c60.js` in the
   handoff folder is the exact orchestration that was running. Its stages are
   Update → Regenerate → Ideas → Check → Build, and Update has already finished. Reuse it, with
   its paths adjusted, to run the rest.
4. **Build the PDFs**: `bash provenance-latex/build_all.sh`, with no errors, no undefined
   references and no overfull box above 10pt. Then commit and push.
5. **Fresh-clone verification of the pushed `main`.** Clone into a scratch folder and run:
   `bash fable-cosmology/setup.sh`, `bash fable-cosmology/run_all.sh`, then compare every tracked
   result file byte for byte. After that, from inside `claude-fable/`, run
   `wolframscript -file run_from_nb.wls`, which must give 217 cells, 644/644 and 0 messages with
   the two Rust checks passing. Then run `waveguide.py validate` (64/64), the waveguide derivation
   (94/94, with the T16 JSON byte-identical), `fermion/crosscheck.py`, both reference scripts,
   and `bash provenance-latex/build_all.sh`. The script `freshclone-record/rec.sh` and the compare
   scripts in the handoff folder do this.
6. **Fill `{{FRESH-CLONE}}` and `{{FINAL-PUSH}}`** in the three pages and in the ideas item with
   the real results and hashes. Rebuild the PDFs, commit, push, and confirm with
   `git ls-remote origin refs/heads/main`.
7. **Memory.** Update `claude-fable-notebook-project` (Parts VII–VIII, 217 cells, 644
   assertions). Then delete this restart file and its memory pointer, and push.

## 5. Where everything is

- **Repository:** `C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77`. Push only to `origin`
  (`once-ere/Pre-Universe_with_Claude`), never to `upstream`.
- **Handoff folder** (not in git): `C:\Users\nsh\Documents\8-dim\session-handoff-2026-09-25\`
  - `scratchpad/design/`
    - `DESIGN-FERMION-FABLE.md` and `DESIGN-REV2-ADOPTED-CORRECTIONS.md` (rev 2 overrides rev 1);
    - `DOCS-SPEC.md` (the page rules and outlines);
    - `TODO-FINAL.txt`;
    - the review records `review_partial.txt`, `review_new.txt`, `verdicts*.txt`.
  - `scratchpad/docs-shared/`: the fact-checked shared sections (foundations, canonical spin
    connection) and the complete-set-of-ideas source and generator.
  - `scratchpad/p14*`, `p15*`, `p16*`: the page generators and their parts.
  - `scratchpad/part7`, `part8`: the prototype states of the notebook parts.
  - `freshclone-record/`: VERIFY.txt, `rec.sh` and the compare scripts of the interrupted
    fresh-clone check.
  - `workflow-scripts/*.js`: every workflow that was run (design review, shared sections,
    pages 14/15/16, ideas, finalize).
- **The original scratch folder of the session** may still exist:
  `C:\Users\nsh\AppData\Local\Temp\claude\C--Users-nsh-Documents-8-dim-Pre-Universe-14SEP26-77\a4cc01b9-bc82-49b5-8384-6abeb2e19ce5\scratchpad`.

## 6. Rules learned the hard way (keep them)

- **The notebook** `claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb`
  - It is generated from `claude-fable/cells_part*.wl` by `python claude-fable/build_tools.py`.
    Never edit the `.nb`.
  - Run it from inside `claude-fable/`. From the root, the reference-CSV checks are skipped.
  - Every run rewrites `claude-fable/*.mx` with different bytes but the same content. Restore them
    with `git checkout -- claude-fable/*.mx` before committing.
- **Git Bash**
  - Long Python patch scripts must be written to a file and run from there. A long quoted heredoc
    breaks.
  - Use forward slashes in Wolfram paths.
  - Never run `taskkill /IM python.exe`: it kills every Python process, including other jobs.
- **The fermion solver**
  - `fable_fermion fable4d` is the physical, stabilized model. Its stabilizer violates the null
    energy condition along x0.
  - `fable8d` is the no-go demonstration.
  - Refusals (negative energy; first-order transitions) are grid-independent since `2bc936d`.
- **The design review corrected several first-draft claims.** The answers must keep these:
  - The quantized fable never crosses `w = −1`. An observer's CDM + DE fit shows an *apparent*
    phantom crossing when the fermion mass grows.
  - Mass-varying dark energy needs power laws with `ν < 0.279`, is adiabatically unstable, and
    needs a vacuum-energy fine-tuning of 1e13–1e16 `ρ_c`.
  - The dark-matter `w` falls from 1/3 to 0.
  - The mass bounds: `ΔN_eff` needs m > 10.3 eV; Tremaine–Gunn needs 231–358 eV; free streaming
    needs about 1.1–1.8 keV.
  - Unstabilized 8D changes G by 1e8–1e17.
