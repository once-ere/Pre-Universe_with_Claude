//! The mean-field potentials W(sigma) of fermion fable (canonical normalization, design A.6(c)):
//! `W(sigma) := V(H sigma)`, `m_eff = W'(sigma)`, all in the solver's units (sigma in
//! `rho_c0^(3/4)`, W in `rho_c0`, masses in `E_c = rho_c0^(1/4)`; see constants.rs for eV).
//!
//! | name        | W(sigma)                             | W'(sigma)                               |
//! |-------------|--------------------------------------|-----------------------------------------|
//! | mass        | m0 sigma                             | m0                                      |
//! | lambda-mass | V0 + m0 sigma                        | m0                                      |
//! | power       | m0 sigma + lam sigma^nu  (sigma >= 0) | m0 + nu lam sigma^(nu-1)               |
//! | expdamp     | V0 + m0 sigma e^(-sigma/s1)          | m0 (1 - sigma/s1) e^(-sigma/s1)         |
//! | lorentz     | V0 + m0 sigma / (1 + (sigma/s1)^2)   | m0 (1 - u)/(1 + u)^2, u = (sigma/s1)^2  |
//! | quadratic   | V0 + m0 sigma + (lam/2) sigma^2      | m0 + lam sigma                          |
//!
//! Each potential also states WHERE the roots of the gap equation `m = W'(sigma_KS(m, kF)/v)` can
//! lie and whether the root is provably unique there (`gap_plan`); the proofs are in the comments
//! of `gap_plan` and are summarized on stderr by the command-line tool.

/// The KS scalar-density function sigma_KS(m) at fixed kF is odd, strictly increasing, and maps
/// the real line onto (-n, n); its slope chi = d sigma/d m is largest at m = 0,
/// chi(0) = g kF^2/(4 pi^2).  Every bracket argument below uses only these facts.
#[derive(Clone, Debug, PartialEq)]
pub enum Potential {
    Mass { m0: f64 },
    LambdaMass { v0: f64, m0: f64 },
    Power { m0: f64, lam: f64, nu: f64 },
    ExpDamp { v0: f64, m0: f64, s1: f64 },
    Lorentz { v0: f64, m0: f64, s1: f64 },
    Quadratic { v0: f64, m0: f64, lam: f64 },
}

/// Where to look for the roots of the gap equation.
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum GapPlan {
    /// the root is known in closed form (W' constant)
    Exact(f64),
    /// exactly one root, in [lo, hi] (the proof is in `gap_plan`)
    Unique { lo: f64, hi: f64 },
    /// possibly several roots, all in [lo, hi]: scan and refine every sign change
    Scan { lo: f64, hi: f64 },
}

