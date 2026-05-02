///! Uniform-width histogram binning.
///!
///! Backing statistic for \@geom-histogram. Emits one row per bin with the
///! bin midpoint as x, the count as y, and the bin `width` for reference.

#import "../utils/types.typ": parse-number

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
      let w = if weight-col == none { 1 } else {
        let raw = r.at(weight-col, default: none)
        if raw == none { 0 } else if type(raw) == str { float(raw) } else {
          raw
        }
      }
      (x: xv, w: w)
    })
    .filter(p => p != none)
  if pairs.len() == 0 { return (data: (), mapping: (x: "x", y: "y")) }
  let xs = pairs.map(p => p.x)
  let lo = calc.min(..xs)
  let hi = calc.max(..xs)
  if hi == lo { hi = lo + 1.0 }
  let binwidth = params.at("binwidth", default: none)
  let bins = params.at("bins", default: 30)
  let n-bins = if binwidth != none and binwidth > 0 {
    calc.max(1, int(calc.ceil((hi - lo) / binwidth)))
  } else {
    bins
  }
  let width = (hi - lo) / n-bins
  let counts = range(n-bins).map(_ => 0)
  for p in pairs {
    let raw = int(calc.floor((p.x - lo) / width))
    let idx = calc.max(0, calc.min(n-bins - 1, raw))
    counts.at(idx) = counts.at(idx) + p.w
  }
  let rows = range(n-bins).map(i => (
    x: lo + (i + 0.5) * width,
    y: counts.at(i),
    width: width,
  ))
  (data: rows, mapping: (x: "x", y: "y"))
}
