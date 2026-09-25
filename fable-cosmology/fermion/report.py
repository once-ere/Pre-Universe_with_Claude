#!/usr/bin/env python3
"""report.py -- run fable_fermion for the development parameter sets and write
fable-cosmology/fermion/dev/REPORT.txt (plain text) with every command, the stats lines and the
key numbers, plus a few PNG plots in the same folder.

    fable-cosmology/.venv/Scripts/python.exe fable-cosmology/fermion/report.py

Definitions used here (all read from the CSV columns):
  a_nr          first a with kF/|m_eff| <= 1 (linear interpolation in N)
  N_eff_extra   rho_f / rho_nu(1 species) at a_BBN = T_nu0 / 1 MeV and at a_rec = 1/1091
  CPL fits      least squares of w(a) = w0 + wa (1 - a) over the output rows with 0.3 <= a <= 1
                (uniform in ln a); for w_DE_eff and w_DE_inf the rows where the subtracted density
                is within 1e-3 of zero (|rho_DE| < 1e-3 rho_total) are excluded, sign changes of
                rho_DE are listed as crossings, and when rho_DE crosses zero inside [0.3, 1] (a pole
                of w_DE) the fit is restricted to a >= 1.05 x the last crossing
  Delta G/G     G(a2)/G(a1) - 1 from the G_ratio column (G_4 = G_8/(B^3 C)); |dlnG/dt| today =
                |3 H_B + H_C| H0, H0 in 1/yr
"""
import math
import os
import re
import subprocess
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
DEV = os.path.join(HERE, "dev")
EXE = os.path.abspath(os.path.join(HERE, "..", "rust", "fable_fermion", "target", "release",
                                   "fable_fermion.exe" if os.name == "nt" else "fable_fermion"))
LLR = 1e-13      # |dG/dt|/G bound today, 1/yr (lunar laser ranging)
BBN_DG = 0.1     # |Delta G/G| bound between BBN and today (order of magnitude)


def read_csv(path):
    comments, rows, hdr = [], [], None
    with open(path) as fh:
        for line in fh:
            if line.startswith("#"):
                comments.append(line[1:].strip())
            elif hdr is None:
                hdr = line.strip().split(",")
            else:
                rows.append([float(x) for x in line.split(",")])
    d = np.array(rows)
    return comments, {h: d[:, i] for i, h in enumerate(hdr)}


def interp_at(c, name, a):
    """Cubic interpolation in N on the 8 nearest rows (the CSV grid is uniform in N)."""
    from scipy.interpolate import CubicSpline
    N = c["N"]
    x = math.log(a)
    if x < N[0] or x > N[-1]:
        return float("nan")
    k = int(np.searchsorted(N, x))
    lo, hi = max(0, k - 4), min(len(N), k + 4)
    y = c[name][lo:hi]
    if not np.all(np.isfinite(y)):
        return float(np.interp(x, N, c[name]))
    return float(CubicSpline(N[lo:hi], y)(x))


def first_crossing(c, name, level):
    N, y = c["N"], c[name] - level
    for k in range(1, len(N)):
        if np.isfinite(y[k - 1]) and np.isfinite(y[k]) and y[k - 1] * y[k] <= 0 and y[k - 1] != y[k]:
            return math.exp(N[k - 1] + (N[k] - N[k - 1]) * y[k - 1] / (y[k - 1] - y[k]))
    return float("nan")


def cpl(c, wname, rho_name=None):
    a = c["a"]
    sel = (a >= 0.3) & (a <= 1.0) & np.isfinite(c[wname])
    notes = []
    if rho_name is not None:
        rho_tot = c["rho_r"] + c["rho_b"] + c["rho_f"]
        near = np.abs(c[rho_name]) < 1e-3 * rho_tot
        sel &= ~near
        r = c[rho_name]
        cross = [a[k] for k in range(1, len(a)) if r[k - 1] * r[k] < 0]
        if cross:
            notes.append("rho crosses zero at a = " + ", ".join(f"{x:.4g}" for x in cross[:6]))
            inside = [x for x in cross if 0.3 <= x <= 1.0]
            if inside:
                # w_DE has a pole at the crossing: fit only above the last crossing (with a 5 % margin)
                amin = 1.05 * max(inside)
                sel &= a >= amin
                notes.append(f"fit restricted to {amin:.3g} <= a <= 1")
    if sel.sum() < 3:
        return float("nan"), float("nan"), "too few rows"
    X = np.vstack([np.ones(sel.sum()), 1 - a[sel]]).T
    w0, wa = np.linalg.lstsq(X, c[wname][sel], rcond=None)[0]
    return w0, wa, "; ".join(notes)


