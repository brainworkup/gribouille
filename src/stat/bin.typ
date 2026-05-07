///! Uniform-width histogram binning.
///!
///! Backing statistic for \@geom-histogram. Emits one row per bin with the
///! bin midpoint as x, the count as y, and the bin `width` for reference.

#import "../utils/types.typ": parse-number
#import "../utils/summaries.typ": read-weight
#import "../utils/bin.typ": (
  bin-midpoint, bin-of, panel-bin-grid, resolve-bin-grid,
)
#import "../utils/aes-resolve.typ": stat-output-mapping

/// Bin statistic: partition x into uniform-width bins, count rows per bin.
///
/// Either `bins` or `binwidth` fixes the partition; if both are supplied,
/// `binwidth` wins.
///
/// \@category Stats
/// \@stability stable
/// \@since 0.0.1
///
/// \@param bins Target number of bins when `binwidth` is `none`.
/// \@param binwidth Fixed bin width. Overrides `bins` when set.
///
/// \@returns Statistic object with `name: "bin"`, consumed by geom layers.
///
/// \@examples Histogram driven by an eight-bin partition.
/// ```
/// #let d = range(0, 40).map(i => (x: i * 0.25))
/// #plot(
///   data: d,
///   mapping: aes(x: "x"),
///   layers: (geom-histogram(bins: 8),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Constructor form: `stat: stat-bin()` is equivalent to
/// `stat: "bin"` with defaults (`bins: 30`). Use the constructor to customise
/// the partition on any geom, not just \@geom-histogram.
/// ```
/// #let d = range(0, 40).map(i => (x: i * 0.25))
/// #plot(
///   data: d,
///   mapping: aes(x: "x"),
///   layers: (geom-col(stat: stat-bin(bins: 8)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-histogram, \@stat-count
#let stat-bin(bins: 30, binwidth: none) = (
  kind: "stat",
  name: "bin",
  params: (bins: bins, binwidth: binwidth),
)

#let apply(data, mapping, params: (:)) = {
  let x-col = if mapping != none { mapping.at("x", default: none) } else {
    none
  }
  if x-col == none { return (data: data, mapping: mapping) }
  let weight-col = mapping.at("weight", default: none)
  let pairs = data
    .map(r => {
      let xv = parse-number(r.at(x-col, default: none))
      if xv == none { return none }
      (x: xv, w: read-weight(r, weight-col))
    })
    .filter(p => p != none)
  let new-mapping = stat-output-mapping(mapping, (x: "x", y: "y"))
  if pairs.len() == 0 { return (data: (), mapping: new-mapping) }
  let grid = resolve-bin-grid(pairs.map(p => p.x), params)
  let counts = range(grid.n-bins).map(_ => 0)
  for p in pairs {
    let idx = bin-of(p.x, grid.lo, grid.width, grid.n-bins)
    counts.at(idx) = counts.at(idx) + p.w
  }
  let total = counts.fold(0, (acc, c) => acc + c)
  let denom = if total == 0 { 1 } else { total * grid.width }
  let rows = range(grid.n-bins).map(i => {
    let c = counts.at(i)
    (
      x: bin-midpoint(grid.lo, grid.width, i),
      y: c,
      width: grid.width,
      _count: c,
      density: c / denom,
    )
  })
  (data: rows, mapping: new-mapping)
}
