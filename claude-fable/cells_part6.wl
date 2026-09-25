(* ::CELLMANIFEST-PART:: 6 *)

(* ::Title:: *)
PART VI  --  fableScalar and fable: two fields on the pre-universe, and the equation of state of dark energy

(* ::Text:: *)
WHAT THIS PART IS FOR, IN ONE PARAGRAPH.  Parts III-V built the geometry of the 4+4
pre-universe and settled how a 16-component spinor is differentiated on it.  Part VI puts two
matter fields on that geometry and asks the cosmologist's question of each: what is its energy
density rho, what is its pressure P, and what is the ratio w = P/rho that decides whether the
field behaves as dust (w = 0), as radiation (w = 1/3), as a cosmological constant (w = -1) or as
something in between or beyond.  The first field, fableScalar, is a real scalar with a
self-interaction potential V(phi), the pre-universe cousin of quintessence.  The second, fable, is
a real 16-component spinor of exactly the kind this notebook has studied since Section 11, with a
self-interaction potential V(s) of its scalar bilinear s = Psi^T sigma16 Psi; the author's
Lagrangian La of Section 11 is the special case V = -(2M/H) s.  For each field this Part defines
the Lagrangian and the energy-momentum tensor, PROVES the conservation law and the decomposition
into kinetic, potential and gradient energies, derives w in closed form where it has one, and
closes with the 4-dimensional Friedmann reference models that the numerical solver
fable-cosmology integrates, solved here independently with NDSolve.

CONVENTIONS, RESTATED SO THAT NOTHING BELOW HAS TO BE GUESSED.  The spinor metric is the symbol
sigma16 (symmetric; sigma16 . T16[a] antisymmetric, Section 5).  The flat Dirac matrices T16[a]
are 0-based, a = 0..7.  The coordinate list X = {x0, ..., x7} is 1-based, so the time coordinate
x4 is ENTRY 5 of X, of gCanonical and of gammaCurvedCanonical, and the observed 3-space x1, x2,
x3 is entries 2, 3, 4.  The constants H, K, M are Protected since Section 1, so the energies
defined here are called cfKE, cfPE, cfG0, cfG5 (scalar) and cfKPsi, cfKh (spinor).  The volume
factor is sqrtDetgTele = Sec[6 H x0] of Section 21, for which Sqrt[det g]^2 == det g was proved
there.  And the one rule that governs the whole Part: THE FUNCTION a4 IS NEVER GIVEN A VALUE.
Every statement is proved for an arbitrary a4; the 4-dimensional reference models of Sections 23
and 24 live on a SEPARATE frame with their own scale factor aF[x4], and the last assertion of the
Part checks that a4 is still undefined.

(* ::Section:: *)
23.  fableScalar -- a scalar field on the pre-universe, its energy-momentum tensor, and wScalar

(* ::Text:: *)
THE FIELD.  fableScalar is a real scalar phi(x0, ..., x7) on the 8-manifold, minimally coupled to
the canonical metric, with a self-interaction potential V(phi) that is left completely general:

    L_phi  =  Sqrt[det g] * Lhat_phi,        Lhat_phi  =  -(1/2) g^{mu nu} d_mu phi d_nu phi  -  V(phi) .

The sign in front of the kinetic term is chosen so that the kinetic energy along the observer's
time x4 comes out POSITIVE: g^{44} = -1, so -(1/2) g^{44} phidot^2 = +(1/2) phidot^2.  The
energy-momentum tensor is the Hilbert one, obtained by varying the action with respect to the
inverse metric,

    T_{mu nu}  =  -(2/Sqrt[det g]) dS/dg^{mu nu}  =  d_mu phi d_nu phi  +  g_{mu nu} Lhat_phi ,

and the field equation is  box phi == V'(phi)  with  box = (1/Sqrt[g]) d_mu ( Sqrt[g] g^{mu nu} d_nu ).

Two general helpers are defined first, because both fields need them.  cfEulerLagrange forms the
Euler-Lagrange expression of a first-order Lagrangian for a list of fields, each of which may
depend on any subset of the coordinates; it is the general form of Section 12's eL.
cfCovariantDivergence forms the vector nabla^mu T_{mu nu} with the Levi-Civita Christoffel
symbols of Section 16.  Each is tested on a case whose answer is known before it is trusted.

(* ::Input:: *)
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

(* ::Input:: *)
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

