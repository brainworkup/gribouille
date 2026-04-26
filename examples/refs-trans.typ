// Reference lines on a log10 y axis: yintercept values land at the
// correct log positions because hline routes through map-axis.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let df = range(1, 11).map(i => (x: i, y: calc.pow(10, i / 3)))

#plot(
  data: df,
  mapping: aes(x: "x", y: "y"),
  layers: (
    geom-point(size: 3pt),
    geom-hline(yintercept: (10, 100, 1000), colour: rgb("#d62728")),
  ),
  scales: (scale-y-log10(),),
  labs: labs(title: "Reference lines on a log10 y axis"),
  width: 10cm,
  height: 7cm,
)
