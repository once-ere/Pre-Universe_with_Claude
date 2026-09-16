(* ::CELLMANIFEST-PART:: 5 *)

(* ::Title:: *)
PART V  --  The fable-5.1 bridge: the connection in which the frame itself is parallel

(* ::Section:: *)
21.  The fable-5.1 bridge -- the Weitzenboeck (teleparallel) connection of the canonical frame

(* ::Text:: *)
WHAT THIS SECTION IS FOR, IN ONE PARAGRAPH.  Bridges 1 and 2 of Part IV keep the Levi-Civita
connection and only rotate the frame; Bridge 3 keeps the frame and adds a torsion term by hand.
The fable-5.1 bridge keeps the frame AND the metric AND the flat metric eta4488 -- the bridge [d]
of Section 15 is untouched -- and changes the one thing the other bridges did not question: the
RULE FOR PARALLEL TRANSPORT.  It declares the canonical frame itself to be parallel.  The
consequences are exact and, for this geometry, all in closed form: the spin connection in that
frame is ZERO, the curvature is ZERO, the whole of the geometry moves into the TORSION, and the
canonical Levi-Civita spin connection of Section 16 turns out to be, component for component,
the CONTORTION of that torsion.  The comparison with the canonical connection is therefore not a
gauge transformation law but a tensor identity with content.  This is the teleparallel
equivalent of general relativity, written for the 4+4 pre-universe.

FOR THE READER WHO HAS NEVER MET THIS.  A connection is a rule that says which vectors at
neighbouring points count as "the same".  The Levi-Civita rule says: no torsion, and let the
curvature be whatever the metric forces it to be.  The Weitzenboeck rule says instead: the eight
frame vectors e[mu,a] are the same at every point, full stop.  Because the frame field is not
constant in the coordinates, this rule has torsion; because every vector is a fixed combination
of the frame vectors, transporting a vector around a closed loop brings it back unchanged, so the
rule has no curvature.  Both rules are metric compatible -- lengths are preserved by both -- and
both live on the same manifold with the same metric g.  They differ by a tensor, the contortion,
and that tensor is what this section computes and compares.

(* ::Input:: *)
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

(* ::Text:: *)
Step 2 of the user's standard procedure, run for this bridge.  The vielbein postulate of
Section 16 is

    D[e[nu,a], x[mu]] - Gamma[rho,mu,nu] e[rho,a] + omegaMixed[mu,a,b] e[nu,b]  ==  0 .

With Gamma the Weitzenboeck connection the first two terms cancel by construction, so the
postulate is solved by omega == 0.  That is the whole point: in the frame that defines the
bridge, THE FABLE-5.1 SPIN CONNECTION IS IDENTICALLY ZERO.  We do not assume this; we feed
Gamma^W to the same solver that produced every other connection in this notebook and read off
what comes out.

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Text:: *)
THE COMPARISON WITH THE CANONICAL SPIN CONNECTION.  Two connections on the same manifold differ
by a tensor.  Here that tensor is the CONTORTION, K = Gamma^W - Gamma^LC, and the standard
formula expresses it through the torsion alone:

    K[rho,mu,nu]  =  (1/2) ( T[rho,mu,nu] + T[mu,rho,nu] + T[nu,rho,mu] ),    all indices down.

Now substitute Gamma^LC = Gamma^W - K into the vielbein postulate.  The Gamma^W part cancels
the derivative of the frame exactly, because that is what Gamma^W was built to do, and what is
left is

    omegaCanonical[mu,a,b]  ==  - K[rho,mu,nu] e[rho,a] coframe[[b,nu]] .

In words: THE ENTIRE CANONICAL LEVI-CIVITA SPIN CONNECTION OF SECTION 16 IS MINUS THE CONTORTION
OF THE FABLE-5.1 TORSION, pulled back to flat indices.  It is not "the same connection in a
different gauge"; it is a different connection, and the difference is a tensor built from the
torsion that the fable-5.1 bridge exposes.  Every one of the 24 non-zero components of
omegaCanonical is accounted for this way, and both sides are verified below with no assumption
beyond those of Section 15.

(* ::Input:: *)
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

(* ::Text:: *)
WHAT KIND OF TORSION IS IT?  A torsion tensor in n dimensions splits into three irreducible
pieces: a VECTOR part (its trace), a totally antisymmetric AXIAL part, and a traceless
TENSOR part.  For the fable-5.1 bridge of this geometry the answer is clean:

  - the vector part is T[mu] = T[nu,nu,mu], and it is a GRADIENT:  T[mu] = D[phi, x[mu]]  with
    phi = Log[Sin[6 H x0]].  Only its x0 component is non-zero, 6 H Cot[6 H x0].
  - the axial part vanishes identically, because the canonical frame is diagonal.  This is the
    exact complement of Bridge 3, whose torsion was purely axial and put in by hand: the
    fable-5.1 torsion is purely NON-axial and comes from the geometry itself.
  - the tensor part carries the rest, including everything that depends on a4.

The vector part is the one that matters for the spinor below, and that it is a gradient is what
makes the spinor result exact.

(* ::Input:: *)
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

(* ::Text:: *)
THE SCALAR IDENTITY: R == -T + B.  The Levi-Civita scalar curvature R of Section 16 and the
fable-5.1 torsion scalar

    T  =  (1/4) T^{rmn} T_{rmn}  +  (1/2) T^{rmn} T_{nmr}  -  T^m T_m

