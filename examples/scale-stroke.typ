// scale-stroke: marker outline thickness driven by the stroke aesthetic.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let cont = range(1, 8).map(i => (x: i, y: i, w: i))

#plot(
  data: cont,
  mapping: aes(x: "x", y: "y", stroke: "w"),
  layers: (geom-point(size: 6pt, fill: rgb("#1f77b4")),),
  scales: (scale-stroke-continuous(range: (0.2pt, 2pt)),),
  labs: labs(title: "scale-stroke-continuous"),
  width: 10cm,
  height: 4cm,
)

#let manual = (
  (x: 1, y: 1, g: "thin"),
  (x: 2, y: 2, g: "thin"),
  (x: 1, y: 2, g: "medium"),
  (x: 2, y: 3, g: "medium"),
  (x: 1, y: 3, g: "thick"),
  (x: 2, y: 4, g: "thick"),
)

#plot(
  data: manual,
  mapping: aes(x: "x", y: "y", stroke: "g"),
  layers: (geom-point(size: 6pt, fill: rgb("#1f77b4")),),
  scales: (
    scale-stroke-manual(
      values: (0.2pt, 0.8pt, 2pt),
      limits: ("thin", "medium", "thick"),
    ),
  ),
  labs: labs(title: "scale-stroke-manual"),
  width: 10cm,
  height: 4cm,
)
