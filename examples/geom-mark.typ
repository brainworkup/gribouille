// geom-mark: enclose each cluster with a chosen shape.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let pts = ()
#for (cx, cy, k) in ((1, 1, "a"), (4, 1.5, "b"), (2.5, 4, "c")) {
  for i in range(0, 8) {
    pts.push((
      x: cx + 0.6 * calc.cos(i * 0.7),
      y: cy + 0.6 * calc.sin(i * 0.7),
      k: k,
    ))
  }
}

#plot(
  data: pts,
  mapping: aes(x: "x", y: "y", fill: "k"),
  layers: (
    geom-mark(method: "hull", expand: 0.3, alpha: 0.25),
    geom-point(size: 3pt),
  ),
  labs: labs(title: "geom-mark, method = \"hull\""),
  width: 10cm,
  height: 5cm,
)

#plot(
  data: pts,
  mapping: aes(x: "x", y: "y", fill: "k"),
  layers: (
    geom-mark(method: "ellipse", expand: 0.4, alpha: 0.25),
    geom-point(size: 3pt),
  ),
  labs: labs(title: "geom-mark, method = \"ellipse\""),
  width: 10cm,
  height: 5cm,
)

#plot(
  data: pts,
  mapping: aes(x: "x", y: "y", fill: "k"),
  layers: (
    geom-mark(method: "rect", expand: 0.3, alpha: 0.2),
    geom-point(size: 3pt),
  ),
  labs: labs(title: "geom-mark, method = \"rect\""),
  width: 10cm,
  height: 5cm,
)

#plot(
  data: pts,
  mapping: aes(x: "x", y: "y", fill: "k"),
  layers: (
    geom-mark(method: "circle", expand: 0.3, alpha: 0.2),
    geom-point(size: 3pt),
  ),
  labs: labs(title: "geom-mark, method = \"circle\""),
  width: 10cm,
  height: 5cm,
)
