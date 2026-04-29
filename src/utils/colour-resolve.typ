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

/// Resolve a per-row alpha value.
///
/// Priority order:
/// 1. Pinned `layer.params.alpha` when it is not `auto` and not `none`.
/// 2. The trained alpha scale (continuous/discrete/identity), if `mapping.alpha` is set.
/// 3. `default-alpha` otherwise (defaults to `1`, geoms with intrinsic translucency pass their own).
///
/// @param layer The layer dictionary providing `params.alpha`.
/// @param mapping The resolved aesthetic mapping.
/// @param ctx The plot context exposing `trained`.
/// @param sample-row The row used to read the alpha value.
/// @param default-alpha Fallback opacity when no pin or mapping applies.
/// @returns A scalar alpha in `[0, 1]`.
#let resolve-alpha(layer, mapping, ctx, sample-row, default-alpha: 1) = {
  let pinned = layer.params.at("alpha", default: auto)
  if pinned != auto and pinned != none {
    return _clamp(pinned, 0, 1)
  }
  let col = if mapping == none { none } else {
    mapping.at("alpha", default: none)
  }
  let trained = ctx.trained.at("alpha", default: none)
  if col == none or trained == none { return _clamp(default-alpha, 0, 1) }
  let raw = sample-row.at(col, default: none)
  if raw == none { return _clamp(default-alpha, 0, 1) }
  if trained.type == "identity" {
    let v = parse-number(raw)
    if v == none { return _clamp(default-alpha, 0, 1) }
    return _clamp(v, 0, 1)
  }
  let spec = trained.at("spec", default: none)
  let range = if spec != none { spec.at("range", default: (0.1, 1)) } else {
    (0.1, 1)
  }
  if trained.type == "continuous" {
    let v = parse-number(raw)
    if v == none { return _clamp(default-alpha, 0, 1) }
    return _clamp(map-continuous(v, trained.domain, range), 0, 1)
  }
  let s = str(raw)
  let idx = trained.domain.position(v => v == s)
  let n = trained.domain.len()
  if idx == none or n == 0 { return _clamp(default-alpha, 0, 1) }
  let (lo, hi) = range
  if n == 1 { return _clamp((lo + hi) / 2, 0, 1) }
  _clamp(lo + idx * (hi - lo) / (n - 1), 0, 1)
}

/// Resolve a per-row stroke thickness.
///
/// Priority order:
/// 1. Pinned `layer.params.linewidth` when set to a non-`auto`, non-`none` length.
/// 2. The trained linewidth scale, if `mapping.linewidth` is set.
/// 3. `default-thickness` otherwise.
///
/// `default-thickness` is conventionally the layer's `params.stroke` length, so
/// when neither the mapping nor an explicit `linewidth:` pin applies, the
/// layer's configured stroke length is used as the fallback thickness.
///
/// @param layer The layer dictionary providing `params.linewidth`.
/// @param mapping The resolved aesthetic mapping.
/// @param ctx The plot context exposing `trained`.
/// @param sample-row The row used to read the linewidth value.
/// @param default-thickness Fallback thickness when no mapping or pin applies.
/// @returns A Typst length suitable for `stroke.thickness`.
#let resolve-linewidth(layer, mapping, ctx, sample-row, default-thickness) = {
  let pinned-lw = layer.params.at("linewidth", default: auto)
  if pinned-lw != auto and pinned-lw != none and type(pinned-lw) == length {
    return pinned-lw
  }
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

/// Resolve a per-row marker size.
///
/// Priority order:
/// 1. Pinned `layer.params.size` when set to a non-`auto`, non-`none` length.
/// 2. The trained size scale, if `mapping.size` is set.
/// 3. `default-size` otherwise.
///
/// @param layer The layer dictionary providing `params.size`.
/// @param mapping The resolved aesthetic mapping.
/// @param ctx The plot context exposing `trained`.
/// @param sample-row The row used to read the size value.
/// @param default-size Fallback length when no mapping or pin applies.
/// @returns A Typst length suitable for a marker radius.
#let resolve-size(layer, mapping, ctx, sample-row, default-size) = {
  let pinned = layer.params.at("size", default: auto)
  if pinned != auto and pinned != none and type(pinned) == length {
    return pinned
  }
  let col = if mapping == none { none } else {
    mapping.at("size", default: none)
  }
  let trained = ctx.trained.at("size", default: none)
  if col == none or trained == none { return default-size }
  let raw = sample-row.at(col, default: none)
  if raw == none { return default-size }
  if trained.type == "identity" {
    if type(raw) == length { return raw }
    let v = parse-number(raw)
    if v == none { return default-size }
    return v * 1pt
  }
  let spec = trained.at("spec", default: none)
  let range = if spec != none {
    spec.at("range", default: (1pt, 6pt))
  } else {
    (1pt, 6pt)
  }
  let (lo, hi) = range
  if trained.type == "continuous" {
    let v = parse-number(raw)
    if v == none { return default-size }
    let (d-lo, d-hi) = trained.domain
    if d-hi == d-lo { return (lo + hi) / 2 }
    let t = (v - d-lo) / (d-hi - d-lo)
    let t-clamped = if t < 0 { 0 } else if t > 1 { 1 } else { t }
    return lo + t-clamped * (hi - lo)
  }
  let s = str(raw)
  let idx = trained.domain.position(v => v == s)
  let n = trained.domain.len()
  if idx == none or n == 0 { return default-size }
  if n == 1 { return (lo + hi) / 2 }
  lo + idx * (hi - lo) / (n - 1)
}

/// Resolve a stroke colour for a row sample.
///
/// Priority order:
/// 1. Pinned `layer.params.colour` when it is not `auto` and not `none`.
/// 2. The trained colour scale, when `mapping.colour` is set.
/// 3. `default-colour` otherwise.
///
/// Applies the per-row alpha (mapped or pinned) as a transparentise step.
///
/// @param layer The layer dictionary providing `params.colour`/`params.alpha`.
/// @param mapping The resolved aesthetic mapping.
/// @param ctx The plot context exposing `trained`, `resolve-colour`, and `palette`.
/// @param sample-row The row used to read the colour value (group leader or per-row).
/// @param default-colour The colour used when no scale resolution applies.
/// @returns A colour ready to use as a stroke paint.
#let resolve-stroke-colour(layer, mapping, ctx, sample-row, default-colour) = {
  let colour-param = layer.params.at("colour", default: auto)
  let resolved = if colour-param != auto and colour-param != none {
    colour-param
  } else {
    let colour-col = mapping.at("colour", default: none)
    let colour-trained = ctx.trained.at("colour", default: none)
    if colour-col != none and colour-trained != none {
      let v = sample-row.at(colour-col, default: none)
      (ctx.resolve-colour)(colour-trained, v, ctx.palette)
    } else { default-colour }
  }
  let alpha = resolve-alpha(layer, mapping, ctx, sample-row)
  apply-alpha(resolved, alpha)
}
