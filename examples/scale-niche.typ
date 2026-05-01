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

#let continuous-d = ()
#for i in range(0, 16) {
  continuous-d.push((x: i, y: i, z: i * 1.0))
}

#let make(label, body) = {
  set align(center)
  stack(
    dir: ttb,
    spacing: 0.2cm,
    text(weight: "bold", label),
    body,
  )
}

#grid(
  columns: 3,
  column-gutter: 0.4cm,
  row-gutter: 0.5cm,
  make(
    "grey (discrete)",
    plot(
      data: discrete-d,
      mapping: aes(x: "x", y: "y", fill: "g"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-fill-grey(),),
      width: 6cm,
      height: 5cm,
    ),
  ),
  make(
    "hue (discrete)",
    plot(
      data: discrete-d,
      mapping: aes(x: "x", y: "y", fill: "g"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-fill-hue(),),
      width: 6cm,
      height: 5cm,
    ),
  ),
  make(
    "distiller Spectral (continuous)",
    plot(
      data: continuous-d,
      mapping: aes(x: "x", y: "y", fill: "z"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-fill-distiller(palette: "Spectral"),),
      width: 6cm,
      height: 5cm,
    ),
  ),
)
