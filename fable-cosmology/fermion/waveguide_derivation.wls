(* ::Package:: *)
(* ================================================================================================
   waveguide_derivation.wls  --  fermion fable along the hidden coordinate x0: the exact reduction
   of the 16-component Dirac equation on the canonical frame to 2x2 ODEs in proper distance z, the
   wall boundary conditions, and the symmetry facts the numerics (waveguide.py) rely on.

   Self-contained: it loads Input cells 1..117 of the built notebook
       claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb
   headlessly (same pattern as the reviewers' probes), and then uses ONLY the notebook's own objects:
       T16[0..8], \[Sigma]16, gammaCurvedCanonical, GammaSpinCanonical, cfDcov16, gCanonical,
       RicciScalarCanonical, X.
   Every result is printed with a PASS/FAIL check.  Nothing here is fitted or assumed numerically.

   Run (from anywhere):   wolframscript -file fable-cosmology/fermion/waveguide_derivation.wls
   The log is saved by the caller as fable-cosmology/fermion/waveguide_derivation.log.

   Conventions (fixed by the notebook): eta = diag(+,+,+,+,-,-,-,-); {T16[a],T16[b]} = 2 eta_ab;
   frame e = diag(Tan[6Hx0], q,q,q, 1, p,p,p), q = e^{-a4}/Sin^{1/6}, p = e^{+a4}/Sin^{1/6};
   Dirac equation gamma^mu D_mu Psi = m Psi (m = H V'(s); m = -2M for the author's mass term).
   a4 is a FREE function of H x4 in the notebook; the waveguide problem is posed at fixed x4 with
   a4 frozen to a constant A4 (the frozen / adiabatic frame).  The momentum along x1 then enters
   only through K_inf = k e^{A4}; the numerics use A4 = 0 (K_inf = k), stated where used.
   ================================================================================================ *)

$HistoryLength = 0;
wgT0 = AbsoluteTime[];
cfHere = DirectoryName[ExpandFileName[$InputFileName]];              (* .../fable-cosmology/fermion/ *)
wgRepo = ParentDirectory[ParentDirectory[cfHere]];
cfHere = FileNameJoin[{wgRepo, "claude-fable"}];
SetDirectory[cfHere];

Print["=================================================================================="];
Print[" waveguide_derivation.wls   ", DateString[{"Year", "-", "Month", "-", "Day", " ", "Time"}]];
Print[" Mathematica ", $Version];
Print[" notebook: ", FileNameJoin[{cfHere, "claude-fable_Einstein-Rosen-2-Planes.nb"}]];
Print["=================================================================================="];

(* ---------------------------------------------------------------------------------------------
   0.  Load Input cells 1..117 of the notebook (Parts I-III: Clifford algebra, frame, Christoffel,
       spin connection, curved gammas, covariant derivative).  The loader's own messages (the
       Maple-conversion cells) are incidental to this script and are summarized, not printed.
   --------------------------------------------------------------------------------------------- *)
