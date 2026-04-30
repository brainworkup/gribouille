///! Hollow box from `ymin` to `ymax` with a thicker bar at `y` (the median).

#import "../deps.typ": cetz
#import "../scale/train.typ": map-position
#import "../utils/band.typ": x-band
#import "../utils/types.typ": parse-number
#import "../utils/colour-resolve.typ": resolve-stroke-colour
#import "../utils/fill-resolve.typ": resolve-fill-colour
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/stroke.typ": build-stroke

/// Crossbar layer: a box from `ymin` to `ymax` with a horizontal bar at `y`.
///
/// Mapping must provide `x`, `y`, `ymin`, `ymax`. The `width` parameter sets
/// the box width in x data units for continuous x, and as a fraction of the
/// per-category slot width for discrete x.
///
/// \@category Geoms
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x`, `y`, `ymin`, `ymax`.
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
/// \@param width Box width. In x data units for continuous x; a fraction of the slot width for discrete x.
/// \@param colour Stroke colour for the box and the median bar. `auto` falls back to the theme ink only when neither `colour` nor `fill` is set.
/// \@param fill Box fill colour. `auto` resolves via the fill scale or a neutral default.
/// \@param stroke Stroke thickness for the box outline.
/// \@param middle-stroke Stroke thickness for the median bar.
/// \@param alpha Box opacity in `[0, 1]`.
/// \@param stat Statistical transform name. Usually `"identity"`.
/// \@param position Position adjustment name. Usually `"identity"`.
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Box from `lo` to `hi` with the median bar at `y`.
/// ```
/// #let d = range(1, 5).map(i => (
///   x: i,
///   y: i,
///   lo: i - 0.6,
///   hi: i + 0.6,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", ymin: "lo", ymax: "hi"),
///   layers: (geom-crossbar(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Map `fill` to a categorical column to colour the box per group.
/// ```
/// #let d = range(1, 5).map(i => (
///   x: i, y: i, lo: i - 0.6, hi: i + 0.6,
///   k: if calc.rem(i, 2) == 0 { "even" } else { "odd" },
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", ymin: "lo", ymax: "hi", fill: "k"),
///   layers: (geom-crossbar(alpha: 0.6),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-errorbar, \@geom-pointrange, \@geom-boxplot
#let geom-crossbar(
  mapping: none,
  data: none,
  width: 0.6,
  colour: auto,
  fill: auto,
  stroke: 0.6pt,
  middle-stroke: 1.2pt,
  alpha: auto,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "crossbar",
  mapping: mapping,
  data: data,
  params: (
    width: width,
    colour: colour,
    fill: fill,
    stroke: stroke,
    middle-stroke: middle-stroke,
    alpha: alpha,
  ),
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
  let ymin-col = mapping.at("ymin", default: none)
  let ymax-col = mapping.at("ymax", default: none)
  if (
    x-col == none or y-col == none or ymin-col == none or ymax-col == none
  ) { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let neutral-fill = rgb("#cccccc")
  let ink = ctx.theme.at("ink", default: black)
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    ink,
    neutral-fill,
  )

  let half-width = layer.params.width / 2

  for row in data {
    let raw-x = row.at(x-col, default: none)
    let cx = map-position(x-trained, raw-x, ctx.px-range)
    let mid = parse-number(row.at(y-col, default: none))
    let lo = parse-number(row.at(ymin-col, default: none))
    let hi = parse-number(row.at(ymax-col, default: none))
    if cx == none or mid == none or lo == none or hi == none { continue }
    let cy-mid = map-position(y-trained, mid, ctx.py-range)
    let cy-lo = map-position(y-trained, lo, ctx.py-range)
    let cy-hi = map-position(y-trained, hi, ctx.py-range)
    if cy-mid == none or cy-lo == none or cy-hi == none { continue }

    let band = x-band(x-trained, raw-x, half-width, ctx.px-range)
    let (cx-lo, cx-hi) = if band == none { (cx, cx) } else { band }

    let final-fill = resolve-fill-colour(
      layer,
      mapping,
      ctx,
      row,
      default-fill,
    )
    let resolved-stroke = resolve-stroke-colour(
      layer,
      mapping,
      ctx,
      row,
      default-colour,
    )
    let stroke-spec = build-stroke(layer.params.stroke, resolved-stroke)
    let middle-stroke-spec = build-stroke(
      layer.params.middle-stroke,
      resolved-stroke,
    )

    cetz.draw.rect(
      (cx-lo, cy-lo),
      (cx-hi, cy-hi),
      fill: final-fill,
      stroke: stroke-spec,
    )
    cetz.draw.line(
      (cx-lo, cy-mid),
      (cx-hi, cy-mid),
      stroke: middle-stroke-spec,
    )
  }
}
