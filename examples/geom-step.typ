// geom-step: stair-step interpolation between consecutive points.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = (
  (x: 1, y: 1, dir: "hv"),
  (x: 2, y: 3, dir: "hv"),
  (x: 3, y: 2, dir: "hv"),
  (x: 4, y: 5, dir: "hv"),
  (x: 5, y: 4, dir: "hv"),
)

#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-step(stroke: 1pt, direction: "hv"),),
  width: 9cm,
  height: 5cm,
)
