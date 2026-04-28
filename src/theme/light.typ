///! Light theme preset.
///!
///! Light grey panel with white grid lines and a subtle grey border.

#import "../utils/colour.typ": col-mix
#import "defaults.typ": _tr-ink, _tr-paper

/// Light theme: light grey panel, white grid, soft grey axes.
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
/// @examples Soft grey axes on a tinted panel.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-light(),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @examples Override `accent` to give the data ink a custom highlight
/// colour without losing the soft panel.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-light(accent: rgb("#1b9e77")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @theme-grey, @theme-minimal, @theme-classic, @theme-dark, @theme-void, @theme
#let theme-light(ink: _tr-ink, paper: _tr-paper, accent: rgb("#3366FF")) = (
  kind: "theme",
  name: "light",
  ink: ink,
  paper: paper,
  accent: accent,
  panel-fill: col-mix(ink, paper, 0.9216),
  grid-colour: paper,
  grid-thickness: 0.5pt,
  axis-colour: col-mix(ink, paper, 0.8),
  axis-thickness: 0.5pt,
  axis-text-colour: col-mix(ink, paper, 0.302),
)
