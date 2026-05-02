// Two routings for Typst markup in annotations:
//   - annotate("typst", label: "...") — the geom always evaluates the label.
//   - annotate("text",  label: typst("...")) — the typst() tag forces eval.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

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
      "typst",
      x: 5,
      y: 6.5,
      label: "*peak* at $x = 5$",
      anchor: "south",
      dy: 0.3,
      size: 10pt,
    ),
    annotate(
      "text",
      x: 0.5,
      y: 7.5,
      label: typst("Series _A_"),
      anchor: "west",
      size: 12pt,
    ),
    annotate("vline", xintercept: 5, colour: rgb("#cc0000"), stroke: 0.8pt),
  ),
  labs: labs(
    title: "Typst markup annotations",
    x: "Index",
    y: "Value",
  ),
  width: 12cm,
  height: 6cm,
)
