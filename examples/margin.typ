// theme(plot-margin: ...) shifts the canvas using margin().

#import "../lib.typ": *

#set page(width: 12cm)

#let accent = rgb("#1f77b4")
#let d = range(0, 10).map(i => (x: i, y: i * 0.5))

#let panel(title, theme-arg) = {
  set align(center)
  stack(
    dir: ttb,
    spacing: 0.2cm,
    text(weight: "bold", title),
    plot(
      data: d,
      mapping: aes(x: "x", y: "y"),
      layers: (
        geom-line(stroke: 1pt, colour: accent),
        geom-point(size: 2pt, fill: accent),
      ),
      labs: labs(x: "x", y: "y"),
      theme: theme-arg,
      width: 12cm,
      height: 9cm,
    ),
  )
}

#stack(
  dir: ttb,
  spacing: 0.4cm,
  panel("Default plot-margin", theme-minimal()),
  panel(
    "margin(top: 0.6cm, right: 0.6cm, bottom: 0.9cm, left: 1.6cm)",
    theme-minimal(plot-margin: margin(
      top: 0.6cm,
      right: 0.6cm,
      bottom: 0.9cm,
      left: 1.6cm,
    )),
  ),
  panel(
    "margin(top: 0.6cm, left: 1.6cm) — other sides auto",
    theme-minimal(plot-margin: margin(top: 0.6cm, left: 1.6cm)),
  ),
)
