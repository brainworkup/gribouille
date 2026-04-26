// stat-function: same shape as the sin(x) panel of longtail-geoms but the
// samples are produced by stat-function instead of geom-function. The stat
// runs ahead of plotting via apply-stat to feed any line-style geom.

#import "../lib.typ": *
#import "../src/stat/apply.typ": apply-stat

#set page(width: auto, height: auto, margin: 0.5cm)

#let frame-x = (
  (x: -calc.pi, y: -1),
  (x: calc.pi, y: 1),
)

#let curve = apply-stat(
  "function",
  (),
  none,
  (
    fun: x => calc.sin(x),
    xlim: (-calc.pi, calc.pi),
    n: 101,
    args: (:),
  ),
).data

#plot(
  data: frame-x,
  mapping: aes(x: "x", y: "y"),
  layers: (
    geom-blank(),
    geom-line(
      data: curve,
      mapping: aes(x: "x", y: "y"),
      inherit-aes: false,
      colour: rgb("#d62728"),
      stroke: 1pt,
    ),
  ),
  labs: labs(title: "stat-function: sin(x) sampled via the stat surface"),
  width: 9cm,
  height: 5cm,
)
