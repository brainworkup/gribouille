///! Minimal theme preset.
///!
///! White panel with thin light grey gridlines, no axis lines, no tick marks.

#import "defaults.typ": _tr-ink, _tr-paper
#import "elements.typ": element-blank, element-line
#import "theme.typ": _apply-overrides

/// Minimal theme: white panel, light grey gridlines, no axis lines.
///
/// For the gribouille default (grey panel with white gridlines) use \@theme-grey.
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
/// \@examples Minimal style: faint gridlines, no axis lines or tick marks.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-minimal(),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Pair the minimal theme with a coloured `accent` for slide
/// decks where you still want a brand colour.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-minimal(accent: rgb("#1f77b4")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Spot-override individual elements without rebuilding the
/// theme from scratch.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-minimal(axis-title: element-text(size: 14pt)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme-grey, \@theme-classic, \@theme-void, \@theme
#let theme-minimal(
  ink: _tr-ink,
  paper: _tr-paper,
  accent: rgb("#3366FF"),
  ..fields,
) = {
  let base = (
    kind: "theme",
    name: "minimal",
    ink: ink,
    paper: paper,
    accent: accent,
    panel-background: element-blank(),
    panel-grid: element-line(colour: rgb("#ebebeb"), thickness: 0.4pt),
    axis-line: element-blank(),
    tick-length: 0cm,
  )
  _apply-overrides(base, fields)
}
