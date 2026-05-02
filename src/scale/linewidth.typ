///! Linewidth scale.
///!
///! Maps a numeric column onto a pair of Typst lengths describing the output
///! range of stroke thicknesses for line-style geoms.

/// Continuous linewidth scale mapping a numeric column to stroke thickness.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.2.0
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param range Pair of Typst lengths `(min, max)` bounding the output thickness.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param breaks Array of break values for the legend, or `auto`.
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Linewidth grows with `w`, with one segment per row driven by
/// the `group` mapping.
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
/// \@examples Pair `colour` and `linewidth` with the same column to encode
/// magnitude through both channels.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i, w: i + 1, g: str(i)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "w", linewidth: "w", group: "g"),
///   layers: (geom-line(),),
///   scales: (scale-linewidth-continuous(range: (0.4pt, 3pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-linewidth-identity, \@scale-size-continuous
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

/// Manual discrete linewidth scale: supply a per-level array of Typst lengths.
///
/// Use when each level should map to a chosen thickness rather than the
/// evenly-spaced range that the discrete inference would assign.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param values Array of Typst lengths, one per level (in `limits` order when set, otherwise in first-seen order).
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Three groups assigned thin/medium/thick strokes.
/// ```
/// #let d = (
///   (x: 1, y: 1, g: "a"), (x: 2, y: 2, g: "a"),
///   (x: 1, y: 2, g: "b"), (x: 2, y: 3, g: "b"),
///   (x: 1, y: 3, g: "c"), (x: 2, y: 4, g: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linewidth: "g", group: "g"),
///   layers: (geom-line(),),
///   scales: (scale-linewidth-manual(values: (0.4pt, 1pt, 2pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-linewidth-continuous, \@scale-linewidth-identity
#let scale-linewidth-manual(
  values: (),
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "linewidth",
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  labels: labels,
)

/// Binned continuous linewidth scale.
///
/// Maps a numeric column onto a stroke-thickness range, but groups values
/// into `n-breaks` bins for the legend. The mapping stays continuous so
/// drawn strokes vary smoothly within each bin; only the legend swatches
/// snap to bin centres.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param n-breaks Number of legend bins.
/// \@param range Pair of Typst lengths `(min, max)` bounding the output thickness.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Linewidth grows with `w`, with the legend grouped into four bins.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i, w: i + 1, g: str(i)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linewidth: "w", group: "g"),
///   layers: (geom-line(),),
///   scales: (scale-linewidth-binned(n-breaks: 4, range: (0.4pt, 2pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-linewidth-continuous, \@scale-size-binned
#let scale-linewidth-binned(
  n-breaks: 4,
  range: (0.4pt, 1.4pt),
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "linewidth",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  breaks: auto,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
)

/// Linewidth scale that uses each row's value as the stroke thickness.
///
/// Values must be Typst lengths. No legend is drawn because the column
/// carries the visual outcome verbatim.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.2.0
///
/// \@param name Legend title. Identity scales draw no legend.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Per-row Typst lengths carried straight through to the line
/// strokes; no legend is drawn.
/// ```
/// #let d = (
///   (x: 1, y: 2, g: "a", lw: 0.4pt),
///   (x: 2, y: 3, g: "a", lw: 0.4pt),
///   (x: 1, y: 1, g: "b", lw: 1.2pt),
///   (x: 2, y: 2, g: "b", lw: 1.2pt),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", group: "g", linewidth: "lw"),
///   layers: (geom-line(),),
///   scales: (scale-linewidth-identity(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-linewidth-continuous
#let scale-linewidth-identity(name: none) = (
  kind: "scale",
  aesthetic: "linewidth",
  type: "identity",
  name: name,
)
