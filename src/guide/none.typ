///! Suppress the legend for an aesthetic.
///!
///! Bind to an aesthetic via @guides to skip drawing the corresponding
///! legend without affecting the underlying scale.

/// Suppress the legend for an aesthetic.
///
/// When bound to an aesthetic via @guides, the legend renderer skips that
/// aesthetic's guide entirely while leaving the scale and mapping intact.
///
/// @category Guides
/// @stability stable
/// @since 0.0.1
///
/// @returns Marker dictionary tagged `kind: "guide"` with `suppress: true`.
///
/// @examples Drop the colour legend without removing the colour mapping.
/// ```
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt),),
///   guides: guides(colour: guide-none()),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @examples Suppress multiple legends at once when the encoding is
/// self-explanatory from context.
/// ```
/// #let d = (
///   (x: 1, y: 1, g: "a", w: 1),
///   (x: 2, y: 2, g: "b", w: 2),
///   (x: 3, y: 3, g: "c", w: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g", size: "w"),
///   layers: (geom-point(),),
///   guides: guides(colour: guide-none(), size: guide-none()),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @guides, @guide-legend, @plot
#let guide-none() = (kind: "guide", suppress: true)
