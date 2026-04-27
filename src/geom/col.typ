///! Vertical bars taking heights directly from the y aesthetic.
///!
///! Use `geom-col` for pre-aggregated data; use @geom-bar when you want the
///! layer to count observations for you. The layer honours `position: "stack"`,
///! `"dodge"`, and `"fill"` via the matching position adjustments.

#import "../deps.typ": cetz
#import "../scale/train.typ": map-continuous, map-position
#import "../utils/types.typ": parse-number
#import "../utils/colour-resolve.typ": apply-alpha, resolve-alpha

/// Bar layer with heights taken from the y aesthetic.
///
/// Each row becomes one bar centred at its x value. Use @geom-bar (stat-count)
/// when you want automatic counting; `geom-col` expects pre-aggregated y.
///
/// @category Geoms
/// @stability stable
/// @since 0.0.1
///
/// @param mapping Layer-specific aesthetic mapping built with @aes. Falls back to the plot mapping when `none`.
/// @param data Layer-specific dataset. Falls back to the plot data when `none`.
/// @param width Bar width as a fraction of the category width (0 to 1).
/// @param fill Bar fill colour. `auto` resolves via the fill scale or a neutral default.
/// @param stroke Bar outline; `none` means no border.
/// @param alpha Bar opacity in `[0, 1]`.
/// @param key Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
/// @param stat Statistical transform name. Usually `"identity"`.
/// @param position Position adjustment: `"identity"`, `"stack"`, `"dodge"`, or `"fill"`.
/// @param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// @returns Layer dictionary consumed by @plot.
///
/// @example
/// ```
/// #let d = (
///   (q: "Q1", revenue: 10),
///   (q: "Q2", revenue: 18),
///   (q: "Q3", revenue: 25),
///   (q: "Q4", revenue: 22),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "revenue"),
///   layers: (geom-col(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @geom-bar, @position-stack, @position-dodge, @position-fill
#let geom-col(
  mapping: none,
  data: none,
  width: 0.9,
  fill: auto,
  stroke: none,
  alpha: 1,
  key: auto,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "col",
  mapping: mapping,
  data: data,
  params: (width: width, fill: fill, stroke: stroke, alpha: alpha),
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

  let flipped = ctx.at("flipped", default: false)
  // Under flip, the value axis is x and the category axis is y; otherwise
  // the value axis is y and the category axis is x. Bind local aliases so
  // the rest of the routine reads the same regardless of orientation.
  let value-trained = if flipped { x-trained } else { y-trained }
  let cat-trained = if flipped { y-trained } else { x-trained }
  let value-col = if flipped { mapping.x } else { mapping.y }
  let cat-col = if flipped { mapping.y } else { mapping.x }
  let value-range = if flipped { ctx.px-range } else { ctx.py-range }
  let cat-range = if flipped { ctx.py-range } else { ctx.px-range }
  if value-trained.type != "continuous" { return }

  let position = layer.at("position", default: "identity")
  let vmin-col = mapping.at(
    if flipped { "xmin" } else { "ymin" },
    default: none,
  )
  let vmax-col = mapping.at(
    if flipped { "xmax" } else { "ymax" },
    default: none,
  )
  // Stacked/filled bars receive ymin/ymax from the position adjustment under
  // either orientation; the position writes them under the y keys, and under
  // flip the renderer's mapping swap routes them onto x.
  if flipped and vmin-col == none and vmax-col == none {
    vmin-col = mapping.at("ymin", default: none)
    vmax-col = mapping.at("ymax", default: none)
  }
  let use-minmax = (
    (position == "stack" or position == "fill")
      and vmin-col != none
      and vmax-col != none
  )

  let fill-col = mapping.at("fill", default: none)
  let fill-trained = ctx.trained.at("fill", default: none)
  let default-fill = if (
    layer.params.fill != auto and layer.params.fill != none
  ) {
    layer.params.fill
  } else {
    rgb("#4c78a8")
  }

  let baseline-vc = map-continuous(
    calc.max(0.0, value-trained.domain.at(0)),
    value-trained.domain,
    value-range,
  )

  let (cat-lo, cat-hi) = cat-range
  let category-span = if (
    cat-trained.type == "discrete" and cat-trained.domain.len() > 0
  ) {
    (cat-hi - cat-lo) / cat-trained.domain.len()
  } else {
    // Continuous category axis: infer from minimum gap between unique values.
    let xs = data
      .map(r => parse-number(r.at(cat-col, default: none)))
      .filter(v => v != none)
    let (d-lo, d-hi) = cat-trained.domain
    if xs.len() < 2 or d-hi == d-lo {
      (cat-hi - cat-lo) / 10
    } else {
      let sorted = xs.dedup().sorted()
      let gaps = range(sorted.len() - 1).map(i => (
        sorted.at(i + 1) - sorted.at(i)
      ))
      let min-gap = calc.min(..gaps)
      min-gap * (cat-hi - cat-lo) / (d-hi - d-lo)
    }
  }
  let bar-width-fraction = layer.params.width
  let half = category-span * bar-width-fraction / 2

  for row in data {
    let cat-c = map-position(
      cat-trained,
      row.at(cat-col, default: none),
      cat-range,
    )
    if cat-c == none { continue }

    let (v-lo-c, v-hi-c) = if use-minmax {
      let lo-v = parse-number(row.at(vmin-col, default: none))
      let hi-v = parse-number(row.at(vmax-col, default: none))
      if lo-v == none or hi-v == none { continue }
      (
        map-continuous(lo-v, value-trained.domain, value-range),
        map-continuous(hi-v, value-trained.domain, value-range),
      )
    } else {
      let raw = parse-number(row.at(value-col, default: none))
      if raw == none { continue }
      let vc = map-continuous(raw, value-trained.domain, value-range)
      if vc >= baseline-vc { (baseline-vc, vc) } else { (vc, baseline-vc) }
    }

    let centre = cat-c
    let bar-half = half
    if position == "dodge" {
      let offset = row.at("_dodge-offset", default: 0)
      let n = row.at("_dodge-n", default: 1)
      centre = cat-c + offset * category-span * bar-width-fraction
      bar-half = (category-span * bar-width-fraction / n) / 2
    }

    let colour = if fill-col != none and fill-trained != none {
      (ctx.resolve-colour)(
        fill-trained,
        row.at(fill-col, default: none),
        ctx.palette,
      )
    } else { default-fill }
    let alpha = resolve-alpha(layer, mapping, ctx, row)
    let final-fill = apply-alpha(colour, alpha)

    let (a, b) = if flipped {
      ((v-lo-c, centre - bar-half), (v-hi-c, centre + bar-half))
    } else {
      ((centre - bar-half, v-lo-c), (centre + bar-half, v-hi-c))
    }

    cetz.draw.rect(
      a,
      b,
      fill: final-fill,
      stroke: if layer.params.stroke == none { none } else {
        layer.params.stroke
      },
    )
  }
}
