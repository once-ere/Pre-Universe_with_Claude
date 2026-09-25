//! A thin driver over the vendored pure-Rust SUNDIALS 7.8.0 CVODE (BDF + Newton + dense linear
//! solver, or Adams), the integrator configuration rustSolveIt uses for its stiff problems.
//! Copied from fable_cosmo/src/cvode_driver.rs (unchanged API) and extended with the Jacobian
//! count and backward integration (x1 < x0).
//!
//! `integrate` advances `y' = f(x, y)` from `x0` to `x1` and returns the state at `points`
//! equally spaced output values of `x` (the first is the initial condition).  The right-hand
//! side receives its parameters through CVODE's `user_data` box.
//!
//! `integrate_detailed` is the same integration, but a failure returns a `Failure`: CVODE's flag
//! and message, the last SUCCESSFUL internal step (x, y) (CVODE returns y(t_n) at t_n on every
//! failure), and the `user_data` box handed back, so that the caller can read what the
//! right-hand side recorded before it returned an error code (models::RhsData).  CVODE's own error
//! messages are captured into the failure message instead of being printed on stderr, so that a
//! refused run ends with exactly one line of reason (the "t + h = t" warnings still go to stderr).

#![allow(non_snake_case)]

use std::any::Any;
use std::cell::RefCell;
use std::rc::Rc;

use cvode_rs::prelude::*;
use cvode_rs::sundials_context::{SUNContext_ClearErrHandlers, SUNContext_PushErrHandler};

/// Integration statistics, printed to stderr by the command-line tool.
#[derive(Clone, Copy, Debug, Default)]
pub struct Stats {
    pub steps: i64,
    pub rhs_evals: i64,
    pub nonlin_iters: i64,
    pub err_test_fails: i64,
    pub jac_evals: i64,
}

impl Stats {
    pub fn add(&mut self, o: &Stats) {
        self.steps += o.steps;
        self.rhs_evals += o.rhs_evals;
        self.nonlin_iters += o.nonlin_iters;
        self.err_test_fails += o.err_test_fails;
        self.jac_evals += o.jac_evals;
    }
}

/// Output of one integration: the output abscissae and the state at each.
pub struct Trajectory {
    pub x: Vec<f64>,
    pub y: Vec<Vec<f64>>,
    pub stats: Stats,
}

/// The minimum step of every integration, in units of eps max(|x0|, |x1|, 1) (see
/// `integrate_detailed`).
pub const HMIN_ULPS: f64 = 64.0;

/// A failed integration (see the module documentation).
pub struct Failure {
    /// CVODE's return flag (negative), or 0 for a set-up error
    pub flag: i32,
    /// one line: the flag, its name, where, and CVODE's own message
    pub message: String,
    /// the last successful internal step: x and y(x)
    pub x_good: f64,
    pub y_good: Vec<f64>,
    /// the user data box, handed back by CVODE (None for a set-up error)
    pub user_data: Option<Box<dyn Any>>,
    pub stats: Stats,
}

impl Failure {
    fn setup(msg: String, x0: f64, y0: &[f64]) -> Box<Failure> {
        Box::new(Failure { flag: 0, message: msg, x_good: x0, y_good: y0.to_vec(), user_data: None, stats: Stats::default() })
    }
}

fn read_vec(v: &N_Vector) -> Vec<f64> {
    N_VGetArrayPointer(v).expect("N_VGetArrayPointer").to_vec()
}

fn collect_stats(cv: &CVodeMem) -> Stats {
    let mut st = Stats::default();
    let mut s: i64 = 0;
    if CVodeGetNumSteps(cv, &mut s) == 0 {
        st.steps = s;
    }
    if CVodeGetNumRhsEvals(cv, &mut s) == 0 {
        st.rhs_evals = s;
    }
    if CVodeGetNumNonlinSolvIters(cv, &mut s) == 0 {
        st.nonlin_iters = s;
    }
    if CVodeGetNumErrTestFails(cv, &mut s) == 0 {
        st.err_test_fails = s;
    }
    if CVodeGetNumJacEvals(cv, &mut s) == 0 {
        st.jac_evals = s;
    }
    st
}

