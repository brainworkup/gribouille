///! Per-x summary statistic backing @geom-pointrange and friends.
///!
///! For every distinct x level in the input data, reduces the y values to a
///! single `(x, y, ymin, ymax)` row using one of the ggplot2-style summary
///! helpers in `src/utils/summaries.typ`.

#import "../utils/types.typ": parse-number
#import "../utils/summaries.typ": summarise

/// Summary statistic: per-x reduction to a central value and an uncertainty
/// band.
///
/// One output row per distinct x value with keys `(x, y, ymin, ymax)`. The
/// reduction is chosen by `fun`; supported names mirror ggplot2's family:
/// `"mean_se"`, `"mean_cl_normal"`, `"mean_sdl"`, and `"median_hilow"`.
/// Hyphenated spellings (e.g. `"mean-se"`) are accepted to match Gribouille's
/// kebab-case convention.
///
/// @category Stats
/// @stability stable
/// @since 0.0.1
///
/// @param fun Name of the summary helper to apply to each bucket of y values.
/// @param fun-args Keyword arguments forwarded to the helper, for example
///   `(mult: 2)` for `mean_se` or `(conf: 0.5)` for `median_hilow`.
///
/// @returns Statistic object with `name: "summary"`, consumed by geom layers.
///
/// @example
/// ```
/// //| width: 10cm
/// //| height: 6cm
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
///     geom-line(stat: stat-summary(fun: "mean_se")),
///     geom-ribbon(stat: stat-summary(fun: "mean_se")),
///   ),
/// )
/// ```
///
/// @see @stat-summary-bin, @stat-boxplot
#let stat-summary(fun: "mean_se", fun-args: (:)) = (
  kind: "stat",
  name: "summary",
  params: (fun: fun, "fun-args": fun-args),
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

  let fun = params.at("fun", default: "mean_se")
  let fun-args = params.at("fun-args", default: (:))

  // Bucket rows by their raw x value; emit one summary row per bucket in
  // first-appearance order so the downstream x scale keeps the same level
  // ordering as the input.
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
