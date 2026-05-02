///! Scale expansion helper, mirroring ggplot2's `expansion()`.
///!
///! `expansion()` returns a dict consumed by the `expand:` argument on
///! positional scales (`scale-x-continuous`, `scale-y-continuous`,
///! `scale-x-discrete`, `scale-y-discrete`, `scale-x-binned`, `scale-y-binned`,
///! `scale-x-date`, etc.).

/// Build a scale expansion specification.
///
/// Each side of the axis is padded by `mult * span + add`, where `span` is
/// the trained data range (in the transformed space for continuous scales,
/// or `n - 1` for discrete scales with `n` levels).
/// Pass a scalar to apply the same value to both sides, or a `(lo, hi)`
/// pair to set them independently.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param mult Multiplicative expansion (scalar or `(lo, hi)` pair).
/// \@param add Additive expansion in data units (scalar or `(lo, hi)` pair).
///
/// \@returns Expansion dictionary accepted by `expand:` on positional scales.
///
/// \@examples Add 5% breathing room on each side of a continuous axis.
/// ```
/// #let d = range(1, 11).map(i => (x: i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-y-continuous(expand: expansion(mult: 0.05)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Asymmetric expansion: zero on the lower side, 0.1 on the upper.
/// ```
/// #let d = range(1, 11).map(i => (x: i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-col(),),
///   scales: (scale-y-continuous(expand: expansion(mult: (0, 0.1))),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-x-continuous, \@expand-limits
#let expansion(mult: 0, add: 0) = (
  kind: "expansion",
  mult: mult,
  add: add,
)

#let _pair(value) = {
  if type(value) == array {
    if value.len() == 2 { return (value.at(0), value.at(1)) }
    if value.len() == 1 { return (value.at(0), value.at(0)) }
    return (0, 0)
  }
  (value, value)
}

#let _default-for(scale-type) = {
  if scale-type == "discrete" { return (0, 0.6, 0, 0.6) }
  (0.05, 0, 0.05, 0)
}

// Coerce a user-provided `expand:` value into the canonical 4-tuple
// `(mult-lo, add-lo, mult-hi, add-hi)`. Accepts `auto`, `false` / `none`,
// an `expansion()` dict, or a length-2 / length-4 array.
#let normalise-expansion(value, scale-type) = {
  if value == auto { return _default-for(scale-type) }
  if value == false or value == none { return (0, 0, 0, 0) }
  if (
    type(value) == dictionary and value.at("kind", default: none) == "expansion"
  ) {
    let (mult-lo, mult-hi) = _pair(value.mult)
    let (add-lo, add-hi) = _pair(value.add)
    return (mult-lo, add-lo, mult-hi, add-hi)
  }
  if type(value) == array and value.len() == 4 {
    return (value.at(0), value.at(1), value.at(2), value.at(3))
  }
  if type(value) == array and value.len() == 2 {
    let (mult-lo, mult-hi) = _pair(value.at(0))
    let (add-lo, add-hi) = _pair(value.at(1))
    return (mult-lo, add-lo, mult-hi, add-hi)
  }
  _default-for(scale-type)
}
