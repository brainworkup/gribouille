// Niche fill scales: grey ramp, hue wheel, distiller.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let discrete-d = (
  (x: 1, y: 1, g: "alpha"),
  (x: 2, y: 2, g: "beta"),
  (x: 3, y: 3, g: "gamma"),
  (x: 4, y: 4, g: "delta"),
  (x: 5, y: 5, g: "epsilon"),
)

#let continuous-d = range(0, 16).map(i => (x: i, y: i, z: i * 1.0))

#let panel(title, body) = {
  set align(center)
  stack(dir: ttb, spacing: 0.2cm, text(weight: "bold", title), body)
}

#let theme0 = theme-minimal()

#grid(
  rows: 3,
  column-gutter: 0.5cm,
  row-gutter: 0.5cm,
  panel(
    "scale-fill-grey",
    plot(
      data: discrete-d,
      mapping: aes(x: "x", y: "y", fill: "g"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-fill-grey(),),
      labs: labs(x: "x", y: "y", fill: "Group"),
      theme: theme0,
      width: 6cm,
      height: 5cm,
    ),
  ),
  panel(
    "scale-fill-hue",
    plot(
      data: discrete-d,
      mapping: aes(x: "x", y: "y", fill: "g"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-fill-hue(),),
      labs: labs(x: "x", y: "y", fill: "Group"),
      theme: theme0,
      width: 6cm,
      height: 5cm,
    ),
  ),
  panel(
    "scale-fill-distiller (Spectral)",
    plot(
      data: continuous-d,
      mapping: aes(x: "x", y: "y", fill: "z"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-fill-distiller(palette: "Spectral"),),
      labs: labs(x: "x", y: "y", fill: "z"),
      theme: theme0,
      width: 6cm,
      height: 5cm,
    ),
  ),
)
