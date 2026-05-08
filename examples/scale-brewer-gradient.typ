// ColorBrewer plus gradient/gradient2 scales.

#import "../lib.typ": *

#set page(width: 12cm)

#let discrete-d = (
  (x: 1, y: 1, g: "alpha"),
  (x: 2, y: 2, g: "beta"),
  (x: 3, y: 3, g: "gamma"),
  (x: 4, y: 4, g: "delta"),
  (x: 5, y: 5, g: "epsilon"),
)

#let continuous-d = range(0, 16).map(i => (x: i, y: i, z: i * 1.0))
#let diverging-d = range(-7, 8).map(i => (x: i, y: i, z: i * 1.0))

#let panel(title, body) = {
  set align(center)
  stack(dir: ttb, spacing: 0.2cm, text(weight: "bold", title), body)
}

#let theme0 = theme-minimal()

#grid(
  columns: 2,
  column-gutter: 0.5cm,
  row-gutter: 0.5cm,
  panel(
    "scale-fill-brewer (Set1)",
    plot(
      data: discrete-d,
      mapping: aes(x: "x", y: "y", fill: "g"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-fill-brewer(palette: "Set1"),),
      labs: labs(x: "x", y: "y", fill: "Group"),
      theme: theme0,
      width: 12cm,
      height: 9cm,
    ),
  ),
  panel(
    "scale-fill-brewer (Spectral)",
    plot(
      data: discrete-d,
      mapping: aes(x: "x", y: "y", fill: "g"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-fill-brewer(palette: "Spectral"),),
      labs: labs(x: "x", y: "y", fill: "Group"),
      theme: theme0,
      width: 12cm,
      height: 9cm,
    ),
  ),

  panel(
    "scale-fill-gradient (two-stop)",
    plot(
      data: continuous-d,
      mapping: aes(x: "x", y: "y", fill: "z"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-fill-gradient(),),
      labs: labs(x: "x", y: "y", fill: "z"),
      theme: theme0,
      width: 12cm,
      height: 9cm,
    ),
  ),
  panel(
    "scale-fill-gradient2 (around 0)",
    plot(
      data: diverging-d,
      mapping: aes(x: "x", y: "y", fill: "z"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-fill-gradient2(midpoint: 0),),
      labs: labs(x: "x", y: "y", fill: "z"),
      theme: theme0,
      width: 12cm,
      height: 9cm,
    ),
  ),
)
