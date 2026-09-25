//! Physical constants and the unit system of fable_fermion.
//!
//! Natural units `hbar = c = 1` (and `k_B = 1` for temperatures).  Every number the solver
//! integrates is dimensionless:
//!
//! * time in units of `1/H0` (so `H0 = 1`), with `H0 = 100 h km/s/Mpc`, `h = 0.674`;
//! * energy densities in units of the critical density today, `rho_c0 = 3 H0^2 M_pl^2`
//!   (`M_pl` the REDUCED Planck mass, `M_pl^2 = 1/(8 pi G)`), so that `8 pi G rho = 3 H0^2 rho_hat`
//!   and the Friedmann constraint reads `H^2 = rho_hat` (H in units of H0);
//! * masses, momenta and the Fermi momentum in units of `E_c := rho_c0^(1/4)`
//!   (`E_c = 2.46e-3 eV` for h = 0.674; computed below, never hard-coded);
//! * number densities and the scalar density `sigma = <chibar chi>` in units of `E_c^3 = rho_c0^(3/4)`;
//! * the potential W(sigma) in units of `E_c^4 = rho_c0`.
//!
//! Conversion from eV:  `m_hat = m[eV] / E_c[eV]`,  `kF_hat = kF[eV] / E_c[eV]`,
//! `sigma_hat = sigma[eV^3] / E_c^3`,  `W_hat = W[eV^4] / E_c^4`.  With these, a Fermi gas of
//! mass `m_hat` and Fermi momentum `kF_hat` has energy density `eps_hat` directly in units of
//! rho_c0, which is what the dimensionless Friedmann equation needs.

use std::f64::consts::PI;

/// hbar in eV s, derived from HBAR_J_S / EV_J so that H0 in eV and the reduced Planck mass use one and
/// the same CODATA 2018 hbar (the truncated 6.582119569e-16 differed from HBAR_J_S/EV_J by 6.1e-10 and
/// shifted E_c by 2.7e-10; the Mathematica reference make_reference_fermion.wls uses hbarJs/eVJ as well).
pub const HBAR_EV_S: f64 = HBAR_J_S / EV_J;
/// hbar in J s: the CODATA 2018 value 1.054571817...e-34, TRUNCATED to 10 significant digits.
/// NOT exact: h = 6.62607015e-34 J s is exact in the 2019 SI, but hbar = h/(2 pi) is irrational
/// and has no finite decimal expansion (h/(2 pi) = 1.054571817646156...e-34; the truncated value
/// is a relative 6.1e-10 below it).  The value is kept as it is: HBAR_EV_S = HBAR_J_S/EV_J, M_pl
/// and hence E_c = 2.46261317732986325e-3 eV and Omega_r0 = 9.20960546728882807e-5 are computed
/// from it, and the Mathematica reference make_reference_fermion.wls uses the same truncated
/// hbarJs = 1054571817/10^43.
pub const HBAR_J_S: f64 = 1.054_571_817e-34;
/// speed of light in m/s (exact).
pub const C_M_S: f64 = 299_792_458.0;
/// 1 eV in J (exact).
pub const EV_J: f64 = 1.602_176_634e-19;
/// Newton's constant (CODATA 2018), m^3 kg^-1 s^-2.
pub const G_SI: f64 = 6.674_30e-11;
/// Boltzmann's constant in eV/K: CODATA 2018, TRUNCATED to 10 significant digits.  k_B =
/// 1.380649e-23 J/K and e are exact in the 2019 SI, but their ratio 8.617333262145...e-5 is not a
/// finite decimal of this length (the truncation is a relative 1.7e-11; make_reference_fermion.wls
/// uses the exact ratio).  Kept as it is: Omega_r0 = 9.20960546728882807e-5 is computed from it.
pub const K_B_EV_K: f64 = 8.617_333_262e-5;
/// 1 Mpc in m: 1 pc = 648000/pi au, 1 au = 149 597 870 700 m (IAU 2012/2015).
pub const MPC_M: f64 = 648_000.0 / PI * 149_597_870_700.0 * 1.0e6;
/// Julian year in s.
pub const YEAR_S: f64 = 365.25 * 86_400.0;
/// The reduced Hubble constant used throughout.
pub const H_LITTLE: f64 = 0.674;
/// CMB temperature today, K (Fixsen 2009).
pub const T_CMB_K: f64 = 2.7255;
/// Effective number of massless neutrino species of the standard model.
pub const N_EFF_STD: f64 = 3.046;
/// Physical baryon density omega_b = Omega_b0 h^2 (Planck 2018); the design review (E11)
/// replaced the design's Omega_b0 = 0.0493 by omega_b/h^2 = 0.0492.
pub const OMEGA_B_H2: f64 = 0.02237;
/// Number of fable states per spatial momentum (design A.4: 8 particle states per momentum).
pub const G_FABLE: f64 = 8.0;
/// Redshift of recombination (photon decoupling) used for the N_eff report.
pub const Z_RECOMBINATION: f64 = 1090.0;
/// The temperature (eV) that defines "BBN" in the report: T = 1 MeV (neutrino decoupling).
pub const T_BBN_EV: f64 = 1.0e6;

