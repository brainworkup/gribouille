// scale-linewidth family: continuous, manual per-level lengths, and binned.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let cont = range(0, 10).map(i => (x: i, y: i, w: i + 1, g: str(i)))

#plot(
  data: cont,
  mapping: aes(x: "x", y: "y", linewidth: "w", group: "g"),
  layers: (geom-line(),),
  scales: (scale-linewidth-continuous(range: (0.4pt, 2.4pt)),),
  labs: labs(title: "scale-linewidth-continuous"),
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
  mapping: aes(x: "x", y: "y", linewidth: "g", group: "g"),
  layers: (geom-line(),),
  scales: (
    scale-linewidth-manual(
      values: (0.4pt, 1.2pt, 2.4pt),
      limits: ("thin", "medium", "thick"),
    ),
  ),
  labs: labs(title: "scale-linewidth-manual"),
  width: 10cm,
  height: 4cm,
)

#plot(
  data: cont,
  mapping: aes(x: "x", y: "y", linewidth: "w", group: "g"),
  layers: (geom-line(),),
  scales: (scale-linewidth-binned(n-breaks: 4, range: (0.4pt, 2.4pt)),),
  labs: labs(title: "scale-linewidth-binned"),
  width: 10cm,
  height: 4cm,
)
