// stat-summary: per-x mean ± standard error rendered as a line plus a ribbon
// uncertainty band. Five x-buckets, eight observations per bucket. The
// summary statistic is applied per layer via `stat-summary`.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let buckets = (1, 2, 3, 4, 5)
#let offsets = (-1.4, -0.6, -0.2, 0.3, 0.8, -0.5, 0.4, 1.0)

#let raw = ()
#for x in buckets {
  let trend = 2 + 0.6 * x
  for o in offsets {
    raw.push((x: x, y: trend + o))
  }
}

#plot(
  data: raw,
  mapping: aes(x: "x", y: "y"),
  layers: (
    geom-ribbon(
      stat: stat-summary(fun: "mean-se", fun-args: (mult: 1)),
      fill: rgb("#4c78a8"),
      alpha: 0.3,
    ),
    geom-line(
      stat: stat-summary(fun: "mean-se", fun-args: (mult: 1)),
      colour: rgb("#4c78a8"),
      stroke: 1pt,
    ),
    geom-point(
      stat: stat-summary(fun: "mean-se", fun-args: (mult: 1)),
      fill: rgb("#4c78a8"),
      size: 3pt,
    ),
  ),
  scales: (
    scale-x-continuous(name: "x"),
    scale-y-continuous(name: "Mean ± SE"),
  ),
  labs: labs(title: "Per-x mean with standard-error band"),
  width: 10cm,
  height: 7cm,
)
