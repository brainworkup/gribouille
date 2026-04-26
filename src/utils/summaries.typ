///! Summary helpers: ggplot2's `mean_*` and `median_hilow` family.
///!
///! Each helper accepts an array of numbers and returns a dict
///! `(y: <central>, ymin: <low>, ymax: <high>)`. Empty or all-`none` inputs
///! collapse to `(y: none, ymin: none, ymax: none)` so the caller can decide
///! how to handle missing buckets.

#import "types.typ": parse-number
#import "normal.typ": qnorm

#let _to-numeric(values) = {
  values.map(v => parse-number(v)).filter(v => v != none)
}

#let _empty-summary = (y: none, ymin: none, ymax: none)

#let _sum(xs) = {
  let acc = 0.0
  for v in xs { acc = acc + v }
  acc
}

#let _mean(xs) = _sum(xs) / xs.len()

// Sample standard deviation (Bessel's correction, divisor n - 1). Returns
// 0 when the sample has a single observation.
#let _sd(xs) = {
  let n = xs.len()
  if n < 2 { return 0.0 }
  let m = _mean(xs)
  let ss = _sum(xs.map(v => (v - m) * (v - m)))
  calc.sqrt(ss / (n - 1))
}

// Linear-interpolation quantile (R type 7) on a sorted array. Mirrors the
// helper used in `src/stat/boxplot.typ` so summaries here stay consistent
// with the boxplot statistic.
#let _quantile(sorted, q) = {
  let n = sorted.len()
  if n == 0 { return none }
  if n == 1 { return sorted.at(0) }
  let pos = q * (n - 1)
  let lo = int(calc.floor(pos))
  let hi = int(calc.ceil(pos))
  if lo == hi { return sorted.at(lo) }
  let frac = pos - lo
  sorted.at(lo) * (1 - frac) + sorted.at(hi) * frac
}

/// Mean and standard-error band: `mean ± mult * se`.
///
/// `se = sd / sqrt(n)` using the sample standard deviation. Returns
/// `(y: <mean>, ymin: <mean - mult * se>, ymax: <mean + mult * se>)`.
///
/// @category Stats
/// @stability stable
/// @since 0.0.1
///
/// @param values Array of numbers; non-numeric entries are dropped.
/// @param mult Multiplier on the standard error.
///
/// @returns Dict `(y, ymin, ymax)`; all-`none` if `values` has no numerics.
#let mean-se(values, mult: 1) = {
  let xs = _to-numeric(values)
  let n = xs.len()
  if n == 0 { return _empty-summary }
  let m = _mean(xs)
  let se = if n < 2 { 0.0 } else { _sd(xs) / calc.sqrt(n) }
  (y: m, ymin: m - mult * se, ymax: m + mult * se)
}

/// Mean with normal-approximation confidence interval.
///
/// The two-sided z critical value `qnorm((1 + conf) / 2)` is computed from
/// Acklam's inverse-normal approximation, so any `conf` in the open interval
/// `(0, 1)` is supported.
///
/// @category Stats
/// @stability stable
/// @since 0.0.1
///
/// @param values Array of numbers; non-numeric entries are dropped.
/// @param conf Confidence level in the open interval `(0, 1)`.
///
/// @returns Dict `(y, ymin, ymax)`; all-`none` if `values` has no numerics.
#let mean-cl-normal(values, conf: 0.95) = {
  if conf <= 0 or conf >= 1 {
    panic("mean-cl-normal: conf must be in (0, 1); got " + repr(conf))
  }
  let xs = _to-numeric(values)
  let n = xs.len()
  if n == 0 { return _empty-summary }
  let m = _mean(xs)
  let se = if n < 2 { 0.0 } else { _sd(xs) / calc.sqrt(n) }
  let z = qnorm((1 + conf) / 2)
  (y: m, ymin: m - z * se, ymax: m + z * se)
}

/// Mean and standard-deviation band: `mean ± mult * sd`.
///
/// @category Stats
/// @stability stable
/// @since 0.0.1
///
/// @param values Array of numbers; non-numeric entries are dropped.
/// @param mult Multiplier on the sample standard deviation.
///
/// @returns Dict `(y, ymin, ymax)`; all-`none` if `values` has no numerics.
#let mean-sdl(values, mult: 2) = {
  let xs = _to-numeric(values)
  if xs.len() == 0 { return _empty-summary }
  let m = _mean(xs)
  let s = _sd(xs)
  (y: m, ymin: m - mult * s, ymax: m + mult * s)
}

