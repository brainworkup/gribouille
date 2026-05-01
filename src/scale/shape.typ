///! Shape scale.
///!
///! Maps discrete levels onto marker-shape keywords consumed by \@geom-point
///! (`"circle"`, `"square"`, `"triangle"`, `"diamond"`, `"cross"`, `"x"`,
///! `"star"`, `"triangle-down"`).

#import "../utils/palette.typ": default-shapes

/// Discrete shape scale: maps levels to marker-shape keywords.
///
/// Pass a custom array of keywords via `palette` to override the default
/// shape set.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param palette Array of shape keywords, or `auto` for the library default.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default shape palette mapping three categories to distinct
/// markers.
/// ```
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", shape: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-shape(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Pair `shape` and `fill` mappings with the same column to
/// reinforce the categorical encoding.
/// ```
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", shape: "sp", fill: "sp"),
///   layers: (geom-point(size: 4pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-shape-manual, \@geom-point
#let scale-shape(name: none, palette: auto, limits: none, labels: auto) = (
  kind: "scale",
  aesthetic: "shape",
  type: "discrete",
  name: name,
  palette: if palette == auto { default-shapes } else { palette },
  limits: limits,
  labels: labels,
)

/// Manual discrete shape scale: supply the shape-keyword array directly.
///
/// Keywords cycle through `values` in the order levels appear, unless
/// `limits` fixes the level order.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of shape keywords, one per level.
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
/// \@param limits Array of level names controlling order and inclusion, or `none`.
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Custom three-shape cycle assigned in input order.
/// ```
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", shape: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-shape-manual(
///     values: ("circle", "triangle", "diamond"),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples `limits` pins the level order so the shape mapping stays
/// stable across datasets.
/// ```
/// #let d = (
///   (x: 1, y: 3, sp: "c"),
///   (x: 2, y: 4, sp: "a"),
///   (x: 3, y: 2, sp: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", shape: "sp"),
///   layers: (geom-point(size: 4pt),),
///   scales: (scale-shape-manual(
///     values: ("circle", "triangle", "diamond"),
///     limits: ("a", "b", "c"),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-shape, \@geom-point
#let scale-shape-manual(values: (), name: none, limits: none, labels: auto) = (
  kind: "scale",
  aesthetic: "shape",
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  labels: labels,
)

/// Shape scale that uses each row's value as the marker keyword directly.
///
/// The mapped column must contain shape keywords accepted by \@geom-point
/// (`"circle"`, `"square"`, `"triangle"`, `"diamond"`, `"cross"`, `"x"`,
/// `"star"`, `"triangle-down"`).
///
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Identity scales draw no legend.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Per-row shape keyword carried straight through to the marker.
/// ```
/// #let d = (
///   (x: 1, y: 2, sh: "circle"),
///   (x: 2, y: 4, sh: "triangle"),
///   (x: 3, y: 3, sh: "diamond"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", shape: "sh"),
///   layers: (geom-point(size: 4pt),),
///   scales: (scale-shape-identity(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-shape, \@scale-shape-manual, \@geom-point
#let scale-shape-identity(name: none) = (
  kind: "scale",
  aesthetic: "shape",
  type: "identity",
  name: name,
)
