//! fable_cosmo -- the fableScalar and fable cosmologies of DESIGN.md, integrated with the
//! vendored pure-Rust SUNDIALS 7.8.0 CVODE of the rustSolveIt repositories.
//!
//!     fable_cosmo <model> [--potential NAME] [--param KEY=VALUE ...] [--n0 X0] [--n1 X1]
//!                 [--points K] [--out FILE.csv] [--no-normalize] [--grid N] [--x0min A] [--x0max B]
//!                 [--profile-out FILE.csv] [--rtol R] [--atol A]
//!     model : scalar-flrw | scalar-cpl | spinor-flrw | scalar-pre | scalar-pre-x0
//!     fable_cosmo --version
//!
//! Every column of every CSV is named in its header line; the integration statistics go to
//! stderr.  Exit code 0 on success, 2 on a usage error, 1 on a solver error.

mod cvode_driver;
mod models;
mod potentials;

use std::collections::HashMap;
use std::io::Write;

use cvode_driver::{integrate, Trajectory};
use models::*;
use potentials::{param, ScalarPotential, SpinorPotential};

const VERSION: &str = "fable_cosmo 0.1.0, sundials_rs 7.8.0 (pure Rust), CVODE BDF";

struct Args {
    model: String,
    potential: Option<String>,
    params: HashMap<String, f64>,
    n0: Option<f64>,
    n1: Option<f64>,
    points: usize,
    out: Option<String>,
    normalize: bool,
    grid: usize,
    x0min: f64,
    x0max: f64,
    profile_out: Option<String>,
    rtol: f64,
    atol: f64,
    method: Option<String>,
}

fn usage() -> ! {
    eprintln!("usage: fable_cosmo <scalar-flrw|scalar-cpl|spinor-flrw|scalar-pre|scalar-pre-x0> [--potential NAME] [--param KEY=VALUE ...] [--n0 X0] [--n1 X1] [--points K] [--out FILE.csv] [--no-normalize] [--grid N] [--x0min A] [--x0max B] [--profile-out FILE.csv] [--rtol R] [--atol A] [--method bdf|adams]\n       fable_cosmo --version");
    std::process::exit(2);
}

fn parse_args() -> Args {
    let argv: Vec<String> = std::env::args().skip(1).collect();
    if argv.is_empty() {
        usage();
    }
    if argv[0] == "--version" || argv[0] == "-V" {
        println!("{VERSION}");
        std::process::exit(0);
    }
    let mut a = Args {
        model: argv[0].clone(),
        potential: None,
        params: HashMap::new(),
        n0: None,
        n1: None,
        points: 701,
        out: None,
        normalize: true,
        grid: 101,
        x0min: 0.05,
        x0max: 0.22,
        profile_out: None,
        rtol: 1e-10,
        atol: 1e-12,
        method: None,
    };
    let mut i = 1;
    let need = |i: usize, argv: &[String]| -> String {
        if i + 1 >= argv.len() {
            eprintln!("missing value after {}", argv[i]);
            usage();
        }
        argv[i + 1].clone()
    };
    while i < argv.len() {
        match argv[i].as_str() {
            "--potential" => { a.potential = Some(need(i, &argv)); i += 2; }
            "--param" => {
                let kv = need(i, &argv);
                let (k, v) = kv.split_once('=').unwrap_or_else(|| { eprintln!("--param expects KEY=VALUE, got '{kv}'"); usage() });
                let val: f64 = v.parse().unwrap_or_else(|_| { eprintln!("--param {k}: '{v}' is not a number"); usage() });
                a.params.insert(k.to_string(), val);
                i += 2;
            }
            "--n0" => { a.n0 = Some(need(i, &argv).parse().unwrap_or_else(|_| usage())); i += 2; }
            "--n1" => { a.n1 = Some(need(i, &argv).parse().unwrap_or_else(|_| usage())); i += 2; }
            "--points" => { a.points = need(i, &argv).parse().unwrap_or_else(|_| usage()); i += 2; }
            "--out" => { a.out = Some(need(i, &argv)); i += 2; }
            "--no-normalize" => { a.normalize = false; i += 1; }
            "--grid" => { a.grid = need(i, &argv).parse().unwrap_or_else(|_| usage()); i += 2; }
            "--x0min" => { a.x0min = need(i, &argv).parse().unwrap_or_else(|_| usage()); i += 2; }
            "--x0max" => { a.x0max = need(i, &argv).parse().unwrap_or_else(|_| usage()); i += 2; }
            "--profile-out" => { a.profile_out = Some(need(i, &argv)); i += 2; }
            "--rtol" => { a.rtol = need(i, &argv).parse().unwrap_or_else(|_| usage()); i += 2; }
            "--atol" => { a.atol = need(i, &argv).parse().unwrap_or_else(|_| usage()); i += 2; }
            "--method" => { a.method = Some(need(i, &argv)); i += 2; }
            other => { eprintln!("unknown argument '{other}'"); usage(); }
        }
    }
    if a.points < 2 {
        eprintln!("--points must be at least 2");
        usage();
    }
    a
}

