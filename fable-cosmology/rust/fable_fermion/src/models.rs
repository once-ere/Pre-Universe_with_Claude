//! The two cosmological models of design B.3 with the Kohn-Sham fable as a source.
//!
//! Units (constants.rs): H0 = 1, densities in rho_c0, masses/momenta in E_c = rho_c0^(1/4).
//! Independent variable N = ln A (A the observed scale factor).
//!
//! # fable8d: the asymptotic region of the primordial field = 8D Bianchi-I
//! `ds^2 = C^2 dz^2 + A^2 dx_obs^2 - dt^2 - B^2 dx_hid^2` (z = proper x0, x_hid = x5..x7, the
//! hidden timelike sheet).  With `H_X = d ln X/dt`, `Theta = 3 H_A + 3 H_B + H_C` and
//! `kappa_8 rho -> 3 rho_hat` (rho_hat per 7-volume, in rho_c0):
//! ```text
//! constraint:  3 H_A^2 + 3 H_B^2 + 9 H_A H_B + 3 H_A H_C + 3 H_B H_C = 3 rho_hat     (monitored)
//! evolution:   dH_i/dt = -H_i Theta + 3 (P_i - T/6),   i = A, B, C
//!              T = -rho + 3 P_obs + 3 P_hid + P_x0   (the trace of the mixed stress tensor)
//! d/dN = (1/H_A) d/dt;   state y = (ln B, ln C, H_A, H_B, H_C, t)
//! ```
//! Sources, per 7-volume, v = B^3 C:
//! * radiation `rho_r = Omega_r0 A^-4 / v`, `P_obs = rho_r/3`, `P_hid = P_x0 = 0`;
//! * baryons `rho_b = Omega_b0 A^-3 / v`, pressureless in every direction;
//! * fable: kF = kF0/A, n8 = n/v, the gap m = W'(sigma/v) at every N (kohn_sham.rs).
//!
//! Covariant conservation in Bianchi-I, `rho' + 3 H_A (rho + P_obs) + 3 H_B (rho + P_hid) +
//! H_C (rho + P_x0) = 0`, holds for EACH source separately:
//! radiation `d ln rho_r/dt = -4 H_A - (3 H_B + H_C)` = `-3 H_A (4/3) - (3 H_B + H_C)`;
//! baryons `-3 H_A - (3 H_B + H_C)`; fable: `d rho_8 = wF dn/v - (eps/v) d ln v` (kohn_sham.rs)
//! with `dn/dt = -3 H_A n`, and `rho_8 + P_obs = wF n/v`, `rho_8 + P_hid = eps/v`.
//! The constraint propagates: `d(S - 3 rho_hat)/dt = -2 Theta (S - 3 rho_hat)` (S = the pair
//! sum), so it decays forward in time and grows backward.
//!
//! Frozen hidden theorem (design B.3): H_B = H_C = 0 is preserved iff P_hid - T/6 = 0 and
//! P_x0 - T/6 = 0, i.e. `2 P_hid = 3 P_obs - rho` (with P_hid = P_x0).  Equivalently the hidden
//! driver `F = rho - 3 P_obs + 2 P_hid` (dH_B/dt + H_B Theta = kappa F/6) vanishes: radiation
//! F = 0; dust F = rho; any 8D vacuum energy (bare V0, the condensate U) F = 2 rho_V; the
//! self-consistent KS fable F = 2 W - sigma8 W' (zero iff W is proportional to sigma^2; the
//! author's mass term gives F = m0 sigma8 > 0).
//!
//! Model roles (design review E3): the unstabilized fable8d is the NO-GO demonstration (any dust
//! or vacuum energy drives the hidden sheet towards the 7D-isotropic attractor H_B/H_A -> 1, so
//! G_4 = G_8/(B^3 C) changes by many orders of magnitude); the physical model is fable4d =
//! fable8d + a ZERO-ENERGY stabilizing hidden stress P_stab = -F_total/2 on the B and C
//! directions.  With it (and H_B = H_C = 0) the hidden pressures drop out of the conservation law,
//! the constraint becomes 3 H_A^2 = kappa rho and the A equation H_A' + 3 H_A^2 = kappa (rho - P_obs)/2,
//! i.e. exactly 4D Friedmann (without it, dust would decelerate as dH/dt = -(5/2) H^2 instead of
//! -(3/2) H^2).  `fable8d --freeze-hidden` integrates exactly this system (H_A evolved by its
//! evolution equation) and reproduces fable4d (a test).  The 8D and 4D couplings are related by
//! kappa_4 = kappa_8 / V_h,0 (V_h,0 the hidden volume today, v = 1), and a sigma^2 coupling by
//! lam_8 = lam_4 V_h,0.
//!
//! # fable4d: the hidden sheet frozen (stabilized), v = 1
//! `H_A^2 = rho_r + rho_b + rho_f` (H0 = 1), t integrated (dt/dN = 1/H_A), fable algebraic.
//! Backward runs are provided for fable4d only: backward in time the shear modes of fable8d grow
//! (the run goes to the 8D Kasner point H_B/H_A = -0.2929) and the constraint drifts to O(1).

