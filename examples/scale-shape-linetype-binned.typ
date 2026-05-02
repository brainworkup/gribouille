// Binned shape and linetype scales: cut a continuous variable into n bins,
// each bin gets one shape (point geom) or one dash pattern (line geom).

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = range(0, 12).map(i => (x: i, y: i, w: i + 1))

#plot(
  data: d,
  mapping: aes(x: "x", y: "y", shape: "w"),
  layers: (geom-point(size: 4pt),),
  scales: (scale-shape-binned(n-breaks: 4),),
  labs: labs(title: "scale-shape-binned(n-breaks: 4)"),
  width: 10cm,
  height: 4cm,
)

#plot(
  data: d,
  mapping: aes(x: "x", y: "y", shape: "w"),
  layers: (geom-point(size: 4pt),),
  scales: (
    scale-shape-binned(
      n-breaks: 6,
      palette: (
        "circle",
        "square",
        "triangle",
        "diamond",
        "cross",
        "x",
      ),
    ),
  ),
  labs: labs(title: "scale-shape-binned with custom palette"),
  width: 10cm,
  height: 4cm,
)

// Linetype-binned: each group's continuous q value falls in a bin and the
// bin picks a dash. group: pins one polyline per integer level.
#let lined = ()
#for q in range(1, 7) {
  for x in range(0, 6) {
    lined.push((x: x, y: x + q * 0.3, q: q))
  }
}

#plot(
  data: lined,
  mapping: aes(x: "x", y: "y", linetype: "q", group: "q"),
  layers: (geom-line(stroke: 1pt),),
  scales: (scale-linetype-binned(n-breaks: 3),),
  labs: labs(title: "scale-linetype-binned(n-breaks: 3)"),
  width: 10cm,
  height: 4cm,
)
