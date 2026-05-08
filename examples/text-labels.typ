// geom-text and geom-label: annotate points with their name.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let cities = (
  (x: 2.0, y: 5.3, name: "Alpha"),
  (x: 4.0, y: 2.8, name: "Beta"),
  (x: 6.0, y: 7.0, name: "Gamma"),
  (x: 8.0, y: 4.1, name: "Delta"),
)

#let panel(title, body) = {
  set align(center)
  stack(dir: ttb, spacing: 0.2cm, text(weight: "bold", title), body)
}

#let accent = rgb("#1f77b4")

#stack(
  dir: ttb,
  spacing: 0.5cm,
  panel(
    "geom-text (plain)",
    plot(
      data: cities,
      mapping: aes(x: "x", y: "y", label: "name"),
      layers: (
        geom-point(size: 4pt, fill: accent),
        geom-text(size: 9pt, dy: 0.3, anchor: "south"),
      ),
      labs: labs(x: "x", y: "y"),
      theme: theme-minimal(),
      width: 12cm,
      height: 9cm,
    ),
  ),
  panel(
    "geom-label (boxed)",
    plot(
      data: cities,
      mapping: aes(x: "x", y: "y", label: "name"),
      layers: (
        geom-point(size: 4pt, fill: accent),
        geom-label(size: 9pt, dy: 0.35, anchor: "south"),
      ),
      labs: labs(x: "x", y: "y"),
      theme: theme-minimal(),
      width: 12cm,
      height: 9cm,
    ),
  ),
)
