///! Shortcut groups for theme element overrides.
///!
///! Each `theme-sub-*` constructor wraps \@theme with the prefixed surface
///! keys for one family.

#import "theme.typ": theme

#let _axis-sub(suffix, title, text, line, ticks) = theme(
  ..(
    (
      ("axis-title" + suffix): title,
      ("axis-text" + suffix): text,
      ("axis-line" + suffix): line,
      ("axis-ticks" + suffix): ticks,
    )
  ),
)

/// Shortcut for both axes' title, text, line, and ticks.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.6.0
///
/// \@param title \@element-text or \@element-typst for `axis-title`.
/// \@param text \@element-text or \@element-typst for `axis-text`.
/// \@param line \@element-line or \@element-blank for `axis-line`.
/// \@param ticks \@element-line or \@element-blank for `axis-ticks`.
///
/// \@returns Theme dictionary with the named overrides applied.
///
/// \@examples Red ink on every axis title and tick label, mirrored on the
/// axis line and tick marks.
/// ```
/// #let red-text = element-text(colour: rgb("#cc0000"))
/// #let red-line = element-line(colour: rgb("#cc0000"))
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-sub-axis(
///     title: red-text,
///     text: red-text,
///     line: red-line,
///     ticks: red-line,
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme, \@theme-sub-axis-x, \@theme-sub-axis-y
#let theme-sub-axis(title: none, text: none, line: none, ticks: none) = (
  _axis-sub("", title, text, line, ticks)
)

/// Shortcut for both x axes (top + bottom).
///
/// \@category Themes
/// \@stability stable
/// \@since 0.6.0
///
/// \@param title \@element-text or \@element-typst for `axis-title-x`.
/// \@param text Same for `axis-text-x`.
/// \@param line \@element-line for `axis-line-x`.
/// \@param ticks \@element-line for `axis-ticks-x`.
///
/// \@returns Theme dictionary with the named x-axis overrides applied.
///
/// \@see \@theme-sub-axis, \@theme-sub-axis-y, \@theme-sub-axis-bottom, \@theme-sub-axis-top
#let theme-sub-axis-x(title: none, text: none, line: none, ticks: none) = (
  _axis-sub("-x", title, text, line, ticks)
)

/// Shortcut for both y axes (left + right).
///
/// \@category Themes
/// \@stability stable
/// \@since 0.6.0
///
/// \@param title \@element-text or \@element-typst for `axis-title-y`.
/// \@param text Same for `axis-text-y`.
/// \@param line \@element-line for `axis-line-y`.
/// \@param ticks \@element-line for `axis-ticks-y`.
///
/// \@returns Theme dictionary with the named y-axis overrides applied.
///
/// \@see \@theme-sub-axis, \@theme-sub-axis-x, \@theme-sub-axis-left, \@theme-sub-axis-right
#let theme-sub-axis-y(title: none, text: none, line: none, ticks: none) = (
  _axis-sub("-y", title, text, line, ticks)
)

/// Shortcut for the bottom x axis only.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.6.0
///
/// \@param title Element override for the bottom x axis title.
/// \@param text Element override for the bottom x axis tick labels.
/// \@param line Element override for the bottom x axis line.
/// \@param ticks Element override for the bottom x axis ticks.
///
/// \@returns Theme dictionary scoped to the bottom x axis.
///
/// \@see \@theme-sub-axis-x, \@theme-sub-axis-top
#let theme-sub-axis-bottom(
  title: none,
  text: none,
  line: none,
  ticks: none,
) = _axis-sub("-x-bottom", title, text, line, ticks)

/// Shortcut for the top x axis only.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.6.0
///
/// \@param title Element override for the top x axis title.
/// \@param text Element override for the top x axis tick labels.
/// \@param line Element override for the top x axis line.
/// \@param ticks Element override for the top x axis ticks.
///
/// \@returns Theme dictionary scoped to the top x axis.
///
/// \@see \@theme-sub-axis-x, \@theme-sub-axis-bottom
#let theme-sub-axis-top(
  title: none,
  text: none,
  line: none,
  ticks: none,
) = _axis-sub("-x-top", title, text, line, ticks)

/// Shortcut for the left y axis only.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.6.0
///
/// \@param title Element override for the left y axis title.
/// \@param text Element override for the left y axis tick labels.
/// \@param line Element override for the left y axis line.
/// \@param ticks Element override for the left y axis ticks.
///
/// \@returns Theme dictionary scoped to the left y axis.
///
/// \@see \@theme-sub-axis-y, \@theme-sub-axis-right
#let theme-sub-axis-left(
  title: none,
  text: none,
  line: none,
  ticks: none,
) = _axis-sub("-y-left", title, text, line, ticks)

/// Shortcut for the right y axis only.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.6.0
///
/// \@param title Element override for the right y axis title.
/// \@param text Element override for the right y axis tick labels.
/// \@param line Element override for the right y axis line.
/// \@param ticks Element override for the right y axis ticks.
///
/// \@returns Theme dictionary scoped to the right y axis.
///
/// \@see \@theme-sub-axis-y, \@theme-sub-axis-left
#let theme-sub-axis-right(
  title: none,
  text: none,
  line: none,
  ticks: none,
) = _axis-sub("-y-right", title, text, line, ticks)

/// Shortcut for legend text and title.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.6.0
///
/// \@param text \@element-text or \@element-typst for `legend-text`.
/// \@param title Same for `legend-title`.
///
/// \@returns Theme dictionary with the named legend overrides applied.
///
/// \@examples Bold legend titles via the shortcut group.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5, k: if calc.even(i) { "a" } else { "b" }))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "k"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-sub-legend(title: element-text(weight: "bold")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme
#let theme-sub-legend(text: none, title: none) = theme(
  legend-text: text,
  legend-title: title,
)

/// Shortcut for panel grid and background.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.6.0
///
/// \@param grid \@element-line or \@element-blank for `panel-grid`.
/// \@param background \@element-rect or \@element-blank for `panel-background`.
///
/// \@returns Theme dictionary with the named panel overrides applied.
///
/// \@see \@theme
#let theme-sub-panel(grid: none, background: none) = theme(
  panel-grid: grid,
  panel-background: background,
)

/// Shortcut for plot title, subtitle, caption, and outer margin.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.6.0
///
/// \@param title \@element-text or \@element-typst for `plot-title`.
/// \@param subtitle Same for `plot-subtitle`.
/// \@param caption Same for `plot-caption`.
/// \@param margin \@margin record for `plot-margin`.
///
/// \@returns Theme dictionary with the named plot overrides applied.
///
/// \@see \@theme
#let theme-sub-plot(
  title: none,
  subtitle: none,
  caption: none,
  margin: none,
) = theme(
  plot-title: title,
  plot-subtitle: subtitle,
  plot-caption: caption,
  plot-margin: margin,
)

/// Shortcut for facet strip text and background.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.6.0
///
/// \@param text \@element-text or \@element-typst for `strip-text`.
/// \@param background \@element-rect or \@element-blank for `strip-background`.
///
/// \@returns Theme dictionary with the named strip overrides applied.
///
/// \@see \@theme
#let theme-sub-strip(text: none, background: none) = theme(
  strip-text: text,
  strip-background: background,
)
