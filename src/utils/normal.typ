///! Inverse standard-normal CDF using Acklam's rational approximation.
///!
///! Provides @qnorm with about 1.15e-9 accuracy across the open interval
///! `(0, 1)`. Inlined so the helper has no external dependencies.

#let _qnorm-acklam(p) = {
  let a = (
    -3.969683028665376e+01,
    2.209460984245205e+02,
    -2.759285104469687e+02,
    1.383577518672690e+02,
    -3.066479806614716e+01,
    2.506628277459239e+00,
  )
  let b = (
    -5.447609879822406e+01,
    1.615858368580409e+02,
    -1.556989798598866e+02,
    6.680131188771972e+01,
    -1.328068155288572e+01,
  )
  let c = (
    -7.784894002430293e-03,
    -3.223964580411365e-01,
    -2.400758277161838e+00,
    -2.549732539343734e+00,
    4.374664141464968e+00,
    2.938163982698783e+00,
  )
  let d = (
    7.784695709041462e-03,
    3.224671290700398e-01,
    2.445134137142996e+00,
    3.754408661907416e+00,
  )
  let p-low = 0.02425
  let p-high = 1 - p-low
  if p < p-low {
    let qq = calc.sqrt(-2 * calc.ln(p))
    (
      (
        (
          (((c.at(0) * qq + c.at(1)) * qq + c.at(2)) * qq + c.at(3)) * qq
            + c.at(4)
        )
          * qq
          + c.at(5)
      )
        / ((((d.at(0) * qq + d.at(1)) * qq + d.at(2)) * qq + d.at(3)) * qq + 1)
    )
  } else if p <= p-high {
    let qq = p - 0.5
    let r = qq * qq
    (
      (
        ((((a.at(0) * r + a.at(1)) * r + a.at(2)) * r + a.at(3)) * r + a.at(4))
          * r
          + a.at(5)
      )
        * qq
        / (
          (
            (((b.at(0) * r + b.at(1)) * r + b.at(2)) * r + b.at(3)) * r
              + b.at(4)
          )
            * r
            + 1
        )
    )
  } else {
    let qq = calc.sqrt(-2 * calc.ln(1 - p))
    (
      -(
        (
          (((c.at(0) * qq + c.at(1)) * qq + c.at(2)) * qq + c.at(3)) * qq
            + c.at(4)
        )
          * qq
          + c.at(5)
      )
        / ((((d.at(0) * qq + d.at(1)) * qq + d.at(2)) * qq + d.at(3)) * qq + 1)
    )
  }
}

/// Inverse standard-normal cumulative distribution function.
///
/// Returns the standard-normal quantile for probability `p` using Acklam's
/// rational approximation, accurate to about 1.15e-9 across `(0, 1)`. Out of
/// range inputs panic so callers do not silently receive `±infinity`.
///
/// @category Stats
/// @stability stable
/// @since 0.0.1
///
/// @param p Probability in the open interval `(0, 1)`.
///
/// @returns Numeric standard-normal quantile.
#let qnorm(p) = {
  if p <= 0 or p >= 1 { panic("qnorm: p must be in (0, 1)") }
  _qnorm-acklam(p)
}
