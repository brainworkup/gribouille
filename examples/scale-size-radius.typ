// scale-size-manual and scale-radius alongside the existing area variant.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let cont = range(1, 8).map(i => (x: i, y: i, w: i * i))

#plot(
  data: cont,
  mapping: aes(x: "x", y: "y", size: "w"),
  layers: (geom-point(fill: rgb("#1f77b4")),),
  scales: (scale-radius(range: (1pt, 8pt)),),
  labs: labs(title: "scale-radius (linear)"),
  width: 10cm,
  height: 4cm,
)

#plot(
  data: cont,
  mapping: aes(x: "x", y: "y", size: "w"),
  layers: (geom-point(fill: rgb("#1f77b4")),),
  scales: (scale-size-area(range: (1pt, 8pt)),),
  labs: labs(title: "scale-size-area (sqrt)"),
  width: 10cm,
  height: 4cm,
)

#let manual = (
  (x: 1, y: 1, g: "small"),
  (x: 2, y: 2, g: "small"),
  (x: 1, y: 2, g: "medium"),
  (x: 2, y: 3, g: "medium"),
  (x: 1, y: 3, g: "large"),
  (x: 2, y: 4, g: "large"),
)

#plot(
  data: manual,
  mapping: aes(x: "x", y: "y", size: "g"),
  layers: (geom-point(fill: rgb("#1f77b4")),),
  scales: (
    scale-size-manual(
      values: (2pt, 4pt, 8pt),
      limits: ("small", "medium", "large"),
    ),
  ),
  labs: labs(title: "scale-size-manual"),
  width: 10cm,
  height: 4cm,
)
