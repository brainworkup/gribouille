///! Flipped coordinate system swapping the x and y axes at render time.
///!
///! Scale training is unchanged; only the rendered axes and any direction-
///! sensitive geoms are swapped so vertical bars become horizontal bars,
///! horizontal reference lines become vertical, and so on.

/// Cartesian coordinate system with the x and y axes swapped at render time.
///
/// Use this to turn a vertical bar chart into a horizontal one without
/// rewriting the data or the mapping. The axis labels, ticks, and the
/// directional geoms (`geom-col`, `geom-hline`, `geom-vline`, `geom-abline`)
/// follow the swap automatically. Direction-agnostic geoms (`geom-point`,
/// `geom-line`, `geom-path`, `geom-step`, `geom-segment`) work via the same
/// swap with no per-geom changes.
///
/// @category Coord
/// @stability experimental
/// @since 0.0.1
///
/// @returns Coordinate dictionary consumed by @plot.
///
/// @examples Flip a vertical bar chart into a horizontal one without
/// rewriting the mapping.
/// ```
/// #let d = (
///   (q: "Q1", revenue: 10),
///   (q: "Q2", revenue: 18),
///   (q: "Q3", revenue: 25),
///   (q: "Q4", revenue: 22),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "revenue"),
///   layers: (geom-col(),),
///   coord: coord-flip(),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @examples Reference lines follow the flip: a `yintercept` becomes a
/// vertical reference once the axes swap.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-hline(yintercept: 2.5, colour: rgb("#cc0000")),
///   ),
///   coord: coord-flip(),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @plot, @coord-cartesian, @geom-col
#let coord-flip() = (
  kind: "coord",
  coord: "flip",
)
