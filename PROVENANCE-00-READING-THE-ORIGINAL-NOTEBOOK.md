# Provenance 00 — Reading the original 24 MB notebook in its entirety

**Effort.** Read, understand and record every authored cell of
`Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb` (24,112,944 bytes,
432,525 lines, 1943 cells) without evaluating any of it and without losing any character.

Everything needed to repeat this work is on this page. No other file needs to be consulted.

---

## 1. Environment actually used

| item | value |
|---|---|
| OS | Windows 11 Pro for Workstations 10.0.26200 |
| shell | Git Bash (the `bash` that ships with Git for Windows) |
| WolframScript | 1.14.0 for Microsoft Windows (64-bit) |
| Wolfram kernel | 15.0.1 for Microsoft Windows (64-bit), 2 July 2026 |
| Python | 3.14 (used only for text post-processing) |

Confirm the toolchain:

```bash
which wolframscript
wolframscript -version
wolframscript -code '$Version'
```

Expected:

```
/c/Program Files/Wolfram Research/WolframScript/wolframscript
WolframScript 1.14.0 for Microsoft Windows (64-bit)
15.0.1 for Microsoft Windows (64-bit) (July 2, 2026)
```

## 2. Back up the source before touching anything

```bash
cd "$(git rev-parse --show-toplevel)"
mkdir -p backups
cp -p "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb" \
      "backups/Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb.bak-$(date +%Y%m%d-%H%M%S)"
ls -la backups/
```

## 3. Two traps, and how they were handled

**Trap 1 — do not evaluate the notebook while reading it.**
The obvious approach, `ToExpression[boxes, StandardForm, HoldComplete]` followed by stripping the
hold, silently *evaluates* the author's code. On the first attempt it produced a 71 MB dump in
under a minute and had to be killed:

```bash
taskkill //F //IM WolframKernel.exe
taskkill //F //IM wolfram.exe
```

The fix is a hand-written box walker that never calls `ToExpression` at all.

**Trap 2 — Wolfram stores many operators as Unicode private-use characters.**
They are invisible in a terminal, so a naive dump silently loses `->`, `==`, `E`, `I` and several
algebra symbols. For example `simp={Zero4,ID4,mid-1}` is really `simp={Zero4 -> 0, ID4 -> 1, mid -> -1}`.
Every such character must be transliterated. The ones that actually occur in this notebook:

| codepoint | Wolfram name | ASCII used |
|---|---|---|
| U+F522 | `\[Rule]` | `->` |
| U+F51F | `\[RuleDelayed]` | `:>` |
| U+F431 | `\[Equal]` | `==` |
| U+F74D | `\[ExponentialE]` | `E` |
| U+F74E | `\[ImaginaryI]` | `I` |
| U+F6FA | `\[DoubleStruckU]` | `uDS` |
| U+F7B2 | `\[DoubleStruckCapitalO]` | `OctSplit` |
| U+F7B5 | `\[DoubleStruckCapitalR]` | `Reals` |
| U+F78F | `\[GothicCapitalF]` | `FGoth` |
| U+F772 | `\[ScriptCapitalC]` | `CliffC` |
| U+F4A0 | `\[Cross]` | `x` |
| U+F527 | `\[SelectionPlaceholder]` | `[*]` |

To identify an unknown private-use character:

```bash
wolframscript -code 'ExportString[FromCharacterCode[16^^F7B2], "Text", CharacterEncoding -> "ASCII"]'
```

**Trap 3 — Windows paths.** In Git Bash a quoted heredoc still mangles `\\` inside the `.wls` it
writes, which produces `Syntax::stresc: Unknown string escape \U`. Always write Windows paths with
forward slashes in Wolfram code. Every command below does.

## 4. The complete extraction script

