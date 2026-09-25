//! The Kohn-Sham ground state of fermion fable (design A.6(c), B.3, B.4(G)).
//!
//! # The T = 0 Fermi sea
//! g = 8 states per spatial momentum, momenta along the three observed directions only (zero
//! modes along x0 and x5..x7), mass m (either sign), Fermi momentum kF, wF = sqrt(kF^2 + m^2):
//!
//! ```text
//! n     = g kF^3 / (6 pi^2)
//! sigma = (g m / (4 pi^2)) [kF wF - m^2 asinh(x)]                       x = kF/|m|
//! eps   = (g / (16 pi^2)) [kF wF (2 kF^2 + m^2) - m^4 asinh(x)]
//! P     = (g / (48 pi^2)) [kF wF (2 kF^2 - 3 m^2) + 3 m^4 asinh(x)]
//! chi   = d sigma/dm |kF = (g / (2 pi^2)) Int_0^kF k^4/w^3 dk   (> 0; chi(m=0) = g kF^2/(4 pi^2))
//! ```
//! (asinh(x) = ln((kF + wF)/|m|)).  sigma is odd in m, eps, P, chi are even.  The closed forms
//! cancel catastrophically for x << 1 (eps ~ m n, sigma ~ n, P ~ n kF^2/(5m) are small differences
//! of large terms), so three regimes are used, all written with the integral representations
//! `S(x) = 2 Int_0^x t^2/sqrt(1+t^2)`, `E(x) = 8 Int_0^x t^2 sqrt(1+t^2)`,
//! `Q(x) = 8 Int_0^x t^4/sqrt(1+t^2)`, `D(x) = 3 S - 2 x^3/sqrt(1+x^2)`:
//!
//! * x < X_LO = 0.6: the convergent binomial series (radius 1) in x^2,
//!   `sigma = g m^3 S/(4pi^2)`, `eps = g m^4 E/(16pi^2)`, `P = g m^4 Q/(48pi^2)`, `chi = g m^2 D/(4pi^2)`;
//!   e.g. eps = |m| n [1 + (3/10) x^2 - (3/56) x^4 + ...], sigma = sgn(m) n [1 - (3/10) x^2 + ...].
//! * X_LO <= x <= X_HI = 100: the closed forms (loss of at most ~1.3 digits at x = X_LO).
//! * x > X_HI: the ultra-relativistic series in y = |m|/kF, with the logarithm kept exact:
//!   `asinh(1/y) = ln(2/y) - Sum_{n>=1} c_n y^(2n)/(2n)`, `sqrt(1+y^2) = Sum b_k y^(2k)`, and
//!   `sigma = g m kF^2 [s - y^2 A]/(4pi^2)`, `eps = g kF^4 [s (2 + y^2) - y^4 A]/(16pi^2)`,
//!   `P = g kF^4 [s (2 - 3 y^2) + 3 y^4 A]/(48pi^2)`, `chi = g kF^2 [3 (s - y^2 A) - 2/s]/(4pi^2)`.
//! * m = 0 exactly: sigma = 0, eps = 3P = g kF^4/(8 pi^2), chi = g kF^2/(4 pi^2).
//!
//! # The mean field (canonical normalization, design A.6(c)), per 7-volume
//! With the hidden volume factor v = B^3 C, sigma8 = sigma/v, m = W'(sigma8):
//! ```text
//! rho_8 = eps/v + W(sigma8) - sigma8 W'(sigma8)       (= rho_qp + U,  U := W - sigma8 W')
//! P_obs = P/v + sigma8 W' - W                          (= P_qp - U)
//! P_hid = P_x0 = sigma8 W' - W                         (= -U)
//! ```
//! Thermodynamic identity (8D form): eps + P = wF n (T = 0 Gibbs-Duhem with mu = wF), hence
//! `rho_8 + P_obs = wF n / v = wF n8` exactly (U cancels), and `rho_8 + P_hid = eps/v`.
//! First law: d eps = wF dn + sigma dm at fixed kF-geometry, so with the gap m = W'(sigma8)
//! `d rho_8 = wF dn/v - (eps/v) d ln v` (the sigma dm terms cancel): at fixed v,
//! `d rho_8/d n8 = wF`.
//!
//! # The gap equation and the branch choice
//! `f(m) = m - W'(sigma_KS(m, kF)/v) = 0`.  Every potential states where its roots can lie and
//! whether the root is unique (`Potential::gap_plan`).  When several roots exist (scan), the one
//! with the LOWEST energy density rho_8 is taken (see `Selection` and the note there on why this,
//! and not the minimum of E_n[sigma] over sigma in (-n, n), is the right rule in the no-sea
//! functional).

use std::f64::consts::PI;

use crate::constants::G_FABLE;
use crate::numerics::brent;
use crate::potentials::{GapPlan, Potential};

pub const X_LO: f64 = 0.6;
pub const X_HI: f64 = 100.0;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Regime {
    Empty,
    Massless,
    SeriesNR,
    Closed,
    SeriesUR,
}

/// The T = 0 Fermi-sea integrals at (m, kF).
#[derive(Clone, Copy, Debug)]
pub struct FermiSea {
    pub m: f64,
    pub kf: f64,
    pub n: f64,
    pub sigma: f64,
    pub eps: f64,
    pub p: f64,
    pub wf: f64,
    /// d sigma / d m at fixed kF
    pub chi: f64,
    pub regime: Regime,
}

/// (S, E, Q, D)(x) by the binomial series; x < 1.
fn series_nr(x: f64) -> (f64, f64, f64, f64) {
    let x2 = x * x;
    let mut c = 1.0; // binom(-1/2, k)
    let mut b = 1.0; // binom(1/2, k)
    let mut p = x * x2; // x^(2k+3)
    let (mut s, mut e, mut q, mut d) = (0.0f64, 0.0f64, 0.0f64, 0.0f64);
    for k in 0..400 {
        let kk = k as f64;
        let ts = 2.0 * c * p / (2.0 * kk + 3.0);
        let te = 8.0 * b * p / (2.0 * kk + 3.0);
        let tq = 8.0 * c * p * x2 / (2.0 * kk + 5.0);
        let td = c * p * (-4.0 * kk) / (2.0 * kk + 3.0);
        s += ts;
        e += te;
        q += tq;
        d += td;
        if k >= 2 && ts.abs() <= 1e-18 * s.abs() && te.abs() <= 1e-18 * e.abs() && tq.abs() <= 1e-18 * q.abs() && td.abs() <= 1e-18 * d.abs() {
            break;
        }
        c *= -(2.0 * kk + 1.0) / (2.0 * kk + 2.0);
        b *= (0.5 - kk) / (kk + 1.0);
        p *= x2;
    }
    (s, e, q, d)
}

