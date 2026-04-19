// Facet-wrap with a per-panel smoother. Each group has a different slope;
// the linear fit in every panel follows only its own subset of rows.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let slopes = (a: 0.5, b: -0.4, c: 1.2)
#let df = ()
#for (group, slope) in slopes.pairs() {
  for i in range(0, 20) {
    let x = i
    let jitter = calc.sin(i * 1.7 + slopes.at(group) * 3.1) * 0.6
    df.push((group: group, x: x, y: slope * x + jitter))
  }
}

#plot(
  data: df,
  mapping: aes(x: "x", y: "y"),
  layers: (
    geom-point(size: 2pt),
    geom-smooth(method: "lm"),
  ),
  facet: facet-wrap("group", ncol: 3),
  theme: theme-minimal(),
)
