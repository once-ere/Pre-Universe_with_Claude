# Provenance 09 — Evaluating the notebook in Mathematica, and checking the output

**Effort.** Evaluate `claude-fable_Einstein-Rosen-2-Planes.nb` in Mathematica — both headlessly
in a kernel and in the actual front end — and then check the output: not merely that it ran, but
that every number it prints means what it says it means. Three defects were found and fixed; all
three were in prose or in a label, none changed a computed value.

Everything needed to repeat this work is on this page. No other file needs to be consulted.

---

## 0. Where things are

| what | path |
|---|---|
| repository | `C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77` |
| the notebook | `<repo>\claude-fable\claude-fable_Einstein-Rosen-2-Planes.nb` |
| a second copy, kept in step | `C:\Users\nsh\Documents\8-dim\claude-fable_Einstein-Rosen-2-Planes.nb` |
| cell manifests the notebook is built from | `<repo>\claude-fable\cells_part1.wl` … `cells_part4.wl` |
| build tool | `<repo>\claude-fable\build_tools.py` |
| harness | `<repo>\claude-fable\runner_header.wl` |
| scratch for this effort | `C:\Users\nsh\Documents\8-dim\eval-run\` |

The notebook is **generated** from the four manifests. It is never edited by hand. Any change
described below was made to a manifest and the notebook rebuilt.

## 1. Back up before touching anything

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77"
mkdir -p backups
cp -p claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb "backups/claude-fable_Einstein-Rosen-2-Planes.2026-09-14T1700.nb"
cp -p ../claude-fable_Einstein-Rosen-2-Planes.nb "backups/8-dim-copy_claude-fable_Einstein-Rosen-2-Planes.2026-09-14T1700.nb"
cp -p claude-fable/cells_part3.wl backups/cells_part3.wl.bak-20260914-1712
cp -p claude-fable/cells_part4.wl backups/cells_part4.wl.bak-20260914-1712
sha256sum claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb ../claude-fable_Einstein-Rosen-2-Planes.nb backups/*.nb
```

All four notebook copies hashed `a2ee160311e16e0ad3767c8a7e675a209555bec5302b6693ead03e39d32f031b`,
138 568 bytes. `backups/` is git-ignored, so these do not enter the history.

## 2. Evaluation A — headless kernel, straight out of the `.nb`

This is the definitive run. It imports the delivered notebook, takes its `Input` cells in
document order, and evaluates each one in a single fresh kernel. It does not use `run_all.wls`,
so it cannot pass because of anything that lives only in the build tooling.

`<repo>\claude-fable\run_from_nb.wls`, in full:

```wolfram
(* Execute the notebook itself: import the .nb, take its Input cells in order, evaluate each.
   ToExpression[...,Hold] on a multi-line cell returns Hold[e1,e2,...]; rewrap those as one
   CompoundExpression so the cell evaluates as a single unit, exactly as the front end does. *)
Get["runner_header.wl"];
nbfile = "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb";
nb = Import[nbfile, "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
Print["evaluating ", Length[inputs], " Input cells straight out of the .nb"];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
Do[cfRunCell[i, asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, Length[inputs]}];
cfRunSummary[];
```

