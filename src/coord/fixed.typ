///! Fixed aspect-ratio coordinate system.
///!
///! Locks the panel so that one data unit on x maps to `ratio` data units on y.
///! Scale training is unchanged; only the inner panel pixel size is adjusted.

/// Cartesian coordinate system with a fixed data-unit aspect ratio.
///
/// The user's `width` and `height` act as upper bounds: the renderer keeps
/// the smaller of the two derived panel dimensions and shrinks the longer
/// axis so that one x data unit projects to `ratio` y data units.
///
/// @category Coord
/// @stability stable
/// @since 0.0.1
///
/// @param ratio Number of y data units per x data unit (default `1`).
///
/// @returns Coordinate dictionary consumed by @plot.
///
/// @example
/// ```
/// //| width: 10cm
/// //| height: 6cm
/// #let d = range(0, 20).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   coord: coord-fixed(ratio: 1),
/// )
/// ```
///
/// @see @plot, @coord-cartesian
#let coord-fixed(ratio: 1) = (
  kind: "coord",
  coord: "fixed",
  ratio: ratio,
)
