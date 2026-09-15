(* ::CELLMANIFEST-PART:: 2 *)

(* ::Section:: *)
5.  The 16x16 Dirac matrices T16, the chirality operator, sigma16 and the so(4,4) generators

(* ::Text:: *)
Following E. A. Lord's reduced Brauer-Weyl construction ("The Dirac spinor in six dimensions",
Math. Proc. Camb. Phil. Soc. 64 (1968) 765-778), the 8x8 generators of Section 4 are promoted to
16x16 generators by the off-diagonal doubling

    T16[A] = ArrayFlatten[ { {0, taubar[A]}, {tau[A], 0} } ],      A = 0..7.

These are the Dirac matrices of this notebook.  Everywhere below, gamma[a] means T16[a].  The
doubling is exactly what realizes the 16-component spinor as the direct sum of a type-1 and a
type-2 split-octonion spinor: the upper 8 components are the type-1 spinor and the lower 8 are
the type-2 spinor, and each T16[A] exchanges them.

They obey the full Clifford relation of the 4+4 quadratic form,

    (1/2) ( T16[A] . T16[B] + T16[B] . T16[A] )  ==  eta4488[[A+1,B+1]] ID16 ,

equivalently  Anticommutator[gamma[a], gamma[b]] == 2 eta[a,b] ID16.

(* ::Input:: *)
ClearAll[T16, \[Sigma]16, covariantDiffMatrix];
Do[T16[A] = ArrayFlatten[{{0, \[Tau]bar[A]}, {\[Tau][A], 0}}], {A, 0, 7}];
(* T16[8] is the chirality operator: the ordered product of all eight generators. *)
T16[8] = Dot @@ Table[T16[A], {A, 0, 7}];
Dimensions[T16[0]]

(* ::Input:: *)
(* --- the defining Clifford relation for the 16x16 Dirac matrices ------------------------- *)
(* Optimization: the original wrapped this in FullSimplify.  Every entry here is an exact    *)
(* integer, so FullSimplify is a no-op that costs several seconds; it is dropped.  The       *)
(* identity being verified is byte-for-byte the one in the original notebook.                *)
cfAssert["{T16[A], T16[B]}/2 == eta4488[[A+1,B+1]] ID16",
  Table[(1/2) (T16[A] . T16[B] + T16[B] . T16[A]) === \[Eta]4488[[A + 1, B + 1]] ID16,
    {A, 0, 7}, {B, 0, 7}]];

(* ::Input:: *)
(* --- sigma16 is the 16x16 spinor metric; it is the product of the four spacelike gammas -- *)
\[Sigma]16 = T16[0] . T16[1] . T16[2] . T16[3];
cfAssert["sigma16 == ArrayFlatten[{{-sigma,0},{0,sigma}}]",
  \[Sigma]16 === ArrayFlatten[{{-\[Sigma], 0}, {0, \[Sigma]}}]];
cfAssert["sigma16 . T16[A] is antisymmetric for A = 0..7",
  Table[\[Sigma]16 . T16[A] === -Transpose[\[Sigma]16 . T16[A]], {A, 0, 7}]];
cfAssert["T16[8] == sigma16 . T16[4].T16[5].T16[6].T16[7]",
  T16[8] === \[Sigma]16 . T16[4] . T16[5] . T16[6] . T16[7]];
MatrixForm[\[Sigma]16]

(* ::Input:: *)
(* --- the matrix that the original notebook uses to build covariant differences ----------- *)
covariantDiffMatrix = T16[5] . T16[6] . T16[7];
cfAssert["sigma16 . covariantDiffMatrix is symmetric",
  \[Sigma]16 . covariantDiffMatrix === Transpose[\[Sigma]16 . covariantDiffMatrix]];
MatrixForm[covariantDiffMatrix]

(* ::Text:: *)
Chirality projectors.  T16[8] squares to the identity, so (ID16 -/+ T16[8])/2 are complementary
orthogonal projectors that split the 16-component spinor into its two 8-component chiral halves.

(* ::Input:: *)
ClearAll[PL, PR];
PL = (1/2) (ID16 - T16[8]);
PR = (1/2) (ID16 + T16[8]);
cfAssert["PL + PR == ID16", PL + PR === ID16];
cfAssert["PL is idempotent", PL . PL === PL];
cfAssert["PR is idempotent", PR . PR === PR];
cfAssert["PL . PR == PR . PL == 0", {PL . PR === ZERO16, PR . PL === ZERO16}];
{MatrixForm[PL], MatrixForm[PR]}

