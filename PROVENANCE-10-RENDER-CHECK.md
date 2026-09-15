# Provenance 10 — Opening the notebook in Mathematica and checking that it renders

**Effort.** Open `claude-fable_Einstein-Rosen-2-Planes.nb` in the Mathematica front end and
establish that it *renders*: that the front end can parse every cell, that no cell comes back as
an error box, that every block changed in the preceding effort appears correctly on screen and
on the printed page, and that opening it changes nothing on disk.

Everything needed to repeat this work is on this page. No other file needs to be consulted.

---

## 0. Where things are

| what | path |
|---|---|
| repository | `C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77` |
| the notebook that was opened | `C:\Users\nsh\Documents\8-dim\claude-fable_Einstein-Rosen-2-Planes.nb` |
| its in-repo twin, byte-identical | `<repo>\claude-fable\claude-fable_Einstein-Rosen-2-Planes.nb` |
| scripts, logs and images from this effort | `<repo>\claude-fable\render-check\` |
| scratch the scripts write to | `C:\Users\nsh\Documents\8-dim\render3\` |

The three `.wls` files are committed exactly as they were run, so they still name the scratch
directory `render3` as their output. Re-running them writes there, not into the repository.

## 1. The state going in

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77"
tasklist | grep -i wolfram
sha256sum claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb ../claude-fable_Einstein-Rosen-2-Planes.nb
stat -c '%s bytes  mtime %y' claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb
git status --porcelain=v1 -- claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb
```

Both copies hashed `e1f2e0848c83bdb82d671369f0b2d06ab1853e98af20d4568d936ec5b7b7ebd2`,
144 787 bytes, and `git status` printed nothing, i.e. the file on disk was identical to `HEAD`.

## 2. What the open window actually holds

A window title is the cheapest reliable evidence: the Wolfram front end appends `*` to the title
of a notebook with unsaved changes. Enumerating the visible windows, rather than assuming, also
catches the case where an earlier headless front end is still alive and holding a stale copy.

```powershell
Add-Type @"
using System;using System.Text;using System.Runtime.InteropServices;
public class W3{
 [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc cb, IntPtr l);
 [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
 [DllImport("user32.dll")] public static extern int GetWindowTextLength(IntPtr h);
 [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
 [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint p);
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
 public struct RECT{public int L,T,R,B;}
 public delegate bool EnumWindowsProc(IntPtr h, IntPtr l);
}
"@
$rows=@()
$cb=[W3+EnumWindowsProc]{ param($h,$l)
  if([W3]::IsWindowVisible($h)){
    $len=[W3]::GetWindowTextLength($h)
    if($len -gt 0){ $sb=New-Object Text.StringBuilder ($len+1); [void][W3]::GetWindowText($h,$sb,$sb.Capacity)
      $p=0; [void][W3]::GetWindowThreadProcessId($h,[ref]$p)
      $proc=(Get-Process -Id $p -ErrorAction SilentlyContinue).ProcessName
      if($proc -like "Wolfram*"){
        $r=New-Object W3+RECT; [void][W3]::GetWindowRect($h,[ref]$r)
        $script:rows += [pscustomobject]@{PID=$p;Title=$sb.ToString();Size="$($r.R-$r.L)x$($r.B-$r.T)";Unsaved=($sb.ToString() -match '\*')} } } }
  return $true }
[void][W3]::EnumWindows($cb,[IntPtr]::Zero)
$rows | Format-List
```

```
PID     : 9688
Title   : claude-fable_Einstein-Rosen-2-Planes - Wolfram
Unsaved : False
```

If the notebook is not open, launch it. The front end is **not** under a `Mathematica`
directory on this machine:

```bash
find "/c/Program Files/Wolfram Research" -maxdepth 3 -iname "WolframNB.exe"
#   /c/Program Files/Wolfram Research/Wolfram/14.3/WolframNB.exe
#   /c/Program Files/Wolfram Research/Wolfram/15.0/WolframNB.exe
#   /c/Program Files/Wolfram Research/Wolfram/15.0.1/WolframNB.exe

FE="/c/Program Files/Wolfram Research/Wolfram/15.0.1/WolframNB.exe"
NB="C:\Users\nsh\Documents\8-dim\claude-fable_Einstein-Rosen-2-Planes.nb"
("$FE" "$NB" >/dev/null 2>&1 &)
```

## 3. The render check proper — what the front end makes of the file

This is the test that matters. The notebook is generated, and every `Input` cell is written to
the file as `Cell[BoxData["<code string>"], "Input"]` — a bare **string**. The front end has to
parse that string into boxes when it opens the file. A cell it cannot parse either becomes an
`ErrorBox` or stays a string. Counting both is a direct measurement of "does it render".

