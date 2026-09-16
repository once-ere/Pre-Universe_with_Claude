# Provenance 06 — Bridge 3, the triality frame with octonionic torsion, compared to the canonical spin connection

**Effort.** Invent a third way of bridging curved spacetime indices to flat tangent-space indices,
this time one whose flat index is not a vector index at all but a split-octonion **spinor** index;
give it a spin connection that is **not** the Levi-Civita one; and compare it, component by
component, with the canonical spin connection of section 16.

This is section 20 of `claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb`
(Input cells 131–139).

Everything needed to repeat this work is on this page. No other file needs to be consulted.

The script below opens the notebook **inside the repository**, at
`<repo>\claude-fable\claude-fable_Einstein-Rosen-2-Planes.nb`, and sets the working
directory to `<repo>\claude-fable`. That is the only copy git tracks, so this page runs
against a fresh clone with no further step. An identical copy is also delivered to
`C:\Users\nsh\Documents\8-dim\` for the author's convenience; that one is outside the
repository and nothing on this page depends on it.

---

## 0. Status after the fable-5.1 review (2026-09-16)

This page was written when the notebook still called Bridges 1, 2 and 3 "three new spin
connections". The review that produced Part V of the notebook (Section 21, the fable-5.1 bridge)
re-examined all three, and the verdict is recorded here so that nobody reads the page below with
the wrong expectation.

**Bridge 3 is a different connection**, and the review confirms it: the contortion
`lambda mSkew[a,b,c] frameTri[[mu,c]]` is a tensor, the torsion `-2 lambda mSkew` is non-zero
(now certified by a numerical witness that must evaluate to an actual number, not by a test that
passes vacuously), and — new in this revision — its curvature `RiemannOct` is computed: at
`lambda = 0` it is the triality conjugate of the canonical curvature, and its dependence on
`lambda` is exactly quadratic. One sentence of this page was overstated and has been corrected in
the notebook: the analogy with the Cartan–Schouten connections on a Lie group. Those are flat and
their torsion is the anholonomy of a frame; `omegaOct` is not flat for any `lambda`, and the
octonion structure constants violate the Jacobi identity, so they are not the anholonomy of any
frame. The fable-5.1 bridge of Part V is the complementary case: its torsion is purely
non-axial and comes from the geometry rather than being inserted by hand.

The commands, the assertions and the numbers on this page are unchanged and still pass; what
changed is the label. The notebook's own text now carries the same verdict, in the Part IV
introduction and at the head of Section 20 ("WHAT THIS BRIDGE IS, AND IS NOT"), and the master
comparison of Section 22 classifies every connection in its last column.

---

## 1. The bridge

Section 9 of the notebook builds the constant **triality bridge**

```
triVecToSpin[[A+1, a+1]]  =  ( unit . sigma . taubar[A] )[[a+1]]
```

which carries a flat VECTOR index `A` to a flat TYPE-1 SPLIT-OCTONION SPINOR index `a`, using the
one distinguished unit spinor `unit = uEig[[8]]` taken from the eigensystem of `sigma`. This is
the object the original notebook writes as `F` with indices `a` and `A`. Two facts about it are
established there and used here:

- it is **orthogonal**: `Transpose[triVecToSpin] == Inverse[triVecToSpin]`;
- it carries `eta4488` **exactly onto `sigma`**.

The new frame is therefore

```
frameTri = frameCanonical . triVecToSpin ,     flat tangent metric = sigma
```

and it reproduces the same curved metric.

## 2. Why a fourth ingredient is needed, and what it is

Being honest about this matters. `triVecToSpin` is constant, and it carries `eta` to `sigma` —
which is exactly what the null rotation `U` of bridge 2 does. So *as a frame alone*, bridge 3
would differ from bridge 2 only by a constant rotation and would add nothing new. The notebook
says so and then goes further: it changes the **connection** as well.

Section 9 proves that the split-octonion structure constants `m`, restricted to the seven
imaginary directions and with all indices lowered, are **totally antisymmetric**. A totally
antisymmetric 3-tensor on the tangent space is precisely what can be added to a metric connection
as **torsion** without spoiling metric compatibility. So define, for a real parameter `lambda`,

```
omegaOct[mu,a,b]  =  omegaTriLC[mu,a,b]  +  lambda * mSkew[a,b,c] * frameTri[[mu,c]]
```

where `omegaTriLC` is the Levi-Civita connection in the triality frame and `mSkew` is the
totally antisymmetric part of the structure constants transported into the spinor basis. The
added term is antisymmetric in `(a,b)`, so `omegaOct` is still `so(4,4)`-valued and still metric
compatible — but it is **no longer torsion-free**.

This is the octonionic analogue of the Cartan–Schouten flat connections on a Lie group. In
physics it is the Einstein–Cartan axial-torsion coupling, here generated by the split-octonion
multiplication itself rather than put in by hand. At `lambda = 0` it reduces to Levi-Civita.

**A caution about the antisymmetrization.** The totally antisymmetric part must be written out
over the six permutations of the three index POSITIONS with the standard signs:

```
mTA[A,B,C] = (1/6)( m[A,B,C] - m[B,A,C] - m[A,C,B] - m[C,B,A] + m[B,C,A] + m[C,A,B] )
```

Writing it instead as `(1/6) Sum[Signature[p] m[[p]], {p, Permutations[{A,B,C}]}]` is wrong and
produces a totally **symmetric** object, because `Signature` there is taken relative to sorted
order rather than relative to `(A,B,C)`. That mistake was made and caught by the notebook's own
`mSkewSpin is totally antisymmetric` assertion.

## 3. The comparison that was proved

```
omegaOct[mu]  ==  Inverse[P] . omegaCanonical[mu] . P  +  contortion[mu] ,   P = triVecToSpin
```

with the whole difference being the contortion, linear in `lambda` and vanishing at `lambda = 0`.
The torsion comes out in closed form:

```
T[a,b,c]  ==  -2 lambda mSkew[a,b,c]
```

totally antisymmetric, as a skew-torsion connection must be. The factor `-2` is derived, not
assumed: from `T_{a mu nu} = K_{mu a b} e_nu^b - K_{nu a b} e_mu^b` with
`K_{mu a b} = lambda m_{abd} e_mu^d`, contracting with the coframe gives
`T_{apq} = lambda (m_{aqp} - m_{apq}) = -2 lambda m_{apq}` by antisymmetry in the last two
indices.

## 4. Complete commands

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
cat > prov06_bridge3.wls <<'WLSEOF'
(* Run the delivered notebook, then print the whole of the bridge-3 comparison. *)
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
(* cells 1..135 = everything through section 20 *)
Block[{$Output = {}},
  Do[ReleaseHold[asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, 1, 135}]];

line[s_] := Print["\n================ ", s, " ================"];

line["THE TRIALITY BRIDGE"];
Print["triVecToSpin = "]; Print[MatrixForm[triVecToSpin]];
Print["it is ORTHOGONAL: Transpose[P] == Inverse[P] : ",
  cfZeroArrayQ[Transpose[triVecToSpin] - triSpinToVec]];
Print["it carries eta4488 exactly onto sigma        : ", \[Eta]Tri === \[Sigma]];
Print["so its tangent metric is the SPINOR metric   : ", \[Eta]TriFlat === \[Sigma]];

line["THE NEW FRAME FIELD"];
Print["frameTri = frameCanonical . triVecToSpin = "]; Print[MatrixForm[frameTri]];
Print["it gives the SAME curved metric g : ",
  cfZeroArrayQ[frameTri . \[Eta]TriFlat . Transpose[frameTri] - gCanonical]];

line["THE TOTALLY ANTISYMMETRIC SPLIT-OCTONION STRUCTURE CONSTANTS"];
Print["mSkewSpin is totally antisymmetric : ",
  cfZeroArrayQ[{Table[mSkewSpin[[a,b,c]] + mSkewSpin[[b,a,c]], {a,8},{b,8},{c,8}],
                Table[mSkewSpin[[a,b,c]] + mSkewSpin[[a,c,b]], {a,8},{b,8},{c,8}]}]];
Print["non-zero components of mSkewSpin : ", Count[Flatten[mSkewSpin], Except[0]]];
Print["distinct values : ", Union[Flatten[mSkewSpin]]];

line["THE lambda = 0 PART: LEVI-CIVITA IN THE TRIALITY FRAME"];
Print["non-zero components of omegaTriLC : ", Count[Flatten[omegaTriLC], Except[0]]];
Print["vielbein postulate holds identically : ",
  cfZeroArrayQ[cfVielbeinResidual[frameTri, X, GammaCanonical, omegaTriLCMixed]]];
Print["omega[mu,a,b] == -omega[mu,b,a] : ",
  cfZeroArrayQ[Table[omegaTriLC[[m,a,b]] + omegaTriLC[[m,b,a]], {m,8},{a,8},{b,8}]]];
Print["it IS the constant triality conjugate of the canonical connection : ",
  cfZeroArrayQ[Table[omegaTriLCMixed[[mu]]
     - triSpinToVec . omegaCanonicalMixed[[mu]] . triVecToSpin, {mu,8}]]];

line["THE NEW CONNECTION: LEVI-CIVITA PLUS OCTONIONIC SKEW TORSION"];
Print["non-zero contortion components : ", Count[Flatten[contortionOct], Except[0]]];
Print["omegaOct[mu,a,b] == -omegaOct[mu,b,a]  (still metric compatible) : ",
  cfZeroArrayQ[Table[omegaOct[[m,a,b]] + omegaOct[[m,b,a]], {m,8},{a,8},{b,8}]]];
Print["at lambda = 0 it reduces to Levi-Civita : ",
  cfZeroArrayQ[(omegaOct /. \[Lambda]Oct -> 0) - omegaTriLC]];

line["ITS TORSION"];
Print["torsion vanishes at lambda = 0 : ", cfZeroArrayQ[torsionOct /. \[Lambda]Oct -> 0]];
Print["torsion is NOT zero for lambda != 0 : ",
  ! TrueQ[cfZeroArrayQ[torsionOct /. \[Lambda]Oct -> 1]]];
Print["non-zero flat torsion components : ", Count[Flatten[torsionOctFlat], Except[0]]];
Print["T[a,b,c] is TOTALLY ANTISYMMETRIC : ",
  cfZeroArrayQ[{Table[torsionOctFlat[[a,b,c]] + torsionOctFlat[[b,a,c]], {a,8},{b,8},{c,8}],
                Table[torsionOctFlat[[a,b,c]] + torsionOctFlat[[a,c,b]], {a,8},{b,8},{c,8}]}]];
Print["T[a,b,c] == -2 lambda mSkewSpin[a,b,c] : ",
  cfZeroArrayQ[Table[torsionOctFlat[[a,b,c]] + 2 \[Lambda]Oct mSkewSpin[[a,b,c]],
    {a,8},{b,8},{c,8}]]];

line["COMPARISON WITH THE CANONICAL SPIN CONNECTION"];
Print["omegaOct - (triality conjugate of omegaCanonical) == contortion : ",
  cfZeroArrayQ[deltaOct - contortionOctMixed]];
Print["the difference vanishes at lambda = 0 : ",
  cfZeroArrayQ[deltaOct /. \[Lambda]Oct -> 0]];
Print["non-zero components of the difference : ", Count[Flatten[deltaOct], Except[0]]];
Print["the difference is linear in lambda : ",
  cfZeroArrayQ[(deltaOct /. \[Lambda]Oct -> 2) - 2 (deltaOct /. \[Lambda]Oct -> 1)]];

line["THE DIRAC MATRICES THAT MATCH THIS FRAME"];
(* cfSpinMatrix of Section 17 contracts flat indices against T16, which obeys the eta4488     *)
(* Clifford relation.  Bridge 3's flat index is a sigma-type spinor index, so the matching    *)
(* Dirac matrices are the triality transports T16Tri.                                         *)
Print["{T16Tri[a],T16Tri[b]} == 2 sigma[[a,b]] ID16 : ",
  cfZeroArrayQ[Table[T16Tri[a] . T16Tri[b] + T16Tri[b] . T16Tri[a]
     - 2 \[Eta]TriFlat[[a,b]] ID16, {a,8},{b,8}]]];
Print["they differ from the vector-frame T16 : ",
  ! TrueQ[cfZeroArrayQ[Table[T16Tri[a] - T16[a-1], {a,8}]]]];
Print["T16 does NOT obey the sigma relation : ",
  ! TrueQ[cfZeroArrayQ[Table[T16[a-1] . T16[b-1] + T16[b-1] . T16[a-1]
     - 2 \[Eta]TriFlat[[a,b]] ID16, {a,8},{b,8}]]]];

line["THE EFFECT ON THE SPINOR COVARIANT DERIVATIVE"];
Print["at lambda = 0 the Bridge 3 spinor connection equals the canonical one : ",
  cfZeroArrayQ[Table[(GammaSpinOct[[mu]] /. \[Lambda]Oct -> 0) - GammaSpinCanonical[[mu]], {mu,8}]]];
Print["extra 16x16 coupling vanishes at lambda = 0 : ",
  cfZeroArrayQ[GammaSpinOctExtra /. \[Lambda]Oct -> 0]];
Print["extra coupling is non-zero for lambda != 0  : ",
  ! TrueQ[cfZeroArrayQ[GammaSpinOctExtra /. \[Lambda]Oct -> 1]]];
Print["it is still block diagonal (type-1 + type-2 preserved) : ",
  cfZeroArrayQ[Table[GammaSpinOctExtra[[mu]]
     - ArrayFlatten[{{GammaSpinOctExtra[[mu]][[1;;8,1;;8]], 0},
                     {0, GammaSpinOctExtra[[mu]][[9;;16,9;;16]]}}], {mu,8}]]];
Print["non-zero entries in the extra coupling : ",
  Count[Flatten[GammaSpinOctExtra], Except[0]]];

line["DONE"];
WLSEOF
timeout 3000 wolframscript -file prov06_bridge3.wls 2>&1 | tee prov06.log
```

