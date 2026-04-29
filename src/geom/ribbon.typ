///! Filled band between `ymin` and `ymax` along x.
///!
///! Requires the aesthetic mapping to provide `x`, `ymin`, and `ymax`. Useful
///! for uncertainty envelopes and shaded ranges under a line.
///! Under \@coord-flip the band currently keeps its `ymin`/`ymax` semantics
///! against the user's original y axis; the visual result may not match a
///! sideways ribbon and should be inspected per use.

#import "../deps.typ": cetz
#import "../scale/train.typ": map-position
#import "../utils/types.typ": parse-number
#import "../utils/fill-resolve.typ": resolve-fill-colour

/// Filled band between `ymin` and `ymax` along the x aesthetic.
///
/// The mapping must provide `x`, `ymin`, and `ymax`. Rows are sorted by x
/// and the polygon is closed between the lower and upper boundaries.
///
/// \@category Geoms
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x`, `ymin`, `ymax`.
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
/// \@param fill Band fill colour. `auto` resolves via the fill scale or a neutral default.
/// \@param stroke Band outline; `none` means no border.
/// \@param alpha Band opacity in `[0, 1]`.
/// \@param stat Statistical transform name. Usually `"identity"`.
/// \@param position Position adjustment name. Usually `"identity"`.
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Plain shaded band between `ymin` and `ymax`.
/// ```
/// #let d = range(0, 10).map(i => (
///   x: i,
///   lo: i * 0.5 - 1,
///   hi: i * 0.5 + 1,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", ymin: "lo", ymax: "hi"),
///   layers: (geom-ribbon(alpha: 0.3),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Pair the ribbon with \@geom-line over a `y` mid-line for a
/// classic uncertainty-around-trend visualisation.
/// ```
/// #let d = range(0, 10).map(i => (
///   x: i, y: i * 0.5, lo: i * 0.5 - 0.6, hi: i * 0.5 + 0.6,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", ymin: "lo", ymax: "hi"),
///   layers: (
///     geom-ribbon(alpha: 0.3),
///     geom-line(stroke: 1pt),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-smooth, \@geom-line
#let geom-ribbon(
  mapping: none,
  data: none,
  fill: auto,
  stroke: none,
  alpha: auto,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "ribbon",
  mapping: mapping,
  data: data,
  params: (fill: fill, stroke: stroke, alpha: alpha),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  let x-col = mapping.at("x", default: none)
  let lo-col = mapping.at("ymin", default: none)
  let hi-col = mapping.at("ymax", default: none)
  if x-col == none or lo-col == none or hi-col == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let sorted = data
    .map(row => {
      let x = parse-number(row.at(x-col, default: none))
      let lo = parse-number(row.at(lo-col, default: none))
      let hi = parse-number(row.at(hi-col, default: none))
      (x: x, lo: lo, hi: hi)
    })
    .filter(p => p.x != none and p.lo != none and p.hi != none)
    .sorted(key: p => p.x)

  if sorted.len() < 2 { return }

  let upper = sorted.map(p => (
    map-position(x-trained, p.x, ctx.px-range),
    map-position(y-trained, p.hi, ctx.py-range),
  ))
  let lower = sorted
    .rev()
    .map(p => (
      map-position(x-trained, p.x, ctx.px-range),
      map-position(y-trained, p.lo, ctx.py-range),
    ))
  let pts = upper + lower
  if pts.any(p => p.at(0) == none or p.at(1) == none) { return }

  let final-fill = resolve-fill-colour(
    layer,
    mapping,
    ctx,
    data.first(),
    rgb("#4c78a8"),
    colour-fallback: false,
    default-alpha: 0.3,
  )

  cetz.draw.line(
    ..pts,
    close: true,
    fill: final-fill,
    stroke: if layer.params.stroke == none { none } else {
      layer.params.stroke
    },
  )
}