`<repo>\claude-fable\render-check\probe.wls`, in full:

```wolfram
(* Open the delivered notebook in a front end and inspect what the front end actually made of
   it.  Read-only: opened Visible->False and closed without saving. *)
src = "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb";
Print["file      : ", FileByteCount[src], " bytes  sha256 ",
      IntegerString[Hash[ReadByteArray[src], "SHA256"], 16]];
UsingFrontEnd[
  nb  = NotebookOpen[src, Visible -> False];
  got = NotebookGet[nb];
  NotebookClose[nb]];

cells = Cases[got, Cell[_, s_String, ___] :> s, Infinity];
Print["cells     : ", Length[cells]];
Print["by style  : ", SortBy[Tally[cells], -Last[#] &]];
Print["ErrorBox  : ", Length[Cases[got, ErrorBox[___], Infinity]]];

(* An Input cell is stored in the file as Cell[BoxData["<code string>"], "Input"].  The front
   end must PARSE that string into boxes.  Any cell still holding a bare string after the
   front end has opened it is one the front end could not parse. *)
raw = Cases[got, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
Print["Input cells left as an unparsed string : ", Length[raw]];
If[raw =!= {}, Scan[Print["   UNPARSED: ", StringTake[#, Min[120, StringLength[#]]]] &, raw]];

(* Any box head the front end does not know would show up as a symbol with no rendering rule. *)
heads = DeleteDuplicates[Cases[got, h_Symbol[___] /; StringMatchQ[SymbolName[h], "*Box"] :> SymbolName[h], Infinity]];
Print["box heads : ", Sort[heads]];
Print["private-use chars remaining: ",
  Length[Select[Union[Flatten[Characters /@ Cases[got, _String, Infinity]]],
    57344 <= First[ToCharacterCode[#]] <= 63743 &]]];
Print["source unchanged: ", IntegerString[Hash[ReadByteArray[src], "SHA256"], 16]];
```

```bash
cd "C:/Users/nsh/Documents/8-dim/render3"
wolframscript -file probe.wls 2>&1 | tee probe.log
```

```
file      : 144787 bytes  sha256 e1f2e0848c83bdb82d671369f0b2d06ab1853e98af20d4568d936ec5b7b7ebd2
cells     : 213
by style  : {{Input, 139}, {Text, 46}, {Section, 22}, {Title, 4}, {Subsubtitle, 1}, {Subtitle, 1}}
ErrorBox  : 0
Input cells left as an unparsed string : 0
box heads : {RowBox}
private-use chars remaining: 0
source unchanged: e1f2e0848c83bdb82d671369f0b2d06ab1853e98af20d4568d936ec5b7b7ebd2
```

Every one of the 139 `Input` cells parsed, nothing became an error box, and the hash is the same
before and after, so opening the notebook wrote nothing.

The private-use count is checked because the author's original notebook stores several operators
as private-use characters (U+E000–U+F8FF), which are invisible in most editors. Zero of them
survive into the refactored notebook.

## 4. Rasterizing the cells that changed

`<repo>\claude-fable\render-check\shots.wls`, in full:

```wolfram
(* Rasterize the individual cells this session changed, to confirm each renders.
   Read-only: the notebook is opened Visible->False and closed without saving.

   The cell selector matters.  Cases[got, c_Cell, Infinity] also matches the enclosing
   Cell[CellGroupData[{...}, Open]], so First[] would return a whole group rather than the cell
   asked for, and two needles inside one group would silently produce the same picture twice.
   Cell[_, _String, ___] matches LEAF cells only, because a group has no String style in slot 2. *)
src = "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb";
out = "C:/Users/nsh/Documents/8-dim/render3/";

(* The yZ-split assertions and the sigma16 assertions are both in the five-bilinears Input cell,
   so they are ONE picture, not two. *)
targets = {
  {"A-section14-text",  "A word first on WHICH split"},
  {"B-bilinear-cell",   "the yZ split at 8 is NOT"},
  {"C-bridge3-comment", "Count the gammas"},
  {"D-counter-defs",    "counts the times stage 3 returned TRUE"},
  {"E-cfZeroQ",         "Count the two outcomes apart"},
  {"F-final-summary",   "identities accepted on numerical evidence alone"}};

UsingFrontEnd[
  nb = NotebookOpen[src, Visible -> False];
  got = NotebookGet[nb];
  NotebookClose[nb];
  cells = Cases[got, c : Cell[_, _String, ___] :> c, Infinity];
  txt[e_] := StringJoin[Cases[e, _String, Infinity]];
  Do[Module[{name = t[[1]], needle = t[[2]], hits, img},
     hits = Select[cells, StringContainsQ[txt[#], needle] &];
     Which[
       hits === {},        Print["  NOT FOUND: ", needle],
       Length[hits] > 1,   Print["  AMBIGUOUS (", Length[hits], " cells): ", needle],
       True,               img = Rasterize[Notebook[{First[hits]}, StyleDefinitions -> "Default.nb"],
                                           ImageResolution -> 108];
                           Export[out <> name <> ".png", img];
                           Print["  ", name, "  -> ", ImageDimensions[img]]]],
    {t, targets}]];
```