def negative_ranges(c, name):
    a, y = c["a"], c[name]
    neg = np.isfinite(y) & (y < 0)
    out, k = [], 0
    while k < len(a):
        if neg[k]:
            j = k
            while j + 1 < len(a) and neg[j + 1]:
                j += 1
            out.append((a[k], a[j]))
            k = j + 1
        else:
            k += 1
    return out


def run(tag, args, lines, results, expect_fail=False):
    path = os.path.join(DEV, f"rep_{tag}.csv")
    cmd = [EXE] + args + ["--out", path]
    shown = "fable_fermion " + " ".join(args) + f" --out fermion/dev/rep_{tag}.csv"
    t0 = time.time()
    r = subprocess.run(cmd, capture_output=True, text=True)
    dt = time.time() - t0
    lines.append(f"$ {shown}")
    log = [l for l in r.stderr.splitlines() if l.startswith("#") or l.startswith("fable_fermion:")]
    if r.returncode != 0:
        lines.append(f"  -> exit {r.returncode} ({'expected' if expect_fail else 'UNEXPECTED'}): " + " | ".join(l for l in r.stderr.splitlines() if l.startswith("fable_fermion:")))
        results[tag] = None
        return None
    keep = [l for l in log if l.startswith("# stats") or "result:" in l or "unstabilized fable8d" in l or "a_nr" in l
            or "Delta N_eff" in l or "cross-check" in l or "shooting converged" in l or "WARNING" in l
            or "NOTE" in l or "ground-state" in l]
    for l in keep:
        lines.append("  " + l)
    lines.append(f"  (wall {dt:.2f} s)")
    comments, c = read_csv(path)
    results[tag] = (comments, c, log)
    return c


def summarize(tag, c, log, u):
    s = {}
    s["m_today_eV"] = c["m_eff_eV"][-1]
    s["kF0_eV"] = c["kF_eV"][-1]
    s["a_nr"] = first_crossing(c, "kF_over_m", 1.0)
    s["Neff_BBN"] = interp_at(c, "N_eff_extra", u["a_bbn"])
    s["Neff_rec"] = interp_at(c, "N_eff_extra", u["a_rec"])
    # the radiation-like content: 3 P_KS / rho_nu1 (P_KS/v = P_obs_f + rho_U); rho_nu1 = rho_f/N_eff_extra
    pr = 3 * (c["P_obs_f"] + c["rho_U"]) * c["N_eff_extra"] / c["rho_f"]
    s["Neff_rec_pressure"] = interp_at(dict(N=c["N"], y=pr), "y", u["a_rec"])
    for a in (1e-6, 1e-3, 0.3, 0.5, 1.0):
        s[f"w_f({a:g})"] = interp_at(c, "w_f", a)
    s["cpl_wf"] = cpl(c, "w_f")
    s["cpl_wDEeff"] = cpl(c, "w_DE_eff", "rho_DE_eff")
    s["cpl_wDEinf"] = cpl(c, "w_DE_inf", "rho_DE_inf")
    cs = c["cs2_adiabatic"]
    s["cs2_min"] = (np.nanmin(cs), c["a"][np.nanargmin(cs)]) if np.isfinite(cs).any() else (float("nan"), float("nan"))
    s["cs2_neg"] = negative_ranges(c, "cs2_adiabatic")
    g1e10, g1 = interp_at(c, "G_ratio", 1e-10), c["G_ratio"][-1]
    gbbn = interp_at(c, "G_ratio", u["a_bbn"])
    s["dG_1e-10_to_1"] = g1 / g1e10 - 1 if np.isfinite(g1e10) else float("nan")
    s["dG_BBN_to_1"] = g1 / gbbn - 1 if np.isfinite(gbbn) else float("nan")
    s["G(1e-10)/G(1)"] = g1e10 / g1
    s["G(BBN)/G(1)"] = gbbn / g1
    s["max|H_B/H_A|"] = float(np.max(np.abs(c["H_B"] / c["H_A"])))
    s["Gdot_today_per_yr"] = abs(3 * c["H_B"][-1] + c["H_C"][-1]) * u["h0_per_yr"]
    s["constraint_max"] = np.nanmax(np.abs(c["constraint_residual"]))
    s["q0"] = c["q_dec"][-1]
    s["t0_Gyr"] = c["t"][-1] / u["h0_per_yr"] / 1e9
    vac = c["vac_over_rhoc"]
    rho_tot = c["rho_r"] + c["rho_b"] + c["rho_f"]
    ratio = np.abs(vac) / rho_tot
    late = c["a"] >= 0.3
    s["vac/rho_tot max (a>=0.3)"] = float(np.nanmax(ratio[late]))
    k = int(np.nanargmax(ratio))
    s["vac/rho_tot max (all a)"] = float(ratio[k])
    s["  at a"] = float(c["a"][k])
    s["vac/rho_c at a=0.5"] = interp_at(c, "vac_over_rhoc", 0.5)
    s["wDMeff_range"] = (np.nanmin(c["w_DM_eff"]), np.nanmax(c["w_DM_eff"]))
    s["Omega_f0"] = c["Omega_f"][-1]
    s["rho_U0"] = c["rho_U"][-1]
    s["w_DE_inf(1)"] = c["w_DE_inf"][-1]
    s["P_stab0"] = c["P_stab"][-1]
    return s


