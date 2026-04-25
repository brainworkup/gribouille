// coord-fixed: lock the panel so one x unit equals `ratio` y units.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let df = range(0, 11).map(i => (x: i, y: i))

#stack(
  dir: ttb,
  spacing: 0.6cm,
  plot(
    data: df,
    mapping: aes(x: "x", y: "y"),
    layers: (geom-line(colour: rgb("#1f77b4")), geom-point(size: 2pt)),
    labs: labs(title: "Default cartesian"),
    width: 12cm,
    height: 6cm,
  ),
  plot(
    data: df,
    mapping: aes(x: "x", y: "y"),
    layers: (geom-line(colour: rgb("#1f77b4")), geom-point(size: 2pt)),
    coord: coord-fixed(ratio: 1),
    labs: labs(title: "coord-fixed(ratio: 1)"),
    width: 12cm,
    height: 6cm,
  ),
)
