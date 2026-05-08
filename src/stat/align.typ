///! Align groups onto a shared x-grid for stacked area / ribbon use.
///!
///! Mirrors ggplot2 v4's `stat_align`. Each group's y is linearly
///! interpolated onto the union of every group's x values plus the
///! zero-crossings detected within each group, so stacked layers share
///! clean vertices at every break.

#import "../utils/types.typ": parse-number
#import "../utils/group.typ": partition-by-group

#let _ZERO-CROSSING-FRACTION = 0.001

#let _parsed-pairs(data, x-col, y-col) = {
  data
    .map(r => {
      let xv = parse-number(r.at(x-col, default: none))
      let yv = parse-number(r.at(y-col, default: none))
      if xv == none or yv == none { return none }
      (x: xv, y: yv, row: r)
    })
    .filter(p => p != none)
    .sorted(key: p => p.x)
}

#let _zero-crossings-for-group(pairs) = {
  let crossings = ()
  for i in range(1, pairs.len()) {
    let a = pairs.at(i - 1)
    let b = pairs.at(i)
    if (a.y < 0) != (b.y < 0) {
      let dy = b.y - a.y
      if dy != 0 {
        crossings.push(a.x - a.y * (b.x - a.x) / dy)
      }
    }
  }
  crossings
}

#let _dedupe-sorted(values) = {
  let out = ()
  for v in values.sorted() {
    if out.len() == 0 or out.last() != v { out.push(v) }
  }
  out
}

#let _min-diff(sorted-values) = {
  if sorted-values.len() < 2 { return 0 }
  let min-d = sorted-values.last() - sorted-values.first()
  for i in range(1, sorted-values.len()) {
    let d = sorted-values.at(i) - sorted-values.at(i - 1)
    if d < min-d { min-d = d }
  }
  min-d
}

/// Align statistic: resample each group onto a shared x-grid.
///
/// Builds the union of every group's x values plus zero-crossings within
/// each group, deduped and sorted. Each group's y is linearly interpolated
/// onto that grid; rows outside a group's input range are dropped, and
/// the trimmed extremes are padded with `y = 0` so stacked areas join
/// cleanly between groups.
///
/// Output rows carry an `align-padding` boolean: `true` for the leading
/// and trailing zero-pad rows, `false` for interpolated points.
///
/// \@category Stats
/// \@stability stable
/// \@since 0.6.0
///
/// \@returns Statistic object with `name: "align"`, consumed by geom layers.
///
/// \@examples Two groups with mismatched x sampled onto a stacked area.
/// ```
/// #let d = (
///   (x: 0, y: 1, k: "a"), (x: 2, y: 3, k: "a"), (x: 4, y: 2, k: "a"),
///   (x: 1, y: 2, k: "b"), (x: 3, y: 1, k: "b"), (x: 5, y: 4, k: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "k"),
///   layers: (geom-area(stat: stat-align(), position: "stack"),),
///   width: 12cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-area, \@geom-ribbon, \@stat-identity
#let stat-align() = (kind: "stat", name: "align", params: (:))

/// Panel-level setup: compute the union x-grid + adjust offset once and
/// thread them through to per-group `apply()` via params.
///
/// \@internal
#let setup(data, mapping, params: (:)) = {
  if mapping == none { return params }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none { return params }

  let xs = ()
  let crossings = ()
  for g in partition-by-group(data, mapping) {
    let pairs = _parsed-pairs(g.data, x-col, y-col)
    for p in pairs { xs.push(p.x) }
    for c in _zero-crossings-for-group(pairs) { crossings.push(c) }
  }
  if xs.len() == 0 { return params }

  let unique-loc = _dedupe-sorted(xs + crossings)
  let lo = unique-loc.first()
  let hi = unique-loc.last()
  let range-span = hi - lo
  let adjust = range-span * _ZERO-CROSSING-FRACTION
  let diff = _min-diff(unique-loc)
  if diff > 0 and diff / 3 < adjust { adjust = diff / 3 }

  let padded = ()
  for v in unique-loc {
    padded.push(v - adjust)
    padded.push(v)
    padded.push(v + adjust)
  }
  let final-loc = _dedupe-sorted(padded)

  let out = params
  out.insert("unique-loc", final-loc)
  out.insert("adjust", adjust)
  out
}

#let apply(data, mapping, params: (:)) = {
  if mapping == none { return (data: data, mapping: mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  let unique-loc = params.at("unique-loc", default: ())
  let adjust = params.at("adjust", default: 0)
  if x-col == none or y-col == none or unique-loc.len() == 0 {
    return (data: data, mapping: mapping)
  }

  let pairs = _parsed-pairs(data, x-col, y-col)
  if pairs.len() < 2 {
    return (data: pairs.map(p => p.row), mapping: mapping)
  }

  let x-min = pairs.first().x
  let x-max = pairs.last().x
  let n = pairs.len()
  let pi = 0
  let interpolated = ()
  for loc in unique-loc {
    if loc < x-min or loc > x-max { continue }
    while pi + 1 < n and pairs.at(pi + 1).x <= loc { pi += 1 }
    let a = pairs.at(pi)
    let yv = if a.x == loc or pi + 1 >= n {
      a.y
    } else {
      let b = pairs.at(pi + 1)
      let t = (loc - a.x) / (b.x - a.x)
      a.y + (b.y - a.y) * t
    }
    interpolated.push(
      a.row + ((x-col): loc, (y-col): yv, "align-padding": false),
    )
  }

  if interpolated.len() == 0 { return (data: (), mapping: mapping) }

  let proto = pairs.first().row
  let leading = (
    proto
      + (
        (x-col): interpolated.first().at(x-col) - adjust,
        (y-col): 0,
        "align-padding": true,
      )
  )
  let trailing = (
    proto
      + (
        (x-col): interpolated.last().at(x-col) + adjust,
        (y-col): 0,
        "align-padding": true,
      )
  )
  (data: (leading,) + interpolated + (trailing,), mapping: mapping)
}
