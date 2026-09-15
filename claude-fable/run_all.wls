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
cfAssert["but NOT a Spin(8,8) transformation: it does not preserve sigma16",
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
  (* Count the two outcomes apart.  Incrementing one counter BEFORE the call, as this cell   *)
  (* used to, made every non-vanishing assertion look like an identity accepted on numerics. *)
  If[r, $cfNumericCertificates++, $cfNonVanishingWitnesses++];
  r];
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
 cfZeroArrayQ[{{0, Sin[x0]^2 + Cos[x0]^2 - 1}, {Exp[a4[H x4]] Exp[-a4[H x4]] - 1, 0}}]}
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
cfAssert["the metric is non-degenerate", ! TrueQ[cfZeroQ[detgCanonical]]];
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
cfAssert["(1/8) omega [gamma^a, gamma^b] == (1/2) omega SAB",
  cfZeroArrayQ[Table[GammaSpinCanonical[[mu]]
      - (1/2) Sum[omegaCanonical[[mu, a, b]] SAB[[a, b]], {a, 8}, {b, 8}], {mu, 8}]]];
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
Dimensions[gammaCurvedCanonical]
]];

(* ---------- Input cell 117 ---------- *)
cfRunCell[117, Hold[
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
  ! TrueQ[cfZeroArrayQ[cfLambda . Transpose[cfLambda] - ID8]]];
cfAssert["Lambda == MatrixExp[theta K] with K the (0,4) boost generator",
  cfZeroArrayQ[cfLambdaOf[\[Theta]] - MatrixExp[\[Theta] cfBoostGenerator]]];
MatrixForm[cfLambda]
]];

(* ---------- Input cell 118 ---------- *)
cfRunCell[118, Hold[
frameBoost = cfSimpArray[frameCanonical . cfLambda];
cfAssert["BRIDGE 1 reproduces the SAME curved metric g",
  cfZeroArrayQ[frameBoost . \[Eta]4488 . Transpose[frameBoost] - gCanonical]];
cfAssert["BRIDGE 1 frame really is different from the canonical frame",
  frameBoost =!= frameCanonical];
MatrixForm[frameBoost]
]];

