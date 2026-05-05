///! Polar coordinate system.

/// Polar coordinate system.
///
/// `theta = "x"` (default) distributes categories around the circle for
/// rose / radar layouts; `theta = "y"` turns stacked y values into wedges
/// for pie / donut layouts.
///
/// \@category Coord
/// \@stability experimental
/// \@since 0.5.0
///
/// \@param theta Which axis is angular: `"x"` (default) or `"y"`.
/// \@param start Offset in radians from 12 o'clock for the first slice.
/// \@param direction `1` (default) advances clockwise; `-1` counter-clockwise.
/// \@param clip `"on"` (default) clips marks to the panel rectangle; `"off"` lets marks render past it.
///
/// \@returns Coordinate dictionary consumed by \@plot.
///
/// \@examples Pie chart from a stacked column.
/// ```
/// #let d = (
///   (slice: "all", value: 30, kind: "A"),
///   (slice: "all", value: 20, kind: "B"),
///   (slice: "all", value: 50, kind: "C"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "slice", y: "value", fill: "kind"),
///   layers: (geom-col(width: 1, position: "stack"),),
///   coord: coord-polar(theta: "y"),
///   width: 7cm,
///   height: 7cm,
/// )
/// ```
///
/// \@see \@plot, \@geom-col
#let coord-polar(theta: "x", start: 0, direction: 1, clip: "on") = (
  kind: "coord",
  coord: "polar",
  theta: theta,
  start: start,
  direction: direction,
  clip: clip,
)
