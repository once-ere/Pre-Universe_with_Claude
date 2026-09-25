//! The five numerical models of DESIGN.md §4, each as a CVODE right-hand side plus the
//! bookkeeping that turns an integrated state into the physical quantities of the CSV.
//!
//! Units throughout the FLRW models: `8 pi G = 1` (`M_pl = 1`), `H0 = 1`, `a0 = 1`, so the
//! critical density today is `rho_crit = 3 H0^2 M_pl^2 = 3`.  The independent variable is
//! `N = ln a`.  Cosmic time `t` (in units of `1/H0`) is carried as a state variable through
//! `dt/dN = 1/H`.
//!
//! Units in the pre-universe models: the notebook's constant `H = 1` (so `6 H x0 = 6 x0` and the
//! standing assumption `0 < 6 H x0 < pi/2` reads `0 < x0 < pi/12`); the field is dimensionless.

#![allow(non_snake_case)]

use std::any::Any;
use std::collections::HashMap;

use cvode_rs::prelude::*;

use crate::potentials::{param, ScalarPotential, SpinorPotential};

/// Cosmological background parameters shared by Models A, A' and B.
#[derive(Clone, Copy, Debug)]
pub struct Background {
    pub om: f64,
    pub or: f64,
    pub w0: f64,
    pub wa: f64,
}

impl Background {
    pub fn from_params(p: &HashMap<String, f64>) -> Self {
        Background {
            om: param(p, "om", 0.3),
            or: param(p, "or", 8.4e-5),
            w0: param(p, "w0", -0.861),
            wa: param(p, "wa", -0.60),
        }
    }
    /// The dark-energy fraction today that closes the universe.
    pub fn ode0(&self) -> f64 {
        1.0 - self.om - self.or
    }
    /// The CPL dark-energy density factor `rho_DE(a)/rho_DE(1)` in closed form:
    /// `a^{-3(1 + w0 + wa)} exp(-3 wa (1 - a))`.
    pub fn cpl_factor(&self, a: f64) -> f64 {
        a.powf(-3.0 * (1.0 + self.w0 + self.wa)) * (-3.0 * self.wa * (1.0 - a)).exp()
    }
    /// The CPL equation of state `w(a) = w0 + wa (1 - a)`.
    pub fn cpl_w(&self, a: f64) -> f64 {
        self.w0 + self.wa * (1.0 - a)
    }
    /// `H^2` of the CPL background (`H0 = 1`).
    pub fn cpl_h2(&self, a: f64) -> f64 {
        self.om * a.powi(-3) + self.or * a.powi(-4) + self.ode0() * self.cpl_factor(a)
    }
}

// ------------------------------------------------------------------ Model A: fableScalar, self-consistent FLRW

pub struct ScalarFlrw {
    pub bg: Background,
    pub pot: ScalarPotential,
}

impl ScalarFlrw {
    /// `H^2 = (rho_m + rho_r + rho_phi) / 3` with `rho_m = 3 om e^{-3N}` etc.
    pub fn h2(&self, n: f64, phi: f64, phidot: f64) -> f64 {
        let rho_m = 3.0 * self.bg.om * (-3.0 * n).exp();
        let rho_r = 3.0 * self.bg.or * (-4.0 * n).exp();
        let rho_phi = 0.5 * phidot * phidot + self.pot.v(phi);
        (rho_m + rho_r + rho_phi) / 3.0
    }
}

