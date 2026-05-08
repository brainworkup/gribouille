// scale-alpha family: continuous, manual per-level opacities, and binned.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let accent = rgb("#1f77b4")
#let cont = range(0, 10).map(i => (x: i, y: i, w: i + 1))

#let panel(title, body) = {
  set align(center)
  stack(dir: ttb, spacing: 0.2cm, text(weight: "bold", title), body)
}

#let manual = (
  (x: 1, y: 1, g: "dim"),
  (x: 2, y: 2, g: "dim"),
  (x: 1, y: 2, g: "medium"),
  (x: 2, y: 3, g: "medium"),
  (x: 1, y: 3, g: "full"),
  (x: 2, y: 4, g: "full"),
)

#let cont-plot(scale-layer, title) = panel(
  title,
  plot(
    data: cont,
    mapping: aes(x: "x", y: "y", alpha: "w"),
    layers: (geom-point(size: 5pt, fill: accent),),
    scales: (scale-layer,),
    labs: labs(x: "x", y: "y", alpha: "w"),
    theme: theme-minimal(),
    width: 12cm,
    height: 9cm,
  ),
)

#stack(
  dir: ttb,
  spacing: 0.4cm,
  cont-plot(scale-alpha-continuous(range: (0.2, 1)), "scale-alpha-continuous"),
  panel(
    "scale-alpha-manual",
    plot(
      data: manual,
      mapping: aes(x: "x", y: "y", alpha: "g"),
      layers: (geom-point(size: 5pt, fill: accent),),
      scales: (
        scale-alpha-manual(
          values: (0.2, 0.55, 1),
          limits: ("dim", "medium", "full"),
        ),
      ),
      labs: labs(x: "x", y: "y", alpha: "Group"),
      theme: theme-minimal(),
      width: 12cm,
      height: 9cm,
    ),
  ),
  cont-plot(
    scale-alpha-binned(n-breaks: 4, range: (0.2, 1)),
    "scale-alpha-binned",
  ),
)