(* ::Text:: *)
The so(4,4) Lorentz generators in the 16-dimensional spinor representation,

    SAB[[A+1,B+1]] = S^{AB} = (1/4) Commutator[ T16[A], T16[B] ] .

These are the objects that appear in the spinor covariant derivative of Part III: the
combination (1/8) omega[mu,a,b] Commutator[gamma[a], gamma[b]] is exactly
(1/2) omega[mu,a,b] S^{ab}.

(* ::Input:: *)
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

(* ::Input:: *)
(* --- the so(4,4) commutation relations, over the 28 independent index pairs ------------- *)
(* [S_AB, S_CD] == -( eta_AC S_BD - eta_AD S_BC - eta_BC S_AD + eta_BD S_AC )               *)
cfTimed["so(4,4) commutators over 28 x 28 index pairs",
 cfAssert["[SAB,SAB] closes on the so(4,4) algebra",
  Flatten @ Table[
    SAB[[A1, B1]] . SAB[[A2, B2]] - SAB[[A2, B2]] . SAB[[A1, B1]] ===
      -(\[Eta]4488[[A1, A2]] SAB[[B1, B2]] - \[Eta]4488[[A1, B2]] SAB[[B1, A2]]
        - \[Eta]4488[[B1, A2]] SAB[[A1, B2]] + \[Eta]4488[[B1, B2]] SAB[[A1, A2]]),
    {A1, 1, 7}, {B1, A1 + 1, 8}, {A2, 1, 7}, {B2, A2 + 1, 8}]]];

(* ::Input:: *)
(* --- S_AB rotates the gammas as a vector: [S_AB, gamma_C] == -eta_CA gamma_B + eta_CB gamma_A *)
cfTimed["vector transformation law of the gammas",
 cfAssert["[SAB, T16] reproduces the vector representation",
  Flatten @ Table[
    SAB[[A1, B1]] . T16[B2 - 1] - T16[B2 - 1] . SAB[[A1, B1]] ===
      -\[Eta]4488[[B2, A1]] T16[B1 - 1] + \[Eta]4488[[B2, B1]] T16[A1 - 1],
    {A1, 1, 8}, {B1, 1, 8}, {B2, 1, 8}]]];

(* ::Section:: *)
6.  A complete basis of the 16x16 matrix algebra

(* ::Text:: *)
The Clifford algebra generated by eight 16x16 gammas has 2^8 = 256 = 16 x 16 independent
elements, namely the ordered products of k distinct generators for k = 1..8 together with the
identity.  The original notebook builds these with eight nested Do loops and AppendTo.  We build
the same list, in exactly the same order, with Subsets, which enumerates index tuples in
lexicographic order and is both shorter and quadratically faster.  The order matters because the
original refers to particular positions in it (93 and 255), and those references are re-verified
below.

