// stat-ellipse: per-group covariance ellipse drawn through geom-ellipse.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let pts = ()
#for (cx, cy, k) in ((0, 0, "alpha"), (4, 1, "beta"), (2, 4, "gamma")) {
  for i in range(0, 30) {
    pts.push((
      x: cx + calc.cos(i * 0.5),
      y: cy + calc.sin(i * 0.5) * 0.6,
      k: k,
    ))
  }
}

#plot(
  data: pts,
  mapping: aes(x: "x", y: "y", fill: "k"),
  layers: (
    geom-ellipse(stat: stat-ellipse(level: 0.95), alpha: 0.2),
    geom-point(size: 2pt),
  ),
  labs: labs(title: "stat-ellipse, level = 0.95"),
  width: 12cm,
  height: 6cm,
)
