(* ::CELLMANIFEST-PART:: 1 *)

(* ::Title:: *)
claude-fable_Einstein-Rosen-2-Planes
Pre-gravity, Pre-Big-Bang: 3 Generations of Einstein-Rosen 2-Plane Bridges
Frame fields, spin connections and the 16-component split-octonion spinor on a curved 4+4 spacetime

(* ::Text:: *)
Refactored, commented and optimized from the author's scratch notebook
"Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb".

Original mathematics and physics: Patrick L. Nash, Ph.D. (c) 2022, under the GNU General Public License.
Professor, UTSA Physics and Astronomy, Retired.  Patrick299Nash at gmail.
Please cite that work, and this web page, if you use it.

Refactoring, the frame-field / spin-connection chapters, and the three new bridges:
prepared with Claude (Anthropic) at the author's direction, 2026-09-14.

WARNING (from the original): syncope, presyncope AHEAD.

Whenever possible we follow ROBERT L. BRYANT, "SUBMANIFOLDS AND SPECIAL STRUCTURES ON THE
OCTONIANS", J. Differential Geometry 17 (1982) 185-232; all errors are definitely ours.

(* ::Section:: *)
0.  What this notebook does, and how it is organized

(* ::Text:: *)
PART I  (Sections 1-9) rebuilds, verifies and optimizes the algebraic engine of the original
notebook: the flat 4+4 Minkowski metric, the real 8x8 Clifford generators tau, the 16x16 Dirac
matrices T16, the so(4,4) generators SAB, the 256-element basis of the 16x16 matrix algebra,
the 4x4 Dirac matrices, and the split-octonion structure constants obtained by Cartan triality.

PART II (Sections 10-14) reproduces the original physics: the 16-component wave function Psi16
of the "un-universe", its Lagrangian, the Euler-Lagrange equations, the change of variables to
light-cone-like coordinates (z,t), the decoupling into four blocks of four equations, the Maple
closed-form solutions, the bilinear invariants, and the M6 = 3 generations of Einstein-Rosen
2-plane bridges.

PART III (Sections 15-17) is new.  It makes explicit the local flat 4+4 Minkowski coordinate
system that exists at every point of the curved 4+4 spacetime, i.e. the frame field (vielbein)
e, and then computes

  [a] the curved metric            g[mu,nu],
  [b] the flat Minkowski metric    eta[a,b],
  [c] the frame field              e[mu,a],
  [d] the bridge                   g[mu,nu] == e[mu,a] eta[a,b] e[nu,b],
  [e] the canonical spin connection omega[mu,a,b] from the zero-torsion vielbein postulate
      D[e[nu,a], x[mu]] - Gamma[rho,mu,nu] e[rho,a] + omegaMixed[mu,a,b] e[nu,b] == 0,
  [f] the gauge-covariant derivative of the 16-component spinor
      Dcov[mu] psi == D[psi, x[mu]] + (1/8) omega[mu,a,b] Commutator[gamma[a], gamma[b]] . psi,
      where gamma[a] are the 16x16 Dirac matrices T16 built in Section 5.

A vielbein here is simply an 8-dimensional vierbein, i.e. an 8-dimensional frame field.

PART IV (Sections 18-21) is also new.  It invents three further ways of bridging curved
spacetime indices to flat tangent-space indices, derives a new spin connection for each, and
compares every one of them, component by component, to the canonical spin connection of Part III.

(* ::Section:: *)
1.  Session setup

(* ::Text:: *)
We keep the original notebook's session policy: Simplify gets a time constraint of 1 second per
sub-problem and FullSimplify gets 3 seconds, spelling warnings are switched off, and the
dimension of the algebra is 8.  These are the original tolerances and they are not changed here.

(* ::Input:: *)
(* --- provenance banner, as in the original notebook ------------------------------------- *)
Print["CopyRight (C) 2022, Patrick L. Nash, under the General Public License."];
Print["Please cite this work, and this web page, if you use it."];
Print["Refactored for claude-fable_Einstein-Rosen-2-Planes.nb; Wolfram Language ", $Version];

(* ::Input:: *)
(* --- session options: identical to the original ------------------------------------------ *)
SetOptions[Simplify, TimeConstraint -> 1];
SetOptions[FullSimplify, TimeConstraint -> 3];
{Off[General::spell], Off[General::spell1]};
Options[Simplify]
Options[FullSimplify]

