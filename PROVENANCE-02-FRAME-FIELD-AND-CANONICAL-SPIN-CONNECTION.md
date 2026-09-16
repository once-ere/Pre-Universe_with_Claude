# Provenance 02 — The frame field and the canonical spin connection

**Effort.** Make explicit the local flat 4+4 Minkowski coordinate system that exists at every
point of the curved 4+4 spacetime; state the bridge between the curved metric and the flat
Minkowski metric through a pseudo-orthogonal frame field; and compute the canonical spin
connection from the zero-torsion vielbein postulate.

This covers Steps 1 and 2 of the standard procedure, i.e. sections 15 and 16 of
`claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb` (Input cells 91–110).

Everything needed to repeat this work is on this page. No other file needs to be consulted.

The script below opens the notebook **inside the repository**, at
`<repo>\claude-fable\claude-fable_Einstein-Rosen-2-Planes.nb`, and sets the working
directory to `<repo>\claude-fable`. That is the only copy git tracks, so this page runs
against a fresh clone with no further step. An identical copy is also delivered to
`C:\Users\nsh\Documents\8-dim\` for the author's convenience; that one is outside the
repository and nothing on this page depends on it.

---

## 1. The objects and the conventions

| symbol in the prompt | symbol in the notebook | Wolfram array |
|---|---|---|
| curved metric `g_{mu nu}` | `gCanonical` | `gCanonical[[mu,nu]]`, 8×8 |
| flat Minkowski metric `eta_{ab}` | `η4488` | `DiagonalMatrix[{1,1,1,1,-1,-1,-1,-1}]` |
| frame field `e_mu^a` | `frameCanonical` | `frameCanonical[[mu,a]]`, curved row, flat column |
| inverse frame `e_a^mu` | `coframeCanonical` | `Inverse[frameCanonical]`, `coframeCanonical[[a,mu]]` |
| spin connection `omega_{mu a b}` | `omegaCanonical` | `omegaCanonical[[mu,a,b]]`, 8×8×8 |
| `omega_mu{}^a{}_b` | `omegaCanonicalMixed` | `omegaCanonicalMixed[[mu,a,b]]` |

Greek indices are curved and run 0..7; Latin indices are flat and run 0..7. Wolfram array
positions are 1-based, so the flat index `A` sits at position `A+1`.

With the row/column convention above, the bridge

```
[d]   g_{mu nu} == e_mu^a eta_{ab} e_nu^b
```

is the single matrix statement

```
gCanonical == frameCanonical . η4488 . Transpose[frameCanonical]
```

A **vielbein** here is simply an 8-dimensional vierbein, i.e. an 8-dimensional frame field.

## 2. The canonical frame field

This is the diagonal matrix that the original notebook records (its cells 546 and 555) as the
value of the symbol it writes as `gtrye` with indices `alpha` and `(A)`:

```
frameCanonical = DiagonalMatrix[{Tan[6 H x0], q, q, q, 1, p, p, p}]

    q = Exp[-a4[H x4]] / Sin[6 H x0]^(1/6)
    p = Exp[+a4[H x4]] / Sin[6 H x0]^(1/6)
```

so the line element is

```
ds^2 =  Tan[6 H x0]^2 dx0^2
      + q^2 (dx1^2 + dx2^2 + dx3^2)
      -      dx4^2
      - p^2 (dx5^2 + dx6^2 + dx7^2)
```

**`a4` is never defined in the original notebook.** It is a free differentiable scalar function of
`H x4`. No value is invented for it here; every result below holds for arbitrary `a4`. The
notebook says so out loud when section 15 runs.

The two exponentials are reciprocal: `q p = 1/Sin[6 H x0]^(1/3)`. The three ordinary 3-space
directions contract exactly as fast as the three superluminal deflating directions expand.

## 3. The vielbein postulate, and how omega is obtained from it

```
D[e[nu,a], x[mu]] - Gamma[rho,mu,nu] e[rho,a] + omegaMixed[mu,a,b] e[nu,b]  ==  0
```

Contracting the free index `nu` with the coframe gives the closed form the notebook uses:

```
omegaMixed[mu,a,c] = Sum over nu of
    ( Sum over rho of Gamma[rho,mu,nu] e[rho,a]  -  D[e[nu,a], x[mu]] ) * coframe[[c,nu]]
