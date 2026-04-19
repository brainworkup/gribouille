///! Minimal theme preset.
///!
///! White panel with thin light grey gridlines, no axis lines, no tick marks.
///! Matches ggplot2's / plotnine's `theme_minimal()`.

/// Minimal theme: white panel, light grey gridlines, no axis lines.
///
/// Equivalent to ggplot2's / plotnine's `theme_minimal()`. For the gribouille default
/// (grey panel with white gridlines) use @theme-grey.
///
/// @category Themes
/// @stability stable
/// @since 0.0.1
///
/// @param ink Foreground colour (text). Default: `black`.
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
///   theme: theme-minimal(),
/// )
/// ```
///
/// @see @theme-grey, @theme-classic, @theme-void, @theme
#let theme-minimal(ink: black, paper: white, accent: rgb("#3366FF")) = (
  kind: "theme",
  name: "minimal",
  ink: ink,
  paper: paper,
  accent: accent,
  panel-fill: none,
  grid-colour: rgb("#ebebeb"),
  grid-thickness: 0.4pt,
  axis-colour: none,
  axis-thickness: 0pt,
  tick-length: 0,
)
