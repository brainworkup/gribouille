///! Step function between consecutive observations.
///!
///! Like @geom-line but each segment between two points is drawn as a
///! stair-step: a horizontal then vertical move (`direction: "hv"`,
///! default) or vertical then horizontal (`direction: "vh"`).

#import "../deps.typ": cetz
#import "../scale/train.typ": map-position
#import "../utils/types.typ": parse-number
#import "../utils/palette.typ": default-linetypes
#import "../utils/group.typ": partition-by-group
#import "../utils/colour-resolve.typ": resolve-linewidth, resolve-stroke-colour

/// Step layer connecting observations as a stair-step path, one per group.
///
/// `direction` chooses between `"hv"` (horizontal first, then vertical)
/// and `"vh"` (vertical first, then horizontal).
///
/// @category Geoms
/// @stability stable
/// @since 0.0.1
///
/// @param mapping Layer-specific aesthetic mapping built with @aes. Falls back to the plot mapping when `none`.
/// @param data Layer-specific dataset. Falls back to the plot data when `none`.
/// @param direction Step direction: `"hv"` (default) or `"vh"`.
/// @param stroke Line thickness (a Typst length).
/// @param colour Fixed line colour. `auto` resolves via the colour scale or a neutral default.
/// @param alpha Line opacity in `[0, 1]`.
/// @param linetype Dash keyword (e.g. `"solid"`, `"dashed"`). `auto` honours the linetype scale.
/// @param stat Statistical transform name. Usually `"identity"`.
/// @param position Position adjustment name. Usually `"identity"`.
/// @param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// @returns Layer dictionary consumed by @plot.
///
/// @examples Default `"hv"` step path moving right then up between points.
/// ```
/// #let d = range(0, 7).map(i => (x: i, y: calc.rem(i * 3, 5)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-step(stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @examples `"vh"` direction reverses the corner placement, useful when
/// the change is best read as happening at the previous timestamp.
/// ```
/// #let d = range(0, 7).map(i => (x: i, y: calc.rem(i * 3, 5)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-step(direction: "vh", stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @geom-line, @geom-path
#let geom-step(
  mapping: none,
  data: none,
  direction: "hv",
  stroke: 0.8pt,
  colour: auto,
  alpha: 1,
  linetype: auto,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = {
  if direction != "hv" and direction != "vh" {
    panic("geom-step: direction must be \"hv\" or \"vh\"")
  }
  (
    kind: "layer",
    geom: "step",
    mapping: mapping,
    data: data,
    params: (
      direction: direction,
      stroke: stroke,
      colour: colour,
      alpha: alpha,
      linetype: linetype,
    ),
    stat: stat,
    position: position,
    inherit-aes: inherit-aes,
  )
}

#let _stair(pts, direction) = {
  if pts.len() < 2 { return pts }
  let out = (pts.first(),)
  for i in range(1, pts.len()) {
    let (x0, y0) = pts.at(i - 1)
    let (x1, y1) = pts.at(i)
    if direction == "hv" {
      out.push((x1, y0))
    } else {
      out.push((x0, y1))
    }
    out.push((x1, y1))
  }
  out
}

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none or mapping.x == none or mapping.y == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let default-colour = if (
    layer.params.colour != auto and layer.params.colour != none
  ) { layer.params.colour } else { ctx.theme.at("ink", default: black) }

  let linetype-col = mapping.at("linetype", default: none)
  let linetype-trained = ctx.trained.at("linetype", default: none)
  let linetype-palette = if linetype-trained != none {
    if linetype-trained.at("spec", default: none) != none {
      linetype-trained.spec.at("palette", default: default-linetypes)
    } else { default-linetypes }
  } else { default-linetypes }
  let default-linetype = if (
    layer.params.linetype != auto and layer.params.linetype != none
  ) { layer.params.linetype } else { "solid" }

  for g in partition-by-group(data, mapping, trained: ctx.trained) {
    let rows = g.data
    let with-x = rows
      .map(row => {
        let xv = row.at(mapping.x, default: none)
        let xn = if x-trained.type == "continuous" {
          parse-number(xv)
        } else {
          x-trained.domain.position(v => v == str(xv))
        }
        (row: row, xn: xn)
      })
      .filter(p => p.xn != none)
      .sorted(key: p => p.xn)

    let pts = ()
    for p in with-x {
      let cx = map-position(
        x-trained,
        p.row.at(mapping.x, default: none),
        ctx.px-range,
      )
      let cy = map-position(
        y-trained,
        p.row.at(mapping.y, default: none),
        ctx.py-range,
      )
      if cx == none or cy == none { continue }
      pts.push((cx, cy))
    }
    if pts.len() < 2 { continue }
    let stair = _stair(pts, layer.params.direction)

    let final-colour = resolve-stroke-colour(
      layer,
      mapping,
      ctx,
      rows.first(),
      default-colour,
    )

    let dash = if linetype-col != none and linetype-trained != none {
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
      ..stair,
      stroke: (paint: final-colour, thickness: thickness, dash: dash),
    )
  }
}
