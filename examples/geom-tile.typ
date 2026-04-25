// geom-tile: heatmap of x/y/fill.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = ()
#for x in range(0, 6) {
  for y in range(0, 5) {
    d.push((x: x, y: y, v: x + y + calc.rem(x * y, 3)))
  }
}

#plot(
  data: d,
  mapping: aes(x: "x", y: "y", fill: "v"),
  layers: (geom-tile(),),
  scales: (scale-fill-viridis-c(),),
  width: 9cm,
  height: 5cm,
)
