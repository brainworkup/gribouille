// Secondary x-axis duplicated on top via `dup-axis`.
// The same ticks appear on the bottom and the top edge of the panel.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = range(0, 11).map(i => (x: i, y: i * i))

#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 2pt),),
  scales: (
    scale-x-continuous(
      name: "x",
      secondary: dup-axis(name: "x (top)"),
    ),
    scale-y-continuous(
      name: "y",
      secondary: sec-axis(
        trans: v => v / 10,
        name: "y / 10",
      ),
    ),
  ),
  width: 10cm,
  height: 6cm,
)
