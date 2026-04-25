///! Dark theme preset.
///!
///! Dark grey panel with white grid lines and dark axis text.
///! Mirrors ggplot2's / plotnine's `theme_dark()`.

#import "defaults.typ": _tr-ink, _tr-paper

/// Dark theme: dark grey panel, white grid, dark axis text.
///
/// Equivalent to ggplot2's / plotnine's `theme_dark()`.
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
///   theme: theme-dark(),
/// )
/// ```
///
/// @see @theme-grey, @theme-minimal, @theme-classic, @theme-light, @theme-void, @theme
#let theme-dark(ink: _tr-ink, paper: _tr-paper, accent: rgb("#3366FF")) = (
  kind: "theme",
  name: "dark",
  ink: ink,
  paper: paper,
  accent: accent,
  panel-fill: rgb("#7f7f7f"),
  grid-colour: paper,
  grid-thickness: 0.5pt,
  axis-colour: rgb("#666666"),
  axis-thickness: 0.5pt,
  axis-text-colour: rgb("#4d4d4d"),
)
