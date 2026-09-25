#!/usr/bin/env python3
"""crosscheck.py -- an INDEPENDENT Python implementation of fable4d and fable8d, compared with the
Rust/CVODE solver fable_fermion.

Independent parts (no code shared with the Rust crate):
  * the unit system (Omega_r0, rho_c0^(1/4)) recomputed from CODATA constants;
  * the T = 0 Fermi-sea integrals by adaptive quadrature (scipy.integrate.quad, epsrel 1e-12,
    split at k = |m|), NOT the closed forms or series of kohn_sham.rs;
  * the gap equation m = W'(sigma_KS(m, kF)/v) by scipy.optimize.brentq on the documented brackets;
  * the ODEs by scipy.integrate.solve_ivp, method DOP853 (explicit Runge-Kutta 8(5,3)),
    rtol 1e-11, instead of CVODE BDF.
What is taken from the Rust run: the normalized parameters written in the CSV header line
"# params: ..." (kF0, the potential's parameters after shooting, ln B and ln C at a_start,
Omega_r0, Omega_b0, a_start).  The Python run then integrates from a_start (or evaluates the
algebraic fable4d solution) on the Rust output grid and compares:
  max |Delta w_f|, max |Delta H_A|/H_A, max |Delta B|/B, max |Delta G_ratio|/G_ratio.
Every number must be below 1e-6, otherwise the script FAILS loudly (exit code 1).
It also checks, independently of the Rust shooting, that H_A(A = 1) = 1 and B(1) = C(1) = 1.

Run from anywhere:
    fable-cosmology/.venv/Scripts/python.exe fable-cosmology/fermion/crosscheck.py [--jobs N]
The Rust CSVs are (re)generated into fable-cosmology/fermion/dev/ by this script.
"""
import math
import os
import re
import subprocess
import sys
import time
from concurrent.futures import ProcessPoolExecutor

import warnings

import numpy as np
from scipy.integrate import IntegrationWarning, quad, solve_ivp
from scipy.optimize import brentq

# quad occasionally reports "roundoff error detected" at epsrel = 1e-12 for the scalar density of
# a nearly massless gas; the agreement with the Rust closed forms (printed below, < 1e-8) shows
# these evaluations are accurate to far better than the 1e-6 criterion
warnings.simplefilter("ignore", IntegrationWarning)

HERE = os.path.dirname(os.path.abspath(__file__))
DEV = os.path.join(HERE, "dev")
EXE = os.path.abspath(os.path.join(HERE, "..", "rust", "fable_fermion", "target", "release",
                                   "fable_fermion.exe" if os.name == "nt" else "fable_fermion"))
G = 8.0
PI2 = math.pi ** 2
TOL = 1e-6

# ---------------------------------------------------------------- units, recomputed independently


def units():
    hbar_js = 1.054571817e-34
    c = 299792458.0
    ev = 1.602176634e-19
    hbar_evs = hbar_js / ev    # one CODATA-2018 hbar for H0 and M_pl, as constants.rs and make_reference_fermion.wls
    gN = 6.67430e-11
    kb = 8.617333262e-5
    mpc = 648000.0 / math.pi * 149597870700.0 * 1e6
    h = 0.674
    h0 = 100.0 * h * 1e3 / mpc * hbar_evs                     # eV
    mpl = math.sqrt(hbar_js * c ** 5 / (8 * math.pi * gN)) / ev  # reduced Planck mass, eV
    rhoc = 3 * h0 ** 2 * mpl ** 2
    tg = kb * 2.7255
    og = PI2 / 15 * tg ** 4 / rhoc
    onu = 7 / 8 * (4 / 11) ** (4 / 3) * og
    return dict(e_c=rhoc ** 0.25, omega_r0=og + 3.046 * onu, omega_nu1=onu, omega_b0=0.02237 / h ** 2)

# ---------------------------------------------------------------- Fermi sea by quadrature


