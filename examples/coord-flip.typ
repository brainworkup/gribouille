// coord-flip swaps x and y so vertical bars read as horizontal.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let revenue = (
  (q: "Q1", revenue: 10),
  (q: "Q2", revenue: 18),
  (q: "Q3", revenue: 25),
  (q: "Q4", revenue: 22),
)

#let panel(title, body) = {
  set align(center)
  stack(dir: ttb, spacing: 0.2cm, text(weight: "bold", title), body)
}

#stack(
  dir: ttb,
  spacing: 0.5cm,
  panel(
    "Default cartesian",
    plot(
      data: revenue,
      mapping: aes(x: "q", y: "revenue", fill: "q"),
      layers: (geom-col(),),
      guides: guides(fill: guide-none()),
      scales: (
        scale-y-continuous(labels: label-currency(symbol: "$", digits: 0)),
      ),
      labs: labs(x: "Quarter", y: "Revenue (M)"),
      theme: theme-minimal(),
      width: 12cm,
      height: 9cm,
    ),
  ),
  panel(
    "coord-flip()",
    plot(
      data: revenue,
      mapping: aes(x: "q", y: "revenue", fill: "q"),
      layers: (geom-col(),),
      coord: coord-flip(),
      guides: guides(fill: guide-none()),
      scales: (
        scale-y-continuous(labels: label-currency(symbol: "$", digits: 0)),
      ),
      labs: labs(x: "Quarter", y: "Revenue (M)"),
      theme: theme-minimal(),
      width: 12cm,
      height: 9cm,
    ),
  ),
)
