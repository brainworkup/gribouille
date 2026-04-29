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
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param palette Colour source: a gradient, an array of colours, or `auto`.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param breaks Array of break values for the legend, or `auto`.
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default ramp interpolating between the library's low and high
/// blue stops.
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
/// \@examples Pin `limits` to clip the trained domain and render extremes at
/// the palette endpoints.
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-continuous(limits: (1, 4)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-colour-viridis-c, \@scale-colour-discrete, \@scale-fill-continuous
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
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param palette Colour source: an array of colours, or `auto`.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default palette mapping three categories to the library's eight
/// reserved discrete colours.
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
/// \@examples Override `palette` with an explicit colour array to hand-pick
/// the mapping order.
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
///   scales: (scale-colour-discrete(palette: (
///     rgb("#1b9e77"), rgb("#d95f02"), rgb("#7570b3"),
///   )),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-colour-manual, \@scale-colour-viridis-d, \@scale-fill-discrete
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
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param palette Colour source: a gradient, an array of colours, or `auto`.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param breaks Array of break values for the legend, or `auto`.
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default ramp filling bars by their numeric value.
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
/// \@examples The default ramp shown as a continuous swatch via \@geom-rect
/// over a sampled gradient.
/// ```
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-continuous(),),
///   guides: guides(fill: guide-none()),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-fill-viridis-c, \@scale-fill-discrete, \@scale-colour-continuous
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
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param palette Colour source: an array of colours, or `auto`.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default palette filling three bars from the library's reserved
/// discrete colours.
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
/// \@examples The palette laid out as a swatch strip via \@geom-rect, one
/// rectangle per level.
/// ```
/// #let levels = ("a", "b", "c", "d", "e", "f", "g", "h")
/// #let d = levels.enumerate().map(((i, k)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: k,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-discrete(),),
///   guides: guides(fill: guide-none()),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-fill-manual, \@scale-fill-viridis-d, \@scale-colour-discrete
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
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of colours, one per level.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Hand-picked colour array applied to three categorical levels.
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
/// \@examples `limits` fixes the level order independently of how rows appear
/// in the data, useful for stable legends across datasets.
/// ```
/// #let d = (
///   (x: 1, y: 2, sp: "c"),
///   (x: 2, y: 4, sp: "a"),
///   (x: 3, y: 3, sp: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-manual(
///     values: (rgb("#1b9e77"), rgb("#d95f02"), rgb("#7570b3")),
///     limits: ("a", "b", "c"),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-colour-discrete, \@scale-fill-manual
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
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of colours, one per level.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Hand-picked colour array applied to three categorical levels.
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
/// \@examples The same array shown as a swatch strip via \@geom-rect.
/// ```
/// #let pal = (rgb("#66c2a5"), rgb("#fc8d62"), rgb("#8da0cb"))
/// #let d = pal.enumerate().map(((i, _)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: str(i),
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-manual(values: pal),),
///   guides: guides(fill: guide-none()),
///   width: 6cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-fill-discrete, \@scale-colour-manual
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
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Plasma option of the viridis family applied to four categories.
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
/// \@examples Switching `option` to `"cividis"` selects the colour-blind safe
/// alternative.
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
///   scales: (scale-colour-viridis-d(option: "cividis"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-colour-viridis-c, \@scale-colour-viridis-b, \@scale-fill-viridis-d
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
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param breaks Array of break values for the legend, or `auto`.
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Magma option applied to a continuous numeric column.
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
/// \@examples Default `"viridis"` ramp with `limits` clipping the lower tail.
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-viridis-c(limits: (2, 6)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-colour-viridis-d, \@scale-colour-viridis-b, \@scale-fill-viridis-c
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
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// \@param n-breaks Number of bins to partition the domain into.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Four equal-width bins coloured from the default viridis ramp.
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
/// \@examples Bumping `n-breaks` and switching to the inferno option produces
/// a finer-grained banded scale.
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-viridis-b(option: "inferno", n-breaks: 8),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-colour-viridis-c, \@scale-colour-viridis-d, \@scale-fill-viridis-b
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
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Cividis option filling four categorical bars.
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
/// \@examples Each viridis option laid out as a swatch strip via \@geom-rect.
/// ```
/// #let opts = ("viridis", "magma", "plasma", "inferno", "cividis")
/// #let d = opts.enumerate().map(((i, k)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: k,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-viridis-d(option: "magma"),),
///   guides: guides(fill: guide-none()),
///   width: 6cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-fill-viridis-c, \@scale-fill-viridis-b, \@scale-colour-viridis-d
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
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param breaks Array of break values for the legend, or `auto`.
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default viridis ramp filling bars by their numeric value.
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
/// \@examples The viridis ramp shown as a continuous swatch via \@geom-rect.
/// ```
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-viridis-c(),),
///   guides: guides(fill: guide-none()),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-fill-viridis-d, \@scale-fill-viridis-b, \@scale-colour-viridis-c
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
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Identity scales draw no legend, but the title is
///   carried for downstream consumers that may surface it.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Hex strings carried straight through to point strokes; no
/// legend is drawn.
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
/// \@see \@scale-colour-manual, \@scale-fill-identity
#let scale-colour-identity(name: none) = (
  kind: "scale",
  aesthetic: "colour",
  type: "identity",
  name: name,
)

