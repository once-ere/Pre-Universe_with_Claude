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
  Print["CELL ", n, "  t=", ToString[NumberForm[t, {8, 3}]], " s",
    If[msgs === {}, "", "   MESSAGES: " <> ToString[msgs]]];
  r];

cfRunSummary[] := Module[{tot, slow},
  tot = Total[#["seconds"] & /@ $cfCellLog];
  slow = Reverse[SortBy[$cfCellLog, #["seconds"] &]][[1 ;; Min[12, Length[$cfCellLog]]]];
  Print["==================== RUN SUMMARY ===================="];
  Print["cells evaluated : ", Length[$cfCellLog]];
  Print["total seconds   : ", ToString[NumberForm[tot, {10, 3}]]];
  Print["cells w/ msgs   : ", Length[$cfMessages]];
  If[$cfMessages =!= {},
    Print["---- messages ----"];
    Scan[Print["  cell ", #[[1]], ": ", #[[2]]] &, $cfMessages]];
  Print["---- slowest cells ----"];
  Scan[Print["  cell ", #["cell"], "  ", ToString[NumberForm[#["seconds"], {8, 3}]], " s"] &, slow];
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
Protect[DIM8];
DIM8
]];

(* ---------- Input cell 4 ---------- *)
cfRunCell[4, Hold[
ClearAll[cfTimed];
SetAttributes[cfTimed, HoldRest];
cfTimed[label_String, expr_] := Module[{t, r},
  {t, r} = AbsoluteTiming[expr];
  Print["  [", NumberForm[t, {6, 3}], " s]  ", label];
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
ClearAll[evalues, evecs, uEig, hUSE, unit];
{evalues, evecs} = Eigensystem[\[Sigma]];
uEig = ExpandAll[(1/Sqrt[2]) evecs];
hUSE = 8;
unit = uEig[[hUSE]];
Protect[hUSE, unit];
cfAssert["each uEig row is sigma-normalized to +/-1",
  MemberQ[{1, -1}, #] & /@ Table[uEig[[h]] . \[Sigma] . uEig[[h]], {h, 1, 8}]];
cfAssert["unit is sigma-normalized to +1", unit . \[Sigma] . unit === 1];
{evalues, MatrixForm[uEig], unit}
]];

(* ---------- Input cell 40 ---------- *)
cfRunCell[40, Hold[
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

(* ---------- Input cell 41 ---------- *)
cfRunCell[41, Hold[
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

(* ---------- Input cell 42 ---------- *)
cfRunCell[42, Hold[
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

(* ---------- Input cell 43 ---------- *)
cfRunCell[43, Hold[
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

(* ---------- Input cell 44 ---------- *)
cfRunCell[44, Hold[
(* --- eA[1] is the unit of the algebra: eA[1] x = x eA[1] = x ---------------------------- *)
cfAssert["eA[1] is a two-sided identity for the vector-basis product",
  Join[
   Flatten @ Table[Sum[mABC[[1, B1, C1]] ID8[[C1]], {C1, 8}] === ID8[[B1]], {B1, 1, 8}],
   Flatten @ Table[Sum[mABC[[A1, 1, C1]] ID8[[C1]], {C1, 8}] === ID8[[A1]], {A1, 1, 8}]]];
Table[Sum[mABC[[1, B1, C1]] EA[[C1]], {C1, 8}], {B1, 8}]
]];

(* ---------- Input cell 45 ---------- *)
cfRunCell[45, Hold[
(* --- the norm is multiplicative on basis units: m^C_AB eta_CD m^D_AB = eta_AA eta_BB ----- *)
cfAssert["<eA, eB> composition is compatible with eta (basis-unit norm form)",
  Flatten @ Table[
    Sum[mABC[[A1, B1, C1]] \[Eta]4488[[C1, D1]] mABC[[A1, B1, D1]], {C1, 8}, {D1, 8}] ===
      \[Eta]4488[[A1, A1]] \[Eta]4488[[B1, B1]],
    {A1, 1, 8}, {B1, 1, 8}]];
]];

(* ---------- Input cell 46 ---------- *)
cfRunCell[46, Hold[
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

