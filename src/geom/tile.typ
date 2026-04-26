///! Centred tiles at `(x, y)` with optional `width` and `height`.
///!
///! Mapping provides `x` and `y`; `width` and `height` may be mapped or fixed.

#import "../deps.typ": cetz
#import "../scale/train.typ": map-position
#import "../utils/types.typ": parse-number
#import "../utils/fill-resolve.typ": resolve-fill-colour

/// Tile layer: filled rectangle centred at `(x, y)` per row.
///
/// `width` and `height` default to 1 in data units; both may be mapped
/// via @aes or fixed via the layer parameters.
///
/// @category Geoms
/// @stability stable
/// @since 0.0.1
///
/// @param mapping Layer-specific aesthetic mapping built with @aes. Must map `x`, `y`.
/// @param data Layer-specific dataset. Falls back to the plot data when `none`.
/// @param width Default tile width in data units when not mapped.
/// @param height Default tile height in data units when not mapped.
/// @param fill Fixed fill colour. `auto` resolves via the fill scale or a neutral default.
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
/// #let d = ()
/// #for x in range(0, 5) {
///   for y in range(0, 4) {
///     d.push((x: x, y: y, v: x + y))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "v"),
///   layers: (geom-tile(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @geom-rect, @geom-raster
#let geom-tile(
  mapping: none,
  data: none,
  width: 1,
  height: 1,
  fill: auto,
  stroke: none,
  alpha: 1,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "tile",
  mapping: mapping,
  data: data,
  params: (
    width: width,
    height: height,
    fill: fill,
    stroke: stroke,
    alpha: alpha,
  ),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

/// Raster: shorthand for @geom-tile assuming a regular grid.
///
/// In gribouille both functions render the same way; `geom-raster` is
/// kept as a familiar synonym.
///
/// @category Geoms
/// @stability stable
/// @since 0.0.1
///
/// @param args Forwarded verbatim to @geom-tile.
///
/// @returns Layer dictionary consumed by @plot.
///
/// @see @geom-tile
#let geom-raster(..args) = geom-tile(..args)

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if (
    x-trained == none
      or y-trained == none
      or x-trained.type != "continuous"
      or y-trained.type != "continuous"
  ) { return }

  let width-col = mapping.at("width", default: none)
  let height-col = mapping.at("height", default: none)
  let neutral-fill = rgb("#4c78a8")

  for row in data {
    let x = parse-number(row.at(x-col, default: none))
    let y = parse-number(row.at(y-col, default: none))
    if x == none or y == none { continue }
    let w = if width-col != none {
      parse-number(row.at(width-col, default: none))
    } else { layer.params.width }
    let h = if height-col != none {
      parse-number(row.at(height-col, default: none))
    } else { layer.params.height }
    if w == none or h == none { continue }
    let cx0 = map-position(x-trained, x - w / 2, ctx.px-range)
    let cx1 = map-position(x-trained, x + w / 2, ctx.px-range)
    let cy0 = map-position(y-trained, y - h / 2, ctx.py-range)
    let cy1 = map-position(y-trained, y + h / 2, ctx.py-range)
    if cx0 == none or cx1 == none or cy0 == none or cy1 == none { continue }

    let final-fill = resolve-fill-colour(
      layer,
      mapping,
      ctx,
      row,
      neutral-fill,
      colour-fallback: false,
    )

    cetz.draw.rect(
      (cx0, cy0),
      (cx1, cy1),
      fill: final-fill,
      stroke: if layer.params.stroke == none { none } else {
        layer.params.stroke
      },
    )
  }
}
