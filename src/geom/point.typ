///! Scatterplot markers.
///!
///! Draws one shape per row at the `(x, y)` position from the aesthetic
///! mapping. `fill` paints the marker body; `colour` paints the outline.
///! Size, shape, and alpha can each be mapped or set as fixed layer
///! parameters.

#import "../deps.typ": cetz
#import "../scale/train.typ": map-discrete, map-position
#import "../utils/palette.typ": default-shapes, spec-palette
#import "../utils/colour-resolve.typ": resolve-size
#import "../utils/fill-resolve.typ": resolve-fill-colour
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/stroke.typ": resolve-stroke-spec
#import "../guide/draw-marker.typ": draw-marker

/// Scatterplot layer drawing a marker for each row at `(x, y)`.
///
/// Default `stat` is `"identity"` and default `position` is `"identity"`.
/// `fill` paints the marker body; `colour` paints the outline. Shape and
/// alpha can be mapped via \@aes or set to fixed values through the layer
/// parameters below.
///
/// \@category Geoms
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Falls back to the plot mapping when `none`.
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
/// \@param size Marker size (a Typst length).
/// \@param colour Fixed marker outline colour. `auto` resolves via the colour scale, falling back to the theme `ink` only when neither `colour` nor `fill` is set.
/// \@param fill Marker body fill. `auto` resolves via the fill scale or a neutral default.
/// \@param stroke Marker outline thickness (a Typst length) or stroke dictionary; `none` disables the outline and the `colour` aesthetic.
/// \@param alpha Marker opacity in `[0, 1]`.
/// \@param shape Marker shape keyword (e.g. `"circle"`, `"square"`, `"triangle"`). `auto` honours the shape scale.
/// \@param key Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
/// \@param stat Statistical transform name. Usually left at `"identity"`.
/// \@param position Position adjustment name. Usually left at `"identity"`.
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Default scatter, mapping `fill` to a categorical column.
/// ```
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "a"),
///   (x: 4, y: 5, sp: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "sp"),
///   layers: (geom-point(size: 3pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Map `shape` and `size` alongside `fill` to encode three
/// dimensions on the same scatter.
/// ```
/// #let d = (
///   (x: 1, y: 2, sp: "a", w: 1),
///   (x: 2, y: 4, sp: "b", w: 2),
///   (x: 3, y: 3, sp: "a", w: 3),
///   (x: 4, y: 5, sp: "b", w: 4),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "sp", shape: "sp", size: "w"),
///   layers: (geom-point(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-line, \@geom-text, \@scale-shape, \@aes
#let geom-point(
  mapping: none,
  data: none,
  size: auto,
  colour: auto,
  fill: auto,
  stroke: 0.5pt,
  alpha: auto,
  shape: auto,
  key: auto,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "point",
  mapping: mapping,
  data: data,
  params: (
    size: size,
    colour: colour,
    fill: fill,
    stroke: stroke,
    alpha: alpha,
    shape: shape,
  ),
  key: key,
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

#let _palette-at(palette, idx) = palette.at(calc.rem(idx, palette.len()))

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none or mapping.x == none or mapping.y == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let ink = ctx.theme.at("ink", default: black)
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    ink,
    ink,
  )

  let shape-param = layer.params.shape
  let shape-pinned = shape-param != auto and shape-param != none
  let shape-col = mapping.at("shape", default: none)
  let shape-trained = ctx.trained.at("shape", default: none)
  let shape-palette = spec-palette(shape-trained, default-shapes)
  let default-shape-kind = if shape-pinned { shape-param } else { "circle" }

  for row in data {
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
    let size = resolve-size(layer, mapping, ctx, row, 1.5pt)
    let body-fill = resolve-fill-colour(
      layer,
      mapping,
      ctx,
      row,
      default-fill,
    )
    let stroke-spec = resolve-stroke-spec(
      layer,
      mapping,
      ctx,
      row,
      default-colour,
    )
    let shape-kind = if shape-pinned {
      shape-param
    } else if shape-col != none and shape-trained != none {
      if shape-trained.type == "identity" {
        let v = row.at(shape-col, default: none)
        if v == none or v == "" { default-shape-kind } else { str(v) }
      } else {
        let idx = shape-trained.domain.position(v => (
          v == str(row.at(shape-col, default: none))
        ))
        if idx == none { default-shape-kind } else {
          _palette-at(shape-palette, idx)
        }
      }
    } else { default-shape-kind }
    draw-marker((cx, cy), shape-kind, size, body-fill, stroke-spec)
  }
}