differ by a pure divergence,  B = (2/Sqrt[det g]) D[ Sqrt[det g] T^mu, x[mu] ].  This is the
statement that the Einstein-Hilbert action and the teleparallel action are the same action up
to a boundary term -- the teleparallel equivalent of general relativity -- and here it holds in
closed form.  Two remarks a student should not skip.  First, det g == Sec[6 H x0]^2 is positive:
signature 4+4 has an even number of minus signs.  Second, the square root is Sec[6 H x0] and
not Abs[Sec[6 H x0]], because Section 15 assumed 0 < 6 H x0 < Pi/2; writing the Abs would be
correct but would make Mathematica differentiate Abs, and the identity would then look false
for a purely notational reason.  We state the assumption and use Sec.

(* ::Input:: *)
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

(* ::Text:: *)
THE 16-COMPONENT SPINOR.  Step 3 of the user's procedure, for this bridge.  In the fable-5.1
gauge the spin connection is zero, so the covariant derivative of the 16-component spinor is the
plain partial derivative and the Dirac operator is gamma^mu D[Psi, x_mu] with the curved
gamma^mu = coframe[[a,mu]] T16[a] of Section 17.  The canonical Dirac operator of Section 17
carries in addition the connection term gamma^mu Gamma^spin[mu].  The comparison is exact and
short: because the torsion vector is a gradient, that entire connection term is ONE VECTOR
TERM,

    gamma^mu Gamma^spin[mu]  ==  -(1/2) T[mu] gamma^mu  ==  -(1/2) D[phi, x_mu] gamma^mu ,

and a vector term of that form is removed by a rescaling of the spinor.  Precisely:

    DiracCanonical[ Sqrt[Sin[6 H x0]] Psi' ]  ==  Sqrt[Sin[6 H x0]] * gamma^mu D[Psi', x_mu] .

So the Levi-Civita Dirac equation for Psi and the fable-5.1 (connection-free) Dirac equation for
Psi' = Psi / Sqrt[Sin[6 H x0]] are the SAME equation.  Nothing about this is approximate.  A
student who wants to solve the curved Dirac equation of this model may solve the connection-free
one and multiply by Sqrt[Sin[6 H x0]].

(* ::Input:: *)
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

(* ::Text:: *)
THE LAGRANGIAN, AND A FACT ABOUT THIS MODEL'S SPINOR THAT THE FABLE-5.1 BRIDGE MAKES VISIBLE.
Section 11 proved that sigma16 . T16[a] is ANTISYMMETRIC, so the bilinear
Transpose[Psi] . sigma16 . T16[a] . Psi vanishes identically for any real 16-component Psi.
Combine that with the result just proved, that the connection term of the Dirac operator is a
multiple of gamma^mu, and the conclusion is immediate:

    Transpose[Psi] . sigma16 . gamma^mu Gamma^spin[mu] . Psi  ==  0     for EVERY Psi.

The spin connection contributes NOTHING to the Dirac Lagrangian of this real spinor, whichever
frame it is written in.  The curved Dirac Lagrangian is therefore, exactly,

    L  =  Sqrt[det g] * ( Transpose[Psi] . sigma16 . gamma^mu . D[Psi, x_mu] )  +  mass term,

with the coframe inside gamma^mu and no connection at all: it is MANIFESTLY the fable-5.1
(teleparallel) Lagrangian.  This also says precisely what the original notebook's flat
Lagrangian La of Section 11 leaves out.  Not the spin connection, which was never there to be
left out: it leaves out the volume factor Sqrt[det g] == Sec[6 H x0] and the coframe factors
Cot[6 H x0], Sin[6 H x0]^(1/6) Exp[-+a4[H x4]] inside gamma^mu.  Those, and only those, are the
difference between the author's La and the covariant Dirac Lagrangian of this geometry.

(* ::Input:: *)
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

(* ::Text:: *)
THE BRIDGE IS FRAME-COVARIANT, AND IT EXPLAINS BRIDGE 1.  The fable-5.1 connection is a
property of the frame bundle, not of one frame: rotate the canonical frame by Bridge 1's local
boost Lambda(x) and the same affine connection Gamma^W, fed to the same solver, gives the
fable-5.1 spin connection in the boosted frame.  It is no longer zero -- it is the pure-gauge
term  -D[M, x_mu] . Inverse[M]  with M = Transpose[Lambda], and NOTHING ELSE -- and its curvature
is still identically zero.  Compare Section 18: Bridge 1's "inhomogeneous gauge term" is exactly
this object.  So Part IV's first bridge was not a new connection but the fable-5.1 connection of
the boosted frame added to the Levi-Civita one; everything in Part IV is now in one picture.

(* ::Input:: *)
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

(* ::Section:: *)
22.  Master comparison of the five spin connections

(* ::Text:: *)
Everything computed in Parts III, IV and V, collected in one place.  For each connection we
record the frame field it comes from, the flat tangent metric it uses, whether the curved metric
g is unchanged (it is, for all five), whether the connection is metric compatible, whether its
torsion and its curvature vanish, and how it differs from the canonical one.  The last column is
the honest classification: a bridge that differs from the canonical connection by a gauge
transformation is the SAME connection in a different gauge; only a bridge that differs by a
tensor is a different connection.

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Input:: *)
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
