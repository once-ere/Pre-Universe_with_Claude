(* make_reference_fermion.wls -- the Mathematica reference runs of the fermion fable in fable4d, written as CSV
   next to this script.  Self-locating; run from anywhere:
       wolframscript -file fable-cosmology/reference/make_reference_fermion.wls

   THE MODEL (Part VIII, Section 33 of claude-fable_Einstein-Rosen-2-Planes.nb).  fable4d = the 8-dimensional
   Bianchi-I system of Section 31 with the hidden sheet held fixed by the zero-energy stabilizing stress
   P_stab = -F_total/2 (Section 33): B = C = 1, v = 1, and the observer's equations are exactly the Friedmann
   equations 3 H_A^2 = kappa rho, H_A' = -(kappa/2)(rho + P_obs).  The fable is a homogeneous Kohn-Sham Fermi
   gas (g = 8 states per momentum, T = 0, momenta along the observed sheet) in the mean field of W(sigma):
       n = g kF^3/(6 pi^2),  sigma, eps, P = the Fermi-sea integrals of Section 33 at mass m,
       gap m = W'(sigma),  rho_f = eps + W - sigma W',  P_obs_f = P + sigma W' - W,  w_f = P_obs_f/rho_f,
   and the fable number is conserved, kF = kF0/a.  fable4d is ALGEBRAIC in a: the gap is local, and
       H_A(a)^2 = Omega_r0 a^-4 + Omega_b0 a^-3 + rho_f(a)       (H0 = 1, densities in units of rho_c0);
   only the age t(a) needs integrating, dt/dN = 1/H_A, N = ln a, with t(N0) = 1/(2 H_A(N0)) (radiation era).

   UNITS (hbar = c = k_B = 1).  Time in 1/H0, H0 = 100 h km/s/Mpc, h = 0.674; densities in rho_c0 = 3 H0^2 M_pl^2
   (M_pl the reduced Planck mass); masses and momenta in E_c = rho_c0^(1/4) (computed below from CODATA 2018
   constants, E_c = 2.46261e-3 eV); sigma and n in E_c^3.  Omega_r0 = Omega_gamma0 (1 + N_eff (7/8)(4/11)^(4/3))
   from T0 = 2.7255 K and N_eff = 3.046; Omega_b0 = omega_b/h^2 with omega_b = 0.02237 (Planck 2018), = 0.049243.
   These are the conventions of the Rust solver fable-cosmology/rust/fable_fermion (its constants.rs), so that its
   CSVs can be compared with these directly.

   THE TWO CASES (both flat):
     mass30eV : W = V0 + m0 sigma, m0 = 30 eV (the author's mass term) plus a bare Lambda V0.  kF0 from
                eps(kF0, m0) = 0.265 (the Fermi gas carries Omega = 0.265 today), V0 = 1 - 0.265 - Omega_b0 - Omega_r0.
                rho_f INCLUDES V0 (it is part of W); the gap is m = m0 exactly.  (The same case in the Rust solver:
                fable_fermion fable4d --potential lambda-mass --param m0_ev=30 --param omega_dm=0.265
                --a-start 1e-10 --points 701.)
     power    : W = m0 sigma + lam sigma^nu, nu = 1/2 (a mass-varying fermion), no bare Lambda.  Fixed by the
                values today: m_eff(a = 1) = m_today = 100 eV, eps(kF0, m_today) = 0.55 (the quasi-particle share),
                and flatness, rho_f(1) = 1 - Omega_b0 - Omega_r0, i.e. the condensate U = W - sigma W' =
                (1 - nu) lam sigma^nu carries U_today = 1 - 0.55 - Omega_b0 - Omega_r0.  Then
                    lam = U_today/((1 - nu) sigma_t^nu),   m0 = m_today - nu lam sigma_t^(nu - 1)   (sigma_t = sigma(kF0, m_today)),
                m0 = 27.1 eV > 0 and the gap m = m0 + nu lam sigma^(nu-1) has exactly one root (its left side minus
                right side is strictly increasing in m).  (The same case in the Rust solver: fable_fermion fable4d
                --potential power --param m_today_ev=100 --param nu=0.5 --param omega_dm=0.55 --a-start 1e-10 --points 701.)
   Grid: 701 points in N from ln(1e-10) to 0.  Columns: N, a, t, H_A, rho_f, P_obs_f, w_f, m_eff, sigma, kF_over_m.

   NUMERICS.  Every row is EXACT ALGEBRA evaluated at 40 significant digits: the Fermi-sea closed forms with exact
   inputs (Mathematica raises the working precision automatically across the cancellations of the
   non-relativistic regime), the power-law gap solved by Brent's method at 45 digits.  The age is integrated by
   NDSolve at WorkingPrecision 30 with the numerically stable series of the Fermi-sea integrals for kF/|m| < 1/4
   (and, for the power case, the gap solved inside the right-hand side).  The script cross-checks the series
   against the closed forms, the gap residual at every row, and the Friedmann closure today.                 *)
cfHere = DirectoryName[ExpandFileName[$InputFileName]];
$MaxExtraPrecision = 200;
wp = 40;

(* ------------------------------------------------------------------ constants and units *)
hbarJs = 1054571817/10^43;  cMs = 299792458;  eVJ = 1602176634/10^28;  Gsi = 667430/10^16;
kBeVK = (1380649/10^29)/eVJ;  auM = 149597870700;  mpcM = 648000/Pi auM 10^6;  hLittle = 674/1000;
TcmbK = 27255/10000;  Neff = 3046/1000;  gDeg = 8;
H0s = 100 hLittle 1000/mpcM;                              (* 1/s *)
H0eV = hbarJs H0s/eVJ;                                    (* eV *)
MplEV = Sqrt[hbarJs cMs^5/(8 Pi Gsi)]/eVJ;                (* reduced Planck mass, eV *)
rhoc0 = 3 H0eV^2 MplEV^2;                                 (* eV^4 *)
Ec = rhoc0^(1/4);                                         (* eV *)
Tg0 = kBeVK TcmbK;                                        (* eV *)
OmG = (Pi^2/15) Tg0^4/rhoc0;
OmR = SetPrecision[N[OmG (1 + Neff (7/8) (4/11)^(4/3)), 80], Infinity];
OmB = (2237/100000)/hLittle^2;                            (* omega_b/h^2, Planck 2018: the Rust solver's value *)
Print["E_c = rho_c0^(1/4) = ", N[Ec, 12], " eV;  1/H0 = ", N[1/(H0s 365.25 86400), 8], " yr"];
Print["Omega_gamma0 = ", N[OmG, 10], ",  Omega_r0 = ", N[OmR, 10], ",  Omega_b0 = ", N[OmB, 10]];

(* ------------------------------------------------------------------ the Fermi sea (T = 0, g states per momentum) *)
(* closed forms, used with exact or high-precision inputs *)
wFc[k_, m_] := Sqrt[k^2 + m^2];
Lc[k_, m_] := ArcSinh[k/Abs[m]];
nKS[k_] := gDeg k^3/(6 Pi^2);
sigC[k_, m_] := If[m == 0, 0, gDeg m/(4 Pi^2) (k wFc[k, m] - m^2 Lc[k, m])];
epsC[k_, m_] := gDeg/(16 Pi^2) (k wFc[k, m] (2 k^2 + m^2) - If[m == 0, 0, m^4 Lc[k, m]]);
pC[k_, m_]   := gDeg/(48 Pi^2) (k wFc[k, m] (2 k^2 - 3 m^2) + If[m == 0, 0, 3 m^4 Lc[k, m]]);
(* the series for x = kF/|m| < 1/4 (no cancellation), 60 terms: |x|^(2 j) < 10^-70 *)
serI1[x_] := Sum[Binomial[-1/2, j] x^(2 j + 3)/(2 j + 3), {j, 0, 60}];
serI2[x_] := Sum[Binomial[1/2, j] x^(2 j + 3)/(2 j + 3), {j, 0, 60}];
serI3[x_] := Sum[Binomial[-1/2, j] x^(2 j + 5)/(2 j + 5), {j, 0, 60}];
sigS[k_, m_] := If[k/Abs[m] < 1/4, gDeg m Abs[m]^2 serI1[k/Abs[m]]/(2 Pi^2), sigC[k, m]];
epsS[k_, m_] := If[k/Abs[m] < 1/4, gDeg Abs[m]^4 serI2[k/Abs[m]]/(2 Pi^2), epsC[k, m]];
pS[k_, m_]   := If[k/Abs[m] < 1/4, gDeg Abs[m]^4 serI3[k/Abs[m]]/(6 Pi^2), pC[k, m]];
(* the series and the closed forms agree: relative differences at 80-digit inputs, kF/|m| = 1/5 and 1/100 *)
Print["series vs closed forms at kF/m = 1/5, 1/100: they agree to at least ",
  Round[Min[Accuracy /@ Flatten[Table[With[{xx = SetPrecision[x, 80]},
     {sigS[xx, 1]/sigC[xx, 1] - 1, epsS[xx, 1]/epsC[xx, 1] - 1, pS[xx, 1]/pC[xx, 1] - 1}], {x, {1/5, 1/100}}]]]], " digits (relative)"];

(* ------------------------------------------------------------------ case 1: mass30eV *)
m0A = SetPrecision[N[30/Ec, 80], Infinity];                (* 30 eV in E_c, as an 80-digit exact rational *)
kF0A = SetPrecision[kk /. FindRoot[epsC[kk, m0A] == 265/1000, {kk, 1/20, 1/10}, WorkingPrecision -> 60, AccuracyGoal -> 50, PrecisionGoal -> 50], Infinity];
V0A = 1 - 265/1000 - OmB - OmR;
Print["mass30eV: m0 = ", N[m0A, 12], " E_c = 30 eV;  kF0 = ", N[kF0A, 16], " E_c = ", N[kF0A Ec, 10], " eV;  V0 = Omega_Lambda = ", N[V0A, 12]];
rowA[n_] := Module[{a = Exp[n], k, e, p, s, rho, pob},
  k = kF0A/a; e = epsC[k, m0A]; p = pC[k, m0A]; s = sigC[k, m0A];
  rho = e + V0A; pob = p - V0A;
  N[{n, a, 0, Sqrt[OmR/a^4 + OmB/a^3 + rho], rho, pob, pob/rho, m0A, s, k/m0A}, wp]];
HA[n_?NumericQ] := Module[{a = Exp[n], k}, k = kF0A/a; Sqrt[OmR/a^4 + OmB/a^3 + epsS[k, m0A] + V0A]];

(* ------------------------------------------------------------------ case 2: power, nu = 1/2 *)
nuP = 1/2;  mtP = SetPrecision[N[100/Ec, 80], Infinity];  OmQP = 55/100;
kF0P = SetPrecision[kk /. FindRoot[epsC[kk, mtP] == OmQP, {kk, 1/20, 1/10}, WorkingPrecision -> 60, AccuracyGoal -> 50, PrecisionGoal -> 50], Infinity];
sigT = N[sigC[kF0P, mtP], 60];
Ut = 1 - OmQP - OmB - OmR;
lamP = SetPrecision[Ut/((1 - nuP) sigT^nuP), Infinity];
m0P = SetPrecision[mtP - nuP lamP sigT^(nuP - 1), Infinity];
Print["power: nu = 1/2, m_today = 100 eV, eps_today = 0.55;  kF0 = ", N[kF0P, 16], " E_c;  lam = ", N[lamP, 16],
  " E_c^(5/2);  m0 = ", N[m0P, 16], " E_c = ", N[m0P Ec, 10], " eV;  U_today = ", N[Ut, 12]];
WP[s_] := m0P s + lamP s^nuP;  dWP[s_] := m0P + nuP lamP s^(nuP - 1);
(* the gap m = W'(sigma(kF, m)): f(m) = m - W'(sigma) is strictly increasing; bracket by doubling, then Brent *)
gapP[k_, sig_] := Module[{f, lo, hi, kk = SetPrecision[k, 50]},
  f[mm_?NumericQ] := mm - dWP[sig[kk, mm]];
  lo = m0P/2; While[f[lo] >= 0, lo = lo/2];
  hi = 2 m0P; While[f[hi] <= 0, hi = 2 hi];
  mm /. FindRoot[f[mm], {mm, lo, hi}, Method -> "Brent", WorkingPrecision -> 45, AccuracyGoal -> 40, PrecisionGoal -> 40]];
rowP[n_] := Module[{a = Exp[n], k, m, e, p, s, U, rho, pob},
  k = kF0P/a; m = SetPrecision[gapP[k, sigC], 80]; e = epsC[k, m]; p = pC[k, m]; s = sigC[k, m];
  U = WP[s] - s dWP[s]; rho = e + U; pob = p - U;
  N[{n, a, 0, Sqrt[OmR/a^4 + OmB/a^3 + rho], rho, pob, pob/rho, m, s, k/m, m - dWP[s]}, wp]];
HP[n_?NumericQ] := Module[{a = Exp[SetPrecision[n, 50]], k, m, s},
  k = kF0P/a; m = gapP[k, sigS]; s = sigS[k, m];
  N[Sqrt[OmR/a^4 + OmB/a^3 + epsS[k, m] + WP[s] - s dWP[s]], 45]];

(* ------------------------------------------------------------------ the grid, the rows, the age *)
n0 = Log[10^-10]; n1 = 0; npts = 701;
grid = Table[n0 + (n1 - n0) j/(npts - 1), {j, 0, npts - 1}];
(* the age: u = ln t, du/dN = 1/(t H) = Exp[-u]/H, u(N0) = -ln(2 H(N0)); relative accuracy of t is uniform *)
ageBy[Hf_] := Module[{sol, u},
  sol = NDSolve[{u'[nn] == Exp[-u[nn]]/Hf[nn], u[n0] == -Log[2 Hf[n0]]}, u, {nn, n0, n1},
     WorkingPrecision -> 30, PrecisionGoal -> 20, AccuracyGoal -> 20, MaxSteps -> 10^6, InterpolationOrder -> All][[1]];   (* dense output of the method's own order *)
  Table[Exp[u[nn] /. sol], {nn, grid}]];
{tA, rowsA} = AbsoluteTiming[rowA /@ grid];
{tAa, ageA} = AbsoluteTiming[ageBy[HA]];
rowsA[[All, 3]] = ageA;
Print["mass30eV: rows in ", Round[tA, 0.1], " s, age in ", Round[tAa, 0.1], " s;  today: H_A = ", N[rowsA[[-1, 4]], 16],
  ", rho_f = ", N[rowsA[[-1, 5]], 16], ", w_f = ", N[rowsA[[-1, 7]], 16], ", t0 = ", N[rowsA[[-1, 3]], 16]];
Print["mass30eV checks: |H_A(1) - 1| = ", N[Abs[rowsA[[-1, 4]] - 1], 3], ";  w_f(a_i) = ", N[rowsA[[1, 7]], 12], " (ultra-relativistic: 1/3 - O((m/kF)^2))",
  ";  H_A from the closed forms and from the series (NDSolve's right-hand side) agree to at least ",
  Round[Min[Table[Accuracy[(rowsA[[j, 4]] - HA[SetPrecision[grid[[j]], 60]])/rowsA[[j, 4]]], {j, 1, npts, 10}]]], " digits"];
{tP, rowsPx} = AbsoluteTiming[rowP /@ grid];
Print["power: rows in ", Round[tP, 0.1], " s;  max |gap residual|/m = ", N[Max[Abs[rowsPx[[All, 11]]/rowsPx[[All, 8]]]], 3]];
rowsP = rowsPx[[All, 1 ;; 10]];
{tPa, ageP} = AbsoluteTiming[ageBy[HP]];
rowsP[[All, 3]] = ageP;
Print["power: age in ", Round[tPa, 0.1], " s;  today: H_A = ", N[rowsP[[-1, 4]], 16], ", rho_f = ", N[rowsP[[-1, 5]], 16], ", w_f = ", N[rowsP[[-1, 7]], 16],
  ", m_eff = ", N[rowsP[[-1, 8]] Ec, 12], " eV, t0 = ", N[rowsP[[-1, 3]], 16]];
Print["power checks: |H_A(1) - 1| = ", N[Abs[rowsP[[-1, 4]] - 1], 3], ";  m_eff(a_i) = ", N[rowsP[[1, 8]] Ec, 12], " eV;  m_eff(1)/m_today - 1 = ", N[rowsP[[-1, 8]]/mtP - 1, 3]];

(* ------------------------------------------------------------------ write *)
hdr = {"N", "a", "t", "H_A", "rho_f", "P_obs_f", "w_f", "m_eff", "sigma", "kF_over_m"};
Export[cfHere <> "mathematica_fable4d_mass30eV.csv", Prepend[Map[N, rowsA, {2}], hdr], "CSV"];
Export[cfHere <> "mathematica_fable4d_power.csv", Prepend[Map[N, rowsP, {2}], hdr], "CSV"];
Print["wrote mathematica_fable4d_mass30eV.csv and mathematica_fable4d_power.csv (", npts, " rows each)"];
