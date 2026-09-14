# Provenance 07 — Reproducing the original physics, and proving it byte-for-byte

**Effort.** Reproduce, in the refactored notebook, the whole physics chain of the original
scratch notebook: the 16-component wave function of the un-universe, its Lagrangian, the
Euler–Lagrange equations, the change of chart to `(z,t)`, the decoupling into four blocks of
four, the Maple closed-form solutions, the bilinear invariants, the two solution branches, and
M6 = the 6-plane in which the 3 generations of Einstein–Rosen 2-plane bridges live. Then prove
the reproduction is faithful, not merely plausible.

This is Part II of `C:\Users\nsh\Documents\8-dim\claude-fable_Einstein-Rosen-2-Planes.nb`,
sections 10 to 14, Input cells 53 to 90.

Everything needed to repeat this work is on this page. No other file needs to be consulted.

---

## 1. The strongest possible fidelity check, and it passes

The original notebook calls `DumpSave` on its Euler–Lagrange equations, twice, and the author's
saved output is still in the repository:

```
Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLa.mx      2705 bytes
Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLazt.mx    3145 bytes
```

The refactored notebook calls `DumpSave` at the same two points with the same naming convention,
producing

```
claude-fable_Einstein-Rosen-2-Planes-eLa.mx      2696 bytes
claude-fable_Einstein-Rosen-2-Planes-eLazt.mx    3144 bytes
```

