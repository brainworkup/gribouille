// scale-x-date: monthly time series rendered with year-month axis labels.
//
// x values are ISO-8601 date strings; the scale parses them into days since
// 2000-01-01 during training. Months step roughly every 30 days for a simple
// monthly cadence.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let epoch = datetime(year: 2000, month: 1, day: 1)
#let d = range(0, 12).map(i => (
  x: (epoch + duration(days: 8766 + 30 * i)).display("[year]-[month]-[day]"),
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
