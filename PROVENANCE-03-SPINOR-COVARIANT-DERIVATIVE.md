# Provenance 03 — The gauge-covariant derivative of the 16-component spinor

**Effort.** Step 3 of the standard procedure. Construct the covariant derivative for the
16-component spinor field that is the direct sum of a split-octonion type-1 spinor field and a
split-octonion type-2 spinor field, by replacing ordinary partial derivatives with

```
Dcov[mu] psi  ==  D[psi, x[mu]]  +  (1/8) omega[mu,a,b] Commutator[gamma[a], gamma[b]] . psi
```

where `gamma[a]` are the 16×16 Dirac matrices, which had to be defined first.

This is section 17 of `C:\Users\nsh\Documents\8-dim\claude-fable_Einstein-Rosen-2-Planes.nb`
(Input cells 111–116), resting on section 5 (cells 22–29) for the Dirac matrices.

Everything needed to repeat this work is on this page. No other file needs to be consulted.

---

## 1. The 16×16 Dirac matrices

They are not invented here. They are the author's own, built by E. A. Lord's reduced
Brauer–Weyl construction ("The Dirac spinor in six dimensions", Math. Proc. Camb. Phil. Soc. 64
(1968) 765–778), which promotes the real 8×8 Clifford generators to 16×16 ones by an
off-diagonal doubling:

```
gamma[A]  ==  T16[A]  ==  ArrayFlatten[{{0, taubar[A]}, {tau[A], 0}}] ,     A = 0..7
```

where

- `tau[0] = ID8`;
- `tau[1..6]` are the six 8×8 blocks assembled from the SO(4) self-dual `s4by4[h]` and
  anti-self-dual `t4by4[h]` matrices;
- `tau[7] = tau[1].tau[2].tau[3].tau[4].tau[5].tau[6]`;
- `taubar[A] = sigma . Transpose[sigma . tau[A]]` is the sigma-adjoint, with
  `sigma = ArrayFlatten[{{0,ID4},{ID4,0}}]`.

They satisfy the Clifford relation of the 4+4 quadratic form,

```
(1/2) ( T16[A] . T16[B] + T16[B] . T16[A] )  ==  eta4488[[A+1,B+1]] ID16
```

equivalently `Anticommutator[gamma[a], gamma[b]] == 2 eta[a,b] ID16`.

`T16[8]`, the ordered product of all eight, is the chirality operator, and
`sigma16 = T16[0].T16[1].T16[2].T16[3] == ArrayFlatten[{{-sigma,0},{0,sigma}}]` is the 16×16
spinor metric.

## 2. The structural fact that makes the direct sum work

Each `gamma[a]` is **off-diagonal** in the type-1 / type-2 block decomposition. Therefore every
*product of two* gammas is **block diagonal**:

```
T16[A] . T16[B] = ArrayFlatten[{{taubar[A].tau[B], 0}, {0, tau[A].taubar[B]}}]
```

The spin connection enters `Dcov` only through commutators of two gammas, so the connection
matrix never mixes the type-1 spinor with the type-2 spinor. The 16-component covariant
derivative really is the direct sum of a type-1 covariant derivative and a type-2 covariant
derivative:

```
Dcov1[mu] psi1 = D[psi1, x_mu] + (1/8) omega[mu,a,b] ( taubar^a tau^b - taubar^b tau^a ) . psi1
Dcov2[mu] psi2 = D[psi2, x_mu] + (1/8) omega[mu,a,b] ( tau^a taubar^b - tau^b taubar^a ) . psi2
```

Acting on a split-octonion **type-1** spinor field `psi`, which is what the prompt asks for, the
replacement is exactly the first of those two lines.

Also, because `SAB[[a+1,b+1]] = (1/4) Commutator[gamma[a], gamma[b]]`, the connection term
`(1/8) omega[mu,a,b] Commutator[gamma[a],gamma[b]]` is identically
`(1/2) omega[mu,a,b] SAB[[a+1,b+1]]`, which is the form the original notebook's commented-out
Lagrangian `Lg` uses.

## 3. Complete commands

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"
cat > prov03_covariant_derivative.wls <<'WLSEOF'
(* Run the delivered notebook, then print everything about the 16x16 Dirac matrices and the
   spinor covariant derivative. *)

