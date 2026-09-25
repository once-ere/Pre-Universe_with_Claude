(* ::CELLMANIFEST-PART:: 7 *)

(* ::Title:: *)
PART VII  --  fermion fable: the complex 16-spinor, its canonical quantization in 4+4 dimensions, its field equations in the primordial gravitational field, and its energy-momentum tensor operator

(* ::Text:: *)
WHAT THIS PART IS FOR, IN ONE PARAGRAPH.  Part VI treated fable as a CLASSICAL field: sixteen real,
commuting component functions Psi(x) with the Lagrangian (1/H) Psi^T sigma16 gamma^mu D_mu Psi - V(s).
A spinor field of the real world is a fermion field: its components anticommute, and it is
quantized with anticommutators.  This Part makes fable a fermion.  Section 26 shows why the real
16-spinor cannot simply be declared Grassmann -- with the author's spinor metric sigma16 its mass
term and its kinetic term would both disappear -- and that the minimal field which uses the
author's sigma16 conjugation, propagates, admits a self-interaction V(Psibar Psi) and reduces to
Part VI as its real commuting shadow is a COMPLEX 16-spinor Psi with Dirac conjugate
Psibar = Psi^ddag sigma16.  Section 27 writes the Hermitian Lagrangian, derives both field
equations by explicit variation, and writes them out, component by component, in the primordial
gravitational field -- the canonical frame, with the function a4 never given a value -- in 16x16
form, in split-octonion 8+8 form, and in the rescaled form in which the spin connection disappears.
Section 28 quantizes the field canonically with x4 as time: the Dirac-bracket anticommutator is
derived, it turns out to be INDEFINITE (signature (8,8)), and the Krein-space fundamental symmetry
J that turns it into a positive Fock space is constructed; J acts only on a hidden "flavour" index,
it is unique, and it exists exactly when the field carries no momentum along the three hidden
timelike directions x5, x6, x7.  Section 29 builds the energy-momentum tensor OPERATOR, proves it
symmetric, Hermitian and conserved, and evaluates the energy density, the pressures and the
equation of state w in the vacuum, in a one-particle state and in the homogeneous Fermi sea, in
closed form.  The canonical spin connection is discussed wherever it enters.

