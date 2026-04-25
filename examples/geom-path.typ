// geom-path: connects rows in input order, not sorted by x.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = ()
#for i in range(0, 60) {
  let t = i * 0.2
  d.push((x: calc.cos(t) * (3 + t * 0.05), y: calc.sin(t) * (3 + t * 0.05)))
}

#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-path(stroke: 1pt),),
  width: 9cm,
  height: 5cm,
)
