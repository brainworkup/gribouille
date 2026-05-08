// geom-area: filled polygon from y = 0 up to y along x.

#import "../lib.typ": *

#set page(width: 12cm)

#plot(
  data: economics,
  mapping: aes(x: "date", y: "unemploy"),
  layers: (
    geom-area(alpha: 0.35, fill: rgb("#1f77b4")),
    geom-line(stroke: 1pt, colour: rgb("#1f77b4")),
  ),
  scales: (
    scale-x-date(),
    scale-y-continuous(labels: label-comma()),
  ),
  labs: labs(
    title: "Monthly US unemployment, 2008-2009",
    subtitle: "Area under the curve highlights the climb during the recession",
    x: "Month",
    y: "Unemployed (thousands)",
    caption: "Source: bundled economics dataset",
  ),
  theme: theme-minimal(),
  width: 12cm,
  height: 9cm,
)