```bash
cd "C:/Users/nsh/Documents/8-dim/render3"
wolframscript -file shots.wls 2>&1 | tee shots.log
sha256sum *.png
```

```
  A-section14-text  -> {663, 1766}
  B-bilinear-cell  -> {667, 2478}
  C-bridge3-comment  -> {667, 1707}
  D-counter-defs  -> {666, 2717}
  E-cfZeroQ  -> {669, 1650}
  F-final-summary  -> {646, 423}
```

Six images, six distinct hashes.

`RegisterFormat::interr: ... ImageMetadataTools could not be installed` appears in the log. It is
a Wolfram-internal complaint about writing PNG metadata; the images are produced with correct
dimensions and correct content, and it has no effect on the check.

The lines in the rasterized `Text` cells wrap twice, because `Rasterize` of a one-cell notebook
picks a ~660-pixel width while the source text is hard-wrapped at about 100 characters. That is
an artifact of the raster width, not of the notebook — section 6 below shows the same text laid
out correctly in the real window.

## 5. Two corrections made while producing these images

Both are recorded because each produced an artifact that looked like a result.

**The selector matched cell groups.** The first version of `shots.wls` used
`Cases[got, c_Cell :> c, Infinity]`, which also matches `Cell[CellGroupData[{...}, Open]]`, so
`First[hits]` returned an enclosing group. Every target reported `3 cell(s) matched`, and two
targets produced **byte-identical** images. Fixed by matching `Cell[_, _String, ___]`, which
selects leaf cells only.

**One of those duplicates was real.** After the fix, `B` and `C` still rasterized to the same
picture. That turned out to be correct, not a second bug: both new assertion blocks live in the
*same* `Input` cell. Checked directly against the manifest rather than assumed:

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"
awk '/^\(\* ::Input:: \*\)/{n++} \
     /the yZ split at 8 is NOT/{print "  yZ assertions      -> Input cell #"n} \
     /sigma16 alone is SYMMETRIC/{print "  sigma16 assertions -> Input cell #"n}' cells_part3.wl