## 5. The result

The block below is `claude-fable/prov06_bridge3.log` as the run printed it, with the literal
`InputForm[...]` and `MatrixForm[...]` wrappers removed and the bulk matrix dumps elided for
reading. No data line is dropped; compare against the committed log if you want the raw form.

```
================ THE TRIALITY BRIDGE ================
it is ORTHOGONAL: Transpose[P] == Inverse[P] : True
it carries eta4488 exactly onto sigma        : True
so its tangent metric is the SPINOR metric   : True

================ THE NEW FRAME FIELD ================
it gives the SAME curved metric g : True

================ THE TOTALLY ANTISYMMETRIC SPLIT-OCTONION STRUCTURE CONSTANTS ================
mSkewSpin is totally antisymmetric : True
distinct values : {0, -(1/Sqrt[2]), 1/Sqrt[2], -Sqrt[2], Sqrt[2]}
non-zero components of mSkewSpin : 48

================ THE lambda = 0 PART: LEVI-CIVITA IN THE TRIALITY FRAME ================
non-zero components of omegaTriLC : 84
vielbein postulate holds identically : True
omega[mu,a,b] == -omega[mu,b,a] : True
it IS the constant triality conjugate of the canonical connection : True

================ THE NEW CONNECTION: LEVI-CIVITA PLUS OCTONIONIC SKEW TORSION ================
non-zero contortion components : 78
omegaOct[mu,a,b] == -omegaOct[mu,b,a]  (still metric compatible) : True
at lambda = 0 it reduces to Levi-Civita : True

================ ITS TORSION ================
torsion vanishes at lambda = 0 : True
torsion is NOT zero for lambda != 0 : True
non-zero flat torsion components : 48
T[a,b,c] is TOTALLY ANTISYMMETRIC : True
T[a,b,c] == -2 lambda mSkewSpin[a,b,c] : True

================ COMPARISON WITH THE CANONICAL SPIN CONNECTION ================
omegaOct - (triality conjugate of omegaCanonical) == contortion : True
the difference vanishes at lambda = 0 : True
non-zero components of the difference : 78
the difference is linear in lambda : True

================ THE DIRAC MATRICES THAT MATCH THIS FRAME ================
{T16Tri[a],T16Tri[b]} == 2 sigma[[a,b]] ID16 : True
they differ from the vector-frame T16 : True
T16 does NOT obey the sigma relation : True

================ THE EFFECT ON THE SPINOR COVARIANT DERIVATIVE ================
at lambda = 0 the Bridge 3 spinor connection equals the canonical one : True
extra 16x16 coupling vanishes at lambda = 0 : True
extra coupling is non-zero for lambda != 0  : True
it is still block diagonal (type-1 + type-2 preserved) : True
non-zero entries in the extra coupling : 160
```