/// A CSV table: header and rows.
struct Table {
    header: Vec<&'static str>,
    rows: Vec<Vec<f64>>,
}

impl Table {
    fn write(&self, out: &Option<String>) -> Result<(), String> {
        let mut s = String::new();
        s.push_str(&self.header.join(","));
        s.push('\n');
        for r in &self.rows {
            let line: Vec<String> = r.iter().map(|v| format!("{v:.15e}")).collect();
            s.push_str(&line.join(","));
            s.push('\n');
        }
        match out {
            Some(path) => std::fs::write(path, s).map_err(|e| format!("cannot write {path}: {e}")),
            None => { std::io::stdout().write_all(s.as_bytes()).map_err(|e| e.to_string()) }
        }
    }
}

/// BDF for the cosmological (mildly stiff) models, Adams for the undamped oscillatory pre-universe models, unless --method says otherwise.
fn adams_for(a: &Args) -> bool {
    match a.method.as_deref() {
        Some("adams") => true,
        Some("bdf") => false,
        Some(other) => { eprintln!("unknown --method '{other}' (bdf | adams)"); usage() }
        None => a.model.starts_with("scalar-pre"),
    }
}

fn stats_line(model: &str, tr: &Trajectory) -> String {
    format!("# stats: model={model} steps={} rhs_evals={} nonlin_iters={} err_test_fails={}",
            tr.stats.steps, tr.stats.rhs_evals, tr.stats.nonlin_iters, tr.stats.err_test_fails)
}

// ------------------------------------------------------------------ Model A

