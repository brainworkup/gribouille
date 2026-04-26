/// Blend two colours.
///
/// Mirrors ggplot2's `col_mix(col1, col2, amount)`:
/// `amount` is the fraction of `col2` (0 = pure `col1`, 1 = pure `col2`).
/// Mixing happens in sRGB so `col-mix(black, white, 0.92)` returns `grey92`.
///
/// @category Scales
/// @stability stable
/// @since 0.1.0
///
/// @param col1 Base colour.
/// @param col2 Colour to blend in.
/// @param amount Fraction of `col2` in the result (0 to 1).
/// @returns Blended colour.
#let col-mix(col1, col2, amount) = color.mix(
  (col1, 1 - amount),
  (col2, amount),
  space: rgb,
)

// Build an n-stop grey ramp from `start` (darker) to `end` (lighter), each
// expressed as a fraction in 0..1 where 0 is black and 1 is white. Returns
// `n` `luma` colours evenly spaced in luminance.
#let grey-palette(n, start: 0.2, end: 0.8) = {
  let count = calc.max(1, int(n))
  if count == 1 { return (luma(start * 100%),) }
  range(count).map(i => {
    let t = i / (count - 1)
    let v = start + t * (end - start)
    luma(v * 100%)
  })
}

// Build an n-stop equally-spaced hue ramp in OKLCh space. `h` is a pair
// `(start, end)` of angles. The first colour sits at `h.at(0)` and
// successive colours step by `(end - start) / n` so the endpoint is
// excluded, matching ggplot2's `scale_colour_hue()` default.
#let hue-palette(n, h: (15deg, 375deg), c: 100, l: 65) = {
  let count = calc.max(1, int(n))
  let (h-lo, h-hi) = h
  let span = h-hi - h-lo
  let step = span / count
  let lightness = calc.max(0, calc.min(100, l)) * 1%
  let chroma-frac = calc.max(0, calc.min(100, c)) / 100
  let chroma = chroma-frac * 0.18 + 0.02
  range(count).map(i => oklch(lightness, chroma, h-lo + step * i))
}

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
