///! Hexagonal two-dimensional summary statistic. Reduces a `z` aesthetic
///! per hex cell.

#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/hex.typ": hex-bin-of, resolve-hex-grid
#import "../utils/summaries.typ": reduce-scalar
#import "../utils/types.typ": parse-number

/// Hex-grid summary statistic.
///
/// Partitions (x, y) into a pointy-top hex grid (same rule as
/// \@stat-bin-hex), then reduces the `z` values inside each cell to a
/// single scalar emitted as the `value` column.
///
/// \@category Stats
/// \@stability stable
/// \@since 0.4.0
///
/// \@param fun Reduction. String keyword (`"mean"`, `"median"`, `"sum"`, `"min"`, `"max"`) or callable.
/// \@param bins Scalar or `(x, y)` pair — target bin counts.
/// \@param binwidth Scalar or `(x, y)` pair — fixed pitches.
///
/// \@returns Statistic object with `name: "summary_hex"`.
///
/// \@see \@stat-bin-hex, \@stat-summary-2d
#let stat-summary-hex(fun: "mean", bins: 30, binwidth: none) = (
  kind: "stat",
  name: "summary_hex",
  params: (fun: fun, bins: bins, binwidth: binwidth),
)

#let apply(data, mapping, params: (:)) = {
  let new-mapping = stat-output-mapping(
    mapping,
    (x: "x", y: "y", fill: "value"),
  )
  if mapping == none { return (data: (), mapping: new-mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  let z-col = mapping.at("z", default: none)
  if x-col == none or y-col == none or z-col == none {
    return (data: (), mapping: new-mapping)
  }
  let triples = data
    .map(r => {
      let xv = parse-number(r.at(x-col, default: none))
      let yv = parse-number(r.at(y-col, default: none))
      let zv = r.at(z-col, default: none)
      if xv == none or yv == none or zv == none { return none }
      (x: xv, y: yv, z: zv)
    })
    .filter(p => p != none)
  if triples.len() == 0 { return (data: (), mapping: new-mapping) }
  let grid = resolve-hex-grid(
    triples.map(t => t.x),
    triples.map(t => t.y),
    params,
  )
  // Sparse cell dict, mirroring `bin-hex.apply`: hex grids are sparser
  // than their rectangular bounding box and a flat array would
  // over-allocate. The cell entry holds the z bucket plus the centre so
  // that capture happens once on first insert.
  let cells = (:)
  for t in triples {
    let cell = hex-bin-of(t.x, t.y, grid)
    let key = str(cell.ix) + "," + str(cell.iy)
    let prev = cells.at(key, default: none)
    if prev == none {
      cells.insert(key, (zs: (t.z,), cx: cell.cx, cy: cell.cy))
    } else {
      prev.zs.push(t.z)
      cells.insert(key, prev)
    }
  }
  let fun = params.at("fun", default: "mean")
  let rows = ()
  for c in cells.values() {
    let value = reduce-scalar(fun, c.zs)
    if value == none { continue }
    rows.push((
      x: c.cx,
      y: c.cy,
      value: value,
      _hex-dx: grid.dx,
      _hex-dy: grid.dy,
    ))
  }
  (data: rows, mapping: new-mapping)
}