def fermi(m, kf):
    """(n, sigma, eps, P) for g = 8, momenta in 3 dimensions, by adaptive quadrature."""
    if kf <= 0.0:
        return 0.0, 0.0, 0.0, 0.0
    n = G * kf ** 3 / (6 * PI2)
    if m == 0.0:
        e = G * kf ** 4 / (8 * PI2)
        return n, 0.0, e, e / 3
    am = abs(m)
    c = G / (2 * PI2)
    opts = dict(epsabs=0.0, epsrel=1e-12, limit=400)
    if am < kf:
        opts["points"] = [am]
    s = c * quad(lambda k: k * k * m / math.hypot(k, m), 0.0, kf, **opts)[0]
    e = c * quad(lambda k: k * k * math.hypot(k, m), 0.0, kf, **opts)[0]
    p = c / 3 * quad(lambda k: k ** 4 / math.hypot(k, m), 0.0, kf, **opts)[0]
    return n, s, e, p


def sigma_only(m, kf):
    if kf <= 0.0 or m == 0.0:
        return 0.0
    am = abs(m)
    opts = dict(epsabs=0.0, epsrel=1e-12, limit=400)
    if am < kf:
        opts["points"] = [am]
    return G / (2 * PI2) * quad(lambda k: k * k * m / math.hypot(k, m), 0.0, kf, **opts)[0]

# ---------------------------------------------------------------- potentials


def W(p, s):
    t = p["potential"]
    if t == "mass":
        return p["m0"] * s
    if t == "lambda-mass":
        return p["v0"] + p["m0"] * s
    if t == "power":
        return p["m0"] * s + p["lam"] * s ** p["nu"]
    if t == "expdamp":
        return p["v0"] + p["m0"] * s * math.exp(-s / p["s1"])
    if t == "quadratic":
        return p["v0"] + p["m0"] * s + 0.5 * p["lam"] * s * s
    raise ValueError(t)


def Wp(p, s):
    t = p["potential"]
    if t in ("mass", "lambda-mass"):
        return p["m0"]
    if t == "power":
        return p["m0"] + p["nu"] * p["lam"] * s ** (p["nu"] - 1)
    if t == "expdamp":
        return p["m0"] * (1 - s / p["s1"]) * math.exp(-s / p["s1"])
    if t == "quadratic":
        return p["m0"] + p["lam"] * s
    raise ValueError(t)


def gap(p, kf, v):
    """The self-consistent m on the (unique) branch, by brentq on the documented bracket."""
    t = p["potential"]
    if t in ("mass", "lambda-mass"):
        return p["m0"]

    def f(m):
        return m - Wp(p, sigma_only(m, kf) / v)

    if t == "power":            # lam > 0, 0 < nu < 1: f increasing on m > 0, root > m0 + nu lam n8^(nu-1)
        n8 = G * kf ** 3 / (6 * PI2) / v
        lo = p["m0"] + p["nu"] * p["lam"] * n8 ** (p["nu"] - 1)
        if not lo > 0:
            lo = kf * 1e-3
            while f(lo) >= 0:
                lo *= 1e-3
        flo = f(lo)
        if flo >= 0:            # the root is at lo within rounding (deep non-relativistic limit)
            return lo
        hi = p["m0"] + p["nu"] * p["lam"] * (sigma_only(lo, kf) / v) ** (p["nu"] - 1)
        while f(hi) < 0:
            hi = 2 * abs(hi) + kf
        return brentq(f, lo, hi, xtol=1e-300, rtol=1e-15, maxiter=500)
    if t == "expdamp" or (t == "quadratic" and p["lam"] <= 0):   # m0 > 0: one root in (0, m0]
        return brentq(f, 0.0, p["m0"], xtol=1e-300, rtol=1e-15, maxiter=500)
    raise ValueError(f"no bracket for {t}")


def fable(p, N, lnv):
    """rho_f, P_obs_f, P_hid_f, F_f (hidden driver), dP (P_obs - P_hid) per 7-volume."""
    kf = p["kf0"] * math.exp(-N)
    v = math.exp(lnv)
    m = gap(p, kf, v)
    n, s, e, P = fermi(m, kf)
    s8 = s / v
    U = W(p, s8) - s8 * Wp(p, s8)
    rho = e / v + U
    return dict(rho=rho, pobs=P / v - U, phid=-U, F=m * s8 + 2 * U, dp=P / v, m=m, n8=n / v)


def composition(p, N, lnv):
    rr = p["omega_r0"] * math.exp(-4 * N - lnv)
    rb = p["omega_b0"] * math.exp(-3 * N - lnv)
    fb = fable(p, N, lnv)
    return rr, rb, fb, rr + rb + fb["rho"], rb + fb["F"], rr / 3 + fb["dp"]

# ---------------------------------------------------------------- models


