(* ::CELLMANIFEST-PART:: 4 *)

(* ::Title:: *)
PART III  --  The curved 4+4 spacetime, its frame field, and the canonical spin connection

(* ::Section:: *)
15.  The local flat 4+4 Minkowski coordinate system at every spacetime point

(* ::Text:: *)
This is the part of the construction that the original notebook records as a result but never
derives.  We set it out completely.

At every point of the curved 4+4 spacetime there is a local flat 4+4 Minkowski coordinate
system.  The object that installs it is the FRAME FIELD, also called the vielbein: in eight
dimensions a vielbein is simply an 8-dimensional vierbein, i.e. an 8-dimensional frame field.
Writing mu, nu for curved spacetime indices and a, b for flat tangent-space indices, the frame
field e[mu,a] is the bridge

    [a]  curved metric          g[mu,nu]
    [b]  flat Minkowski metric  eta[a,b]     (here eta4488, signature 4+4)
    [c]  frame field            e[mu,a]
    [d]  the bridge             g[mu,nu] == e[mu,a] eta[a,b] e[nu,b]

In Wolfram arrays we store the frame as an 8x8 matrix whose ROW index is the curved index mu
and whose COLUMN index is the flat index a, so [d] is the single matrix statement

    g == frame . eta4488 . Transpose[frame] .

The inverse frame (the coframe) is the matrix inverse, stored with the flat index on the row:

    coframe == Inverse[frame],   coframe[[a,nu]] = e_a{}^nu,
    coframe . frame == frame . coframe == ID8 .

(* ::Input:: *)
(* --- a notice helper, used whenever we meet a symbol the original never defines ---------- *)
ClearAll[cfNote];
cfNote[title_String, body_String] := (
  Print["  NOTE  ", title];
  Print["        ", body];
  Style[Column[{Style[title, Bold], body}], Background -> LightYellow]);

(* ::Input:: *)
(* --- HARD REQUIREMENT: report, do not invent, every symbol the original leaves undefined -- *)
cfNote["a4 is an undefined scalar function inherited from the original notebook",
 "The canonical frame field below contains Exp[-a4[H x4]] and Exp[+a4[H x4]].  The original \
notebook never gives a4 a definition; it appears only inside the recorded value of the frame \
field.  We therefore carry a4 through symbolically and we do NOT invent a value for it.  Every \
result in Parts III and IV is valid for an arbitrary differentiable a4.  The same applies to \
la, which occurs only inside the assumption ssX of Section 2."];

(* ::Text:: *)
The canonical frame field of this geometry.  It is the diagonal 8x8 matrix recorded in the
original notebook as the value of the symbol written there "gtrye with indices alpha and (A)":

    diag( Tan[6 H x0],  q, q, q,  1,  p, p, p )

    q = Exp[-a4[H x4]] / Sin[6 H x0]^(1/6)        (the three spacelike 3-space directions)
    p = Exp[+a4[H x4]] / Sin[6 H x0]^(1/6)        (the three superluminal deflating directions)

The hidden-space direction x0 carries Tan[6 H x0] and the time direction x4 carries 1.  Since
eta4488 = diag(1,1,1,1,-1,-1,-1,-1), the line element is

    ds^2 =  Tan[6 H x0]^2 dx0^2
          + q^2 ( dx1^2 + dx2^2 + dx3^2 )
          -      dx4^2
          - p^2 ( dx5^2 + dx6^2 + dx7^2 ) .

Note the two exponentials are reciprocal: q p = 1/Sin[6 H x0]^(1/3).  The 3-space directions
contract exactly as fast as the deflating directions expand.  That reciprocity is the geometric
content of "pre-gravity, pre-Big-Bang" in this model, and it is what makes the Einstein-Rosen
pairing of Section 19 natural.

(* ::Input:: *)
ClearAll[cfQminus, cfQplus, frameCanonical, coframeCanonical, gCanonical, gInvCanonical];
cfQminus = Exp[-a4[H x4]]/Sin[6 H x0]^(1/6);
cfQplus  = Exp[+a4[H x4]]/Sin[6 H x0]^(1/6);
frameCanonical = DiagonalMatrix[{Tan[6 H x0],
    cfQminus, cfQminus, cfQminus, 1, cfQplus, cfQplus, cfQplus}];
MatrixForm[frameCanonical]

(* ::Input:: *)
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

(* ::Text:: *)
A note on how identities are certified in Parts III and IV.

