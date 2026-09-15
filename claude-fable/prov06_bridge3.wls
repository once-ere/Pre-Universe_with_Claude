(* Run the delivered notebook, then print the whole of the bridge-3 comparison. *)
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
(* cells 1..135 = everything through section 20 *)
Block[{$Output = {}},
  Do[ReleaseHold[asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, 1, 135}]];

line[s_] := Print["\n================ ", s, " ================"];

line["THE TRIALITY BRIDGE"];
Print["triVecToSpin = "]; Print[MatrixForm[triVecToSpin]];
Print["it is ORTHOGONAL: Transpose[P] == Inverse[P] : ",
  cfZeroArrayQ[Transpose[triVecToSpin] - triSpinToVec]];
Print["it carries eta4488 exactly onto sigma        : ", \[Eta]Tri === \[Sigma]];
Print["so its tangent metric is the SPINOR metric   : ", \[Eta]TriFlat === \[Sigma]];

line["THE NEW FRAME FIELD"];
Print["frameTri = frameCanonical . triVecToSpin = "]; Print[MatrixForm[frameTri]];
Print["it gives the SAME curved metric g : ",
  cfZeroArrayQ[frameTri . \[Eta]TriFlat . Transpose[frameTri] - gCanonical]];

line["THE TOTALLY ANTISYMMETRIC SPLIT-OCTONION STRUCTURE CONSTANTS"];
Print["mSkewSpin is totally antisymmetric : ",
  cfZeroArrayQ[{Table[mSkewSpin[[a,b,c]] + mSkewSpin[[b,a,c]], {a,8},{b,8},{c,8}],
                Table[mSkewSpin[[a,b,c]] + mSkewSpin[[a,c,b]], {a,8},{b,8},{c,8}]}]];
Print["non-zero components of mSkewSpin : ", Count[Flatten[mSkewSpin], Except[0]]];
Print["distinct values : ", Union[Flatten[mSkewSpin]]];

line["THE lambda = 0 PART: LEVI-CIVITA IN THE TRIALITY FRAME"];
Print["non-zero components of omegaTriLC : ", Count[Flatten[omegaTriLC], Except[0]]];
Print["vielbein postulate holds identically : ",
  cfZeroArrayQ[cfVielbeinResidual[frameTri, X, GammaCanonical, omegaTriLCMixed]]];
Print["omega[mu,a,b] == -omega[mu,b,a] : ",
  cfZeroArrayQ[Table[omegaTriLC[[m,a,b]] + omegaTriLC[[m,b,a]], {m,8},{a,8},{b,8}]]];
Print["it IS the constant triality conjugate of the canonical connection : ",
  cfZeroArrayQ[Table[omegaTriLCMixed[[mu]]
     - triSpinToVec . omegaCanonicalMixed[[mu]] . triVecToSpin, {mu,8}]]];

line["THE NEW CONNECTION: LEVI-CIVITA PLUS OCTONIONIC SKEW TORSION"];
Print["non-zero contortion components : ", Count[Flatten[contortionOct], Except[0]]];
Print["omegaOct[mu,a,b] == -omegaOct[mu,b,a]  (still metric compatible) : ",
  cfZeroArrayQ[Table[omegaOct[[m,a,b]] + omegaOct[[m,b,a]], {m,8},{a,8},{b,8}]]];
Print["at lambda = 0 it reduces to Levi-Civita : ",
  cfZeroArrayQ[(omegaOct /. \[Lambda]Oct -> 0) - omegaTriLC]];

line["ITS TORSION"];
Print["torsion vanishes at lambda = 0 : ", cfZeroArrayQ[torsionOct /. \[Lambda]Oct -> 0]];
Print["torsion is NOT zero for lambda != 0 : ",
  ! TrueQ[cfZeroArrayQ[torsionOct /. \[Lambda]Oct -> 1]]];