def fmt(x, p=4):
    if isinstance(x, tuple):
        return "(" + ", ".join(fmt(y, p) for y in x) + ")"
    if x is None:
        return "-"
    if isinstance(x, str):
        return x
    if not np.isfinite(x):
        return "nan"
    return f"{x:.{p}g}"


def main():
    os.makedirs(DEV, exist_ok=True)
    cons = subprocess.run([EXE, "--constants"], capture_output=True, text=True).stdout
    ver = subprocess.run([EXE, "--version"], capture_output=True, text=True).stdout.strip()
    get = lambda key, i=0: float(re.findall(r"=\s+([-+]?\d[\d.]*e[-+]?\d+)", [l for l in cons.splitlines() if l.startswith(key)][0])[i])
    u = dict(h0_per_yr=get("H0", 1), a_bbn=get("a_BBN"), a_rec=get("a_rec"))
    lines, results, table = [], {}, []
    L = lines.append
    L("FABLE_FERMION DEVELOPMENT REPORT")
    L("================================")
    L(f"generated {time.strftime('%Y-%m-%d %H:%M:%S')} by fable-cosmology/fermion/report.py")
    L(f"binary: {ver}")
    L("")
    L("1. UNIT SYSTEM (fable_fermion --constants)")
    for l in cons.splitlines():
        L("  " + l)
    L("")
    L("2. RUNS (command, then the solver's own log lines: normalization, result, stats)")
    L("")

    runs = []
    # (A) mass + bare Lambda (lambda-mass), Omega_dm = 0.265
    for m in (1, 30, 1000):
        runs.append((f"lm{m}_4d", ["fable4d", "--potential", "lambda-mass", "--param", f"m0_ev={m}"], f"lambda-mass m0={m} eV, fable4d"))
        runs.append((f"lm{m}_4d_bw", ["fable4d", "--potential", "lambda-mass", "--param", f"m0_ev={m}", "--direction", "backward"], f"lambda-mass m0={m} eV, fable4d backward"))
        runs.append((f"lm{m}_8d", ["fable8d", "--potential", "lambda-mass", "--param", f"m0_ev={m}"], f"lambda-mass m0={m} eV, fable8d (unstabilized)"))
    # (B) the potential supplies DE: Omega_f0 = 0.265 (qp) + closure
    for m in (1, 30):
        for nu in (0.236, 0.5):
            runs.append((f"pw{nu}_m{m}_4d", ["fable4d", "--potential", "power", "--param", f"nu={nu}", "--param", f"m_today_ev={m}"], f"power nu={nu}, m_today={m} eV, fable4d"))
            runs.append((f"pw{nu}_m{m}_8d", ["fable8d", "--potential", "power", "--param", f"nu={nu}", "--param", f"m_today_ev={m}"], f"power nu={nu}, m_today={m} eV, fable8d"))
        runs.append((f"ed_m{m}_4d", ["fable4d", "--potential", "expdamp", "--param", f"m_today_ev={m}"], f"expdamp xt=1/2.21, m_today={m} eV, fable4d"))
        runs.append((f"ed_m{m}_8d", ["fable8d", "--potential", "expdamp", "--param", f"m_today_ev={m}"], f"expdamp xt=1/2.21, m_today={m} eV, fable8d"))
        runs.append((f"qd_m{m}_4d", ["fable4d", "--potential", "quadratic", "--param", "gq=-0.5", "--param", f"m_today_ev={m}"], f"quadratic gq=-0.5 (attractive) + bare V0, m_today={m} eV, fable4d"))
        runs.append((f"qd_m{m}_8d", ["fable8d", "--potential", "quadratic", "--param", "gq=-0.5", "--param", f"m_today_ev={m}"], f"quadratic gq=-0.5 + bare V0, m_today={m} eV, fable8d"))
    # (C) the author's mass term alone (no V0): Einstein-de Sitter-like
    for m in (1, 100):
        runs.append((f"mass{m}_4d", ["fable4d", "--potential", "mass", "--param", f"m0_ev={m}"], f"mass m0={m} eV (no V0), fable4d"))
        runs.append((f"mass{m}_8d", ["fable8d", "--potential", "mass", "--param", f"m0_ev={m}"], f"mass m0={m} eV (no V0), fable8d"))
    # (D) frozen-hidden theorem: pure W = (lam/2) sigma^2, radiation only
    lam = 100 * 4 * math.pi ** 2 / 8
    runs.append(("frozen_quad_lowest", ["fable8d", "--no-shoot", "--potential", "quadratic", "--param", "m0=0", "--param", f"lam={lam}", "--param", "kf0=1", "--omega-b", "0"], "pure (lam/2) sigma^2, lowest branch, radiation only"))
    runs.append(("frozen_quad_positive", ["fable8d", "--no-shoot", "--potential", "quadratic", "--param", "m0=0", "--param", f"lam={lam}", "--param", "kf0=1", "--omega-b", "0", "--branch", "positive"], "pure (lam/2) sigma^2, non-trivial (m > 0) branch, radiation only"))
    runs.append(("frozen_rad", ["fable8d", "--no-fable", "--omega-b", "0"], "radiation only"))
    runs.append(("dust_rad", ["fable8d", "--no-fable"], "radiation + baryons (dust) only"))
    # (E) insensitivity to a_start
    for ai in ("1e-12", "1e-10", "1e-8"):
        runs.append((f"as{ai}_8d", ["fable8d", "--potential", "lambda-mass", "--param", "m0_ev=30", "--a-start", ai], f"lambda-mass 30 eV fable8d, a_start={ai}"))
        runs.append((f"as{ai}_4d", ["fable4d", "--potential", "lambda-mass", "--param", "m0_ev=30", "--a-start", ai], f"lambda-mass 30 eV fable4d, a_start={ai}"))
    # (F) excluded cases (the solver refuses them, with the physical reason)
    fails = [
        ("qd_rep_4d", ["fable4d", "--potential", "quadratic", "--param", "gq=0.5"], "quadratic gq=+0.5 (repulsive)"),
        ("lorentz_4d", ["fable4d", "--potential", "lorentz"], "lorentz xt=1/1.5"),
        ("lorentz_8d", ["fable8d", "--potential", "lorentz"], "lorentz xt=1/1.5, fable8d"),
        ("bw_8d", ["fable8d", "--potential", "mass", "--direction", "backward"], "fable8d backward"),
    ]
    descr = {}
    for tag, args, d in runs:
        descr[tag] = d
        L(f"[{tag}] {d}")
        run(tag, args, lines, results)
        L("")
    L("Excluded / refused cases:")
    for tag, args, d in fails:
        L(f"[{tag}] {d}")
        run(tag, args, lines, results, expect_fail=True)
        L("")

    # ---------------------------------------------------------------- key table
    L("")
    L("3. KEY NUMBERS")
    L("")
    L("Columns: m_eff(1) [eV]; kF0 [eV]; a_nr (kF = |m_eff|); DeltaN_eff at BBN (T = 1 MeV) and at")
    L("recombination; w_f at a = 1e-6, 1e-3, 0.3, 0.5, 1; CPL (w0, wa) of w_f, w_DE_eff, w_DE_inf over")
    L("0.3 <= a <= 1; min cs2 and the a-ranges with cs2 < 0; Delta G/G from a = 1e-10 and from BBN to 1;")
    L("G(1e-10)/G(1), G(BBN)/G(1); |dlnG/dt| today [1/yr]; max |H_B/H_A|; max |constraint residual|; q0; t0 [Gyr];")
    L("the neglected renormalized Dirac-sea energy |DeltaE_vac|/rho_total (max over a >= 0.3, max over the run and")
    L("where) and DeltaE_vac/rho_c at a = 0.5; w_DM_eff range; Omega_f0; rho_U(1); P_stab(1).")
    L("Neff_rec counts the fable's full energy (rest mass included); Neff_rec_pressure = 3 P_KS/rho_nu1 is its")
    L("radiation-like content, the quantity the CMB damping tail constrains.")
    L("")
    summaries = {}
    for tag, args, d in runs:
        if results.get(tag) is None:
            continue
        comments, c, log = results[tag]
        if "rho_f" not in c or not np.any(c["rho_f"] != 0):
            s = dict(Gdot_today_per_yr=abs(3 * c["H_B"][-1] + c["H_C"][-1]) * u["h0_per_yr"],
                     dG_BBN_to_1=c["G_ratio"][-1] / interp_at(c, "G_ratio", u["a_bbn"]) - 1,
                     dG_1e10=c["G_ratio"][-1] / interp_at(c, "G_ratio", 1e-10) - 1,
                     HB_over_HA_max=float(np.max(np.abs(c["H_B"] / c["H_A"]))),
                     constraint_max=float(np.nanmax(np.abs(c["constraint_residual"]))))
            summaries[tag] = s
            L(f"[{tag}] {d}")
            for k, v in s.items():
                L(f"    {k:22s} = {fmt(v, 6)}")
            L("")
            continue
        s = summarize(tag, c, log, u)
        summaries[tag] = s
        L(f"[{tag}] {d}")
        order = ["m_today_eV", "kF0_eV", "a_nr", "Neff_BBN", "Neff_rec", "Neff_rec_pressure", "w_f(1e-06)", "w_f(0.001)", "w_f(0.3)", "w_f(0.5)", "w_f(1)",
                 "cpl_wf", "cpl_wDEeff", "cpl_wDEinf", "cs2_min", "cs2_neg", "dG_1e-10_to_1", "dG_BBN_to_1", "G(1e-10)/G(1)", "G(BBN)/G(1)",
                 "Gdot_today_per_yr", "max|H_B/H_A|", "constraint_max", "q0", "t0_Gyr", "vac/rho_tot max (a>=0.3)", "vac/rho_tot max (all a)", "  at a",
                 "vac/rho_c at a=0.5", "wDMeff_range", "Omega_f0", "rho_U0", "w_DE_inf(1)", "P_stab0"]
        for k in order:
            v = s[k]
            if k == "cs2_neg":
                v = "none" if not v else "; ".join(f"[{x:.3g}, {y:.3g}]" for x, y in v[:5]) + (" ..." if len(v) > 5 else "")
            L(f"    {k:22s} = {fmt(v, 6)}")
        L("")

    # ---------------------------------------------------------------- compact table
    L("4. COMPACT TABLE (fable4d = the stabilized, physical model; 8d = the unstabilized no-go)")
    L("")
    hdr = f"{'run':18s} {'m_eff(1)eV':>10s} {'a_nr':>9s} {'dNeffBBN':>9s} {'dNeffRecP':>9s} {'w(1e-6)':>8s} {'w(1e-3)':>8s} {'w(0.3)':>8s} {'w(0.5)':>8s} {'w(1)':>8s} {'w0,wa (w_f)':>16s} {'w0,wa (DE,inf)':>16s} {'min cs2':>9s} {'G(1e-10)/G(1)':>13s} {'|Gdot/G| /yr':>12s} {'max|C|':>8s}"
    L(hdr)
    for tag, args, d in runs:
        s = summaries.get(tag)
        if s is None or "m_today_eV" not in s:
            continue
        w = s["cpl_wf"]
        wi = s["cpl_wDEinf"]
        L(f"{tag:18s} {s['m_today_eV']:10.4g} {s['a_nr']:9.3g} {s['Neff_BBN']:9.3g} {s['Neff_rec_pressure']:9.3g} {s['w_f(1e-06)']:8.4f} {s['w_f(0.001)']:8.4f} {s['w_f(0.3)']:8.4f} {s['w_f(0.5)']:8.4f} {s['w_f(1)']:8.4f} {w[0]:7.3f},{w[1]:7.3f}  {wi[0]:7.3f},{wi[1]:7.3f}  {s['cs2_min'][0]:9.3g} {s['G(1e-10)/G(1)']:13.4g} {s['Gdot_today_per_yr']:12.4g} {s['constraint_max']:8.2g}")
    L("")
    L("Reference: Unite (DESI-like) CPL (w0, wa) = (-0.861, -0.60); w(z = 0) quoted -0.764 elsewhere; bounds:")
    L(f"|dlnG/dt| < {LLR:g} /yr (lunar laser ranging), |Delta G/G| (BBN -> today) < ~{BBN_DG:g}; Delta N_eff < ~0.3 (Planck).")
    L("")

    # ---------------------------------------------------------------- a_start insensitivity
    L("5. INSENSITIVITY TO a_start (lambda-mass 30 eV)")
    for kind in ("8d", "4d"):
        vals = []
        for ai in ("1e-12", "1e-10", "1e-8"):
            r = results.get(f"as{ai}_{kind}")
            if r is None:
                continue
            c = r[1]
            vals.append((ai, c["H_B"][-1], c["rho_f"][-1], c["rho_U"][-1], c["q_dec"][-1], c["t"][-1], interp_at(c, "w_f", 0.5)))
        for v in vals:
            L(f"  fable{kind} a_start={v[0]:>6s}: H_B(1)={v[1]:.12e} rho_f(1)={v[2]:.12e} rho_U(1)={v[3]:.12e} q0={v[4]:.12e} t0={v[5]:.12e} w_f(0.5)={v[6]:.12e}")
    L("")
    with open(os.path.join(DEV, "REPORT_runs.txt"), "w") as fh:
        fh.write("\n".join(lines) + "\n")
    print("\n".join(lines))
    make_plots(results, descr)


