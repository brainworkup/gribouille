///! Text geom that always evaluates its `label` aesthetic as Typst markup.

#import "./text.typ" as text-geom

/// Text label layer whose `label` aesthetic is always evaluated as Typst markup.
///
/// Sibling of \@geom-text. Use this when every label string must be
/// interpreted as Typst markup at the call site, without wrapping each
/// column reference in \@typst.
///
/// \@category Geoms
/// \@stability stable
/// \@since 0.4.0
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x` and `y`. Map `label` to a column when each row carries its own label, or pass `label:` directly to use a single constant value for every row.
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
/// \@param size Text size (a Typst length).
/// \@param colour Fixed text colour. `auto` inherits the theme `ink`. Used when no colour mapping is active.
/// \@param alpha Text opacity in `[0, 1]`. `auto` honours any mapped alpha aesthetic.
/// \@param anchor CeTZ anchor (e.g. `"center"`, `"west"`) controlling placement.
/// \@param dx Horizontal offset, as a number (canvas units, 1 = 1cm) or a Typst length.
/// \@param dy Vertical offset, as a number (canvas units, 1 = 1cm) or a Typst length.
/// \@param label Constant label drawn at every row's `(x, y)`. Accepts a Typst content block (`[#math.alpha]`, `[*bold*]`) or a markup string (`"$alpha$"`) eval'd as Typst at render time. When `none`, the label is read from the `label` aesthetic mapping.
/// \@param stat Statistical transform name. Usually `"identity"`.
/// \@param position Position adjustment name. Usually `"identity"`.
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Each row's `label` column carries Typst markup that is evaluated
/// in place; no `typst()` wrapper is needed at the call site.
/// ```
/// #let d = (
///   (x: 1, y: 1, t: "$alpha$"),
///   (x: 2, y: 2, t: "*bold*"),
///   (x: 3, y: 3, t: "#emph[italic]"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", label: "t"),
///   layers: (geom-typst(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Use a constant content block as the label at every row.
/// ```
/// #let d = (
///   (x: 1, y: 1),
///   (x: 2, y: 2),
///   (x: 3, y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-typst(label: [#math.alpha]),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-text, \@typst, \@annotate
#let geom-typst(
  mapping: none,
  data: none,
  size: 10pt,
  colour: auto,
  alpha: auto,
  anchor: "center",
  dx: 0,
  dy: 0,
  label: none,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = (
  kind: "layer",
  geom: "typst",
  mapping: mapping,
  data: data,
  params: (
    size: size,
    colour: colour,
    alpha: alpha,
    anchor: anchor,
    dx: dx,
    dy: dy,
    label: label,
  ),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  let new = layer
  let marks = layer.at("typst-marks", default: (:))
  marks.insert("label", true)
  new.insert("typst-marks", marks)
  text-geom.draw(new, ctx)
}
