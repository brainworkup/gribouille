///! Dark theme preset.
///!
///! Dark grey panel with white grid lines and dark axis text.

#import "../utils/colour.typ": col-mix
#import "defaults.typ": _tr-ink, _tr-paper

/// Dark theme: dark grey panel, white grid, dark axis text.
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
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-dark(),
///   width: 10cm,
///   height: 6cm,
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
  panel-fill: col-mix(ink, paper, 0.498),
  grid-colour: paper,
  grid-thickness: 0.5pt,
  axis-colour: col-mix(ink, paper, 0.4),
  axis-thickness: 0.5pt,
  axis-text-colour: col-mix(ink, paper, 0.302),
)
