///! Closed polygons from `(x, y)` rows, one polygon per group.

#import "../deps.typ": cetz
#import "../scale/train.typ": map-position
#import "../utils/types.typ": parse-number
#import "../utils/group.typ": partition-by-group
#import "../utils/fill-resolve.typ": resolve-fill-colour

/// Polygon layer: one closed filled polygon per group.
///
/// Rows are connected in input order and the polygon is closed back to
/// the first vertex. Use `group`, `colour`, `fill`, or `linetype` to
/// split rows into separate polygons.
///
/// @category Geoms
/// @stability stable
/// @since 0.0.1
///
/// @param mapping Layer-specific aesthetic mapping built with @aes. Must map `x`, `y`.
/// @param data Layer-specific dataset. Falls back to the plot data when `none`.
/// @param fill Fixed fill colour. `auto` resolves via the fill scale.
/// @param stroke Outline; `none` means no border.
/// @param alpha Fill opacity in `[0, 1]`.
/// @param stat Statistical transform name. Usually `"identity"`.
/// @param position Position adjustment name. Usually `"identity"`.
/// @param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// @returns Layer dictionary consumed by @plot.
///
/// @example
/// ```
/// //| width: 10cm
/// //| height: 6cm
/// #let d = (
///   (x: 0, y: 0, k: "a"),
///   (x: 2, y: 0, k: "a"),
///   (x: 1, y: 2, k: "a"),
///   (x: 3, y: 1, k: "b"),
///   (x: 5, y: 1, k: "b"),
///   (x: 4, y: 3, k: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "k"),
///   layers: (geom-polygon(alpha: 0.5),),
/// )
/// ```
///
/// @see @geom-rect, @geom-area
#let geom-polygon(
  mapping: none,
  data: none,
  fill: auto,
  stroke: none,
  alpha: 0.6,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "polygon",
  mapping: mapping,
  data: data,
  params: (fill: fill, stroke: stroke, alpha: alpha),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none or mapping.x == none or mapping.y == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let neutral-fill = rgb("#4c78a8")

  for g in partition-by-group(data, mapping, trained: ctx.trained) {
    let rows = g.data
    let pts = ()
    for row in rows {
      let cx = map-position(
        x-trained,
        row.at(mapping.x, default: none),
        ctx.px-range,
      )
      let cy = map-position(
        y-trained,
        row.at(mapping.y, default: none),
        ctx.py-range,
      )
      if cx == none or cy == none { continue }
      pts.push((cx, cy))
    }
    if pts.len() < 3 { continue }

    let final-fill = resolve-fill-colour(
      layer,
      mapping,
      ctx,
      rows.first(),
      neutral-fill,
      colour-fallback: false,
    )

    cetz.draw.line(
      ..pts,
      close: true,
      fill: final-fill,
      stroke: if layer.params.stroke == none { none } else {
        layer.params.stroke
      },
    )
  }
}
