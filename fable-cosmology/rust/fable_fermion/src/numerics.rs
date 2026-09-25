//! Two small numerical tools: Brent's bracketed root finder (Brent 1973, "zeroin": inverse
//! quadratic interpolation and secant steps, safeguarded by bisection, so it never leaves the
//! bracket and converges superlinearly) and an adaptive Gauss-Kronrod (7, 15) quadrature with the
//! QUADPACK error estimate (Piessens et al. 1983, QAG), used by the tests as the independent
//! reference for the closed-form Fermi integrals.

/// Find a zero of `f` in `[a, b]`, `f(a) f(b) <= 0` required.  Terminates when the bracket is
/// narrower than `2 eps |x| + xtol_abs` or `f` vanishes exactly.  Returns the root and the number
/// of function evaluations.
pub fn brent<F: FnMut(f64) -> f64>(mut f: F, a0: f64, b0: f64, xtol_abs: f64, max_iter: usize) -> Result<(f64, usize), String> {
    let (mut a, mut b) = (a0, b0);
    let mut fa = f(a);
    let mut fb = f(b);
    let mut evals = 2usize;
    if !(fa.is_finite() && fb.is_finite()) {
        return Err(format!("brent: non-finite function value at the bracket ends f({a}) = {fa}, f({b}) = {fb}"));
    }
    if fa == 0.0 {
        return Ok((a, evals));
    }
    if fb == 0.0 {
        return Ok((b, evals));
    }
    if (fa > 0.0) == (fb > 0.0) {
        return Err(format!("brent: [{a}, {b}] does not bracket a root: f = {fa}, {fb}"));
    }
    let (mut c, mut fc) = (a, fa);
    let mut d = b - a;
    let mut e = d;
    for _ in 0..max_iter {
        if (fb > 0.0) == (fc > 0.0) {
            c = a;
            fc = fa;
            d = b - a;
            e = d;
        }
        if fc.abs() < fb.abs() {
            a = b;
            b = c;
            c = a;
            fa = fb;
            fb = fc;
            fc = fa;
        }
        let tol = 2.0 * f64::EPSILON * b.abs() + 0.5 * xtol_abs;
        let xm = 0.5 * (c - b);
        if xm.abs() <= tol || fb == 0.0 {
            return Ok((b, evals));
        }
        if e.abs() >= tol && fa.abs() > fb.abs() {
            let s = fb / fa;
            let (mut p, mut q);
            if a == c {
                p = 2.0 * xm * s;
                q = 1.0 - s;
            } else {
                let qq = fa / fc;
                let r = fb / fc;
                p = s * (2.0 * xm * qq * (qq - r) - (b - a) * (r - 1.0));
                q = (qq - 1.0) * (r - 1.0) * (s - 1.0);
            }
            if p > 0.0 {
                q = -q;
            } else {
                p = -p;
            }
            let min1 = 3.0 * xm * q - (tol * q).abs();
            let min2 = (e * q).abs();
            if 2.0 * p < min1.min(min2) {
                e = d;
                d = p / q;
            } else {
                d = xm;
                e = d;
            }
        } else {
            d = xm;
            e = d;
        }
        a = b;
        fa = fb;
        b += if d.abs() > tol { d } else { tol.copysign(xm) };
        fb = f(b);
        evals += 1;
        if !fb.is_finite() {
            return Err(format!("brent: non-finite function value f({b}) = {fb}"));
        }
    }
    Err(format!("brent: no convergence in {max_iter} iterations (bracket [{b}, {c}])"))
}

// ------------------------------------------------------------------ Gauss-Kronrod (7, 15)

const XGK: [f64; 8] = [
    0.991_455_371_120_812_639_206_854_697_526_329,
    0.949_107_912_342_758_524_526_189_684_047_851,
    0.864_864_423_359_769_072_789_712_788_640_926,
    0.741_531_185_599_394_439_863_864_773_280_788,
    0.586_087_235_467_691_130_294_144_845_693_013,
    0.405_845_151_377_397_166_906_606_412_076_961,
    0.207_784_955_007_898_467_600_689_403_773_245,
    0.0,
];
const WGK: [f64; 8] = [
    0.022_935_322_010_529_224_963_732_008_058_970,
    0.063_092_092_629_978_553_290_700_663_189_204,
    0.104_790_010_322_250_183_839_876_322_541_518,
    0.140_653_259_715_525_918_745_189_590_510_238,
    0.169_004_726_639_267_902_826_583_426_598_550,
    0.190_350_578_064_785_409_913_256_402_421_014,
    0.204_432_940_075_298_892_414_161_999_234_649,
    0.209_482_141_084_727_828_012_999_174_891_714,
];
const WG: [f64; 4] = [
    0.129_484_966_168_869_693_270_611_432_679_082,
    0.279_705_391_489_276_667_901_467_771_423_780,
    0.381_830_050_505_118_944_950_369_775_488_975,
    0.417_959_183_673_469_387_755_102_040_816_327,
];

