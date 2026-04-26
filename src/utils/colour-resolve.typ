#import "../scale/train.typ": map-continuous
#import "./types.typ": parse-number

/// Apply an alpha transparentise to an already-resolved colour.
///
/// Returns `colour` unchanged when `alpha` is `>= 1`, otherwise returns
/// `colour.transparentize((1 - alpha) * 100%)`.
///
/// @param colour A resolved colour value.
/// @param alpha Opacity in `[0, 1]`.
/// @returns The colour with alpha applied.
#let apply-alpha(colour, alpha) = {
  if alpha < 1 { colour.transparentize((1 - alpha) * 100%) } else { colour }
}

#let _clamp(x, lo, hi) = {
  if x < lo { lo } else if x > hi { hi } else { x }
}

/// Resolve a per-row alpha value, falling back to the layer's fixed alpha.
///
/// If `mapping.alpha` is set and a trained alpha scale exists, reads the
/// row's value and resolves it through the trained scale: continuous scales
/// linearly interpolate the spec's `range` between domain endpoints, discrete
/// scales pick from the spec's `range` by level index, and identity scales
/// pass the value through clamped to `[0, 1]`. Otherwise returns
/// `layer.params.alpha`.
///
/// @param layer The layer dictionary providing `params.alpha`.
/// @param mapping The resolved aesthetic mapping.
/// @param ctx The plot context exposing `trained`.
/// @param sample-row The row used to read the alpha value.
/// @returns A scalar alpha in `[0, 1]`.
#let resolve-alpha(layer, mapping, ctx, sample-row) = {
  let col = if mapping == none { none } else {
    mapping.at("alpha", default: none)
  }
  let trained = ctx.trained.at("alpha", default: none)
  if col == none or trained == none {
    return layer.params.at("alpha", default: 1)
  }
  let raw = sample-row.at(col, default: none)
  if raw == none { return layer.params.at("alpha", default: 1) }
  if trained.type == "identity" {
    let v = parse-number(raw)
    if v == none { return layer.params.at("alpha", default: 1) }
    return _clamp(v, 0, 1)
  }
  let spec = trained.at("spec", default: none)
  let range = if spec != none { spec.at("range", default: (0.1, 1)) } else {
    (0.1, 1)
  }
  if trained.type == "continuous" {
    let v = parse-number(raw)
    if v == none { return layer.params.at("alpha", default: 1) }
    return _clamp(map-continuous(v, trained.domain, range), 0, 1)
  }
  let s = str(raw)
  let idx = trained.domain.position(v => v == s)
  let n = trained.domain.len()
  if idx == none or n == 0 { return layer.params.at("alpha", default: 1) }
  let (lo, hi) = range
  if n == 1 { return _clamp((lo + hi) / 2, 0, 1) }
  _clamp(lo + idx * (hi - lo) / (n - 1), 0, 1)
}

/// Resolve a per-row stroke thickness, falling back to a default length.
///
/// If `mapping.linewidth` is set and a trained linewidth scale exists, reads
/// the row's value and resolves it through the trained scale: continuous
/// scales linearly interpolate the spec's `range` of Typst lengths, discrete
/// scales pick from the spec's `range` by level index, and identity scales
/// pass the length through unchanged. Otherwise returns `default-thickness`.
///
/// @param layer The layer dictionary (kept for symmetry with `resolve-alpha`).
/// @param mapping The resolved aesthetic mapping.
/// @param ctx The plot context exposing `trained`.
/// @param sample-row The row used to read the linewidth value.
/// @param default-thickness Fallback thickness when no mapping or scale applies.
/// @returns A Typst length suitable for `stroke.thickness`.
#let resolve-linewidth(layer, mapping, ctx, sample-row, default-thickness) = {
  let col = if mapping == none { none } else {
    mapping.at("linewidth", default: none)
  }
  let trained = ctx.trained.at("linewidth", default: none)
  if col == none or trained == none { return default-thickness }
  let raw = sample-row.at(col, default: none)
  if raw == none { return default-thickness }
  if trained.type == "identity" {
    if type(raw) == length { return raw }
    let v = parse-number(raw)
    if v == none { return default-thickness }
    return v * 1pt
  }
  let spec = trained.at("spec", default: none)
  let range = if spec != none {
    spec.at("range", default: (0.4pt, 1.4pt))
  } else {
    (0.4pt, 1.4pt)
  }
  let (lo, hi) = range
  if trained.type == "continuous" {
    let v = parse-number(raw)
    if v == none { return default-thickness }
    let (d-lo, d-hi) = trained.domain
    if d-hi == d-lo { return (lo + hi) / 2 }
    let t = (v - d-lo) / (d-hi - d-lo)
    let t-clamped = if t < 0 { 0 } else if t > 1 { 1 } else { t }
    return lo + t-clamped * (hi - lo)
  }
  let s = str(raw)
  let idx = trained.domain.position(v => v == s)
  let n = trained.domain.len()
  if idx == none or n == 0 { return default-thickness }
  if n == 1 { return (lo + hi) / 2 }
  lo + idx * (hi - lo) / (n - 1)
}

/// Resolve a stroke colour for a row sample.
///
/// Looks up the colour-mapped column on `sample-row` and resolves it through
/// the trained colour scale, falling back to `default-colour` when no mapping
/// or no trained scale is available.
/// Applies the per-row alpha (mapped or fixed) as a transparentise step.
///
/// @param layer The layer dictionary providing `params.alpha`.
/// @param mapping The resolved aesthetic mapping.
/// @param ctx The plot context exposing `trained`, `resolve-colour`, and `palette`.
/// @param sample-row The row used to read the colour value (group leader or per-row).
/// @param default-colour The colour used when no scale resolution applies.
/// @returns A colour ready to use as a stroke paint.
#let resolve-stroke-colour(layer, mapping, ctx, sample-row, default-colour) = {
  let colour-col = mapping.at("colour", default: none)
  let colour-trained = ctx.trained.at("colour", default: none)
  let resolved = if colour-col != none and colour-trained != none {
    let v = sample-row.at(colour-col, default: none)
    (ctx.resolve-colour)(colour-trained, v, ctx.palette)
  } else { default-colour }
  let alpha = resolve-alpha(layer, mapping, ctx, sample-row)
  apply-alpha(resolved, alpha)
}