CONVENTIONS, RESTATED.  Flat Dirac matrices T16[a], a = 0..7, real, {T16[a], T16[b]} = 2 eta_ab
(Section 5); T16[8] = T16[0]...T16[7] = diag(-ID8, +ID8) is the chirality; sigma16 =
T16[0].T16[1].T16[2].T16[3] is the spinor metric.  X = {x0, ..., x7}: the Wolfram index is the
coordinate index plus one, so x4 (the observer's time) is entry 5.  The canonical frame is
diag(Tan[6 H x0], q, q, q, 1, p, p, p) with q = Exp[-a4[H x4]]/Sin[6 H x0]^(1/6),
p = Exp[+a4[H x4]]/Sin[6 H x0]^(1/6), Sqrt[det g] = Sec[6 H x0] (Sections 15 and 21).  H, K, M
are Protected.  THE FUNCTION a4 IS NEVER GIVEN A VALUE: every statement below holds for an
arbitrary a4, and the last assertion of the Part checks that a4 is still undefined.

TWO CONJUGATIONS, AND TWO SYMBOLS FOR THEM.  Psi^ddag is the CLASSICAL conjugate of the field --
the conjugation of the Grassmann algebra, the one that appears in the Lagrangian -- and
Psibar = Psi^ddag sigma16.  After quantization (Section 28) the Hilbert-space adjoint is a
DIFFERENT operation, Psi^dagger = Psi^ddag J.  The two are never written with the same symbol.

TWO KINDS OF ALGEBRA, AND WHEN EACH IS USED.  Statements whose content IS the anticommutation of
the field -- that a mass term or a kinetic term vanishes, is Hermitian, or is a total derivative --
are proved in a genuine Grassmann (exterior) algebra implemented in Section 26 and tested there on
known identities before it is used.  Statements about BILINEAR expressions -- Lagrangians,
Euler-Lagrange equations, currents, energy-momentum tensors, conservation laws -- are proved with
Psi and Psibar represented by two INDEPENDENT vectors of ordinary functions of the coordinates,
with Psibar always written to the LEFT of Psi.  That commuting proxy is exact for such
identities: in every term Psibar is the leftmost and Psi the rightmost odd factor, so the left
derivative with respect to Psibar and the right derivative with respect to Psi are the ordinary
derivatives, and no reordering of odd factors ever occurs.  Where reality matters (Hermiticity
under ddag), Psi = u + i v with real u, v and Psibar = (u - i v)^T sigma16.

(* ::Section:: *)
26.  The refinement: why fermion fable is a complex 16-spinor

(* ::Text:: *)
THE CLIFFORD SYMMETRY TABLE.  Everything in this section follows from one table.  A spinor
bilinear psi^T C Gamma psi is built from a "charge conjugation" matrix C and one of the 256
ordered products Gamma of the Dirac matrices (Section 6's basis base16, grouped by rank r, the
number of factors).  There are two candidates for C:

    C-  =  sigma16                 with  C- T16[a] C-^-1  =  -T16[a]^T      (the author's spinor metric)
    C+  =  sigma16 . T16[8]        with  C+ T16[a] C+^-1  =  +T16[a]^T .

Every product C Gamma is either symmetric (S) or antisymmetric (A), and the answer depends only on
the rank:

    rank r        0  1  2  3  4  5  6  7  8
    C-  Gamma     S  A  A  S  S  A  A  S  S
    C+  Gamma     S  S  A  A  S  S  A  A  S

(136 symmetric and 120 antisymmetric products for each C, as it must be for 16x16 matrices).  Why
this decides everything: for COMMUTING components psi^T N psi sees only the symmetric part of N,
for ANTICOMMUTING (Grassmann) components only the antisymmetric part.  The "four candidate" mass
matrices sigma16, C+, sigma16 T16[8], C+ T16[8] are only two, because T16[8]^2 = ID16:
sigma16 T16[8] = C+ and C+ T16[8] = sigma16.

(* ::Input:: *)
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

(* ::Text:: *)
THE LORENTZ-INVARIANT BILINEARS.  A bilinear psi^T N psi (real field) or Psi^ddag N Psi (complex
field) is a Spin(4,4) scalar exactly when S^T N + N S = 0 for all 28 generators S = SAB of
Section 5 (the generators are real, so the condition is the same in both cases).  Solving these
7168 linear equations for the 256 entries of N gives a TWO-dimensional space, spanned by C- and
C+ -- equivalently by the two chiral pieces PL sigma16 PL and PR sigma16 PR, one for each
split-octonion spinor type -- and every invariant N is SYMMETRIC and chirality-DIAGONAL (it
commutes with T16[8]).  That is the complete list of candidates for a mass term; nothing is left
out.

(* ::Input:: *)
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

(* ::Text:: *)
A GRASSMANN ALGEBRA, BUILT AND TESTED.  To prove statements about anticommuting fields the
notebook needs an honest exterior algebra, not a sign convention applied by hand.  The one used
here is small and explicit.  An element is an Association from MONOMIALS to coefficients; a
monomial is the sorted list of the generator indices it contains, {} being the unit.  The product
of two monomials is zero if they share a generator, and otherwise it is the sorted union with the
sign of the permutation that sorts the concatenation (Signature).  On top of that:

    grAdd, grScale, grMul          sums, scalar multiples and products;
    grSame[x, y]                   equality of two elements (x - y has no monomial left);
    grBil[xs, N, ys]               the bilinear  Sum_ab xs_a N_ab ys_b  of two lists of elements;
    grD[x, dmap]                   the EVEN derivation that maps generator i to generator dmap[i]:
                                   with dmap: theta_a -> phi_a it is d/dt with phi_a = d theta_a/dt;
    grDL[x, i]                     the LEFT derivative with respect to generator i;
    grConj[x]                      the classical conjugation ddag: (x y)^ddag = y^ddag x^ddag,
                                   generators self-conjugate (real), coefficients complex-conjugated.

Before any physics, the algebra is tested on facts that are known independently: generators
anticommute and square to zero; the product is associative and graded-commutative; the
conjugation is an involutive anti-automorphism; grD obeys the Leibniz rule and grDL the graded
Leibniz rule.  Then the two lemmas that drive this section are proved for a completely general
(symbolic) 16x16 matrix N:

    theta^T N theta  ==  theta^T N_A theta          (N_A, N_S: antisymmetric, symmetric part of N)
    theta^T N phi - (1/2) d( theta^T N theta )  ==  theta^T N_S phi ,

and the Euler-Lagrange expression of L = theta^T N phi (left derivatives, phi = d theta/dt) is
exactly (N + N^T) phi = 2 N_S phi.  So a first-order Grassmann kinetic term is a TOTAL DERIVATIVE,
with empty field equations, precisely when its matrix is antisymmetric.  For COMMUTING variables
the roles are exactly reversed (control): theta^T N theta sees only N_S, and the Euler-Lagrange
expression of theta^T N phi is 2 N_A phi.

(* ::Input:: *)
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

(* ::Text:: *)
THE THREE REAL OPTIONS, AND WHY EACH FAILS.  With the table and the lemmas the verdicts are
immediate, and each is proved in the Grassmann algebra.

(a) A REAL Grassmann 16-spinor with the author's sigma16.  Its only invariant mass terms vanish,
    theta^T sigma16 theta == theta^T C+ theta == 0 (both are symmetric), and in every direction its
    flat kinetic term theta^T sigma16 T16[a] d theta is a TOTAL DERIVATIVE,
    (1/2) d(theta^T sigma16 T16[a] theta) (sigma16 T16[a] is antisymmetric), with an identically
    empty Euler-Lagrange expression; the total derivative itself is not zero.  On a curved frame
    the covariant kinetic term is Sqrt[g] theta^T sigma16 gamma^mu D_mu theta = (total derivative)
    + (1/2) Sqrt[g] theta^T sigma16 {gamma^mu, Gamma_mu} theta, because
    d_mu(Sqrt[g] sigma16 gamma^mu) = Sqrt[g] sigma16 [gamma^mu, Gamma_mu]; and the second term
    vanishes on EVERY frame, because {T16[a], S^bc} is a rank-3 product (or zero) and sigma16 times
    a rank-3 product is symmetric.  NO DYNAMICS, on any frame.
(b) A MAJORANA 16-spinor built with C+.  Now C+ T16[a] is symmetric, so the kinetic term is
    genuine: its Euler-Lagrange expression is 2 C+ T16[a] phi, and C+ T16[a] is invertible.  But
    both invariant forms are symmetric, so there is NO Lorentz-scalar bilinear at all: it is
    massless, and no V(s) with s a bilinear exists.  Its quartic Lorentz scalars are not zero, and
    they are all ONE scalar: with the vector v_a = theta^T sigma16 T16[a] theta, the 2-form
    B_ab = theta^T C+ T16[a] T16[b] theta and the 3-form C_abc = theta^T C+ T16[a] T16[b] T16[c] theta,
    the three contractions v.v, B.B and C.C are proportional to each other.  Its commuting
    shadow has no kinetic term (C+ T16[a] symmetric: a total derivative for commuting components).
(c) A MAJORANA-WEYL or WEYL 8-spinor (one chirality, PL or PR).  Both invariant forms are
    chirality-DIAGONAL and every T16[a] is chirality-OFF-diagonal, so PL C T16[a] PL ==
    PR C T16[a] PR == 0: no kinetic term at all.  It cannot propagate.
(d) Part VI's real COMMUTING fable escapes (a) because for commuting components the symmetric
    sigma16 gives a non-zero mass term and the antisymmetric sigma16 T16[a] gives a genuine kinetic
    term (the control of the previous cell).  That is why Part VI's classical theory is consistent
    -- and why it cannot be quantized as a fermion: a commuting spinor violates the spin-statistics
    connection.

The conclusion, with its scope stated: the complex 16-spinor of the next cell is the MINIMAL field
that uses the author's sigma16 conjugation, propagates, admits V(s) with s = Psibar Psi, and
reduces to Part VI as its real commuting shadow.  It is not the unique field with dynamics: the
C+ Majorana spinor propagates too, but it is massless, has no bilinear V(s), and has no commuting
shadow.

(* ::Input:: *)
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

(* ::Text:: *)
THE COMPLEX 16-SPINOR.  Take two real Grassmann 16-spinors theta1, theta2 (32 real generators) and
Psi = (theta1 + i theta2)/Sqrt[2], so Psi^ddag = (theta1 - i theta2)^T/Sqrt[2] and the Dirac
conjugate is Psibar = Psi^ddag sigma16.  Now everything the real options lacked is present:

    Psibar Psi  ==  i theta1^T sigma16 theta2     -- non-zero (16 monomials) and Hermitian (real
        under ddag); the second invariant p = Psibar T16[8] Psi = Psi^ddag C+ Psi is non-zero and
        Hermitian as well: the complex 16-spinor has TWO scalar bilinears;
    s = Psibar Psi is a sum of 16 COMMUTING NILPOTENT even elements x_a (x_a^2 = 0), so every
        polynomial V(s) is a finite polynomial: s^17 == 0;
    Psi^ddag K phi = Theta^T A Phi (Theta = (theta1, theta2), Phi = d Theta, K = sigma16 T16[a])
        with symmetric part A_S = (i/2) [[0, K], [-K, 0]] =: (i/2) Omega  -- NOT zero, so the
        kinetic term is genuine; Omega is real symmetric and invertible (it is the symplectic
        matrix of Section 28);
    the symmetrized kinetic term (1/2)(Psi^ddag K phi - phi^ddag K Psi) is HERMITIAN, and it
        differs from Psi^ddag K phi by the total derivative -(1/2) d(Psi^ddag K Psi); the
        unsymmetrized one is not Hermitian.

Invariance of s and p under Spin(4,4) is the statement S^T N + N S = 0 of the invariant-form cell
(the Lorentz generators are real).  This is the field the rest of the Part uses; the
self-interaction is taken to depend on s only (Section 28 shows why p cannot enter).

(* ::Input:: *)
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

(* ::Text:: *)
FOUR FOUR-DIMENSIONAL DIRAC FERMIONS.  The observer's Clifford algebra is generated by T16[1],
T16[2], T16[3] (the observed space) and T16[4] (the observer's time).  Its 16 ordered products are
linearly independent, so over the complex numbers it is the full matrix algebra M4(C) -- the
algebra of 4x4 Dirac matrices.  Its COMMUTANT in M16(C), computed by solving X T16[i] == T16[i] X
(i = 1..4), is again 16-dimensional; it is generated by the four "hidden" (flavour) gammas

    h_A  =  Omega4 . T16[A],     A = 0, 5, 6, 7,       Omega4 = T16[1].T16[2].T16[3].T16[4],  Omega4^2 = -1,

which commute with T16[1..4] and obey {h_A, h_B} = -2 eta_AB: a second Clifford algebra, of the
hidden directions.  The two algebras intersect only in the multiples of the identity.  By the
double-commutant theorem C^16 = C^4 (observer's Dirac index) (x) C^4 (hidden flavour index):
under the observer's Lorentz group Spin(3,1), generated by T16[i] T16[j] with i, j in
{1, 2, 3, 4}, fermion fable is FOUR 4-dimensional Dirac fermions.  Per momentum that is 4 x 2 = 8
particle states (and 8 antiparticle states) -- the degeneracy g = 8 of Sections 28 and 29.

(* ::Input:: *)
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

(* ::Text:: *)
THE REFINED LAGRANGIAN, AND THE FIDELITY CHAIN.  The Lagrangian of fermion fable is the
SYMMETRIZED covariant one (Section 27 shows why no other form is admissible for a complex field):

    L  =  Sqrt[det g] Lhat,      Lhat  =  (1/(2H)) [ Psibar gamma^mu D_mu Psi - (D_mu Psibar) gamma^mu Psi ]  -  V(s),      s = Psibar Psi,
    D_mu Psi = d_mu Psi + Gamma^spin_mu Psi,       D_mu Psibar = d_mu Psibar - Psibar Gamma^spin_mu ,

and its energy-momentum tensor (derived in Section 29) is

    That_{mu nu}  =  -(1/(4H)) [ Psibar gamma_mu D_nu Psi - (D_nu Psibar) gamma_mu Psi + (mu <-> nu) ]  +  g_{mu nu} Lhat .

Four helpers implement them for an arbitrary frame (curved gammas and spin connection passed in):
cfLhatFermion, cfEquationFermion (gamma^mu D_mu Psi - H V'(s) Psi), cfAdjointEquationFermion
((D_mu Psibar) gamma^mu + H V'(s) Psibar) and cfTFermion.  Before any of them is used for something
new, they are anchored to what the notebook already knows.  Set Psi -> a real commuting spinor psi
and Psibar -> psi^T sigma16 (the "bosonic shadow") and:

    [1] Lhat becomes Part VI's cfLhatFable EXACTLY, on the canonical frame with generic V;
    [2] on the flat frame with V = -(2M/H) s and no volume factor it becomes the author's La[] of
        Section 11 -- the chain Part VI established, closed here directly;
    [3] the Euler-Lagrange expressions of the complex field, combined as sigma16 . EL_Psibar + EL_Psi
        (the chain rule for Psibar = psi^T sigma16), become Part VI's explicit variation cfELFable,
        and on the flat frame the author's sixteen equations eLa of Section 12;
    [4] That becomes Part VI's covariant tensor cfTCov exactly.

Every new result of this Part therefore contains Part VI -- and through it Sections 11 and 12 --
as its real commuting limit.

(* ::Input:: *)
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

(* ::Section:: *)
27.  The Lagrangian, the field equations in the primordial gravitational field, and the canonical spin connection

(* ::Text:: *)
THE LAGRANGIAN, AND WHY IT MUST BE THE SYMMETRIZED COVARIANT ONE.  From here on Psi and Psibar are
two independent 16-component fields of ALL EIGHT coordinates (the commuting proxy of the
introduction).  Four candidate Lagrangians differ by where the derivative acts and whether it is
covariant:

    Lsym    =  (1/(2H)) [ Psibar gamma^mu D_mu Psi - (D_mu Psibar) gamma^mu Psi ] - V(s)     (the Lagrangian of this Part)
    Lsym_d  =  the same with d_mu in place of D_mu
    Lun     =  (1/H) Psibar gamma^mu D_mu Psi - V(s)
    Lun_d   =  (1/H) Psibar gamma^mu d_mu Psi - V(s)

and the facts, each asserted below on the canonical frame for generic Psi(x0..x7), Psibar(x0..x7):

 (a) the connection is real and sigma16 Gamma^spin_mu is antisymmetric, i.e.
     Gamma_mu^T sigma16 = -sigma16 Gamma_mu, so D_mu Psibar = d_mu Psibar - Psibar Gamma_mu is exactly
     the Dirac conjugate of D_mu Psi;
 (b) Lsym is HERMITIAN: with Psi = u + i v and Psibar = (u - i v)^T sigma16 it is real.  No factor i
     is needed because sigma16 gamma^mu is real and antisymmetric; Lun is NOT Hermitian (witness);
 (c) Lsym contains the connection ONLY through (1/(2H)) Psibar {gamma^mu, Gamma_mu} Psi, and on the
     canonical frame {gamma^mu, Gamma_mu} == 0 for EACH mu separately (every Gamma_mu is a
     combination of T16[mu] T16[0] and T16[mu] T16[4], with no totally antisymmetric part), so
     Lsym == Lsym_d there: the connection drops out of the symmetrized Lagrangian (on every frame
     on which the MATRIX {gamma^mu, Gamma_mu} vanishes -- diagonal frames -- and NOT in general);
 (d) Lun - Lsym == (1/(2H)) nabla_mu( Psibar gamma^mu Psi ), a total divergence;
 (e) but Lun - Lun_d == (1/H) Psibar gamma^mu Gamma_mu Psi == -3 Cot[6 H x0]^2 Psibar T16[0] Psi, which is
     NOT zero for a complex field (witness) -- it vanishes only in the real commuting limit, which
     is the scope of the statement "Lhat with D == Lhat with d" of Parts V and VI;
 (f) therefore Lun_d is INADMISSIBLE: varying Psibar gives gamma^mu d_mu Psi == H V' Psi with the
     connection term missing, varying Psi gives an adjoint equation that contains it,
     (d_mu Psibar) gamma^mu + Psibar [gamma^mu, Gamma_mu] == -H V' Psibar, and the two are NOT Dirac
     conjugates of each other: they differ by Psibar [gamma^mu, Gamma_mu] = -6 H Cot[6 H x0]^2 Psibar T16[0]
     (witness).  Only a Lagrangian whose two variations are conjugate defines a consistent theory.

(* ::Input:: *)
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

(* ::Text:: *)
THE FIELD EQUATIONS, DERIVED.  Vary Psibar and Psi independently in L = Sqrt[g] Lsym (the left
derivative with respect to Psibar and the right derivative with respect to Psi are the ordinary
derivatives of the commuting proxy).  For generic fields of all eight coordinates:

    EL_Psibar  ==  (Sqrt[g]/H) ( gamma^mu D_mu Psi - H V'(s) Psi ),
    EL_Psi     ==  -(Sqrt[g]/H) ( (D_mu Psibar) gamma^mu + H V'(s) Psibar ),

so the field equation and the adjoint field equation of fermion fable are

    gamma^mu D_mu Psi  ==  H V'(s) Psi ,            (D_mu Psibar) gamma^mu  ==  -H V'(s) Psibar .

The SIGN of the adjoint equation is derived, not assumed, and it is exactly the one required by
consistency: with Psi = u + i v and Psibar = (u - i v)^T sigma16 the adjoint equation is the Dirac
conjugate of the field equation, (adjoint residual) == -(field residual)^* ^T sigma16, because
T16[a]^T sigma16 = -sigma16 T16[a].  The wrong sign, (D Psibar) gamma = +H V' Psibar, fails that
test (control).  The derivation uses only the covariant constancy of gamma^mu in the form
(1/Sqrt[g]) d_mu(Sqrt[g] gamma^mu) == [gamma^mu, Gamma_mu] (Section 17); the anticommutator is
not needed for the symmetrized Lagrangian.

OPERATOR ORDERING (definitions, not identities).  The Hamiltonian contains V(:s:), defined by the
spectral calculus of the Hermitian operator s(x) = Psi^dagger beta Psi of Section 28 (regularized and
normal-ordered); no ordering prescription is needed there, and non-polynomial V is covered.  The
operator field equation is gamma^mu D_mu Psi = H :V'(s) Psi:, where V'(s) Psi is the Weyl-symmetrized
product, i.e. the average over the positions at which Psi can be inserted in V'(s).  It is exact for
linear V (the author's mass term).  For nonlinear V it differs from the naive product by Hartree
and Fock contractions with the coincident J-vacuum propagator, a c-number MATRIX with a scalar part
(divergent; it renormalizes V') and a gamma^4 part (the charge density of the sea; a constant
chemical-potential shift, removed by charge-symmetric ordering or by a phase Psi -> e^{i mu x4} Psi,
NOT by renormalizing V).  In the Kohn-Sham mean field of Section 29 V'(s) is replaced by V'(<s>)
and the equation is linear.

(* ::Input:: *)
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

(* ::Text:: *)
THE U(1) CURRENT AND THE PARTICLE NUMBER.  Lsym is invariant under Psi -> e^{i alpha} Psi,
Psibar -> e^{-i alpha} Psibar.  The Noether current is

    J^mu  =  dL/d(d_mu Psi) (i Psi) + (-i Psibar) dL/d(d_mu Psibar)  ==  (Sqrt[g]/H) i Psibar gamma^mu Psi ,

so j^mu = i Psibar gamma^mu Psi is the U(1) current; it is real (i sigma16 gamma^mu is Hermitian).
Off shell the identity

    (1/Sqrt[g]) d_mu( Sqrt[g] j^mu )  ==  i ( Ebar Psi + Psibar E ) ,     E, Ebar = the two field-equation residuals,

holds for generic fields of all eight coordinates, so the current is conserved on shell.  The
PARTICLE-NUMBER current is n^mu := -(i/H) Psibar gamma^mu Psi = -j^mu/H: Section 28 shows that
N = Int Sqrt[g] n^4 d^7x is the normal-ordered number of particles minus antiparticles (so the
charge of j carries a conventional minus sign: Int Sqrt[g] j^4 d^7x = -H N).

(* ::Input:: *)
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

(* ::Text:: *)
THE CANONICAL SPIN CONNECTION: A COMPLETE ACCOUNT, AND WHAT IT DOES TO FERMION FABLE.  Restated
from Parts III-V so that this Part can be read alone.

WHAT IT IS.  The canonical spin connection omega_mu^{ab} is the unique solution of the vielbein
postulate d_mu e_nu^a - Gamma^rho_{mu nu} e_rho^a + omega_mu^a_b e_nu^b = 0 with the Levi-Civita
Christoffel symbols of the canonical metric (Section 16, solver cfSpinConnection; confirmed by an
independent frame-only formula).  It is metric compatible (omega antisymmetric in a, b) and
torsion-free.  Its non-zero components are listed in the grid below: every one has the form
omega_mu^{mu 0} or omega_mu^{mu 4} (up to antisymmetry), because the frame is diagonal and depends
only on x0 and x4; omega_0 and omega_4 vanish.  The spinor connection is
Gamma^spin_mu = (1/2) omega_mu^{ab} S_ab = Sum_{a<b} omega_mu,ab (1/2) T16[a] T16[b]; it is real, and
sigma16 Gamma_mu is antisymmetric.

ITS OTHER FACES (Parts IV and V).  Bridges 1 and 2 are the SAME connection in a local and in a
constant gauge (Sections 18, 19: omega' = M omega M^-1 - dM M^-1, with dM = 0 for Bridge 2).
Bridge 3 is a DIFFERENT connection, with totally antisymmetric octonionic torsion (Section 20).
The fable-5.1 (Weitzenboeck) bridge (Section 21) has omega = 0 in the canonical frame; the
canonical connection is then exactly minus the contortion of the Weitzenboeck torsion, the
torsion vector is the gradient T_mu = d_mu Log[Sin[6 H x0]], and R = -T + B.

WHAT IT DOES TO FERMION FABLE.
 (i)   In the symmetrized Lagrangian it enters only through Psibar {gamma^mu, Gamma_mu} Psi, which
       vanishes on the canonical frame direction by direction (previous cells).  In the
       unsymmetrized Lagrangian it does NOT drop out for a complex field.
 (ii)  In the field equation it enters as gamma^mu Gamma_mu, and direction by direction
       gamma^mu Gamma_mu (no sum) is a combination alpha_mu T16[0] + beta_mu T16[4] of the two
       "radial" gammas only.  Summed, the T16[4] parts cancel -- the three observed directions
       give -(3/2)(H a4') ... and the three hidden ones the opposite, because q p does not depend
       on x4 -- and what is left is gamma^mu Gamma_mu = -3 H Cot[6 H x0]^2 T16[0] = -(1/2) T_mu gamma^mu,
       which the rescaling Psi = Sqrt[Sin[6 H x0]] Psi' removes exactly (below).
 (iii) It does NOT drop out of the energy-momentum tensor: off the diagonal the covariant and the
       partial-derivative tensors differ (Section 29).
 (iv)  In the symmetrized form it enters NEITHER the canonical anticommutator (Gamma_4 = 0, and the
       anticommutator comes from the time-derivative term alone) NOR the Hamiltonian density,
       Sqrt[g] [ -(1/(2H)) Sum_{k != 4} (Psibar gamma^k d_k Psi - d_k Psibar gamma^k Psi) + V ].  It
       appears in the equation of motion, through gamma^mu Gamma_mu = (1/2)(1/Sqrt[g]) d_mu(Sqrt[g] gamma^mu),
       and there it is exactly the term that makes the one-particle operator Hermitian (Section 28).
       (This corrects the design's "it enters the Hamiltonian".)
 (v)   Every gamma^mu Gamma_mu commutes with the Krein fundamental symmetry J of Section 28,
       while the individual Gamma_h of the hidden timelike directions h = 5, 6, 7 anticommute with
       it (they are boosts mixing x0 or x4 with the hidden sheet).

(* ::Input:: *)
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

(* ::Text:: *)
THE FIELD EQUATIONS WRITTEN OUT IN THE PRIMORDIAL GRAVITATIONAL FIELD.  On the canonical frame
(a4 free), with gamma^0 = Cot[6 H x0] T16[0], gamma^i = (1/q) T16[i] (i = 1,2,3), gamma^4 = T16[4],
gamma^h = (1/p) T16[h] (h = 5,6,7), and for fields of all eight coordinates:

 (i) 16x16 form:
       Cot[6Hx0] T16[0] d_0 Psi + (1/q) Sum_i T16[i] d_i Psi + T16[4] d_4 Psi + (1/p) Sum_h T16[h] d_h Psi
         - 3 H Cot[6Hx0]^2 T16[0] Psi  ==  H V'(s) Psi ,
       Cot[6Hx0] d_0 Psibar T16[0] + (1/q) Sum_i d_i Psibar T16[i] + d_4 Psibar T16[4] + (1/p) Sum_h d_h Psibar T16[h]
         - 3 H Cot[6Hx0]^2 Psibar T16[0]  ==  -H V'(s) Psibar ;
 (ii) split-octonion 8+8 form, Psi = (psi1, psi2) (type-1, type-2), T16[a] = [[0, taubar[a]], [tau[a], 0]],
       Gamma^spin = diag(Gamma^(1), Gamma^(2)) (Section 17).  Covariantly, on any frame,
       e_a^mu taubar[a] (d_mu + Gamma^(2)_mu) psi2 = H V'(s) psi1 ,   e_a^mu tau[a] (d_mu + Gamma^(1)_mu) psi1 = H V'(s) psi2 ,
       and with Psibar = (psibar1, psibar2), psibar1 = -psi1^ddag sigma, psibar2 = psi2^ddag sigma, the conjugates
       (d_mu psibar2 - psibar2 Gamma^(2)_mu) tau[a] e_a^mu = -H V' psibar1 ,  (d_mu psibar1 - psibar1 Gamma^(1)_mu) taubar[a] e_a^mu = -H V' psibar2 .
       On the canonical frame (tau[0] = taubar[0] = ID8):
       Cot d_0 psi2 + (1/q) Sum_i taubar[i] d_i psi2 + taubar[4] d_4 psi2 + (1/p) Sum_h taubar[h] d_h psi2 - 3 H Cot^2 psi2 == H V'(s) psi1 ,
       Cot d_0 psi1 + (1/q) Sum_i tau[i] d_i psi1 + tau[4] d_4 psi1 + (1/p) Sum_h tau[h] d_h psi1 - 3 H Cot^2 psi1 == H V'(s) psi2 ,
       s = -psi1^ddag sigma psi1 + psi2^ddag sigma psi2  (Psibar = Psi^ddag sigma16, sigma16 = diag(-sigma, sigma));
 (iii) all sixteen component equations (each T16[a] is a signed permutation matrix, so equation r
       contains exactly one derivative per coordinate, of the component that T16[a] maps to r; the
       connection term multiplies the same component as the x0-derivative; the coupling graph is
       connected: for fields of all eight coordinates the sixteen equations form ONE block);
 (iv) the rescaled form: Psi = Sqrt[Sin[6Hx0]] Psi', Psibar = Sqrt[Sin[6Hx0]] Psi'bar,
       Cot T16[0] d_0 Psi' + (1/q) Sum_i T16[i] d_i Psi' + T16[4] d_4 Psi' + (1/p) Sum_h T16[h] d_h Psi'
         ==  H V'(Sin[6Hx0] s') Psi' ,   s' = Psi'bar Psi'   -- no connection term at all,
       and the same for Psi'bar.

Two structural remarks, asserted below.  The only internal U(1) of the action is the VECTOR phase:
the commutant of all eight T16[a] in M16(C) is the multiples of the identity.  In particular the
axial phase Psi -> exp(i alpha T16[8]) Psi leaves s = Psibar Psi invariant but NOT the kinetic term
(T16[8] anticommutes with every gamma) -- the reverse of the four-dimensional intuition.  The
component equations are also exported, in TeX and plain text, by the script
export_fermion_fable_tex.wls (it evaluates this notebook and renders cfFieldEqTerms).

(* ::Input:: *)
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

(* ::Section:: *)
28.  Canonical quantization in 4+4 dimensions: the Dirac bracket, the Krein structure J, and the admissible sector

(* ::Text:: *)
TIME, SLICES, AND THE TIME-DERIVATIVE PART OF THE LAGRANGIAN.  Time is x4, the observer's proper
time: on the canonical frame g_44 = -1 (lapse 1) and g_4mu = 0 for mu != 4 (shift 0).  A slice
x4 = const is SEVEN-dimensional with signature (4,3): x0, x1, x2, x3 spacelike and x5, x6, x7
TIMELIKE.  It is therefore not a Cauchy surface, and the quantization below is carried out where
it is well posed (the admissible sector, later in this section).  From Lsym the momenta are

    Pi_Psi     =  dL/d(d_4 Psi)     =  (Sqrt[g]/(2H)) Psibar gamma^4 ,
    Pi_Psibar  =  dL/d(d_4 Psibar)  =  -(Sqrt[g]/(2H)) gamma^4 Psi ,

and the symplectic potential Pi_Psi dPsi + dPsibar Pi_Psibar differs from that of the
unsymmetrized Lagrangian, (Sqrt[g]/H) Psibar gamma^4 dPsi, by the exact variation
d[(Sqrt[g]/(2H)) Psibar gamma^4 Psi]: the two define the SAME symplectic form, hence the same
brackets.  With Psibar = Psi^ddag sigma16 the time-derivative part is

    Psi^ddag K d_4 Psi ,    K = (Sqrt[g]/H) sigma16 gamma^4 = i Gtilde,    Gtilde = (Sqrt[g]/H) G,    G = -i sigma16 gamma^4 ,

and on the canonical frame gamma^4 = T16[4], so G = -i sigma16 T16[4] = -i T16[0].T16[1].T16[2].T16[3].T16[4] =: J.
G is Hermitian, G^2 = ID16, and it has eigenvalues +1 (8 times) and -1 (8 times): the kinetic form
is INDEFINITE, signature (8,8).  The connection has Gamma_4 = 0 on the canonical frame, so the
time-derivative part -- the part that determines the anticommutator -- contains no connection.

(* ::Input:: *)
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

(* ::Text:: *)
THE DIRAC BRACKET, AND THE CANONICAL ANTICOMMUTATOR.  Write Psi = (theta1 + i theta2)/Sqrt[2] with
real Grassmann theta1, theta2 and Theta = (theta1, theta2).  In the Grassmann algebra of Section
26, for K = c sigma16 T16[4] with any scalar c,

    Psi^ddag K dPsi  ==  (i/2) Theta^T Omega_c dTheta  +  (1/4) d( theta1^T K theta1 + theta2^T K theta2 ),
    Omega_c = [[0, K], [-K, 0]]  (real, symmetric, invertible),

so up to a total time derivative the Lagrangian is the first-order system (i/2) Theta^T Omega Theta' - h.
Its momenta are proportional to Theta, the constraints pi - (momentum as a function of Theta) are
second class with constraint matrix proportional to Omega, and the Dirac bracket of the Theta's is
proportional to Omega^-1; the constant is fixed by the elementary case Omega = 1, (i/2) xi xi',
whose quantization is {xi, xi} = 1.  Hence

    {Theta_i, Theta_j}  =  (Omega^-1)_ij ,
    {Psi_a, Psi^ddag_b} = (1/2) [ (Omega^-1)_11 + (Omega^-1)_22 - i (Omega^-1)_12 + i (Omega^-1)_21 ]_ab  ==  i (K^-1)_ab  ==  (Gtilde^-1)_ab ,
    {Psi_a, Psi_b} = 0 .

The same sign and normalization are CONFIRMED independently, and without any convention for graded
Poisson brackets, in the Fock-space cell below: with this anticommutator the Heisenberg equation
generated by the canonical Hamiltonian reproduces the field equation, and with the opposite sign it
gives the time-reversed one.  On the canonical frame, J^-1 = J and Sqrt[g] = Sec[6 H x0], so

    {Psi_a(x), Psi^ddag_b(y)}_{x4 = y4}  =  (H/Sqrt[g]) J_ab delta^7(x - y)  =  H Cos[6 H x0] J_ab delta^7(x - y) ,

which is the design's (H/Sqrt[g]) (-i sigma16 gamma^4)_ab, because (-i sigma16 T16[4])^-1 = -i sigma16 T16[4].
In the admissible truncation (fields independent of x5, x6, x7, with a FINITE hidden coordinate
volume V_hid = Int dx5 dx6 dx7 -- an assumption, stated) the delta function becomes
delta^4(x0..x3 - y0..y3) and the factor H/Sqrt[g] becomes H/(V_hid Sqrt[g]).  For the rescaled
field Psi' = Psi/Sqrt[Sin[6 H x0]] the factor is H Cot[6 H x0].  On a frame whose Sqrt[g] depends on
x4 one quantizes chi = (Sqrt[g]/H)^(1/2) Psi, {chi, chi^ddag} = G delta^7; on the canonical frame
Sqrt[g] does not depend on x4 and the two coincide.  The spin connection does not appear: the
anticommutator comes from the time-derivative term alone, and Gamma_4 = 0.

(* ::Input:: *)
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

(* ::Text:: *)
WHAT J IS, AND THE HILBERT ADJOINT.  J = -i T16[0]...T16[4] = -i Omega4 T16[0] = -i h_0, with
Omega4 = T16[1].T16[2].T16[3].T16[4] of Section 26: J is one of the hidden flavour gammas, it lies in
the commutant of the observer's Clifford algebra, and on C^16 = C^4 (observer) (x) C^4 (flavour) it
acts on the FLAVOUR factor only, where it has signature (2,2) -- verified on the image of a rank-4
primitive idempotent of the observer's algebra.  With beta := -i T16[4] (Hermitian, beta^2 = 1):

    sigma16  =  J beta ,       beta T16[j] beta = -T16[j]  and  T16[j] Hermitian  (j = 0..3) :

beta is the observer's Dirac-adjoint matrix.  Define the HILBERT ADJOINT by the J-involution,
Psi^dagger := Psi^ddag J.  Then

    Psibar = Psi^ddag sigma16 = Psi^dagger beta          (the standard 4D Dirac adjoint),
    s = Psi^dagger beta Psi ,
    Psi^ddag G d_4 Psi = Psi^dagger d_4 Psi               (the time-kinetic term becomes (Sqrt[g]/H) i Psi^dagger d_4 Psi),
    {Psi_a, Psi^dagger_b} = (H/Sqrt[g]) delta_ab delta^7  (POSITIVE).

So fermion fable is 4 flavours x a 4D Dirac field, and J-quantization replaces the classical
flavour metric of signature (2,2) by the identity.  Why this is legitimate: for Grassmann fields the
*-structure is a free choice -- the Berezin integral treats Psi and Psibar as independent -- and the
J-involution is that choice.  Why it would NOT rescue a bosonic field: for a commuting 16-component
field the same involution gives [b, b^dagger] = 1, but the Hamiltonian Sum_u omega_u b_u^dagger b_u then
has 8 negative-frequency modes per momentum and no exclusion principle to fill them: it is unbounded
below; and the only local involutions compatible with a Hermitian s and a Hermitian Hamiltonian are
+J and -J (the uniqueness theorem below), -J giving every mode negative norm.  For fermions the
negative-frequency modes are filled (the Dirac sea) and the obstruction disappears.  The J-odd
bilinears (That_{mu h}, j^h, Psibar T16[8] Psi) become anti-Hermitian operators, so the classical real
theory of Part VI is the classical limit of the J-EVEN sector only.

CHIRALITY.  J anticommutes with T16[8]: J exchanges the two split-octonion types.  Each chirality
subspace is G-NULL (PL G PL = PR G PR = 0: the Krein form pairs type-1 with type-2 only), so the
J-vacuum is not chirality-graded; but the two chirality subspaces ARE orthogonal in the Hilbert
product (PL PR = 0 with PL, PR Hermitian).  Neither p = Psibar T16[8] Psi (anti-Hermitian under J) nor
i p (anti-Hermitian under the classical conjugation ddag, so it would make the Lagrangian complex)
can enter V consistently: V = V(s).

THE HERMITICITY RULE.  Under the J-adjoint, a bilinear Psi^ddag M Psi with M classically Hermitian
is (Psi^ddag M Psi)^dagger = Psi^ddag (J M J) Psi: it is HERMITIAN iff [J, M] = 0 and ANTI-Hermitian
iff {J, M} = 0.  The table below records J against every matrix that occurs: sigma16 and
sigma16 gamma^mu (mu = 0..4) commute; sigma16 gamma^h (h = 5, 6, 7) anticommute; every
gamma^mu Gamma_mu commutes; Gamma_1..Gamma_3 commute and Gamma_5..Gamma_7 ANTIcommute (boosts
mixing x0 or x4 with the hidden timelike sheet); the chirality T16[8] and hence p = Psibar T16[8] Psi
anticommute.  Consequences: s is Hermitian, p is ANTI-Hermitian (so V may depend on s but not on
p); the hidden current components j^h and the energy-momentum components That_{mu h} (mu = 0..4)
are built from anticommuting matrices and are anti-Hermitian: their expectation values are purely
imaginary in every state and vanish in every state invariant under the hidden rotations (the
J-vacuum and the Kohn-Sham states of Section 29), consistent with G_{mu h} = 0 on the canonical
frame.  That_{h h'} (h != h') is not anti-Hermitian: for fields independent of x5, x6, x7 it vanishes
identically, and That_{hh} = g_hh Lhat is Hermitian (Section 29).  The price, counted: of the 28 Lorentz
generators S_ab, 13 commute with J -- Spin(4,1) of x0..x4 (10) and Spin(3) of x5..x7 (3) -- and
15 anticommute: the 12 boosts between x0..x3 and x5..x7 and the 3 ROTATIONS between x4 and
x5..x7 (x4..x7 are all timelike).  The Krein form G itself is invariant (S^T G + G S = 0) under
exactly the 21 generators with a, b != 4: Spin(4,3), the group of the slice.

(* ::Input:: *)
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

(* ::Text:: *)
THE ADMISSIBLE SECTOR: A THEOREM.  Take a plane wave at momentum k (flat local analysis, the
frame factors frozen): the one-particle Hamiltonian is h_k = sigma16 (m - i gamma.k), with
gamma.k = Sum_{a != 4} k_a T16[a], and the evolution generator is E_k = G^-1 h_k = G h_k, i d_4 Psi = E_k Psi.
Write k_s^2 = k0^2 + ... + k3^2 and k_h^2 = k5^2 + k6^2 + k7^2.

 (1) For EVERY k, E_k^2 = (k_s^2 - k_h^2 + m^2) ID16: the dispersion relation is
     omega^2 = k_s^2 - k_h^2 + m^2.
 (2) Admissible k (k_h = 0): [J, E_k] = 0 and J itself gives the positive quantization (G J = ID16).
 (3) Hidden momentum BELOW threshold (k_h^2 < k_s^2 + m^2): a momentum-dependent, boosted
     J' = S^-1 J S -- S the spin boost in the plane of k_s and k_h that removes k_h -- commutes with
     E_k and with beta, J'^2 = 1, and G J' = S^2 is positive definite: each such momentum can be
     quantized positively on its own.
 (4) AT threshold E_k is not zero but E_k^2 = 0: E_k is nilpotent and cannot be diagonalized (Jordan
     blocks); there is no mode expansion.
 (5) ABOVE threshold omega^2 < 0: the frequencies are imaginary (growth along x4, the ill-posed
     ultrahyperbolic Cauchy problem) and the modes are G-NEUTRAL (u^dagger G u = 0), so they carry
     no norm at all (example k = (0, 3/4, 1, 0 | k5 = 2), m = 1: omega = +-i Sqrt[23]/4 = +-1.19896 i).
 (6) NO single momentum-independent positive J' exists once a hidden momentum is present.  If
     V(s) and the local energy-momentum tensor are to be Hermitian, J' must commute with beta
     (s = Psi^ddag G beta Psi) and with E_k for all k.  Certificate: for the four admissible unit
     momenta and one hidden momentum, EVERY X commuting with beta and all five E_k has
     Tr(G X) = 0, so G X is never positive definite.  Analytic proof for a purely hidden momentum:
     [E_k, beta] = 2 i k5 T16[5], so J' commutes with T16[5]; T16[5] anticommutes with G, hence
     T16[5]^dagger (G J') T16[5] = -(G J'): a positive matrix would be congruent to a negative one.
 (7) J is UNIQUE: the joint commutant of beta and all admissible E_k is 8-dimensional and every one
     of its elements commutes with J; if X is in it with X^2 = 1 and G X = J X definite, then
     (J X)^2 = 1, and a definite Hermitian matrix with square 1 is +-ID16: X = J (positive metric)
     or X = -J (every mode of negative norm).

THEOREM (admissibility).  Let W be the linear span of the momenta carried by the modes, a subspace of
the slice R^(4,3).  A positive (Hilbert-space) Fock quantization in which the local s(x), the local
energy-momentum tensor and the free Hamiltonian are all Hermitian exists if and only if W is
spacelike-definite; then J' = S^-1 J S with S a slice boost carrying W into span(x0..x3), and J' is
unique (with J'^2 = 1) when W = span(x0..x3).  On the canonical frame the fields depend on all of
x0..x3, so the condition is: NO momentum along x5, x6, x7, and J = -i T16[0].T16[1].T16[2].T16[3].T16[4]
is unique.  (Items (3)-(7) above are the ingredients; the general identity [E_k, beta] = 2 i T_k with
T_k = Sum_a k_a T16[a] is asserted below.)  The
admissible theory is a TRUNCATION (a dimensional reduction Psi = Psi(x0, ..., x4)), not a
superselection sector: V(s) contains terms like b^dagger_{k_h} b^dagger_{-k_h} b_0 b_0 that would
connect it to hidden momenta.  What survives of the multi-time picture is the isometry fact: the
metric, the frame and the connection do not depend on x5, x6, x7, so the hidden translations P_h
commute with the x4-evolution, [P_4, P_h] = 0.

(* ::Input:: *)
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

(* ::Text:: *)
THE HAMILTONIAN ON THE CANONICAL FRAME, THE SPIN CONNECTION, AND THE BOUNDARY CONDITION.  The
Hamiltonian DENSITY of the symmetrized Lagrangian, Pi_Psi d_4 Psi + d_4 Psibar Pi_Psibar - L, is

    Sqrt[g] [ -(1/(2H)) Sum_{k != 4} ( Psibar gamma^k d_k Psi - d_k Psibar gamma^k Psi ) + V(s) ] ,

with NO spin connection in it (on the canonical frame; this corrects the design's statement that
the connection "enters the Hamiltonian").  Varying it gives the one-particle operator: in the
admissible sector (Psi = Psi(x0, ..., x4)) the field equation is i Gtilde d_4 Psi = h Psi with

    h Psi  =  Sqrt[g] sigma16 [ V'(s) Psi - (1/H) ( Sum_{j=0..3} gamma^j d_j Psi + Sum_mu gamma^mu Gamma_mu Psi ) ] .

The connection appears here, through the equation of motion, and it has a job: since
(1/2) Sum_{mu != 4} d_mu( Sqrt[g] sigma16 gamma^mu ) == Sqrt[g] sigma16 gamma^mu Gamma_mu (and
d_4(Sqrt[g] sigma16 gamma^4) = 0), the derivative part of h is -(1/H) Sum_j (A_j d_j + (1/2) d_j A_j)
with A_j = Sqrt[g] sigma16 gamma^j real ANTIsymmetric, and for such an operator
<f, h g> - <h f, g> is a total derivative: the connection term is exactly the term that makes the
one-particle Hamiltonian Hermitian.  THE x0 DIRECTION AND ITS BOUNDARY CONDITION.  For the rescaled
field Psi' = Psi/Sqrt[Sin[6 H x0]] the measure becomes flat in the proper distance
z = -Log[Cos[6 H x0]]/(6 H) along x0: Sqrt[g] dx0 |Psi|^2 = |Psi'|^2 dz (Sec Sin = Tan = dz/dx0), z runs
over [0, infinity) as 6 H x0 runs over [0, Pi/2), and the x0 part of the rescaled Dirac operator is
exactly T16[0] d_z, while the frame factors are bounded: Sin[6 H x0] = Sqrt[1 - Exp[-12 H z]].  So
the one-particle space is L^2(dz), the operator is REGULAR at the wall z = 0 (a boundary condition is
needed there) and LIMIT-POINT at z -> infinity (by the standard theorem that a one-dimensional Dirac
system with locally integrable coefficients is always limit-point at an infinite endpoint: no
condition is needed or allowed there).  The condition at the wall in this real-Clifford
convention is the bag-type T16[0] Psi' = +-Psi' at z = 0 (no factor i, because T16[0]^2 = +1): it
kills the normal flux Psi'^dagger beta T16[0] Psi' (because {beta, T16[0]} = 0) and it commutes with J.
It is part of the canonical quantization.  Finally
J commutes with h: every matrix in h (sigma16, sigma16 gamma^j for j = 0..3, sigma16 gamma^mu Gamma_mu)
commutes with J -- for every a4, every x0-profile and every V.  A hidden derivative term would
anticommute (control).  The x4-dependence of h enters only through the observed frame factor
1/q; it mixes positive and negative frequencies (a Bogoliubov transformation) WITHIN the admissible
sector, and since it commutes with J that mixing is unitary on the Fock space.

(* ::Input:: *)
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

(* ::Text:: *)
KREIN MODES, EXACTLY.  For an admissible momentum k = (k0, k1, k2, k3) and mass m (flat local
analysis; on the canonical frame k is the physical momentum, the coordinate momentum along x1..x3
divided by q) put A = G h = E_k and w = Sqrt[k.k + m^2].  Then A^2 = w^2, [A, J] = 0, and the four
Hermitian projectors

    P_{s,eta}  =  (1/4) (ID16 + s A/w) (ID16 + eta J),       s, eta = +1, -1,

have rank 4 each (trace 4), sum to ID16, and Sum eta P_{s,eta} = J = G^-1 -- the COMPLETENESS
relation Sum_u eta_u u u^dagger = G^-1 of any J-orthonormal mode basis.  So each frequency +-w is
8-fold degenerate and the G-form restricted to each frequency eigenspace has signature (4,4).
For EVERY mode u in the image of P_{s,eta}, normalized by u^dagger G u = eta, the projector
identities P X P = c P give, exactly and for arbitrary k and m,

    eta u^dagger h u = s w = omega_u                      (energy = frequency),
    eta u^dagger sigma16 u = m/omega_u                    (scalar density),
    eta u^dagger (dh/dk_j) u = k_j/omega_u = d omega_u/d k_j   (velocity: Hellmann-Feynman),

where dh/dk_j = -i sigma16 T16[j].  The identities are proved with w a symbol and w^2 reduced to
k.k + m^2 (exact polynomial remainder), nothing numerical.

THE MODE BASIS MUST CONSIST OF J-EIGENVECTORS.  The Krein prescription "b_u^dagger := eta_u b_u^ddag"
depends on the basis.  It reproduces the J-involution Psi^dagger = Psi^ddag J only if every mode is a
J-eigenvector, J u = eta_u u -- which is what the P_{s,eta} above deliver (J P_{s,eta} = eta P_{s,eta}),
and which is possible because [J, G h_k] = 0 for momenta along x0..x3.  A G-orthonormal basis mixed
by a Krein boost inside one frequency eigenspace still diagonalizes the evolution, but it induces
the involution J_U = G U U^dagger != J, and under it s is NOT Hermitian (control below, exact, at
k = 3 e1, m = 4, with the boost cosh = 5/4, sinh = 3/4).  A generic generalized-eigenvector routine
does not choose J-eigenvectors; the Fock construction of the next cell does.

(* ::Input:: *)
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

(* ::Text:: *)
A FINITE FOCK SPACE AT ONE MOMENTUM (JORDAN-WIGNER).  At the momentum k = 3 e1 with m = 4 (so
omega = 5 exactly) the sixteen modes of one momentum are represented on C^(2^16) by Jordan-Wigner
operators f_1..f_16 (SparseArray, exact integers), which obey the positive CAR {f_i, f_j^dagger} =
delta_ij.  Two realizations are checked.

FIELD LEVEL.  Psi_a := f_a (the factor H/Sqrt[g] set to 1), Psi^dagger = f^dagger, Psi^ddag := Psi^dagger J.
Then {Psi_a, Psi^ddag_b} = J_ab = (G^-1)_ab -- exactly the Dirac-bracket anticommutator; the free
Hamiltonian H_free = Psi^ddag h Psi = Psi^dagger (J h) Psi and s = Psi^ddag sigma16 Psi = Psi^dagger beta Psi
are Hermitian operators, and so is the interacting H_free + lambda s^2; p = Psi^ddag C+ Psi is
anti-Hermitian (control); the one-body matrix J h has eigenvalues +5 and -5, eight times each; and
the HEISENBERG EQUATION holds: [H_free, Psi_a] = -(G^-1 h Psi)_a, i.e. i d_4 Psi = i [H, Psi] reproduces
i G d_4 Psi = h Psi.  With the opposite sign of the anticommutator (Psi^ddag := -Psi^dagger J) the
same construction gives H' = -H_free and the time-REVERSED equation (control): this is the
convention-free confirmation of the sign derived with the Dirac bracket.

MODE LEVEL.  b_u := f_u for the sixteen J-EIGENMODES of the previous cell (u = 1..8: omega = +5,
u = 9..16: omega = -5; J u = eta_u u with eta = +1 for four of each and -1 for the other four).  The Krein conjugate
b_u^ddag := eta_u b_u^dagger obeys {b_u, b_v^ddag} = eta_u delta_uv -- the indefinite CAR that the
field anticommutator demands through Sum_u eta_u u u^dagger = G^-1 -- and its naive "norm"
<0| b_u b_u^ddag |0> = eta_u is NEGATIVE for eta = -1: that is the indefinite metric the J-involution
removes (the Fock norm <0| b_u b_u^dagger |0> = 1).  The Hamiltonian Sum_u omega_u eta_u b_u^ddag b_u
equals Sum_u omega_u b_u^dagger b_u, [Ham, b_u] = -omega_u b_u (b_u(x4) = b_u e^(-i omega_u x4), the time
dependence of the classical mode), and its spectrum on the 65536 states is: a UNIQUE ground state
at -8 omega, the DIRAC SEA (all eight negative-frequency modes filled); the normal-ordered
:Ham: = Ham + 8 omega >= 0; the first excited level at +omega above it is 16-fold: 8 PARTICLE states
(one positive-frequency mode added) and 8 ANTIPARTICLE states (one negative-frequency mode
emptied, a hole), with particle number N = Sum_u b_u^dagger b_u - 8 = +1 and -1 respectively.  In a
Fock basis state the expectation of b_u^ddag b_v is eta_u n_u delta_uv, which is the rule
<Psi^ddag M Psi> = Sum_occupied eta_u u^dagger M u used in Section 29.  The particle-number density is
n^4 = -(i/H) Psibar gamma^4 Psi = (1/H) Psi^ddag G Psi = (1/H) Psi^dagger Psi, whose mode form is
Sum_u eta_u b_u^ddag b_u = Sum_u b_u^dagger b_u.

(* ::Input:: *)
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

(* ::Section:: *)
29.  The energy-momentum tensor operator of fermion fable: definition, conservation, and rho, P and w

(* ::Text:: *)
THE TENSOR, AND WHERE IT COMES FROM.  The energy-momentum tensor of fermion fable is

    That_{mu nu}  =  -(1/(4H)) [ Psibar gamma_mu D_nu Psi - (D_nu Psibar) gamma_mu Psi + (mu <-> nu) ]  +  g_{mu nu} Lhat ,

normal-ordered with respect to the J-vacuum of Section 28 when it is an operator.  It is the HILBERT
(symmetric-tetrad) tensor of the symmetrized action, T^{mu nu} = (2/Sqrt[g]) dS/dg_{mu nu}, and it
equals the covariant expression above OFF shell.  This is checked the direct way: perturb the
canonical frame by a symmetric first-order tetrad perturbation h(x0, x4) in the (mu, nu) slot,
recompute to first order everything that depends on the frame -- the metric, the Christoffel
symbols, the spin connection from the vielbein postulate, the curved gammas, Sqrt[g] -- and take the
Euler-Lagrange derivative with respect to h.  Three facts come out.  The result is the tensor above
(checked on the diagonal (x1, x1), (x4, x4) and off the diagonal (x1, x4), (x0, x5), (x5, x4)).  The
variation of the spin connection contributes EXACTLY NOTHING: its totally antisymmetric part does
not change under a symmetric tetrad variation, and the symmetrized Lagrangian sees the connection
only through that part, (1/2) omega_[cab] gamma^{cab}; the covariant-derivative terms of the tensor
come instead from the frame dependence of {gamma^mu, Gamma_mu}, which vanishes on the background
while its first variation does not.  And the Hilbert tensor is NOT the partial-derivative tensor
(control, at (x1, x4)): one never varies a partial-derivative Lagrangian.  Two more properties: the
tensor is symmetric, and it is Hermitian under the classical conjugation (real for Psi = u + i v).

(* ::Input:: *)
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

(* ::Text:: *)
CONSERVATION ON SHELL, AND WHY THE COMMUTING PROXY PROVES IT FOR THE FERMION.  Solve the two field
equations for the x4-derivatives,

    d_4 Psi     =  F     =  -gamma^4 ( H V'(s) Psi - gamma^0 d_0 Psi - (gamma^mu Gamma_mu) Psi ) ,
    d_4 Psibar  =  Fbar  =  ( H V'(s) Psibar + d_0 Psibar gamma^0 - Psibar (Gamma_mu gamma^mu) ) gamma^4 ,

and let cfOnShellC replace every x4-derivative of either field (of any order) by the corresponding
derivative of F or Fbar, to a fixed point.  Then nabla^mu That_{mu nu} == 0 in all eight components,
for generic Psi(x0, x4), Psibar(x0, x4) and generic V.  Why a commuting computation proves the
Grassmann statement: after the substitution every term of the divergence is a bilinear with Psibar
(or a derivative of it) on the left and Psi (or a derivative) on the right, multiplied by
functions of the EVEN composites s and d s (through V', V'' and their derivatives); no two odd
factors are ever exchanged, so the same algebra holds verbatim for anticommuting components.  A
configuration that is NOT a solution has a non-zero divergence (control).  The spin connection does
not drop out of the tensor: That differs from the partial-derivative tensor by
-(1/(4H)) Psibar ({gamma_mu, Gamma_nu} + {gamma_nu, Gamma_mu}) Psi, which vanishes on the diagonal
(so rho and every pressure are the same in both) but not off it -- and only That is conserved.  (The
symbolic divergence of the partial-derivative tensor is not attempted: it takes minutes and the
off-diagonal difference already shows the two tensors are different.)

(* ::Input:: *)
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

(* ::Text:: *)
ON SHELL: THE LAGRANGIAN, THE DENSITY, THE PRESSURES AND THE TRACE.  With cfOnShellC, for generic
Psi(x0, x4), Psibar(x0, x4) and generic V:

    kinetic bilinear (1/(2H))[Psibar gamma^mu D_mu Psi - (D_mu Psibar) gamma^mu Psi]  ==  s V'(s)   (NOT zero),
    Lhat == s V'(s) - V(s) ,
    rho = That_44 == V(s) + K_h ,          K_h = -(1/(2H)) ( Psibar gamma^0 d_0 Psi - d_0 Psibar gamma^0 Psi ) ,
    T^i_i == T^h_h == s V'(s) - V(s)       (i = 1, 2, 3 observed; h = 5, 6, 7 hidden) ,
    T^0_0 == s V'(s) - V(s) + K_h ,
    T^mu_mu == 7 s V'(s) - 8 V(s)          (off shell: 7 Lkin - 8 V) .

T^i_i = T^h_h holds because {gamma^mu, Gamma_mu} = 0 for EACH direction separately: the kinetic part
of T^i_i and T^h_h vanishes for fields of (x0, x4), and they reduce to Lhat.  In the real commuting
limit K_h is Part VI's cfKh, and for the rescaled solutions Psi = Sqrt[Sin[6 H x0]] Psi'(x4) (and the
same for Psibar) K_h = 0 and rho = V(s): Part VI's formulas, now for the complex field.

WHICH COMPONENTS ARE HERMITIAN OPERATORS (Section 28's rule, component by component).  For fields
independent of x5, x6, x7 -- the admissible sector, here Psi(x0, ..., x4), Psibar(x0, ..., x4) -- replace
Psi -> J Psi and Psibar -> Psibar J (J^2 = 1, s is unchanged).  A component that goes into itself
is built from J-even matrices and is a HERMITIAN operator; one that goes into minus itself is
anti-Hermitian.  The table: all components with mu, nu in {0..4} are even; the components
That_{mu h} (mu in 0..4, h in 5..7) are ODD (anti-Hermitian; purely imaginary expectation values,
and zero in every state invariant under the hidden rotations, because That_{mu h} is a vector
under them); That_{h h'} (h != h') VANISHES identically; That_{hh} = g_hh Lhat is even.  The
hidden momenta P_h = Int Sqrt[g] That^4_h are J-odd operators with zero expectation in the J-eigenmode
Fock states of Section 28.

(* ::Input:: *)
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

(* ::Text:: *)
EXPECTATION VALUES: THE MODE SUMS.  Use the canonical normalization chi = Psi/Sqrt[H] (then
V(s) = V(H sigma) =: W(sigma), sigma = <chibar chi>, and m = W'(sigma) is the mass in the mode equation) and
the local plane-wave analysis of Section 28.  On a plane wave chi = u Exp[i (k.x - omega x4)],
chibar = ubar Exp[-i (k.x - omega x4)] (ubar = u^ddag sigma16), the kinetic parts of the tensor are

    T_44 + Lhat  ==  omega ubar (-i T16[4]) u  =  omega u^ddag G u ,
    T^j_j - Lhat  ==  k_j ubar (-i T16[j]) u   =  k_j u^ddag (dh/dk_j) u        (j = 0..3, flat frame),

and by the expectation rule <Psi^ddag N Psi> = Sum_occupied eta_u u^dagger N u of Section 28 together
with the exact mode identities there, each occupied positive-frequency mode contributes omega to the
energy density, k_j^2/omega to the pressure along j, and m/omega to sigma; each hole in the sea
contributes the same with omega -> |omega|.  So for a state of N modes in a coordinate volume Vol,
rho = Sum omega/Vol + (W - sigma W'), P_j = Sum k_j^2/(omega Vol) + (sigma W' - W), sigma = Sum m/(omega Vol);
for ONE particle w = (k^2/3)/omega^2 (isotropic average) on top of the background W - sigma W'.

THE VACUUM.  <0| :That_{mu nu}: |0> = 0 by normal ordering with respect to the J-vacuum.  That
statement is clean only for a STATIC background (a4 = const) or in the adiabatic limit: on an
x4-dependent background normal ordering is ambiguous -- with respect to the instantaneous vacuum it
breaks covariant conservation, with respect to a fixed in-vacuum it leaves a divergence -- and a
conserved renormalized <T> needs adiabatic subtraction or point-splitting.  The unrenormalized sea
energy per unit volume, -g Int^Lambda d^3k/(2 pi)^3 omega, is minus the Fermi-sea energy at k_F = Lambda:

    -(g/(16 pi^2)) [ 2 Lambda^4 + 2 m^2 Lambda^2 + m^4/4 - m^4 Log[2 Lambda/m] ] + O(Lambda^-2) ,

whose finite, mass-dependent part contains -(g/(32 pi^2)) m^4 Log[m^2].  It is absorbed into V (the
renormalized, no-sea functional); the cosmological-constant problem is NOT solved here.

(* ::Input:: *)
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

(* ::Text:: *)
THE HOMOGENEOUS FERMI SEA (THE KOHN-SHAM GROUND STATE) IN CLOSED FORM.  Fill the positive-frequency
modes with |k| < k_F along the observed sheet (zero modes along x0 -- the Sqrt[Sin] profile -- and
along x5, x6, x7).  The degeneracy is g = 8 = 4 flavours x 2 spins (Sections 26 and 28: 8
positive-frequency modes per momentum).  With w_F = Sqrt[k_F^2 + m^2] and L = Log[(k_F + w_F)/m]
(m > 0; everything depends on m^2 except sigma, which has the sign of m):

    n          =  g k_F^3/(6 pi^2)                                                   = g Int d^3k/(2 pi)^3 1
    sigma_KS   =  (g m/(4 pi^2)) [ k_F w_F - m^2 L ]                                  = g Int d^3k/(2 pi)^3 m/omega
    eps_KS     =  (g/(16 pi^2)) [ k_F w_F (2 k_F^2 + m^2) - m^4 L ]                  = g Int d^3k/(2 pi)^3 omega
    P_KS       =  (g/(48 pi^2)) [ k_F w_F (2 k_F^2 - 3 m^2) + 3 m^4 L ]              = g Int d^3k/(2 pi)^3 k^2/(3 omega)

Each closed form is proved equal to its integral: its k_F-derivative is the integrand times
g k_F^2/(2 pi^2) and it vanishes at k_F = 0; independently, Mathematica's Integrate returns the same
function (with ArcTanh[k_F/w_F], which equals L); and a numerical quadrature agrees (control).  The
identities that organise them:

    eps_KS + P_KS == w_F n        (the zero-temperature Gibbs relation, mu = w_F),
    eps_KS - 3 P_KS == m sigma_KS  (the trace identity),
    d eps_KS/dm == sigma_KS,  d eps_KS/dk_F == w_F dn/dk_F .

MEAN FIELD.  With W(sigma) := V(H sigma), the gap equation m = W'(sigma) and self-consistency
sigma = sigma_KS(k_F, m):

    rho = eps_KS + W - sigma W' ,    P_obs = P_KS + sigma W' - W ,    P_hid = P_x0 = sigma W' - W ,
    rho + P_obs == w_F n (exact) ,   d rho/dn == w_F at the self-consistent point .

THE AUTHOR'S MASS TERM, W = m sigma (V = -(2M/H) s gives m = -2M): W - sigma W' = 0, so
rho = eps_KS > 0, P = P_KS >= 0 and 0 <= w = P_KS/eps_KS <= 1/3; w depends only on x = k_F/|m|, it
rises MONOTONICALLY from 0 (x -> 0, w ~ x^2/5: dust) to 1/3 (x -> infinity: radiation) -- dust only in the
non-relativistic limit.  The classical sign problem disappears: Part VI needed M s < 0 for
rho = -(2M/H) s > 0, and quantum mechanically m sigma_KS = g Int m^2/omega >= 0 automatically.

THE CLASSICAL LIMIT, STATED PRECISELY.  At the self-consistent point the trace identity gives, exactly,

    rho == W(sigma) + 3 P_KS ,        P_obs == ( sigma W'(sigma) - W(sigma) ) + P_KS ,

i.e. Part VI's rho = V(s), P = s V' - V (with s = H sigma) plus the degeneracy pressure and three times
it.  Part VI is recovered exactly in the limit P_KS/eps_KS -> 0, which is k_F/|m| -> 0: the cold,
NON-RELATIVISTIC limit of the Fermi sea (not "k_F -> 0 at fixed n", which is impossible).

(* ::Input:: *)
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

(* ::Text:: *)
ON THE PRE-UNIVERSE: THE QUANTUM GAS COOLS, THE CLASSICAL FIELD DOES NOT.  Four facts, each proved.

(1) CHARGE.  The number current is conserved on shell for generic Psi(x0, x4), Psibar(x0, x4).  For
    the x0-profile Psi = Sqrt[Sin[6 H x0]] Psi' with Psi' independent of x0, Sqrt[g] j^0 is independent
    of x0 (Sec Sin Cot = 1), so d_4(Sqrt[g] j^4) = 0: the charge per coordinate volume does not depend
    on x4, and since Sqrt[g] does not either, neither does the proper 8-density.  The 7-volume is
    constant because the observed sheet grows exactly as the hidden sheet shrinks (q^3 p^3 is
    x4-independent, Part VI).
(2) WHICH x4-ONLY FIELDS SOLVE THE EQUATIONS.  Psi = Sqrt[Sin] Psi'(x4) solves the field equation at every
    x0 iff V''(s) s' = 0: either V is linear (the author's mass term), or the data are NULL,
    s' = Psi'bar Psi' = 0.  s' is conserved by the x4-only equations, so null data give x4-only
    solutions for ANY V, with rho = V(0).  For a nonlinear V and s' != 0 it fails (witness).
(3) REDSHIFT.  A mode Psi = Sqrt[Sin] u(x4) Exp[i k x1] (coordinate momentum k along the observed
    sheet) obeys T16[4] u' + i (k/q) T16[1] u = H V' u exactly: its PHYSICAL momentum is k/q, and
    d Log[k/q]/dx4 = H a4'(H x4) = -H_obs.  The observed-sheet momenta redshift as Exp[a4] ~ 1/a, and
    the instantaneous frequency is Sqrt[k^2/q^2 + m^2] (Section 28's E^2 = omega^2 at k_phys = k/q).
(4) COOLING.  The occupied coordinate momenta are fixed (the mode labels are conserved; the
    x4-dependence of q only mixes +-omega, a Bogoliubov effect that vanishes adiabatically), so
    x = k_F,phys/m falls as Exp[a4]: dx/dx4 = H a4' x, and since w(x) is increasing, sign(dw/dx4) =
    sign(a4').  In the regime a4' < 0 (the observed sheet expanding, Section 25) the quantum fable gas
    COOLS, w: 1/3 -> 0, even though its 8-density does not dilute.  The classical Part VI fable, by
    contrast, has ds/dx4 = 0 on the rescaled solutions and w = s V'/V - 1 FROZEN.

(* ::Input:: *)
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

(* ::Text:: *)
THE FINAL TALLY.  Section 22's and Section 25's tally cells remain where they are, untouched.  This
cell repeats the tally after Part VII, so that the last cell of the notebook reports every assertion
made anywhere in it -- including the one that no identity was accepted on numerical evidence alone
-- and the non-vanishing witnesses, which Part VII adds to.

(* ::Input:: *)
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
