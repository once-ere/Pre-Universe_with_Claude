# Provenance 01 — Building and running `claude-fable_Einstein-Rosen-2-Planes.nb`

**Effort.** Refine and refactor the whole of
`Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb` into a new, commented,
optimized notebook at `claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb`,
and prove that the notebook executes cleanly from end to end.

Everything needed to repeat this work is on this page. No other file needs to be consulted.

---

## 1. What was produced

| file | bytes | what it is |
|---|---|---|
| `Pre-Universe_14SEP26-77\claude-fable\claude-fable_Einstein-Rosen-2-Planes.nb` | 144787 | **the deliverable notebook**: 213 cells, 139 of them Input. This is the copy git tracks. |
| `C:\Users\nsh\Documents\8-dim\claude-fable_Einstein-Rosen-2-Planes.nb` | 144787 | a byte-identical copy delivered to the requested path, outside the repository |
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
REPO="$(git rev-parse --show-toplevel)"
cd "$(dirname "$REPO")"          # the author's delivery folder; optional
cp "$REPO/ConvertMapleToMathematicaV2.wl" .
cp "$REPO/EtoExp.wl" .
ls -la ConvertMapleToMathematicaV2.wl EtoExp.wl
```

If they are missing, section 10 of the notebook prints `MISSING FILE` together with every path it
searched, and section 13 prints
`CANNOT PARSE THE MAPLE SOLUTIONS: ConvertMapleToMathematicaV2.wl was not found.` — it does not
silently substitute a home-made parser.

## 4. Back up before overwriting

```bash
cd "$(dirname "$(git rev-parse --show-toplevel)")"   # the author's delivery folder; optional
mkdir -p Pre-Universe_14SEP26-77/backups
if [ -f claude-fable_Einstein-Rosen-2-Planes.nb ]; then
  cp -p claude-fable_Einstein-Rosen-2-Planes.nb \
     "Pre-Universe_14SEP26-77/backups/claude-fable_Einstein-Rosen-2-Planes.nb.bak-$(date +%Y%m%d-%H%M%S)"
fi
ls -la Pre-Universe_14SEP26-77/backups/
```

## 5. Rebuild the notebook from the manifests

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
python build_tools.py 2>&1 | tee build.log
cat build.log
```

Expected:

```
manifest files : ['cells_part1.wl', 'cells_part2.wl', 'cells_part3.wl', 'cells_part4.wl']
cells parsed   : 213 {'Title': 4, 'Subtitle': 1, 'Subsubtitle': 1, 'Text': 46, 'Section': 22, 'Input': 139}
run_all.wls    : 139 Input cells
notebook       : 213 cells -> C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77\claude-fable\claude-fable_Einstein-Rosen-2-Planes.nb
```

Then copy it to the deliverable location:

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
cp claude-fable_Einstein-Rosen-2-Planes.nb "C:/Users/nsh/Documents/8-dim/"
ls -la "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb"
```

## 5a. The generator, in full, and every other file under `claude-fable/`

`build_tools.py` is invoked above and on three other pages. It is the only thing that writes the
notebook, so this page carries it complete rather than assuming it.

`<repo>\claude-fable\build_tools.py`, in full:

```python
#!/usr/bin/env python3
"""
build_tools.py -- turn the cell-manifest .wl files into

  (a) a runnable .wls script containing only the Input cells, in order, and
  (b) a Wolfram .nb notebook containing every cell with its style.

The manifest format is one marker line per cell,

      (* ::Title:: *)      (* ::Section:: *)      (* ::Subsection:: *)
      (* ::Text:: *)       (* ::Input:: *)

followed by the cell body until the next marker.  Bodies of Text/Title/Section cells are
literal text; bodies of Input cells are Wolfram Language code.
"""

import re
import sys
import glob
import os

MARKER = re.compile(r'^\(\*\s*::\s*([A-Za-z][A-Za-z0-9-]*)\s*::\s*(.*?)\*\)\s*$')

KNOWN_STYLES = {
    "Title": "Title",
    "Subtitle": "Subtitle",
    "Subsubtitle": "Subsubtitle",
    "Section": "Section",
    "Subsection": "Subsection",
    "Subsubsection": "Subsubsection",
    "Text": "Text",
    "Input": "Input",
    "Item": "Item",
}


def parse_manifest(paths):
    """Return a list of (style, body) pairs, in file order then line order."""
    cells = []
    for path in paths:
        with open(path, "r", encoding="utf-8") as fh:
            lines = fh.read().split("\n")
        style = None
        buf = []
        for line in lines:
            m = MARKER.match(line)
            if m:
                name = m.group(1)
                if style is not None:
                    cells.append((style, "\n".join(buf).strip("\n")))
                buf = []
                style = KNOWN_STYLES.get(name)  # None for unknown markers -> skipped
            else:
                if style is not None:
                    buf.append(line)
        if style is not None:
            cells.append((style, "\n".join(buf).strip("\n")))
    # drop cells whose body is entirely blank
    return [(s, b) for (s, b) in cells if b.strip() != ""]


