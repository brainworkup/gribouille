// coord-flip: swap the x and y axes so vertical bars become horizontal.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let revenue = (
  (q: "Q1", revenue: 10),
  (q: "Q2", revenue: 18),
  (q: "Q3", revenue: 25),
  (q: "Q4", revenue: 22),
)

#stack(
  dir: ttb,
  spacing: 0.6cm,
  plot(
    data: revenue,
    mapping: aes(x: "q", y: "revenue"),
    layers: (geom-col(),),
    labs: labs(title: "Default cartesian", x: "Quarter", y: "Revenue (k$)"),
    width: 10cm,
    height: 6cm,
  ),
  plot(
    data: revenue,
    mapping: aes(x: "q", y: "revenue"),
    layers: (geom-col(),),
    coord: coord-flip(),
    labs: labs(title: "coord-flip()", x: "Quarter", y: "Revenue (k$)"),
    width: 10cm,
    height: 6cm,
  ),
)
