///! Boxed text labels at `(x, y)` positions.
///!
///! Like \@geom-text but wraps the label in a rectangle with configurable
///! fill, stroke, inset, and corner radius.

#import "../deps.typ": cetz
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/label-draw.typ": (
  compute-aabbs, compute-placements, draw-segment, segment-config,
)
#import "../utils/radial.typ": project-point
#import "../utils/stroke.typ": build-stroke
#import "../utils/typst-markup.typ": eval-as-markup
#import "../theme/theme.typ": (
  geom-colour-default, geom-defaults, geom-fill-default,
)

#let _to-cm(v) = if type(v) == length { v / 1cm } else { v }

/// Boxed text label layer reading strings from the `label` aesthetic.
///
/// One boxed text block is drawn per row at the mapped `(x, y)`. The box
/// takes its own fill, stroke, inset, and corner radius. Per-row data-unit
/// offsets are read from the `nudge-x` and `nudge-y` aesthetics; setting
/// `segment: true` draws a connector back to the anchor that avoids the
/// other label boxes of the same layer.
///
/// \@category Geoms
/// \@subcategory Text and annotations
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x`, `y`, and `label`. May map `nudge-x` and `nudge-y` for per-row offsets in data units.
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
/// \@param size Text size (a Typst length).
/// \@param colour Paint applied to both the box outline and the label text. `auto` resolves via the colour scale, falling back to the theme `ink` only when neither `colour` nor `fill` is set.
/// \@param fill Box fill colour. `auto` resolves via the fill scale, falling back to the theme `paper` only when neither `colour` nor `fill` is set.
/// \@param stroke Box outline thickness (a Typst length) or stroke dictionary; `none` disables the outline.
/// \@param alpha Box and text opacity in `[0, 1]`. `auto` honours any mapped alpha aesthetic.
/// \@param inset Padding between text and box border (a Typst length).
/// \@param radius Corner radius of the box (a Typst length).
/// \@param anchor CeTZ anchor (e.g., `"center"`, `"west"`) controlling placement.
/// \@param dx Horizontal offset, as a number (canvas units, 1 = 1cm) or a Typst length (e.g., `4pt`, `2mm`).
/// \@param dy Vertical offset, as a number (canvas units, 1 = 1cm) or a Typst length (e.g., `4pt`, `2mm`).
/// \@param segment Draw a connector from each box back to its anchor point. When `true`, the connector is routed to avoid the AABBs of other boxes of the same layer; dropped when no L-bend clears the obstacles.
/// \@param segment-colour Connector paint. `auto` inherits the theme `ink`.
/// \@param segment-stroke Connector thickness (a Typst length).
/// \@param min-segment-length Connectors shorter than this distance (canvas units, 1 = 1cm) are suppressed.
/// \@param arrow Draw a small V-mark at the anchor end of the connector.
/// \@param arrow-length Arrow stroke length (a Typst length).
/// \@param box-padding Extra cm padding added around each measured box when routing connectors.
/// \@param stat Statistical transform name. Usually `"identity"`.
/// \@param position Position adjustment name. Usually `"identity"`; pass `"nudge"` to shift labels off their points.
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Default boxed labels nudged above their points.
/// ```
/// //| alt: "Three point markers at (x, y) with boxed text labels (a, b, c) nudged above each point on the panel."
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
/// //| alt: "Three points with rounded cream callout labels (alpha, beta, gamma) and orange outlines positioned above markers."
/// #let d = (
///   (x: 1, y: 2, name: "alpha"),
///   (x: 2, y: 4, name: "beta"),
///   (x: 3, y: 3, name: "gamma"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", label: "name"),
///   layers: (
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
  segment: false,
  segment-colour: auto,
  segment-stroke: 0.4pt,
  min-segment-length: 0.05,
  arrow: false,
  arrow-length: 4pt,
  box-padding: 0.05,
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
    segment: segment,
    segment-colour: segment-colour,
    segment-stroke: segment-stroke,
    min-segment-length: min-segment-length,
    arrow: arrow,
    arrow-length: arrow-length,
    box-padding: box-padding,
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

  let g-defaults = geom-defaults(ctx.theme)
  let theme-colour = geom-colour-default(g-defaults)
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    theme-colour,
    geom-fill-default(g-defaults, role: "paper"),
  )
  let label-typst = layer
    .at("typst-marks", default: (:))
    .at("label", default: false)
  let dx-base = _to-cm(layer.params.dx)
  let dy-base = _to-cm(layer.params.dy)
  let segment-on = layer.params.segment
  let needs-placement = (
    segment-on
      or (
        mapping.at("nudge-x", default: none) != none
          or mapping.at("nudge-y", default: none) != none
      )
  )

  let placements = if needs-placement {
    compute-placements(ctx, mapping, data, dx-base, dy-base)
  } else { () }
  let aabbs = if segment-on {
    compute-aabbs(
      placements,
      layer.at("_label-sizes", default: ()),
      layer.params.box-padding,
    )
  } else { () }
  let seg-cfg = if segment-on { segment-config(layer.params, theme-colour) }

  for (idx, row) in data.enumerate() {
    let centre = if needs-placement {
      let p = placements.at(idx)
      if p == none { continue }
      p.centre
    } else {
      let projected = project-point(
        ctx,
        row.at(mapping.x, default: none),
        row.at(mapping.y, default: none),
      )
      if projected == none { continue }
      (projected.at(0) + dx-base, projected.at(1) + dy-base)
    }
    let label = row.at(label-col, default: none)
    if label == none { continue }
    if label-typst { label = eval-as-markup(label) }
    // Resolve text colour with `theme-colour` as the unconditional fallback so
    // the label stays visible even when the exclusive-default rule suppresses
    // the box outline; the outline follows `default-colour` and is dropped
    // when only `fill` is set.
    let text-paint = resolve-channel(
      "colour",
      layer,
      mapping,
      ctx,
      row,
      theme-colour,
    )
    let box-fill = resolve-channel(
      "fill",
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
    let text-size = resolve-channel(
      "size",
      layer,
      mapping,
      ctx,
      row,
      layer.params.size,
    )
    let body = box(
      fill: box-fill,
      stroke: stroke-spec,
      inset: layer.params.inset,
      radius: layer.params.radius,
      text(size: text-size, fill: text-paint)[#label],
    )
    if segment-on {
      draw-segment(idx, placements.at(idx), aabbs, seg-cfg)
    }
    cetz.draw.content(
      centre,
      body,
      anchor: layer.params.anchor,
    )
  }
}
