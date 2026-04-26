///! Colour and fill scales.
///!
///! `palette` accepts a Typst gradient, an array of colours, or `auto` for
///! the library default. Manual and viridis helpers are colocated in this
///! file for easy discovery.

#import "../utils/viridis.typ" as viridis-mod
#import "../utils/palette.typ": brewer-palette
#import "../utils/colour.typ": grey-palette, hue-palette

/// Continuous colour scale mapping a numeric column to stroke colours.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param palette Colour source: a gradient, an array of colours, or `auto`.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param breaks Array of break values for the legend, or `auto`.
/// @param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-continuous(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-colour-viridis-c, @scale-colour-discrete, @scale-fill-continuous
#let scale-colour-continuous(
  name: none,
  palette: auto,
  limits: none,
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "colour",
  type: "continuous",
  name: name,
  palette: palette,
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Discrete colour scale mapping categorical levels to stroke colours.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param palette Colour source: an array of colours, or `auto`.
/// @param limits Array of level names controlling order and inclusion, or `none`.
/// @param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-discrete(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-colour-manual, @scale-colour-viridis-d, @scale-fill-discrete
#let scale-colour-discrete(
  name: none,
  palette: auto,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "colour",
  type: "discrete",
  name: name,
  palette: palette,
  limits: limits,
  labels: labels,
)

/// Continuous fill scale mapping a numeric column to fill colours.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param palette Colour source: a gradient, an array of colours, or `auto`.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param breaks Array of break values for the legend, or `auto`.
/// @param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = (
///   (grp: "a", y: 1),
///   (grp: "b", y: 2),
///   (grp: "c", y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y", fill: "y"),
///   layers: (geom-col(),),
///   scales: (scale-fill-continuous(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-fill-viridis-c, @scale-fill-discrete, @scale-colour-continuous
#let scale-fill-continuous(
  name: none,
  palette: auto,
  limits: none,
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "fill",
  type: "continuous",
  name: name,
  palette: palette,
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Discrete fill scale mapping categorical levels to fill colours.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param palette Colour source: an array of colours, or `auto`.
/// @param limits Array of level names controlling order and inclusion, or `none`.
/// @param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = (
///   (grp: "a", y: 1),
///   (grp: "b", y: 2),
///   (grp: "c", y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y", fill: "grp"),
///   layers: (geom-col(),),
///   scales: (scale-fill-discrete(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-fill-manual, @scale-fill-viridis-d, @scale-colour-discrete
#let scale-fill-discrete(
  name: none,
  palette: auto,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "fill",
  type: "discrete",
  name: name,
  palette: palette,
  limits: limits,
  labels: labels,
)

/// Manual discrete colour scale: supply the colour array directly.
///
/// Colours cycle through `values` in the order levels appear, unless
/// `limits` fixes the level order.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param values Array of colours, one per level.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Array of level names controlling order and inclusion, or `none`.
/// @param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-manual(values: (
///     rgb("#1b9e77"), rgb("#d95f02"), rgb("#7570b3"),
///   )),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-colour-discrete, @scale-fill-manual
#let scale-colour-manual(values: (), name: none, limits: none, labels: auto) = (
  kind: "scale",
  aesthetic: "colour",
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  labels: labels,
)

/// Manual discrete fill scale: supply the colour array directly.
///
/// Colours cycle through `values` in the order levels appear, unless
/// `limits` fixes the level order.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param values Array of colours, one per level.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Array of level names controlling order and inclusion, or `none`.
/// @param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = (
///   (grp: "a", y: 1),
///   (grp: "b", y: 2),
///   (grp: "c", y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y", fill: "grp"),
///   layers: (geom-col(),),
///   scales: (scale-fill-manual(values: (
///     rgb("#66c2a5"), rgb("#fc8d62"), rgb("#8da0cb"),
///   )),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-fill-discrete, @scale-colour-manual
#let scale-fill-manual(values: (), name: none, limits: none, labels: auto) = (
  kind: "scale",
  aesthetic: "fill",
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  labels: labels,
)