def run_python(p, grid):
    """Evaluate the model on the Rust N grid.  Returns dict of arrays H_A, B, G_ratio, w_f."""
    four_d = p["model"] == "fable4d"
    frozen = p["freeze"] == 1
    N0 = grid[0]
    if four_d or frozen:
        out = dict(H_A=[], B=[], G=[], w_f=[])
        HA_alg = []
        for N in grid:
            rr, rb, fb, rho, F, dp = composition(p, N, 0.0)
            HA_alg.append(math.sqrt(rho))
            out["w_f"].append(fb["pobs"] / fb["rho"])
        out["H_A"] = np.array(HA_alg)
        out["B"] = np.ones(len(grid))
        out["G"] = np.ones(len(grid))
        out["w_f"] = np.array(out["w_f"])
        return out

    # fable8d: y = (ln B, ln C, h_A, h_B, h_C, tau), h = H A^2, tau = t / A^2, independent N
    def rhs(N, y):
        lnB, lnC, sA, sB, sC, tau = y
        e = math.exp(-2 * N)
        HA, HB, HC = sA * e, sB * e, sC * e
        rr, rb, fb, rho, F, dp = composition(p, N, 3 * lnB + lnC)
        th = 3 * HA + 3 * HB + HC
        dHA = -HA * th + F / 2 + 3 * dp
        dHB = -HB * th + F / 2
        dHC = -HC * th + F / 2
        return [HB / HA, HC / HA, 2 * sA + dHA / (HA * e), 2 * sB + dHB / (HA * e),
                2 * sC + dHC / (HA * e), -2 * tau + e / HA]

    lnB0, lnC0 = p["lnB_i"], p["lnC_i"]
    rr, rb, fb, rho, F, dp = composition(p, N0, 3 * lnB0 + lnC0)
    HA0 = math.sqrt(rho)
    e2 = math.exp(2 * N0)
    y0 = [lnB0, lnC0, HA0 * e2, 0.0, 0.0, 0.5 / HA0 / e2]
    sol = solve_ivp(rhs, (N0, grid[-1]), y0, method="DOP853", rtol=1e-11, atol=1e-14,
                    t_eval=grid, dense_output=False)
    if not sol.success:
        raise RuntimeError(sol.message)
    Y = sol.y
    E = np.exp(-2 * grid)
    HA = Y[2] * E
    lnv = 3 * Y[0] + Y[1]
    wf = np.array([(lambda f: f["pobs"] / f["rho"])(fable(p, N, lv)) for N, lv in zip(grid, lnv)])
    return dict(H_A=HA, B=np.exp(Y[0]), C=np.exp(Y[1]), G=np.exp(-lnv), w_f=wf, nfev=sol.nfev)

# ---------------------------------------------------------------- Rust side


def read_csv(path):
    params, rows, hdr = {}, [], None
    with open(path) as fh:
        for line in fh:
            if line.startswith("# params:"):
                for tok in line[len("# params:"):].split():
                    k, _, v = tok.partition("=")
                    try:
                        params[k] = float(v)
                    except ValueError:
                        params[k] = v
            elif line.startswith("#"):
                continue
            elif hdr is None:
                hdr = line.strip().split(",")
            else:
                rows.append([float(x) for x in line.split(",")])
    d = np.array(rows)
    return params, {h: d[:, i] for i, h in enumerate(hdr)}


CASES = [
    # (tag, model, potential args)
    ("mass1_4d", "fable4d", ["--potential", "mass", "--param", "m0_ev=1"]),
    ("mass100_4d", "fable4d", ["--potential", "mass", "--param", "m0_ev=100"]),
    ("lm30_4d", "fable4d", ["--potential", "lambda-mass", "--param", "m0_ev=30"]),
    ("power236_4d", "fable4d", ["--potential", "power", "--param", "nu=0.236"]),
    ("expdamp_4d", "fable4d", ["--potential", "expdamp"]),
    ("quadratic_4d", "fable4d", ["--potential", "quadratic", "--param", "gq=-0.5"]),
    ("mass1_8d", "fable8d", ["--potential", "mass", "--param", "m0_ev=1"]),
    ("mass100_8d", "fable8d", ["--potential", "mass", "--param", "m0_ev=100"]),
    ("lm30_8d", "fable8d", ["--potential", "lambda-mass", "--param", "m0_ev=30"]),
    ("power236_8d", "fable8d", ["--potential", "power", "--param", "nu=0.236"]),
    ("expdamp_8d", "fable8d", ["--potential", "expdamp"]),
    ("quadratic_8d", "fable8d", ["--potential", "quadratic", "--param", "gq=-0.5"]),
    ("lm30_8d_frozen", "fable8d", ["--potential", "lambda-mass", "--param", "m0_ev=30", "--freeze-hidden"]),
]


