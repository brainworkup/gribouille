///! Line connecting binned counts along x.
///!
///! Equivalent to @geom-histogram but draws a polyline through bin
///! midpoints rather than bars. Uses @stat-bin under the hood; choose
///! either `bins` or `binwidth`.

/// Frequency polygon: a line through per-bin counts of the x aesthetic.
///
/// @category Geoms
/// @stability stable
/// @since 0.0.1
///
/// @param mapping Layer-specific aesthetic mapping built with @aes. Must map `x`.
/// @param data Layer-specific dataset. Falls back to the plot data when `none`.
/// @param bins Target number of bins when `binwidth` is `none`.
/// @param binwidth Fixed bin width. Overrides `bins` when set.
/// @param stroke Line thickness (a Typst length).
/// @param colour Fixed line colour. `auto` resolves via the colour scale.
/// @param alpha Line opacity in `[0, 1]`.
/// @param linetype Dash keyword. `auto` honours the linetype scale.
/// @param position Position adjustment name. Usually `"identity"`.
/// @param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// @returns Layer dictionary consumed by @plot.
///
/// @example
/// ```
/// //| width: 10cm
/// //| height: 6cm
/// #let d = range(0, 40).map(i => (
///   x: calc.sin(i * 0.3) * 5 + i * 0.2,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x"),
///   layers: (geom-freqpoly(bins: 12, stroke: 1pt),),
/// )
/// ```
///
/// @see @geom-histogram, @stat-bin, @geom-line
#let geom-freqpoly(
  mapping: none,
  data: none,
  bins: 30,
  binwidth: none,
  stroke: 0.8pt,
  colour: auto,
  alpha: 1,
  linetype: auto,
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "line",
  mapping: mapping,
  data: data,
  params: (
    stroke: stroke,
    colour: colour,
    alpha: alpha,
    linetype: linetype,
    bins: bins,
    binwidth: binwidth,
  ),
  stat: "bin",
  position: position,
  inherit-aes: inherit-aes,
)