/// state y = (phi, phidot, t);  dphi/dN = phidot/H,  dphidot/dN = -3 phidot - V'(phi)/H,  dt/dN = 1/H
pub fn rhs_scalar_flrw(n: f64, y: &N_Vector, ydot: &N_Vector, ud: &mut Option<Box<dyn Any>>) -> i32 {
    let m = match ud.as_ref().and_then(|b| b.downcast_ref::<ScalarFlrw>()) {
        Some(m) => m,
        None => return -1,
    };
    let yv = N_VGetArrayPointer(y).expect("y");
    let (phi, phidot) = (yv[0], yv[1]);
    let h2 = m.h2(n, phi, phidot);
    if !(h2 > 0.0) || !h2.is_finite() {
        return 1; // recoverable: let CVODE shrink the step
    }
    let h = h2.sqrt();
    let mut yd = N_VGetArrayPointer(ydot).expect("ydot");
    yd[0] = phidot / h;
    yd[1] = -3.0 * phidot - m.pot.dv(phi) / h;
    yd[2] = 1.0 / h;
    0
}

// ------------------------------------------------------------------ Model A': fableScalar as a test field on the CPL background

pub struct ScalarCpl {
    pub bg: Background,
    pub pot: ScalarPotential,
}

/// state y = (phi, phidot, t) with H from the CPL background (the field does not source H)
pub fn rhs_scalar_cpl(n: f64, y: &N_Vector, ydot: &N_Vector, ud: &mut Option<Box<dyn Any>>) -> i32 {
    let m = match ud.as_ref().and_then(|b| b.downcast_ref::<ScalarCpl>()) {
        Some(m) => m,
        None => return -1,
    };
    let yv = N_VGetArrayPointer(y).expect("y");
    let (phi, phidot) = (yv[0], yv[1]);
    let h2 = m.bg.cpl_h2(n.exp());
    if !(h2 > 0.0) || !h2.is_finite() {
        return 1;
    }
    let h = h2.sqrt();
    let mut yd = N_VGetArrayPointer(ydot).expect("ydot");
    yd[0] = phidot / h;
    yd[1] = -3.0 * phidot - m.pot.dv(phi) / h;
    yd[2] = 1.0 / h;
    0
}

// ------------------------------------------------------------------ Model B: fable, self-consistent FLRW

pub struct SpinorFlrw {
    pub bg: Background,
    pub pot: SpinorPotential,
}

impl SpinorFlrw {
    pub fn h2(&self, n: f64, s: f64) -> f64 {
        let rho_m = 3.0 * self.bg.om * (-3.0 * n).exp();
        let rho_r = 3.0 * self.bg.or * (-4.0 * n).exp();
        (rho_m + rho_r + self.pot.v(s)) / 3.0
    }
}

/// state y = (s, t);  ds/dN = -3 s  (exact: d(a^3 s)/dt = 0),  dt/dN = 1/H
pub fn rhs_spinor_flrw(n: f64, y: &N_Vector, ydot: &N_Vector, ud: &mut Option<Box<dyn Any>>) -> i32 {
    let m = match ud.as_ref().and_then(|b| b.downcast_ref::<SpinorFlrw>()) {
        Some(m) => m,
        None => return -1,
    };
    let yv = N_VGetArrayPointer(y).expect("y");
    let s = yv[0];
    let h2 = m.h2(n, s);
    if !(h2 > 0.0) || !h2.is_finite() {
        return 1;
    }
    let h = h2.sqrt();
    let mut yd = N_VGetArrayPointer(ydot).expect("ydot");
    yd[0] = -3.0 * s;
    yd[1] = 1.0 / h;
    0
}

// ------------------------------------------------------------------ Model C: fableScalar on the pre-universe, phi = phi(x4)

pub struct ScalarPre {
    pub pot: ScalarPotential,
}

/// state y = (phi, phidot);  phi'' = -V'(phi): no Hubble friction, because Sqrt[det g] = Sec[6 H x0]
/// does not depend on x4 (the observed sheet's expansion and the second sheet's contraction cancel).
pub fn rhs_scalar_pre(_x4: f64, y: &N_Vector, ydot: &N_Vector, ud: &mut Option<Box<dyn Any>>) -> i32 {
    let m = match ud.as_ref().and_then(|b| b.downcast_ref::<ScalarPre>()) {
        Some(m) => m,
        None => return -1,
    };
    let yv = N_VGetArrayPointer(y).expect("y");
    let (phi, phidot) = (yv[0], yv[1]);
    let mut yd = N_VGetArrayPointer(ydot).expect("ydot");
    yd[0] = phidot;
    yd[1] = -m.pot.dv(phi);
    0
}

