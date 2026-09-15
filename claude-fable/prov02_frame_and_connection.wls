(* Run the delivered notebook, then print everything about the frame field and the canonical
   spin connection.  Self-contained: it needs only the .nb and the two helper .wl packages. *)

nbfile = "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb";
SetDirectory["C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"];
nb = Import[nbfile, "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
Print["notebook Input cells: ", Length[inputs]];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
(* evaluate cells 1..110, i.e. everything through section 16 *)
Block[{$Output = {}},
  Do[ReleaseHold[asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, 1, 110}]];

line[s_] := Print["\n================ ", s, " ================"];

line["THE FRAME FIELD  e[mu,a]"];
Print[MatrixForm[frameCanonical]];

line["THE INVERSE FRAME  e_a[mu]"];
Print[MatrixForm[coframeCanonical]];

line["THE CURVED METRIC  g[mu,nu]"];
Print[MatrixForm[gCanonical]];
Print["diagonal: ", InputForm[Diagonal[gCanonical]]];
Print["Det[g]  : ", InputForm[detgCanonical]];
Print["Sqrt[Abs[Det[g]]] : ", InputForm[sqrtDetgCanonical]];

line["[d] THE BRIDGE  g == e . eta . Transpose[e]"];
Print["residual (DEFINITION, cannot fail): ",
  cfZeroArrayQ[gCanonical - frameCanonical . \[Eta]4488 . Transpose[frameCanonical]]];
Print["g equals the STATED line element (has content): ",
  cfZeroArrayQ[gCanonical - DiagonalMatrix[{Tan[6 H x0]^2,
     cfQminus^2, cfQminus^2, cfQminus^2, -1, -cfQplus^2, -cfQplus^2, -cfQplus^2}]]];
Print["Diagonal[g] == Diagonal[eta] * Diagonal[frame]^2, exactly: ",
  cfZeroArrayQ[Diagonal[gCanonical] - Diagonal[\[Eta]4488] Diagonal[frameCanonical]^2]];

line["THE FLAT MINKOWSKI METRIC  eta[a,b]"];
Print[MatrixForm[\[Eta]4488]];
Print["eta . eta == ID8 ? ", \[Eta]4488 . \[Eta]4488 === ID8];
Print["signature : ", Diagonal[\[Eta]4488]];

line["NON-ZERO CHRISTOFFEL SYMBOLS  (37 of 512)"];
Print["count: ", Count[Flatten[GammaCanonical], Except[0]]];
Scan[Print["  Gamma[", #[[1]]-1, ";", #[[2]]-1, ",", #[[3]]-1, "] = ",
     InputForm[GammaCanonical[[Sequence @@ #]]]] &,
  Select[Flatten[Table[{r,m,p},{r,8},{m,8},{p,8}],2],
     GammaCanonical[[Sequence @@ #]] =!= 0 &]];

line["NON-ZERO CANONICAL SPIN-CONNECTION COMPONENTS  omega[mu,a,b]  (24 of 512)"];
Print["count: ", Count[Flatten[omegaCanonical], Except[0]]];
Scan[Print["  omega[", #[[1]]-1, ";", #[[2]]-1, ",", #[[3]]-1, "] = ",
     InputForm[omegaCanonical[[Sequence @@ #]]]] &,
  Select[Flatten[Table[{m,a,b},{m,8},{a,8},{b,8}],2],
     omegaCanonical[[Sequence @@ #]] =!= 0 &]];

line["THE CERTIFICATES, AND WHAT EACH ONE IS WORTH"];
Print["[solver regression] vielbein postulate residual is zero : ",
  cfZeroArrayQ[cfVielbeinResidual[frameCanonical, X, GammaCanonical, omegaCanonicalMixed]]];
Print["[structural]        torsion vanishes                    : ",
  cfZeroArrayQ[cfTorsion[frameCanonical, X, omegaCanonicalMixed]]];
Print["[structural]        Gamma symmetric in its lower indices : ",
  cfZeroArrayQ[Table[GammaCanonical[[r,m,p]] - GammaCanonical[[r,p,m]], {r,8},{m,8},{p,8}]]];
Print["[HAS CONTENT]       omega[mu,a,b] == -omega[mu,b,a]      : ",
  cfZeroArrayQ[Table[omegaCanonical[[m,a,b]] + omegaCanonical[[m,b,a]], {m,8},{a,8},{b,8}]]];
Print["[INDEPENDENT]       frame-only derivation reproduces omegaCanonical : ",
  cfZeroArrayQ[Table[Sum[omegaFromFrameUp[[mu,a,c]] \[Eta]4488[[c,b]], {c,8}]
     - omegaCanonicalMixed[[mu,a,b]], {mu,8},{a,8},{b,8}]]];

line["CURVATURE"];
Print["non-zero curvature components : ", Count[Flatten[RiemannCanonical], Except[0]]];
Print["Ricci scalar                  : ", InputForm[RicciScalarCanonical]];

line["DONE"];
