// Per-geom legend glyphs: a `colour` aesthetic driven by a line layer
// renders as a stroke in the legend, while `fill` driven by a ribbon
// renders as a small rectangle.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = (
  (x: 1, y: 2.0, ymin: 1.4, ymax: 2.6, band: "centre", series: "main"),
  (x: 2, y: 3.2, ymin: 2.6, ymax: 3.8, band: "centre", series: "main"),
  (x: 3, y: 2.7, ymin: 2.0, ymax: 3.4, band: "centre", series: "main"),
  (x: 4, y: 4.1, ymin: 3.4, ymax: 4.7, band: "centre", series: "main"),
)

#plot(
  data: d,
  mapping: aes(x: "x", y: "y", colour: "series", fill: "band"),
  layers: (
    geom-ribbon(
      mapping: aes(ymin: "ymin", ymax: "ymax"),
      alpha: 0.3,
      inherit-aes: true,
    ),
    geom-line(),
  ),
  scales: (
    scale-x-continuous(name: "x"),
    scale-y-continuous(name: "y"),
  ),
  width: 10cm,
  height: 6cm,
)
