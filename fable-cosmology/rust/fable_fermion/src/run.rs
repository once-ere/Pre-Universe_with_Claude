//! Running fable4d / fable8d: parameter specifications, the normalization (shooting) of the fable,
//! the integration, the output table and the diagnostics printed to stderr.
//!
//! # Normalization convention (all runs)
//! The hidden volume factor is normalized TODAY: v := B^3 C / (B^3 C)(A = 1), i.e. B = C = 1 at
//! A = 1, so the per-7-volume densities today are the observed ones (rho_r(1) = Omega_r0,
//! rho_b(1) = Omega_b0) and G_ratio = 1/(B^3 C) = G_4(t)/G_4(today).  For the forward fable8d
//! run this is a boundary-value problem (H_B = H_C = 0 at a_start; B = C = 1 and H_A = 1 at A = 1),
//! solved by (i) an outer iteration on ln v(a_start) (the dynamics depend on ln B, ln C only
//! through ln v; fixed point ln v_start = -(Delta ln v over the run), accelerated by secant
//! steps) and (ii) an inner shooting (bracket + Brent) on one fable parameter so that
//! H_A(A = 1) = 1.
//!
//! # Parameter specifications ("the requested split" today, v = 1)
//! * `mass` (m0): W = m0 sigma.  kF0 is the shooting parameter; the fable closes the budget,
//!   Omega_f0 = 1 - Omega_r0 - Omega_b0 (an Einstein-de Sitter-like universe, q0 = +1/2 in fable4d).
//! * `lambda-mass` (m0, omega_dm): W = V0 + m0 sigma.  kF0 from eps(m0, kF0) = omega_dm
//!   (quasiparticles = the dark matter today); V0 (a bare Lambda) is the shooting parameter.
//! * `power` (m_today, nu, omega_dm): W = m0 sigma + lam sigma^nu.  kF0 from
//!   eps(m_today, kF0) = omega_dm, sigma_t = sigma_KS(m_today, kF0); the condensate energy today
//!   U_t = (1 - nu) lam sigma_t^nu is the shooting parameter; lam = U_t/((1 - nu) sigma_t^nu) and
//!   m0 = m_today - nu lam sigma_t^(nu - 1) (so that m_eff(A = 1) = m_today; m0 may be negative).
//! * `expdamp` (m_today, xt, omega_dm): W = V0 + m0 sigma e^(-sigma/s1).  Part VI's classical
//!   parameters (V0, m, s1) = (1.566, 0.839, 2.21) with s_today = 1 are rescaled by keeping the
//!   ratio xt = sigma_t/s1 = 1/2.21 (where the classical w crossed -1, relative to today) and
//!   imposing the split: s1 = sigma_t/xt, m0 = m_today e^xt/(1 - xt), V0 = the shooting parameter
//!   (the classical ratio V0 : m s_t is NOT kept; the split fixes it instead).
//! * `lorentz` (m_today, xt, omega_dm): W = V0 + m0 sigma/(1 + (sigma/s1)^2), xt = sigma_t/s1
//!   (default 1/1.5, Part VI's s1 = 1.5), m0 = m_today (1 + xt^2)^2/(1 - xt^2), V0 shot.
//! * `quadratic` (m_today, gq, omega_dm): W = V0 + m0 sigma + (lam/2) sigma^2 with
//!   lam = gq m_today/sigma_t (gq = the interaction's share of m_eff today, either sign),
//!   m0 = m_today (1 - gq), V0 (a bare Lambda: the sigma^2 term dilutes like A^-6 in the
//!   non-relativistic era and cannot supply late dark energy) shot.  NOT frozen-hidden compatible
//!   unless m0 = V0 = 0 (then W = (lam/2) sigma^2; use `--no-shoot` or `explicit`).
//! * `explicit` (all W parameters given): kF0 is shot (design review E9), after asserting that
//!   rho_f(A = 1; kF0) is monotonic on the chosen gap branch.
//! * `--no-shoot` (`direct`): the potential's own parameters and kF0 are used as given.

use std::fmt::Write as _;

use crate::constants::Units;
use crate::cvode_driver::{integrate, Stats, Trajectory};
use crate::kohn_sham::{fermi_sea, solve_gap, Selection};
use crate::models::{col_index, fill_today_columns, rhs_fable4d, rhs_fable8d, row, scale, unscale, FableSpec, Model, Sources, COLUMNS};
use crate::numerics::brent;
use crate::potentials::Potential;

