///! Reference line for a normal Q-Q plot.
///!
///! Thin wrapper around @geom-line that computes its data via @stat-qq-line.

/// Q-Q reference line layer fitted through the IQR of the sample.
///
/// The `sample` aesthetic selects the column whose 25th and 75th quantiles
/// anchor the line; when `sample` is absent the layer falls back to `y`.
///
/// @category Geoms
/// @stability stable
/// @since 0.0.1
///
/// @param mapping Layer-specific aesthetic mapping built with @aes. Falls back to the plot mapping when `none`.
/// @param data Layer-specific dataset. Falls back to the plot data when `none`.
/// @param stroke Line thickness (a Typst length).
/// @param colour Fixed line colour. `auto` resolves via the colour scale or a neutral default.
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
/// #let d = (1, 2, 3, 4, 5).map(v => (v: v))
/// #plot(
///   data: d,
///   mapping: aes(sample: "v"),
///   layers: (geom-qq(), geom-qq-line()),
/// )
/// ```
///
/// @see @geom-qq, @stat-qq-line, @geom-line
#let geom-qq-line(
  mapping: none,
  data: none,
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
  params: (stroke: stroke, colour: colour, alpha: alpha, linetype: linetype),
  stat: "qq-line",
  position: position,
  inherit-aes: inherit-aes,
)
