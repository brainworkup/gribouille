///! Hexagonal two-dimensional binning. Backing statistic for \@geom-hex.

#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/hex.typ": hex-bin-of, panel-hex-grid, resolve-hex-grid
#import "../utils/summaries.typ": read-weight
#import "../utils/types.typ": parse-number

/// Two-dimensional hexagonal bin statistic: partition (x, y) into a
/// pointy-top hex grid and count rows per cell.
///
/// `bins` and `binwidth` accept either a scalar or an `(x, y)` pair.
///
/// \@category Stats
/// \@stability stable
/// \@since 0.4.0
///
/// \@param bins Scalar or `(x, y)` pair — target bin counts.
/// \@param binwidth Scalar or `(x, y)` pair — fixed pitches.
///
/// \@returns Statistic object with `name: "bin_hex"`.
///
/// \@see \@geom-hex, \@stat-bin-2d
#let stat-bin-hex(bins: 30, binwidth: none) = (
  kind: "stat",
  name: "bin_hex",
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
    (x: "x", y: "y", fill: "count"),
  )
  if triples.len() == 0 { return (data: (), mapping: new-mapping) }
  let grid = resolve-hex-grid(
    triples.map(t => t.x),
    triples.map(t => t.y),
    params,
  )
  // Sparse counts dict keyed by "ix,iy" — hex grids are sparser than
  // their rectangular bounding box and a flat array would over-allocate.
  let counts = (:)
  let centres = (:)
  for t in triples {
    let cell = hex-bin-of(t.x, t.y, grid)
    let key = str(cell.ix) + "," + str(cell.iy)
    counts.insert(key, counts.at(key, default: 0) + t.w)
    if not centres.keys().contains(key) {
      centres.insert(key, (cx: cell.cx, cy: cell.cy))
    }
  }
  let cell-area = grid.dx * grid.dy * 2
  let rows = counts
    .pairs()
    .map(((key, n)) => {
      let c = centres.at(key)
      (
        x: c.cx,
        y: c.cy,
        count: n,
        density: n / cell-area,
        _hex-dx: grid.dx,
        _hex-dy: grid.dy,
      )
    })
  (data: rows, mapping: new-mapping)
}