```bash
mkdir -p "$(git rev-parse --show-toplevel)/claude-fable/extract"
cd "$(git rev-parse --show-toplevel)/claude-fable/extract"
cat > extract_original.wls <<'WLSEOF'
(* Safe, NON-EVALUATING extraction of every authored cell of the original notebook.
   Box structures are rendered to plain text purely by string surgery.  Nothing is evaluated. *)
(* --- self-locating, so this works from a clone at any path --------------------------------- *)
(* Run in place, from <repo>/claude-fable/extract.  cfRepo is then the repository root.          *)
cfHere = DirectoryName[ExpandFileName[$InputFileName]];
cfRepo = ParentDirectory[ParentDirectory[cfHere]];

src = FileNameJoin[{cfRepo, "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb"}];
dir = cfHere <> "/";

Print["Reading notebook..."];
nb = Import[src, "Notebook"];
Print["Head: ", Head[nb]];
allCells = Cases[nb, Cell[__], Infinity];
Print["Total cells: ", Length[allCells]];
Print["Style tally: ", Tally[Cases[allCells, Cell[_, s_String, ___] :> s]]];

keep = {"Input", "Code", "Text", "Title", "Subtitle", "Chapter", "Section", "Subsection",
        "Subsubsection", "Item", "ItemNumbered", "Program", "ExternalLanguage",
        "InlineFormula", "DisplayFormula"};
sel = Cases[nb, c : Cell[_, s_String, ___] /; MemberQ[keep, s] :> {s, First[c]}, Infinity];
Print["Selected cells: ", Length[sel]];

(* ---- transliterate Wolfram's private-use operator characters to ASCII ------------------- *)
opFix = {
  "\[Rule]" -> " -> ", "\[RuleDelayed]" -> " :> ",
  "\[Equal]" -> " == ", "\[NotEqual]" -> " != ",
  "\[LessEqual]" -> " <= ", "\[GreaterEqual]" -> " >= ",
  "\[And]" -> " && ", "\[Or]" -> " || ", "\[Not]" -> "!",
  "\[Function]" -> " |-> ",
  "\[LeftAssociation]" -> "<|", "\[RightAssociation]" -> "|>",
  "\[Element]" -> " \\[Element] ",
  "\[Sum]" -> "SUM", "\[Product]" -> "PROD", "\[Integral]" -> "INTEGRAL",
  "\[PartialD]" -> "PARTIALD", "\[DifferentialD]" -> "DD",
  "\[CenterDot]" -> " . ", "\[Divide]" -> "/",
  "\[Times]" -> "*", "\[InvisibleTimes]" -> " ", "\[InvisibleSpace]" -> " ",
  "\[InvisibleComma]" -> ",", "\[InvisibleApplication]" -> "@",
  "\[IndentingNewLine]" -> "\n", "\[LineSeparator]" -> "\n",
  "\[NoBreak]" -> "", "\[NonBreakingSpace]" -> " ",
  "\[LongEqual]" -> " == ",
  "\[DoubleStruckU]" -> "uDS", "\[ExponentialE]" -> "E", "\[ImaginaryI]" -> "I",
  "\[DoubleStruckCapitalO]" -> "OctSplit", "\[DoubleStruckCapitalR]" -> "Reals",
  "\[GothicCapitalF]" -> "FGoth", "\[ScriptCapitalC]" -> "CliffC",
  "\[Intersection]" -> " INTERSECT ", "\[Union]" -> " UNION ",
  "\[Cross]" -> "x", "\[SelectionPlaceholder]" -> "[*]"};

(* ---- the non-evaluating box walker ------------------------------------------------------ *)
(* Every box head must accept trailing OPTIONS.  Omitting the ___ on SuperscriptBox is the    *)
(* single most damaging mistake here: it silently drops every                                 *)
(* SuperscriptBox[f, TagBox[(1,0), Derivative], MultilineFunction -> None], i.e. every        *)
(* partial derivative in the notebook.                                                        *)
ClearAll[bx];
bx[s_String] := s;
bx[RowBox[l_List, ___]] := StringJoin[bx /@ l];
bx[BoxData[b_]] := bx[b];
bx[BoxData[l_List]] := StringRiffle[bx /@ l, "\n"];
bx[TextData[b_]] := bx[b];
bx[TextData[l_List]] := StringJoin[bx /@ l];
bx[l_List] := StringJoin[bx /@ l];
bx[SuperscriptBox[a_, TagBox[b_, Derivative, ___], ___]] :=
   "Derivative" <> StringReplace[bx[b], {"(" -> "[", ")" -> "]"}] <> "[" <> bx[a] <> "]";
bx[SuperscriptBox[a_, b_, ___]] := bx[a] <> "^(" <> bx[b] <> ")";
bx[SubscriptBox[a_, b_, ___]] := "Subscript[" <> bx[a] <> ", " <> bx[b] <> "]";
bx[SubsuperscriptBox[a_, b_, c_, ___]] := "Subsuperscript[" <> bx[a] <> ", " <> bx[b] <> ", " <> bx[c] <> "]";
bx[FractionBox[a_, b_, ___]] := "((" <> bx[a] <> ")/(" <> bx[b] <> "))";
bx[SqrtBox[a_, ___]] := "Sqrt[" <> bx[a] <> "]";
bx[RadicalBox[a_, b_, ___]] := "Surd[" <> bx[a] <> ", " <> bx[b] <> "]";
bx[OverscriptBox[a_, b_, ___]] := "Overscript[" <> bx[a] <> ", " <> bx[b] <> "]";
bx[UnderscriptBox[a_, b_, ___]] := "Underscript[" <> bx[a] <> ", " <> bx[b] <> "]";
bx[UnderoverscriptBox[a_, b_, c_, ___]] := "Underoverscript[" <> bx[a] <> ", " <> bx[b] <> ", " <> bx[c] <> "]";
bx[StyleBox[a_, ___]] := bx[a];
bx[FormBox[a_, ___]] := bx[a];
bx[TagBox[a_, ___]] := bx[a];
bx[InterpretationBox[a_, ___]] := bx[a];
bx[TemplateBox[a_List, ___]] := StringJoin[bx /@ a];
bx[ButtonBox[a_, ___]] := bx[a];
bx[PaneBox[a_, ___]] := bx[a];
bx[AdjustmentBox[a_, ___]] := bx[a];
bx[ErrorBox[a_, ___]] := bx[a];
bx[GridBox[rows_List, ___]] := StringRiffle[StringRiffle[bx /@ #, ", "] & /@ rows, "\n"];
bx[Cell[a_, ___]] := bx[a];
bx[BoxData[]] := "";
bx[other_] := "<<UNRENDERED:" <> ToString[Head[other]] <> ">>";

strm = OpenWrite[dir <> "cells_dump.txt", CharacterEncoding -> "UTF8"];
idx  = OpenWrite[dir <> "cells_index.txt", CharacterEncoding -> "UTF8"];
Do[
 Module[{sty = sel[[i, 1]], body = sel[[i, 2]], txt},
  txt = Quiet@Check[StringReplace[bx[body], opFix], "<<RENDER-ERROR>>"];
  If[! StringQ[txt], txt = "<<NONSTRING>>"];
  WriteString[idx, ToString[i] <> "\t" <> sty <> "\t" <> ToString[StringLength[txt]] <> "\t" <>
     StringReplace[StringTake[txt, UpTo[110]], {"\n" -> " \\n "}] <> "\n"];
  WriteString[strm, "\n(* ===== CELL " <> ToString[i] <> " style=" <> sty <> " len=" <>
     ToString[StringLength[txt]] <> " ===== *)\n"];
  WriteString[strm, txt, "\n"];
 ], {i, Length[sel]}];
Close[strm]; Close[idx];
Print["dump bytes  = ", FileByteCount[dir <> "cells_dump.txt"]];
Print["index bytes = ", FileByteCount[dir <> "cells_index.txt"]];
WLSEOF
timeout 1200 wolframscript -file extract_original.wls 2>&1 | tee extract_original.log
cat extract_original.log
```