// ------------------------------------------------------------------ Model D: fableScalar on the pre-universe with an x0 profile (method of lines)

/// Grid in the hidden coordinate x0, on `[x0min, x0max]` inside `(0, pi/12)` (H = 1).
pub struct ScalarPreX0 {
    pub pot: ScalarPotential,
    pub x0: Vec<f64>,
    /// `Sec[6 x0] Cot[6 x0]^2` at the half-points x0_{j+1/2}, j = 0..n-2  (the flux coefficient)
    pub coef_half: Vec<f64>,
    /// `Cos[6 x0_j]`  (the 1/Sqrt[g] factor of the divergence)
    pub cos_j: Vec<f64>,
    /// `Sec[6 x0_j]`  (the measure Sqrt[det g] used for sheet averages)
    pub sec_j: Vec<f64>,
    pub h: f64,
}

impl ScalarPreX0 {
    pub fn new(pot: ScalarPotential, x0min: f64, x0max: f64, n: usize) -> Result<Self, String> {
        if n < 3 {
            return Err("the x0 grid needs at least 3 points".into());
        }
        if !(x0min > 0.0 && x0max < std::f64::consts::PI / 12.0 && x0min < x0max) {
            return Err(format!("the x0 grid must lie inside (0, pi/12) = (0, {:.6}); got [{x0min}, {x0max}]", std::f64::consts::PI / 12.0));
        }
        let h = (x0max - x0min) / ((n - 1) as f64);
        let x0: Vec<f64> = (0..n).map(|j| x0min + h * j as f64).collect();
        let coef = |x: f64| {
            let c = (6.0 * x).cos();
            let s = (6.0 * x).sin();
            (1.0 / c) * (c / s) * (c / s)
        };
        let coef_half = (0..n - 1).map(|j| coef(x0min + h * (j as f64 + 0.5))).collect();
        let cos_j = x0.iter().map(|&x| (6.0 * x).cos()).collect();
        let sec_j = x0.iter().map(|&x| 1.0 / (6.0 * x).cos()).collect();
        Ok(ScalarPreX0 { pot, x0, coef_half, cos_j, sec_j, h })
    }

    pub fn n(&self) -> usize {
        self.x0.len()
    }

    /// `G0_j = (1/2) Cot[6 x0_j]^2 (d_0 phi)_j^2`, with a centred derivative (one-sided at the ends).
    pub fn g0(&self, phi: &[f64]) -> Vec<f64> {
        let n = self.n();
        (0..n)
            .map(|j| {
                let d = if j == 0 {
                    (phi[1] - phi[0]) / self.h
                } else if j == n - 1 {
                    (phi[n - 1] - phi[n - 2]) / self.h
                } else {
                    (phi[j + 1] - phi[j - 1]) / (2.0 * self.h)
                };
                let cot = self.cos_j[j] / (6.0 * self.x0[j]).sin();
                0.5 * cot * cot * d * d
            })
            .collect()
    }
}

