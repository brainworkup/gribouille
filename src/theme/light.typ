///! Light theme preset.
///!
///! Light grey panel with white grid lines and a subtle grey border.

#import "../utils/colour.typ": col-mix
#import "defaults.typ": _tr-ink, _tr-paper
#import "elements.typ": element-line, element-rect, element-text
#import "theme.typ": _apply-overrides

/// Light theme: light grey panel, white grid, soft grey axes.
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
/// \@examples Soft grey axes on a tinted panel.
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
/// \@examples Override `accent` to give the data ink a custom highlight
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
/// \@examples Tinted panel background on top of the soft preset.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-light(panel-background: element-rect(fill: rgb("#fff7e6"))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme-grey, \@theme-minimal, \@theme-classic, \@theme-dark, \@theme-void, \@theme
#let theme-light(
  ink: _tr-ink,
  paper: _tr-paper,
  accent: rgb("#3366FF"),
  ..fields,
) = {
  let base = (
    kind: "theme",
    name: "light",
    ink: ink,
    paper: paper,
    accent: accent,
    panel-background: element-rect(fill: col-mix(ink, paper, 0.9216)),
    panel-grid: element-line(
      colour: col-mix(ink, paper, 0.7),
      thickness: 0.5pt,
    ),
    axis-line: element-line(colour: col-mix(ink, paper, 0.8), thickness: 0.5pt),
    axis-text: element-text(colour: col-mix(ink, paper, 0.302)),
  )
  _apply-overrides(base, fields)
}
