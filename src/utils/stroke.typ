#import "colour-resolve.typ": resolve-stroke-colour, resolve-stroke-width
#import "../theme/theme.typ": (
  default-stroke-thickness, geom-default, geom-defaults,
)

/// Build a CeTZ stroke dictionary by injecting `paint` into a thickness-only stroke spec, or returns `none` when the layer disabled the stroke.
///
/// Accepts the layer's `stroke` parameter in any of three forms:
/// - `none` or `0pt`: no stroke is drawn, returns `none`.
/// - a `length`: wraps it into `(paint: stroke-paint, thickness: stroke-param)`.
/// - a dictionary: returns it as is, only filling in `paint` if absent.
///
/// \@internal
/// \@param stroke-param The layer's `params.stroke` value.
/// \@param stroke-paint The resolved stroke colour.
/// \@returns A CeTZ stroke dictionary or `none`.
/// Resolve `layer.params.stroke` to a concrete length when the constructor
/// left it `auto`, consulting `theme.geom.linewidth` first and falling back
/// to the per-geom default.
///
/// Returns the layer's pinned value (length, `none`, or stroke dict) unchanged
/// when not `auto`, so user overrides always win.
///
/// \@internal
/// \@param layer The layer providing `params.stroke`.
/// \@param ctx The plot context exposing `theme`.
/// \@param fallback Per-geom default thickness used when the theme also
///   leaves `element-geom.linewidth` unset.
/// \@returns A length, `none`, or stroke dict.
#let resolve-pinned-stroke(layer, ctx, fallback) = {
  let s = layer.params.stroke
  if s != auto { return s }
  // Wrapper layers (e.g. `geom-contour`/`geom-quantile` dispatching via
  // `geom: "path"`/`"line"`) override the host geom's visual default by
  // setting `params.stroke-fallback`.
  let effective-fallback = layer.params.at(
    "stroke-fallback",
    default: fallback,
  )
  geom-default(geom-defaults(ctx.theme), "linewidth", effective-fallback)
}

#let build-stroke(stroke-param, stroke-paint) = {
  if stroke-param == none { return none }
  if stroke-paint == none { return none }
  if type(stroke-param) == length {
    if stroke-param == 0pt { return none }
    return (paint: stroke-paint, thickness: stroke-param)
  }
  if type(stroke-param) == dictionary {
    let merged = stroke-param
    if merged.at("paint", default: none) == none {
      merged.insert("paint", stroke-paint)
    }
    return merged
  }
  stroke-param
}

/// Resolve the per-row stroke spec for a dual-aesthetic geom in one step: looks up `layer.params.stroke`, resolves the stroke paint via the colour scale, and wraps the pair via \@build-stroke.
///
/// Returns `none` when the layer disabled the stroke (`params.stroke == none`) or when `default-colour` is `none` (the exclusive-default rule suppressed the stroke because only `fill` is set).
///
/// \@internal
/// \@param layer The layer dictionary providing `params.stroke` and `params.colour`.
/// \@param mapping The resolved aesthetic mapping.
/// \@param ctx The plot context exposing `trained`, `resolve-colour`, and `palette`.
/// \@param sample-row The row used to read the colour value.
/// \@param default-colour The colour used when no scale resolution applies, or `none` to suppress the stroke entirely.
/// \@param default-thickness Fallback stroke thickness when `params.stroke == auto` and no `linewidth` mapping resolves; defaults to \@default-stroke-thickness.
/// \@returns A CeTZ stroke dictionary or `none`.
#let resolve-stroke-spec(
  layer,
  mapping,
  ctx,
  sample-row,
  default-colour,
  default-thickness: default-stroke-thickness,
) = {
  let stroke-param = layer.params.stroke
  if stroke-param == none { return none }
  let paint = resolve-stroke-colour(
    layer,
    mapping,
    ctx,
    sample-row,
    default-colour,
  )
  // When `stroke:` is `auto`, resolve the thickness via the stroke aesthetic
  // (mapping or `default-thickness`). Pinned lengths and dictionaries pass
  // through build-stroke unchanged.
  let resolved-param = if stroke-param == auto {
    resolve-stroke-width(layer, mapping, ctx, sample-row, default-thickness)
  } else { stroke-param }
  build-stroke(resolved-param, paint)
}
