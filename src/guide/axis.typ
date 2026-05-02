///! Axis guide customisation.
///!
///! Build a guide spec the axis renderer respects when bound to the `x` or
///! `y` aesthetic via \@guides. Rotate tick labels with `angle` or stagger
///! them across multiple rows (x) or columns (y) with `n-dodge` to prevent
///! overlap.

/// Customise the x- or y-axis tick labels.
///
/// The returned spec carries customisation only; it is bound to an aesthetic
/// when passed through \@guides as `x: guide-axis(...)` or `y: guide-axis(...)`,
/// and applied by the axis renderer when drawing tick labels. On the x-axis
/// `n-dodge` staggers labels across rows; on the y-axis it staggers them
/// across columns receding from the axis.
///
/// \@category Guides
/// \@stability stable
/// \@since 0.0.1
///
/// \@param angle Tick-label rotation in degrees: 0 horizontal, 45 readable diagonal, 90 vertical.
/// \@param n-dodge Number of rows (x-axis) or columns (y-axis) across which to stagger tick labels; 1 keeps them on a single row/column.
///
/// \@returns Guide dictionary tagged `kind: "guide"`, consumed by \@guides.
///
/// \@examples Rotate long x tick labels so they don't overlap.
/// ```
/// #let d = (
///   (x: "January", y: 1),
///   (x: "February", y: 2),
///   (x: "March", y: 3),
///   (x: "April", y: 4),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   guides: guides(x: guide-axis(angle: 30)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Stagger labels across two rows when many short ticks would
/// pile up.
/// ```
/// #let months = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug")
/// #let d = months.enumerate().map(((i, m)) => (x: m, y: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-col(),),
///   guides: guides(x: guide-axis(n-dodge: 2)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Rotate long y tick labels.
/// ```
/// #let cities = ("Anvers", "Bruxelles", "Charleroi", "Liège")
/// #let d = cities.enumerate().map(((i, c)) => (x: i + 1, y: c))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   guides: guides(y: guide-axis(angle: 30)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@guides, \@guide-legend, \@plot
#let guide-axis(angle: 0, n-dodge: 1) = (
  kind: "guide",
  aesthetic: none,
  angle: angle,
  n-dodge: n-dodge,
)
