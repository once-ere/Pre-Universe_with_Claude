(* ::Package:: *)
(* ================================================================================================
   waveguide_check.wls  --  independent Mathematica cross-check of the wall levels computed by
   waveguide.py (fable-cosmology/fermion/dev/waveguide_levels_reference.csv, written by
   `python waveguide.py reference`).

   Independent means: a different language, a different integrator (NDSolve at 30-digit working
   precision instead of DOP853 / Magnus in double precision), a different eigenvalue condition
   (the normalized 2x2 Wronskian of the left and right solutions instead of the Pruefer angle, and
   FindRoot with Brent's method), and the decaying eigenvector computed by Mathematica's NullSpace.
   The Python value is used only to choose a bracket [w0 - d, w0 + d] (d = 1e-3 R, clipped below the
   continuum); inside it the root is re-solved from scratch.  Also:
     - the full 16-component system (T16 from the notebook, via the committed waveguide_T16.json) is integrated
       with NDSolve (K = 3, 8; 25 digits) or, at K = 80 where NDSolve on the 16x8 matrix system did not
       finish in 30 min, with an independently coded 4th-order Magnus / MatrixExp propagator, and the
       multiplicity of each level is read off the singular values of [Q_L | Q_R];
     - the thresholds K_c(1), K_c(2) are checked with an independently written Pruefer-angle NDSolve:
       the mismatch at the continuum edge w = R crosses a multiple of Pi between K_c (1 - 1e-6) and
       K_c (1 + 1e-6).

   Units H = 1.  Block ODE (irrep w3 = -i; the other irrep is K -> -K):
       f' = -K(z) f + (m + w) g,   g' = K(z) g + (m - w) f,   K(z) = K_inf (1 - e^{-12 z})^{1/12},
   wall f(0) cos th + g(0) sin th = 0 (MIT+ : th = -Pi/4, MIT- : th = +Pi/4).

   Run:  wolframscript -file fable-cosmology/fermion/waveguide_check.wls
   ================================================================================================ *)

$HistoryLength = 0;
t0 = AbsoluteTime[];
dir = DirectoryName[ExpandFileName[$InputFileName]];
refFile = FileNameJoin[{dir, "dev", "waveguide_levels_reference.csv"}];
tFile = FileNameJoin[{dir, "waveguide_T16.json"}];
Print["waveguide_check.wls   ", DateString[{"Year", "-", "Month", "-", "Day", " ", "Time"}], "   ", $Version];
Print["reference: ", refFile];
ref = Rest[Import[refFile, "CSV"]];
wp = 30;
log = {};
check[label_, ok_] := (AppendTo[log, {label, TrueQ[ok]}]; Print[If[TrueQ[ok], "  PASS  ", "  FAIL  "], label]);
sci[x_] := Module[{v = N[x], e}, If[v == 0, "0", e = Floor[Log10[Abs[v]]]; ToString[NumberForm[v/10^e, {3, 2}]] <> "e" <> ToString[e]]];
num[x_, d_] := ToString[NumberForm[N[x, d + 2], d]];
prec = wp + 20;     (* inputs carry 20 more digits than the working precision (m - w cancels near w = m) *)

Kp[z_, Kinf_] := Kinf (1 - Exp[-12 z])^(1/12);

(* left solution at zm from the wall, right solution at zm from the exact decaying eigenvector at za *)
wronsk[w_?NumericQ, Kinf_, m_, th_, zm_, za_] := Module[{yL, yR, M, kap, vec, f, g, z},
  yL = If[zm > 0,
    NDSolveValue[{f'[z] == -Kp[z, Kinf] f[z] + (m + w) g[z], g'[z] == Kp[z, Kinf] g[z] + (m - w) f[z],
       f[0] == -Sin[th], g[0] == Cos[th]}, {f[zm], g[zm]}, {z, 0, zm},
      WorkingPrecision -> wp, PrecisionGoal -> 22, AccuracyGoal -> 22, MaxSteps -> 10^7],
    {-Sin[th], Cos[th]}];
  M = {{-Kinf, m + w}, {m - w, Kinf}};
  kap = Sqrt[Kinf^2 + m^2 - w^2];
  vec = First[NullSpace[M + kap IdentityMatrix[2]]];
  yR = NDSolveValue[{f'[z] == -Kp[z, Kinf] f[z] + (m + w) g[z], g'[z] == Kp[z, Kinf] g[z] + (m - w) f[z],
       f[za] == vec[[1]], g[za] == vec[[2]]}, {f[zm], g[zm]}, {z, zm, za},
      WorkingPrecision -> wp, PrecisionGoal -> 22, AccuracyGoal -> 22, MaxSteps -> 10^7];
  (yL[[1]] yR[[2]] - yL[[2]] yR[[1]])/(Norm[yL] Norm[yR])];

(* ---------------------------------------------------------------------------------------------
   1. levels
   --------------------------------------------------------------------------------------------- *)
Print[""]; Print["1. Levels: NDSolve (WorkingPrecision 30) + FindRoot (Brent) vs waveguide.py"];
Print[StringPadRight["case", 40], StringPadRight["waveguide.py", 22], StringPadRight["Mathematica", 34], "|diff|"];
levelRows = Select[ref, NumberQ[#[[5]]] &];
mres = Table[Module[{name = r[[1]], Kinf = SetPrecision[r[[2]], prec], m = SetPrecision[r[[3]], prec],
     th, w0 = SetPrecision[r[[5]], prec], R, d, zm = 2/100, za = 3, sol, wM},
    th = Which[Abs[r[[4]] + N[Pi/4]] < 10^-9, -Pi/4, Abs[r[[4]] - N[Pi/4]] < 10^-9, Pi/4,
      Abs[r[[4]] - N[Pi/2]] < 10^-9, Pi/2, True, SetPrecision[r[[4]], prec]];
    R = Sqrt[Kinf^2 + m^2];
    d = 10^-3 R;
    (* for the flat band w = m the coefficient m - w cancels to ~1e-42 near the root and NDSolve warns
       (NDSolveValue::precw) that this coefficient has fewer digits than the working precision; the
       warning is harmless there and is suppressed for that case only *)
    sol = If[StringMatchQ[name, "g(0)=0*"],
      Quiet[FindRoot[wronsk[w, Kinf, m, th, zm, za], {w, w0 - d, Min[w0 + d, R (1 - 10^-12)]},
        Method -> "Brent", WorkingPrecision -> prec, AccuracyGoal -> 20, PrecisionGoal -> 20], NDSolveValue::precw],
      FindRoot[wronsk[w, Kinf, m, th, zm, za], {w, w0 - d, Min[w0 + d, R (1 - 10^-12)]},
        Method -> "Brent", WorkingPrecision -> prec, AccuracyGoal -> 20, PrecisionGoal -> 20]];
    wM = w /. sol;
    Print[StringPadRight[name, 40], StringPadRight[num[r[[5]], 15], 22], StringPadRight[num[wM, 22], 34], sci[Abs[wM - w0]]];
    {name, r[[5]], wM, Abs[wM - w0]}], {r, levelRows}];
check["all " <> ToString[Length[mres]] <> " levels agree with waveguide.py to better than 1e-6 (max |diff| = " <>
   sci[Max[mres[[All, 4]]]] <> ")", Max[mres[[All, 4]]] < 10^-6];
check["and to better than 1e-9 (the double-precision reference is printed to 15 digits)", Max[mres[[All, 4]]] < 10^-9];
check["the exact flat band th = Pi/2: w = m = 1 to 1e-20", Abs[Select[mres, StringMatchQ[#[[1]], "g(0)=0*"] &][[1, 3]] - 1] < 10^-20];

(* ---------------------------------------------------------------------------------------------
   2. full 16-component system: multiplicities
   --------------------------------------------------------------------------------------------- *)
Print[""]; Print["2. Full 16-component system (T16 from the notebook): multiplicity of the levels"];
jj = Import[tFile, "RawJSON"];
T16n = SetPrecision[jj["T16"], wp];
id16 = IdentityMatrix[16];
check["T16 from the JSON satisfy {T16[a], T16[b]} = 2 eta_ab", Module[{T = jj["T16"], eta = DiagonalMatrix[{1, 1, 1, 1, -1, -1, -1, -1}]},
   And @@ Flatten[Table[T[[a]] . T[[b]] + T[[b]] . T[[a]] == 2 eta[[a, b]] id16, {a, 8}, {b, 8}]]]];
sv16[w_?NumericQ, Kinf_, m_, eps_, zm_, za_, prec_] := Module[{A, T0, T1, T4, Y0, Yinf, Minf, es, YL, YR, Y, z, QL, QR},
  {T0, T1, T4} = SetPrecision[{T16n[[1]], T16n[[2]], T16n[[5]]}, prec + 10];   (* inputs 10 digits above the working precision *)
  A[zz_] := T0 . (m id16 - I Kp[zz, Kinf] T1 + I w T4);
  es = Eigensystem[SetPrecision[eps T0, prec + 10]];
  Y0 = Transpose[Pick[es[[2]], Sign[Re[es[[1]]]], 1]];
  Minf = T0 . (m id16 - I Kinf T1 + I w T4);
  es = Eigensystem[Minf];
  Yinf = Transpose[es[[2]][[Ordering[Re[es[[1]]]][[1 ;; 8]]]]];
  YL = NDSolveValue[{Y'[z] == A[z] . Y[z], Y[0] == Y0}, Y[zm], {z, 0, zm}, WorkingPrecision -> prec,
     PrecisionGoal -> prec - 8, AccuracyGoal -> prec - 8, MaxSteps -> 10^7];
  YR = NDSolveValue[{Y'[z] == A[z] . Y[z], Y[za] == Yinf}, Y[zm], {z, zm, za}, WorkingPrecision -> prec,
     PrecisionGoal -> prec - 8, AccuracyGoal -> prec - 8, MaxSteps -> 10^7];
  QL = Orthogonalize[Transpose[YL]]; QR = Orthogonalize[Transpose[YR]];
  Sort[SingularValueList[Transpose[Join[QL, QR]], Tolerance -> 0]]];
(* For K = 80 the NDSolve integration of the 16x8 matrix system did not finish within 30 minutes (20-digit
   and machine precision alike), so there an independently coded 4th-order Magnus / MatrixExp propagator
   (machine precision, step 5e-4 / geometric near the wall) is used instead of NDSolve. *)
sv16mag[w_?NumericQ, Kinf_, m_, eps_, zm_, za_, h_] := Module[{T0, T1, T4, A0, B, Cc, es, Y0, Yinf, gL, gR, prop,
    c = Sqrt[3.]/12, g1 = 0.5 - Sqrt[3.]/6, g2 = 0.5 + Sqrt[3.]/6},
  {T0, T1, T4} = N[{T16n[[1]], T16n[[2]], T16n[[5]]}];
  A0 = T0 . (m id16 + I w T4); B = -I T0 . T1; Cc = B . A0 - A0 . B;
  es = Eigensystem[eps T0]; Y0 = Transpose[Pick[es[[2]], Sign[Round[Re[es[[1]]]]], 1]];
  es = Eigensystem[A0 + Kinf B]; Yinf = Transpose[es[[2]][[Ordering[Re[es[[1]]]][[1 ;; 8]]]]];
  gL = Join[{0.}, Exp[Subdivide[Log[10.^-14], Log[N[zm]], 400]]];
  gR = Subdivide[N[zm], N[za], Ceiling[(za - zm)/h]];
  prop[g_, Y0_, back_] := Module[{Y = Y0, n = Length[g] - 1, z0, hh, K1, K2, Om, idx},
    idx = If[back, Range[n, 1, -1], Range[1, n]];
    Do[z0 = g[[i]]; hh = g[[i + 1]] - g[[i]];
      K1 = Kp[z0 + g1 hh, Kinf]; K2 = Kp[z0 + g2 hh, Kinf];
      Om = hh A0 + 0.5 hh (K1 + K2) B + c hh^2 (K2 - K1) Cc;
      Y = MatrixExp[If[back, -Om, Om]] . Y;
      If[Mod[i, 16] == 0, Y = Transpose[Orthogonalize[Transpose[Y]]]], {i, idx}];
    Transpose[Orthogonalize[Transpose[Y]]]];
  Sort[SingularValueList[Join[prop[gL, Y0, False], prop[gR, Yinf, True], 2], Tolerance -> 0]]];
cases16 = {
   {"opposite-sign K=3 edge [NDSolve, 25 digits]", 3, 1, -1, "opposite-sign K=3 edge (irrep -i)", 25, "nd", 10^-6},
   {"same-sign K=8 shallow [NDSolve, 25 digits]", 8, 1, 1, "same-sign K=8 shallow (irrep -i)", 25, "nd", 10^-6},
   {"same-sign K=80 n=1 (irrep +i) [Magnus/MatrixExp]", 80, 1, 1, "same-sign K=80 n=1 (irrep +i)", 0, "mag", 10^-5},
   {"same-sign K=80 n=0 (irrep -i) [Magnus/MatrixExp]", 80, 1, 1, "same-sign K=80 n=0 (irrep -i)", 0, "mag", 10^-5},
   {"same-sign K=80 n=2 (irrep -i) [Magnus/MatrixExp]", 80, 1, 1, "same-sign K=80 n=2 (irrep -i)", 0, "mag", 10^-5}};
Do[Module[{lab = c[[1]], K = c[[2]], m = c[[3]], eps = c[[4]], wM, prec = c[[6]], dw = c[[8]], s0, s1, s2, nz, sv, t1},
   wM = Abs[Select[mres, #[[1]] == c[[5]] &][[1, 3]]];      (* the positive level of the 16-component problem *)
   sv[x_] := If[c[[7]] === "nd", sv16[SetPrecision[x, prec + 10], K, m, eps, 2/100, 3, prec],
      sv16mag[N[x], K, m, eps, 0.02, 3., 5*10^-4]];
   t1 = First[AbsoluteTiming[s0 = sv[wM]]];
   s1 = sv[wM + dw]; s2 = sv[wM - dw];
   nz = Count[s0, x_ /; x < 10^-3 s0[[5]]];              (* scale-free: zero relative to the 5th singular value *)
   Print["   ", lab, ": w = ", num[wM, 16], "  smallest 5 singular values at w: ", sci /@ s0[[1 ;; 5]],
     "   at w +- ", sci[dw], ": ", sci /@ {s1[[1]], s2[[1]]}, "   (", Round[t1, 0.1], " s per evaluation)"];
   check[lab <> ": 16x16 multiplicity 4 at w (4 singular values < 1e-3 x the 5th), rising >= 10x at w +- " <> sci[dw] <>
       " (a sharp 4-fold minimum at the 30-digit 2x2 level)",
     nz == 4 && Min[s1[[1]], s2[[1]]] > 10 Max[s0[[1 ;; 4]]]]], {c, cases16}];

(* ---------------------------------------------------------------------------------------------
   3. thresholds with an independently written Pruefer-angle integration
   --------------------------------------------------------------------------------------------- *)
Print[""]; Print["3. Thresholds: Pruefer mismatch at the continuum edge w = R changes by crossing a multiple of Pi"];
deltaEdge[Kinf_?NumericQ, m_, th_] := Module[{R = Sqrt[Kinf^2 + m^2], al = ArcTan[m, Kinf], p, z, pz},
  (* p' = m cos 2p + K sin 2p - w; at w = R the decaying direction is the double fixed point p = al/2 *)
  pz = NDSolveValue[{p'[z] == m Cos[2 p[z]] + Kp[z, Kinf] Sin[2 p[z]] - R, p[3] == al/2}, p[0], {z, 0, 3},
    WorkingPrecision -> wp, PrecisionGoal -> 22, AccuracyGoal -> 22, MaxSteps -> 10^7];
  th + Pi/2 - pz];
thrRows = Select[ref, StringMatchQ[#[[1]], "threshold*"] &];
Do[Module[{Kc = SetPrecision[r[[2]], prec], sgn, lo, hi, n1, n2},
   sgn = If[StringContainsQ[r[[1]], "(+i)"], -1, 1];     (* irrep +i = block ODE with K -> -K *)
   lo = deltaEdge[sgn Kc (1 - 10^-6), 1, -Pi/4]/Pi;
   hi = deltaEdge[sgn Kc (1 + 10^-6), 1, -Pi/4]/Pi;
   Print["   ", r[[1]], ": K_c = ", num[r[[2]], 12], ";  Delta(R)/Pi at K_c(1 -+ 1e-6) = ", sci[lo], ", ", sci[hi]];
   check[r[[1]] <> ": Delta(R)/Pi crosses an integer between K_c (1 - 1e-6) and K_c (1 + 1e-6)",
     Floor[lo] =!= Floor[hi]]], {r, thrRows}];

Print[""];
Print["waveguide_check.wls: ", Length[log], " checks, ", Count[log, {_, True}], " PASS, ", Count[log, {_, False}], " FAIL   (",
  Round[AbsoluteTime[] - t0, 0.1], " s)"];
