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
pdf = cfOut <> "evaluated.pdf";
n = Import[pdf, "PageCount"];
Do[t = Quiet@Check[Import[pdf, {"Plaintext", k}], ""];
   If[StringQ[t] && StringContainsQ[t, "difference from canonical"], Print["master table page: ", k]],
  {k, n}];