fn run_scalar_flrw(a: &Args, pot: ScalarPotential, n0: f64, n1: f64) -> Result<(Table, Trajectory, ScalarPotential), String> {
    let bg = Background::from_params(&a.params);
    let phi_i = param(&a.params, "phi_i", default_phi_i(&pot));
    let phidot_i = param(&a.params, "phidot_i", 0.0);
    let target = bg.ode0();

    let one = |p: &ScalarPotential, points: usize| -> Result<Trajectory, String> {
        let m = ScalarFlrw { bg, pot: p.clone() };
        integrate(adams_for(a), rhs_scalar_flrw, Box::new(m), &[phi_i, phidot_i, 0.0], n0, n1, points, a.rtol, a.atol, 500_000)
    };
    let omega_today = |p: &ScalarPotential| -> Result<f64, String> {
        let tr = one(p, 2)?;
        let y = &tr.y[1];
        let m = ScalarFlrw { bg, pot: p.clone() };
        let h2 = m.h2(n1, y[0], y[1]);
        Ok((0.5 * y[1] * y[1] + p.v(y[0])) / (3.0 * h2))
    };

    // Normalise the overall scale of V so that Omega_phi(N = n1) = 1 - om - or, by bisection on
    // log10 of the scale factor k.  Omega_phi today is monotonic in k for every potential here.
    let pot = if a.normalize {
        let (mut lo, mut hi) = (-6.0f64, 6.0f64);
        let f_lo = omega_today(&pot.scaled(10f64.powf(lo)))? - target;
        let f_hi = omega_today(&pot.scaled(10f64.powf(hi)))? - target;
        if f_lo > 0.0 || f_hi < 0.0 {
            return Err(format!("normalisation cannot bracket Omega_phi = {target}: Omega(10^{lo} V) = {}, Omega(10^{hi} V) = {}; choose the scale by hand and pass --no-normalize", f_lo + target, f_hi + target));
        }
        for _ in 0..80 {
            let mid = 0.5 * (lo + hi);
            let f_mid = omega_today(&pot.scaled(10f64.powf(mid)))? - target;
            if f_mid > 0.0 { hi = mid } else { lo = mid }
            if (hi - lo) < 1e-13 { break; }
        }
        pot.scaled(10f64.powf(0.5 * (lo + hi)))
    } else {
        pot
    };

    let tr = one(&pot, a.points)?;
    let m = ScalarFlrw { bg, pot: pot.clone() };
    // t is integrated from N0; the age of the universe at N0 is added analytically as t0 = 1/(2 H(N0)),
    // the exact age of a radiation-dominated universe with that Hubble rate (the era N0 = -7 lies in).
    let t_age0 = 0.5 / m.h2(n0, phi_i, phidot_i).sqrt();
    eprintln!("# initial conditions: N0={n0} phi_i={phi_i} phidot_i={phidot_i} t_age(N0)={t_age0:.6e}");
    let header = vec!["a", "z", "N", "t", "phi", "phidot", "H", "KE", "PE", "rho_phi", "P_phi", "w_phi", "Omega_phi", "Omega_m", "Omega_r", "q_dec"];
    let mut rows = Vec::with_capacity(tr.x.len());
    for (n, y) in tr.x.iter().zip(tr.y.iter()) {
        let (phi, phidot, t) = (y[0], y[1], y[2] + t_age0);
        let aa = n.exp();
        let h2 = m.h2(*n, phi, phidot);
        let h = h2.sqrt();
        let ke = 0.5 * phidot * phidot;
        let pe = pot.v(phi);
        let rho = ke + pe;
        let p = ke - pe;
        if !(rho > 0.0) {
            return Err(format!("rho_phi = {rho} is not positive at N = {n}: the potential went negative; w is undefined there"));
        }
        let rho_m = 3.0 * bg.om * (-3.0 * n).exp();
        let rho_r = 3.0 * bg.or * (-4.0 * n).exp();
        let dh_dn = (-3.0 * rho_m - 4.0 * rho_r - 3.0 * phidot * phidot) / (6.0 * h);
        let q = -1.0 - dh_dn / h;
        rows.push(vec![aa, 1.0 / aa - 1.0, *n, t, phi, phidot, h, ke, pe, rho, p, p / rho, rho / (3.0 * h2), rho_m / (3.0 * h2), rho_r / (3.0 * h2), q]);
    }
    Ok((Table { header, rows }, tr, pot))
}

fn default_phi_i(pot: &ScalarPotential) -> f64 {
    match pot {
        ScalarPotential::Exp { .. } => 0.0,
        ScalarPotential::InvPower { .. } => 0.2,
        ScalarPotential::Pngb { f, .. } => 0.5 * f,
        ScalarPotential::Quadratic { .. } => 1.0,
        ScalarPotential::Hilltop { mu, .. } => 0.1 * mu,
        ScalarPotential::Const { .. } => 0.0,
        ScalarPotential::Quartic { .. } => 1.0,
    }
}

// ------------------------------------------------------------------ Model A'

