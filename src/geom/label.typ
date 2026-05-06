///! Boxed text labels at `(x, y)` positions.
///!
///! Like \@geom-text but wraps the label in a rectangle with configurable
///! fill, stroke, inset, and corner radius.

#import "../deps.typ": cetz
#import "../utils/colour-resolve.typ": resolve-size, resolve-stroke-colour
#import "../utils/fill-resolve.typ": resolve-fill-colour
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/radial.typ": project-point
#import "../utils/stroke.typ": build-stroke
#import "../utils/typst-markup.typ": eval-as-markup

/// Boxed text label layer reading strings from the `label` aesthetic.
///
/// One boxed text block is drawn per row at the mapped `(x, y)`. The box
/// takes its own fill, stroke, inset, and corner radius.
///
/// \@category Geoms
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x`, `y`, and `label`.
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
/// \@param size Text size (a Typst length).
/// \@param colour Paint applied to both the box outline and the label text. `auto` resolves via the colour scale, falling back to the theme `ink` only when neither `colour` nor `fill` is set.
/// \@param fill Box fill colour. `auto` resolves via the fill scale, falling back to the theme `paper` only when neither `colour` nor `fill` is set.
/// \@param stroke Box outline thickness (a Typst length) or stroke dictionary; `none` disables the outline.
/// \@param alpha Box and text opacity in `[0, 1]`. `auto` honours any mapped alpha aesthetic.
/// \@param inset Padding between text and box border (a Typst length).
/// \@param radius Corner radius of the box (a Typst length).
/// \@param anchor CeTZ anchor (e.g. `"center"`, `"west"`) controlling placement.
/// \@param dx Horizontal offset, as a number (canvas units, 1 = 1cm) or a Typst length (e.g. `4pt`, `2mm`).
/// \@param dy Vertical offset, as a number (canvas units, 1 = 1cm) or a Typst length (e.g. `4pt`, `2mm`).
/// \@param stat Statistical transform name. Usually `"identity"`.
/// \@param position Position adjustment name. Usually `"identity"`; pass `"nudge"` to shift labels off their points.
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Default boxed labels nudged above their points.
/// ```
/// #let d = (
///   (x: 1, y: 2, name: "a"),
///   (x: 2, y: 4, name: "b"),
///   (x: 3, y: 3, name: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", label: "name"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-label(dy: 0.25),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Customise `fill`, `stroke`, and `radius` to match a coloured
/// callout style.
/// ```
/// #let d = (
///   (x: 1, y: 2, name: "alpha"),
///   (x: 2, y: 4, name: "beta"),
///   (x: 3, y: 3, name: "gamma"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", label: "name"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-label(
///       fill: rgb("#fff7e6"),
///       stroke: 0.6pt + rgb("#cc7a00"),
///       radius: 3pt,
///       inset: 4pt,
///       dy: 0.3,
///     ),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-text, \@aes
#let geom-label(
  mapping: none,
  data: none,
  size: 8pt,
  colour: auto,
  fill: auto,
  stroke: 0.4pt,
  alpha: auto,
  inset: 2pt,
  radius: 1pt,
  anchor: "center",
  dx: 0,
  dy: 0,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "label",
  mapping: mapping,
  data: data,
  params: (
    size: size,
    colour: colour,
    fill: fill,
    stroke: stroke,
    alpha: alpha,
    inset: inset,
    radius: radius,
    anchor: anchor,
    dx: dx,
    dy: dy,
  ),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none or mapping.at("x", default: none) == none { return }
  if mapping.at("y", default: none) == none { return }
  let label-col = mapping.at("label", default: none)
  if label-col == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let ink = ctx.theme.at("ink", default: black)
  let paper = ctx.theme.at("paper", default: white)
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    ink,
    paper,
  )
  let label-typst = layer
    .at("typst-marks", default: (:))
    .at("label", default: false)

  for row in data {
    let projected = project-point(
      ctx,
      row.at(mapping.x, default: none),
      row.at(mapping.y, default: none),
    )
    if projected == none { continue }
    let (cx, cy) = projected
    let label = row.at(label-col, default: none)
    if label == none { continue }
    if label-typst { label = eval-as-markup(label) }
    // Text must remain visible regardless of the exclusive-default rule, so
    // resolve with `ink` as the unconditional fallback; the box outline
    // follows `default-colour` and is suppressed when only `fill` is set.
    let text-paint = resolve-stroke-colour(
      layer,
      mapping,
      ctx,
      row,
      ink,
    )
    let box-fill = resolve-fill-colour(
      layer,
      mapping,
      ctx,
      row,
      default-fill,
    )
    let stroke-spec = if default-colour == none {
      none
    } else {
      build-stroke(layer.params.stroke, text-paint)
    }
    let text-size = resolve-size(layer, mapping, ctx, row, layer.params.size)
    let body = box(
      fill: box-fill,
      stroke: stroke-spec,
      inset: layer.params.inset,
      radius: layer.params.radius,
      text(size: text-size, fill: text-paint)[#label],
    )
    let dx = if type(layer.params.dx) == length {
      layer.params.dx / 1cm
    } else { layer.params.dx }
    let dy = if type(layer.params.dy) == length {
      layer.params.dy / 1cm
    } else { layer.params.dy }
    cetz.draw.content(
      (cx + dx, cy + dy),
      body,
      anchor: layer.params.anchor,
    )
  }
}
