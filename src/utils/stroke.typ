#import "colour-resolve.typ": resolve-stroke-colour, resolve-stroke-width

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
/// \@returns A CeTZ stroke dictionary or `none`.
#let resolve-stroke-spec(layer, mapping, ctx, sample-row, default-colour) = {
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
  // (mapping or default 0.5pt). Pinned lengths and dictionaries pass through
  // build-stroke unchanged.
  let resolved-param = if stroke-param == auto {
    resolve-stroke-width(layer, mapping, ctx, sample-row, 0.5pt)
  } else { stroke-param }
  build-stroke(resolved-param, paint)
}
