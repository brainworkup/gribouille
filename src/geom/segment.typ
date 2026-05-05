///! Straight line segments from `(x, y)` to `(xend, yend)`.

#import "../deps.typ": cetz
#import "../scale/train.typ": map-position
#import "../utils/types.typ": parse-number
#import "../utils/colour-resolve.typ": resolve-linewidth, resolve-stroke-colour
#import "../utils/polar.typ": polar-point

/// Segment layer: one line from `(x, y)` to `(xend, yend)` per row.
///
/// Mapping must provide `x`, `y`, `xend`, `yend`. Colour and linetype may
/// be mapped or set as fixed layer parameters.
///
/// \@category Geoms
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x`, `y`, `xend`, `yend`.
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
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
/// \@examples Three crossing segments specified by their two endpoints.
/// ```
/// #let d = (
///   (x: 0, y: 0, xend: 4, yend: 3),
///   (x: 0, y: 3, xend: 4, yend: 0),
///   (x: 2, y: 0, xend: 2, yend: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", xend: "xend", yend: "yend"),
///   layers: (geom-segment(stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Map `colour` and `linetype` to colour-coded categorical
/// segments.
/// ```
/// #let d = (
///   (x: 0, y: 0, xend: 4, yend: 3, k: "a"),
///   (x: 0, y: 3, xend: 4, yend: 0, k: "b"),
///   (x: 2, y: 0, xend: 2, yend: 3, k: "a"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", xend: "xend", yend: "yend", colour: "k", linetype: "k"),
///   layers: (geom-segment(stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-line, \@geom-path
#let geom-segment(
  mapping: none,
  data: none,
  stroke: 0.8pt,
  colour: auto,
  alpha: auto,
  linetype: "solid",
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "segment",
  mapping: mapping,
  data: data,
  params: (stroke: stroke, colour: colour, alpha: alpha, linetype: linetype),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

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

  let polar = ctx.at("polar", default: none)
  for row in data {
    let x0 = parse-number(row.at(x-col, default: none))
    let y0 = parse-number(row.at(y-col, default: none))
    let x1 = parse-number(row.at(xend-col, default: none))
    let y1 = parse-number(row.at(yend-col, default: none))
    if x0 == none or y0 == none or x1 == none or y1 == none { continue }
    let (cx0, cy0, cx1, cy1) = if polar != none {
      let p0 = polar-point(x0, y0, polar)
      let p1 = polar-point(x1, y1, polar)
      if p0 == none or p1 == none { continue }
      (p0.at(0), p0.at(1), p1.at(0), p1.at(1))
    } else {
      let a = map-position(x-trained, x0, ctx.px-range)
      let b = map-position(y-trained, y0, ctx.py-range)
      let c = map-position(x-trained, x1, ctx.px-range)
      let d = map-position(y-trained, y1, ctx.py-range)
      if a == none or b == none or c == none or d == none { continue }
      (a, b, c, d)
    }

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
