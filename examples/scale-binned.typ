// Binned scale family: stepped fill gradient, fermenter palette, area sizing.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let continuous-d = range(0, 24).map(i => (x: i, y: i, z: i * 1.0))
#let area-d = range(1, 11).map(i => (x: i, y: i, w: i * i))

#let panel(title, body) = {
  set align(center)
  stack(dir: ttb, spacing: 0.2cm, text(weight: "bold", title), body)
}

#let common-theme = theme-minimal()

#grid(
  rows: 3,
  column-gutter: 0.5cm,
  row-gutter: 0.5cm,
  panel(
    "scale-fill-steps (5 bins)",
    plot(
      data: continuous-d,
      mapping: aes(x: "x", y: "y", fill: "z"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-fill-steps(n-breaks: 5),),
      labs: labs(x: "x", y: "y", fill: "z"),
      theme: common-theme,
      width: 12cm,
      height: 9cm,
    ),
  ),
  panel(
    "scale-fill-fermenter (Spectral, 7)",
    plot(
      data: continuous-d,
      mapping: aes(x: "x", y: "y", fill: "z"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-fill-fermenter(palette: "Spectral", n-breaks: 7),),
      labs: labs(x: "x", y: "y", fill: "z"),
      theme: common-theme,
      width: 12cm,
      height: 9cm,
    ),
  ),
  panel(
    "scale-size-area (sub-linear)",
    plot(
      data: area-d,
      mapping: aes(x: "x", y: "y", size: "w"),
      layers: (geom-point(fill: rgb("#1f77b4")),),
      scales: (scale-size-area(range: (1pt, 12pt)),),
      labs: labs(x: "x", y: "y", size: "w"),
      theme: common-theme,
      width: 12cm,
      height: 9cm,
    ),
  ),
)
