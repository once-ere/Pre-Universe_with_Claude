(* Read-only instrumentation.  Run the delivered notebook exactly as run_from_nb.wls does, but
   wrap cfNumericallyZeroQ -- the single function every certificate increment is adjacent to --
   so each call is logged with the cell it happened in, the expression, and the verdict.
   Wrapping cfAssert would NOT work: cfAssert is not HoldRest, so its argument (and therefore
   the certificate consumption) is evaluated before cfAssert is ever entered.
   The notebook file itself is not modified. *)
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
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];

$nzLog = {};  $cell = 0;  $wrapped = False;

wrapIt[] := If[! $wrapped && DownValues[Global`cfNumericallyZeroQ] =!= {},
  $wrapped = True;
  DownValues[nzOrig] =
    DownValues[Global`cfNumericallyZeroQ] /. Global`cfNumericallyZeroQ -> nzOrig;
  Clear[Global`cfNumericallyZeroQ];
  Global`cfNumericallyZeroQ[e_] := Module[{r = nzOrig[e]},
    AppendTo[$nzLog, {$cell, r, ToString[Short[e, 1], InputForm]}];
    r];
  Print[">>> cfNumericallyZeroQ instrumented after cell ", $cell]];

Do[$cell = i;
   cfRunCell[i, asOne[ToExpression[inputs[[i]], InputForm, Hold]]];
   wrapIt[],
  {i, Length[inputs]}];

Print["==================== CERTIFICATE ATTRIBUTION ===================="];
Print["counter says            : ", Global`$cfNumericCertificates];
Print["cfNumericallyZeroQ calls: ", Length[$nzLog]];
Print["  of which returned True (a genuine positive certification): ",
      Count[$nzLog, {_, True, _}]];
Print["  of which returned False (i.e. the expression was shown NOT to vanish): ",
      Count[$nzLog, {_, False, _}]];
Print["---- every call, in order ----"];
Scan[Function[e, Print["  cell ", e[[1]], "   verdict ", e[[2]], "   on: ", e[[3]]]], $nzLog];
cfRunSummary[];
