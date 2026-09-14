# Provenance 01 — Building and running `claude-fable_Einstein-Rosen-2-Planes.nb`

**Effort.** Refine and refactor the whole of
`Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb` into a new, commented,
optimized notebook at `C:\Users\nsh\Documents\8-dim\claude-fable_Einstein-Rosen-2-Planes.nb`,
and prove that the notebook executes cleanly from end to end.

Everything needed to repeat this work is on this page. No other file needs to be consulted.

---

## 1. What was produced

| file | bytes | what it is |
|---|---|---|
| `C:\Users\nsh\Documents\8-dim\claude-fable_Einstein-Rosen-2-Planes.nb` | 136119 | the deliverable notebook: 211 cells, 139 of them Input |
| `Pre-Universe_14SEP26-77\claude-fable\cells_part1.wl` | — | source manifest, sections 0–4 |
| `Pre-Universe_14SEP26-77\claude-fable\cells_part2.wl` | — | source manifest, sections 5–9 |
| `Pre-Universe_14SEP26-77\claude-fable\cells_part3.wl` | — | source manifest, sections 10–14 |
| `Pre-Universe_14SEP26-77\claude-fable\cells_part4.wl` | — | source manifest, sections 15–21 |
| `Pre-Universe_14SEP26-77\claude-fable\build_tools.py` | — | turns the manifests into the `.nb` and into a runnable `.wls` |
| `Pre-Universe_14SEP26-77\claude-fable\runner_header.wl` | — | the test harness that times each cell and collects every message |

The notebook is generated from the four manifests rather than edited by hand. That is what
guarantees that the code inside the notebook and the code that was tested are the same bytes.

## 2. Structure of the notebook

| part | sections | Input cells | content |
|---|---|---|---|
| I | 1–9 | 1–52 | flat metric, SO(4) blocks, 8×8 `τ`, 16×16 `T16`, `SAB`, the 256/64/16-element matrix bases, 4×4 Dirac, Cartan triality |
| II | 10–14 | 53–90 | `Ψ16`, the Lagrangian, Euler–Lagrange, the (z,t) chart, the four coupled blocks, the Maple solutions, bilinears, M6 |
| III | 15–17 | 91–116 | the frame field, the canonical spin connection, the 16-component spinor covariant derivative |
| IV | 18–21 | 117–139 | three new bridges, three new spin connections, and the master comparison |

Exact section-to-cell map:

| section | Input cells |
|---|---|
| 1. Session setup | 1–6 |
| 2. Coordinates and the flat 4+4 Minkowski metric eta | 7–12 |
| 3. SO(4) self-dual and anti-self-dual 4×4 matrices | 13–15 |
| 4. The real 8×8 Clifford generators tau and the spinor metric sigma | 16–21 |
| 5. The 16×16 Dirac matrices T16, chirality, sigma16, so(4,4) generators | 22–29 |
| 6. A complete basis of the 16×16 matrix algebra | 30–35 |
| 7. A complete basis of the 8×8 matrix algebra | 36–38 |
| 8. The 4×4 Dirac matrices and the 4×4 matrix basis | 39–44 |
| 9. Cartan triality and the split-octonion structure constants | 45–52 |
| 10. Housekeeping and the two helper packages | 53–55 |
| 11. The wave function and its Lagrangian | 56–60 |
| 12. Euler–Lagrange, the coupling pattern, the (z,t) chart | 61–66 |
| 13. Decoupling into four blocks and the closed-form solutions | 67–78 |
| 14. Bilinears, the two branches, M6 = 3 generations | 79–90 |
| 15. The local flat Minkowski system at every point (the frame field) | 91–99 |
| 16. Christoffel symbols and the canonical spin connection | 100–110 |
| 17. The gauge-covariant derivative of the 16-component spinor | 111–116 |
| 18. Bridge 1 — locally boosted frame | 117–122 |
| 19. Bridge 2 — null (light-cone) frame | 123–127 |
| 20. Bridge 3 — triality frame with octonionic torsion | 128–135 |
| 21. Master comparison | 136–139 |

