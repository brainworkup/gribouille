// Identity scales: the column value IS the visual property.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = (
  (x: 1, y: 2, c: "#1b9e77", s: "circle"),
  (x: 2, y: 4, c: "#d95f02", s: "triangle"),
  (x: 3, y: 3, c: "#7570b3", s: "diamond"),
  (x: 4, y: 5, c: "#e7298a", s: "square"),
)

#plot(
  data: d,
  mapping: aes(x: "x", y: "y", colour: "c", shape: "s"),
  layers: (geom-point(size: 3pt),),
  scales: (scale-colour-identity(), scale-shape-identity()),
  width: 9cm,
  height: 5cm,
)
