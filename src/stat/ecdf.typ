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
  let weight-col = mapping.at("weight", default: none)
  let pairs = data
    .map(r => {
      let xv = parse-number(r.at(x-col, default: none))
      if xv == none { return none }
      let w = if weight-col == none { 1 } else {
        let raw = r.at(weight-col, default: none)
        if raw == none { 0 } else if type(raw) == str { float(raw) } else {
          raw
        }
      }
      (x: xv, w: w)
    })
    .filter(p => p != none)
  if pairs.len() == 0 { return (data: (), mapping: base-mapping) }
  let total = pairs.fold(0, (acc, p) => acc + p.w)
  if total == 0 { return (data: (), mapping: base-mapping) }
  let sorted = pairs.sorted(key: p => p.x)
  let rows = ()
  let cum = 0
  let i = 0
  let n = sorted.len()
  while i < n {
    let v = sorted.at(i).x
    cum += sorted.at(i).w
    rows.push((x: v, y: cum / total))
    let j = i + 1
    while j < n and sorted.at(j).x == v {
      cum += sorted.at(j).w
      j = j + 1
    }
    i = j
  }
  (data: rows, mapping: base-mapping)
}