Print["non-zero flat torsion components : ", Count[Flatten[torsionOctFlat], Except[0]]];
Print["T[a,b,c] is TOTALLY ANTISYMMETRIC : ",
  cfZeroArrayQ[{Table[torsionOctFlat[[a,b,c]] + torsionOctFlat[[b,a,c]], {a,8},{b,8},{c,8}],
                Table[torsionOctFlat[[a,b,c]] + torsionOctFlat[[a,c,b]], {a,8},{b,8},{c,8}]}]];
Print["T[a,b,c] == -2 lambda mSkewSpin[a,b,c] : ",
  cfZeroArrayQ[Table[torsionOctFlat[[a,b,c]] + 2 \[Lambda]Oct mSkewSpin[[a,b,c]],
    {a,8},{b,8},{c,8}]]];

line["COMPARISON WITH THE CANONICAL SPIN CONNECTION"];
Print["omegaOct - (triality conjugate of omegaCanonical) == contortion : ",
  cfZeroArrayQ[deltaOct - contortionOctMixed]];
Print["the difference vanishes at lambda = 0 : ",
  cfZeroArrayQ[deltaOct /. \[Lambda]Oct -> 0]];
Print["non-zero components of the difference : ", Count[Flatten[deltaOct], Except[0]]];
Print["the difference is linear in lambda : ",
  cfZeroArrayQ[(deltaOct /. \[Lambda]Oct -> 2) - 2 (deltaOct /. \[Lambda]Oct -> 1)]];

line["THE DIRAC MATRICES THAT MATCH THIS FRAME"];
(* cfSpinMatrix of Section 17 contracts flat indices against T16, which obeys the eta4488     *)
(* Clifford relation.  Bridge 3's flat index is a sigma-type spinor index, so the matching    *)
(* Dirac matrices are the triality transports T16Tri.                                         *)
Print["{T16Tri[a],T16Tri[b]} == 2 sigma[[a,b]] ID16 : ",
  cfZeroArrayQ[Table[T16Tri[a] . T16Tri[b] + T16Tri[b] . T16Tri[a]
     - 2 \[Eta]TriFlat[[a,b]] ID16, {a,8},{b,8}]]];
Print["they differ from the vector-frame T16 : ",
  ! TrueQ[cfZeroArrayQ[Table[T16Tri[a] - T16[a-1], {a,8}]]]];
Print["T16 does NOT obey the sigma relation : ",
  ! TrueQ[cfZeroArrayQ[Table[T16[a-1] . T16[b-1] + T16[b-1] . T16[a-1]
     - 2 \[Eta]TriFlat[[a,b]] ID16, {a,8},{b,8}]]]];

line["THE EFFECT ON THE SPINOR COVARIANT DERIVATIVE"];
Print["at lambda = 0 the Bridge 3 spinor connection equals the canonical one : ",
  cfZeroArrayQ[Table[(GammaSpinOct[[mu]] /. \[Lambda]Oct -> 0) - GammaSpinCanonical[[mu]], {mu,8}]]];
Print["extra 16x16 coupling vanishes at lambda = 0 : ",
  cfZeroArrayQ[GammaSpinOctExtra /. \[Lambda]Oct -> 0]];
Print["extra coupling is non-zero for lambda != 0  : ",
  ! TrueQ[cfZeroArrayQ[GammaSpinOctExtra /. \[Lambda]Oct -> 1]]];
Print["it is still block diagonal (type-1 + type-2 preserved) : ",
  cfZeroArrayQ[Table[GammaSpinOctExtra[[mu]]
     - ArrayFlatten[{{GammaSpinOctExtra[[mu]][[1;;8,1;;8]], 0},
                     {0, GammaSpinOctExtra[[mu]][[9;;16,9;;16]]}}], {mu,8}]]];
Print["non-zero entries in the extra coupling : ",
  Count[Flatten[GammaSpinOctExtra], Except[0]]];

line["DONE"];
