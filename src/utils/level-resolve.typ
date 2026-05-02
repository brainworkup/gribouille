// Level-to-value resolution for legend glyph composition.
//
// Each aesthetic maps a value (a discrete level string or a continuous number)
// to a visual quantity: a colour, a shape keyword, a dash keyword, a size
// length, an opacity, or a stroke thickness. The geom drawing path uses the
// per-row resolvers in `colour-resolve.typ`/`fill-resolve.typ`; the legend
// path needs the same answer keyed by *level* rather than by row, so this
// module exposes a thin level-driven kernel that the swatch composer can call.
//
// Returns `none` when the aesthetic cannot be resolved (e.g. continuous
// linetype is meaningless): the caller treats `none` as "drop this aesthetic
// from the composed glyph".

#import "./colour.typ": resolve-continuous-colour
#import "./palette.typ": (
  default-linetypes, default-shapes, palette-at, spec-palette,
)
#import "../scale/train.typ": map-continuous

#let spec-range(trained, fallback) = {
  let spec = trained.at("spec", default: none)
  if spec == none { return fallback }
  spec.at("range", default: fallback)
}

#let discrete-index(trained, level) = {
  let s = str(level)
  trained.domain.position(v => v == s)
}

#let discrete-numeric(trained, level, range) = {
  let n = trained.domain.len()
  if n == 0 { return none }
  let (lo, hi) = range
  if n == 1 { return (lo + hi) / 2 }
  let idx = discrete-index(trained, level)
  if idx == none { return none }
  lo + idx * (hi - lo) / (n - 1)
}

#let continuous-numeric(trained, value, range) = {
  let (d-lo, d-hi) = trained.domain
  let (lo, hi) = range
  if d-hi == d-lo { return (lo + hi) / 2 }
  let t = (value - d-lo) / (d-hi - d-lo)
  let t-clamped = if t < 0 { 0 } else if t > 1 { 1 } else { t }
  lo + t-clamped * (hi - lo)
}

// Resolve a single aesthetic for a given value. `value` is a discrete level
// string when `trained.type == "discrete"` and a number when continuous.
//
// `palette` overrides the trained spec's palette where the aesthetic is
// palette-driven (colour/fill); pass `none` to use the trained spec or the
// library default.
#let resolve-level(aesthetic, trained, value, palette: none, ink: black) = {
  if trained == none { return none }
  if trained.type == "identity" { return value }

  if aesthetic == "colour" or aesthetic == "fill" {
    let pal = spec-palette(trained, palette)
    if pal == none { return ink }
    if trained.type == "discrete" {
      let idx = discrete-index(trained, value)
      if idx == none { return ink }
      return palette-at(pal, idx)
    }
    return resolve-continuous-colour(trained, value, pal, ink)
  }

  if aesthetic == "shape" {
    if trained.type != "discrete" { return none }
    let pal = spec-palette(trained, default-shapes)
    let idx = discrete-index(trained, value)
    if idx == none { return none }
    return palette-at(pal, idx)
  }

  if aesthetic == "linetype" {
    if trained.type != "discrete" { return none }
    let pal = spec-palette(trained, default-linetypes)
    let idx = discrete-index(trained, value)
    if idx == none { return none }
    return palette-at(pal, idx)
  }

  if aesthetic == "size" {
    let range = spec-range(trained, (1pt, 6pt))
    if trained.type == "discrete" {
      let pal = spec-palette(trained, none)
      if pal != none and pal.len() > 0 {
        let idx = discrete-index(trained, value)
        if idx == none { return none }
        return palette-at(pal, idx)
      }
      return discrete-numeric(trained, value, range)
    }
    return continuous-numeric(trained, value, range)
  }

  if aesthetic == "linewidth" {
    let range = spec-range(trained, (0.4pt, 1.4pt))
    if trained.type == "discrete" {
      let pal = spec-palette(trained, none)
      if pal != none and pal.len() > 0 {
        let idx = discrete-index(trained, value)
        if idx == none { return none }
        return palette-at(pal, idx)
      }
      return discrete-numeric(trained, value, range)
    }
    return continuous-numeric(trained, value, range)
  }

  if aesthetic == "alpha" {
    let range = spec-range(trained, (0.1, 1))
    if trained.type == "discrete" {
      let pal = spec-palette(trained, none)
      if pal != none and pal.len() > 0 {
        let idx = discrete-index(trained, value)
        if idx == none { return none }
        return palette-at(pal, idx)
      }
      return discrete-numeric(trained, value, range)
    }
    return continuous-numeric(trained, value, range)
  }

  none
}