impl Potential {
    pub fn name(&self) -> &'static str {
        match self {
            Potential::Mass { .. } => "mass",
            Potential::LambdaMass { .. } => "lambda-mass",
            Potential::Power { .. } => "power",
            Potential::ExpDamp { .. } => "expdamp",
            Potential::Lorentz { .. } => "lorentz",
            Potential::Quadratic { .. } => "quadratic",
        }
    }

    /// `true` when W is defined only for sigma >= 0 (the power law with non-integer nu).
    pub fn nonneg_domain(&self) -> bool {
        matches!(self, Potential::Power { .. })
    }

    pub fn w(&self, s: f64) -> f64 {
        match *self {
            Potential::Mass { m0 } => m0 * s,
            Potential::LambdaMass { v0, m0 } => v0 + m0 * s,
            Potential::Power { m0, lam, nu } => m0 * s + lam * s.powf(nu),
            Potential::ExpDamp { v0, m0, s1 } => v0 + m0 * s * (-s / s1).exp(),
            Potential::Lorentz { v0, m0, s1 } => {
                let r = s / s1;
                v0 + m0 * s / (1.0 + r * r)
            }
            Potential::Quadratic { v0, m0, lam } => v0 + m0 * s + 0.5 * lam * s * s,
        }
    }

    pub fn dw(&self, s: f64) -> f64 {
        match *self {
            Potential::Mass { m0 } => m0,
            Potential::LambdaMass { m0, .. } => m0,
            Potential::Power { m0, lam, nu } => m0 + nu * lam * s.powf(nu - 1.0),
            Potential::ExpDamp { m0, s1, .. } => m0 * (1.0 - s / s1) * (-s / s1).exp(),
            Potential::Lorentz { m0, s1, .. } => {
                let u = (s / s1) * (s / s1);
                m0 * (1.0 - u) / ((1.0 + u) * (1.0 + u))
            }
            Potential::Quadratic { m0, lam, .. } => m0 + lam * s,
        }
    }

    pub fn d2w(&self, s: f64) -> f64 {
        match *self {
            Potential::Mass { .. } | Potential::LambdaMass { .. } => 0.0,
            Potential::Power { lam, nu, .. } => nu * (nu - 1.0) * lam * s.powf(nu - 2.0),
            Potential::ExpDamp { m0, s1, .. } => (m0 / s1) * (-s / s1).exp() * (s / s1 - 2.0),
            Potential::Lorentz { m0, s1, .. } => {
                let u = (s / s1) * (s / s1);
                m0 * (u - 3.0) / (1.0 + u).powi(3) * 2.0 * s / (s1 * s1)
            }
            Potential::Quadratic { lam, .. } => lam,
        }
    }

    /// The condensate energy density U = W - sigma W' (the mean-field part of rho; P_hid = -U).
    pub fn u(&self, s: f64) -> f64 {
        self.w(s) - s * self.dw(s)
    }

    /// Where the roots of `f(m) = m - W'(sigma_KS(m, kF)/v)` lie.  `n8 = n/v` bounds
    /// `|sigma_KS/v| < n8`; `chi0 = g kF^2/(4 pi^2)` bounds the slope of sigma_KS.
    pub fn gap_plan(&self, n8: f64, chi0_over_v: f64) -> GapPlan {
        match *self {
            // W' = m0: the gap equation is m = m0.
            Potential::Mass { m0 } | Potential::LambdaMass { m0, .. } => GapPlan::Exact(m0),

            Potential::Power { m0, lam, nu } => {
                if lam > 0.0 && nu > 0.0 && nu < 1.0 {
                    // sigma^nu needs sigma >= 0, hence m > 0.  For lam > 0, 0 < nu < 1 the map
                    // m -> nu lam sigma8(m)^(nu-1) is strictly DECREASING (sigma8 increasing), so
                    // f(m) = m - m0 - nu lam sigma8^(nu-1) is strictly increasing, f(0+) = -inf,
                    // f(inf) = +inf: exactly one root.  Since sigma8 < n8, the root exceeds
                    // m0 + nu lam n8^(nu-1) (used as lo when positive; otherwise lo -> 0+).  The
                    // upper end hi = m0 + nu lam sigma8(lo)^(nu-1) is found by the solver.
                    let lo = m0 + nu * lam * n8.powf(nu - 1.0);
                    GapPlan::Unique { lo: if lo > 0.0 { lo } else { 0.0 }, hi: f64::NAN }
                } else {
                    // no uniqueness argument: scan (0, M] where M bounds W' on (0, n8]
                    let hi = (m0.abs() + (nu * lam).abs() * n8.powf(nu - 1.0)).max(m0.abs()) * 4.0 + 1.0;
                    GapPlan::Scan { lo: 0.0, hi }
                }
            }

            Potential::ExpDamp { m0, s1, .. } => {
                // m0 > 0: a root with m < 0 would need sigma8 < 0 and then W' = m0 (1 - sigma8/s1)
                // e^(-sigma8/s1) > 0: contradiction; m = 0 gives f = -m0 != 0; m > m0 gives f > 0
                // since W' <= m0 for sigma8 >= 0.  On (0, m0] every root has W' = m > 0, i.e.
                // sigma8 < s1 (< 2 s1, where W'' < 0): there f is strictly increasing
                // (sigma8 increasing, W' decreasing), and f > 0 wherever sigma8 >= s1.
                // f(0) = -m0 < 0, f(m0) = m0 (1 - W'(sigma8(m0))/m0) > 0: exactly one root,
                // and it has sigma8 < s1 (the "pinning" of design B.3).  m0 < 0 is the mirror image.
                let _ = s1;
                if m0 > 0.0 {
                    GapPlan::Unique { lo: 0.0, hi: m0 }
                } else if m0 < 0.0 {
                    GapPlan::Unique { lo: m0, hi: 0.0 }
                } else {
                    GapPlan::Exact(0.0)
                }
            }

            Potential::Lorentz { m0, s1, .. } => {
                // positive branch (m0 > 0): a root with m > 0 needs 0 < sigma8 < s1 (W' > 0 there
                // only); on that range W' is decreasing (dW'/du = m0 (u - 3)/(1 + u)^3 < 0 for
                // u < 3), so f is strictly increasing on (0, m0], f(0) = -m0, f(m0) > 0: exactly
                // one positive root.  A negative root needs sigma8 < -s1 (W' < 0 only for
                // |sigma8| > s1), impossible when n8 <= s1; otherwise it can exist (possibly two):
                // scan [min W', max W'] = [-m0/8, m0] (min of (1-u)/(1+u)^2 is -1/8 at u = 3).
                if m0 == 0.0 {
                    GapPlan::Exact(0.0)
                } else if n8 <= s1 {
                    if m0 > 0.0 { GapPlan::Unique { lo: 0.0, hi: m0 } } else { GapPlan::Unique { lo: m0, hi: 0.0 } }
                } else {
                    let (a, b) = if m0 > 0.0 { (-m0 / 8.0, m0) } else { (m0, -m0 / 8.0) };
                    GapPlan::Scan { lo: a, hi: b }
                }
            }

            Potential::Quadratic { m0, lam, .. } => {
                if lam <= 0.0 {
                    // f(m) = m - m0 + |lam| sigma8(m): strictly increasing.  m0 > 0: f(0) = -m0 < 0,
                    // f(m0) = |lam| sigma8(m0) > 0 -> one root in (0, m0]; m0 < 0 mirror; m0 = 0:
                    // the root is m = 0 (sigma8(0) = 0).
                    if m0 > 0.0 {
                        GapPlan::Unique { lo: 0.0, hi: m0 }
                    } else if m0 < 0.0 {
                        GapPlan::Unique { lo: m0, hi: 0.0 }
                    } else {
                        GapPlan::Exact(0.0)
                    }
                } else {
                    // lam > 0: every root lies in [m0 - lam n8, m0 + lam n8] (|sigma8| < n8);
                    // f'(m) = 1 - lam chi/v >= 1 - lam chi0/v, so the root is unique when
                    // lam chi0/v < 1 (weak coupling); otherwise scan.
                    let (lo, hi) = (m0 - lam * n8, m0 + lam * n8);
                    if lam * chi0_over_v < 1.0 {
                        GapPlan::Unique { lo, hi }
                    } else {
                        GapPlan::Scan { lo, hi }
                    }
                }
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn fd(f: &dyn Fn(f64) -> f64, x: f64) -> f64 {
        let h = 1e-5 * x.abs().max(1e-3);
        (f(x + h) - f(x - h)) / (2.0 * h)
    }

    #[test]
    fn derivatives_match_finite_differences() {
        let pots = [
            Potential::Mass { m0: 0.9 },
            Potential::LambdaMass { v0: 2.1, m0: 0.9 },
            Potential::Power { m0: 0.9, lam: 0.4, nu: 0.236 },
            Potential::ExpDamp { v0: 2.1, m0: 0.7, s1: 1.5 },
            Potential::Lorentz { v0: 2.1, m0: 0.7, s1: 1.5 },
            Potential::Quadratic { v0: 0.3, m0: 0.7, lam: -0.4 },
        ];
        for p in pots.iter() {
            for &s in &[0.2, 1.0, 3.0] {
                let n1 = fd(&|x| p.w(x), s);
                assert!((n1 - p.dw(s)).abs() <= 1e-8 * (1.0 + p.dw(s).abs()), "{p:?} W' at {s}");
                let n2 = fd(&|x| p.dw(x), s);
                assert!((n2 - p.d2w(s)).abs() <= 1e-7 * (1.0 + p.d2w(s).abs()), "{p:?} W'' at {s}: {n2} vs {}", p.d2w(s));
                let nu = fd(&|x| p.u(x), s);
                assert!((nu + s * p.d2w(s)).abs() <= 1e-7 * (1.0 + (s * p.d2w(s)).abs()), "{p:?} dU/dsigma = -sigma W''");
            }
        }
    }

    #[test]
    fn signs_that_the_bracket_proofs_use() {
        // expdamp: W' > 0 iff sigma < s1, W'' < 0 for sigma < 2 s1, W' > 0 for all sigma < 0
        let e = Potential::ExpDamp { v0: 0.0, m0: 1.0, s1: 2.0 };
        assert!(e.dw(1.9) > 0.0 && e.dw(2.1) < 0.0 && e.d2w(3.9) < 0.0 && e.d2w(4.1) > 0.0 && e.dw(-5.0) > 0.0);
        // lorentz: min of (1-u)/(1+u)^2 is -1/8 at u = 3
        let l = Potential::Lorentz { v0: 0.0, m0: 1.0, s1: 1.0 };
        let smin = 3f64.sqrt();
        assert!((l.dw(smin) + 0.125).abs() < 1e-15 && l.dw(smin * 1.01) > -0.125 && l.dw(smin * 0.99) > -0.125);
        assert!(l.dw(0.99) > 0.0 && l.dw(1.01) < 0.0 && l.dw(-0.5) > 0.0);
    }
}
