///! Quantile-quantile statistic against the standard normal distribution.
///!
///! Backing statistic for @geom-qq. Sorts numeric values from the `sample`
///! aesthetic and pairs them with theoretical standard-normal quantiles at
///! the plotting positions `(i + 0.5) / n`.

#import "../utils/types.typ": parse-number
#import "../utils/normal.typ": qnorm

/// Q-Q statistic: theoretical-vs-sample pairs against the standard normal.
///
/// Reads the `sample` aesthetic from the mapping; if `sample` is absent the
/// statistic falls back to `y`. Non-numeric and `none` values are dropped.
/// Output rows are sorted by `sample` ascending, with `theoretical` taken
/// from `qnorm((i + 0.5) / n)` for `i` in `0..n`.
///
/// @category Stats
/// @stability stable
/// @since 0.0.1
///
/// @returns Statistic object with `name: "qq"`, consumed by geom layers.
///
/// @example
/// ```
/// //| width: 10cm
/// //| height: 6cm
/// #let d = (1, 2, 3, 4, 5).map(v => (v: v))
/// #plot(
///   data: d,
///   mapping: aes(sample: "v"),
///   layers: (geom-qq(),),
/// )
/// ```
///
/// @see @geom-qq, @stat-qq-line
#let stat-qq() = (kind: "stat", name: "qq")

#let apply(data, mapping, params: (:)) = {
  let base-mapping = (x: "theoretical", y: "sample")
  let sample-col = if mapping != none {
    let s = mapping.at("sample", default: none)
    if s != none { s } else { mapping.at("y", default: none) }
  } else { none }
  if sample-col == none { return (data: (), mapping: base-mapping) }
  let xs = data
    .map(r => parse-number(r.at(sample-col, default: none)))
    .filter(v => v != none)
  let n = xs.len()
  if n == 0 { return (data: (), mapping: base-mapping) }
  let sorted = xs.sorted()
  let rows = ()
  let i = 0
  while i < n {
    let p = (i + 0.5) / n
    rows.push((theoretical: qnorm(p), sample: sorted.at(i)))
    i = i + 1
  }
  (data: rows, mapping: base-mapping)
}
