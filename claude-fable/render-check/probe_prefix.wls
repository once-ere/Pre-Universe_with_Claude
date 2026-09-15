
(* --- self-locating, so this works from a clone at any path --------------------------------- *)
(* Run in place, from <repo>/claude-fable/render-check.  Output goes to $CF_OUT, or a folder in *)
(* the system temp directory when CF_OUT is unset, so this never writes into the repository.    *)
cfHere = DirectoryName[ExpandFileName[$InputFileName]];
cfRepo = ParentDirectory[ParentDirectory[cfHere]];
cfNB   = FileNameJoin[{cfRepo, "claude-fable", "claude-fable_Einstein-Rosen-2-Planes.nb"}];
cfOut  = Environment["CF_OUT"];
If[cfOut === $Failed || cfOut === "", cfOut = FileNameJoin[{$TemporaryDirectory, "cf-render-check"}]];
Quiet[CreateDirectory[cfOut]];
cfOut  = cfOut <> "/";
Print["repo   : ", cfRepo];
Print["output : ", cfOut];
src = cfNB;
out = cfOut <> "prefix.nb";
full = Import[src, "Notebook"];
cells = First[full];
opts = Rest[full];
(* keep cells up to and including the 12th Input cell *)
pos = Position[cells, Cell[_, "Input", ___], 1][[12, 1]];
Export[out, Notebook[Take[cells, pos], Sequence @@ opts], "NB"];
Print["prefix cells: ", Length[Take[cells, pos]], "  bytes=", FileByteCount[out]];
Print["prefix opts : ", InputForm[opts]];

UsingFrontEnd[
  nb = NotebookOpen[out, Visible -> False];
  Print["open  -> ", Head[nb]];
  r = NotebookEvaluate[nb, InsertResults -> True];
  Print["eval  -> returned head ", Head[r]];
  Print["cells now in memory: ",
     Tally[Cases[NotebookGet[nb], Cell[_, s_String, ___] :> s, Infinity]]];
  s = NotebookSave[nb, out];
  Print["save  -> ", InputForm[s]];
  NotebookClose[nb]];
Print["after : bytes=", FileByteCount[out], "  styles=",
  Tally[Cases[Import[out, "Notebook"], Cell[_, s_String, ___] :> s, Infinity]]];
