// guide-legend() and guide-none(): customise or suppress per-aesthetic legends.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let pts = (
  (x: 1.0, y: 2.1, g: "alpha"),
  (x: 2.0, y: 3.0, g: "beta"),
  (x: 3.0, y: 4.2, g: "gamma"),
  (x: 4.0, y: 5.3, g: "delta"),
  (x: 5.0, y: 6.1, g: "epsilon"),
  (x: 1.5, y: 1.4, g: "alpha"),
  (x: 2.5, y: 2.3, g: "beta"),
  (x: 3.5, y: 3.1, g: "gamma"),
  (x: 4.5, y: 4.2, g: "delta"),
  (x: 5.5, y: 5.0, g: "epsilon"),
)

#let make-plot(label, gs) = {
  set align(center)
  stack(
    dir: ttb,
    spacing: 0.2cm,
    text(weight: "bold", label),
    plot(
      data: pts,
      mapping: aes(x: "x", y: "y", fill: "g"),
      layers: (geom-point(size: 2.5pt),),
      guides: gs,
      width: 6cm,
      height: 5cm,
    ),
  )
}

#grid(
  columns: 3,
  column-gutter: 0.5cm,
  row-gutter: 0.5cm,
  make-plot("default", (:)),
  make-plot("reverse", guides(colour: guide-legend(reverse: true))),
  make-plot("ncol: 2", guides(colour: guide-legend(ncol: 2))),
)
