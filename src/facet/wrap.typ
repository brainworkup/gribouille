///! Wrap faceting.
///!
///! One panel per level of a discrete variable, wrapped into a grid of
///! `ncol` columns (or `nrow` rows).

#import "shared.typ"
#import "labellers.typ": label-value

/// Wrap facets: one panel per level of a discrete variable.
///
/// Panels are arranged into a grid of `ncol` columns (or `nrow` rows when
/// `ncol` is `none`).
///
/// \@category Facets
/// \@stability stable
/// \@since 0.0.1
///
/// \@param var Name of the discrete column whose levels drive the panels.
/// \@param ncol Number of columns in the panel grid, or `none` for automatic.
/// \@param nrow Number of rows in the panel grid, or `none` for automatic.
/// \@param scales Scale policy. One of `"fixed"` (default, every panel
///   shares both axes), `"free"` (each panel trains x and y on its own
///   subset), `"free_x"` (only x is per-panel), or `"free_y"` (only y is
///   per-panel). Non-positional scales (colour, fill, size, shape,
///   linetype) are always shared so legends stay consistent. An explicit
///   `coord-cartesian(xlim:, ylim:)` overrides the per-panel domain on
///   the corresponding axis, pinning every panel to the same range.
/// \@param labeller Labeller controlling strip text. Defaults to
///   `label-value()` which shows the level as-is.
///
/// \@returns Facet dictionary consumed by \@plot.
///
/// \@examples One panel per level of `sp`, three columns, with each panel
/// training y independently.
/// ```
/// #let d = ()
/// #for sp in ("a", "b", "c") {
///   for i in range(0, 6) {
///     d.push((sp: sp, x: i, y: i + calc.rem(i, 3)))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   facet: facet-wrap("sp", ncol: 3, scales: "free_y"),
///   width: 12cm,
///   height: 7cm,
/// )
/// ```
///
/// \@examples Default `scales: "fixed"` shares both axes across panels;
/// useful when you want comparable scales side by side.
/// ```
/// #let d = ()
/// #for sp in ("a", "b", "c", "d") {
///   for i in range(0, 6) {
///     d.push((sp: sp, x: i, y: i + calc.rem(i, 3)))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   facet: facet-wrap("sp", nrow: 2),
///   width: 12cm,
///   height: 7cm,
/// )
/// ```
///
/// \@examples One panel per penguin island, sharing axes so the species
/// clusters can be compared visually across panels.
/// ```
/// #plot(
///   data: penguins,
///   mapping: aes(
///     x: "flipper-len",
///     y: "body-mass",
///     fill: "species",
///   ),
///   layers: (geom-point(size: 2pt, alpha: 0.85),),
///   facet: facet-wrap("island", ncol: 3),
///   labs: labs(x: "Flipper length (mm)", y: "Body mass (g)", fill: "Species"),
///   width: 14cm,
///   height: 5cm,
/// )
/// ```
///
/// \@see \@facet-grid, \@plot
#let facet-wrap(
  var,
  ncol: none,
  nrow: none,
  scales: "fixed",
  labeller: label-value(),
) = {
  if not ("fixed", "free", "free_x", "free_y").contains(scales) {
    panic(
      "facet-wrap: scales must be \"fixed\", \"free\", \"free_x\", or \"free_y\"",
    )
  }
  (
    kind: "facet",
    facet: "wrap",
    var: var,
    ncol: ncol,
    nrow: nrow,
    scales: scales,
    labeller: labeller,
  )
}

#let levels-for(prepared, var) = shared.levels-for(prepared, var)

#let filter-layers(prepared, var, value) = shared.filter-layers-multi(
  prepared,
  ((var, value),),
)
