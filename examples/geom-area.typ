// geom-area: filled polygon from y = 0 up to y along x.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = range(0, 24).map(i => (
  x: i,
  y: calc.sin(i * 0.5) + 1.5,
))

#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-area(alpha: 0.5),),
  width: 9cm,
  height: 5cm,
)