/// The SUNDIALS error handler of `integrate_detailed`: CVODE's error messages are appended to a
/// shared buffer (the handler's user data) instead of being printed.
fn capture_err_handler(_line: i32, func: &str, _file: &str, msg: &str, err_code: i32, data: &mut Option<Box<dyn Any>>, _ctx: &SUNContext) {
    if let Some(buf) = data.as_ref().and_then(|b| b.downcast_ref::<Rc<RefCell<Vec<String>>>>()) {
        buf.borrow_mut().push(format!("[{func}, code {err_code}] {msg}"));
    }
}

/// Integrate with CVODE (BDF unless `adams`).  `rtol`, `atol` are the scalar tolerances.
/// `max_steps` bounds the internal steps per output interval.  A failure is reported as its
/// one-line message (use `integrate_detailed` for the last good step and the user data).
#[allow(clippy::too_many_arguments)]
pub fn integrate(
    adams: bool,
    rhs: CVRhsFn,
    user_data: Box<dyn Any>,
    y0: &[f64],
    x0: f64,
    x1: f64,
    points: usize,
    rtol: f64,
    atol: f64,
    max_steps: i64,
) -> Result<Trajectory, String> {
    integrate_detailed(adams, rhs, user_data, y0, x0, x1, points, rtol, atol, max_steps).map_err(|f| f.message)
}