fn run_scalar_cpl(a: &Args, pot: ScalarPotential, n0: f64, n1: f64) -> Result<(Table, Trajectory, ScalarPotential), String> {
    let bg = Background::from_params(&a.params);
    let phi_i = param(&a.params, "phi_i", default_phi_i(&pot));
    let phidot_i = param(&a.params, "phidot_i", 0.0);
    let one = |p: &ScalarPotential, points: usize| -> Result<Trajectory, String> {
        let m = ScalarCpl { bg, pot: p.clone() };
        integrate(adams_for(a), rhs_scalar_cpl, Box::new(m), &[phi_i, phidot_i, 0.0], n0, n1, points, a.rtol, a.atol, 500_000)
    };
    // The test field does not source H; its scale is fixed so that rho_phi(today)/3 = Omega_DE
    // (i.e. it carries the energy the CPL dark energy would carry today).
    let pot = if a.normalize {
        let target = 3.0 * bg.ode0();
        let rho_today = |p: &ScalarPotential| -> Result<f64, String> {
            let tr = one(p, 2)?;
            let y = &tr.y[1];
            Ok(0.5 * y[1] * y[1] + p.v(y[0]))
        };
        let (mut lo, mut hi) = (-6.0f64, 6.0f64);
        // The same bracket check as Model A: a field that joins the scaling regime of the CPL
        // background (exp with lambda^2 > 3) never carries rho_phi(today) = 3 Omega_DE, and the
        // bisection would otherwise return the bracket edge 10^6 silently.
        let f_lo = rho_today(&pot.scaled(10f64.powf(lo)))? - target;
        let f_hi = rho_today(&pot.scaled(10f64.powf(hi)))? - target;
        if f_lo > 0.0 || f_hi < 0.0 {
            return Err(format!("normalisation cannot bracket rho_phi(a=1) = {target} (= 3 Omega_DE): rho_phi(10^{lo} V) = {}, rho_phi(10^{hi} V) = {}; choose the scale by hand and pass --no-normalize", f_lo + target, f_hi + target));
        }
        for _ in 0..80 {
            let mid = 0.5 * (lo + hi);
            if rho_today(&pot.scaled(10f64.powf(mid)))? > target { hi = mid } else { lo = mid }
            if (hi - lo) < 1e-13 { break; }
        }
        pot.scaled(10f64.powf(0.5 * (lo + hi)))
    } else {
        pot
    };
    let tr = one(&pot, a.points)?;
    let t_age0 = 0.5 / bg.cpl_h2(n0.exp()).sqrt();
    eprintln!("# initial conditions: N0={n0} phi_i={phi_i} phidot_i={phidot_i} t_age(N0)={t_age0:.6e}");
    let header = vec!["a", "z", "N", "t", "phi", "phidot", "H", "KE", "PE", "rho_phi", "P_phi", "w_phi", "w_cpl", "Omega_phi_test", "Omega_DE_cpl"];
    let mut rows = Vec::with_capacity(tr.x.len());
    for (n, y) in tr.x.iter().zip(tr.y.iter()) {
        let (phi, phidot, t) = (y[0], y[1], y[2] + t_age0);
        let aa = n.exp();
        let h2 = bg.cpl_h2(aa);
        let ke = 0.5 * phidot * phidot;
        let pe = pot.v(phi);
        let rho = ke + pe;
        let p = ke - pe;
        rows.push(vec![aa, 1.0 / aa - 1.0, *n, t, phi, phidot, h2.sqrt(), ke, pe, rho, p, p / rho, bg.cpl_w(aa), rho / (3.0 * h2), bg.ode0() * bg.cpl_factor(aa) / h2]);
    }
    Ok((Table { header, rows }, tr, pot))
}

// ------------------------------------------------------------------ Model B

