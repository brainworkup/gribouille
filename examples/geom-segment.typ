// geom-segment: straight lines from (x, y) to (xend, yend).

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = (
  (x: 0, y: 0, xend: 4, yend: 3, k: "a"),
  (x: 0, y: 3, xend: 4, yend: 0, k: "b"),
  (x: 2, y: 0, xend: 2, yend: 3, k: "c"),
  (x: 0, y: 1.5, xend: 4, yend: 1.5, k: "a"),
)

#plot(
  data: d,
  mapping: aes(x: "x", y: "y", xend: "xend", yend: "yend", colour: "k"),
  layers: (geom-segment(stroke: 1pt),),
  width: 9cm,
  height: 5cm,
)
