(* Evaluate the delivered notebook in the Mathematica FRONT END, on a COPY, in a CLEAN kernel.
   Nothing else runs in this kernel, so no earlier Protect[] can contaminate it.
   Results are harvested with NotebookGet, because NotebookSave[nb,path] returns $Failed here. *)
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
src = cfNB;
dst = cfOut <> "evaluated.nb";
If[FileExistsQ[dst], DeleteFile[dst]];
CopyFile[src, dst];
Print["source   : ", FileByteCount[src], " bytes  sha256 ",
      IntegerString[Hash[ReadByteArray[src], "SHA256"], 16]];
t0 = AbsoluteTime[];
UsingFrontEnd[
  cfnb  = NotebookOpen[dst, Visible -> False];
  NotebookEvaluate[cfnb, InsertResults -> True];
  cfgot = NotebookGet[cfnb];
  NotebookClose[cfnb]];
Print["NotebookEvaluate + NotebookGet done in ", Round[AbsoluteTime[] - t0], " s"];
Export[dst, cfgot, "NB"];
Print["evaluated: ", FileByteCount[dst], " bytes"];
Print["styles   : ", SortBy[Tally[Cases[Import[dst, "Notebook"], Cell[_, s_String, ___] :> s, Infinity]], -Last[#] &]];
Print["source unchanged: ", IntegerString[Hash[ReadByteArray[src], "SHA256"], 16]];
pdf = cfOut <> "evaluated.pdf";
UsingFrontEnd[
  nb2 = NotebookOpen[dst, Visible -> False];
  Export[pdf, nb2];
  NotebookClose[nb2]];
Print["pdf bytes: ", FileByteCount[pdf], "   pages: ", Import[pdf, "PageCount"]];
