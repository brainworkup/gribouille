///! Legend guide customisation.
///!
///! Build a guide spec the legend renderer respects when bound to an
///! aesthetic via @guides. Customise level order with `reverse` and the
///! swatch grid with `nrow` or `ncol`.

/// Customise the legend (swatch) for an aesthetic.
///
/// The returned spec carries customisation only; it is bound to an aesthetic
/// when passed through @guides as `colour: guide-legend(...)` or similar,
/// and applied by the legend renderer when drawing the swatch.
///
/// @category Guides
/// @stability stable
/// @since 0.0.1
///
/// @param title Override the legend title; `none` keeps the default from labs or scale.
/// @param nrow Number of rows when laying out levels in a grid; `none` for default.
/// @param ncol Number of columns when laying out levels in a grid; `none` for default.
/// @param reverse Reverse the order of levels.
///
/// @returns Guide dictionary tagged `kind: "guide"`, consumed by @guides.
///
/// @example
/// ```
/// //| width: 10cm
/// //| height: 6cm
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "b"),
///   (x: 3, y: 3, g: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt),),
///   guides: guides(colour: guide-legend(reverse: true)),
/// )
/// ```
///
/// @see @guides, @guide-none, @plot
#let guide-legend(title: none, nrow: none, ncol: none, reverse: false) = (
  kind: "guide",
  aesthetic: none,
  title: title,
  nrow: nrow,
  ncol: ncol,
  reverse: reverse,
)
