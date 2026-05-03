// Shared scaffolding for line/path/step. Each geom supplies `build-pts`,
// the rows -> screen points transformation that distinguishes it
// (path: input order; line: sort by x; step: sort + stair).

#import "../deps.typ": cetz
#import "../scale/train.typ": map-position
#import "../utils/types.typ": parse-number
#import "../utils/group.typ": partition-by-group
#import "../utils/colour-resolve.typ": resolve-linewidth, resolve-stroke-colour
#import "../utils/linetype-resolve.typ": resolve-linetype

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

  for g in partition-by-group(data, mapping, trained: ctx.trained) {
    let rows = g.data
    let pts = build-pts(rows, layer, mapping, x-trained, y-trained, ctx)
    if pts.len() < 2 { continue }

    let leader = rows.first()
    let final-colour = resolve-stroke-colour(layer, mapping, ctx, leader, ink)
    let dash = resolve-linetype(layer, mapping, ctx, leader)
    let thickness = resolve-linewidth(
      layer,
      mapping,
      ctx,
      leader,
      layer.params.stroke,
    )
    cetz.draw.line(
      ..pts,
      stroke: (paint: final-colour, thickness: thickness, dash: dash),
    )
  }
}