/// (S, E, Q, D)(x) in closed form.
fn closed(x: f64) -> (f64, f64, f64, f64) {
    let s = (1.0 + x * x).sqrt();
    let a = x.asinh();
    let xs = x * s;
    let sfun = xs - a;
    let efun = xs * (2.0 * x * x + 1.0) - a;
    let qfun = xs * (2.0 * x * x - 3.0) + 3.0 * a;
    let dfun = 3.0 * sfun - 2.0 * x * x * x / s;
    (sfun, efun, qfun, dfun)
}

/// (Sy, Ey, Qy, Dy)(y), y = |m|/kF small: the ultra-relativistic series with exact logarithm.
fn series_ur(y: f64) -> (f64, f64, f64, f64) {
    let y2 = y * y;
    // sqrt(1 + y^2) = Sum b_k y^(2k);  asinh(1/y) = ln 2 - ln y - Sum_{n>=1} c_n y^(2n)/(2n)
    let mut sq = 1.0;
    let mut asn = std::f64::consts::LN_2 - y.ln();
    let mut b = 1.0;
    let mut c = 1.0;
    let mut p = 1.0;
    for k in 1..60 {
        let kk = k as f64;
        b *= (0.5 - (kk - 1.0)) / kk;
        c *= -(2.0 * (kk - 1.0) + 1.0) / (2.0 * (kk - 1.0) + 2.0);
        p *= y2;
        let tb = b * p;
        let ta = -c * p / (2.0 * kk);
        sq += tb;
        asn += ta;
        if tb.abs() <= 1e-18 * sq.abs() && ta.abs() <= 1e-18 * asn.abs() {
            break;
        }
    }
    let y4a = y2 * y2 * asn;
    let sy = sq - y2 * asn;
    let ey = sq * (2.0 + y2) - y4a;
    let qy = sq * (2.0 - 3.0 * y2) + 3.0 * y4a;
    let dy = 3.0 * sy - 2.0 / sq;
    (sy, ey, qy, dy)
}

/// The Fermi-sea integrals, choosing the regime automatically.
pub fn fermi_sea(m: f64, kf: f64) -> FermiSea {
    fermi_sea_regime(m, kf, None)
}

/// The Fermi-sea integrals in a forced regime (the continuity tests use this); `None` = automatic.
pub fn fermi_sea_regime(m: f64, kf: f64, force: Option<Regime>) -> FermiSea {
    let g = G_FABLE;
    let pi2 = PI * PI;
    let am = m.abs();
    let wf = kf.hypot(m);
    if !(kf > 0.0) {
        return FermiSea { m, kf, n: 0.0, sigma: 0.0, eps: 0.0, p: 0.0, wf: am, chi: 0.0, regime: Regime::Empty };
    }
    let n = g * kf * kf * kf / (6.0 * pi2);
    if am == 0.0 {
        let e4 = g * kf.powi(4) / (8.0 * pi2);
        return FermiSea { m, kf, n, sigma: 0.0, eps: e4, p: e4 / 3.0, wf: kf, chi: g * kf * kf / (4.0 * pi2), regime: Regime::Massless };
    }
    let x = kf / am;
    let regime = force.unwrap_or(if x < X_LO { Regime::SeriesNR } else if x <= X_HI { Regime::Closed } else { Regime::SeriesUR });
    match regime {
        Regime::SeriesNR | Regime::Closed => {
            let (sf, ef, qf, df) = if regime == Regime::SeriesNR { series_nr(x) } else { closed(x) };
            let m2 = m * m;
            FermiSea {
                m,
                kf,
                n,
                sigma: g * m * m2 * sf / (4.0 * pi2),
                eps: g * m2 * m2 * ef / (16.0 * pi2),
                p: g * m2 * m2 * qf / (48.0 * pi2),
                wf,
                chi: g * m2 * df / (4.0 * pi2),
                regime,
            }
        }
        _ => {
            let y = am / kf;
            let (sy, ey, qy, dy) = series_ur(y);
            let k2 = kf * kf;
            FermiSea {
                m,
                kf,
                n,
                sigma: g * m * k2 * sy / (4.0 * pi2),
                eps: g * k2 * k2 * ey / (16.0 * pi2),
                p: g * k2 * k2 * qy / (48.0 * pi2),
                wf,
                chi: g * k2 * dy / (4.0 * pi2),
                regime: Regime::SeriesUR,
            }
        }
    }
}

/// d sigma / d kF at fixed m = (g/(2 pi^2)) kF^2 m / wF.
pub fn dsigma_dkf(m: f64, kf: f64) -> f64 {
    let wf = kf.hypot(m);
    if wf == 0.0 {
        return 0.0;
    }
    G_FABLE / (2.0 * PI * PI) * kf * kf * m / wf
}

// ------------------------------------------------------------------ mean field

/// Which gap root to take when there are several.
///
/// `Lowest` (default): the stationary point of the KS energy with the lowest energy density rho_8
/// at the given (n, v).  NOTE (a correction to design B.4(G)): in the no-sea functional
/// `E_n[sigma] = T_s[sigma; n] + W(sigma)`, `T_s = eps(m(sigma)) - m(sigma) sigma` is CONCAVE in
/// sigma (d2 T_s/d sigma^2 = -1/chi < 0), so for W linear the self-consistent point is a MAXIMUM
/// of E_n over sigma in (-n, n) and the "global minimum" sits at the unphysical end sigma -> -sgn(m0) n
/// (all particles in the negative-mass band, i.e. Dirac-sea states of the true KS Hamiltonian);
/// the test `ks_functional_stationary_point_is_a_maximum_for_the_mass_term` demonstrates it.  The
/// no-sea functional only makes sense at its stationary points (the gap solutions), and among
/// those the ground state is the one of lowest energy.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Selection {
    Lowest,
    Positive,
    Negative,
}

impl Selection {
    pub fn parse(s: &str) -> Result<Self, String> {
        match s {
            "lowest" => Ok(Selection::Lowest),
            "positive" => Ok(Selection::Positive),
            "negative" => Ok(Selection::Negative),
            other => Err(format!("unknown --branch '{other}' (lowest | positive | negative)")),
        }
    }
}

