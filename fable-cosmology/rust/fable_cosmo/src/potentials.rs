//! The self-interaction potentials of the two fields.
//!
//! `ScalarPotential` is `V(phi)` for fableScalar; `SpinorPotential` is `V(s)` for fable, where
//! `s = Psi^T sigma16 Psi` is the scalar bilinear.  Every potential exposes its value and its
//! first derivative; the unit tests check each derivative against a central finite difference.

use std::collections::HashMap;

/// Look a parameter up, with a default.
pub fn param(p: &HashMap<String, f64>, key: &str, default: f64) -> f64 {
    p.get(key).copied().unwrap_or(default)
}

#[derive(Clone, Debug)]
pub enum ScalarPotential {
    /// `V0 exp(-lambda phi)`  (freezing / scaling)
    Exp { v0: f64, lambda: f64 },
    /// `V0 phi^(-alpha)`  (Ratra-Peebles inverse power, freezing)
    InvPower { v0: f64, alpha: f64 },
    /// `V0 (1 + cos(phi/f))`  (pseudo-Nambu-Goldstone boson, thawing)
    Pngb { v0: f64, f: f64 },
    /// `(1/2) m^2 phi^2`  (oscillating; <w> = 0)
    Quadratic { m: f64 },
    /// `V0 (1 - phi^2/mu^2)`  (hilltop, thawing; only used where V > 0)
    Hilltop { v0: f64, mu: f64 },
    /// `V0`  (a cosmological constant; the control case, w = -1 exactly)
    Const { v0: f64 },
    /// `(1/4) lambda phi^4`  (oscillating; virial average <w> = 1/3, radiation-like)
    Quartic { lambda: f64 },
}

impl ScalarPotential {
    pub fn from_name(name: &str, p: &HashMap<String, f64>) -> Result<Self, String> {
        Ok(match name {
            "exp" => ScalarPotential::Exp { v0: param(p, "v0", 1.0), lambda: param(p, "lambda", 1.0) },
            "invpower" => ScalarPotential::InvPower { v0: param(p, "v0", 1.0), alpha: param(p, "alpha", 1.0) },
            "pngb" => ScalarPotential::Pngb { v0: param(p, "v0", 1.0), f: param(p, "f", 1.0) },
            "quadratic" => ScalarPotential::Quadratic { m: param(p, "m", 1.0) },
            "hilltop" => ScalarPotential::Hilltop { v0: param(p, "v0", 1.0), mu: param(p, "mu", 1.0) },
            "const" => ScalarPotential::Const { v0: param(p, "v0", 1.0) },
            "quartic" => ScalarPotential::Quartic { lambda: param(p, "lambda", 1.0) },
            other => return Err(format!("unknown scalar potential '{other}' (exp | invpower | pngb | quadratic | hilltop | const | quartic)")),
        })
    }

    /// Multiply the overall scale by `k` (used by the normalisation of Omega_phi today).
    pub fn scaled(&self, k: f64) -> Self {
        match *self {
            ScalarPotential::Exp { v0, lambda } => ScalarPotential::Exp { v0: k * v0, lambda },
            ScalarPotential::InvPower { v0, alpha } => ScalarPotential::InvPower { v0: k * v0, alpha },
            ScalarPotential::Pngb { v0, f } => ScalarPotential::Pngb { v0: k * v0, f },
            ScalarPotential::Quadratic { m } => ScalarPotential::Quadratic { m: k.sqrt() * m },
            ScalarPotential::Hilltop { v0, mu } => ScalarPotential::Hilltop { v0: k * v0, mu },
            ScalarPotential::Const { v0 } => ScalarPotential::Const { v0: k * v0 },
            ScalarPotential::Quartic { lambda } => ScalarPotential::Quartic { lambda: k * lambda },
        }
    }

    pub fn v(&self, phi: f64) -> f64 {
        match *self {
            ScalarPotential::Exp { v0, lambda } => v0 * (-lambda * phi).exp(),
            ScalarPotential::InvPower { v0, alpha } => v0 * phi.powf(-alpha),
            ScalarPotential::Pngb { v0, f } => v0 * (1.0 + (phi / f).cos()),
            ScalarPotential::Quadratic { m } => 0.5 * m * m * phi * phi,
            ScalarPotential::Hilltop { v0, mu } => v0 * (1.0 - phi * phi / (mu * mu)),
            ScalarPotential::Const { v0 } => v0,
            ScalarPotential::Quartic { lambda } => 0.25 * lambda * phi.powi(4),
        }
    }

    pub fn dv(&self, phi: f64) -> f64 {
        match *self {
            ScalarPotential::Exp { v0, lambda } => -lambda * v0 * (-lambda * phi).exp(),
            ScalarPotential::InvPower { v0, alpha } => -alpha * v0 * phi.powf(-alpha - 1.0),
            ScalarPotential::Pngb { v0, f } => -v0 / f * (phi / f).sin(),
            ScalarPotential::Quadratic { m } => m * m * phi,
            ScalarPotential::Hilltop { v0, mu } => -2.0 * v0 * phi / (mu * mu),
            ScalarPotential::Const { .. } => 0.0,
            ScalarPotential::Quartic { lambda } => lambda * phi.powi(3),
        }
    }

