///! Linetype scale.
///!
///! Maps discrete levels onto CeTZ dash keywords consumed by \@geom-line
///! (`"solid"`, `"dashed"`, `"dotted"`, `"dash-dotted"`, etc.).

#import "../utils/palette.typ": default-linetypes

/// Discrete linetype scale: maps levels to dash-pattern keywords.
///
/// Pass a custom array of keywords via `palette` to override the default
/// linetype set.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param palette Array of dash keywords, or `auto` for the library default.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default linetype palette mapping two groups to distinct dash
/// patterns.
/// ```
/// #let d = (
///   (x: 1, y: 2, grp: "a"),
///   (x: 2, y: 4, grp: "a"),
///   (x: 3, y: 3, grp: "a"),
///   (x: 1, y: 1, grp: "b"),
///   (x: 2, y: 2, grp: "b"),
///   (x: 3, y: 4, grp: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linetype: "grp"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (scale-linetype(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Override `palette` with a custom keyword cycle.
/// ```
/// #let d = (
///   (x: 1, y: 2, grp: "a"), (x: 2, y: 4, grp: "a"),
///   (x: 1, y: 1, grp: "b"), (x: 2, y: 2, grp: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linetype: "grp"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (scale-linetype(palette: ("dotted", "dash-dotted")),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-linetype-manual, \@geom-line
#let scale-linetype(name: none, palette: auto, limits: none, labels: auto) = (
  kind: "scale",
  aesthetic: "linetype",
  type: "discrete",
  name: name,
  palette: if palette == auto { default-linetypes } else { palette },
  limits: limits,
  labels: labels,
)

/// Manual discrete linetype scale: supply the dash-keyword array directly.
///
/// Keywords cycle through `values` in the order levels appear, unless
/// `limits` fixes the level order.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of dash keywords, one per level.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Two-keyword cycle assigned in input order.
/// ```
/// #let d = (
///   (x: 1, y: 2, grp: "a"),
///   (x: 2, y: 4, grp: "a"),
///   (x: 1, y: 1, grp: "b"),
///   (x: 2, y: 2, grp: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linetype: "grp"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (scale-linetype-manual(values: ("solid", "dashed")),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples `limits` fixes the level order so the same dash maps to the
/// same group regardless of input order.
/// ```
/// #let d = (
///   (x: 1, y: 1, grp: "b"), (x: 2, y: 2, grp: "b"),
///   (x: 1, y: 2, grp: "a"), (x: 2, y: 4, grp: "a"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linetype: "grp"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (scale-linetype-manual(
///     values: ("solid", "dashed"),
///     limits: ("a", "b"),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-linetype, \@geom-line
#let scale-linetype-manual(
  values: (),
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "linetype",
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  labels: labels,
)

/// Linetype scale that uses each row's value as the dash keyword directly.
///
/// The mapped column must contain dash keywords accepted by \@geom-line
/// (`"solid"`, `"dashed"`, `"dotted"`, `"dash-dotted"`,
/// `"densely-dashed"`, `"loosely-dashed"`).
///
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Identity scales draw no legend.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Per-row dash keyword carried straight through to the line.
/// ```
/// #let d = (
///   (x: 1, y: 2, dt: "solid"),  (x: 2, y: 3, dt: "solid"),
///   (x: 1, y: 1, dt: "dashed"), (x: 2, y: 2, dt: "dashed"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linetype: "dt"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (scale-linetype-identity(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-linetype, \@scale-linetype-manual, \@geom-line
#let scale-linetype-identity(name: none) = (
  kind: "scale",
  aesthetic: "linetype",
  type: "identity",
  name: name,
)

/// Binned linetype scale: cuts a continuous variable into `n-breaks` bins,
/// each bin gets one dash keyword from `palette`.
///
/// The scale stays continuous: the trained domain is numeric and the
/// resolver snaps each row to the bin its value falls into.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param n-breaks Number of bins to partition the continuous domain into.
/// \@param palette Array of dash keywords, one per bin, or `auto` for the library default.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Continuous `(lo, hi)` pair pinning the domain, or `none`.
/// \@param labels Array of legend labels aligned with bin midpoints, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Bin a continuous quality column into three linetype buckets.
/// ```
/// #let d = range(1, 13).map(i => (x: i, y: i, q: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linetype: "q", group: "q"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (scale-linetype-binned(n-breaks: 3),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-linetype, \@scale-linetype-manual, \@geom-line
#let scale-linetype-binned(
  n-breaks: 4,
  palette: auto,
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "linetype",
  type: "continuous",
  name: name,
  palette: if palette == auto { default-linetypes } else { palette },
  limits: limits,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
)

/// Continuous linetype scale: alias of \@scale-linetype-binned with the
/// default bin count. Provided for ggplot2 API parity.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param name Legend title.
/// \@param palette Array of dash keywords, or `auto`.
/// \@param limits Continuous `(lo, hi)` pair, or `none`.
/// \@param labels Array of legend labels, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@see \@scale-linetype-binned, \@scale-linetype, \@geom-line
#let scale-linetype-continuous(
  name: none,
  palette: auto,
  limits: none,
  labels: auto,
) = scale-linetype-binned(
  n-breaks: 4,
  palette: palette,
  name: name,
  limits: limits,
  labels: labels,
)

/// Discrete linetype scale: alias of \@scale-linetype.
///
/// Provided for ggplot2 API parity. Identical to calling `scale-linetype()`
/// directly.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param name Legend title.
/// \@param palette Array of dash keywords, or `auto`.
/// \@param limits Array of level names, or `none`.
/// \@param labels Array of legend labels, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@see \@scale-linetype, \@geom-line
#let scale-linetype-discrete(
  name: none,
  palette: auto,
  limits: none,
  labels: auto,
) = scale-linetype(
  name: name,
  palette: palette,
  limits: limits,
  labels: labels,
)
