///! Horizontal line from `xmin` to `xmax` with vertical caps at each `y`.

#import "../deps.typ": cetz
#import "../scale/train.typ": map-continuous, map-position
#import "../utils/types.typ": parse-number
#import "../utils/colour-resolve.typ": apply-alpha

/// Horizontal errorbar layer: range with a vertical cap at each end.
///
/// Mapping must provide `y`, `xmin`, `xmax`. The `height` parameter sets the
/// cap span in y data units for continuous y, and as a fraction of the
/// per-category slot height for discrete y.
///
/// @category Geoms
/// @stability stable
/// @since 0.0.1
///
/// @param mapping Layer-specific aesthetic mapping built with @aes. Must map `y`, `xmin`, `xmax`.
/// @param data Layer-specific dataset. Falls back to the plot data when `none`.
/// @param height Cap span. In y data units for continuous y; a fraction of the slot height for discrete y.
/// @param stroke Line thickness (a Typst length).
/// @param colour Fixed line colour. `auto` resolves via the colour scale.
/// @param alpha Line opacity in `[0, 1]`.
/// @param linetype Dash keyword. Defaults to `"solid"`.
/// @param stat Statistical transform name. Usually `"identity"`.
/// @param position Position adjustment name. Usually `"identity"`.
/// @param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// @returns Layer dictionary consumed by @plot.
///
/// @example
/// ```
/// #let d = range(1, 6).map(i => (
///   y: i,
///   lo: i - 0.5,
///   hi: i + 0.5,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(y: "y", xmin: "lo", xmax: "hi"),
///   layers: (geom-errorbarh(height: 0.4),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @geom-errorbar, @geom-linerange, @geom-pointrange
#let geom-errorbarh(
  mapping: none,
  data: none,
  height: 0.4,
  stroke: 0.8pt,
  colour: auto,
  alpha: 1,
  linetype: "solid",
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "errorbarh",
  mapping: mapping,
  data: data,
  params: (
    height: height,
    stroke: stroke,
    colour: colour,
    alpha: alpha,
    linetype: linetype,
  ),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

#let _y-band(y-trained, raw-y, half-height, py-range) = {
  if y-trained.type == "continuous" {
    let raw-num = parse-number(raw-y)
    if raw-num == none { return none }
    (
      map-continuous(raw-num - half-height, y-trained.domain, py-range),
      map-continuous(raw-num + half-height, y-trained.domain, py-range),
    )
  } else {
    let cy = map-position(y-trained, raw-y, py-range)
    if cy == none { return none }
    let n = y-trained.domain.len()
    if n == 0 { return none }
    let (py-lo, py-hi) = py-range
    let slot = (py-hi - py-lo) / n
    let half-px = slot * half-height
    (cy - half-px, cy + half-px)
  }
}

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  let y-col = mapping.at("y", default: none)
  let xmin-col = mapping.at("xmin", default: none)
  let xmax-col = mapping.at("xmax", default: none)
  if y-col == none or xmin-col == none or xmax-col == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let colour-col = mapping.at("colour", default: none)
  let colour-trained = ctx.trained.at("colour", default: none)
  let default-colour = if (
    layer.params.colour != auto and layer.params.colour != none
  ) { layer.params.colour } else { ctx.theme.at("ink", default: black) }

  let half-height = layer.params.height / 2

  for row in data {
    let raw-y = row.at(y-col, default: none)
    let cy = map-position(y-trained, raw-y, ctx.py-range)
    let lo = parse-number(row.at(xmin-col, default: none))
    let hi = parse-number(row.at(xmax-col, default: none))
    if cy == none or lo == none or hi == none { continue }
    let cx-lo = map-position(x-trained, lo, ctx.px-range)
    let cx-hi = map-position(x-trained, hi, ctx.px-range)
    if cx-lo == none or cx-hi == none { continue }

    let band = _y-band(y-trained, raw-y, half-height, ctx.py-range)
    let (cap-lo, cap-hi) = if band == none { (cy, cy) } else { band }

    let colour = if colour-col != none and colour-trained != none {
      (ctx.resolve-colour)(
        colour-trained,
        row.at(colour-col, default: none),
        ctx.palette,
      )
    } else { default-colour }
    let final-colour = apply-alpha(colour, layer.params.alpha)

    let stroke-spec = (
      paint: final-colour,
      thickness: layer.params.stroke,
      dash: layer.params.linetype,
    )

    cetz.draw.line((cx-lo, cy), (cx-hi, cy), stroke: stroke-spec)
    cetz.draw.line((cx-lo, cap-lo), (cx-lo, cap-hi), stroke: stroke-spec)
    cetz.draw.line((cx-hi, cap-lo), (cx-hi, cap-hi), stroke: stroke-spec)
  }
}