```

and lowering the first flat index with `eta` gives `omega[mu,a,b]`, which must come out
**antisymmetric in a and b**. That antisymmetry is not imposed anywhere; it is a consequence of
metric compatibility and it is checked.

The generalized Christoffel symbols are the ordinary ones of `g`:

```
Gamma[rho,mu,nu] = (1/2) g^{rho s} ( d_mu g_{s nu} + d_nu g_{s mu} - d_s g_{mu nu} )
```

## 4. Complete commands to reproduce and display the result

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
cat > prov02_frame_and_connection.wls <<'WLSEOF'
(* Run the delivered notebook, then print everything about the frame field and the canonical
   spin connection.  Self-contained: it needs only the .nb and the two helper .wl packages. *)
(* --- self-locating, so this script works from a clone at any path -------------------------- *)
(* $InputFileName is the path this file was invoked with; ExpandFileName makes it absolute even *)
(* when wolframscript was given a relative path.  cfHere is this script's own directory,        *)
(* i.e. <repo>/claude-fable, and cfRepo is the repository root.                                 *)
cfHere = DirectoryName[ExpandFileName[$InputFileName]];
cfRepo = ParentDirectory[cfHere];
cfNB   = FileNameJoin[{cfHere, "claude-fable_Einstein-Rosen-2-Planes.nb"}];

nbfile = cfNB;
SetDirectory[cfHere];
nb = Import[nbfile, "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
Print["notebook Input cells: ", Length[inputs]];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
(* evaluate cells 1..110, i.e. everything through section 16 *)
Block[{$Output = {}},
  Do[ReleaseHold[asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, 1, 110}]];

line[s_] := Print["\n================ ", s, " ================"];

line["THE FRAME FIELD  e[mu,a]"];
Print[MatrixForm[frameCanonical]];

line["THE INVERSE FRAME  e_a[mu]"];
Print[MatrixForm[coframeCanonical]];

line["THE CURVED METRIC  g[mu,nu]"];
Print[MatrixForm[gCanonical]];
Print["diagonal: ", InputForm[Diagonal[gCanonical]]];
Print["Det[g]  : ", InputForm[detgCanonical]];
Print["Sqrt[Abs[Det[g]]] : ", InputForm[sqrtDetgCanonical]];

line["[d] THE BRIDGE  g == e . eta . Transpose[e]"];
Print["residual (DEFINITION, cannot fail): ",
  cfZeroArrayQ[gCanonical - frameCanonical . \[Eta]4488 . Transpose[frameCanonical]]];
Print["g equals the STATED line element (has content): ",
  cfZeroArrayQ[gCanonical - DiagonalMatrix[{Tan[6 H x0]^2,
     cfQminus^2, cfQminus^2, cfQminus^2, -1, -cfQplus^2, -cfQplus^2, -cfQplus^2}]]];
Print["Diagonal[g] == Diagonal[eta] * Diagonal[frame]^2, exactly: ",
  cfZeroArrayQ[Diagonal[gCanonical] - Diagonal[\[Eta]4488] Diagonal[frameCanonical]^2]];

line["THE FLAT MINKOWSKI METRIC  eta[a,b]"];
Print[MatrixForm[\[Eta]4488]];
Print["eta . eta == ID8 ? ", \[Eta]4488 . \[Eta]4488 === ID8];
Print["signature : ", Diagonal[\[Eta]4488]];

line["NON-ZERO CHRISTOFFEL SYMBOLS  (37 of 512)"];
Print["count: ", Count[Flatten[GammaCanonical], Except[0]]];
Scan[Print["  Gamma[", #[[1]]-1, ";", #[[2]]-1, ",", #[[3]]-1, "] = ",
     InputForm[GammaCanonical[[Sequence @@ #]]]] &,
  Select[Flatten[Table[{r,m,p},{r,8},{m,8},{p,8}],2],
     GammaCanonical[[Sequence @@ #]] =!= 0 &]];

line["NON-ZERO CANONICAL SPIN-CONNECTION COMPONENTS  omega[mu,a,b]  (24 of 512)"];
Print["count: ", Count[Flatten[omegaCanonical], Except[0]]];
Scan[Print["  omega[", #[[1]]-1, ";", #[[2]]-1, ",", #[[3]]-1, "] = ",
     InputForm[omegaCanonical[[Sequence @@ #]]]] &,
  Select[Flatten[Table[{m,a,b},{m,8},{a,8},{b,8}],2],
     omegaCanonical[[Sequence @@ #]] =!= 0 &]];

line["THE CERTIFICATES, AND WHAT EACH ONE IS WORTH"];
Print["[solver regression] vielbein postulate residual is zero : ",
  cfZeroArrayQ[cfVielbeinResidual[frameCanonical, X, GammaCanonical, omegaCanonicalMixed]]];
Print["[structural]        torsion vanishes                    : ",
  cfZeroArrayQ[cfTorsion[frameCanonical, X, omegaCanonicalMixed]]];
Print["[structural]        Gamma symmetric in its lower indices : ",
  cfZeroArrayQ[Table[GammaCanonical[[r,m,p]] - GammaCanonical[[r,p,m]], {r,8},{m,8},{p,8}]]];
Print["[HAS CONTENT]       omega[mu,a,b] == -omega[mu,b,a]      : ",
  cfZeroArrayQ[Table[omegaCanonical[[m,a,b]] + omegaCanonical[[m,b,a]], {m,8},{a,8},{b,8}]]];
Print["[INDEPENDENT]       frame-only derivation reproduces omegaCanonical : ",
  cfZeroArrayQ[Table[Sum[omegaFromFrameUp[[mu,a,c]] \[Eta]4488[[c,b]], {c,8}]
     - omegaCanonicalMixed[[mu,a,b]], {mu,8},{a,8},{b,8}]]];

line["CURVATURE"];
Print["non-zero curvature components : ", Count[Flatten[RiemannCanonical], Except[0]]];
Print["Ricci scalar                  : ", InputForm[RicciScalarCanonical]];

line["DONE"];
WLSEOF
timeout 3000 wolframscript -file prov02_frame_and_connection.wls 2>&1 | tee prov02.log
```

