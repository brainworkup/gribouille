// geom-polygon: closed filled polygons, one per group.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = (
  (x: 0, y: 0, k: "a"),
  (x: 2, y: 0, k: "a"),
  (x: 2, y: 2, k: "a"),
  (x: 0, y: 2, k: "a"),
  (x: 3, y: 1, k: "b"),
  (x: 5, y: 1, k: "b"),
  (x: 5, y: 4, k: "b"),
  (x: 4, y: 5, k: "b"),
  (x: 3, y: 4, k: "b"),
)

#plot(
  data: d,
  mapping: aes(x: "x", y: "y", fill: "k"),
  layers: (geom-polygon(alpha: 0.6),),
  width: 9cm,
  height: 5cm,
)
