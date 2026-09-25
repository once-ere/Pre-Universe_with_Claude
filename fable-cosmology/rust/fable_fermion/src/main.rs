//! fable_fermion -- command-line front end.
//!
//!     fable_fermion fable4d|fable8d --potential NAME [--param KEY=VALUE ...]
//!                   [--direction forward|backward] [--a-start A] [--points K] [--out FILE.csv]
//!                   [--rtol R] [--atol A] [--method bdf|adams] [--branch lowest|positive|negative]
//!                   [--freeze-hidden] [--no-shoot] [--omega-b X] [--omega-r X] [--no-fable]
//!     fable_fermion gap --potential NAME --param ... --kf KF [--v V]     (all gap roots, energies)
//!     fable_fermion --constants
//!     fable_fermion --version
//!
//! Potentials and their --param keys (masses in eV where the key ends in _ev; everything else in
//! the solver's units, see --constants):
//!   mass        m0_ev (1)
//!   lambda-mass m0_ev (1), omega_dm (0.265)
//!   power       m_today_ev (1), nu (0.236), omega_dm (0.265)
//!   expdamp     m_today_ev (1), xt (1/2.21), omega_dm (0.265)
//!   lorentz     m_today_ev (1), xt (1/1.5), omega_dm (0.265)
//!   quadratic   m_today_ev (1), gq (-0.5), omega_dm (0.265)
//!   explicit    (the W parameters below given explicitly; kF0 shot)
//! With --no-shoot, or --potential explicit, the potential's own parameters are read:
//!   m0 | m0_ev, v0, lam, nu, s1, and (for --no-shoot) kf0 | kf0_ev; the W form from --form NAME.
//!
//! The CSV goes to --out (or stdout); the log and the integration statistics go to stderr.
//! Exit code 0 on success, 2 on a usage error, 1 on a solver error.

use std::collections::HashMap;
use std::io::Write;

use fable_fermion::constants::Units;
use fable_fermion::kohn_sham::{gap_roots_scan, mean_field_at, solve_gap, Selection};
use fable_fermion::potentials::{GapPlan, Potential};
use fable_fermion::run::{run, Config, Direction, ModelKind, Spec};
use fable_fermion::VERSION;

fn usage() -> ! {
    eprintln!("usage: fable_fermion fable4d|fable8d --potential mass|lambda-mass|power|expdamp|lorentz|quadratic|explicit [--form NAME] [--param KEY=VALUE ...] [--direction forward|backward] [--a-start A] [--points K] [--out FILE.csv] [--rtol R] [--atol A] [--method bdf|adams] [--branch lowest|positive|negative] [--freeze-hidden] [--no-shoot] [--no-fable] [--omega-b X] [--omega-r X]\n       fable_fermion gap --form NAME --param ... --kf KF [--v V]\n       fable_fermion --constants | --version");
    std::process::exit(2);
}

struct Args {
    cmd: String,
    potential: Option<String>,
    form: Option<String>,
    params: HashMap<String, f64>,
    direction: Direction,
    a_start: f64,
    points: usize,
    out: Option<String>,
    rtol: f64,
    atol: f64,
    adams: bool,
    sel: Selection,
    freeze: bool,
    no_shoot: bool,
    no_fable: bool,
    omega_b: Option<f64>,
    omega_r: Option<f64>,
    kf: Option<f64>,
    v: f64,
}