def wl_string(s):
    """Encode a Python str as a Wolfram Language double-quoted string literal."""
    out = []
    for ch in s:
        if ch == "\\":
            out.append("\\\\")
        elif ch == '"':
            out.append('\\"')
        elif ch == "\n":
            out.append("\\n")
        elif ch == "\r":
            continue
        elif ch == "\t":
            out.append("\\t")
        else:
            out.append(ch)
    return '"' + "".join(out) + '"'


def build_script(cells, out_path, header=""):
    """Write a .wls that evaluates every Input cell in order."""
    with open(out_path, "w", encoding="utf-8") as fh:
        if header:
            fh.write(header.rstrip() + "\n\n")
        n = 0
        for style, body in cells:
            if style != "Input":
                continue
            n += 1
            fh.write("\n(* ---------- Input cell %d ---------- *)\n" % n)
            fh.write("cfRunCell[%d, Hold[\n" % n)
            fh.write(body.rstrip() + "\n")
            fh.write("]];\n")
        fh.write("\ncfRunSummary[];\n")
    return n


def build_notebook(cells, out_path, window_title):
    """Write a .nb file as a plain-text Wolfram expression."""
    parts = []
    for style, body in cells:
        if style == "Input":
            parts.append("Cell[BoxData[%s], \"Input\"]" % wl_string(body))
        else:
            parts.append("Cell[%s, %s]" % (wl_string(body), wl_string(style)))
    with open(out_path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("(* Content-type: application/vnd.wolfram.mathematica *)\n\n")
        fh.write("(*** Wolfram Notebook File ***)\n")
        fh.write("(* http://www.wolfram.com/nb *)\n\n")
        fh.write("(* CreatedBy='claude-fable build_tools.py' *)\n\n")
        fh.write("Notebook[{\n")
        fh.write(",\n".join(parts))
        fh.write("\n},\n")
        fh.write("WindowSize->{1400, 900},\n")
        fh.write("WindowTitle->%s,\n" % wl_string(window_title))
        fh.write("WindowMargins->{{Automatic, 0}, {Automatic, 0}},\n")
        fh.write("FrontEndVersion->\"14.0 for Microsoft Windows (64-bit)\",\n")
        fh.write("StyleDefinitions->\"Default.nb\"\n")
        fh.write("]\n")
    return len(cells)


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    paths = sorted(glob.glob(os.path.join(here, "cells_part*.wl")))
    if not paths:
        print("no cells_part*.wl found in", here)
        return 1
    cells = parse_manifest(paths)
    counts = {}
    for s, _ in cells:
        counts[s] = counts.get(s, 0) + 1
    print("manifest files :", [os.path.basename(p) for p in paths])
    print("cells parsed   :", len(cells), counts)

    runner_header = open(os.path.join(here, "runner_header.wl"), "r", encoding="utf-8").read()
    n_in = build_script(cells, os.path.join(here, "run_all.wls"), runner_header)
    print("run_all.wls    :", n_in, "Input cells")

    nb = os.path.join(here, "claude-fable_Einstein-Rosen-2-Planes.nb")
    n_nb = build_notebook(cells, nb, "claude-fable_Einstein-Rosen-2-Planes")
    print("notebook       :", n_nb, "cells ->", nb)
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

The rest of `claude-fable/` is listed here so that nothing in the directory is unexplained. The
scripts in the first group are the ones the provenance pages run and reproduce; the second group
is development scratch, kept because it is the record of how the work actually went, and named
here so a reader is not left guessing.

| file | what it is | reproduced on |
|---|---|---|
| `build_tools.py` | generates the `.nb` and `run_all.wls` from the four manifests | this page, above |
| `cells_part1.wl` … `cells_part4.wl` | the cell manifests the notebook is generated from | — (they are the source) |
| `runner_header.wl` | the assertion and timing harness | this page |
| `run_from_nb.wls` | evaluates the delivered `.nb` straight out of the file | this page, PROVENANCE-09 |
| `verify_nb.wls` | parses the `.nb` without evaluating it | this page |
| `run_from_clone.wls` | the same run, from a fresh clone | PROVENANCE-08 |
| `prov02_…` … `prov07_physics.wls` | one per chapter of Parts III and IV | PROVENANCE-02 … 07 |
| `prov07_mx_fidelity.wls`, `mx_fidelity2.wls` | compare the equations with the author's own `.mx` | PROVENANCE-07, PROVENANCE-09 |
| `attribute_certs.wls` | attributes each numerical certificate to its call site | PROVENANCE-09 |
| `render-check/*.wls` | front-end parse, cell images, PDF render | PROVENANCE-10 |
| `extract/extract_original.wls` | the non-evaluating extract of the author's notebook | PROVENANCE-00 |
| `run_all.wls` | **generated** by `build_tools.py`; the Input cells as a script | — (generated) |

Development scratch, superseded but kept:

| file | what it was for |
|---|---|
| `run_all_12.wls` | an early partial build, sections 1–12 only; superseded by `run_all.wls` |
| `probe2.wls`, `probe3.wls`, `probe4.wls` | one-off probes run against those partial builds while the manifests were being written |
| `probe_sig.wls`, `probe_sig2.wls` | probes used to work out why `Sign[Exp[a4[…]]]` is undecidable, which is what led to the explicit `cfSignatureAssume` in Section 15 |
| `check_deltas.wls` | an early component-by-component diff of two spin connections, before the master comparison of Section 21 existed |
| `cmp_mx.wls` | the first `.mx` comparison, superseded by `prov07_mx_fidelity.wls` and `mx_fidelity2.wls` |
| `report_results.wls` | prints a headline summary of the metric, `Det[g]` and both Ricci scalars; its output is `report_results.log` |

Each of those runs the same way as the others: `cd "$(git rev-parse --show-toplevel)/claude-fable"`
then `wolframscript -file <name> 2>&1 | tee <name>.log`. They are not needed to reproduce any
result on any provenance page.

## 6. Check that the `.nb` is well formed and every Input cell parses

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
cat > verify_nb.wls <<'WLSEOF'
(* Verify the generated .nb: import it, pull out the Input cells, and evaluate them all in
   order in this kernel.  If the notebook is well formed, this reproduces run_all.wls exactly. *)
(* --- self-locating, so this script works from a clone at any path -------------------------- *)
(* $InputFileName is the path this file was invoked with; ExpandFileName makes it absolute even *)
(* when wolframscript was given a relative path.  cfHere is this script's own directory,        *)
(* i.e. <repo>/claude-fable, and cfRepo is the repository root.                                 *)
cfHere = DirectoryName[ExpandFileName[$InputFileName]];
cfRepo = ParentDirectory[cfHere];
cfNB   = FileNameJoin[{cfHere, "claude-fable_Einstein-Rosen-2-Planes.nb"}];
nbfile = cfNB;
Print["file bytes: ", FileByteCount[nbfile]];
nb = Import[nbfile, "Notebook"];
Print["Head: ", Head[nb]];
cells = Cases[nb, Cell[__], Infinity];
Print["cells: ", Length[cells]];
Print["style tally: ", Tally[Cases[cells, Cell[_, s_String, ___] :> s]]];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
Print["input cells with plain-string BoxData: ", Length[inputs]];
Print["total input characters: ", Total[StringLength /@ inputs]];
(* every Input cell must parse *)
bad = {};
Do[Module[{e = Quiet@Check[ToExpression[inputs[[i]], InputForm, HoldComplete], $Failed]},
    If[e === $Failed || Head[e] =!= HoldComplete, AppendTo[bad, i]]], {i, Length[inputs]}];
Print["input cells that FAIL to parse: ", bad];
(* compare against the manifest-built script *)
Print["first cell: ", InputForm[StringTake[inputs[[1]], UpTo[90]]]];
Print["last cell : ", InputForm[StringTake[inputs[[-1]], UpTo[90]]]];
WLSEOF
timeout 900 wolframscript -file verify_nb.wls 2>&1 | tee verify_nb.log
cat verify_nb.log
```

Expected:

```
file bytes: 144787
Head: Notebook
cells: 213
style tally: {{Title, 4}, {Subtitle, 1}, {Subsubtitle, 1}, {Text, 46}, {Section, 22}, {Input, 139}}
input cells with plain-string BoxData: 139
total input characters: 93970
input cells that FAIL to parse: {}
first cell: InputForm[(* --- provenance banner, as in the original notebook ------------------------------------]
last cell : InputForm[(* --- final tally of every assertion made in this notebook ------------------------------]
```

## 7. Execute the notebook itself, end to end

This is the real test: it imports the delivered `.nb`, takes its Input cells in order, and
evaluates each one in a fresh kernel, exactly as the front end would.

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
cat > runner_header.wl <<'WLSEOF'
(* runner_header.wl -- harness used by run_all.wls to evaluate every notebook Input cell
   in order, in one kernel, reporting timing and every message raised. *)

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
  Scan[Print["  cell ", #["cell"], "  ", ToString[NumberForm[N[#["seconds"]], {8, 3}, ExponentFunction -> (Null &)]], " s"] &, slow];
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
(* --- self-locating, so this script works from a clone at any path -------------------------- *)
(* $InputFileName is the path this file was invoked with; ExpandFileName makes it absolute even *)
(* when wolframscript was given a relative path.  cfHere is this script's own directory,        *)
(* i.e. <repo>/claude-fable, and cfRepo is the repository root.                                 *)
cfHere = DirectoryName[ExpandFileName[$InputFileName]];
cfRepo = ParentDirectory[cfHere];
cfNB   = FileNameJoin[{cfHere, "claude-fable_Einstein-Rosen-2-Planes.nb"}];
Get[FileNameJoin[{cfHere, "runner_header.wl"}]];
nbfile = cfNB;
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
total seconds   : 127.849
cells w/ msgs   : 0
---- slowest cells ----
  cell 80  69.005 s
  cell 88  22.723 s
  cell 86   8.173 s
  ...
==================== ASSERTIONS ====================
assertions run  : 182
passed          : 182
FAILED          : 0
====================================================
```

The three numbers that matter:

- **`cells evaluated : 139`** — every Input cell ran.
- **`cells w/ msgs : 0`** — the notebook raises no errors and no warnings.
- **`assertions run : 182  passed : 182  FAILED : 0`** — every identity the notebook claims was
  checked and holds.

Wall-clock time is roughly 128 s on this machine; it will vary.

The assertion total has grown as the notebook gained checks: it was 175 when the repository was
first pushed, 178 after the review of commit `35ff142`, and 182 after the evaluation of
`2da615d` added four. If a future change adds more, this number moves with it; what must stay
true is that **passed** equals **assertions run** and **FAILED** is zero.

To see the individual assertion verdicts:

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
grep -c 'PASS' run_from_nb.log       # 182
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
stay undetermined everywhere else, and no stated result depends on the particular probes.

Stage 3 is reached with two opposite intentions, and the notebook counts them apart, because one
number lumping them together was misleading and was corrected on 2026-09-14:

- `$cfNumericCertificates` counts the times stage 3 returned **True** — an identity that
  `Simplify` could not close, accepted on numerical evidence alone. It measures how much of the
  notebook is *not* symbolic, and smaller is better. It currently reads **0**.
- `$cfNonVanishingWitnesses` counts the times stage 3 returned **False** inside an assertion of
  the form `! TrueQ[cfZeroArrayQ[...]]`, i.e. a claim that something is *not* identically zero. A
  single sample point where an expression evaluates non-zero is a complete proof of
  non-vanishing, so these are the strongest form such a claim can take. It currently reads **6**.

To see both:

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
grep -E 'identities accepted|non-vanishing witnesses' run_from_nb.log
```

which prints

```
identities accepted on numerical evidence alone : 0   (stage 3 returned True)
non-vanishing witnesses                         : 6   (stage 3 returned False inside a ! TrueQ[...] assertion;
```

which prints `numerical certificates used: 6`. That counter records `cfZeroQ`/`cfZeroArrayQ`
calls that fall through to stage 3, not assertions, and the six break down as one plus five:

- **one** comes from the worked example at the end of the cell that defines the test,
  `cfZeroQ[x0 - x4]`. That is a demonstration of the three stages, not an assertion.
- **five** come from assertions, and every one of them is a NEGATIVE test, written
  `! TrueQ[cfZeroQ[...]]` or `! TrueQ[cfZeroArrayQ[...]]`: that the metric is non-degenerate,
  that `Lambda` is a genuine boost and not a rotation, that Bridge 3's torsion is non-zero for
  non-zero lambda, that the triality Dirac matrices really differ from the vector-frame ones,
  and that the extra spinor coupling is non-zero for non-zero lambda.

So **no positive identity in this notebook rests on the numerical probe.** In all five cases the
probe is used to REFUTE an identity by exhibiting a non-zero value at rational sample points,
which is a sound refutation rather than a numerical stand-in for a proof. To confirm the five:

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
grep -n '! TrueQ\[cfZero' cells_part*.wl
```

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
| the whole title block as one `Title` cell | split into `Title`, `Subtitle`, `Subsubtitle` | all three lines rendered at full Title size in red; the split gives the intended hierarchy |

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
# the notebook DumpSaves these beside itself, i.e. in <repo>/claude-fable, because a
# headless kernel has no NotebookFileName[] and cfDir falls back to the working directory
ls -la claude-fable_Einstein-Rosen-2-Planes-eLa.mx \
       claude-fable_Einstein-Rosen-2-Planes-eLazt.mx
```

Expected sizes 2,696 and 3,144 bytes. To turn the writing off, set `$cfWriteMX = False` in the
cell that defines it.
