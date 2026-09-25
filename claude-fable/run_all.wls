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

(* ---------- Input cell 173 ---------- *)
cfRunCell[173, Hold[
ClearAll[cfSymQ, cfCminus, cfCplus, cfRank16, cfCliffordTable, cfSimp60];
(* Part VII decides some identities with Simplify directly; the session's 1-second budget (Section 1) is too  *)
(* small for a few of them, so this Part passes an explicit budget instead of changing the session policy.   *)
cfSimp60[e_] := Simplify[e, TimeConstraint -> 60];
cfSimp60[e_, a_] := Simplify[e, a, TimeConstraint -> 60];
cfSymQ[m_] := Which[m === Transpose[m], "S", m === -Transpose[m], "A", True, "neither"];
cfCminus = \[Sigma]16;
cfCplus  = \[Sigma]16 . T16[8];
cfRank16[b_] := If[b[[1]] === ID16, 0, Length[b[[2]]]];       (* base16 stores the identity as {ID16, {{0,...,7}}} *)
cfCliffordTable = Table[With[{sel = Select[base16, cfRank16[#] == r &]},
    {r, Length[sel], Union[cfSymQ[cfCminus . #[[1]]] & /@ sel], Union[cfSymQ[cfCplus . #[[1]]] & /@ sel]}], {r, 0, 8}];
cfAssert["REFINEMENT [definition]: T16[8]^2 == sigma16^2 == C+^2 == ID16, C+ is symmetric, and C+ . T16[8] == sigma16 -- the four candidate mass matrices are only two",
  {T16[8] . T16[8] === ID16, \[Sigma]16 . \[Sigma]16 === ID16, cfCplus . cfCplus === ID16, cfSymQ[cfCplus] === "S",
   cfCplus . T16[8] === \[Sigma]16, \[Sigma]16 . T16[8] === cfCplus}];
cfAssert["REFINEMENT [has content]: C- T16[a] C-^-1 == -T16[a]^T and C+ T16[a] C+^-1 == +T16[a]^T for a = 0..7",
  Join[Table[cfCminus . T16[a] . Inverse[cfCminus] === -Transpose[T16[a]], {a, 0, 7}],
       Table[cfCplus . T16[a] . Inverse[cfCplus] === Transpose[T16[a]], {a, 0, 7}]]];
cfAssert["REFINEMENT [THE RESULT]: the symmetry of C Gamma depends only on the rank r of Gamma:  C-: S A A S S A A S S,  C+: S S A A S S A A S  (r = 0..8)",
  {cfCliffordTable[[All, 3]] === Map[List, Characters["SAASSAASS"]],
   cfCliffordTable[[All, 4]] === Map[List, Characters["SSAASSAAS"]],
   cfCliffordTable[[All, 2]] === Table[Binomial[8, r], {r, 0, 8}]}];
cfAssert["REFINEMENT [has content]: for each C, 136 of the 256 products are symmetric and 120 antisymmetric",
  {Total[Pick[cfCliffordTable[[All, 2]], cfCliffordTable[[All, 3]], {"S"}]] === 136,
   Total[Pick[cfCliffordTable[[All, 2]], cfCliffordTable[[All, 3]], {"A"}]] === 120,
   Total[Pick[cfCliffordTable[[All, 2]], cfCliffordTable[[All, 4]], {"S"}]] === 136,
   Total[Pick[cfCliffordTable[[All, 2]], cfCliffordTable[[All, 4]], {"A"}]] === 120}];
Grid[Prepend[cfCliffordTable /. {s_String} :> s, {"rank r", "number of products", "C- Gamma = sigma16 Gamma", "C+ Gamma = sigma16 T16[8] Gamma"}],
  Frame -> All, Alignment -> Center]
]];

(* ---------- Input cell 174 ---------- *)
cfRunCell[174, Hold[
ClearAll[cfInvVars, cfInvForms];
cfInvVars  = Array[cfInvN, {16, 16}];
cfInvForms = Map[Partition[#, 16] &, NullSpace[Normal[CoefficientArrays[
    Flatten[Table[Transpose[SAB[[a, b]]] . cfInvVars + cfInvVars . SAB[[a, b]], {a, 1, 7}, {b, a + 1, 8}]], Flatten[cfInvVars]][[2]]]]];
cfAssert["REFINEMENT [THE RESULT]: the Spin(4,4)-invariant bilinear forms on the 16-spinor form a 2-dimensional space, spanned by C- = sigma16 and C+ = sigma16 T16[8]",
  {Length[cfInvForms] === 2, MatrixRank[Join[Flatten /@ cfInvForms, {Flatten[cfCminus], Flatten[cfCplus]}]] === 2}];
cfAssert["REFINEMENT [has content]: every invariant form is SYMMETRIC and chirality-diagonal, and the two chiral pieces PL sigma16 PL and PR sigma16 PR are invariant separately",
  {Union[cfSymQ /@ cfInvForms] === {"S"}, Table[n . T16[8] === T16[8] . n, {n, cfInvForms}],
   Table[Transpose[SAB[[a, b]]] . (PL . \[Sigma]16 . PL) + (PL . \[Sigma]16 . PL) . SAB[[a, b]] === ZERO16, {a, 8}, {b, 8}],
   Table[Transpose[SAB[[a, b]]] . (PR . \[Sigma]16 . PR) + (PR . \[Sigma]16 . PR) . SAB[[a, b]] === ZERO16, {a, 8}, {b, 8}]}];
{Length[cfInvForms], " invariant forms, all symmetric"}
]];

(* ---------- Input cell 175 ---------- *)
cfRunCell[175, Hold[
ClearAll[grClean, grGen, grAdd, grScale, grMul, grSame, grBil, grD, grDL, grConj, grRandom, grDeg, grEL];
grClean[x_Association] := Select[Map[Expand, x], # =!= 0 &];
grGen[i_Integer] := <|{i} -> 1|>;
grAdd[xs___Association] := grClean[Merge[{xs}, Total]];
grScale[c_, x_Association] := grClean[Map[c # &, x]];
grMul[x_Association, y_Association] := grClean[Merge[Flatten[Table[
     With[{c = Join[ka, kb]}, If[DuplicateFreeQ[c], <|Sort[c] -> Signature[c] x[ka] y[kb]|>, Nothing]],
     {ka, Keys[x]}, {kb, Keys[y]}]], Total]];
(* Associations are ORDERED, so two equal elements can differ as expressions: compare by difference *)
grSame[x_Association, y_Association] := grAdd[x, grScale[-1, y]] === <||>;
grBil[xs_List, n_, ys_List] := grAdd @@ Flatten[Table[If[n[[a, b]] === 0, Nothing, grScale[n[[a, b]], grMul[xs[[a]], ys[[b]]]]],
    {a, Length[xs]}, {b, Length[ys]}]];
grD[x_Association, dmap_] := grClean[Merge[Flatten[KeyValueMap[Function[{mm, c},
       Table[With[{m2 = ReplacePart[mm, i -> dmap[mm[[i]]]]}, If[DuplicateFreeQ[m2], <|Sort[m2] -> Signature[m2] c|>, Nothing]],
         {i, Length[mm]}]], x]], Total]];
grDL[x_Association, i_Integer] := grClean[Merge[KeyValueMap[Function[{mm, c},
       With[{p = FirstPosition[mm, i]}, If[MissingQ[p], Nothing, <|Delete[mm, p] -> (-1)^(p[[1]] - 1) c|>]]], x], Total]];
grConj[x_Association] := grClean[Association[KeyValueMap[#1 -> (-1)^(Length[#1] (Length[#1] - 1)/2) Conjugate[#2] &, x]]];
grDeg[x_Association] := Union[Length /@ Keys[x]];
grRandom[deg_Integer, gens_List, nt_Integer] := grClean[Association[Table[Sort[RandomSample[gens, deg]] ->
     RandomInteger[{-4, 4}] + I RandomInteger[{-4, 4}], {nt}]]];
(* Euler-Lagrange expression of L(theta, phi = d theta), left derivatives:  dL/dtheta_c - d( dL/dphi_c ) *)
grEL[L_Association, thIdx_List, phIdx_List, dmap_] := Table[
   grAdd[grDL[L, thIdx[[c]]], grScale[-1, grD[grDL[L, phIdx[[c]]], dmap]]], {c, Length[thIdx]}];
(* --- tests on known identities ------------------------------------------------------------- *)
SeedRandom[20260924];
Module[{x1, x2, x3, y1, y2, e1, e2, dm = (# + 10 &)},
  cfAssert["GRASSMANN [solver regression]: generators anticommute and square to zero (all pairs of 1..6)",
    Flatten[Table[{grSame[grMul[grGen[i], grGen[j]], grScale[-1, grMul[grGen[j], grGen[i]]]], grMul[grGen[i], grGen[i]] === <||>}, {i, 6}, {j, 6}]]];
  x1 = grRandom[1, Range[8], 5]; x2 = grRandom[2, Range[8], 6]; x3 = grRandom[3, Range[8], 6];
  cfAssert["GRASSMANN [solver regression]: the product is associative, (x y) z == x (y z), on elements of degree 1, 2, 3 (and the products tested are not zero)",
    {grSame[grMul[grMul[x1, x2], x3], grMul[x1, grMul[x2, x3]]], grSame[grMul[grMul[x3, x1], x2], grMul[x3, grMul[x1, x2]]],
     grMul[grMul[x3, x1], x2] =!= <||>, grMul[grMul[x1, x2], x3] =!= <||>}];
  cfAssert["GRASSMANN [solver regression]: graded commutativity  x y == (-1)^(|x| |y|) y x  (degrees 1, 2, 3), and x^2 == 0 for x odd",
    {grMul[x1, x1] === <||>, grSame[grMul[x1, x3], grScale[-1, grMul[x3, x1]]], grSame[grMul[x2, x3], grMul[x3, x2]],
     grSame[grMul[x1, x2], grMul[x2, x1]], grMul[x1, x3] =!= <||>, grMul[x2, x3] =!= <||>}];
  e1 = grAdd[x1, x2]; e2 = grAdd[x2, x3, <|{} -> 2 - I|>];
  cfAssert["GRASSMANN [solver regression]: the conjugation is an involutive anti-automorphism,  (x y)^ddag == y^ddag x^ddag,  (x^ddag)^ddag == x",
    {grSame[grConj[grMul[e1, e2]], grMul[grConj[e2], grConj[e1]]], grSame[grConj[grConj[e2]], e2],
     grSame[grConj[grMul[x1, x3]], grMul[grConj[x3], grConj[x1]]], grMul[e1, e2] =!= <||>}];
  y1 = grRandom[2, Range[10], 5]; y2 = grRandom[3, Range[10], 5];
  cfAssert["GRASSMANN [solver regression]: grD is an even derivation, d(x y) == d(x) y + x d(y);  grDL obeys d_i(x y) == d_i(x) y + (-1)^|x| x d_i(y)",
    {grSame[grD[grMul[y1, y2], dm], grAdd[grMul[grD[y1, dm], y2], grMul[y1, grD[y2, dm]]]],
     Table[grSame[grDL[grMul[y1, y2], i], grAdd[grMul[grDL[y1, i], y2], grMul[y1, grDL[y2, i]]]], {i, 10}],
     Table[grSame[grDL[grMul[x1, x3], i], grAdd[grMul[grDL[x1, i], x3], grScale[-1, grMul[x1, grDL[x3, i]]]]], {i, 8}],
     grD[grMul[y1, y2], dm] =!= <||>}]];
(* --- the lemmas, for a symbolic 16x16 matrix ------------------------------------------------- *)
ClearAll[cfTh, cfPh, cfDmap, cfNsym];
cfTh = Table[grGen[a], {a, 16}];  cfPh = Table[grGen[a + 16], {a, 16}];
cfDmap = (# + 16 &);                                       (* theta_a -> phi_a -> (second derivative) : d/dt *)
cfNsym = Array[cfNn, {16, 16}];
cfAssert["GRASSMANN [THE RESULT]: theta^T N theta == theta^T N_A theta and theta^T N_S theta == 0 for a general 16x16 N -- an anticommuting bilinear sees only the ANTISYMMETRIC part",
  {grSame[grBil[cfTh, cfNsym, cfTh], grBil[cfTh, (cfNsym - Transpose[cfNsym])/2, cfTh]], grBil[cfTh, (cfNsym + Transpose[cfNsym])/2, cfTh] === <||>}];
cfAssert["GRASSMANN [THE RESULT]: theta^T N phi - (1/2) d(theta^T N theta) == theta^T N_S phi for a general N",
  grSame[grAdd[grBil[cfTh, cfNsym, cfPh], grScale[-1/2, grD[grBil[cfTh, cfNsym, cfTh], cfDmap]]], grBil[cfTh, (cfNsym + Transpose[cfNsym])/2, cfPh]]];
cfAssert["GRASSMANN [THE RESULT]: the Euler-Lagrange expression of L = theta^T N phi (left derivatives) is (N + N^T) phi: EMPTY field equations exactly when N is antisymmetric",
  MapThread[grSame, {grEL[grBil[cfTh, cfNsym, cfPh], Range[16], Range[17, 32], cfDmap],
     Table[grBil[{<|{} -> 1|>}, {(cfNsym + Transpose[cfNsym])[[c]]}, cfPh], {c, 16}]}]];
cfAssert["GRASSMANN [control]: for COMMUTING components the roles are reversed -- theta^T N theta sees only N_S, and the Euler-Lagrange expression of theta^T N phi is 2 N_A phi",
  Module[{tc = Array[cfTc, 16], pc = Array[cfPc, 16], lc},
    lc = tc . cfNsym . pc;
    {Expand[tc . cfNsym . tc - tc . ((cfNsym + Transpose[cfNsym])/2) . tc] === 0,
     Expand[D[lc, {tc}] - (D[lc, {pc}] /. Thread[tc -> pc]) - (cfNsym - Transpose[cfNsym]) . pc] === ConstantArray[0, 16]}]];
{Length[grBil[cfTh, cfNsym, cfTh]], " monomials in theta^T N theta (= 16*15/2)"}
]];

(* ---------- Input cell 176 ---------- *)
cfRunCell[176, Hold[
ClearAll[cfGrKin, cfGrV, cfGrB, cfGrC, cfGrVV, cfGrBB, cfGrCC, cfGrRatio];
cfGrKin[c_, a_] := grBil[cfTh, c . T16[a], cfPh];                        (* theta^T C T16[a] d theta *)
cfAssert["REFINEMENT (a) [THE RESULT]: real Grassmann + sigma16: both invariant mass terms vanish, and theta^T sigma16 T16[a] phi == (1/2) d(theta^T sigma16 T16[a] theta) for every a (a total derivative)",
  {grBil[cfTh, \[Sigma]16, cfTh] === <||>, grBil[cfTh, cfCplus, cfTh] === <||>,
   Table[grSame[cfGrKin[\[Sigma]16, a], grScale[1/2, grD[grBil[cfTh, \[Sigma]16 . T16[a], cfTh], cfDmap]]], {a, 0, 7}]}];
cfAssert["REFINEMENT (a) [has content]: its Euler-Lagrange expression is identically empty in every direction -- while the kinetic term itself is NOT zero",
  {Table[Union[grEL[cfGrKin[\[Sigma]16, a], Range[16], Range[17, 32], cfDmap]] === {<||>}, {a, 0, 7}],
   Table[Length[cfGrKin[\[Sigma]16, a]] > 0, {a, 0, 7}]}];
cfAssert["REFINEMENT (a) [THE RESULT]: FRAME-INDEPENDENT -- sigma16 {T16[a], S^bc} is SYMMETRIC for all a, b, c (so theta^T sigma16 {gamma^mu, Gamma_mu} theta == 0 on every frame), and d_mu(Sqrt[g] sigma16 gamma^mu) == Sqrt[g] sigma16 [gamma^mu, Gamma_mu] on the canonical frame",
  {Union[Flatten[Table[cfSymQ[\[Sigma]16 . (T16[a - 1] . SAB[[b, c]] + SAB[[b, c]] . T16[a - 1])], {a, 8}, {b, 8}, {c, 8}]]] === {"S"},
   Table[grBil[cfTh, \[Sigma]16 . (T16[a - 1] . SAB[[b, c]] + SAB[[b, c]] . T16[a - 1]), cfTh] === <||>, {a, 8}, {b, 3}, {c, 8}],
   cfZeroArrayQ[Sum[D[cfSqrtg \[Sigma]16 . cfGamUp[[mu]], X[[mu]]], {mu, 8}]
     - cfSqrtg \[Sigma]16 . Sum[cfGamUp[[mu]] . GammaSpinCanonical[[mu]] - GammaSpinCanonical[[mu]] . cfGamUp[[mu]], {mu, 8}]]}];
cfAssert["REFINEMENT (b) [THE RESULT]: Majorana with C+: the kinetic term is genuine -- Euler-Lagrange expression 2 C+ T16[a] phi with C+ T16[a] invertible -- but every invariant bilinear vanishes (massless, no V(s))",
  {Table[MapThread[grSame, {grEL[cfGrKin[cfCplus, a], Range[16], Range[17, 32], cfDmap],
      Table[grBil[{<|{} -> 1|>}, {2 (cfCplus . T16[a])[[c]]}, cfPh], {c, 16}]}], {a, 0, 7}],
   Table[Det[cfCplus . T16[a]] =!= 0, {a, 0, 7}],
   Table[grBil[cfTh, n, cfTh] === <||>, {n, Join[cfInvForms, {cfCminus, cfCplus, \[Sigma]16 . T16[8], cfCplus . T16[8]}]}]}];
cfGrV = Table[grBil[cfTh, \[Sigma]16 . T16[a], cfTh], {a, 0, 7}];
cfGrB = Flatten[Table[If[a < b, {grBil[cfTh, cfCplus . T16[a] . T16[b], cfTh], \[Eta]4488[[a + 1, a + 1]] \[Eta]4488[[b + 1, b + 1]]}, Nothing], {a, 0, 7}, {b, 0, 7}], 1];
cfGrC = Flatten[Table[If[a < b < c, {grBil[cfTh, cfCplus . T16[a] . T16[b] . T16[c], cfTh], \[Eta]4488[[a + 1, a + 1]] \[Eta]4488[[b + 1, b + 1]] \[Eta]4488[[c + 1, c + 1]]}, Nothing],
    {a, 0, 7}, {b, 0, 7}, {c, 0, 7}], 2];
cfGrVV = grAdd @@ Table[grScale[\[Eta]4488[[a + 1, a + 1]], grMul[cfGrV[[a + 1]], cfGrV[[a + 1]]]], {a, 0, 7}];
cfGrBB = grAdd @@ Table[grScale[e[[2]], grMul[e[[1]], e[[1]]]], {e, cfGrB}];
cfGrCC = grAdd @@ Table[grScale[e[[2]], grMul[e[[1]], e[[1]]]], {e, cfGrC}];
cfGrRatio[x_, y_] := Union[Table[x[k]/y[k], {k, Keys[y]}]];                  (* the ratio, monomial by monomial *)
cfAssert["REFINEMENT (b) [has content]: the scope -- the quartic Lorentz scalars v.v, B.B, C.C of the Majorana spinor are NOT zero and are all proportional to ONE quartic (same monomials, one constant ratio each)",
  {Length[cfGrBB] > 0, grDeg[cfGrBB] === {4}, Sort[Keys[cfGrVV]] === Sort[Keys[cfGrBB]] === Sort[Keys[cfGrCC]],
   Length[cfGrRatio[cfGrVV, cfGrBB]] === 1, Length[cfGrRatio[cfGrCC, cfGrBB]] === 1}];
cfAssert["REFINEMENT (b) [has content]: and the commuting shadow of the C+ Majorana spinor has NO kinetic term: for commuting components theta^T C+ T16[a] phi is the total derivative (1/2) d(theta^T C+ T16[a] theta)",
  Module[{tc = Array[cfTc, 16], pc = Array[cfPc, 16]},
    Table[Expand[tc . cfCplus . T16[a] . pc - (1/2) (D[tc . cfCplus . T16[a] . tc, {tc}] . pc)] === 0, {a, 0, 7}]]];
cfAssert["REFINEMENT (c) [THE RESULT]: Weyl and Majorana-Weyl: PL C T16[a] PL == PR C T16[a] PR == 0 for C = C-, C+ and every a (C chirality-diagonal, T16[a] chirality-odd) -- no kinetic term",
  {Table[{PL . c . T16[a] . PL === ZERO16, PR . c . T16[a] . PR === ZERO16}, {c, {cfCminus, cfCplus}}, {a, 0, 7}],
   Table[{c . T16[8] === T16[8] . c, T16[a] . T16[8] === -T16[8] . T16[a]}, {c, {cfCminus, cfCplus}}, {a, 0, 7}]}];
{"quartic scalars: ", Length[cfGrBB], " monomials;  v.v/B.B = ", First[cfGrRatio[cfGrVV, cfGrBB]], ",  C.C/B.B = ", First[cfGrRatio[cfGrCC, cfGrBB]]}
]];

(* ---------- Input cell 177 ---------- *)
cfRunCell[177, Hold[
ClearAll[cfTh1, cfTh2, cfPh1, cfPh2, cfDmapC, cfGPsi, cfGPhi, cfGPsiC, cfGPhiC, cfGS, cfGP, cfGKin, cfGKinSym, cfGAmat, cfOmegaMat];
cfTh1 = Table[grGen[a], {a, 16}];       cfTh2 = Table[grGen[a + 16], {a, 16}];
cfPh1 = Table[grGen[a + 32], {a, 16}];  cfPh2 = Table[grGen[a + 48], {a, 16}];
cfDmapC = (# + 32 &);
cfGPsi = Table[grAdd[grScale[1/Sqrt[2], cfTh1[[a]]], grScale[I/Sqrt[2], cfTh2[[a]]]], {a, 16}];
cfGPhi = Table[grAdd[grScale[1/Sqrt[2], cfPh1[[a]]], grScale[I/Sqrt[2], cfPh2[[a]]]], {a, 16}];
cfGPsiC = grConj /@ cfGPsi;  cfGPhiC = grConj /@ cfGPhi;                        (* Psi^ddag, phi^ddag *)
cfGS = grBil[cfGPsiC, \[Sigma]16, cfGPsi];                                       (* s = Psibar Psi *)
cfGP = grBil[cfGPsiC, cfCplus, cfGPsi];                                          (* p = Psibar T16[8] Psi *)
cfAssert["REFINEMENT (d) [definition]: Psi^ddag == (theta1 - i theta2)^T/Sqrt[2] in the algebra",
  MapThread[grSame, {cfGPsiC, Table[grAdd[grScale[1/Sqrt[2], cfTh1[[a]]], grScale[-I/Sqrt[2], cfTh2[[a]]]], {a, 16}]}]];
cfAssert["REFINEMENT (d) [THE RESULT]: s = Psibar Psi == i theta1^T sigma16 theta2: NON-ZERO (16 monomials) and HERMITIAN; p = Psibar T16[8] Psi is non-zero and Hermitian too",
  {grSame[cfGS, grScale[I, grBil[cfTh1, \[Sigma]16, cfTh2]]], Length[cfGS] === 16, grSame[grConj[cfGS], cfGS],
   Length[cfGP] === 16, grSame[grConj[cfGP], cfGP], grSame[cfGP, grBil[cfGPsiC, \[Sigma]16 . T16[8], cfGPsi]]}];
cfAssert["REFINEMENT (d) [has content]: s is a sum of 16 commuting nilpotent even elements x_a (x_a x_b == x_b x_a, x_a^2 == 0), so s^17 == 0 and V(s) is a finite polynomial",
  Module[{xs = KeyValueMap[<|#1 -> #2|> &, cfGS]},
    {Length[xs] === 16, Table[grSame[grMul[xs[[i]], xs[[j]]], grMul[xs[[j]], xs[[i]]]], {i, 16}, {j, 16}], Table[grMul[x, x] === <||>, {x, xs}],
     grSame[grAdd @@ xs, cfGS], grSame[grMul[cfGS, cfGS], grScale[2, grAdd @@ Flatten[Table[grMul[xs[[i]], xs[[j]]], {i, 16}, {j, i + 1, 16}]]]]}]];
cfGKin    = grBil[cfGPsiC, \[Sigma]16 . T16[4], cfGPhi];                                   (* Psi^ddag K phi, K = sigma16 T16[4] *)
cfGKinSym = grAdd[grScale[1/2, cfGKin], grScale[-1/2, grBil[cfGPhiC, \[Sigma]16 . T16[4], cfGPsi]]];
cfGAmat   = Table[Lookup[cfGKin, Key[{i, j + 32}], 0], {i, 32}, {j, 32}];                 (* Theta^T A Phi *)
cfOmegaMat = ArrayFlatten[{{0, \[Sigma]16 . T16[4]}, {-\[Sigma]16 . T16[4], 0}}];
cfAssert["REFINEMENT (d) [definition]: the 32x32 matrix A read off the algebra reproduces Psi^ddag K phi exactly",
  grSame[grBil[Join[cfTh1, cfTh2], cfGAmat, Join[cfPh1, cfPh2]], cfGKin]];
cfAssert["REFINEMENT (d) [THE RESULT]: its symmetric part is A_S == (i/2) Omega, Omega = [[0, K], [-K, 0]] real SYMMETRIC and invertible: a genuine kinetic term",
  {(cfGAmat + Transpose[cfGAmat])/2 === (I/2) cfOmegaMat, cfSymQ[cfOmegaMat] === "S", Det[cfOmegaMat] =!= 0}];
cfAssert["REFINEMENT (d) [has content]: the symmetrized kinetic term is HERMITIAN and equals Psi^ddag K phi - (1/2) d(Psi^ddag K Psi); the unsymmetrized one is not Hermitian",
  {grSame[grConj[cfGKinSym], cfGKinSym], grSame[cfGKinSym, grAdd[cfGKin, grScale[-1/2, grD[grBil[cfGPsiC, \[Sigma]16 . T16[4], cfGPsi], cfDmapC]]]],
   ! grSame[grConj[cfGKin], cfGKin]}];
cfAssert["REFINEMENT (d) [has content]: the same holds in every direction a = 0..7: the symmetrized Psi^ddag sigma16 T16[a] phi is Hermitian, with symmetric part (i/2)[[0, sigma16 T16[a]], [-sigma16 T16[a], 0]] != 0",
  Table[Module[{kin = grBil[cfGPsiC, \[Sigma]16 . T16[a], cfGPhi], am, ks},
     am = Table[Lookup[kin, Key[{i, j + 32}], 0], {i, 32}, {j, 32}];
     ks = grAdd[grScale[1/2, kin], grScale[-1/2, grBil[cfGPhiC, \[Sigma]16 . T16[a], cfGPsi]]];
     {grSame[grConj[ks], ks], (am + Transpose[am])/2 === (I/2) ArrayFlatten[{{0, \[Sigma]16 . T16[a]}, {-\[Sigma]16 . T16[a], 0}}]}], {a, 0, 7}]];
{Length[cfGS], " monomials in Psibar Psi;  ", Length[cfGKin], " in Psi^ddag K phi"}
]];

(* ---------- Input cell 178 ---------- *)
cfRunCell[178, Hold[
ClearAll[cfObsAlg, cfCommutant, cfOmega4, cfHid, cfHidAlg];
cfObsAlg = Join[{ID16}, Table[Dot @@ (T16 /@ s), {s, Subsets[{1, 2, 3, 4}, {1, 4}]}]];
cfCommutant = Map[Partition[#, 16] &, NullSpace[Normal[CoefficientArrays[
    Flatten[Table[Array[cfCm, {16, 16}] . T16[i] - T16[i] . Array[cfCm, {16, 16}], {i, 1, 4}]], Flatten[Array[cfCm, {16, 16}]]][[2]]]]];
cfOmega4 = T16[1] . T16[2] . T16[3] . T16[4];
cfHid = Table[cfOmega4 . T16[A], {A, {0, 5, 6, 7}}];
cfHidAlg = Join[{ID16}, Table[Dot @@ (cfHid[[#]] & /@ s), {s, Subsets[{1, 2, 3, 4}, {1, 4}]}]];
cfAssert["4D [THE RESULT]: the 16 ordered products of T16[1..4] are linearly independent (the observer's algebra is M4(C)), and its commutant in M16(C) is 16-dimensional",
  {Length[cfObsAlg] === 16, MatrixRank[Flatten /@ cfObsAlg] === 16, Length[cfCommutant] === 16}];
cfAssert["4D [has content]: Omega4^2 == -ID16, the hidden gammas h_A = Omega4 T16[A] (A = 0,5,6,7) commute with T16[1..4] and obey {h_A, h_B} == -2 eta_AB",
  {cfOmega4 . cfOmega4 === -ID16,
   Table[cfHid[[A]] . T16[i] === T16[i] . cfHid[[A]], {A, 4}, {i, 1, 4}],
   Table[cfHid[[A]] . cfHid[[B]] + cfHid[[B]] . cfHid[[A]] === -2 \[Eta]4488[[{1, 6, 7, 8}[[A]], {1, 6, 7, 8}[[B]]]] ID16, {A, 4}, {B, 4}]}];
cfAssert["4D [THE RESULT]: the 16 products of the hidden gammas span the commutant, and the two algebras meet only in the multiples of ID16 (rank of the union 16 + 16 - 1 = 31): C^16 = C^4 (x) C^4, four 4D Dirac fermions",
  {MatrixRank[Flatten /@ cfHidAlg] === 16, MatrixRank[Join[Flatten /@ cfHidAlg, Flatten /@ cfCommutant]] === 16,
   MatrixRank[Join[Flatten /@ cfObsAlg, Flatten /@ cfHidAlg]] === 31}];
cfAssert["4D [has content]: the observer's Lorentz generators T16[i] T16[j] (i < j in 1..4) commute with every hidden gamma",
  Table[(T16[i] . T16[j]) . cfHid[[A]] === cfHid[[A]] . (T16[i] . T16[j]), {i, 1, 4}, {j, i + 1, 4}, {A, 4}]];
{Length[cfObsAlg], Length[cfCommutant], MatrixRank[Join[Flatten /@ cfObsAlg, Flatten /@ cfHidAlg]]}
]];

(* ---------- Input cell 179 ---------- *)
cfRunCell[179, Hold[
ClearAll[cfLhatFermion, cfEquationFermion, cfAdjointEquationFermion, cfTFermion, cfPsiCGen, cfPsiBGen, cfRealRule, cfRealRuleFlat,
         cfLhatC, cfLC, cfELbarC, cfELpsiC, cfGamFlat, cfZeroSpin];
cfLhatFermion[psi_List, psib_List, gamUp_List, gamSpin_List, Vfun_] :=
  (1/(2 H)) Sum[psib . gamUp[[mu]] . (D[psi, X[[mu]]] + gamSpin[[mu]] . psi)
      - (D[psib, X[[mu]]] - psib . gamSpin[[mu]]) . gamUp[[mu]] . psi, {mu, 8}] - Vfun[psib . psi];
cfEquationFermion[psi_List, psib_List, gamUp_List, gamSpin_List, Vfun_] :=
  Sum[gamUp[[mu]] . (D[psi, X[[mu]]] + gamSpin[[mu]] . psi), {mu, 8}] - H Vfun'[psib . psi] psi;
cfAdjointEquationFermion[psi_List, psib_List, gamUp_List, gamSpin_List, Vfun_] :=
  Sum[(D[psib, X[[mu]]] - psib . gamSpin[[mu]]) . gamUp[[mu]], {mu, 8}] + H Vfun'[psib . psi] psib;
cfTFermion[psi_List, psib_List, gamUp_List, gamSpin_List, gmet_, Vfun_] := Module[{gamDn, dP, dB, lh},
  gamDn = Table[Sum[gmet[[mu, nu]] gamUp[[nu]], {nu, 8}], {mu, 8}];
  dP = Table[D[psi, X[[mu]]] + gamSpin[[mu]] . psi, {mu, 8}];
  dB = Table[D[psib, X[[mu]]] - psib . gamSpin[[mu]], {mu, 8}];
  lh = cfLhatFermion[psi, psib, gamUp, gamSpin, Vfun];
  Table[-(1/(4 H)) (psib . gamDn[[mu]] . dP[[nu]] - dB[[nu]] . gamDn[[mu]] . psi + psib . gamDn[[nu]] . dP[[mu]] - dB[[mu]] . gamDn[[nu]] . psi)
    + gmet[[mu, nu]] lh, {mu, 8}, {nu, 8}]];
(* the complex field and its conjugate, independent, generic in (x0, x4) *)
cfPsiCGen = Table[cfPsiC[k][x0, x4], {k, 0, 15}];
cfPsiBGen = Table[cfPsiB[k][x0, x4], {k, 0, 15}];
(* the bosonic shadow: Psi -> psi (Part VI's real commuting field), Psibar -> psi^T sigma16 *)
cfRealRule = Join[Table[cfPsiC[k] -> cfPsiF[k], {k, 0, 15}],
   Table[With[{kk = k}, cfPsiB[kk] -> Function[{u0, u4}, Evaluate[(cfPsiGen . \[Sigma]16)[[kk + 1]] /. {x0 -> u0, x4 -> u4}]]], {k, 0, 15}]];
cfRealRuleFlat = Join[Table[cfPsiC[k] -> f16[k], {k, 0, 15}],
   Table[With[{kk = k}, cfPsiB[kk] -> Function[{u0, u4}, Evaluate[(\[CapitalPsi]16 . \[Sigma]16)[[kk + 1]] /. {x0 -> u0, x4 -> u4}]]], {k, 0, 15}]];
cfGamFlat  = Table[T16[mu - 1], {mu, 8}];
cfZeroSpin = ConstantArray[ZERO16, 8];
cfLhatC  = cfLhatFermion[cfPsiCGen, cfPsiBGen, cfGamUp, GammaSpinCanonical, cfVs];
cfLC     = cfSqrtg cfLhatC;
cfELbarC = cfTimed["Euler-Lagrange expressions of the complex fable with respect to Psibar, generic (x0, x4)", cfEulerLagrange[cfLC, cfPsiBGen, X]];
cfELpsiC = cfTimed["Euler-Lagrange expressions of the complex fable with respect to Psi, generic (x0, x4)", cfEulerLagrange[cfLC, cfPsiCGen, X]];
cfAssert["FIDELITY [1] [fidelity]: Psi -> psi, Psibar -> psi^T sigma16 turns the symmetrized covariant Lhat into Part VI's cfLhatFable EXACTLY (canonical frame, generic V)",
  Expand[(cfLhatC /. cfRealRule) - cfLhatFable] === 0];
cfAssert["FIDELITY [2] [fidelity]: on the flat frame with V = -(2M/H) s and no volume factor, the same limit on Psi16 IS the author's La[] of Section 11",
  cfZeroQ[cfLhatFermion[\[CapitalPsi]16, \[CapitalPsi]16 . \[Sigma]16, cfGamFlat, cfZeroSpin, (-(2 M/H) # &)] - La[]]];
cfAssert["FIDELITY [3] [fidelity]: sigma16 . EL_Psibar + EL_Psi in the real limit == Part VI's explicit variation cfELFable, component for component",
  cfZeroArrayQ[Expand[\[Sigma]16 . (cfELbarC /. cfRealRule) + (cfELpsiC /. cfRealRule) - cfELFable]]];
cfAssert["FIDELITY [3] [fidelity]: and on the flat frame with V = -(2M/H) s the same combination IS the author's eLa of Section 12",
  Module[{lf = cfLhatFermion[cfPsiCGen, cfPsiBGen, cfGamFlat, cfZeroSpin, (-(2 M/H) # &)]},
    cfZeroArrayQ[\[Sigma]16 . (cfEulerLagrange[lf, cfPsiBGen, X] /. cfRealRuleFlat) + (cfEulerLagrange[lf, cfPsiCGen, X] /. cfRealRuleFlat) - eLa]]];
cfAssert["FIDELITY [4] [fidelity]: the energy-momentum tensor That in the real limit IS Part VI's covariant tensor cfTCov, all 64 components",
  cfZeroArrayQ[Expand[(cfTFermion[cfPsiCGen, cfPsiBGen, cfGamUp, GammaSpinCanonical, gCanonical, cfVs] /. cfRealRule) - cfTCov]]];
Short[cfLhatC, 3]
]];

(* ---------- Input cell 180 ---------- *)
cfRunCell[180, Hold[
ClearAll[cfPsiC8, cfPsiB8, cfS8, cfLsym8, cfLsymD8, cfLun8, cfLunD8, cfUVRule8, cfRealRule8, cfConjFlip, cfExpandV, cfAnti, cfComm, cfSumGG];
cfPsiC8 = Table[cfPsiCA[k] @@ X, {k, 0, 15}];                 (* Psi(x0, ..., x7)    *)
cfPsiB8 = Table[cfPsiBA[k] @@ X, {k, 0, 15}];                 (* Psibar(x0, ..., x7) *)
cfS8    = cfPsiB8 . cfPsiC8;
cfAnti[a_, b_] := a . b + b . a;   cfComm[a_, b_] := a . b - b . a;
cfLsym8  = cfLhatFermion[cfPsiC8, cfPsiB8, cfGamUp, GammaSpinCanonical, cfVs];
cfLsymD8 = cfLhatFermion[cfPsiC8, cfPsiB8, cfGamUp, cfZeroSpin, cfVs];
cfLun8   = (1/H) cfPsiB8 . Sum[cfGamUp[[mu]] . (D[cfPsiC8, X[[mu]]] + GammaSpinCanonical[[mu]] . cfPsiC8), {mu, 8}] - cfVs[cfS8];
cfLunD8  = (1/H) cfPsiB8 . Sum[cfGamUp[[mu]] . D[cfPsiC8, X[[mu]]], {mu, 8}] - cfVs[cfS8];
cfSumGG  = Sum[cfGamUp[[mu]] . GammaSpinCanonical[[mu]], {mu, 8}];                 (* gamma^mu Gamma_mu = -3 H Cot^2 T16[0] *)
(* Psi = u + i v, Psibar = (u - i v)^T sigma16 with real u, v of all eight coordinates *)
cfUVRule8 = Join[Table[With[{kk = k}, cfPsiCA[kk] -> Function[Evaluate[X], Evaluate[cfReU[kk] @@ X + I cfImV[kk] @@ X]]], {k, 0, 15}],
   Table[With[{kk = k}, cfPsiBA[kk] -> Function[Evaluate[X], Evaluate[(Table[cfReU[j] @@ X - I cfImV[j] @@ X, {j, 0, 15}] . \[Sigma]16)[[kk + 1]]]]], {k, 0, 15}]];
(* complex conjugation of an expression whose only complex numbers are explicit: flip i, then expand inside V *)
cfConjFlip[e_] := (e /. Complex[a_, b_] :> Complex[a, -b]);
cfExpandV[e_] := (e /. (h : cfVs | Derivative[_][cfVs])[a_] :> h[Expand[a]]);        (* expand inside V and its derivatives *)
(* the real commuting limit of the eight-coordinate fields: Psi -> psi, Psibar -> psi^T sigma16 *)
cfRealRule8 = Join[Table[cfPsiCA[k] -> cfPsiRA[k], {k, 0, 15}],
   Table[With[{kk = k}, cfPsiBA[kk] -> Function[Evaluate[X], Evaluate[(Table[cfPsiRA[j] @@ X, {j, 0, 15}] . \[Sigma]16)[[kk + 1]]]]], {k, 0, 15}]];
cfAssert["LAGRANGIAN (a) [definition]: every Gamma^spin_mu is real and sigma16 Gamma_mu is antisymmetric (Gamma_mu^T sigma16 == -sigma16 Gamma_mu): D_mu Psibar is the Dirac conjugate of D_mu Psi",
  {Table[FreeQ[GammaSpinCanonical[[mu]], Complex], {mu, 8}],
   cfZeroArrayQ[Table[Transpose[GammaSpinCanonical[[mu]]] . \[Sigma]16 + \[Sigma]16 . GammaSpinCanonical[[mu]], {mu, 8}]]}];
cfAssert["LAGRANGIAN (b) [THE RESULT]: Lsym is HERMITIAN -- real for Psi = u + i v, Psibar = (u - i v)^T sigma16, generic u, v of all eight coordinates",
  Module[{l = cfExpandV[Expand[cfLsym8 /. cfUVRule8]]},
    Expand[cfExpandV[l - cfConjFlip[l]]] === 0]];
cfAssert["LAGRANGIAN (b) [control]: Lun is NOT Hermitian -- its imaginary part is not zero, witnessed on the constant spinors u = e1, v = e13 (with V = s^2)",
  Module[{l = (cfLun8 /. cfUVRule8) /. {cfReU[j_] :> Function[Evaluate[X], UnitVector[16, 1][[j + 1]]], cfImV[j_] :> Function[Evaluate[X], UnitVector[16, 13][[j + 1]]]}},
    cfNonZeroWitnessQ[(l - cfConjFlip[l]) /. cfVs -> (#^2 &)]]];
cfAssert["LAGRANGIAN (c) [THE RESULT]: Lsym - Lsym_d == (1/(2H)) Sum_mu Psibar {gamma^mu, Gamma_mu} Psi identically, and {gamma^mu, Gamma_mu} == 0 for EACH mu on the canonical frame: Lsym == Lsym_d",
  {Expand[cfLsym8 - cfLsymD8 - (1/(2 H)) Sum[cfPsiB8 . cfAnti[cfGamUp[[mu]], GammaSpinCanonical[[mu]]] . cfPsiC8, {mu, 8}]] === 0,
   Table[cfZeroArrayQ[cfAnti[cfGamUp[[mu]], GammaSpinCanonical[[mu]]]], {mu, 8}],
   Expand[cfLsym8 - cfLsymD8] === 0}];
cfAssert["LAGRANGIAN (d) [has content]: Lun - Lsym == (1/(2H)) (1/Sqrt[g]) d_mu( Sqrt[g] Psibar gamma^mu Psi ), a total divergence",
  cfZeroQ[Expand[cfLun8 - cfLsym8 - (1/(2 H)) (1/cfSqrtg) Sum[D[cfSqrtg cfPsiB8 . cfGamUp[[mu]] . cfPsiC8, X[[mu]]], {mu, 8}]]]];
cfAssert["LAGRANGIAN (e) [has content]: Lun - Lun_d == (1/H) Psibar gamma^mu Gamma_mu Psi == -3 Cot[6 H x0]^2 Psibar T16[0] Psi",
  {Expand[cfLun8 - cfLunD8 - (1/H) cfPsiB8 . cfSumGG . cfPsiC8] === 0, cfZeroArrayQ[cfSumGG + 3 H Cot[6 H x0]^2 T16[0]]}];
cfAssert["LAGRANGIAN (e) [control]: that term is NOT zero for a complex field (witness u = e1, v = e13), and IS zero in the real commuting limit (the scope of Parts V-VI)",
  {cfNonZeroWitnessQ[(-3 Cot[6 H x0]^2 cfPsiB8 . T16[0] . cfPsiC8 /. cfUVRule8) /. {cfReU[j_] :> Function[Evaluate[X], UnitVector[16, 1][[j + 1]]],
      cfImV[j_] :> Function[Evaluate[X], UnitVector[16, 13][[j + 1]]]}],
   Expand[(cfPsiB8 . cfSumGG . cfPsiC8) /. cfRealRule8] === 0}];
(* (f): the partial-derivative Lagrangian and its two Euler-Lagrange expressions *)
Module[{elB, elP, e1, e2, cvB, cvP},
  elB = cfEulerLagrange[cfSqrtg cfLunD8, cfPsiB8, X];
  elP = cfEulerLagrange[cfSqrtg cfLunD8, cfPsiC8, X];
  e1 = Sum[cfGamUp[[mu]] . D[cfPsiC8, X[[mu]]], {mu, 8}] - H cfVs'[cfS8] cfPsiC8;                         (* connection MISSING *)
  e2 = Sum[D[cfPsiB8, X[[mu]]] . cfGamUp[[mu]], {mu, 8}] + cfPsiB8 . Sum[cfComm[cfGamUp[[mu]], GammaSpinCanonical[[mu]]], {mu, 8}] + H cfVs'[cfS8] cfPsiB8;
  cfAssert["LAGRANGIAN (f) [THE RESULT]: Lun_d varied with respect to Psibar gives (Sqrt[g]/H)(gamma^mu d_mu Psi - H V' Psi): the connection term is MISSING",
    cfZeroArrayQ[Expand[elB - (cfSqrtg/H) e1]]];
  cfAssert["LAGRANGIAN (f) [THE RESULT]: varied with respect to Psi it gives -(Sqrt[g]/H)((d_mu Psibar) gamma^mu + Psibar [gamma^mu, Gamma_mu] + H V' Psibar), with Psibar [gamma^mu, Gamma_mu] == 2 Psibar gamma^mu Gamma_mu: the connection term is PRESENT",
    {cfZeroArrayQ[Expand[elP + (cfSqrtg/H) e2]],
     cfZeroArrayQ[Sum[cfComm[cfGamUp[[mu]], GammaSpinCanonical[[mu]]], {mu, 8}] - 2 cfSumGG]}];
  (* the Dirac conjugate of e1 is -(conj e1)^T sigma16; with Psi = u + i v it must equal e2 for a consistent theory *)
  cvB = cfConjFlip[e1 /. cfUVRule8] . \[Sigma]16;  cvP = e2 /. cfUVRule8;
  cfAssert["LAGRANGIAN (f) [control]: so Lun_d is INADMISSIBLE -- its two field equations are not Dirac conjugates: they differ by 2 Psibar gamma^mu Gamma_mu = -6 H Cot^2 Psibar T16[0], non-zero (witness u = e1, v = 0, V = s^2)",
    {Expand[cfExpandV[Expand[(cvP + cvB) - 2 (cfPsiB8 . cfSumGG /. cfUVRule8)]]] === ConstantArray[0, 16],
     cfNonZeroWitnessQ[(2 cfPsiB8 . cfSumGG /. cfUVRule8) /. {cfReU[j_] :> Function[Evaluate[X], UnitVector[16, 1][[j + 1]]], cfImV[j_] :> Function[Evaluate[X], 0]}]}]];
Short[cfLsym8, 3]
]];

(* ---------- Input cell 181 ---------- *)
cfRunCell[181, Hold[
ClearAll[cfELbar8, cfELpsi8, cfE8, cfEbar8];
cfELbar8 = cfTimed["Euler-Lagrange expressions with respect to Psibar, generic fields of all eight coordinates", cfEulerLagrange[cfSqrtg cfLsym8, cfPsiB8, X]];
cfELpsi8 = cfTimed["Euler-Lagrange expressions with respect to Psi, generic fields of all eight coordinates", cfEulerLagrange[cfSqrtg cfLsym8, cfPsiC8, X]];
cfE8    = cfEquationFermion[cfPsiC8, cfPsiB8, cfGamUp, GammaSpinCanonical, cfVs];            (* gamma^mu D_mu Psi - H V' Psi *)
cfEbar8 = cfAdjointEquationFermion[cfPsiC8, cfPsiB8, cfGamUp, GammaSpinCanonical, cfVs];     (* (D_mu Psibar) gamma^mu + H V' Psibar *)
cfAssert["FIELD EQUATION [has content]: the identity the derivation uses -- (1/Sqrt[g]) d_mu(Sqrt[g] gamma^mu) == [gamma^mu, Gamma_mu] (covariant constancy, Section 17)",
  cfZeroArrayQ[cfDivG - Sum[cfComm[cfGamUp[[mu]], GammaSpinCanonical[[mu]]], {mu, 8}]]];
cfAssert["FIELD EQUATION [THE RESULT]: EL_Psibar == (Sqrt[g]/H)(gamma^mu D_mu Psi - H V'(s) Psi) for generic Psi, Psibar of all eight coordinates: the field equation is gamma^mu D_mu Psi == H V'(s) Psi",
  cfZeroArrayQ[Expand[cfELbar8 - (cfSqrtg/H) cfE8]]];
cfAssert["FIELD EQUATION [THE RESULT]: EL_Psi == -(Sqrt[g]/H)((D_mu Psibar) gamma^mu + H V'(s) Psibar): the adjoint equation is (D_mu Psibar) gamma^mu == -H V'(s) Psibar",
  cfZeroArrayQ[Expand[cfELpsi8 + (cfSqrtg/H) cfEbar8]]];
cfAssert["FIELD EQUATION [has content]: the adjoint equation IS the Dirac conjugate of the field equation: with Psi = u + i v, Psibar = (u - i v)^T sigma16, adjoint residual == -(field residual)^* . sigma16",
  Expand[cfExpandV[Expand[(cfEbar8 /. cfUVRule8) + cfConjFlip[cfE8 /. cfUVRule8] . \[Sigma]16]]] === ConstantArray[0, 16]];
cfAssert["FIELD EQUATION [control]: the opposite sign, (D Psibar) gamma == +H V' Psibar, is NOT the conjugate -- witnessed on u = e1 + e5, v = 0 with V = s^2 (s = -2 there)",
  cfNonZeroWitnessQ[((cfEbar8 - 2 H cfVs'[cfS8] cfPsiB8 /. cfUVRule8) + cfConjFlip[cfE8 /. cfUVRule8] . \[Sigma]16) /. cfVs -> (#^2 &) /.
     {cfReU[j_] :> Function[Evaluate[X], (UnitVector[16, 1] + UnitVector[16, 5])[[j + 1]]], cfImV[j_] :> Function[Evaluate[X], 0]}]];
Short[cfE8[[1]], 4]
]];

(* ---------- Input cell 182 ---------- *)
cfRunCell[182, Hold[
ClearAll[cfJ8, cfNoether8];
cfJ8 = Table[I cfPsiB8 . cfGamUp[[mu]] . cfPsiC8, {mu, 8}];
cfNoether8 = Table[Sum[D[cfSqrtg cfLsym8, D[cfPsiC8[[k]], X[[mu]]]] (I cfPsiC8[[k]]) + (-I cfPsiB8[[k]]) D[cfSqrtg cfLsym8, D[cfPsiB8[[k]], X[[mu]]]], {k, 16}], {mu, 8}];
cfAssert["CURRENT [THE RESULT]: the Noether current of the U(1) phase is (Sqrt[g]/H) i Psibar gamma^mu Psi",
  cfZeroArrayQ[Expand[cfNoether8 - (cfSqrtg/H) cfJ8]]];
cfAssert["CURRENT [has content]: i sigma16 gamma^mu is Hermitian for every mu, so j^mu is real",
  Table[cfZeroArrayQ[I \[Sigma]16 . cfGamUp[[mu]] - ConjugateTranspose[I \[Sigma]16 . cfGamUp[[mu]]] /. Conjugate[x_] :> x], {mu, 8}]];
cfAssert["CURRENT [THE RESULT]: OFF SHELL (1/Sqrt[g]) d_mu(Sqrt[g] j^mu) == i (Ebar Psi + Psibar E) for generic fields of all eight coordinates -- conserved on shell",
  cfZeroQ[Expand[(1/cfSqrtg) Sum[D[cfSqrtg cfJ8[[mu]], X[[mu]]], {mu, 8}] - I (cfEbar8 . cfPsiC8 + cfPsiB8 . cfE8)]]];
Short[cfJ8[[5]], 3]
]];

(* ---------- Input cell 183 ---------- *)
cfRunCell[183, Hold[
ClearAll[cfGGdir, cfGGalpha, cfGGbeta, cfOmegaNonZero];
cfOmegaNonZero = Select[Flatten[Table[{mu, a, b, omegaCanonical[[mu, a, b]]}, {mu, 8}, {a, 8}, {b, 8}], 2], #[[4]] =!= 0 &];
cfGGdir   = Table[cfSimpArray[cfGamUp[[mu]] . GammaSpinCanonical[[mu]]], {mu, 8}];           (* gamma^mu Gamma_mu, no sum *)
cfGGalpha = Table[cfSimp[Tr[T16[0] . cfGGdir[[mu]]]/16], {mu, 8}];                            (* T16[0]^2 = +1 *)
cfGGbeta  = Table[cfSimp[-Tr[T16[4] . cfGGdir[[mu]]]/16], {mu, 8}];                           (* T16[4]^2 = -1 *)
cfAssert["SPIN CONNECTION [has content]: metric compatible (omega_mu^{ab} antisymmetric) and every non-zero component is omega_mu^{mu 0} or omega_mu^{mu 4} (up to antisymmetry): omega_0 == omega_4 == 0",
  {cfZeroArrayQ[Table[omegaCanonical[[mu, a, b]] + omegaCanonical[[mu, b, a]], {mu, 8}, {a, 8}, {b, 8}]],
   AllTrue[cfOmegaNonZero, (MemberQ[{#[[2]], #[[3]]}, #[[1]]] && MemberQ[{1, 5}, If[#[[2]] == #[[1]], #[[3]], #[[2]]]]) &],
   GammaSpinCanonical[[1]] === ZERO16, GammaSpinCanonical[[5]] === ZERO16, Length[cfOmegaNonZero] === 24}];
cfAssert["SPIN CONNECTION [definition]: Gamma^spin_mu == Sum_{a<b} omega_mu,ab (1/2) T16[a] T16[b]",
  cfZeroArrayQ[Table[GammaSpinCanonical[[mu]] - Sum[omegaCanonical[[mu, a, b]] (1/2) T16[a - 1] . T16[b - 1], {a, 8}, {b, a + 1, 8}], {mu, 8}]]];
cfAssert["SPIN CONNECTION [THE RESULT]: direction by direction gamma^mu Gamma_mu == alpha_mu T16[0] + beta_mu T16[4]; Sum alpha_mu == -3 H Cot[6 H x0]^2 and Sum beta_mu == 0 (the observed and hidden a4 terms cancel)",
  {cfZeroArrayQ[Table[cfGGdir[[mu]] - cfGGalpha[[mu]] T16[0] - cfGGbeta[[mu]] T16[4], {mu, 8}]],
   cfZeroQ[Total[cfGGalpha] + 3 H Cot[6 H x0]^2], cfZeroQ[Total[cfGGbeta]],
   cfZeroQ[Total[cfGGbeta[[2 ;; 4]]] + Total[cfGGbeta[[6 ;; 8]]]], cfNonZeroWitnessQ[Total[cfGGbeta[[2 ;; 4]]]]}];
cfAssert["SPIN CONNECTION [has content]: Parts IV-V restated -- Bridge 1's difference is the pure gauge term, Bridge 2 is a constant conjugate, Bridge 3 has totally antisymmetric torsion that is not zero",
  {cfZeroArrayQ[deltaBoost - gaugeTermBoost], cfZeroArrayQ[Table[omegaNullMixed[[mu]] - cfU . omegaCanonicalMixed[[mu]] . cfU, {mu, 8}]],
   cfZeroArrayQ[Table[torsionOctFlat[[a, b, c]] + 2 \[Lambda]Oct mSkewSpin[[a, b, c]], {a, 8}, {b, 8}, {c, 8}]], cfNonZeroWitnessQ[torsionOct /. \[Lambda]Oct -> 1]}];
cfAssert["SPIN CONNECTION [has content]: Part V restated -- omega^W == 0 in the canonical frame, omega^LC == -contortion, T_mu == d_mu Log[Sin[6 H x0]], R == -T + B, and gamma^mu Gamma_mu == -(1/2) T_mu gamma^mu",
  {cfZeroArrayQ[omegaFable51Mixed], cfZeroArrayQ[omegaCanonicalFromTorsion - omegaCanonicalMixed],
   cfZeroArrayQ[torsionVectorFable51 - Table[D[Log[Sin[6 H x0]], X[[mu]]], {mu, 8}]],
   cfZeroQ[RicciScalarCanonical - (-torsionScalarFable51 + boundaryTermFable51)],
   cfZeroArrayQ[cfSumGG + (1/2) Sum[torsionVectorFable51[[mu]] cfGamUp[[mu]], {mu, 8}]]}];
Column[{cfShowConnection[omegaCanonical, "omega"],
  Grid[Prepend[Table[{Row[{"x", mu - 1}], cfGGalpha[[mu]], cfGGbeta[[mu]]}, {mu, 8}],
    {"direction", "gamma^mu Gamma_mu :  coefficient of T16[0]", "coefficient of T16[4]"}], Frame -> All, Alignment -> Left]}]
]];

(* ---------- Input cell 184 ---------- *)
cfRunCell[184, Hold[
ClearAll[cfFieldOp16, cfAdjOp16, cfTau8, cfTauBar8, cfPsi1, cfPsi2, cfUpper8, cfLower8, cfFieldEqTerms, cfAdjEqTerms, cfTermsOf,
         cfRescale8, cfPsiP8, cfPsiPB8, cfVp, cfBlocks8];
cfFieldOp16 = (Cot[6 H x0] T16[0] . D[cfPsiC8, x0] + (1/cfQminus) Sum[T16[i] . D[cfPsiC8, X[[i + 1]]], {i, 1, 3}] + T16[4] . D[cfPsiC8, x4]
   + (1/cfQplus) Sum[T16[h] . D[cfPsiC8, X[[h + 1]]], {h, 5, 7}] - 3 H Cot[6 H x0]^2 T16[0] . cfPsiC8 - H cfVs'[cfS8] cfPsiC8);
cfAdjOp16 = (Cot[6 H x0] D[cfPsiB8, x0] . T16[0] + (1/cfQminus) Sum[D[cfPsiB8, X[[i + 1]]] . T16[i], {i, 1, 3}] + D[cfPsiB8, x4] . T16[4]
   + (1/cfQplus) Sum[D[cfPsiB8, X[[h + 1]]] . T16[h], {h, 5, 7}] - 3 H Cot[6 H x0]^2 cfPsiB8 . T16[0] + H cfVs'[cfS8] cfPsiB8);
cfAssert["WRITTEN OUT (i) [THE RESULT]: the field equation on the canonical frame is Cot T16[0] d_0 Psi + (1/q) T16[i] d_i Psi + T16[4] d_4 Psi + (1/p) T16[h] d_h Psi - 3 H Cot^2 T16[0] Psi == H V'(s) Psi",
  {Expand[cfE8 - cfFieldOp16 - (cfSumGG + 3 H Cot[6 H x0]^2 T16[0]) . cfPsiC8] === ConstantArray[0, 16],
   cfZeroArrayQ[cfSumGG + 3 H Cot[6 H x0]^2 T16[0]],
   cfZeroArrayQ[Table[cfGamUp[[mu]] - {Cot[6 H x0], 1/cfQminus, 1/cfQminus, 1/cfQminus, 1, 1/cfQplus, 1/cfQplus, 1/cfQplus}[[mu]] T16[mu - 1], {mu, 8}]]}];
cfAssert["WRITTEN OUT (i) [THE RESULT]: the adjoint equation is Cot d_0 Psibar T16[0] + ... - 3 H Cot^2 Psibar T16[0] == -H V'(s) Psibar (the connection enters with the sign fixed by {gamma^mu, Gamma_mu} = 0)",
  {Expand[cfEbar8 - cfAdjOp16 + cfPsiB8 . (Sum[GammaSpinCanonical[[mu]] . cfGamUp[[mu]], {mu, 8}] - 3 H Cot[6 H x0]^2 T16[0])] === ConstantArray[0, 16],
   cfZeroArrayQ[Sum[GammaSpinCanonical[[mu]] . cfGamUp[[mu]], {mu, 8}] - 3 H Cot[6 H x0]^2 T16[0]]}];
cfPsi1 = cfPsiC8[[1 ;; 8]];  cfPsi2 = cfPsiC8[[9 ;; 16]];
cfUpper8 = (Cot[6 H x0] D[cfPsi2, x0] + (1/cfQminus) Sum[\[Tau]bar[i] . D[cfPsi2, X[[i + 1]]], {i, 1, 3}] + \[Tau]bar[4] . D[cfPsi2, x4]
   + (1/cfQplus) Sum[\[Tau]bar[h] . D[cfPsi2, X[[h + 1]]], {h, 5, 7}] - 3 H Cot[6 H x0]^2 cfPsi2 - H cfVs'[cfS8] cfPsi1);
cfLower8 = (Cot[6 H x0] D[cfPsi1, x0] + (1/cfQminus) Sum[\[Tau][i] . D[cfPsi1, X[[i + 1]]], {i, 1, 3}] + \[Tau][4] . D[cfPsi1, x4]
   + (1/cfQplus) Sum[\[Tau][h] . D[cfPsi1, X[[h + 1]]], {h, 5, 7}] - 3 H Cot[6 H x0]^2 cfPsi1 - H cfVs'[cfS8] cfPsi2);
cfAssert["WRITTEN OUT (ii) [THE RESULT]: the split-octonion 8+8 form -- the type-1 rows are the taubar equations for psi2, the type-2 rows the tau equations for psi1 (tau[0] == taubar[0] == ID8)",
  {\[Tau][0] === ID8, \[Tau]bar[0] === ID8,
   Expand[cfFieldOp16[[1 ;; 8]] - cfUpper8] === ConstantArray[0, 8], Expand[cfFieldOp16[[9 ;; 16]] - cfLower8] === ConstantArray[0, 8]}];
cfAssert["WRITTEN OUT (ii) [THE RESULT]: the covariant 8+8 form -- rows 1..8 are e_a^mu taubar[a] (d_mu + Gamma^(2)_mu) psi2 - H V' psi1, rows 9..16 are e_a^mu tau[a] (d_mu + Gamma^(1)_mu) psi1 - H V' psi2; and the conjugate rows",
  {Expand[cfE8[[1 ;; 8]] - (Sum[cfGamUp[[mu]][[1 ;; 8, 9 ;; 16]] . (D[cfPsi2, X[[mu]]] + GammaSpinType2[[mu]] . cfPsi2), {mu, 8}] - H cfVs'[cfS8] cfPsi1)] === ConstantArray[0, 8],
   Expand[cfE8[[9 ;; 16]] - (Sum[cfGamUp[[mu]][[9 ;; 16, 1 ;; 8]] . (D[cfPsi1, X[[mu]]] + GammaSpinType1[[mu]] . cfPsi1), {mu, 8}] - H cfVs'[cfS8] cfPsi2)] === ConstantArray[0, 8],
   Expand[cfEbar8[[1 ;; 8]] - (Sum[(D[cfPsiB8[[9 ;; 16]], X[[mu]]] - cfPsiB8[[9 ;; 16]] . GammaSpinType2[[mu]]) . cfGamUp[[mu]][[9 ;; 16, 1 ;; 8]], {mu, 8}] + H cfVs'[cfS8] cfPsiB8[[1 ;; 8]])] === ConstantArray[0, 8],
   Expand[cfEbar8[[9 ;; 16]] - (Sum[(D[cfPsiB8[[1 ;; 8]], X[[mu]]] - cfPsiB8[[1 ;; 8]] . GammaSpinType1[[mu]]) . cfGamUp[[mu]][[1 ;; 8, 9 ;; 16]], {mu, 8}] + H cfVs'[cfS8] cfPsiB8[[9 ;; 16]])] === ConstantArray[0, 8],
   cfZeroArrayQ[Table[{cfGamUp[[mu]][[1 ;; 8, 9 ;; 16]] - (1/frameCanonical[[mu, mu]]) \[Tau]bar[mu - 1], cfGamUp[[mu]][[9 ;; 16, 1 ;; 8]] - (1/frameCanonical[[mu, mu]]) \[Tau][mu - 1]}, {mu, 8}]]}];
cfAssert["WRITTEN OUT (ii) [has content]: with Psibar = Psi^ddag sigma16 and sigma16 = diag(-sigma, sigma): s == -psi1^ddag sigma psi1 + psi2^ddag sigma psi2 (psibar1 = -psi1^ddag sigma, psibar2 = psi2^ddag sigma)",
  Module[{pd = Array[cfPd, 16]}, {\[Sigma]16 === ArrayFlatten[{{-\[Sigma], 0}, {0, \[Sigma]}}],
     Expand[pd . \[Sigma]16 . cfPsiC8 - (-pd[[1 ;; 8]] . \[Sigma] . cfPsi1 + pd[[9 ;; 16]] . \[Sigma] . cfPsi2)] === 0}]];
(* (iii) the sixteen equations as lists of terms: {coefficient, component k, coordinate index mu (0..7)} and {coefficient, k} *)
cfTermsOf[expr_, head_] := Module[{e = Expand[expr /. {cfVs'[_] -> cfVp}], ders, flds},
  ders = Union[Cases[e, Derivative[d__][head[k_]][__] :> {k, First[Flatten[Position[{d}, 1]]] - 1}, Infinity]];
  flds = Union[Cases[e, head[k_][Sequence @@ X] :> k, Infinity]];
  {Table[{Coefficient[e, Derivative[Sequence @@ UnitVector[8, dk[[2]] + 1]][head[dk[[1]]]] @@ X], dk[[1]], dk[[2]]}, {dk, ders}],
   Table[{Coefficient[e /. Derivative[__][head[_]][__] -> 0, head[k] @@ X], k}, {k, flds}]}];
cfFieldEqTerms = Table[cfTermsOf[cfE8[[r]], cfPsiCA], {r, 16}];
cfAdjEqTerms   = Table[cfTermsOf[cfEbar8[[r]], cfPsiBA], {r, 16}];
cfAssert["WRITTEN OUT (iii) [definition]: the term lists reproduce all sixteen field equations and all sixteen adjoint equations exactly",
  {Expand[Table[Sum[t[[1]] Derivative[Sequence @@ UnitVector[8, t[[3]] + 1]][cfPsiCA[t[[2]]]] @@ X, {t, cfFieldEqTerms[[r, 1]]}]
        + Sum[t[[1]] cfPsiCA[t[[2]]] @@ X, {t, cfFieldEqTerms[[r, 2]]}], {r, 16}] - (cfE8 /. cfVs'[_] -> cfVp)] === ConstantArray[0, 16],
   Expand[Table[Sum[t[[1]] Derivative[Sequence @@ UnitVector[8, t[[3]] + 1]][cfPsiBA[t[[2]]]] @@ X, {t, cfAdjEqTerms[[r, 1]]}]
        + Sum[t[[1]] cfPsiBA[t[[2]]] @@ X, {t, cfAdjEqTerms[[r, 2]]}], {r, 16}] - (cfEbar8 /. cfVs'[_] -> cfVp)] === ConstantArray[0, 16]}];
cfAssert["WRITTEN OUT (iii) [has content]: every component equation has exactly one derivative per coordinate x0..x7, the connection term multiplies the component carrying the x0-derivative, and -H V' multiplies psi_r itself",
  Table[With[{d = cfFieldEqTerms[[r, 1]], f = cfFieldEqTerms[[r, 2]]},
     {Sort[d[[All, 3]]] === Range[0, 7],
      MemberQ[f, {c_, k_} /; k === First[Select[d, #[[3]] == 0 &]][[2]] && cfZeroQ[c - First[Select[d, #[[3]] == 0 &]][[1]] (-3 H Cot[6 H x0])]],
      MemberQ[f, {c_, k_} /; k === r - 1 && cfZeroQ[Coefficient[c, cfVp] + H]]}], {r, 16}]];
cfAssert["SYMMETRY [THE RESULT]: the only internal U(1) is the vector phase -- the commutant of all eight T16[a] in M16(C) is one-dimensional (multiples of ID16)",
  Length[NullSpace[Normal[CoefficientArrays[Flatten[Table[Array[cfXa, {16, 16}] . T16[a] - T16[a] . Array[cfXa, {16, 16}], {a, 0, 7}]], Flatten[Array[cfXa, {16, 16}]]][[2]]]]] === 1];
cfAssert["SYMMETRY [has content]: the axial phase exp(i alpha T16[8]) leaves s invariant but not the kinetic term: exp(-i alpha T8) T16[a] exp(i alpha T8) == T16[a] exp(2 i alpha T8), so Psibar gamma^mu d_mu Psi changes at first order by 2 i alpha Psibar gamma^mu T16[8] d_mu Psi, which is not zero (witness)",
  {Table[cfSimp60[MatrixExp[-I cfAlpha T16[8]] . T16[a] . MatrixExp[I cfAlpha T16[8]] - T16[a] . MatrixExp[2 I cfAlpha T16[8]]] === ConstantArray[0, {16, 16}], {a, 0, 7}],
   cfSimp60[MatrixExp[-I cfAlpha T16[8]] . MatrixExp[I cfAlpha T16[8]]] === ID16,
   cfNonZeroWitnessQ[(2 I cfPsiB8 . cfGamUp[[2]] . T16[8] . D[cfPsiC8, x1]) /. {cfPsiBA[k_] :> Function[Evaluate[X], UnitVector[16, 1][[k + 1]]],
      cfPsiCA[k_] :> Function[Evaluate[X], x1 (UnitVector[16, 9] + UnitVector[16, 10] + UnitVector[16, 11] + UnitVector[16, 12] + UnitVector[16, 13] + UnitVector[16, 14] + UnitVector[16, 15] + UnitVector[16, 16])[[k + 1]]]}]}];
cfBlocks8 = showCoupledEquations[Table[Union[Append[cfFieldEqTerms[[r, 1]][[All, 2]], r - 1]], {r, 16}]];
cfAssert["WRITTEN OUT (iii) [has content]: for fields of all eight coordinates the sixteen equations form ONE coupled block (the four blocks of four of Section 13 belong to the (x0, x4) reduction)",
  cfBlocks8 === {Range[0, 15]}];
(* (iv) the rescaled form *)
cfPsiP8  = Table[cfPsiPA[k] @@ X, {k, 0, 15}];
cfPsiPB8 = Table[cfPsiPBA[k] @@ X, {k, 0, 15}];
cfRescale8 = Join[Table[With[{kk = k}, cfPsiCA[kk] -> Function[Evaluate[X], Evaluate[Sqrt[Sin[6 H x0]] cfPsiPA[kk] @@ X]]], {k, 0, 15}],
   Table[With[{kk = k}, cfPsiBA[kk] -> Function[Evaluate[X], Evaluate[Sqrt[Sin[6 H x0]] cfPsiPBA[kk] @@ X]]], {k, 0, 15}]];
cfAssert["WRITTEN OUT (iv) [THE RESULT]: Psi = Sqrt[Sin[6Hx0]] Psi' turns the field equation into Sqrt[Sin] (Cot T16[0] d_0 Psi' + (1/q) T16[i] d_i Psi' + T16[4] d_4 Psi' + (1/p) T16[h] d_h Psi' - H V'(Sin s') Psi'): NO connection term",
  cfZeroArrayQ[Expand[(cfE8 /. cfRescale8) - Sqrt[Sin[6 H x0]] (Cot[6 H x0] T16[0] . D[cfPsiP8, x0] + (1/cfQminus) Sum[T16[i] . D[cfPsiP8, X[[i + 1]]], {i, 1, 3}]
      + T16[4] . D[cfPsiP8, x4] + (1/cfQplus) Sum[T16[h] . D[cfPsiP8, X[[h + 1]]], {h, 5, 7}] - H cfVs'[cfS8 /. cfRescale8] cfPsiP8)]]];
cfAssert["WRITTEN OUT (iv) [THE RESULT]: and the adjoint equation into Sqrt[Sin] (Cot d_0 Psi'bar T16[0] + ... + H V'(Sin s') Psi'bar), with no connection term either",
  cfZeroArrayQ[Expand[(cfEbar8 /. cfRescale8) - Sqrt[Sin[6 H x0]] (Cot[6 H x0] D[cfPsiPB8, x0] . T16[0] + (1/cfQminus) Sum[D[cfPsiPB8, X[[i + 1]]] . T16[i], {i, 1, 3}]
      + D[cfPsiPB8, x4] . T16[4] + (1/cfQplus) Sum[D[cfPsiPB8, X[[h + 1]]] . T16[h], {h, 5, 7}] + H cfVs'[cfS8 /. cfRescale8] cfPsiPB8)]]];
cfAssert["WRITTEN OUT (iv) [definition]: under the rescaling s == Sin[6 H x0] s',  s' = Psi'bar Psi'",
  Expand[(cfS8 /. cfRescale8) - Sin[6 H x0] cfPsiPB8 . cfPsiP8] === 0];
Column[Table[Row[{"eq ", r - 1, ":  ", Short[cfE8[[r]] /. {Derivative[d__][cfPsiCA[k_]][__] :> Subscript["d", First[Flatten[Position[{d}, 1]]] - 1][Subscript[\[Psi], k]],
     cfPsiCA[k_][__] :> Subscript[\[Psi], k], cfPsiBA[k_][__] :> Subscript[OverBar[\[Psi]], k]}, 3], " == 0"}], {r, 16}]]
]];

(* ---------- Input cell 185 ---------- *)
cfRunCell[185, Hold[
ClearAll[cfGK, cfJK, cfBeta, cfPiPsi, cfPiPsib, cfThetaSym, cfThetaUn, cfDPsi, cfDPsib];
cfJK   = -I T16[0] . T16[1] . T16[2] . T16[3] . T16[4];                   (* J *)
cfGK   = -I \[Sigma]16 . cfGamUp[[5]];                                     (* G = -i sigma16 gamma^4 *)
cfAssert["QUANTIZATION [definition]: lapse 1 and shift 0 (g_44 == -1, g_4mu == 0), and the slice x4 = const has signature (4,3) -- x0..x3 spacelike, x5..x7 timelike (given a4 real and 0 < 6 H x0 < Pi/2)",
  {gCanonical[[5, 5]] === -1, Table[gCanonical[[5, mu]], {mu, {1, 2, 3, 4, 6, 7, 8}}] === ConstantArray[0, 7],
   Module[{d = Delete[Diagonal[gCanonical], 5]}, {Count[cfSimp60[# > 0, cfSignatureAssume] & /@ d, True] === 4, Count[cfSimp60[# < 0, cfSignatureAssume] & /@ d, True] === 3}]}];
cfAssert["QUANTIZATION [THE RESULT]: the momenta of Lsym are Pi_Psi == (Sqrt[g]/(2H)) Psibar gamma^4 and Pi_Psibar == -(Sqrt[g]/(2H)) gamma^4 Psi",
  {Expand[Table[D[cfLC, D[cfPsiCGen[[k]], x4]], {k, 16}] - (cfSqrtg/(2 H)) cfPsiBGen . cfGamUp[[5]]] === ConstantArray[0, 16],
   Expand[Table[D[cfLC, D[cfPsiBGen[[k]], x4]], {k, 16}] + (cfSqrtg/(2 H)) cfGamUp[[5]] . cfPsiCGen] === ConstantArray[0, 16]}];
cfDPsi = Array[cfdPsi, 16]; cfDPsib = Array[cfdPsib, 16];                    (* variations delta Psi, delta Psibar *)
cfThetaSym = (cfSqrtg/(2 H)) (cfPsiBGen . cfGamUp[[5]] . cfDPsi - cfDPsib . cfGamUp[[5]] . cfPsiCGen);
cfThetaUn  = (cfSqrtg/H) cfPsiBGen . cfGamUp[[5]] . cfDPsi;
cfAssert["QUANTIZATION [has content]: theta_un - theta_sym == delta[(Sqrt[g]/(2H)) Psibar gamma^4 Psi] exactly: the same symplectic form, the same brackets",
  Expand[cfThetaUn - cfThetaSym - (cfSqrtg/(2 H)) (cfDPsib . cfGamUp[[5]] . cfPsiCGen + cfPsiBGen . cfGamUp[[5]] . cfDPsi)] === 0];
cfAssert["QUANTIZATION [THE RESULT]: G = -i sigma16 gamma^4 == J = -i T16[0].T16[1].T16[2].T16[3].T16[4] on the canonical frame; J is Hermitian, J^2 == ID16, eigenvalues +1 (8) and -1 (8): signature (8,8)",
  {cfGK === cfJK, cfJK === ConjugateTranspose[cfJK], cfJK . cfJK === ID16, Sort[Tally[Eigenvalues[cfJK]]] === {{-1, 8}, {1, 8}},
   cfZeroArrayQ[(cfSqrtg/H) \[Sigma]16 . cfGamUp[[5]] - I (cfSqrtg/H) cfGK]}];
cfAssert["QUANTIZATION [has content]: Gamma_4 == 0 -- the time-derivative part of the Lagrangian, which fixes the anticommutator, contains no spin connection",
  GammaSpinCanonical[[5]] === ZERO16];
{cfJK // MatrixForm}
]];

(* ---------- Input cell 186 ---------- *)
cfRunCell[186, Hold[
ClearAll[cfOmegaC, cfOmegaInv, cfKc, cfAntiPsiPsiDd, cfAntiPsiPsi];
cfKc = cfCK \[Sigma]16 . T16[4];                                            (* K = c sigma16 T16[4], c a free scalar *)
cfOmegaC = ArrayFlatten[{{0, cfKc}, {-cfKc, 0}}];
cfAssert["DIRAC BRACKET [THE RESULT]: in the Grassmann algebra Psi^ddag K phi == (i/2) Theta^T Omega_c Phi + (1/4) d(theta1^T K theta1 + theta2^T K theta2), for K = c sigma16 T16[4] with a free scalar c",
  grSame[grBil[cfGPsiC, cfKc, cfGPhi],
    grAdd[grScale[I/2, grBil[Join[cfTh1, cfTh2], cfOmegaC, Join[cfPh1, cfPh2]]],
      grScale[1/4, grD[grAdd[grBil[cfTh1, cfKc, cfTh1], grBil[cfTh2, cfKc, cfTh2]], cfDmapC]]]]];
cfOmegaInv = Inverse[cfOmegaC];
cfAssert["DIRAC BRACKET [has content]: Omega_c is real symmetric and invertible, Omega_c^-1 == [[0, -K^-1], [K^-1, 0]]",
  {cfSymQ[cfOmegaC] === "S", Det[cfOmegaC] =!= 0, Expand[cfOmegaInv - ArrayFlatten[{{0, -Inverse[cfKc]}, {Inverse[cfKc], 0}}]] === ConstantArray[0, {32, 32}]}];
cfAntiPsiPsiDd = (1/2) (cfOmegaInv[[1 ;; 16, 1 ;; 16]] + cfOmegaInv[[17 ;; 32, 17 ;; 32]] - I cfOmegaInv[[1 ;; 16, 17 ;; 32]] + I cfOmegaInv[[17 ;; 32, 1 ;; 16]]);
cfAntiPsiPsi   = (1/2) (cfOmegaInv[[1 ;; 16, 1 ;; 16]] - cfOmegaInv[[17 ;; 32, 17 ;; 32]] + I cfOmegaInv[[1 ;; 16, 17 ;; 32]] + I cfOmegaInv[[17 ;; 32, 1 ;; 16]]);
cfAssert["DIRAC BRACKET [THE RESULT]: {Theta_i, Theta_j} = (Omega^-1)_ij gives {Psi_a, Psi^ddag_b} == i (K^-1)_ab == (Gtilde^-1)_ab and {Psi_a, Psi_b} == 0",
  {Expand[cfAntiPsiPsiDd - I Inverse[cfKc]] === ConstantArray[0, {16, 16}], Expand[cfAntiPsiPsi] === ConstantArray[0, {16, 16}],
   Expand[cfAntiPsiPsiDd - Inverse[-I cfKc]] === ConstantArray[0, {16, 16}]}];
cfAssert["ANTICOMMUTATOR [THE RESULT]: on the canonical frame (c = Sqrt[g]/H) {Psi, Psi^ddag} == (H/Sqrt[g]) J == H Cos[6 H x0] J  (J^-1 == J), which IS the design's (H/Sqrt[g])(-i sigma16 gamma^4)",
  {cfZeroArrayQ[(cfAntiPsiPsiDd /. cfCK -> cfSqrtg/H) - H Cos[6 H x0] cfJK], Inverse[cfJK] === cfJK,
   cfZeroArrayQ[(H/cfSqrtg) (-I \[Sigma]16 . cfGamUp[[5]]) - H Cos[6 H x0] cfJK]}];
cfAssert["ANTICOMMUTATOR [has content]: the rescaled field Psi' = Psi/Sqrt[Sin[6 H x0]] has {Psi', Psi'^ddag} == H Cot[6 H x0] J delta^7, and Sqrt[g] is x4-independent (so quantizing chi = (Sqrt[g]/H)^(1/2) Psi changes nothing on the canonical frame)",
  {cfZeroQ[H Cos[6 H x0]/Sin[6 H x0] - H Cot[6 H x0]], D[cfSqrtg, x4] === 0}];
MatrixForm[cfAntiPsiPsiDd /. cfCK -> 1]
]];

(* ---------- Input cell 187 ---------- *)
cfRunCell[187, Hold[
ClearAll[cfBeta, cfIdemObs, cfIdemBasis, cfJTable, cfJCommQ, cfJAntiQ, cfLorentzJ];
cfBeta = -I T16[4];
cfIdemObs = (1/4) (ID16 + I T16[1] . T16[2]) . (ID16 + T16[3] . T16[4]);        (* a primitive idempotent of the observer's algebra *)
cfIdemBasis = Transpose[Orthogonalize[Transpose[Select[Transpose[cfIdemObs], # =!= ConstantArray[0, 16] &]]][[1 ;; 4]]];
cfAssert["J [THE RESULT]: J == -i Omega4 T16[0] == -i h_0 is a hidden flavour gamma: it lies in the commutant of T16[1..4] (in the span of the hidden-gamma products of Section 26)",
  {cfJK === -I cfOmega4 . T16[0], cfJK === -I cfHid[[1]], Table[cfJK . T16[i] === T16[i] . cfJK, {i, 1, 4}],
   MatrixRank[Join[Flatten /@ cfHidAlg, {Flatten[cfJK]}]] === 16}];
cfAssert["J [has content]: on the flavour factor J has signature (2,2): cfIdemObs is a rank-4 projector commuting with J, and J restricted to its image has eigenvalues +1, +1, -1, -1",
  Module[{v = Orthogonalize[NullSpace[cfIdemObs - ID16]]},
    {cfIdemObs . cfIdemObs === cfIdemObs, MatrixRank[cfIdemObs] === 4, cfIdemObs . cfJK === cfJK . cfIdemObs,
     Sort[Eigenvalues[Conjugate[v] . cfJK . Transpose[v]]] === {-1, -1, 1, 1}, Tr[cfJK] === 0}]];
cfAssert["J [THE RESULT]: sigma16 == J beta with beta = -i T16[4] Hermitian, beta^2 == 1; T16[0..3] Hermitian with beta T16[j] beta == -T16[j]: beta is the observer's Dirac adjoint",
  {\[Sigma]16 === cfJK . cfBeta, cfBeta === ConjugateTranspose[cfBeta], cfBeta . cfBeta === ID16,
   Table[{T16[j] === ConjugateTranspose[T16[j]], cfBeta . T16[j] . cfBeta === -T16[j]}, {j, 0, 3}],
   Table[T16[h] === -ConjugateTranspose[T16[h]], {h, 4, 7}]}];
cfAssert["J [THE RESULT]: with Psi^dagger := Psi^ddag J:  Psibar = Psi^dagger beta (J sigma16 == beta),  Psi^ddag G = Psi^dagger (J G == ID16),  {Psi, Psi^dagger} == (H/Sqrt[g]) ID16 (G^-1 J == ID16): POSITIVE",
  {cfJK . \[Sigma]16 === cfBeta, cfJK . cfGK === ID16, Inverse[cfGK] . cfJK === ID16}];
cfJCommQ[m_] := cfZeroArrayQ[cfJK . m - m . cfJK];
cfJAntiQ[m_] := cfZeroArrayQ[cfJK . m + m . cfJK];
cfJTable = Join[
   {{"sigma16", cfJCommQ[\[Sigma]16], cfJAntiQ[\[Sigma]16]}, {"T16[8]", cfJCommQ[T16[8]], cfJAntiQ[T16[8]]}, {"C+ = sigma16 T16[8]  (p)", cfJCommQ[cfCplus], cfJAntiQ[cfCplus]}},
   Table[{Row[{"T16[", a, "]"}], cfJCommQ[T16[a]], cfJAntiQ[T16[a]]}, {a, 0, 7}],
   Table[{Row[{"sigma16 gamma^", mu - 1}], cfJCommQ[\[Sigma]16 . cfGamUp[[mu]]], cfJAntiQ[\[Sigma]16 . cfGamUp[[mu]]]}, {mu, 8}],
   Table[{Row[{"gamma^", mu - 1, " Gamma_", mu - 1}], cfJCommQ[cfGGdir[[mu]]], cfJAntiQ[cfGGdir[[mu]]]}, {mu, 8}],
   Table[{Row[{"Gamma_", mu - 1}], cfJCommQ[GammaSpinCanonical[[mu]]], cfJAntiQ[GammaSpinCanonical[[mu]]]}, {mu, 8}]];
cfAssert["J TABLE [THE RESULT]: J commutes with sigma16, T16[0..4], sigma16 gamma^mu (mu = 0..4), every gamma^mu Gamma_mu and Gamma_1..Gamma_3; it ANTIcommutes with T16[5..7], sigma16 gamma^h (h = 5..7), Gamma_5..Gamma_7, T16[8] and C+",
  {cfJTable[[1, 2 ;; 3]] === {True, False}, cfJTable[[2, 2 ;; 3]] === {False, True}, cfJTable[[3, 2 ;; 3]] === {False, True},
   cfJTable[[4 ;; 11, 2 ;; 3]] === Join[ConstantArray[{True, False}, 5], ConstantArray[{False, True}, 3]],
   cfJTable[[12 ;; 19, 2 ;; 3]] === Join[ConstantArray[{True, False}, 5], ConstantArray[{False, True}, 3]],
   cfJTable[[20 ;; 27, 2]] === ConstantArray[True, 8],
   cfJTable[[{29, 30, 31}, 2 ;; 3]] === ConstantArray[{True, False}, 3], cfJTable[[{33, 34, 35}, 2 ;; 3]] === ConstantArray[{False, True}, 3],
   GammaSpinCanonical[[1]] === ZERO16, GammaSpinCanonical[[5]] === ZERO16}];
cfAssert["J [has content]: the Hermiticity rule -- for classically Hermitian M, (J M)^dagger == J M iff [J, M] == 0 and == -J M iff {J, M} == 0: so s = Psi^ddag sigma16 Psi is Hermitian and p = Psi^ddag C+ Psi is ANTI-Hermitian",
  {ConjugateTranspose[cfJK . \[Sigma]16] === cfJK . \[Sigma]16, ConjugateTranspose[cfJK . cfCplus] === -cfJK . cfCplus,
   \[Sigma]16 === ConjugateTranspose[\[Sigma]16], cfCplus === ConjugateTranspose[cfCplus]}];
cfLorentzJ = Flatten[Table[{a - 1, b - 1, SAB[[a, b]] . cfJK === cfJK . SAB[[a, b]], SAB[[a, b]] . cfJK === -cfJK . SAB[[a, b]],
     Transpose[SAB[[a, b]]] . cfGK + cfGK . SAB[[a, b]] === ZERO16}, {a, 1, 7}, {b, a + 1, 8}], 1];
cfAssert["J [THE RESULT]: 13 of the 28 Lorentz generators commute with J (a, b both in {0..4}: Spin(4,1), or both in {5,6,7}: Spin(3)); the other 15 anticommute -- 12 boosts x0..x3 <-> x5..x7 and 3 rotations x4 <-> x5..x7",
  {Count[cfLorentzJ, {_, _, True, False, _}] === 13, Count[cfLorentzJ, {_, _, False, True, _}] === 15,
   AllTrue[cfLorentzJ, (#[[3]] === ((#[[1]] <= 4 && #[[2]] <= 4) || (#[[1]] >= 5 && #[[2]] >= 5))) &]}];
cfAssert["J [has content]: the Krein form G is invariant (S^T G + G S == 0) under exactly the 21 generators with a, b != 4 -- Spin(4,3), the group of the slice",
  {Count[cfLorentzJ, {_, _, _, _, True}] === 21, AllTrue[cfLorentzJ, (#[[5]] === (#[[1]] != 4 && #[[2]] != 4)) &]}];
cfAssert["J [has content]: chirality -- {J, T16[8]} == 0, each chirality subspace is G-NULL (PL G PL == PR G PR == 0), and the two chiralities are orthogonal in the Hilbert product (PL, PR Hermitian, PL PR == 0)",
  {cfJK . T16[8] === -T16[8] . cfJK, PL . cfGK . PL === ZERO16, PR . cfGK . PR === ZERO16,
   PL === ConjugateTranspose[PL], PR === ConjugateTranspose[PR], PL . PR === ZERO16}];
Grid[Prepend[cfJTable, {"matrix", "commutes with J", "anticommutes with J"}], Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 188 ---------- *)
cfRunCell[188, Hold[
ClearAll[cfKv, cfHk, cfEk, cfKsq, cfKhq, cfEkNum, cfBoostS, cfJp, cfCommutantOf, cfJointComm, cfJointCommAdm];
cfKv = {cfk0, cfk1, cfk2, cfk3, 0, cfk5, cfk6, cfk7};                           (* k_a, a = 0..7, no component along x4 *)
cfHk[kv_, m_] := \[Sigma]16 . (m ID16 - I Sum[kv[[a]] T16[a - 1], {a, 8}]);
cfEk[kv_, m_] := cfGK . cfHk[kv, m];
cfAssert["ADMISSIBILITY (1) [THE RESULT]: E_k^2 == (k_s^2 - k_h^2 + m^2) ID16 for every k: omega^2 = k_s^2 - k_h^2 + m^2",
  Expand[cfEk[cfKv, cfMs] . cfEk[cfKv, cfMs] - (cfk0^2 + cfk1^2 + cfk2^2 + cfk3^2 - cfk5^2 - cfk6^2 - cfk7^2 + cfMs^2) ID16] === ConstantArray[0, {16, 16}]];
cfAssert["ADMISSIBILITY (2) [THE RESULT]: for admissible k (k_h = 0), [J, E_k] == 0, E_k is J-Hermitian, and G J == ID16 is positive: J quantizes every admissible momentum positively",
  With[{e = cfEk[{cfk0, cfk1, cfk2, cfk3, 0, 0, 0, 0}, cfMs]},
    {Expand[cfJK . e - e . cfJK] === ConstantArray[0, {16, 16}], Expand[ComplexExpand[ConjugateTranspose[e]] - e] === ConstantArray[0, {16, 16}], cfGK . cfJK === ID16}]];
(* (3) below threshold: k = 5 e1 + 3 e5, m = 3: omega^2 = 25 - 9 + 9 = 25; boost with tanh(theta) = 3/5 *)
cfEkNum = cfEk[{0, 5, 0, 0, 0, 3, 0, 0}, 3];
cfBoostS = (3/(2 Sqrt[2])) ID16 + (1/(2 Sqrt[2])) T16[1] . T16[5];            (* cosh(theta/2) + sinh(theta/2) T1 T5 *)
cfJp = Inverse[cfBoostS] . cfJK . cfBoostS;
cfAssert["ADMISSIBILITY (3) [THE RESULT]: below threshold (k = 5 e1 + 3 e5, m = 3) the boosted J' = S^-1 J S commutes with E_k and beta, J'^2 == 1, and G J' == S^2 is Hermitian positive definite",
  {cfSimp60[cfJp . cfEkNum - cfEkNum . cfJp] === ConstantArray[0, {16, 16}], cfSimp60[cfJp . cfBeta - cfBeta . cfJp] === ConstantArray[0, {16, 16}],
   cfSimp60[cfJp . cfJp] === ID16, cfSimp60[cfGK . cfJp - cfBoostS . cfBoostS] === ConstantArray[0, {16, 16}],
   cfBoostS === ConjugateTranspose[cfBoostS], Min[Eigenvalues[cfBoostS . cfBoostS]] > 0,
   Expand[cfEkNum . cfEkNum] === 25 ID16, ! (Expand[cfJK . cfEkNum - cfEkNum . cfJK] === ConstantArray[0, {16, 16}])}];
cfAssert["ADMISSIBILITY (4) [THE RESULT]: AT threshold (k = 4 e1 + 5 e5, m = 3) E_k != 0 but E_k^2 == 0: nilpotent, not diagonalizable (rank 8: Jordan blocks of size 2)",
  With[{e = cfEk[{0, 4, 0, 0, 0, 5, 0, 0}, 3]}, {e =!= ConstantArray[0, {16, 16}], Expand[e . e] === ConstantArray[0, {16, 16}], MatrixRank[e] === 8}]];
cfAssert["ADMISSIBILITY (5) [THE RESULT]: ABOVE threshold (k = (0, 3/4, 1, 0 | k5 = 2), m = 1) omega^2 == -23/16: every eigenvalue of E_k is +-i Sqrt[23]/4 = +-1.19896 i and every eigenvector is G-NEUTRAL (u^dagger G u == 0)",
  With[{e = cfEk[{0, 3/4, 1, 0, 0, 2, 0, 0}, 1]},
    {Expand[e . e] === -(23/16) ID16, Abs[N[Sqrt[23]/4, 20] - 1.19896] < 10^-5,
     Union[Flatten[Table[With[{v = NullSpace[e - s I (Sqrt[23]/4) ID16]}, {Length[v] === 8, cfSimp60[Conjugate[v] . cfGK . Transpose[v]] === ConstantArray[0, {8, 8}]}], {s, {-1, 1}}]]] === {True}}]];
cfAssert["ADMISSIBILITY [has content]: the general identity [E_k, beta] == 2 i T_k, T_k = Sum_a k_a T16[a], for every k (admissible and hidden components alike)",
  Expand[cfEk[cfKv, cfMs] . cfBeta - cfBeta . cfEk[cfKv, cfMs] - 2 I Sum[cfKv[[a]] T16[a - 1], {a, 8}]] === ConstantArray[0, {16, 16}]];
cfCommutantOf[mats_List] := Map[Partition[#, 16] &, NullSpace[Normal[CoefficientArrays[
     Flatten[Table[Array[cfXc, {16, 16}] . mm - mm . Array[cfXc, {16, 16}], {mm, mats}]], Flatten[Array[cfXc, {16, 16}]]][[2]]]]];
cfJointComm = cfCommutantOf[Join[{cfBeta}, Table[cfEk[UnitVector[8, a], 1], {a, 1, 4}], {cfEk[{0, 1, 0, 0, 0, 1/2, 0, 0}, 1]}]];
cfAssert["ADMISSIBILITY (6) [THE RESULT]: traceless certificate -- every X commuting with beta, the four admissible E_k and one hidden-momentum E_k has Tr(G X) == 0, so no positive G J' exists; J itself is not in that commutant",
  {Length[cfJointComm] >= 1, Union[Table[cfSimp60[Tr[cfGK . x]], {x, cfJointComm}]] === {0},
   MatrixRank[Join[Flatten /@ cfJointComm, {Flatten[cfJK]}]] === Length[cfJointComm] + 1}];
cfAssert["ADMISSIBILITY (6) [THE RESULT]: the analytic proof for a purely hidden momentum -- [E_k, beta] == 2 i k5 T16[5]; T16[5] anticommutes with G and T16[5]^dagger G T16[5] == -G (so a J' commuting with T16[5] has T5^dagger (G J') T5 == -(G J'))",
  {Expand[cfEk[{0, 0, 0, 0, 0, cfk5, 0, 0}, cfMs] . cfBeta - cfBeta . cfEk[{0, 0, 0, 0, 0, cfk5, 0, 0}, cfMs] - 2 I cfk5 T16[5]] === ConstantArray[0, {16, 16}],
   T16[5] . cfGK === -cfGK . T16[5], ConjugateTranspose[T16[5]] . cfGK . T16[5] === -cfGK}];
cfJointCommAdm = cfCommutantOf[Join[{cfBeta}, Table[cfEk[UnitVector[8, a], 1], {a, 1, 4}]]];
cfAssert["ADMISSIBILITY (7) [THE RESULT]: J is UNIQUE -- the joint commutant of beta and the admissible E_k is 8-dimensional, contains J, and every element of it commutes with J (so X^2 == 1 with J X > 0 forces X == J)",
  {Length[cfJointCommAdm] === 8, MatrixRank[Join[Flatten /@ cfJointCommAdm, {Flatten[cfJK]}]] === 8,
   Table[x . cfJK === cfJK . x, {x, cfJointCommAdm}]}];
cfAssert["ADMISSIBILITY [has content]: [P_4, P_h] == 0 -- the metric, the frame and the spin connection do not depend on x5, x6, x7",
  {Table[D[{gCanonical, frameCanonical, GammaSpinCanonical}, X[[h]]] === {ConstantArray[0, {8, 8}], ConstantArray[0, {8, 8}], ConstantArray[0, {8, 16, 16}]}, {h, 6, 8}]}];
{Length[cfJointComm], " = dim of the joint commutant with a hidden momentum;  ", Length[cfJointCommAdm], " without"}
]];

(* ---------- Input cell 189 ---------- *)
cfRunCell[189, Hold[
ClearAll[cfPsiAd, cfHop, cfHopHid, cfAflux, cfBagP, cfBagM, cfFf, cfGg, cfFb];
cfPsiAd = Table[cfPsiAdm[k][x0, x1, x2, x3, x4], {k, 0, 15}];              (* an admissible Psi(x0, ..., x4) *)
cfHop[psi_] := cfSqrtg \[Sigma]16 . (cfVpMF psi - (1/H) (Sum[cfGamUp[[j]] . D[psi, X[[j]]], {j, 1, 4}] + cfSumGG . psi));   (* V'(<s>) = cfVpMF, mean field *)
cfHopHid[psi_] := cfHop[psi] - (cfSqrtg/H) \[Sigma]16 . cfGamUp[[6]] . D[psi, x5];
cfAssert["HAMILTONIAN [THE RESULT]: the Hamiltonian density Pi_Psi d_4 Psi + d_4 Psibar Pi_Psibar - L of the symmetrized Lagrangian is Sqrt[g][-(1/(2H)) Sum_{k != 4}(Psibar gamma^k d_k Psi - d_k Psibar gamma^k Psi) + V]: NO spin connection (fields of all eight coordinates)",
  Module[{l = cfSqrtg cfLsym8},
    Expand[Sum[D[l, D[cfPsiC8[[k]], x4]] D[cfPsiC8[[k]], x4] + D[cfPsiB8[[k]], x4] D[l, D[cfPsiB8[[k]], x4]], {k, 16}] - l
      - cfSqrtg (-(1/(2 H)) Sum[cfPsiB8 . cfGamUp[[mu]] . D[cfPsiC8, X[[mu]]] - D[cfPsiB8, X[[mu]]] . cfGamUp[[mu]] . cfPsiC8, {mu, {1, 2, 3, 4, 6, 7, 8}}] + cfVs[cfS8])] === 0]];
cfAssert["HAMILTONIAN [THE RESULT]: (Sqrt[g]/H) sigma16 (gamma^mu D_mu Psi - H V' Psi) == i Gtilde d_4 Psi - h Psi for admissible Psi(x0..x4): the field equation is i Gtilde d_4 Psi = h Psi",
  Expand[(cfSqrtg/H) \[Sigma]16 . (cfEquationFermion[cfPsiAd, ConstantArray[0, 16], cfGamUp, GammaSpinCanonical, cfVs] /. cfVs'[_] -> cfVpMF)
     - (I (cfSqrtg/H) cfGK . D[cfPsiAd, x4] - cfHop[cfPsiAd])] === ConstantArray[0, 16]];
cfAssert["HAMILTONIAN [THE RESULT]: (1/2) Sum_{mu != 4} d_mu(Sqrt[g] sigma16 gamma^mu) == Sqrt[g] sigma16 Sum gamma^mu Gamma_mu, and d_4(Sqrt[g] sigma16 gamma^4) == 0: the connection term is the one that makes h Hermitian",
  {cfZeroArrayQ[(1/2) Sum[D[cfSqrtg \[Sigma]16 . cfGamUp[[mu]], X[[mu]]], {mu, {1, 2, 3, 4, 6, 7, 8}}] - cfSqrtg \[Sigma]16 . cfSumGG],
   D[cfSqrtg \[Sigma]16 . cfGamUp[[5]], x4] === ConstantArray[0, {16, 16}]}];
cfAflux = cfSqrtg \[Sigma]16 . cfGamUp[[1]];                                (* A_0 = Sqrt[g] sigma16 gamma^0, x0-dependent *)
cfFf = Table[cfFfun[k][x0], {k, 16}];  cfFb = Table[cfFbar[k][x0], {k, 16}];  cfGg = Table[cfGfun[k][x0], {k, 16}];
cfAssert["HAMILTONIAN [has content]: A_0 = Sqrt[g] sigma16 gamma^0 is real antisymmetric, and for h_0 = -(A_0 d_0 + (1/2) A_0'):  <f, h_0 g> - <h_0 f, g> == -d_0(f^dagger A_0 g), a pure boundary term",
  {cfZeroArrayQ[cfAflux + Transpose[cfAflux]],
   Expand[(-cfFb . (cfAflux . D[cfGg, x0] + (1/2) D[cfAflux, x0] . cfGg)) - (-(D[cfFb, x0] . Transpose[cfAflux] . cfGg + (1/2) cfFb . Transpose[D[cfAflux, x0]] . cfGg))
      + D[cfFb . cfAflux . cfGg, x0]] === 0}];
cfAssert["BOUNDARY [has content]: the x0 direction in proper distance z = -Log[Cos[6 H x0]]/(6 H): dz/dx0 == Tan[6Hx0] == Sec Sin (so Sqrt[g] dx0 |Psi|^2 = |Psi'|^2 dz), z(0) == 0 and z -> infinity at 6 H x0 -> Pi/2, gamma^0 d_0 == T16[0] d_z, and Sin[6Hx0] == Sqrt[1 - Exp[-12 H z]] (bounded frame factors)",
  {cfZeroQ[D[-Log[Cos[6 H x0]]/(6 H), x0] - Tan[6 H x0]], cfZeroQ[Sec[6 H x0] Sin[6 H x0] - Tan[6 H x0]], (-Log[Cos[6 H x0]]/(6 H) /. x0 -> 0) === 0,
   Limit[-Log[Cos[u]]/(6 H), u -> Pi/2, Direction -> "FromBelow", Assumptions -> H > 0] === Infinity,
   cfZeroQ[Cot[6 H x0] Tan[6 H x0] - 1], cfZeroQ[Sqrt[1 - Exp[-12 H (-Log[Cos[6 H x0]]/(6 H))]] - Sin[6 H x0]]}];
cfBagP = (1/2) (ID16 + T16[0]);  cfBagM = (1/2) (ID16 - T16[0]);
cfAssert["BOUNDARY [THE RESULT]: the bag condition T16[0] Psi' = +-Psi' at the wall -- T16[0]^2 == 1, {beta, T16[0]} == 0, the normal-flux form vanishes on both eigenspaces (P beta T16[0] P == 0), and [J, T16[0]] == 0",
  {T16[0] . T16[0] === ID16, cfBeta . T16[0] + T16[0] . cfBeta === ZERO16,
   cfBagP . cfBeta . T16[0] . cfBagP === ZERO16, cfBagM . cfBeta . T16[0] . cfBagM === ZERO16,
   cfJK . T16[0] === T16[0] . cfJK, cfBagP . cfJK === cfJK . cfBagP}];
cfAssert["HAMILTONIAN [THE RESULT]: [J, h] == 0 on the admissible sector, for every a4, every x0-profile and every V' -- including the spin-connection term",
  Expand[cfJK . cfHop[cfPsiAd] - cfHop[cfJK . cfPsiAd]] === ConstantArray[0, 16]];
cfAssert["HAMILTONIAN [control]: a hidden derivative term breaks it -- [J, h] != 0 once Psi depends on x5 (witnessed on Psi = x5 e1)",
  cfNonZeroWitnessQ[(cfJK . cfHopHid[#] - cfHopHid[cfJK . #]) &[x5 UnitVector[16, 1]] /. cfVpMF -> 1]];
cfAssert["HAMILTONIAN [has content]: the x4-dependence of h enters only through 1/q: d_4 h Psi == (H a4'[H x4]) x (the observed-direction part of h), which commutes with J",
  Expand[D[cfHop[cfPsiAd], x4] - cfHop[D[cfPsiAd, x4]] + H a4'[H x4] (cfSqrtg/H) \[Sigma]16 . Sum[cfGamUp[[j]] . D[cfPsiAd, X[[j]]], {j, 2, 4}]
     + (cfSqrtg/H) \[Sigma]16 . D[cfSumGG, x4] . cfPsiAd] === ConstantArray[0, 16] && cfZeroArrayQ[D[cfSumGG, x4]]];
Short[cfHop[cfPsiAd][[1]], 3]
]];

(* ---------- Input cell 190 ---------- *)
cfRunCell[190, Hold[
ClearAll[cfW, cfKadm, cfAk, cfHkAdm, cfProj, cfModW];
cfKadm = {cfk0, cfk1, cfk2, cfk3, 0, 0, 0, 0};
cfHkAdm = cfHk[cfKadm, cfMs];
cfAk = cfGK . cfHkAdm;
cfProj[s_, eta_] := (1/4) (ID16 + s cfAk/cfW) . (ID16 + eta cfJK);
cfModW[e_] := With[{f = (PolynomialRemainder[Numerator[Together[#]], cfW^2 - (cfk0^2 + cfk1^2 + cfk2^2 + cfk3^2 + cfMs^2), cfW] &)}, Expand[If[ListQ[e], Map[f, e, {ArrayDepth[e]}], f[e]]]];
cfAssert["KREIN MODES [has content]: A = G h satisfies A^2 == w^2 ID16 and [A, J] == 0, and A is Hermitian (G and h commute) for every admissible k and m",
  {Expand[cfAk . cfAk - (cfk0^2 + cfk1^2 + cfk2^2 + cfk3^2 + cfMs^2) ID16] === ConstantArray[0, {16, 16}],
   Expand[cfAk . cfJK - cfJK . cfAk] === ConstantArray[0, {16, 16}], Expand[ComplexExpand[ConjugateTranspose[cfAk]] - cfAk] === ConstantArray[0, {16, 16}]}];
cfAssert["KREIN MODES [THE RESULT]: the four P_{s,eta} are projectors of trace (rank) 4, mutually orthogonal, summing to ID16, and Sum eta P_{s,eta} == J == G^-1 (completeness)",
  {Table[cfModW[cfProj[s, e] . cfProj[s, e] - cfProj[s, e]] === ConstantArray[0, {16, 16}], {s, {1, -1}}, {e, {1, -1}}],
   Table[cfModW[Tr[cfProj[s, e]] - 4] === 0, {s, {1, -1}}, {e, {1, -1}}],
   cfModW[cfProj[1, 1] . cfProj[-1, 1]] === ConstantArray[0, {16, 16}], cfModW[cfProj[1, 1] . cfProj[1, -1]] === ConstantArray[0, {16, 16}],
   Expand[Sum[cfProj[s, e], {s, {1, -1}}, {e, {1, -1}}]] === ID16, Expand[Sum[e cfProj[s, e], {s, {1, -1}}, {e, {1, -1}}] - Inverse[cfGK]] === ConstantArray[0, {16, 16}]}];
cfAssert["KREIN MODES [THE RESULT]: for every mode, eta u^dagger h u == s w (energy = frequency), eta u^dagger sigma16 u == m/omega_u, eta u^dagger (dh/dk_j) u == k_j/omega_u: P X P == c P with c = eta s w, eta s m/w, eta s k_j/w",
  Table[{cfModW[cfProj[s, e] . cfHkAdm . cfProj[s, e] - e s cfW cfProj[s, e]] === ConstantArray[0, {16, 16}],
     cfModW[cfProj[s, e] . \[Sigma]16 . cfProj[s, e] - e s (cfMs/cfW) cfProj[s, e]] === ConstantArray[0, {16, 16}],
     Table[cfModW[cfProj[s, e] . (-I \[Sigma]16 . T16[j]) . cfProj[s, e] - e s (cfKadm[[j + 1]]/cfW) cfProj[s, e]] === ConstantArray[0, {16, 16}], {j, 0, 3}],
     cfModW[cfProj[s, e] . cfGK . cfProj[s, e] - e cfProj[s, e]] === ConstantArray[0, {16, 16}]}, {s, {1, -1}}, {e, {1, -1}}]];
cfAssert["KREIN MODES [has content]: dh/dk_j == -i sigma16 T16[j], and d omega/d k_j == k_j/omega for omega = +-w",
  {Table[D[cfHkAdm, cfKadm[[j + 1]]] === -I \[Sigma]16 . T16[j], {j, 0, 3}],
   Table[cfSimp60[D[s Sqrt[cfk0^2 + cfk1^2 + cfk2^2 + cfk3^2 + cfMs^2], cfKadm[[j + 1]]] - cfKadm[[j + 1]]/(s Sqrt[cfk0^2 + cfk1^2 + cfk2^2 + cfk3^2 + cfMs^2])], {s, {1, -1}}, {j, 0, 3}] === ConstantArray[0, {2, 4}]}];
cfAssert["KREIN MODES [THE RESULT]: every mode of P_{s,eta} is a J-eigenvector: J P_{s,eta} == eta P_{s,eta}",
  Table[Expand[cfJK . cfProj[s, e] - e cfProj[s, e]] === ConstantArray[0, {16, 16}], {s, {1, -1}}, {e, {1, -1}}]];
Module[{pp, pm, up, um, u1, u2, a3, jU, unitNormalize},
  unitNormalize[v_] := v/Sqrt[Conjugate[v] . v];
  a3 = cfGK . cfHk[{0, 3, 0, 0, 0, 0, 0, 0}, 4];
  pp = (1/4) (ID16 + a3/5) . (ID16 + cfJK);  pm = (1/4) (ID16 + a3/5) . (ID16 - cfJK);
  up = unitNormalize[First[Select[Transpose[pp], # =!= ConstantArray[0, 16] &]]];
  um = unitNormalize[First[Select[Transpose[pm], # =!= ConstantArray[0, 16] &]]];
  u1 = (5/4) up + (3/4) um;  u2 = (3/4) up + (5/4) um;
  jU = cfGK . (ID16 - Outer[Times, up, Conjugate[up]] - Outer[Times, um, Conjugate[um]] + Outer[Times, u1, Conjugate[u1]] + Outer[Times, u2, Conjugate[u2]]);
  cfAssert["KREIN MODES [control]: a Krein-boosted pair u1 = (5/4)u+ + (3/4)u-, u2 = (3/4)u+ + (5/4)u- in the omega = +5 eigenspace is still G-orthonormal and still consists of modes, but not of J-eigenvectors; the induced J_U = G U U^dagger differs from J, and under it s is NOT Hermitian",
    {cfSimp60[{cfJK . up - up, cfJK . um + um, a3 . up - 5 up, a3 . um - 5 um}] === ConstantArray[0, {4, 16}],
     cfSimp60[{Conjugate[up] . up, Conjugate[um] . um, Conjugate[up] . um}] === {1, 1, 0},
     cfSimp60[{a3 . u1 - 5 u1, a3 . u2 - 5 u2}] === ConstantArray[0, {2, 16}],
     cfSimp60[{Conjugate[u1] . cfGK . u1, Conjugate[u2] . cfGK . u2, Conjugate[u1] . cfGK . u2}] === {1, -1, 0},
     cfSimp60[cfJK . u1 - u1] =!= ConstantArray[0, 16], cfSimp60[jU - cfJK] =!= ConstantArray[0, {16, 16}],
     cfSimp60[ConjugateTranspose[Inverse[jU] . \[Sigma]16] - Inverse[jU] . \[Sigma]16] =!= ConstantArray[0, {16, 16}],
     cfSimp60[ConjugateTranspose[Inverse[cfJK] . \[Sigma]16] - Inverse[cfJK] . \[Sigma]16] === ConstantArray[0, {16, 16}]}]];
{"rank of each P_{s,eta}: ", Table[cfSimp60[Tr[cfProj[s, e]] /. cfW -> Sqrt[cfk0^2 + cfk1^2 + cfk2^2 + cfk3^2 + cfMs^2]], {s, {1, -1}}, {e, {1, -1}}]}
]];

(* ---------- Input cell 191 ---------- *)
cfRunCell[191, Hold[
ClearAll[cfJWsz, cfJWa, cfJWid, cfF, cfFd, cfFockZeroQ, cfId65536, cfHm, cfJhm, cfHfree, cfSop, cfPop, cfOmU, cfEtaU, cfBdd, cfHam, cfHamDiag, cfOcc];
cfJWsz = SparseArray[{{1, 1} -> 1, {2, 2} -> -1}];  cfJWa = SparseArray[{{1, 2} -> 1}, {2, 2}];  cfJWid = IdentityMatrix[2, SparseArray];
cfF  = Table[KroneckerProduct @@ Join[ConstantArray[cfJWsz, j - 1], {cfJWa}, ConstantArray[cfJWid, 16 - j]], {j, 16}];
cfFd = ConjugateTranspose /@ cfF;
cfId65536 = IdentityMatrix[65536, SparseArray];
cfFockZeroQ[m_] := With[{v = SparseArray[m]["NonzeroValues"]}, v === {} || Union[v] === {0}];
cfAssert["FOCK [solver regression]: the Jordan-Wigner operators obey the positive CAR {f_i, f_j^dagger} == delta_ij, {f_i, f_j} == 0 on C^65536",
  cfTimed["the CAR of 16 Jordan-Wigner operators", {Table[cfFockZeroQ[cfF[[i]] . cfFd[[j]] + cfFd[[j]] . cfF[[i]] - If[i == j, cfId65536, 0]], {i, 16}, {j, 16}],
    Table[cfFockZeroQ[cfF[[i]] . cfF[[j]] + cfF[[j]] . cfF[[i]]], {i, 16}, {j, i, 16}]}]];
(* field level, at k = 3 e1, m = 4 *)
cfHm  = cfHk[{0, 3, 0, 0, 0, 0, 0, 0}, 4];
cfJhm = cfJK . cfHm;
cfHfree = Sum[If[cfJhm[[a, b]] === 0, 0, cfJhm[[a, b]] cfFd[[a]] . cfF[[b]]], {a, 16}, {b, 16}];
cfSop   = Sum[If[cfBeta[[a, b]] === 0, 0, cfBeta[[a, b]] cfFd[[a]] . cfF[[b]]], {a, 16}, {b, 16}];
cfPop   = Sum[With[{c = (cfJK . cfCplus)[[a, b]]}, If[c === 0, 0, c cfFd[[a]] . cfF[[b]]]], {a, 16}, {b, 16}];
cfAssert["FOCK (field level) [THE RESULT]: {Psi_a, Psi^ddag_b} == J_ab == (G^-1)_ab with Psi = f, Psi^ddag = f^dagger J -- the Dirac-bracket anticommutator, realized on a positive Fock space",
  Table[cfFockZeroQ[cfF[[a]] . Sum[If[cfJK[[c, b]] === 0, 0, cfJK[[c, b]] cfFd[[c]]], {c, 16}] + Sum[If[cfJK[[c, b]] === 0, 0, cfJK[[c, b]] cfFd[[c]]], {c, 16}] . cfF[[a]]
      - Inverse[cfGK][[a, b]] cfId65536], {a, 16}, {b, 16}]];
cfAssert["FOCK (field level) [THE RESULT]: J h is Hermitian with eigenvalues +5 (8) and -5 (8); H_free and s are Hermitian operators, so is H_free + (3/7) s^2; p = Psi^ddag C+ Psi is ANTI-Hermitian",
  {cfJhm === ConjugateTranspose[cfJhm], Sort[Tally[Eigenvalues[cfJhm]]] === {{-5, 8}, {5, 8}},
   cfFockZeroQ[cfHfree - ConjugateTranspose[cfHfree]], cfFockZeroQ[cfSop - ConjugateTranspose[cfSop]],
   cfFockZeroQ[(cfHfree + (3/7) cfSop . cfSop) - ConjugateTranspose[cfHfree + (3/7) cfSop . cfSop]],
   cfFockZeroQ[cfPop + ConjugateTranspose[cfPop]], ! cfFockZeroQ[cfPop]}];
cfAssert["FOCK (field level) [THE RESULT]: Heisenberg -- [H_free, Psi_a] == -(G^-1 h Psi)_a for all 16 components, so i d_4 Psi = i [H, Psi] IS the field equation i G d_4 Psi = h Psi",
  cfTimed["the Heisenberg equation on the Fock space", Table[cfFockZeroQ[cfHfree . cfF[[a]] - cfF[[a]] . cfHfree + Sum[If[cfJhm[[a, b]] === 0, 0, cfJhm[[a, b]] cfF[[b]]], {b, 16}]], {a, 16}]]];
cfAssert["FOCK (field level) [control]: with the opposite sign of the anticommutator the Hamiltonian is -H_free and [H', Psi_a] == +(G^-1 h Psi)_a: the time-REVERSED equation",
  With[{hp = -cfHfree}, {cfFockZeroQ[hp . cfF[[1]] - cfF[[1]] . hp - Sum[If[cfJhm[[1, b]] === 0, 0, cfJhm[[1, b]] cfF[[b]]], {b, 16}]],
     ! cfFockZeroQ[hp . cfF[[1]] - cfF[[1]] . hp + Sum[If[cfJhm[[1, b]] === 0, 0, cfJhm[[1, b]] cfF[[b]]], {b, 16}]]}]];
(* mode level *)
cfOmU  = Join[ConstantArray[5, 8], ConstantArray[-5, 8]];
cfEtaU = Join[{1, 1, 1, 1, -1, -1, -1, -1}, {1, 1, 1, 1, -1, -1, -1, -1}];
cfBdd  = Table[cfEtaU[[u]] cfFd[[u]], {u, 16}];                                  (* b_u^ddag = eta_u b_u^dagger *)
cfHam  = Sum[cfOmU[[u]] cfFd[[u]] . cfF[[u]], {u, 16}];
cfHamDiag = Normal[Diagonal[cfHam]];
cfOcc[i_] := IntegerDigits[i - 1, 2, 16];                                          (* occupations n_1..n_16 of basis state i *)
cfAssert["FOCK (mode level) [THE RESULT]: {b_u, b_v^ddag} == eta_u delta_uv (the indefinite CAR demanded by Sum eta u u^dagger = G^-1), and the J-involution b^dagger = eta b^ddag restores {b, b^dagger} == 1",
  {Table[cfFockZeroQ[cfF[[u]] . cfBdd[[v]] + cfBdd[[v]] . cfF[[u]] - If[u == v, cfEtaU[[u]] cfId65536, 0]], {u, 16}, {v, 16}],
   Table[cfFockZeroQ[cfEtaU[[u]] cfBdd[[u]] - cfFd[[u]]], {u, 16}]}];
cfAssert["FOCK (mode level) [has content]: the naive Krein 'norm' <0| b_u b_u^ddag |0> equals eta_u -- NEGATIVE for the four eta = -1 modes of each frequency -- while the Fock norm <0| b_u b_u^dagger |0> == 1",
  With[{vac = SparseArray[{1 -> 1}, 65536]}, {Table[vac . (cfF[[u]] . cfBdd[[u]] . vac), {u, 16}] === cfEtaU, Table[vac . (cfF[[u]] . cfFd[[u]] . vac), {u, 16}] === ConstantArray[1, 16]}]];
cfAssert["FOCK (mode level) [THE RESULT]: Sum omega_u eta_u b_u^ddag b_u == Sum omega_u b_u^dagger b_u, and [Ham, b_u] == -omega_u b_u for every u (b_u(x4) = b_u e^(-i omega_u x4))",
  {cfFockZeroQ[Sum[cfOmU[[u]] cfEtaU[[u]] cfBdd[[u]] . cfF[[u]], {u, 16}] - cfHam],
   Table[cfFockZeroQ[cfHam . cfF[[u]] - cfF[[u]] . cfHam + cfOmU[[u]] cfF[[u]]], {u, 16}]}];
cfAssert["FOCK (mode level) [THE RESULT]: the spectrum -- a UNIQUE ground state at -8 omega = -40, the Dirac sea (modes 9..16 filled, 1..8 empty); :Ham: = Ham + 40 >= 0",
  With[{mn = Min[cfHamDiag], pos = Flatten[Position[cfHamDiag, Min[cfHamDiag]]]},
    {mn === -40, Length[pos] === 1, cfOcc[First[pos]] === Join[ConstantArray[0, 8], ConstantArray[1, 8]], Min[cfHamDiag + 40] === 0}]];
cfAssert["FOCK (mode level) [THE RESULT]: the first excited level, omega = 5 above the sea, is 16-fold: 8 particle states (N = +1) and 8 antiparticle states (N = -1), with N = Sum b^dagger b - 8",
  With[{pos = Flatten[Position[cfHamDiag, -35]]},
    {Length[pos] === 16, Sort[Table[Total[cfOcc[i]] - 8, {i, pos}]] === Join[ConstantArray[-1, 8], ConstantArray[1, 8]],
     Count[pos, i_ /; Total[cfOcc[i][[1 ;; 8]]] === 1 && Total[cfOcc[i][[9 ;; 16]]] === 8] === 8,
     Count[pos, i_ /; Total[cfOcc[i][[1 ;; 8]]] === 0 && Total[cfOcc[i][[9 ;; 16]]] === 7] === 8}]];
cfAssert["FOCK (mode level) [THE RESULT]: in every Fock basis state tested (the sea and the 16 first excited states) <n| b_u^ddag b_v |n> == eta_u n_u delta_uv -- the expectation rule of Section 29",
  Module[{states = Join[Flatten[Position[cfHamDiag, -40]], Flatten[Position[cfHamDiag, -35]]]},
    Table[With[{vec = SparseArray[{st -> 1}, 65536]}, Table[vec . (cfBdd[[u]] . (cfF[[v]] . vec)), {u, 16}, {v, 16}] ===
       Table[If[u == v, cfEtaU[[u]] cfOcc[st][[u]], 0], {u, 16}, {v, 16}]], {st, states}]]];
cfAssert["CHARGE [THE RESULT]: n^4 = -(i/H) Psibar gamma^4 Psi == (1/H) Psi^ddag G Psi == (1/H) Psi^dagger Psi, whose mode form Sum_u eta_u b_u^ddag b_u == Sum_u b_u^dagger b_u is the particle number (normal-ordered: particles - antiparticles)",
  {-I \[Sigma]16 . cfGamUp[[5]] === cfGK, cfJK . cfGK === ID16,
   cfFockZeroQ[Sum[cfEtaU[[u]] cfBdd[[u]] . cfF[[u]], {u, 16}] - Sum[cfFd[[u]] . cfF[[u]], {u, 16}]]}];
{"ground-state energy ", Min[cfHamDiag], ";  first excited level ", -35, " with degeneracy ", Count[cfHamDiag, -35]}
]];

(* ---------- Input cell 192 ---------- *)
cfRunCell[192, Hold[
ClearAll[cfTF, cfTParC, cfFirstOrder, cfKin1, cfHilbert, cfFrDiag, cfUVRule2, cfVecRule];
(* substitution rules that make the sixteen components of Psi(x0, x4) (head cfPsiC) or Psibar (head cfPsiB) the entries *)
(* of a given vector expression in the symbols u0, u4 (Function is assembled with Apply, so u0, u4 are not renamed)   *)
cfVecRule[head_, vec_] := Table[head[k - 1] -> (Function @@ {{u0, u4}, vec[[k]]}), {k, 16}];     (* built with Apply: no renaming of u0, u4 *)
cfTF   = cfTFermion[cfPsiCGen, cfPsiBGen, cfGamUp, GammaSpinCanonical, gCanonical, cfVs];       (* That, generic Psi(x0,x4), Psibar(x0,x4) *)
cfTParC = cfTFermion[cfPsiCGen, cfPsiBGen, cfGamUp, cfZeroSpin, gCanonical, cfVs];               (* the same with d in place of D *)
cfFrDiag = Diagonal[frameCanonical];
(* first-order change of the frame-dependent objects under frame -> frame + e1 *)
cfFirstOrder[e1_] := Module[{e0 = frameCanonical, c0 = coframeCanonical, g0 = gCanonical, gi0 = gInvCanonical, Gam0 = GammaCanonical,
    g1, gi1, dg0, dg1, Gam1, c1, om1, Gs1, gu1, sq1},
  g1 = e1 . \[Eta]4488 . Transpose[e0] + e0 . \[Eta]4488 . Transpose[e1];
  gi1 = -gi0 . g1 . gi0;
  dg0 = Table[D[g0[[m, p]], X[[k]]], {k, 8}, {m, 8}, {p, 8}];
  dg1 = Table[D[g1[[m, p]], X[[k]]], {k, 8}, {m, 8}, {p, 8}];
  Gam1 = Table[(1/2) Sum[gi1[[r, s]] (dg0[[m, s, p]] + dg0[[p, s, m]] - dg0[[s, m, p]]) + gi0[[r, s]] (dg1[[m, s, p]] + dg1[[p, s, m]] - dg1[[s, m, p]]), {s, 8}],
    {r, 8}, {m, 8}, {p, 8}];
  c1 = -c0 . e1 . c0;
  om1 = Table[Sum[(Sum[Gam1[[r, mu, nu]] e0[[r, a]] + Gam0[[r, mu, nu]] e1[[r, a]], {r, 8}] - D[e1[[nu, a]], X[[mu]]]) c0[[c, nu]]
       + (Sum[Gam0[[r, mu, nu]] e0[[r, a]], {r, 8}] - D[e0[[nu, a]], X[[mu]]]) c1[[c, nu]], {nu, 8}], {mu, 8}, {a, 8}, {c, 8}];
  Gs1 = Table[cfSpinMatrix[cfLowerFirstFlat[om1, \[Eta]4488], mu], {mu, 8}];
  gu1 = Table[Sum[c1[[a, mu]] T16[a - 1], {a, 8}], {mu, 8}];
  sq1 = cfSqrtg Tr[c0 . e1];
  {gu1, Gs1, sq1}];
(* first-order change of the symmetrized kinetic term, from delta gamma^mu and delta Gamma_mu *)
cfKin1[gu1_, Gs1_] := (1/(2 H)) (cfPsiBGen . Sum[gu1[[mu]] . (D[cfPsiCGen, X[[mu]]] + GammaSpinCanonical[[mu]] . cfPsiCGen) + cfGamUp[[mu]] . Gs1[[mu]] . cfPsiCGen, {mu, 8}]
    - Sum[(D[cfPsiBGen, X[[mu]]] - cfPsiBGen . GammaSpinCanonical[[mu]]) . gu1[[mu]] . cfPsiCGen - cfPsiBGen . Gs1[[mu]] . cfGamUp[[mu]] . cfPsiCGen, {mu, 8}]);
(* T^{mn} from the symmetric perturbation of slot (m, n); withDG -> False drops the spin-connection variation *)
cfHilbert[{m_, n_}, withDG_] := Module[{e1 = ConstantArray[0, {8, 8}], pc, l1, el},
  If[m == n, e1[[m, m]] = cfHh[x0, x4] \[Eta]4488[[m, m]]/cfFrDiag[[m]],
    e1[[m, n]] = cfHh[x0, x4] \[Eta]4488[[n, n]]/cfFrDiag[[n]]; e1[[n, m]] = cfHh[x0, x4] \[Eta]4488[[m, m]]/cfFrDiag[[m]]];
  pc = cfFirstOrder[e1];
  l1 = pc[[3]] cfLhatC + cfSqrtg cfKin1[pc[[1]], If[withDG, pc[[2]], 0 pc[[2]]]];
  el = cfEulerLagrange[l1, {cfHh[x0, x4]}, X][[1]];
  If[m == n, el/cfSqrtg, el/(2 cfSqrtg)]];
cfAssert["EMT [THE RESULT]: the Hilbert (symmetric-tetrad) tensor of the symmetrized action IS That, OFF shell -- components (x1,x1), (x4,x4), (x1,x4), (x0,x5), (x5,x4)",
  cfTimed["Hilbert tensor from first-order symmetric tetrad perturbations, five components",
    Table[cfZeroQ[Expand[cfHilbert[pr, True] - gInvCanonical[[pr[[1]], pr[[1]]]] gInvCanonical[[pr[[2]], pr[[2]]]] cfTF[[pr[[1]], pr[[2]]]]]],
      {pr, {{2, 2}, {5, 5}, {2, 5}, {1, 6}, {6, 5}}}]]];
cfAssert["EMT [has content]: the spin-connection variation contributes NOTHING -- dropping it leaves the Hilbert tensor unchanged at (x1,x4), (x0,x5), (x5,x4)",
  Table[cfZeroQ[Expand[cfHilbert[pr, False] - cfHilbert[pr, True]]], {pr, {{2, 5}, {1, 6}, {6, 5}}}]];
cfAssert["EMT [control]: the Hilbert tensor is NOT the partial-derivative tensor: at (x1,x4) they differ -- witnessed on constant spinors (Psibar = e1, Psi = e11: (T16[4] T16[1] T16[0])_{1,11} != 0)",
  {(T16[4] . T16[1] . T16[0])[[1, 11]] =!= 0,
   cfNonZeroWitnessQ[(gInvCanonical[[2, 2]] gInvCanonical[[5, 5]] (cfTF[[2, 5]] - cfTParC[[2, 5]])) /.
     Join[cfVecRule[cfPsiB, UnitVector[16, 1]], cfVecRule[cfPsiC, UnitVector[16, 11]]]]}];
cfAssert["EMT [definition]: That is symmetric",
  cfTF === Transpose[cfTF]];
cfUVRule2 = Join[Table[With[{kk = k}, cfPsiC[kk] -> Function[{u0, u4}, cfRe2[kk][u0, u4] + I cfIm2[kk][u0, u4]]], {k, 0, 15}],
   Table[With[{kk = k}, cfPsiB[kk] -> Function[{u0, u4}, Evaluate[(Table[cfRe2[j][u0, u4] - I cfIm2[j][u0, u4], {j, 0, 15}] . \[Sigma]16)[[kk + 1]]]]], {k, 0, 15}]];
cfAssert["EMT [THE RESULT]: That is Hermitian under the classical conjugation: real for Psi = u + i v, Psibar = (u - i v)^T sigma16, all 64 components",
  Module[{t = cfExpandV[Expand[cfTF /. cfUVRule2]]}, Expand[cfExpandV[t - cfConjFlip[t]]] === ConstantArray[0, {8, 8}]]];
{Dimensions[cfTF], Count[Flatten[cfTF], Except[0]], " non-zero components"}
]];

(* ---------- Input cell 193 ---------- *)
cfRunCell[193, Hold[
ClearAll[cfSC, cfFC, cfFBv, cfOnShellC, cfDivTF, cfKhC];
cfSC  = cfPsiBGen . cfPsiCGen;
cfFC  = -cfGamUp[[5]] . (H cfVs'[cfSC] cfPsiCGen - cfGamUp[[1]] . D[cfPsiCGen, x0] - cfSumGG . cfPsiCGen);
cfFBv = (H cfVs'[cfSC] cfPsiBGen + D[cfPsiBGen, x0] . cfGamUp[[1]] - cfPsiBGen . Sum[GammaSpinCanonical[[mu]] . cfGamUp[[mu]], {mu, 8}]) . cfGamUp[[5]];
cfOnShellC[expr_] := FixedPoint[Function[e, e /. {Derivative[a_, b_ /; b >= 1][cfPsiC[k_]][x0, x4] :> D[cfFC[[k + 1]], {x0, a}, {x4, b - 1}],
      Derivative[a_, b_ /; b >= 1][cfPsiB[k_]][x0, x4] :> D[cfFBv[[k + 1]], {x0, a}, {x4, b - 1}]}], expr, 12];
cfAssert["EMT CONSERVATION [definition]: F and Fbar solve the field equation and the adjoint equation for the x4-derivatives",
  {cfZeroArrayQ[Expand[cfEquationFermion[cfPsiCGen, cfPsiBGen, cfGamUp, GammaSpinCanonical, cfVs] /. Derivative[0, 1][cfPsiC[k_]][x0, x4] :> cfFC[[k + 1]]]],
   cfZeroArrayQ[Expand[cfAdjointEquationFermion[cfPsiCGen, cfPsiBGen, cfGamUp, GammaSpinCanonical, cfVs] /. Derivative[0, 1][cfPsiB[k_]][x0, x4] :> cfFBv[[k + 1]]]]}];
cfDivTF = cfTimed["nabla^mu That_{mu nu}, generic Psi(x0, x4), Psibar(x0, x4)", cfCovariantDivergence[cfTF, gInvCanonical, GammaCanonical, X]];
cfAssert["EMT CONSERVATION [THE RESULT]: nabla^mu That_{mu nu} == 0 ON SHELL in all eight components, for generic Psi(x0, x4), Psibar(x0, x4) and generic V",
  cfTimed["the on-shell divergence, eight components", cfZeroArrayQ[Table[Expand[cfOnShellC[cfDivTF[[nu]]]], {nu, 8}]]]];
cfAssert["EMT CONSERVATION [control]: OFF shell the divergence is not zero -- witnessed on Psi = (x4 + x0^2) e1 + e13, Psibar = e1 + x4 e5 with V = s^2, which is not a solution",
  cfNonZeroWitnessQ[cfDivTF /. cfVs -> (#^2 &) /. Join[cfVecRule[cfPsiC, (u4 + u0^2) UnitVector[16, 1] + UnitVector[16, 13]],
     cfVecRule[cfPsiB, UnitVector[16, 1] + u4 UnitVector[16, 5]]]]];
cfAssert["EMT [THE RESULT]: That - T_par == -(1/(4H)) Psibar ({gamma_mu, Gamma_nu} + {gamma_nu, Gamma_mu}) Psi: equal on the diagonal (every {gamma_mu, Gamma_mu} vanishes), different off it (the (x1, x4) witness above)",
  {Expand[cfTF - cfTParC + (1/(4 H)) Table[cfPsiBGen . (cfAnti[cfGamDn[[mu]], GammaSpinCanonical[[nu]]] + cfAnti[cfGamDn[[nu]], GammaSpinCanonical[[mu]]]) . cfPsiCGen, {mu, 8}, {nu, 8}]] === ConstantArray[0, {8, 8}],
   cfZeroArrayQ[Table[cfAnti[cfGamDn[[mu]], GammaSpinCanonical[[mu]]], {mu, 8}]]}];
{"on-shell divergence checked in ", 8, " components"}
]];

(* ---------- Input cell 194 ---------- *)
cfRunCell[194, Hold[
ClearAll[cfKinC, cfLhatOnC, cfTAdm, cfPsiAdB, cfJParity, cfParityTable, cfJflipRule];
cfKinC = cfLhatC + cfVs[cfSC];
cfKhC  = -(1/(2 H)) (cfPsiBGen . cfGamUp[[1]] . D[cfPsiCGen, x0] - D[cfPsiBGen, x0] . cfGamUp[[1]] . cfPsiCGen);
cfAssert["EMT ON SHELL [THE RESULT]: the kinetic bilinear == s V'(s) (not zero) and Lhat == s V'(s) - V(s)",
  {cfZeroQ[Expand[cfOnShellC[cfKinC] - cfSC cfVs'[cfSC]]], cfZeroQ[Expand[cfOnShellC[cfLhatC] - (cfSC cfVs'[cfSC] - cfVs[cfSC])]]}];
cfAssert["EMT ON SHELL [THE RESULT]: rho = That_44 == V(s) + K_h",
  cfZeroQ[Expand[cfOnShellC[cfTF[[5, 5]]] - (cfVs[cfSC] + cfKhC)]]];
cfAssert["EMT ON SHELL [THE RESULT]: T^i_i == T^h_h == s V'(s) - V(s) for the three observed and the three hidden directions, and T^0_0 == s V'(s) - V(s) + K_h",
  {Table[cfZeroQ[Expand[cfOnShellC[gInvCanonical[[i, i]] cfTF[[i, i]]] - (cfSC cfVs'[cfSC] - cfVs[cfSC])]], {i, {2, 3, 4, 6, 7, 8}}],
   cfZeroQ[Expand[cfOnShellC[gInvCanonical[[1, 1]] cfTF[[1, 1]]] - (cfSC cfVs'[cfSC] - cfVs[cfSC] + cfKhC)]]}];
cfAssert["EMT [has content]: the trace T^mu_mu == 7 Lkin - 8 V off shell, == 7 s V'(s) - 8 V(s) on shell",
  {cfZeroQ[Expand[Sum[gInvCanonical[[mu, nu]] cfTF[[mu, nu]], {mu, 8}, {nu, 8}] - (7 cfKinC - 8 cfVs[cfSC])]],
   cfZeroQ[Expand[cfOnShellC[Sum[gInvCanonical[[mu, nu]] cfTF[[mu, nu]], {mu, 8}, {nu, 8}]] - (7 cfSC cfVs'[cfSC] - 8 cfVs[cfSC])]]}];
cfAssert["EMT [fidelity]: K_h in the real commuting limit IS Part VI's cfKh, and K_h == 0 on the rescaled solutions Sqrt[Sin] Psi'(x4), Sqrt[Sin] Psi'bar(x4), where rho == V(s)",
  {Expand[(cfKhC /. cfRealRule) - cfKh] === 0,
   Module[{rr = Join[Table[With[{kk = k}, cfPsiC[kk] -> Function[{u0, u4}, Sqrt[Sin[6 H u0]] cfPsiR[kk][u4]]], {k, 0, 15}],
       Table[With[{kk = k}, cfPsiB[kk] -> Function[{u0, u4}, Sqrt[Sin[6 H u0]] cfPsiRB[kk][u4]]], {k, 0, 15}]]},
     {cfZeroQ[Expand[cfKhC /. rr]], cfZeroQ[Expand[(cfOnShellC[cfTF[[5, 5]]] - cfVs[cfSC]) /. rr]]}]}];
(* the J-parity table, admissible fields Psi(x0..x4), Psibar(x0..x4) *)
cfPsiAdB = Table[cfPsiAdmB[k][x0, x1, x2, x3, x4], {k, 0, 15}];
cfTAdm = cfTFermion[cfPsiAd, cfPsiAdB, cfGamUp, GammaSpinCanonical, gCanonical, cfVs];
cfJflipRule = Join[Table[With[{kk = k}, cfPsiAdm[kk] -> Function[{u0, u1, u2, u3, u4}, Evaluate[(cfJK . cfPsiAd)[[kk + 1]] /. Thread[{x0, x1, x2, x3, x4} -> {u0, u1, u2, u3, u4}]]]], {k, 0, 15}],
   Table[With[{kk = k}, cfPsiAdmB[kk] -> Function[{u0, u1, u2, u3, u4}, Evaluate[(cfPsiAdB . cfJK)[[kk + 1]] /. Thread[{x0, x1, x2, x3, x4} -> {u0, u1, u2, u3, u4}]]]], {k, 0, 15}]];
cfJParity[e_] := Module[{a = cfExpandV[Expand[e]], b},
  b = cfExpandV[Expand[e /. cfJflipRule]];
  Which[a === 0, "zero", Expand[a - b] === 0, "even", Expand[a + b] === 0, "odd", True, "mixed"]];
cfParityTable = cfTimed["the J-parity of all 64 components of That, admissible fields", Table[cfJParity[cfTAdm[[mu, nu]]], {mu, 8}, {nu, 8}]];
cfAssert["EMT HERMITICITY [THE RESULT]: J-parity table -- (mu, nu) in {0..4}: EVEN (Hermitian); (mu in 0..4, h in 5..7): ODD (anti-Hermitian); (h, h'), h != h': ZERO identically; (h, h): even",
  {Union[Flatten[cfParityTable[[1 ;; 5, 1 ;; 5]]]] === {"even"}, Union[Flatten[cfParityTable[[1 ;; 5, 6 ;; 8]]]] === {"odd"},
   Union[Flatten[Table[If[i != j, cfParityTable[[i, j]], Nothing], {i, 6, 8}, {j, 6, 8}]]] === {"zero"},
   Union[Table[cfParityTable[[h, h]], {h, 6, 8}]] === {"even"}}];
cfAssert["EMT HERMITICITY [has content]: for x5..x7-independent fields That_{hh} == g_hh Lhat exactly, because {gamma_h, Gamma_h} == 0",
  {cfZeroArrayQ[Table[cfAnti[cfGamDn[[h]], GammaSpinCanonical[[h]]], {h, 6, 8}]],
   Table[Expand[cfTAdm[[h, h]] - gCanonical[[h, h]] cfLhatFermion[cfPsiAd, cfPsiAdB, cfGamUp, GammaSpinCanonical, cfVs]] === 0, {h, 6, 8}]}];
Grid[Prepend[MapThread[Prepend, {cfParityTable, Table[Row[{"x", mu - 1}], {mu, 8}]}], Prepend[Table[Row[{"x", nu - 1}], {nu, 8}], ""]], Frame -> All]
]];

(* ---------- Input cell 195 ---------- *)
cfRunCell[195, Hold[
ClearAll[cfUb, cfUv, cfPW, cfPWrule, cfTflat, cfLflat];
cfUb = Array[cfUbar, 16];  cfUv = Array[cfUvec, 16];
(* canonical normalization on the flat frame: chi = Psi/Sqrt[H]; the plane wave in (x0..x3, x4) *)
cfPWrule = Join[Table[With[{kk = k}, cfPsiAdm[kk] -> Function[{u0, u1, u2, u3, u4}, Sqrt[H] cfUv[[kk + 1]] Exp[I (cfk0 u0 + cfk1 u1 + cfk2 u2 + cfk3 u3 - cfOm u4)]]], {k, 0, 15}],
   Table[With[{kk = k}, cfPsiAdmB[kk] -> Function[{u0, u1, u2, u3, u4}, Sqrt[H] cfUb[[kk + 1]] Exp[-I (cfk0 u0 + cfk1 u1 + cfk2 u2 + cfk3 u3 - cfOm u4)]]], {k, 0, 15}]];
cfTflat = cfTFermion[cfPsiAd, cfPsiAdB, cfGamFlat, cfZeroSpin, \[Eta]4488, (cfWW[#/H] &)] /. cfPWrule;
cfLflat = cfLhatFermion[cfPsiAd, cfPsiAdB, cfGamFlat, cfZeroSpin, (cfWW[#/H] &)] /. cfPWrule;
cfAssert["MODE SUMS [THE RESULT]: on a flat-frame plane wave (canonical normalization), T_44 + Lhat == omega ubar (-i T16[4]) u and T^j_j - Lhat == k_j ubar (-i T16[j]) u (j = 0..3): energy and pressure are the frequency and k_j dh/dk_j bilinears",
  {cfSimp60[cfTflat[[5, 5]] + cfLflat - cfOm cfUb . (-I T16[4]) . cfUv] === 0,
   Table[cfSimp60[\[Eta]4488[[j + 1, j + 1]] cfTflat[[j + 1, j + 1]] - cfLflat - {cfk0, cfk1, cfk2, cfk3}[[j + 1]] cfUb . (-I T16[j]) . cfUv], {j, 0, 3}] === {0, 0, 0, 0}}];
cfAssert["MODE SUMS [has content]: with ubar = u^ddag sigma16 these are omega u^ddag G u and k_j u^ddag (dh/dk_j) u, so by Section 28 each occupied mode contributes omega, k_j^2/omega and (to sigma) m/omega",
  {\[Sigma]16 . (-I T16[4]) === cfGK, Table[\[Sigma]16 . (-I T16[j]) === D[cfHkAdm, {cfk0, cfk1, cfk2, cfk3}[[j + 1]]], {j, 0, 3}]}];
cfAssert["VACUUM [THE RESULT]: the unrenormalized sea energy -eps_KS(Lambda) == -(g/(16 pi^2))(2 Lambda^4 + 2 m^2 Lambda^2 + m^4/4 - m^4 Log[2 Lambda/m]) + o(1) as Lambda -> infinity; its m-dependent finite part contains -(g/(32 pi^2)) m^4 Log[m^2]",
  Module[{lam, epsL},
    epsL = (cfGdeg/(16 Pi^2)) (lam Sqrt[lam^2 + cfMm^2] (2 lam^2 + cfMm^2) - cfMm^4 Log[(lam + Sqrt[lam^2 + cfMm^2])/cfMm]);
    {Limit[-epsL + (cfGdeg/(16 Pi^2)) (2 lam^4 + 2 cfMm^2 lam^2 + cfMm^4/4 - cfMm^4 Log[2 lam/cfMm]), lam -> Infinity, Assumptions -> cfMm > 0] === 0,
     cfSimp60[Coefficient[Expand[PowerExpand[-(cfGdeg/(16 Pi^2)) (- cfMm^4 (Log[2] + Log[lam] - Log[cfMm]))]], Log[cfMm]] - (-(cfGdeg/(32 Pi^2)) cfMm^4) 2] === 0}]];
Short[cfTflat[[5, 5]], 3]
]];

(* ---------- Input cell 196 ---------- *)
cfRunCell[196, Hold[
ClearAll[cfWF, cfLF, cfNKS, cfSigKS, cfEpsKS, cfPKS, cfKSas, cfWks, cfI1, cfI2, cfI3, cfDl, cfXx];
cfKSas = cfKF > 0 && cfMm > 0;
cfWF = Sqrt[cfKF^2 + cfMm^2];  cfLF = Log[(cfKF + cfWF)/cfMm];
cfNKS   = cfGdeg cfKF^3/(6 Pi^2);
cfSigKS = (cfGdeg cfMm/(4 Pi^2)) (cfKF cfWF - cfMm^2 cfLF);
cfEpsKS = (cfGdeg/(16 Pi^2)) (cfKF cfWF (2 cfKF^2 + cfMm^2) - cfMm^4 cfLF);
cfPKS   = (cfGdeg/(48 Pi^2)) (cfKF cfWF (2 cfKF^2 - 3 cfMm^2) + 3 cfMm^4 cfLF);
cfAssert["KOHN-SHAM [definition]: the degeneracy g = 8 -- per momentum the positive-frequency eigenspace has rank 8 (Section 28's P_{+,+} + P_{+,-}), four flavours times two spins",
  cfModW[Tr[cfProj[1, 1] + cfProj[1, -1]] - 8] === 0];
cfAssert["KOHN-SHAM [THE RESULT]: each closed form has k_F-derivative (g/(2 pi^2)) k_F^2 f(k_F) with f = 1, m/omega, omega, k^2/(3 omega), and vanishes at k_F = 0 -- so it IS the integral g Int d^3k/(2 pi)^3 f",
  {cfSimp60[D[cfNKS, cfKF] - (cfGdeg/(2 Pi^2)) cfKF^2, cfKSas] === 0, cfSimp60[D[cfSigKS, cfKF] - (cfGdeg/(2 Pi^2)) cfKF^2 cfMm/cfWF, cfKSas] === 0,
   cfSimp60[D[cfEpsKS, cfKF] - (cfGdeg/(2 Pi^2)) cfKF^2 cfWF, cfKSas] === 0, cfSimp60[D[cfPKS, cfKF] - (cfGdeg/(2 Pi^2)) cfKF^4/(3 cfWF), cfKSas] === 0,
   Union[cfSimp60[#, cfMm > 0] & /@ ({cfNKS, cfSigKS, cfEpsKS, cfPKS} /. cfKF -> 0)] === {0}}];
cfAssert["KOHN-SHAM [has content]: Integrate returns the same functions, with ArcTanh[k_F/w_F] in place of L -- and ArcTanh[k_F/w_F] == L (equal derivatives, both 0 at k_F = 0)",
  {cfSimp60[D[ArcTanh[cfKF/cfWF] - cfLF, cfKF], cfKSas] === 0, cfSimp60[ArcTanh[cfKF/cfWF] - cfLF /. cfKF -> 0, cfMm > 0] === 0,
   cfSimp60[(cfEpsKS - (cfGdeg/(2 Pi^2)) Integrate[cfKk^2 Sqrt[cfKk^2 + cfMm^2], {cfKk, 0, cfKF}, Assumptions -> cfKSas]) /. ArcTanh[cfKF/cfWF] -> cfLF, cfKSas] === 0,
   cfSimp60[(cfPKS - (cfGdeg/(6 Pi^2)) Integrate[cfKk^4/Sqrt[cfKk^2 + cfMm^2], {cfKk, 0, cfKF}, Assumptions -> cfKSas]) /. ArcTanh[cfKF/cfWF] -> cfLF, cfKSas] === 0,
   cfSimp60[(cfSigKS - (cfGdeg cfMm/(2 Pi^2)) Integrate[cfKk^2/Sqrt[cfKk^2 + cfMm^2], {cfKk, 0, cfKF}, Assumptions -> cfKSas]) /. ArcTanh[cfKF/cfWF] -> cfLF, cfKSas] === 0}];
cfAssert["KOHN-SHAM [control]: numerical quadrature agrees at k_F = 3/2, m = 1, g = 8 to 1e-12 (a cross-check; the proof is the symbolic one above)",
  Module[{r = {cfKF -> 3/2, cfMm -> 1, cfGdeg -> 8}},
    Max[Abs[{N[cfEpsKS /. r, 20] - (8/(2 Pi^2)) NIntegrate[k^2 Sqrt[k^2 + 1], {k, 0, 3/2}, WorkingPrecision -> 20],
       N[cfPKS /. r, 20] - (8/(6 Pi^2)) NIntegrate[k^4/Sqrt[k^2 + 1], {k, 0, 3/2}, WorkingPrecision -> 20],
       N[cfSigKS /. r, 20] - (8/(2 Pi^2)) NIntegrate[k^2/Sqrt[k^2 + 1], {k, 0, 3/2}, WorkingPrecision -> 20]}]] < 10^-12]];
cfAssert["KOHN-SHAM [THE RESULT]: eps + P == w_F n (Gibbs), eps - 3 P == m sigma (trace), d eps/dm == sigma, d eps/dk_F == w_F dn/dk_F",
  {cfSimp60[cfEpsKS + cfPKS - cfWF cfNKS, cfKSas] === 0, cfSimp60[cfEpsKS - 3 cfPKS - cfMm cfSigKS, cfKSas] === 0,
   cfSimp60[D[cfEpsKS, cfMm] - cfSigKS, cfKSas] === 0, cfSimp60[D[cfEpsKS, cfKF] - cfWF D[cfNKS, cfKF], cfKSas] === 0}];
cfAssert["MEAN FIELD [THE RESULT]: rho = eps + W - sigma W', P_obs = P_KS + sigma W' - W give rho + P_obs == w_F n exactly; and d rho/dn == w_F + (sigma_KS - sigma) W'' sigma'(n), i.e. == w_F at the self-consistent point sigma = sigma_KS (m = W'(sigma) throughout)",
  Module[{kfn, sgn, rhoN, dr, sub},
    sub = {cfKF -> kfn[cfNn], cfMm -> cfWfun'[sgn[cfNn]]};
    rhoN = (cfEpsKS /. sub) + cfWfun[sgn[cfNn]] - sgn[cfNn] cfWfun'[sgn[cfNn]];
    dr = D[rhoN, cfNn] /. {kfn'[cfNn] -> 1/(D[cfNKS, cfKF] /. cfKF -> kfn[cfNn])};
    {cfSimp60[(cfEpsKS + cfW0 - cfSg cfW1) + (cfPKS + cfSg cfW1 - cfW0) - cfWF cfNKS, cfKSas] === 0,
     cfSimp60[dr - ((cfWF /. sub) + ((cfSigKS /. sub) - sgn[cfNn]) cfWfun''[sgn[cfNn]] sgn'[cfNn]), kfn[cfNn] > 0 && cfWfun'[sgn[cfNn]] > 0] === 0}]];
(* w as a function of x = k_F/m, with m = 1 *)
cfWks = Sqrt[cfXx^2 + 1];
cfI1 = (1/8) (cfXx cfWks (2 cfXx^2 + 1) - Log[cfXx + cfWks]);  cfI2 = (1/8) (cfXx cfWks (2 cfXx^2 - 3) + 3 Log[cfXx + cfWks]);  cfI3 = (1/2) (cfXx cfWks - Log[cfXx + cfWks]);
cfDl = cfXx^2 cfI1 - cfWks^2 cfI2;
cfAssert["AUTHOR'S MASS TERM [THE RESULT]: W = m sigma gives W - sigma W' == 0, so rho == eps_KS, P == P_KS, and w = P_KS/eps_KS depends only on x = k_F/m: w == I2/(3 I1), I_n the m = 1 integrals",
  {cfSimp60[(cfMm cfSg) - cfSg D[cfMm cfSg, cfSg]] === 0, cfSimp60[(cfPKS/cfEpsKS /. cfKF -> cfXx cfMm) - cfI2/(3 cfI1), cfXx > 0 && cfMm > 0] === 0,
   cfSimp60[D[cfI1, cfXx] - cfXx^2 cfWks, cfXx > 0] === 0, cfSimp60[D[cfI2, cfXx] - cfXx^4/cfWks, cfXx > 0] === 0, Union[{cfI1, cfI2, cfI3} /. cfXx -> 0] === {0}}];
cfAssert["AUTHOR'S MASS TERM [THE RESULT]: 0 <= w <= 1/3 -- P_KS >= 0 (I2' = x^4/w_x > 0, I2(0) = 0) and eps - 3P = m sigma = (g m^4/(2 pi^2)) I3 >= 0 (I3' = x^2/w_x > 0, I3(0) = 0)",
  {cfSimp60[D[cfI3, cfXx] - cfXx^2/cfWks, cfXx > 0] === 0,
   cfSimp60[(cfMm cfSigKS /. cfKF -> cfXx cfMm) - (cfGdeg cfMm^4/(2 Pi^2)) cfI3, cfXx > 0 && cfMm > 0] === 0,
   cfSimp60[(cfPKS /. cfKF -> cfXx cfMm) - (cfGdeg cfMm^4/(6 Pi^2)) cfI2, cfXx > 0 && cfMm > 0] === 0}];
cfAssert["AUTHOR'S MASS TERM [THE RESULT]: w rises MONOTONICALLY -- dw/dx == x^2 Delta/(3 w_x I1^2) with Delta = x^2 I1 - w_x^2 I2, Delta(0) = 0 and Delta' = 2 x I3 > 0 -- from w -> 0 (x -> 0, w = x^2/5 + O(x^4): dust) to w -> 1/3 (x -> infinity: radiation)",
  {cfSimp60[D[cfI2/(3 cfI1), cfXx] - cfXx^2 cfDl/(3 cfWks cfI1^2), cfXx > 0] === 0,
   cfSimp60[D[cfDl, cfXx] - 2 cfXx cfI3, cfXx > 0] === 0, (cfDl /. cfXx -> 0) === 0,
   Limit[cfI2/(3 cfI1), cfXx -> 0] === 0, Limit[cfI2/(3 cfI1), cfXx -> Infinity] === 1/3,
   Normal[Series[cfI2/(3 cfI1), {cfXx, 0, 2}]] === cfXx^2/5}];
cfAssert["AUTHOR'S MASS TERM [has content]: the classical sign problem disappears -- sigma_KS = g Int m/omega is ODD in m and m sigma_KS = (g m^4/(2 pi^2)) I3(k_F/|m|) >= 0 for either sign, so with m = -2M: M sigma_KS <= 0, the branch M s < 0 that Part VI had to assume",
  {cfSimp60[((cfMm/Sqrt[cfKk^2 + cfMm^2]) /. cfMm -> -cfMm) + cfMm/Sqrt[cfKk^2 + cfMm^2]] === 0,
   cfSimp60[cfMm cfSigKS - (cfGdeg cfMm^4/(2 Pi^2)) (cfI3 /. cfXx -> cfKF/cfMm), cfKSas] === 0}];
cfAssert["CLASSICAL LIMIT [THE RESULT]: at the self-consistent point rho == W + 3 P_KS and P_obs == (sigma W' - W) + P_KS exactly (sigma = sigma_KS, m = W'); Part VI's rho = V(s), P = s V' - V is the limit P_KS/eps_KS -> 0, i.e. k_F/m -> 0",
  {cfSimp60[((cfEpsKS + cfW0 - cfSigKS cfMm) - (cfW0 + 3 cfPKS)), cfKSas] === 0, cfSimp60[((cfPKS + cfSigKS cfMm - cfW0) - ((cfSigKS cfMm - cfW0) + cfPKS))] === 0,
   Limit[cfI2/(3 cfI1), cfXx -> 0] === 0}];
Grid[{{"n", cfNKS}, {"sigma_KS", cfSigKS}, {"eps_KS", cfEpsKS}, {"P_KS", cfPKS}, {"w (mass term)", "P_KS/eps_KS in [0, 1/3]"}}, Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 197 ---------- *)
cfRunCell[197, Hold[
ClearAll[cfRescC, cfJC, cfKc1, cfPsiUx, cfModeRule];
cfJC = Table[I cfPsiBGen . cfGamUp[[mu]] . cfPsiCGen, {mu, 8}];
cfAssert["PRE-UNIVERSE (1) [THE RESULT]: the U(1) current is conserved on shell, (1/Sqrt[g]) d_mu(Sqrt[g] j^mu) == 0, for generic Psi(x0, x4), Psibar(x0, x4)",
  cfZeroQ[Expand[cfOnShellC[(1/cfSqrtg) Sum[D[cfSqrtg cfJC[[mu]], X[[mu]]], {mu, 8}]]]]];
cfRescC = Join[Table[With[{kk = k}, cfPsiC[kk] -> Function[{u0, u4}, Sqrt[Sin[6 H u0]] cfPsiR[kk][u4]]], {k, 0, 15}],
   Table[With[{kk = k}, cfPsiB[kk] -> Function[{u0, u4}, Sqrt[Sin[6 H u0]] cfPsiRB[kk][u4]]], {k, 0, 15}]];
cfAssert["PRE-UNIVERSE (1) [THE RESULT]: for Psi = Sqrt[Sin] Psi'(x4), Sqrt[g] j^0 is x0-independent (Sec Sin Cot == 1), so d_4(Sqrt[g] j^4) == 0 on shell; and Sqrt[g] and q^3 p^3 are x4-independent",
  {cfZeroQ[Sec[6 H x0] Sin[6 H x0] Cot[6 H x0] - 1], cfZeroQ[D[(cfSqrtg cfJC[[1]]) /. cfRescC, x0]],
   cfZeroQ[Expand[(cfOnShellC[D[cfSqrtg cfJC[[5]], x4]]) /. cfRescC]], D[cfSqrtg, x4] === 0, cfZeroQ[D[cfQminus^3 cfQplus^3, x4]]}];
cfAssert["PRE-UNIVERSE (2) [THE RESULT]: Psi = Sqrt[Sin] Psi'(x4) satisfies the field equation iff d_x0 V'(Sin[6Hx0] s') == 0, and d_x0 V'(Sin s') == 6 H Cos[6 H x0] s' V''(Sin s'): V linear OR s' == 0",
  {cfZeroArrayQ[Expand[(cfEquationFermion[cfPsiCGen, cfPsiBGen, cfGamUp, GammaSpinCanonical, cfVs] /. cfRescC)
      - Sqrt[Sin[6 H x0]] (cfGamUp[[5]] . D[Table[cfPsiR[k][x4], {k, 0, 15}], x4] - H cfVs'[cfSC /. cfRescC] Table[cfPsiR[k][x4], {k, 0, 15}])]],
   cfZeroQ[D[cfVs'[Sin[6 H x0] cfSp], x0] - 6 H Cos[6 H x0] cfSp cfVs''[Sin[6 H x0] cfSp]],
   D[cfVs'[Sin[6 H x0] cfSp] /. cfVs -> (cfMlin # &), x0] === 0, (D[cfVs'[Sin[6 H x0] cfSp], x0] /. cfSp -> 0) === 0}];
cfAssert["PRE-UNIVERSE (2) [has content]: s' = Psi'bar Psi' is conserved by the x4-only equations (d_4 Psi' = -H V' T16[4] Psi', d_4 Psi'bar = H V' Psi'bar T16[4]) for ANY V; so null data s' = 0 are solutions for any V, with rho == V(0); and for V = s^2 with s' != 0 the x0-dependence is real (witness)",
  Module[{pp = Table[cfPsiR[k][x4], {k, 0, 15}], pb = Table[cfPsiRB[k][x4], {k, 0, 15}], rl},
    rl = Join[Table[With[{kk = k}, Derivative[1][cfPsiR[kk]] -> Function[u4, Evaluate[(-H cfVp0 T16[4] . pp)[[kk + 1]] /. x4 -> u4]]], {k, 0, 15}],
      Table[With[{kk = k}, Derivative[1][cfPsiRB[kk]] -> Function[u4, Evaluate[(H cfVp0 pb . T16[4])[[kk + 1]] /. x4 -> u4]]], {k, 0, 15}]];
    {Expand[D[pb . pp, x4] /. rl] === 0,
     Expand[(T16[4] . (-H cfVp0 T16[4] . pp) - H cfVp0 pp)] === ConstantArray[0, 16], Expand[(H cfVp0 pb . T16[4]) . T16[4] + H cfVp0 pb] === ConstantArray[0, 16],
     cfZeroQ[(cfVs[Sin[6 H x0] cfSp] /. cfSp -> 0) - cfVs[0]],
     cfNonZeroWitnessQ[D[cfVs'[Sin[6 H x0] cfSp] /. cfVs -> (#^2 &), x0] /. cfSp -> -2]}]];
cfPsiUx = Table[cfUx[k][x4], {k, 0, 15}];
cfModeRule = Table[With[{kk = k}, cfPsiCA[kk] -> Function[Evaluate[X], Evaluate[Sqrt[Sin[6 H x0]] Exp[I cfKmom x1] cfUx[kk][x4]]]], {k, 0, 15}];
cfAssert["PRE-UNIVERSE (3) [THE RESULT]: for Psi = Sqrt[Sin] u(x4) Exp[i k x1] the field equation (mass term, V' = constant) is Sqrt[Sin] Exp[i k x1] (T16[4] u' + i (k/q) T16[1] u - H V' u): the physical momentum is k/q",
  cfZeroArrayQ[Expand[((cfFieldOp16 /. cfVs' -> (cfVp0 &)) /. cfModeRule)
     - Sqrt[Sin[6 H x0]] Exp[I cfKmom x1] (T16[4] . D[cfPsiUx, x4] + I (cfKmom/cfQminus) T16[1] . cfPsiUx - H cfVp0 cfPsiUx)]]];
cfAssert["PRE-UNIVERSE (3) [THE RESULT]: d Log[k/q]/dx4 == H a4'[H x4] == -H_obs (observed momenta redshift as Exp[a4]), and E^2 == (k^2/q^2 + m^2) ID16 at the physical momentum",
  {cfZeroQ[D[Log[cfKmom/cfQminus], x4] - H a4'[H x4]],
   Expand[cfEk[{0, cfKp, 0, 0, 0, 0, 0, 0}, cfMs] . cfEk[{0, cfKp, 0, 0, 0, 0, 0, 0}, cfMs] - (cfKp^2 + cfMs^2) ID16] === ConstantArray[0, {16, 16}]}];
cfAssert["PRE-UNIVERSE (4) [THE RESULT]: x = k_F,phys/m = x_c/(q m) obeys d Log[x]/dx4 == H a4'[H x4]; since dw/dx > 0, dw/dx4 = w'(x) x H a4' < 0 exactly when a4' < 0 (the observed sheet expanding): the quantum gas COOLS",
  {cfZeroQ[D[Log[cfXc/cfQminus], x4] - H a4'[H x4]],
   cfSimp60[H a4'[H x4] cfXx cfDwdx < 0, H > 0 && a4'[H x4] < 0 && cfXx > 0 && cfDwdx > 0],
   cfSimp60[H a4'[H x4] cfXx cfDwdx > 0, H > 0 && a4'[H x4] > 0 && cfXx > 0 && cfDwdx > 0]}];
cfAssert["PRE-UNIVERSE (4) [control]: the classical Part VI fable does NOT cool -- ds/dx4 == 0 on its rescaled solutions (Part VI's result, re-asserted), and its w = s V'/V - 1 is a function of s alone: frozen",
  {cfZeroQ[Expand[cfDsDx4 /. cfRescRule4]], FreeQ[cfWPsi[cfVs], x4 | x0], ! FreeQ[cfWPsi[cfVs], sPsi]}];
cfAssert["PART VII [control]: a4 is STILL UNDEFINED -- nothing in Part VII gave it a value",
  {ValueQ[a4] === False, DownValues[a4] === {}, FreeQ[frameCanonical, cfKF | cfXx | cfOm]}];
Grid[{{"quantity", "classical fable (Part VI)", "fermion fable (Part VII, Kohn-Sham, mass term)"},
  {"rho", "V(s)", "eps_KS(k_F, m) > 0"}, {"P (observed)", "s V' - V  (= 0: dust)", "P_KS in [0, rho/3]"},
  {"w", "s V'/V - 1, frozen (ds/dx4 = 0)", "P_KS/eps_KS: 1/3 -> 0 as the observed sheet expands"},
  {"8-density", "constant", "constant (charge per coordinate volume conserved)"}}, Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 198 ---------- *)
cfRunCell[198, Hold[
(* --- final tally of every assertion made in this notebook, Parts I-VII --------------------- *)
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

(* ---------- Input cell 199 ---------- *)
cfRunCell[199, Hold[
(* --- the Einstein tensor helper -------------------------------------------------------- *)
(* Gam[[r, m, p]] = Gamma^r_{m p}, the layout of cfChristoffel (Section 16).  Every entry is  *)
(* simplified at the ENTRY level (the lesson of cfSimpArray).  Returns the Ricci tensor with *)
(* both indices down, the Ricci scalar, the mixed Einstein tensor G^mu_nu and G_{mu nu}.      *)
ClearAll[cfEinsteinData, cfFrameGeometry, cfEinsteinFLRW, cfEinsteinCanonical];
cfEinsteinData[g_, gInv_, Gam_, coords_List] := Module[{n = Length[coords], ric, R, Gmix},
  ric = Table[cfSimp[Sum[D[Gam[[l, m, p]], coords[[l]]] - D[Gam[[l, m, l]], coords[[p]]], {l, n}]
        + Sum[Gam[[l, l, s]] Gam[[s, m, p]] - Gam[[l, p, s]] Gam[[s, m, l]], {l, n}, {s, n}]], {m, n}, {p, n}];
  R = cfSimp[Sum[gInv[[a, b]] ric[[a, b]], {a, n}, {b, n}]];
  Gmix = Table[cfSimp[Sum[gInv[[m, k]] ric[[k, p]], {k, n}] - (1/2) KroneckerDelta[m, p] R], {m, n}, {p, n}];
  <|"Ricci" -> ric, "R" -> R, "G" -> Gmix,
    "Gdown" -> Table[cfSimp[Sum[g[[m, k]] Gmix[[k, p]], {k, n}]], {m, n}, {p, n}]|>];
(* a frame in, everything out: metric, inverse, Christoffel symbols (Section 16's solver), Einstein *)
cfFrameGeometry[frame_, etaFlat_] := Module[{g, gi, Gam},
  g = cfSimpArray[frame . etaFlat . Transpose[frame]];
  gi = cfSimpArray[Inverse[g]];
  Gam = cfChristoffel[g, gi, X];
  <|"frame" -> frame, "g" -> g, "gInv" -> gi, "Gamma" -> Gam, "Einstein" -> cfEinsteinData[g, gi, Gam, X]|>];
cfEinsteinFLRW = cfTimed["Einstein tensor of the FLRW frame of Section 24 (the helper's regression test)",
  cfEinsteinData[gFLRW, gInvFLRW, GammaFLRW, X]];
cfAssert["EINSTEIN [solver regression]: on the FLRW frame of Section 24, G^4_4 == -3 (a'/a)^2 and G^i_i == -(2 a''/a + (a'/a)^2): the Friedmann equations with the textbook signs",
  {cfZeroQ[cfEinsteinFLRW["G"][[5, 5]] + 3 (aF'[x4]/aF[x4])^2],
   cfZeroArrayQ[Table[cfEinsteinFLRW["G"][[i, i]] + (2 aF''[x4]/aF[x4] + (aF'[x4]/aF[x4])^2), {i, 2, 4}]]}];
cfAssert["EINSTEIN [solver regression]: ... and G == -3 (a''/a + (a'/a)^2) along the four static directions x0, x5, x6, x7, with no off-diagonal component",
  {cfZeroArrayQ[Table[cfEinsteinFLRW["G"][[i, i]] + 3 (aF''[x4]/aF[x4] + (aF'[x4]/aF[x4])^2), {i, {1, 6, 7, 8}}]],
   cfZeroArrayQ[Table[If[i == j, 0, cfEinsteinFLRW["G"][[i, j]]], {i, 8}, {j, 8}]]}];
cfEinsteinCanonical = cfTimed["Einstein tensor of the canonical metric, a4 arbitrary",
  cfEinsteinData[gCanonical, gInvCanonical, GammaCanonical, X]];
cfAssert["EINSTEIN [fidelity]: the Ricci scalar from the Christoffel symbols == RicciScalarCanonical of Section 16 (from the curvature 2-form of the spin connection): two routes, one answer",
  cfZeroQ[cfEinsteinCanonical["R"] - RicciScalarCanonical]];
cfAssert["EINSTEIN [has content]: the contracted Bianchi identity nabla_mu G^mu_nu == 0 holds for the canonical Einstein tensor, all eight components, a4 arbitrary",
  cfZeroArrayQ[cfCovariantDivergence[cfEinsteinCanonical["Gdown"], gInvCanonical, GammaCanonical, X]]];
cfAssert["EINSTEIN [control]: the canonical metric is NOT a vacuum solution -- G^0_0 is not zero (witnessed)",
  cfNonZeroWitnessQ[cfEinsteinCanonical["G"][[1, 1]]]];
{cfEinsteinCanonical["R"], Count[Flatten[cfEinsteinCanonical["G"]], Except[0]], " non-zero components of G^mu_nu"}
]];

(* ---------- Input cell 200 ---------- *)
cfRunCell[200, Hold[
ClearAll[cfCot6, cfCsc6, cfA1, cfA2, cfG00Claim, cfGiiClaim, cfG44Claim, cfGhhClaim, cfRClaim, cfGCanonicalClaim,
         cfFrameX0, cfFrameA4, cfGeoX0, cfGeoA4, cfGx0, cfGa4];
cfCot6 = Cot[6 H x0];  cfCsc6 = Csc[6 H x0];  cfA1 = a4'[H x4];  cfA2 = a4''[H x4];
cfG00Claim = 3 H^2 (5 cfCot6^4 - cfA1^2);
cfGiiClaim = (H^2/2) (15 (9 + Cos[12 H x0]) cfCot6^2 cfCsc6^2 - 6 cfA1^2 - 2 cfA2);
cfG44Claim = (3 H^2/2) ((55 + 7 Cos[12 H x0]) cfCot6^2 cfCsc6^2 + 2 cfA1^2);
cfGhhClaim = (H^2/2) (15 (9 + Cos[12 H x0]) cfCot6^2 cfCsc6^2 - 6 cfA1^2 + 2 cfA2);
cfRClaim   = -3 H^2 ((55 + 7 Cos[12 H x0]) cfCot6^2 cfCsc6^2 - 2 cfA1^2);
cfGCanonicalClaim = DiagonalMatrix[{cfG00Claim, cfGiiClaim, cfGiiClaim, cfGiiClaim, cfG44Claim, cfGhhClaim, cfGhhClaim, cfGhhClaim}];
cfAssert["EINSTEIN [THE RESULT]: all 64 components of G^mu_nu of the canonical metric, a4 arbitrary: 8 diagonal ones as stated, 56 off-diagonal ones identically zero",
  cfZeroArrayQ[TrigExpand[cfEinsteinCanonical["G"] - cfGCanonicalClaim]]];
cfAssert["EINSTEIN [THE RESULT]: the Ricci scalar R == -3 H^2 ((55 + 7 Cos[12 H x0]) Cot^2 Csc^2 - 2 a4'^2)",
  cfZeroQ[TrigExpand[cfEinsteinCanonical["R"] - cfRClaim]]];
(* the two factor frames: neither is the canonical frame, neither gives a4 a value *)
cfFrameX0 = DiagonalMatrix[{Tan[6 H x0], Sin[6 H x0]^(-1/6), Sin[6 H x0]^(-1/6), Sin[6 H x0]^(-1/6), 1,
    Sin[6 H x0]^(-1/6), Sin[6 H x0]^(-1/6), Sin[6 H x0]^(-1/6)}];
cfFrameA4 = DiagonalMatrix[{1, Exp[-a4[H x4]], Exp[-a4[H x4]], Exp[-a4[H x4]], 1, Exp[a4[H x4]], Exp[a4[H x4]], Exp[a4[H x4]]}];
cfGeoX0 = cfTimed["Einstein tensor of the x0-only frame", cfFrameGeometry[cfFrameX0, \[Eta]4488]];
cfGeoA4 = cfTimed["Einstein tensor of the a4-only frame", cfFrameGeometry[cfFrameA4, \[Eta]4488]];
cfGx0 = cfGeoX0["Einstein"]["G"];  cfGa4 = cfGeoA4["Einstein"]["G"];
cfAssert["EINSTEIN [definition]: the two factor frames multiply to the canonical frame, and neither is it: the x0-only frame contains no a4, the a4-only frame contains no x0",
  {cfZeroArrayQ[cfFrameX0 . cfFrameA4 - frameCanonical], FreeQ[cfFrameX0, a4], FreeQ[cfFrameA4, x0]}];
cfAssert["EINSTEIN [THE RESULT]: NO CROSS TERMS -- G^mu_nu(canonical) == G^mu_nu(x0-only frame) + G^mu_nu(a4-only frame), all 64 components",
  cfZeroArrayQ[cfEinsteinCanonical["G"] - cfGx0 - cfGa4]];
cfAssert["EINSTEIN [has content]: the x0-part is the same on the observed and the hidden sheet (G^i_i == G^h_h), and the a4-part is x0-independent",
  {cfZeroArrayQ[Table[cfGx0[[i, i]] - cfGx0[[h, h]], {i, 2, 4}, {h, 6, 8}]], FreeQ[cfGa4, x0], FreeQ[cfGx0, a4]}];
Grid[Prepend[Table[{Row[{"G^", mu - 1, "_", mu - 1}], cfGx0[[mu, mu]], cfGa4[[mu, mu]]}, {mu, 8}],
  {"component", "x0-part (x0-only frame)", "a4-part (a4-only frame)"}], Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 201 ---------- *)
cfRunCell[201, Hold[
ClearAll[cfBoundGap, cfRhoBg];
cfBoundGap = cfEinsteinCanonical["G"][[5, 5]] - (72 H^2 cfCot6^2 cfCsc6^2 + 3 H^2 cfA1^2);
cfAssert["ENERGY [has content]: min over x0 of 55 + 7 Cos[12 H x0] is 48 (attained where Cos[12 H x0] = -1)",
  {MinValue[55 + 7 Cos[u], u] === 48, (55 + 7 Cos[u] /. u -> Pi) === 48}];
cfAssert["ENERGY [THE RESULT]: G^4_4 - (72 H^2 Cot^2 Csc^2 + 3 H^2 a4'^2) == (21/2) H^2 (1 + Cos[12 H x0]) Cot^2 Csc^2, which is >= 0",
  {cfZeroQ[TrigExpand[cfBoundGap - (21/2) H^2 (1 + Cos[12 H x0]) cfCot6^2 cfCsc6^2]],
   Simplify[(21/2) H^2 (1 + Cos[12 H x0]) cfCot6^2 cfCsc6^2 >= 0, cfGeomAssume]}];
cfAssert["ENERGY [THE RESULT]: 72 H^2 Cot^2 Csc^2 + 3 H^2 a4'^2 > 0 in 0 < 6 H x0 < Pi/2 for real a4, hence rho_total = -G^4_4/kappa < 0: the canonical metric demands NEGATIVE total energy density",
  Simplify[72 H^2 cfCot6^2 cfCsc6^2 + 3 H^2 cfA1^2 > 0, cfSignatureAssume && Element[cfA1, Reals]]];
(* the Kohn-Sham energy density of Section 29 (cfEpsKS, m > 0; it is even in m) is positive: zero at kF = 0, increasing *)
cfAssert["ENERGY [has content]: Section 29's eps_KS vanishes at kF = 0 and d eps_KS/d kF == g kF^2 wF/(2 pi^2) > 0, so the KS fable with the author's mass term (rho = eps_KS) cannot be the sole source",
  {cfSimp60[cfEpsKS /. cfKF -> 0, cfMm > 0] === 0, cfSimp60[D[cfEpsKS, cfKF] - cfGdeg cfKF^2 cfWF/(2 Pi^2), cfKSas] === 0,
   Simplify[cfGdeg cfKF^2 cfWF/(2 Pi^2) > 0, cfKSas && cfGdeg > 0]}];
cfRhoBg = -cfGx0[[5, 5]]/kappa;
cfAssert["BACKGROUND [has content]: with the splitting T_bg := G_x0/kappa, rho_bg == -(3 H^2/(2 kappa)) (55 + 7 Cos[12 H x0]) Cot^2 Csc^2 < 0 everywhere",
  {cfZeroQ[cfRhoBg + (3 H^2/(2 kappa)) (55 + 7 Cos[12 H x0]) cfCot6^2 cfCsc6^2],
   Simplify[cfRhoBg < 0, cfGeomAssume && kappa > 0 && 0 < 6 H x0 < Pi/2]}];
cfAssert["BACKGROUND [has content]: the illustration -- G_a4 is x0-independent, while the fable density of Section 24, rho = V(Sin[6 H x0] s') on Psi = Sqrt[Sin] Psi'(x4), depends on x0 for the mass term (witnessed on Psi' = e1 + e5, M = 1)",
  {FreeQ[cfGa4, x0], cfNonZeroWitnessQ[D[(cfRhoFable /. cfVs -> (-(2 M/H) # &) /. cfRescRule4 /. cfConstRuleR) /. M -> 1, x0]]}];
{cfBoundGap, cfRhoBg}
]];

(* ---------- Input cell 202 ---------- *)
cfRunCell[202, Hold[
ClearAll[cfTmixCanonical, cfKSFluid];
(* Section 29's That (cfTF) and Lhat (cfLhatC) for the independent Psi(x0, x4), Psibar(x0, x4) of Section 26, canonical frame *)
cfTmixCanonical = gInvCanonical . cfTF;
cfAssert["ANISOTROPY [THE RESULT]: G^i_i - G^h_h == -2 H^2 a4''[H x4] for every observed i and hidden h, hence a4'' == -kappa (P_obs - P_hid)/(2 H^2) for any source",
  {cfZeroArrayQ[Table[cfEinsteinCanonical["G"][[i, i]] - cfEinsteinCanonical["G"][[h, h]] + 2 H^2 cfA2, {i, 2, 4}, {h, 6, 8}]],
   cfZeroQ[(cfA2 /. Solve[cfEinsteinCanonical["G"][[2, 2]] - cfEinsteinCanonical["G"][[6, 6]] == kappa (Pobs - Phid), cfA2][[1]]) + kappa (Pobs - Phid)/(2 H^2)]}];
cfAssert["ANISOTROPY [has content]: the premise, re-checked with the index lowered -- {gamma_mu, Gamma_mu} == 0 for EACH mu separately on the canonical frame (gamma_mu = g_{mu nu} gamma^nu; Section 27 (c))",
  cfZeroArrayQ[Table[cfAnti[cfGamDn[[mu]], GammaSpinCanonical[[mu]]], {mu, 8}]]];
cfAssert["ANISOTROPY [THE RESULT]: OFF SHELL, for generic independent Psi(x0, x4), Psibar(x0, x4) and every V:  T^i_i == Lhat == T^h_h  (i = 1,2,3; h = 5,6,7), so P_obs == P_hid and such fable configurations force a4'' == 0",
  cfZeroArrayQ[Expand[Table[cfTmixCanonical[[mu, mu]] - cfLhatC, {mu, {2, 3, 4, 6, 7, 8}}]]]];
cfAssert["ANISOTROPY [control]: T^0_0 is NOT Lhat off shell -- the x0-derivatives enter it (witnessed on Psi = x0 e1, Psibar = the first column of T16[0], V = s^2): the statement is special to the directions on which the fields do not depend",
  cfNonZeroWitnessQ[(cfTmixCanonical[[1, 1]] - cfLhatC) /. cfVs -> (#^2 &) /. Join[cfVecRule[cfPsiC, u0 UnitVector[16, 1]], cfVecRule[cfPsiB, T16[0][[All, 1]]]]]];
(* the Kohn-Sham pressure of Section 29 (cfPKS) is positive *)
cfAssert["ANISOTROPY [has content]: Section 29's P_KS vanishes at kF = 0 and dP_KS/dkF == g kF^4/(6 pi^2 wF) > 0, so P_KS > 0 for kF > 0",
  {cfSimp60[cfPKS /. cfKF -> 0, cfMm > 0] === 0, cfSimp60[D[cfPKS, cfKF] - cfGdeg cfKF^4/(6 Pi^2 cfWF), cfKSas] === 0,
   Simplify[cfGdeg cfKF^4/(6 Pi^2 cfWF) > 0, cfKSas && cfGdeg > 0]}];
(* the mean-field fluid per 7-volume, Section 33: {rho, P_obs, P_hid} from eps_KS, P_KS, sigma_KS, v and W *)
cfKSFluid[eps_, p_, sig_, v_, Wf_] := With[{s7 = sig/v},
  {eps/v + Wf[s7] - s7 Wf'[s7], p/v + s7 Wf'[s7] - Wf[s7], s7 Wf'[s7] - Wf[s7]}];
cfAssert["ANISOTROPY [THE RESULT]: for the KS fluid P_obs - P_hid == P_KS/v identically, for every W: the Fermi gas CAN source a4'' < 0",
  cfZeroQ[(cfKSFluid[epsK, pK, sigK, vK, cfWpot][[2]] - cfKSFluid[epsK, pK, sigK, vK, cfWpot][[3]]) - pK/vK]];
Short[cfLhatC, 3]
]];

(* ---------- Input cell 203 ---------- *)
cfRunCell[203, Hold[
ClearAll[cfhA4, cfGhostT, cfDemanded];
cfAssert["MOMENTUM [THE RESULT]: G^0_4 == G^4_0 == 0 on the canonical frame, so T^0_4 == 0 is required of the source",
  {cfEinsteinCanonical["G"][[1, 5]] === 0, cfEinsteinCanonical["G"][[5, 1]] === 0}];
(* a concrete witness, built with Section 29's cfVecRule: Psi = x4 e1, Psibar = the first column of T16[0] (constant) *)
cfAssert["MOMENTUM [has content]: T^0_4 == 0 is a genuine condition -- fable's T_{04} is not identically zero (witnessed on Psi = x4 e1, Psibar = T16[0] e1, V = s^2)",
  cfNonZeroWitnessQ[cfTF[[1, 5]] /. cfVs -> (#^2 &) /. Join[cfVecRule[cfPsiC, u4 UnitVector[16, 1]], cfVecRule[cfPsiB, T16[0][[All, 1]]]]]];
cfhA4 = H a4'[H x4];
cfAssert["GHOST [THE RESULT]: the a4-part demands rho == P_C == -3 h^2/kappa, P_obs == rho - h'/kappa, P_hid == rho + h'/kappa, with h = H a4'[H x4], h' = dh/dx4",
  {cfZeroQ[-cfGa4[[5, 5]]/kappa + 3 cfhA4^2/kappa], cfZeroQ[cfGa4[[1, 1]]/kappa + 3 cfhA4^2/kappa],
   cfZeroArrayQ[Table[cfGa4[[i, i]]/kappa - (-3 cfhA4^2/kappa - D[cfhA4, x4]/kappa), {i, 2, 4}]],
   cfZeroArrayQ[Table[cfGa4[[h, h]]/kappa - (-3 cfhA4^2/kappa + D[cfhA4, x4]/kappa), {h, 6, 8}]]}];
(* the ghost scalar phi(x4) on the a4-only frame: L = +(1/2) g^{mn} d_m phi d_n phi, T_mn = -d_m phi d_n phi + g_mn L *)
cfGhostT = Module[{gg = cfGeoA4["g"], gi = cfGeoA4["gInv"], dphi = Table[D[phiG[x4], X[[mu]]], {mu, 8}], Lg},
  Lg = (1/2) Sum[gi[[m, n]] dphi[[m]] dphi[[n]], {m, 8}, {n, 8}];
  gi . Table[-dphi[[m]] dphi[[n]] + gg[[m, n]] Lg, {m, 8}, {n, 8}]];
cfDemanded = cfGa4/kappa;
cfAssert["GHOST [THE RESULT]: demanded stress == ghost-scalar tensor with phi'^2 = 6 h^2/kappa  +  (h'/kappa) diag(0,-1,-1,-1,0,1,1,1): negative-energy, stiff (P_C == rho), plus a traceless anisotropic part",
  cfZeroArrayQ[cfDemanded - ((cfGhostT /. phiG'[x4] -> Sqrt[6/kappa] cfhA4) + (D[cfhA4, x4]/kappa) DiagonalMatrix[{0, -1, -1, -1, 0, 1, 1, 1}])]];
cfAssert["GHOST [has content]: the ghost scalar's energy density is -phi'^2/2 < 0 and all seven of its pressures equal it",
  {cfZeroQ[-cfGhostT[[5, 5]] + phiG'[x4]^2/2], cfZeroArrayQ[Table[cfGhostT[[i, i]] + cfGhostT[[5, 5]], {i, {1, 2, 3, 4, 6, 7, 8}}]]}];
cfAssert["PART VIII [control]: a4 is STILL UNDEFINED after Section 30",
  {ValueQ[a4] === False, DownValues[a4] === {}, OwnValues[a4] === {}}];
Grid[{{"rho", "-3 h^2/kappa"}, {"P_C (x0)", "-3 h^2/kappa  = rho  (stiff)"}, {"P_obs", "rho - h'/kappa"}, {"P_hid", "rho + h'/kappa"}},
  Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 204 ---------- *)
cfRunCell[204, Hold[
ClearAll[cfWarpAssume, cfFrameWarp, cfFrameBI, cfGeoWarp, cfGeoBI, cfGWarp, cfGBI, cfRateA, cfRateB, cfRateC, cfThetaABC, cfCanonicalABC, cfSw];
cfWarpAssume = cfGeomAssume && scA[x4] > 0 && scB[x4] > 0 && scC[x4] > 0;
cfSw = Sin[6 H x0]^(-1/6);
cfFrameWarp = DiagonalMatrix[{Tan[6 H x0] scC[x4], scA[x4] cfSw, scA[x4] cfSw, scA[x4] cfSw, 1, scB[x4] cfSw, scB[x4] cfSw, scB[x4] cfSw}];
cfFrameBI   = DiagonalMatrix[{scC[x4], scA[x4], scA[x4], scA[x4], 1, scB[x4], scB[x4], scB[x4]}];
cfRateA = scA'[x4]/scA[x4];  cfRateB = scB'[x4]/scB[x4];  cfRateC = scC'[x4]/scC[x4];  cfThetaABC = 3 cfRateA + 3 cfRateB + cfRateC;
(* THE labelled substitution that recovers the canonical frame from the family (never applied to a4) *)
cfCanonicalABC = {scA -> Function[t, Exp[-a4[H t]]], scB -> Function[t, Exp[a4[H t]]], scC -> Function[t, 1]};
{cfGeoWarp, cfGeoBI} = Block[{cfGeomAssume = cfWarpAssume},
  {cfTimed["geometry and Einstein tensor of the generalized warped frame", cfFrameGeometry[cfFrameWarp, \[Eta]4488]],
   cfTimed["geometry and Einstein tensor of the 8D Bianchi-I frame", cfFrameGeometry[cfFrameBI, \[Eta]4488]]}];
cfGWarp = cfGeoWarp["Einstein"]["G"];  cfGBI = cfGeoBI["Einstein"]["G"];
cfAssert["WARPED [definition]: the canonical frame IS the member A = Exp[-a4], B = Exp[+a4], C = 1 of the family (labelled substitution)",
  cfZeroArrayQ[(cfFrameWarp /. cfCanonicalABC) - frameCanonical]];
cfAssert["WARPED [has content]: the contracted Bianchi identity nabla_mu G^mu_nu == 0 holds for the warped family, A, B, C arbitrary",
  Block[{cfGeomAssume = cfWarpAssume},
    cfZeroArrayQ[cfCovariantDivergence[cfGeoWarp["Einstein"]["Gdown"], cfGeoWarp["gInv"], cfGeoWarp["Gamma"], X]]]];
cfAssert["WARPED [THE RESULT]: diag G^mu_nu == diag G_x0/C^2 + diag G_BI(A, B, C) EXACTLY (the x0-part of Section 30 and the unwarped Bianchi-I tensor)",
  Block[{cfGeomAssume = cfWarpAssume}, cfZeroArrayQ[Diagonal[cfGWarp] - (Diagonal[cfGx0]/scC[x4]^2 + Diagonal[cfGBI])]]];
cfAssert["WARPED [THE RESULT]: the only off-diagonal components are G^4_0 == 3 H Cot (2 H_C - H_A - H_B) and G^0_4 == -3 H Cot^3 (2 H_C - H_A - H_B)/C^2",
  Block[{cfGeomAssume = cfWarpAssume},
    {cfZeroQ[cfGWarp[[5, 1]] - 3 H cfCot6 (2 cfRateC - cfRateA - cfRateB)], cfZeroQ[cfGWarp[[1, 5]] + 3 H cfCot6^3 (2 cfRateC - cfRateA - cfRateB)/scC[x4]^2],
     cfZeroArrayQ[Table[If[i == j || {i, j} === {1, 5} || {i, j} === {5, 1}, 0, cfGWarp[[i, j]]], {i, 8}, {j, 8}]]}]];
cfAssert["WARPED [fidelity]: on the canonical member the warped Einstein tensor IS Section 30's, all 64 components, and the Bianchi-I part IS Section 30's a4-part",
  {cfZeroArrayQ[(cfGWarp /. cfCanonicalABC) - cfEinsteinCanonical["G"]], cfZeroArrayQ[(cfGBI /. cfCanonicalABC) - cfGa4]}];
Grid[Prepend[Table[{Row[{"G^", mu - 1, "_", mu - 1}], cfGBI[[mu, mu]]}, {mu, 8}], {"component", "Bianchi-I part G_BI(A, B, C)"}],
  Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 205 ---------- *)
cfRunCell[205, Hold[
ClearAll[cfPairs];
cfPairs = 3 cfRateA^2 + 3 cfRateB^2 + 9 cfRateA cfRateB + 3 cfRateA cfRateC + 3 cfRateB cfRateC;
cfAssert["(0,4) [THE RESULT]: with T^4_0 = 0 the (0,4) Einstein equation is 2 H_C == H_A + H_B (Cot[6 H x0] is not zero for 0 < 6 H x0 < Pi/2)",
  {cfZeroQ[cfGWarp[[5, 1]]/(3 H cfCot6) - (2 cfRateC - cfRateA - cfRateB)], Simplify[cfCot6 > 0, cfGeomAssume && 0 < 6 H x0 < Pi/2]}];
cfAssert["(0,4) [THE RESULT]: with C = 1 (labelled substitution) it reads H_A + H_B == 0, i.e. d(A B)/dx4 == 0: the volume-preserving pairing is SINGLED OUT, and the canonical member satisfies it",
  {cfZeroQ[(cfGWarp[[5, 1]] /. scC -> Function[t, 1]) + 3 H cfCot6 D[Log[scA[x4] scB[x4]], x4]],
   cfZeroQ[(cfGWarp[[5, 1]]) /. cfCanonicalABC]}];
cfAssert["(0,4) [has content]: kappa rho == -G^4_4 == -G_x0^4_4/C^2 + (sum over the 21 pairs of the seven directions of H_i H_j)",
  Block[{cfGeomAssume = cfWarpAssume}, cfZeroQ[-cfGWarp[[5, 5]] - (-cfGx0[[5, 5]]/scC[x4]^2 + cfPairs)]]];
cfAssert["(0,4) [THE RESULT]: the pair sum is -3 H_A^2 on the volume-preserving branch (negative energy) and (9/2)(H_A^2 + H_B^2) + 12 H_A H_B on the branch H_C = (H_A + H_B)/2, i.e. +(9/2) H_A^2 > 0 for a static hidden sheet",
  {cfZeroQ[(cfPairs /. {scB -> Function[t, 1/scA[t]], scC -> Function[t, 1]}) + 3 cfRateA^2],
   cfZeroQ[(cfPairs /. scC -> Function[t, Sqrt[scA[t] scB[t]]]) - ((9/2) (cfRateA^2 + cfRateB^2) + 12 cfRateA cfRateB)],
   cfZeroQ[(cfPairs /. {scC -> Function[t, Sqrt[scA[t]]], scB -> Function[t, 1]}) - (9/2) cfRateA^2]}];
cfPairs
]];

(* ---------- Input cell 206 ---------- *)
cfRunCell[206, Hold[
ClearAll[cfZofX0, cfX0ofZ, cfGzz, cfLimX0, cfTbgMix, cfTbgTrace, cfBgDriver];
cfZofX0 = Integrate[Tan[6 H y], {y, 0, x0}, Assumptions -> H > 0 && 0 < 6 H x0 < Pi/2];
cfX0ofZ = ArcCos[Exp[-6 H zP]]/(6 H);
cfAssert["ASYMPTOTIC [definition]: z = Int_0^x0 Tan[6 H y] dy == -Log[Cos[6 H x0]]/(6 H), and x0(z) = ArcCos[Exp[-6 H z]]/(6 H) inverts it",
  {cfZeroQ[cfZofX0 + Log[Cos[6 H x0]]/(6 H)], Simplify[(-Log[Cos[6 H x0]]/(6 H)) /. x0 -> cfX0ofZ, H > 0 && zP > 0] === zP}];
cfGzz = cfGeoWarp["g"][[1, 1]] (1/D[cfZofX0, x0])^2;
cfAssert["ASYMPTOTIC [THE RESULT]: in the coordinate z, g_zz == C^2 exactly and g_ii = A^2 (1 - Exp[-12 H z])^(-1/6), g_hh = -B^2 (1 - Exp[-12 H z])^(-1/6): the metric tends to the unwarped Bianchi-I metric",
  {cfZeroQ[cfGzz - scC[x4]^2],
   Simplify[(cfGeoWarp["g"][[2, 2]] /. x0 -> cfX0ofZ) - scA[x4]^2 (1 - Exp[-12 H zP])^(-1/6), H > 0 && zP > 0 && scA[x4] > 0] === 0,
   Simplify[(cfGeoWarp["g"][[6, 6]] /. x0 -> cfX0ofZ) + scB[x4]^2 (1 - Exp[-12 H zP])^(-1/6), H > 0 && zP > 0 && scB[x4] > 0] === 0}];
cfAssert["ASYMPTOTIC [has content]: Cot[6 H x0]^2 == Exp[-12 H z]/(1 - Exp[-12 H z]): every x0-term decays like Exp[-12 H z]",
  Simplify[(Cot[6 H x0]^2 /. x0 -> cfX0ofZ) - Exp[-12 H zP]/(1 - Exp[-12 H zP]), H > 0 && zP > 0] === 0];
cfLimX0[e_] := Limit[e, x0 -> Pi/(12 H), Direction -> "FromBelow", Assumptions -> H > 0];
cfAssert["ASYMPTOTIC [THE RESULT]: decay rates as 6 H x0 -> Pi/2: G_x0^0_0/Cot^4 -> 15 H^2, G_x0^i_i/Cot^2 -> 60 H^2, G_x0^h_h/Cot^2 -> 60 H^2, G_x0^4_4/Cot^2 -> 72 H^2; G^4_0/Cot and G^0_4/Cot^3 are free of x0",
  {cfLimX0[cfGx0[[1, 1]]/cfCot6^4] === 15 H^2, cfLimX0[cfGx0[[2, 2]]/cfCot6^2] === 60 H^2, cfLimX0[cfGx0[[6, 6]]/cfCot6^2] === 60 H^2,
   cfLimX0[cfGx0[[5, 5]]/cfCot6^2] === 72 H^2,
   FreeQ[Simplify[cfGWarp[[5, 1]]/cfCot6, cfWarpAssume], x0], FreeQ[Simplify[cfGWarp[[1, 5]]/cfCot6^3, cfWarpAssume], x0]}];
(* the background stress T_bg = G_x0/(kappa C^2) and its residual drivers kappa (P_i - T/6) *)
cfTbgMix = Diagonal[cfGx0]/(kappa scC[x4]^2);
cfTbgTrace = Total[cfTbgMix];
cfBgDriver = kappa (cfTbgMix - cfTbgTrace/6);
cfAssert["ASYMPTOTIC [THE RESULT]: in units of H^2 Cot^2/(kappa C^2): rho_bg -> -72, P_obs = P_hid -> 60, P_C/Cot^2 -> 15",
  {cfLimX0[(-cfTbgMix[[5]])/(H^2 cfCot6^2/(kappa scC[x4]^2))] === -72, cfLimX0[cfTbgMix[[2]]/(H^2 cfCot6^2/(kappa scC[x4]^2))] === 60,
   cfLimX0[cfTbgMix[[6]]/(H^2 cfCot6^2/(kappa scC[x4]^2))] === 60, cfLimX0[cfTbgMix[[1]]/(H^2 cfCot6^4/(kappa scC[x4]^2))] === 15}];
cfAssert["ASYMPTOTIC [THE RESULT]: residual drivers kappa (P_i - T/6)|bg -> -12 H^2 Cot^2/C^2 for A and B, and -72 H^2 Cot^2/C^2 for C (if T_bg is not counted as a source)",
  {cfLimX0[cfBgDriver[[2]]/(H^2 cfCot6^2/scC[x4]^2)] === -12, cfLimX0[cfBgDriver[[6]]/(H^2 cfCot6^2/scC[x4]^2)] === -12,
   cfLimX0[cfBgDriver[[1]]/(H^2 cfCot6^2/scC[x4]^2)] === -72}];
cfAssert["ASYMPTOTIC [THE RESULT]: validity of 'present universe = Bianchi-I': kappa |rho_bg|/(3 H_A^2) divided by 24 (H/H_A)^2 Cot^2/C^2 -> 1",
  cfLimX0[(cfTbgMix[[5]] kappa/(3 hAobs^2))/(24 (H/hAobs)^2 cfCot6^2/scC[x4]^2)] === 1];
{cfZofX0, cfLimX0[cfGx0[[5, 5]]/cfCot6^2]}
]];

(* ---------- Input cell 207 ---------- *)
cfRunCell[207, Hold[
ClearAll[cfGeoBIflip, cfTsrc, cfTsrcTrace, cfEinsteinSol, cfTBIdown, cfDivTBI];
cfGeoBIflip = Block[{cfGeomAssume = cfWarpAssume},
  cfTimed["Bianchi-I frame with the hidden directions made SPACELIKE (eta -> diag(1,1,1,1,-1,1,1,1))",
    cfFrameGeometry[cfFrameBI, DiagonalMatrix[{1, 1, 1, 1, -1, 1, 1, 1}]]]];
cfAssert["BIANCHI-I [THE RESULT]: the mixed Einstein tensor does NOT depend on the signs of the hidden directions (timelike x5..x7 or spacelike: identical G^mu_nu)",
  cfZeroArrayQ[cfGeoBIflip["Einstein"]["G"] - cfGBI]];
cfAssert["BIANCHI-I [THE RESULT]: -G^4_4 == 3 H_A^2 + 3 H_B^2 + 9 H_A H_B + 3 H_A H_C + 3 H_B H_C == (Theta^2 - Sum_i H_i^2)/2, the sum over the 21 pairs of the seven directions",
  {cfZeroQ[-cfGBI[[5, 5]] - cfPairs], cfZeroQ[cfPairs - (cfThetaABC^2 - (3 cfRateA^2 + 3 cfRateB^2 + cfRateC^2))/2]}];
cfAssert["BIANCHI-I [has content]: R^i_i == H_i' + H_i Theta for i = A (x1), B (x5), C (x0), and R^4_4 == Sum over the seven directions of (H_i' + H_i^2)",
  Module[{Rmix = cfGeoBI["gInv"] . cfGeoBI["Einstein"]["Ricci"]},
    {cfZeroQ[Rmix[[2, 2]] - (D[cfRateA, x4] + cfRateA cfThetaABC)], cfZeroQ[Rmix[[6, 6]] - (D[cfRateB, x4] + cfRateB cfThetaABC)],
     cfZeroQ[Rmix[[1, 1]] - (D[cfRateC, x4] + cfRateC cfThetaABC)],
     cfZeroQ[Rmix[[5, 5]] - (3 (D[cfRateA, x4] + cfRateA^2) + 3 (D[cfRateB, x4] + cfRateB^2) + D[cfRateC, x4] + cfRateC^2)]}]];
cfTsrc = {PC, Pobs, Pobs, Pobs, -rho, Phid, Phid, Phid};  cfTsrcTrace = Total[cfTsrc];
cfEinsteinSol = Solve[Thread[{cfGBI[[1, 1]], cfGBI[[2, 2]], cfGBI[[5, 5]], cfGBI[[6, 6]]} == kappa {PC, Pobs, -rho, Phid}], {rho, Pobs, Phid, PC}][[1]];
cfAssert["BIANCHI-I [THE RESULT]: G^mu_nu == kappa T^mu_nu is EQUIVALENT to the constraint sum-over-pairs == kappa rho plus the evolution equations H_i' + H_i Theta == kappa (P_i - T/6), i = A, B, C",
  {cfZeroQ[(kappa rho /. cfEinsteinSol) - cfPairs],
   cfZeroQ[((D[cfRateA, x4] + cfRateA cfThetaABC) - kappa (Pobs - cfTsrcTrace/6)) /. cfEinsteinSol],
   cfZeroQ[((D[cfRateB, x4] + cfRateB cfThetaABC) - kappa (Phid - cfTsrcTrace/6)) /. cfEinsteinSol],
   cfZeroQ[((D[cfRateC, x4] + cfRateC cfThetaABC) - kappa (PC - cfTsrcTrace/6)) /. cfEinsteinSol]}];
(* the conservation law: nabla^mu T_{mu nu} of the diagonal fluid on the Bianchi-I metric *)
cfTBIdown = cfGeoBI["g"] . DiagonalMatrix[{PCf[x4], Pobsf[x4], Pobsf[x4], Pobsf[x4], -rhof[x4], Phidf[x4], Phidf[x4], Phidf[x4]}];
cfDivTBI = cfCovariantDivergence[cfTBIdown, cfGeoBI["gInv"], cfGeoBI["Gamma"], X];
cfAssert["BIANCHI-I [THE RESULT]: 8D conservation for anisotropic pressures -- nabla_mu T^mu_4 == -(rho' + 3 H_A (rho + P_obs) + 3 H_B (rho + P_hid) + H_C (rho + P_C)), and the other seven components vanish identically",
  {cfZeroQ[cfDivTBI[[5]] + (rhof'[x4] + 3 cfRateA (rhof[x4] + Pobsf[x4]) + 3 cfRateB (rhof[x4] + Phidf[x4]) + cfRateC (rhof[x4] + PCf[x4]))],
   cfZeroArrayQ[Delete[cfDivTBI, 5]]}];
Grid[{{"constraint", Row[{cfPairs, "  ==  kappa rho"}]}, {"evolution", "H_i' + H_i Theta == kappa (P_i - T/6),  i = A, B, C"},
      {"conservation", "rho' + 3 H_A (rho + P_obs) + 3 H_B (rho + P_hid) + H_C (rho + P_C) == 0"}}, Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 208 ---------- *)
cfRunCell[208, Hold[
ClearAll[cfOmegaWarpMixed, cfOmegaWarp, cfOmegaBIMixed, cfOmegaBI, cfGsWarp, cfGsBI, cfGamUpWarp, cfGamUpBI, cfOmegaFromList,
         cfOmegaWarpList, cfOmegaBIList];
{cfOmegaWarpMixed, cfOmegaBIMixed} = Block[{cfGeomAssume = cfWarpAssume},
  {cfTimed["spin connection of the warped frame, vielbein postulate (Section 16's solver)", cfSpinConnection[cfFrameWarp, X, \[Eta]4488, cfGeoWarp["Gamma"]]],
   cfTimed["spin connection of the Bianchi-I frame", cfSpinConnection[cfFrameBI, X, \[Eta]4488, cfGeoBI["Gamma"]]]}];
cfOmegaWarp = cfLowerFirstFlat[cfOmegaWarpMixed, \[Eta]4488];
cfOmegaBI   = cfLowerFirstFlat[cfOmegaBIMixed, \[Eta]4488];
cfAssert["SPIN CONNECTION [solver regression]: the vielbein-postulate residual is zero on the warped and on the Bianchi-I frame",
  Block[{cfGeomAssume = cfWarpAssume},
    {cfZeroArrayQ[cfVielbeinResidual[cfFrameWarp, X, cfGeoWarp["Gamma"], cfOmegaWarpMixed]],
     cfZeroArrayQ[cfVielbeinResidual[cfFrameBI, X, cfGeoBI["Gamma"], cfOmegaBIMixed]]}]];
cfAssert["SPIN CONNECTION [has content]: omega_mu[a,b] == -omega_mu[b,a] on both frames (metric compatibility)",
  Block[{cfGeomAssume = cfWarpAssume},
    {cfZeroArrayQ[Table[cfOmegaWarp[[mu, a, b]] + cfOmegaWarp[[mu, b, a]], {mu, 8}, {a, 8}, {b, 8}]],
     cfZeroArrayQ[Table[cfOmegaBI[[mu, a, b]] + cfOmegaBI[[mu, b, a]], {mu, 8}, {a, 8}, {b, 8}]]}]];
(* the stated lists, {mu, a, b, value} with 0-based indices and a < b, turned into full antisymmetric arrays *)
cfOmegaFromList[lst_] := Module[{om = ConstantArray[0, {8, 8, 8}]},
  Scan[(om[[#[[1]] + 1, #[[2]] + 1, #[[3]] + 1]] = #[[4]]; om[[#[[1]] + 1, #[[3]] + 1, #[[2]] + 1]] = -#[[4]]) &, lst]; om];
cfOmegaWarpList = Join[{{0, 0, 4, Tan[6 H x0] scC'[x4]}},
  Flatten[Table[{{i, 0, i, H Cos[6 H x0]^2 scA[x4]/(scC[x4] Sin[6 H x0]^(13/6))}, {i, i, 4, scA'[x4]/Sin[6 H x0]^(1/6)}}, {i, 1, 3}], 1],
  Flatten[Table[{{h, 0, h, -H Cos[6 H x0]^2 scB[x4]/(scC[x4] Sin[6 H x0]^(13/6))}, {h, 4, h, scB'[x4]/Sin[6 H x0]^(1/6)}}, {h, 5, 7}], 1]];
cfOmegaBIList = Join[{{0, 0, 4, scC'[x4]}}, Table[{i, i, 4, scA'[x4]}, {i, 1, 3}], Table[{h, 4, h, scB'[x4]}, {h, 5, 7}]];
cfAssert["SPIN CONNECTION [THE RESULT]: the complete list of non-zero omega_mu^{ab} of the WARPED frame is the thirteen stated components (and their antisymmetric partners) -- nothing else",
  Block[{cfGeomAssume = cfWarpAssume}, cfZeroArrayQ[cfOmegaWarp - cfOmegaFromList[cfOmegaWarpList]]]];
cfAssert["SPIN CONNECTION [THE RESULT]: the complete list for the Bianchi-I frame is omega_0^{04} = C', omega_i^{i4} = A', omega_h^{4h} = B' -- nothing else",
  cfZeroArrayQ[cfOmegaBI - cfOmegaFromList[cfOmegaBIList]]];
cfAssert["SPIN CONNECTION [fidelity]: on the canonical member (labelled substitution) the warped connection IS omegaCanonical of Section 16, and the new component omega_0^{04} vanishes there",
  {cfZeroArrayQ[(cfOmegaWarp /. cfCanonicalABC) - omegaCanonical], (cfOmegaWarp[[1, 1, 5]] /. cfCanonicalABC) === 0}];
{cfGsWarp, cfGsBI} = Block[{cfGeomAssume = cfWarpAssume},
  {Table[cfSimpArray[cfSpinMatrix[cfOmegaWarp, mu]], {mu, 8}], Table[cfSimpArray[cfSpinMatrix[cfOmegaBI, mu]], {mu, 8}]}];
cfGamUpWarp = Block[{cfGeomAssume = cfWarpAssume}, Table[cfSimpArray[Sum[Inverse[cfFrameWarp][[a, mu]] T16[a - 1], {a, 8}]], {mu, 8}]];
cfGamUpBI   = Block[{cfGeomAssume = cfWarpAssume}, Table[cfSimpArray[Sum[Inverse[cfFrameBI][[a, mu]] T16[a - 1], {a, 8}]], {mu, 8}]];
cfAssert["SPIN CONNECTION [has content]: Gamma_mu rotates the Dirac matrices as omega rotates a vector, [Gamma_mu, T16[a]] == -omega_mu^a_b T16[b], on the warped frame",
  Block[{cfGeomAssume = cfWarpAssume},
    cfZeroArrayQ[Table[cfGsWarp[[mu]] . T16[a - 1] - T16[a - 1] . cfGsWarp[[mu]] + Sum[cfOmegaWarpMixed[[mu, a, b]] T16[b - 1], {b, 8}], {mu, 8}, {a, 8}]]]];
cfAssert["SPIN CONNECTION [has content]: the curved gamma^mu are covariantly constant on the warped frame, D_mu gamma^nu == 0",
  Block[{cfGeomAssume = cfWarpAssume},
    cfZeroArrayQ[Table[D[cfGamUpWarp[[nu]], X[[mu]]] + Sum[cfGeoWarp["Gamma"][[nu, mu, r]] cfGamUpWarp[[r]], {r, 8}]
        + cfGsWarp[[mu]] . cfGamUpWarp[[nu]] - cfGamUpWarp[[nu]] . cfGsWarp[[mu]], {mu, 8}, {nu, 8}]]]];
Grid[Prepend[Map[{Row[{"omega_", #[[1]], "^{", #[[2]], #[[3]], "}"}], #[[4]]} &, cfOmegaWarpList], {"warped frame", "value"}],
  Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 209 ---------- *)
cfRunCell[209, Hold[
ClearAll[cfGGWarp, cfGGBI, cfGamDnWarp, cfGamDnBI, cfWitABC, cfTorsWarp, cfTorsWarpCurved, cfTvecWarp, cfPotWarp,
         cfRescWarp, cfDiracWarp, cfSqrtgWarp, cfAntiWarp];
cfGGWarp = Block[{cfGeomAssume = cfWarpAssume}, cfSimpArray[Sum[cfGamUpWarp[[mu]] . cfGsWarp[[mu]], {mu, 8}]]];
cfGGBI   = Block[{cfGeomAssume = cfWarpAssume}, cfSimpArray[Sum[cfGamUpBI[[mu]] . cfGsBI[[mu]], {mu, 8}]]];
cfAssert["DIRAC [THE RESULT]: gamma^mu Gamma_mu == -(3 H Cot^2/C) T16[0] + (1/2)(3 H_A + 3 H_B + H_C) gamma^4 on the warped frame, and gamma^4 == T16[4]",
  Block[{cfGeomAssume = cfWarpAssume},
    {cfZeroArrayQ[cfGGWarp - (-(3 H cfCot6^2/scC[x4]) T16[0] + (1/2) cfThetaABC cfGamUpWarp[[5]])], cfGamUpWarp[[5]] === T16[4]}]];
cfAssert["DIRAC [control]: the opposite sign of the Hubble term FAILS (witnessed on A = 1 + x4/2, B = 1 + x4/3, C = 1 + x4^2/3)",
  cfNonZeroWitnessQ[(cfGGWarp - (-(3 H cfCot6^2/scC[x4]) T16[0] - (1/2) cfThetaABC cfGamUpWarp[[5]])) /.
     {scA -> Function[t, 1 + t/2], scB -> Function[t, 1 + t/3], scC -> Function[t, 1 + t^2/3]}]];
cfAssert["DIRAC [THE RESULT]: on the Bianchi-I frame gamma^mu Gamma_mu == (1/2)(3 H_A + 3 H_B + H_C) T16[4]: the pure Hubble term of an expanding 7-volume",
  cfZeroArrayQ[cfGGBI - (1/2) cfThetaABC T16[4]]];
cfGamDnWarp = Table[Sum[cfGeoWarp["g"][[mu, nu]] cfGamUpWarp[[nu]], {nu, 8}], {mu, 8}];
cfGamDnBI   = Table[Sum[cfGeoBI["g"][[mu, nu]] cfGamUpBI[[nu]], {nu, 8}], {mu, 8}];
cfAssert["DIRAC [THE RESULT]: {gamma_mu, Gamma_mu} == 0 for EACH mu separately, on the warped and on the Bianchi-I frame",
  Block[{cfGeomAssume = cfWarpAssume},
    {cfZeroArrayQ[Table[cfGamDnWarp[[mu]] . cfGsWarp[[mu]] + cfGsWarp[[mu]] . cfGamDnWarp[[mu]], {mu, 8}]],
     cfZeroArrayQ[Table[cfGamDnBI[[mu]] . cfGsBI[[mu]] + cfGsBI[[mu]] . cfGamDnBI[[mu]], {mu, 8}]]}]];
cfAssert["DIRAC [THE RESULT]: hence Section 26's symmetrized Lagrangian is the same with D_mu as with d_mu on the warped frame, for Psi, Psibar of all eight coordinates (cfPsiC8, cfPsiB8) and every V",
  Expand[cfLhatFermion[cfPsiC8, cfPsiB8, cfGamUpWarp, cfGsWarp, cfVs] - cfLhatFermion[cfPsiC8, cfPsiB8, cfGamUpWarp, cfZeroSpin, cfVs]] === 0];
cfWitABC = {scA -> Function[t, 1 + t/2], scB -> Function[t, 1 + t/3], scC -> Function[t, 1 + t^2/3]};
cfAssert["DIRAC [THE RESULT]: Gamma_x4 == 0, and Gamma_x0 == (1/2) Tan[6 H x0] C'(x4) T16[0].T16[4], which is NOT zero when C varies (witnessed on C = 1 + x4^2/3)",
  {cfZeroArrayQ[cfGsWarp[[5]]], cfZeroArrayQ[cfGsWarp[[1]] - (1/2) Tan[6 H x0] scC'[x4] T16[0] . T16[4]],
   cfNonZeroWitnessQ[cfGsWarp[[1]] /. cfWitABC]}];
(* (iv) the Weitzenboeck torsion of the warped frame, as in Part V: omega = 0, T^a_{mu nu} = d_mu e_nu^a - d_nu e_mu^a *)
cfTorsWarp = Block[{cfGeomAssume = cfWarpAssume}, cfTimed["Weitzenboeck torsion of the warped frame (Part V's cfTorsion with omega = 0)",
  cfTorsion[cfFrameWarp, X, ConstantArray[0, {8, 8, 8}]]]];
cfTorsWarpCurved = Block[{cfGeomAssume = cfWarpAssume},
  cfSimpArray @ Table[Sum[Inverse[cfFrameWarp][[a, r]] cfTorsWarp[[a, m, p]], {a, 8}], {r, 8}, {m, 8}, {p, 8}]];
cfTvecWarp = Block[{cfGeomAssume = cfWarpAssume}, cfSimpArray @ Table[Sum[cfTorsWarpCurved[[nu, nu, mu]], {nu, 8}], {mu, 8}]];
cfPotWarp = Log[Sin[6 H x0]/(scA[x4]^3 scB[x4]^3 scC[x4])];
cfAssert["WEITZENBOECK [THE RESULT]: the torsion vector of the warped frame is a GRADIENT, T_mu == d_mu Log[Sin[6 H x0]/(A^3 B^3 C)]; on the canonical member it is Part V's torsionVectorFable51",
  Block[{cfGeomAssume = cfWarpAssume},
    {cfZeroArrayQ[cfTvecWarp - Table[D[cfPotWarp, X[[mu]]], {mu, 8}]], cfZeroArrayQ[(cfTvecWarp /. cfCanonicalABC) - torsionVectorFable51]}]];
cfAssert["WEITZENBOECK [THE RESULT]: gamma^mu Gamma_mu == -(1/2) T_mu gamma^mu on the warped frame -- one vector term, a gradient",
  Block[{cfGeomAssume = cfWarpAssume}, cfZeroArrayQ[cfGGWarp + (1/2) Sum[cfTvecWarp[[mu]] cfGamUpWarp[[mu]], {mu, 8}]]]];
cfRescWarp = Sqrt[Sin[6 H x0]] (scA[x4]^3 scB[x4]^3 scC[x4])^(-1/2);
cfDiracWarp[psi_List] := Sum[cfGamUpWarp[[mu]] . (D[psi, X[[mu]]] + cfGsWarp[[mu]] . psi), {mu, 8}];
cfAssert["RESCALING [THE RESULT]: gamma^mu D_mu [Sqrt[Sin[6 H x0]] (A^3 B^3 C)^(-1/2) chi] == Sqrt[Sin[6 H x0]] (A^3 B^3 C)^(-1/2) gamma^mu d_mu chi for a GENERIC chi(x0, ..., x7): the connection is removed exactly",
  Block[{cfGeomAssume = cfWarpAssume},
    cfZeroArrayQ[cfDiracWarp[cfRescWarp cfPsiP8] - cfRescWarp Sum[cfGamUpWarp[[mu]] . D[cfPsiP8, X[[mu]]], {mu, 8}]]]];
(* Sqrt[|det g|] = |det e|, and det e > 0 in the domain: no square root of a symbolic square is taken *)
cfSqrtgWarp = Det[cfFrameWarp];
cfAssert["RESCALING [has content]: det g == (det e)^2 and det e == Tan[6 H x0] C A^3 B^3 / Sin[6 H x0] > 0, so Sqrt[|det g|] == Tan[6 H x0] C A^3 B^3 / Sin[6 H x0] on the warped frame",
  Block[{cfGeomAssume = cfWarpAssume},
    {cfZeroQ[Det[cfGeoWarp["g"]] - cfSqrtgWarp^2], cfZeroQ[cfSqrtgWarp - Tan[6 H x0] scC[x4] scA[x4]^3 scB[x4]^3/Sin[6 H x0]],
     Simplify[cfSqrtgWarp > 0, cfWarpAssume && 0 < 6 H x0 < Pi/2]}]];
cfAssert["RESCALING [has content]: on the warped frame G = -i sigma16 gamma^4 is Section 28's cfGK (= J) -- the same matrix on every member of the family (gamma^4 == T16[4], lapse 1)",
  {-I \[Sigma]16 . cfGamUpWarp[[5]] === cfGK, cfGK === cfJK, cfGeoWarp["g"][[5, 5]] === -1}];
(* Section 28's Dirac-bracket anticommutator for K = c sigma16 T16[4], with c = Sqrt[|det g|]/H of the warped frame *)
cfAntiWarp = cfAntiPsiPsiDd /. cfCK -> cfSqrtgWarp/H;
cfAssert["RESCALING [THE RESULT]: {Psi, Psi^ddag} == (H/Sqrt[|det g|]) G on the warped frame (Section 28's cfAntiPsiPsiDd at c = Sqrt[|det g|]/H), and for chi = Psi/f, f = Sqrt[Sin] (A^3 B^3 C)^(-1/2): {chi, chi^ddag} == H Cot[6 H x0] G -- the Sqrt[det g] cancels, independent of x4 and of A, B, C",
  Block[{cfGeomAssume = cfWarpAssume},
    {cfZeroArrayQ[cfAntiWarp - (H/cfSqrtgWarp) cfGK], cfZeroArrayQ[cfAntiWarp/cfRescWarp^2 - H Cot[6 H x0] cfGK],
     cfZeroArrayQ[((cfAntiWarp/cfRescWarp^2) /. cfCanonicalABC) - H Cot[6 H x0] cfJK]}]];
Grid[{{"gamma^mu Gamma_mu (warped)", "-(3 H Cot^2/C) T16[0] + (1/2)(3 H_A + 3 H_B + H_C) T16[4]"},
      {"torsion vector", cfTvecWarp[[{1, 5}]]}, {"rescaling factor", cfRescWarp}, {"{chi, chi^dagger}", "H Cot[6 H x0] G delta^7"}},
  Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 210 ---------- *)
cfRunCell[210, Hold[
(* J = cfJK and the tests cfJCommQ, cfJAntiQ are Section 28's *)
cfAssert["J [definition]: Section 28's J = -i T16[0]...T16[4] is Hermitian with J^2 == 1; it commutes with T16[0..4] and anticommutes with T16[5..7]",
  {ConjugateTranspose[cfJK] === cfJK, cfJK . cfJK === ID16, Table[cfJK . T16[a] === T16[a] . cfJK, {a, 0, 4}], Table[cfJK . T16[a] === -T16[a] . cfJK, {a, 5, 7}]}];
cfAssert["J [THE RESULT]: [J, gamma^mu Gamma_mu] == 0 for EACH mu separately (h = 5,6,7 included), on the warped and on the Bianchi-I frame",
  Block[{cfGeomAssume = cfWarpAssume},
    {Table[cfJCommQ[cfGamUpWarp[[mu]] . cfGsWarp[[mu]]], {mu, 8}], Table[cfJCommQ[cfGamUpBI[[mu]] . cfGsBI[[mu]]], {mu, 8}]}]];
cfAssert["J [THE RESULT]: [J, Gamma_mu] == 0 for mu = 0..4 and {J, Gamma_h} == 0 for h = 5, 6, 7, on the warped and on the Bianchi-I frame",
  Block[{cfGeomAssume = cfWarpAssume},
    {Table[cfJCommQ[cfGsWarp[[mu]]], {mu, 1, 5}], Table[cfJAntiQ[cfGsWarp[[mu]]], {mu, 6, 8}],
     Table[cfJCommQ[cfGsBI[[mu]]], {mu, 1, 5}], Table[cfJAntiQ[cfGsBI[[mu]]], {mu, 6, 8}]}]];
cfAssert["J [has content]: the anticommuting Gamma_h are not zero (witnessed on A = 1 + x4/2, B = 1 + x4/3, C = 1 + x4^2/3), so {J, Gamma_h} == 0 is not vacuous",
  cfNonZeroWitnessQ[Table[cfGsWarp[[mu]], {mu, 6, 8}] /. cfWitABC]];
cfAssert["RECOVERY [fidelity]: on the canonical member (labelled substitution) Gamma_mu IS Section 17's GammaSpinCanonical for every mu, and gamma^mu Gamma_mu IS Section 24's -3 H Cot^2 T16[0]",
  {cfZeroArrayQ[(cfGsWarp /. cfCanonicalABC) - GammaSpinCanonical], cfZeroArrayQ[(cfGGWarp /. cfCanonicalABC) + 3 H cfCot6^2 T16[0]]}];
cfAssert["RECOVERY [THE RESULT]: the Hubble coefficient 3 H_A + 3 H_B + H_C vanishes on the canonical member -- the canonical 7-volume is constant in x4, which is why Part VI had no dilution",
  cfZeroQ[cfThetaABC /. cfCanonicalABC]];
cfAssert["PART VIII [control]: a4 is STILL UNDEFINED after Section 32, and the scale factors scA, scB, scC have no values either",
  {ValueQ[a4] === False, DownValues[a4] === {}, {ValueQ[scA], ValueQ[scB], ValueQ[scC]} === {False, False, False}, {DownValues[scA], DownValues[scB], DownValues[scC]} === {{}, {}, {}}}];
Grid[{{"mu", "0", "1-3", "4", "5-7"}, {"[J, Gamma_mu]", "0", "0", "0 (Gamma_4 = 0)", "anticommutes"}, {"[J, gamma^mu Gamma_mu]", "0", "0", "0", "0"}},
  Frame -> All, Alignment -> Center]
]];

(* ---------- Input cell 211 ---------- *)
cfRunCell[211, Hold[
ClearAll[cfFluid7, cfWtilde];
(* the fluid per 7-volume, built from Section 29's closed forms and Section 30's cfKSFluid *)
cfFluid7[k_, m_, v_, Wf_] := cfKSFluid[cfEpsKS, cfPKS, cfSigKS, v, Wf] /. {cfKF -> k, cfMm -> m};
cfAssert["KS FLUID [fidelity]: at v = 1 the fluid IS Section 29's mean field: rho = eps_KS + W - sigma W', P_obs = P_KS + sigma W' - W, P_hid = sigma W' - W",
  cfFluid7[cfKF, cfMm, 1, cfWpot] === {cfEpsKS + cfWpot[cfSigKS] - cfSigKS cfWpot'[cfSigKS], cfPKS + cfSigKS cfWpot'[cfSigKS] - cfWpot[cfSigKS], cfSigKS cfWpot'[cfSigKS] - cfWpot[cfSigKS]}];
cfAssert["KS FLUID [fidelity]: Section 29's identities, re-checked where they are used -- eps + P == wF n, eps - 3 P == m sigma, T_s = eps - m sigma == 3 P, d eps/dm == sigma, d eps/dkF == wF dn/dkF",
  cfSimp60[{cfEpsKS + cfPKS - cfWF cfNKS, cfEpsKS - 3 cfPKS - cfMm cfSigKS, (cfEpsKS - cfMm cfSigKS) - 3 cfPKS,
     D[cfEpsKS, cfMm] - cfSigKS, D[cfEpsKS, cfKF] - cfWF D[cfNKS, cfKF]}, cfKSas] === {0, 0, 0, 0, 0}];
cfAssert["KS FLUID [THE RESULT]: ON THE GAP m = W'(sigma7), rho == 3 P_KS/v + W(sigma7) (Section 29's trace identity, per 7-volume), and P_obs - P_hid == P_KS/v, for every W",
  {cfSimp60[(cfFluid7[cfKF, cfMm, vK, cfWpot][[1]] - (3 cfPKS/vK + cfWpot[cfSigKS/vK])) /. Derivative[1][cfWpot][_] -> cfMm, cfKSas && vK > 0] === 0,
   cfZeroQ[cfFluid7[cfKF, cfMm, vK, cfWpot][[2]] - cfFluid7[cfKF, cfMm, vK, cfWpot][[3]] - cfPKS/vK]}];
cfAssert["KS FLUID [has content]: the massless limit m -> 0+: sigma_KS -> 0 and eps_KS = 3 P_KS -> g kF^4/(8 pi^2)",
  Limit[{cfSigKS, cfEpsKS, 3 cfPKS}, cfMm -> 0, Direction -> "FromAbove", Assumptions -> cfKF > 0] === {0, cfGdeg cfKF^4/(8 Pi^2), cfGdeg cfKF^4/(8 Pi^2)}];
cfWtilde = (cfWpot[-#] &);
cfAssert["KS FLUID [THE RESULT]: NEGATIVE m -- the fluid is invariant under sigma -> -sigma, W(x) -> W~(x) = W(-x), and the gap m = W'(sigma7) becomes -m = W~'(-sigma7); with sigma_KS odd and eps_KS, P_KS even in m (Section 29) the case m < 0 reduces to m > 0",
  {cfKSFluid[epsK, pK, -sigK, vK, cfWtilde] === cfKSFluid[epsK, pK, sigK, vK, cfWpot] || Simplify[cfKSFluid[epsK, pK, -sigK, vK, cfWtilde] - cfKSFluid[epsK, pK, sigK, vK, cfWpot]] === {0, 0, 0},
   Simplify[((-mKS) - cfWtilde'[-sigK/vK]) + (mKS - cfWpot'[sigK/vK])] === 0}];
Grid[{{"rho", "eps_KS/v + W - sigma7 W'  =  3 P_KS/v + W  (gap)"}, {"P_obs", "P_KS/v + sigma7 W' - W"}, {"P_hid = P_C", "sigma7 W' - W"}},
  Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 212 ---------- *)
cfRunCell[212, Hold[
ClearAll[cfKFt, cfVt, cfMt, cfS7t, cfFluidT, cfConsResidual, cfConsSym];
cfKFt = kF0s/scA[x4];  cfVt = scB[x4]^3 scC[x4];  cfMt = mF8[x4];
cfS7t = (cfSigKS /. {cfKF -> cfKFt, cfMm -> cfMt})/cfVt;
cfFluidT = cfFluid7[cfKFt, cfMt, cfVt, cfWpot];
(* parenthesized: a top-level line that starts with "-" would be a NEW expression in a notebook cell *)
cfConsResidual = (D[cfFluidT[[1]], x4] + 3 cfRateA (cfFluidT[[1]] + cfFluidT[[2]]) + (3 cfRateB + cfRateC) (cfFluidT[[1]] + cfFluidT[[3]])
   - cfS7t D[cfMt - cfWpot'[cfS7t], x4]);
(* W and its derivatives occur only at the single argument sigma7 (checked); they are replaced by the symbols w0W, w1W, w2W, *)
(* so that Simplify cannot rewrite that argument differently in different terms: the identity holds for EVERY W, W', W''.  *)
cfConsSym = cfConsResidual /. {cfWpot[_] -> w0W, Derivative[1][cfWpot][_] -> w1W, Derivative[2][cfWpot][_] -> w2W};
cfAssert["CONSERVATION [definition]: the fable number per comoving 7-volume, (n_KS/v) A^3 B^3 C, is constant when kF = kF0/A",
  cfZeroQ[D[(cfNKS /. cfKF -> cfKFt)/cfVt scA[x4]^3 scB[x4]^3 scC[x4], x4]]];
cfAssert["CONSERVATION [has content]: rho + P_obs == wF n_KS/v and rho + P_hid == eps_KS/v identically (no gap needed)",
  cfSimp60[{cfFluidT[[1]] + cfFluidT[[2]] - ((cfWF cfNKS) /. {cfKF -> cfKFt, cfMm -> cfMt})/cfVt, cfFluidT[[1]] + cfFluidT[[3]] - (cfEpsKS /. {cfKF -> cfKFt, cfMm -> cfMt})/cfVt},
    kF0s > 0 && scA[x4] > 0 && scB[x4] > 0 && scC[x4] > 0 && mF8[x4] > 0] === {0, 0}];
cfAssert["CONSERVATION [THE RESULT]: rho' + 3 H_A (rho + P_obs) + (3 H_B + H_C)(rho + P_hid) == sigma7 d/dx4[m - W'(sigma7)] IDENTICALLY, for arbitrary A, B, C, m(x4) > 0 and W: the KS fluid is exactly conserved on the gap",
  {Union[Cases[cfConsResidual, (cfWpot | Derivative[_][cfWpot])[arg_] :> arg, Infinity]] === {cfS7t},
   cfSimp60[cfConsSym, kF0s > 0 && scA[x4] > 0 && scB[x4] > 0 && scC[x4] > 0 && mF8[x4] > 0] === 0}];
cfAssert["CONSERVATION [control]: without the gap the fluid is NOT conserved -- the left side is not identically zero (witnessed on A = 1 + x4/2, B = 1 + x4/3, C = 1 + x4^2/3, m = 2 + x4, W = sigma^2, kF0 = 1, g = 8)",
  cfNonZeroWitnessQ[(cfConsResidual + cfS7t D[cfMt - cfWpot'[cfS7t], x4]) /. cfWitABC /. {mF8 -> Function[t, 2 + t], cfWpot -> (#^2 &), kF0s -> 1, cfGdeg -> 8}]];
Short[cfFluidT, 4]
]];

(* ---------- Input cell 213 ---------- *)
cfRunCell[213, Hold[
ClearAll[cfFdrive, cfTsrcC, cfSigOverM, cfDelta, cfPhiArc, cfWitGap, cfMstar, cfRho0W, cfRhoStarW];
cfTsrcC = cfTsrcTrace /. PC -> Phid;
cfFdrive = rho - 3 Pobs + 2 Phid;
cfAssert["DRIVER [THE RESULT]: with P_C = P_hid, kappa (P_hid - T/6) == kappa (P_C - T/6) == kappa F/6, F = rho - 3 P_obs + 2 P_hid: the right-hand side of the B and C equations",
  {cfZeroQ[(Phid - cfTsrcC/6) - cfFdrive/6], cfZeroQ[((PC - cfTsrcTrace/6) /. PC -> Phid) - cfFdrive/6]}];
cfAssert["DRIVER [has content]: F == 0 for radiation, F == rho for dust, F == 2 rho for an 8D vacuum",
  {cfZeroQ[cfFdrive /. {Pobs -> rho/3, Phid -> 0}], cfZeroQ[(cfFdrive /. {Pobs -> 0, Phid -> 0}) - rho], cfZeroQ[(cfFdrive /. {Pobs -> -rho, Phid -> -rho}) - 2 rho]}];
cfAssert["DRIVER [THE RESULT]: for the KS fluid F == sigma7 (m - W') + 2 W - sigma7 W' identically, i.e. F == 2 W - sigma7 W' on the gap; the mass term gives F == m0 sigma7 (dust-like), W = V0 + m0 sigma gives 2 V0 + m0 sigma7",
  Module[{fl = cfFluid7[cfKF, cfMm, vK, cfWpot], s7 = cfSigKS/vK},
    {cfSimp60[(fl[[1]] - 3 fl[[2]] + 2 fl[[3]]) - (s7 (cfMm - cfWpot'[s7]) + 2 cfWpot[s7] - s7 cfWpot'[s7]), cfKSas && vK > 0] === 0,
     cfZeroQ[(2 cfWpot[s7] - s7 cfWpot'[s7] - m0W s7) /. cfWpot -> (m0W # &)],
     cfZeroQ[(2 cfWpot[s7] - s7 cfWpot'[s7] - (2 V0W + m0W s7)) /. cfWpot -> (V0W + m0W # &)]}]];
cfAssert["FROZEN [THE RESULT]: 2 W - sigma W' == 0 for all sigma iff W == c sigma^2 (the general solution of sigma W' == 2 W)",
  {Simplify[(cfWpot[sS] /. DSolve[sS cfWpot'[sS] == 2 cfWpot[sS], cfWpot[sS], sS][[1]]) == C[1] sS^2], cfZeroQ[(2 cfWpot[sS] - sS cfWpot'[sS]) /. cfWpot -> (cW #^2 &)]}];
cfAssert["FROZEN [has content]: m sigma_KS > 0 for m > 0 (zero at kF = 0, kF-derivative g kF^2 m^2/(2 pi^2 wF) > 0; even in m, so also for m < 0); for c < 0 a root m != 0 of m = 2 c sigma_KS/v would give m^2 = 2 c (m sigma_KS)/v < 0: only m = 0",
  {cfSimp60[cfMm cfSigKS /. cfKF -> 0, cfMm > 0] === 0,
   cfSimp60[D[cfMm cfSigKS, cfKF] - cfGdeg cfKF^2 cfMm^2/(2 Pi^2 cfWF), cfKSas] === 0,
   Simplify[cfGdeg cfKF^2 cfMm^2/(2 Pi^2 cfWF) > 0, cfKSas && cfGdeg > 0],
   Simplify[2 cW msPos/vK < 0, cW < 0 && vK > 0 && msPos > 0]}];
cfSigOverM = cfSigKS/cfMm;
cfPhiArc = Log[xA + Sqrt[1 + xA^2]] - xA/Sqrt[1 + xA^2];
cfAssert["FROZEN [has content]: phi(x) = Log[x + Sqrt[1 + x^2]] - x/Sqrt[1 + x^2] is 0 at x = 0 and increasing (derivative x^2/(1 + x^2)^(3/2)), hence positive for x > 0; and L - kF/wF == phi(kF/m)",
  {(cfPhiArc /. xA -> 0) === 0, Simplify[D[cfPhiArc, xA] - xA^2/(1 + xA^2)^(3/2)] === 0,
   cfSimp60[(cfLF - cfKF/cfWF) - (cfPhiArc /. xA -> cfKF/cfMm), cfKSas] === 0}];
cfAssert["FROZEN [THE RESULT]: for c > 0, sigma_KS/m decreases strictly (d/dm = -(g m/(2 pi^2))(L - kF/wF)) from g kF^2/(4 pi^2) at m -> 0 to 0 at m -> infinity: a non-trivial root of 1 = 2 c (sigma_KS/m)/v exists iff c g kF^2/(2 pi^2 v) > 1",
  {cfSimp60[D[cfSigOverM, cfMm] + (cfGdeg cfMm/(2 Pi^2)) (cfLF - cfKF/cfWF), cfKSas] === 0,
   Limit[cfSigOverM, cfMm -> 0, Direction -> "FromAbove", Assumptions -> cfKF > 0] === cfGdeg cfKF^2/(4 Pi^2),
   Limit[cfSigOverM, cfMm -> Infinity, Assumptions -> cfKF > 0] === 0,
   cfZeroQ[(2 cW/vK) (cfGdeg cfKF^2/(4 Pi^2)) - cW cfGdeg cfKF^2/(2 Pi^2 vK)]}];
cfDelta = cfEpsKS - cfMm cfSigKS/2 - cfGdeg cfKF^4/(8 Pi^2);
cfAssert["FROZEN [THE RESULT]: on the non-trivial root (m = 2 c sigma7) rho == (eps_KS - m sigma_KS/2)/v, and Delta = eps_KS(m) - m sigma_KS/2 - eps_KS(0) has Delta(0+) = 0 and dDelta/dm = (g m^3/(4 pi^2))(L - kF/wF) > 0: the m = 0 branch has LOWER rho",
  {cfZeroQ[(cfFluid7[cfKF, cfMm, vK, (cW #^2 &)][[1]] /. cW -> cfMm vK/(2 cfSigKS)) - (cfEpsKS - cfMm cfSigKS/2)/vK],
   Limit[cfDelta, cfMm -> 0, Direction -> "FromAbove", Assumptions -> cfKF > 0] === 0,
   cfSimp60[D[cfDelta, cfMm] - (cfGdeg cfMm^3/(4 Pi^2)) (cfLF - cfKF/cfWF), cfKSas] === 0}];
(* witness numbers: g = 8, v = 1, c = 15 (lam = 2 c = 30), kF = 1: threshold c g kF^2/(2 pi^2) = 6.08 > 1 *)
cfWitGap = {cfGdeg -> 8, vK -> 1, cW -> 15, cfKF -> 1};
cfMstar = cfMm /. FindRoot[(cfMm - 2 cW cfSigKS/vK) /. cfWitGap, {cfMm, 1, 30}, WorkingPrecision -> 30];
cfRho0W = cfGdeg cfKF^4/(8 Pi^2) /. cfWitGap;
cfRhoStarW = (cfEpsKS - cfMm cfSigKS/2) /. cfWitGap /. cfMm -> cfMstar;
Print["  frozen-compatible witness (g = 8, v = 1, c = 15, kF = 1): non-trivial root m* = ", N[cfMstar, 12],
      ";  rho(m = 0) = ", N[cfRho0W, 12], "  <  rho(m*) = ", N[cfRhoStarW, 12]];
cfAssert["FROZEN [has content]: witness numbers -- at g = 8, v = 1, c = 15, kF = 1 the non-trivial root m* exists (gap residual < 10^-20) and rho(m = 0) < rho(m*)",
  {cfMstar > 1/10, Abs[(cfMm - 2 cW cfSigKS/vK) /. cfWitGap /. cfMm -> cfMstar] < 10^-20, N[cfRho0W, 30] < cfRhoStarW}];
cfAssert["FROZEN [THE RESULT]: on the m = 0 branch the frozen-compatible fable is RADIATION: rho = eps_KS(kF, 0)/v, P_obs = rho/3, P_hid = 0",
  Module[{fl = Limit[cfFluid7[cfKF, cfMm, vK, (cW #^2 &)], cfMm -> 0, Direction -> "FromAbove", Assumptions -> cfKF > 0 && vK > 0]},
    {cfZeroQ[fl[[1]] - cfGdeg cfKF^4/(8 Pi^2 vK)], cfZeroQ[fl[[2]] - fl[[1]]/3], cfZeroQ[fl[[3]]]}]];
{cfMstar, N[cfRho0W, 10], N[cfRhoStarW, 10]}
]];

(* ---------- Input cell 214 ---------- *)
cfRunCell[214, Hold[
ClearAll[cfVofW, cfS0];
cfAssert["PHANTOM [THE RESULT]: rho + P_obs == wF n_KS/v >= 0, so w_f >= -1 wherever rho > 0 -- the quantized fable cannot cross the phantom divide",
  {cfSimp60[cfFluid7[cfKF, cfMm, vK, cfWpot][[1]] + cfFluid7[cfKF, cfMm, vK, cfWpot][[2]] - cfWF cfNKS/vK, cfKSas && vK > 0] === 0,
   Simplify[cfWF cfNKS/vK >= 0, cfKSas && vK > 0 && cfGdeg > 0]}];
cfVofW = cfWpot[#/H] &;            (* V(s) := W(s/H), s = H sigma7 *)
cfAssert["CLASSICAL LIMIT [THE RESULT]: exactly, on the gap and with s = H sigma7, V(s) = W(s/H): rho == V(s) + 3 P_KS/v, P_obs == s V'(s) - V(s) + P_KS/v, P_hid == s V'(s) - V(s)",
  Module[{fl = cfFluid7[cfKF, cfMm, vK, cfWpot], s7 = cfSigKS/vK},
    {cfSimp60[(fl[[1]] - (cfVofW[H s7] + 3 cfPKS/vK)) /. Derivative[1][cfWpot][_] -> cfMm, cfKSas && vK > 0] === 0,
     cfZeroQ[fl[[2]] - ((sS D[cfVofW[sS], sS] - cfVofW[sS]) /. sS -> H s7) - cfPKS/vK],
     cfZeroQ[fl[[3]] - ((sS D[cfVofW[sS], sS] - cfVofW[sS]) /. sS -> H s7)]}]];
cfAssert["CLASSICAL LIMIT [fidelity]: Section 24's on-shell P_1 (cfP1Fable, re-checked here) is s V'(s) - V(s); evaluated at s = H sigma7 with V(s) = W(s/H) it IS the KS P_hid = sigma7 W' - W",
  {cfZeroQ[Expand[cfP1Fable - (cfSBil cfVs'[cfSBil] - cfVs[cfSBil])]],
   cfZeroQ[(((sS cfVs'[sS] - cfVs[sS]) /. cfVs -> cfVofW) /. sS -> H sigG/vK) - cfKSFluid[epsG, pG, sigG, vK, cfWpot][[3]]]}];
cfAssert["CLASSICAL LIMIT [THE RESULT]: NR series (kF/m -> 0, m > 0): sigma_KS/n_KS = 1 - (3/10) kF^2/m^2 + ..., (eps_KS - n_KS m)/(n_KS kF^2/m) -> 3/10, P_KS/(n_KS kF^2/m) -> 1/5",
  {Normal[Series[cfSigKS/cfNKS, {cfKF, 0, 2}, Assumptions -> cfMm > 0]] === 1 - 3 cfKF^2/(10 cfMm^2),
   Normal[Series[(cfEpsKS - cfNKS cfMm)/(cfNKS cfKF^2/cfMm), {cfKF, 0, 0}, Assumptions -> cfMm > 0]] === 3/10,
   Normal[Series[cfPKS/(cfNKS cfKF^2/cfMm), {cfKF, 0, 0}, Assumptions -> cfMm > 0]] === 1/5}];
cfS0 = nG/vK;       (* s0 = n/v on the branch m > 0 *)
cfAssert["CLASSICAL LIMIT [has content]: the design's form, exactly: on the gap (m = W'(sigma7) > 0) rho - W(s0) == (eps - n m)/v - [W(s0) - W(sigma7) - W'(sigma7)(s0 - sigma7)], s0 = n/v -- a second-order Taylor remainder in s0 - sigma7",
  cfZeroQ[((epsG/vK + cfWpot[sigG/vK] - (sigG/vK) cfWpot'[sigG/vK]) - cfWpot[cfS0])
     - ((epsG - nG cfWpot'[sigG/vK])/vK - (cfWpot[cfS0] - cfWpot[sigG/vK] - cfWpot'[sigG/vK] (cfS0 - sigG/vK)))]];
cfAssert["SIGN RULE [THE RESULT]: m sigma_KS >= 0 gives sign(sigma7) == sign(m) == sign(W'(sigma7)); for Section 24's mass term W = -2 M sigma the gap is m = -2 M and W(sign(m) n/v) = -2 M sign(-2 M) n/v == 2 |M| n/v > 0",
  {Simplify[Sign[sgX] == Sign[mmX], mmX > 0 && sgX > 0], Simplify[Sign[sgX] == Sign[mmX], mmX < 0 && sgX < 0],
   Simplify[-2 M Sign[-2 M] nG/vK - 2 Abs[M] nG/vK, Element[M, Reals]] === 0}];
Grid[{{"rho", "V(s) + 3 P_KS/v"}, {"P_obs", "s V'(s) - V(s) + P_KS/v"}, {"P_hid = P_C", "s V'(s) - V(s)"}, {"rho + P_obs", "wF n_KS/v  >=  0"}},
  Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 215 ---------- *)
cfRunCell[215, Hold[
ClearAll[cfStab, cfFrozenRule, cfGBIfrozen, cfNullK, cfTstab];
cfStab = -cfFdrive/2;
cfFrozenRule = {scB -> Function[t, 1], scC -> Function[t, 1]};
cfGBIfrozen = cfGBI /. cfFrozenRule;
cfAssert["fable4d [THE RESULT]: with P_stab = -F/2 on B and C, the hidden drivers vanish, F + 2 P_stab == 0, so H_B = H_C = 0 is preserved exactly",
  cfZeroQ[(rho - 3 Pobs + 2 (Phid + cfStab))]];
cfAssert["fable4d [THE RESULT]: with B = C = 1 (labelled substitution) the Einstein equations are EXACTLY 3 H_A^2 == kappa rho and H_A' == -(kappa/2)(rho + P_obs); the x0 and hidden equations then hold with P_hid + P_stab",
  {cfZeroQ[-cfGBIfrozen[[5, 5]] - 3 cfRateA^2],
   cfZeroQ[(cfGBIfrozen[[2, 2]] - kappa Pobs) /. D[scA[x4], {x4, 2}] -> scA[x4] (-(kappa/2) (rho + Pobs) + cfRateA^2) /. rho -> 3 cfRateA^2/kappa],
   cfZeroQ[(cfGBIfrozen[[6, 6]] - kappa (Phid + cfStab)) /. D[scA[x4], {x4, 2}] -> scA[x4] (-(kappa/2) (rho + Pobs) + cfRateA^2) /. rho -> 3 cfRateA^2/kappa],
   cfZeroQ[(cfGBIfrozen[[1, 1]] - kappa (Phid + cfStab)) /. D[scA[x4], {x4, 2}] -> scA[x4] (-(kappa/2) (rho + Pobs) + cfRateA^2) /. rho -> 3 cfRateA^2/kappa]}];
cfAssert["fable4d [has content]: the Friedmann pair is self-consistent -- d/dx4 (3 H_A^2 - kappa rho) == 0 when H_A' = -(kappa/2)(rho + P_obs) and rho' = -3 H_A (rho + P_obs) (the conservation law at H_B = H_C = 0)",
  cfZeroQ[(6 cfRateA hAdot - kappa rhoDot) /. {hAdot -> -(kappa/2) (rho + Pobs), rhoDot -> -3 cfRateA (rho + Pobs)}]];
(* the null energy condition along x0: k = e_0/C + e_4 is null on the Bianchi-I metric *)
cfNullK = {1/scC[x4], 0, 0, 0, 1, 0, 0, 0};
cfTstab = cfGeoBI["g"] . DiagonalMatrix[{PstabS, 0, 0, 0, 0, PstabS, PstabS, PstabS}];     (* rho_stab = 0 *)
cfAssert["fable4d [THE RESULT]: the stabilizer VIOLATES the null energy condition along x0: T_stab(k, k) == P_stab == -F/2 for the null k in the (x0, x4) plane, == -rho_dust/2 < 0 for dust alone",
  {cfZeroQ[cfNullK . cfGeoBI["g"] . cfNullK], cfZeroQ[cfNullK . cfTstab . cfNullK - PstabS],
   cfZeroQ[(cfStab /. {Pobs -> 0, Phid -> 0}) + rho/2], Simplify[-rho/2 < 0, rho > 0]}];
cfAssert["fable4d [has content]: it is a Lagrange multiplier with zero energy -- rho_stab == 0, and at H_B = H_C = 0 it drops out of the conservation law (its term is (3 H_B + H_C) P_stab)",
  {cfTstab[[5, 5]] === 0, cfZeroQ[((cfDivTBI[[5]] /. {rhof -> (0 &), Pobsf -> (0 &), Phidf -> (PstabF[#] &), PCf -> (PstabF[#] &)}) /. cfFrozenRule)]}];
{-cfGBIfrozen[[5, 5]], cfStab}
]];

(* ---------- Input cell 216 ---------- *)
cfRunCell[216, Hold[
ClearAll[cfHbarJs, cfClight, cfEVJ, cfGnewton, cfKBeVK, cfMpcM, cfHlittle, cfH0s, cfH0eV, cfMplEV, cfRhoc0, cfEcEV, cfTg0, cfOmG, cfOmR0, cfOmB0,
         cfKSnum, cfN0grid, cfGrid701, cfSub, cfM0A, cfKF0A, cfV0A, cfRowA, cfInvHA, cfAgeA, cfRowsA8,
         cfNuP, cfMtP, cfOmQP, cfKF0P, cfSigT, cfUt, cfLamP, cfM0P, cfWP8, cfGapP8, cfRowP, cfSolP, cfRowsP8, cfHP8,
         cfRefFileA, cfRefFileP, cfCmpRef, cfRustFileA, cfRustFileP, cfReadRust, cfCmpRust, cfHdr8, cfPstabA, cfPstabP, cfNF];
(* a plain number formatter for the printed log: d significant digits, exponent written as e *)
cfNF[x_, d_ : 8] := ToString[NumberForm[N[x], d, NumberFormat -> (If[#3 === "", #1, #1 <> "e" <> #3] &)]];
(* ---- units: CODATA 2018, exact where exact ---- *)
cfHbarJs = 1054571817/10^43;  cfClight = 299792458;  cfEVJ = 1602176634/10^28;  cfGnewton = 667430/10^16;
cfKBeVK = (1380649/10^29)/cfEVJ;  cfMpcM = 648000/Pi 149597870700 10^6;  cfHlittle = 674/1000;
cfH0s  = 100 cfHlittle 1000/cfMpcM;                 (* H0 in 1/s *)
cfH0eV = cfHbarJs cfH0s/cfEVJ;                      (* hbar H0 in eV *)
cfMplEV = Sqrt[cfHbarJs cfClight^5/(8 Pi cfGnewton)]/cfEVJ;
cfRhoc0 = 3 cfH0eV^2 cfMplEV^2;                     (* eV^4 *)
cfEcEV  = cfRhoc0^(1/4);                            (* the unit of mass and momentum, eV *)
cfTg0   = cfKBeVK 27255/10000;                      (* T_CMB in eV *)
cfOmG   = (Pi^2/15) cfTg0^4/cfRhoc0;
cfOmR0  = SetPrecision[N[cfOmG (1 + (3046/1000) (7/8) (4/11)^(4/3)), 60], Infinity];
cfOmB0  = (2237/100000)/cfHlittle^2;
Print["  units:  1/H0 = ", cfNF[N[1/(cfH0s 365.25 86400)], 8], " yr;  M_pl = ", cfNF[N[cfMplEV 10^-9], 8], " GeV;  rho_c0 = ",
      cfNF[N[cfRhoc0], 8], " eV^4;  E_c = rho_c0^(1/4) = ", cfNF[N[cfEcEV], 8], " eV"];
Print["          Omega_gamma0 = ", cfNF[N[cfOmG], 8], ",  Omega_r0 = ", cfNF[N[cfOmR0], 8], ",  Omega_b0 = ", cfNF[N[cfOmB0], 8]];
cfAssert["fable4d RUNS [definition]: the units computed from CODATA 2018 -- E_c = rho_c0^(1/4) == 2.46261e-3 eV, Omega_r0 == 9.2096e-5, Omega_b0 = 0.02237/h^2 == 0.049243 (to the quoted digits)",
  {Abs[N[cfEcEV/(246261/10^8), 20] - 1] < 10^-5, Abs[N[cfOmR0/(92096/10^9), 20] - 1] < 10^-4, Abs[N[cfOmB0, 20] - 49243/10^6] < 10^-6}];
(* ---- Section 29's closed forms, evaluated at 30 digits from exact inputs (g = 8) ---- *)
cfKSnum[f_, k_, m_] := N[f /. {cfKF -> k, cfMm -> m, cfGdeg -> 8}, 30];
cfN0grid = Log[10^-10];
cfGrid701 = Table[cfN0grid - cfN0grid j/700, {j, 0, 700}];
cfSub = Range[1, 701, 10];                                           (* every tenth row: 71 rows *)
(* ---- case mass30eV ---- *)
cfM0A  = SetPrecision[N[30/cfEcEV, 60], Infinity];
cfKF0A = SetPrecision[kk /. FindRoot[(cfEpsKS /. {cfKF -> kk, cfMm -> cfM0A, cfGdeg -> 8}) == 265/1000, {kk, 1/20, 1/10}, WorkingPrecision -> 60], Infinity];
cfV0A  = SetPrecision[N[1 - 265/1000 - cfOmB0 - cfOmR0, 60], Infinity];
cfRowA[n_] := Module[{a = Exp[n], k, e, p, s, rho, pob},
  k = cfKF0A/a; e = cfKSnum[cfEpsKS, k, cfM0A]; p = cfKSnum[cfPKS, k, cfM0A]; s = cfKSnum[cfSigKS, k, cfM0A];
  rho = e + cfV0A; pob = p - cfV0A;
  {N[n, 30], N[a, 30], 0, N[Sqrt[cfOmR0/a^4 + cfOmB0/a^3 + rho], 30], rho, pob, pob/rho, N[cfM0A, 30], s, N[k/cfM0A, 30]}];
cfInvHA[n_?NumericQ] := Module[{nn = SetPrecision[n, 60], a, k}, a = Exp[nn]; k = cfKF0A/a;
  N[1/Sqrt[cfOmR0/a^4 + cfOmB0/a^3 + (cfEpsKS /. {cfKF -> k, cfMm -> cfM0A, cfGdeg -> 8}) + cfV0A], 40]];
cfRowsA8 = cfTimed["fable4d mass30eV: 71 rows by exact algebra, the age by NIntegrate between the rows",
  Module[{rows = cfRowA /@ cfGrid701[[cfSub]], t0, ts},
    t0 = (1/2) cfInvHA[cfN0grid];
    ts = FoldList[Plus, t0, Table[NIntegrate[cfInvHA[nn], {nn, cfGrid701[[cfSub[[i]]]], cfGrid701[[cfSub[[i + 1]]]]},
        WorkingPrecision -> 30, PrecisionGoal -> 20, AccuracyGoal -> Infinity], {i, Length[cfSub] - 1}]];
    rows[[All, 3]] = ts; rows]];
(* ---- case power: nu = 1/2, m_today = 100 eV, eps_KS(today) = 0.55, flat, no bare Lambda ---- *)
cfNuP = 1/2;  cfMtP = SetPrecision[N[100/cfEcEV, 60], Infinity];  cfOmQP = 55/100;
cfKF0P = SetPrecision[kk /. FindRoot[(cfEpsKS /. {cfKF -> kk, cfMm -> cfMtP, cfGdeg -> 8}) == cfOmQP, {kk, 1/20, 1/10}, WorkingPrecision -> 60], Infinity];
cfSigT = SetPrecision[cfKSnum[cfSigKS, cfKF0P, cfMtP], Infinity];
cfUt   = SetPrecision[N[1 - cfOmQP - cfOmB0 - cfOmR0, 60], Infinity];
cfLamP = SetPrecision[N[cfUt/((1 - cfNuP) cfSigT^cfNuP), 60], Infinity];
cfM0P  = SetPrecision[N[cfMtP - cfNuP cfLamP cfSigT^(cfNuP - 1), 60], Infinity];
cfWP8[s_] := cfM0P s + cfLamP s^cfNuP;
(* the gap m = W'(sigma_KS(kF, m)): Section 33's argument makes m - W'(sigma) strictly increasing in m; solved by FindRoot at 40 digits *)
cfGapP8[k_] := mm /. FindRoot[mm - (cfM0P + cfNuP cfLamP (cfSigKS /. {cfKF -> k, cfMm -> mm, cfGdeg -> 8})^(cfNuP - 1)), {mm, cfM0P, 2 cfMtP},
   Method -> "Brent", WorkingPrecision -> 40, AccuracyGoal -> 35, PrecisionGoal -> 35];     (* f(m0) < 0 < f(2 m_today) *)
cfRowP[n_] := Module[{a = Exp[n], k, m, e, p, s, U, rho, pob},
  k = cfKF0P/a; m = SetPrecision[cfGapP8[k], 60];
  e = cfKSnum[cfEpsKS, k, m]; p = cfKSnum[cfPKS, k, m]; s = cfKSnum[cfSigKS, k, m];
  U = N[cfWP8[s] - s D[cfWP8[ss], ss] /. ss -> s, 30]; rho = e + U; pob = p - U;
  {N[n, 30], N[a, 30], 0, N[Sqrt[cfOmR0/a^4 + cfOmB0/a^3 + rho], 30], rho, pob, pob/rho, N[m, 30], s, N[k/m, 30]}];
(* the pair (m(N), u(N) = ln t(N)): the differentiated gap equation and du/dN = Exp[-u]/H *)
cfHP8[n_, m_] := With[{k = cfKF0P Exp[-n], s = cfSigKS /. {cfKF -> cfKF0P Exp[-n], cfMm -> m, cfGdeg -> 8}},
  Sqrt[cfOmR0 Exp[-4 n] + cfOmB0 Exp[-3 n] + (cfEpsKS /. {cfKF -> k, cfMm -> m, cfGdeg -> 8}) + (1 - cfNuP) cfLamP s^cfNuP]];
cfSolP = cfTimed["fable4d power: NDSolve of (m(N), ln t(N)) with the differentiated gap equation",
  Module[{w2, sk, sm, dsdm = D[cfSigKS, cfMm], rhs},
    w2[s_] := cfNuP (cfNuP - 1) cfLamP s^(cfNuP - 2);
    sk[k_, m_] := (8/(2 Pi^2)) k^2 m/Sqrt[k^2 + m^2];                                       (* d sigma/d kF (Section 29) *)
    sm[k_, m_] := dsdm /. {cfKF -> k, cfMm -> m, cfGdeg -> 8};
    rhs[n_, m_] := With[{k = cfKF0P Exp[-n], s = cfSigKS /. {cfKF -> cfKF0P Exp[-n], cfMm -> m, cfGdeg -> 8}},
      -w2[s] sk[k, m] k/(1 - w2[s] sm[k, m])];
    NDSolve[{mP'[nn] == rhs[nn, mP[nn]], uP'[nn] == Exp[-uP[nn]]/cfHP8[nn, mP[nn]],
       mP[cfN0grid] == SetPrecision[cfGapP8[cfKF0P Exp[-cfN0grid]], 40], uP[cfN0grid] == -Log[2 cfHP8[cfN0grid, SetPrecision[cfGapP8[cfKF0P Exp[-cfN0grid]], 40]]]},
      {mP, uP}, {nn, cfN0grid, 0}, WorkingPrecision -> 40, PrecisionGoal -> 24, AccuracyGoal -> 28, MaxSteps -> 10^6, InterpolationOrder -> All][[1]]]];
cfRowsP8 = cfTimed["fable4d power: 71 rows by exact algebra (FindRoot of the gap at every row)",
  Module[{rows = cfRowP /@ cfGrid701[[cfSub]]}, rows[[All, 3]] = Table[Exp[uP[n] /. cfSolP], {n, cfGrid701[[cfSub]]}]; rows]];
Print["  mass30eV: m0 = 30 eV = ", cfNF[N[cfM0A], 10], " E_c;  kF0 = ", cfNF[N[cfKF0A], 12], " E_c = ", cfNF[N[cfKF0A cfEcEV], 8],
      " eV;  V0 = ", cfNF[N[cfV0A], 10], ";  a_nr = kF0/m0 = ", cfNF[N[cfKF0A/cfM0A], 6], ";  t0 = ", cfNF[cfRowsA8[[-1, 3]], 12], " / H0"];
Print["  power:    m_today = 100 eV;  kF0 = ", cfNF[N[cfKF0P], 12], " E_c;  lam = ", cfNF[N[cfLamP], 12], ";  m0 = ", cfNF[N[cfM0P cfEcEV], 10],
      " eV;  U_today = ", cfNF[N[cfUt], 10], ";  w_f(1) = ", cfNF[cfRowsP8[[-1, 7]], 12], ";  t0 = ", cfNF[cfRowsP8[[-1, 3]], 12], " / H0"];
cfAssert["fable4d RUNS [THE RESULT]: mass30eV -- flat today (H_A(1) == 1), eps_KS(1) == 0.265, ultra-relativistic at the start (w_f(a_i) = 1/3 to 1e-8), non-relativistic at a_nr = kF0/m0 == 4.16e-4 (m/eV)^(-4/3) (1%), and w_f >= -1 at every row",
  {Abs[cfRowsA8[[-1, 4]] - 1] < 10^-20, Abs[cfKSnum[cfEpsKS, cfKF0A, cfM0A] - 265/1000] < 10^-20, Abs[cfRowsA8[[1, 7]] - 1/3] < 10^-8,
   cfRowsA8[[1, 10]] > 1 > cfRowsA8[[-1, 10]], Abs[N[(cfKF0A/cfM0A)/(416/10^6 30^(-4/3))] - 1] < 1/100, Min[cfRowsA8[[All, 7]]] >= -1}];
cfAssert["fable4d RUNS [THE RESULT]: power -- flat today, m_eff(1) == 100 eV, m0 == 27.15 eV > 0, m_eff INCREASES monotonically from m0 (early) to m_today, and w_f >= -1 at every row",
  {Abs[cfRowsP8[[-1, 4]] - 1] < 10^-20, Abs[cfRowsP8[[-1, 8]]/cfMtP - 1] < 10^-20, Abs[N[cfM0P cfEcEV] - 27.15] < 0.01,
   AllTrue[Differences[cfRowsP8[[All, 8]]], # > 0 &], Abs[cfRowsP8[[1, 8]]/cfM0P - 1] < 10^-3, Min[cfRowsP8[[All, 7]]] >= -1}];
cfAssert["fable4d RUNS [has content]: the differentiated gap equation carries m(N) along the history -- NDSolve's m agrees with the per-row FindRoot to 1e-15 at all 71 rows",
  Max[Table[Abs[(mP[cfRowsP8[[i, 1]]] /. cfSolP)/cfRowsP8[[i, 8]] - 1], {i, Length[cfSub]}]] < 10^-15];
(* the stabilizer along the runs: P_stab = -F_total/2, F_total = rho_b + F_fable (radiation has F = 0) *)
cfPstabA = Table[-(cfOmB0/r[[2]]^3 + 2 cfV0A + cfM0A r[[9]])/2, {r, cfRowsA8}];              (* F_fable = 2 V0 + m0 sigma *)
cfPstabP = Table[-(cfOmB0/r[[2]]^3 + cfM0P r[[9]] + (2 - cfNuP) cfLamP r[[9]]^cfNuP)/2, {r, cfRowsP8}];   (* 2W - sigma W' *)
cfAssert["fable4d RUNS [THE RESULT]: the stabilizer P_stab = -F_total/2 is NEGATIVE at every row of both runs -- the null-energy violation along x0 is present along the whole history",
  {Max[cfPstabA] < 0, Max[cfPstabP] < 0}];
Print["  P_stab(a) [units of rho_c0] at a = 1e-10, 1e-6, 1e-3, 1:   mass30eV ", cfNF[#, 6] & /@ cfPstabA[[{1, 29, 50, 71}]],
      ";   power ", cfNF[#, 6] & /@ cfPstabP[[{1, 29, 50, 71}]]];
(* ---- the reference CSVs of make_reference_fermion.wls, if present ---- *)
cfHdr8 = {"N", "a", "t", "H_A", "rho_f", "P_obs_f", "w_f", "m_eff", "sigma", "kF_over_m"};
cfCmpRef[file_, rows_] := Module[{ref = Import[file, "CSV"], sel, d},
  sel = ref[[1 + cfSub]];
  d = Table[Max[Table[With[{x = rows[[i, c]], y = sel[[i, c]]},
        Which[c == 6, Abs[x - y]/rows[[i, 5]], c == 1 || c == 7, Abs[x - y], True, Abs[x - y]/Abs[x]]], {i, Length[cfSub]}]], {c, 10}];
  {ref[[1]] === cfHdr8, Length[ref] === 702, d}];
cfRefFileA = FileNameJoin[{cfRefDir, "mathematica_fable4d_mass30eV.csv"}];
cfRefFileP = FileNameJoin[{cfRefDir, "mathematica_fable4d_power.csv"}];
If[FileExistsQ[cfRefFileA] && FileExistsQ[cfRefFileP],
  Module[{ca = cfCmpRef[cfRefFileA, cfRowsA8], cp = cfCmpRef[cfRefFileP, cfRowsP8]},
    Print["  reference ", cfRefFileA, ":  max difference per column ", cfNF[#, 3] & /@ N[ca[[3]]]];
    Print["  reference ", cfRefFileP, ":  max difference per column ", cfNF[#, 3] & /@ N[cp[[3]]]];
    cfAssert["fable4d RUNS [fidelity]: the reference CSVs have the expected header and 701 rows",
      {ca[[1]], ca[[2]], cp[[1]], cp[[2]]}];
    cfAssert["fable4d RUNS [fidelity]: at every tenth row ALL TEN columns agree with fable-cosmology/reference/mathematica_fable4d_mass30eV.csv and _power.csv to 1e-10 (relative; P_obs_f relative to rho_f; N and w_f absolute)",
      {Max[ca[[3]]] < 10^-10, Max[cp[[3]]] < 10^-10}]],
  cfNote["reference files not found; the fable4d comparison was skipped, not failed",
    "Looked for " <> cfRefFileA <> " and " <> cfRefFileP <> ".  Run fable-cosmology/reference/make_reference_fermion.wls to create them; the computation above stands on its own."]];
(* ---- the Rust solver's CSVs (written under fable-cosmology/results by a notebook), if present ---- *)
cfReadRust[file_] := Module[{lines, hdr, data},
  lines = Select[StringSplit[Import[file, "Text"], "\n"], StringLength[StringTrim[#]] > 0 && ! StringStartsQ[StringTrim[#], "#"] &];
  hdr = StringTrim /@ StringSplit[First[lines], ","];
  data = ImportString[StringRiffle[Rest[lines], "\n"], "CSV"];                  (* the comment lines are dropped first *)
  AssociationThread[hdr, Transpose[data]]];
(* the Rust grid may differ from this one: its columns are interpolated in N (cubic) -- the positive ones in Log,    *)
(* w_f as it is, and P_obs_f through the ratio P_obs_f/rho_f -- so that the interpolation error stays far below 1e-6. *)
cfCmpRust[file_, rows_] := Module[{r = cfReadRust[file], nR, sel, d, fi},
  nR = r["N"];
  sel = Select[Range[Length[rows]], Min[nR] <= rows[[#, 1]] <= Max[nR] &];
  fi[vals_] := Interpolation[Transpose[{nR, vals}], InterpolationOrder -> 3];
  d = Table[With[{col = cfHdr8[[c]]},
      If[! (KeyExistsQ[r, col] && KeyExistsQ[r, "rho_f"]), Missing[col],
        Which[
          c == 6, With[{f = fi[r["P_obs_f"]/r["rho_f"]]}, Max[Table[Abs[rows[[i, 6]]/rows[[i, 5]] - f[rows[[i, 1]]]], {i, sel}]]],
          c == 7, With[{f = fi[r["w_f"]]}, Max[Table[Abs[rows[[i, 7]] - f[rows[[i, 1]]]], {i, sel}]]],
          True,   With[{f = fi[Log[Abs[r[col]]]]}, Max[Table[Abs[rows[[i, c]]/Exp[f[rows[[i, 1]]]] - 1], {i, sel}]]]]]],
    {c, 2, 10}];
  {Length[sel], d}];
cfRustFileA = FileNameJoin[{cfDir, "..", "fable-cosmology", "results", "nb06_fable4d_mass30eV.csv"}];
cfRustFileP = FileNameJoin[{cfDir, "..", "fable-cosmology", "results", "nb06_fable4d_power.csv"}];
Do[With[{file = pair[[1]], rows = pair[[2]], name = pair[[3]]},
    If[FileExistsQ[file],
      Module[{c = cfCmpRust[file, rows]},
        Print["  Rust ", file, ": ", c[[1]], " rows compared; max difference per column {a, t, H_A, rho_f, P_obs_f, w_f, m_eff, sigma, kF_over_m}: ", Map[If[NumericQ[#], cfNF[#, 3], #] &, c[[2]]]];
        cfAssert["fable4d RUNS [fidelity]: the Rust solver's " <> name <> " run agrees with this cell to 1e-6 in every column, at every one of the rows its grid covers",
          {c[[1]] > 10, FreeQ[c[[2]], Missing], Max[c[[2]]] < 10^-6}]],
      cfNote["Rust CSV not found; that comparison was skipped, not failed",
        "Looked for " <> file <> ".  A fable-cosmology notebook writes it with fable_fermion fable4d (the command is in this cell's text)."]]],
  {pair, {{cfRustFileA, cfRowsA8, "mass30eV"}, {cfRustFileP, cfRowsP8, "power"}}}];
Grid[Prepend[Map[NumberForm[N[#], 6] &, Join[cfRowsA8[[{1, 21, 41, 51, 61, 66, 71}, {1, 2, 3, 4, 7, 10}]], cfRowsP8[[{1, 21, 41, 51, 61, 66, 71}, {1, 2, 3, 4, 7, 10}]]], {2}],
  {"N", "a", "t [1/H0]", "H_A [H0]", "w_f", "kF/m"}], Frame -> All, Alignment -> Left, Dividers -> {None, {2 -> True, 9 -> True}}]
]];

(* ---------- Input cell 217 ---------- *)
cfRunCell[217, Hold[
cfAssert["PART VIII [control]: a4 is STILL UNDEFINED -- nothing in Part VIII gave it a value; the scale factors scA, scB, scC were only ever substituted inside assertions, and none of them entered the canonical frame",
  {ValueQ[a4] === False, DownValues[a4] === {}, OwnValues[a4] === {},
   {ValueQ[scA], ValueQ[scB], ValueQ[scC]} === {False, False, False}, FreeQ[frameCanonical, scA | scB | scC], FreeQ[gCanonical, scA | scB | scC]}];
(* --- final tally of every assertion made in this notebook, Parts I-VIII -------------------- *)
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