/// Discrete viridis colour scale.
///
/// `option` selects between `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`,
/// and `"cividis"`.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Array of level names controlling order and inclusion, or `none`.
/// @param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
///   (x: 4, y: 5, sp: "d"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-viridis-d(option: "plasma"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-colour-viridis-c, @scale-colour-viridis-b, @scale-fill-viridis-d
#let scale-colour-viridis-d(
  option: "viridis",
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "colour",
  type: "discrete",
  name: name,
  palette: viridis-mod.palette(option),
  limits: limits,
  labels: labels,
)

/// Continuous viridis colour scale.
///
/// `option` selects between `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`,
/// and `"cividis"`.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param breaks Array of break values for the legend, or `auto`.
/// @param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-viridis-c(option: "magma"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-colour-viridis-d, @scale-colour-viridis-b, @scale-fill-viridis-c
#let scale-colour-viridis-c(
  option: "viridis",
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "colour",
  type: "continuous",
  name: name,
  palette: viridis-mod.palette(option),
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Binned viridis colour scale.
///
/// Partitions the continuous domain into `n-breaks` equal segments, each
/// coloured from the chosen viridis palette.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// @param n-breaks Number of bins to partition the domain into.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param labels Array of legend labels aligned with the bins, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-viridis-b(n-breaks: 4),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-colour-viridis-c, @scale-colour-viridis-d, @scale-fill-viridis-b
#let scale-colour-viridis-b(
  option: "viridis",
  n-breaks: 5,
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "colour",
  type: "continuous",
  name: name,
  palette: viridis-mod.palette(option),
  limits: limits,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
)

/// Discrete viridis fill scale.
///
/// `option` selects between `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`,
/// and `"cividis"`.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Array of level names controlling order and inclusion, or `none`.
/// @param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = (
///   (grp: "a", y: 1),
///   (grp: "b", y: 2),
///   (grp: "c", y: 3),
///   (grp: "d", y: 4),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y", fill: "grp"),
///   layers: (geom-col(),),
///   scales: (scale-fill-viridis-d(option: "cividis"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-fill-viridis-c, @scale-fill-viridis-b, @scale-colour-viridis-d
#let scale-fill-viridis-d(
  option: "viridis",
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "fill",
  type: "discrete",
  name: name,
  palette: viridis-mod.palette(option),
  limits: limits,
  labels: labels,
)

/// Continuous viridis fill scale.
///
/// `option` selects between `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`,
/// and `"cividis"`.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param breaks Array of break values for the legend, or `auto`.
/// @param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(0, 12).map(i => (grp: str(i), y: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y", fill: "y"),
///   layers: (geom-col(),),
///   scales: (scale-fill-viridis-c(option: "viridis"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-fill-viridis-d, @scale-fill-viridis-b, @scale-colour-viridis-c
#let scale-fill-viridis-c(
  option: "viridis",
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "fill",
  type: "continuous",
  name: name,
  palette: viridis-mod.palette(option),
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Colour scale that uses each row's value as the stroke colour directly.
///
/// The mapped column must hold values acceptable to Typst's `rgb()`
/// (e.g. `"#ff0000"`) or already be `color` values. No legend is drawn
/// because the column carries the visual outcome verbatim.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param name Legend title. Identity scales draw no legend, but the title is
///   carried for downstream consumers that may surface it.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = (
///   (x: 1, y: 2, c: "#1b9e77"),
///   (x: 2, y: 4, c: "#d95f02"),
///   (x: 3, y: 3, c: "#7570b3"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "c"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-identity(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-colour-manual, @scale-fill-identity
#let scale-colour-identity(name: none) = (
  kind: "scale",
  aesthetic: "colour",
  type: "identity",
  name: name,
)

/// Fill scale that uses each row's value as the fill colour directly.
///
/// Values must be hex strings or `color` values; see @scale-colour-identity.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param name Legend title. Identity scales draw no legend.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-fill-manual, @scale-colour-identity
#let scale-fill-identity(name: none) = (
  kind: "scale",
  aesthetic: "fill",
  type: "identity",
  name: name,
)

