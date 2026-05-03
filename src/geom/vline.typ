///! Vertical reference line(s) at given x intercepts.
///!
///! Works only with a continuous x scale. `xintercept` accepts a single value
///! or an array for drawing multiple reference lines at once.
///! Under \@coord-flip the line is drawn as a horizontal reference at the
///! same data value because the x axis becomes the rendered vertical axis.

#import "../deps.typ": cetz
#import "../scale/train.typ": map-axis-data
#import "../utils/colour-resolve.typ": (
  apply-alpha, resolve-alpha, resolve-linewidth,
)

/// Vertical reference line at one or more x intercepts.
///
/// `xintercept` can be a scalar or an array. The layer does not inherit the
/// plot mapping by default; it draws purely from the `xintercept` parameter.
///
/// \@category Geoms
/// \@stability stable
/// \@since 0.0.1
///
/// \@param xintercept Scalar or array of x values at which to draw vertical lines.
/// \@param colour Line colour. `auto` inherits the theme `ink`.
/// \@param stroke Line thickness (a Typst length).
/// \@param alpha Line opacity in `[0, 1]`.
/// \@param linetype Dash keyword. Defaults to `"solid"`.
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping. Defaults to `false`.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Two vertical reference lines at `x = 3` and `x = 6`.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-vline(xintercept: (3, 6), colour: rgb("#4c78a8")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples A single dashed reference line at the data midpoint.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-vline(xintercept: 4.5, stroke: 1pt, colour: rgb("#cc0000")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-hline, \@geom-abline
#let geom-vline(
  xintercept: none,
  colour: auto,
  stroke: 0.6pt,
  alpha: auto,
  linetype: "solid",
  inherit-aes: false,
) = (
  kind: "layer",
  geom: "vline",
  mapping: none,
  data: none,
  params: (
    xintercept: xintercept,
    colour: colour,
    stroke: stroke,
    alpha: alpha,
    linetype: linetype,
  ),
  stat: "identity",
  position: "identity",
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  let flipped = ctx.at("flipped", default: false)
  // Under flip, the user's x axis is the rendered vertical axis, so a vline
  // at `x = k` is drawn as a horizontal line at vertical position k. The
  // trained scale carrying the user's original x values lives on
  // `trained.y` after the renderer's flip swap.
  let trained = ctx.trained.at(if flipped { "y" } else { "x" }, default: none)
  if trained == none or trained.type != "continuous" { return }
  let xs = layer.params.xintercept
  if xs == none { return }
  if type(xs) != array { xs = (xs,) }
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
  let stroke-spec = (
    paint: fill,
    thickness: thickness,
    dash: layer.params.linetype,
  )
  if flipped {
    let (px-lo, px-hi) = ctx.px-range
    for x in xs {
      let cy = map-axis-data(trained, float(x), ctx.py-range)
      cetz.draw.line((px-lo, cy), (px-hi, cy), stroke: stroke-spec)
    }
  } else {
    let (py-lo, py-hi) = ctx.py-range
    for x in xs {
      let cx = map-axis-data(trained, float(x), ctx.px-range)
      cetz.draw.line((cx, py-lo), (cx, py-hi), stroke: stroke-spec)
    }
  }
}