Section 1 set the original notebook's session policy, Simplify with a 1-second budget per
sub-problem.  That budget is right for the algebra of Parts I and II, where every entry is an
exact integer or a short rational, but it is not always enough for the curved-space expressions
here, which mix Tan, Sin^(1/6), Exp of an undetermined function a4, and Cosh/Sinh of an
undetermined rapidity.  Rather than raise the global budget -- which would change the original's
session policy and make the whole notebook slow -- we certify an identity in three escalating
stages:

  1. exact structural equality (the entry is literally 0);
  2. Simplify under the geometric assumptions, with a 5-second budget;
  3. a high-precision numerical certificate: substitute concrete probe functions for the
     undetermined a4 and rapidity, evaluate at three rational sample points inside the assumed
     domain to 30 significant digits with up to 200 digits of extra working precision, and
     accept the result as zero only if its magnitude is below 10^-22.

Stage 3 uses probe functions ONLY as test inputs.  They are never definitions: a4 and the
rapidity remain undetermined everywhere else in this notebook, and no stated result depends on
the particular probes.

Stage 3 is reached with two opposite intentions, and this notebook counts them separately
because a single number lumping them together was actively misleading.

  $cfNumericCertificates  counts the times stage 3 returned TRUE, i.e. an identity that
                          Simplify could not close and that is therefore accepted on numerical
                          evidence alone.  This is the number that measures how much of the
                          notebook is NOT symbolic, and the smaller it is the better.

  $cfNonVanishingWitnesses  counts the assertions of the form cfNonZeroWitnessQ[...], which is
                          how this notebook states that something is NOT identically zero --
                          that the Bridge 3 torsion really is present, that the triality Dirac
                          matrices really do differ from the vector ones, that Lambda really is
                          a boost and not a rotation, that the fable-5.1 torsion is there.  A
                          witness is a probe point at which every entry is an actual NUMBER and
                          at least one is non-zero; that is a COMPLETE proof of non-vanishing,
                          the strongest form the claim can take.  A probe that does not reduce
                          to numbers is a FAILED witness, not a passed one -- an earlier version
                          of this notebook got that backwards, and it is the reason the test is
                          written as it is.

Both are printed by the final summary.  The run reports $cfNumericCertificates == 0: every
identity in this notebook is closed symbolically, and stage 3 is used only to witness the
non-vanishing claims.  The number of those witnesses is whatever the summary prints; it grows
whenever a new "this is NOT zero" assertion is added, as Part V adds several, and a larger
count means more non-vanishing facts were proved, not that more was taken on trust.

One detail about stage 3.  Evaluating an expression that is IDENTICALLY ZERO in arbitrary
precision always ends by raising N::meprec, because no amount of extra working precision can
produce the requested significant digits of zero.  That message is therefore the expected
signal of success, not a failure, and it is the only message cfZeroQ suppresses.  The decision
is made by Chop, not by the message: the numbers are computed to 30 significant digits with up
to 200 digits of extra working precision, and anything larger than 10^-22 in magnitude is
reported as non-zero.

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Input:: *)
(* --- the metric determinant, and the volume factor used in Lagrangians ------------------- *)
ClearAll[detgCanonical, sqrtDetgCanonical];
detgCanonical = cfSimp[Det[gCanonical]];
sqrtDetgCanonical = cfSimp[Sqrt[Abs[detgCanonical]]];
cfAssert["the metric is non-degenerate", cfNonZeroWitnessQ[detgCanonical]];
{detgCanonical, sqrtDetgCanonical}

(* ::Input:: *)
(* --- the frame, coframe and metric, direction by direction ------------------------------- *)
Grid[Prepend[
  Table[{Subscript["direction", ToString[\[Mu] - 1]],
         frameCanonical[[\[Mu], \[Mu]]],
         coframeCanonical[[\[Mu], \[Mu]]],
         gCanonical[[\[Mu], \[Mu]]]}, {\[Mu], 1, 8}],
  {"direction", "frame e[mu,a]", "coframe e_a^mu", "g[mu,mu]"}], Frame -> All, Alignment -> Left]

(* ::Section:: *)
16.  The generalized Christoffel symbols, and the canonical spin connection