    pub fn name(&self) -> &'static str {
        match self {
            ScalarPotential::Exp { .. } => "exp",
            ScalarPotential::InvPower { .. } => "invpower",
            ScalarPotential::Pngb { .. } => "pngb",
            ScalarPotential::Quadratic { .. } => "quadratic",
            ScalarPotential::Hilltop { .. } => "hilltop",
            ScalarPotential::Const { .. } => "const",
            ScalarPotential::Quartic { .. } => "quartic",
        }
    }
}

#[derive(Clone, Debug)]
pub enum SpinorPotential {
    /// `m s`  -- the author's mass term promoted to a potential: dust, w = 0 exactly
    Mass { m: f64 },
    /// `V0 + m s`  -- one field that is dark matter early and a cosmological constant late
    LambdaMass { v0: f64, m: f64 },
    /// `m s + lambda s^n`  -- dust early, w -> n - 1 late
    Power { m: f64, lambda: f64, n: f64 },
    /// `V0 - mu (s - sstar)^2`  -- phantom for s > sstar, crosses w = -1 at s = sstar; valid only where V > 0
    Hilltop { v0: f64, mu: f64, sstar: f64 },
    /// `V0 + m s / (1 + (s/s1)^2)`  -- positive everywhere; phantom for s > s1 (w -> -1 from below as s -> inf),
    /// crosses w = -1 exactly at s = s1, quintessence-like after, w -> -1 from above as s -> 0
    Lorentz { v0: f64, m: f64, s1: f64 },
    /// `V0 + m s exp(-s/s1)`  -- bounded below by V0 > 0; V' changes sign at s = s1, so w crosses -1 there,
    /// phantom for s > s1 and w -> -1 from below as s -> inf
    ExpDamp { v0: f64, m: f64, s1: f64 },
}

impl SpinorPotential {
    pub fn from_name(name: &str, p: &HashMap<String, f64>) -> Result<Self, String> {
        Ok(match name {
            "mass" => SpinorPotential::Mass { m: param(p, "m", 1.0) },
            "lambda-mass" => SpinorPotential::LambdaMass { v0: param(p, "v0", 1.0), m: param(p, "m", 1.0) },
            "power" => SpinorPotential::Power { m: param(p, "m", 1.0), lambda: param(p, "lambda", 1.0), n: param(p, "n", 0.5) },
            "hilltop" => SpinorPotential::Hilltop { v0: param(p, "v0", 1.0), mu: param(p, "mu", 1.0), sstar: param(p, "sstar", 1.5) },
            "lorentz" => SpinorPotential::Lorentz { v0: param(p, "v0", 1.0), m: param(p, "m", 1.0), s1: param(p, "s1", 1.5) },
            "expdamp" => SpinorPotential::ExpDamp { v0: param(p, "v0", 1.0), m: param(p, "m", 1.0), s1: param(p, "s1", 1.5) },
            other => return Err(format!("unknown spinor potential '{other}' (mass | lambda-mass | power | hilltop | lorentz | expdamp)")),
        })
    }

    /// Multiply the overall scale by `k`.  `w(s) = s V'/V - 1` is unchanged by this.
    pub fn scaled(&self, k: f64) -> Self {
        match *self {
            SpinorPotential::Mass { m } => SpinorPotential::Mass { m: k * m },
            SpinorPotential::LambdaMass { v0, m } => SpinorPotential::LambdaMass { v0: k * v0, m: k * m },
            SpinorPotential::Power { m, lambda, n } => SpinorPotential::Power { m: k * m, lambda: k * lambda, n },
            SpinorPotential::Hilltop { v0, mu, sstar } => SpinorPotential::Hilltop { v0: k * v0, mu: k * mu, sstar },
            SpinorPotential::Lorentz { v0, m, s1 } => SpinorPotential::Lorentz { v0: k * v0, m: k * m, s1 },
            SpinorPotential::ExpDamp { v0, m, s1 } => SpinorPotential::ExpDamp { v0: k * v0, m: k * m, s1 },
        }
    }

    pub fn v(&self, s: f64) -> f64 {
        match *self {
            SpinorPotential::Mass { m } => m * s,
            SpinorPotential::LambdaMass { v0, m } => v0 + m * s,
            SpinorPotential::Power { m, lambda, n } => m * s + lambda * s.powf(n),
            SpinorPotential::Hilltop { v0, mu, sstar } => v0 - mu * (s - sstar) * (s - sstar),
            SpinorPotential::Lorentz { v0, m, s1 } => v0 + m * s / (1.0 + (s / s1) * (s / s1)),
            SpinorPotential::ExpDamp { v0, m, s1 } => v0 + m * s * (-s / s1).exp(),
        }
    }

