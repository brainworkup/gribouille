///! Test theme preset.
///!
///! Loud red borders and obvious styling so panel, axis, and grid regions are
///! easy to identify visually.

#import "defaults.typ": _tr-ink, _tr-paper

/// Test theme: white panel, red axes, no grid, for visual debugging.
///
/// Designed to make theme regions stand out so test renderings are easy to
/// inspect.
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
///   theme: theme-test(),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @theme-grey, @theme-minimal, @theme-classic, @theme-bw, @theme-void, @theme
#let theme-test(ink: _tr-ink, paper: _tr-paper, accent: rgb("#3366FF")) = (
  kind: "theme",
  name: "test",
  ink: ink,
  paper: paper,
  accent: accent,
  panel-fill: paper,
  grid-colour: none,
  grid-thickness: 0pt,
  axis-colour: rgb("#cc0000"),
  axis-thickness: 1pt,
  axis-text-colour: rgb("#cc0000"),
  strip-fill: rgb("#ffd6d6"),
  strip-text-colour: rgb("#cc0000"),
)