fn run_spinor_flrw(a: &Args, pot: SpinorPotential, n0: f64, n1: f64) -> Result<(Table, Trajectory, SpinorPotential), String> {
    let bg = Background::from_params(&a.params);
    let s_today = param(&a.params, "s_today", 1.0);
    // s = s_today e^{-3N} exactly; the potential is scaled so that V(s_today) = 3 Omega_Psi0, which
    // leaves w(s) untouched.
    let pot = if a.normalize {
        let k = 3.0 * bg.ode0() / pot.v(s_today);
        if !(k > 0.0) || !k.is_finite() {
            return Err(format!("cannot normalise: V(s_today = {s_today}) = {} must be positive", pot.v(s_today)));
        }
        pot.scaled(k)
    } else {
        pot
    };
    let s_i = s_today * (-3.0 * n0).exp();
    if !(pot.v(s_i) > 0.0) {
        return Err(format!("V(s) = {} is not positive at the start (s = {s_i:.4e} at N0 = {n0}): rho_Psi = V(s) must be positive; this potential is only valid at later times -- start at a larger --n0 (the Lorentz potential is positive everywhere)", pot.v(s_i)));
    }
    let m = SpinorFlrw { bg, pot: pot.clone() };
    let t_age0 = 0.5 / m.h2(n0, s_i).sqrt();
    eprintln!("# initial conditions: N0={n0} s_i={s_i:.6e} s_today={s_today} t_age(N0)={t_age0:.6e}");
    let tr = integrate(adams_for(a), rhs_spinor_flrw, Box::new(m), &[s_i, 0.0], n0, n1, a.points, a.rtol, a.atol, 500_000)?;
    let m = SpinorFlrw { bg, pot: pot.clone() };
    let header = vec!["a", "z", "N", "t", "s", "H", "K_Psi", "U_Psi", "rho_Psi", "P_Psi", "w_Psi", "Omega_Psi", "Omega_m", "Omega_r", "q_dec"];
    let mut rows = Vec::with_capacity(tr.x.len());
    for (n, y) in tr.x.iter().zip(tr.y.iter()) {
        let (s, t) = (y[0], y[1] + t_age0);
        let aa = n.exp();
        let h2 = m.h2(*n, s);
        let h = h2.sqrt();
        let v = pot.v(s);
        if !(v > 0.0) {
            return Err(format!("V(s) = {v} is not positive at N = {n} (s = {s:.4e}): rho_Psi = V(s) must be positive on the whole run"));
        }
        let sv = s * pot.dv(s);
        let rho_m = 3.0 * bg.om * (-3.0 * n).exp();
        let rho_r = 3.0 * bg.or * (-4.0 * n).exp();
        let dh_dn = (-3.0 * rho_m - 4.0 * rho_r - 3.0 * sv) / (6.0 * h);
        let q = -1.0 - dh_dn / h;
        rows.push(vec![aa, 1.0 / aa - 1.0, *n, t, s, h, sv, v, v, sv - v, pot.w(s), v / (3.0 * h2), rho_m / (3.0 * h2), rho_r / (3.0 * h2), q]);
    }
    Ok((Table { header, rows }, tr, pot))
}

// ------------------------------------------------------------------ Model C

fn run_scalar_pre(a: &Args, pot: ScalarPotential, x0: f64, x1: f64) -> Result<(Table, Trajectory), String> {
    let phi_i = param(&a.params, "phi_i", 1.0);
    let phidot_i = param(&a.params, "phidot_i", 0.0);
    let m = ScalarPre { pot: pot.clone() };
    let tr = integrate(adams_for(a), rhs_scalar_pre, Box::new(m), &[phi_i, phidot_i], x0, x1, a.points, a.rtol, a.atol, 500_000)?;
    let header = vec!["x4", "phi", "phidot", "KE", "PE", "rho", "P", "w", "w_avg", "rho_drift"];
    let mut rows = Vec::with_capacity(tr.x.len());
    let mut acc_w = 0.0;
    let mut prev: Option<(f64, f64)> = None;
    let rho0 = 0.5 * phidot_i * phidot_i + pot.v(phi_i);
    for (x, y) in tr.x.iter().zip(tr.y.iter()) {
        let (phi, phidot) = (y[0], y[1]);
        let ke = 0.5 * phidot * phidot;
        let pe = pot.v(phi);
        let rho = ke + pe;
        let p = ke - pe;
        let w = p / rho;
        if let Some((xp, wp)) = prev {
            acc_w += 0.5 * (w + wp) * (x - xp);
        }
        prev = Some((*x, w));
        let w_avg = if *x > tr.x[0] { acc_w / (x - tr.x[0]) } else { w };
        rows.push(vec![*x, phi, phidot, ke, pe, rho, p, w, w_avg, rho / rho0 - 1.0]);
    }
    Ok((Table { header, rows }, tr))
}

