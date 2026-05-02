// geom-ellipse: parametric ellipses with mapped fill and rotation.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = (
  (x0: 0, y0: 0, a: 2, b: 1, angle: 0, k: "wide"),
  (x0: 1, y0: 1, a: 1, b: 0.5, angle: calc.pi / 4, k: "tilt"),
  (x0: -1, y0: 1.5, a: 0.8, b: 0.8, angle: 0, k: "round"),
)

#plot(
  data: d,
  mapping: aes(
    x0: "x0",
    y0: "y0",
    a: "a",
    b: "b",
    angle: "angle",
    fill: "k",
  ),
  layers: (geom-ellipse(alpha: 0.5),),
  labs: labs(title: "Mapped ellipses", fill: "Shape"),
  width: 10cm,
  height: 6cm,
)
