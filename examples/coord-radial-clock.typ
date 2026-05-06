// Clock-face layout: hourly observations wrapped to a circle via coord-polar.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let hours = range(0, 24).map(h => (
  hour: h,
  load: 30 + 25 * calc.sin(2 * calc.pi * h / 24) + calc.rem(h * 7, 11),
))

#plot(
  data: hours,
  mapping: aes(x: "hour", y: "load"),
  layers: (
    geom-line(stroke: 1pt),
    geom-point(size: 2pt),
  ),
  coord: coord-polar(theta: "x"),
  scales: (
    scale-x-continuous(limits: (0, 24)),
  ),
  labs: labs(title: "Daily load"),
  theme: theme-minimal(),
  width: 9cm,
  height: 9cm,
)
