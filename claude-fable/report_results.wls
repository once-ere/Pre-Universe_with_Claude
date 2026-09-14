(* Run the notebook and print the headline results, for the provenance documents. *)
Get["runner_header.wl"];
nbfile = "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb";
SetDirectory["C:/Users/nsh/Documents/8-dim"];
nb = Import[nbfile, "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
Block[{$Output = {}}, Do[cfRunCell[i, asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, Length[inputs]}]];
Print["================= HEADLINE RESULTS ================="];
Print["metric g diagonal        : ", InputForm[Diagonal[gCanonical]]];
Print["Det[g]                   : ", InputForm[detgCanonical]];
Print["Ricci scalar (canonical) : ", InputForm[RicciScalarCanonical]];
Print["Ricci scalar (bridge 1)  : ", InputForm[RicciScalarBoost]];
Print["Ricci scalar (bridge 2)  : ", InputForm[RicciScalarNull]];
Print["nonzero Gamma            : ", Count[Flatten[GammaCanonical], Except[0]]];
Print["nonzero omegaCanonical   : ", Count[Flatten[omegaCanonical], Except[0]]];
Print["nonzero omegaBoost       : ", Count[Flatten[omegaBoost], Except[0]]];
Print["nonzero omegaNull        : ", Count[Flatten[omegaNull], Except[0]]];
Print["nonzero omegaTriLC       : ", Count[Flatten[omegaTriLC], Except[0]]];
Print["nonzero contortionOct    : ", Count[Flatten[contortionOct], Except[0]]];
Print["nonzero RiemannCanonical : ", Count[Flatten[RiemannCanonical], Except[0]]];
Print["nonzero torsionOctFlat   : ", Count[Flatten[torsionOctFlat], Except[0]]];
Print["nonzero mSkewSpin        : ", Count[Flatten[mSkewSpin], Except[0]]];
Print["--- non-zero Christoffel symbols ---"];
Scan[Print["  Gamma[", #[[1]]-1, ";", #[[2]]-1, ",", #[[3]]-1, "] = ", InputForm[GammaCanonical[[Sequence@@#]]]]&,
  Select[Flatten[Table[{r,m,p},{r,8},{m,8},{p,8}],2], GammaCanonical[[Sequence@@#]] =!= 0 &]];
Print["--- non-zero canonical spin-connection components ---"];
Scan[Print["  omega[", #[[1]]-1, ";", #[[2]]-1, ",", #[[3]]-1, "] = ", InputForm[omegaCanonical[[Sequence@@#]]]]&,
  Select[Flatten[Table[{m,a,b},{m,8},{a,8},{b,8}],2], omegaCanonical[[Sequence@@#]] =!= 0 &]];
Print["--- non-zero components of Delta1 = omegaBoost - conjugate(omegaCanonical) ---"];
Scan[Print["  Delta1[", #[[1]]-1, "][", #[[2]], ",", #[[3]], "] = ", InputForm[deltaBoost[[Sequence@@#]]]]&,
  Select[Flatten[Table[{m,a,b},{m,8},{a,8},{b,8}],2], deltaBoost[[Sequence@@#]] =!= 0 &]];
Print["--- Delta2 = omegaNull - U omegaCanonical U ---"];
Print["  identically zero? ", Union[Flatten[deltaNull]] === {0}, "   entries: ", Union[Flatten[deltaNull]]];
Print["--- Delta3 = omegaOct - conjugate(omegaCanonical) : first few non-zero ---"];
Print["  count: ", Count[Flatten[deltaOct], Except[0]]];
Print["  sample: ", InputForm[Select[Flatten[deltaOct], # =!= 0 &][[1 ;; 3]]]];
Print["--- Psi16ab (the two-solution branch) ---"];
Print[InputForm[\[CapitalPsi]16ab]];
Print["--- M6 (the 6-plane) determined components ---"];
Print[InputForm[First[sixPlane78][[All,1]]]];
Print["numerical certificates used: ", $cfNumericCertificates];
cfAssertSummary[];
