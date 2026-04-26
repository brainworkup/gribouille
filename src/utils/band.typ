///! Helper for the symmetric x-band shared by boxplot/errorbar/crossbar.

#import "../scale/train.typ": map-continuous, map-position
#import "types.typ": parse-number

/// Compute `(cx-lo, cx-hi)` for a horizontal band of half-width `half-width`
/// centred on `raw-x`.
///
/// For continuous x the band edges are mapped through `map-continuous` so the
/// half-width is interpreted in x data units. For discrete x the band is sized
/// as a fraction of the per-category slot width.
///
/// Returns `none` when the centre cannot be mapped, or when continuous x fails
/// to parse as a number. Callers decide whether to skip the row or fall back
/// to `(cx, cx)` in the parse-failure case.
#let x-band(x-trained, raw-x, half-width, px-range) = {
  if x-trained.type == "continuous" {
    let raw-num = parse-number(raw-x)
    if raw-num == none { return none }
    (
      map-continuous(raw-num - half-width, x-trained.domain, px-range),
      map-continuous(raw-num + half-width, x-trained.domain, px-range),
    )
  } else {
    let cx = map-position(x-trained, raw-x, px-range)
    if cx == none { return none }
    let n = x-trained.domain.len()
    if n == 0 { return none }
    let (px-lo, px-hi) = px-range
    let slot = (px-hi - px-lo) / n
    let half-px = slot * half-width
    (cx - half-px, cx + half-px)
  }
}
