///! Dark theme preset.
///!
///! Dark grey panel with white grid lines and dark axis text.

#import "../utils/colour.typ": col-mix
#import "defaults.typ": _tr-ink, _tr-paper
#import "theme.typ": _apply-overrides

/// Dark theme: dark grey panel, white grid, dark axis text.
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
/// \@examples Dark grey panel with light gridlines for high-contrast slides.
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
/// \@examples Pair the dark theme with a non-default `accent` for branded
/// slides.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-dark(accent: rgb("#ffd700")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Drop the panel grid for a starker look while keeping the
/// dark preset.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-dark(panel-grid: element-blank()),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme-grey, \@theme-minimal, \@theme-classic, \@theme-light, \@theme-void, \@theme
#let theme-dark(
  ink: _tr-ink,
  paper: _tr-paper,
  accent: rgb("#3366FF"),
  ..fields,
) = {
  let base = (
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
  _apply-overrides(base, fields)
}
