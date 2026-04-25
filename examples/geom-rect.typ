// geom-rect: filled boxes from xmin/xmax/ymin/ymax.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = (
  (xmin: 0.0, xmax: 1.0, ymin: 0.0, ymax: 2.0, k: "a"),
  (xmin: 1.5, xmax: 3.0, ymin: 0.5, ymax: 3.0, k: "b"),
  (xmin: 3.5, xmax: 5.0, ymin: 1.0, ymax: 4.0, k: "c"),
  (xmin: 0.5, xmax: 2.0, ymin: 2.5, ymax: 4.5, k: "a"),
)

#plot(
  data: d,
  mapping: aes(
    xmin: "xmin",
    xmax: "xmax",
    ymin: "ymin",
    ymax: "ymax",
    fill: "k",
  ),
  layers: (geom-rect(alpha: 0.5),),
  width: 9cm,
  height: 5cm,
)