/// Lunar-laser-ranging bound on |dG/dt / G| today (Hofmann & Mueller 2018: (7.1 +- 7.6)e-14 /yr).
pub const LLR_GDOT_BOUND_PER_YR: f64 = 1.0e-13;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ModelKind {
    Fable4d,
    Fable8d,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Direction {
    Forward,
    Backward,
}

#[derive(Clone, Debug)]
pub struct Config {
    pub kind: ModelKind,
    pub direction: Direction,
    pub a_start: f64,
    pub points: usize,
    pub rtol: f64,
    pub atol: f64,
    pub adams: bool,
    pub freeze_hidden: bool,
    pub sel: Selection,
    pub max_steps: i64,
    pub omega_r0: f64,
    pub omega_b0: f64,
}

impl Config {
    pub fn new(kind: ModelKind, direction: Direction, u: &Units) -> Self {
        Config {
            kind,
            direction,
            a_start: 1e-12,
            points: 2001,
            rtol: 1e-10,
            atol: 1e-12,
            adams: false,
            freeze_hidden: false,
            sel: Selection::Lowest,
            max_steps: 1_000_000,
            omega_r0: u.omega_r0,
            omega_b0: u.omega_b0,
        }
    }
}

#[derive(Clone, Debug)]
pub enum Spec {
    /// no fable at all (radiation + baryons)
    NoFable,
    /// potential and kF0 as given (no shooting)
    Direct { pot: Potential, kf0: f64 },
    /// potential as given, kF0 shot
    Explicit { pot: Potential },
    Mass { m0: f64 },
    LambdaMass { m0: f64, omega_dm: f64 },
    Power { m_today: f64, nu: f64, omega_dm: f64 },
    ExpDamp { m_today: f64, xt: f64, omega_dm: f64 },
    Lorentz { m_today: f64, xt: f64, omega_dm: f64 },
    Quadratic { m_today: f64, gq: f64, omega_dm: f64 },
}

/// kF with eps(m, kF) = target at v = 1 (eps is strictly increasing in kF).
pub fn kf_for_eps(m: f64, target: f64) -> Result<f64, String> {
    if !(target > 0.0) {
        return Err(format!("the fable energy density today must be positive, got {target}"));
    }
    let f = |lk: f64| (fermi_sea(m, lk.exp()).eps / target).ln();
    let (mut lo, mut hi) = (-10.0f64, 10.0f64);
    while f(lo) > 0.0 {
        lo -= 10.0;
    }
    while f(hi) < 0.0 {
        hi += 10.0;
    }
    brent(f, lo, hi, 1e-15, 400).map(|(x, _)| x.exp())
}

/// ln kF0 with rho_f(A = 1, v = 1; kF0) = target on the chosen gap branch, after asserting that
/// rho_f is strictly increasing in kF0 on a grid ln kF0 in [-40, 40] (step 0.05) wherever the gap
/// equation is solvable (design review E9).
pub fn lnkf0_closure(pot: &Potential, target: f64, sel: Selection) -> Result<(f64, String), String> {
    let rho = |lk: f64| solve_gap(pot, lk.exp(), 1.0, sel).map(|mf| mf.rho);
    let grid: Vec<f64> = (0..=1600).map(|i| -40.0 + 0.05 * i as f64).collect();
    let vals: Vec<Option<f64>> = grid.iter().map(|&lk| rho(lk).ok()).collect();
    let mut prev: Option<(f64, f64)> = None;
    let mut bad = Vec::new();
    let mut crossings = Vec::new();
    for (lk, v) in grid.iter().zip(vals.iter()) {
        if let Some(r) = v {
            if let Some((plk, pr)) = prev {
                if !(*r > pr) {
                    bad.push(format!("ln kF0 {plk:.2}->{lk:.2}: {pr:.6e} -> {r:.6e}"));
                }
                if (pr - target) * (r - target) <= 0.0 {
                    crossings.push((plk, *lk));
                }
            }
            prev = Some((*lk, *r));
        }
    }
    let failed = vals.iter().filter(|v| v.is_none()).count();
    if !bad.is_empty() {
        return Err(format!("rho_f(A=1; kF0) is NOT monotonic on the {sel:?} branch of {pot:?}: {} (first: {})", bad.len(), bad[0]));
    }
    if crossings.len() != 1 {
        return Err(format!("rho_f(A=1; kF0) = {target} has {} solutions on the grid for {pot:?}", crossings.len()));
    }
    let (lo, hi) = crossings[0];
    let (x, _) = brent(|lk| rho(lk).map(|r| r - target).unwrap_or(f64::NAN), lo, hi, 1e-15, 400)?;
    Ok((x, format!("rho_f(A=1; kF0) strictly increasing on the {sel:?} branch over ln kF0 in [-40, 40] ({} grid points, {failed} without a gap solution); unique solution ln kF0 = {x:.15e}", grid.len())))
}

impl Spec {
    pub fn label(&self) -> String {
        match self {
            Spec::NoFable => "none".into(),
            Spec::Direct { pot, .. } => format!("{}-direct", pot.name()),
            Spec::Explicit { pot } => format!("{}-explicit", pot.name()),
            Spec::Mass { .. } => "mass".into(),
            Spec::LambdaMass { .. } => "lambda-mass".into(),
            Spec::Power { .. } => "power".into(),
            Spec::ExpDamp { .. } => "expdamp".into(),
            Spec::Lorentz { .. } => "lorentz".into(),
            Spec::Quadratic { .. } => "quadratic".into(),
        }
    }

    /// What is shot, in words (printed to stderr).
    pub fn shooting_parameter(&self) -> &'static str {
        match self {
            Spec::NoFable | Spec::Direct { .. } => "none",
            Spec::Mass { .. } | Spec::Explicit { .. } => "ln kF0 (the fable number density)",
            Spec::LambdaMass { .. } | Spec::ExpDamp { .. } | Spec::Lorentz { .. } | Spec::Quadratic { .. } => "V0 (kF0 fixed by eps(m_today, kF0) = omega_dm)",
            Spec::Power { .. } => "ln U_t, U_t = (1 - nu) lam sigma_t^nu > 0 (kF0 fixed by eps(m_today, kF0) = omega_dm)",
        }
    }

    fn shoots_kf0(&self) -> bool {
        matches!(self, Spec::Mass { .. } | Spec::Explicit { .. })
    }

    fn has_shooting(&self) -> bool {
        !matches!(self, Spec::NoFable | Spec::Direct { .. })
    }

    /// The quasiparticle mass the split specs impose today (NaN otherwise).
    pub fn m_today(&self) -> f64 {
        match *self {
            Spec::LambdaMass { m0, .. } => m0,
            Spec::Power { m_today, .. } | Spec::ExpDamp { m_today, .. } | Spec::Lorentz { m_today, .. } | Spec::Quadratic { m_today, .. } => m_today,
            _ => f64::NAN,
        }
    }

    fn omega_dm(&self) -> f64 {
        match *self {
            Spec::LambdaMass { omega_dm, .. } | Spec::Power { omega_dm, .. } | Spec::ExpDamp { omega_dm, .. } | Spec::Lorentz { omega_dm, .. } | Spec::Quadratic { omega_dm, .. } => omega_dm,
            _ => f64::NAN,
        }
    }

    /// The fable realized from the shooting variable x (ln kF0 for mass/explicit, the amplitude
    /// otherwise).
    pub fn realize(&self, x: f64, sel: Selection) -> Result<Option<FableSpec>, String> {
        let fs = |pot: Potential, kf0: f64| {
            pot.validate()?;
            Ok(Some(FableSpec { pot, kf0, sel }))
        };
        match *self {
            Spec::NoFable => Ok(None),
            Spec::Direct { ref pot, kf0 } => fs(pot.clone(), kf0),
            Spec::Explicit { ref pot } => fs(pot.clone(), x.exp()),
            Spec::Mass { m0 } => fs(Potential::Mass { m0 }, x.exp()),
            _ => {
                let m = self.m_today();
                let kf0 = kf_for_eps(m, self.omega_dm())?;
                let st = fermi_sea(m, kf0).sigma;
                let pot = match *self {
                    Spec::LambdaMass { m0, .. } => Potential::LambdaMass { v0: x, m0 },
                    Spec::Power { m_today, nu, .. } => {
                        if !(nu > 0.0 && nu < 1.0) {
                            return Err(format!("power: nu = {nu} must lie in (0, 1) for the split parametrization (use explicit/--no-shoot otherwise)"));
                        }
                        let lam = x.exp() / ((1.0 - nu) * st.powf(nu));
                        Potential::Power { m0: m_today - nu * lam * st.powf(nu - 1.0), lam, nu }
                    }
                    Spec::ExpDamp { m_today, xt, .. } => {
                        if !(xt > 0.0 && xt < 1.0) {
                            return Err(format!("expdamp: xt = sigma_t/s1 = {xt} must lie in (0, 1) (m_eff > 0 today needs sigma_t < s1)"));
                        }
                        Potential::ExpDamp { v0: x, m0: m_today * xt.exp() / (1.0 - xt), s1: st / xt }
                    }
                    Spec::Lorentz { m_today, xt, .. } => {
                        if !(xt > 0.0 && xt < 1.0) {
                            return Err(format!("lorentz: xt = sigma_t/s1 = {xt} must lie in (0, 1)"));
                        }
                        let u = xt * xt;
                        Potential::Lorentz { v0: x, m0: m_today * (1.0 + u) * (1.0 + u) / (1.0 - u), s1: st / xt }
                    }
                    Spec::Quadratic { m_today, gq, .. } => {
                        let lam = gq * m_today / st;
                        Potential::Quadratic { v0: x, m0: m_today * (1.0 - gq), lam }
                    }
                    _ => unreachable!(),
                };
                fs(pot, kf0)
            }
        }
    }

    /// The shooting variable that makes rho_f(A = 1, v = 1) = target exactly (the fable4d
    /// closure; also the starting guess of the forward fable8d shooting).  Returns (x, note).
    pub fn closure_4d(&self, target: f64, sel: Selection) -> Result<(f64, String), String> {
        match *self {
            Spec::NoFable | Spec::Direct { .. } => Ok((f64::NAN, "no closure (nothing to shoot)".into())),
            Spec::Mass { m0 } => lnkf0_closure(&Potential::Mass { m0 }, target, sel),
            Spec::Explicit { ref pot } => lnkf0_closure(pot, target, sel),
            _ => {
                // rho_f(1) = eps(m_today, kF0) + U(sigma_t; x); U is affine in x with unit slope
                // for V0, and U_t = x itself for the power law.
                let m = self.m_today();
                let kf0 = kf_for_eps(m, self.omega_dm())?;
                let sea = fermi_sea(m, kf0);
                let f0 = self.realize(0.0, sel)?.unwrap();
                let u0 = f0.pot.u(sea.sigma);
                let x = match self {
                    Spec::Power { .. } => {
                        let ut = target - sea.eps;
                        if !(ut > 0.0) {
                            return Err(format!("power: the closure needs U_t = {ut:e} > 0 (omega_dm too large)"));
                        }
                        ut.ln()
                    }
                    _ => target - sea.eps - u0,
                };
                Ok((x, format!("kF0 = {kf0:.15e} from eps(m_today, kF0) = {}; amplitude by the affine closure", self.omega_dm())))
            }
        }
    }

    /// For the split specs: the requested state (m_eff = m_today at A = 1, v = 1) must be the
    /// selected (ground-state) gap solution of the realized potential.
    pub fn check_ground_state(&self, fable: &Option<FableSpec>) -> Result<String, String> {
        let m = self.m_today();
        if !m.is_finite() {
            return Ok(String::new());
        }
        let f = fable.as_ref().unwrap();
        let mf = solve_gap(&f.pot, f.kf0, 1.0, f.sel)?;
        if (mf.m - m).abs() > 1e-8 * m.abs() {
            return Err(format!("the requested state m_eff(A=1) = {m:e} is not the {:?} gap solution of {:?} (that is m = {:e}, {} roots)", f.sel, f.pot, mf.m, mf.n_roots));
        }
        Ok(format!("ground-state check: the {:?} gap solution at A = 1 is m_eff = {:.15e} = m_today (rel. diff {:.1e}, {} root(s))", f.sel, mf.m, (mf.m - m).abs() / m.abs(), mf.n_roots))
    }
}