Loading both pairs into one kernel and comparing gives **`SameQ` — identical expressions, not
merely equal ones**. The small byte differences are the stored symbol names, nothing else.

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"
cat > prov07_mx_fidelity.wls <<'WLSEOF'
(* Compare the equations the refactor produces with the author's own DumpSave output. *)
src  = "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/";
mine = "C:/Users/nsh/Documents/8-dim/";

Get[src <> "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLa.mx"];
srcELa = eLa; Clear[eLa];
Get[src <> "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLazt.mx"];
srcELazt = eLazt; Clear[eLazt];
Get[mine <> "claude-fable_Einstein-Rosen-2-Planes-eLa.mx"];
myELa = eLa; Clear[eLa];
Get[mine <> "claude-fable_Einstein-Rosen-2-Planes-eLazt.mx"];
myELazt = eLazt; Clear[eLazt];

cv = x0 > 0 && x4 > 0 && z > 0 && t > 0;
Print["lengths: src eLa   ", Length[srcELa],   "   mine ", Length[myELa]];
Print["lengths: src eLazt ", Length[srcELazt], "   mine ", Length[myELazt]];
Print["eLa   IDENTICAL (SameQ)  : ", srcELa   === myELa];
Print["eLa   difference          : ", Union@Flatten@Simplify[srcELa   - myELa,   cv]];
Print["eLazt IDENTICAL (SameQ)  : ", srcELazt === myELazt];
Print["eLazt difference          : ", Union@Flatten@Simplify[srcELazt - myELazt, cv]];
Print["--- sample: the author's eLa[[1]] ---"]; Print[InputForm[srcELa[[1]]]];
Print["--- sample: the refactor's eLa[[1]] ---"]; Print[InputForm[myELa[[1]]]];
WLSEOF
timeout 900 wolframscript -file prov07_mx_fidelity.wls 2>&1 | tee prov07_mx.log
```

Expected:

```
lengths: src eLa   16   mine 16
lengths: src eLazt 16   mine 16
eLa   IDENTICAL (SameQ)  : True
eLa   difference          : {0}
eLazt IDENTICAL (SameQ)  : True
eLazt difference          : {0}
--- sample: the author's eLa[[1]] ---
(-2*(2*M*f16[4][x0, x4] + Derivative[0, 1][f16[9]][x0, x4] + Derivative[1, 0][f16[12]][x0, x4]))/H
--- sample: the refactor's eLa[[1]] ---
(-2*(2*M*f16[4][x0, x4] + Derivative[0, 1][f16[9]][x0, x4] + Derivative[1, 0][f16[12]][x0, x4]))/H
```

The `.mx` files the refactor compares against were written by the author's own notebook, before
any of this work began. They cannot have been influenced by it. `SameQ` on both pairs is the
proof that the refactor's Lagrangian, its Euler–Lagrange operator, its chart change and its
sixteen field equations are the author's, unchanged.

To regenerate the refactor's two `.mx` files, run the notebook (section 12 writes them):

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"
timeout 3000 wolframscript -file run_from_nb.wls 2>&1 | tee run_from_nb.log
ls -la "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes-eLa.mx" \
       "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes-eLazt.mx"
```

## 2. What Part II computes, step by step

| step | object | what it is |
|---|---|---|
| 1 | `Psi16` | sixteen scalar functions `f16[0..15]` of `x0` and `x4`; the first eight are the type-1 split-octonion spinor, the last eight the type-2 spinor |
| 2 | `La[]` | `(1/H) Psi16^T sigma16 T16[alpha] d_alpha Psi16 + 2(M/H) Psi16^T sigma16 Psi16` |
| 3 | `eLa` | the sixteen Euler–Lagrange equations |
| 4 | `eLaCouplings` | the partition of the sixteen components into four blocks of four |
| 5 | `eLazt` | the same equations in the chart `z = 6 H x0`, `t = H x4`, scaled by `1/(2H)` |
| 6 | `coupledyZeqs` | four independent 4×4 first-order systems after relabelling `Z -> yZ` |
| 7 | Maple strings | the author's closed forms, pasted back verbatim and parsed |
| 8 | `ssyZ` | the closed forms as pure functions, **substituted back and verified** |
| 9 | bilinears | five invariants; requiring the norms to be light-cone constants fixes `C2 = -C1`, `C4 = -C3` |
| 10 | `Psi16ab`, `Psi16aa` | the two mass branches, `M -> H Mab Sqrt[C1 C3]` and `M -> H Sqrt[C1 C3]` |
| 11 | `vectorFormOfType1/2` | the two triality vectors, each normal to a 7-plane |
| 12 | `M6` | the intersection of the two 7-planes: a 6-plane with six free parameters |

## 3. An exact identity behind the Lagrangian that the original gets wrong in a scratch cell

Section 5 proves that `sigma16 . T16[A]` is **antisymmetric**. An antisymmetric bilinear form
vanishes on the diagonal, so

```
Psi16^T . sigma16 . T16[alpha] . Psi16  ==  0   identically
```

and therefore

```
Psi16^T . sigma16 . T16[alpha] . D[Psi16, x_alpha]
   ==  - D[Psi16, x_alpha]^T . sigma16 . T16[alpha] . Psi16
```

holds **exactly, with no boundary term at all**. The kinetic term is its own negative transpose,
which is what makes the variational problem well posed.

The original notebook probes this in a scratch cell but writes the conjugate form with `2 H M`
where the Lagrangian has `2 M/H`, and without the `1/H` on the kinetic term, so its difference
does not vanish. Written with matching coefficients the difference is exactly zero. The
refactored notebook states and verifies both the identity and the mismatch.

## 4. Complete commands to reproduce and display Part II

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable"
cat > prov07_physics.wls <<'WLSEOF'
(* Run the delivered notebook, then print the whole of Part II. *)

nbfile = "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb";
SetDirectory["C:/Users/nsh/Documents/8-dim"];
nb = Import[nbfile, "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
(* cells 1..90 = everything through section 14 *)
Block[{$Output = {}},
  Do[ReleaseHold[asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, 1, 90}]];

line[s_] := Print["\n================ ", s, " ================"];

line["THE WAVE FUNCTION"];
Print["Psi16 = ", InputForm[\[CapitalPsi]16]];
Print["type-1 half : ", InputForm[\[CapitalPsi]16upper]];
Print["type-2 half : ", InputForm[\[CapitalPsi]16lower]];

line["THE LAGRANGIAN"];
Print[InputForm[La[]]];

line["THE EXACT IDENTITIES BEHIND IT"];
Print["Psi16 . sigma16 . T16[alpha] . Psi16 == 0 for every alpha : ",
  Union@Table[Expand[Transpose[\[CapitalPsi]16] . \[Sigma]16 . T16[a-1] . \[CapitalPsi]16] === 0, {a,8}]];
Print["the kinetic term equals minus its transpose : ",
  Expand[Transpose[\[CapitalPsi]16] . \[Sigma]16 . Sum[T16[a-1] . D[\[CapitalPsi]16, X[[a]]], {a,8}]
   + Sum[D[Transpose[\[CapitalPsi]16], X[[a]]] . \[Sigma]16 . T16[a-1], {a,8}] . \[CapitalPsi]16] === 0];

line["THE SIXTEEN EULER-LAGRANGE EQUATIONS"];
Print[Column[eLa]];

line["THE COUPLING PATTERN"];
Print["blocks : ", eLaCouplings];
Print["block sizes : ", Length /@ eLaCouplings];
Print["they partition 0..15 : ", Sort[Flatten[eLaCouplings]] === Range[0,15]];

line["THE EQUATIONS IN THE (z,t) CHART"];
Print[Column[eLazt]];

line["THE FOUR 4x4 BLOCKS"];
Print[Column[coupledyZeqs]];
Print["each block is closed in its own four components : ",
  Table[Union@Cases[coupledyZeqs[[b]], yZ[n_Integer] :> n, Infinity, Heads -> True], {b,4}]];

line["WHAT DSolve DOES WITH THEM"];
Print[dsolveResults /. DSolve[a__] :> "returned unevaluated"];

line["THE MAPLE CLOSED FORMS, SUBSTITUTED BACK"];
Print["every one of the sixteen equations reduces to True : ",
  Union[Flatten[cfMapleCheck]] === {True}];
Print[Column[sYZvar]];

line["THE Z -> yZ TRANSFORMATION"];
Print["orthogonal, Transpose[S].S == ID16     : ", Transpose[almightyS] . almightyS === ID16];
Print["but NOT a Spin(8,8) transformation     : ",
  Transpose[almightyS] . \[Sigma]16 . almightyS =!= \[Sigma]16];
Print["and NOT a direct sum (it mixes type-1 with type-2) : ",
  caZ2 =!= ArrayFlatten[{{caZ2[[1;;8,1;;8]], 0}, {0, caZ2[[9;;16,9;;16]]}}]];

line["THE FIVE BILINEARS"];
Print["psi . sigma16 . psi == psi2.sigma.psi2 - psi1.sigma.psi1 : ",
  Simplify[psiSigma16psi - (psi2Sigmapsi2 - psi1Sigmapsi1), constraintVars] === 0];
Print[Column[{psiSigma16psi, psi1Sigmapsi1, psi2Sigmapsi2, psi2psi1, psi2Sigmapsi1}]];

line["THE BRANCH C2 = -C1, C4 = -C3"];
Print[Column[cfBilinearsOnBranch]];

line["THE TWO MASS BRANCHES"];
Print["Psi16ab : ", InputForm[\[CapitalPsi]16ab]];
Print["Psi16aa : ", InputForm[\[CapitalPsi]16aa]];

line["TRIALITY: SPINORS BECOME VECTORS"];
Print["vectorFormOfType1 : ", InputForm[vectorFormOfType1]];
Print["vectorFormOfType2 : ", InputForm[vectorFormOfType2]];
Print["the two bridges are mutually inverse : ", triVecToSpin . triSpinToVec === ID8];

line["THE TWO 7-PLANES AND THEIR INTERSECTION M6"];
Print["sevenPlane1 is annihilated by vectorFormOfType1 : ",
  Simplify[vectorFormOfType1 . sevenPlane1] === 0];
Print["sevenPlane2 is annihilated by vectorFormOfType2 : ",
  Simplify[vectorFormOfType2 . sevenPlane2] === 0];
Print["components M6 determines : ", First[sixPlane78][[All,1]]];
Print["free parameters remaining : ",
  Length[Complement[Array[zoct, 8], First[sixPlane78][[All,1]]]]];
Print["M6 = ", InputForm[M6]];

line["DONE"];
WLSEOF
timeout 3000 wolframscript -file prov07_physics.wls 2>&1 | tee prov07_physics.log
```

## 5. The headline results

```
================ THE COUPLING PATTERN ================
block sizes : {4, 4, 4, 4}
they partition 0..15 : True

================ WHAT DSolve DOES WITH THEM ================
{returned unevaluated, returned unevaluated, returned unevaluated, returned unevaluated}

================ THE MAPLE CLOSED FORMS, SUBSTITUTED BACK ================
every one of the sixteen equations reduces to True : True

================ THE Z -> yZ TRANSFORMATION ================
orthogonal, Transpose[S].S == ID16     : True
but NOT a Spin(8,8) transformation     : True
and NOT a direct sum (it mixes type-1 with type-2) : True

================ THE TWO 7-PLANES AND THEIR INTERSECTION M6 ================
sevenPlane1 is annihilated by vectorFormOfType1 : True
sevenPlane2 is annihilated by vectorFormOfType2 : True
components M6 determines : {zoct[7], zoct[8]}
free parameters remaining : 6
```

Three of those deserve comment.

**DSolve returns all four blocks unevaluated.** That is not a failure of the refactor; it is the
reason the author turned to Maple in the first place. The notebook runs the same four calls the
original does, wrapped in `TimeConstrained` so it cannot hang, and reports honestly what this
kernel actually does rather than assuming either outcome.

**The Maple closed forms are verified, not trusted.** The parser that converts them,
`ConvertMapleToMathematicaV2.wl`, prints on loading: "loaded successfully! BUT, WARNING: DO NOT
USE IF YOU WANT A CORRECT RESULT!". That warning does not matter here, because the parsed
solutions are substituted back into the four blocks and every one of the sixteen equations
reduces to `True`. The verification, not the parser, is what certifies them.

**The `Z -> yZ` relabelling is orthogonal but not `Spin(8,8)`, and not a direct sum.** It
preserves the Euclidean form but not `sigma16`, and it mixes the type-1 spinor with the type-2
spinor. That is the original notebook's own observation, reproduced and re-verified.

## 6. One index error in the first draft of this refactor, and how it was caught

The first draft of section 14 applied the two triality bridges the wrong way round:

```
vectorFormOfType2 = triSpinToVec . psi2                          (* WRONG *)
vectorFormOfType1 = eta4488 . (Transpose[psi1] . sigma . triVecToSpin)   (* WRONG *)
```

The correct assignments, which are what the original notebook uses, are

```
vectorFormOfType2 = triVecToSpin . psi2
vectorFormOfType1 = eta4488 . (Transpose[psi1] . sigma . triSpinToVec)
```

`triVecToSpin[[A,a]]` carries a vector row index and a spinor column index, so it converts a
column spinor to a vector under LEFT multiplication, while `triSpinToVec` does the same for a row
spinor under RIGHT multiplication. Exchanging them still type-checks, and — this is why it was
dangerous — it still passes every assertion attached to the resulting objects, because any
non-zero covector annihilates *some* 7-plane. It silently produces different 7-planes and a
different M6.

The error was found by an independent adversarial review of the refactor against the original's
extracted cells 754 and 756, where the author writes `F` with indices `a,A` and `A,a`
respectively. The notebook now pins the convention with an extra assertion that would fail if the
two were exchanged again:

```
cfAssert["vectorFormOfType2 == psi2 contracted on the SPINOR index of triVecToSpin",
  Simplify[vectorFormOfType2
     - Table[Sum[triVecToSpin[[A1, a1]] psi2[[a1]], {a1, 8}], {A1, 8}]] === ConstantArray[0, 8]];
```

## 7. What this proves

- The refactored Part II reproduces the author's Euler–Lagrange equations **identically**, in
  both charts, checked against `.mx` files the author saved before this work started.
- The decoupling into four blocks of four, the Maple closed forms, their verification, the
  bilinears, the two branch conditions and the two mass branches all reproduce.
- M6, the 6-plane in which the 3 generations of Einstein–Rosen 2-plane bridges live, is the
  intersection of two 7-planes and has exactly six free parameters.
- One index error introduced by the refactor was found and fixed, and the convention is now
  pinned by an assertion.