#![allow(non_snake_case)]

use std::any::Any;

use cvode_rs::prelude::*;

use crate::kohn_sham::{fable_derivatives, solve_gap, MeanField, Selection};
use crate::potentials::Potential;

#[derive(Clone, Copy, Debug)]
pub struct Sources {
    /// radiation density per 7-volume at A = 1, v = 1
    pub omega_r0: f64,
    /// baryon density per 7-volume at A = 1, v = 1
    pub omega_b0: f64,
}

#[derive(Clone, Debug)]
pub struct FableSpec {
    pub pot: Potential,
    /// Fermi momentum at A = 1 (kF = kF0 / A), in E_c
    pub kf0: f64,
    pub sel: Selection,
}

#[derive(Clone, Debug)]
pub struct Model {
    pub src: Sources,
    pub fable: Option<FableSpec>,
    pub freeze_hidden: bool,
}

/// All sources at (N, ln v).
#[derive(Clone, Copy, Debug)]
pub struct Composition {
    pub rho_r: f64,
    pub rho_b: f64,
    pub mf: Option<MeanField>,
    pub rho_f: f64,
    pub p_obs_f: f64,
    pub p_hid_f: f64,
    pub rho: f64,
    pub p_obs: f64,
    pub p_hid: f64,
    pub p_x0: f64,
}

impl Model {
    pub fn composition(&self, n: f64, lnv: f64) -> Result<Composition, String> {
        let rho_r = self.src.omega_r0 * (-4.0 * n - lnv).exp();
        let rho_b = self.src.omega_b0 * (-3.0 * n - lnv).exp();
        let (mf, rho_f, p_obs_f, p_hid_f) = match &self.fable {
            Some(fs) => {
                let kf = fs.kf0 * (-n).exp();
                let mf = solve_gap(&fs.pot, kf, lnv.exp(), fs.sel)?;
                (Some(mf), mf.rho, mf.p_obs, mf.p_hid)
            }
            None => (None, 0.0, 0.0, 0.0),
        };
        let rho = rho_r + rho_b + rho_f;
        let p_obs = rho_r / 3.0 + p_obs_f;
        let p_hid = p_hid_f;
        Ok(Composition { rho_r, rho_b, mf, rho_f, p_obs_f, p_hid_f, rho, p_obs, p_hid, p_x0: p_hid })
    }

    /// d/dt of (H_A, H_B, H_C) for fable8d (the stabilizing hidden stress included when frozen).
    pub fn dh_dt(&self, c: &Composition, ha: f64, hb: f64, hc: f64) -> (f64, f64, f64) {
        if self.freeze_hidden {
            let ph = 0.5 * (3.0 * c.p_obs - c.rho);
            let t = -c.rho + 3.0 * c.p_obs + 4.0 * ph;
            (-3.0 * ha * ha + 3.0 * (c.p_obs - t / 6.0), 0.0, 0.0)
        } else {
            let theta = 3.0 * ha + 3.0 * hb + hc;
            let t = -c.rho + 3.0 * c.p_obs + 3.0 * c.p_hid + c.p_x0;
            (
                -ha * theta + 3.0 * (c.p_obs - t / 6.0),
                -hb * theta + 3.0 * (c.p_hid - t / 6.0),
                -hc * theta + 3.0 * (c.p_x0 - t / 6.0),
            )
        }
    }
}

/// The pair sum S = 3 H_A^2 + 3 H_B^2 + 9 H_A H_B + 3 H_A H_C + 3 H_B H_C.
pub fn pair_sum(ha: f64, hb: f64, hc: f64) -> f64 {
    3.0 * ha * ha + 3.0 * hb * hb + 9.0 * ha * hb + 3.0 * ha * hc + 3.0 * hb * hc
}