/// A finished run.
pub struct RunOutput {
    pub header_comments: Vec<String>,
    pub rows: Vec<Vec<f64>>,
    pub stats: Stats,
    pub log: Vec<String>,
    pub fable: Option<FableSpec>,
    pub lnb_i: f64,
    pub lnc_i: f64,
}

impl RunOutput {
    pub fn csv(&self) -> String {
        let mut s = String::new();
        for c in &self.header_comments {
            let _ = writeln!(s, "# {c}");
        }
        s.push_str(&COLUMNS.join(","));
        s.push('\n');
        for r in &self.rows {
            let line: Vec<String> = r.iter().map(|v| format!("{v:.14e}")).collect();
            s.push_str(&line.join(","));
            s.push('\n');
        }
        s
    }

    pub fn col(&self, name: &str) -> Vec<f64> {
        let i = col_index(name);
        self.rows.iter().map(|r| r[i]).collect()
    }
}

/// Integrate fable8d from the PHYSICAL state y0 at n0; CVODE works on the scaled variables
/// (models::scale), the returned trajectory is physical again.
fn integrate_8d(model: &Model, cfg: &Config, y0: &[f64], n0: f64, n1: f64, points: usize) -> Result<Trajectory, String> {
    let ys0 = scale(n0, y0);
    let mut tr = integrate(cfg.adams, rhs_fable8d, Box::new(model.clone()), &ys0, n0, n1, points, cfg.rtol, cfg.atol, cfg.max_steps)?;
    for (n, y) in tr.x.iter().zip(tr.y.iter_mut()) {
        *y = unscale(*n, y).to_vec();
    }
    Ok(tr)
}

