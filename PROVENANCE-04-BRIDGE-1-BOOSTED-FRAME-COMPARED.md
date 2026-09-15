# Provenance 04 — New bridge 1, a locally boosted frame, compared to the canonical spin connection

**Effort.** Invent a new way of bridging curved spacetime indices to flat tangent-space indices;
derive its spin connection from the same vielbein postulate; and compare that new spin connection,
component by component, with the canonical one of section 16.

This is section 18 of `C:\Users\nsh\Documents\8-dim\claude-fable_Einstein-Rosen-2-Planes.nb`
(Input cells 117–122).

Everything needed to repeat this work is on this page. No other file needs to be consulted.

The script below opens the notebook **inside the repository**, at
`<repo>\claude-fable\claude-fable_Einstein-Rosen-2-Planes.nb`, and sets the working
directory to `<repo>\claude-fable`. That is the only copy git tracks, so this page runs
against a fresh clone with no further step. An identical copy is also delivered to
`C:\Users\nsh\Documents\8-dim\` for the author's convenience; that one is outside the
repository and nothing on this page depends on it.

---

## 1. The new bridge

Introduce an object that does not appear in the original notebook: a **rapidity field**
`cfBoostRapidity[x0,x4]`, an arbitrary differentiable scalar function of the hidden-space
coordinate `x0` and the time coordinate `x4`. It generates a boost in the flat `(0,4)` plane, i.e.
between the first tangent direction (spacelike, `eta = +1`) and the fifth (timelike, `eta = -1`):

```
Lambda[theta] = ID8 + (Cosh[theta]-1)(E00 + E44) + Sinh[theta](E04 + E40)
              = MatrixExp[theta K]
```

where `K` is the boost generator with `K[[1,5]] = K[[5,1]] = 1` in Wolfram positions. The new
frame field is

```
frameBoost = frameCanonical . Lambda
```

`Lambda` is an element of `O(4,4)`, so **the curved metric is unchanged**. The two frames install
two different local flat Minkowski coordinate systems at each point, related by a different boost
at every point, over one and the same geometry.

This is the most physically pointed of the three new bridges, because it exhibits the spin
connection as **the gauge field of local Lorentz transformations**: a pure change of local frame
must shift it by an inhomogeneous term, exactly as a change of phase shifts the electromagnetic
vector potential.

## 2. The comparison that was proved

If a new frame is built as `frameNew = frameOld . L` with `L` a matrix of flat indices, then
substituting into the vielbein postulate and setting `M = Transpose[L]` gives

```
omegaNew[mu]  ==  M . omegaOld[mu] . Inverse[M]  -  D[M, x_mu] . Inverse[M]
```

Nothing in the notebook assumes this. The new connection is derived independently by the same
solver `cfSpinConnection`, and the formula is then verified against the derived result.

Because `Lambda == MatrixExp[theta K]`, the inhomogeneous piece collapses to something very
simple:

```
D[Lambda, x_mu] . Inverse[Lambda]  ==  D[theta, x_mu] * K
```

with no residual `theta` dependence at all. So the entire difference between the two spin
connections is **one scalar gradient times one fixed generator**:

```
Delta1[mu]  ==  omegaBoost[mu] - Lambda . omegaCanonical[mu] . Inverse[Lambda]
            ==  -D[theta, x_mu] * K
