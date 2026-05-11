///! Hexagonal two-dimensional summary statistic. Reduces a `z` aesthetic
///! per hex cell.

#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/hex.typ": hex-cells
#import "../utils/summaries.typ": reduce-scalar

/// Hex-grid summary statistic.
///
/// Partitions (x, y) into a pointy-top hex grid (same rule as \@stat-bin-hex),
/// then reduces the `z` values inside each cell to a single scalar emitted
/// as the `value` column.
///
/// \@category Stats
/// \@subcategory Summaries
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
  let z-col = mapping.at("z", default: none)
  if z-col == none { return (data: (), mapping: new-mapping) }
  let result = hex-cells(
    data,
    mapping.at("x", default: none),
    mapping.at("y", default: none),
    params,
    z-col: z-col,
  )
  if result == none { return (data: (), mapping: new-mapping) }
  let grid = result.grid
  let fun = params.at("fun", default: "mean")
  let rows = ()
  for c in result.cells.values() {
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
