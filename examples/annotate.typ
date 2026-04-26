// annotate(): add ad-hoc text labels and a reference line to a base plot.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let df = range(0, 11).map(i => (
  x: i,
  y: 4 + 2 * calc.sin(i * 0.7) + i * 0.15,
))

#plot(
  data: df,
  mapping: aes(x: "x", y: "y"),
  layers: (
    geom-point(size: 3pt, fill: rgb("#1f77b4")),
    annotate(
      "text",
      x: 5,
      y: 6,
      label: "peak",
      anchor: "south",
      dy: 0.3,
      size: 10pt,
    ),
    annotate(
      "text",
      x: 0.5,
      y: 7.5,
      label: "Series A",
      anchor: "west",
      size: 12pt,
    ),
    annotate("vline", xintercept: 5, colour: rgb("#cc0000"), stroke: 0.8pt),
  ),
  labs: labs(
    title: "Annotated series",
    x: "Index",
    y: "Value",
  ),
  width: 11cm,
  height: 7cm,
)
