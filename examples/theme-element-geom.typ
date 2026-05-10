// theme(geom: element-geom(...)) injects layer-default fill, colour, and
// linewidth into supporting geoms. Each panel below uses the same data and
// shows how a single theme override re-tints every wired geom at once.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let d = (
  (q: "Q1", revenue: 10),
  (q: "Q2", revenue: 18),
  (q: "Q3", revenue: 25),
  (q: "Q4", revenue: 22),
)

#let pts = (
  (x: 1, y: 1),
  (x: 2, y: 4),
  (x: 3, y: 9),
  (x: 4, y: 16),
)

#let make-row(title, custom-theme) = stack(
  dir: ttb,
  spacing: 0.4cm,
  plot(
    data: d,
    mapping: aes(x: "q", y: "revenue"),
    layers: (geom-col(stroke: 0.6pt + black),),
    theme: custom-theme,
    width: 12cm,
    height: 9cm,
    labs: labs(title: title + " (col)"),
  ),
  plot(
    data: pts,
    mapping: aes(x: "x", y: "y"),
    layers: (geom-line(),),
    theme: custom-theme,
    width: 12cm,
    height: 9cm,
    labs: labs(title: title + " (line)"),
  ),
)

#stack(
  dir: ttb,
  spacing: 0.5cm,
  make-row("Default theme", theme-minimal()),
  make-row(
    "theme(geom: element-geom(fill: red, colour: red, linewidth: 1.2pt))",
    theme(
      geom: element-geom(
        fill: rgb("#cc3333"),
        colour: rgb("#cc3333"),
        linewidth: 1.2pt,
      ),
    ),
  ),
)