(* ::Text:: *)
CONSERVATION, PROVED OFF SHELL.  The strongest form of the conservation law is an identity that
holds for EVERY field configuration, whether or not it solves the field equation:

    nabla^mu T_{mu nu}  ==  ( box phi - V'(phi) ) d_nu phi      for a generic phi of all eight coordinates.

The right-hand side is the field equation times the gradient of the field, so on shell the
divergence vanishes exactly, in all eight components, with no assumption about the form of phi
or of V.  Both statements are asserted below: the off-shell identity for the fully generic
phi(x0, ..., x7), and then its on-shell corollary by explicit substitution of the field
equation (solved for the second x4-derivative of phi).  The control shows that the divergence
does not vanish for a configuration that is NOT a solution.  The trace of the tensor is also
recorded: T^mu_mu = -3 (d phi)^2 - 8 V, the eight-dimensional form of the familiar
-(d-2)/2 (d phi)^2 - d V.

(* ::Input:: *)
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

(* ::Text:: *)
ENERGY DENSITY, PRESSURE AND wScalar.  The observer of this model is the geodesic observer
u = d/dx4 (g_{44} = -1, and x0 is constant along the worldline).  For that observer

    rho  =  T_{44}  =  T[[5,5]],        P_i  =  T^i_i  =  gInv[[i,i]] T[[i,i]]   (no sum, i = 1,2,3),     w = P/rho .

To see the structure, take a field of the hidden coordinate x0, the time x4 and ONE coordinate
of the second sheet, x5 (the field is homogeneous on the observed 3-space, so P_1 = P_2 = P_3;
x6 and x7 would enter exactly as x5 does).  Four non-negative energies appear:

    cfKE  =  (1/2) phidot^2                        kinetic energy along x4
    cfPE  =  V(phi)                                potential energy
    cfG0  =  (1/2) Cot[6 H x0]^2 (d_0 phi)^2       gradient energy along the hidden coordinate x0
    cfG5  =  (1/2) (1/p^2) (d_5 phi)^2             gradient energy along the second, TIMELIKE sheet

and the theorem is

    rho  =  KE + PE + G0 - G5,        P_1  =  KE - PE - G0 + G5,        P_0  =  KE - PE + G0 + G5 .

Three things follow at once, and each is asserted.  (i) Adding the first two lines,
rho + P_1 == 2 KE >= 0: the NULL ENERGY CONDITION holds identically, so w + 1 = 2 KE/rho and
w >= -1 wherever rho > 0.  fableScalar can approach the phantom divide but can never cross it
with positive energy density.  (ii) rho > 0 is a HYPOTHESIS, not a theorem: for a field
independent of x5, x6, x7 and V >= 0 it is a sum of squares plus V, but a gradient along the
timelike second sheet enters rho with a MINUS sign, and that sector -- which can have rho < 0 --
is excluded from every statement about w in this Part.  (iii) With G0 = G5 = 0 the formulas are
the textbook quintessence ones, rho = KE + V, P = KE - V.

(* ::Input:: *)
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

(* ::Text:: *)
NO HUBBLE FRICTION.  In a Friedmann universe a homogeneous scalar obeys phi'' + 3 H_obs phi' + V' = 0:
the expansion drains the field's kinetic energy.  On the pre-universe the analogous statement is
false, and the reason is geometric.  For phi = phi(x4) the field equation is exactly

    phi''(x4)  ==  -V'(phi) ,

with NO friction term, because the combination Sqrt[g] g^{44} = -Sec[6 H x0] that multiplies
phidot inside box phi does not depend on x4 (the 8-volume element is x4-independent, Section 15).
So rho = KE + V is conserved along x4, the field oscillates undamped in its potential, and w(x4)
oscillates with it.  For the quadratic potential V = m^2 phi^2/2 the solution phi = A Cos[m x4] is
exact, and on it w = -Cos[2 m x4] exactly: it swings between -1 and +1 and averages to ZERO over a
period.  That is the virial theorem <w> = (n - 1)/(n + 1) at n = 1, and it is the statement that
coherent oscillations of fableScalar in a quadratic potential are DUST -- the classic scalar
dark-matter mechanism, here with no damping at all.  A control adds a friction term by hand and
shows what it would do.

(* ::Input:: *)
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

(* ::Text:: *)
A STATIC PROFILE ALONG THE HIDDEN COORDINATE IS A COSMOLOGICAL CONSTANT ON THE OBSERVED SHEET.
Take V = 0 and a field phi(x0) of the hidden coordinate only.  The field equation reduces to
Cos[6 H x0] d_0( Sec[6 H x0] Cot[6 H x0]^2 phi'(x0) ) == 0, whose general solution is
phi'(x0) = C Sin[6 H x0]^2 / Cos[6 H x0].  On it the only energy is the gradient energy
G0 = C^2 Sin[6 H x0]^2 / 2: it depends on x0, but not on x4 and not on x1, x2, x3, so for the
observer at fixed x0 it is a CONSTANT, and rho = G0, P_1 = -G0 give w = -1 EXACTLY.  A gradient
frozen along the hidden direction looks to the observer exactly like a cosmological constant.
The honest qualification is the hidden-direction pressure: P_0 = +G0 = +rho.  In eight dimensions
this is an anisotropic stress, not a Lambda term; the Lambda-like behaviour is a statement about
the observed sheet, and it is stated as such.

(* ::Input:: *)
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

(* ::Text:: *)
THE VOLUME FACTORISATION, FOR THE 4-DIMENSIONAL REDUCTION.  The 8-volume element factorises as

    Sqrt[det g_8]  ==  q^3 * ( Tan[6 H x0] p^3 ) ,

the observed 3-volume density q^3 times the hidden 4-volume density Vhid = Tan[6 H x0] p^3.
Because p and q are reciprocal up to the common Sin factor, q^3 p^3 = 1/Sqrt[Sin[6 H x0]] does not
depend on x4 at all: the observed sheet grows exactly as fast as the second sheet shrinks.  With
the kinematic identification ln a = -a4 of Section 25 this says Vhid scales as Exp[3 a4] = a^-3.
Integrating the 8-dimensional action over the hidden coordinates therefore produces a
4-dimensional action with the weight a^3 Vhid Lhat, and a reduced density rho_4 = Vhid rho_8
that falls as a^-3 EVEN WHEN rho_8 is constant.  Section 25 draws the conclusion; here the three
identities are proved.

(* ::Input:: *)
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

(* ::Text:: *)
THE 4-DIMENSIONAL REFERENCE MODEL (MODEL A), SOLVED INDEPENDENTLY.  The standard quintessence
model -- phi'' + 3 H_obs phi' + V' = 0 with the Friedmann equation -- is what one obtains when the
hidden volume is held fixed and the field sources the expansion.  It does NOT live on the
pre-universe (it has the Hubble friction the pre-universe lacks) and it never substitutes for a4;
it is the reference model of the observational literature, and it is what the Rust solver
fable-cosmology integrates as Model A.  This cell integrates the same equations with NDSolve, as
the third, independent integrator of the verification plan.  Units: 8 pi G = 1, H0 = 1,
rho_crit = 3; independent variable N = ln a; state (phi, phidot, t):

    dphi/dN = phidot/H,     dphidot/dN = -3 phidot - V'(phi)/H,     dt/dN = 1/H,
    H^2 = Om Exp[-3 N] + Or Exp[-4 N] + (phidot^2/2 + V)/3,     Om = 3/10,  Or = 84/10^6,

from N0 = -7 at rest (phi = 0, phidot = 0, the frozen start) to N1 = 0, 701 output points; the
age at N0 is added analytically as 1/(2 H(N0)).  The case is exp: V = V0 Exp[-phi] with V0 the
value the solver's shooting found, 2.6871520526047146, entered as the EXACT rational the double
represents, so that every input to NDSolve is exact and WorkingPrecision -> 24 raises no message.
If the solver's reference file fable-cosmology/reference/mathematica_scalar_exp.csv is present,
w is compared with it at every one of the 701 rows to 1e-9; if it is absent, the comparison is
reported as skipped, not as a failure.  What the run shows: w rises from -1 at the frozen start
to -0.8434 today -- a THAWING field -- and never dips below -1, exactly as the null energy
condition above demands.

(* ::Input:: *)
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

(* ::Section:: *)
24.  fable -- the 16-component spinor field, its energy-momentum tensor, and w

(* ::Text:: *)
THE FIELD.  fable is a real 16-component spinor Psi(x) on the 8-manifold, transforming under
Spin(4,4) exactly as the model's Psi16 of Section 11, with the Dirac matrices T16[a], the spinor
metric sigma16, the curved gamma^mu = coframe[[a, mu]] T16[a] of Section 17, the scalar bilinear
s = Psi^T sigma16 Psi, and a self-interaction potential V(s) that is left general:

    L_Psi  =  Sqrt[det g] * Lhat_Psi,      Lhat_Psi  =  (1/H) Psi^T sigma16 gamma^mu D_mu Psi  -  V(s),      D_mu = d_mu + Gamma^spin_mu .

Part V proved that on the canonical frame the connection term contributes nothing to this
Lagrangian (Psi^T sigma16 gamma^mu Gamma^spin_mu Psi == 0 for every Psi), so Lhat_Psi may equally
be written with the plain partial derivative; that equality is re-asserted here for the generic
Psi(x0, x4) of this section, because everything below rests on it.  The author's La of Section 11
is the case V(s) = -(2M/H) s on the flat frame with no volume factor.  That is the FIDELITY ANCHOR
of this section: the general Lagrangian helper, evaluated in that case on the model's own Psi16,
must reproduce La[] term for term, and its Euler-Lagrange equations must reproduce the sixteen
field equations eLa of Section 12.  Both are asserted before anything new is claimed.

The helper cfLagrangianFable[psi, frame, sqrtg, Vfun] takes the potential as a pure function of
s, so that a generic symbol, the author's -(2M/H)s, or a concrete V(s) can be passed without
changing the code; cfDiracOperatorFor[psi, gammaUp, gammaSpin] is the Dirac operator for an
arbitrary set of curved gamma matrices and spinor connection, needed for the FLRW frame below.

(* ::Input:: *)
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

(* ::Text:: *)
THE FIELD EQUATION, BY EXPLICIT VARIATION.  Varying the sixteen components of Psi in
Sqrt[g] Lhat_Psi -- with the kinetic matrix A^mu = sigma16 gamma^mu ANTISYMMETRIC and the mass
matrix sigma16 SYMMETRIC, so that the transposed half of the kinetic term integrates by parts
against Sqrt[g] A^mu -- gives

    EL  ==  Sqrt[g] [ (2/H) ( A^mu d_mu Psi + (1/2) D Psi )  -  2 V'(s) sigma16 Psi ],      D = (1/Sqrt[g]) d_mu ( Sqrt[g] A^mu ) .

The divergence term D is where the geometry enters.  Two identities settle what it is.  In
general (1/Sqrt[g]) d_mu(Sqrt[g] gamma^mu) == [gamma^mu, Gamma^spin_mu], because the curved
gamma matrices are covariantly constant (Section 17).  On the canonical frame the anticommutator
{gamma^mu, Gamma^spin_mu} vanishes as well -- the connection has no totally antisymmetric part --
so the commutator is twice the product, (1/2) D == sigma16 gamma^mu Gamma^spin_mu, and the field
equation is EXACTLY the Levi-Civita covariant Dirac equation

    gamma^mu D_mu Psi  ==  H V'(s) Psi .

On this geometry the connection term is -3 H Cot[6 H x0]^2 T16[0] Psi.  It does not vanish for a
spinor that is independent of x0: a spinor homogeneous in every coordinate but x4 is NOT a
solution, and that is why the rescaling of the next cell is needed.

(* ::Input:: *)
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

(* ::Text:: *)
THE RESCALING.  Part V proved that the connection term of the canonical Dirac operator is a
single vector term, -(1/2) T_mu gamma^mu with T_mu a gradient, and that it is removed exactly by
writing Psi = Sqrt[Sin[6 H x0]] Psi'.  Here that theorem does the work: for a GENERIC Psi'(x0, x4),

    ( gamma^mu D_mu - H V'(s) ) [ Sqrt[Sin[6 H x0]] Psi' ]  ==  Sqrt[Sin[6 H x0]] ( gamma^mu d_mu Psi' - H V'(s) Psi' ),
    s = Sin[6 H x0] * Psi'^T sigma16 Psi' .

For a Psi' that depends on x4 alone the equation collapses to gamma^4 d_4 Psi' == H V'(s) Psi', and
since (gamma^4)^2 = -ID16 it can be solved for the derivative, d_4 Psi' == -H V'(s) gamma^4 Psi'.
The honest qualification, asserted below: the right-hand side still depends on x0 through
V'(Sin[6 H x0] s').  For the mass term V = -(2M/H) s, V' is a constant and Psi'(x4) is an exact
solution; for a nonlinear V(s) it is not, and the exact problem is the (x0, x4) system for
Psi'(x0, x4).  Every statement about w below that uses Psi'(x4) is therefore a statement about the
constant-V' solutions, and is labelled so.

(* ::Input:: *)
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

(* ::Text:: *)
THE ENERGY-MOMENTUM TENSOR OF fable.  Varying the covariant action with respect to the frame
gives the symmetrised kinetic bilinear built with the COVARIANT derivative (the variation of the
spin connection contributes a term antisymmetric in mu, nu that drops from the symmetrised
tensor):

    T_{mu nu}  =  -(1/(2H)) ( Psi^T sigma16 gamma_mu D_nu Psi + Psi^T sigma16 gamma_nu D_mu Psi )  +  g_{mu nu} Lhat_Psi,      gamma_mu = g_{mu nu} gamma^nu .

A tempting shortcut would build the same expression with d_nu in place of D_nu, since the
connection dropped out of the Lagrangian.  It does not drop out of the tensor.  The two tensors
have the SAME DIAGONAL -- so rho and the pressures are the same either way -- but they differ
off the diagonal, and only the covariant one is conserved.  Both facts are asserted: the
diagonal agreement symbolically for the generic Psi(x0, x4), and the off-diagonal difference by a
witness on a concrete constant spinor (a witness must reduce to numbers, and the probe rules of
Section 15 know nothing about generic functions).

(* ::Input:: *)
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

(* ::Text:: *)
ON SHELL: rho, P AND THE LAGRANGIAN.  The field equation is solved for d_4 Psi,

    d_4 Psi  ==  F  =  -gamma^4 ( H V'(s) Psi - gamma^0 d_0 Psi - (1/2) divG Psi ),

and cfOnShell substitutes it: every x4-derivative of every component (of any order, mixed with
x0-derivatives or not) is replaced by the corresponding derivative of F, repeatedly, until no
x4-derivative of the field is left.  That is the "on shell" of this section, and it holds for a
GENERIC Psi(x0, x4).  Two kinetic bilinears organise the answer,

    cfKPsi  =  (1/H) Psi^T sigma16 gamma^4 d_4 Psi       along the observer's time,
    cfKh    =  -(1/H) Psi^T sigma16 gamma^0 d_0 Psi      along the hidden coordinate,

and the theorems are

    Lhat  ==  s V'(s) - V(s),        rho  ==  V(s) + K_h,        P_1 = P_2 = P_3  ==  s V'(s) - V(s) .

For the rescaled solutions Psi = Sqrt[Sin[6 H x0]] Psi'(x4), K_h vanishes identically (d_0 Psi is
proportional to Psi, and Psi^T sigma16 gamma^0 Psi == 0), so rho == V(s) and w == s V'(s)/V(s) - 1.
Finally the bilinear itself: on shell, ds/dx4 == 2 Psi^T sigma16 gamma^4 gamma^0 d_0 Psi for the
generic Psi(x0, x4) -- the two other terms of d_4 Psi drop because sigma16 gamma^4 and
sigma16 gamma^4 gamma^0 are antisymmetric -- and that survivor vanishes for the rescaled
x0-independent Psi'.  So s is constant in x4 on those solutions: NO DILUTION on the pre-universe,
the spinor analogue of "no Hubble friction".  (An earlier draft of this Part claimed ds/dx4 == 0
for the generic Psi(x0, x4); it is false, and the control below witnesses a non-zero value.)

(* ::Input:: *)
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

(* ::Text:: *)
CONSERVATION.  With cfOnShell in hand the conservation law can be tested for the GENERIC
Psi(x0, x4): the covariant divergence nabla^mu T_{mu nu} of the covariant tensor, with every
x4-derivative replaced by its on-shell value, must vanish in all eight components.  It does.  The
partial-derivative tensor does not pass this test -- it was checked symbolically while this Part
was being designed (its x0, x4 components are conserved and the other six are not), but that
symbolic check runs for minutes under the notebook's Simplify budget and is not repeated here;
the off-diagonal difference between the two tensors was witnessed numerically above, which is
what the claim "they are different tensors" requires.

(* ::Input:: *)
ClearAll[cfDivTCov];
cfDivTCov = cfTimed["nabla^mu T_{mu nu} of the covariant tensor of fable, generic Psi(x0, x4)",
  cfCovariantDivergence[cfTCov, gInvCanonical, GammaCanonical, X]];
cfAssert["FABLE [THE RESULT]: nabla^mu T_{mu nu} == 0 ON SHELL in all eight components, for a generic Psi(x0, x4) -- the covariant tensor is the conserved one",
  cfZeroArrayQ[Table[Expand[cfOnShell[cfDivTCov[[nu]]]], {nu, 8}]]];

(* ::Text:: *)
DUST, AND THE CLOSED FORMS OF w.  The author's own Lagrangian is the mass term V = -(2M/H) s.
For it, on shell, P_1 == 0 identically and rho == -(2M/H) s: the spinor of the original model,
promoted to a cosmological field, is PRESSURELESS -- cold dark matter, exactly, with rho > 0 on the
branch M s < 0.  For a general V on the rescaled solutions w = s V'(s)/V(s) - 1, which is n - 1
for V ~ s^n: dust at n = 1, accelerating for 0 < n < 2/3 (n = 0.236 gives Unite's constant-w
value -0.764 exactly), PHANTOM for n < 0.  And w + 1 = s V'/V changes sign where V' does: a
potential whose slope changes sign at s* with V(s*) > 0 lets w CROSS THE PHANTOM DIVIDE with no
wrong-sign kinetic term -- the classical spinor-quintom mechanism (Cai & Wang, Class. Quantum Grav. 25 (2008) 165014).  The
stability of perturbations is not examined here.  The six potentials of the numerical work and
their closed-form w are recorded and asserted; for lorentz and expdamp V is positive everywhere,
w -> -1 from below as s -> infinity (the far past, s ~ a^-3 in the reference model), crosses -1
at s = s1, and returns to -1 from above as s -> 0.  With expdamp's (V0, m, s1) = (1.566, 0.839, 2.21)
and s = 1 today, w(1) = -0.8608, Unite's w0 = -0.861.

(* ::Input:: *)
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

(* ::Text:: *)
THE 4-DIMENSIONAL REFERENCE MODEL (MODEL B): A SEPARATE FLRW FRAME.  To connect w_Psi(s) to a
history w(a) one needs how s evolves with the scale factor, and in the pre-universe it does not
evolve at all (ds/dx4 = 0 above).  The reference model of the observational literature is the
spinor on a Friedmann-Lemaitre-Robertson-Walker background, and this cell builds it the only
honest way: as a SEPARATE frame, diag(1, aF[x4], aF[x4], aF[x4], 1, 1, 1, 1) with its own scale
factor aF, fed to the same solver cfSpinConnection as every other frame in this notebook.  The
canonical frame and a4 are not touched -- the first assertion checks exactly that.  On the FLRW
frame the connection term of the Dirac operator is the familiar Hubble term,
gamma^mu Gamma^spin_mu == (3/2) (a'/a) gamma^4, the Dirac equation for Psi(x4) is
gamma^4 (d_4 + (3/2) H_obs) Psi == H V'(s) Psi, and on shell d(a^3 s)/dx4 == 0 for EVERY V: the
bilinear dilutes exactly as dust, s = s0 a^-3, and w_Psi(a) is the ALGEBRAIC function
s V'(s)/V(s) - 1 evaluated on it.  The whole history of w is fixed by the shape of V.  A control
removes the Hubble term and recovers the pre-universe's ds/dx4 = 0, showing that the dilution IS
the Hubble term and nothing else.

(* ::Input:: *)
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

(* ::Text:: *)
MODEL B, SOLVED INDEPENDENTLY.  With s = Exp[-3 N] exact, the only quantity that needs
integrating is the cosmic time, dt/dN = 1/H with H^2 = Om Exp[-3 N] + Or Exp[-4 N] + V(s)/3, and
w(N) is the algebraic function above.  The case is expdamp with (V0, m, s1) = (1.566, 0.839, 2.21)
and no normalisation (V(1) = 1.566 + 0.839/e^(1/2.21) ~ 2.0996 = 3 Omega_Psi0 with Omega_Psi0 = 0.6999),
the same parameters, grid and initial condition as the solver.  All inputs are exact rationals, so
Exp[-s/s1] at s = e^21 ~ 1.3e9 (the start, N = -7) is a tiny but exact number and no machine
underflow is ever raised; the rows are converted to 20-digit numbers only at the end.  If
fable-cosmology/reference/mathematica_spinor_expdamp.csv is present, w is compared with it at
every row to 1e-9.  What the run shows: w = -1 in the deep past (s huge, V -> V0), a genuine
PHANTOM phase with w below -1 -- the minimum is w = -1.302 at a = 0.543 (z = 0.84) on this grid --
the crossing of -1 at s = s1, i.e. a = s1^(-1/3) = 0.7677, and w(1) = -0.8608 today.

(* ::Input:: *)
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

(* ::Section:: *)
25.  Reading the two mechanisms side by side

(* ::Text:: *)
WHAT WAS PROVED, IN ONE TABLE.  The questions the task asks -- is w time-varying, can it cross
the phantom divide, is there a connection to dark matter, to dark energy, to the Supernovae Unite
fits (w0, wa) = (-0.861, -0.60) -- are answered field by field.  Every entry in the table below
is either a theorem of Sections 23-24 (marked so) or a property of the 4-dimensional reference
models integrated there and by the solver; nothing in it is a fit to data.

(* ::Input:: *)
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

(* ::Text:: *)
THE KINEMATIC IDENTIFICATION, AND ITS SIGN HYPOTHESIS.  The cosmological time is t = x4 (g_44 = -1,
the proper time of the observer u = d/dx4).  The x1-x3 frame entry at fixed x0 is the observed
scale factor,

    a(t)  ~  q  ~  Exp[-a4[H t]],        ln a  =  -a4[H t] + const,        H_obs  =  -H a4'[H t] .

This is a KINEMATIC IDENTIFICATION ONLY.  a4 stays undetermined; the observed sheet expands
(H_obs > 0) exactly in the regime a4' < 0, which is the regime assumed throughout this Part
(Section 15 reads the same frame the other way round: the sign is a hypothesis, not a result);
and the 4-dimensional reference models of Sections 23 and 24 do NOT live on the pre-universe --
their a(t) comes from a Friedmann equation with Hubble friction, which the pre-universe does not
have, and it is never substituted for a4.

THE VOLUME BOOKKEEPING, AND ITS CAVEATS.  Section 23 proved Sqrt[g_8] = q^3 * Vhid with the
hidden 4-volume density Vhid = Tan[6 H x0] p^3 ~ Exp[3 a4] = a^-3 (defined up to the formal
integral over the three non-compact timelike directions).  Integrating the 8-dimensional action
over the hidden coordinates gives a 4-dimensional action with weight a^3 Vhid Lhat, and a reduced
tensor T^(4) = Vhid T^(8) whose density rho_4 = Vhid rho_8 obeys

    d rho_4/dt + 3 H_obs (rho_4 + P_4)  ==  3 H_obs P_4

for every w: it is NOT separately conserved -- energy flows into the contracting sheet -- and
it falls as a^-3 even when the locally measured density rho_8 = T_44 is exactly constant (as it
is for phi(x4), Section 23).  The a^-3 is a volume effect that holds for every w; it is NOT a
dark-matter signature, because a cosmological constant would pass the same test.  Which of the
two densities gravitates is undetermined: the framework has no gravitational sector (no Einstein
equations, a4 free).  The standard quintessence model -- the field sources the expansion, the
hidden volume is held fixed -- is what Models A and B integrate; it is the reference model of the
PDF and of the CPL fits, and it is not derived from the pre-universe here.

WHAT IS PROVED ON THE 8-MANIFOLD, AND WHAT IS THE REFERENCE MODEL.  Proved on the pre-universe,
for arbitrary a4 and with every identity closed symbolically: the two energy-momentum tensors and
their conservation, the null energy condition of fableScalar and its w >= -1, the absence of
Hubble friction and the undamped virial dust of the quadratic scalar, the cosmological-constant
behaviour of a static x0 gradient on the observed sheet, the covariant Dirac equation of fable
and its rescaling, rho = V + K_h and P = s V' - V, the dust of the author's mass term, the
constancy of s in x4, and the volume factorisation.  The reference model -- Friedmann expansion
driven by the field, s ~ a^-3, the thawing exp scalar, the phantom crossing of expdamp at
a = 0.768 -- is 4-dimensional physics on a separate FLRW frame, checked here to be what the solver
integrates, and it is where all contact with (w0, wa) is made.

(* ::Input:: *)
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

(* ::Text:: *)
THE FINAL TALLY.  Section 22's tally cell counted the assertions of Parts I-V (250, all passed)
and remains where it is, untouched.  This cell repeats the same tally after Part VI, so that the
last cell of the notebook reports every assertion made anywhere in it -- including the one that
no identity was accepted on numerical evidence alone -- and the non-vanishing witnesses added by
this Part.

(* ::Input:: *)
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
