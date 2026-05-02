// geom-curve: quadratic bezier connectors with mapped colour.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = (
  (x: 0, y: 0, xend: 4, yend: 3, k: "a"),
  (x: 0, y: 3, xend: 4, yend: 0, k: "b"),
  (x: 2, y: 0, xend: 2, yend: 3, k: "a"),
)

#plot(
  data: d,
  mapping: aes(x: "x", y: "y", xend: "xend", yend: "yend", colour: "k"),
  layers: (geom-curve(curvature: 0.5, stroke: 1pt),),
  labs: labs(title: "geom-curve, curvature = 0.5"),
  width: 10cm,
  height: 5cm,
)

#plot(
  data: d,
  mapping: aes(x: "x", y: "y", xend: "xend", yend: "yend", colour: "k"),
  layers: (geom-curve(curvature: -0.5, stroke: 1pt),),
  labs: labs(title: "geom-curve, curvature = -0.5 (flipped)"),
  width: 10cm,
  height: 5cm,
)
