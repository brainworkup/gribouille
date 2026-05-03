// Two-dimensional uniform-grid binning helpers used by stat-bin-2d and
// stat-summary-2d. A 2D grid is a dict
// `(x-lo, x-n-bins, x-width, y-lo, y-n-bins, y-width)`.

#import "bin.typ": bin-config, bin-domain, bin-midpoint, bin-of
#import "types.typ": parse-number

// Resolve a `bins` / `binwidth` parameter that is either a scalar (applied
// to both axes) or an `(x, y)` pair into the per-axis pair.
#let _split-pair(value, fallback: none) = {
  if value == none { return (fallback, fallback) }
  if type(value) == array { return (value.at(0), value.at(1)) }
  (value, value)
}

#let bin-grid-2d(xs, ys, bins, binwidth) = {
  let (bx, by) = _split-pair(bins, fallback: 30)
  let (wx, wy) = _split-pair(binwidth)
  let (x-lo, x-hi) = bin-domain(xs)
  let (y-lo, y-hi) = bin-domain(ys)
  let xc = bin-config(x-lo, x-hi, bx, wx)
  let yc = bin-config(y-lo, y-hi, by, wy)
  (
    x-lo: x-lo,
    x-n-bins: xc.n-bins,
    x-width: xc.width,
    y-lo: y-lo,
    y-n-bins: yc.n-bins,
    y-width: yc.width,
  )
}

// Stash a panel-wide grid in `params.grid` so per-group `apply()` calls share
// the partition (mirrors `panel-bin-grid` for 1D).
#let panel-bin-grid-2d(data, mapping, params) = {
  if mapping == none { return params }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none { return params }
  let pairs = data
    .map(r => {
      let xv = parse-number(r.at(x-col, default: none))
      let yv = parse-number(r.at(y-col, default: none))
      if xv == none or yv == none { return none }
      (xv, yv)
    })
    .filter(p => p != none)
  if pairs.len() == 0 { return params }
  let grid = bin-grid-2d(
    pairs.map(p => p.at(0)),
    pairs.map(p => p.at(1)),
    params.at("bins", default: 30),
    params.at("binwidth", default: none),
  )
  let out = params
  out.insert("grid", grid)
  out
}

#let resolve-bin-grid-2d(xs, ys, params) = {
  let g = params.at("grid", default: none)
  if g != none { return g }
  bin-grid-2d(
    xs,
    ys,
    params.at("bins", default: 30),
    params.at("binwidth", default: none),
  )
}

#let bin-of-2d(x, y, grid) = (
  bin-of(x, grid.x-lo, grid.x-width, grid.x-n-bins),
  bin-of(y, grid.y-lo, grid.y-width, grid.y-n-bins),
)

#let bin-midpoint-2d(grid, ix, iy) = (
  bin-midpoint(grid.x-lo, grid.x-width, ix),
  bin-midpoint(grid.y-lo, grid.y-width, iy),
)
