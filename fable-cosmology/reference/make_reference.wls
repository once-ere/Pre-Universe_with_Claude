(* make_reference.wls -- the third, independent integrator: Mathematica NDSolve on the two reference
   cases of DESIGN.md section 5, written as CSV next to this script.  Self-locating; run from anywhere:
       wolframscript -file fable-cosmology/reference/make_reference.wls
   Units: 8 pi G = 1, H0 = 1, rho_crit = 3; N = Log[a]; the same equations, parameters and initial
   conditions as fable_cosmo (Model A: scalar-flrw exp, Model B: spinor-flrw expdamp).             *)
cfHere = DirectoryName[ExpandFileName[$InputFileName]];
om = 3/10; orr = 84/10^6; n0 = -7; n1 = 0; npts = 701;
grid = Table[n0 + (n1 - n0) k/(npts - 1), {k, 0, npts - 1}];
(* machine numbers: Export writes them with 16 significant digits.  The Quiet is needed because
   Model B's H column at an exact N is an exact expression whose term Exp[-s/s1] (s ~ 1.3e9 at
   N = -7) underflows when N[] takes it to machine precision; the value is unaffected, but
   without the Quiet the run printed three General::munfl messages and a General::stop. *)
fmt[x_] := Quiet[N[x], General::munfl];

(* ---------------------------------------------------------------- Model A: exp, lambda = 1, V0 as normalised by the solver *)
v0A = SetPrecision[2.6871520526047146, 30]; lam = 1;   (* the solver's normalised V0, at the working precision *)
VA[p_] := v0A Exp[-lam p]; dVA[p_] := -lam v0A Exp[-lam p];
HA[n_, p_, pd_] := Sqrt[om Exp[-3 n] + orr Exp[-4 n] + (pd^2/2 + VA[p])/3];
solA = NDSolve[{phi'[n] == phid[n]/HA[n, phi[n], phid[n]],
    phid'[n] == -3 phid[n] - dVA[phi[n]]/HA[n, phi[n], phid[n]],
    tt'[n] == 1/HA[n, phi[n], phid[n]],
    phi[n0] == 0, phid[n0] == 0, tt[n0] == 0}, {phi, phid, tt}, {n, n0, n1},
   WorkingPrecision -> 24, PrecisionGoal -> 15, AccuracyGoal -> 15, MaxSteps -> 10^6][[1]];
tAge0A = 1/(2 HA[n0, 0, 0]);
rowsA = Table[With[{p = phi[n] /. solA, pd = phid[n] /. solA, t = (tt[n] /. solA) + tAge0A},
    {n, Exp[n], t, p, pd, HA[n, p, pd], (pd^2/2 - VA[p])/(pd^2/2 + VA[p])}], {n, grid}];
Export[cfHere <> "mathematica_scalar_exp.csv", Prepend[Map[fmt, rowsA, {2}], {"N", "a", "t", "phi", "phidot", "H", "w_phi"}], "CSV"];
Print["mathematica_scalar_exp.csv: ", Length[rowsA], " rows;  w(a=1) = ", N[rowsA[[-1, -1]]]];

(* ---------------------------------------------------------------- Model B: expdamp (1.566, 0.839, 2.21), no normalisation *)
v0B = 1566/1000; mB = 839/1000; s1B = 221/100;
VB[s_] := v0B + mB s Quiet[Exp[-s/s1B], General::munfl]; dVB[s_] := mB (1 - s/s1B) Quiet[Exp[-s/s1B], General::munfl];
HB[n_] := Sqrt[om Exp[-3 n] + orr Exp[-4 n] + VB[Exp[-3 n]]/3];
solB = Quiet[NDSolve[{tt'[n] == 1/HB[n], tt[n0] == 0}, tt, {n, n0, n1},
   WorkingPrecision -> 24, PrecisionGoal -> 15, AccuracyGoal -> 15, MaxSteps -> 10^6], General::munfl][[1]];
tAge0B = 1/(2 HB[n0]);
rowsB = Quiet[Table[With[{s = N[Exp[-3 n], 24]}, {n, Exp[n], (tt[n] /. solB) + tAge0B, s, HB[n], VB[s], s dVB[s]/VB[s] - 1}], {n, grid}], General::munfl];
Export[cfHere <> "mathematica_spinor_expdamp.csv", Prepend[Map[fmt, rowsB, {2}], {"N", "a", "t", "s", "H", "rho_Psi", "w_Psi"}], "CSV"];
Print["mathematica_spinor_expdamp.csv: ", Length[rowsB], " rows;  w(a=1) = ", N[rowsB[[-1, -1]]], "  min w = ", N[Min[rowsB[[All, -1]]]]];