fn model_for(cfg: &Config, fable: Option<FableSpec>) -> Model {
    Model { src: Sources { omega_r0: cfg.omega_r0, omega_b0: cfg.omega_b0 }, fable, freeze_hidden: cfg.freeze_hidden && cfg.kind == ModelKind::Fable8d }
}

/// Forward fable8d state at N0 with H_B = H_C = 0 and H_A from the constraint.
fn forward_initial(model: &Model, n0: f64, lnb: f64, lnc: f64) -> Result<Vec<f64>, String> {
    let lnv = if model.freeze_hidden { 0.0 } else { 3.0 * lnb + lnc };
    let c = model.composition(n0, lnv)?;
    if !(c.rho > 0.0) {
        return Err(format!("rho_hat(a_start) = {} is not positive", c.rho));
    }
    let ha = c.rho.sqrt();
    Ok(vec![lnb, lnc, ha, 0.0, 0.0, 0.5 / ha])
}

/// Run to A = 1 and return (H_A(1), Delta ln B, Delta ln C, stats).
fn to_today(spec: &Spec, cfg: &Config, x: f64, lnv_i: f64) -> Result<(f64, f64, f64, Stats), String> {
    let fable = spec.realize(x, cfg.sel)?;
    let model = model_for(cfg, fable);
    let n0 = cfg.a_start.ln();
    let (lb, lc) = (0.25 * lnv_i, 0.25 * lnv_i);
    let y0 = forward_initial(&model, n0, lb, lc)?;
    let tr = integrate_8d(&model, cfg, &y0, n0, 0.0, 2)?;
    let y1 = &tr.y[1];
    Ok((y1[2], y1[0] - lb, y1[1] - lc, tr.stats))
}

/// The normalization B = C = 1 at A = 1 for FIXED fable parameters x: a secant iteration on
/// ln v(a_start) for F(ln v_start) = ln v(A=1) = ln v_start + Delta ln v.  The dynamics depend on
/// ln B, ln C only through ln v, and are exactly scale-invariant in v when every source is
/// proportional to 1/v (radiation, baryons, the mass-term fable), so the first step is usually
/// exact; the non-scale-invariant parts (V0, nonlinear W) need a few secant steps.  Stops at the
/// integration-noise floor |ln v(1)| < 50 rtol max(1, |Delta ln v|).
/// Returns (ln v_start, H_A(1), Delta ln B, Delta ln C, iterations).
fn lnv_fixed_point(spec: &Spec, cfg: &Config, x: f64, lnv_guess: f64, stats: &mut Stats) -> Result<(f64, f64, f64, f64, usize), String> {
    let mut lnv_i = lnv_guess;
    let mut hist: Vec<(f64, f64)> = Vec::new();
    for it in 0..60 {
        let (ha1, db, dc, st) = to_today(spec, cfg, x, lnv_i)?;
        stats.add(&st);
        let lnv1 = lnv_i + 3.0 * db + dc;
        let tol_lnv = 50.0 * cfg.rtol * (3.0 * db + dc).abs().max(1.0);
        if lnv1.abs() < tol_lnv {
            return Ok((lnv_i, ha1, db, dc, it + 1));
        }
        hist.push((lnv_i, lnv1));
        lnv_i = if hist.len() >= 2 {
            let (p0, f0) = hist[hist.len() - 2];
            let (p1, f1) = hist[hist.len() - 1];
            if (f1 - f0).abs() > 1e-300 { p1 - f1 * (p1 - p0) / (f1 - f0) } else { p1 - f1 }
        } else {
            lnv_i - lnv1
        };
    }
    Err(format!("ln v(a_start) iteration did not converge at x = {x:e} (history {hist:?})"))
}

/// Outer shooting: find x with H_A(1; x) = 1, where every trial x is first normalized by
/// `lnv_fixed_point` (so H_A(1; x) is a function of x alone).  Bracket by expansion from the
/// fable4d closure value, then Brent.  Failed trials count as H_A(1) = 0 (a recollapse before
/// A = 1 is the usual cause; the message is logged).  Returns (x, ln v_start, Delta ln B,
/// Delta ln C, trial runs).
fn shoot_x(spec: &Spec, cfg: &Config, x_guess: f64, log: &mut Vec<String>, stats: &mut Stats) -> Result<(f64, f64, f64, f64, usize), String> {
    let mut evals = 0usize;
    let mut last_err = String::new();
    let mut lnv_warm = 0.0f64;
    let mut best: Option<(f64, f64, f64, f64, f64)> = None; // (|g|, x, lnv, db, dc)
    let mut g = |x: f64, evals: &mut usize, stats: &mut Stats, last_err: &mut String| -> f64 {
        *evals += 1;
        match lnv_fixed_point(spec, cfg, x, lnv_warm, stats) {
            Ok((lnv, ha, db, dc, _)) => {
                lnv_warm = lnv;
                let gval = ha - 1.0;
                if best.map_or(true, |b| gval.abs() < b.0) {
                    best = Some((gval.abs(), x, lnv, db, dc));
                }
                gval
            }
            Err(e) => {
                crate::models::debug_rhs_error(f64::NAN, lnv_warm, &format!("shooting trial x = {x:e} failed: {e}"));
                *last_err = e;
                -1.0
            }
        }
    };
    let step0 = if spec.shoots_kf0() || matches!(spec, Spec::Power { .. }) { 0.1 } else { (0.1 * x_guess.abs()).max(0.02) };
    let mut a = x_guess;
    let mut fa = g(a, &mut evals, stats, &mut last_err);
    let dir = if fa < 0.0 { 1.0 } else { -1.0 };
    let mut step = step0;
    let mut b = a + dir * step;
    let mut fb = if fa == 0.0 { 0.0 } else { g(b, &mut evals, stats, &mut last_err) };
    let mut k = 0;
    while fa != 0.0 && (fa > 0.0) == (fb > 0.0) && fb != 0.0 {
        a = b;
        fa = fb;
        step *= 2.0;
        b = a + dir * step;
        fb = g(b, &mut evals, stats, &mut last_err);
        k += 1;
        if k > 60 {
            return Err(format!("shooting: no bracket for H_A(1) = 1 from x = {x_guess} (last x = {b}, H_A(1) - 1 = {fb}; last integration error: {last_err})"));
        }
    }
    if fa != 0.0 && fb != 0.0 {
        let (lo, hi) = if a < b { (a, b) } else { (b, a) };
        let tol = 1e-13 * lo.abs().max(hi.abs()).max(1e-2);
        brent(|x| g(x, &mut evals, stats, &mut last_err), lo, hi, tol, 200)?;
    }
    if !last_err.is_empty() {
        log.push(format!("shooting note: some trial integrations failed (counted as H_A(1) = 0): {last_err}"));
    }
    let (_, x, lnv, db, dc) = best.ok_or("shooting: no successful trial")?;
    Ok((x, lnv, db, dc, evals))
}

