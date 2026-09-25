//! fable_fermion -- the quantized fermion fable (complex 16-spinor, g = 8 states per momentum,
//! Kohn-Sham mean field) as the source of the 8-dimensional primordial gravitational field in its
//! asymptotic (Bianchi-I) region, integrated with the vendored pure-Rust SUNDIALS 7.8.0 CVODE of
//! the rustSolveIt repositories.
//!
//! Modules: `constants` (unit system), `numerics` (Brent, Gauss-Kronrod), `potentials` (W(sigma)
//! and the gap-bracket proofs), `kohn_sham` (Fermi-sea integrals, mean field, gap equation),
//! `models` (fable8d / fable4d right-hand sides and output rows), `run` (normalization/shooting,
//! integration, diagnostics), `cvode_driver`.

pub mod constants;
pub mod cvode_driver;
pub mod kohn_sham;
pub mod models;
pub mod numerics;
pub mod potentials;
pub mod run;

pub const VERSION: &str = "fable_fermion 0.1.0, sundials_rs 7.8.0 (pure Rust), CVODE BDF";