/// Binned viridis fill scale.
///
/// Partitions the continuous domain into `n-breaks` equal segments, each
/// coloured from the chosen viridis palette.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// @param n-breaks Number of bins to partition the domain into.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param labels Array of legend labels aligned with the bins, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(0, 12).map(i => (grp: str(i), y: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y", fill: "y"),
///   layers: (geom-col(),),
///   scales: (scale-fill-viridis-b(n-breaks: 4),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-fill-viridis-c, @scale-fill-viridis-d, @scale-colour-viridis-b
#let scale-fill-viridis-b(
  option: "viridis",
  n-breaks: 5,
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "fill",
  type: "continuous",
  name: name,
  palette: viridis-mod.palette(option),
  limits: limits,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
)

/// Discrete ColorBrewer colour scale.
///
/// `palette` selects a named ColorBrewer palette such as `"Set1"`,
/// `"Dark2"`, or `"Spectral"`. Categorical levels are mapped to colours
/// in the order they first appear in the data.
///
/// @category Scales
/// @stability stable
/// @since 0.1.0
///
/// @param palette ColorBrewer palette name (qualitative, sequential, or diverging).
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Array of level names controlling order and inclusion, or `none`.
/// @param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-brewer(palette: "Set1"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-fill-brewer, @scale-colour-discrete
#let scale-colour-brewer(
  palette: "Set1",
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "colour",
  type: "discrete",
  name: name,
  palette: brewer-palette(palette),
  limits: limits,
  labels: labels,
)

/// Discrete ColorBrewer fill scale.
///
/// Fill counterpart of @scale-colour-brewer. Same palette names apply.
///
/// @category Scales
/// @stability stable
/// @since 0.1.0
///
/// @param palette ColorBrewer palette name (qualitative, sequential, or diverging).
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Array of level names controlling order and inclusion, or `none`.
/// @param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-colour-brewer, @scale-fill-discrete
#let scale-fill-brewer(
  palette: "Set1",
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "fill",
  type: "discrete",
  name: name,
  palette: brewer-palette(palette),
  limits: limits,
  labels: labels,
)