/// Every derived number of the unit system, computed from the constants above.
#[derive(Clone, Copy, Debug)]
pub struct Units {
    pub h: f64,
    /// H0 in 1/s
    pub h0_per_s: f64,
    /// H0 in 1/yr
    pub h0_per_yr: f64,
    /// H0 in eV (hbar H0)
    pub h0_ev: f64,
    /// reduced Planck mass sqrt(hbar c / (8 pi G)) in eV
    pub mpl_ev: f64,
    /// rho_c0 = 3 H0^2 M_pl^2 in eV^4
    pub rho_c0_ev4: f64,
    /// E_c = rho_c0^(1/4) in eV: the unit of mass and momentum
    pub e_c_ev: f64,
    /// photon temperature today, eV
    pub t_gamma0_ev: f64,
    /// neutrino temperature today (4/11)^(1/3) T_gamma0, eV
    pub t_nu0_ev: f64,
    /// Omega_gamma today
    pub omega_gamma0: f64,
    /// Omega of ONE massless neutrino species (nu + nubar, 2 helicity states) today:
    /// (7/8) (4/11)^(4/3) Omega_gamma0
    pub omega_nu1_0: f64,
    /// Omega_r0 = Omega_gamma0 (1 + N_eff (7/8)(4/11)^(4/3))
    pub omega_r0: f64,
    pub omega_b0: f64,
    /// scale factor at T = 1 MeV: a_BBN = T_nu0 / 1 MeV (T_nu scales exactly as 1/a after
    /// neutrino decoupling, which is where T = 1 MeV lies)
    pub a_bbn: f64,
    /// scale factor at recombination, 1/(1 + 1090)
    pub a_rec: f64,
}

impl Units {
    pub fn new() -> Self {
        let h = H_LITTLE;
        let h0_per_s = 100.0 * h * 1.0e3 / MPC_M;
        let h0_ev = HBAR_EV_S * h0_per_s;
        // M_pl c^2 = sqrt(hbar c^5 / (8 pi G)) in J -> eV
        let mpl_ev = (HBAR_J_S * C_M_S.powi(5) / (8.0 * PI * G_SI)).sqrt() / EV_J;
        let rho_c0_ev4 = 3.0 * h0_ev * h0_ev * mpl_ev * mpl_ev;
        let e_c_ev = rho_c0_ev4.powf(0.25);
        let t_gamma0_ev = K_B_EV_K * T_CMB_K;
        let t_nu0_ev = (4.0f64 / 11.0).powf(1.0 / 3.0) * t_gamma0_ev;
        let rho_gamma0 = PI * PI / 15.0 * t_gamma0_ev.powi(4);
        let omega_gamma0 = rho_gamma0 / rho_c0_ev4;
        let nu_factor = 7.0 / 8.0 * (4.0f64 / 11.0).powf(4.0 / 3.0);
        let omega_nu1_0 = nu_factor * omega_gamma0;
        let omega_r0 = omega_gamma0 * (1.0 + N_EFF_STD * nu_factor);
        Units {
            h,
            h0_per_s,
            h0_per_yr: h0_per_s * YEAR_S,
            h0_ev,
            mpl_ev,
            rho_c0_ev4,
            e_c_ev,
            t_gamma0_ev,
            t_nu0_ev,
            omega_gamma0,
            omega_nu1_0,
            omega_r0,
            omega_b0: OMEGA_B_H2 / (h * h),
            a_bbn: t_nu0_ev / T_BBN_EV,
            a_rec: 1.0 / (1.0 + Z_RECOMBINATION),
        }
    }

    /// A mass/momentum in eV converted to the solver's unit E_c.
    pub fn from_ev(&self, x_ev: f64) -> f64 {
        x_ev / self.e_c_ev
    }

    /// A mass/momentum in the solver's unit converted to eV.
    pub fn to_ev(&self, x: f64) -> f64 {
        x * self.e_c_ev
    }