/// The mean-field fable at (m, kF, v), per 7-volume.
#[derive(Clone, Copy, Debug)]
pub struct MeanField {
    pub m: f64,
    pub kf: f64,
    pub v: f64,
    pub sea: FermiSea,
    pub n8: f64,
    pub sigma8: f64,
    pub w: f64,
    pub dw: f64,
    pub d2w: f64,
    /// U = W - sigma8 W'
    pub u: f64,
    /// eps / v
    pub rho_qp: f64,
    /// P / v
    pub p_qp: f64,
    pub rho: f64,
    pub p_obs: f64,
    /// P_hid = P_x0 = -U
    pub p_hid: f64,
    /// (m - W'(sigma8)) / max(|m|, |W'|, kF)
    pub gap_residual: f64,
    pub n_roots: usize,
    /// sign of m on the selected branch (+1, 0, -1)
    pub branch: i32,
}

/// Evaluate the mean field at a given m (self-consistent or not).
pub fn mean_field_at(pot: &Potential, m: f64, kf: f64, v: f64) -> MeanField {
    let sea = fermi_sea(m, kf);
    let n8 = sea.n / v;
    let sigma8 = sea.sigma / v;
    let w = pot.w(sigma8);
    let dw = pot.dw(sigma8);
    let d2w = pot.d2w(sigma8);
    let u = pot.u(sigma8); // analytic W - sigma8 W'
    let rho_qp = sea.eps / v;
    let p_qp = sea.p / v;
    let scale = m.abs().max(dw.abs()).max(kf).max(f64::MIN_POSITIVE);
    MeanField {
        m,
        kf,
        v,
        sea,
        n8,
        sigma8,
        w,
        dw,
        d2w,
        u,
        rho_qp,
        p_qp,
        rho: rho_qp + u,
        p_obs: p_qp - u,
        p_hid: -u,
        gap_residual: (m - dw) / scale,
        n_roots: 1,
        branch: if m > 0.0 { 1 } else if m < 0.0 { -1 } else { 0 },
    }
}

/// The gap function f(m) = m - W'(sigma_KS(m, kF)/v).
pub fn gap_function(pot: &Potential, m: f64, kf: f64, v: f64) -> f64 {
    let s8 = fermi_sea(m, kf).sigma / v;
    m - pot.dw(s8)
}

fn refine(pot: &Potential, kf: f64, v: f64, lo: f64, hi: f64) -> Result<f64, String> {
    let f = |m: f64| gap_function(pot, m, kf, v);
    let (flo, fhi) = (f(lo), f(hi));
    let tolf = |m: f64| 1e-14 * (m.abs() + pot.dw(fermi_sea(m, kf).sigma / v).abs());
    if flo == 0.0 {
        return Ok(lo);
    }
    if fhi == 0.0 {
        return Ok(hi);
    }
    if (flo > 0.0) == (fhi > 0.0) {
        // within rounding of an end point?
        if flo.abs() <= tolf(lo) {
            return Ok(lo);
        }
        if fhi.abs() <= tolf(hi) {
            return Ok(hi);
        }
        return Err(format!("gap: [{lo:e}, {hi:e}] does not bracket a root (f = {flo:e}, {fhi:e})"));
    }
    brent(f, lo, hi, 0.0, 400).map(|(r, _)| r)
}

/// All roots of the gap equation found by scanning [lo, hi] (asinh-spaced around m = 0 on the
/// scale kF, 800 cells) and refining every sign change with Brent.
pub fn gap_roots_scan(pot: &Potential, kf: f64, v: f64, lo: f64, hi: f64) -> Result<Vec<f64>, String> {
    let scale = kf.max(1e-300);
    let (tlo, thi) = ((lo / scale).asinh(), (hi / scale).asinh());
    let ncell = 800;
    let mut ms: Vec<f64> = (0..=ncell).map(|i| scale * (tlo + (thi - tlo) * i as f64 / ncell as f64).sinh()).collect();
    if lo < 0.0 && hi > 0.0 {
        ms.push(0.0);
    }
    if pot.nonneg_domain() {
        // sigma >= 0 only (m > 0): add a log-spaced sub-grid from kF 1e-24 up to the first
        // asinh point, where W' ~ sigma^(nu-1) varies fastest
        ms.retain(|&m| m > 0.0 && m >= lo);
        let top = ms.first().copied().unwrap_or(hi);
        let bottom = (scale * 1e-24).max(lo).max(1e-300);
        if top > bottom {
            let k = 120;
            for i in 0..k {
                ms.push(bottom * (top / bottom).powf(i as f64 / k as f64));
            }
        }
    }
    ms.sort_by(|a, b| a.partial_cmp(b).unwrap());
    ms.dedup();
    let fs: Vec<f64> = ms.iter().map(|&m| gap_function(pot, m, kf, v)).collect();
    let mut roots = Vec::new();
    for i in 0..ms.len() {
        if fs[i] == 0.0 {
            roots.push(ms[i]);
        }
        if i + 1 < ms.len() && fs[i].is_finite() && fs[i + 1].is_finite() && fs[i] != 0.0 && fs[i + 1] != 0.0 && (fs[i] > 0.0) != (fs[i + 1] > 0.0) {
            roots.push(refine(pot, kf, v, ms[i], ms[i + 1])?);
        }
    }
    roots.sort_by(|a, b| a.partial_cmp(b).unwrap());
    roots.dedup_by(|a, b| (*a - *b).abs() <= 1e-12 * (a.abs() + b.abs()) + 1e-300);
    Ok(roots)
}