```

## 3. Complete commands

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"
cat > prov04_bridge1.wls <<'WLSEOF'
(* Run the delivered notebook, then print the whole of the bridge-1 comparison. *)

nbfile = "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb";
SetDirectory["C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"];
nb = Import[nbfile, "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
(* cells 1..122 = everything through section 18 *)
Block[{$Output = {}},
  Do[ReleaseHold[asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, 1, 122}]];

line[s_] := Print["\n================ ", s, " ================"];

line["THE NEW OBJECT: A LOCAL BOOST Lambda(x)"];
Print["Lambda = "]; Print[MatrixForm[cfLambda]];
Print["Lambda . eta . Transpose[Lambda] == eta   (Lambda is in O(4,4)) : ",
  cfZeroArrayQ[cfLambda . \[Eta]4488 . Transpose[cfLambda] - \[Eta]4488]];
Print["Lambda . Transpose[Lambda] != ID8         (a boost, not a rotation) : ",
  ! TrueQ[cfZeroArrayQ[cfLambda . Transpose[cfLambda] - ID8]]];
Print["Lambda == MatrixExp[theta K] : ",
  cfZeroArrayQ[cfLambdaOf[\[Theta]] - MatrixExp[\[Theta] cfBoostGenerator]]];
Print["the boost generator K = "]; Print[MatrixForm[cfBoostGenerator]];

line["THE NEW FRAME FIELD"];
Print["frameBoost = frameCanonical . Lambda ="]; Print[MatrixForm[frameBoost]];
Print["it is a DIFFERENT frame : ", frameBoost =!= frameCanonical];
Print["but it gives the SAME curved metric g : ",
  cfZeroArrayQ[frameBoost . \[Eta]4488 . Transpose[frameBoost] - gCanonical]];

line["THE NEW SPIN CONNECTION"];
Print["non-zero components of omegaBoost : ", Count[Flatten[omegaBoost], Except[0]]];
Print["   (canonical had ", Count[Flatten[omegaCanonical], Except[0]], ")"];
Print["vielbein postulate holds identically : ",
  cfZeroArrayQ[cfVielbeinResidual[frameBoost, X, GammaCanonical, omegaBoostMixed]]];
Print["omega[mu,a,b] == -omega[mu,b,a]      : ",
  cfZeroArrayQ[Table[omegaBoost[[m,a,b]] + omegaBoost[[m,b,a]], {m,8},{a,8},{b,8}]]];
Print["torsion still vanishes               : ",
  cfZeroArrayQ[cfTorsion[frameBoost, X, omegaBoostMixed]]];

line["COMPARISON WITH THE CANONICAL SPIN CONNECTION"];
Print["omegaBoost == M omegaCanonical Inverse[M] - D[M,x_mu] Inverse[M],  M = Transpose[Lambda] : ",
  cfZeroArrayQ[omegaBoostMixed - omegaBoostPredicted]];
Print["the WHOLE difference is the inhomogeneous gauge term : ",
  cfZeroArrayQ[deltaBoost - gaugeTermBoost]];
Print["the difference equals -D[theta,x_mu] * K : ",
  cfZeroArrayQ[Table[deltaBoost[[mu]]
    + D[cfBoostRapidity[x0,x4], X[[mu]]] cfBoostGenerator, {mu,8}]]];
Print["non-zero components of the difference : ", Count[Flatten[deltaBoost], Except[0]]];
Scan[Print["  Delta1[", #[[1]]-1, "] flat entry (", #[[2]]-1, ",", #[[3]]-1, ") = ",
      InputForm[deltaBoost[[Sequence @@ #]]]] &,
  Select[Flatten[Table[{m,a,b},{m,8},{a,8},{b,8}],2], deltaBoost[[Sequence @@ #]] =!= 0 &]];

line["THE GEOMETRY IS THE SAME: CURVATURE AND RICCI SCALAR"];
Print["R' == M R Inverse[M]  (curvature transforms covariantly) : ",
  cfZeroArrayQ[Table[RiemannBoost[[mu,nu]] - cfM . RiemannCanonical[[mu,nu]] . cfMinv,
    {mu,8},{nu,8}]]];
Print["Ricci scalar, canonical : ", InputForm[RicciScalarCanonical]];
Print["Ricci scalar, bridge 1  : ", InputForm[RicciScalarBoost]];
Print["they are equal          : ", cfZeroQ[RicciScalarBoost - RicciScalarCanonical]];

line["DONE"];
WLSEOF
timeout 3000 wolframscript -file prov04_bridge1.wls 2>&1 | tee prov04.log
```

## 4. The result