Expected output:

```
Reading notebook...
Head: Notebook
Total cells: 1943
Style tally: {{Title, 6}, {Text, 156}, {Section, 32}, {Input, 650}, {Print, 14}, {Output, 546}, {Subsubsection, 2}, {Message, 9}, {InlineFormula, 1}}
Selected cells: 847
dump bytes  = 131678
index bytes = 66042
```

So: **1943 cells in total, of which 847 are authored** (650 Input, 156 Text, 32 Section, 6 Title,
2 Subsubsection, 1 InlineFormula). The remaining 1096 are stored Output, Print and Message cells.
The authored content compresses to 131,660 bytes of readable text — 0.55 % of the 24 MB file.

## 3a. Confirm nothing was silently dropped

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable/extract"
grep -o '<<UNRENDERED:[A-Za-z]*>>' cells_dump.txt | sort | uniq -c
```

Expected:

```
    120 <<UNRENDERED:GraphicsBox>>
     13 <<UNRENDERED:GraphicsData>>
```

Those 133 hits are the author's pasted screenshots. They carry no executable content.
**Nothing else is unrendered**, which is the proof that the walker covered every box head that
actually occurs in this notebook.

Tally the remaining non-ASCII characters to confirm every operator was transliterated:

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable/extract"
PYTHONIOENCODING=utf-8 python -c "
import collections, unicodedata
s=open('cells_dump.txt',encoding='utf-8').read()
c=collections.Counter(ch for ch in s if ord(ch)>127)
for ch,n in c.most_common():
    try: nm=unicodedata.name(ch)
    except ValueError: nm='<PRIVATE-USE - STILL UNTRANSLITERATED>'
    print(f'U+{ord(ch):04X}  n={n:6d}  {nm}')
"
```

