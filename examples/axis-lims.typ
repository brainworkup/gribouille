// guide-axis(), xlim(), ylim(), and lims() customise axis tick labels
// and explicit axis limits.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let pts = (
  (x: 1.0, y: 2.1),
  (x: 2.0, y: 3.0),
  (x: 3.0, y: 4.2),
  (x: 4.0, y: 5.3),
  (x: 5.0, y: 6.1),
  (x: 6.0, y: 5.5),
  (x: 7.0, y: 4.8),
)

#let dated = (
  (m: "January", n: 12),
  (m: "February", n: 17),
  (m: "March", n: 14),
  (m: "April", n: 22),
  (m: "May", n: 19),
  (m: "June", n: 26),
)

#let make-plot(label, body) = {
  set align(center)
  stack(dir: ttb, spacing: 0.2cm, text(weight: "bold", label), body)
}

#grid(
  columns: 3,
  column-gutter: 0.5cm,
  row-gutter: 0.5cm,
  make-plot(
    "default",
    plot(
      data: pts,
      mapping: aes(x: "x", y: "y"),
      layers: (geom-point(size: 2.5pt),),
      width: 6cm,
      height: 5cm,
    ),
  ),
  make-plot(
    "guide-axis(angle: 45)",
    plot(
      data: dated,
      mapping: aes(x: "m", y: "n"),
      layers: (geom-point(size: 2.5pt),),
      guides: guides(x: guide-axis(angle: 45)),
      width: 6cm,
      height: 5cm,
    ),
  ),
  make-plot(
    "lims(x: (0, 20), y: (-5, 5))",
    plot(
      data: pts,
      mapping: aes(x: "x", y: "y"),
      layers: (geom-point(size: 2.5pt),),
      scales: lims(x: (0, 20), y: (-5, 5)),
      width: 6cm,
      height: 5cm,
    ),
  ),
)
