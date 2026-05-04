///! Iso-line contour statistic. Backing stat for \@geom-contour.

#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/marching-squares.typ": isolines
#import "../utils/pretty.typ": pretty
#import "../utils/types.typ": parse-number

// Resolve contour levels from `breaks` (explicit array), `binwidth` (fixed
// step), or `bins` (target count). Falls back to `pretty()` so default
// levels land on round numbers within `[lo, hi]`.
#let _resolve-levels(lo, hi, bins, binwidth, breaks) = {
  if breaks != none and breaks != auto {
    return breaks
  }
  if binwidth != none {
    let n = calc.max(1, int(calc.floor((hi - lo) / binwidth)))
    return range(1, n + 1).map(i => lo + i * binwidth)
  }
  let target = if bins == none { 10 } else { bins }
  pretty(lo, hi, n: target)
}

// Reshape a long-format `(x, y, z)` table into the `(xs, ys, z[i][j])`
// regular grid expected by `isolines`. Rows must lie on a (Cartesian)
// product of unique x and y values; missing cells are filled with `none`
// and skipped by marching squares.
#let _grid-from-rows(rows, x-col, y-col, z-col) = {
  let xs-set = ()
  let ys-set = ()
  for r in rows {
    let xv = parse-number(r.at(x-col, default: none))
    let yv = parse-number(r.at(y-col, default: none))
    if xv == none or yv == none { continue }
    if not xs-set.contains(xv) { xs-set.push(xv) }
    if not ys-set.contains(yv) { ys-set.push(yv) }
  }
  let xs = xs-set.sorted()
  let ys = ys-set.sorted()
  let nx = xs.len()
  let ny = ys.len()
  if nx < 2 or ny < 2 { return (xs: xs, ys: ys, z: ()) }
  let z = range(nx).map(_ => range(ny).map(_ => none))
  let z-lo = none
  let z-hi = none
  for r in rows {
    let xv = parse-number(r.at(x-col, default: none))
    let yv = parse-number(r.at(y-col, default: none))
    let zv = parse-number(r.at(z-col, default: none))
    if xv == none or yv == none or zv == none { continue }
    let i = xs.position(v => v == xv)
    let j = ys.position(v => v == yv)
    if i == none or j == none { continue }
    z.at(i).at(j) = zv
    z-lo = if z-lo == none { zv } else { calc.min(z-lo, zv) }
    z-hi = if z-hi == none { zv } else { calc.max(z-hi, zv) }
  }
  (xs: xs, ys: ys, z: z, z-lo: z-lo, z-hi: z-hi)
}

/// Marching-squares contour statistic.
///
/// Treats input rows as samples of a scalar field `z` over a regular
/// `(x, y)` grid (one row per Cartesian product cell) and emits the iso-line
/// segments at each level. Pair with \@geom-path or \@geom-contour to draw.
///
/// Either `breaks`, `binwidth`, or `bins` controls level placement;
/// precedence runs `breaks` > `binwidth` > `bins` (default `bins: 10`).
///
/// \@category Stats
/// \@stability stable
/// \@since 0.4.0
///
/// \@param bins Target contour-level count when `breaks` and `binwidth` are unset.
/// \@param binwidth Fixed step between levels. Overrides `bins`.
/// \@param breaks Explicit array of contour levels. Overrides `bins` and `binwidth`.
///
/// \@returns Statistic object with `name: "contour"`.
///
/// \@see \@geom-contour, \@stat-bin-2d
#let stat-contour(bins: 10, binwidth: none, breaks: auto) = (
  kind: "stat",
  name: "contour",
  params: (bins: bins, binwidth: binwidth, breaks: breaks),
)

#let apply(data, mapping, params: (:)) = {
  let new-mapping = stat-output-mapping(
    mapping,
    (x: "x", y: "y", group: "group"),
  )
  if mapping == none { return (data: (), mapping: new-mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  let z-col = mapping.at("z", default: none)
  if x-col == none or y-col == none or z-col == none {
    return (data: (), mapping: new-mapping)
  }
  let grid = _grid-from-rows(data, x-col, y-col, z-col)
  if grid.z.len() == 0 or grid.at("z-lo", default: none) == none {
    return (data: (), mapping: new-mapping)
  }
  let levels = _resolve-levels(
    grid.z-lo,
    grid.z-hi,
    params.at("bins", default: 10),
    params.at("binwidth", default: none),
    params.at("breaks", default: auto),
  )
  let rows = ()
  for (li, level) in levels.enumerate() {
    let segs = isolines(grid.xs, grid.ys, grid.z, level)
    for (si, ((x0, y0), (x1, y1))) in segs.enumerate() {
      let group = str(li) + ":" + str(si)
      rows.push((x: x0, y: y0, level: level, group: group))
      rows.push((x: x1, y: y1, level: level, group: group))
    }
  }
  (data: rows, mapping: new-mapping)
}
