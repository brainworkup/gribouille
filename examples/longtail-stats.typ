// stat-ecdf and stat-unique: ECDF curve plus a deduplicated scatter.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let accent = rgb("#1f77b4")

#let ecdf = plot(
  data: mpg,
  mapping: aes(x: "hwy"),
  layers: (geom-line(stat: "ecdf", colour: accent, stroke: 1.4pt),),
  scales: (
    scale-x-continuous(name: "Highway mpg"),
    scale-y-continuous(name: "F(x)", limits: (0, 1)),
  ),
  labs: labs(
    title: "ECDF via stat-ecdf",
    x: "Highway mpg",
    y: "F(x)",
  ),
  theme: theme-minimal(),
  width: 12cm,
  height: 9cm,
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

#let dedup = plot(
  data: scatter,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(stat: "unique", size: 4pt, fill: accent),),
  labs: labs(title: "Deduped scatter via stat-unique", x: "x", y: "y"),
  theme: theme-minimal(),
  width: 12cm,
  height: 9cm,
)

#grid(
  columns: 1,
  row-gutter: 0.6cm,
  ecdf,
  dedup,
)
