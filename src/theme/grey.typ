///! Grey theme preset.
///!
///! Light grey panel background with white gridlines and thin black axes.
///! Library default. Derives element colours from `ink` and `paper` via
///! `col-mix`.

#import "../utils/colour.typ": col-mix
#import "defaults.typ": _tr-ink, _tr-paper

/// Grey theme: light grey panel with white gridlines.
///
/// This is the gribouille default theme.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.0.1
///
/// \@param ink Foreground colour (text, axis lines). Default: `black`.
/// \@param paper Background colour. Default: `white`.
/// \@param accent Accent colour. Default: `rgb("#3366FF")`.
///
/// \@returns Theme dictionary consumed by \@plot.
///
/// \@examples Library default: light grey panel with white gridlines.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-grey(),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Override `ink` and `paper` for a tinted theme without
/// switching theme function.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-grey(ink: rgb("#2c3e50"), paper: rgb("#fdf6e3")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme-minimal, \@theme-classic, \@theme-void, \@theme
#let theme-grey(ink: _tr-ink, paper: _tr-paper, accent: rgb("#3366FF")) = (
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