fn parse_args() -> Args {
    let argv: Vec<String> = std::env::args().skip(1).collect();
    if argv.is_empty() {
        usage();
    }
    match argv[0].as_str() {
        "--version" | "-V" => {
            println!("{VERSION}");
            std::process::exit(0);
        }
        "--constants" => {
            print!("{}", Units::new().report());
            std::process::exit(0);
        }
        _ => {}
    }
    let mut a = Args {
        cmd: argv[0].clone(),
        potential: None,
        form: None,
        params: HashMap::new(),
        direction: Direction::Forward,
        a_start: 1e-12,
        points: 2001,
        out: None,
        rtol: 1e-10,
        atol: 1e-12,
        adams: false,
        sel: Selection::Lowest,
        freeze: false,
        no_shoot: false,
        no_fable: false,
        omega_b: None,
        omega_r: None,
        kf: None,
        v: 1.0,
    };
    let need = |i: usize, argv: &[String]| -> String {
        if i + 1 >= argv.len() {
            eprintln!("missing value after {}", argv[i]);
            usage();
        }
        argv[i + 1].clone()
    };
    let num = |s: String, what: &str| -> f64 {
        s.parse().unwrap_or_else(|_| {
            eprintln!("{what}: '{s}' is not a number");
            usage()
        })
    };
    let mut i = 1;
    while i < argv.len() {
        match argv[i].as_str() {
            "--potential" => { a.potential = Some(need(i, &argv)); i += 2; }
            "--form" => { a.form = Some(need(i, &argv)); i += 2; }
            "--param" => {
                let kv = need(i, &argv);
                let (k, v) = kv.split_once('=').unwrap_or_else(|| { eprintln!("--param expects KEY=VALUE, got '{kv}'"); usage() });
                a.params.insert(k.to_string(), num(v.to_string(), k));
                i += 2;
            }
            "--direction" => {
                a.direction = match need(i, &argv).as_str() {
                    "forward" => Direction::Forward,
                    "backward" => Direction::Backward,
                    o => { eprintln!("unknown --direction '{o}'"); usage() }
                };
                i += 2;
            }
            "--a-start" => { a.a_start = num(need(i, &argv), "--a-start"); i += 2; }
            "--points" => { a.points = num(need(i, &argv), "--points") as usize; i += 2; }
            "--out" => { a.out = Some(need(i, &argv)); i += 2; }
            "--rtol" => { a.rtol = num(need(i, &argv), "--rtol"); i += 2; }
            "--atol" => { a.atol = num(need(i, &argv), "--atol"); i += 2; }
            "--method" => {
                a.adams = match need(i, &argv).as_str() {
                    "bdf" => false,
                    "adams" => true,
                    o => { eprintln!("unknown --method '{o}' (bdf | adams)"); usage() }
                };
                i += 2;
            }
            "--branch" => { a.sel = Selection::parse(&need(i, &argv)).unwrap_or_else(|e| { eprintln!("{e}"); usage() }); i += 2; }
            "--freeze-hidden" => { a.freeze = true; i += 1; }
            "--no-shoot" => { a.no_shoot = true; i += 1; }
            "--no-fable" => { a.no_fable = true; i += 1; }
            "--omega-b" => { a.omega_b = Some(num(need(i, &argv), "--omega-b")); i += 2; }
            "--omega-r" => { a.omega_r = Some(num(need(i, &argv), "--omega-r")); i += 2; }
            "--kf" => { a.kf = Some(num(need(i, &argv), "--kf")); i += 2; }
            "--v" => { a.v = num(need(i, &argv), "--v"); i += 2; }
            other => { eprintln!("unknown argument '{other}'"); usage(); }
        }
    }
    if a.points < 2 {
        eprintln!("--points must be at least 2");
        usage();
    }
    a
}

fn p(a: &Args, key: &str, default: f64) -> f64 {
    a.params.get(key).copied().unwrap_or(default)
}

/// A mass parameter: KEY_ev (eV) if given, else KEY (solver units), else default_ev (eV).
fn mass(a: &Args, u: &Units, key: &str, default_ev: f64) -> f64 {
    if let Some(v) = a.params.get(&format!("{key}_ev")) {
        u.from_ev(*v)
    } else if let Some(v) = a.params.get(key) {
        *v
    } else {
        u.from_ev(default_ev)
    }
}

/// The potential from its explicit parameters (for --no-shoot, explicit, gap).
fn explicit_potential(a: &Args, u: &Units, form: &str) -> Result<Potential, String> {
    let m0 = mass(a, u, "m0", 1.0);
    Ok(match form {
        "mass" => Potential::Mass { m0 },
        "lambda-mass" => Potential::LambdaMass { v0: p(a, "v0", 0.0), m0 },
        "power" => Potential::Power { m0, lam: p(a, "lam", 1.0), nu: p(a, "nu", 0.236) },
        "expdamp" => Potential::ExpDamp { v0: p(a, "v0", 0.0), m0, s1: p(a, "s1", 1.0) },
        "lorentz" => Potential::Lorentz { v0: p(a, "v0", 0.0), m0, s1: p(a, "s1", 1.0) },
        "quadratic" => Potential::Quadratic { v0: p(a, "v0", 0.0), m0, lam: p(a, "lam", 0.0) },
        other => return Err(format!("unknown potential form '{other}'")),
    })
}

fn build_spec(a: &Args, u: &Units) -> Result<Spec, String> {
    if a.no_fable {
        return Ok(Spec::NoFable);
    }
    let name = a.potential.clone().unwrap_or_else(|| "mass".into());
    if a.no_shoot {
        let form = a.form.clone().unwrap_or_else(|| name.clone());
        let pot = explicit_potential(a, u, &form)?;
        let kf0 = mass(a, u, "kf0", f64::NAN);
        if !kf0.is_finite() {
            return Err("--no-shoot needs --param kf0=... (solver units) or kf0_ev=...".into());
        }
        return Ok(Spec::Direct { pot, kf0 });
    }
    let dm = p(a, "omega_dm", 0.265);
    Ok(match name.as_str() {
        "mass" => Spec::Mass { m0: mass(a, u, "m0", 1.0) },
        "lambda-mass" => Spec::LambdaMass { m0: mass(a, u, "m0", 1.0), omega_dm: dm },
        "power" => Spec::Power { m_today: mass(a, u, "m_today", 1.0), nu: p(a, "nu", 0.236), omega_dm: dm },
        "expdamp" => Spec::ExpDamp { m_today: mass(a, u, "m_today", 1.0), xt: p(a, "xt", 1.0 / 2.21), omega_dm: dm },
        "lorentz" => Spec::Lorentz { m_today: mass(a, u, "m_today", 1.0), xt: p(a, "xt", 1.0 / 1.5), omega_dm: dm },
        "quadratic" => Spec::Quadratic { m_today: mass(a, u, "m_today", 1.0), gq: p(a, "gq", -0.5), omega_dm: dm },
        "explicit" => {
            let form = a.form.clone().ok_or("--potential explicit needs --form NAME")?;
            Spec::Explicit { pot: explicit_potential(a, u, &form)? }
        }
        other => return Err(format!("unknown potential '{other}' (mass | lambda-mass | power | expdamp | lorentz | quadratic | explicit)")),
    })
}