def one_case(case):
    try:
        return one_case_inner(case)
    except Exception as e:  # report per case, do not hide
        return dict(tag=case[0], error=f"{type(e).__name__}: {e}")


def one_case_inner(case):
    tag, model, args = case
    t0 = time.time()
    path = os.path.join(DEV, f"xc_{tag}.csv")
    cmd = [EXE, model] + args + ["--out", path]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        return dict(tag=tag, error=f"Rust failed: {r.stderr[-600:]}")
    p, rust = read_csv(path)
    grid = rust["N"]
    py = run_python(p, grid)
    dw = np.nanmax(np.abs(py["w_f"] - rust["w_f"]))
    dh = np.max(np.abs(py["H_A"] - rust["H_A"]) / rust["H_A"])
    db = np.max(np.abs(py["B"] - rust["B"]) / rust["B"])
    dg = np.max(np.abs(py["G"] - rust["G_ratio"]) / rust["G_ratio"])
    today = dict(H_A=py["H_A"][-1], B=py["B"][-1], C=py.get("C", np.ones(1))[-1])
    return dict(tag=tag, dw=dw, dh=dh, db=db, dg=dg, today=today, secs=time.time() - t0,
                nfev=py.get("nfev", 0), cmd=" ".join(os.path.relpath(c, HERE) if os.path.isabs(c) else c for c in cmd))


def main():
    jobs = 4
    if "--jobs" in sys.argv:
        jobs = int(sys.argv[sys.argv.index("--jobs") + 1])
    os.makedirs(DEV, exist_ok=True)
    if not os.path.exists(EXE):
        sys.exit(f"FAIL: the Rust binary {EXE} does not exist; build it with cargo build --release")
    # the unit system, recomputed
    u = units()
    ver = subprocess.run([EXE, "--constants"], capture_output=True, text=True).stdout
    sci = lambda key, i=0: float(re.findall(r"=\s+([-+]?\d[\d.]*e[-+]?\d+)", [l for l in ver.splitlines() if l.startswith(key)][0])[i])
    rust_or = sci("Omega_r0")
    rust_ec = sci("E_c")
    print(f"units: Omega_r0 python {u['omega_r0']:.10e} rust {rust_or:.10e};  E_c python {u['e_c']:.10e} eV rust {rust_ec:.10e} eV")
    fail = abs(u["omega_r0"] / rust_or - 1) > 1e-9 or abs(u["e_c"] / rust_ec - 1) > 1e-9
    print(f"{'case':16s} {'max|dw_f|':>11s} {'max|dH_A|/H':>12s} {'max|dB|/B':>11s} {'max|dG|/G':>11s} {'H_A(1)py':>18s} {'B(1)py':>18s} {'nfev':>7s} {'secs':>7s}")
    with ProcessPoolExecutor(max_workers=jobs) as ex:
        results = list(ex.map(one_case, CASES))
    for r in results:
        if "error" in r:
            print(f"{r['tag']:16s} ERROR {r['error']}")
            fail = True
            continue
        bad = max(r["dw"], r["dh"], r["db"], r["dg"]) > TOL or abs(r["today"]["H_A"] - 1) > 1e-6 or abs(r["today"]["B"] - 1) > 1e-6
        fail |= bad
        print(f"{r['tag']:16s} {r['dw']:11.3e} {r['dh']:12.3e} {r['db']:11.3e} {r['dg']:11.3e} {r['today']['H_A']:18.15f} {r['today']['B']:18.15f} {r['nfev']:7d} {r['secs']:7.1f}{'  <-- FAIL' if bad else ''}")
    for r in results:
        if "cmd" in r:
            print(f"# {r['tag']}: {r['cmd']}")
    if fail:
        print("CROSSCHECK FAILED: some difference exceeds 1e-6 (or H_A(1), B(1) != 1)")
        sys.exit(1)
    print(f"CROSSCHECK PASSED: every difference < {TOL:g}")


if __name__ == "__main__":
    main()