Everything that remains must be a named Greek letter or ordinary punctuation. Any line reading
`<PRIVATE-USE - STILL UNTRANSLITERATED>` means an operator is still being lost and `opFix` needs
another entry. With the `opFix` given above there are none left; the check that says so is

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable/extract"
PYTHONIOENCODING=utf-8 python -c "
import collections
s=open('cells_dump.txt',encoding='utf-8').read()
bad=[(hex(ord(ch)),n) for ch,n in collections.Counter(s).items() if 0xE000<=ord(ch)<=0xF8FF]
print('private-use characters left:', bad)"
```

which prints

```
private-use characters left: []
```

## 4a. Read the extraction

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable/extract"
grep -n 'style=Section\|style=Title\|style=Subsubsection' cells_dump.txt   # the outline
awk -F'\t' '{s[$2]+=$3; n[$2]++} END {for (k in s) print k, n[k], s[k]}' cells_index.txt
sed -n '1,700p'    cells_dump.txt
sed -n '700,1400p' cells_dump.txt
sed -n '1400,2100p' cells_dump.txt
sed -n '2100,2800p' cells_dump.txt
sed -n '2800,3500p' cells_dump.txt
sed -n '3500,3740p' cells_dump.txt
```

To see the raw, untransliterated boxes of any particular cell — the way to settle an ambiguity:

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable/extract"
cat > rawcell.wls <<'WLSEOF'
cfRepo = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
src = FileNameJoin[{cfRepo, "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb"}];
nb = Import[src, "Notebook"];
keep = {"Input","Code","Text","Title","Subtitle","Chapter","Section","Subsection",
        "Subsubsection","Item","ItemNumbered","Program","ExternalLanguage",
        "InlineFormula","DisplayFormula"};
sel = Cases[nb, c : Cell[_, s_String, ___] /; MemberQ[keep, s] :> {s, First[c]}, Infinity];
want = {55, 57, 656};       (* <-- put the cell numbers you want here *)
Do[Print["######## RAW CELL ", i, "  style=", sel[[i,1]]];
   Print[ExportString[ToString[sel[[i,2]], InputForm], "Text", CharacterEncoding -> "ASCII"]];
   Print[], {i, want}];
