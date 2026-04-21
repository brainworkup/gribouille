///! Void theme preset.
///!
///! No axes, grid, or panel background. Useful when the plot stands on its
///! own without an axis frame (e.g. maps, annotated figures).

#import "defaults.typ": _tr-ink

/// Void theme: no axes, no grid, no panel background.
///
/// @category Themes
/// @stability stable
/// @since 0.0.1
///
/// @param ink Foreground colour. Default: `black`.
/// @param paper Background colour. Default: transparent (`rgb(0, 0, 0, 0)`).
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
///   theme: theme-void(),
/// )
/// ```
///
/// @see @theme-grey, @theme-minimal, @theme-classic, @theme
#let theme-void(
  ink: _tr-ink,
  paper: rgb(0, 0, 0, 0),
  accent: rgb("#3366FF"),
) = (
  kind: "theme",
  name: "void",
  ink: ink,
  paper: paper,
  accent: accent,
  panel-fill: none,
  grid-colour: none,
  grid-thickness: 0pt,
  axis-colour: none,
  axis-thickness: 0pt,
  tick-length: 0,
  tick-labels: false,
  axis-title-size: 0pt,
)
