// geom-count: scatter where each unique (x, y) is drawn once and the count
// is exposed as the size aesthetic via stat-sum.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let raw = ()
#for x in (1, 2, 3, 4) {
  for y in (1, 2, 3) {
    let n = calc.rem(x + y, 4) + 1
    for _ in range(0, n) { raw.push((x: x, y: y)) }
  }
}

#plot(
  data: raw,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-count(fill: rgb("#1f77b4"), alpha: 0.6),),
  scales: (
    scale-x-continuous(name: "x"),
    scale-y-continuous(name: "y"),
  ),
  labs: labs(title: "geom-count: markers at unique (x, y)"),
  width: 9cm,
  height: 6cm,
)
