///! Hexagonal two-dimensional binning. Backing statistic for \@geom-hex.

#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/hex.typ": hex-cells, panel-hex-grid

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
  let new-mapping = stat-output-mapping(
    mapping,
    (x: "x", y: "y", fill: "count"),
  )
  if mapping == none { return (data: (), mapping: new-mapping) }
  let result = hex-cells(
    data,
    mapping.at("x", default: none),
    mapping.at("y", default: none),
    params,
    weight-col: mapping.at("weight", default: none),
  )
  if result == none { return (data: (), mapping: new-mapping) }
  let grid = result.grid
  let cell-area = grid.dx * grid.dy * 2
  let rows = result
    .cells
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
