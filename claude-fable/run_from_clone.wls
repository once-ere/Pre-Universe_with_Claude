(* Run the delivered notebook straight out of a fresh clone, with nothing from the
   development machine on the path.  The helper packages come from the clone too. *)
(* Self-locating and depth-independent: this file is committed at <repo>/claude-fable, but is
   also meant to be copied to a clone root.  Work out which, rather than assuming. *)
cfHere = DirectoryName[ExpandFileName[$InputFileName]];
cfCF   = If[FileExistsQ[FileNameJoin[{cfHere, "runner_header.wl"}]],
            cfHere,                                   (* run from inside claude-fable *)
            FileNameJoin[{cfHere, "claude-fable"}]];   (* run from the clone root      *)
dir    = ParentDirectory[cfCF];
SetDirectory[cfCF];
Print["working directory : ", Directory[]];
Get["runner_header.wl"];
nbfile = FileNameJoin[{cfCF, "claude-fable_Einstein-Rosen-2-Planes.nb"}];
Print["notebook          : ", nbfile];
Print["bytes             : ", FileByteCount[nbfile]];
nb = Import[nbfile, "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
Print["Input cells       : ", Length[inputs]];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
Do[cfRunCell[i, asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, Length[inputs]}];
cfRunSummary[];