WLSEOF
timeout 900 wolframscript -file rawcell.wls 2>&1 | tee rawcell.log
```

## 5. What the original notebook contains

| cells | content |
|---|---|
| 1–46 | banner, helper-package loading, coordinates `{x0..x7}`, `η4488 = diag(1,1,1,1,-1,-1,-1,-1)`, spinor metric `σ` |
| 47–145 | `Ψ16`, the `Symbolize` declarations for the author's 2-D notation, and small utility functions |
| 146–181 | eigensystem of `σ`; SO(4) self-dual `s4by4[h]` and anti-self-dual `t4by4[h]` |
| 182–206 | the real 8×8 Clifford generators `τ[0..7]` and `τ̄`, and their identities |
| 207–298 | the 16×16 Dirac matrices `T16`, `σ16`, chirality, and the `so(4,4)` generators `SAB` |
| 299–380 | the 256-element basis of the 16×16 algebra and the 64-element basis of the 8×8 algebra |
| 381–478 | the 4×4 Dirac matrices `γ`, `S44αβ`, and the 16-element 4×4 basis |
| 479–560 | triality: the constant bridge `F` built from the distinguished unit spinor; the diagonal frame field |
| 561–642 | the split-octonion structure constants `mabc` and `mABC`, and the multiplication table |
| 643–700 | the Lagrangian `La`, the Euler–Lagrange operator `eL`, `eLa`, `eLazt`, and the four coupled blocks |
| 701–790 | the Maple closed-form solutions, pasted back and checked |
| 791–830 | the `Z → yZ` orthogonal transformation `almightyS` |
| 831–847 | notes, the Einstein–Rosen citation, and the split-octonion notation summary |

Two facts recorded here because they are load-bearing downstream:

- The frame field the author records (cells 546 and 555) is the diagonal matrix
  `diag(Tan[6 H x0], q, q, q, 1, p, p, p)` with `q = E^(-a4[H x4])/Sin[6 H x0]^(1/6)` and
  `p = E^(+a4[H x4])/Sin[6 H x0]^(1/6)`.
- **`a4` is never defined anywhere in the notebook.** It is a free scalar function of `H x4`.
  The same is true of `la`, which occurs only inside the assumption `ssX`. Neither was invented
  a value; both are carried symbolically.

## 6. Two defects in the original that this reading uncovered

1. **`sixAntiSymmetric8by8` is a misnomer.** Only its first three entries are antisymmetric; the
   last three are symmetric, because transposing `ArrayFlatten[{{0,t},{-t,0}}]` with `t`
   antisymmetric returns the matrix unchanged. The correct statement, which the original also
   records and which holds, is `Transpose[τ[A]] == -η4488[[A+1,A+1]] τ[A]` for `A = 1..7`.
   Check it:

   ```bash
   cd "$(git rev-parse --show-toplevel)/claude-fable/extract"
   grep -n 'sixAntiSymmetric8by8' cells_dump.txt
   ```

2. **`σ16 . SAB` is antisymmetric, not symmetric.** The original contains both claims, in
   cell 255 (correct) and cells 279–280 (incorrect). Proof: `σ16` is symmetric and squares to
   `ID16`, and `σ16 . T16[A]` is antisymmetric, so `Transpose[T16[A]] == -σ16.T16[A].σ16`;
   substituting that twice into `Transpose[σ16.T16[A].T16[B]]` gives `σ16.T16[B].T16[A]`, which
   flips the sign of the commutator.

Both are carried forward with the correct statement and an explanatory comment.

## 7. What this effort produced

| file | bytes | content |
|---|---|---|
| `claude-fable/extract/cells_dump.txt` | 131,678 | every authored cell, in order, as plain text |
| `claude-fable/extract/cells_index.txt` | 66,042 | one line per cell: number, style, length, first 110 characters |
| `backups/…nb.bak-YYYYmmdd-HHMMSS` | 24,112,944 | untouched copy of the source notebook |