## 3. Prerequisites

```bash
which wolframscript && wolframscript -version && wolframscript -code '$Version'
```

Expected:

```
/c/Program Files/Wolfram Research/WolframScript/wolframscript
WolframScript 1.14.0 for Microsoft Windows (64-bit)
15.0.1 for Microsoft Windows (64-bit) (July 2, 2026)
```

Two helper packages written by the author must sit next to the notebook. Put them there:

```bash
cd "C:/Users/nsh/Documents/8-dim"
cp Pre-Universe_14SEP26-77/ConvertMapleToMathematicaV2.wl .
cp Pre-Universe_14SEP26-77/EtoExp.wl .
ls -la ConvertMapleToMathematicaV2.wl EtoExp.wl
```

If they are missing, section 10 of the notebook prints `MISSING FILE` together with every path it
searched, and section 13 prints
`CANNOT PARSE THE MAPLE SOLUTIONS: ConvertMapleToMathematicaV2.wl was not found.` — it does not
silently substitute a home-made parser.

## 4. Back up before overwriting

```bash
cd "C:/Users/nsh/Documents/8-dim"
mkdir -p Pre-Universe_14SEP26-77/backups
if [ -f claude-fable_Einstein-Rosen-2-Planes.nb ]; then
  cp -p claude-fable_Einstein-Rosen-2-Planes.nb \
     "Pre-Universe_14SEP26-77/backups/claude-fable_Einstein-Rosen-2-Planes.nb.bak-$(date +%Y%m%d-%H%M%S)"
fi
ls -la Pre-Universe_14SEP26-77/backups/
```

## 5. Rebuild the notebook from the manifests

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"
python build_tools.py 2>&1 | tee build.log
cat build.log
```

Expected:

```
manifest files : ['cells_part1.wl', 'cells_part2.wl', 'cells_part3.wl', 'cells_part4.wl']
cells parsed   : 211 {'Title': 4, 'Text': 46, 'Section': 22, 'Input': 139}
run_all.wls    : 139 Input cells
notebook       : 211 cells -> C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\claude-fable\claude-fable_Einstein-Rosen-2-Planes.nb
```

Then copy it to the deliverable location:

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"
cp claude-fable_Einstein-Rosen-2-Planes.nb "C:/Users/nsh/Documents/8-dim/"
ls -la "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb"
```

## 6. Check that the `.nb` is well formed and every Input cell parses

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"
cat > verify_nb.wls <<'WLSEOF'
nbfile = "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb";
Print["file bytes: ", FileByteCount[nbfile]];
nb = Import[nbfile, "Notebook"];
Print["Head: ", Head[nb]];
cells = Cases[nb, Cell[__], Infinity];
Print["cells: ", Length[cells]];
Print["style tally: ", Tally[Cases[cells, Cell[_, s_String, ___] :> s]]];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
Print["input cells: ", Length[inputs]];
Print["total input characters: ", Total[StringLength /@ inputs]];
bad = {};
Do[Module[{e = Quiet@Check[ToExpression[inputs[[i]], InputForm, HoldComplete], $Failed]},
    If[e === $Failed || Head[e] =!= HoldComplete, AppendTo[bad, i]]], {i, Length[inputs]}];
