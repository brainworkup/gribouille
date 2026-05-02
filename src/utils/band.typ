///! Helper for the symmetric x-band shared by boxplot/errorbar/crossbar.

#import "../scale/train.typ": discrete-slot-width, map-axis, map-position
#import "types.typ": parse-number

/// Compute the panel x-coordinate range of a band centred on `raw-x`.
///
/// For continuous x the band edges are mapped through `map-axis` so the
/// half-width is interpreted in x data units and any scale `view-trans`
/// expansion is honoured. For discrete x the band is sized as a fraction
/// of the per-category slot width, accounting for `view-index` expansion.
///
/// \@internal
///
/// \@param x-trained Trained x scale dictionary providing `type` and `domain`.
/// \@param raw-x Row x value (numeric for continuous, raw level for discrete).
/// \@param half-width Band half-width in x data units (continuous) or as a fraction of the slot (discrete).
/// \@param px-range Pair `(lo, hi)` giving the panel x extent in cetz units.
///
/// \@returns Pair `(cx-lo, cx-hi)` of mapped band edges, or `none` when the centre cannot be mapped.
#let x-band(x-trained, raw-x, half-width, px-range) = {
  if x-trained.type == "continuous" {
    let raw-num = parse-number(raw-x)
    if raw-num == none { return none }
    (
      map-axis(x-trained, raw-num - half-width, px-range),
      map-axis(x-trained, raw-num + half-width, px-range),
    )
  } else {
    let cx = map-position(x-trained, raw-x, px-range)
    if cx == none { return none }
    let half-px = discrete-slot-width(x-trained, px-range) * half-width
    (cx - half-px, cx + half-px)
  }
}