/// The machine-readable parameter line of the CSV header (read by the Python cross-check).
fn params_line(cfg: &Config, spec: &Spec, fable: &Option<FableSpec>, lnb_i: f64, lnc_i: f64, u: &Units) -> String {
    let mut s = format!(
        "params: model={} direction={} spec={} a_start={:e} omega_r0={:.17e} omega_b0={:.17e} freeze={} branch={:?} lnB_i={:.17e} lnC_i={:.17e} e_c_ev={:.17e} omega_nu1={:.17e} rtol={:e} atol={:e}",
        if cfg.kind == ModelKind::Fable4d { "fable4d" } else { "fable8d" },
        if cfg.direction == Direction::Forward { "forward" } else { "backward" },
        spec.label(),
        cfg.a_start,
        cfg.omega_r0,
        cfg.omega_b0,
        cfg.freeze_hidden as i32,
        cfg.sel,
        lnb_i,
        lnc_i,
        u.e_c_ev,
        u.omega_nu1_0,
        cfg.rtol,
        cfg.atol
    );
    if let Some(f) = fable {
        let _ = write!(s, " kf0={:.17e} potential={}", f.kf0, f.pot.name());
        match f.pot {
            Potential::Mass { m0 } => { let _ = write!(s, " m0={m0:.17e}"); }
            Potential::LambdaMass { v0, m0 } => { let _ = write!(s, " v0={v0:.17e} m0={m0:.17e}"); }
            Potential::Power { m0, lam, nu } => { let _ = write!(s, " m0={m0:.17e} lam={lam:.17e} nu={nu:.17e}"); }
            Potential::ExpDamp { v0, m0, s1 } | Potential::Lorentz { v0, m0, s1 } => { let _ = write!(s, " v0={v0:.17e} m0={m0:.17e} s1={s1:.17e}"); }
            Potential::Quadratic { v0, m0, lam } => { let _ = write!(s, " v0={v0:.17e} m0={m0:.17e} lam={lam:.17e}"); }
        }
    } else {
        s.push_str(" potential=none");
    }
    s
}

/// Linear interpolation of the first crossing of `y = level` (in the row order), in N.
fn crossing(ns: &[f64], ys: &[f64], level: f64) -> Option<f64> {
    for k in 1..ns.len() {
        let (a, b) = (ys[k - 1] - level, ys[k] - level);
        if a.is_finite() && b.is_finite() && a * b <= 0.0 && a != b {
            return Some(ns[k - 1] + (ns[k] - ns[k - 1]) * a / (a - b));
        }
    }
    None
}

/// Detect gap-branch jumps (first-order transitions) between consecutive output rows: a change of
/// the sign of m_eff, or a change of m_eff not explained by the smooth derivative dm/dN.
fn detect_branch_jump(rows: &[Vec<f64>]) -> Option<String> {
    let (i_n, i_m, i_b, i_d, i_kf) = (col_index("N"), col_index("m_eff"), col_index("branch"), col_index("dm_dN"), col_index("kF_eV"));
    for k in 1..rows.len() {
        let (p, c) = (&rows[k - 1], &rows[k]);
        let dn = (c[i_n] - p[i_n]).abs();
        let dm = (c[i_m] - p[i_m]).abs();
        let scale = p[i_m].abs().max(c[i_m].abs());
        let smooth = 5.0 * p[i_d].abs().max(c[i_d].abs()) * dn;
        let kf_scale = 1e-9 * (p[i_kf] + c[i_kf]); // eV-scaled only for a floor
        if p[i_b] != c[i_b] && p[i_b] != 0.0 && c[i_b] != 0.0 {
            return Some(format!("gap-branch jump (sign of m_eff) between N = {} and N = {}: m = {:e} -> {:e}", p[i_n], c[i_n], p[i_m], c[i_m]));
        }
        if dm > 0.25 * scale && dm > smooth && dm > kf_scale {
            return Some(format!("gap-branch jump between N = {} and N = {}: m = {:e} -> {:e} (the smooth derivative predicts |dm| <= {:e})", p[i_n], c[i_n], p[i_m], c[i_m], smooth));
        }
    }
    None
}