    pub fn dv(&self, s: f64) -> f64 {
        match *self {
            SpinorPotential::Mass { m } => m,
            SpinorPotential::LambdaMass { m, .. } => m,
            SpinorPotential::Power { m, lambda, n } => m + n * lambda * s.powf(n - 1.0),
            SpinorPotential::Hilltop { mu, sstar, .. } => -2.0 * mu * (s - sstar),
            SpinorPotential::Lorentz { m, s1, .. } => { let u = (s / s1) * (s / s1); m * (1.0 - u) / ((1.0 + u) * (1.0 + u)) }
            SpinorPotential::ExpDamp { m, s1, .. } => m * (1.0 - s / s1) * (-s / s1).exp(),
        }
    }

    /// `w_Psi(s) = s V'(s) / V(s) - 1`
    pub fn w(&self, s: f64) -> f64 {
        s * self.dv(s) / self.v(s) - 1.0
    }

    pub fn name(&self) -> &'static str {
        match self {
            SpinorPotential::Mass { .. } => "mass",
            SpinorPotential::LambdaMass { .. } => "lambda-mass",
            SpinorPotential::Power { .. } => "power",
            SpinorPotential::Hilltop { .. } => "hilltop",
            SpinorPotential::Lorentz { .. } => "lorentz",
            SpinorPotential::ExpDamp { .. } => "expdamp",
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn fd(f: &dyn Fn(f64) -> f64, x: f64) -> f64 {
        let h = 1e-6 * x.abs().max(1.0);
        (f(x + h) - f(x - h)) / (2.0 * h)
    }

    #[test]
    fn scalar_derivatives_match_finite_differences() {
        let pots = [
            ScalarPotential::Exp { v0: 0.7, lambda: 1.3 },
            ScalarPotential::InvPower { v0: 0.7, alpha: 0.8 },
            ScalarPotential::Pngb { v0: 0.7, f: 0.9 },
            ScalarPotential::Quadratic { m: 1.7 },
            ScalarPotential::Hilltop { v0: 0.7, mu: 2.5 },
            ScalarPotential::Const { v0: 0.7 },
            ScalarPotential::Quartic { lambda: 0.6 },
        ];
        for p in pots.iter() {
            for &phi in &[0.3, 0.9, 1.7] {
                let num = fd(&|x| p.v(x), phi);
                let ana = p.dv(phi);
                assert!((num - ana).abs() <= 1e-7 * (1.0 + ana.abs()), "{:?} at {phi}: {num} vs {ana}", p);
            }
        }
    }

    #[test]
    fn spinor_derivatives_match_finite_differences_and_w() {
        let pots = [
            SpinorPotential::Mass { m: 0.9 },
            SpinorPotential::LambdaMass { v0: 2.1, m: 0.9 },
            SpinorPotential::Power { m: 0.9, lambda: 0.4, n: 0.5 },
            SpinorPotential::Hilltop { v0: 2.1, mu: 0.3, sstar: 1.5 },
            SpinorPotential::Lorentz { v0: 2.1, m: 0.7, s1: 1.5 },
            SpinorPotential::ExpDamp { v0: 2.1, m: 0.7, s1: 1.5 },
        ];
        for p in pots.iter() {
            for &s in &[0.2, 1.0, 3.0] {
                let num = fd(&|x| p.v(x), s);
                let ana = p.dv(s);
                assert!((num - ana).abs() <= 1e-7 * (1.0 + ana.abs()), "{:?} at {s}: {num} vs {ana}", p);
            }
        }
        // the mass term is dust, exactly
        assert_eq!(SpinorPotential::Mass { m: 0.9 }.w(2.3), 0.0);
        // a power law s^n has w = n - 1
        let pw = SpinorPotential::Power { m: 0.0, lambda: 0.4, n: 0.5 };
        assert!((pw.w(2.3) - (-0.5)).abs() < 1e-14);
        // the hilltop crosses w = -1 exactly at s = sstar
        let h = SpinorPotential::Hilltop { v0: 2.1, mu: 0.3, sstar: 1.5 };
        assert!((h.w(1.5) + 1.0).abs() < 1e-14);
        assert!(h.w(2.0) < -1.0 && h.w(1.0) > -1.0);
        // the Lorentzian crosses w = -1 exactly at s = s1, is phantom before and not after, and is positive everywhere
        let l = SpinorPotential::Lorentz { v0: 2.1, m: 0.7, s1: 1.5 };
        assert!((l.w(1.5) + 1.0).abs() < 1e-14);
        assert!(l.w(4.0) < -1.0 && l.w(0.5) > -1.0 && l.v(1e6) > 0.0 && l.v(1e-6) > 0.0);
        // the damped exponential crosses at s = s1 too, and is bounded below by v0
        let e = SpinorPotential::ExpDamp { v0: 2.1, m: 0.7, s1: 1.5 };
        assert!((e.w(1.5) + 1.0).abs() < 1e-14);
        assert!(e.w(4.0) < -1.0 && e.w(0.5) > -1.0 && e.v(50.0) >= 2.1 && e.v(1e-9) >= 2.1);
        // scaling V by a constant does not change w
        assert!((h.scaled(3.7).w(0.8) - h.w(0.8)).abs() < 1e-14);
    }
}
