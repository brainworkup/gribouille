// Errorbar family: four range-style geoms over the same per-quarter summary.

#import "../lib.typ": *

#set page(width: 12cm)

#let accent = rgb("#1f77b4")

#let revenue = (
  (quarter: 1, mean: 12.4, lo: 11.0, hi: 13.5),
  (quarter: 2, mean: 14.1, lo: 13.0, hi: 15.4),
  (quarter: 3, mean: 13.6, lo: 12.0, hi: 14.8),
  (quarter: 4, mean: 16.2, lo: 14.6, hi: 17.7),
)

#let panel(title, layers) = {
  set align(center)
  stack(
    dir: ttb,
    spacing: 0.2cm,
    text(weight: "bold", title),
    plot(
      data: revenue,
      mapping: aes(x: "quarter", y: "mean", ymin: "lo", ymax: "hi"),
      layers: layers,
      scales: (
        scale-x-continuous(breaks: (1, 2, 3, 4)),
        scale-y-continuous(labels: label-currency(symbol: "$", digits: 1)),
      ),
      labs: labs(x: "Quarter", y: "Revenue"),
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
  panel("geom-errorbar", (
    geom-errorbar(width: 0.4, stroke: 1pt, colour: accent),
    geom-point(size: 3pt, fill: accent),
  )),
  panel("geom-linerange", (
    geom-linerange(stroke: 1.2pt, colour: accent),
    geom-point(size: 3pt, fill: accent),
  )),

  panel("geom-crossbar", (
    geom-crossbar(fill: rgb("#a8c6d8"), stroke: 1pt, colour: accent),
  )),
  panel("geom-pointrange", (
    geom-pointrange(size: 3pt, stroke: 1.2pt, colour: accent),
  )),
)
