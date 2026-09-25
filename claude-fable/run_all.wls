(* runner_header.wl -- harness used by run_all.wls to evaluate every notebook Input cell
   in order, in one kernel, reporting timing and every message raised. *)

$cfCellLog = {};
$cfMessages = {};

cfRunCell[n_Integer, held_Hold] := Module[{t, r, msgs},
  t = 0; r = Null;
  msgs = Block[{$MessageList = {}},
    {t, r} = AbsoluteTiming[ReleaseHold[held]];
    $MessageList];
  msgs = DeleteDuplicates[ToString[#, InputForm] & /@ msgs];
  AppendTo[$cfCellLog, <|"cell" -> n, "seconds" -> t, "messages" -> msgs|>];
  If[msgs =!= {}, AppendTo[$cfMessages, {n, msgs}]];
  Print["CELL ", n, "  t=", ToString[NumberForm[N[t], {8, 3}, ExponentFunction -> (Null &)]], " s",
    If[msgs === {}, "", "   MESSAGES: " <> ToString[msgs]]];
  r];

cfRunSummary[] := Module[{tot, slow},
  tot = Total[#["seconds"] & /@ $cfCellLog];
  slow = Reverse[SortBy[$cfCellLog, #["seconds"] &]][[1 ;; Min[12, Length[$cfCellLog]]]];
  Print["==================== RUN SUMMARY ===================="];
  Print["cells evaluated : ", Length[$cfCellLog]];
  Print["total seconds   : ", ToString[NumberForm[N[tot], {10, 3}, ExponentFunction -> (Null &)]]];
  Print["cells w/ msgs   : ", Length[$cfMessages]];
  If[$cfMessages =!= {},
    Print["---- messages ----"];
    Scan[Print["  cell ", #[[1]], ": ", #[[2]]] &, $cfMessages]];
  Print["---- slowest cells ----"];
  Scan[Print["  cell ", #["cell"], "  ", ToString[NumberForm[N[#["seconds"]], {8, 3}, ExponentFunction -> (Null &)]], " s"] &, slow];
  Print["==================== ASSERTIONS ===================="];
  Module[{n = Length[$cfAssertLog], bad = Cases[$cfAssertLog, {l_, False} :> l]},
    Print["assertions run  : ", n];
    Print["passed          : ", n - Length[bad]];
    Print["FAILED          : ", Length[bad]];
    Scan[Print["  FAIL: ", #] &, bad]];
  Print["===================================================="];
  ];


(* ---------- Input cell 1 ---------- *)
cfRunCell[1, Hold[
(* --- provenance banner, as in the original notebook ------------------------------------- *)
Print["CopyRight (C) 2022, Patrick L. Nash, under the General Public License."];
Print["Please cite this work, and this web page, if you use it."];
Print["Refactored for claude-fable_Einstein-Rosen-2-Planes.nb; Wolfram Language ", $Version];
]];

(* ---------- Input cell 2 ---------- *)
cfRunCell[2, Hold[
(* --- session options: identical to the original ------------------------------------------ *)
SetOptions[Simplify, TimeConstraint -> 1];
SetOptions[FullSimplify, TimeConstraint -> 3];
{Off[General::spell], Off[General::spell1]};
Options[Simplify]
Options[FullSimplify]
]];

(* ---------- Input cell 3 ---------- *)
cfRunCell[3, Hold[
(* --- the one global dimension constant --------------------------------------------------- *)
ClearAll[DIM8];
DIM8 = 8;
(* M (mass), K and H (the Hubble-like constant) are the model's three scalar constants; the *)
(* original notebook protects them here so that no later cell can accidentally assign them. *)
Protect[DIM8, M, K, H];
{DIM8, Attributes[M], Attributes[K], Attributes[H]}
]];

(* ---------- Input cell 4 ---------- *)
cfRunCell[4, Hold[
ClearAll[cfTimed];
SetAttributes[cfTimed, HoldRest];
cfTimed[label_String, expr_] := Module[{t, r},
  {t, r} = AbsoluteTiming[expr];
  Print["  [", ToString[NumberForm[N[t], {6, 3}, ExponentFunction -> (Null &)]], " s]  ", label];
  r];
]];

(* ---------- Input cell 5 ---------- *)
cfRunCell[5, Hold[
ClearAll[cfAssert, $cfAssertLog];
$cfAssertLog = {};
cfAssert[label_String, value_] := Module[{flat, ok},
  flat = Union[Flatten[{value}]];
  ok = (flat === {True});
  AppendTo[$cfAssertLog, {label, ok}];
  Print[If[ok, "  PASS  ", "  FAIL  "], label,
    If[ok, "", "   -> distinct values: " <> ToString[Short[flat, 3], InputForm]]];
  ok];
]];

(* ---------- Input cell 6 ---------- *)
cfRunCell[6, Hold[
(* --- summary of every assertion made so far --------------------------------------------- *)
ClearAll[cfAssertSummary];
cfAssertSummary[] := Module[{n, bad},
  n = Length[$cfAssertLog];
  bad = Cases[$cfAssertLog, {l_, False} :> l];
  Print["Assertions run: ", n, "   passed: ", n - Length[bad], "   failed: ", Length[bad]];
  If[bad =!= {}, Print["FAILED: ", Column[bad]]];
  Grid[Prepend[$cfAssertLog, {"assertion", "ok"}], Frame -> All, Alignment -> Left]];
]];

(* ---------- Input cell 7 ---------- *)
cfRunCell[7, Hold[
ClearAll[X, x0, x1, x2, x3, x4, x5, x6, x7];
X = {x0, x1, x2, x3, x4, x5, x6, x7};
Protect[X, x0, x1, x2, x3, x4, x5, x6, x7];
X
]];

(* ---------- Input cell 8 ---------- *)
cfRunCell[8, Hold[
(* --- the flat 4+4 Minkowski metric eta_{AB} ---------------------------------------------- *)
ClearAll[\[Eta]4488, ID4, ID8, ID16, Zero4, Zero8, ZERO16];
ID4  = IdentityMatrix[4];
ID8  = IdentityMatrix[8];
ID16 = IdentityMatrix[16];
Zero4  = ConstantArray[0, {4, 4}];
Zero8  = ConstantArray[0, {8, 8}];
ZERO16 = ConstantArray[0, {16, 16}];
\[Eta]4488 = ArrayFlatten[{{ID4, 0}, {0, -ID4}}];
MatrixForm[\[Eta]4488]
]];

(* ---------- Input cell 9 ---------- *)
cfRunCell[9, Hold[
(* --- eta is its own inverse, so raising and lowering flat indices is cheap --------------- *)
cfAssert["eta4488 . eta4488 == ID8", \[Eta]4488 . \[Eta]4488 === ID8];
cfAssert["eta4488 is symmetric", \[Eta]4488 === Transpose[\[Eta]4488]];
cfAssert["signature of eta4488 is (4,4)", Sort[Diagonal[\[Eta]4488]] === Sort[{1,1,1,1,-1,-1,-1,-1}]];
Diagonal[\[Eta]4488]
]];

(* ---------- Input cell 10 ---------- *)
cfRunCell[10, Hold[
ClearAll[\[Epsilon]3, \[Epsilon]4];
\[Epsilon]3 = Array[Signature[{##}] &, {3, 3, 3}];
\[Epsilon]4 = Array[Signature[{##}] &, {4, 4, 4, 4}];
{Dimensions[\[Epsilon]3], Dimensions[\[Epsilon]4], \[Epsilon]4[[1, 2, 3, 4]]}
]];

(* ---------- Input cell 11 ---------- *)
cfRunCell[11, Hold[
ClearAll[sX0, ssX, constraintVars];
sX0 = And @@ Thread[X > 0];
ssX = H > 0 && sX0 && 6 H x0 > 0 && 2 la[x4] > 0 && Cot[6 H x0] > 0 && Sin[6 H x0] > 0;
constraintVars = x0 > 0 && x4 > 0 && z > 0 && t > 0;
{sX0, ssX, constraintVars}
]];

(* ---------- Input cell 12 ---------- *)
cfRunCell[12, Hold[
(* --- the (x0,x4) <-> (z,t) chart change of the original notebook ------------------------- *)
ClearAll[szt, sx0x4];
szt   = Solve[6 H x0 == z && H x4 == t, {z, t}][[1]];
sx0x4 = Solve[6 H x0 == z && H x4 == t, {x0, x4}][[1]];
Protect[szt, sx0x4];
{szt, sx0x4}
]];

(* ---------- Input cell 13 ---------- *)
cfRunCell[13, Hold[
ClearAll[Qa, Qb, cfSelfDual, cfAntiSelfDual, s4by4, t4by4];
Qa[h_Integer, p_Integer, q_Integer] := Signature[{h, p, q, 4}];
Qb[h_Integer, p_Integer, q_Integer] := ID4[[p, 4]] ID4[[q, h]] - ID4[[p, h]] ID4[[q, 4]];
cfSelfDual[h_, p_, q_]     := Qa[h, p, q] - Qb[h, p, q];
cfAntiSelfDual[h_, p_, q_] := Qa[h, p, q] + Qb[h, p, q];
Do[s4by4[h] = Table[cfSelfDual[h, p, q],     {p, 4}, {q, 4}], {h, 1, 3}];
Do[t4by4[h] = Table[cfAntiSelfDual[h, p, q], {p, 4}, {q, 4}], {h, 1, 3}];
Protect[s4by4, t4by4];
Grid[{{"h", "s4by4[h]", "t4by4[h]"},
      Sequence @@ Table[{h, MatrixForm[s4by4[h]], MatrixForm[t4by4[h]]}, {h, 3}]}, Frame -> All]
]];

(* ---------- Input cell 14 ---------- *)
cfRunCell[14, Hold[
(* --- duality checks, exactly the two tests of the original notebook ---------------------- *)
cfAssert["s4by4 is self-dual",
  Table[(1/2) Sum[\[Epsilon]4[[p, q, j1, j2]] s4by4[h][[j1, j2]], {j1, 4}, {j2, 4}] ==
        s4by4[h][[p, q]], {h, 3}, {p, 4}, {q, 4}]];
cfAssert["t4by4 is anti-self-dual",
  Table[(1/2) Sum[\[Epsilon]4[[p, q, j1, j2]] t4by4[h][[j1, j2]], {j1, 4}, {j2, 4}] ==
        -t4by4[h][[p, q]], {h, 3}, {p, 4}, {q, 4}]];
cfAssert["s4by4 and t4by4 are antisymmetric",
  Join[Table[s4by4[h] === -Transpose[s4by4[h]], {h, 3}],
       Table[t4by4[h] === -Transpose[t4by4[h]], {h, 3}]]];
cfAssert["the two su(2) factors commute",
  Table[s4by4[j] . t4by4[k] === t4by4[k] . s4by4[j], {j, 3}, {k, 3}]];
]];

(* ---------- Input cell 15 ---------- *)
cfRunCell[15, Hold[
(* --- the nine mixed products st[J,K], used to complete the 4x4 basis -------------------- *)
ClearAll[st];
Do[st[J, K] = s4by4[J] . t4by4[K], {J, 1, 3}, {K, 1, 3}];
Protect[st];
cfAssert["st[J,K] is symmetric", Table[st[J, K] === Transpose[st[J, K]], {J, 3}, {K, 3}]];
Grid[Table[MatrixForm[st[J, K]], {J, 3}, {K, 3}], Frame -> All]
]];

(* ---------- Input cell 16 ---------- *)
cfRunCell[16, Hold[
ClearAll[\[Sigma]];
\[Sigma] = ArrayFlatten[{{Zero4, ID4}, {ID4, Zero4}}];
cfAssert["sigma . sigma == ID8", \[Sigma] . \[Sigma] === ID8];
cfAssert["sigma is symmetric", \[Sigma] === Transpose[\[Sigma]]];
cfAssert["Tr[sigma] == 0", Tr[\[Sigma]] === 0];
MatrixForm[\[Sigma]]
]];

(* ---------- Input cell 17 ---------- *)
cfRunCell[17, Hold[
ClearAll[sixAntiSymmetric8by8];
sixAntiSymmetric8by8 = Join[
   Table[ArrayFlatten[{{0, s4by4[h]}, { s4by4[h], 0}}], {h, 1, 3}],
   Table[ArrayFlatten[{{0, t4by4[h]}, {-t4by4[h], 0}}], {h, 3, 1, -1}]];
cfAssert["blocks 1-3 (built from s4by4) are antisymmetric",
  Table[sixAntiSymmetric8by8[[k]] === -Transpose[sixAntiSymmetric8by8[[k]]], {k, 1, 3}]];
cfAssert["blocks 4-6 (built from t4by4) are symmetric",
  Table[sixAntiSymmetric8by8[[k]] === Transpose[sixAntiSymmetric8by8[[k]]], {k, 4, 6}]];
Length[sixAntiSymmetric8by8]
]];

(* ---------- Input cell 18 ---------- *)
cfRunCell[18, Hold[
ClearAll[\[Tau], \[Tau]bar];
\[Tau][0] = ID8;
Do[\[Tau][h] = sixAntiSymmetric8by8[[h]], {h, 1, 6}];
\[Tau][7] = \[Tau][1] . \[Tau][2] . \[Tau][3] . \[Tau][4] . \[Tau][5] . \[Tau][6];
Do[\[Tau]bar[A] = \[Sigma] . Transpose[\[Sigma] . \[Tau][A]], {A, 0, 7}];
MatrixForm[\[Tau][7]]
]];

(* ---------- Input cell 19 ---------- *)
cfRunCell[19, Hold[
(* --- the defining Clifford relation ------------------------------------------------------ *)
cfAssert["(1/2)(tau[A].taubar[B] + tau[B].taubar[A]) == eta4488[[A+1,B+1]] ID8",
  Table[(1/2) (\[Tau][A] . \[Tau]bar[B] + \[Tau][B] . \[Tau]bar[A]) ===
        \[Eta]4488[[A + 1, B + 1]] ID8, {A, 0, 7}, {B, 0, 7}]];
]];

(* ---------- Input cell 20 ---------- *)
cfRunCell[20, Hold[
(* --- the identities of the original notebook that fix the ordering conventions ----------- *)
cfAssert["sigma == tau[1].tau[2].tau[3]", \[Sigma] === \[Tau][1] . \[Tau][2] . \[Tau][3]];
cfAssert["sigma == tau[4].tau[5].tau[6].tau[7]",
  \[Sigma] === \[Tau][4] . \[Tau][5] . \[Tau][6] . \[Tau][7]];
cfAssert["tau[1]...tau[7] == tau[0] == ID8",
  \[Tau][1] . \[Tau][2] . \[Tau][3] . \[Tau][4] . \[Tau][5] . \[Tau][6] . \[Tau][7] === ID8];
cfAssert["sigma . taubar[A] == Transpose[sigma . tau[A]]",
  Table[\[Sigma] . \[Tau]bar[A] === Transpose[\[Sigma] . \[Tau][A]], {A, 0, 7}]];
cfAssert["-eta4488[[A+1,A+1]] tau[A] == Transpose[tau[A]] for A = 1..7",
  Table[-\[Eta]4488[[A + 1, A + 1]] \[Tau][A] === Transpose[\[Tau][A]], {A, 1, 7}]];
]];

(* ---------- Input cell 21 ---------- *)
cfRunCell[21, Hold[
(* --- Omega = sigma . tau[7] is the second invariant of the original notebook ------------- *)
ClearAll[\[CapitalOmega]];
\[CapitalOmega] = \[Sigma] . \[Tau][7];
cfAssert["Omega == tau[4].tau[5].tau[6]",
  \[CapitalOmega] === \[Tau][4] . \[Tau][5] . \[Tau][6]];
{Det[\[CapitalOmega]], MatrixForm[\[CapitalOmega]]}
]];

(* ---------- Input cell 22 ---------- *)
cfRunCell[22, Hold[
ClearAll[T16, \[Sigma]16, covariantDiffMatrix];
Do[T16[A] = ArrayFlatten[{{0, \[Tau]bar[A]}, {\[Tau][A], 0}}], {A, 0, 7}];
(* T16[8] is the chirality operator: the ordered product of all eight generators. *)
T16[8] = Dot @@ Table[T16[A], {A, 0, 7}];
Dimensions[T16[0]]
]];

(* ---------- Input cell 23 ---------- *)
cfRunCell[23, Hold[
(* --- the defining Clifford relation for the 16x16 Dirac matrices ------------------------- *)
(* Optimization: the original wrapped this in FullSimplify.  Every entry here is an exact    *)
(* integer, so FullSimplify is a no-op that costs several seconds; it is dropped.  The       *)
(* identity being verified is byte-for-byte the one in the original notebook.                *)
cfAssert["{T16[A], T16[B]}/2 == eta4488[[A+1,B+1]] ID16",
  Table[(1/2) (T16[A] . T16[B] + T16[B] . T16[A]) === \[Eta]4488[[A + 1, B + 1]] ID16,
    {A, 0, 7}, {B, 0, 7}]];
]];

(* ---------- Input cell 24 ---------- *)
cfRunCell[24, Hold[
(* --- sigma16 is the 16x16 spinor metric; it is the product of the four spacelike gammas -- *)
\[Sigma]16 = T16[0] . T16[1] . T16[2] . T16[3];
cfAssert["sigma16 == ArrayFlatten[{{-sigma,0},{0,sigma}}]",
  \[Sigma]16 === ArrayFlatten[{{-\[Sigma], 0}, {0, \[Sigma]}}]];
cfAssert["sigma16 . T16[A] is antisymmetric for A = 0..7",
  Table[\[Sigma]16 . T16[A] === -Transpose[\[Sigma]16 . T16[A]], {A, 0, 7}]];
cfAssert["T16[8] == sigma16 . T16[4].T16[5].T16[6].T16[7]",
  T16[8] === \[Sigma]16 . T16[4] . T16[5] . T16[6] . T16[7]];
MatrixForm[\[Sigma]16]
]];

(* ---------- Input cell 25 ---------- *)
cfRunCell[25, Hold[
(* --- the matrix that the original notebook uses to build covariant differences ----------- *)
covariantDiffMatrix = T16[5] . T16[6] . T16[7];
cfAssert["sigma16 . covariantDiffMatrix is symmetric",
  \[Sigma]16 . covariantDiffMatrix === Transpose[\[Sigma]16 . covariantDiffMatrix]];
MatrixForm[covariantDiffMatrix]
]];

(* ---------- Input cell 26 ---------- *)
cfRunCell[26, Hold[
ClearAll[PL, PR];
PL = (1/2) (ID16 - T16[8]);
PR = (1/2) (ID16 + T16[8]);
cfAssert["PL + PR == ID16", PL + PR === ID16];
cfAssert["PL is idempotent", PL . PL === PL];
cfAssert["PR is idempotent", PR . PR === PR];
cfAssert["PL . PR == PR . PL == 0", {PL . PR === ZERO16, PR . PL === ZERO16}];
(* Which half is which.  T16[8] is diag(-ID8, +ID8), so PL is the projector onto the UPPER    *)
(* eight components -- the type-1 spinor -- and PR onto the LOWER eight, the type-2 spinor.  *)
(* Part III uses this: the 16-component covariant derivative is a direct sum of a type-1 and  *)
(* a type-2 piece precisely because the connection commutes with T16[8].                      *)
cfAssert["PL projects onto the upper (type-1) components, PR onto the lower (type-2) components",
  {PL === DiagonalMatrix[Join[ConstantArray[1, 8], ConstantArray[0, 8]]],
   PR === DiagonalMatrix[Join[ConstantArray[0, 8], ConstantArray[1, 8]]]}];
{MatrixForm[PL], MatrixForm[PR]}
]];

(* ---------- Input cell 27 ---------- *)
cfRunCell[27, Hold[
ClearAll[SAB, sAB];
SAB = Table[(1/4) (T16[A1] . T16[B1] - T16[B1] . T16[A1]), {A1, 0, 7}, {B1, 0, 7}];
(* the same objects addressed by flat index rather than array position, as in the original *)
Do[sAB[A1][B1] = SAB[[A1 + 1, B1 + 1]], {A1, 0, 7}, {B1, 0, 7}];
cfAssert["SAB is antisymmetric in its two flat indices",
  Table[SAB[[A1, B1]] === -SAB[[B1, A1]], {A1, 1, 8}, {B1, 1, 8}]];
(* sigma16 . SAB is ANTIsymmetric, not symmetric.  Proof: sigma16 is symmetric and squares to *)
(* ID16, and sigma16 . T16[A] is antisymmetric, so Transpose[T16[A]] == -sigma16.T16[A].sigma16. *)
(* Substituting that twice into Transpose[sigma16 . T16[A] . T16[B]] gives sigma16.T16[B].T16[A], *)
(* which flips the sign of the commutator.  The original notebook records both the correct claim *)
(* and, in an exploratory cell, the opposite one; only the antisymmetric statement is true.      *)
cfAssert["sigma16 . SAB is antisymmetric",
  Table[\[Sigma]16 . SAB[[A1, B1]] === -Transpose[\[Sigma]16 . SAB[[A1, B1]]], {A1, 1, 8}, {B1, 1, 8}]];
cfAssert["sigma16 is symmetric and sigma16 . sigma16 == ID16",
  {\[Sigma]16 === Transpose[\[Sigma]16], \[Sigma]16 . \[Sigma]16 === ID16}];
cfAssert["T16[8] commutes with every SAB: the chiral halves are each Spin(4,4)-invariant",
  Table[T16[8] . SAB[[A1, B1]] === SAB[[A1, B1]] . T16[8], {A1, 1, 8}, {B1, 1, 8}]];
Dimensions[SAB]
]];

(* ---------- Input cell 28 ---------- *)
cfRunCell[28, Hold[
(* --- the so(4,4) commutation relations, over the 28 independent index pairs ------------- *)
(* [S_AB, S_CD] == -( eta_AC S_BD - eta_AD S_BC - eta_BC S_AD + eta_BD S_AC )               *)
cfTimed["so(4,4) commutators over 28 x 28 index pairs",
 cfAssert["[SAB,SAB] closes on the so(4,4) algebra",
  Flatten @ Table[
    SAB[[A1, B1]] . SAB[[A2, B2]] - SAB[[A2, B2]] . SAB[[A1, B1]] ===
      -(\[Eta]4488[[A1, A2]] SAB[[B1, B2]] - \[Eta]4488[[A1, B2]] SAB[[B1, A2]]
        - \[Eta]4488[[B1, A2]] SAB[[A1, B2]] + \[Eta]4488[[B1, B2]] SAB[[A1, A2]]),
    {A1, 1, 7}, {B1, A1 + 1, 8}, {A2, 1, 7}, {B2, A2 + 1, 8}]]];
]];

(* ---------- Input cell 29 ---------- *)
cfRunCell[29, Hold[
(* --- S_AB rotates the gammas as a vector: [S_AB, gamma_C] == -eta_CA gamma_B + eta_CB gamma_A *)
cfTimed["vector transformation law of the gammas",
 cfAssert["[SAB, T16] reproduces the vector representation",
  Flatten @ Table[
    SAB[[A1, B1]] . T16[B2 - 1] - T16[B2 - 1] . SAB[[A1, B1]] ===
      -\[Eta]4488[[B2, A1]] T16[B1 - 1] + \[Eta]4488[[B2, B1]] T16[A1 - 1],
    {A1, 1, 8}, {B1, 1, 8}, {B2, 1, 8}]]];
]];

(* ---------- Input cell 30 ---------- *)
cfRunCell[30, Hold[
ClearAll[cfCliffordWord, base16];
(* cfCliffordWord[{j1,...,jk}] is the ordered product T16[j1]. ... .T16[jk] *)
cfCliffordWord[idx_List] := Dot @@ (T16 /@ idx);
base16 = cfTimed["build the 256-element basis of the 16x16 algebra",
  Join[
    Sequence @@ Table[{cfCliffordWord[#], #} & /@ Subsets[Range[0, 7], {k}], {k, 1, 8}],
    {{ID16, {Range[0, 7]}}}]];
{Length[base16], Length[Union[base16[[All, 1]]]]}
]];

(* ---------- Input cell 31 ---------- *)
cfRunCell[31, Hold[
(* --- the two positional references made by the original notebook ------------------------- *)
cfAssert["base16[[93]] is sigma16", \[Sigma]16 === base16[[93, 1]]];
cfAssert["base16[[255]] is the chirality operator T16[8]", T16[8] === base16[[255, 1]]];
cfAssert["base16[[256]] is the identity", ID16 === base16[[256, 1]]];
{base16[[93, 2]], base16[[255, 2]], base16[[256, 2]]}
]];

(* ---------- Input cell 32 ---------- *)
cfRunCell[32, Hold[
(* --- every basis element squares to +ID16 or -ID16, so Tr[M.M]/16 is +1 or -1 ------------ *)
cfAssert["Tr[M.M]/16 is +1 or -1 for every basis element",
  MemberQ[{1, -1}, #] & /@ Union[Flatten[Tr[#. #/16] & /@ base16[[All, 1]]]]];
Union[Flatten[Tr[#. #/16] & /@ base16[[All, 1]]]]
]];

(* ---------- Input cell 33 ---------- *)
cfRunCell[33, Hold[
(* --- split the basis by the sign of Tr[M.M]; the original records 136 and 120 ----------- *)
ClearAll[positiveTrMM, negativeTrMM];
positiveTrMM = Select[base16, Tr[#[[1]] . #[[1]]] > 0 & -> "Index"];
negativeTrMM = Select[base16, Tr[#[[1]] . #[[1]]] < 0 & -> "Index"];
cfAssert["136 basis elements have Tr[M.M] > 0", Length[positiveTrMM] === 136];
cfAssert["120 basis elements have Tr[M.M] < 0", Length[negativeTrMM] === 120];
{Length[positiveTrMM], Length[negativeTrMM]}
]];

(* ---------- Input cell 34 ---------- *)
cfRunCell[34, Hold[
(* --- and the same split is the symmetric / antisymmetric split: 16*17/2 and 16*15/2 ------ *)
ClearAll[symm16, antisymm16];
symm16     = Select[Range[Length[base16]], base16[[#, 1]] ===  Transpose[base16[[#, 1]]] &];
antisymm16 = Select[Range[Length[base16]], base16[[#, 1]] === -Transpose[base16[[#, 1]]] &];
cfAssert["symmetric basis elements number 16*17/2 = 136", Length[symm16] === 136];
cfAssert["antisymmetric basis elements number 16*15/2 = 120", Length[antisymm16] === 120];
cfAssert["Tr[M.M] > 0 exactly when M is symmetric", Sort[symm16] === Sort[positiveTrMM]];
cfAssert["Tr[M.M] < 0 exactly when M is antisymmetric", Sort[antisymm16] === Sort[negativeTrMM]];
{Length[symm16], Length[antisymm16], 16 (16 + 1)/2, 16 (16 - 1)/2}
]];

(* ---------- Input cell 35 ---------- *)
cfRunCell[35, Hold[
(* --- the original also removes sign-duplicates to get a projective basis ----------------- *)
ClearAll[dups, BASE16, use16];
dups = cfTimed["find sign-duplicate basis elements",
  Select[base16, MemberQ[base16[[All, 1]], -#[[1]]] &]];
BASE16 = use16 = Complement[base16, dups];
{Length[dups], Length[use16]}
]];

(* ---------- Input cell 36 ---------- *)
cfRunCell[36, Hold[
ClearAll[bas64, \[Eta]64];
bas64 = Join[
   Sequence @@ Table[{Dot @@ (\[Tau] /@ #), #} & /@ Subsets[Range[1, 7], {k}], {k, 1, 3}],
   {{ID8, {64}}}];
cfAssert["the 8x8 basis has 64 elements", Length[bas64] === 64];
cfAssert["the 64 elements are distinct", Length[Union[bas64[[All, 1]]]] === 64];
\[Eta]64 = DiagonalMatrix[Table[(1/8) Tr[bas64[[A, 1]] . bas64[[A, 1]]], {A, 64}]];
{Length[bas64], Tr[\[Eta]64], Union[Diagonal[\[Eta]64]]}
]];

(* ---------- Input cell 37 ---------- *)
cfRunCell[37, Hold[
(* --- the trace form is orthogonal: (1/8) Tr[M_A . M_B] is diagonal ---------------------- *)
cfTimed["orthogonality of the 64-element trace form",
 cfAssert["(1/8) Tr[bas64[A].bas64[B]] == eta64[[A,B]]",
  Flatten @ Table[(1/8) Tr[bas64[[A, 1]] . bas64[[B, 1]]] === \[Eta]64[[A, B]],
    {A, 1, 64}, {B, 1, 64}]]];
]];

(* ---------- Input cell 38 ---------- *)
cfRunCell[38, Hold[
(* --- symmetric / antisymmetric split of the 8x8 basis: 8*9/2 = 36 and 8*7/2 = 28 -------- *)
ClearAll[symm8, anti8];
symm8 = Select[Range[64], bas64[[#, 1]] ===  Transpose[bas64[[#, 1]]] &];
anti8 = Select[Range[64], bas64[[#, 1]] === -Transpose[bas64[[#, 1]]] &];
cfAssert["symmetric 8x8 basis elements number 36", Length[symm8] === 36];
cfAssert["antisymmetric 8x8 basis elements number 28", Length[anti8] === 28];
{Length[symm8], Length[anti8]}
]];

(* ---------- Input cell 39 ---------- *)
cfRunCell[39, Hold[
ClearAll[g44, g3, Gr, \[Gamma]4];
g44 = \[Eta]4488[[2 ;; 5, 2 ;; 5]];
g3 = DiagonalMatrix[{1, 1, -1}];
Do[Gr[h, k] = t4by4[h] . s4by4[k] (-g3[[h, h]] g3[[k, k]]), {h, 1, 3}, {k, 1, 3}];
\[Gamma]4 = {Gr[1, 1], Gr[1, 2], Gr[1, 3], t4by4[2]};
AppendTo[\[Gamma]4, -\[Gamma]4[[1]] . \[Gamma]4[[2]] . \[Gamma]4[[3]] . \[Gamma]4[[4]]];
cfAssert["g44 == diag(1,1,1,-1)", g44 === DiagonalMatrix[{1, 1, 1, -1}]];
cfAssert["gamma4[[5]] == -t4by4[3]", \[Gamma]4[[5]] === -t4by4[3]];
{MatrixForm[g44], MatrixForm /@ \[Gamma]4}
]];

(* ---------- Input cell 40 ---------- *)
cfRunCell[40, Hold[
(* --- the four-dimensional Clifford relation, and the fifth gamma ------------------------- *)
cfAssert["{gamma4[h], gamma4[k]} == 2 g44[[h,k]] ID4  for h,k = 1..4",
  Table[\[Gamma]4[[h]] . \[Gamma]4[[k]] + \[Gamma]4[[k]] . \[Gamma]4[[h]] === 2 g44[[h, k]] ID4,
    {h, 1, 4}, {k, 1, 4}]];
cfAssert["{gamma4[h], gamma4[k]} == 2 eta4488[[1+h,1+k]] ID4  for h,k = 1..5",
  Table[\[Gamma]4[[h]] . \[Gamma]4[[k]] + \[Gamma]4[[k]] . \[Gamma]4[[h]] ===
     2 \[Eta]4488[[1 + h, 1 + k]] ID4, {h, 1, 5}, {k, 1, 5}]];
]];

(* ---------- Input cell 41 ---------- *)
cfRunCell[41, Hold[
(* --- the 4x4 charge-conjugation matrix epsilon, and the Lorentz generators S44 ----------- *)
ClearAll[\[CurlyEpsilon]4, S44, \[Eta]44];
\[CurlyEpsilon]4 = t4by4[2];
\[Eta]44 = DiagonalMatrix[{1, 1, 1, -1}];
S44 = -(1/4) Table[\[Gamma]4[[h]] . \[Gamma]4[[k]] - \[Gamma]4[[k]] . \[Gamma]4[[h]], {h, 1, 4}, {k, 1, 4}];
cfAssert["epsilon4 is antisymmetric", Transpose[\[CurlyEpsilon]4] === -\[CurlyEpsilon]4];
(* epsilon4 is the charge-conjugation matrix of the four-dimensional algebra.  It is symmetric *)
(* against the four vector gammas and ANTIsymmetric against the chirality gamma gamma4[[5]].   *)
(* The original notebook tests A = 1..5 in one exploratory cell and therefore sees a mixed     *)
(* result; the two correct statements are separated here.                                     *)
cfAssert["epsilon4 . gamma4[A] is symmetric for A = 1..4",
  Table[\[CurlyEpsilon]4 . \[Gamma]4[[A]] === Transpose[\[CurlyEpsilon]4 . \[Gamma]4[[A]]], {A, 1, 4}]];
cfAssert["epsilon4 . gamma4[5] is ANTIsymmetric",
  \[CurlyEpsilon]4 . \[Gamma]4[[5]] === -Transpose[\[CurlyEpsilon]4 . \[Gamma]4[[5]]]];
cfAssert["epsilon4 . epsilon4 == -ID4", \[CurlyEpsilon]4 . \[CurlyEpsilon]4 === -ID4];
cfAssert["epsilon4 . S44 is symmetric",
  Table[\[CurlyEpsilon]4 . S44[[A, B]] === Transpose[\[CurlyEpsilon]4 . S44[[A, B]]],
    {A, 1, 3}, {B, A + 1, 4}]];
Dimensions[S44]
]];

(* ---------- Input cell 42 ---------- *)
cfRunCell[42, Hold[
(* --- the so(3,1) commutation relations, and the vector law for the 4x4 gammas ------------ *)
cfAssert["[S44,S44] closes on the so(3,1) algebra",
  Flatten @ Table[
    S44[[A1, B1]] . S44[[A2, B2]] - S44[[A2, B2]] . S44[[A1, B1]] ===
      \[Eta]44[[A1, A2]] S44[[B1, B2]] - \[Eta]44[[A1, B2]] S44[[B1, A2]]
      - \[Eta]44[[B1, A2]] S44[[A1, B2]] + \[Eta]44[[B1, B2]] S44[[A1, A2]],
    {A1, 1, 3}, {B1, A1 + 1, 4}, {A2, 1, 3}, {B2, A2 + 1, 4}]];
cfAssert["[S44, gamma4] reproduces the vector representation",
  Flatten @ Table[
    S44[[A1, B1]] . \[Gamma]4[[B2]] - \[Gamma]4[[B2]] . S44[[A1, B1]] ===
      \[Eta]44[[B2, A1]] \[Gamma]4[[B1]] - \[Eta]44[[B2, B1]] \[Gamma]4[[A1]],
    {A1, 1, 4}, {B1, 1, 4}, {B2, 1, 4}]];
]];

(* ---------- Input cell 43 ---------- *)
cfRunCell[43, Hold[
(* --- a complete 16-element basis of the 4x4 matrix algebra ------------------------------- *)
(* Built from the 2x2 Pauli blocks exactly as the original does, with                        *)
(*   sigma22    = { ID2,  sigma1, I sigma2, sigma3 }   (the original's If[#==2, I, 1])       *)
(*   sigma22bar = { -ID2, sigma1, I sigma2, sigma3 }                                         *)
(* Every entry is real, because I PauliMatrix[2] == {{0,1},{-1,0}}.                          *)
(* and xxx[j] = ArrayFlatten[{{0, sigma22bar[j]}, {sigma22[j], 0}}].                          *)
ClearAll[\[Sigma]22, \[Sigma]22bar, xxx, base4by4, \[Eta]2244];
\[Sigma]22    = Join[{IdentityMatrix[2]}, Table[If[h == 2, I, 1] PauliMatrix[h], {h, 1, 3}]];
\[Sigma]22bar = Join[{-IdentityMatrix[2]}, Table[If[h == 2, I, 1] PauliMatrix[h], {h, 1, 3}]];
\[Eta]2244 = DiagonalMatrix[{-1, 1, -1, 1}];
cfAssert["(1/2)(sigma22[A] sigma22bar[B] + sigma22[B] sigma22bar[A]) == eta2244[[A,B]] ID2",
  Table[(1/2) (\[Sigma]22[[A]] . \[Sigma]22bar[[B]] + \[Sigma]22[[B]] . \[Sigma]22bar[[A]]) ===
     \[Eta]2244[[A, B]] IdentityMatrix[2], {A, 1, 4}, {B, 1, 4}]];
Do[xxx[j] = ArrayFlatten[{{0, \[Sigma]22bar[[j]]}, {\[Sigma]22[[j]], 0}}], {j, 1, 4}];
base4by4 = Join[{{ID4, {0}}},
   Sequence @@ Table[{Dot @@ (xxx /@ #), #} & /@ Subsets[Range[1, 4], {k}], {k, 1, 4}]];
cfAssert["the 4x4 basis has 16 elements", Length[base4by4] === 16];
cfAssert["the 16 elements are linearly independent",
  MatrixRank[Flatten /@ base4by4[[All, 1]]] === 16];
{Length[base4by4], MatrixRank[Flatten /@ base4by4[[All, 1]]]}
]];

(* ---------- Input cell 44 ---------- *)
cfRunCell[44, Hold[
(* --- and the 1 + 4 + 6 + 4 + 1 symmetry pattern of the 4x4 basis ------------------------- *)
cfAssert["the 4x4 basis splits 10 symmetric + 6 antisymmetric",
  {Length[Select[base4by4, #[[1]] ===  Transpose[#[[1]]] &]] === 10,
   Length[Select[base4by4, #[[1]] === -Transpose[#[[1]]] &]] ===  6}];
{Plus @@ {1, 4, 6, 4, 1},
 Length[Select[base4by4, #[[1]] === Transpose[#[[1]]] &]],
 Length[Select[base4by4, #[[1]] === -Transpose[#[[1]]] &]]}
]];

(* ---------- Input cell 45 ---------- *)
cfRunCell[45, Hold[
ClearAll[evalues, evecs, uEig, hUSE, unit];
{evalues, evecs} = Eigensystem[\[Sigma]];
uEig = ExpandAll[(1/Sqrt[2]) evecs];
hUSE = 8;
unit = uEig[[hUSE]];
(* Pin it.  Everything downstream -- the triality bridge, the octonion structure constants,   *)
(* the split into type 1 and type 2 -- is built on this one spinor, and Eigensystem promises   *)
(* nothing about the order of its rows.  If a future kernel reorders them this line fails      *)
(* loudly instead of silently changing every table that follows.                              *)
cfAssert["unit is pinned to the author's spinor {1/Sqrt[2],0,0,0,1/Sqrt[2],0,0,0} -- the row order of Eigensystem is not relied on silently",
  unit === {1/Sqrt[2], 0, 0, 0, 1/Sqrt[2], 0, 0, 0}];
Protect[hUSE, unit];
cfAssert["each uEig row is sigma-normalized to +/-1",
  MemberQ[{1, -1}, #] & /@ Table[uEig[[h]] . \[Sigma] . uEig[[h]], {h, 1, 8}]];
cfAssert["unit is sigma-normalized to +1", unit . \[Sigma] . unit === 1];
{evalues, MatrixForm[uEig], unit}
]];

(* ---------- Input cell 46 ---------- *)
cfRunCell[46, Hold[
ClearAll[triVecToSpin, triSpinToVec];
triVecToSpin = Table[unit . \[Sigma] . \[Tau]bar[A], {A, 0, 7}];
triSpinToVec = Inverse[triVecToSpin];
cfAssert["triVecToSpin . triSpinToVec == ID8", triVecToSpin . triSpinToVec === ID8];
cfAssert["triSpinToVec . triVecToSpin == ID8", triSpinToVec . triVecToSpin === ID8];
(* the original's closed form for the inverse bridge *)
cfAssert["triSpinToVec == Transpose[ eta_AA tau[A].unit ]  (the original's closed form)",
  triSpinToVec === Transpose[Table[\[Eta]4488[[A + 1, A + 1]] (\[Tau][A] . unit), {A, 0, 7}]]];
MatrixForm[triVecToSpin]
]];

(* ---------- Input cell 47 ---------- *)
cfRunCell[47, Hold[
ClearAll[\[Eta]Tri];
\[Eta]Tri = Simplify[triSpinToVec . \[Eta]4488 . Transpose[triSpinToVec]];
cfAssert["etaTri is symmetric", \[Eta]Tri === Transpose[\[Eta]Tri]];
cfAssert["etaTri has signature (4,4)",
  Sort[Eigenvalues[\[Eta]Tri]] === Sort[{1, 1, 1, 1, -1, -1, -1, -1}]];
(* w_a = v^A triVecToSpin[[A,a]], so v.eta.v == w.etaTri.w means eta == P . etaTri . Transpose[P]. *)
cfAssert["triVecToSpin transports etaTri back to eta4488",
  Simplify[triVecToSpin . \[Eta]Tri . Transpose[triVecToSpin] - \[Eta]4488] === Zero8];
cfAssert["THE TRIALITY METRIC IS EXACTLY THE SPINOR METRIC:  etaTri == sigma",
  \[Eta]Tri === \[Sigma]];
MatrixForm[\[Eta]Tri]
]];

(* ---------- Input cell 48 ---------- *)
cfRunCell[48, Hold[
ClearAll[\[Tau]A, mabc, mABC];
\[Tau]A = Table[\[Eta]4488[[A, A]] \[Tau][A - 1], {A, 1, 8}];
mabc = cfTimed["split-octonion structure constants in the spinor basis",
  Table[Sum[triVecToSpin[[A1, a1]] \[Tau]A[[A1]][[c1, b1]], {A1, 1, 8}],
    {a1, 1, 8}, {b1, 1, 8}, {c1, 1, 8}]];
mABC = cfTimed["split-octonion structure constants in the vector basis",
  Table[Sum[triVecToSpin[[C1, c1]] \[Tau]A[[A1]][[c1, b1]] triSpinToVec[[b1, B1]],
      {b1, 1, 8}, {c1, 1, 8}], {A1, 1, 8}, {B1, 1, 8}, {C1, 1, 8}]];
{Dimensions[mabc], Dimensions[mABC]}
]];

(* ---------- Input cell 49 ---------- *)
cfRunCell[49, Hold[
(* --- the vector basis units, and the multiplication table as the original displays it ---- *)
ClearAll[EA, gridSplitOctonion];
EA = Array[eA, 8];
gridSplitOctonion = Grid[
  Prepend[
    Table[Flatten[{EA[[A1]], Table[Sum[mABC[[A1, B1, C1]] EA[[C1]], {C1, 1, 8}], {B1, 1, 8}]}],
      {A1, 1, 8}],
    Flatten[{"A/B", EA}]],
  Frame -> All];
gridSplitOctonion
]];

(* ---------- Input cell 50 ---------- *)
cfRunCell[50, Hold[
(* --- eA[1] is the unit of the algebra: eA[1] x = x eA[1] = x ---------------------------- *)
cfAssert["eA[1] is a two-sided identity for the vector-basis product",
  Join[
   Flatten @ Table[Sum[mABC[[1, B1, C1]] ID8[[C1]], {C1, 8}] === ID8[[B1]], {B1, 1, 8}],
   Flatten @ Table[Sum[mABC[[A1, 1, C1]] ID8[[C1]], {C1, 8}] === ID8[[A1]], {A1, 1, 8}]]];
Table[Sum[mABC[[1, B1, C1]] EA[[C1]], {C1, 8}], {B1, 8}]
]];

(* ---------- Input cell 51 ---------- *)
cfRunCell[51, Hold[
(* --- the norm is multiplicative on basis units: m^C_AB eta_CD m^D_AB = eta_AA eta_BB ----- *)
cfAssert["<eA, eB> composition is compatible with eta (basis-unit norm form)",
  Flatten @ Table[
    Sum[mABC[[A1, B1, C1]] \[Eta]4488[[C1, D1]] mABC[[A1, B1, D1]], {C1, 8}, {D1, 8}] ===
      \[Eta]4488[[A1, A1]] \[Eta]4488[[B1, B1]],
    {A1, 1, 8}, {B1, 1, 8}]];
]];

(* ---------- Input cell 52 ---------- *)
cfRunCell[52, Hold[
(* --- the imaginary structure constants are totally antisymmetric ------------------------- *)
(* Lower the last index with eta and drop the real direction A=1 (the unit eA[1]).          *)
ClearAll[mLower, mImTotallyAntisymmetric];
mLower = Table[Sum[mABC[[A1, B1, D1]] \[Eta]4488[[D1, C1]], {D1, 8}],
  {A1, 1, 8}, {B1, 1, 8}, {C1, 1, 8}];
mImTotallyAntisymmetric = Flatten @ Table[
   {mLower[[A1, B1, C1]] === -mLower[[B1, A1, C1]],
    mLower[[A1, B1, C1]] === -mLower[[A1, C1, B1]]},
   {A1, 2, 8}, {B1, 2, 8}, {C1, 2, 8}];
cfAssert["m_{ABC} restricted to imaginary directions is totally antisymmetric",
  mImTotallyAntisymmetric];
Total[Abs[Flatten[mLower[[2 ;; 8, 2 ;; 8, 2 ;; 8]]]]]
]];

(* ---------- Input cell 53 ---------- *)
cfRunCell[53, Hold[
ClearAll[cfNotebookFile, cfDir, cfName, cfHeader, cfResolveFile];
cfNotebookFile = Quiet[NotebookFileName[]];
cfDir  = If[StringQ[cfNotebookFile], DirectoryName[cfNotebookFile], Directory[]];
cfName = If[StringQ[cfNotebookFile], FileBaseName[cfNotebookFile],
            "claude-fable_Einstein-Rosen-2-Planes"];
cfHeader = cfName <> "-";
{cfDir, cfName, cfHeader}
]];

(* ---------- Input cell 54 ---------- *)
cfRunCell[54, Hold[
(* --- look for a file next to the notebook, in the working directory, or one level down --- *)
cfResolveFile[name_String] := Module[{cands, hit},
  cands = DeleteDuplicates[{
     FileNameJoin[{cfDir, name}],
     FileNameJoin[{cfDir, "Pre-Universe_14SEP26-77", name}],
     FileNameJoin[{Directory[], name}],
     FileNameJoin[{Directory[], "Pre-Universe_14SEP26-77", name}],
     FileNameJoin[{ParentDirectory[Directory[]], name}]}];
  hit = SelectFirst[cands, FileExistsQ[#] &, $Failed];
  If[hit === $Failed,
    Print["  MISSING FILE  ", name];
    Print["                searched: ", Column[cands]];
    Print["                Put the file in one of those places and re-evaluate this cell."]];
  hit];
{cfResolveFile["ConvertMapleToMathematicaV2.wl"], cfResolveFile["EtoExp.wl"]}
]];

(* ---------- Input cell 55 ---------- *)
cfRunCell[55, Hold[
(* --- load them ------------------------------------------------------------------------- *)
ClearAll[cfMaplePath, cfEtoExpPath];
cfMaplePath  = cfResolveFile["ConvertMapleToMathematicaV2.wl"];
cfEtoExpPath = cfResolveFile["EtoExp.wl"];
If[StringQ[cfMaplePath],  Get[cfMaplePath],
   Print["  ConvertMapleToMathematicaV2 not loaded; Section 13 will report it again."]];
If[StringQ[cfEtoExpPath], Get[cfEtoExpPath],
   Print["  EtoExp not loaded.  Nothing in this notebook calls it, so nothing will fail;"];
   Print["  it is loaded only for parity with the original."]];
{ValueQ[cfMaplePath], ValueQ[cfEtoExpPath]}
]];

(* ---------- Input cell 56 ---------- *)
cfRunCell[56, Hold[
ClearAll[\[CapitalPsi]16, \[CapitalPsi]16upper, \[CapitalPsi]16lower, f16];
\[CapitalPsi]16 = Table[f16[k][x0, x4], {k, 0, 15}];
\[CapitalPsi]16upper = Take[\[CapitalPsi]16, 8];    (* type-1 split-octonion spinor *)
\[CapitalPsi]16lower = Take[\[CapitalPsi]16, -8];   (* type-2 split-octonion spinor *)
cfAssert["Psi16 is the direct sum of the type-1 and type-2 spinors",
  \[CapitalPsi]16 === Join[\[CapitalPsi]16upper, \[CapitalPsi]16lower]];
\[CapitalPsi]16
]];

(* ---------- Input cell 57 ---------- *)
cfRunCell[57, Hold[
(* --- the two re-parameterizations of the component functions ----------------------------- *)
ClearAll[sf\[Psi]16Aa, snewf\[Psi]16Aa, sreplaceZ, sreplacenZ, subsDefects];
sf\[Psi]16Aa =
  Table[f16[k] -> ToExpression["((Z[" <> ToString[k] <> "][6*H*#1,H*#2])&)"], {k, 0, 15}];
snewf\[Psi]16Aa =
  Table[f16[k] -> ToExpression[
     "((nZ[" <> ToString[k] <> "][6*H*#1,H*#2]/Sqrt[Sin[6*H*#1]])&)"], {k, 0, 15}];
sreplaceZ  = Table[Z[k]  -> ToExpression["Z"  <> ToString[k]], {k, 0, 15}];
sreplacenZ = Table[nZ[k] -> ToExpression["nZ" <> ToString[k]], {k, 0, 15}];
subsDefects = {};      (* the original's hook for patching defective components; empty *)
{sf\[Psi]16Aa[[1]], snewf\[Psi]16Aa[[1]], Length[sreplaceZ], subsDefects}
]];

(* ---------- Input cell 58 ---------- *)
cfRunCell[58, Hold[
ClearAll[La];
La[] := ((1/H) Transpose[\[CapitalPsi]16] . \[Sigma]16 .
          Sum[T16[\[Alpha]1 - 1] . D[\[CapitalPsi]16, X[[\[Alpha]1]]], {\[Alpha]1, 1, Length[X]}]
        + 2 (M/H) Transpose[\[CapitalPsi]16] . \[Sigma]16 . \[CapitalPsi]16
       ) // Simplify[#, constraintVars] &;
cfTimed["evaluate the Lagrangian La[]", La[]] // Short[#, 10] &
]];

(* ---------- Input cell 59 ---------- *)
cfRunCell[59, Hold[
(* --- the two exact identities behind the Lagrangian -------------------------------------- *)
cfAssert["Psi16 . sigma16 . T16[alpha] . Psi16 == 0 identically (antisymmetric form)",
  Table[Expand[Transpose[\[CapitalPsi]16] . \[Sigma]16 . T16[\[Alpha]1 - 1] . \[CapitalPsi]16] === 0,
    {\[Alpha]1, 1, 8}]];
cfAssert["the kinetic term equals minus its transpose, exactly",
  Expand[
    Transpose[\[CapitalPsi]16] . \[Sigma]16 .
      Sum[T16[\[Alpha]1 - 1] . D[\[CapitalPsi]16, X[[\[Alpha]1]]], {\[Alpha]1, 1, 8}]
    + Sum[D[Transpose[\[CapitalPsi]16], X[[\[Alpha]1]]] . \[Sigma]16 . T16[\[Alpha]1 - 1],
        {\[Alpha]1, 1, 8}] . \[CapitalPsi]16] === 0];
]];

(* ---------- Input cell 60 ---------- *)
cfRunCell[60, Hold[
(* --- so the Lagrangian and its "conjugate" form differ only in the mass coefficient ------ *)
(* The original's scratch cell compares La against a conjugate form written with 2 H M       *)
(* instead of 2 M/H and without the 1/H on the kinetic term, so its difference does not       *)
(* vanish.  Written with matching coefficients the difference is exactly zero.                *)
cfAssert["La[] == its conjugate form when the coefficients match",
  Simplify[La[] - (
     -(1/H) Sum[D[Transpose[\[CapitalPsi]16], X[[\[Alpha]1]]] . \[Sigma]16 . T16[\[Alpha]1 - 1],
        {\[Alpha]1, 1, 8}] . \[CapitalPsi]16
     + 2 (M/H) Transpose[\[CapitalPsi]16] . \[Sigma]16 . \[CapitalPsi]16),
   constraintVars] === 0];
]];

(* ---------- Input cell 61 ---------- *)
cfRunCell[61, Hold[
ClearAll[eL];
eL[Lagrangian_Symbol, detsqrt_] := Module[{L, t},
  L = Lagrangian[];
  t = Table[
    FullSimplify[
      (1/detsqrt) (
        D[L, f16[k][x0, x4]]
        - D[D[L, Derivative[1, 0][f16[k]][x0, x4]], x0]
        - D[D[L, Derivative[0, 1][f16[k]][x0, x4]], x4]),
      constraintVars],
    {k, 0, 15}];
  Return[t /. subsDefects];
];
]];

(* ---------- Input cell 62 ---------- *)
cfRunCell[62, Hold[
(* --- the sixteen field equations --------------------------------------------------------- *)
ClearAll[eLa];
eLa = cfTimed["Euler-Lagrange equations eLa = eL[La, 1]", eL[La, 1]];
cfAssert["there are sixteen field equations", Length[eLa] === 16];
Column[eLa]
]];

(* ---------- Input cell 63 ---------- *)
cfRunCell[63, Hold[
(* --- which components are coupled to which ----------------------------------------------- *)
(* rawSets collects, for each equation, the set of component indices that appear in it.       *)
(* MergeSetsStep merges any two sets that intersect; iterating it to a fixed point gives the  *)
(* partition of the sixteen components into independent blocks.                               *)
ClearAll[rawSets, MergeSetsStep, showCoupledEquations];
rawSets[l_, f_, o_: 0] := Table[
   Cases[l[[j]], h_Symbol[n_Integer] /; StringEndsQ[SymbolName[h], f] :> n + o,
     Infinity, Heads -> True],
   {j, 1, Length[l]}];
MergeSetsStep[currentSets_List] := Module[{i, j, merged = currentSets},
  Catch[
   For[i = 1, i <= Length[merged], i++,
    For[j = i + 1, j <= Length[merged], j++,
     If[Intersection[merged[[i]], merged[[j]]] =!= {},
      merged = Delete[merged, {{i}, {j}}];
      AppendTo[merged, Sort[Union[currentSets[[i]], currentSets[[j]]]]];
      Throw[Sort[merged]]]]];
   Sort[merged]]];
showCoupledEquations[items_List] := FixedPoint[MergeSetsStep, items];
]];

(* ---------- Input cell 64 ---------- *)
cfRunCell[64, Hold[
ClearAll[eLaRawSets, eLaCouplings];
eLaRawSets = rawSets[eLa, "f16", 0];
eLaCouplings = cfTimed["partition the 16 components into coupled blocks",
  showCoupledEquations[eLaRawSets]];
cfAssert["the coupled blocks partition all sixteen components",
  Sort[Flatten[eLaCouplings]] === Range[0, 15]];
cfAssert["there are four blocks of four",
  Length /@ eLaCouplings === {4, 4, 4, 4}];
eLaCouplings
]];

(* ---------- Input cell 65 ---------- *)
cfRunCell[65, Hold[
(* --- save the equations, exactly as the original does ------------------------------------ *)
ClearAll[$cfWriteMX];
$cfWriteMX = True;
If[$cfWriteMX,
  DumpSave[FileNameJoin[{cfDir, cfHeader <> "eLa.mx"}], eLa];
  Print["wrote ", FileNameJoin[{cfDir, cfHeader <> "eLa.mx"}]]];
]];

(* ---------- Input cell 66 ---------- *)
cfRunCell[66, Hold[
ClearAll[eLazt];
eLazt = cfTimed["change of chart: eLazt = (1/(2H)) eLa in the (z,t) coordinates",
  ((1/(2 H)) eLa /. sf\[Psi]16Aa /. sx0x4) // FullSimplify[#, constraintVars] &];
If[$cfWriteMX,
  DumpSave[FileNameJoin[{cfDir, cfHeader <> "eLazt.mx"}], eLazt];
  Print["wrote ", FileNameJoin[{cfDir, cfHeader <> "eLazt.mx"}]]];
Column[eLazt]
]];

(* ---------- Input cell 67 ---------- *)
cfRunCell[67, Hold[
ClearAll[varZ, varZzt, DzvarZ, DtvarZ];
varZ = Table[Z[k], {k, 0, 15}];
varZzt = Through[varZ[z, t]];
DzvarZ = D[varZzt, z];
DtvarZ = D[varZzt, t];
{Short[varZzt, 3], Short[DtvarZ, 3]}
]];

(* ---------- Input cell 68 ---------- *)
cfRunCell[68, Hold[
(* --- solve the system for the t-derivatives ---------------------------------------------- *)
ClearAll[DtvarZsubs, DtvarZEQS, DtvarZrelations];
DtvarZsubs = cfTimed["solve the 16 equations for the t-derivatives",
  Solve[And @@ Thread[0 == eLazt], DtvarZ][[1]] // FullSimplify[#, constraintVars] &];
DtvarZEQS = DtvarZsubs /. {Rule -> Equal};
DtvarZrelations = DtvarZsubs /. {Rule -> Subtract};
cfAssert["all sixteen t-derivatives are determined", Length[DtvarZsubs] === 16];
Column[DtvarZsubs]
]];

(* ---------- Input cell 69 ---------- *)
cfRunCell[69, Hold[
(* --- the relabelling, and its inverse ---------------------------------------------------- *)
ClearAll[yZdef, Zdef, sZtOyZ, syZtoZ, zeroZyZforCaExpression, zeroZyZEQS];
yZdef = Table[yZ[k], {k, 0, 15}];
Zdef  = Table[Z[k],  {k, 0, 15}];
sZtOyZ = Table[Z[Flatten[eLaCouplings][[j]]] -> yZ[j - 1], {j, 1, 16}];
syZtoZ = Solve[And @@ (sZtOyZ /. {Rule -> Equal}), yZdef][[-1]];
zeroZyZforCaExpression = -(sZtOyZ /. {Rule -> Subtract});
zeroZyZEQS = sZtOyZ /. {Rule -> Equal};
cfAssert["the relabelling is a bijection of the sixteen components",
  Sort[sZtOyZ[[All, 1]]] === Sort[Zdef] && Sort[sZtOyZ[[All, 2]]] === Sort[yZdef]];
Column[sZtOyZ]
]];

(* ---------- Input cell 70 ---------- *)
cfRunCell[70, Hold[
(* --- the equations in the new labels, and the four 4x4 blocks ---------------------------- *)
ClearAll[eLyZ, DtyZsubsA, DtvaryZEQS, zeroDtyZeqs, coupledyZeqs];
eLyZ = cfTimed["relabel the equations", (eLazt /. sZtOyZ) // FullSimplify];
DtyZsubsA = cfTimed["solve the relabelled system for the t-derivatives",
  Solve[And @@ Thread[0 == eLyZ], D[Through[yZdef[z, t]], t]][[1]] //
    FullSimplify[#, constraintVars] &];
DtvaryZEQS = DtyZsubsA /. {Rule -> Equal};
zeroDtyZeqs = DtyZsubsA /. {Rule -> Subtract};
coupledyZeqs = Partition[DtvaryZEQS, 4];
cfAssert["the system splits into four blocks of four equations",
  Dimensions[coupledyZeqs] === {4, 4}];
Column[coupledyZeqs]
]];

(* ---------- Input cell 71 ---------- *)
cfRunCell[71, Hold[
(* --- each block really is closed: block j mentions only yZ[4(j-1)] .. yZ[4(j-1)+3] -------- *)
cfAssert["each 4x4 block is closed in its own four components",
  Table[SubsetQ[Range[4 (blk - 1), 4 (blk - 1) + 3],
     Union@Cases[coupledyZeqs[[blk]], yZ[n_Integer] :> n, Infinity, Heads -> True]],
    {blk, 1, 4}]];
Table[Union@Cases[coupledyZeqs[[blk]], yZ[n_Integer] :> n, Infinity, Heads -> True],
  {blk, 1, 4}]
]];

(* ---------- Input cell 72 ---------- *)
cfRunCell[72, Hold[
ClearAll[yZvar, cfDSolveTry, dsolveResults];
yZvar = Through[yZdef[z, t]];
cfDSolveTry[blk_Integer, seconds_: 60] := Module[{r},
  r = TimeConstrained[
     Quiet@Check[DSolve[coupledyZeqs[[blk]], yZvar[[4 (blk - 1) + 1 ;; 4 blk]], {z, t}],
       $cfDSolveFailed],
     seconds, $cfDSolveTimedOut];
  Print["  block ", blk, ": ",
    Which[r === $cfDSolveTimedOut, "TIMED OUT",
          r === $cfDSolveFailed, "DSolve reported an error",
          MatchQ[r, _DSolve], "returned unevaluated",
          r === {}, "no solution found",
          True, "closed form with " <> ToString[Length[r]] <> " branch(es)"]];
  r];
dsolveResults = cfTimed["DSolve on the four blocks", Table[cfDSolveTry[blk], {blk, 1, 4}]];
Short[dsolveResults, 8]
]];

(* ---------- Input cell 73 ---------- *)
cfRunCell[73, Hold[
ClearAll[maplestringEQ1, maplestringEQ2, maplestringEQ3, maplestringEQ4];
maplestringEQ1 = "{{yZ0(z, t) = exp((6*(z/6 + t)*H^2*C1^2 - 6*(-z/6 + t)*M^2)/(6*C1*H^2))*(H^2*(c11*c12 - c13*c14)*C1^2 - M^2*(c11*c12 + c13*c14))/(2*H*C1*M), yZ1(z, t) = -((H^2*(c11*c12 - c13*c14)*C1^2 + M^2*(c11*c12 + c13*c14))*exp((6*(z/6 + t)*H^2*C1^2 - 6*(-z/6 + t)*M^2)/(6*C1*H^2)))/(2*H*C1*M), yZ2(z, t) = c13*exp((6*(z/6 + t)*H^2*C1^2 - 6*(-z/6 + t)*M^2)/(6*C1*H^2))*c14, yZ3(z, t) = c11*exp((6*(z/6 + t)*H^2*C1^2 - 6*(-z/6 + t)*M^2)/(6*C1*H^2))*c12}}";
maplestringEQ2 = "{{yZ4(z, t) = -exp((6*(z/6 + t)*H^2*C2^2 - 6*(-z/6 + t)*M^2)/(6*C2*H^2))*(H^2*(c21*c22 + c23*c24)*C2^2 - M^2*(c21*c22 - c23*c24))/(2*H*C2*M), yZ5(z, t) = -((H^2*(c21*c22 + c23*c24)*C2^2 + M^2*(c21*c22 - c23*c24))*exp((6*(z/6 + t)*H^2*C2^2 - 6*(-z/6 + t)*M^2)/(6*C2*H^2)))/(2*H*C2*M), yZ6(z, t) = c23*exp((6*(z/6 + t)*H^2*C2^2 - 6*(-z/6 + t)*M^2)/(6*C2*H^2))*c24, yZ7(z, t) = c21*exp((6*(z/6 + t)*H^2*C2^2 - 6*(-z/6 + t)*M^2)/(6*C2*H^2))*c22}}";
maplestringEQ3 = "{{yZ10(z, t) = c33*exp((6*H^2*(z/6 + t)*C3^2 - 6*(-z/6 + t)*M^2)/(6*C3*H^2))*c34, yZ11(z, t) = c31*exp((6*H^2*(z/6 + t)*C3^2 - 6*(-z/6 + t)*M^2)/(6*C3*H^2))*c32, yZ8(z, t) = -exp((6*H^2*(z/6 + t)*C3^2 - 6*(-z/6 + t)*M^2)/(6*C3*H^2))*(H^2*(c31*c32 + c33*c34)*C3^2 - M^2*(c31*c32 - c33*c34))/(2*H*C3*M), yZ9(z, t) = -((H^2*(c31*c32 + c33*c34)*C3^2 + M^2*(c31*c32 - c33*c34))*exp((6*H^2*(z/6 + t)*C3^2 - 6*(-z/6 + t)*M^2)/(6*C3*H^2)))/(2*H*C3*M)}}";
maplestringEQ4 = "{{yZ12(z, t) = exp((6*H^2*(z/6 + t)*C4^2 - 6*(-z/6 + t)*M^2)/(6*C4*H^2))*(H^2*(c41*c42 - c43*c44)*C4^2 - M^2*(c41*c42 + c43*c44))/(2*H*C4*M), yZ13(z, t) = -((H^2*(c41*c42 - c43*c44)*C4^2 + M^2*(c41*c42 + c43*c44))*exp((6*H^2*(z/6 + t)*C4^2 - 6*(-z/6 + t)*M^2)/(6*C4*H^2)))/(2*H*C4*M), yZ14(z, t) = c43*exp((6*H^2*(z/6 + t)*C4^2 - 6*(-z/6 + t)*M^2)/(6*C4*H^2))*c44, yZ15(z, t) = c41*exp((6*H^2*(z/6 + t)*C4^2 - 6*(-z/6 + t)*M^2)/(6*C4*H^2))*c42}}";
StringLength /@ {maplestringEQ1, maplestringEQ2, maplestringEQ3, maplestringEQ4}
]];

(* ---------- Input cell 74 ---------- *)
cfRunCell[74, Hold[
(* --- parse them ------------------------------------------------------------------------- *)
ClearAll[solvedEQ, YZvar, sYZvar];
If[! StringQ[cfMaplePath],
  Print["  CANNOT PARSE THE MAPLE SOLUTIONS: ConvertMapleToMathematicaV2.wl was not found."];
  Print["  Nothing is substituted for it.  Place the file next to this notebook and re-run."]];
solvedEQ = Table[ConvertMapleToMathematicaV2[
    {maplestringEQ1, maplestringEQ2, maplestringEQ3, maplestringEQ4}[[j]]], {j, 1, 4}];
YZvar = Table[ToExpression["YZ" <> ToString[k] <> "[z,t]"], {k, 0, 15}];
sYZvar = Solve[And @@ Flatten[solvedEQ], YZvar][[1]];
cfAssert["all sixteen components have a closed form", Length[sYZvar] === 16];
Column[sYZvar]
]];

(* ---------- Input cell 75 ---------- *)
cfRunCell[75, Hold[
(* --- turn them into pure functions for yZ ------------------------------------------------ *)
ClearAll[ssyZ];
ssyZ = Table[
   yZ[k] -> ToExpression["((" <> ToString[FullForm[sYZvar[[k + 1, 2]] /. {z -> #1, t -> #2}]] <> ")&)"],
   {k, 0, 15}];
cfAssert["there are sixteen pure-function rules", Length[ssyZ] === 16];
Short[ssyZ, 6]
]];

(* ---------- Input cell 76 ---------- *)
cfRunCell[76, Hold[
(* --- VERIFY the Maple solutions against the four blocks ---------------------------------- *)
(* This is the cell that certifies Section 13.  Every one of the sixteen equations must       *)
(* reduce to True after the closed forms are substituted.                                     *)
ClearAll[cfMapleCheck];
cfMapleCheck = cfTimed["substitute the closed forms back into the four blocks",
  Table[FullSimplify[coupledyZeqs[[blk]] /. ssyZ], {blk, 1, 4}]];
cfAssert["THE MAPLE CLOSED FORMS SOLVE ALL SIXTEEN EQUATIONS",
  Union[Flatten[cfMapleCheck]] === {True}];
cfMapleCheck
]];

(* ---------- Input cell 77 ---------- *)
cfRunCell[77, Hold[
(* --- back to the original labels, and to Psi16 ------------------------------------------- *)
ClearAll[sZ, \[CapitalPsi]16a];
sZ = Sort[sZtOyZ /. ssyZ];
\[CapitalPsi]16a = cfTimed["Psi16 with the closed forms substituted",
  (\[CapitalPsi]16 /. sf\[Psi]16Aa /. sx0x4 /. sZ /. szt) // FullSimplify];
Column[\[CapitalPsi]16a]
]];

(* ---------- Input cell 78 ---------- *)
cfRunCell[78, Hold[
ClearAll[cayZ, caZ, caZ2, almightyS];
cayZ = CoefficientArrays[zeroZyZforCaExpression, yZdef];
caZ  = CoefficientArrays[zeroZyZforCaExpression, Zdef];
caZ2 = Normal[caZ[[2]]];
almightyS = -Transpose[caZ2];
cfAssert["the yZ coefficient matrix is the identity", Normal[cayZ[[2]]] === ID16];
cfAssert["ORTHOGONAL: Transpose[S] . S == ID16", Transpose[almightyS] . almightyS === ID16];
cfAssert["ORTHOGONAL: S . Transpose[S] == ID16", almightyS . Transpose[almightyS] === ID16];
cfAssert["but NOT a O(8,8) transformation: it does not preserve sigma16",
  Transpose[almightyS] . \[Sigma]16 . almightyS =!= \[Sigma]16];
cfAssert["and NOT a direct sum: it mixes type-1 with type-2",
  caZ2 =!= ArrayFlatten[{{caZ2[[1 ;; 8, 1 ;; 8]], 0}, {0, caZ2[[9 ;; 16, 9 ;; 16]]}}]];
MatrixForm[caZ2]
]];

(* ---------- Input cell 79 ---------- *)
cfRunCell[79, Hold[
ClearAll[sztar, sszt, ztadv, ztret];
sztar = Solve[ztadv == 6 t + z && ztret == 6 t - z, {ztadv, ztret}][[1]];
sszt  = Solve[ztadv == 6 t + z && ztret == 6 t - z, {z, t}][[1]];
{sztar, sszt}
]];

(* ---------- Input cell 80 ---------- *)
cfRunCell[80, Hold[
(* --- the five bilinears ------------------------------------------------------------------ *)
ClearAll[\[Psi]sol, \[Psi]1sol, \[Psi]2sol, psiSigma16psi, psi1Sigmapsi1, psi2Sigmapsi2,
         psi2psi1, psi2Sigmapsi1];
\[Psi]sol  = Through[yZdef[z, t]] /. ssyZ;
\[Psi]1sol = \[Psi]sol[[1 ;; 8]];
\[Psi]2sol = \[Psi]sol[[9 ;; 16]];
(* The split at 8 is a split of the yZ COUPLING blocks, NOT of the type-1/type-2 direct sum.   *)
(* Section 13 proved the relabelling mixes the two types; these two assertions say exactly how, *)
(* so that the names psi1sol/psi2sol cannot be misread as the split-octonion halves.            *)
cfAssert["the yZ split at 8 is NOT the type-1/type-2 split",
  Sort[sZtOyZ[[1 ;; 8, 1]]] =!= Sort[Table[Z[k], {k, 0, 7}]]];
cfAssert["the first relabelled block holds four type-1 and four type-2 components",
  {Count[sZtOyZ[[1 ;; 8, 1]], Z[k_Integer] /; k <= 7],
   Count[sZtOyZ[[1 ;; 8, 1]], Z[k_Integer] /; k >= 8]} === {4, 4}];
(* FullSimplify::time is EXPECTED on two of these five bilinears: Section 1 set the original    *)
(* notebook's 3-second FullSimplify budget and these expressions exceed it.  FullSimplify then  *)
(* returns the best form it reached, which is correct but not maximally simplified, so the      *)
(* message is informational.  It is suppressed here and only here, and announced first.         *)
Print["  EXPECTED MESSAGE  FullSimplify::time may fire on the bilinears; the 3-second budget"];
Print["                    set in Section 1 is the original notebook's, and a budget that is"];
Print["                    reached still returns a correct, merely less-simplified, result."];
psiSigma16psi  = cfTimed["bilinear psi . sigma16 . psi",
   Quiet[\[Psi]sol . \[Sigma]16 . \[Psi]sol // FullSimplify[#, constraintVars] &,
     {FullSimplify::time, General::stop}]];
psi1Sigmapsi1  = cfTimed["bilinear psi1 . sigma . psi1",
   Quiet[\[Psi]1sol . \[Sigma] . \[Psi]1sol // FullSimplify[#, constraintVars] &,
     {FullSimplify::time, General::stop}]];
psi2Sigmapsi2  = cfTimed["bilinear psi2 . sigma . psi2",
   Quiet[\[Psi]2sol . \[Sigma] . \[Psi]2sol // FullSimplify[#, constraintVars] &,
     {FullSimplify::time, General::stop}]];
psi2psi1       = cfTimed["bilinear psi2 . psi1",
   Quiet[\[Psi]2sol . \[Psi]1sol // FullSimplify[#, constraintVars] &,
     {FullSimplify::time, General::stop}]];
psi2Sigmapsi1  = cfTimed["bilinear psi2 . sigma . psi1",
   Quiet[\[Psi]2sol . \[Sigma] . \[Psi]1sol // FullSimplify[#, constraintVars] &,
     {FullSimplify::time, General::stop}]];
(* sigma16 == ArrayFlatten[{{-sigma,0},{0,sigma}}], so the 16-component norm is the DIFFERENCE  *)
(* of the two 8-component norms.  Note that sigma16 itself is SYMMETRIC, so this bilinear does  *)
(* not vanish; it is sigma16 . T16[A] that is antisymmetric, which is what made the kinetic     *)
(* term of Section 11 self-adjoint.                                                             *)
cfAssert["psi . sigma16 . psi == psi2.sigma.psi2 - psi1.sigma.psi1",
  Simplify[psiSigma16psi - (psi2Sigmapsi2 - psi1Sigmapsi1), constraintVars] === 0];
(* This notebook used to describe psi . sigma16 . psi as "identically zero, as Section 11       *)
(* showed".  That was wrong on both counts and is corrected here.  Section 11's identity is     *)
(* psi . sigma16 . T16[alpha] . psi == 0, with the T16 factor.  Without it the form is          *)
(* symmetric, so nothing forces the bilinear to vanish -- and it does not.                       *)
cfAssert["sigma16 alone is SYMMETRIC, so psi . sigma16 . psi is not forced to vanish",
  Transpose[\[Sigma]16] === \[Sigma]16];
cfAssert["and for this solution it does NOT vanish: it is not the zero expression",
  Simplify[psiSigma16psi, constraintVars] =!= 0];
Column[{psiSigma16psi, psi1Sigmapsi1, psi2Sigmapsi2, psi2psi1, psi2Sigmapsi1}]
]];

(* ---------- Input cell 81 ---------- *)
cfRunCell[81, Hold[
(* --- demanding that the two norms be light-cone constants fixes C2 and C4 ---------------- *)
ClearAll[cfNormDerivs, cfConstantSolutions];
cfNormDerivs = Union@Flatten@Table[
    {Simplify[D[b /. sszt, ztadv], constraintVars],
     Simplify[D[b /. sszt, ztret], constraintVars]},
    {b, {psi1Sigmapsi1, psi2Sigmapsi2}}];
(* Solve::ifun and Solve::svars are EXPECTED here.  The conditions are transcendental in the    *)
(* block constants, so Solve inverts an exponential (ifun) and does not determine every one of  *)
(* the four constants (svars) -- a one-parameter family survives, which is the point.  The      *)
(* branch that Solve returns is verified independently in the next cell.                         *)
Print["  EXPECTED MESSAGES  Solve::ifun and Solve::svars: the light-cone conditions are"];
Print["                     transcendental and leave a family of solutions, not a unique one."];
cfConstantSolutions = Quiet[Solve[And @@ Thread[0 == cfNormDerivs], {C1, C2, C3, C4}],
   {Solve::ifun, Solve::svars}];
cfAssert["the light-cone-constant condition has solutions", cfConstantSolutions =!= {}];
{cfNormDerivs, cfConstantSolutions}
]];

(* ---------- Input cell 82 ---------- *)
cfRunCell[82, Hold[
(* --- the original's branch: C2 -> -C1 and C4 -> -C3 -------------------------------------- *)
ClearAll[cfBranch, cfBilinearsOnBranch];
cfBranch = {C2 -> -C1, C4 -> -C3};
cfBilinearsOnBranch = Simplify[
   {psiSigma16psi, psi1Sigmapsi1, psi2Sigmapsi2, psi2Sigmapsi1} /. sszt /. cfBranch,
   constraintVars];
cfAssert["on the branch C2 = -C1, C4 = -C3 the two norms are independent of ztadv and ztret",
  Flatten@Table[Simplify[{D[b, ztadv], D[b, ztret]}, constraintVars] === {0, 0},
    {b, cfBilinearsOnBranch[[2 ;; 3]]}]];
Column[cfBilinearsOnBranch]
]];

(* ---------- Input cell 83 ---------- *)
cfRunCell[83, Hold[
(* --- the two mass branches of the original notebook -------------------------------------- *)
(* Psi16ab keeps a free dimensionless mass ratio Mab; Psi16aa is the special case Mab = 1.    *)
ClearAll[\[CapitalPsi]16ab, \[CapitalPsi]16aa, \[CapitalPsi]16x0ONLY];
\[CapitalPsi]16ab = cfTimed["Psi16ab  (M -> H Mab Sqrt[C1 C3])",
  (\[CapitalPsi]16a /. sf\[Psi]16Aa /. sx0x4 /. sZ /. szt
     /. {C2 -> -C1, C4 -> -C3, M -> H Mab Sqrt[C1 C3]}) // FullSimplify];
\[CapitalPsi]16aa = cfTimed["Psi16aa  (M -> H Sqrt[C1 C3])",
  (\[CapitalPsi]16a /. sf\[Psi]16Aa /. sx0x4 /. sZ /. szt
     /. {C2 -> -C1, C4 -> -C3, M -> H Sqrt[C1 C3]}) // FullSimplify];
\[CapitalPsi]16x0ONLY = cfTimed["Psi16x0ONLY  (C3 -> C1)",
  (\[CapitalPsi]16aa /. {C3 -> C1}) // FullSimplify[#, C1 > 0] &];
Column[{Short[\[CapitalPsi]16ab, 6], Short[\[CapitalPsi]16aa, 6], Short[\[CapitalPsi]16x0ONLY, 6]}]
]];

(* ---------- Input cell 84 ---------- *)
cfRunCell[84, Hold[
(* --- advanced and retarded coordinates in the (x0,x4) chart ------------------------------ *)
ClearAll[s\[Xi], ssx0x4, \[Xi]adv, \[Xi]ret];
s\[Xi]   = Solve[\[Xi]adv == x0 - x4 && \[Xi]ret == x0 + x4, {\[Xi]adv, \[Xi]ret}][[1]];
ssx0x4 = Solve[\[Xi]adv == x0 - x4 && \[Xi]ret == x0 + x4, {x0, x4}][[1]];
{s\[Xi], ssx0x4}
]];

(* ---------- Input cell 85 ---------- *)
cfRunCell[85, Hold[
(* --- the two split-octonion spinors of the solution -------------------------------------- *)
ClearAll[\[Psi]1, \[Psi]2, type1DIVBYtype2, realPartOfType1, realPartOfType2];
\[Psi]1 = FullSimplify[\[CapitalPsi]16ab[[1 ;; 8]]];
\[Psi]2 = FullSimplify[\[CapitalPsi]16ab[[9 ;; 16]]];
type1DIVBYtype2 = FullSimplify[\[CapitalPsi]16ab[[1 ;; 8]]/\[CapitalPsi]16ab[[9 ;; 16]]];
realPartOfType1 = FullSimplify[unit . \[Psi]1];
realPartOfType2 = FullSimplify[unit . \[Psi]2];
Column[{Short[\[Psi]1, 4], Short[\[Psi]2, 4], Short[type1DIVBYtype2, 4],
        realPartOfType1, realPartOfType2}]
]];

(* ---------- Input cell 86 ---------- *)
cfRunCell[86, Hold[
ClearAll[vectorFormOfType1, vectorFormOfType2];
(* triVecToSpin[[A,a]]: vector row, spinor column.  It maps a column SPINOR to a VECTOR from  *)
(* the left; triSpinToVec does the reverse and acts on a ROW spinor from the right.           *)
vectorFormOfType2 = FullSimplify[triVecToSpin . \[Psi]2];
vectorFormOfType1 = FullSimplify[\[Eta]4488 . (Transpose[\[Psi]1] . \[Sigma] . triSpinToVec)];
cfAssert["both triality vectors have eight components",
  {Length[vectorFormOfType1], Length[vectorFormOfType2]} === {8, 8}];
(* the index placement is not arbitrary: each bridge must be used on its own side *)
cfAssert["vectorFormOfType2 == psi2 contracted on the SPINOR index of triVecToSpin",
  Simplify[vectorFormOfType2
     - Table[Sum[triVecToSpin[[A1, a1]] \[Psi]2[[a1]], {a1, 8}], {A1, 8}]] ===
   ConstantArray[0, 8]];
cfAssert["triVecToSpin and triSpinToVec really are mutually inverse",
  triVecToSpin . triSpinToVec === ID8];
Column[{Short[vectorFormOfType1, 5], Short[vectorFormOfType2, 5]}]
]];

(* ---------- Input cell 87 ---------- *)
cfRunCell[87, Hold[
(* --- the two 7-planes ------------------------------------------------------------------- *)
ClearAll[Zoct, zoct, sz8, sz7, sevenPlane1, sevenPlane2];
Zoct = Array[zoct, 8];
sz8 = FullSimplify[Solve[0 == vectorFormOfType2 . Zoct, zoct[8]][[-1]]];
sz7 = Simplify[Solve[0 == vectorFormOfType1 . Zoct, zoct[7]][[-1]]];
sevenPlane2 = Zoct /. sz8;
sevenPlane1 = Zoct /. sz7;
cfAssert["sevenPlane2 is annihilated by vectorFormOfType2",
  Simplify[vectorFormOfType2 . sevenPlane2] === 0];
cfAssert["sevenPlane1 is annihilated by vectorFormOfType1",
  Simplify[vectorFormOfType1 . sevenPlane1] === 0];
Column[{Short[sevenPlane1, 5], Short[sevenPlane2, 5]}]
]];

(* ---------- Input cell 88 ---------- *)
cfRunCell[88, Hold[
(* --- and their intersection, the 6-plane M6 ---------------------------------------------- *)
ClearAll[sixPlane78, M6];
(* Solve::svars is EXPECTED here and is in fact the result we want: intersecting two 7-planes  *)
(* in an 8-space determines only TWO of the eight components and leaves SIX free.  That is the  *)
(* 6-plane M6.  The free-parameter count is asserted immediately below.                          *)
Print["  EXPECTED MESSAGE  Solve::svars: two 7-planes fix only two of the eight components,"];
Print["                    leaving the six free parameters of M6."];
sixPlane78 = cfTimed["intersect the two 7-planes",
  Simplify[Quiet[Solve[And @@ Thread[sevenPlane1 == sevenPlane2], Zoct], {Solve::svars}]]];
M6 = cfTimed["M6 in advanced / retarded coordinates",
  Simplify[Zoct /. sixPlane78 /. ssx0x4 /. s\[Xi]]];
cfAssert["M6 is a non-empty solution set", sixPlane78 =!= {}];
cfAssert["M6 has six free parameters",
  Length[Complement[Array[zoct, 8], First[sixPlane78][[All, 1]]]] === 6];
{Short[sixPlane78, 8], Short[M6, 8]}
]];

(* ---------- Input cell 89 ---------- *)
cfRunCell[89, Hold[
(* --- the free directions of M6, i.e. the six parameters that survive --------------------- *)
Grid[Prepend[
  Table[{zoct[j],
     If[MemberQ[First[sixPlane78][[All, 1]], zoct[j]], "determined", "free parameter"]},
    {j, 1, 8}], {"component", "status"}], Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 90 ---------- *)
cfRunCell[90, Hold[
ClearAll[cfResolution];
cfResolution[v_List] := Module[{u, EAa, EaA, FaA},
  If[Length[v] =!= 8,
    Print["  ERROR  cfResolution expects a length-8 spinor; got ", Length[v]];
    Return[$Failed]];
  If[Simplify[Transpose[v] . \[Sigma] . v] === 0,
    Print["  ERROR  cfResolution needs a spinor of non-zero sigma-norm"];
    Return[$Failed]];
  u   = FullSimplify[v/Sqrt[Abs[Transpose[v] . \[Sigma] . v]]];
  EAa = Table[u . \[Sigma] . \[Tau]bar[A1], {A1, 0, 7}];
  EaA = FullSimplify[Inverse[EAa]];
  FaA = FullSimplify[Transpose[Table[\[Eta]4488[[A1 + 1, A1 + 1]] (\[Tau][A1] . u), {A1, 0, 7}]]];
  <|"EAa" -> EAa, "EaA" -> EaA, "FaA" -> FaA,
    "closedFormMatchesInverse" -> (FullSimplify[FaA - EaA] === Zero8),
    "bridgesAreInverse" -> (FullSimplify[EAa . EaA] === ID8)|>];
ClearAll[cfResolutionUnit];
cfResolutionUnit = cfResolution[unit];
cfAssert["cfResolution[unit]: the closed-form bridge equals the matrix inverse",
  cfResolutionUnit["closedFormMatchesInverse"]];
cfAssert["cfResolution[unit]: the two bridges are mutually inverse",
  cfResolutionUnit["bridgesAreInverse"]];
cfAssert["cfResolution[unit] reproduces triVecToSpin",
  cfResolutionUnit["EAa"] === triVecToSpin];
Keys[cfResolutionUnit]
]];

(* ---------- Input cell 91 ---------- *)
cfRunCell[91, Hold[
(* --- a notice helper, used whenever we meet a symbol the original never defines ---------- *)
ClearAll[cfNote];
cfNote[title_String, body_String] := (
  Print["  NOTE  ", title];
  Print["        ", body];
  Style[Column[{Style[title, Bold], body}], Background -> LightYellow]);
]];

(* ---------- Input cell 92 ---------- *)
cfRunCell[92, Hold[
(* --- HARD REQUIREMENT: report, do not invent, every symbol the original leaves undefined -- *)
cfNote["a4 is an undefined scalar function inherited from the original notebook",
 "The canonical frame field below contains Exp[-a4[H x4]] and Exp[+a4[H x4]].  The original \
notebook never gives a4 a definition; it appears only inside the recorded value of the frame \
field.  We therefore carry a4 through symbolically and we do NOT invent a value for it.  Every \
result in Parts III and IV is valid for an arbitrary differentiable a4.  The same applies to \
la, which occurs only inside the assumption ssX of Section 2."];
]];

(* ---------- Input cell 93 ---------- *)
cfRunCell[93, Hold[
ClearAll[cfQminus, cfQplus, frameCanonical, coframeCanonical, gCanonical, gInvCanonical];
cfQminus = Exp[-a4[H x4]]/Sin[6 H x0]^(1/6);
cfQplus  = Exp[+a4[H x4]]/Sin[6 H x0]^(1/6);
frameCanonical = DiagonalMatrix[{Tan[6 H x0],
    cfQminus, cfQminus, cfQminus, 1, cfQplus, cfQplus, cfQplus}];
MatrixForm[frameCanonical]
]];

(* ---------- Input cell 94 ---------- *)
cfRunCell[94, Hold[
(* --- assumptions used by every Simplify in Parts III and IV ------------------------------ *)
(* These are the original notebook's assumptions ssX, unchanged. *)
ClearAll[cfGeomAssume, cfSimp, cfSimpArray];
cfGeomAssume = ssX;
cfSimp[expr_] := Simplify[expr, cfGeomAssume];
(* The level specification matters.  Map[f, arr, {-1}] would map f over the ATOMS of arr --  *)
(* the bare symbols and integers buried inside each entry -- and would leave every compound  *)
(* entry untouched, making this function a silent no-op.  ArrayDepth[arr] is the level of    *)
(* the entries themselves: 2 for a matrix, 3 for a connection, 4 for a curvature 2-form.     *)
cfSimpArray[arr_] := Map[If[# === 0, 0, cfSimp[#]] &, arr, {ArrayDepth[arr]}];
{cfGeomAssume,
 (* a one-line self-test of the level specification *)
 cfSimpArray[{{Sin[x0]^2 + Cos[x0]^2 - 1, 0}}] === {{0, 0}}}
]];

(* ---------- Input cell 95 ---------- *)
cfRunCell[95, Hold[
ClearAll[cfProbeRules, cfProbePoints, cfZeroQ, cfZeroArrayQ,
         $cfNumericCertificates, $cfNonVanishingWitnesses];
$cfNumericCertificates   = 0;   (* stage 3 said "yes, zero"  -- an identity taken on numerics *)
$cfNonVanishingWitnesses = 0;   (* stage 3 said "no, non-zero" -- a witness of non-vanishing  *)
(* probe functions: TEST INPUTS ONLY, never definitions *)
cfProbeRules = {
  a4 -> Function[u, 3/7 + u/5 + Sin[u]/11],
  cfBoostRapidity -> Function[{u, v}, u/3 - 2 v/5 + Sin[u + v]/7]};
(* sample points chosen inside the assumed domain: H>0, x>0 and 0 < 6 H x0 < Pi/2 *)
cfProbePoints = {
  {H -> 1/10, x0 -> 1/4, x1 -> 1/3, x2 -> 2/5, x3 -> 3/7, x4 -> 1/2, x5 -> 5/9, x6 -> 4/7,
   x7 -> 6/11, \[Lambda]Oct -> 7/13},
  {H -> 1/7,  x0 -> 1/5, x1 -> 2/7, x2 -> 1/6, x3 -> 5/8, x4 -> 2/3, x5 -> 3/8, x6 -> 7/9,
   x7 -> 1/4,  \[Lambda]Oct -> -3/5},
  {H -> 2/9,  x0 -> 1/8, x1 -> 3/5, x2 -> 4/9, x3 -> 1/2, x4 -> 3/4, x5 -> 2/5, x6 -> 1/3,
   x7 -> 5/7,  \[Lambda]Oct -> 11/4}};
cfProbePoints[[All, 1]]
]];

(* ---------- Input cell 96 ---------- *)
cfRunCell[96, Hold[
(* --- the three-stage zero test --------------------------------------------------------- *)
(* cfNumericallyZeroQ is stage 3.  N::meprec is the expected signal that an expression is    *)
(* identically zero, so it is suppressed here and ONLY here; Chop makes the decision.        *)
ClearAll[cfNumericallyZeroQ];
cfNumericallyZeroQ[expr_] := Block[{$MaxExtraPrecision = 200},
  AllTrue[cfProbePoints,
    Function[pt,
     TrueQ[Max[Abs[Quiet[Chop[N[Flatten[{expr}] /. cfProbeRules /. pt, 30], 10^-22],
                         {N::meprec, General::stop}]]] == 0]]]];
cfZeroQ[e_] := Module[{s, r},
  If[e === 0, Return[True]];
  s = Simplify[e, cfGeomAssume, TimeConstraint -> 5];
  If[s === 0, Return[True]];
  r = cfNumericallyZeroQ[s];
  (* A True here is an identity accepted on numerical evidence alone; count it.  A False    *)
  (* here is NOT counted as a witness of non-vanishing: it may only mean the probe did not   *)
  (* reduce to a number.  Genuine witnesses come from cfNonZeroWitnessQ below.               *)
  If[r, $cfNumericCertificates++];
  r];
(* cfNonZeroWitnessQ is how this notebook states that something is NOT identically zero.     *)
(* It succeeds only if, at some probe point, EVERY entry evaluates to an actual number and    *)
(* at least one of them has magnitude above 10^-10.  A non-numeric leftover -- an undefined  *)
(* function that the probe rules do not reach, say -- makes it FAIL, not pass.  That is the   *)
(* difference between this and the pattern ! TrueQ[cfZeroArrayQ[...]], which a previous      *)
(* version of this notebook used and which passes vacuously on exactly such a leftover.       *)
ClearAll[cfNonZeroWitnessQ];
cfNonZeroWitnessQ[expr_] := Block[{$MaxExtraPrecision = 200}, Module[{vals, ok},
  vals = Quiet[N[Flatten[{expr}] /. cfProbeRules /. #, 30], {N::meprec, General::stop}] & /@ cfProbePoints;
  ok = AnyTrue[vals, Function[v, AllTrue[v, NumericQ] && Max[Abs[Chop[v, 10^-22]]] > 10^-10]];
  If[ok, $cfNonVanishingWitnesses++];
  ok]];
cfZeroArrayQ[arr_] := Module[{flat = Flatten[{arr}], s},
  (* stage 1 *)
  If[AllTrue[flat, # === 0 &], Return[True]];
  (* stage 2: Simplify the whole array at once, under the geometric assumptions.  Skipping   *)
  (* this and going straight to the numerical sweep would leave every array identity in      *)
  (* Parts III and IV certified only at sample points, which is weaker than the policy this  *)
  (* notebook states.                                                                        *)
  s = Simplify[flat, cfGeomAssume, TimeConstraint -> 5];
  If[AllTrue[s, # === 0 &], Return[True]];
  (* stage 3: one fast numerical sweep over whatever stage 2 could not reduce *)
  If[cfNumericallyZeroQ[s], $cfNumericCertificates++; Return[True]];
  (* still inconclusive: test entry by entry so we learn which entries fail *)
  AllTrue[s, cfZeroQ]];
{cfZeroQ[0], cfZeroQ[Tan[6 H x0] Cot[6 H x0] - 1], cfZeroQ[x0 - x4],
 cfZeroArrayQ[{{0, Sin[x0]^2 + Cos[x0]^2 - 1}, {Exp[a4[H x4]] Exp[-a4[H x4]] - 1, 0}}],
 cfNonZeroWitnessQ[x0 - x4], cfNonZeroWitnessQ[Sin[x0]^2 + Cos[x0]^2 - 1],
 cfNonZeroWitnessQ[cfSomeUndefinedFunction[x0]]}
(* the self-tests above are demonstrations, not claims about the geometry: reset the tally *)
$cfNumericCertificates = 0; $cfNonVanishingWitnesses = 0;
]];

(* ---------- Input cell 97 ---------- *)
cfRunCell[97, Hold[
(* --- [d] the bridge g = e . eta . Transpose[e] ------------------------------------------- *)
gCanonical = cfSimp[frameCanonical . \[Eta]4488 . Transpose[frameCanonical]];
coframeCanonical = cfSimp[Inverse[frameCanonical]];
gInvCanonical = cfSimp[Inverse[gCanonical]];
(* Grading these honestly, because the obvious one is a tautology.                          *)
(* gCanonical was DEFINED one line above as frame . eta . Transpose[frame], so asserting    *)
(* that it equals frame . eta . Transpose[frame] restates the definition and cannot fail.   *)
(* It is kept because it puts the bridge [d] on screen next to the metric, but it is        *)
(* labelled for what it is.  The check with content is the one after it: that the frame     *)
(* the ORIGINAL notebook recorded reproduces exactly the line element stated in the text     *)
(* above.  A mistranscribed frame entry would fail that and pass the tautology.             *)
cfAssert["CANONICAL [structural]: frame . coframe == ID8  (certifies only that the frame is invertible)",
  cfZeroArrayQ[frameCanonical . coframeCanonical - ID8]];
cfAssert["CANONICAL [definition]: g == frame . eta4488 . Transpose[frame]  (bridge [d]; this IS how g was defined, so it cannot fail)",
  cfZeroArrayQ[gCanonical - frameCanonical . \[Eta]4488 . Transpose[frameCanonical]]];
cfAssert["CANONICAL [has content]: g == diag(Tan[6 H x0]^2, q^2, q^2, q^2, -1, -p^2, -p^2, -p^2), the stated line element",
  cfZeroArrayQ[gCanonical - DiagonalMatrix[{Tan[6 H x0]^2,
     cfQminus^2, cfQminus^2, cfQminus^2, -1, -cfQplus^2, -cfQplus^2, -cfQplus^2}]]];
(* Signature.  Because the frame is diagonal, g[[i,i]] == eta[[i,i]] frame[[i,i]]^2 exactly, *)
(* which is Sylvester's law of inertia made explicit: g inherits eta's signature from any    *)
(* real invertible frame.  That identity needs no assumption at all.                          *)
cfAssert["CANONICAL [has content]: Diagonal[g] == Diagonal[eta4488] * Diagonal[frame]^2 exactly",
  cfZeroArrayQ[Diagonal[gCanonical] - Diagonal[\[Eta]4488] Diagonal[frameCanonical]^2]];
(* Turning that into "four plus, four minus" needs two things the notebook cannot derive,     *)
(* because a4 is deliberately left undefined: that a4 is REAL-valued, and that 6 H x0 lies    *)
(* in the first quadrant so that Tan[6 H x0] > 0.  Both are stated here rather than assumed   *)
(* silently.  Without them Mathematica cannot decide the sign of Exp[a4[H x4]] and is right   *)
(* not to.                                                                                    *)
ClearAll[cfSignatureAssume];
cfSignatureAssume = cfGeomAssume && Element[a4[H x4], Reals] && 0 < 6 H x0 < Pi/2;
cfAssert["CANONICAL [has content]: g has signature (4,4), GIVEN a4 real and 0 < 6 H x0 < Pi/2",
  Module[{s = Simplify[# > 0, cfSignatureAssume] & /@ Diagonal[gCanonical]},
    {Count[s, True] === 4, Count[s, False] === 4}]];
cfAssert["Inverse[g] == Transpose[coframe] . eta4488 . coframe",
  cfZeroArrayQ[gInvCanonical - Transpose[coframeCanonical] . \[Eta]4488 . coframeCanonical]];
cfAssert["g is symmetric", cfZeroArrayQ[gCanonical - Transpose[gCanonical]]];
MatrixForm[gCanonical]
]];

(* ---------- Input cell 98 ---------- *)
cfRunCell[98, Hold[
(* --- the metric determinant, and the volume factor used in Lagrangians ------------------- *)
ClearAll[detgCanonical, sqrtDetgCanonical];
detgCanonical = cfSimp[Det[gCanonical]];
sqrtDetgCanonical = cfSimp[Sqrt[Abs[detgCanonical]]];
cfAssert["the metric is non-degenerate", cfNonZeroWitnessQ[detgCanonical]];
{detgCanonical, sqrtDetgCanonical}
]];

(* ---------- Input cell 99 ---------- *)
cfRunCell[99, Hold[
(* --- the frame, coframe and metric, direction by direction ------------------------------- *)
Grid[Prepend[
  Table[{Subscript["direction", ToString[\[Mu] - 1]],
         frameCanonical[[\[Mu], \[Mu]]],
         coframeCanonical[[\[Mu], \[Mu]]],
         gCanonical[[\[Mu], \[Mu]]]}, {\[Mu], 1, 8}],
  {"direction", "frame e[mu,a]", "coframe e_a^mu", "g[mu,mu]"}], Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 100 ---------- *)
cfRunCell[100, Hold[
(* --- the generalized Christoffel symbols of the second kind ------------------------------ *)
(* Gamma[[rho,mu,nu]] = (1/2) g^{rho s} ( d_mu g_{s nu} + d_nu g_{s mu} - d_s g_{mu nu} )    *)
(* Optimization: the first derivatives of g are computed once into dg[[k,m,p]] and reused,   *)
(* instead of being recomputed inside the triple loop as a naive transcription would do.     *)
ClearAll[cfChristoffel];
cfChristoffel[g_, ginv_, coords_] := Module[{n = Length[coords], dg},
  dg = Table[D[g[[m, p]], coords[[k]]], {k, n}, {m, n}, {p, n}];
  Table[
   cfSimp[(1/2) Sum[ginv[[r, s]] (dg[[m, s, p]] + dg[[p, s, m]] - dg[[s, m, p]]), {s, n}]],
   {r, n}, {m, n}, {p, n}]];
]];

(* ---------- Input cell 101 ---------- *)
cfRunCell[101, Hold[
ClearAll[GammaCanonical];
GammaCanonical = cfTimed["generalized Christoffel symbols of the 4+4 metric",
  cfChristoffel[gCanonical, gInvCanonical, X]];
cfAssert["Gamma is symmetric in its two lower indices (torsion-free affine connection)",
  cfZeroArrayQ[Table[GammaCanonical[[r, m, p]] - GammaCanonical[[r, p, m]],
    {r, 8}, {m, 8}, {p, 8}]]];
{Dimensions[GammaCanonical], Count[Flatten[GammaCanonical], Except[0]], " non-zero components"}
]];

(* ---------- Input cell 102 ---------- *)
cfRunCell[102, Hold[
(* --- the non-zero Christoffel symbols, listed ------------------------------------------- *)
Grid[Prepend[
  Select[Flatten[Table[{Row[{"Gamma[", r - 1, ";", m - 1, ",", p - 1, "]"}],
      GammaCanonical[[r, m, p]]}, {r, 8}, {m, 8}, {p, 8}], 2], #[[2]] =!= 0 &],
  {"symbol", "value"}], Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 103 ---------- *)
cfRunCell[103, Hold[
(* ======================================================================================== *)
(* The general spin-connection solver.  It takes ANY frame field and ANY flat tangent metric *)
(* and returns the unique zero-torsion spin connection determined by the vielbein postulate. *)
(* Every one of the four connections in this notebook is produced by this one routine, so    *)
(* the comparisons of Part IV compare results, not different pieces of code.                 *)
(* The Christoffel symbols are a property of g alone, so they are passed in and REUSED       *)
(* across all four bridges rather than recomputed four times.                                *)
(* ======================================================================================== *)
ClearAll[cfSpinConnection, cfLowerFirstFlat, cfVielbeinResidual, cfTorsion, cfCurvature];
cfSpinConnection[frame_, coords_, etaFlat_, gamma_] :=
 Module[{n = Length[coords], cofr, dE},
  cofr = cfSimp[Inverse[frame]];                                  (* cofr[[a,nu]] = e_a^nu *)
  dE = Table[D[frame[[nu, a]], coords[[mu]]], {mu, n}, {nu, n}, {a, n}];
  Table[
    cfSimp[Sum[(Sum[gamma[[r, mu, nu]] frame[[r, a]], {r, n}] - dE[[mu, nu, a]]) cofr[[c, nu]],
      {nu, n}]],
    {mu, n}, {a, n}, {c, n}]];
]];

(* ---------- Input cell 104 ---------- *)
cfRunCell[104, Hold[
(* --- index lowering, and the three diagnostics every connection must pass ---------------- *)
cfLowerFirstFlat[om_, etaFlat_] := Module[{n = Length[etaFlat]},
  Table[Sum[etaFlat[[a, c]] om[[mu, c, b]], {c, n}], {mu, n}, {a, n}, {b, n}]];
cfVielbeinResidual[frame_, coords_, gamma_, om_] := Module[{n = Length[coords]},
  Table[
    D[frame[[nu, a]], coords[[mu]]] - Sum[gamma[[r, mu, nu]] frame[[r, a]], {r, n}]
      + Sum[om[[mu, a, b]] frame[[nu, b]], {b, n}],
    {mu, n}, {nu, n}, {a, n}]];
(* torsion 2-form  T^a_{mu nu} = d_mu e_nu^a - d_nu e_mu^a + om_mu{}^a{}_b e_nu^b - (mu<->nu) *)
cfTorsion[frame_, coords_, om_] := Module[{n = Length[coords]},
  cfSimpArray @ Table[
    D[frame[[nu, a]], coords[[mu]]] - D[frame[[mu, a]], coords[[nu]]]
      + Sum[om[[mu, a, b]] frame[[nu, b]] - om[[nu, a, b]] frame[[mu, b]], {b, n}],
    {a, n}, {mu, n}, {nu, n}]];
(* curvature 2-form  R_{mu nu}{}^a{}_b = d_mu om_nu - d_nu om_mu + [om_mu, om_nu]           *)
cfCurvature[om_, coords_] := Module[{n = Length[coords]},
  cfSimpArray @ Table[
    D[om[[nu, a, b]], coords[[mu]]] - D[om[[mu, a, b]], coords[[nu]]]
      + Sum[om[[mu, a, c]] om[[nu, c, b]] - om[[nu, a, c]] om[[mu, c, b]], {c, n}],
    {mu, n}, {nu, n}, {a, n}, {b, n}]];
]];

(* ---------- Input cell 105 ---------- *)
cfRunCell[105, Hold[
(* ======================= THE CANONICAL SPIN CONNECTION ================================== *)
ClearAll[omegaCanonicalMixed, omegaCanonical];
omegaCanonicalMixed = cfTimed["canonical spin connection omega[mu]^a_b from the vielbein postulate",
  cfSpinConnection[frameCanonical, X, \[Eta]4488, GammaCanonical]];
omegaCanonical = cfLowerFirstFlat[omegaCanonicalMixed, \[Eta]4488];
{Dimensions[omegaCanonical], Count[Flatten[omegaCanonical], Except[0]], " non-zero components"}
]];

(* ---------- Input cell 106 ---------- *)
cfRunCell[106, Hold[
(* --- what the three obvious checks actually establish ------------------------------------ *)
cfAssert["CANONICAL [solver regression]: vielbein postulate residual is zero",
  cfZeroArrayQ[cfVielbeinResidual[frameCanonical, X, GammaCanonical, omegaCanonicalMixed]]];
cfAssert["CANONICAL [structural]: torsion vanishes",
  cfZeroArrayQ[cfTorsion[frameCanonical, X, omegaCanonicalMixed]]];
cfAssert["CANONICAL [has content]: omega[mu,a,b] == -omega[mu,b,a]  (metric compatibility)",
  cfZeroArrayQ[Table[omegaCanonical[[mu, a, b]] + omegaCanonical[[mu, b, a]],
    {mu, 8}, {a, 8}, {b, 8}]]];
]];

(* ---------- Input cell 107 ---------- *)
cfRunCell[107, Hold[
(* --- the independent derivation, from the frame alone ------------------------------------ *)
(* omega_mu^{ab} = (1/2) e^{a nu} ( d_mu e_nu^b - d_nu e_mu^b )                               *)
(*               - (1/2) e^{b nu} ( d_mu e_nu^a - d_nu e_mu^a )                               *)
(*               - (1/2) e^{a rho} e^{b sig} ( d_rho e_sig^c - d_sig e_rho^c ) eta_{cd} e_mu^d *)
(* Nothing here refers to Gamma or to g: only the frame, its derivatives and eta.             *)
ClearAll[cfSpinConnectionFromFrame];
cfSpinConnectionFromFrame[frame_, coords_, etaFlat_] :=
 Module[{n = Length[coords], cofr, up, dE, term1, term2, term3},
  cofr = cfSimp[Inverse[frame]];                       (* cofr[[a,nu]]  = e_a^nu   *)
  up   = cfSimp[Inverse[etaFlat] . cofr];              (* up[[a,nu]]    = e^{a nu} *)
  dE   = Table[D[frame[[nu, a]], coords[[mu]]], {mu, n}, {nu, n}, {a, n}];
  Table[
   cfSimp[
    (1/2) Sum[up[[a, nu]] (dE[[mu, nu, b]] - dE[[nu, mu, b]]), {nu, n}]
    - (1/2) Sum[up[[b, nu]] (dE[[mu, nu, a]] - dE[[nu, mu, a]]), {nu, n}]
    - (1/2) Sum[up[[a, rho]] up[[b, sig]] (dE[[rho, sig, c]] - dE[[sig, rho, c]])
         etaFlat[[c, d]] frame[[mu, d]], {rho, n}, {sig, n}, {c, n}, {d, n}]],
   {mu, n}, {a, n}, {b, n}]];

ClearAll[omegaFromFrameUp];
omegaFromFrameUp = cfTimed["independent derivation of omega from the frame alone",
  cfSpinConnectionFromFrame[frameCanonical, X, \[Eta]4488]];
(* omegaFromFrameUp carries omega_mu^{ab}; lower the second flat index to compare *)
cfAssert["INDEPENDENT CHECK: the frame-only derivation reproduces omegaCanonical exactly",
  cfZeroArrayQ[Table[Sum[omegaFromFrameUp[[mu, a, c]] \[Eta]4488[[c, b]], {c, 8}]
     - omegaCanonicalMixed[[mu, a, b]], {mu, 8}, {a, 8}, {b, 8}]]];
cfAssert["INDEPENDENT CHECK: and it is antisymmetric in its two raised flat indices",
  cfZeroArrayQ[Table[omegaFromFrameUp[[mu, a, b]] + omegaFromFrameUp[[mu, b, a]],
    {mu, 8}, {a, 8}, {b, 8}]]];
]];

(* ---------- Input cell 108 ---------- *)
cfRunCell[108, Hold[
(* --- the non-zero components of the canonical spin connection, listed -------------------- *)
ClearAll[cfShowConnection];
cfShowConnection[om_, name_String] := Grid[Prepend[
   Select[Flatten[Table[{Row[{name, "[", mu - 1, ";", a - 1, ",", b - 1, "]"}],
       om[[mu, a, b]]}, {mu, 8}, {a, 8}, {b, 8}], 2], #[[2]] =!= 0 &],
   {"component", "value"}], Frame -> All, Alignment -> Left];
cfShowConnection[omegaCanonical, "omega"]
]];

(* ---------- Input cell 109 ---------- *)
cfRunCell[109, Hold[
(* --- the curvature 2-form of the canonical connection ------------------------------------ *)
ClearAll[RiemannCanonical];
RiemannCanonical = cfTimed["curvature 2-form of the canonical spin connection",
  cfCurvature[omegaCanonicalMixed, X]];
cfAssert["CANONICAL: curvature is antisymmetric in the two spacetime indices",
  cfZeroArrayQ[Table[RiemannCanonical[[mu, nu, a, b]] + RiemannCanonical[[nu, mu, a, b]],
    {mu, 8}, {nu, 8}, {a, 8}, {b, 8}]]];
{Count[Flatten[RiemannCanonical], Except[0]], " non-zero curvature components"}
]];

(* ---------- Input cell 110 ---------- *)
cfRunCell[110, Hold[
(* --- the Ricci scalar; it is the invariant we use to confirm that every bridge below ----- *)
(* --- really does describe the SAME geometry ---------------------------------------------- *)
ClearAll[cfRicciScalar, RicciScalarCanonical];
cfRicciScalar[frame_, riem_, ginv_] := Module[{cofr, ric},
  cofr = cfSimp[Inverse[frame]];
  ric = cfSimpArray @ Table[Sum[cofr[[a, mu]] riem[[mu, nu, a, b]], {a, 8}, {mu, 8}],
     {nu, 8}, {b, 8}];
  (* one scalar, so FullSimplify is cheap here and it matters: without it the same number   *)
  (* comes out in different surface forms from different frames, which looks like a          *)
  (* disagreement when it is not.                                                            *)
  FullSimplify[Sum[ginv[[nu, rho]] frame[[rho, b]] ric[[nu, b]], {nu, 8}, {rho, 8}, {b, 8}],
    cfGeomAssume]];
RicciScalarCanonical = cfTimed["Ricci scalar of the canonical connection",
  cfRicciScalar[frameCanonical, RiemannCanonical, gInvCanonical]];
RicciScalarCanonical
]];

(* ---------- Input cell 111 ---------- *)
cfRunCell[111, Hold[
(* --- the 16x16 spin-connection matrix in each spacetime direction ------------------------ *)
ClearAll[cfSpinMatrix, GammaSpinCanonical];
cfSpinMatrix[om_, mu_Integer] :=
  (1/8) Sum[om[[mu, a, b]] (T16[a - 1] . T16[b - 1] - T16[b - 1] . T16[a - 1]), {a, 8}, {b, 8}];
GammaSpinCanonical = cfTimed["16x16 spin-connection matrices Gamma^spin[mu]",
  Table[cfSimpArray[cfSpinMatrix[omegaCanonical, mu]], {mu, 8}]];
Dimensions[GammaSpinCanonical]
]];

(* ---------- Input cell 112 ---------- *)
cfRunCell[112, Hold[
(* --- it equals (1/2) omega[mu,a,b] SAB, as it must --------------------------------------- *)
cfAssert["[definition] (1/8) omega [gamma^a, gamma^b] == (1/2) omega SAB  (SAB is defined as (1/4)[gamma,gamma], so this cannot fail)",
  cfZeroArrayQ[Table[GammaSpinCanonical[[mu]]
      - (1/2) Sum[omegaCanonical[[mu, a, b]] SAB[[a, b]], {a, 8}, {b, 8}], {mu, 8}]]];
(* The check with content.  The spinor connection is the RIGHT one only if it rotates the     *)
(* Dirac matrices exactly as omega rotates a vector: [Gamma^spin_mu, gamma^a] must equal      *)
(* - omega_mu^a_b gamma^b.  That fixes the coefficient 1/8 AND its sign against the sign       *)
(* convention of the vielbein postulate; the wrong sign, or 1/4 instead of 1/8, fails it.     *)
cfAssert["[has content] the spinor connection is compatible with omega: [Gamma^spin_mu, gamma^a] + omega_mu^a_b gamma^b == 0",
  cfZeroArrayQ[Table[GammaSpinCanonical[[mu]] . T16[a - 1] - T16[a - 1] . GammaSpinCanonical[[mu]]
      + Sum[omegaCanonicalMixed[[mu, a, b]] T16[b - 1], {b, 8}], {mu, 8}, {a, 8}]]];
cfAssert["[control] with the opposite sign the compatibility check FAILS (witnessed): the sign is fixed by the vielbein postulate, not free",
  cfNonZeroWitnessQ[Table[GammaSpinCanonical[[mu]] . T16[a - 1] - T16[a - 1] . GammaSpinCanonical[[mu]]
      - Sum[omegaCanonicalMixed[[mu, a, b]] T16[b - 1], {b, 8}], {mu, 8}, {a, 8}]]];
]];

(* ---------- Input cell 113 ---------- *)
cfRunCell[113, Hold[
(* --- the direct-sum structure: every Gamma^spin[mu] is block diagonal -------------------- *)
ClearAll[GammaSpinType1, GammaSpinType2];
cfAssert["Gamma^spin[mu] is block diagonal: it never mixes type-1 with type-2",
  cfZeroArrayQ[Table[GammaSpinCanonical[[mu]]
      - ArrayFlatten[{{GammaSpinCanonical[[mu]][[1 ;; 8, 1 ;; 8]], 0},
                      {0, GammaSpinCanonical[[mu]][[9 ;; 16, 9 ;; 16]]}}], {mu, 8}]]];
GammaSpinType1 = Table[GammaSpinCanonical[[mu]][[1 ;; 8, 1 ;; 8]],   {mu, 8}];
GammaSpinType2 = Table[GammaSpinCanonical[[mu]][[9 ;; 16, 9 ;; 16]], {mu, 8}];
{Dimensions[GammaSpinType1], Dimensions[GammaSpinType2]}
]];

(* ---------- Input cell 114 ---------- *)
cfRunCell[114, Hold[
(* --- the two 8x8 blocks, written directly in terms of tau and taubar --------------------- *)
cfAssert["the type-1 block is (1/8) omega (taubar^a tau^b - taubar^b tau^a)",
  cfZeroArrayQ[Table[GammaSpinType1[[mu]] - (1/8) Sum[omegaCanonical[[mu, a, b]]
      (\[Tau]bar[a - 1] . \[Tau][b - 1] - \[Tau]bar[b - 1] . \[Tau][a - 1]), {a, 8}, {b, 8}],
      {mu, 8}]]];
cfAssert["the type-2 block is (1/8) omega (tau^a taubar^b - tau^b taubar^a)",
  cfZeroArrayQ[Table[GammaSpinType2[[mu]] - (1/8) Sum[omegaCanonical[[mu, a, b]]
      (\[Tau][a - 1] . \[Tau]bar[b - 1] - \[Tau][b - 1] . \[Tau]bar[a - 1]), {a, 8}, {b, 8}],
      {mu, 8}]]];
]];

(* ---------- Input cell 115 ---------- *)
cfRunCell[115, Hold[
(* --- the covariant derivative itself ----------------------------------------------------- *)
(* cfDcov16 acts on a 16-component spinor; cfDcovType1 and cfDcovType2 act on the type-1 and *)
(* type-2 split-octonion spinors separately, which is legitimate exactly because the         *)
(* connection matrix is block diagonal.                                                      *)
ClearAll[cfDcov16, cfDcovType1, cfDcovType2, psiGeneric, psi1Generic, psi2Generic];
cfDcov16[psi_List, mu_Integer, gs_: Automatic] :=
  D[psi, X[[mu]]] + (If[gs === Automatic, GammaSpinCanonical, gs][[mu]]) . psi;
cfDcovType1[psi1_List, mu_Integer] := D[psi1, X[[mu]]] + GammaSpinType1[[mu]] . psi1;
cfDcovType2[psi2_List, mu_Integer] := D[psi2, X[[mu]]] + GammaSpinType2[[mu]] . psi2;
psiGeneric  = Table[cfPsi[k] @@ X, {k, 0, 15}];
psi1Generic = psiGeneric[[1 ;; 8]];
psi2Generic = psiGeneric[[9 ;; 16]];
cfAssert["Dcov16 on the direct sum is the direct sum of Dcov1 and Dcov2",
  cfZeroArrayQ[Table[cfDcov16[psiGeneric, mu]
      - Join[cfDcovType1[psi1Generic, mu], cfDcovType2[psi2Generic, mu]], {mu, 8}]]];
cfDcovType1[psi1Generic, 1] // Short[#, 6] &
]];

(* ---------- Input cell 116 ---------- *)
cfRunCell[116, Hold[
(* --- the curved-space Dirac operator ----------------------------------------------------- *)
(* gammaCurved[mu] = coframe[[a,mu]] gamma^a  obeys  {gammaCurved[mu], gammaCurved[nu]}       *)
(*                                                   == 2 g^{mu nu} ID16 .                   *)
ClearAll[gammaCurvedCanonical, cfDiracOperator];
gammaCurvedCanonical = Table[cfSimpArray[Sum[coframeCanonical[[a, mu]] T16[a - 1], {a, 8}]], {mu, 8}];
cfAssert["{gammaCurved[mu], gammaCurved[nu]} == 2 gInv[mu,nu] ID16",
  cfZeroArrayQ[Table[gammaCurvedCanonical[[mu]] . gammaCurvedCanonical[[nu]]
      + gammaCurvedCanonical[[nu]] . gammaCurvedCanonical[[mu]]
      - 2 gInvCanonical[[mu, nu]] ID16, {mu, 8}, {nu, 8}]]];
cfDiracOperator[psi_List] := Sum[gammaCurvedCanonical[[mu]] . cfDcov16[psi, mu], {mu, 8}];
(* the check that ties the three connections together: the Christoffel symbols acting on the  *)
(* curved index, the spinor connection acting by commutator, and the frame in between.  If any  *)
(* one of them had the wrong sign or index order, the curved Dirac matrices would not be        *)
(* covariantly constant.                                                                        *)
cfAssert["[has content] and therefore the curved Dirac matrices are covariantly constant: D_mu gammaCurved^nu == 0",
  cfZeroArrayQ[Table[D[gammaCurvedCanonical[[nu]], X[[mu]]]
      + Sum[GammaCanonical[[nu, mu, rho]] gammaCurvedCanonical[[rho]], {rho, 8}]
      + GammaSpinCanonical[[mu]] . gammaCurvedCanonical[[nu]] - gammaCurvedCanonical[[nu]] . GammaSpinCanonical[[mu]],
      {mu, 8}, {nu, 8}]]];
Dimensions[gammaCurvedCanonical]
]];

(* ---------- Input cell 117 ---------- *)
cfRunCell[117, Hold[
(* --- and now on the wave function of the model itself, Psi16 of Section 11 ---------------- *)
(* Psi16 depends only on x0 and x4, so in the other six directions the covariant derivative   *)
(* IS the connection term, and in x0 and x4 it is the flat derivative plus that term.         *)
ClearAll[DcovPsi16, DiracPsi16];
DcovPsi16 = Table[cfDcov16[\[CapitalPsi]16, mu], {mu, 8}];
cfAssert["[definition] Dcov[mu] Psi16 - D[Psi16, x_mu] == Gamma^spin[mu] . Psi16",
  cfZeroArrayQ[Table[DcovPsi16[[mu]] - D[\[CapitalPsi]16, X[[mu]]] - GammaSpinCanonical[[mu]] . \[CapitalPsi]16, {mu, 8}]]];
cfAssert["in the six directions on which Psi16 does not depend, Dcov Psi16 is purely the connection term",
  cfZeroArrayQ[Table[DcovPsi16[[mu]] - GammaSpinCanonical[[mu]] . \[CapitalPsi]16, {mu, {2, 3, 4, 6, 7, 8}}]]];
cfAssert["the connection term does not vanish on Psi16: the connection matrices themselves are non-zero (witnessed)",
  cfNonZeroWitnessQ[Table[GammaSpinCanonical[[mu]], {mu, 8}]]];
DiracPsi16 = cfTimed["the curved-space Dirac operator applied to Psi16", cfDiracOperator[\[CapitalPsi]16]];
Column[{Short[DcovPsi16[[1]], 4], Short[DiracPsi16, 6]}]
]];

(* ---------- Input cell 118 ---------- *)
cfRunCell[118, Hold[
ClearAll[cfBoostRapidity, cfLambda, cfLambdaOf, cfBoostGenerator, frameBoost];
cfBoostGenerator = Module[{K = ConstantArray[0, {8, 8}]}, K[[1, 5]] = 1; K[[5, 1]] = 1; K];
cfLambdaOf[th_] := Module[{L = IdentityMatrix[8]},
  L[[1, 1]] = Cosh[th]; L[[5, 5]] = Cosh[th];
  L[[1, 5]] = Sinh[th]; L[[5, 1]] = Sinh[th];
  L];
cfLambda = cfLambdaOf[cfBoostRapidity[x0, x4]];
cfAssert["Lambda is in O(4,4): Lambda . eta . Transpose[Lambda] == eta",
  cfZeroArrayQ[cfLambda . \[Eta]4488 . Transpose[cfLambda] - \[Eta]4488]];
cfAssert["Lambda is NOT in O(8): it is a genuine boost, not a rotation",
  cfNonZeroWitnessQ[cfLambda . Transpose[cfLambda] - ID8]];
cfAssert["Lambda == MatrixExp[theta K] with K the (0,4) boost generator",
  cfZeroArrayQ[cfLambdaOf[\[Theta]] - MatrixExp[\[Theta] cfBoostGenerator]]];
MatrixForm[cfLambda]
]];

(* ---------- Input cell 119 ---------- *)
cfRunCell[119, Hold[
frameBoost = cfSimpArray[frameCanonical . cfLambda];
cfAssert["BRIDGE 1 reproduces the SAME curved metric g",
  cfZeroArrayQ[frameBoost . \[Eta]4488 . Transpose[frameBoost] - gCanonical]];
cfAssert["BRIDGE 1 frame really is different from the canonical frame",
  frameBoost =!= frameCanonical];
MatrixForm[frameBoost]
]];

(* ---------- Input cell 120 ---------- *)
cfRunCell[120, Hold[
(* --- the new spin connection, derived from the same vielbein postulate ------------------- *)
ClearAll[omegaBoostMixed, omegaBoost];
omegaBoostMixed = cfTimed["BRIDGE 1 spin connection",
  cfSpinConnection[frameBoost, X, \[Eta]4488, GammaCanonical]];
omegaBoost = cfLowerFirstFlat[omegaBoostMixed, \[Eta]4488];
cfAssert["BRIDGE 1: vielbein postulate holds identically",
  cfZeroArrayQ[cfVielbeinResidual[frameBoost, X, GammaCanonical, omegaBoostMixed]]];
cfAssert["BRIDGE 1: omega[mu,a,b] == -omega[mu,b,a]",
  cfZeroArrayQ[Table[omegaBoost[[mu, a, b]] + omegaBoost[[mu, b, a]], {mu, 8}, {a, 8}, {b, 8}]]];
cfAssert["BRIDGE 1: torsion still vanishes",
  cfZeroArrayQ[cfTorsion[frameBoost, X, omegaBoostMixed]]];
{Count[Flatten[omegaBoost], Except[0]], " non-zero components"}
]];

(* ---------- Input cell 121 ---------- *)
cfRunCell[121, Hold[
(* --- the test Section 16 could not make: both solvers on a NON-symmetric frame ------------ *)
(* A constant boost by a fixed rapidity gives a frame that is not equal to its transpose and   *)
(* contains no undetermined function, so this is cheap and it is discriminating: any          *)
(* transposition of the frame's curved and flat slots, in either solver, fails here.           *)
ClearAll[frameSlotTest, omegaSlotTestA, omegaSlotTestB];
frameSlotTest = cfSimpArray[frameCanonical . cfLambdaOf[1/3]];
cfAssert["the slot-test frame is genuinely not symmetric", cfNonZeroWitnessQ[frameSlotTest - Transpose[frameSlotTest]]];
omegaSlotTestA = cfTimed["vielbein-postulate solver on the non-symmetric frame",
  cfSpinConnection[frameSlotTest, X, \[Eta]4488, GammaCanonical]];
omegaSlotTestB = cfTimed["frame-only formula on the non-symmetric frame",
  cfSpinConnectionFromFrame[frameSlotTest, X, \[Eta]4488]];
cfAssert["INDEPENDENT CHECK on a non-symmetric frame: the two solvers agree, so the curved/flat slots are placed correctly in both",
  cfZeroArrayQ[Table[Sum[omegaSlotTestB[[mu, a, c]] \[Eta]4488[[c, b]], {c, 8}] - omegaSlotTestA[[mu, a, b]],
    {mu, 8}, {a, 8}, {b, 8}]]];
cfAssert["and the result is the canonical connection conjugated by the constant boost, as the gauge law demands",
  cfZeroArrayQ[Table[omegaSlotTestA[[mu]] - Transpose[cfLambdaOf[1/3]] . omegaCanonicalMixed[[mu]] . Inverse[Transpose[cfLambdaOf[1/3]]],
    {mu, 8}]]];
]];

(* ---------- Input cell 122 ---------- *)
cfRunCell[122, Hold[
(* --- COMPARISON 1: the new connection is the canonical one plus a pure gauge term -------- *)
ClearAll[cfM, cfMinv, omegaBoostPredicted, deltaBoost, gaugeTermBoost];
cfM = Transpose[cfLambda];
cfMinv = cfSimpArray[Inverse[cfM]];
omegaBoostPredicted = Table[
   cfSimpArray[cfM . omegaCanonicalMixed[[mu]] . cfMinv - D[cfM, X[[mu]]] . cfMinv], {mu, 8}];
cfAssert["COMPARISON 1: omegaBoost == M omegaCanonical Inverse[M] - D[M,x_mu] Inverse[M]",
  cfZeroArrayQ[omegaBoostMixed - omegaBoostPredicted]];
gaugeTermBoost = Table[cfSimpArray[-D[cfM, X[[mu]]] . cfMinv], {mu, 8}];
deltaBoost = Table[cfSimpArray[omegaBoostMixed[[mu]] - cfM . omegaCanonicalMixed[[mu]] . cfMinv],
   {mu, 8}];
cfAssert["COMPARISON 1: the WHOLE difference is the inhomogeneous gauge term",
  cfZeroArrayQ[deltaBoost - gaugeTermBoost]];
{Count[Flatten[deltaBoost], Except[0]], " non-zero components in the difference"}
]];

(* ---------- Input cell 123 ---------- *)
cfRunCell[123, Hold[
(* --- the gauge term written out: it is -d(rapidity) times the boost generator ------------ *)
(* Because Lambda == MatrixExp[theta K], D[Lambda,x_mu] . Inverse[Lambda] == D[theta,x_mu] K  *)
(* exactly, with no residual theta dependence.  The whole difference between the two spin     *)
(* connections is therefore one scalar gradient times one fixed generator.                    *)
cfAssert["COMPARISON 1: the difference equals -D[theta, x_mu] * (boost generator)",
  cfZeroArrayQ[Table[deltaBoost[[mu]]
    + D[cfBoostRapidity[x0, x4], X[[mu]]] cfBoostGenerator, {mu, 8}]]];
Grid[Prepend[
  Table[{Row[{"Delta1[", mu - 1, "]"}], -D[cfBoostRapidity[x0, x4], X[[mu]]],
         If[D[cfBoostRapidity[x0, x4], X[[mu]]] === 0, "zero",
            "times the (0,4) boost generator K"]},
    {mu, 8}], {"direction mu", "coefficient", "structure"}], Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 124 ---------- *)
cfRunCell[124, Hold[
(* --- and the curvature is only conjugated: same geometry, new gauge ---------------------- *)
ClearAll[RiemannBoost, RicciScalarBoost];
RiemannBoost = cfTimed["BRIDGE 1 curvature 2-form", cfCurvature[omegaBoostMixed, X]];
cfAssert["COMPARISON 1: curvature transforms covariantly, R' == M R Inverse[M]",
  cfZeroArrayQ[Table[RiemannBoost[[mu, nu]] - cfM . RiemannCanonical[[mu, nu]] . cfMinv,
    {mu, 8}, {nu, 8}]]];
RicciScalarBoost = cfTimed["BRIDGE 1 Ricci scalar",
  cfRicciScalar[frameBoost, RiemannBoost, gInvCanonical]];
cfAssert["COMPARISON 1: BRIDGE 1 has the SAME Ricci scalar as the canonical frame",
  cfZeroQ[RicciScalarBoost - RicciScalarCanonical]];
{RicciScalarCanonical, RicciScalarBoost}
]];

(* ---------- Input cell 125 ---------- *)
cfRunCell[125, Hold[
ClearAll[cfSpinLiftBoost, cfSpinLiftBoostInv, GammaSpinBoost, gammaCurvedBoost];
cfSpinLiftBoost    = MatrixExp[ cfBoostRapidity[x0, x4] SAB[[1, 5]]];
cfSpinLiftBoostInv = MatrixExp[-cfBoostRapidity[x0, x4] SAB[[1, 5]]];
cfAssert["BRIDGE 1 spin lift: Inverse[S] . S == ID16",
  cfZeroArrayQ[cfSpinLiftBoostInv . cfSpinLiftBoost - ID16]];
cfAssert["BRIDGE 1 spin lift: S preserves the spinor metric, Transpose[S] . sigma16 . S == sigma16",
  cfZeroArrayQ[Transpose[cfSpinLiftBoost] . \[Sigma]16 . cfSpinLiftBoost - \[Sigma]16]];
cfAssert["BRIDGE 1 spin lift [has content]: Inverse[S] . gamma^a . S == Lambda^a_b gamma^b  (S is the spin lift of Lambda)",
  cfZeroArrayQ[Table[cfSpinLiftBoostInv . T16[a - 1] . cfSpinLiftBoost
     - Sum[cfLambda[[a, b]] T16[b - 1], {b, 8}], {a, 8}]]];
GammaSpinBoost = cfTimed["BRIDGE 1 16x16 spin-connection matrices",
  Table[cfSimpArray[cfSpinMatrix[omegaBoost, mu]], {mu, 8}]];
cfAssert["COMPARISON 1 at the spinor level [THE GAUGE LAW]: Gamma'_mu == S Gamma_mu Inverse[S] - D[S,x_mu] Inverse[S]",
  cfZeroArrayQ[Table[GammaSpinBoost[[mu]]
     - (cfSpinLiftBoost . GammaSpinCanonical[[mu]] . cfSpinLiftBoostInv
        - D[cfSpinLiftBoost, X[[mu]]] . cfSpinLiftBoostInv), {mu, 8}]]];
cfAssert["COMPARISON 1 at the spinor level: the inhomogeneous term is -D[theta,x_mu] SAB[[1,5]], the spin image of -D[theta,x_mu] K",
  cfZeroArrayQ[Table[GammaSpinBoost[[mu]] - cfSpinLiftBoost . GammaSpinCanonical[[mu]] . cfSpinLiftBoostInv
     + D[cfBoostRapidity[x0, x4], X[[mu]]] SAB[[1, 5]], {mu, 8}]]];
cfAssert["COMPARISON 1 at the spinor level: and that is exactly cfSpinMatrix applied to the vector difference deltaBoost",
  cfZeroArrayQ[Table[GammaSpinBoost[[mu]] - cfSpinLiftBoost . GammaSpinCanonical[[mu]] . cfSpinLiftBoostInv
     - cfSpinMatrix[cfLowerFirstFlat[deltaBoost, \[Eta]4488], mu], {mu, 8}]]];
cfAssert["BRIDGE 1 [has content]: D'_mu (S psi) == S D_mu psi for a generic spinor -- one covariant derivative, two gauges",
  cfZeroArrayQ[Table[D[cfSpinLiftBoost . psiGeneric, X[[mu]]] + GammaSpinBoost[[mu]] . (cfSpinLiftBoost . psiGeneric)
     - cfSpinLiftBoost . (D[psiGeneric, X[[mu]]] + GammaSpinCanonical[[mu]] . psiGeneric), {mu, 8}]]];
gammaCurvedBoost = cfSimpArray @ Table[Sum[Inverse[frameBoost][[a, mu]] T16[a - 1], {a, 8}], {mu, 8}];
cfAssert["BRIDGE 1: the curved Dirac matrices of the boosted frame are S gamma^mu Inverse[S]",
  cfZeroArrayQ[Table[gammaCurvedBoost[[mu]]
     - cfSpinLiftBoost . gammaCurvedCanonical[[mu]] . cfSpinLiftBoostInv, {mu, 8}]]];
cfAssert["BRIDGE 1: so the Dirac operator is one operator in two gauges, Dirac'[S psi] == S Dirac[psi]",
  cfZeroArrayQ[Sum[gammaCurvedBoost[[mu]] . (D[cfSpinLiftBoost . psiGeneric, X[[mu]]]
       + GammaSpinBoost[[mu]] . (cfSpinLiftBoost . psiGeneric)), {mu, 8}]
     - cfSpinLiftBoost . cfDiracOperator[psiGeneric]]];
{Count[Flatten[GammaSpinBoost], Except[0]], " non-zero entries in the eight 16x16 spinor-connection matrices"}
]];

(* ---------- Input cell 126 ---------- *)
cfRunCell[126, Hold[
ClearAll[cfU, \[Eta]Null, frameNull];
cfU = (1/Sqrt[2]) ArrayFlatten[{{ID4, ID4}, {ID4, -ID4}}];
cfAssert["U is an involution: U . U == ID8", cfZeroArrayQ[cfU . cfU - ID8]];
cfAssert["U is symmetric", cfU === Transpose[cfU]];
\[Eta]Null = FullSimplify[Transpose[cfU] . \[Eta]4488 . cfU];
cfAssert["THE NULL TANGENT METRIC IS EXACTLY THE SPINOR METRIC sigma", \[Eta]Null === \[Sigma]];
cfAssert["etaNull is symmetric and squares to ID8",
  {\[Eta]Null === Transpose[\[Eta]Null], \[Eta]Null . \[Eta]Null === ID8}];
cfAssert["all eight frame directions are null: etaNull has zero diagonal",
  Diagonal[\[Eta]Null] === ConstantArray[0, 8]];
MatrixForm[\[Eta]Null]
]];

(* ---------- Input cell 127 ---------- *)
cfRunCell[127, Hold[
frameNull = cfSimpArray[frameCanonical . cfU];
cfAssert["BRIDGE 2 reproduces the SAME curved metric g",
  cfZeroArrayQ[frameNull . \[Eta]Null . Transpose[frameNull] - gCanonical]];
MatrixForm[frameNull]
]];

(* ---------- Input cell 128 ---------- *)
cfRunCell[128, Hold[
(* --- the new spin connection ------------------------------------------------------------- *)
ClearAll[omegaNullMixed, omegaNull];
omegaNullMixed = cfTimed["BRIDGE 2 spin connection",
  cfSpinConnection[frameNull, X, \[Eta]Null, GammaCanonical]];
omegaNull = cfLowerFirstFlat[omegaNullMixed, \[Eta]Null];
cfAssert["BRIDGE 2: vielbein postulate holds identically",
  cfZeroArrayQ[cfVielbeinResidual[frameNull, X, GammaCanonical, omegaNullMixed]]];
cfAssert["BRIDGE 2: omega[mu,a,b] == -omega[mu,b,a] with indices lowered by etaNull",
  cfZeroArrayQ[Table[omegaNull[[mu, a, b]] + omegaNull[[mu, b, a]], {mu, 8}, {a, 8}, {b, 8}]]];
cfAssert["BRIDGE 2: torsion vanishes",
  cfZeroArrayQ[cfTorsion[frameNull, X, omegaNullMixed]]];
{Count[Flatten[omegaNull], Except[0]], " non-zero components"}
]];

(* ---------- Input cell 129 ---------- *)
cfRunCell[129, Hold[
(* --- COMPARISON 2: a CONSTANT similarity, with no inhomogeneous term --------------------- *)
(* Here L == U, so M == Transpose[U] == U and Inverse[M] == U; and because U is constant the  *)
(* gauge term D[M,x_mu] . Inverse[M] is identically zero.                                     *)
ClearAll[deltaNull];
cfAssert["COMPARISON 2: omegaNull == U . omegaCanonical . U exactly",
  cfZeroArrayQ[Table[omegaNullMixed[[mu]] - cfU . omegaCanonicalMixed[[mu]] . cfU, {mu, 8}]]];
deltaNull = cfSimpArray[Table[omegaNullMixed[[mu]] - cfU . omegaCanonicalMixed[[mu]] . cfU,
   {mu, 8}]];
cfAssert["COMPARISON 2: the inhomogeneous gauge term is ZERO because U is constant",
  cfZeroArrayQ[Table[D[cfU, X[[mu]]], {mu, 8}]]];
cfShowConnection[omegaNull, "omegaNull"]
]];

(* ---------- Input cell 130 ---------- *)
cfRunCell[130, Hold[
(* --- the curvature is the constant conjugate, so again the same geometry ----------------- *)
ClearAll[RiemannNull, RicciScalarNull];
RiemannNull = cfTimed["BRIDGE 2 curvature 2-form", cfCurvature[omegaNullMixed, X]];
cfAssert["COMPARISON 2: R_null == U . R_canonical . U",
  cfZeroArrayQ[Table[RiemannNull[[mu, nu]] - cfU . RiemannCanonical[[mu, nu]] . cfU,
    {mu, 8}, {nu, 8}]]];
RicciScalarNull = cfTimed["BRIDGE 2 Ricci scalar",
  cfRicciScalar[frameNull, RiemannNull, gInvCanonical]];
cfAssert["COMPARISON 2: BRIDGE 2 has the SAME Ricci scalar as the canonical frame",
  cfZeroQ[RicciScalarNull - RicciScalarCanonical]];
{RicciScalarCanonical, RicciScalarNull}
]];

(* ---------- Input cell 131 ---------- *)
cfRunCell[131, Hold[
ClearAll[frameTri, \[Eta]TriFlat];
\[Eta]TriFlat = \[Eta]Tri;                       (* == sigma, proved in Section 9 *)
cfAssert["the triality bridge is Euclidean-orthogonal: Transpose[P] == Inverse[P]",
  cfZeroArrayQ[Transpose[triVecToSpin] - triSpinToVec]];
cfAssert["but it is NOT in O(4,4): P . eta4488 . Transpose[P] != eta4488 (it carries eta4488 to sigma)",
  cfNonZeroWitnessQ[triVecToSpin . \[Eta]4488 . Transpose[triVecToSpin] - \[Eta]4488]];
frameTri = cfSimpArray[frameCanonical . triVecToSpin];
cfAssert["BRIDGE 3 reproduces the SAME curved metric g",
  cfZeroArrayQ[frameTri . \[Eta]TriFlat . Transpose[frameTri] - gCanonical]];
cfAssert["the triality tangent metric is sigma", \[Eta]TriFlat === \[Sigma]];
MatrixForm[frameTri]
]];

(* ---------- Input cell 132 ---------- *)
cfRunCell[132, Hold[
(* --- the totally antisymmetric structure constants, transported to the spinor basis ------ *)
(* The antisymmetrization is written out over the six permutations of the three POSITIONS,    *)
(* with the standard signs.  Writing it as a sum over Permutations of the index VALUES would  *)
(* be wrong: Signature there is taken relative to sorted order, which produces a totally      *)
(* SYMMETRIC object instead.                                                                 *)
ClearAll[mLowerTotallyAntisym, mSkewSpin];
mLowerTotallyAntisym = Table[
   (1/6) (mLower[[A1, B1, C1]] - mLower[[B1, A1, C1]] - mLower[[A1, C1, B1]]
          - mLower[[C1, B1, A1]] + mLower[[B1, C1, A1]] + mLower[[C1, A1, B1]]),
   {A1, 8}, {B1, 8}, {C1, 8}];
cfAssert["the antisymmetrized structure constants are totally antisymmetric",
  cfZeroArrayQ[{
    Table[mLowerTotallyAntisym[[A1, B1, C1]] + mLowerTotallyAntisym[[B1, A1, C1]],
      {A1, 8}, {B1, 8}, {C1, 8}],
    Table[mLowerTotallyAntisym[[A1, B1, C1]] + mLowerTotallyAntisym[[A1, C1, B1]],
      {A1, 8}, {B1, 8}, {C1, 8}]}]];
cfAssert["they agree with mLower on the seven imaginary directions",
  cfZeroArrayQ[Table[mLowerTotallyAntisym[[A1, B1, C1]] - mLower[[A1, B1, C1]],
    {A1, 2, 8}, {B1, 2, 8}, {C1, 2, 8}]]];
(* transport all three indices through the triality bridge; total antisymmetry is preserved *)
mSkewSpin = cfTimed["transport the skew structure constants to the spinor basis",
  Table[Sum[triSpinToVec[[a, A1]] triSpinToVec[[b, B1]] triSpinToVec[[c, C1]]
      mLowerTotallyAntisym[[A1, B1, C1]], {A1, 8}, {B1, 8}, {C1, 8}], {a, 8}, {b, 8}, {c, 8}]];
cfAssert["mSkewSpin is totally antisymmetric",
  cfZeroArrayQ[{Table[mSkewSpin[[a, b, c]] + mSkewSpin[[b, a, c]], {a, 8}, {b, 8}, {c, 8}],
                Table[mSkewSpin[[a, b, c]] + mSkewSpin[[a, c, b]], {a, 8}, {b, 8}, {c, 8}]}]];
{Dimensions[mSkewSpin], Count[Flatten[mSkewSpin], Except[0]], " non-zero components"}
]];

(* ---------- Input cell 133 ---------- *)
cfRunCell[133, Hold[
(* --- first the Levi-Civita connection in the triality frame (the lambda = 0 case) -------- *)
ClearAll[omegaTriLCMixed, omegaTriLC];
omegaTriLCMixed = cfTimed["BRIDGE 3 Levi-Civita part",
  cfSpinConnection[frameTri, X, \[Eta]TriFlat, GammaCanonical]];
omegaTriLC = cfLowerFirstFlat[omegaTriLCMixed, \[Eta]TriFlat];
cfAssert["BRIDGE 3 (lambda=0): vielbein postulate holds identically",
  cfZeroArrayQ[cfVielbeinResidual[frameTri, X, GammaCanonical, omegaTriLCMixed]]];
cfAssert["BRIDGE 3 (lambda=0): omega[mu,a,b] == -omega[mu,b,a]",
  cfZeroArrayQ[Table[omegaTriLC[[mu, a, b]] + omegaTriLC[[mu, b, a]],
    {mu, 8}, {a, 8}, {b, 8}]]];
cfAssert["BRIDGE 3 (lambda=0) is the constant triality conjugate of the canonical connection",
  cfZeroArrayQ[Table[omegaTriLCMixed[[mu]]
      - triSpinToVec . omegaCanonicalMixed[[mu]] . triVecToSpin, {mu, 8}]]];
{Count[Flatten[omegaTriLC], Except[0]], " non-zero components"}
]];

(* ---------- Input cell 134 ---------- *)
cfRunCell[134, Hold[
(* --- now the NEW octonionic connection with totally antisymmetric torsion ---------------- *)
ClearAll[\[Lambda]Oct, contortionOct, omegaOct, omegaOctMixed];
(* lambda is a free real torsion-strength parameter introduced here, not in the original *)
contortionOct = Table[\[Lambda]Oct Sum[mSkewSpin[[a, b, c]] frameTri[[mu, c]], {c, 8}],
   {mu, 8}, {a, 8}, {b, 8}];
omegaOct = cfSimpArray[omegaTriLC + contortionOct];
(* raise the first flat index again; the triality tangent metric sigma is its own inverse *)
omegaOctMixed = Table[Sum[\[Eta]TriFlat[[a, c]] omegaOct[[mu, c, b]], {c, 8}],
   {mu, 8}, {a, 8}, {b, 8}];
cfAssert["BRIDGE 3: omegaOct[mu,a,b] == -omegaOct[mu,b,a]  (still metric compatible)",
  cfZeroArrayQ[Table[omegaOct[[mu, a, b]] + omegaOct[[mu, b, a]], {mu, 8}, {a, 8}, {b, 8}]]];
cfAssert["BRIDGE 3: at lambda = 0 it reduces to the Levi-Civita connection",
  cfZeroArrayQ[(omegaOct /. \[Lambda]Oct -> 0) - omegaTriLC]];
{Count[Flatten[contortionOct], Except[0]], " non-zero contortion components"}
]];

(* ---------- Input cell 135 ---------- *)
cfRunCell[135, Hold[
(* --- the torsion of the octonionic connection is non-zero and totally antisymmetric ------ *)
ClearAll[torsionOct, torsionOctFlat];
torsionOct = cfTimed["BRIDGE 3 torsion 2-form", cfTorsion[frameTri, X, omegaOctMixed]];
cfAssert["BRIDGE 3: torsion vanishes at lambda = 0",
  cfZeroArrayQ[torsionOct /. \[Lambda]Oct -> 0]];
cfAssert["BRIDGE 3: torsion is NOT zero for lambda != 0",
  cfNonZeroWitnessQ[torsionOct /. \[Lambda]Oct -> 1]];
(* pull the torsion back to all-flat indices: T_{abc} = eta_{ad} T^d_{mu nu} e_b^mu e_c^nu *)
torsionOctFlat = cfTimed["BRIDGE 3 torsion with all indices flat",
  Module[{cofr = cfSimpArray[Inverse[frameTri]]},
   cfSimpArray @ Table[
     Sum[\[Eta]TriFlat[[a, d]] torsionOct[[d, mu, nu]] cofr[[b, mu]] cofr[[c, nu]],
       {d, 8}, {mu, 8}, {nu, 8}], {a, 8}, {b, 8}, {c, 8}]]];
cfAssert["BRIDGE 3: the flat torsion T[a,b,c] is TOTALLY ANTISYMMETRIC",
  cfZeroArrayQ[{Table[torsionOctFlat[[a, b, c]] + torsionOctFlat[[b, a, c]],
                  {a, 8}, {b, 8}, {c, 8}],
                Table[torsionOctFlat[[a, b, c]] + torsionOctFlat[[a, c, b]],
                  {a, 8}, {b, 8}, {c, 8}]}]];
cfAssert["BRIDGE 3: T[a,b,c] == -2 lambda mSkewSpin[a,b,c]",
  cfZeroArrayQ[Table[torsionOctFlat[[a, b, c]] + 2 \[Lambda]Oct mSkewSpin[[a, b, c]],
    {a, 8}, {b, 8}, {c, 8}]]];
{Count[Flatten[torsionOctFlat], Except[0]], " non-zero flat torsion components"}
]];

(* ---------- Input cell 136 ---------- *)
cfRunCell[136, Hold[
(* --- COMPARISON 3: the difference from the canonical connection is exactly the contortion - *)
ClearAll[deltaOct, contortionOctMixed];
contortionOctMixed = Table[Sum[\[Eta]TriFlat[[a, c]] contortionOct[[mu, c, b]], {c, 8}],
   {mu, 8}, {a, 8}, {b, 8}];
deltaOct = cfSimpArray[Table[
    omegaOctMixed[[mu]] - triSpinToVec . omegaCanonicalMixed[[mu]] . triVecToSpin, {mu, 8}]];
cfAssert["COMPARISON 3: omegaOct - (triality conjugate of omegaCanonical) == contortion",
  cfZeroArrayQ[deltaOct - contortionOctMixed]];
cfAssert["COMPARISON 3: the difference is linear in lambda and vanishes at lambda = 0",
  cfZeroArrayQ[deltaOct /. \[Lambda]Oct -> 0]];
{Count[Flatten[deltaOct], Except[0]], " non-zero components in the difference"}
]];

(* ---------- Input cell 137 ---------- *)
cfRunCell[137, Hold[
ClearAll[RiemannOct, RicciScalarOct, contortionOctUnit, mSkewNormSq, torsionOctNormSq];
RiemannOct = cfTimed["BRIDGE 3 curvature 2-form", cfCurvature[omegaOctMixed, X]];
cfAssert["BRIDGE 3: at lambda = 0 the curvature is the triality conjugate of the canonical curvature",
  cfZeroArrayQ[Table[(RiemannOct[[mu, nu]] /. \[Lambda]Oct -> 0)
      - triSpinToVec . RiemannCanonical[[mu, nu]] . triVecToSpin, {mu, 8}, {nu, 8}]]];
cfAssert["BRIDGE 3 [has content]: the curvature DOES depend on lambda (witnessed)",
  cfNonZeroWitnessQ[D[RiemannOct, \[Lambda]Oct]]];
cfAssert["BRIDGE 3: the lambda-dependence is a polynomial of degree exactly two",
  cfZeroArrayQ[D[RiemannOct, {\[Lambda]Oct, 3}]]];
contortionOctUnit = contortionOctMixed /. \[Lambda]Oct -> 1;                    (* K at lambda = 1 *)
cfAssert["BRIDGE 3: the lambda^1 term is the Levi-Civita covariant exterior derivative of the contortion, dK + [omegaTriLC, K]",
  cfZeroArrayQ[Table[(D[RiemannOct[[mu, nu]], \[Lambda]Oct] /. \[Lambda]Oct -> 0)
      - (D[contortionOctUnit[[nu]], X[[mu]]] - D[contortionOctUnit[[mu]], X[[nu]]]
         + omegaTriLCMixed[[mu]] . contortionOctUnit[[nu]] - contortionOctUnit[[nu]] . omegaTriLCMixed[[mu]]
         + contortionOctUnit[[mu]] . omegaTriLCMixed[[nu]] - omegaTriLCMixed[[nu]] . contortionOctUnit[[mu]]),
      {mu, 8}, {nu, 8}]]];
cfAssert["BRIDGE 3: the lambda^2 term is [K_mu, K_nu], the contortion commuted with itself",
  cfZeroArrayQ[Table[(1/2) D[RiemannOct[[mu, nu]], {\[Lambda]Oct, 2}]
      - (contortionOctUnit[[mu]] . contortionOctUnit[[nu]] - contortionOctUnit[[nu]] . contortionOctUnit[[mu]]),
      {mu, 8}, {nu, 8}]]];
RicciScalarOct = cfTimed["BRIDGE 3 Ricci scalar", cfRicciScalar[frameTri, RiemannOct, gInvCanonical]];
cfAssert["BRIDGE 3: at lambda = 0 the Ricci scalar is the canonical one",
  cfZeroQ[(RicciScalarOct /. \[Lambda]Oct -> 0) - RicciScalarCanonical]];
mSkewNormSq = Sum[mSkewSpin[[a, b, c]] mSkewSpin[[d, e, f]]
     \[Eta]TriFlat[[a, d]] \[Eta]TriFlat[[b, e]] \[Eta]TriFlat[[c, f]],
   {a, 8}, {b, 8}, {c, 8}, {d, 8}, {e, 8}, {f, 8}];                             (* mSkew . mSkew *)
torsionOctNormSq = Sum[torsionOctFlat[[a, b, c]] torsionOctFlat[[d, e, f]]
     \[Eta]TriFlat[[a, d]] \[Eta]TriFlat[[b, e]] \[Eta]TriFlat[[c, f]],
   {a, 8}, {b, 8}, {c, 8}, {d, 8}, {e, 8}, {f, 8}];                             (* T_{abc} T^{abc} *)
cfAssert["BRIDGE 3 [THE RESULT]: R(omegaOct) - R(canonical) == -(1/4) T_{abc} T^{abc}, a constant shift set by the torsion alone",
  cfZeroQ[RicciScalarOct - RicciScalarCanonical + (1/4) torsionOctNormSq]];
cfAssert["BRIDGE 3: equivalently -lambda^2 (mSkew . mSkew), with mSkew . mSkew == 42, so the shift is exactly -42 lambda^2",
  {cfZeroQ[RicciScalarOct - RicciScalarCanonical + \[Lambda]Oct^2 mSkewNormSq], mSkewNormSq === 42,
   cfZeroQ[RicciScalarOct - RicciScalarCanonical + 42 \[Lambda]Oct^2]}];
{Count[Flatten[RiemannOct], Except[0]], " non-zero curvature components;   R(omegaOct) - R(canonical) = ",
 FullSimplify[RicciScalarOct - RicciScalarCanonical]}
]];

(* ---------- Input cell 138 ---------- *)
cfRunCell[138, Hold[
ClearAll[T16Tri, cfSpinMatrixTri];
T16Tri[a_Integer] := T16Tri[a] = Sum[triSpinToVec[[a, A1]] T16[A1 - 1], {A1, 8}];
cfAssert["THE TRIALITY DIRAC MATRICES OBEY THE sigma CLIFFORD RELATION: {T16Tri[a],T16Tri[b]} == 2 sigma[[a,b]] ID16",
  cfZeroArrayQ[Table[T16Tri[a] . T16Tri[b] + T16Tri[b] . T16Tri[a]
     - 2 \[Eta]TriFlat[[a, b]] ID16, {a, 8}, {b, 8}]]];
cfAssert["they are NOT the vector-frame Dirac matrices, so the distinction is real",
  cfNonZeroWitnessQ[Table[T16Tri[a] - T16[a - 1], {a, 8}]]];
cfSpinMatrixTri[om_, mu_Integer] :=
  (1/8) Sum[om[[mu, a, b]] (T16Tri[a] . T16Tri[b] - T16Tri[b] . T16Tri[a]), {a, 8}, {b, 8}];
]];

(* ---------- Input cell 139 ---------- *)
cfRunCell[139, Hold[
(* --- the effect on the spinor covariant derivative: the torsion's so(4,4) piece ---------- *)
(* Dcov picks up (lambda/8) mSkew[a,b,c] frameTri[[mu,c]] Commutator[gammaTri^a, gammaTri^b]. *)
(* Count the gammas: that expression is QUADRATIC in gamma, not cubic.  The third structure-  *)
(* constant index c is contracted against the FRAME, frameTri[[mu,c]], not against a third    *)
(* gamma.  What this cell exhibits is therefore the torsion's contribution to the so(4,4)     *)
(* part of the spinor connection, generated by the split-octonion multiplication itself       *)
(* rather than put in by hand.                                                                *)
(* The familiar Einstein-Cartan AXIAL term, T[a,b,c] gamma^a gamma^b gamma^c, is the genuinely *)
(* cubic object, and it appears only after this connection piece is contracted with the        *)
(* gamma^mu of the Dirac operator.  This notebook does not perform that contraction, so it     *)
(* does not claim to have displayed the axial coupling.                                        *)
ClearAll[GammaSpinOct, GammaSpinOctExtra];
GammaSpinOct = cfTimed["BRIDGE 3 16x16 spin-connection matrices",
  Table[cfSimpArray[cfSpinMatrixTri[omegaOct, mu]], {mu, 8}]];
GammaSpinOctExtra = cfTimed["BRIDGE 3 extra spinor coupling from the torsion",
  Table[cfSimpArray[cfSpinMatrixTri[contortionOct, mu]], {mu, 8}]];
(* consistency: at lambda = 0 the Bridge 3 spinor connection must be the SAME 16x16 matrix as *)
(* the canonical one, because the two frames differ by a constant change of basis under which *)
(* omega and the Dirac matrices are transported together (T16Tri is the transport of T16).    *)
cfAssert["at lambda = 0 the Bridge 3 spinor connection equals the canonical one",
  cfZeroArrayQ[Table[(GammaSpinOct[[mu]] /. \[Lambda]Oct -> 0) - GammaSpinCanonical[[mu]], {mu, 8}]]];
cfAssert["the extra spinor coupling vanishes at lambda = 0",
  cfZeroArrayQ[GammaSpinOctExtra /. \[Lambda]Oct -> 0]];
cfAssert["the extra spinor coupling is non-zero for lambda != 0",
  cfNonZeroWitnessQ[GammaSpinOctExtra /. \[Lambda]Oct -> 1]];
cfAssert["the extra spinor coupling is still block diagonal (type-1 + type-2 preserved)",
  cfZeroArrayQ[Table[GammaSpinOctExtra[[mu]]
      - ArrayFlatten[{{GammaSpinOctExtra[[mu]][[1 ;; 8, 1 ;; 8]], 0},
                      {0, GammaSpinOctExtra[[mu]][[9 ;; 16, 9 ;; 16]]}}], {mu, 8}]]];
{Count[Flatten[GammaSpinOctExtra], Except[0]], " non-zero entries in the extra coupling"}
]];

(* ---------- Input cell 140 ---------- *)
cfRunCell[140, Hold[
(* --- the Weitzenboeck affine connection: the frame is parallel ---------------------------- *)
(* Gamma^W[[rho,mu,nu]] = e_a^rho d_mu e_nu^a.  With this affine connection the covariant       *)
(* derivative of every frame vector vanishes identically, which is the DEFINITION of the       *)
(* fable-5.1 bridge.  It uses the same frame, the same coframe and the same coordinates as     *)
(* Section 15; nothing new is introduced except the transport rule.                           *)
ClearAll[GammaWeitzenboeck, cfFable51Frame, cfFable51Coframe];
cfFable51Frame   = frameCanonical;
cfFable51Coframe = coframeCanonical;
GammaWeitzenboeck = cfTimed["fable-5.1: Weitzenboeck affine connection Gamma^W = e_a^rho d_mu e_nu^a",
  cfSimpArray @ Table[Sum[cfFable51Coframe[[a, r]] D[cfFable51Frame[[p, a]], X[[m]]], {a, 8}],
    {r, 8}, {m, 8}, {p, 8}]];
cfAssert["FABLE-5.1 [definition]: the frame is parallel  --  nabla^W e == 0 for all eight frame vectors",
  cfZeroArrayQ[Table[D[cfFable51Frame[[nu, a]], X[[mu]]]
      - Sum[GammaWeitzenboeck[[r, mu, nu]] cfFable51Frame[[r, a]], {r, 8}], {mu, 8}, {nu, 8}, {a, 8}]]];
cfAssert["FABLE-5.1 [has content]: Gamma^W is metric compatible, nabla^W g == 0",
  cfZeroArrayQ[Table[D[gCanonical[[m, p]], X[[k]]]
      - Sum[GammaWeitzenboeck[[s, k, m]] gCanonical[[s, p]] + GammaWeitzenboeck[[s, k, p]] gCanonical[[m, s]],
          {s, 8}], {k, 8}, {m, 8}, {p, 8}]]];
cfAssert["FABLE-5.1 [has content]: Gamma^W is NOT symmetric in its lower indices -- it has torsion",
  cfNonZeroWitnessQ[Table[GammaWeitzenboeck[[r, m, p]] - GammaWeitzenboeck[[r, p, m]],
      {r, 8}, {m, 8}, {p, 8}]]];
cfAssert["FABLE-5.1 [has content]: Gamma^W is NOT the Levi-Civita connection",
  cfNonZeroWitnessQ[GammaWeitzenboeck - GammaCanonical]];
{Dimensions[GammaWeitzenboeck], Count[Flatten[GammaWeitzenboeck], Except[0]], " non-zero components"}
]];

(* ---------- Input cell 141 ---------- *)
cfRunCell[141, Hold[
ClearAll[omegaFable51Mixed, omegaFable51];
omegaFable51Mixed = cfTimed["fable-5.1 spin connection from the vielbein postulate, with Gamma^W",
  cfSpinConnection[cfFable51Frame, X, \[Eta]4488, GammaWeitzenboeck]];
omegaFable51 = cfLowerFirstFlat[omegaFable51Mixed, \[Eta]4488];
cfAssert["FABLE-5.1 [solver regression]: vielbein postulate residual is zero",
  cfZeroArrayQ[cfVielbeinResidual[cfFable51Frame, X, GammaWeitzenboeck, omegaFable51Mixed]]];
cfAssert["FABLE-5.1 [THE RESULT]: the spin connection in the canonical frame is IDENTICALLY ZERO",
  cfZeroArrayQ[omegaFable51Mixed]];
cfAssert["FABLE-5.1: trivially antisymmetric, so trivially metric compatible",
  cfZeroArrayQ[Table[omegaFable51[[mu, a, b]] + omegaFable51[[mu, b, a]], {mu, 8}, {a, 8}, {b, 8}]]];
{Count[Flatten[omegaFable51], Except[0]], " non-zero components  (zero: the frame is parallel)"}
]];

(* ---------- Input cell 142 ---------- *)
cfRunCell[142, Hold[
(* --- the torsion of the fable-5.1 bridge, and its curvature ------------------------------ *)
(* With omega == 0 the torsion 2-form of Section 16 reduces to the exterior derivative of the  *)
(* frame, T^a_{mu nu} = d_mu e_nu^a - d_nu e_mu^a, and the curvature 2-form reduces to zero.  *)
ClearAll[torsionFable51, torsionFable51Curved, RiemannFable51];
torsionFable51 = cfTimed["fable-5.1 torsion 2-form  T^a_{mu nu} = d_mu e_nu^a - d_nu e_mu^a",
  cfTorsion[cfFable51Frame, X, omegaFable51Mixed]];
torsionFable51Curved = cfSimpArray @ Table[Sum[cfFable51Coframe[[a, r]] torsionFable51[[a, m, p]], {a, 8}],
   {r, 8}, {m, 8}, {p, 8}];
cfAssert["FABLE-5.1 [has content]: the torsion is NOT zero",
  cfNonZeroWitnessQ[torsionFable51]];
cfAssert["FABLE-5.1: T^rho_{mu nu} == Gamma^W[rho,mu,nu] - Gamma^W[rho,nu,mu]  (torsion is the antisymmetric part of Gamma^W)",
  cfZeroArrayQ[torsionFable51Curved
     - Table[GammaWeitzenboeck[[r, m, p]] - GammaWeitzenboeck[[r, p, m]], {r, 8}, {m, 8}, {p, 8}]]];
RiemannFable51 = cfTimed["fable-5.1 curvature 2-form", cfCurvature[omegaFable51Mixed, X]];
cfAssert["FABLE-5.1 [THE RESULT]: the curvature is IDENTICALLY ZERO -- a flat connection on a curved metric",
  cfZeroArrayQ[RiemannFable51]];
{Count[Flatten[torsionFable51], Except[0]], " non-zero torsion components;   curvature components: ",
 Count[Flatten[RiemannFable51], Except[0]]}
]];

(* ---------- Input cell 143 ---------- *)
cfRunCell[143, Hold[
ClearAll[contortionFable51, contortionFable51Formula, torsionFable51Low, omegaCanonicalFromTorsion];
contortionFable51 = cfSimpArray[GammaWeitzenboeck - GammaCanonical];              (* K^rho_{mu nu} *)
torsionFable51Low = cfSimpArray @ Table[Sum[gCanonical[[r, s]] torsionFable51Curved[[s, m, p]], {s, 8}],
   {r, 8}, {m, 8}, {p, 8}];                                                        (* T_{rho mu nu}  *)
contortionFable51Formula = cfSimpArray @ Table[
   (1/2) Sum[gInvCanonical[[r, s]] (torsionFable51Low[[s, m, p]] + torsionFable51Low[[m, s, p]]
       + torsionFable51Low[[p, s, m]]), {s, 8}], {r, 8}, {m, 8}, {p, 8}];
cfAssert["COMPARISON F [has content]: Gamma^W - Gamma^LC == (1/2)(T_{rmn} + T_{mrn} + T_{nrm}) with the index raised, the contortion formula",
  cfZeroArrayQ[contortionFable51 - contortionFable51Formula]];
omegaCanonicalFromTorsion = cfSimpArray @ Table[
   -Sum[contortionFable51[[r, mu, nu]] cfFable51Frame[[r, a]] cfFable51Coframe[[b, nu]], {r, 8}, {nu, 8}],
   {mu, 8}, {a, 8}, {b, 8}];
cfAssert["COMPARISON F [THE RESULT]: omegaCanonical == - contortion(fable-5.1 torsion), pulled back to flat indices, exactly",
  cfZeroArrayQ[omegaCanonicalFromTorsion - omegaCanonicalMixed]];
cfAssert["COMPARISON F: so omegaCanonical - omegaFable51 is a TENSOR, not a gauge term (omegaFable51 == 0)",
  cfZeroArrayQ[(omegaCanonicalMixed - omegaFable51Mixed) - omegaCanonicalFromTorsion]];
{Count[Flatten[contortionFable51], Except[0]], " non-zero contortion components  ==  ",
 Count[Flatten[omegaCanonical], Except[0]], " non-zero canonical spin-connection components"}
]];

(* ---------- Input cell 144 ---------- *)
cfRunCell[144, Hold[
ClearAll[torsionVectorFable51, torsionPotentialFable51, torsionFable51Flat, torsionAxialFable51];
torsionVectorFable51 = cfSimpArray @ Table[Sum[torsionFable51Curved[[nu, nu, mu]], {nu, 8}], {mu, 8}];
torsionPotentialFable51 = Log[Sin[6 H x0]];
cfAssert["FABLE-5.1 torsion vector T[mu] = T[nu,nu,mu] is a GRADIENT: T[mu] == D[Log[Sin[6 H x0]], x[mu]]",
  cfZeroArrayQ[torsionVectorFable51 - Table[D[torsionPotentialFable51, X[[mu]]], {mu, 8}]]];
cfAssert["FABLE-5.1 torsion vector has exactly one non-zero component, 6 H Cot[6 H x0] along x0",
  cfZeroArrayQ[torsionVectorFable51 - {6 H Cot[6 H x0], 0, 0, 0, 0, 0, 0, 0}]];
(* pull the torsion to all-flat lowered indices, as Section 20 did for Bridge 3 *)
torsionFable51Flat = cfSimpArray @ Table[
   Sum[\[Eta]4488[[a, d]] torsionFable51[[d, mu, nu]] cfFable51Coframe[[b, mu]] cfFable51Coframe[[c, nu]],
     {d, 8}, {mu, 8}, {nu, 8}], {a, 8}, {b, 8}, {c, 8}];
torsionAxialFable51 = cfSimpArray @ Table[
   (1/6) (torsionFable51Flat[[a, b, c]] + torsionFable51Flat[[b, c, a]] + torsionFable51Flat[[c, a, b]]
        - torsionFable51Flat[[b, a, c]] - torsionFable51Flat[[a, c, b]] - torsionFable51Flat[[c, b, a]]),
   {a, 8}, {b, 8}, {c, 8}];
cfAssert["FABLE-5.1: the AXIAL (totally antisymmetric) part of the torsion vanishes -- the complement of Bridge 3",
  cfZeroArrayQ[torsionAxialFable51]];
cfAssert["FABLE-5.1: the torsion itself does not vanish, so the tensor part carries the rest",
  cfNonZeroWitnessQ[torsionFable51Flat]];
Grid[Prepend[Table[{Row[{"T[", mu - 1, "]"}], torsionVectorFable51[[mu]]}, {mu, 8}],
  {"torsion vector component", "value"}], Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 145 ---------- *)
cfRunCell[145, Hold[
ClearAll[torsionScalarFable51, sqrtDetgTele, boundaryTermFable51, torsionFable51Up, torsionVectorFable51Up];
sqrtDetgTele = Sec[6 H x0];
cfAssert["FABLE-5.1: det g == Sec[6 H x0]^2  (positive, as signature 4+4 requires)",
  cfZeroQ[detgCanonical - sqrtDetgTele^2]];
torsionFable51Up = cfSimpArray @ Table[
   Sum[gInvCanonical[[m, mm]] gInvCanonical[[p, pp]] torsionFable51Curved[[r, mm, pp]], {mm, 8}, {pp, 8}],
   {r, 8}, {m, 8}, {p, 8}];                                                        (* T^{r m p} *)
torsionVectorFable51Up = cfSimpArray @ Table[Sum[gInvCanonical[[m, k]] torsionVectorFable51[[k]], {k, 8}], {m, 8}];
torsionScalarFable51 = cfTimed["fable-5.1 torsion scalar T",
  FullSimplify[
    (1/4) Sum[torsionFable51Up[[r, m, p]] torsionFable51Low[[r, m, p]], {r, 8}, {m, 8}, {p, 8}]
    + (1/2) Sum[torsionFable51Up[[r, m, p]] torsionFable51Low[[p, m, r]], {r, 8}, {m, 8}, {p, 8}]
    - Sum[torsionVectorFable51Up[[m]] torsionVectorFable51[[m]], {m, 8}], cfGeomAssume]];
boundaryTermFable51 = cfTimed["fable-5.1 boundary term B = (2/sqrt g) d_mu(sqrt g T^mu)",
  FullSimplify[(2/sqrtDetgTele) Sum[D[sqrtDetgTele torsionVectorFable51Up[[m]], X[[m]]], {m, 8}], cfGeomAssume]];
cfAssert["COMPARISON F [THE RESULT]: R == -T + B  --  the teleparallel equivalent of GR, in closed form for this geometry",
  cfZeroQ[RicciScalarCanonical - (-torsionScalarFable51 + boundaryTermFable51)]];
cfAssert["FABLE-5.1: T is not zero and B is not zero -- neither side is trivial",
  {cfNonZeroWitnessQ[torsionScalarFable51], cfNonZeroWitnessQ[boundaryTermFable51]}];
Grid[{{"R  (Levi-Civita scalar curvature, Section 16)", RicciScalarCanonical},
      {"T  (fable-5.1 torsion scalar)", torsionScalarFable51},
      {"B  (boundary term)", boundaryTermFable51},
      {"R + T - B", FullSimplify[RicciScalarCanonical + torsionScalarFable51 - boundaryTermFable51, cfGeomAssume]}},
  Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 146 ---------- *)
cfRunCell[146, Hold[
ClearAll[cfDiracConnectionTerm, cfPsiPrime, cfDiracFable51];
cfDiracConnectionTerm = cfTimed["gamma^mu Gamma^spin[mu], the connection part of the canonical Dirac operator",
  cfSimpArray[Sum[gammaCurvedCanonical[[mu]] . GammaSpinCanonical[[mu]], {mu, 8}]]];
cfAssert["FABLE-5.1 [THE RESULT]: gamma^mu Gamma^spin[mu] == -(1/2) T[mu] gamma^mu, one vector term",
  cfZeroArrayQ[cfDiracConnectionTerm
     + (1/2) Sum[torsionVectorFable51[[mu]] gammaCurvedCanonical[[mu]], {mu, 8}]]];
cfAssert["FABLE-5.1: equivalently -(1/2) D[Log[Sin[6 H x0]], x_mu] gamma^mu",
  cfZeroArrayQ[cfDiracConnectionTerm
     + (1/2) Sum[D[torsionPotentialFable51, X[[mu]]] gammaCurvedCanonical[[mu]], {mu, 8}]]];
cfPsiPrime = Table[cfPsiP[k] @@ X, {k, 0, 15}];                (* a generic 16-component spinor *)
cfDiracFable51[psi_List] := Sum[gammaCurvedCanonical[[mu]] . D[psi, X[[mu]]], {mu, 8}];   (* no connection *)
cfAssert["FABLE-5.1 [THE RESULT]: DiracCanonical[ Sqrt[Sin[6Hx0]] Psi' ] == Sqrt[Sin[6Hx0]] DiracFable51[Psi'], for a generic Psi'",
  cfZeroArrayQ[cfSimpArray[
    cfDiracOperator[Sqrt[Sin[6 H x0]] cfPsiPrime] - Sqrt[Sin[6 H x0]] cfDiracFable51[cfPsiPrime]]]];
(* witnessed on a concrete spinor, the constant one, because a witness must reduce to numbers *)
cfAssert["FABLE-5.1: the rescaling is NOT a no-op -- the two Dirac operators differ on the constant spinor",
  cfNonZeroWitnessQ[cfDiracOperator[ConstantArray[1, 16]] - cfDiracFable51[ConstantArray[1, 16]]]];
Short[cfDiracConnectionTerm, 4]
]];

(* ---------- Input cell 147 ---------- *)
cfRunCell[147, Hold[
ClearAll[cfLagrangianConnectionTerm];
cfLagrangianConnectionTerm = cfTimed["the connection term of the Dirac Lagrangian, for a generic spinor",
  cfSimp[sqrtDetgTele Transpose[cfPsiPrime] . \[Sigma]16 . (cfDiracConnectionTerm . cfPsiPrime)]];
cfAssert["FABLE-5.1 [THE RESULT]: Psi^T sigma16 gamma^mu Gamma^spin[mu] Psi == 0 for EVERY Psi -- the spin connection drops out of the Lagrangian",
  cfZeroQ[cfLagrangianConnectionTerm]];
cfAssert["FABLE-5.1: the reason is Section 11's identity, Psi^T sigma16 T16[a] Psi == 0 (sigma16 T16[a] antisymmetric)",
  cfZeroArrayQ[Table[Expand[Transpose[cfPsiPrime] . \[Sigma]16 . T16[a - 1] . cfPsiPrime], {a, 8}]]];
cfAssert["FABLE-5.1: but the connection term does NOT drop out of the Dirac OPERATOR (it is -(1/2) T[mu] gamma^mu, non-zero)",
  cfNonZeroWitnessQ[cfDiracConnectionTerm]];
(* What the author's flat Lagrangian La omits: exactly the volume factor and the coframe.        *)
(* The covariant Lagrangian is written as a function of the frame and the volume factor, with   *)
(* the author's own 1/H normalization kept, so that setting frame -> ID8 and sqrtg -> 1 is a    *)
(* genuine substitution and not a no-op on already-evaluated symbols.                            *)
ClearAll[cfLagrangianCovariant, cfLagrangianAuthorForm];
cfLagrangianCovariant[psi_List, frame_, sqrtg_] := Module[{cofr = Inverse[frame]},
  (1/H) sqrtg Transpose[psi] . \[Sigma]16 .
      Sum[Sum[cofr[[a, mu]] T16[a - 1], {a, 8}] . D[psi, X[[mu]]], {mu, 8}]
  + 2 (M/H) sqrtg Transpose[psi] . \[Sigma]16 . psi];
(* The outer parentheses are load-bearing.  Without them the second line, which begins with   *)
(* "+", is a complete expression on its own and Mathematica evaluates it as one: the definition *)
(* silently loses its mass term.  Section 11's La[] has the same parentheses for the same reason. *)
cfLagrangianAuthorForm[psi_List] := ((1/H) Transpose[psi] . \[Sigma]16 . Sum[T16[a - 1] . D[psi, X[[a]]], {a, 8}]
  + 2 (M/H) Transpose[psi] . \[Sigma]16 . psi);
cfAssert["FABLE-5.1: the author-form helper applied to Psi16 IS Section 11's La[] (the two are the same expression)",
  cfZeroQ[cfLagrangianAuthorForm[\[CapitalPsi]16] - La[]]];
cfAssert["FABLE-5.1: the covariant Lagrangian with frame -> ID8 and volume factor -> 1 IS the author's La of Section 11, term for term",
  Expand[cfLagrangianCovariant[cfPsiPrime, ID8, 1] - cfLagrangianAuthorForm[cfPsiPrime]] === 0];
(* witnessed on a constant spinor: the kinetic terms vanish and the mass terms differ by the    *)
(* volume factor.  Not the all-ones spinor, for which psi^T sigma16 psi == 0; e1 + e5 gives -2. *)
(* The mass M is a free constant of the model with no probe value, and a witness must reduce to *)
(* a number, so M is set to 1 inside this one test and nowhere else.                            *)
cfAssert["FABLE-5.1: with the real frame and volume factor it is NOT the author's La -- witnessed on the constant spinor e1 + e5 (at M = 1)",
  cfNonZeroWitnessQ[(cfLagrangianCovariant[UnitVector[16, 1] + UnitVector[16, 5], cfFable51Frame, sqrtDetgTele]
      - cfLagrangianAuthorForm[UnitVector[16, 1] + UnitVector[16, 5]]) /. M -> 1]];
cfAssert["FABLE-5.1: and the covariant Lagrangian has NO connection term to omit -- its kinetic term is already the fable-5.1 one",
  Expand[cfLagrangianCovariant[cfPsiPrime, cfFable51Frame, sqrtDetgTele]
     - ((1/H) sqrtDetgTele Transpose[cfPsiPrime] . \[Sigma]16 . cfDiracFable51[cfPsiPrime]
        + 2 (M/H) sqrtDetgTele Transpose[cfPsiPrime] . \[Sigma]16 . cfPsiPrime)] === 0];
{"connection term of the Lagrangian, simplified: ", cfLagrangianConnectionTerm}
]];

(* ---------- Input cell 148 ---------- *)
cfRunCell[148, Hold[
ClearAll[omegaFable51BoostMixed, omegaFable51BoostPredicted];
(* Simplify::time is EXPECTED here and only here in Part V: the solver simplifies each entry     *)
(* under Section 1's 1-second budget, and entries built from Cosh and Sinh of the undetermined   *)
(* rapidity exceed it.  A budget that is reached returns a correct, merely less-simplified,      *)
(* result; the assertions below then close every identity symbolically.  The message is         *)
(* announced first and suppressed for this one computation, exactly as Section 14 does.          *)
Print["  EXPECTED MESSAGE  Simplify::time may fire while solving the vielbein postulate in the"];
Print["                    boosted frame; the 1-second budget is Section 1's, and a budget that"];
Print["                    is reached still returns a correct, merely less-simplified, result."];
omegaFable51BoostMixed = cfTimed["fable-5.1 spin connection in Bridge 1's boosted frame",
  Quiet[cfSpinConnection[frameBoost, X, \[Eta]4488, GammaWeitzenboeck], {Simplify::time, General::stop}]];
(* the independent route: Part IV's lemma with omegaOld == 0 predicts omegaNew == -D[M] Inverse[M] *)
omegaFable51BoostPredicted = Table[cfSimpArray[-D[cfM, X[[mu]]] . cfMinv], {mu, 8}];
cfAssert["FABLE-5.1 in the boosted frame: vielbein postulate residual is zero",
  Quiet[cfZeroArrayQ[cfVielbeinResidual[frameBoost, X, GammaWeitzenboeck, omegaFable51BoostMixed]], {Simplify::time, General::stop}]];
cfAssert["FABLE-5.1 in the boosted frame [THE RESULT]: omega == -D[M,x_mu] Inverse[M], pure gauge and nothing else",
  cfZeroArrayQ[Table[omegaFable51BoostMixed[[mu]] - omegaFable51BoostPredicted[[mu]], {mu, 8}]]];
cfAssert["FABLE-5.1 in the boosted frame: the lemma's prediction itself satisfies the vielbein postulate with Gamma^W",
  Quiet[cfZeroArrayQ[cfVielbeinResidual[frameBoost, X, GammaWeitzenboeck, omegaFable51BoostPredicted]], {Simplify::time, General::stop}]];
cfAssert["FABLE-5.1 in the boosted frame: the curvature is STILL identically zero",
  Quiet[cfZeroArrayQ[cfCurvature[omegaFable51BoostMixed, X]], {Simplify::time, General::stop}]];
cfAssert["and Bridge 1's inhomogeneous term of Section 18 IS this object: deltaBoost == omegaFable51Boost",
  cfZeroArrayQ[Table[deltaBoost[[mu]] - omegaFable51BoostMixed[[mu]], {mu, 8}]]];
cfAssert["so omegaBoost == (canonical, conjugated) + (fable-5.1 in the boosted frame)",
  cfZeroArrayQ[Table[omegaBoostMixed[[mu]]
     - (cfM . omegaCanonicalMixed[[mu]] . cfMinv + omegaFable51BoostMixed[[mu]]), {mu, 8}]]];
{Count[Flatten[omegaFable51BoostMixed], Except[0]], " non-zero components, all pure gauge"}
]];

(* ---------- Input cell 149 ---------- *)
cfRunCell[149, Hold[
ClearAll[cfConnectionSummary];
cfConnectionSummary = {
  {"connection", "frame field", "flat metric", "same g?", "metric compatible?",
   "torsion zero?", "curvature zero?", "difference from canonical", "verdict"},
  {"omegaCanonical", "frameCanonical (diagonal)", "eta4488", "yes (reference)", "yes",
   "yes", "no", "-- (reference)", "Levi-Civita"},
  {"omegaBoost  (Bridge 1)", "frameCanonical . Lambda(x)", "eta4488", "yes", "yes",
   "yes", "no", "gauge term  -D[theta,x_mu] K  (a Weitzenboeck connection, see Part V)",
   "SAME connection, local gauge"},
  {"omegaNull  (Bridge 2)", "frameCanonical . U", "etaNull == sigma", "yes", "yes",
   "yes", "no", "constant similarity  U omega U", "SAME connection, constant gauge"},
  {"omegaOct  (Bridge 3)", "frameCanonical . triVecToSpin", "etaTri == sigma", "yes", "yes",
   "NO: axial torsion  -2 lambda mSkew", "no",
   "contortion  lambda mSkew[a,b,c] frameTri[[mu,c]], a tensor",
   "DIFFERENT connection"},
  {"omegaFable51  (fable-5.1)", "frameCanonical (parallel)", "eta4488", "yes", "yes",
   "NO: vector + tensor torsion, axial part zero", "YES: flat",
   "omegaCanonical == - contortion(T_fable51), a tensor; omegaFable51 == 0",
   "DIFFERENT connection"}};
Grid[cfConnectionSummary, Frame -> All, Alignment -> Left,
  Background -> {None, {LightGray, None, None, None, None, None}}]
]];

(* ---------- Input cell 150 ---------- *)
cfRunCell[150, Hold[
(* --- numerical fingerprint: the count of non-zero components of each object -------------- *)
Grid[{
  {"object", "non-zero components"},
  {"Gamma (Christoffel, Levi-Civita)", Count[Flatten[GammaCanonical], Except[0]]},
  {"Gamma^W (Weitzenboeck, fable-5.1)", Count[Flatten[GammaWeitzenboeck], Except[0]]},
  {"omegaCanonical", Count[Flatten[omegaCanonical], Except[0]]},
  {"omegaBoost", Count[Flatten[omegaBoost], Except[0]]},
  {"omegaNull", Count[Flatten[omegaNull], Except[0]]},
  {"omegaTriLC (lambda=0)", Count[Flatten[omegaTriLC], Except[0]]},
  {"GammaSpinCanonical (16x16 spinor connection)", Count[Flatten[GammaSpinCanonical], Except[0]]},
  {"GammaSpinBoost  (Bridge 1)", Count[Flatten[GammaSpinBoost], Except[0]]},
  {"omegaFable51 (canonical frame)", Count[Flatten[omegaFable51], Except[0]]},
  {"contortionOct  (Bridge 3)", Count[Flatten[contortionOct], Except[0]]},
  {"contortionFable51  (== Gamma^W - Gamma^LC)", Count[Flatten[contortionFable51], Except[0]]},
  {"RiemannCanonical", Count[Flatten[RiemannCanonical], Except[0]]},
  {"RiemannBoost", Count[Flatten[RiemannBoost], Except[0]]},
  {"RiemannNull", Count[Flatten[RiemannNull], Except[0]]},
  {"RiemannOct  (Bridge 3)", Count[Flatten[RiemannOct], Except[0]]},
  {"RiemannFable51", Count[Flatten[RiemannFable51], Except[0]]},
  {"torsionOctFlat  (Bridge 3)", Count[Flatten[torsionOctFlat], Except[0]]},
  {"torsionFable51Flat", Count[Flatten[torsionFable51Flat], Except[0]]}
 }, Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 151 ---------- *)
cfRunCell[151, Hold[
(* --- the four comparisons, side by side -------------------------------------------------- *)
Grid[{
  {"comparison", "statement proved above", "content?"},
  {"BRIDGE 1 vs canonical",
   "omegaBoost_mu == M omegaCanonical_mu Inverse[M] - D[M,x_mu] Inverse[M],  M = Transpose[Lambda]",
   "the gauge transformation law; no new connection"},
  {"BRIDGE 2 vs canonical",
   "omegaNull_mu == U omegaCanonical_mu U   exactly, U constant",
   "a constant change of basis; no new connection"},
  {"BRIDGE 3 vs canonical",
   "omegaOct_mu == Inverse[P] omegaCanonical_mu P + lambda mSkew . frameTri,  P = triVecToSpin",
   "a tensor (contortion with axial torsion); a different connection"},
  {"FABLE-5.1 vs canonical",
   "omegaCanonical == - K(T_fable51) pulled to flat indices;  omegaFable51 == 0;  R == -T + B;"
   <> "  gamma^mu Gamma_mu == -(1/2) T_mu gamma^mu;  Dirac_LC[Sqrt[Sin] Psi'] == Sqrt[Sin] Dirac_fable51[Psi']",
   "a tensor (contortion with vector torsion); a different, FLAT connection; exact spinor equivalence"},
  {"curvature",
   "conjugated under bridges 1 and 2;  for bridge 3 a polynomial of degree exactly 2 in lambda (lambda^0: the conjugated canonical curvature,"
   <> " lambda^1: dK + [omega,K],  lambda^2: [K,K]);  IDENTICALLY ZERO for fable-5.1",
   ""},
  {"Ricci scalar / torsion scalar",
   "R identical for canonical and bridges 1, 2;  R - 42 lambda^2 for bridge 3 (== R - (1/4) T_{abc} T^{abc});"
   <> "  R == -T + B for fable-5.1 with T, B in closed form",
   ""},
  {"spinor level",
   "bridge 1: Gamma' == S Gamma S^-1 - dS S^-1 with the explicit spin lift S, Dirac'[S psi] == S Dirac[psi];"
   <> "  bridge 3: an extra so(4,4)-valued coupling from the axial torsion;"
   <> "  fable-5.1: no connection term at all, Dirac_LC[Sqrt[Sin] Psi'] == Sqrt[Sin] gamma^mu d_mu Psi'",
   ""},
  {"torsion",
   "zero for canonical and bridges 1, 2;  -2 lambda mSkew (axial) for bridge 3;  d e^a (vector + tensor, axial part zero) for fable-5.1",
   ""}
 }, Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 152 ---------- *)
cfRunCell[152, Hold[
(* --- final tally of every assertion made in this notebook -------------------------------- *)
Print["identities accepted on numerical evidence alone : ", $cfNumericCertificates,
      "   (stage 3 returned True)"];
Print["non-vanishing witnesses                         : ", $cfNonVanishingWitnesses,
      "   (cfNonZeroWitnessQ found a probe point at which every entry is a"];
Print["                                                     number and one of them is non-zero: a complete",
      " proof of non-vanishing)"];
cfAssert["no identity in this notebook was accepted on numerical evidence alone",
  $cfNumericCertificates === 0];
cfAssertSummary[]
]];

(* ---------- Input cell 153 ---------- *)
cfRunCell[153, Hold[
(* --- two general helpers, used for both fields ------------------------------------------ *)
(* cfEulerLagrange[L, fields, coords]: for each field f in the list, the Euler-Lagrange       *)
(* expression  D[L, f] - Sum_mu D[ D[L, D[f, x_mu]], x_mu ]  of a first-order Lagrangian.     *)
(* A field may depend on any subset of the coordinates: a direction on which it does not     *)
(* depend has D[f, x_mu] == 0 and is skipped, so the same helper serves a phi of all eight    *)
(* coordinates and a Psi of (x0, x4).  The names fld, crd are the iteration variables.        *)
ClearAll[cfEulerLagrange, cfCovariantDivergence];
cfEulerLagrange[L_, fields_List, coords_List] := Table[
  D[L, fld] - Sum[With[{df = D[fld, crd]}, If[df === 0, 0, D[D[L, df], crd]]], {crd, coords}],
  {fld, fields}];
(* cfCovariantDivergence[T, gInv, Gamma, coords]: the vector                                  *)
(*   nabla^mu T_{mu nu} = g^{mu al} ( d_mu T_{al nu} - Gamma^la_{mu al} T_{la nu} - Gamma^la_{mu nu} T_{al la} ). *)
cfCovariantDivergence[T_, gInv_, Gam_, coords_List] := Module[{n = Length[coords]},
  Table[Sum[gInv[[mu, al]] (D[T[[al, nu]], coords[[mu]]]
      - Sum[Gam[[la, mu, al]] T[[la, nu]], {la, n}] - Sum[Gam[[la, mu, nu]] T[[al, la]], {la, n}]),
    {mu, n}, {al, n}], {nu, n}]];
cfAssert["HELPER [definition]: cfEulerLagrange on the oscillator L = f'^2/2 - f^2/2 gives -f'' - f",
  cfEulerLagrange[(1/2) D[cfTestF[x4], x4]^2 - (1/2) cfTestF[x4]^2, {cfTestF[x4]}, X] === {-cfTestF[x4] - cfTestF''[x4]}];
cfAssert["HELPER [solver regression]: cfCovariantDivergence of the metric itself vanishes (metric compatibility of Section 16's Gamma; a wrong index slot in the helper fails this)",
  cfZeroArrayQ[cfCovariantDivergence[gCanonical, gInvCanonical, GammaCanonical, X]]];
]];

(* ---------- Input cell 154 ---------- *)
cfRunCell[154, Hold[
(* --- fableScalar: the field, its Lagrangian, its energy-momentum tensor, its field equation - *)
ClearAll[cfSqrtg, cfPhiGen, cfVphi, cfDphi, cfLhatScalar, cfLScalar, cfTScalar, cfBoxPhi];
cfSqrtg  = sqrtDetgTele;                                    (* Sec[6 H x0], Section 21 *)
cfPhiGen = cfPhiFn @@ X;                                    (* phi(x0, ..., x7), generic *)
cfDphi   = Table[D[cfPhiGen, X[[mu]]], {mu, 8}];
cfLhatScalar = -(1/2) Sum[gInvCanonical[[mu, nu]] cfDphi[[mu]] cfDphi[[nu]], {mu, 8}, {nu, 8}] - cfVphi[cfPhiGen];
cfLScalar    = cfSqrtg cfLhatScalar;
cfTScalar    = Table[cfDphi[[mu]] cfDphi[[nu]] + gCanonical[[mu, nu]] cfLhatScalar, {mu, 8}, {nu, 8}];
cfBoxPhi     = (1/cfSqrtg) Sum[D[cfSqrtg gInvCanonical[[mu, nu]] cfDphi[[nu]], X[[mu]]], {mu, 8}, {nu, 8}];
cfAssert["FABLESCALAR [definition]: the x4 kinetic term of Lhat is +(1/2) phidot^2, because g^{44} == -1",
  cfZeroQ[Coefficient[cfLhatScalar, cfDphi[[5]], 2] - 1/2]];
cfAssert["FABLESCALAR [definition]: T_{mu nu} is symmetric",
  cfTScalar === Transpose[cfTScalar]];
(* The check with content: the stated tensor really is the metric-variation (Hilbert) tensor.  *)
(* On a general DIAGONAL metric with independent entries g^{mu mu} = gi[mu], and               *)
(* Sqrt[det g] = 1/Sqrt[Product gi] (det g > 0, as in signature 4+4), the prescription          *)
(* T_{mu mu} = -(2/Sqrt[g]) d(Sqrt[g] Lhat)/d g^{mu mu} must reproduce d_mu phi d_mu phi + g_{mu mu} Lhat. *)
cfAssert["FABLESCALAR [has content]: the Hilbert prescription T_{mu mu} = -(2/Sqrt[g]) d(Sqrt[g] Lhat)/dg^{mu mu} reproduces d_mu phi d_mu phi + g_{mu mu} Lhat on a general diagonal metric",
  Module[{gi, ginvD, gD, sq, Lh, TH},
    ginvD = DiagonalMatrix[Table[gi[mu], {mu, 8}]];  gD = DiagonalMatrix[Table[1/gi[mu], {mu, 8}]];
    sq = 1/Sqrt[Product[gi[mu], {mu, 8}]];
    Lh = -(1/2) Sum[ginvD[[mu, mu]] cfDphi[[mu]]^2, {mu, 8}] - cfVphi[cfPhiGen];
    TH = Table[-(2/sq) D[sq Lh, gi[mu]], {mu, 8}];
    cfZeroArrayQ[Table[TH[[mu]] - (cfDphi[[mu]]^2 + gD[[mu, mu]] Lh), {mu, 8}]]]];
cfAssert["FABLESCALAR [has content]: the Euler-Lagrange expression of Sqrt[g] Lhat is Sqrt[g] (box phi - V'(phi)): the field equation is box phi == V'(phi)",
  cfZeroQ[cfEulerLagrange[cfLScalar, {cfPhiGen}, X][[1]] - cfSqrtg (cfBoxPhi - cfVphi'[cfPhiGen])]];
cfAssert["FABLESCALAR [has content]: on the pre-universe, box phi == -phidotdot + Cos[6Hx0] d_0(Sec[6Hx0] Cot[6Hx0]^2 d_0 phi) + (1/q^2)(d_1^2 + d_2^2 + d_3^2) phi - (1/p^2)(d_5^2 + d_6^2 + d_7^2) phi",
  cfZeroQ[cfBoxPhi - (-D[cfPhiGen, x4, x4] + Cos[6 H x0] D[Sec[6 H x0] Cot[6 H x0]^2 D[cfPhiGen, x0], x0]
     + (1/cfQminus^2) Sum[D[cfPhiGen, X[[i]], X[[i]]], {i, 2, 4}] - (1/cfQplus^2) Sum[D[cfPhiGen, X[[i]], X[[i]]], {i, 6, 8}])]];
MatrixForm[Diagonal[cfTScalar] /. cfVphi[cfPhiGen] -> "V"]
]];

(* ---------- Input cell 155 ---------- *)
cfRunCell[155, Hold[
ClearAll[cfDivTScalar, cfPhiDD, cfScalarOnShell];
cfDivTScalar = cfTimed["nabla^mu T_{mu nu} of fableScalar, for a generic phi(x0, ..., x7)",
  cfCovariantDivergence[cfTScalar, gInvCanonical, GammaCanonical, X]];
cfAssert["FABLESCALAR [THE RESULT]: OFF-SHELL identity  nabla^mu T_{mu nu} == (box phi - V'(phi)) d_nu phi  for a generic phi of all eight coordinates",
  cfZeroArrayQ[cfDivTScalar - (cfBoxPhi - cfVphi'[cfPhiGen]) cfDphi]];
(* on shell: the field equation solved for the highest x4-derivative, and substituted *)
cfPhiDD = D[cfPhiGen, x4, x4];
cfScalarOnShell = cfPhiDD -> Expand[cfBoxPhi + cfPhiDD] - cfVphi'[cfPhiGen];
cfAssert["FABLESCALAR [definition]: the substitution rule solves the field equation, box phi - V' == 0 under it",
  cfZeroQ[(cfBoxPhi - cfVphi'[cfPhiGen]) /. cfScalarOnShell]];
cfAssert["FABLESCALAR [THE RESULT]: nabla^mu T_{mu nu} == 0 ON SHELL, in all eight components, by substitution of the field equation",
  cfZeroArrayQ[cfDivTScalar /. cfScalarOnShell]];
cfAssert["FABLESCALAR [control]: off shell the divergence does NOT vanish -- witnessed on phi = x0 + x4^2 with V = phi^2, which is not a solution",
  cfNonZeroWitnessQ[cfDivTScalar /. {cfPhiFn -> Function[{u0, u1, u2, u3, u4, u5, u6, u7}, u4^2 + u0], cfVphi -> (#^2 &)}]];
cfAssert["FABLESCALAR [has content]: trace T^mu_mu == -3 (d phi)^2 - 8 V(phi)",
  cfZeroQ[Sum[gInvCanonical[[mu, nu]] cfTScalar[[mu, nu]], {mu, 8}, {nu, 8}]
     - (-3 Sum[gInvCanonical[[mu, nu]] cfDphi[[mu]] cfDphi[[nu]], {mu, 8}, {nu, 8}] - 8 cfVphi[cfPhiGen])]];
]];

(* ---------- Input cell 156 ---------- *)
cfRunCell[156, Hold[
ClearAll[cfRedRule, cfPhiRed, cfDphiRed, cfTRed, cfKE, cfPE, cfG0, cfG5, cfRhoScalar, cfP1Scalar, cfP0Scalar, cfWScalar];
cfRedRule  = {cfPhiFn -> Function[{u0, u1, u2, u3, u4, u5, u6, u7}, cfPhiR[u0, u4, u5]]};   (* phi(x0, x4, x5) *)
cfPhiRed   = cfPhiGen /. cfRedRule;
cfDphiRed  = cfDphi   /. cfRedRule;
cfTRed     = cfTScalar /. cfRedRule;
cfKE = (1/2) cfDphiRed[[5]]^2;                                (* x4 kinetic energy            *)
cfPE = cfVphi[cfPhiRed];                                      (* potential energy             *)
cfG0 = (1/2) Cot[6 H x0]^2 cfDphiRed[[1]]^2;                  (* gradient energy along x0     *)
cfG5 = (1/2) cfDphiRed[[6]]^2/cfQplus^2;                      (* gradient energy along x5     *)
cfRhoScalar = cfTRed[[5, 5]];                                 (* rho = T_44                   *)
cfP1Scalar  = gInvCanonical[[2, 2]] cfTRed[[2, 2]];           (* P_1 = T^1_1                  *)
cfP0Scalar  = gInvCanonical[[1, 1]] cfTRed[[1, 1]];           (* P_0 = T^0_0, hidden direction *)
cfWScalar   = cfP1Scalar/cfRhoScalar;                         (* wScalar                      *)
cfAssert["FABLESCALAR [definition]: rho == KE + PE + G0 - G5",
  cfZeroQ[cfRhoScalar - (cfKE + cfPE + cfG0 - cfG5)]];
cfAssert["FABLESCALAR [definition]: P_1 == KE - PE - G0 + G5,  and P_2 == P_3 == P_1 (homogeneous on the observed sheet)",
  {cfZeroQ[cfP1Scalar - (cfKE - cfPE - cfG0 + cfG5)],
   cfZeroQ[gInvCanonical[[3, 3]] cfTRed[[3, 3]] - cfP1Scalar], cfZeroQ[gInvCanonical[[4, 4]] cfTRed[[4, 4]] - cfP1Scalar]}];
cfAssert["FABLESCALAR [has content]: along the hidden direction P_0 == KE - PE + G0 + G5 -- the x0 gradient is pressure-like there, not tension-like",
  cfZeroQ[cfP0Scalar - (cfKE - cfPE + cfG0 + cfG5)]];
cfAssert["FABLESCALAR [THE RESULT]: the null energy condition rho + P_1 == 2 KE holds IDENTICALLY, for every phi(x0, x4, x5) and every V",
  cfZeroQ[cfRhoScalar + cfP1Scalar - 2 cfKE]];
cfAssert["FABLESCALAR [THE RESULT]: w + 1 == 2 KE / rho, so w >= -1 wherever rho > 0: fableScalar cannot cross the phantom divide with positive energy density",
  cfZeroQ[(cfWScalar + 1) - 2 cfKE/cfRhoScalar]];
cfAssert["FABLESCALAR [has content]: the usual quintessence formulas are the G0 = G5 = 0 case: for phi(x4), rho == KE + V and P_1 == KE - V",
  {cfZeroQ[(cfRhoScalar - (cfKE + cfPE)) /. cfPhiR -> Function[{u0, u4, u5}, cfPhi4[u4]]],
   cfZeroQ[(cfP1Scalar - (cfKE - cfPE)) /. cfPhiR -> Function[{u0, u4, u5}, cfPhi4[u4]]]}];
cfAssert["FABLESCALAR [has content]: for phi(x0, x4) rho == KE + V + G0 with KE and G0 manifestly squares -- rho > 0 is guaranteed for V >= 0 there (the hypothesis used below)",
  {cfZeroQ[(cfRhoScalar - (cfKE + cfPE + cfG0)) /. cfPhiR -> Function[{u0, u4, u5}, cfPhi04[u0, u4]]],
   MatchQ[cfKE, (1/2) _^2], MatchQ[cfG0, (1/2) Cot[6 H x0]^2 _^2]}];
cfAssert["FABLESCALAR [has content]: the -G5 sector -- for phi(x5) alone with V = 0, rho == -G5 exactly, and G5 is not zero (witnessed on phi = x5^2): that sector has rho < 0 and is EXCLUDED from every statement about w",
  {cfZeroQ[(cfRhoScalar + cfG5) /. {cfPhiR -> Function[{u0, u4, u5}, cfPhi5[u5]], cfVphi -> (0 &)}],
   cfNonZeroWitnessQ[cfG5 /. cfPhiR -> Function[{u0, u4, u5}, u5^2]]}];
Grid[{{"rho", cfKE + cfPE + cfG0 - cfG5}, {"P_1 = P_2 = P_3", cfKE - cfPE - cfG0 + cfG5}, {"P_0 (hidden direction)", cfKE - cfPE + cfG0 + cfG5},
      {"rho + P_1", 2 cfKE}}, Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 157 ---------- *)
cfRunCell[157, Hold[
ClearAll[cfPhi4Rule, cfBox4, cfRho4x, cfQuadV, cfQuadSol, cfWQuad, cfRhoQuad];
cfPhi4Rule = {cfPhiFn -> Function[{u0, u1, u2, u3, u4, u5, u6, u7}, cfPhi4[u4]]};
cfBox4 = cfSimp[cfBoxPhi /. cfPhi4Rule];
cfAssert["FABLESCALAR [THE RESULT]: for phi = phi(x4) the field equation is phi'' == -V'(phi): NO HUBBLE FRICTION on the pre-universe",
  cfZeroQ[cfBox4 + cfPhi4''[x4]]];
cfAssert["FABLESCALAR [has content]: the reason -- Sqrt[g] g^{44} == -Sec[6 H x0], independent of x4 (and of x1, x2, x3)",
  {cfZeroQ[cfSqrtg gInvCanonical[[5, 5]] + Sec[6 H x0]],
   cfZeroArrayQ[Table[D[cfSqrtg gInvCanonical[[5, 5]], X[[i]]], {i, {2, 3, 4, 5}}]]}];
cfRho4x = cfRhoScalar /. cfPhiR -> Function[{u0, u4, u5}, cfPhi4[u4]];
cfAssert["FABLESCALAR [THE RESULT]: rho = KE + V is conserved along x4 on shell: d rho/dx4 == 0 under phi'' -> -V'(phi)",
  cfZeroQ[D[cfRho4x, x4] /. cfPhi4''[x4] -> -cfVphi'[cfPhi4[x4]]]];
cfAssert["FABLESCALAR [control]: with a friction term added by hand, phi'' -> -3 Hf phi' - V', the same rho obeys d rho/dx4 == -3 Hf phi'^2 == -3 Hf (rho + P): the Friedmann continuity equation, absent here",
  cfZeroQ[(D[cfRho4x, x4] /. cfPhi4''[x4] -> -3 cfHf cfPhi4'[x4] - cfVphi'[cfPhi4[x4]]) + 3 cfHf cfPhi4'[x4]^2]];
(* the exact quadratic solution and the virial average *)
cfQuadV   = (1/2) mPhi^2 #^2 &;
cfQuadSol = Aphi Cos[mPhi x4];
cfAssert["FABLESCALAR [has content]: phi = A Cos[m x4] solves phi'' == -V'(phi) for V = m^2 phi^2/2, exactly",
  cfZeroQ[D[cfQuadSol, x4, x4] + cfQuadV'[cfQuadSol]]];
cfWQuad   = cfSimp[cfWScalar /. {cfPhiR -> Function[{u0, u4, u5}, Aphi Cos[mPhi u4]], cfVphi -> cfQuadV}];
cfRhoQuad = cfRhoScalar /. {cfPhiR -> Function[{u0, u4, u5}, Aphi Cos[mPhi u4]], cfVphi -> cfQuadV};
cfAssert["FABLESCALAR [THE RESULT]: on that solution w == -Cos[2 m x4] exactly -- it oscillates between -1 and +1 -- while rho == A^2 m^2/2 is constant",
  {cfZeroQ[cfWQuad + Cos[2 mPhi x4]], cfZeroQ[cfRhoQuad - Aphi^2 mPhi^2/2]}];
cfAssert["FABLESCALAR [THE RESULT]: the average of w over one period is 0 -- coherent oscillations in a quadratic potential are DUST (the virial theorem <w> = (n-1)/(n+1) at n = 1)",
  cfZeroQ[Integrate[cfWQuad, {x4, 0, 2 Pi/mPhi}, Assumptions -> mPhi > 0 && Aphi > 0]]];
{cfBox4, cfWQuad}
]];

(* ---------- Input cell 158 ---------- *)
cfRunCell[158, Hold[
ClearAll[cfStaticRule, cfStaticEq, cfStaticSol, cfStaticSub, cfStaticRed, cfG0Static, cfRhoStatic, cfP1Static, cfP0Static];
cfStaticRule = {cfPhiFn -> Function[{u0, u1, u2, u3, u4, u5, u6, u7}, cfPhi0[u0]]};
cfStaticEq   = cfSimp[cfBoxPhi /. cfStaticRule];
cfAssert["FABLESCALAR [has content]: for phi = phi(x0) and V = 0 the field equation is Cos[6 H x0] d_0( Sec[6 H x0] Cot[6 H x0]^2 phi'(x0) ) == 0",
  cfZeroQ[cfStaticEq - Cos[6 H x0] D[Sec[6 H x0] Cot[6 H x0]^2 cfPhi0'[x0], x0]]];
cfStaticSol = cGrad Sin[6 H x0]^2/Cos[6 H x0];                                  (* phi'(x0) *)
cfStaticSub = {Derivative[2][cfPhi0][x0] -> D[cfStaticSol, x0], Derivative[1][cfPhi0][x0] -> cfStaticSol};
cfAssert["FABLESCALAR [has content]: phi'(x0) = C Sin[6 H x0]^2 / Cos[6 H x0] solves it for every constant C",
  cfZeroQ[cfStaticEq /. cfStaticSub]];
cfStaticRed = {cfPhiR -> Function[{u0, u4, u5}, cfPhi0[u0]], cfVphi -> (0 &)};
cfG0Static  = cfG0        /. cfStaticRed /. cfStaticSub;
cfRhoStatic = cfRhoScalar /. cfStaticRed /. cfStaticSub;
cfP1Static  = cfP1Scalar  /. cfStaticRed /. cfStaticSub;
cfP0Static  = cfP0Scalar  /. cfStaticRed /. cfStaticSub;
cfAssert["FABLESCALAR [has content]: on the static profile G0 == C^2 Sin[6 H x0]^2 / 2 -- independent of x4 and of x1, x2, x3: constant for the observer at fixed x0",
  {cfZeroQ[cfG0Static - cGrad^2 Sin[6 H x0]^2/2], cfZeroArrayQ[Table[D[cfG0Static, X[[i]]], {i, {2, 3, 4, 5}}]]}];
cfAssert["FABLESCALAR [THE RESULT]: rho == G0 and P_1 == -G0, so w == -1 EXACTLY on the observed sheet: a static x0 gradient is a cosmological constant for the observer",
  {cfZeroQ[cfRhoStatic - cfG0Static], cfZeroQ[cfP1Static + cfG0Static], cfZeroQ[cfP1Static/cfRhoStatic + 1]}];
cfAssert["FABLESCALAR [has content]: but along the hidden direction P_0 == +G0 == +rho -- in eight dimensions this is an anisotropic stress, not a Lambda term",
  cfZeroQ[cfP0Static - cfRhoStatic]];
cfAssert["FABLESCALAR [has content]: that energy density is not zero -- witnessed at C = 1",
  cfNonZeroWitnessQ[cfRhoStatic /. cGrad -> 1]];
Grid[{{"phi'(x0)", cfStaticSol}, {"rho", cfSimp[cfRhoStatic]}, {"P_1 = P_2 = P_3", cfSimp[cfP1Static]}, {"P_0", cfSimp[cfP0Static]}},
  Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 159 ---------- *)
cfRunCell[159, Hold[
ClearAll[cfObs3, cfVhid];
cfObs3 = cfQminus^3;                                (* observed 3-volume density, q^3       *)
cfVhid = Tan[6 H x0] cfQplus^3;                     (* hidden 4-volume density, Tan p^3     *)
cfAssert["FABLESCALAR [has content]: Sqrt[det g_8] == q^3 * (Tan[6 H x0] p^3): observed 3-volume density times hidden 4-volume density",
  cfZeroQ[cfSqrtg - cfObs3 cfVhid]];
cfAssert["FABLESCALAR [has content]: the 8-volume element is independent of x4: d(q^3 p^3)/dx4 == 0",
  cfZeroQ[D[cfQminus^3 cfQplus^3, x4]]];
cfAssert["FABLESCALAR [has content]: the hidden 4-volume density scales as Exp[+3 a4[H x4]] and the observed 3-volume as Exp[-3 a4[H x4]]: Vhid Exp[-3 a4] and q^3 Exp[+3 a4] are x4-independent",
  {cfZeroQ[D[cfVhid Exp[-3 a4[H x4]], x4]], cfZeroQ[D[cfObs3 Exp[3 a4[H x4]], x4]]}];
{cfObs3, cfVhid, cfSimp[cfObs3 cfVhid]}
]];

(* ---------- Input cell 160 ---------- *)
cfRunCell[160, Hold[
ClearAll[cfOmM, cfOmR, cfN0, cfN1, cfNpts, cfNgrid, cfV0A, cfLamA, cfVA, cfdVA, cfHA, cfSolA, cfRowsA, cfRowsANum,
         cfRefDir, cfRefScalarFile, cfRefA, cfDiffA, cfDwA];
cfOmM = 3/10;  cfOmR = 84/10^6;  cfN0 = -7;  cfN1 = 0;  cfNpts = 701;
cfNgrid = Table[cfN0 + (cfN1 - cfN0) k/(cfNpts - 1), {k, 0, cfNpts - 1}];
cfV0A  = SetPrecision[2.6871520526047146, Infinity];      (* the solver's normalised V0, as the exact rational of that double *)
cfLamA = 1;
cfVA[p_]  := cfV0A Exp[-cfLamA p];
cfdVA[p_] := -cfLamA cfV0A Exp[-cfLamA p];
cfHA[n_, p_, pd_] := Sqrt[cfOmM Exp[-3 n] + cfOmR Exp[-4 n] + (pd^2/2 + cfVA[p])/3];
cfSolA = cfTimed["NDSolve of the 4-dimensional reference Model A (exp, lambda = 1, frozen start at N = -7)",
  NDSolve[{phiN'[nA] == phidN[nA]/cfHA[nA, phiN[nA], phidN[nA]],
     phidN'[nA] == -3 phidN[nA] - cfdVA[phiN[nA]]/cfHA[nA, phiN[nA], phidN[nA]],
     tN'[nA] == 1/cfHA[nA, phiN[nA], phidN[nA]],
     phiN[cfN0] == 0, phidN[cfN0] == 0, tN[cfN0] == 0}, {phiN, phidN, tN}, {nA, cfN0, cfN1},
    WorkingPrecision -> 24, PrecisionGoal -> 15, AccuracyGoal -> 15, MaxSteps -> 10^6][[1]]];
(* rows: N, a, t (with the analytic age at N0), phi, phidot, H, w -- the solver's columns *)
cfRowsA = Table[With[{p = phiN[n] /. cfSolA, pd = phidN[n] /. cfSolA},
   {n, Exp[n], (tN[n] /. cfSolA) + 1/(2 cfHA[cfN0, 0, 0]), p, pd, cfHA[n, p, pd], (pd^2/2 - cfVA[p])/(pd^2/2 + cfVA[p])}], {n, cfNgrid}];
cfRowsANum = N[cfRowsA, 20];
cfAssert["MODEL A [definition]: 701 rows from N = -7 to 0, and w(N0) == -1 exactly at the frozen start",
  {Length[cfRowsA] === 701, cfRowsA[[1, 7]] == -1}];
cfAssert["MODEL A [fidelity]: Omega_phi(a = 1) == 1 - Om - Or to 1e-8 -- NDSolve reproduces the solver's shooting normalisation of V0",
  Abs[(cfRowsANum[[-1, 5]]^2/2 + cfVA[cfRowsANum[[-1, 4]]])/3 - (1 - cfOmM - cfOmR)] < 10^-8];
cfAssert["MODEL A [has content]: w never goes below -1 on the run (the null energy condition, numerically)",
  Min[cfRowsANum[[All, 7]]] >= -1];
cfDwA = Differences[cfRowsANum[[All, 7]]];
cfAssert["MODEL A [has content]: dw/dN > 0 at every step: the exp field with a frozen start THAWS (read off the sign of dw/dN, not assumed)",
  AllTrue[cfDwA, # > 0 &]];
Print["  Model A (exp):  w(a=1) = ", cfRowsANum[[-1, 7]], "   phi(a=1) = ", cfRowsANum[[-1, 4]],
      "   t(a=1) = ", cfRowsANum[[-1, 3]], "   H(a=1) = ", cfRowsANum[[-1, 6]]];
(* the comparison with the solver's reference file, if it is there *)
cfRefDir = FileNameJoin[{cfDir, "..", "fable-cosmology", "reference"}];
cfRefScalarFile = FileNameJoin[{cfRefDir, "mathematica_scalar_exp.csv"}];
If[FileExistsQ[cfRefScalarFile],
  cfRefA  = Import[cfRefScalarFile, "CSV"];
  cfDiffA = Table[Max[Abs[N[cfRowsANum[[All, c]]] - cfRefA[[2 ;;, c]]]], {c, 7}];
  Print["  reference ", cfRefScalarFile];
  Print["  rows: ", Length[cfRefA] - 1, ";  max |difference| per column {N, a, t, phi, phidot, H, w}: ", cfDiffA];
  cfAssert["MODEL A [fidelity]: the reference CSV has the expected header and the same 701 values of N",
    {cfRefA[[1]] === {"N", "a", "t", "phi", "phidot", "H", "w_phi"}, Length[cfRefA] === 702, cfDiffA[[1]] < 10^-12}];
  cfAssert["MODEL A [fidelity]: w agrees with fable-cosmology/reference/mathematica_scalar_exp.csv at EVERY row to 1e-9",
    cfDiffA[[7]] < 10^-9];
  cfAssert["MODEL A [fidelity]: so do t, phi, phidot and H, to 1e-9",
    Max[cfDiffA[[3 ;; 6]]] < 10^-9],
  cfNote["reference file not found; the Model A comparison was skipped, not failed",
    "Looked for " <> cfRefScalarFile <> ".  Run fable-cosmology/reference/make_reference.wls to create it; the NDSolve above stands on its own."]];
Grid[Prepend[Map[NumberForm[#, 8] &, cfRowsANum[[{1, 101, 201, 301, 401, 501, 601, 701}]], {2}],
  {"N", "a", "t", "phi", "phidot", "H", "w_phi"}], Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 161 ---------- *)
cfRunCell[161, Hold[
ClearAll[cfPsiGen, cfPsiF, cfSBil, cfVs, cfGamUp, cfGamDn, cfLagrangianFable, cfDiracOperatorFor,
         cfLhatFable, cfLhatFablePar, cfLFable, cfConstRule, cfLaFlat];
cfPsiGen = Table[cfPsiF[k][x0, x4], {k, 0, 15}];            (* fable, generic in (x0, x4)      *)
cfSBil   = cfPsiGen . \[Sigma]16 . cfPsiGen;                  (* the scalar bilinear s           *)
cfGamUp  = gammaCurvedCanonical;                              (* gamma^mu, entry 5 is x4         *)
cfGamDn  = Table[Sum[gCanonical[[mu, nu]] cfGamUp[[nu]], {nu, 8}], {mu, 8}];      (* gamma_mu   *)
cfLagrangianFable[psi_List, frame_, sqrtg_, Vfun_] := Module[{cofr = Inverse[frame], gam},
  gam = Table[Sum[cofr[[a, mu]] T16[a - 1], {a, 8}], {mu, 8}];
  sqrtg ((1/H) psi . \[Sigma]16 . Sum[gam[[mu]] . D[psi, X[[mu]]], {mu, 8}] - Vfun[psi . \[Sigma]16 . psi])];
cfDiracOperatorFor[psi_List, gammaUp_List, gammaSpin_List] :=
  Sum[gammaUp[[mu]] . (D[psi, X[[mu]]] + gammaSpin[[mu]] . psi), {mu, 8}];
cfLhatFable    = (1/H) cfPsiGen . \[Sigma]16 . Sum[cfGamUp[[mu]] . cfDcov16[cfPsiGen, mu], {mu, 8}] - cfVs[cfSBil];   (* with D_mu *)
cfLhatFablePar = cfLagrangianFable[cfPsiGen, frameCanonical, 1, cfVs];                                            (* with d_mu *)
cfLFable       = cfSqrtg cfLhatFablePar;                                                                          (* the action density *)
(* a concrete constant spinor, for witnesses: e1 + e5, on which s = -2 (the all-ones spinor has s = 0) *)
cfConstRule = Table[With[{kk = k}, cfPsiF[kk] -> Function[{u0, u4}, Evaluate[(UnitVector[16, 1] + UnitVector[16, 5])[[kk + 1]]]]], {k, 0, 15}];
cfAssert["FABLE [definition]: s = Psi^T sigma16 Psi is a genuine scalar with content: on the constant spinor e1 + e5, s == -2",
  (cfSBil /. cfConstRule) === -2];
cfAssert["FABLE [has content]: Lhat with the covariant derivative == Lhat with the partial derivative, for the generic Psi(x0, x4) (Part V's theorem, re-asserted here)",
  cfZeroQ[Expand[cfLhatFable - cfLhatFablePar]]];
cfAssert["FABLE [fidelity]: with V = -(2M/H) s, frame -> ID8 and Sqrt[g] -> 1, on the model's Psi16, the Lagrangian helper IS the author's La[] of Section 11",
  cfZeroQ[cfLagrangianFable[\[CapitalPsi]16, ID8, 1, (-(2 M/H) # &)] - La[]]];
cfLaFlat[] := cfLagrangianFable[\[CapitalPsi]16, ID8, 1, (-(2 M/H) # &)];
cfAssert["FABLE [fidelity]: and its Euler-Lagrange equations, formed with the author's own eL operator, ARE the sixteen equations eLa of Section 12",
  cfZeroArrayQ[eL[cfLaFlat, 1] - eLa]];
cfAssert["FABLE [solver regression]: the new helper cfEulerLagrange reproduces eLa too",
  cfZeroArrayQ[cfEulerLagrange[cfLaFlat[], \[CapitalPsi]16, X] - eLa]];
Short[cfLhatFablePar, 4]
]];

(* ---------- Input cell 162 ---------- *)
cfRunCell[162, Hold[
ClearAll[cfELFable, cfAmat, cfDmat, cfELFormula, cfDivG, cfFieldEqFable];
cfELFable = cfTimed["Euler-Lagrange equations of fable by explicit variation of Sqrt[g] Lhat, generic V(s)",
  cfEulerLagrange[cfLFable, cfPsiGen, X]];
cfAmat = Table[\[Sigma]16 . cfGamUp[[mu]], {mu, 8}];                                       (* A^mu = sigma16 gamma^mu *)
cfDmat = (1/cfSqrtg) Sum[D[cfSqrtg cfAmat[[mu]], X[[mu]]], {mu, 8}];                         (* D = (1/sqrt g) d_mu(sqrt g A^mu) *)
cfELFormula = cfSqrtg ((2/H) (Sum[cfAmat[[mu]] . D[cfPsiGen, X[[mu]]], {mu, 8}] + (1/2) cfDmat . cfPsiGen)
   - 2 cfVs'[cfSBil] \[Sigma]16 . cfPsiGen);
cfAssert["FABLE [THE RESULT]: the Euler-Lagrange equations by explicit variation == Sqrt[g] [ (2/H)(A^mu d_mu Psi + (1/2) D Psi) - 2 V'(s) sigma16 Psi ]",
  cfZeroArrayQ[cfELFable - cfELFormula]];
cfAssert["FABLE [has content]: A^mu = sigma16 gamma^mu is antisymmetric and sigma16 is symmetric -- the structure that makes the variation close",
  {cfZeroArrayQ[Table[cfAmat[[mu]] + Transpose[cfAmat[[mu]]], {mu, 8}]], \[Sigma]16 === Transpose[\[Sigma]16]}];
cfDivG = (1/cfSqrtg) Sum[D[cfSqrtg cfGamUp[[mu]], X[[mu]]], {mu, 8}];
cfAssert["FABLE [has content]: in general (1/Sqrt[g]) d_mu(Sqrt[g] gamma^mu) == [gamma^mu, Gamma^spin_mu]  (covariant constancy of gamma^mu, Section 17)",
  cfZeroArrayQ[cfDivG - Sum[cfGamUp[[mu]] . GammaSpinCanonical[[mu]] - GammaSpinCanonical[[mu]] . cfGamUp[[mu]], {mu, 8}]]];
cfAssert["FABLE [has content]: the HYPOTHESIS that makes it a product -- the anticommutator {gamma^mu, Gamma^spin_mu} == 0 on the canonical frame (no totally antisymmetric part of the connection)",
  cfZeroArrayQ[Sum[cfGamUp[[mu]] . GammaSpinCanonical[[mu]] + GammaSpinCanonical[[mu]] . cfGamUp[[mu]], {mu, 8}]]];
cfAssert["FABLE [has content]: hence (1/2)(1/Sqrt[g]) d_mu(Sqrt[g] gamma^mu) == gamma^mu Gamma^spin_mu, and on this geometry == -3 H Cot[6 H x0]^2 T16[0]",
  {cfZeroArrayQ[(1/2) cfDivG - Sum[cfGamUp[[mu]] . GammaSpinCanonical[[mu]], {mu, 8}]],
   cfZeroArrayQ[(1/2) cfDivG + 3 H Cot[6 H x0]^2 T16[0]]}];
cfFieldEqFable = cfDiracOperatorFor[cfPsiGen, cfGamUp, GammaSpinCanonical] - H cfVs'[cfSBil] cfPsiGen;   (* gamma^mu D_mu Psi - H V'(s) Psi *)
cfAssert["FABLE [THE RESULT]: EL == Sqrt[g] (2/H) sigma16 . ( gamma^mu D_mu Psi - H V'(s) Psi ): the field equation of fable is EXACTLY the Levi-Civita covariant Dirac equation  gamma^mu D_mu Psi == H V'(s) Psi",
  cfZeroArrayQ[cfELFable - cfSqrtg (2/H) \[Sigma]16 . cfFieldEqFable]];
cfAssert["FABLE [has content]: the connection term does not vanish on an x0-independent spinor -- witnessed on the constant spinor e1: a spinor homogeneous in everything but x4 is NOT a solution",
  cfNonZeroWitnessQ[(1/2) cfDivG . UnitVector[16, 1]]];
Short[cfSimpArray[(1/2) cfDivG], 4]
]];

(* ---------- Input cell 163 ---------- *)
cfRunCell[163, Hold[
ClearAll[cfRescRule, cfPsiRGen, cfSR, cfRescRule4, cfPsiR4, cfSR4, cfOnShellR4, cfConstRuleR];
cfRescRule = Table[With[{kk = k}, cfPsiF[kk] -> Function[{u0, u4}, Sqrt[Sin[6 H u0]] cfPsiRr[kk][u0, u4]]], {k, 0, 15}];
cfPsiRGen  = Table[cfPsiRr[k][x0, x4], {k, 0, 15}];                          (* Psi'(x0, x4), generic *)
cfSR       = cfSBil /. cfRescRule;
cfAssert["FABLE [definition]: under Psi = Sqrt[Sin[6 H x0]] Psi', s == Sin[6 H x0] Psi'^T sigma16 Psi'",
  cfZeroQ[cfSR - Sin[6 H x0] cfPsiRGen . \[Sigma]16 . cfPsiRGen]];
cfAssert["FABLE [THE RESULT]: (gamma^mu D_mu - H V'(s)) [Sqrt[Sin[6 H x0]] Psi'] == Sqrt[Sin[6 H x0]] (gamma^mu d_mu Psi' - H V'(s) Psi') for a GENERIC Psi'(x0, x4): the rescaling removes the connection term exactly",
  cfZeroArrayQ[(cfFieldEqFable /. cfRescRule)
     - Sqrt[Sin[6 H x0]] (Sum[cfGamUp[[mu]] . D[cfPsiRGen, X[[mu]]], {mu, 8}] - H cfVs'[cfSR] cfPsiRGen)]];
(* now Psi' of x4 alone *)
cfRescRule4 = Table[With[{kk = k}, cfPsiF[kk] -> Function[{u0, u4}, Sqrt[Sin[6 H u0]] cfPsiR[kk][u4]]], {k, 0, 15}];
cfPsiR4     = Table[cfPsiR[k][x4], {k, 0, 15}];                               (* Psi'(x4) *)
cfSR4       = cfSBil /. cfRescRule4;
cfAssert["FABLE [has content]: (gamma^4)^2 == -ID16, so gamma^4 d_4 Psi' == H V'(s) Psi' is solved by d_4 Psi' == -H V'(s) gamma^4 Psi'",
  cfZeroArrayQ[cfGamUp[[5]] . cfGamUp[[5]] + ID16]];
cfAssert["FABLE [has content]: for Psi' = Psi'(x4) the field equation reduces to Sqrt[Sin[6 H x0]] (gamma^4 d_4 Psi' - H V'(s) Psi'), s = Sin[6 H x0] Psi'^T sigma16 Psi'",
  cfZeroArrayQ[(cfFieldEqFable /. cfRescRule4) - Sqrt[Sin[6 H x0]] (cfGamUp[[5]] . D[cfPsiR4, x4] - H cfVs'[cfSR4] cfPsiR4)]];
(* the reduced equation solved for d_4 Psi', as substitution rules; With injects the index into the held Function body *)
cfOnShellR4 = Table[With[{kk = k}, Derivative[1][cfPsiR[kk]] ->
   Function[u4, Evaluate[(-H cfVs'[cfSR4] (cfGamUp[[5]] . cfPsiR4))[[kk + 1]] /. x4 -> u4]]], {k, 0, 15}];
cfConstRuleR = Table[With[{kk = k}, cfPsiR[kk] -> Function[u4, Evaluate[(UnitVector[16, 1] + UnitVector[16, 5])[[kk + 1]]]]], {k, 0, 15}];
cfAssert["FABLE [has content]: the reduced equation still depends on x0 through V'(Sin[6 H x0] s'): for a NONLINEAR V a Psi'(x4) alone is not a solution -- witnessed with V = s^2 on Psi' = e1 + e5",
  cfNonZeroWitnessQ[D[cfVs'[cfSR4], x0] /. cfVs -> (#^2 &) /. cfConstRuleR]];
cfAssert["FABLE [has content]: for the mass term V = -(2M/H) s, V' is constant and Psi'(x4) IS an exact solution",
  cfZeroQ[D[cfVs'[cfSR4], x0] /. cfVs -> (-(2 M/H) # &)]];
Short[cfOnShellR4[[1]], 3]
]];

(* ---------- Input cell 164 ---------- *)
cfRunCell[164, Hold[
ClearAll[cfDcovPsi, cfTCov, cfTPar, cfConstRuleW];
cfDcovPsi = Table[cfDcov16[cfPsiGen, mu], {mu, 8}];
cfTCov = Table[-(1/(2 H)) (cfPsiGen . \[Sigma]16 . cfGamDn[[mu]] . cfDcovPsi[[nu]] + cfPsiGen . \[Sigma]16 . cfGamDn[[nu]] . cfDcovPsi[[mu]])
   + gCanonical[[mu, nu]] cfLhatFable, {mu, 8}, {nu, 8}];
cfTPar = Table[-(1/(2 H)) (cfPsiGen . \[Sigma]16 . cfGamDn[[mu]] . D[cfPsiGen, X[[nu]]] + cfPsiGen . \[Sigma]16 . cfGamDn[[nu]] . D[cfPsiGen, X[[mu]]])
   + gCanonical[[mu, nu]] cfLhatFablePar, {mu, 8}, {nu, 8}];
cfAssert["FABLE [definition]: T_cov is symmetric by construction",
  cfTCov === Transpose[cfTCov]];
cfAssert["FABLE [has content]: the diagonal of T_cov equals the diagonal of the partial-derivative tensor, for the generic Psi(x0, x4): rho and every pressure are the same in both",
  cfZeroArrayQ[Table[Expand[cfTCov[[mu, mu]] - cfTPar[[mu, mu]]], {mu, 8}]]];
(* The witness spinor is the constant e1 + e13.  On a constant spinor the difference reduces to   *)
(* the connection bilinears -(1/2H)(Psi^T sigma16 gamma_mu Gamma_nu Psi + (mu <-> nu)), and       *)
(* Gamma^spin vanishes along x0 and x4, so the (x_i, x4) difference is -(1/2H) Psi^T sigma16 gamma_4 Gamma_i Psi. *)
(* Many unit-vector spinors (e1 + e5 among them) happen to sit in its kernel; e1 + e13 does not.   *)
cfConstRuleW = Table[With[{kk = k}, cfPsiF[kk] -> Function[{u0, u4}, Evaluate[(UnitVector[16, 1] + UnitVector[16, 13])[[kk + 1]]]]], {k, 0, 15}];
cfAssert["FABLE [has content]: but the two tensors DIFFER off the diagonal -- witnessed on the (x3, x4) component T[[4,5]], a momentum density along the observed sheet, for the constant spinor e1 + e13 and V = s^2",
  cfNonZeroWitnessQ[Expand[cfTCov[[4, 5]] - cfTPar[[4, 5]]] /. cfVs -> (#^2 &) /. cfConstRuleW]];
{Dimensions[cfTCov], Count[Flatten[cfTCov], Except[0]], " non-zero components"}
]];

(* ---------- Input cell 165 ---------- *)
cfRunCell[165, Hold[
ClearAll[cfFvec, cfFk, cfOnShell, cfKPsi, cfKh, cfRhoFable, cfP1Fable, cfLhatOnShell, cfDsDx4, cfLinRule];
cfFvec = -cfGamUp[[5]] . (H cfVs'[cfSBil] cfPsiGen - cfGamUp[[1]] . D[cfPsiGen, x0] - (1/2) cfDivG . cfPsiGen);   (* = d_4 Psi on shell *)
cfAssert["FABLE [definition]: F solves the field equation for d_4 Psi: gamma^4 F + gamma^0 d_0 Psi + (1/2) divG Psi - H V'(s) Psi == 0",
  cfZeroArrayQ[cfGamUp[[5]] . cfFvec + cfGamUp[[1]] . D[cfPsiGen, x0] + (1/2) cfDivG . cfPsiGen - H cfVs'[cfSBil] cfPsiGen]];
cfFk[k_Integer] := cfFvec[[k + 1]];
(* the recipe: replace d_x0^a d_x4^b Psi_k (b >= 1) by d_x0^a d_x4^(b-1) F_k, to a fixed point *)
cfOnShell[expr_] := FixedPoint[Function[e, e /. Derivative[a_, b_ /; b >= 1][cfPsiF[k_]][x0, x4] :> D[cfFk[k], {x0, a}, {x4, b - 1}]], expr, 12];
cfKPsi = (1/H) cfPsiGen . \[Sigma]16 . cfGamUp[[5]] . D[cfPsiGen, x4];         (* kinetic bilinear along x4  *)
cfKh   = -(1/H) cfPsiGen . \[Sigma]16 . cfGamUp[[1]] . D[cfPsiGen, x0];        (* kinetic bilinear along x0  *)
cfRhoFable    = cfOnShell[cfTCov[[5, 5]]];                                     (* rho = T_44 on shell        *)
cfP1Fable     = cfOnShell[gInvCanonical[[2, 2]] cfTCov[[2, 2]]];               (* P_1 = T^1_1 on shell       *)
cfLhatOnShell = cfOnShell[cfLhatFable];
cfAssert["FABLE [definition]: cfOnShell leaves no x4-derivative of the field in rho",
  FreeQ[cfRhoFable, Derivative[_, b_ /; b >= 1][cfPsiF[_]][__]]];
cfAssert["FABLE [THE RESULT]: on shell, Lhat == s V'(s) - V(s)",
  cfZeroQ[Expand[cfLhatOnShell - (cfSBil cfVs'[cfSBil] - cfVs[cfSBil])]]];
cfAssert["FABLE [THE RESULT]: on shell, rho == V(s) + K_h,   K_h = -(1/H) Psi^T sigma16 gamma^0 d_0 Psi",
  cfZeroQ[Expand[cfRhoFable - (cfVs[cfSBil] + cfKh)]]];
cfAssert["FABLE [THE RESULT]: on shell, P_1 == s V'(s) - V(s),  and P_2 == P_3 == P_1",
  {cfZeroQ[Expand[cfP1Fable - (cfSBil cfVs'[cfSBil] - cfVs[cfSBil])]],
   cfZeroQ[Expand[cfOnShell[gInvCanonical[[3, 3]] cfTCov[[3, 3]]] - cfP1Fable]],
   cfZeroQ[Expand[cfOnShell[gInvCanonical[[4, 4]] cfTCov[[4, 4]]] - cfP1Fable]]}];
cfAssert["FABLE [has content]: on shell, K_Psi == s V'(s) + K_h -- the x4 kinetic bilinear is fixed by the potential and the hidden one",
  cfZeroQ[Expand[cfOnShell[cfKPsi] - (cfSBil cfVs'[cfSBil] + cfKh)]]];
cfAssert["FABLE [has content]: K_h == 0 for Psi = Sqrt[Sin[6 H x0]] Psi'(x4)  (d_0 Psi is proportional to Psi, and Psi^T sigma16 gamma^0 Psi == 0)",
  cfZeroQ[Expand[cfKh /. cfRescRule4]]];
cfAssert["FABLE [THE RESULT]: so for those solutions rho == V(s), hence w == s V'(s)/V(s) - 1, and rho > 0 requires V(s) > 0",
  cfZeroQ[Expand[(cfRhoFable - cfVs[cfSBil]) /. cfRescRule4]]];
(* the bilinear along x4 *)
cfDsDx4 = 2 cfPsiGen . \[Sigma]16 . cfGamUp[[5]] . cfGamUp[[1]] . D[cfPsiGen, x0];
cfAssert["FABLE [THE RESULT]: on shell, ds/dx4 == 2 Psi^T sigma16 gamma^4 gamma^0 d_0 Psi for a generic Psi(x0, x4)",
  cfZeroQ[Expand[cfOnShell[D[cfSBil, x4]] - cfDsDx4]]];
cfAssert["FABLE [has content]: the two other terms of d_4 Psi drop out because sigma16 gamma^4 and sigma16 gamma^4 gamma^0 are ANTISYMMETRIC",
  {cfZeroArrayQ[\[Sigma]16 . cfGamUp[[5]] + Transpose[\[Sigma]16 . cfGamUp[[5]]]],
   cfZeroArrayQ[\[Sigma]16 . cfGamUp[[5]] . cfGamUp[[1]] + Transpose[\[Sigma]16 . cfGamUp[[5]] . cfGamUp[[1]]]]}];
cfLinRule = Table[With[{kk = k}, cfPsiF[kk] -> Function[{u0, u4}, Evaluate[UnitVector[16, 1][[kk + 1]] + u0 UnitVector[16, 2][[kk + 1]]]]], {k, 0, 15}];
cfAssert["FABLE [control]: that bilinear is NOT identically zero for an x0-dependent Psi -- witnessed on Psi = e1 + x0 e2: 'ds/dx4 == 0 for generic Psi(x0, x4)' would be FALSE",
  cfNonZeroWitnessQ[cfDsDx4 /. cfLinRule]];
cfAssert["FABLE [THE RESULT]: for Psi = Sqrt[Sin[6 H x0]] Psi'(x4) it vanishes: s is CONSTANT IN x4 -- no dilution on the pre-universe",
  cfZeroQ[Expand[cfDsDx4 /. cfRescRule4]]];
cfAssert["FABLE [THE RESULT]: the same from the reduced equation: ds'/dx4 == 0 on shell for Psi'(x4), because Psi'^T sigma16 gamma^4 Psi' == 0",
  cfZeroQ[Expand[D[cfPsiR4 . \[Sigma]16 . cfPsiR4, x4] /. cfOnShellR4]]];
Grid[{{"Lhat (on shell)", "s V'(s) - V(s)"}, {"rho (on shell)", "V(s) + K_h"}, {"P_1 = P_2 = P_3 (on shell)", "s V'(s) - V(s)"},
      {"K_h for Sqrt[Sin] Psi'(x4)", 0}, {"ds/dx4 (on shell)", "2 Psi^T sigma16 gamma^4 gamma^0 d_0 Psi   (0 for Sqrt[Sin] Psi'(x4))"}},
  Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 166 ---------- *)
cfRunCell[166, Hold[
ClearAll[cfDivTCov];
cfDivTCov = cfTimed["nabla^mu T_{mu nu} of the covariant tensor of fable, generic Psi(x0, x4)",
  cfCovariantDivergence[cfTCov, gInvCanonical, GammaCanonical, X]];
cfAssert["FABLE [THE RESULT]: nabla^mu T_{mu nu} == 0 ON SHELL in all eight components, for a generic Psi(x0, x4) -- the covariant tensor is the conserved one",
  cfZeroArrayQ[Table[Expand[cfOnShell[cfDivTCov[[nu]]]], {nu, 8}]]];
]];

(* ---------- Input cell 167 ---------- *)
cfRunCell[167, Hold[
ClearAll[cfWPsi, cfPotFable, cfWPsiClosed, cfPotAssume];
cfAssert["FABLE [THE RESULT]: the author's mass term V = -(2M/H) s is DUST: on shell P_1 == 0 identically and rho == -(2M/H) s  (w == 0, exactly)",
  {cfZeroQ[Expand[cfP1Fable /. cfVs -> (-(2 M/H) # &)]],
   cfZeroQ[Expand[(cfRhoFable + (2 M/H) cfSBil) /. cfVs -> (-(2 M/H) # &) /. cfRescRule4]]}];
cfAssert["FABLE [has content]: that density is not zero -- witnessed on Psi' = e1 + e5 at M = 1 (rho = (2M/H) * 2 Sin[6 H x0] there)",
  cfNonZeroWitnessQ[(cfRhoFable /. cfVs -> (-(2 M/H) # &) /. cfRescRule4 /. cfConstRuleR) /. M -> 1]];
cfWPsi[Vfun_] := sPsi Vfun'[sPsi]/Vfun[sPsi] - 1;                (* w_Psi(s) = s V'(s)/V(s) - 1, on rho = V *)
cfPotFable = <|"mass" -> (mF # &), "lambda-mass" -> (V0 + mF # &), "power" -> (mF # + lamF #^nF &),
   "hilltop" -> (V0 - muF (# - sStar)^2 &), "lorentz" -> (V0 + mF #/(1 + (#/s1)^2) &), "expdamp" -> (V0 + mF # Exp[-#/s1] &)|>;
cfWPsiClosed = <|"mass" -> 0, "lambda-mass" -> -V0/(V0 + mF sPsi),
   "power" -> (mF sPsi + nF lamF sPsi^nF)/(mF sPsi + lamF sPsi^nF) - 1,
   "hilltop" -> -2 muF sPsi (sPsi - sStar)/(V0 - muF (sPsi - sStar)^2) - 1,
   "lorentz" -> mF sPsi (1 - (sPsi/s1)^2)/((1 + (sPsi/s1)^2)^2 (V0 + mF sPsi/(1 + (sPsi/s1)^2))) - 1,
   "expdamp" -> mF sPsi Exp[-sPsi/s1] (1 - sPsi/s1)/(V0 + mF sPsi Exp[-sPsi/s1]) - 1|>;
cfPotAssume = V0 > 0 && mF > 0 && s1 > 0;
cfAssert["FABLE [has content]: the closed forms of w_Psi(s) = s V'(s)/V(s) - 1 for the six potentials of the numerical work (mass, lambda-mass, power, hilltop, lorentz, expdamp)",
  Table[cfZeroQ[cfWPsi[cfPotFable[name]] - cfWPsiClosed[name]], {name, Keys[cfPotFable]}]];
cfAssert["FABLE [THE RESULT]: mass -> w == 0 (dust);  V = lam s^n alone -> w == n - 1 (accelerating for n < 2/3, phantom for n < 0);  n = 0.236 -> w == -0.764 exactly",
  {cfZeroQ[cfWPsi[cfPotFable["mass"]]], cfZeroQ[cfWPsi[(lamF #^nF &)] - (nF - 1)], cfZeroQ[cfWPsi[(lamF #^(236/1000) &)] + 764/1000]}];
cfAssert["FABLE [THE RESULT]: w + 1 == s V'/V vanishes where V' does, with V > 0 there: lorentz and expdamp cross w = -1 at s = s1, hilltop at s = s* -- the phantom divide is crossed with no wrong-sign kinetic term",
  {cfZeroQ[(cfWPsi[cfPotFable["lorentz"]] + 1) /. sPsi -> s1], cfZeroQ[(cfWPsi[cfPotFable["expdamp"]] + 1) /. sPsi -> s1],
   cfZeroQ[(cfWPsi[cfPotFable["hilltop"]] + 1) /. sPsi -> sStar],
   Simplify[cfPotFable["lorentz"][s1] > 0 && cfPotFable["expdamp"][s1] > 0 && cfPotFable["hilltop"][sStar] > 0, cfPotAssume]}];
cfAssert["FABLE [has content]: lorentz and expdamp are bounded below by V0 > 0 for s >= 0 (rho > 0 on the whole history), and w < -1 for s > s1 (the past), w > -1 for 0 < s < s1 (the present)",
  {Simplify[cfPotFable["lorentz"][sPsi] >= V0, sPsi >= 0 && cfPotAssume], Simplify[cfPotFable["expdamp"][sPsi] >= V0, sPsi >= 0 && cfPotAssume],
   Simplify[cfWPsi[cfPotFable["lorentz"]] + 1 < 0, sPsi > s1 && cfPotAssume], Simplify[cfWPsi[cfPotFable["lorentz"]] + 1 > 0, 0 < sPsi < s1 && cfPotAssume],
   Simplify[cfWPsi[cfPotFable["expdamp"]] + 1 < 0, sPsi > s1 && cfPotAssume], Simplify[cfWPsi[cfPotFable["expdamp"]] + 1 > 0, 0 < sPsi < s1 && cfPotAssume]}];
cfAssert["FABLE [has content]: the limits -- lorentz and expdamp: w -> -1 both as s -> infinity and as s -> 0;  lambda-mass: w -> 0 (dust) as s -> infinity and -> -1 (Lambda) as s -> 0",
  {Limit[cfWPsi[cfPotFable["lorentz"]], sPsi -> Infinity, Assumptions -> cfPotAssume] === -1, Limit[cfWPsi[cfPotFable["lorentz"]], sPsi -> 0, Assumptions -> cfPotAssume] === -1,
   Limit[cfWPsi[cfPotFable["expdamp"]], sPsi -> Infinity, Assumptions -> cfPotAssume] === -1, Limit[cfWPsi[cfPotFable["expdamp"]], sPsi -> 0, Assumptions -> cfPotAssume] === -1,
   Limit[cfWPsi[cfPotFable["lambda-mass"]], sPsi -> Infinity, Assumptions -> cfPotAssume] === 0, Limit[cfWPsi[cfPotFable["lambda-mass"]], sPsi -> 0, Assumptions -> cfPotAssume] === -1}];
cfAssert["FABLE [has content]: expdamp with (V0, m, s1) = (1.566, 0.839, 2.21) at s = 1 (today) gives w == -0.8608, Unite's w0 = -0.861 to three decimals",
  Abs[N[cfWPsi[cfPotFable["expdamp"]] /. {V0 -> 1566/1000, mF -> 839/1000, s1 -> 221/100, sPsi -> 1}, 20] + 861/1000] < 5/10^4];
Grid[Prepend[Table[{name, cfPotFable[name][sPsi], cfWPsiClosed[name]}, {name, Keys[cfPotFable]}], {"potential", "V(s)", "w_Psi(s) = s V'/V - 1"}],
  Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 168 ---------- *)
cfRunCell[168, Hold[
ClearAll[frameFLRW, gFLRW, gInvFLRW, GammaFLRW, omegaFLRWMixed, omegaFLRW, GammaSpinFLRW, cofrFLRW, gamUpFLRW,
         cfPsiTGen, cfSTBil, cfFT, cfOnShellT, cfFT0, cfOnShellT0];
frameFLRW = DiagonalMatrix[{1, aF[x4], aF[x4], aF[x4], 1, 1, 1, 1}];       (* a SEPARATE frame with its own scale factor *)
cfAssert["FLRW [definition]: the reference frame does not mention a4, and the canonical frame is untouched",
  {FreeQ[frameFLRW, a4], frameCanonical === DiagonalMatrix[{Tan[6 H x0], cfQminus, cfQminus, cfQminus, 1, cfQplus, cfQplus, cfQplus}]}];
gFLRW    = frameFLRW . \[Eta]4488 . Transpose[frameFLRW];
gInvFLRW = Inverse[gFLRW];
GammaFLRW = cfChristoffel[gFLRW, gInvFLRW, X];
omegaFLRWMixed = cfTimed["FLRW: spin connection from the vielbein postulate, same solver as Sections 16-21",
  cfSpinConnection[frameFLRW, X, \[Eta]4488, GammaFLRW]];
omegaFLRW = cfLowerFirstFlat[omegaFLRWMixed, \[Eta]4488];
cfAssert["FLRW [solver regression]: vielbein postulate residual is zero",
  cfZeroArrayQ[cfVielbeinResidual[frameFLRW, X, GammaFLRW, omegaFLRWMixed]]];
cfAssert["FLRW [has content]: omega is antisymmetric (metric compatible)",
  cfZeroArrayQ[Table[omegaFLRW[[mu, a, b]] + omegaFLRW[[mu, b, a]], {mu, 8}, {a, 8}, {b, 8}]]];
GammaSpinFLRW = Table[cfSpinMatrix[omegaFLRW, mu], {mu, 8}];
cofrFLRW  = Inverse[frameFLRW];
gamUpFLRW = Table[Sum[cofrFLRW[[a, mu]] T16[a - 1], {a, 8}], {mu, 8}];
cfAssert["FLRW [THE RESULT]: gamma^mu Gamma^spin_mu == (3/2) (a'/a) gamma^4 -- the Hubble term of the FLRW Dirac equation",
  cfZeroArrayQ[Sum[gamUpFLRW[[mu]] . GammaSpinFLRW[[mu]], {mu, 8}] - (3/2) (aF'[x4]/aF[x4]) gamUpFLRW[[5]]]];
cfPsiTGen = Table[cfPsiT[k][x4], {k, 0, 15}];
cfSTBil   = cfPsiTGen . \[Sigma]16 . cfPsiTGen;
(* gamma^4 (d_4 + (3/2) H_obs) Psi == H V' Psi  =>  d_4 Psi == -H V' gamma^4 Psi - (3/2) H_obs Psi *)
cfFT = -gamUpFLRW[[5]] . (H cfVs'[cfSTBil] cfPsiTGen) - (3/2) (aF'[x4]/aF[x4]) cfPsiTGen;
cfOnShellT = Table[With[{kk = k}, Derivative[1][cfPsiT[kk]] -> Function[u4, Evaluate[cfFT[[kk + 1]] /. x4 -> u4]]], {k, 0, 15}];
cfAssert["FLRW [definition]: the rule solves gamma^mu D_mu Psi == H V'(s) Psi for d_4 Psi",
  cfZeroArrayQ[(cfDiracOperatorFor[cfPsiTGen, gamUpFLRW, GammaSpinFLRW] - H cfVs'[cfSTBil] cfPsiTGen) /. cfOnShellT]];
cfAssert["FLRW [THE RESULT]: d(a^3 s)/dx4 == 0 on shell, for EVERY V: s = s0 a^-3, the dust dilution law, and w_Psi(a) = s V'(s)/V(s) - 1 on it",
  cfZeroQ[Expand[D[aF[x4]^3 cfSTBil, x4] /. cfOnShellT]]];
cfFT0 = -gamUpFLRW[[5]] . (H cfVs'[cfSTBil] cfPsiTGen);                          (* the same equation WITHOUT the Hubble term *)
cfOnShellT0 = Table[With[{kk = k}, Derivative[1][cfPsiT[kk]] -> Function[u4, Evaluate[cfFT0[[kk + 1]] /. x4 -> u4]]], {k, 0, 15}];
cfAssert["FLRW [control]: without the Hubble term, d(a^3 s)/dx4 == 3 (a'/a) a^3 s instead (i.e. ds/dx4 == 0, the pre-universe law): the dilution IS the Hubble term",
  cfZeroQ[Expand[(D[aF[x4]^3 cfSTBil, x4] /. cfOnShellT0) - 3 aF'[x4] aF[x4]^2 cfSTBil]]];
cfShowConnection[omegaFLRW, "omegaFLRW"]
]];

(* ---------- Input cell 169 ---------- *)
cfRunCell[169, Hold[
ClearAll[cfV0B, cfMB, cfS1B, cfVB, cfdVB, cfHB, cfSolB, cfRowsB, cfRowsBNum, cfRefSpinorFile, cfRefB, cfDiffB, cfWB, cfMinPosB];
cfV0B = 1566/1000;  cfMB = 839/1000;  cfS1B = 221/100;
cfVB[s_]  := cfV0B + cfMB s Exp[-s/cfS1B];
cfdVB[s_] := cfMB (1 - s/cfS1B) Exp[-s/cfS1B];
cfHB[n_]  := Sqrt[cfOmM Exp[-3 n] + cfOmR Exp[-4 n] + cfVB[Exp[-3 n]]/3];
cfSolB = cfTimed["NDSolve of the 4-dimensional reference Model B (expdamp; only the cosmic time needs integrating, s = Exp[-3 N] is exact)",
  NDSolve[{tN'[nA] == 1/cfHB[nA], tN[cfN0] == 0}, tN, {nA, cfN0, cfN1},
    WorkingPrecision -> 24, PrecisionGoal -> 15, AccuracyGoal -> 15, MaxSteps -> 10^6][[1]]];
(* rows: N, a, t, s, H, rho_Psi = V(s), w_Psi = s V'/V - 1 -- the solver's columns *)
cfRowsB = Table[With[{s = Exp[-3 n]},
   {n, Exp[n], (tN[n] /. cfSolB) + 1/(2 cfHB[cfN0]), s, cfHB[n], cfVB[s], s cfdVB[s]/cfVB[s] - 1}], {n, cfNgrid}];
cfRowsBNum = N[cfRowsB, 20];
cfWB = cfRowsBNum[[All, 7]];
cfMinPosB = First[Ordering[cfWB, 1]];
cfAssert["MODEL B [definition]: 701 rows from N = -7 to 0, s(0) == 1 and rho_Psi(0) == V(1) == 1.566 + 0.839 Exp[-1/2.21]",
  {Length[cfRowsB] === 701, cfRowsB[[-1, 4]] === 1, cfRowsB[[-1, 6]] === cfV0B + cfMB Exp[-1/cfS1B]}];
cfAssert["MODEL B [THE RESULT]: w <= -1 at every grid point with s > s1 and w > -1 at every grid point with s < s1: the crossing is at s = s1, a = s1^(-1/3) = 0.7677",
  {AllTrue[Pick[cfWB, Thread[cfRowsBNum[[All, 4]] > cfS1B]], # <= -1 &], AllTrue[Pick[cfWB, Thread[cfRowsBNum[[All, 4]] < cfS1B]], # > -1 &]}];
cfAssert["MODEL B [has content]: a genuine phantom phase: min w = -1.302 (to 0.001) at a = 0.543, and w(a = 1) = -0.8608",
  {Abs[cfWB[[cfMinPosB]] + 1302/1000] < 1/1000, Abs[cfRowsBNum[[cfMinPosB, 2]] - 543/1000] < 1/1000, Abs[cfWB[[-1]] + 8608/10000] < 1/10000}];
cfAssert["MODEL B [has content]: V(s) > 0 at every row -- rho_Psi > 0 on the whole history",
  Min[cfRowsBNum[[All, 6]]] > 0];
Print["  Model B (expdamp):  w(a=1) = ", cfWB[[-1]], "   min w = ", cfWB[[cfMinPosB]], " at N = ", N[cfNgrid[[cfMinPosB]]],
      " (a = ", cfRowsBNum[[cfMinPosB, 2]], ")   t(a=1) = ", cfRowsBNum[[-1, 3]], "   H(a=1) = ", cfRowsBNum[[-1, 5]]];
cfRefSpinorFile = FileNameJoin[{cfRefDir, "mathematica_spinor_expdamp.csv"}];
If[FileExistsQ[cfRefSpinorFile],
  cfRefB  = Import[cfRefSpinorFile, "CSV"];
  cfDiffB = Table[Max[Abs[N[cfRowsBNum[[All, c]]] - cfRefB[[2 ;;, c]]]], {c, 7}];
  Print["  reference ", cfRefSpinorFile];
  Print["  rows: ", Length[cfRefB] - 1, ";  max |difference| per column {N, a, t, s, H, rho_Psi, w_Psi}: ", cfDiffB];
  cfAssert["MODEL B [fidelity]: the reference CSV has the expected header and the same 701 values of N",
    {cfRefB[[1]] === {"N", "a", "t", "s", "H", "rho_Psi", "w_Psi"}, Length[cfRefB] === 702, cfDiffB[[1]] < 10^-12}];
  cfAssert["MODEL B [fidelity]: w agrees with fable-cosmology/reference/mathematica_spinor_expdamp.csv at EVERY row to 1e-9",
    cfDiffB[[7]] < 10^-9];
  cfAssert["MODEL B [fidelity]: so do t, H and rho_Psi, to 1e-9 (s differs only by the file's 16-digit rounding of numbers of order 1e9)",
    {Max[cfDiffB[[{3, 5, 6}]]] < 10^-9, cfDiffB[[4]]/Max[cfRefB[[2 ;;, 4]]] < 10^-14}],
  cfNote["reference file not found; the Model B comparison was skipped, not failed",
    "Looked for " <> cfRefSpinorFile <> ".  Run fable-cosmology/reference/make_reference.wls to create it; the NDSolve above stands on its own."]];
Grid[Prepend[Map[NumberForm[#, 8] &, cfRowsBNum[[{1, 101, 201, 301, 401, 501, 601, 640, 701}]], {2}],
  {"N", "a", "t", "s", "H", "rho_Psi", "w_Psi"}], Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 170 ---------- *)
cfRunCell[170, Hold[
ClearAll[cfMechanismTable];
cfMechanismTable = {
  {"question", "fableScalar (real scalar phi, V(phi))", "fable (real 16-spinor Psi, V(s), s = Psi^T sigma16 Psi)"},
  {"time-varying w?",
   "YES.  Reference Model A: rolling in V under Hubble friction (thawing, w from -1 to -0.843 for exp).  "
   <> "On the pre-universe: undamped oscillation (phi'' = -V', Section 23) and sloshing between x0-gradient energy and x4 motion",
   "YES.  Reference Model B: w(a) = s V'/V - 1 on s = s0 a^-3 (theorem: d(a^3 s)/dt = 0).  "
   <> "dust -> constant n - 1 (power), or phantom -> -1 -> quintessence-like (lorentz, expdamp).  On the pre-universe s is constant (ds/dx4 = 0)"},
  {"phantom divide?",
   "NEVER with rho > 0: rho + P = 2 KE >= 0 (theorem, Section 23), w + 1 = 2 KE/rho",
   "CROSSED at V'(s*) = 0 with V(s*) > 0 (theorem: w + 1 = s V'/V), by lorentz and expdamp at s = s1; classical spinor-quintom mechanism; "
   <> "perturbative stability not examined"},
  {"dark matter?",
   "coherent oscillations: <w> = 0 for the quadratic V (theorem, Section 23); Model A 'quadratic' dilutes as dust once oscillating",
   "the author's mass term V = -(2M/H) s IS dust, P = 0 exactly (theorem, Section 24); s = s0 a^-3 is the dust dilution law"},
  {"dark energy?",
   "slow roll / flat V (w -> -1); the static x0 gradient: w = -1 exactly on the observed sheet (theorem, Section 23), with P_0 = +rho along x0",
   "power with 0 < n < 2/3 (field-driven; n = 0.236 <-> w = -0.764); the V0 terms (lambda-mass, lorentz, expdamp) are a BARE Lambda and are reported as such"},
  {"Unite (w0, wa) = (-0.861, -0.60)?",
   "a thawing fableScalar gives w0 > -1 and wa < 0 (the same sign pattern) with w0 + wa below -1 only in the CPL EXTRAPOLATION, never w < -1; "
   <> "whether |wa| ~ 0.6 is reachable is what Model A measures",
   "expdamp / lorentz give a genuine phantom phase in the past, w(1) = -0.861, wa < 0 (Model B here: min w = -1.30 at a = 0.54, crossing at a = 0.768)"},
  {"the volume bookkeeping",
   "any constant 8-density has rho_4 ~ a^-3 in the reduction -- a VOLUME effect, not dust; undetermined without a gravitational sector",
   "same"}};
Grid[cfMechanismTable, Frame -> All, Alignment -> Left, Background -> {None, {LightGray, None}}, ItemSize -> {{Automatic, 42, 42}, Automatic}]
]];

(* ---------- Input cell 171 ---------- *)
cfRunCell[171, Hold[
ClearAll[cfHobs, cfRho4, cfP4];
cfAssert["KINEMATIC [definition]: ln q == -a4[H x4] + const(x0):  D[Log[q], x4] == -H a4'[H x4] == H_obs",
  cfZeroQ[D[Log[cfQminus], x4] + H a4'[H x4]]];
cfAssert["KINEMATIC [has content]: the second sheet contracts at exactly the opposite rate:  D[Log[p], x4] == +H a4'[H x4] == -H_obs",
  cfZeroQ[D[Log[cfQplus], x4] - H a4'[H x4]]];
cfHobs = -H a4'[H x4];
cfAssert["KINEMATIC [has content]: H_obs > 0 exactly when a4' < 0 (and H_obs < 0 when a4' > 0) -- the sign HYPOTHESIS of this Part, stated, not derived",
  {Simplify[cfHobs > 0, H > 0 && a4'[H x4] < 0], Simplify[cfHobs < 0, H > 0 && a4'[H x4] > 0]}];
cfRho4 = cfVhid rho8;                                        (* rho_4 = Vhid rho_8, with rho_8 = T_44 constant in x4 *)
cfP4   = w4 cfRho4;                                          (* P_4 = w rho_4, any w *)
cfAssert["VOLUME [has content]: the reduced density rho_4 = Vhid rho_8 is NOT separately conserved:  d rho_4/dx4 + 3 H_obs (rho_4 + P_4) == 3 H_obs P_4, for every w",
  cfZeroQ[D[cfRho4, x4] + 3 cfHobs (cfRho4 + cfP4) - 3 cfHobs cfP4]];
cfAssert["VOLUME [has content]: equivalently d rho_4/dx4 == -3 H_obs rho_4: rho_4 falls as a^-3 for EVERY w -- a volume effect, the same for a cosmological constant as for dust",
  cfZeroQ[D[cfRho4, x4] + 3 cfHobs cfRho4]];
cfAssert["VOLUME [has content]: while the locally measured density rho_8 = T_44 of phi(x4) is exactly constant in x4 (Section 23, on shell)",
  cfZeroQ[D[cfRho4x, x4] /. cfPhi4''[x4] -> -cfVphi'[cfPhi4[x4]]]];
cfAssert["PART VI [control]: a4 is STILL UNDEFINED -- nothing in Part VI gave it a value; and the FLRW scale factor aF never entered the canonical frame",
  {ValueQ[a4] === False, DownValues[a4] === {}, FreeQ[frameCanonical, aF], FreeQ[gCanonical, aF]}];
{ValueQ[a4], DownValues[a4]}
]];

(* ---------- Input cell 172 ---------- *)
cfRunCell[172, Hold[
(* --- final tally of every assertion made in this notebook, Parts I-VI ---------------------- *)
Print["identities accepted on numerical evidence alone : ", $cfNumericCertificates,
      "   (stage 3 returned True)"];
Print["non-vanishing witnesses                         : ", $cfNonVanishingWitnesses,
      "   (cfNonZeroWitnessQ found a probe point at which every entry is a"];
Print["                                                     number and one of them is non-zero: a complete",
      " proof of non-vanishing)"];
cfAssert["no identity in this notebook was accepted on numerical evidence alone",
  $cfNumericCertificates === 0];
cfAssertSummary[]
]];

cfRunSummary[];