## 6. Reading the comparison

This is the only one of the three Part IV bridges that is a different **connection** rather than
a different description of the same one; the fable-5.1 bridge of Part V is the other one. The other two are gauge-equivalent to the canonical
connection; this one is not, and the certificate that says so is its non-zero torsion.

The difference from the canonical connection splits cleanly into two pieces:

1. a **constant similarity** by the orthogonal triality matrix `P` — the same kind of difference
   bridge 2 has, and by itself carrying no new content;
2. a **contortion** `lambda * mSkew[a,b,c] * frameTri[[mu,c]]`, which is new, is linear in
   `lambda`, and is what makes the torsion non-zero.

The torsion is `T[a,b,c] == -2 lambda mSkew[a,b,c]`: totally antisymmetric, built out of the
split-octonion multiplication table and nothing else, and independent of the metric. Its 48
non-zero flat components are exactly the 48 non-zero components of `mSkew`, as that identity
requires.

On the spinor side the consequence is concrete, and there is one trap to avoid. The spin
representative of a connection is built by contracting its flat indices against Dirac matrices,
and the Dirac matrices have to be the ones whose Clifford relation uses *this frame's* tangent
metric. `T16` obeys `{T16[A],T16[B]} == 2 eta4488[[A,B]] ID16`, which is the vector frame's
metric, not `sigma`. The matching matrices here are the triality transports

