// scale-*-continuous(limits:) sets explicit data domains; guide-axis tweaks tick text.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let panel(title, body) = {
  set align(center)
  stack(dir: ttb, spacing: 0.2cm, text(weight: "bold", title), body)
}

#let base(extra-scales: (), extra-guides: (:)) = plot(
  data: mpg,
  mapping: aes(x: "displ", y: "hwy"),
  layers: (geom-point(size: 2.5pt, alpha: 0.7),),
  scales: extra-scales,
  guides: extra-guides,
  labs: labs(x: "Displacement (L)", y: "Highway mpg"),
  theme: theme-minimal(),
  width: 12cm,
  height: 9cm,
)

#grid(
  rows: 3,
  column-gutter: 0.5cm,
  row-gutter: 0.5cm,
  panel("default", base()),
  panel(
    "guide-axis(angle: 45)",
    base(extra-guides: guides(x: guide-axis(angle: 45))),
  ),
  panel(
    "limits: (0, 8) / (0, 50)",
    base(extra-scales: (
      scale-x-continuous(limits: (0, 8)),
      scale-y-continuous(limits: (0, 50)),
    )),
  ),
)
