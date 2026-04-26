///! Filled area between the x axis and y.
///!
///! Equivalent to a ribbon with `ymin = 0`. Rows are sorted by x within
///! each group and the polygon closes back along `y = 0`.

#import "../deps.typ": cetz
#import "../scale/train.typ": map-position
#import "../utils/types.typ": parse-number
#import "../utils/group.typ": partition-by-group
#import "../utils/fill-resolve.typ": resolve-fill-colour

/// Area layer: filled polygon from `y = 0` up to `y` along x, per group.
///
/// Mapping must provide `x` and `y`. Discrete colour, fill, or `group`
/// mappings split rows into separate filled polygons drawn back to front.
///
/// @category Geoms
/// @stability stable
/// @since 0.0.1
///
/// @param mapping Layer-specific aesthetic mapping built with @aes. Falls back to the plot mapping when `none`.
/// @param data Layer-specific dataset. Falls back to the plot data when `none`.
/// @param fill Fixed fill colour. `auto` resolves via the fill scale, the colour scale, or a neutral default.
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
/// #let d = range(0, 12).map(i => (x: i, y: calc.sin(i * 0.6) + 1.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-area(alpha: 0.4),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @geom-ribbon, @geom-line
#let geom-area(
  mapping: none,
  data: none,
  fill: auto,
  stroke: none,
  alpha: 0.4,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "area",
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
  if y-trained.type != "continuous" { return }

  let baseline = map-position(y-trained, 0, ctx.py-range)
  if baseline == none { return }

  let neutral-fill = rgb("#4c78a8")

  for g in partition-by-group(data, mapping, trained: ctx.trained) {
    let rows = g.data
    let sorted = rows
      .map(row => (
        x: parse-number(row.at(mapping.x, default: none)),
        y: parse-number(row.at(mapping.y, default: none)),
        row: row,
      ))
      .filter(p => p.x != none and p.y != none)
      .sorted(key: p => p.x)
    if sorted.len() < 2 { continue }

    let upper = sorted.map(p => (
      map-position(x-trained, p.x, ctx.px-range),
      map-position(y-trained, p.y, ctx.py-range),
    ))
    let lower = sorted
      .rev()
      .map(p => (map-position(x-trained, p.x, ctx.px-range), baseline))
    let pts = upper + lower
    if pts.any(p => p.at(0) == none or p.at(1) == none) { continue }

    let final-fill = resolve-fill-colour(
      layer,
      mapping,
      ctx,
      rows.first(),
      neutral-fill,
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
