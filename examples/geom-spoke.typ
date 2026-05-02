// geom-spoke: vector field of unit-length arrows on a small grid.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = ()
#for i in range(0, 6) {
  for j in range(0, 6) {
    d.push((
      x: i,
      y: j,
      angle: calc.atan2(j - 2.5, i - 2.5),
      r: 0.4,
    ))
  }
}

#plot(
  data: d,
  mapping: aes(x: "x", y: "y", angle: "angle", radius: "r"),
  layers: (
    geom-spoke(stroke: 0.6pt),
    geom-point(size: 1.5pt, fill: rgb("#1f77b4")),
  ),
  labs: labs(title: "geom-spoke vector field"),
  width: 8cm,
  height: 8cm,
)