/// state y = (phi_0..phi_{n-1}, phidot_0..phidot_{n-1});
/// phi''_j = Cos[6x0_j] (F_{j+1/2} - F_{j-1/2})/h - V'(phi_j),  F_{j+1/2} = coef_{j+1/2} (phi_{j+1} - phi_j)/h,
/// Neumann ends (F = 0 at both boundaries).
pub fn rhs_scalar_pre_x0(_x4: f64, y: &N_Vector, ydot: &N_Vector, ud: &mut Option<Box<dyn Any>>) -> i32 {
    let m = match ud.as_ref().and_then(|b| b.downcast_ref::<ScalarPreX0>()) {
        Some(m) => m,
        None => return -1,
    };
    let n = m.n();
    let yv = N_VGetArrayPointer(y).expect("y");
    let mut yd = N_VGetArrayPointer(ydot).expect("ydot");
    let (phi, phidot) = yv.split_at(n);
    for j in 0..n {
        let f_plus = if j + 1 < n { m.coef_half[j] * (phi[j + 1] - phi[j]) / m.h } else { 0.0 };
        let f_minus = if j > 0 { m.coef_half[j - 1] * (phi[j] - phi[j - 1]) / m.h } else { 0.0 };
        yd[j] = phidot[j];
        yd[n + j] = m.cos_j[j] * (f_plus - f_minus) / m.h - m.pot.dv(phi[j]);
    }
    0
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn cpl_closed_form_matches_the_integral() {
        // rho_DE(a)/rho_DE(1) = exp( 3 int_a^1 (1 + w(a'))/a' da' )
        let bg = Background { om: 0.3, or: 8.4e-5, w0: -0.861, wa: -0.60 };
        for &a in &[0.1, 0.37, 0.8] {
            let m = 20000;
            let mut acc = 0.0;
            for k in 0..m {
                let a1 = a + (1.0 - a) * (k as f64 + 0.5) / m as f64;
                acc += (1.0 + bg.cpl_w(a1)) / a1;
            }
            acc *= (1.0 - a) / m as f64;
            let num = (3.0 * acc).exp();
            let cf = bg.cpl_factor(a);
            assert!((num - cf).abs() < 1e-6 * cf, "a={a}: {num} vs {cf}");
        }
        assert!((bg.cpl_h2(1.0) - 1.0).abs() < 1e-14);
    }

    #[test]
    fn rho_plus_p_is_twice_the_kinetic_energy() {
        // fableScalar on the observed sheet: rho = KE + PE + G0 - G5, P = KE - PE - G0 + G5
        let mut seed = 12345u64;
        let mut rnd = || {
            seed = seed.wrapping_mul(6364136223846793005).wrapping_add(1442695040888963407);
            ((seed >> 11) as f64) / ((1u64 << 53) as f64)
        };
        for _ in 0..1000 {
            let (ke, pe, g0, g5) = (rnd(), rnd(), rnd(), rnd());
            let rho = ke + pe + g0 - g5;
            let p = ke - pe - g0 + g5;
            assert!((rho + p - 2.0 * ke).abs() < 1e-15);
        }
    }

    #[test]
    fn friedmann_closure_today() {
        // with rho_crit = 3 and Omega_field = 1 - om - or, H(N = 0) = 1 exactly, for both fields
        let bg = Background { om: 0.3, or: 8.4e-5, w0: -0.861, wa: -0.60 };
        let sc = ScalarFlrw { bg, pot: ScalarPotential::Const { v0: 3.0 * bg.ode0() } };
        assert!((sc.h2(0.0, 0.0, 0.0) - 1.0).abs() < 1e-14);
        let sp = SpinorFlrw { bg, pot: SpinorPotential::Mass { m: 3.0 * bg.ode0() } };
        assert!((sp.h2(0.0, 1.0) - 1.0).abs() < 1e-14);
        // and the matter fraction today is om
        assert!((3.0 * bg.om / (3.0 * sc.h2(0.0, 0.0, 0.0)) - bg.om).abs() < 1e-14);
    }

    #[test]
    fn x0_grid_rejects_the_singular_ends() {
        let pot = ScalarPotential::Quadratic { m: 1.0 };
        assert!(ScalarPreX0::new(pot.clone(), 0.0, 0.2, 10).is_err());
        assert!(ScalarPreX0::new(pot.clone(), 0.05, 0.3, 10).is_err());
        assert!(ScalarPreX0::new(pot, 0.05, 0.2, 10).is_ok());
    }
}
