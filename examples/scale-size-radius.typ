// scale-size-manual and scale-radius alongside the existing area variant.

#import "../lib.typ": *

#set page(width: 12cm)

#let accent = rgb("#1f77b4")

#let cont = range(1, 8).map(i => (x: i, y: i, w: i * i))

#let manual = (
  (x: 1, y: 1, g: "small"),
  (x: 2, y: 2, g: "small"),
  (x: 1, y: 2, g: "medium"),
  (x: 2, y: 3, g: "medium"),
  (x: 1, y: 3, g: "large"),
  (x: 2, y: 4, g: "large"),
)

#let panel(title, body) = {
  set align(center)
  stack(dir: ttb, spacing: 0.2cm, text(weight: "bold", title), body)
}

#stack(
  dir: ttb,
  spacing: 0.4cm,
  panel(
    "scale-radius (linear)",
    plot(
      data: cont,
      mapping: aes(x: "x", y: "y", size: "w"),
      layers: (geom-point(fill: accent),),
      scales: (scale-radius(range: (1pt, 8pt)),),
      labs: labs(x: "x", y: "y", size: "w"),
      theme: theme-minimal(),
      width: 12cm,
      height: 9cm,
    ),
  ),
  panel(
    "scale-size-area (sqrt)",
    plot(
      data: cont,
      mapping: aes(x: "x", y: "y", size: "w"),
      layers: (geom-point(fill: accent),),
      scales: (scale-size-area(range: (1pt, 8pt)),),
      labs: labs(x: "x", y: "y", size: "w"),
      theme: theme-minimal(),
      width: 12cm,
      height: 9cm,
    ),
  ),
  panel(
    "scale-size-manual",
    plot(
      data: manual,
      mapping: aes(x: "x", y: "y", size: "g"),
      layers: (geom-point(fill: accent),),
      scales: (
        scale-size-manual(
          values: (2pt, 4pt, 8pt),
          limits: ("small", "medium", "large"),
        ),
      ),
      labs: labs(x: "x", y: "y", size: "Magnitude"),
      theme: theme-minimal(),
      width: 12cm,
      height: 9cm,
    ),
  ),
)