(* ::Text:: *)
Step 2 of the standard procedure.  The spin connection is obtained from the zero-torsion
(Levi-Civita) condition in the form known as the VIELBEIN POSTULATE: the total covariant
derivative of the frame field, using the affine connection on the curved index and the spin
connection on the flat index, vanishes:

    D[e[nu,a], x[mu]] - Gamma[rho,mu,nu] e[rho,a] + omegaMixed[mu,a,b] e[nu,b]  ==  0 .

Solving it for omega, and contracting with the coframe to free the index nu,

    omegaMixed[mu,a,c]  =  Sum over nu of
        ( Sum over rho of Gamma[rho,mu,nu] e[rho,a]  -  D[e[nu,a], x[mu]] ) * coframe[[c,nu]] .

Lowering the first flat index with eta gives omega[mu,a,b], which must come out ANTISYMMETRIC
in a and b.  That antisymmetry is not imposed: it is a consequence of metric compatibility, and
we verify it explicitly for every connection computed in this notebook.

(* ::Input:: *)
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

(* ::Input:: *)
ClearAll[GammaCanonical];
GammaCanonical = cfTimed["generalized Christoffel symbols of the 4+4 metric",
  cfChristoffel[gCanonical, gInvCanonical, X]];
cfAssert["Gamma is symmetric in its two lower indices (torsion-free affine connection)",
  cfZeroArrayQ[Table[GammaCanonical[[r, m, p]] - GammaCanonical[[r, p, m]],
    {r, 8}, {m, 8}, {p, 8}]]];
{Dimensions[GammaCanonical], Count[Flatten[GammaCanonical], Except[0]], " non-zero components"}

(* ::Input:: *)
(* --- the non-zero Christoffel symbols, listed ------------------------------------------- *)
Grid[Prepend[
  Select[Flatten[Table[{Row[{"Gamma[", r - 1, ";", m - 1, ",", p - 1, "]"}],
      GammaCanonical[[r, m, p]]}, {r, 8}, {m, 8}, {p, 8}], 2], #[[2]] =!= 0 &],
  {"symbol", "value"}], Frame -> All, Alignment -> Left]

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Input:: *)
(* ======================= THE CANONICAL SPIN CONNECTION ================================== *)
ClearAll[omegaCanonicalMixed, omegaCanonical];
omegaCanonicalMixed = cfTimed["canonical spin connection omega[mu]^a_b from the vielbein postulate",
  cfSpinConnection[frameCanonical, X, \[Eta]4488, GammaCanonical]];
omegaCanonical = cfLowerFirstFlat[omegaCanonicalMixed, \[Eta]4488];
{Dimensions[omegaCanonical], Count[Flatten[omegaCanonical], Except[0]], " non-zero components"}

(* ::Text:: *)
Now the verification, and it is worth being exact about what each check does and does not
establish, because two of the three obvious ones are weaker than they look.

- "the vielbein postulate residual is zero" is an ALGEBRAIC IDENTITY of the solver, not a fact
  about this geometry.  cfSpinConnection contracts the postulate with Inverse[frame], and
  cfVielbeinResidual contracts it back with frame; the two contractions cancel for ANY affine
  connection and ANY invertible frame.  It is a useful regression test of the code, and nothing
  more.
- "the torsion vanishes" is nearly as weak.  Once the residual is zero, the torsion reduces to
  (Gamma[rho,mu,nu] - Gamma[rho,nu,mu]) e[rho,a], and the symmetry of Gamma in its lower indices
  is itself structural: swapping mu and nu in (1/2) g^{rs}(dg[m,s,p] + dg[p,s,m] - dg[s,m,p])
  reproduces the same expression whenever g is symmetric.
- "omega[mu,a,b] == -omega[mu,b,a]" DOES have content.  Nothing in the solver imposes it; it
  holds only because the affine connection fed in really is the Levi-Civita connection of the
  metric that the frame builds.  A wrong Christoffel symbol would break it.

So we run all three, labelled honestly, and then add a fourth check that is genuinely
independent: re-derive the spin connection from the FRAME ALONE, by the standard closed formula
in terms of the anholonomy of the coframe, which never mentions Gamma or the metric, and compare.
If cfChristoffel had a slot wrong, that comparison would fail.  One class of error it CANNOT
see, on this frame, is a transposition of the frame's own two slots (curved row versus flat
column): the canonical frame is diagonal, so it equals its own transpose and every such error
is invisible here.  That case is certified in Section 18, where both solvers are run on a
frame that is not symmetric.

