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

#let theme0 = theme-minimal()

#grid(
  columns: 1,
  row-gutter: 0.5cm,
  plot(
    data: discrete-d,
    mapping: aes(x: "x", y: "y", fill: "g"),
    layers: (geom-point(size: 4pt),),
    scales: (scale-fill-grey(),),
    labs: labs(title: "scale-fill-grey", x: "x", y: "y", fill: "Group"),
    theme: theme0,
    width: 12cm,
    height: 9cm,
  ),
  plot(
    data: discrete-d,
    mapping: aes(x: "x", y: "y", fill: "g"),
    layers: (geom-point(size: 4pt),),
    scales: (scale-fill-hue(),),
    labs: labs(title: "scale-fill-hue", x: "x", y: "y", fill: "Group"),
    theme: theme0,
    width: 12cm,
    height: 9cm,
  ),
  plot(
    data: continuous-d,
    mapping: aes(x: "x", y: "y", fill: "z"),
    layers: (geom-point(size: 4pt),),
    scales: (scale-fill-distiller(palette: "Spectral"),),
    labs: labs(
      title: "scale-fill-distiller (Spectral)",
      x: "x",
      y: "y",
      fill: "z",
    ),
    theme: theme0,
    width: 12cm,
    height: 9cm,
  ),
)
