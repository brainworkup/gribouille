///! Reference line for a Q-Q plot.
///!
///! Backing statistic for @geom-qq-line.
///! Computes the slope and intercept that pass through the 25th and 75th
///! sample quantiles versus the corresponding theoretical quantiles of the
///! chosen reference distribution, then emits the two endpoints of that
///! line across the theoretical range used by @stat-qq.

#import "../utils/types.typ": parse-number
#import "../utils/normal.typ": theoretical-quantile

#let _quantile-type-7(sorted, q) = {
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

/// Q-Q reference-line statistic: two endpoints of the IQR-fitted line.
///
/// Slope is `(q3 - q1) / (t3 - t1)` from the sample's 25th and 75th type-7
/// quantiles divided by the corresponding theoretical quantiles of the
/// reference distribution, and intercept is `q1 - slope * t1`.
/// Endpoints span the theoretical range that @stat-qq would emit for the
/// same `n` and reference distribution.
/// Supported reference distributions are `"normal"` (default), `"uniform"`,
/// and `"exponential"`.
///
/// @category Stats
/// @stability stable
/// @since 0.0.1
///
/// @returns Statistic object with `name: "qq-line"`, consumed by geom layers.
///
/// @example
/// ```
/// #let d = (1, 2, 3, 4, 5).map(v => (v: v))
/// #plot(
///   data: d,
///   mapping: aes(y: "v"),
///   layers: (geom-qq(), geom-qq-line()),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @geom-qq-line, @stat-qq
#let stat-qq-line() = (kind: "stat", name: "qq-line")

#let apply(data, mapping, params: (:)) = {
  let base-mapping = (x: "theoretical", y: "sample")
  let sample-col = if mapping != none {
    let s = mapping.at("sample", default: none)
    if s != none { s } else { mapping.at("y", default: none) }
  } else { none }
  if sample-col == none { return (data: (), mapping: base-mapping) }
  let distribution = params.at("distribution", default: "normal")
  let xs = data
    .map(r => parse-number(r.at(sample-col, default: none)))
    .filter(v => v != none)
  let n = xs.len()
  if n < 2 { return (data: (), mapping: base-mapping) }
  let sorted = xs.sorted()
  let q1 = _quantile-type-7(sorted, 0.25)
  let q3 = _quantile-type-7(sorted, 0.75)
  let z1 = theoretical-quantile(0.25, distribution)
  let z3 = theoretical-quantile(0.75, distribution)
  let slope = (q3 - q1) / (z3 - z1)
  let intercept = q1 - slope * z1
  let t-lo = theoretical-quantile(0.5 / n, distribution)
  let t-hi = theoretical-quantile((n - 0.5) / n, distribution)
  let rows = (
    (theoretical: t-lo, sample: intercept + slope * t-lo),
    (theoretical: t-hi, sample: intercept + slope * t-hi),
  )
  (data: rows, mapping: base-mapping)
}