/// Relative constraint residual (S - 3 rho_hat) / max(3 rho_hat, 3 H_A^2).
pub fn constraint_residual(ha: f64, hb: f64, hc: f64, rho: f64) -> f64 {
    (pair_sum(ha, hb, hc) - 3.0 * rho) / (3.0 * rho.abs()).max(3.0 * ha * ha)
}

/// The physical state (ln B, ln C, H_A, H_B, H_C, t) from the integrated one.
///
/// CVODE integrates the SCALED variables h_i = H_i A^2 and tau = t / A^2 (A = e^N): from
/// a_start = 1e-12 the physical H_i fall by ~24 orders of magnitude while H_B, H_C start at
/// exactly 0, so no absolute tolerance suits the unscaled H (the first steps collapse to
/// t + h = t).  In the radiation era h_A and tau are constant, so the scaled problem is O(1)
/// throughout; the equations are the same, multiplied through by A^2.
pub fn unscale(n: f64, y: &[f64]) -> [f64; 6] {
    let e = (-2.0 * n).exp();
    [y[0], y[1], y[2] * e, y[3] * e, y[4] * e, y[5] / e]
}

/// The integrated state from the physical one (inverse of `unscale`).
pub fn scale(n: f64, p: &[f64]) -> Vec<f64> {
    let e = (2.0 * n).exp();
    vec![p[0], p[1], p[2] * e, p[3] * e, p[4] * e, p[5] / e]
}

/// fable8d right-hand side, independent variable N; integrated state
/// y = (ln B, ln C, h_A, h_B, h_C, tau) with h_i = H_i A^2, tau = t/A^2:
/// d ln B/dN = H_B/H_A, d ln C/dN = H_C/H_A, dh_i/dN = 2 h_i + A^2 (dH_i/dt)/H_A,
/// dtau/dN = -2 tau + A^-2/H_A.
pub fn rhs_fable8d(n: f64, y: &N_Vector, ydot: &N_Vector, ud: &mut Option<Box<dyn Any>>) -> i32 {
    let m = match ud.as_ref().and_then(|b| b.downcast_ref::<Model>()) {
        Some(m) => m,
        None => return -1,
    };
    let yv = N_VGetArrayPointer(y).expect("y");
    let (lnb, lnc, sa, sb, sc, tau) = (yv[0], yv[1], yv[2], yv[3], yv[4], yv[5]);
    let e = (-2.0 * n).exp(); // A^-2
    let (ha, hb, hc) = (sa * e, sb * e, sc * e);
    if !(ha > 0.0) || !ha.is_finite() || !hb.is_finite() || !hc.is_finite() {
        return 1;
    }
    let lnv = if m.freeze_hidden { 0.0 } else { 3.0 * lnb + lnc };
    let c = match m.composition(n, lnv) {
        Ok(c) => c,
        Err(_) => return 1,
    };
    let (dha, dhb, dhc) = m.dh_dt(&c, ha, hb, hc);
    let mut yd = N_VGetArrayPointer(ydot).expect("ydot");
    if m.freeze_hidden {
        yd[0] = 0.0;
        yd[1] = 0.0;
    } else {
        yd[0] = hb / ha;
        yd[1] = hc / ha;
    }
    yd[2] = 2.0 * sa + dha / (ha * e);
    yd[3] = if m.freeze_hidden { 0.0 } else { 2.0 * sb + dhb / (ha * e) };
    yd[4] = if m.freeze_hidden { 0.0 } else { 2.0 * sc + dhc / (ha * e) };
    yd[5] = -2.0 * tau + e / ha;
    0
}

/// fable4d right-hand side; integrated state y = (tau = t/A^2), H_A = sqrt(rho_hat(N)) with v = 1:
/// dtau/dN = -2 tau + A^-2/H_A.
pub fn rhs_fable4d(n: f64, y: &N_Vector, ydot: &N_Vector, ud: &mut Option<Box<dyn Any>>) -> i32 {
    let m = match ud.as_ref().and_then(|b| b.downcast_ref::<Model>()) {
        Some(m) => m,
        None => return -1,
    };
    let c = match m.composition(n, 0.0) {
        Ok(c) => c,
        Err(_) => return 1,
    };
    if !(c.rho > 0.0) {
        return 1;
    }
    let tau = N_VGetArrayPointer(y).expect("y")[0];
    let mut yd = N_VGetArrayPointer(ydot).expect("ydot");
    yd[0] = -2.0 * tau + (-2.0 * n).exp() / c.rho.sqrt();
    0
}


