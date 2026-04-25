// geom-freqpoly: line through binned counts, the line counterpart to a histogram.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = range(0, 60).map(i => (
  x: calc.sin(i * 0.27) * 4 + i * 0.15,
))

#plot(
  data: d,
  mapping: aes(x: "x"),
  layers: (geom-freqpoly(bins: 12, stroke: 1pt),),
  width: 9cm,
  height: 5cm,
)
