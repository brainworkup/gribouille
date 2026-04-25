// Facet wrap with both axes free: each panel trains its own x and y on
// its own subset, useful when groups span very different domains in both
// directions.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = (
  (g: "near", t: 0, v: 1.2),
  (g: "near", t: 1, v: 1.4),
  (g: "near", t: 2, v: 1.5),
  (g: "near", t: 3, v: 1.6),
  (g: "mid", t: 50, v: 30),
  (g: "mid", t: 60, v: 38),
  (g: "mid", t: 70, v: 45),
  (g: "mid", t: 80, v: 52),
  (g: "far", t: 1000, v: 600),
  (g: "far", t: 1500, v: 720),
  (g: "far", t: 2000, v: 880),
  (g: "far", t: 2500, v: 950),
)

#plot(
  data: d,
  mapping: aes(x: "t", y: "v"),
  layers: (geom-line(), geom-point(size: 2pt)),
  facet: facet-wrap("g", ncol: 3, scales: "free"),
  scales: (
    scale-x-continuous(name: "Time"),
    scale-y-continuous(name: "Value"),
  ),
  width: 16cm,
  height: 6cm,
)