/// The hidden-sheet driver of one composition, F = rho - 3 P_obs + 2 P_hid (P_x0 = P_hid for
/// every source): dH_B/dt + H_B Theta = kappa F/6 = F/2 in solver units.  Radiation F = 0, dust
/// F = rho, any 8D vacuum energy (bare V0, the condensate U) F = 2 rho_V, the self-consistent KS
/// fable F = 2 W - sigma8 W'.  The stabilizing stress of fable4d is P_stab = -F/2.
pub fn hidden_driver(c: &Composition) -> f64 {
    c.rho - 3.0 * c.p_obs + 2.0 * c.p_hid
}

/// The columns of every output CSV, in order: the required ones, the ones the design review
/// added, and a few extras.
pub const COLUMNS: [&str; 46] = [
    "N", "a", "z", "t", "B", "C", "H_A", "H_B", "H_C", "constraint_residual", "rho_r", "rho_b", "rho_f", "P_obs_f", "P_hid_f", "n_f", "sigma", "m_eff", "kF_over_m", "w_f", "rho_qp", "w_qp", "rho_U", "w_DE_eff", "Omega_r", "Omega_b", "Omega_f", "q_dec", "G_ratio", "cs2_adiabatic", "N_eff_extra",
    // added by the design review (E3, E8, E10)
    "P_stab", "Omega_sum", "rho_DE_inf", "w_DE_inf", "w_DM_intrinsic", "w_DM_eff", "Q",
    // extras
    "rho_DE_eff", "F_hidden", "dm_dN", "m_eff_eV", "kF_eV", "gap_roots", "branch", "gap_residual",
];

pub fn col_index(name: &str) -> usize {
    COLUMNS.iter().position(|c| *c == name).unwrap_or_else(|| panic!("no column {name}"))
}

/// One output row, from the state at N.  `y` is the fable8d state (ln B, ln C, H_A, H_B, H_C, t);
/// for fable4d pass (0, 0, H_A, 0, 0, t).  `stabilized` = fable4d or fable8d --freeze-hidden (the
/// zero-energy stabilizing hidden stress is present).  The columns that need today's row
/// (w_DE_eff, rho_DE_eff, rho_DE_inf, w_DE_inf) are filled by `fill_today_columns`.
pub fn row(model: &Model, four_d: bool, n: f64, y: &[f64], omega_nu1: f64, e_c_ev: f64) -> Result<Vec<f64>, String> {
    let (lnb, lnc, ha, hb, hc, t) = (y[0], y[1], y[2], y[3], y[4], y[5]);
    let stabilized = four_d || model.freeze_hidden;
    let lnv = if stabilized { 0.0 } else { 3.0 * lnb + lnc };
    let c = model.composition(n, lnv)?;
    let a = n.exp();
    let dha = if four_d { -1.5 * (c.rho + c.p_obs) } else { model.dh_dt(&c, ha, hb, hc).0 };
    let q = -1.0 - dha / (ha * ha);
    let resid = constraint_residual(ha, hb, hc, c.rho);
    let ell = if stabilized { 0.0 } else { (3.0 * hb + hc) / ha };
    let f_hidden = hidden_driver(&c);
    let p_stab = if stabilized { -0.5 * f_hidden } else { 0.0 };
    let nan = f64::NAN;
    let (n8, s8, meff, kfm, rho_qp, w_qp, rho_u, cs2, roots, branch, gres, kf, dmdn, w_dm_eff, q_ex) = match &c.mf {
        Some(mf) => {
            let (drho, dp, dm) = fable_derivatives(mf, ell);
            let kfm = if mf.m != 0.0 { mf.kf / mf.m.abs() } else { f64::INFINITY };
            let wqp = if mf.sea.eps != 0.0 { mf.sea.p / mf.sea.eps } else { nan };
            // eps' + 3 H_A (eps + P) = sigma m'  (per 3-volume; the v-dilution cancels):
            // w_DM_eff = w_DM - sigma_KS (dm/dN) / (3 eps_KS);  Q = sigma8 dm/dt = sigma8 H_A dm/dN
            let wde = if mf.sea.eps != 0.0 { wqp - mf.sea.sigma * dm / (3.0 * mf.sea.eps) } else { nan };
            (mf.n8, mf.sigma8, mf.m, kfm, mf.rho_qp, wqp, mf.u, dp / drho, mf.n_roots as f64, mf.branch as f64, mf.gap_residual, mf.kf, dm, wde, mf.sigma8 * ha * dm)
        }
        None => (0.0, 0.0, 0.0, nan, 0.0, nan, 0.0, nan, 0.0, 0.0, 0.0, 0.0, 0.0, nan, 0.0),
    };
    let h2 = ha * ha;
    let w_f = if c.rho_f != 0.0 { c.p_obs_f / c.rho_f } else { nan };
    let rho_nu1 = omega_nu1 * (-4.0 * n - lnv).exp();
    let (bb, cc) = if stabilized { (1.0, 1.0) } else { (lnb.exp(), lnc.exp()) };
    // Omega_sum = rho_hat/H_A^2 = 1 + (3H_B^2 + 9H_A H_B + 3H_A H_C + 3H_B H_C)/(3H_A^2) on the constraint
    let omega_sum = c.rho / h2;
    Ok(vec![
        n, a, 1.0 / a - 1.0, t, bb, cc, ha, hb, hc, resid, c.rho_r, c.rho_b, c.rho_f, c.p_obs_f, c.p_hid_f, n8, s8, meff, kfm, w_f, rho_qp, w_qp, rho_u, nan, c.rho_r / h2, c.rho_b / h2, c.rho_f / h2, q, (-lnv).exp(), cs2, c.rho_f / rho_nu1,
        p_stab, omega_sum, nan, nan, w_qp, w_dm_eff, q_ex,
        nan, f_hidden, dmdn, meff * e_c_ev, kf * e_c_ev, roots, branch, gres,
    ])
}

