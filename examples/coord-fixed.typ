// coord-fixed locks the panel so one x unit equals `ratio` y units.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let accent = rgb("#1f77b4")
#let df = range(0, 11).map(i => (x: i, y: i))

#let panel(title, coord-arg) = {
  set align(center)
  stack(
    dir: ttb,
    spacing: 0.2cm,
    text(weight: "bold", title),
    plot(
      data: df,
      mapping: aes(x: "x", y: "y"),
      layers: (
        geom-line(stroke: 1pt, colour: accent),
        geom-point(size: 2pt, fill: accent),
      ),
      coord: coord-arg,
      labs: labs(x: "x", y: "y"),
      theme: theme-minimal(),
      width: 11cm,
      height: 5cm,
    ),
  )
}

#stack(
  dir: ttb,
  spacing: 0.5cm,
  panel("Default cartesian (panel ratio)", none),
  panel("coord-fixed(ratio: 1) — square units", coord-fixed(ratio: 1)),
)