(* ::Input:: *)
(* --- what the three obvious checks actually establish ------------------------------------ *)
cfAssert["CANONICAL [solver regression]: vielbein postulate residual is zero",
  cfZeroArrayQ[cfVielbeinResidual[frameCanonical, X, GammaCanonical, omegaCanonicalMixed]]];
cfAssert["CANONICAL [structural]: torsion vanishes",
  cfZeroArrayQ[cfTorsion[frameCanonical, X, omegaCanonicalMixed]]];
cfAssert["CANONICAL [has content]: omega[mu,a,b] == -omega[mu,b,a]  (metric compatibility)",
  cfZeroArrayQ[Table[omegaCanonical[[mu, a, b]] + omegaCanonical[[mu, b, a]],
    {mu, 8}, {a, 8}, {b, 8}]]];

(* ::Input:: *)
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

(* ::Input:: *)
(* --- the non-zero components of the canonical spin connection, listed -------------------- *)
ClearAll[cfShowConnection];
cfShowConnection[om_, name_String] := Grid[Prepend[
   Select[Flatten[Table[{Row[{name, "[", mu - 1, ";", a - 1, ",", b - 1, "]"}],
       om[[mu, a, b]]}, {mu, 8}, {a, 8}, {b, 8}], 2], #[[2]] =!= 0 &],
   {"component", "value"}], Frame -> All, Alignment -> Left];
cfShowConnection[omegaCanonical, "omega"]

(* ::Input:: *)
(* --- the curvature 2-form of the canonical connection ------------------------------------ *)
ClearAll[RiemannCanonical];
RiemannCanonical = cfTimed["curvature 2-form of the canonical spin connection",
  cfCurvature[omegaCanonicalMixed, X]];
cfAssert["CANONICAL: curvature is antisymmetric in the two spacetime indices",
  cfZeroArrayQ[Table[RiemannCanonical[[mu, nu, a, b]] + RiemannCanonical[[nu, mu, a, b]],
    {mu, 8}, {nu, 8}, {a, 8}, {b, 8}]]];
{Count[Flatten[RiemannCanonical], Except[0]], " non-zero curvature components"}

(* ::Input:: *)
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

(* ::Section:: *)
17.  The gauge-covariant derivative of the 16-component spinor

(* ::Text:: *)
Step 3 of the standard procedure.  The wave function of this model is a 16-component spinor
that is the DIRECT SUM of a split-octonion type-1 spinor field and a split-octonion type-2
spinor field:

    Psi16 = { psi1 (8 components) , psi2 (8 components) } .

Acting on it, ordinary partial derivatives are replaced by the gauge-covariant derivative

    Dcov[mu] Psi  ==  D[Psi, x[mu]]  +  (1/8) omega[mu,a,b] Commutator[gamma[a], gamma[b]] . Psi

What this section does and does not do, stated plainly.  It CONSTRUCTS the operator, verifies
its coefficient and sign, verifies its direct-sum structure on a generic spinor, and then
APPLIES it to the model's own Psi16 of Section 11.  It does NOT re-derive the field equations
of Part II from a covariant Lagrangian: those equations, and the closed-form solutions that
satisfy them, are the flat ones of Section 12, exactly as in the original notebook.  Part V
makes the relation between the two precise.

where gamma[a] = T16[a] are the 16x16 Dirac matrices of Section 5.  Since
SAB[[a+1,b+1]] = (1/4) Commutator[gamma[a], gamma[b]], the connection term is equally
(1/2) omega[mu,a,b] SAB[[a+1,b+1]], which is the form the original notebook's commented-out
Lagrangian Lg uses.

A structural fact that matters for this model: each gamma[a] is OFF-diagonal in the
type-1/type-2 block decomposition, so every PRODUCT of two gammas is BLOCK-DIAGONAL.  Section 5
proved the same thing in the language of chirality: PL and PR project exactly onto the upper
(type-1) and lower (type-2) halves, and T16[8] commutes with every SAB, so the two halves are
each Spin(4,4)-invariant.  The spin
connection matrix therefore never mixes the type-1 spinor with the type-2 spinor.  The
16-component covariant derivative really is the direct sum of a type-1 covariant derivative and
a type-2 covariant derivative, and we verify that below and extract the two 8x8 blocks.

(* ::Input:: *)
(* --- the 16x16 spin-connection matrix in each spacetime direction ------------------------ *)
ClearAll[cfSpinMatrix, GammaSpinCanonical];
cfSpinMatrix[om_, mu_Integer] :=
  (1/8) Sum[om[[mu, a, b]] (T16[a - 1] . T16[b - 1] - T16[b - 1] . T16[a - 1]), {a, 8}, {b, 8}];
GammaSpinCanonical = cfTimed["16x16 spin-connection matrices Gamma^spin[mu]",
  Table[cfSimpArray[cfSpinMatrix[omegaCanonical, mu]], {mu, 8}]];
Dimensions[GammaSpinCanonical]

(* ::Input:: *)
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

(* ::Input:: *)
(* --- the direct-sum structure: every Gamma^spin[mu] is block diagonal -------------------- *)
ClearAll[GammaSpinType1, GammaSpinType2];
cfAssert["Gamma^spin[mu] is block diagonal: it never mixes type-1 with type-2",
  cfZeroArrayQ[Table[GammaSpinCanonical[[mu]]
      - ArrayFlatten[{{GammaSpinCanonical[[mu]][[1 ;; 8, 1 ;; 8]], 0},
                      {0, GammaSpinCanonical[[mu]][[9 ;; 16, 9 ;; 16]]}}], {mu, 8}]]];
GammaSpinType1 = Table[GammaSpinCanonical[[mu]][[1 ;; 8, 1 ;; 8]],   {mu, 8}];
GammaSpinType2 = Table[GammaSpinCanonical[[mu]][[9 ;; 16, 9 ;; 16]], {mu, 8}];
{Dimensions[GammaSpinType1], Dimensions[GammaSpinType2]}

(* ::Input:: *)
(* --- the two 8x8 blocks, written directly in terms of tau and taubar --------------------- *)
cfAssert["the type-1 block is (1/8) omega (taubar^a tau^b - taubar^b tau^a)",
  cfZeroArrayQ[Table[GammaSpinType1[[mu]] - (1/8) Sum[omegaCanonical[[mu, a, b]]
      (\[Tau]bar[a - 1] . \[Tau][b - 1] - \[Tau]bar[b - 1] . \[Tau][a - 1]), {a, 8}, {b, 8}],
      {mu, 8}]]];
cfAssert["the type-2 block is (1/8) omega (tau^a taubar^b - tau^b taubar^a)",
  cfZeroArrayQ[Table[GammaSpinType2[[mu]] - (1/8) Sum[omegaCanonical[[mu, a, b]]
      (\[Tau][a - 1] . \[Tau]bar[b - 1] - \[Tau][b - 1] . \[Tau]bar[a - 1]), {a, 8}, {b, 8}],
      {mu, 8}]]];

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Title:: *)
PART IV  --  Three bridges between curved and flat indices: two gauge transformations, and one new connection

