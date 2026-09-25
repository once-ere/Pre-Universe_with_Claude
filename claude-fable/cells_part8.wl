(* ::CELLMANIFEST-PART:: 8 *)

(* ::Title:: *)
PART VIII  --  fable as a source of the Einstein equations of the primordial gravitational field

(* ::Text:: *)
WHAT THIS PART IS FOR, IN ONE PARAGRAPH.  Parts III-V built the 4+4 geometry of the pre-universe
-- the canonical frame, its Levi-Civita spin connection, and the fable-5.1 torsion that carries
the same information -- but they never asked what SOURCES that geometry.  Part VI put fields on
it without letting them act back.  Part VII made fable a complex 16-component fermion field,
quantized it canonically and built its energy-momentum tensor operator.  Part VIII closes the
loop: it computes the Einstein tensor of the primordial gravitational field, reads off what
energy-momentum it demands, derives the family of frames on which fable can source it, computes
the canonical spin connection of that interacting system, and writes out and solves the coupled
equations G = kappa <That> with fable in its Kohn-Sham ground state, from the radiation era to
today.

CONVENTIONS, RESTATED.  Coordinates X = {x0, ..., x7} are 1-based in Wolfram arrays (x4 is entry 5);
eta4488 = diag(1,1,1,1,-1,-1,-1,-1); the frame is stored with the curved index on the row, so
g = frame . eta4488 . Transpose[frame].  The Einstein tensor is used with one index up and one
down, G^mu_nu, because then the answer does not depend on how the metric signs are distributed.
kappa = 8 pi G_8 > 0 is the eight-dimensional gravitational coupling, a plain symbol.  For a
source at rest in the observer's frame the energy density and the pressures are the diagonal of
the mixed tensor,

    rho = -T^4_4,     P_obs = T^i_i  (i = 1,2,3),     P_hid = T^h_h  (h = 5,6,7),     P_C = T^0_0 ,

so that the Einstein equations G^mu_nu = kappa T^mu_nu read G^4_4 = -kappa rho, G^i_i = kappa P_obs,
and so on.  WHAT IS REUSED.  Nothing of Parts I-VII is redefined here.  From Sections 16-17 the
solvers cfChristoffel and cfSpinConnection and the canonical objects; from Section 21 the Weitzenboeck
torsion; from Section 23 cfCovariantDivergence; from Part VII the symmetrized Lagrangian and tensor
helpers cfLhatFermion and cfTFermion, the independent field families cfPsiCGen, cfPsiBGen (of x0, x4)
and cfPsiC8, cfPsiB8, cfPsiP8 (of all eight coordinates), the canonical That = cfTF and Lhat = cfLhatC,
the Kohn-Sham closed forms cfNKS, cfSigKS, cfEpsKS, cfPKS (symbols cfKF, cfMm > 0, cfGdeg), the Krein
operator J = cfJK with its tests cfJCommQ, cfJAntiQ, the Dirac-bracket anticommutator cfAntiPsiPsiDd,
G = cfGK, and cfSimp60 (Simplify with a 60-second budget, since Section 1 sets 1 second).