/// Run a model end to end.
pub fn run(cfg: &Config, spec: &Spec, u: &Units) -> Result<RunOutput, String> {
    let mut log = Vec::new();
    let mut stats = Stats::default();
    let n0 = cfg.a_start.ln();
    let target_today = 1.0 - cfg.omega_r0 - cfg.omega_b0;
    let four_d = cfg.kind == ModelKind::Fable4d;
    let frozen = cfg.freeze_hidden && !four_d;
    if !four_d && cfg.direction == Direction::Backward {
        return Err("fable8d runs forward only (design review E4): backward in time the shear modes grow as A^-3 v^-1 relative to H_A ~ A^-2, the solution runs to the 8D Kasner point H_B/H_A = -0.2929 and the constraint drifts to O(1); use fable4d --direction backward".into());
    }
    if !(cfg.a_start > 0.0 && cfg.a_start < 1.0) {
        return Err(format!("a_start = {} must lie in (0, 1)", cfg.a_start));
    }

    // ---- normalization
    let (fable, lnb_i, lnc_i) = if four_d || frozen || cfg.direction == Direction::Backward {
        // algebraic closure today: rho_r + rho_b + rho_f = 1 at A = 1, v = 1 (the constraint with
        // H_A = 1, H_B = H_C = 0)
        let (x, note) = spec.closure_4d(target_today, cfg.sel)?;
        let fable = spec.realize(x, cfg.sel)?;
        if spec.has_shooting() {
            log.push(format!("normalization: closure today (A = B = C = 1): rho_r + rho_b + rho_f = 1; shooting variable [{}] = {x:.15e}; {note}", spec.shooting_parameter()));
        } else {
            log.push("normalization: none (parameters as given)".into());
        }
        (fable, 0.0, 0.0)
    } else {
        // forward fable8d: outer shooting on the fable parameter x so that H_A(1) = 1; for every trial
        // x an inner secant iteration on ln v(a_start) so that B = C = 1 at A = 1
        let (x0, note) = spec.closure_4d(target_today, cfg.sel)?;
        let (x, lnv_i, db, dc) = if spec.has_shooting() {
            log.push(format!("normalization (forward fable8d): v := B^3 C/(B^3 C)(A=1); outer bracket + Brent shooting on [{}] so that H_A(A = 1) = 1, starting from the fable4d closure value x = {x0:.10e} ({note}); for every trial an inner secant iteration on ln v(a_start) so that B = C = 1 at A = 1 (tolerance 50 rtol max(1, |Delta ln v|), the integration-noise floor)", spec.shooting_parameter()));
            let (x, lnv, db, dc, ev) = shoot_x(spec, cfg, x0, &mut log, &mut stats)?;
            log.push(format!("  shooting converged after {ev} trials: x = {x:.15e}, ln v(a_start) = {lnv:.15e}, Delta ln B = {db:.12e}, Delta ln C = {dc:.12e}"));
            (x, lnv, db, dc)
        } else {
            log.push("normalization (forward fable8d): nothing to shoot (radiation/baryons only or --no-shoot); only ln v(a_start) is iterated so that B = C = 1 at A = 1".into());
            let (lnv, ha1, db, dc, it) = lnv_fixed_point(spec, cfg, x0, 0.0, &mut stats)?;
            log.push(format!("  ln v(a_start) = {lnv:.15e} after {it} runs; H_A(1) = {ha1:.15e} (not shot)"));
            (x0, lnv, db, dc)
        };
        let _ = lnv_i;
        let last = (db, dc);
        let fable = spec.realize(x, cfg.sel)?;
        (fable, -last.0, -last.1)
    };
    let gs = spec.check_ground_state(&fable)?;
    if !gs.is_empty() {
        log.push(gs);
    }

    let model = model_for(cfg, fable.clone());
    if let Some(f) = &fable {
        let mf = solve_gap(&f.pot, f.kf0, 1.0, cfg.sel)?;
        log.push(format!(
            "fable today (A = 1, v = 1): potential {:?}, kF0 = {:.10e} E_c = {:.6e} eV, m_eff = {:.10e} E_c = {:.6e} eV, rho_qp = {:.10e}, U = {:.10e}, rho_f = {:.10e}, w_f = {:.10e}, gap roots = {}",
            f.pot, f.kf0, u.to_ev(f.kf0), mf.m, u.to_ev(mf.m), mf.rho_qp, mf.u, mf.rho, mf.p_obs / mf.rho, mf.n_roots
        ));
    }

    // ---- the output integration
    let (x_start, x_end) = if cfg.direction == Direction::Forward { (n0, 0.0) } else { (0.0, n0) };
    let (xs, ys): (Vec<f64>, Vec<Vec<f64>>) = if four_d {
        // pre-check along the output grid: the gap must be solvable and rho_hat > 0
        for k in 0..cfg.points {
            let n = n0 * (1.0 - k as f64 / (cfg.points - 1) as f64);
            let c = model.composition(n, 0.0).map_err(|e| format!("at N = {n:.6}: {e}"))?;
            if !(c.rho > 0.0) {
                let mf = c.mf.map(|m| format!("m_eff = {:e}, sigma8 = {:e}, rho_f = {:e} (U = {:e})", m.m, m.sigma8, m.rho, m.u)).unwrap_or_default();
                return Err(format!("rho_hat = {:e} <= 0 at N = {n:.6} (a = {:.4e}): the Kohn-Sham ground state has negative energy there ({mf}); H_A^2 = rho_hat is impossible", c.rho, n.exp()));
            }
        }
        let c0 = model.composition(x_start, 0.0)?;
        let t0 = if cfg.direction == Direction::Forward { 0.5 / c0.rho.sqrt() } else { 0.0 };
        // integrated variable tau = t/A^2 (see models::unscale)
        let tau0 = t0 * (-2.0 * x_start).exp();
        let tr = integrate(cfg.adams, rhs_fable4d, Box::new(model.clone()), &[tau0], x_start, x_end, cfg.points, cfg.rtol, cfg.atol, cfg.max_steps)?;
        stats.add(&tr.stats);
        let ys = tr
            .x
            .iter()
            .zip(tr.y.iter())
            .map(|(n, y)| {
                let c = model.composition(*n, 0.0)?;
                Ok(vec![0.0, 0.0, c.rho.sqrt(), 0.0, 0.0, y[0] * (2.0 * n).exp()])
            })
            .collect::<Result<Vec<_>, String>>()?;
        (tr.x, ys)
    } else {
        let y0 = forward_initial(&model, n0, lnb_i, lnc_i)?;
        let tr = integrate_8d(&model, cfg, &y0, x_start, x_end, cfg.points).map_err(|e| format!("{e} (rerun with the environment variable FABLE_DEBUG=1 to see the failing right-hand-side evaluations)"))?;
        stats.add(&tr.stats);
        (tr.x, tr.y)
    };
    let mut pairs: Vec<(f64, Vec<f64>)> = xs.into_iter().zip(ys).collect();
    if cfg.direction == Direction::Backward {
        pairs.reverse();
        // shift t so that t(a_start) = 1/(2 H_A(a_start)) (the radiation-era age)
        let shift = 0.5 / pairs[0].1[2] - pairs[0].1[5];
        for (_, y) in pairs.iter_mut() {
            y[5] += shift;
        }
    }
    let mut rows = Vec::with_capacity(pairs.len());
    for (n, y) in pairs.iter() {
        rows.push(row(&model, four_d, *n, y, u.omega_nu1_0, u.e_c_ev)?);
    }
    fill_today_columns(&mut rows, cfg.omega_r0, cfg.omega_b0);
    if let Some(msg) = detect_branch_jump(&rows) {
        return Err(format!("{msg}: a first-order transition of the Kohn-Sham ground state; the RHS is discontinuous there and energy conservation would need the Maxwell construction, which this solver does not implement"));
    }

    // ---- diagnostics for the log
    let out = RunOutput { header_comments: vec![], rows, stats, log: vec![], fable: fable.clone(), lnb_i, lnc_i };
    let ns = out.col("N");
    let res = out.col("constraint_residual");
    let maxres = res.iter().fold(0.0f64, |a, &b| a.max(b.abs()));
    let roots = out.col("gap_roots");
    let multi = roots.iter().filter(|&&r| r > 1.0).count();
    let gres = out.col("gap_residual").iter().fold(0.0f64, |a, &b| a.max(b.abs()));
    let today = out.rows.iter().min_by(|a, b| a[0].abs().partial_cmp(&b[0].abs()).unwrap()).unwrap().clone();
    let first = out.rows[0].clone();
    log.push(format!(
        "result: H_A(A=1) = {:.15e}, B(1) = {:.15e}, C(1) = {:.15e}, q0 = {:.6e}, age t0 = {:.10e}/H0, max |constraint residual| = {maxres:.3e}, max |gap residual| = {gres:.1e}, rows with several gap roots = {multi}",
        today[col_index("H_A")], today[col_index("B")], today[col_index("C")], today[col_index("q_dec")], today[col_index("t")]
    ));
    if fable.is_some() {
        let kfm = out.col("kF_over_m");
        // matter-radiation equality with today's rest-mass dust: a_eq = Omega_r0/(Omega_b0 + m_t n_t)
        let dust0 = today[col_index("m_eff")].abs() * today[col_index("n_f")];
        let a_eq = cfg.omega_r0 / (cfg.omega_b0 + dust0);
        match crossing(&ns, &kfm, 1.0) {
            Some(nnr) => {
                let anr = nnr.exp();
                // design review DFT-11 criteria: hot if a_nr > a_eq; cold-like if a_nr < ~1e-6
                let class = if anr > a_eq { "HOT (non-relativistic only after matter-radiation equality)" } else if anr > 1e-6 { "WARM / not hot (a_nr between 1e-6 and a_eq)" } else { "COLD-LIKE (a_nr < 1e-6)" };
                log.push(format!("a_nr (kF = |m_eff|) = {anr:.6e} (z_nr = {:.4e}), a_eq = {a_eq:.4e}: {class}", 1.0 / anr - 1.0));
                let amax = (1e-10f64).min(0.01 * anr);
                if cfg.a_start > amax {
                    log.push(format!("WARNING: a_start = {:e} > min(1e-10, 0.01 a_nr) = {amax:e} (design review: the interval should start deep in the ultra-relativistic radiation era)", cfg.a_start));
                }
            }
            None => log.push(format!("a_nr: kF/|m_eff| never crosses 1 on [a_start, 1] (from {:.3e} to {:.3e})", kfm[0], kfm[kfm.len() - 1])),
        }
        let k0 = kfm[0];
        if k0 < 10.0 {
            log.push(format!("WARNING: the fable is NOT ultra-relativistic at a_start (kF/|m| = {k0:.3e}; needs kF0/a_start > m)"));
        } else {
            log.push(format!("the fable is ultra-relativistic at a_start: kF/|m_eff| = {k0:.3e}"));
        }
        let neff = out.col("N_eff_extra");
        let at = |a: f64| -> f64 {
            let x = a.ln();
            for k in 1..ns.len() {
                if (ns[k - 1] - x) * (ns[k] - x) <= 0.0 {
                    let f = (x - ns[k - 1]) / (ns[k] - ns[k - 1]);
                    return neff[k - 1] + f * (neff[k] - neff[k - 1]);
                }
            }
            f64::NAN
        };
        log.push(format!("Delta N_eff (fable energy density in units of one massless neutrino species): at BBN (a = {:.4e}, T = 1 MeV) = {:.6e}, at recombination (a = {:.4e}) = {:.6e}", u.a_bbn, at(u.a_bbn), u.a_rec, at(u.a_rec)));
    }
    if four_d || frozen {
        let ps = out.col("P_stab");
        let (pmin, pmax) = ps.iter().fold((f64::INFINITY, f64::NEG_INFINITY), |a, &b| (a.0.min(b), a.1.max(b)));
        log.push(format!("stabilizer: P_stab = -F_hidden/2 ranges over [{pmin:.4e}, {pmax:.4e}] (today {:.6e}); it is a Lagrange multiplier with zero energy density and violates the null energy condition along x0 wherever dust is present (rho + P_C = -rho_dust/2)", today[col_index("P_stab")]));
    }
    if four_d {
        // t(A=1) by an independent quadrature: t = t(a_start) + Int_{N0}^{0} dN / H_A(N)
        let h = |n: f64| model.composition(n, 0.0).map(|c| c.rho.sqrt()).unwrap_or(f64::NAN);
        let n_lo = ns[0];
        let (q, qerr) = crate::numerics::integrate_gk(|n| 1.0 / h(n), n_lo, 0.0, &[-20.0, -15.0, -10.0, -8.0, -6.0, -4.0, -2.0, -1.0], 0.0, 1e-13, 20000);
        let t0q = 0.5 / h(n_lo) + q;
        let tc = today[col_index("t")];
        log.push(format!("t(A=1) cross-check: CVODE {tc:.15e} vs Gauss-Kronrod quadrature {t0q:.15e} (rel. diff {:.2e}, quadrature error estimate {qerr:.1e})", (tc - t0q).abs() / t0q));
    }
    if matches!(spec, Spec::Mass { .. }) && (four_d || frozen) {
        log.push(format!("NOTE: W = m0 sigma alone (no V0): the closure forces Omega_f0 = 1 - Omega_b0 - Omega_r0 = {target_today:.6}: an Einstein-de Sitter-like universe (q0 = {:.4}, +1/2 for pure dust)", today[col_index("q_dec")]));
    }
    if !four_d && !frozen {
        let g_start = first[col_index("G_ratio")];
        let hb = today[col_index("H_B")];
        let hc = today[col_index("H_C")];
        let gdot = -(3.0 * hb + hc);
        log.push(format!(
            "unstabilized fable8d (the no-go test): G(today)/G(a_start) = {:.6e}, v(a_start)/v(today) = {:.6e}, H_B/H_A today = {:.6e}, dlnG/dt today = {gdot:.6e} H0 = {:.6e} /yr against the lunar-laser-ranging bound |dlnG/dt| < {LLR_GDOT_BOUND_PER_YR:e} /yr ({})",
            1.0 / g_start,
            1.0 / g_start,
            hb / today[col_index("H_A")],
            gdot * u.h0_per_yr,
            if (gdot * u.h0_per_yr).abs() > LLR_GDOT_BOUND_PER_YR { "VIOLATED" } else { "satisfied" }
        ));
    }
    log.push("the DM/DE split (rho_qp = eps/v vs rho_U = W - sigma W') is a convention: the condensate has P = -rho_U in all seven spatial directions, i.e. it is an 8D vacuum energy".into());

    let mut header = vec![
        crate::VERSION.to_string(),
        params_line(cfg, spec, &fable, lnb_i, lnc_i, u),
        format!("spec: {:?}", spec),
        "units: hbar = c = 1, H0 = 1 (t in 1/H0), densities per 7-volume in rho_c0 = 3 H0^2 M_pl^2, masses and kF in E_c = rho_c0^(1/4) (m_eff_eV, kF_eV in eV)".into(),
        "v = B^3 C/(B^3 C)(A=1) (B = C = 1 today in every run); G_ratio = 1/v = G_4(t)/G_4(today); kappa_4,0 = kappa_8/V_h,0; a sigma^2 coupling lam_8 = lam_4 V_h,0".into(),
        "n_f = n/v and sigma = sigma_KS/v per 7-volume; kF_over_m = kF/|m_eff| (inf when m_eff = 0)".into(),
        "constraint_residual = (S - kappa rho)/(3 H_A^2) = (S - 3 rho_hat)/(3 H_A^2), S = 3H_A^2 + 3H_B^2 + 9H_A H_B + 3H_A H_C + 3H_B H_C".into(),
        "Omega_X = rho_X/H_A^2; Omega_sum = rho_hat/H_A^2 = 1 + (3H_B^2 + 9H_A H_B + 3H_A H_C + 3H_B H_C)/(3H_A^2) (1 in fable4d)".into(),
        "rho_qp = eps/v (quasiparticles), w_qp = w_DM_intrinsic = P/eps; rho_U = W - sigma W' (condensate, an 8D vacuum energy: P_hid_f = -rho_U); the DM/DE split is a convention".into(),
        "w_DM_eff = w_DM - sigma_KS (dm/dN)/(3 eps_KS) (eps' + 3 H_A (eps + P) = sigma m'); Q = sigma8 dm_eff/dt (energy exchange condensate -> quasiparticles per 7-volume; = n dm/dt in the non-relativistic limit)".into(),
        "rho_dust0 = m_eff(A=1) n_f(A=1) (rest-mass dust today); rho_DE_eff = rho_f - rho_dust0 A^-3 v(1)/v, w_DE_eff = P_obs_f/rho_DE_eff".into(),
        "rho_DE_inf = H_A^2 - Omega_r0 A^-4 - Omega_b0 A^-3 - rho_dust0 A^-3 (observer-inferred), w_DE_inf = -1 - (1/3) d ln rho_DE_inf/d ln A".into(),
        "F_hidden = rho - 3 P_obs + 2 P_hid (all sources; dH_B/dt + H_B Theta = F/2); P_stab = -F_hidden/2 = the zero-energy stabilizing hidden stress of fable4d, a LAGRANGE MULTIPLIER (not a derived stress) that violates the null energy condition along x0 when dust is present (rho + P_C = -rho_dust/2); 0 in unstabilized fable8d".into(),
        "vac_over_rhoc = DeltaE_vac(m_eff; M = m_eff(A=1))/v: the renormalized one-loop Dirac-sea energy (relativistic Hartree, Chin 1977) that the no-sea functional drops; reported, not included in the dynamics".into(),
        "cs2_adiabatic = (dP_obs_f/dN)/(drho_f/dN) along the solution (analytic, with the differentiated gap equation); N_eff_extra = rho_f / rho_nu(1 species), rho_nu1 = Omega_nu1_0 A^-4/v".into(),
        "q_dec = -1 - (dH_A/dt)/H_A^2; gap_roots = number of gap roots found (1 where uniqueness is proven); branch = sign of m_eff; gap_residual = (m - W'(sigma))/scale; dm_dN = d m_eff/dN".into(),
        "g_*(T) is not followed: rho_r = Omega_r0 A^-4/v at all times (misstates rho_r A^4 by up to a factor ~0.39 at the earliest times)".into(),
    ];
    if cfg.direction == Direction::Backward {
        header.push("t: integrated from today (lookback) and shifted so that t(a_start) = 1/(2 H_A(a_start)) (radiation-era age); absolute accuracy ~1e-8/H0, so early-time ages below ~3e-8/H0 are not resolved (use the forward run)".into());
    } else {
        header.push("t: t(a_start) = 1/(2 H_A(a_start)) (radiation-era age), then integrated".into());
    }
    Ok(RunOutput { header_comments: header, rows: out.rows, stats, log, fable, lnb_i, lnc_i })
}