(* ::Text:: *)
The canonical frame field of Part III is one choice among infinitely many.  Part IV builds three
further bridges between curved spacetime indices and flat tangent-space indices, derives the
spin connection of each with the SAME solver cfSpinConnection, and compares each, component by
component, with the canonical spin connection.  Part V then adds a fourth, the fable-5.1 bridge.

A word of honesty about what counts as NEW, because the first version of this notebook was not
careful enough about it.  Any frame of the form frameNew = frameCanonical . L, with L(x) a
matrix that preserves the flat metric, describes the same geometry through a rotated local
Minkowski system.  Its Levi-Civita spin connection is the canonical one transformed by the gauge
law below.  Comparing it with the canonical connection therefore re-derives that law and nothing
more: it is the SAME connection in a different gauge, not a new connection.  Two of the three
bridges here are of that kind.  They are kept because they are correct, because each teaches
something real about the gauge structure of the frame bundle, and because Part V uses Bridge 1
to show what its "inhomogeneous term" actually is.  But they are labelled for what they are.

  BRIDGE 1  a locally boosted orthonormal frame, frameCanonical . Lambda(x) with Lambda in
            O(4,4).  SAME CONNECTION, LOCAL GAUGE.  The flat metric is still eta4488.  The
            connection differs from the canonical one by the inhomogeneous gauge term, which
            exhibits the spin connection as the gauge field of local Lorentz transformations --
            and which Part V identifies as the fable-5.1 connection of the boosted frame.

  BRIDGE 2  a null (light-cone) frame, frameCanonical . U with U constant.  SAME CONNECTION,
            CONSTANT GAUGE.  The flat tangent metric changes from eta4488 to the split form in
            which the four pairs (x0,x4), (x1,x5), (x2,x6), (x3,x7) are null, and that split
            form is exactly the split-octonion spinor metric sigma of Section 4.  The
            connection is the canonical one conjugated by U, with no inhomogeneous term.  The
            content here is the identity etaNull == sigma, not the connection.

  BRIDGE 3  a triality (split-octonion spinor) frame carrying TOTALLY ANTISYMMETRIC TORSION
            built from the split-octonion structure constants.  A DIFFERENT CONNECTION.  The
            flat index is a type-1 spinor index and the connection is not the Levi-Civita one:
            it differs from it by a contortion tensor, so its torsion is non-zero.

  FABLE-5.1 (Part V) the Weitzenboeck connection, in which the canonical frame itself is
            parallel.  A DIFFERENT CONNECTION, with zero spin connection and zero curvature in
            the canonical frame, whose torsion carries the whole geometry; the canonical
            spin connection is exactly minus its contortion.

