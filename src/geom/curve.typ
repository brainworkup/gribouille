///! Curved segments from `(x, y)` to `(xend, yend)`.
///!
///! Quadratic-bezier counterpart of \@geom-segment. The control point sits
///! perpendicular to the chord at a position controlled by `curvature` and
///! `angle`, then the curve is sampled into a polyline drawn through the
///! same draw chain.

#import "../deps.typ": cetz
#import "../scale/train.typ": map-position
#import "../utils/types.typ": parse-number
#import "../utils/colour-resolve.typ": resolve-linewidth, resolve-stroke-colour

/// Curved segment layer: one quadratic bezier from `(x, y)` to `(xend, yend)` per row.
///
/// `curvature` chooses the magnitude and side of the bow:
/// - `0` collapses to a straight `geom-segment`.
/// - Positive values curve to the right of the chord (looking from start to end).
/// - Negative values curve to the left.
///
/// `angle` shifts the control point along the chord (in addition to the
/// perpendicular offset), producing asymmetric arcs. `90deg` gives a
/// symmetric bow; smaller or larger angles bias the apex toward one end.
///
/// \@category Geoms
/// \@stability stable
/// \@since 0.4.0
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x`, `y`, `xend`, `yend`.
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
/// \@param curvature Bezier-control offset as a fraction of the chord length. `0` draws a straight segment; sign flips the side of the bow.
/// \@param angle Apex angle in `(0deg, 180deg)`. `90deg` is symmetric.
/// \@param n Number of polyline samples along the curve.
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
/// \@examples Three curved connectors with the default symmetric bow.
/// ```
/// #let d = (
///   (x: 0, y: 0, xend: 4, yend: 3, k: "a"),
///   (x: 0, y: 3, xend: 4, yend: 0, k: "b"),
///   (x: 2, y: 0, xend: 2, yend: 3, k: "a"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", xend: "xend", yend: "yend", colour: "k"),
///   layers: (geom-curve(curvature: 0.5, stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Negative `curvature` flips the arc to the other side.
/// ```
/// #let d = ((x: 0, y: 0, xend: 4, yend: 3),)
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", xend: "xend", yend: "yend"),
///   layers: (geom-curve(curvature: -0.5, stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-segment, \@geom-line
#let geom-curve(
  mapping: none,
  data: none,
  curvature: 0.5,
  angle: 90deg,
  n: 32,
  stroke: 0.8pt,
  colour: auto,
  alpha: auto,
  linetype: "solid",
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "curve",
  mapping: mapping,
  data: data,
  params: (
    curvature: curvature,
    angle: angle,
    n: n,
    stroke: stroke,
    colour: colour,
    alpha: alpha,
    linetype: linetype,
  ),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

// Quadratic-bezier samples between (cx0, cy0) and (cx1, cy1). The control
// point sits perpendicular to the chord at a distance proportional to
// `curvature * chord-length`. `angle` shifts the apex along the chord;
// 90deg places it at the midpoint.
#let _curve-points(cx0, cy0, cx1, cy1, curvature, angle, n) = {
  let dx = cx1 - cx0
  let dy = cy1 - cy0
  let length = calc.sqrt(dx * dx + dy * dy)
  if length == 0 { return ((cx0, cy0),) }
  let t-mid = calc.cos(angle) * 0.5 + 0.5
  let mx = cx0 + t-mid * dx
  let my = cy0 + t-mid * dy
  let perp-x = -dy / length
  let perp-y = dx / length
  let offset = curvature * length
  let cx = mx + offset * perp-x
  let cy = my + offset * perp-y
  range(0, n + 1).map(i => {
    let t = i / n
    let u = 1 - t
    let bx = u * u * cx0 + 2 * u * t * cx + t * t * cx1
    let by = u * u * cy0 + 2 * u * t * cy + t * t * cy1
    (bx, by)
  })
}

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  let xend-col = mapping.at("xend", default: none)
  let yend-col = mapping.at("yend", default: none)
  if x-col == none or y-col == none or xend-col == none or yend-col == none {
    return
  }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let ink = ctx.theme.at("ink", default: black)
  let curvature = layer.params.curvature
  let angle = layer.params.angle
  let n = layer.params.n

  for row in data {
    let x0 = parse-number(row.at(x-col, default: none))
    let y0 = parse-number(row.at(y-col, default: none))
    let x1 = parse-number(row.at(xend-col, default: none))
    let y1 = parse-number(row.at(yend-col, default: none))
    if x0 == none or y0 == none or x1 == none or y1 == none { continue }
    let cx0 = map-position(x-trained, x0, ctx.px-range)
    let cy0 = map-position(y-trained, y0, ctx.py-range)
    let cx1 = map-position(x-trained, x1, ctx.px-range)
    let cy1 = map-position(y-trained, y1, ctx.py-range)
    if cx0 == none or cy0 == none or cx1 == none or cy1 == none { continue }

    let pts = _curve-points(cx0, cy0, cx1, cy1, curvature, angle, n)
    if pts.len() < 2 { continue }

    let final-colour = resolve-stroke-colour(layer, mapping, ctx, row, ink)
    let thickness = resolve-linewidth(
      layer,
      mapping,
      ctx,
      row,
      layer.params.stroke,
    )
    cetz.draw.line(
      ..pts,
      stroke: (
        paint: final-colour,
        thickness: thickness,
        dash: layer.params.linetype,
      ),
    )
  }
}
