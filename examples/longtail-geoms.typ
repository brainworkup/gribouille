// Long-tail geoms: blank, rug, function across three panels.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let scatter = range(0, 30).map(i => (
  x: i / 3 + calc.sin(i * 0.7),
  y: calc.cos(i * 0.4) * 2 + i / 6,
))

#let frame-x = (
  (x: -calc.pi, y: -1),
  (x: calc.pi, y: 1),
)

#let observations = range(0, 40).map(i => (
  x: calc.sin(i * 0.3) * 4 + 5,
  y: 0,
))

#let p1 = plot(
  data: scatter,
  mapping: aes(x: "x", y: "y"),
  layers: (
    geom-point(size: 2.5pt),
    geom-rug(sides: "bl", colour: rgb("#1f77b4")),
  ),
  labs: labs(title: "Scatter with rug"),
  width: 8cm,
  height: 5cm,
)

#let p2 = plot(
  data: frame-x,
  mapping: aes(x: "x", y: "y"),
  layers: (
    geom-blank(),
    geom-function(
      fun: x => calc.sin(x),
      xlim: (-calc.pi, calc.pi),
      colour: rgb("#d62728"),
      stroke: 1pt,
    ),
  ),
  labs: labs(title: "sin(x) over geom-blank frame"),
  width: 8cm,
  height: 5cm,
)

#let p3 = plot(
  data: observations,
  mapping: aes(x: "x", y: "y"),
  layers: (
    geom-blank(
      data: ((x: 0, y: 0), (x: 10, y: 10)),
      inherit-aes: false,
      mapping: aes(x: "x", y: "y"),
    ),
    geom-rug(sides: "b", colour: rgb("#2ca02c"), length: 0.3),
  ),
  labs: labs(title: "Forced y-range with rug density"),
  width: 8cm,
  height: 5cm,
)

#stack(dir: ttb, spacing: 0.6cm, p1, p2, p3)