## 5. The result

```
================ THE CURVED METRIC  g[mu,nu] ================
diagonal: {Tan[6*H*x0]^2,
           1/(E^(2*a4[H*x4])*Sin[6*H*x0]^(1/3)),
           1/(E^(2*a4[H*x4])*Sin[6*H*x0]^(1/3)),
           1/(E^(2*a4[H*x4])*Sin[6*H*x0]^(1/3)),
           -1,
           -(E^(2*a4[H*x4])/Sin[6*H*x0]^(1/3)),
           -(E^(2*a4[H*x4])/Sin[6*H*x0]^(1/3)),
           -(E^(2*a4[H*x4])/Sin[6*H*x0]^(1/3))}
Det[g]  : Sec[6*H*x0]^2
Sqrt[Abs[Det[g]]] : Abs[Sec[6*H*x0]]
```

`Det[g]` is positive, as it must be for signature (4,4): there is an even number of negative
eigenvalues.

### The 37 non-zero Christoffel symbols

```
  Gamma[0;0,0] = 12*H*Csc[12*H*x0]
  Gamma[0;1,1] = Gamma[0;2,2] = Gamma[0;3,3] =  (H*Cos[6*H*x0]^3)/(E^(2*a4[H*x4])*Sin[6*H*x0]^(10/3))
  Gamma[0;5,5] = Gamma[0;6,6] = Gamma[0;7,7] = -(E^(2*a4[H*x4])*H*Cos[6*H*x0]^3)/Sin[6*H*x0]^(10/3)
  Gamma[j;0,j] = Gamma[j;j,0] = -H*Cot[6*H*x0]                     j = 1,2,3
  Gamma[j;j,4] = Gamma[j;4,j] = -H*a4'[H*x4]                       j = 1,2,3
  Gamma[4;j,j] = -(H*a4'[H*x4])/(E^(2*a4[H*x4])*Sin[6*H*x0]^(1/3)) j = 1,2,3
  Gamma[4;k,k] = -(E^(2*a4[H*x4])*H*a4'[H*x4])/Sin[6*H*x0]^(1/3)   k = 5,6,7
  Gamma[k;0,k] = Gamma[k;k,0] = -H*Cot[6*H*x0]                     k = 5,6,7
  Gamma[k;4,k] = Gamma[k;k,4] =  H*a4'[H*x4]                       k = 5,6,7
```

### The 24 non-zero canonical spin-connection components

Write `c = Cos[6 H x0]`, `s = Sin[6 H x0]`, `A = a4[H x4]`, `A' = a4'[H x4]`. Then, for
`j = 1,2,3` (the ordinary 3-space directions) and `k = 5,6,7` (the deflating directions):

| component | value |
|---|---|
| `omega[j; 0,j] = -omega[j; j,0]` | `H c^2 / (E^A s^(13/6))` |
| `omega[j; 4,j] = -omega[j; j,4]` | `H A' / (E^A s^(1/6))` |
| `omega[k; 0,k] = -omega[k; k,0]` | `-E^A H c^2 / s^(13/6)` |
| `omega[k; 4,k] = -omega[k; k,4]` | `E^A H A' / s^(1/6)` |

