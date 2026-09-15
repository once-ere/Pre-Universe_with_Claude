(* Run the delivered notebook, then print the whole of the bridge-2 comparison. *)

nbfile = "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb";
SetDirectory["C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"];
nb = Import[nbfile, "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
(* cells 1..127 = everything through section 19 *)
Block[{$Output = {}},
  Do[ReleaseHold[asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, 1, 127}]];

line[s_] := Print["\n================ ", s, " ================"];

line["THE CONSTANT NULL ROTATION U"];
Print["U = "]; Print[MatrixForm[cfU]];
Print["U == Transpose[U]  : ", cfU === Transpose[cfU]];
Print["U . U == ID8       : ", cfZeroArrayQ[cfU . cfU - ID8]];
Print["U is constant      : ", cfZeroArrayQ[Table[D[cfU, X[[mu]]], {mu, 8}]]];

line["THE NEW FLAT TANGENT METRIC"];
Print["etaNull = Transpose[U] . eta4488 . U = "]; Print[MatrixForm[\[Eta]Null]];
Print["etaNull == sigma, the split-octonion SPINOR metric : ", \[Eta]Null === \[Sigma]];
Print["diagonal of etaNull (all frame directions are null) : ", Diagonal[\[Eta]Null]];
Print["etaNull . etaNull == ID8 : ", \[Eta]Null . \[Eta]Null === ID8];

line["THE NEW FRAME FIELD"];
Print["frameNull = frameCanonical . U = "]; Print[MatrixForm[frameNull]];
Print["it gives the SAME curved metric g : ",
  cfZeroArrayQ[frameNull . \[Eta]Null . Transpose[frameNull] - gCanonical]];

line["THE NEW SPIN CONNECTION"];
Print["non-zero components of omegaNull : ", Count[Flatten[omegaNull], Except[0]]];
Print["   (canonical had ", Count[Flatten[omegaCanonical], Except[0]], ")"];
Print["vielbein postulate holds identically : ",
  cfZeroArrayQ[cfVielbeinResidual[frameNull, X, GammaCanonical, omegaNullMixed]]];
Print["omega[mu,a,b] == -omega[mu,b,a] with indices lowered by etaNull : ",
  cfZeroArrayQ[Table[omegaNull[[m,a,b]] + omegaNull[[m,b,a]], {m,8},{a,8},{b,8}]]];
Print["torsion vanishes : ", cfZeroArrayQ[cfTorsion[frameNull, X, omegaNullMixed]]];

line["COMPARISON WITH THE CANONICAL SPIN CONNECTION"];
Print["omegaNull == U . omegaCanonical . U  exactly : ",
  cfZeroArrayQ[Table[omegaNullMixed[[mu]] - cfU . omegaCanonicalMixed[[mu]] . cfU, {mu,8}]]];
Print["the inhomogeneous gauge term D[U,x_mu].Inverse[U] is identically ZERO : ",
  cfZeroArrayQ[Table[D[cfU, X[[mu]]], {mu, 8}]]];
Print["so the difference Delta2 has ", Count[Flatten[deltaNull], Except[0]],
      " non-zero components; its distinct entries are ", Union[Flatten[deltaNull]]];

line["THE NON-ZERO COMPONENTS OF omegaNull"];
Scan[Print["  omegaNull[", #[[1]]-1, ";", #[[2]]-1, ",", #[[3]]-1, "] = ",
     InputForm[omegaNull[[Sequence @@ #]]]] &,
  Select[Flatten[Table[{m,a,b},{m,8},{a,8},{b,8}],2], omegaNull[[Sequence @@ #]] =!= 0 &]];

line["THE GEOMETRY IS THE SAME: CURVATURE AND RICCI SCALAR"];
Print["R_null == U R_canonical U : ",
  cfZeroArrayQ[Table[RiemannNull[[mu,nu]] - cfU . RiemannCanonical[[mu,nu]] . cfU,
    {mu,8},{nu,8}]]];
Print["Ricci scalar, canonical : ", InputForm[RicciScalarCanonical]];
Print["Ricci scalar, bridge 2  : ", InputForm[RicciScalarNull]];
Print["they are equal          : ", cfZeroQ[RicciScalarNull - RicciScalarCanonical]];

line["DONE"];
