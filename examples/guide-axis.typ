// guide-axis customises tick label rotation and dodging on a discrete axis.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let make-panel(title, gs) = plot(
  data: mpg,
  mapping: aes(x: "manufacturer"),
  layers: (geom-bar(),),
  guides: gs,
  scales: (scale-y-continuous(name: "Vehicles in sample"),),
  labs: labs(title: title, x: "Manufacturer"),
  theme: theme-minimal(),
  width: 11cm,
  height: 4.2cm,
)

#stack(
  dir: ttb,
  spacing: 0.4cm,
  make-panel("Default tick labels overlap", (:)),
  make-panel("guides(x: guide-axis(angle: 30))", guides(
    x: guide-axis(angle: 30),
  )),
  make-panel("guides(x: guide-axis(n-dodge: 2))", guides(
    x: guide-axis(n-dodge: 2),
  )),
)
