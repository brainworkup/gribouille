///! Legend guide customisation.
///!
///! Build a guide spec the legend renderer respects when bound to an
///! aesthetic via \@guides. Customise level order with `reverse` and the
///! swatch grid with `nrow` or `ncol`.

/// Customise the legend (swatch) for an aesthetic.
///
/// The returned spec carries customisation only; it is bound to an aesthetic
/// when passed through \@guides as `colour: guide-legend(...)` or similar,
/// and applied by the legend renderer when drawing the swatch.
///
/// \@category Guides
/// \@stability stable
/// \@since 0.0.1
///
/// \@param title Override the legend title; `none` keeps the default from labs or scale.
/// \@param nrow Number of rows when laying out levels in a grid; `none` for default.
/// \@param ncol Number of columns when laying out levels in a grid; `none` for default.
/// \@param reverse Reverse the order of levels.
///
/// \@returns Guide dictionary tagged `kind: "guide"`, consumed by \@guides.
///
/// \@examples Reverse the level order shown in the legend.
/// ```
/// //| alt: "Scatter chart of three coloured points with the fill legend listing levels c, b, a from top to bottom instead of the default a, b, c."
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "b"),
///   (x: 3, y: 3, g: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "g"),
///   layers: (geom-point(size: 3pt),),
///   guides: guides(fill: guide-legend(reverse: true)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Override the legend title and lay swatches out across two
/// columns to compress the legend horizontally.
/// ```
/// //| alt: "Scatter chart of four-level fill mapping with a custom Group legend title and the four swatches laid out in two columns."
/// #let d = ()
/// #for grp in ("a", "b", "c", "d") {
///   for i in range(0, 4) { d.push((x: i, y: i, g: grp)) }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "g"),
///   layers: (geom-point(size: 3pt),),
///   guides: guides(fill: guide-legend(title: "Group", ncol: 2)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Penguin species legend rendered as a 3-column legend so it
/// sits flat under a wide panel.
/// ```
/// //| alt: "Scatter chart of penguin flipper length versus body mass with a wide Species legend laid out in three columns under the panel."
/// #plot(
///   data: penguins,
///   mapping: aes(x: "flipper-len", y: "body-mass", fill: "species"),
///   layers: (geom-point(size: 2pt),),
///   guides: guides(fill: guide-legend(title: "Species", ncol: 3)),
///   labs: labs(x: "Flipper Length (mm)", y: "Body Mass (g)"),
///   width: 14cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@guides, \@guide-none, \@plot
#let guide-legend(title: none, nrow: none, ncol: none, reverse: false) = (
  kind: "guide",
  aesthetic: none,
  title: title,
  nrow: nrow,
  ncol: ncol,
  reverse: reverse,
)
