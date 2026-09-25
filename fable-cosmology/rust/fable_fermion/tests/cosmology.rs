//! End-to-end tests of fable4d / fable8d: real runs, written to CSV, read back and checked.

use std::collections::HashMap;

use fable_fermion::constants::Units;
use fable_fermion::kohn_sham::Selection;
use fable_fermion::potentials::Potential;
use fable_fermion::run::{run, Config, Direction, ModelKind, Spec};

/// A CSV read back from disk: header comments, column index, rows.
struct Csv {
    comments: Vec<String>,
    idx: HashMap<String, usize>,
    rows: Vec<Vec<f64>>,
}

impl Csv {
    fn col(&self, name: &str) -> Vec<f64> {
        let i = *self.idx.get(name).unwrap_or_else(|| panic!("no column {name}"));
        self.rows.iter().map(|r| r[i]).collect()
    }
}

fn run_csv(tag: &str, cfg: &Config, spec: &Spec) -> Csv {
    let u = Units::new();
    let out = run(cfg, spec, &u).unwrap_or_else(|e| panic!("{tag}: {e}"));
    let path = std::path::Path::new(env!("CARGO_TARGET_TMPDIR")).join(format!("{tag}.csv"));
    std::fs::write(&path, out.csv()).unwrap();
    let text = std::fs::read_to_string(&path).unwrap();
    let mut comments = Vec::new();
    let mut idx = HashMap::new();
    let mut rows = Vec::new();
    for line in text.lines() {
        if let Some(c) = line.strip_prefix("# ") {
            comments.push(c.to_string());
        } else if idx.is_empty() {
            for (i, h) in line.split(',').enumerate() {
                idx.insert(h.to_string(), i);
            }
        } else {
            rows.push(line.split(',').map(|x| x.parse::<f64>().unwrap()).collect());
        }
    }
    Csv { comments, idx, rows }
}

fn cfg(kind: ModelKind) -> Config {
    Config::new(kind, Direction::Forward, &Units::new())
}

fn ev(x: f64) -> f64 {
    Units::new().from_ev(x)
}

/// 7-point central derivative on a uniform grid (interior points only).
fn deriv7(x: &[f64], y: &[f64], k: usize) -> f64 {
    let h = x[k + 1] - x[k];
    (y[k + 3] - 9.0 * y[k + 2] + 45.0 * y[k + 1] - 45.0 * y[k - 1] + 9.0 * y[k - 2] - y[k - 3]) / (60.0 * h)
}

/// 5-point central derivative on a uniform grid (interior points only).
fn deriv5(x: &[f64], y: &[f64], k: usize) -> f64 {
    let h = x[k + 1] - x[k];
    (-y[k + 2] + 8.0 * y[k + 1] - 8.0 * y[k - 1] + y[k - 2]) / (12.0 * h)
}

#[test]
fn version_string() {
    let out = std::process::Command::new(env!("CARGO_BIN_EXE_fable_fermion")).arg("--version").output().unwrap();
    assert_eq!(String::from_utf8_lossy(&out.stdout).trim(), "fable_fermion 0.1.0, sundials_rs 7.8.0 (pure Rust), CVODE BDF");
}

