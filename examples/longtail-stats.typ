// stat-ecdf and stat-unique: ECDF curve plus a deduplicated scatter.
// Left panel: a histogram-like sample drawn as a step-up ECDF using
// `geom-line(stat: "ecdf")`. Right panel: a scatter with explicit
// duplicates collapsed via `geom-point(stat: "unique")`.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let raw = (
  (x: 1),
  (x: 1),
  (x: 2),
  (x: 2),
  (x: 2),
  (x: 3),
  (x: 3),
  (x: 4),
  (x: 5),
  (x: 5),
  (x: 6),
  (x: 7),
  (x: 8),
  (x: 9),
  (x: 10),
)

#let scatter = (
  (x: 1, y: 1),
  (x: 1, y: 1),
  (x: 1, y: 1),
  (x: 2, y: 3),
  (x: 2, y: 3),
  (x: 3, y: 2),
  (x: 4, y: 4),
  (x: 4, y: 4),
  (x: 5, y: 5),
)

#let panel(title, body) = {
  set align(center)
  stack(
    dir: ttb,
    spacing: 0.2cm,
    text(weight: "bold", title),
    body,
  )
}

#grid(
  columns: 2,
  column-gutter: 0.6cm,
  panel(
    "ECDF via stat-ecdf",
    plot(
      data: raw,
      mapping: aes(x: "x"),
      layers: (
        geom-line(stat: "ecdf", colour: rgb("#4c78a8"), stroke: 1.2pt),
      ),
      scales: (
        scale-x-continuous(name: "x"),
        scale-y-continuous(name: "F(x)", limits: (0, 1)),
      ),
      width: 7cm,
      height: 5cm,
    ),
  ),
  panel(
    "Deduped scatter via stat-unique",
    plot(
      data: scatter,
      mapping: aes(x: "x", y: "y"),
      layers: (
        geom-point(stat: "unique", size: 4pt, fill: rgb("#4c78a8")),
      ),
      scales: (
        scale-x-continuous(name: "x"),
        scale-y-continuous(name: "y"),
      ),
      width: 7cm,
      height: 5cm,
    ),
  ),
)