    /// The human-readable table printed by `fable_fermion --constants`.
    pub fn report(&self) -> String {
        let mut s = String::new();
        s.push_str("# fable_fermion unit system (hbar = c = k_B = 1)\n");
        s.push_str(&format!("h                     = {}\n", self.h));
        s.push_str(&format!("H0                    = {:.10e} 1/s = {:.10e} 1/yr = {:.10e} eV\n", self.h0_per_s, self.h0_per_yr, self.h0_ev));
        s.push_str(&format!("1/H0                  = {:.10e} yr\n", 1.0 / self.h0_per_yr));
        s.push_str(&format!("M_pl (reduced, from G)= {:.10e} eV = {:.10e} GeV\n", self.mpl_ev, self.mpl_ev * 1e-9));
        s.push_str(&format!("rho_c0 = 3 H0^2 M_pl^2= {:.10e} eV^4\n", self.rho_c0_ev4));
        s.push_str(&format!("E_c = rho_c0^(1/4)    = {:.10e} eV   (unit of m, kF; sigma, n in E_c^3; W, rho in E_c^4 = rho_c0)\n", self.e_c_ev));
        s.push_str(&format!("1 eV                  = {:.10e} E_c\n", 1.0 / self.e_c_ev));
        s.push_str(&format!("T_CMB                 = {} K = {:.10e} eV;  T_nu0 = {:.10e} eV\n", T_CMB_K, self.t_gamma0_ev, self.t_nu0_ev));
        s.push_str(&format!("Omega_gamma0          = {:.10e}   (Omega_gamma0 h^2 = {:.10e})\n", self.omega_gamma0, self.omega_gamma0 * self.h * self.h));
        s.push_str(&format!("Omega_nu(1 species)0  = {:.10e}\n", self.omega_nu1_0));
        s.push_str(&format!("Omega_r0 (N_eff={})= {:.10e}   (Omega_r0 h^2 = {:.10e})\n", N_EFF_STD, self.omega_r0, self.omega_r0 * self.h * self.h));
        s.push_str(&format!("Omega_b0 = {}/h^2 = {:.10e}\n", OMEGA_B_H2, self.omega_b0));
        s.push_str("(g_*(T) is not followed: radiation is Omega_r0 A^-4 at all times, which misstates rho_r A^4 by up to a factor ~0.39 before e+e- annihilation and the QCD transition)\n");
        s.push_str(&format!("g (fable states per momentum) = {}\n", G_FABLE));
        s.push_str(&format!("a_BBN (T = 1 MeV)     = {:.10e}   (= T_nu0 / 1 MeV)\n", self.a_bbn));
        s.push_str(&format!("a_rec (z = {})      = {:.10e}\n", Z_RECOMBINATION, self.a_rec));
        s
    }
}

impl Default for Units {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn unit_system_matches_the_standard_values() {
        let u = Units::new();
        // reduced Planck mass 2.435e18 GeV
        assert!((u.mpl_ev / 2.435e27 - 1.0).abs() < 1e-3, "M_pl = {}", u.mpl_ev);
        // H0 for h = 0.674: 2.1332e-33 h eV
        assert!((u.h0_ev / (2.1332e-33 * 0.674) - 1.0).abs() < 1e-4, "H0 = {}", u.h0_ev);
        // rho_c0^(1/4) = 2.46e-3 eV
        assert!((u.e_c_ev / 2.463e-3 - 1.0).abs() < 2e-3, "E_c = {}", u.e_c_ev);
        // Omega_gamma h^2 = 2.473e-5 for T = 2.7255 K
        assert!((u.omega_gamma0 * u.h * u.h / 2.473e-5 - 1.0).abs() < 1e-3);
        // 1/H0 = 14.5 Gyr for h = 0.674
        assert!(((1.0 / u.h0_per_yr) / 1.4507e10 - 1.0).abs() < 1e-3, "1/H0 = {} yr", 1.0 / u.h0_per_yr);
        // design review E11: Omega_r0 = 9.2096e-5 (h = 0.674, T0 = 2.7255 K, N_eff = 3.046), E_c = 2.4626e-3 eV
        assert!((u.omega_r0 - 9.2096e-5).abs() < 1e-8, "Omega_r0 = {:.6e}", u.omega_r0);
        assert!((u.e_c_ev - 2.4626e-3).abs() < 1e-7, "E_c = {:.6e}", u.e_c_ev);
        assert!((u.omega_b0 - 0.0492).abs() < 1e-4);
        // round trip
        assert!((u.to_ev(u.from_ev(3.7)) - 3.7).abs() < 1e-15);
    }
}
