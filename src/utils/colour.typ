/// Blend two colours.
///
/// Mirrors ggplot2's `col_mix(col1, col2, amount)`:
/// `amount` is the fraction of `col2` (0 = pure `col1`, 1 = pure `col2`).
///
/// @category Scales
/// @stability stable
/// @since 0.1.0
///
/// @param col1 Base colour.
/// @param col2 Colour to blend in.
/// @param amount Fraction of `col2` in the result (0–1).
/// @returns Blended colour.
#let col-mix(col1, col2, amount) = col1.mix((col2, amount * 100%))

// Walk an n-stop palette: linearly interpolate between consecutive stops to
// turn a normalised position `t` (in 0..1) into a colour. Used by gradientn
// resolvers in the renderer and the legend.
#let interpolate-stops(palette, t) = {
  let n = palette.len()
  if n == 0 { return none }
  if n == 1 { return palette.first() }
  let tc = calc.max(0.0, calc.min(1.0, t))
  if tc <= 0.0 { return palette.first() }
  if tc >= 1.0 { return palette.last() }
  let scaled = tc * (n - 1)
  let i = int(scaled)
  let frac = scaled - i
  let a = palette.at(i)
  let b = palette.at(i + 1)
  a.mix((b, frac * 100%))
}

// Resolve a continuous numeric value to a colour, given a trained scale dict
// (with `domain`) and a palette of one or more stops. If the trained spec
// carries a `midpoint`, treat the palette as `(low, mid, high)` and split
// the interpolation at the midpoint, matching ggplot2's gradient2 semantics.
#let resolve-continuous-colour(trained, value, palette, fallback) = {
  if palette == none or palette.len() == 0 { return fallback }
  let (lo, hi) = trained.domain
  if hi == lo { return palette.first() }
  let spec = trained.at("spec", default: none)
  let midpoint = if spec == none { none } else {
    spec.at("midpoint", default: none)
  }
  if midpoint != none and palette.len() >= 3 {
    let low = palette.first()
    let mid = palette.at(1)
    let high = palette.last()
    if value <= midpoint {
      let span = midpoint - lo
      if span <= 0 { return mid }
      let t = calc.max(0.0, calc.min(1.0, (value - lo) / span))
      if t <= 0.0 { return low }
      if t >= 1.0 { return mid }
      return low.mix((mid, t * 100%))
    }
    let span = hi - midpoint
    if span <= 0 { return mid }
    let t = calc.max(0.0, calc.min(1.0, (value - midpoint) / span))
    if t <= 0.0 { return mid }
    if t >= 1.0 { return high }
    return mid.mix((high, t * 100%))
  }
  let t = (value - lo) / (hi - lo)
  interpolate-stops(palette, t)
}
