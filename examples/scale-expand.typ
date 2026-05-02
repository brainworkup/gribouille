// scale-x-continuous(expand:) and coord-cartesian(expand: false) tune the
// breathing room around the data, mirroring ggplot2's expansion() semantics.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let pts = range(1, 11).map(i => (x: i, y: i))

#let make-plot(label, body) = {
  set align(center)
  stack(dir: ttb, spacing: 0.2cm, text(weight: "bold", label), body)
}

#grid(
  columns: 3,
  column-gutter: 0.5cm,
  row-gutter: 0.5cm,
  make-plot(
    "default (5%)",
    plot(
      data: pts,
      mapping: aes(x: "x", y: "y"),
      layers: (geom-point(size: 2.5pt),),
      width: 6cm,
      height: 5cm,
    ),
  ),
  make-plot(
    "expand: expansion(mult: 0)",
    plot(
      data: pts,
      mapping: aes(x: "x", y: "y"),
      layers: (geom-point(size: 2.5pt),),
      scales: (
        scale-x-continuous(expand: expansion(mult: 0)),
        scale-y-continuous(expand: expansion(mult: 0)),
      ),
      width: 6cm,
      height: 5cm,
    ),
  ),
  make-plot(
    "coord-cartesian(expand: false)",
    plot(
      data: pts,
      mapping: aes(x: "x", y: "y"),
      layers: (geom-point(size: 2.5pt),),
      coord: coord-cartesian(expand: false),
      width: 6cm,
      height: 5cm,
    ),
  ),
)
