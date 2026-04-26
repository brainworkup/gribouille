// scale-x-date: monthly time series rendered with year-month axis labels.
//
// x values are days since 2000-01-01: 8766 corresponds to 2024-01-01, then
// each step adds 30 days for a simple monthly cadence.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let d = range(0, 12).map(i => (
  x: 8766 + 30 * i,
  y: calc.sin(i * 0.6) + 1.5,
))

#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (
    geom-line(colour: rgb("#1f77b4")),
    geom-point(size: 2pt),
  ),
  scales: (scale-x-date(date-format: "[year]-[month repr:numerical]"),),
  labs: labs(x: "Month", y: "Value", title: "Monthly series, 2024"),
  width: 14cm,
  height: 6cm,
)
