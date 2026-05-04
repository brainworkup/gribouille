// guide-legend() and guide-none(): customise or suppress per-aesthetic legends.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let make-panel(title, gs) = {
  set align(center)
  stack(
    dir: ttb,
    spacing: 0.2cm,
    text(weight: "bold", title),
    plot(
      data: mpg,
      mapping: aes(x: "displ", y: "hwy", colour: "class"),
      layers: (geom-point(size: 2.5pt),),
      guides: gs,
      labs: labs(
        x: "Displacement (L)",
        y: "Highway mpg",
        colour: "Class",
      ),
      theme: theme-minimal(),
      width: 11cm,
      height: 4.2cm,
    ),
  )
}

#grid(
  rows: 3,
  column-gutter: 0.5cm,
  row-gutter: 0.5cm,
  make-panel("default", (:)),
  make-panel("guide-legend(reverse: true)", guides(
    colour: guide-legend(reverse: true),
  )),
  make-panel("guide-legend(ncol: 2)", guides(colour: guide-legend(ncol: 2))),
)
