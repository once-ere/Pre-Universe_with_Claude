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
