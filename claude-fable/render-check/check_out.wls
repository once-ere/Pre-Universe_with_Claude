
(* --- self-locating, so this works from a clone at any path --------------------------------- *)
(* Run in place, from <repo>/claude-fable/render-check.  Output goes to $CF_OUT, or to a folder  *)
(* in the system temp directory when CF_OUT is unset, so this never writes into the repository.  *)
cfHere = DirectoryName[ExpandFileName[$InputFileName]];
cfRepo = ParentDirectory[ParentDirectory[cfHere]];
cfNB   = FileNameJoin[{cfRepo, "claude-fable", "claude-fable_Einstein-Rosen-2-Planes.nb"}];
cfOut  = Environment["CF_OUT"];
If[cfOut === $Failed || cfOut === "", cfOut = FileNameJoin[{$TemporaryDirectory, "cf-render-check"}]];
Quiet[CreateDirectory[cfOut]];
cfOut  = cfOut <> "/";
dst = cfOut <> "evaluated.nb";
nb  = Import[dst, "Notebook"];
cells = First[nb];
outs = Cases[nb, Cell[c_, "Output", ___] :> c, Infinity];
Print["Output cells            : ", Length[outs]];
Print["ErrorBox anywhere       : ", Length[Cases[nb, ErrorBox[___], Infinity]]];

txt[e_] := StringJoin[Cases[e, _String, Infinity]];
bad = {"$Failed", "$Aborted", "Indeterminate", "ComplexInfinity", "DirectedInfinity",
       "Null[", "Missing[", "Interrupt", "$MachinePrecision"};
Do[Module[{t = txt[outs[[i]]]},
   Scan[If[StringContainsQ[t, #], Print["  SUSPECT output cell ", i, " contains ", #,
           "  ->  ", StringTake[t, Min[200, StringLength[t]]]]] &, bad]],
  {i, Length[outs]}];
Print["suspect scan done"];

(* unevaluated heads that would mean a cell did not compute *)
Do[Module[{t = txt[outs[[i]]]},
   If[StringContainsQ[t, "DSolve[" | "Solve[" | "Integrate[" | "FullSimplify["],
      Print["  cell ", i, " output still shows an unevaluated head: ",
            StringTake[t, Min[160, StringLength[t]]]]]],
  {i, Length[outs]}];
Print["unevaluated-head scan done"];

Print["---- the last 6 Output cells, as plain text ----"];
Do[Print["[out ", i, "] ", StringTake[txt[outs[[i]]], Min[1400, StringLength[txt[outs[[i]]]]]]],
  {i, Length[outs] - 5, Length[outs]}];
