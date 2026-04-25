// Continuous axis transformations: log10, sqrt, and reverse on the y axis.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = range(1, 11).map(i => (x: i, y: calc.pow(2, i)))

#grid(
  columns: 2,
  column-gutter: 0.4cm,
  row-gutter: 0.4cm,
  plot(
    data: d,
    mapping: aes(x: "x", y: "y"),
    layers: (geom-point(size: 2pt),),
    width: 8cm,
    height: 5cm,
    labs: labs(title: "Linear y"),
  ),
  plot(
    data: d,
    mapping: aes(x: "x", y: "y"),
    layers: (geom-point(size: 2pt),),
    scales: (scale-y-log10(),),
    width: 8cm,
    height: 5cm,
    labs: labs(title: "Log10 y"),
  ),

  plot(
    data: d,
    mapping: aes(x: "x", y: "y"),
    layers: (geom-point(size: 2pt),),
    scales: (scale-y-sqrt(),),
    width: 8cm,
    height: 5cm,
    labs: labs(title: "Sqrt y"),
  ),
  plot(
    data: d,
    mapping: aes(x: "x", y: "y"),
    layers: (geom-point(size: 2pt),),
    scales: (scale-y-reverse(),),
    width: 8cm,
    height: 5cm,
    labs: labs(title: "Reversed y"),
  ),
)