Every component is antisymmetric in its two flat indices, which is the printed verification
`omega[mu,a,b] == -omega[mu,b,a] : True`. The connection is non-zero only in the six
directions `mu = 1,2,3,5,6,7`, and in each of those only the two flat planes `(0,mu)` and
`(4,mu)` are excited: the geometry rotates each spatial frame axis against the hidden-space
direction and boosts it against time, and does nothing else.

### The certificates, and what each one is worth

```
[solver regression] vielbein postulate residual is zero : True
[structural]        torsion vanishes                    : True
[structural]        Gamma symmetric in its lower indices : True
[HAS CONTENT]       omega[mu,a,b] == -omega[mu,b,a]      : True
[INDEPENDENT]       frame-only derivation reproduces omegaCanonical : True
```

It is worth being exact about what each of these establishes, because two of them are weaker
than they look.

- The **vielbein-postulate residual** is an algebraic identity of the solver, not a fact about
  this geometry. `cfSpinConnection` contracts the postulate with `Inverse[frame]` and
  `cfVielbeinResidual` contracts it back with `frame`; the two contractions cancel for any
  affine connection and any invertible frame. It is a regression test of the code, no more.
- **Torsion vanishing** is nearly as weak. Given a zero residual it reduces to the symmetry of
  the Christoffel symbols in their lower indices, and that symmetry is itself structural:
  swapping the two lower indices in the Christoffel formula reproduces the same expression
  whenever the metric is symmetric.
- **Antisymmetry of `omega` in its two flat indices** does have content. Nothing in the solver
  imposes it; it holds only because the affine connection fed in really is the Levi-Civita
  connection of the metric the frame builds. A wrong Christoffel symbol would break it.
- The **independent derivation** is the strongest of the four. Section 16 re-derives the spin
  connection from the frame alone, by the standard closed formula in terms of the anholonomy of
  the coframe, which never mentions the Christoffel symbols or the metric:

  ```
  omega_mu^{ab} = (1/2) e^{a nu}  ( d_mu e_nu^b  - d_nu e_mu^b  )
                - (1/2) e^{b nu}  ( d_mu e_nu^a  - d_nu e_mu^a  )
                - (1/2) e^{a rho} e^{b sig} ( d_rho e_sig^c - d_sig e_rho^c ) eta_{cd} e_mu^d
  ```

  It reproduces `omegaCanonical` exactly. If either `cfChristoffel` or `cfSpinConnection` had an
  index slot wrong, this comparison would fail.

### Curvature

```
non-zero curvature components : 156
Ricci scalar                  : -3*H^2*((55 + 7*Cos[12*H*x0])*Cot[6*H*x0]^2*Csc[6*H*x0]^2 - 2*Derivative[1][a4][H*x4]^2)
```

The Ricci scalar depends on `a4` only through `a4'[H x4]^2`, which is why it is the right
invariant to compare the bridges of Parts IV and V against: it is a single scalar that no change of
frame can alter. An equivalent form, which `Simplify` sometimes prefers, is
`-6 H^2 (24 Cot[6 H x0]^2 + 31 Cot[6 H x0]^4 - a4'[H x4]^2)`; the two differ only in surface
form.

## 6. What this proves

- A local flat 4+4 Minkowski coordinate system exists at every point, and `frameCanonical`
  installs it. State that carefully: in this notebook `g` is **defined** as
  `frame . eta . Transpose[frame]`, so asserting the bridge `[d]` restates the definition and
  cannot fail. The notebook labels that assertion `[definition]` for exactly this reason. What
  carries content, and is asserted separately, is that the frame the ORIGINAL notebook recorded
  reproduces the line element stated above, that `Diagonal[g] == Diagonal[eta] * Diagonal[frame]^2`
  exactly, which is Sylvester's law made explicit, and that the signature is (4,4) given that
  `a4` is real-valued and `0 < 6 H x0 < Pi/2`. A mistranscribed frame entry would fail those and
  pass the tautology.
- The frame is pseudo-orthogonal with respect to `eta4488` of signature (4,4), not orthogonal:
  the tangent metric has four plus signs and four minus signs.
- The canonical spin connection follows from the zero-torsion vielbein postulate alone, with no
  extra input, and it comes out `so(4,4)`-valued (antisymmetric in its two flat indices) and
  torsion-free — both verified rather than assumed.

## 7. Reading the same result inside the notebook

Open `claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb` in Mathematica and
evaluate sections 1 through 16. The grid produced by

```
cfShowConnection[omegaCanonical, "omega"]
```

is the table of the 24 non-zero components above, and

```
cfAssertSummary[]
```

at the very end of the notebook lists every identity with its verdict.
