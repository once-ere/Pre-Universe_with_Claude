(* Run the delivered notebook straight out of a fresh clone, with nothing from the
   development machine on the path.  The helper packages come from the clone too. *)
dir = DirectoryName[$InputFileName];
SetDirectory[FileNameJoin[{dir, "claude-fable"}]];
Print["working directory : ", Directory[]];
Get["runner_header.wl"];
nbfile = FileNameJoin[{dir, "claude-fable", "claude-fable_Einstein-Rosen-2-Planes.nb"}];
Print["notebook          : ", nbfile];
Print["bytes             : ", FileByteCount[nbfile]];
nb = Import[nbfile, "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
Print["Input cells       : ", Length[inputs]];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
Do[cfRunCell[i, asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, Length[inputs]}];
cfRunSummary[];
