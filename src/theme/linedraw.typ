///! Linedraw theme preset.
///!
///! White panel framed by a heavier black border, with very faint grid lines.
///! Mirrors ggplot2's / plotnine's `theme_linedraw()`.

#import "defaults.typ": _tr-ink, _tr-paper

/// Linedraw theme: white panel, strong black axes, very faint grid.
///
/// Equivalent to ggplot2's / plotnine's `theme_linedraw()`.
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
///   theme: theme-linedraw(),
/// )
/// ```
///
/// @see @theme-grey, @theme-minimal, @theme-classic, @theme-bw, @theme-void, @theme
#let theme-linedraw(ink: _tr-ink, paper: _tr-paper, accent: rgb("#3366FF")) = (
  kind: "theme",
  name: "linedraw",
  ink: ink,
  paper: paper,
  accent: accent,
  panel-fill: paper,
  grid-colour: rgb("#f0f0f0"),
  grid-thickness: 0.3pt,
  axis-colour: ink,
  axis-thickness: 0.8pt,
  axis-text-colour: ink,
)