#   yZ assertions      -> Input cell #28
#   sigma16 assertions -> Input cell #28
```

So the target list was reduced to one image for that cell rather than shipping the same picture
under two names.

## 6. The live window, and a DPI mistake worth recording

`PrintWindow` asks a window to draw itself into a bitmap. It does **not** raise or focus the
window, which matters here: an earlier attempt in this project used `SetForegroundWindow`, and
raising the front end captured keystrokes the author was typing into another application.

The first capture came out looking enormously magnified with the right-hand side cut off. That
was not the notebook. This display is **3840 × 2400 at 250 % Windows scaling**, and the window
had been sized with `MoveWindow(..., 1500, 920, ...)` — which takes **physical** pixels, so the
window was only 600 logical pixels wide.

The mistake was invisible at first because a DPI-*unaware* process is lied to by Windows:

```powershell
# WITHOUT SetProcessDPIAware: reports the virtualized values
#   LOGPIXELSX = 96  => scale 1x ;  screen 1536 x 960
# WITH it: the truth
Add-Type @"
using System;using System.Runtime.InteropServices;
public class D2{
 [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
 [DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr h);
 [DllImport("user32.dll")] public static extern int ReleaseDC(IntPtr h, IntPtr dc);
 [DllImport("gdi32.dll")]  public static extern int GetDeviceCaps(IntPtr dc, int i);
 [DllImport("user32.dll")] public static extern int GetSystemMetrics(int i);
}
"@
[void][D2]::SetProcessDPIAware()
$dc=[D2]::GetDC([IntPtr]::Zero)
$lx=[D2]::GetDeviceCaps($dc,88)
[void][D2]::ReleaseDC([IntPtr]::Zero,$dc)
"LOGPIXELSX = $lx  => Windows scale $([math]::Round($lx/96*100))%"
"virtual screen = $([D2]::GetSystemMetrics(0)) x $([D2]::GetSystemMetrics(1)) physical pixels"
```

```
LOGPIXELSX = 240  => Windows scale 250%
virtual screen = 3840 x 2400 physical pixels
```

Sizing the window to 3400 × 2100 physical — about 1360 × 840 logical, close to the notebook's own
`WindowSize -> {1400, 900}` — and capturing again gives a correct picture: Title in red, Subtitle
and Subsubtitle below it, `Text` cells in the body font, and the magnification indicator in the
bottom-right reading **100 %**. The notebook sets no `Magnification` of its own
(`grep -c Magnification` on the file returns `0`), and the front-end preferences set none for
notebooks either — the entries in `AppData\Roaming\Wolfram\FrontEnd\init.m` are for palettes and
the sidebar.

Both captures are kept:

| file | what it shows |
|---|---|
| `live-window-1-too-narrow-dpi-mistake.png` | the window at 1500 physical px = 600 logical px — the mistake |
| `live-window-2-correct.png` | the window at 3400 × 2100 physical = 1360 × 840 logical, 100 % |

## 7. The whole document, printed

`<repo>\claude-fable\render-check\pdf.wls`, in full:

```wolfram
src = "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb";
pdf = "C:/Users/nsh/Documents/8-dim/render3/rendered.pdf";
UsingFrontEnd[
  nb = NotebookOpen[src, Visible -> False];
  Export[pdf, nb];
  NotebookClose[nb]];
n = Import[pdf, "PageCount"];
Print["pdf : ", FileByteCount[pdf], " bytes   pages: ", n];
(* locate the blocks changed this session *)
needles = {"A word first on WHICH split", "the yZ split at 8 is NOT",
           "sigma16 alone is SYMMETRIC", "Count the gammas",
           "counts the times stage 3 returned TRUE",
           "identities accepted on numerical evidence alone"};
Do[Module[{hits = {}},
   Do[Module[{t = Quiet@Check[Import[pdf, {"Plaintext", k}], ""]},
      If[StringQ[t] && StringContainsQ[t, needle], AppendTo[hits, k]]], {k, n}];
   Print["  ", If[hits === {}, "NOT FOUND", "pages " <> ToString[hits]], "  <- ", needle]],
  {needle, needles}];
Print["source unchanged: ", IntegerString[Hash[ReadByteArray[src], "SHA256"], 16]];
```

```bash
cd "C:/Users/nsh/Documents/8-dim/render3"
wolframscript -file pdf.wls 2>&1 | tee pdf.log
```

```
pdf : 254808 bytes   pages: 66
  pages {30}  <- A word first on WHICH split
  pages {31}  <- the yZ split at 8 is NOT
  pages {32}  <- sigma16 alone is SYMMETRIC
  pages {64}  <- Count the gammas
  pages {40}  <- counts the times stage 3 returned TRUE
  pages {66}  <- identities accepted on numerical evidence alone
source unchanged: e1f2e0848c83bdb82d671369f0b2d06ab1853e98af20d4568d936ec5b7b7ebd2
```

66 pages, against 65 before the corrections of the preceding effort; the added prose is one page.
Every changed block was found and inspected.

Note the import form. `Import[pdf, {"Plaintext", All}]` is **not** supported and returns
`pages: 0` together with `Part::partd`. The per-page form `Import[pdf, {"Plaintext", n}]` is what
works, and is what the loop above uses.

## 8. Leaving the machine tidy

`UsingFrontEnd` starts its own headless front end. Those exit on their own, but it is worth
confirming that only the author's window is left, and that the file is still untouched:

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77"
tasklist | grep -iE "WolframNB.exe|WolframKernel.exe|wolframscript"
sha256sum ../claude-fable_Einstein-Rosen-2-Planes.nb
git status --porcelain=v1
```

One `WolframNB.exe` (the author's window) and its kernel; hash unchanged; tree clean.

## 9. Repeating the whole check from nothing

```bash
# 1. the file is what it should be
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77"
sha256sum ../claude-fable_Einstein-Rosen-2-Planes.nb
git status --porcelain=v1 -- claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb

# 2. open it, if it is not open already
FE="/c/Program Files/Wolfram Research/Wolfram/15.0.1/WolframNB.exe"
("$FE" "C:\Users\nsh\Documents\8-dim\claude-fable_Einstein-Rosen-2-Planes.nb" >/dev/null 2>&1 &)

# 3. the three checks
mkdir -p "C:/Users/nsh/Documents/8-dim/render3"
cp claude-fable/render-check/*.wls "C:/Users/nsh/Documents/8-dim/render3/"
cd "C:/Users/nsh/Documents/8-dim/render3"
wolframscript -file probe.wls 2>&1 | tee probe.log
wolframscript -file shots.wls 2>&1 | tee shots.log
wolframscript -file pdf.wls   2>&1 | tee pdf.log

# 4. nothing was written to the notebook
sha256sum "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb"
```

Expected: 213 cells, 0 `ErrorBox`, 0 unparsed `Input` cells, 0 private-use characters, six
distinct cell images, a 66-page PDF, and the same sha256 before and after.
