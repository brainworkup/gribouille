///! Bars of observation counts.
///!
///! Thin wrapper around @geom-col that swaps in `stat: "count"` and defaults
///! `position` to `"stack"`. Use this when you want counts; use @geom-col for
///! pre-aggregated heights.

#import "col.typ": geom-col

/// Bar layer that counts rows per x level (stat-count).
///
/// Maps the `x` aesthetic to a discrete variable; the layer then counts
/// rows per x level and draws one bar per count. Use @geom-col instead
/// when y is already computed.
///
/// @category Geoms
/// @stability stable
/// @since 0.0.1
///
/// @param mapping Layer-specific aesthetic mapping built with @aes. Falls back to the plot mapping when `none`.
/// @param data Layer-specific dataset. Falls back to the plot data when `none`.
/// @param width Bar width as a fraction of the category width (0 to 1).
/// @param fill Bar fill colour. `auto` resolves via the fill scale or a neutral default.
/// @param stroke Bar outline; `none` means no border.
/// @param alpha Bar opacity in `[0, 1]`.
/// @param position Position adjustment: `"stack"` (default), `"dodge"`, `"fill"`, or `"identity"`.
/// @param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// @returns Layer dictionary consumed by @plot.
///
/// @examples Plain count of rows per category.
/// ```
/// #let d = (
///   (grp: "a"),
///   (grp: "b"),
///   (grp: "a"),
///   (grp: "c"),
///   (grp: "b"),
///   (grp: "a"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp"),
///   layers: (geom-bar(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @examples Map `fill` to a second column and switch `position` to
/// `"dodge"` to compare counts side by side.
/// ```
/// #let d = (
///   (grp: "a", k: "x"),
///   (grp: "b", k: "x"),
///   (grp: "a", k: "y"),
///   (grp: "c", k: "x"),
///   (grp: "b", k: "y"),
///   (grp: "a", k: "y"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", fill: "k"),
///   layers: (geom-bar(position: "dodge"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @geom-col, @stat-count
#let geom-bar(
  mapping: none,
  data: none,
  width: 0.9,
  fill: auto,
  stroke: none,
  alpha: auto,
  position: "stack",
  inherit-aes: true,
) = geom-col(
  mapping: mapping,
  data: data,
  width: width,
  fill: fill,
  stroke: stroke,
  alpha: alpha,
  stat: "count",
  position: position,
  inherit-aes: inherit-aes,
)