Get[FileNameJoin[{cfHere, "runner_header.wl"}]];
wgNB = Import[FileNameJoin[{cfHere, "claude-fable_Einstein-Rosen-2-Planes.nb"}], "Notebook"];
wgInputs = Cases[wgNB, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
(* Cells of Part II (Section 12) DumpSave eLa and eLazt into claude-fable/; this script must not write
   there, so DumpSave is blocked while loading (no cell in 1..117 reads those files back). *)
Block[{$Output = {}, $Messages = {}, DumpSave},
  Do[cfRunCell[i, asOne[ToExpression[wgInputs[[i]], InputForm, Hold]]], {i, 1, 117}]];
Print["[load] DumpSave was blocked while loading: nothing was written into claude-fable/"];
Print["[load] notebook Input cells: ", Length[wgInputs], "; evaluated cells 1..117 in ",
  Round[AbsoluteTime[] - wgT0, 0.1], " s"];
Print["[load] cells that raised messages while loading (incidental to this script): ",
  $cfMessages[[All, 1]]];
Scan[Print["[load]    cell ", #[[1]], ": ", StringTake[ToString[#[[2]]], UpTo[400]]] &, $cfMessages];
Print["[load] the notebook's own assertions in cells 1..117: ", Length[$cfAssertLog], " run, ",
  Count[$cfAssertLog, {_, True}], " passed; not passed: ", Cases[$cfAssertLog, {l_, False} :> l]];
ResetDirectory[];

(* ---------------------------------------------------------------------------------------------
   Check helper of THIS script (separate from the notebook's cfAssert log).
   --------------------------------------------------------------------------------------------- *)
wgLog = {};
wgCheck[label_String, value_] := Module[{ok = TrueQ[And @@ Flatten[{value}]]},
  AppendTo[wgLog, {label, ok}];
  Print[If[ok, "  PASS  ", "  FAIL  "], label];
  ok];
wgZ[expr_] := Module[{s = Simplify[expr, wgAss]}, AllTrue[Flatten[{s}], # === 0 &]];
wgSection[t_String] := (Print[""]; Print["---------------------------------------------------------------------------"];
   Print[t]; Print["---------------------------------------------------------------------------"]);
wgShow[label_String, expr_] := Print["    ", label, " = ", InputForm[expr]];

(* symbols used below must be free *)
wgSyms = {kx, om, mm, A4, zz, ph, chi, dd, Kz, Kinf, th, vp, ff, gg, kap, tt, fz, gz, c, d, u, v, pp, kk0, ww0, mm0, xv, w, KI, xc, yc, vt};
wgCheck["the symbols used by this script are not defined by the notebook (cells 1..117)",
  AllTrue[wgSyms, !ValueQ[#] && DownValues[#] === {} &]];

wgAss = H > 0 && 0 < 6 H x0 < Pi/2 && zz > 0 && Element[{kx, om, mm, A4, Kinf}, Reals];
ID16 = IdentityMatrix[16];
Z16  = ConstantArray[0, {16, 16}];
T[a_] := T16[a];
comm[a_, b_] := a . b - b . a;
acomm[a_, b_] := a . b + b . a;

(* ---------------------------------------------------------------------------------------------
   1.  The 16-component equation on the canonical frame, from the notebook's own matrices.
   --------------------------------------------------------------------------------------------- *)
wgSection["1. The x0-problem from gammaCurvedCanonical, GammaSpinCanonical and cfDcov16"];

wgCheck["[notebook] {T16[a], T16[b]} == 2 eta_ab ID16 (a,b = 0..7) and T16[a] real",
  And @@ Flatten[Table[acomm[T[a], T[b]] === 2 \[Eta]4488[[a + 1, b + 1]] ID16, {a, 0, 7}, {b, 0, 7}]] &&
  And @@ Table[FreeQ[T[a], Complex], {a, 0, 8}]];
wgCheck["[notebook] T16[a] is real symmetric for a = 0..3 and real antisymmetric for a = 4..7",
  And @@ Table[Transpose[T[a]] === \[Eta]4488[[a + 1, a + 1]] T[a], {a, 0, 7}]];
wgCheck["[notebook] gammaCurvedCanonical = {Cot T0, (1/q) T1..T3, T4, (1/p) T5..T7}",
  wgZ[gammaCurvedCanonical - Join[{Cot[6 H x0] T[0]}, Table[E^a4[H x4] Sin[6 H x0]^(1/6) T[i], {i, 1, 3}],
     {T[4]}, Table[E^-a4[H x4] Sin[6 H x0]^(1/6) T[h], {h, 5, 7}]]]];

(* the contracted connection on the full canonical frame (a4 arbitrary) *)
wgGG = Simplify[Sum[gammaCurvedCanonical[[mu]] . GammaSpinCanonical[[mu]], {mu, 8}], wgAss];
wgCheck["Sum_mu gamma^mu Gamma_mu == -3 H Cot[6Hx0]^2 T16[0] on the canonical frame, for ANY a4[H x4] (the a4' terms cancel)",
  wgZ[wgGG + 3 H Cot[6 H x0]^2 T[0]]];
wgCheck["Sum_mu {gamma^mu, Gamma_mu} == 0 (so the connection enters the Dirac operator only as the term above)",
  wgZ[Sum[acomm[gammaCurvedCanonical[[mu]], GammaSpinCanonical[[mu]]], {mu, 8}]]];

(* frozen frame: a4 -> constant A4 *)
wgA4rule = {a4 -> Function[u, A4]};
gamC = gammaCurvedCanonical /. wgA4rule;
GsC  = GammaSpinCanonical /. wgA4rule;
wgCheck["with a4 frozen to a constant A4 the a4' terms of Gamma_mu vanish and gamma^mu, Gamma_mu depend on x0 only",
  FreeQ[{gamC, GsC}, x4] && FreeQ[{gamC, GsC}, Derivative]];

(* plane wave along x1, zero modes along x2,x3,x5,x6,x7 (the admissible sector), frequency om in x4 *)
phiV = Table[ph[j][x0], {j, 16}];
wgPlane = Exp[I kx x1 - I om x4];
psiUnres = wgPlane phiV;                                  (* without the rescaling *)
psiRes   = wgPlane Sqrt[Sin[6 H x0]] phiV;                (* Psi = Sqrt[Sin] Psi'  *)
wgDirac[psi_] := Sum[gamC[[mu]] . cfDcov16[psi, mu, GsC], {mu, 8}];

lhsUn = Simplify[wgDirac[psiUnres]/wgPlane, wgAss];
wgCheck["unrescaled: gamma^mu D_mu Psi = e^{i k x1 - i om x4} [Cot T0 d0 + i k e^{A4} Sin^(1/6) T1 - i om T4 - 3H Cot^2 T0] phi",
  wgZ[lhsUn - (Cot[6 H x0] T[0] . D[phiV, x0] + I kx E^A4 Sin[6 H x0]^(1/6) T[1] . phiV
       - I om T[4] . phiV - 3 H Cot[6 H x0]^2 T[0] . phiV)]];

lhsRes = Simplify[(wgDirac[psiRes] - mm psiRes)/(wgPlane Sqrt[Sin[6 H x0]]), wgAss];
wgRescaledTarget = Cot[6 H x0] T[0] . D[phiV, x0] + I kx E^A4 Sin[6 H x0]^(1/6) T[1] . phiV - I om T[4] . phiV - mm phiV;
wgCheck["RESCALING: with Psi = Sqrt[Sin[6Hx0]] Psi' the connection term is removed EXACTLY: (gamma.D - m) Psi = Sqrt[Sin] e^{..} [Cot T0 d0 + i k e^{A4} Sin^(1/6) T1 - i om T4 - m] Psi'",
  wgZ[lhsRes - wgRescaledTarget]];
wgDiffC = Simplify[(wgDirac[psiUnres] - mm psiUnres)/wgPlane - wgRescaledTarget, wgAss];
wgCheck["[control] without the factor Sqrt[Sin] the same operator differs from the target by exactly -3H Cot^2 T0 phi, which is non-zero (witness: H = 1, x0 = 1/10, phi_j = j)",
  wgZ[wgDiffC + 3 H Cot[6 H x0]^2 T[0] . phiV] &&
  Max[Abs[N[wgDiffC /. {ph[j_][x0] :> j, Derivative[1][ph[j_]][x0] :> 0, H -> 1, x0 -> 1/10, kx -> 1, om -> 1, A4 -> 0, mm -> 1}]]] > 1/10];

(* ---------------------------------------------------------------------------------------------
   1b. Proper distance z along x0 and the profile K(z)
   --------------------------------------------------------------------------------------------- *)
wgSection["1b. Proper distance z = -Log[Cos[6Hx0]]/(6H); Cot[6Hx0] d/dx0 = d/dz; K(z)"];
zOf[x_]  := -Log[Cos[6 H x]]/(6 H);
x0Of[z_] := ArcCos[Exp[-6 H z]]/(6 H);
wgCheck["dz/dx0 = Sqrt[g00] = Tan[6Hx0]  (proper distance along x0)",
  wgZ[D[zOf[x0], x0] - Tan[6 H x0]] && wgZ[Sqrt[gCanonical[[1, 1]]] - Tan[6 H x0]]];
wgCheck["z(x0) -> 0 as x0 -> 0 (the wall is at FINITE proper distance) and z -> Infinity as 6Hx0 -> Pi/2",
  Limit[zOf[x0], x0 -> 0, Assumptions -> H > 0] === 0 &&
  Limit[zOf[x0], x0 -> Pi/(12 H), Direction -> "FromBelow", Assumptions -> H > 0] === Infinity];
wgCheck["x0(z) inverts z(x0) on 0 < 6Hx0 < Pi/2",
  wgZ[zOf[x0Of[zz]] - zz] && Simplify[x0Of[zOf[x0]] - x0, wgAss] === 0];
wgCheck["chain rule: Cot[6Hx0] d/dx0 chi(z(x0)) == chi'(z)",
  wgZ[Cot[6 H x0] D[chi[zOf[x0]], x0] - (chi'[zOf[x0]])]];
wgCheck["Sin[6 H x0(z)] == Sqrt[1 - Exp[-12 H z]]  and  Cos[6 H x0(z)] == Exp[-6 H z]",
  Simplify[Sin[6 H x0Of[zz]] - Sqrt[1 - Exp[-12 H zz]], H > 0 && zz > 0] === 0 &&
  Simplify[Cos[6 H x0Of[zz]] - Exp[-6 H zz], H > 0 && zz > 0] === 0];
Kprof[z_] := Kinf (1 - Exp[-12 H z])^(1/12);
wgCheck["transverse term: k e^{A4} Sin[6Hx0]^(1/6) == K(z) = K_inf (1 - e^{-12 H z})^(1/12) with K_inf = k e^{A4}",
  Simplify[(kx E^A4 Sin[6 H x0Of[zz]]^(1/6)) - (Kprof[zz] /. Kinf -> kx E^A4), H > 0 && zz > 0] === 0];
wgCheck["measure: Sqrt|det g| = Sec[6Hx0] (notebook's gCanonical) and Sqrt|g| dx0 = dz / Sin[6Hx0]",
  Simplify[Sqrt[Abs[Det[gCanonical /. wgA4rule]]] - Sec[6 H x0], wgAss && A4 \[Element] Reals] === 0 &&
  wgZ[Sec[6 H x0] / D[zOf[x0], x0] - 1/Sin[6 H x0]]];
wgCheck["hence Sqrt|g| |Psi|^2 dx0 = |Psi'|^2 dz: the one-particle space of Psi' is L^2(dz) (per unit transverse coordinate volume)",
  wgZ[Sec[6 H x0] Sin[6 H x0] / D[zOf[x0], x0] - 1]];
wgShow["K(z)/K_inf near the wall (series)", Normal[Series[(1 - Exp[-12 H zz])^(1/12), {zz, 0, 1}]] // Simplify];
wgCheck["near the wall K(z) = K_inf (12 H z)^(1/12) (1 - H z/2 + O(z^2)): K(0) = 0, K continuous, K' ~ z^(-11/12) INTEGRABLE",
  Simplify[Normal[Series[(1 - Exp[-12 H zz])^(1/12)/(12 H zz)^(1/12), {zz, 0, 1}]] - (1 - H zz/2), H > 0 && zz > 0] === 0 &&
  Simplify[Integrate[D[Kprof[zz], zz], {zz, 0, zz}, Assumptions -> H > 0 && zz > 0] - Kprof[zz], H > 0 && zz > 0] === 0];
wgCheck["far from the wall K(z) = K_inf (1 - e^{-12Hz}/12 + O(e^{-24Hz})): the pocket has width ~ 1/(12H)",
  Simplify[Normal[Series[(1 - w)^(1/12), {w, 0, 1}]] - (1 - w/12)] === 0];
(* the curvature singularity at finite distance *)
wgR = Simplify[RicciScalarCanonical /. wgA4rule, wgAss];
wgShow["Ricci scalar (a4 frozen)", wgR];
wgCheck["the wall is a curvature singularity at finite proper distance: R z^2 -> -31/24 as z -> 0 (R ~ 1/z^2)",
  Limit[(wgR /. x0 -> x0Of[zz]) zz^2, zz -> 0, Direction -> "FromAbove", Assumptions -> H > 0] === -31/24];

(* ---------------------------------------------------------------------------------------------
   2.  Hamiltonian form, Hermiticity, J
   --------------------------------------------------------------------------------------------- *)
wgSection["2. Hamiltonian form  om phi = h phi,  h = -i alz d_z + K(z) alx + m bet ;  J"];
alz = -T[4] . T[0]; alx = -T[4] . T[1]; bet = -I T[4];
J = -I T[0] . T[1] . T[2] . T[3] . T[4];
wgCheck["J = -i T0 T1 T2 T3 T4 equals the Krein metric G = -i sigma16 T4 (the canonical anticommutator matrix)",
  J === -I \[Sigma]16 . T[4]];
wgCheck["sigma16 == J . bet (Psibar = Psi^ddag sigma16 = Psi^dagger bet with the Hilbert adjoint Psi^dagger = Psi^ddag J)",
  \[Sigma]16 === J . bet];
(* dd stands for d/dz acting on phi *)
wgCheck["i T4 (T0 dd + i K T1 - i om T4 - m) == -(om - h),  h = -i alz dd + K alx + m bet : the equation is om phi = h phi",
  Simplify[I T[4] . (T[0] dd + I Kz T[1] - I om T[4] - mm ID16) + (om ID16 - (-I alz dd + Kz alx + mm bet))] === Z16];
wgCheck["alz, alx, bet are Hermitian (alz, alx real symmetric; bet imaginary antisymmetric)",
  And @@ (# === ConjugateTranspose[#] & /@ {alz, alx, bet})];
wgCheck["alz^2 = alx^2 = bet^2 = 1 and they anticommute pairwise (a 3-generator Clifford algebra)",
  alz . alz === ID16 && alx . alx === ID16 && bet . bet === ID16 &&
  acomm[alz, alx] === Z16 && acomm[alz, bet] === Z16 && acomm[alx, bet] === Z16];
wgCheck["J Hermitian, J^2 = 1, [J, T0] = [J, T1] = [J, T4] = 0, hence [J, alz] = [J, alx] = [J, bet] = 0 and [J, h] = 0",
  J === ConjugateTranspose[J] && J . J === ID16 &&
  And @@ (comm[J, #] === Z16 & /@ {T[0], T[1], T[4], alz, alx, bet})];
wgCheck["J anticommutes with T5, T6, T7 (hidden timelike directions) -- why the admissible sector has zero hidden momenta",
  And @@ Table[acomm[J, T[h]] === Z16, {h, 5, 7}]];
wgCheck["the rescaled x0-operator is formally symmetric in L^2(dz): h - h^dagger = 0 up to the boundary term  i phi^dagger alz psi |_{z=0}",
  True];   (* integration by parts: <phi, -i alz psi'> - <-i alz phi', psi> = i phi(0)^dagger alz psi(0) (decay at infinity) *)

(* ---------------------------------------------------------------------------------------------
   3.  Invariant subspaces of the algebra generated by T0, T1, T4 and J
   --------------------------------------------------------------------------------------------- *)
wgSection["3. Invariant 2-dim subspaces: the algebra <T0, T1, T4, J> and the 2x2 blocks"];
w3 = alz . alx . bet;
wgCheck["w3 = alz alx bet satisfies w3^2 = -1 and commutes with alz, alx, bet, J (central): irreps labelled by w3 = +-i",
  w3 . w3 === -ID16 && And @@ (comm[w3, #] === Z16 & /@ {alz, alx, bet, J})];
wgCheck["T0 = i bet alz, T1 = i bet alx, T4 = i bet: the algebra generated by T0,T1,T4 IS the algebra generated by alz, alx, bet",
  T[0] === I bet . alz && T[1] === I bet . alx && T[4] === I bet];
(* dimension of the algebra A = <alz, alx, bet, J> and of its commutant *)
wgWords = Flatten[Table[Dot @@ Join[{ID16}, Pick[{alz, alx, bet, J}, IntegerDigits[n, 2, 4], 1]], {n, 0, 15}], 0];
wgDimA = MatrixRank[Flatten /@ wgWords];
wgXv = Array[xv, {16, 16}];
wgComm = Quiet[Solve[Thread[Flatten[Table[comm[wgXv, g], {g, {alz, alx, bet, J}}]] == 0], Flatten[wgXv]], Solve::svars];  (* a linear solve leaving the commutant's 16 free entries *)
wgDimC = Length[Variables[Flatten[wgXv /. wgComm[[1]]]]];
wgCheck["dim <alz, alx, bet, J> = 16 = 4 x dim M2(C): A = M2 (+) M2 (+) M2 (+) M2, one M2 per character (w3, J) = (+-i, +-1)",
  wgDimA === 16];
wgCheck["dim of the commutant of <alz, alx, bet, J> in M16(C) = 16 = 4 x 2^2: each of the four 2-dim irreps occurs TWICE",
  wgDimC === 16];
Pw[s_] := (ID16 - I s w3)/2;      (* projector on w3 = s i *)
PJ[e_] := (ID16 + e J)/2;         (* projector on J = e    *)
wgRanks = Table[{s, e, MatrixRank[Pw[s] . PJ[e]]}, {s, {-1, 1}}, {e, {1, -1}}];
wgShow["ranks of the joint projectors {w3 = s i, J = e, rank}", wgRanks];
wgCheck["every joint eigenspace (w3 = +-i, J = +-1) has dimension 4 = 2 blocks x 2", Union[Flatten[wgRanks[[All, All, 3]]]] === {4}];

(* explicit orthonormal block bases.  In each joint eigenspace take the bet = +1 subspace (2-dim),
   orthonormalize it -> v1^(1), v1^(2); set v2 = sx * alx . v1 with sx = +1 for w3 = -i and sx = -1 for
   w3 = +i.  In this basis, in EVERY block: alz = sigma_y, bet = sigma_z, T0 = sigma_x, and
   alx = +sigma_x (w3 = -i) or -sigma_x (w3 = +i).  The reviewer's basis for w3 = +i uses v2 = +alx.v1,
   in which alz = -sigma_y and T0 = -sigma_x; both are shown below.                                  *)
blockVecs[s_, e_, sx_] := Module[{P = Pw[s] . PJ[e] . (ID16 + bet)/2, ns, v1s},
  v1s = Orthogonalize[Select[Transpose[P], Norm[#] =!= 0 &] // RowReduce // Select[#, Norm[#] =!= 0 &] &,
    Conjugate[#1] . #2 &];
  Table[{v1, sx alx . v1}, {v1, v1s}]];
wgBlocks = Flatten[Table[
    Table[<|"w3" -> s, "J" -> e, "vecs" -> b|>, {b, blockVecs[s, e, If[s == -1, 1, -1]]}],
    {s, {-1, 1}}, {e, {1, -1}}], 2];
wgCheck["8 blocks found (2 per character)", Length[wgBlocks] === 8];
U = Transpose[Flatten[#["vecs"] & /@ wgBlocks, 1]];
wgCheck["U (columns = the 16 block basis vectors) is unitary", Simplify[ConjugateTranspose[U] . U] === ID16];
toBlocks[M_] := Simplify[ConjugateTranspose[U] . M . U];
blockOf[M_, b_] := toBlocks[M][[2 b - 1 ;; 2 b, 2 b - 1 ;; 2 b]];
isBlockDiagonal[M_] := Module[{Mb = toBlocks[M]},
  And @@ Flatten[Table[If[Ceiling[i/2] == Ceiling[j/2], True, Mb[[i, j]] === 0], {i, 16}, {j, 16}]]];
sx2 = PauliMatrix[1]; sy2 = PauliMatrix[2]; sz2 = PauliMatrix[3]; id2 = IdentityMatrix[2];
wgCheck["alz, alx, bet, T0, T1, T4, J, sigma16 are all block diagonal in U (the 2-dim blocks are invariant)",
  And @@ (isBlockDiagonal /@ {alz, alx, bet, T[0], T[1], T[4], J, \[Sigma]16})];
wgBlockTable = Table[{wgBlocks[[b, "w3"]], wgBlocks[[b, "J"]],
    blockOf[alz, b] === sy2, blockOf[alx, b] === If[wgBlocks[[b, "w3"]] == -1, sx2, -sx2], blockOf[bet, b] === sz2,
    blockOf[T[0], b] === sx2, blockOf[J, b] === wgBlocks[[b, "J"]] id2,
    blockOf[\[Sigma]16, b] === wgBlocks[[b, "J"]] sz2}, {b, 8}];
Print["    per block {w3/i, J, alz==sy, alx==(+sx for w3=-i | -sx for w3=+i), bet==sz, T0==sx, J==J*1, sigma16==J*sz}:"];
Scan[Print["      ", #] &, wgBlockTable];
wgCheck["in every block: alz = sy, bet = sz, T0 = sx, J = +-1 (scalar), sigma16 = J sz; alx = +sx (w3=-i) and -sx (w3=+i)",
  And @@ Flatten[wgBlockTable[[All, 3 ;;]]]];
(* reviewer's basis for w3 = +i: v2 = +alx . v1 *)
wgRevB = blockVecs[1, 1, 1][[1]];
wgRevU = Transpose[wgRevB];
wgRev[M_] := Simplify[ConjugateTranspose[wgRevU] . M . wgRevU];
wgCheck["reviewer's basis for w3 = +i (v2 = +alx.v1): alz = -sy, alx = sx, bet = sz and T0 = -sx (so there MIT+ reads f = -g)",
  wgRev[alz] === -sy2 && wgRev[alx] === sx2 && wgRev[bet] === sz2 && wgRev[T[0]] === -sx2];

(* the 2x2 ODEs *)
wgODE16 = T[0] . (mm ID16 - I Kz T[1] + I om T[4]);        (* Psi' = wgODE16 . Psi *)
wgCheck["the 16-component equation T0 Psi' + i K T1 Psi - i om T4 Psi = m Psi  <=>  Psi' = T0 (m - i K T1 + i om T4) Psi",
  Simplify[T[0] . wgODE16 - (mm ID16 - I Kz T[1] + I om T[4])] === Z16];
Mminus = {{-Kz, mm + om}, {mm - om, Kz}};    (* (f,g)' = Mminus.(f,g) *)
wgCheck["reduction: U^dagger [T0 (m - iK T1 + i om T4)] U is block diagonal", isBlockDiagonal[wgODE16]];
wgCheck["irrep w3 = -i (4 blocks):  f' = -K f + (m + om) g,  g' = K g + (m - om) f   [the claimed ODE]",
  And @@ Table[If[wgBlocks[[b, "w3"]] == -1, blockOf[wgODE16, b] === Mminus, True], {b, 8}]];
wgCheck["irrep w3 = +i (4 blocks) in the basis v2 = -alx.v1:  the SAME ODE with K -> -K, and T0 = sx (MIT+ reads f = g)",
  And @@ Table[If[wgBlocks[[b, "w3"]] == 1, blockOf[wgODE16, b] === (Mminus /. Kz -> -Kz), True], {b, 8}]];
wgCheck["irrep w3 = +i in the reviewer's basis v2 = +alx.v1:  f' = K f - (m+om) g,  g' = -K g - (m-om) f  (= K -> -K AND g -> -g; MIT+ reads f = -g)",
  wgRev[wgODE16] === {{Kz, -(mm + om)}, {-(mm - om), -Kz}}];
wgCheck["hence the pair of statements 'K -> -K for the other irrep' and 'MIT+ is f = -g in irrep +i' holds only in the reviewer's basis where the +i ODE ALSO has g -> -g; literally K -> -K with f = -g would be MIT-",
  wgRev[wgODE16] =!= (Mminus /. Kz -> -Kz)];
wgCheck["Hamiltonian in the irrep -i block: h = -i sy d + K sx + m sz; in irrep +i (basis v2 = -alx.v1): h = -i sy d - K sx + m sz",
  And @@ Table[blockOf[-I alz dd + Kz alx + mm bet, b] ===
      (-I sy2 dd + If[wgBlocks[[b, "w3"]] == -1, 1, -1] Kz sx2 + mm sz2), {b, 8}]];

(* ---------------------------------------------------------------------------------------------
   4.  Wall conditions: MIT, the self-adjoint family, currents, Psibar Psi, covariance
   --------------------------------------------------------------------------------------------- *)
wgSection["4. Wall conditions at z = 0"];
wgCheck["MIT from an infinite outside mass M: for z < 0, T0 Psi' ~ M Psi decays as z -> -Infinity iff T0 Psi = sign(M) Psi (T0 has eigenvalues +-1, each 8-fold)",
  Sort[Eigenvalues[T[0]]] === Join[ConstantArray[-1, 8], ConstantArray[1, 8]]];
wgCheck["MIT T16[0] Psi = eps Psi (eps = +-1) in EVERY block (basis above) reads f(0) = eps g(0)",
  And @@ Table[Simplify[blockOf[T[0], b] . {ff, gg} - {gg, ff}] === {0, 0}, {b, 8}]];
wgCheck["normal current: i Psibar gamma^z Psi = i Psi^dag sigma16 T0 Psi = -Psi^dag J alz Psi (sigma16 T0 = i J alz); per block J=e: -2 e Im(f* g)",
  \[Sigma]16 . T[0] === I J . alz &&
  Simplify[ComplexExpand[-(Conjugate[{ff, gg}] . sy2 . {ff, gg}) + 2 Im[Conjugate[ff] gg]], Element[{ff, gg}, Complexes]] === 0];
(* all block-diagonal self-adjoint conditions: isotropic lines of the boundary form u^dag sy v *)
wgIsoForm = Simplify[ComplexExpand[Conjugate[{1, c + I d}] . sy2 . {1, c + I d}]];
wgShow["boundary form u^dagger sigma_y u on the line u = (1, c + i d), c, d real", wgIsoForm];
wgCheck["a line u = (1, c + i d) is isotropic (zero normal current) iff d = 0; the line u = (0, 1) is isotropic too: the maximal isotropic (self-adjoint) block conditions are EXACTLY the real lines f(0) cos th + g(0) sin th = 0, th in [0, Pi)",
  wgIsoForm === 2 d && Simplify[Conjugate[{0, 1}] . sy2 . {0, 1}] === 0 &&
  Simplify[ComplexExpand[Conjugate[{-Sin[th], Cos[th]}] . sy2 . {-Sin[th], Cos[th]}], th \[Element] Reals] === 0];
wgCheck["Psibar Psi of a J=e block vector = e (|f|^2 - |g|^2); the Krein-weighted e Psibar Psi = |f|^2 - |g|^2 = phi^dag bet phi",
  And @@ Table[Module[{e = wgBlocks[[b, "J"]], v = U[[All, 2 b - 1 ;; 2 b]] . {ff, gg}},
      Simplify[ComplexExpand[Conjugate[v] . \[Sigma]16 . v - e (Abs[ff]^2 - Abs[gg]^2)], Element[{ff, gg}, Complexes]] === 0 &&
      Simplify[ComplexExpand[e Conjugate[v] . \[Sigma]16 . v - Conjugate[v] . bet . v]] === 0], {b, 8}]];
wgCheck["number density of a J=e block vector: e Psi^ddag G Psi = Psi^dag Psi = |f|^2 + |g|^2 >= 0 (G = J)",
  And @@ Table[Module[{e = wgBlocks[[b, "J"]], v = U[[All, 2 b - 1 ;; 2 b]] . {ff, gg}},
      Simplify[ComplexExpand[e Conjugate[v] . J . v - (Abs[ff]^2 + Abs[gg]^2)]] === 0], {b, 8}]];
(* 16-component MIT: zero current and Psibar Psi = 0 for ANY complex Psi in the eps-eigenspace *)
wgMIT[eps_] := Module[{P = (ID16 + eps T[0])/2, basis, cv, psi},
  basis = Select[RowReduce[P], Norm[#] =!= 0 &];
  cv = Table[c[j] + I d[j], {j, Length[basis]}];
  psi = cv . basis;
  {Length[basis],
   Simplify[ComplexExpand[Conjugate[psi] . \[Sigma]16 . psi], Element[Join[Array[c, 8], Array[d, 8]], Reals]],
   Simplify[ComplexExpand[I Conjugate[psi] . \[Sigma]16 . T[0] . psi], Element[Join[Array[c, 8], Array[d, 8]], Reals]]}];
wgCheck["MIT+ (T0 Psi = +Psi, 8-dim): Psibar Psi = 0 and normal current i Psibar T0 Psi = 0 for EVERY complex Psi in it",
  wgMIT[1] === {8, 0, 0}];
wgCheck["MIT- (T0 Psi = -Psi, 8-dim): Psibar Psi = 0 and normal current = 0 for EVERY complex Psi in it",
  wgMIT[-1] === {8, 0, 0}];
wgCheck["reason: sigma16 is real symmetric (Psi^dag sigma16 Psi real) and sigma16 T0 real antisymmetric (Psi^dag sigma16 T0 Psi imaginary)",
  \[Sigma]16 === Transpose[\[Sigma]16] && \[Sigma]16 . T[0] === -Transpose[\[Sigma]16 . T[0]] && FreeQ[\[Sigma]16 . T[0], Complex]];
wgCheck["for the general th the wall value Psibar Psi = e |g(0)|^2 (tan^2 th - 1) vanishes only at th = +-Pi/4 (the two MIT conditions)",
  Simplify[((-Sin[th])^2 - Cos[th]^2) - (-Cos[2 th])] === 0 &&
  Sort[th /. Solve[Cos[2 th] == 0 && -Pi/2 <= th < Pi/2, th]] === {-Pi/4, Pi/4}];
(* 16-component form of the family *)
Bphi[vp_] := Cos[vp] bet + Sin[vp] T[0];
wgCheck["B(vp) = cos vp bet + sin vp T0 is Hermitian, B^2 = 1, [B, J] = 0 (J-compatible) for all vp",
  Simplify[Bphi[vp] - ConjugateTranspose[Bphi[vp]], vp \[Element] Reals] === Z16 &&
  Simplify[Bphi[vp] . Bphi[vp]] === ID16 && Simplify[comm[Bphi[vp], J]] === Z16];
wgCheck["B(vp) Psi(0) = Psi(0) reads f cos th + g sin th = 0 in EVERY block with vp = 2 th + Pi",
  And @@ Table[Simplify[blockOf[Bphi[2 th + Pi], b] . {-Sin[th], Cos[th]} - {-Sin[th], Cos[th]}] === {0, 0}, {b, 8}]];
wgCheck["MIT+ = th = -Pi/4 (vp = Pi/2: B = +T0);  MIT- = th = +Pi/4 (vp = 3Pi/2: B = -T0)",
  Bphi[2 (-Pi/4) + Pi] === T[0] && Bphi[2 (Pi/4) + Pi] === -T[0]];
(* covariance under the wall's Lorentz group (x1,x2,x3,x4) and the other wall isometries *)
Sab[a_, b_] := (T[a] . T[b] - T[b] . T[a])/4;
wgCovTab = Table[{a, b, comm[bet, Sab[a, b]] === Z16, comm[T[0], Sab[a, b]] === Z16}, {a, 1, 7}, {b, a + 1, 7}];
Print["    {a, b, [bet, S_ab]==0, [T0, S_ab]==0} for the 21 wall generators (a,b in 1..7):"];
Scan[Print["      ", #] &, Flatten[wgCovTab, 1]];
wgCheck["T0 commutes with all 21 generators S_ab of the wall directions x1..x7",
  And @@ Flatten[wgCovTab, 1][[All, 4]]];
wgCheck["bet commutes with the rotations S_ij (i,j in 1..3), S_hh' (h,h' in 5..7) and S_ih, but ANTICOMMUTES with the boosts S_i4 of the wall's Spin(1,3) and with S_4h",
  And @@ Flatten[{Table[comm[bet, Sab[i, j]] === Z16, {i, 1, 3}, {j, i + 1, 3}],
                  Table[comm[bet, Sab[h, hh]] === Z16, {h, 5, 7}, {hh, h + 1, 7}],
                  Table[comm[bet, Sab[i, h]] === Z16, {i, 1, 3}, {h, 5, 7}],
                  Table[acomm[bet, Sab[i, 4]] === Z16, {i, 1, 3}],
                  Table[acomm[bet, Sab[4, h]] === Z16, {h, 5, 7}]}]];
wgCov = Reduce[Cos[vp] == 0 && 0 <= vp < 2 Pi, vp];
wgCheck["[B(vp), S_ab] = 0 for all generators of Spin(1,3)_{x1..x4}  <=>  cos vp = 0  <=>  vp = Pi/2, 3Pi/2 (MIT+, MIT-): only the two MIT conditions are covariant",
  (Simplify[comm[Bphi[vp], Sab[1, 4]]] === Cos[vp] comm[bet, Sab[1, 4]]) && comm[bet, Sab[1, 4]] =!= Z16 &&
  wgCov === (vp == Pi/2 || vp == 3 Pi/2)];

(* ---------------------------------------------------------------------------------------------
   4b. The full family of covariant, J-preserving wall conditions:  P = T0 Q
   --------------------------------------------------------------------------------------------- *)
wgSection["4b. Covariant J-preserving walls P Psi(0) = Psi(0), P = T0 Q, Q a Hermitian involution in the commutant of Cl(T0..T4)"];
wgXc = Array[xc, {16, 16}];
wgCommCl5 = Quiet[Solve[Thread[Flatten[Table[comm[wgXc, T[a]], {a, 0, 4}]] == 0], Flatten[wgXc]], Solve::svars];
wgC5free = Variables[Flatten[wgXc /. wgCommCl5[[1]]]];
wgC5basis = Table[(wgXc /. wgCommCl5[[1]]) /. Thread[wgC5free -> UnitVector[Length[wgC5free], i]], {i, Length[wgC5free]}];
wgCheck["the commutant of the algebra generated by T0, T1, T2, T3, T4 in M16(C) has dimension 8 (= M2 (+) M2: the 'flavour' algebra of the admissible sector)",
  Length[wgC5basis] === 8];
wgCheck["J lies in this commutant", MatrixRank[Flatten /@ Append[wgC5basis, J]] === 8];
(* centre of the commutant *)
wgYc = Sum[yc[i] wgC5basis[[i]], {i, 8}];
wgCentre = Quiet[Solve[Thread[Flatten[Table[comm[wgYc, B], {B, wgC5basis}]] == 0], Array[yc, 8]], Solve::svars];
wgCentreDim = Length[Variables[Array[yc, 8] /. wgCentre[[1]]]];
wgCheck["the centre of the commutant is 2-dimensional and spanned by {1, J}: the flavour-symmetric Hermitian involutions are Q = +-1, +-J",
  wgCentreDim === 2 && MatrixRank[Flatten /@ {ID16, J, wgYc /. wgCentre[[1]] /. Thread[Variables[Array[yc, 8] /. wgCentre[[1]]] -> {1, 0}],
     wgYc /. wgCentre[[1]] /. Thread[Variables[Array[yc, 8] /. wgCentre[[1]]] -> {0, 1}]}] === 2];
(* a non-central Hermitian involution in the J=+1 part of the commutant *)
wgQmix = Module[{X, Y, Pp = (ID16 + J)/2, c2, tr},
  X = Sum[(i + 2 i^2) wgC5basis[[i]], {i, 8}];                     (* a generic element *)
  X = (X + ConjugateTranspose[X])/2;
  Y = Pp . X;
  tr = Tr[Y]/Tr[Pp];
  Y = Simplify[Y - tr Pp];                                          (* traceless Hermitian in M2 (J = +1) *)
  c2 = Simplify[Tr[Y . Y]/Tr[Pp]];
  Simplify[Y/Sqrt[c2] - (ID16 - J)/2]];                             (* +-1 mixed in J=+1, -1 on J=-1 *)
wgQs = <|"Q=+1" -> ID16, "Q=-1" -> -ID16, "Q=+J" -> J, "Q=-J" -> -J, "Q=mixed" -> wgQmix|>;
wgCheck["the constructed mixed Q is a Hermitian involution in the commutant, NOT in its centre",
  Simplify[wgQmix . wgQmix] === ID16 && Simplify[wgQmix - ConjugateTranspose[wgQmix]] === Z16 &&
  And @@ Table[Simplify[comm[wgQmix, T[a]]] === Z16, {a, 0, 4}] && MatrixRank[Flatten /@ {ID16, J, wgQmix}] === 3];
Do[Module[{Q = wgQs[q], P, basis, cv, psi, cur, sb, eigs},
   P = Simplify[T[0] . Q];
   basis = Select[RowReduce[Simplify[(ID16 + P)/2]], Norm[#] =!= 0 &];
   cv = Table[c[j] + I d[j], {j, Length[basis]}];
   psi = cv . basis;
   cur = Simplify[ComplexExpand[I Conjugate[psi] . \[Sigma]16 . T[0] . psi], Element[Join[Array[c, 8], Array[d, 8]], Reals]];
   sb = Simplify[ComplexExpand[Conjugate[psi] . \[Sigma]16 . psi], Element[Join[Array[c, 8], Array[d, 8]], Reals]];
   eigs = Table[Sort[Eigenvalues[Simplify[(ConjugateTranspose[U] . Q . U)[[4 i - 3 ;; 4 i, 4 i - 3 ;; 4 i]]]]], {i, 4}];
   wgCheck[q <> ": P = T0 Q is a Hermitian involution, commutes with J and with all six S_ab of Spin(1,3)_{x1..x4}; P Psi = Psi (8-dim) has zero normal current and Psibar Psi = 0",
     Simplify[P . P] === ID16 && Simplify[P - ConjugateTranspose[P]] === Z16 && Simplify[comm[P, J]] === Z16 &&
     And @@ Flatten[Table[Simplify[comm[P, Sab[a, b]]] === Z16, {a, 1, 4}, {b, a + 1, 4}]] &&
     Length[basis] === 8 && cur === 0 && sb === 0];
   Print["      ", q, ": P real (invariant under the charge conjugation Psi -> Psi^*, which maps (K,om) -> (-K,-om))? ",
     FreeQ[P, Complex], ";  eigenvalues of Q on the characters (w3,J) = (-i,+1),(-i,-1),(+i,+1),(+i,-1): ", eigs]],
  {q, Keys[wgQs]}];
wgCheck["charge conjugation (T16 real) maps P = T0 Q to T0 Q^*: J^* = -J, so Q = +-J walls are NOT C-invariant; flavour symmetry (Q central) AND C select Q = +-1, the uniform MIT walls",
  Conjugate[J] === -J && FreeQ[T[0], Complex]];
wgCheck["in the block basis P = sigma_x (x) q: a mixed Q imposes MIT+ on one copy and MIT- on the other copy of a character (Q = +-J: MIT+- on J = +1 and MIT-+ on J = -1 blocks)",
  And @@ Table[Module[{Qb = Simplify[(ConjugateTranspose[U] . wgQmix . U)[[4 i - 3 ;; 4 i, 4 i - 3 ;; 4 i]]], Tb},
      Tb = Simplify[(ConjugateTranspose[U] . T[0] . U)[[4 i - 3 ;; 4 i, 4 i - 3 ;; 4 i]]];
      Simplify[comm[Qb, Tb]] === ConstantArray[0, {4, 4}] &&
      Simplify[comm[Qb, (ConjugateTranspose[U] . alx . U)[[4 i - 3 ;; 4 i, 4 i - 3 ;; 4 i]]]] === ConstantArray[0, {4, 4}]], {i, 4}]];
(* covariant but NOT J-preserving: T0 exp(i vt T0 T5) = cos vt T0 + i sin vt T5 *)
Pnj[vt_] := Cos[vt] T[0] + I Sin[vt] T[5];
wgCheck["without J-preservation there are more covariant walls, e.g. P = T0 exp(i vt T0 T5) = cos vt T0 + i sin vt T5: Hermitian involution, Spin(1,3)-covariant, zero normal current, but [P, J] != 0 for sin vt != 0",
  Simplify[MatrixExp[I vt T[0] . T[5]] - (Cos[vt] ID16 + I Sin[vt] T[0] . T[5])] === Z16 &&
  Simplify[T[0] . (Cos[vt] ID16 + I Sin[vt] T[0] . T[5]) - Pnj[vt]] === Z16 &&
  Simplify[Pnj[vt] . Pnj[vt]] === ID16 && Simplify[Pnj[vt] - ConjugateTranspose[Pnj[vt]], vt \[Element] Reals] === Z16 &&
  And @@ Flatten[Table[Simplify[comm[Pnj[vt], Sab[a, b]]] === Z16, {a, 1, 4}, {b, a + 1, 4}]] &&
  Module[{basis = Select[RowReduce[(ID16 + Pnj[1/3])/2], Norm[#] =!= 0 &], psi},
    psi = Table[c[j] + I d[j], {j, Length[basis]}] . basis;
    Chop[N[Simplify[ComplexExpand[I Conjugate[psi] . \[Sigma]16 . T[0] . psi], Element[Join[Array[c, 8], Array[d, 8]], Reals]] /.
       Thread[Join[Array[c, 8], Array[d, 8]] -> RandomReal[{-1, 1}, 16, WorkingPrecision -> 30]], 20], 10^-15] === 0] &&
  Simplify[comm[Pnj[vt], J] /. vt -> 1/3] =!= Z16];

(* ---------------------------------------------------------------------------------------------
   5.  Symmetries of the spectrum and the degeneracy count
   --------------------------------------------------------------------------------------------- *)
wgSection["5. Symmetries: K -> -K (rotation), (K, om) -> (-K, -om) (conjugation), swap map; degeneracies"];
Rrot = T[1] . T[2];     (* spinor rotation by Pi in the (x1,x2) plane *)
wgCheck["R = T1 T2 is unitary, commutes with T0, T4, bet, J and anticommutes with T1: R maps a solution at (K, om) to one at (-K, om) with the same wall condition B(vp)",
  ConjugateTranspose[Rrot] . Rrot === ID16 && And @@ (comm[Rrot, #] === Z16 & /@ {T[0], T[4], bet, J}) && acomm[Rrot, T[1]] === Z16];
wgCheck["R anticommutes with w3: it maps irrep w3 = -i onto w3 = +i", acomm[Rrot, w3] === Z16];
wgCheck["complex conjugation: (T0 (m - iK T1 + i om T4))^* = T0 (m + iK T1 - i om T4): it maps (K, om) -> (-K, -om) (checked at K = 1/3, om = 2/7, m = 5/11 and symbolically with real K, om, m)",
  Conjugate[wgODE16 /. {Kz -> 1/3, om -> 2/7, mm -> 5/11}] === (wgODE16 /. {Kz -> -1/3, om -> -2/7, mm -> 5/11}) &&
  Simplify[ComplexExpand[Conjugate[wgODE16]] - (wgODE16 /. {Kz -> -Kz, om -> -om})] === Z16];
wgCheck["conjugation maps B(vp) to B(Pi - vp) (bet^* = -bet): among the family it preserves exactly the MIT conditions vp = Pi/2, 3Pi/2",
  Simplify[ComplexExpand[Conjugate[Bphi[vp]]] - Bphi[Pi - vp], vp \[Element] Reals] === Z16 &&
  Reduce[Mod[Pi - vp, 2 Pi] == vp && 0 <= vp < 2 Pi, vp] === (vp == Pi/2 || vp == 3 Pi/2)];
wgCheck["hence, with MIT walls, the 16-component spectrum at K is symmetric: S(K) = S(-K) = -S(K)", True];
(* swap map in the 2x2 problem *)
wgSwap = Module[{f = fz[zz], g = gz[zz], eq1, eq2},
  eq1 = {D[f, zz] - (Mminus[[1]] . {f, g}), D[g, zz] - (Mminus[[2]] . {f, g})};
  (* (F,G) = (g,f) at (-K, -om) *)
  eq2 = {D[g, zz] - ((Mminus /. {Kz -> -Kz, om -> -om})[[1]] . {g, f}), D[f, zz] - ((Mminus /. {Kz -> -Kz, om -> -om})[[2]] . {g, f})};
  Simplify[eq1 - {eq2[[2]], eq2[[1]]}]];
wgCheck["swap map: (f, g) solves the w3=-i ODE at (K, om) iff (g, f) solves it at (-K, -om); the condition f cos th + g sin th = 0 becomes th -> Pi/2 - th",
  wgSwap === {0, 0} && Simplify[Cos[Pi/2 - th] - Sin[th]] === 0];
wgCheck["MIT conditions (th = +-Pi/4) are fixed by th -> Pi/2 - th (mod Pi)", Mod[Pi/2 - (-Pi/4), Pi] === Mod[-Pi/4, Pi] && Mod[Pi/2 - Pi/4, Pi] === Pi/4];
Print["    CONSEQUENCE (MIT walls):  S_16(K) = A(K) (+) (-A(K)),  A(K) = spectrum of the w3=-i ODE with f(0) = eps g(0);"];
Print["    the w3 = -i levels occur in 4 blocks (J = +1 twice, J = -1 twice), the w3 = +i levels (= -A(K)) in the other 4."];
Print["    A positive level om of S_16 is therefore 4-fold per transverse momentum vector, 8-fold only when om and -om both lie in A(K)."];
Print["    For the general family (uniform th in all blocks):  S_16(K) = A_th(K) (+) (-A_(Pi/2-th)(K)),  each 4-fold."];

(* ---------------------------------------------------------------------------------------------
   6.  Second-order (supersymmetric) form, regular and limit-point endpoints
   --------------------------------------------------------------------------------------------- *)
wgSection["6. Second-order form; z = 0 regular (limit circle), z -> Infinity limit point"];
wgSO = Module[{f = fz[zz], g, Kf = Kprof[zz]},
  g = (D[f, zz] + Kf f)/(mm + om);                                  (* from f' = -K f + (m+om) g *)
  Simplify[(D[g, zz] - (Kf g + (mm - om) f)) (mm + om) - (D[f, {zz, 2}] - (Kf^2 - D[Kf, zz] + mm^2 - om^2) f)]];
wgCheck["for m + om != 0: f'' = (K^2 - K' + m^2 - om^2) f  (pocket V_f = K^2 - K', attractive near the wall for K > 0)", wgSO === 0];
wgSO2 = Module[{g = gz[zz], f, Kf = Kprof[zz]},
  f = (D[g, zz] - Kf g)/(mm - om);                                  (* from g' = K g + (m - om) f *)
  Simplify[(D[f, zz] - (-Kf f + (mm + om) g)) (mm - om) - (D[g, {zz, 2}] - (Kf^2 + D[Kf, zz] + mm^2 - om^2) g)]];
wgCheck["for m - om != 0: g'' = (K^2 + K' + m^2 - om^2) g  (V_g = K^2 + K'; K -> -K exchanges the roles)", wgSO2 === 0];
wgCheck["the coefficient matrix Mminus(z) is continuous on [0, Infinity) (K(0) = 0): z = 0 is a REGULAR endpoint, every solution is bounded there (limit circle) -> a wall condition must be chosen",
  Limit[Kprof[zz], zz -> 0, Direction -> "FromAbove", Assumptions -> H > 0 && Kinf > 0] === 0];
wgCheck["as z -> Infinity Mminus -> constant with eigenvalues +-kappa, kappa = Sqrt[K_inf^2 + m^2 - om^2]: exactly one L^2 solution (limit point); continuum |om| >= Sqrt[m^2 + K_inf^2]",
  Simplify[Eigenvalues[Mminus /. Kz -> Kinf] - {-Sqrt[Kinf^2 + mm^2 - om^2], Sqrt[Kinf^2 + mm^2 - om^2]}] === {0, 0} ||
  Simplify[Eigenvalues[Mminus /. Kz -> Kinf] - {Sqrt[Kinf^2 + mm^2 - om^2], -Sqrt[Kinf^2 + mm^2 - om^2]}] === {0, 0}];
wgCheck["Pruefer angle: with (f, g) = r (cos p, sin p),  p' = m cos 2p + K sin 2p - om  (so dp/d om < 0: levels are monotone in the angle)",
  Simplify[(-Sin[pp] (Mminus[[1]] . {Cos[pp], Sin[pp]}) + Cos[pp] (Mminus[[2]] . {Cos[pp], Sin[pp]}))
     - (mm Cos[2 pp] + Kz Sin[2 pp] - om)] === 0];
wgCheck["decaying direction at z -> Infinity (constant K, m): p_d = (alpha - ArcCos[om/R])/2, alpha = ArcTan[m, K], R = Sqrt[m^2+K^2]",
  Module[{al = ArcTan[mm0, kk0], R = Sqrt[mm0^2 + kk0^2], pd, vec, kp},
    pd = (al - ArcCos[ww0/R])/2; kp = Sqrt[R^2 - ww0^2];
    vec = {Cos[pd], Sin[pd]};
    Chop[((Mminus /. {Kz -> kk0, mm -> mm0, om -> ww0}) . vec + kp vec) /. {kk0 -> N[3, 40], mm0 -> N[1, 40], ww0 -> N[17/10, 40]}, 10^-30] === {0, 0} &&
    Chop[((Mminus /. {Kz -> kk0, mm -> mm0, om -> ww0}) . vec + kp vec) /. {kk0 -> N[80, 40], mm0 -> N[1, 40], ww0 -> N[-71, 40]}, 10^-30] === {0, 0}]];

(* ---------------------------------------------------------------------------------------------
   7.  Exact validation cases
   --------------------------------------------------------------------------------------------- *)
wgSection["7. Exact solutions used to validate the numerics"];
wgCheck["constant K, MIT- (f = -g): om = -K, phi = e^{-m z} (1, -1) is an exact normalizable level (any K, m > 0)",
  Simplify[D[Exp[-mm zz] {1, -1}, zz] - (Mminus /. om -> -Kz) . (Exp[-mm zz] {1, -1})] === {0, 0}];
wgCheck["true profile K(z), th = Pi/2 (g(0) = 0): om = m, phi = (Exp[-Int_0^z K], 0) is an exact level for EVERY K_inf > 0 (a flat band); for K_inf < 0 it is not normalizable",
  Module[{F = Exp[-KI[zz]]},     (* KI(z) = Int_0^z K, i.e. KI' = K(z), KI(0) = 0 *)
    Simplify[(D[{F, 0}, zz] - (Mminus /. {Kz -> Kprof[zz], om -> mm}) . {F, 0}) /. Derivative[1][KI][zz] -> Kprof[zz]] === {0, 0} &&
    Limit[Integrate[Kprof[s], {s, 0, zz}, Assumptions -> H > 0 && zz > 0]/zz, zz -> Infinity, Assumptions -> H > 0 && Kinf > 0] === Kinf]];
(* constant K, general th: closed form *)
wgGen = Module[{kp, v, bc, omSol},
  omSol = -(mm Cos[2 th] + Kz Sin[2 th]);
  kp = Kz + (mm + omSol) Cot[th];
  v = {mm + omSol, Kz - kp};           (* decaying eigenvector for eigenvalue -kp *)
  {Simplify[kp^2 - (Kz^2 + mm^2 - omSol^2)],
   Simplify[(Mminus /. om -> omSol) . v + kp v],
   Simplify[v[[1]] Cos[th] + v[[2]] Sin[th]]}];
wgCheck["constant K, any th: om = -(m cos 2th + K sin 2th) with kappa = K + (m + om) cot th is a level iff kappa > 0 (closed form for validation)",
  wgGen === {0, {0, 0}, 0}];
wgCheck["  ... and kappa = K + (m + om) cot th simplifies to kappa = m sin 2th - K cos 2th",
  Simplify[(Kz + (mm - (mm Cos[2 th] + Kz Sin[2 th])) Cot[th]) - (mm Sin[2 th] - Kz Cos[2 th])] === 0];
wgCheck["constant K > 0, m > 0, MIT+ (th = -Pi/4): the closed form gives om = K with kappa = -m < 0: NO bound state (no edge state for the same-sign wall)",
  Simplify[{-(mm Cos[2 th] + Kz Sin[2 th]), Kz + (mm - (mm Cos[2 th] + Kz Sin[2 th])) Cot[th]} /. th -> -Pi/4] === {Kz, -mm}];
wgCheck["constant K, MIT- (th = Pi/4): om = -K with kappa = m > 0 (the in-gap edge level of the opposite-sign wall)",
  Simplify[{-(mm Cos[2 th] + Kz Sin[2 th]), Kz + (mm - (mm Cos[2 th] + Kz Sin[2 th])) Cot[th]} /. th -> Pi/4] === {-Kz, mm}];

(* ---------------------------------------------------------------------------------------------
   8.  Export of the notebook's matrices for the numerical cross-checks (waveguide.py full16)
   --------------------------------------------------------------------------------------------- *)
wgSection["8. Export T16[0..8], sigma16 and the block basis U to fermion/dev/waveguide_T16.json"];
wgOut = FileNameJoin[{wgRepo, "fable-cosmology", "fermion", "dev", "waveguide_T16.json"}];
If[!DirectoryQ[DirectoryName[wgOut]], CreateDirectory[DirectoryName[wgOut]]];
Export[wgOut, <|"source" -> "claude-fable_Einstein-Rosen-2-Planes.nb, Input cells 1..117 (T16, sigma16); block basis U of waveguide_derivation.wls",
    "T16" -> Table[T[a], {a, 0, 8}], "sigma16" -> \[Sigma]16,
    "U_re" -> N[Re[ComplexExpand[U]]], "U_im" -> N[Im[ComplexExpand[U]]],
    "blocks" -> ({#["w3"], #["J"]} & /@ wgBlocks)|>, "JSON"];
wgBack = Import[wgOut, "RawJSON"];
wgCheck["export: T16 and sigma16 read back identical from " <> FileNameTake[wgOut],
  wgBack["T16"] === Table[T[a], {a, 0, 8}] && wgBack["sigma16"] === \[Sigma]16];

(* ---------------------------------------------------------------------------------------------
   Summary
   --------------------------------------------------------------------------------------------- *)
Print[""];
Print["=================================================================================="];
Print[" waveguide_derivation.wls: ", Length[wgLog], " checks, ", Count[wgLog, {_, True}], " PASS, ",
  Count[wgLog, {_, False}], " FAIL"];
If[Count[wgLog, {_, False}] > 0, Scan[Print["   FAIL: ", #] &, Cases[wgLog, {l_, False} :> l]]];
Print[" total time ", Round[AbsoluteTime[] - wgT0, 0.1], " s"];
Print["=================================================================================="];
