///! Test theme preset.
///!
///! Loud red borders and obvious styling so panel, axis, and grid regions are
///! easy to identify visually.

#import "defaults.typ": _tr-ink, _tr-paper
#import "elements.typ": element-blank, element-line, element-rect, element-text
#import "theme.typ": _preset

/// Test theme: white panel, red axes, no grid, for visual debugging.
///
/// Designed to make theme regions stand out so test renderings are easy to
/// inspect.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.0.1
///
/// \@param ink Foreground colour (text). Default: `black`.
/// \@param paper Background colour. Default: `white`.
/// \@param accent Accent colour. Default: `rgb("#3366FF")`.
/// \@param ..fields Extra overrides forwarded to \@theme; see its docs for the full catalogue of structured and flat keys.
///
/// \@returns Theme dictionary consumed by \@plot.
///
/// \@examples Loud red axes and strips so theme regions are easy to spot.
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
/// \@examples Tweak a single field of the test preset to focus a debug
/// session on one surface.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-test(strip-background: element-rect(fill: rgb("#ffe8b3"))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Particularly handy with facets to verify strip styling.
/// ```
/// #let d = ()
/// #for sp in ("a", "b") {
///   for i in range(0, 6) {
///     d.push((sp: sp, x: i, y: i * 0.5))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   facet: facet-wrap("sp"),
///   theme: theme-test(),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme-grey, \@theme-minimal, \@theme-classic, \@theme-bw, \@theme-void, \@theme
#let theme-test(
  ink: _tr-ink,
  paper: _tr-paper,
  accent: rgb("#3366FF"),
  ..fields,
) = _preset(
  "test",
  ink,
  paper,
  accent,
  (
    panel-background: element-rect(fill: paper),
    panel-grid: element-blank(),
    axis-line: element-line(colour: rgb("#cc0000"), thickness: 1pt),
    axis-text: element-text(colour: rgb("#cc0000")),
    strip-background: element-rect(fill: rgb("#ffd6d6")),
    strip-text: element-text(colour: rgb("#cc0000")),
  ),
  fields,
)
