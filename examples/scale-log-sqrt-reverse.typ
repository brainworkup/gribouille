// Continuous axis transformations: log10, sqrt, and reverse on the y axis.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let accent = rgb("#1f77b4")
#let d = range(1, 11).map(i => (x: i, y: calc.pow(2, i)))

#let panel(title, scales) = {
  set align(center)
  stack(
    dir: ttb,
    spacing: 0.2cm,
    text(weight: "bold", title),
    plot(
      data: d,
      mapping: aes(x: "x", y: "y"),
      layers: (
        geom-line(stroke: 1pt, colour: accent),
        geom-point(size: 2pt, fill: accent),
      ),
      scales: scales,
      labs: labs(x: "x", y: "2^x"),
      theme: theme-minimal(),
      width: 12cm,
      height: 9cm,
    ),
  )
}

#grid(
  rows: 2,
  column-gutter: 0.5cm,
  row-gutter: 0.5cm,
  panel("Linear y", ()), panel("Log10 y", (scale-y-log10(),)),
  panel("Sqrt y", (scale-y-sqrt(),)), panel("Reversed y", (scale-y-reverse(),)),
)