/// Continuous two-stop colour gradient.
///
/// Linearly interpolates between `low` and `high` across the trained domain.
/// Defaults to a blue ramp.
///
/// @category Scales
/// @stability stable
/// @since 0.1.0
///
/// @param low Colour for the low end of the domain.
/// @param high Colour for the high end of the domain.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param breaks Array of break values for the legend, or `auto`.
/// @param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-gradient(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-colour-gradient2, @scale-colour-gradientn, @scale-fill-gradient
#let scale-colour-gradient(
  low: rgb("#132B43"),
  high: rgb("#56B1F7"),
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "colour",
  type: "continuous",
  name: name,
  palette: (low, high),
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Continuous diverging colour gradient through a midpoint.
///
/// Interpolates `low` to `mid` for values at or below `midpoint`, and
/// `mid` to `high` for values at or above it.
///
/// @category Scales
/// @stability stable
/// @since 0.1.0
///
/// @param low Colour for values far below `midpoint`.
/// @param mid Colour at `midpoint`.
/// @param high Colour for values far above `midpoint`.
/// @param midpoint Value at which the palette transitions through `mid`.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param breaks Array of break values for the legend, or `auto`.
/// @param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(-5, 6).map(i => (x: i, y: i, z: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-gradient2(midpoint: 0),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-colour-gradient, @scale-colour-gradientn, @scale-fill-gradient2
#let scale-colour-gradient2(
  low: rgb("#1F77B4"),
  mid: rgb("#FFFFFF"),
  high: rgb("#D62728"),
  midpoint: 0,
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "colour",
  type: "continuous",
  name: name,
  palette: (low, mid, high),
  midpoint: midpoint,
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Continuous n-stop colour gradient.
///
/// Walks `colours` as a sequence of stops and linearly interpolates between
/// adjacent stops. Useful for ramps that require more than two anchor
/// colours (for example a ColorBrewer palette used as a continuous ramp).
///
/// @category Scales
/// @stability stable
/// @since 0.1.0
///
/// @param colours Array of two or more colours.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param breaks Array of break values for the legend, or `auto`.
/// @param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-gradientn(colours: (
///     rgb("#1a9850"), rgb("#ffffbf"), rgb("#d73027"),
///   )),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-colour-gradient, @scale-colour-gradient2, @scale-fill-gradientn
#let scale-colour-gradientn(
  colours: (),
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "colour",
  type: "continuous",
  name: name,
  palette: colours,
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Continuous two-stop fill gradient.
///
/// Fill counterpart of @scale-colour-gradient.
///
/// @category Scales
/// @stability stable
/// @since 0.1.0
///
/// @param low Colour for the low end of the domain.
/// @param high Colour for the high end of the domain.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param breaks Array of break values for the legend, or `auto`.
/// @param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-colour-gradient, @scale-fill-gradient2, @scale-fill-gradientn
#let scale-fill-gradient(
  low: rgb("#132B43"),
  high: rgb("#56B1F7"),
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "fill",
  type: "continuous",
  name: name,
  palette: (low, high),
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Continuous diverging fill gradient through a midpoint.
///
/// Fill counterpart of @scale-colour-gradient2.
///
/// @category Scales
/// @stability stable
/// @since 0.1.0
///
/// @param low Colour for values far below `midpoint`.
/// @param mid Colour at `midpoint`.
/// @param high Colour for values far above `midpoint`.
/// @param midpoint Value at which the palette transitions through `mid`.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param breaks Array of break values for the legend, or `auto`.
/// @param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-colour-gradient2, @scale-fill-gradient, @scale-fill-gradientn
#let scale-fill-gradient2(
  low: rgb("#1F77B4"),
  mid: rgb("#FFFFFF"),
  high: rgb("#D62728"),
  midpoint: 0,
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "fill",
  type: "continuous",
  name: name,
  palette: (low, mid, high),
  midpoint: midpoint,
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Continuous n-stop fill gradient.
///
/// Fill counterpart of @scale-colour-gradientn.
///
/// @category Scales
/// @stability stable
/// @since 0.1.0
///
/// @param colours Array of two or more colours.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param breaks Array of break values for the legend, or `auto`.
/// @param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-colour-gradientn, @scale-fill-gradient, @scale-fill-gradient2
#let scale-fill-gradientn(
  colours: (),
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "fill",
  type: "continuous",
  name: name,
  palette: colours,
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Discrete grey colour scale.
///
/// Generates `n` evenly-spaced `luma` colours from `start` (darker) to `end`
/// (lighter), each in `[0, 1]` where 0 is black and 1 is white.
///
/// @category Scales
/// @stability stable
/// @since 0.2.0
///
/// @param start Luminance for the first level, in `[0, 1]`.
/// @param end Luminance for the last level, in `[0, 1]`.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Array of level names controlling order and inclusion, or `none`.
/// @param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-grey(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-fill-grey, @scale-colour-discrete
#let scale-colour-grey(
  start: 0.2,
  end: 0.8,
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "colour",
  type: "discrete",
  name: name,
  palette: grey-palette(10, start: start, end: end),
  limits: limits,
  labels: labels,
)

/// Discrete grey fill scale.
///
/// Fill counterpart of @scale-colour-grey.
///
/// @category Scales
/// @stability stable
/// @since 0.2.0
///
/// @param start Luminance for the first level, in `[0, 1]`.
/// @param end Luminance for the last level, in `[0, 1]`.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Array of level names controlling order and inclusion, or `none`.
/// @param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-colour-grey, @scale-fill-discrete
#let scale-fill-grey(
  start: 0.2,
  end: 0.8,
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "fill",
  type: "discrete",
  name: name,
  palette: grey-palette(10, start: start, end: end),
  limits: limits,
  labels: labels,
)

