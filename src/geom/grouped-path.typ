// Shared scaffolding for line/path/step. Each geom supplies `build-pts`,
// the rows -> screen points transformation that distinguishes it
// (path: input order; line: sort by x; step: sort + stair).

#import "../deps.typ": cetz
#import "../scale/train.typ": map-position
#import "../utils/types.typ": parse-number
#import "../utils/palette.typ": default-linetypes, palette-at, spec-palette
#import "../utils/level-resolve.typ": resolve-binned
#import "../utils/group.typ": partition-by-group
#import "../utils/colour-resolve.typ": resolve-linewidth, resolve-stroke-colour

// Sort rows by their x value: numeric for continuous scales, domain index
// for discrete ones. Drops rows whose x value can't be resolved.
#let sort-rows-by-x(rows, mapping, x-trained) = {
  rows
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
    .map(p => p.row)
}

// Map rows to (cx, cy) screen positions using the trained x and y scales.
// Skips rows whose x or y position fails to resolve.
#let rows-to-points(rows, mapping, x-trained, y-trained, ctx) = {
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
  pts
}

#let draw-grouped-paths(layer, ctx, build-pts) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none or mapping.x == none or mapping.y == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let ink = ctx.theme.at("ink", default: black)

  let linetype-param = layer.params.at("linetype", default: auto)
  let linetype-pinned = linetype-param != auto and linetype-param != none
  let linetype-col = mapping.at("linetype", default: none)
  let linetype-trained = ctx.trained.at("linetype", default: none)
  let linetype-palette = spec-palette(linetype-trained, default-linetypes)
  let default-linetype = if linetype-pinned { linetype-param } else { "solid" }

  for g in partition-by-group(data, mapping, trained: ctx.trained) {
    let rows = g.data
    let pts = build-pts(rows, layer, mapping, x-trained, y-trained, ctx)
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
    } else if linetype-col == none or linetype-trained == none {
      default-linetype
    } else {
      let sample = rows.first().at(linetype-col, default: none)
      if linetype-trained.type == "identity" {
        if sample == none or sample == "" { default-linetype } else {
          str(sample)
        }
      } else if linetype-trained.type == "continuous" {
        let resolved = if sample == none { none } else {
          resolve-binned(linetype-trained, sample, default-linetypes)
        }
        if resolved == none { default-linetype } else { resolved }
      } else {
        let idx = linetype-trained.domain.position(v => v == str(sample))
        if idx == none { default-linetype } else {
          palette-at(linetype-palette, idx)
        }
      }
    }

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
