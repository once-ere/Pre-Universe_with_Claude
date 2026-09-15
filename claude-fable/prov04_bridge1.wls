(* Run the delivered notebook, then print the whole of the bridge-1 comparison. *)
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
(* cells 1..122 = everything through section 18 *)
Block[{$Output = {}},
  Do[ReleaseHold[asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, 1, 122}]];

line[s_] := Print["\n================ ", s, " ================"];

line["THE NEW OBJECT: A LOCAL BOOST Lambda(x)"];
Print["Lambda = "]; Print[MatrixForm[cfLambda]];
Print["Lambda . eta . Transpose[Lambda] == eta   (Lambda is in O(4,4)) : ",
  cfZeroArrayQ[cfLambda . \[Eta]4488 . Transpose[cfLambda] - \[Eta]4488]];
Print["Lambda . Transpose[Lambda] != ID8         (a boost, not a rotation) : ",
  ! TrueQ[cfZeroArrayQ[cfLambda . Transpose[cfLambda] - ID8]]];
Print["Lambda == MatrixExp[theta K] : ",
  cfZeroArrayQ[cfLambdaOf[\[Theta]] - MatrixExp[\[Theta] cfBoostGenerator]]];
Print["the boost generator K = "]; Print[MatrixForm[cfBoostGenerator]];

line["THE NEW FRAME FIELD"];
Print["frameBoost = frameCanonical . Lambda ="]; Print[MatrixForm[frameBoost]];
Print["it is a DIFFERENT frame : ", frameBoost =!= frameCanonical];
Print["but it gives the SAME curved metric g : ",
  cfZeroArrayQ[frameBoost . \[Eta]4488 . Transpose[frameBoost] - gCanonical]];

line["THE NEW SPIN CONNECTION"];
Print["non-zero components of omegaBoost : ", Count[Flatten[omegaBoost], Except[0]]];
Print["   (canonical had ", Count[Flatten[omegaCanonical], Except[0]], ")"];
Print["vielbein postulate holds identically : ",
  cfZeroArrayQ[cfVielbeinResidual[frameBoost, X, GammaCanonical, omegaBoostMixed]]];
Print["omega[mu,a,b] == -omega[mu,b,a]      : ",
  cfZeroArrayQ[Table[omegaBoost[[m,a,b]] + omegaBoost[[m,b,a]], {m,8},{a,8},{b,8}]]];
Print["torsion still vanishes               : ",
  cfZeroArrayQ[cfTorsion[frameBoost, X, omegaBoostMixed]]];

line["COMPARISON WITH THE CANONICAL SPIN CONNECTION"];
Print["omegaBoost == M omegaCanonical Inverse[M] - D[M,x_mu] Inverse[M],  M = Transpose[Lambda] : ",
  cfZeroArrayQ[omegaBoostMixed - omegaBoostPredicted]];
Print["the WHOLE difference is the inhomogeneous gauge term : ",
  cfZeroArrayQ[deltaBoost - gaugeTermBoost]];
Print["the difference equals -D[theta,x_mu] * K : ",
  cfZeroArrayQ[Table[deltaBoost[[mu]]
    + D[cfBoostRapidity[x0,x4], X[[mu]]] cfBoostGenerator, {mu,8}]]];
Print["non-zero components of the difference : ", Count[Flatten[deltaBoost], Except[0]]];
Scan[Print["  Delta1[", #[[1]]-1, "] flat entry (", #[[2]]-1, ",", #[[3]]-1, ") = ",
      InputForm[deltaBoost[[Sequence @@ #]]]] &,
  Select[Flatten[Table[{m,a,b},{m,8},{a,8},{b,8}],2], deltaBoost[[Sequence @@ #]] =!= 0 &]];

line["THE GEOMETRY IS THE SAME: CURVATURE AND RICCI SCALAR"];
Print["R' == M R Inverse[M]  (curvature transforms covariantly) : ",
  cfZeroArrayQ[Table[RiemannBoost[[mu,nu]] - cfM . RiemannCanonical[[mu,nu]] . cfMinv,
    {mu,8},{nu,8}]]];
Print["Ricci scalar, canonical : ", InputForm[RicciScalarCanonical]];
Print["Ricci scalar, bridge 1  : ", InputForm[RicciScalarBoost]];
Print["they are equal          : ", cfZeroQ[RicciScalarBoost - RicciScalarCanonical]];

line["DONE"];
