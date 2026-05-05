///! Text labels at `(x, y)` positions.
///!
///! The label string comes from the `label` aesthetic. For a boxed variant
///! with a fill and border, use \@geom-label.

#import "../deps.typ": cetz
#import "../utils/colour-resolve.typ": resolve-size, resolve-stroke-colour
#import "../utils/polar.typ": project-point
#import "../utils/typst-markup.typ": eval-as-markup

/// Text label layer reading strings from the `label` aesthetic.
///
/// One text block is drawn per row at the mapped `(x, y)` with an optional
/// offset via `dx` and `dy`.
///
/// \@category Geoms
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x`, `y`, and `label`.
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
/// \@param size Text size (a Typst length).
/// \@param colour Fixed text colour. `auto` inherits the theme `ink`. Used when no colour mapping is active.
/// \@param alpha Text opacity in `[0, 1]`. `auto` honours any mapped alpha aesthetic.
/// \@param anchor CeTZ anchor (e.g. `"center"`, `"west"`) controlling placement.
/// \@param dx Horizontal offset, as a number (canvas units, 1 = 1cm) or a Typst length (e.g. `4pt`, `2mm`).
/// \@param dy Vertical offset, as a number (canvas units, 1 = 1cm) or a Typst length (e.g. `4pt`, `2mm`).
/// \@param stat Statistical transform name. Usually `"identity"`.
/// \@param position Position adjustment name. Usually `"identity"`; pass `"nudge"` to shift labels off their points.
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Labels nudged above their points via `dy`.
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
///     geom-text(dy: 0.2),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Map `colour` and use `anchor: "west"` to flow labels to the right
/// of each point.
/// ```
/// #let d = (
///   (x: 1, y: 2, name: "a", grp: "x"),
///   (x: 2, y: 4, name: "b", grp: "y"),
///   (x: 3, y: 3, name: "c", grp: "x"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", label: "name", colour: "grp", fill: "grp"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-text(anchor: "west", dx: 0.15),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-label, \@aes
#let geom-text(
  mapping: none,
  data: none,
  size: 8pt,
  colour: auto,
  alpha: auto,
  anchor: "center",
  dx: 0,
  dy: 0,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "text",
  mapping: mapping,
  data: data,
  params: (
    size: size,
    colour: colour,
    alpha: alpha,
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
  let const-label = layer.params.at("label", default: none)
  let use-const = const-label != none
  let label-col = mapping.at("label", default: none)
  if not use-const and label-col == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let ink = ctx.theme.at("ink", default: black)
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
    let label = if use-const { const-label } else {
      row.at(label-col, default: none)
    }
    if label == none { continue }
    if label-typst { label = eval-as-markup(label) }
    let colour = resolve-stroke-colour(layer, mapping, ctx, row, ink)
    let text-size = resolve-size(layer, mapping, ctx, row, layer.params.size)
    let dx = if type(layer.params.dx) == length {
      layer.params.dx / 1cm
    } else { layer.params.dx }
    let dy = if type(layer.params.dy) == length {
      layer.params.dy / 1cm
    } else { layer.params.dy }
    cetz.draw.content(
      (cx + dx, cy + dy),
      text(size: text-size, fill: colour)[#label],
      anchor: layer.params.anchor,
    )
  }
}
