//! A thin driver over the vendored pure-Rust SUNDIALS 7.8.0 CVODE (BDF + Newton + dense linear
//! solver, or Adams), the integrator configuration rustSolveIt uses for its stiff problems.
//! Copied from fable_cosmo/src/cvode_driver.rs (unchanged API) and extended with the Jacobian
//! count and backward integration (x1 < x0).
//!
//! `integrate` advances `y' = f(x, y)` from `x0` to `x1` and returns the state at `points`
//! equally spaced output values of `x` (the first is the initial condition).  The right-hand
//! side receives its parameters through CVODE's `user_data` box.

#![allow(non_snake_case)]

use std::any::Any;

use cvode_rs::prelude::*;

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

fn read_vec(v: &N_Vector) -> Vec<f64> {
    N_VGetArrayPointer(v).expect("N_VGetArrayPointer").to_vec()
}

/// Integrate with CVODE (BDF unless `adams`).  `rtol`, `atol` are the scalar tolerances.
/// `max_steps` bounds the internal steps per output interval.
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
    if points < 2 {
        return Err("integrate: at least 2 output points".into());
    }
    let n = y0.len() as sunindextype;
    let mut sunctx: Option<SUNContext> = None;
    if SUNContext_Create(SUN_COMM_NULL, &mut sunctx) != 0 {
        return Err("SUNContext_Create failed".into());
    }
    let ctx = sunctx.ok_or("SUNContext_Create returned None")?;

    let y = N_VNew_Serial(n, &ctx).ok_or("N_VNew_Serial returned None")?;
    {
        let mut d = N_VGetArrayPointer(&y).ok_or("N_VGetArrayPointer failed")?;
        d.copy_from_slice(y0);
    }

    let cv = CVodeCreate(if adams { CV_ADAMS } else { CV_BDF }, &ctx).ok_or("CVodeCreate returned None")?;
    let mut flag = CVodeInit(&cv, rhs, x0, &y);
    if flag != 0 {
        return Err(format!("CVodeInit failed: {flag}"));
    }
    flag = CVodeSStolerances(&cv, rtol, atol);
    if flag != 0 {
        return Err(format!("CVodeSStolerances failed: {flag}"));
    }
    let a_mat = SUNDenseMatrix(n, n, &ctx).ok_or("SUNDenseMatrix returned None")?;
    let ls = SUNLinSol_Dense(&y, &a_mat, &ctx).ok_or("SUNLinSol_Dense returned None")?;
    flag = CVodeSetLinearSolver(&cv, &ls, Some(&a_mat));
    if flag != 0 {
        return Err(format!("CVodeSetLinearSolver failed: {flag}"));
    }
    flag = CVodeSetUserData(&cv, Some(user_data));
    if flag != 0 {
        return Err(format!("CVodeSetUserData failed: {flag}"));
    }
    flag = CVodeSetMaxNumSteps(&cv, max_steps);
    if flag != 0 {
        return Err(format!("CVodeSetMaxNumSteps failed: {flag}"));
    }
    flag = CVodeSetStopTime(&cv, x1);
    if flag != 0 {
        return Err(format!("CVodeSetStopTime failed: {flag}"));
    }

    let mut xs = Vec::with_capacity(points);
    let mut ys = Vec::with_capacity(points);
    xs.push(x0);
    ys.push(y0.to_vec());
    let mut t = x0;
    for k in 1..points {
        let xout = if k == points - 1 { x1 } else { x0 + (x1 - x0) * (k as f64) / ((points - 1) as f64) };
        let cflag = CVode(&cv, xout, &y, &mut t, CV_NORMAL);
        if cflag < 0 {
            return Err(format!("CVode failed with flag {cflag} at x = {t}"));
        }
        xs.push(t);
        ys.push(read_vec(&y));
    }

    let mut st = Stats::default();
    let mut s: i64 = 0;
    if CVodeGetNumSteps(&cv, &mut s) == 0 {
        st.steps = s;
    }
    if CVodeGetNumRhsEvals(&cv, &mut s) == 0 {
        st.rhs_evals = s;
    }
    if CVodeGetNumNonlinSolvIters(&cv, &mut s) == 0 {
        st.nonlin_iters = s;
    }
    if CVodeGetNumErrTestFails(&cv, &mut s) == 0 {
        st.err_test_fails = s;
    }
    if CVodeGetNumJacEvals(&cv, &mut s) == 0 {
        st.jac_evals = s;
    }
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