/// Discrete equally-spaced hue colour scale.
///
/// Steps `n` hues across the angular range `h` in OKLCh space, picking
/// chroma and luminance from `c` and `l`. Defaults to
/// `h = (15deg, 375deg)`, `c = 100`, `l = 65`.
///
/// OKLCh is used as a perceptually uniform near-equivalent of HCL, which
/// Typst does not expose directly. The first colour sits at `h.at(0)` and
/// successive colours step by `(end - start) / n`, so the endpoint is
/// excluded and the wheel never duplicates a hue when `start` and `end`
/// differ by a full turn.
///
/// @category Scales
/// @stability stable
/// @since 0.2.0
///
/// @param h Pair `(start, end)` of hue angles.
/// @param c Chroma in `[0, 100]`.
/// @param l Luminance in `[0, 100]`.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Array of level names controlling order and inclusion, or `none`.
/// @param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
///   (x: 4, y: 5, sp: "d"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-hue(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-fill-hue, @scale-colour-discrete
#let scale-colour-hue(
  h: (15deg, 375deg),
  c: 100,
  l: 65,
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "colour",
  type: "discrete",
  name: name,
  palette: hue-palette(12, h: h, c: c, l: l),
  limits: limits,
  labels: labels,
)

/// Discrete equally-spaced hue fill scale.
///
/// Fill counterpart of @scale-colour-hue.
///
/// @category Scales
/// @stability stable
/// @since 0.2.0
///
/// @param h Pair `(start, end)` of hue angles.
/// @param c Chroma in `[0, 100]`.
/// @param l Luminance in `[0, 100]`.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Array of level names controlling order and inclusion, or `none`.
/// @param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-colour-hue, @scale-fill-discrete
#let scale-fill-hue(
  h: (15deg, 375deg),
  c: 100,
  l: 65,
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "fill",
  type: "discrete",
  name: name,
  palette: hue-palette(12, h: h, c: c, l: l),
  limits: limits,
  labels: labels,
)

/// Continuous ColorBrewer colour scale.
///
/// Looks up a Brewer palette by name and interpolates linearly across its
/// stops as a continuous ramp. `direction` flips the palette: `1` keeps the
/// canonical order, `-1` reverses it.
///
/// @category Scales
/// @stability stable
/// @since 0.2.0
///
/// @param palette ColorBrewer palette name (sequential or diverging works best).
/// @param direction `1` for canonical order, `-1` for reversed.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param breaks Array of break values for the legend, or `auto`.
/// @param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-distiller(palette: "Spectral"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-fill-distiller, @scale-colour-gradientn, @scale-colour-brewer
#let scale-colour-distiller(
  palette: "Spectral",
  direction: 1,
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
) = {
  let stops = brewer-palette(palette)
  if direction < 0 { stops = stops.rev() }
  (
    kind: "scale",
    aesthetic: "colour",
    type: "continuous",
    name: name,
    palette: stops,
    limits: limits,
    breaks: breaks,
    labels: labels,
  )
}

/// Continuous alpha (opacity) scale mapping a numeric column to opacities.
///
/// @category Scales
/// @stability stable
/// @since 0.2.0
///
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param range Pair `(lo, hi)` bounding the output opacity, each in `[0, 1]`.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param breaks Array of break values for the legend, or `auto`.
/// @param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, w: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", alpha: "w"),
///   layers: (geom-point(size: 4pt),),
///   scales: (scale-alpha-continuous(range: (0.1, 1)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-alpha-identity, @scale-colour-continuous
#let scale-alpha-continuous(
  name: none,
  range: (0.1, 1),
  limits: none,
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "alpha",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Alpha scale that uses each row's value as the opacity directly.
///
/// Values are clamped to `[0, 1]` before being applied to the colour.
/// No legend is drawn because the column carries the visual outcome verbatim.
///
/// @category Scales
/// @stability stable
/// @since 0.2.0
///
/// @param name Legend title. Identity scales draw no legend.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-alpha-continuous, @scale-colour-identity
#let scale-alpha-identity(name: none) = (
  kind: "scale",
  aesthetic: "alpha",
  type: "identity",
  name: name,
)