def make_plots(results, descr):
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except Exception as e:  # pragma: no cover
        print("no plots:", e)
        return
    fig, ax = plt.subplots(1, 2, figsize=(12, 4.5))
    for tag in ("lm1_4d", "lm30_4d", "lm1000_4d", "pw0.236_m1_4d", "pw0.5_m1_4d", "ed_m1_4d", "qd_m1_4d"):
        r = results.get(tag)
        if r is None:
            continue
        c = r[1]
        ax[0].semilogx(c["a"], c["w_f"], label=tag)
        ax[1].semilogx(c["a"], c["N_eff_extra"], label=tag)
    ax[0].set_xlabel("a")
    ax[0].set_ylabel("w_f = P_obs/rho (fable4d)")
    ax[0].legend(fontsize=7)
    ax[1].set_xlabel("a")
    ax[1].set_ylabel("Delta N_eff (fable)")
    ax[1].set_yscale("log")
    fig.tight_layout()
    fig.savefig(os.path.join(DEV, "rep_w_and_neff.png"), dpi=120)
    fig, ax = plt.subplots(figsize=(6, 4.5))
    for tag in ("lm1_8d", "lm30_8d", "mass100_8d", "dust_rad", "frozen_rad"):
        r = results.get(tag)
        if r is None:
            continue
        c = r[1]
        ax.loglog(c["a"], c["G_ratio"], label=tag)
    ax.set_xlabel("a")
    ax.set_ylabel("G_4(a)/G_4(today) (unstabilized fable8d)")
    ax.legend(fontsize=7)
    fig.tight_layout()
    fig.savefig(os.path.join(DEV, "rep_G_8d.png"), dpi=120)


if __name__ == "__main__":
    main()
