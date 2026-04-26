///! Continuous position scales for x and y.
///!
///! Use these to override the default continuous axis: set `limits` to clip,
///! `breaks` and `labels` to control tick marks, or `trans` to apply
///! `"log10"`, `"sqrt"`, or `"reverse"` transformations.

/// Continuous x scale: axis title, limits, breaks, labels, and transformation.
///
/// `trans` accepts `"identity"`, `"log10"`, `"sqrt"`, and `"reverse"`.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param name Axis title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none` for automatic limits.
/// @param breaks Array of break values, or `auto` for automatic tick selection.
/// @param labels Array of tick labels aligned with `breaks`, or `auto`.
/// @param trans Transformation keyword: `"identity"`, `"log10"`, `"sqrt"`, or `"reverse"`.
/// @param expand Expansion added to each side of the domain, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(1, 11).map(i => (x: i, y: i * i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-x-continuous(name: "Index", limits: (0, 12)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-y-continuous, @scale-x-discrete, @coord-cartesian
#let scale-x-continuous(
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
  trans: "identity",
  expand: auto,
) = (
  kind: "scale",
  aesthetic: "x",
  type: "continuous",
  name: name,
  limits: limits,
  breaks: breaks,
  labels: labels,
  trans: trans,
  expand: expand,
)

/// Continuous y scale: axis title, limits, breaks, labels, and transformation.
///
/// `trans` accepts `"identity"`, `"log10"`, `"sqrt"`, and `"reverse"`.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param name Axis title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none` for automatic limits.
/// @param breaks Array of break values, or `auto` for automatic tick selection.
/// @param labels Array of tick labels aligned with `breaks`, or `auto`.
/// @param trans Transformation keyword: `"identity"`, `"log10"`, `"sqrt"`, or `"reverse"`.
/// @param expand Expansion added to each side of the domain, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(1, 11).map(i => (x: i, y: calc.pow(2, i)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-y-continuous(name: "Value", trans: "log10"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-x-continuous, @scale-y-discrete
#let scale-y-continuous(
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
  trans: "identity",
  expand: auto,
) = (
  kind: "scale",
  aesthetic: "y",
  type: "continuous",
  name: name,
  limits: limits,
  breaks: breaks,
  labels: labels,
  trans: trans,
  expand: expand,
)

/// Continuous x scale on a base-10 log axis.
///
/// Thin wrapper over @scale-x-continuous with `trans: "log10"`.
/// All x values must be strictly positive.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param name Axis title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none` for automatic limits.
/// @param breaks Array of break values, or `auto` for automatic tick selection.
/// @param labels Array of tick labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(1, 11).map(i => (x: calc.pow(10, i / 2), y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-x-log10(name: "x"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-x-continuous, @scale-y-log10
#let scale-x-log10(name: none, limits: none, breaks: auto, labels: auto) = (
  kind: "scale",
  aesthetic: "x",
  type: "continuous",
  name: name,
  limits: limits,
  breaks: breaks,
  labels: labels,
  trans: "log10",
  expand: auto,
)

/// Continuous y scale on a base-10 log axis.
///
/// Thin wrapper over @scale-y-continuous with `trans: "log10"`.
/// All y values must be strictly positive.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param name Axis title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none` for automatic limits.
/// @param breaks Array of break values, or `auto` for automatic tick selection.
/// @param labels Array of tick labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(1, 11).map(i => (x: i, y: calc.pow(2, i)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-y-log10(name: "y"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-y-continuous, @scale-x-log10
#let scale-y-log10(name: none, limits: none, breaks: auto, labels: auto) = (
  kind: "scale",
  aesthetic: "y",
  type: "continuous",
  name: name,
  limits: limits,
  breaks: breaks,
  labels: labels,
  trans: "log10",
  expand: auto,
)

/// Continuous x scale on a square-root axis.
///
/// Thin wrapper over @scale-x-continuous with `trans: "sqrt"`.
/// All x values must be non-negative.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param name Axis title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none` for automatic limits.
/// @param breaks Array of break values, or `auto` for automatic tick selection.
/// @param labels Array of tick labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(0, 11).map(i => (x: i * i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-x-sqrt(name: "x"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-x-continuous, @scale-y-sqrt
#let scale-x-sqrt(name: none, limits: none, breaks: auto, labels: auto) = (
  kind: "scale",
  aesthetic: "x",
  type: "continuous",
  name: name,
  limits: limits,
  breaks: breaks,
  labels: labels,
  trans: "sqrt",
  expand: auto,
)

/// Continuous y scale on a square-root axis.
///
/// Thin wrapper over @scale-y-continuous with `trans: "sqrt"`.
/// All y values must be non-negative.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param name Axis title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none` for automatic limits.
/// @param breaks Array of break values, or `auto` for automatic tick selection.
/// @param labels Array of tick labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(0, 11).map(i => (x: i, y: i * i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-y-sqrt(name: "y"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-y-continuous, @scale-x-sqrt
#let scale-y-sqrt(name: none, limits: none, breaks: auto, labels: auto) = (
  kind: "scale",
  aesthetic: "y",
  type: "continuous",
  name: name,
  limits: limits,
  breaks: breaks,
  labels: labels,
  trans: "sqrt",
  expand: auto,
)

/// Continuous x scale flipped left-to-right.
///
/// Thin wrapper over @scale-x-continuous with `trans: "reverse"`. Tick labels
/// stay in data units; only the axis direction reverses.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param name Axis title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none` for automatic limits.
/// @param breaks Array of break values, or `auto` for automatic tick selection.
/// @param labels Array of tick labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(1, 11).map(i => (x: i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-x-reverse(name: "x"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-x-continuous, @scale-y-reverse
#let scale-x-reverse(name: none, limits: none, breaks: auto, labels: auto) = (
  kind: "scale",
  aesthetic: "x",
  type: "continuous",
  name: name,
  limits: limits,
  breaks: breaks,
  labels: labels,
  trans: "reverse",
  expand: auto,
)

/// Continuous y scale flipped bottom-to-top.
///
/// Thin wrapper over @scale-y-continuous with `trans: "reverse"`. Tick labels
/// stay in data units; only the axis direction reverses.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param name Axis title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none` for automatic limits.
/// @param breaks Array of break values, or `auto` for automatic tick selection.
/// @param labels Array of tick labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(1, 11).map(i => (x: i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-y-reverse(name: "y"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-y-continuous, @scale-x-reverse
#let scale-y-reverse(name: none, limits: none, breaks: auto, labels: auto) = (
  kind: "scale",
  aesthetic: "y",
  type: "continuous",
  name: name,
  limits: limits,
  breaks: breaks,
  labels: labels,
  trans: "reverse",
  expand: auto,
)