/// Solve the gap equation at (kF, v) and return the selected self-consistent mean field.
pub fn solve_gap(pot: &Potential, kf: f64, v: f64, sel: Selection) -> Result<MeanField, String> {
    let sea0 = fermi_sea(0.0, kf);
    let n8 = sea0.n / v;
    let chi0_over_v = sea0.chi / v;
    match pot.gap_plan(n8, chi0_over_v) {
        GapPlan::Exact(m) => Ok(mean_field_at(pot, m, kf, v)),
        GapPlan::Unique { lo, hi } => {
            let (lo, hi) = if let Potential::Power { m0, lam, nu } = *pot {
                // lo > 0 with f(lo) < 0; hi = m0 + nu lam sigma8(lo)^(nu-1) >= root
                let mut lo = lo;
                if !(lo > 0.0) {
                    lo = (kf.min(m0.abs().max(kf))) * 1e-3;
                    let mut k = 0;
                    while gap_function(pot, lo, kf, v) >= 0.0 {
                        lo *= 1e-3;
                        k += 1;
                        if k > 100 {
                            return Err(format!("power gap: no lower bracket at kF = {kf:e}, v = {v:e}"));
                        }
                    }
                }
                let s8 = fermi_sea(lo, kf).sigma / v;
                let mut hi = m0 + nu * lam * s8.powf(nu - 1.0);
                let mut k = 0;
                while gap_function(pot, hi, kf, v) < 0.0 {
                    hi = 2.0 * hi.abs() + kf;
                    k += 1;
                    if k > 200 {
                        return Err(format!("power gap: no upper bracket at kF = {kf:e}, v = {v:e}"));
                    }
                }
                (lo, hi)
            } else {
                (lo, hi)
            };
            let m = refine(pot, kf, v, lo, hi)?;
            Ok(mean_field_at(pot, m, kf, v))
        }
        GapPlan::Scan { lo, hi } => {
            let roots = gap_roots_scan(pot, kf, v, lo, hi)?;
            if roots.is_empty() {
                return Err(format!("gap: no root found in [{lo:e}, {hi:e}] at kF = {kf:e}, v = {v:e}"));
            }
            let fields: Vec<MeanField> = roots.iter().map(|&m| mean_field_at(pot, m, kf, v)).collect();
            let pick = match sel {
                Selection::Lowest => {
                    // lowest energy; ties (|drho| <= 1e-14 rho) resolved towards m > 0
                    let mut best = 0usize;
                    for (i, f) in fields.iter().enumerate() {
                        let b = &fields[best];
                        let tie = (f.rho - b.rho).abs() <= 1e-14 * (f.rho.abs() + b.rho.abs());
                        if (!tie && f.rho < b.rho) || (tie && f.m > b.m) {
                            best = i;
                        }
                    }
                    Some(best)
                }
                Selection::Positive => fields.iter().enumerate().filter(|(_, f)| f.m > 0.0).max_by(|a, b| a.1.m.partial_cmp(&b.1.m).unwrap()).map(|(i, _)| i),
                Selection::Negative => fields.iter().enumerate().filter(|(_, f)| f.m < 0.0).min_by(|a, b| a.1.m.partial_cmp(&b.1.m).unwrap()).map(|(i, _)| i),
            };
            let i = pick.ok_or_else(|| format!("gap: no root on the requested {sel:?} branch (roots: {roots:?})"))?;
            let mut mf = fields[i];
            mf.n_roots = roots.len();
            Ok(mf)
        }
    }
}

/// The KS energy functional of design B.4(G) in the no-sea approximation, per 7-volume:
/// `E_n[sigma8] = T_s + W(sigma8)`, `T_s = (eps(m) - m sigma_KS(m))/v` with m defined by
/// `sigma_KS(m, kF)/v = sigma8` (sigma_KS is strictly increasing in m, onto (-n, n)).
pub fn ks_functional(pot: &Potential, sigma8: f64, kf: f64, v: f64) -> Result<f64, String> {
    let n8 = fermi_sea(0.0, kf).n / v;
    if !(sigma8.abs() < n8) {
        return Err(format!("sigma8 = {sigma8:e} outside (-n8, n8) = +-{n8:e}"));
    }
    let f = |m: f64| fermi_sea(m, kf).sigma / v - sigma8;
    let mut hi = kf.max(1e-300);
    while f(hi) < 0.0 {
        hi *= 2.0;
    }
    let mut lo = -kf.max(1e-300);
    while f(lo) > 0.0 {
        lo *= 2.0;
    }
    let (m, _) = brent(f, lo, hi, 0.0, 400)?;
    let sea = fermi_sea(m, kf);
    Ok((sea.eps - m * sea.sigma) / v + pot.w(sigma8))
}

/// The auxiliary-field (Walecka) functional of design review DFT-1, per 7-volume, for W with
/// W' strictly monotone (W'' != 0): `Omega_n(m) = eps(m)/v + F(m)`, `F(m) = W(sigma_m) - m sigma_m`,
/// `W'(sigma_m) = m`.  dOmega/dm = (sigma_KS/v - sigma_m), so its stationary points are the gap
/// roots and Omega(m*) = rho_8; for concave W (attractive) it is minimized there.
pub fn walecka_functional(pot: &Potential, m: f64, kf: f64, v: f64, sigma_lo: f64, sigma_hi: f64) -> Result<f64, String> {
    let (sm, _) = brent(|s| pot.dw(s) - m, sigma_lo, sigma_hi, 0.0, 400)?;
    Ok(fermi_sea(m, kf).eps / v + pot.w(sm) - m * sm)
}

/// The renormalized one-loop Dirac-sea energy that the no-sea functional drops (relativistic
/// Hartree approximation, Chin 1977), per 3-volume, for g states per momentum and reference mass
/// M (counterterms through m^4, so that it vanishes like (m - M)^5 at m = M):
/// `DeltaE_vac(m) = -(g/(16 pi^2)) [m^4 ln(m/M) + M^3 (M - m) - (7/2) M^2 (M - m)^2
///                  + (13/3) M (M - m)^3 - (25/12) (M - m)^4]`  (|m| and |M| are used: the sea
/// energy is even in m).  Design review DFT-4: for mass-varying W it cannot be absorbed into W
/// without changing the gap equation; the solver reports it (column vac_over_rhoc), it does not
/// include it in the dynamics.
pub fn vacuum_energy(m: f64, mref: f64) -> f64 {
    let (m, mm) = (m.abs(), mref.abs());
    if mm == 0.0 {
        return 0.0;
    }
    let d = mm - m;
    let log_term = if m > 0.0 { m.powi(4) * (m / mm).ln() } else { 0.0 };
    -(G_FABLE / (16.0 * PI * PI)) * (log_term + mm.powi(3) * d - 3.5 * mm * mm * d * d + 13.0 / 3.0 * mm * d.powi(3) - 25.0 / 12.0 * d.powi(4))
}

