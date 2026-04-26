// Errorbar family: same synthetic data, four range-style geoms.
// Top-left: geom-errorbar, top-right: geom-linerange,
// bottom-left: geom-crossbar, bottom-right: geom-pointrange.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let df = ()
#for i in range(1, 6) {
  let mid = i + calc.sin(i) * 0.4
  df.push((x: i, y: mid, lo: mid - 0.8, hi: mid + 0.8))
}

#let make-plot(title, layers) = {
  set align(center)
  stack(
    dir: ttb,
    spacing: 0.2cm,
    text(weight: "bold", title),
    plot(
      data: df,
      mapping: aes(x: "x", y: "y", ymin: "lo", ymax: "hi"),
      layers: layers,
      scales: (
        scale-x-continuous(name: "x"),
        scale-y-continuous(name: "y"),
      ),
      width: 6cm,
      height: 4.5cm,
    ),
  )
}

#grid(
  columns: 2,
  column-gutter: 0.4cm,
  row-gutter: 0.4cm,
  make-plot("geom-errorbar", (geom-errorbar(width: 0.4),)),
  make-plot("geom-linerange", (geom-linerange(stroke: 1.2pt),)),

  make-plot("geom-crossbar", (geom-crossbar(fill: rgb("#a8c6d8")),)),
  make-plot("geom-pointrange", (geom-pointrange(size: 3pt),)),
)