Print["input cells that FAIL to parse: ", bad];
WLSEOF
timeout 900 wolframscript -file verify_nb.wls 2>&1 | tee verify_nb.log
cat verify_nb.log
```

Expected:

```
file bytes: 136119
Head: Notebook
cells: 211
style tally: {{Title, 4}, {Text, 46}, {Section, 22}, {Input, 139}}
input cells: 139
total input characters: 88829
input cells that FAIL to parse: {}
```

## 7. Execute the notebook itself, end to end

This is the real test: it imports the delivered `.nb`, takes its Input cells in order, and
evaluates each one in a fresh kernel, exactly as the front end would.

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"
cat > runner_header.wl <<'WLSEOF'
(* Harness: evaluate every notebook Input cell in order, in one kernel, reporting timing and
   every message raised. *)

$cfCellLog = {};
$cfMessages = {};

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

cfRunSummary[] := Module[{tot, slow},
  tot = Total[#["seconds"] & /@ $cfCellLog];
  slow = Reverse[SortBy[$cfCellLog, #["seconds"] &]][[1 ;; Min[12, Length[$cfCellLog]]]];
  Print["==================== RUN SUMMARY ===================="];
  Print["cells evaluated : ", Length[$cfCellLog]];
  Print["total seconds   : ", ToString[NumberForm[N[tot], {10, 3}, ExponentFunction -> (Null &)]]];
  Print["cells w/ msgs   : ", Length[$cfMessages]];
  If[$cfMessages =!= {},
    Print["---- messages ----"];
    Scan[Print["  cell ", #[[1]], ": ", #[[2]]] &, $cfMessages]];
  Print["---- slowest cells ----"];
  Scan[Print["  cell ", #["cell"], "  ",
     ToString[NumberForm[N[#["seconds"]], {8, 3}, ExponentFunction -> (Null &)]], " s"] &, slow];
  Print["==================== ASSERTIONS ===================="];
  Module[{n = Length[$cfAssertLog], bad = Cases[$cfAssertLog, {l_, False} :> l]},
    Print["assertions run  : ", n];
    Print["passed          : ", n - Length[bad]];
    Print["FAILED          : ", Length[bad]];
    Scan[Print["  FAIL: ", #] &, bad]];
  Print["===================================================="];
  ];
WLSEOF
cat > run_from_nb.wls <<'WLSEOF'
(* Execute the notebook itself: import the .nb, take its Input cells in order, evaluate each.
   ToExpression[...,Hold] on a multi-line cell returns Hold[e1,e2,...]; rewrap those as one
   CompoundExpression so the cell evaluates as a single unit, exactly as the front end does. *)
Get["C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable/runner_header.wl"];
nbfile = "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb";
SetDirectory["C:/Users/nsh/Documents/8-dim"];
nb = Import[nbfile, "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
Print["evaluating ", Length[inputs], " Input cells straight out of the .nb"];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
Do[cfRunCell[i, asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, Length[inputs]}];
cfRunSummary[];
WLSEOF
timeout 3000 wolframscript -file run_from_nb.wls 2>&1 | tee run_from_nb.log
sed -n '/RUN SUMMARY/,$p' run_from_nb.log
```

Expected tail:

```
==================== RUN SUMMARY ====================
cells evaluated : 139
total seconds   : 140.600
cells w/ msgs   : 0
---- slowest cells ----
  cell 80  75.065 s
  cell 88  24.810 s
  cell 86   8.921 s
  ...
==================== ASSERTIONS ====================
assertions run  : 175
passed          : 175
FAILED          : 0
====================================================
```

The three numbers that matter:

- **`cells evaluated : 139`** — every Input cell ran.
- **`cells w/ msgs : 0`** — the notebook raises no errors and no warnings.
- **`assertions run : 175  passed : 175  FAILED : 0`** — every identity the notebook claims was
  checked and holds.

Wall-clock time is roughly 140 s on this machine; it will vary.

