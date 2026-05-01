// Binned scale family: stepped fill gradient, fermenter palette, area sizing.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let continuous-d = ()
#for i in range(0, 24) {
  continuous-d.push((x: i, y: i, z: i * 1.0))
}

#let area-d = ()
#for i in range(1, 11) {
  area-d.push((x: i, y: i, w: i * i))
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
    "steps (5 bins)",
    plot(
      data: continuous-d,
      mapping: aes(x: "x", y: "y", fill: "z"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-fill-steps(n-breaks: 5),),
      width: 6cm,
      height: 5cm,
    ),
  ),
  make(
    "fermenter Spectral (7 bins)",
    plot(
      data: continuous-d,
      mapping: aes(x: "x", y: "y", fill: "z"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-fill-fermenter(palette: "Spectral", n-breaks: 7),),
      width: 6cm,
      height: 5cm,
    ),
  ),
  make(
    "size-area (sub-linear)",
    plot(
      data: area-d,
      mapping: aes(x: "x", y: "y", size: "w"),
      layers: (geom-point(),),
      scales: (scale-size-area(range: (1pt, 12pt)),),
      width: 6cm,
      height: 5cm,
    ),
  ),
)
