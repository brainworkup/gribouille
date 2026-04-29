///! Horizontal reference line(s) at given y intercepts.
///!
///! Works only with a continuous y scale. `yintercept` accepts a single value
///! or an array for drawing multiple reference lines at once.
///! Under \@coord-flip the line is drawn as a vertical reference at the same
///! data value because the y axis becomes the rendered horizontal axis.

#import "../deps.typ": cetz
#import "../scale/train.typ": map-axis
#import "../utils/colour-resolve.typ": (
  apply-alpha, resolve-alpha, resolve-linewidth,
)

/// Horizontal reference line at one or more y intercepts.
///
/// `yintercept` can be a scalar or an array. The layer does not inherit the
/// plot mapping by default; it draws purely from the `yintercept` parameter.
///
/// \@category Geoms
/// \@stability stable
/// \@since 0.0.1
///
/// \@param yintercept Scalar or array of y values at which to draw horizontal lines.
/// \@param colour Line colour. `auto` inherits the theme `ink`.
/// \@param stroke Line thickness (a Typst length).
/// \@param alpha Line opacity in `[0, 1]`.
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping. Defaults to `false`.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Single horizontal reference line at `y = 5`.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i + 2))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-hline(yintercept: 5, colour: rgb("#cc0000")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Pass an array of intercepts to draw several reference lines at
/// once.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i + 2))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-hline(yintercept: (3, 6, 9), colour: rgb("#888888")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-vline, \@geom-abline
#let geom-hline(
  yintercept: none,
  colour: auto,
  stroke: 0.6pt,
  alpha: auto,
  inherit-aes: false,
) = (
  kind: "layer",
  geom: "hline",
  mapping: none,
  data: none,
  params: (
    yintercept: yintercept,
    colour: colour,
    stroke: stroke,
    alpha: alpha,
  ),
  stat: "identity",
  position: "identity",
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  let flipped = ctx.at("flipped", default: false)
  // Under flip, the user's y axis is the rendered horizontal axis, so an
  // hline at `y = k` is drawn as a vertical line at horizontal position k.
  // The trained scale carrying the user's original y values lives on
  // `trained.x` after the renderer's flip swap.
  let trained = ctx.trained.at(if flipped { "x" } else { "y" }, default: none)
  if trained == none or trained.type != "continuous" { return }
  let ys = layer.params.yintercept
  if ys == none { return }
  if type(ys) != array { ys = (ys,) }
  let colour = if layer.params.colour == auto {
    ctx.theme.at("ink", default: black)
  } else { layer.params.colour }
  let mapping = (ctx.resolve-mapping)(layer)
  let alpha = resolve-alpha(layer, mapping, ctx, (:))
  let fill = apply-alpha(colour, alpha)
  let thickness = resolve-linewidth(
    layer,
    mapping,
    ctx,
    (:),
    layer.params.stroke,
  )
  let stroke-spec = (paint: fill, thickness: thickness)
  if flipped {
    let (py-lo, py-hi) = ctx.py-range
    for y in ys {
      let cx = map-axis(trained, float(y), ctx.px-range)
      cetz.draw.line((cx, py-lo), (cx, py-hi), stroke: stroke-spec)
    }
  } else {
    let (px-lo, px-hi) = ctx.px-range
    for y in ys {
      let cy = map-axis(trained, float(y), ctx.py-range)
      cetz.draw.line((px-lo, cy), (px-hi, cy), stroke: stroke-spec)
    }
  }
}
