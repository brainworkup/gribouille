///! Vertical line from `ymin` to `ymax` with horizontal caps at each `x`.

#import "../deps.typ": cetz
#import "../utils/aes-resolve.typ": resolve-channel
#import "../scale/train.typ": map-position
#import "../utils/band.typ": x-band
#import "../utils/radial.typ": (
  RADIAL-DEFAULT-CAP-HALF, project-point, radial-tangent-cap,
)
#import "../utils/types.typ": parse-number
#import "../utils/colour-resolve.typ": apply-alpha

/// Errorbar layer: vertical range with a horizontal cap at each end.
///
/// Mapping must provide `x`, `ymin`, `ymax`. The `width` parameter sets the
/// cap span in x data units for continuous x, and as a fraction of the
/// per-category slot width for discrete x.
///
/// \@category Geoms
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x`, `ymin`, `ymax`.
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
/// \@param width Cap span. A Typst length sets the cap span directly in panel units; a number is interpreted as x data units for continuous x and a fraction of the slot width for discrete x.
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
/// \@examples Vertical error bars with default cap span.
/// ```
/// #let d = range(1, 6).map(i => (
///   x: i,
///   lo: i - 0.5,
///   hi: i + 0.5,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", ymin: "lo", ymax: "hi"),
///   layers: (geom-errorbar(width: 0.4),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Combine with \@geom-point at the central estimate to convey the
/// uncertainty around it.
/// ```
/// #let d = range(1, 6).map(i => (
///   x: i, y: i, lo: i - 0.5, hi: i + 0.5,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", ymin: "lo", ymax: "hi"),
///   layers: (
///     geom-errorbar(width: 0.3),
///     geom-point(size: 3pt),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-linerange, \@geom-pointrange, \@geom-crossbar
#let geom-errorbar(
  mapping: none,
  data: none,
  width: 0.4,
  stroke: 0.8pt,
  colour: auto,
  alpha: auto,
  linetype: "solid",
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "errorbar",
  mapping: mapping,
  data: data,
  params: (
    width: width,
    stroke: stroke,
    colour: colour,
    alpha: alpha,
    linetype: linetype,
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
  let ymin-col = mapping.at("ymin", default: none)
  let ymax-col = mapping.at("ymax", default: none)
  if x-col == none or ymin-col == none or ymax-col == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let colour-pinned = (
    layer.params.colour != auto and layer.params.colour != none
  )
  let colour-col = mapping.at("colour", default: none)
  let colour-trained = ctx.trained.at("colour", default: none)
  let resolve-colour = if colour-trained != none {
    (ctx.resolve-colour)(colour-trained, ctx.palette)
  } else { none }
  let ink = ctx.theme.at("ink", default: black)

  // `width` accepts a Typst length (cap span in panel units) or a number (cap
  // span in x data units for continuous x, fraction of slot for discrete x).
  let width-is-length = type(layer.params.width) == length
  let half-width = if width-is-length {
    (layer.params.width / 1cm) / 2
  } else { layer.params.width / 2 }

  for row in data {
    let raw-x = row.at(x-col, default: none)
    let cx = map-position(x-trained, raw-x, ctx.px-range)
    let lo = parse-number(row.at(ymin-col, default: none))
    let hi = parse-number(row.at(ymax-col, default: none))
    if cx == none or lo == none or hi == none { continue }
    let cy-lo = map-position(y-trained, lo, ctx.py-range)
    let cy-hi = map-position(y-trained, hi, ctx.py-range)
    if cy-lo == none or cy-hi == none { continue }

    let (cap-lo, cap-hi) = if width-is-length {
      (cx - half-width, cx + half-width)
    } else {
      let band = x-band(x-trained, raw-x, half-width, ctx.px-range)
      if band == none { (cx, cx) } else { band }
    }

    let colour = if colour-pinned {
      layer.params.colour
    } else if colour-col != none and resolve-colour != none {
      resolve-colour(row.at(colour-col, default: none))
    } else { ink }
    let alpha = resolve-channel("alpha", layer, mapping, ctx, row, 1)
    let final-colour = apply-alpha(colour, alpha)
    let thickness = resolve-channel(
      "linewidth",
      layer,
      mapping,
      ctx,
      row,
      layer.params.stroke,
    )

    let stroke-spec = (
      paint: final-colour,
      thickness: thickness,
      dash: layer.params.linetype,
    )

    if ctx.at("radial", default: none) != none {
      // Polar caps would ideally be arcs at constant r, but a tangent
      // chord reads similarly at typical cap widths.
      let p-lo = project-point(ctx, raw-x, lo)
      let p-hi = project-point(ctx, raw-x, hi)
      if p-lo == none or p-hi == none { continue }
      let (sx-lo, sy-lo) = p-lo
      let (sx-hi, sy-hi) = p-hi
      cetz.draw.line((sx-lo, sy-lo), (sx-hi, sy-hi), stroke: stroke-spec)
      let cap = radial-tangent-cap(
        p-lo,
        p-hi,
        if width-is-length { half-width } else { RADIAL-DEFAULT-CAP-HALF },
      )
      if cap == none { continue }
      let (nx, ny) = cap
      cetz.draw.line(
        (sx-lo - nx, sy-lo - ny),
        (sx-lo + nx, sy-lo + ny),
        stroke: stroke-spec,
      )
      cetz.draw.line(
        (sx-hi - nx, sy-hi - ny),
        (sx-hi + nx, sy-hi + ny),
        stroke: stroke-spec,
      )
      continue
    }

    cetz.draw.line((cx, cy-lo), (cx, cy-hi), stroke: stroke-spec)
    cetz.draw.line((cap-lo, cy-lo), (cap-hi, cy-lo), stroke: stroke-spec)
    cetz.draw.line((cap-lo, cy-hi), (cap-hi, cy-hi), stroke: stroke-spec)
  }
}
