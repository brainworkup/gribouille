// ColorBrewer + gradient/gradient2/gradientn scales.

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

#let diverging-d = ()
#for i in range(-7, 8) {
  diverging-d.push((x: i, y: i, z: i * 1.0))
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
  columns: 2,
  column-gutter: 0.4cm,
  row-gutter: 0.5cm,
  make(
    "Set1 (discrete)",
    plot(
      data: discrete-d,
      mapping: aes(x: "x", y: "y", colour: "g"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-colour-brewer(palette: "Set1"),),
      width: 7cm,
      height: 5cm,
    ),
  ),
  make(
    "Spectral (discrete)",
    plot(
      data: discrete-d,
      mapping: aes(x: "x", y: "y", colour: "g"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-colour-brewer(palette: "Spectral"),),
      width: 7cm,
      height: 5cm,
    ),
  ),

  make(
    "gradient (two-stop)",
    plot(
      data: continuous-d,
      mapping: aes(x: "x", y: "y", colour: "z"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-colour-gradient(),),
      width: 7cm,
      height: 5cm,
    ),
  ),
  make(
    "gradient2 (around 0)",
    plot(
      data: diverging-d,
      mapping: aes(x: "x", y: "y", colour: "z"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-colour-gradient2(midpoint: 0),),
      width: 7cm,
      height: 5cm,
    ),
  ),
)
