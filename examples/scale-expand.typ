// scale-*-continuous(expand:) and coord-cartesian(expand: false) tune
// the breathing room around the data.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let pts = range(1, 11).map(i => (x: i, y: i))

#let panel(title, body) = {
  set align(center)
  stack(dir: ttb, spacing: 0.2cm, text(weight: "bold", title), body)
}

#let base(scales: (), coord-arg: none) = plot(
  data: pts,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 2.5pt, fill: rgb("#1f77b4")),),
  scales: scales,
  coord: coord-arg,
  labs: labs(x: "x", y: "y"),
  theme: theme-minimal(),
  width: 6cm,
  height: 5cm,
)

#grid(
  columns: 3,
  column-gutter: 0.5cm,
  row-gutter: 0.5cm,
  panel("default (5% expand)", base()),
  panel("expand: false", base(scales: (
    scale-x-continuous(expand: false),
    scale-y-continuous(expand: false),
  ))),
  panel("coord-cartesian(expand: false)", base(
    coord-arg: coord-cartesian(expand: false),
  )),
)
