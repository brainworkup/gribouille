///! Classic theme preset.
///!
///! White panel background with visible axis borders and no gridlines.

#import "defaults.typ": _tr-ink, _tr-paper
#import "theme.typ": _apply-overrides

/// Classic theme: white panel, axis borders, no gridlines.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.0.1
///
/// \@param ink Foreground colour (axis lines, text). Default: `black`.
/// \@param paper Background colour. Default: `white`.
/// \@param accent Accent colour. Default: `rgb("#3366FF")`.
/// \@param ..fields Extra overrides forwarded to \@theme; see its docs for the full catalogue of structured and flat keys.
///
/// \@returns Theme dictionary consumed by \@plot.
///
/// \@examples Classic axis borders with no gridlines.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-classic(),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Switch `paper` to a tinted background while keeping the
/// classic axis style.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-classic(paper: rgb("#fff7e6")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Bump the axis title size on top of the classic preset.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-classic(axis-title: element-text(size: 14pt)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme-grey, \@theme-minimal, \@theme-void, \@theme
#let theme-classic(
  ink: _tr-ink,
  paper: _tr-paper,
  accent: rgb("#3366FF"),
  ..fields,
) = {
  let base = (
    kind: "theme",
    name: "classic",
    ink: ink,
    paper: paper,
    accent: accent,
    panel-fill: paper,
    grid-colour: none,
    grid-thickness: 0pt,
    axis-colour: ink,
    axis-thickness: 0.6pt,
  )
  _apply-overrides(base, fields)
}
