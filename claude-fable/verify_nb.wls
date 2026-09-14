(* Verify the generated .nb: import it, pull out the Input cells, and evaluate them all in
   order in this kernel.  If the notebook is well formed, this reproduces run_all.wls exactly. *)
nbfile = "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb";
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