nbfile = "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb";
SetDirectory["C:/Users/nsh/Documents/8-dim"];
nb = Import[nbfile, "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
(* cells 1..116 = everything through section 17 *)
Block[{$Output = {}},
  Do[ReleaseHold[asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, 1, 116}]];

line[s_] := Print["\n================ ", s, " ================"];

line["THE 16x16 DIRAC MATRICES gamma[a] = T16[a]"];
Print["dimensions of each: ", Dimensions[T16[0]]];
Print["Clifford relation {gamma^a,gamma^b} == 2 eta^{ab} ID16 : ",
  Union@Flatten@Table[
    T16[A] . T16[B] + T16[B] . T16[A] === 2 \[Eta]4488[[A+1,B+1]] ID16, {A,0,7},{B,0,7}]];
Print["chirality T16[8] squares to ID16 : ", T16[8] . T16[8] === ID16];
Print["sigma16 == ArrayFlatten[{{-sigma,0},{0,sigma}}] : ",
  \[Sigma]16 === ArrayFlatten[{{-\[Sigma], 0}, {0, \[Sigma]}}]];
Print["gamma[0] = "]; Print[MatrixForm[T16[0]]];

line["EVERY PRODUCT OF TWO GAMMAS IS BLOCK DIAGONAL"];
Print[Union@Flatten@Table[
   T16[A] . T16[B] === ArrayFlatten[{{\[Tau]bar[A] . \[Tau][B], 0}, {0, \[Tau][A] . \[Tau]bar[B]}}],
   {A,0,7},{B,0,7}]];

line["THE 16x16 SPIN-CONNECTION MATRIX Gamma^spin[mu]"];
Print["dimensions: ", Dimensions[GammaSpinCanonical]];
Print["(1/8) omega [gamma^a,gamma^b] == (1/2) omega SAB : ",
  cfZeroArrayQ[Table[GammaSpinCanonical[[mu]]
     - (1/2) Sum[omegaCanonical[[mu,a,b]] SAB[[a,b]], {a,8},{b,8}], {mu,8}]]];
Print["block diagonal (type-1 never mixes with type-2) : ",
  cfZeroArrayQ[Table[GammaSpinCanonical[[mu]]
     - ArrayFlatten[{{GammaSpinCanonical[[mu]][[1;;8,1;;8]], 0},
                     {0, GammaSpinCanonical[[mu]][[9;;16,9;;16]]}}], {mu,8}]]];
Print["directions mu where Gamma^spin[mu] is non-zero : ",
  Select[Range[8], Count[Flatten[GammaSpinCanonical[[#]]], Except[0]] > 0 &] - 1];
Do[If[Count[Flatten[GammaSpinCanonical[[mu]]], Except[0]] > 0,
   Print["  Gamma^spin[", mu-1, "] has ", Count[Flatten[GammaSpinCanonical[[mu]]], Except[0]],
         " non-zero entries"]], {mu, 8}];

line["THE TYPE-1 BLOCK, WRITTEN IN tau AND taubar"];
Print["type-1 block == (1/8) omega (taubar^a tau^b - taubar^b tau^a) : ",
  cfZeroArrayQ[Table[GammaSpinType1[[mu]] - (1/8) Sum[omegaCanonical[[mu,a,b]]
     (\[Tau]bar[a-1] . \[Tau][b-1] - \[Tau]bar[b-1] . \[Tau][a-1]), {a,8},{b,8}], {mu,8}]]];
Print["type-2 block == (1/8) omega (tau^a taubar^b - tau^b taubar^a) : ",
  cfZeroArrayQ[Table[GammaSpinType2[[mu]] - (1/8) Sum[omegaCanonical[[mu,a,b]]
     (\[Tau][a-1] . \[Tau]bar[b-1] - \[Tau][b-1] . \[Tau]bar[a-1]), {a,8},{b,8}], {mu,8}]]];
Print["the type-1 connection matrix in direction mu = 1:"];
Print[MatrixForm[GammaSpinType1[[2]]]];

line["THE COVARIANT DERIVATIVE ON A GENERIC SPINOR"];
Print["Dcov16 on the direct sum == direct sum of Dcov1 and Dcov2 : ",
  cfZeroArrayQ[Table[cfDcov16[psiGeneric, mu]
     - Join[cfDcovType1[psi1Generic, mu], cfDcovType2[psi2Generic, mu]], {mu, 8}]]];
Print["Dcov on a TYPE-1 split-octonion spinor, direction mu = 1, first two components:"];
Print[Column[cfDcovType1[psi1Generic, 2][[1 ;; 2]]]];

line["THE CURVED-SPACE DIRAC OPERATOR"];
Print["gammaCurved[mu] = coframe[[a,mu]] gamma^a"];
Print["{gammaCurved[mu],gammaCurved[nu]} == 2 g^{mu nu} ID16 : ",
  cfZeroArrayQ[Table[gammaCurvedCanonical[[mu]] . gammaCurvedCanonical[[nu]]
     + gammaCurvedCanonical[[nu]] . gammaCurvedCanonical[[mu]]
     - 2 gInvCanonical[[mu,nu]] ID16, {mu,8},{nu,8}]]];
Print["dimensions of the curved gamma list : ", Dimensions[gammaCurvedCanonical]];

line["DONE"];
WLSEOF
timeout 3000 wolframscript -file prov03_covariant_derivative.wls 2>&1 | tee prov03.log
```

## 4. The result

```
================ THE 16x16 DIRAC MATRICES gamma[a] = T16[a] ================
dimensions of each: {16, 16}
Clifford relation {gamma^a,gamma^b} == 2 eta^{ab} ID16 : {True}
chirality T16[8] squares to ID16 : True
sigma16 == ArrayFlatten[{{-sigma,0},{0,sigma}}] : True

================ EVERY PRODUCT OF TWO GAMMAS IS BLOCK DIAGONAL ================
{True}

================ THE 16x16 SPIN-CONNECTION MATRIX Gamma^spin[mu] ================
dimensions: {8, 16, 16}
(1/8) omega [gamma^a,gamma^b] == (1/2) omega SAB : True
block diagonal (type-1 never mixes with type-2) : True
directions mu where Gamma^spin[mu] is non-zero : {1, 2, 3, 5, 6, 7}
  Gamma^spin[1] has 32 non-zero entries
  Gamma^spin[2] has 32 non-zero entries
  Gamma^spin[3] has 32 non-zero entries
  Gamma^spin[5] has 32 non-zero entries
  Gamma^spin[6] has 32 non-zero entries
  Gamma^spin[7] has 32 non-zero entries

================ THE TYPE-1 BLOCK, WRITTEN IN tau AND taubar ================
type-1 block == (1/8) omega (taubar^a tau^b - taubar^b tau^a) : True
type-2 block == (1/8) omega (tau^a taubar^b - tau^b taubar^a) : True

================ THE COVARIANT DERIVATIVE ON A GENERIC SPINOR ================
Dcov16 on the direct sum == direct sum of Dcov1 and Dcov2 : True

================ THE CURVED-SPACE DIRAC OPERATOR ================
{gammaCurved[mu],gammaCurved[nu]} == 2 g^{mu nu} ID16 : True
dimensions of the curved gamma list : {8, 16, 16}
```

`Gamma^spin[mu]` is non-zero only for `mu = 1,2,3,5,6,7` — the six directions in which the
canonical spin connection itself is non-zero. In the hidden-space direction `mu = 0` and the time
direction `mu = 4` the covariant derivative reduces to the ordinary partial derivative.

## 5. The three functions the notebook defines

```
cfDcov16[psi, mu]        16-component spinor, D[psi, x_mu] + Gamma^spin[mu] . psi
cfDcovType1[psi1, mu]     8-component type-1 split-octonion spinor
cfDcovType2[psi2, mu]     8-component type-2 split-octonion spinor
cfDiracOperator[psi]      Sum over mu of gammaCurved[mu] . cfDcov16[psi, mu]
```

Splitting `cfDcov16` into `cfDcovType1` and `cfDcovType2` is legitimate exactly because
`Gamma^spin[mu]` is block diagonal, which the run verifies rather than assumes.

## 6. What this proves

- The 16×16 Dirac matrices required by Step 3 exist, are real, and satisfy the Clifford relation
  of the signature-(4,4) quadratic form.
- The prescribed replacement `D[psi,x_mu] -> D[psi,x_mu] + (1/8) omega[mu,a,b] [gamma^a,gamma^b] psi`
  is well defined on the 16-component spinor and agrees with the `(1/2) omega SAB` form.
- Acting on the direct sum of a type-1 and a type-2 split-octonion spinor, the covariant
  derivative respects the direct sum: it never rotates a type-1 spinor into a type-2 spinor.
  That is a property of this particular Clifford representation, not an assumption.
- The curved gammas built from the coframe satisfy the curved Clifford relation
  `{gamma^mu, gamma^nu} == 2 g^{mu nu}`, so the curved-space Dirac operator is well posed.
