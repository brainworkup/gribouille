// Long-tail geoms: blank, rug, function across three panels.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let panel(title, plot-body) = {
  set align(center)
  stack(dir: ttb, spacing: 0.2cm, text(weight: "bold", title), plot-body)
}

#let p1 = plot(
  data: mpg,
  mapping: aes(x: "displ", y: "hwy", colour: "class"),
  layers: (
    geom-point(size: 2.5pt, alpha: 0.85),
    geom-rug(sides: "bl"),
  ),
  labs: labs(x: "Displacement (L)", y: "Highway mpg", colour: "Class"),
  theme: theme-minimal(),
  width: 8cm,
  height: 5cm,
)

#let frame = ((x: -calc.pi, y: -1), (x: calc.pi, y: 1))

#let p2 = plot(
  data: frame,
  mapping: aes(x: "x", y: "y"),
  layers: (
    geom-blank(),
    geom-function(
      fun: x => calc.sin(x),
      xlim: (-calc.pi, calc.pi),
      colour: rgb("#d62728"),
      stroke: 1.2pt,
    ),
  ),
  scales: (scale-x-continuous(breaks: (-3, -1.5, 0, 1.5, 3)),),
  labs: labs(x: "x", y: "sin(x)"),
  theme: theme-minimal(),
  width: 8cm,
  height: 5cm,
)

#let p3 = plot(
  data: mpg,
  mapping: aes(x: "hwy"),
  layers: (
    geom-blank(
      data: ((x: 10, y: 0), (x: 50, y: 1)),
      mapping: aes(x: "x", y: "y"),
      inherit-aes: false,
    ),
    geom-rug(sides: "b", colour: rgb("#2ca02c"), length: 0.4),
  ),
  scales: (scale-x-continuous(name: "Highway mpg"),),
  labs: labs(y: ""),
  theme: theme-minimal(),
  width: 8cm,
  height: 5cm,
)

#stack(
  dir: ttb,
  spacing: 0.5cm,
  panel("geom-rug for marginal observations", p1),
  panel("geom-blank as a frame for geom-function", p2),
  panel("Forced x-range to highlight rug density", p3),
)
