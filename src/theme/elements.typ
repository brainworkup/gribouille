///! Structured theme elements.
///!
///! `element_*` constructors. \@theme translates these into the flat theme
///! fields consumed internally by `merge-theme`.

/// Text element: font size, weight, colour, and angle.
///
/// Pass the result to \@theme under keys like `axis-text`, `axis-title`,
/// `legend-text`, or `legend-title`.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.0.1
///
/// \@param size Text size (a Typst length), or `none` to inherit.
/// \@param weight Font weight (e.g. `"regular"`, `"bold"`), or `none` to inherit.
/// \@param colour Text colour, or `none` to inherit.
/// \@param angle Rotation angle (a Typst angle), or `none` to inherit.
/// \@param family Font family (e.g. `"sans"`, `"serif"`), or `none` to inherit.
///
/// \@returns Element dictionary consumed by \@theme.
///
/// \@examples Bigger axis-title font passed via \@theme.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(axis-title: element-text(size: 14pt)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Combine multiple text fields and a rotation angle on axis
/// tick labels.
/// ```
/// #let d = (
///   (q: "Q1", y: 3), (q: "Q2", y: 5), (q: "Q3", y: 4), (q: "Q4", y: 6),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "y"),
///   layers: (geom-col(),),
///   theme: theme(axis-text: element-text(
///     size: 9pt,
///     angle: 30deg,
///     colour: rgb("#1f77b4"),
///   )),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme, \@element-line, \@element-rect, \@element-blank, \@element-typst
#let element-text(
  size: none,
  weight: none,
  colour: none,
  angle: none,
  family: none,
) = (
  kind: "element-text",
  size: size,
  weight: weight,
  colour: colour,
  angle: angle,
  family: family,
)

/// Typst-markup text element: same fields as \@element-text plus
/// automatic Typst-markup evaluation for plain strings reaching this
/// surface.
///
/// Drop-in replacement for \@element-text on any text key. Strings
/// supplied via \@labs, scale names, or scale `labels:` callbacks are
/// evaluated as Typst markup before rendering, so users do not need to
/// wrap each value with \@typst. Per-call \@typst() and content (`[…]`)
/// values still pass through unchanged.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.1.0
///
/// \@param size Text size (a Typst length), or `none` to inherit.
/// \@param weight Font weight (e.g. `"regular"`, `"bold"`), or `none`.
/// \@param colour Text colour, or `none` to inherit.
/// \@param angle Rotation angle (a Typst angle), or `none` to inherit.
/// \@param family Font family, or `none` to inherit.
///
/// \@returns Element dictionary consumed by \@theme.
///
/// \@examples Enable Typst markup for every plot title in a session by
/// setting `plot-title: element-typst()` on the theme.
/// ```
/// #let d = ((x: 1, y: 1), (x: 2, y: 4), (x: 3, y: 9))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   labs: labs(title: "Mean $bar(x)$ over time"),
///   theme: theme(plot-title: element-typst(size: 14pt, weight: "bold")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Mix typst and non-typst surfaces in the same theme:
/// ```
/// #let d = ((x: 1, y: 1), (x: 2, y: 4), (x: 3, y: 9))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   labs: labs(title: "Mean $bar(x)$", x: "Time (s)"),
///   theme: theme(
///     plot-title: element-typst(),
///     axis-title: element-text(),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme, \@element-text, \@typst
#let element-typst(
  size: none,
  weight: none,
  colour: none,
  angle: none,
  family: none,
) = (
  kind: "element-typst",
  size: size,
  weight: weight,
  colour: colour,
  angle: angle,
  family: family,
)

