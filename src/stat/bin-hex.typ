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
  // Sparse cell dict keyed by "ix,iy" — hex grids are sparser than their
  // rectangular bounding box and a flat array would over-allocate. Each
  // entry stores (count, cx, cy) so the centre is captured once per cell
  // without a parallel dict.
  let cells = (:)
  for t in triples {
    let cell = hex-bin-of(t.x, t.y, grid)
    let key = str(cell.ix) + "," + str(cell.iy)
    let prev = cells.at(key, default: none)
    if prev == none {
      cells.insert(key, (count: t.w, cx: cell.cx, cy: cell.cy))
    } else {
      prev.count += t.w
      cells.insert(key, prev)
    }
  }
  let cell-area = grid.dx * grid.dy * 2
  let rows = cells
    .values()
    .map(c => (
      x: c.cx,
      y: c.cy,
      count: c.count,
      density: c.count / cell-area,
      _hex-dx: grid.dx,
      _hex-dy: grid.dy,
    ))
  (data: rows, mapping: new-mapping)
}
