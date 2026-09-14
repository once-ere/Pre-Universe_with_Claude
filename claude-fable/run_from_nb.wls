(* Execute the notebook itself: import the .nb, take its Input cells in order, evaluate each.
   ToExpression[...,Hold] on a multi-line cell returns Hold[e1,e2,...]; rewrap those as one
   CompoundExpression so the cell evaluates as a single unit, exactly as the front end does. *)
Get["runner_header.wl"];
nbfile = "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb";
nb = Import[nbfile, "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
Print["evaluating ", Length[inputs], " Input cells straight out of the .nb"];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
Do[cfRunCell[i, asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, Length[inputs]}];
cfRunSummary[];
