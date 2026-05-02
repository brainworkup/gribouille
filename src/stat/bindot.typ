///! Dot-density binning.
///!
///! Backing statistic for \@geom-dotplot. Bins observations along x into
///! uniform-width buckets, emits one row per observation with the bin
///! midpoint as `x`, the within-bin stack index as `y`, and the bin width
///! plus per-bin count for reference.

#import "../utils/types.typ": parse-number
#import "../utils/bin.typ": bin-config, bin-domain, bin-midpoint, bin-of

/// Dot-density bin statistic: emit one stacked row per observation.
///
/// Either `bins` or `binwidth` fixes the partition; `binwidth` wins when
/// both are supplied. The `y` column carries each observation's stack index
/// within its bin, so geom-dotplot can place dots at increasing heights.
///
/// \@category Stats
/// \@stability stable
/// \@since 0.4.0
///
/// \@param bins Target number of bins when `binwidth` is `none`.
/// \@param binwidth Fixed bin width. Overrides `bins` when set.
/// \@param stackratio Vertical spacing between stacked dots, in dot units. 1 means touching.
///
/// \@returns Statistic object with `name: "bindot"`, consumed by \@geom-dotplot.
///
/// \@see \@geom-dotplot, \@stat-bin
#let stat-bindot(bins: 30, binwidth: none, stackratio: 1.0) = (
  kind: "stat",
  name: "bindot",
  params: (bins: bins, binwidth: binwidth, stackratio: stackratio),
)

#let apply(data, mapping, params: (:)) = {
  let x-col = if mapping != none { mapping.at("x", default: none) } else {
    none
  }
  if x-col == none { return (data: data, mapping: mapping) }
  let xs = data
    .map(r => parse-number(r.at(x-col, default: none)))
    .filter(v => v != none)
  if xs.len() == 0 { return (data: (), mapping: (x: "x", y: "y")) }
  let (lo, hi) = bin-domain(xs)
  let (n-bins, width) = bin-config(
    lo,
    hi,
    params.at("bins", default: 30),
    params.at("binwidth", default: none),
  )
  let counts = range(n-bins).map(_ => 0)
  let assignments = ()
  for x in xs {
    let idx = bin-of(x, lo, width, n-bins)
    assignments.push((bin: idx, stack: counts.at(idx)))
    counts.at(idx) = counts.at(idx) + 1
  }
  let stackratio = params.at("stackratio", default: 1.0)
  let rows = assignments.map(a => (
    x: bin-midpoint(lo, width, a.bin),
    y: (a.stack + 0.5) * stackratio,
    bin-count: counts.at(a.bin),
    width: width,
  ))
  (data: rows, mapping: (x: "x", y: "y"))
}