A general fact we will use three times.  If a new frame is built from the old one by
frameNew = frameOld . L with L an invertible matrix of flat indices, then substituting into the
vielbein postulate and setting M = Transpose[L] gives

    omegaNew[mu] == M . omegaOld[mu] . Inverse[M]  -  D[M, x_mu] . Inverse[M] .

The second term is the inhomogeneous gauge term; it vanishes exactly when L is constant.  We do
NOT assume this formula anywhere: each new connection is derived independently from the vielbein
postulate, and the formula is then verified against the derived result.

(* ::Section:: *)
18.  Bridge 1 -- a locally boosted frame: the same connection in a local gauge

(* ::Text:: *)
WHAT THIS BRIDGE IS, AND IS NOT.  It is a change of gauge.  The frame is rotated pointwise by
an element of O(4,4), the Levi-Civita connection is re-expressed in the rotated frame, and the
comparison with the canonical connection recovers the gauge transformation law -- which is a
real and useful thing to see written out for this geometry, but is not a new connection.  The
one genuinely new object it exhibits is the inhomogeneous term -D[theta,x_mu] K, and Part V
shows that this term is itself a connection: the fable-5.1 (Weitzenboeck) connection of the
boosted frame.  Read this section for the gauge structure; read Part V for what the extra term
means.

Introduce a NEW object, not present in the original notebook: a rapidity field
cfBoostRapidity[x0,x4], an arbitrary differentiable scalar function of the hidden-space
coordinate x0 and the time coordinate x4.  It generates a boost in the flat (0,4) plane, i.e.
between the first (spacelike, eta = +1) and the fifth (timelike, eta = -1) tangent directions:

    Lambda[theta] = ID8 + (Cosh[theta]-1)(E00 + E44) + Sinh[theta](E04 + E40)
                  = MatrixExp[theta K],     K the boost generator on flat indices 0 and 4.

Lambda is an element of O(4,4): Lambda . eta4488 . Transpose[Lambda] == eta4488.  The new frame
field is frameBoost = frameCanonical . Lambda.  Because Lambda preserves eta4488, THE CURVED
METRIC IS UNCHANGED: the two frames describe the same geometry through two different local
Minkowski coordinate systems, related by a different boost at every point.

(* ::Input:: *)
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

(* ::Input:: *)
frameBoost = cfSimpArray[frameCanonical . cfLambda];
cfAssert["BRIDGE 1 reproduces the SAME curved metric g",
  cfZeroArrayQ[frameBoost . \[Eta]4488 . Transpose[frameBoost] - gCanonical]];
cfAssert["BRIDGE 1 frame really is different from the canonical frame",
  frameBoost =!= frameCanonical];
MatrixForm[frameBoost]

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Text:: *)
Step 3 for Bridge 1: the spinor level.  A local Lorentz transformation Lambda(x) of the frame
acts on a 16-component spinor through its SPIN LIFT S(x), the 16x16 matrix that obeys

    Inverse[S] . gamma^a . S  ==  Lambda^a_b gamma^b .

For a boost of rapidity theta in the (0,4) plane the lift is the exponential of the SAME
rapidity times the so(4,4) generator SAB[[1,5]] == (1/4)[gamma^0, gamma^4] -- with no extra
factor 1/2, because SAB already carries the 1/4.  (Lambda is symmetric, so Lambda^a_b and
Lambda^b_a coincide and there is no index-placement question to settle here.)  With S in hand
the comparison of Section 17's spinor connection between the two frames is a law, not a table:

    Gamma'_mu  ==  S Gamma_mu Inverse[S]  -  D[S, x_mu] Inverse[S] ,