THE RULE OF PARTS III-VII STILL HOLDS: a4 IS NEVER GIVEN A VALUE.  The dynamical frames of
Sections 31-33 carry their own scale factors scA, scB, scC (functions of x4, separate symbols;
simplifications on them assume A, B, C > 0 in addition to Section 15's assumptions); the canonical frame is recovered from them only by an explicit, labelled substitution
inside an assertion, and the last assertion of this Part checks that a4 is still undefined.

(* ::Section:: *)
30.  The Einstein tensor of the canonical metric, and what it demands of its source

(* ::Text:: *)
THE TOOL.  The Einstein tensor is computed from the Christoffel symbols of Section 16,

    R_{mu nu} = d_l Gamma^l_{mu nu} - d_nu Gamma^l_{mu l} + Gamma^l_{l s} Gamma^s_{mu nu} - Gamma^l_{nu s} Gamma^s_{mu l},
    R = g^{mu nu} R_{mu nu},        G^mu_nu = g^{mu k} R_{k nu} - (1/2) delta^mu_nu R ,

by one helper, cfEinsteinData, that every frame of this Part goes through.  It is not trusted
until it has passed three tests, each of which a wrong index or sign would fail.  (1) On the
separate FLRW frame of Section 24 it must return the Friedmann equations with the textbook
signs: G^4_4 = -3 H_obs^2, G^i_i = -(2 a''/a + H_obs^2), and G = -3 (a''/a + H_obs^2) along the
four static directions.  (2) On the canonical frame its Ricci scalar must equal the one Section 16
obtained by a completely different route, from the curvature 2-form of the spin connection.
(3) Its output must obey the contracted Bianchi identity nabla_mu G^mu_nu = 0, which fails for
any wrong Ricci tensor; the divergence is taken with Section 23's cfCovariantDivergence.

(* ::Input:: *)
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

(* ::Text:: *)
ALL SIXTY-FOUR COMPONENTS.  With Cot = Cot[6 H x0], Csc = Csc[6 H x0], a4' = a4'[H x4] and
a4'' = a4''[H x4] (derivatives with respect to the argument of a4), the mixed Einstein tensor of
the canonical metric is DIAGONAL -- all 56 off-diagonal components vanish identically -- and

    G^0_0  =  3 H^2 ( 5 Cot^4 - a4'^2 )
    G^i_i  =  (H^2/2) ( 15 (9 + Cos[12 H x0]) Cot^2 Csc^2 - 6 a4'^2 - 2 a4'' )          i = 1, 2, 3
    G^4_4  =  (3 H^2/2) ( (55 + 7 Cos[12 H x0]) Cot^2 Csc^2 + 2 a4'^2 )
    G^h_h  =  (H^2/2) ( 15 (9 + Cos[12 H x0]) Cot^2 Csc^2 - 6 a4'^2 + 2 a4'' )          h = 5, 6, 7
    R      =  -3 H^2 ( (55 + 7 Cos[12 H x0]) Cot^2 Csc^2 - 2 a4'^2 ) .

THE SPLIT.  Every component is a function of x0 alone PLUS a function of x4 alone; there is no
cross term.  The statement is made without giving a4 any value: the x0-part is the Einstein
tensor of the SEPARATE frame diag(Tan[6 H x0], S^(-1/6) x3, 1, S^(-1/6) x3), S = Sin[6 H x0], which
does not contain a4, and the a4-part is the Einstein tensor of the SEPARATE frame
diag(1, Exp[-a4] x3, 1, Exp[+a4] x3), which does not contain x0.  The canonical Einstein tensor
is asserted to be their sum, entry by entry.  The x0-part does not distinguish the observed from
the hidden sheet (G^i_i = G^h_h there); only a4'' does.

(* ::Input:: *)
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

(* ::Text:: *)
THEOREM (a), ENERGY.  G^4_4 = -kappa rho_total, and the minimum of 55 + 7 Cos[12 H x0] is 48.
Therefore, for every a4 and everywhere in 0 < 6 H x0 < Pi/2,

    rho_total  =  -G^4_4/kappa  <=  -( 72 H^2 Cot^2 Csc^2 + 3 H^2 a4'^2 )/kappa  <  0 ,

with G^4_4 - (72 H^2 Cot^2 Csc^2 + 3 H^2 a4'^2) = (21/2) H^2 (1 + Cos[12 H x0]) Cot^2 Csc^2 >= 0
exactly.  The total energy density that sources the canonical metric is NEGATIVE everywhere.  No
source with rho >= 0 can be the sole source of this geometry -- in particular not the Kohn-Sham
fable of Part VII with the author's mass term, whose rho = eps_KS is positive (it vanishes at
kF = 0 and grows with kF, d eps_KS/d kF = g kF^2 wF/(2 pi^2) > 0).

THE BACKGROUND-STRESS READING (an illustration, and the splitting is a choice).  One may split
the source as T = T_bg + T_rest with T_bg := G_x0/kappa, the x0-part of the Einstein tensor
held as a fixed background.  Its energy density is rho_bg = -(3 H^2/(2 kappa)) (55 + 7 Cos[12 H x0])
Cot^2 Csc^2 < 0 everywhere.  The remaining equations G_a4 = kappa T_rest then demand a stress that
is independent of x0, because G_a4 is; the fable solutions of Section 24 are not -- the rescaled
solution Psi = Sqrt[Sin[6 H x0]] Psi'(x4) has rho = V(Sin[6 H x0] s'), which depends on x0 for the
author's mass term.  So fable would have to deform the x0-profile.  This is an illustration of
the splitting, not a theorem about the full coupled problem, and it is stated as such.

(* ::Input:: *)
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

(* ::Text:: *)
THEOREM (b), ANISOTROPY.  Subtracting the hidden-sheet equation from the observed-sheet one, the
x0-parts cancel and

    G^i_i - G^h_h  =  -2 H^2 a4''        so        a4''  =  -kappa ( P_obs - P_hid ) / (2 H^2)

for ANY source.  Now take fable as the source, as a c-number configuration Psi(x0, x4),
Psibar(x0, x4) of the symmetrized Lagrangian of Part VII,

    Lhat = (1/(2H)) [ Psibar gamma^mu D_mu Psi - (D_mu Psibar) gamma^mu Psi ] - V(s),     s = Psibar Psi,
    That_{mu nu} = -(1/(4H)) [ Psibar gamma_mu D_nu Psi - (D_nu Psibar) gamma_mu Psi + (mu <-> nu) ] + g_{mu nu} Lhat ,

with Psi and Psibar INDEPENDENT functions.  Along a direction on which the fields do not depend,
D_i Psi = Gamma_i Psi and D_i Psibar = -Psibar Gamma_i, so the kinetic part of That_{ii} is
-(1/(2H)) Psibar {gamma_i, Gamma_i} Psi, and the canonical connection has {gamma_mu, Gamma_mu} = 0 FOR
EACH mu separately (Section 27 (c)).  Hence, OFF shell and for every V,

    P_obs  =  T^i_i  =  Lhat  =  T^h_h  =  P_hid ,

and such configurations force a4'' = 0: the anisotropy of the canonical frame cannot be sourced
by them.  The Kohn-Sham Fermi gas of Part VII is different: its quasi-particles move along the
observed sheet only, so P_obs - P_hid = P_KS/v, where v = B^3 C is the hidden 4-volume per
reference volume (Section 33) and P_KS = (g/(2 pi^2)) Int_0^kF k^4/(3 wk) dk > 0 (it vanishes at
kF = 0 and dP_KS/dkF = g kF^4/(6 pi^2 wF) > 0).  So the KS gas can source a4'' < 0.  (The tensor used
below is Section 29's That for the independent families cfPsiCGen, cfPsiBGen of (x0, x4), built by
Section 26's frame-generic helper cfTFermion; the per-7-volume fluid cfKSFluid is defined here and
used again in Section 33.)

(* ::Input:: *)
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

(* ::Text:: *)
THEOREM (c), MOMENTUM.  G^0_4 = G^4_0 = 0 on the canonical frame, so the source must carry no
momentum along the hidden coordinate, T^0_4 = 0.  That is a real condition on fable: its T_{04}
is not identically zero (witnessed below on a concrete pair Psi, Psibar).

THE ASYMPTOTIC CANONICAL FRAME IS SOURCED BY A GHOST.  The a4-part of the Einstein tensor is the
Einstein tensor of diag(1, Exp[-a4] x3, 1, Exp[a4] x3), which Section 31 shows to be the
asymptotic (6 H x0 -> Pi/2) form of the canonical frame.  With h = H a4'[H x4] (so that
H_obs = -h) and h' = dh/dx4 = H^2 a4'', the stress it demands is

    rho  =  P_C  =  -3 h^2/kappa,        P_obs  =  rho - h'/kappa,        P_hid  =  rho + h'/kappa .

Its x0-pressure equals its energy density (w_C = +1, stiff), and it is negative: when h' = 0 all
seven pressures equal rho = -3 h^2/kappa, which is exactly the energy-momentum tensor of a GHOST
scalar phi(x4) (a scalar with the wrong sign of its kinetic term) with phi'^2 = 6 h^2/kappa.  The
general statement, asserted without setting a4'' to anything, is that the demanded stress is the
ghost tensor plus the traceless anisotropic stress h'/kappa diag(0, -1,-1,-1, 0, +1,+1,+1).  The
volume-preserving expansion of the observed sheet (h < 0 means H_obs > 0) is sourced by negative
energy.

(* ::Input:: *)
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


(* ::Section:: *)
31.  The generalized warped frame, its asymptotic region, and the 8-dimensional Bianchi-I limit

(* ::Text:: *)
THE FAMILY OF FRAMES ON WHICH fable CAN ACT BACK.  Section 30 showed that the canonical frame,
with its single free function a4, cannot absorb a positive energy density.  The natural
generalization keeps the x0-profile of the canonical frame and gives each block its own scale
factor, a function of the observer's time x4:

    e = diag( Tan[6 H x0] C,  A S^(-1/6), A S^(-1/6), A S^(-1/6),  1,  B S^(-1/6), B S^(-1/6), B S^(-1/6) ),     S = Sin[6 H x0],

with A = scA[x4] (observed sheet), B = scB[x4] (hidden timelike sheet), C = scC[x4] (hidden x0
direction), and the rates H_A = A'/A, H_B = B'/B, H_C = C'/C.  The canonical frame is the member
A = Exp[-a4], B = Exp[+a4], C = 1 -- an explicit, labelled substitution, used only inside
assertions.  The theorem (F4 of the design, as corrected in review):

    diag G^mu_nu  =  diag G_x0 / C^2  +  diag G_BI(A, B, C)       EXACTLY,

where G_x0 is the x0-part of Section 30 and G_BI is the Einstein tensor of the unwarped
8-dimensional Bianchi-I frame diag(C, A, A, A, 1, B, B, B).  The ONLY off-diagonal components are

    G^4_0  =  3 H Cot[6 H x0] ( 2 H_C - H_A - H_B ),         G^0_4  =  -3 H Cot[6 H x0]^3 ( 2 H_C - H_A - H_B ) / C^2 .

On the canonical member everything reduces to Section 30, and the contracted Bianchi identity
holds for the whole family.

(* ::Input:: *)
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

(* ::Text:: *)
THE (0,4) EQUATION SINGLES OUT THE AUTHOR'S VOLUME-PRESERVING STRUCTURE -- IT DOES NOT DERIVE IT.
The Einstein equation G^4_0 = kappa T^4_0 with a source that carries no momentum along x0
(T^4_0 = 0: required on the canonical frame by Theorem (c), and true of the Kohn-Sham fluid, whose
quasi-particles move along the observed sheet only) gives, since Cot[6 H x0] is not zero,

    2 H_C  =  H_A + H_B .

Within the separable warped family and with the x0 direction STATIC (C = 1, a labelled
substitution) this is H_A + H_B = 0, i.e. A B = const: exactly the author's volume-preserving
pairing A = Exp[-a4], B = Exp[+a4].  So the author's ansatz is singled out by the momentum
constraint once C = 1 is imposed; it is not derived, because C = 1 is itself an assumption.  With
C dynamical the constraint is H_C = (H_A + H_B)/2, and the energy bill changes sign: the
Bianchi-I part of kappa rho = -G^4_4 is the sum over pairs of the seven directions,

    kappa rho  =  -G_x0^4_4/C^2  +  3 H_A^2 + 3 H_B^2 + 9 H_A H_B + 3 H_A H_C + 3 H_B H_C ,

which is -3 H_A^2 < 0 on the volume-preserving branch (H_B = -H_A, H_C = 0) -- Section 30's
negative energy -- but (9/2)(H_A^2 + H_B^2) + 12 H_A H_B on the branch H_C = (H_A + H_B)/2, and
that is +(9/2) H_A^2 > 0 when the hidden sheet is static (H_B = 0).  With C dynamical a
POSITIVE-energy expansion of the observed sheet is allowed (the x0-term -G_x0^4_4/C^2 is still
negative, and the next cell shows how fast it decays).

(* ::Input:: *)
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

(* ::Text:: *)
THE ASYMPTOTIC REGION.  The proper distance along x0 at fixed x4 (C = 1) is
z = Int_0^x0 Tan[6 H y] dy = -Log[Cos[6 H x0]]/(6 H), and 6 H x0 -> Pi/2 is z -> infinity.  In the
coordinate z the warped metric is EXACTLY

    ds^2  =  C^2 dz^2  +  A^2 (1 - Exp[-12 H z])^(-1/6) dx_obs^2  -  dx4^2  -  B^2 (1 - Exp[-12 H z])^(-1/6) dx_hid^2 ,

so it tends to the unwarped Bianchi-I metric, and every x0-term of the Einstein tensor decays with
Cot[6 H x0]^2 = Exp[-12 H z]/(1 - Exp[-12 H z]).  Component by component, as 6 H x0 -> Pi/2:

    G_x0^0_0 ~ 15 H^2 Cot^4,     G_x0^i_i = G_x0^h_h ~ 60 H^2 Cot^2,     G_x0^4_4 ~ 72 H^2 Cot^2,
    G^4_0 ~ Cot,   G^0_4 ~ Cot^3 .

Read as a background stress T_bg = G_x0/(kappa C^2), in units of H^2 Cot^2/(kappa C^2):
rho_bg -> -72, P_obs = P_hid -> 60, P_C -> 15 Cot^2 -> 0.  If T_bg is NOT counted as a source,
the x0-terms act on the Bianchi-I evolution equations (next cell) as residual drivers
kappa (P_i - T/6)|bg -> -12 H^2 Cot^2/C^2 for A and for B, and -72 H^2 Cot^2/C^2 for C.  The
present universe may be treated as the 8-dimensional Bianchi-I region when the background is
negligible against the observer's critical density, kappa |rho_bg|/(3 H_A^2) -> 24 (H/H_A)^2
Cot^2/C^2 << 1: the VALIDITY INEQUALITY of Section 33's models.

(* ::Input:: *)
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

(* ::Text:: *)
THE 8-DIMENSIONAL BIANCHI-I EQUATIONS (F5).  In the asymptotic region the primordial field is the
metric ds^2 = C^2 dz^2 + A^2 dx_obs^2 - dx4^2 - B^2 dx_hid^2.  Its mixed Einstein tensor does NOT
depend on whether the hidden directions are timelike or spacelike: flipping the three hidden signs
of eta leaves every G^mu_nu unchanged (asserted).  With the source T^mu_nu =
diag(P_C, P_obs x3, -rho, P_hid x3) and T = -rho + 3 P_obs + 3 P_hid + P_C, the Einstein equations
are equivalent to

    constraint:   3 H_A^2 + 3 H_B^2 + 9 H_A H_B + 3 H_A H_C + 3 H_B H_C  =  kappa rho        (the 21 pairs of the 7 directions)
    evolution:    H_i' + H_i Theta  =  kappa ( P_i - T/6 ),     i = A, B, C,     Theta = 3 H_A + 3 H_B + H_C,

the evolution form being the Ricci form R^i_i = kappa (T^i_i - T/(D-2)) with D - 2 = 6.  The
source must obey the 8-dimensional conservation law for anisotropic pressures, which is the
nu = 4 component of nabla_mu T^mu_nu = 0:

    rho' + 3 H_A (rho + P_obs) + 3 H_B (rho + P_hid) + H_C (rho + P_C)  =  0 .

(* ::Input:: *)
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


(* ::Section:: *)
32.  The canonical spin connection of the interacting system

(* ::Text:: *)
THE SAME SOLVER, TWO NEW FRAMES.  The spin connection of the frames on which fable acts back is
computed exactly as every connection of Parts III-VI was: the vielbein postulate of Section 16,
solved by cfSpinConnection, lowered with eta4488, checked by the postulate residual (a regression
test of the solver) and by antisymmetry (metric compatibility, which has content), and turned
into the 16x16 matrices Gamma_mu = (1/8) omega_{mu ab} [T16[a], T16[b]] by Section 17's
cfSpinMatrix, where T16[a] is gamma^a (flat index up) and omega_{mu ab} carries BOTH flat indices
down, lowered with eta4488 (raising both would flip the sign of every plane that contains x4 or a
hidden timelike direction, since eta44 = eta55 = eta66 = eta77 = -1).  With omega_{mu ab} listed
for a < b (the partner omega_{mu ba} = -omega_{mu ab}), the complete list of non-zero components
is, on the WARPED frame (S = Sin[6 H x0]),

    omega_{0 04}  =  Tan[6 H x0] C'
    omega_{i 0i}  =  H Cos[6 H x0]^2 A / (C S^(13/6)),        omega_{i i4}  =  A' / S^(1/6)        (i = 1, 2, 3)
    omega_{h 0h}  = -H Cos[6 H x0]^2 B / (C S^(13/6)),        omega_{h 4h}  =  B' / S^(1/6)        (h = 5, 6, 7)

-- thirteen independent components, the first of which is NEW: the canonical frame (C = 1) has no
connection along x0 at all.  On the 8-dimensional Bianchi-I frame only the seven components
omega_{0 04} = C', omega_{i i4} = A', omega_{h 4h} = B' survive.  Both lists are asserted
component by component, and on the canonical member (labelled substitution) the warped list
reduces to the 24 non-zero components of Section 16.

(* ::Input:: *)
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
cfAssert["SPIN CONNECTION [THE RESULT]: the complete list of non-zero omega_{mu ab} (both flat indices down) of the WARPED frame is the thirteen stated components (and their antisymmetric partners) -- nothing else",
  Block[{cfGeomAssume = cfWarpAssume}, cfZeroArrayQ[cfOmegaWarp - cfOmegaFromList[cfOmegaWarpList]]]];
cfAssert["SPIN CONNECTION [THE RESULT]: the complete list for the Bianchi-I frame is omega_{0 04} = C', omega_{i i4} = A', omega_{h 4h} = B' (both flat indices down) -- nothing else",
  cfZeroArrayQ[cfOmegaBI - cfOmegaFromList[cfOmegaBIList]]];
cfAssert["SPIN CONNECTION [fidelity]: on the canonical member (labelled substitution) the warped connection IS omegaCanonical of Section 16, and the new component omega_{0 04} vanishes there",
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

(* ::Text:: *)
WHAT THE CONNECTION DOES TO THE DIRAC OPERATOR.  Four statements, each asserted.

(i) The whole connection enters the Dirac operator as ONE matrix,

    gamma^mu Gamma_mu  =  -(3 H Cot[6 H x0]^2 / C) T16[0]  +  (1/2) ( 3 H_A + 3 H_B + H_C ) gamma^4 ,       gamma^4 = T16[4],

the first term being the canonical term of Section 24 divided by C, the second the Hubble
(dilution) term of an expanding 7-volume -- with the PLUS sign; the opposite sign fails.

(ii) {gamma_mu, Gamma_mu} = 0 for EACH mu separately on the warped and on the Bianchi-I frame, so
the symmetrized Lagrangian of Part VII is the same with D_mu as with d_mu on these frames (asserted
with Section 26's cfLhatFermion for Psi, Psibar of all eight coordinates on the warped frame), and
the pressures along directions on which the fields do not depend are again Lhat (Section 30(b)).

(iii) Gamma_x4 = 0, but Gamma_x0 = (1/2) Tan[6 H x0] C'(x4) T16[0].T16[4]: it is not zero as soon as
the x0 direction is dynamical (witnessed on C = 1 + x4^2/3).

(iv) THE WEITZENBOECK FORM.  Computed as in Part V -- the torsion of the connection in which the
frame is parallel, T^a_{mu nu} = d_mu e_nu^a - d_nu e_mu^a, pulled to curved indices and traced,
T_mu = T^nu_{nu mu} -- the torsion vector of the warped frame is a gradient,

    T_mu  =  d_mu Log[ Sin[6 H x0] / (A^3 B^3 C) ] ,

and gamma^mu Gamma_mu = -(1/2) T_mu gamma^mu, exactly as for the canonical frame in Part V.  So
the rescaling

    Psi  =  Sqrt[Sin[6 H x0]] (A^3 B^3 C)^(-1/2) chi

removes the connection from the Dirac operator for a GENERIC chi(x0, ..., x7) (Section 27's family
cfPsiP8): gamma^mu D_mu Psi = Sqrt[Sin] (A^3 B^3 C)^(-1/2) gamma^mu d_mu chi.  The anticommutator of
Section 28 carries over to the warped family because its derivation is local in time and the lapse
is still 1 with gamma^4 = T16[4]: the time-derivative part is Psi^ddag K d_4 Psi with
K = (Sqrt[|det g|]/H) sigma16 T16[4], and Section 28's Dirac-bracket result for K = c sigma16 T16[4]
(cfAntiPsiPsiDd) with c = Sqrt[|det g|]/H gives {Psi_a(x), Psi^ddag_b(y)} = (H/Sqrt[|det g|]) G_ab delta^7(x - y),
G = -i sigma16 T16[4] = J (Section 28's cfGK), the same matrix on every member of the family.  The
Sqrt[det g] then cancels against the rescaling: Sqrt[|det g|] = Tan[6 H x0] C A^3 B^3/S, so

    {chi_a(x), chi^ddag_b(y)}  =  H Cot[6 H x0] G_ab delta^7(x - y) ,

independent of x4 and of A, B, C -- on the canonical member this is Section 28's H Cot[6 H x0] J.

(* ::Input:: *)
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

(* ::Text:: *)
THE KREIN OPERATOR J AND THE CONNECTION.  Section 28 quantized fable with the fundamental symmetry
J = -i T16[0].T16[1].T16[2].T16[3].T16[4] (Hermitian, J^2 = 1).  J commutes with T16[0], ..., T16[4]
and anticommutes with T16[5], T16[6], T16[7].  The connection of the interacting system respects
this split, direction by direction, on the warped AND on the Bianchi-I frame:

    [J, gamma^mu Gamma_mu] = 0 for EACH mu (no sum),  h = 5, 6, 7 included;
    [J, Gamma_mu] = 0 for mu = 0, ..., 4;        {J, Gamma_h} = 0 for h = 5, 6, 7   (Gamma_h is not zero).

So every connection term of the admissible-sector Hamiltonian is J-even, on the frames of Sections
31-33 as on the canonical one.  Finally the recovery: on the canonical member (labelled
substitution) Gamma_mu is Section 17's GammaSpinCanonical in every direction, and the Hubble
coefficient 3 H_A + 3 H_B + H_C = -3 H a4' + 3 H a4' + 0 VANISHES -- the 7-volume of the canonical
frame is constant in x4.  That is why Part VI found no dilution (ds/dx4 = 0) on the pre-universe:
the dilution term is present in the general frame and cancels exactly on the author's.

(* ::Input:: *)
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


(* ::Section:: *)
33.  The coupled equations of fable and the primordial field, and their solution from the radiation era to today

(* ::Text:: *)
THE SEMICLASSICAL SYSTEM.  The metric stays classical and fable is quantized:

    G^mu_nu  =  kappa < That^mu_nu > ,

with the expectation value taken in the Kohn-Sham ground state of Section 29: a homogeneous Fermi
sea at T = 0, g = 8 states per spatial momentum, momenta along the observed sheet only (zero modes
along x0, x5, x6, x7 -- the admissible sector of Section 28), in the mean field m = W'(sigma) of
the potential W(sigma) := V(H sigma).  In the asymptotic region of Section 31 the metric is
8-dimensional Bianchi-I and the source is diagonal.  Section 29's closed forms (cfNKS, cfSigKS,
cfEpsKS, cfPKS, in the symbols cfKF = kF, cfMm = m > 0, cfGdeg = g; proved there by differentiation,
by Integrate and by quadrature) are densities per unit OBSERVED 3-volume.  Spread over the hidden
4-volume v = B^3 C (relative to a reference hidden volume) they become densities per 7-volume, and
the fluid that sources the Einstein equations is

    sigma7 = sigma_KS/v,     gap:  m = W'(sigma7),
    rho    =  eps_KS/v + W(sigma7) - sigma7 W'(sigma7)      ( = 3 P_KS/v + W(sigma7) on the gap ),
    P_obs  =  P_KS/v + sigma7 W' - W,        P_hid  =  P_C  =  sigma7 W' - W .

At v = 1 this is Section 29's mean field.  The massless limit is sigma -> 0, eps = 3 P = g kF^4/(8 pi^2).
The identities of Section 29 that the theorems below use are re-checked here, on the same closed
forms: eps + P = wF n (Gibbs), eps - 3 P = m sigma (trace), T_s := eps - m sigma = 3 P, d eps/dm = sigma
(Hellmann-Feynman), d eps/dkF = wF dn/dkF.
NEGATIVE m.  Section 29 writes the closed forms for m > 0; sigma_KS is odd in m and eps_KS, P_KS are
even.  Under m -> -m, sigma -> -sigma and W(x) -> W~(x) := W(-x), the fluid (rho, P_obs, P_hid) is
unchanged and the gap m = W'(sigma7) goes into -m = W~'(-sigma7).  So every statement below that is
proved for m > 0 and an ARBITRARY W holds for m < 0 as well.

(* ::Input:: *)
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

(* ::Text:: *)
THEOREM: THE KOHN-SHAM FLUID IS EXACTLY CONSERVED IN 8-DIMENSIONAL BIANCHI-I.  The fable number
in a comoving 7-volume, (n_KS/v) A^3 v = n_KS A^3, is conserved, so kF = kF0/A.  Take the scale
factors A, B, C and the mass m(x4) > 0 as ARBITRARY functions and W arbitrary.  Then, identically,

    rho' + 3 H_A (rho + P_obs) + (3 H_B + H_C)(rho + P_hid)  =  sigma7 * d/dx4 [ m - W'(sigma7) ] .

The right-hand side is the time derivative of the gap equation.  On the self-consistent solution it
vanishes at every x4, so the KS fluid obeys Section 31's conservation law (with P_C = P_hid)
EXACTLY, for every W -- the Einstein equations with this source are consistent (and by the parity of
the previous cell, for m < 0 too).  The mechanism: rho + P_obs = wF n_KS/v and rho + P_hid = eps_KS/v
hold identically, d eps = wF dn + sigma dm (Section 29), and the gap cancels the sigma dm term
against the variation of W.  Off the gap the fluid is not conserved (control).

(* ::Input:: *)
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

(* ::Text:: *)
THE HIDDEN-SHEET DRIVER.  With P_C = P_hid, Section 31's evolution equations for B and C both read

    H_B' + H_B Theta  =  H_C' + H_C Theta  =  kappa F/6,        F  =  rho - 3 P_obs + 2 P_hid .

F is the driver of the hidden sheet: radiation (P_obs = rho/3, P_hid = 0) has F = 0, dust has
F = rho, an 8-dimensional vacuum (all pressures -rho) has F = 2 rho, and the KS fluid has

    F  =  2 W - sigma7 W'   on the gap         (off the gap: sigma7 (m - W') + 2 W - sigma7 W'),

so the author's mass term W = m0 sigma drives the sheet exactly like dust (F = m0 sigma7), and
W = V0 + m0 sigma gives F = 2 V0 + m0 sigma7.  Given H_B = H_C = 0 at one time, the hidden sheet stays
FROZEN for all time iff F = 0 along the history; for the KS fluid, for all sigma7 the history
sweeps, iff sigma W' = 2 W, i.e. W = c sigma^2.  Then the gap is m = 2 c sigma7.  m = 0 is always a
root.  For c < 0 it is the only one: m sigma_KS > 0 for m != 0, so a root m != 0 would give
m^2 = 2 c (m sigma_KS)/v < 0.  For c > 0 a non-trivial root exists iff c g kF^2/(2 pi^2 v) > 1
(sigma_KS/m decreases strictly, from g kF^2/(4 pi^2) at m -> 0 to 0 at m -> infinity), and it has
HIGHER energy: on it rho = (eps_KS(m) - m sigma_KS(m)/2)/v, and Delta(m) = eps_KS(m) - m sigma_KS/2 -
eps_KS(0) vanishes at m = 0+ and has dDelta/dm = (g m^3/(4 pi^2)) (L - kF/wF) > 0 (L - kF/wF =
phi(kF/m), and phi(x) = Log[x + Sqrt[1 + x^2]] - x/Sqrt[1 + x^2] vanishes at 0 and has derivative
x^2/(1 + x^2)^(3/2) > 0).  So the ground state of a frozen-compatible fable is the m = 0 branch, on
which rho = eps_KS(kF, 0)/v, P_obs = rho/3, P_hid = 0: RADIATION.  A KS fable compatible with a
frozen hidden sheet is neither dark matter nor dark energy.

(* ::Input:: *)
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

(* ::Text:: *)
NO PHANTOM CROSSING.  rho + P_obs = wF n_KS/v >= 0 identically (two cells up), so w_f = P_obs/rho >= -1
wherever rho > 0.  The quantized fermion fable CANNOT cross the phantom divide; the classical
crossing of Section 24 (at V'(s*) = 0) does not survive quantization.

THE CLASSICAL LIMIT IS THE NON-RELATIVISTIC LIMIT, kF << |m| (not a coherent zero mode: Pauli
forbids that).  Exactly, on the gap, with s = H sigma7 and V(s) := W(s/H) (so V(s) = W(sigma7) and
s V'(s) = sigma7 W'(sigma7)):

    rho  =  V(s) + 3 P_KS/v,        P_obs  =  s V'(s) - V(s) + P_KS/v,        P_hid  =  s V'(s) - V(s) ,

and as kF/m -> 0 (m > 0, n_KS = g kF^3/(6 pi^2))

    sigma_KS = n_KS [1 - (3/10) kF^2/m^2 + ...],   eps_KS = n_KS m + (3/10) n_KS kF^2/m + ...,   P_KS = n_KS kF^2/(5 m) + ... ,

so P_KS/rho -> 0 and the quantized fluid reduces to Section 24's rho = V(s), P = s V'(s) - V(s) (its
K_h = 0 branch); P_hid is exactly Section 24's on-shell pressure formula.  (Section 29 states the
v = 1 case of the exact decomposition; here it is per 7-volume and tied to V.)  In the design's form,
with s0 = n_KS/v, rho = W(s0) + (eps_KS - n_KS m)/v - [W(s0) - W(sigma7) - W'(sigma7)(s0 - sigma7)]
exactly, i.e. rho = W(s0) + (3/10) n_KS kF^2/(m v) + (a second-order Taylor remainder in
s0 - sigma7 = O(n kF^2/m^2)).  THE SIGN RULE: m sigma_KS >= 0 (previous cell, and Section 29), so on
every self-consistent solution sign(sigma7) = sign(m) = sign(W'(sigma7)).  For Section 24's mass term
V = -(2M/H) s, i.e. W = -2 M sigma, the gap is m = -2 M, sigma7 has the sign of -M, and
rho -> W(s0 sign(m)) = 2 |M| n_KS/v > 0: the branch M s > 0 of Section 24, with negative energy, is
not a self-consistent state.

(* ::Input:: *)
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

(* ::Text:: *)
fable4d: THE STABILIZED MODEL.  The unstabilized system (fable8d) is a no-go for observers: dust
and vacuum energy have F > 0 (previous cells), so they drive the hidden sheet and the 4-dimensional
Newton constant G_4 = G_8/V_hid changes by orders of magnitude (the Rust solver of fable-cosmology
integrates it and reports how much; this notebook does not).  fable4d adds to the hidden pressures
of B and C a zero-energy stabilizing stress

    P_stab  =  -F_total/2        (rho_stab = 0, added to P_hid and to P_C),

where F_total is the driver of all the matter present.  Then F_total + 2 P_stab = 0, so H_B = H_C = 0
is preserved exactly, and the observer's equations are EXACTLY the Friedmann equations

    3 H_A^2  =  kappa rho,        H_A'  =  -(kappa/2) (rho + P_obs),

with the hidden equations satisfied identically.  The price, stated plainly: P_stab is a
LAGRANGE MULTIPLIER that enforces the frozen hidden sheet, not a stress derived from any field of
this notebook, and it VIOLATES THE NULL ENERGY CONDITION along x0 whenever dust is present: for a
null vector in the (x0, x4) plane its contribution is rho_stab + P_stab = -F_total/2, which is
-rho_dust/2 < 0 for dust alone.  fable4d is ALGEBRAIC in a: kF = kF0/a, the gap is local,
H_A(a)^2 = Sum_i Omega_i(a), and only the age t(a) is a quadrature.

(* ::Input:: *)
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


(* ::Text:: *)
THE COUPLED EQUATIONS SOLVED, FROM THE RADIATION ERA TO TODAY (fable4d).  UNITS: hbar = c = k_B = 1;
time in 1/H0 with H0 = 100 h km/s/Mpc, h = 0.674; densities in units of rho_c0 = 3 H0^2 M_pl^2
(M_pl the reduced Planck mass, from Newton's G); masses and momenta in E_c = rho_c0^(1/4); sigma and
n in E_c^3.  Every constant is computed below from CODATA 2018 values and printed: E_c = 2.46261e-3 eV,
Omega_r0 = 9.2096e-5 (photons at T0 = 2.7255 K plus N_eff = 3.046 massless neutrinos), and
Omega_b0 = omega_b/h^2 = 0.02237/h^2 = 0.04924 -- the conventions of the Rust solver
fable-cosmology/rust/fable_fermion, so that its CSVs can be compared directly.  In these units the
Friedmann equation of fable4d is H_A^2 = Omega_r0 a^-4 + Omega_b0 a^-3 + rho_f(a) and the fable
number is conserved, kF = kF0/a.  TWO CASES, both flat, on N = ln a from ln(1e-10) to 0:

  mass30eV  W = V0 + m0 sigma, m0 = 30 eV (the author's mass term) plus a bare Lambda V0: kF0 from
            eps_KS(kF0, m0) = 0.265 and V0 = 1 - 0.265 - Omega_b0 - Omega_r0; rho_f includes V0; the gap
            is m = m0 exactly.  (Rust: fable4d --potential lambda-mass --param m0_ev=30.)
  power     W = m0 sigma + lam sigma^nu, nu = 1/2, a MASS-VARYING fermion with no bare Lambda: fixed
            today by m_eff(1) = m_today = 100 eV, eps_KS(kF0, m_today) = 0.55 and flatness, so that the
            condensate U = W - sigma W' = (1 - nu) lam sigma^nu carries 1 - 0.55 - Omega_b0 - Omega_r0; then
            lam = U_today/((1 - nu) sigma_t^nu) and m0 = m_today - nu lam sigma_t^(nu - 1) = 27.15 eV > 0.
            (Rust: fable4d --potential power --param m_today_ev=100 --param nu=0.5 --param omega_dm=0.55.)

WHAT THIS CELL COMPUTES, AND HOW IT DIFFERS FROM THE REFERENCE SCRIPT.  The reference CSVs
fable-cosmology/reference/mathematica_fable4d_mass30eV.csv and mathematica_fable4d_power.csv are
written by fable-cosmology/reference/make_reference_fermion.wls (701 rows; exact algebra at 40
digits with a per-row Brent solve of the gap; the age by NDSolve with the series form of the
Fermi-sea integrals and, for power, the gap solved inside the right-hand side).  This cell
recomputes every tenth row independently: the algebraic columns from Section 29's closed forms with
exact inputs (FindRoot for the gap); the age of mass30eV by NIntegrate of dN/H between the rows; the
age of power by NDSolve of the pair (m(N), ln t(N)), with m(N) carried by the DIFFERENTIATED gap
equation dm/dN = -W''(sigma) (d sigma/d kF) kF / (1 - W''(sigma) d sigma/dm) instead of being solved for,
and checked against the per-row solve.  If the reference CSVs exist, all ten columns are compared at
those rows to 1e-10; if the Rust solver's CSVs fable-cosmology/results/nb06_fable4d_mass30eV.csv and
nb06_fable4d_power.csv exist (written by a fable-cosmology notebook), their columns N, a, t, H_A,
rho_f, P_obs_f, w_f, m_eff, sigma, kF_over_m are interpolated onto these rows (cubic in N: the positive
columns in Log, P_obs_f through P_obs_f/rho_f) and compared to 1e-6.
Absent files are reported with a NOTE, not as failures.  Physics checked on the runs: the fable is
ultra-relativistic at the start (w_f -> 1/3), becomes non-relativistic at a_nr = kF0/m0 (the design's
4.16e-4 (m/eV)^(-4/3)), never has w_f < -1, and the stabilizer P_stab = -F_total/2 is NEGATIVE at every
row -- the null-energy violation along x0 is present along the whole history, not only today.

(* ::Input:: *)
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

(* ::Text:: *)
WHAT WAS PROVED IN PART VIII, AND WHAT WAS COMPUTED.  Proved symbolically, a4 arbitrary: the
Einstein tensor of the canonical metric (all 64 components, the x0 + a4 split, the Ricci scalar,
the Bianchi identity) and the three theorems it implies -- negative total energy, the anisotropy law
a4'' = -kappa (P_obs - P_hid)/(2 H^2) with P_obs = P_hid for every c-number fable configuration of
(x0, x4), and zero x0-momentum; the ghost-scalar reading of the asymptotic canonical frame; the
generalized warped frame, the (0,4) constraint that singles out (not derives) the volume-preserving
pairing, the asymptotic region and its validity inequality, the 8D Bianchi-I equations and their
sign independence; the spin connection of the interacting system (every component, gamma^mu Gamma_mu,
the Weitzenboeck form, the rescaling, the anticommutator, the J table); and the coupled system with
the Kohn-Sham fable -- exact 8D conservation, the hidden-sheet driver, the frozen-sheet theorem and
its radiation corollary, the absence of phantom crossing, the classical limit and the sign rule, and
the stabilized fable4d with its null-energy price.  Computed: the two fable4d histories above,
checked against the reference CSVs and, when present, the Rust solver.  The last cell checks that a4
is still undefined and repeats the notebook's tally.

(* ::Input:: *)
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