/// Derivatives of the self-consistent fable along a trajectory: kF = kF0 e^(-N) and
/// d ln v/dN = ell.  Returns (d rho_8/dN, d P_obs/dN, d m/dN).  d rho_8/dN is the exact
/// conservation law -3 wF n8 - ell eps/v; d P_obs/dN follows from dP = n d wF - sigma dm and the
/// differentiated gap equation dm = W'' d sigma8.
pub fn fable_derivatives(mf: &MeanField, ell: f64) -> (f64, f64, f64) {
    let (m, kf, v) = (mf.m, mf.kf, mf.v);
    let sea = &mf.sea;
    let a = mf.d2w;
    let sk = dsigma_dkf(m, kf);
    let denom = 1.0 - a * sea.chi / v;
    let ds8 = (-kf * sk / v - mf.sigma8 * ell) / denom;
    let dm = if a == 0.0 { 0.0 } else { a * ds8 };
    let drho = -3.0 * sea.wf * sea.n / v - ell * sea.eps / v;
    let dp_ks = if sea.wf > 0.0 { sea.n * (-kf * kf + m * dm) / sea.wf - sea.sigma * dm } else { 0.0 };
    let du = -mf.sigma8 * a * ds8;
    let dpobs = dp_ks / v - sea.p / v * ell - du;
    (drho, dpobs, dm)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::numerics::integrate_gk;

    /// the four integrals by adaptive Gauss-Kronrod, breakpoint at k = |m|
    fn quad(m: f64, kf: f64) -> (f64, f64, f64, f64) {
        let g = G_FABLE;
        let c = g / (2.0 * PI * PI);
        let bp = [m.abs()];
        let w = |k: f64| k.hypot(m);
        let (s, _) = integrate_gk(|k| k * k * m / w(k), 0.0, kf, &bp, 0.0, 1e-15, 20000);
        let (e, _) = integrate_gk(|k| k * k * w(k), 0.0, kf, &bp, 0.0, 1e-15, 20000);
        let (p, _) = integrate_gk(|k| k.powi(4) / w(k), 0.0, kf, &bp, 0.0, 1e-15, 20000);
        let (x, _) = integrate_gk(|k| k.powi(4) / w(k).powi(3), 0.0, kf, &bp, 0.0, 1e-15, 20000);
        (c * s, c * e, c * p / 3.0, c * x)
    }

    fn rel(a: f64, b: f64) -> f64 {
        if a == b { 0.0 } else { (a - b).abs() / a.abs().max(b.abs()) }
    }

    #[test]
    fn fermi_integrals_match_quadrature() {
        for &x in &[1e-6, 1e-3, 0.1, 1.0, 10.0, 1e3, 1e6] {
            for &m in &[1.0f64, -1.0, 3.7e-2, 2.5e3] {
                let kf = x * m.abs();
                let fs = fermi_sea(m, kf);
                let (s, e, p, c) = quad(m, kf);
                let worst = rel(fs.sigma, s).max(rel(fs.eps, e)).max(rel(fs.p, p)).max(rel(fs.chi, c));
                assert!(worst < 1e-12, "x = {x}, m = {m}: sigma {} vs {s}, eps {} vs {e}, P {} vs {p}, chi {} vs {c} (worst rel {worst:e}, regime {:?})", fs.sigma, fs.eps, fs.p, fs.chi, fs.regime);
                assert!(rel(fs.n, G_FABLE * kf.powi(3) / (6.0 * PI * PI)) < 1e-15);
            }
        }
        // m = 0 exactly
        let fs = fermi_sea(0.0, 2.0);
        let (s, e, p, c) = quad(0.0, 2.0);
        assert!(fs.sigma == 0.0 && s == 0.0 && rel(fs.eps, e) < 1e-13 && rel(fs.p, p) < 1e-13 && rel(fs.chi, c) < 1e-13);
    }

    #[test]
    fn series_and_closed_forms_are_continuous_at_the_switch_points() {
        for &xs in &[X_LO, X_HI] {
            for &m in &[1.0f64, -2.0] {
                for &dx in &[-1e-9, 0.0, 1e-9] {
                    let kf = (xs + dx) * m.abs();
                    let a = fermi_sea_regime(m, kf, Some(Regime::Closed));
                    let b = fermi_sea_regime(m, kf, Some(if xs == X_LO { Regime::SeriesNR } else { Regime::SeriesUR }));
                    for (u, w, name) in [(a.sigma, b.sigma, "sigma"), (a.eps, b.eps, "eps"), (a.p, b.p, "P"), (a.chi, b.chi, "chi")] {
                        assert!(rel(u, w) < 5e-14, "x = {}: {name} closed {u} vs series {w} (rel {:e})", xs + dx, rel(u, w));
                    }
                }
            }
        }
        // and the automatic choice is continuous across the switches (one-sided limits agree)
        for &xs in &[X_LO, X_HI] {
            let below = fermi_sea(1.0, xs * (1.0 - 1e-15));
            let above = fermi_sea(1.0, xs * (1.0 + 1e-15));
            assert!(rel(below.eps, above.eps) < 1e-13 && rel(below.p, above.p) < 1e-13 && rel(below.sigma, above.sigma) < 1e-13);
        }
    }

    #[test]
    fn nonrelativistic_and_ultrarelativistic_limits() {
        // eps = |m| n [1 + 3x^2/10 - 3x^4/56],  sigma = n [1 - 3x^2/10 + ...],  P = n kF^2/(5|m|) [1 - 5x^2/14]
        let (m, x) = (2.0, 1e-3);
        let fs = fermi_sea(m, x * m);
        assert!(rel(fs.eps, m * fs.n * (1.0 + 0.3 * x * x - 3.0 / 56.0 * x.powi(4))) < 1e-15);
        assert!(rel(fs.sigma, fs.n * (1.0 - 0.3 * x * x + 9.0 / 56.0 * x.powi(4))) < 1e-15);
        assert!(rel(fs.p, fs.n * (x * m).powi(2) / (5.0 * m) * (1.0 - 5.0 / 14.0 * x * x)) < 1e-11);
        // parity: sigma odd, eps, P, chi even
        let (a, b) = (fermi_sea(0.7, 1.3), fermi_sea(-0.7, 1.3));
        assert!(a.sigma == -b.sigma && a.eps == b.eps && a.p == b.p && a.chi == b.chi);
        // UR: eps -> 3P, sigma -> g m kF^2/(4 pi^2)
        let fs = fermi_sea(1e-8, 1.0);
        assert!(rel(fs.eps, 3.0 * fs.p) < 1e-15 && rel(fs.sigma, G_FABLE * 1e-8 / (4.0 * PI * PI)) < 1e-14);
        // the trace identity eps - 3P = m sigma for every x
        for &x in &[1e-4, 0.3, 0.6, 2.0, 99.0, 101.0, 1e5] {
            let fs = fermi_sea(1.3, 1.3 * x);
            // (relative to eps: for x >> 1, eps - 3P ~ m^2 kF^2 is a small difference of kF^4 terms)
            assert!((fs.eps - 3.0 * fs.p - 1.3 * fs.sigma).abs() < 1e-14 * fs.eps, "x = {x}: eps - 3P = {} vs m sigma = {}", fs.eps - 3.0 * fs.p, 1.3 * fs.sigma);
            // T = 0 Gibbs-Duhem: eps + P = wF n
            assert!(rel(fs.eps + fs.p, fs.wf * fs.n) < 1e-14, "x = {x}: eps + P = wF n");
        }
    }

    fn pots() -> Vec<Potential> {
        vec![
            Potential::Mass { m0: 3.0 },
            Potential::LambdaMass { v0: 0.7, m0: 3.0 },
            Potential::Power { m0: 3.0, lam: 0.8, nu: 0.236 },
            Potential::Power { m0: -2.0, lam: 0.8, nu: 0.5 },
            Potential::ExpDamp { v0: 0.4, m0: 3.0, s1: 0.05 },
            Potential::Lorentz { v0: 0.4, m0: 3.0, s1: 0.05 },
            Potential::Quadratic { v0: 0.1, m0: 3.0, lam: -20.0 },
            Potential::Quadratic { v0: 0.0, m0: 3.0, lam: 5.0 },
        ]
    }

    /// the same potentials with V0 = 0: a constant V0 drops out of every derivative, and keeping it
    /// would only make the finite differences ill-conditioned (rho = V0 + O(n) at small kF)
    fn pots_v0_zero() -> Vec<Potential> {
        pots()
            .into_iter()
            .map(|p| match p {
                Potential::LambdaMass { m0, .. } => Potential::LambdaMass { v0: 0.0, m0 },
                Potential::ExpDamp { m0, s1, .. } => Potential::ExpDamp { v0: 0.0, m0, s1 },
                Potential::Lorentz { m0, s1, .. } => Potential::Lorentz { v0: 0.0, m0, s1 },
                Potential::Quadratic { m0, lam, .. } => Potential::Quadratic { v0: 0.0, m0, lam },
                other => other,
            })
            .collect()
    }

    #[test]
    fn per_3_volume_mean_field_violates_8d_conservation() {
        // Design review E2: the condensate must be evaluated at sigma8 = sigma_KS/v (per 7-volume).
        // The per-3-volume prescription rho7 = [eps + W(sigma) - sigma W'(sigma)]/v with m = W'(sigma)
        // (sigma unscaled) gives d rho7/dN = -3 wF n/v - ell rho3/v, whereas the Bianchi-I conservation
        // law demands -3 wF n/v - ell (rho7 + P_hid7) = -3 wF n/v - ell eps/v: the mismatch is
        // -ell U/v, non-zero whenever U != 0 and v varies.  The correct prescription passes.
        let pot = Potential::Power { m0: 3.0, lam: 0.8, nu: 0.236 };
        let (kf0, ell) = (0.8, 0.5);
        let wrong = |n: f64| {
            let (kf, v) = (kf0 * (-n).exp(), (ell * n).exp());
            let mf = solve_gap(&pot, kf, 1.0, Selection::Lowest).unwrap(); // gap with unscaled sigma
            let rho3 = mf.sea.eps + mf.u;
            (rho3 / v, (mf.sea.p - mf.u) / v, -mf.u / v, mf.sea.wf * mf.sea.n / v)
        };
        let right = |n: f64| {
            let (kf, v) = (kf0 * (-n).exp(), (ell * n).exp());
            let mf = solve_gap(&pot, kf, v, Selection::Lowest).unwrap();
            (mf.rho, mf.p_obs, mf.p_hid, mf.sea.wf * mf.sea.n / v)
        };
        let h = 1e-4;
        let resid = |f: &dyn Fn(f64) -> (f64, f64, f64, f64)| {
            let (rp, _, _, _) = f(h);
            let (rm, _, _, _) = f(-h);
            let (r0, po, ph, _) = f(0.0);
            let drho = (rp - rm) / (2.0 * h);
            // rho' + 3 (rho + P_obs) + ell (rho + P_hid) = 0   (d/dN, H_A = 1 per unit N)
            (drho + 3.0 * (r0 + po) + ell * (r0 + ph)) / r0.abs()
        };
        let (rw, rr) = (resid(&wrong), resid(&right));
        assert!(rr.abs() < 1e-7, "correct per-7-volume prescription: residual {rr:e}");
        assert!(rw.abs() > 1e-2, "per-3-volume prescription should fail conservation: residual {rw:e}");
        eprintln!("per-3-volume conservation residual = {rw:.4e}, per-7-volume = {rr:.2e}");
    }

    #[test]
    fn thermodynamic_identities_at_the_self_consistent_point() {
        for pot in pots_v0_zero() {
            for &kf in &[1e-3, 0.3, 1.0, 5.0, 300.0] {
                for &v in &[1.0, 0.37, 4.2] {
                    let mf = solve_gap(&pot, kf, v, Selection::Lowest).unwrap_or_else(|e| panic!("{pot:?} kF={kf} v={v}: {e}"));
                    // gap residual
                    assert!(mf.gap_residual.abs() < 1e-12, "{pot:?} kF={kf} v={v}: gap residual {:e}", mf.gap_residual);
                    // rho + P_obs = wF n / v  and rho + P_hid = eps / v
                    let lhs = mf.rho + mf.p_obs;
                    let rhs = mf.sea.wf * mf.sea.n / v;
                    assert!((lhs - rhs).abs() <= 1e-12 * (rhs.abs() + mf.u.abs()), "{pot:?} kF={kf} v={v}: rho + P_obs = {lhs:e} vs wF n/v = {rhs:e}");
                    assert!((mf.rho + mf.p_hid - mf.rho_qp).abs() <= 1e-13 * (mf.rho_qp.abs() + mf.u.abs()));
                    // d rho_8 / d n8 = wF at fixed v (the gap re-solved at kF (1 +- h))
                    let h = 1e-5;
                    let (kp, km) = (kf * (1.0 + h), kf * (1.0 - h));
                    let (fp, fm) = (solve_gap(&pot, kp, v, Selection::Lowest).unwrap(), solve_gap(&pot, km, v, Selection::Lowest).unwrap());
                    let drdn = (fp.rho - fm.rho) / (fp.n8 - fm.n8);
                    assert!(rel(drdn, mf.sea.wf) < 1e-8, "{pot:?} kF={kf} v={v}: d rho/d n8 = {drdn:e} vs wF = {:e}", mf.sea.wf);
                }
            }
        }
    }

    #[test]
    fn derivative_along_the_trajectory_matches_finite_differences() {
        // kF = kF0 e^-N, ln v = ell N: compare fable_derivatives with central differences
        for pot in pots() {
            for &(kf0, ell) in &[(0.3, 0.0), (1.0, 0.4), (40.0, -0.2), (0.02, 0.7)] {
                let at = |n: f64| solve_gap(&pot, kf0 * (-n).exp(), (ell * n).exp(), Selection::Lowest).unwrap();
                let h = 1e-4;
                let (p, m0, c) = (at(h), at(-h), at(0.0));
                let (drho, dp, dm) = fable_derivatives(&c, ell);
                let fd_rho = (p.rho - m0.rho) / (2.0 * h);
                let fd_p = (p.p_obs - m0.p_obs) / (2.0 * h);
                let fd_m = (p.m - m0.m) / (2.0 * h);
                let sc = c.rho.abs() + c.u.abs() + c.rho_qp;
                assert!((drho - fd_rho).abs() < 1e-6 * sc, "{pot:?} {kf0} {ell}: drho {drho:e} vs {fd_rho:e}");
                assert!((dp - fd_p).abs() < 1e-6 * sc, "{pot:?} {kf0} {ell}: dP {dp:e} vs {fd_p:e}");
                assert!((dm - fd_m).abs() < 1e-6 * (c.m.abs() + kf0), "{pot:?} {kf0} {ell}: dm {dm:e} vs {fd_m:e}");
            }
        }
    }

    #[test]
    fn expdamp_pins_sigma_below_s1_and_mass_goes_to_zero_at_high_density() {
        let pot = Potential::ExpDamp { v0: 0.0, m0: 3.0, s1: 0.05 };
        for &kf in &[0.1, 1.0, 10.0, 1e3, 1e6] {
            let mf = solve_gap(&pot, kf, 1.0, Selection::Lowest).unwrap();
            assert!(mf.sigma8 < 0.05 && mf.m > 0.0, "kF = {kf}: sigma8 = {}", mf.sigma8);
        }
        let hi = solve_gap(&pot, 1e6, 1.0, Selection::Lowest).unwrap();
        assert!(hi.m / hi.kf < 1e-9 && (hi.sigma8 / 0.05 - 1.0).abs() < 1e-6);
    }

    #[test]
    fn multiple_gap_roots_are_found_and_the_lowest_energy_one_is_taken() {
        // repulsive quadratic at strong coupling: lam chi0/v > 1 -> three roots (m<0, small m>0, large m>0)
        let pot = Potential::Quadratic { v0: 0.0, m0: 0.5, lam: 40.0 };
        let kf = 1.0;
        let chi0 = fermi_sea(0.0, kf).chi;
        assert!(40.0 * chi0 > 1.0);
        let n8 = fermi_sea(0.0, kf).n;
        let roots = gap_roots_scan(&pot, kf, 1.0, 0.5 - 40.0 * n8, 0.5 + 40.0 * n8).unwrap();
        assert!(roots.len() >= 2, "roots: {roots:?}");
        for &r in &roots {
            assert!(gap_function(&pot, r, kf, 1.0).abs() < 1e-11 * (r.abs() + 1.0));
        }
        let best = solve_gap(&pot, kf, 1.0, Selection::Lowest).unwrap();
        assert_eq!(best.n_roots, roots.len());
        for &r in &roots {
            assert!(best.rho <= mean_field_at(&pot, r, kf, 1.0).rho + 1e-14);
        }
        // W = (lam/2) sigma^2 with lam > 0: m = 0 is always a root, the non-trivial pair +-m* exists
        // at strong coupling and has HIGHER energy: the ground state is the massless gas
        let pq = Potential::Quadratic { v0: 0.0, m0: 0.0, lam: 40.0 };
        let g0 = solve_gap(&pq, kf, 1.0, Selection::Lowest).unwrap();
        let gp = solve_gap(&pq, kf, 1.0, Selection::Positive).unwrap();
        assert!(g0.m == 0.0 && gp.m > 0.0 && gp.rho > g0.rho, "m* = {}, rho(m*) = {}, rho(0) = {}", gp.m, gp.rho, g0.rho);
    }

    #[test]
    fn quadrature_at_the_review_points_and_switch_continuity() {
        // design review DFT-12 points, including x = 1e-8, 1e-5 and both sides of 0.25
        for &x in &[1e-8, 1e-5, 1e-3, 0.1, 0.2499, 0.25, 1.0, 10.0, 1e3] {
            for &m in &[1.0f64, -2.0] {
                let kf = x * m.abs();
                let fs = fermi_sea(m, kf);
                let (s, e, p, _) = quad(m, kf);
                let worst = rel(fs.sigma, s).max(rel(fs.eps, e)).max(rel(fs.p, p));
                assert!(worst < 1e-12, "x = {x}, m = {m}: worst rel {worst:e}");
            }
        }
    }

    #[test]
    fn nonrelativistic_classical_limit_of_the_mean_field() {
        // DFT-5: kF << |m|:  sigma = sgn(m) n [1 - (3/10) kF^2/m^2],
        // rho = W(sgn(m) n) + (3/10) n kF^2/|m|,  P_obs = [sigma W' - W] + n kF^2/(5|m|),
        // P_hid = sigma W' - W.  Self-consistency forces sgn(sigma) = sgn(W').
        let pot = Potential::Power { m0: 1.0, lam: 1e-6, nu: 0.236 }; // m_eff ~ 1, x = kF/m ~ 1e-2
        for &kf in &[1e-2, 3e-2] {
            let mf = solve_gap(&pot, kf, 1.0, Selection::Lowest).unwrap();
            let (m, n) = (mf.m, mf.sea.n);
            let x2 = (kf / m).powi(2);
            assert!(rel(mf.sigma8, n * (1.0 - 0.3 * x2)) < 1e-3 * x2);
            let rho_nr = pot.w(n) + 0.3 * n * kf * kf / m;
            assert!((mf.rho - rho_nr).abs() < 1e-2 * 0.3 * n * kf * kf / m, "rho {} vs {rho_nr}", mf.rho);
            let pobs_nr = -pot.u(mf.sigma8) + n * kf * kf / (5.0 * m);
            assert!((mf.p_obs - pobs_nr).abs() < 1e-2 * n * kf * kf / (5.0 * m));
            assert!((mf.p_hid + pot.u(mf.sigma8)).abs() < 1e-15 * pot.u(mf.sigma8).abs());
            assert!(mf.sigma8.signum() == pot.dw(mf.sigma8).signum());
            // rho = 3 P_KS/v + W(sigma8) at the self-consistent point (eps - m sigma = 3P exactly)
            assert!(rel(mf.rho, 3.0 * mf.p_qp + mf.w) < 1e-14);
        }
    }

    #[test]
    fn no_phantom_crossing_rho_plus_p_obs_is_nonnegative() {
        // DFT-6: rho + P_obs = wF n/v >= 0, so w_f >= -1 wherever rho > 0 (every potential, every kF)
        for pot in pots() {
            for &kf in &[1e-4, 1e-2, 0.3, 3.0, 300.0] {
                let mf = solve_gap(&pot, kf, 1.0, Selection::Lowest).unwrap();
                assert!(mf.rho + mf.p_obs >= 0.0, "{pot:?} kF = {kf}");
                if mf.rho > 0.0 {
                    assert!(mf.p_obs / mf.rho >= -1.0 - 1e-15);
                }
            }
        }
    }

    #[test]
    fn root_counts_three_for_strong_repulsion_one_for_concave_w() {
        // DFT-2: (m0, lam, kF) = (0.05, 20, 1): three roots
        let pot = Potential::Quadratic { v0: 0.0, m0: 0.05, lam: 20.0 };
        let n8 = fermi_sea(0.0, 1.0).n;
        let roots = gap_roots_scan(&pot, 1.0, 1.0, 0.05 - 20.0 * n8, 0.05 + 20.0 * n8).unwrap();
        assert_eq!(roots.len(), 3, "roots {roots:?}");
        // concave W (W'' <= 0): exactly one root on a kF grid, counted by a wide scan
        let concave = [
            Potential::Mass { m0: 3.0 },
            Potential::LambdaMass { v0: 0.2, m0: 3.0 },
            Potential::Power { m0: 3.0, lam: 0.8, nu: 0.236 },
            Potential::Power { m0: 0.0, lam: 0.8, nu: 0.5 },
            Potential::ExpDamp { v0: 0.1, m0: 3.0, s1: 0.05 },
            Potential::Quadratic { v0: 0.0, m0: 3.0, lam: -20.0 },
        ];
        for pot in concave.iter() {
            for &kf in &[1e-3, 0.03, 0.3, 3.0, 30.0] {
                let n8 = fermi_sea(0.0, kf).n;
                let (lo, hi) = if pot.nonneg_domain() { (0.0, 1e12) } else { (-1e3, 1e3) };
                let roots = gap_roots_scan(pot, kf, 1.0, lo, hi).unwrap();
                assert_eq!(roots.len(), 1, "{pot:?} kF = {kf} (n8 = {n8:e}): roots {roots:?}");
                let mf = solve_gap(pot, kf, 1.0, Selection::Lowest).unwrap();
                assert!(rel(mf.m, roots[0]) < 1e-12);
            }
        }
    }

    #[test]
    fn walecka_functional_is_minimized_at_the_gap_root() {
        // DFT-1 test value: W = sigma - 10 sigma^2, kF = 1: m* = 0.211249, rho = 0.121193
        let pot = Potential::Quadratic { v0: 0.0, m0: 1.0, lam: -20.0 };
        let mf = solve_gap(&pot, 1.0, 1.0, Selection::Lowest).unwrap();
        assert!((mf.m - 0.211249).abs() < 5e-7, "m* = {}", mf.m);
        assert!((mf.rho - 0.121193).abs() < 5e-7, "rho = {}", mf.rho);
        let om = |m: f64| walecka_functional(&pot, m, 1.0, 1.0, -1e3, 1e3).unwrap();
        assert!(rel(om(mf.m), mf.rho) < 1e-12);
        for &dm in &[1e-3, 1e-2, 0.1] {
            assert!(om(mf.m + dm) > om(mf.m) && om(mf.m - dm) > om(mf.m), "not a minimum at dm = {dm}");
        }
    }

    #[test]
    fn vacuum_energy_vanishes_to_fifth_order_at_the_reference_mass() {
        let mm = 2.0;
        assert_eq!(vacuum_energy(mm, mm), 0.0);
        let (a, b) = (vacuum_energy(mm * 1.01, mm), vacuum_energy(mm * 1.02, mm));
        // O(d^5): doubling d multiplies it by ~32
        assert!((b / a - 32.0).abs() < 1.5, "ratio {}", b / a);
        assert!(vacuum_energy(-1.3, mm) == vacuum_energy(1.3, mm));
    }

    #[test]
    fn ks_functional_stationary_point_is_a_maximum_for_the_mass_term() {
        // design B.4(G) says: ground state = global minimum of E_n[sigma] over sigma in (-n, n).
        // For W = m0 sigma the self-consistent point (m = m0) is stationary but a MAXIMUM, and the
        // infimum is approached at sigma -> -n (E -> -m0 n), which is unphysical.
        let pot = Potential::Mass { m0: 2.0 };
        let (kf, v) = (1.5, 1.0);
        let mf = solve_gap(&pot, kf, v, Selection::Lowest).unwrap();
        let e0 = ks_functional(&pot, mf.sigma8, kf, v).unwrap();
        assert!(rel(e0, mf.rho) < 1e-12, "E_n at the gap solution = rho_8");
        let d = 1e-3 * mf.n8;
        let (ep, em) = (ks_functional(&pot, mf.sigma8 + d, kf, v).unwrap(), ks_functional(&pot, mf.sigma8 - d, kf, v).unwrap());
        assert!(ep < e0 && em < e0, "stationary point is a local maximum: {em} {e0} {ep}");
        let e_end = ks_functional(&pot, -0.999_999 * mf.n8, kf, v).unwrap();
        assert!(e_end < 0.0 && e_end < e0, "E_n near sigma = -n: {e_end} < E_n(gap) = {e0}");
    }
}