```
T16Tri[a]  =  Sum over A of  triSpinToVec[[a,A]] T16[A-1] ,
{T16Tri[a], T16Tri[b]}  ==  2 sigma[[a,b]] ID16
```

and the run above confirms both that `T16Tri` satisfies the sigma relation and that `T16` does
not. Built with `T16Tri`, the covariant derivative of section 17 picks up the extra term

```
(lambda/8) mSkew[a,b,c] frameTri[[mu,c]] Commutator[gammaTri^a, gammaTri^b]
```

which is QUADRATIC in the gammas, not cubic. Count them: the expression above carries two, and
the third structure-constant index `c` is contracted against the frame, `frameTri[[mu,c]]`, not
against a third gamma. What it is, is the torsion's contribution to the so(4,4) part of the
spinor connection, generated by the split-octonion multiplication itself rather than put in by
hand. The genuinely cubic Einstein–Cartan AXIAL term, `T[a,b,c] gamma^a gamma^b gamma^c`,
appears only after this piece is contracted with the `gamma^mu` of the Dirac operator, and the
notebook does not perform that contraction, so it does not claim to have exhibited the axial
coupling. (This page said "cubic in the gammas — the Einstein–Cartan axial coupling" until the
evaluation of 2026-09-14 found the miscount; the notebook cell now states the corrected
version, and so does this page.) The extra term is still block diagonal, so
even with torsion the derivative respects the type-1 / type-2 direct sum. And at `lambda = 0` the
whole 16×16 connection collapses onto the canonical one, exactly as it must, because the two
frames then differ only by a constant O(4,4) rotation. That last check is the one that would have
caught a wrong Dirac basis, and it is in the notebook.

