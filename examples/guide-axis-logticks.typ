// guide-axis-logticks adds minor ticks at log-scale subdivisions on a log10 axis.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let d = (
  (x: 1, y: 1),
  (x: 3, y: 5),
  (x: 10, y: 25),
  (x: 30, y: 100),
  (x: 100, y: 500),
  (x: 300, y: 2500),
  (x: 1000, y: 10000),
)

#let panel(title, gs) = plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (
    geom-line(stroke: 0.6pt, alpha: 0.4),
    geom-point(size: 3pt),
  ),
  scales: (
    scale-x-continuous(trans: "log10", labels: label-comma()),
    scale-y-continuous(trans: "log10", labels: label-comma()),
  ),
  guides: gs,
  labs: labs(title: title, x: "Inputs (log10)", y: "Outputs (log10)"),
  theme: theme-minimal(),
  width: 9cm,
  height: 6cm,
)

#stack(
  dir: ttb,
  spacing: 0.5cm,
  panel("Decade ticks only", (:)),
  panel(
    "guide-axis-logticks() on x and y",
    guides(x: guide-axis-logticks(), y: guide-axis-logticks()),
  ),
)
