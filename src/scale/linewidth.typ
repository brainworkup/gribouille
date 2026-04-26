///! Linewidth scale.
///!
///! Maps a numeric column onto a pair of Typst lengths describing the output
///! range of stroke thicknesses for line-style geoms.

/// Continuous linewidth scale mapping a numeric column to stroke thickness.
///
/// @category Scales
/// @stability stable
/// @since 0.2.0
///
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param range Pair of Typst lengths `(min, max)` bounding the output thickness.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param breaks Array of break values for the legend, or `auto`.
/// @param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i, w: i + 1, g: str(i)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linewidth: "w", group: "g"),
///   layers: (geom-line(),),
///   scales: (scale-linewidth-continuous(range: (0.4pt, 2pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-linewidth-identity, @scale-size-continuous
#let scale-linewidth-continuous(
  name: none,
  range: (0.4pt, 1.4pt),
  limits: none,
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "linewidth",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Linewidth scale that uses each row's value as the stroke thickness.
///
/// Values must be Typst lengths. No legend is drawn because the column
/// carries the visual outcome verbatim.
///
/// @category Scales
/// @stability stable
/// @since 0.2.0
///
/// @param name Legend title. Identity scales draw no legend.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-linewidth-continuous
#let scale-linewidth-identity(name: none) = (
  kind: "scale",
  aesthetic: "linewidth",
  type: "identity",
  name: name,
)
