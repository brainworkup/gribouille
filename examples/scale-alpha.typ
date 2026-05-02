// scale-alpha family: continuous, manual per-level opacities, and binned.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let cont = range(0, 10).map(i => (x: i, y: i, w: i + 1))

#plot(
  data: cont,
  mapping: aes(x: "x", y: "y", alpha: "w"),
  layers: (geom-point(size: 5pt, fill: rgb("#1f77b4")),),
  scales: (scale-alpha-continuous(range: (0.2, 1)),),
  labs: labs(title: "scale-alpha-continuous"),
  width: 10cm,
  height: 4cm,
)

#let manual = (
  (x: 1, y: 1, g: "dim"),
  (x: 2, y: 2, g: "dim"),
  (x: 1, y: 2, g: "medium"),
  (x: 2, y: 3, g: "medium"),
  (x: 1, y: 3, g: "full"),
  (x: 2, y: 4, g: "full"),
)

#plot(
  data: manual,
  mapping: aes(x: "x", y: "y", alpha: "g"),
  layers: (geom-point(size: 5pt, fill: rgb("#1f77b4")),),
  scales: (
    scale-alpha-manual(
      values: (0.2, 0.55, 1),
      limits: ("dim", "medium", "full"),
    ),
  ),
  labs: labs(title: "scale-alpha-manual"),
  width: 10cm,
  height: 4cm,
)

#plot(
  data: cont,
  mapping: aes(x: "x", y: "y", alpha: "w"),
  layers: (geom-point(size: 5pt, fill: rgb("#1f77b4")),),
  scales: (scale-alpha-binned(n-breaks: 4, range: (0.2, 1)),),
  labs: labs(title: "scale-alpha-binned"),
  width: 10cm,
  height: 4cm,
)
