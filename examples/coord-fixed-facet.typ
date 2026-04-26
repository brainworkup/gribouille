// coord-fixed combined with facet-wrap: each panel locks its inner drawing
// area so one x unit equals one y unit, even across multiple facets.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let d = ()
#for x in range(0, 11) {
  d.push((g: "alpha", x: x, y: x))
  d.push((g: "beta", x: x, y: x + 1))
  d.push((g: "gamma", x: x, y: x - 1))
}

#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 2pt), geom-line(colour: rgb("#1f77b4"))),
  facet: facet-wrap("g", ncol: 3),
  coord: coord-fixed(ratio: 1),
  labs: labs(title: "coord-fixed(ratio: 1) inside facet-wrap"),
  width: 16cm,
  height: 7cm,
)