// ------------------------------------------------------------------ Model D

fn run_scalar_pre_x0(a: &Args, pot: ScalarPotential, x0: f64, x1: f64) -> Result<(Table, Trajectory, Option<Table>), String> {
    let grid = ScalarPreX0::new(pot.clone(), a.x0min, a.x0max, a.grid)?;
    let n = grid.n();
    let amp = param(&a.params, "phi_i", 1.0);
    let eps = param(&a.params, "eps", 0.5);
    let mode = param(&a.params, "mode", 1.0);
    // initial profile: phi(x0, 0) = amp (1 + eps cos(mode pi (x0 - x0min)/(x0max - x0min))), at rest
    let mut y0 = vec![0.0; 2 * n];
    for j in 0..n {
        let u = (grid.x0[j] - a.x0min) / (a.x0max - a.x0min);
        y0[j] = amp * (1.0 + eps * (mode * std::f64::consts::PI * u).cos());
    }
    let sec = grid.sec_j.clone();
    let coef_half = grid.coef_half.clone();
    let x0grid = grid.x0.clone();
    let h = grid.h;
    let mid = n / 2;
    let m = ScalarPreX0 { pot: pot.clone(), ..grid };
    let g0_of = {
        let g = ScalarPreX0::new(pot.clone(), a.x0min, a.x0max, a.grid)?;
        move |phi: &[f64]| g.g0(phi)
    };
    let tr = integrate(adams_for(a), rhs_scalar_pre_x0, Box::new(m), &y0, x0, x1, a.points, a.rtol, a.atol, 2_000_000)?;
    let header = vec!["x4", "phi_mid", "KE_mid", "PE_mid", "G0_mid", "rho_mid", "P_mid", "w_mid", "E_sheet", "P_sheet", "w_sheet", "KE_frac", "PE_frac", "G0_frac", "E_drift"];
    let mut rows = Vec::with_capacity(tr.x.len());
    let mut e0: Option<f64> = None;
    let mut profile_rows = Vec::new();
    for (x, y) in tr.x.iter().zip(tr.y.iter()) {
        let (phi, phidot) = y.split_at(n);
        let g0 = g0_of(phi);
        // the discrete energy the scheme conserves exactly (summation by parts of the flux form)
        let (mut ke_t, mut pe_t, mut g0_t) = (0.0, 0.0, 0.0);
        for j in 0..n {
            let wgt = sec[j] * h;
            ke_t += wgt * 0.5 * phidot[j] * phidot[j];
            pe_t += wgt * pot.v(phi[j]);
        }
        for j in 0..n - 1 {
            let d = (phi[j + 1] - phi[j]) / h;
            g0_t += 0.5 * coef_half[j] * d * d * h;
        }
        let e = ke_t + pe_t + g0_t;
        let ptot = ke_t - pe_t - g0_t;
        if e0.is_none() { e0 = Some(e); }
        let ke_m = 0.5 * phidot[mid] * phidot[mid];
        let pe_m = pot.v(phi[mid]);
        let rho_m = ke_m + pe_m + g0[mid];
        let p_m = ke_m - pe_m - g0[mid];
        rows.push(vec![*x, phi[mid], ke_m, pe_m, g0[mid], rho_m, p_m, p_m / rho_m, e, ptot, ptot / e, ke_t / e, pe_t / e, g0_t / e, e / e0.unwrap() - 1.0]);
        if a.profile_out.is_some() {
            let mut r = vec![*x];
            r.extend_from_slice(phi);
            profile_rows.push(r);
        }
    }
    let profile = if a.profile_out.is_some() {
        // header: x4, then the grid abscissae as column names are not numbers; write them as a first row
        let mut hdr: Vec<&'static str> = vec!["x4"];
        for _ in 0..n { hdr.push("phi"); }
        let mut rows2 = vec![{ let mut r = vec![f64::NAN]; r.extend(x0grid.iter()); r }];
        rows2.extend(profile_rows);
        Some(Table { header: hdr, rows: rows2 })
    } else { None };
    Ok((Table { header, rows }, tr, profile))
}

