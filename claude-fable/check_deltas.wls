
(* --- self-locating, so this script works from a clone at any path -------------------------- *)
(* $InputFileName is the path this file was invoked with; ExpandFileName makes it absolute even *)
(* when wolframscript was given a relative path.  cfHere is this script's own directory,        *)
(* i.e. <repo>/claude-fable, and cfRepo is the repository root.                                 *)
cfHere = DirectoryName[ExpandFileName[$InputFileName]];
cfRepo = ParentDirectory[cfHere];
cfNB   = FileNameJoin[{cfHere, "claude-fable_Einstein-Rosen-2-Planes.nb"}];
nbfile = cfNB;
SetDirectory[cfHere];
nb = Import[nbfile, "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
Block[{$Output = {}}, Do[ReleaseHold[asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, 1, 126}]];
t1 = AbsoluteTiming[
  db = Map[If[# === 0, 0, FullSimplify[#, cfGeomAssume, TimeConstraint -> 20]] &, deltaBoost, {-1}];];
Print["deltaBoost FullSimplify seconds: ", t1[[1]]];
Print["deltaBoost raw non-zero slots      : ", Count[Flatten[deltaBoost], Except[0]]];
Print["deltaBoost simplified non-zero     : ", Count[Flatten[db], Except[0]]];
Scan[Print["  Delta1[", #[[1]]-1, "] flat (", #[[2]]-1, ",", #[[3]]-1, ") = ", InputForm[db[[Sequence@@#]]]]&,
  Select[Flatten[Table[{m,a,b},{m,8},{a,8},{b,8}],2], db[[Sequence@@#]] =!= 0 &]];
t2 = AbsoluteTiming[
  dn = Map[If[# === 0, 0, FullSimplify[#, cfGeomAssume, TimeConstraint -> 20]] &, deltaNull, {-1}];];
Print["deltaNull FullSimplify seconds: ", t2[[1]]];
Print["deltaNull raw non-zero slots      : ", Count[Flatten[deltaNull], Except[0]]];
Print["deltaNull simplified non-zero     : ", Count[Flatten[dn], Except[0]]];
Print["deltaNull simplified distinct     : ", Union[Flatten[dn]]];