/// One 15-point Kronrod rule on [a, b]: (integral, QUADPACK error estimate).
fn qk15<F: Fn(f64) -> f64>(f: &F, a: f64, b: f64) -> (f64, f64) {
    let centr = 0.5 * (a + b);
    let hlgth = 0.5 * (b - a);
    let dhlgth = hlgth.abs();
    let fc = f(centr);
    let mut resg = fc * WG[3];
    let mut resk = fc * WGK[7];
    let mut resabs = resk.abs();
    let mut fv1 = [0.0; 7];
    let mut fv2 = [0.0; 7];
    for j in 0..3 {
        let jtw = 2 * j + 1;
        let absc = hlgth * XGK[jtw];
        let f1 = f(centr - absc);
        let f2 = f(centr + absc);
        fv1[jtw] = f1;
        fv2[jtw] = f2;
        resg += WG[j] * (f1 + f2);
        resk += WGK[jtw] * (f1 + f2);
        resabs += WGK[jtw] * (f1.abs() + f2.abs());
    }
    for j in 0..4 {
        let jtwm1 = 2 * j;
        let absc = hlgth * XGK[jtwm1];
        let f1 = f(centr - absc);
        let f2 = f(centr + absc);
        fv1[jtwm1] = f1;
        fv2[jtwm1] = f2;
        resk += WGK[jtwm1] * (f1 + f2);
        resabs += WGK[jtwm1] * (f1.abs() + f2.abs());
    }
    let reskh = resk * 0.5;
    let mut resasc = WGK[7] * (fc - reskh).abs();
    for j in 0..7 {
        resasc += WGK[j] * ((fv1[j] - reskh).abs() + (fv2[j] - reskh).abs());
    }
    let result = resk * hlgth;
    resabs *= dhlgth;
    resasc *= dhlgth;
    let mut abserr = ((resk - resg) * hlgth).abs();
    if resasc != 0.0 && abserr != 0.0 {
        abserr = resasc * (1.0f64).min((200.0 * abserr / resasc).powf(1.5));
    }
    let uflow = f64::MIN_POSITIVE;
    if resabs > uflow / (50.0 * f64::EPSILON) {
        abserr = abserr.max(50.0 * f64::EPSILON * resabs);
    }
    (result, abserr)
}

/// Globally adaptive Gauss-Kronrod quadrature of `f` over `[a, b]` with the given interior
/// breakpoints: bisect the subinterval with the largest error estimate until the summed estimate
/// is below `max(epsabs, epsrel |I|)`.  Returns (integral, error estimate).
pub fn integrate_gk<F: Fn(f64) -> f64>(f: F, a: f64, b: f64, breakpoints: &[f64], epsabs: f64, epsrel: f64, max_intervals: usize) -> (f64, f64) {
    let mut pts = vec![a];
    for &p in breakpoints {
        if p > a && p < b {
            pts.push(p);
        }
    }
    pts.push(b);
    pts.sort_by(|x, y| x.partial_cmp(y).unwrap());
    let mut ivs: Vec<(f64, f64, f64, f64)> = Vec::new();
    for w in pts.windows(2) {
        let (r, e) = qk15(&f, w[0], w[1]);
        ivs.push((w[0], w[1], r, e));
    }
    loop {
        let total: f64 = ivs.iter().map(|iv| iv.2).sum();
        let err: f64 = ivs.iter().map(|iv| iv.3).sum();
        if err <= epsabs.max(epsrel * total.abs()) || ivs.len() >= max_intervals {
            return (total, err);
        }
        // split the worst interval
        let (k, _) = ivs.iter().enumerate().fold((0usize, -1.0f64), |acc, (i, iv)| if iv.3 > acc.1 { (i, iv.3) } else { acc });
        let (lo, hi, _, _) = ivs[k];
        let mid = 0.5 * (lo + hi);
        if !(mid > lo && mid < hi) {
            return (total, err);
        }
        let (r1, e1) = qk15(&f, lo, mid);
        let (r2, e2) = qk15(&f, mid, hi);
        ivs[k] = (lo, mid, r1, e1);
        ivs.push((mid, hi, r2, e2));
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn brent_finds_simple_roots() {
        let (r, _) = brent(|x| x * x - 2.0, 0.0, 2.0, 0.0, 200).unwrap();
        assert!((r - 2f64.sqrt()).abs() < 4e-16);
        let (r, _) = brent(|x| x.cos() - x, 0.0, 1.0, 0.0, 200).unwrap();
        assert!((r - 0.739_085_133_215_160_6).abs() < 1e-15);
        assert!(brent(|x| x * x + 1.0, -1.0, 1.0, 0.0, 200).is_err());
    }

    #[test]
    fn gauss_kronrod_is_exact_on_smooth_functions() {
        let (r, _) = integrate_gk(|x| x.exp(), 0.0, 1.0, &[], 0.0, 1e-15, 1000);
        assert!((r - (1f64.exp() - 1.0)).abs() < 1e-14);
        let (r, _) = integrate_gk(|x| 1.0 / (1.0 + x * x), 0.0, 1e3, &[1.0], 0.0, 1e-14, 1000);
        assert!((r - 1e3f64.atan()).abs() < 1e-13);
        let (r, _) = integrate_gk(|x| x.powi(7), -1.0, 2.0, &[], 0.0, 1e-15, 1000);
        assert!((r - (256.0 - 1.0) / 8.0).abs() < 1e-13);
    }
}
