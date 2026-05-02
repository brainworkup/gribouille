// weight aesthetic: per-row weights threaded into counts, bins, and smoothers.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

// Pre-aggregated counts: each row carries a weight that the stat sums into
// the bar height instead of counting the row as 1.
#let counts = (
  (grp: "a", n: 12),
  (grp: "b", n: 4),
  (grp: "c", n: 9),
  (grp: "d", n: 6),
)

#plot(
  data: counts,
  mapping: aes(x: "grp", weight: "n"),
  layers: (geom-bar(),),
  labs: labs(title: "geom-bar with weight = pre-aggregated count"),
  width: 10cm,
  height: 4cm,
)

// Weighted least squares: outliers carry low weight so the fitted line is
// pulled toward the high-weight points.
#let pts = ()
#for i in range(0, 20) {
  pts.push((x: i, y: i * 0.5 + calc.sin(i * 0.4), w: 1))
}
// Two outliers with negligible weight; the WLS fit ignores them.
#pts.push((x: 5, y: 30, w: 0.001))
#pts.push((x: 15, y: -20, w: 0.001))

#plot(
  data: pts,
  mapping: aes(x: "x", y: "y", weight: "w"),
  layers: (
    geom-point(size: 2pt),
    geom-smooth(method: "lm"),
  ),
  labs: labs(title: "geom-smooth with weighted least squares"),
  width: 10cm,
  height: 5cm,
)