/// `integrate`, returning a `Failure` (last good internal step, user data) when CVODE fails.
#[allow(clippy::too_many_arguments)]
pub fn integrate_detailed(
    adams: bool,
    rhs: CVRhsFn,
    user_data: Box<dyn Any>,
    y0: &[f64],
    x0: f64,
    x1: f64,
    points: usize,
    rtol: f64,
    atol: f64,
    max_steps: i64,
) -> Result<Trajectory, Box<Failure>> {
    let setup = |m: String| Failure::setup(m, x0, y0);
    if points < 2 {
        return Err(setup("integrate: at least 2 output points".into()));
    }
    let n = y0.len() as sunindextype;
    let mut sunctx: Option<SUNContext> = None;
    if SUNContext_Create(SUN_COMM_NULL, &mut sunctx) != 0 {
        return Err(setup("SUNContext_Create failed".into()));
    }
    let ctx = sunctx.ok_or_else(|| setup("SUNContext_Create returned None".into()))?;
    let errors: Rc<RefCell<Vec<String>>> = Rc::new(RefCell::new(Vec::new()));
    SUNContext_ClearErrHandlers(&ctx);
    SUNContext_PushErrHandler(&ctx, capture_err_handler, Some(Box::new(errors.clone())));

    let y = N_VNew_Serial(n, &ctx).ok_or_else(|| setup("N_VNew_Serial returned None".into()))?;
    {
        let mut d = N_VGetArrayPointer(&y).ok_or_else(|| setup("N_VGetArrayPointer failed".into()))?;
        d.copy_from_slice(y0);
    }

    let cv = CVodeCreate(if adams { CV_ADAMS } else { CV_BDF }, &ctx).ok_or_else(|| setup("CVodeCreate returned None".into()))?;
    let check = |flag: i32, what: &str| -> Result<(), Box<Failure>> {
        if flag != 0 {
            Err(setup(format!("{what} failed: {flag} {}", errors.borrow().join("; "))))
        } else {
            Ok(())
        }
    };
    check(CVodeInit(&cv, rhs, x0, &y), "CVodeInit")?;
    check(CVodeSStolerances(&cv, rtol, atol), "CVodeSStolerances")?;
    let a_mat = SUNDenseMatrix(n, n, &ctx).ok_or_else(|| setup("SUNDenseMatrix returned None".into()))?;
    let ls = SUNLinSol_Dense(&y, &a_mat, &ctx).ok_or_else(|| setup("SUNLinSol_Dense returned None".into()))?;
    check(CVodeSetLinearSolver(&cv, &ls, Some(&a_mat)), "CVodeSetLinearSolver")?;
    check(CVodeSetUserData(&cv, Some(user_data)), "CVodeSetUserData")?;
    check(CVodeSetMaxNumSteps(&cv, max_steps), "CVodeSetMaxNumSteps")?;
    check(CVodeSetStopTime(&cv, x1), "CVodeSetStopTime")?;
    // A minimum step just above the round-off of x (64 eps max(|x0|, |x1|, 1), ~4e-13 for
    // a_start = 1e-12): inactive in every successful run (CVODE only clamps with it, and the
    // clamps are max(eta, hmin/|h|) = eta while |h| >> hmin), it ends an integration that crawls
    // towards a singular point (H_A -> 0: d/dN = (1/H_A) d/dt) instead of letting it take
    // max_steps steps of t + h = t there.
    check(CVodeSetMinStep(&cv, HMIN_ULPS * f64::EPSILON * x0.abs().max(x1.abs()).max(1.0)), "CVodeSetMinStep")?;

    let mut xs = Vec::with_capacity(points);
    let mut ys = Vec::with_capacity(points);
    xs.push(x0);
    ys.push(y0.to_vec());
    let mut t = x0;
    for k in 1..points {
        let xout = if k == points - 1 { x1 } else { x0 + (x1 - x0) * (k as f64) / ((points - 1) as f64) };
        let cflag = CVode(&cv, xout, &y, &mut t, CV_NORMAL);
        if cflag < 0 {
            // CVODE returns t = t_n and y = y(t_n), the last successful internal step
            let mut ud: Option<Box<dyn Any>> = None;
            CVodeGetUserData(&cv, &mut ud);
            let stats = collect_stats(&cv);
            let msgs = errors.borrow().join("; ");
            let message = format!("CVode failed with flag {cflag} ({}) at x = {t}{}", CVodeGetReturnFlagName(cflag as i64), if msgs.is_empty() { String::new() } else { format!(": {msgs}") });
            let failure = Failure { flag: cflag, message, x_good: t, y_good: read_vec(&y), user_data: ud, stats };
            let mut cv_opt = Some(cv);
            CVodeFree(&mut cv_opt);
            return Err(Box::new(failure));
        }
        xs.push(t);
        ys.push(read_vec(&y));
    }

    let st = collect_stats(&cv);
    let mut cv_opt = Some(cv);
    CVodeFree(&mut cv_opt);
    Ok(Trajectory { x: xs, y: ys, stats: st })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn decay(_x: f64, y: &N_Vector, ydot: &N_Vector, ud: &mut Option<Box<dyn Any>>) -> i32 {
        let k = *ud.as_ref().and_then(|b| b.downcast_ref::<f64>()).unwrap_or(&1.0);
        let yv = N_VGetArrayPointer(y).unwrap();
        let mut yd = N_VGetArrayPointer(ydot).unwrap();
        yd[0] = -k * yv[0];
        0
    }

    #[test]
    fn exponential_decay_forward_and_backward() {
        let tr = integrate(false, decay, Box::new(1.5f64), &[2.0], 0.0, 3.0, 4, 1e-10, 1e-12, 100000).unwrap();
        for (x, y) in tr.x.iter().zip(tr.y.iter()) {
            let exact = 2.0 * (-1.5 * x).exp();
            assert!((y[0] - exact).abs() < 1e-8 * exact, "x={x}: {} vs {exact}", y[0]);
        }
        // backward: from x = 3 to x = 0 recovers 2
        let yb = 2.0 * (-4.5f64).exp();
        let tb = integrate(false, decay, Box::new(1.5f64), &[yb], 3.0, 0.0, 4, 1e-10, 1e-14, 100000).unwrap();
        assert!((tb.x[3] - 0.0).abs() < 1e-15 && (tb.y[3][0] - 2.0).abs() < 1e-8, "backward: {:?}", tb.y[3]);
        assert!(tr.stats.steps > 0 && tr.stats.rhs_evals > 0);
    }
}
