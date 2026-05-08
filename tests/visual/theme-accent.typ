// Smoke render: theme.accent flows into geom-smooth's default stroke.

#import "../../lib.typ": *

#let d = range(0, 20).map(i => (
  x: i,
  y: i * 0.5 + calc.sin(i * 0.5),
))

#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 2pt), geom-smooth(method: "lm", se: true)),
  theme: theme-bw(accent: rgb("#cc0000")),
  width: 10cm,
  height: 6cm,
)
