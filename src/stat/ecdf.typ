///! Empirical cumulative distribution function statistic.
///!
///! Backing statistic for ECDF curves. Emits one row per unique x value with
///! the cumulative fraction reaching that value as y.

#import "../utils/types.typ": parse-number

/// ECDF statistic: one row per unique x value with the cumulative fraction.
///
/// Numeric x values are parsed via `parse-number`; `none` and unparseable
/// inputs are dropped. For each unique value `v` in the sorted sample, y is
/// the 1-indexed position of `v`'s first occurrence divided by `n`. Output
/// rows are sorted by x ascending.
///
/// \@category Stats
/// \@stability stable
/// \@since 0.0.1
///
/// \@returns Statistic object with `name: "ecdf"`, consumed by geom layers.
///
/// \@examples ECDF curve over a tiny sample, drawn as a polyline.
/// ```
/// #let d = (3, 1, 2, 1).map(v => (x: v))
/// #plot(
///   data: d,
///   mapping: aes(x: "x"),
///   layers: (geom-line(stat: "ecdf"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Constructor form: `stat: stat-ecdf()` is equivalent to
/// `stat: "ecdf"` with defaults. Mapping `colour` to a group column produces
/// one ECDF per group; both syntax forms honour aesthetic grouping identically.
/// ```
/// #let d = ()
/// #for grp in ("a", "b") {
///   for i in range(0, 15) {
///     d.push((x: i + (if grp == "b" { 3 } else { 0 }), grp: grp))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", colour: "grp"),
///   layers: (geom-line(stat: stat-ecdf(), stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@stat-bin, \@stat-count
#let stat-ecdf() = (kind: "stat", name: "ecdf")

#let apply(data, mapping, params: (:)) = {
  let x-col = if mapping != none { mapping.at("x", default: none) } else {
    none
  }
  let base-mapping = (x: "x", y: "y")
  if x-col == none { return (data: (), mapping: base-mapping) }
  let xs = data
    .map(r => parse-number(r.at(x-col, default: none)))
    .filter(v => v != none)
  let n = xs.len()
  if n == 0 { return (data: (), mapping: base-mapping) }
  let sorted = xs.sorted()
  let rows = ()
  let i = 0
  while i < n {
    let v = sorted.at(i)
    rows.push((x: v, y: (i + 1) / n))
    let j = i + 1
    while j < n and sorted.at(j) == v { j = j + 1 }
    i = j
  }
  (data: rows, mapping: base-mapping)
}
