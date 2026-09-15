(* Run the delivered notebook, then print everything about the 16x16 Dirac matrices and the
   spinor covariant derivative. *)
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
(* cells 1..116 = everything through section 17 *)
Block[{$Output = {}},
  Do[ReleaseHold[asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, 1, 116}]];

line[s_] := Print["\n================ ", s, " ================"];

line["THE 16x16 DIRAC MATRICES gamma[a] = T16[a]"];
Print["dimensions of each: ", Dimensions[T16[0]]];
Print["Clifford relation {gamma^a,gamma^b} == 2 eta^{ab} ID16 : ",
  Union@Flatten@Table[
    T16[A] . T16[B] + T16[B] . T16[A] === 2 \[Eta]4488[[A+1,B+1]] ID16, {A,0,7},{B,0,7}]];
Print["chirality T16[8] squares to ID16 : ", T16[8] . T16[8] === ID16];
Print["sigma16 == ArrayFlatten[{{-sigma,0},{0,sigma}}] : ",
  \[Sigma]16 === ArrayFlatten[{{-\[Sigma], 0}, {0, \[Sigma]}}]];
Print["gamma[0] = "]; Print[MatrixForm[T16[0]]];

line["EVERY PRODUCT OF TWO GAMMAS IS BLOCK DIAGONAL"];
Print[Union@Flatten@Table[
   T16[A] . T16[B] === ArrayFlatten[{{\[Tau]bar[A] . \[Tau][B], 0}, {0, \[Tau][A] . \[Tau]bar[B]}}],
   {A,0,7},{B,0,7}]];

line["THE 16x16 SPIN-CONNECTION MATRIX Gamma^spin[mu]"];
Print["dimensions: ", Dimensions[GammaSpinCanonical]];
Print["(1/8) omega [gamma^a,gamma^b] == (1/2) omega SAB : ",
  cfZeroArrayQ[Table[GammaSpinCanonical[[mu]]
     - (1/2) Sum[omegaCanonical[[mu,a,b]] SAB[[a,b]], {a,8},{b,8}], {mu,8}]]];
Print["block diagonal (type-1 never mixes with type-2) : ",
  cfZeroArrayQ[Table[GammaSpinCanonical[[mu]]
     - ArrayFlatten[{{GammaSpinCanonical[[mu]][[1;;8,1;;8]], 0},
                     {0, GammaSpinCanonical[[mu]][[9;;16,9;;16]]}}], {mu,8}]]];
Print["directions mu where Gamma^spin[mu] is non-zero : ",
  Select[Range[8], Count[Flatten[GammaSpinCanonical[[#]]], Except[0]] > 0 &] - 1];
Do[If[Count[Flatten[GammaSpinCanonical[[mu]]], Except[0]] > 0,
   Print["  Gamma^spin[", mu-1, "] has ", Count[Flatten[GammaSpinCanonical[[mu]]], Except[0]],
         " non-zero entries"]], {mu, 8}];

line["THE TYPE-1 BLOCK, WRITTEN IN tau AND taubar"];
Print["type-1 block == (1/8) omega (taubar^a tau^b - taubar^b tau^a) : ",
  cfZeroArrayQ[Table[GammaSpinType1[[mu]] - (1/8) Sum[omegaCanonical[[mu,a,b]]
     (\[Tau]bar[a-1] . \[Tau][b-1] - \[Tau]bar[b-1] . \[Tau][a-1]), {a,8},{b,8}], {mu,8}]]];
Print["type-2 block == (1/8) omega (tau^a taubar^b - tau^b taubar^a) : ",
  cfZeroArrayQ[Table[GammaSpinType2[[mu]] - (1/8) Sum[omegaCanonical[[mu,a,b]]
     (\[Tau][a-1] . \[Tau]bar[b-1] - \[Tau][b-1] . \[Tau]bar[a-1]), {a,8},{b,8}], {mu,8}]]];
Print["the type-1 connection matrix in direction mu = 1:"];
Print[MatrixForm[GammaSpinType1[[2]]]];

line["THE COVARIANT DERIVATIVE ON A GENERIC SPINOR"];
Print["Dcov16 on the direct sum == direct sum of Dcov1 and Dcov2 : ",
  cfZeroArrayQ[Table[cfDcov16[psiGeneric, mu]
     - Join[cfDcovType1[psi1Generic, mu], cfDcovType2[psi2Generic, mu]], {mu, 8}]]];
Print["Dcov on a TYPE-1 split-octonion spinor, direction mu = 1, first two components:"];
Print[Column[cfDcovType1[psi1Generic, 2][[1 ;; 2]]]];

line["THE CURVED-SPACE DIRAC OPERATOR"];
Print["gammaCurved[mu] = coframe[[a,mu]] gamma^a"];
Print["{gammaCurved[mu],gammaCurved[nu]} == 2 g^{mu nu} ID16 : ",
  cfZeroArrayQ[Table[gammaCurvedCanonical[[mu]] . gammaCurvedCanonical[[nu]]
     + gammaCurvedCanonical[[nu]] . gammaCurvedCanonical[[mu]]
     - 2 gInvCanonical[[mu,nu]] ID16, {mu,8},{nu,8}]]];
Print["dimensions of the curved gamma list : ", Dimensions[gammaCurvedCanonical]];

line["DONE"];
