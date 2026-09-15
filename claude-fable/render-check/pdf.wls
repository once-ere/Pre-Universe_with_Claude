
(* --- self-locating, so this works from a clone at any path --------------------------------- *)
(* Run this script IN PLACE, from <repo>/claude-fable/render-check.  cfRepo is then the           *)
(* repository root and cfNB the delivered notebook.  Output goes to the directory named by the    *)
(* CF_OUT environment variable, or to a folder in the system temp directory if CF_OUT is unset,   *)
(* so that running this never writes into the repository.                                        *)
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
pdf = cfOut <> "rendered.pdf";
UsingFrontEnd[
  nb = NotebookOpen[src, Visible -> False];
  Export[pdf, nb];
  NotebookClose[nb]];
n = Import[pdf, "PageCount"];
Print["pdf : ", FileByteCount[pdf], " bytes   pages: ", n];
(* locate the blocks changed this session *)
needles = {"A word first on WHICH split", "the yZ split at 8 is NOT",
           "sigma16 alone is SYMMETRIC", "Count the gammas",
           "counts the times stage 3 returned TRUE",
           "identities accepted on numerical evidence alone"};
Do[Module[{hits = {}},
   Do[Module[{t = Quiet@Check[Import[pdf, {"Plaintext", k}], ""]},
      If[StringQ[t] && StringContainsQ[t, needle], AppendTo[hits, k]]], {k, n}];
   Print["  ", If[hits === {}, "NOT FOUND", "pages " <> ToString[hits]], "  <- ", needle]],
  {needle, needles}];
Print["source unchanged: ", IntegerString[Hash[ReadByteArray[src], "SHA256"], 16]];
