///! Directed segments from `(x, y)` along a per-row `(angle, radius)`.
///!
///! Polar counterpart of \@geom-segment. Each row's `(angle, radius)` gives
///! the offset to the segment endpoint via `xend = x + radius * cos(angle)`
///! and `yend = y + radius * sin(angle)`.

#import "../deps.typ": cetz
#import "../scale/train.typ": map-position
#import "../utils/types.typ": parse-number
#import "../utils/colour-resolve.typ": resolve-linewidth, resolve-stroke-colour

/// Spoke layer: one segment from `(x, y)` along `(angle, radius)` per row.
///
/// `angle` is a Typst angle (e.g. `45deg`) when supplied as a layer
/// parameter; mapped values are read as numbers in radians from the data.
/// `radius` is the segment length in data units.
///
/// \@category Geoms
/// \@stability stable
/// \@since 0.4.0
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x`, `y`. `angle` and `radius` may be mapped or left to the layer-level fallbacks.
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
/// \@param angle Layer-level direction (a Typst angle, e.g. `45deg`) used when `aes(angle: ...)` is not mapped.
/// \@param radius Layer-level length in data units used when `aes(radius: ...)` is not mapped.
/// \@param stroke Line thickness (a Typst length).
/// \@param colour Fixed line colour. `auto` resolves via the colour scale.
/// \@param alpha Line opacity in `[0, 1]`.
/// \@param linetype Dash keyword. Defaults to `"solid"`.
/// \@param stat Statistical transform name. Usually `"identity"`.
/// \@param position Position adjustment name. Usually `"identity"`.
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Eight unit-length spokes radiating from the origin at evenly
/// spaced angles.
/// ```
/// #let d = range(0, 8).map(i => (
///   x: 0, y: 0, angle: i * calc.pi / 4, r: 1,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", angle: "angle", radius: "r"),
///   layers: (geom-spoke(stroke: 1pt),),
///   width: 8cm,
///   height: 8cm,
/// )
/// ```
///
/// \@see \@geom-segment, \@geom-curve
#let geom-spoke(
  mapping: none,
  data: none,
  angle: 0deg,
  radius: 1,
  stroke: 0.8pt,
  colour: auto,
  alpha: auto,
  linetype: "solid",
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "spoke",
  mapping: mapping,
  data: data,
  params: (
    angle: angle,
    radius: radius,
    stroke: stroke,
    colour: colour,
    alpha: alpha,
    linetype: linetype,
  ),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

#let _row-angle(row, col, fallback) = {
  if col == none {
    if type(fallback) == angle { return fallback }
    return fallback * 1rad
  }
  let raw = row.at(col, default: none)
  let v = parse-number(raw)
  if v == none {
    if type(fallback) == angle { return fallback }
    return fallback * 1rad
  }
  v * 1rad
}

#let _row-radius(row, col, fallback) = {
  if col == none { return fallback }
  let v = parse-number(row.at(col, default: none))
  if v == none { fallback } else { v }
}

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let angle-col = mapping.at("angle", default: none)
  let radius-col = mapping.at("radius", default: none)
  let angle-fallback = layer.params.angle
  let radius-fallback = layer.params.radius

  let ink = ctx.theme.at("ink", default: black)

  for row in data {
    let x0 = parse-number(row.at(x-col, default: none))
    let y0 = parse-number(row.at(y-col, default: none))
    if x0 == none or y0 == none { continue }
    let theta = _row-angle(row, angle-col, angle-fallback)
    let r = _row-radius(row, radius-col, radius-fallback)
    let x1 = x0 + r * calc.cos(theta)
    let y1 = y0 + r * calc.sin(theta)
    let cx0 = map-position(x-trained, x0, ctx.px-range)
    let cy0 = map-position(y-trained, y0, ctx.py-range)
    let cx1 = map-position(x-trained, x1, ctx.px-range)
    let cy1 = map-position(y-trained, y1, ctx.py-range)
    if cx0 == none or cy0 == none or cx1 == none or cy1 == none { continue }

    let final-colour = resolve-stroke-colour(layer, mapping, ctx, row, ink)
    let thickness = resolve-linewidth(
      layer,
      mapping,
      ctx,
      row,
      layer.params.stroke,
    )
    cetz.draw.line(
      (cx0, cy0),
      (cx1, cy1),
      stroke: (
        paint: final-colour,
        thickness: thickness,
        dash: layer.params.linetype,
      ),
    )
  }
}
