// scale_x_log10 pre-transforms data: stats fit a line in log space, so a
// power-law dataset comes out straight.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let accent = rgb("#1f77b4")
#let red = rgb("#d62728")
#let d = range(1, 11).map(i => (x: calc.pow(10, i / 2), y: 2 * (i / 2) + 1))

#let panel(title, scales) = {
  set align(center)
  stack(
    dir: ttb,
    spacing: 0.2cm,
    text(weight: "bold", title),
    plot(
      data: d,
      mapping: aes(x: "x", y: "y"),
      layers: (
        geom-point(size: 3pt, colour: accent),
        geom-smooth(method: "lm", colour: red, fill: red, alpha: 0.15),
      ),
      scales: scales,
      labs: labs(x: "x", y: "y"),
      theme: theme-minimal(),
      width: 9cm,
      height: 5cm,
    ),
  )
}

#stack(
  dir: ttb,
  spacing: 0.5cm,
  panel("Linear x: smooth fits a curved line on power-law data", ()),
  panel(
    "Log10 x (pre-stat): smooth fits a straight line in log space",
    (scale-x-log10(),),
  ),
)
