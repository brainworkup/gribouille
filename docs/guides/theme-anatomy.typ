// Standalone anatomy figure for docs/guides/theming.qmd.
//
// Compile from the project root for debugging:
//
//   typst compile --root . docs/guides/theme-anatomy.typ docs/guides/theme-anatomy.pdf
//
// The .qmd page reuses this file via `#include "/docs/guides/theme-anatomy.typ"`
// inside its {typst} chunk; do not move it without updating that path.

#import "/lib.typ": *
#import "@preview/cetz:0.5.2": canvas, draw

#set page(width: auto, height: auto, margin: 0.5cm)

#let _ink = {
  let v = sys.inputs.at("typst-render-foreground", default: "")
  if v == "" { rgb("#1f2328") } else { rgb(v) }
}
#let _muted = rgb("#666666")

#let _demo-data = (
  (g: "A", x: 1, y: 2.4),
  (g: "A", x: 2, y: 3.1),
  (g: "A", x: 3, y: 3.8),
  (g: "A", x: 4, y: 4.2),
  (g: "B", x: 1, y: 1.6),
  (g: "B", x: 2, y: 2.0),
  (g: "B", x: 3, y: 2.7),
  (g: "B", x: 4, y: 3.1),
)

#let _demo-plot = plot(
  data: _demo-data,
  mapping: aes(x: "x", y: "y", colour: "g"),
  layers: (geom-point(size: 3pt),),
  facet: facet-wrap("g"),
  labs: labs(
    title: "Anatomy of a plot",
    subtitle: "Each region is one theme() key",
    caption: "Caption text lives in plot-caption",
    x: "x (axis-title)",
    y: "y (axis-title)",
    colour: "Group",
  ),
  theme: theme(
    plot-background: element-rect(fill: rgb("#fffaf0")),
    panel-background: element-rect(fill: rgb("#eef4ff")),
    strip-background: element-rect(fill: rgb("#ffe2d6")),
    legend-background: element-rect(
      fill: rgb("#e6f4ea"),
      colour: rgb("#bcd9c4"),
      stroke: 0.3pt,
    ),
    panel-grid: element-line(colour: rgb("#c0c8d4"), stroke: 0.4pt),
    axis-line: element-line(stroke: 0.6pt),
    axis-ticks: element-line(stroke: 0.6pt),
    plot-margin: margin(top: 1cm, right: 1cm, bottom: 1cm, left: 1cm),
  ),
  width: 12cm,
  height: 6.5cm,
)

#canvas(length: 1cm, {
  import draw: *
  set-style(content: (frame: none))

  let px = 4.5
  let py = 4.0
  let pw = 12.0
  let ph = 6.5

  content(
    (px, py),
    anchor: "south-west",
    _demo-plot,
  )

  let cstroke = 0.5pt + _muted
  let left-x = 3.5
  let right-x = 16.3

  let lab(name, keys) = text(size: 7.5pt, fill: _ink)[
    *#name* \
    #text(size: 7pt, font: "DejaVu Sans Mono", fill: _muted)[#keys]
  ]

  let callouts = (
    (
      from: (5.85, 11.45),
      label: (left-x, 12.8),
      anchor: "south-east",
      name: "Outer canvas",
      keys: [`plot-background`],
    ),
    (
      from: (6.0, 11.7),
      label: (left-x, 11.4),
      anchor: "south-east",
      name: "Inset around content",
      keys: [`plot-margin`],
    ),
    (
      from: (6.65, 8.05),
      label: (left-x, 8.4),
      anchor: "south-east",
      name: "Left axis",
      keys: [
        `axis-line-y-left` \
        `axis-ticks-y-left` \
        `axis-text-y-left` \
        `axis-title-y-left`
      ],
    ),
    (
      from: (7.0, 4.85),
      label: (left-x, 3.8),
      anchor: "south-east",
      name: "Caption",
      keys: [`plot-caption`],
    ),
    (
      from: (8.5, 11.7),
      label: (right-x, 12.7),
      anchor: "south-west",
      name: "Title block",
      keys: [
        `plot-title` \
        `plot-subtitle`
      ],
    ),
    (
      from: (9.0, 10.2),
      label: (right-x, 11.4),
      anchor: "south-west",
      name: "Facet strip",
      keys: [
        `strip-background` \
        `strip-text`
      ],
    ),
    (
      from: (12.5, 8.0),
      label: (right-x, 9.5),
      anchor: "south-west",
      name: "Panel",
      keys: [
        `panel-background` \
        `panel-grid`
      ],
    ),
    (
      from: (15.3, 9.9),
      label: (right-x, 5.8),
      anchor: "south-west",
      name: "Legend",
      keys: [
        `legend-background` \
        `legend-title` \
        `legend-text` \
        `legend-bar` \
        `legend-ticks`
      ],
    ),
    (
      from: (10.8, 5.35),
      label: (right-x, 3.8),
      anchor: "south-west",
      name: "Bottom axis",
      keys: [
        `axis-line-x-bottom` \
        `axis-ticks-x-bottom` \
        `axis-text-x-bottom` \
        `axis-title-x-bottom`
      ],
    ),
  )

  for c in callouts {
    line(c.label, c.from, stroke: cstroke, mark: (end: ">"))
    content(c.label, anchor: c.anchor, lab(c.name, c.keys))
  }

  // Double-arrow indicators showing the extent of plot-margin on each rim.
  let mstroke = 0.5pt + rgb("#bf8b00")
  let mtag(pos, anchor) = content(
    pos,
    anchor: anchor,
    text(
      size: 6.5pt,
      font: "DejaVu Sans Mono",
      fill: rgb("#bf8b00"),
    )[plot-margin],
  )
  let dbl = (start: ">", end: ">")
  line((10.5, 9.55), (10.5, 10.8), stroke: mstroke, mark: dbl)
  mtag((10.65, 10.18), "west")
  line((5.7, 10.3), (6.85, 10.3), stroke: mstroke, mark: dbl)
  mtag((6.275, 10.45), "south")
  line((15.5, 8.0), (15.85, 8.0), stroke: mstroke, mark: dbl)
  mtag((15.675, 7.85), "north")
  line((10.5, 4.85), (10.5, 6.05), stroke: mstroke, mark: dbl)
  mtag((10.65, 5.45), "west")
})