/// Line element: colour and thickness.
///
/// Pass the result to \@theme under keys like `panel-grid` or `axis-line`.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.0.1
///
/// \@param colour Line colour, or `none` to inherit.
/// \@param thickness Line thickness (a Typst length), or `none`.
///
/// \@returns Element dictionary consumed by \@theme.
///
/// \@examples Recolour the panel grid via \@theme.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(panel-grid: element-line(colour: rgb("#d9cfbf"))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Strengthen the axis line by setting both `colour` and
/// `thickness`.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(axis-line: element-line(
///     colour: rgb("#cc0000"),
///     thickness: 1pt,
///   )),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme, \@element-text, \@element-rect, \@element-blank
#let element-line(colour: none, thickness: none) = (
  kind: "element-line",
  colour: colour,
  thickness: thickness,
)

/// Rectangle element: fill and stroke.
///
/// Pass the result to \@theme under keys like `panel-background`.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.0.1
///
/// \@param fill Rectangle fill colour, or `none` to inherit.
/// \@param stroke Rectangle stroke, or `none` to inherit.
///
/// \@returns Element dictionary consumed by \@theme.
///
/// \@examples Tinted panel background via \@theme.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(panel-background: element-rect(fill: rgb("#f7f0e7"))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Add a stroke to frame the panel as well as fill it.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(panel-background: element-rect(
///     fill: rgb("#fff7e6"),
///     stroke: 1pt + rgb("#cc7a00"),
///   )),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme, \@element-text, \@element-line, \@element-blank
#let element-rect(fill: none, stroke: none) = (
  kind: "element-rect",
  fill: fill,
  stroke: stroke,
)

/// Blank element: hides the corresponding theme element.
///
/// Pass the result to \@theme under keys like `panel-grid` or `axis-line`
/// to turn them off entirely.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.0.1
///
/// \@returns Element dictionary consumed by \@theme.
///
/// \@examples Hide the panel grid entirely.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(panel-grid: element-blank()),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Combine `element-blank` with other overrides to remove
/// multiple non-data marks at once.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(
///     panel-grid: element-blank(),
///     axis-line: element-blank(),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme, \@element-text, \@element-line, \@element-rect
#let element-blank() = (kind: "element-blank")

/// Plot-margin specification: padding on each side of the plot canvas.
///
/// Each side accepts a Typst length (e.g. `1cm`, `8pt`) or `auto` to fall
/// through to the renderer's dynamic default (which leaves room for the
/// axis title, tick labels, and any legend). Pass the result to \@theme
/// under the `plot-margin` key.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.4.0
///
/// \@param top Top margin (Typst length or `auto`).
/// \@param right Right margin.
/// \@param bottom Bottom margin.
/// \@param left Left margin.
///
/// \@returns Margin dictionary consumed by \@theme.
///
/// \@examples Wide left margin to give a long axis title room to breathe.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(plot-margin: margin(left: 2cm, top: 0.5cm)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme, \@margin-part, \@margin-auto
#let margin(top: 0pt, right: 0pt, bottom: 0pt, left: 0pt) = (
  kind: "margin",
  top: top,
  right: right,
  bottom: bottom,
  left: left,
)

/// Partial margin specification: unspecified sides fall through to the
/// renderer's dynamic default.
///
/// Like \@margin but with `auto` defaults so every unset side keeps the
/// computed default while explicit sides override.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.4.0
///
/// \@param top Top margin (`auto` to keep the default).
/// \@param right Right margin.
/// \@param bottom Bottom margin.
/// \@param left Left margin.
///
/// \@returns Margin dictionary consumed by \@theme.
///
/// \@see \@margin, \@margin-auto
#let margin-part(
  top: auto,
  right: auto,
  bottom: auto,
  left: auto,
) = (
  kind: "margin",
  top: top,
  right: right,
  bottom: bottom,
  left: left,
)

/// Auto-sized margin: every side resolves to the renderer's dynamic default.
///
/// Equivalent to omitting `plot-margin` from a theme; available so users
/// can reset to defaults explicitly when overriding a theme.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.4.0
///
/// \@returns Margin dictionary consumed by \@theme.
///
/// \@see \@margin, \@margin-part
#let margin-auto() = (
  kind: "margin",
  top: auto,
  right: auto,
  bottom: auto,
  left: auto,
)
