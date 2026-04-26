///! Secondary axes for continuous x and y scales.
///!
///! A secondary axis draws an extra set of ticks on the opposite side of the
///! panel, optionally derived from the primary axis through a transformation
///! function. Pass the result of `dup-axis` or `sec-axis` to the `secondary:`
///! parameter of `scale-x-continuous` or `scale-y-continuous`.

/// Duplicate the primary axis on the opposite side of the panel.
///
/// Draws the same ticks as the primary axis but on the top edge for x or
/// the right edge for y, optionally with a different title.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param name Title shown above or beside the secondary axis, or `none`.
/// @param breaks Array of break values, or `auto` to mirror the primary axis.
/// @param labels Array of labels aligned with `breaks`, or `auto`.
///
/// @returns Secondary axis dictionary consumed by @scale-x-continuous and @scale-y-continuous.
///
/// @example
/// ```
/// #let d = range(0, 11).map(i => (x: i, y: i * i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (
///     scale-x-continuous(name: "x", secondary: dup-axis(name: "x'")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @sec-axis, @scale-x-continuous, @scale-y-continuous
#let dup-axis(name: none, breaks: auto, labels: auto) = (
  kind: "secondary-axis",
  trans: "identity",
  name: name,
  breaks: breaks,
  labels: labels,
)

/// Secondary axis derived from the primary through a transformation.
///
/// `trans` is a function mapping a primary-axis value to its secondary-axis
/// value. Use `"identity"` to mirror the primary axis exactly, or pass any
/// callable, e.g. `x => x * 9 / 5 + 32` for Celsius to Fahrenheit.
///
/// @category Scales
/// @stability stable
/// @since 0.0.1
///
/// @param trans Function or `"identity"` mapping primary values to secondary values.
/// @param name Title shown above or beside the secondary axis, or `none`.
/// @param breaks Array of break values in primary units, or `auto`.
/// @param labels Array of labels aligned with `breaks`, or `auto`.
///
/// @returns Secondary axis dictionary consumed by @scale-x-continuous and @scale-y-continuous.
///
/// @example
/// ```
/// #let d = range(0, 11).map(i => (c: i * 5, mpg: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "c", y: "mpg"),
///   layers: (geom-point(size: 2pt),),
///   scales: (
///     scale-x-continuous(
///       name: "Celsius",
///       secondary: sec-axis(trans: x => x * 9 / 5 + 32, name: "Fahrenheit"),
///     ),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @dup-axis, @scale-x-continuous, @scale-y-continuous
#let sec-axis(trans: "identity", name: none, breaks: auto, labels: auto) = (
  kind: "secondary-axis",
  trans: trans,
  name: name,
  breaks: breaks,
  labels: labels,
)

// Map a primary value through the secondary's transformation.
#let apply-trans(sec, value) = {
  let t = sec.trans
  if t == "identity" or t == none { return value }
  t(value)
}