and its inhomogeneous term is -D[theta,x_mu] SAB[[1,5]], the spin image of the vector term
-D[theta,x_mu] K found above.  What the law is FOR is the last two assertions: with psi -> S psi
the covariant derivative and the Dirac operator of the boosted frame are the canonical ones
conjugated, so a solution of the Dirac equation in one frame is a solution in the other.

(* ::Input:: *)
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

(* ::Section:: *)
19.  Bridge 2 -- the null (light-cone) frame: the same connection in a constant gauge, and the spinor metric sigma

(* ::Text:: *)
WHAT THIS BRIDGE IS, AND IS NOT.  It is a constant change of basis on the flat index.  The
connection that results is the canonical one conjugated by a fixed matrix, with no inhomogeneous
term at all, so as a "new spin connection" it is the weakest of the four: the same connection,
written in a constant gauge.  What is worth keeping is the fact it turns up -- that the null
form of the 4+4 flat metric is exactly the split-octonion spinor metric sigma -- and that fact
is about the flat metric, not about the connection.

The second bridge changes the FLAT TANGENT METRIC rather than the frame's orientation.  Pair the
eight flat directions as (0,4), (1,5), (2,6), (3,7) -- one spacelike with one timelike in each
pair -- and replace each pair by its two null combinations.  The constant matrix that does this
is

    U = (1/Sqrt[2]) ArrayFlatten[ { {ID4, ID4}, {ID4, -ID4} } ] ,      U == Transpose[U],
                                                                       U . U == ID8 .

Under U the flat metric becomes  etaNull = Transpose[U] . eta4488 . U, and the remarkable fact,
verified below, is that etaNull IS EXACTLY THE SPLIT-OCTONION SPINOR METRIC sigma of Section 4.
The null frame of this 4+4 geometry and the spinor pairing of the split octonions are the same
structure.  Note also that etaNull has a zero diagonal, which is precisely the statement that
all eight frame directions are null.

This is the frame adapted to Einstein and Rosen's picture: each pair of coordinates is split
into an advanced and a retarded null direction, which is exactly the (ztadv, ztret) and
(xiadv, xiret) splitting the original notebook performs by hand in its "retarded, advanced"
sections.

The new frame is frameNull = frameCanonical . U, and it reproduces the same curved metric g
because U . etaNull . Transpose[U] == eta4488.

(* ::Input:: *)
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

(* ::Input:: *)
frameNull = cfSimpArray[frameCanonical . cfU];
cfAssert["BRIDGE 2 reproduces the SAME curved metric g",
  cfZeroArrayQ[frameNull . \[Eta]Null . Transpose[frameNull] - gCanonical]];
MatrixForm[frameNull]

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Section:: *)
20.  Bridge 3 -- the triality frame with totally antisymmetric split-octonion torsion

(* ::Text:: *)
The third bridge is of a different kind.  Its flat index is not a vector index at all: it is a
TYPE-1 SPLIT-OCTONION SPINOR INDEX, reached through the constant triality bridge triVecToSpin of
Section 9.  Section 9 proved that this bridge carries eta4488 exactly onto sigma, so the frame

    frameTri = frameCanonical . triVecToSpin

again reproduces the same curved metric, now with flat tangent metric sigma.  We also record
here a fact that is used below: triVecToSpin satisfies Transpose[P] == Inverse[P], Euclidean
orthogonality, which is a computational convenience.  It is NOT an element of O(4,4) -- it
carries eta4488 to sigma, which is the whole point of it -- so as a bridge it is a constant
change of basis of the flat tangent space, and nothing more is claimed for it.

That alone would give nothing new beyond Bridge 2, because triVecToSpin is constant.  So we go
further and change the CONNECTION as well.  The split-octonion structure constants m, restricted
to the seven imaginary directions and with all indices lowered, are TOTALLY ANTISYMMETRIC (this
was verified in Section 9).  A totally antisymmetric 3-tensor on the tangent space is exactly
what is needed to add TOTALLY ANTISYMMETRIC TORSION to a metric connection without spoiling
metric compatibility.  Define, for a real parameter lambda,

    omegaOct[mu,a,b]  =  omegaTriLC[mu,a,b]  +  lambda * mSkew[a,b,c] * frameTri[[mu,c]] .