fn gap_command(a: &Args, u: &Units) -> Result<(), String> {
    let form = a.form.clone().or(a.potential.clone()).ok_or("gap needs --form NAME")?;
    let pot = explicit_potential(a, u, &form)?;
    let kf = a.kf.ok_or("gap needs --kf KF (solver units)")?;
    let v = a.v;
    let sea0 = fable_fermion::kohn_sham::fermi_sea(0.0, kf);
    let plan = pot.gap_plan(sea0.n / v, sea0.chi / v);
    println!("# potential {pot:?}, kF = {kf:e}, v = {v:e}, n8 = {:e}, plan = {plan:?}", sea0.n / v);
    let (lo, hi) = match plan {
        GapPlan::Exact(m) => (m, m),
        GapPlan::Unique { lo, hi } | GapPlan::Scan { lo, hi } => (lo, if hi.is_finite() { hi } else { 1e3 * (lo.abs() + kf) }),
    };
    let roots = if lo == hi { vec![lo] } else { gap_roots_scan(&pot, kf, v, lo, hi)? };
    println!("m,sigma8,rho8,P_obs,P_hid,gap_residual");
    for r in roots {
        let mf = mean_field_at(&pot, r, kf, v);
        println!("{:.15e},{:.15e},{:.15e},{:.15e},{:.15e},{:.3e}", r, mf.sigma8, mf.rho, mf.p_obs, mf.p_hid, mf.gap_residual);
    }
    let best = solve_gap(&pot, kf, v, a.sel)?;
    println!("# selected ({:?}): m = {:.15e}, rho8 = {:.15e}, roots = {}", a.sel, best.m, best.rho, best.n_roots);
    Ok(())
}

fn main() {
    let a = parse_args();
    let u = Units::new();
    if a.cmd == "gap" {
        if let Err(e) = gap_command(&a, &u) {
            eprintln!("fable_fermion: {e}");
            std::process::exit(1);
        }
        return;
    }
    let kind = match a.cmd.as_str() {
        "fable4d" => ModelKind::Fable4d,
        "fable8d" => ModelKind::Fable8d,
        other => {
            eprintln!("unknown model '{other}' (fable4d | fable8d | gap)");
            usage();
        }
    };
    let spec = match build_spec(&a, &u) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("fable_fermion: {e}");
            std::process::exit(2);
        }
    };
    let mut cfg = Config::new(kind, a.direction, &u);
    cfg.a_start = a.a_start;
    cfg.points = a.points;
    cfg.rtol = a.rtol;
    cfg.atol = a.atol;
    cfg.adams = a.adams;
    cfg.sel = a.sel;
    cfg.freeze_hidden = a.freeze;
    if let Some(x) = a.omega_b {
        cfg.omega_b0 = x;
    }
    if let Some(x) = a.omega_r {
        cfg.omega_r0 = x;
    }
    let t0 = std::time::Instant::now();
    match run(&cfg, &spec, &u) {
        Ok(out) => {
            let csv = out.csv();
            let res = match &a.out {
                Some(path) => std::fs::write(path, csv).map_err(|e| format!("cannot write {path}: {e}")),
                None => std::io::stdout().write_all(csv.as_bytes()).map_err(|e| e.to_string()),
            };
            if let Err(e) = res {
                eprintln!("fable_fermion: {e}");
                std::process::exit(1);
            }
            for l in &out.log {
                eprintln!("# {l}");
            }
            let s = out.stats;
            eprintln!(
                "# stats: model={} direction={:?} potential={} steps={} rhs_evals={} nonlin_iters={} err_test_fails={} jac_evals={} wall={:.3}s",
                a.cmd,
                a.direction,
                spec.label(),
                s.steps,
                s.rhs_evals,
                s.nonlin_iters,
                s.err_test_fails,
                s.jac_evals,
                t0.elapsed().as_secs_f64()
            );
            eprintln!("# {VERSION}");
        }
        Err(e) => {
            eprintln!("fable_fermion: {e}");
            std::process::exit(1);
        }
    }
}
