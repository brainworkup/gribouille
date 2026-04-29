///! Boxplots from raw observations using @stat-boxplot.
///!
///! The default `stat = "boxplot"` reduces each group to one summary row
///! before the geom draws. Pass `stat: "identity"` only when the layer
///! receives pre-computed summary rows (`x`, `lower`, `middle`, `upper`,
///! `ymin`, `ymax`, optional `outliers`).

#import "../deps.typ": cetz
#import "../scale/train.typ": map-continuous, map-position
#import "../utils/band.typ": x-band
#import "../utils/types.typ": parse-number
#import "../utils/colour-resolve.typ": apply-alpha, resolve-alpha

/// Boxplot layer: draws a Tukey box, whiskers, and outlier points per group.
///
/// Defaults to `stat = "boxplot"`, so the layer accepts raw observations and
/// computes the five-number summary per group internally. The default
/// `position = "identity"` keeps groups at their categorical x slot; switch
/// to `"dodge"` if you want side-by-side boxes per fill level.
///
/// @category Geoms
/// @stability stable
/// @since 0.0.1
///
/// @param mapping Layer-specific aesthetic mapping built with @aes. Falls back to the plot mapping when `none`.
/// @param data Layer-specific dataset. Falls back to the plot data when `none`.
/// @param width Box width in x data units. For discrete x this is also a data-unit width.
/// @param fill Box fill colour. `auto` resolves via the fill scale or a neutral default.
/// @param colour Stroke colour for the box, median, and whiskers. `auto` falls back to the theme ink.
/// @param stroke Stroke thickness for the box outline and whiskers.
/// @param alpha Box opacity in `[0, 1]`.
/// @param outlier-size Marker size for outlier points.
/// @param outlier-colour Marker colour for outlier points. `auto` follows the box stroke colour.
/// @param whisker-cap Cap length at the whisker ends as a fraction of `width`.
/// @param stat Statistical transform name. `"boxplot"` by default.
/// @param position Position adjustment name. `"identity"` by default.
/// @param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// @returns Layer dictionary consumed by @plot.
///
/// @examples Five-number summary computed per category from raw observations.
/// ```
/// #let d = ()
/// #for grp in ("a", "b", "c") {
///   for i in range(20) {
///     d.push((grp: grp, y: calc.sin(i) + i / 10))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y"),
///   layers: (geom-boxplot(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @examples Add a second mapping (`fill`) and switch `position` to
/// `"dodge"` to compare distributions side by side per group.
/// ```
/// #let d = ()
/// #for grp in ("a", "b", "c") {
///   for k in ("x", "y") {
///     for i in range(20) {
///       d.push((grp: grp, k: k, y: calc.sin(i) + i / 10 + (if k == "y" { 0.7 } else { 0 })))
///     }
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y", fill: "k"),
///   layers: (geom-boxplot(position: "dodge"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @stat-boxplot, @geom-col
#let geom-boxplot(
  mapping: none,
  data: none,
  width: 0.6,
  fill: auto,
  colour: auto,
  stroke: 0.6pt,
  alpha: auto,
  outlier-size: 1.8pt,
  outlier-colour: auto,
  whisker-cap: 0.5,
  stat: "boxplot",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "boxplot",
  mapping: mapping,
  data: data,
  params: (
    width: width,
    fill: fill,
    colour: colour,
    stroke: stroke,
    alpha: alpha,
    outlier-size: outlier-size,
    outlier-colour: outlier-colour,
    whisker-cap: whisker-cap,
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
  let lower-col = mapping.at("lower", default: none)
  let middle-col = mapping.at("middle", default: none)
  let upper-col = mapping.at("upper", default: none)
  let ymin-col = mapping.at("ymin", default: none)
  let ymax-col = mapping.at("ymax", default: none)
  if (
    x-col == none
      or lower-col == none
      or middle-col == none
      or upper-col == none
      or ymin-col == none
      or ymax-col == none
  ) { return }

  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }
  if y-trained.type != "continuous" { return }

  let fill-col = mapping.at("fill", default: none)
  let fill-trained = ctx.trained.at("fill", default: none)
  let colour-col = mapping.at("colour", default: none)
  let colour-trained = ctx.trained.at("colour", default: none)
  let ink = ctx.theme.at("ink", default: black)
  let neutral-fill = rgb("#cccccc")

  let default-fill = if (
    layer.params.fill != auto and layer.params.fill != none
  ) { layer.params.fill } else { neutral-fill }
  let default-stroke-colour = if (
    layer.params.colour != auto and layer.params.colour != none
  ) { layer.params.colour } else { ink }
  let outlier-colour-param = layer.params.outlier-colour
  let stroke-thickness = layer.params.stroke
  let half-width = layer.params.width / 2
  let cap-half = half-width * layer.params.whisker-cap

  for row in data {
    let raw-x = row.at(x-col, default: none)
    let cx = map-position(x-trained, raw-x, ctx.px-range)
    if cx == none { continue }

    let lower = parse-number(row.at(lower-col, default: none))
    let middle = parse-number(row.at(middle-col, default: none))
    let upper = parse-number(row.at(upper-col, default: none))
    let ymin = parse-number(row.at(ymin-col, default: none))
    let ymax = parse-number(row.at(ymax-col, default: none))
    if (
      lower == none
        or middle == none
        or upper == none
        or ymin == none
        or ymax == none
    ) { continue }

    // Whisker endpoints come from explicit fields when stat-boxplot supplies
    // them; otherwise we fall back to ymin/ymax (identity stat with
    // pre-computed summaries that omit outlier extremes).
    let whisker-lo = parse-number(row.at("whisker-lo", default: none))
    let whisker-hi = parse-number(row.at("whisker-hi", default: none))
    if whisker-lo == none { whisker-lo = ymin }
    if whisker-hi == none { whisker-hi = ymax }

    let cy-lower = map-continuous(lower, y-trained.domain, ctx.py-range)
    let cy-middle = map-continuous(middle, y-trained.domain, ctx.py-range)
    let cy-upper = map-continuous(upper, y-trained.domain, ctx.py-range)
    let cy-whisker-lo = map-continuous(
      whisker-lo,
      y-trained.domain,
      ctx.py-range,
    )
    let cy-whisker-hi = map-continuous(
      whisker-hi,
      y-trained.domain,
      ctx.py-range,
    )

    let box-band = x-band(x-trained, raw-x, half-width, ctx.px-range)
    let cap-band = x-band(x-trained, raw-x, cap-half, ctx.px-range)
    if box-band == none or cap-band == none { continue }
    let (cx-lo, cx-hi) = box-band
    let (cap-lo, cap-hi) = cap-band

    let resolved-fill = if (
      fill-col != none and fill-trained != none and layer.params.fill == auto
    ) {
      (ctx.resolve-colour)(
        fill-trained,
        row.at(fill-col, default: none),
        ctx.palette,
      )
    } else { default-fill }
    let resolved-stroke = if (
      colour-col != none
        and colour-trained != none
        and layer.params.colour == auto
    ) {
      (ctx.resolve-colour)(
        colour-trained,
        row.at(colour-col, default: none),
        ctx.palette,
      )
    } else { default-stroke-colour }

    let alpha = resolve-alpha(layer, mapping, ctx, row)
    let final-fill = apply-alpha(resolved-fill, alpha)
    let stroke-spec = (paint: resolved-stroke, thickness: stroke-thickness)

    cetz.draw.rect(
      (cx-lo, cy-lower),
      (cx-hi, cy-upper),
      fill: final-fill,
      stroke: stroke-spec,
    )

    cetz.draw.line(
      (cx-lo, cy-middle),
      (cx-hi, cy-middle),
      stroke: stroke-spec,
    )

    cetz.draw.line((cx, cy-whisker-lo), (cx, cy-lower), stroke: stroke-spec)
    cetz.draw.line((cx, cy-upper), (cx, cy-whisker-hi), stroke: stroke-spec)

    if layer.params.whisker-cap > 0 {
      cetz.draw.line(
        (cap-lo, cy-whisker-lo),
        (cap-hi, cy-whisker-lo),
        stroke: stroke-spec,
      )
      cetz.draw.line(
        (cap-lo, cy-whisker-hi),
        (cap-hi, cy-whisker-hi),
        stroke: stroke-spec,
      )
    }

    let outlier-paint = if (
      outlier-colour-param != auto and outlier-colour-param != none
    ) { outlier-colour-param } else { resolved-stroke }
    let outliers = row.at("outliers", default: ())
    for ov in outliers {
      let v = parse-number(ov)
      if v == none { continue }
      let cy = map-continuous(v, y-trained.domain, ctx.py-range)
      cetz.draw.circle(
        (cx, cy),
        radius: layer.params.outlier-size,
        fill: outlier-paint,
        stroke: none,
      )
    }
  }
}
