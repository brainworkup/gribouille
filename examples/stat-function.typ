// stat-function: same shape as the sin(x) panel of longtail-geoms but the
// samples are produced by stat-function instead of geom-function.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let frame-x = (
  (x: -calc.pi, y: -1),
  (x: calc.pi, y: 1),
)

#plot(
  data: frame-x,
  mapping: aes(x: "x", y: "y"),
  layers: (
    geom-blank(),
    geom-line(
      stat: stat-function(fun: x => calc.sin(x), xlim: (-calc.pi, calc.pi)),
      colour: rgb("#d62728"),
      stroke: 1pt,
    ),
  ),
  labs: labs(title: "stat-function: sin(x) sampled via the stat surface"),
  width: 9cm,
  height: 5cm,
)