#[test]
fn covariant_conservation_along_real_fable8d_runs() {
    // rho' + 3 (rho + P_obs) + ((3 H_B + H_C)/H_A) (rho + P_hid) = 0 in N = ln A, for each source,
    // by 5-point finite differences of the CSV (4001 points, dN = 0.0069)
    for (tag, spec) in [
        ("cons_lm1", Spec::LambdaMass { m0: ev(1.0), omega_dm: 0.265 }),
        ("cons_pw", Spec::Power { m_today: ev(1.0), nu: 0.236, omega_dm: 0.265 }),
        ("cons_ed", Spec::ExpDamp { m_today: ev(1.0), xt: 1.0 / 2.21, omega_dm: 0.265 }),
    ] {
        let mut c = cfg(ModelKind::Fable8d);
        c.points = 4001;
        let t = run_csv(tag, &c, &spec);
        let (n, ha, hb, hc) = (t.col("N"), t.col("H_A"), t.col("H_B"), t.col("H_C"));
        let (rf, po, ph) = (t.col("rho_f"), t.col("P_obs_f"), t.col("P_hid_f"));
        let (rr, rb) = (t.col("rho_r"), t.col("rho_b"));
        let mut worst: f64 = 0.0;
        let mut skipped = 0usize;
        for k in 2..n.len() - 2 {
            // skip rows the CSV grid does not resolve: |D7 - D5| estimates the truncation error of
            // the 5-point derivative D5; rows where it exceeds 1e-6 of the conservation terms cannot
            // be certified by this grid.  The power law's "pinning release" makes m_eff jump by 100x
            // within one CSV interval near A = 1: CVODE resolves it with its own steps, the CSV
            // grid (dN = 0.007) cannot.
            if k < 3 || k + 3 >= n.len() {
                continue;
            }
            let d5 = deriv5(&n, &rf, k);
            let d7 = deriv7(&n, &rf, k);
            let fscale = 3.0 * (rf[k] + po[k]).abs();
            if (d7 - d5).abs() > 1e-6 * fscale {
                skipped += 1;
                continue;
            }
            let ell = (3.0 * hb[k] + hc[k]) / ha[k];
            let fab = deriv5(&n, &rf, k) + 3.0 * (rf[k] + po[k]) + ell * (rf[k] + ph[k]);
            let fab_scale = 3.0 * (rf[k] + po[k]).abs() + ell.abs() * (rf[k] + ph[k]).abs();
            let rad = deriv5(&n, &rr, k) + 3.0 * (4.0 / 3.0) * rr[k] + ell * rr[k];
            let bar = deriv5(&n, &rb, k) + 3.0 * rb[k] + ell * rb[k];
            let e = (fab / fab_scale).abs().max((rad / (4.0 * rr[k])).abs()).max((bar / (3.0 * rb[k])).abs());
            worst = worst.max(e);
        }
        assert!(worst < 1e-6, "{tag}: worst relative conservation residual {worst:e}");
        assert!(skipped * 100 < n.len(), "{tag}: {skipped} under-resolved rows skipped");
        eprintln!("{tag}: worst relative conservation residual {worst:.3e} ({skipped} under-resolved rows skipped)");
    }
}

#[test]
fn constraint_residual_stays_small_on_forward_fable8d_runs() {
    for (tag, spec) in [
        ("con_lm1", Spec::LambdaMass { m0: ev(1.0), omega_dm: 0.265 }),
        ("con_lm30", Spec::LambdaMass { m0: ev(30.0), omega_dm: 0.265 }),
        ("con_pw5", Spec::Power { m_today: ev(1.0), nu: 0.5, omega_dm: 0.265 }),
        ("con_qd", Spec::Quadratic { m_today: ev(1.0), gq: -0.5, omega_dm: 0.265 }),
        ("con_mass", Spec::Mass { m0: ev(100.0) }),
    ] {
        let t = run_csv(tag, &cfg(ModelKind::Fable8d), &spec);
        let (res, ha) = (t.col("constraint_residual"), t.col("H_A"));
        let rho: Vec<f64> = (0..res.len()).map(|k| t.col("rho_r")[k] + t.col("rho_b")[k] + t.col("rho_f")[k]).collect();
        // relative to 3 rho_hat (the CSV column is normalized by 3 H_A^2, up to 7x larger when H_B ~ H_A)
        let worst_rho = (0..res.len()).map(|k| (res[k] * ha[k] * ha[k] / rho[k]).abs()).fold(0.0f64, f64::max);
        let worst_col = res.iter().fold(0.0f64, |a, b| a.max(b.abs()));
        assert!(worst_rho < 1e-8, "{tag}: |S - 3 rho|/(3 rho) = {worst_rho:e}");
        assert!(worst_col < 1e-7, "{tag}: |S - 3 rho|/(3 H_A^2) = {worst_col:e}");
        // normalization: H_A = B = C = 1 today
        let last = t.rows.last().unwrap();
        for (name, tol) in [("H_A", 1e-8), ("B", 1e-7), ("C", 1e-7)] {
            assert!((last[t.idx[name]] - 1.0).abs() < tol, "{tag}: {name}(1) = {}", last[t.idx[name]]);
        }
        eprintln!("{tag}: max constraint residual rel. 3 rho = {worst_rho:.2e}, rel. 3 H_A^2 = {worst_col:.2e}");
    }
}