/// Continuous ColorBrewer fill scale.
///
/// Fill counterpart of @scale-colour-distiller.
///
/// @category Scales
/// @stability stable
/// @since 0.2.0
///
/// @param palette ColorBrewer palette name (sequential or diverging works best).
/// @param direction `1` for canonical order, `-1` for reversed.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param breaks Array of break values for the legend, or `auto`.
/// @param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-colour-distiller, @scale-fill-gradientn, @scale-fill-brewer
#let scale-fill-distiller(
  palette: "Spectral",
  direction: 1,
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
) = {
  let stops = brewer-palette(palette)
  if direction < 0 { stops = stops.rev() }
  (
    kind: "scale",
    aesthetic: "fill",
    type: "continuous",
    name: name,
    palette: stops,
    limits: limits,
    breaks: breaks,
    labels: labels,
  )
}

/// Binned two-stop colour gradient.
///
/// Quantises the trained continuous domain into `n-breaks` equal-width bins
/// and fills each bin with a single colour drawn from the `low` to `high`
/// ramp. Defaults to a blue ramp.
///
/// @category Scales
/// @stability stable
/// @since 0.3.0
///
/// @param low Colour for the low end of the domain.
/// @param high Colour for the high end of the domain.
/// @param n-breaks Number of bins to partition the domain into.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param labels Array of legend labels aligned with the bins, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 1.0))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-steps(n-breaks: 5),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-colour-steps2, @scale-colour-stepsn, @scale-fill-steps
#let scale-colour-steps(
  low: rgb("#132B43"),
  high: rgb("#56B1F7"),
  n-breaks: 5,
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "colour",
  type: "continuous",
  name: name,
  palette: (low, high),
  limits: limits,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
)

/// Binned diverging colour gradient through a midpoint.
///
/// Quantises the trained continuous domain into `n-breaks` equal-width bins
/// using a three-stop palette that pivots through `mid` at `midpoint`.
///
/// @category Scales
/// @stability stable
/// @since 0.3.0
///
/// @param low Colour for values far below `midpoint`.
/// @param mid Colour at `midpoint`.
/// @param high Colour for values far above `midpoint`.
/// @param midpoint Value at which the palette transitions through `mid`.
/// @param n-breaks Number of bins to partition the domain into.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param labels Array of legend labels aligned with the bins, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(-5, 6).map(i => (x: i, y: i, z: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-steps2(midpoint: 0, n-breaks: 6),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-colour-steps, @scale-colour-stepsn, @scale-fill-steps2
#let scale-colour-steps2(
  low: rgb("#005A32"),
  mid: white,
  high: rgb("#A50026"),
  midpoint: 0,
  n-breaks: 5,
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "colour",
  type: "continuous",
  name: name,
  palette: (low, mid, high),
  midpoint: midpoint,
  limits: limits,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
)

/// Binned n-stop colour gradient.
///
/// Walks `colours` as a sequence of stops and quantises the lookup into
/// `n-breaks` equal-width bins.
///
/// @category Scales
/// @stability stable
/// @since 0.3.0
///
/// @param colours Array of two or more colours.
/// @param n-breaks Number of bins to partition the domain into.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param labels Array of legend labels aligned with the bins, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-stepsn(colours: (
///     rgb("#1a9850"), rgb("#ffffbf"), rgb("#d73027"),
///   ), n-breaks: 6),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-colour-steps, @scale-colour-steps2, @scale-fill-stepsn
#let scale-colour-stepsn(
  colours: (),
  n-breaks: 5,
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "colour",
  type: "continuous",
  name: name,
  palette: colours,
  limits: limits,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
)

