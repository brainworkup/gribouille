///! Per-x summary statistic backing @geom-pointrange and friends.
///!
///! For every distinct x level in the input data, reduces the y values to a
///! single `(x, y, ymin, ymax)` row using one of the summary helpers in
///! `src/utils/summaries.typ`.

#import "../utils/types.typ": parse-number
#import "../utils/summaries.typ": summarise

/// Per-x reduction to a central value and an uncertainty band.
///
/// One output row per distinct x value with keys `(x, y, ymin, ymax)`. The
/// reduction is chosen by `fun`; supported names are `"mean-se"`,
/// `"mean-cl-normal"`, `"mean-sdl"`, and `"median-hilow"`.
///
/// @category Stats
/// @stability stable
/// @since 0.0.1
///
/// @param fun Name of the summary helper to apply to each bucket of y values.
/// @param fun-args Keyword arguments forwarded to the helper, for example
///   `(mult: 2)` for `mean-se` or `(conf: 0.5)` for `median-hilow`.
///
/// @returns Statistic object with `name: "summary"`, consumed by geom layers.
///
/// @examples Mean and standard-error summary per group, drawn as a line and
/// ribbon stack.
/// ```
/// #let d = ()
/// #for grp in ("a", "b", "c") {
///   for i in range(20) {
///     d.push((grp: grp, y: calc.sin(i) + i / 10))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y"),
///   layers: (
///     geom-line(stat: stat-summary(fun: "mean-se")),
///     geom-ribbon(stat: stat-summary(fun: "mean-se")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @examples Use the `median-hilow` reducer with @geom-pointrange to surface
/// the median plus a customisable confidence band.
/// ```
/// #let d = ()
/// #for grp in ("a", "b", "c") {
///   for i in range(20) {
///     d.push((grp: grp, y: calc.sin(i) + i / 10))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y"),
///   layers: (
///     geom-pointrange(
///       size: 3pt,
///       stat: stat-summary(fun: "median-hilow", fun-args: (conf: 0.5)),
///     ),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @stat-summary-bin, @stat-boxplot
#let stat-summary(fun: "mean-se", fun-args: (:)) = (
  kind: "stat",
  name: "summary",
  params: (fun: fun, "fun-args": fun-args),
)

#let _group-aesthetics = ("group", "colour", "fill", "linetype", "shape")

#let apply(data, mapping, params: (:)) = {
  let base-mapping = (x: "x", y: "y", ymin: "ymin", ymax: "ymax")
  if mapping == none { return (data: (), mapping: base-mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none {
    return (data: (), mapping: base-mapping)
  }
  if data.len() == 0 { return (data: (), mapping: base-mapping) }

  let fun = params.at("fun", default: "mean-se")
  let fun-args = params.at("fun-args", default: (:))

  // Bivariate path: when a grouping aesthetic (colour, shape …) is set, the
  // data has already been pre-partitioned upstream so each call sees one
  // group's rows. If x is continuous within that group, sub-bucketing by x
  // would produce one row per individual observation; instead emit a single
  // bivariate summary covering both x- and y-direction uncertainty.
  let has-grouping = _group-aesthetics.any(a => (
    mapping.at(a, default: none) != none
  ))
  let x-nonnull = data
    .map(r => r.at(x-col, default: none))
    .filter(v => v != none)
  let x-continuous = (
    x-nonnull.len() > 0 and x-nonnull.all(v => parse-number(v) != none)
  )
  if has-grouping and x-continuous {
    let xs = data.map(r => r.at(x-col, default: none))
    let ys = data.map(r => r.at(y-col, default: none))
    let sx = summarise(fun, xs, fun-args: fun-args)
    let sy = summarise(fun, ys, fun-args: fun-args)
    if sx.y == none or sy.y == none { return (data: (), mapping: base-mapping) }
    let bmap = (
      x: "x",
      y: "y",
      xmin: "xmin",
      xmax: "xmax",
      ymin: "ymin",
      ymax: "ymax",
    )
    for aes in _group-aesthetics {
      let col = mapping.at(aes, default: none)
      if col != none { bmap.insert(aes, col) }
    }
    return (
      data: (
        (
          x: sx.y,
          y: sy.y,
          xmin: sx.ymin,
          xmax: sx.ymax,
          ymin: sy.ymin,
          ymax: sy.ymax,
        ),
      ),
      mapping: bmap,
    )
  }

  // Discrete x: bucket rows by their raw x value; emit one summary row per
  // bucket in first-appearance order so the downstream x scale keeps the same
  // level ordering as the input.
  for aes in _group-aesthetics {
    let col = mapping.at(aes, default: none)
    if col != none { base-mapping.insert(aes, col) }
  }
  let buckets = (:)
  let order = ()
  for row in data {
    let key = str(row.at(x-col, default: ""))
    if key == "" { continue }
    let bucket = buckets.at(key, default: ())
    bucket.push(row)
    buckets.insert(key, bucket)
    if not order.contains(key) { order.push(key) }
  }

  let out = ()
  for key in order {
    let rows = buckets.at(key)
    let ys = rows.map(r => r.at(y-col, default: none))
    let summary = summarise(fun, ys, fun-args: fun-args)
    if summary.y == none { continue }

    let raw-x = rows.first().at(x-col, default: none)
    let parsed-x = parse-number(raw-x)
    let x-value = if parsed-x != none { parsed-x } else { raw-x }

    out.push((
      x: x-value,
      y: summary.y,
      ymin: summary.ymin,
      ymax: summary.ymax,
    ))
  }

  (data: out, mapping: base-mapping)
}
