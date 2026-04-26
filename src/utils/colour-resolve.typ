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

/// Resolve a stroke colour for a row sample.
///
/// Looks up the colour-mapped column on `sample-row` and resolves it through
/// the trained colour scale, falling back to `default-colour` when no mapping
/// or no trained scale is available.
/// Applies `layer.params.alpha` as a transparentise step when below 1.
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
  let alpha = layer.params.at("alpha", default: 1)
  apply-alpha(resolved, alpha)
}
