///! Binned y-summary statistic.
///!
///! Bins x with the same uniform-width rule as `src/stat/bin.typ`, then for
///! each bin reduces the y values inside to a `(y, ymin, ymax)` summary
///! using one of the helpers in `src/utils/summaries.typ`.

#import "../utils/types.typ": parse-number
#import "../utils/summaries.typ": summarise

/// Summary statistic over uniform x bins.
///
/// Partitions x into uniform-width bins (same rule as `stat-bin`), then for
/// every bin reduces the y values inside to a `(x, y, ymin, ymax)` row where
/// `x` is the bin midpoint. The reduction is chosen by `fun`; supported names
/// are `"mean-se"`, `"mean-cl-normal"`, `"mean-sd"`, and `"median-hilow"`.
///
/// Either `bins` or `binwidth` fixes the partition; if both are supplied,
/// `binwidth` wins.
///
/// \@category Stats
/// \@stability stable
/// \@since 0.0.1
///
/// \@param fun Name of the summary helper to apply to each bin's y values.
/// \@param bins Target number of bins when `binwidth` is `none`.
/// \@param binwidth Fixed bin width. Overrides `bins` when set.
/// \@param fun-args Keyword arguments forwarded to the helper.
///
/// \@returns Statistic object with `name: "summary_bin"`, consumed by geom
///   layers.
///
/// \@examples Mean and standard-error bands per bin, drawn as a polyline.
/// ```
/// #let d = range(0, 80).map(i => (x: i / 10, y: calc.sin(i / 10) + i / 80))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-line(stat: stat-summary-bin(fun: "mean-se", bins: 8)),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples `stat: "summary_bin"` is equivalent to `stat: stat-summary-bin()`
/// with defaults (`fun: "mean-se"`, `bins: 30`). Use the constructor to
/// customise the reduction or partition.
/// ```
/// #let d = range(0, 80).map(i => (x: i / 10, y: calc.sin(i / 10) + i / 80))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-pointrange(
///       size: 3pt,
///       stat: stat-summary-bin(fun: "median-hilow", bins: 8),
///     ),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@stat-summary, \@stat-bin
#let stat-summary-bin(
  fun: "mean-se",
  bins: 30,
  binwidth: none,
  fun-args: (:),
) = (
  kind: "stat",
  name: "summary_bin",
  params: (
    fun: fun,
    bins: bins,
    binwidth: binwidth,
    "fun-args": fun-args,
  ),
)

#let apply(data, mapping, params: (:)) = {
  let base-mapping = (x: "x", y: "y", ymin: "ymin", ymax: "ymax")
  if mapping == none { return (data: (), mapping: base-mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none {
    return (data: (), mapping: base-mapping)
  }
  if data.len() == 0 { return (data: (), mapping: base-mapping) }

  let weight-col = mapping.at("weight", default: none)
  let pairs = data
    .map(r => (
      x: parse-number(r.at(x-col, default: none)),
      y: r.at(y-col, default: none),
      w: if weight-col == none { 1 } else { r.at(weight-col, default: none) },
    ))
    .filter(p => p.x != none)
  if pairs.len() == 0 { return (data: (), mapping: base-mapping) }

  let xs = pairs.map(p => p.x)
  let lo = calc.min(..xs)
  let hi = calc.max(..xs)
  if hi == lo { hi = lo + 1.0 }

  let binwidth = params.at("binwidth", default: none)
  let bins = params.at("bins", default: 30)
  let n-bins = if binwidth != none and binwidth > 0 {
    calc.max(1, int(calc.ceil((hi - lo) / binwidth)))
  } else {
    bins
  }
  let width = (hi - lo) / n-bins

  let buckets = range(n-bins).map(_ => (ys: (), ws: ()))
  for p in pairs {
    let raw = int(calc.floor((p.x - lo) / width))
    let idx = calc.max(0, calc.min(n-bins - 1, raw))
    let bucket = buckets.at(idx)
    bucket.ys.push(p.y)
    bucket.ws.push(p.w)
    buckets.at(idx) = bucket
  }

  let fun = params.at("fun", default: "mean-se")
  let fun-args = params.at("fun-args", default: (:))

  let out = ()
  for i in range(n-bins) {
    let bucket = buckets.at(i)
    if bucket.ys.len() == 0 { continue }
    let weights = if weight-col == none { none } else { bucket.ws }
    let summary = summarise(
      fun,
      bucket.ys,
      fun-args: fun-args,
      weights: weights,
    )
    if summary.y == none { continue }
    out.push((
      x: lo + (i + 0.5) * width,
      y: summary.y,
      ymin: summary.ymin,
      ymax: summary.ymax,
    ))
  }

  (data: out, mapping: base-mapping)
}