The added term is antisymmetric in (a,b), so omegaOct is still an so(4,4)-valued connection and
is still metric compatible; but it is no longer torsion-free.  Its torsion is totally
antisymmetric and proportional to the octonion structure constants.  It is a Riemann-Cartan
connection with constant totally antisymmetric contortion.  It resembles the Cartan-Schouten
connections on a Lie group, whose torsion is likewise the structure-constant tensor of a
frame, but two things that hold there fail here and should not be assumed: those connections
are FLAT, and this one is not (its curvature is computed below and depends on lambda); and
their torsion is the anholonomy of a genuine frame, whereas the octonion structure constants
violate the Jacobi identity and so cannot be the anholonomy of any frame at all.  A totally
antisymmetric torsion is precisely the kind that sources the Einstein-Cartan AXIAL torsion
coupling of a spinor.  What Section 20 computes is the torsion itself and its effect on the connection; the
cubic gamma^a gamma^b gamma^c axial term is a further contraction that this notebook does not
carry out, and the cell that builds the spinor coupling says so.  At lambda = 0 the connection
reduces to the Levi-Civita connection in the triality frame.

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Text:: *)
The curvature of Bridge 3.  The first version of this notebook wrote in its summary that
"bridge 3 adds a torsion-dependent piece" to the curvature, and never computed it.  Here it is,
and it has a clean structure.  Because omegaOct == omegaTriLC + lambda K with K the contortion,
and the curvature is quadratic in the connection, R(omegaOct) is a polynomial of degree exactly
two in lambda:

    lambda^0 :  the canonical curvature, carried over by the triality bridge;
    lambda^1 :  the Levi-Civita covariant exterior derivative of the contortion, dK + [omegaTriLC, K];
    lambda^2 :  the commutator [K_mu, K_nu] of the contortion with itself.

Its Ricci scalar differs from the canonical one by a CONSTANT, -(1/4) T_{abc} T^{abc}, the
standard result for a totally antisymmetric torsion; with T = -2 lambda mSkew that is
-lambda^2 (mSkew . mSkew) = -42 lambda^2.  The octonionic torsion shifts the scalar curvature of
the pre-universe by a fixed amount, everywhere, and the amount is set by the square of the
split-octonion structure constants.  That is the torsion-dependent piece.

(* ::Input:: *)
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

(* ::Text:: *)
The effect on the spinor covariant derivative.  One thing must be got right here, and it is easy
to get wrong.  cfSpinMatrix of Section 17 contracts the flat indices of a connection against the
Dirac matrices T16, and that is correct only when those flat indices are the eta4488 VECTOR
indices, because T16 obeys Anticommutator[T16[A], T16[B]] == 2 eta4488[[A+1,B+1]] ID16.  Bridge
3's flat index is not a vector index: it is a triality-spinor index whose tangent metric is
sigma.  Feeding omegaOct into cfSpinMatrix would therefore build the spin representative of a
different object.

The Dirac matrices that match this frame are the triality transports

    T16Tri[a]  =  Sum over A of  triSpinToVec[[a,A]] T16[A-1]

and they obey Anticommutator[T16Tri[a], T16Tri[b]] == 2 sigma[[a,b]] ID16, which is exactly the
statement that the triality bridge carries eta4488 onto sigma.  We verify that, and then build
Bridge 3's spinor connection with them.

(* ::Input:: *)
ClearAll[T16Tri, cfSpinMatrixTri];
T16Tri[a_Integer] := T16Tri[a] = Sum[triSpinToVec[[a, A1]] T16[A1 - 1], {A1, 8}];
cfAssert["THE TRIALITY DIRAC MATRICES OBEY THE sigma CLIFFORD RELATION: {T16Tri[a],T16Tri[b]} == 2 sigma[[a,b]] ID16",
  cfZeroArrayQ[Table[T16Tri[a] . T16Tri[b] + T16Tri[b] . T16Tri[a]
     - 2 \[Eta]TriFlat[[a, b]] ID16, {a, 8}, {b, 8}]]];
cfAssert["they are NOT the vector-frame Dirac matrices, so the distinction is real",
  cfNonZeroWitnessQ[Table[T16Tri[a] - T16[a - 1], {a, 8}]]];
cfSpinMatrixTri[om_, mu_Integer] :=
  (1/8) Sum[om[[mu, a, b]] (T16Tri[a] . T16Tri[b] - T16Tri[b] . T16Tri[a]), {a, 8}, {b, 8}];

(* ::Input:: *)
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
