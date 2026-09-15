(* Compare the eLa/eLazt written by TODAY's two runs against the author's own DumpSave output.
   Clear[] has HoldAll, so plain Clear[eLa] is what clears the symbol; Clear[Evaluate[eLa]] does not. *)
(* --- self-locating, so this script works from a clone at any path -------------------------- *)
(* $InputFileName is the path this file was invoked with; ExpandFileName makes it absolute even *)
(* when wolframscript was given a relative path.  cfHere is this script's own directory,        *)
(* i.e. <repo>/claude-fable, and cfRepo is the repository root.                                 *)
cfHere = DirectoryName[ExpandFileName[$InputFileName]];
cfRepo = ParentDirectory[cfHere];
cfNB   = FileNameJoin[{cfHere, "claude-fable_Einstein-Rosen-2-Planes.nb"}];
src = cfRepo <> "/";
cf  = cfHere <> "/";
(* The front-end run writes its .mx into the directory it was told to use, which is $CF_OUT, *)
(* or a folder in the system temp directory when CF_OUT is unset -- the same convention the  *)
(* render-check scripts follow.  Nothing here depends on a path outside the repository.      *)
fe  = Environment["CF_OUT"];
If[fe === $Failed || fe === "", fe = FileNameJoin[{$TemporaryDirectory, "cf-render-check"}]];
fe  = fe <> "/";

Get[src <> "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLa.mx"];
srcELa = eLa; Clear[eLa];
Get[src <> "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLazt.mx"];
srcELazt = eLazt; Clear[eLazt];

Get[cf <> "claude-fable_Einstein-Rosen-2-Planes-eLa.mx"];    kerELa = eLa; Clear[eLa];
Get[cf <> "claude-fable_Einstein-Rosen-2-Planes-eLazt.mx"];  kerELazt = eLazt; Clear[eLazt];
Get[fe <> "evaluated-eLa.mx"];                               feELa = eLa; Clear[eLa];
Get[fe <> "evaluated-eLazt.mx"];                             feELazt = eLazt; Clear[eLazt];

cv = x0 > 0 && x4 > 0 && z > 0 && t > 0;
Print["lengths eLa   : author ", Length[srcELa],   "  kernel-run ", Length[kerELa],   "  front-end ", Length[feELa]];
Print["lengths eLazt : author ", Length[srcELazt], "  kernel-run ", Length[kerELazt], "  front-end ", Length[feELazt]];
Print["eLa   author === kernel-run (SameQ) : ", srcELa   === kerELa];
Print["eLa   author === front-end  (SameQ) : ", srcELa   === feELa];
Print["eLazt author === kernel-run (SameQ) : ", srcELazt === kerELazt];
Print["eLazt author === front-end  (SameQ) : ", srcELazt === feELazt];
Print["eLa   residual author - kernel-run  : ", Union@Flatten@Simplify[srcELa   - kerELa,   cv]];
Print["eLazt residual author - kernel-run  : ", Union@Flatten@Simplify[srcELazt - kerELazt, cv]];
