///! Continuous size scale.
///!
///! Maps a numeric column onto a pair of Typst lengths describing the output
///! range of marker or line sizes.

/// Continuous size scale mapping a numeric column to a size range.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param range Pair of Typst lengths `(min, max)` bounding the output size.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param breaks Array of break values for the legend, or `auto`.
/// @param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i, w: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", size: "w"),
///   layers: (geom-point(),),
///   scales: (scale-size-continuous(range: (1pt, 6pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-shape, @scale-colour-continuous
#let scale-size-continuous(
  name: none,
  range: (1pt, 6pt),
  limits: none,
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "size",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Binned continuous size scale mapping a numeric column to `n-breaks` sizes.
///
/// Quantises the trained domain into equal-width bins so that all rows in a
/// bin take the same visual size, drawn from the midpoint position of the
/// `range` interval.
///
/// @category Scales
/// @stability stable
/// @since 0.3.0
///
/// @param n-breaks Number of bins to partition the domain into.
/// @param range Pair of Typst lengths `(min, max)` bounding the output size.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param labels Array of legend labels aligned with the bins, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, w: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", size: "w"),
///   layers: (geom-point(),),
///   scales: (scale-size-binned(n-breaks: 4, range: (1pt, 6pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-size-continuous, @scale-size-binned-area
#let scale-size-binned(
  n-breaks: 4,
  range: (1pt, 6pt),
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "size",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  breaks: auto,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
)

/// Area-proportional continuous size scale.
///
/// Maps each value through the square root of its normalised position so the
/// drawn marker area, rather than its diameter, scales linearly with the
/// data. This is the perceptually neutral default when the visual quantity
/// of interest is a count or magnitude.
///
/// @category Scales
/// @stability stable
/// @since 0.3.0
///
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param range Pair of Typst lengths `(min, max)` bounding the output size.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param breaks Array of break values for the legend, or `auto`.
/// @param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(1, 8).map(i => (x: i, y: i, w: i * i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", size: "w"),
///   layers: (geom-point(),),
///   scales: (scale-size-area(range: (1pt, 12pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-size-continuous, @scale-size-binned-area
#let scale-size-area(
  name: none,
  range: (1pt, 6pt),
  limits: none,
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "size",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  breaks: breaks,
  labels: labels,
  size-trans: "area",
)

/// Binned area-proportional size scale.
///
/// Combines binning with area scaling: the domain is partitioned into
/// `n-breaks` bins, and the size of each bin grows with the square root of
/// its normalised midpoint position.
///
/// @category Scales
/// @stability stable
/// @since 0.3.0
///
/// @param n-breaks Number of bins to partition the domain into.
/// @param range Pair of Typst lengths `(min, max)` bounding the output size.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param labels Array of legend labels aligned with the bins, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(1, 8).map(i => (x: i, y: i, w: i * i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", size: "w"),
///   layers: (geom-point(),),
///   scales: (scale-size-binned-area(n-breaks: 4, range: (1pt, 12pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-size-binned, @scale-size-area
#let scale-size-binned-area(
  n-breaks: 4,
  range: (1pt, 6pt),
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "size",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  breaks: auto,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
  size-trans: "area",
)
