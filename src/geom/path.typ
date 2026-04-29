///! Polyline preserving row order.
///!
///! Identical to @geom-line except rows are joined in their input order
///! rather than sorted by x. Useful for trajectories, time-series with
///! out-of-order timestamps, and any path where order is meaningful.

#import "../deps.typ": cetz
#import "../scale/train.typ": map-position
#import "../utils/palette.typ": default-linetypes
#import "../utils/group.typ": partition-by-group
#import "../utils/colour-resolve.typ": resolve-linewidth, resolve-stroke-colour

/// Path layer connecting observations in row order, one path per group.
///
/// Grouping is implicit on discrete aesthetics (colour, fill, linetype) or
/// the explicit `group` mapping, just like @geom-line.
///
/// @category Geoms
/// @stability stable
/// @since 0.0.1
///
/// @param mapping Layer-specific aesthetic mapping built with @aes. Falls back to the plot mapping when `none`.
/// @param data Layer-specific dataset. Falls back to the plot data when `none`.
/// @param stroke Line thickness (a Typst length).
/// @param colour Fixed line colour. `auto` resolves via the colour scale or a neutral default.
/// @param alpha Line opacity in `[0, 1]`.
/// @param linetype Dash keyword (e.g. `"solid"`, `"dashed"`). `auto` honours the linetype scale.
/// @param key Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
/// @param stat Statistical transform name. Usually `"identity"`.
/// @param position Position adjustment name. Usually `"identity"`.
/// @param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// @returns Layer dictionary consumed by @plot.
///
/// @examples Connect rows in input order (deliberately not sorted by x).
/// ```
/// #let d = (
///   (x: 1, y: 1), (x: 3, y: 4), (x: 2, y: 2), (x: 4, y: 5),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-path(stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @examples Trajectory of a moving point parameterised by `t`, drawn in
/// time order with a coloured fade.
/// ```
/// #let d = range(0, 24).map(t => (
///   x: calc.cos(t * 0.4), y: calc.sin(t * 0.4) * (t / 24 + 0.5), t: t,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "t"),
///   layers: (geom-path(stroke: 1.2pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @geom-line, @geom-step, @geom-segment
#let geom-path(
  mapping: none,
  data: none,
  stroke: 0.8pt,
  colour: auto,
  alpha: auto,
  linetype: auto,
  key: auto,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "path",
  mapping: mapping,
  data: data,
  params: (stroke: stroke, colour: colour, alpha: alpha, linetype: linetype),
  key: key,
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

  let ink = ctx.theme.at("ink", default: black)

  let linetype-param = layer.params.linetype
  let linetype-pinned = linetype-param != auto and linetype-param != none
  let linetype-col = mapping.at("linetype", default: none)
  let linetype-trained = ctx.trained.at("linetype", default: none)
  let linetype-palette = if linetype-trained != none {
    if linetype-trained.at("spec", default: none) != none {
      linetype-trained.spec.at("palette", default: default-linetypes)
    } else { default-linetypes }
  } else { default-linetypes }
  let default-linetype = if linetype-pinned { linetype-param } else { "solid" }

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
    if pts.len() < 2 { continue }

    let final-colour = resolve-stroke-colour(
      layer,
      mapping,
      ctx,
      rows.first(),
      ink,
    )

    let dash = if linetype-pinned {
      linetype-param
    } else if linetype-col != none and linetype-trained != none {
      let sample = rows.first().at(linetype-col, default: none)
      if linetype-trained.type == "identity" {
        if sample == none or sample == "" { default-linetype } else {
          str(sample)
        }
      } else {
        let idx = linetype-trained.domain.position(v => v == str(sample))
        if idx == none { default-linetype } else {
          linetype-palette.at(calc.rem(idx, linetype-palette.len()))
        }
      }
    } else { default-linetype }

    let thickness = resolve-linewidth(
      layer,
      mapping,
      ctx,
      rows.first(),
      layer.params.stroke,
    )
    cetz.draw.line(
      ..pts,
      stroke: (paint: final-colour, thickness: thickness, dash: dash),
    )
  }
}