/// Fill the columns that need today's row (A = 1, where v = 1):
/// * rest-mass dust today: rho_dust0 = m_eff(A=1) n_f(A=1) (a stated constant);
/// * `rho_DE_eff = rho_f - rho_dust0 A^-3 v(A=1)/v` (the fable minus the rest-mass dust it would
///   be with today's mass, scaled as A^-3 v^-1), `w_DE_eff = P_obs_f / rho_DE_eff`;
/// * the observer-inferred dark energy (design review E10):
///   `rho_DE_inf = H_A^2 - Omega_r0 A^-4 - Omega_b0 A^-3 - rho_dust0 A^-3`,
///   `w_DE_inf = -1 - (1/3) d ln rho_DE_inf/d ln A`, with d(H_A^2)/dN = 2 dH_A/dt.
pub fn fill_today_columns(rows: &mut [Vec<f64>], omega_r0: f64, omega_b0: f64) {
    let (i_n, i_ha, i_q, i_nf, i_m, i_g, i_rhof, i_p) = (col_index("N"), col_index("H_A"), col_index("q_dec"), col_index("n_f"), col_index("m_eff"), col_index("G_ratio"), col_index("rho_f"), col_index("P_obs_f"));
    let (i_w, i_rde, i_rinf, i_winf) = (col_index("w_DE_eff"), col_index("rho_DE_eff"), col_index("rho_DE_inf"), col_index("w_DE_inf"));
    let today = match rows.iter().min_by(|a, b| a[i_n].abs().partial_cmp(&b[i_n].abs()).unwrap()) {
        Some(r) => r.clone(),
        None => return,
    };
    let dust0 = today[i_m].abs() * today[i_nf] / today[i_g]; // m_t n_t v_t (v_t = 1/G_ratio_t = 1)
    for r in rows.iter_mut() {
        let a = r[i_n].exp();
        let v = 1.0 / r[i_g];
        let dust = dust0 * a.powi(-3) / v;
        let rde = r[i_rhof] - dust;
        r[i_rde] = rde;
        r[i_w] = if rde != 0.0 { r[i_p] / rde } else { f64::NAN };
        let ha = r[i_ha];
        let hdot = -(1.0 + r[i_q]) * ha * ha;
        let rinf = ha * ha - omega_r0 * a.powi(-4) - (omega_b0 + dust0) * a.powi(-3);
        let drinf = 2.0 * hdot + 4.0 * omega_r0 * a.powi(-4) + 3.0 * (omega_b0 + dust0) * a.powi(-3);
        r[i_rinf] = rinf;
        r[i_winf] = if rinf != 0.0 { -1.0 - drinf / (3.0 * rinf) } else { f64::NAN };
    }
}