#[test]
fn frozen_hidden_theorem() {
    // (a) radiation only: H_B = H_C = 0 to 1e-12
    let mut c = cfg(ModelKind::Fable8d);
    c.omega_b0 = 0.0;
    let t = run_csv("frozen_rad", &c, &Spec::NoFable);
    let worst = |t: &Csv| (0..t.rows.len()).map(|k| (t.col("H_B")[k].abs().max(t.col("H_C")[k].abs())) / t.col("H_A")[k]).fold(0.0f64, f64::max);
    assert!(worst(&t) < 1e-12, "radiation only: max |H_B|/H_A = {:e}", worst(&t));

    // (b) radiation + fable with W = (lam/2) sigma^2 (m0 = V0 = 0): F = 2W - sigma W' = 0 identically.
    // lam so large that the non-trivial branch exists for the whole run: lam g kF^2/(4 pi^2) > 1 at kF >= kF0 = 1.
    let lam = 100.0 * 4.0 * std::f64::consts::PI.powi(2) / 8.0;
    let pot = Potential::Quadratic { v0: 0.0, m0: 0.0, lam };
    for (tag, sel) in [("frozen_quad_lowest", Selection::Lowest), ("frozen_quad_positive", Selection::Positive)] {
        let mut c = cfg(ModelKind::Fable8d);
        c.omega_b0 = 0.0;
        c.sel = sel;
        let t = run_csv(tag, &c, &Spec::Direct { pot: pot.clone(), kf0: 1.0 });
        assert!(worst(&t) < 1e-12, "{tag}: max |H_B|/H_A = {:e}", worst(&t));
        let (m, fh, rho) = (t.col("m_eff"), t.col("F_hidden"), t.col("rho_f"));
        if sel == Selection::Positive {
            assert!(m.iter().all(|&x| x > 0.0), "{tag}: the non-trivial branch must have m > 0");
            let fmax = (0..fh.len()).map(|k| (fh[k] / rho[k]).abs()).fold(0.0f64, f64::max);
            assert!(fmax < 1e-10, "{tag}: F/rho = {fmax:e}");
        } else {
            // the ground state of W = (lam/2) sigma^2 is m = 0: the fable is radiation
            assert!(m.iter().all(|&x| x == 0.0), "{tag}: lowest branch should be massless");
        }
    }
    // the non-trivial branch has HIGHER energy than m = 0 at the same (n, v)
    let pos = run_csv("frozen_quad_positive_b", &{ let mut c = cfg(ModelKind::Fable4d); c.omega_b0 = 0.0; c.sel = Selection::Positive; c }, &Spec::Direct { pot: pot.clone(), kf0: 1.0 });
    let low = run_csv("frozen_quad_lowest_b", &{ let mut c = cfg(ModelKind::Fable4d); c.omega_b0 = 0.0; c }, &Spec::Direct { pot, kf0: 1.0 });
    let (rp, rl) = (pos.col("rho_f"), low.col("rho_f"));
    assert!((0..rp.len()).all(|k| rp[k] > rl[k]), "non-trivial branch must lie above m = 0");

    // (c) dust drives the hidden sheet: radiation + baryons, H_B, H_C > 0 (the hidden sheet EXPANDS
    // and G_4 = G_8/(B^3 C) DECREASES), F_hidden = rho_b > 0
    let t = run_csv("frozen_dust", &cfg(ModelKind::Fable8d), &Spec::NoFable);
    let last = t.rows.last().unwrap();
    assert!(last[t.idx["H_B"]] > 0.0 && last[t.idx["H_C"]] > 0.0 && last[t.idx["F_hidden"]] > 0.0);
    let g = t.col("G_ratio");
    assert!(g[0] > 1.0 && g.windows(2).all(|w| w[1] <= w[0] * (1.0 + 1e-12)), "G must decrease monotonically when dust drives the hidden sheet");
    // (d) the author's mass term drives it too: F = m0 sigma8 > 0
    let t = run_csv("frozen_mass", &cfg(ModelKind::Fable8d), &Spec::Mass { m0: ev(100.0) });
    let f = t.col("F_hidden");
    let hb = t.col("H_B");
    assert!(f.iter().all(|&x| x > 0.0) && *hb.last().unwrap() > 0.0);
}

#[test]
fn fable8d_with_hidden_frozen_by_hand_reproduces_fable4d() {
    for (tag, spec) in [("fz_lm1", Spec::LambdaMass { m0: ev(1.0), omega_dm: 0.265 }), ("fz_pw", Spec::Power { m_today: ev(1.0), nu: 0.236, omega_dm: 0.265 })] {
        let a = run_csv(&format!("{tag}_4d"), &cfg(ModelKind::Fable4d), &spec);
        let b = run_csv(&format!("{tag}_8f"), &{ let mut c = cfg(ModelKind::Fable8d); c.freeze_hidden = true; c }, &spec);
        let rho = a.col("rho_f");
        for name in ["H_A", "t", "w_f", "rho_f", "P_stab", "q_dec"] {
            let (x, y) = (a.col(name), b.col(name));
            // q_dec and P_stab cross zero: compare q absolutely, P_stab relative to rho_f
            let scale = |k: usize| match name {
                "q_dec" => 1.0,
                "P_stab" => rho[k].abs(),
                _ => x[k].abs().max(1e-300),
            };
            let worst = (0..x.len()).map(|k| (x[k] - y[k]).abs() / scale(k)).fold(0.0f64, f64::max);
            let tol = if name == "q_dec" { 1e-7 } else { 1e-8 };
            assert!(worst < tol, "{tag}: {name} differs by {worst:e}");
        }
        assert!(b.col("H_B").iter().all(|&x| x == 0.0));
    }
}