To see the individual assertion verdicts:

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"
grep -c 'PASS' run_from_nb.log       # 175
grep    'FAIL' run_from_nb.log       # only the "FAILED : 0" summary line
grep -n 'MESSAGES' run_from_nb.log   # no hits
```

## 8. How the notebook certifies its own identities

Section 1 keeps the original notebook's session policy unchanged — `Simplify` with a 1-second
budget and `FullSimplify` with 3 seconds. That budget is right for the exact-integer algebra of
Parts I and II, but not always enough for the curved-space expressions of Parts III and IV, which
mix `Tan`, `Sin^(1/6)`, `Exp` of the undetermined function `a4`, and `Cosh`/`Sinh` of an
undetermined rapidity. Rather than change the original's policy, the notebook escalates in three
stages (`cfZeroQ` and `cfZeroArrayQ`, defined in section 15):

1. exact structural equality — the entry is literally `0`;
2. `Simplify` under the geometric assumptions with a 5-second budget;
3. a high-precision numerical certificate — substitute concrete probe functions for the
   undetermined `a4` and rapidity, evaluate at three rational sample points inside the assumed
   domain (`H > 0`, all `x > 0`, `0 < 6 H x0 < Pi/2`), evaluate to 30 significant digits with up
   to 200 digits of extra working precision, and require the magnitude to be below `10^-22`.

Stage 3 uses the probes as *test inputs only*. They are never definitions: `a4` and the rapidity
stay undetermined everywhere else, and no stated result depends on the particular probes. The
counter `$cfNumericCertificates` records how many checks needed stage 3. To see it:

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"
grep 'numerical certificates used' run_from_nb.log
```

which prints `numerical certificates used: 6`. So 169 of the 175 assertions are settled purely
symbolically and only 6 need the numerical certificate.

`N::meprec` is suppressed inside stage 3, and only there. Evaluating an expression that is
identically zero in arbitrary precision always ends by raising it, because no amount of working
precision produces the requested significant digits of zero — the message is the expected signal
of success, and `Chop` is what actually decides.

## 9. Optimizations made, and what was deliberately not changed

Changed, with the mathematics identical:

| original | refactor | why |
|---|---|---|
| eight nested `Do` loops with `AppendTo` building the 256-element basis | `Subsets[Range[0,7],{k}]` | same list in the same lexicographic order, quadratically faster; the original's positional references `base16[[93]]` and `base16[[255]]` are re-verified |
| `FullSimplify` wrapped around exact-integer matrix identities | dropped | a no-op that cost several seconds per cell |
| `g` derivatives recomputed inside the Christoffel triple loop | computed once into `dg[[k,m,p]]` | same values |
| Christoffel symbols recomputed for each of the four frames | computed once and passed in | they are a property of `g` alone |
| pages of nested `True` lists as output | one `PASS`/`FAIL` line per identity via `cfAssert` | readable |
| `Needs["Notation`"]` and 30 `Symbolize` declarations | plain ASCII symbol names | `Notation`` needs a front end; the notebook now runs headless |
| `NotebookFileName[]` used directly | guarded, with a fallback to `Directory[]` | `NotebookFileName[]` returns `$Failed` in a headless kernel |
| the 8-component position vector called `Z` | renamed `Zoct` | in the original it collides with the head `Z[k]` used for the wave-function components in the same session |

Deliberately **not** changed: every constant, every tolerance, the `TimeConstraint` settings, the
control flow of `eL`, the Lagrangian coefficients, the Maple solution strings, and the assumption
sets `ssX` and `constraintVars`.

## 10. Symbols the original leaves undefined

The notebook reports them rather than inventing values. Section 15 prints:

```
  NOTE  a4 is an undefined scalar function inherited from the original notebook
        The canonical frame field below contains Exp[-a4[H x4]] and Exp[+a4[H x4]].  The original
        notebook never gives a4 a definition; it appears only inside the recorded value of the
        frame field.  We therefore carry a4 through symbolically and we do NOT invent a value for
        it.  Every result in Parts III and IV is valid for an arbitrary differentiable a4.  The
        same applies to la, which occurs only inside the assumption ssX of Section 2.
```

Two cells of the original (`resolution` and `resolution2`) are laid out as several side-by-side
columns with pasted images used as superscripts inside `Print` strings, and cannot be transcribed
into linear code unambiguously. The notebook says so in section 14 and re-implements the *checks*
those cells perform rather than guessing at their text.

## 11. Files this effort writes when the notebook runs

Section 12 calls `DumpSave` exactly as the original does, into the notebook's own directory:

```bash
ls -la "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes-eLa.mx" \
       "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes-eLazt.mx"
```

Expected sizes 2,696 and 3,144 bytes. To turn the writing off, set `$cfWriteMX = False` in the
cell that defines it.
