# Provenance 05 — New bridge 2, the null (light-cone) frame, compared to the canonical spin connection

**Effort.** Invent a second, different way of bridging curved spacetime indices to flat
tangent-space indices — this time by changing the flat tangent metric rather than the frame's
orientation — derive its spin connection from the same vielbein postulate, and compare it
component by component with the canonical one.

This is section 19 of `claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb`
(Input cells 123–127).

Everything needed to repeat this work is on this page. No other file needs to be consulted.

The script below opens the notebook **inside the repository**, at
`<repo>\claude-fable\claude-fable_Einstein-Rosen-2-Planes.nb`, and sets the working
directory to `<repo>\claude-fable`. That is the only copy git tracks, so this page runs
against a fresh clone with no further step. An identical copy is also delivered to
`C:\Users\nsh\Documents\8-dim\` for the author's convenience; that one is outside the
repository and nothing on this page depends on it.

---

## 1. The new bridge

Pair the eight flat directions as `(0,4)`, `(1,5)`, `(2,6)`, `(3,7)` — one spacelike with one
timelike in each pair — and replace each pair by its two **null** combinations. The constant
matrix that does this is

```
U = (1/Sqrt[2]) ArrayFlatten[{{ID4, ID4}, {ID4, -ID4}}] ,   U == Transpose[U] ,   U . U == ID8
```

Under `U` the flat metric becomes

```
etaNull = Transpose[U] . eta4488 . U
```

and the frame is

```
frameNull = frameCanonical . U
```

which reproduces the same curved metric because `U . etaNull . Transpose[U] == eta4488`.

This is the frame adapted to Einstein and Rosen's own picture: each pair of coordinates is split
into an advanced and a retarded null direction — exactly the `(ztadv, ztret)` and
`(xiadv, xiret)` splittings that the original notebook performs by hand in its two
"retarded, advanced" sections. In this frame the two "sheets" joined at the bridge are the two
null halves of each pair.

## 2. The result that makes this bridge interesting

```
etaNull  ==  sigma
```

**exactly**. The null tangent metric of this 4+4 geometry *is* the split-octonion spinor metric
`sigma = ArrayFlatten[{{0,ID4},{ID4,0}}]` that the original notebook uses throughout for its
type-1 and type-2 spinors. The light-cone structure of the spacetime and the spinor pairing of
the split octonions are the same structure. `etaNull` has a **zero diagonal**, which is the
statement that all eight frame directions are null.

## 3. The comparison that was proved

Because `U` is **constant**, the general transformation law

```
omegaNew[mu] == M omegaOld[mu] Inverse[M] - D[M,x_mu] Inverse[M] ,   M = Transpose[L]
```

loses its second term entirely. With `L = U` and `U == Transpose[U] == Inverse[U]` this is

```
omegaNull[mu]  ==  U . omegaCanonical[mu] . U        exactly, with no inhomogeneous term
```

As in bridge 1, the notebook does not assume this: `omegaNull` is derived independently by the
same solver `cfSpinConnection` from the vielbein postulate with `etaNull` in place of `eta4488`,
and the formula is then verified against the derived result.

## 4. Complete commands

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
cat > prov05_bridge2.wls <<'WLSEOF'
(* Run the delivered notebook, then print the whole of the bridge-2 comparison. *)
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
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
(* cells 1..127 = everything through section 19 *)
Block[{$Output = {}},
  Do[ReleaseHold[asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, 1, 127}]];

line[s_] := Print["\n================ ", s, " ================"];

line["THE CONSTANT NULL ROTATION U"];
Print["U = "]; Print[MatrixForm[cfU]];
Print["U == Transpose[U]  : ", cfU === Transpose[cfU]];
Print["U . U == ID8       : ", cfZeroArrayQ[cfU . cfU - ID8]];
Print["U is constant      : ", cfZeroArrayQ[Table[D[cfU, X[[mu]]], {mu, 8}]]];

line["THE NEW FLAT TANGENT METRIC"];
Print["etaNull = Transpose[U] . eta4488 . U = "]; Print[MatrixForm[\[Eta]Null]];
Print["etaNull == sigma, the split-octonion SPINOR metric : ", \[Eta]Null === \[Sigma]];
Print["diagonal of etaNull (all frame directions are null) : ", Diagonal[\[Eta]Null]];
Print["etaNull . etaNull == ID8 : ", \[Eta]Null . \[Eta]Null === ID8];

line["THE NEW FRAME FIELD"];
Print["frameNull = frameCanonical . U = "]; Print[MatrixForm[frameNull]];
Print["it gives the SAME curved metric g : ",
  cfZeroArrayQ[frameNull . \[Eta]Null . Transpose[frameNull] - gCanonical]];

line["THE NEW SPIN CONNECTION"];
Print["non-zero components of omegaNull : ", Count[Flatten[omegaNull], Except[0]]];
Print["   (canonical had ", Count[Flatten[omegaCanonical], Except[0]], ")"];
Print["vielbein postulate holds identically : ",
  cfZeroArrayQ[cfVielbeinResidual[frameNull, X, GammaCanonical, omegaNullMixed]]];
Print["omega[mu,a,b] == -omega[mu,b,a] with indices lowered by etaNull : ",
  cfZeroArrayQ[Table[omegaNull[[m,a,b]] + omegaNull[[m,b,a]], {m,8},{a,8},{b,8}]]];
Print["torsion vanishes : ", cfZeroArrayQ[cfTorsion[frameNull, X, omegaNullMixed]]];

line["COMPARISON WITH THE CANONICAL SPIN CONNECTION"];
Print["omegaNull == U . omegaCanonical . U  exactly : ",
  cfZeroArrayQ[Table[omegaNullMixed[[mu]] - cfU . omegaCanonicalMixed[[mu]] . cfU, {mu,8}]]];
Print["the inhomogeneous gauge term D[U,x_mu].Inverse[U] is identically ZERO : ",
  cfZeroArrayQ[Table[D[cfU, X[[mu]]], {mu, 8}]]];
Print["so the difference Delta2 has ", Count[Flatten[deltaNull], Except[0]],
      " non-zero components; its distinct entries are ", Union[Flatten[deltaNull]]];

line["THE NON-ZERO COMPONENTS OF omegaNull"];
Scan[Print["  omegaNull[", #[[1]]-1, ";", #[[2]]-1, ",", #[[3]]-1, "] = ",
     InputForm[omegaNull[[Sequence @@ #]]]] &,
  Select[Flatten[Table[{m,a,b},{m,8},{a,8},{b,8}],2], omegaNull[[Sequence @@ #]] =!= 0 &]];

line["THE GEOMETRY IS THE SAME: CURVATURE AND RICCI SCALAR"];
Print["R_null == U R_canonical U : ",
  cfZeroArrayQ[Table[RiemannNull[[mu,nu]] - cfU . RiemannCanonical[[mu,nu]] . cfU,
    {mu,8},{nu,8}]]];
Print["Ricci scalar, canonical : ", InputForm[RicciScalarCanonical]];
Print["Ricci scalar, bridge 2  : ", InputForm[RicciScalarNull]];
Print["they are equal          : ", cfZeroQ[RicciScalarNull - RicciScalarCanonical]];

line["DONE"];
WLSEOF
timeout 3000 wolframscript -file prov05_bridge2.wls 2>&1 | tee prov05.log
```

