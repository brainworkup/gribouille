///! Scatter with per-row jitter offset.
///!
///! Thin wrapper around @geom-point that defaults `position` to `"jitter"`.

#import "point.typ": geom-point

/// Scatter layer with @position-jitter applied by default.
///
/// All other parameters mirror @geom-point.
///
/// @category Geoms
/// @stability stable
/// @since 0.0.1
///
/// @param mapping Layer-specific aesthetic mapping built with @aes. Falls back to the plot mapping when `none`.
/// @param data Layer-specific dataset. Falls back to the plot data when `none`.
/// @param size Marker size (a Typst length).
/// @param stroke Marker stroke; `none` means no outline.
/// @param fill Marker fill colour. `auto` resolves via the colour scale or a neutral default.
/// @param alpha Marker opacity in `[0, 1]`.
/// @param shape Marker shape keyword.
/// @param stat Statistical transform name.
/// @param position Position adjustment name. Defaults to `"jitter"`.
/// @param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// @returns Layer dictionary consumed by @plot.
///
/// @example
/// ```
/// #let d = ()
/// #for x in (1, 2, 3) {
///   for _ in range(0, 16) { d.push((x: x, y: 1)) }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-jitter(size: 2pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @geom-point, @position-jitter
#let geom-jitter(
  mapping: none,
  data: none,
  size: 1.5pt,
  stroke: none,
  fill: auto,
  alpha: 1,
  shape: auto,
  stat: "identity",
  position: "jitter",
  inherit-aes: true,
) = geom-point(
  mapping: mapping,
  data: data,
  size: size,
  stroke: stroke,
  fill: fill,
  alpha: alpha,
  shape: shape,
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)
