#import "colour-resolve.typ": apply-alpha, resolve-alpha
#import "late-binding.typ": apply-after-scale, is-after-scale

/// Resolve a fill colour for a row sample.
///
/// Priority order:
/// 1. Fixed `layer.params.fill` when it is not `auto` and not `none`.
/// 2. The fill scale, when `fill-mapping` is `true`, a fill mapping is set, and the fill scale is trained.
/// 3. `default-fill` otherwise.
///
/// `colour-fallback` is off by default: the `colour` aesthetic drives strokes, not fills, and must be opted into explicitly when a geom truly wants the legacy fallback.
///
/// Applies the per-row alpha (mapped or fixed) via \@apply-alpha as the final step.
///
/// \@internal
/// \@param layer The layer dictionary providing `params.fill` and `params.alpha`.
/// \@param mapping The resolved aesthetic mapping.
/// \@param ctx The plot context exposing `trained`, `resolve-colour`, and `palette`.
/// \@param sample-row The row used to read the fill or colour value.
/// \@param default-fill The colour used when no scale resolution applies.
/// \@param fill-mapping Whether to consult the fill mapping and scale.
/// \@param colour-fallback Whether to fall back to the colour scale when fill is unmapped.
/// \@param default-alpha Fallback opacity passed through to \@resolve-alpha when no pin or mapping applies.
/// \@returns A fill colour with alpha applied.
#let resolve-fill-colour(
  layer,
  mapping,
  ctx,
  sample-row,
  default-fill,
  fill-mapping: true,
  colour-fallback: false,
  default-alpha: 1,
) = {
  let fill-param = layer.params.at("fill", default: auto)
  let fill-spec = if fill-mapping { mapping.at("fill", default: none) } else {
    none
  }
  let resolved = if fill-param != auto and fill-param != none {
    fill-param
  } else if is-after-scale(fill-spec) {
    default-fill
  } else {
    let fill-trained = if fill-mapping {
      ctx.trained.at("fill", default: none)
    } else { none }
    if fill-spec != none and fill-trained != none {
      ((ctx.resolve-colour)(fill-trained, ctx.palette))(
        sample-row.at(fill-spec, default: none),
      )
    } else if colour-fallback {
      let colour-col = mapping.at("colour", default: none)
      let colour-trained = ctx.trained.at("colour", default: none)
      if colour-col != none and colour-trained != none {
        ((ctx.resolve-colour)(colour-trained, ctx.palette))(
          sample-row.at(colour-col, default: none),
        )
      } else { default-fill }
    } else { default-fill }
  }
  resolved = apply-after-scale(resolved, fill-spec, ctx, sample-row)
  let alpha = resolve-alpha(
    layer,
    mapping,
    ctx,
    sample-row,
    default-alpha: default-alpha,
  )
  apply-alpha(resolved, alpha)
}
