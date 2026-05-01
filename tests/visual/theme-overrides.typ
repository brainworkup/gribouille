// Smoke render: spot-overrides on a complete theme reach the renderer.

#import "../../lib.typ": *

#let d = range(0, 10).map(i => (x: i, y: i * 0.5))

#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 2pt),),
  theme: theme-minimal(
    axis-title: element-text(size: 14pt),
    panel-background: element-rect(fill: rgb("#f7f0e7")),
    panel-grid: element-line(colour: rgb("#d9cfbf")),
  ),
  width: 10cm,
  height: 6cm,
)
