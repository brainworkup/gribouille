// geom-errorbarh: horizontal error bars per category, plus point estimates.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let df = ()
#for (i, cat) in ("alpha", "beta", "gamma", "delta", "epsilon").enumerate() {
  let mid = 2 + i + calc.sin(i) * 0.6
  df.push((cat: cat, x: mid, lo: mid - 0.7, hi: mid + 0.5))
}

#plot(
  data: df,
  mapping: aes(y: "cat", x: "x", xmin: "lo", xmax: "hi"),
  layers: (
    geom-errorbarh(height: 0.4, stroke: 1pt, colour: rgb("#1f77b4")),
    geom-point(size: 3pt, fill: rgb("#1f77b4")),
  ),
  scales: (
    scale-x-continuous(name: "estimate"),
    scale-y-discrete(name: "category"),
  ),
  labs: labs(title: "Per-category horizontal error bars"),
  width: 10cm,
  height: 5cm,
)
