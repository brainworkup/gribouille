// Facet wrap with free scales: each panel trains its own y axis on its own
// subset, so panels with very different y-ranges read clearly.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = ()
#for x in range(0, 12) {
  d.push((g: "small", x: x, y: 0.1 * x + 0.05))
  d.push((g: "medium", x: x, y: 2.0 * x + 1.0))
  d.push((g: "large", x: x, y: 50.0 * x + 5.0))
}

#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-line(), geom-point(size: 2pt)),
  facet: facet-wrap("g", ncol: 3, scales: "free_y"),
  scales: (
    scale-x-continuous(name: "Index"),
    scale-y-continuous(name: "Value"),
  ),
  width: 16cm,
  height: 6cm,
)
