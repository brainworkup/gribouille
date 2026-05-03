///! Rectangular two-dimensional binning. Backing statistic for \@geom-bin-2d.

#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/bin2d.typ": (
  bin-midpoint-2d, bin-of-2d, panel-bin-grid-2d, resolve-bin-grid-2d,
)
#import "../utils/summaries.typ": read-weight
#import "../utils/types.typ": parse-number

/// Two-dimensional bin statistic: partition (x, y) into a rectangular grid
/// and count rows per cell.
///
/// `bins` and `binwidth` accept either a scalar (applied to both axes) or
/// an `(x, y)` pair. `binwidth` wins on each axis where both are set.
///
/// \@category Stats
/// \@stability stable
/// \@since 0.4.0
///
/// \@param bins Scalar or `(x, y)` pair — target bin counts when binwidth is `none`.
/// \@param binwidth Scalar or `(x, y)` pair — fixed bin widths. Overrides `bins` per axis.
///
/// \@returns Statistic object with `name: "bin_2d"`.
///
/// \@see \@geom-bin-2d, \@stat-bin
#let stat-bin-2d(bins: 30, binwidth: none) = (
  kind: "stat",
  name: "bin_2d",
  params: (bins: bins, binwidth: binwidth),
)

#let apply(data, mapping, params: (:)) = {
  let x-col = if mapping != none { mapping.at("x", default: none) } else {
    none
  }
  let y-col = if mapping != none { mapping.at("y", default: none) } else {
    none
  }
  if x-col == none or y-col == none {
    return (data: data, mapping: mapping)
  }
  let weight-col = mapping.at("weight", default: none)
  let triples = data
    .map(r => {
      let xv = parse-number(r.at(x-col, default: none))
      let yv = parse-number(r.at(y-col, default: none))
      if xv == none or yv == none { return none }
      (x: xv, y: yv, w: read-weight(r, weight-col))
    })
    .filter(p => p != none)
  let new-mapping = stat-output-mapping(
    mapping,
    (
      x: "x",
      y: "y",
      xmin: "xmin",
      xmax: "xmax",
      ymin: "ymin",
      ymax: "ymax",
      fill: "count",
    ),
  )
  if triples.len() == 0 { return (data: (), mapping: new-mapping) }
  let grid = resolve-bin-grid-2d(
    triples.map(t => t.x),
    triples.map(t => t.y),
    params,
  )
  // Flat counts table: Typst arrays are value-typed, so nested-array
  // assignment doesn't propagate.
  let ny = grid.y-n-bins
  let counts = range(grid.x-n-bins * ny).map(_ => 0)
  for t in triples {
    let (ix, iy) = bin-of-2d(t.x, t.y, grid)
    let k = ix * ny + iy
    counts.at(k) = counts.at(k) + t.w
  }
  let cell-area = grid.x-width * grid.y-width
  let rows = ()
  for k in range(counts.len()) {
    let n = counts.at(k)
    if n == 0 { continue }
    let (xm, ym) = bin-midpoint-2d(grid, calc.quo(k, ny), calc.rem(k, ny))
    rows.push((
      x: xm,
      y: ym,
      xmin: xm - grid.x-width / 2,
      xmax: xm + grid.x-width / 2,
      ymin: ym - grid.y-width / 2,
      ymax: ym + grid.y-width / 2,
      count: n,
      density: n / cell-area,
    ))
  }
  (data: rows, mapping: new-mapping)
}