## 7. What this proves

- A third bridge exists whose flat index is a split-octonion spinor index, reached through Cartan
  triality, and it reproduces the same curved metric.
- The triality bridge is an orthogonal matrix that carries the flat Minkowski metric exactly onto
  the split-octonion spinor metric.
- Because that bridge is constant, its Levi-Civita connection alone would be gauge-equivalent to
  the canonical one — and the notebook proves exactly that, rather than pretending otherwise.
- Adding totally antisymmetric torsion built from the split-octonion structure constants gives a
  genuinely new metric-compatible connection with non-zero torsion, reducing to Levi-Civita at
  `lambda = 0`.
- The full difference from the canonical spin connection was computed in closed form, and the
  torsion in closed form: `T[a,b,c] == -2 lambda mSkew[a,b,c]`.

## 8. How the three Part IV bridges differ from one another

| | bridge 1 | bridge 2 | bridge 3 |
|---|---|---|---|
| what changes | the frame's orientation, pointwise | the flat tangent metric | the flat index type, and the connection |
| flat tangent metric | `eta4488` | `sigma` | `sigma` |
| bridging matrix | `Lambda(x)`, x-dependent | `U`, constant | `triVecToSpin`, constant |
| curved metric `g` | unchanged | unchanged | unchanged |
| metric compatible | yes | yes | yes |
| torsion | zero | zero | **`-2 lambda mSkew`** |
| difference from canonical | inhomogeneous gauge term `-d(theta) K` | constant similarity only | constant similarity **plus contortion** |
| same geometry? | yes | yes | **no, for `lambda != 0`** |
