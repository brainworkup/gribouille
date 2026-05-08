// scale-stroke: marker outline thickness driven by the stroke aesthetic.

#import "../lib.typ": *

#set page(width: 12cm)

#let accent = rgb("#1f77b4")

#let cont = range(1, 8).map(i => (x: i, y: i, w: i))

#let manual = (
  (x: 1, y: 1, g: "thin"),
  (x: 2, y: 2, g: "thin"),
  (x: 1, y: 2, g: "medium"),
  (x: 2, y: 3, g: "medium"),
  (x: 1, y: 3, g: "thick"),
  (x: 2, y: 4, g: "thick"),
)

#let panel(title, body) = {
  set align(center)
  stack(dir: ttb, spacing: 0.2cm, text(weight: "bold", title), body)
}

#stack(
  dir: ttb,
  spacing: 0.4cm,
  panel(
    "scale-stroke-continuous",
    plot(
      data: cont,
      mapping: aes(x: "x", y: "y", stroke: "w"),
      layers: (geom-point(size: 6pt, fill: accent),),
      scales: (scale-stroke-continuous(range: (0.2pt, 2pt)),),
      labs: labs(x: "x", y: "y", stroke: "w"),
      theme: theme-minimal(),
      width: 12cm,
      height: 9cm,
    ),
  ),
  panel(
    "scale-stroke-manual",
    plot(
      data: manual,
      mapping: aes(x: "x", y: "y", stroke: "g"),
      layers: (geom-point(size: 6pt, fill: accent),),
      scales: (
        scale-stroke-manual(
          values: (0.2pt, 0.8pt, 2pt),
          limits: ("thin", "medium", "thick"),
        ),
      ),
      labs: labs(x: "x", y: "y", stroke: "Outline"),
      theme: theme-minimal(),
      width: 12cm,
      height: 9cm,
    ),
  ),
)
