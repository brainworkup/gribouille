///! Drop arbitrary Typst content into the legend area.
///!
///! Bind via \@guides under any key (the name only routes the override; the
///! content has no associated scale) to render a free-form block alongside
///! the auto-built legends. Useful for annotations, swatch keys produced by
///! external code, branding, or anything Typst can typeset.

/// Render arbitrary Typst content as a legend slot.
///
/// Unlike scale-driven guides, `guide-custom` carries its own content and
/// has no aesthetic to consume; it sits next to the auto-built legends in
/// the order it appears in the \@guides binding.
///
/// \@category Guides
/// \@stability stable
/// \@since 0.5.0
///
/// \@param content Typst content block (markup, image, table, ...).
/// \@param width Block width as a length, or `auto` for the default 3cm.
/// \@param height Block height as a length, or `auto` for the default 2cm.
/// \@param title Optional title rendered above the block using the legend-title surface.
///
/// \@returns Marker dictionary tagged `kind: "guide-custom"`, consumed by \@guides.
///
/// \@examples Add a free-form annotation block alongside the colour legend.
/// ```
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "b"),
///   (x: 3, y: 3, g: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt),),
///   guides: guides(
///     custom: guide-custom(
///       [Series sourced from internal sales reports.],
///       width: 4cm,
///       height: 1.4cm,
///       title: "Notes",
///     ),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@guides, \@guide-legend
#let guide-custom(
  content,
  width: auto,
  height: auto,
  title: none,
) = (
  kind: "guide-custom",
  content: content,
  width: width,
  height: height,
  title: title,
)
