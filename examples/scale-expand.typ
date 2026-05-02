// scale-x-continuous(expand:) and coord-cartesian(expand: false) tune the
// breathing room around the data. `expand:` accepts a ratio (5%) for
// proportional padding, a length (5pt) for canvas-space padding, or a
// 2-tuple `(lo, hi)` to set the sides independently.

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
    "expand: false",
    plot(
      data: pts,
      mapping: aes(x: "x", y: "y"),
      layers: (geom-point(size: 2.5pt),),
      scales: (
        scale-x-continuous(expand: false),
        scale-y-continuous(expand: false),
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
