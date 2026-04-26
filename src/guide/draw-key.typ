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
/// @example
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
/// @example
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
/// @example
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
/// @example
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
/// @example
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