(* ::Input:: *)
ClearAll[cfCliffordWord, base16];
(* cfCliffordWord[{j1,...,jk}] is the ordered product T16[j1]. ... .T16[jk] *)
cfCliffordWord[idx_List] := Dot @@ (T16 /@ idx);
base16 = cfTimed["build the 256-element basis of the 16x16 algebra",
  Join[
    Sequence @@ Table[{cfCliffordWord[#], #} & /@ Subsets[Range[0, 7], {k}], {k, 1, 8}],
    {{ID16, {Range[0, 7]}}}]];
{Length[base16], Length[Union[base16[[All, 1]]]]}

(* ::Input:: *)
(* --- the two positional references made by the original notebook ------------------------- *)
cfAssert["base16[[93]] is sigma16", \[Sigma]16 === base16[[93, 1]]];
cfAssert["base16[[255]] is the chirality operator T16[8]", T16[8] === base16[[255, 1]]];
cfAssert["base16[[256]] is the identity", ID16 === base16[[256, 1]]];
{base16[[93, 2]], base16[[255, 2]], base16[[256, 2]]}

(* ::Input:: *)
(* --- every basis element squares to +ID16 or -ID16, so Tr[M.M]/16 is +1 or -1 ------------ *)
cfAssert["Tr[M.M]/16 is +1 or -1 for every basis element",
  MemberQ[{1, -1}, #] & /@ Union[Flatten[Tr[#. #/16] & /@ base16[[All, 1]]]]];
Union[Flatten[Tr[#. #/16] & /@ base16[[All, 1]]]]

(* ::Input:: *)
(* --- split the basis by the sign of Tr[M.M]; the original records 136 and 120 ----------- *)
ClearAll[positiveTrMM, negativeTrMM];
positiveTrMM = Select[base16, Tr[#[[1]] . #[[1]]] > 0 & -> "Index"];
negativeTrMM = Select[base16, Tr[#[[1]] . #[[1]]] < 0 & -> "Index"];
cfAssert["136 basis elements have Tr[M.M] > 0", Length[positiveTrMM] === 136];
cfAssert["120 basis elements have Tr[M.M] < 0", Length[negativeTrMM] === 120];
{Length[positiveTrMM], Length[negativeTrMM]}

(* ::Input:: *)
(* --- and the same split is the symmetric / antisymmetric split: 16*17/2 and 16*15/2 ------ *)
ClearAll[symm16, antisymm16];
symm16     = Select[Range[Length[base16]], base16[[#, 1]] ===  Transpose[base16[[#, 1]]] &];
antisymm16 = Select[Range[Length[base16]], base16[[#, 1]] === -Transpose[base16[[#, 1]]] &];
cfAssert["symmetric basis elements number 16*17/2 = 136", Length[symm16] === 136];
cfAssert["antisymmetric basis elements number 16*15/2 = 120", Length[antisymm16] === 120];
cfAssert["Tr[M.M] > 0 exactly when M is symmetric", Sort[symm16] === Sort[positiveTrMM]];
cfAssert["Tr[M.M] < 0 exactly when M is antisymmetric", Sort[antisymm16] === Sort[negativeTrMM]];
{Length[symm16], Length[antisymm16], 16 (16 + 1)/2, 16 (16 - 1)/2}

(* ::Input:: *)
(* --- the original also removes sign-duplicates to get a projective basis ----------------- *)
ClearAll[dups, BASE16, use16];
dups = cfTimed["find sign-duplicate basis elements",
  Select[base16, MemberQ[base16[[All, 1]], -#[[1]]] &]];
BASE16 = use16 = Complement[base16, dups];
{Length[dups], Length[use16]}

(* ::Section:: *)
7.  A complete basis of the 8x8 matrix algebra, and the induced flat metric

(* ::Text:: *)
The same construction one level down.  The 8x8 algebra generated by tau[1]..tau[7] has
7 + 21 + 35 = 63 independent products plus the identity, i.e. 64 = 8 x 8 elements.  The trace
form (1/8) Tr[M.M] on this basis is the diagonal metric eta64; its trace counts the signature.

(* ::Input:: *)
ClearAll[bas64, \[Eta]64];
bas64 = Join[
   Sequence @@ Table[{Dot @@ (\[Tau] /@ #), #} & /@ Subsets[Range[1, 7], {k}], {k, 1, 3}],
   {{ID8, {64}}}];
cfAssert["the 8x8 basis has 64 elements", Length[bas64] === 64];
cfAssert["the 64 elements are distinct", Length[Union[bas64[[All, 1]]]] === 64];
\[Eta]64 = DiagonalMatrix[Table[(1/8) Tr[bas64[[A, 1]] . bas64[[A, 1]]], {A, 64}]];
{Length[bas64], Tr[\[Eta]64], Union[Diagonal[\[Eta]64]]}

(* ::Input:: *)
(* --- the trace form is orthogonal: (1/8) Tr[M_A . M_B] is diagonal ---------------------- *)
cfTimed["orthogonality of the 64-element trace form",
 cfAssert["(1/8) Tr[bas64[A].bas64[B]] == eta64[[A,B]]",
  Flatten @ Table[(1/8) Tr[bas64[[A, 1]] . bas64[[B, 1]]] === \[Eta]64[[A, B]],
    {A, 1, 64}, {B, 1, 64}]]];

(* ::Input:: *)
(* --- symmetric / antisymmetric split of the 8x8 basis: 8*9/2 = 36 and 8*7/2 = 28 -------- *)
ClearAll[symm8, anti8];
symm8 = Select[Range[64], bas64[[#, 1]] ===  Transpose[bas64[[#, 1]]] &];
anti8 = Select[Range[64], bas64[[#, 1]] === -Transpose[bas64[[#, 1]]] &];
cfAssert["symmetric 8x8 basis elements number 36", Length[symm8] === 36];
cfAssert["antisymmetric 8x8 basis elements number 28", Length[anti8] === 28];
{Length[symm8], Length[anti8]}

(* ::Section:: *)
8.  The 4x4 Dirac matrices, and a complete basis of the 4x4 matrix algebra

(* ::Text:: *)
The original notebook also carries the ordinary four-dimensional Dirac algebra, because the
(x1,x2,x3,x4) block of the 4+4 metric is an ordinary Minkowski space of signature (+,+,+,-).
Its 4x4 metric is the sub-block g44 = eta4488[[2;;5, 2;;5]] = diag(1,1,1,-1).

The four gammas are built from the same self-dual and anti-self-dual SO(4) blocks of Section 3.
With g3 = diag(1,1,-1) and Gr[h,k] = -g3[[h,h]] g3[[k,k]] t4by4[h] . s4by4[k], the original takes

    gamma = { Gr[1,1], Gr[1,2], Gr[1,3], t4by4[2] } ,      gamma[5] = -gamma[1].gamma[2].gamma[3].gamma[4]

and the four of them satisfy the four-dimensional Clifford relation
Anticommutator[gamma[h], gamma[k]] == 2 g44[[h,k]] ID4.  The associated Lorentz generators are
S44 = -(1/4) Commutator[gamma[h], gamma[k]].

(* ::Input:: *)
ClearAll[g44, g3, Gr, \[Gamma]4];
g44 = \[Eta]4488[[2 ;; 5, 2 ;; 5]];
g3 = DiagonalMatrix[{1, 1, -1}];
Do[Gr[h, k] = t4by4[h] . s4by4[k] (-g3[[h, h]] g3[[k, k]]), {h, 1, 3}, {k, 1, 3}];
\[Gamma]4 = {Gr[1, 1], Gr[1, 2], Gr[1, 3], t4by4[2]};
AppendTo[\[Gamma]4, -\[Gamma]4[[1]] . \[Gamma]4[[2]] . \[Gamma]4[[3]] . \[Gamma]4[[4]]];
cfAssert["g44 == diag(1,1,1,-1)", g44 === DiagonalMatrix[{1, 1, 1, -1}]];
cfAssert["gamma4[[5]] == -t4by4[3]", \[Gamma]4[[5]] === -t4by4[3]];
{MatrixForm[g44], MatrixForm /@ \[Gamma]4}

(* ::Input:: *)
(* --- the four-dimensional Clifford relation, and the fifth gamma ------------------------- *)
cfAssert["{gamma4[h], gamma4[k]} == 2 g44[[h,k]] ID4  for h,k = 1..4",
  Table[\[Gamma]4[[h]] . \[Gamma]4[[k]] + \[Gamma]4[[k]] . \[Gamma]4[[h]] === 2 g44[[h, k]] ID4,
    {h, 1, 4}, {k, 1, 4}]];
cfAssert["{gamma4[h], gamma4[k]} == 2 eta4488[[1+h,1+k]] ID4  for h,k = 1..5",
  Table[\[Gamma]4[[h]] . \[Gamma]4[[k]] + \[Gamma]4[[k]] . \[Gamma]4[[h]] ===
     2 \[Eta]4488[[1 + h, 1 + k]] ID4, {h, 1, 5}, {k, 1, 5}]];

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Input:: *)
(* --- and the 1 + 4 + 6 + 4 + 1 symmetry pattern of the 4x4 basis ------------------------- *)
cfAssert["the 4x4 basis splits 10 symmetric + 6 antisymmetric",
  {Length[Select[base4by4, #[[1]] ===  Transpose[#[[1]]] &]] === 10,
   Length[Select[base4by4, #[[1]] === -Transpose[#[[1]]] &]] ===  6}];
{Plus @@ {1, 4, 6, 4, 1},
 Length[Select[base4by4, #[[1]] === Transpose[#[[1]]] &]],
 Length[Select[base4by4, #[[1]] === -Transpose[#[[1]]] &]]}

(* ::Section:: *)
9.  Cartan triality: the constant bridge between the vector and spinor realizations,
    and the split-octonion structure constants

(* ::Text:: *)
The split octonion algebra O(4,4) carries three inequivalent-looking but equivalent 8-component
representations of Spin(4,4): the vector, the type-1 spinor and the type-2 spinor.  That is
Cartan's triality.  The original notebook realizes the vector-to-spinor bridge concretely by
picking one distinguished isotropic direction.

Take the eigensystem of the spinor metric sigma.  Its eigenvectors, rescaled by 1/Sqrt[2], form
the matrix uEig.  Rows 1..4 have eigenvalue -1 and rows 5..8 have eigenvalue +1.  The original
selects row hUSE = 8 and calls it unit; it is a unit-norm spinor, Transpose[unit].sigma.unit == 1.

(* ::Input:: *)
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

(* ::Text:: *)
The triality bridge itself.  Define the 8x8 matrix

    triVecToSpin[[A+1, a+1]]  =  ( unit . sigma . taubar[A] )[[a+1]] ,

which carries a FLAT VECTOR index A (row) and a FLAT TYPE-1 SPINOR index a (column).  This is
the object written E^{(A)}_a, equivalently F_a{}^A, in the original notebook.  Its inverse
triSpinToVec carries the indices the other way round, and the original gives a closed form for
it that we verify rather than assume.

(* ::Input:: *)
ClearAll[triVecToSpin, triSpinToVec];
triVecToSpin = Table[unit . \[Sigma] . \[Tau]bar[A], {A, 0, 7}];
triSpinToVec = Inverse[triVecToSpin];
cfAssert["triVecToSpin . triSpinToVec == ID8", triVecToSpin . triSpinToVec === ID8];
cfAssert["triSpinToVec . triVecToSpin == ID8", triSpinToVec . triVecToSpin === ID8];
(* the original's closed form for the inverse bridge *)
cfAssert["triSpinToVec == Transpose[ eta_AA tau[A].unit ]  (the original's closed form)",
  triSpinToVec === Transpose[Table[\[Eta]4488[[A + 1, A + 1]] (\[Tau][A] . unit), {A, 0, 7}]]];
MatrixForm[triVecToSpin]

(* ::Text:: *)
What flat tangent metric does the triality bridge induce?  If a vector v with flat components
v^A is carried to the spinor components w^a = v^A triVecToSpin[[A,a]], then the flat length
v.eta.v becomes w . etaTri . w with

    etaTri  =  Inverse[triVecToSpin] . eta4488 . Inverse[Transpose[triVecToSpin]] .

We compute it and find that it is EXACTLY the split-octonion spinor metric sigma.  That is the
precise sense in which the type-1 spinor space is an isometric copy of the 4+4 vector space, and
it is what makes the third new bridge, Section 20, possible.

(* ::Input:: *)
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

(* ::Text:: *)
The split-octonion multiplication constants.  With the triality bridge in hand, the product of
two basis units is read off from the Clifford generators:

    mabc[[a,b,c]] = Sum over A of  triVecToSpin[[A,a]] * ( eta_AA tau[A-1] )[[c,b]]
    mABC[[A,B,C]] = Sum over b,c of triVecToSpin[[C,c]] ( eta_AA tau[A-1] )[[c,b]] triSpinToVec[[b,B]]

mabc is the multiplication table in the type-1 spinor basis; mABC is the same table in the
vector basis, which is the one usually displayed as "the split octonion multiplication table".

(* ::Input:: *)
ClearAll[\[Tau]A, mabc, mABC];
\[Tau]A = Table[\[Eta]4488[[A, A]] \[Tau][A - 1], {A, 1, 8}];
mabc = cfTimed["split-octonion structure constants in the spinor basis",
  Table[Sum[triVecToSpin[[A1, a1]] \[Tau]A[[A1]][[c1, b1]], {A1, 1, 8}],
    {a1, 1, 8}, {b1, 1, 8}, {c1, 1, 8}]];
mABC = cfTimed["split-octonion structure constants in the vector basis",
  Table[Sum[triVecToSpin[[C1, c1]] \[Tau]A[[A1]][[c1, b1]] triSpinToVec[[b1, B1]],
      {b1, 1, 8}, {c1, 1, 8}], {A1, 1, 8}, {B1, 1, 8}, {C1, 1, 8}]];
{Dimensions[mabc], Dimensions[mABC]}

(* ::Input:: *)
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

(* ::Input:: *)
(* --- eA[1] is the unit of the algebra: eA[1] x = x eA[1] = x ---------------------------- *)
cfAssert["eA[1] is a two-sided identity for the vector-basis product",
  Join[
   Flatten @ Table[Sum[mABC[[1, B1, C1]] ID8[[C1]], {C1, 8}] === ID8[[B1]], {B1, 1, 8}],
   Flatten @ Table[Sum[mABC[[A1, 1, C1]] ID8[[C1]], {C1, 8}] === ID8[[A1]], {A1, 1, 8}]]];
Table[Sum[mABC[[1, B1, C1]] EA[[C1]], {C1, 8}], {B1, 8}]

(* ::Input:: *)
(* --- the norm is multiplicative on basis units: m^C_AB eta_CD m^D_AB = eta_AA eta_BB ----- *)
cfAssert["<eA, eB> composition is compatible with eta (basis-unit norm form)",
  Flatten @ Table[
    Sum[mABC[[A1, B1, C1]] \[Eta]4488[[C1, D1]] mABC[[A1, B1, D1]], {C1, 8}, {D1, 8}] ===
      \[Eta]4488[[A1, A1]] \[Eta]4488[[B1, B1]],
    {A1, 1, 8}, {B1, 1, 8}]];

(* ::Input:: *)
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
