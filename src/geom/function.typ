///! Polyline of a callable evaluated across the trained x-domain.
///!
///! Samples `n` points uniformly across the x-range and draws a line through
///! `(x, fun(x))`. The layer ignores any inherited data and mapping; it
///! generates its own samples from `fun`.

#import "../deps.typ": cetz
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/radial.typ": project-point
#import "../utils/colour-resolve.typ": apply-alpha, resolve-alpha

/// Polyline of `fun(x)` sampled uniformly across the x-range.
///
/// The trained x-domain is used by default; pass `xlim` to override it.
/// `n` samples are taken across that range. Sampled points where `fun`
/// returns `none` are dropped silently.
///
/// \@category Geoms
/// \@stability stable
/// \@since 0.0.1
///
/// \@param fun Callable taking a numeric x and returning a numeric y, or `none` to skip.
/// \@param n Number of samples taken uniformly across the x-range.
/// \@param xlim Optional `(lo, hi)` overriding the trained x-domain.
/// \@param stroke Line thickness (a Typst length).
/// \@param colour Fixed line colour. `auto` falls back to the theme `ink`.
/// \@param alpha Line opacity in `[0, 1]`.
/// \@param linetype Dash keyword. Defaults to `"solid"`.
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping. Defaults to `false`.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Sine curve sampled across the trained x-domain.
/// ```
/// #let frame = ((x: -calc.pi, y: -1), (x: calc.pi, y: 1))
/// #plot(
///   data: frame,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-blank(),
///     geom-function(fun: x => calc.sin(x)),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Pass `xlim` to override the domain when the training data does
/// not match the function's natural range.
/// ```
/// #let frame = ((x: 0, y: 0), (x: 1, y: 1))
/// #plot(
///   data: frame,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-blank(),
///     geom-function(
///       fun: x => calc.sin(x) * 0.5 + 0.5,
///       xlim: (0, 4 * calc.pi),
///       n: 201,
///     ),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-blank, \@geom-line, \@geom-abline
#let geom-function(
  fun: none,
  n: 101,
  xlim: none,
  stroke: 0.8pt,
  colour: auto,
  alpha: auto,
  linetype: "solid",
  inherit-aes: false,
) = (
  kind: "layer",
  geom: "function",
  mapping: none,
  data: (),
  params: (
    fun: fun,
    n: n,
    xlim: xlim,
    stroke: stroke,
    colour: colour,
    alpha: alpha,
    linetype: linetype,
  ),
  stat: "identity",
  position: "identity",
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  let fun = layer.params.fun
  if fun == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }
  if x-trained.type != "continuous" or y-trained.type != "continuous" { return }

  let domain = if layer.params.xlim != none {
    layer.params.xlim
  } else { x-trained.domain }
  let (lo, hi) = (float(domain.at(0)), float(domain.at(1)))
  if hi <= lo { return }
  let n = calc.max(2, int(layer.params.n))
  let step = (hi - lo) / (n - 1)

  let pts = ()
  for i in range(0, n) {
    let x = lo + i * step
    let y = fun(x)
    if y == none { continue }
    let p = project-point(ctx, x, float(y))
    if p == none { continue }
    pts.push(p)
  }
  if pts.len() < 2 { return }

  let colour = if (
    layer.params.colour != auto and layer.params.colour != none
  ) { layer.params.colour } else { ctx.theme.at("ink", default: black) }
  let mapping = (ctx.resolve-mapping)(layer)
  let alpha = resolve-channel("alpha", layer, mapping, ctx, (:), 1)
  let final-colour = apply-alpha(colour, alpha)

  cetz.draw.line(
    ..pts,
    stroke: (
      paint: final-colour,
      thickness: layer.params.stroke,
      dash: layer.params.linetype,
    ),
  )
}
