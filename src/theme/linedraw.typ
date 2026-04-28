///! Linedraw theme preset.
///!
///! White panel framed by a heavier black border, with very faint grid lines.

#import "../utils/colour.typ": col-mix
#import "defaults.typ": _tr-ink, _tr-paper

/// Linedraw theme: white panel, strong black axes, very faint grid.
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
/// @examples Strong black border around a white panel with faint grid.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-linedraw(),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @examples Switch `ink` to a softer hue for a less stark publication
/// look while keeping the heavy axis frame.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-linedraw(ink: rgb("#2c3e50")),
///   width: 10cm,
///   height: 6cm,
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
  grid-colour: col-mix(ink, paper, 0.9412),
  grid-thickness: 0.3pt,
  axis-colour: ink,
  axis-thickness: 0.8pt,
  axis-text-colour: ink,
)