fn main() {
    let a = parse_args();
    let result: Result<(Table, Trajectory, Option<Table>, String), String> = (|| {
        match a.model.as_str() {
            "scalar-flrw" | "scalar-cpl" | "scalar-pre" | "scalar-pre-x0" => {
                let name = a.potential.clone().unwrap_or_else(|| "exp".to_string());
                let pot = ScalarPotential::from_name(&name, &a.params)?;
                match a.model.as_str() {
                    "scalar-flrw" => {
                        let (t, tr, p) = run_scalar_flrw(&a, pot, a.n0.unwrap_or(-7.0), a.n1.unwrap_or(0.0))?;
                        Ok((t, tr, None, format!("potential={} {:?}", p.name(), p)))
                    }
                    "scalar-cpl" => {
                        let (t, tr, p) = run_scalar_cpl(&a, pot, a.n0.unwrap_or(-7.0), a.n1.unwrap_or(0.0))?;
                        Ok((t, tr, None, format!("potential={} {:?}", p.name(), p)))
                    }
                    "scalar-pre" => {
                        let (t, tr) = run_scalar_pre(&a, pot.clone(), a.n0.unwrap_or(0.0), a.n1.unwrap_or(50.0))?;
                        Ok((t, tr, None, format!("potential={} {:?}", pot.name(), pot)))
                    }
                    _ => {
                        let (t, tr, prof) = run_scalar_pre_x0(&a, pot.clone(), a.n0.unwrap_or(0.0), a.n1.unwrap_or(50.0))?;
                        Ok((t, tr, prof, format!("potential={} {:?} grid={} x0=[{},{}]", pot.name(), pot, a.grid, a.x0min, a.x0max)))
                    }
                }
            }
            "spinor-flrw" => {
                let name = a.potential.clone().unwrap_or_else(|| "mass".to_string());
                let pot = SpinorPotential::from_name(&name, &a.params)?;
                let (t, tr, p) = run_spinor_flrw(&a, pot, a.n0.unwrap_or(-7.0), a.n1.unwrap_or(0.0))?;
                Ok((t, tr, None, format!("potential={} {:?}", p.name(), p)))
            }
            other => Err(format!("unknown model '{other}'")),
        }
    })();
    match result {
        Ok((table, tr, profile, desc)) => {
            if let Err(e) = table.write(&a.out) {
                eprintln!("{e}");
                std::process::exit(1);
            }
            if let (Some(p), Some(path)) = (profile, &a.profile_out) {
                if let Err(e) = p.write(&Some(path.clone())) {
                    eprintln!("{e}");
                    std::process::exit(1);
                }
            }
            eprintln!("{}", stats_line(&a.model, &tr));
            eprintln!("# {desc}");
            eprintln!("# {VERSION}");
        }
        Err(e) => {
            eprintln!("fable_cosmo: {e}");
            std::process::exit(1);
        }
    }
}
