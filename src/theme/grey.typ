///! Grey theme preset.
///!
///! Light grey panel background with white gridlines and thin black axes.
///! Matches ggplot2's / plotnine's `theme_gray()` and is the library default.
///! Derives element colours from `ink` and `paper` via `col-mix`, mirroring
///! ggplot2 v4 exactly.

#import "../utils/colour.typ": col-mix

/// Grey theme: light grey panel with white gridlines.
///
/// This is the gribouille default, equivalent to ggplot2's / plotnine's `theme_gray()`.
///
/// @category Themes
/// @stability stable
/// @since 0.0.1
///
/// @param ink Foreground colour (text, axis lines). Default: `black`.
/// @param paper Background colour. Default: `white`.
/// @param accent Accent colour. Default: `rgb("#3366FF")`.
///
/// @returns Theme dictionary consumed by @plot.
///
/// @example
/// ```
/// //| width: 10cm
/// //| height: 6cm
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-grey(),
/// )
/// ```
///
/// @see @theme-minimal, @theme-classic, @theme-void, @theme
#let theme-grey(ink: black, paper: white, accent: rgb("#3366FF")) = (
  kind: "theme",
  name: "grey",
  ink: ink,
  paper: paper,
  accent: accent,
  panel-fill: col-mix(ink, paper, 0.92),
  grid-colour: paper,
  grid-thickness: 0.5pt,
  axis-colour: ink,
  axis-thickness: 0.5pt,
  axis-text-colour: col-mix(ink, paper, 0.302),
  strip-fill: col-mix(ink, paper, 0.85),
)
