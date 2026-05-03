// Pointy-top hexagonal binning.
//
// Two interleaved rectangular lattices form a single hex grid. Lattice A
// has centres at `(x0 + ix * dx, y0 + iy * dy * 2)`; lattice B is offset
// by `(dx / 2, dy)`. The closer centre of the two candidates wins, which
// matches Voronoi regions of the combined hex lattice.
//
// `dx` is the horizontal pitch (centre-to-centre) and `dy = dx * sqrt(3) / 2`
// for a regular hex; callers may override `dy` when data axes have very
// different scales.

#import "bin.typ": bin-domain
#import "types.typ": parse-number

#let _SQRT3 = calc.sqrt(3)
#let _SQRT3-OVER-2 = _SQRT3 / 2

#let _split-pair(value, fallback: none) = {
  if value == none { return (fallback, fallback) }
  if type(value) == array { return (value.at(0), value.at(1)) }
  (value, value)
}

// Build a hex grid from `(xs, ys)` extents and a `bins` / `binwidth` pair.
// `bins` accepts a scalar (applied to both axes) or an `(x, y)` pair.
// `binwidth` overrides each axis where set.
#let hex-grid(xs, ys, bins, binwidth) = {
  let (bx, by) = _split-pair(bins, fallback: 30)
  let (wx, wy) = _split-pair(binwidth)
  let (x-lo, x-hi) = bin-domain(xs)
  let (y-lo, y-hi) = bin-domain(ys)
  let dx = if wx != none { wx } else { (x-hi - x-lo) / bx }
  let dy = if wy != none { wy } else { (y-hi - y-lo) / by * _SQRT3-OVER-2 }
  (x-lo: x-lo, y-lo: y-lo, dx: dx, dy: dy)
}

#let panel-hex-grid(data, mapping, params) = {
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
  let grid = hex-grid(
    pairs.map(p => p.at(0)),
    pairs.map(p => p.at(1)),
    params.at("bins", default: 30),
    params.at("binwidth", default: none),
  )
  let out = params
  out.insert("grid", grid)
  out
}

#let resolve-hex-grid(xs, ys, params) = {
  let g = params.at("grid", default: none)
  if g != none { return g }
  hex-grid(xs, ys, params.at("bins", default: 30), params.at(
    "binwidth",
    default: none,
  ))
}

// Assign `(x, y)` to the closest hex centre. Returns `(ix, iy, cx, cy)`
// where `(ix, iy)` is the integer cell key and `(cx, cy)` is the centre
// in data space. `iy` is even on lattice A and odd on lattice B.
#let hex-bin-of(x, y, grid) = {
  let dx = grid.dx
  let dy = grid.dy
  // Lattice A centre (even rows).
  let ia = calc.round((x - grid.x-lo) / dx)
  let ja = calc.round((y - grid.y-lo) / (2 * dy))
  let cxa = grid.x-lo + ia * dx
  let cya = grid.y-lo + ja * 2 * dy
  let dax = x - cxa
  let day = y - cya
  let da2 = dax * dax + day * day
  // Lattice B centre (odd rows).
  let ib = calc.round((x - grid.x-lo - dx / 2) / dx)
  let jb = calc.round((y - grid.y-lo - dy) / (2 * dy))
  let cxb = grid.x-lo + ib * dx + dx / 2
  let cyb = grid.y-lo + jb * 2 * dy + dy
  let dbx = x - cxb
  let dby = y - cyb
  let db2 = dbx * dbx + dby * dby
  if da2 <= db2 {
    (ix: ia, iy: 2 * ja, cx: cxa, cy: cya)
  } else {
    (ix: ib, iy: 2 * jb + 1, cx: cxb, cy: cyb)
  }
}

// Six pointy-top vertices around `(cx, cy)`. `dx` is horizontal pitch and
// `dy` vertical row pitch; the circumradius derives as `dy * 2 / 3` only
// when `dy = dx * sqrt(3) / 2`. For non-regular grids we draw the hex with
// width `dx` and height `2 * dy`, which keeps cells touching their
// neighbours.
#let hex-vertices(cx, cy, dx, dy) = {
  let hw = dx / 2
  let q = dy * 2 / 3
  let qh = q / 2
  (
    (cx, cy + q),
    (cx + hw, cy + qh),
    (cx + hw, cy - qh),
    (cx, cy - q),
    (cx - hw, cy - qh),
    (cx - hw, cy + qh),
  )
}
