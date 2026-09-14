(* Compare the equations the refactor produces with the author's own DumpSave output. *)
src  = "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/";
mine = "C:/Users/nsh/Documents/8-dim/";

Get[src <> "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLa.mx"];
srcELa = eLa; Clear[eLa];
Get[src <> "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLazt.mx"];
srcELazt = eLazt; Clear[eLazt];
Get[mine <> "claude-fable_Einstein-Rosen-2-Planes-eLa.mx"];
myELa = eLa; Clear[eLa];
Get[mine <> "claude-fable_Einstein-Rosen-2-Planes-eLazt.mx"];
myELazt = eLazt; Clear[eLazt];

cv = x0 > 0 && x4 > 0 && z > 0 && t > 0;
Print["lengths: src eLa   ", Length[srcELa],   "   mine ", Length[myELa]];
Print["lengths: src eLazt ", Length[srcELazt], "   mine ", Length[myELazt]];
Print["eLa   IDENTICAL (SameQ)  : ", srcELa   === myELa];
Print["eLa   difference          : ", Union@Flatten@Simplify[srcELa   - myELa,   cv]];
Print["eLazt IDENTICAL (SameQ)  : ", srcELazt === myELazt];
Print["eLazt difference          : ", Union@Flatten@Simplify[srcELazt - myELazt, cv]];
Print["--- sample: the author's eLa[[1]] ---"]; Print[InputForm[srcELa[[1]]]];
Print["--- sample: the refactor's eLa[[1]] ---"]; Print[InputForm[myELa[[1]]]];