/// Median plus a central interval covering `conf` proportion of the data.
///
/// Quantiles use the type-7 / numpy default linear interpolation rule, the
/// same convention as `src/stat/boxplot.typ`. The default `conf: 0.5`
/// returns the median with the IQR (25th to 75th percentile).
///
/// @category Stats
/// @stability stable
/// @since 0.0.1
///
/// @param values Array of numbers; non-numeric entries are dropped.
/// @param conf Proportion of the data covered by the interval, in `(0, 1)`.
///
/// @returns Dict `(y, ymin, ymax)`; all-`none` if `values` has no numerics.
#let median-hilow(values, conf: 0.5) = {
  if conf <= 0 or conf >= 1 {
    panic("median-hilow: conf must be in (0, 1); got " + repr(conf))
  }
  let xs = _to-numeric(values)
  if xs.len() == 0 { return _empty-summary }
  let sorted = xs.sorted()
  let tail = (1 - conf) / 2
  (
    y: _quantile(sorted, 0.5),
    ymin: _quantile(sorted, tail),
    ymax: _quantile(sorted, 1 - tail),
  )
}

// Deterministic pseudo-random in [0, 1) seeded by an integer index. Uses the
// same sin-fract noise trick as `position-jitter` so bootstrap resamples are
// reproducible across renders without any RNG state.
#let _rand01(seed) = {
  let v = calc.sin(seed * 12.9898 + 78.233) * 43758.5453
  v - calc.floor(v)
}

/// Mean with a bootstrap percentile confidence interval.
///
/// Resamples `values` with replacement `n-boot` times, computes the bootstrap
/// mean for each resample, and returns the requested central percentiles of
/// the bootstrap distribution. The resampling indices are drawn from a
/// deterministic noise sequence seeded by `seed`, so identical inputs always
/// produce identical bounds.
///
/// @category Stats
/// @stability stable
/// @since 0.0.1
///
/// @param values Array of numbers; non-numeric entries are dropped.
/// @param conf Confidence level in the open interval `(0, 1)`.
/// @param n-boot Number of bootstrap resamples.
/// @param seed Integer seed for the deterministic resampling sequence.
///
/// @returns Dict `(y, ymin, ymax)`; all-`none` if `values` has no numerics.
#let mean-cl-boot(values, conf: 0.95, n-boot: 1000, seed: 0) = {
  if conf <= 0 or conf >= 1 {
    panic("mean-cl-boot: conf must be in (0, 1); got " + repr(conf))
  }
  let xs = _to-numeric(values)
  let n = xs.len()
  if n == 0 { return _empty-summary }
  let m = _mean(xs)
  if n < 2 { return (y: m, ymin: m, ymax: m) }
  let nb = calc.max(1, int(n-boot))
  let means = ()
  for b in range(0, nb) {
    let acc = 0.0
    for j in range(0, n) {
      let r = _rand01(seed + b * 100003 + j * 1009)
      let raw = int(calc.floor(r * n))
      let idx = if raw >= n { n - 1 } else if raw < 0 { 0 } else { raw }
      acc = acc + xs.at(idx)
    }
    means.push(acc / n)
  }
  let sorted = means.sorted()
  let tail = (1 - conf) / 2
  (
    y: m,
    ymin: _quantile(sorted, tail),
    ymax: _quantile(sorted, 1 - tail),
  )
}

/// Look up a summary helper by ggplot2-style name.
///
/// Accepts both the ggplot2 underscore form (`"mean_se"`) and the kebab form
/// (`"mean-se"`) used elsewhere in Gribouille. Unknown names panic.
///
/// @category Stats
/// @stability stable
/// @since 0.0.1
///
/// @param name Summary helper name.
/// @param values Array of numbers; non-numeric entries are dropped.
/// @param fun-args Keyword arguments forwarded to the helper.
///
/// @returns Dict `(y, ymin, ymax)`.
#let summarise(name, values, fun-args: (:)) = {
  let key = name.replace("_", "-")
  if key == "mean-se" {
    let mult = fun-args.at("mult", default: 1)
    return mean-se(values, mult: mult)
  } else if key == "mean-cl-normal" {
    let conf = fun-args.at("conf", default: 0.95)
    return mean-cl-normal(values, conf: conf)
  } else if key == "mean-cl-boot" {
    let conf = fun-args.at("conf", default: 0.95)
    let n-boot = fun-args.at("n-boot", default: 1000)
    let seed = fun-args.at("seed", default: 0)
    return mean-cl-boot(values, conf: conf, n-boot: n-boot, seed: seed)
  } else if key == "mean-sdl" {
    let mult = fun-args.at("mult", default: 2)
    return mean-sdl(values, mult: mult)
  } else if key == "median-hilow" {
    let conf = fun-args.at("conf", default: 0.5)
    return median-hilow(values, conf: conf)
  }
  panic(
    "summarise: unknown summary function "
      + repr(name)
      + "; expected one of mean_se, mean_cl_normal, mean_cl_boot, "
      + "mean_sdl, median_hilow.",
  )
}