/// Binned ColorBrewer colour scale.
///
/// Looks up a Brewer palette by name, interpolates across its stops, and
/// quantises the lookup into `n-breaks` equal-width bins. `direction` flips
/// the palette: `1` keeps the canonical order, `-1` reverses it.
///
/// @category Scales
/// @stability stable
/// @since 0.3.0
///
/// @param palette ColorBrewer palette name (sequential or diverging works best).
/// @param n-breaks Number of bins to partition the domain into.
/// @param direction `1` for canonical order, `-1` for reversed.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param labels Array of legend labels aligned with the bins, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-fermenter(palette: "Spectral", n-breaks: 5),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @scale-colour-distiller, @scale-fill-fermenter
#let scale-colour-fermenter(
  palette: "Spectral",
  n-breaks: 5,
  direction: 1,
  name: none,
  limits: none,
  labels: auto,
) = {
  let stops = brewer-palette(palette)
  if direction < 0 { stops = stops.rev() }
  (
    kind: "scale",
    aesthetic: "colour",
    type: "continuous",
    name: name,
    palette: stops,
    limits: limits,
    labels: labels,
    binned: true,
    n-breaks: n-breaks,
  )
}

/// Binned two-stop fill gradient.
///
/// Fill counterpart of @scale-colour-steps.
///
/// @category Scales
/// @stability stable
/// @since 0.3.0
///
/// @param low Colour for the low end of the domain.
/// @param high Colour for the high end of the domain.
/// @param n-breaks Number of bins to partition the domain into.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param labels Array of legend labels aligned with the bins, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-colour-steps, @scale-fill-steps2, @scale-fill-stepsn
#let scale-fill-steps(
  low: rgb("#132B43"),
  high: rgb("#56B1F7"),
  n-breaks: 5,
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "fill",
  type: "continuous",
  name: name,
  palette: (low, high),
  limits: limits,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
)

/// Binned diverging fill gradient through a midpoint.
///
/// Fill counterpart of @scale-colour-steps2.
///
/// @category Scales
/// @stability stable
/// @since 0.3.0
///
/// @param low Colour for values far below `midpoint`.
/// @param mid Colour at `midpoint`.
/// @param high Colour for values far above `midpoint`.
/// @param midpoint Value at which the palette transitions through `mid`.
/// @param n-breaks Number of bins to partition the domain into.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param labels Array of legend labels aligned with the bins, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-colour-steps2, @scale-fill-steps, @scale-fill-stepsn
#let scale-fill-steps2(
  low: rgb("#005A32"),
  mid: white,
  high: rgb("#A50026"),
  midpoint: 0,
  n-breaks: 5,
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "fill",
  type: "continuous",
  name: name,
  palette: (low, mid, high),
  midpoint: midpoint,
  limits: limits,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
)

/// Binned n-stop fill gradient.
///
/// Fill counterpart of @scale-colour-stepsn.
///
/// @category Scales
/// @stability stable
/// @since 0.3.0
///
/// @param colours Array of two or more colours.
/// @param n-breaks Number of bins to partition the domain into.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param labels Array of legend labels aligned with the bins, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-colour-stepsn, @scale-fill-steps, @scale-fill-steps2
#let scale-fill-stepsn(
  colours: (),
  n-breaks: 5,
  name: none,
  limits: none,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "fill",
  type: "continuous",
  name: name,
  palette: colours,
  limits: limits,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
)

/// Binned ColorBrewer fill scale.
///
/// Fill counterpart of @scale-colour-fermenter.
///
/// @category Scales
/// @stability stable
/// @since 0.3.0
///
/// @param palette ColorBrewer palette name (sequential or diverging works best).
/// @param n-breaks Number of bins to partition the domain into.
/// @param direction `1` for canonical order, `-1` for reversed.
/// @param name Legend title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// @param labels Array of legend labels aligned with the bins, or `auto`.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-colour-fermenter, @scale-fill-distiller
#let scale-fill-fermenter(
  palette: "Spectral",
  n-breaks: 5,
  direction: 1,
  name: none,
  limits: none,
  labels: auto,
) = {
  let stops = brewer-palette(palette)
  if direction < 0 { stops = stops.rev() }
  (
    kind: "scale",
    aesthetic: "fill",
    type: "continuous",
    name: name,
    palette: stops,
    limits: limits,
    labels: labels,
    binned: true,
    n-breaks: n-breaks,
  )
}
