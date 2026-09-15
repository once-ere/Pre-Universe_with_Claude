(* Run the delivered notebook, then print the whole of Part II. *)

nbfile = "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb";
SetDirectory["C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"];
nb = Import[nbfile, "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
(* cells 1..90 = everything through section 14 *)
Block[{$Output = {}},
  Do[ReleaseHold[asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, 1, 90}]];

line[s_] := Print["\n================ ", s, " ================"];

line["THE WAVE FUNCTION"];
Print["Psi16 = ", InputForm[\[CapitalPsi]16]];
Print["type-1 half : ", InputForm[\[CapitalPsi]16upper]];
Print["type-2 half : ", InputForm[\[CapitalPsi]16lower]];

line["THE LAGRANGIAN"];
Print[InputForm[La[]]];

line["THE EXACT IDENTITIES BEHIND IT"];
Print["Psi16 . sigma16 . T16[alpha] . Psi16 == 0 for every alpha : ",
  Union@Table[Expand[Transpose[\[CapitalPsi]16] . \[Sigma]16 . T16[a-1] . \[CapitalPsi]16] === 0, {a,8}]];
Print["the kinetic term equals minus its transpose : ",
  Expand[Transpose[\[CapitalPsi]16] . \[Sigma]16 . Sum[T16[a-1] . D[\[CapitalPsi]16, X[[a]]], {a,8}]
   + Sum[D[Transpose[\[CapitalPsi]16], X[[a]]] . \[Sigma]16 . T16[a-1], {a,8}] . \[CapitalPsi]16] === 0];

line["THE SIXTEEN EULER-LAGRANGE EQUATIONS"];
Print[Column[eLa]];

line["THE COUPLING PATTERN"];
Print["blocks : ", eLaCouplings];
Print["block sizes : ", Length /@ eLaCouplings];
Print["they partition 0..15 : ", Sort[Flatten[eLaCouplings]] === Range[0,15]];

line["THE EQUATIONS IN THE (z,t) CHART"];
Print[Column[eLazt]];

line["THE FOUR 4x4 BLOCKS"];
Print[Column[coupledyZeqs]];
Print["each block is closed in its own four components : ",
  Table[Union@Cases[coupledyZeqs[[b]], yZ[n_Integer] :> n, Infinity, Heads -> True], {b,4}]];

line["WHAT DSolve DOES WITH THEM"];
Print[dsolveResults /. DSolve[a__] :> "returned unevaluated"];

line["THE MAPLE CLOSED FORMS, SUBSTITUTED BACK"];
Print["every one of the sixteen equations reduces to True : ",
  Union[Flatten[cfMapleCheck]] === {True}];
Print[Column[sYZvar]];

line["THE Z -> yZ TRANSFORMATION"];
Print["orthogonal, Transpose[S].S == ID16     : ", Transpose[almightyS] . almightyS === ID16];
Print["but NOT a Spin(8,8) transformation     : ",
  Transpose[almightyS] . \[Sigma]16 . almightyS =!= \[Sigma]16];
Print["and NOT a direct sum (it mixes type-1 with type-2) : ",
  caZ2 =!= ArrayFlatten[{{caZ2[[1;;8,1;;8]], 0}, {0, caZ2[[9;;16,9;;16]]}}]];

line["THE FIVE BILINEARS"];
Print["psi . sigma16 . psi == psi2.sigma.psi2 - psi1.sigma.psi1 : ",
  Simplify[psiSigma16psi - (psi2Sigmapsi2 - psi1Sigmapsi1), constraintVars] === 0];
Print[Column[{psiSigma16psi, psi1Sigmapsi1, psi2Sigmapsi2, psi2psi1, psi2Sigmapsi1}]];

line["THE BRANCH C2 = -C1, C4 = -C3"];
Print[Column[cfBilinearsOnBranch]];

line["THE TWO MASS BRANCHES"];
Print["Psi16ab : ", InputForm[\[CapitalPsi]16ab]];
Print["Psi16aa : ", InputForm[\[CapitalPsi]16aa]];

line["TRIALITY: SPINORS BECOME VECTORS"];
Print["vectorFormOfType1 : ", InputForm[vectorFormOfType1]];
Print["vectorFormOfType2 : ", InputForm[vectorFormOfType2]];
Print["the two bridges are mutually inverse : ", triVecToSpin . triSpinToVec === ID8];

line["THE TWO 7-PLANES AND THEIR INTERSECTION M6"];
Print["sevenPlane1 is annihilated by vectorFormOfType1 : ",
  Simplify[vectorFormOfType1 . sevenPlane1] === 0];
Print["sevenPlane2 is annihilated by vectorFormOfType2 : ",
  Simplify[vectorFormOfType2 . sevenPlane2] === 0];
Print["components M6 determines : ", First[sixPlane78][[All,1]]];
Print["free parameters remaining : ",
  Length[Complement[Array[zoct, 8], First[sixPlane78][[All,1]]]]];
Print["M6 = ", InputForm[M6]];

line["DONE"];
