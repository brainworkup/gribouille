///! Top-level shortcuts for axis limits.
///!
///! Sugar over @scale-x-continuous and @scale-y-continuous so users can clip
///! or extend axis domains without spelling out a full scale spec. `xlim` and
///! `ylim` clip the trained domain; `expand-limits` only extends it so the
///! data range is preserved when wider.

#import "scale/continuous.typ": scale-x-continuous, scale-y-continuous

/// Clip the x-axis to the interval `(lo, hi)`.
///
/// Sugar over `scale-x-continuous(limits: (lo, hi))`. Pass directly through
/// `scales:` on @plot.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param lo Lower bound of the x-axis domain.
/// @param hi Upper bound of the x-axis domain.
///
/// @returns Continuous x scale spec consumed by @plot.
///
/// @example
/// ```
/// //| width: 10cm
/// //| height: 6cm
/// #let d = range(1, 6).map(i => (x: i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   scales: (xlim(0, 10),),
/// )
/// ```
///
/// @see @ylim, @lims, @expand-limits, @scale-x-continuous
#let xlim(lo, hi) = scale-x-continuous(limits: (lo, hi))

/// Clip the y-axis to the interval `(lo, hi)`.
///
/// Sugar over `scale-y-continuous(limits: (lo, hi))`. Pass directly through
/// `scales:` on @plot.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param lo Lower bound of the y-axis domain.
/// @param hi Upper bound of the y-axis domain.
///
/// @returns Continuous y scale spec consumed by @plot.
///
/// @example
/// ```
/// //| width: 10cm
/// //| height: 6cm
/// #let d = range(1, 6).map(i => (x: i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   scales: (ylim(0, 10),),
/// )
/// ```
///
/// @see @xlim, @lims, @expand-limits, @scale-y-continuous
#let ylim(lo, hi) = scale-y-continuous(limits: (lo, hi))

/// Bundle x- and y-axis limits into a single `scales:` argument.
///
/// Returns an array of scale specs from @xlim and @ylim when the
/// corresponding argument is non-`none`. Convenient when both axes need
/// clipping at once.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param x Pair `(lo, hi)` for the x-axis, or `none` to leave x untouched.
/// @param y Pair `(lo, hi)` for the y-axis, or `none` to leave y untouched.
///
/// @returns Array of scale specs ready to splat into `scales:` on @plot.
///
/// @example
/// ```
/// //| width: 10cm
/// //| height: 6cm
/// #let d = range(1, 6).map(i => (x: i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   scales: lims(x: (0, 10), y: (0, 10)),
/// )
/// ```
///
/// @see @xlim, @ylim, @expand-limits
#let lims(x: none, y: none) = {
  let out = ()
  if x != none { out.push(xlim(..x)) }
  if y != none { out.push(ylim(..y)) }
  out
}

/// Ensure the trained domain includes the supplied values without replacing it.
///
/// Unlike @lims, `expand-limits` does not clip the data; it folds `extend`
/// values into the trained min/max so the final domain spans both the data
/// and the supplied points. Useful for forcing a baseline at zero or showing
/// a target value alongside observed data.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param x Single value or array of values the x-axis must include, or `none`.
/// @param y Single value or array of values the y-axis must include, or `none`.
///
/// @returns Array of scale specs ready to splat into `scales:` on @plot.
///
/// @example
/// ```
/// //| width: 10cm
/// //| height: 6cm
/// #let d = range(1, 6).map(i => (x: i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   scales: expand-limits(y: 0),
/// )
/// ```
///
/// @see @lims, @xlim, @ylim
#let expand-limits(x: none, y: none) = {
  let _values(v) = if type(v) == array { v } else { (v,) }
  let out = ()
  if x != none {
    let s = scale-x-continuous()
    s.insert("extend", _values(x))
    out.push(s)
  }
  if y != none {
    let s = scale-y-continuous()
    s.insert("extend", _values(y))
    out.push(s)
  }
  out
}
