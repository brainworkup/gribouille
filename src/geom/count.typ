///! Scatter markers sized by the count of overplotted `(x, y)` pairs.
///!
///! Thin wrapper over @geom-point that defaults `stat: "sum"`. The backing
///! @stat-sum aggregates duplicate `(x, y)` rows into one row per unique pair
///! and exposes the count via the `size` aesthetic.

/// Count layer drawing one marker per unique `(x, y)`, sized by frequency.
///
/// @category Geoms
/// @stability stable
/// @since 0.0.1
///
/// @param mapping Layer-specific aesthetic mapping built with @aes. Falls back to the plot mapping when `none`.
/// @param data Layer-specific dataset. Falls back to the plot data when `none`.
/// @param size Marker size (a Typst length). Used as the fixed size when no size scale is active.
/// @param stroke Marker stroke; `none` means no outline.
/// @param fill Marker fill colour. `auto` resolves via the colour scale or a neutral default.
/// @param colour Fixed marker outline colour. `auto` resolves via the colour scale, falling back to the theme `ink`. Only takes effect when `stroke` is non-zero.
/// @param alpha Marker opacity in `[0, 1]`.
/// @param shape Marker shape keyword. `auto` honours the shape scale.
/// @param stat Statistical transform name. Defaults to `"sum"`.
/// @param position Position adjustment name. Usually `"identity"`.
/// @param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// @returns Layer dictionary consumed by @plot.
///
/// @examples Marker size grows with the number of duplicate `(x, y)` rows.
/// ```
/// #let d = (
///   (x: 1, y: 1),
///   (x: 1, y: 1),
///   (x: 2, y: 2),
///   (x: 3, y: 3),
///   (x: 3, y: 3),
///   (x: 3, y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-count(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @examples Pair with @scale-size-area to give markers an area-proportional
/// scaling (instead of a radius-proportional one).
/// ```
/// #let d = (
///   (x: 1, y: 1),
///   (x: 1, y: 1),
///   (x: 2, y: 2),
///   (x: 3, y: 3),
///   (x: 3, y: 3),
///   (x: 3, y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-count(),),
///   scales: (scale-size-area(range: (1pt, 12pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @geom-point, @stat-sum
#let geom-count(
  mapping: none,
  data: none,
  size: 3pt,
  stroke: none,
  fill: auto,
  colour: auto,
  alpha: 1,
  shape: auto,
  stat: "sum",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "point",
  mapping: mapping,
  data: data,
  params: (
    size: size,
    stroke: stroke,
    fill: fill,
    colour: colour,
    alpha: alpha,
    shape: shape,
  ),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)
