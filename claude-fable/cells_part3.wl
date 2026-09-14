(* ::CELLMANIFEST-PART:: 3 *)

(* ::Title:: *)
PART II  --  The wave function of the un-universe, its field equations, and the 3 generations

(* ::Section:: *)
10.  Housekeeping: where this notebook lives, and the two helper packages

(* ::Text:: *)
The original notebook calls NotebookFileName[] directly.  That works in the Wolfram front end
but returns $Failed in a headless kernel, which would stop the whole notebook.  We resolve the
location defensively instead, and fall back on the current working directory.  Two helper
packages written by the author are loaded if they can be found:

    ConvertMapleToMathematicaV2.wl   parses the Maple solution strings of Section 12
    EtoExp.wl                        rewrites Power[E, ...] as Exp[...]

If a package cannot be found we say exactly which file is missing and where we looked, and we
do NOT substitute a home-made replacement for it.

(* ::Input:: *)
ClearAll[cfNotebookFile, cfDir, cfName, cfHeader, cfResolveFile];
cfNotebookFile = Quiet[NotebookFileName[]];
cfDir  = If[StringQ[cfNotebookFile], DirectoryName[cfNotebookFile], Directory[]];
cfName = If[StringQ[cfNotebookFile], FileBaseName[cfNotebookFile],
            "claude-fable_Einstein-Rosen-2-Planes"];
cfHeader = cfName <> "-";
{cfDir, cfName, cfHeader}