/// Fill scale that uses each row's value as the fill colour directly.
///
/// Values must be hex strings or `color` values; see \@scale-colour-identity.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Identity scales draw no legend.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Per-row hex strings used as fills, with \@geom-rect drawing a
/// custom swatch from arbitrary colours.
/// ```
/// #let d = (
///   (xmin: 0, xmax: 1, ymin: 0, ymax: 1, c: "#1b9e77"),
///   (xmin: 1, xmax: 2, ymin: 0, ymax: 1, c: "#d95f02"),
///   (xmin: 2, xmax: 3, ymin: 0, ymax: 1, c: "#7570b3"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "c"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-identity(),),
///   width: 6cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-fill-manual, \@scale-colour-identity
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
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// \@param n-breaks Number of bins to partition the domain into.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default viridis ramp quantised into four bins for a banded fill.
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
/// \@examples The same ramp shown as a banded swatch via \@geom-rect.
/// ```
/// #let d = range(0, 12).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-viridis-b(option: "plasma", n-breaks: 6),),
///   guides: guides(fill: guide-none()),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-fill-viridis-c, \@scale-fill-viridis-d, \@scale-colour-viridis-b
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
/// \@category Scales
/// \@stability stable
/// \@since 0.1.0
///
/// \@param palette ColorBrewer palette name (qualitative, sequential, or diverging).
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Set1 palette mapping three categorical levels to bold qualitative
/// hues.
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
/// \@examples Switching to the diverging Spectral palette suits ordered
/// categories with a meaningful midpoint.
/// ```
/// #let d = (
///   (x: 1, y: 2, sp: "low"),
///   (x: 2, y: 3, sp: "mid"),
///   (x: 3, y: 4, sp: "high"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-brewer(
///     palette: "Spectral",
///     limits: ("low", "mid", "high"),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-fill-brewer, \@scale-colour-discrete
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
/// Fill counterpart of \@scale-colour-brewer. Same palette names apply.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.1.0
///
/// \@param palette ColorBrewer palette name (qualitative, sequential, or diverging).
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Set1 palette filling categorical bars.
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
///   scales: (scale-fill-brewer(palette: "Set1"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples The Spectral palette laid out as a swatch strip via \@geom-rect.
/// ```
/// #let levels = ("a", "b", "c", "d", "e", "f", "g")
/// #let d = levels.enumerate().map(((i, k)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: k,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-brewer(palette: "Spectral"),),
///   guides: guides(fill: guide-none()),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-brewer, \@scale-fill-discrete
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
/// \@category Scales
/// \@stability stable
/// \@since 0.1.0
///
/// \@param low Colour for the low end of the domain.
/// \@param high Colour for the high end of the domain.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param breaks Array of break values for the legend, or `auto`.
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default low-to-high blue ramp.
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
/// \@examples Custom two-stop ramp passing explicit `low` and `high` colours.
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-gradient(
///     low: rgb("#fee5d9"),
///     high: rgb("#a50f15"),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-colour-gradient2, \@scale-colour-gradientn, \@scale-fill-gradient
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
/// \@category Scales
/// \@stability stable
/// \@since 0.1.0
///
/// \@param low Colour for values far below `midpoint`.
/// \@param mid Colour at `midpoint`.
/// \@param high Colour for values far above `midpoint`.
/// \@param midpoint Value at which the palette transitions through `mid`.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param breaks Array of break values for the legend, or `auto`.
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default diverging ramp pivoting at zero, useful for signed
/// numeric values.
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
/// \@examples Shift `midpoint` to centre the ramp around a non-zero baseline.
/// ```
/// #let d = range(0, 11).map(i => (x: i, y: i, z: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-gradient2(
///     low: rgb("#1a9850"),
///     mid: rgb("#ffffbf"),
///     high: rgb("#d73027"),
///     midpoint: 5,
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-colour-gradient, \@scale-colour-gradientn, \@scale-fill-gradient2
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
/// \@category Scales
/// \@stability stable
/// \@since 0.1.0
///
/// \@param colours Array of two or more colours.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param breaks Array of break values for the legend, or `auto`.
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Three-stop ramp interpolating green-yellow-red across the domain.
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
/// \@examples Feeding a brewer palette into `scale-colour-gradientn` lifts a
/// discrete palette into a continuous ramp.
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-gradientn(
///     colours: brewer-palette("RdYlBu"),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-colour-gradient, \@scale-colour-gradient2, \@scale-fill-gradientn
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
/// Fill counterpart of \@scale-colour-gradient.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.1.0
///
/// \@param low Colour for the low end of the domain.
/// \@param high Colour for the high end of the domain.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param breaks Array of break values for the legend, or `auto`.
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Custom two-stop ramp shown as a continuous swatch via \@geom-rect.
/// ```
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-gradient(
///     low: rgb("#fee5d9"),
///     high: rgb("#a50f15"),
///   ),),
///   guides: guides(fill: guide-none()),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-gradient, \@scale-fill-gradient2, \@scale-fill-gradientn
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
/// Fill counterpart of \@scale-colour-gradient2.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.1.0
///
/// \@param low Colour for values far below `midpoint`.
/// \@param mid Colour at `midpoint`.
/// \@param high Colour for values far above `midpoint`.
/// \@param midpoint Value at which the palette transitions through `mid`.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param breaks Array of break values for the legend, or `auto`.
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Diverging ramp pivoting at zero, shown as a swatch via
/// \@geom-rect.
/// ```
/// #let d = range(-7, 8).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-gradient2(midpoint: 0),),
///   guides: guides(fill: guide-none()),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-gradient2, \@scale-fill-gradient, \@scale-fill-gradientn
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
/// Fill counterpart of \@scale-colour-gradientn.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.1.0
///
/// \@param colours Array of two or more colours.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param breaks Array of break values for the legend, or `auto`.
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Three-stop ramp shown as a continuous swatch via \@geom-rect.
/// ```
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-gradientn(colours: (
///     rgb("#1a9850"), rgb("#ffffbf"), rgb("#d73027"),
///   )),),
///   guides: guides(fill: guide-none()),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-gradientn, \@scale-fill-gradient, \@scale-fill-gradient2
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
/// \@category Scales
/// \@stability stable
/// \@since 0.2.0
///
/// \@param start Luminance for the first level, in `[0, 1]`.
/// \@param end Luminance for the last level, in `[0, 1]`.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default grey ramp from dark to light spread across three levels.
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
/// \@examples Narrowing `start` and `end` constrains the ramp to a darker
/// range for tighter contrast.
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
///   scales: (scale-colour-grey(start: 0.1, end: 0.5),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-fill-grey, \@scale-colour-discrete
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
/// Fill counterpart of \@scale-colour-grey.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.2.0
///
/// \@param start Luminance for the first level, in `[0, 1]`.
/// \@param end Luminance for the last level, in `[0, 1]`.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default grey ramp shown as a swatch strip via \@geom-rect.
/// ```
/// #let levels = ("a", "b", "c", "d", "e", "f")
/// #let d = levels.enumerate().map(((i, k)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: k,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-grey(),),
///   guides: guides(fill: guide-none()),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-grey, \@scale-fill-discrete
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
/// \@category Scales
/// \@stability stable
/// \@since 0.2.0
///
/// \@param h Pair `(start, end)` of hue angles.
/// \@param c Chroma in `[0, 100]`.
/// \@param l Luminance in `[0, 100]`.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default hue wheel mapping four levels to evenly-spaced colours.
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
/// \@examples Lower `c` (chroma) and `l` (luminance) yield a muted, pastel-like
/// palette.
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
///   scales: (scale-colour-hue(c: 50, l: 80),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-fill-hue, \@scale-colour-discrete
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
/// Fill counterpart of \@scale-colour-hue.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.2.0
///
/// \@param h Pair `(start, end)` of hue angles.
/// \@param c Chroma in `[0, 100]`.
/// \@param l Luminance in `[0, 100]`.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default hue wheel shown as a swatch strip via \@geom-rect.
/// ```
/// #let levels = ("a", "b", "c", "d", "e", "f", "g", "h")
/// #let d = levels.enumerate().map(((i, k)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: k,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-hue(),),
///   guides: guides(fill: guide-none()),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-hue, \@scale-fill-discrete
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
/// \@category Scales
/// \@stability stable
/// \@since 0.2.0
///
/// \@param palette ColorBrewer palette name (sequential or diverging works best).
/// \@param direction `1` for canonical order, `-1` for reversed.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param breaks Array of break values for the legend, or `auto`.
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Spectral palette interpolated as a continuous ramp.
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
/// \@examples Set `direction: -1` to reverse the palette so high values map
/// to the canonical low end.
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-distiller(palette: "Blues", direction: -1),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-fill-distiller, \@scale-colour-gradientn, \@scale-colour-brewer
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
/// \@category Scales
/// \@stability stable
/// \@since 0.2.0
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param range Pair `(lo, hi)` bounding the output opacity, each in `[0, 1]`.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param breaks Array of break values for the legend, or `auto`.
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Linear opacity mapping with a wide `range` to fade points from
/// near-transparent to fully opaque.
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
/// \@examples A narrower `range` keeps every point visible while still
/// encoding magnitude.
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, w: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", alpha: "w"),
///   layers: (geom-point(size: 4pt),),
///   scales: (scale-alpha-continuous(range: (0.4, 0.9)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-alpha-identity, \@scale-colour-continuous
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
/// \@category Scales
/// \@stability stable
/// \@since 0.2.0
///
/// \@param name Legend title. Identity scales draw no legend.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Per-row opacity carried straight through to the point fills.
/// ```
/// #let d = (
///   (x: 1, y: 2, w: 0.2),
///   (x: 2, y: 3, w: 0.5),
///   (x: 3, y: 4, w: 0.8),
///   (x: 4, y: 5, w: 1.0),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", alpha: "w"),
///   layers: (geom-point(size: 6pt, fill: rgb("#1f77b4")),),
///   scales: (scale-alpha-identity(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-alpha-continuous, \@scale-colour-identity
#let scale-alpha-identity(name: none) = (
  kind: "scale",
  aesthetic: "alpha",
  type: "identity",
  name: name,
)

/// Continuous ColorBrewer fill scale.
///
/// Fill counterpart of \@scale-colour-distiller.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.2.0
///
/// \@param palette ColorBrewer palette name (sequential or diverging works best).
/// \@param direction `1` for canonical order, `-1` for reversed.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param breaks Array of break values for the legend, or `auto`.
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Spectral palette interpolated across a continuous swatch via
/// \@geom-rect.
/// ```
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-distiller(palette: "Spectral"),),
///   guides: guides(fill: guide-none()),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-distiller, \@scale-fill-gradientn, \@scale-fill-brewer
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
/// \@category Scales
/// \@stability stable
/// \@since 0.3.0
///
/// \@param low Colour for the low end of the domain.
/// \@param high Colour for the high end of the domain.
/// \@param n-breaks Number of bins to partition the domain into.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Five-bin discretisation of the default low-to-high blue ramp.
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
/// \@examples Custom `low`/`high` colours discretised into eight bins.
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 1.0))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-steps(
///     low: rgb("#fee5d9"),
///     high: rgb("#a50f15"),
///     n-breaks: 8,
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-colour-steps2, \@scale-colour-stepsn, \@scale-fill-steps
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
/// \@category Scales
/// \@stability stable
/// \@since 0.3.0
///
/// \@param low Colour for values far below `midpoint`.
/// \@param mid Colour at `midpoint`.
/// \@param high Colour for values far above `midpoint`.
/// \@param midpoint Value at which the palette transitions through `mid`.
/// \@param n-breaks Number of bins to partition the domain into.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Six-bin diverging discretisation pivoting at zero.
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
/// \@examples Shift `midpoint` and adjust the three stops to highlight a
/// non-zero pivot.
/// ```
/// #let d = range(0, 11).map(i => (x: i, y: i, z: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-steps2(
///     low: rgb("#1a9850"),
///     mid: rgb("#ffffbf"),
///     high: rgb("#d73027"),
///     midpoint: 5,
///     n-breaks: 8,
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-colour-steps, \@scale-colour-stepsn, \@scale-fill-steps2
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
/// \@category Scales
/// \@stability stable
/// \@since 0.3.0
///
/// \@param colours Array of two or more colours.
/// \@param n-breaks Number of bins to partition the domain into.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Three-stop ramp discretised into six bins.
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
/// \@examples Reuse a brewer palette as the stop list to fold a discrete
/// palette into a banded continuous scale.
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-stepsn(
///     colours: brewer-palette("YlOrRd"),
///     n-breaks: 5,
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-colour-steps, \@scale-colour-steps2, \@scale-fill-stepsn
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
/// \@category Scales
/// \@stability stable
/// \@since 0.3.0
///
/// \@param palette ColorBrewer palette name (sequential or diverging works best).
/// \@param n-breaks Number of bins to partition the domain into.
/// \@param direction `1` for canonical order, `-1` for reversed.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Spectral palette quantised into five bins.
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
/// \@examples Sequential blues palette reversed via `direction: -1` for an
/// inverted banding.
/// ```
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-fermenter(
///     palette: "Blues",
///     direction: -1,
///     n-breaks: 7,
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-colour-distiller, \@scale-fill-fermenter
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
/// Fill counterpart of \@scale-colour-steps.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.3.0
///
/// \@param low Colour for the low end of the domain.
/// \@param high Colour for the high end of the domain.
/// \@param n-breaks Number of bins to partition the domain into.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Five-bin discretised fill ramp shown as a swatch via \@geom-rect.
/// ```
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-steps(n-breaks: 5),),
///   guides: guides(fill: guide-none()),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-steps, \@scale-fill-steps2, \@scale-fill-stepsn
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
/// Fill counterpart of \@scale-colour-steps2.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.3.0
///
/// \@param low Colour for values far below `midpoint`.
/// \@param mid Colour at `midpoint`.
/// \@param high Colour for values far above `midpoint`.
/// \@param midpoint Value at which the palette transitions through `mid`.
/// \@param n-breaks Number of bins to partition the domain into.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Six-bin diverging swatch pivoting at zero.
/// ```
/// #let d = range(-7, 8).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-steps2(midpoint: 0, n-breaks: 6),),
///   guides: guides(fill: guide-none()),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-steps2, \@scale-fill-steps, \@scale-fill-stepsn
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
/// Fill counterpart of \@scale-colour-stepsn.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.3.0
///
/// \@param colours Array of two or more colours.
/// \@param n-breaks Number of bins to partition the domain into.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Three-stop ramp discretised into six bins, shown as a swatch
/// via \@geom-rect.
/// ```
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-stepsn(colours: (
///     rgb("#1a9850"), rgb("#ffffbf"), rgb("#d73027"),
///   ), n-breaks: 6),),
///   guides: guides(fill: guide-none()),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-stepsn, \@scale-fill-steps, \@scale-fill-steps2
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
/// Fill counterpart of \@scale-colour-fermenter.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.3.0
///
/// \@param palette ColorBrewer palette name (sequential or diverging works best).
/// \@param n-breaks Number of bins to partition the domain into.
/// \@param direction `1` for canonical order, `-1` for reversed.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Spectral palette quantised into five bins, shown as a swatch
/// via \@geom-rect.
/// ```
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-fermenter(palette: "Spectral", n-breaks: 5),),
///   guides: guides(fill: guide-none()),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-fermenter, \@scale-fill-distiller
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
