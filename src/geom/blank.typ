///! Invisible layer that still trains scales.
///!
///! Renders nothing but contributes its data to scale training. Useful for
///! forcing axis ranges without drawing marks, in the spirit of ggplot2's
///! `geom_blank()` and plotnine's `geom_blank`.

/// Invisible layer used to extend trained scales without drawing marks.
///
/// Typical mappings are `x` and / or `y`; any aesthetic in the mapping
/// participates in scale training so the panel reserves room for the
/// implied range.
///
/// @category Geoms
/// @stability stable
/// @since 0.0.1
///
/// @param mapping Layer-specific aesthetic mapping built with @aes. Falls back to the plot mapping when `none`.
/// @param data Layer-specific dataset. Falls back to the plot data when `none`.
/// @param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// @returns Layer dictionary consumed by @plot.
///
/// @example
/// ```
/// //| width: 10cm
/// //| height: 6cm
/// #let frame = ((x: 0, y: 0), (x: 10, y: 5))
/// #plot(
///   data: frame,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-blank(),),
/// )
/// ```
///
/// @see @geom-rug, @geom-function
#let geom-blank(mapping: none, data: none, inherit-aes: true) = (
  kind: "layer",
  geom: "blank",
  mapping: mapping,
  data: data,
  params: (:),
  stat: "identity",
  position: "identity",
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {}
