///! Legend key glyphs.
///!
///! Each geom contributes a small drawing to the legend. The default glyph
///! depends on the geom kind: points draw circles, lines draw short strokes,
///! filled shapes draw small rectangles. Override per layer with `key:`.

#import "../deps.typ": cetz

/// Draw-key returning a small filled circle.
///
/// Used by point and jitter geoms.
///
/// @category Guides
/// @stability stable
/// @since 0.0.1
///
/// @returns Draw-key dictionary consumed by the legend renderer.
///
/// @examples Force the point glyph in the legend (the default for points).
/// ```
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt, key: draw-key-point()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
///
/// @examples Use the point glyph on a layer that would otherwise default
/// to a different shape, like a line layered over points.
/// ```
/// #let d = (
///   (x: 1, y: 1, g: "a"), (x: 2, y: 2, g: "a"),
///   (x: 1, y: 3, g: "b"), (x: 2, y: 1, g: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-line(key: draw-key-point()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
///
/// @see @draw-key-line, @draw-key-rect, @draw-key-path, @draw-key-blank
#let draw-key-point() = (kind: "draw-key", key: "point")

/// Draw-key returning a short horizontal line.
///
/// Used by line, path, step, smooth, segment, hline, vline, and abline geoms.
///
/// @category Guides
/// @stability stable
/// @since 0.0.1
///
/// @returns Draw-key dictionary consumed by the legend renderer.
///
/// @examples Short stroke glyph (the default for line layers).
/// ```
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "a"),
///   (x: 1, y: 3, g: "b"),
///   (x: 2, y: 1, g: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-line(key: draw-key-line()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
///
/// @examples Override a column layer's default rectangle glyph with a line
/// stroke.
/// ```
/// #let d = (
///   (g: "a", n: 3),
///   (g: "b", n: 5),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "g", y: "n", fill: "g"),
///   layers: (geom-col(key: draw-key-line()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
///
/// @see @draw-key-point, @draw-key-rect, @draw-key-path, @draw-key-blank
#let draw-key-line() = (kind: "draw-key", key: "line")

/// Draw-key returning a small filled rectangle.
///
/// Used by bar, col, rect, tile, polygon, area, ribbon, and histogram geoms.
///
/// @category Guides
/// @stability stable
/// @since 0.0.1
///
/// @returns Draw-key dictionary consumed by the legend renderer.
///
/// @examples Filled rectangle glyph (the default for column layers).
/// ```
/// #let d = (
///   (g: "a", n: 3),
///   (g: "b", n: 5),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "g", y: "n", fill: "g"),
///   layers: (geom-col(key: draw-key-rect()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
///
/// @examples Use the rectangle glyph on a point layer when the legend
/// reads more naturally as colour swatches.
/// ```
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "b"),
///   (x: 3, y: 3, g: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt, key: draw-key-rect()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
///
/// @see @draw-key-point, @draw-key-line, @draw-key-path, @draw-key-blank
#let draw-key-rect() = (kind: "draw-key", key: "rect")

/// Draw-key returning a short polyline.
///
/// Useful for path-like geoms where a single straight stroke is misleading.
///
/// @category Guides
/// @stability stable
/// @since 0.0.1
///
/// @returns Draw-key dictionary consumed by the legend renderer.
///
/// @examples Short polyline glyph that hints at a non-monotonic path.
/// ```
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "a"),
///   (x: 1, y: 3, g: "b"),
///   (x: 2, y: 1, g: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-path(key: draw-key-path()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
///
/// @examples Use the path glyph for trajectory-style line layers to make
/// the legend visually consistent with the data.
/// ```
/// #let d = range(0, 24).map(t => (
///   x: calc.cos(t * 0.4), y: calc.sin(t * 0.4) * (t / 24 + 0.5), g: "trajectory",
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-path(stroke: 1pt, key: draw-key-path()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
///
/// @see @draw-key-point, @draw-key-line, @draw-key-rect, @draw-key-blank
#let draw-key-path() = (kind: "draw-key", key: "path")

/// Draw-key that draws nothing.
///
/// Used by `geom-blank` and as a way to suppress a layer's legend glyph
/// without removing the legend entirely.
///
/// @category Guides
/// @stability stable
/// @since 0.0.1
///
/// @returns Draw-key dictionary consumed by the legend renderer.
///
/// @examples Suppress just the layer's glyph in the legend, keeping the
/// label slot.
/// ```
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt, key: draw-key-blank()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
///
/// @examples Useful when one layer in a stack should not appear in the
/// legend; here a `geom-line` carries the legend, a `geom-point` is
/// silenced.
/// ```
/// #let d = (
///   (x: 1, y: 1, g: "a"), (x: 2, y: 2, g: "a"),
///   (x: 1, y: 3, g: "b"), (x: 2, y: 1, g: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (
///     geom-line(stroke: 1pt),
///     geom-point(size: 3pt, key: draw-key-blank()),
///   ),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
///
/// @see @draw-key-point, @draw-key-line, @draw-key-rect, @draw-key-path
#let draw-key-blank() = (kind: "draw-key", key: "blank")

// Default key kind for a geom name. Returns one of "point", "line", "rect",
// or "blank" so the legend can pick a glyph automatically.
#let default-key-for(geom) = {
  if geom == "point" { return "point" }
  if geom == "jitter" { return "point" }
  if (
    "line",
    "path",
    "step",
    "smooth",
    "segment",
    "abline",
    "hline",
    "vline",
    "rug",
    "freqpoly",
    "function",
    "qq",
    "qq-line",
    "errorbar",
    "errorbarh",
    "linerange",
  ).contains(geom) {
    return "line"
  }
  if (
    "col",
    "bar",
    "histogram",
    "rect",
    "tile",
    "area",
    "ribbon",
    "polygon",
    "boxplot",
    "crossbar",
    "label",
  ).contains(geom) {
    return "rect"
  }
  if geom == "blank" { return "blank" }
  "rect"
}

// Draw a small key glyph centred at (cx, cy) of the given half-extent `r`,
// using `colour` for fill (point/rect) or stroke (line/path).
#let draw-glyph(key, cx, cy, r, colour) = {
  if key == "blank" { return }
  if key == "point" {
    cetz.draw.circle(
      (cx, cy),
      radius: r,
      fill: colour,
      stroke: none,
    )
  } else if key == "rect" {
    cetz.draw.rect(
      (cx - r, cy - r),
      (cx + r, cy + r),
      fill: colour,
      stroke: none,
    )
  } else if key == "line" {
    cetz.draw.line(
      (cx - r * 1.4, cy),
      (cx + r * 1.4, cy),
      stroke: (paint: colour, thickness: 1pt),
    )
  } else if key == "path" {
    cetz.draw.line(
      (cx - r * 1.4, cy - r * 0.6),
      (cx - r * 0.4, cy + r * 0.6),
      (cx + r * 0.4, cy - r * 0.4),
      (cx + r * 1.4, cy + r * 0.5),
      stroke: (paint: colour, thickness: 1pt),
    )
  } else {
    cetz.draw.rect(
      (cx - r, cy - r),
      (cx + r, cy + r),
      fill: colour,
      stroke: none,
    )
  }
}
