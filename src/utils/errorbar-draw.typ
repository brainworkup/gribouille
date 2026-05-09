// Shared draw path for `geom-errorbar` and `geom-errorbarh`.
//
// `axis` selects which axis the bar's length spans:
//   "y" → vertical bar (errorbar): centre column = x, span columns = ymin/ymax
//   "x" → horizontal bar (errorbarh): centre column = y, span columns = xmin/xmax
// `cap-extent` is the user's `width:` (errorbar) or `height:` (errorbarh):
// either a Typst length (cap span in panel units) or a number (data units for
// continuous centre axis, fraction of slot for discrete).

#import "../deps.typ": cetz
#import "../utils/aes-resolve.typ": resolve-channel
#import "../scale/train.typ": map-position
#import "../utils/band.typ": axis-band
#import "../utils/radial.typ": (
  RADIAL-DEFAULT-CAP-HALF, project-point, radial-tangent-cap,
)
#import "../utils/types.typ": parse-number
#import "../utils/colour-resolve.typ": apply-alpha

#let _draw-errorbar-axis(layer, ctx, axis, cap-extent) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  let centre-axis = if axis == "y" { "x" } else { "y" }
  let centre-col = mapping.at(centre-axis, default: none)
  let span-min-col = mapping.at(axis + "min", default: none)
  let span-max-col = mapping.at(axis + "max", default: none)
  if centre-col == none or span-min-col == none or span-max-col == none {
    return
  }
  let centre-trained = ctx.trained.at(centre-axis, default: none)
  let span-trained = ctx.trained.at(axis, default: none)
  if centre-trained == none or span-trained == none { return }

  let colour-pinned = (
    layer.params.colour != auto and layer.params.colour != none
  )
  let colour-col = mapping.at("colour", default: none)
  let colour-trained = ctx.trained.at("colour", default: none)
  let resolve-colour = if colour-trained != none {
    (ctx.resolve-colour)(colour-trained, ctx.palette)
  } else { none }
  let ink = ctx.theme.at("ink", default: black)

  let extent-is-length = type(cap-extent) == length
  let half = if extent-is-length {
    (cap-extent / 1cm) / 2
  } else { cap-extent / 2 }

  let centre-range = if centre-axis == "x" { ctx.px-range } else {
    ctx.py-range
  }
  let span-range = if axis == "y" { ctx.py-range } else { ctx.px-range }

  for row in data {
    let raw-centre = row.at(centre-col, default: none)
    let centre-c = map-position(centre-trained, raw-centre, centre-range)
    let lo = parse-number(row.at(span-min-col, default: none))
    let hi = parse-number(row.at(span-max-col, default: none))
    if centre-c == none or lo == none or hi == none { continue }
    let span-lo = map-position(span-trained, lo, span-range)
    let span-hi = map-position(span-trained, hi, span-range)
    if span-lo == none or span-hi == none { continue }

    let (cap-lo, cap-hi) = if extent-is-length {
      (centre-c - half, centre-c + half)
    } else {
      let band = axis-band(centre-trained, raw-centre, half, centre-range)
      if band == none { (centre-c, centre-c) } else { band }
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
      let p-lo = if axis == "y" {
        project-point(ctx, raw-centre, lo)
      } else {
        project-point(ctx, lo, raw-centre)
      }
      let p-hi = if axis == "y" {
        project-point(ctx, raw-centre, hi)
      } else {
        project-point(ctx, hi, raw-centre)
      }
      if p-lo == none or p-hi == none { continue }
      let (sx-lo, sy-lo) = p-lo
      let (sx-hi, sy-hi) = p-hi
      cetz.draw.line((sx-lo, sy-lo), (sx-hi, sy-hi), stroke: stroke-spec)
      let cap = radial-tangent-cap(
        p-lo,
        p-hi,
        if extent-is-length { half } else { RADIAL-DEFAULT-CAP-HALF },
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

    if axis == "y" {
      cetz.draw.line(
        (centre-c, span-lo),
        (centre-c, span-hi),
        stroke: stroke-spec,
      )
      cetz.draw.line((cap-lo, span-lo), (cap-hi, span-lo), stroke: stroke-spec)
      cetz.draw.line((cap-lo, span-hi), (cap-hi, span-hi), stroke: stroke-spec)
    } else {
      cetz.draw.line(
        (span-lo, centre-c),
        (span-hi, centre-c),
        stroke: stroke-spec,
      )
      cetz.draw.line((span-lo, cap-lo), (span-lo, cap-hi), stroke: stroke-spec)
      cetz.draw.line((span-hi, cap-lo), (span-hi, cap-hi), stroke: stroke-spec)
    }
  }
}
