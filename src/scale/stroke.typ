///! Stroke scale.
///!
///! Maps a numeric column onto a pair of Typst lengths describing the output
///! range of marker outline thicknesses for `geom-point`.

/// Continuous stroke scale mapping a numeric column to outline thickness.
///
/// \@category Scales
/// \@subcategory Stroke scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param range Pair of Typst lengths `(min, max)` bounding the output thickness.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param breaks Array of break values for the legend, or `auto`.
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Marker outline grows with `w`.
/// ```
/// #let d = range(1, 8).map(i => (x: i, y: i, w: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", stroke: "w"),
///   layers: (geom-point(size: 5pt, fill: rgb("#1f77b4")),),
///   scales: (scale-stroke-continuous(range: (0.2pt, 1.6pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-stroke-identity, \@scale-linewidth-continuous
#let scale-stroke-continuous(
  name: none,
  range: (0.2pt, 1.4pt),
  limits: none,
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "stroke",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Manual discrete stroke scale: supply a per-level array of Typst lengths.
///
/// \@category Scales
/// \@subcategory Stroke scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param values Array of Typst lengths, one per level.
/// \@param name Legend title.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@see \@scale-stroke-continuous, \@scale-linewidth-manual
#let scale-stroke-manual(
  values: (),
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "stroke",
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  labels: labels,
)

/// Binned continuous stroke scale.
///
/// Maps a numeric column onto an outline-thickness range, but groups values
/// into `n-breaks` bins for the legend.
///
/// \@category Scales
/// \@subcategory Stroke scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param n-breaks Number of legend bins.
/// \@param range Pair of Typst lengths `(min, max)` bounding the output thickness.
/// \@param name Legend title.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@see \@scale-stroke-continuous, \@scale-linewidth-binned
#let scale-stroke-binned(
  n-breaks: 4,
  range: (0.2pt, 1.4pt),
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "stroke",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  breaks: auto,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
)

/// Stroke scale that uses each row's value as the outline thickness.
///
/// Values must be Typst lengths. No legend is drawn because the column
/// carries the visual outcome verbatim.
///
/// \@category Scales
/// \@subcategory Stroke scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param name Legend title. Identity scales draw no legend.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@see \@scale-stroke-continuous
#let scale-stroke-identity(name: none) = (
  kind: "scale",
  aesthetic: "stroke",
  type: "identity",
  name: name,
)
