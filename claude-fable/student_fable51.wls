(* student_fable51.wls -- use the fable-5.1 result: solve the connection-free Dirac equation,   *)
(* multiply by Sqrt[Sin[6 H x0]], and you have solved the Levi-Civita one.                     *)
(* Run from anywhere:  wolframscript -file student_fable51.wls                                 *)
cfHere = DirectoryName[ExpandFileName[$InputFileName]];
Get[FileNameJoin[{cfHere, "runner_header.wl"}]];
nb = Import[FileNameJoin[{cfHere, "claude-fable_Einstein-Rosen-2-Planes.nb"}], "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
(* evaluate the notebook's cells until Section 17's Dirac operator exists *)
i = 0;
Block[{$Output = {}},
  While[! (ValueQ[GammaSpinCanonical] && DownValues[cfDiracOperator] =!= {}) && i < Length[inputs],
    i++; cfRunCell[i, asOne[ToExpression[inputs[[i]], InputForm, Hold]]]]];
Print["notebook state loaded through Input cell ", i];

(* the connection-free (fable-5.1) Dirac operator: curved gammas, no connection *)
cfDiracFable51[psi_List] := Sum[gammaCurvedCanonical[[mu]] . D[psi, X[[mu]]], {mu, 8}];
(* a generic real 16-component spinor and a generic mass *)
psiP = Table[psiPrime[k] @@ X, {k, 0, 15}];
weight = Sqrt[Sin[6 H x0]];

(* THE IDENTITY, on a generic spinor: DiracCanonical[weight psi'] == weight DiracFable51[psi'] *)
identity = Simplify[cfDiracOperator[weight psiP] - weight cfDiracFable51[psiP], cfGeomAssume];
Print["Dirac_LC[Sqrt[Sin] Psi'] - Sqrt[Sin] gamma^mu d_mu Psi'  ==  ", identity];

(* so the two Dirac EQUATIONS are equivalent, mass term included: *)
eqLC     = cfDiracOperator[weight psiP] + m weight psiP;        (* Levi-Civita, on Psi = weight Psi' *)
eqFable  = weight (cfDiracFable51[psiP] + m psiP);              (* connection-free, on Psi'          *)
Print["the two equations differ by: ", Simplify[eqLC - eqFable, cfGeomAssume]];

(* how to convert a solution: *)
Print["given Psi' solving  gamma^mu d_mu Psi' + m Psi' == 0,  the Levi-Civita solution is  Psi = ",
  weight, " Psi'"];
Print["given Psi solving the Levi-Civita equation, the connection-free solution is  Psi' = Psi / ", weight];
