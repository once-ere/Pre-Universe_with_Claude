(* Safe, NON-EVALUATING extraction of every authored cell of the original notebook.
   Box structures are rendered to plain text purely by string surgery.  Nothing is evaluated. *)

src = "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb";
dir = "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable/extract/";

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