Run it:

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"
wolframscript -file run_from_nb.wls 2>&1 | tee eval_kernel_1728.log
```

Final result:

```
==================== RUN SUMMARY ====================
cells evaluated : 139
total seconds   : 125.553
cells w/ msgs   : 0
==================== ASSERTIONS ====================
assertions run  : 182
passed          : 182
FAILED          : 0
====================================================
```

`cells w/ msgs : 0` is produced by `cfRunCell` in `runner_header.wl`, which captures
`$MessageList` inside a `Block` around each cell:

```wolfram
cfRunCell[n_Integer, held_Hold] := Module[{t, r, msgs},
  t = 0; r = Null;
  msgs = Block[{$MessageList = {}},
    {t, r} = AbsoluteTiming[ReleaseHold[held]];
    $MessageList];
  msgs = DeleteDuplicates[ToString[#, InputForm] & /@ msgs];
  AppendTo[$cfCellLog, <|"cell" -> n, "seconds" -> t, "messages" -> msgs|>];
  If[msgs =!= {}, AppendTo[$cfMessages, {n, msgs}]];
  Print["CELL ", n, "  t=", ToString[NumberForm[N[t], {8, 3}, ExponentFunction -> (Null &)]], " s",
    If[msgs === {}, "", "   MESSAGES: " <> ToString[msgs]]];
  r];
```

## 3. Evaluation B — the actual Mathematica front end

`NotebookEvaluate` is run on a **copy**, so the shipped file is never opened for writing.

Two traps were hit here and both are worth recording.

**Trap 1: `NotebookSave[nb, path]` returns `$Failed`.** The first attempt evaluated the notebook
correctly and then saved a file byte-identical to the input — no results inserted. Probing on a
truncated notebook showed the cause: `NotebookEvaluate` had inserted the `Output` cells
correctly, and it was the save that silently failed.

```bash
cd "C:/Users/nsh/Documents/8-dim/eval-run"
wolframscript -file probe_prefix.wls 2>&1 | tee probe_prefix.log
```
```
cells now in memory: {{Title,1},{Subtitle,1},{Subsubtitle,1},{Text,8},{Section,3},{Input,12},{Output,8}}
save  -> InputForm[$Failed]
```

The fix is to harvest with `NotebookGet` and write with `Export`.

**Trap 2: one kernel, two notebooks.** Running a self-test notebook and then the real one in the
same kernel raises `ClearAll::wrsym: Symbol DIM8 is Protected`, because Section 1 of the first
notebook executed `Protect[DIM8, M, K, H]`. That is an artifact of the harness, not of the
notebook. Each notebook gets its own kernel.

`C:\Users\nsh\Documents\8-dim\eval-run\fe_full.wls`, in full:

```wolfram
(* Evaluate the delivered notebook in the Mathematica FRONT END, on a COPY, in a CLEAN kernel.
   Nothing else runs in this kernel, so no earlier Protect[] can contaminate it.
   Results are harvested with NotebookGet, because NotebookSave[nb,path] returns $Failed here. *)
src = "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb";
dst = "C:/Users/nsh/Documents/8-dim/eval-run/evaluated.nb";
If[FileExistsQ[dst], DeleteFile[dst]];
CopyFile[src, dst];
Print["source   : ", FileByteCount[src], " bytes  sha256 ",
      IntegerString[Hash[ReadByteArray[src], "SHA256"], 16]];
t0 = AbsoluteTime[];
UsingFrontEnd[
  cfnb  = NotebookOpen[dst, Visible -> False];
  NotebookEvaluate[cfnb, InsertResults -> True];
  cfgot = NotebookGet[cfnb];
  NotebookClose[cfnb]];
Print["NotebookEvaluate + NotebookGet done in ", Round[AbsoluteTime[] - t0], " s"];
Export[dst, cfgot, "NB"];
Print["evaluated: ", FileByteCount[dst], " bytes"];
Print["styles   : ", SortBy[Tally[Cases[Import[dst, "Notebook"], Cell[_, s_String, ___] :> s, Infinity]], -Last[#] &]];
Print["source unchanged: ", IntegerString[Hash[ReadByteArray[src], "SHA256"], 16]];
pdf = "C:/Users/nsh/Documents/8-dim/eval-run/evaluated.pdf";
UsingFrontEnd[
  nb2 = NotebookOpen[dst, Visible -> False];
  Export[pdf, nb2];
  NotebookClose[nb2]];
Print["pdf bytes: ", FileByteCount[pdf], "   pages: ", Import[pdf, "PageCount"]];
```

```bash
cd "C:/Users/nsh/Documents/8-dim/eval-run"
wolframscript -file fe_full.wls 2>&1 | tee fe_full_1730.log
```

The front end agrees with the kernel: same 182 assertions, same 0 failures, and **110 `Output`
cells** inserted — exactly `139 - 29`, the 29 `Input` cells that end in `;` and print nothing.

## 4. Checking the output — how it was done

`Cases` at level 1 does **not** find `Output` cells in a real notebook: the front end wraps each
input/output pair in `Cell[CellGroupData[{...}, Open]]`. Use `Infinity`.

```bash
cd "C:/Users/nsh/Documents/8-dim/eval-run"
cat > check_out.wls <<'EOF'
dst = "C:/Users/nsh/Documents/8-dim/eval-run/evaluated.nb";
nb  = Import[dst, "Notebook"];
outs = Cases[nb, Cell[c_, "Output", ___] :> c, Infinity];
Print["Output cells            : ", Length[outs]];
Print["ErrorBox anywhere       : ", Length[Cases[nb, ErrorBox[___], Infinity]]];
txt[e_] := StringJoin[Cases[e, _String, Infinity]];
bad = {"$Failed", "$Aborted", "Indeterminate", "ComplexInfinity", "DirectedInfinity",
       "Missing[", "Interrupt"};
Do[Module[{t = txt[outs[[i]]]},
   Scan[If[StringContainsQ[t, #], Print["  SUSPECT output cell ", i, " contains ", #]] &, bad]],
  {i, Length[outs]}];
Print["suspect scan done"];
EOF
wolframscript -file check_out.wls 2>&1 | tee check_out.log
```

`Output cells: 110`, `ErrorBox anywhere: 0`, no suspects.

One false positive is worth recording so it is not rediscovered: scanning for the substring
`Null[` matches the connection's own display label `omegaNull[1;0,1]`. There is no `Null` in any
output.

To find the page a given result lands on in a rendered PDF, note that
`Import[pdf, {"Plaintext", All}]` is **not** a supported form and returns `pages: 0` with
`Part::partd`. The per-page form works:

```bash
cd "C:/Users/nsh/Documents/8-dim/eval-run"
cat > findpage.wls <<'EOF'
pdf = "C:/Users/nsh/Documents/8-dim/eval-run/evaluated.pdf";
n = Import[pdf, "PageCount"];
Do[t = Quiet@Check[Import[pdf, {"Plaintext", k}], ""];
   If[StringQ[t] && StringContainsQ[t, "difference from canonical"], Print["master table page: ", k]],
  {k, n}];
EOF
wolframscript -file findpage.wls 2>&1 | tee findpage.log
```

## 5. The results the run produces

Non-zero component counts, from the Section 21 fingerprint table:

| object | non-zero components |
|---|---|
| `Gamma` (Christoffel) | 37 |
| `omegaCanonical` | 24 |
| `omegaBoost` | 28 |
| `omegaNull` | 48 |
| `omegaTriLC` (λ=0) | 84 |
| `contortionOct` | 78 |
| `RiemannCanonical` | 156 |
| `RiemannBoost` | 156 |
| `RiemannNull` | 396 |
| `torsionOctFlat` | 48 |

These cross-check against the identities proved in the same sections rather than standing alone.
`deltaBoost`, the whole difference between Bridge 1 and the canonical connection, has **4**
non-zero components — one scalar gradient times one fixed generator — and `28 = 24 + 4`.
`omegaNull = U . omegaCanonical . U` with `U` a constant dense involution, so 24 → 48 is expected;
a constant orthogonal conjugation does not preserve the count. Same for `omegaTriLC` at 84.

The cross-check matters because a helper that simplifies array entries is easy to break
silently. `cfSimpArray` must map at the level of the **entries**:

```wolfram
cfSimpArray[arr_] := Map[If[# === 0, 0, cfSimp[#]] &, arr, {ArrayDepth[arr]}];
```

`Map[f, arr, {-1}]` maps over the *atoms* and is a silent no-op on compound entries, which
inflates every count computed afterwards. The manifest carries a one-line self-test next to the
definition: `cfSimpArray[{{Sin[x0]^2 + Cos[x0]^2 - 1, 0}}] === {{0, 0}}`.

## 6. Fidelity: the Euler–Lagrange equations still match the author's own files

The notebook `DumpSave`s `eLa` and `eLazt` each run. They are compared against the author's own
files, written before any of this work began.

`<repo>\claude-fable\mx_fidelity2.wls`, in full:

```wolfram
(* Compare the eLa/eLazt written by TODAY's two runs against the author's own DumpSave output.
   Clear[] has HoldAll, so plain Clear[eLa] is what clears the symbol; Clear[Evaluate[eLa]] does not. *)
src = "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/";
cf  = "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable/";
fe  = "C:/Users/nsh/Documents/8-dim/eval-run/";

Get[src <> "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLa.mx"];
srcELa = eLa; Clear[eLa];
Get[src <> "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLazt.mx"];
srcELazt = eLazt; Clear[eLazt];

Get[cf <> "claude-fable_Einstein-Rosen-2-Planes-eLa.mx"];    kerELa = eLa; Clear[eLa];
Get[cf <> "claude-fable_Einstein-Rosen-2-Planes-eLazt.mx"];  kerELazt = eLazt; Clear[eLazt];
Get[fe <> "evaluated-eLa.mx"];                               feELa = eLa; Clear[eLa];
Get[fe <> "evaluated-eLazt.mx"];                             feELazt = eLazt; Clear[eLazt];

cv = x0 > 0 && x4 > 0 && z > 0 && t > 0;
Print["lengths eLa   : author ", Length[srcELa],   "  kernel-run ", Length[kerELa],   "  front-end ", Length[feELa]];
Print["lengths eLazt : author ", Length[srcELazt], "  kernel-run ", Length[kerELazt], "  front-end ", Length[feELazt]];
Print["eLa   author === kernel-run (SameQ) : ", srcELa   === kerELa];
Print["eLa   author === front-end  (SameQ) : ", srcELa   === feELa];
Print["eLazt author === kernel-run (SameQ) : ", srcELazt === kerELazt];
Print["eLazt author === front-end  (SameQ) : ", srcELazt === feELazt];
Print["eLa   residual author - kernel-run  : ", Union@Flatten@Simplify[srcELa   - kerELa,   cv]];
Print["eLazt residual author - kernel-run  : ", Union@Flatten@Simplify[srcELazt - kerELazt, cv]];
```

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"
wolframscript -file mx_fidelity2.wls 2>&1 | tee mx_fidelity2.log
```
```
lengths eLa   : author 16  kernel-run 16  front-end 16
lengths eLazt : author 16  kernel-run 16  front-end 16
eLa   author === kernel-run (SameQ) : True
eLa   author === front-end  (SameQ) : True
eLazt author === kernel-run (SameQ) : True
eLazt author === front-end  (SameQ) : True
eLa   residual author - kernel-run  : {0}
eLazt residual author - kernel-run  : {0}
```

`DumpSave` output is not byte-deterministic, so the two `.mx` files in the repository change
size slightly on every run. Their **content** is identical, which is what the check above
establishes, so after a verification run they are restored rather than committed:

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77"
git checkout -- claude-fable/claude-fable_Einstein-Rosen-2-Planes-eLa.mx \
                claude-fable/claude-fable_Einstein-Rosen-2-Planes-eLazt.mx
```

A trap that cost one wasted run: `Clear` has attribute `HoldAll`. Writing
`Clear[Evaluate[sym]]` evaluates the symbol to its (large) value first and raises
`Clear::ssym`, leaving the symbol set. Every comparison after that is meaningless while
appearing to run. Use plain `Clear[eLa]`.

## 7. What the check of the output found, and what was changed

Eight independent reading passes over the run log and the four manifests raised 39 candidate
defects; each was then put to three independent reviewers whose instructions were to refute it.
36 were refuted. Three survived, and a fourth was established by direct measurement after the
majority had wrongly dismissed it. **All four are prose or labels. No computed value changed,
and the `.mx` comparison in section 6 above was re-run afterwards and still passes.**

### 7.1 `psi1sol` / `psi2sol` were called the type-1 and type-2 spinor halves. They are not.

`cells_part3.wl` Section 14 said "psi1 its type-1 half and psi2 its type-2 half". The code splits
the solution in the **relabelled** `yZ` basis:

```wolfram
\[Psi]sol  = Through[yZdef[z, t]] /. ssyZ;
\[Psi]1sol = \[Psi]sol[[1 ;; 8]];
\[Psi]2sol = \[Psi]sol[[9 ;; 16]];
```

The relabelling groups components by which four of them couple in the field equations. The
notebook's own Section 13 assertion — *"and NOT a direct sum: it mixes type-1 with type-2"* —
already proves that this regrouping is not the type-1/type-2 split, and the relabelling table it
prints shows it outright:

```
Z[0] -> yZ[0]   Z[5] -> yZ[1]   Z[8] -> yZ[2]   Z[13] -> yZ[3]
Z[1] -> yZ[4]   Z[4] -> yZ[5]   Z[9] -> yZ[6]   Z[12] -> yZ[7]
```

`yZ[0..7]` is four type-1 components (`Z0..Z7`) and four type-2 (`Z8..Z15`). The genuine type-1
and type-2 spinors appear two cells later as `Psi16ab[[1;;8]]` and `Psi16ab[[9;;16]]`.

The original notebook never made the type-1/type-2 claim about these bilinears — it calls them
"light-like quanta" — so this was introduced by the refactor and removing it restores fidelity.
The Text cell was rewritten, and two assertions were added so the point is checked rather than
asserted:

```wolfram
cfAssert["the yZ split at 8 is NOT the type-1/type-2 split",
  Sort[sZtOyZ[[1 ;; 8, 1]]] =!= Sort[Table[Z[k], {k, 0, 7}]]];
cfAssert["the first relabelled block holds four type-1 and four type-2 components",
  {Count[sZtOyZ[[1 ;; 8, 1]], Z[k_Integer] /; k <= 7],
   Count[sZtOyZ[[1 ;; 8, 1]], Z[k_Integer] /; k >= 8]} === {4, 4}];
```

**No number moved.** The branch `C2 -> -C1, C4 -> -C3` is written literally in the next cell,
exactly as the original notebook writes it; it is not derived from these bilinears. `Psi16ab`,
the triality vectors, both 7-planes and M6 are unaffected.

### 7.2 The notebook said `psi . sigma16 . psi` is identically zero, and contradicted itself

Section 14's text claimed "identically zero, as Section 11 showed". Section 11's identity is

```wolfram
cfAssert["Psi16 . sigma16 . T16[alpha] . Psi16 == 0 identically (antisymmetric form)", ...]
```

— **with** the `T16[alpha]` factor, which is what makes `sigma16 . T16[alpha]` antisymmetric.
`sigma16` alone is symmetric, so nothing forces the bilinear to vanish, and the notebook's own
comment fifteen lines below the claim said exactly that. The computed value is a non-trivial
exponential expression. The parenthetical was removed and two assertions added:

```wolfram
cfAssert["sigma16 alone is SYMMETRIC, so psi . sigma16 . psi is not forced to vanish",
  Transpose[\[Sigma]16] === \[Sigma]16];
cfAssert["and for this solution it does NOT vanish: it is not the zero expression",
  Simplify[psiSigma16psi, constraintVars] =!= 0];
```

### 7.3 The Bridge 3 spinor coupling was called "a cubic-in-gamma term". It is quadratic.

`cells_part4.wl` described

```
(lambda/8) mSkew[a,b,c] frameTri[[mu,c]] Commutator[gammaTri^a, gammaTri^b]
```

as cubic in gamma. Counting the gammas in that very expression gives two: the third
structure-constant index `c` is contracted against the **frame**, not against a third gamma. The
code agrees:

```wolfram
cfSpinMatrixTri[om_, mu_Integer] :=
  (1/8) Sum[om[[mu, a, b]] (T16Tri[a] . T16Tri[b] - T16Tri[b] . T16Tri[a]), {a, 8}, {b, 8}];
```

The genuinely cubic Einstein–Cartan axial term `T[a,b,c] gamma^a gamma^b gamma^c` appears only
after contraction with the `gamma^mu` of the Dirac operator, which this notebook does not
perform. The comment, the cell header and the Section 20 paragraph were corrected to say so.

### 7.4 "numerical certificates used: 6" did not mean what it said

This one was raised and then **wrongly refuted** by majority vote; it was settled by measurement.

`cfNumericallyZeroQ` is stage 3 of the zero test. `cfZeroQ` incremented `$cfNumericCertificates`
*before* calling it, so the counter rose whether the answer was "yes, zero" or "no, non-zero".
Instrumenting the function — wrapping `cfNumericallyZeroQ`, not `cfAssert`, because `cfAssert`
is not `HoldRest` and its argument is evaluated before it is ever entered — gave:

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"
wolframscript -file attribute_certs.wls 2>&1 | tee attribute_certs.log
```
```
counter says            : 6
cfNumericallyZeroQ calls: 9
  of which returned True (a genuine positive certification): 0
  of which returned False (i.e. the expression was shown NOT to vanish): 9
```

Zero. **No identity in this notebook rests on numerical evidence.** All six increments came from
the five `! TrueQ[cfZeroArrayQ[...]]` assertions that state something is *not* zero — that the
Bridge 3 torsion is really present, that the triality Dirac matrices really differ from the
vector ones, that `Lambda` is a boost and not a rotation, that the metric is non-degenerate, that
the extra spinor coupling is non-zero. For a negative claim a single sample point with a non-zero
value is a *complete* proof, so these are the strongest form the claim can take, not a weakened
one — the label simply described them backwards.

The counter was split in two and the outcome-dependent increment fixed:

```wolfram
cfZeroQ[e_] := Module[{s, r},
  If[e === 0, Return[True]];
  s = Simplify[e, cfGeomAssume, TimeConstraint -> 5];
  If[s === 0, Return[True]];
  r = cfNumericallyZeroQ[s];
  If[r, $cfNumericCertificates++, $cfNonVanishingWitnesses++];
  r];
```

The run now prints:

```
identities accepted on numerical evidence alone : 0   (stage 3 returned True)
non-vanishing witnesses                         : 6   (stage 3 returned False inside a ! TrueQ[...] assertion;
                                                     a sample point with a non-zero value is a complete proof of non-vanishing)
```

## 8. Rebuild and re-verify after the changes

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"
python build_tools.py 2>&1 | tee build_1725.log
cp -p claude-fable_Einstein-Rosen-2-Planes.nb "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb"
wolframscript -file run_from_nb.wls 2>&1 | tee eval_kernel_1728.log
```

```
cells parsed   : 213 {'Title': 4, 'Subtitle': 1, 'Subsubtitle': 1, 'Text': 46, 'Section': 22, 'Input': 139}
run_all.wls    : 139 Input cells
notebook       : 213 cells
...
cells evaluated : 139      total seconds : 125.553      cells w/ msgs : 0
assertions run  : 182      passed : 182                 FAILED : 0
```

Structure unchanged: 213 cells, 139 `Input`. Assertions went from 178 to 182 — the four added in
§7.1 and §7.2 — and all pass.

## 9. Messages and warnings that appear in the log, and what each one is

Hard rule 5 is "fix all errors and warnings", and hard rule 2 is fidelity to the source. Where
those pull in opposite directions the classification matters, so every line in the log that reads
like a warning is listed here with its verdict.

| line in the log | what it is |
|---|---|
| `ConvertMapleToMathematicaV2 loaded successfully!  BUT, WARNING:  DO NOT USE IF YOU WANT A CORRECT RESULT!` | the **author's own** text, printed by his own package on load. Preserved under fidelity. Not a defect of this work. |
| `EtoExp.wl loaded.  BUT, WARNING:  DO NOT USE IF YOU WANT A CORRECT RESULT!` | likewise the author's own text. |
| `block 1..4: returned unevaluated` | honest reporting. The original notebook's experience was that Mathematica does not solve these blocks, which is why the author turned to Maple. `cfDSolveTry` wraps `DSolve` in `TimeConstrained` and reports `TIMED OUT` / `DSolve reported an error` / `returned unevaluated` / a closed form, whichever happens. The Maple closed forms are then verified against all sixteen equations, and that assertion passes. |
| `EXPECTED MESSAGE  FullSimplify::time …` | announced before it can fire, suppressed only for `{FullSimplify::time, General::stop}` and only on the five bilinears. The 3-second budget is the original notebook's. A budget that is reached still returns a correct, merely less-simplified result. |
| `EXPECTED MESSAGES  Solve::ifun and Solve::svars …` | the light-cone conditions are transcendental, so `Solve` inverts an exponential and leaves a family rather than a unique solution. Suppressed by name only. |
| `EXPECTED MESSAGE  Solve::svars …` | two 7-planes fix two of eight components, leaving the six free parameters of M6. That is the result, not a failure. |
| `NOTE  a4 is an undefined scalar function …` | required disclosure under hard rule 3. The original never defines `a4`; it appears only inside the recorded frame field. It is carried symbolically and never invented. The same applies to `la`. |

`Off[General::spell]` and `Off[General::spell1]` in Section 1 are the original notebook's own
session policy, kept unchanged.

## 10. Reproducing the whole thing from nothing

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"

# 1. rebuild the notebook from the manifests
python build_tools.py 2>&1 | tee build.log

# 2. evaluate it headlessly, straight out of the .nb
wolframscript -file run_from_nb.wls 2>&1 | tee eval_kernel.log

# 3. evaluate it in the front end, on a copy, and render it
cd "C:/Users/nsh/Documents/8-dim/eval-run"
wolframscript -file fe_full.wls 2>&1 | tee fe_full.log

# 4. check the evaluated notebook's outputs
wolframscript -file check_out.wls 2>&1 | tee check_out.log

# 5. confirm the Euler-Lagrange equations still match the author's own .mx files
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"
wolframscript -file mx_fidelity2.wls 2>&1 | tee mx_fidelity2.log

# 6. restore the regenerated .mx files, whose content is identical but whose bytes are not
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77"
git checkout -- claude-fable/claude-fable_Einstein-Rosen-2-Planes-eLa.mx \
                claude-fable/claude-fable_Einstein-Rosen-2-Planes-eLazt.mx
git status --porcelain=v1
```

Expected: 139 cells, ~125 s, 0 cells with messages, 182 of 182 assertions passing, 110 `Output`
cells in the evaluated copy, 0 `ErrorBox`, and `SameQ` against both of the author's `.mx` files.
