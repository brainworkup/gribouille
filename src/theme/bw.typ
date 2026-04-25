///! Black-and-white theme preset.
///!
///! White panel framed by a thin black border, with light grey grid lines.
///! Mirrors ggplot2's / plotnine's `theme_bw()`.

#import "defaults.typ": _tr-ink, _tr-paper

/// Black-and-white theme: white panel, black axes, light grey grid.
///
/// Equivalent to ggplot2's / plotnine's `theme_bw()`.
///
/// @category Themes
/// @stability stable
/// @since 0.0.1
///
/// @param ink Foreground colour (axis lines, text). Default: `black`.
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
///   theme: theme-bw(),
/// )
/// ```
///
/// @see @theme-grey, @theme-minimal, @theme-classic, @theme-void, @theme
#let theme-bw(ink: _tr-ink, paper: _tr-paper, accent: rgb("#3366FF")) = (
  kind: "theme",
  name: "bw",
  ink: ink,
  paper: paper,
  accent: accent,
  panel-fill: paper,
  grid-colour: rgb("#ebebeb"),
  grid-thickness: 0.4pt,
  axis-colour: ink,
  axis-thickness: 0.5pt,
)