(* ::Input:: *)
(* --- the one global dimension constant --------------------------------------------------- *)
ClearAll[DIM8];
DIM8 = 8;
(* M (mass), K and H (the Hubble-like constant) are the model's three scalar constants; the *)
(* original notebook protects them here so that no later cell can accidentally assign them. *)
Protect[DIM8, M, K, H];
{DIM8, Attributes[M], Attributes[K], Attributes[H]}

(* ::Text:: *)
A small timing helper.  Every expensive step in this notebook is wrapped in it so that a reader
can see immediately where the time goes.  It prints the wall-clock cost and returns the value
unchanged, so it can be inserted anywhere without altering the mathematics.

(* ::Input:: *)
ClearAll[cfTimed];
SetAttributes[cfTimed, HoldRest];
cfTimed[label_String, expr_] := Module[{t, r},
  {t, r} = AbsoluteTiming[expr];
  Print["  [", ToString[NumberForm[N[t], {6, 3}, ExponentFunction -> (Null &)]], " s]  ", label];
  r];

(* ::Text:: *)
A reporting helper for the many algebraic identities that this notebook verifies.  It reduces a
whole table of assertions to a single True/False and prints a one-line verdict, which is far
cheaper to read than the original notebook's pages of nested True lists.

(* ::Input:: *)
ClearAll[cfAssert, $cfAssertLog];
$cfAssertLog = {};
cfAssert[label_String, value_] := Module[{flat, ok},
  flat = Union[Flatten[{value}]];
  ok = (flat === {True});
  AppendTo[$cfAssertLog, {label, ok}];
  Print[If[ok, "  PASS  ", "  FAIL  "], label,
    If[ok, "", "   -> distinct values: " <> ToString[Short[flat, 3], InputForm]]];
  ok];

(* ::Input:: *)
(* --- summary of every assertion made so far --------------------------------------------- *)
ClearAll[cfAssertSummary];
cfAssertSummary[] := Module[{n, bad},
  n = Length[$cfAssertLog];
  bad = Cases[$cfAssertLog, {l_, False} :> l];
  Print["Assertions run: ", n, "   passed: ", n - Length[bad], "   failed: ", Length[bad]];
  If[bad =!= {}, Print["FAILED: ", Column[bad]]];
  Grid[Prepend[$cfAssertLog, {"assertion", "ok"}], Frame -> All, Alignment -> Left]];

(* ::Section:: *)
2.  Coordinates and the flat 4+4 Minkowski metric eta

(* ::Text:: *)
Coordinates, following the original notebook (which took them from the author's earlier
Eternal-DEFLATION-Inflation work):

    { x0 | x1 x2 x3 | x4 | x5 x6 x7 }
      |      |         |      |
      |      |         |      +-- superluminal deflating time directions (3)
      |      |         +--------- time
      |      +------------------- ordinary 3-space
      +-------------------------- hidden space

The flat metric eta4488 has signature (4,4): the first four directions are spacelike (+1) and
the last four are timelike (-1).  Throughout this notebook a capital Latin index A,B,... or a
lower-case a,b,... is a FLAT tangent-space index and runs 0..7; a Greek index mu,nu,alpha,...
is a CURVED spacetime index and also runs 0..7.  Wolfram array positions are 1-based, so the
flat index A sits at array position A+1.  Every place where that shift matters is flagged.

(* ::Input:: *)
ClearAll[X, x0, x1, x2, x3, x4, x5, x6, x7];
X = {x0, x1, x2, x3, x4, x5, x6, x7};
Protect[X, x0, x1, x2, x3, x4, x5, x6, x7];
X

(* ::Input:: *)
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

(* ::Input:: *)
(* --- eta is its own inverse, so raising and lowering flat indices is cheap --------------- *)
cfAssert["eta4488 . eta4488 == ID8", \[Eta]4488 . \[Eta]4488 === ID8];
cfAssert["eta4488 is symmetric", \[Eta]4488 === Transpose[\[Eta]4488]];
cfAssert["signature of eta4488 is (4,4)", Sort[Diagonal[\[Eta]4488]] === Sort[{1,1,1,1,-1,-1,-1,-1}]];
Diagonal[\[Eta]4488]

(* ::Text:: *)
The Levi-Civita symbols of the original notebook.  epsilon3 is used for the SO(3) structure
constants and epsilon4 for the 4-dimensional duality operation that splits the antisymmetric
4x4 matrices into self-dual and anti-self-dual halves.

(* ::Input:: *)
ClearAll[\[Epsilon]3, \[Epsilon]4];
\[Epsilon]3 = Array[Signature[{##}] &, {3, 3, 3}];
\[Epsilon]4 = Array[Signature[{##}] &, {4, 4, 4, 4}];
{Dimensions[\[Epsilon]3], Dimensions[\[Epsilon]4], \[Epsilon]4[[1, 2, 3, 4]]}

(* ::Text:: *)
Positivity assumptions used by Simplify throughout.  These are exactly the assumptions of the
original notebook: constraintVars for the (z,t) chart and ssX for the (x0,x4) chart.
Note that la is a free scalar function inherited from the original notebook; it is never given
a definition there and we do not invent one here.

(* ::Input:: *)
ClearAll[sX0, ssX, constraintVars];
sX0 = And @@ Thread[X > 0];
ssX = H > 0 && sX0 && 6 H x0 > 0 && 2 la[x4] > 0 && Cot[6 H x0] > 0 && Sin[6 H x0] > 0;
constraintVars = x0 > 0 && x4 > 0 && z > 0 && t > 0;
{sX0, ssX, constraintVars}

(* ::Input:: *)
(* --- the (x0,x4) <-> (z,t) chart change of the original notebook ------------------------- *)
ClearAll[szt, sx0x4];
szt   = Solve[6 H x0 == z && H x4 == t, {z, t}][[1]];
sx0x4 = Solve[6 H x0 == z && H x4 == t, {x0, x4}][[1]];
Protect[szt, sx0x4];
{szt, sx0x4}

(* ::Section:: *)
3.  SO(4): self-dual and anti-self-dual antisymmetric 4x4 matrices

(* ::Text:: *)
The six-dimensional space of antisymmetric real 4x4 matrices splits, under the Hodge star built
from epsilon4, into a self-dual 3-space and an anti-self-dual 3-space.  The original notebook
builds explicit bases for both from two elementary tensors:

    Qa[h,p,q] = Signature[{h,p,q,4}]                            (the 3-dimensional epsilon)
    Qb[h,p,q] = KroneckerDelta[p,4] KroneckerDelta[q,h]
              - KroneckerDelta[p,h] KroneckerDelta[q,4]

with s4by4[h] = Qa - Qb self-dual and t4by4[h] = Qa + Qb anti-self-dual, h = 1,2,3.
These are the two commuting su(2) factors of so(4) = su(2) + su(2).

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Input:: *)
(* --- the nine mixed products st[J,K], used to complete the 4x4 basis -------------------- *)
ClearAll[st];
Do[st[J, K] = s4by4[J] . t4by4[K], {J, 1, 3}, {K, 1, 3}];
Protect[st];
cfAssert["st[J,K] is symmetric", Table[st[J, K] === Transpose[st[J, K]], {J, 3}, {K, 3}]];
Grid[Table[MatrixForm[st[J, K]], {J, 3}, {K, 3}], Frame -> All]

(* ::Section:: *)
4.  The real 8x8 Clifford generators tau, their conjugates, and the spinor metric sigma

(* ::Text:: *)
sigma is the O(4,4) spinor metric.  It is the 8x8 symmetric matrix that pairs the first four
spinor components with the last four; it is its own inverse and it is traceless.  In the
language of the original notebook, both the type-1 and the type-2 split-octonion spinors carry
this same sigma (the usual notational abuse), since sigma == Inverse[sigma].

(* ::Input:: *)
ClearAll[\[Sigma]];
\[Sigma] = ArrayFlatten[{{Zero4, ID4}, {ID4, Zero4}}];
cfAssert["sigma . sigma == ID8", \[Sigma] . \[Sigma] === ID8];
cfAssert["sigma is symmetric", \[Sigma] === Transpose[\[Sigma]]];
cfAssert["Tr[sigma] == 0", Tr[\[Sigma]] === 0];
MatrixForm[\[Sigma]]

(* ::Text:: *)
Six 8x8 matrices are assembled from the SO(4) blocks.  The first three use the self-dual blocks
in a symmetric off-diagonal arrangement, the last three use the anti-self-dual blocks in an
antisymmetric arrangement, and the anti-self-dual ones are taken in reverse order h = 3,2,1 so
that the resulting tau matrices come out in the order fixed by the original notebook.  That
ordering matters: it is what makes tau[7] equal the product tau[1]...tau[6] and what makes
sigma equal tau[1].tau[2].tau[3].

A caution for readers of the original notebook.  The variable is called sixAntiSymmetric8by8
there, and we keep that name so the two notebooks can be read side by side, but the name is a
misnomer for half of its contents: only the first three matrices are antisymmetric.  The last
three are SYMMETRIC, because transposing ArrayFlatten[{{0,t},{-t,0}}] with t antisymmetric
gives the matrix back unchanged.  That is not a defect.  It is precisely what the signature
demands, and the correct statement is verified below:

    Transpose[tau[A]] == -eta4488[[A+1,A+1]] tau[A],   A = 1..7,

so tau[1],tau[2],tau[3] (where eta = +1) are antisymmetric and tau[4],tau[5],tau[6] (where
eta = -1) are symmetric.

(* ::Input:: *)
ClearAll[sixAntiSymmetric8by8];
sixAntiSymmetric8by8 = Join[
   Table[ArrayFlatten[{{0, s4by4[h]}, { s4by4[h], 0}}], {h, 1, 3}],
   Table[ArrayFlatten[{{0, t4by4[h]}, {-t4by4[h], 0}}], {h, 3, 1, -1}]];
cfAssert["blocks 1-3 (built from s4by4) are antisymmetric",
  Table[sixAntiSymmetric8by8[[k]] === -Transpose[sixAntiSymmetric8by8[[k]]], {k, 1, 3}]];
cfAssert["blocks 4-6 (built from t4by4) are symmetric",
  Table[sixAntiSymmetric8by8[[k]] === Transpose[sixAntiSymmetric8by8[[k]]], {k, 4, 6}]];
Length[sixAntiSymmetric8by8]

(* ::Text:: *)
The 8x8 real Clifford generators.  tau[0] is the identity; tau[1]..tau[6] are the six
antisymmetric blocks just built; tau[7] is their ordered product.  The conjugate generator is
taubar[A] = sigma . Transpose[sigma . tau[A]], which is the sigma-adjoint of tau[A].

Together they realize the split Clifford algebra of the 4+4 quadratic form in its 8x8 real
"half-spinor" form:

    (1/2) ( tau[A] . taubar[B] + tau[B] . taubar[A] )  ==  eta4488[[A+1,B+1]] ID8 .

(* ::Input:: *)
ClearAll[\[Tau], \[Tau]bar];
\[Tau][0] = ID8;
Do[\[Tau][h] = sixAntiSymmetric8by8[[h]], {h, 1, 6}];
\[Tau][7] = \[Tau][1] . \[Tau][2] . \[Tau][3] . \[Tau][4] . \[Tau][5] . \[Tau][6];
Do[\[Tau]bar[A] = \[Sigma] . Transpose[\[Sigma] . \[Tau][A]], {A, 0, 7}];
MatrixForm[\[Tau][7]]

(* ::Input:: *)
(* --- the defining Clifford relation ------------------------------------------------------ *)
cfAssert["(1/2)(tau[A].taubar[B] + tau[B].taubar[A]) == eta4488[[A+1,B+1]] ID8",
  Table[(1/2) (\[Tau][A] . \[Tau]bar[B] + \[Tau][B] . \[Tau]bar[A]) ===
        \[Eta]4488[[A + 1, B + 1]] ID8, {A, 0, 7}, {B, 0, 7}]];

(* ::Input:: *)
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

(* ::Input:: *)
(* --- Omega = sigma . tau[7] is the second invariant of the original notebook ------------- *)
ClearAll[\[CapitalOmega]];
\[CapitalOmega] = \[Sigma] . \[Tau][7];
cfAssert["Omega == tau[4].tau[5].tau[6]",
  \[CapitalOmega] === \[Tau][4] . \[Tau][5] . \[Tau][6]];
{Det[\[CapitalOmega]], MatrixForm[\[CapitalOmega]]}
