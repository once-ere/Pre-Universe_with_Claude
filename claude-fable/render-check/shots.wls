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
