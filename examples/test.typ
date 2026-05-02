#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let d = (
  (x: 1, y: 2, name: "a", grp: "x"),
  (x: 2, y: 4, name: "b", grp: "y"),
  (x: 3, y: 3, name: "c", grp: "x"),
)
#plot(
  data: d,
  mapping: aes(x: "x", y: "y", label: "name", colour: "grp", fill: "grp"),
  layers: (
    geom-point(size: 2pt),
    geom-text(anchor: "west", dx: 0.15),
  ),
  width: 10cm,
  height: 6cm,
)