## 5. The result

```
================ THE CONSTANT NULL ROTATION U ================
U == Transpose[U]  : True
U . U == ID8       : True
U is constant      : True

================ THE NEW FLAT TANGENT METRIC ================
etaNull == sigma, the split-octonion SPINOR metric : True
diagonal of etaNull (all frame directions are null) : {0, 0, 0, 0, 0, 0, 0, 0}
etaNull . etaNull == ID8 : True

================ THE NEW FRAME FIELD ================
it gives the SAME curved metric g : True

================ THE NEW SPIN CONNECTION ================
non-zero components of omegaNull : 48
   (canonical had 24)
vielbein postulate holds identically : True
omega[mu,a,b] == -omega[mu,b,a] with indices lowered by etaNull : True
torsion vanishes : True

================ COMPARISON WITH THE CANONICAL SPIN CONNECTION ================
omegaNull == U . omegaCanonical . U  exactly : True
the inhomogeneous gauge term D[U,x_mu].Inverse[U] is identically ZERO : True
so the difference Delta2 has 0 non-zero components; its distinct entries are {0}

================ THE GEOMETRY IS THE SAME: CURVATURE AND RICCI SCALAR ================
R_null == U R_canonical U : True
Ricci scalar, canonical : -3*H^2*((55 + 7*Cos[12*H*x0])*Cot[6*H*x0]^2*Csc[6*H*x0]^2 - 2*Derivative[1][a4][H*x4]^2)
Ricci scalar, bridge 2  : -3*H^2*((55 + 7*Cos[12*H*x0])*Cot[6*H*x0]^2*Csc[6*H*x0]^2 - 2*Derivative[1][a4][H*x4]^2)
they are equal          : True
```

## 6. Reading the comparison

**The difference from the canonical connection is exactly zero** once the constant similarity by
`U` is accounted for. That is the sharpest possible contrast with bridge 1: there the difference
was a non-zero pure-gauge term, four components of `-d(rapidity)`; here the corresponding term
`D[U, x_mu] . Inverse[U]` vanishes identically because `U` does not depend on position. The two
bridges therefore isolate the two halves of the transformation law — the homogeneous part and the
inhomogeneous part — one each.

The component count rises from 24 to 48. That is not new information appearing from nowhere: the
null rotation mixes each pair of flat directions, so a single canonical component
`omega[mu; 0, j]` becomes a pair of null-frame components. The content is identical, spread over
twice as many slots, and the exact statement `omegaNull == U omegaCanonical U` says so.

Set against the physics of the original notebook, this bridge is the one that makes the
Einstein–Rosen structure manifest. Einstein and Rosen describe "two congruent parts or sheets,
corresponding to u > 0 and u < 0, joined by a hyperplane in which g vanishes". In the null frame
each of the four coordinate pairs is resolved into exactly such a pair of sheets, and the metric
that pairs them is `sigma` — the very metric the notebook uses to pair the type-1 spinor with the
type-2 spinor. That is not a coincidence introduced here; it is forced, and it is proved by the
single line `etaNull === sigma : True`.

## 7. What this proves

- A second genuinely different bridge exists: it changes the flat tangent metric, from
  `diag(1,1,1,1,-1,-1,-1,-1)` to the split form with a zero diagonal, while leaving the curved
  metric untouched.
- The split form it produces is exactly the split-octonion spinor metric `sigma`.
- Its spin connection, derived independently, is `so(4,4)`-valued with respect to `etaNull` and
  torsion-free.
- It differs from the canonical spin connection by a **constant similarity only**, with the
  inhomogeneous gauge term identically zero — verified, not assumed.
- The curvature is the constant conjugate and the Ricci scalar is identical, so this too is the
  same geometry.
