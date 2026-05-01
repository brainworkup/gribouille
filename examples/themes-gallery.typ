// Gallery of the extra theme presets, with theme-minimal for comparison.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let pts = (
  (x: 1.0, y: 2.1, g: "a"),
  (x: 2.0, y: 3.0, g: "a"),
  (x: 3.0, y: 4.2, g: "a"),
  (x: 4.0, y: 5.3, g: "a"),
  (x: 5.0, y: 6.1, g: "a"),
  (x: 1.5, y: 1.4, g: "b"),
  (x: 2.5, y: 2.3, g: "b"),
  (x: 3.5, y: 3.1, g: "b"),
  (x: 4.5, y: 4.2, g: "b"),
  (x: 5.5, y: 5.0, g: "b"),
)

#let make-plot(label, t) = {
  set align(center)
  stack(
    dir: ttb,
    spacing: 0.2cm,
    text(weight: "bold", label),
    plot(
      data: pts,
      mapping: aes(x: "x", y: "y", fill: "g"),
      layers: (geom-point(size: 2.5pt),),
      theme: t,
      width: 5.5cm,
      height: 4.5cm,
    ),
  )
}

#grid(
  columns: 3,
  column-gutter: 0.4cm,
  row-gutter: 0.4cm,
  make-plot("theme-minimal", theme-minimal()),
  make-plot("theme-bw", theme-bw()),
  make-plot("theme-linedraw", theme-linedraw()),

  make-plot("theme-light", theme-light()), make-plot("theme-dark", theme-dark()), make-plot("theme-test", theme-test()),
)