#[test]
fn backward_runs() {
    let u = Units::new();
    // fable8d backward is refused (design review E4)
    let c = Config::new(ModelKind::Fable8d, Direction::Backward, &u);
    assert!(run(&c, &Spec::Mass { m0: ev(1.0) }, &u).is_err());
    // fable4d backward = forward
    let spec = Spec::LambdaMass { m0: ev(30.0), omega_dm: 0.265 };
    let f = run_csv("bw_f", &cfg(ModelKind::Fable4d), &spec);
    let b = run_csv("bw_b", &Config::new(ModelKind::Fable4d, Direction::Backward, &u), &spec);
    let (hf, hb2, tf, tb) = (f.col("H_A"), b.col("H_A"), f.col("t"), b.col("t"));
    for k in 0..hf.len() {
        assert!((hf[k] - hb2[k]).abs() <= 1e-12 * hf[k], "H_A differs at row {k}");
        // the backward run integrates the age from today (lookback): its error is relative to t0,
        // ~1e-8/H0 absolute (measured, rtol = 1e-10, ~2000 steps), so early-time ages below
        // ~3e-8/H0 (~400 yr) are not resolved by a backward run; the forward run resolves them
        assert!((tf[k] - tb[k]).abs() <= 1e-8 * tf[k] + 3e-8, "t differs at row {k}: {} vs {}", tf[k], tb[k]);
    }
}

#[test]
fn physics_checks_along_runs() {
    // no phantom crossing: w_f >= -1 wherever rho_f > 0 (rho + P_obs = wF n/v >= 0)
    for (tag, spec) in [
        ("ph_pw", Spec::Power { m_today: ev(1.0), nu: 0.236, omega_dm: 0.265 }),
        ("ph_ed", Spec::ExpDamp { m_today: ev(1.0), xt: 1.0 / 2.21, omega_dm: 0.265 }),
        ("ph_qd", Spec::Quadratic { m_today: ev(1.0), gq: -0.5, omega_dm: 0.265 }),
    ] {
        let t = run_csv(tag, &cfg(ModelKind::Fable4d), &spec);
        let (w, r) = (t.col("w_f"), t.col("rho_f"));
        assert!((0..w.len()).all(|k| r[k] <= 0.0 || w[k] >= -1.0 - 1e-12), "{tag}: phantom w_f");
        // the Omegas sum to 1 in fable4d, and the vacuum-energy column vanishes today
        let os = t.col("Omega_sum");
        assert!(os.iter().all(|&x| (x - 1.0).abs() < 1e-13));
        assert!(t.col("vac_over_rhoc").last().unwrap().abs() < 1e-300 + 1e-15);
    }
    // W = m0 sigma alone: Einstein-de Sitter-like, q0 -> +1/2
    let t = run_csv("eds", &cfg(ModelKind::Fable4d), &Spec::Mass { m0: ev(100.0) });
    let q0 = *t.col("q_dec").last().unwrap();
    assert!((q0 - 0.5).abs() < 1e-3, "q0 = {q0}");
    assert!(t.comments.iter().any(|c| c.starts_with("params: model=fable4d")));
    // the repulsive quadratic has a first-order transition and is refused; lorentz has a negative-energy ground state
    let u = Units::new();
    let e = run(&cfg(ModelKind::Fable4d), &Spec::Quadratic { m_today: ev(1.0), gq: 0.5, omega_dm: 0.265 }, &u).err().unwrap();
    assert!(e.contains("gap-branch jump"), "{e}");
    let e = run(&cfg(ModelKind::Fable4d), &Spec::Lorentz { m_today: ev(1.0), xt: 1.0 / 1.5, omega_dm: 0.265 }, &u).err().unwrap();
    assert!(e.contains("negative energy"), "{e}");
}

#[test]
fn insensitivity_to_a_start() {
    // today's state of the forward fable8d BVP does not depend on a_start (deep in the radiation era)
    let spec = Spec::LambdaMass { m0: ev(30.0), omega_dm: 0.265 };
    let a = run_csv("as12", &cfg(ModelKind::Fable8d), &spec);
    let b = run_csv("as10", &{ let mut c = cfg(ModelKind::Fable8d); c.a_start = 1e-10; c.points = 1601; c }, &spec);
    let (la, lb) = (a.rows.last().unwrap(), b.rows.last().unwrap());
    for name in ["H_B", "rho_f", "q_dec", "rho_U"] {
        let (x, y) = (la[a.idx[name]], lb[b.idx[name]]);
        assert!((x - y).abs() < 1e-6 * x.abs(), "{name}: {x} vs {y}");
    }
}