(* ---------- Input cell 119 ---------- *)
cfRunCell[119, Hold[
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

(* ---------- Input cell 120 ---------- *)
cfRunCell[120, Hold[
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

(* ---------- Input cell 121 ---------- *)
cfRunCell[121, Hold[
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

(* ---------- Input cell 122 ---------- *)
cfRunCell[122, Hold[
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

(* ---------- Input cell 123 ---------- *)
cfRunCell[123, Hold[
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

(* ---------- Input cell 124 ---------- *)
cfRunCell[124, Hold[
frameNull = cfSimpArray[frameCanonical . cfU];
cfAssert["BRIDGE 2 reproduces the SAME curved metric g",
  cfZeroArrayQ[frameNull . \[Eta]Null . Transpose[frameNull] - gCanonical]];
MatrixForm[frameNull]
]];

(* ---------- Input cell 125 ---------- *)
cfRunCell[125, Hold[
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

(* ---------- Input cell 126 ---------- *)
cfRunCell[126, Hold[
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

(* ---------- Input cell 127 ---------- *)
cfRunCell[127, Hold[
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

(* ---------- Input cell 128 ---------- *)
cfRunCell[128, Hold[
ClearAll[frameTri, \[Eta]TriFlat];
\[Eta]TriFlat = \[Eta]Tri;                       (* == sigma, proved in Section 9 *)
cfAssert["the triality bridge is ORTHOGONAL: Transpose[P] == Inverse[P]",
  cfZeroArrayQ[Transpose[triVecToSpin] - triSpinToVec]];
frameTri = cfSimpArray[frameCanonical . triVecToSpin];
cfAssert["BRIDGE 3 reproduces the SAME curved metric g",
  cfZeroArrayQ[frameTri . \[Eta]TriFlat . Transpose[frameTri] - gCanonical]];
cfAssert["the triality tangent metric is sigma", \[Eta]TriFlat === \[Sigma]];
MatrixForm[frameTri]
]];

(* ---------- Input cell 129 ---------- *)
cfRunCell[129, Hold[
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

(* ---------- Input cell 130 ---------- *)
cfRunCell[130, Hold[
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

(* ---------- Input cell 131 ---------- *)
cfRunCell[131, Hold[
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

(* ---------- Input cell 132 ---------- *)
cfRunCell[132, Hold[
(* --- the torsion of the octonionic connection is non-zero and totally antisymmetric ------ *)
ClearAll[torsionOct, torsionOctFlat];
torsionOct = cfTimed["BRIDGE 3 torsion 2-form", cfTorsion[frameTri, X, omegaOctMixed]];
cfAssert["BRIDGE 3: torsion vanishes at lambda = 0",
  cfZeroArrayQ[torsionOct /. \[Lambda]Oct -> 0]];
cfAssert["BRIDGE 3: torsion is NOT zero for lambda != 0",
  ! TrueQ[cfZeroArrayQ[torsionOct /. \[Lambda]Oct -> 1]]];
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

(* ---------- Input cell 133 ---------- *)
cfRunCell[133, Hold[
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

(* ---------- Input cell 134 ---------- *)
cfRunCell[134, Hold[
ClearAll[T16Tri, cfSpinMatrixTri];
T16Tri[a_Integer] := T16Tri[a] = Sum[triSpinToVec[[a, A1]] T16[A1 - 1], {A1, 8}];
cfAssert["THE TRIALITY DIRAC MATRICES OBEY THE sigma CLIFFORD RELATION: {T16Tri[a],T16Tri[b]} == 2 sigma[[a,b]] ID16",
  cfZeroArrayQ[Table[T16Tri[a] . T16Tri[b] + T16Tri[b] . T16Tri[a]
     - 2 \[Eta]TriFlat[[a, b]] ID16, {a, 8}, {b, 8}]]];
cfAssert["they are NOT the vector-frame Dirac matrices, so the distinction is real",
  ! TrueQ[cfZeroArrayQ[Table[T16Tri[a] - T16[a - 1], {a, 8}]]]];
cfSpinMatrixTri[om_, mu_Integer] :=
  (1/8) Sum[om[[mu, a, b]] (T16Tri[a] . T16Tri[b] - T16Tri[b] . T16Tri[a]), {a, 8}, {b, 8}];
]];

(* ---------- Input cell 135 ---------- *)
cfRunCell[135, Hold[
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
(* the canonical one, because the two frames differ only by a constant O(4,4) rotation.       *)
cfAssert["at lambda = 0 the Bridge 3 spinor connection equals the canonical one",
  cfZeroArrayQ[Table[(GammaSpinOct[[mu]] /. \[Lambda]Oct -> 0) - GammaSpinCanonical[[mu]], {mu, 8}]]];
cfAssert["the extra spinor coupling vanishes at lambda = 0",
  cfZeroArrayQ[GammaSpinOctExtra /. \[Lambda]Oct -> 0]];
cfAssert["the extra spinor coupling is non-zero for lambda != 0",
  ! TrueQ[cfZeroArrayQ[GammaSpinOctExtra /. \[Lambda]Oct -> 1]]];
cfAssert["the extra spinor coupling is still block diagonal (type-1 + type-2 preserved)",
  cfZeroArrayQ[Table[GammaSpinOctExtra[[mu]]
      - ArrayFlatten[{{GammaSpinOctExtra[[mu]][[1 ;; 8, 1 ;; 8]], 0},
                      {0, GammaSpinOctExtra[[mu]][[9 ;; 16, 9 ;; 16]]}}], {mu, 8}]]];
{Count[Flatten[GammaSpinOctExtra], Except[0]], " non-zero entries in the extra coupling"}
]];

(* ---------- Input cell 136 ---------- *)
cfRunCell[136, Hold[
ClearAll[cfConnectionSummary];
cfConnectionSummary = {
  {"connection", "frame field", "flat metric", "same g?", "antisymmetric?", "torsion zero?",
   "difference from canonical"},
  {"omegaCanonical", "frameCanonical (diagonal)", "eta4488", "yes (reference)", "yes", "yes",
   "-- (reference)"},
  {"omegaBoost", "frameCanonical . Lambda(x)", "eta4488", "yes", "yes", "yes",
   "inhomogeneous gauge term  -D[theta,x_mu] K"},
  {"omegaNull", "frameCanonical . U", "etaNull == sigma", "yes", "yes", "yes",
   "constant similarity only:  U omega U"},
  {"omegaOct", "frameCanonical . triVecToSpin", "etaTri == sigma", "yes", "yes",
   "NO: torsion == -2 lambda mSkew",
   "contortion  lambda mSkew[a,b,c] frameTri[[mu,c]]"}};
Grid[cfConnectionSummary, Frame -> All, Alignment -> Left,
  Background -> {None, {LightGray, None, None, None, None}}]
]];

(* ---------- Input cell 137 ---------- *)
cfRunCell[137, Hold[
(* --- numerical fingerprint: the count of non-zero components of each object -------------- *)
Grid[{
  {"object", "non-zero components"},
  {"Gamma (Christoffel)", Count[Flatten[GammaCanonical], Except[0]]},
  {"omegaCanonical", Count[Flatten[omegaCanonical], Except[0]]},
  {"omegaBoost", Count[Flatten[omegaBoost], Except[0]]},
  {"omegaNull", Count[Flatten[omegaNull], Except[0]]},
  {"omegaTriLC (lambda=0)", Count[Flatten[omegaTriLC], Except[0]]},
  {"contortionOct", Count[Flatten[contortionOct], Except[0]]},
  {"RiemannCanonical", Count[Flatten[RiemannCanonical], Except[0]]},
  {"RiemannBoost", Count[Flatten[RiemannBoost], Except[0]]},
  {"RiemannNull", Count[Flatten[RiemannNull], Except[0]]},
  {"torsionOctFlat", Count[Flatten[torsionOctFlat], Except[0]]}
 }, Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 138 ---------- *)
cfRunCell[138, Hold[
(* --- the three comparisons, side by side ------------------------------------------------ *)
Grid[{
  {"comparison", "statement proved above"},
  {"BRIDGE 1 vs canonical",
   "omegaBoost_mu == M omegaCanonical_mu Inverse[M] - D[M,x_mu] Inverse[M],  M = Transpose[Lambda];"
   <> "  the whole difference is -D[theta,x_mu] K, one scalar gradient times one fixed generator"},
  {"BRIDGE 2 vs canonical",
   "omegaNull_mu == U omegaCanonical_mu U   exactly, with no inhomogeneous term"},
  {"BRIDGE 3 vs canonical",
   "omegaOct_mu == Inverse[P] omegaCanonical_mu P + lambda mSkew . frameTri,  P = triVecToSpin"},
  {"curvature",
   "R transforms covariantly under bridges 1 and 2, so all three describe the same geometry; "
   <> "bridge 3 adds a torsion-dependent piece"},
  {"Ricci scalar", "identical for the canonical frame and bridges 1 and 2"},
  {"torsion",
   "zero for the canonical connection and for bridges 1 and 2;  -2 lambda mSkew for bridge 3"}
 }, Frame -> All, Alignment -> Left]
]];

(* ---------- Input cell 139 ---------- *)
cfRunCell[139, Hold[
(* --- final tally of every assertion made in this notebook -------------------------------- *)
Print["identities accepted on numerical evidence alone : ", $cfNumericCertificates,
      "   (stage 3 returned True)"];
Print["non-vanishing witnesses                         : ", $cfNonVanishingWitnesses,
      "   (stage 3 returned False inside a ! TrueQ[...] assertion;"];
Print["                                                     a sample point with a non-zero",
      " value is a complete proof of non-vanishing)"];
cfAssertSummary[]
]];

cfRunSummary[];
