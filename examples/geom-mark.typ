// geom-mark: enclose each cluster with a chosen shape.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let panel(title, method, expand) = {
  set align(center)
  stack(
    dir: ttb,
    spacing: 0.2cm,
    text(weight: "bold", title),
    plot(
      data: penguins,
      mapping: aes(x: "flipper-len", y: "body-mass", fill: "species"),
      layers: (
        geom-mark(method: method, expand: expand, alpha: 0.25),
        geom-point(size: 2pt, alpha: 0.85),
      ),
      scales: (
        scale-y-continuous(labels: label-comma()),
      ),
      labs: labs(
        x: "Flipper length (mm)",
        y: "Body mass (g)",
        fill: "Species",
      ),
      theme: theme-minimal(),
      width: 7cm,
      height: 5cm,
    ),
  )
}

#grid(
  columns: 2,
  column-gutter: 0.5cm,
  row-gutter: 0.5cm,
  panel(`method: "hull"`, "hull", 8pt),
  panel(`method: "ellipse"`, "ellipse", 10pt),

  panel(`method: "rect"`, "rect", 8pt),
  panel(`method: "circle"`, "circle", 8pt),
)