(* ::Input:: *)
(* --- look for a file next to the notebook, in the working directory, or one level down --- *)
cfResolveFile[name_String] := Module[{cands, hit},
  cands = DeleteDuplicates[{
     FileNameJoin[{cfDir, name}],
     FileNameJoin[{cfDir, "Pre-Universe_14SEP26-77", name}],
     FileNameJoin[{Directory[], name}],
     FileNameJoin[{Directory[], "Pre-Universe_14SEP26-77", name}],
     FileNameJoin[{ParentDirectory[Directory[]], name}]}];
  hit = SelectFirst[cands, FileExistsQ[#] &, $Failed];
  If[hit === $Failed,
    Print["  MISSING FILE  ", name];
    Print["                searched: ", Column[cands]];
    Print["                Put the file in one of those places and re-evaluate this cell."]];
  hit];
{cfResolveFile["ConvertMapleToMathematicaV2.wl"], cfResolveFile["EtoExp.wl"]}

(* ::Input:: *)
(* --- load them ------------------------------------------------------------------------- *)
ClearAll[cfMaplePath, cfEtoExpPath];
cfMaplePath  = cfResolveFile["ConvertMapleToMathematicaV2.wl"];
cfEtoExpPath = cfResolveFile["EtoExp.wl"];
If[StringQ[cfMaplePath],  Get[cfMaplePath],
   Print["  ConvertMapleToMathematicaV2 not loaded; Section 12 will report it again."]];
If[StringQ[cfEtoExpPath], Get[cfEtoExpPath],
   Print["  EtoExp not loaded; the Exp-rewriting cells of Section 12 will report it again."]];
{ValueQ[cfMaplePath], ValueQ[cfEtoExpPath]}

(* ::Section:: *)
11.  The wave function of the un-universe, and its Lagrangian

(* ::Text:: *)
Psi16 is the 16-component spinor that the original notebook calls the wave function of the
un-universe.  Its components are sixteen scalar functions f16[0..15] of the two coordinates that
the model actually depends on, the hidden-space coordinate x0 and the time coordinate x4.  The
first eight components are the type-1 split-octonion spinor and the last eight are the type-2
spinor, so Psi16 is literally the direct sum of the two.

The original notebook also prepares two substitution rules that rewrite the f16 in terms of new
unknowns in the light-cone-like chart z = 6 H x0, t = H x4:

    sfpsi16Aa     f16[k] -> ( Z[k][6 H #1, H #2] & )
    snewfpsi16Aa  f16[k] -> ( nZ[k][6 H #1, H #2] / Sqrt[Sin[6 H #1]] & )

Only the first is used downstream; the second is the author's alternative normalization and is
recorded here unchanged.  In the original the second rule's 1/Sqrt[Sin[...]] factor is written
inside the string as a typeset FractionBox escape; we write it in plain input form, which
parses to exactly the same expression.

(* ::Input:: *)
ClearAll[\[CapitalPsi]16, \[CapitalPsi]16upper, \[CapitalPsi]16lower, f16];
\[CapitalPsi]16 = Table[f16[k][x0, x4], {k, 0, 15}];
\[CapitalPsi]16upper = Take[\[CapitalPsi]16, 8];    (* type-1 split-octonion spinor *)
\[CapitalPsi]16lower = Take[\[CapitalPsi]16, -8];   (* type-2 split-octonion spinor *)
cfAssert["Psi16 is the direct sum of the type-1 and type-2 spinors",
  \[CapitalPsi]16 === Join[\[CapitalPsi]16upper, \[CapitalPsi]16lower]];
\[CapitalPsi]16

(* ::Input:: *)
(* --- the two re-parameterizations of the component functions ----------------------------- *)
ClearAll[sf\[Psi]16Aa, snewf\[Psi]16Aa, sreplaceZ, sreplacenZ, subsDefects];
sf\[Psi]16Aa =
  Table[f16[k] -> ToExpression["((Z[" <> ToString[k] <> "][6*H*#1,H*#2])&)"], {k, 0, 15}];
snewf\[Psi]16Aa =
  Table[f16[k] -> ToExpression[
     "((nZ[" <> ToString[k] <> "][6*H*#1,H*#2]/Sqrt[Sin[6*H*#1]])&)"], {k, 0, 15}];
sreplaceZ  = Table[Z[k]  -> ToExpression["Z"  <> ToString[k]], {k, 0, 15}];
sreplacenZ = Table[nZ[k] -> ToExpression["nZ" <> ToString[k]], {k, 0, 15}];
subsDefects = {};      (* the original's hook for patching defective components; empty *)
{sf\[Psi]16Aa[[1]], snewf\[Psi]16Aa[[1]], Length[sreplaceZ], subsDefects}

(* ::Text:: *)
The Lagrangian.  This is the Dirac Lagrangian of the pre-universe, written with the 16x16 Dirac
matrices of Section 5 and the 16x16 spinor metric sigma16:

    La  =  (1/H)  Psi16^T . sigma16 . Sum over alpha of T16[alpha-1] . D[Psi16, x_alpha]
         + 2 (M/H) Psi16^T . sigma16 . Psi16 .

Because Psi16 depends only on x0 and x4, only the alpha = 1 and alpha = 5 terms survive.

There is an exact structural identity behind this Lagrangian that is worth stating, because the
original notebook probes it in a scratch cell with mismatched factors of H and therefore gets a
non-zero answer.  Section 5 proved that sigma16 . T16[A] is ANTISYMMETRIC.  An antisymmetric
bilinear form vanishes on the diagonal, so

    Psi16^T . sigma16 . T16[alpha] . Psi16  ==  0   identically,

hence its derivative vanishes too, and therefore

    Psi16^T . sigma16 . T16[alpha] . D[Psi16, x_alpha]
      ==  - D[Psi16, x_alpha]^T . sigma16 . T16[alpha] . Psi16

holds EXACTLY, with no boundary term at all.  The kinetic term is its own negative transpose:
that is what makes the variational problem well posed.  We verify both statements below.

(* ::Input:: *)
ClearAll[La];
La[] := ((1/H) Transpose[\[CapitalPsi]16] . \[Sigma]16 .
          Sum[T16[\[Alpha]1 - 1] . D[\[CapitalPsi]16, X[[\[Alpha]1]]], {\[Alpha]1, 1, Length[X]}]
        + 2 (M/H) Transpose[\[CapitalPsi]16] . \[Sigma]16 . \[CapitalPsi]16
       ) // Simplify[#, constraintVars] &;
cfTimed["evaluate the Lagrangian La[]", La[]] // Short[#, 10] &

(* ::Input:: *)
(* --- the two exact identities behind the Lagrangian -------------------------------------- *)
cfAssert["Psi16 . sigma16 . T16[alpha] . Psi16 == 0 identically (antisymmetric form)",
  Table[Expand[Transpose[\[CapitalPsi]16] . \[Sigma]16 . T16[\[Alpha]1 - 1] . \[CapitalPsi]16] === 0,
    {\[Alpha]1, 1, 8}]];
cfAssert["the kinetic term equals minus its transpose, exactly",
  Expand[
    Transpose[\[CapitalPsi]16] . \[Sigma]16 .
      Sum[T16[\[Alpha]1 - 1] . D[\[CapitalPsi]16, X[[\[Alpha]1]]], {\[Alpha]1, 1, 8}]
    + Sum[D[Transpose[\[CapitalPsi]16], X[[\[Alpha]1]]] . \[Sigma]16 . T16[\[Alpha]1 - 1],
        {\[Alpha]1, 1, 8}] . \[CapitalPsi]16] === 0];

(* ::Input:: *)
(* --- so the Lagrangian and its "conjugate" form differ only in the mass coefficient ------ *)
(* The original's scratch cell compares La against a conjugate form written with 2 H M       *)
(* instead of 2 M/H and without the 1/H on the kinetic term, so its difference does not       *)
(* vanish.  Written with matching coefficients the difference is exactly zero.                *)
cfAssert["La[] == its conjugate form when the coefficients match",
  Simplify[La[] - (
     -(1/H) Sum[D[Transpose[\[CapitalPsi]16], X[[\[Alpha]1]]] . \[Sigma]16 . T16[\[Alpha]1 - 1],
        {\[Alpha]1, 1, 8}] . \[CapitalPsi]16
     + 2 (M/H) Transpose[\[CapitalPsi]16] . \[Sigma]16 . \[CapitalPsi]16),
   constraintVars] === 0];

(* ::Section:: *)
12.  The Euler-Lagrange equations, the coupling pattern, and the (z,t) chart

(* ::Text:: *)
The Euler-Lagrange operator of the original notebook, transcribed exactly.  For each component
index k it forms

    (1/detsqrt) ( D[L, f16[k][x0,x4]]
                  - D[ D[L, Derivative[1,0][f16[k]][x0,x4]], x0]
                  - D[ D[L, Derivative[0,1][f16[k]][x0,x4]], x4] )

simplified under constraintVars, and then applies subsDefects.  For the flat Lagrangian La the
volume factor detsqrt is 1.

(* ::Input:: *)
ClearAll[eL];
eL[Lagrangian_Symbol, detsqrt_] := Module[{L, t},
  L = Lagrangian[];
  t = Table[
    FullSimplify[
      (1/detsqrt) (
        D[L, f16[k][x0, x4]]
        - D[D[L, Derivative[1, 0][f16[k]][x0, x4]], x0]
        - D[D[L, Derivative[0, 1][f16[k]][x0, x4]], x4]),
      constraintVars],
    {k, 0, 15}];
  Return[t /. subsDefects];
];

(* ::Input:: *)
(* --- the sixteen field equations --------------------------------------------------------- *)
ClearAll[eLa];
eLa = cfTimed["Euler-Lagrange equations eLa = eL[La, 1]", eL[La, 1]];
cfAssert["there are sixteen field equations", Length[eLa] === 16];
Column[eLa]

(* ::Input:: *)
(* --- which components are coupled to which ----------------------------------------------- *)
(* rawSets collects, for each equation, the set of component indices that appear in it.       *)
(* MergeSetsStep merges any two sets that intersect; iterating it to a fixed point gives the  *)
(* partition of the sixteen components into independent blocks.                               *)
ClearAll[rawSets, MergeSetsStep, showCoupledEquations];
rawSets[l_, f_, o_: 0] := Table[
   Cases[l[[j]], h_Symbol[n_Integer] /; StringEndsQ[SymbolName[h], f] :> n + o,
     Infinity, Heads -> True],
   {j, 1, Length[l]}];
MergeSetsStep[currentSets_List] := Module[{i, j, merged = currentSets},
  Catch[
   For[i = 1, i <= Length[merged], i++,
    For[j = i + 1, j <= Length[merged], j++,
     If[Intersection[merged[[i]], merged[[j]]] =!= {},
      merged = Delete[merged, {{i}, {j}}];
      AppendTo[merged, Sort[Union[currentSets[[i]], currentSets[[j]]]]];
      Throw[Sort[merged]]]]];
   Sort[merged]]];
showCoupledEquations[items_List] := FixedPoint[MergeSetsStep, items];

(* ::Input:: *)
ClearAll[eLaRawSets, eLaCouplings];
eLaRawSets = rawSets[eLa, "f16", 0];
eLaCouplings = cfTimed["partition the 16 components into coupled blocks",
  showCoupledEquations[eLaRawSets]];
cfAssert["the coupled blocks partition all sixteen components",
  Sort[Flatten[eLaCouplings]] === Range[0, 15]];
cfAssert["there are four blocks of four",
  Length /@ eLaCouplings === {4, 4, 4, 4}];
eLaCouplings

(* ::Input:: *)
(* --- save the equations, exactly as the original does ------------------------------------ *)
ClearAll[$cfWriteMX];
$cfWriteMX = True;
If[$cfWriteMX,
  DumpSave[FileNameJoin[{cfDir, cfHeader <> "eLa.mx"}], eLa];
  Print["wrote ", FileNameJoin[{cfDir, cfHeader <> "eLa.mx"}]]];

(* ::Text:: *)
Now change the chart.  Substituting f16[k] -> Z[k][6 H x0, H x4] and then x0 -> z/(6H),
x4 -> t/H turns the sixteen equations into equations for the Z[k] in the coordinates (z,t).
The overall factor 1/(2H) is the original's normalization.

(* ::Input:: *)
ClearAll[eLazt];
eLazt = cfTimed["change of chart: eLazt = (1/(2H)) eLa in the (z,t) coordinates",
  ((1/(2 H)) eLa /. sf\[Psi]16Aa /. sx0x4) // FullSimplify[#, constraintVars] &];
If[$cfWriteMX,
  DumpSave[FileNameJoin[{cfDir, cfHeader <> "eLazt.mx"}], eLazt];
  Print["wrote ", FileNameJoin[{cfDir, cfHeader <> "eLazt.mx"}]]];
Column[eLazt]

(* ::Section:: *)
13.  Decoupling into four blocks of four, and the closed-form solutions

(* ::Text:: *)
The sixteen equations couple the components in four groups of four.  Relabelling the components
so that each group becomes a consecutive block of four turns the system into four independent
4x4 first-order systems.  The relabelling map is

    sZtOyZ :   Z[ eLaCouplings flattened ]  ->  yZ[0], yZ[1], ..., yZ[15] ,

i.e. the j-th component in the flattened coupling list becomes yZ[j-1].

(* ::Input:: *)
ClearAll[varZ, varZzt, DzvarZ, DtvarZ];
varZ = Table[Z[k], {k, 0, 15}];
varZzt = Through[varZ[z, t]];
DzvarZ = D[varZzt, z];
DtvarZ = D[varZzt, t];
{Short[varZzt, 3], Short[DtvarZ, 3]}

(* ::Input:: *)
(* --- solve the system for the t-derivatives ---------------------------------------------- *)
ClearAll[DtvarZsubs, DtvarZEQS, DtvarZrelations];
DtvarZsubs = cfTimed["solve the 16 equations for the t-derivatives",
  Solve[And @@ Thread[0 == eLazt], DtvarZ][[1]] // FullSimplify[#, constraintVars] &];
DtvarZEQS = DtvarZsubs /. {Rule -> Equal};
DtvarZrelations = DtvarZsubs /. {Rule -> Subtract};
cfAssert["all sixteen t-derivatives are determined", Length[DtvarZsubs] === 16];
Column[DtvarZsubs]

(* ::Input:: *)
(* --- the relabelling, and its inverse ---------------------------------------------------- *)
ClearAll[yZdef, Zdef, sZtOyZ, syZtoZ, zeroZyZforCaExpression, zeroZyZEQS];
yZdef = Table[yZ[k], {k, 0, 15}];
Zdef  = Table[Z[k],  {k, 0, 15}];
sZtOyZ = Table[Z[Flatten[eLaCouplings][[j]]] -> yZ[j - 1], {j, 1, 16}];
syZtoZ = Solve[And @@ (sZtOyZ /. {Rule -> Equal}), yZdef][[-1]];
zeroZyZforCaExpression = -(sZtOyZ /. {Rule -> Subtract});
zeroZyZEQS = sZtOyZ /. {Rule -> Equal};
cfAssert["the relabelling is a bijection of the sixteen components",
  Sort[sZtOyZ[[All, 1]]] === Sort[Zdef] && Sort[sZtOyZ[[All, 2]]] === Sort[yZdef]];
Column[sZtOyZ]

(* ::Input:: *)
(* --- the equations in the new labels, and the four 4x4 blocks ---------------------------- *)
ClearAll[eLyZ, DtyZsubsA, DtvaryZEQS, zeroDtyZeqs, coupledyZeqs];
eLyZ = cfTimed["relabel the equations", (eLazt /. sZtOyZ) // FullSimplify];
DtyZsubsA = cfTimed["solve the relabelled system for the t-derivatives",
  Solve[And @@ Thread[0 == eLyZ], D[Through[yZdef[z, t]], t]][[1]] //
    FullSimplify[#, constraintVars] &];
DtvaryZEQS = DtyZsubsA /. {Rule -> Equal};
zeroDtyZeqs = DtyZsubsA /. {Rule -> Subtract};
coupledyZeqs = Partition[DtvaryZEQS, 4];
cfAssert["the system splits into four blocks of four equations",
  Dimensions[coupledyZeqs] === {4, 4}];
Column[coupledyZeqs]

(* ::Input:: *)
(* --- each block really is closed: block j mentions only yZ[4(j-1)] .. yZ[4(j-1)+3] -------- *)
cfAssert["each 4x4 block is closed in its own four components",
  Table[SubsetQ[Range[4 (blk - 1), 4 (blk - 1) + 3],
     Union@Cases[coupledyZeqs[[blk]], yZ[n_Integer] :> n, Infinity, Heads -> True]],
    {blk, 1, 4}]];
Table[Union@Cases[coupledyZeqs[[blk]], yZ[n_Integer] :> n, Infinity, Heads -> True],
  {blk, 1, 4}]

(* ::Text:: *)
The original notebook now tries DSolve on each block.  We run the same four calls, but wrapped
in TimeConstrained so that the notebook cannot hang on them, and we report honestly whether
each one returned a closed form or came back unevaluated.  The original's experience was that
Mathematica does not solve these blocks, which is why the author turned to Maple; the cells
below record what actually happens in this kernel rather than assuming either outcome.

(* ::Input:: *)
ClearAll[yZvar, cfDSolveTry, dsolveResults];
yZvar = Through[yZdef[z, t]];
cfDSolveTry[blk_Integer, seconds_: 60] := Module[{r},
  r = TimeConstrained[
     Quiet@Check[DSolve[coupledyZeqs[[blk]], yZvar[[4 (blk - 1) + 1 ;; 4 blk]], {z, t}],
       $cfDSolveFailed],
     seconds, $cfDSolveTimedOut];
  Print["  block ", blk, ": ",
    Which[r === $cfDSolveTimedOut, "TIMED OUT",
          r === $cfDSolveFailed, "DSolve reported an error",
          MatchQ[r, _DSolve], "returned unevaluated",
          r === {}, "no solution found",
          True, "closed form with " <> ToString[Length[r]] <> " branch(es)"]];
  r];
dsolveResults = cfTimed["DSolve on the four blocks", Table[cfDSolveTry[blk], {blk, 1, 4}]];
Short[dsolveResults, 8]

(* ::Text:: *)
The closed forms below were obtained with Maple by the author and pasted back into the original
notebook as literal strings.  They are reproduced here verbatim.  The parser that turns them
into Wolfram expressions is the author's own ConvertMapleToMathematicaV2, whose load banner
warns that it should not be trusted for a correct result.  That warning does not matter here,
because the solutions it produces are SUBSTITUTED BACK into the four blocks and verified
symbolically a few cells below: the verification, not the parser, is what certifies them.

Each block j involves one constant C_j and four constants c_j1..c_j4, and every component
carries the same exponential

    exp( ( 6 (z/6 + t) H^2 C_j^2  -  6 (-z/6 + t) M^2 ) / (6 C_j H^2) ) .

(* ::Input:: *)
ClearAll[maplestringEQ1, maplestringEQ2, maplestringEQ3, maplestringEQ4];
maplestringEQ1 = "{{yZ0(z, t) = exp((6*(z/6 + t)*H^2*C1^2 - 6*(-z/6 + t)*M^2)/(6*C1*H^2))*(H^2*(c11*c12 - c13*c14)*C1^2 - M^2*(c11*c12 + c13*c14))/(2*H*C1*M), yZ1(z, t) = -((H^2*(c11*c12 - c13*c14)*C1^2 + M^2*(c11*c12 + c13*c14))*exp((6*(z/6 + t)*H^2*C1^2 - 6*(-z/6 + t)*M^2)/(6*C1*H^2)))/(2*H*C1*M), yZ2(z, t) = c13*exp((6*(z/6 + t)*H^2*C1^2 - 6*(-z/6 + t)*M^2)/(6*C1*H^2))*c14, yZ3(z, t) = c11*exp((6*(z/6 + t)*H^2*C1^2 - 6*(-z/6 + t)*M^2)/(6*C1*H^2))*c12}}";
maplestringEQ2 = "{{yZ4(z, t) = -exp((6*(z/6 + t)*H^2*C2^2 - 6*(-z/6 + t)*M^2)/(6*C2*H^2))*(H^2*(c21*c22 + c23*c24)*C2^2 - M^2*(c21*c22 - c23*c24))/(2*H*C2*M), yZ5(z, t) = -((H^2*(c21*c22 + c23*c24)*C2^2 + M^2*(c21*c22 - c23*c24))*exp((6*(z/6 + t)*H^2*C2^2 - 6*(-z/6 + t)*M^2)/(6*C2*H^2)))/(2*H*C2*M), yZ6(z, t) = c23*exp((6*(z/6 + t)*H^2*C2^2 - 6*(-z/6 + t)*M^2)/(6*C2*H^2))*c24, yZ7(z, t) = c21*exp((6*(z/6 + t)*H^2*C2^2 - 6*(-z/6 + t)*M^2)/(6*C2*H^2))*c22}}";
maplestringEQ3 = "{{yZ10(z, t) = c33*exp((6*H^2*(z/6 + t)*C3^2 - 6*(-z/6 + t)*M^2)/(6*C3*H^2))*c34, yZ11(z, t) = c31*exp((6*H^2*(z/6 + t)*C3^2 - 6*(-z/6 + t)*M^2)/(6*C3*H^2))*c32, yZ8(z, t) = -exp((6*H^2*(z/6 + t)*C3^2 - 6*(-z/6 + t)*M^2)/(6*C3*H^2))*(H^2*(c31*c32 + c33*c34)*C3^2 - M^2*(c31*c32 - c33*c34))/(2*H*C3*M), yZ9(z, t) = -((H^2*(c31*c32 + c33*c34)*C3^2 + M^2*(c31*c32 - c33*c34))*exp((6*H^2*(z/6 + t)*C3^2 - 6*(-z/6 + t)*M^2)/(6*C3*H^2)))/(2*H*C3*M)}}";
maplestringEQ4 = "{{yZ12(z, t) = exp((6*H^2*(z/6 + t)*C4^2 - 6*(-z/6 + t)*M^2)/(6*C4*H^2))*(H^2*(c41*c42 - c43*c44)*C4^2 - M^2*(c41*c42 + c43*c44))/(2*H*C4*M), yZ13(z, t) = -((H^2*(c41*c42 - c43*c44)*C4^2 + M^2*(c41*c42 + c43*c44))*exp((6*H^2*(z/6 + t)*C4^2 - 6*(-z/6 + t)*M^2)/(6*C4*H^2)))/(2*H*C4*M), yZ14(z, t) = c43*exp((6*H^2*(z/6 + t)*C4^2 - 6*(-z/6 + t)*M^2)/(6*C4*H^2))*c44, yZ15(z, t) = c41*exp((6*H^2*(z/6 + t)*C4^2 - 6*(-z/6 + t)*M^2)/(6*C4*H^2))*c42}}";
StringLength /@ {maplestringEQ1, maplestringEQ2, maplestringEQ3, maplestringEQ4}

(* ::Input:: *)
(* --- parse them ------------------------------------------------------------------------- *)
ClearAll[solvedEQ, YZvar, sYZvar];
If[! StringQ[cfMaplePath],
  Print["  CANNOT PARSE THE MAPLE SOLUTIONS: ConvertMapleToMathematicaV2.wl was not found."];
  Print["  Nothing is substituted for it.  Place the file next to this notebook and re-run."]];
solvedEQ = Table[ConvertMapleToMathematicaV2[
    {maplestringEQ1, maplestringEQ2, maplestringEQ3, maplestringEQ4}[[j]]], {j, 1, 4}];
YZvar = Table[ToExpression["YZ" <> ToString[k] <> "[z,t]"], {k, 0, 15}];
sYZvar = Solve[And @@ Flatten[solvedEQ], YZvar][[1]];
cfAssert["all sixteen components have a closed form", Length[sYZvar] === 16];
Column[sYZvar]

(* ::Input:: *)
(* --- turn them into pure functions for yZ ------------------------------------------------ *)
ClearAll[ssyZ];
ssyZ = Table[
   yZ[k] -> ToExpression["((" <> ToString[FullForm[sYZvar[[k + 1, 2]] /. {z -> #1, t -> #2}]] <> ")&)"],
   {k, 0, 15}];
cfAssert["there are sixteen pure-function rules", Length[ssyZ] === 16];
Short[ssyZ, 6]

(* ::Input:: *)
(* --- VERIFY the Maple solutions against the four blocks ---------------------------------- *)
(* This is the cell that certifies Section 13.  Every one of the sixteen equations must       *)
(* reduce to True after the closed forms are substituted.                                     *)
ClearAll[cfMapleCheck];
cfMapleCheck = cfTimed["substitute the closed forms back into the four blocks",
  Table[FullSimplify[coupledyZeqs[[blk]] /. ssyZ], {blk, 1, 4}]];
cfAssert["THE MAPLE CLOSED FORMS SOLVE ALL SIXTEEN EQUATIONS",
  Union[Flatten[cfMapleCheck]] === {True}];
cfMapleCheck

(* ::Input:: *)
(* --- back to the original labels, and to Psi16 ------------------------------------------- *)
ClearAll[sZ, \[CapitalPsi]16a];
sZ = Sort[sZtOyZ /. ssyZ];
\[CapitalPsi]16a = cfTimed["Psi16 with the closed forms substituted",
  (\[CapitalPsi]16 /. sf\[Psi]16Aa /. sx0x4 /. sZ /. szt) // FullSimplify];
Column[\[CapitalPsi]16a]

(* ::Text:: *)
One more structural result of the original notebook.  The relabelling Z -> yZ is a linear map;
extracting its matrix with CoefficientArrays shows that the map is an ORTHOGONAL 16x16 matrix,
so it preserves the Euclidean form, but it does NOT preserve sigma16, so it is not a Spin(8,8)
transformation; and it is not block diagonal, so it mixes the type-1 and type-2 spinors.

(* ::Input:: *)
ClearAll[cayZ, caZ, caZ2, almightyS];
cayZ = CoefficientArrays[zeroZyZforCaExpression, yZdef];
caZ  = CoefficientArrays[zeroZyZforCaExpression, Zdef];
caZ2 = Normal[caZ[[2]]];
almightyS = -Transpose[caZ2];
cfAssert["the yZ coefficient matrix is the identity", Normal[cayZ[[2]]] === ID16];
cfAssert["ORTHOGONAL: Transpose[S] . S == ID16", Transpose[almightyS] . almightyS === ID16];
cfAssert["ORTHOGONAL: S . Transpose[S] == ID16", almightyS . Transpose[almightyS] === ID16];
cfAssert["but NOT a Spin(8,8) transformation: it does not preserve sigma16",
  Transpose[almightyS] . \[Sigma]16 . almightyS =!= \[Sigma]16];
cfAssert["and NOT a direct sum: it mixes type-1 with type-2",
  caZ2 =!= ArrayFlatten[{{caZ2[[1 ;; 8, 1 ;; 8]], 0}, {0, caZ2[[9 ;; 16, 9 ;; 16]]}}]];
MatrixForm[caZ2]

(* ::Section:: *)
14.  Bilinears, the two solution branches, and M6 = 3 generations of Einstein-Rosen 2-planes

(* ::Text:: *)
Five bilinear invariants are formed from the solution.  With psi the 16-component solution,
psi1 its type-1 half and psi2 its type-2 half:

    psi . sigma16 . psi        (identically zero, as Section 11 showed)
    psi1 . sigma . psi1        (the type-1 norm)
    psi2 . sigma . psi2        (the type-2 norm)
    psi2 . psi1                (the unpaired product)
    psi2 . sigma . psi1        (the paired product)

Requiring the norms to be constant along the light cone is what fixes two of the four block
constants.  We first introduce the advanced and retarded light-cone coordinates in the (z,t)
chart, which are the original notebook's ztadv and ztret.

(* ::Input:: *)
ClearAll[sztar, sszt, ztadv, ztret];
sztar = Solve[ztadv == 6 t + z && ztret == 6 t - z, {ztadv, ztret}][[1]];
sszt  = Solve[ztadv == 6 t + z && ztret == 6 t - z, {z, t}][[1]];
{sztar, sszt}

(* ::Input:: *)
(* --- the five bilinears ------------------------------------------------------------------ *)
ClearAll[\[Psi]sol, \[Psi]1sol, \[Psi]2sol, psiSigma16psi, psi1Sigmapsi1, psi2Sigmapsi2,
         psi2psi1, psi2Sigmapsi1];
\[Psi]sol  = Through[yZdef[z, t]] /. ssyZ;
\[Psi]1sol = \[Psi]sol[[1 ;; 8]];
\[Psi]2sol = \[Psi]sol[[9 ;; 16]];
(* FullSimplify::time is EXPECTED on two of these five bilinears: Section 1 set the original    *)
(* notebook's 3-second FullSimplify budget and these expressions exceed it.  FullSimplify then  *)
(* returns the best form it reached, which is correct but not maximally simplified, so the      *)
(* message is informational.  It is suppressed here and only here, and announced first.         *)
Print["  EXPECTED MESSAGE  FullSimplify::time may fire on the bilinears; the 3-second budget"];
Print["                    set in Section 1 is the original notebook's, and a budget that is"];
Print["                    reached still returns a correct, merely less-simplified, result."];
psiSigma16psi  = cfTimed["bilinear psi . sigma16 . psi",
   Quiet[\[Psi]sol . \[Sigma]16 . \[Psi]sol // FullSimplify[#, constraintVars] &,
     {FullSimplify::time, General::stop}]];
psi1Sigmapsi1  = cfTimed["bilinear psi1 . sigma . psi1",
   Quiet[\[Psi]1sol . \[Sigma] . \[Psi]1sol // FullSimplify[#, constraintVars] &,
     {FullSimplify::time, General::stop}]];
psi2Sigmapsi2  = cfTimed["bilinear psi2 . sigma . psi2",
   Quiet[\[Psi]2sol . \[Sigma] . \[Psi]2sol // FullSimplify[#, constraintVars] &,
     {FullSimplify::time, General::stop}]];
psi2psi1       = cfTimed["bilinear psi2 . psi1",
   Quiet[\[Psi]2sol . \[Psi]1sol // FullSimplify[#, constraintVars] &,
     {FullSimplify::time, General::stop}]];
psi2Sigmapsi1  = cfTimed["bilinear psi2 . sigma . psi1",
   Quiet[\[Psi]2sol . \[Sigma] . \[Psi]1sol // FullSimplify[#, constraintVars] &,
     {FullSimplify::time, General::stop}]];
(* sigma16 == ArrayFlatten[{{-sigma,0},{0,sigma}}], so the 16-component norm is the DIFFERENCE  *)
(* of the two 8-component norms.  Note that sigma16 itself is SYMMETRIC, so this bilinear does  *)
(* not vanish; it is sigma16 . T16[A] that is antisymmetric, which is what made the kinetic     *)
(* term of Section 11 self-adjoint.                                                             *)
cfAssert["psi . sigma16 . psi == psi2.sigma.psi2 - psi1.sigma.psi1",
  Simplify[psiSigma16psi - (psi2Sigmapsi2 - psi1Sigmapsi1), constraintVars] === 0];
Column[{psiSigma16psi, psi1Sigmapsi1, psi2Sigmapsi2, psi2psi1, psi2Sigmapsi1}]

(* ::Input:: *)
(* --- demanding that the two norms be light-cone constants fixes C2 and C4 ---------------- *)
ClearAll[cfNormDerivs, cfConstantSolutions];
cfNormDerivs = Union@Flatten@Table[
    {Simplify[D[b /. sszt, ztadv], constraintVars],
     Simplify[D[b /. sszt, ztret], constraintVars]},
    {b, {psi1Sigmapsi1, psi2Sigmapsi2}}];
(* Solve::ifun and Solve::svars are EXPECTED here.  The conditions are transcendental in the    *)
(* block constants, so Solve inverts an exponential (ifun) and does not determine every one of  *)
(* the four constants (svars) -- a one-parameter family survives, which is the point.  The      *)
(* branch that Solve returns is verified independently in the next cell.                         *)
Print["  EXPECTED MESSAGES  Solve::ifun and Solve::svars: the light-cone conditions are"];
Print["                     transcendental and leave a family of solutions, not a unique one."];
cfConstantSolutions = Quiet[Solve[And @@ Thread[0 == cfNormDerivs], {C1, C2, C3, C4}],
   {Solve::ifun, Solve::svars}];
cfAssert["the light-cone-constant condition has solutions", cfConstantSolutions =!= {}];
{cfNormDerivs, cfConstantSolutions}

(* ::Input:: *)
(* --- the original's branch: C2 -> -C1 and C4 -> -C3 -------------------------------------- *)
ClearAll[cfBranch, cfBilinearsOnBranch];
cfBranch = {C2 -> -C1, C4 -> -C3};
cfBilinearsOnBranch = Simplify[
   {psiSigma16psi, psi1Sigmapsi1, psi2Sigmapsi2, psi2Sigmapsi1} /. sszt /. cfBranch,
   constraintVars];
cfAssert["on the branch C2 = -C1, C4 = -C3 the two norms are independent of ztadv and ztret",
  Flatten@Table[Simplify[{D[b, ztadv], D[b, ztret]}, constraintVars] === {0, 0},
    {b, cfBilinearsOnBranch[[2 ;; 3]]}]];
Column[cfBilinearsOnBranch]

(* ::Input:: *)
(* --- the two mass branches of the original notebook -------------------------------------- *)
(* Psi16ab keeps a free dimensionless mass ratio Mab; Psi16aa is the special case Mab = 1.    *)
ClearAll[\[CapitalPsi]16ab, \[CapitalPsi]16aa, \[CapitalPsi]16x0ONLY];
\[CapitalPsi]16ab = cfTimed["Psi16ab  (M -> H Mab Sqrt[C1 C3])",
  (\[CapitalPsi]16a /. sf\[Psi]16Aa /. sx0x4 /. sZ /. szt
     /. {C2 -> -C1, C4 -> -C3, M -> H Mab Sqrt[C1 C3]}) // FullSimplify];
\[CapitalPsi]16aa = cfTimed["Psi16aa  (M -> H Sqrt[C1 C3])",
  (\[CapitalPsi]16a /. sf\[Psi]16Aa /. sx0x4 /. sZ /. szt
     /. {C2 -> -C1, C4 -> -C3, M -> H Sqrt[C1 C3]}) // FullSimplify];
\[CapitalPsi]16x0ONLY = cfTimed["Psi16x0ONLY  (C3 -> C1)",
  (\[CapitalPsi]16aa /. {C3 -> C1}) // FullSimplify[#, C1 > 0] &];
Column[{Short[\[CapitalPsi]16ab, 6], Short[\[CapitalPsi]16aa, 6], Short[\[CapitalPsi]16x0ONLY, 6]}]

(* ::Input:: *)
(* --- advanced and retarded coordinates in the (x0,x4) chart ------------------------------ *)
ClearAll[s\[Xi], ssx0x4, \[Xi]adv, \[Xi]ret];
s\[Xi]   = Solve[\[Xi]adv == x0 - x4 && \[Xi]ret == x0 + x4, {\[Xi]adv, \[Xi]ret}][[1]];
ssx0x4 = Solve[\[Xi]adv == x0 - x4 && \[Xi]ret == x0 + x4, {x0, x4}][[1]];
{s\[Xi], ssx0x4}

(* ::Input:: *)
(* --- the two split-octonion spinors of the solution -------------------------------------- *)
ClearAll[\[Psi]1, \[Psi]2, type1DIVBYtype2, realPartOfType1, realPartOfType2];
\[Psi]1 = FullSimplify[\[CapitalPsi]16ab[[1 ;; 8]]];
\[Psi]2 = FullSimplify[\[CapitalPsi]16ab[[9 ;; 16]]];
type1DIVBYtype2 = FullSimplify[\[CapitalPsi]16ab[[1 ;; 8]]/\[CapitalPsi]16ab[[9 ;; 16]]];
realPartOfType1 = FullSimplify[unit . \[Psi]1];
realPartOfType2 = FullSimplify[unit . \[Psi]2];
Column[{Short[\[Psi]1, 4], Short[\[Psi]2, 4], Short[type1DIVBYtype2, 4],
        realPartOfType1, realPartOfType2}]

(* ::Text:: *)
Triality now turns each spinor into a VECTOR of the split octonion algebra.  Using the constant
bridge of Section 9,

    vectorFormOfType2  =  triVecToSpin . psi2
    vectorFormOfType1  =  eta4488 . ( Transpose[psi1] . sigma . triSpinToVec )

Which of the two mutually inverse bridge matrices goes on which side is not a matter of taste.
triVecToSpin[[A,a]] carries a VECTOR row index and a SPINOR column index, so LEFT-multiplying a
column spinor by it produces a vector, while RIGHT-multiplying a row spinor by triSpinToVec does
the same on the other side.  Exchanging the two would still type-check, would still pass every
assertion attached to these objects (any non-zero covector annihilates some 7-plane), and would
silently produce different 7-planes and a different M6.  These are the objects the original
notebook writes as F with indices a,A and A,a respectively, in exactly this arrangement.

Each of these two vectors is normal to a 7-plane through the origin of the split octonion
algebra, namely the set of position vectors Zoct with <vector, Zoct> = 0.  Two 7-planes that are
not parallel meet in a 6-plane.  That 6-plane, called M6 in the original notebook, is the object
of the title: the three generations of Einstein-Rosen 2-plane bridges live in it.

A naming note.  The original notebook writes the 8-component position vector as Z, which
collides with the head Z[k] used for the wave-function components earlier in the same session.
We call it Zoct here.  The mathematics is unchanged; only the symbol is.

(* ::Input:: *)
ClearAll[vectorFormOfType1, vectorFormOfType2];
(* triVecToSpin[[A,a]]: vector row, spinor column.  It maps a column SPINOR to a VECTOR from  *)
(* the left; triSpinToVec does the reverse and acts on a ROW spinor from the right.           *)
vectorFormOfType2 = FullSimplify[triVecToSpin . \[Psi]2];
vectorFormOfType1 = FullSimplify[\[Eta]4488 . (Transpose[\[Psi]1] . \[Sigma] . triSpinToVec)];
cfAssert["both triality vectors have eight components",
  {Length[vectorFormOfType1], Length[vectorFormOfType2]} === {8, 8}];
(* the index placement is not arbitrary: each bridge must be used on its own side *)
cfAssert["vectorFormOfType2 == psi2 contracted on the SPINOR index of triVecToSpin",
  Simplify[vectorFormOfType2
     - Table[Sum[triVecToSpin[[A1, a1]] \[Psi]2[[a1]], {a1, 8}], {A1, 8}]] ===
   ConstantArray[0, 8]];
cfAssert["triVecToSpin and triSpinToVec really are mutually inverse",
  triVecToSpin . triSpinToVec === ID8];
Column[{Short[vectorFormOfType1, 5], Short[vectorFormOfType2, 5]}]

(* ::Input:: *)
(* --- the two 7-planes ------------------------------------------------------------------- *)
ClearAll[Zoct, zoct, sz8, sz7, sevenPlane1, sevenPlane2];
Zoct = Array[zoct, 8];
sz8 = FullSimplify[Solve[0 == vectorFormOfType2 . Zoct, zoct[8]][[-1]]];
sz7 = Simplify[Solve[0 == vectorFormOfType1 . Zoct, zoct[7]][[-1]]];
sevenPlane2 = Zoct /. sz8;
sevenPlane1 = Zoct /. sz7;
cfAssert["sevenPlane2 is annihilated by vectorFormOfType2",
  Simplify[vectorFormOfType2 . sevenPlane2] === 0];
cfAssert["sevenPlane1 is annihilated by vectorFormOfType1",
  Simplify[vectorFormOfType1 . sevenPlane1] === 0];
Column[{Short[sevenPlane1, 5], Short[sevenPlane2, 5]}]

(* ::Input:: *)
(* --- and their intersection, the 6-plane M6 ---------------------------------------------- *)
ClearAll[sixPlane78, M6];
(* Solve::svars is EXPECTED here and is in fact the result we want: intersecting two 7-planes  *)
(* in an 8-space determines only TWO of the eight components and leaves SIX free.  That is the  *)
(* 6-plane M6.  The free-parameter count is asserted immediately below.                          *)
Print["  EXPECTED MESSAGE  Solve::svars: two 7-planes fix only two of the eight components,"];
Print["                    leaving the six free parameters of M6."];
sixPlane78 = cfTimed["intersect the two 7-planes",
  Simplify[Quiet[Solve[And @@ Thread[sevenPlane1 == sevenPlane2], Zoct], {Solve::svars}]]];
M6 = cfTimed["M6 in advanced / retarded coordinates",
  Simplify[Zoct /. sixPlane78 /. ssx0x4 /. s\[Xi]]];
cfAssert["M6 is a non-empty solution set", sixPlane78 =!= {}];
cfAssert["M6 has six free parameters",
  Length[Complement[Array[zoct, 8], First[sixPlane78][[All, 1]]]] === 6];
{Short[sixPlane78, 8], Short[M6, 8]}

(* ::Input:: *)
(* --- the free directions of M6, i.e. the six parameters that survive --------------------- *)
Grid[Prepend[
  Table[{zoct[j],
     If[MemberQ[First[sixPlane78][[All, 1]], zoct[j]], "determined", "free parameter"]},
    {j, 1, 8}], {"component", "status"}], Frame -> All, Alignment -> Left]

(* ::Text:: *)
Finally, the frame-resolution check of the original notebook.

The original defines two helper functions, resolution and resolution2, in two cells that are
laid out as several side-by-side columns with pasted images used as superscripts inside Print
strings.  That layout cannot be transcribed into linear code unambiguously, so we do NOT guess
at the original text.  What those cells check is unambiguous, and it is re-implemented here
directly: for a spinor v of non-zero norm, the frame built from v by triality must agree with
the closed-form bridge of Section 9, and the two bridges must be mutually inverse.

(* ::Input:: *)
ClearAll[cfResolution];
cfResolution[v_List] := Module[{u, EAa, EaA, FaA},
  If[Length[v] =!= 8,
    Print["  ERROR  cfResolution expects a length-8 spinor; got ", Length[v]];
    Return[$Failed]];
  If[Simplify[Transpose[v] . \[Sigma] . v] === 0,
    Print["  ERROR  cfResolution needs a spinor of non-zero sigma-norm"];
    Return[$Failed]];
  u   = FullSimplify[v/Sqrt[Abs[Transpose[v] . \[Sigma] . v]]];
  EAa = Table[u . \[Sigma] . \[Tau]bar[A1], {A1, 0, 7}];
  EaA = FullSimplify[Inverse[EAa]];
  FaA = FullSimplify[Transpose[Table[\[Eta]4488[[A1 + 1, A1 + 1]] (\[Tau][A1] . u), {A1, 0, 7}]]];
  <|"EAa" -> EAa, "EaA" -> EaA, "FaA" -> FaA,
    "closedFormMatchesInverse" -> (FullSimplify[FaA - EaA] === Zero8),
    "bridgesAreInverse" -> (FullSimplify[EAa . EaA] === ID8)|>];
ClearAll[cfResolutionUnit];
cfResolutionUnit = cfResolution[unit];
cfAssert["cfResolution[unit]: the closed-form bridge equals the matrix inverse",
  cfResolutionUnit["closedFormMatchesInverse"]];
cfAssert["cfResolution[unit]: the two bridges are mutually inverse",
  cfResolutionUnit["bridgesAreInverse"]];
cfAssert["cfResolution[unit] reproduces triVecToSpin",
  cfResolutionUnit["EAa"] === triVecToSpin];
Keys[cfResolutionUnit]