```
================ THE NEW OBJECT: A LOCAL BOOST Lambda(x) ================
Lambda . eta . Transpose[Lambda] == eta   (Lambda is in O(4,4)) : True
Lambda . Transpose[Lambda] != ID8         (a boost, not a rotation) : True
Lambda == MatrixExp[theta K] : True

================ THE NEW FRAME FIELD ================
it is a DIFFERENT frame : True
but it gives the SAME curved metric g : True

================ THE NEW SPIN CONNECTION ================
non-zero components of omegaBoost : 28
   (canonical had 24)
vielbein postulate holds identically : True
omega[mu,a,b] == -omega[mu,b,a]      : True
torsion still vanishes               : True

================ COMPARISON WITH THE CANONICAL SPIN CONNECTION ================
omegaBoost == M omegaCanonical Inverse[M] - D[M,x_mu] Inverse[M],  M = Transpose[Lambda] : True
the WHOLE difference is the inhomogeneous gauge term : True
the difference equals -D[theta,x_mu] * K : True
non-zero components of the difference : 4
  Delta1[0] flat entry (0,4) = -Derivative[1, 0][cfBoostRapidity][x0, x4]
  Delta1[0] flat entry (4,0) = -Derivative[1, 0][cfBoostRapidity][x0, x4]
  Delta1[4] flat entry (0,4) = -Derivative[0, 1][cfBoostRapidity][x0, x4]
  Delta1[4] flat entry (4,0) = -Derivative[0, 1][cfBoostRapidity][x0, x4]

================ THE GEOMETRY IS THE SAME: CURVATURE AND RICCI SCALAR ================
R' == M R Inverse[M]  (curvature transforms covariantly) : True
Ricci scalar, canonical : -3*H^2*((55 + 7*Cos[12*H*x0])*Cot[6*H*x0]^2*Csc[6*H*x0]^2 - 2*Derivative[1][a4][H*x4]^2)
Ricci scalar, bridge 1  : 3*H^2*(-((55 + 7*Cos[12*H*x0])*Cot[6*H*x0]^2*Csc[6*H*x0]^2) + 2*Derivative[1][a4][H*x4]^2)
they are equal          : True
```

## 5. Reading the comparison

**The difference is exactly four components out of 512, and they are the four the gauge argument
predicts.** The boost was chosen in the flat `(0,4)` plane, so the only flat entries that can be
touched are `(0,4)` and `(4,0)`; and the rapidity depends only on `x0` and `x4`, so the only
spacetime directions that can be touched are `mu = 0` and `mu = 4`. Two times two is four.

The value in each of those four slots is minus the corresponding partial derivative of the
rapidity. That is the whole difference between the two spin connections — no dependence on the
metric, on `a4`, on `Sin[6 H x0]`, or on the rapidity itself, only on its gradient.

This is the precise sense in which the spin connection is the gravitational analogue of the
electromagnetic vector potential. A local Lorentz transformation shifts it by
`-Lambda^{-1} d Lambda`, exactly as a local phase rotation shifts `A_mu` by `-d(phase)`.

The two spin connections are therefore **gauge-equivalent descriptions of the same geometry**.
The certificates that say so are the last three lines: the curvature transforms covariantly
(`R' == M R M^{-1}`, no inhomogeneous term), and the Ricci scalar — a number no change of frame
can alter — is identical.

Note on reading the raw output: the two Ricci scalars print with the overall minus sign placed
differently, `-3 H^2 (A - B)` against `3 H^2 (-A + B)`. Those are the same expression;
`FullSimplify` simply settles on different arrangements when it reaches them from different
frames. The final `cfZeroQ` check on the difference, not the printed form, is what settles the
matter, and it returns True.

## 6. What this proves

- A genuinely different frame field over the same metric exists and was constructed.
- Its spin connection, derived independently from the zero-torsion vielbein postulate, is still
  `so(4,4)`-valued and still torsion-free.
- It differs from the canonical spin connection by a pure gauge term, and that term was computed
  in closed form: `-d(rapidity) * (0,4)-boost generator`, four non-zero components.
- The two connections describe the same geometry: same curvature up to conjugation, same Ricci
  scalar.
